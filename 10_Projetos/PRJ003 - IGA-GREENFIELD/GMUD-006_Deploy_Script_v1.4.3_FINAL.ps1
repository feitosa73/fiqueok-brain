# ==============================================================================
# GMUD-006 — SCRIPT DE DEPLOY COM ORQUESTRAÇÃO DE BOOTSTRAP (v1.4.3)
# ==============================================================================
# Projeto: PRJ003 - IGA Greenfield
# Versão: 1.4.3 (Correção de Parser e Sintaxe de Gate)
# ==============================================================================

# [BANNER DE IDENTIFICAÇÃO OMITIDO PARA BREVIDADE]

# 1. CARREGAR VARIÁVEIS DO ARQUIVO .env
if (-not (Test-Path ".env")) {
    Write-Error "ERRO: Arquivo .env não encontrado."
    exit 1
}

Get-Content .env | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
    $name, $value = $_.Split('=', 2)
    Set-Variable -Name $name.Trim() -Value $value.Trim() -Force
}

# 2. DEFINIÇÕES
$VM_USER = "paulo"
$VM_IP   = "xxx.xxx.xxx.xxx"
$BASE    = "/srv/prj003"

# 3. PRE-FLIGHT (SSH TEST)
Write-Host "`n[STEP 2] Testando SSH em $VM_IP..." -ForegroundColor Yellow
$sshTest = ssh -o ConnectTimeout=5 $VM_USER@$VM_IP "echo 'OK'" 2>$null
if ($sshTest -ne "OK") {
    Write-Error "Falha na conexão SSH."
    exit 1
}

# 4. LIMPEZA NA VM
Write-Host "`n[STEP 3] Limpando volumes na VM..." -ForegroundColor Yellow
ssh $VM_USER@$VM_IP "sudo rm -rf $BASE/data/postgres/* $BASE/data/midpoint/var/* && sudo mkdir -p $BASE/data/postgres $BASE/data/midpoint/var && sudo chown -R ${VM_USER}:${VM_USER} $BASE"

# 5. GERAÇÃO DO DOCKER-COMPOSE (COM ESCAPES CORRETOS)
Write-Host "`n[STEP 4] Gerando docker-compose.yml..." -ForegroundColor Yellow

$composeContent = @"
services:
  postgres:
    image: postgres:16-alpine
    container_name: postgres
    environment:
      POSTGRES_DB: midpoint
      POSTGRES_USER: midpoint
      POSTGRES_PASSWORD: $POSTGRES_PASSWORD
    volumes:
      - $BASE/data/postgres:/var/lib/postgresql/data
    networks:
      - iga-network
    restart: unless-stopped

  midpoint:
    image: evolveum/midpoint:4.8
    container_name: midpoint
    ports:
      - "8080:8080"
    environment:
      MIDPOINT_REPOSITORY_DATABASE_URL: jdbc:postgresql://postgres:5432/midpoint
      MIDPOINT_REPOSITORY_DATABASE_USERNAME: midpoint
      MIDPOINT_REPOSITORY_DATABASE_PASSWORD: $MIDPOINT_REPOSITORY_DATABASE_PASSWORD
      MP_SET_midpoint_administrator_initialPassword: $MP_SET_midpoint_administrator_initialPassword
    volumes:
      - $BASE/data/midpoint/var:/opt/midpoint/var
      - $BASE/logs/midpoint:/opt/midpoint/var/log
    depends_on:
      - postgres
    networks:
      - iga-network
    restart: unless-stopped

networks:
  iga-network:
    driver: bridge
"@

$composeContent | ssh $VM_USER@$VM_IP "cat > ~/docker-compose.yml"

# 6. FASE 1: POSTGRES
ssh $VM_USER@$VM_IP "docker compose up -d postgres"

# 7. GATE DE ESTABILIZAÇÃO (LÓGICA CORRIGIDA)
Write-Host "`n[GATE] Aguardando PostgreSQL ficar pronto..." -ForegroundColor Cyan
$gateSuccess = $false

for ($i = 1; $i -le 10; $i++) {
    Write-Host "  [Tentativa $i/10] Verificando logs..." -ForegroundColor Gray
    $logs = ssh $VM_USER@$VM_IP "docker logs postgres 2>&1"

    if ($logs -match "database system is ready to accept connections") {
        Write-Host "✅ PostgreSQL pronto!" -ForegroundColor Green
        Start-Sleep -Seconds 10
        $gateSuccess = $true
        break
    }
    Start-Sleep -Seconds 10
}

if (-not $gateSuccess) {
    Write-Error "Timeout no banco de dados."
    exit 1
}

# 8. FASE 2: MIDPOINT
ssh $VM_USER@$VM_IP "docker compose up -d midpoint"

# 9. MONITORAMENTO
Write-Host "`n[SUCESSO] Deploy iniciado. Acompanhando logs..." -ForegroundColor Green
ssh $VM_USER@$VM_IP "docker logs -f midpoint"
