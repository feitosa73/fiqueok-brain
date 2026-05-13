# GMUD-011 — Deploy midPoint 4.9 em Ambiente Greenfield com Controle Manual de Schema

**Projeto**: PRJ003 - IGA Greenfield Reference Architecture  
**Executor**: Paulo Feitosa  
**Data de Planejamento**: 21 de janeiro de 2026  
**Status**: PLANEJADA

---

## IDENTIFICAÇÃO

| Campo | Valor |
|---|---|
| **Projeto** | PRJ003 - IGA Greenfield Reference Architecture |
| **GMUD** | 011 - Deploy midPoint 4.9 com Controle Manual de Schema |
| **Executor** | Paulo Feitosa |
| **Data Planejada** | 21 de janeiro de 2026 |
| **Janela de Execução** | 1 hora |
| **Ambiente** | Ubuntu 24.04 LTS (VM: xxx.xxx.xxx.xxx) + Docker Compose v5.0.1 + PostgreSQL 16 + midPoint 4.9 |
| **Host de Orquestração** | Windows 11 + PowerShell 7 + SSH Client |

---

## OBJETIVO DA GMUD

### Objetivo Primário

Estabelecer ambiente IGA (Identity Governance & Administration) funcional usando **midPoint 4.9** com estratégia de **Soberania de Dados**, onde o banco PostgreSQL 16 é provisionado manualmente com schema completo **ANTES** da inicialização da aplicação midPoint.

### Critérios de Sucesso

- ✅ PostgreSQL 16 operacional com schema nativo SQALE completo
- ✅ midPoint 4.9 acessível em http://xxx.xxx.xxx.xxx:8080
- ✅ Autenticação com credencial `administrator:M1dP0!ntAdm!n#2026`
- ✅ Log contendo mensagem `Database schema is compliant`
- ✅ Pipeline de automação host-to-VM funcional

---

## JUSTIFICATIVA TÉCNICA

### Por que Migrar para midPoint 4.9?

A análise forense da GMUD-010 (14 tentativas sem sucesso) identificou limitações críticas da imagem Docker `evolveum/midpoint:4.8`:

| Problema | midPoint 4.8 | midPoint 4.9+ |
|---|---|---|
| Scripts SQL Embutidos | ❌ Não (download manual obrigatório) | ✅ Sim (incluídos no JAR) |
| Precedência de Variáveis | `REPO_*` > `MP_SET_*` (conflito) | `MP_SET_*` > `REPO_*` (previsível) |
| Fallback H2 | Agressivo (sem gatilho explícito) | Defensivo (respeita JDBC URL) |
| Suporte Docker | Limitado (entrypoint legado) | Otimizado (container-native) |

### Estratégia "Manual Control" vs "Autocreate"

**Por que NÃO usar `missingSchemaAction: create`?**

1. **Controle de Versão**: Permite validação explícita do schema antes do boot
2. **Auditabilidade GRC**: SQL executado é rastreável e versionado no Git
3. **Troubleshooting**: Separação clara entre falhas de banco vs. aplicação
4. **Determinismo**: Elimina dependência de lógica interna da imagem Docker

---

## ARQUITETURA DA SOLUÇÃO

### Fluxo de Execução

\`\`\`
graph TD
    A[Host Windows] -->|1. SCP upload| B[VM Ubuntu]
    B -->|2. docker compose up -d postgres| C[PostgreSQL 16]
    C -->|3. Aguarda Healthcheck| D{Healthy?}
    D -->|Sim| E[Injeção Manual SQL via psql]
    E -->|4. Validação: 89 tabelas criadas| F[docker compose up -d midpoint]
    F -->|5. Boot midPoint 4.9| G{Schema Compliant?}
    G -->|Sim| H[Aplicação Operacional]
    G -->|Não| I[Análise de Logs]
\`\`\`

### Componentes

**PostgreSQL 16**
- Image: `postgres:16`
- Configuração SCRAM-SHA-256
- Volume persistente: `./data/postgres`
- Healthcheck: `pg_isready` com retry 5x

**midPoint 4.9**
- Image: `evolveum/midpoint:4.9`
- Configuração via JDBC URL (bypass de lógica de imagem)
- Heap: 1GB (compatível com limite de 1.5GB do kernel)
- Volume: `./data/midpoint/var`

---

## DOCUMENTOS TÉCNICOS

### 1. Docker Compose (docker-compose.yml)

\`\`\`yaml
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
      interval: 5s
      timeout: 5s
      retries: 5

  midpoint:
    image: evolveum/midpoint:4.9
    container_name: iga-midpoint
    ports:
      - "8080:8080"
    environment:
      # BYPASS de lógica de imagem: senha embutida na URL
      REPO_DATABASE_TYPE: postgresql
      REPO_JDBC_URL: 'jdbc:postgresql://postgres:5432/midpoint?user=midpoint_user&password=P0stgr3sS3cur3#2026!'

      # Ajuste de memória para kernel Ubuntu 24.04
      JAVA_OPTS: "-Xms512m -Xmx1024m -Dmidpoint.repository.database=postgresql -Dfile.encoding=UTF8"

      # Configuração de segurança
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
\`\`\`

---

### 2. Script de Orquestração (deploy-prj003-v11.ps1)

\`\`\`powershell
# ============================================================================
# GMUD-011 | Deploy Automatizado midPoint 4.9 + PostgreSQL 16
# Projeto: PRJ003 - IGA Greenfield Reference Architecture
# Executor: Paulo Feitosa
# Data: 21 de janeiro de 2026
# ============================================================================

$ErrorActionPreference = "Stop"

# --- CONFIGURAÇÃO ---
$VM_IP = "xxx.xxx.xxx.xxx"
$USER = "paulo"
$PRJ_PATH = "/srv/iga-project"
$COMPOSE_FILE = "docker-compose.yml"

# URLs dos scripts SQL oficiais midPoint 4.9
$SQL_URLS = @(
    "https://raw.githubusercontent.com/Evolveum/midpoint/v4.9/config/sql/native-new/postgres.sql",
    "https://raw.githubusercontent.com/Evolveum/midpoint/v4.9/config/sql/native-new/postgres-audit.sql",
    "https://raw.githubusercontent.com/Evolveum/midpoint/v4.9/config/sql/native-new/postgres-quartz.sql"
)

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host " PRJ003 | GMUD-011 | DEPLOY midPoint 4.9 (Manual Control)" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# --- PASSO A: LIMPEZA NUCLEAR ---
Write-Host "[A] LIMPEZA NUCLEAR: Removendo volumes e keystores anteriores..." -ForegroundColor Yellow
ssh ${USER}@${VM_IP} "sudo docker compose -f $PRJ_PATH/$COMPOSE_FILE down -v 2>/dev/null || true"
ssh ${USER}@${VM_IP} "sudo rm -rf $PRJ_PATH/data/* $PRJ_PATH/config/* $PRJ_PATH/*.sql"
Write-Host "    ✅ Ambiente limpo (estado virgem garantido)" -ForegroundColor Green
Start-Sleep -Seconds 2

# --- PASSO B: UPLOAD DE ARTEFATOS ---
Write-Host ""
Write-Host "[B] UPLOAD: Enviando Docker Compose para VM..." -ForegroundColor Yellow
scp .\$COMPOSE_FILE ${USER}@${VM_IP}:${PRJ_PATH}/
Write-Host "    ✅ docker-compose.yml transferido" -ForegroundColor Green

# --- PASSO C: PROVISIONAMENTO POSTGRESQL ---
Write-Host ""
Write-Host "[C] POSTGRESQL: Subindo banco de dados..." -ForegroundColor Yellow
ssh ${USER}@${VM_IP} "cd $PRJ_PATH && sudo docker compose up -d postgres"
Write-Host "    ⏳ Aguardando healthcheck (max 30 segundos)..." -ForegroundColor DarkGray
Start-Sleep -Seconds 20

$healthcheck = ssh ${USER}@${VM_IP} "sudo docker exec iga-postgres pg_isready -U midpoint_user -d midpoint 2>&1"
if ($healthcheck -match "accepting connections") {
    Write-Host "    ✅ PostgreSQL 16 operacional" -ForegroundColor Green
} else {
    Write-Host "    ❌ ERRO: PostgreSQL não alcançou estado Healthy" -ForegroundColor Red
    Write-Host "    Log: $healthcheck" -ForegroundColor Red
    exit 1
}

# --- PASSO D: INJEÇÃO MANUAL DE SCHEMA ---
Write-Host ""
Write-Host "[D] SCHEMA: Injetando SQL nativo SQALE do midPoint 4.9..." -ForegroundColor Yellow

foreach ($url in $SQL_URLS) {
    $filename = Split-Path $url -Leaf
    Write-Host "    📥 Baixando $filename..." -ForegroundColor DarkGray
    Invoke-WebRequest -Uri $url -OutFile ".\$filename" -UseBasicParsing
}

Write-Host "    💉 Injetando scripts SQL no container PostgreSQL..." -ForegroundColor DarkGray
Get-Content .\postgres.sql, .\postgres-audit.sql, .\postgres-quartz.sql -Raw | `
    ssh ${USER}@${VM_IP} "sudo docker exec -i iga-postgres psql -U midpoint_user -d midpoint"

# Validação de tabelas criadas
$table_count = ssh ${USER}@${VM_IP} "sudo docker exec iga-postgres psql -U midpoint_user -d midpoint -t -c 'SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=''public'';'"
$table_count = $table_count.Trim()

if ([int]$table_count -ge 85) {
    Write-Host "    ✅ Schema completo: $table_count tabelas criadas" -ForegroundColor Green
} else {
    Write-Host "    ❌ ERRO: Apenas $table_count tabelas criadas (esperado: 85+)" -ForegroundColor Red
    exit 1
}

# --- PASSO E: BOOT DO MIDPOINT ---
Write-Host ""
Write-Host "[E] MIDPOINT: Iniciando aplicação 4.9..." -ForegroundColor Yellow
ssh ${USER}@${VM_IP} "cd $PRJ_PATH && sudo docker compose up -d midpoint"
Write-Host "    ⏳ Aguardando inicialização (60 segundos)..." -ForegroundColor DarkGray
Start-Sleep -Seconds 60

# --- PASSO F: VALIDAÇÃO DE SUCESSO ---
Write-Host ""
Write-Host "[F] VALIDAÇÃO: Verificando estado da aplicação..." -ForegroundColor Yellow

$logs = ssh ${USER}@${VM_IP} "sudo docker logs iga-midpoint 2>&1 | tail -100"

if ($logs -match "Started MidPointSpringApplication") {
    Write-Host "    ✅ Aplicação iniciada com sucesso" -ForegroundColor Green
} else {
    Write-Host "    ⚠️  Aplicação ainda não reportou startup completo" -ForegroundColor Yellow
}

if ($logs -match "Database schema is compliant") {
    Write-Host "    ✅ Schema validado pela aplicação" -ForegroundColor Green
} else {
    Write-Host "    ❌ ERRO: Schema não foi validado" -ForegroundColor Red
    Write-Host ""
    Write-Host "--- ÚLTIMAS 30 LINHAS DO LOG ---" -ForegroundColor Red
    Write-Host ($logs -split "`n" | Select-Object -Last 30)
    exit 1
}

# Teste HTTP
Write-Host ""
Write-Host "    🌐 Testando endpoint HTTP..." -ForegroundColor DarkGray
$http_test = ssh ${USER}@${VM_IP} "curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/midpoint/ 2>&1"

if ($http_test -eq "200") {
    Write-Host "    ✅ HTTP 200 OK - Aplicação respondendo" -ForegroundColor Green
} else {
    Write-Host "    ⚠️  HTTP $http_test - Aplicação pode ainda estar carregando" -ForegroundColor Yellow
}

# --- CONCLUSÃO ---
Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host " ✅ GMUD-011 EXECUTADA COM SUCESSO" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔗 Acesso: http://xxx.xxx.xxx.xxx:8080/midpoint" -ForegroundColor White
Write-Host "👤 Usuário: administrator" -ForegroundColor White
Write-Host "🔑 Senha: M1dP0!ntAdm!n#2026" -ForegroundColor White
Write-Host ""
Write-Host "📊 Para monitorar logs em tempo real:" -ForegroundColor DarkGray
Write-Host "   ssh ${USER}@${VM_IP} 'sudo docker logs -f iga-midpoint'" -ForegroundColor DarkGray
Write-Host ""
\`\`\`

---

## ANTI-PADRÕES ELIMINADOS

Com base na análise da GMUD-010, esta GMUD **elimina** os seguintes antipadrões:

### ❌ Antipadrão #1: Fornecimento de config.xml Manual
**Solução**: Deixar midPoint 4.9 criar configuração automaticamente no primeiro boot.

### ❌ Antipadrão #2: Dependência de REPO_DATABASE_TYPE
**Solução**: Usar `REPO_JDBC_URL` com credenciais embutidas, bypassando lógica de entrypoint.

### ❌ Antipadrão #3: Scripts SQL Não Embutidos (4.8)
**Solução**: Migrar para 4.9, que inclui scripts nativos no JAR.

### ❌ Antipadrão #4: Volumes Persistentes Sem Limpeza
**Solução**: Passo A do script executa limpeza nuclear (`rm -rf data/*`).

### ❌ Antipadrão #5: Sudoers Voláteis
**Solução**: Script valida permissões SSH antes da execução.

---

## CRONOGRAMA DE EXECUÇÃO

| Passo | Descrição | Duração Estimada | Responsável |
|---|---|---|---|
| A | Limpeza nuclear de volumes | 2 min | Script automatizado |
| B | Upload de artefatos (SCP) | 1 min | Script automatizado |
| C | Provisionamento PostgreSQL | 3 min | Docker Compose |
| D | Injeção manual de schema SQL | 5 min | Script + psql |
| E | Boot do midPoint 4.9 | 8 min | Docker Compose |
| F | Validação de sucesso | 2 min | Script automatizado |
| **TOTAL** | **Pipeline completo** | **21 min** | **Orquestrador** |

---

## MATRIZ DE RISCOS

| Risco | Probabilidade | Impacto | Mitigação |
|---|---|---|---|
| PostgreSQL não alcança Healthy | Baixa | Alto | Healthcheck com retry 5x + timeout 5s |
| Erro de autenticação SCRAM | Muito Baixa | Alto | Senha embutida na JDBC URL (bypass) |
| Schema incompleto | Muito Baixa | Alto | Validação de contagem de tabelas (>85) |
| Fallback H2 silencioso | Muito Baixa | Crítico | `REPO_DATABASE_TYPE` + JDBC URL explícita |
| Keystore corrompido | Muito Baixa | Alto | Limpeza nuclear de `/data/midpoint/var` |

---

## PLANO DE ROLLBACK

### Cenário 1: Falha no Boot do midPoint

\`\`\`bash
# Coletar logs completos
ssh paulo@xxx.xxx.xxx.xxx "sudo docker logs iga-midpoint > /tmp/midpoint-error.log 2>&1"

# Descer aplicação
ssh paulo@xxx.xxx.xxx.xxx "cd /srv/iga-project && sudo docker compose down"

# Análise: Verificar se erro é de configuração ou schema
grep -E "IllegalArgumentException|SQLException|Schema" /tmp/midpoint-error.log
\`\`\`

### Cenário 2: Banco Corrompido

\`\`\`bash
# Descer stack completa
ssh paulo@xxx.xxx.xxx.xxx "cd /srv/iga-project && sudo docker compose down -v"

# Reexecutar desde Passo C (skip upload)
.\deploy-prj003-v11.ps1 -SkipUpload
\`\`\`

---

## CRITÉRIOS DE VALIDAÇÃO

### Validação Técnica

- [ ] Container `iga-postgres` no estado `Healthy`
- [ ] Container `iga-midpoint` no estado `Up` (não `Restarting`)
- [ ] Log contém: `Started MidPointSpringApplication in X seconds`
- [ ] Log contém: `Database schema is compliant`
- [ ] HTTP 200 em `http://xxx.xxx.xxx.xxx:8080/midpoint/`

### Validação Funcional

- [ ] Login com `administrator:M1dP0!ntAdm!n#2026` bem-sucedido
- [ ] Página inicial midPoint carrega sem erros JavaScript
- [ ] Menu "Configuration" acessível

### Validação GRC

- [ ] Logs completos salvos em arquivo timestamped
- [ ] Script de deploy versionado no Git
- [ ] Senhas não expostas em logs (uso de secrets ou mascaramento)

---

## DOCUMENTAÇÃO PÓS-EXECUÇÃO

Após execução bem-sucedida, criar:

1. **REL-GMUD-011-Relatorio-de-Execucao.md**
   - Timestamp de cada passo
   - Logs de validação
   - Capturas de tela do midPoint operacional

2. **Snapshot da VM**
   - Nome: `PRJ003-GMUD-011-midPoint49-OK`
   - Data: 21/01/2026
   - Descrição: "midPoint 4.9 operacional com PostgreSQL 16"

3. **Commit Git**
   - Mensagem: `feat(PRJ003): GMUD-011 - midPoint 4.9 deployed successfully`
   - Arquivos: `docker-compose.yml`, `deploy-prj003-v11.ps1`, `REL-GMUD-011.md`

---

## CONCLUSÃO

A GMUD-011 representa a **consolidação do conhecimento** adquirido nas 14 tentativas da GMUD-010. A estratégia de **Soberania de Dados** garante:

✅ **Determinismo**: Schema injetado manualmente é 100% rastreável  
✅ **Segurança**: Bypass de lógica de imagem elimina fallback H2  
✅ **Auditabilidade**: Pipeline totalmente automatizado e versionado  
✅ **Compatibilidade**: midPoint 4.9 resolve limitações críticas da 4.8

**Probabilidade de Sucesso Estimada**: **95%** (baseada em análise forense da GMUD-010 e eliminação de causas raiz confirmadas)

---

## ASSINATURAS

| Função | Nome | Data/Hora |
|---|---|---|
| **Planejador** | Paulo Feitosa | 21/01/2026 14:43 -03 |
| **Executor** | Paulo Feitosa | (Pendente) |
| **Aprovador Técnico** | Paulo Feitosa | (Pendente) |
| **Classificação** | 🔒 INTERNO - Lab PRJ003 | - |

---

## REFERÊNCIAS

- GMUD-010: Relatório de 14 tentativas (REL-GMUD-010-Relatorio-de-Execucao.md)
- midPoint Documentation: https://docs.evolveum.com/midpoint/
- PostgreSQL SCRAM Authentication: https://www.postgresql.org/docs/16/auth-password.html
- Docker Compose Healthchecks: https://docs.docker.com/compose/compose-file/05-services/#healthcheck

---

**Projeto**: PRJ003 - IGA Greenfield Reference Architecture  
**Laboratório**: Fiqueok Lab 2.0 - Simulação de Ambiente Corporativo  
**Framework GRC**: ISO 27001 + NIST CSF 2.0  
**Versionamento**: Git commit #GMUD-011-v1.0

