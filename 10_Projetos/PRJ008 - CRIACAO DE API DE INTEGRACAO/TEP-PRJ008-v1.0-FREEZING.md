# TEP — Termo de Encerramento de Projeto (Freezing)
## PRJ008 — Shadow API REST · OrangeHRM × midPoint IGA

---

| Campo | Valor |
|---|---|
| **Documento** | TEP-PRJ008-v1.0-FREEZING |
| **Versão** | 1.0 |
| **Data** | 14/04/2026 |
| **Status** | 🔴 **FROZEN** — Bloqueio Técnico de Infraestrutura |
| **Responsável** | Paulo Feitosa Lima |
| **Programa** | PRJ003 — Living Lab Fiqueok · Greenfield |
| **Motivo do Freeze** | Incompatibilidade de conector REST com midPoint 4.10 / Java 21 |

---

## 1. RESUMO EXECUTIVO

O PRJ008 entregou com sucesso a Shadow API REST (Sprints 1–5), mas foi bloqueado na Sprint 6 (integração midPoint) por ausência de um conector REST compatível com o ambiente midPoint 4.10/Java 21. Todas as alternativas técnicas disponíveis foram esgotadas sem build Java customizado. O projeto é congelado até que a comunidade Evolveum ou um novo release do Polygon disponibilize um JAR standalone compatível.

---

## 2. O QUE FOI ENTREGUE (CONCLUÍDO)

### 2.1 Infraestrutura

| Item | Status | Evidência |
|------|--------|-----------|
| VM `api-gf-01` Ubuntu 24.04, Tailscale `xxx.xxx.xxx.xxx` | ✅ | Terminal Sprint 1 |
| Docker v29.2.1 + Compose v5.0.2 | ✅ | Terminal Sprint 1 |
| Vault HA active, policy `api-proxy-policy` | ✅ | `Evidencia_Terminal_-_Vault.md` |
| Token de serviço em `/var/lib/shadow-api/vault_token` (chmod 600) | ✅ | Sprint 1 |
| `svc_shadow_api` MariaDB SELECT-only em `ohrm_user` + `hs_hr_employee` | ✅ | `Evidencias_Prompt_Orange.md` |
| `secret/orangehrm/db_api` provisionado no Vault | ✅ | `Evidencias_Prompt_Vault.txt` |
| VM `iga-gf-02` Ubuntu 24.04, Tailscale `xxx.xxx.xxx.xxx` | ✅ | `deepseek.txt` |
| midPoint 4.10 + PostgreSQL 16, Docker Compose `/srv/iga-project` | ✅ | Evidência IGA |

### 2.2 Shadow API (api-gf-01:8000)

| Componente | Status | Detalhe |
|-----------|--------|---------|
| FastAPI + Uvicorn | ✅ | Python 3.12, venv |
| `GET /` → HTTP 200 | ✅ | `{"status":"Shadow API is operational","target":"OrangeHRM"}` |
| `GET /employees` → HTTP 200 | ✅ | Array JSON com `emp_number`, `employee_id`, `first_name`, `last_name` |
| Autenticação `X-API-KEY` | ✅ | `Fiqueok-Security-Token-2026` |
| Vault integration (`secret/orangehrm/db_api`) | ✅ | hvac, sem credentials em código |
| UTF-8 NFC normalização (Pydantic) | ✅ | Sprint 5 |
| Empty string → None (`response_model_exclude_none=True`) | ✅ | Sprint 5 |
| Logging middleware ISO 27001 A.8.15 | ✅ | Sprint 5 |
| Swagger UI em `/docs` | ✅ | Evidência screenshot |
| Scripts de teste removidos | ✅ | Sprint 5 |

### 2.3 midPoint (iga-gf-02:8080)

| Item | Status | Detalhe |
|------|--------|---------|
| midPoint 4.10 operacional | ✅ | `docker logs` confirmado |
| PostgreSQL 16, 171 objetos importados | ✅ | `Database schema is compliant` |
| `missingSchemaAction: stop` | ✅ | TEP anterior |
| `restart: unless-stopped` | ✅ | docker-compose.yml atualizado |
| Resource "Fiqueok Shadow API (OrangeHRM)" importado | ✅ | OID `97afbdbb-e5df-4b98-ba69-d872e2e1ffda` |
| ScriptedREST 1.1.1.e2 JAR injetado | ✅ (parcial) | Conector reconhecido, incompatível |

---

## 3. ONDE O PROJETO PAROU — ROOT CAUSE ANALYSIS

### 3.1 O Bloqueio

A Sprint 6 objetivava configurar o Resource REST no midPoint para consumir `GET http://xxx.xxx.xxx.xxx:8000/employees` com header `X-API-KEY`. O bloqueio ocorreu na camada do conector ICF.

### 3.2 Linha do Tempo do Bloqueio

**Tentativa 1 — Polygon REST Connector (connector-rest 2.x):**
URLs testadas: Nexus Evolveum `<REDACTED_SECRET>-rest/2.6/` e `/2.7/`, Maven Central `/com/evolveum/polygon/connector-rest/2.6/`. Todas retornaram **HTTP 404**. Causa confirmada: `connector-rest` é uma **biblioteca superclass para desenvolvedores** (dependência Maven), não um conector ICF standalone deployável. Nunca existiu como JAR pronto para download.

**Tentativa 2 — ScriptedREST Connector 1.1.1.e2 (ForgeRock/Evolveum):**
JAR obtido com sucesso: `https://nexus.evolveum.<REDACTED_SECRET>erock/openicf/connectors/scriptedrest-connector/1.1.1.e2/scriptedrest-connector-1.1.1.e2.jar` (1.3MB). Conector reconhecido pelo midPoint, OID `c89f121b-f6a3-483e-9300-91b91bbe06f5`. Test Connection: **FALHA** com `groovy/util/slurpersupport/GPathResult`. Causa: conector desenvolvido para midPoint 3.x / Groovy 2.x / Java 11. O midPoint 4.10 roda Java 21 com runtime Groovy diferente onde `GPathResult` foi movido. A falha ocorre na inicialização do bundle, antes de qualquer script ser executado.

**Tentativa 3 — Script Groovy mínimo (validação do classpath):**
Script sem nenhum import de Groovy, apenas classes ConnId. Mesmo erro `GPathResult`. Confirmação definitiva: o problema é no classpath de inicialização do JAR do conector, não no script.

### 3.3 Diagnóstico Técnico Final

| Conclusão | Fonte |
|-----------|-------|
| `connector-rest` Polygon não existe como JAR standalone | Pesquisa Maven Central + Nexus Evolveum |
| ScriptedREST 1.1.1.e2 é incompatível com Java 21 | Error log midPoint + teste de script mínimo |
| Não existe Feature Flag para REST nativo no midPoint 4.10 | Confirmado pela Perplexity (pesquisa docs Evolveum) |
| Connector-rest 3.x existe no Maven mas requer build customizado | mvnrepository.com last release Mar 2024 |
| ScriptedSQL com Groovy HTTP teria o mesmo problema de GPathResult | Mesmo runtime Groovy compartilhado |

---

## 4. O QUE ESTÁ PRONTO PARA RETOMADA

Quando o bloqueio for resolvido, a retomada requer apenas:

1. **Obter JAR compatível** — um dos caminhos abaixo (ver Seção 6)
2. **Injetar em** `/srv/iga-project/data/midpoint/connid-connectors/`
3. **Reiniciar midPoint** — `docker compose restart midpoint`
4. **Verificar conector descoberto** — `SELECT displaynameorig FROM m_connector`
5. **Test Connection** no Resource OID `97afbdbb-e5df-4b98-ba69-d872e2e1ffda`
6. **Validar JML** — Joiner, Mover, Leaver

O Resource XML, o script SearchScript.groovy e toda a infraestrutura estão em estado válido e aguardando.

---

## 5. ESTADO ATUAL DO AMBIENTE (14/04/2026)

```
TAILSCALE MESH VPN
├── DESKTOP-O87TPQI    xxx.xxx.xxx.xxx   — Host Windows (admin)
├── vault-gf-01        xxx.xxx.xxx.xxx   — Vault HA active, unsealed
├── rh-gf-01-local     xxx.xxx.xxx.xxx   — OrangeHRM + MariaDB
├── api-gf-01          xxx.xxx.xxx.xxx — Shadow API :8000 ✅ ATIVO
└── iga-gf-02          xxx.xxx.xxx.xxx  — midPoint 4.10 :8080 ✅ ATIVO
```

**Arquivos relevantes na iga-gf-02:**
- `/srv/iga-project/docker-compose.yml` — stack midPoint + PostgreSQL
- `/srv/iga-<REDACTED_SECRET>pt.groovy` — script de busca
- `/srv/iga-project/data/midpoint/connid-connectors/` — diretório para o JAR
- `/tmp/shadow-api-resource-v2.xml` — Resource XML (pode precisar ser recriado)

---

## 6. CAMINHOS PARA DESBLOQUEIO

### Caminho A — Build Maven (Recomendado)
Compilar o `connector-rest` do Polygon com suporte a Java 21:

```bash
# Requer Java 17+ e Maven na máquina de build
git clone https://github.com/Evolveum/polygon
cd polygon
mvn clean install -pl connector-rest -am -Dmaven.test.skip=true
# JAR gerado em: polygon/connector-rest/target/connector-rest-*.jar
```

Copiar o JAR gerado para `/srv/iga-project/data/midpoint/connid-connectors/`.

### Caminho B — Aguardar Release Oficial
Monitorar: `https://nexus.evolveum.<REDACTED_SECRET>um/polygon/connector-rest/`
Para uma versão >= 3.x com suporte declarado a Java 21.

### Caminho C — Conector HTTP Genérico de Terceiros
Repositórios como `inalogy/midpoint-connector-*` publicam conectores compatíveis com midPoint 4.x. Monitorar GitHub para um conector HTTP/REST genérico com suporte a header customizado.

---

## 7. COMO REPORTAR O PROBLEMA À COMUNIDADE EVOLVEUM

### 7.1 Fórum Oficial

URL: `https://community.evolveum.com/`

**Template de Post sugerido:**

**Título:** `ScriptedREST connector 1.1.1.e2 fails with GPathResult on midPoint 4.10 / Java 21`

**Corpo:**
```
Environment:
- midPoint 4.10 (Docker image evolveum/midpoint:4.10, Java 21.0.8)
- Ubuntu 24.04
- connector: scriptedrest-connector-1.1.1.e2.jar

Problem:
After placing the JAR in /opt/midpoint/var/connid-connectors/ and restarting,
the connector is discovered (appears in m_connector table). However, Test Connection
fails with:

"Connector initialization failed. Unexpected runtime error:
groovy/util/slurpersupport/GPathResult"

This error occurs even with a minimal test script containing only ConnId framework
imports (no Groovy JSON/HTTP code). The error appears to be a classpath issue
during connector bundle initialization, not related to script content.

Question:
1. Is there a standalone deployable JAR for the Polygon REST connector
   (com.evolveum.polygon.connector-rest) compatible with midPoint 4.10 / Java 21?
2. Is there a known workaround for the GPathResult classpath issue in 4.10?
3. What is the recommended approach for consuming a JSON REST API (with custom
   X-API-KEY header) from midPoint 4.10 without building a custom connector?

Use case: midPoint 4.10 consuming a FastAPI endpoint returning employee JSON
for JML identity lifecycle automation (no SCIM, plain JSON array).
```

### 7.2 GitHub Issue

URL: `https://github.com/Evolveum/polygon/issues`

Abrir issue com título: `connector-rest: no standalone deployable JAR for Java 21 / midPoint 4.10`

---

## 8. LIÇÕES APRENDIDAS (PRJ008)

| # | Lição | Categoria |
|---|-------|-----------|
| L01 | O `connector-rest` Polygon é uma biblioteca de desenvolvimento, não um conector pronto — esta distinção não está clara na documentação | Arquitetura |
| L02 | O ScriptedREST 1.1.1.e2 (última versão disponível) é incompatível com Java 21 por design | Compatibilidade |
| L03 | A Evolveum descontinuou o ScriptedREST e recomenda build Java customizado — sem alternativa "zero-code" documentada para REST | Estratégia |
| L04 | Peer Review multicamada (Claude + Gemini + Perplexity + Copilot) foi essencial para chegar ao diagnóstico correto | Governança |
| L05 | A Shadow API em si é um ativo valioso e reutilizável independente do bloqueio do conector | Entrega |
| L06 | Path errado no Vault (`orangehrm/mysql` vs `orangehrm/db_api`) custou ~2h na Sprint 1 — confirmar paths antes de codificar | Operacional |
| L07 | pip install caiu por instabilidade de vSwitch externo — snapshot obrigatório antes de operações de rede | Operacional |

---

## 9. APROVAÇÃO DO FREEZE

| Papel | Nome | Data | Decisão |
|-------|------|------|---------|
| Responsável / GRC Lead | Paulo Feitosa Lima | 14/04/2026 | ✅ FREEZE APROVADO |

---

## 10. CONTROLE DE VERSÃO

| Versão | Data | Mudança |
|--------|------|---------|
| 1.0 | 14/04/2026 | Documento inicial de freezing |

---

*Documento gerado com apoio de Claude (Anthropic)*
*Living Lab Fiqueok — PRJ008*
*Retomada: mediante disponibilidade de conector REST compatível com Java 21*

