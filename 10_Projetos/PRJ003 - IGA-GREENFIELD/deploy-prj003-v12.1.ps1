$VM_IP = "xxx.xxx.xxx.xxx"
$USER = "paulo"
$PRJ_PATH = "/srv/iga-project"
$DB_PWD = "P0stgr3sS3cur3#2026!"

Write-Host "--- PRJ003 - Tentativa 12.1 | Final Boss: Keystore & H2 Bypass ---" -ForegroundColor Cyan

# 1. Geracao do config.xml (Ajustado com user/pass na URL e escape de XML)
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

# 2. Geracao do docker-compose.yml (Removendo variaveis MP_SET que causam fallback para H2)
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
      # O segredo: Não passamos variaveis de banco aqui para a imagem não sobrescrever nosso config.xml
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

# 3. Limpeza Nuclear de Aplicacao (Mas preservando o banco injetado se quiser, ou limpando tudo)
# Vamos limpar TUDO para garantir que o Keystore seja novo.
Write-Host "Limpando volumes de aplicacao na VM..."
ssh ${USER}@${VM_IP} "sudo docker compose -f $PRJ_PATH/docker-compose.yml down -v; sudo rm -rf $PRJ_PATH/data/midpoint/* $PRJ_PATH/config/*"

# 4. Upload e Preparacao
[System.IO.File]::WriteAllText("$PWD\config.xml", $CONFIG_XML)
[System.IO.File]::WriteAllText("$PWD\docker-compose.yml", $COMPOSE_CONTENT)
ssh ${USER}@${VM_IP} "mkdir -p $PRJ_PATH/config"
scp .\config.xml ${USER}@${VM_IP}:${PRJ_PATH}/config/
scp .\docker-compose.yml ${USER}@${VM_IP}:${PRJ_PATH}/

# 5. Reinicializacao Focada
Write-Host "Fase 1: Subindo Postgres..."
ssh ${USER}@${VM_IP} "cd $PRJ_PATH; sudo docker compose up -d postgres"
Start-Sleep -Seconds 15

Write-Host "Fase 2: Reinjetando SQL (Garantindo banco limpo e populado)..."
Get-Content ".\postgres.sql", ".\postgres-audit.sql", ".\postgres-quartz.sql" -Raw | ssh ${USER}@${VM_IP} "sudo docker exec -i iga-postgres psql -U midpoint_user -d midpoint"

Write-Host "Fase 3: Subindo midPoint com Config.xml Blindado..."
ssh ${USER}@${VM_IP} "cd $PRJ_PATH; sudo docker compose up -d midpoint"

# 6. Monitoramento
ssh ${USER}@${VM_IP} "sudo docker logs -f iga-midpoint"
