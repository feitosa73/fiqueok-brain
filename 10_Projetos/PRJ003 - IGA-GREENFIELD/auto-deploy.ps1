$VM_IP = "xxx.xxx.xxx.xxx"
$USER = "paulo"
$PRJ_PATH = "/srv/iga-project"
$DB_PWD = "P0stgr3sS3cur3#2026!"

Write-Host "--- PRJ003 | INICIANDO AUTOMACAO TOTAL (TENTATIVA 14) ---"

# 1. Reset de Infraestrutura na VM
Write-Host "1. Limpando ambiente na VM..."
ssh -t ${USER}@${VM_IP} "sudo docker compose -f $PRJ_PATH/docker-compose.yml down -v; sudo rm -rf $PRJ_PATH/data/* $PRJ_PATH/config/*"

# 2. Criacao do config.xml Fixo (Solucao Manus + Hardening)
$XML_CONTENT = @"
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

# 3. Criacao do docker-compose.yml (Bypass total de logica de imagem)
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
    image: evolveum/midpoint:4.8
    container_name: iga-midpoint
    ports:
      - "8080:8080"
    environment:
      MP_KEYSTORE_PASSWORD: 'midpoint_keystore_2026'
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

# 4. Escrita e Transferencia
if (!(Test-Path ".\config")) { New-Item -ItemType Directory -Path ".\config" }
[System.IO.File]::WriteAllText("$PWD\config\config.xml", $XML_CONTENT)
[System.IO.File]::WriteAllText("$PWD\docker-compose.yml", $COMPOSE_CONTENT)

Write-Host "2. Enviando configuracoes..."
ssh ${USER}@${VM_IP} "mkdir -p $PRJ_PATH/config"
scp .\config\config.xml ${USER}@${VM_IP}:${PRJ_PATH}/config/
scp .\docker-compose.yml ${USER}@${VM_IP}:${PRJ_PATH}/

# 5. Inicializacao do Banco e Injecao de Schema
Write-Host "3. Subindo banco e injetando SQL..."
ssh ${USER}@${VM_IP} "cd $PRJ_PATH; sudo docker compose up -d postgres"
Start-Sleep -Seconds 15
Get-Content ".\postgres.sql", ".\postgres-audit.sql", ".\postgres-quartz.sql" -Raw | ssh ${USER}@${VM_IP} "sudo docker exec -i iga-postgres psql -U midpoint_user -d midpoint"

# 6. Subida Final
Write-Host "4. Iniciando aplicacao midPoint..."
ssh ${USER}@${VM_IP} "cd $PRJ_PATH; sudo docker compose up -d midpoint"

# 7. Analise Automatica de Log
Write-Host "--- ANALISANDO LOGS EM TEMPO REAL ---"
ssh ${USER}@${VM_IP} "sudo docker logs -f iga-midpoint"
