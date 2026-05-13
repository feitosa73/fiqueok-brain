# ====================================================================
# GMUD-008 v1.5 - Deploy Automatizado IaC (Garantia de Integridade)
# Projeto: PRJ003 - IGA Greenfield Reference Architecture
# Versão: 1.5 | Foco: Validação de Variáveis e Fix de Conexão DB
# ====================================================================

# 1. Carregamento Robusto do .env
$envPath = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path $envPath)) { 
    Write-Error "CRÍTICO: Arquivo .env não encontrado em $envPath"; exit 1 
}

Get-Content $envPath | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
    $name, $value = $_.Split('=', 2)
    Set-Variable -Name $name.Trim() -Value $value.Trim() -Scope Global
}

# 2. Portão de Validação (Anti-Erro SCRAM)
Write-Host "--- Validando Baseline de Segredos ---" -ForegroundColor Cyan
if ([string]::IsNullOrWhiteSpace($POSTGRES_PASSWORD) -or [string]::IsNullOrWhiteSpace($VM_IP)) {
    Write-Error "ERRO: Variáveis críticas ($POSTGRES_PASSWORD ou $VM_IP) estão vazias. Verifique o arquivo .env"; exit 1
}
Write-Host "✅ Variáveis carregadas para o host: $VM_IP" -ForegroundColor Green

$BASE_DIR = "/srv/prj003"
$EVIDENCE_DIR = "$BASE_DIR/evidencias"

# STEP 1: PRE-FLIGHT
Write-Host "[STEP 1] Pre-Flight Checklist..." -ForegroundColor Yellow
$sudo_test = ssh -o ConnectTimeout=5 "$VM_USER@$VM_IP" "sudo -n whoami" 2>&1
if (($sudo_test | Out-String).Trim() -ne "root") { Write-Error "FALHA: Sudoers/SSH na VM."; exit 1 }

# STEP 2: INFRAESTRUTURA
ssh "$VM_USER@$VM_IP" "sudo mkdir -p $BASE_DIR/data/postgres $BASE_DIR/data/midpoint/var $BASE_DIR/logs/midpoint $EVIDENCE_DIR && sudo chown -R ${VM_USER}:${VM_USER} $BASE_DIR"

# ====================================================================
# STEP 3/4: DOCKER COMPOSE (Versão 1.6 - Proteção de Credenciais)
# ====================================================================
Write-Host "[STEP 3/4] Gerando docker-compose.yml com expansão de variáveis..." -ForegroundColor Yellow

# O uso de '${VAR}' garante que o PowerShell injete o valor e as aspas protejam caracteres especiais no Linux
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
      REPO_PASSWORD: '${POSTGRES_PASSWORD}'
      # Configurações explícitas de repositório para evitar Fallback H2
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

# Transmissão via Pipe elimina erros de indentação (EOF)
$yaml | ssh "$VM_USER@$VM_IP" "cat > $BASE_DIR/docker-compose.yml"
Write-Host "    ✅ Docker-compose.yml injetado com aspas de segurança" -ForegroundColor Green

# STEP 5/6: DEPLOY
ssh "$VM_USER@$VM_IP" "cd $BASE_DIR && docker compose up -d" | Out-Null

Write-Host "🚀 Deploy iniciado. Monitorando logs do bootstrap..." -ForegroundColor Yellow
ssh "$VM_USER@$VM_IP" "docker logs -f midpoint"