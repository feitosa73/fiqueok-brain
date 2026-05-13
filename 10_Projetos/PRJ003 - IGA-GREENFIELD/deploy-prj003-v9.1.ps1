$VM_IP = "xxx.xxx.xxx.xxx"
$USER = "paulo"
$PRJ_PATH = "/srv/iga-project"

Write-Host "ðŸš€ Iniciando Tentativa #9.1 - InjeÃ§Ã£o via Host" -ForegroundColor Cyan

# 1. Reset na VM
ssh -t ${USER}@${VM_IP} "sudo docker compose -f $PRJ_PATH/docker-compose.yml down -v; sudo rm -rf $PRJ_PATH/data/*"

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

$COMPOSE_CONTENT | Out-File -FilePath ".\docker-compose.yml" -Encoding ascii
scp .\docker-compose.yml ${USER}@${VM_IP}:${PRJ_PATH}/
ssh -t ${USER}@${VM_IP} "cd $PRJ_PATH && sudo docker compose up -d postgres"

Write-Host "â³ Aguardando banco... (15s)"
Start-Sleep -Seconds 15

Write-Host "ðŸ’‰ Injetando SQL via TÃºnel SSH..." -ForegroundColor Magenta
Get-Content ".\postgres.sql", ".\postgres-audit.sql", ".\postgres-quartz.sql" | ssh ${USER}@${VM_IP} "sudo docker exec -i iga-postgres psql -U midpoint_user -d midpoint"

ssh -t ${USER}@${VM_IP} "cd $PRJ_PATH && sudo docker compose up -d midpoint"
ssh ${USER}@${VM_IP} "sudo docker logs -f iga-midpoint"

