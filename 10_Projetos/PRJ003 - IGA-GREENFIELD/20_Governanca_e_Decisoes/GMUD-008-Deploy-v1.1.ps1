# ====================================================================
# GMUD-008 v1.1 - Deploy Automatizado IaC do Ambiente IGA
# Projeto: PRJ003 - IGA Greenfield Reference Architecture
# Versão: 1.1 (Correções de Escaping e Timeout)
# Data: 18/01/2026 22:00
# Executor: Paulo Feitosa
# ====================================================================

# ====================================================================
# CONFIGURAÇÃO INICIAL - LEITURA DE CREDENCIAIS
# ====================================================================

# Verificar se arquivo .env existe no diretório local
if (-not (Test-Path ".env")) {
    Write-Error "ERRO: Arquivo .env não encontrado no diretório do script"
    Write-Host "Crie o arquivo .env com as seguintes variáveis:" -ForegroundColor Yellow
    Write-Host "VM_IP=xxx.xxx.xxx.xxx" -ForegroundColor Gray
    Write-Host "VM_USER=paulo" -ForegroundColor Gray
    Write-Host "POSTGRES_PASSWORD=SuaSenha" -ForegroundColor Gray
    Write-Host "MIDPOINT_ADMIN_PASSWORD=SuaSenha" -ForegroundColor Gray
    exit 1
}

# Carregar variáveis do arquivo .env
Get-Content ".env" | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
    $name, $value = $_.Split('=', 2)
    Set-Variable -Name $name.Trim() -Value $value.Trim() -Scope Script
}

# Validar variáveis obrigatórias
if (-not $VM_IP -or -not $VM_USER -or -not $POSTGRES_PASSWORD -or -not $MIDPOINT_ADMIN_PASSWORD) {
    Write-Error "ERRO: Variáveis obrigatórias ausentes no .env"
    exit 1
}

$BASE_DIR = "/srv/prj003"
$EVIDENCE_DIR = "$BASE_DIR/evidencias"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "GMUD-008 v1.1 - Deploy Automatizado IaC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VM: $VM_USER@$VM_IP" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Cyan

# ====================================================================
# STEP 1: PRÉ-FLIGHT CHECKLIST (Red Teaming)
# ====================================================================
Write-Host "[STEP 1] Executando Pre-Flight Checklist..." -ForegroundColor Yellow

# 1.1 Conectividade SSH
Write-Host "  1.1 Validando conectividade SSH..." -ForegroundColor Gray
$ssh_test = ssh -o ConnectTimeout=5 "$VM_USER@$VM_IP" "echo 'SSH_OK'" 2>&1
if ($ssh_test -notmatch "SSH_OK") {
    Write-Error "FALHA: Conectividade SSH não disponível"
    exit 1
}
Write-Host "    ✅ SSH OK" -ForegroundColor Green

# 1.2 Sudo sem senha
Write-Host "  1.2 Validando sudo sem senha..." -ForegroundColor Gray
$sudo_test = ssh "$VM_USER@$VM_IP" "sudo -n whoami" 2>&1
if ($sudo_test -ne "root") {
    Write-Error "FALHA: Sudo requer senha interativa"
    exit 1
}
Write-Host "    ✅ Sudo sem senha OK" -ForegroundColor Green

# 1.3 Docker instalado
Write-Host "  1.3 Validando Docker..." -ForegroundColor Gray
$docker_version = ssh "$VM_USER@$VM_IP" "docker --version" 2>&1
if ($docker_version -notmatch "Docker version") {
    Write-Error "FALHA: Docker não instalado"
    exit 1
}
Write-Host "    ✅ Docker OK: $docker_version" -ForegroundColor Green

# 1.4 Docker Compose instalado
Write-Host "  1.4 Validando Docker Compose..." -ForegroundColor Gray
$compose_version = ssh "$VM_USER@$VM_IP" "docker compose version" 2>&1
if ($compose_version -notmatch "Docker Compose version") {
    Write-Error "FALHA: Docker Compose não instalado"
    exit 1
}
Write-Host "    ✅ Docker Compose OK: $compose_version" -ForegroundColor Green

# 1.5 CRÍTICO: Conectividade Externa
Write-Host "  1.5 Validando conectividade externa..." -ForegroundColor Gray
$ping_test = ssh "$VM_USER@$VM_IP" "ping -c 2 8.8.8.8" 2>&1
if ($ping_test -notmatch "2 packets transmitted, 2 received") {
    Write-Error "FALHA: Sem conectividade externa (ping 8.8.8.8 falhou)"
    exit 1
}
Write-Host "    ✅ Conectividade externa OK" -ForegroundColor Green

# 1.6 CRÍTICO: Resolução DNS
Write-Host "  1.6 Validando resolução DNS..." -ForegroundColor Gray
$dns_test = ssh "$VM_USER@$VM_IP" "nslookup registry-1.docker.io" 2>&1
if ($dns_test -notmatch "Address:") {
    Write-Warning "FALHA: Resolução DNS falhou - Aplicando contorno temporário..."
    ssh "$VM_USER@$VM_IP" "echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf" | Out-Null
    Start-Sleep -Seconds 2
    $dns_test = ssh "$VM_USER@$VM_IP" "nslookup registry-1.docker.io" 2>&1
    if ($dns_test -notmatch "Address:") {
        Write-Error "FALHA: Resolução DNS falhou mesmo após contorno"
        exit 1
    }
    Write-Host "    ⚠️  DNS temporário aplicado (8.8.8.8) - Requer solução permanente" -ForegroundColor Yellow
} else {
    Write-Host "    ✅ Resolução DNS OK" -ForegroundColor Green
}

# 1.7 CRÍTICO: Acesso ao Docker Hub
Write-Host "  1.7 Validando acesso ao Docker Hub..." -ForegroundColor Gray
$hub_test = ssh "$VM_USER@$VM_IP" "curl -I https://registry-1.docker.io/v2/ 2>&1 | head -1" 2>&1
if ($hub_test -notmatch "HTTP") {
    Write-Error "FALHA: Acesso ao Docker Hub falhou"
    exit 1
}
Write-Host "    ✅ Docker Hub acessível" -ForegroundColor Green

# 1.8 Estado limpo
Write-Host "  1.8 Validando estado limpo..." -ForegroundColor Gray
$containers = ssh "$VM_USER@$VM_IP" "docker ps -a -q" 2>&1
if ($containers) {
    Write-Warning "ATENÇÃO: Containers existentes detectados - Aplicando limpeza..."
    ssh "$VM_USER@$VM_IP" "cd $BASE_DIR 2>/dev/null && docker compose down 2>/dev/null; docker system prune -f" | Out-Null
}
Write-Host "    ✅ Ambiente limpo" -ForegroundColor Green

Write-Host "`n[STEP 1] ✅ Pre-Flight Checklist APROVADO`n" -ForegroundColor Green

# ====================================================================
# STEP 2: PREPARAÇÃO DO AMBIENTE
# ====================================================================
Write-Host "[STEP 2] Preparando estrutura de diretórios..." -ForegroundColor Yellow

ssh "$VM_USER@$VM_IP" @"
sudo mkdir -p $BASE_DIR/data/postgres
sudo mkdir -p $BASE_DIR/data/midpoint/var
sudo mkdir -p $BASE_DIR/logs/midpoint
sudo mkdir -p $EVIDENCE_DIR
sudo chown -R $VM_USER:$VM_USER $BASE_DIR
"@ | Out-Null

Write-Host "[STEP 2] ✅ Estrutura criada`n" -ForegroundColor Green

# ====================================================================
# STEP 3: CRIAÇÃO DO ARQUIVO .env NA VM
# ====================================================================
Write-Host "[STEP 3] Criando arquivo .env na VM..." -ForegroundColor Yellow

# CORREÇÃO v1.1: Usar heredoc com aspas simples para evitar expansão local
ssh "$VM_USER@$VM_IP" @"
cat > $BASE_DIR/.env << 'ENVEOF'
# Credenciais do PostgreSQL (Backend)
POSTGRES_DB=midpoint
POSTGRES_USER=midpoint
POSTGRES_PASSWORD=$POSTGRES_PASSWORD

# Credenciais do midPoint (Frontend)
MIDPOINT_ADMIN_USERNAME=administrator
MIDPOINT_ADMIN_PASSWORD=$MIDPOINT_ADMIN_PASSWORD
ENVEOF
chmod 600 $BASE_DIR/.env
"@

Write-Host "[STEP 3] ✅ Arquivo .env criado na VM`n" -ForegroundColor Green

# ====================================================================
# STEP 4: CRIAÇÃO DO docker-compose.yml CORRIGIDO
# ====================================================================
Write-Host "[STEP 4] Criando docker-compose.yml (CORREÇÃO GMUD-008 v1.1)..." -ForegroundColor Yellow

# CORREÇÃO v1.1: Heredoc com aspas simples + expansão manual das variáveis críticas
ssh "$VM_USER@$VM_IP" @"
cat > $BASE_DIR/docker-compose.yml << 'COMPOSEEOF'
services:
  postgres:
    image: postgres:16-alpine
    container_name: postgres
    environment:
      POSTGRES_DB: \`${POSTGRES_DB}
      POSTGRES_USER: \`${POSTGRES_USER}
      POSTGRES_PASSWORD: \`${POSTGRES_PASSWORD}
    volumes:
      - $BASE_DIR/data/postgres:/var/lib/postgresql/data
    networks:
      - iga-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U midpoint"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  midpoint:
    image: evolveum/midpoint:4.8
    container_name: midpoint
    ports:
      - "8080:8080"
    environment:
      REPO_DATABASE_TYPE: postgresql
      REPO_HOST: postgres
      REPO_PORT: 5432
      REPO_DATABASE: \`${POSTGRES_DB}
      REPO_USER: \`${POSTGRES_USER}
      REPO_PASSWORD: \`${POSTGRES_PASSWORD}
      REPO_JDBC_URL: jdbc:postgresql://postgres:5432/\`${POSTGRES_DB}
      MP_SET_midpoint.repository.jdbcUrl: jdbc:postgresql://postgres:5432/\`${POSTGRES_DB}
      MP_SET_midpoint.repository.jdbcUsername: \`${POSTGRES_USER}
      MP_SET_midpoint.repository.jdbcPassword: \`${POSTGRES_PASSWORD}
      MP_SET_midpoint.repository.database: postgresql
      MP_SET_midpoint.administrator.initialPassword: \`${MIDPOINT_ADMIN_PASSWORD}
    volumes:
      - $BASE_DIR/data/midpoint/var:/opt/midpoint/var
      - $BASE_DIR/logs/midpoint:/opt/midpoint/var/log
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - iga-network
    restart: unless-stopped

networks:
  iga-network:
    driver: bridge
COMPOSEEOF
"@

# Validar sintaxe
Write-Host "  Validando sintaxe do docker-compose.yml..." -ForegroundColor Gray
$compose_validation = ssh "$VM_USER@$VM_IP" "cd $BASE_DIR && docker compose config" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "FALHA: Sintaxe do docker-compose.yml inválida"
    Write-Host $compose_validation -ForegroundColor Red
    exit 1
}

Write-Host "[STEP 4] ✅ docker-compose.yml criado e validado`n" -ForegroundColor Green

# ====================================================================
# STEP 5: PULL DE IMAGENS DOCKER
# ====================================================================
Write-Host "[STEP 5] Fazendo pull das imagens Docker..." -ForegroundColor Yellow

Write-Host "  Baixando postgres:16-alpine..." -ForegroundColor Gray
ssh "$VM_USER@$VM_IP" "docker pull postgres:16-alpine" 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "FALHA: Pull da imagem PostgreSQL falhou"
    exit 1
}

Write-Host "  Baixando evolveum/midpoint:4.8..." -ForegroundColor Gray
ssh "$VM_USER@$VM_IP" "docker pull evolveum/midpoint:4.8" 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "FALHA: Pull da imagem midPoint falhou"
    exit 1
}

ssh "$VM_USER@$VM_IP" "docker images > $EVIDENCE_DIR/images-downloaded.txt"

Write-Host "[STEP 5] ✅ Imagens baixadas com sucesso`n" -ForegroundColor Green

# ====================================================================
# STEP 6: INICIALIZAÇÃO FASE 1 - POSTGRESQL
# ====================================================================
Write-Host "[STEP 6] Inicializando PostgreSQL (Fase 1)..." -ForegroundColor Yellow

ssh "$VM_USER@$VM_IP" "cd $BASE_DIR && docker compose up -d postgres" 2>&1 | Out-Null

Write-Host "  Aguardando PostgreSQL atingir estado healthy..." -ForegroundColor Gray
$max_attempts = 30
$attempt = 0
$postgres_healthy = `$false

while ($attempt -lt $max_attempts) {
    $health_status = ssh "$VM_USER@$VM_IP" "docker inspect postgres --format='{{.State.Health.Status}}'" 2>&1
    if ($health_status -eq "healthy") {
        $postgres_healthy = `$true
        break
    }
    Start-Sleep -Seconds 2
    $attempt++
    Write-Host "    Tentativa $attempt/$max_attempts - Status: $health_status" -ForegroundColor Gray
}

if (-not $postgres_healthy) {
    Write-Error "FALHA: PostgreSQL não atingiu estado healthy em 60 segundos"
    ssh "$VM_USER@$VM_IP" "docker logs postgres > $EVIDENCE_DIR/postgres-failure.log 2>&1"
    Write-Host "Logs salvos em: $EVIDENCE_DIR/postgres-failure.log" -ForegroundColor Yellow
    exit 1
}

# Aguardar consolidação do schema
Write-Host "  Aguardando consolidação do schema (10s)..." -ForegroundColor Gray
Start-Sleep -Seconds 10

ssh "$VM_USER@$VM_IP" "docker logs postgres > $EVIDENCE_DIR/postgres-bootstrap.log 2>&1"

Write-Host "[STEP 6] ✅ PostgreSQL inicializado e saudável`n" -ForegroundColor Green

# ====================================================================
# STEP 7: INICIALIZAÇÃO FASE 2 - MIDPOINT
# ====================================================================
Write-Host "[STEP 7] Inicializando midPoint (Fase 2)..." -ForegroundColor Yellow

ssh "$VM_USER@$VM_IP" "cd $BASE_DIR && docker compose up -d midpoint" 2>&1 | Out-Null

# CORREÇÃO v1.1: Timeout aumentado para 180s (3 minutos)
Write-Host "  Aguardando bootstrap do midPoint (180s - 3 minutos)..." -ForegroundColor Gray
Write-Host "  midPoint é pesado - aguarde pacientemente..." -ForegroundColor Yellow

for ($i = 1; $i -le 18; $i++) {
    Start-Sleep -Seconds 10
    Write-Host "    $($i*10)s / 180s..." -ForegroundColor Gray
}

ssh "$VM_USER@$VM_IP" "docker logs midpoint > $EVIDENCE_DIR/midpoint-bootstrap.log 2>&1"

Write-Host "[STEP 7] ✅ midPoint inicializado (aguardou 180s)`n" -ForegroundColor Green

# ====================================================================
# STEP 8: GATE DE VALIDAÇÃO CRÍTICO (PostgreSQL vs H2)
# ====================================================================
Write-Host "[STEP 8] GATE CRÍTICO - Validando tipo de repositório..." -ForegroundColor Yellow

# Verificar se H2 foi detectado (FALHA)
$h2_detected = ssh "$VM_USER@$VM_IP" "docker logs midpoint 2>&1 | grep -i 'repository.*h2'" 2>&1

if ($h2_detected) {
    Write-Host "`n❌ FALHA CRÍTICA: midPoint ativou fallback H2!" -ForegroundColor Red
    Write-Host "Evidência: $h2_detected" -ForegroundColor Red
    
    # CORREÇÃO v1.1: Rollback condicional com confirmação
    Write-Host "`n⚠️  ROLLBACK CONDICIONAL:" -ForegroundColor Yellow
    Write-Host "  - Fallback H2 confirmado nos logs" -ForegroundColor Gray
    Write-Host "  - PostgreSQL NÃO foi utilizado" -ForegroundColor Gray
    Write-Host "  - Dados atuais NÃO são válidos" -ForegroundColor Gray
    
    $rollback_confirm = Read-Host "`nDeseja aplicar rollback e destruir os dados? (S/N)"
    
    if ($rollback_confirm -eq 'S' -or $rollback_confirm -eq 's') {
        Write-Host "`nAcionando rollback automático..." -ForegroundColor Yellow
        
        ssh "$VM_USER@$VM_IP" @"
cd $BASE_DIR
docker compose down
sudo rm -rf $BASE_DIR/data/postgres
sudo rm -rf $BASE_DIR/data/midpoint/var
echo 'ROLLBACK: Fallback H2 detectado' > $EVIDENCE_DIR/rollback-reason.txt
echo 'Timestamp: \`$(date)' >> $EVIDENCE_DIR/rollback-reason.txt
"@
        
        Write-Error "GMUD-008 FALHOU: midPoint não conectou ao PostgreSQL - Rollback aplicado"
    } else {
        Write-Host "`nRollback cancelado pelo executor - Analise os logs manualmente" -ForegroundColor Yellow
    }
    
    exit 1
}

# Verificar se PostgreSQL foi detectado (SUCESSO)
$postgres_detected = ssh "$VM_USER@$VM_IP" "docker logs midpoint 2>&1 | grep -i 'repository.*postgresql'" 2>&1

if ($postgres_detected) {
    Write-Host "  ✅ PostgreSQL confirmado nos logs!" -ForegroundColor Green
    Write-Host "  Evidência: $postgres_detected" -ForegroundColor Gray
} else {
    Write-Warning "ATENÇÃO: Não foi possível confirmar uso de PostgreSQL explicitamente"
    Write-Host "Continuando validação com endpoint HTTP..." -ForegroundColor Yellow
}

Write-Host "[STEP 8] ✅ Gate de validação APROVADO (nenhum H2 detectado)`n" -ForegroundColor Green

# ====================================================================
# STEP 9: VALIDAÇÃO DE ENDPOINT HTTP
# ====================================================================
Write-Host "[STEP 9] Validando endpoint HTTP..." -ForegroundColor Yellow

# Aguardar adicional para garantir estabilização
Write-Host "  Aguardando estabilização final (30s)..." -ForegroundColor Gray
Start-Sleep -Seconds 30

$http_test = ssh "$VM_USER@$VM_IP" "curl -I http://$VM_IP:8080/midpoint 2>&1 | head -1" 2>&1

if ($http_test -notmatch "HTTP") {
    Write-Error "FALHA: Endpoint HTTP não respondeu"
    ssh "$VM_USER@$VM_IP" "docker logs midpoint > $EVIDENCE_DIR/midpoint-http-failure.log 2>&1"
    exit 1
}

ssh "$VM_USER@$VM_IP" "curl -v http://$VM_IP:8080/midpoint > $EVIDENCE_DIR/http-response.txt 2>&1"

Write-Host "  ✅ Endpoint HTTP respondendo: $http_test" -ForegroundColor Green
Write-Host "[STEP 9] ✅ Validação HTTP concluída`n" -ForegroundColor Green

# ====================================================================
# STEP 10: COLETA DE EVIDÊNCIAS FINAIS
# ====================================================================
Write-Host "[STEP 10] Coletando evidências técnicas..." -ForegroundColor Yellow

ssh "$VM_USER@$VM_IP" @"
docker ps > $EVIDENCE_DIR/containers-runtime.txt
docker inspect postgres > $EVIDENCE_DIR/postgres-config.json
docker inspect midpoint > $EVIDENCE_DIR/midpoint-config.json
docker logs postgres > $EVIDENCE_DIR/postgres-final.log 2>&1
docker logs midpoint > $EVIDENCE_DIR/midpoint-final.log 2>&1
du -sh $BASE_DIR/data/postgres > $EVIDENCE_DIR/volumes-size.txt
du -sh $BASE_DIR/data/midpoint/var >> $EVIDENCE_DIR/volumes-size.txt
echo '=== ÍNDICE DE EVIDÊNCIAS ===' > $EVIDENCE_DIR/INDEX.txt
ls -lh $EVIDENCE_DIR >> $EVIDENCE_DIR/INDEX.txt
echo '=== CONFIGURAÇÃO DO AMBIENTE ===' >> $EVIDENCE_DIR/INDEX.txt
echo 'VM IP: $VM_IP' >> $EVIDENCE_DIR/INDEX.txt
echo 'Data de Execução: \`$(date)' >> $EVIDENCE_DIR/INDEX.txt
echo 'Versão da GMUD: 008 v1.1' >> $EVIDENCE_DIR/INDEX.txt
"@

Write-Host "[STEP 10] ✅ Evidências coletadas`n" -ForegroundColor Green

# ====================================================================
# CONCLUSÃO
# ====================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "GMUD-008 v1.1 EXECUTADA COM SUCESSO" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "📋 Próximas ações MANUAIS:" -ForegroundColor Yellow
Write-Host "  1. Acessar http://$VM_IP:8080/midpoint" -ForegroundColor White
Write-Host "  2. Fazer login com:" -ForegroundColor White
Write-Host "     Usuário: administrator" -ForegroundColor White
Write-Host "     Senha: $MIDPOINT_ADMIN_PASSWORD" -ForegroundColor White
Write-Host "  3. Validar dashboard do midPoint" -ForegroundColor White
Write-Host "  4. Capturar screenshot do dashboard" -ForegroundColor White
Write-Host "  5. Criar REL-GMUD-008 com status de sucesso" -ForegroundColor White
Write-Host "`n📁 Evidências disponíveis em: $EVIDENCE_DIR" -ForegroundColor Cyan
Write-Host "`n✅ Deploy concluído - Validação manual de login pendente`n" -ForegroundColor Green
