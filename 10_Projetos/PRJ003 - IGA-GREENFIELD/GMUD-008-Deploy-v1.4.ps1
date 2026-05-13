# ====================================================================
# GMUD-008 v1.4 - Deploy Automatizado IaC (Arquitetura de Confiança)
# Projeto: PRJ003 - IGA Greenfield Reference Architecture
# Versão: 1.4 | Foco: Correção de Autenticação SCRAM & Persistência
# Executor: Paulo Feitosa
# ====================================================================

# 1. Carregamento e Sanitização de Credenciais
if (-not (Test-Path ".env")) { Write-Error "FALHA: Arquivo .env local não encontrado."; exit 1 }
Get-Content ".env" | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
    $name, $value = $_.Split('=', 2)
    Set-Variable -Name $name.Trim() -Value $value.Trim() -Scope Script
}

$BASE_DIR = "/srv/prj003"
$EVIDENCE_DIR = "$BASE_DIR/evidencias"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "GMUD-008 v1.4 - Deploy Automatizado IaC" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# STEP 1: PRE-FLIGHT CHECKLIST
Write-Host "[STEP 1] Executando Pre-Flight Checklist..." -ForegroundColor Yellow

# 1.1 Identidade e Sudo
$sudo_test = ssh -o ConnectTimeout=5 "$VM_USER@$VM_IP" "sudo -n whoami" 2>&1
if (($sudo_test | Out-String).Trim() -ne "root") {
    Write-Error "FALHA: Hardening do Sudoers ou SSH Key não detectado."; exit 1
}
Write-Host "    ✅ SSH & Sudo OK" -ForegroundColor Green

# 1.2 Limpeza Preventiva (Garantia de Estado Zero)
Write-Host "    🧹 Aplicando limpeza preventiva de containers/volumes..." -ForegroundColor Gray
ssh "$VM_USER@$VM_IP" "cd $BASE_DIR 2>/dev/null && docker compose down -v 2>/dev/null; sudo rm -rf $BASE_DIR/data/postgres/*" | Out-Null
Write-Host "    ✅ Ambiente preparado" -ForegroundColor Green

# STEP 2: INFRAESTRUTURA DE DIRETÓRIOS
Write-Host "[STEP 2] Criando estrutura de diretórios..." -ForegroundColor Yellow
ssh "$VM_USER@$VM_IP" "sudo mkdir -p $BASE_DIR/data/postgres $BASE_DIR/data/midpoint/var $BASE_DIR/logs/midpoint $EVIDENCE_DIR && sudo chown -R ${VM_USER}:${VM_USER} $BASE_DIR"
Write-Host "    ✅ Diretórios criados" -ForegroundColor Green

# STEP 3 & 4: INJEÇÃO DE CONFIGURAÇÃO (Método de Expansão Segura)
Write-Host "[STEP 3/4] Gerando docker-compose.yml com credenciais..." -ForegroundColor Yellow

$yaml = @"
services:
  postgres:
    image: postgres:16-alpine
    container_name: postgres
    environment:
      POSTGRES_DB: midpoint
      POSTGRES_USER: midpoint
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - $BASE_DIR/data/postgres:/var/lib/postgresql/data
    networks: [iga-network]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U midpoint"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  midpoint:
    image: evolveum/midpoint:4.8
    container_name: midpoint
    ports: ["8080:8080"]
    environment:
      REPO_DATABASE_TYPE: postgresql
      REPO_HOST: postgres
      REPO_DATABASE: midpoint
      REPO_USER: midpoint
      REPO_PASSWORD: ${POSTGRES_PASSWORD}
      MP_SET_midpoint.repository.jdbcUrl: jdbc:postgresql://postgres:5432/midpoint
      MP_SET_midpoint.repository.jdbcUsername: midpoint
      MP_SET_midpoint.repository.jdbcPassword: ${POSTGRES_PASSWORD}
      MP_SET_midpoint.administrator.initialPassword: ${MIDPOINT_ADMIN_PASSWORD}
    volumes:
      - $BASE_DIR/data/midpoint/var:/opt/midpoint/var
    depends_on:
      postgres: { condition: service_healthy }
    networks: [iga-network]
    restart: unless-stopped

networks:
  iga-network: { driver: bridge }
"@

$yaml | ssh "$VM_USER@$VM_IP" "cat > $BASE_DIR/docker-compose.yml"
Write-Host "    ✅ Docker-compose injetado e validado" -ForegroundColor Green

# STEP 5 & 6: DEPLOY E MONITORAMENTO
Write-Host "[STEP 5/6] Inicializando containers..." -ForegroundColor Yellow
ssh "$VM_USER@$VM_IP" "cd $BASE_DIR && docker compose up -d" | Out-Null

$postgres_healthy = $false
for ($i=1; $i -le 30; $i++) {
    $status = ssh "$VM_USER@$VM_IP" "docker inspect postgres --format='{{.State.Health.Status}}'" 2>&1
    if (($status | Out-String).Trim() -eq "healthy") { $postgres_healthy = $true; break }
    Write-Host "    Aguardando PostgreSQL... Tentativa $i/30 (Status: $status)" -ForegroundColor Gray
    Start-Sleep -Seconds 3
}

if ($postgres_healthy) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "GMUD-008 v1.4 EXECUTADA COM SUCESSO" -ForegroundColor Green
    Write-Host "URL: http://${VM_IP}:8080/midpoint" -ForegroundColor White
    Write-Host "========================================`n" -ForegroundColor Cyan
    Write-Host "Monitorando bootstrap (Java Startup)..." -ForegroundColor Yellow
    ssh "$VM_USER@$VM_IP" "docker logs -f midpoint"
} else {
    Write-Error "FALHA: PostgreSQL não atingiu estado saudável."
}