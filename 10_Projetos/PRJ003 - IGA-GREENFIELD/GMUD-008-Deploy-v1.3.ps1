# ====================================================================
# GMUD-008 v1.3 - Deploy Automatizado IaC (Edição Auditoria)
# Projeto: PRJ003 - IGA Greenfield Reference Architecture
# Versão: 1.3 | Executor: Paulo Feitosa
# ====================================================================

# 1. Carregamento Sanitizado (Fim do \r)
if (-not (Test-Path ".env")) { Write-Error "FALHA: .env não encontrado."; exit 1 }
Get-Content ".env" | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
    $name, $value = $_.Split('=', 2)
    Set-Variable -Name $name.Trim() -Value $value.Trim() -Scope Script
}

$BASE_DIR = "/srv/prj003"
$EVIDENCE_DIR = "$BASE_DIR/evidencias"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "GMUD-008 v1.3 - Deploy Automatizado IaC" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# STEP 1: PRE-FLIGHT CHECKLIST
Write-Host "[STEP 1] Executando Pre-Flight Checklist..." -ForegroundColor Yellow

# 1.1 SSH & Sudo Check (whoami)
$sudo_test = ssh -o ConnectTimeout=5 "$VM_USER@$VM_IP" "sudo -n whoami" 2>&1
if (($sudo_test | Out-String).Trim() -ne "root") {
    Write-Error "FALHA: Sudoers não configurado corretamente."; exit 1
}
Write-Host "    ✅ SSH & Sudo OK" -ForegroundColor Green

# 1.2 Docker Hub Check (Silent Mode)
$hub_test = ssh "$VM_USER@$VM_IP" "curl -sI https://registry-1.docker.io/v2/ | head -n 1" 2>&1
if (($hub_test | Out-String) -notmatch "HTTP") {
    Write-Error "FALHA: Sem acesso ao Docker Hub."; exit 1
}
Write-Host "    ✅ Docker Hub Acessível" -ForegroundColor Green

# 1.3 Limpeza de Ambiente (Fim do Toil)
$containers = ssh "$VM_USER@$VM_IP" "docker ps -a -q" 2>&1
if (($containers | Out-String).Trim()) {
    Write-Warning "Limpando containers existentes..."
    ssh "$VM_USER@$VM_IP" "docker stop \$(docker ps -a -q) && docker rm \$(docker ps -a -q)" | Out-Null
}
Write-Host "    ✅ Ambiente Limpo" -ForegroundColor Green

# STEP 2: PREPARAÇÃO (Comando Único e Seguro)
Write-Host "[STEP 2] Preparando estrutura de diretórios..." -ForegroundColor Yellow
# CORREÇÃO DA LINHA 47: Uso de ${} para isolar a variável do caractere :
ssh "$VM_USER@$VM_IP" "sudo mkdir -p $BASE_DIR/data/postgres $BASE_DIR/data/midpoint/var $BASE_DIR/logs/midpoint $EVIDENCE_DIR && sudo chown -R ${VM_USER}:${VM_USER} $BASE_DIR"
Write-Host "    ✅ Estrutura criada com nomes limpos" -ForegroundColor Green

# STEP 3 & 4: CONFIGURAÇÃO (Método Pipe)
Write-Host "[STEP 3/4] Configurando IGA Greenfield..." -ForegroundColor Yellow
$yamlContent = @"
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
      REPO_DATABASE: midpoint
      REPO_USER: midpoint
      REPO_PASSWORD: $POSTGRES_PASSWORD
      MP_SET_midpoint.administrator.initialPassword: $MIDPOINT_ADMIN_PASSWORD
    volumes:
      - $BASE_DIR/data/midpoint/var:/opt/midpoint/var
    depends_on:
      postgres: { condition: service_healthy }
    networks: [iga-network]
    restart: unless-stopped
networks:
  iga-network: { driver: bridge }
"@
$yamlContent | ssh "$VM_USER@$VM_IP" "cat > $BASE_DIR/docker-compose.yml"
Write-Host "    ✅ Docker-compose injetado via Pipe" -ForegroundColor Green

# STEP 5 & 6: DEPLOY
Write-Host "[STEP 5/6] Subindo containers e monitorando saúde..." -ForegroundColor Yellow
ssh "$VM_USER@$VM_IP" "cd $BASE_DIR && docker compose up -d" | Out-Null

$postgres_healthy = $false
for ($i=1; $i -le 30; $i++) {
    $status = ssh "$VM_USER@$VM_IP" "docker inspect postgres --format='{{.State.Health.Status}}'" 2>&1
    if (($status | Out-String).Trim() -eq "healthy") { $postgres_healthy = $true; break }
    Write-Host "    Tentativa $i/30 - Status: $status" -ForegroundColor Gray
    Start-Sleep -Seconds 2
}

if ($postgres_healthy) {
    Write-Host "`n✅ GMUD-008 v1.3 EXECUTADA COM SUCESSO" -ForegroundColor Green
    Write-Host "Acesse: http://$VM_IP:8080/midpoint" -ForegroundColor White
} else {
    Write-Error "FALHA: PostgreSQL não estabilizou."
}