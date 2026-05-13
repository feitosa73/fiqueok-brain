$VM_IP = "xxx.xxx.xxx.xxx"
$USER = "paulo"
$PRJ_PATH = "/srv/iga-project"
$DB_PWD = "P0stgr3sS3cur3#2026!"

Write-Host "--- PRJ003 | GMUD-012 | EXECUCAO MIDPOINT 4.10 (HARDENED) ---" -ForegroundColor Cyan

# 1. Limpeza de Infraestrutura (Evita erro de Tampered Keystore)
Write-Host "Limpando volumes e configuracoes residuais na VM..."
ssh ${USER}@${VM_IP} "sudo docker compose -f $PRJ_PATH/docker-compose.yml down -v; sudo rm -rf $PRJ_PATH/data/* $PRJ_PATH/config/*"

# 2. Geracao do docker-compose.yml (Bypass total de logica de imagem)
$COMPOSE_CONTENT = @"
services:
  postgres:
    image: postgres:16
    container_name: iga-postgres
    environment:
      POSTGRES_DB: midpoint
      POSTGRES_USER: midpoint_user
      POSTGRES_PASSWORD: '$DB_PWD'
    volumes:
      - ./data/postgres:/var/lib/postgresql/data
    networks:
      - iga-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U midpoint_user -d midpoint"]
      interval: 5s
      timeout: 5s
      retries: 5

  midpoint:
    image: evolveum/midpoint:4.10
    container_name: iga-midpoint
    ports:
      - "8080:8080"
    environment:
      # SOBERANIA DE VARIAVEIS: Forca o Java a ignorar o fallback H2
      MP_SET_midpoint_repository_database: postgresql
      MP_SET_midpoint_repository_type: native
      MP_SET_midpoint_repository_jdbcUrl: 'jdbc:postgresql://postgres:5432/midpoint?user=midpoint_user&password=$DB_PWD'
      
      # AJUSTE DE PERFORMANCE: Condizente com 1.5GB detectados pelo Kernel
      JAVA_OPTS: "-Xms512m -Xmx1024m -Dmidpoint.repository.database=postgresql -Dfile.encoding=UTF8"
      
      MP_KEYSTORE_PASSWORD: 'midpoint_keystore_2026'
      MP_SET_midpoint_administrator_initialPassword: 'M1dP0!ntAdm!n#2026'
    volumes:
      - ./data/midpoint/var:/opt/midpoint/var
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - iga-network

networks:
  iga-network:
    driver: bridge
"@

# 3. Preparacao e Upload
[System.IO.File]::WriteAllText("$PWD\docker-compose.yml", $COMPOSE_CONTENT)
ssh ${USER}@${VM_IP} "mkdir -p $PRJ_PATH"
scp .\docker-compose.yml ${USER}@${VM_IP}:${PRJ_PATH}/

# 4. Provisionamento de Banco e Injecao de Schema (Soberania de Dados)
Write-Host "Iniciando PostgreSQL 16..."
ssh ${USER}@${VM_IP} "cd $PRJ_PATH; sudo docker compose up -d postgres"
Write-Host "Aguardando estabilizacao do banco (20s)..."
Start-Sleep -Seconds 20

Write-Host "Injetando Schema Nativo 4.10 via Host..." -ForegroundColor Magenta
# O script assume que os arquivos .sql estao na pasta local do Windows
$sqlFiles = Get-Content ".\postgres.sql", ".\postgres-audit.sql", ".\postgres-quartz.sql" -Raw
$sqlFiles | ssh ${USER}@${VM_IP} "sudo docker exec -i iga-postgres psql -U midpoint_user -d midpoint"

# 5. Boot da Aplicacao
Write-Host "Lancando midPoint 4.10..." -ForegroundColor Green
ssh ${USER}@${VM_IP} "cd $PRJ_PATH; sudo docker compose up -d midpoint"

# 6. Monitoramento de logs em tempo real
Write-Host "Monitorando inicializacao. Procure por: Started MidPointSpringApplication"
ssh ${USER}@${VM_IP} "sudo docker logs -f iga-midpoint"
