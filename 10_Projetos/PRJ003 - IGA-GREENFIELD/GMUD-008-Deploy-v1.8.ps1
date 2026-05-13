# ====================================================================
# GMUD-008 v1.8 - Deploy Automatizado IaC (Extreme Hardening)
# Projeto: PRJ003 - IGA Greenfield Reference Architecture
# Foco: Automação Total (Netplan + Sudoers + Fix SCRAM Auth)
# Executor: Paulo Feitosa | Data: 19/01/2026
# ====================================================================

# 1. Carregamento e Validação do Baseline (Correção de Caminho)
$CurrentPath = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$envPath = Join-Path $CurrentPath ".env"

if (-not (Test-Path $envPath)) { 
    Write-Error "❌ CRÍTICO: Arquivo .env não encontrado em $envPath"
    exit 1 
}

Get-Content $envPath | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
    $name, $value = $_.Split('=', 2)
    Set-Variable -Name $name.Trim() -Value $value.Trim() -Scope Global
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "GMUD-008 v1.8 - EXECUTANDO DEPLOY TOTAL" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Validação de Segurança (Anti-Erro SCRAM)
if ([string]::IsNullOrWhiteSpace($POSTGRES_PASSWORD) -or [string]::IsNullOrWhiteSpace($VM_IP)) {
    Write-Error "❌ FALHA: Variáveis críticas vazias no .env. Verifique o arquivo."
    exit 1
}

$BASE_DIR = "/srv/prj003"
$EVIDENCE_DIR = "$BASE_DIR/evidencias"

# ========================================
# BLOCO 2: BOOTSTRAP DE INFRAESTRUTURA
# ========================================
Write-Host "[INFRA] Configurando SO da VM (Rede e Privilégios)..." -ForegroundColor Yellow

# 2.1 Sudoers Whitelist (Bootstrap de Confiança)
Write-Host "    [2.1] Configurando Sudoers NOPASSWD (Requer senha uma vez)..." -ForegroundColor Gray
$sudoersRule = "${VM_USER} ALL=(ALL) NOPASSWD: ALL"
ssh -t "$VM_USER@$VM_IP" "echo '$sudoersRule' | sudo tee /etc/sudoers.d/${VM_USER} > /dev/null && sudo chmod 440 /etc/sudoers.d/${VM_USER}"

# 2.2 Netplan Automático
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

# ========================================
# BLOCO 3: PREPARAÇÃO IAC (ESTADO ZERO)
# ========================================
Write-Host "`n[IAC] Limpando volumes e preparando diretórios..." -ForegroundColor Yellow
ssh "$VM_USER@$VM_IP" "sudo rm -rf $BASE_DIR && sudo mkdir -p $BASE_DIR/data/postgres $BASE_DIR/data/midpoint/var $BASE_DIR/logs/midpoint $EVIDENCE_DIR && sudo chown -R ${VM_USER}:${VM_USER} $BASE_DIR"

# ========================================
# BLOCO 4: INJEÇÃO DO DOCKER COMPOSE
# ========================================
Write-Host "[IAC] Injetando Docker Compose com aspas de segurança..." -ForegroundColor Yellow

$yamlContent = @"
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
    networks:
      - iga-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U midpoint"]
      interval: 10s
    restart: unless-stopped

  midpoint:
    image: evolveum/midpoint:4.8
    container_name: midpoint
    ports:
      - "8080:8080"
    environment:
      REPO_DATABASE_TYPE: postgresql
      REPO_HOST: postgres
      REPO_DATABASE: midpoint
      REPO_USER: midpoint
      REPO_PASSWORD: '${POSTGRES_PASSWORD}'
      MP_SET_midpoint.repository.jdbcUrl: jdbc:postgresql://postgres:5432/midpoint
      MP_SET_midpoint.repository.jdbcUsername: midpoint
      MP_SET_midpoint.repository.jdbcPassword: '${POSTGRES_PASSWORD}'
      MP_SET_midpoint.administrator.initialPassword: '${MIDPOINT_ADMIN_PASSWORD}'
    volumes:
      - $BASE_DIR/data/midpoint/var:/opt/midpoint/var
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - iga-network
    restart: unless-stopped

networks:
  iga-network:
    driver: bridge
"@

$yamlContent | ssh "$VM_USER@$VM_IP" "cat > $BASE_DIR/docker-compose.yml"
Write-Host "    ✅ Docker-compose injetado com aspas de segurança" -ForegroundColor Green

# ========================================
# BLOCO 5: GO-LIVE
# ========================================
Write-Host "[DEPLOY] Subindo containers..." -ForegroundColor Yellow
ssh "$VM_USER@$VM_IP" "cd $BASE_DIR && docker compose up -d" | Out-Null

Write-Host "`n✅ GMUD-008 v1.8 EXECUTADA COM SUCESSO" -ForegroundColor Green
Write-Host "Acesse: http://${VM_IP}:8080/midpoint" -ForegroundColor White
Write-Host "`nMonitorando bootstrap (Aguarde o 'Deployment finished')...`n" -ForegroundColor Yellow
ssh "$VM_USER@$VM_IP" "docker logs -f midpoint"
