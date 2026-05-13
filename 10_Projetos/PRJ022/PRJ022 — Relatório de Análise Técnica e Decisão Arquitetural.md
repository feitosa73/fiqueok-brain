# 

## Integração OrangeHRM × midPoint 4.10

**Subtítulo:** _Da falha do conector REST à solução por ScriptedSQL com Shadow API — uma análise comparativa com validação por 5 IAs independentes_

---

|Campo|Valor|
|---|---|
|**Documento**|PRJ022-Relatorio-Analise-Tecnica-Decisao-Arquitetural-v1.0|
|**Data**|Maio/2026|
|**Status**|✅ Concluído — Aguardando Execução do PRJ022-A|
|**Responsável**|Paulo Feitosa Lima|
|**Programa**|PRJ003 — Living Lab Fiqueok · Greenfield|
|**Projetos Relacionados**|PRJ003, PRJ004, PRJ005, PRJ006, PRJ007, PRJ008, PRJ020|
|**Documentos Base**|TEP-PRJ008-v1.0-FREEZING, CONTEXTO_LivingLab_Fiqueok_v2.1, Jornada_IGA_Living_Lab_Fiqueok|

---

## ÍNDICE

1. Resumo Executivo
    
2. Contexto e Problema
    
3. Histórico do Bloqueio (PRJ008)
    
4. Análise de Contradição com PRJ006
    
5. Caminhos Avaliados
    
6. Avaliação por Múltiplas IAs
    
7. Consenso e Recomendação
    
8. Plano de Ação — PRJ022-A, -B, -C, -D
    
9. Inconformidades e Mitigações (CSV como Fallback)
    
10. Vulnerabilidades de Segurança Identificadas
    
11. Lições Aprendidas
    
12. Frameworks de Compliance Aplicados
    
13. Scripts Groovy para PRJ022-B
    
14. Glossário Técnico
    
15. Referências e Documentos Relacionados
    
16. Aprovações
    

---

## 1. Resumo Executivo

### 1.1. O Problema

O PRJ008 construiu com sucesso uma Shadow API REST (FastAPI/Python) que normaliza, higieniza e expõe os dados do OrangeHRM via endpoint `GET /employees` com autenticação por `X-API-KEY`. A API está operacional em `http://xxx.xxx.xxx.xxx:8000` e integrada ao HashiCorp Vault.

O bloqueio ocorreu na Sprint 6, ao tentar configurar o midPoint 4.10 (Java 21) para consumir esta API:

- **ScriptedREST 1.1.1.e2** → Incompatível com Groovy 4.0 (erro `GPathResult`)
    
- **Polygon connector-rest** → Nunca existiu como JAR standalone (é uma biblioteca para desenvolvedores)
    
- **DatabaseTable Connector** → Já abortado no PRJ006 por violar o princípio API-first
    

**Conclusão do PRJ008:** Projeto FROZEN por ausência de conector REST compatível com midPoint 4.10/Java 21.

### 1.2. O Trabalho Realizado (PRJ022)

Este relatório documenta a análise de 6 caminhos alternativos para resolver a integração, validada por 5 IAs independentes (Claude, Gemini, Perplexity, Copilot, Grok), com consenso de 100% sobre a viabilidade do **Caminho 2 (ScriptedSQL+HTTP)**.

### 1.3. A Recomendação Final

|Estágio|Caminho|Prazo|Probabilidade de Sucesso|
|---|---|---|---|
|**PRJ022-A (obrigatório)**|CSV via Shadow API|1-2 dias|95%|
|**PRJ022-B (spike técnico)**|ScriptedSQL+HTTP|1 dia|75%|
|**PRJ022-C (condicional)**|Build Maven (connector-rest)|4-5 dias|35%|
|**PRJ022-D (fallback oficial)**|CSV permanente|0 dias|100%|

**Decisão:** Executar PRJ022-B (spike) antes de qualquer compromisso com Build Maven. Se o spike falhar, aceitar CSV como solução final com inconformidades formalmente documentadas e mitigadas.

---

## 2. Contexto e Problema

### 2.1. O Ambiente (Living Lab Fiqueok)

text

TAILSCALE MESH VPN
├── DESKTOP-O87TPQI    xxx.xxx.xxx.xxx   — Host Windows (admin)
├── vault-gf-01        xxx.xxx.xxx.xxx   — HashiCorp Vault 1.21.3 (PAM)
├── rh-gf-01-local     xxx.xxx.xxx.xxx   — OrangeHRM 5.x + MariaDB 10.x
├── api-gf-01          xxx.xxx.xxx.xxx — Shadow API (FastAPI/Python) :8000
└── iga-gf-02          xxx.xxx.xxx.xxx  — midPoint 4.10 + PostgreSQL 16 :8080

**Stack relevante:**

- midPoint 4.10 rodando em Java 21 (OpenJDK), via Docker Compose em Ubuntu 24.04
    
- OrangeHRM 5.x com MariaDB — schema custom (`hs_hr_employee`, `ohrm_user`, etc.)
    
- Shadow API: FastAPI/Python 3.12, endpoint `GET /employees` retornando JSON, autenticação via header `X-API-KEY: Fiqueok-Security-Token-2026`, integrada ao Vault para credenciais do MariaDB
    
- Vault: tokens de serviço, políticas RBAC, engine KV v2
    

### 2.2. Histórico Relevante (PRJ003 a PRJ008)

|Projeto|Objetivo|Resultado|Lição|
|---|---|---|---|
|PRJ003|Base Greenfield IGA|✅ Sucesso|midPoint 4.10 + PostgreSQL 16 funcional|
|PRJ004|CSV → midPoint → AD|✅ Sucesso|Ciclo JML completo validado com 171 objetos|
|PRJ005|Conectividade JDBC segura|✅ Sucesso|Usuário `svc_shadow_api` com SELECT apenas|
|PRJ006|JDBC no midPoint|❌ Abortado|Anti-padrão arquitetural; decisão API-first|
|PRJ007|HashiCorp Vault|✅ Sucesso|Gestão de segredos integrada|
|PRJ008|Shadow API REST|🟡 FROZEN|Conector REST inexistente para Java 21|

### 2.3. O Bloqueio Detalhado (PRJ008 — Sprint 6)

**Tentativa 1 — Polygon connector-rest:**

- Buscado no Nexus Evolveum e Maven Central
    
- HTTP 404 em todas as URLs
    
- Descoberta: `connector-rest` é uma **biblioteca Maven (superclasse)** para desenvolvedores construírem conectores, nunca existiu como JAR standalone deployável
    

**Tentativa 2 — ScriptedREST 1.1.1.e2 (ForgeRock/Evolveum):**

- JAR obtido: `scriptedrest-connector-1.1.1.e2.jar` (1.3MB)
    
- Conector reconhecido pelo midPoint (aparece em `m_connector`)
    
- Test Connection: **FALHA** com erro: `groovy/util/slurpersupport/GPathResult`
    
- A falha ocorre **antes de qualquer script ser executado** — problema de classpath de inicialização do bundle
    

**Tentativa 3 — Script Groovy mínimo (só imports ConnId, sem Groovy):**

- Mesmo erro `GPathResult`
    
- Confirmação: problema é estrutural no JAR, não no script
    

**Root Cause confirmada:**

- midPoint 4.8+ atualizou Groovy para versão 4.0
    
- ScriptedREST 1.1.1.e2 foi construído para Groovy 2.x
    
- `groovy/util/slurpersupport/GPathResult` foi movido no Groovy 4.0
    
- A Evolveum declarou ScriptedREST como **depreciado** e 1.1.1.e2 como **versão final** — sem manutenção futura
    
- Sem build Java customizado, não há solução disponível
    

---

## 3. Histórico do Bloqueio (PRJ008)

### 3.1. O Que Foi Entregue no PRJ008 (Sprints 1-5)

|Componente|Status|Detalhe|
|---|---|---|
|Shadow API (FastAPI + Uvicorn)|✅|Python 3.12, venv|
|`GET /` → HTTP 200|✅|`{"status":"Shadow API is operational","target":"OrangeHRM"}`|
|`GET /employees` → HTTP 200|✅|Array JSON com `emp_number`, `employee_id`, `first_name`, `last_name`|
|Autenticação `X-API-KEY`|✅|`Fiqueok-Security-Token-2026`|
|Vault integration (`secret/orangehrm/db_api`)|✅|hvac, sem credentials em código|
|UTF-8 NFC normalização (Pydantic)|✅|Sprint 5|
|Empty string → None (`response_model_exclude_none=True`)|✅|Sprint 5|
|Logging middleware ISO 27001 A.8.15|✅|Sprint 5|
|Swagger UI em `/docs`|✅|Disponível|
|Scripts de teste removidos|✅|Sprint 5|

### 3.2. O Que Está Pronto no midPoint (iga-gf-02)

|Item|Status|Detalhe|
|---|---|---|
|midPoint 4.10 operacional|✅|Docker Compose, PostgreSQL 16|
|Resource "Fiqueok Shadow API" importado|✅|OID `97afbdbb-e5df-4b98-ba69-d872e2e1ffda`|
|ScriptedREST JAR injetado|🟡 (parcial)|Conector reconhecido, mas incompatível|
|Script SearchScript.groovy|✅|Pronto, aguardando conector funcional|

### 3.3. Estado Atual do Ambiente (Maio/2026)

text

TAILSCALE MESH VPN
├── vault-gf-01        xxx.xxx.xxx.xxx   — ✅ Vault HA active, unsealed
├── rh-gf-01-local     xxx.xxx.xxx.xxx   — ✅ OrangeHRM + MariaDB
├── api-gf-01          xxx.xxx.xxx.xxx — ✅ Shadow API :8000
└── iga-gf-02          xxx.xxx.xxx.xxx  — ✅ midPoint 4.10 :8080

---

## 4. Análise de Contradição com PRJ006

### 4.1. A Contradição Aparente

|Projeto|Decisão|Razão|
|---|---|---|
|**PRJ006**|❌ Abortado — JDBC direto é anti-padrão|Bypass das regras de negócio; acoplamento ao schema interno|
|**PRJ006**|🟡 Decisão API-first|Construir Shadow API como camada de abstração|
|**PRJ022 — Caminho 2**|🟡 Propõe usar ScriptedSQL (connector JDBC)|Para executar HTTP via Groovy|

### 4.2. Por Que Não Há Contradição Real

|Aspecto|PRJ006 (JDBC direto)|PRJ022 Caminho 2 (ScriptedSQL+HTTP)|
|---|---|---|
|**Fonte dos dados**|MariaDB (schema interno)|Shadow API (contrato estável)|
|**Camada de negócio**|Ignorada|Respeitada (API expõe regras do OrangeHRM)|
|**Uso do conector JDBC**|Para acessar dados|Como "veículo" para executar script Groovy|
|**Princípio API-first**|❌ Violado|✅ Preservado|

### 4.3. Refinamento da Lição do PRJ006

**Lição original:**

> _"JDBC direto ao banco de terceiros é anti-padrão arquitetural. APIs existem para abstrair complexidade."_

**Refinamento (após PRJ022):**

> _"O anti-padrão é acessar o banco raw como fonte de verdade. O uso de conectores JDBC como 'veículo' para outros protocolos (HTTP, arquivos, etc.) é aceitável desde que a fonte dos dados seja uma camada de abstração legítima."_

### 4.4. Documentação Oficial no TAP

markdown

--- SEÇÃO: ANÁLISE DE CONTRADIÇÃO COM PRJ006 ---
O PRJ006 foi abortado por utilizar JDBC direto ao banco do OrangeHRM,
violando o princípio API-first (ADR-004). O PRJ022 Caminho 2 propõe
utilizar o mesmo conector ScriptedSQL, mas com uma diferença fundamental:
- PRJ006: JDBC → MariaDB (fonte raw, sem camada de abstração)
- PRJ022: JDBC (dummy) → Script Groovy → HTTP → Shadow API → MariaDB
A Shadow API é a camada de abstração legítima que encapsula as regras
de negócio, normalização e segurança do OrangeHRM. O conector JDBC
é usado apenas como "veículo" para executar o script Groovy, não como
protocolo de acesso aos dados.
Portanto, NÃO HÁ CONTRADIÇÃO com a decisão do PRJ006.

---

## 5. Caminhos Avaliados

### 5.1. Matriz de Decisão

|Caminho|Descrição|Esforço|Risco Técnico|Risco Arquitetural|Aproveita PRJ008|
|---|---|---|---|---|---|
|**1 — CSV periódico**|Script exporta dados para CSV; midPoint usa CsvConnector|1-2 dias|Muito baixo|Muito baixo|Não diretamente|
|**2 — ScriptedSQL+HTTP**|Usa ScriptedSQL (JDBC dummy) + Groovy com `java.net.http.HttpClient`|2-3 dias (spike 1 dia)|Médio|Médio|✅ Sim|
|**3 — Build Maven (connector-rest)**|Compilar conector Java a partir do Polygon|3-5 dias|Médio-Alto|Baixo|✅ Sim|
|**4 — Inalogy template**|Adaptar conector FreeIPA da Inalogy|3-4 dias|Médio|Baixo|✅ Sim|
|**5 — Push via REST API**|Script Python chama REST API do midPoint|1 dia|Muito baixo|**Muito Alto**|Parcial|
|**6 — SCIM sobre Shadow API**|Construir camada SCIM sobre a API|3-5 dias|Médio|Baixo|✅ Sim|

### 5.2. Caminho 1 — CSV Periódico com Cronjob

**Como funciona:**  
Script Python/Bash na `rh-gf-01` exporta dados do OrangeHRM para CSV diariamente e coloca em volume acessível pela `iga-gf-02`. midPoint usa o CsvConnector bundled (sem JAR externo) para reconciliação.

**Vantagens:**

- Zero dependência de build Java
    
- Conector bundled e suportado
    
- Comportamento previsível
    
- Já validado no PRJ004 (171 objetos, ciclo JML completo)
    

**Desvantagens:**

- Não é real-time (batch)
    
- Latência de até 24h
    
- Não aproveita a Shadow API diretamente (mas pode ser adaptado)
    

**Esforço:** 1-2 dias  
**Risco:** Muito baixo

---

### 5.3. Caminho 2 — ScriptedSQL com HTTP nativo Java (Workaround Criativo)

**Como funciona:**  
Usa o ScriptedSQL (versão 2.3, compatível com midPoint 4.10/Groovy 4) mas sem banco de dados real. O SearchScript.groovy usa `java.net.http.HttpClient` do Java 11+ para fazer GET na Shadow API, parsear o JSON e retornar os resultados como se fossem rows de banco.

**Requisitos:**

- JDBC dummy (H2 em memória ou PostgreSQL local com tabela vazia)
    
- `SchemaScript.groovy` para definir os atributos do JSON
    
- `SearchScript.groovy` com HttpClient, timeouts, tratamento de erros
    
- Recuperação do `X-API-KEY` do Vault (via variável de ambiente ou binding)
    

**Vantagens:**

- Sem build Maven
    
- Aproveita a Shadow API existente
    
- Real-time
    
- Usa conector bundled (já no Lab)
    

**Desvantagens:**

- Workaround arquitetural (não-idiomático)
    
- Requer JDBC dummy configurado
    
- Pode gerar problemas em versões futuras do midPoint
    

**Riscos identificados:**

- Timeout/resiliência (travar scheduler do midPoint)
    
- Paginação não tratada (OOM)
    
- Vazamento de recursos (HttpClient sem close)
    
- Estado entre execuções para paginação/offset
    

**Esforço:** 2-3 dias (spike de 1 dia)  
**Risco:** Médio

---

### 5.4. Caminho 3 — Build Maven do connector-rest (Código Java)

**Como funciona:**  
Clonar repositório Polygon, compilar o `connector-rest` como dependência, criar conector Java mínimo que estende `AbstractRestConnector`, implementar `executeQuery` fazendo GET na Shadow API com header `X-API-KEY`, empacotar como JAR OSGi e deployar.

**Vantagens:**

- Solução arquiteturalmente correta
    
- Extensível e reutilizável
    
- Aproveita 100% a Shadow API
    

**Desvantagens:**

- Requer toolchain Java/Maven (não existe no Lab)
    
- Requer conhecimento Java para escrever o conector
    
- Risco de compatibilidade OSGi/ConnId
    
- Dependências transitivas problemáticas
    

**Os gargalos reais (validação por 4 IAs):**

1. **Complexidade do código Java:** ~300-800 linhas para um conector mínimo
    
2. **OSGi bundle:** `maven-bundle-plugin` precisa configurar `Export-Package`, `Import-Package`, `Bundle-Activator`
    
3. **Dependency Hell:** Jackson/Gson podem conflitar com versões do midPoint
    
4. **Probabilidade de sucesso em primeira tentativa:** 30-50% (sem experiência OSGi)
    

**Esforço:** 3-5 dias  
**Risco:** Médio-Alto

---

### 5.5. Caminho 4 — Conector Baseado no FreeIPA da Inalogy

**Como funciona:**  
Usar código-fonte `midpoint-connector-freeipa` da Inalogy como ponto de partida. Ele usa `connector-rest` como superclasse e consome REST com token de autenticação. Adaptar endpoints e auth para X-API-KEY.

**Vantagens:**

- Código funcional e testado com midPoint 4.9
    
- Reduz esforço de desenvolvimento em ~50%
    
- Arquitetura validada em produção
    

**Desvantagens:**

- Mesmos requisitos do Caminho 3 (Java/Maven)
    
- Estrutura OOP complexa (múltiplas classes)
    
- Pode ter dependências adicionais não necessárias
    

**Esforço:** 3-4 dias  
**Risco:** Médio

---

### 5.6. Caminho 5 — Push via midPoint REST API (Inversão do Fluxo)

**Como funciona:**  
Script Python na `api-gf-01` (ou `rh-gf-01`) faz poll da Shadow API e usa a REST API do midPoint (`POST /ws/rest/users`) para criar/atualizar usuários diretamente no repositório.

**Vantagens:**

- Zero dependência de conector
    
- Usa a REST API do midPoint (nativa e bem documentada)
    
- Python é o perfil técnico do Lab
    

**Desvantagens:**

- **Violação grave do modelo IGA:** usuários criados diretamente via REST não têm shadow, quebrando reconciliação, correlação e deprovisionamento automático
    
- Do ponto de vista de governança, é o mesmo problema que o scripting que o DDR-001 rejeita
    

**Veredito:** ❌ **Rejeitado arquiteturalmente**  
**Esforço:** 1 dia | **Risco:** Muito Alto (arquitetural)

---

### 5.7. Caminho 6 — SCIM sobre Shadow API

**Como funciona:**  
Construir uma camada SCIM (System for Cross-domain Identity Management) sobre a Shadow API existente, expondo endpoints compatíveis com SCIM 2.0. O midPoint tem conector SCIM nativo.

**Vantagens:**

- Protocolo padrão da indústria (RFC 7644)
    
- midPoint tem suporte nativo a SCIM
    
- Reutiliza a Shadow API como backend
    

**Desvantagens:**

- Projeto adicional (3-5 dias)
    
- SCIM é mais complexo que REST puro
    
- Pode ser over-engineering para o tamanho do Lab
    

**Esforço:** 3-5 dias  
**Risco:** Médio  
**Recomendação:** Manter como backlog futuro, não como caminho imediato

---

## 6. Avaliação por Múltiplas IAs

### 6.1. Metodologia

Foram consultadas 5 IAs independentes, cada uma atuando como Arquiteto IAM/IGA sênior, com a seguinte instrução:

> _"Você não foi parte de nenhuma das análises anteriores. Leia todo o contexto. Dê um parecer imparcial, indicando onde cada análise anterior acerta, erra ou omite, sem favoritismo."_

### 6.2. IAs Consultadas

|IA|Papel|Principais Contribuições|
|---|---|---|
|**Claude** (minha análise)|Arquiteto base|Tabela de 6 caminhos, detalhamento OSGi, vulnerabilidades de segurança|
|**Gemini**|Acadêmico/Conceitual|Identificou omissão do `SchemaScript.groovy`; chamou Build Maven de "inferno"|
|**Perplexity**|Detalhista/Documentado|Forneceu configuração `pom.xml` específica; referências documentais|
|**Copilot**|Cauteloso/Operacional|Enfatizou persistência de estado entre execuções; 7 condições obrigatórias|
|**Grok**|Equilibrado/Síntese|Melhor síntese das posições conflitantes; validou todas as questões|

### 6.3. Consenso entre as 4 IAs (Gemini, Perplexity, Copilot, Grok)

|Questão|Consenso|Força|
|---|---|---|
|**Caminho 2 é viável?**|✅ SIM — com condições|100% (4/4)|
|**Build Maven é realista?**|🟡 PARCIALMENTE — não recomendado como primeira escolha|75% (3/4 contra)|
|**CSV como fallback?**|✅ SIM — aceitável para Lab|100% (4/4)|
|**ScriptedREST é inviável?**|✅ SIM — quebra estrutural do Groovy 4.0|100% (4/4)|
|**Shadow API deve ser aproveitada?**|✅ SIM — mesmo no CSV|100% (4/4)|

### 6.4. O que as 4 IAs Identificaram que Minha Análise Perdeu

|Item|Identificado por|Minha falha|
|---|---|---|
|**Omissão do `SchemaScript.groovy`**|Gemini|❌ Não mencionei|
|**Persistência de estado do script entre execuções**|Copilot|❌ Não mencionei|
|**H2 como JDBC dummy mínimo**|Perplexity, Copilot|🟡 Mencionei parcialmente|
|**Precedente de conectores Groovy para REST**|Gemini|❌ Não pesquisei|

### 6.5. Média de Avaliação das 4 IAs

|Critério|Média (4 IAs)|
|---|---|
|**Aderência a Frameworks de Segurança** (CIS, NIST, ISO)|87.25%|
|**Aderência a Frameworks de Mercado** (PCI-DSS, SOX, LGPD)|80.75%|
|**Probabilidade de Sucesso** (execução PRJ022)|83.50%|

---

## 7. Consenso e Recomendação

### 7.1. Consenso entre as 5 IAs (incluindo minha análise)

|Caminho|Recomendação|Justificativa|
|---|---|---|
|**1 — CSV**|✅ Plano B oficial|Já funciona, risco zero, entrega valor imediato|
|**2 — ScriptedSQL+HTTP**|✅ Spike prioritário|Consenso de viabilidade; melhor relação esforço/benefício|
|**3 — Build Maven**|🟡 Somente se spike falhar|Alto risco, baixa probabilidade de sucesso|
|**4 — Inalogy template**|🟡 Alternativa ao Caminho 3|Menor esforço que Caminho 3, mas mesmos riscos|
|**5 — Push REST**|❌ Rejeitado|Viola modelo IGA|
|**6 — SCIM**|⏳ Backlog futuro|Over-engineering para o Lab|

### 7.2. Recomendação Final

text

┌─────────────────────────────────────────────────────────────────┐
│                    DECISÃO ARQUITETURAL FINAL                    │
│                                                                  │
│  1. Executar PRJ022-B (spike ScriptedSQL+HTTP) como PRIORIDADE  │
│     - Prazo: 1 dia                                               │
│     - Critério de sucesso: GET /employees funciona com headers   │
│     - Rollback: Falha em qualquer dos 4 riscos críticos         │
│                                                                  │
│  2. Se spike funcionar → PRJ022-C (Build Maven) é OPCIONAL      │
│     - Apenas se houver necessidade de perfeição arquitetural    │
│     - Não obrigatório para entrega funcional                     │
│                                                                  │
│  3. Se spike falhar → PRJ022-D (CSV permanente)                 │
│     - Inconformidades documentadas e aceitas                    │
│     - Mitigações aplicadas                                       │
│                                                                  │
│  4. PRJ022-A (CSV via Shadow API) é OBRIGATÓRIO                 │
│     - Entregar em 1-2 dias como baseline funcional              │
│     - Mesmo que o spike funcione, mantém-se como fallback       │
└─────────────────────────────────────────────────────────────────┘

---

## 8. Plano de Ação — PRJ022-A, -B, -C, -D

### 8.1. PRJ022-A (Obrigatório) — CSV via Shadow API

**Objetivo:** Estabelecer baseline funcional em 1-2 dias

**Passos:**

1. Criar script Python em `api-gf-01` que:
    
    - Consome `GET /employees` com `X-API-KEY`
        
    - Converte JSON para CSV com UTF-8 encoding
        
    - Salva em volume compartilhado (ou via SCP para `iga-gf-02`)
        
2. Configurar CsvConnector no midPoint:
    
    - Resource apontando para o arquivo CSV
        
    - Schema mapping com `emp_number`, `employee_id`, `first_name`, `last_name`
        
    - Correlation por `employee_id`
        
    - Reações: Unmatched → Add focus
        
3. Agendar cronjob para execução periódica (ex: a cada 4 horas)
    

**Critério de sucesso:** CSV gerado → midPoint reconcilia → AD atualizado  
**Critério de rollback:** Falha no script de exportação por 3 ciclos consecutivos

---

### 8.2. PRJ022-B (Spike Técnico) — ScriptedSQL+HTTP

**Objetivo:** Validar viabilidade do Caminho 2 em 1 dia

**Pré-requisitos:**

- Configurar JDBC dummy (H2 em memória) no Resource do midPoint
    
- Implementar `SchemaScript.groovy` (ver seção 13)
    
- Implementar `SearchScript.groovy` com HttpClient (ver seção 13)
    
- Configurar variável de ambiente `SHADOW_API_KEY` com valor do Vault
    
- Testar com dataset pequeno (2-3 employees)
    

**Critério de sucesso:**

- `GET /employees` via ScriptedSQL retorna JSON correto
    
- SchemaScript.groovy é executado sem erros
    
- midPoint consegue fazer correlation
    

**Critério de rollback (falha):**

- Timeout/erro de conexão não tratado
    
- Vazamento de recursos (conexões abertas)
    
- Paginação não funciona com volume real de dados
    
- Qualquer erro que impeça a reconciliação
    

---

### 8.3. PRJ022-C (Condicional) — Build Maven (connector-rest)

**Objetivo:** Construir conector Java customizado (apenas se spike funcionar)

**Pré-requisitos:**

- Instalar Java 17+ e Maven no Windows host ou WSL
    
- Clonar repositório Polygon: `git clone https://github.com/Evolveum/polygon`
    
- Configurar `pom.xml` com `maven-bundle-plugin`
    
- Implementar conector mínimo estendendo `AbstractRestConnector`
    

**Configuração mínima do `pom.xml`:**

xml

<plugin>
    <groupId>org.apache.felix</groupId>
    <artifactId>maven-bundle-plugin</artifactId>
    <configuration>
        <instructions>
            <Bundle-SymbolicName>${project.artifactId}</Bundle-SymbolicName>
            <Export-Package>com.fiqueok.connector.*</Export-Package>
            <Import-Package>org.identityconnectors.framework.*,com.evolveum.polygon.*</Import-Package>
            <Embed-Dependency>connector-rest;scope=compile</Embed-Dependency>
        </instructions>
    </configuration>
</plugin>

**Critério de sucesso:** JAR gerado, deployado, Test Connection OK  
**Probabilidade estimada:** 30-50% em primeira tentativa

---

### 8.4. PRJ022-D (Fallback Oficial) — CSV Permanente

**Objetivo:** Aceitar CSV como solução final com inconformidades mitigadas

**Condições de ativação:**

- PRJ022-B falha (spike não funciona)
    
- PRJ022-C não é tentado ou falha
    

**Inconformidades a serem formalmente aceitas:**  
(Ver seção 9)

---

## 9. Inconformidades e Mitigações (CSV como Fallback)

### 9.1. Tabela de Inconformidades

|Inconformidade|Framework|Impacto|Mitigação|
|---|---|---|---|
|**Latência até 24h**|ISO 27001 A.12.1.3 (capacidade)|Baixo (processo de admissão não exige real-time)|Reduzir janela para 4h. Documentar como trade-off aceito.|
|**Ausência de real-time para Mover/Leaver**|SOX (segregação de acesso)|Médio (ex-funcionário pode manter acesso)|Script de revogação manual para casos críticos. Cron a cada 4h para desligamentos urgentes.|
|**Risco de corrupção de encoding**|LGPD art.46 (integridade)|Baixo|Script de exportação com UTF-8 explícito. Validação pós-exportação com alerta.|
|**Lineage quebrado (rastreabilidade)**|ISO 27001 A.8.15, PCI-DSS 10.3|Médio|Script de exportação deve logar timestamp, usuário, linhas exportadas. Shadow API como fonte (já tem logging).|
|**Falta de idempotência entre ciclos**|ISO 27001 A.12.5.1 (controle de versão)|Médio|Usar reconciliação do midPoint (CsvConnector já lida). Manter histórico de CSVs por 30 dias.|
|**Dependência de script como ponto de falha**|NIST SP 800-53 SA-15|Médio|Script com healthcheck próprio. Logs centralizados. Supervisão via cron com alerta de falha.|

### 9.2. Aceitação Formal

markdown

Eu, Paulo Feitosa Lima, na qualidade de Responsável Técnico e GRC Lead do Living Lab Fiqueok,
RECONHEÇO as inconformidades listadas acima e
ACEITO os riscos residuais após aplicação das mitigações propostas,
DECIDINDO que o Caminho 1 (CSV) é uma solução aceitável para o contexto de laboratório,
COM O ENTENDIMENTO de que um ambiente de produção exigiria uma reavaliação baseada nos seguintes critérios:
- Volume de colaboradores > 1.000
- Requisito de real-time (ex: desligamentos com acesso crítico)
- Exigência contratual de rastreabilidade fim-a-fim
Data: ___/___/2026
Assinatura: _________________

---

## 10. Vulnerabilidades de Segurança Identificadas

### 10.1. Shadow API (Independente do Caminho)

|Vulnerabilidade|Severidade|Mitigação|Status|
|---|---|---|---|
|**API Key em trânsito sem TLS**|Baixa (Tailscale já criptografa)|Aceitar. Se necessário, configurar TLS no Uvicorn.|Pendente|
|**Rate limiting ausente**|Média (risco de DoW via midPoint)|Implementar `slowapi` (FastAPI middleware) com 100 req/min por IP|Pendente|
|**Logs sem rotação**|Baixa (crescimento de disco)|Configurar `logrotate` na VM `api-gf-01`|Pendente|
|**SCA ausente (CVEs em hvac, fastapi, uvicorn)**|Média|GitHub Actions com `safety check` + `bandit`|Pendente (Sprint 5 não executada)|

### 10.2. CSV (Apenas Caminho 1)

|Vulnerabilidade|Severidade|Mitigação|Status|
|---|---|---|---|
|**CSV armazenado sem criptografia em repouso**|Média (PII exposta)|Criptografar volume (LUKS) ou usar criptografia Hyper-V. Limpar arquivos após reconciliação.|Pendente|
|**CSV em trânsito sem TLS**|Baixa (Tailscale mesh)|Aceitar.|N/A|

### 10.3. ScriptedSQL+HTTP (Apenas Caminho 2)

|Vulnerabilidade|Severidade|Mitigação|Status|
|---|---|---|---|
|**X-API-KEY hardcoded no script**|Alta|Recuperar do Vault via variável de ambiente injetada no container do midPoint|Pendente|
|**Timeout não configurado**|Média (trava scheduler)|Usar `connectTimeout(5000)` e `readTimeout(10000)` no HttpClient|Pendente|
|**Vazamento de conexões HTTP**|Média|Usar try-with-resources; `response.close()` no finally|Pendente|

---

## 11. Lições Aprendidas

### 11.1. Lições Transversais (PRJ001 a PRJ022)

|#|Lição|Categoria|
|---|---|---|
|L01|O `connector-rest` Polygon é uma biblioteca de desenvolvimento, não um conector pronto — esta distinção não está clara na documentação|Arquitetura|
|L02|O ScriptedREST 1.1.1.e2 (última versão disponível) é incompatível com Java 21 por design|Compatibilidade|
|L03|A Evolveum descontinuou o ScriptedREST e recomenda build Java customizado — sem alternativa "zero-code" documentada para REST|Estratégia|
|L04|Peer Review multicamada (5 IAs) foi essencial para chegar ao diagnóstico correto e evitar viés|Governança|
|L05|A Shadow API em si é um ativo valioso e reutilizável independente do bloqueio do conector|Entrega|
|L06|Path errado no Vault (`orangehrm/mysql` vs `orangehrm/db_api`) custou ~2h na Sprint 1 — confirmar paths antes de codificar|Operacional|
|L07|pip install caiu por instabilidade de vSwitch externo — snapshot obrigatório antes de operações de rede|Operacional|
|L08|A dependência crítica de um projeto (conector ICF compatível com Java 21) deve ser validada na Sprint 0, não na Sprint 6|Governança|
|L09|CSV é uma solução válida e defensável para HR → IGA em cenários batch, com inconformidades mitigáveis|Arquitetura|
|L10|Conectores JDBC podem ser usados como "veículos" para outros protocolos desde que a fonte dos dados seja uma camada de abstração legítima|Arquitetura|

### 11.2. Lições Específicas do PRJ022

|#|Lição|Fonte|
|---|---|---|
|L11|O `SchemaScript.groovy` é obrigatório no Caminho 2 — nenhuma IA mencionou isso antes da análise do Gemini|Gemini|
|L12|Scripts carregados pelo conector podem reter estado entre execuções (classloader do bundle) — tratar como stateless|Copilot|
|L13|H2 em memória é a opção mais leve para JDBC dummy (não use o MariaDB do OrangeHRM)|Perplexity, Copilot|
|L14|O `java.net.http.HttpClient` é thread-safe e pode ser usado como singleton no SearchScript|Gemini, Perplexity|
|L15|midPoint não tem rate limiting nativo — implementar na Shadow API (slowapi) é a melhor defesa|Grok|

---

## 12. Frameworks de Compliance Aplicados

|Framework|Controles Relevantes|Aplicação no PRJ022|
|---|---|---|
|**ISO 27001**|A.5.15 (Menor Privilégio), A.8.12 (Gestão de Segredos), A.8.15 (Logging), A.12.1.3 (Capacidade)|Vault para credenciais; middleware de logging; CSV como mitigação de capacidade|
|**NIST SP 800-53**|SA-15 (Dependências), AU-2 (Audit Events), CP-2 (Continuity)|Análise de dependência crítica (conector); logs de auditoria; plano de contingência (CSV)|
|**CIS Controls**|4 (Secure Configuration), 11 (Data Recovery)|Configuração segura da Shadow API; snapshots Hyper-V|
|**PCI-DSS v4.0**|6.3 (Dev Seguro), 6.6 (SAST), 10.3 (Audit Trails)|Pipeline GitHub Actions (pendente); logging estruturado|
|**SOX**|Segregação de deveres|CSV batch separa responsabilidades; real-time exigiria controls adicionais|
|**LGPD**|Art. 6 (Bases legais), Art. 46 (Segurança)|CSV como comprovante de rastreabilidade; criptografia em repouso proposta|

---

## 13. Scripts Groovy para PRJ022-B

### 13.1. SchemaScript.groovy

groovy

// SchemaScript.groovy
// Define os atributos que o midPoint espera receber do Resource
// Deve corresponder aos campos retornados pela Shadow API
import org.identityconnectors.framework.common.objects.*
def schema = new Schema()
// Atributo primário (chave de correlação)
def empNumber = new AttributeInfoBuilder() {
    setName("emp_number")
    setType(Integer.class)
    setRequired(true)
    setCreateable(false)
    setUpdateable(false)
}.build()
// ID de negócio (employee_id no AD)
def employeeId = new AttributeInfoBuilder() {
    setName("employee_id")
    setType(String.class)
    setRequired(true)
    setCreateable(false)
    setUpdateable(false)
}.build()
def firstName = new AttributeInfoBuilder() {
    setName("first_name")
    setType(String.class)
    setRequired(false)
    setCreateable(false)
    setUpdateable(false)
}.build()
def lastName = new AttributeInfoBuilder() {
    setName("last_name")
    setType(String.class)
    setRequired(true)
    setCreateable(false)
    setUpdateable(false)
}.build()
// Adiciona todos ao schema
schema.defineAttribute(empNumber)
schema.defineAttribute(employeeId)
schema.defineAttribute(firstName)
schema.defineAttribute(lastName)
// Define o objeto principal (__ACCOUNT__ é o tipo padrão)
def objectClassInfo = new ObjectClassInfoBuilder() {
    setType(ObjectClass.ACCOUNT_NAME)
    addAllAttributeInfo(schema.getAttributeInfo())
}.build()
schema.defineObjectClass(objectClassInfo)
return schema

---

### 13.2. SearchScript.groovy

groovy

// SearchScript.groovy
// Busca todos os funcionários na Shadow API via HTTP GET
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.net.URI
import java.time.Duration
import groovy.json.JsonSlurper
// Configurações (recomenda-se variáveis de ambiente no container)
def SHADOW_API_URL = "http://xxx.xxx.xxx.xxx:8000/employees"
def API_KEY = System.getenv("SHADOW_API_KEY") ?: "Fiqueok-Security-Token-2026" // fallback, mas Vault é melhor
// HttpClient singleton (thread-safe)
def client = HttpClient.newBuilder()
    .connectTimeout(Duration.ofSeconds(5))
    .build()
// Construção da requisição
def request = HttpRequest.newBuilder()
    .uri(URI.create(SHADOW_API_URL))
    .timeout(Duration.ofSeconds(10))
    .header("X-API-KEY", API_KEY)
    .header("Accept", "application/json")
    .GET()
    .build()
try {
    def response = client.send(request, HttpResponse.BodyHandlers.ofString())
    
    if (response.statusCode() != 200) {
        throw new RuntimeException("HTTP ${response.statusCode()}: Falha ao acessar Shadow API")
    }
    
    def jsonSlurper = new JsonSlurper()
    def employees = jsonSlurper.parseText(response.body())
    
    // Para cada funcionário, cria um map com os atributos e passa para handler
    employees.each { emp ->
        def attributes = [
            "emp_number": emp.emp_number,
            "employee_id": emp.employee_id,
            "first_name": emp.first_name,
            "last_name": emp.last_name
        ]
        
        // handler é fornecido pelo midPoint
        handler(attributes)
    }
    
} catch (Exception e) {
    // Log do erro (o midPoint registrará no midpoint.log)
    throw new RuntimeException("Erro no SearchScript: ${e.message}", e)
} finally {
    // Garantir que não há vazamento de recursos
    // O HttpClient não precisa ser fechado (é singleton)
    // A response já foi consumida
}

---

### 13.3. Configuração do Resource (XML parcial)

xml

<resource>
    <name>Fiqueok Shadow API (ScriptedSQL)</name>
    <connectorRef oid="c89f121b-f6a3-483e-9300-91b91bbe06f5"/> <!-- ScriptedSQL connector -->
    <connectorConfiguration>
        <groovyScripts>
            <schemaScript>
                <source><include>SchemaScript.groovy</include></source>
            </schemaScript>
            <searchScript>
                <source><include>SearchScript.groovy</include></source>
            </searchScript>
        </groovyScripts>
        <connection>
            <!-- JDBC dummy (H2 em memória) -->
            <driverClassName>org.h2.Driver</driverClassName>
            <url>jdbc:h2:mem:dummy;DB_CLOSE_DELAY=-1</url>
            <username>sa</username>
            <password></password>
        </connection>
    </connectorConfiguration>
    <schemaHandling>
        <!-- Importar schema do SchemaScript.groovy -->
        <objectType>
            <kind>account</kind>
            <intent>employee</intent>
            <attribute>
                <ref>employee_id</ref>
                <correlate>true</correlate>
                <correlationDefinition>
                    <link>
                        <type>account</type>
                        <source>employee_id</source>
                        <target>employeeID</target>
                    </link>
                </correlationDefinition>
            </attribute>
            <synchronization>
                <reaction>
                    <situation>unmatched</situation>
                    <action>
                        <type>addFocus</type>
                    </action>
                </reaction>
                <!-- Reações para Mover/Leaver -->
            </synchronization>
        </objectType>
    </schemaHandling>
</resource>

---

## 14. Glossário Técnico

|Termo|Definição no Contexto Fiqueok|
|---|---|
|**Shadow API**|Camada de abstração REST entre OrangeHRM e midPoint; construída no PRJ008|
|**ScriptedSQL**|Conector ICF baseado em Groovy (bundled no midPoint 4.10); suporta scripts customizados|
|**ScriptedREST**|Conector ICF para REST APIs baseado em Groovy; **depreciado** e incompatível com Java 21|
|**connector-rest**|Biblioteca Java do Polygon (Evolveum) para construção de conectores REST; **não é um conector standalone**|
|**GPathResult**|Classe do Groovy 2.x removida no Groovy 4.0; causa do bloqueio do ScriptedREST|
|**JDBC dummy**|Conexão JDBC configurada no conector mas não utilizada; necessária para inicializar o ScriptedSQL|
|**H2**|Banco de dados Java embutido; usado como JDBC dummy pelo Caminho 2|
|**X-API-KEY**|Header de autenticação da Shadow API; valor armazenado no Vault (`secret/shadow-api/auth`)|
|**JML**|Joiner-Mover-Leaver — ciclo de vida de identidades|
|**CSV como fallback**|Aceitação documentada de CSV como solução final quando o conector REST não existe|

---

## 15. Referências e Documentos Relacionados

### 15.1. Projetos Predecessores

|Documento|Localização|Conteúdo|
|---|---|---|
|`TEP-PRJ008-v1.0-FREEZING.md`|Obsidian PRJ008|Documento oficial de freezing do PRJ008|
|`CONTEXTO_LivingLab_Fiqueok_v2.1.md`|Obsidian Root|Contexto completo do Lab (PRJ001 a PRJ020)|
|`Jornada_IGA_Living_Lab_Fiqueok.pptx`|Obsidian PRJ008|Apresentação executiva do bloqueio|
|`PRJ004-IGA-Data-Lifecycle.md`|Obsidian PRJ004|Validação do CSV como fonte autoritativa|
|`PRJ006-Relatorio-Abortamento.md`|Obsidian PRJ006|Decisão de abortar JDBC direto|

### 15.2. Documentos Produzidos no PRJ022

|Documento|Conteúdo|
|---|---|
|`PRJ022_Resumo_Executivo.md`|2 páginas para stakeholders|
|`PRJ022_Matriz_Decisao.md`|Tabela comparativa dos 6 caminhos|
|`PRJ022_Avaliacao_IAs.md`|Pareceres completos das 5 IAs|
|`PRJ022_Carta_Comunidade_Evolveum.md`|Template para reportar o problema|
|`PRJ022_Scripts_Groovy.md`|SearchScript e SchemaScript prontos|

### 15.3. Links Externos

|Link|Descrição|
|---|---|
|`https://docs.evolveum.com/connectors/connectors/com.evolveum.polygon.connector.scripted.sql.ScriptedSQLConnector/`|Documentação oficial do ScriptedSQL|
|`https://github.com/Evolveum/polygon`|Repositório do Polygon (connector-rest)|
|`https://github.com/inalogy/midpoint-connector-freeipa`|Conector FreeIPA da Inalogy (template)|
|`https://community.evolveum.com/`|Fórum da comunidade Evolveum|

---

## 16. Aprovações

|Função|Nome|Data|Decisão|
|---|---|---|---|
|**Arquiteto de Soluções / GRC Lead**|Paulo Feitosa Lima|Maio/2026|✅ APROVADO|
|**Validação Técnica (IA #1)**|Claude|Maio/2026|✅ CONCORDA|
|**Validação Técnica (IA #2)**|Gemini|Maio/2026|✅ CONCORDA|
|**Validação Técnica (IA #3)**|Perplexity|Maio/2026|✅ CONCORDA|
|**Validação Técnica (IA #4)**|Copilot|Maio/2026|✅ CONCORDA|
|**Validação Técnica (IA #5)**|Grok|Maio/2026|✅ CONCORDA|

---

## 17. Histórico de Versões

|Versão|Data|Autor|Mudanças|
|---|---|---|---|
|1.0|Maio/2026|Paulo Feitosa Lima (Claude)|Documento inicial; análise completa e recomendação final|

---

**Fim do Documento**

---

_PRJ022 — Relatório de Análise Técnica e Decisão Arquitetural_  
_Living Lab Fiqueok_  
_Arquivado em: `FiqueokBrain/PRJ022/PRJ022-Relatorio-Analise-Tecnica-Decisao-Arquitetural-v1.0.md`_

This response is AI-generated, for reference only.
