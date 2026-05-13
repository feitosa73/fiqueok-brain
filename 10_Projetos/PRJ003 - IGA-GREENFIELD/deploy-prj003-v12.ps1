$VM_IP = "xxx.xxx.xxx.xxx"
$USER = "paulo"
$PRJ_PATH = "/srv/iga-project"
$DB_PWD = "P0stgr3sS3cur3#2026!"

Write-Host "--- PRJ003 - Tentativa 12 | Fusao Manus + Fiqueok (SCRAM Fix) ---" -ForegroundColor Cyan

# 1. Geracao do config.xml (Baseado no parecer Manus.ai)
$CONFIG_XML = @"
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <midpoint>
        <repository>
            <type>native</type>
            <jdbcUrl>jdbc:postgresql://postgres:5432/midpoint?user=midpoint_user&amp;password=$DB_PWD</jdbcUrl>
        </repository>
        <keystore>
            <keyStorePath>`${midpoint.home}/keystore.jceks</keyStorePath>
            <keyStorePassword>midpoint_keystore_2026</keyStorePassword>
            <encryptionKeyAlias>default</encryptionKeyAlias>
        </keystore>
    </midpoint>
</configuration>
"@

# 2. Geracao do docker-compose.yml (Bypass total de MP_SET de Banco)
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
      interval: 10s
      timeout: 5s
      retries: 5

  midpoint:
    image: evolveum/midpoint:4.8
    container_name: iga-midpoint
    ports:
      - "8080:8080"
    environment:
      # Mantemos apenas o essencial para a aplicacao, o banco vem via config.xml
      MP_KEYSTORE_PASSWORD: 'midpoint_keystore_2026'
      MP_SET_midpoint_administrator_initialPassword: "M1dP0!ntAdm!n#2026"
    volumes:
      - ./data/midpoint/var:/opt/midpoint/var
      - ./config/config.xml:/opt/midpoint/var/config.xml:ro
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - iga-network

networks:
  iga-network:
    driver: bridge
"@

# 3. Preparacao Local e Upload
Write-Host "Preparando arquivos locais..."
if (!(Test-Path ".\config")) { New-Item -ItemType Directory -Path ".\config" }
[System.IO.File]::WriteAllText("$PWD\config\config.xml", $CONFIG_XML)
[System.IO.File]::WriteAllText("$PWD\docker-compose.yml", $COMPOSE_CONTENT)

Write-Host "Enviando configuracoes para a VM..."
ssh ${USER}@${VM_IP} "mkdir -p $PRJ_PATH/config"
scp .\config\config.xml ${USER}@${VM_IP}:${PRJ_PATH}/config/
scp .\docker-compose.yml ${USER}@${VM_IP}:${PRJ_PATH}/

# 4. Restart dos Servicos (Garantindo limpeza de logs)
Write-Host "Reiniciando midPoint com Injeção de URL JDBC..." -ForegroundColor Yellow
ssh ${USER}@${VM_IP} "cd $PRJ_PATH; sudo docker compose up -d"

# 5. Monitoramento
Write-Host "Acompanhando logs..."
ssh ${USER}@${VM_IP} "sudo docker logs -f iga-midpoint"
