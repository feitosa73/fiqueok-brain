---
**Documento:** TEMPLATE-IDENTITY-DECISION-GOVERNANCE-CANVAS  
**Título:** Template — Canvas de Governança de Decisão em Identidade  
**Tipo:** Template Reutilizável — Canvas de Governança  
**Domínio:** Arquitetura de Identidade (IAM / IGA / GRC)  
**Versão:** 2.0  
**Data:** 14/01/2026  
**Aplicabilidade:** Universal — Projetos IAM/IGA/Segurança/Compliance  
**Independente de:** Ferramenta, vendor, plataforma, organização  

---

## Propósito do Template

Este template define a estrutura para documentar **governança de decisões relacionadas à identidade** em qualquer projeto IAM/IGA.

**Características:**
- Reutilizável em múltiplos contextos (corporativo, lab, consultoria, POC)
- Agnóstico de ferramenta e vendor
- Independente de metodologia específica (ITIL, COBIT, TOGAF)
- Define **quem decide o quê** e **como** decisões são validadas
- Previne decisões implícitas, atalhos técnicos e retrabalho

**Princípio Fundamental:**  
Decisões arquiteturais, de governança e técnicas em identidade devem ser explícitas, rastreáveis e validadas antes de implementação. Este canvas é o **framework de controle** que impede decisões "em voo" não documentadas.

---

## 1. Identificação

**Projeto:**  
_(Nome do projeto ou iniciativa IAM/IGA)_

**Código do Canvas:**  
_(Padrão sugerido: DEC-ID-GOV-XXX ou DEC-ID-001)_

**Versão:**  
_(Formato: X.Y — major.minor)_

**Status:**  
- [ ] Rascunho  
- [ ] Em Consolidação  
- [ ] Congelado (regras em vigor)  
- [ ] Ativo  
- [ ] Arquivado  

**Data de Criação:**  
_(dd/mm/aaaa)_

**Última Revisão:**  
_(dd/mm/aaaa)_

**Owner do Canvas:**  
_(Nome e área do responsável pela governança de decisões)_

**Aprovador:**  
_(Quem valida mudanças neste canvas)_

---

## 2. Objetivo do Canvas

Este canvas define **como decisões relacionadas à identidade são tomadas neste projeto**, estabelecendo:

- **Tipos de decisão** existentes no domínio de identidade
- **Responsáveis** por cada tipo de decisão
- **Nível de formalidade** exigido para cada categoria
- **Artefatos obrigatórios** para validação e rastreabilidade
- **Processo de escalonamento** quando decisões ultrapassam competência
- **Mecanismos de bloqueio** para decisões não autorizadas

### Este Canvas Atua Como Mecanismo de Controle, Evitando:

- [ ] Decisões implícitas (não documentadas)  
- [ ] Atalhos técnicos que comprometem arquitetura  
- [ ] Mudanças sem rastreabilidade  
- [ ] Conflitos de autoridade entre times  
- [ ] Retrabalho por decisões inconsistentes  
- [ ] Violação de princípios arquiteturais  
- [ ] Não conformidades em auditorias  

---

## 3. Escopo de Decisões Abrangidas

Este Canvas se aplica a decisões relacionadas aos seguintes temas:

### Domínios de Decisão em Identidade

- [ ] **Identidade canônica** — identificador único, correlação, modelo de dados  
- [ ] **Atributos e dados de identidade** — autoridade, precedência, governança  
- [ ] **Estados e ciclo de vida** — lifecycle semântico, transições, eventos  
- [ ] **Integrações IAM** — conectores, sincronizações, fontes de dados  
- [ ] **Automação de acessos** — provisionamento, deprovisionamento, RBAC  
- [ ] **Políticas de segurança** — autenticação, autorização, segregation of duties  
- [ ] **Exceções e desvios** — casos especiais, workarounds temporários  
- [ ] **Compliance e auditoria** — rastreabilidade, evidências, controles  

### Decisões Fora do Escopo

_(Indicar claramente o que NÃO é coberto por este canvas)_

**Exemplos:**
- Decisões de infraestrutura não relacionadas a identidade
- Decisões de desenvolvimento de aplicações
- Decisões puramente operacionais de TI sem impacto em identidade

---

## 4. Tipos de Decisão em Identidade

Classificar os tipos de decisão existentes no projeto, com definição clara de cada categoria.

| Tipo de Decisão | Descrição | Exemplos |
|----------------|-----------|----------|
| **Arquitetural** | Afeta modelo conceitual, semântica, contratos de identidade ou princípios fundamentais | Escolha de identificador canônico; definição de estados semânticos; separação entre identidade e contas |
| **Governança** | Afeta regras de autoridade, precedência, responsabilidades ou processos de decisão | Definição de autoridade de dados; regras de resolução de conflitos; políticas de lifecycle |
| **Técnica** | Afeta implementação, configuração ou integração de ferramentas específicas | Escolha de connector type; configuração de mappings; parâmetros de sincronização |
| **Operacional** | Afeta execução recorrente, manutenção ou suporte, sem alterar modelo ou regras | Agendamento de sincronizações; ajuste de timeouts; troubleshooting de integrações |
| **Emergencial** | Afeta resposta imediata a incidente, violação ou falha crítica | Desabilitação manual de conta comprometida; bypass temporário de automação; rollback de emergência |

---

## 5. Matriz de Decisão e Responsabilidade

Definir **quem pode decidir o quê**, com que nível de formalidade e quais artefatos são obrigatórios.

| Tipo de Decisão | Responsável / Papel | Artefato Obrigatório | Aprovador | Pode ocorrer em GMUD técnica? | Prazo de Formalização |
|----------------|---------------------|----------------------|-----------|-------------------------------|----------------------|
| **Arquitetural** | Arquiteto de Identidade | ADR (Architecture Decision Record) | Owner do Projeto + Arquiteto | ❌ Não | Antes da implementação |
| **Governança** | Gestor de Identidade / GRC Lead | Canvas de Decisão (CAN-ID) | Comitê de Governança | ❌ Não | Antes da automação |
| **Técnica** | Engenheiro IAM / Implementador | GMUD Técnica | Arquiteto (review) | ✅ Sim | Durante GMUD |
| **Operacional** | Time de Operações IAM | Procedimento Operacional (POP) | Gestor de Operações | ✅ Sim | Conforme SLA |
| **Emergencial** | On-call / Incident Manager | Registro de Incidente | Gestor de Segurança | ⚠️ Exceção | Máximo 48h após evento |

### Observações

- **ADR (Architecture Decision Record):** Documento formal que captura decisão, contexto, alternativas, consequências e justificativa
- **Canvas de Decisão (CAN-ID):** Artefato estruturado para decisões de governança de identidade
- **GMUD Técnica:** Change request para implementação técnica dentro de decisões já validadas
- **Registro de Incidente:** Documentação formal de evento emergencial e ações tomadas

---

## 6. Relação com Canvases de Identidade

Estabelecer como decisões interagem com os canvases de identidade (CAN-ID).

### Hierarquia de Artefatos

