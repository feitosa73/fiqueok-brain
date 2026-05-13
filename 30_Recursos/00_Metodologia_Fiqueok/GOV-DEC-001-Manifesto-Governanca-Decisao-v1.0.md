---
id_documento: GOV-DEC-001
titulo: Manifesto de Governança de Decisão em Projetos Técnicos e Estratégicos
tipo: Política de Governança
categoria: Governança Corporativa - Tomada de Decisão
status: 🟢 Ativo
prioridade: Crítica
data_criacao: 10/01/2026
versao: 1.0
localizacao: 20_Recursos/Governanca
classificacao: Internal Use - Governance Framework
tags: [Governança, RACI, DACI, Decisão, Responsabilidade, Accountability]
documentos_relacionados:
  - GOV-IA-001 (Manifesto de Governança de IA - complementar)
---

# Manifesto de Governança de Decisão em Projetos Técnicos e Estratégicos

## Propósito

Este manifesto estabelece o **modelo formal de governança de decisão** para projetos técnicos, estratégicos e operacionais. Seu objetivo é:

1. **Declarar formalmente** o uso disciplinado de matrizes RACI e DACI como frameworks de responsabilidade
2. **Eliminar ambiguidade** sobre quem decide, quem executa e quem responde por resultados
3. **Garantir accountability** em todas as atividades e decisões relevantes
4. **Criar linguagem comum** para discussão de responsabilidades em equipes multidisciplinares
5. **Estabelecer base normativa** para Architecture Decision Records (ADRs), Gestões de Mudança (GMUDs), Procedimentos Operacionais Padrão (POPs) e outros artefatos de governança

Este documento é **independente de tecnologia, ferramenta ou metodologia específica** e pode ser reaplicado em diferentes contextos de projeto, mantendo os mesmos princípios de governança.

---

## Princípios Fundamentais

### 1. Clareza de Responsabilidade

**Princípio**: Toda atividade relevante deve ter responsável claramente identificado.

- Não há "responsabilidade compartilhada" sem definição explícita de papéis
- Cada atividade possui **um e apenas um Accountable** (responsável final)
- Múltiplos executores (Responsible) são permitidos, mas com coordenação clara
- Ambiguidade na responsabilidade é tratada como risco de governança

### 2. Decisão Única e Rastreável

**Princípio**: Toda decisão estratégica, arquitetural ou operacional deve ter um decisor identificado.

- Decisões relevantes possuem **um e apenas um Approver** (aprovador final)
- Processo decisório é conduzido por **um Driver** (facilitador do processo)
- Consenso é desejável, mas decisão final é prerrogativa do Approver
- Decisões devem ser documentadas com data, contexto e justificativa

### 3. Separação entre Decisão e Execução

**Princípio**: Quem decide não necessariamente executa; quem executa não necessariamente decide.

- **Decisão** (DACI): Escolha estratégica, trade-off, aprovação final
- **Execução** (RACI): Implementação técnica, validação, documentação
- Projetos complexos envolvem **ambos os tipos de atividade**, exigindo frameworks distintos

### 4. Transparência e Auditabilidade

**Princípio**: Responsabilidades e decisões devem ser transparentes e auditáveis.

- Matrizes RACI e DACI devem ser documentadas em artefatos formais
- Mudanças de responsabilidade requerem justificativa documentada
- Logs de decisão devem rastrear nome do decisor, data e contexto
- Auditoria de conformidade deve validar aderência aos modelos declarados

---

## RACI: Matriz de Responsabilidades para Execução

### O que é RACI?

**RACI** é uma matriz de responsabilidades que define papéis em processos de execução:

- **R (Responsible)**: Quem executa a tarefa ou atividade
- **A (Accountable)**: Quem responde pelo resultado final e tem autoridade de aprovação
- **C (Consulted)**: Quem é consultado antes da execução (comunicação bidirecional)
- **I (Informed)**: Quem é informado após a execução (comunicação unidirecional)

**Regra de ouro do RACI**:
- Pode haver múltiplos **R** (executores) para uma tarefa
- Deve haver **um e apenas um A** (accountable) por tarefa
- **C** e **I** são opcionais, mas devem ser explícitos quando aplicáveis

### Quando Usar RACI?

RACI é adequado para **processos contínuos, operacionais ou multifase** que envolvem execução técnica:

**Cenários de Aplicação**:
- **Implementação de GMUDs**: Múltiplas fases (planejamento, execução, validação, documentação)
- **Troubleshooting de Incidentes**: Análise, correção, validação, comunicação
- **Desenvolvimento de Funcionalidades**: Design, codificação, teste, deploy
- **Documentação de Processos**: Redação, revisão técnica, aprovação, publicação
- **Planejamento de Roadmaps**: Coleta de requisitos, análise de viabilidade, faseamento, monitoramento

**Características de Atividades RACI**:
- Processo **contínuo** ou **iterativo** (não pontual)
- Múltiplas **etapas sequenciais** ou **paralelas**
- Diversos **executores** com especialidades distintas
- Necessidade de **coordenação** entre áreas ou pessoas

### Por que RACI?

**Justificativa**:
1. **Execução Clara**: Define quem faz o trabalho técnico
2. **Coordenação**: Identifica interdependências entre executores
3. **Accountability**: Garante responsável final por resultados operacionais
4. **Comunicação**: Define quem consultar antes e informar depois

**Exemplo de Uso** (Implementação de GMUD):

| Atividade | Arquiteto | Operador | Gestor de Mudança | CISO |
|-----------|-----------|----------|-------------------|------|
| Planejamento técnico | R | C | A | I |
| Execução de scripts | C | R | I | I |
| Validação pós-deploy | R | R | C | A |
| Documentação final | C | I | R | A |

**Leitura da Matriz**:
- **Planejamento técnico**: Arquiteto executa (R), Operador é consultado (C), Gestor aprova (A), CISO é informado (I)
- **Execução de scripts**: Operador executa (R), Arquiteto é consultado (C), outros são informados (I)
- **Validação pós-deploy**: Arquiteto e Operador validam (R), CISO aprova resultado final (A)

---

## DACI: Framework de Decisão Estratégica

### O que é DACI?

**DACI** é um framework de decisão que define papéis em processos decisórios:

- **D (Driver)**: Quem conduz o processo de decisão (coleta informações, facilita discussão, sintetiza opções)
- **A (Approver)**: Quem aprova a decisão final (único decisor com poder de veto)
- **C (Contributors)**: Quem contribui com informações, análises e recomendações
- **I (Informed)**: Quem é informado após a decisão (stakeholders afetados)

**Regra de ouro do DACI**:
- Deve haver **um e apenas um D** (driver do processo)
- Deve haver **um e apenas um A** (approver final)
- Pode haver múltiplos **C** (contributors), mas devem ser limitados para evitar paralisia
- **I** inclui todos os afetados pela decisão

### Quando Usar DACI?

DACI é adequado para **decisões pontuais, estratégicas ou arquiteturais** que envolvem escolhas críticas:

**Cenários de Aplicação**:
- **Architecture Decision Records (ADRs)**: Escolha de tecnologias, padrões arquiteturais, conectores
- **Decisões de Estratégia**: Definição de roadmap, priorização de projetos, alocação de orçamento
- **Trade-offs Críticos**: Performance vs. Segurança, Custo vs. Qualidade, Velocidade vs. Conformidade
- **Resolução de Conflitos**: Divergências entre áreas, mudanças de escopo, exceções a políticas
- **Definição de Políticas**: Padrões corporativos, normas de segurança, processos de governança

**Características de Decisões DACI**:
- Decisão **pontual** (não processo contínuo)
- Impacto **estratégico** ou **arquitetural**
- Envolve **trade-offs** explícitos entre alternativas
- Requer **aprovação formal** de autoridade competente

### Por que DACI?

**Justificativa**:
1. **Decisão Clara**: Define quem tem autoridade final
2. **Eficiência**: Driver único evita paralisia decisória
3. **Contribuição Estruturada**: Contributors fornecem análises sem diluir responsabilidade
4. **Rastreabilidade**: Decisões documentadas com aprovador identificado

**Exemplo de Uso** (Escolha de Conector para Integração):

| Papel | Pessoa/Área | Responsabilidade |
|-------|-------------|------------------|
| **D (Driver)** | Arquiteto de Soluções | Conduz análise técnica, compara alternativas (DatabaseTable vs ScriptedSQL), sintetiza recomendação |
| **A (Approver)** | CISO | Aprova decisão final considerando segurança, governança e custo operacional |
| **C (Contributors)** | Engenheiro de DevOps | Contribui com análise de manutenibilidade e debugging |
| **C (Contributors)** | Especialista em IGA | Contribui com boas práticas de governança de identidades |
| **I (Informed)** | Equipe de Operações | Informada sobre conector escolhido para suporte operacional |

**Leitura do Framework**:
- **Driver (Arquiteto)**: Pesquisa, analisa, documenta opções, facilita discussão
- **Approver (CISO)**: Recebe recomendação, questiona se necessário, decide e assume accountability
- **Contributors**: Fornecem inputs específicos sem autoridade decisória
- **Informed**: Recebe comunicação após decisão para alinhamento

---

## RACI e DACI: Quando Usar Cada Um?

### Diferenças Fundamentais

| Aspecto | RACI | DACI |
|---------|------|------|
| **Natureza** | Processo de execução | Processo de decisão |
| **Duração** | Contínuo ou multifase | Pontual |
| **Foco** | Quem faz o quê | Quem decide o quê |
| **Múltiplos Responsáveis** | Sim (múltiplos R) | Não (único D e único A) |
| **Saída** | Entregável técnico ou operacional | Decisão documentada |
| **Artefato Típico** | GMUD, POP, Checklist | ADR, Política, Padrão |

### Coexistência RACI + DACI

**Princípio**: RACI e DACI **não competem**, mas se **complementam**.

**Projetos complexos envolvem ambos**:
1. **Decisão Estratégica (DACI)**: "Qual conector usar para integração?" → ADR-004
2. **Execução Técnica (RACI)**: "Como implementar o conector escolhido?" → GMUD-018

**Exemplo de Sequência**:
1. **DACI**: CISO aprova uso de ScriptedSQL (ADR-004)
2. **RACI**: Arquiteto planeja (R), Operador executa (R), Gestor de Mudança aprova implementação (A)

**Regra de Transição**:
- ADR (DACI) estabelece **decisão**
- GMUD (RACI) implementa **execução**
- ADR é **pré-requisito** de GMUD quando decisão arquitetural está envolvida

---

## Papéis e Responsabilidades

### Papéis em RACI

#### R (Responsible) - Executor

**Definição**: Pessoa ou equipe que executa a tarefa.

**Responsabilidades**:
- Realizar o trabalho técnico ou operacional
- Entregar resultado conforme especificação
- Comunicar progresso e impedimentos
- Consultar stakeholders marcados como (C)

**Pode haver múltiplos R**: Sim (coordenação necessária)

**Exemplo**: Engenheiro de DevOps executa script de deploy, Arquiteto executa validação técnica

#### A (Accountable) - Responsável Final

**Definição**: Pessoa que responde pelo resultado final e tem autoridade de aprovação.

**Responsabilidades**:
- Garantir que tarefa seja concluída conforme critérios de aceitação
- Aprovar entregável final
- Assumir accountability em caso de falha
- Resolver impedimentos escalados

**Pode haver múltiplos A**: **NÃO** (apenas um por tarefa)

**Exemplo**: Gestor de Mudança aprova GMUD completa, CISO aprova mudanças críticas em produção

#### C (Consulted) - Consultado

**Definição**: Pessoa cujo input é necessário antes da execução.

**Responsabilidades**:
- Fornecer expertise técnica ou conhecimento de contexto
- Validar proposta antes de execução
- Comunicação **bidirecional** (pode questionar e recomendar ajustes)

**Pode haver múltiplos C**: Sim (mas limitados para evitar gargalos)

**Exemplo**: Especialista em segurança consultado sobre configuração de firewall

#### I (Informed) - Informado

**Definição**: Pessoa que precisa ser informada sobre progresso ou resultado.

**Responsabilidades**:
- Receber comunicação sobre status ou conclusão
- Comunicação **unidirecional** (não participa da execução)
- Alinhar planos futuros com base em informação recebida

**Pode haver múltiplos I**: Sim (stakeholders afetados)

**Exemplo**: Equipe de suporte informada sobre nova funcionalidade deployada

---

### Papéis em DACI

#### D (Driver) - Condutor do Processo

**Definição**: Pessoa responsável por conduzir o processo decisório até conclusão.

**Responsabilidades**:
- Identificar necessidade de decisão
- Coletar informações e análises de Contributors
- Facilitar discussões e síntese de opções
- Apresentar recomendação ao Approver
- Comunicar decisão aos Informed

**Pode haver múltiplos D**: **NÃO** (apenas um driver por decisão)

**Exemplo**: Arquiteto de Soluções conduz análise de alternativas de conector (DatabaseTable vs ScriptedSQL)

#### A (Approver) - Aprovador Final

**Definição**: Pessoa com autoridade para tomar decisão final.

**Responsabilidades**:
- Avaliar recomendação do Driver
- Questionar premissas e trade-offs se necessário
- Tomar decisão final (aprovar, rejeitar ou solicitar ajustes)
- Assumir accountability pela decisão

**Pode haver múltiplos A**: **NÃO** (apenas um aprovador por decisão)

**Exemplo**: CISO aprova escolha de tecnologia para integração crítica

#### C (Contributors) - Contribuidores

**Definição**: Pessoas que fornecem informações, análises ou recomendações.

**Responsabilidades**:
- Fornecer expertise técnica ou conhecimento de domínio
- Analisar trade-offs sob perspectiva específica (segurança, custo, performance)
- Recomendar alternativas sem autoridade decisória

**Pode haver múltiplos C**: Sim (mas limitados a especialistas essenciais)

**Exemplo**: Engenheiro de DevOps contribui com análise de manutenibilidade, Especialista em GRC contribui com análise de conformidade

#### I (Informed) - Informados

**Definição**: Pessoas afetadas pela decisão que precisam ser comunicadas.

**Responsabilidades**:
- Receber comunicação sobre decisão tomada
- Alinhar planos operacionais com nova direção
- Não participam do processo decisório

**Pode haver múltiplos I**: Sim (todos os stakeholders afetados)

**Exemplo**: Equipe de Operações informada sobre conector escolhido para preparar suporte

---

## Governança de Decisão: Princípios Operacionais

### 1. Toda Decisão Relevante Deve Ter um Accountable

**Definição de Decisão Relevante**:
- Impacta arquitetura técnica ou estratégia de projeto
- Envolve trade-offs críticos (segurança vs. performance, custo vs. qualidade)
- Requer investimento significativo (tempo, dinheiro, pessoas)
- Afeta múltiplas áreas ou sistemas
- Define padrões ou políticas de longo prazo

**Princípio**: Decisões relevantes não podem ser "compartilhadas" sem Approver explícito.

**Salvaguardas**:
- ADRs devem identificar **Approver nominal** (nome e cargo)
- Decisões sem Approver identificado são consideradas **não formalizadas**
- Logs de decisão rastreiam **data, contexto e aprovador**

**Exemplo de Formalização**:
```
ADR-004: Escolha de Conector OrangeHRM → midPoint
Driver: Paulo Feitosa (Arquiteto de Soluções)
Approver: Paulo Feitosa (CISO)
Data: 03/01/2026
Status: Aprovado
```

### 2. Toda Execução Deve Ter Responsável Definido

**Definição de Execução Relevante**:
- Implementação técnica de mudanças em ambientes
- Validação de funcionalidades ou integrações
- Documentação de processos ou arquitetura
- Troubleshooting de incidentes
- Deploy de serviços ou aplicações

**Princípio**: Execuções relevantes não podem ficar sem Accountable (A) identificado.

**Salvaguardas**:
- GMUDs devem identificar **Responsável Técnico nominal** (Accountable)
- Atividades críticas devem ter **Responsible (R) e Accountable (A) explícitos**
- Matrizes RACI devem ser documentadas na seção de responsabilidades da GMUD

**Exemplo de Formalização**:
```
GMUD-023: Validação de Materialização de Identidades via CSV
Responsável Técnico (Accountable): Paulo Feitosa (Owner/CISO)
Execução Técnica (Responsible): Equipe de IGA
Validação (Consulted): Especialista em midPoint
```

### 3. Ambiguidade é Risco de Governança

**Princípio**: Falta de clareza sobre responsabilidades é tratada como risco a ser mitigado.

**Situações de Risco**:
- Múltiplos Accountables (A) para mesma tarefa → **Conflito de autoridade**
- Nenhum Accountable (A) identificado → **Falta de ownership**
- Driver (D) e Approver (A) ausentes em decisão estratégica → **Decisão informal**
- Responsible (R) ausente em atividade crítica → **Gargalo de execução**

**Mitigação**:
- Revisão obrigatória de matrizes RACI/DACI em reuniões de kickoff
- Validação de ADRs e GMUDs antes de aprovação final
- Escalação de ambiguidades para decisor de nível superior

### 4. Delegação Deve Ser Explícita

**Princípio**: Transferência de responsabilidade requer documentação formal.

**Situações de Delegação**:
- Accountable (A) delega execução para Responsible (R): **Normal** (RACI padrão)
- Approver (A) delega decisão para outro Approver: **Requer atualização de ADR**
- Driver (D) transfere condução para outro Driver: **Requer atualização de DACI**

**Salvaguardas**:
- Delegações devem ser registradas em documentos (ADR, GMUD, log de decisão)
- Accountable original permanece informado (papel I) mesmo após delegação
- Delegação temporária (ex: férias) requer backup nomeado

**Exemplo de Delegação Formal**:
```
ADR-005: Rebuild Controlado IGA-P-01 → IGA-P-02
Approver Original: Paulo Feitosa (CISO)
Delegação: N/A (decisão crítica não delegável)

GMUD-023: Validação CSV Canônico
Accountable Original: Paulo Feitosa (Owner/CISO)
Delegação Temporária: N/A (execução sob supervisão direta)
```

---

## Relação com ADRs e GMUDs

### Architecture Decision Records (ADRs)

**Modelo de Governança**: **DACI obrigatório**

**Estrutura Mínima Obrigatória**:
```yaml
id_documento: ADR-XXX
titulo: [Nome da Decisão]
status: [Proposto / Aprovado / Rejeitado / Substituído]
data: [DD/MM/AAAA]
driver: [Nome e Cargo do Condutor]
approver: [Nome e Cargo do Aprovador]
contributors: [Lista de Contribuidores]
informed: [Lista de Informados]
```

**Seções Obrigatórias em ADR**:
1. **Contexto**: Por que a decisão é necessária?
2. **Opções Avaliadas**: Quais alternativas foram consideradas?
3. **Decisão**: Qual opção foi escolhida? (aprovada por Approver)
4. **Justificativa**: Por que esta opção foi escolhida?
5. **Consequências**: Quais impactos positivos e negativos?
6. **DACI Explícito**: Matriz com D, A, C, I identificados

**Validação de Qualidade de ADR**:
- [ ] Approver identificado nominalmente
- [ ] Driver conduziu análise e apresentou recomendação
- [ ] Contributors listados com expertise declarada
- [ ] Informed inclui stakeholders afetados
- [ ] Decisão possui data e status (Aprovado/Rejeitado)

### Gestões de Mudança (GMUDs)

**Modelo de Governança**: **RACI obrigatório**

**Estrutura Mínima Obrigatória**:
```yaml
id_documento: GMUD-XXX
titulo: [Nome da Mudança]
status: [Proposta / Aprovada / Em Execução / Concluída]
data_criacao: [DD/MM/AAAA]
responsavel_tecnico: [Nome e Cargo do Accountable]
aprovador: [Nome e Cargo do Aprovador Final]
```

**Seções Obrigatórias em GMUD**:
1. **Objetivo**: O que será implementado?
2. **Escopo**: Quais atividades estão incluídas/excluídas?
3. **Atividades**: Lista detalhada de tarefas
4. **Matriz RACI**: Responsabilidades por atividade
5. **Critérios de Sucesso**: Como validar conclusão?
6. **Plano de Rollback**: Como reverter se necessário?

**Validação de Qualidade de GMUD**:
- [ ] Accountable (A) identificado para cada atividade crítica
- [ ] Responsible (R) identificado para execução técnica
- [ ] Consulted (C) listados para validações necessárias
- [ ] Informed (I) inclui stakeholders afetados
- [ ] Aprovador final da GMUD identificado nominalmente

### Procedimentos Operacionais Padrão (POPs)

**Modelo de Governança**: **RACI recomendado**

**Aplicação de RACI em POPs**:
- POPs definem **processos recorrentes** (ex: Cold Start Diário, Gestão de Vulnerabilidades)
- RACI identifica **papéis genéricos** (não pessoas específicas)
- Exemplo: "R: Operador de Infraestrutura", "A: Gestor de Mudança"

**Estrutura Recomendada**:
1. **Objetivo do POP**: Qual processo está sendo padronizado?
2. **Escopo**: Quais atividades estão cobertas?
3. **Matriz RACI**: Responsabilidades por papel (não por pessoa)
4. **Procedimento Detalhado**: Passo a passo de execução
5. **Critérios de Sucesso**: Como validar conclusão?

---

## Encerramento Institucional

### Declaração de Compromisso

Este manifesto estabelece o **compromisso institucional** com governança de decisão clara, auditável e rastreável em todos os projetos técnicos e estratégicos. Ele reconhece:

1. **Necessidade de Clareza**: Ambiguidade em responsabilidades é fonte de risco e ineficiência
2. **Complementaridade RACI/DACI**: Projetos complexos exigem frameworks distintos para execução e decisão
3. **Accountability Humana**: Decisões e execuções relevantes devem ter responsável nominal identificado
4. **Auditabilidade**: Matrizes RACI e DACI garantem rastreabilidade de responsabilidades

### Aplicabilidade

Este manifesto aplica-se a:
- **Projetos Técnicos**: Laboratórios, provas de conceito, implementações de infraestrutura
- **Projetos Estratégicos**: Definição de roadmaps, priorização de iniciativas, alocação de orçamento
- **Documentação Formal**: ADRs, GMUDs, POPs, políticas corporativas, padrões técnicos
- **Artigos e Estudos de Caso**: Publicações técnicas que descrevem processos decisórios
- **Futuras Consultorias**: Projetos de clientes que requerem governança formal

### Vigência e Revisão

**Vigência**: Imediata a partir de 10/01/2026

**Revisão Obrigatória**: Anual (próxima revisão: 10/01/2027)

**Revisão Antecipada**: Se houver:
- Mudança organizacional significativa (fusão, reestruturação)
- Novas regulamentações sobre governança corporativa
- Incidentes relacionados a ambiguidade de responsabilidades
- Evolução de boas práticas de gestão de projetos

### Conformidade e Auditoria

**Princípio de Conformidade**: Todos os artefatos formais (ADRs, GMUDs, POPs) devem:
1. Referenciar este manifesto nos metadados
2. Declarar modelo de governança utilizado (RACI ou DACI)
3. Documentar matriz de responsabilidades explicitamente

**Auditoria de Conformidade**:
- Revisão trimestral de ADRs e GMUDs para validar presença de DACI/RACI
- Identificação de artefatos sem Accountable/Approver definido
- Correção de ambiguidades identificadas em auditoria

**Exceções**:
- Documentos técnicos de baixo impacto (ex: tutoriais, checklists simples) podem dispensar RACI/DACI formal
- Exceções devem ser justificadas documentalmente

### Aprovações

| Papel | Nome | Data | Status |
|-------|------|------|--------|
| **Autor** | Paulo Feitosa (Owner/CISO) | 10/01/2026 | ✅ Documentado |
| **Aprovador Final** | Paulo Feitosa (Owner/CISO) | [Pendente] | 🟡 Aguardando aprovação |

---

## Controle de Versão

| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Criação do Manifesto de Governança de Decisão - Definição de RACI, DACI, princípios operacionais e relação com ADRs/GMUDs | Pendente |

---

**Documento mantido por**: Paulo Feitosa (Owner/CISO)  
**Repositório**: Obsidian Vault - `FiqueokBrain/20_Recursos/Governanca/`  
**Classificação**: Internal Use - Governance Framework  
**Próxima Revisão**: 10/01/2027 ou quando houver mudança significativa

---

**FIM DO MANIFESTO GOV-DEC-001 v1.0**
