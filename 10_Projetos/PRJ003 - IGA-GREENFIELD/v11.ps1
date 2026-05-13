$VM_IP = "xxx.xxx.xxx.xxx"
$USER = "paulo"
$PRJ_PATH = "/srv/iga-project"

Write-Host "🚀 PRJ003 - Tentativa #11 | Validação de Schema e Boot" -ForegroundColor Cyan

# 1. Definição do Compose Hardened (Ajustado para 'validate')
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
      # Injeção direta via MP_SET para garantir SCRAM Auth
      MP_SET_midpoint_repository_type: native
      MP_SET_midpoint_repository_jdbcUrl: jdbc:postgresql://postgres:5432/midpoint
      MP_SET_midpoint_repository_jdbcUsername: midpoint_user
      MP_SET_midpoint_repository_jdbcPassword: 'P0stgr3sS3cur3#2026!'
      MP_SET_midpoint_repository_database: postgresql
      MP_SET_midpoint_repository_missingSchemaAction: validate # AJUSTE CRÍTICO
      
      MP_KEYSTORE_PASSWORD: 'midpoint_keystore_2026'
      MP_SET_midpoint_administrator_initialPassword: "M1dP0!ntAdm!n#2026"
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

# 2. Upload da Configuração
$COMPOSE_CONTENT | Out-File -FilePath ".\docker-compose.yml" -Encoding ascii
Write-Host " Atualizando docker-compose na VM..."
scp .\docker-compose.yml ${USER}@${VM_IP}:${PRJ_PATH}/

# 3. Reinicialização dos Serviços (Sem apagar o banco que já injetamos)
Write-Host "🔄 Reiniciando containers..." -ForegroundColor Yellow
ssh ${USER}@${VM_IP} "cd $PRJ_PATH; sudo docker compose up -d"

# 4. Monitoramento Final
Write-Host " Acompanhando log de inicialização... Aguarde a logo ASCII."
ssh ${USER}@${VM_IP} "sudo docker logs -f iga-midpoint"
