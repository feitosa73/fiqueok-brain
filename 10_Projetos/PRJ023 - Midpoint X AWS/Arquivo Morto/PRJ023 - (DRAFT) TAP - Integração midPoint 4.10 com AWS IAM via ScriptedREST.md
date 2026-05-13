## ✅ **Análise da Orientação do Gemini**

A orientação da Gemini está **tecnicamente correta e estrategicamente alinhada** com a arquitetura que vínhamos discutindo. Vamos avaliar:

---

## 📊 **Avaliação de Probabilidade de Sucesso**

| Critério | Análise | Probabilidade |
|----------|---------|---------------|
| **ScriptedREST Connector** | ✅ Já presente no midPoint (confirmado) | Alta |
| **Credenciais AWS** | ✅ Já criadas (`midpoint-connector`) | Alta |
| **Variáveis de ambiente** | ✅ Já configuradas (SHADOW_API_KEY funcionou) | Alta |
| **Scripts Groovy** | ⚠️ Desafio: AWS Signature V4 para autenticação | Média |
| **Test Connection** | ⚠️ Depende da implementação correta da assinatura | Média |
| **Reconciliação** | ✅ Modelo similar ao CSV já funciona | Alta |

### **Probabilidade Geral de Sucesso: ~65-75%**

**Riscos identificados:**
- A AWS exige **Signature V4** nas chamadas REST (complexa de implementar em Groovy puro)
- O ScriptedREST pode ter limitações com headers de autorização dinâmicos

---

## 📋  - Integração midPoint com AWS IAM via ScriptedREST**

---

## **TAP - Technical Assessment Plan**
### **PRJ023: 

---

| Campo | Valor |
|-------|-------|
| **Projeto** | PRJ023 |
| **Título** | Integração midPoint com AWS IAM via ScriptedREST |
| **Data** | Maio/2026 |
| **Status** | 📝 Em Planejamento |
| **Responsável** | Paulo Feitosa Lima |
| **Pré-requisito** | PRJ022-A (CSV → midPoint → AD) funcionando |
| **Documentos Base** | PRJ022 POP v1.4, PRJ022 Relatório ANálise Técnica |

---

## 1. Objetivo

Estabelecer integração entre o **midPoint 4.10** e a **AWS IAM** utilizando o **ScriptedREST Connector**, permitindo o provisionamento automático de usuários IAM a partir dos dados do OrangeHRM (via CSV/Shadow API).

---

## 2. Escopo

### 2.1. Dentro do Escopo

| Item | Descrição |
|------|-----------|
| ✅ | Criar Resource AWS no midPoint usando ScriptedREST Connector |
| ✅ | Implementar scripts Groovy para operações IAM |
| ✅ | Provisionar usuários IAM na AWS (CreateUser) |
| ✅ | Correlacionar usuários existentes (ListUsers) |
| ✅ | Documentar scripts e configurações |

### 2.2. Fora do Escopo

| Item | Justificativa |
|------|---------------|
| ❌ | Provisionamento de grupos e políticas | Foco no usuário básico |
| ❌ | AWS Identity Center (SSO) | Complexidade adicional |
| ❌ | Remoção/desativação de usuários | Fase posterior |
| ❌ | Build Maven do conector | Usaremos ScriptedREST existente |

---

## 3. Arquitetura Proposta

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PRJ023 - midPoint ↔ AWS IAM via ScriptedREST             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐     ┌─────────────────────────────────────────────────────┐│
│  │  Shadow API │     │                    midPoint                         ││
│  │  (PRJ008)   │────▶│  ┌───────────────────────────────────────────────┐  ││
│  └─────────────┘     │  │            Recurso CSV (PRJ022-A)             │  ││
│                      │  │  employee_id, first_name, last_name...        │  ││
│                      │  └───────────────────┬───────────────────────────┘  ││
│                      │                      │                               ││
│                      │                      ▼                               ││
│                      │  ┌───────────────────────────────────────────────┐  ││
│                      │  │         Resource AWS (ScriptedREST)           │  ││
│                      │  │  ┌─────────────────────────────────────────┐  │  ││
│                      │  │  │ SearchScript.groovy (GET /ListUsers)    │  │  ││
│                      │  │  │ CreateScript.groovy (POST /CreateUser)  │  │  ││
│                      │  │  └─────────────────────────────────────────┘  │  ││
│                      │  └───────────────────┬───────────────────────────┘  ││
│                      │                      │                               ││
│                      │                      │ HTTPS + Signature V4         ││
│                      │                      ▼                               ││
│                      │  ┌───────────────────────────────────────────────┐  ││
│                      │  │                    AWS IAM                     │  ││
│                      │  │  • IAM User: david.velez                      │  ││
│                      │  │  • Tags: employeeID=FP001                     │  ││
│                      │  │  • Path: /fiqueok-lab/                        │  ││
│                      │  └───────────────────────────────────────────────┘  ││
│                      │                                                      ││
│                      └──────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Pré-Requisitos

| # | Requisito | Status | Critério |
|---|-----------|--------|----------|
| PR-01 | PRJ022-A funcionando (CSV) | ✅ | 103 usuários processados |
| PR-02 | Credenciais AWS IAM | ✅ | `midpoint-connector` com Access Key |
| PR-03 | Variáveis ambiente AWS no container | ⏳ | Adicionar ao docker-compose.yml |
| PR-04 | ScriptedREST Connector presente | ✅ | Confirmado no midPoint |
| PR-05 | Pasta `/opt/midpoint/var/scripts/` | ✅ | Já existe (scripts do PRJ022-B) |
| PR-06 | Snapshot de segurança | ✅ | PRJ022-B-Antes-Spike |

---

## 5. Plano de Execução

### **Fase 1: Preparação do Ambiente** (15 min)

```bash
# [iga-gf-02]$

# Adicionar variáveis AWS ao docker-compose.yml
sudo nano /srv/iga-project/docker-compose.yml

# Adicionar na seção environment do midpoint:
#   AWS_ACCESS_KEY_ID: 'AKIA...'
#   AWS_SECRET_ACCESS_KEY: '...'
#   AWS_DEFAULT_REGION: 'us-east-1'

# Reiniciar container
cd /srv/iga-project
sudo docker compose down
sudo docker compose up -d
sleep 30

# Verificar variáveis
sudo docker exec iga-midpoint env | grep AWS_
```

### **Fase 2: Desenvolvimento dos Scripts Groovy** (1 hora)

#### **2.1. AWS Signature V4 Helper (Biblioteca)**

```groovy
// /srv/iga-project/data/midpoint/scripts/AWSSignatureV4.groovy
// Helper para assinatura de requisições AWS
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec
import java.security.MessageDigest

def sign(request, accessKey, secretKey, region, service) {
    // Implementação da Signature V4
    // (será fornecida completa na execução)
}
```

#### **2.2. SearchScript.groovy (List Users)**

```groovy
// /srv/iga-project/data/midpoint/scripts/SearchScript.groovy
// Busca usuários IAM existentes para reconciliação
def AWS_ACCESS_KEY = System.getenv("AWS_ACCESS_KEY_ID")
def AWS_SECRET_KEY = System.getenv("AWS_SECRET_ACCESS_KEY")
def AWS_REGION = System.getenv("AWS_DEFAULT_REGION") ?: "us-east-1"

def listUsers() {
    // GET https://iam.amazonaws.com/?Action=ListUsers&Version=2010-05-08
    // Retorna lista de usuários para handler()
}
```

#### **2.3. CreateScript.groovy (Create User)**

```groovy
// /srv/iga-project/data/midpoint/scripts/CreateScript.groovy
// Cria usuário IAM quando novo registro é detectado
def createUser(attributes) {
    def userName = attributes.name
    def tags = [
        { Key: "employeeID", Value: attributes.personalNumber },
        { Key: "createdBy", Value: "midPoint" }
    ]
    // POST com parâmetros para CreateUser
}
```

### **Fase 3: Configuração do Resource AWS** (20 min)

1. **Resources** → **New resource** → **Create from scratch**
2. Selecione **ScriptedRESTConnector**
3. Configure:

| Configuração | Valor |
|--------------|-------|
| **Nome** | `AWS IAM (ScriptedREST)` |
| **Base URL** | `https://iam.amazonaws.com/` |
| **Service Name** | `iam` |
| **Region** | `us-east-1` |

4. **Schema handling** → **Add object type**:

| Campo | Valor |
|-------|-------|
| Kind | `account` |
| Intent | `aws-iam-user` |
| Display Name | `IAM User` |

5. **Mapeamentos**:

| Source (midPoint) | Target (AWS) |
|-------------------|--------------|
| `name` | `UserName` |
| `personalNumber` | `Tags.employeeID` |
| `givenName` | `Tags.firstName` |
| `familyName` | `Tags.lastName` |

### **Fase 4: Teste e Validação** (30 min)

| Teste | Comando/Procedimento | Critério |
|-------|----------------------|----------|
| Test Connection | GUI → Test connection | Success |
| Search/Reconciliação | Executar tarefa de reconciliação | Usuários existentes encontrados |
| Create User | Criar usuário teste no midPoint | Usuário aparece na AWS IAM |

---

## 6. Critério de Sucesso

| # | Critério | Métrica |
|---|----------|---------|
| 1 | Test Connection OK | Conexão bem-sucedida |
| 2 | Search retorna usuários | ListUsers funciona |
| 3 | CreateUser cria na AWS | Usuário aparece no console IAM |
| 4 | Reconciliation sem erros | Nenhum erro de provisionamento |

---

## 7. Critério de Rollback

| Falha | Ação |
|-------|------|
| Test Connection falha | Restaurar snapshot, documentar erro |
| Scripts Groovy não compilam | Validar sintaxe, reduzir complexidade |
| AWS Signature V4 não funciona | Substituir por abordagem mais simples (ex: usar CLI via shell) |
| Qualquer erro não resolvido em 2 horas | Restaurar snapshot e arquivar |

---

## 8. Cronograma Estimado

| Fase | Duração | Acumulado |
|------|---------|-----------|
| Preparação | 15 min | 15 min |
| Scripts Groovy | 1 hora | 1h15 |
| Configuração Resource | 20 min | 1h35 |
| Teste e Validação | 30 min | 2h05 |
| Documentação | 30 min | 2h35 |

**Total estimado: ~2.5 horas**

---

## 9. Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| AWS Signature V4 complexa | Alta | Alto | Usar SDK Java diretamente no Groovy |
| ScriptedREST incompatível Java 21 | Média | Alto | Validar antes com Test Connection |
| Rate limiting da AWS | Baixa | Médio | Implementar retry/exponential backoff |
| Mudança na API AWS | Baixa | Médio | Usar endpoints estáveis (2010-05-08) |

---

## 10. Entregáveis

| Entregável | Formato | Local |
|------------|---------|-------|
| Scripts Groovy | `.groovy` | `/srv/iga-project/data/midpoint/scripts/` |
| Resource XML | `.xml` | Exportado do midPoint |
| TAP Documento | `.md` | Obsidian PRJ023 |
| POP de Execução | `.md` | Obsidian PRJ023 |

---

## 11. Aprovações

| Função | Nome | Data | Decisão |
|--------|------|------|---------|
| Arquiteto IGA | Paulo Feitosa Lima | Maio/2026 | ✅ APROVADO |

---

## 12. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 04/05/2026 | Paulo Feitosa Lima | Criação do TAP para PRJ023 baseado na orientação do Gemini |

---

**Fim do TAP PRJ023**

---

*TAP - Technical Assessment Plan*  
*Living Lab Fiqueok*  
*PRJ023 - midPoint ↔ AWS IAM via ScriptedREST*