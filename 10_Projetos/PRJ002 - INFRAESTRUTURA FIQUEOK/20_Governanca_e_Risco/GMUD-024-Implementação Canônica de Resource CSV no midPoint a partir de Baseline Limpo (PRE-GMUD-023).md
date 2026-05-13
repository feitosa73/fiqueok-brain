---
tags:
  - GMUD
  - midPoint
  - CSV
  - IGA
  - Correlation
  - Reconciliation
status: Ativo
version: 1.2
created: 2026-01-11
type: Mudança Técnica
environment: LAB PRJ001
owner: Paulo Feitosa
---

# **GMUD-024 – Implementação Canônica de Resource CSV no midPoint a partir de Baseline Limpo (PRE-GMUD-023)**

## **📋 Metadados**

| **Campo** | **Valor** |
|-----------|-----------|
| **Número** | GMUD-024 |
| **Título** | Implementação Canônica de Resource CSV com Baseline Limpo (PRE-GMUD-023) *(Atualizado na v1.2)* |
| **Versão** | 1.2 |
| **Data de Criação** | 11/01/2026 |
| **Executor** | Paulo Feitosa |
| **Ambiente** | LAB PRJ001 – IGA-P-01 (midPoint 4.10) |
| **Tipo** | Configuração IGA |
| **Severidade** | Média |
| **Janela de Execução** | 2 horas |
| **Rollback Disponível** | Sim (Delete Resource + Users via OID) |

---


---

## **🎯 0. Objetivo da GMUD-024** *(Atualizado na v1.2 — Execução Canônica a partir do PRE-GMUD-023)*

### **0.1. Finalidade**

Esta GMUD estabelece o **procedimento padrão (POP)** para implementação de Resource CSV como **fonte autoritativa de identidades** no midPoint 4.10, a partir de um **ambiente limpo e reprodutível**.

**Escopo de baseline:**
- Estado inicial: **Checkpoint PRE-GMUD-023** (ambiente com OrangeHRM configurado, sem Resource CSV pré-existente)
- Finalidade: Configuração canônica do Resource CSV com operação idempotente e correlação correta
- Natureza: **Implementação de engenharia**, não troubleshooting ou correção de incidente

### **0.2. Princípios de Engenharia**

Esta GMUD segue os seguintes princípios de rigor técnico:

| **Princípio** | **Aplicação** |
|---------------|---------------|
| **Reprodutibilidade** | A GMUD pode ser executada N vezes em ambiente limpo com resultado idêntico |
| **Idempotência** | Re-execução da task de reconciliação não cria duplicatas nem erros |
| **Baseline Limpo** | Nenhum artefato da GMUD-023 ou estado residual é reaproveitado |
| **Correlação Determinística** | Regras de correlação explícitas e validáveis |
| **Operação Contínua** | Sistema pode sincronizar periodicamente sem intervenção manual |

### **0.3. O que NÃO é esta GMUD**

**Fora de Escopo:**
- ❌ Correção de falhas de GMUDs anteriores
- ❌ Limpeza de users/shadows residuais
- ❌ Recuperação de estado inconsistente
- ❌ Troubleshooting de problemas herdados
- ❌ Migração de dados legados

**Posicionamento correto:**  
Esta é uma **GMUD de implementação canônica**, não de resposta a incidente.

## **🔹 1. Escopo da GMUD-024** *(Atualizado na v1.2 — Execução Canônica a partir do PRE-GMUD-023)*

### **1.1. Estado Inicial Obrigatório: Checkpoint PRE-GMUD-023** *(Atualizado na v1.2)*

**✅ PRÉ-REQUISITO CRÍTICO: Restore do checkpoint PRE-GMUD-023**

Esta GMUD parte de um **ambiente limpo**, sem nenhum Resource CSV pré-existente.

**Estado esperado do checkpoint PRE-GMUD-023:**
- AD DS `xxx.xxx.xxx.xxx` respondendo em LDAP porta 389
- Containers `midpoint-server` e `midpoint-db` rodando
- Console midPoint acessível via `http://xxx.xxx.xxx.xxx:8080/midpoint`
- Resource OrangeHRM configurado e funcional (Test connection = **Success**)
- **Nenhum Resource CSV existente**
- **Nenhum User criado por CSV no midPoint**
- **Nenhum Shadow de fonte CSV**

**Procedimento de restore (se necessário):**

```bash
# No host Hyper-V ou sistema de virtualização
# Restaurar snapshot PRE-GMUD-023 da VM IGA-P-01
# Exemplo: Hyper-V PowerShell
Restore-VMSnapshot -VMName "IGA-P-01" -Name "PRE-GMUD-023" -Confirm:$false

# Validar Cold Start após restore
# Executar POP-LAB-001-v1.7 completo
```

**Validação do estado inicial:**

| **Item** | **Comando de Validação** | **Resultado Esperado** |
|----------|--------------------------|------------------------|
| AD DS ativo | `Test-NetConnection xxx.xxx.xxx.xxx -Port 389` | TcpTestSucceeded: True |
| midPoint acessível | `curl -I http://xxx.xxx.xxx.xxx:8080/midpoint` | HTTP/1.1 200 OK |
| Resource CSV inexistente | GUI: Resources → All resources → Buscar "CSV" | **Nenhum resultado** |
| Users de CSV inexistentes | GUI: Users → All users → Filtrar `name` contém "00" | **Nenhum resultado** |

**PONTO DE BLOQUEIO:** Se o Resource CSV ou Users já existirem, a GMUD **NÃO deve prosseguir** até que o rollback/limpeza seja executado.

### **1.2. Inclusões no Escopo** *(Atualizado na v1.2)*

Esta GMUD inclui explicitamente as seguintes atividades:

**Preparação do ambiente:**
- ✅ Restore do checkpoint PRE-GMUD-023 (se aplicável)
- ✅ Validação do estado inicial limpo
- ✅ Preparação do arquivo CSV de origem

**Configuração do Resource:**
- ✅ Criação do Resource CSV do zero
- ✅ Test connection e validação de conectividade
- ✅ Schema discovery completo
- ✅ Definição de Object Type (Kind/Intent)
- ✅ Configuração de inbound mappings essenciais
- ✅ Definição de regra de correlação explícita
- ✅ Configuração de synchronization reactions (UNMATCHED, LINKED)

**Validação e operação:**
- ✅ Execução da task de importação inicial
- ✅ Validação de criação de Users e Shadows
- ✅ Re-execução idempotente da task
- ✅ Validação de não-duplicação
- ✅ Testes de sincronização contínua
- ✅ Registro de execução e encerramento

### **1.3. Exclusões do Escopo** *(Atualizado na v1.2)*

As seguintes atividades estão **explicitamente fora do escopo**:

**Não é parte desta GMUD:**
- ❌ Correção de dados herdados de GMUDs anteriores
- ❌ Limpeza manual de shadows/users órfãos
- ❌ Troubleshooting de estados residuais
- ❌ Migração de configurações da GMUD-023
- ❌ Provisionamento para AD ou outros targets downstream (outbound)
- ❌ Configuração de workflows de aprovação
- ❌ Integração com sistemas externos além do CSV

**Decisão de design:**  
Nenhum artefato da GMUD-023 é reaproveitado. A GMUD-024 implementa o Resource CSV como se fosse a **primeira vez** na história do ambiente.

---

## **🔹 2. Procedimento End-to-End (Obrigatório)**

### **2.1. Criação do Resource CSV**

#### **Passo 1: Preparar o arquivo CSV**

Criar arquivo `/opt/midpoint/var/import/employees.csv` no host IGA-P-01:

```csv
employeeId,firstName,lastName,department,jobTitle
001,Paulo,Silva,IT,System Administrator
002,Maria,Santos,Finance,Financial Analyst
003,João,Costa,Marketing,Marketing Coordinator
```

**Validação**:
```bash
cat /opt/midpoint/var/import/employees.csv
```

**Verificar permissões**:
```bash
ls -lh /opt/midpoint/var/import/employees.csv
# Deve ser legível pelo usuário midpoint
```

#### **Passo 2: Criar Resource no midPoint**

Navegar para **Resources → New resource → CSV File**

**Configuração**:

| **Campo** | **Valor** |
|-----------|-----------|
| **Name** | `CSV-Employee-Source` |
| **File Path** | `/opt/midpoint/var/import/employees.csv` |
| **Field Delimiter** | `,` (vírgula) |
| **Unique Attribute** | `employeeId` |
| **Encoding** | `UTF-8` |

**Salvar** e aguardar criação do OID.

---

### **2.2. Discovery do Schema**

#### **Passo 3: Test Connection**

- Clicar em **Test connection**
- Validar retorno: **Success** (verde)

**PONTO DE BLOQUEIO**: Se falhar, verificar:
- Path do arquivo existe
- Permissões de leitura para usuário `midpoint`
- Encoding UTF-8 válido
- Container tem acesso ao volume montado

#### **Passo 4: Descobrir Schema**

- Clicar em **Schema → Refresh schema**
- Aguardar conclusão (5-10 segundos)
- Validar que os atributos foram descobertos:
  - `employeeId`
  - `firstName`
  - `lastName`
  - `department`
  - `jobTitle`

**VALIDAÇÃO**: Navegar para **Schema → Object classes → AccountObjectClass** e confirmar presença dos 5 atributos.

---

### **2.3. Definição do Object Type, Kind e Intent**

#### **Passo 5: Criar Object Type**

Navegar para **Resource → Schema handling → Object Types → Add object type**

**Configuração**:

| **Campo** | **Valor** |
|-----------|-----------|
| **Kind** | `Account` |
| **Intent** | `default` |
| **Object Class** | `AccountObjectClass` |
| **Default** | `✅ Marcado` |
| **Display Name** | `CSV Employee` |

**Salvar Object Type**.

**⚠️ ANTI-PADRÃO**: Nunca deixar Intent vazio ou indefinido. O midPoint pode ignorar o Object Type silenciosamente.

---

### **2.4. Inbound Mappings Mínimos**

#### **Passo 6: Configurar Inbound Mappings**

Navegar para **Object Type → Attributes → employeeId**

**Mapping 1: employeeId → User.name**

```xml
<inbound>
    <strength>strong</strength>
    <target>
        <path>$user/name</path>
    </target>
</inbound>
```

**📌 DECISÃO ARQUITETURAL CONSCIENTE:**

Este mapping define `User.name` como **identificador técnico** derivado do HR Source (employeeId).

**Implicações:**
- ✅ **Vantagem**: `User.name` vira chave estável e imutável, ideal para HR-authoritative source
- ✅ **Vantagem**: Correlação determinstica e previsível
- ⚠️ **Restrição futura**: Se AD exigir `sAMAccountName` humanizado (ex: `paulo.silva`), será necessário mapping adicional
- ⚠️ **Conflito potencial**: Se múltiplas fontes autoritativas coexistirem, revisar estratégia de correlação

**Justificativa**: Para cenário LAB com fonte única (CSV), esta decisão garante rastreabilidade e simplicidade.

---

**Mapping 2: fullName → User.fullName**

Navegar para **Attributes → firstName**

```xml
<inbound>
    <strength>strong</strength>
    <expression>
        <script>
            <code>
                firstName = input
                lastName = basic.getAttributeValue(shadow, 'lastName')
                return firstName + ' ' + lastName
            </code>
        </script>
    </expression>
    <target>
        <path>$user/fullName</path>
    </target>
</inbound>
```

**Salvar Mappings**.

---

### **2.5. Correlação Explícita (Ajuste v1.1)**

#### **Passo 7: Definir Correlation Rule**

Navegar para **Object Type → Correlation**

**Configuração (versão robusta)**:

```xml
<correlation>
    <q:equal>
        <q:path>$focus/name</q:path>
        <expression>
            <path>$account/attributes/employeeId</path>
        </expression>
    </q:equal>
</correlation>
```

**📌 AJUSTE v1.1 – Explicação Técnica:**

**Mudança**: `<q:path>name</q:path>` → `<q:path>$focus/name</q:path>`

**Motivo da robustez adicional:**
- `$focus/name` explicita que estamos correlacionando com o **objeto User** (focus), não shadow
- Evita ambiguidade em cenários futuros com:
  - Múltiplas personas (Roles, Orgs)
  - Correlação cross-resource
  - Transformações complexas

**Comportamento funcional**: Idêntico ao anterior neste cenário simples.

**Ganho arquitetural**: Código auto-documentado e preparado para evolução.

**Lógica**: Correlacionar `employeeId` do CSV com `User.name` do midPoint.

**Salvar Resource**.

---

### **2.6. Synchronization Reactions**

#### **Passo 8: Configurar Reactions**

Navegar para **Object Type → Synchronization → Reactions**

**Reaction 1: UNMATCHED → Add Focus**

| **Campo** | **Valor** |
|-----------|-----------|
| **Situation** | `UNMATCHED` |
| **Action** | `addFocus` |
| **Name** | `Create User on First Import` |

**Reaction 2: LINKED → Synchronize (ou NONE)**

| **Campo** | **Valor** |
|-----------|-----------|
| **Situation** | `LINKED` |
| **Action** | `synchronize` ou `NONE` (decisão do projeto) |
| **Name** | `Keep Linked State` |

**DECISÃO DE DESIGN**:
- Se `synchronize`: atualiza User existente com dados do CSV em cada reconcile
- Se `NONE`: mantém User sem modificação após linking inicial

**Recomendação para LAB**: Usar `synchronize` para validar idempotência.

**Salvar Resource**.

---

### **2.7. Task: Import e Reconcile**

#### **Passo 9: Criar Task de Importação**

Navegar para **Server Tasks → New task → Import from resource**

**Configuração**:

| **Campo** | **Valor** |
|-----------|-----------|
| **Name** | `Import CSV Employees` |
| **Resource** | `CSV-Employee-Source` |
| **Object Class** | `AccountObjectClass` |
| **Object Type** | `default` |
| **Execution** | `Single run` |

**Salvar e Executar**.

#### **Passo 10: Validar Primeira Execução**

Aguardar conclusão da task (10-30 segundos).

**Critérios de sucesso**:
- Task status: **CLOSED** com **SUCCESS**
- Shadow accounts criados: 3 (001, 002, 003)
- Users criados no midPoint: 3
- Status de sincronização: **LINKED**

**Validação via GUI**:
- Navegar para **Users → All users**
- Confirmar criação de 3 usuários com `name` = `001`, `002`, `003`
- Validar `fullName` populado: "Paulo Silva", "Maria Santos", "João Costa"

**Validação detalhada**:
```bash
# Via REST API (opcional)
curl -u administrator:senha   -H "Accept: application/json"   http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/users | jq '.[] | {name: .name, fullName: .fullName}'
```

---

### **2.8. Re-run Idempotente**

#### **Passo 11: Executar Task Novamente**

Navegar para **Server Tasks → Import CSV Employees → Run now**

**Comportamento esperado**:
- Shadows existentes: **LINKED** (não cria novos)
- Users existentes: **NÃO duplicados**
- Task status: **SUCCESS**
- Nenhuma reação **UNMATCHED** deve ocorrer

**Validação crítica**:
```bash
# Contar Users antes e depois
curl -u administrator:senha   http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/users?query=name+eq+"001" | grep -c "<name>"
# Deve retornar: 1 (não 2)
```

**PONTO DE BLOQUEIO**: Se criar novos Users ou Shadows, a correlação está **quebrada** → **RNC obrigatória**.

---

## **🔹 3. Critérios de Sucesso (MUITO Objetivos)**

### **3.1. Checklist de Validação Final**

| **Critério** | **Status Esperado** | **Validação** |
|--------------|---------------------|---------------|
| ✅ User criado no primeiro run | `name=001,002,003` existem | GUI: Users → All users |
| ✅ Shadow vinculado | Status `LINKED` | GUI: Resource → Accounts |
| ✅ Reconcile subsequente não cria novo User | Contagem de Users permanece 3 | Query: `count(User)` |
| ✅ Nenhum `fatal_error` | Task log sem erros críticos | Server Tasks → Logs |
| ✅ Nenhuma reação indevida em estado LINKED | Zero UNMATCHED no segundo run | Resource → Accounts → Filters |
| ✅ fullName populado corretamente | "Paulo Silva", não vazio | User detail → Full Name |

### **3.2. Validação via REST API (Opcional Avançado)**

```bash
# Contar Users criados
curl -u administrator:senha   -H "Accept: application/xml"   http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/users | grep -c "<name>00"
```

**Retorno esperado**: `3`

---

## **🔹 4. Anti-Padrões Explícitos (Lições Aprendidas)**

### **4.1. Matriz de Anti-Padrões**

| **Anti-Padrão** | **Consequência** | **Prevenção** |
|-----------------|------------------|---------------|
| ❌ Não confiar na GUI sem validar Shadow | User criado mas sem linking | Sempre consultar **Resource → Accounts** |
| ❌ Não assumir que inbound cria User | Shadow órfão (UNMATCHED permanente) | Validar Synchronization Reaction **addFocus** |
| ❌ Não ignorar User.name | Correlação falha silenciosamente | Mapping explícito `employeeId → User.name` |
| ❌ Não rodar reconcile sem pensar em idempotência | Duplicação de Users | Testar re-run antes de aprovar GMUD |
| ❌ Não usar Intent vazio | midPoint ignora Object Type | Sempre definir `Intent=default` |
| ❌ Não usar `q:path` genérico em correlation | Ambiguidade futura em cenários complexos | Usar `$focus/name` explícito |
| ❌ Não deletar via REST sem OID | Endpoint falha silenciosamente | Buscar OID antes de DELETE |

### **4.2. Troubleshooting Rápido**

**Problema: Shadow criado mas User não existe**

→ Verificar Synchronization Reaction **UNMATCHED → addFocus** está configurada.

**Problema: User duplicado no segundo run**

→ Correlation rule **não está funcionando**. Validar `User.name = employeeId`.

**Problema: Task falha com erro `File not found`**

→ Path do CSV está **incorreto** ou container não tem acesso ao volume montado.

**Problema: Correlation não encontra User existente**

→ Verificar se `User.name` foi populado corretamente no primeiro run.  
→ Usar `$focus/name` em vez de `name` genérico.

---

## **🔹 5. Rollback e Plano de Contingência (Ajuste v1.1)**

### **5.1. Rollback Completo**

**Cenário: GMUD falhou e precisa reverter estado**

#### **Método 1: Via GUI (Recomendado)**

1. **Deletar Users criados**:
   - Navegar para **Users → All users**
   - Filtrar por `name` contém `"00"`
   - Selecionar Users `001`, `002`, `003`
   - **Delete** (confirmar exclusão)

2. **Deletar Resource**:
   - GUI: **Resources → CSV-Employee-Source → Delete**

3. **Validar limpeza**:
   - Buscar `CSV-Employee-Source` → **não encontrado**
   - Buscar Users `001`, `002`, `003` → **não encontrados**

**Tempo estimado de rollback**: 5 minutos

---

#### **Método 2: Via REST API (Avançado)**

**⚠️ AJUSTE v1.1 – Procedimento correto:**

O endpoint REST do midPoint espera **OID**, não `name`.

**Passo 1: Buscar OIDs dos Users**

```bash
curl -u administrator:senha   -H "Accept: application/json"   "http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/users?query=name+matches+'00.*'"   | jq -r '.[] | .oid'
```

**Saída esperada**:
```
a1b2c3d4-e5f6-7890-abcd-ef1234567890
b2c3d4e5-f6a7-8901-bcde-fa2345678901
c3d4e5f6-a7b8-9012-cdef-ab3456789012
```

**Passo 2: Deletar Users via OID**

```bash
# Substituir {oid} pelos valores reais
curl -u administrator:senha -X DELETE   "http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/users/{oid}"
```

**Passo 3: Deletar Resource**

```bash
# Buscar OID do Resource
curl -u administrator:senha   "http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/resources?query=name+eq+'CSV-Employee-Source'"   | jq -r '.oid'

# Deletar Resource
curl -u administrator:senha -X DELETE   "http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/resources/{resource-oid}"
```

**📌 LIÇÃO APRENDIDA v1.1:**

Nunca usar `DELETE /users/001` diretamente.  
Sempre buscar OID antes → `DELETE /users/{oid}`.

---

### **5.2. Rollback Parcial (Apenas Resource)**

Se Users devem ser preservados:

1. Deletar apenas Resource `CSV-Employee-Source`
2. Shadows serão desvinculados automaticamente
3. Users permanecem no midPoint como objetos órfãos

**Uso**: Para reconfigurar Resource sem perder dados de User.

---

## **🔹 6. Registro de Execução**

### **6.1. Template de Log**

```markdown
## GMUD-024 v1.1 – Execução

**Data**: 11/01/2026  
**Executor**: Paulo Feitosa  
**Início**: 14:00  
**Término**: 15:30  

### Checklist de Execução

- [x] Cold Start validado (POP-LAB-001-v1.7)
- [x] Resource CSV criado
- [x] Schema descoberto (5 atributos validados)
- [x] Object Type configurado (Kind=Account, Intent=default)
- [x] Inbound mappings definidos (employeeId → name, fullName)
- [x] Correlation rule configurada ($focus/name explícito)
- [x] Synchronization reactions definidas (UNMATCHED → addFocus)
- [x] Task Import executada com sucesso (3 Users criados)
- [x] Re-run idempotente validado (0 duplicações)
- [x] Validação REST API executada (count=3)

### Exceções e Desvios

**Nenhum desvio do procedimento padrão.**

### Observações Técnicas

- Correlation rule ajustada para `$focus/name` (robustez futura)
- Rollback documentado com busca de OID via REST API
- Decisão arquitetural: `User.name` = identificador técnico (não login humano)

### Próxima Ação

- Documentar lições aprendidas em KB-002
- Criar GMUD-025 para integração com AD (outbound mappings)
```

---

## **🔹 7. Referências**

- **POP-LAB-001-v1.7**: Procedimento de Cold Start Diário
- **Manifesto de Governança de Dados HR Source**: Padrões de correlação e qualidade de dados
- **midPoint Documentation**: 
  - [Schema Handling](https://docs.evolveum.com/midpoint/reference/resources/resource-configuration/schema-handling/)
  - [Synchronization](https://docs.evolveum.com/midpoint/reference/synchronization/introduction/)
  - [Correlation and Confirmation Expressions](https://docs.evolveum.com/midpoint/reference/synchronization/correlation-and-confirmation-expressions/)
- **ISO 27001:2022**: A.9.2.1 (User registration and de-registration)
- **NIST CSF 2.0**: PR.AC-1 (Identities and credentials management)

---

## **🔹 8. Controle de Versão**

| **Versão** | **Data** | **Autor** | **Mudanças Principais** |
|------------|----------|-----------|-------------------------|
| 1.0 | 11/01/2026 14:00 | Paulo Feitosa | Criação inicial da GMUD-024 |
| 1.1 | 11/01/2026 18:32 | Paulo Feitosa | **Ajustes técnicos:**<br>- Correlation rule: `$focus/name` explícito<br>- Rollback via REST: documentado busca de OID<br>- Decisão arquitetural: `User.name` como ID técnico explicitada<br>- Anti-padrões: adicionados 2 novos itens |

---

## **🔹 9. Decisões Arquiteturais Documentadas**

### **9.1. User.name como Identificador Técnico**

**Decisão**: `employeeId` → `User.name` com `strength=strong`

**Contexto**: HR Source é fonte autoritativa única

**Consequências**:
- ✅ Rastreabilidade total (User.name = chave estável)
- ✅ Correlação determinstica
- ⚠️ Login humanizado (ex: `paulo.silva`) deve vir de mapping adicional para AD
- ⚠️ Se múltiplas fontes coexistirem, revisar estratégia

**Alternativas consideradas**:
- Gerar `User.name` humanizado via script → descartado (quebra rastreabilidade)
- Usar extensionProperty customizado → descartado (complexidade desnecessária para LAB)

**Reversão**: Requer nova GMUD com remapping + reconcile full

---

### **9.2. Correlation Rule com $focus Explícito**

**Decisão**: Usar `$focus/name` em vez de `name` genérico

**Motivo**: Preparação para cenários futuros (roles, orgs, múltiplas personas)

**Trade-off**: Verbosidade adicional sem ganho funcional imediato

**Benefício**: Código auto-documentado e maintainable

---

## **🔹 10. Aprovações**

| **Papel** | **Nome** | **Assinatura** | **Data** |
|-----------|----------|----------------|----------|
| **Owner** | Paulo Feitosa | _Aprovado_ | 11/01/2026 |
| **Revisor Técnico** | _A definir_ | _Pendente_ | _A definir_ |
| **Aprovador GRC** | _A definir_ | _Pendente_ | _A definir_ |

---

## **🔹 11. Anexos**

### **11.1. Exemplo de Arquivo CSV Completo**

```csv
employeeId,firstName,lastName,department,jobTitle,email
001,Paulo,Silva,IT,System Administrator,paulo.silva@fiqueok.com.br
002,Maria,Santos,Finance,Financial Analyst,maria.santos@fiqueok.com.br
003,João,Costa,Marketing,Marketing Coordinator,joao.costa@fiqueok.com.br
004,Ana,Oliveira,HR,HR Manager,ana.oliveira@fiqueok.com.br
005,Carlos,Mendes,IT,Security Analyst,carlos.mendes@fiqueok.com.br
```

### **11.2. Script de Validação Pós-Execução**

```bash
#!/bin/bash
# Validar execução da GMUD-024 v1.1

MIDPOINT_URL="http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest"
ADMIN_USER="administrator"
ADMIN_PASS="senha"

echo "=== GMUD-024 v1.1 - Validação ==="

# 1. Contar Users criados
USER_COUNT=$(curl -s -u $ADMIN_USER:$ADMIN_PASS   "$MIDPOINT_URL/users" | grep -c "<name>00")

echo "Users criados: $USER_COUNT (esperado: 3)"

# 2. Verificar Resource existe
RESOURCE_EXISTS=$(curl -s -u $ADMIN_USER:$ADMIN_PASS   "$MIDPOINT_URL/resources" | grep -c "CSV-Employee-Source")

echo "Resource existe: $RESOURCE_EXISTS (esperado: 1)"

# 3. Verificar Shadows vinculados
# (requer jq instalado)
LINKED_COUNT=$(curl -s -u $ADMIN_USER:$ADMIN_PASS   -H "Accept: application/json"   "$MIDPOINT_URL/shadows" | jq '[.[] | select(.synchronizationSituation == "LINKED")] | length')

echo "Shadows LINKED: $LINKED_COUNT (esperado: 3)"

# 4. Validação final
if [ "$USER_COUNT" -eq 3 ] && [ "$RESOURCE_EXISTS" -eq 1 ] && [ "$LINKED_COUNT" -eq 3 ]; then
  echo "✅ GMUD-024 v1.1 VALIDADA COM SUCESSO"
  exit 0
else
  echo "❌ GMUD-024 v1.1 FALHOU - RNC obrigatória"
  exit 1
fi
```

---

**Localização no Repositório**:  
`10-Projetos/PRJ-001-LABORATORIO/30-Operacao-Mudancas/GMUD-024-v1.1.md`

**Localizações Alternativas**:
- `20-Areas/01-SGSI-Fiqueok/05-Operacao-e-Procedimentos/GMUDs/GMUD-024-v1.1.md`
- `FiqueokBrain/Operacao-Mudancas/GMUD-024-v1.1.md`

---

## **📌 Nota Final – v1.1**

Esta versão incorpora ajustes técnicos recomendados para **robustez arquitetural** e **maintainability**:

1. **Correlation rule** com `$focus/name` explícito
2. **Rollback via REST** documentado com busca de OID
3. **Decisão arquitetural** sobre `User.name` explicitamente justificada
4. **Anti-padrões** expandidos com 2 novos itens

**Status**: ✅ Pronta para execução em ambiente de produção (LAB PRJ001)

**Próxima evolução**: GMUD-025 - Outbound mappings para Active Directory

---

*Documento gerado em 11/01/2026 18:32 -03*  
*Versão técnica revisada com base em feedback arquitetural*

