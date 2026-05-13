# 

**PRJ005 - Integração de Fonte Autoritativa (OrangeHRM)**

## Informações do Projeto

- **ID do Projeto:** PRJ005
    
- **Nome:** OrangeHRM Integration - HR-Driven Provisioning
    
- **Status:** Concluído com Sucesso Operacional
    
- **Data de Início:** 02/02/2026
    
- **Data de Encerramento:** 03/02/2026
    
- **Duração:** 2 dias
    
- **Responsável:** Paulo Feitosa (IAM Specialist/Auditor)
    
- **Contexto:** Living Lab Fiqueok (Greenfield)
    

---

## Sumário Executivo

O PRJ005 foi concluído com **sucesso operacional**, estabelecendo a fundação completa de conectividade e segurança para integração entre o midPoint e o OrangeHRM. O projeto superou desafios técnicos significativos relacionados a configuração de infraestrutura, segurança de rede e gestão de credenciais, resultando em um **duto de dados funcional e protegido** entre os sistemas IGA e HR.

A fase de infraestrutura e conectividade foi completada com todos os controles de segurança implementados, validados através de checkpoints de continuidade operacional, e documentada para replicação futura. O Living Lab Fiqueok agora possui uma solução de IGA funcional pronta para automação de ciclo de vida de identidades baseada em eventos de RH.

---

## Objetivos Alcançados

## Objetivo Principal ✅

Estabelecer conectividade segura e confiável entre midPoint (IGA) e OrangeHRM (HR), permitindo extração automatizada de dados autoritativos de colaboradores.

## Objetivos Específicos ✅

- Configurar comunicação JDBC entre midPoint (.116) e MariaDB (.107)
    
- Implementar controles de segurança de rede e firewall
    
- Criar usuário de serviço com privilégios mínimos
    
- Desenvolver query SQL otimizada para extração de dados
    
- Garantir continuidade operacional através de checkpoints
    
- Documentar todas as configurações e procedimentos
    

---

## Ações Executadas (Log de Atividades)

## Configuração de Rede e Firewall

**Atividade:** Estabelecimento de conectividade TCP segura  
**Data:** 02/02/2026  
**Detalhes:**

- Validada conectividade entre IGA (xxx.xxx.xxx.xxx) e RH (xxx.xxx.xxx.xxx) na porta 3306
    
- Teste de handshake TCP executado com sucesso via `nc -zv xxx.xxx.xxx.xxx 3306`
    
- Configurado Firewall UFW no host RH para restringir acesso exclusivamente ao servidor IGA
    
- Regra implementada: `ufw allow from xxx.xxx.xxx.xxx to any port 3306`
    
- Política default deny mantida para demais origens
    

**Resultado:** Conectividade funcional com perímetro de segurança estabelecido

## Ajuste de Infraestrutura Docker

**Atividade:** Correção de configuração do MariaDB  
**Data:** 02/02/2026  
**Detalhes:**

- Identificada ausência de mapeamento de portas no `docker-compose.yml` do MariaDB
    
- Diagnosticado erro de sintaxe YAML (indentação incorreta) na linha 14
    
- Corrigida estrutura do arquivo mantendo princípio de exposição mínima
    
- Validada sintaxe através de parser YAML antes de aplicação
    
- Serviço reiniciado com sucesso após correção
    

**Resultado:** MariaDB acessível via porta 3306 com configuração validada

## Gestão de Identidades e Acessos (IAM/DB)

**Atividade:** Criação de usuário de serviço e query de integração  
**Data:** 02/02/2026 - 03/02/2026  
**Detalhes:**

**Usuário de Serviço:**

- Criado usuário `midpoint_user` no MariaDB seguindo princípio de privilégio mínimo
    
- Permissões concedidas: `SELECT` apenas nas tabelas necessárias
    
- Escopo restrito ao database `greenfield_hr`
    
- Origem de conexão limitada a xxx.xxx.xxx.xxx
    
- Alinhamento com controle ISO 27001 A.9.4.4 (Privilégios Mínimos)
    

**Query de Integração:**

sql

`SELECT      e.emp_number,    e.employee_id,    e.emp_firstname,    e.emp_lastname,    e.emp_work_email,    jt.job_title_name,    su.name as subunit_name FROM hs_hr_employee e LEFT JOIN ohrm_job_title jt ON e.job_title_code = jt.id LEFT JOIN ohrm_subunit su ON e.work_station = su.id`

- Desenvolvida query SQL com `LEFT JOIN` para conversão de IDs numéricos em descrições legíveis
    
- Validada extração de atributos críticos: cargo (job_title_name) e departamento (subunit_name)
    
- Testada integridade de dados com colaboradora piloto
    

**Resultado:** Usuário de serviço funcional com query otimizada para extração de dados

## Salvaguarda de Continuidade Operacional

**Atividade:** Criação de checkpoints Hyper-V  
**Data:** 02/02/2026 - 03/02/2026  
**Detalhes:**

Executados checkpoints nas seguintes VMs para garantir reversibilidade:

- `iga-gf-01`: Checkpoint `PRJ005_Infra_Ready_Check` (pós-validação de rede)
    
- `iga-gf-01`: Checkpoint `PRJ005_Pre_Logic_Config` (pré-configuração lógica)
    
- `rh-gf-01-local`: Checkpoint `PRJ005_DB_Config_Complete` (pós-configuração de banco)
    

**Resultado:** Capacidade de rollback em menos de 5 minutos para qualquer fase do projeto

## Validação de Segurança

**Atividade:** Auditoria de configurações de segurança  
**Data:** 03/02/2026  
**Detalhes:**

- Verificada ausência de exposição desnecessária de portas
    
- Validada política de firewall com teste de conectividade de origem não autorizada
    
- Confirmada criptografia de senha de usuário de serviço no MariaDB
    
- Auditados logs de acesso ao banco de dados
    

**Resultado:** Postura de segurança alinhada com ISO 27001 A.13.1.1 (Segregação de Redes)

---

## Lições Aprendidas (Análise Pós-Incidente)

## L01 - Gestão de Ativos e Inventário

**Categoria:** Operacional  
**Severidade:** Média

**Descrição da Falha:**  
Inconsistência entre o hostname do sistema operacional e o nome da VM no Hyper-V dificultou a execução de scripts de automação e criação de checkpoints. A VM estava registrada como `rh-gf-01-local` no Hyper-V mas o hostname do SO era diferente, causando confusão durante operações de manutenção.

**Impacto:**  
Atraso de aproximadamente 30 minutos na criação de checkpoints e necessidade de validação manual de inventário de ativos.

**Ação Corretiva Implementada:**  
Padronização de nomenclatura entre camada de virtualização (Hyper-V) e sistema operacional. Criação de inventário de ativos documentando:

- Nome da VM no Hyper-V
    
- Hostname do SO
    
- Endereço IP
    
- Função no laboratório
    

**Aprendizado:**  
Manter um **inventário de ativos padronizado** entre a camada de virtualização e a camada de rede é fundamental para operações eficientes. A inconsistência entre diferentes camadas tecnológicas gera fricção operacional desnecessária.

**Aplicação Futura:**  
Implementar script de validação que compara naming conventions entre Hyper-V, DNS e hostname antes de qualquer deployment.

---

## L02 - Gestão de Credenciais e PAM

**Categoria:** Segurança  
**Severidade:** Alta

**Descrição da Falha:**  
Dificuldade na recuperação de credenciais administrativas personalizadas (`M1dP0!ntAdm!n#2026`) devido à ausência de um cofre de senhas centralizado. A dependência de memória humana ou registros esparsos em documentação resultou em tentativas de login com credenciais incorretas.

**Impacto:**  
Risco de lockout de conta administrativa e necessidade de procedimento de recuperação de senha. Perda de tempo em tentativas de autenticação malsucedidas.

**Ação Corretiva Implementada:**  
Documentação imediata de todas as credenciais em vault seguro. Estabelecimento de política de gestão de segredos para o laboratório.

**Aprendizado:**  
A **adoção de um gerenciador de segredos ou cofre PAM** é crítica para mitigar a dependência de memória humana. Mesmo em ambientes de laboratório, a gestão adequada de credenciais previne interrupções operacionais e riscos de segurança.

**Aplicação Futura:**  
Implementar solução de PAM (Privileged Access Management) ou minimamente um password manager criptografado para todos os ativos do laboratório. Considerar integração com KeePass ou HashiCorp Vault.

---

## L03 - Infraestrutura como Código (IaC)

**Categoria:** Técnica  
**Severidade:** Alta

**Descrição da Falha:**  
Interrupção do serviço MariaDB devido a erro de indentação no arquivo `docker-compose.yml` (linha 14). O erro de sintaxe YAML impediu a inicialização correta do container, resultando em falha de conectividade.

**Impacto:**  
Downtime completo do serviço de banco de dados até identificação e correção do erro. Necessidade de troubleshooting manual para localizar problema de sintaxe.

**Ação Corretiva Implementada:**  
Validação de sintaxe YAML através de linter antes de aplicação de mudanças. Implementação de checklist de validação para alterações em arquivos de infraestrutura.

**Aprendizado:**  
**Implementação de validação (Linting) antes da aplicação de mudanças** em arquivos de infraestrutura como código é fundamental. Erros de sintaxe em YAML podem passar despercebidos visualmente mas causam falhas críticas em runtime.

**Aplicação Futura:**  
Integrar yamllint ou validadores equivalentes no workflow de mudanças de infraestrutura. Considerar uso de pre-commit hooks para validação automática antes de deployment.

---

## L04 - IA e Validação de Contexto

**Categoria:** Operacional/Segurança  
**Severidade:** Média

**Descrição da Falha:**  
Durante troubleshooting de credenciais, sistema de IA tentou recuperar informações do histórico mas falhou em localizar a senha específica, sugerindo credenciais padrão potencialmente incorretas.

**Impacto:**  
Risco de tentativas de autenticação com credenciais incorretas. Necessidade de validação manual contra fonte de verdade (documentação própria).

**Ação Corretiva Implementada:**  
Estabelecimento de protocolo de validação onde informações críticas fornecidas por sistemas automatizados devem ser confirmadas contra fonte autoritativa.

**Aprendizado:**  
O **Auditor deve manter vigilância constante sobre informações fornecidas por sistemas automatizados**, priorizando a verdade dos registros próprios. IA é ferramenta de auxílio, não substituto de verificação rigorosa.

**Aplicação Futura:**  
Implementar processo de double-check para informações críticas (credenciais, configurações de segurança) onde sugestões automatizadas são validadas contra documentação oficial antes de aplicação.

---

## L05 - Query Design e Integridade de Dados

**Categoria:** Técnica  
**Severidade:** Baixa

**Descrição da Lição:**  
A necessidade de usar `LEFT JOIN` ao invés de `INNER JOIN` foi identificada para garantir que colaboradores sem cargo ou departamento ainda fossem extraídos. Esta decisão de design preveniu perda de dados.

**Impacto:**  
Positivo - Prevenção de exclusão acidental de colaboradores por ausência de relacionamentos.

**Aprendizado:**  
Queries de integração devem priorizar **inclusividade de dados** utilizando `LEFT JOIN` quando apropriado. A ausência de atributo secundário (cargo, departamento) não deve impedir a importação da identidade principal.

**Aplicação Futura:**  
Estabelecer como padrão o uso de `LEFT JOIN` para atributos opcionais e `INNER JOIN` apenas quando relacionamento é obrigatório para integridade de negócio.

---

## Indicadores de Sucesso (KPIs)

## Conectividade de Rede

**Meta:** 100% de disponibilidade  
**Resultado:** ✅ **100%**  
Conectividade TCP validada via teste `nc -zv` com sucesso consistente durante todo o período de testes.

## Segurança de Perímetro

**Meta:** Zero exposições desnecessárias  
**Resultado:** ✅ **Alcançado**  
Firewall UFW configurado com regras restritivas. Auditoria confirmou que apenas tráfego autorizado do IGA pode acessar porta 3306.

## Resiliência Operacional

**Meta:** Capacidade de rollback < 5 minutos  
**Resultado:** ✅ **3 minutos (média)**  
Checkpoints validados com restauração bem-sucedida em tempo médio de 3 minutos.

## Integridade de Dados

**Meta:** 100% de atributos mapeados corretamente  
**Resultado:** ✅ **100%**  
Query SQL validada retornando todos os atributos esperados com tipos de dados corretos e valores legíveis.

## Privilégios Mínimos

**Meta:** Usuário de serviço com apenas permissões necessárias  
**Resultado:** ✅ **Alcançado**  
Usuário `midpoint_user` criado com `SELECT` apenas, sem permissões de escrita ou administração.

---

## Riscos e Incidentes

## Incidentes Ocorridos

**I01 - Falha de Sintaxe YAML**

- **Severidade:** Alta
    
- **Duração:** 45 minutos
    
- **Resolução:** Correção de indentação e validação via linter
    
- **Prevenção Futura:** Implementação de validação automática pré-deployment
    

**I02 - Inconsistência de Naming**

- **Severidade:** Média
    
- **Duração:** 30 minutos
    
- **Resolução:** Documentação de inventário de ativos
    
- **Prevenção Futura:** Padronização de nomenclatura entre camadas
    

## Riscos Mitigados

Todos os riscos identificados no documento de abertura foram adequadamente mitigados através das ações executadas.

---

## Entregas Realizadas

## Documentação Técnica ✅

- Inventário de ativos com mapeamento de VMs, hostnames e IPs
    
- Procedimento de configuração de usuário de serviço MariaDB
    
- Query SQL de integração documentada e comentada
    
- Guia de troubleshooting para erros comuns de conectividade
    

## Configurações de Infraestrutura ✅

- Firewall UFW configurado e auditado
    
- Docker Compose do MariaDB corrigido e validado
    
- Usuário de serviço `midpoint_user` criado com privilégios mínimos
    
- Conectividade JDBC testada e aprovada
    

## Salvaguardas Operacionais ✅

- 3 checkpoints críticos criados no Hyper-V
    
- Procedimento de rollback documentado e testado
    
- Logs de auditoria preservados para análise futura
    

---

## Visão GRC: Compliance Posture

O PRJ005 encerra a fase de infraestrutura **atendendo rigorosamente aos controles de segurança** estabelecidos pela ISO 27001:

## A.13.1.1 - Segregação de Redes ✅

Implementação de firewall com políticas restritivas garantindo que apenas tráfego autorizado do servidor IGA possa acessar o banco de dados RH. Segregação lógica entre ambientes estabelecida.

## A.9.4.4 - Privilégios Mínimos ✅

Usuário de serviço criado com permissões exclusivamente necessárias para operação (`SELECT`). Nenhum privilégio administrativo ou de escrita concedido, alinhado com princípio de least privilege.

## A.12.3.1 - Backup de Informações ✅

Checkpoints de continuidade operacional criados antes de todas as mudanças críticas, garantindo capacidade de restauração em caso de falha.

**Postura de Compliance:** **Aprovada** para progressão para fase de configuração lógica.

---

## Visão CEO: Maturidade em IAM

> "Paulo, o PRJ005 provou que a Fiqueok não apenas configura ferramentas, mas **gerencia crises e aprende com elas**. O duto está aberto e protegido. Agora, o laboratório deixa de ser um conjunto de VMs e passa a ser uma **solução de IGA funcional**."

## Maturidade Demonstrada

**Nível Atual:** **Gerenciado e Mensurável**

O projeto demonstrou evolução significativa na maturidade de IAM do laboratório:

- **Resiliência:** Capacidade de recuperação rápida de incidentes através de checkpoints
    
- **Segurança:** Implementação proativa de controles antes de funcionalidades
    
- **Documentação:** Registro completo de lições aprendidas para conhecimento organizacional
    
- **Governança:** Alinhamento com frameworks reconhecidos (ISO 27001)
    

## Valor Entregue

- **Duto de Dados:** Infraestrutura de integração funcional entre sistemas críticos
    
- **Base de Conhecimento:** Documentação detalhada permitindo replicação e troubleshooting
    
- **Postura de Segurança:** Controles implementados seguindo melhores práticas da indústria
    
- **Escalabilidade:** Fundação que suporta expansão para novos sistemas-alvo
    

---

## Transição e Próximos Passos

## Handoff para PRJ006

O PRJ005 entrega ao PRJ006 uma **base sólida e segura** para implementação de lógica de provisionamento:

- Conectividade JDBC validada e funcional
    
- Query SQL otimizada pronta para uso
    
- Usuário de serviço configurado
    
- Controles de segurança implementados
    

## Ações Pendentes (Out of Scope)

As seguintes atividades foram identificadas como fora do escopo do PRJ005 e serão endereçadas em projetos futuros:

- **Configuração de Resource Object no midPoint:** PRJ006
    
- **Mapeamento de Atributos e Correlação:** PRJ006
    
- **Provisionamento para OpenLDAP:** PRJ006
    
- **Processos Mover e Leaver:** Planejamento futuro
    
- **Implementação de PAM:** Projeto independente de segurança
    

---

## Recomendações para Projetos Futuros

## Curto Prazo (PRJ006)

- Implementar resource object do OrangeHRM no midPoint utilizando query validada
    
- Configurar mapeamento de atributos com foco em integridade
    
- Testar provisionamento completo com colaboradora piloto (Ana Silva)
    

## Médio Prazo (PRJ007+)

- Implementar solução de PAM para gestão centralizada de credenciais
    
- Estabelecer pipeline de validação automática para arquivos IaC
    
- Desenvolver runbook de troubleshooting baseado em lições aprendidas
    

## Longo Prazo (Laboratório)

- Migrar para segmento de rede dedicado (.70) conforme planejado em PRJ007
    
- Implementar monitoramento proativo de conectividade JDBC
    
- Estabelecer procedimento de disaster recovery com testes periódicos
    

---

## Aprovações e Encerramento Formal

- **Encerramento Técnico:** 03/02/2026
    
- **Responsável:** Paulo Feitosa
    
- **Status Final:** ✅ **Concluído com Sucesso Operacional**
    
- **Documentação Arquivada:** Living Lab Fiqueok Knowledge Base (Obsidian)
    
- **Checkpoints Preservados:** Hyper-V (iga-gf-01, rh-gf-01-local)
    

---

## Conclusão

O PRJ005 representa um **marco significativo** na jornada de maturidade IAM do Living Lab Fiqueok. Apesar dos desafios técnicos encontrados, o projeto não apenas entregou a infraestrutura planejada, mas também **estabeleceu processos de governança** que elevarão a qualidade de todos os projetos subsequentes.

As lições aprendidas em gestão de credenciais, validação de IaC e padronização de ativos transcendem este projeto específico, **transformando-se em conhecimento organizacional** que fortalecerá a operação do laboratório como um todo.

**O duto está aberto. O laboratório está pronto para IGA em produção.**

---

_Este documento encerra formalmente o PRJ005 e autoriza o início do PRJ006 - Configuração Lógica e Provisionamento._
