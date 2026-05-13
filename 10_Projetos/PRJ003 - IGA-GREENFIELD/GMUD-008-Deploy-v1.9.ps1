# ====================================================================
# GMUD-008 v1.9 - Deploy Automatizado IaC (Fiqueok Final Edition)
# Projeto: PRJ003 - IGA Greenfield Reference Architecture
# Foco: Automação Zero-Touch + Fix SCRAM + Netplan Auto-Config
# ====================================================================

# 1. Carregamento Inteligente do .env (Resolve erro de colagem)
$CurrentPath = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$envPath = Join-Path $CurrentPath ".env"

if (-not (Test-Path $envPath)) { 
    Write-Error "❌ CRÍTICO: .env não encontrado em $envPath. O script precisa estar na mesma pasta do .env"; exit 1 
}

# Carregamento forçado para o escopo global
Get-Content $envPath | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
    $name, $value = $_.Split('=', 2)
    Set-Variable -Name $name.Trim() -Value $value.Trim() -Scope Global
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "GMUD-008 v1.9 - EXECUTANDO DEPLOY TOTAL" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Portão de Segurança: Validação de Variáveis
if ([string]::IsNullOrWhiteSpace($POSTGRES_PASSWORD) -or [string]::IsNullOrWhiteSpace($VM_IP)) {
    Write-Error "❌ FALHA: Variáveis não carregadas. Verifique o .env."; exit 1
}
Write-Host "✅ Credenciais validadas para: ${VM_USER}@${VM_IP}" -ForegroundColor Green

$BASE_DIR = "/srv/prj003"

# 2. Bootstrap de Acesso e Rede (Fim das senhas repetitivas)
Write-Host "[INFRA] Configurando SO da VM..." -ForegroundColor Yellow

# 2.1 SSH Key Setup
$pubKey = Join-Path $env:USERPROFILE ".ssh\id_ed25519.pub"
if (Test-Path $pubKey) {
    Write-Host "    [2.1] Autorizando Chave SSH..." -ForegroundColor Gray
    Get-Content $pubKey | ssh "${VM_USER}@${VM_IP}" "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys" 2>$null
}

# 2.2 Netplan Automático (IP Fixo .116)
Write-Host "    [2.2] Aplicando Netplan (IP Estático)..." -ForegroundColor Gray
$netplan = @"
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses: [${VM_IP}/22]
      routes: [{to: default, via: xxx.xxx.xxx.xxx}]
      nameservers: {addresses: [8.8.8.8, 1.1.1.1]}
"@
$netplan | ssh "${VM_USER}@${VM_IP}" "sudo tee /etc/netplan/50-cloud-init.yaml > /dev/null && sudo netplan apply"

# 3. Preparação IaC (Estado Zero Absoluto)
Write-Host "[IAC] Limpando ambiente e criando volumes..." -ForegroundColor Yellow
ssh "${VM_USER}@${VM_IP}" "sudo rm -rf $BASE_DIR && sudo mkdir -p $BASE_DIR/data/postgres $BASE_DIR/data/midpoint/var $BASE_DIR/logs/midpoint && sudo chown -R ${VM_USER}:${VM_USER} $BASE_DIR"

# 4. Injeção do Docker Compose (O Fim do Erro SCRAM)
Write-Host "[IAC] Injetando Docker Compose com aspas de proteção..." -ForegroundColor Yellow

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
      - /srv/prj003/data/postgres:/var/lib/postgresql/data
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
      REPO_PORT: 5432
      REPO_DATABASE: midpoint
      REPO_USER: midpoint
      REPO_PASSWORD: '${POSTGRES_PASSWORD}'
      MP_SET_midpoint.repository.jdbcUrl: jdbc:postgresql://postgres:5432/midpoint
      MP_SET_midpoint.repository.jdbcUsername: midpoint
      MP_SET_midpoint.repository.jdbcPassword: '${POSTGRES_PASSWORD}'
      MP_SET_midpoint.administrator.initialPassword: '${MIDPOINT_ADMIN_PASSWORD}'
    volumes:
      - /srv/prj003/data/midpoint/var:/opt/midpoint/var
    depends_on:
      postgres: { condition: service_healthy }
    networks: [iga-network]
    restart: unless-stopped

networks:
  iga-network: { driver: bridge }
"@

$yaml | ssh "${VM_USER}@${VM_IP}" "cat > $BASE_DIR/docker-compose.yml"
Write-Host "    ✅ Docker-compose injetado com sucesso" -ForegroundColor Green

# 5. Go-Live e Monitoramento
Write-Host "[DEPLOY] Subindo containers e abrindo logs..." -ForegroundColor Yellow
ssh "${VM_USER}@${VM_IP}" "cd $BASE_DIR && docker compose up -d" | Out-Null

Write-Host "`n✅ GMUD-008 v1.9 EXECUTADA COM SUCESSO" -ForegroundColor Green
Write-Host "URL: http://${VM_IP}:8080/midpoint" -ForegroundColor White
Write-Host "Aguarde o bootstrap completo nos logs abaixo...`n" -ForegroundColor Gray
ssh "${VM_USER}@${VM_IP}" "docker logs -f midpoint"
