---
id_documento: GMUD-023
titulo: Validação de Materialização de Identidades via CSV Canônico (Fase 1 - ADR-006)
tipo: Gestão de Mudança (Change Management)
categoria: Mudança Padrão - Validação Técnica
status: 🟡 Proposta
prioridade: Alta
data_criacao: 09/01/2026
janela_execucao: [A definir após aprovação]
duracao_estimada: 3-4 horas
responsavel_tecnico: Paulo Feitosa (Owner/CISO)
apoio_tecnico: ChatGPT, Gemini (ferramentas de análise)
responsavel_grc: Paulo Feitosa (Owner/CISO)
apoio_grc: Perplexity Pro (ferramenta de pesquisa)
aprovador: Paulo Feitosa (Owner/CISO)
ambiente: IGA-P-01 (xxx.xxx.xxx.xxx) - Ambiente Descartável
impacto: Muito Baixo (ambiente isolado, sem dados produtivos)
versao: 1.1
localizacao: 10_Projetos/PRJ001-LABORATORIO/20_Governanca/GMUDs
classificacao: Internal Use - Change Management
tags: [GMUD, Validação, IGA, CSV, Modelagem, Fase1, ADR-006]
decisoes_relacionadas:
  - ADR-006 (Estratégia de Ingestão de Dados - Fase 1)
  - ADR-005 (Rebuild Controlado IGA-P-01 → IGA-P-02)
  - ADR-004 (Connector ScriptedSQL vs DatabaseTable)
documentos_relacionados:
  - GMUD-022 (Rollback Histórico - Sucesso Parcial)
  - MET-IAM-001 (IAM Lab Foundation)
  - ARQ-003 (Arquitetura de Governança de Identidades)
---

# GMUD-023: Validação de Materialização de Identidades via CSV Canônico (Fase 1 - ADR-006)

## Status da GMUD

**Status**: 🟡 Proposta (Aguardando Aprovação)  
**Data de Criação**: 09/01/2026  
**Aprovador Final**: Paulo Feitosa (Owner/CISO)  
**Responsável Técnico**: Paulo Feitosa (Owner/CISO)  
**Apoio Técnico**: ChatGPT, Gemini (ferramentas de análise)  
**Apoio GRC**: Perplexity Pro (ferramenta de pesquisa)

---

## 1. Identificação da Mudança

| Campo | Valor |
|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-|
| **ID da GMUD** | GMUD-023 |
| **Título** | Validação de Materialização de Identidades via CSV Canônico (Fase 1 - ADR-006) |
| **Categoria** | Mudança Padrão - Validação Técnica |
| **Tipo** | Implementação Controlada |
| **Prioridade** | Alta |
| **Ambiente** | IGA-P-01 (xxx.xxx.xxx.xxx) - **Ambiente Descartável** |
| **Impacto** | Muito Baixo (ambiente isolado, sem dados produtivos) |
| **Janela de Execução** | [A definir após aprovação] (Estimado: 1 dia útil) |
| **Duração Estimada** | 3-4 horas (incluindo validações) |
| **Rollback** | N/A (ambiente descartável, snapshot pré-execução disponível) |

---

## 2. Contexto

### 2.1. Histórico de Decisões Arquiteturais

**ADR-005 - Rebuild Controlado** (Aprovada em 09/01/2026 19:03):
- Decisão: Criar novo ambiente IGA-P-02 do zero, preservando IGA-P-01 como artefato histórico
- Princípio: Rebuild como estratégia arquitetural planejada (resiliência por design - MET-IAM-001)
- Status: IGA-P-02 ainda **não criado** (criação pendente de conclusão da Fase 1 da ADR-006)

**ADR-006 - Estratégia de Ingestão de Dados** (Proposta em 09/01/2026):
- Decisão: Estratégia evolutiva em 2 fases
  - **Fase 1 (esta GMUD)**: CSV Intermediário para validar modelagem IGA
  - **Fase 2 (futura)**: ScriptedSQL para integração automatizada
- Princípio: Separation of Concerns - validar dados isoladamente de conectores

**GMUD-022 - Diagnóstico Base** (06/01/2026):
> "Integrações IGA falham mais por **modelagem lógica** do que por tecnologia. Conector funcional ≠ integração completa. A camada de **Object Type, Correlation e Template** é crítica."

**Evidências Históricas (22 GMUDs de IGA-P-01)**:
- ✅ Conectores técnicos funcionaram (DatabaseTable + ScriptedSQL)
- ✅ Conectividade de rede operacional (OrangeHRM ↔ midPoint)
- ✅ Bancos de dados íntegros (PostgreSQL + MariaDB)
- ❌ **Materialização de identidades falhou** (Object Types, Correlation, Templates incorretos)

### 2.2. Ambiente Atual (IGA-P-01)

**Status**: Operacional após GMUD-022 (Rollback Histórico)

**Componentes Ativos**:
- midPoint 4.10 (porta 8080)
- PostgreSQL 16 (repositório midPoint)
- OrangeHRM 5.8 (porta 8081) - **NÃO será utilizado nesta GMUD**
- MariaDB 11.4 (OrangeHRM DB) - **NÃO será utilizado nesta GMUD**

**Declaração de Ambiente Descartável**:
> IGA-P-01 é tratado como **ambiente descartável** para fins de validação técnica. O valor desta GMUD reside nas **evidências, conclusões e modelagem validada**, não no estado final do ambiente. IGA-P-01 será eventualmente substituído por IGA-P-02 conforme ADR-005.

### 2.3. Pergunta Crítica desta GMUD

**Pergunta a ser respondida**:
> "Com dados simples, explícitos e estáveis (CSV), o motor IGA midPoint cria corretamente objetos UserType no repositório?"

**Hipótese a validar** (baseada em GMUD-022):
> "A falha de materialização de identidades em IGA-P-01 foi causada por modelagem incorreta de Object Types, Correlation Rules e Object Templates, **não por falha de conectores ou infraestrutura**."

---

## 3. Objetivo da GMUD-023

### 3.1. Objetivo Principal

Validar a **materialização de identidades** no repositório midPoint a partir de um **dataset canônico controlado (CSV)**, isolando completamente a camada de **governança de identidade** (Object Types, Correlation, Templates) da camada de **automação de conectores** (ScriptedSQL, DatabaseTable, APIs).

### 3.2. Objetivos Específicos

1. **Criar Golden Data Set**: Definir modelo canônico mínimo de identidade em CSV estático
2. **Validar Object Type**: Confirmar mapeamento correto de atributos CSV → midPoint
3. **Validar Correlation Rule**: Confirmar identificação unívoca de identidades
4. **Validar Object Template**: Confirmar transformações de dados (ex: geração de username)
5. **Validar Focus Type**: Confirmar criação de objetos UserType no repositório
6. **Documentar Modelagem**: Registrar evidências de mapeamentos validados para reutilização em IGA-P-02

### 3.3. Não-Objetivos (Explícito)

**Esta GMUD NÃO tem como objetivo**:
- ❌ Integrar OrangeHRM em tempo real (reservado para Fase 2 da ADR-006)
- ❌ Utilizar conector ScriptedSQL (reservado para Fase 2 da ADR-006)
- ❌ Utilizar API REST intermediária (fora de escopo conforme ADR-006)
- ❌ Executar provisionamento para sistemas alvo (ex: Active Directory)
- ❌ Resolver ciclo completo Joiner/Mover/Leaver (fora de escopo)
- ❌ Criar ou modificar ambiente IGA-P-02 (criação pendente de sucesso desta GMUD)
- ❌ Validar performance de sincronização em tempo real (não aplicável a CSV estático)

---

## 4. Escopo da Mudança

### 4.1. Incluído no Escopo

| # | Item | Descrição | Tipo de Atividade |
|---|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente ||| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-----|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-|
| 1 | **Golden Data Set (CSV)** | Criação de dataset canônico com 5-10 identidades sintéticas | Configuração |
| 2 | **Resource CSV** | Configuração de Resource midPoint com CSV File Connector | Configuração |
| 3 | **Object Type** | Definição de mapeamento de atributos CSV → AccountObjectClass | Modelagem IGA |
| 4 | **Correlation Rule** | Criação de regra de identificação unívoca de identidades | Modelagem IGA |
| 5 | **Object Template (UserType)** | Definição de transformações (ex: geração de username) | Modelagem IGA |
| 6 | **Focus Type** | Configuração de tipo de foco (UserType) no Resource | Modelagem IGA |
| 7 | **Task de Importação** | Criação e execução de Task de Reconciliation | Execução |
| 8 | **Validação de Materialização** | Confirmação de usuários criados no repositório midPoint | Validação |
| 9 | **Documentação de Evidências** | Registro de mapeamentos, logs e screenshots | Documentação |

### 4.2. Fora de Escopo (Explícito)

| # | Item | Justificativa |
|---|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente ||| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|
| 1 | Integração com banco MariaDB (OrangeHRM) | Reservado para Fase 2 da ADR-006 (ScriptedSQL) |
| 2 | Conector ScriptedSQL | ADR-006 define uso apenas em Fase 2 |
| 3 | Conector DatabaseTable | ADR-004 substituiu por ScriptedSQL (Fase 2) |
| 4 | API REST intermediária | ADR-006 rejeitou Alternativa C |
| 5 | Provisionamento para Active Directory | Integração futura, fora de escopo de ADR-006 |
| 6 | Sincronização em tempo real | CSV é dataset estático (batch único) |
| 7 | Ciclo Joiner/Mover/Leaver completo | Fora de escopo de validação de materialização |
| 8 | Criação de IGA-P-02 | Pendente de sucesso desta GMUD (ADR-005) |
| 9 | Migração de configurações IGA-P-01 → IGA-P-02 | Posterior a esta GMUD |

---

## 5. Atividades

### 5.1. Fase 1 - Preparação de Dataset Canônico

**Duração Estimada**: 30 minutos

#### Atividade 1.1: Definir Modelo Canônico Mínimo de Identidade

**Responsável**: Paulo Feitosa (Owner/CISO)

**Descrição**: Definir estrutura mínima de identidade compatível com midPoint UserType.

**Atributos Obrigatórios**:
- `emp_number` (UID - identificador único)
- `emp_firstname` (givenName)
- `emp_lastname` (familyName)
- `work_email` (emailAddress)
- `job_title` (jobTitle - opcional)

**Regras de Negócio**:
- UID deve ser único (sem duplicatas no CSV)
- Email deve ser único (usado como chave de correlação)
- Nomes devem conter apenas caracteres ASCII (evitar problemas de encoding)

**Entregável**: `/docs/GMUD-023-canonical-identity-model.md`

#### Atividade 1.2: Criar Dataset CSV Controlado

**Responsável**: Paulo Feitosa (Owner/CISO)

**Descrição**: Criar arquivo CSV com 5-10 identidades sintéticas para validação.

**Formato**:
```csv
emp_number,emp_firstname,emp_lastname,work_email,job_title
001,Paulo,Feitosa,paulo.feitosa@fiqueok.local,CISO
002,Carlos,Silva,carlos.silva@fiqueok.local,Security Analyst
003,Ana,Santos,ana.santos@fiqueok.local,IAM Specialist
004,Roberto,Lima,roberto.lima@fiqueok.local,GRC Lead
005,Mariana,Costa,mariana.costa@fiqueok.local,SOC Analyst
```

**Validações**:
- [ ] Encoding UTF-8 sem BOM
- [ ] Delimitador: vírgula (`,`)
- [ ] Campos entre aspas duplas se contiverem vírgula
- [ ] Nenhum campo vazio (usar "N/A" se necessário)

**Localização**: `/opt/midpoint/import/gmud-023-golden-dataset.csv`

**Entregável**: Arquivo CSV validado + checksum SHA256

#### Atividade 1.3: Validar Integridade do CSV

**Responsável**: Paulo Feitosa (Owner/CISO)

**Descrição**: Executar validações técnicas no CSV.

**Comandos**:
```bash
# Validar encoding
file /opt/midpoint/import/gmud-023-golden-dataset.csv
# Esperado: UTF-8 Unicode text

# Contar linhas (deve ser 6: 1 header + 5 registros)
wc -l /opt/midpoint/import/gmud-023-golden-dataset.csv

# Validar formato (sem caracteres inválidos)
cat /opt/midpoint/import/gmud-023-golden-dataset.csv | head

# Gerar checksum
sha256sum /opt/midpoint/import/gmud-023-golden-dataset.csv > /opt/midpoint/import/gmud-023-golden-dataset.csv.sha256
```

**Critério de Sucesso**:
- [ ] Encoding UTF-8 confirmado
- [ ] 6 linhas (1 header + 5 registros)
- [ ] Nenhum caractere inválido
- [ ] Checksum gerado

### 5.2. Fase 2 - Configuração de Resource CSV

**Duração Estimada**: 30 minutos

#### Atividade 2.1: Criar Resource CSV no midPoint

**Responsável**: Paulo Feitosa (Owner/CISO)

**Descrição**: Configurar Resource com CSV File Connector nativo do midPoint.

**Parâmetros de Configuração**:

| Parâmetro | Valor | Justificativa |
|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-----|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|
| **Nome do Resource** | `OrangeHRM-CSV-GMUD023` | Nomenclatura identifica GMUD e método |
| **Connector Type** | `org.identityconnectors.csvfile.CSVFileConnector` | Conector nativo midPoint (bundled) |
| **File Path** | `/opt/midpoint/import/gmud-023-golden-dataset.csv` | Path absoluto dentro do container |
| **Key Column** | `emp_number` | UID único no CSV |
| **Encoding** | `UTF-8` | Compatível com caracteres especiais |
| **Field Delimiter** | `,` | Padrão CSV |
| **Text Qualifier** | `"` | Campos com vírgulas entre aspas |
| **Read-Only** | `true` | CSV não será modificado |

**Método**: GUI midPoint (Configuration → Repository Objects → Resources → New Resource)

**Critério de Sucesso**:
- [ ] Resource criado com status `UP` (ícone verde)
- [ ] Test Connection executado com sucesso
- [ ] Schema discovered (atributos do CSV visíveis)

#### Atividade 2.2: Validar Schema Discovery

**Responsável**: Paulo Feitosa (Owner/CISO)

**Descrição**: Confirmar que midPoint identificou corretamente os atributos do CSV.

**Validações**:
- [ ] Atributo `emp_number` identificado como `__UID__` (UID)
- [ ] Atributo `emp_number` identificado como `__NAME__` (Name)
- [ ] Atributos `emp_firstname`, `emp_lastname`, `work_email`, `job_title` visíveis
- [ ] Tipo de dados: String (para todos os atributos)

**Método**: GUI midPoint → Resource → Schema → AccountObjectClass → Attributes

**Entregável**: Screenshot do schema descoberto

### 5.3. Fase 3 - Modelagem IGA

**Duração Estimada**: 90 minutos

#### Atividade 3.1: Configurar Object Type

**Responsável**: Paulo Feitosa (Owner/CISO)

**Descrição**: Definir mapeamento de atributos CSV → midPoint UserType.

**Mapeamento de Atributos**:

| Atributo CSV | Atributo midPoint | Tipo | Obrigatório | Transformação |
|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |--|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente ||| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|
| `emp_number` | `icfs:name` (UID) | String | Sim | Nenhuma |
| `emp_number` | `name` (username) | String | Sim | Transformação via Object Template |
| `emp_firstname` | `givenName` | String | Sim | Nenhuma |
| `emp_lastname` | `familyName` | String | Sim | Nenhuma |
| `work_email` | `emailAddress` | String | Sim | Nenhuma |
| `job_title` | `organizationalUnit` | String | Não | Nenhuma |

**Método**: Editar XML do Resource (AccountObjectClass → Attributes → Inbound Mappings)

**Exemplo de Inbound Mapping** (simplificado):
```xml
<attribute>
    <ref>icfs:name</ref>
    <displayName>Employee Number</displayName>
    <inbound>
        <target>
            <path>$user/name</path>
        </target>
    </inbound>
</attribute>
```

**Critério de Sucesso**:
- [ ] Mapeamento de 5 atributos configurado (emp_number, firstname, lastname, email, job_title)
- [ ] Inbound mappings apontando para UserType paths corretos
- [ ] Validação XML sem erros

**Entregável**: `/docs/GMUD-023-object-type-mapping.xml`

#### Atividade 3.2: Configurar Correlation Rule

**Responsável**: Paulo Feitosa (Owner/CISO)

**Descrição**: Definir regra de identificação unívoca de identidades (evitar duplicatas).

**Estratégia de Correlação**: Correlacionar por `emailAddress`

**Lógica**:
1. Se usuário com mesmo `emailAddress` já existir no repositório → **Atualizar** (Link)
2. Se usuário com mesmo `emailAddress` NÃO existir → **Criar** novo UserType

**Método**: Editar XML do Resource (Synchronization → Correlation)

**Exemplo de Correlation Rule** (simplificado):
```xml
<correlation>
    <q:equal>
        <q:path>emailAddress</q:path>
        <expression>
            <path>$account/attributes/work_email</path>
        </expression>
    </q:equal>
</correlation>
```

**Critério de Sucesso**:
- [ ] Correlation rule configurada (query por emailAddress)
- [ ] Lógica: Atualizar se existir, Criar se não existir
- [ ] Validação XML sem erros

**Entregável**: `/docs/GMUD-023-correlation-rule.xml`

#### Atividade 3.3: Configurar Object Template (UserType)

**Responsável**: Paulo Feitosa (Owner/CISO)

**Descrição**: Definir transformações de dados para geração de atributos derivados.

**Transformações a Implementar**:

| Atributo Alvo | Origem | Transformação |
|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |--|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|
| `name` (username) | `givenName` + `familyName` | `givenName.toLowerCase() + "." + familyName.toLowerCase()` (ex: "paulo.feitosa") |
| `fullName` | `givenName` + `familyName` | `givenName + " " + familyName` (ex: "Paulo Feitosa") |
| `emailAddress` | `work_email` (direto) | Nenhuma (atribuição direta) |

**Método**: Criar Object Template via GUI ou XML (Configuration → Repository Objects → Object Templates → New Object Template)

**Exemplo de Object Template** (simplificado):
```xml
<objectTemplate oid="..." xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3">
    <name>User Template - GMUD-023</name>
    <mapping>
        <name>Username from givenName.familyName</name>
        <strength>strong</strength>
        <source>
            <path>givenName</path>
        </source>
        <source>
            <path>familyName</path>
        </source>
        <expression>
            <script>
                <code>
                    givenName.toLowerCase() + '.' + familyName.toLowerCase()
                </code>
            </script>
        </expression>
        <target>
            <path>name</path>
        </target>
    </mapping>
</objectTemplate>
```

**Critério de Sucesso**:
- [ ] Object Template criado com OID único
- [ ] Mapeamento de `name` (username) configurado com script Groovy
- [ ] Mapeamento de `fullName` configurado
- [ ] Template associado ao Resource (Focus Type = UserType)

**Entregável**: `/docs/GMUD-023-object-template.xml`

#### Atividade 3.4: Configurar Focus Type

**Responsável**: Paulo Feitosa (Owner/CISO)

**Descrição**: Associar Resource ao tipo de objeto de foco (UserType).

**Configuração**:
- **Focus Type**: `UserType` (c:UserType)
- **Object Template**: OID do template criado em Atividade 3.3
- **Synchronization Intent**: `default`

**Método**: Editar XML do Resource (Synchronization → ObjectSynchronization)

**Exemplo**:
```xml
<objectSynchronization>
    <name>Default Account Sync</name>
    <focusType>c:UserType</focusType>
    <objectTemplate>
        <targetRef oid="[OID do Object Template]" type="ObjectTemplateType"/>
    </objectTemplate>
</objectSynchronization>
```

**Critério de Sucesso**:
- [ ] Focus Type configurado como UserType
- [ ] Object Template associado (OID correto)
- [ ] Validação XML sem erros

### 5.4. Fase 4 - Execução de Importação

**Duração Estimada**: 30 minutos

#### Atividade 4.1: Criar Task de Importação (Reconciliation)

**Responsável**: Paulo Feitosa (Owner/CISO)

**Descrição**: Criar Task de Reconciliation para importar identidades do CSV.

**Parâmetros da Task**:

| Parâmetro | Valor |
|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-----|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-|
| **Nome da Task** | `Import from OrangeHRM-CSV-GMUD023` |
| **Tipo** | Reconciliation Task |
| **Resource** | `OrangeHRM-CSV-GMUD023` |
| **Object Class** | `AccountObjectClass` (default) |
| **Execution Mode** | `Manual` (execução única sob demanda) |
| **Dry Run** | `false` (execução real, não simulação) |

**Método**: GUI midPoint (Server Tasks → New Task → Import from Resource)

**Critério de Sucesso**:
- [ ] Task criada com status `Runnable`
- [ ] Resource associado corretamente
- [ ] Task não está em modo Dry Run

#### Atividade 4.2: Executar Task de Reconciliation

**Responsável**: Paulo Feitosa (Owner/CISO)

**Descrição**: Executar Task manualmente e aguardar conclusão.

**Procedimento**:
1. Acessar GUI: Server Tasks → `Import from OrangeHRM-CSV-GMUD023`
2. Clicar em "Run now"
3. Aguardar status mudar para `Closed` (sucesso) ou `Suspended` (erro)
4. Capturar logs de execução

**Tempo Esperado**: 10-30 segundos (5 registros)

**Critério de Sucesso**:
- [ ] Task executada com status `Closed` (sucesso)
- [ ] Progresso: 5 objetos processados, 0 erros
- [ ] Logs não contêm exceções (exceptions)

**Entregável**: Screenshot do resultado da Task + logs exportados (`/docs/GMUD-023-task-logs.txt`)

### 5.5. Fase 5 - Validação de Materialização

**Duração Estimada**: 30 minutos

#### Atividade 5.1: Validar Criação de Usuários no Repositório

**Responsável**: Paulo Feitosa (Owner/CISO)

**Descrição**: Confirmar que usuários foram criados como objetos UserType no repositório midPoint.

**Validações**:

1. **Contagem de Usuários**:
   - Acessar GUI: Administration → Users
   - Confirmar: 5 novos usuários visíveis (paulo.feitosa, carlos.silva, ana.santos, roberto.lima, mariana.costa)

2. **Detalhamento de 1 Usuário de Teste** (ex: paulo.feitosa):
   - Acessar: Users → paulo.feitosa → Edit
   - Validar atributos:
     - [ ] `name`: `paulo.feitosa` (gerado via Object Template)
     - [ ] `givenName`: `Paulo`
     - [ ] `familyName`: `Feitosa`
     - [ ] `fullName`: `Paulo Feitosa`
     - [ ] `emailAddress`: `paulo.feitosa@fiqueok.local`
     - [ ] `organizationalUnit`: `CISO`

3. **Validar Correlação** (evitar duplicatas):
   - Re-executar Task de Reconciliation (2ª execução)
   - Confirmar: 5 objetos processados, 0 novos usuários criados (apenas atualizações)
   - Validar: Nenhum usuário duplicado (contagem permanece 5)

**Critério de Sucesso**:
- [ ] 5 usuários criados no repositório
- [ ] Atributos mapeados corretamente (sample de 1 usuário validado)
- [ ] Correlation Rule funciona (2ª execução não cria duplicatas)

**Entregável**: Screenshots de:
- Lista de usuários (Administration → Users)
- Detalhamento de 1 usuário (paulo.feitosa)
- Resultado da 2ª execução da Task (validação de correlação)

#### Atividade 5.2: Validar Logs e Evidências

**Responsável**: Paulo Feitosa (Owner/CISO)

**Descrição**: Revisar logs técnicos para confirmar ausência de erros.

**Logs a Validar**:

1. **Logs da Task** (GUI: Server Tasks → Task → Result):
   - Status: `Success`
   - Progress: `5/5 objects processed`
   - Errors: `0`

2. **Logs do midPoint** (container):
   ```bash
   docker logs midpoint | grep -i "GMUD-023" > /docs/GMUD-023-midpoint-logs.txt
   ```
   - Confirmar: Nenhuma exception (ERROR, WARN aceitáveis se não críticos)

3. **Logs do PostgreSQL** (se aplicável):
   ```bash
   docker logs midpoint-db | grep -i "error" | tail -n 50
   ```
   - Confirmar: Nenhum erro de INSERT/UPDATE relacionado a UserType

**Critério de Sucesso**:
- [ ] Logs da Task confirmam sucesso (0 erros)
- [ ] Logs do midPoint não contêm exceptions críticas
- [ ] Logs do PostgreSQL não contêm erros de persistência

**Entregável**: Arquivos de log salvos em `/docs/`

### 5.6. Fase 6 - Documentação de Evidências

**Duração Estimada**: 30 minutos

#### Atividade 6.1: Consolidar Documentação de Mapeamentos

**Responsável**: Paulo Feitosa (Owner/CISO)

**Descrição**: Reunir toda a documentação de modelagem IGA para reutilização em IGA-P-02.

**Documentos a Consolidar**:

| Documento | Localização | Status |
|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-----|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |--|
| Modelo Canônico de Identidade | `/docs/GMUD-023-canonical-identity-model.md` | ✅ |
| Dataset CSV + Checksum | `/opt/midpoint/import/gmud-023-golden-dataset.csv` + `.sha256` | ✅ |
| Object Type Mapping | `/docs/GMUD-023-object-type-mapping.xml` | ✅ |
| Correlation Rule | `/docs/GMUD-023-correlation-rule.xml` | ✅ |
| Object Template | `/docs/GMUD-023-object-template.xml` | ✅ |
| Logs da Task | `/docs/GMUD-023-task-logs.txt` | ✅ |
| Logs do midPoint | `/docs/GMUD-023-midpoint-logs.txt` | ✅ |
| Screenshots | `/docs/GMUD-023-screenshots/` (5-7 imagens) | ✅ |

**Método**: Criar arquivo ZIP consolidado

```bash
cd /docs
zip -r GMUD-023-evidencias.zip     GMUD-023-canonical-identity-model.md     GMUD-023-object-type-mapping.xml     GMUD-023-correlation-rule.xml     GMUD-023-object-template.xml     GMUD-023-task-logs.txt     GMUD-023-midpoint-logs.txt     GMUD-023-screenshots/
```

**Critério de Sucesso**:
- [ ] Todos os 8 documentos consolidados
- [ ] ZIP gerado com checksum SHA256
- [ ] Documentos acessíveis para reutilização em IGA-P-02

**Entregável**: `/docs/GMUD-023-evidencias.zip` + `.sha256`

#### Atividade 6.2: Criar Relatório de Encerramento da GMUD

**Responsável**: Paulo Feitosa (Owner/CISO)

**Descrição**: Redigir relatório formal de encerramento (REL-GMUD-023).

**Estrutura do Relatório**:

1. **Sumário Executivo**:
   - Objetivo: Validar materialização de identidades via CSV
   - Resultado: [Sucesso / Sucesso Parcial / Falha]
   - Evidências: 5 usuários criados, 0 erros técnicos

2. **Resposta à Pergunta Crítica**:
   - Pergunta: "Com dados simples, explícitos e estáveis (CSV), o motor IGA midPoint cria corretamente objetos UserType no repositório?"
   - Resposta: [Sim / Não / Parcialmente]
   - Justificativa: [Baseada em evidências]

3. **Validação de Hipótese (GMUD-022)**:
   - Hipótese: "A falha de materialização foi causada por modelagem incorreta, não por conectores"
   - Validação: [Confirmada / Refutada]
   - Conclusão: [Análise técnica]

4. **Modelagem Validada** (para reutilização):
   - Object Type: [Resumo de atributos mapeados]
   - Correlation Rule: [Estratégia validada]
   - Object Template: [Transformações validadas]

5. **Recomendações**:
   - Próxima ação: [Criar IGA-P-02 / Ajustar modelagem / Outra]
   - Fase 2 (ScriptedSQL): [Viável / Necessita ajustes]

**Entregável**: `/docs/REL-GMUD-023-Validacao-CSV-Canonico.md`

---

## 6. Riscos e Mitigações

### 6.1. Riscos Técnicos

| ID | Risco | Probabilidade | Impacto | Mitigação |
|----|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-----|
| **R01** | CSV com encoding incorreto (não UTF-8) | 🟡 Média | 🟡 Médio | Validação de encoding antes de importação (Atividade 1.3) |
| **R02** | Object Template com erro de sintaxe Groovy | 🟡 Média | 🔴 Alto | Teste de sintaxe antes de associar ao Resource |
| **R03** | Correlation Rule não identifica usuários existentes | 🟡 Média | 🟡 Médio | Validação com 2ª execução da Task (Atividade 5.1) |
| **R04** | midPoint não descobre schema do CSV | 🟢 Baixa | 🔴 Alto | Test Connection antes de configurar Object Type |
| **R05** | Task de importação falha por timeout | 🟢 Baixa | 🟡 Médio | Dataset pequeno (5 registros) reduz risco |

### 6.2. Riscos de Governança

| ID | Risco | Probabilidade | Impacto | Mitigação |
|----|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-----|
| **R06** | Ambiente IGA-P-01 não representativo de IGA-P-02 | 🟢 Baixa | 🟢 Baixo | Modelagem validada será **copiada** para IGA-P-02 (ADR-006 Fase 2) |
| **R07** | Documentação de mapeamentos incompleta | 🟡 Média | 🟡 Médio | Checklist obrigatório de 8 documentos (Atividade 6.1) |
| **R08** | Perda de estado de IGA-P-01 antes de documentação | 🟢 Baixa | 🔴 Alto | Snapshot pré-GMUD + consolidação de evidências em ZIP |

### 6.3. Riscos Residuais (Aceitáveis)

| Risco Residual | Justificativa de Aceitação |
|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |----|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|
| **IGA-P-01 será descartado** | ADR-005 confirmou ambiente descartável; valor está nas evidências documentadas |
| **CSV não representa dados reais** | Dataset sintético é adequado para validação de modelagem (objetivo da GMUD) |
| **Integração OrangeHRM não validada** | Fora de escopo; reservado para Fase 2 da ADR-006 (ScriptedSQL) |

---

## 7. Critérios de Sucesso

### 7.1. Critérios Técnicos Obrigatórios

Esta GMUD será considerada **bem-sucedida** se **TODOS** os critérios abaixo forem atendidos:

| # | Critério | Método de Validação | Peso |
|---|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |----|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente ||
| 1 | **CSV importado com 100% dos registros** | Task mostra 5/5 objetos processados, 0 erros | 🔴 Crítico |
| 2 | **Usuários materializados no repositório** | 5 usuários visíveis em Administration → Users | 🔴 Crítico |
| 3 | **Mapeamento de atributos correto** | Sample de 1 usuário (paulo.feitosa) com todos os atributos validados | 🔴 Crítico |
| 4 | **Correlation Rule funciona** | 2ª execução da Task não cria usuários duplicados | 🔴 Crítico |
| 5 | **Object Template aplica transformações** | Username gerado corretamente (ex: "paulo.feitosa" de "Paulo" + "Feitosa") | 🔴 Crítico |
| 6 | **Nenhum erro técnico de conector** | Logs da Task e midPoint não contêm exceptions críticas | 🔴 Crítico |
| 7 | **Resultado determinístico e repetível** | 2ª execução da Task produz mesmo resultado (5 usuários, 0 novos) | 🟡 Importante |
| 8 | **Documentação completa** | 8 documentos consolidados em ZIP com checksum | 🟡 Importante |

**Peso dos Critérios**:
- 🔴 **Crítico**: Falha invalida a GMUD (status: Encerrada Sem Sucesso)
- 🟡 **Importante**: Falha requer justificativa documentada (status: Sucesso Parcial)

### 7.2. Critério de Validação de Hipótese (GMUD-022)

**Hipótese a validar**:
> "A falha de materialização de identidades em IGA-P-01 foi causada por modelagem incorreta de Object Types, Correlation Rules e Object Templates, **não por falha de conectores ou infraestrutura**."

**Validação**:
- ✅ **Hipótese Confirmada**: Se CSV (conector simples) materializar identidades com sucesso
  - **Conclusão**: Problema de IGA-P-01 era de modelagem, não de conector
  - **Ação**: Prosseguir para Fase 2 (ScriptedSQL) reutilizando modelagem validada

- ❌ **Hipótese Refutada**: Se CSV falhar em materializar identidades
  - **Conclusão**: Problema pode ser de infraestrutura ou configuração base de midPoint
  - **Ação**: Investigar causa raiz antes de prosseguir para Fase 2

### 7.3. Gate de Aprovação para Fase 2 (ADR-006)

**Condição para avançar para Fase 2 (ScriptedSQL)**:

```
SE (Critérios 1-6 = Todos Atendidos) E (Hipótese = Confirmada)
ENTÃO: Aprovar transição para Fase 2 da ADR-006 (ScriptedSQL)
SENÃO: Criar RNC + Plano de Correção antes de avançar
```

---

## 8. Dependências

### 8.1. Dependências de ADRs

| ADR | Status | Dependência | Impacto na GMUD-023 |
|-----|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |--|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|
| **ADR-006** | Proposta | Esta GMUD implementa **Fase 1** da ADR-006 | Escopo definido pela ADR-006 (CSV canônico) |
| **ADR-005** | Aprovada | IGA-P-01 confirmado como ambiente descartável | Libera uso de IGA-P-01 para validação |
| **ADR-004** | Aprovada | Define ScriptedSQL para Fase 2 (fora de escopo) | Não impacta esta GMUD (CSV em Fase 1) |

### 8.2. Dependências de GMUDs

| GMUD | Status | Dependência | Impacto na GMUD-023 |
|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente ||| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |--|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|
| **GMUD-022** | Encerrada (Sucesso Parcial) | Diagnóstico base (falha de modelagem IGA) | Define hipótese a validar |
| **GMUD-0XX** (Criação IGA-P-02) | Futura | Pendente de sucesso desta GMUD | Esta GMUD é **pré-requisito** |

### 8.3. Dependências Técnicas

| Componente | Status Requerido | Validação |
|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente ||| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente ||| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-----|
| **midPoint 4.10** | Operacional (GUI acessível) | Test Connection antes de iniciar |
| **PostgreSQL 16** | Operacional (repositório íntegro) | Verificar logs de inicialização |
| **Container midPoint** | Healthy (docker ps) | Estado Up + healthy |
| **CSV File Connector** | Disponível (bundled) | Verificar em Connectors → CSV File Connector |

---

## 9. Impactos

### 9.1. Componentes Impactados

| Componente | Tipo de Impacto | Descrição | Reversibilidade |
|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente ||| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |----|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-----|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-----|
| **midPoint Repository** | 🟢 Criação | 5 objetos UserType criados | ✅ Reversível (ambiente descartável) |
| **Resource CSV** | 🟢 Criação | 1 Resource novo (`OrangeHRM-CSV-GMUD023`) | ✅ Reversível (pode ser deletado) |
| **Object Template** | 🟢 Criação | 1 Object Template novo | ✅ Reversível (pode ser deletado) |
| **Tasks** | 🟢 Criação | 1 Task de Reconciliation | ✅ Reversível (pode ser suspensa/deletada) |

### 9.2. Componentes NÃO Impactados

| Componente | Status | Justificativa |
|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente ||| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |--|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|
| **OrangeHRM (database MariaDB)** | ✅ **Nenhuma ação** | CSV é export estático, não há leitura dinâmica |
| **Active Directory (ID-P-01)** | ✅ **Nenhuma ação** | Fora de escopo (ADR-005 + ADR-006) |
| **IGA-P-02** | ✅ **Não criado** | Criação pendente de sucesso desta GMUD |
| **Containers Docker (orangehrm-app, orangehrm-db)** | ✅ **Não acessados** | CSV não interage com OrangeHRM runtime |

### 9.3. Impacto em Usuários e Sistemas

**Impacto**: **Nenhum** (ambiente isolado, sem dados produtivos)

- Nenhum usuário externo afetado
- Nenhum sistema corporativo impactado
- Nenhuma integração externa ativa

---

## 10. Plano de Rollback

### 10.1. Necessidade de Rollback

**Cenários que exigem rollback**:
1. Falha crítica de midPoint (container não sobe após configuração)
2. Corrupção de repositório PostgreSQL
3. Impossibilidade de validar critérios de sucesso

**Cenários que NÃO exigem rollback**:
- Falha de modelagem IGA (Object Type, Correlation, Template incorretos) → Ajustar configuração
- Usuários não materializados → Investigar causa raiz, não reverter

### 10.2. Procedimento de Rollback

**Método**: Restaurar snapshot pré-GMUD

**Etapas**:
1. Desligar VM IGA-P-01 (shutdown graceful)
2. Hyper-V Manager → IGA-P-01 → Snapshots → `PRE-GMUD-023-Baseline`
3. Apply Snapshot
4. Inicializar VM
5. Validar estado: midPoint GUI acessível, containers healthy

**Tempo de Rollback**: 10-15 minutos

**Perda de Dados**: Nenhuma (ambiente descartável, dados sintéticos)

### 10.3. Snapshot Obrigatório Pré-GMUD

**Ação obrigatória ANTES de iniciar execução**:

```bash
# No host Hyper-V:
# Criar snapshot com nomenclatura padronizada
Snapshot Name: "PRE-GMUD-023-Baseline-[DATA-HORA]"
Description: "Baseline pré-validação CSV canônico (GMUD-023)"
```

**Validação**:
- [ ] Snapshot criado com sucesso
- [ ] Nome segue nomenclatura `PRE-GMUD-023-*`
- [ ] Data/hora registrada

---

## 11. Matriz de Responsabilidades (RACI)

| Atividade | Paulo (Owner) | Perplexity (GRC) | ChatGPT (Architect) | Gemini |
|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-----|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente ||| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |--|
| **Aprovação da GMUD** | **A** | R | C | I |
| **Criação de snapshot pré-GMUD** | **R/A** | I | C | I |
| **Fase 1: Preparação de Dataset** | I | C | **R/A** | I |
| **Fase 2: Configuração de Resource** | I | C | **R/A** | I |
| **Fase 3: Modelagem IGA** | I | C | **R/A** | I |
| **Fase 4: Execução de Importação** | I | C | **R/A** | I |
| **Fase 5: Validação de Materialização** | **A** | C | **R** | I |
| **Fase 6: Documentação de Evidências** | **A** | **R** | C | I |
| **Relatório de Encerramento (REL-GMUD-023)** | **A** | **R** | C | I |
| **Decisão de avançar para Fase 2** | **A** | R | C | I |

**Legenda**: 
- **R** = Responsible (Executor)
- **A** = Accountable (Aprovador/Responsável Final)
- **C** = Consulted (Consultado)
- **I** = Informed (Informado)

**Nota sobre Apoio de Ferramentas**:  
As ferramentas de IA (ChatGPT, Gemini, Perplexity Pro) foram utilizadas como apoio à análise técnica, pesquisa e documentação durante a elaboração desta GMUD. Todas as decisões técnicas e aprovações são de responsabilidade de Paulo Feitosa (Owner/CISO).


---

## 12. Cronograma Estimado

**Duração Total Estimada**: 3-4 horas (em 1 dia útil)

| Fase | Atividades | Duração | Dependência |
|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente ||| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-----|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-|
| **Preparação** | Criação de snapshot + validação de pré-requisitos | 15 min | - |
| **Fase 1** | Preparação de Dataset Canônico (Atividades 1.1-1.3) | 30 min | Preparação |
| **Fase 2** | Configuração de Resource CSV (Atividades 2.1-2.2) | 30 min | Fase 1 |
| **Fase 3** | Modelagem IGA (Atividades 3.1-3.4) | 90 min | Fase 2 |
| **Fase 4** | Execução de Importação (Atividades 4.1-4.2) | 30 min | Fase 3 |
| **Fase 5** | Validação de Materialização (Atividades 5.1-5.2) | 30 min | Fase 4 |
| **Fase 6** | Documentação de Evidências (Atividades 6.1-6.2) | 30 min | Fase 5 |
| **Buffer** | Contingência para ajustes/troubleshooting | 30 min | - |

**Total**: 4h 15min (incluindo buffer)

---

## 13. Comunicação

### 13.1. Stakeholders

| Stakeholder | Papel | Tipo de Comunicação | Momento |
|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|
| **Paulo Feitosa** | Owner/CISO/Aprovador | Aprovação formal da GMUD | Antes de executar |
| **Perplexity Pro** | GRC Lead | Documentação e encerramento | Durante e após execução |
| **ChatGPT** | Systems Architect | Execução técnica | Durante execução |
| **Gemini** | Deep-Dive Consultant | Informado (sem ação) | Após encerramento |

### 13.2. Notificações

**Antes da Execução**:
- [ ] GMUD-023 enviada para aprovação de Paulo Feitosa
- [ ] Confirmação de janela de execução

**Durante a Execução**:
- [ ] Notificação de início (Paulo + Perplexity)
- [ ] Notificação de falha crítica (se ocorrer) → Paulo (imediato)

**Após a Execução**:
- [ ] Relatório de Encerramento (REL-GMUD-023) → Paulo
- [ ] Evidências consolidadas (ZIP) → Repositório Obsidian
- [ ] Decisão sobre Fase 2 → Paulo (aprovação)

---

## 14. Critérios de Encerramento

### 14.1. Condições para Encerramento

A GMUD-023 será encerrada quando **UMA** das seguintes condições for satisfeita:

#### 14.1.1. Encerramento com Sucesso

**Condição**:
- ✅ Todos os 6 critérios críticos atendidos (Seção 7.1, critérios 1-6)
- ✅ Critérios importantes atendidos (7-8) OU justificados
- ✅ Hipótese da GMUD-022 validada (confirmada ou refutada com conclusão documentada)
- ✅ Documentação completa (8 documentos consolidados)

**Classificação**: `Encerrada com Sucesso`

**Próxima Ação**: Aprovar criação de IGA-P-02 (ADR-005) + avançar para Fase 2 da ADR-006 (ScriptedSQL)

#### 14.1.2. Encerramento com Sucesso Parcial

**Condição**:
- ✅ Critérios críticos 1-6 atendidos
- ⚠️ Critérios importantes 7-8 parcialmente atendidos (com justificativa)
- ✅ Hipótese validada (com ressalvas documentadas)

**Classificação**: `Encerrada com Sucesso Parcial`

**Próxima Ação**: Criar RNC para itens não atendidos + decidir se avança para Fase 2

#### 14.1.3. Encerramento Sem Sucesso

**Condição**:
- ❌ Qualquer critério crítico (1-6) NÃO atendido
- ❌ Impossibilidade de materializar identidades via CSV

**Classificação**: `Encerrada Sem Sucesso`

**Próxima Ação**: Criar RNC + Análise de causa raiz + Plano de correção antes de prosseguir

### 14.2. Artefatos Obrigatórios para Encerramento

Independente da classificação, os seguintes artefatos são **obrigatórios**:

- [ ] Relatório de Encerramento (REL-GMUD-023)
- [ ] Evidências consolidadas (ZIP + checksum)
- [ ] Resposta à pergunta crítica (Seção 2.3)
- [ ] Validação de hipótese da GMUD-022 (confirmada/refutada)
- [ ] Recomendação sobre Fase 2 (prosseguir/ajustar/cancelar)

---

## 15. Aprovações

| Papel | Nome | Data | Status | Assinatura |
|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente ||| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente ||| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |--|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente ||
| **Autor** | Paulo Feitosa (Owner/CISO) | 09/01/2026 | ✅ Documentado | GMUD-023 v1.0 |
| **Apoio Documentação** | Perplexity Pro, ChatGPT, Gemini | 09/01/2026 | ✅ Documentado | GMUD-023 v1.0 |
| **Aprovador Final** | Paulo Feitosa (Owner/CISO) | [Pendente] | 🟡 **Aguardando aprovação** | - |

---

## 16. Controle de Versão

| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente ||| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente ||| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente || Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |---|| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |
| 1.1 | 10/01/2026 | Paulo Feitosa (Owner/CISO) | Ajuste de governança de autoria: responsabilidades técnicas atribuídas ao Owner/CISO; ferramentas de IA posicionadas como apoio à análise | Pendente |-----|
| 1.0 | 09/01/2026 | Paulo Feitosa (Owner/CISO) | Criação da GMUD-023 - Validação CSV Canônico (Fase 1 ADR-006) | Pendente |

---

## 17. Referências

### 17.1. Decisões Arquiteturais
- ADR-006 - Estratégia de Ingestão de Dados (Fase 1: CSV Canônico)
- ADR-005 - Rebuild Controlado IGA-P-01 → IGA-P-02
- ADR-004 - Connector ScriptedSQL vs DatabaseTable

### 17.2. GMUDs Relacionadas
- GMUD-022 - Rollback Histórico (Diagnóstico: Falha de Modelagem IGA)
- GMUD-010, 013, 017 - Tentativas DatabaseTable (Histórico de falhas)

### 17.3. Metodologias
- MET-IAM-001 - IAM Lab Foundation (Resiliência por Design)
- ARQ-003 - Arquitetura de Governança de Identidades

---

## 18. Anexos

### Anexo A: Estrutura de Diretórios

```
/opt/midpoint/import/
├── gmud-023-golden-dataset.csv
└── gmud-023-golden-dataset.csv.sha256

/docs/
├── GMUD-023-canonical-identity-model.md
├── GMUD-023-object-type-mapping.xml
├── GMUD-023-correlation-rule.xml
├── GMUD-023-object-template.xml
├── GMUD-023-task-logs.txt
├── GMUD-023-midpoint-logs.txt
├── GMUD-023-screenshots/
│   ├── 01-resource-test-connection.png
│   ├── 02-schema-discovered.png
│   ├── 03-task-result.png
│   ├── 04-users-list.png
│   └── 05-user-detail-paulo-feitosa.png
├── GMUD-023-evidencias.zip
├── GMUD-023-evidencias.zip.sha256
└── REL-GMUD-023-Validacao-CSV-Canonico.md
```

### Anexo B: Exemplo de Dataset CSV (Golden Data Set)

```csv
emp_number,emp_firstname,emp_lastname,work_email,job_title
001,Paulo,Feitosa,paulo.feitosa@fiqueok.local,CISO
002,Carlos,Silva,carlos.silva@fiqueok.local,Security Analyst
003,Ana,Santos,ana.santos@fiqueok.local,IAM Specialist
004,Roberto,Lima,roberto.lima@fiqueok.local,GRC Lead
005,Mariana,Costa,mariana.costa@fiqueok.local,SOC Analyst
```

---

**Frase de Encerramento**:

> "A GMUD-023 não busca resolver o problema completo de integração OrangeHRM → midPoint, mas responder à pergunta crítica: **'Com dados simples e controlados, o motor IGA materializa identidades corretamente?'** Esta validação isolada é pré-requisito obrigatório para avançar à Fase 2 (ScriptedSQL), conforme estratégia evolutiva da ADR-006. O sucesso desta GMUD comprova que a modelagem IGA está correta; a falha indica necessidade de ajuste antes de adicionar complexidade de conectores automatizados."

**Status**: 🟡 **GMUD-023 v1.1 AGUARDANDO APROVAÇÃO DE PAULO FEITOSA**

---

**Responsável**: Paulo Feitosa (Owner/CISO)  
**Apoio**: Ferramentas de IA (Perplexity Pro, ChatGPT, Gemini)  
**Repositório:** Obsidian Vault - `FiqueokBrain/10_Projetos/PRJ001-LABORATORIO/20_Governanca/GMUDs/`  
**Classificação:** Internal Use - Change Management  
**Próxima Revisão:** Após aprovação e execução

---

**FIM DA GMUD-023 v1.1**

