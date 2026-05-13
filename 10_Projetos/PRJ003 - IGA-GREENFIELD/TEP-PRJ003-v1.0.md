# TEP-PRJ003 — Termo de Encerramento de Projeto
## IGA Greenfield Reference Architecture

---

| Campo | Valor |
|---|---|
| **Código do Projeto** | PRJ003 |
| **Nome** | IGA Greenfield Reference Architecture |
| **Contexto** | Living Lab Fiqueok 2.0 |
| **Owner** | Paulo Feitosa |
| **Data de Abertura** | 2026-01-14 |
| **Data de Encerramento** | 2026-01-21 |
| **Status Final** | ✅ ENCERRADO COM SUCESSO |
| **Versão deste documento** | 1.0 |

---

## 1. Resumo Executivo

O PRJ003 foi iniciado com o duplo objetivo de formalizar a governança de identidade do Living Lab Fiqueok 2.0 e implantar a plataforma IGA midPoint com repositório nativo PostgreSQL em ambiente Docker. A fase de governança (GMUDs 001–004) foi concluída com sucesso e dentro do prazo. A fase técnica (GMUDs 005–012) enfrentou bloqueadores persistentes relacionados a incompatibilidades da versão midPoint 4.8 com PostgreSQL 16 SCRAM-SHA-256, fallback silencioso para banco H2, e envenenamento de volumes Docker — resultando em 19 tentativas de deploy distribuídas entre as versões 4.8 e 4.9. O sucesso foi alcançado na GMUD-012, com a versão midPoint 4.10, em 1 minuto e 19 segundos de deploy, após a adoção da estratégia de injeção manual prévia de schema ("Soberania de Dados"). O ambiente final entrega midPoint 4.10 + PostgreSQL 16 plenamente operacionais, com 171 objetos iniciais importados e endpoint web respondendo.

---

## 2. Linha do Tempo das GMUDs

### GMUD-001 — Estruturação Inicial do Projeto
**Data:** 2026-01-14 | **Status:** ✅ Concluída com Sucesso

Abertura formal do PRJ003. Definição de propósito, escopo, princípios arquiteturais e estrutura de artefatos. Estabelecimento do documento PRJ003.md como fonte central de verdade do projeto.

**Resultado:** Projeto estruturado e autorizado para execução das GMUDs subsequentes.

---

### GMUD-002 — Consolidação dos Canvases de Decisão de Identidade
**Data:** 2026-01-14 | **Status:** ✅ Concluída com Sucesso

Criação e formalização dos três Canvases de Decisão de Identidade: CAN-ID-001 (Identidade Canônica), CAN-ID-002 (Autoridade de Dados de Identidade) e CAN-ID-003 (Estados da Identidade). Esses artefatos estabeleceram o contrato semântico oficial do projeto.

**Resultado:** Contrato semântico de identidade formalizado. Base estável para GMUDs técnicas futuras. Nenhum incidente.

---

### GMUD-003 — Consolidação da Arquitetura Lógica de Identidade
**Data:** 2026-01-14 | **Status:** ✅ Concluída com Sucesso

Formalização da arquitetura lógica de identidade, criação do Identity Decision Canvas (DEC-ID-001), do diagrama C4 — Contexto e do Data Governance Canvas (DGC-001). Estabelecimento explícito dos limites entre decisão, arquitetura e execução técnica.

**Resultado:** Arquitetura lógica consolidada. Projeto autorizado para GMUDs técnicas com base governada. Nenhum incidente.

---

### GMUD-004 — Cold Start da Infraestrutura IAM
**Data:** 2026-01-14 | **Status:** ✅ Concluída com Sucesso

Provisionamento da VM IGA-GF-01 (Ubuntu Server 24.04 LTS, IP xxx.xxx.xxx.xxx). Instalação do Docker Engine e Docker Compose Plugin via repositório oficial. Validação de acesso SSH e estabilidade do ambiente. Nenhum container funcional implantado nesta etapa.

**Resultado:** Infraestrutura base estável. Todos os critérios de sucesso atendidos. Checkpoint Hyper-V PRE-GMUD-005 criado.

---

### GMUD-005 — Deploy Inicial midPoint 4.8 + PostgreSQL 16
**Data:** 2026-01-17 | **Status:** ❌ Encerrada sem Sucesso — Rollback Aplicado

**Objetivo:** Primeiro deploy de midPoint 4.8 com PostgreSQL via Docker Compose.

**O que foi executado:** Containers iniciados com sucesso, logs confirmaram criação do usuário `administrator`. Interface web acessível em porta 8080.

**Bloqueador:** Falha de autenticação com credenciais padrão (`administrator / 5ecurity`) mesmo após bootstrap confirmado nos logs. Causa raiz não identificada nesta GMUD: distinção entre credencial de repositório (PostgreSQL) e credencial de aplicação (usuário administrador do midPoint).

**Rollback:** Volumes limpos, containers removidos. Ambiente retornado ao estado Cold Start.

---

### GMUD-006 — Deploy com Orquestração de Bootstrap
**Data:** 2026-01-17 | **Status:** ❌ Executada sem Sucesso — Rollback Aplicado

**Objetivo:** Corrigir a race condition da GMUD-005 com inicialização sequencial PostgreSQL → midPoint e healthcheck explícito.

**Bloqueadores (3):**
1. Erro de sintaxe PowerShell (backticks incorretos) — corrigido na v1.4.3
2. Usuário `paulo` sem configuração `NOPASSWD` no sudoers — corrigido durante execução
3. **Crítico:** VM sem conectividade externa (DNS resolver falhou para registry-1.docker.io). Causa: switch virtual Hyper-V perdeu conectividade após restauração de checkpoint.

**Rollback:** Checkpoint PRE-GMUD-005 aplicado. Rede não restaurada pelo checkpoint.

---

### GMUD-007 — Deploy Manual Passo-a-Passo
**Data:** 2026-01-18 | **Status:** ❌ Executada sem Sucesso — Rollback Aplicado

**Objetivo:** Reexecutar o Cold Start após resolução do problema de rede, aplicando correções de variáveis de ambiente.

**Pré-requisitos resolvidos:** Rede do Hyper-V corrigida, DNS operacional, sudo configurado.

**Bloqueador:** docker-compose.yml com variáveis `MIDPOINT_REPOSITORY_*` em formato incorreto para o midPoint 4.8. Resultado: midPoint ativou banco H2 via fallback silencioso em vez de conectar ao PostgreSQL. Log confirmou: `midpoint.repository.database .:. h2`.

**Rollback parcial:** Dados do PostgreSQL preservados para análise forense.

---

### GMUD-008 — Deploy Automatizado via IaC (PowerShell)
**Data:** 2026-01-19 | **Status:** ❌ Executada sem Sucesso — Rollback Aplicado

**Objetivo:** Deploy automatizado via script PowerShell único (v1.4 a v1.9), eliminando intervenção manual.

**9 iterações executadas** (v1.4 a v1.9) ao longo de 3 horas. Três causas raízes identificadas:

1. **Vácuo de variáveis:** Carregamento do `.env` via `Get-Content` com expansão em here-strings gerou senhas vazias (`jdbcPassword` com valor em branco nos logs).
2. **Envenenamento de volume:** PostgreSQL persistiu senha incorreta no `pg_hba.conf` no primeiro boot corrompido; tentativas subsequentes ignoraram novas variáveis.
3. **Conflito de interatividade:** `sudo visudo` via SSH exigiu TTY, quebrando o modelo zero-touch.

**Rollback:** VM revertida ao snapshot PRE-GMUD-008.

---

### GMUD-009 — Deploy Técnico com Análise de Causa Raiz
**Data:** 2026-01-20 | **Status:** ❌ Executada sem Sucesso — Rollback Aplicado

**Objetivo:** Isolar e resolver a causa raiz da falha de injeção de credenciais após análise prévia.

**5 tentativas** com abordagens distintas (3h49min):
- POP v3.0: variáveis duplicadas `REPO_*` + `MP_SET_*` → conflito de precedência, schema 4.6 não encontrado
- POP v4.1: apenas `REPO_*` → `PSQLException: no password was provided`
- POP v4.2: config.xml manual → `Keystore path not defined`
- POP v4.3: Docker Secrets (`_FILE` suffix) → não reconhecido pela imagem 4.8

**Causa raiz identificada nesta GMUD:** O script `docker-entrypoint.sh` da imagem `evolveum/midpoint:4.8` usa `sed` para injetar a senha no `config.xml`. Senhas com caracteres especiais (`#`, `!`) são interpretadas pelo `sed` como delimitadores, resultando em senha incompleta. Fallback silencioso para H2 mascarou o problema.

**Rollback:** Limpeza atômica de volumes.

---

### GMUD-010 — Orquestração e Deploy Automatizado (Ciclo Final 4.8)
**Data:** 2026-01-20 | **Status:** ❌ Executada sem Sucesso — Rollback Aplicado

**Objetivo:** Consolidar todos os aprendizados das GMUDs anteriores em pipeline definitivo para midPoint 4.8.

**14 tentativas** em 2 horas. Marcos alcançados:
- ✅ PostgreSQL 16 operacional com schema nativo (89 tabelas) pela primeira vez (Tentativa #6)
- ✅ Handshake JDBC bem-sucedido (Tentativa #7)
- ✅ Pipeline PowerShell → SSH → Docker validado e funcional

**Bloqueador persistente:** Bug confirmado no `docker-entrypoint.sh` da versão 4.8: lógica de precedência força fallback para H2 quando `REPO_DATABASE_TYPE` não está presente, sobrescrevendo qualquer configuração `MP_SET_*`. Versão 4.8 não inclui scripts SQL embutidos (necessário baixar do GitHub Evolveum). 5 antipadrões catalogados.

**Decisão:** Abandono da versão 4.8 para fins de deploy funcional. Avaliação da versão 4.9.

---

### GMUD-011 — Deploy midPoint 4.9 — Avaliação de Versão
**Data:** 2026-01-21 | **Status:** ❌ Executada sem Sucesso — Rollback Aplicado

**Objetivo:** Validar se a versão 4.9 resolve os problemas de entrypoint da 4.8.

**Resultado:** A imagem `evolveum/midpoint:4.9` manteve o mesmo comportamento problemático. Log confirmou: `Processing variable (MAP) ... midpoint.repository.database .:. h2` mesmo com `REPO_DATABASE_TYPE: postgresql` configurado. O entrypoint 4.9 rejeitou H2 ao detectar configuração Native, gerando falha imediata de inicialização (`Unsupported database type: h2`).

**Lição:** Versão 4.9 não resolveu o bug de precedência de variáveis. Necessário avançar para 4.10.

---

### GMUD-012 — Deploy midPoint 4.10 com Soberania de Dados
**Data:** 2026-01-21 | **Status:** ✅ EXECUTADA COM SUCESSO

**Objetivo:** Deploy definitivo usando midPoint 4.10 com estratégia de injeção manual prévia de schema PostgreSQL.

**Estratégia "Soberania de Dados":**
1. Limpeza nuclear de volumes
2. Boot isolado do PostgreSQL (healthcheck validado)
3. Injeção manual dos 3 scripts SQL oficiais (postgres.sql, postgres-audit.sql, postgres-quartz.sql) via `psql` antes do midPoint subir
4. Boot do midPoint 4.10 com variáveis `MP_SET_*` e credenciais embutidas na URL JDBC

**Duração total do deploy:** 1 minuto e 19 segundos

**Resultados:**
- PostgreSQL 16: ✅ operacional (20s)
- Schema SQALE v51: ✅ completo — Change #51 executado (40s)
- midPoint 4.10: ✅ operacional — startup em 19.63s
- Importação inicial: ✅ 171 objetos importados, 0 erros
- Endpoint HTTP: ✅ `http://xxx.xxx.xxx.xxx:8080` respondendo

**Causa do sucesso:** midPoint 4.10 inverteu a precedência de variáveis (`MP_SET_*` > `REPO_*`), atualizou o driver JDBC para suporte nativo a SCRAM-SHA-256, e eliminou o fallback agressivo para H2.

---

## 3. Estado Final do Ambiente

| Componente | Status | Versão | Observação |
|---|---|---|---|
| VM IGA-GF-01 | ✅ Operacional | Ubuntu 24.04 LTS | IP: xxx.xxx.xxx.xxx |
| Docker Engine | ✅ Operacional | 29.x | |
| PostgreSQL | ✅ Operacional | 16-alpine | Schema SQALE v51, 89 tabelas |
| midPoint | ✅ Operacional | 4.10 | Startup em 19.63s |
| Interface Web | ✅ Acessível | — | http://xxx.xxx.xxx.xxx:8080 |
| Autenticação | ✅ Funcional | — | Usuário `administrator` validado |
| Pipeline PowerShell | ✅ Validado | deploy-v12-final.ps1 | Host → VM via SSH |

**Débitos Técnicos Conhecidos:**
- Senha do `administrator` não trocada após primeiro login (recomendado como próxima ação de compliance)
- Memória disponível limitada a 1.5GB (kernel Ubuntu 24.04) — Heap Java configurado em 1024MB, monitoramento necessário para operações intensivas
- Versão 4.10 usa repositório SQALE (schema UUID + JSONB) — diferente do Hibernate da 4.8; customizações futuras devem considerar essa diferença

---

## 4. Avaliação dos Critérios de Sucesso

| Critério | Meta | Resultado |
|---|---|---|
| CS-01 Artefatos de decisão formalizados | CAN-ID + DEC-ID + DGC criados e consistentes | ✅ Alcançado — GMUD-002/003 |
| CS-02 VM com Docker operacional | `docker ps` sem erros | ✅ Alcançado — GMUD-004 |
| CS-03 midPoint acessível via web | HTTP 200 em porta 8080 | ✅ Alcançado — GMUD-012 |
| CS-04 Login funcional com `administrator` | Autenticação bem-sucedida | ✅ Alcançado — GMUD-012 |
| CS-05 PostgreSQL como repositório nativo | Log confirma `database: postgresql` | ✅ Alcançado — GMUD-012 |
| CS-06 Ambiente reconstruível por documentação | Cold start possível sem memória operacional | ✅ Alcançado — POP documentado |
| CS-07 Script de deploy idempotente | Duas rodadas consecutivas com sucesso | ⚠️ Parcialmente alcançado — pipeline validado, idempotência formal não testada em duas rodadas |

---

## 5. Lições Aprendidas

As lições L-series do PRJ003 continuam a numeração da série iniciada nos projetos anteriores do Living Lab Fiqueok.

**L-01** *(GMUD-002)* — Canvases de decisão de identidade criados antes da execução técnica eliminam ambiguidade e evitam retrabalho arquitetural. O contrato semântico formalizado no CAN-ID-001/002/003 serviu como âncora para todas as GMUDs subsequentes.

**L-02** *(GMUD-005)* — Em plataformas IGA, existem dois níveis de credenciais que precisam ser validados separadamente: a credencial de infraestrutura (senha PostgreSQL) e a credencial de aplicação (senha do usuário `administrator`). A validação da conexão ao banco **não garante** que o usuário administrativo foi criado corretamente.

**L-03** *(GMUD-005)* — O bootstrap de aplicações IGA é sensível a timing. `depends_on` simples no Docker Compose não garante que o PostgreSQL completou a criação do schema antes do midPoint iniciar. Healthcheck explícito (`condition: service_healthy`) é obrigatório.

**L-04** *(GMUD-006)* — Checkpoints Hyper-V podem não restaurar completamente o estado de rede de switches virtuais externos. Validar conectividade de rede (ping externo + resolução DNS) é o **primeiro passo obrigatório** após qualquer restauração de checkpoint.

**L-05** *(GMUD-006)* — Scripts de automação via SSH que executam comandos privilegiados exigem configuração prévia de `NOPASSWD` no sudoers. Esta validação deve fazer parte do Pre-Flight Checklist de toda GMUD técnica automatizada.

**L-06** *(GMUD-007)* — O midPoint 4.8 e 4.9 possuem fallback silencioso para banco H2 quando a configuração de PostgreSQL não é reconhecida. O container inicia, reporta saúde, e responde HTTP 200 — mas está operando com banco em memória. Verificar `midpoint.repository.database` nos logs é obrigatório antes de considerar qualquer deploy bem-sucedido.

**L-07** *(GMUD-008)* — Expansão de variáveis em PowerShell here-strings (`@" "@`) falha silenciosamente quando variáveis não estão no escopo correto. O resultado é senha vazia (`jdbcPassword: ` vazio nos logs) e falha de autenticação sem mensagem clara. Validar o conteúdo das variáveis antes de gerar arquivos de configuração.

**L-08** *(GMUD-008)* — Volumes Docker persistem o hash de senha configurado no **primeiro boot**. Tentativas subsequentes com senhas diferentes são ignoradas porque o PostgreSQL detecta cluster já inicializado. Rollback de volume deve ser atômico: `docker compose down -v` + `sudo rm -rf data/*` sempre juntos.

**L-09** *(GMUD-009)* — O `sed` interpreta caracteres como `#`, `!`, `@` como delimitadores ou comentários quando usados dentro de expressões de substituição. Senhas com caracteres especiais passadas via `sed` para o `config.xml` do midPoint chegam incompletas ou vazias ao JDBC. Usar senhas alfanuméricas ou injetar via URL JDBC diretamente.

**L-10** *(GMUD-009)* — Cinco tentativas sem convergência é o sinal para um pivot estratégico, não para um novo refinamento tático. Regra operacional: máximo 3 tentativas com a mesma abordagem; na quarta, escalar ou mudar a estratégia.

**L-11** *(GMUD-010)* — A versão `evolveum/midpoint:4.8` não inclui scripts SQL embutidos. O schema precisar ser baixado do repositório GitHub da Evolveum e injetado manualmente via `psql` antes de o midPoint subir. Versões 4.9+ incluem os scripts internamente.

**L-12** *(GMUD-010)* — Antipadrão confirmado: nunca fornecer `config.xml` manual no **primeiro boot** do midPoint. O keystore JCEKS ainda não existe no volume, e a aplicação falha com `Keystore path not defined`. O midPoint deve criar o keystore automaticamente no cold start; o `config.xml` manual só deve ser fornecido em boots subsequentes.

**L-13** *(GMUD-010/011)* — O conflito de precedência de variáveis de ambiente é um bug documentado das versões 4.8 e 4.9: `REPO_DATABASE_TYPE` tem que estar presente para que o entrypoint não force H2; mas mesmo quando presente, as variáveis modernas `MP_SET_*` podem ser sobrescritas. A versão 4.10 resolveu esse bug invertendo a precedência.

**L-14** *(GMUD-012)* — A estratégia de "Soberania de Dados" (injetar schema manualmente antes do boot da aplicação) elimina a dependência da lógica de autocreate do entrypoint e garante paridade exata de versão entre schema e aplicação. Esta abordagem é aplicável a qualquer plataforma que usa scripts de inicialização externos.

**L-15** *(transversal)* — O Gate de Reversibilidade (ADR-002) funcionou conforme projetado em 8 GMUDs consecutivas. Nenhuma falha técnica introduziu estado inconsistente irreversível no ambiente. A governança arquitetural projetada no PRJ003 protegeu o projeto de débito técnico acumulado.

**L-16** *(transversal)* — 19 deploys fracassados geraram conhecimento não documentado oficialmente pela Evolveum: 8 antipadrões catalogados, comportamento do SCRAM-SHA-256 com drivers JDBC legados, e a técnica de bypass do entrypoint. Este conhecimento tem valor direto em consultoria de implementação midPoint em clientes corporativos.

---

## 6. Débitos Técnicos

| ID | Descrição | Prioridade | Projeto de Destino |
|---|---|---|---|
| DT-01 | Trocar senha do `administrator` após primeiro login | Alta | Próxima GMUD |
| DT-02 | Implementar healthcheck HTTP no midPoint (valida banco, não apenas porta) | Média | PRJ004 |
| DT-03 | Testar idempotência formal do pipeline (duas rodadas consecutivas) | Média | PRJ004 |
| DT-04 | Monitoramento de consumo de RAM (alerta se heap > 1.2GB) | Média | PRJ004 |
| DT-05 | Desabilitar módulos midPoint não utilizados para reduzir footprint de memória | Baixa | PRJ004 |
| DT-06 | Criar `.env.example` com placeholders para publicação no repositório | Baixa | Encerramento PRJ003 |
| DT-07 | Sanitização de credenciais hardcoded em scripts antes de publicação | Alta | Encerramento PRJ003 |

---

## 7. Aprovação de Encerramento

| Papel | Nome | Data | Status |
|---|---|---|---|
| Owner do Projeto | Paulo Feitosa | 2026-01-21 | ✅ Aprovado |
| GRC Lead | Paulo Feitosa | 2026-01-21 | ✅ Aprovado |

---

---

# Adendo — Retrospectiva Arquitetural

*Este adendo documenta os padrões de comportamento, falhas de decisão e lacunas de orientação identificados em perspectiva retrospectiva. Não representa crítica à execução — representa o aprendizado que deve orientar os próximos projetos.*

---

## A. O Padrão de Comportamento que se Repetiu

Ao longo das GMUDs 005 a 011, um padrão se repetiu com variações: a mesma tentativa foi refinada incrementalmente (nova versão do script, novo ajuste de variável) sem mudar a abordagem fundamental. Cada iteração adicionava uma correção baseada no erro observado, mas não questionava o pressuposto subjacente — que a imagem Docker oficial da Evolveum se comportaria conforme sua documentação pública.

Isso resultou em 14 tentativas na GMUD-010 sozinha e 3 horas e 49 minutos de troubleshooting na GMUD-009, com o mesmo bloqueador fundamental em todas: a lógica interna do `docker-entrypoint.sh` não era o que a documentação descrevia.

O padrão pode ser nomeado: **refinamento tático sem revisão estratégica**. A saída correta teria sido, após 3 tentativas sem convergência, pausar, fazer engenharia reversa do comportamento real (inspecionar o entrypoint diretamente), e mudar de abordagem.

---

## B. Decisões Arquiteturais que Não Foram Tomadas Antes de Executar

Três decisões deveriam ter existido antes da GMUD-005:

**B.1 — Escolha de versão do midPoint com validação de compatibilidade**
Nenhum momento anterior à GMUD-005 incluiu a validação de que a imagem `evolveum/midpoint:4.8` era compatível com PostgreSQL 16 no modo SCRAM-SHA-256. A escolha da versão 4.8 foi feita por familiaridade e posição de LTS, sem teste de smoke em ambiente isolado.

**B.2 — Estratégia de injeção de configuração definida antes do primeiro deploy**
Os dois mecanismos de configuração da imagem (`REPO_*` legado vs `MP_SET_*` moderno) nunca foram avaliados antes da execução. A decisão sobre qual usar foi tomada iterativamente, no meio das falhas, o que multiplicou o número de tentativas com abordagens conflitantes.

**B.3 — Protocolo de validação de bootstrap antes de considerar sucesso**
Não havia, antes da GMUD-005, uma definição formal de como validar que o midPoint havia subido corretamente com PostgreSQL (e não com H2). A validação visual da interface web foi adotada como critério de sucesso — mas a interface web responde igualmente no modo H2 e no modo PostgreSQL. O critério correto (verificar `midpoint.repository.database` nos logs) só foi estabelecido após múltiplas falhas.

---

## C. O que Seria Necessário Saber/Ter Antes da Primeira GMUD Técnica

1. **Um ADR sobre versão do midPoint** com teste de smoke da imagem escolhida em VM temporária, antes de qualquer commit de GMUD
2. **Um documento de estratégia de configuração** definindo qual mecanismo usar (`REPO_*` vs `MP_SET_*`) e documentando o comportamento real do entrypoint
3. **Um checklist de validação de bootstrap** com os comandos exatos para confirmar que o banco é PostgreSQL (não H2), que o keystore foi criado, e que o schema está na versão correta
4. **Um pré-requisito de rede documentado**, incluindo o comportamento de checkpoints Hyper-V com switches externos
5. **Um critério de abandono de versão** formalizado: se após N tentativas uma versão não funciona, a decisão de mudar de versão deve ser tomada via ADR, não via desgaste operacional

---

## D. Onde as IAs que Orientaram o Projeto Falharam

As orientações recebidas das ferramentas de IA ao longo das GMUDs 005–010 operaram consistentemente em nível N2 (executar procedimentos com orientação) quando o contexto exigia nível N4 (diagnóstico de causa raiz sistêmica e revisão de arquitetura).

Manifestações específicas:

**D.1 — Orientação incremental em vez de diagnóstico sistêmico**
Quando uma tentativa falhava, as IAs sugeriam o ajuste seguinte (nova variável, novo formato de senha, novo parâmetro) sem questionar se a abordagem inteira era correta. O diagnóstico de que o `docker-entrypoint.sh` tinha um bug de precedência — e que isso tornava qualquer refinamento de variável inútil — não foi proposto proativamente. Foi descoberto por engenharia reversa após 10+ iterações.

**D.2 — Não questionamento da versão escolhida**
Nenhuma IA sinalizou, durante as GMUDs 005–009, que a versão 4.8 poderia ser incompatível com PostgreSQL 16 SCRAM-SHA-256 de forma fundamental — e que mudar de versão era provavelmente mais eficiente do que continuar ajustando a 4.8. Essa conclusão só chegou após esgotamento das opções táticas.

**D.3 — Ausência de hipótese sobre fallback silencioso**
O comportamento de fallback H2 do midPoint — que faz o container parecer saudável enquanto opera com banco em memória — não foi identificado pelas IAs como armadilha potencial na fase de planejamento. Ele foi descoberto empiricamente nas GMUDs 007 e 010.

**O que orientação N4 teria parecido:**
- "Antes de tentar qualquer ajuste de variável, vamos inspecionar o comportamento real do entrypoint desta versão"
- "Após 3 tentativas sem convergência, a causa raiz provavelmente está fora da camada de configuração que estamos ajustando"
- "Existe uma incompatibilidade de design entre o entrypoint 4.8 e o PostgreSQL 16 SCRAM; mudar de versão é mais eficiente do que contornar isso"

---

## E. O que Levar para os Próximos Projetos

1. **Toda plataforma nova recebe um spike de validação** antes de entrar no roadmap de GMUDs. Um spike é uma GMUD mínima de 2 horas com critério binário: funciona ou não funciona na configuração básica.

2. **Versão de software é uma decisão arquitetural**, não uma escolha operacional. Deve existir em ADR com justificativa e critério de upgrade.

3. **O protocolo de validação de bootstrap é parte do critério de sucesso da GMUD** — não uma etapa implícita. Para qualquer plataforma com fallback silencioso (H2, SQLite embarcado, banco em memória), é obrigatório verificar explicitamente que o banco de dados externo está sendo usado.

4. **Máximo 3 tentativas com a mesma abordagem.** Na quarta, parar, fazer uma análise de causa raiz formal (incluindo inspeção de logs completos e comportamento de internos do sistema), e documentar a decisão de mudar de abordagem em registro próprio antes de continuar.

5. **O conhecimento gerado em falhas é ativo de portfólio.** Os 8 antipadrões catalogados no PRJ003, os 16 lições aprendidas e a técnica de "Soberania de Dados" têm valor direto em contextos de consultoria de implementação IAM/IGA — precisamente porque não estão na documentação oficial.

---

*TEP-PRJ003 v1.0 — Living Lab Fiqueok 2.0*

