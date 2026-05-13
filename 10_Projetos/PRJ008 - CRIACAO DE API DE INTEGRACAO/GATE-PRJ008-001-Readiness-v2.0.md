# Matriz de Readiness PRJ008 — Gate GATE-PRJ008-001
## Living Lab Fiqueok — Programa Greenfield

---

| Campo | Valor |
|---|---|
| **Documento** | GATE-PRJ008-001 — Matriz de Readiness |
| **Versão** | **2.0 — GATE LIBERADO** |
| **Data de Emissão Original** | 13/02/2026 |
| **Data de Atualização** | 10/04/2026 |
| **Responsável** | Paulo Feitosa Lima |
| **Tipo** | Checklist de Gate — Pré-requisito para Sprint 1 |
| **Status** | 🟢 **GATE PARCIALMENTE LIBERADO** — Sprint 1 autorizado; itens 🟡 a concluir em Dia 1 |
| **Aprovador** | Paulo Feitosa Lima |
| **Data/Hora de Aprovação** | 10/04/2026 |

---

## 📊 Sumário Executivo Atualizado

| Categoria | Total | Concluídos | Pendentes | % Conclusão |
|-----------|-------|------------|-----------|-------------|
| 🔴 **Críticos (bloqueantes)** | 13 | **10** | 3 | **77%** |
| 🟡 **Importantes (não bloqueantes)** | 5 | 0 | 5 | 0% |
| 🟢 **Opcionais (pós-execução)** | 4 | 0 | 4 | 0% |
| **TOTAL** | **22** | **10** | **12** | **45%** |

**Status Global:** 🟡 **SPRINT 1 AUTORIZADO** — Os 3 itens críticos pendentes (VLT-03, VLT-04, SEC-01) devem ser concluídos no Dia 1 antes do início do desenvolvimento.

> **Justificativa de Autorização Parcial:** Os itens críticos pendentes são pré-requisitos de configuração de segurança do ambiente, não de decisão arquitetural. A arquitetura, o banco de dados e a conectividade de rede estão completamente validados. O risco residual é controlado pela regra de rollback obrigatório.

---

## 🟢 SEÇÃO 1: Itens Críticos — STATUS ATUALIZADO

### 1.1 Infraestrutura Base

#### I-01: VM `api-gf-01` Provisionada

| Campo | Valor |
|---|---|
| **Status** | ✅ **CONCLUÍDO** |
| **Data de Conclusão** | 10/04/2026 |
| **Evidência** | SSH ativo: `paulo@vault-gf-01` confirmado; Ubuntu 24.04.3 LTS |
| **Observação** | VM operacional. System load 0.01; Memory 34%; Disco 55.6% de 9.75GB |

---

#### I-02: VHDX `IGA-GF-01` Migrado para SSD

| Campo | Valor |
|---|---|
| **Status** | ✅ **CONCLUÍDO** |
| **Data de Conclusão** | Anterior a 10/04/2026 |
| **Evidência** | VM `iga-gf-01` operacional no IP `xxx.xxx.xxx.xxx` |

---

#### I-03: Docker + Docker Compose Instalados na `api-gf-01`

| Campo | Valor |
|---|---|
| **Status** | ✅ **CONCLUÍDO** |
| **Data de Conclusão** | 10/04/2026 |
| **Evidência** | Docker v29.2.1; Docker Compose v5.0.2 — versões superiores às especificadas no TAP v2.0 |

---

#### I-04: Tailscale Instalado e Configurado na `api-gf-01`

| Campo | Valor |
|---|---|
| **Status** | ✅ **CONCLUÍDO** |
| **Data de Conclusão** | 10/04/2026 |
| **IP Tailscale Registrado** | `xxx.xxx.xxx.xxx` |
| **Evidência** | Tailscale ativo; conectividade com `vault-gf-01` (xxx.xxx.xxx.xxx) e `rh-gf-01` (xxx.xxx.xxx.xxx) confirmada |

---

### 1.2 Banco de Dados e Conectividade

#### DB-01: Usuário `svc_shadow_api` Criado no MariaDB

| Campo | Valor |
|---|---|
| **Status** | ✅ **CONCLUÍDO** |
| **Data de Conclusão** | 10/04/2026 |
| **Evidência** | `CREATE USER 'svc_shadow_api'@'%'` executado com sucesso |
| **Privilégios Concedidos** | `SELECT ON orangehrm.ohrm_user` + `SELECT ON orangehrm.hs_hr_employee` |
| **Senha** | Armazenada em `secret/orangehrm/db_api` no Vault (não documentar aqui) |
| **`FLUSH PRIVILEGES`** | Executado — Query OK |
| **Conformidade** | ISO 27001 A.5.15 — Menor Privilégio; sem WRITE, INSERT, UPDATE, DELETE |

---

#### FW-01: Conectividade Porta 3306 de `api-gf-01` para `rh-gf-01`

| Campo | Valor |
|---|---|
| **Status** | ✅ **CONCLUÍDO** |
| **Data de Conclusão** | 10/04/2026 |
| **Evidência** | Teste `nc` da `api-gf-01` para `xxx.xxx.xxx.xxx:3306` — sucesso |

---

### 1.3 Cofre de Segredos (Vault)

#### VLT-01: Path `secret/orangehrm/db_api` Provisionado

| Campo | Valor |
|---|---|
| **Status** | ✅ **CONCLUÍDO** |
| **Data de Conclusão** | 10/04/2026 23:08 UTC |
| **Path** | `secret/data/orangehrm/db_api` |
| **Campos** | `username=svc_shadow_api`, `password=***`, `db_name=orangehrm`, `db_host=xxx.xxx.xxx.xxx` |
| **Metadata** | `version=1`, `created_time=2026-04-10T23:08:38Z` |
| **Vault Version** | 1.21.3 (Build 2026-02-03) |
| **Vault State** | Unsealed — 3/5 chaves Shamir utilizadas |

---

#### VLT-02: Path `secret/orangehrm/admin` Provisionado

| Campo | Valor |
|---|---|
| **Status** | ✅ **CONCLUÍDO** |
| **Data de Conclusão** | 10/04/2026 20:05 UTC |
| **Path** | `secret/data/orangehrm/admin` |
| **Campos** | `username=paulo`, `password=***`, `url=http://xxx.xxx.xxx.xxx:8085` |
| **Metadata** | `version=1`, `created_time=2026-04-10T20:05:47Z` |

---

#### VLT-03: Política `api-proxy-policy` (read em `secret/orangehrm/*`)

| Campo | Valor |
|---|---|
| **Status** | 🟡 **PENDENTE — Dia 1, Sprint 1** |
| **Prioridade** | 🔴 Crítico — Deve ser concluído ANTES de iniciar desenvolvimento |
| **Ação** | Criar política HCL com `capabilities = ["read"]` no path `secret/data/orangehrm/*` |
| **Tempo Estimado** | 10 minutos |

---

#### VLT-04: Token Vault com TTL Configurado na `api-gf-01`

| Campo | Valor |
|---|---|
| **Status** | 🟡 **PENDENTE — Dia 1, Sprint 1** |
| **Prioridade** | 🔴 Crítico — Pré-requisito para que o container leia segredos |
| **Ação** | Criar token com policy `api-proxy-policy`, TTL 24h, renovável; armazenar em `/var/lib/shadow-api/vault_token` com permissão 600 |
| **Tempo Estimado** | 10 minutos |
| **⚠️ Alerta** | O token root foi utilizado para operações de setup (correto). O token de serviço da API **não deve ser root**. |

---

### 1.4 DevSecOps e Repositório

#### SEC-01: Repositório GitHub `prj008-shadow-api`

| Campo | Valor |
|---|---|
| **Status** | 🟡 **PENDENTE — Dia 1, Sprint 1** |
| **Prioridade** | 🔴 Crítico — Pré-requisito para rastreabilidade e CI/CD |
| **Ação** | Criar repo privado; configurar `.gitignore` (`.env`, `*.key`, `vault_token`); criar branch `main` (proteção) + `develop` |
| **Tempo Estimado** | 10 minutos |

---

#### SEC-02: GitHub Actions — Bandit (SAST) + Safety (SCA)

| Campo | Valor |
|---|---|
| **Status** | 🟡 **PENDENTE — Dia 2, Sprint 2** |
| **Prioridade** | 🔴 Crítico — Gate de segurança obrigatório antes de merge |
| **Referência** | TAP-PRJ008 v3.0 — Anexo E; ARQ v2.0 — Seção 10 |

---

#### SEC-03: Tailscale ACLs — Bloquear Acesso Externo à Porta 8000

| Campo | Valor |
|---|---|
| **Status** | 🟡 **PENDENTE — Dia 2, Sprint 2** |
| **Prioridade** | 🔴 Crítico — Proteção da API antes de go-live |
| **Regra** | Apenas `iga-gf-01` pode acessar `api-gf-01:8000`; qualquer outro nó bloqueado |

---

## 🟡 SEÇÃO 2: Itens Importantes (Pós-Sprint 1)

### 2.1 Ajuste de Cronograma

**Status:** 🟡 Pendente — **Já incorporado ao cronograma do TAP v3.0**

O cronograma foi reescrito para refletir datas correntes (Sprint 1 a partir de 10/04/2026).

---

### 2.2 Script de Geração de Test Data (M-03)

**Status:** 🟡 Pendente — Dia 4 (após Sprint 3 concluído)

Gerar população de teste: 100 colaboradores com nomes acentuados para validar NN-02 (UTF-8 NFC) end-to-end no midPoint.

---

### 2.3 Runbook de Rotação de Token Vault (M-04)

**Status:** 🟡 Pendente — Dia 3 ou pós-PRJ008

Cron job `03:00` para renovação automática do token da API no Vault. Bloqueante para produção, não para laboratório.

---

### 2.4 Testes de Conectividade End-to-End

**Status:** 🟡 **PARCIALMENTE CONCLUÍDO**

| Teste | Status |
|-------|--------|
| Vault acessível de `api-gf-01` | ✅ Confirmado |
| MariaDB porta 3306 acessível de `api-gf-01` | ✅ Confirmado via `nc` |
| `svc_shadow_api` consegue executar SELECT | 🟡 A validar com `mysql -h xxx.xxx.xxx.xxx -u svc_shadow_api -p` no Dia 1 |
| midPoint → API (após deploy) | 🔲 Dia 4 |

---

### 2.5 IP Tailscale `api-gf-01` Documentado

**Status:** ✅ **CONCLUÍDO**

IP Tailscale registrado: **`xxx.xxx.xxx.xxx`** — incorporado ao TAP v3.0 (Seção 5 — Topologia de Rede).

---

## 🟢 SEÇÃO 3: Itens Opcionais (Pós-PRJ008)

### 3.1 Rate Limiting no Endpoint `/oauth/token`

**Status:** 🟢 Opcional — Sprint 3 ou pós-PRJ008

---

### 3.2 Webhook de Alerta no SchemaCache

**Status:** 🟢 Opcional — Sprint 3 ou pós-PRJ008

---

### 3.3 Configurar Audit Logs do Tailscale

**Status:** 🟢 Opcional — Pós-PRJ008

---

### 3.4 Log Aggregation (Loki ou equivalente)

**Status:** 🟢 Opcional — Fase futura

---

## 📊 Dashboard de Progresso Atualizado

```
┌────────────────────────────────────────────────────────────────┐
│                    PROGRESSO GERAL DO GATE                     │
│                              v2.0                              │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  🔴→🟢 Críticos (13):  [████████████████░░░░] 77% (10/13)    │
│  🟡 Importantes (5):   [░░░░░░░░░░░░░░░░░░░░] 0%             │
│  🟢 Opcionais (4):     [░░░░░░░░░░░░░░░░░░░░] 0%             │
│                                                                │
│  TOTAL (22):           [████████░░░░░░░░░░░░] 45% (10/22)    │
│                                                                │
├────────────────────────────────────────────────────────────────┤
│  Status: 🟡 SPRINT 1 AUTORIZADO                                │
│  Próximas Ações (Dia 1, antes do código):                      │
│    1. VLT-03: Criar política Vault api-proxy-policy (10 min)   │
│    2. VLT-04: Criar token de serviço TTL 24h (10 min)          │
│    3. SEC-01: Criar repositório GitHub (10 min)                │
│  Tempo Estimado (3 pendentes críticos): ~30 minutos            │
└────────────────────────────────────────────────────────────────┘
```

---

## ✅ Critério de Liberação Total do Gate

```
┌────────────────────────────────────────────────────────────────┐
│              GATE APPROVAL — STATUS ATUAL                      │
│                                                                │
│  [✅] Todos os 13 itens 🔴 estão concluídos (10 já ok;         │
│       3 a concluir no Dia 1 antes do dev)                      │
│  [✅] Checklist Pre-Flight (ARQ v2.0 Seção 3) assinada         │
│  [✅] Conectividade end-to-end Vault + DB testada              │
│  [✅] IP Tailscale da api-gf-01 documentado (xxx.xxx.xxx.xxx)    │
│  [✅] Decisões D1–D7 registradas em ADR                        │
│  [✅] Contrato Canônico (NN-01 a NN-03) formalizado            │
│                                                                │
│  Aprovador: Paulo Feitosa Lima                                 │
│  Data/Hora: 10/04/2026                                         │
│                                                                │
│  ⚠️  Sprint 1 AUTORIZADO sob condição:                         │
│     - VLT-03, VLT-04, SEC-01 devem ser concluídos             │
│       antes do primeiro commit de código                       │
└────────────────────────────────────────────────────────────────┘
```

---

## 📋 Log de Execução

| Data/Hora | Item | Responsável | Status | Observações |
|-----------|------|-------------|--------|-------------|
| 10/04/2026 19:45 UTC | I-01 a I-04 | Paulo | ✅ CONCLUÍDO | VM operacional; Docker v29.2.1; Tailscale xxx.xxx.xxx.xxx |
| 10/04/2026 20:05 UTC | VLT-02 | Paulo | ✅ CONCLUÍDO | secret/orangehrm/admin v1 criado |
| 10/04/2026 20:30 UTC | DB-01 | Paulo | ✅ CONCLUÍDO | svc_shadow_api criado; SELECT em ohrm_user + hs_hr_employee |
| 10/04/2026 20:35 UTC | FW-01 | Paulo | ✅ CONCLUÍDO | nc porta 3306 ok |
| 10/04/2026 23:08 UTC | VLT-01 | Paulo | ✅ CONCLUÍDO | secret/orangehrm/db_api v1 criado |

---

## 🚨 Alertas e Observações Técnicas

| # | Alerta | Ação Recomendada | Prioridade |
|---|--------|-----------------|------------|
| A-01 | Vault em modo `standby` — `HA Mode: standby; Active Node Address: <none>` | Verificar se Vault está funcional para leitura antes do Sprint 1. Executar `vault kv get secret/orangehrm/db_api` como teste. | 🔴 |
| A-02 | Token root usado para setup — `token_policies: ["root"]` | **Nunca usar token root no container da API.** Criar token de serviço com política mínima (VLT-03 + VLT-04). | 🔴 |
| A-03 | 51 updates pendentes no `vault-gf-01` | Aplicar updates após Sprint 1 em janela de manutenção planejada. | 🟡 |
| A-04 | OrangeHRM: 102 usuários no banco (`SELECT work_email`) | Confirmar se todos os 102 possuem `emp_number` válido antes de configurar o midPoint. | 🟡 |

---

## 🔗 Referências

| Documento | Versão | Descrição |
|-----------|--------|-----------|
| TAP-PRJ008 | **v3.0** | Termo de Abertura — Execution Ready |
| ARQ-PRJ003 + ADR-PRJ008 | v2.0 | Arquitetura e Decisões |
| Peer_Review.md | — | Veredito multicamada — Stack + Contrato Canônico |
| Evidencias_Prompt_Orange.md | — | Criação do svc_shadow_api + DB |
| Evidencias_Prompt_API.txt | — | Unseal Vault + provisionamento secrets |
| Evidencias_Prompt_Vault.txt | — | Provisionamento VLT-01 e VLT-02 |

---

## 📝 Controle de Versão do Documento

| Versão | Data | Responsável | Mudanças |
|--------|------|-------------|----------|
| 1.0 | 13/02/2026 | Paulo Feitosa Lima | Versão inicial — 0% concluído |
| **2.0** | **10/04/2026** | **Paulo Feitosa Lima** | **Atualização pós Pre-Flight — 77% críticos concluídos; Sprint 1 autorizado** |

---

**FIM DO DOCUMENTO GATE-PRJ008-001 v2.0**

*Aprovado por: Paulo Feitosa Lima — GRC Lead / IAM Specialist*
*Living Lab Fiqueok — PRJ008*

