# ====================================================================
# GMUD-008 v1.3 - Deploy Automatizado IaC (Zero-Touch)
# Projeto: PRJ003 - IGA Greenfield Reference Architecture
# Versão: 1.3 (Hardening + SSH Keys + Correções de Campo)
# Data: 19/01/2026 17:30
# Executor: Paulo Feitosa
# ====================================================================

# 1. Carregamento Seguro do .env (Limpeza de CRLF)
if (-not (Test-Path ".env")) {
    Write-Error "FALHA: Arquivo .env não encontrado."
    exit 1
}
Get-Content ".env" | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
    $name, $value = $_.Split('=', 2)
    Set-Variable -Name $name.Trim() -Value $value.Trim() -Scope Script
}

$BASE_DIR = "/srv/prj003"
$EVIDENCE_DIR = "$BASE_DIR/evidencias"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "GMUD-008 v1.3 - Deploy Automatizado IaC" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# STEP 1: PRE-FLIGHT CHECKLIST (Robustecido)
Write-Host "[STEP 1] Executando Pre-Flight Checklist..." -ForegroundColor Yellow

# 1.1 SSH & Sudo (Linha única para evitar interrupção)
$sudo_test = ssh -o ConnectTimeout=5 "$VM_USER@$VM_IP" "sudo -n whoami" 2>&1
if (($sudo_test | Out-String).Trim() -ne "root") {
    Write-Error "FALHA: Acesso Sudo Passwordless não detectado ou SSH Key falhou."
    exit 1
}
Write-Host "    ✅ SSH & Sudo OK" -ForegroundColor Green

# 1.2 Validar Conectividade & DNS
$dns_test = ssh "$VM_USER@$VM_IP" "nslookup registry-1.docker.io" 2>&1
if (($dns_test | Out-String) -notmatch "Address") {
    Write-Error "FALHA: Resolução DNS na VM."
    exit 1
}
Write-Host "    ✅ Conectividade & DNS OK" -ForegroundColor Green

# STEP 2: PREPARAÇÃO DO AMBIENTE (Comando Único)
Write-Host "[STEP 2] Preparando estrutura de diretórios..." -ForegroundColor Yellow
ssh "$VM_USER@$VM_IP" "sudo mkdir -p $BASE_DIR/data/postgres $BASE_DIR/data/midpoint/var $BASE_DIR/logs/midpoint $EVIDENCE_DIR && sudo chown -R $VM_USER:$VM_USER $BASE_DIR"
Write-Host "    ✅ Estrutura criada com nomes limpos" -ForegroundColor Green

# STEP 3: ARQUIVO .ENV NA VM
Write-Host "[STEP 3] Criando arquivo .env na VM..." -ForegroundColor Yellow
$envContent = @"
POSTGRES_DB=midpoint
POSTGRES_USER=midpoint
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
MIDPOINT_ADMIN_USERNAME=administrator
MIDPOINT_ADMIN_PASSWORD=$MIDPOINT_ADMIN_PASSWORD
"@
$envContent | ssh "$VM_USER@$VM_IP" "cat > $BASE_DIR/.env && chmod 600 $BASE_DIR/.env"
Write-Host "    ✅ .env criado" -ForegroundColor Green

# STEP 4: DOCKER-COMPOSE (Método Pipe - Sem Heredoc Error)
Write-Host "[STEP 4] Criando docker-compose.yml..." -ForegroundColor Yellow
$yaml = @"
services:
  postgres:
    image: postgres:16-alpine
    container_name: postgres
    environment:
      POSTGRES_DB: midpoint
      POSTGRES_USER: midpoint
      POSTGRES_PASSWORD: $POSTGRES_PASSWORD
    volumes:
      - $BASE_DIR/data/postgres:/var/lib/postgresql/data
    networks:
      - iga-network
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
      REPO_PORT: 5432
      REPO_DATABASE: midpoint
      REPO_USER: midpoint
      REPO_PASSWORD: $POSTGRES_PASSWORD
      REPO_JDBC_URL: jdbc:postgresql://postgres:5432/midpoint
      MP_SET_midpoint.repository.jdbcUrl: jdbc:postgresql://postgres:5432/midpoint
      MP_SET_midpoint.repository.jdbcUsername: midpoint
      MP_SET_midpoint.repository.jdbcPassword: $POSTGRES_PASSWORD
      MP_SET_midpoint.repository.database: postgresql
      MP_SET_midpoint.administrator.initialPassword: $MIDPOINT_ADMIN_PASSWORD
    volumes:
      - $BASE_DIR/data/midpoint/var:/opt/midpoint/var
      - $BASE_DIR/logs/midpoint:/opt/midpoint/var/log
    depends_on:
      postgres: { condition: service_healthy }
    networks:
      - iga-network
    restart: unless-stopped

networks:
  iga-network: { driver: bridge }
"@
$yaml | ssh "$VM_USER@$VM_IP" "cat > $BASE_DIR/docker-compose.yml"
$compose_check = ssh "$VM_USER@$VM_IP" "cd $BASE_DIR && docker compose config" 2>&1
if ($LASTEXITCODE -ne 0) { Write-Error "FALHA: Sintaxe YAML."; exit 1 }
Write-Host "    ✅ Docker-compose validado" -ForegroundColor Green

# STEP 5 & 6: DEPLOY & HEALTHCHECK
Write-Host "[STEP 5/6] Subindo containers e validando PostgreSQL..." -ForegroundColor Yellow
ssh "$VM_USER@$VM_IP" "cd $BASE_DIR && docker compose up -d" | Out-Null

$postgres_healthy = $false
for ($i=1; $i -le 30; $i++) {
    $status = ssh "$VM_USER@$VM_IP" "docker inspect postgres --format='{{.State.Health.Status}}'" 2>&1
    if (($status | Out-String).Trim() -eq "healthy") { $postgres_healthy = $true; break }
    Write-Host "    Tentativa $i/30 - Status: $status" -ForegroundColor Gray
    Start-Sleep -Seconds 2
}

if ($postgres_healthy) {
    Write-Host "    ✅ PostgreSQL Saudável. Iniciando bootstrap do midPoint (180s)..." -ForegroundColor Green
    Start-Sleep -Seconds 180
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "GMUD-008 v1.3 EXECUTADA COM SUCESSO" -ForegroundColor Green
    Write-Host "Acesse: http://$VM_IP:8080/midpoint" -ForegroundColor White
    Write-Host "========================================`n" -ForegroundColor Cyan
} else {
    Write-Error "FALHA: PostgreSQL não estabilizou."
}