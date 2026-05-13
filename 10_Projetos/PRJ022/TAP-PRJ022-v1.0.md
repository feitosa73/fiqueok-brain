**FIQUEOK CONSULTORIA**

Living Lab Fiqueok · Programa PRJ003 — Greenfield

**TAP — Termo de Abertura de Projeto**

**PRJ022 — Integração IGA: OrangeHRM × midPoint via CSV + Spike ScriptedSQL**

|     |     |
| --- | --- |
| **Campo** | **Valor** |
| **Documento** | TAP-PRJ022-v1.0 |
| **Versão** | 1.0 |
| **Data** | Maio / 2026 |
| **Status** | **ABERTO — Aguardando Execução** |
| **Responsável** | Paulo Feitosa Lima |
| **Programa** | PRJ003 — Living Lab Fiqueok · Greenfield |
| **Projeto Predecessor** | PRJ008 — Shadow API REST (FROZEN) |
| **Documentos Base** | TEP-PRJ008-v1.0-FREEZING · PRJ022-Relatório-Análise-Técnica · POP-PRJ022-A-v1.4 |

_Documento gerado com apoio de Claude (Anthropic) · Living Lab Fiqueok_

# **1\. Resumo Executivo**

O PRJ022 formaliza e executa a solução definitiva para a integração entre o OrangeHRM (fonte autoritativa de RH) e o midPoint 4.10 (motor de IGA), bloqueada desde a Sprint 6 do PRJ008 por ausência de conector REST compatível com Java 21.

A decisão arquitetural — validada por cinco IAs independentes e documentada no Relatório de Análise Técnica — estrutura o projeto em dois estágios complementares:

|     |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- |
| **Estágio** | **Abordagem** | **Natureza** | **Probabilidade** | **Prazo Estimado** | **Status** |
| **A** | CSV via Shadow API (CsvConnector nativo) | **Obrigatório** | **95%** | 1 – 2 dias | **POC validada** |
| **B** | Spike ScriptedSQL + HTTP (3 tentativas) | **Spike técnico** | **75%** | 1 dia | **Planejado** |

O critério de sucesso do projeto é determinado exclusivamente pelo Estágio A: a entrega de um pipeline IGA end-to-end operacional com o ciclo JML (Joiner/Mover/Leaver) ativo. O Estágio B é executado em paralelo como spike de melhoria. Caso fracasse após três tentativas documentadas, é encerrado formalmente e o CSV é aceito como solução permanente, com inconformidade arquitetural registrada e mitigada.

# **2\. Contexto Estratégico e Justificativa**

## **2.1. Histórico do Programa PRJ003**

O PRJ022 é o nono projeto do programa PRJ003 (Living Lab Fiqueok Greenfield) e representa a conclusão da jornada de integração IGA iniciada no PRJ003. A tabela abaixo consolida os projetos predecessores relevantes:

|     |     |     |     |
| --- | --- | --- | --- |
| **Projeto** | **Objetivo** | **Resultado** | **Artefato para PRJ022** |
| PRJ003 | Base Greenfield IGA | **Sucesso** | midPoint 4.10 + PostgreSQL 16 operacional |
| PRJ004 | CSV → midPoint → AD | **Sucesso** | Validação do ciclo JML completo com 171 objetos |
| PRJ005 | Conectividade JDBC segura | **Sucesso** | Usuário svc_shadow_api com SELECT restrito |
| PRJ006 | JDBC direto no midPoint | **Abortado** | Decisão API-first documentada — proíbe acesso direto ao MariaDB |
| PRJ007 | HashiCorp Vault | **Sucesso** | Gestão de segredos integrada; policy api-proxy-policy |
| PRJ008 | Shadow API REST (FastAPI) | **FROZEN** | API operacional em :8000 — conector REST bloqueado em Java 21 |

## **2.2. O Bloqueio do PRJ008 — Root Cause Analysis**

A Sprint 6 do PRJ008 tentou configurar o midPoint 4.10 para consumir a Shadow API REST. Três abordagens foram esgotadas antes do freeze:

|     |     |     |
| --- | --- | --- |
| **Tentativa** | **Resultado** | **Causa Raiz Confirmada** |
| Polygon connector-rest (JAR standalone) | **HTTP 404** | Nunca existiu como JAR deployável — é uma biblioteca Maven para desenvolvedores |
| ScriptedREST 1.1.1.e2 (ForgeRock/Evolveum) | **FALHA — GPathResult** | Construído para Groovy 2.x; midPoint 4.10 roda Groovy 4.0 onde GPathResult foi movido |
| Script Groovy mínimo (sem imports de rede) | **Mesmo erro** | Falha ocorre antes de qualquer script — problema estrutural no classpath do JAR |

_A Evolveum declarou o ScriptedREST como depreciado, com 1.1.1.e2 como versão final, sem previsão de manutenção. Não existe alternativa "zero-code" para consumo REST no midPoint 4.10 / Java 21 sem build Java customizado._

## **2.3. Justificativa do PRJ022**

A abertura do PRJ022 é motivada por três fatores convergentes:

- Continuidade operacional: o pipeline IGA é o critical path para a retomada das GMUDs 013 e 014 (provisionamento no Active Directory), bloqueadas desde dezembro/2025.
- Pragmatismo arquitetural: o CsvConnector nativo do midPoint foi validado no PRJ004 (171 objetos, ciclo JML completo). A POC do PRJ022-A já criou 102 usuários com sucesso.
- Evolução técnica controlada: o Estágio B preserva a tentativa de integração API-first sem comprometer a entrega do Estágio A, alinhado ao princípio de decisão por evidências que rege o programa.

# **3\. Escopo do Projeto**

## **3.1. Estágio A — Integração CSV (Obrigatório)**

Implementação em produção do Lab do pipeline OrangeHRM → Shadow API → CSV → midPoint 4.10, seguindo o POP-PRJ022-A-v1.4 já validado. O escopo inclui:

- Script Python de exportação na api-gf-01, consumindo a Shadow API com autenticação via Vault (sem credenciais hardcoded).
- Transferência segura do CSV para iga-gf-02 via SCP com chave SSH (sem senha).
- Configuração do CsvConnector no midPoint com schema handling, correlation rule (employee_id → personalNumber) e synchronization (Unmatched → addFocus).
- Tarefa de reconciliação operacional com agendamento periódico configurado.
- Validação do ciclo JML: Joiner (novo funcionário criado no OrangeHRM aparece no midPoint), Mover (atualização de atributos propagada) e Leaver (desativação refletida no repositório Focus).
- Logging de auditoria em conformidade com ISO 27001 A.8.15.

## **3.2. Estágio B — Spike ScriptedSQL + HTTP (Técnico)**

Execução controlada de até três tentativas para viabilizar integração near-real-time via ScriptedSQL Connector (bundled no midPoint 4.10) como veículo para executar chamadas HTTP via Java 11+ HttpClient. Este estágio não bloqueia o encerramento do projeto.

- Tentativa 1: Configuração do conector ScriptedSQL com JDBC dummy (H2 em memória) e script SearchScript.groovy utilizando java.net.http.HttpClient.
- Tentativa 2 (se T1 falhar): Ajuste de classpath e variáveis de ambiente do container midPoint para resolver dependências Groovy.
- Tentativa 3 (se T2 falhar): Variação de abordagem com HttpURLConnection (java.net) como alternativa ao HttpClient.
- Documentação técnica de resultado — seja conector funcional ou relatório de bloqueio para a comunidade Evolveum.

## **3.3. Fora do Escopo**

Não estão incluídos neste projeto:

- Build Maven customizado do connector-rest Polygon (avaliado como esforço de 4-5 dias com 35% de probabilidade de sucesso — candidato a projeto separado).
- Migração do midPoint para versão superior a 4.10.
- Provisionamento downstream no Active Directory (dependente da GMUD-013/014 — projetos subsequentes).
- Integração com outros sistemas-alvo além do repositório Focus do midPoint.

# **4\. Deliverables e Critérios de Aceite**

## **4.1. Deliverables do Estágio A**

|     |     |     |     |
| --- | --- | --- | --- |
| **ID** | **Deliverable** | **Critério de Aceite** | **Evidência** |
| D-A01 | Script de exportação CSV operacional (api-gf-01) | Execução gera hr_export.csv com 103+ linhas; log registra timestamp e contagem de registros | Saída do script + wc -l |
| D-A02 | Transferência SCP automatizada e segura | CSV transferido sem prompt de senha; permissões 644 no arquivo destino; chave SSH configurada | ls -la no iga-gf-02 |
| D-A03 | Resource CSV no midPoint configurado e testado | Test Connection verde; Discovery exibe colunas emp_number, employee_id, first_name, last_name | Screenshot GUI midPoint |
| D-A04 | Ciclo JML validado no repositório Focus | 102+ usuários criados; correlation sem duplicatas; Joiner, Mover e Leaver funcionais | Lista de Users no midPoint |
| D-A05 | Tarefa de reconciliação com agendamento | Tarefa executando via cron configurado; logs sem erros críticos | Aba Schedule + task log |
| D-A06 | Documentação de encerramento (REL-PRJ022-A) | Relatório com evidências, lições aprendidas e status de compliance | Arquivo .md no Obsidian |

## **4.2. Deliverables do Estágio B**

|     |     |     |     |
| --- | --- | --- | --- |
| **ID** | **Deliverable** | **Critério de Aceite** | **Evidência** |
| D-B01 | Relatório de cada tentativa (T1, T2, T3) | Evidência técnica do resultado — log de erro ou confirmação de sucesso — para cada tentativa realizada | Logs midPoint |
| D-B02a | (Sucesso) Conector ScriptedSQL funcional | Test Connection verde; GET /employees retornando dados; reconciliação sem CSV; ciclo JML near-real-time | Screenshot + logs |
| D-B02b | (Falha) Relatório técnico de bloqueio | Documento estruturado com root cause, evidências e template para reporte à comunidade Evolveum | Arquivo .md + post no fórum |
| D-B03 | Nota de acompanhamento da comunidade Evolveum | Registro de monitoramento do repositório Polygon e fórum Evolveum para novas releases compatíveis com Java 21 | Link salvo no Obsidian |

## **4.3. Critério de Sucesso do Projeto**

O PRJ022 é declarado CONCLUÍDO COM SUCESSO quando o Estágio A estiver integralmente entregue, independentemente do resultado do Estágio B. O pipeline CSV funcional com ciclo JML ativo constitui a entrega mínima viável e o objetivo central do projeto.

_Caso o Estágio B produza um conector funcional, o projeto é encerrado com status CONCLUÍDO COM DISTINÇÃO, e a solução ScriptedSQL substitui o CSV como integração primária._

# **5\. Aprendizado e Recursos Gerados**

## **5.1. Aprendizado Técnico**

O PRJ022 consolida um conjunto de conhecimentos de alto valor para a prática de IAM/GRC que raramente está reunido em um único profissional com evidências documentadas:

- Ciclo completo de integração IGA: da modelagem de fonte autoritativa (OrangeHRM/MariaDB), passando pela abstração via Shadow API (FastAPI/Python), até o consumo pelo motor de governança (midPoint 4.10) com ciclo JML ativo.
- Limites arquiteturais do midPoint 4.10 e Java 21: impacto da migração Groovy 2.x → 4.0, descontinuação do ScriptedREST, inexistência do connector-rest como artefato standalone — com evidências de três tentativas documentadas e validação de cinco IAs independentes.
- Tomada de decisão arquitetural sob adversidade: documentar inconformidades formalmente (CSV viola o princípio API-first), aplicar controles compensatórios e criar o roadmap de evolução futura — metodologia replicável em contextos corporativos reais.
- Segurança operacional no ciclo de identidades: menor privilégio (svc_shadow_api SELECT-only), gestão de segredos via Vault (sem credenciais em código), logging ISO 27001 A.8.15 em todas as camadas do pipeline.

## **5.2. Recursos Técnicos Disponíveis ao Encerramento**

|     |     |     |
| --- | --- | --- |
| **Recurso** | **Descrição** | **Reutilização** |
| **Pipeline IGA end-to-end** | OrangeHRM → Shadow API → CSV → midPoint → repositório Focus, com ciclo JML ativo | Base para provisionamento no AD (GMUD-013/014) |
| **CsvConnector como conector de referência** | Configuração validada e documentada no POP v1.4 com 13 lições aprendidas | Onboarding rápido de novas fontes HR em clientes |
| **Shadow API como ativo reutilizável** | Endpoint REST normalizado, autenticado e versionado, consumível por qualquer sistema HTTP | Keycloak, futuras integrações, demos para clientes |
| **Modelo de spike técnico documentado** | Metodologia de 3 tentativas com evidências estruturadas para conectores problemáticos | Replicável para outros conectores ICF em Java 21 |
| **POP v1.4 como base de conhecimento** | Procedimento operacional completo com troubleshooting, compliance e histórico de versões | Replicação em ambientes de clientes reais |
| **Relatório de Análise Técnica (5 IAs)** | Análise comparativa de 6 caminhos com consenso multi-IA, scripts Groovy prontos e XML de Resource | Referência técnica para projetos REST+midPoint |

## **5.3. Posicionamento para Próximas Frentes**

Ao encerrar o PRJ022, o midPoint do Lab estará posicionado como motor de provisionamento pronto para receber novos targets. O trabalho pesado de configuração da fonte autoritativa — OrangeHRM como HR System of Record — estará integralmente concluído, desbloqueando imediatamente:

- Retomada da GMUD-013 (Configuração do Resource AD no midPoint) e GMUD-014 (Integração LDAPS) — projetos suspensos desde 26/12/2025.
- Expansão para novos targets: Keycloak (SSO), sistemas Linux, ou qualquer recurso com conector ICF disponível.
- Implementação de campanhas de certificação de acesso e relatórios de compliance automatizados.

_O acompanhamento da comunidade Evolveum para novas releases do connector-rest compatíveis com Java 21 permanece como ação contínua. Caso uma versão compatível seja publicada, a substituição do CSV pelo conector nativo poderá ser executada como projeto de melhoria, sem impacto na operação em curso._

# **6\. Arquitetura da Solução**

## **6.1. Ambiente de Infraestrutura (Tailscale Mesh VPN)**

|     |     |     |     |     |
| --- | --- | --- | --- | --- |
| **VM / Hostname** | **IP Tailscale** | **Função** | **Status** | **Relevância PRJ022** |
| DESKTOP-O87TPQI | xxx.xxx.xxx.xxx | Host Windows — administração | **Ativo** | Console Hyper-V |
| vault-gf-01 | xxx.xxx.xxx.xxx | HashiCorp Vault 1.21.3 — PAM / Segredos | **HA Unsealed** | API Key da Shadow API |
| rh-gf-01-local | xxx.xxx.xxx.xxx | OrangeHRM 5.x + MariaDB 10.x — Fonte HR | **Ativo** | Origem dos dados |
| api-gf-01 | xxx.xxx.xxx.xxx | Shadow API (FastAPI/Python) :8000 | **Ativo** | GET /employees + exportação CSV |
| iga-gf-02 | xxx.xxx.xxx.xxx | midPoint 4.10 + PostgreSQL 16 :8080 | **Ativo** | Motor IGA — destino final |

## **6.2. Fluxo de Dados — Estágio A (CSV)**

_OrangeHRM (MariaDB) → Shadow API GET /employees → Script Python (exportação CSV) → SCP → midPoint CsvConnector → Repositório Focus (Users) → Reconciliação JML_

## **6.3. Fluxo de Dados — Estágio B (Spike)**

_midPoint ScriptedSQL → JDBC dummy (H2 in-memory) → Groovy SearchScript → java.net.http.HttpClient → Shadow API GET /employees → JSON parse → Repositório Focus_

## **6.4. Inconformidade Arquitetural Documentada (CSV como Fallback)**

A solução CSV constitui uma inconformidade em relação ao princípio API-first estabelecido no PRJ006. A tabela abaixo registra formalmente a inconformidade e os controles compensatórios aplicados:

|     |     |     |
| --- | --- | --- |
| **Dimensão** | **Inconformidade** | **Controle Compensatório** |
| Princípio arquitetural | CSV viola o princípio API-first (PRJ006) | Shadow API permanece como camada de abstração; CSV é gerado a partir da API, não do banco diretamente |
| Latência | Dados não são near-real-time (batch via cron) | Agendamento configurável (mín. a cada 15 min); aceito para ambiente de Lab |
| Segurança | Arquivo CSV transitório contém dados PII | Permissões 644; transferência via SCP; retenção mínima; logging de acesso |
| Manutenção | Dois pontos de falha (script + cron) em vez de um (conector) | POP v1.4 documentado; troubleshooting guide; rollback via snapshot |

# **7\. Análise de Riscos**

|     |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- |
| **ID** | **Risco** | **Prob.** | **Impacto** | **Severidade** | **Mitigação** |
| R01 | Estágio B falha nas 3 tentativas (bloqueio Java 21 persiste) | **Alta** | **Baixo** | **Moderada** | Aceito — Estágio A garante entrega do projeto. Spike encerrado formalmente com documentação para comunidade Evolveum. |
| R02 | Falha na transferência SCP (chave SSH expirada ou permissões) | **Baixa** | **Médio** | **Baixa** | Pre-flight obrigatório (POP Passo 5); procedimento de rollback via snapshot documentado no POP v1.4. |
| R03 | Correlation duplicando usuários no midPoint | **Baixa** | **Médio** | **Baixa** | Validação V03-V04 obrigatória antes da reconciliação; regra employee_id → personalNumber testada na POC. |
| R04 | Container midPoint não localiza o CSV (mapeamento de volume) | **Média** | **Médio** | **Moderada** | Lição L02 do POP: caminho dentro do container (/opt/midpoint/var/) difere do host. Verificação V01-V02 obrigatória. |
| R05 | API Key da Shadow API expirada ou inválida | **Baixa** | **Alto** | **Moderada** | Validação do endpoint antes de cada execução; chave gerenciada via Vault — rotação controlada. |
| R06 | Vault indisponível durante exportação CSV | **Baixa** | **Médio** | **Baixa** | Vault HA ativo em vault-gf-01. Script detecta erro e registra falha no log sem corromper o CSV anterior. |

# **8\. Cronograma e Marcos**

|     |     |     |     |
| --- | --- | --- | --- |
| **Marco** | **Descrição** | **Prazo** | **Critério de Conclusão** |
| M01 | PRE-FLIGHT — Validação de ambiente e snapshots | Dia 0 | Todos os serviços operacionais; snapshots criados nas duas VMs |
| M02 | ESTÁGIO A — Script de exportação e transferência SCP | Dia 1 | hr_export.csv gerado e validado no container midPoint (wc -l = 103+) |
| M03 | ESTÁGIO A — Resource CSV + Object Type configurados | Dia 1 | Test Connection verde; Discovery com 4 colunas; Correlation e Synchronization ativas |
| M04 | ESTÁGIO A — Ciclo JML validado | Dia 2 | 102+ usuários no repositório Focus; Joiner, Mover e Leaver testados com sucesso |
| M05 | ESTÁGIO B — Tentativa T1 (ScriptedSQL + HttpClient) | Dia 2 | Test Connection executado; resultado documentado com log |
| M06 | ESTÁGIO B — Tentativas T2 e T3 (variações) | Dia 3 | Resultado de cada tentativa documentado; decisão de encerramento do spike tomada |
| M07 | ENCERRAMENTO — REL-PRJ022 emitido | Dia 3 | Relatório de encerramento com evidências, lições aprendidas e próximos passos aprovado |

_Prazo total estimado: 3 dias úteis a partir da aprovação deste TAP. Execução condicionada à disponibilidade do responsável e estabilidade do ambiente Tailscale._

# **9\. Alinhamento com Frameworks de Conformidade**

|     |     |     |
| --- | --- | --- |
| **Framework** | **Controle** | **Implementação no PRJ022** |
| **ISO 27001:2022** | A.5.15 — Menor Privilégio | Usuário svc_shadow_api com SELECT restrito ao schema orangehrm |
| **ISO 27001:2022** | A.8.12 — Gestão de Segredos | API Key armazenada no Vault (secret/orangehrm/db_api); zero credenciais em código |
| **ISO 27001:2022** | A.8.15 — Logging e Auditoria | Log de exportação com timestamp e contagem de registros; logs de tarefa do midPoint preservados |
| **NIST SP 800-53** | AC-2 — Gestão de Contas | Ciclo JML automático: provisionamento e desativação baseados no status HR do OrangeHRM |
| **NIST SP 800-53** | SA-15 — Dependências | Mapeamento de volumes Docker validado; pre-flight obrigatório antes de cada reconciliação |
| **CIS Controls v8** | Control 4 — Configuração Segura | Permissões 755/644 nos diretórios e arquivos CSV; sem uso de chmod 777 |
| **CIS Controls v8** | Control 5 — Gestão de Contas | Correlation rule garantindo unicidade via employee_id; sem duplicatas no repositório Focus |
| **LGPD / GDPR** | Art. 46 — Segurança de Dados | CSV com UTF-8 NFC; dados PII com permissões restritas; transferência via SCP criptografado |
| **SOX** | Segregação de Deveres | Separação entre exportação (script Python / api-gf-01) e importação (midPoint / iga-gf-02) |

# **10\. Governança e Controle de Mudanças**

## **10.1. Responsabilidades**

|     |     |     |
| --- | --- | --- |
| **Papel** | **Nome** | **Responsabilidade** |
| Sponsor / CISO | Paulo Feitosa Lima | Aprovação do TAP, decisões arquiteturais, encerramento do projeto |
| Arquiteto de Soluções | Paulo Feitosa Lima | Definição de escopo, análise técnica, validação de critérios de aceite |
| Executor Técnico | Paulo Feitosa Lima | Execução do POP v1.4, documentação de evidências, realização do spike |
| Auditor GRC | Paulo Feitosa Lima | Validação de compliance, emissão do REL-PRJ022, registro de lições aprendidas |

## **10.2. Acompanhamento Pós-Projeto**

Ao encerrar o PRJ022, as seguintes ações de monitoramento contínuo são registradas no backlog do programa PRJ003:

- Monitorar o repositório https://nexus.evolveum.<REDACTED_SECRET>um/polygon/connector-rest/ para versões >= 3.x com suporte declarado a Java 21.
- Acompanhar o fórum da comunidade Evolveum (https://community.evolveum.com/) para respostas ao issue sobre GPathResult / Java 21.
- Caso seja publicado um JAR standalone compatível, avaliar a substituição do pipeline CSV como projeto de melhoria autônomo.

## **10.3. Controle de Versões do TAP**

|     |     |     |     |
| --- | --- | --- | --- |
| **Versão** | **Data** | **Autor** | **Mudanças** |
| 1.0 | Maio / 2026 | Paulo Feitosa Lima | Documento inicial de abertura do PRJ022 |

# **11\. Aprovações**

A abertura formal do PRJ022 está condicionada à aprovação do responsável listado abaixo. Ao assinar, o aprovador confirma que compreende o escopo, os riscos, os critérios de sucesso e as decisões arquiteturais documentadas neste TAP.

|     |     |     |     |     |
| --- | --- | --- | --- | --- |
| **Papel** | **Nome** | **Data** | **Decisão** | **Assinatura** |
| Responsável / GRC Lead | Paulo Feitosa Lima | Maio / 2026 | **APROVADO** | \___\___\___\___\____ |

_Documento gerado com apoio de Claude (Anthropic) · Living Lab Fiqueok · PRJ022_

_Arquivado em: FiqueokBrain/PRJ022/TAP-PRJ022-v1.0.md_
