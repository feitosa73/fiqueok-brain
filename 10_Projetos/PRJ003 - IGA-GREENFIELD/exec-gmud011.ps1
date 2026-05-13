$VM_IP = "xxx.xxx.xxx.xxx"
$USER = "paulo"
$PRJ_PATH = "/srv/iga-project"

Write-Host "--- GMUD-011 | INICIANDO PROTOCOLO DE CONTROLE MANUAL ---" -ForegroundColor Cyan

# A. Limpeza de rastro (Garante Keystore novo e sem conflitos)
Write-Host "Limpando volumes na VM..."
ssh ${USER}@${VM_IP} "sudo docker compose -f $PRJ_PATH/docker-compose.yml down -v; sudo rm -rf $PRJ_PATH/data/*"

# B. Envio da configuracao
Write-Host "Enviando docker-compose..."
scp .\docker-compose.yml ${USER}@${VM_IP}:${PRJ_PATH}/

# C. Provisionamento de Banco
Write-Host "Iniciando PostgreSQL 16..."
ssh ${USER}@${VM_IP} "cd $PRJ_PATH; sudo docker compose up -d postgres"
Start-Sleep -Seconds 20

# D. Injeção de Schema (Soberania de Dados)
# Certifique-se de que os arquivos .sql estao na pasta atual no Windows
Write-Host "Injetando tabelas nativas via Host..." -ForegroundColor Magenta
$sqlFiles = Get-Content ".\postgres.sql", ".\postgres-audit.sql", ".\postgres-quartz.sql" -Raw
$sqlFiles | ssh ${USER}@${VM_IP} "sudo docker exec -i iga-postgres psql -U midpoint_user -d midpoint"

# E. Verificação de Integridade (Checklist GRC)
Write-Host "Validando populacao do banco..."
ssh ${USER}@${VM_IP} "sudo docker exec iga-postgres psql -U midpoint_user -d midpoint -c 'SELECT count(*) FROM information_schema.tables WHERE table_schema = ''public'';'"

# F. Boot da Aplicacao
Write-Host "Iniciando midPoint 4.9..." -ForegroundColor Green
ssh ${USER}@${VM_IP} "cd $PRJ_PATH; sudo docker compose up -d midpoint"

# G. Monitoramento
Write-Host "Analise de logs (Aguarde a logo ASCII)..."
ssh ${USER}@${VM_IP} "sudo docker logs -f iga-midpoint"
