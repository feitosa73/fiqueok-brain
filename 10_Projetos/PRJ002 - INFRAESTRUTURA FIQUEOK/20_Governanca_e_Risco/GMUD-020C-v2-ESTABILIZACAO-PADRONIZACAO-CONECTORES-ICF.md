<REDACTED_SECRET><REDACTED_SECRET>
GMUD-020C - ESTABILIZAÇÃO E PADRONIZAÇÃO DO STACK IAM (v2)
<REDACTED_SECRET><REDACTED_SECRET>
Projeto: PRJ-002 Identity Governance & Administration (IGA)
Título: Estabilização e Padronização do Stack IAM + Injeção de Conectores ICF
ID da Mudança: GMUD-020C-PRJ002
Tipo: CORRETIVA + CONFORMIDADE + ARQUITETURAL
Severidade: ALTA (Correção de Débito Técnico Crítico + Gap de Aplicação)
Responsável: Paulo Feitosa (Owner/CISO)
Orquestrador Técnico: Gemini Deep-Dive (CTO/Arch)
Análise Arquitetural: ChatGPT (Análise de Histórico de GMUDs)
Data de Execução: 05/01/2026
Status: 🟡 PLANEJADA - PRONTA PARA EXECUÇÃO
Versão: 2.0 (Incorpora descoberta crítica de conectores ICF)

<REDACTED_SECRET><REDACTED_SECRET>
1. CONTEXTO E JUSTIFICATIVA
<REDACTED_SECRET><REDACTED_SECRET>

## 1.1 Histórico de GMUDs Anteriores (Consolidado)

**Linha do Tempo de Falhas:**

```
GMUD-018 (Não documentada) → FALHA
   ↓
GMUD-019 (Não documentada) → FALHA
   ↓
GMUD-020 (04/01/2026) → ⚠️ PARCIAL
   - Fases 1-2: ✅ Backup + Remoção 4.10
   - Fase 3: ❌ Deploy 4.8.8 (72 tabelas Generic vs 130+ Native)
   ↓
GMUD-020B (05/01/2026) → ❌ ENCERRADA SEM SUCESSO
   - Estratégia: Clean Slate (remoção de volume + auto-init)
   - Descoberta: INCOMPATIBILIDADE DE INFRAESTRUTURA
     • PostgreSQL 9.5 (EOL) vs requisito 12+
     • Java 21 vs requisito Java 17
     • Scripts SQL ausentes/inacessíveis
   ↓
GMUD-020C v1 (05/01/2026 AM) → 🔄 REVISADA
   - Estratégia: Conformidade Técnica (PostgreSQL 15)
   - Gap Identificado: AUSÊNCIA DE CONECTORES ICF
```

## 1.2 Root Cause Analysis (RCA) - Análise Bicamadas

Após cruzamento de análises conduzidas por diferentes IAs, identificou-se
uma **Falha de Planejamento de Requisitos em Duas Camadas**:

### Camada 1: Infraestrutura (Identificada por Gemini Deep-Dive)

| Problema | Causa | Impacto |
|----------|-------|---------|
| **PostgreSQL 9.5 EOL** | Dialeto SQL incompatível | Scripts de init falhavam |
| **Java 21 (não cert.)** | Runtime não homologado | Instabilidade não mapeada |
| **Scripts SQL inacessíveis** | Imagem ou volume incorreto | Impossibilidade de criar schema |

**Diagnóstico Gemini:**
"O midPoint 4.8 tentava rodar em um chassi antigo (PostgreSQL 9.5).
Necessário upgrade de infraestrutura."

### Camada 2: Aplicação (Identificada por ChatGPT via Análise de Histórico)

**Contexto da Descoberta:**
Após análise do histórico completo de GMUDs (fornecidas via arquivo ZIP),
ChatGPT identificou um **gap crítico de aplicação**:

| Problema | Causa | Impacto |
|----------|-------|---------|
| **Conectores ICF ausentes** | midPoint Docker não traz drivers nativos | Impossibilidade de integrar com OrangeHRM |
| **ScriptedSQL/DatabaseTable** | Artefatos .jar não disponíveis | "Connector Not Found" ao configurar recursos |

**Diagnóstico ChatGPT:**
"O ambiente não possui os 'drivers' necessários para que o midPoint fale com
sistemas externos (OrangeHRM via MySQL). A ausência de connector-sql e
connector-db-table explica por que o downgrade 4.10 → 4.8 não resolveu o
problema de importação de identidades."

**Evidência Arquitetural:**
```
midPoint 4.8.8 (Docker)
   ↓ (tenta conectar)
OrangeHRM (MySQL)
   ↓ (requer)
connector-sql-1.6.0.0.jar ❌ AUSENTE
connector-db-table-1.6.0.0.jar ❌ AUSENTE
```

## 1.3 Diagnóstico Final Consolidado

O ambiente sofria de uma **"Falha de Planejamento de Requisitos"** em duas camadas:

1. **Camada de Infra (Gemini)**: Database incompatível (9.5 EOL)
2. **Camada de App (ChatGPT)**: Artefatos de integração inexistentes

**Metáfora Técnica Atualizada:**
"Tentávamos rodar um carro (midPoint) em um chassi antigo (PostgreSQL 9.5)
E SEM RODAS (conectores ICF). A GMUD-020C v2 corrige ambos os problemas."

## 1.4 Objetivo da GMUD-020C v2

Alinhar o ambiente aos **requisitos oficiais do fabricante** (Evolveum) em
DOIS NÍVEIS:

### Nível 1: Conformidade de Infraestrutura
- PostgreSQL 15 Alpine (certificado para midPoint 4.8.8)
- Java 17 LTS (embedado na imagem oficial)
- Variáveis de ambiente MP_DB_* (mapeamento correto de scripts)

### Nível 2: Conformidade de Aplicação
- Conectores ICF (Identity Connector Framework)
- connector-sql-1.6.0.0.jar (ScriptedSQL)
- connector-db-table-1.6.0.0.jar (DatabaseTable)
- Mapeamento de volume /opt/midpoint/var/icf-connectors

**Benefício Estratégico:**
Construir autoridade técnica ao demonstrar que troubleshooting eficaz requer
**análise em múltiplas camadas**, não apenas troca de versões de software.

## 1.5 Lições Aprendidas Aplicadas

✅ **L6 (Validação de Pré-requisitos)**: Checklist expandido (infra + app)
✅ **L7 (Clean Slate Expõe Débitos)**: Deep Clean mantido
✅ **L8 (Divergência Documentação/Realidade)**: Inventário As-Is atualizado
✅ **L12 (Verificação de Requisitos de Aplicação)**: NOVA LIÇÃO (ver Seção 10.2)
✅ **L13 (Design de Arquitetura vs. Troca de Versões)**: NOVA LIÇÃO (ver Seção 10.2)

<REDACTED_SECRET><REDACTED_SECRET>
2. ESCOPO E OBJETIVOS
<REDACTED_SECRET><REDACTED_SECRET>

## 2.1 Escopo da Mudança

**IN SCOPE:**
✅ Upgrade PostgreSQL 9.5 → 15 Alpine
✅ Validação de Java 17 LTS (embedado na imagem oficial)
✅ Deep Clean (remoção de volumes e cache de imagens)
✅ **🆕 Download de conectores ICF (ScriptedSQL + DatabaseTable)**
✅ **🆕 Configuração de volume icf-connectors no docker-compose.yml**
✅ Deploy midPoint 4.8.8 com configuração certificada
✅ Validação de inicialização nativa (130+ tabelas Sqale)
✅ **🆕 Validação de disponibilidade de conectores (via GUI midPoint)**
✅ Teste de login e dashboard

**OUT OF SCOPE:**
❌ Configuração de recursos externos (OrangeHRM, AD) - será GMUD-021
❌ Carga de massa de dados (7 personas)
❌ Configuração de SSL/TLS customizado
❌ Testes de provisioning automático

## 2.2 Objetivos Mensuráveis

| Objetivo | Meta | Validação |
|----------|------|-----------|
| **PostgreSQL Atualizado** | 15.x Alpine | `docker exec midpoint-db psql -V` |
| **Banco Inicializado** | > 130 tabelas | `psql -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name LIKE 'm_%';"` |
| **🆕 Conectores ICF Disponíveis** | 2 arquivos .jar | `ls -lh /opt/stack-iga/icf-connectors/*.jar` |
| **🆕 Conectores Carregados** | Visíveis na GUI | Configuração → Repositório → Conectores |
| **Container Healthy** | status healthy | `docker ps \| grep healthy` |
| **Tempo de Boot** | < 5 minutos | docker logs midpoint-server |
| **Login Funcional** | Dashboard visível | Browser: http://xxx.xxx.xxx.xxx:8080/midpoint/ |
| **Versão Confirmada** | 4.8.8 | Rodapé da interface web |

## 2.3 Benefícios Esperados

**Técnicos:**
- Stack homologado pelo vendor (suporte oficial disponível)
- **Capacidade de integração com sistemas externos (OrangeHRM)**
- Redução de 100% dos erros de dialeto SQL
- **Eliminação de "Connector Not Found" ao configurar recursos**

**Operacionais:**
- Ambiente IGA disponível para desenvolvimento de conectores
- Base estável para GMUD-021 (Conector OrangeHRM)
- **Redução de MTTR em futuras configurações de recursos**

**Conformidade (ISO 27001):**
- A.12.1.4: Software com suporte ativo (PostgreSQL 15 até 2027)
- A.14.2.1: Política de Desenvolvimento Seguro (sem versões EOL)
- A.12.1.2: Gestão de Mudanças baseada em evidências (RCA Bicamadas)
- **🆕 A.14.2.5: Princípios de Engenharia de Sistemas Seguros (Design Arquitetural)**

**Aprendizado (Living Lab):**
- Demonstração de troubleshooting metodológico (não apenas troca de versões)
- Aplicação prática de RCA em múltiplas camadas
- Portfolio técnico: "A Anatomia de um Troubleshooting de IGA"

<REDACTED_SECRET><REDACTED_SECRET>
3. NOVO DOCKER-COMPOSE.YML (VERSÃO ESTÁVEL 4.8.8 + ICF CONNECTORS)
<REDACTED_SECRET><REDACTED_SECRET>

Este arquivo foi ajustado para:
1. Utilizar PostgreSQL 15 Alpine (conformidade Evolveum)
2. **Mapear volume de conectores ICF (novo)**
3. Garantir persistência correta

```yaml
version: '3.8'

services:
  midpoint-db:
    image: postgres:15-alpine
    container_name: midpoint-db
    restart: always
    environment:
      POSTGRES_DB: midpoint
      POSTGRES_USER: midpoint
      POSTGRES_PASSWORD: password # Altere para senha forte em produção
    volumes:
      - midpoint-db-data:/var/lib/postgresql/data
    networks:
      - midpoint-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U midpoint"]
      interval: 10s
      timeout: 5s
      retries: 5

  midpoint-server:
    image: evolveum/midpoint:4.8.8
    container_name: midpoint-server
    restart: always
    environment:
      # Configurações do Repositório Nativo
      - MP_DB_HOST=midpoint-db
      - MP_DB_PORT=5432
      - MP_DB_NAME=midpoint
      - MP_DB_USER=midpoint
      - MP_DB_PASSWORD=password
      - MP_DB_SCHEMA=public
      - MP_DB_TYPE=postgresql
      # Força a inicialização se a DB estiver vazia
      - MP_SET_midpoint_repository_missingSchemaAction=create
      # Ajuste de Memória (Alinhado ao PC Gamer com 64GB RAM)
      - JAVA_OPTS=-Xms2g -Xmx4g
    ports:
      - "8080:8080"
      - "8443:8443"
    volumes:
      - midpoint-home:/opt/midpoint/var
      # 🆕 CRÍTICO: Mapeamento de conectores ICF
      - ./icf-connectors:/opt/midpoint/var/icf-connectors
    depends_on:
      midpoint-db:
        condition: service_healthy
    networks:
      - midpoint-net

networks:
  midpoint-net:
    driver: bridge

volumes:
  midpoint-db-data:
  midpoint-home:
```

## Mudanças Críticas em Relação à v1

| Componente | GMUD-020C v1 | GMUD-020C v2 (nova) | Justificativa |
|------------|--------------|---------------------|---------------|
| **Volumes midPoint** | Apenas midpoint-home | + icf-connectors | Carregar conectores .jar no startup |
| **Pré-requisitos** | Infra (DB, Java) | + Conectores ICF | Gap de aplicação identificado |
| **Validações** | 10 testes | 12 testes (+2) | Validar conectores carregados |
| **Tempo Estimado** | 21 min | 28 min (+7) | Download de .jar + validação GUI |

<REDACTED_SECRET><REDACTED_SECRET>
4. PRÉ-REQUISITOS E VALIDAÇÕES INICIAIS
<REDACTED_SECRET><REDACTED_SECRET>

## 4.1 Checklist de Auditoria (Obrigatório)

### Hardware e Software Base

□ **Docker Engine**: Versão 20.10+ instalada
  ```bash
  docker --version
  # Esperado: Docker version 20.10.x ou superior
  ```

□ **Docker Compose**: Versão 2.0+ instalada
  ```bash
  docker compose version
  # Esperado: Docker Compose version v2.x.x
  ```

□ **RAM Disponível**: Mínimo 8GB livres
  ```bash
  free -h | grep Mem
  # Esperado: > 8GB available
  ```

□ **Espaço em Disco**: Mínimo 10GB livres
  ```bash
  df -h /var/lib/docker
  # Esperado: > 10GB disponível
  ```

□ **🆕 Conectividade Nexus Evolveum**: Acesso ao repositório de conectores
  ```bash
  curl -I https://nexus.evolveum.com/nexus/content/groups/public/
  # Esperado: HTTP 200 OK
  ```

### Validação de Estado Atual

□ **Containers Existentes**: Verificar status
  ```bash
  docker ps -a | grep midpoint
  # Documentar output (pode estar em crash loop)
  ```

□ **Volumes Existentes**: Inventariar
  ```bash
  docker volume ls | grep midpoint
  # Documentar volumes a serem removidos
  ```

□ **🆕 Diretório de Conectores**: Verificar existência
  ```bash
  ls -ld /opt/stack-iga/icf-connectors
  # Se não existir, será criado na Fase 1
  ```

## 4.2 Inventário As-Is (Lição L8)

| Componente | Estado Atual (Pré-GMUD-020C v2) |
|------------|----------------------------------|
| **midpoint-server** | CrashLoopBackOff (desde GMUD-020B) |
| **midpoint-db** | Up, PostgreSQL 9.5.25 (EOL) |
| **midpoint-db-data** | Vazio (removido em GMUD-020B) |
| **midpoint_home** | Estado indefinido |
| **🆕 icf-connectors/** | ❌ NÃO EXISTE (gap de aplicação) |
| **OrangeHRM** | Up 3+ days (não será afetado) |

## 4.3 Delta de Mudança (As-Is → To-Be)

| Item | As-Is | To-Be (020C v2) | Ação |
|------|-------|-----------------|------|
| **PostgreSQL** | 9.5.25 | 15.x Alpine | Substituir container + volume |
| **Java** | 21.0.6 | 17 LTS (embed) | Usar imagem oficial evolveum |
| **Configuração** | Manual/indefinida | Variáveis MP_DB_* | Editar docker-compose.yml |
| **🆕 Conectores ICF** | Ausentes | .jar baixados | wget + volume mapping |
| **Volumes** | Corrompidos/antigos | Novos (clean) | Deep Clean |

<REDACTED_SECRET><REDACTED_SECRET>
5. PROCEDIMENTO DE EXECUÇÃO
<REDACTED_SECRET><REDACTED_SECRET>

## FASE 0: PREPARAÇÃO DE CONECTORES ICF (NOVA) - Tempo: 7 min

### Objetivo
Baixar e preparar os artefatos de integração (conectores ICF) necessários para
que o midPoint possa se conectar a sistemas externos (OrangeHRM via MySQL).

### Passo 0.1: Criar Diretório de Conectores

**Comando:**
```bash
mkdir -p /opt/stack-iga/icf-connectors
cd /opt/stack-iga/icf-connectors
```

**Validação:**
```bash
ls -ld /opt/stack-iga/icf-connectors
# Esperado: drwxr-xr-x ... /opt/stack-iga/icf-connectors
```

### Passo 0.2: Download do Conector ScriptedSQL

**Comando:**
```bash
wget https://nexus.evolveum.<REDACTED_SECRET>veum/polygon/connector-sql/1.6.0.0/connector-sql-1.6.0.0.jar -P /opt/stack-iga/icf-connectors/
```

**Validação:**
```bash
ls -lh /opt/stack-iga/icf-connectors/connector-sql-1.6.0.0.jar
# Esperado: Arquivo com tamanho ~500KB-1MB
```

**Se download falhar:**
```bash
# Tentar URL alternativo (GitHub Releases da Evolveum Polygon)
wget https://github.com/Evolveum/connector-sql/releases/download/v1.6.0.0/connector-sql-1.6.0.0.jar -P /opt/stack-iga/icf-connectors/
```

### Passo 0.3: Download do Conector DatabaseTable

**Comando:**
```bash
wget https://nexus.evolveum.<REDACTED_SECRET>veum/polygon/connector-db-table/1.6.0.0/connector-db-table-1.6.0.0.jar -P /opt/stack-iga/icf-connectors/
```

**Validação:**
```bash
ls -lh /opt/stack-iga/icf-connectors/connector-db-table-1.6.0.0.jar
# Esperado: Arquivo com tamanho ~300KB-800KB
```

### Passo 0.4: Verificar Integridade dos Arquivos

**Comando:**
```bash
file /opt/stack-iga/icf-connectors/*.jar
```

**Resultado Esperado:**
```
connector-sql-1.6.0.0.jar:      Java archive data (JAR)
connector-db-table-1.6.0.0.jar: Java archive data (JAR)
```

**Se output for diferente (ex: HTML, ASCII text):**
❌ FALHA - Download corrompido
→ Remover arquivos: `rm /opt/stack-iga/icf-connectors/*.jar`
→ Repetir Passos 0.2 e 0.3

### Passo 0.5: Configurar Permissões

**Comando:**
```bash
chmod 644 /opt/stack-iga/icf-connectors/*.jar
chown root:root /opt/stack-iga/icf-connectors/*.jar
```

**Validação:**
```bash
ls -l /opt/stack-iga/icf-connectors/
# Esperado: -rw-r--r-- 1 root root ... connector-*.jar
```

### Critério de Aceite FASE 0:
✅ Diretório /opt/stack-iga/icf-connectors criado
✅ 2 arquivos .jar baixados (connector-sql + connector-db-table)
✅ Arquivos identificados como Java JAR (comando `file`)
✅ Permissões configuradas (644)
✅ Tempo < 10 minutos

---

## FASE 1: DEEP CLEAN (LIMPEZA GERAL) - Tempo: 5 min

### Objetivo
Garantir que NENHUM vestígio da configuração anterior (PostgreSQL 9.5, volumes
corrompidos, cache de imagens) interfira na nova instalação.

### Passo 1.1: Parar e Remover Containers + Volumes

**Comando:**
```bash
cd /opt/stack-iga/  # ou diretório onde está o docker-compose.yml
docker compose down -v
```

**⚠️ CRÍTICO**: O parâmetro `-v` remove TODOS os volumes nomeados.

**Validação:**
```bash
docker ps -a | grep midpoint
# Esperado: Nenhuma saída

docker volume ls | grep midpoint
# Esperado: Nenhuma saída
```

### Passo 1.2: Limpeza de Cache de Imagens

**Comando:**
```bash
docker image rm postgres:9.5 evolveum/midpoint:4.8.8-alpine -f 2>/dev/null
```

**Validação:**
```bash
docker images | grep -E "postgres|midpoint"
# Esperado: Apenas imagens que serão baixadas (15-alpine, 4.8.8)
```

### Critério de Aceite FASE 1:
✅ Nenhum container midpoint-* existente
✅ Nenhum volume midpoint-* existente
✅ Imagens antigas removidas
✅ Tempo < 7 minutos

---

## FASE 2: CONFIGURAÇÃO DO NOVO STACK - Tempo: 5 min

### Passo 2.1: Backup do docker-compose.yml Atual

**Comando:**
```bash
cp docker-compose.yml docker-compose.yml.bak_020c_v1_$(date +%Y%m%d_%H%M)
```

### Passo 2.2: Substituir docker-compose.yml

**Editar manualmente (nano/vim):**
```bash
nano docker-compose.yml
# Copiar o conteúdo da Seção 3 deste documento
# ⚠️ ATENÇÃO: Incluir a linha de volume icf-connectors
```

**🔍 Verificar linha crítica:**
```yaml
    volumes:
      - midpoint-home:/opt/midpoint/var
      - ./icf-connectors:/opt/midpoint/var/icf-connectors  # ← ESTA LINHA
```

### Passo 2.3: Validar Sintaxe YAML

**Comando:**
```bash
docker compose config
```

**Resultado Esperado:**
- Nenhum erro de sintaxe
- Volume icf-connectors aparece no output

### Passo 2.4: Criar Symlink (se necessário)

**Se icf-connectors estiver em /opt/stack-iga/:**
```bash
cd /opt/stack-iga/  # Diretório do docker-compose.yml
ln -s /opt/stack-iga/icf-connectors ./icf-connectors
```

**Validação:**
```bash
ls -l icf-connectors
# Esperado: lrwxrwxrwx ... icf-connectors -> /opt/stack-iga/icf-connectors
```

### Critério de Aceite FASE 2:
✅ Backup criado
✅ docker-compose.yml atualizado
✅ Validação YAML sem erros
✅ Volume icf-connectors mapeado
✅ Tempo < 7 minutos

---

## FASE 3: DEPLOY DO NOVO STACK - Tempo: 5-7 min

### Passo 3.1: Iniciar Containers

**Comando:**
```bash
docker compose up -d
```

**Output Esperado:**
```
[+] Running 5/5
 ✔ Network midpoint-net           Created
 ✔ Volume "midpoint-db-data"      Created
 ✔ Volume "midpoint_home"         Created
 ✔ Container midpoint-db          Started
 ✔ Container midpoint-server      Started
```

### Passo 3.2: Monitoramento em Tempo Real

**Comando:**
```bash
docker compose logs -f midpoint-server
```

**Marcos de Progresso (Teste de Mesa):**

| Tempo | Ator | Ação | Resultado Esperado |
|-------|------|------|--------------------|
| 0-1 min | Docker | Pull postgres:15-alpine | Imagem baixada |
| 1-2 min | Container DB | Inicialização PostgreSQL | Base midpoint criada (UTF-8) |
| 2-3 min | Container App | SchemaChecker inicia | Detecta DB vazia |
| 3-4 min | App → DB | applyScript | Execução postgresql-4.8-all.sql |
| 4-5 min | Spring Boot | Contexto de Aplicação | Tomcat inicia (porta 8080) |
| **4:30-5 min** | **🆕 ICF Loader** | **Carregamento de conectores** | **2 conectores detectados em /opt/midpoint/var/icf-connectors** |
| 5 min | Sistema | Startup completo | "midPoint started" |

### Mensagens de Log Esperadas (NOVO - Conectores)

```
[04:30] INFO  [main] (ConnectorFactory) - Scanning for connectors in: /opt/midpoint/var/icf-connectors
[04:35] INFO  [main] (ConnectorFactory) - Found connector: connector-sql-1.6.0.0.jar
[04:35] INFO  [main] (ConnectorFactory) - Found connector: connector-db-table-1.6.0.0.jar
[04:40] INFO  [main] (ConnectorFactory) - Successfully loaded 2 ICF connectors
```

**Se mensagem de erro aparecer:**
```
ERROR [main] (ConnectorFactory) - Failed to load connector from: /opt/midpoint/var/icf-connectors/connector-*.jar
```
❌ FALHA - Validar:
1. Permissões dos .jar (devem ser 644)
2. Integridade dos arquivos (comando `file`)
3. Volume mapeado corretamente no docker-compose.yml

### Critério de Aceite FASE 3:
✅ Mensagem "midPoint started" nos logs
✅ **🆕 Mensagem "Successfully loaded 2 ICF connectors"**
✅ Nenhuma mensagem FATAL ou ERROR crítico
✅ Container não reinicia (sem crash loop)
✅ Tempo < 7 minutos

---

## FASE 4: VALIDAÇÃO DE INTEGRIDADE - Tempo: 5 min

### Passo 4.1: Validar Versão PostgreSQL

**Comando:**
```bash
docker exec midpoint-db psql -V
```

**Resultado Esperado:**
```
psql (PostgreSQL) 15.x (Debian 15.x-x-alpine)
```

### Passo 4.2: Validar Contagem de Tabelas (Native Sqale)

**Comando:**
```bash
docker exec midpoint-db psql -U midpoint -d midpoint -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'm_%';"
```

**Resultado Esperado:**
```
 count
-------
   132
(1 row)
```

### Passo 4.3: Validar Versão do Schema

**Comando:**
```bash
docker exec midpoint-db psql -U midpoint -d midpoint -c "SELECT databaseschemaversion FROM m_global_metadata;"
```

**Resultado Esperado:**
```
 databaseschemaversion
-----------------------
 4.8
(1 row)
```

### Passo 4.4: 🆕 Validar Conectores no Filesystem

**Comando:**
```bash
docker exec midpoint-server ls -lh /opt/midpoint/var/icf-connectors/
```

**Resultado Esperado:**
```
total 1.2M
-rw-r--r-- 1 root root 800K ... connector-db-table-1.6.0.0.jar
-rw-r--r-- 1 root root 500K ... connector-sql-1.6.0.0.jar
```

**Se diretório vazio:**
❌ FALHA - Volume não foi mapeado corretamente
→ Verificar docker-compose.yml (Seção 3)
→ Verificar symlink (Fase 2, Passo 2.4)

### Critério de Aceite FASE 4:
✅ PostgreSQL 15.x confirmado
✅ Banco com > 130 tabelas
✅ Versão schema: 4.8
✅ **🆕 2 arquivos .jar visíveis no container**
✅ Tempo < 7 minutos

---

## FASE 5: VALIDAÇÃO DE DISPONIBILIDADE E CONECTORES - Tempo: 5 min

### Passo 5.1: Health Check HTTP

**Comando:**
```bash
curl -I http://xxx.xxx.xxx.xxx:8080/midpoint/
```

**Resultado Esperado:**
```
HTTP/1.1 302 
Location: http://xxx.xxx.xxx.xxx:8080/midpoint/login
```

### Passo 5.2: Validação Manual (Navegador)

1. **Abrir navegador**
2. **URL**: http://xxx.xxx.xxx.xxx:8080/midpoint/
3. **Login**: administrator / 5ecr3t

**Checklist Visual:**
□ Dashboard visível
□ Versão 4.8.8 no rodapé
□ Menu lateral presente

### Passo 5.3: 🆕 Validar Conectores na GUI (CRÍTICO)

**Caminho na Interface:**
```
Configuração (⚙️) → Repositório → Conectores
```

**Resultado Esperado:**
Listagem de conectores disponíveis deve incluir:

| Nome do Conector | Versão | Tipo | Status |
|-----------------|--------|------|--------|
| **ScriptedSQL Connector** | 1.6.0.0 | com.evolveum.polygon.connector.sql.ScriptedSQLConnector | ✅ Disponível |
| **DatabaseTable Connector** | 1.6.0.0 | org.identityconnectors.databasetable.DatabaseTableConnector | ✅ Disponível |

**Screenshot Obrigatório:**
- Capturar tela da lista de conectores
- Salvar em: `/backup/GMUD-020C-v2/screenshots/05_conectores_disponiveis.png`

**Se lista estiver vazia:**
❌ FALHA CRÍTICA - Conectores não foram carregados
→ Revisar logs: `docker logs midpoint-server | grep -i connector`
→ Validar Fase 4, Passo 4.4
→ Ativar Rollback se não resolver em 10 minutos

### Passo 5.4: 🆕 Teste de Criação de Recurso (Opcional)

**Objetivo:** Validar que o conector pode ser selecionado ao criar um recurso

**Caminho:**
```
Configuração (⚙️) → Recursos → Novo Recurso
```

**Ação:**
1. Clicar em "Criar novo recurso"
2. No campo "Tipo de Conector", buscar por "SQL" ou "Database"
3. Verificar se "ScriptedSQL" e "DatabaseTable" aparecem nas opções

**Resultado Esperado:**
□ ScriptedSQL Connector aparece na lista suspensa
□ DatabaseTable Connector aparece na lista suspensa

**⚠️ IMPORTANTE:** NÃO concluir a criação do recurso (será feito na GMUD-021).
   Apenas validar que o conector está disponível.

### Critério de Aceite FASE 5:
✅ Curl retorna HTTP 200 ou 302
✅ Container status: healthy
✅ Login funcional
✅ **🆕 2 conectores ICF visíveis na GUI**
✅ **🆕 Screenshot capturado**
✅ **🆕 Conectores selecionáveis ao criar recurso**
✅ Tempo < 7 minutos

<REDACTED_SECRET><REDACTED_SECRET>
6. MATRIZ DE VALIDAÇÃO CONSOLIDADA
<REDACTED_SECRET><REDACTED_SECRET>

| # | Teste | Comando/Ação | Resultado Esperado | Status |
|---|-------|--------------|-------------------|--------|
| 1 | **PostgreSQL Versão** | `docker exec midpoint-db psql -V` | 15.x Alpine | □ |
| 2 | **Boot do midPoint** | `docker logs midpoint-server \| grep "started"` | "midPoint started" | □ |
| 3 | **Contagem de Tabelas** | `psql COUNT(*) WHERE table_name LIKE 'm_%'` | > 130 tabelas | □ |
| 4 | **Versão do Schema** | `psql SELECT databaseschemaversion` | 4.8 | □ |
| 5 | **🆕 Conectores no Filesystem** | `docker exec ls /opt/midpoint/var/icf-connectors/` | 2 arquivos .jar | □ |
| 6 | **🆕 Conectores em Logs** | `docker logs \| grep "Successfully loaded 2 ICF connectors"` | Mensagem presente | □ |
| 7 | **HTTP Health Check** | `curl -I http://xxx.xxx.xxx.xxx:8080/midpoint/` | HTTP 200 ou 302 | □ |
| 8 | **Container Status** | `docker ps \| grep midpoint-server` | Up (healthy) | □ |
| 9 | **Login Web** | Browser login | Tela de Login visível | □ |
| 10 | **Autenticação** | administrator/5ecr3t | Dashboard visível | □ |
| 11 | **🆕 Conectores na GUI** | Configuração → Repositório → Conectores | ScriptedSQL + DatabaseTable | □ |
| 12 | **🆕 Conectores Selecionáveis** | Criar Recurso → Tipo de Conector | Opções disponíveis | □ |

**Taxa de Sucesso Requerida**: 12/12 testes (100%)

<REDACTED_SECRET><REDACTED_SECRET>
7. ROLLBACK PLAN
<REDACTED_SECRET><REDACTED_SECRET>

## 7.1 Critérios de Ativação de Rollback

Ativar rollback SE:

❌ Fase 0: Falha no download de conectores após 3 tentativas
❌ Fase 3: Container permanece unhealthy por > 10 minutos
❌ Fase 4: Tabelas críticas ausentes
❌ **🆕 Fase 5: Conectores ICF não aparecem na GUI**

## 7.2 Rollback Completo via Checkpoint Hyper-V

**Tempo Estimado**: 5-8 minutos

**PowerShell (host Hyper-V):**
```powershell
Stop-VM -Name "IGA-P-01" -Force
Restore-VMSnapshot -Name "IGA-P-01_Checkpoint_GMUD-020" -VMName "IGA-P-01" -Confirm:$false
Start-VM -Name "IGA-P-01"
```

**Resultado:**
- Retorno ao estado pré-GMUD-020 (midPoint 4.10)
- OrangeHRM preservado
- Conectores ICF não estarão disponíveis (situação anterior)

## 7.3 Rollback Parcial (Apenas Docker)

**Tempo Estimado**: 3-5 minutos

**Comandos:**
```bash
docker compose down -v
cp docker-compose.yml.bak_020c_v1_* docker-compose.yml
# Não subir novamente (aguardar GMUD-020D)
```

<REDACTED_SECRET><REDACTED_SECRET>
8. ANÁLISE DE RISCO E MITIGAÇÃO
<REDACTED_SECRET><REDACTED_SECRET>

## 8.1 Riscos Técnicos

| Risco | Prob. | Impacto | Mitigação |
|-------|-------|---------|-----------|
| **R1: PostgreSQL 15 incompatível** | MUITO BAIXA | ALTO | Versão certificada. Rollback disponível. |
| **R2: 🆕 Download de .jar falha** | BAIXA | MÉDIO | URLs alternativas (GitHub). Validação de integridade. |
| **R3: 🆕 Conectores não carregam** | MÉDIA | ALTO | Validação de permissões e volume mapping. |
| **R4: Timeout download imagens** | BAIXA | BAIXO | Executar docker pull manualmente. |

## 8.2 Controles ISO 27001

| Controle | Descrição | Evidência |
|----------|-----------|-----------|
| **A.12.1.2 - Gestão de Mudanças** | GMUD baseada em RCA Bicamadas | Este documento |
| **A.14.2.1 - Desenvolvimento Seguro** | Eliminação de EOL | PostgreSQL 15 |
| **🆕 A.14.2.5 - Engenharia de Sistemas** | Design arquitetural completo | Conectores ICF incluídos |
| **A.16.1.7 - Lições Aprendidas** | L12, L13 (novas) | Seção 10.2 |

<REDACTED_SECRET><REDACTED_SECRET>
9. MÉTRICAS E KPIs
<REDACTED_SECRET><REDACTED_SECRET>

## 9.1 Tempo de Execução (RTO)

| Fase | Planejado | Máximo | Buffer |
|------|-----------|--------|--------|
| **Fase 0: 🆕 Conectores** | 7 min | 10 min | +3 min |
| Fase 1: Deep Clean | 5 min | 7 min | +2 min |
| Fase 2: Configuração | 5 min | 7 min | +2 min |
| Fase 3: Deploy | 5 min | 7 min | +2 min |
| Fase 4: Validação DB | 5 min | 7 min | +2 min |
| Fase 5: 🆕 Valid. Conectores | 5 min | 7 min | +2 min |
| **TOTAL** | **32 min** | **45 min** | **+13 min** |

## 9.2 Comparação de GMUDs (Evolução)

| Métrica | GMUD-020 | GMUD-020B | GMUD-020C v1 | **GMUD-020C v2** |
|---------|----------|-----------|--------------|------------------|
| **Taxa de Sucesso** | 66.7% | 40% | N/A | **100% (objetivo)** |
| **PostgreSQL** | 9.5 EOL | 9.5 EOL | 15.x | **15.x** |
| **🆕 Conectores ICF** | N/A | N/A | ❌ Ausente | **✅ Incluído** |
| **Duração** | 35 min | 22 min | 21 min | **32 min (+11)** |
| **Validações** | 5 | 10 | 10 | **12 (+2)** |

<REDACTED_SECRET><REDACTED_SECRET>
10. LIÇÕES APRENDIDAS (CONSOLIDAÇÃO FINAL)
<REDACTED_SECRET><REDACTED_SECRET>

## 10.1 Aplicação de Lições L1-L11

| ID | Lição | Aplicação na GMUD-020C v2 |
|----|-------|---------------------------|
| L6 | Validação de Pré-requisitos | Checklist expandido (infra + app) |
| L7 | Clean Slate Diagnóstico | Deep Clean mantido |
| L8 | Inventário As-Is | Incluído gap de conectores |

## 10.2 Novas Lições (L12-L13)

### L12: Verificação de Requisitos de Aplicação

**Contexto:**
GMUDs 020 e 020B focaram APENAS em infraestrutura (PostgreSQL, Java).
ChatGPT, ao analisar histórico completo, identificou gap de aplicação:
conectores ICF ausentes.

**Aprendizado:**
"Troubleshooting eficaz requer análise em MÚLTIPLAS CAMADAS:
- Camada 1: Infraestrutura (DB, runtime, rede)
- Camada 2: Aplicação (libraries, drivers, plugins)
- Camada 3: Configuração (variáveis, mapeamentos, permissões)"

**Ação Preventiva:**
Criar **Checklist de Requisitos de Aplicação** para GMUDs futuras:

```markdown
## Checklist de Requisitos de Aplicação (Executar ANTES de GMUD)

### Para midPoint
□ Conectores ICF necessários identificados (ScriptedSQL, LDAP, AD, etc.)
□ Arquivos .jar baixados e validados
□ Volume icf-connectors mapeado no docker-compose.yml
□ Permissões configuradas (644)

### Para OrangeHRM
□ Plugins necessários identificados
□ Extensões PHP validadas (versão compatível)
□ Conectores de autenticação externa (LDAP, SAML) se aplicável

### Para PKI
□ Certificados raiz disponíveis
□ Scripts de CRL (Certificate Revocation List) configurados
```

**Responsável:** Arquitetura (Gemini) + Operações (Paulo)
**Prazo:** Implementar antes de GMUD-021
**Referência:** ISO 27001 A.14.2.5 (Princípios de Engenharia de Sistemas)

### L13: Design de Arquitetura vs. Troca de Versões

**Contexto:**
GMUDs 018, 019, 020, 020B tentaram resolver problemas através de:
- Downgrade de versão (4.10 → 4.8)
- Upgrade de banco (9.5 → 15)
- Troca de imagem (Alpine → Standard)

**Descoberta:**
Nenhuma dessas ações resolveria o problema REAL: ausência de conectores ICF.

**Aprendizado:**
"Trocar versões de software sem entender a ARQUITETURA COMPLETA é como
trocar pneus de um carro sem rodas. O problema não está na versão, mas
no DESIGN INCOMPLETO do ambiente."

**Aplicação Futura:**
Antes de GMUDs de mudança de versão, executar:

1. **Análise de Dependências:**
   - Listar TODOS os componentes necessários (não apenas o principal)
   - Exemplo: midPoint requer DB + Java + Conectores + (opcionalmente) LDAP

2. **Diagrama Arquitetural:**
   - Desenhar fluxo de dados (ex: midPoint → Conector → OrangeHRM)
   - Identificar pontos de integração
   - Validar que TODOS os artefatos estão presentes

3. **Teste de Mesa (Dry Run):**
   - Simular fluxo lógico ANTES de executar GMUD
   - Identificar falhas em laboratório, não em produção

**Exemplo de Aplicação:**
Antes de GMUD-021 (Conector OrangeHRM), validar:
- ✅ midPoint 4.8.8 operacional (GMUD-020C v2)
- ✅ Conectores ICF disponíveis (ScriptedSQL)
- ✅ OrangeHRM com base MySQL acessível
- ✅ Credenciais de acesso documentadas
- ✅ Scripts de sincronização (Groovy/JavaScript) testados em sandbox

**Benefício para Living Lab:**
Esta lição é o **diferencial em entrevistas**:
"Não apenas configurei o midPoint. Identifiquei, através de análise
arquitetural, que o ambiente tinha um gap de aplicação (conectores ICF)
que nenhuma troca de versão resolveria. Isso demonstra senioridade técnica:
entender o PORQUÊ, não apenas o COMO."

**Responsável:** Paulo Feitosa (portfólio técnico)
**Prazo:** Documentar em post LinkedIn até 10/01/2026
**Referência:** Portfolio: "A Anatomia de um Troubleshooting de IGA"

<REDACTED_SECRET><REDACTED_SECRET>
11. COMUNICAÇÃO E STAKEHOLDERS
<REDACTED_SECRET><REDACTED_SECRET>

## 11.1 Notificação Pré-GMUD (T-2h)

**Assunto:** GMUD-020C v2 - Estabilização Stack IAM + Conectores ICF

**Mensagem:**
```
Será realizada correção de infraestrutura E aplicação do ambiente midPoint:

Data/Hora: 05/01/2026 às [HORÁRIO] BRT
Duração Estimada: 32 minutos
Impacto: Indisponibilidade temporária do midPoint

Mudanças Críticas:
✅ PostgreSQL 9.5 (EOL) → 15 Alpine (certificado)
✅ 🆕 Injeção de Conectores ICF (ScriptedSQL + DatabaseTable)
✅ Configuração via variáveis MP_DB_*
✅ Deep Clean (remoção de volumes corrompidos)

Descoberta Técnica:
Através de análise arquitetural (ChatGPT + histórico de GMUDs),
identificou-se gap de aplicação: conectores ICF ausentes.
Esta GMUD corrige AMBAS as camadas (infra + app).

Contexto: Correção de débito técnico bicamadas (REL-GMUD-020B)
```

## 11.2 Notificação Pós-GMUD (T+0)

**Mensagem de Sucesso:**
```
Assunto: ✅ GMUD-020C v2 CONCLUÍDA - Stack IAM Estabilizado

GMUD-020C v2 executada com sucesso em [XX] minutos.

Sistema Disponível:
✅ midPoint 4.8.8: http://xxx.xxx.xxx.xxx:8080/midpoint/
   - Login: administrator / 5ecr3t
   - PostgreSQL: 15.x Alpine (certificado)
   - Banco: 130+ tabelas Native Sqale
   - 🆕 Conectores ICF: ScriptedSQL 1.6.0.0 + DatabaseTable 1.6.0.0

Melhorias Implementadas:
- Upgrade PostgreSQL 9.5 (EOL) → 15.x
- 🆕 Injeção de artefatos de integração (conectores ICF)
- Configuração certificada pelo vendor
- Análise arquitetural bicamadas (infra + app)

Descoberta Técnica:
A falha das GMUDs anteriores não era apenas de infraestrutura,
mas de DESIGN INCOMPLETO: conectores ICF ausentes.
Lições L12 e L13 documentadas no relatório.

Próximos Passos:
- GMUD-021: Configuração de Recurso OrangeHRM (AGORA VIÁVEL)
- Relatório: REL-GMUD-020C-v2.md
- Post LinkedIn: "A Anatomia de um Troubleshooting de IGA"
```

<REDACTED_SECRET><REDACTED_SECRET>
12. PRÓXIMOS PASSOS (PÓS-GMUD-020C v2)
<REDACTED_SECRET><REDACTED_SECRET>

## 12.1 Imediato (Próximas 24h)

□ Monitoramento contínuo (docker logs -f midpoint-server)
□ Validar que conectores permanecem visíveis após restart
□ Elaborar REL-GMUD-020C-v2.md
□ Criar checkpoint Hyper-V: IGA-P-01_Checkpoint_POST-GMUD-020C-v2
□ **🆕 Iniciar planejamento GMUD-021 (Conector OrangeHRM)**

## 12.2 Curto Prazo (1 semana)

□ GMUD-021: Configuração de Recurso OrangeHRM no midPoint
□ Validar sincronização de identidades (importação de usuários)
□ Criar matriz de compatibilidade (Lição L11)
□ Atualizar documentação As-Built (topologia + conectores)
□ **🆕 Escrever post LinkedIn (Lição L13)**

## 12.3 Médio Prazo (1 mês)

□ GMUD-022: Integração midPoint ↔ Active Directory
□ Implementação de massa de dados (7 personas brasileiras)
□ Configuração de políticas de provisionamento
□ Testes de carga (performance com conectores ativos)

## 12.4 Portfolio Técnico (Living Lab)

□ Documentar descoberta de conectores ICF (estudo de caso)
□ Criar apresentação: "A Anatomia de um Troubleshooting de IGA"
□ Publicar artigo técnico (Medium/LinkedIn)
□ Adicionar ao portfolio: "Análise Arquitetural Bicamadas"

<REDACTED_SECRET><REDACTED_SECRET>
13. APROVAÇÕES E ASSINATURAS
<REDACTED_SECRET><REDACTED_SECRET>

## 13.1 Elaboração e Revisão

**Elaborado por:**
- Gemini Deep-Dive (CTO/Arch) - Análise de Infraestrutura
- ChatGPT - Análise Arquitetural (Gap de Conectores ICF)
Data: 05/01/2026 13:17 BRT
Versão: 2.0 (Incorpora descoberta de conectores ICF)

**Contexto da Descoberta:**
Através de análise de histórico completo de GMUDs (ZIP fornecido), ChatGPT
identificou gap crítico de aplicação que explicava falhas consecutivas.
Esta versão implementa correção bicamadas (infra + app).

**Revisado por:**
Nome: Paulo Feitosa (Owner/CISO)
Data: ___/___/______
Assinatura: _________________________________

## 13.2 Aprovação de Mudança

**Change Manager:**
Nome: Paulo Feitosa
Data de Aprovação: ___/___/______

**Decisão**: □ APROVADA   □ REJEITADA   □ ADIADA

**Justificativa (se rejeitada/adiada):**
_________________________________________________________________

## 13.3 Execução

**Executor Técnico:**
Nome: Paulo Feitosa (IGA-P-01)
Data de Execução: ___/___/______
Horário de Início: ___:___ BRT
Horário de Término: ___:___ BRT

**Resultado**: □ SUCESSO   □ SUCESSO PARCIAL   □ ROLLBACK

**Observações:**
_________________________________________________________________

<REDACTED_SECRET><REDACTED_SECRET>
14. REFERÊNCIAS
<REDACTED_SECRET><REDACTED_SECRET>

## Documentos Relacionados

- **REL-GMUD-020.md**: Implementação Parcial (contexto)
- **REL-GMUD-020B.md**: Encerramento Sem Sucesso (RCA Infra)
- **GMUD-020C v1.md**: Primeira versão (apenas infra)
- **Análise ChatGPT**: Histórico de GMUDs (ZIP) - Gap de Conectores ICF

## Referências Técnicas

- midPoint 4.8 System Requirements:
  https://docs.evolveum.com/midpoint/4.8/install/system-requirements/

- ICF Connectors Repository:
  https://nexus.evolveum.<REDACTED_SECRET>veum/polygon/

- Connector SQL Documentation:
  https://docs.evolveum.com/connectors/connectors/com.evolveum.polygon.connector.sql.ScriptedSQLConnector/

- Connector DatabaseTable Documentation:
  https://docs.evolveum.com/connectors/connectors/org.identityconnectors.databasetable.DatabaseTableConnector/

## Contatos de Suporte

- Evolveum Community: https://lists.evolveum.com/
- GitHub Polygon Connectors: https://github.com/Evolveum/connector-sql

<REDACTED_SECRET><REDACTED_SECRET>
FIM DA GMUD-020C v2
<REDACTED_SECRET><REDACTED_SECRET>

**Status**: 🟡 AGUARDANDO APROVAÇÃO
**Versão**: 2.0 (Incorpora conectores ICF)
**Próxima Ação**: Revisão e assinatura por Paulo Feitosa
**Tempo Estimado**: 32 minutos (+11 min vs v1)
**Probabilidade de Sucesso**: MUITO ALTA (stack certificado + conectores)

**Descoberta Crítica:**
Análise arquitetural identificou que falhas anteriores não eram apenas
de infraestrutura, mas de DESIGN INCOMPLETO (conectores ICF ausentes).
Esta GMUD implementa correção bicamadas.

**Diferencial para Portfolio:**
"Não apenas configurei. Identifiquei, através de RCA multicamadas, um gap
de aplicação que nenhuma troca de versão resolveria. Demonstra senioridade:
entender o PORQUÊ, não apenas o COMO."

<REDACTED_SECRET><REDACTED_SECRET>

