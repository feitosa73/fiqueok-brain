
# TERMO DE ABERTURA DO PROJETO (TAP)
## PRJ008 — Shadow API REST · OrangeHRM × midPoint IGA

---

| Campo | Valor |
|---|---|
| **Documento** | TAP-PRJ008 |
| **Versão** | **3.0 — EXECUTION READY** |
| **Data de Emissão** | 10/04/2026 |
| **Responsável** | Paulo Feitosa Lima |
| **GRC Lead / Auditor** | Paulo Feitosa Lima (IAM Specialist / GRC Lead) |
| **Revisores Técnicos** | ChatGPT · Gemini Pro · Perplexity AI · Claude |
| **Status** | ✅ **APROVADO PARA SPRINT 1** — Gate GATE-PRJ008-001 liberado |
| **Programa** | PRJ003 — Living Lab Fiqueok · Greenfield |
| **Documentos Predecessores** | TAP-PRJ008-v2.0 · ARQ-PRJ003-ADR-PRJ008-v2.0 · GATE-PRJ008-001-v2.0 |

---

## 📋 CHANGELOG v2.0 → v3.0

| Item | Mudança | Justificativa |
|------|---------|---------------|
| **Stack Tecnológica** | Definida: Python 3.12 + FastAPI + SQLAlchemy 2.0 (Core) + Uvicorn | Veredito do Peer Review multicamada |
| **Contrato Canônico** | Formalizado: `emp_number` como âncora imutável; UTF-8 NFC; Null por omissão | Decisão de design irrevogável pós-Peer Review |
| **Infra** | I-01 a I-04 marcados como **CONCLUÍDOS** com evidências de execução | Pre-Flight executado em 10/04/2026 |
| **Banco de Dados** | DB-01 marcado como **CONCLUÍDO** — `svc_shadow_api` criado com evidência | Evidência: `Evidencias_Prompt_Orange.md` |
| **Vault** | VLT-01 marcado como **CONCLUÍDO** — `secret/orangehrm/db_api` provisionado | Evidência: `Evidencias_Prompt_Vault.txt` |
| **Cronograma** | Reescrito para Fase 1 (Sprint 1–3) com datas correntes | Fases 0 a Planning encerradas |
| **Decisões D1–D7** | Todas resolvidas e registradas em ADR | Bloco de decisão 100% fechado |
| **Anexo E** | DevSecOps pipeline com Bandit + Safety mantido e referenciado | Sem alteração de substância |
| **Seção de Riscos** | Atualizada: R1/R2/R5/R6 fechados; R3/R4 migrados; R9 adicionado | Reflita estado real do projeto |

---

## 1. IDENTIFICAÇÃO DO PROJETO

| Item | Descrição |
|------|-----------|
| **Código** | PRJ008 |
| **Nome** | Shadow API REST — HR-Driven Identity Lifecycle com AI-Augmented Development |
| **Categoria** | IGA + Application Security + DevSecOps |
| **Programa** | Living Lab Fiqueok — Identity & Access Governance Stack |
| **Patrocinador / GP** | Paulo Feitosa Lima |
| **Arquiteto Técnico** | Claude / ChatGPT (execução assistida) |
| **Data de Início (Planejamento)** | 13/02/2026 |
| **Data de Início (Execução / Sprint 1)** | 10/04/2026 |
| **Data de Término Prevista** | 17/04/2026 |
| **Duração Execução** | 5 dias úteis (3 Sprints + Integração + Encerramento) |

---

## 2. CONTEXTO E JUSTIFICATIVA

### 2.1 Situação Atual (Estado em 10/04/2026)

O PRJ008 completou com êxito todas as fases de planejamento e pré-voo. A infraestrutura base está operacional, o banco de dados está configurado com o princípio de menor privilégio e os segredos estão provisionados no Vault. O projeto está agora formalmente autorizado a iniciar o desenvolvimento da Shadow API.

**Lições Críticas Incorporadas:**

- PRJ006 (JDBC direto): abortado por anti-padrão arquitetural. PRJ008 mitiga via camada de API intermediária.
- PRJ015 (Cloud Sync): falha por violação de SSoT. PRJ008 reforça o OrangeHRM como única fonte de verdade.
- Qualquer decisão de design não documentada antes da codificação incorreu em custo 10× no passado. O Peer Review multicamada fecha esse vetor.

### 2.2 Problema de Negócio

O processo atual de integração OrangeHRM → Active Directory depende de exportação manual via CSV, causando corrupção de encoding (acentuação), falhas de integridade e ausência de rastreabilidade de identidade. O ciclo JML (Joiner/Mover/Leaver) não é automatizado.

### 2.3 Solução Aprovada

Implementar uma **Shadow API REST** (FastAPI / Python 3.12) que expõe os dados do OrangeHRM (MariaDB) de forma segura, normalizada e auditável para consumo pelo midPoint IGA, habilitando o ciclo JML completo conforme ISO 27001 A.5.15 (Controle de Acesso) e A.8.15 (Log de Auditoria).

---

## 3. DECISÕES ARQUITETURAIS RESOLVIDAS (ADR — FECHADAS)

Todas as 7 decisões críticas do bloco Pre-Flight foram resolvidas. Este bloco está **100% fechado** e é irrevogável para esta versão do projeto.

| ID | Decisão | Resolução | Referência |
|----|---------|-----------|------------|
| **D1** | Modelo de Hospedagem | VM Dedicada (`api-gf-01`) + Docker Compose | ARQ v2.0 / Peer Review |
| **D2** | Arquitetura de Rede | Tailscale Mesh VPN; `api-gf-01` no IP `xxx.xxx.xxx.xxx` | GATE-PRJ008-001 v2.0 |
| **D3** | Identificador Canônico | **`emp_number`** (mapeado para `employeeID` no AD) — imutável, nunca reciclado | Peer Review — Decisão Final |
| **D4** | Autoridade de Dados | OrangeHRM/MariaDB = **Single Source of Truth (SSoT)** — sem exceções | ARQ v2.0 |
| **D5** | Estados de Identidade | `active / terminated / on_leave / probation / pre_start` → midPoint (JML) | Contrato OpenAPI v2.0 |
| **D6** | Política Vault | Path `secret/orangehrm/*`; operações `read`; token com renovação diária (M-04) | Evidência Vault 10/04 |
| **D7** | Estratégia de Rollback | Snapshot Hyper-V pré-sprint + Git tags versionados + Docker image tags | ARQ v2.0 ADR-D7 |

### 3.1 Contrato Canônico (Non-Negotiables do Peer Review)

Estas três decisões de design são **não negociáveis** e não podem ser alteradas sem aprovação formal de uma nova ADR:

**NN-01 — Âncora Imutável:** O campo `emp_number` da tabela `hs_hr_employee` é a única âncora de correlação entre o OrangeHRM e o midPoint IGA. Ele será mapeado para o atributo `employeeID` no Active Directory. Nenhum outro atributo (nome, e-mail, matrícula textual) pode ser utilizado como chave de correlação.

**NN-02 — Normalização UTF-8 NFC:** Todo string extraído do MariaDB deve ser normalizado para Unicode NFC (`unicodedata.normalize('NFC', value)`) na camada de Data Access antes de ser serializado para JSON. O banco usa charset `utf8mb4` + collation `utf8mb4_unicode_ci`. O header HTTP de resposta deve declarar `Content-Type: application/json; charset=utf-8`.

**NN-03 — Null Handling por Omissão:** Campos opcionais cujo valor é `NULL` no banco **não devem ser incluídos** no payload JSON de resposta. A ausência de um campo sinaliza ao midPoint "sem informação" — diferente de `null`, que pode ser interpretado como instrução de limpeza de atributo no AD. Implementação: `response_model_exclude_none=True` no FastAPI ou equivalente no serializer.

---

## 4. STACK TECNOLÓGICA (APROVADA — IMUTÁVEL)

| Componente | Tecnologia | Versão | Justificativa |
|-----------|-----------|--------|---------------|
| **Linguagem** | Python | 3.12 | Veredito Peer Review; suporte estendido |
| **Framework API** | FastAPI | ≥ 0.110 | Async nativo, OpenAPI automático, Pydantic v2 |
| **ORM / Query** | SQLAlchemy (Core) | 2.0 | Type-safe, async, sem magic ORM que oculte queries |
| **Server** | Uvicorn | ≥ 0.27 | ASGI production-grade |
| **Vault Client** | hvac | ≥ 2.3 | Biblioteca oficial HashiCorp |
| **DB Driver** | mysql-connector-python | ≥ 8.3 | Compatible MariaDB 10.11 |
| **Container** | Docker Compose | v5.0.2 | Verificado em `api-gf-01` |
| **SAST** | Bandit | latest | Pipeline GitHub Actions — Anexo E |
| **SCA** | Safety | latest | Pipeline GitHub Actions — Anexo E |

---

## 5. TOPOLOGIA DE REDE (ESTADO ATUAL — ATUALIZADO)

```
┌──────────────────────────────────────────────────────────────┐
│               TAILSCALE MESH VPN (100.x.x.0/24)              │
│                    MagicDNS + ACLs Enabled                   │
└──────────────────────────────────────────────────────────────┘
         │               │               │               │
  ┌──────▼──────┐  ┌──────▼──────┐  ┌───▼────────┐  ┌──▼──────────┐
  │ vault-gf-01 │  │  iga-gf-01  │  │  api-gf-01 │  │  rh-gf-01   │
  │xxx.xxx.xxx.xxx │  │ 100.69.98.. │  │100.112.18. │  │xxx.xxx.xxx.xxx │
  │             │  │             │  │    .22     │  │             │
  │ HashiCorp   │  │  midPoint   │  │  Shadow    │  │  OrangeHRM  │
  │  Vault      │  │    IGA      │  │   API      │  │  MariaDB    │
  │   :8200     │  │   :8080     │  │   :8000    │  │   :3306     │
  │  ✅ ATIVO   │  │  ✅ ATIVO   │  │ ✅ PRONTO  │  │  ✅ ATIVO   │
  └─────────────┘  └─────────────┘  └────────────┘  └─────────────┘

Host: DESKTOP-O87TPQI | Tailscale: xxx.xxx.xxx.xxx
```

---

## 6. INFRAESTRUTURA — STATUS PRÉ-SPRINT (10/04/2026)

### 6.1 Evidências de Execução Técnica

| ID | Item | Status | Evidência | Data |
|----|------|--------|-----------|------|
| **I-01** | VM `api-gf-01` (Ubuntu 24.04) provisionada e operacional | ✅ **CONCLUÍDO** | SSH ativo; uptime verificado | 10/04/2026 |
| **I-02** | VHDX `IGA-GF-01` migrado para SSD | ✅ **CONCLUÍDO** | VM `iga-gf-01` operacional | Anterior |
| **I-03** | Docker v29.2.1 + Compose v5.0.2 instalados | ✅ **CONCLUÍDO** | `docker --version` validado | 10/04/2026 |
| **I-04** | Tailscale configurado — IP `xxx.xxx.xxx.xxx` | ✅ **CONCLUÍDO** | `tailscale status` confirmado | 10/04/2026 |
| **DB-01** | Usuário `svc_shadow_api` criado — `SELECT` em `ohrm_user` + `hs_hr_employee` | ✅ **CONCLUÍDO** | `GRANT SELECT` confirmado; `FLUSH PRIVILEGES` executado | 10/04/2026 |
| **FW-01** | Porta 3306 acessível de `api-gf-01` via `nc` | ✅ **CONCLUÍDO** | Teste `nc` passou | 10/04/2026 |
| **VLT-01** | `secret/orangehrm/db_api` provisionado no Vault | ✅ **CONCLUÍDO** | `vault kv put` confirmado — campos: `username`, `password`, `db_name`, `db_host` | 10/04/2026 |
| **VLT-02** | `secret/orangehrm/admin` provisionado (referência) | ✅ **CONCLUÍDO** | `vault kv put` confirmado | 10/04/2026 |
| **VLT-03** | Política `api-proxy-policy` | 🟡 **PENDENTE** | A criar — Sprint 1, Dia 1 |  |
| **VLT-04** | Token Vault com TTL configurado na VM | 🟡 **PENDENTE** | A criar — Sprint 1, Dia 1 |  |
| **SEC-01** | Repositório GitHub criado | 🟡 **PENDENTE** | A criar — Sprint 1, Dia 1 |  |
| **SEC-02** | GitHub Actions (Bandit + Safety) | 🟡 **PENDENTE** | A criar — Sprint 1, Dia 2 |  |
| **SEC-03** | Tailscale ACLs refinadas | 🟡 **PENDENTE** | A criar — Sprint 1, Dia 2 |  |

> **Nota de Auditoria:** As evidências dos itens concluídos estão arquivadas em `Evidencias_Prompt_Orange.md`, `Evidencias_Prompt_API.txt` e `Evidencias_Prompt_Vault.txt`. O Vault foi unsealed com 3/5 chaves Shamir e autenticado via root token. O estado do cluster Vault é `standby` com `HA Mode: standby` — verificar `Active Node Address` antes do Sprint 1.

---

## 7. OBJETIVOS DE EXECUÇÃO (v3.0)

### 7.1 Objetivo Geral

Desenvolver, validar e implantar a Shadow API REST com pipeline DevSecOps multicamada, entregando o ciclo JML funcional (OrangeHRM → Shadow API → midPoint → AD) até 17/04/2026.

### 7.2 Critérios de Sucesso da Fase 1

| ID | Critério | Método de Validação | Meta |
|----|----------|---------------------|------|
| CE1 | `GET /oauth/token` retorna JWT válido | `curl` com `client_credentials` | HTTP 200 |
| CE2 | `GET /api/v1/employees` retorna payload conforme OpenAPI | `curl` + validação Pydantic | HTTP 200, encoding UTF-8 NFC |
| CE3 | `GET /health` reflete estado real de dependências | `curl`; testar com Vault sealed | 200/207/503 corretos |
| CE4 | Zero CVEs críticos no código gerado | Bandit (SAST) + Safety (SCA) | 0 findings High/Critical |
| CE5 | JML funcional: Joiner + Mover + Leaver | Testes manuais midPoint | 3/3 cenários passando |
| CE6 | Zero secrets em texto plano no repositório | `grep -r "password"` + `git log` | 0 ocorrências |
| CE7 | Campos nulos omitidos — AD não recebe atributos vazios | Inspeção manual do payload | 100% conformidade NN-03 |
| CE8 | Nomes com acentuação corretos no AD | Validar "André", "Vitória", "Conceição" | NFC validado end-to-end |

---

## 8. CRONOGRAMA — FASE 1 (SPRINT 1–3) ATUALIZADO

**Referência:** 10/04/2026 (Sprint 1 autorizado)

### Sprint 1 — Dia 1 (10/04 ou próxima sessão) — Fundações Seguras

| Horário | Atividade | Responsável | Entregável |
|---------|-----------|-------------|------------|
| H+0:00 | Snapshot Hyper-V `api-gf-01` pré-sprint | Paulo | `PRJ008-Sprint1-PreStart` |
| H+0:30 | Criar repositório GitHub `prj008-shadow-api`; configurar `.gitignore` (`.env`, `*.key`) | Paulo | Repo criado |
| H+1:00 | Criar política Vault `api-proxy-policy` (read em `secret/orangehrm/*`) | Paulo | VLT-03 concluído |
| H+1:30 | Configurar token Vault com TTL 24h na `api-gf-01` | Paulo | VLT-04 concluído |
| H+2:00 | Gerar estrutura do projeto (IA): `app/`, `config.py`, `dependencies.py`, `managers.py` | Paulo + IA | Estrutura de diretórios |
| H+3:00 | Validação Camada 1 (Gemini): revisão arquitetural do código gerado | Paulo (coord.) | Score ≥ 8/10 |

**Critério de Rollback Sprint 1:** Se ao final do Dia 1 a estrutura base não estiver com testes de import passando → Rollback para snapshot; investigar no dia seguinte.

---

### Sprint 2 — Dia 2 — Core Endpoints

| Horário | Atividade | Responsável | Entregável |
|---------|-----------|-------------|------------|
| H+0:00 | Gerar `app/routes/auth.py` — OAuth2 Client Credentials + JWT (IA) | Paulo + IA | `/oauth/token` |
| H+1:00 | Gerar `app/routes/employees.py` — Data Engine com UTF-8 NFC + null omission (IA) | Paulo + IA | `GET /api/v1/employees` |
| H+2:00 | Validação Camada 2 (ChatGPT): SAST manual — checar CWE-89, CWE-200, A01–A07 | Paulo (coord.) | Score SAST ≥ 9/10 |
| H+3:00 | Testes manuais `curl`: `/oauth/token` + `/api/v1/employees` funcionais | Paulo | Evidências de teste |

**Critério de Rollback Sprint 2:** Se `curl` para `/api/v1/employees` não retornar HTTP 200 com payload válido → Rollback para tag `sprint1-stable`.

---

### Sprint 3 — Dia 3 — Health Check + DevSecOps

| Horário | Atividade | Responsável | Entregável |
|---------|-----------|-------------|------------|
| H+0:00 | Gerar `app/routes/health.py` — Health Check L3 (Liveness + Readiness + Deps) | Paulo + IA | `GET /health` (200/207/503) |
| H+0:45 | Configurar GitHub Actions: Bandit (SAST) + Safety (SCA) | Paulo | Pipeline CI ativo |
| H+1:15 | Configurar Tailscale ACLs: bloquear acesso externo à porta 8000 (SEC-03) | Paulo | SEC-03 concluído |
| H+2:00 | Validação Camada 3 (Perplexity): Threat Intelligence — CVEs nas dependências | Paulo (coord.) | Tabela CVEs; aprovação |
| H+3:00 | Validação Camada 4 (Paulo): checklist humano final — Anexo E.4 | Paulo | Checklist assinado |

**Critério de Rollback Sprint 3:** Se Bandit retornar HIGH/CRITICAL ou Perplexity reprovar → Code freeze; não avançar para integração.

---

### Dia 4 — Integração midPoint

| Horário | Atividade | Responsável | Entregável |
|---------|-----------|-------------|------------|
| H+0:00 | Configurar Resource no midPoint (REST Connector) apontando para `api-gf-01:8000` | Paulo | Resource ativo |
| H+1:00 | Teste Joiner: criar colaborador no OrangeHRM → sincronizar → validar conta no AD | Paulo | Evidência JML-J |
| H+1:45 | Teste Mover: transferir departamento → sincronizar → validar atributo `ou` no AD | Paulo | Evidência JML-M |
| H+2:15 | Teste Leaver: registrar desligamento → sincronizar → validar `nsAccountLock=TRUE` | Paulo | Evidência JML-L |

---

### Dia 5 — Encerramento PRJ008

| Atividade | Entregável |
|-----------|------------|
| Snapshot final Hyper-V (todos os nós) | `PRJ008-Sprint-Final` |
| Atualizar TEP-PRJ008 (evidências de execução) | TEP-PRJ008 v1.0 |
| Post-Mortem (lições L1–Ln) | Post-Mortem PRJ008 |
| Registrar PRJ008 como CONCLUÍDO no Obsidian | Status atualizado |
| Abrir TAP-PRJ016 (midPoint como IGA Engine) se aplicável | TAP-PRJ016 draft |

---

## 9. ENTREGÁVEIS

| ID | Entregável | Tipo | Sprint | Status |
|----|-----------|------|--------|--------|
| E1 | ADR-PRJ008-D1 a D7 | Decisões Arquiteturais | Pre-Flight | ✅ CONCLUÍDO |
| E2 | Diagrama de Componentes | Documentação | Planning | ✅ CONCLUÍDO |
| E3 | Contrato OpenAPI v2.0 | Especificação | Planning | ✅ CONCLUÍDO |
| E4 | Matriz de Conectividade | Documentação | Planning | ✅ CONCLUÍDO |
| E5 | Shadow API — código completo (OAuth + /employees + /health) | Software | Sprint 1–3 | 🔲 PENDENTE |
| E6 | Pipeline DevSecOps (Bandit + Safety + GitHub Actions) | DevSecOps | Sprint 3 | 🔲 PENDENTE |
| E7 | Resource midPoint configurado | Configuração | Dia 4 | 🔲 PENDENTE |
| E8 | Evidências de Testes JML (3 cenários) | Evidência | Dia 4 | 🔲 PENDENTE |
| E9 | Snapshots Hyper-V (pré + pós) | Backup | Dia 1 + 5 | 🔲 PENDENTE |
| E10 | Post-Mortem PRJ008 | Análise | Dia 5 | 🔲 PENDENTE |

---

## 10. RISCOS E MITIGAÇÕES (v3.0)

| ID | Risco | Prob | Impacto | Status | Mitigação |
|----|-------|------|---------|--------|-----------|
| R1 | Decisão D1 indefinida | Baixa | Alto | ✅ **FECHADO** | VM `api-gf-01` provisionada |
| R2 | OpenAPI inválido | Baixa | Médio | ✅ **FECHADO** | Contrato OpenAPI v2.0 aprovado |
| R3 | IA gera código com CVE | Média | Crítico | 🟡 **ATIVO** | Pipeline 4 camadas (Anexo E); Bandit + Safety no CI |
| R4 | Testes JML falham | Média | Alto | 🟡 **ATIVO** | Mapeamento de estados documentado; rollback de sprint disponível |
| R5 | Vault token expira durante sprint | Baixa | Médio | ✅ **MITIGADO** | VLT-04: token TTL 24h; cron de rotação (M-04) |
| R6 | Sprint não conclui no dia | Média | Médio | 🟡 **ATIVO** | Rollback obrigatório conforme regra da seção 8; sem tentativas de hotfix no dia |
| R7 | Corrupção de encoding de nomes | Baixa | Alto | ✅ **MITIGADO** | NN-02: UTF-8 NFC mandatório na camada de dados |
| R8 | Drift de atributos no AD por null | Baixa | Alto | ✅ **MITIGADO** | NN-03: omissão de campos nulos; `exclude_none=True` |
| R9 | Vulnerabilidade não detectada no código gerado por IA | Baixa | Crítico | 🟡 **ATIVO** | 4 camadas de validação; rollback automático se falhar |
| R10 | Vault em modo `standby` sem nó ativo | Baixa | Alto | 🟡 **NOVO** | Verificar `Active Node Address` antes de Sprint 1; unseal se necessário |

---

## 11. REGRA DE ROLLBACK (IRREVOGÁVEL)

```
┌────────────────────────────────────────────────────────────────┐
│                   POLÍTICA DE ROLLBACK PRJ008                  │
│                                                                │
│  Se ao final de qualquer Sprint:                               │
│  - O entregável do dia não estiver funcional (curl OK)         │
│  - Ou o pipeline de segurança retornar HIGH/CRITICAL           │
│  - Ou a validação multicamada reprovar                         │
│                                                                │
│  AÇÃO OBRIGATÓRIA:                                             │
│  1. Restaurar snapshot Hyper-V do início do sprint             │
│  2. Fazer git revert para a última tag estável                 │
│  3. Documentar motivo do rollback no log de execução           │
│  4. NÃO tentar hotfix no mesmo dia                             │
│                                                                │
│  PROIBIDO: Avançar para o próximo sprint com entregável        │
│  parcial ou código não validado.                               │
└────────────────────────────────────────────────────────────────┘
```

---

## 12. WORKFLOW DE DESENVOLVIMENTO ASSISTIDO POR IA (ANEXO E — RESUMO)

O desenvolvimento será 100% assistido por IA generativa com validação multicamada obrigatória antes de qualquer commit na branch principal.

### Pipeline de Validação (4 Camadas)

| Camada | Executor | Foco | Gate |
|--------|----------|------|------|
| **L1** | Gemini Pro | Revisão arquitetural; Clean Architecture; DDD; encoding; auditabilidade | Score ≥ 8/10 |
| **L2** | ChatGPT | SAST manual — CWE-89 (Injection), CWE-200 (Exposure), A01–A07 OWASP | Score ≥ 9/10; 0 CVEs |
| **L3** | Perplexity Pro | Threat Intelligence — CVEs por versão de dependência; MITRE ATT&CK | Aprovação SIM/CONDICIONAL |
| **L4** | Paulo (Humano) | Checklist final — secrets, logs, curl, snapshot | Assinatura obrigatória |

### Formato de Commit Obrigatório

```
feat(api): [Componente] vX.Y — AI-Generated + Validated

Generator: [Modelo] (prompt PRJ008-[ID])
Validator L1: Gemini — Score [N]/10
Validator L2: ChatGPT SAST — Score [N]/10, [N] CVEs
Validator L3: Perplexity — [APROVADO/CONDICIONAL]
Validator L4: Paulo — [APROVADO]

Security: Zero hardcoded credentials | SQLAlchemy parametrized | JWT em todos os endpoints
Refs: TAP-PRJ008-v3.0 Anexo E
```

---

## 13. CONFORMIDADE E RASTREABILIDADE

| Controle | Referência | Implementação |
|----------|-----------|---------------|
| Menor Privilégio | ISO 27001 A.5.15 | `svc_shadow_api` — SELECT apenas em 2 tabelas |
| Gestão de Segredos | ISO 27001 A.8.12 | Vault KV v2 — sem credenciais em código ou env file |
| Log de Auditoria | ISO 27001 A.8.15 | Cada chamada à API loga: timestamp, IP, JWT claims, registros retornados |
| Gestão de Capacidade | ISO 27001 A.12.1.3 | Health Check L3 monitora dependências em tempo real |
| Cadeia de Custódia de Código | ISO 27001 A.8.25 | GitHub + assinatura de commits + pipeline CI obrigatório |
| Revisão por Pares | ISO 27001 A.5.3 | 4-eyes principle — 3 IAs + 1 humano antes de merge |

---

## 14. APROVAÇÕES

| Função | Nome | Data | Decisão |
|--------|------|------|---------|
| **Responsável / GP** | Paulo Feitosa Lima | 10/04/2026 | ✅ APROVADO |
| **GRC Lead** | Paulo Feitosa Lima | 10/04/2026 | ✅ APROVADO |
| **Arquiteto Técnico** | Peer Review Multicamada (ChatGPT/Gemini/Perplexity/Claude) | 10/04/2026 | ✅ APROVADO |

---

## 15. CONTROLE DE VERSÃO

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 12/02/2026 | Perplexity AI | Versão inicial |
| 2.0 | 13/02/2026 | Perplexity AI | Planning-first 80/20 |
| **3.0** | **10/04/2026** | **Paulo Feitosa Lima / Claude** | **Execution Ready — Pre-Flight concluído; decisões de design finalizadas; Sprint 1 autorizado** |

---

*Documento gerado com apoio de Claude (Anthropic) — Revisão e aprovação: Paulo Feitosa Lima (GRC Lead)*
*Repositório: Living Lab Fiqueok — PRJ008*
*Próxima revisão: Pós-Sprint 3 (TEP-PRJ008 v1.0)*

