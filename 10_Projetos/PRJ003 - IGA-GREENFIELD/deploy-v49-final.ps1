$VM_IP = "xxx.xxx.xxx.xxx"
$USER = "paulo"
$PRJ_PATH = "/srv/iga-project"

Write-Host "--- GMUD-011 | INSTALACAO MANUAL MIDPOINT 4.9 ---"

# A. Limpeza total de rastro (Fundamental para o Keystore)
Write-Host "Limpando volumes..."
ssh ${USER}@${VM_IP} "sudo docker compose -f $PRJ_PATH/docker-compose.yml down -v; sudo rm -rf $PRJ_PATH/data/*"

# B. Upload do Compose
scp .\docker-compose.yml ${USER}@${VM_IP}:${PRJ_PATH}/

# C. Provisionamento de Banco
Write-Host "Subindo PostgreSQL 16..."
ssh ${USER}@${VM_IP} "cd $PRJ_PATH; sudo docker compose up -d postgres"
Start-Sleep -Seconds 20

# D. Injecao de Schema (O 'Cerebro' da operacao)
Write-Host "Injetando tabelas nativas..."
Get-Content ".\postgres.sql", ".\postgres-audit.sql", ".\postgres-quartz.sql" -Raw | ssh ${USER}@${VM_IP} "sudo docker exec -i iga-postgres psql -U midpoint_user -d midpoint"

# E. Boot da Aplicacao
Write-Host "Iniciando midPoint 4.9..."
ssh ${USER}@${VM_IP} "cd $PRJ_PATH; sudo docker compose up -d midpoint"

# F. Logs
Write-Host "Monitorando inicializacao..."
ssh ${USER}@${VM_IP} "sudo docker logs -f iga-midpoint"
