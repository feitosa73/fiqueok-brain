# TERMO DE ABERTURA DO PROJETO (TAP)

**Projeto PRJ008 - Shadow API REST para Integração OrangeHRM × midPoint IGA**

**Versão**: 2.0 - Revisão Estratégica (Planning-First Approach)  
**Data**: 13 de Fevereiro de 2026  
**Responsável**: Paulo Feitosa Lima  
**GRC Lead**: Perplexity AI (Threat Intelligence & Compliance)  
**Contexto**: Living Lab Fiqueok - Greenfield Environment

---

## 📋 CHANGELOG - VERSÃO 2.0

| Item | Mudança | Justificativa |
|------|---------|---------------|
| **Foco do Projeto** | 80% Planejamento + 20% Execução | Evitar débito técnico por decisões tardias (lição PRJ006) |
| **Nova Estrutura** | 3 Fases de Planning + 1 Fase de Execução | Decisões arquiteturais precedem codificação |
| **DevSecOps** | Pipeline de CI/CD com Security Gates | Código gerado por IA exige validação multicamada |
| **Sprints Diárias** | Rollback obrigatório se entrega falhar | Proteção contra "technical debt snowball" |
| **Decisões Pendentes** | 7 decisões críticas documentadas | Nenhuma suposição implícita permitida |

---

## 1. IDENTIFICAÇÃO DO PROJETO

| Item | Descrição |
|------|-----------|
| **Código do Projeto** | PRJ008 |
| **Nome** | Shadow API REST - HR-Driven Identity Lifecycle com AI-Augmented Development |
| **Categoria** | Identity Governance & Administration (IGA) + Application Security + DevSecOps |
| **Programa** | Living Lab Fiqueok - Identity & Access Governance Stack |
| **Patrocinador** | Paulo Feitosa (IAM Specialist/Auditor) |
| **Gerente do Projeto** | Paulo Feitosa |
| **GRC Lead** | Perplexity AI (Threat Intelligence) |
| **Arquiteto Técnico** | ChatGPT/Claude (após aprovação de decisões) |
| **Especialista Deep-Dive** | Gemini Pro (validação arquitetural) |
| **Data de Início** | 13/02/2026 (quinta-feira) - Fase de Planning |
| **Data de Término Prevista** | 24/02/2026 (segunda-feira) |
| **Duração Estimada** | 9 dias úteis (Planning: 6 dias, Execução: 3 dias) |

---

## 2. CONTEXTO E JUSTIFICATIVA

### 2.1 Situação Atual

O Living Lab Fiqueok concluiu com sucesso o PRJ007 (HashiCorp Vault) implementando PAM (Privileged Access Management) com gestão centralizada de segredos. No entanto, o PRJ006 (integração JDBC com OrangeHRM) foi abortado por representar um anti-padrão arquitetural.

**Lição Crítica do PRJ006**: Decisões arquiteturais tardias custam 10x mais para corrigir do que decisões tomadas antes da codificação.

### 2.2 Análise de Débito de Decisão

Projetos anteriores demonstraram que:
- **Identificador canônico indefinido** → duplicação de registros no midPoint
- **Autoridade de dados implícita** → conflitos de sincronização  
- **Estados de identidade ambíguos** → provisionamentos incorretos
- **Fluxo de dados não documentado** → retrabalho em GMUDs

**Métrica de Custo**:
- Decisão ANTES da codificação: 1x esforço
- Decisão DURANTE a codificação: 3x esforço  
- Decisão APÓS deployment: 10x esforço (+ risco de rollback)

**Investimento PRJ008**: 6 dias de planejamento = evitar 18-30 dias de retrabalho (ROI: 300-500%)

---

## 3. OBJETIVOS

### 3.1 Objetivo Geral

Implementar uma **Shadow API REST** baseada em FastAPI que possibilite ao midPoint 4.10 executar o ciclo de vida completo de identidades (JML) utilizando o OrangeHRM 5.8 como fonte autoritativa, com:
- **100% das decisões arquiteturais documentadas ANTES da codificação**
- **Pipeline DevSecOps com 4 camadas de validação de código AI-generated**
- **Zero débito técnico por decisões tardias**

### 3.2 Objetivos Específicos

**OS1 - Levantamento e Decisões (80% do Esforço)**
- Decidir modelo de hospedagem (VM/IaaS/Serverless/Container)
- Desenhar arquitetura de rede Zero Trust com Tailscale ACLs
- Definir identificador canônico e autoridade de dados
- Criar contrato OpenAPI da Shadow API (antes do código existir)
- Definir política de Least Privilege no Vault
- Desenhar pipeline DevSecOps com Security Gates

**OS2 - Desenvolvimento Assistido por IA (15% do Esforço)**
- Gerar código via IA seguindo prompts validados
- Validar código em 4 camadas (Gemini + ChatGPT + Perplexity + Humano)

**OS3 - Integração e Testes (5% do Esforço)**
- Configurar Resource no midPoint
- Validar JML (Joiner/Mover/Leaver)

---

## 4. FASE 0 - PRE-FLIGHT (LEVANTAMENTO TÉCNICO)

**Duração**: 2 dias (13-14/02/2026)  
**Esforço**: 6 horas  
**Responsável**: Paulo + Perplexity + Gemini

### 4.1 Matriz de Decisões de Infraestrutura (OBRIGATÓRIA)

Antes de qualquer codificação, **7 decisões arquiteturais** devem ser documentadas:

| ID | Decisão Necessária | Opções | Responsável | Prazo |
|----|-------------------|--------|-------------|-------|
| **D1** | **Modelo de Hospedagem** | VM Dedicada / Container / Serverless / IaaS | Paulo + Gemini | 13/02 |
| **D2** | **Arquitetura de Rede** | Tailscale ACLs / VLANs / Bridge Docker | Paulo + ChatGPT | 13/02 |
| **D3** | **Identificador Canônico** | emp_number / employeeId / email / UUID | Paulo + Perplexity | 14/02 |
| **D4** | **Autoridade de Dados** | OrangeHRM = Source of Truth? | Paulo | 14/02 |
| **D5** | **Estados de Identidade** | Mapear OrangeHRM → midPoint | Paulo + Gemini | 14/02 |
| **D6** | **Política Vault** | Path + Operações (read/list/write) | Paulo | 14/02 |
| **D7** | **Estratégia de Rollback** | Snapshot / Image Tags / Git Revert | Paulo | 14/02 |

**Critério de Saída da Fase 0**: Todas as 7 decisões documentadas em ADR (Architecture Decision Record) e aprovadas.

### 4.2 Análise de Viabilidade de Infraestrutura

#### **Opção A - VM Dedicada (Hyper-V/IaaS)**

**Prós**:
- Isolamento total (VM independente, IP Tailscale dedicado)
- Controle total de SO (patching, hardening)
- Facilita auditoria (logs centralizados)

**Contras**:
- Exige gestão de SO (updates, monitoramento)
- Maior consumo de recursos (1 vCPU, 1-2GB RAM)
- Tempo de provisionamento: ~1-2 horas

**Cenário de Uso**: Ambiente corporativo, compliance rigoroso

#### **Opção B - Container Docker no Host**

**Prós**:
- Deploy rápido (5-10 minutos via docker-compose)
- Menor consumo de recursos
- Isolamento de processo

**Contras**:
- Isolamento de rede mais frágil
- Compartilha kernel do host
- Dificuldade em segregar tráfego com Tailscale ACLs

**Cenário de Uso**: Laboratório, prototipagem rápida

#### **Opção C - Serverless (AWS Lambda/Azure Functions)**

**Prós**:
- Escalabilidade infinita
- Menor custo (pay-per-use)
- Zero gestão de SO

**Contras**:
- Conectividade complexa com Living Lab local
- Cold start latency (500ms-2s)
- Vendor lock-in

**Cenário de Uso**: Produção cloud-native

**RECOMENDAÇÃO (Perplexity)**:
- **Curto Prazo (Sprint 1-2)**: Container Docker (velocidade)
- **Médio Prazo (Sprint 3+)**: VM Dedicada (governança)

### 4.3 Arquitetura de Rede e Conectividade Zero Trust

#### **Diagrama de Fluxo de Dados (DFD)**

```
┌──────────────────────────────────────────────────────────────┐
│               TAILSCALE MESH VPN (100.x.x.0/24)              │
│                    MagicDNS + ACLs Enabled                   │
└──────────────────────────────────────────────────────────────┘
           │              │              │              │
    ┌──────▼──────┐ ┌─────▼──────┐ ┌────▼──────┐ ┌────▼──────┐
    │   vault     │ │    iga     │ │  api      │ │    rh     │
    │  -gf-01     │ │  -gf-01    │ │ -gf-01    │ │  -gf-01   │
    │xxx.xxx.xxx.xxx │ │ 100.x.x.x  │ │ PENDENTE  │ │ 100.x.x.x │
    │             │ │            │ │  DECISÃO  │ │           │
    │ HashiCorp   │ │  midPoint  │ │  Shadow   │ │  Orange   │
    │  Vault      │ │    4.10    │ │  API      │ │  HRM 5.8  │
    │   :8200     │ │    :8080   │ │  :8000    │ │  :3306    │
    └─────────────┘ └────────────┘ └───────────┘ └───────────┘
```

#### **Decisões de Conectividade (D2)**

**D2.1**: Como a Shadow API alcançará o MariaDB?
- **Opção A** (RECOMENDADA): Via IP Tailscale do rh-gf-01
- Opção B: Via bridge Docker (se API no mesmo host)
- Opção C: Via exposição de porta local (INSEGURO)

**D2.2**: Como a Shadow API alcançará o Vault?
- **Obrigatório**: Via IP Tailscale xxx.xxx.xxx.xxx:8200
- Token lido de variável de ambiente VAULT_TOKEN

**D2.3**: Como o midPoint chamará a Shadow API?
- Opção A: Via IP Tailscale (se VM dedicada)
- Opção B: Via localhost:8000 (se container no mesmo host)

#### **Matriz de Conectividade (Firewall Rules)**

| Source | Destination | Port | Protocolo | Ação | Justificativa |
|--------|-------------|------|-----------|------|---------------|
| api-gf-01 | vault-gf-01 | 8200 | HTTPS | ALLOW | Leitura de secrets |
| api-gf-01 | rh-gf-01 | 3306 | MySQL | ALLOW | Query ao OrangeHRM |
| iga-gf-01 | api-gf-01 | 8000 | HTTP | ALLOW | midPoint consome API |
| * | api-gf-01 | 8000 | HTTP | DENY | Zero acesso externo |
| api-gf-01 | * | * | * | DENY | Least Privilege |

#### **Testes de Conectividade (OBRIGATÓRIOS)**

```bash
# Teste 1: Vault acessível?
curl -s http://xxx.xxx.xxx.xxx:8200/v1/sys/health | jq .

# Teste 2: MariaDB acessível?
telnet <IP_RH_GF_01> 3306

# Teste 3: Teste de query
mysql -h <IP_RH_GF_01> -u root -p -e "SELECT 1"
```

**Critério de Saída**: 100% dos testes passando.

### 4.4 Definição do Contrato de Identidade

#### **Identificador Canônico (DECISÃO D3)**

**Análise de Opções**:

| Atributo | Imutabilidade | Unicidade | Disponibilidade | Recomendação |
|----------|---------------|-----------|-----------------|--------------|
| `emp_number` | ✅ Alta | ✅ Sim (PK) | ✅ Sempre | **RECOMENDADO** |
| `email` | ❌ Baixa | ⚠️ Não (NULL) | ⚠️ Nem sempre | REJEITADO |
| `cpf` | ✅ Alta | ✅ Sim | ⚠️ Customização | Alternativa |
| UUID gerado | ✅ Imutável | ✅ Único | ✅ Sempre | Sobrecarga |

**DECISÃO D3 (Recomendação)**:
- **Identificador Canônico**: `emp_number` do OrangeHRM
- **Mapeamento no midPoint**: Correlação via `employeeNumber`
- **Política**: `emp_number` NUNCA alterado após criação

#### **Autoridade de Dados (DECISÃO D4)**

**Mapa de Autoridade por Atributo**:

| Atributo | Sistema Autoritativo | Direção | Conflito? |
|----------|---------------------|---------|-----------|
| `emp_number` | OrangeHRM | OrangeHRM → midPoint | Não (imutável) |
| `firstName` | OrangeHRM | OrangeHRM → midPoint → LDAP | Não |
| `email` | OrangeHRM | OrangeHRM → midPoint → AD | Sim (AD pode alterar) |
| `department` | OrangeHRM | OrangeHRM → midPoint → LDAP | Não |
| `isTerminated` | OrangeHRM | Derivado de termination_id | Não |

**Política de Conflitos**: OrangeHRM sempre prevalece (Source of Truth).

#### **Estados de Identidade (DECISÃO D5)**

**Mapeamento OrangeHRM → midPoint**:

| Estado OrangeHRM | Condição SQL | Estado midPoint | administrativeStatus |
|------------------|--------------|-----------------|----------------------|
| **Ativo** | `termination_id IS NULL AND joined_date <= NOW()` | Ativo | enabled |
| **Aviso Prévio** | `termination_id IS NOT NULL AND t.date > NOW()` | Ativo | enabled |
| **Desligado** | `termination_id IS NOT NULL AND t.date <= NOW()` | Inativo | disabled |
| **Pré-Contratado** | `joined_date > NOW()` | Pendente | archived |

### 4.5 Política de Acesso ao Vault (DECISÃO D6)

#### **Política api-proxy-policy (REFINADA)**

```hcl
# Leitura de secrets do OrangeHRM
path "secret/data/orangehrm/mysql" {
  capabilities = ["read"]
}

path "secret/data/orangehrm/oauth" {
  capabilities = ["read"]
}

# Leitura de JWT secret
path "secret/data/api-proxy/jwt" {
  capabilities = ["read"]
}

# Auto-renewal do próprio token
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# Lookup do próprio token
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# BLOQUEADO: Escrita em qualquer path
path "secret/*" {
  capabilities = ["deny"]
}
```

#### **Teste de Validação**

```bash
# 1. Gerar token com política
VAULT_TOKEN=$(vault token create -policy=api-proxy-policy -period=24h -format=json | jq -r .auth.client_token)

# 2. Testar leitura autorizada
vault kv get secret/orangehrm/mysql
# Esperado: Sucesso

# 3. Testar leitura NÃO autorizada
vault kv get secret/midpoint/admin
# Esperado: Error permission denied

# 4. Testar escrita (deve falhar)
vault kv put secret/orangehrm/mysql root_password="TESTE"
# Esperado: Error permission denied
```

**Critério de Saída**: 100% dos testes de RBAC passando.

---

## 5. FASE 1 - DESIGN E GOVERNANÇA

**Duração**: 3 dias (17-19/02/2026)  
**Esforço**: 9 horas  
**Responsável**: Paulo + Perplexity + ChatGPT

### 5.1 Elaboração do Diagrama de Componentes

#### **Arquitetura Lógica**

```
┌────────────────────────────────────────────────────────────┐
│                 SHADOW API - FASTAPI                       │
│                  (Python 3.11 + Uvicorn)                   │
└────────────────────────────────────────────────────────────┘
                           │
       ┌───────────────────┼───────────────────┐
       │                   │                   │
┌──────▼──────┐    ┌───────▼──────┐    ┌──────▼──────┐
│Auth Manager │    │ Data Engine  │    │Health Check │
│             │    │              │    │             │
│- OAuth 2.0  │    │- SQLAlchemy  │    │- Vault Chk  │
│- JWT Gen    │    │- Query Build │    │- DB Check   │
│- Token Val  │    │- Conn Pool   │    │- Status Agg │
└──────┬──────┘    └───────┬──────┘    └──────┬──────┘
       │                   │                   │
       │           ┌───────▼───────────────────▼───┐
       │           │      Vault Manager            │
       │           │  - Secrets Retrieval          │
       │           │  - Token Auto-Renewal         │
       │           │  - Error Handling + Retry     │
       │           └───────────────────────────────┘
       │                           │
       │                           ▼
       │               ┌────────────────────┐
       │               │  HashiCorp Vault   │
       │               │  xxx.xxx.xxx.xxx:8200 │
       │               └────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│        Endpoints Expostos            │
├──────────────────────────────────────┤
│ POST /oauth/token                    │
│   → Autentica Client Credentials     │
│   → Retorna JWT (TTL 3600s)          │
│                                      │
│ GET /api/v1/employees                │
│   → Requer: Bearer Token             │
│   → Retorna: JSON colaboradores      │
│   → Lógica: Deriva isTerminated      │
│                                      │
│ GET /health                          │
│   → Verifica: API + Vault + DB       │
│   → Retorna: 200/207/503             │
└──────────────────────────────────────┘
```

#### **Estrutura de Arquivos (Definitiva)**

```
shadow-api-orangehrm/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── config/
│   │   ├── __init__.py
│   │   └── settings.py
│   ├── managers/
│   │   ├── __init__.py
│   │   ├── vault.py
│   │   └── database.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── employee.py
│   │   └── auth.py
│   ├── routes/
│   │   ├── __init__.py
│   │   ├── oauth.py
│   │   ├── employees.py
│   │   └── health.py
│   └── dependencies.py
├── tests/
│   ├── __init__.py
│   ├── test_oauth.py
│   ├── test_employees.py
│   └── test_health.py
├── docs/
│   ├── openapi.yaml
│   ├── architecture.md
│   └── decisions.md
├── .env.vault.template
├── .gitignore
├── requirements.txt
├── docker-compose.yml
├── Dockerfile
└── README.md
```

### 5.2 Contrato OpenAPI (ANTES do Código)

**Objetivo**: midPoint precisa conhecer o formato EXATO da API antes do código existir.

**Endpoints Obrigatórios**:

1. **POST /oauth/token**
   - Request: `grant_type=client_credentials&client_id=<>&client_secret=<>`
   - Response: `{"access_token": "JWT", "token_type": "Bearer", "expires_in": 3600}`

2. **GET /api/v1/employees**
   - Headers: `Authorization: Bearer <JWT>`
   - Response: `{"data": [Employee], "total": int}`

3. **GET /health**
   - Response: `{"status": "healthy|degraded|unhealthy", "dependencies": {...}}`

**Query SQL (OBRIGATÓRIA para /employees)**:

```sql
SELECT 
    e.emp_number AS employeeId,
    e.emp_firstname AS firstName,
    e.emp_lastname AS lastName,
    e.emp_work_email AS email,
    jt.job_title_name AS jobTitle,
    su.name AS department,
    e.termination_id IS NOT NULL AS isTerminated,
    e.joined_date AS joinedDate,
    t.date AS terminatedDate
FROM hs_hr_employee e
LEFT JOIN ohrm_job_title jt ON e.job_title_code = jt.id
LEFT JOIN ohrm_subunit su ON e.work_station = su.id
LEFT JOIN ohrm_emp_termination t ON e.termination_id = t.id
WHERE e.emp_number IS NOT NULL
ORDER BY e.emp_number
```

### 5.3 Gatilhos de Auditoria

**Eventos que DEVEM gerar logs**:

| Evento | Log Level | Campos Obrigatórios |
|--------|-----------|---------------------|
| Token OAuth solicitado | INFO | client_id, source_ip, timestamp |
| Token OAuth rejeitado | WARNING | client_id, reason, source_ip |
| Secret lido do Vault | INFO | path, token_id (hash) |
| Falha ao ler secret | ERROR | path, error, token_id |
| Query SQL executada | DEBUG | query (sanitizado), duration_ms |
| Health check executado | DEBUG | status, dependencies |

**Formato (JSON)**:

```json
{
  "timestamp": "2026-02-13T14:30:00.123Z",
  "level": "INFO",
  "service": "shadow-api",
  "version": "1.0.0",
  "event": "oauth_token_issued",
  "client_id": "midpoint-iga-client",
  "source_ip": "xxx.xxx.xxx.xxx",
  "token_ttl": 3600
}
```

---

## 6. FASE 2 - DEVSECOPS PIPELINE

**Duração**: 1 dia (20/02/2026)  
**Esforço**: 3 horas  
**Responsável**: Paulo + ChatGPT

### 6.1 Estrutura da Esteira de CI/CD

```
STAGE 1: CODE GENERATION (IA)
├─ Input: Prompt validado
├─ Executor: Claude/ChatGPT/Gemini
├─ Output: Código Python completo
└─ Critério: Sintaxe válida

STAGE 2: STATIC ANALYSIS (SAST)
├─ Tools: Bandit, Flake8, mypy, Safety
├─ Executor: ChatGPT (análise)
├─ Output: Lista de vulnerabilidades + Score
└─ Gate: Score < 8 → REJEITAR

STAGE 3: ARCHITECTURAL REVIEW
├─ Executor: Gemini Deep
├─ Checklist: SRP, DI, Pooling, Error Handling
├─ Output: Problemas + Refatorações
└─ Gate: CRITICAL → REJEITAR

STAGE 4: THREAT INTELLIGENCE
├─ Executor: Perplexity Pro
├─ Checklist: CVEs, MITRE ATT&CK, OWASP
├─ Output: CVEs + Aprovação
└─ Gate: CVE crítico → REJEITAR

STAGE 5: MANUAL APPROVAL
├─ Executor: Paulo (Auditor)
├─ Checklist: Testes manuais + Logs
├─ Output: GO / NO-GO
└─ Gate: NO-GO → Rollback

STAGE 6: DEPLOYMENT (Staging)
├─ Executor: Docker Compose
├─ Steps: Build + Tag + Deploy + Tests
└─ Gate: Smoke test falhou → Rollback

STAGE 7: PRODUCTION
├─ Executor: Paulo (comando manual)
├─ Steps: Snapshot + Tag + Deploy
└─ Rollback Plan: Restore snapshot
```

### 6.2 Security Gates

#### **Gate 1: SAST**

```bash
bandit -r app/ -f json -o reports/bandit.json
flake8 app/ --max-line-length=120
mypy app/ --strict
safety check --json > reports/safety.json
```

**Thresholds**:
- Bandit HIGH: 0 issues → REJEITAR
- Flake8 Errors: 0 → REJEITAR
- mypy Coverage: ≥ 90%
- Safety Critical CVE: 0 → REJEITAR

#### **Gate 2: Architectural Review (Gemini)**

**Checklist**:
- [ ] Separação de concerns (SRP)
- [ ] Dependency injection correto
- [ ] Connection pooling configurado
- [ ] Error handling robusto
- [ ] Logging estruturado

**Output**: Score 0-10 + Refatorações

#### **Gate 3: Threat Intelligence (Perplexity)**

**Tarefas**:
1. Pesquisar CVEs para dependências
2. Identificar funções inseguras
3. Mapear vetores de ataque (MITRE ATT&CK)
4. Validar OWASP API Top 10

**Output**: Tabela CVEs + Aprovação (SIM/NÃO/CONDICIONAL)

#### **Gate 4: Manual Approval**

**Checklist**:
- [ ] Código passou SAST (0 critical)
- [ ] Gemini Score ≥ 8/10
- [ ] Perplexity aprovou (0 CVEs)
- [ ] Testes manuais OK
- [ ] Logs não expõem secrets
- [ ] Snapshot Hyper-V criado

### 6.3 Plano de Rollback

**Estratégias**:

| Cenário | Estratégia | RTO |
|---------|------------|-----|
| Código com bug | Git revert + rebuild | 5-10 min |
| Container não inicia | Docker image rollback | 2-5 min |
| VM corrompida | Hyper-V snapshot restore | 5-15 min |

**Procedimento Docker**:

```bash
# 1. Identificar versão anterior
docker images | grep shadow-api

# 2. Parar container
docker-compose down

# 3. Alterar docker-compose.yml para tag anterior

# 4. Restart
docker-compose up -d

# 5. Validar
curl http://localhost:8000/health | jq .
```

---

## 7. FASE 3 - DESENVOLVIMENTO ASSISTIDO POR IA

**Duração**: 2 dias (21-22/02/2026)  
**Esforço**: 6 horas  
**Responsável**: Paulo + Claude/ChatGPT + Validação IA

### 7.1 Fatiamento em Sprints Diárias

#### **Sprint 1 - Alicerce (OAuth + Vault)**

**Data**: 21/02/2026  
**Duração**: 3 horas

**Componentes**:
- app/config/settings.py
- app/managers/vault.py
- app/routes/oauth.py
- docker-compose.yml

**Entregável**: Endpoint /oauth/token funcional

**Teste**:
```bash
curl -X POST http://localhost:8000/oauth/token   -d "grant_type=client_credentials"   -d "client_id=<VAULT>"   -d "client_secret=<VAULT>"

# Esperado: {"access_token": "JWT", ...}
```

**Falha? Rollback**: Apagar pasta do projeto.

#### **Sprint 2 - Core (Data Integration)**

**Data**: 22/02/2026  
**Duração**: 3 horas

**Componentes**:
- app/managers/database.py
- app/routes/employees.py
- app/models/employee.py

**Entregável**: Endpoint /api/v1/employees funcional

**Teste**:
```bash
TOKEN=$(curl -s -X POST ...)

curl -H "Authorization: Bearer $TOKEN"   http://localhost:8000/api/v1/employees | jq .

# Esperado: {"data": [Employee], ...}
```

**Falha? Rollback**: git revert HEAD + rebuild Sprint 1.

#### **Sprint 3 - Resiliência (Health Check)**

**Data**: 24/02/2026  
**Duração**: 2 horas

**Componentes**:
- app/routes/health.py
- Refatoração dependencies.py

**Entregável**: Endpoint /health funcional

**Teste**:
```bash
curl http://localhost:8000/health | jq .

# Esperado: {"status": "healthy", "dependencies": {...}}
```

**Teste Degradação**:
```bash
docker stop orange-db
curl http://localhost:8000/health
# Esperado: HTTP 207/503, database.status = "unhealthy"
```

**Falha? Rollback**: Retornar para Sprint 2.

---

## 8. FASE 4 - INTEGRAÇÃO E TESTES

**Duração**: 1 dia (24/02/2026)  
**Esforço**: 3 horas  
**Responsável**: Paulo

### 8.1 Configuração do Resource no midPoint

**Objetivo**: Conectar midPoint à Shadow API usando OAuth 2.0

**Configuração**:
- Connector: REST Connector
- Base URL: http://api-gf-01:8000
- Auth: OAuth 2.0 Client Credentials
- Token URL: /oauth/token
- Data Endpoint: /api/v1/employees

**Schema Handling**:
- Identificador: employeeId → employeeNumber
- Atributos: firstName, lastName, email, jobTitle, department
- Status: isTerminated → administrativeStatus (enabled/disabled)

**Correlação**: Via employeeNumber

### 8.2 Testes de Provisionamento (JML)

#### **Teste 1 - Joiner**

**Cenário**: Novo colaborador "Maria Santos"

**Passos**:
1. Criar no OrangeHRM (Nome, Email, Dept, Cargo)
2. Sincronizar no midPoint
3. Validar criação no LDAP

**Critério**: Conta criada com todos os atributos.

#### **Teste 2 - Mover**

**Cenário**: Maria transferida para outro departamento

**Passos**:
1. Atualizar dept no OrangeHRM
2. Sincronizar no midPoint
3. Validar atualização LDAP

**Critério**: Atributo `ou` atualizado.

#### **Teste 3 - Leaver**

**Cenário**: Maria desligada

**Passos**:
1. Registrar desligamento no OrangeHRM
2. Sincronizar no midPoint
3. Validar desabilitação LDAP

**Critério**: nsAccountLock = TRUE.

---

## 9. CRONOGRAMA REVISADO (80/20)

### **Resumo de Fases**:

| Fase | Duração | % Esforço |
|------|---------|-----------|
| **0 - Pre-Flight** | 2 dias | 30% |
| **1 - Design** | 3 dias | 35% |
| **2 - DevSecOps** | 1 dia | 15% |
| **3 - Desenvolvimento** | 2 dias | 15% |
| **4 - Testes** | 1 dia | 5% |
| **TOTAL** | **9 dias** | **100%** |

### **Cronograma Detalhado**:

#### **Dia 1: 13/02 (quinta) - Pre-Flight Parte 1**

| Horário | Atividade | Duração |
|---------|-----------|---------|
| 18:00-18:30 | Snapshot PRJ008-PreStart | 30min |
| 18:30-20:00 | Decisões D1 + D2 | 1h30min |
| 20:00-21:00 | Testes conectividade | 1h |

**Entregáveis**: ADR-001 (Hospedagem) + ADR-002 (Rede)

#### **Dia 2: 14/02 (sexta) - Pre-Flight Parte 2**

| Horário | Atividade | Duração |
|---------|-----------|---------|
| 18:00-19:30 | Decisões D3-D5 | 1h30min |
| 19:30-20:30 | Decisão D6 + Testes RBAC | 1h |
| 20:30-21:00 | Decisão D7 + Validação snapshots | 30min |

**Entregáveis**: ADR-003 a 007

#### **Dia 3: 17/02 (segunda) - Design Parte 1**

| Horário | Atividade | Duração |
|---------|-----------|---------|
| 18:00-20:00 | Diagrama de componentes | 2h |
| 20:00-21:00 | OpenAPI contract | 1h |

**Entregáveis**: docs/architecture.md + docs/openapi.yaml

#### **Dia 4: 18/02 (terça) - Design Parte 2**

| Horário | Atividade | Duração |
|---------|-----------|---------|
| 18:00-19:30 | Gatilhos de auditoria | 1h30min |
| 19:30-21:00 | Validar OpenAPI | 1h30min |

**Entregáveis**: docs/audit-spec.md

#### **Dia 5: 19/02 (quarta) - Design Review**

| Horário | Atividade | Duração |
|---------|-----------|---------|
| 18:00-20:00 | Revisão de documentação | 2h |
| 20:00-21:00 | Aprovação final | 1h |

**Gate**: Todas as decisões aprovadas.

#### **Dia 6: 20/02 (quinta) - DevSecOps**

| Horário | Atividade | Duração |
|---------|-----------|---------|
| 18:00-20:00 | Configurar SAST tools | 2h |
| 20:00-21:00 | Documentar Security Gates | 1h |

**Entregáveis**: scripts/run-sast.sh + docs/security-gates.md

#### **Dia 7: 21/02 (sexta) - Sprint 1**

| Horário | Atividade | Duração |
|---------|-----------|---------|
| 18:00-19:00 | Gerar código OAuth + Vault | 1h |
| 19:00-20:00 | Validação multicamada | 1h |
| 20:00-21:00 | Testes manuais | 1h |

**Entregável**: Endpoint /oauth/token

#### **Dia 8: 22/02 (sábado) - Sprint 2**

| Horário | Atividade | Duração |
|---------|-----------|---------|
| 14:00-15:00 | Gerar código Data Engine | 1h |
| 15:00-16:00 | Validação | 1h |
| 16:00-17:00 | Testes | 1h |

**Entregável**: Endpoint /api/v1/employees

#### **Dia 9: 24/02 (segunda) - Sprint 3 + Integração**

| Horário | Atividade | Duração |
|---------|-----------|---------|
| 18:00-19:00 | Gerar Health Check | 1h |
| 19:00-19:30 | Validação | 30min |
| 19:30-20:30 | Configurar Resource midPoint | 1h |
| 20:30-21:00 | Testes JML | 30min |

**Entregáveis**: API completa + Resource + Testes

---

## 10. ENTREGÁVEIS

| ID | Entregável | Tipo | Prazo |
|----|-----------|------|-------|
| **E1** | ADR-PRJ008-001 a 007 | Decisões | 14/02 |
| **E2** | Diagrama de Componentes | Doc | 17/02 |
| **E3** | OpenAPI Contract | Spec | 18/02 |
| **E4** | Matriz de Conectividade | Doc | 14/02 |
| **E5** | DevSecOps Pipeline | Scripts | 20/02 |
| **E6** | Shadow API (Código) | Software | 22/02 |
| **E7** | Resource midPoint | Config | 24/02 |
| **E8** | Testes JML | Evidências | 24/02 |
| **E9** | Snapshot Hyper-V | Backup | 24/02 |
| **E10** | Post-Mortem | Análise | 25/02 |

---

## 11. CRITÉRIOS DE SUCESSO

### 11.1 Planejamento (80%)

| ID | Critério | Validação | Meta |
|----|----------|-----------|------|
| CP1 | 7 decisões documentadas | ADRs aprovados | 100% |
| CP2 | OpenAPI sem erros | Swagger Editor | 0 erros |
| CP3 | Testes conectividade | Vault + DB | 100% |
| CP4 | Política Vault testada | RBAC validado | 100% |

### 11.2 Execução (20%)

| ID | Critério | Validação | Meta |
|----|----------|-----------|------|
| CE1 | /oauth/token funcional | curl retorna JWT | HTTP 200 |
| CE2 | /api/v1/employees funcional | JSON colaboradores | HTTP 200 |
| CE3 | /health funcional | Status dependências | 200/207/503 |
| CE4 | Zero CVEs críticos | Perplexity | 0 |
| CE5 | JML funcional | Testes completos | 100% |
| CE6 | Zero secrets plaintext | grep | 0 |

---

## 12. RISCOS E MITIGAÇÕES

| ID | Risco | Prob | Impacto | Mitigação |
|----|-------|------|---------|-----------|
| R1 | Decisão D1 indefinida | Média | Alto | Deadline 13/02 20:00 |
| R2 | OpenAPI inválido | Baixa | Médio | Validação Swagger |
| R3 | IA gera código com CVE | Média | Crítico | Pipeline 4 camadas |
| R4 | Testes JML falham | Média | Alto | Doc prévia de estados |
| R5 | Vault token expira | Baixa | Médio | TTL 24h |
| R6 | Sprint não conclui | Média | Médio | Rollback obrigatório |

---

## 13. APROVAÇÕES

| Função | Nome | Data | Decisão |
|--------|------|------|---------|
| **Responsável** | Paulo Feitosa Lima | 13/02/2026 | PENDENTE |
| **GRC Lead** | Perplexity AI | 13/02/2026 | PENDENTE |
| **Sponsor** | Paulo Feitosa | 13/02/2026 | PENDENTE |

---

## 14. CONTROLE DE VERSÃO

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 12/02/2026 | Perplexity AI | Versão inicial |
| **2.0** | **13/02/2026** | **Perplexity AI** | **Planning-first 80/20** |

---

**FIM DO TAP-PRJ008 v2.0**

---

*Documento mantido por Perplexity AI (GRC Lead & Threat Intelligence)*  
*Repositório: Living Lab Fiqueok - PRJ008*  
*Próxima revisão: Após conclusão Fase 0 (Pre-Flight)*

