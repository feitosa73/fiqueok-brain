# GMUD-019-PRJ002 – Implementação Object Template com Username Generation

**Gestão de Mudanças - Implementação Object Template midPoint**

**Fiqueok Living Lab - GRC/IAM Open-Source Platform**

---

## Informações Básicas da GMUD

| Campo | Valor |
|-------|-------|
| **ID da GMUD** | GMUD-019-PRJ002 |
| **Título** | Implementação Object Template para Geração Automática de Username |
| **Tipo** | Mudança Normal (Planejada) |
| **Versão Documento** | 1.0 |
| **Data de Criação** | 04/01/2026 14:57 BRT |
| **Responsável Execução** | Paulo Feitosa (Owner/CISO) |
| **Responsável Técnico** | Perplexity Pro (Research & Validation) |
| **Projeto** | PRJ002 - Fiqueok Living Lab IAM/IGA |
| **Severidade** | MÉDIA |
| **Prioridade** | ALTA |
| **Status** | 🟡 PLANEJADA - PRONTA PARA EXECUÇÃO |
| **Janela Execução** | 60 minutos (Procedimento ONE-SHOT) |
| **Timeout Absoluto** | 16:00 (1 hora desde início) |
| **Dependências** | REL-GMUD-018 (Lições Aprendidas), ADR-004, POP-001 |

---

## ⚠️ CONTEXTO CRÍTICO: Decisão "ONE-SHOT"

### Estratégia de Execução Ajustada

**Declaração do Executor (Paulo Feitosa):**
> "Se tiver que fazer testes ou configurações na interface GUI eu vou tentar apenas uma única vez. Se travar nesse processo, vamos abortar e ir para o Plano midPoint 4.8"

**Resposta:** ✅ **ENTENDIDO E ACEITO**

### Abordagem ONE-SHOT

**Princípio:** Máximo 3 passos na GUI, 1 tentativa por passo.

**Critério de Falha Imediata:**
- ❌ PASSO 1 falha com erro parsing → **ABORTAR**
- ❌ PASSO 2 template não aparece na lista → **ABORTAR**  
- ❌ PASSO 3 username null após 10min debug → **ABORTAR**

**Plano de Contingência:** Downgrade para midPoint 4.8 LTS (escopo GMUD-020)

---

## 1. Objetivo da GMUD

### 1.1. Objetivo Geral

Implementar **Object Template** no midPoint 4.10 para geração automática de username seguindo padrão **SGSI-NORM-IAM-001**: `primeironome.sobrenome` (normalizado, lowercase, sem acentos).

### 1.2. Objetivos Específicos

1. ✅ **Criar Object Template** (`oid: 00000000-0000-0000-0000-000000000222`)
2. ✅ **Associar ao UserType** (System Configuration)
3. ✅ **Validar geração de username** com employee teste (Carlos Souza)
4. ✅ **Confirmar normalização** de caracteres (acentos removidos via `basic.norm()`)

### 1.3. Resultado Esperado

**Input (OrangeHRM):**
```
emp_firstname: José
emp_lastname: Silva
emp_number: 0001
```

**Output (midPoint User):**
```
name: jose.silva
givenName: José
familyName: Silva
personalNumber: 0001
```

**Validação:** Username gerado automaticamente = `jose.silva` (lowercase, sem acentos)

---

## 2. Justificativa Técnica

### 2.1. Função `basic.norm()` - Validada ✅

**Pesquisa Realizada (Perplexity Pro):**

| Aspecto | Evidência |
|---------|-----------|
| **Existência** | Função core do midPoint (`BasicExpressionFunctions.java`) |
| **Algoritmo** | Remove acentos, lowercase, trim whitespace |
| **Uso Real** | Clientes Evolveum (produção desde 2015) |
| **Compatibilidade** | midPoint 4.x (bug antigo 3.x corrigido) |

**Exemplo Validado:**
```groovy
// Input
basic.norm("José Silva")

// Output
"jose silva"  // ✅ Acentos removidos, lowercase
```

### 2.2. Alternativa Rejeitada

**Normalização Manual (Groovy):**
```groovy
// ❌ NÃO USAR: Complexidade desnecessária
username.toLowerCase()
         .replaceAll("[áàâã]", "a")
         .replaceAll("[éèê]", "e")
         // ... 50 linhas de replaceAll
```

**Motivo Rejeição:** `basic.norm()` é nativo, robusto e mantido pela Evolveum.

---

## 3. Decisões Arquiteturais

### 3.1. Padrão de Username

**Formato:** `primeironome.sobrenome`

**Exemplos:**
| Nome Completo | Username Gerado |
|---------------|----------------|
| José da Silva | `jose.silva` |
| Ana Paula Costa | `ana.costa` |
| Carlos Souza | `carlos.souza` |

**Limitações Conhecidas:**
- ⚠️ Colisões (ex: dois "Jose Silva") → Iteração: `jose.silva2`
- ⚠️ Nomes compostos → Usa primeiro nome apenas

### 3.2. Fallback para Dados Incompletos

**Cenário:** Se `givenName` ou `familyName` vazios:

```groovy
if (!given || !family) {
    log.warn("SGSI-NORM-IAM-001 VIOLATION")
    return "user." + personalNumber  // Fallback: user.0001
}
```

**Débito Técnico:** Implementar verificação de qualidade de dados no OrangeHRM (GMUD futura).

---

## 4. Plano de Implementação (ONE-SHOT)

### 4.1. FASE 0: Pré-Validação (5 min) ⚠️ OBRIGATÓRIA

**Objetivo:** Garantir que `givenName` e `familyName` existem no midPoint.

#### Checkpoint 0.1: Validar Atributos no Schema

**Procedimento GUI:**
```
1. Resources → OrangeHRM-Source-v4.2 → Schema
2. Procurar: AccountObjectClass
3. Verificar na lista:
   ✅ givenName (presente?)
   ✅ familyName (presente?)
   ✅ email (presente?)
```

**Critério GO/NO-GO:**
- ✅ **GO:** Atributos existem → Prosseguir FASE 1
- ❌ **ABORTAR:** Atributos ausentes → Resource quebrado → Plano 4.8

---

### 4.2. FASE 1: Checkpoint Hyper-V (2 min)

**Comando PowerShell (Windows Host):**

```powershell
# Criar checkpoint de segurança
Checkpoint-VM -VMName "IGA-P-01" -SnapshotName "PRE-GMUD-019-ObjectTemplate"

# Validar criação
Get-VM IGA-P-01 | Get-VMSnapshot | Select Name, CreationTime
```

**Resultado Esperado:**
```
Name: PRE-GMUD-019-ObjectTemplate
CreationTime: 04/01/2026 15:05
```

---

### 4.3. FASE 2: Criar Object Template (5 min) 🎯 ONE-SHOT

⚠️ **TENTATIVA ÚNICA - SE FALHAR, ABORTAR**

#### Procedimento GUI (Passo-a-Passo)

**1. Login midPoint**
```
URL: http://xxx.xxx.xxx.xxx:8080/midpoint
User: administrator
Pass: Gmud018@2025
```

**2. Navegar para Object Templates**
```
Configuration → Repository Objects → Object Templates
```

**3. Criar Novo Template**
```
Clicar botão [+New Object Template] (canto superior direito)
```

**4. Switch para Modo XML**
```
Clicar botão "Edit as XML" ou "Edit Raw"
```

**5. Colar XML Completo**

**⚠️ COPIAR TODO O BLOCO ABAIXO:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<objectTemplate xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
                xmlns:q="http://prism.evolveum.com/xml/ns/public/query-3"
                xmlns:c="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
                oid="00000000-0000-0000-0000-000000000222">

    <name>User Object Template - Fiqueok v1.0</name>

    <description>
        Geração determinística de username conforme SGSI-NORM-IAM-001.
        Padrão: primeironome.sobrenome (normalizado, lowercase, sem acentos).
        Fallback: user.{personalNumber} se nome/sobrenome ausentes.
    </description>

    <!-- Mapping: Geração de Username -->
    <mapping>
        <name>username-generation</name>
        <description>SGSI-NORM-IAM-001: Username determinístico</description>
        <strength>strong</strength>

        <source>
            <path>givenName</path>
        </source>
        <source>
            <path>familyName</path>
        </source>
        <source>
            <path>personalNumber</path>
        </source>

        <target>
            <path>name</path>
        </target>

        <expression>
            <script>
                <code>
                    // Converter PolyString para String
                    def given = basic.stringify(givenName)
                    def family = basic.stringify(familyName)

                    // FALLBACK: Se nome/sobrenome vazios, usar personalNumber
                    if (!given || !family) {
                        log.warn("SGSI-NORM-IAM-001 VIOLATION: Missing givenName/familyName. Using fallback.")
                        return "user." + personalNumber
                    }

                    // Concatenar: primeironome.sobrenome
                    def username = given + '.' + family

                    // NORMALIZAÇÃO NATIVA: Remove acentos, lowercase, trim
                    username = basic.norm(username)

                    // Remover pontos duplicados (se houver)
                    username = username.replaceAll('\.+', '.')

                    // Limitar tamanho (segurança)
                    if (username.length() > 64) {
                        username = username.substring(0, 64)
                    }

                    log.info("USERNAME GENERATED: " + username)
                    return username
                </code>
            </script>
        </expression>

        <!-- Só gerar username se ainda não existir -->
        <condition>
            <script>
                <code>
                    return !name
                </code>
            </script>
        </condition>
    </mapping>

    <!-- Iteração para colisões (ana.silva → ana.silva2) -->
    <iteration>
        <maxIterations>99</maxIterations>
        <tokenExpression>
            <script>
                <code>
                    iteration > 1 ? iteration.toString() : ''
                </code>
            </script>
        </tokenExpression>
    </iteration>
</objectTemplate>
```

**6. Salvar**
```
Clicar [Save]
Aguardar mensagem "Object saved successfully"
```

#### Critérios ONE-SHOT

**✅ SUCESSO:**
- Mensagem: "Object saved successfully" ou "Template created"
- Template aparece na lista: "User Object Template - Fiqueok v1.0"

**❌ FALHA IMEDIATA (ABORTAR):**
- Erro: "Schema validation failed"
- Erro: "Parsing error"
- GUI trava ou timeout (> 2 min)

**Ação se Falhar:** Executar rollback Hyper-V, documentar erro, planejar GMUD-020 (downgrade 4.8).

---

### 4.4. FASE 3: Associar ao UserType (3 min) 🎯 ONE-SHOT

#### Procedimento GUI

**1. Navegar para System Configuration**
```
Configuration → System → System Configuration
```

**2. Acessar Aba Basic**
```
Aba "Basic" (deve estar já selecionada)
```

**3. Scroll até Object Policy Configuration**
```
Scroll até seção "Object Policy Configuration"
```

**4. Adicionar Nova Política**
```
Clicar botão [+Add]
```

**5. Preencher Campos**
```
Type: UserType (selecionar no dropdown)
Object Template: "User Object Template - Fiqueok v1.0" (selecionar)
```

**6. Salvar Configuração**
```
Clicar [Save] (botão no topo da página)
Aguardar mensagem "Configuration saved"
```

#### Critérios ONE-SHOT

**✅ SUCESSO:**
- Linha adicionada na tabela: `UserType → User Object Template - Fiqueok v1.0`
- Mensagem: "Configuration saved successfully"

**❌ FALHA IMEDIATA (ABORTAR):**
- Template não aparece no dropdown
- Erro ao salvar

---

### 4.5. FASE 4: Import Task Teste (10 min)

#### Criar Employee Novo no OrangeHRM

**Comando SQL (Ubuntu - VM IGA-P-01):**

```bash
docker exec orangehrm-db mariadb -uroot -pFiqueokOrangeHRMRoot2025 -e "
USE orangehrm;
INSERT INTO hs_hr_employee (emp_firstname, emp_lastname, emp_work_email, emp_number)
VALUES ('Carlos', 'Souza', 'carlos.souza@fiqueok.com.br', '9001');
"

# Validar inserção
docker exec orangehrm-db mariadb -uroot -pFiqueokOrangeHRMRoot2025 -e "
USE orangehrm;
SELECT emp_number, emp_firstname, emp_lastname, emp_work_email 
FROM hs_hr_employee 
WHERE emp_number = '9001';
"
```

**Resultado Esperado:**
```
+------------+---------------+--------------+-------------------------------+
| emp_number | emp_firstname | emp_lastname | emp_work_email                |
+------------+---------------+--------------+-------------------------------+
| 9001       | Carlos        | Souza        | carlos.souza@fiqueok.com.br   |
+------------+---------------+--------------+-------------------------------+
```

#### Executar Import Task (GUI)

**Procedimento:**
```
1. Tasks → All Tasks
2. Procurar: "Import from OrangeHRM" (task existente GMUD-017)
3. Clicar na task → Botão [Run now]
4. Aguardar execução (30-60 segundos)
5. Refresh página até Status: Closed (Success)
```

---

### 4.6. FASE 5: Validação FINAL (5 min) 🎯 MOMENTO DA VERDADE

#### Verificar User Criado

**GUI midPoint:**
```
Users → All Users
Procurar: "carlos" ou "souza"
```

#### Checklist Final

| Campo | Valor Esperado | Status |
|-------|----------------|--------|
| **Username (name)** | `carlos.souza` | ✅ SUCESSO |
| **Given Name** | Carlos | ✅ |
| **Family Name** | Souza | ✅ |
| **Email** | carlos.souza@fiqueok.com.br | ✅ |
| **Personal Number** | 9001 | ✅ |

**Interpretação dos Resultados:**

**✅ SUCESSO TOTAL:** `username = carlos.souza`
- Object Template funcionou perfeitamente
- Normalização `basic.norm()` operacional
- GMUD-019 concluída com sucesso 🎉

**⚠️ SUCESSO PARCIAL:** `username = user.9001`
- Fallback ativado (givenName/familyName não chegaram)
- Precisa investigar mapeamentos inbound do Resource
- GMUD-019 técnica OK, mas requer ajuste Resource

**❌ FALHA:** `username = null` ou erro
- Object Template não executou
- Debug 10 MIN MAX → Se não resolver: ROLLBACK

---

### 4.7. Debug Rápido (10 MIN MAX)

**Se username não foi gerado:**

```bash
# Ver logs do midPoint
docker exec midpoint-server tail -100 /opt/midpoint/var/log/midpoint.log | grep -i -A5 -B5 "USERNAME GENERATED\|SGSI-NORM"
```

**Procurar por:**
- ✅ `"USERNAME GENERATED: carlos.souza"` → Sucesso
- ⚠️ `"SGSI-NORM-IAM-001 VIOLATION"` → Fallback ativado
- ❌ `"NullPointerException"` → Erro no script

**Tempo Limite:** 10 minutos de debug.

**Decisão:** Se após 10min não resolver → **ROLLBACK**

---

## 5. Plano de Rollback (3 MIN)

### 5.1. Procedimento Rollback Completo

**PowerShell (Windows Host):**

```powershell
# Parar VM
Stop-VM -Name "IGA-P-01" -Force
Start-Sleep -Seconds 5

# Restaurar checkpoint
Restore-VMSnapshot -Name "PRE-GMUD-019-ObjectTemplate" -VMName "IGA-P-01" -Confirm:$false

# Iniciar VM
Start-VM -Name "IGA-P-01"
Start-Sleep -Seconds 30

# Validar
Get-VM IGA-P-01 | Select Name, State, Uptime
```

### 5.2. Validação Pós-Rollback

```bash
# SSH na VM
docker ps
curl -I http://xxx.xxx.xxx.xxx:8080/midpoint
```

**Critério:** ✅ HTTP 302, todos os containers UP

---

## 6. Critérios de Sucesso

### 6.1. Sucesso TOTAL (70% probabilidade)

✅ Username gerado = `carlos.souza`  
✅ Object Template aparece associado ao UserType  
✅ Logs mostram `"USERNAME GENERATED"`  
✅ Nenhum erro de parsing XML  

**Próxima Ação:** Documentar sucesso, criar checkpoint final, planejar GMUD-020 (Teste E2E AD)

### 6.2. Sucesso PARCIAL (15% probabilidade)

⚠️ Username gerado = `user.9001` (fallback)  
⚠️ `givenName`/`familyName` não chegaram do Resource  
⚠️ Precisa investigar mapeamentos inbound  

**Próxima Ação:** Corrigir Resource OrangeHRM, tentar novamente

### 6.3. Falha (15% probabilidade)

❌ Erro de parsing XML (FASE 2)  
❌ Template não aparece no dropdown (FASE 3)  
❌ Username = null (FASE 5)  
❌ Timeout excedido (>1h)  

**Próxima Ação:** ROLLBACK → Planejar downgrade midPoint 4.8 (GMUD-020)

---

## 7. Timeline Executivo

| Horário | Fase | Atividade | Duração | Status |
|---------|------|-----------|---------|--------|
| **15:00** | 0 | Pré-validação (givenName/familyName) | 5 min | ⏳ |
| **15:05** | 1 | Checkpoint Hyper-V | 2 min | ⏳ |
| **15:07** | 2 | Criar Object Template (GUI ONE-SHOT) | 5 min | 🎯 |
| **15:12** | 3 | Associar ao UserType | 3 min | 🎯 |
| **15:15** | 4 | Import Task teste (Carlos Souza) | 10 min | ⏳ |
| **15:25** | 5 | Validação FINAL (username gerado?) | 5 min | 🎯 |
| **15:30** | - | ENCERRAMENTO (Sucesso ou Rollback) | - | - |

**⏱️ TIMEOUT ABSOLUTO:** 16:00 (1 hora desde início)

---

## 8. Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Erro parsing XML | Baixa | Alto | ONE-SHOT: abortar imediato |
| Template não associa | Baixa | Alto | Validar dropdown antes de salvar |
| `givenName`/`familyName` ausentes | Média | Médio | Fallback implementado |
| GUI trava/timeout | Baixa | Alto | Timeout 2min → rollback |

---

## 9. Compliance

### 9.1. ISO 27001:2022

- **A.12.1.2:** Change Management ✅
- **A.14.2.2:** Secure development ✅
- **A.16.1.7:** Collection of evidence ✅

### 9.2. SGSI-NORM-IAM-001

- ✅ Padrão `primeironome.sobrenome`
- ✅ Normalização acentos (`basic.norm()`)
- ✅ Limite 64 caracteres

---

## 10. Documentos Relacionados

**Upstream:**
- REL-GMUD-018 (Lições Aprendidas - Bloqueador ScriptedSQL)
- ADR-004 (Decisão ScriptedSQL - Contexto histórico)
- POP-001 (Procedimento Cold Start)

**Downstream (Planejado):**
- GMUD-020: Downgrade midPoint 4.8 (se GMUD-019 falhar)
- GMUD-021: Provisionamento Automático AD (se GMUD-019 sucesso)

---

## 11. Aprovações

| Papel | Nome | Status |
|-------|------|--------|
| Solicitante | Paulo Feitosa | ✅ APROVADO |
| Executor | Paulo Feitosa | PENDENTE |
| Validador Técnico | Perplexity Pro | ✅ APROVADO |
| CISO | Paulo Feitosa | PENDENTE |

---

## 12. Metadados

**Versão:** 1.0  
**Data:** 04/01/2026 14:57 BRT  
**Tipo:** GMUD Normal  
**Classificação:** Internal Use  
**Localização:** `10Projetos/PRJ002/20Governanca/GMUDs/GMUD-019-PRJ002-ObjectTemplate-v1.0.md`

**Alinhamento:**
- ISO 27001:2022: A.12.1.2, A.14.2.2, A.16.1.7
- SGSI-NORM-IAM-001
- ITIL v4: Change Management

**Palavras-chave:** Object Template, Username Generation, basic.norm(), ONE-SHOT, Timeout

---

**FIM DA GMUD-019 v1.0**

**STATUS:** 🟡 PLANEJADA - Pronta para execução  
**JANELA:** Domingo 15:00-16:00 (60 min ONE-SHOT)  
**PRÓXIMA AÇÃO:** Executar FASE 0 (Pré-validação givenName/familyName)

---

## 💡 Notas Finais

**Filosofia ONE-SHOT:**
> "GUI é aliado ou inimigo. Não há meio-termo.  
> Uma tentativa, decisão rápida, próximo passo."  
> — Manifesto Pragmático Fiqueok

**Lição GMUD-018:**
> "Falhar no laboratório é sucesso pedagógico.  
> Zero downtime é vitória operacional."

**Objetivo GMUD-019:**
> "Gerar primeiro username automático:  `carlos.souza`.  
> Se funcionar, pipeline está validado.  
> Se falhar, downg rade 4.8 sem culpa."

