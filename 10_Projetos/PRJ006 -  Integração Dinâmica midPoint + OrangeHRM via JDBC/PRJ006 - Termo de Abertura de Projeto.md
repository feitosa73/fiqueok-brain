 (TAP)

**PRJ006 - Integração Dinâmica: midPoint + OrangeHRM (JDBC)**

## Informações do Projeto

- **ID do Projeto:** PRJ006
    
- **Nome:** Integração Dinâmica midPoint + OrangeHRM via JDBC
    
- **Status Histórico:** Encerrado (Migrado para PRJ007)
    
- **Responsável:** Paulo Feitosa (IAM Specialist/Auditor)
    
- **Data de Início:** Janeiro/2026
    
- **Contexto:** Living Lab Fiqueok (Greenfield)
    
- **Plataformas:** midPoint 4.10, OrangeHRM OS 5.8, PostgreSQL/MariaDB
    

---

## Sumário Executivo

O PRJ006 representa a **evolução natural** do Living Lab Fiqueok na jornada de maturidade de Governança de Identidades, transitando de fontes autoritativas estáticas (PRJ004 - CSV) para **sistemas integrados dinamicamente**. Este projeto estabelece o OrangeHRM como fonte autoritativa de identidades em tempo real, simulando o fluxo de dados de uma organização Fintech moderna.

A integração via conector JDBC nativo do midPoint permite que mudanças organizacionais no sistema de RH disparem automaticamente ações de provisionamento no ecossistema de identidades, eliminando intervenções manuais e reduzindo o risco de inconsistências entre sistemas.

Este projeto marca a transição do laboratório de um ambiente de validação conceitual para uma **arquitetura de sistemas integrados** que reflete cenários corporativos reais.

---

## Justificativa Estratégica

## Evolução do Laboratório Greenfield

O PRJ004 validou com sucesso os conceitos fundamentais de governança de identidades utilizando arquivo CSV como fonte autoritativa. Embora bem-sucedido para validação de conceitos, o modelo estático apresentou limitações críticas para simulação de cenários corporativos:

- **Latência de Sincronização:** Mudanças organizacionais requerem atualização manual do arquivo e reimportação
    
- **Ausência de Rastreabilidade:** Sem logs transacionais de mudanças no sistema de origem
    
- **Escalabilidade Limitada:** Modelo inadequado para volumes corporativos de movimentação de colaboradores
    
- **Realismo Reduzido:** Não reflete a arquitetura de sistemas integrados de organizações modernas
    

## Necessidade de Integração Dinâmica

O PRJ006 foi desenhado para **eliminar essas limitações**, estabelecendo o OrangeHRM como fonte autoritativa dinâmica que:

- Simula o fluxo de dados de uma Fintech real onde sistemas HR corporativos alimentam automaticamente a plataforma IGA
    
- Permite validação de cenários complexos de sincronização em tempo real
    
- Demonstra capacidade do midPoint de operar em arquiteturas de sistemas integrados
    
- Estabelece fundações para futuras integrações com sistemas adicionais (Active Directory, aplicações SaaS)
    

## Alinhamento com Missão Fiqueok

Este projeto alinha-se diretamente com a missão da **Fiqueok** de ser plataforma de aprendizado técnico e análise para executivos de TI e Auditoria, demonstrando na prática como implementar governança de identidades em cenários corporativos complexos.

---

## Objetivos do Projeto

## Objetivo Principal

Estabelecer integração funcional e segura entre midPoint e OrangeHRM via protocolo JDBC, permitindo sincronização automatizada de dados de colaboradores e provisionamento baseado em eventos de RH.

## Objetivos Específicos

## Integração de Sistemas

Conectar o midPoint 4.10 ao banco de dados (PostgreSQL/MariaDB) do OrangeHRM via conector DatabaseTable utilizando protocolo JDBC, garantindo comunicação estável e performática.

## Automação JML

Implementar automação completa do ciclo de vida de identidades com foco inicial no processo **Joiner**, garantindo que novos registros inseridos no OrangeHRM sejam automaticamente:

- Descobertos pelo midPoint através de sincronização periódica
    
- Correlacionados corretamente utilizando âncora de ouro (personalNumber)
    
- Provisionados nos sistemas-alvo (OpenLDAP) conforme políticas de governança
    

## Governança de Dados

Validar a **consistência e integridade** do atributo crítico `personalNumber` vindo de base relacional SQL, garantindo que:

- Valores sejam únicos e imutáveis
    
- Correlação entre sistemas seja resiliente
    
- Dados extraídos reflitam estrutura normalizada do banco de dados
    

## Mapeamento Avançado

Implementar mapeamento de atributos complexos incluindo:

- Dados demográficos (nome, sobrenome, email)
    
- Informações organizacionais (cargo, departamento)
    
- Atributos de governança (data de admissão, status de emprego)
    

---

## Escopo do Projeto

## Dentro do Escopo

- Configuração de resource object para OrangeHRM no midPoint
    
- Desenvolvimento de query SQL otimizada para extração de dados via JDBC
    
- Implementação de sincronização automatizada com execução periódica
    
- Mapeamento completo de atributos de colaboradores
    
- Configuração de reações de sincronização para processo Joiner
    
- Validação de provisionamento automático para OpenLDAP
    
- Documentação de procedimentos e troubleshooting
    
- Criação de checkpoints de continuidade operacional
    

## Fora do Escopo

- Processos Mover e Leaver (planejados para iterações futuras)
    
- Provisionamento reverso (midPoint → OrangeHRM)
    
- Integração com sistemas adicionais além do OpenLDAP
    
- Customização da interface do OrangeHRM
    
- Migração de segmento de rede (será tratado no PRJ007)
    
- Implementação de workflows de aprovação
    

---

## Arquitetura de Referência

## Componentes da Solução

**Fonte Autoritativa:**

- Sistema: OrangeHRM OS 5.8
    
- Runtime: Docker containerizado
    
- Banco de Dados: PostgreSQL/MariaDB
    
- Função: Sistema HR corporativo (Single Source of Truth para dados de colaboradores)
    

**Motor de Governança:**

- Sistema: midPoint 4.10
    
- Runtime: Docker containerizado
    
- Função: Orquestrador central de identidades e provisionamento
    

**Sistema-Alvo:**

- Sistema: OpenLDAP
    
- Protocolo: LDAP v3
    
- Função: Diretório corporativo para autenticação e autorização
    

## Protocolo de Comunicação

**JDBC (Java Database Connectivity)**  
Conexão direta ao banco de dados do OrangeHRM utilizando conector DatabaseTable nativo do midPoint. Esta abordagem permite:

- Extração eficiente de dados através de queries SQL otimizadas
    
- Controle granular sobre atributos extraídos
    
- Flexibilidade para implementar lógica complexa de correlação
    
- Performance superior comparada a APIs REST em cenários de sincronização em massa
    

## Topologia de Rede

**Segmento Inicial:** 192.168.68.x (IPs dinâmicos)

- **IGA Server:** xxx.xxx.xxx.xxx (iga-gf-01)
    
- **HR Server:** xxx.xxx.xxx.xxx (orangehrm-gf-01 / rh-gf-01-local)
    
- **LDAP Server:** 192.168.68.x (openldap-gf-01)
    

**Nota:** A decisão de migrar para segmento dedicado (.70) com IPs estáticos será tomada durante o projeto, resultando na criação do PRJ007 para higiene de infraestrutura.

## Fluxo de Dados

OrangeHRM (DB)→JDBCmidPoint→SyncRepository→LDAPOpenLDAP\text{OrangeHRM (DB)} \xrightarrow{\text{JDBC}} \text{midPoint} \xrightarrow{\text{Sync}} \text{Repository} \xrightarrow{\text{LDAP}} \text{OpenLDAP}OrangeHRM (DB)JDBCmidPointSyncRepositoryLDAPOpenLDAP

1. midPoint executa query SQL via JDBC no banco OrangeHRM
    
2. Dados de colaboradores são importados para Repository do midPoint
    
3. Reações de sincronização disparam ações de provisionamento
    
4. Identidades são criadas/atualizadas no OpenLDAP conforme políticas
    

---

## Stakeholders e Marca

## Marca: Fiqueok

**Posicionamento:**  
Plataforma de aprendizado técnico e análise focada em governança de identidades e auditoria de sistemas.

**Missão:**  
Fornecer conhecimento prático e evidências documentadas para executivos de TI e profissionais de auditoria tomarem decisões estratégicas informadas sobre implementação de soluções IAM.

**Referência:** Estabelecido em 2025-12-28

## Público-Alvo

**Executivos de TI:**

- CIOs e CTOs avaliando soluções de governança de identidades
    
- Gerentes de Infraestrutura planejando arquiteturas integradas
    
- Arquitetos de Segurança desenhando controles de acesso
    

**Profissionais de Auditoria:**

- Auditores internos validando controles de IAM
    
- Consultores de compliance avaliando postura de governança
    
- Analistas de risco mapeando vulnerabilidades de identidade
    

**Referência:** Audiência definida em 2025-12-02

## Papel do Responsável

**Paulo Feitosa - IAM Specialist/Auditor**

Responsável por todas as fases técnicas do projeto, incluindo arquitetura, implementação, validação e documentação. Atuando com dupla perspectiva:

- **Especialista IAM:** Implementação técnica seguindo melhores práticas da indústria
    
- **Auditor:** Validação de controles de segurança e conformidade com frameworks
    

---

## Riscos Identificados

## R01 - Conflitos de Porta Docker

**Descrição:**  
Risco de colisão entre portas expostas pelos containers Docker e serviços do Host Windows (Hyper-V, IIS, SQL Server), resultando em falha de inicialização de serviços.

**Probabilidade:** Alta  
**Impacto:** Alto  
**Mitigação Planejada:**

- Mapeamento detalhado de portas em uso no host antes de deployment
    
- Configuração de portas customizadas no docker-compose.yml quando necessário
    
- Validação de disponibilidade de porta antes de iniciar containers
    
- Documentação de todas as portas utilizadas no laboratório
    

**Status:** Identificado no planejamento

---

## R02 - Integridade de Conexão JDBC

**Descrição:**  
Vulnerabilidade na conexão direta ao banco de dados podendo causar bloqueios (locks) em tabelas durante sincronizações, impactando performance do OrangeHRM ou causando timeouts no midPoint.

**Probabilidade:** Média  
**Impacto:** Alto  
**Mitigação Planejada:**

- Implementação de queries SQL otimizadas com SELECT específico de colunas
    
- Uso de índices apropriados nas tabelas consultadas
    
- Configuração de timeout adequado no conector JDBC
    
- Testes de carga para validar impacto de sincronizações
    
- Consideração de read replica se performance degradar
    

**Status:** Identificado no planejamento

---

## R03 - Persistência de Rede e Conectividade SSH

**Descrição:**  
Instabilidade na conectividade SSH devido ao compartilhamento de IPs com adaptador físico do Host, resultando em perda de sessões durante configuração e troubleshooting.

**Probabilidade:** Alta  
**Impacto:** Médio  
**Mitigação Planejada:**

- Configuração de IPs estáticos em VMs críticas
    
- Uso de Hyper-V Console como fallback para acesso às VMs
    
- Avaliação de migração para segmento de rede dedicado
    
- Implementação de keep-alive em sessões SSH
    

**Status:** Identificado no planejamento

**Nota:** Este risco levou à decisão de criar o PRJ007 para migração controlada para segmento .70 com IPs estáticos.

---

## R04 - Consistência de Dados entre Sistemas

**Descrição:**  
Risco de inconsistência entre dados no OrangeHRM e sistemas provisionados devido a falhas de sincronização, timeouts ou erros de mapeamento.

**Probabilidade:** Média  
**Impacto:** Alto  
**Mitigação Planejada:**

- Implementação de logging detalhado de todas as sincronizações
    
- Validação de integridade através de reconciliação periódica
    
- Alertas para falhas de sincronização
    
- Procedimento de correção de inconsistências documentado
    

**Status:** Identificado no planejamento

---

## R05 - Complexidade de Troubleshooting

**Descrição:**  
Dificuldade em diagnosticar problemas devido à complexidade da arquitetura multi-camadas (Docker, JDBC, SQL, midPoint, LDAP).

**Probabilidade:** Alta  
**Impacto:** Médio  
**Mitigação Planejada:**

- Implementação de logging estruturado em todos os componentes
    
- Criação de runbook de troubleshooting com cenários comuns
    
- Checkpoints frequentes para facilitar rollback
    
- Documentação de cada camada da arquitetura
    

**Status:** Identificado no planejamento

---

## Premissas e Restrições

## Premissas

- PRJ005 foi concluído com sucesso, entregando conectividade JDBC funcional
    
- Query SQL de extração de dados foi validada e está otimizada
    
- Usuário de serviço com privilégios mínimos está configurado no banco de dados
    
- Checkpoints de infraestrutura estão disponíveis para rollback
    
- Ambiente de laboratório possui recursos computacionais suficientes
    

## Restrições

- **Ambiente:** Operação restrita ao laboratório Greenfield, sem integração com sistemas produtivos
    
- **Segmento de Rede:** Inicialmente limitado ao 192.168.68.x com IPs dinâmicos
    
- **Recursos:** VMs rodando em Host único Windows com Hyper-V
    
- **Banco de Dados:** Acesso read-only via usuário de serviço (sem permissões de escrita)
    
- **Temporalidade:** Projeto deve ser concluído antes da migração de rede (PRJ007)
    

---

## Critérios de Sucesso

## Indicadores Técnicos (KPIs)

**Conectividade JDBC:**

- Meta: 99% de disponibilidade durante período de testes
    
- Medição: Logs de sincronização bem-sucedidas vs. falhas
    

**Taxa de Provisionamento:**

- Meta: 100% dos colaboradores no OrangeHRM provisionados no OpenLDAP
    
- Medição: Comparação de contagem de registros entre sistemas
    

**Integridade de Dados:**

- Meta: 100% de atributos mapeados corretamente
    
- Medição: Validação manual de amostra de colaboradores provisionados
    

**Performance de Sincronização:**

- Meta: Sincronização completa em menos de 2 minutos para 10 colaboradores
    
- Medição: Tempo de execução de task de importação
    

## Critérios Funcionais

- Resource object do OrangeHRM configurado e ativo no midPoint
    
- Sincronização automatizada executando sem erros
    
- Colaboradora piloto (Ana Silva) provisionada automaticamente no OpenLDAP
    
- Atributos organizacionais (cargo, departamento) corretamente mapeados
    
- Logs de auditoria registrando todas as operações de sincronização
    

## Critérios de Governança

- Documentação completa de configurações e procedimentos
    
- Controles de segurança validados (ISO 27001 A.9.4.4, A.13.1.1)
    
- Checkpoints de continuidade criados para todas as fases críticas
    
- Lições aprendidas documentadas para conhecimento organizacional
    

---

## Entregas Esperadas

## Documentação

- Documento de arquitetura técnica detalhando componentes e fluxos
    
- Procedimento operacional padrão (SOP) para sincronização
    
- Runbook de troubleshooting com cenários comuns
    
- Documento de lições aprendidas
    
- Relatório de encerramento com análise de KPIs
    

## Configurações Técnicas

- Resource object do OrangeHRM no midPoint
    
- Mapeamento completo de atributos
    
- Reações de sincronização configuradas
    
- Query SQL otimizada documentada
    
- Schedule de sincronização automatizada
    

## Evidências de Governança

- Screenshots de sincronizações bem-sucedidas
    
- Logs de auditoria preservados
    
- Validação de controles de segurança
    
- Checkpoints Hyper-V com configurações validadas
    

---

## Cronograma Estimado

## Fase 1 - Configuração de Resource Object

**Duração:** 2 dias  
**Atividades:**

- Importação de resource object no midPoint
    
- Configuração de conector JDBC
    
- Validação de conectividade
    

## Fase 2 - Mapeamento e Correlação

**Duração:** 2 dias  
**Atividades:**

- Configuração de mapeamento de atributos
    
- Implementação de correlação baseada em personalNumber
    
- Configuração de reações de sincronização
    

## Fase 3 - Testes e Validação

**Duração:** 2 dias  
**Atividades:**

- Execução de sincronização de teste
    
- Validação de provisionamento no OpenLDAP
    
- Testes de integridade de dados
    
- Ajustes de performance
    

## Fase 4 - Documentação e Encerramento

**Duração:** 1 dia  
**Atividades:**

- Elaboração de documentação técnica
    
- Criação de runbook de troubleshooting
    
- Análise de lições aprendidas
    
- Relatório de encerramento
    

**Duração Total Estimada:** 7 dias úteis

---

## Dependências

## Projetos Anteriores

- **PRJ004:** Conceitos de correlação e JML validados
    
- **PRJ005:** Conectividade JDBC e query SQL estabelecidas
    

## Infraestrutura

- VMs operacionais: iga-gf-01, orangehrm-gf-01, openldap-gf-01
    
- Conectividade de rede validada entre componentes
    
- Firewall configurado com regras apropriadas
    
- Checkpoints de continuidade disponíveis
    

## Dados

- OrangeHRM populado com colaboradores de teste
    
- Usuário de serviço configurado no banco de dados
    
- Query SQL de extração validada
    

---

## Transição para PRJ007

Este projeto está historicamente marcado como **Encerrado (Migrado para PRJ007)** devido à decisão estratégica de implementar higiene de infraestrutura antes de completar a integração lógica.

Durante a execução do PRJ006, identificou-se que os riscos de rede (R03) e conflitos de porta (R01) justificavam uma **pausa técnica** para reestruturação do ambiente antes de prosseguir com configurações complexas.

A decisão de migrar para segmento .70 com IPs estáticos foi tomada para:

- Eliminar instabilidade de rede que poderia comprometer testes
    
- Isolar completamente o ambiente de laboratório
    
- Estabelecer fundação sólida para integração definitiva
    
- Prevenir retrabalho futuro devido a problemas de infraestrutura
    

**O conhecimento e configurações do PRJ006 foram preservados e transferidos para o PRJ007**, que executou a migração de rede e posteriormente completou a integração dinâmica OrangeHRM em ambiente estável.

---

## Aprovações e Autorização

- **Abertura Formal:** Janeiro/2026
    
- **Responsável:** Paulo Feitosa
    
- **Status:** Projeto formalmente iniciado
    
- **Migração:** Encerrado e migrado para PRJ007 conforme decisão técnica estratégica
    

Este documento marca a abertura oficial do PRJ006, estabelecendo os objetivos, escopo e critérios de sucesso para a primeira integração dinâmica do Living Lab Fiqueok.

---

_Nota Histórica: Este projeto demonstrou a maturidade do laboratório em reconhecer quando pausar para consolidar fundações, priorizando qualidade de entrega sobre velocidade de execução._
