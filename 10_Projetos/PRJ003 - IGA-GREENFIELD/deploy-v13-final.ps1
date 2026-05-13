# ============================================================================
# GMUD-013 | Encerramento PRJ003 - Clean Slate & Sanitization (FIXED)
# Projeto: PRJ003 - IGA Greenfield Reference Architecture
# Executor: Paulo Feitosa
# ============================================================================

$ErrorActionPreference = "Stop"

# --- CONFIGURACAO ---
$VM_IP = "xxx.xxx.xxx.xxx"
$USER = "paulo"
$PRJ_PATH = "/srv/iga-project"

Write-Host "--- PRJ003 | GMUD-013 | INICIANDO TESTE DE REPETIBILIDADE ---" -ForegroundColor Cyan

# 1. Limpeza Nuclear (Garante que o teste comece do zero absoluto)
Write-Host "[1/6] Limpando volumes e estados anteriores na VM..." -ForegroundColor Yellow
ssh ${USER}@${VM_IP} "sudo docker compose -f $PRJ_PATH/docker-compose.yml down -v 2>/dev/null || true"
ssh ${USER}@${VM_IP} "sudo rm -rf $PRJ_PATH/data/* $PRJ_PATH/config/*"

# 2. Upload da Orquestracao Sanitizada
Write-Host "[2/6] Enviando docker-compose.yml e .env para a VM..." -ForegroundColor Yellow
scp .\docker-compose.yml ${USER}@${VM_IP}:${PRJ_PATH}/
scp .\.env ${USER}@${VM_IP}:${PRJ_PATH}/
Write-Host "✅ Arquivos de configuracao transferidos." -ForegroundColor Green

# 3. Provisionamento do Banco de Dados
Write-Host "[3/6] Iniciando PostgreSQL 16 (Sanitizado)..." -ForegroundColor Yellow
ssh ${USER}@${VM_IP} "cd $PRJ_PATH && sudo docker compose up -d postgres"
Write-Host "    Aguardando estabilizacao do banco (20s)..."
Start-Sleep -Seconds 20

# 4. Injecao de Schema (Baseline v51 para midPoint 4.10)
Write-Host "[4/6] Injetando Schema Nativo 4.10 via Host..." -ForegroundColor Magenta
$sqlFiles = Get-Content ".\postgres.sql", ".\postgres-audit.sql", ".\postgres-quartz.sql" -Raw
$sqlFiles | ssh ${USER}@${VM_IP} "sudo docker exec -i iga-postgres psql -U midpoint_user -d midpoint"
Write-Host "    ✅ Schema v51 injetado com sucesso." -ForegroundColor Green

# 5. Lancamento da Aplicacao midPoint 4.10
Write-Host "[5/6] Lancando midPoint 4.10..." -ForegroundColor Green
ssh ${USER}@${VM_IP} "cd $PRJ_PATH && sudo docker compose up -d midpoint"

# 6. Monitoramento e Validacao
Write-Host "[6/6] Validando inicializacao... (Procure por: Database schema is compliant)" -ForegroundColor Cyan
ssh ${USER}@${VM_IP} "sudo docker logs -f iga-midpoint"
