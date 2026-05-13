---
id_documento: MET-IAM-001
titulo: IAM Lab Foundation - Guia de Boas Práticas para Implementação Resiliente
tipo: Metodologia
status: Ativo
data_criacao: 09/01/2026
data_revisao: 09/01/2026
autor: Paulo Feitosa (Fiqueok)
revisor: Perplexity Pro (GRC Lead)
owner: Paulo Feitosa - Owner/CISO
contexto: Lab Fiqueok 2.0 - Metodologia de Referência para Arquitetura IAM End-to-End
versao: 1.0
localizacao: 30_Recursos/00_Metodologia_Fiqueok/IAM
classificacao: Internal Use - Methodology
tags: [IAM, IGA, midPoint, OrangeHRM, Active Directory, Resiliência, Bootstrap, Metodologia]
decisoes_relacionadas: 
  - ADR-004 (Connector ScriptedSQL vs DatabaseTable)
  - ARQ-003 (Arquitetura de Governança de Identidades)
  - DDR-001 (Adoção de Plataforma IGA vs Scripting)
documentos_relacionados:
  - GMUD-010 (Falha DatabaseTable - 1ª tentativa)
  - GMUD-013 (Falha DatabaseTable - 2ª tentativa)  
  - GMUD-017 (Falha DatabaseTable - 3ª tentativa)
  - POP-LAB-001 (Cold Start Diário)
---

# IAM Lab Foundation: Guia de Boas Práticas para Implementação Resiliente

## Introdução

Este guia consolida as melhores práticas de governança e engenharia de sistemas para a concepção de um laboratório de Gerenciamento de Identidades e Acessos (IAM) de ponta a ponta. O foco desta metodologia é garantir a **resiliência por design**, evitando falhas comuns de persistência, inconsistências de schema e riscos de interdependência de dados que frequentemente comprometem ambientes de teste integrados.

Este documento foi criado como **referência metodológica** para reiniciar e readequar o Lab IAM da Fiqueok sempre que necessário, incorporando lições aprendidas de 3 GMUDs falhadas (010, 013, 017) e decisões arquiteturais formalizadas em ADRs.

---

## ### TITLE 1. Papel de Cada Ferramenta

O sucesso de uma arquitetura de IAM depende do entendimento claro do papel que cada componente desempenha. No nosso laboratório, a distribuição de responsabilidades é fundamental para garantir um fluxo de dados coeso e seguro.

| Ferramenta | Papel Principal | Descrição | Decisão Formal |
| :--- | :--- | :--- | :--- |
| **OrangeHRM** | Fonte da Verdade (Authoritative Source) | O OrangeHRM servirá como o ponto de partida para todas as identidades. Ele é o sistema onde os registros de colaboradores (novas contratações, alterações de cargo, desligamentos) são criados e mantidos. Qualquer alteração no ciclo de vida de um colaborador deve ser iniciada aqui para garantir que o processo de IAM reflita a realidade do RH. | ARQ-003 |
| **midPoint** | Motor de Governança e Provisionamento (IGA) | O midPoint atuará como o **cérebro da solução**, orquestrando o fluxo de identidades. Ele irá consumir os dados do OrangeHRM, aplicar regras de negócio, políticas de acesso e provisionar/desprovisionar contas e acessos no Active Directory. O midPoint é responsável pela reconciliação, auditoria e governança dos acessos. | DDR-001, ARQ-003 |
| **Active Directory** | Sistema Alvo (Target System) | O Active Directory será o principal sistema de diretório onde as contas de usuário serão criadas, atualizadas e desativadas pelo midPoint. Ele funcionará como o repositório central de identidades para autenticação e autorização em outros sistemas e aplicações no ambiente do laboratório. | ARQ-003 |

> **Princípio Arquitetural**: O fluxo de dados é **unidirecional**: OrangeHRM → midPoint → AD. Conforme estabelecido em ARQ-003, o midPoint **nunca** altera dados de volta no OrangeHRM para preservar a integridade da fonte autoritativa.

---

## ### TITLE 2. Decisões Arquiteturais Pré-Integração

Antes de iniciar a configuração técnica, é crucial definir alguns parâmetros que guiarão a implementação. Decisões mal planejadas nesta fase podem levar a retrabalho e falhas de segurança.

### 2.1. Modelo de Dados e Mapeamento de Atributos

- **O que decidir**: Quais atributos do OrangeHRM (ex: nome, sobrenome, cargo, departamento, matrícula) serão mapeados para o midPoint e, subsequentemente, para o Active Directory (ex: `sAMAccountName`, `userPrincipalName`, `displayName`, `department`).

- **Por que é importante**: Garante a consistência dos dados entre os sistemas e evita a propagação de informações incorretas. É preciso definir um **identificador único** (como a matrícula do funcionário) que servirá como a chave de correlação entre os sistemas.

### 2.2. Ciclo de Vida da Identidade (Joiner, Mover, Leaver)

- **O que decidir**: Como cada evento de RH será tratado:
  - **Joiner** (novo colaborador): Conta criada no AD em até 24 horas?
  - **Mover** (mudança de cargo): Dispara revisão de acessos?
  - **Leaver** (desligamento): Desativação imediata da conta?

- **Por que é importante**: Automatiza os processos de RH, reduz o risco de acessos indevidos e garante que os usuários tenham os recursos necessários para suas funções no tempo certo.

### 2.3. Estratégia de Conectividade OrangeHRM ↔ midPoint

- **O que decidir**: Como o midPoint se conectará ao OrangeHRM. A versão Open Source do OrangeHRM não possui um conector nativo no midPoint. As opções são:

| Opção | Descrição | Vantagens | Desvantagens | Status Lab Fiqueok |
|:------|:----------|:----------|:-------------|:-------------------|
| **CSV Export** | OrangeHRM gera arquivo CSV, midPoint importa via batch | Simples, rápido de implementar | Não é real-time, requer cron/scheduler | ❌ Rejeitada (ADR-004) |
| **API REST** | Conector customizado ou genérico para API REST do OrangeHRM | Real-time, enterprise | Complexidade alta, OrangeHRM OS tem API limitada | ❌ Não implementada |
| **DatabaseTable (JDBC)** | Connector ICF genérico lê diretamente MariaDB | Configuração rápida (teoria) | **100% falha** em schemas custom (`hshr_employee`) | ❌ Rejeitada após 3 GMUDs falhadas |
| **ScriptedSQL (Groovy)** | Scripts Groovy customizados com controle total sobre SQL | Controle total, debugging facilitado, auditável | Requer conhecimento Groovy | ✅ **APROVADA (ADR-004)** |

> **Decisão Formal**: O Lab Fiqueok adotou **Connector ScriptedSQL** conforme ADR-004, após histórico de falhas GMUD-010, 013 e 017 com DatabaseTable. Probabilidade de sucesso: 85% vs 30% (DatabaseTable).

- **Por que é importante**: A escolha impacta a complexidade da implementação e a capacidade de resposta do sistema a eventos de RH.

### 2.4. Estrutura de OUs no Active Directory

- **O que decidir**: Definir a estrutura de Unidades Organizacionais (OUs) no AD que receberá as contas de usuário. A estrutura pode ser baseada em departamentos, localidades ou uma combinação de ambos. O midPoint usará essa estrutura para organizar as contas provisionadas.

- **Por que é importante**: Uma estrutura de OUs bem definida facilita a aplicação de políticas de grupo (GPOs) e a delegação de administração.

---

## ### TITLE 3. Integrações Recomendadas no Lab

### 3.1. Integrações que FAZEM Sentido

- **Sincronização OrangeHRM → midPoint**: Esta é a integração central. O midPoint deve ser configurado para ler os dados do OrangeHRM (via CSV, REST ou ScriptedSQL) e criar/atualizar os "meta-usuários" em seu repositório interno.

- **Provisionamento midPoint → Active Directory**: Com base nos dados do RH e nas regras definidas, o midPoint deve provisionar as contas no AD. Isso inclui a criação do usuário, definição de senha inicial, adição a grupos e alocação na OU correta.

- **Reconciliação AD → midPoint**: O midPoint deve ser capaz de ler o estado atual do AD e compará-lo com seu próprio repositório. Isso é crucial para detectar contas criadas manualmente ("rogue accounts") ou alterações feitas diretamente no AD, garantindo que o midPoint permaneça a **fonte de controle**.

### 3.2. Integrações que NÃO Fazem Sentido (Inicialmente)

- **❌ Provisionamento midPoint → OrangeHRM**: O fluxo de dados deve ser **unidirecional** do RH para o IAM. Permitir que o midPoint altere dados no sistema de RH pode violar princípios de governança e integridade dos dados de origem.

- **❌ Autenticação LDAP do OrangeHRM no AD**: Embora o OrangeHRM suporte autenticação via LDAP, habilitar isso no início do laboratório pode complicar o cenário. O foco inicial deve ser no **provisionamento** e no **ciclo de vida da identidade**, não na autenticação federada.

> **Nota de Escopo**: Estas integrações podem ser consideradas em fases futuras (requerem novo ADR se implementadas).

---

## ### TITLE 4. Resiliência de Persistência: Bootstrap Infalível

A falha de inicialização devido a inconsistências no schema de persistência é um risco significativo. Para garantir um **bootstrap infalível** e validação correta do schema, independentemente da imagem do SO ou motor de banco de dados, as seguintes abordagens são recomendadas:

### 4.1. Uso de Contêineres e Orquestração (Docker/Kubernetes)

- **Mudança de Baseline**: Adotar uma abordagem de **infraestrutura como código (IaC)** utilizando contêineres (Docker) para o midPoint e seu banco de dados. Ferramentas de orquestração (como Docker Compose para o lab ou Kubernetes para um ambiente mais próximo de produção) garantem que o ambiente seja provisionado de forma consistente e replicável.

- **Benefícios**: Imagens de contêineres encapsulam todas as dependências, garantindo que o ambiente de execução do midPoint e do banco de dados seja idêntico em qualquer lugar. Isso elimina inconsistências relacionadas ao SO base.

### 4.2. Gerenciamento de Migrações de Schema

- **Ferramentas de Migração de Banco de Dados**: Utilizar ferramentas como **Flyway** ou **Liquibase** para gerenciar as migrações de schema do banco de dados do midPoint. Essas ferramentas permitem versionar o schema do banco de dados e aplicar migrações de forma controlada e idempotente.

- **Processo de Bootstrap**: O processo de inicialização do midPoint deve incluir uma etapa automatizada de verificação e aplicação de migrações de schema. Isso garante que o banco de dados esteja sempre na versão esperada do schema antes que a aplicação tente acessá-lo.

- **Validação de Checksum**: Ferramentas de migração de schema utilizam checksums para validar a integridade dos scripts de migração, prevenindo a aplicação de scripts corrompidos ou alterados indevidamente.

### 4.3. Banco de Dados Dedicado e Externo

- **Separação de Responsabilidades**: Em vez de um banco de dados embarcado ou compartilhado, o midPoint deve utilizar um banco de dados externo e dedicado (ex: PostgreSQL, MySQL). Isso isola a persistência do ciclo de vida da aplicação.

- **Configuração Explícita**: A configuração da conexão com o banco de dados deve ser explícita e validada no início do bootstrap, com mecanismos de retry e timeouts configuráveis para lidar com indisponibilidades temporárias do banco.

---

## ### TITLE 5. Governança de Ativos: Separação de Responsabilidades

Em ecossistemas de IAM integrados, a manutenção do orquestrador exige uma governança rigorosa de ativos e uma clara separação de responsabilidades para evitar a corrupção acidental de dados em sistemas adjacentes.

### 5.1. Isolamento de Ambiente e Dados

- **Ambientes Distintos**: Manter ambientes de desenvolvimento, teste e produção (ou lab) completamente segregados. Isso inclui redes, máquinas virtuais/contêineres e, crucialmente, bancos de dados.

- **Dados Sintéticos/Anonimizados**: No ambiente de laboratório, utilizar dados sintéticos ou anonimizados para simular o OrangeHRM e o Active Directory. **Nunca** conectar o ambiente de lab a sistemas externos de produção ou que contenham dados sensíveis reais, a menos que seja estritamente necessário e com aprovação formal e controles de segurança robustos.

### 5.2. Princípio do Menor Privilégio (Least Privilege)

- **Contas de Servço Dedicadas**: Cada integração (midPoint→AD, midPoint→OrangeHRM) deve usar contas de serviço dedicadas com as permissões **mínimas** necessárias para realizar suas funções:
  - Conta de serviço do midPoint no AD: permissão apenas para criar, modificar e desativar usuários em OUs específicas (não admin de domínio)
  - Conta do midPoint no MariaDB: permissão apenas `SELECT` na tabela `hshr_employee` (conforme ARQ-003)

- **Restão de Acesso ao Banco de Dados**: A conta de usuário do midPoint no banco de dados deve ter permissões restritas apenas ao schema e tabelas que o midPoint gerencia. Não deve ter permissão para apagar o banco de dados inteiro ou acessar outros schemas.

### 5.3. Backup e Recuperação de Desastres (DR)

- **Estratégia de Backup**: Implementar uma estratégia robusta de backup para:
  - Banco de dados do midPoint (ex: `pg_dump` para PostgreSQL)
  - Dados de configuração do midPoint (XMLs de recursos, objetos, etc.)
  - Backups armazenados em local seguro e testados regularmente

- **Planos de Recuperação**: Ter planos de recuperação de desastres bem documentados e testados para o midPoint e seus sistemas adjacentes. Isso inclui procedimentos para restaurar o banco de dados e a aplicação a um estado funcional.

### 5.4. Automação de Manutenção Segura

- **Scripts Idempotentes e Testados**: Qualquer rotina de manutenção ou sanitização deve ser implementada via scripts idempotentes e rigorosamente testados em ambientes isolados antes de ser aplicada ao lab.

- **Revisão de Código e Aprovação**: Todas as alterações em scripts de manutenção ou configurações de ambiente devem passar por revisão de código e aprovação por pares.

---

## ### TITLE 6. Checklist de Prontidão (Readiness)

"A robustez do ambiente antes da automação depende de um checklist de prontidão rigoroso, contemplando protocolos de validação de estado e estratégias de recuperação mandatórias para assegurar a continuidade técnica e diagnósticos precisos."

### 6.1. Pré-requisitos de Infraestrutura

- [ ] **Infraestrutura como Código (IaC)**: O ambiente do midPoint e seu banco de dados foram provisionados via IaC (ex: Docker Compose, Ansible, Terraform) para garantir reprodutibilidade?
- [ ] **Contêineres**: O midPoint e o banco de dados estão rodando em contêineres isolados?
- [ ] **Gerenciamento de Segredos**: Credenciais de banco de dados e APIs estão sendo gerenciadas de forma segura (ex: variáveis de ambiente, Docker Secrets, HashiCorp Vault) e **não hardcoded**?

### 6.2. Ambiente e Conectividade

- [ ] **Conectividade de Rede**: O servidor do midPoint consegue resolver os nomes e alcançar as portas necessárias:
  - OrangeHRM: HTTP/S para API ou porta do banco de dados (3306 MariaDB)
  - Active Directory: portas LDAP 389/636
- [ ] **Firewalls e Regras de Segurança**: As regras de firewall foram configuradas para permitir a comunicação entre os três sistemas nas portas especificadas?

### 6.3. Contas de Serviço e Permissões (Least Privilege)

- [ ] **Conta de Serviço midPoint → AD**: Foi criada uma conta de serviço no Active Directory com as permissões **mínimas** necessárias para o midPoint ler e escrever atributos de usuário (criar, modificar, desativar usuários) em OUs específicas? A conta **não** deve ter privilégios de administrador de domínio.

- [ ] **Acesso ao OrangeHRM**: 
  - Se usando API: midPoint tem credenciais (OAuth2 client ID/secret)?
  - Se usando CSV: midPoint tem permissão de leitura no diretório de export?
  - Se usando ScriptedSQL: midPoint tem credenciais JDBC com permissão `SELECT` apenas na tabela `hshr_employee`?

- [ ] **Permissões de Banco de Dados do midPoint**: A conta de usuário do midPoint no banco de dados possui permissões restritas apenas ao schema e tabelas que o midPoint gerencia?

### 6.4. Validação de Schema e Integridade do Banco de Dados

- [ ] **Migrações de Schema Automatizadas**: O processo de bootstrap do midPoint inclui a execução automatizada de migrações de schema (via Flyway/Liquibase) para garantir que o banco de dados esteja na versão correta?

- [ ] **Validação de Integridade do Schema**: Após a aplicação das migrações, foi executada uma validação de integridade do schema do banco de dados para detectar inconsistências (ex: tabelas ausentes, colunas com tipos incorretos)?

- [ ] **Estado Inicial do Banco de Dados**: O banco de dados do midPoint foi inicializado com um conjunto de dados de configuração base (ex: recursos, objetos de tarefa) que são conhecidamente válidos e consistentes?

### 6.5. Validação Manual dos Conectores

- [ ] **Teste de Conexão do midPoint**: O midPoint consegue estabelecer uma conexão bem-sucedida com o Active Directory e com o OrangeHRM (seja via API, CSV ou ScriptedSQL)? Use a função "Test Connection" da interface.

- [ ] **Leitura de Dados (Reconciliação Inicial)**: O midPoint consegue ler e exibir os dados de:
  - Um usuário de teste do OrangeHRM?
  - Uma conta de teste existente no Active Directory?

- [ ] **Escrita de Dados (Provisionamento Manual)**: A partir da interface do midPoint, é possível:
  - Criar manualmente um usuário de teste no Active Directory?
  - Atualizar um atributo (como o número de telefone) e ver a alteração refletida no AD?

---

## ### TITLE 7. Estratégias de Recuperação (Snapshots/Rollback)

Para mitigar o impacto de falhas e permitir um retorno rápido a um estado conhecido e funcional, as seguintes estratégias de recuperação devem ser implementadas e testadas:

### 7.1. Snapshots de Máquinas Virtuais/Contêineres

- **Ponto de Recuperação**: Antes de qualquer alteração significativa no ambiente (ex: atualização de versão do midPoint, alteração de configuração crítica, execução de automação em massa), criar um snapshot da VM ou do volume de dados dos contêineres. Isso permite um rollback rápido para um estado anterior conhecido.

- **Frequência**: Definir uma política de snapshots (ex: diário, antes de grandes mudanças) e garantir que os snapshots sejam armazenados de forma segura e acessível.

### 7.2. Backup e Restauração do Banco de Dados

- **Backups Lógicos e Físicos**: Implementar rotinas de backup do banco de dados do midPoint (ex: `pg_dump` para PostgreSQL). Testar o processo de restauração regularmente para garantir sua eficácia.

- **Ponto no Tempo (Point-in-Time Recovery)**: Configurar o banco de dados para permitir recuperação pontual, o que é crucial para restaurar o estado exato do banco de dados antes de um incidente.

### 7.3. Versionamento de Configurações (Git)

- **Controle de Versão**: Todos os arquivos de configuração do midPoint (XMLs de recursos, objetos, políticas) devem ser versionados em um sistema de controle de versão (ex: Git). Isso permite rastrear alterações, reverter para versões anteriores e colaborar de forma segura.

- **Implantação Automatizada**: Utilizar ferramentas de automação para implantar configurações versionadas no midPoint, garantindo que o estado da configuração seja sempre o esperado.

### 7.4. Testes de Recuperação de Desastres (DR Drills)

- **Simulação de Falhas**: Realizar exercícios de recuperação de desastres periodicamente, simulando cenários de falha (ex: perda do banco de dados, corrupção de configuração) e testando os procedimentos de restauração. Isso ajuda a identificar lacunas nos planos de recuperação e a treinar a equipe.

A implementação dessas estratégias torna o laboratório de IAM **resiliente** a falhas e provê um ambiente seguro para experimentação, minimizando riscos operacionais críticos e garantindo a rastreabilidade das mudanças.

---

## ### TITLE 8. Matriz de Decisões e Controles de Conformidade

| Decisão Arquitetural | Framework | Controle | Justificativa | Evidência |
|:---------------------|:----------|:---------|:--------------|:----------|
| OrangeHRM como Fonte Autoritativa | ISO 27001:2022 | A.9.2.1 - Registro de usuários | Garante rastreabilidade de origem de identidades | ARQ-003 |
| Fluxo Unidirecional HR→IGA→AD | NIST CSF 2.0 | ID.AM - Asset Management | Evita corrupção de dados na fonte autoritativa | ARQ-003, Seção 4 deste guia |
| ScriptedSQL (Groovy) | ISO 27001:2022 | A.12.1.2 - Gestão de Mudanças | Scripts auditáveis e versionados em Git | ADR-004 |
| Least Privilege (Contas de Serviço) | CIS Controls v8 | 6.1 - Contas de serviço | Reduz superfície de ataque | ARQ-003 |
| Segregação de Redes Docker | ISO 27001:2022 | A.13.1.1 - Controles de rede | Isola componentes críticos (DB não exposto) | ARQ-003 |
| Backup e DR | ISO 27001:2022 | A.12.3.1 - Backup de informações | Garante continuidade operacional | POP-LAB-001 |

---

## ### TITLE 9. Lições Aprendidas do Lab Fiqueok

Este guia incorpora aprendizados práticos de **3 GMUDs falhadas** no Lab Fiqueok 2.0:

### 9.1. GMUD-010: Primeira Tentativa (DatabaseTable)

- **Resultado**: ❌ Falhou - Schema discovery incompleto
- **Causa Raiz**: Connector ICF DatabaseTable não interpreta schemas custom (`hshr_employee`)
- **Lição**: Conectores genéricos não são adequados para schemas não-padrão

### 9.2. GMUD-013: Segunda Tentativa (DatabaseTable v2)

- **Resultado**: ⚠️ Sucesso parcial - Test Connection OK, mas sincronização instável
- **Causa Raiz**: Mapeamento de atributos inconsistente
- **Lição**: "Test Connection" bem-sucedido ≠ Provisionamento funcional

### 9.3. GMUD-017: Terceira Tentativa (DatabaseTable - 5 iterações)

- **Resultado**: ❌ Falha total após 225 minutos de troubleshooting
- **Causa Raiz**: Limitações arquiteturais do connector (comportamento "caixa-preta")
- **Lição**: Insistir na mesma abordagem após 3 falhas é insanidade técnica
- **Decisão Resultante**: ADR-004 formalizou migração para ScriptedSQL

### 9.4. Princípios Consolidados

1. **Validar prontidão antes de automação**: Checklist de Readiness (Seção 6) evita retrabalho
2. **Preferir controle sobre conveniência**: ScriptedSQL > DatabaseTable (debugging facilitado)
3. **Documentar falhas formalmente**: GMUDs falhadas geraram ADR-004 e este guia
4. **Testar recuperação, não só funcionalidade**: Snapshots/rollback são mandatórios (Seção 7)

---

## ### TITLE 10. Documentos Relacionados

### 10.1. Decisões Arquiteturais (ADRs)

- **ADR-004** - Escolha de Connector para Integração OrangeHRM → midPoint (ScriptedSQL vs DatabaseTable)
- **DDR-001** - Adoção de Plataforma IGA vs Scripting (midPoint aprovado)

### 10.2. Arquitetura e Normas

- **ARQ-003** - Arquitetura de Referência – Infraestrutura de Governança de Identidades
- **ARQ-002** - Arquitetura de Referência de Identidade (Core) - AD DS
- **PAD-001** - Padrão de Identidade e Governança (IGA) [Obsoleto - substituído por ARQ-003]

### 10.3. Procedimentos Operacionais

- **POP-LAB-001** - Cold Start Diário do LAB PRJ001 (AD DS + midPoint + OrangeHRM)
- **POP-GRC-001** - Fluxo de Gestão de Vulnerabilidades

### 10.4. GMUDs e Lições Aprendidas

- **GMUD-010** - Configuração do Resource OrangeHRM no midPoint (1ª tentativa - Falhou)
- **GMUD-013** - Configuração do Resource OrangeHRM no midPoint v2 (2ª tentativa - Parcial)
- **GMUD-017** - Correção OrangeHRM → midPoint (3ª tentativa - 5 iterações - Falhou)
- **GMUD-018** - Implementação ScriptedSQL Connector (Planejada - baseada em ADR-004)

### 10.5. Templates e Metodologias

- **TEMPLATE-001** - Relatório de Não-Conformidade (RNC)
- **MET-001** - Framework de Integração GRC & EA [Obsoleto]

---

## ### TITLE 11. Referências Técnicas

[1]: [OrangeHRM Inc and Identity Automation](https://www.orangehrmlive.com/assets/Documents/Resources/Press-Releases/automation.pdf)  
[2]: [OrangeHRM And Identity Automation Join Forces To Integrate...](https://www.hrhub.com/doc/orangehrm-inc-and-identity-automation-join-0001)  
[3]: [MidPoint architecture and design](https://docs.evolveum.com/midpoint/architecture/)  
[4]: [Practical Identity Management With MidPoint](https://docs.evolveum.com/book/practical-identity-management-with-midpoint.html)  
[5]: [How to create an Active Directory account using MidPoint...](https://www.reddit.<REDACTED_SECRET>w/how_to_create_an_active_directory_account_using/)  
[6]: [Active Directory With LDAP Connector](https://docs.evolveum.com/connectors/resources/active-directory/active-directory-ldap/)  
[7]: [OrangeHRM API | Integration | Plugins](https://www.orangehrm.com/en/resources/other-resources/orangehrm-api)  
[8]: [CSV Connector - midPoint](https://docs.evolveum.com/connectors/connectors/com.evolveum.polygon.connector.csv.CsvConnector/)  
[9]: [Configuring LDAP - OrangeHRM](https://starterhelp.orangehrm.com/hc/en-us/articles/6380350066588-Configuring-LDAP)  
[10]: [OrangeHRM Open Source : REST api docs](https://orangehrm.github.io/orangehrm-api-doc/)  
[11]: [Using Native PostgreSQL Repository - MidPoint](https://docs.evolveum.<REDACTED_SECRET>/native-postgresql/usage/)  
[12]: [Repository Database Support - MidPoint](https://docs.evolveum.<REDACTED_SECRET>/repository-database-support/)  
[13]: [Repository Schema update - MidPoint](https://docs.evolveum.com/midpoint/install/repository-schema-update/)  
[14]: [Best Practices for Identity Governance and Administration](https://www.techprescient.com/identity-security/identity-governance-best-practices/)  
[15]: [Mastering Separation of Duties with IGA - Omada Identity](https://omadaidentity.com/resources/blog/separation-of-duties/)  
[16]: [8 Proven Best Practices To Optimize IGA](https://www.zluri.com/blog/iam-governance-best-practices/)

---

## ### TITLE 12. Matriz RACI de Manutenção do Documento

| Atividade | Perplexity (GRC Lead) | ChatGPT (Architect) | Paulo (Owner) |
|:----------|:----------------------|:--------------------|:--------------|
| Revisão anual do guia | A/R | C | A |
| Atualização por novas GMUDs | R | C | A |
| Incorporação de lições aprendidas | R | I | A |
| Validação técnica de arquitetura | C | R | A |
| Aprovação de mudanças | I | I | A |

**Legenda RACI:**  
- **R** (Responsible): Executa a tarefa  
- **A** (Accountable): Responsável final / decision maker  
- **C** (Consulted): Consultado antes da decisão  
- **I** (Informed): Informado após a decisão

---

## ### TITLE 13. Changelog

| Versão | Data | Autor | Mudanças Principais | Aprovador |
|:-------|:-----|:------|:--------------------|:----------|
| 1.0 | 09/01/2026 | Paulo Feitosa | Criação inicial do guia consolidando boas práticas | - |
| 1.1 | 09/01/2026 | Perplexity Pro (GRC Lead) | **Revisão estrutural completa**: Adição de metadados YAML, seção de Lições Aprendidas (GMUDs 010/013/017), referências a ADR-004 e ARQ-003, matriz de decisões/conformidade, RACI de manutenção, correção de typo "PAulo" → "Paulo" | Pendente aprovação Paulo |

---

## ### TITLE 14. Controle de Versão e Próxima Revisão

- **Próxima revisão obrigatória**: 09/07/2026 (6 meses)
- **Trigger de revisão antecipada**: 
  - Falha de GMUD relacionada a IAM
  - Nova decisão arquitetural (ADR) que impacte este guia
  - Mudança de ferramenta (ex: substituição de midPoint ou OrangeHRM)
- **Responsável pela manutenção**: Perplexity Pro (GRC Lead) conforme ADR-002
- **Aprovador final**: Paulo Feitosa (Owner/CISO)

---

**Classificação**: Internal Use - Methodology  
**Repositório**: Obsidian Vault - `FiqueokBrain/30_Recursos/00_Metodologia_Fiqueok/IAM/MET-IAM-001.md`  
**Palavras-chave**: IAM, IGA, midPoint, OrangeHRM, Active Directory, Resiliência, Bootstrap, ScriptedSQL, Least Privilege, Docker, IaC, Lições Aprendidas, GMUD-010, GMUD-013, GMUD-017, ADR-004

---

**FIM DO DOCUMENTO MET-IAM-001**

---

*Documento mantido por Perplexity Pro (Chief Documentation Officer & GRC Lead) conforme ADR-002.*
