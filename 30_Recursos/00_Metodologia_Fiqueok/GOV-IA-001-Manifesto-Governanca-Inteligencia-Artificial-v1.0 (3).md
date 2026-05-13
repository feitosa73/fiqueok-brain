---
id_documento: GOV-IA-001
titulo: Manifesto de Governança de Inteligência Artificial em Projetos Técnicos
tipo: Política de Governança
categoria: Governança Corporativa
status: 🟢 Ativo
prioridade: Alta
data_criacao: 10/01/2026
versao: 1.0
localizacao: 20_Recursos/Governanca
classificacao: Internal Use - Governance Framework
tags: [Governança, IA, RACI, DACI, Responsabilidade, Accountability]
documentos_relacionados:
  - ADR-001 (Redistribuição de Papéis e Responsabilidades das IAs)
  - ADR-002 (Reatribuição de Responsabilidades - Perplexity Duplo Papel)
  - GMUD-023 v1.1 (Exemplo de aplicação dos princípios)
---

# Manifesto de Governança de Inteligência Artificial em Projetos Técnicos

## Propósito

Este manifesto estabelece o **modelo de governança para uso de Inteligência Artificial** em projetos técnicos, laboratórios, documentação e futuras atividades de consultoria. Seu objetivo é:

1. **Declarar formalmente** a coexistência de modelos RACI e DACI como frameworks de responsabilidade
2. **Estabelecer princípios** para uso ético, transparente e auditável de ferramentas de IA
3. **Definir limites claros** sobre responsabilidades humanas versus capacidades técnicas de IA
4. **Garantir accountability** em decisões técnicas, estratégicas e documentais
5. **Criar base normativa** para Architecture Decision Records (ADRs), Gestões de Mudança (GMUDs) e outros documentos corporativos

Este documento é **independente de ferramentas específicas** e pode ser reaplicado em diferentes contextos de projeto, mantendo a mesma estrutura de governança.

---

## Princípios Fundamentais

### 1. Separação de Capacidades e Responsabilidades

**Princípio**: Capacidade técnica não equivale a responsabilidade institucional.

- Ferramentas de IA possuem **capacidades** (análise, síntese, codificação, pesquisa)
- Humanos possuem **responsabilidades** (decisão, aprovação, accountability legal)
- A governança distingue claramente entre:
  - **Quem executa** (pode ser humano ou IA)
  - **Quem decide** (sempre humano)
  - **Quem responde** (sempre humano)

### 2. Decisão e Aprovação Humanas

**Princípio**: Decisões técnicas, estratégicas e operacionais são prerrogativas humanas.

- IA **recomenda**, humanos **decidem**
- IA **analisa**, humanos **aprovam**
- IA **sugere**, humanos **assumem responsabilidade**

Nenhuma ferramenta de IA pode:
- Aprovar mudanças em ambientes produtivos ou de laboratório
- Assumir responsabilidade por incidentes ou não-conformidades
- Substituir o papel de decisor final em ADRs, GMUDs ou políticas

### 3. Transparência e Auditabilidade

**Princípio**: O uso de IA deve ser transparente, documentado e auditável.

- Documentos técnicos devem declarar quando IA foi utilizada como apoio
- O tipo de apoio deve ser especificado (análise, pesquisa, codificação, documentação)
- A responsabilidade final deve ser atribuída nominalmente a um humano
- Logs de decisões devem rastrear origem humana, não ferramentas utilizadas

### 4. IA como Ferramenta, não Agente

**Princípio**: Inteligência Artificial é uma capacidade técnica à disposição de pessoas.

- IA não é "membro da equipe"
- IA não é "autor" de decisões ou documentos
- IA não é "responsável técnico" por implementações
- IA é **recurso** utilizado por profissionais para ampliar produtividade e qualidade

---

## Modelo de Governança: RACI e DACI

### Por que Dois Modelos?

A gestão de projetos técnicos envolve dois tipos distintos de atividades:

1. **Processos contínuos e colaborativos** (execução técnica, documentação, validação)
2. **Decisões arquiteturais críticas** (escolha de tecnologias, mudanças de arquitetura, definição de padrões)

Cada tipo de atividade exige um framework de responsabilidade diferente:

- **RACI**: adequado para processos contínuos com múltiplos envolvidos
- **DACI**: adequado para decisões pontuais com driver único e aprovador explícito

### O que é RACI?

**RACI** é uma matriz de responsabilidades que define quatro papéis:

- **R (Responsible)**: Quem executa a tarefa
- **A (Accountable)**: Quem responde pelo resultado final (apenas um por tarefa)
- **C (Consulted)**: Quem é consultado antes da execução (comunicação bidirecional)
- **I (Informed)**: Quem é informado após a execução (comunicação unidirecional)

**Quando usar RACI**:
- Implementação de GMUDs (múltiplas fases, diversos executores)
- Documentação de processos (redação, revisão, aprovação)
- Troubleshooting de incidentes (análise, correção, validação)
- Planejamento de roadmaps (planejamento, execução, monitoramento)

**Características**:
- Processos **contínuos** ou **iterativos**
- Múltiplos **executores** (R) possíveis
- Responsabilidade final (A) sempre única e humana
- Apoio de IA pode aparecer como (R) em tarefas de análise/documentação

### O que é DACI?

**DACI** é um framework de decisão que define quatro papéis:

- **D (Driver)**: Quem conduz o processo de decisão (coleta informações, facilita discussão)
- **A (Approver)**: Quem aprova a decisão final (apenas um)
- **C (Contributors)**: Quem contribui com informações e análises
- **I (Informed)**: Quem é informado após a decisão

**Quando usar DACI**:
- Architecture Decision Records (ADRs)
- Decisões de tecnologia (escolha de conector, arquitetura de integração)
- Mudanças de estratégia técnica (migração de plataforma, adoção de padrões)
- Definição de políticas e padrões

**Características**:
- Decisões **pontuais** e **críticas**
- Driver (D) único conduz o processo
- Aprovador (A) único com poder de veto
- IA pode ser Contributor (C), **nunca** Driver ou Approver

### Coexistência RACI + DACI

**Princípio**: RACI e DACI **não competem**, mas se complementam.

- **ADRs** usam DACI (decisões arquiteturais)
- **GMUDs** usam RACI (processos de execução)
- **Políticas corporativas** usam DACI (definição de padrões)
- **Troubleshooting** usa RACI (análise, correção, validação)

**Regra de ouro**:
- Se a atividade é uma **decisão crítica e pontual** → **DACI**
- Se a atividade é um **processo contínuo com múltiplas fases** → **RACI**

---

## Papel da Inteligência Artificial

### 1. Capacidades Técnicas de IA

IA pode ser utilizada para:

**Análise Técnica**:
- Diagnóstico de configurações
- Análise de logs e evidências técnicas
- Identificação de causa raiz de incidentes
- Comparação de alternativas arquiteturais

**Pesquisa e Documentação**:
- Pesquisa de CVEs, vulnerabilidades e patches
- Comparação de ferramentas e tecnologias
- Síntese de documentação técnica
- Redação de rascunhos de GMUDs, ADRs e relatórios

**Implementação Assistida**:
- Geração de scripts (Bash, PowerShell, Python, Groovy)
- Criação de playbooks Ansible
- Configuração de Docker Compose
- Geração de diagramas de arquitetura

**Validação e Revisão**:
- Validação de sintaxe de código
- Fact-checking de informações técnicas
- Revisão de documentação para consistência
- Identificação de gaps em processos

### 2. Limites Operacionais de IA

IA **não pode**:

**Decisão**:
- ❌ Aprovar mudanças em ambientes de laboratório ou produção
- ❌ Decidir sobre estratégias arquiteturais
- ❌ Escolher tecnologias sem validação humana
- ❌ Definir prioridades de projeto

**Responsabilidade**:
- ❌ Assumir accountability por incidentes
- ❌ Assinar documentos como "responsável técnico"
- ❌ Responder por não-conformidades (RNCs)
- ❌ Ser listada como "autor" em aprovações formais

**Execução Autônoma**:
- ❌ Executar comandos em servidores sem supervisão
- ❌ Realizar mudanças em bancos de dados de forma autônoma
- ❌ Modificar configurações críticas sem validação humana
- ❌ Tomar decisões de rollback em caso de falha

### 3. Papéis de IA em Modelos de Governança

#### Em RACI

IA pode aparecer como:
- **R (Responsible)**: Para tarefas de análise, documentação e codificação assistida
  - Exemplo: "R: Ferramenta de IA (análise técnica)"
- **C (Consulted)**: Para validação técnica ou fact-checking
  - Exemplo: "C: Ferramenta de IA (validação de sintaxe)"

IA **nunca** pode ser:
- **A (Accountable)**: Responsabilidade final é sempre humana
- **I (Informed)**: IA não é stakeholder do projeto

#### Em DACI

IA pode aparecer como:
- **C (Contributor)**: Para análises técnicas e recomendações
  - Exemplo: "C: Ferramenta de IA (comparação de conectores)"

IA **nunca** pode ser:
- **D (Driver)**: Condução de decisões é prerrogativa humana
- **A (Approver)**: Aprovação é prerrogativa humana
- **I (Informed)**: IA não é stakeholder do projeto

---

## Responsabilidades: Técnica, Decisória e Documental

### 1. Responsabilidade Técnica

**Definição**: Garantir que implementações técnicas sejam corretas, seguras e aderentes a padrões.

**Responsável**: Sempre humano (Owner, Arquiteto, Engenheiro)

**Apoio de IA**: Análise técnica, geração de código, validação de sintaxe

**Exemplos**:
- Decisão sobre qual conector usar em integração midPoint ↔ OrangeHRM
- Validação de configurações de rede (VLANs, ACLs, firewall)
- Aprovação de scripts antes de execução em ambiente produtivo

**Regra**: IA pode **gerar** código, mas humano **valida e aprova** execução.

### 2. Responsabilidade Decisória

**Definição**: Autoridade para tomar decisões estratégicas, arquiteturais ou operacionais.

**Responsável**: Sempre humano (Owner, CISO, Aprovador formal)

**Apoio de IA**: Análise de trade-offs, comparação de alternativas, pesquisa de melhores práticas

**Exemplos**:
- Escolha entre conector DatabaseTable vs ScriptedSQL (ADR-004)
- Aprovação de GMUD para validação de CSV canônico (GMUD-023)
- Decisão sobre faseamento de roadmap de projeto

**Regra**: IA pode **recomendar**, mas humano **decide e responde**.

### 3. Responsabilidade Documental

**Definição**: Autoria e accountability por documentos técnicos e formais.

**Responsável**: Sempre humano (autor nominal identificado)

**Apoio de IA**: Redação assistida, síntese de informações, formatação

**Exemplos**:
- GMUDs formais (exemplo: GMUD-023 v1.1 - autor: Paulo Feitosa)
- ADRs (exemplo: ADR-004 - decisor: Paulo Feitosa)
- Relatórios de não-conformidade (RNCs)

**Regra**: IA pode **redigir rascunhos**, mas humano é **autor e responsável final**.

---

## Limites e Salvaguardas

### 1. IA Não é Autora Final

**Princípio**: Documentos corporativos possuem autor humano identificado.

**Regra de Documentação**:
- Metadados de documentos devem listar **humano como autor**
- Apoio de IA deve ser declarado como **ferramenta utilizada**
- Seções de aprovação devem identificar **humano como responsável**

**Exemplo Correto** (GMUD-023 v1.1):
```yaml
responsavel_tecnico: Paulo Feitosa (Owner/CISO)
apoio_tecnico: ChatGPT, Gemini (ferramentas de análise)
```

**Exemplo Incorreto**:
```yaml
responsavel_tecnico: ChatGPT (Systems Architect)
```

### 2. IA Não é Decisora

**Princípio**: Decisões técnicas, estratégicas e operacionais são prerrogativas humanas.

**Salvaguardas**:
- ADRs devem identificar **decisor humano** no campo "Aprovador"
- Matrizes DACI não podem listar IA como Driver (D) ou Approver (A)
- Logs de decisão devem rastrear **nome da pessoa**, não ferramenta

**Exemplo Correto** (ADR-004):
```
Decisor: Paulo Feitosa (Owner/CISO)
Apoio à Análise: Perplexity Pro (pesquisa), ChatGPT (análise técnica)
```

### 3. IA Não Assume Responsabilidade Legal, Ética ou Institucional

**Princípio**: Accountability é inerentemente humana.

**Situações de Responsabilidade Humana**:
- **Incidentes de segurança**: Humano responde por ações corretivas
- **Não-conformidades (RNCs)**: Humano é responsável por plano de remediation
- **Auditoria externa**: Humano explica decisões técnicas
- **Publicações externas**: Humano é autor identificável

**Salvaguardas**:
- RNCs não podem listar IA como "responsável pela correção"
- Relatórios de incidente devem identificar **humano como incident commander**
- Apresentações externas devem creditar **autor humano**

---

## Relação com ADRs e GMUDs

### 1. Architecture Decision Records (ADRs)

**Modelo de Governança**: **DACI**

**Estrutura Obrigatória**:
- **D (Driver)**: Humano que conduz análise (exemplo: Paulo Feitosa)
- **A (Approver)**: Humano que aprova decisão (exemplo: Paulo Feitosa)
- **C (Contributors)**: Humanos e/ou ferramentas de IA (exemplo: "Ferramenta de IA - análise técnica")
- **I (Informed)**: Stakeholders humanos

**Exemplo de ADR com IA** (ADR-004):
```
Driver: Paulo Feitosa (Owner/CISO)
Approver: Paulo Feitosa (Owner/CISO)
Contributors:
  - Paulo Feitosa (análise de requisitos)
  - Ferramenta de IA (comparação técnica DatabaseTable vs ScriptedSQL)
Informed: Equipe de projeto
```

### 2. Gestões de Mudança (GMUDs)

**Modelo de Governança**: **RACI**

**Estrutura Obrigatória**:
- **R (Responsible)**: Humano ou ferramenta de IA (para tarefas de execução)
- **A (Accountable)**: Sempre humano (responsável final pela GMUD)
- **C (Consulted)**: Humanos e/ou ferramentas de IA
- **I (Informed)**: Stakeholders humanos

**Exemplo de GMUD com IA** (GMUD-023 v1.1):
```
Responsável Técnico: Paulo Feitosa (Owner/CISO)
Apoio Técnico: ChatGPT, Gemini (ferramentas de análise)
Aprovador: Paulo Feitosa (Owner/CISO)
```

**Nota sobre Atividades**:
- Atividades de análise técnica podem ter "R: Ferramenta de IA"
- Atividades de validação e aprovação devem ter "A: Humano"
- Documentação deve incluir nota explicativa sobre uso de IA

### 3. Referência Obrigatória

**Princípio**: Documentos que envolvem uso de IA devem referenciar este Manifesto.

**Forma de Referência**:
```yaml
documentos_relacionados:
  - GOV-IA-001 (Manifesto de Governança de IA)
```

**Texto padrão para incluir em documentos**:
> "Ferramentas de Inteligência Artificial foram utilizadas como apoio à análise técnica e documentação, conforme Manifesto de Governança de IA (GOV-IA-001). Decisões e responsabilidades técnicas são de [Nome do Responsável Humano]."

---

## Encerramento Institucional

### Declaração de Compromisso

Este manifesto estabelece o **compromisso institucional** com uso ético, transparente e auditável de Inteligência Artificial em projetos técnicos. Ele reconhece:

1. **Valor da IA**: Ferramentas de IA ampliam produtividade, qualidade e profundidade analítica
2. **Limite da IA**: Decisão, accountability e responsabilidade institucional são prerrogativas humanas
3. **Transparência**: Uso de IA deve ser documentado e auditável
4. **Governança**: Modelos RACI e DACI garantem clareza de responsabilidades

### Aplicabilidade

Este manifesto aplica-se a:
- Projetos de laboratório (Lab Fiqueok, Living Lab)
- Documentação técnica (ADRs, GMUDs, RNCs, relatórios)
- Artigos e publicações técnicas
- Apresentações em eventos
- Futuras atividades de consultoria

### Vigência e Revisão

**Vigência**: Imediata a partir de 10/01/2026

**Revisão Obrigatória**: Anual (próxima revisão: 10/01/2027)

**Revisão Antecipada**: Se houver:
- Mudança significativa em capacidades de IA
- Novas regulamentações sobre uso de IA
- Incidentes relacionados a uso inadequado de IA
- Evolução de boas práticas de governança

### Aprovações

| Papel | Nome | Data | Status |
|-------|------|------|--------|
| **Autor** | Paulo Feitosa (Owner/CISO) | 10/01/2026 | ✅ Aprovado |
| **Apoio Documentação** | Perplexity Pro (ferramenta de análise) | 10/01/2026 | N/A |
| **Aprovador Final** | Paulo Feitosa (Owner/CISO) | [Pendente] | 🟡 Aguardando aprovação |

---

## Controle de Versão

| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Criação do Manifesto de Governança de IA - Definição de princípios, modelos RACI/DACI e limites de IA | Pendente |

---

**Documento mantido por**: Paulo Feitosa (Owner/CISO)  
**Apoio**: Perplexity Pro (ferramenta de pesquisa e documentação)  
**Repositório**: Obsidian Vault - `FiqueokBrain/20_Recursos/Governanca/`  
**Classificação**: Internal Use - Governance Framework  
**Próxima Revisão**: 10/01/2027 ou quando houver mudança significativa

---

**FIM DO MANIFESTO GOV-IA-001 v1.0**
