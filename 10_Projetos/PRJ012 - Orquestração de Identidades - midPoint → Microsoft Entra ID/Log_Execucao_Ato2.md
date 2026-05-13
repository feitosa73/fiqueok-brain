### 📓 PRJ012 — ATO 2: Validação midPoint → Entra ID (Dry Run e Reconciliação)

**Data/Hora da Execução:** `2026-03-10 14:30` **Responsável:** `Paulo Feitosa Lima` **Projeto:** `PRJ012 — Orquestração de Identidades` **Fase:** ATO 2 — midPoint → Entra ID (Dry Run e Reconciliação)

#### 🔐 Identificadores Utilizados

- **Application (Client) ID:** `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
    
- **Tenant ID:** `503bbd0e-f33f-4ebe-b12e-f24a506978c9`
    
- **Vault Path:** `secret/prj012/entra-connector`
    
- **Resource midPoint:** `AzureAD-GraphAPI-PRJ012`
    

#### 📜 Configuração Executada

- Conector Microsoft Graph API instalado no midPoint.
    
- Resource criado com credenciais via Vault (Zero Plaintext).
    
- Schema importado com atributos: `displayName`, `userPrincipalName`, `employeeId`, `department`, `jobTitle`, `accountEnabled`.
    
- Âncora de correlação definida: `employeeId`.
    

#### 🧪 Dry Run — Resultados

- **Usuários LINKED:** `100`
    
- **Usuários UNMATCHED:** `0`
    
- **Alterações destrutivas:** `Nenhuma`
    
- **Status:** ✅ OK
    

#### 📂 Reconciliação Real (Read Mode)

- Shadows criados no midPoint: `100`
    
- Logs de auditoria confirmam importação sem erros.
    
- Evidência JSON arquivada em: `...\PRJ012\Evidencias\Ato2\PRJ012_ATO2_Validation.json`
    

#### 📂 Evidências Coletadas

- Relatório de reconciliação (Dry Run).
    
- Relatório de reconciliação (Read Mode).
    
- Logs de auditoria do midPoint.
    
- Arquivo JSON com métricas (UsersCount, GroupsCount, ShadowsCount).
    
- Screenshots da configuração do Resource no midPoint.
