---
status: Ativo
versão: 2.0
data: 2026-01-12
tipo: Glossário Consolidado
área: Living Lab Fiqueok - Todos os Domínios
owner: Paulo Feitosa
tags: glossário, IAM, IGA, arquitetura, GRC, observabilidade, segurança
relacionado:
  - Manifesto v2.0
  - ARQ-005 - Memorial de Arquitetura
  - POP-001 - Cold Start Diário
  - ADR-004 - Decisão Connector OrangeHRM
---

# Glossário Completo — Living Lab Fiqueok

**Objetivo**: Linguagem compartilhada para todos os domínios do Lab Fiqueok (IAM/IGA, infraestrutura, GRC, arquitetura, operação), servindo como referência única em GMUDs, ADRs, RNCs, troubleshooting e auditoria.

**Escopo**: 180+ termos técnicos práticos, não jargão vazio, organizados por domínio funcional.

**Versão**: 2.0 — Consolidação dos glossários IAM/IGA e Conceitos Estruturantes

**Data**: 2026-01-12

---

## Índice

1. [IAM / IGA / midPoint](#iam--iga--midpoint)
2. [Diretório / Active Directory](#diretório--active-directory)
3. [Dados, Schema e HR Source](#dados-schema-e-hr-source)
4. [Conectores, APIs e Integração](#conectores-apis-e-integração)
5. [Docker, Infra e Plataforma](#docker-infra-e-plataforma)
6. [Observabilidade, Logs e Jobs](#observabilidade-logs-e-jobs)
7. [Segurança, Ameaças e Risco](#segurança-ameaças-e-risco)
8. [GRC, Auditoria e Compliance](#grc-auditoria-e-compliance)
9. [Change, GMUD, Incidentes e Operação](#change-gmud-incidentes-e-operação)
10. [Fundamentos de Estado e Comportamento](#fundamentos-de-estado-e-comportamento)
11. [Contratos, Acoplamento e Impacto](#contratos-acoplamento-e-impacto)
12. [Resiliência, Execução e Consistência](#resiliência-execução-e-consistência)
13. [Observabilidade, Diagnóstico e Aprendizado](#observabilidade-diagnóstico-e-aprendizado)
14. [Arquitetura, Decisão e Narrativa](#arquitetura-decisão-e-narrativa)

---

## IAM / IGA / midPoint

**IGA (Identity Governance and Administration)** — Framework e ferramentas para administrar ciclo de vida de identidades, acessos e conformidade. Usado quando se fala de midPoint como camada de orquestração entre HR Source e AD. **Relacionados**: IAM, Identity Governance, IdM. **Nota de auditoria**: auditor enxerga IGA como controle chave para A.9 (controle de acesso) e trilha de evidências de quem aprovou o quê.

**IAM (Identity and Access Management)** — Conjunto mais amplo que cobre autenticação, autorização e gestão de contas em sistemas. Usado quando se descreve o escopo do lab (IAM, PAM, IGA, SIEM etc.). **Relacionados**: IGA, IdM, PAM. **Nota de auditoria**: auditor verifica se o escopo de IAM cobre todos os sistemas críticos e se há processo formal de JML.

**midPoint (midPoint IGA Engine)** — Plataforma open source de IGA usada como barramento de identidades entre OrangeHRM e Active Directory. Usado quando se fala de recursos, tarefas, reconciliação, correlação e provisionamento. **Relacionados**: IGA Engine, Identity Repository. **Nota de auditoria**: auditor espera ver configuração versionada, logs de tarefas, evidência de reconciliação e segregação de funções na administração do midPoint.

**HR Source (Fonte Autoritativa de RH)** — Sistema de recursos humanos que é a origem "verdade única" das identidades (OrangeHRM no lab). Usado quando se define quem manda na criação/alteração de colaboradores. **Relacionados**: System of Record (SoR), OrangeHRM, PIM. **Nota de auditoria**: auditor verifica se a fonte autoritativa está claramente definida e documentada e se outras fontes não conseguem criar identidade bypassando o HR.

**Identity Repository (Repositório de Identidades)** — Banco de dados do midPoint que guarda objetos de usuário, shadow accounts e metadados. Usado quando se fala de PostgreSQL 16 como repositório do midPoint. **Relacionados**: midPoint Repository, IGA DB. **Nota de auditoria**: auditor avalia segurança do banco, segregação de acesso DBA vs. admin de aplicação, backups e trilha de alterações de schema.

**Lifecycle JML (Joiner-Mover-Leaver)** — Modelo de ciclo de vida de identidades: admissão, mudança interna e desligamento. Usado ao desenhar fluxos de onboarding e desligamento automáticos via HR Source → midPoint → AD. **Relacionados**: Onboarding, Offboarding, Rehire. **Nota de auditoria**: auditor busca evidências de que cada mudança de status de emprego refletiu em ações coerentes de acesso em tempo razoável.

**Onboarding (Criação de Colaborador)** — Processo de criação de identidade a partir do cadastro inicial no OrangeHRM e propagação ao midPoint e AD. Usado quando se explica que Employee ID ancora o shadow account antes do provisionamento. **Relacionados**: Joiner, Provisionamento inicial. **Nota de auditoria**: auditor analisa se o onboarding depende de aprovação formal, se há segregação de funções e se o tempo de provisionamento é compatível com política.

**Offboarding (Desligamento)** — Processo de revogar acessos e desativar contas quando o colaborador é desligado no HR. Usado quando Employment Status muda para "Desligado" e dispara desativação automática no AD. **Relacionados**: Leaver, Desprovisionamento. **Nota de auditoria**: auditor verifica se contas desligadas permanecem ativas além do prazo definido e se há contas zumbis.

**Employee ID (ID de Empregado)** — Identificador único, sequencial, imutável do colaborador no OrangeHRM, base para correlação determinística. Usado como âncora para correlacionar identidade entre HR Source, midPoint e AD. **Relacionados**: UID, Correlation Attribute. **Nota de auditoria**: auditor trata Employee ID como chave primária de identidade e cobra unicidade, imutabilidade e processo de correção de duplicidades.

**Correlation (Correlação)** — Lógica que diz como o midPoint encontra qual usuário de destino corresponde a um registro de origem. Usado quando se fala de mapping de Employee ID ou username para encontrar contas em AD. **Relacionados**: Deterministic Correlation, Weak Correlation, Matching Rules. **Nota de auditoria**: auditor quer saber quais atributos são usados na correlação e qual o risco de match errado (conta errada recebendo update).

**Deterministic Correlation (Correlação Determinística)** — Correlação baseada em atributo único e estável (ex: Employee ID), que garante match previsível. Usado quando se afirma que o objetivo é provisionamento determinístico a partir de dados limpos no HR. **Relacionados**: Strong Correlation, Exact Match. **Nota de auditoria**: auditor vê correlação determinística como mitigação importante para risco de acesso indevido por atualização em identidade errada.

**Weak Correlation (Correlação Fraca)** — Correlação baseada em atributos mutáveis ou combinados (ex: nome, data de nascimento), mais sujeita a erro. Usado em cenários de fallback quando Employee ID não está disponível ou está inconsistente. **Relacionados**: Fuzzy Match, Heurística. **Nota de auditoria**: auditor enxerga correlação fraca como risco e espera plano de migração para atributo forte e registro de exceções.

**Reconciliation (Reconciliação)** — Processo periódico de comparar estado entre origem e destino para corrigir divergências. Usado quando se fala em tarefas de import e sync no midPoint para alinhar OrangeHRM, midPoint e AD. **Relacionados**: Sync, Inventory Import, Health Check de Identidade. **Nota de auditoria**: auditor espera ver agendamento, logs e resultados de reconciliação, além de tratamento formal de exceções encontradas.

**Provisioning (Provisionamento)** — Criação ou atualização de contas e atributos em sistemas-alvo a partir das regras do midPoint. Usado quando midPoint envia comandos de create/modify para AD baseado em mudanças no HR. **Relacionados**: Deprovisioning, Account Management. **Nota de auditoria**: auditor analisa se há evidências de quem aprovou o acesso que foi provisionado e se o processo é repetível e rastreável.

**Deprovisioning (Desprovisionamento)** — Remoção de acessos e desativação de contas em sistemas-alvo quando identidade deixa de ser elegível. Usado quando Employment Status muda para "Desligado" e o midPoint desabilita conta AD. **Relacionados**: Offboarding, Disable Account. **Nota de auditoria**: auditor olha se deprovisionamento é automático e tempestivo, reduzindo janela de risco de acesso indevido.

**Shadow Account (Conta Sombra)** — Representação de uma conta de destino dentro do midPoint, usada para tracking e reconciliação. Usado quando se fala de OrangeHRM-Source-v4.2 e accounts listadas na aba Accounts do resource. **Relacionados**: Projection, Resource Object. **Nota de auditoria**: auditor avalia se shadow accounts estão consistentes com contas reais e se reconciliações tratam desvios como RNC quando críticos.

**Resource (Recurso midPoint)** — Configuração que define como o midPoint conversa com um sistema-alvo (schema, connector, credentials). Usado em "Resource OrangeHRM-Source-v4.2 → Test Connection". **Relacionados**: Connector, Target System. **Nota de auditoria**: auditor espera ver recursos documentados, versionados e com credenciais protegidas (ex: Vault/secret management).

**Import Task (Tarefa de Importação)** — Job no midPoint que lê objetos do sistema de origem e atualiza o repositório. Usado quando se fala da tarefa "Import OrangeHRM Identities" e seu status (CLOSED, SUCCESS, ERROR). **Relacionados**: Scheduled Task, Reconciliation Job. **Nota de auditoria**: auditor verifica periodicidade, resultados, falhas recorrentes e se erros viram RNC quando impactam conformidade.

**Assignment (Atribuição)** — Relação que vincula usuário a um papel, organização ou recurso dentro do midPoint. Usado para descrever como roles futuras serão baseadas em Job Title para RBAC. **Relacionados**: Role, Org, Policy Rule. **Nota de auditoria**: auditor analisa se assignments são aprovados, se há segregação de funções e se revisão periódica é feita (access review).

**Role (Papel / Função)** — Conjunto de permissões agrupadas que podem ser atribuídas a usuários. Usado em "Role Catalog" futuro onde Job Title mapeia para grupos AD. **Relacionados**: RBAC, Group-based Access. **Nota de auditoria**: auditor verifica se catálogo de papéis está documentado, aprovado e se roles críticos têm donos claros e revisões periódicas.

**RBAC (Role-Based Access Control)** — Modelo de controle de acesso onde permissões são associadas a papéis e não diretamente a usuários. Usado como roadmap quando Job Title do HR será base para atribuição automática de grupos AD. **Relacionados**: ABAC, Group Mapping. **Nota de auditoria**: auditor considera RBAC boa prática e olha se foi implementado sem papéis excessivamente amplos ou sem dono.

**ABAC (Attribute-Based Access Control)** — Modelo de controle de acesso baseado em atributos (cargo, departamento, localização) em vez de papéis fixos. Usado como evolução futura do RBAC no lab quando regras complexas forem necessárias. **Relacionados**: RBAC, Policy-based Access. **Nota de auditoria**: auditor vê ABAC como mais granular mas exige governança forte de atributos.

**Policy Rule (Regra de Política)** — Regra declarativa no midPoint que aplica decisões de compliance, SoD ou remediação automática. Usado em exemplos de regras GRC, como exigir MFA para salários acima de certo valor. **Relacionados**: Constraint, Policy Violation. **Nota de auditoria**: auditor avalia se regras estão alinhadas a controles ISO (ex: privilégio mínimo) e se violações são registradas e tratadas.

**SoD (Segregation of Duties)** — Princípio de separar funções críticas para reduzir risco de fraude ou abuso. Usado quando Department e Job Title são base para futuras regras de segregação em AD. **Relacionados**: Conflito de Atribuições, Dual Control. **Nota de auditoria**: auditor exige matriz de SoD e evidências de monitoramento de conflitos (inclusive nos acessos provisionados via midPoint).

**Cold Start (Inicialização a Frio)** — Processo de subir todo o lab desde o zero (VMs, bancos, containers, midPoint, OrangeHRM) até estado estável. Usado diariamente via POP Cold Start para garantir ambiente consistente antes de qualquer GMUD. **Relacionados**: Boot Sequence, Startup Runbook. **Nota de auditoria**: auditor vê o POP de Cold Start como evidência de controle operacional e rastreabilidade de disponibilidade do ambiente.

**Warm Start (Inicialização Parcial)** — Inicialização de componentes quando infraestrutura base já está ativa, com menor escopo que o Cold Start. Usado em cenários de restart apenas de containers ou serviços específicos sem reinício de todas as VMs. **Relacionados**: Restart Controlado, Partial Recovery. **Nota de auditoria**: auditor verifica se há critérios claros de quando usar warm vs. cold e se riscos de inconsistência são endereçados.

**Health Check (Checagem de Saúde)** — Verificação para saber se serviços e integrações estão operacionais (ping, portas, Test Connection). Usado nos scripts que checam ping do AD, status de containers e Test Connection do resource OrangeHRM. **Relacionados**: Readiness Probe, Liveness Probe. **Nota de auditoria**: auditor valoriza health checks automatizados como controles preventivos com evidências de execução e reação a falhas.

**All Green (Status ALL GREEN)** — Estado em que todos os critérios de sucesso do Cold Start estão atendidos sem restrições. Usado no log diário LOG-COLD-START-YYYY-MM-DD.md para indicar ambiente totalmente saudável. **Relacionados**: Healthy, Sem Restrições. **Nota de auditoria**: auditor pode usar histórico de ALL GREEN vs YELLOW/RED como evidência de maturidade operacional e estabilidade.

**Yellow Status (Estado YELLOW)** — Estado de operação com restrições, onde sistema funciona mas há limitações ou alertas registrados. Usado quando um critério do Cold Start falha, mas há workaround documentado. **Relacionados**: Degradado, Operação com Risco. **Nota de auditoria**: auditor verifica se operação em YELLOW é temporária, documentada com RNC e risco aceito formalmente.

**Red Status (Estado RED)** — Estado de indisponibilidade ou falha crítica do ambiente, bloqueando atividades normais do lab. Usado quando AD, bancos ou containers de aplicação falham em iniciar, acionando ponto de bloqueio crítico. **Relacionados**: Outage, Severity Crítica. **Nota de auditoria**: auditor espera que RED gere incidente formal, análise de causa raiz e plano de ação documentado.

**Blocking Point (Ponto de Bloqueio Crítico)** — Condição explicitamente definida em POPs onde o fluxo deve parar até correção de falha. Usado quando containers de banco ou app não iniciam, impedindo prosseguir com testes de acesso. **Relacionados**: Go/No-Go, Gate de Controle. **Nota de auditoria**: auditor vê pontos de bloqueio como mecanismo formal de evitar bypass de controles sob pressão operacional.

**Test Connection (Teste de Conexão)** — Função do midPoint para validar conectividade e credenciais de um resource. Usado no resource OrangeHRM-Source-v4.2 como critério decisivo de sucesso do Cold Start. **Relacionados**: Connectivity Test, Ping do Recurso. **Nota de auditoria**: auditor considera o print do Test Connection SUCCESS como evidência forte de integridade técnica da integração.

**Import Status (Status de Tarefa midPoint)** — Campo que indica o resultado da última execução da tarefa (CLOSED, SUCCESS, ERROR, RUNNING). Usado para decidir se é necessário troubleshooting ou reprocessamento após o Cold Start. **Relacionados**: Job Status, Execution Result. **Nota de auditoria**: auditor revisa histórico de erros e se eles geraram RNC quando afetaram disponibilidade ou integridade de dados.

**Identity Drift (Desvio de Identidade)** — Situação em que dados de identidade em sistemas-alvo divergem do que está na fonte autoritativa. Usado quando Department, Job Title ou nomes no AD não seguem o que está no OrangeHRM. **Relacionados**: Config Drift, Data Drift. **Nota de auditoria**: auditor vê drift como não conformidade de governança de identidade, devendo gerar RNC e plano de correção.

**Zombie Account (Conta Zumbi)** — Conta ativa em AD ou outro sistema sem vínculo com colaborador ativo (ex-desligado). Usado quando Offboarding falha ou Employment Status não dispara desativação. **Relacionados**: Orphan Account, Stale Account. **Nota de auditoria**: auditor trata conta zumbi como falha grave de controle de acesso (ISO A.9.2.1/9.2.2).

**Orphan Identity (Identidade Órfã)** — Identidade ou conta sem registro correspondente na fonte autoritativa de dados. Usado quando há usuário em AD que não existe no OrangeHRM. **Relacionados**: Zombie Account, Out-of-band Account. **Nota de auditoria**: auditor verifica se há processo recorrente de detecção de órfãs via reconciliação e se correções são formalizadas.

**Rehire (Recontratação)** — Caso de uso em que colaborador retorna com o mesmo Employee ID, reativando identidade histórica sem criar duplicata. Usado como exemplo de benefício de imutabilidade do Employee ID. **Relacionados**: Lifecycle, Reactivation. **Nota de auditoria**: auditor analisa se rehire respeita histórico de acessos e se não restabelece privilégios obsoletos sem revisão.

**Garbage In, Garbage Out (GIGO)** — Princípio de que dados ruins na origem geram identidades ruins e provisioning errado. Usado no manifesto de governança de dados para justificar foco na qualidade no OrangeHRM. **Relacionados**: Data Quality, Input Validation. **Nota de auditoria**: auditor usa GIGO como argumento para focar em controles no HR Source, não apenas no midPoint.

**Identity Timeline (Linha do Tempo da Identidade)** — Visão histórica das mudanças de identidade (status, atributos, acessos) ao longo do tempo. Usado para rastrear onboarding, movimentos internos e desligamento pelo Employee ID. **Relacionados**: Audit Trail, Change History. **Nota de auditoria**: auditor espera conseguir reconstruir a timeline de qualquer identidade crítica com base em logs e GMUDs.

**Attribute Mapping (Mapeamento de Atributos)** — Regras que ligam campos do HR (Employee ID, Department) a atributos de midPoint/AD. Usado quando se define que Department mapeia para OU no AD e Job Title para grupos. **Relacionados**: Transformation, Schema Mapping. **Nota de auditoria**: auditor verifica documentação do mapping e consistência entre o que foi definido e o que está implementado em scripts/config.

**basic.norm (Função de Normalização midPoint)** — Função padrão do midPoint para normalizar strings (ex: remoção de acentos, formatação). Usado no script de geração de username a partir de firstName e lastName. **Relacionados**: String Normalization, Username Policy. **Nota de auditoria**: auditor checa se políticas de nomes definidas em norma corporativa estão refletidas nesta função.

**Username Pattern (Padrão de Username)** — Convenção de nome de usuário (ex: primeironome.sobrenome) usada para sAMAccountName. Usado em SGSI-NORM-IAM-001 e na lógica de generateUsername.groovy. **Relacionados**: Naming Convention, Identifier Policy. **Nota de auditoria**: auditor verifica se padrão é consistente em todo o ambiente e se exceções são aprovadas/documentadas.

**Identity Bus (Barramento de Identidades)** — Metáfora/arquitetura onde o midPoint é o ponto central por onde passam todas as mudanças de identidade. Usado quando se define que scripts diretos em AD são vetados e tudo deve passar pelo midPoint. **Relacionados**: Hub-and-Spoke, Master Data Hub. **Nota de auditoria**: auditor vê o Identity Bus como controle de centralização e exige evidências de que integrações não bypassam o bus.

**PAM (Privileged Access Management)** — Solução para gerenciar, monitorar e auditar acessos privilegiados (administradores, root, Domain Admin). Usado como roadmap futuro no lab para proteger credenciais de alto privilégio. **Relacionados**: Jump Server, Session Recording. **Nota de auditoria**: auditor espera PAM em ambientes com contas administrativas críticas.

---

## Diretório / Active Directory

**Active Directory (AD DS)** — Serviço de diretório da Microsoft usado como target system principal para contas corporativas. Usado no lab como domínio corp.fiqueok.com.br em Windows Server 2022. **Relacionados**: LDAP, Domain Controller. **Nota de auditoria**: auditor analisa hardening, segmentação, delegação de privilégios e governança de grupos.

**Domain Controller (Controlador de Domínio / DC)** — Servidor que hospeda o AD DS e responde por autenticação, LDAP e DNS do domínio. Usado como ID-P-01 no lab, IP xxx.xxx.xxx.xxx. **Relacionados**: FSMO Roles, Global Catalog. **Nota de auditoria**: auditor verifica disponibilidade, backups, logs de segurança e proteção física/virtual do DC.

**corp.fiqueok.com.br (Domínio AD)** — Domínio lógico do laboratório Fiqueok para simular ambiente corporativo real. Usado como destino de provisionamento de usuários pelo midPoint. **Relacionados**: AD Forest, DNS Zone. **Nota de auditoria**: auditor trata o domínio como escopo principal de controle de acesso e exige documentação "as-built".

**Organizational Unit (OU / Unidade Organizacional)** — Contêiner lógico no AD para organizar objetos e aplicar GPOs e delegações. Usado para separar OUUsers, OUFinance, OUIT etc. **Relacionados**: Containers, GPO Scope. **Nota de auditoria**: auditor checa se estrutura de OU reflete a organização e suporte para SoD e RBAC.

**sAMAccountName (Login AD)** — Atributo de login do AD usado para autenticação legado (pré-Windows 2000). Usado para armazenar username do padrão primeironome.sobrenome gerado pelo midPoint. **Relacionados**: userPrincipalName (UPN), CN. **Nota de auditoria**: auditor verifica unicidade, convenção e se contas desativadas mantêm sAMAccountName com registro de motivo.

**userPrincipalName (UPN)** — Nome principal do usuário para autenticação, normalmente no formato user@dominio. Usado para cenários futuros de SSO/Keycloak, embora já faça parte do schema AD. **Relacionados**: sAMAccountName, Login Name. **Nota de auditoria**: auditor valida consistência com e-mail e se UPN é atualizado quando há mudança de nome/política.

**Group (Grupo de Segurança AD)** — Objeto AD usado para atribuir permissões via membership de usuários. Usado no roadmap de RBAC para mapear Job Title em grupos como IT-Admins, Developers. **Relacionados**: Role, Access Group. **Nota de auditoria**: auditor revisa grupos privilegiados, donos de grupo e processo de revisão periódica de membership.

**Service Account (Conta de Serviço)** — Conta técnica usada por aplicações ou scripts (ex: conta svcansible). Usado na GMUD-015A para Ansible e integrações. **Relacionados**: Technical Account, Non-personal Account. **Nota de auditoria**: auditor olha se contas de serviço seguem política específica (senha forte, não expira, uso exclusivo) e se são revisadas.

**Break-glass Account (Conta de Emergência)** — Conta altamente privilegiada usada apenas em situações de emergência. Usado no padrão de AD seguro com processo de break-glass definido. **Relacionados**: Emergency Admin, Firecall ID. **Nota de auditoria**: auditor exige processo de controle de cofre, justificativa, registro de uso e revisão posterior de cada utilização.

**Password Policy (Política de Senhas)** — Conjunto de requisitos de complexidade, expiração e histórico no AD. Usado como referência para hardening de contas de usuário e serviço. **Relacionados**: Fine-grained Password Policy, Lockout Policy. **Nota de auditoria**: auditor compara política configurada com política documentada na PSI e padrões como NIST/ISO.

**Account Lockout (Bloqueio de Conta)** — Mecanismo automático de bloqueio após tentativas de login mal sucedidas. Usado como controle contra brute force em AD. **Relacionados**: Lockout Threshold, Reset. **Nota de auditoria**: auditor verifica se parâmetros são adequados ao risco e se há monitoramento de lockouts anômalos.

**LDAP (Lightweight Directory Access Protocol)** — Protocolo para acesso e consulta ao diretório (porta 389). Usado na integração midPoint-AD via LDAP 389 na GMUD-016. **Relacionados**: LDAPS, Directory Services. **Nota de auditoria**: auditor exige uso de LDAPS em produção, mas pode aceitar LDAP em lab com plano de migração e segmentação forte.

**LDAPS (LDAP over SSL/TLS)** — Versão segura do LDAP (porta 636) com criptografia de canal. Usado como objetivo da Fase 2.0 com Vault emitindo certificados para AD DS. **Relacionados**: TLS, PKI. **Nota de auditoria**: auditor associa LDAPS a controles de confidencialidade e integridade do tráfego de autenticação.

**OU Mapping (Mapeamento de OU)** — Regra que conecta Department no HR a OU de destino no AD. Usado em tabelas que ligam IT → OUIT, Finance → OUFinance etc. **Relacionados**: Provisioning Rule, Directory Structure. **Nota de auditoria**: auditor vê esse mapeamento como evidência de alinhamento organização–diretório e de segregação de ambientes.

**Access Review (Revisão de Acessos)** — Atividade periódica de checagem se acessos ainda são necessários. Usado como futuro processo GRC integrando dados de Salary e Job Title para priorizar revisões. **Relacionados**: Certification, Recertification. **Nota de auditoria**: auditor sempre pergunta por evidência de reviews (relatórios assinados, casos de revogação).

**Stale Object (Objeto Obsoleto)** — Conta ou grupo que não é usado há muito tempo, mas permanece no AD. Usado como alvo de campanhas de limpeza baseadas em logs de login e membership. **Relacionados**: Inactive Account, Zombie Account. **Nota de auditoria**: auditor espera varreduras periódicas de objetos obsoletos e RNC se houver impacto em risco.

**GPO (Group Policy Object)** — Conjunto de configurações aplicadas a objetos do AD (usuários, computadores) dentro de OUs. Usado para aplicar políticas de senha, desktop, segurança de forma centralizada. **Relacionados**: Policy Enforcement, OU Delegation. **Nota de auditoria**: auditor verifica se GPOs estão documentadas, testadas e não criam conflitos de segurança.

**FSMO Roles (Flexible Single Master Operations)** — Funções especiais de um DC (Schema Master, Domain Naming Master, RID Master, PDC Emulator, Infrastructure Master). Usado ao documentar arquitetura do AD e planos de DR. **Relacionados**: Domain Controller, AD Replication. **Nota de auditoria**: auditor checa se papéis FSMO estão documentados e monitorados.

**Kerberos** — Protocolo de autenticação usado pelo AD para verificar identidades sem transmitir senhas pela rede. Usado em contexto de SSO e autenticação corporativa. **Relacionados**: TGT, Service Ticket, Authentication. **Nota de auditoria**: auditor associa Kerberos a controles de autenticação forte e revisa configurações de delegação.

**NTLM (NT LAN Manager)** — Protocolo de autenticação legado, menos seguro que Kerberos. Usado quando se documenta desativação de NTLM como objetivo de hardening. **Relacionados**: Challenge-Response, Legacy Authentication. **Nota de auditoria**: auditor vê uso de NTLM como risco e espera plano de migração para Kerberos.

---

## Dados, Schema e HR Source

**Data Governance (Governança de Dados)** — Conjunto de princípios, processos e papéis para garantir qualidade e uso adequado dos dados. Usado no manifesto de governança de dados HR Source. **Relacionados**: Data Quality, MDM. **Nota de auditoria**: auditor analisa se governança de dados está conectada ao SGSI e se existe dono para cada domínio de dados.

**Data Quality (Qualidade de Dados)** — Grau em que dados são precisos, completos, consistentes e atualizados. Usado quando se exige que nomes estejam completos, sem abreviações indevidas. **Relacionados**: Validation Rules, Cleansing. **Nota de auditoria**: auditor verifica métricas de qualidade e impacto em erros de provisionamento.

**Mandatory Field (Campo Obrigatório)** — Campo que deve ser preenchido no HR para permitir provisioning correto (ex: Department, Job Title). Usado em tabelas de campos obrigatórios e suas funções no IGA. **Relacionados**: Validation, Required Attribute. **Nota de auditoria**: auditor verifica se campos obrigatórios têm enforcement técnico e se falhas bloqueiam provisioning (ou geram RNC).

**Department (Departamento)** — Campo de contexto organizacional do colaborador usado para OU mapping. Usado como base para segregação por OU e relatórios GRC por departamento. **Relacionados**: Org Unit, Cost Center. **Nota de auditoria**: auditor confere se department é consistente entre HR e AD, pois influencia SoD e relatórios de acesso.

**Job Title (Cargo)** — Descrição do cargo do colaborador, fundamento para RBAC futuro. Usado para mapear grupos AD e priorizar revisões de acesso. **Relacionados**: Role, Position. **Nota de auditoria**: auditor avalia se cargos correspondem a perfis de acesso e se existem cargos "genéricos" usados para burlar SoD.

**Employment Status (Status de Emprego)** — Campo que indica se colaborador está Ativo, Suspenso ou Desligado. Usado para triggers de deprovisioning automático. **Relacionados**: HR Lifecycle, State Machine. **Nota de auditoria**: auditor verifica se mudança para Desligado impacta acessos dentro do SLA definido.

**Admission Date (Data de Admissão)** — Data de entrada do colaborador na organização. Usado para regras GRC futuras (ex: bloquear acesso se nunca logou em X dias). **Relacionados**: Hire Date, Effective Date. **Nota de auditoria**: auditor pode cruzar admission date com data de criação de conta AD para avaliar tempestividade do onboarding.

**Salary (Salário)** — Campo numérico de salário bruto, usado para análises de risco e priorização GRC. Usado para regra de compliance: cargos com salário acima de certo valor devem ter MFA e revisões mais frequentes. **Relacionados**: Sensitive Attribute, Risk Weight. **Nota de auditoria**: auditor enxerga salary como dado sensível e avalia se acesso a ele é restrito, logado e justificado.

**Data Drift (Deriva de Dados)** — Mudança gradual em padrões de dados que quebra premissas originais de scripts/regra. Usado quando HR começa a usar abreviações não previstas em nomes ou cargos. **Relacionados**: Schema Evolution, Format Change. **Nota de auditoria**: auditor quer ver monitoramento e atualização de regras quando drift é detectado.

**Normalization (Normalização)** — Processo de padronizar dados (ex: remoção de acentos, espaços) para comparação e geração de usernames. Usado via basic.norm e scripts Groovy no midPoint. **Relacionados**: Sanitização, Canonicalization. **Nota de auditoria**: auditor verifica se regras de normalização são documentadas e testadas para evitar colisões de username.

**Employee Master (Mestre de Empregados)** — Visão consolidada de colaborador com dados HR + IAM. Usado como conceito quando Employee ID unifica trilha HR, midPoint e AD. **Relacionados**: Golden Record, Master Data. **Nota de auditoria**: auditor espera que esse "mestre" consiga responder quem tem quais acessos e por quê.

**Golden Record (Registro Ouro)** — Versão única e definitiva de um registro de identidade usada como referência. Usado implicitamente como Employee ID + dados HR limpos. **Relacionados**: SoR, Master Data. **Nota de auditoria**: auditor valida se há processo de resolução de conflitos para chegar ao golden record.

**MDM (Master Data Management)** — Disciplina de governança que gerencia dados mestres (clientes, produtos, empregados) como ativos críticos. Usado como conceito ao tratar Employee Master e HR Source como MDM de identidades. **Relacionados**: Data Governance, Golden Record. **Nota de auditoria**: auditor associa MDM a controles de qualidade e rastreabilidade de dados críticos.

**Data Lineage (Linhagem de Dados)** — Rastreamento da origem, transformações e destino dos dados ao longo do pipeline. Usado para documentar como Employee ID → midPoint → sAMAccountName. **Relacionados**: Data Flow, Provenance. **Nota de auditoria**: auditor usa lineage para validar integridade de controles ao longo da cadeia de dados.

**Schema Evolution (Evolução de Schema)** — Mudanças no schema de banco ou API ao longo do tempo. Usado quando OrangeHRM adiciona campos ou muda tipos de dados. **Relacionados**: Backward Compatibility, Breaking Change. **Nota de auditoria**: auditor verifica se mudanças de schema são governadas via GMUD e testadas antes de produção.

**PIM (Personal Information Management)** — Sistema para gerenciar dados pessoais de colaboradores (alternativa ao termo HR Source). Usado em contextos mais amplos que RH puro. **Relacionados**: HRIS, HR System. **Nota de auditoria**: auditor trata PIM como custodiante de dados pessoais sensíveis sob LGPD/GDPR.

---

## Conectores, APIs e Integração

**Connector (Conector)** — Componente que permite ao midPoint falar com um sistema (DB, LDAP, REST etc.). Usado para integrar OrangeHRM (DatabaseTable vs ScriptedSQL) e AD. **Relacionados**: ICF Connector, Adapter. **Nota de auditoria**: auditor verifica se conectores são suportados, mantidos e se credenciais são protegidas.

**ICF (Identity Connector Framework)** — Framework de conectores usado pelo midPoint para abstrair acesso a sistemas. Usado em atributos como ICF Name e mapeamentos Employee ID ↔ identity. **Relacionados**: ConnID, Connector Bundle. **Nota de auditoria**: auditor considera a escolha de conectores padrão como redução de risco frente a soluções custom sem suporte.

**DatabaseTable Connector** — Conector do ICF para ler/gravar em tabelas de banco relacional. Usado originalmente na integração OrangeHRM–midPoint, depois descontinuado após falhas (GMUD-017). **Relacionados**: JDBC, ScriptedSQL. **Nota de auditoria**: auditor examina post-mortem da falha e justificativa da mudança de abordagem registrada em ADR.

**ScriptedSQL Connector** — Conector que usa scripts (ex: Groovy) para executar SQL customizado no midPoint. Usado como solução escolhida em ADR-004 para integrar OrangeHRM com flexibilidade. **Relacionados**: Groovy, Custom Connector. **Nota de auditoria**: auditor checa se scripts são versionados, testados e não introduzem riscos de injeção ou bypass de controles.

**Groovy Script (Script Groovy)** — Linguagem utilizada para scripts do ScriptedSQL e normalização de usernames. Usado para SearchScript, TestScript e generateUsername.groovy. **Relacionados**: JVM Scripting, DSL. **Nota de auditoria**: auditor verifica governança de código (revisão, repositório, testes) e acesso a scripts em produção.

**REST API (API REST)** — Interface HTTP usada para integração com sistemas como OrangeHRM. Usado em futuros fluxos quando OrangeHRM expõe endpoints para consulta/atualização. **Relacionados**: JSON, HTTP. **Nota de auditoria**: auditor analisa autenticação da API, logging e rate limiting, especialmente se exposta externamente.

**Test Script (Script de Teste)** — Script de conector usado para validar queries, mapeamentos e performance. Usado em ADR-004 como parte do design do ScriptedSQL. **Relacionados**: SearchScript, Unit Test. **Nota de auditoria**: auditor valoriza scripts de teste como evidência de validação antes de produção.

**SearchScript (Script de Busca)** — Script que define como buscar registros no sistema de origem (ex: empregados no HR). Usado no ScriptedSQL para buscar identidades no OrangeHRM. **Relacionados**: Filter, Query. **Nota de auditoria**: auditor verifica se filtros implementam apenas o necessário e não expõem mais dados do que o requerido.

**Connector Drift (Deriva de Conector)** — Situação em que config do conector diverge do que está documentado em ADR/GMUD. Usado ao discutir falhas recorrentes do DatabaseTable e ajustes pontuais. **Relacionados**: Config Drift, Integration Debt. **Nota de auditoria**: auditor espera reconciliação entre "as-built" do resource e design aprovado no ADR.

**Linking (Vinculação / Linking de Conta)** — Ato de associar identidade do midPoint com conta existente em AD. Usado em GMUD-016 com "linking do usuário 0001". **Relacionados**: Reconciliation, Existing Account. **Nota de auditoria**: auditor verifica se linking segue critério claro e se não gera duplicidades.

**Backend Bridge Network (Rede de Integração)** — Rede Docker usada para tráfego interno entre stacks IGA e HR (fiqueok-backend-net). Usado para isolar comunicações entre midPoint e OrangeHRM. **Relacionados**: Integration Network, Service Mesh. **Nota de auditoria**: auditor avalia se tráfego sensível está restrito à rede interna e se há firewalling adequado.

**Timeout (Estouro de Tempo)** — Falha de integração devido a tempo de resposta excedido. Usado em testes de acesso via navegador quando midPoint ainda está inicializando Tomcat. **Relacionados**: Retry Logic, Circuit Breaker. **Nota de auditoria**: auditor verifica se timeouts causam incidentes visíveis e se há monitoramento.

**Idempotent Operation (Operação Idempotente)** — Operação que pode ser repetida sem alterar o resultado final além do esperado. Usado implicitamente em scripts de verificação/inicialização de containers (rodar várias vezes é seguro). **Relacionados**: Safe Retry, Declarative State. **Nota de auditoria**: auditor vê idempotência como boa prática para automação de infraestrutura.

**API Gateway** — Componente que centraliza acesso a APIs, aplicando autenticação, rate limiting e logging. Usado como objetivo futuro para expor APIs de IGA de forma controlada. **Relacionados**: Reverse Proxy, API Management. **Nota de auditoria**: auditor espera gateway em ambientes com múltiplas APIs externas.

**Webhook** — Mecanismo de callback HTTP para notificação assíncrona de eventos. Usado como possível evolução para integração real-time entre HR e midPoint. **Relacionados**: Event-driven, Push Notification. **Nota de auditoria**: auditor verifica autenticação, retry logic e logging de webhooks.

**Message Queue (Fila de Mensagens)** — Sistema de enfileiramento assíncrono para integração desacoplada (ex: RabbitMQ, Kafka). Usado como arquitetura alternativa para provisionamento em grande escala. **Relacionados**: Event Bus, Pub-Sub. **Nota de auditoria**: auditor avalia se mensagens críticas têm garantia de entrega e auditoria.

**Circuit Breaker** — Padrão de resiliência que interrompe chamadas a sistema com falhas recorrentes para evitar sobrecarga. Usado como objetivo futuro para proteger integrações críticas. **Relacionados**: Fault Tolerance, Retry Logic. **Nota de auditoria**: auditor vê circuit breaker como controle preventivo de cascata de falhas.

---

## Docker, Infra e Plataforma

**Docker Container (Container Docker)** — Unidade de execução isolada para serviços como midPoint, PostgreSQL, OrangeHRM, MariaDB. Usado intensamente no Cold Start (midpoint-db, midpoint-server, orangehrm-db, orangehrm-app). **Relacionados**: Image, Pod. **Nota de auditoria**: auditor verifica controle de imagens, atualização de versões e segregação de redes.

**Docker Compose (docker-compose.yml)** — Arquivo de definição da stack de containers e redes. Usado para subir/atualizar stack IGA e OrangeHRM. **Relacionados**: IaC, Stack Definition. **Nota de auditoria**: auditor considera compose file parte de evidência de arquitetura "as-code" e espera versionamento.

**midpoint-db (Container PostgreSQL)** — Container com PostgreSQL 16 para repositório do midPoint. Usado em scripts de verificação de bancos e PONTO DE BLOQUEIO se ausente. **Relacionados**: Database Container, Stateful. **Nota de auditoria**: auditor checa backup, persistência de volume e acesso restrito ao DB.

**midpoint-server (Container Aplicação midPoint)** — Container com midPoint 4.10 e Tomcat embarcado. Usado em scripts de verificação e startup, porta 8080. **Relacionados**: App Container, IGA Service. **Nota de auditoria**: auditor verifica se logs são persistidos, rotação configurada e acesso administrativo é restrito.

**orangehrm-db (Container MariaDB)** — Container com MariaDB 11.4 para banco do OrangeHRM. Usado em scripts com porta 3306, parte da stack HR. **Relacionados**: HR DB, Relational DB. **Nota de auditoria**: auditor vê orangehrm-db como repositório de dados pessoais sensíveis, requerendo controles adicionais.

**orangehrm-app (Container OrangeHRM)** — Container com aplicação OrangeHRM 5.8. Usado como HR Source com interface na porta 8081. **Relacionados**: HR Application, PIM. **Nota de auditoria**: auditor verifica controle de acesso, logs de administração e proteção de dados pessoais.

**Hyper-V (Microsoft Hyper-V)** — Hypervisor que hospeda VMs do lab Fiqueok. Usado em migração do lab de VirtualBox para Hyper-V (PRJ-INFRA-001). **Relacionados**: Virtualização, vSwitch. **Nota de auditoria**: auditor avalia segregação de redes via vSwitch e hardening do host Hyper-V.

**vSwitch (Virtual Switch)** — Componente de rede virtual do Hyper-V que conecta VMs e VLANs. Usado como vSwitchFiqueokCorp em modo TRUNK com VLANs 1, 20, 30, 40. **Relacionados**: VLAN Trunk, Virtual NIC. **Nota de auditoria**: auditor revisa configuração de trunk e VLAN tagging como evidência de segmentação de rede.

**VLAN (Virtual LAN)** — Segmentação lógica de rede para separar zonas (Mgmt, PKI, IGA, SOC). Usado para criar VLAN 1, 20, 30, 40 com funções específicas. **Relacionados**: Network Segmentation, Zero Trust. **Nota de auditoria**: auditor conecta VLAN mapping a controles ISO A.13.1.3 e NIST PR.AC-5.

**Zero Trust (Modelo Zero Confiança)** — Princípio de não confiar por padrão em nenhuma rede, mesmo interna. Usado quando VLAN 1 → VLAN 20 é bloqueado por default. **Relacionados**: Least Privilege, Microsegmentation. **Nota de auditoria**: auditor verifica se Zero Trust vai além do discurso e aparece em regras de firewall e ACLs.

**Netplan (Configuração de Rede Ubuntu)** — Sistema de configuração de rede em Ubuntu usado no IGA-P-01. Usado para configurar IP estático e DNS para integração com AD. **Relacionados**: YAML Network Config, Networkd. **Nota de auditoria**: auditor verifica se configurações de rede são documentadas e consistentes com diagramas.

**Static IP (IP Estático)** — Endereço IP fixo atribuído às VMs de lab. Usado em GMUD-007 para configurar IP estático em IGA-P-01. **Relacionados**: Address Planning, Network Design. **Nota de auditoria**: auditor verifica se IPs de serviços críticos são estáticos e se há registro atualizado.

**Stateful Service (Serviço Stateful)** — Serviço que mantém estado persistente entre reinícios (ex: bancos, midPoint repository). Usado ao justificar ordem de start: bancos antes das apps. **Relacionados**: Stateful Container, Persistence. **Nota de auditoria**: auditor espera ver processos de backup, restore e testes de recuperação para serviços stateful.

**Stateless Service (Serviço Stateless)** — Serviço que não depende de estado local e pode ser recriado sem perda funcional (ex: front-end). Usado como prática futura para escalabilidade do midPoint ou componentes de UI. **Relacionados**: Scaling, Load Balancer. **Nota de auditoria**: auditor foca mais em disponibilidade do que em backup para componentes stateless.

**Cold Path (Caminho Frio)** — Sequência de inicialização completa desde infraestrutura até apps. Usado no POP Cold Start para definir ordem crítica. **Relacionados**: Startup Runbook, Boot Sequence. **Nota de auditoria**: auditor trata POP como evidência de controle de continuidade operacional.

**State Drift (Deriva de Estado)** — Desalinhamento entre estado desejado (compose, docs) e estado real de containers/hosts. Usado quando containers estão ausentes ou renomeados em relação ao script. **Relacionados**: Config Drift, IaC Drift. **Nota de auditoria**: auditor exige correção de drift e alinhamento com documentação "as-built".

**Container Image** — Template imutável usado para criar containers Docker. Usado ao gerenciar versões de midPoint, PostgreSQL, MariaDB, OrangeHRM. **Relacionados**: Docker Registry, Version Tag. **Nota de auditoria**: auditor verifica origem de imagens, scanning de vulnerabilidades e processo de atualização.

**Volume (Docker Volume)** — Mecanismo de persistência de dados fora do ciclo de vida do container. Usado para bancos de dados e configurações do midPoint. **Relacionados**: Persistent Storage, Bind Mount. **Nota de auditoria**: auditor verifica backup de volumes e testes de restore.

**Infrastructure as Code (IaC)** — Prática de gerenciar infraestrutura via código versionado (docker-compose, scripts). Usado como princípio no lab para rastreabilidade e reprodutibilidade. **Relacionados**: GitOps, Declarative Config. **Nota de auditoria**: auditor valoriza IaC como evidência de controle de mudanças e auditabilidade.

**Snapshot (Checkpoint Hyper-V)** — Captura do estado de uma VM em um ponto no tempo para rollback. Usado para criar pontos de restauração antes de GMUDs críticas. **Relacionados**: Backup, Point-in-time Recovery. **Nota de auditoria**: auditor verifica se snapshots são parte do plano de rollback documentado.

---

## Observabilidade, Logs e Jobs

**Log (Registro de Log)** — Registro de evento de sistema, aplicação ou script. Usado em docker logs, logs do midPoint e OrangeHRM, além de LOG-COLD-START. **Relacionados**: Syslog, Audit Log. **Nota de auditoria**: auditor exige logs imutáveis ou controlados e retenção conforme política.

**Audit Log (Log de Auditoria)** — Logs específicos de ações de administração, acessos e mudanças críticas. Usado em midPoint, AD, HR para rastrear quem fez o quê. **Relacionados**: Security Log, Change History. **Nota de auditoria**: auditor depende desse log para confirmar evidências de conformidade.

**Health Dashboard (Painel de Saúde)** — Visão consolidada de status de serviços e integrações. Usado como objetivo futuro na Fase 3.0 com Wazuh/SIEM. **Relacionados**: Monitoring, NOC Dashboard. **Nota de auditoria**: auditor avalia dashboards como evidência de monitoração contínua.

**Server Task (Tarefa de Servidor midPoint)** — Job agendado no midPoint (import, recon, cleanup). Usado na lista de tasks para verificar status da Import OrangeHRM. **Relacionados**: Scheduler, Job. **Nota de auditoria**: auditor verifica se tarefas críticas são monitoradas e se falhas geram tratativas formais.

**Cron-like Schedule (Agendamento Estilo Cron)** — Expressão de agendamento para execução de tarefas em intervalos fixos. Usado para definir periodicidade de reconciliação e import tasks. **Relacionados**: Scheduler, Job Runner. **Nota de auditoria**: auditor checa se janelas de reconciliação são compatíveis com requisitos de negócio.

**Monitoring (Monitoramento)** — Conjunto de ferramentas e processos para acompanhar disponibilidade e performance. Usado como objetivo na Fase 3.0 com Wazuh, TheHive etc. **Relacionados**: Observability, SIEM. **Nota de auditoria**: auditor verifica se monitoração cobre componentes críticos (AD, midPoint, HR, DB).

**SIEM (Security Information and Event Management)** — Plataforma para centralizar logs e gerar alertas de segurança. Usado como Wazuh no roadmap da VLAN 40. **Relacionados**: Log Management, SOC. **Nota de auditoria**: auditor espera correlação de eventos de IAM dentro do SIEM em ambientes maduros.

**Closed Status (Status CLOSED)** — Estado final de uma tarefa ou incidente indicando conclusão. Usado no status de tarefas midPoint e RNCs. **Relacionados**: Resolved, Completed. **Nota de auditoria**: auditor faz amostragem de itens CLOSED para verificar documentação e eficácia da correção.

**Evidence Screenshot (Print de Evidência)** — Captura de tela usada para comprovar execução de teste ou configuração. Usado para registrar Test Connection SUCCESS, status de containers etc. **Relacionados**: Evidence Artifact, Attachment. **Nota de auditoria**: auditor aceita prints quando autenticados (data, ambiente, usuário) e vinculados a GMUD/RNC.

**Execution Log (Log de Execução)** — Arquivo resumindo execução de um procedimento (ex: LOG-COLD-START-YYYY-MM-DD). Usado para registrar status geral (ALL GREEN/YELLOW/RED) e exceções. **Relacionados**: Runbook Evidence, Operational Log. **Nota de auditoria**: auditor utiliza esses logs como evidência de operacionalização de POPs.

**Health Probe (Prova de Saúde)** — Checagem automática usada por orquestradores/containers para refletir status (healthy/starting). Usado na inspeção de health check do midpoint-server/orangehrm-app. **Relacionados**: Liveness, Readiness. **Nota de auditoria**: auditor vê health probes como parte de desenho resiliente, especialmente em ambientes produtivos.

**Log Retention (Retenção de Logs)** — Política definindo por quanto tempo logs devem ser mantidos. Usado para compliance com ISO 27001 e requisitos de auditoria. **Relacionados**: Log Management, Compliance. **Nota de auditoria**: auditor verifica se retenção atende requisitos legais e permite investigação de incidentes.

**Log Rotation (Rotação de Logs)** — Processo automático de arquivar logs antigos e criar novos para evitar crescimento descontrolado. Usado em containers e VMs do lab. **Relacionados**: Log Management, Disk Space. **Nota de auditoria**: auditor checa se rotação não perde logs críticos e se arquivos antigos são preservados conforme política.

**Correlation Rule (Regra de Correlação)** — Lógica no SIEM que relaciona eventos de múltiplas fontes para detectar padrões de ataque. Usado como objetivo futuro com Wazuh. **Relacionados**: SIEM, Alert. **Nota de auditoria**: auditor avalia se correlações cobrem cenários críticos de IAM (brute force, privilege escalation).

**Metrics (Métricas)** — Valores numéricos coletados sobre performance e comportamento (CPU, latência, taxa de erro). Usado em KPIs do manifesto e monitoramento futuro. **Relacionados**: Telemetry, KPI. **Nota de auditoria**: auditor usa métricas como evidência quantitativa de desempenho de controles.

**Dashboard** — Interface visual que apresenta métricas, status e alertas em tempo real. Usado como objetivo para observabilidade consolidada de IAM. **Relacionados**: Visualization, Monitoring. **Nota de auditoria**: auditor valoriza dashboards que facilitam detecção rápida de anomalias.

**Alerting (Alertas)** — Mecanismo de notificação automática quando condições anormais são detectadas. Usado como evolução do monitoramento passivo para ativo. **Relacionados**: Notification, Threshold. **Nota de auditoria**: auditor verifica se alertas críticos têm resposta definida e são testados.

---

## Segurança, Ameaças e Risco

**Threat (Ameaça)** — Evento ou ator que pode explorar vulnerabilidade e causar impacto. Usado em contexto de threat intelligence e GRC. **Relacionados**: Vulnerability, Risk. **Nota de auditoria**: auditor espera registro de principais ameaças e como controles IAM as mitigam.

**Vulnerability (Vulnerabilidade)** — Fragilidade que pode ser explorada por ameaça. Usado em POP-GRC-001 para gestão de vulnerabilidades. **Relacionados**: Weakness, CVE. **Nota de auditoria**: auditor verifica se vulnerabilidades de IAM (senhas fracas, contas zumbis) entram no processo formal de tratamento.

**Risk (Risco)** — Combinação de probabilidade e impacto de uma ameaça explorando vulnerabilidade. Usado no manifesto como risco cibernético e IAM. **Relacionados**: Risk Register, Residual Risk. **Nota de auditoria**: auditor cobra matriz de risco e associação de riscos a controles específicos.

**Blast Radius (Raio de Impacto)** — Amplitude de impacto caso um controle falhe ou credencial seja comprometida. Usado no glossário do manifesto e em decisões de segmentação. **Relacionados**: Scope of Impact, Lateral Movement. **Nota de auditoria**: auditor pergunta como o desenho reduz blast radius de uma conta comprometida.

**Least Privilege (Privilégio Mínimo)** — Princípio de conceder apenas o acesso estritamente necessário. Usado como base para RBAC e grupos no AD. **Relacionados**: Need-to-know, Access Minimization. **Nota de auditoria**: auditor verifica se perfis padrão não dão privilégios excessivos e se exceções são justificadas.

**Segregation of Environments (Segregação de Ambientes)** — Separação entre ambientes (lab, produção, teste) ou zonas de segurança. Usado ao falar de VLANs e segmentação de rede. **Relacionados**: Environment Hardening, Isolation. **Nota de auditoria**: auditor observa se ambientes de teste não têm acesso direto a dados de produção.

**PKI (Public Key Infrastructure)** — Conjunto de componentes para gerir certificados e chaves. Usado com Vault para emitir certificados para AD e LDAPS. **Relacionados**: CA, Certificates. **Nota de auditoria**: auditor verifica governança de certificados e proteção de chaves privadas.

**HashiCorp Vault (Vault)** — Ferramenta para gestão de segredos e PKI no lab. Usado na VLAN 20 como PKI e secrets management. **Relacionados**: Secret Management, KMS. **Nota de auditoria**: auditor avalia se senhas de conectores e certificados são geridos via Vault ou equivalente.

**Encryption (Criptografia)** — Proteção de dados por algoritmos criptográficos (em trânsito e em repouso). Usado em contexto de LDAPS, PKI, proteção de bancos. **Relacionados**: TLS, At-rest Encryption. **Nota de auditoria**: auditor exige mapeamento claro do uso de criptografia em controles ISO A.10/A.8.

**Account Compromise (Comprometimento de Conta)** — Situação em que atacante obtém credenciais e usa conta legítima. Usado como cenário de risco para blast radius e segmentação. **Relacionados**: Credential Theft, Phishing. **Nota de auditoria**: auditor verifica se há detecção e resposta a acessos anômalos.

**Shadow IT (TI Sombra)** — Uso de ferramentas/sistemas fora da governança oficial. Usado implicitamente na proibição de scripts diretos em AD contornando midPoint. **Relacionados**: Unmanaged IT, Rogue Systems. **Nota de auditoria**: auditor é sensível a Shadow IT que cria identidades sem rastreio.

**Drift de Configuração (Config Drift)** — Divergência entre configuração desejada e real de sistemas ou redes. Usado em memorial de arquitetura quando rede/VMs mudam sem atualização de docs. **Relacionados**: State Drift, IaC Drift. **Nota de auditoria**: auditor exige correção de drift e revisão das GMUDs afetadas.

**Attack Surface (Superfície de Ataque)** — Conjunto de pontos que podem ser explorados por atacante. Usado ao justificar segmentação e redução de exposição de serviços. **Relacionados**: Exposure, Hardening. **Nota de auditoria**: auditor espera ver iniciativas para reduzir superfície de ataque de IAM (AD, midPoint, HR).

**MFA (Multi-Factor Authentication)** — Autenticação com dois ou mais fatores (senha + token, biometria). Usado como controle futuro para contas privilegiadas e high-risk users. **Relacionados**: 2FA, Strong Authentication. **Nota de auditoria**: auditor espera MFA em contas administrativas e vê ausência como NC grave.

**
