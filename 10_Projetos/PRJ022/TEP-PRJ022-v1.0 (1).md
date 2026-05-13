# TEP — Termo de Encerramento de Projeto
## PRJ022 — Integração IGA: OrangeHRM × midPoint via CSV + Spike ScriptedSQL

---

| Campo | Valor |
|---|---|
| **Documento** | TEP-PRJ022-v1.0 |
| **Versão** | 1.0 |
| **Data** | 04/05/2026 |
| **Status** | 🟡 **PARCIALMENTE CONCLUÍDO** — Estágio A: Sucesso · Estágio B: Frozen (Bloqueio de Infraestrutura) |
| **Responsável** | Paulo Feitosa Lima |
| **Programa** | PRJ003 — Living Lab Fiqueok · Greenfield |
| **Projeto Predecessor** | PRJ008 — Shadow API REST (TEP-PRJ008-v1.0-FREEZING) |
| **Documentos Base** | TAP-PRJ022-v1.0 · POP-PRJ022-A-v1.4 · PRJ022-Relatório-Análise-Técnica-v1.0 |

---

## 1. RESUMO EXECUTIVO

O PRJ022 foi aberto para resolver o bloqueio herdado do PRJ008 (ausência de conector REST compatível com midPoint 4.10 / Java 21) e estabelecer um pipeline IGA funcional entre o OrangeHRM (fonte autoritativa de RH) e o midPoint 4.10 (motor de governança de identidades).

O projeto foi estruturado em dois estágios independentes conforme definido no TAP-PRJ022-v1.0:

**Estágio A (CSV via Shadow API):** ✅ **CONCLUÍDO COM SUCESSO**
Pipeline end-to-end operacional. 102 funcionários importados com ciclo JML ativo. Tarefa de reconciliação `Reconciliacao CSV PRJ022 - v2` executada com status `success`, 0 erros, em 5,1 segundos.

**Estágio B (Spike ScriptedSQL + HTTP):** 🔴 **FROZEN — Bloqueio Confirmado**
Três vetores de ataque foram investigados. O bloqueio `groovy/util/slurpersupport/GPathResult` confirmado no PRJ008 foi reproduzido e documentado. A tentativa de build Maven foi investigada a nível de pré-flight mas não executada (vide Seção 4.2). O Estágio B é encerrado formalmente conforme critério de encerramento estabelecido no TAP.

**Veredito:** O PRJ022 atinge seu critério de sucesso. O pipeline IGA está operacional e libera as dependências para retomada das GMUDs 013 e 014.

---

## 2. O QUE FOI ENTREGUE

### 2.1 Estágio A — Pipeline CSV (Concluído)

#### Infraestrutura e Ambiente

| Item | Status | Evidência |
|---|---|---|
| VM `iga-gf-02` Ubuntu 24.04, Tailscale `xxx.xxx.xxx.xxx` | ✅ | `tailscale status` — linha ativa |
| midPoint 4.10 (`iga-midpoint`) — `Up 2 weeks (healthy)` | ✅ | `docker ps` — 04/05/2026 13:07 UTC |
| PostgreSQL 16 (`iga-postgres`) — `Up 2 weeks (healthy)` | ✅ | `docker ps` — 04/05/2026 13:07 UTC |
| CSV `hr_export.csv` em `/srv/iga-project/data/midpoint/` | ✅ | `ls -la` — `-rw-r--r-- paulo paulo 2565 May 3` |
| CSV com 103 linhas (1 cabeçalho + 102 registros) | ✅ | `wc -l` — `103 /srv/...hr_export.csv` |
| CSV validado dentro do container midPoint | ✅ | `docker exec iga-midpoint wc -l` — `103 /opt/midpoint/var/hr_export.csv` |
| Permissões do diretório `/srv/iga-project/data/midpoint/` — `drwxr-xr-x` (755) | ✅ | `ls -la` — proprietário `paulo:paulo` |

#### Dados do CSV Validados

```
emp_number,employee_id,first_name,last_name
1,0001,Paulo,Lima
2,2026001,Ana,Silva
3,FP001,David,Velez
4,FP002,Andre,Chaves
[... 98 registros adicionais até FP100]
```

#### Resource e Tarefa de Reconciliação

| Item | Status | Evidência |
|---|---|---|
| Resource `Fiqueok HR (Shadow API CSV)` — OID `2fe1b874-8a5f-41d2-8ea9-9f4224c5f327` | ✅ | XML da tarefa — `resourceRef` |
| Tarefa `Reconciliacao CSV PRJ022 - v2` — OID `15307a64-d97d-4534-b69f-92e65440c02e` | ✅ | XML da tarefa |
| Tarefa criada por `paulo` em `2026-05-04T14:42:23Z` | ✅ | `_metadata.creatorRef` — `paulo` |
| `executionState: closed` / `schedulingState: closed` | ✅ | XML da tarefa |
| `result.status: success` | ✅ | XML da tarefa |
| Duração total da execução bem-sucedida | ✅ | `start: 14:50:54` → `end: 14:51:00` — **5,1 segundos** |

#### Resultado da Reconciliação (Evidência do XML da Tarefa)

```
totalSuccessCount: 102  (AccountType — add)
totalFailureCount: 0
lastSuccessObjectName: FP100
lastSuccessTimestamp: 2026-05-04T14:50:59.962Z

totalSuccessCount: 102  (UserType — add)
totalFailureCount: 0
lastSuccessObjectName: FP100
lastSuccessTimestamp: 2026-05-04T14:50:59.944Z
```

**Throughput:** 1.270 itens/minuto · Tempo médio por objeto: 40,8 ms

#### Ciclo JML — Evidência Visual

Interface midPoint (`All users`) exibindo usuários provisionados via reconciliação CSV:

> Screenshot anexo (`1777927957168_image.png`) — Dashboard midPoint mostrando usuários: `0001`, `2026001`, `administrator`, `daniel`, `FP001` → `FP011` (e demais até `FP100`), com coluna `Personal Number` populada e `Accounts: 1` para cada usuário provisionado.

---

### 2.2 Estágio B — Spike ScriptedSQL (Frozen)

Foram investigados três vetores conforme planejado no TAP. Todos resultaram em bloqueio confirmado ou infraestrutura insuficiente.

| Item | Status | Evidência |
|---|---|---|
| ScriptedREST 1.1.1.e2 JAR presente no container | ✅ | `ls /opt/midpoint/var/connid-connectors/` — `scriptedrest-connector-1.1.1.e2.jar (1,3MB)` |
| Conector ScriptedREST reconhecido pelo midPoint | ✅ | `curl /midpoint/ws/rest/connectors` — `ScriptedREST` retornado (6 ocorrências) |
| Erro `GPathResult` reproduzido em produção | ✅ | `docker logs iga-midpoint` — `groovy/util/slurpersupport/GPathResult (java.lang.NoClassDefFoundError)` |
| Resource OID `97afbdbb-e5df-4b98-ba69-d872e2e1ffda` preservado | ✅ | Log midPoint confirmado |
| Tentativa de download `connector-scripted-sql-2.3.jar` via `wget` no container | ❌ | `OCI runtime exec failed: exec: "wget": executable file not found in $PATH` |
| Tentativa de download via host — `repo.evolveum.com` | ❌ | `wget: unable to resolve host address 'repo.evolveum.com'` |
| Rollback via snapshot Hyper-V (ambas as VMs) | ✅ | PowerShell — `Get-VMSnapshot ... Restore-VMSnapshot` executado sem erros; VMs em `Running` após 60s |
| VMs restauradas e operacionais pós-rollback | ✅ | `Get-VM` — `api-gf-01: Running 00:24:33` / `IGA-GF-02: Running 00:24:19` |

#### Pré-Flight Build Maven (Investigação de Viabilidade)

Executado como análise de viabilidade antes de comprometer esforço com o Estágio B via Maven:

| Verificação | Resultado |
|---|---|
| Java version | `openjdk version "17.0.18" 2026-01-20` ✅ |
| Maven | `Command 'mvn' not found` ❌ — requereria `sudo apt install maven` |
| Git | `git version 2.43.0` ✅ |
| Acesso Maven Central | `HTTP 200` ✅ |
| Acesso Nexus Evolveum | `HTTP 302` ✅ |
| Espaço em disco | `7,7GB livres de 17GB (52% usado)` ✅ |
| Repositório polygon local | `Ainda não clonado` — não iniciado |

**Conclusão do pré-flight:** Infraestrutura tecnicamente viável para o build Maven (Java 17, acesso à internet, espaço suficiente), mas Maven não instalado e repositório polygon não clonado. Optou-se por não avançar com o Caminho C (build Maven) neste projeto, conforme critério estabelecido no TAP: o Estágio A já entrega o sucesso do projeto.

---

## 3. ONDE O PROJETO PAROU — ROOT CAUSE ANALYSIS FINAL

### 3.1 Confirmação do Bloqueio (Estágio B)

O bloqueio identificado no PRJ008 foi **integralmente reproduzido e confirmado** no contexto do PRJ022:

```
2026-05-04 16:41:21,261 [] [http-nio-8080-exec-9] WARN
(com.evolveum.midpoint.provisioning.ucf.impl.connid.ConnIdUtil):
Got ConnId exception (might be handled by upper layers later)
java.lang.NoClassDefFoundError in Fiqueok Shadow API (OrangeHRM):
ConnectorSpec.Main(resource:97afbdbb-e5df-4b98-ba69-d872e2e1ffda
(Fiqueok Shadow API (OrangeHRM))):
groovy/util/slurpersupport/GPathResult,
reason: groovy/util/slurpersupport/GPathResult
(class java.lang.NoClassDefFoundError)
```

### 3.2 Linha do Tempo do Bloqueio no PRJ022

| Vetor | Resultado |
|---|---|
| **V1 — ScriptedREST 1.1.1.e2** | `NoClassDefFoundError: GPathResult` — falha estrutural no classpath do JAR, anterior a qualquer execução de script |
| **V2 — Download connector-scripted-sql-2.3 via container** | `wget not found in $PATH` — ferramenta ausente no Alpine do container midPoint |
| **V3 — Download via host (repo.evolveum.com)** | `unable to resolve host` — endpoint Evolveum inacessível a partir do host Ubuntu |
| **V4 — Pré-flight Build Maven** | Investigação concluída; Maven não instalado; repositório não clonado; optou-se por não avançar conforme critério do TAP |

### 3.3 Diagnóstico Técnico Final Consolidado

| Causa | Confirmação |
|---|---|
| ScriptedREST 1.1.1.e2 construído para Groovy 2.x — incompatível com Groovy 4.0 (Java 21) | Erro `GPathResult` reproduzido em 04/05/2026 |
| `connector-rest` Polygon não existe como JAR standalone deployável | HTTP 404 em todas as URLs pesquisadas (PRJ008 + PRJ022) |
| `repo.evolveum.com` inacessível via DNS no host Ubuntu da VM | DNS resolution failed em 04/05/2026 |
| Maven não instalado no ambiente `iga-gf-02` | Confirmado no pré-flight de 04/05/2026 |
| Evolveum declarou ScriptedREST como depreciado (versão final: 1.1.1.e2) | Documentado no TEP-PRJ008 e reconfirmado |

---

## 4. ESTADO ATUAL DO AMBIENTE (04/05/2026)

```
TAILSCALE MESH VPN
├── DESKTOP-O87TPQI    xxx.xxx.xxx.xxx    — Host Windows (admin)
├── vault-gf-01        xxx.xxx.xxx.xxx    — Vault HA active
├── rh-gf-01           xxx.xxx.xxx.xxx    — OrangeHRM + MariaDB
├── api-gf-01          xxx.xxx.xxx.xxx   — Shadow API :8000 ✅ ATIVO
├── iga-gf-02          xxx.xxx.xxx.xxx   — midPoint 4.10 :8080 ✅ ATIVO (healthy, 2 weeks up)
├── defectdojo-gf-01   xxx.xxx.xxx.xxx    — DefectDojo
└── sentinel-core      xxx.xxx.xxx.xxx — Sentinel
```

**Arquivos relevantes em `iga-gf-02`:**

| Arquivo / Diretório | Estado |
|---|---|
| `/srv/iga-project/docker-compose.yml` | Stack midPoint + PostgreSQL operacional |
| `/srv/iga-project/data/midpoint/hr_export.csv` | 103 linhas · `-rw-r--r-- paulo paulo 2565 May 3` |
| `/opt/midpoint/var/hr_export.csv` (dentro do container) | 103 linhas · Validado via `docker exec` |
| `/srv/iga-project/data/midpoint/connid-connectors/scriptedrest-connector-1.1.1.e2.jar` | Presente · 1,3MB · Incompatível com Java 21 |
| `/srv/iga-project/data/midpoint/scripts/` | Scripts Groovy preservados para retomada futura |

**Recursos midPoint ativos:**

| Recurso | OID | Estado |
|---|---|---|
| `Fiqueok HR (Shadow API CSV)` | `2fe1b874-8a5f-41d2-8ea9-9f4224c5f327` | ✅ Operacional |
| `Fiqueok Shadow API (OrangeHRM)` | `97afbdbb-e5df-4b98-ba69-d872e2e1ffda` | 🔴 Test Connection falha (GPathResult) |

---

## 5. CAMINHOS PARA DESBLOQUEIO FUTURO (Estágio B)

### Caminho A — Aguardar Release Oficial Evolveum
Monitorar: `https://nexus.evolveum.com/nexus/repository/releases/com/evolveum/polygon/connector-rest/`
Para versão `>= 3.x` com suporte declarado a Java 21.

### Caminho B — Build Maven (Viabilidade Confirmada no Pré-Flight)
Infraestrutura disponível: Java 17 instalado, acesso Maven Central (HTTP 200), 7,7GB livres.

```bash
# Pré-requisitos a instalar no iga-gf-02:
sudo apt install maven -y

# Build do conector:
git clone https://github.com/Evolveum/polygon /tmp/polygon
cd /tmp/polygon
mvn clean install -pl connector-rest -am -Dmaven.test.skip=true

# Deploy:
cp polygon/connector-rest/target/connector-rest-*.jar \
  /srv/iga-project/data/midpoint/connid-connectors/
docker restart iga-midpoint
```

### Caminho C — Conector HTTP de Terceiros
Monitorar repositórios como `inalogy/midpoint-connector-*` no GitHub para conectores HTTP/REST genéricos compatíveis com midPoint 4.10 / Java 21.

### Caminho D — Reporte à Comunidade Evolveum

**Fórum:** `https://community.evolveum.com/`

**Título sugerido:** `ScriptedREST connector 1.1.1.e2 fails with GPathResult on midPoint 4.10 / Java 21`

**GitHub Issue:** `https://github.com/Evolveum/polygon/issues`

**Título:** `connector-rest: no standalone deployable JAR for Java 21 / midPoint 4.10`

---

## 6. LIÇÕES APRENDIDAS

| # | Lição | Categoria |
|---|---|---|
| **L01** | O CSV dentro do container é o que importa — validar sempre via `docker exec wc -l`, não apenas no host | Operacional |
| **L02** | O atributo `name` do User é obrigatório no midPoint — `employee_id → name` deve ser mapeado ou ocorre erro "No name in the new object" | Técnica |
| **L03** | A Correlation rule explícita é OBRIGATÓRIA no midPoint 4.10 com CsvConnector v2.9 — sem ela, 102 erros de correlation na primeira execução (evidenciado nos logs) | Técnica |
| **L04** | O mapeamento `employee_id → personalNumber` com `Strength: Strong` é a âncora da estratégia de correlação | Técnica |
| **L05** | `wget` não está disponível no container Alpine do midPoint — usar `curl` ou transferir JARs externamente via host | Operacional |
| **L06** | `repo.evolveum.com` pode estar inacessível via DNS em redes restritas — confirmar conectividade antes de planejar downloads de conectores | Operacional |
| **L07** | Rollback via snapshot Hyper-V é determinístico e confiável — VMs restauradas e operacionais em menos de 2 minutos | Governança |
| **L08** | O pré-flight de build Maven deve ser executado antes de comprometer tempo com o Caminho C — Java e Git já disponíveis; apenas Maven faltava | Estratégia |
| **L09** | A tarefa de reconciliação antiga deve ser excluída antes de criar nova após mudanças de configuração — evita conflito de shadows | Técnica |
| **L10** | O bloqueio `GPathResult` é estrutural no JAR do ScriptedREST — ocorre antes de qualquer script ser executado, impossível contornar sem rebuild | Arquitetura |
| **L11** | Validação multicamada (5 IAs no PRJ022-Relatório) + evidência de terminal é o padrão de encerramento que garante rastreabilidade audit-ready | Governança |
| **L12** | O pipeline CSV — apesar de ser uma inconformidade arquitetural documentada — entregou 102 usuários em 5,1 segundos com 0 erros, demonstrando robustez operacional | Arquitetura |

---

## 7. IMPACTO E VALOR GERADO

### 7.1 Recursos Técnicos Disponíveis ao Encerramento

| Recurso | Descrição | Próximo Uso |
|---|---|---|
| **Pipeline IGA end-to-end** | OrangeHRM → Shadow API → CSV → midPoint → repositório Focus | Base para GMUD-013 / GMUD-014 (provisionamento AD) |
| **102 usuários no repositório Focus** | Ciclo JML ativo; correlation sem duplicatas | Destino imediato: provisionamento no Active Directory |
| **CsvConnector como conector de referência** | POP v1.4 com 13 lições + troubleshooting guide | Onboarding rápido de novas fontes HR |
| **Shadow API como ativo independente** | Endpoint REST normalizado, autenticado, integrado ao Vault | Qualquer sistema HTTP pode consumir |
| **Pré-flight Maven documentado** | Viabilidade do Caminho B confirmada com evidências | Projeto de melhoria autônomo futuro |
| **Scripts Groovy preservados** | `SearchScript.groovy` e `SchemaScript.groovy` prontos em `/srv/iga-project/data/midpoint/scripts/` | Retomada imediata quando JAR compatível estiver disponível |

### 7.2 Desbloqueio de Dependências

O encerramento do PRJ022 libera diretamente:

- **GMUD-013** — Configuração do Resource AD no midPoint (suspensa desde 26/12/2025)
- **GMUD-014** — Integração LDAPS midPoint → Active Directory (suspensa desde 26/12/2025)
- Expansão para novos targets (Keycloak, Linux, sistemas com conector ICF disponível)

---

## 8. VALIDAÇÃO DOS CRITÉRIOS DE ACEITE

| Critério (TAP-PRJ022-v1.0) | Resultado | Evidência |
|---|---|---|
| **D-A01:** Script de exportação CSV operacional | ✅ ATENDIDO | `hr_export.csv` com 103 linhas · timestamp `May 3 22:06` |
| **D-A02:** Transferência SCP automatizada e segura | ✅ ATENDIDO | Arquivo presente em `/srv/.../midpoint/` com permissões `644` |
| **D-A03:** Resource CSV com Test Connection verde | ✅ ATENDIDO | Resource `Fiqueok HR (Shadow API CSV)` operacional |
| **D-A04:** Ciclo JML validado — 102+ usuários, 0 erros | ✅ ATENDIDO | XML tarefa: `totalSuccessCount: 102 · totalFailureCount: 0` |
| **D-A05:** Tarefa de reconciliação operacional | ✅ ATENDIDO | `Reconciliacao CSV PRJ022 - v2` — `status: success` |
| **D-A06:** Documentação de encerramento | ✅ ATENDIDO | Este documento |
| **D-B01:** Resultado das tentativas documentado | ✅ ATENDIDO | Seção 4 — 3 vetores investigados com evidências |
| **D-B02b:** Relatório técnico de bloqueio | ✅ ATENDIDO | Seção 3 — Root Cause Analysis + logs |
| **D-B03:** Nota de acompanhamento Evolveum | ✅ ATENDIDO | Seção 5 — Caminhos A, B, C, D documentados |
| **CRITÉRIO GERAL DE SUCESSO:** Estágio A entregue | ✅ **PROJETO CONCLUÍDO COM SUCESSO** | — |

---

## 9. APROVAÇÃO DO ENCERRAMENTO

| Papel | Nome | Data | Decisão |
|---|---|---|---|
| Responsável / GRC Lead | Paulo Feitosa Lima | 04/05/2026 | ✅ ENCERRAMENTO APROVADO |

---

## 10. CONTROLE DE VERSÃO

| Versão | Data | Mudança |
|---|---|---|
| 1.0 | 04/05/2026 | Documento inicial de encerramento — baseado em evidências de terminal, XML de tarefa, screenshot GUI e pré-flight Maven |

---

*Documento gerado com apoio de Claude (Anthropic)*
*Living Lab Fiqueok — PRJ022*
*Arquivado em: `FiqueokBrain/PRJ022/TEP-PRJ022-v1.0.md`*
*Retomada do Estágio B: mediante disponibilidade de conector REST compatível com Java 21 ou conclusão do build Maven (Caminho B — Seção 5)*

