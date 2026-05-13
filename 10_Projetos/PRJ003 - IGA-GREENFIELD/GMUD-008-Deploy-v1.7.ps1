# ====================================================================
# GMUD-008 v1.7 - Deploy Automatizado IaC (Enterprise Edition)
# Projeto: PRJ003 - IGA Greenfield Reference Architecture
# Foco: Automação Total (Netplan + Sudoers + Fix SCRAM Auth)
# Executor: Paulo Feitosa | Data: 19/01/2026
# ====================================================================

# 1. Carregamento e Validação do Baseline
$envPath = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path $envPath)) { Write-Error "❌ .env não encontrado."; exit 1 }

Get-Content $envPath | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
    $name, $value = $_.Split('=', 2)
    Set-Variable -Name $name.Trim() -Value $value.Trim() -Scope Global
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "GMUD-008 v1.7 - Validação de Baseline" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ([string]::IsNullOrWhiteSpace($POSTGRES_PASSWORD) -or [string]::IsNullOrWhiteSpace($VM_IP)) {
    Write-Error "❌ Variáveis críticas vazias no .env"; exit 1
}

$BASE_DIR = "/srv/prj003"
$EVIDENCE_DIR = "$BASE_DIR/evidencias"

# ========================================
# BLOCO 2: AUTOMAÇÃO DE INFRAESTRUTURA VM
# ========================================
Write-Host "[INFRA-AUTO] Configurando SO da VM..." -ForegroundColor Yellow

# 2.1 SSH Key Setup (Garante Zero-Touch)
Write-Host "    [2.1] Validando acesso sem senha..." -ForegroundColor Gray
$sshTest = ssh -o ConnectTimeout=5 -o BatchMode=yes "$VM_USER@$VM_IP" "echo OK" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "    ⚠️  Configurando Chave SSH pública..." -ForegroundColor Yellow
    $keyPath = "$env:USERPROFILE\.ssh\id_ed25519.pub"
    if (-not (Test-Path $keyPath)) { Write-Error "Gere a chave: ssh-keygen -t ed25519"; exit 1 }
    Get-Content $keyPath -Raw | ssh "$VM_USER@$VM_IP" "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
}

# 2.2 Netplan (IP Estático Automático)
Write-Host "    [2.2] Aplicando IP Estático via Netplan..." -ForegroundColor Gray
$netplanConfig = @"
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses: [$VM_IP/22]
      routes: [{to: default, via: xxx.xxx.xxx.xxx}]
      nameservers: {addresses: [8.8.8.8, 1.1.1.1]}
"@
$netplanConfig | ssh "$VM_USER@$VM_IP" "sudo tee /etc/netplan/50-cloud-init.yaml > /dev/null && sudo netplan apply"

# 2.3 Hardening de Sudoers (Whitelist de Segurança)
Write-Host "    [2.3] Aplicando Whitelist de Sudoers..." -ForegroundColor Gray
$sudoersRule = "${VM_USER} ALL=(ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/chown, /usr/bin/docker, /usr/bin/du, /usr/bin/rm, /usr/bin/whoami, /usr/sbin/netplan, /usr/bin/tee"
ssh "$VM_USER@$VM_IP" "echo '$sudoersRule' | sudo tee /etc/sudoers.d/${VM_USER} > /dev/null && sudo chmod 440 /etc/sudoers.d/${VM_USER}"

# ========================================
# BLOCO 3/4: PREPARAÇÃO IaC
# ========================================
Write-Host "`n[STEP 1/2] Limpando volumes e criando diretórios..." -ForegroundColor Yellow
ssh "$VM_USER@$VM_IP" "sudo rm -rf $BASE_DIR && sudo mkdir -p $BASE_DIR/data/postgres $BASE_DIR/data/midpoint/var $BASE_DIR/logs/midpoint $EVIDENCE_DIR && sudo chown -R ${VM_USER}:${VM_USER} $BASE_DIR"

Write-Host "[STEP 3/4] Injetando Docker Compose (Fix Auth SCRAM)..." -ForegroundColor Yellow
$yaml = @"
services:
  postgres:
    image: postgres:16-alpine
    container_name: postgres
    environment:
      POSTGRES_DB: midpoint
      POSTGRES_USER: midpoint
      POSTGRES_PASSWORD: '${POSTGRES_PASSWORD}'
    volumes:
      - $BASE_DIR/data/postgres:/var/lib/postgresql/data
    networks: [iga-network]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U midpoint"]
      interval: 10s
    restart: unless-stopped

  midpoint:
    image: evolveum/midpoint:4.8
    container_name: midpoint
    ports: ["8080:8080"]
    environment:
      REPO_DATABASE_TYPE: postgresql
      REPO_HOST: postgres
      REPO_USER: midpoint
      REPO_PASSWORD: '${POSTGRES_PASSWORD}'
      MP_SET_midpoint.repository.jdbcUrl: jdbc:postgresql://postgres:5432/midpoint
      MP_SET_midpoint.repository.jdbcUsername: midpoint
      MP_SET_midpoint.repository.jdbcPassword: '${POSTGRES_PASSWORD}'
      MP_SET_midpoint.administrator.initialPassword: '${MIDPOINT_ADMIN_PASSWORD}'
    volumes:
      - $BASE_DIR/data/midpoint/var:/opt/midpoint/var
      - $BASE_DIR/logs/midpoint:/opt/midpoint/var/log
    depends_on:
      postgres: { condition: service_healthy }
    networks: [iga-network]
    restart: unless-stopped

networks:
  iga-network: { driver: bridge }
"@
$yaml | ssh "$VM_USER@$VM_IP" "cat > $BASE_DIR/docker-compose.yml"

# ========================================
# BLOCO 5: GO-LIVE
# ========================================
Write-Host "[STEP 5/6] Inicializando containers..." -ForegroundColor Yellow
ssh "$VM_USER@$VM_IP" "cd $BASE_DIR && docker compose up -d" | Out-Null

# Validação de Saúde do Banco
$postgres_healthy = $false
for ($i=1; $i -le 20; $i++) {
    $status = ssh "$VM_USER@$VM_IP" "docker inspect postgres --format='{{.State.Health.Status}}'" 2>&1
    if (($status | Out-String).Trim() -eq "healthy") { $postgres_healthy = $true; break }
    Write-Host "    Aguardando DB... ($i/20)" -ForegroundColor Gray
    Start-Sleep -Seconds 3
}

if ($postgres_healthy) {
    Write-Host "`n✅ GMUD-008 v1.7 EXECUTADA COM SUCESSO" -ForegroundColor Green
    Write-Host "URL: http://${VM_IP}:8080/midpoint" -ForegroundColor White
    Write-Host "`nMonitorando bootstrap (Java Startup)...`n" -ForegroundColor Yellow
    ssh "$VM_USER@$VM_IP" "docker logs -f midpoint"
} else {
    Write-Error "FALHA: PostgreSQL não estabilizou."
    ssh "$VM_USER@$VM_IP" "docker logs postgres"
}
