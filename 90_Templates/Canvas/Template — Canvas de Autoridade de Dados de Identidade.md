---
**Documento:** TEMPLATE-CANVAS-IDENTITY-DATA-AUTHORITY  
**Título:** Template — Canvas de Autoridade de Dados de Identidade  
**Tipo:** Template Reutilizável — Canvas de Decisão IAM  
**Categoria:** Autoridade e Governança de Dados de Identidade  
**Versão:** 2.0  
**Data:** 14/01/2026  
**Aplicabilidade:** Universal — Projetos IAM/IGA/Identity Governance  
**Independente de:** Ferramenta, vendor, plataforma, organização  

---

## Propósito do Template

Este template define a estrutura para documentar **decisões de autoridade de dados de identidade** em qualquer projeto IAM/IGA.

**Características:**
- Reutilizável em múltiplos contextos (corporativo, lab, consultoria, POC)
- Agnóstico de ferramenta (midPoint, SailPoint, Okta, Entra ID, AD, etc.)
- Independente de vendor e tecnologia
- Define **quem governa quais dados** antes de integrações técnicas
- Previne conflitos de sincronização e sobrescritas não intencionais

**Princípio Fundamental:**  
Autoridade de dados deve ser explícita, documentada e validada antes de qualquer mapeamento ou sincronização.

---

## 1. Identificação do Canvas

**Projeto:**  
_(Nome do projeto ou iniciativa IAM/IGA)_

**Código do Canvas:**  
_(Padrão sugerido: CAN-ID-DG-XXX ou CAN-ID-AUTH-XXX)_

**Versão:**  
_(Formato: X.Y — major.minor)_

**Status:**  
- [ ] Rascunho  
- [ ] Em Consolidação  
- [ ] Revisado  
- [ ] Ativo  
- [ ] Arquivado  

**Origem da Decisão:**  
_(Indicar gatilho: GMUD específica, ADR, iniciativa estratégica, auditoria, etc.)_

**Data de Criação:**  
_(dd/mm/aaaa)_

**Última Revisão:**  
_(dd/mm/aaaa)_

**Owner / Responsável:**  
_(Nome e área do responsável pelo canvas)_

---

## 2. Objetivo do Canvas

Este canvas descreve **como a autoridade de dados de identidade é definida neste projeto**, estabelecendo:

- **Quem é responsável** por cada categoria de dado de identidade
- **Como conflitos** entre fontes são resolvidos
- **Quais princípios** regem precedência, atualização e sobrescrita
- **Limites de autonomia** de cada sistema integrado

### Este Canvas Atua Como Gate Obrigatório Antes De:

- [ ] Integração de novas fontes de dados de identidade  
- [ ] Mapeamento de atributos entre sistemas  
- [ ] Implementação de sincronizações bidirecionais  
- [ ] Reconciliação e correlação de identidades  
- [ ] Automação de provisionamento ou deprovisionamento  
- [ ] Implementação de fluxos JML (Joiner/Mover/Leaver)  

---

## 3. Contexto do Projeto

### Cenário Arquitetural

- [ ] **Greenfield** — nova infraestrutura, sem sistemas legados  
- [ ] **Brownfield** — integração com sistemas existentes  
- [ ] **Híbrido** — mistura de novos sistemas e legado  

### Principais Fontes de Identidade

_(Listar sistemas que contêm ou geram dados de identidade)_

**Exemplos:**
- Sistema de RH (ex: SAP, Workday, OrangeHRM)
- Active Directory / Entra ID
- Diretório LDAP
- Sistema de IGA (ex: midPoint, SailPoint)
- Aplicações de negócio específicas

### Problemas Observados ou Riscos Conhecidos

_(Descrever problemas concretos que motivam este canvas)_

**Exemplos:**
- Sobrescritas não intencionais de dados de RH por atualizações do AD
- Divergências entre sistema de RH e diretório sem critério de resolução
- Atributos críticos modificados manualmente sem rastreabilidade
- Loops de sincronização causados por autoridade ambígua

### Motivações para Decisões Explícitas de Autoridade

_(Por que este projeto precisa formalizar autoridade de dados?)_

**Exemplos:**
- Requisitos de compliance (ISO 27001, SOX, GDPR, LGPD)
- Auditoria identificou lacunas de governança
- Expansão de integrações aumentou complexidade
- Incidentes de inconsistência de dados

---

## 4. Princípios de Autoridade de Dados

Definir os **princípios arquiteturais** adotados neste projeto.

### Princípios Recomendados (Adaptar Conforme Necessário)

- [ ] **Autoridade por atributo** — cada atributo tem fonte autoritativa única e declarada  
- [ ] **Inexistência de fonte soberana única** — nenhum sistema governa 100% dos atributos  
- [ ] **Precedência explícita** — conflitos são resolvidos por regras documentadas, não por ordem de execução  
- [ ] **Separação entre dados de negócio e técnicos** — dados de RH não sobrescrevem configurações técnicas  
- [ ] **Proibição de sobrescrita implícita** — nenhuma sincronização pode sobrescrever dados sem autoridade declarada  
- [ ] **Rastreabilidade de mudanças** — toda alteração de dados críticos deve ser auditável  
- [ ] **Imutabilidade de identificadores** — identificador canônico não pode ser alterado por nenhuma fonte  

### Princípios Específicos do Projeto

_(Adicionar princípios customizados relevantes para este contexto)_

---

## 5. Classificação das Fontes de Dados

Listar e classificar **todas as fontes de identidade** envolvidas no projeto.

| Fonte | Tipo | Papel no Ecossistema | Observações |
|-------|------|----------------------|-------------|
|       | Negócio / Técnica / Identidade / Aplicação |                      |             |
|       |      |                      |             |
|       |      |                      |             |

**Tipos de Fonte:**
- **Negócio:** Sistemas que gerenciam informações de negócio (RH, ERP, CRM)
- **Técnica:** Sistemas de infraestrutura técnica (AD, LDAP, DNS)
- **Identidade:** Sistemas dedicados a governança de identidade (IGA, IDM)
- **Aplicação:** Aplicações de negócio que mantêm dados locais de usuários

**Papel no Ecossistema:**
- Source of Truth (para determinados atributos)
- Target (recebe dados de outras fontes)
- Híbrido (source para alguns atributos, target para outros)

---

## 6. Autoridade por Categoria de Atributo

Definir autoridade **em nível conceitual**, não técnico.

| Categoria de Atributo | Autoridade Primária | Autoridade Secundária (se aplicável) | Observações |
|----------------------|--------------------|------------------------------------|-------------|
| **Identificador canônico** |  |  |  |
| **Dados pessoais básicos** |  |  |  |
| **Dados de contato** |  |  |  |
| **Dados organizacionais** |  |  |  |
| **Credenciais técnicas** |  |  |  |
| **Estados de conta/lifecycle** |  |  |  |
| **Atribuições de acesso/grupos** |  |  |  |
| **Metadados de auditoria** |  |  |  |

**Exemplos de Preenchimento:**

| Categoria | Autoridade Primária | Autoridade Secundária | Observações |
|-----------|--------------------|-----------------------|-------------|
| Identificador canônico | Sistema de RH (employeeID) | N/A | Imutável, gerado no onboarding |
| Dados pessoais | Sistema de RH | N/A | Nome, CPF, data de nascimento |
| Email corporativo | Active Directory | Sistema de RH (validação) | Gerado por AD conforme convenção |
| Departamento | Sistema de RH | N/A | Estrutura organizacional |
| Estado da conta | Sistema de IGA | Sistema de RH (evento inicial) | IGA orquestra, RH gatilho |
| Grupos técnicos | Active Directory | Sistema de IGA (aprovação) | AD implementa, IGA governa |

> **Nota:** Detalhamento atributo por atributo deve ocorrer em artefato técnico derivado (mapeamento de atributos), não neste canvas.

---

## 7. Precedência e Resolução de Conflitos

Descrever como conflitos entre fontes são tratados quando múltiplos sistemas tentam atualizar o mesmo dado.

### Regras de Precedência

_(Definir ordem de prioridade ou critérios de resolução)_

**Exemplos:**
1. **Última modificação ganha** — para atributos não críticos
2. **Autoridade primária sempre prevalece** — para atributos críticos
3. **Aprovação manual requerida** — para divergências em dados sensíveis
4. **Timestamp de origem** — fonte com timestamp mais recente prevalece

### Comportamento em Indisponibilidade da Fonte Primária

_(O que acontece quando a fonte autoritativa está offline?)_

**Opções:**
- [ ] Sincronização é suspensa até retorno da fonte primária  
- [ ] Fonte secundária assume temporariamente (com flag de contingência)  
- [ ] Sistema de IGA usa último valor conhecido  
- [ ] Alerta é gerado para intervenção manual  

### Tratamento de Divergências

_(Como divergências detectadas são gerenciadas?)_

**Exemplos:**
- Divergências geram ticket de análise
- Relatório semanal de inconsistências é enviado para governança
- Divergências em atributos críticos bloqueiam sincronização
- Dashboard de qualidade de dados exibe divergências

### Registro e Auditoria de Conflitos

_(Como conflitos são registrados para rastreabilidade?)_

**Requisitos:**
- [ ] Log de todas as tentativas de sobrescrita rejeitadas  
- [ ] Histórico de valores conflitantes com timestamp  
- [ ] Identificação de sistema/usuário que tentou modificar  
- [ ] Retenção de logs conforme política de auditoria  

---

## 8. Papel do Sistema de IGA / Orquestrador

Descrever o papel do sistema central de governança de identidades (ex: midPoint, SailPoint, Okta Governance).

### Responsabilidades do Sistema de IGA

- [ ] **Consolidação de dados** — agregar informações de múltiplas fontes  
- [ ] **Execução de regras de autoridade** — aplicar precedência documentada  
- [ ] **Armazenamento canônico** — manter cópia consolidada da identidade  
- [ ] **Orquestração de sincronizações** — coordenar fluxo entre sistemas  
- [ ] **Resolução de conflitos** — aplicar regras de precedência  
- [ ] **Auditoria** — registrar histórico de mudanças  

### Limites Explícitos de Atuação

_(O que o IGA NÃO deve fazer)_

**Exemplos:**
- IGA não deve sobrescrever dados da fonte autoritativa
- IGA não deve gerar valores para atributos de autoridade externa
- IGA não deve modificar dados técnicos de infraestrutura (ex: SID, GUID)
- IGA não deve atuar como fonte primária para dados de negócio

### Modelo de Atuação

- [ ] **Passthrough** — IGA apenas replica dados sem transformação  
- [ ] **Transformação** — IGA aplica regras de negócio antes de propagar  
- [ ] **Enriquecimento** — IGA adiciona metadados sem alterar dados originais  
- [ ] **Consolidação autoritativa** — IGA se torna fonte primária após agregação  

---

## 9. Decisões Congeladas por Este Canvas

Listar explicitamente as decisões que **não podem ser alteradas sem decisão arquitetural formal** (ADR ou revisão deste canvas).

### Decisões Imutáveis

1. _(Exemplo: "Sistema de RH é autoridade única para dados pessoais básicos")_
2. _(Exemplo: "EmployeeID do RH é identificador canônico, imutável e não reutilizável")_
3. _(Exemplo: "Active Directory não pode sobrescrever dados organizacionais vindos do RH")_

### Decisões Revisáveis com Aprovação

1. _(Exemplo: "Regras de geração de email podem ser alteradas mediante ADR")_
2. _(Exemplo: "Autoridade de estados de conta pode ser revista em caso de mudança de processo de negócio")_

### Gatilhos de Revisão Obrigatória

- [ ] Onboarding de nova fonte autoritativa  
- [ ] Mudança de sistema de RH ou ERP  
- [ ] Incidente de segurança relacionado a dados de identidade  
- [ ] Auditoria externa identificando não conformidade  
- [ ] Mudança regulatória (LGPD, GDPR, etc.)  

---

## 10. Relação com Implementações e Outros Artefatos

### GMUDs que Dependem Deste Canvas

_(Listar GMUDs de integração, sincronização ou provisionamento que só podem ser executadas após este canvas estar ativo)_

**Exemplos:**
- GMUD-XXX — Integração Sistema de RH com IGA
- GMUD-YYY — Sincronização Bidirecional IGA-AD
- GMUD-ZZZ — Implementação de Fluxo de Onboarding

### Canvases Relacionados

_(Indicar dependências com outros canvases de decisão)_

**Exemplos:**
- **Depende de:** CAN-ID-001 — Identificador Canônico de Identidade
- **Impacta:** CAN-ID-003 — Estados de Ciclo de Vida de Identidade
- **Complementa:** CAN-ID-004 — Modelo de Correlação entre Fontes

### Decisões Arquiteturais Derivadas (ADRs)

_(ADRs que devem ser criados com base neste canvas)_

**Exemplos:**
- ADR-XXX — Escolha de Sistema de RH como Fonte Autoritativa
- ADR-YYY — Tratamento de Divergências em Ambiente Híbrido

### Artefatos Técnicos Derivados

_(Documentos de implementação que derivam deste canvas)_

**Exemplos:**
- Mapeamento de atributos fonte-a-fonte
- Configuração de conectores IGA
- Políticas de sincronização
- Scripts de transformação

---

## 11. Validação e Testes

### Cenários de Teste Recomendados

1. **Teste de autoridade primária:**  
   _(Validar que modificações na fonte primária são propagadas corretamente)_

2. **Teste de conflito:**  
   _(Validar que tentativa de sobrescrita por fonte não autoritativa é rejeitada)_

3. **Teste de indisponibilidade:**  
   _(Validar comportamento quando fonte primária está offline)_

4. **Teste de auditoria:**  
   _(Validar que conflitos e sobrescritas são registrados em log)_

### Critérios de Aceitação

- [ ] Todas as fontes classificadas e documentadas  
- [ ] Autoridade de todas as categorias de atributo definida  
- [ ] Regras de precedência documentadas e implementadas  
- [ ] Comportamento de conflitos testado e validado  
- [ ] Logs de auditoria funcionando corretamente  
- [ ] Stakeholders aprovaram o canvas  

---

## 12. Stakeholders e Aprovações

| Papel | Nome | Área | Data de Aprovação | Status |
|-------|------|------|-------------------|--------|
| Arquiteto de Identidade |  |  |  |  |
| Gestor de RH / Owner de Dados |  |  |  |  |
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
- _(Arquiteturas de referência, diagramas, modelos de dados)_

### Frameworks de Compliance
- _(ISO 27001, NIST, GDPR, LGPD — controles específicos)_

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
- "Autoridade de email corporativo será revista após migração para Microsoft 365"
- "Sistema de RH legado será substituído em Q3/2026 — canvas deve ser atualizado"
- "Exceção: usuários de serviço não seguem autoridade de RH, seguem registro manual no IGA"

---

## Instruções de Uso

### Para criar canvas de autoridade de dados a partir deste template:

1. Copie este template para novo arquivo
2. Renomeie conforme padrão do projeto (ex: `CAN-ID-DG-001-Autoridade-Dados.md`)
3. Preencha seção 1 (Identificação)
4. Preencha seção 3 (Contexto) com informações do ambiente
5. Defina princípios em seção 4
6. Liste e classifique todas as fontes em seção 5
7. **Defina autoridade por categoria** em seção 6 (decisão crítica)
8. Documente regras de conflito em seção 7
9. Descreva papel do IGA em seção 8
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
**Localização Sugerida:** `/Templates/Identity-Architecture/Data-Governance/`  
**Próxima revisão do template:** Anual ou sob demanda

---
