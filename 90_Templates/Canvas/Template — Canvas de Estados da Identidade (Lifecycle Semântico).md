
---
**Documento:** TEMPLATE-CANVAS-IDENTITY-LIFECYCLE  
**Título:** Template — Canvas de Estados da Identidade (Lifecycle Semântico)  
**Tipo:** Template Reutilizável — Canvas de Decisão IAM  
**Categoria:** Estados e Ciclo de Vida da Identidade  
**Versão:** 2.0  
**Data:** 14/01/2026  
**Aplicabilidade:** Universal — Projetos IAM/IGA/Identity Governance  
**Independente de:** Ferramenta, vendor, plataforma, organização  

---

## Propósito do Template

Este template define a estrutura para documentar **estados semânticos de identidade** em qualquer projeto IAM/IGA.

**Características:**
- Reutilizável em múltiplos contextos (corporativo, lab, consultoria, POC)
- Agnóstico de ferramenta (midPoint, SailPoint, Okta, Entra ID, AD, etc.)
- Independente de vendor e tecnologia
- Separa **estados semânticos** (identidade) de **estados técnicos** (contas)
- Previne ambiguidades em fluxos JML (Joiner/Mover/Leaver)

**Princípio Fundamental:**  
Estados de identidade pertencem ao domínio de negócio, não ao domínio técnico. Decisões sobre lifecycle devem ser semânticas e explícitas antes de qualquer automação.

---

## 1. Identificação do Canvas

**Projeto:**  
_(Nome do projeto ou iniciativa IAM/IGA)_

**Código do Canvas:**  
_(Padrão sugerido: CAN-ID-LC-XXX ou CAN-ID-003)_

**Versão:**  
_(Formato: X.Y — major.minor)_

**Status:**  
- [ ] Rascunho  
- [ ] Em Consolidação  
- [ ] Revisado  
- [ ] Ativo  
- [ ] Arquivado  

**Origem da Decisão:**  
_(Indicar gatilho: GMUD específica, ADR, iniciativa estratégica, auditoria, requisito de compliance, etc.)_

**Data de Criação:**  
_(dd/mm/aaaa)_

**Última Revisão:**  
_(dd/mm/aaaa)_

**Owner / Responsável:**  
_(Nome e área do responsável pelo canvas)_

---

## 2. Objetivo do Canvas

Este canvas define os **estados canônicos da identidade** adotados neste projeto, descrevendo:

- **Quais estados existem** no modelo de identidade da organização
- **O significado semântico** de cada estado (o que representa do ponto de vista de negócio)
- **Os limites conceituais** entre identidade (domínio de negócio) e contas técnicas (domínio de TI)
- **Como estados se relacionam** com elegibilidade para acessos e provisionamento

### Este Canvas Atua Como Gate Obrigatório Antes De:

- [ ] Definição de fluxos JML (Joiner/Mover/Leaver)  
- [ ] Automação de lifecycle de identidades  
- [ ] Correlação entre identidade canônica e contas técnicas  
- [ ] Decisões de desativação, suspensão ou exceções  
- [ ] Implementação de políticas de provisionamento/deprovisionamento  
- [ ] Configuração de regras de sincronização de estados  

---

## 3. Contexto do Projeto

### Cenário Arquitetural

- [ ] **Greenfield** — nova infraestrutura, sem histórico de estados legados  
- [ ] **Brownfield** — integração com sistemas que já possuem conceitos de estado próprios  
- [ ] **Híbrido** — mistura de novos sistemas e legado com conceitos conflitantes  

### Problemas Históricos com Estados (Se Houver)

_(Descrever problemas concretos observados ou herdados)_

**Exemplos:**
- Confusão entre "usuário desabilitado no AD" e "colaborador afastado"
- Estados técnicos (bloqueio de senha) sendo tratados como estados de identidade
- Ausência de estado "suspenso" causando deprovisionamento prematuro
- Reativação de identidade gerando contas duplicadas
- Estados ambíguos em processos de offboarding

### Riscos de Confusão entre Estados Técnicos e Semânticos

_(Por que é crítico separar esses conceitos?)_

**Exemplos:**
- Bloqueio técnico por falha de autenticação não significa término de vínculo
- Conta desabilitada em um sistema não reflete status organizacional
- Estados de sistemas legados não são consistentes entre si
- Automações podem interpretar flags técnicos como eventos de negócio

### Motivações para Definição Explícita de Estados

_(Por que este projeto precisa formalizar estados de identidade?)_

**Exemplos:**
- Requisitos de compliance (LGPD, GDPR, SOX) exigem rastreabilidade de lifecycle
- Auditoria identificou inconsistências entre sistemas
- Processos de offboarding estão demorando muito por falta de clareza
- Necessidade de suportar cenários complexos (licenças, afastamentos, terceirizados)

---

## 4. Princípios dos Estados da Identidade

Definir os **princípios arquiteturais** adotados neste projeto.

### Princípios Recomendados (Adaptar Conforme Necessário)

- [ ] **Estados pertencem à identidade, não às contas** — uma identidade tem um estado; cada conta técnica reflete esse estado  
- [ ] **Estados não são inferidos automaticamente** — mudanças de estado exigem decisão explícita (evento de negócio)  
- [ ] **Estados técnicos não redefinem estados semânticos** — bloqueio de conta não altera estado da identidade  
- [ ] **Transições exigem decisão explícita** — não existem transições automáticas sem evento documentado  
- [ ] **Estados precedem automação** — provisionamento/deprovisionamento são consequências de mudanças de estado, não causas  
- [ ] **Estados são agnósticos de sistema** — definidos no domínio de negócio, não no domínio técnico  
- [ ] **Identidade tem histórico de estados** — transições são auditáveis e rastreáveis  

### Princípios Específicos do Projeto

_(Adicionar princípios customizados relevantes para este contexto)_

**Exemplos:**
- Identidades de terceirizados seguem lifecycle diferente de colaboradores próprios
- Estados de identidade digital não são 1:1 com estados de vínculo trabalhista
- Sistema de IGA é autoridade única para estados canônicos

---

## 5. Estados Canônicos da Identidade

Listar e descrever **todos os estados** definidos no modelo de identidade deste projeto.

---

### Estado: _(Nome do Estado 1)_

**Descrição Semântica:**  
_(O que este estado significa do ponto de vista de negócio)_

**Significado Organizacional:**  
_(Contexto de RH, vínculo trabalhista ou contratual que justifica este estado)_

**Elegibilidade para Acessos:**  
- [ ] **Sim** — identidade neste estado pode ter acessos provisionados  
- [ ] **Não** — identidade neste estado não deve ter acessos ativos  
- [ ] **Parcial** — identidade pode ter acessos limitados ou específicos  

**Impactos em Provisionamento:**  
_(Como sistemas técnicos devem reagir a este estado)_

**Eventos que Causam Entrada neste Estado:**  
_(Gatilhos de negócio que geram transição para este estado)_

**Observações:**  
_(Exceções, casos especiais, notas de implementação)_

---

### Estado: _(Nome do Estado 2)_

**Descrição Semântica:**  

**Significado Organizacional:**  

**Elegibilidade para Acessos:**  
- [ ] Sim  
- [ ] Não  
- [ ] Parcial  

**Impactos em Provisionamento:**  

**Eventos que Causam Entrada neste Estado:**  

**Observações:**  

---

### Estado: _(Nome do Estado 3)_

_(Repetir estrutura para cada estado definido)_

---

### Exemplo de Preenchimento

**Estado: Ativo**

**Descrição Semântica:**  
Identidade de colaborador com vínculo ativo e elegível para acessos regulares.

**Significado Organizacional:**  
Colaborador próprio, estagiário ou terceirizado com contrato vigente e data de início passada.

**Elegibilidade para Acessos:**  
✅ **Sim** — identidade neste estado pode ter acessos provisionados conforme papéis atribuídos.

**Impactos em Provisionamento:**  
- Contas técnicas são criadas ou reativadas
- Acessos são provisionados conforme políticas de RBAC
- Sincronizações são habilitadas

**Eventos que Causam Entrada neste Estado:**  
- Onboarding de novo colaborador (data de início atingida)
- Retorno de afastamento ou licença
- Reativação de vínculo previamente suspenso

**Observações:**  
Identidade permanece ativa até evento de desligamento, afastamento ou suspensão.

---

**Estado: Suspenso**

**Descrição Semântica:**  
Identidade temporariamente inativa, mas com expectativa de retorno.

**Significado Organizacional:**  
Colaborador em licença médica, licença maternidade, suspensão administrativa ou afastamento temporário.

**Elegibilidade para Acessos:**  
⚠️ **Parcial** — pode manter acessos mínimos (email somente leitura) ou ter todos os acessos desabilitados, conforme política.

**Impactos em Provisionamento:**  
- Contas técnicas são desabilitadas ou mantidas em modo somente leitura
- Acessos críticos são removidos
- VPN e acessos remotos são bloqueados

**Eventos que Causam Entrada neste Estado:**  
- Início de licença médica ou maternidade
- Suspensão administrativa por investigação interna
- Afastamento temporário documentado

**Observações:**  
Estado reversível. Identidade retorna a "Ativo" após fim do período de suspensão.

---

**Estado: Desativado**

**Descrição Semântica:**  
Identidade permanentemente inativa, vínculo encerrado, sem expectativa de retorno.

**Significado Organizacional:**  
Colaborador desligado, contrato encerrado, aposentadoria ou término de vínculo.

**Elegibilidade para Acessos:**  
❌ **Não** — identidade neste estado não deve ter acessos ativos em nenhum sistema.

**Impactos em Provisionamento:**  
- Todas as contas técnicas são desabilitadas
- Acessos são revogados
- Dados podem ser arquivados conforme política de retenção
- Objetos técnicos podem ser marcados para exclusão após período de retenção

**Eventos que Causam Entrada neste Estado:**  
- Desligamento voluntário
- Demissão
- Término de contrato de terceirizado
- Aposentadoria

**Observações:**  
Estado final do lifecycle. Identidade pode ser arquivada, mas não reativada (nova contratação gera nova identidade).

---

## 6. Estados Explicitamente NÃO Contemplados

Listar estados que **não são considerados estados de identidade** neste modelo, evitando ambiguidades futuras.

### Estados Técnicos que NÃO São Estados de Identidade

- [ ] **Habilitado / Desabilitado de conta** — reflete estado técnico, não estado de identidade  
- [ ] **Bloqueado por senha** — evento técnico de segurança, não evento de lifecycle  
- [ ] **Expirado** — flag técnica de conta, não estado organizacional  
- [ ] **Pendente de provisionamento** — status de workflow técnico  
- [ ] **Em sincronização** — flag operacional de sistema  
- [ ] **Fora de escopo de sincronização** — filtro técnico, não estado semântico  

### Por Que Esses Não São Estados de Identidade

_(Explicar diferença conceitual)_

**Exemplo:**  
"Um colaborador ativo (estado de identidade) pode ter sua conta do AD bloqueada por senha errada (estado técnico). Isso não muda seu estado de identidade, que continua 'Ativo'. A confusão entre esses conceitos leva a automações incorretas, como deprovisionamento prematuro por bloqueio técnico."

### Estados de Sistemas Legados que Não Devem Ser Propagados

_(Listar estados de sistemas específicos que não têm correspondência no modelo canônico)_

---

## 7. Relação entre Estados de Identidade e Sistemas

Descrever como sistemas técnicos devem interpretar e reagir aos estados canônicos.

### Como Sistemas Técnicos Reagem aos Estados

| Sistema | Estado "Ativo" | Estado "Suspenso" | Estado "Desativado" |
|---------|----------------|-------------------|---------------------|
| Active Directory |                |                   |                     |
| Sistema de IGA |                |                   |                     |
| Sistema de RH |                |                   |                     |
| Email corporativo |                |                   |                     |
| VPN / Acesso remoto |                |                   |                     |

**Exemplo de preenchimento:**

| Sistema | Estado "Ativo" | Estado "Suspenso" | Estado "Desativado" |
|---------|----------------|-------------------|---------------------|
| Active Directory | Conta habilitada | Conta desabilitada | Conta desabilitada, marcada para exclusão |
| Sistema de IGA | Sincronizações ativas | Sincronizações suspensas | Objeto arquivado |
| Sistema de RH | Registro ativo | Afastamento documentado | Registro encerrado |
| Email corporativo | Caixa ativa | Caixa somente leitura | Caixa convertida para compartilhada ou arquivada |
| VPN / Acesso remoto | Acesso permitido | Acesso bloqueado | Certificado revogado |

### O Que os Sistemas Podem Refletir

_(Estados de identidade propagados como configurações técnicas)_

**Exemplo:**  
"Sistemas podem refletir estados canônicos desabilitando contas, removendo permissões ou bloqueando autenticação. Essas são **consequências** do estado de identidade, não **causas**."

### O Que os Sistemas NÃO Podem Definir

_(Limites explícitos de autonomia de sistemas técnicos)_

**Exemplo:**  
"Sistemas técnicos não podem alterar o estado canônico da identidade. Um administrador de AD não pode mudar uma identidade de 'Ativo' para 'Desativado' desabilitando uma conta. Mudanças de estado devem originar de eventos de negócio documentados (ex: registro de desligamento no RH)."

### Papel do IGA como Orquestrador Semântico

_(Como o sistema de IGA gerencia estados)_

**Responsabilidades:**
- Manter estado canônico da identidade como source of truth
- Orquestrar propagação de estados para sistemas técnicos
- Registrar histórico de transições de estado
- Aplicar regras de negócio para transições válidas
- Gerar alertas quando sistemas técnicos divergem do estado canônico

---

## 8. Transições de Estado (Nível Conceitual)

Descrever, em **alto nível**, as transições permitidas entre estados.

⚠️ **Não definir workflow técnico detalhado aqui.** Foco é semântica, não implementação.

### Transições Permitidas

| De | Para | Gatilho de Negócio | Observações |
|----|------|-------------------|-------------|
|    |      |                   |             |
|    |      |                   |             |

**Exemplo de preenchimento:**

| De | Para | Gatilho de Negócio | Observações |
|----|------|-------------------|-------------|
| (Novo) | Ativo | Data de início de contrato atingida | Onboarding |
| Ativo | Suspenso | Início de licença ou afastamento | Reversível |
| Ativo | Desativado | Desligamento documentado | Final |
| Suspenso | Ativo | Retorno de licença/afastamento | Reativação |
| Suspenso | Desativado | Desligamento durante suspensão | Final |

### Transições Proibidas

_(Transições que não fazem sentido no modelo de negócio)_

**Exemplos:**
- Desativado → Ativo (nova contratação gera nova identidade)
- Desativado → Suspenso (não faz sentido semântico)

### Transições que Exigem Decisão Formal

_(Transições que não podem ser automáticas)_

**Exemplos:**
- Qualquer transição para "Desativado" requer aprovação formal de RH
- Reativação de identidade suspensa há mais de 6 meses requer revisão de acessos

### Estados Finais

_(Estados dos quais não há retorno)_

**Exemplo:**  
"Desativado" é estado final. Identidades desativadas não são reativadas; recontratações geram novas identidades.

---

## 9. Decisões Congeladas por Este Canvas

Listar explicitamente as decisões que **não podem ser alteradas sem decisão arquitetural formal** (ADR ou revisão deste canvas).

### Decisões Imutáveis

1. _(Exemplo: "Estados de identidade são semânticos, não técnicos")_
2. _(Exemplo: "Sistema de IGA é autoridade única para estado canônico")_
3. _(Exemplo: "'Desativado' é estado final, sem reversão")_

### Decisões Revisáveis com Aprovação

1. _(Exemplo: "Novos estados podem ser adicionados mediante ADR e validação de impacto")_
2. _(Exemplo: "Comportamento de sistemas em estado 'Suspenso' pode ser ajustado por política")_

### Gatilhos de Revisão Obrigatória

- [ ] Mudança de processo de RH (ex: novos tipos de vínculo)  
- [ ] Requisito regulatório novo (ex: LGPD exigindo novos controles)  
- [ ] Incidente de segurança relacionado a lifecycle  
- [ ] Auditoria identificando gaps no modelo de estados  
- [ ] Onboarding de novo tipo de identidade (ex: fornecedores, robôs)  

---

## 10. Relação com Implementações e Outros Artefatos

### GMUDs que Dependem Deste Canvas

_(Listar GMUDs de implementação de JML, sincronizações ou provisionamento que só podem ser executadas após este canvas estar ativo)_

**Exemplos:**
- GMUD-XXX — Implementação de Fluxo de Onboarding
- GMUD-YYY — Automação de Offboarding
- GMUD-ZZZ — Sincronização de Estados IGA-AD

### Canvases Relacionados

_(Indicar dependências com outros canvases de decisão)_

**Exemplos:**
- **Depende de:** CAN-ID-001 — Identificador Canônico de Identidade
- **Depende de:** CAN-ID-002 — Autoridade de Dados de Identidade
- **Impacta:** CAN-ID-004 — Modelo de Provisionamento

### Decisões Arquiteturais Derivadas (ADRs)

_(ADRs que devem ser criados com base neste canvas)_

**Exemplos:**
- ADR-XXX — Escolha de Sistema de IGA como Autoridade de Estados
- ADR-YYY — Tratamento de Identidades de Terceirizados

### Artefatos Técnicos Derivados

_(Documentos de implementação que derivam deste canvas)_

**Exemplos:**
- Workflows técnicos de JML
- Configuração de lifecycle policies no IGA
- Scripts de automação de provisionamento/deprovisionamento
- Políticas de sincronização de estados

---

## 11. Validação e Testes

### Cenários de Teste Recomendados

1. **Teste de transição normal:**  
   _(Validar transição Ativo → Suspenso → Ativo)_

2. **Teste de transição final:**  
   _(Validar que Desativado não permite reativação)_

3. **Teste de propagação:**  
   _(Validar que mudança de estado no IGA se propaga para sistemas técnicos)_

4. **Teste de independência técnica:**  
   _(Validar que bloqueio de conta no AD não altera estado canônico no IGA)_

### Critérios de Aceitação

- [ ] Todos os estados canônicos definidos e documentados  
- [ ] Transições permitidas e proibidas mapeadas  
- [ ] Relação com sistemas técnicos documentada  
- [ ] Testes de transições executados com sucesso  
- [ ] Auditoria de histórico de estados funcionando  
- [ ] Stakeholders aprovaram o canvas  

---

## 12. Stakeholders e Aprovações

| Papel | Nome | Área | Data de Aprovação | Status |
|-------|------|------|-------------------|--------|
| Arquiteto de Identidade |  |  |  |  |
| Gestor de RH / Owner de Lifecycle |  |  |  |  |
| Gestor de TI / Infraestrutura |  |  |  |  |
| Compliance / GRC |  |  |  |  |
| Owner do Projeto IAM |  |  |  |  |

---

## 13. Referências

### GMUDs Relacionadas
- _(Listar GMUDs que motivaram ou dependem deste canvas)_

### ADRs Relacionadas
- _(Listar decisões arquiteturais formais relacionadas)_

### Outros Canvases
- _(Referenciar outros canvases de identidade do projeto)_

### Documentos Arquiteturais
- _(Arquiteturas de referência, diagramas de lifecycle, fluxos JML)_

### Frameworks de Compliance
- _(ISO 27001, NIST, GDPR, LGPD — controles específicos de lifecycle)_

---

## 14. Controle de Versão

| Versão | Data | Autor | Mudança | Motivo |
|--------|------|-------|---------|--------|
| 1.0    |      |       |         |        |
|        |      |       |         |        |
|        |      |       |         |        |

---

## 15. Observações e Notas de Governança

_(Espaço livre para considerações importantes, alertas, exceções ou notas de implementação)_

**Exemplos:**
- "Estados de identidades de robôs/contas de serviço seguem modelo separado"
- "Identidades de fornecedores têm estado adicional 'Em Homologação'"
- "Colaboradores em período de experiência mantêm estado 'Ativo' com flag adicional"

---

## Instruções de Uso

### Para criar canvas de lifecycle a partir deste template:

1. Copie este template para novo arquivo
2. Renomeie conforme padrão do projeto (ex: `CAN-ID-LC-001-Estados-Identidade.md`)
3. Preencha seção 1 (Identificação)
4. Preencha seção 3 (Contexto) com informações do ambiente
5. Defina princípios em seção 4
6. **Defina todos os estados canônicos** em seção 5 (decisão crítica)
7. Liste estados que NÃO são de identidade em seção 6
8. Documente relação com sistemas em seção 7
9. Mapeie transições em seção 8
10. Formalize decisões congeladas em seção 9
11. Vincule a GMUDs e artefatos em seção 10
12. Obtenha aprovações em seção 12
13. Marque como "Ativo" e comunique a equipes técnicas

---

## Metadados do Template

**Versão do Template:** 2.0  
**Data de Criação:** 14/01/2026  
**Compatível com:** Projetos IAM/IGA/Identity Governance multi-ferramenta  
**Frameworks de Referência:** ISO/IEC 27001, NIST CSF, TOGAF, COBIT  
**Independente de:** Vendor, plataforma, ferramenta, organização  
**Licença de Uso:** Reutilizável em qualquer contexto IAM  

**Mantido por:** Comunidade de Arquitetos de Identidade  
**Localização Sugerida:** `/Templates/Identity-Architecture/Lifecycle/`  
**Próxima revisão do template:** Anual ou sob demanda

---
