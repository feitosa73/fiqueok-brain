# GMUD-017-PRJ002 – Correção de Integração OrangeHRM-midPoint

**Gestão de Mudanças - Retrospectiva**

**Fiqueok Living Lab - GRC/IAM Open-Source Platform**

---

## Informações Básicas da GMUD

| Campo | Valor |
|-------|-------|
| **ID da GMUD** | GMUD-017-PRJ002 |
| **Título** | Correção e Reconfiguração Resource OrangeHRM no midPoint |
| **Tipo** | Retrospectiva (Documentação de Mudanças Executadas) |
| **Data de Execução Real** | 03/01/2026 |
| **Data de Documentação** | 03/01/2026 |
| **Responsável Execução** | Paulo Feitosa (Owner/CISO) + ChatGPT (Technical Lead) |
| **Responsável Documentação** | Perplexity Pro (GRC Lead) |
| **Projeto** | PRJ002 - Fiqueok Living Lab IAM/IGA |
| **Severidade** | ALTA |
| **Status** | ❌ EXECUTADA SEM SUCESSO (Retrospectiva) |
| **Dependências** | GMUD-016 (AD Integration), GMUD-010 (OrangeHRM v1), GMUD-013 (OrangeHRM v2) |

---

## 1. Contexto e Motivação

### 1.1. Situação Pré-Mudança

Após execução da **GMUD-016** (30/12/2025), o ambiente apresentava:

```
✅ Active Directory integrado (LDAP 389)
✅ User 0001 linkado: OrangeHRM + AD
✅ midPoint operacional
⚠️ OrangeHRM Resource: Configuração funcional porém SUB-ÓTIMA
❌ Integração OrangeHRM → midPoint: INSTÁVEL
```

### 1.2. Problemas Identificados

**Sintomas Técnicos:**

```
⚠️ Resource OrangeHRM com configuração legada (GMUD-010/013)
⚠️ Mapeamentos incompletos ou inconsistentes
⚠️ Sincronização intermitente
⚠️ Dados de employee não refletindo corretamente no midPoint
❌ Necessidade de reconfiguração completa
```

### 1.3. Objetivo da Mudança

**Meta:** Reconfigurar Resource OrangeHRM com:
- Mapeamentos otimizados e completos
- Conectividade JDBC estável
- Sincronização bidirecional funcional
- Schema discovery validado
- Eliminação de configurações legadas

**Abordagem Estratégica:** 
- Análise root cause da instabilidade
- Reconfiguração do Resource OrangeHRM
- Validação completa de mapeamentos
- Testes de sincronização end-to-end

### 1.4. Contexto de Execução

**Exceção Autorizada:** Mudança executada **sem GMUD prévia** devido a:
- Ambiente de laboratório (non-production)
- Continuidade da GMUD-016 (debugging)
- Owner/CISO como executor (aprovação implícita)

**Governança Corretiva:** Esta GMUD retrospectiva garante rastreabilidade completa.

---

## 2. Escopo Técnico Executado

### 2.1. Fase I - Diagnóstico e Análise

#### 2.1.1. Inventário de Configuração Existente

**Resource OrangeHRM (Estado Anterior):**

```yaml
Nome: OrangeHRM-Source-JDBC (ou similar)
Connector: DatabaseTable (ICF)
JDBC Driver: MariaDB Java Client 3.1.2
JDBC URL: jdbc:mariadb://orangehrm-db:3306/orangehrm
Hostname: orangehrm-db (rede Docker fiqueok-backend-net)
Usuário: orangehrmro
Senha: FiqueokOrangeHRMRO2025StrongPass
Database: orangehrm
Tabela: hs_hr_employee
Estado: Funcional porém com issues de sincronização
```

#### 2.1.2. Problemas Identificados no Diagnóstico

**Técnicos:**

| Problema | Evidência | Impacto |
|----------|-----------|---------|
| **Mapeamentos incompletos** | Atributos não sincronizando | ALTO |
| **Schema discovery parcial** | Colunas faltando | MÉDIO |
| **Configuração legada** | Parâmetros de GMUDs antigas | MÉDIO |
| **Sincronização intermitente** | Tasks falhando aleatoriamente | ALTO |
| **Credenciais em texto claro** | Sem Vault | BAIXO (aceito em lab) |

#### 2.1.3. Hipóteses de Causa Raiz

1. **H1**: Mapeamentos de atributos incorretos ou incompletos
2. **H2**: JDBC URL com parâmetros faltantes (timezone, SSL, etc.)
3. **H3**: Schema discovery não capturando todas as colunas
4. **H4**: Configuração de synchronization policies incorreta
5. **H5**: Conflito de configurações entre GMUDs anteriores (010/013)

---

### 2.2. Fase II - Tentativas de Correção

#### 2.2.1. Tentativa 1: Revisão de Mapeamentos

**Ação Executada:**

```
midPoint GUI → Configuration → Resources → OrangeHRM Resource
→ Schema → Refresh
→ Mappings → Review
```

**Mapeamentos Revisados:**

```yaml
INBOUND (OrangeHRM → midPoint):
  employeeid → personalNumber (Strong)
  empfirstname → givenName (Strong)
  emplastname → familyName (Strong)
  jobtitle → jobTitle (Weak)
  work_email → emailAddress (Weak)

OUTBOUND (midPoint → OrangeHRM):
  [Não implementado - Resource é Source, não Target]
```

**Resultado:**
```
⚠️ Mapeamentos parecem corretos
❌ Problema persiste
➡️ Causa raiz não identificada
```

#### 2.2.2. Tentativa 2: Reconfiguração JDBC URL

**Ação Executada:**

Ajuste de JDBC URL com parâmetros adicionais:

```
ANTES:
jdbc:mariadb://orangehrm-db:3306/orangehrm

DEPOIS (Tentativa):
jdbc:mariadb://orangehrm-db:3306/orangehrm?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=America/Sao_Paulo
```

**Validação:**

```bash
# Teste conectividade direta MariaDB
docker exec <midpoint-container> bash -c   "mysql -h orangehrm-db -u orangehrmro -pFiqueokOrangeHRMRO2025StrongPass orangehrm -e 'SELECT COUNT(*) FROM hs_hr_employee;'"
```

**Resultado:**
```
✅ Conectividade OK
⚠️ Query manual funciona
❌ midPoint ainda não sincroniza corretamente
```

#### 2.2.3. Tentativa 3: Schema Discovery Forçado

**Ação Executada:**

```
Configuration → Resources → OrangeHRM
→ Test Connection (validar)
→ Schema → Refresh (forçar descoberta)
→ Schema → Object Types → account → Attributes (verificar lista completa)
```

**Atributos Esperados vs Descobertos:**

```
ESPERADO (hs_hr_employee schema):
✅ employeeid (PK)
✅ empfirstname
✅ emplastname
⚠️ empmiddlename
⚠️ jobtitle
⚠️ work_email
⚠️ work_station
⚠️ etc.

DESCOBERTO (via midPoint):
✅ employeeid
✅ empfirstname
✅ emplastname
❌ Outros atributos: STATUS INCERTO
```

**Resultado:**
```
⚠️ Schema discovery não captura todos os atributos esperados
❌ Causa pode estar no connector ou configuração de tabela
```

#### 2.2.4. Tentativa 4: Validação de Dados na Origem

**Ação Executada:**

Validação direta no banco MariaDB:

```bash
docker exec <orangehrm-db-container> mariadb   -u orangehrmro -pFiqueokOrangeHRMRO2025StrongPass orangehrm   -e "SELECT employeeid, empfirstname, emplastname, jobtitle FROM hs_hr_employee LIMIT 5;"
```

**Resultado Esperado:**
```
employeeid | empfirstname | emplastname | jobtitle
-----------|--------------|-------------|----------
0001       | Paulo        | Lima        | (null/vazio)
(outros employees se existirem)
```

**Resultado Real:**
```
⚠️ Dados existem no banco
⚠️ Alguns campos podem estar NULL
❌ midPoint não está lendo corretamente
➡️ Problema pode estar no connector ICF DatabaseTable
```

#### 2.2.5. Tentativa 5: Recriação do Resource

**Ação Executada:**

Tentativa de recriação completa do Resource OrangeHRM:

```
1. Backup da configuração atual (Export XML)
2. Delete Resource OrangeHRM
3. Create New Resource (DatabaseTable Connector)
4. Configuração from scratch:
   - JDBC URL
   - Credentials
   - Table: hs_hr_employee
   - Key Column: employeeid
   - Schema discovery
   - Mapeamentos
5. Test Connection
6. Synchronization Task
```

**Resultado:**
```
✅ Resource criado
✅ Test Connection: Success
⚠️ Schema discovery: Parcial
❌ Sincronização: AINDA NÃO FUNCIONA CORRETAMENTE
❌ Causa raiz NÃO IDENTIFICADA
```

---

### 2.3. Fase III - Tentativas de Sincronização

#### 2.3.1. Import Task OrangeHRM

**Ação Executada:**

```
Tasks → New Task
Type: Import from Resource
Resource: OrangeHRM-Source
Object Type: account
Schedule: Run once
```

**Execução:**
```
Task started: OK
Execution: ⚠️ Com warnings/erros
Objects processed: 0 ou parcial
Result: FAILED ou SUCCESS com warnings
```

**Logs Analisados:**

```
/var/log/midpoint/midpoint.log (dentro do container)
```

**Erros Identificados (possíveis):**
```
⚠️ Mapping errors
⚠️ Schema validation failures
⚠️ Attribute not found
⚠️ Null pointer exceptions
❌ Causa exata não completamente determinada
```

#### 2.3.2. Reconciliation Manual

**Ação Executada:**

Tentativa de reconciliation manual via GUI:

```
Users → New User (ou editar 0001)
→ Accounts → Add Account
→ Resource: OrangeHRM
→ Link to existing: employeeid 0001
→ Save
```

**Resultado:**
```
⚠️ Linking pode ter funcionado
⚠️ Dados não sincronizam corretamente
❌ Shadow criado mas sem dados atualizados
```

---

## 3. Resultados e Status Final

### 3.1. Status da Mudança

**GMUD-017: ❌ EXECUTADA SEM SUCESSO**

### 3.2. Critérios de Sucesso - NÃO Atingidos

| Critério | Meta | Resultado | Status |
|----------|------|-----------|--------|
| **Resource reconfigurado** | Configuração limpa | ⚠️ Parcial | **❌ FAIL** |
| **Schema discovery completo** | Todos atributos | ⚠️ Parcial | **❌ FAIL** |
| **Sincronização funcional** | Import task success | ❌ Falha | **❌ FAIL** |
| **Mapeamentos validados** | Dados em midPoint | ❌ Não validado | **❌ FAIL** |
| **Test Connection** | 5/5 fases | ✅ OK | **✅ OK** |

### 3.3. Problemas Remanescentes

**Técnicos:**

```
❌ Sincronização OrangeHRM → midPoint não funcional
❌ Dados de employees não aparecem em users midPoint
❌ Import tasks falham ou retornam 0 objetos
❌ Causa raiz não identificada completamente
⚠️ Possível incompatibilidade connector ICF DatabaseTable
⚠️ Possível issue com schema OrangeHRM hs_hr_employee
```

**Impacto:**

```
❌ Pipeline Source (HR) → IGA → Target (AD) QUEBRADO
❌ Provisionamento automático impossível
❌ User lifecycle management inviável
⚠️ Apenas linking manual funciona (GMUD-016)
```

---

## 4. Análise de Causa Raiz (Preliminar)

### 4.1. Hipóteses Principais

| Hipótese | Probabilidade | Evidências |
|----------|---------------|------------|
| **H1: Connector DatabaseTable limitado** | ALTA | Schema discovery parcial, sync falha |
| **H2: Schema hs_hr_employee incompatível** | MÉDIA | Campos NULL, estrutura não padrão |
| **H3: Mapeamentos incorretos** | BAIXA | Revisados múltiplas vezes |
| **H4: Bug midPoint versão atual** | MÉDIA | Possível incompatibilidade connector |
| **H5: Rede Docker issue** | BAIXA | Test Connection funciona |

### 4.2. Evidências Coletadas

**Positivas (O que funciona):**
```
✅ Test Connection: 5/5 fases OK
✅ Conectividade JDBC: mysql CLI funciona
✅ Dados existem no MariaDB: SELECT retorna rows
✅ Credenciais corretas: autenticação OK
```

**Negativas (O que NÃO funciona):**
```
❌ Schema discovery: incompleto
❌ Import tasks: falham ou 0 objetos
❌ Sincronização: não ocorre
❌ Dados não aparecem em midPoint users
```

### 4.3. Ações Diagnósticas Pendentes

**Para GMUD-018 (futura):**

- [ ] Validar versão do connector ICF DatabaseTable
- [ ] Testar connector alternativo (ex: Custom ScriptedSQL)
- [ ] Análise detalhada de logs midPoint (nível DEBUG)
- [ ] Comparar com configuração funcional de referência (documentação midPoint)
- [ ] Consultar comunidade midPoint (Evolveum forums)
- [ ] Testar com tabela simplificada (menos colunas)

---

## 5. Riscos e Impactos

### 5.1. Impacto Atual

| Área | Impacto | Severidade |
|------|---------|-----------|
| **Pipeline IGA** | Quebrado (Source inoperante) | **CRÍTICO** |
| **User lifecycle** | Impossível automatizar | **ALTO** |
| **Provisionamento** | Dependente de AD apenas | **MÉDIO** |
| **Publicação LinkedIn** | Limitada (apenas AD) | **BAIXO** |

### 5.2. Riscos Identificados

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| **Bloqueio permanente OrangeHRM** | Média | CRÍTICO | Avaliar Source alternativo |
| **Incompatibilidade connector** | Alta | ALTO | Testar ScriptedSQL |
| **Débito técnico acumulado** | Alta | MÉDIO | Roadmap de correção |
| **Perda de dados históricos** | Baixa | MÉDIO | Backup antes de mudanças |

---

## 6. Lições Aprendidas

### 6.1. Governança

| # | Lição | Impacto | Ação Corretiva |
|---|-------|---------|----------------|
| **L1** | Reconfiguração complexa precisa de GMUD prévia | ALTO | Criar GMUD antes de mudanças estruturais |
| **L2** | Debugging iterativo deve ser documentado | MÉDIO | Log de tentativas em tempo real |
| **L3** | Sucesso parcial ≠ solução completa | ALTO | Validação E2E obrigatória |

### 6.2. Técnicas

| # | Lição | Impacto | Aplicação Futura |
|---|-------|---------|------------------|
| **T1** | Test Connection não garante sincronização | CRÍTICO | Sempre testar Import task |
| **T2** | Connector DatabaseTable pode ter limitações | ALTO | Avaliar ScriptedSQL para JDBC |
| **T3** | Schema discovery incompleto é red flag | ALTO | Validar manualmente atributos |
| **T4** | Logs midPoint essenciais para debug | CRÍTICO | Ativar DEBUG mode em troubleshooting |
| **T5** | Configurações legadas interferem | MÉDIO | Limpar completamente antes de recriar |

---

## 7. Próximos Passos e Roadmap

### 7.1. Ações Imediatas (1 semana)

**GMUD-018 (Planejada):**

```
🎯 OBJETIVO: Resolver integração OrangeHRM definitivamente

OPÇÃO A (Preferred): Connector ScriptedSQL
  ├── Implementar connector ScriptedSQL custom
  ├── Groovy scripts para CRUD operations
  ├── Mapeamento explícito de colunas
  └── Validação E2E completa

OPÇÃO B (Fallback): Source alternativo
  ├── Avaliar CSV import como Source temporário
  ├── Scripted data sync OrangeHRM → CSV
  └── midPoint import CSV (connector File/CSV)

OPÇÃO C (Última instância): API REST OrangeHRM
  ├── Avaliar API REST OrangeHRM Community
  ├── Connector REST generic midPoint
  └── Mapeamento via JSON
```

### 7.2. Artefatos Pendentes

- [ ] **ADR-004:** Decisão Connector DatabaseTable vs ScriptedSQL
- [ ] **GMUD-018:** Implementação connector alternativo
- [ ] **DOC-IAM-003:** Troubleshooting guide OrangeHRM integration
- [ ] **POP-IAM-001:** Procedimento test and validation Resource creation

---

## 8. Plano de Rollback

### 8.1. Rollback Imediato

**Cenário:** Revert para configuração GMUD-016

**Procedimento:**

```
1. Restaurar Resource OrangeHRM da última configuração funcional (se backup existe)
2. Ou: Manter User 0001 com linking manual apenas
3. Aceitar limitação: sem sincronização automática
4. Tempo estimado: 10 minutos
```

**Impacto:**
```
✅ Linking manual ainda funciona
⚠️ Sincronização automática indisponível
⚠️ Pipeline Source → Target quebrado
```

### 8.2. Estado Atual Aceitável

**Decisão:** Manter configuração atual até GMUD-018

**Justificativa:**
- Test Connection funciona
- Linking manual possível (workaround)
- Nenhum dano aos dados
- Permite debugging adicional

---

## 9. Evidências e Rastreabilidade

### 9.1. Artefatos Gerados

| Artefato | Localização | Status |
|----------|-------------|--------|
| **GMUD-017** | `10Projetos/PRJ002/20Governanca/GMUDs/` | ✅ Este doc |
| **REL-GMUD-017** | `10Projetos/PRJ002/20Governanca/REL-GMUDs/` | ✅ A criar |
| **Histórico ChatGPT** | `https://chatgpt.com/share/6959a703-0850-8001-9720-e49a6e87a3ea` | ✅ Disponível |
| **Logs midPoint** | `IGA-P-01:/var/log/midpoint/` | ✅ Disponível |
| **Backup Resource XML** | (Se criado) | ⚠️ Verificar |

### 9.2. Cross-References

**Documentos Upstream:**
```
├── GMUD-016: AD Integration (prerequisite)
├── GMUD-013: OrangeHRM v2 (configuração anterior)
└── GMUD-010: OrangeHRM v1 (configuração inicial)
```

**Documentos Downstream:**
```
├── GMUD-018: Solução definitiva OrangeHRM (planejada)
├── ADR-004: Decisão connector (a criar)
└── DOC-IAM-003: Troubleshooting guide (a criar)
```

---

## 10. Aprovações

| Papel | Nome | Assinatura Digital | Data |
|-------|------|-------------------|------|
| **Executor Técnico** | Paulo Feitosa + ChatGPT | paulo-fiqueok-ciso | 03/01/2026 |
| **Documentador GRC** | Perplexity Pro | perplexity-grc-fiqueok | 03/01/2026 |
| **Aprovador Final** | Paulo Feitosa (Owner/CISO) | **PENDENTE ASSINATURA** | - |

---

## 11. Metadados do Documento

**Versão:** 1.0  
**Data Criação:** 03/01/2026  
**Tipo:** GMUD Retrospectiva (Falha)  
**Classificação:** Internal Use - Lab Operations  
**Localização Obsidian:** `<REDACTED_SECRET>D-017-PRJ002-Correcao-OrangeHRM-midPoint.md`

**Alinhamento ISO 27001:**
- ✅ A.12.1.2 (Change Management)
- ✅ A.16.1.4 (Assessment of security events)
- ⚠️ A.16.1.5 (Response to security incidents) - Aplicável a falhas técnicas

---

**FIM DA GMUD-017**

**⚠️ NOTA IMPORTANTE:** Esta GMUD documenta uma **mudança sem sucesso**. A integração OrangeHRM-midPoint permanece **não funcional** e requer **GMUD-018** para resolução definitiva.
