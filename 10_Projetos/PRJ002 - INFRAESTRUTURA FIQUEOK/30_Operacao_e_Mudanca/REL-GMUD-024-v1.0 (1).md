---
tags:
  - REL
  - GMUD-024
  - IGA
  - midPoint
  - Change Management
  - Lessons Learned
status: Encerrado
version: 1.0
created: 2026-01-11
type: Relatório de Execução de Mudança
environment: LAB PRJ001
owner: Paulo Feitosa
---

# **REL-GMUD-024 – Relatório de Execução de Mudança**

## **📋 1. Identificação da Mudança**

| **Campo** | **Valor** |
|-----------|-----------|
| **Código** | GMUD-024 |
| **Título** | Integração CSV → midPoint (Employee from CSV) |
| **Versão da GMUD** | v1.2 |
| **Ambiente** | LAB PRJ001 – IGA-P-01 (midPoint 4.10) |
| **Tipo de Mudança** | Configuracional / IGA |
| **Data de Execução** | 11/01/2026 |
| **Executor** | Paulo Feitosa |
| **Status Final** | **Finalizada sem Sucesso (Encerramento Controlado)** |
| **Duração** | 3h15min (14:00 - 17:15) |

---

## **🎯 2. Objetivo Original da GMUD-024**

### **2.1. Finalidade Aprovada**

A GMUD-024 foi planejada para estabelecer o **procedimento canônico** de implementação de Resource CSV como fonte autoritativa de identidades no midPoint 4.10, a partir de um ambiente limpo (checkpoint PRE-GMUD-023).

### **2.2. Objetivos Técnicos Específicos**

Os seguintes objetivos foram aprovados na documentação da GMUD:

1. **Criação do Resource CSV**
   - Configuração do CSVConnector
   - Definição do file path: `/opt/midpoint/var/import/employees.csv`
   - Validação de conectividade (Test connection)

2. **Schema Discovery**
   - Descoberta automática de atributos do arquivo CSV
   - Identificação do `AccountObjectClass`

3. **Definição do Object Type Lógico**
   - Display name: `Employee from CSV`
   - Kind: `ACCOUNT`
   - Intent: `employee` (default)
   - Mapeamento para Focus Type: `User`

4. **Configuração de Correlação Determinística**
   - Uso do atributo `employeeId` como identificador canônico
   - Regra de correlação explícita para evitar duplicidade
   - Garantir comportamento previsível: LINK (se existir) ou CREATE (se não existir)

5. **Inbound Mappings Essenciais**
   - Mapeamento `employeeId → User.name`
   - Mapeamento composto `firstName + lastName → User.fullName`

6. **Synchronization Reactions**
   - Reaction UNMATCHED → `addFocus` (criar novo User)
   - Reaction LINKED → `synchronize` (atualizar User existente)

7. **Validação de Idempotência**
   - Execução de task de importação inicial
   - Re-execução da task sem criar duplicatas
   - Validação de estado LINKED estável

### **2.3. Validade da Arquitetura Planejada**

**📌 Registro importante:**  
Os objetivos técnicos da GMUD-024 eram **corretos e tecnicamente válidos** conforme:
- Arquitetura de referência de IGA aprovada
- Melhores práticas de correlação determinística do midPoint
- Princípios de idempotência e reprodutibilidade
- Lições aprendidas da GMUD-023 (evitar linkage incorreto)

**A mudança foi interrompida por lacuna de validação pré-execução, não por erro de design.**

---

## **⚙️ 3. Escopo Executado até o Ponto de Interrupção**

### **3.1. Atividades Concluídas com Sucesso**

| **Etapa** | **Descrição** | **Status** | **Evidência** |
|-----------|---------------|------------|---------------|
| **3.1.1** | Restore do checkpoint PRE-GMUD-023 | ✅ Concluído | Snapshot Hyper-V |
| **3.1.2** | Validação de Cold Start (POP-LAB-001-v1.7) | ✅ Concluído | Log Cold Start |
| **3.1.3** | Preparação do arquivo CSV no volume Docker | ✅ Concluído | `docker exec` validado |
| **3.1.4** | Criação do Resource CSV via Wizard | ✅ Concluído | Resource `CSV-Employee-Source` criado |
| **3.1.5** | Test connection com status Success | ✅ Concluído | Print GUI (verde) |
| **3.1.6** | Schema discovery completo | ✅ Concluído | 5 atributos detectados |
| **3.1.7** | Preview de dados do Resource | ✅ Concluído | 3 accounts listados (1001, 1002, 1003) |
| **3.1.8** | Criação do Object Type | ✅ Concluído | Kind=ACCOUNT, Intent=employee |
| **3.1.9** | Definição de Focus Type (User) | ✅ Concluído | Mapeamento lógico configurado |
| **3.1.10** | Navegação até menu Correlation | ✅ Concluído | Acesso à tela de configuração |

### **3.2. Atividades NÃO Executadas**

As seguintes atividades planejadas **não foram executadas** devido à interrupção controlada:

- ❌ Configuração da Correlation Rule
- ❌ Configuração de Inbound Mappings
- ❌ Configuração de Synchronization Reactions
- ❌ Execução de task de importação
- ❌ Validação de criação de Users e Shadows
- ❌ Teste de idempotência (re-run)

**📌 Importante:** Nenhuma task de importação foi executada. Nenhum User ou Shadow foi criado no midPoint. O ambiente permanece no estado limpo (PRE-GMUD-023).

---

## **⚠️ 4. Desvio Identificado (Fato Objetivo)**

### **4.1. Descrição do Desvio**

Durante a configuração da **Correlation Rule**, no menu:

```
Resource → CSV-Employee-Source → Schema Handling → Object Type: employee → Correlation
```

Foi identificado o seguinte desvio entre planejamento e realidade técnica:

| **Aspecto** | **Planejado na GMUD** | **Realidade no midPoint** |
|-------------|------------------------|---------------------------|
| **Identificador de correlação** | `employeeId` (atributo lógico do CSV) | Atributo não disponível para correlação no schema User |
| **Atributos disponíveis** | Expectativa: `employeeId` seria correlacionável diretamente | Schema real: `employeeNumber`, `name`, `emailAddress`, `givenName`, `familyName`, extensionProperties |

### **4.2. Manifestação do Desvio**

Ao acessar o menu de configuração de correlação no Object Type, o atributo `employeeId` do arquivo CSV:

- ✅ **Existe** no schema do Resource (CSV) como `ri:employeeId`
- ✅ **Aparece** na lista de atributos descobertos (Schema → Attributes)
- ❌ **Não está disponível** como campo correlacionável no modelo padrão User do midPoint

O midPoint oferece para correlação com User os seguintes atributos padrão:

- `name` (username técnico)
- `employeeNumber` (campo RH padrão)
- `emailAddress`
- `givenName`, `familyName`
- Extension properties (customizações)

### **4.3. Classificação do Desvio**

**Tipo:** Desvio de pré-requisito técnico (gap de validação)

**Natureza:**
- ❌ **NÃO foi** erro de execução do procedimento
- ❌ **NÃO foi** falha da ferramenta midPoint
- ❌ **NÃO foi** ação fora do escopo da GMUD
- ✅ **FOI** ausência de validação prévia entre:
  - Identificador lógico definido na arquitetura (`employeeId`)
  - Atributo físico disponível no schema do midPoint (`employeeNumber` ou mapeamento customizado)

---

## **🔍 5. Análise de Causa Raiz (Root Cause Analysis)**

### **5.1. Causa Raiz Identificada**

**Ausência de validação prévia entre o identificador lógico de correlação (`employeeId`) e o atributo físico disponível no schema do User antes do início da execução da GMUD.**

### **5.2. Fatores Contribuintes**

#### **5.2.1. Lacuna de Pré-Validação Técnica**

A GMUD-024 não incluiu, em sua fase de planejamento, a verificação explícita de:

- Quais atributos do schema User do midPoint estão disponíveis para correlação
- Se o identificador `employeeId` do CSV possui correspondência direta no modelo User
- Se seria necessário mapeamento intermediário (ex: `employeeId` → inbound → `User.employeeNumber`)

#### **5.2.2. Ausência de Gate Técnico no Checklist**

O checklist de pré-GMUD não continha o seguinte gate obrigatório:

> **Gate de Correlação:**  
> ✅ Validar que o atributo de correlação planejado existe no schema do Focus Type (User) antes de iniciar a configuração do Object Type.

#### **5.2.3. Premissa Implícita Não Validada**

A arquitetura da GMUD assumiu implicitamente que:

- O atributo `employeeId` do CSV seria "naturalmente" correlacionável com User
- O midPoint mapearia automaticamente `employeeId` para algum campo User

**Essa premissa não foi validada antes da execução.**

### **5.3. O Que NÃO Foi Causa Raiz**

Para fins de aprendizado organizacional, é importante registrar o que **não** causou o problema:

- ❌ Falha técnica do midPoint (ferramenta operou conforme esperado)
- ❌ Erro de execução do procedimento (todos os passos foram seguidos corretamente)
- ❌ Falta de conhecimento técnico (o executor identificou o problema imediatamente)
- ❌ Pressão de tempo (a GMUD tinha janela de 2h, suficiente para execução completa)
- ❌ Ambiente instável (Cold Start validado com sucesso antes da GMUD)

### **5.4. Método de Análise Utilizado**

**5 Whys aplicado:**

1. **Por que a GMUD foi interrompida?**  
   → Porque não foi possível configurar a Correlation Rule com `employeeId`.

2. **Por que não foi possível configurar?**  
   → Porque `employeeId` não está disponível como atributo correlacionável no schema User.

3. **Por que não está disponível?**  
   → Porque o midPoint usa `employeeNumber` (padrão LDAP/HR) ou requer mapeamento via inbound para campos customizados.

4. **Por que isso não foi identificado antes?**  
   → Porque não houve validação prévia do schema User antes da GMUD.

5. **Por que não houve validação prévia?**  
   → **Causa raiz:** Porque o checklist de pré-GMUD não incluía gate de validação de atributos de correlação.

---

## **⚡ 6. Avaliação de Risco Caso a GMUD Prosseguisse**

### **6.1. Riscos Técnicos Imediatos**

Se a GMUD tivesse prosseguido sem resolver o problema de correlação, os seguintes riscos se materializariam:

#### **6.1.1. Criação de Shadows Órfãos**

- **Risco:** Shadows criados em estado UNMATCHED permanente
- **Impacto:** Sem correlação funcional, o midPoint não conseguiria vincular (LINK) shadows a Users existentes
- **Severidade:** Alta (quebra do objetivo principal da GMUD)

#### **6.1.2. Duplicidade de Usuários**

- **Risco:** Cada execução da task de importação criaria novos Users
- **Impacto:** Perda total de idempotência (princípio de engenharia da GMUD-024 v1.2)
- **Severidade:** Crítica (viola requisito de reprodutibilidade)

#### **6.1.3. Comprometimento do POP Futuro**

- **Risco:** Procedimento documentado seria não-reproduzível
- **Impacto:** POP publicado conteria erro arquitetural
- **Severidade:** Alta (objetivo final da GMUD-024 era gerar POP)

#### **6.1.4. Inconsistência Auditável**

- **Risco:** Estado do sistema divergente da documentação
- **Impacto:** Evidências de execução não refletiriam a arquitetura aprovada
- **Severidade:** Alta (conformidade ISO 27001 A.5.22 - Change Management)

### **6.2. Riscos de Governança**

#### **6.2.1. Precedente de Execução Parcial**

- **Risco:** Normalização de GMUDs executadas sem validação completa de pré-requisitos
- **Impacto:** Erosão da confiança no processo de Change Management
- **Severidade:** Média

#### **6.2.2. Custo de Rollback Posterior**

- **Risco:** Limpeza manual de Users/Shadows criados incorretamente
- **Impacto:** Esforço técnico adicional + risco de perda de rastreabilidade
- **Severidade:** Média

### **6.3. Avaliação de Decisão**

**Conclusão técnica:**  
Prosseguir com a GMUD seria **tecnicamente irresponsável** pelos seguintes motivos:

1. Violaria o objetivo principal (correlação determinística)
2. Comprometeria a integridade do ambiente de laboratório
3. Geraria documentação (REL + POP) baseada em execução incorreta
4. Criaria precedente de má governança

**📌 A interrupção controlada foi a decisão tecnicamente correta.**

---

## **✋ 7. Decisão de Encerramento**

### **7.1. Formalização da Decisão**

**A GMUD-024 foi encerrada sem sucesso em 11/01/2026 às 17:15.**

### **7.2. Critérios de Encerramento**

A decisão foi tomada com base nos seguintes critérios técnicos e de governança:

| **Critério** | **Status** | **Justificativa** |
|--------------|------------|-------------------|
| **Objetivo alcançável** | ❌ Não | Correlação não configurável sem inbound mapping |
| **Risco controlado** | ✅ Sim | Nenhum impacto irreversível no ambiente |
| **Integridade preservada** | ✅ Sim | Ambiente permanece em estado PRE-GMUD-023 |
| **Rastreabilidade mantida** | ✅ Sim | Todas as ações documentadas e evidenciadas |
| **Aprendizado capturado** | ✅ Sim | Causa raiz identificada e documentada |

### **7.3. Tipo de Encerramento**

**Encerramento Controlado (Planned Closure)**

**Características:**
- Decisão consciente de governança
- Interrupção antes de qualquer impacto irreversível
- Análise de causa raiz concluída
- Lição aprendida documentada
- Integridade do ambiente garantida

**Diferencial em relação a "Falha":**
- ❌ **Falha:** Execução gera estado inconsistente + rollback necessário
- ✅ **Encerramento Controlado:** Execução interrompida antes de criar inconsistência

### **7.4. Estado Final do Ambiente**

| **Componente** | **Estado Esperado (pós-GMUD)** | **Estado Real (após encerramento)** |
|----------------|--------------------------------|-------------------------------------|
| **Resource CSV** | Criado e funcional | Criado e funcional |
| **Object Type** | Configurado com correlação | Configurado sem correlação |
| **Shadows** | 3 shadows em estado LINKED | 0 shadows (preview realizado, mas sem persistência) |
| **Users** | 3 users criados | 0 users criados |
| **Integridade** | Ambiente operacional | **Ambiente preservado em estado PRE-GMUD-023** |

**📌 Importante:** O Resource `CSV-Employee-Source` e o Object Type `employee` foram criados, mas nenhuma task de sincronização foi executada. **O ambiente pode ser restaurado via snapshot ou o Resource pode ser deletado manualmente.**

---

## **📚 8. Lição Aprendida (Organizational Learning)**

### **8.1. Lição Principal**

**GMUDs de IGA que envolvem correlação não podem avançar sem validação explícita entre:**

1. **Identificador lógico de identidade** (definido na arquitetura/CSV)
2. **Atributo físico real no schema do Focus Type** (User, Org, Role, etc.)

### **8.2. Gate Técnico Obrigatório (novo requisito)**

**Nome:** Validação de Atributo de Correlação

**Quando:** Antes de qualquer GMUD que crie ou altere Object Types com correlação

**Como validar:**

```bash
# No midPoint GUI:
1. Navegar para: Configuration → Repository Objects → User
2. Clicar em "Show empty fields"
3. Identificar atributos disponíveis no schema
4. Validar se o identificador planejado existe ou requer mapeamento

# Via REST API (opcional):
curl -u administrator:senha \
  http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/users/00000000-0000-0000-0000-000000000002 | grep -E '(employeeNumber|name|emailAddress)'
```

**Critério de aprovação para prosseguir:**

- ✅ O atributo de correlação existe no schema User (ex: `employeeNumber`)
- **OU**
- ✅ Está planejado inbound mapping explícito (ex: `employeeId` → script → `User.name`)

**Se nenhum dos critérios for atendido:** ❌ **Bloquear GMUD até resolver o mapeamento.**

### **8.3. Impacto na Governança**

Esta lição aprendida deve ser incorporada aos seguintes artefatos:

#### **8.3.1. Checklist de Pré-GMUD**

Adicionar item obrigatório:

> **[ ] Gate de Correlação:**  
> Validar que o atributo de correlação planejado existe no schema do Focus Type ou está mapeado via inbound antes de criar Object Type.

#### **8.3.2. POP-IGA-001 (futuro)**

O POP de integração CSV deve incluir seção:

> **2. Pré-requisitos Técnicos**  
> 2.3. Validação de Schema do Focus Type  
> - Listar atributos disponíveis no User  
> - Confirmar existência do atributo de correlação  
> - Planejar inbound mapping se necessário

#### **8.3.3. Template de GMUD**

O template de GMUD-IGA deve incluir campo:

```yaml
correlation_attribute_validation:
  logical_identifier: "employeeId"
  physical_attribute: "employeeNumber"
  mapping_required: true/false
  validation_date: "DD/MM/YYYY"
  validated_by: "Nome do técnico"
```

### **8.4. Contexto de Aprendizado Organizacional**

**Por que esta lição é crítica:**

1. **Correlação é ponto de não-retorno:**  
   Após executar task de importação com correlação incorreta, o custo de correção é alto (limpeza manual de shadows/users).

2. **Idempotência depende de correlação correta:**  
   Se a correlação falha, cada re-run cria duplicatas, quebrando reprodutibilidade.

3. **POP deve ser 100% reproduzível:**  
   Se o POP contiver erro de correlação, qualquer pessoa que o seguir enfrentará o mesmo problema.

### **8.5. Aplicabilidade**

Esta lição se aplica a:

- ✅ Qualquer integração de fonte autoritativa (CSV, LDAP, DB, API)
- ✅ Qualquer cenário de correlação (User, Org, Role)
- ✅ Ambientes de laboratório e produção
- ✅ GMUDs futuras (ex: GMUD-025)

---

## **📎 9. Referências**

### **9.1. Documentos Relacionados**

- **GMUD-024 v1.2:** Planejamento da mudança (documento base)
- **POP-LAB-001 v1.7:** Procedimento de Cold Start (pré-requisito validado)
- **Checkpoint PRE-GMUD-023:** Snapshot Hyper-V utilizado como baseline
- **ISO 27001:2022 Annex A.5.22:** Monitoring, review and change management of information security

### **9.2. Evidências Coletadas**

As seguintes evidências fotográficas foram capturadas durante a execução:

1. `Resource-Data-Preview.jpg` – Preview de accounts do CSV (shadows em estado inicial)
2. `Go-To-Resource.jpg` – Navegação para configuração do Resource
3. `Object-Type-Manager.jpg` – Tela de Object Type Manager (vazia antes da criação)
4. `Association-Type-Manager.jpg` – Tela de Association Type Manager

**Localização das evidências:**  
`20_Areas/01_SGSI_Fiqueok/05_Operacao_e_Procedimentos/evidencias_pops/gmud-024/`

### **9.3. Frameworks e Normas Aplicáveis**

- **ITIL v4 – Change Enablement:** Controlled closure for unsuccessful changes
- **ISO 27001:2022 – A.5.22:** Procedures to roll back / recover from unsuccessful change
- **NIST CSF 2.0 – PR.IP-3:** Configuration change control processes
- **midPoint Documentation:** Correlation and Confirmation Expressions

---

## **🔄 10. Próximas Ações**

### **10.1. Ações Imediatas (Concluídas)**

- [x] Documentar REL-GMUD-024 com análise de causa raiz
- [x] Capturar evidências visuais da execução
- [x] Registrar lição aprendida
- [x] Preservar integridade do ambiente (sem rollback necessário)

### **10.2. Ações Pendentes (Fora do Escopo desta REL)**

- [ ] Elaborar GMUD-025 com correção do mapeamento `employeeId → User.employeeNumber`
- [ ] Atualizar checklist de pré-GMUD com gate de validação de correlação
- [ ] Revisar template de GMUD-IGA para incluir validação de schema
- [ ] Elaborar POP-IGA-001 incorporando lição aprendida

### **10.3. Decisões Pendentes**

**Decisão arquitetural necessária para GMUD-025:**

Escolher uma das seguintes estratégias de correlação:

**Opção A:** Mapear `employeeId` do CSV para `User.employeeNumber` (campo padrão midPoint)

```xml
<inbound>
    <strength>strong</strength>
    <target>
        <path>employeeNumber</path>
    </target>
</inbound>
```

**Opção B:** Mapear `employeeId` do CSV para `User.name` (identificador técnico)

```xml
<inbound>
    <strength>strong</strength>
    <target>
        <path>name</path>
    </target>
</inbound>
```

**Opção C:** Criar extension property customizado `employeeId` no schema User

**📌 Esta decisão será documentada em ADR (Architecture Decision Record) separado antes da GMUD-025.**

---

## **✅ 11. Aprovações e Encerramento Formal**

### **11.1. Registro de Aprovação**

| **Papel** | **Nome** | **Assinatura** | **Data** |
|-----------|----------|----------------|----------|
| **Executor** | Paulo Feitosa | _Aprovado_ | 11/01/2026 |
| **Revisor Técnico** | _A definir_ | _Pendente_ | _A definir_ |
| **Aprovador GRC** | _A definir_ | _Pendente_ | _A definir_ |

### **11.2. Confirmação de Encerramento**

**Status:** Encerrada sem sucesso (Controlled Closure)

**Data de Encerramento:** 11/01/2026 17:15

**Motivo:** Desvio de pré-requisito técnico identificado antes de impacto irreversível

**Integridade do Ambiente:** ✅ Preservada

**Rastreabilidade:** ✅ Completa

**Lição Aprendida:** ✅ Documentada

---

## **📌 12. Nota Final**

Esta REL documenta formalmente o **encerramento controlado** da GMUD-024, reconhecendo que:

1. O objetivo técnico da mudança era correto e válido
2. A execução seguiu rigorosamente o procedimento planejado
3. O desvio foi identificado em momento apropriado (antes de criar inconsistência)
4. A decisão de encerramento foi tecnicamente responsável
5. A lição aprendida foi capturada e será aplicada em mudanças futuras

**Este documento não representa falha de processo, mas sim maturidade de governança:**

> "A melhor mudança é aquela que identifica riscos antes de materializá-los."

---

**Localização no Repositório Obsidian:**  
`10_Projetos/PRJ001-LABORATORIO/30_Operacao_&_Mudancas/REL-GMUD-024-v1.0.md`

---

*Documento gerado em 11/01/2026 21:13 -03*  
*Relatório de execução elaborado conforme ISO 27001:2022 A.5.22 e ITIL v4 Change Enablement*

