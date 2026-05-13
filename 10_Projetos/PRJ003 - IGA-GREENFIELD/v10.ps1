$VM_IP = "xxx.xxx.xxx.xxx"
$USER = "paulo"
$PRJ_PATH = "/srv/iga-project"

Write-Host "🚀 PRJ003 - Tentativa #10 | Iniciando Deploy..." -ForegroundColor Cyan

# 1. Reset e Limpeza
ssh ${USER}@${VM_IP} "sudo docker compose -f $PRJ_PATH/docker-compose.yml down -v; sudo rm -rf $PRJ_PATH/data/*"

# 2. Upload do Compose
scp .\docker-compose.yml ${USER}@${VM_IP}:${PRJ_PATH}/

# 3. Subir Banco
ssh ${USER}@${VM_IP} "cd $PRJ_PATH; sudo docker compose up -d postgres"
Write-Host "⏳ Aguardando banco (15s)..."
Start-Sleep -Seconds 15

# 4. Injeção SQL (O ponto onde todas falharam)
Write-Host "💉 Injetando Schemas no PostgreSQL..." -ForegroundColor Magenta
Get-Content ".\postgres.sql", ".\postgres-audit.sql", ".\postgres-quartz.sql" -Raw | ssh ${USER}@${VM_IP} "sudo docker exec -i iga-postgres psql -U midpoint_user -d midpoint"

# 5. Subir midPoint
Write-Host "🚀 Subindo Aplicação..." -ForegroundColor Green
ssh ${USER}@${VM_IP} "cd $PRJ_PATH; sudo docker compose up -d midpoint"
ssh ${USER}@${VM_IP} "sudo docker logs -f iga-midpoint"
