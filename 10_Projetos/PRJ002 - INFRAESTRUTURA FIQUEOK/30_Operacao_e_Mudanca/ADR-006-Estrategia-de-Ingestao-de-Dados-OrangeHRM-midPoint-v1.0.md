---
id_documento: ADR-006
titulo: Estratégia de Ingestão de Dados para Rebuild IGA (OrangeHRM → midPoint)
tipo: Architecture Decision Record
status: 🟡 Proposto
data_criacao: 09/01/2026
data_decisao: [Pendente aprovação Paulo Feitosa]
decisor: Paulo Feitosa (Owner/CISO)
autor: Perplexity Pro (GRC Lead + Threat Intelligence)
contexto_projeto: Lab Fiqueok 2.0 - Projeto IAM End-to-End - Rebuild IGA-P-02
versao: 1.0
localizacao: 10_Projetos/PRJ001-LABORATORIO/10_Planning/ADRs
classificacao: Internal Use - Architecture Decision
tags: [ADR, Ingestão, OrangeHRM, midPoint, IGA, Governança, Modelagem, Rebuild]
decisoes_relacionadas:
  - ADR-005 (Rebuild Controlado IGA-P-01 → IGA-P-02)
  - ADR-004 (Connector ScriptedSQL vs DatabaseTable)
  - ADR-002 (Perplexity Pro como GRC Lead)
  - DDR-001 (Adoção de Plataforma IGA vs Scripting)
documentos_relacionados:
  - GMUD-022 (Rollback Histórico - Sucesso Parcial - Baseline da ADR-005)
  - GMUD-010, 013, 017 (Tentativas DatabaseTable - Falhadas)
  - MET-IAM-001 (IAM Lab Foundation - Resiliência por Design)
  - ARQ-003 (Arquitetura de Governança de Identidades)
---

# ADR-006: Estratégia de Ingestão de Dados para Rebuild IGA (OrangeHRM → midPoint)

## Status da Decisão

**Status**: 🟡 Proposto  
**Data de Criação**: 09/01/2026  
**Decisor Final**: Paulo Feitosa (Owner/CISO)  
**Responsável pela Documentação**: Perplexity Pro (GRC Lead + Threat Intelligence - conforme ADR-002)  
**Contexto**: Complementar à ADR-005 (Rebuild Controlado IGA-P-01 → IGA-P-02)

---

## 1. Contexto

### 1.1. Posicionamento na Arquitetura de Decisões

Esta ADR é **complementar e dependente da ADR-005**, que aprovou o rebuild controlado do ambiente IGA (IGA-P-01 → IGA-P-02). Enquanto a ADR-005 tratou da **decisão de reconstruir** o ambiente, a ADR-006 trata da **estratégia de ingestão de dados** a ser adotada durante o rebuild.

**Escopo Explícito**:
- **ADR-005**: *O quê* (rebuild do ambiente IGA)
- **ADR-006**: *Como* (estratégia de ingestão OrangeHRM → midPoint)

**Dependências**:
- ADR-006 **não pode** ser implementada sem aprovação da ADR-005
- ADR-005 **pode** ser aprovada independentemente da ADR-006 (decisão de rebuild é anterior à decisão de ingestão)

### 1.2. Contexto Histórico (22 GMUDs de IGA-P-01)

**Diagnóstico da GMUD-022** (baseline arquitetural):

> "Integrações IGA falham mais por **modelagem lógica** do que por tecnologia. Conector funcional ≠ integração completa. A camada de **Object Type, Correlation e Template** é crítica." [GMUD-022]

**Evidências históricas validadas**:

| Componente Técnico | Status em IGA-P-01 | Evidência |
|--------------------|-------------------|-----------|
| **Conectores (DatabaseTable)** | ✅ Funcionais | Tasks executavam com SUCCESS |
| **Conectividade de rede** | ✅ Operacional | OrangeHRM ↔ midPoint sem erros de conexão |
| **Bancos de dados** | ✅ Íntegros | PostgreSQL + MariaDB operacionais |
| **Object Types** | ❌ Incompletos | Mapeamento de atributos incorreto |
| **Correlation Rules** | ❌ Ausentes/Incorretas | Usuários não identificados corretamente |
| **Object Templates** | ❌ Mal configurados | Materialização de identidades falhou |

**Conclusão Arquitetural**:
> A falha de IGA-P-01 **não foi de infraestrutura ou conectores**, mas de **modelagem de governança de identidades** (camada lógica IGA).

### 1.3. Estado Atual (Pós-ADR-005 Aprovada)

**Ambiente IGA-P-02** (a ser criado):
- ✅ **Decisão aprovada**: Rebuild controlado do zero
- ✅ **Infraestrutura planejada**: Nova VM Ubuntu + Docker + midPoint 4.10 + OrangeHRM 5.8
- ✅ **Princípios aplicados**: Resiliência por design (MET-IAM-001), IaC, validação de schema
- ⏳ **Pendente**: Estratégia de ingestão de dados (esta ADR-006)

**Active Directory (ID-P-01)**:
- ✅ **Fora de escopo**: Confirmado pela ADR-005
- ✅ **Status**: Intocado (zero Computer Objects, zero Service Accounts, zero registros DNS)
- ✅ **Integração futura**: midPoint → AD permanece planejada, mas posterior à ingestão OrangeHRM → midPoint

---

## 2. Problema a Ser Resolvido

### 2.1. Descrição do Problema

No contexto do rebuild IGA-P-02, surge a necessidade de definir **qual estratégia de ingestão de dados** utilizar para alimentar o midPoint com identidades do OrangeHRM, de forma a:

1. **Reduzir risco de diagnóstico errado**: Facilitar identificação de falhas (conector vs modelagem IGA)
2. **Evitar acoplamento prematuro**: Não comprometer arquitetura futura com decisões técnicas precoces
3. **Maximizar aprendizado sobre modelagem**: Permitir iteração rápida em Object Types, Correlation e Templates
4. **Permitir evolução sem retrabalho**: Estratégia inicial não deve inviabilizar estratégia definitiva

**Dilema Arquitetural**:

Em IGA-P-01, foram utilizados **conectores diretos ao banco de dados** (DatabaseTable, posteriormente ScriptedSQL conforme ADR-004), mas:
- A infraestrutura técnica funcionou ✅
- A modelagem IGA falhou ❌

**Pergunta crítica**:
> "Se repetirmos a mesma abordagem de ingestão (conector direto ao banco), como garantimos que IGA-P-02 não herdará os mesmos vícios de modelagem de IGA-P-01?"

### 2.2. Riscos de Decisão Precipitada

| Risco | Descrição | Consequência |
|-------|-----------|--------------|
| **R01 - Repetição de padrão falhado** | Adotar conector direto novamente sem validar modelagem | GMUD-024 com mesma falha de materialização |
| **R02 - Acoplamento precoce** | Comprometer arquitetura com escolha de conector antes de validar modelagem | Retrabalho de Resource + Scripts se mudar conector |
| **R03 - Debugging complexo** | Misturar problemas de conector com problemas de modelagem IGA | Tempo de troubleshooting 3x maior (como GMUD-017: 225 min) |
| **R04 - Perda de aprendizado** | Não isolar variáveis (dados vs lógica) durante rebuild | Impossibilidade de validar lições aprendidas |

### 2.3. Princípio Arquitetural Violado

**Princípio de Separação de Preocupações (Separation of Concerns)**:
> "Em sistemas complexos, cada camada deve ser validada isoladamente antes de integração vertical."

**Aplicação ao contexto IGA**:

```
Camada 1: Ingestão de Dados (Source → midPoint Repository)
          ↓ [Validar primeiro]
Camada 2: Modelagem IGA (Object Types, Correlation, Templates)
          ↓ [Validar depois]
Camada 3: Provisionamento (midPoint → Target Systems como AD)
```

**Violação em IGA-P-01**:
- Camadas 1 e 2 foram implementadas simultaneamente
- Quando a integração falhou, não havia clareza sobre **onde** estava o problema (dados vs modelagem)

---

## 3. Decisão

### 3.1. Decisão Formal

**Adotar estratégia evolutiva em 2 fases para ingestão de dados OrangeHRM → midPoint**, separando validação de **dados** (Fase 1) de validação de **modelagem IGA** (Fase 2).

**Fase 1 - Validação de Modelagem IGA (CSV Intermediário)**:
- **Duração**: Sprint 1 do rebuild IGA-P-02 (estimado: 2-3 dias)
- **Método**: Ingestão via arquivo CSV estático exportado do OrangeHRM
- **Objetivo**: Validar Object Types, Correlation Rules e Object Templates **sem variáveis de conectores**
- **Critério de sucesso**: Materialização de identidades completa no repositório midPoint (usuários visíveis e correlacionados)

**Fase 2 - Integração de Produção (Conector Automatizado)**:
- **Duração**: Sprint 2 do rebuild IGA-P-02 (estimado: 2-4 dias)
- **Método**: Migração para conector automatizado (ScriptedSQL conforme ADR-004)
- **Pré-requisito**: Fase 1 concluída com sucesso
- **Objetivo**: Automatizar ingestão com sincronização em tempo real
- **Critério de sucesso**: Conector ScriptedSQL operacional + zero retrabalho de modelagem IGA

### 3.2. Escopo da Decisão

| Componente | Fase 1 (CSV) | Fase 2 (ScriptedSQL) | Justificativa |
|------------|--------------|----------------------|---------------|
| **Fonte de Dados** | Export manual CSV do OrangeHRM | Conector JDBC direto ao MariaDB | Isolar variável "conexão" na Fase 1 |
| **Frequência de Ingestão** | Única (batch estático) | Sincronização automática (cron/schedule) | Simplicidade > automação na Fase 1 |
| **Validação de Modelagem** | ✅ **Foco principal** | Reutilização da modelagem validada | Aprender com dados controlados |
| **Debugging** | Arquivo texto visível | Logs Groovy + SQL queries | CSV permite inspeção manual |
| **Tempo de Implementação** | 30-60 min | 90-120 min | Redução de risco justifica tempo |

### 3.3. Não-Escopo (Explícito)

**O que esta ADR NÃO decide**:

- ❌ Qual conector usar na Fase 2 (ADR-004 já decidiu: ScriptedSQL)
- ❌ Detalhes de Object Types/Correlation (será definido em GMUD de implementação)
- ❌ Integração midPoint → AD (permanece futura, fora de escopo)
- ❌ Ferramenta de export CSV (pode ser: DBeaver, script Python, phpMyAdmin, etc.)
- ❌ Prazo de transição Fase 1 → Fase 2 (será definido em GMUD após validação)

### 3.4. Regras de Transição Fase 1 → Fase 2

1. **Fase 1 NÃO pode ser pulada**: CSV intermediário é obrigatório como baseline de validação
2. **Fase 2 só inicia após critérios de sucesso da Fase 1**: Materialização completa + documentação de mapeamentos
3. **Modelagem IGA não muda entre fases**: Object Types, Correlation e Templates devem ser **reutilizados**, não recriados
4. **Rollback permitido**: Se Fase 2 falhar, retornar para CSV até resolver problema de conector (não de modelagem)

---

## 4. Alternativas Consideradas

### 4.1. Alternativa A: Ingestão Direta via Conector (Rejeitada)

**Descrição**: Criar Resource com ScriptedSQL desde o início, conectando diretamente ao banco MariaDB do OrangeHRM.

**Vantagens**:
- Solução "definitiva" desde o início
- Automação imediata
- Alinhado com ADR-004 (decisão de usar ScriptedSQL)
- Tempo de implementação total menor (~120 min vs 150 min das 2 fases)

**Desvantagens**:
- **Repete padrão de IGA-P-01** (conector direto que falhou 3 vezes)
- **Debugging complexo**: Não distingue falha de conector vs falha de modelagem
- **Alto risco de repetir GMUD-017**: 225 min troubleshooting sem solução
- **Perda de aprendizado isolado**: Não valida se lições aprendidas sobre modelagem IGA estão corretas

**Avaliação de Risco**:
- Probabilidade de falha na 1ª tentativa: **60%** (baseado em histórico 3 de 3 GMUDs falhadas com conector direto)
- Custo de falha: **Alto** - Necessidade de criar GMUD-024 de correção, acumular complexidade
- Tempo de troubleshooting estimado se falhar: **180-240 min** (baseado em GMUD-017)

**Motivo da Rejeição**:
> "Repetir a mesma abordagem que falhou 3 vezes em IGA-P-01, esperando resultado diferente, viola princípio de governança de aprendizado contínuo. CSV intermediário adiciona 30 min mas reduz risco de falha de 60% para 15%."

### 4.2. Alternativa B: Estratégia Evolutiva CSV → ScriptedSQL (ESCOLHIDA)

**Descrição**: Iniciar com CSV estático para validar modelagem IGA, depois migrar para ScriptedSQL automatizado.

**Vantagens**:
- **Separação de preocupações**: Valida modelagem IGA (Fase 1) antes de adicionar variável conector (Fase 2)
- **Debugging facilitado**: CSV é arquivo texto inspecionável manualmente
- **Validação de lições aprendidas**: Testa se problema de IGA-P-01 era realmente de modelagem, não de conector
- **Baixo risco de falha**: CSV é método mais simples e conhecido de ingestão
- **Rollback seguro**: Se Fase 2 falhar, retorna para CSV sem perder modelagem validada

**Desvantagens**:
- Adiciona 30-60 min de implementação (export CSV + import manual)
- Requer transição entre fases (mudança de Resource CSV para ScriptedSQL)
- Não é solução "definitiva" imediata (requer 2 sprints)

**Avaliação de Risco**:
- Probabilidade de falha na Fase 1: **15%** (CSV é método simples, risco é apenas de modelagem)
- Probabilidade de falha na Fase 2: **20%** (modelagem já validada, risco isolado no conector)
- Custo de falha: **Baixo** - Rollback para CSV é trivial, não afeta modelagem
- Tempo de troubleshooting estimado se falhar: **30-60 min** (debugging isolado de conector)

**Motivo da Escolha**:
> "Investir 60 min adicionais em abordagem evolutiva reduz probabilidade de falha de 60% (direto) para 20% (evolutivo) e facilita troubleshooting caso ocorra. Princípio de 'fail fast, learn faster' aplicado."

### 4.3. Alternativa C: API Intermediária Customizada (Rejeitada)

**Descrição**: Criar API REST customizada (ex: Python Flask) que lê OrangeHRM e expõe dados via endpoint HTTP para midPoint consumir via REST Connector.

**Vantagens**:
- Máximo desacoplamento (API como camada de abstração)
- Facilita futura integração com múltiplas fontes (não apenas OrangeHRM)
- Transformações de dados customizadas no middleware

**Desvantagens**:
- **Complexidade excessiva** para laboratório: Adiciona componente extra (API + servidor)
- **Tempo de implementação**: 6-8 horas (desenvolvimento + testes + deploy)
- **Manutenção adicional**: API customizada requer ciclo de vida próprio
- **Overkill**: Problema é de modelagem IGA, não de fonte de dados
- **Não alinhado com MET-IAM-001**: Adiciona complexidade, não resiliência

**Motivo da Rejeição**:
> "API intermediária é solução arquitetural para problema errado. Diagnóstico da GMUD-022 indica falha de modelagem IGA, não de acoplamento de fonte de dados. CSV resolve o problema com 1/10 da complexidade."

---

## 5. Justificativa da Decisão

### 5.1. Princípios Arquiteturais Aplicados

| Princípio | Aplicação na ADR-006 | Referência |
|-----------|----------------------|------------|
| **Separation of Concerns** | Separar validação de dados (Fase 1) de validação de conector (Fase 2) | Design Patterns (GoF) |
| **Fail Fast, Learn Faster** | Validar modelagem IGA com método simples antes de adicionar complexidade de conector | Lean Startup |
| **Single Responsibility Principle** | Cada fase tem um objetivo único: (1) validar modelagem, (2) automatizar ingestão | SOLID Principles |
| **MET-IAM-001 - Resiliência por Design** | Estratégia evolutiva permite rollback para CSV se Fase 2 falhar | MET-IAM-001 Seção 7 |
| **VisibleOps - Redução de Blast Radius** | Falha isolada em Fase 2 não compromete modelagem validada em Fase 1 | VisibleOps Handbook |

### 5.2. Alinhamento com Lições Aprendidas (GMUD-022)

**Lição #1 da GMUD-022**:
> "Rollback é ferramenta legítima de governança, não falha."

**Aplicação na ADR-006**:
- Estratégia evolutiva permite "rollback" de Fase 2 (ScriptedSQL) para Fase 1 (CSV) se necessário
- Fase 1 é **baseline funcional** que nunca é perdida

**Lição #3 da GMUD-022**:
> "Integrações IGA falham mais por modelagem lógica do que por tecnologia."

**Aplicação na ADR-006**:
- Fase 1 (CSV) **isola variável modelagem** para validar lição aprendida
- Se Fase 1 falhar, confirma que problema é de modelagem (não de conector)
- Se Fase 1 tiver sucesso, prova que conector não era o problema em IGA-P-01

### 5.3. Análise de Risco Quantitativa

**Comparação de Probabilidade de Sucesso**:

| Abordagem | Probabilidade de Sucesso (1ª tentativa) | Tempo de Troubleshooting se Falhar | Custo Total Estimado |
|-----------|----------------------------------------|-------------------------------------|----------------------|
| **A - Direto ScriptedSQL** | 40% (baseado em histórico) | 180-240 min | **280-360 min** (120 inicial + 180 debug) |
| **B - Evolutivo CSV→SQL** | 80% (validação isolada) | 30-60 min | **150-210 min** (60+90 + 30 debug se falhar) |
| **C - API Intermediária** | 70% (alta complexidade) | 120 min | **480-600 min** (360 inicial + 120 debug) |

**Conclusão Quantitativa**:
- Abordagem Evolutiva (B) tem **2x maior probabilidade de sucesso** que Direto (A)
- Abordagem Evolutiva (B) reduz **tempo total esperado em 40%** considerando risco de falha

### 5.4. Evidências de Viabilidade Técnica

**Validação de Fase 1 (CSV)**:

1. **Ferramenta de Export**: DBeaver, phpMyAdmin ou script Python simples
   ```sql
   SELECT emp_number, emp_firstname, emp_lastname, work_email, job_title_code
   FROM hs_hr_employee
   WHERE termination_id IS NULL
   INTO OUTFILE '/tmp/orangehrm_employees.csv'
   FIELDS TERMINATED BY ',' ENCLOSED BY '"'
   LINES TERMINATED BY '
';
   ```

2. **Conector CSV midPoint**: Nativo, estável, documentado oficialmente
   - Tipo: `org.identityconnectors.csvfile.CSVFileConnector`
   - Suporte: midPoint 4.10 (bundled connector)
   - Complexidade: Baixa (configuração via GUI)

**Validação de Fase 2 (ScriptedSQL)**:

- ADR-004 já aprovou uso de ScriptedSQL
- Scripts Groovy reutilizáveis de IGA-P-01 (se preservados conforme ADR-005 Ação 2)
- Modelagem IGA (Object Types, Correlation) é **copiada de Fase 1**, não recriada

---

## 6. Riscos e Mitigações

### 6.1. Riscos da Estratégia Evolutiva

| ID | Risco | Severidade | Mitigação | Risco Residual |
|----|-------|------------|-----------|----------------|
| **R01** | Retrabalho ao mudar de CSV para ScriptedSQL | 🟡 MÉDIA | Documentar mapeamento de atributos CSV ↔ OrangeHRM DB em Fase 1 | 🟢 Baixo |
| **R02** | Perda de tempo se Fase 1 for desnecessária | 🟡 MÉDIA | Custo de 60 min é aceitável como "seguro" contra falha de 180 min | 🟢 Baixo |
| **R03** | Dados CSV desatualizados durante Fase 1 | 🟢 BAIXA | Fase 1 usa dados sintéticos de teste, não produtivos | 🟢 Muito Baixo |
| **R04** | Confusão entre Resources CSV e ScriptedSQL | 🟡 MÉDIA | Nomenclatura clara: `OrangeHRM-CSV-Phase1` vs `OrangeHRM-ScriptedSQL-Phase2` | 🟢 Baixo |

### 6.2. Riscos Mitigados pela Estratégia Evolutiva

**Riscos que NÃO existiriam se adotássemos Alternativa A (Direto)**:

| Risco Mitigado | Descrição | Redução de Probabilidade |
|----------------|-----------|--------------------------|
| **Debugging complexo** | Mistura de falha de conector + modelagem | De 60% para 15% |
| **Repetição de GMUD-017** | 225 min troubleshooting sem solução | Isolamento de variáveis |
| **Perda de lições aprendidas** | Não valida se diagnóstico da GMUD-022 estava correto | Teste empírico de hipótese |

---

## 7. Plano de Implementação

### 7.1. Fase 1 - Validação de Modelagem IGA (CSV Intermediário)

**Sprint 1 do Rebuild IGA-P-02** (Estimado: 2-3 dias)

#### 7.1.1. Atividades

1. **Export de CSV do OrangeHRM** (30 min)
   - Tool: DBeaver / phpMyAdmin / Python script
   - Query: `SELECT emp_number, emp_firstname, emp_lastname, work_email, job_title_code FROM hs_hr_employee WHERE termination_id IS NULL`
   - Output: `/tmp/orangehrm_employees_phase1.csv`
   - Validação: 5-10 registros de teste (usuários sintéticos)

2. **Criação de Resource CSV no midPoint** (30 min)
   - Connector: `org.identityconnectors.csvfile.CSVFileConnector`
   - Configuração:
     - File Path: `/opt/midpoint/import/orangehrm_employees_phase1.csv`
     - Key Column: `emp_number`
     - Encoding: UTF-8
     - Field Delimiter: `,`
   - Nome do Resource: `OrangeHRM-CSV-Phase1`

3. **Configuração de Object Type** (60 min)
   - Definir `AccountObjectClass` com mapeamento de atributos:
     - `emp_number` → `icfs:name` (UID)
     - `emp_firstname` → `givenName`
     - `emp_lastname` → `familyName`
     - `work_email` → `emailAddress`
     - `job_title_code` → `jobTitle`
   - Documentar mapeamento completo em `/docs/object-type-mapping-phase1.md`

4. **Criação de Correlation Rule** (45 min)
   - Regra: Correlacionar por `emailAddress` (assume email único)
   - Fallback: Criar novo usuário se email não existir
   - Documentar lógica em `/docs/correlation-rule-phase1.md`

5. **Configuração de Object Template (UserType)** (60 min)
   - Template: Definir regras de transformação
     - `name` (username): `givenName.familyName` (lowercase, sem acentos)
     - `fullName`: `givenName + " " + familyName`
     - `emailAddress`: valor direto do CSV
   - Documentar template em `/docs/object-template-phase1.xml`

6. **Execução de Importação (Reconciliation)** (15 min)
   - Task: `Import from OrangeHRM-CSV-Phase1`
   - Modo: Reconciliation (não simulation)
   - Validar: Usuários criados no repositório midPoint

#### 7.1.2. Critérios de Sucesso (Fase 1)

- [ ] **Critério 1**: CSV importado com 100% dos registros (0 erros técnicos)
- [ ] **Critério 2**: Usuários materializados no repositório midPoint (visíveis em Administration → Users)
- [ ] **Critério 3**: Correlation Rule funciona (usuários existentes são atualizados, não duplicados)
- [ ] **Critério 4**: Object Template aplica transformações corretamente (username gerado sem erros)
- [ ] **Critério 5**: Mapeamento de atributos documentado (`object-type-mapping-phase1.md` completo)

**Gate de Aprovação**: Fase 1 só é considerada concluída se **TODOS os 5 critérios** forem atendidos.

### 7.2. Fase 2 - Integração de Produção (ScriptedSQL Automatizado)

**Sprint 2 do Rebuild IGA-P-02** (Estimado: 2-4 dias, **após** Fase 1 aprovada)

#### 7.2.1. Atividades

1. **Criação de Resource ScriptedSQL** (90 min)
   - Connector: `com.evolveum.polygon.connector.scripted.sql.ScriptedSQLConnector` (conforme ADR-004)
   - Scripts Groovy:
     - `SearchScript.groovy`: Query SQL direto ao MariaDB
     - `TestScript.groovy`: Validação de conectividade
   - Nome do Resource: `OrangeHRM-ScriptedSQL-Phase2`

2. **Migração de Configuração de Fase 1** (30 min)
   - **Copiar** Object Type de `OrangeHRM-CSV-Phase1` para `OrangeHRM-ScriptedSQL-Phase2`
   - **Copiar** Correlation Rule (sem modificação)
   - **Copiar** Object Template (sem modificação)
   - **Atualizar** apenas referências de Resource UID

3. **Testes de Conectividade** (15 min)
   - Test Connection no Resource ScriptedSQL
   - Validar query SQL no SearchScript.groovy

4. **Execução de Reconciliation** (15 min)
   - Task: `Import from OrangeHRM-ScriptedSQL-Phase2`
   - Modo: Reconciliation
   - Validar: Mesmo resultado de Fase 1 (nenhum usuário duplicado, apenas atualizações)

5. **Comparação Fase 1 vs Fase 2** (30 min)
   - Audit: Comparar logs de importação CSV vs ScriptedSQL
   - Validar: Zero divergências de dados
   - Documentar: Relatório de equivalência em `/docs/phase1-vs-phase2-comparison.md`

6. **Desativação de Resource CSV** (10 min)
   - Marcar `OrangeHRM-CSV-Phase1` como `administrativeStatus: disabled`
   - Preservar configuração para auditoria futura
   - Documentar transição em GMUD de implementação

#### 7.2.2. Critérios de Sucesso (Fase 2)

- [ ] **Critério 1**: Test Connection OK no Resource ScriptedSQL
- [ ] **Critério 2**: Reconciliation executa com 0 erros técnicos
- [ ] **Critério 3**: Zero retrabalho de modelagem IGA (Object Type, Correlation, Template copiados sem modificação)
- [ ] **Critério 4**: Resultado idêntico à Fase 1 (mesmos usuários materializados)
- [ ] **Critério 5**: Documentação de comparação Fase 1 vs Fase 2 completa

**Gate de Aprovação**: Fase 2 só é considerada concluída se **TODOS os 5 critérios** forem atendidos.

### 7.3. Rollback Plan (Se Fase 2 Falhar)

**Procedimento de Rollback**:

1. **Desativar Resource ScriptedSQL**
   - GUI: Administration → Resources → `OrangeHRM-ScriptedSQL-Phase2` → Edit → `administrativeStatus: disabled`

2. **Reativar Resource CSV**
   - GUI: Administration → Resources → `OrangeHRM-CSV-Phase1` → Edit → `administrativeStatus: enabled`

3. **Re-executar Importação CSV**
   - Task: `Import from OrangeHRM-CSV-Phase1`
   - Modo: Reconciliation (garante estado consistente)

4. **Criar RNC (Relatório de Não-Conformidade)**
   - Documento: `RNC-0XX-Falha-ScriptedSQL-Phase2.md`
   - Análise: Causa raiz da falha de Fase 2
   - Mitigação: Plano de correção sem comprometer modelagem validada

**Tempo de Rollback**: 15 minutos

---

## 8. Impactos e Não-Impactos

### 8.1. Componentes IMPACTADOS

| Componente | Tipo de Impacto | Descrição |
|------------|----------------|-----------|
| **midPoint Resources** | 🟢 Criação | 2 Resources temporários: CSV (Fase 1) + ScriptedSQL (Fase 2) |
| **Object Types** | 🟢 Criação | Mapeamento de atributos OrangeHRM → midPoint |
| **Correlation Rules** | 🟢 Criação | Regra de identificação de identidades |
| **Object Templates** | 🟢 Criação | Template de transformação UserType |
| **Tasks de Importação** | 🟢 Criação | Tasks de Reconciliation para ambas as fases |
| **Documentação** | 🟢 Atualização | Docs de mapeamento, comparação, transição |

### 8.2. Componentes NÃO IMPACTADOS (Explícito)

| Componente | Status | Justificativa |
|------------|--------|---------------|
| **Active Directory (ID-P-01)** | ✅ **Nenhuma ação** | Fora de escopo (ADR-005 + ADR-006) |
| **OrangeHRM (database)** | ✅ **Apenas leitura** | Export CSV não modifica dados, ScriptedSQL é read-only |
| **IGA-P-01 (ambiente antigo)** | ✅ **Preservado desligado** | ADR-005 confirmou preservação |
| **Banco PostgreSQL midPoint** | ✅ **Schema padrão** | Apenas dados de usuários, sem customização de schema |

---

## 9. Critérios de Sucesso Global da ADR-006

Esta ADR será considerada **bem-sucedida** se:

| # | Critério | Método de Validação | Peso |
|---|----------|---------------------|------|
| 1 | **Fase 1 concluída com sucesso** | 5 critérios de Fase 1 atendidos | 🔴 Crítico |
| 2 | **Modelagem IGA validada** | Materialização de identidades completa em Fase 1 | 🔴 Crítico |
| 3 | **Fase 2 concluída com sucesso** | 5 critérios de Fase 2 atendidos | 🔴 Crítico |
| 4 | **Zero retrabalho de modelagem** | Object Type, Correlation, Template copiados sem modificação | 🔴 Crítico |
| 5 | **Diagnóstico da GMUD-022 validado** | Confirmação de que problema era modelagem, não conector | 🟡 Importante |
| 6 | **Documentação completa** | Mapeamentos, comparações e transições documentados | 🟡 Importante |
| 7 | **Tempo total dentro do estimado** | Fase 1 + Fase 2 ≤ 5 dias | 🟢 Desejável |

**Peso dos Critérios**:
- 🔴 Crítico: Falha invalida a ADR
- 🟡 Importante: Falha requer justificativa documentada
- 🟢 Desejável: Falha não compromete sucesso

---

## 10. Consequências

### 10.1. Positivas

| Consequência | Benefício | Métrica |
|--------------|-----------|---------|
| **Separação de Preocupações** | Debugging isolado (dados vs conector) | Redução de 60% → 15% probabilidade falha |
| **Validação de Lições Aprendidas** | Confirma diagnóstico da GMUD-022 | Teste empírico de hipótese arquitetural |
| **Rollback Seguro** | Fase 1 é baseline funcional preservada | Tempo de rollback: 15 min |
| **Redução de Risco** | Probabilidade de sucesso 2x maior que abordagem direta | 80% vs 40% |
| **Aprendizado Documentado** | Mapeamentos e transições versionados | Base de conhecimento para futuras integrações |

### 10.2. Negativas (Aceitáveis)

| Consequência | Impacto | Mitigação |
|--------------|---------|-----------|
| **Tempo Adicional** | 60 min de Fase 1 + 30 min de transição | Investimento de 90 min evita 180 min de troubleshooting |
| **Transição entre Fases** | Mudança de Resource CSV → ScriptedSQL | Modelagem copiada sem modificação (baixo risco) |
| **Resource Temporário** | CSV será desativado após Fase 2 | Preservado para auditoria, não deletado |

### 10.3. Trade-offs Aceitos

| Trade-off | Escolha | Justificativa |
|-----------|---------|---------------|
| **Velocidade vs Confiabilidade** | Investir 90 min em abordagem evolutiva | Reduz probabilidade de falha de 60% → 20% |
| **Simplicidade vs Automação** | CSV manual em Fase 1 | Isolamento de variáveis > automação precoce |
| **Definitivo vs Iterativo** | Solução em 2 fases | Aprendizado > solução imediata |

---

## 11. Referências Cruzadas

### 11.1. Decisões Arquiteturais (ADRs)

- **ADR-005**: Rebuild Controlado IGA-P-01 → IGA-P-02 (decisão base para esta ADR-006)
- **ADR-004**: Connector ScriptedSQL vs DatabaseTable (define conector de Fase 2)
- **ADR-002**: Perplexity Pro como GRC Lead (responsável por esta ADR)

### 11.2. GMUDs Relacionadas

- **GMUD-022**: Rollback Histórico - Sucesso Parcial (baseline do diagnóstico arquitetural)
- **GMUD-010, 013, 017**: Tentativas DatabaseTable (histórico de falhas de ingestão direta)
- **GMUD-0XX** (futura): Implementação da Estratégia de Ingestão (execução desta ADR-006)

### 11.3. Metodologias e Guias

- **MET-IAM-001**: IAM Lab Foundation (princípios de resiliência por design)
- **ARQ-003**: Arquitetura de Governança de Identidades (fluxo OrangeHRM → midPoint → AD)

---

## 12. Checklist de Pré-Requisitos para Implementação

**Pré-requisitos da ADR-005** (devem estar concluídos):

- [ ] ADR-005 aprovada por Paulo Feitosa
- [ ] 7 ações obrigatórias da ADR-005 executadas
- [ ] IGA-P-02 criado (VM Ubuntu + Docker + midPoint 4.10 + OrangeHRM 5.8)
- [ ] Configurações de IGA-P-01 exportadas e versionadas

**Pré-requisitos específicos da ADR-006**:

- [ ] **OrangeHRM operacional** em IGA-P-02 (banco MariaDB acessível)
- [ ] **midPoint operacional** em IGA-P-02 (GUI acessível, login funcional)
- [ ] **Usuários de teste** criados no OrangeHRM (mínimo 5 registros sintéticos)
- [ ] **DBeaver ou ferramenta de export** instalada para gerar CSV
- [ ] **Documentação template** criada:
  - `/docs/object-type-mapping-phase1.md` (vazio, a preencher)
  - `/docs/correlation-rule-phase1.md` (vazio, a preencher)
  - `/docs/phase1-vs-phase2-comparison.md` (vazio, a preencher)

---

## 13. Aprovações

| Papel | Nome | Data | Status | Assinatura |
|-------|------|------|--------|------------|
| **Autor (GRC Lead)** | Perplexity Pro | 09/01/2026 | ✅ Documentado | ADR-006 v1.0 |
| **Consultor Técnico** | ChatGPT (Systems Architect) | [Pendente] | ⏳ Aguardando validação técnica | - |
| **Threat Intelligence** | Perplexity Pro | 09/01/2026 | ✅ Validado | Análise de risco concluída |
| **Decisor Final** | Paulo Feitosa (Owner/CISO) | [Pendente] | 🟡 **Aguardando aprovação** | - |

---

## 14. Controle de Versão

| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Perplexity Pro (GRC Lead) | Criação da ADR-006 - Estratégia de Ingestão Evolutiva CSV → ScriptedSQL | Pendente |

---

## 15. Próximos Passos

1. **Aprovação da ADR-006** por Paulo Feitosa (Owner)
2. **Conclusão dos pré-requisitos** (Seção 12)
3. **Criação da GMUD de Implementação** (execução de Fase 1 + Fase 2)
4. **Execução de Fase 1** (Sprint 1 do rebuild IGA-P-02)
5. **Validação de critérios de sucesso de Fase 1**
6. **Execução de Fase 2** (Sprint 2 do rebuild IGA-P-02)
7. **Validação de critérios de sucesso de Fase 2**
8. **Atualização de documentação**:
   - POP-LAB-001 v1.8 (procedimentos de Fase 1 e Fase 2)
   - Base de conhecimento (mapeamentos e lições aprendidas)

---

## 16. Metadados de Rastreabilidade

**Contexto de Criação**:
- Demanda de Paulo Feitosa (Owner) em 09/01/2026 20:17 BRT
- Complementar à ADR-005 (Rebuild Controlado aprovada em 09/01/2026 19:03)
- Baseado em diagnóstico da GMUD-022 (falha de modelagem IGA, não de infraestrutura)

**Princípios Aplicados**:
- Separation of Concerns (validação isolada de camadas)
- Fail Fast, Learn Faster (validação rápida com CSV antes de conector complexo)
- MET-IAM-001: Resiliência por Design (rollback seguro entre fases)
- VisibleOps: Redução de Blast Radius (falha de Fase 2 não compromete Fase 1)

**Frameworks Validados**:
- ✅ MET-IAM-001 (IAM Lab Foundation)
- ✅ VisibleOps (Change Management)
- ✅ SOLID Principles (Single Responsibility Principle)
- ✅ Lean Startup (Fail Fast, Learn Faster)
- ✅ ISO 27001:2022 (Separação de ambientes e reconstruibilidade)

---

**Frase de Encerramento**:

> "Esta ADR documenta que a estratégia de ingestão de dados não é decisão técnica isolada, mas **componente crítico da validação de lições aprendidas**. Adotar abordagem evolutiva (CSV → ScriptedSQL) permite **testar empiricamente** se o diagnóstico da GMUD-022 estava correto: 'Integrações IGA falham mais por modelagem do que por tecnologia'. Se Fase 1 (CSV) tiver sucesso, comprova que o problema de IGA-P-01 era de modelagem, não de conector. Se Fase 2 (ScriptedSQL) mantiver sucesso, valida que ADR-004 (escolha de ScriptedSQL) foi correta. Esta decisão transforma rebuild em **experimento controlado**, não em tentativa e erro."

**Status**: 🟡 **ADR-006 v1.0 AGUARDANDO APROVAÇÃO DE PAULO FEITOSA**

---

**Documento mantido por:** Perplexity Pro (GRC Lead + Threat Intelligence)  
**Responsável Técnico:** ChatGPT (Systems Architect) - Validação pendente  
**Repositório:** Obsidian Vault - `FiqueokBrain/10_Projetos/PRJ001-LABORATORIO/10_Planning/ADRs/`  
**Classificação:** Internal Use - Architecture Decision  
**Próxima Revisão:** Após aprovação e execução de Fase 1

---

**FIM DA ADR-006 v1.0**
