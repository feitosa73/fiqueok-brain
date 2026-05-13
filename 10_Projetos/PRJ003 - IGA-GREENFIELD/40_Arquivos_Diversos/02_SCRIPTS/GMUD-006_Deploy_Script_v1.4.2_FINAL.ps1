# ==============================================================================
# GMUD-006 — SCRIPT DE DEPLOY COM ORQUESTRAÇÃO DE BOOTSTRAP (v1.4.2 FINAL)
# ==============================================================================
# Projeto: PRJ003 - IGA Greenfield Reference Architecture
# Data: 18/01/2026
# Responsável: Paulo Feitosa
# Descrição: Deploy do midPoint + PostgreSQL com orquestração em duas fases
#            para eliminar Race Condition identificada na GMUD-005
# Versão: 1.4.2 FINAL (IP .116 + Mapeamento de senha administrator)
# ==============================================================================

# 0. BANNER DE IDENTIFICAÇÃO
Write-Host @"
╔══════════════════════════════════════════════════════════════════════════╗
║                        GMUD-006 v1.4.2 FINAL                             ║
║           Deploy IGA com Orquestração de Bootstrap                       ║
║                   PRJ003 - IGA Greenfield                                ║
║         (IP .116 + Senha Administrator via .env)                         ║
╚══════════════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# 1. CARREGAR VARIÁVEIS DO ARQUIVO .env
# --------------------------------------
Write-Host "`n[STEP 1] Carregando variáveis de ambiente do .env..." -ForegroundColor Yellow

if (-not (Test-Path ".env")) {
    Write-Error "ERRO: Arquivo .env não encontrado no diretório atual."
    Write-Host "Certifique-se de que o arquivo .env existe e contém:" -ForegroundColor Red
    Write-Host "  POSTGRES_PASSWORD=<senha>" -ForegroundColor Gray
    Write-Host "  MIDPOINT_REPOSITORY_DATABASE_PASSWORD=<senha>" -ForegroundColor Gray
    Write-Host "  MP_SET_midpoint_administrator_initialPassword=<senha>" -ForegroundColor Gray
    exit 1
}

Get-Content .env | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
    $name, $value = $_.Split('=', 2)
    Set-Variable -Name $name.Trim() -Value $value.Trim() -Force
}

Write-Host "✅ Variáveis carregadas com sucesso" -ForegroundColor Green

# Validar variáveis críticas
if (-not $POSTGRES_PASSWORD) {
    Write-Error "❌ POSTGRES_PASSWORD não encontrado no .env"
    exit 1
}
if (-not $MIDPOINT_REPOSITORY_DATABASE_PASSWORD) {
    Write-Error "❌ MIDPOINT_REPOSITORY_DATABASE_PASSWORD não encontrado no .env"
    exit 1
}
if (-not $MP_SET_midpoint_administrator_initialPassword) {
    Write-Error "❌ MP_SET_midpoint_administrator_initialPassword não encontrado no .env"
    exit 1
}

Write-Host "✅ Todas as variáveis críticas validadas" -ForegroundColor Green

# 2. DEFINIÇÕES DE AMBIENTE
# --------------------------
$VM_USER = "paulo"
$VM_IP   = "xxx.xxx.xxx.xxx"
$BASE    = "/srv/prj003"

Write-Host "`n[INFO] Configurações de deploy:" -ForegroundColor Cyan
Write-Host "  VM: $VM_USER@$VM_IP" -ForegroundColor Gray
Write-Host "  Base: $BASE" -ForegroundColor Gray

# 3. PRE-FLIGHT CHECKLIST
# -----------------------
Write-Host "`n[STEP 2] Executando Pre-Flight Checklist..." -ForegroundColor Yellow

# 3.1. Validar conectividade SSH
Write-Host "  → Testando conectividade SSH..." -ForegroundColor Gray
$sshTest = ssh -o ConnectTimeout=5 $VM_USER@$VM_IP "echo 'OK'" 2>$null
if ($sshTest -ne "OK") {
    Write-Error "❌ Falha na conexão SSH com $VM_IP"
    Write-Host "`nVerifique:" -ForegroundColor Yellow
    Write-Host "  - IP da VM está correto: $VM_IP" -ForegroundColor Gray
    Write-Host "  - Serviço SSH está ativo na VM" -ForegroundColor Gray
    Write-Host "  - Chave SSH está configurada" -ForegroundColor Gray
    exit 1
}
Write-Host "  ✅ SSH conectado" -ForegroundColor Green

# 3.2. Validar Docker na VM
Write-Host "  → Validando Docker na VM..." -ForegroundColor Gray
$dockerVersion = ssh $VM_USER@$VM_IP "docker --version" 2>$null
if (-not $dockerVersion) {
    Write-Error "❌ Docker não encontrado na VM"
    exit 1
}
Write-Host "  ✅ $dockerVersion" -ForegroundColor Green

# 3.3. Validar Docker Compose
Write-Host "  → Validando Docker Compose..." -ForegroundColor Gray
$composeVersion = ssh $VM_USER@$VM_IP "docker compose version" 2>$null
if (-not $composeVersion) {
    Write-Error "❌ Docker Compose não encontrado na VM"
    exit 1
}
Write-Host "  ✅ $composeVersion" -ForegroundColor Green

# 3.4. Validar estado atual dos containers
Write-Host "  → Verificando estado atual do ambiente..." -ForegroundColor Gray
$runningContainers = ssh $VM_USER@$VM_IP "docker ps -q" 2>$null
if ($runningContainers) {
    Write-Warning "⚠️  Containers em execução detectados!"
    Write-Host "Containers serão parados durante a limpeza." -ForegroundColor Yellow
}

Write-Host "`n✅ Pre-Flight Checklist concluído com sucesso" -ForegroundColor Green

# 4. LIMPEZA E PREPARAÇÃO DA ESTRUTURA
# -------------------------------------
Write-Host "`n[STEP 3] Limpando e recriando estrutura de diretórios..." -ForegroundColor Yellow

# 4.1. Parar containers existentes (se houver)
Write-Host "  → Parando containers existentes..." -ForegroundColor Gray
ssh $VM_USER@$VM_IP "docker compose down 2>/dev/null || true"

# 4.2. Limpeza completa de volumes
Write-Host "  → Removendo dados residuais..." -ForegroundColor Gray
ssh $VM_USER@$VM_IP @"
sudo rm -rf $BASE/data/postgres/* && sudo rm -rf $BASE/data/midpoint/var/* && sudo rm -rf $BASE/logs/midpoint/* && sudo mkdir -p $BASE/data/postgres $BASE/data/midpoint/var $BASE/logs/midpoint $BASE/evidencias && sudo chown -R ${VM_USER}:${VM_USER} $BASE
"@

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Falha na preparação da estrutura de diretórios"
    exit 1
}

Write-Host "✅ Estrutura preparada: $BASE" -ForegroundColor Green

# 5. GERAÇÃO E ENVIO DO DOCKER-COMPOSE.YML
# -----------------------------------------
Write-Host "`n[STEP 4] Gerando e enviando docker-compose.yml..." -ForegroundColor Yellow

# CORREÇÃO CRÍTICA v1.4.2: Adicionado mapeamento de MP_SET_midpoint_administrator_initialPassword
`$compose = @"
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

`$compose | ssh $VM_USER@$VM_IP "cat > ~/docker-compose.yml"

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Falha no envio do docker-compose.yml"
    exit 1
}

Write-Host "✅ docker-compose.yml enviado para a VM" -ForegroundColor Green
Write-Host "   → Senha do administrator mapeada via variável de ambiente" -ForegroundColor Cyan

# 6. FASE 1: INICIALIZAÇÃO DO POSTGRESQL
# ---------------------------------------
Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║        FASE 1: Inicializando PostgreSQL                      ║" -ForegroundColor Yellow
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow

ssh $VM_USER@$VM_IP "docker compose up -d postgres"

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Falha ao iniciar o PostgreSQL"
    Write-Host "Execute o comando de rollback:" -ForegroundColor Red
    Write-Host "  ssh $VM_USER@$VM_IP 'docker compose down'" -ForegroundColor Gray
    exit 1
}

Write-Host "✅ Container 'postgres' iniciado" -ForegroundColor Green

# 7. GATE DE ESTABILIZAÇÃO DO POSTGRESQL
# ---------------------------------------
Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     GATE: Aguardando estabilização do PostgreSQL             ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nMonitorando logs do PostgreSQL..." -ForegroundColor Gray
Write-Host "Buscando mensagem: 'database system is ready to accept connections'`n" -ForegroundColor Gray

Start-Sleep -Seconds 5

`$gateSuccess = `$false
for (`$i = 1; `$i -le 10; `$i++) {
    Write-Host "  [Tentativa `$i/10] Verificando disponibilidade..." -ForegroundColor Gray

    `$logs = ssh $VM_USER@$VM_IP "docker logs postgres 2>&1"

    if (`$logs -match "database system is ready to accept connections") {
        Write-Host "`n✅ PostgreSQL PRONTO para aceitar conexões!" -ForegroundColor Green
        Write-Host "   → Consolidando schema (aguardando 10s adicionais)..." -ForegroundColor Gray
        Start-Sleep -Seconds 10
        Write-Host "   ✅ Consolidação concluída" -ForegroundColor Green
        `$gateSuccess = `$true
        break
    }

    if (`$i -eq 10) {
        Write-Error "`n❌ TIMEOUT: PostgreSQL não respondeu em 100 segundos"
        Write-Host "`nExecutando rollback automático..." -ForegroundColor Red
        ssh $VM_USER@$VM_IP "docker compose down"
        Write-Host "Logs do PostgreSQL:" -ForegroundColor Yellow
        ssh $VM_USER@$VM_IP "docker logs postgres 2>&1"
        exit 1
    }

    Start-Sleep -Seconds 10
}

if (-not `$gateSuccess) {
    Write-Error "Gate de estabilização falhou"
    exit 1
}

# 8. FASE 2: INICIALIZAÇÃO DO MIDPOINT
# -------------------------------------
Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║         FASE 2: Inicializando midPoint                       ║" -ForegroundColor Yellow
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow

ssh $VM_USER@$VM_IP "docker compose up -d midpoint"

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Falha ao iniciar o midPoint"
    Write-Host "Execute o comando de rollback:" -ForegroundColor Red
    Write-Host "  ssh $VM_USER@$VM_IP 'docker compose down'" -ForegroundColor Gray
    exit 1
}

Write-Host "✅ Container 'midpoint' iniciado" -ForegroundColor Green

# 9. VALIDAÇÃO DE STATUS DOS CONTAINERS
# --------------------------------------
Write-Host "`n[STEP 5] Validando status dos containers..." -ForegroundColor Yellow

Start-Sleep -Seconds 5
`$containerStatus = ssh $VM_USER@$VM_IP "docker ps --format 'table {{.Names}}	{{.Status}}'"

Write-Host "`n`$containerStatus" -ForegroundColor Gray

# 10. MONITORAMENTO DE BOOTSTRAP DO MIDPOINT
# -------------------------------------------
Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      Monitorando Bootstrap do midPoint                       ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nAguarde as seguintes mensagens nos logs:" -ForegroundColor White
Write-Host "  1️⃣  'Initial password for administrator set from environment'" -ForegroundColor Green
Write-Host "  2️⃣  'Created User:administrator'" -ForegroundColor Green
Write-Host "  3️⃣  'Server startup in XXXXX milliseconds'" -ForegroundColor Green

Write-Host "`n⚠️  Pressione Ctrl+C para interromper o acompanhamento de logs." -ForegroundColor Yellow
Write-Host "   (Os containers continuarão em execução)`n" -ForegroundColor Yellow

Start-Sleep -Seconds 3

# Monitoramento de logs em tempo real
ssh $VM_USER@$VM_IP "docker logs -f midpoint"

# 11. VALIDAÇÃO FINAL (Executado após Ctrl+C nos logs)
# -----------------------------------------------------
Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║              VALIDAÇÃO FINAL - GMUD-006                      ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n[CHECKLIST DE VALIDAÇÃO]" -ForegroundColor Cyan
Write-Host "  [ ] V01: Containers em execução (docker ps -a)" -ForegroundColor Gray
Write-Host "  [ ] V02: Log PostgreSQL - 'ready to accept connections'" -ForegroundColor Gray
Write-Host "  [ ] V03: Log midPoint - 'Initial password set from environment'" -ForegroundColor Gray
Write-Host "  [ ] V04: Log midPoint - 'Created User:administrator'" -ForegroundColor Gray
Write-Host "  [ ] V05: Log midPoint - 'Server startup'" -ForegroundColor Gray
Write-Host "  [ ] V06: Interface web acessível" -ForegroundColor Gray
Write-Host "  [ ] V07: Login bem-sucedido" -ForegroundColor Gray

Write-Host "`n[ACESSO À APLICAÇÃO]" -ForegroundColor Cyan
Write-Host "  URL: http://$VM_IP:8080/midpoint" -ForegroundColor White
Write-Host "`n  Credenciais (conforme .env):" -ForegroundColor White
Write-Host "    Usuário: administrator" -ForegroundColor Green
Write-Host "    Senha:   <conforme MP_SET_midpoint_administrator_initialPassword no .env>" -ForegroundColor Green

Write-Host "`n[COMANDOS ÚTEIS]" -ForegroundColor Cyan
Write-Host "  Verificar containers:" -ForegroundColor White
Write-Host "    ssh $VM_USER@$VM_IP 'docker ps -a'" -ForegroundColor Gray
Write-Host "`n  Visualizar logs PostgreSQL:" -ForegroundColor White
Write-Host "    ssh $VM_USER@$VM_IP 'docker logs postgres'" -ForegroundColor Gray
Write-Host "`n  Visualizar logs midPoint:" -ForegroundColor White
Write-Host "    ssh $VM_USER@$VM_IP 'docker logs midpoint'" -ForegroundColor Gray
Write-Host "`n  Buscar mensagem de senha nos logs:" -ForegroundColor White
Write-Host "    ssh $VM_USER@$VM_IP 'docker logs midpoint | grep -i password'" -ForegroundColor Gray
Write-Host "`n  Acessar shell do midPoint:" -ForegroundColor White
Write-Host "    ssh $VM_USER@$VM_IP 'docker exec -it midpoint bash'" -ForegroundColor Gray

Write-Host "`n[ROLLBACK (Se necessário)]" -ForegroundColor Yellow
Write-Host "  ssh $VM_USER@$VM_IP 'docker compose down'" -ForegroundColor Gray
Write-Host "  ssh $VM_USER@$VM_IP 'sudo rm -rf $BASE/data/*'" -ForegroundColor Gray

Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           GMUD-006 - Deploy Iniciado com Sucesso             ║" -ForegroundColor Cyan
Write-Host "║     Aguarde o bootstrap completo (~5 minutos) e valide       ║" -ForegroundColor Cyan
Write-Host "║              o acesso à interface web.                       ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nPróximo passo: Elaborar REL-GMUD-006 com evidências coletadas.`n" -ForegroundColor White

# ==============================================================================
# FIM DO SCRIPT GMUD-006 v1.4.2 FINAL
# ==============================================================================

