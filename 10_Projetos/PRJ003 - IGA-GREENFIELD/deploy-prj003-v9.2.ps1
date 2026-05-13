$VM_IP = "xxx.xxx.xxx.xxx"
$USER = "paulo"
$PRJ_PATH = "/srv/iga-project"

Write-Host "ðŸš€ PRJ003 - Tentativa #9.2 | Pipeline Host-to-VM" -ForegroundColor Cyan

# 1. Download Garantido (ForÃ§ando diretÃ³rio atual)
Write-Host "ðŸ“¥ Baixando schemas SQL da Evolveum..." -ForegroundColor Gray
$baseUrl = "https://raw.githubusercontent.com/Evolveum/midpoint/support-4.8/config/sql/native"
Invoke-WebRequest -Uri "$baseUrl/postgres.sql" -OutFile ".\postgres.sql"
Invoke-WebRequest -Uri "$baseUrl/postgres-audit.sql" -OutFile ".\postgres-audit.sql"
Invoke-WebRequest -Uri "$baseUrl/postgres-quartz.sql" -OutFile ".\postgres-quartz.sql"

# 2. DefiniÃ§Ã£o do Compose
$COMPOSE_CONTENT = @"
services:
  postgres:
    image: postgres:16
    container_name: iga-postgres
    environment:
      POSTGRES_DB: midpoint
      POSTGRES_USER: midpoint_user
      POSTGRES_PASSWORD: 'P0stgr3sS3cur3#2026!'
    volumes:
      - ./data/postgres:/var/lib/postgresql/data
    networks:
      - iga-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U midpoint_user -d midpoint"]
      interval: 10s
      timeout: 5s
      retries: 5

  midpoint:
    image: evolveum/midpoint:4.8
    container_name: iga-midpoint
    ports:
      - "8080:8080"
    environment:
      REPO_DATABASE_TYPE: postgresql
      REPO_HOST: postgres
      REPO_DATABASE: midpoint
      REPO_USER: midpoint_user
      REPO_PASSWORD: 'P0stgr3sS3cur3#2026!'
      MP_KEYSTORE_PASSWORD: 'midpoint_keystore_2026'
      MP_SET_midpoint.repository.embedded: "false"
      MP_SET_midpoint.repository.missingSchemaAction: "none"
      MP_SET_midpoint.administrator.initialPassword: "M1dP0!ntAdm!n#2026"
    volumes:
      - ./data/midpoint/var:/opt/midpoint/var
      - ./logs/midpoint:/opt/midpoint/var/log
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - iga-network

networks:
  iga-network:
    driver: bridge
"@

# 3. PreparaÃ§Ã£o e Upload
$COMPOSE_CONTENT | Out-File -FilePath ".\docker-compose.yml" -Encoding ascii
Write-Host "ðŸ“‚ Enviando arquivos para a VM..."
scp .\docker-compose.yml ${USER}@${VM_IP}:${PRJ_PATH}/

# 4. Reset Remoto (Agora sem pedir senha se o 1Âº Ato foi feito)
Write-Host "ðŸ§¹ Resetando ambiente..."
ssh ${USER}@${VM_IP} "sudo docker compose -f $PRJ_PATH/docker-compose.yml down -v; sudo rm -rf $PRJ_PATH/data/*"

# 5. InicializaÃ§Ã£o do Banco
Write-Host "ðŸ—„ï¸ Subindo PostgreSQL..." -ForegroundColor Blue
ssh ${USER}@${VM_IP} "cd $PRJ_PATH; sudo docker compose up -d postgres"

Write-Host "â³ Aguardando saÃºde do banco (20s)..."
Start-Sleep -Seconds 20

# 6. InjeÃ§Ã£o de SQL via TÃºnel (O CoraÃ§Ã£o da v9)
Write-Host "ðŸ’‰ Injetando SQL via TÃºnel SSH..." -ForegroundColor Magenta
$sqlFiles = Get-Content ".\postgres.sql", ".\postgres-audit.sql", ".\postgres-quartz.sql" -Raw
$sqlFiles | ssh ${USER}@${VM_IP} "sudo docker exec -i iga-postgres psql -U midpoint_user -d midpoint"

# 7. InicializaÃ§Ã£o do midPoint
Write-Host "ðŸš€ Iniciando midPoint 4.8..." -ForegroundColor Green
ssh ${USER}@${VM_IP} "cd $PRJ_PATH; sudo docker compose up -d midpoint"

Write-Host "â³ Acompanhando Log de Boot..."
ssh ${USER}@${VM_IP} "sudo docker logs -f iga-midpoint"
