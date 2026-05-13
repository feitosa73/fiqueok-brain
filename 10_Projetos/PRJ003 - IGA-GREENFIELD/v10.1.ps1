$VM_IP = "xxx.xxx.xxx.xxx"
$USER = "paulo"
$PRJ_PATH = "/srv/iga-project"

Write-Host "🚀 PRJ003 - Tentativa #10.1 | Ajuste de Autenticação SCRAM" -ForegroundColor Cyan

# 1. Definição do Compose Hardened (Usando injeção direta MP_SET)
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
      # Bypass total da lógica REPO_* (Usando injeção direta no Spring/Java)
      MP_SET_midpoint_repository_type: native
      MP_SET_midpoint_repository_jdbcUrl: jdbc:postgresql://postgres:5432/midpoint
      MP_SET_midpoint_repository_jdbcUsername: midpoint_user
      MP_SET_midpoint_repository_jdbcPassword: 'P0stgr3sS3cur3#2026!'
      MP_SET_midpoint_repository_database: postgresql
      MP_SET_midpoint_repository_missingSchemaAction: none
      
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

# 2. Upload do Compose
$COMPOSE_CONTENT | Out-File -FilePath ".\docker-compose.yml" -Encoding ascii
scp .\docker-compose.yml ${USER}@${VM_IP}:${PRJ_PATH}/

# 3. Reinicialização (Garantindo que o midPoint pegue as novas variáveis)
Write-Host "🔄 Reiniciando midPoint com credenciais explícitas..." -ForegroundColor Yellow
ssh ${USER}@${VM_IP} "cd $PRJ_PATH; sudo docker compose up -d"

# 4. Logs
Write-Host "⏳ Acompanhando Log de Boot Final..."
ssh ${USER}@${VM_IP} "sudo docker logs -f iga-midpoint"
