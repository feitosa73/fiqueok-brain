# 

**PRJ005 - Integração de Fonte Autoritativa (OrangeHRM)**

## Informações do Projeto

- **ID do Projeto:** PRJ005
    
- **Nome:** OrangeHRM Integration - HR-Driven Provisioning
    
- **Status:** Iniciado
    
- **Data de Início:** 02/02/2026
    
- **Responsável:** Paulo Feitosa (IAM Specialist/Auditor)
    
- **Contexto:** Living Lab Fiqueok (Greenfield)
    
- **Plataformas:** midPoint 4.10, OrangeHRM 5.x, MariaDB 10.x
    

---

## Sumário Executivo

O PRJ005 representa a evolução natural do Living Lab Fiqueok, transitando de uma fonte autoritativa estática (CSV) para um sistema corporativo de gestão de recursos humanos. Este projeto estabelece o **OrangeHRM como fonte autoritativa** de identidades, implementando o conceito de HR-Driven Provisioning onde mudanças organizacionais disparam automaticamente ações no ecossistema de identidades.

A integração utiliza conector JDBC nativo do midPoint para comunicação direta com o banco de dados MariaDB do OrangeHRM, permitindo automação completa do ciclo de vida de identidades baseada em eventos de RH.

---

## Objetivos do Projeto

## Objetivo Principal

Estabelecer o OrangeHRM como fonte autoritativa única (Single Source of Truth) para dados de colaboradores, substituindo o modelo manual baseado em CSV do PRJ004.

## Objetivos Específicos

- Integrar o midPoint ao banco de dados MariaDB do OrangeHRM via conector JDBC
    
- Automatizar o ciclo de vida de identidades com foco no processo Joiner
    
- Implementar modelo RBAC (Role-Based Access Control) baseado em cargos organizacionais
    
- Garantir integridade e segurança na extração de dados autoritativos
    
- Estabelecer baseline de governança para futuras integrações de sistemas
    

---

## Contexto e Justificativa

## Evolução do PRJ004

O PRJ004 validou com sucesso o ciclo JML utilizando arquivo CSV, mas apresentou limitações inerentes ao modelo estático:

- Necessidade de sincronizações manuais para refletir mudanças
    
- Ausência de rastreabilidade de alterações organizacionais
    
- Escalabilidade limitada para cenários corporativos reais
    

## Necessidade de Integração HR

A integração com sistema HR corporativo elimina essas limitações, proporcionando:

- Sincronização automática de mudanças organizacionais
    
- Rastreabilidade completa através de logs transacionais do banco de dados
    
- Atributos enriquecidos (job titles, departamentos, hierarquias)
    
- Alinhamento com melhores práticas de IGA corporativo
    

---

## Escopo do Projeto

## Dentro do Escopo

- Configuração de conectividade segura entre midPoint (.116) e OrangeHRM (.107)
    
- Implementação de usuário de serviço com privilégios mínimos no MariaDB
    
- Desenvolvimento de query SQL otimizada para extração de dados autoritativos
    
- Configuração de resource object no midPoint para OrangeHRM
    
- Mapeamento de atributos críticos (personalNumber, name, jobTitle, department)
    
- Validação do processo Joiner através de colaboradora de teste (Ana Silva)
    
- Documentação completa de configurações e procedimentos
    

## Fora do Escopo

- Processos Mover e Leaver (planejados para fases futuras)
    
- Provisionamento reverso (OrangeHRM não receberá dados do midPoint)
    
- Integração com sistemas adicionais além do OpenLDAP (planejado para PRJ006)
    
- Customização da interface do OrangeHRM
    

---

## Arquitetura da Solução

## Componentes Técnicos

**Ambiente IGA:**

- VM: `iga-gf-01`
    
- IP: xxx.xxx.xxx.xxx
    
- OS: Ubuntu 24.04 LTS
    
- Runtime: Docker
    
- Aplicação: midPoint 4.10
    

**Ambiente RH:**

- VM: `orangehrm-gf-01`
    
- IP: xxx.xxx.xxx.xxx
    
- OS: Ubuntu 24.04 LTS
    
- Runtime: Docker
    
- Aplicação: OrangeHRM 5.x
    
- Banco de Dados: MariaDB 10.x
    

## Fluxo de Integração

OrangeHRM (MariaDB)→JDBC:3306midPoint→LDAP:389OpenLDAP\text{OrangeHRM (MariaDB)} \xrightarrow{\text{JDBC:3306}} \text{midPoint} \xrightarrow{\text{LDAP:389}} \text{OpenLDAP}OrangeHRM (MariaDB)JDBC:3306midPointLDAP:389OpenLDAP

O midPoint atua como orquestrador central, extraindo dados do OrangeHRM e provisionando identidades nos sistemas-alvo conforme políticas de governança.

---

## Retrospectiva de Infraestrutura (Checkpoints)

Antes do início da fase lógica de configuração, as seguintes camadas foram validadas e protegidas:

## Conectividade de Rede

**Status:** Validado  
Handshake TCP estabelecido com sucesso na porta 3306 entre servidor IGA (.116) e servidor RH (.107), confirmado através de teste com `nc -zv`.

## Segurança de Rede

**Status:** Endurecido  
Firewall UFW configurado no servidor RH para permitir exclusivamente tráfego autorizado do servidor IGA, seguindo princípio de defesa em profundidade.

Regras implementadas:

- Allow from xxx.xxx.xxx.xxx to any port 3306
    
- Default deny para demais origens
    

## Docker Hardening

**Status:** Ajustado  
Configuração do `docker-compose.yml` revisada para garantir que o MariaDB não esteja exposto desnecessariamente à rede local. Portas publicadas apenas quando estritamente necessário para operações de manutenção.

## Continuidade Operacional

**Status:** Protegido  
Pontos de verificação criados no Hyper-V para garantir capacidade de rollback:

- `PRJ005_Infra_Ready_Check` - Checkpoint pós-validação de rede e firewall
    
- `PRJ005_Pre_Logic_Config` - Checkpoint antes de configurações lógicas no IGA
    

---

## Segurança e Governança

## Usuário de Serviço

Implementação do usuário `midpoint_user` no MariaDB seguindo o **princípio do privilégio mínimo** (ISO 27001 - A.9.4.4):

- Permissões: SELECT apenas nas tabelas necessárias
    
- Escopo: Acesso restrito ao database `greenfield_hr`
    
- Origem: Conexões permitidas apenas de xxx.xxx.xxx.xxx
    

## Gestão de Credenciais

Senha complexa definida para usuário administrativo do midPoint seguindo política de complexidade:

- Formato: `M1dP0!ntAdm!n#2026`
    
- Critérios: Maiúsculas, minúsculas, números, caracteres especiais
    
- Armazenamento: Documentado em vault seguro do laboratório
    

## Query de Ouro (Baseline de Governança)

Desenvolvimento de query SQL otimizada com JOIN entre tabelas para garantir extração de atributos legíveis e relevantes para o negócio, evitando importação de IDs numéricos sem contexto:

sql

`SELECT      e.emp_number,    e.employee_id,    e.emp_firstname,    e.emp_lastname,    e.emp_work_email,    jt.job_title_name,    su.name as subunit_name FROM hs_hr_employee e LEFT JOIN ohrm_job_title jt ON e.job_title_code = jt.id LEFT JOIN ohrm_subunit su ON e.work_station = su.id`

---

## Riscos Identificados e Mitigações

## R01 - Integridade de Dados

**Descrição:** Mapeamento incorreto de atributos provenientes do SQL pode resultar em provisionamento de identidades com dados inconsistentes.

**Probabilidade:** Média  
**Impacto:** Alto  
**Mitigação:** Implementação de Query de JOIN validada para extração de atributos em formato legível. Testes com colaboradora piloto (Ana Silva) antes de sincronização em massa.  
**Status:** Resolvido

## R02 - Exposição de Credenciais

**Descrição:** Exposição desnecessária de credenciais administrativas pode comprometer a segurança do ambiente.

**Probabilidade:** Baixa  
**Impacto:** Crítico  
**Mitigação:** Uso de senha complexa com rotação planejada. Credenciais documentadas apenas em vault seguro. Implementação de usuário de serviço com privilégios mínimos.  
**Status:** Mitigado

## R03 - Disponibilidade do Serviço

**Descrição:** Falhas na conectividade JDBC podem interromper sincronizações automatizadas.

**Probabilidade:** Baixa  
**Impacto:** Médio  
**Mitigação:** Checkpoints de continuidade criados no Hyper-V permitindo rollback rápido. Monitoramento de conectividade de rede validado.  
**Status:** Controlado

---

## Entregas Esperadas

## Fase 1 - Infraestrutura e Conectividade (Concluída)

- Conectividade JDBC funcional entre IGA e RH
    
- Usuário de serviço configurado com privilégios mínimos
    
- Query de extração de dados validada
    
- Checkpoints de continuidade operacional criados
    

## Fase 2 - Configuração Lógica (Em Andamento)

- Resource object do OrangeHRM importado no midPoint
    
- Mapeamento de atributos configurado
    
- Correlação baseada em personalNumber estabelecida
    
- Reações de sincronização para processo Joiner definidas
    

## Fase 3 - Validação e Testes

- Execução de ciclo de Discovery para localização de colaboradores
    
- Provisionamento de colaboradora piloto (Ana Silva)
    
- Validação de integridade de dados provisionados
    
- Documentação de procedimentos operacionais
    

---

## Critérios de Sucesso

## Indicadores Técnicos (KPIs)

- **Conectividade:** 100% de disponibilidade da conexão JDBC durante testes
    
- **Integridade:** 100% dos atributos mapeados corretamente da query SQL
    
- **Resiliência:** Checkpoints críticos validados para rollback em menos de 5 minutos
    
- **Segurança:** Zero exposições desnecessárias de portas ou credenciais
    

## Critérios Funcionais

- Colaboradora Ana Silva provisionada automaticamente no OpenLDAP
    
- Atributos de cargo (jobTitle) e departamento (subunit) corretamente mapeados
    
- Log de auditoria registrando todas as operações de sincronização
    
- Documentação completa permitindo replicação do procedimento
    

---

## Cronograma Estimado

- **Fase 1 - Infraestrutura:** 02/02/2026 - 02/02/2026 (Concluída)
    
- **Fase 2 - Configuração Lógica:** 03/02/2026 - 04/02/2026 (Em Andamento)
    
- **Fase 3 - Validação e Testes:** 05/02/2026 - 06/02/2026 (Planejada)
    
- **Encerramento e Documentação:** 07/02/2026 (Planejada)
    

---

## Stakeholders e Comunicação

## Responsável Técnico

Paulo Feitosa - IAM Specialist/Auditor responsável por todas as fases técnicas e documentação de governança.

## Canais de Documentação

- **Knowledge Base:** Obsidian (Living Lab Fiqueok)
    
- **Versionamento:** Checkpoints Hyper-V para configurações críticas
    
- **Evidências:** Screenshots e logs preservados para auditoria
    

---

## Referências e Dependências

## Dependências de Projetos Anteriores

- **PRJ004:** Fundações de governança e mecanismos de correlação reutilizados
    
- **Infraestrutura Base:** VMs provisionadas e rede estabilizada
    

## Próximos Passos (PRJ006/007)

Após conclusão bem-sucedida do PRJ005, os seguintes projetos estão planejados:

- **PRJ006:** Configuração avançada de provisionamento e RBAC
    
- **PRJ007:** Higiene de IP e reestruturação de rede (Segmento .70)
    

---

## Aprovações e Autorização

- **Abertura Formal:** 02/02/2026
    
- **Responsável:** Paulo Feitosa
    
- **Status:** Projeto formalmente iniciado com infraestrutura validada
    

Este documento marca a abertura oficial do PRJ005, estabelecendo fundações sólidas para a primeira integração corporativa do Living Lab Fiqueok.
