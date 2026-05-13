

---

**Versão:** 1.0 ✅ **VALIDADO** — Baseado nas diretrizes do TAP e nos padrões estabelecidos nos POPs anteriores  
**Data:** 06/05/2026  
**Responsável:** Paulo Feitosa Lima  
**Status:** ✅ Pronto para implementação

---

## ÍNDICE

1. [Objetivo do Documento](#1-objetivo-do-documento)
2. [Arquitetura da Solução](#2-arquitetura-da-solução)
3. [Conceitos Fundamentais (Leitura Obrigatória)](#3-conceitos-fundamentais-leitura-obrigatória)
4. [Pré-Requisitos Obrigatórios](#4-pré-requisitos-obrigatórios)
5. [Checklist de Pré-Verificação (Pre-Flight)](#5-checklist-de-pré-verificação-pre-flight)
6. [Procedimento de Rollback](#6-procedimento-de-rollback)
7. [FASE 1: Preparação do Entra ID (App Registration)](#7-fase-1-preparação-do-entra-id-app-registration)
8. [FASE 2: Instalação do Conector Graph](#8-fase-2-instalação-do-conector-graph)
9. [FASE 3: Criação do Resource Entra ID](#9-fase-3-criação-do-resource-entra-id)
10. [FASE 4: Configuração do Schema Handling](#10-fase-4-configuração-do-schema-handling)
11. [FASE 5: Regras de Segregação de Funções (SoD)](#11-fase-5-regras-de-segregação-de-funções-sod)
12. [FASE 6: Workflow de Aprovação](#12-fase-6-workflow-de-aprovação)
13. [FASE 7: Certificação de Acesso (Campanha)](#13-fase-7-certificação-de-acesso-campanha)
14. [FASE 8: Criação da Role Entra ID](#14-fase-8-criação-da-role-entra-id)
15. [FASE 9: Atribuição da Role ao Usuário](#15-fase-9-atribuição-da-role-ao-usuário)
16. [FASE 10: Execução e Validação](#16-fase-10-execução-e-validação)
17. [POP: Joiner Automático (Procedimento Operacional Padrão)](#17-pop-joiner-automático-procedimento-operacional-padrão)
18. [Resolução de Problemas Comuns](#18-resolução-de-problemas-comuns)
19. [Lições Aprendidas e Compliance](#19-lições-aprendidas-e-compliance)
20. [Decisões Arquiteturais para Futuro ERP (SSO)](#20-decisões-arquiteturais-para-futuro-erp-sso)
21. [Anexos: Comandos de Diagnóstico](#21-anexos-comandos-de-diagnóstico)
22. [Histórico de Versões](#22-histórico-de-versões)

---

## 1. Objetivo do Documento

Este Procedimento Operacional Padrão (POP) descreve o passo a passo para integrar o **midPoint 4.10** com o **Microsoft Entra ID** utilizando o **GraphConnector oficial** (Evolveum), estabelecendo não apenas conectividade, mas uma camada completa de **Governança de Acessos**.

Diferente dos projetos anteriores (PRJ023/AWS, PRJ024/GCP), este projeto implementa:

| Camada | PRJ023/024 (Anterior) | PRJ027 (Este POP) |
|--------|----------------------|-------------------|
| **Provisionamento** | Apenas criação de usuário | Usuário + Licenças + Grupos + Roles administrativas |
| **Workflow** | Ausente | Aprovação de 2 níveis (Manager + Security) |
| **Segregação (SoD)** | Não implementada | Regras ativas (ex: AdminInfra + Auditor = BLOCK) |
| **Certificação** | Não implementada | Campanha trimestral com reconciliação |
| **Auditoria ISO 27001** | Logs básicos | Evidência de aprovação + justificativa + rastreabilidade |

A solução consiste em:
1. App Registration no Entra ID com permissões Graph API
2. Instalação do conector oficial Graph
3. Resource com Schema Handling para usuários, licenças e grupos
4. Workflow de aprovação para provisionamento
5. Regras SoD para prevenção de conflitos
6. Tarefa de reconciliação para detecção de Shadow IT
7. Certificação periódica de acesso

---

## 2. Arquitetura da Solução

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                         PRJ027 - midPoint 4.10 → Microsoft Entra ID                  │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                         midPoint 4.10 (iga-gf-02)                                ││
│  │                         IP: xxx.xxx.xxx.xxx                                        ││
│  │                                                                                  ││
│  │  ┌─────────────┐    ┌─────────────────────────────────────────────────────────┐││
│  │  │  CSV HR     │───▶│  Usuário (ex: FP008)                                    │││
│  │  │  (PRJ022)   │    │  - name: FP008                                          │││
│  │  └─────────────┘    │  - givenName: Fernando                                  │││
│  │                     │  - familyName: Pereira                                  │││
│  │                     │  - email: fernando.pereira@fiqueok.com.br               │││
│  │                     └───────────────────────┬─────────────────────────────────┘││
│  │                                             │                                    ││
│  │                                             │ Atribuição da Role                 ││
│  │                                             ▼                                    ││
│  │  ┌─────────────────────────────────────────────────────────────────────────────┐││
│  │  │                    Role "Microsoft 365 E5"                                  │││
│  │  │  ┌───────────────────────────────────────────────────────────────────────┐  │││
│  │  │  │  Workflow de Aprovação (2 níveis)                                     │  │││
│  │  │  │  ├── Nível 1: Manager do usuário                                      │  │││
│  │  │  │  └── Nível 2: Security Owner (CISO/GRC)                               │  │││
│  │  │  └───────────────────────────────────────────────────────────────────────┘  │││
│  │  │                                                                              │││
│  │  │  ┌───────────────────────────────────────────────────────────────────────┐  │││
│  │  │  │  SoD Rules (Pré-provisionamento)                                      │  │││
│  │  │  │  ├── IF user.hasRole('AdminInfra') AND role.hasRole('Auditor') → BLOCK│  │││
│  │  │  │  └── IF user.hasRole('Financeiro') AND role.hasRole('Billing') → ALERT│  │││
│  │  │  └───────────────────────────────────────────────────────────────────────┘  │││
│  │  │                                                                              │││
│  │  │  ┌───────────────────────────────────────────────────────────────────────┐  │││
│  │  │  │  Account Construction (Inducement)                                    │  │││
│  │  │  │  Resource: Microsoft Entra ID                                         │  │││
│  │  │  │  Kind: account / Intent: entra-user                                   │  │││
│  │  │  │                                                                        │  │││
│  │  │  │  Mapeamentos:                                                          │  │││
│  │  │  │  ├── name → userPrincipalName                                         │  │││
│  │  │  │  ├── givenName → givenName                                            │  │││
│  │  │  │  ├── familyName → surname                                             │  │││
│  │  │  │  ├── email → mail                                                     │  │││
│  │  │  │  └── licenseSkus → assignedLicenses                                   │  │││
│  │  │  └───────────────────────────────────────────────────────────────────────┘  │││
│  │  └─────────────────────────────────────────────────────────────────────────────┘││
│  │                                             │                                    ││
│  │                                             │ HTTPS + Graph API                  ││
│  │                                             ▼                                    ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    Microsoft Entra ID (tenant: fiqueok.com.br)                  ││
│  │                                                                                  ││
│  │  ┌─────────────────────────────────────────────────────────────────────────────┐││
│  │  │  App Registration: midpoint-iga-connector                                   │││
│  │  │  - Client ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx                          │││
│  │  │  - Tenant ID: yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy                          │││
│  │  │  - Certificado/Secret: (armazenado no Vault)                                │││
│  │  │                                                                              │││
│  │  │  Permissões Graph API:                                                       │││
│  │  │  ├── User.ReadWrite.All (Application)                                       │││
│  │  │  ├── Directory.ReadWrite.All (Application)                                  │││
│  │  │  ├── GroupMember.ReadWrite.All (Application)                                │││
│  │  │  ├── RoleManagement.ReadWrite.Directory (Application)                       │││
│  │  │  ├── AppRoleAssignment.ReadWrite.All (Application)                          │││
│  │  │  └── Organization.Read.All (Application)                                    │││
│  │  └─────────────────────────────────────────────────────────────────────────────┘││
│  │                                                                                  ││
│  │  ┌─────────────────────────────────────────────────────────────────────────────┐││
│  │  │  Usuários provisionados:                                                     │││
│  │  │  ├── FP008@fiqueok.com.br (usuário normal)                                   │││
│  │  │  ├── Grupo "Microsoft 365 E5 Licenses" atribuído                             │││
│  │  │  └── Role Admin (se aprovado)                                               │││
│  │  └─────────────────────────────────────────────────────────────────────────────┘││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    FUTURO ERP (via SAML/OIDC)                                   ││
│  │                                                                                  ││
│  │  Usuário acessa ERP → Redirecionado para Entra ID → Autenticação →              ││
│  │  ERP recebe claims (nome, email, roles) → Acesso concedido                      ││
│  │                                                                                  ││
│  │  ⚠️ O ERP NÃO terá senhas locais. Toda autenticação delegada ao Entra ID.       ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Conceitos Fundamentais (Leitura Obrigatória)

### 3.1. O que é o Graph Connector?

O **GraphConnector** da Evolveum é o conector oficial para Microsoft Graph API, que substitui os antigos conectores LDAP/AD. Ele suporta:

| Operação | Suporte | Observação |
|----------|---------|------------|
| `createUser` | ✅ Completo | Cria usuário no Entra ID |
| `updateUser` | ✅ Completo | Atualiza atributos |
| `deleteUser` | ✅ Completo | Remove (ou desabilita) |
| `assignLicense` | ✅ Completo | SKU-based licensing |
| `addToGroup` | ✅ Completo | Membros de grupos |
| `assignRole` | ✅ Completo | Directory roles (Admin, etc.) |
| `sync` | ✅ Completo | Reconciliação |
| `search` | ✅ Completo | Correlação por UPN/email |

### 3.2. Diferença entre User e Account no Entra ID

| Conceito midPoint | Entra ID Correspondente |
|-------------------|-------------------------|
| `User` (focus) | Representação lógica no midPoint |
| `Account` (shadow) | Objeto físico no Entra ID (userPrincipalName) |
| `Role` (midPoint) | Grupo de permissões + inducement para account |

### 3.3. Licenças no Entra ID (SKUs)

As licenças do Microsoft 365 são representadas por **SKU IDs** (strings GUID). O conector aceita uma lista de SKUs no atributo `assignedLicenses`.

**SKUs comuns para o Living Lab:**

| Produto | SKU ID | Nome Amigável |
|---------|--------|---------------|
| Microsoft 365 E5 | `06ebc4ee-1bb5-47dd-8120-11324bc54e06` | M365_E5 |
| EMS E5 | `c42b9cae-ea4f-4ab7-8fb5-40b42e5c4f5e` | EMS_E5 |
| Power BI Pro | `f8a1db68-be16-40ed-86d5-cb42ce701560` | POWER_BI_PRO |

### 3.4. O que são Directory Roles no Entra ID?

Diferente de grupos, as **Directory Roles** são roles administrativas pré-definidas:

| Role | ID do Template | Uso no Projeto |
|------|----------------|----------------|
| Global Administrator | `62e90394-69f5-4237-9190-012177145e10` | Restrito (SoD) |
| User Administrator | `fe930be7-5e62-47db-91af-98c3a49a38b1` | Provisionamento |
| Helpdesk Administrator | `729827e3-9c14-49f7-bb1b-9608f156bbb8` | Suporte N1 |
| Security Reader | `5d6b6bb7-de71-4623-b4af-96380a352509` | Auditoria |

### 3.5. Workflow de Aprovação (Policy Rule)

O midPoint permite associar **policy rules** a roles ou resources. Para o PRJ027, usamos:

```xml
<policyRule>
    <name>EntraRoleApproval</name>
    <policyConstraints>
        <assignment/>
    </policyConstraints>
    <policyActions>
        <approvalWorkflow>
            <approverExpression>
                <path>$user/manager</path>
            </approverExpression>
            <level>2</level>
        </approvalWorkflow>
    </policyActions>
</policyRule>
```

### 3.6. Segregação de Funções (SoD)

As regras SoD são definidas como **policy rules** que avaliam conflitos entre roles existentes e a nova role sendo atribuída.

**Exemplo de regra SoD:**
```xml
<policyRule>
    <name>SoD-AdminInfra-Auditor</name>
    <policyConstraints>
        <and>
            <hasAssignment>
                <targetRef oid="role-admin-infra-oid"/>
            </hasAssignment>
            <hasAssignment>
                <targetRef oid="role-auditor-oid"/>
            </hasAssignment>
        </and>
    </policyConstraints>
    <policyActions>
        <enforcement>
            <action>block</action>
            <message>SoD Violation: AdminInfra and Auditor cannot be combined</message>
        </enforcement>
    </policyActions>
</policyRule>
```

### 3.7. Certificação de Acesso (Access Certification)

A certificação é um processo periódico onde **reviewers** (gerentes, security owners) confirmam ou revogam os acessos dos usuários.

O midPoint 4.10 suporta campanhas de certificação nativas, com:
- Criação de campanha (manual ou agendada)
- Notificações por e-mail
- Dashboard para reviewers
- Ações automáticas (revogação) após deadline

---

## 4. Pré-Requisitos Obrigatórios

| # | Pré-Requisito | Verificação | Critério |
|---|---------------|-------------|----------|
| PR-01 | Acesso ao servidor iga-gf-02 | `ssh paulo@xxx.xxx.xxx.xxx` | Login OK |
| PR-02 | Docker Compose funcionando | `cd /srv/iga-project && docker compose ps` | Container midpoint running |
| PR-03 | midPoint 4.10 operacional | `curl http://xxx.xxx.xxx.xxx:8080/midpoint` | HTTP 200 |
| PR-04 | Tenant Entra ID criado | `fiqueok.com.br` ou `fiqueok.onmicrosoft.com` | Tenant existe |
| PR-05 | Global Admin no Entra ID | Acesso ao portal Azure | Conta com permissão |
| PR-06 | Conta de serviço para App Registration | `svc-midpoint-connector@fiqueok.com.br` | Conta existe |
| PR-07 | Snapshot das VMs realizado | Hyper-V checkpoint | Checkpoint existe |
| PR-08 | Acesso ao Vault (segredos) | `vault kv get secret/entra-id/auth` | Segredo disponível |
| PR-09 | Usuários no midPoint com atributo `manager` | Verificar usuários no GUI | Manager preenchido |
| PR-10 | **ADR-001 aprovado (Arquitetura Multi-Cloud)** | Documento de decisão | Aprovado pelo CISO |

---

## 5. Checklist de Pré-Verificação (Pre-Flight)

Execute os comandos abaixo **antes** de iniciar qualquer configuração.

### 5.1. Verificar Container do midPoint

```bash
# [iga-gf-02]$
sudo docker ps --format "table {{.Names}}\t{{.Status}}" | grep midpoint
# Deve mostrar: iga-midpoint   Up X minutes
```

### 5.2. Verificar Conectividade com Microsoft Graph

```bash
# [iga-gf-02]$
sudo docker exec iga-midpoint curl -s -o /dev/null -w "HTTP: %{http_code}\n" https://graph.microsoft.com/v1.0/
# Deve retornar: HTTP: 200
```

### 5.3. Verificar Arquivo do Conector

```bash
# [iga-gf-02]$
ls -la /tmp/connector-graph-*.jar
# Deve mostrar o arquivo connector-graph-4.0.0.jar (ou versão compatível)
```

### 5.4. Verificar Usuários com Manager Preenchido

```bash
# [iga-gf-02]$
sudo docker exec iga-midpoint curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://localhost:8080/midpoint/ws/rest/users?search=manager" \
  -H "Accept: application/json" | jq '.users | length'
# Deve ser > 0
```

### 5.5. Criar Snapshot de Segurança (OBRIGATÓRIO)

```powershell
# [WinHost]$ (PowerShell como Administrador)
Checkpoint-VM -VMName "iga-gf-02" -SnapshotName "PRJ027-Antes-Configuracao"
```

---

## 6. Procedimento de Rollback

### 6.1. Rollback Completo (Recomendado)

```powershell
# [WinHost]$ (PowerShell como Administrador)
Restore-VMSnapshot -VMName "iga-gf-02" -Name "PRJ027-Antes-Configuracao" -Confirm:$false
Start-VM -Name "iga-gf-02"
```

### 6.2. Rollback Parcial (Apenas Role/Resource)

Se apenas a Role ou Resource precisar ser removido:

1. Acesse o GUI do midPoint
2. Delete o Resource Microsoft Entra ID (se existir)
3. Delete a Role Microsoft 365 E5 (se existir)
4. Remova as regras SoD e Workflow associadas
5. Recalcule os usuários afetados

### 6.3. Rollback no Entra ID (Remoção Manual)

```powershell
# [PowerShell com módulo Microsoft.Graph]
Connect-MgGraph -Scopes "User.ReadWrite.All"
Remove-MgUser -UserId "FP008@fiqueok.com.br"  # Se necessário
```

---

## 7. FASE 1: Preparação do Entra ID (App Registration)

### 7.1. Acessar o Portal do Azure

```
URL: https://portal.azure.com
Usuário: global-admin@fiqueok.com.br
```

### 7.2. Criar App Registration

1. Navegue para **Microsoft Entra ID** → **App registrations**
2. Clique em **New registration**
3. Preencha:

| Campo | Valor |
|-------|-------|
| **Name** | `midpoint-iga-connector` |
| **Supported account types** | `Accounts in this organizational directory only` |
| **Redirect URI** | (deixar em branco - opcional) |

Clique em **Register**

### 7.3. Configurar Certificado ou Segredo (Client Secret)

Para ambiente de LAB (POC), usaremos **Client Secret**. Para PRODUÇÃO, recomendamos **Certificate**.

```powershell
# [PowerShell] ou via portal
```

**Via Portal:**
1. No App Registration, vá para **Certificates & secrets**
2. Clique em **New client secret**
3. Descrição: `midpoint-secret-2026`
4. Expira: `12 months`
5. Clique em **Add**

⚠️ **Copie o valor do segredo imediatamente** — ele não será exibido novamente.

### 7.4. Configurar Permissões Graph API

1. Vá para **API permissions**
2. Clique em **Add a permission** → **Microsoft Graph** → **Application permissions**
3. Adicione as seguintes permissões:

| Permissão | Motivo |
|-----------|--------|
| `User.ReadWrite.All` | Criar/atualizar usuários |
| `Directory.ReadWrite.All` | Ler/atualizar diretório |
| `GroupMember.ReadWrite.All` | Gerenciar membros de grupos |
| `RoleManagement.ReadWrite.Directory` | Atribuir roles administrativas |
| `AppRoleAssignment.ReadWrite.All` | Atribuir licenças (app roles) |
| `Organization.Read.All` | Ler informações do tenant |

4. Clique em **Grant admin consent for Fiqueok**

### 7.5. Coletar Credenciais para o midPoint

| Credencial | Onde encontrar | Exemplo |
|------------|----------------|---------|
| **Tenant ID** | Overview do App Registration | `aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa` |
| **Client ID** | Overview do App Registration | `bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb` |
| **Client Secret** | Certificates & secrets | `cCc~cCc~cCc~cCc~` |

### 7.6. Armazenar no Vault

```bash
# [api-gf-01]$
vault kv put secret/entra-id/auth \
  tenant_id="aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa" \
  client_id="bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb" \
  client_secret="cCc~cCc~cCc~cCc~"
```

**Critério de Sucesso F1:** ✅ App Registration criado, permissões consentidas, segredo armazenado no Vault

---

## 8. FASE 2: Instalação do Conector Graph

### 8.1. Via Terminal (OBRIGATÓRIO)

```bash
# [iga-gf-02]$

# Passo 1: Baixar o conector oficial
cd /tmp
wget https://github.com/Evolveum/connector-graph/releases/download/v4.0.0/connector-graph-4.0.0.jar

# Passo 2: Copiar para o diretório de connectors
sudo cp /tmp/connector-graph-4.0.0.jar /srv/iga-project/data/midpoint/icf-connectors/

# Passo 3: Ajustar permissões
sudo chown 1000:1000 /srv/iga-project/data/midpoint/icf-connectors/connector-graph-*.jar
sudo chmod 644 /srv/iga-project/data/midpoint/icf-connectors/connector-graph-*.jar

# Passo 4: Reiniciar o midPoint
cd /srv/iga-project
sudo docker compose restart midpoint
sleep 30

# Passo 5: Verificar descoberta do conector
sudo docker logs iga-midpoint --tail 100 | grep -i "graph"
```

**Saída esperada:**
```
INFO: Discovered ICF bundle in JAR: file:/opt/midpoint/var/icf-connectors/connector-graph-4.0.0.jar
INFO: Discovered new connector com.evolveum.polygon.connector.graph.GraphConnector v4.0.0
```

**Critério de Sucesso F2:** ✅ Log mostra descoberta do GraphConnector

---

## 9. FASE 3: Criação do Resource Entra ID

### 9.1. Via Interface Gráfica (GUI) — RECOMENDADO

#### Passo 1: Acessar o GUI do midPoint
```
URL: http://xxx.xxx.xxx.xxx:8080/midpoint
Usuário: administrator
Senha: M1dP0!ntAdm!n#2026
```

#### Passo 2: Criar novo Resource
1. Navegue para **Resources** → **All resources**
2. Clique em **New resource** (botão verde)
3. Escolha **Create from scratch**
4. Na lista de conectores, selecione **GraphConnector v4.0.0**
5. Clique em **Next**

#### Passo 3: Preencher Basic Information

| Campo | Valor |
|-------|-------|
| **Name** | `Microsoft Entra ID` |
| **Description** | `Microsoft Entra ID tenant - fiqueok.com.br - Provisionamento e Governança` |
| **Lifecycle state** | `Active (production)` |

Clique em **Next**

#### Passo 4: Preencher Configuration (CRÍTICO)

| Campo | Valor | Observação |
|-------|-------|------------|
| **tenantId** | `aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa` | Do Vault |
| **clientId** | `bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb` | Do Vault |
| **clientSecret** | `cCc~cCc~cCc~cCc~` | Use "Use clear value" |
| **useCertificate** | `false` | Usamos secret (POC) |
| **graphEndpoint** | `https://graph.microsoft.com` | Padrão |

Clique em **Next** até finalizar

#### Passo 5: Testar Conexão
1. Clique em **Save**
2. Clique em **Test connection**

**Saída esperada:** `Connection test completed successfully`

**Critério de Sucesso F3:** ✅ Test Connection OK

---

## 10. FASE 4: Configuração do Schema Handling

### 10.1. Via Interface Gráfica (GUI)

#### Passo 1: Acessar Schema handling
1. No Resource `Microsoft Entra ID`, clique na aba **Schema handling**
2. Clique em **Add object type**

#### Passo 2: Configurar o Object Type

| Campo | Valor |
|-------|-------|
| **Display name** | `Entra ID User` |
| **Kind** | `account` |
| **Intent** | `entra-user` |
| **Lifecycle state** | `Active (production)` |
| **Object class** | `UserType` (GraphConnector) |

Clique em **Next** até chegar em **Mappings**

#### Passo 3: Configurar Mapeamentos (Inbound/Outbound)

Adicione os seguintes mapeamentos (todos outbound, strength=strong):

| Source (midPoint) | Target (Entra ID) | Observação |
|-------------------|-------------------|------------|
| `name` | `userPrincipalName` | Formato: `{name}@fiqueok.com.br` |
| `givenName` | `givenName` | Primeiro nome |
| `familyName` | `surname` | Sobrenome |
| `email` | `mail` | E-mail principal |

**Atenção:** Para `userPrincipalName`, use expressão para concatenar com domínio:
```xml
<expression>
    <script>
        <code>name + '@fiqueok.com.br'</code>
    </script>
</expression>
```

#### Passo 4: Configurar Licenças (Opcional)

Adicione mapeamento para `assignedLicenses`:

| Campo | Valor |
|-------|-------|
| **Source** | `extension:licenseSkus` (atributo do usuário) |
| **Target** | `assignedLicenses` |
| **Direction** | `outbound` |

#### Passo 5: Configurar Correlação

| Campo | Valor |
|-------|-------|
| **Correlator item** | `userPrincipalName` |
| **Search method** | `Item` |
| **Source attribute** | `name` + domínio |
| **Target attribute** | `userPrincipalName` |

#### Passo 6: Configurar Sincronização

| Situation | Action |
|-----------|--------|
| `unmatched` | `addFocus` |
| `matched` | `link` |
| `deleted` | `unlink` (não deletar, apenas desvincular) |

**Critério de Sucesso F4:** ✅ Schema Handling salvo sem erros

---

## 11. FASE 5: Regras de Segregação de Funções (SoD)

### 11.1. Criar Regra SoD via Import (RAW XML)

```xml
<!-- Regra SoD: Administrador de Infraestrutura + Auditor Interno -->
<policyRule xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
            xmlns:c="http://midpoint.evolveum.com/xml/ns/public/common/common-3">
    <name>SoD-AdminInfra-AuditorInterno</name>
    <policyConstraints>
        <and>
            <hasAssignment>
                <targetRef oid="63d8f2a1-1234-4d45-ae2c-df12eb0f6999" type="c:RoleType"/>
            </hasAssignment>
            <hasAssignment>
                <targetRef oid="7e3c4b2a-1234-4d45-ae2c-df12eb0f6999" type="c:RoleType"/>
            </hasAssignment>
        </and>
    </policyConstraints>
    <policyActions>
        <enforcement>
            <action>block</action>
            <message>SoD Violation: User cannot have both AdminInfra and AuditorInterno roles simultaneously.</message>
            <severity>error</severity>
        </enforcement>
    </policyActions>
</policyRule>

<!-- Regra SoD: Desenvolvedor + Billing Admin (Alerta) -->
<policyRule>
    <name>SoD-Desenvolvedor-BillingAdmin</name>
    <policyConstraints>
        <and>
            <hasAssignment>
                <targetRef oid="8a2f1c3e-1234-4d45-ae2c-df12eb0f6999" type="c:RoleType"/>
            </hasAssignment>
            <hasAssignment>
                <targetRef oid="5b1d4e6f-1234-4d45-ae2c-df12eb0f6999" type="c:RoleType"/>
            </hasAssignment>
        </and>
    </policyConstraints>
    <policyActions>
        <enforcement>
            <action>warn</action>
            <message>SoD Warning: Desenvolvedor and BillingAdmin roles combined. Requires justification.</message>
            <severity>warning</severity>
        </enforcement>
    </policyActions>
</policyRule>
```

### 11.2. Importar Regras

1. **Administration** → **Import object**
2. Cole o XML acima
3. Clique em **Import**

**Critério de Sucesso F5:** ✅ Regras SoD importadas e ativas

---

## 12. FASE 6: Workflow de Aprovação

### 12.1. Criar Policy Rule de Aprovação via Import

```xml
<policyRule xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
            xmlns:c="http://midpoint.evolveum.com/xml/ns/public/common/common-3">
    <name>Workflow-EntraRoleApproval</name>
    <policyConstraints>
        <assignment>
            <targetType>c:RoleType</targetType>
            <!-- Aplica-se a roles que provisionam Entra ID -->
            <targetRef oid="f41883a2-4822-4d45-ae2c-df12eb0f6999" type="c:RoleType"/>
        </assignment>
    </policyConstraints>
    <policyActions>
        <approvalWorkflow>
            <level>
                <name>Manager Approval</name>
                <approverExpression>
                    <script>
                        <code>
                            import com.evolveum.midpoint.xml.ns._public.common.common_3.UserType;
                            def managerOid = user.getParentOrgRef().getOid();
                            midpoint.getObject(UserType.class, managerOid).getFocus().getName();
                        </code>
                    </script>
                </approverExpression>
                <autoApprovalIfEmpty>false</autoApprovalIfEmpty>
            </level>
            <level>
                <name>Security Owner Approval</name>
                <approverExpression>
                    <script>
                        <code>return ["security-owner@fiqueok.com.br"];</code>
                    </script>
                </approverExpression>
            </level>
            <timeout>
                <duration>P7D</duration>
                <action>reject</action>
            </timeout>
            <mailNotification>
                <subject>Approval Required: Entra ID Role Assignment</subject>
                <body>User ${user.name} is requesting access to Entra ID role. Please approve or reject.</body>
            </mailNotification>
        </approvalWorkflow>
    </policyActions>
</policyRule>
```

**Critério de Sucesso F6:** ✅ Workflow importado e associado à role

---

## 13. FASE 7: Certificação de Acesso (Campanha)

### 13.1. Criar Campanha via REST API ou GUI

#### Opção 1: Via GUI

1. Navegue para **Access Certification** → **Campaigns**
2. Clique em **New campaign**
3. Preencha:

| Campo | Valor |
|-------|-------|
| **Name** | `Certificacao-Trimestral-EntraID` |
| **Description** | `Revisão trimestral de acessos ao Entra ID` |
| **Stage** | `Create` |
| **Campaign type** | `Role Certification` |
| **Reviewer** | `Manager + Security Owner` |
| **Start** | `2026-07-01` (próximo trimestre) |
| **Deadline** | `30 dias após início` |

#### Opção 2: Via REST API (Agendável)

```bash
curl -X POST -u administrator:'M1dP0!ntAdm!n#2026' \
  -H "Content-Type: application/xml" \
  -d @campaign-request.xml \
  http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/campaigns
```

### 13.2. Configurar Tarefa de Reconciliação (Shadow IT Detection)

```bash
# [iga-gf-02]$
# Criar tarefa de reconciliação via GUI ou curl
```

**Configuração da tarefa:**
- **Resource:** Microsoft Entra ID
- **Kind:** account
- **Intent:** entra-user
- **Schedule:** 0 0 2 * * ? (diariamente às 2h)

**Critério de Sucesso F7:** ✅ Campanha configurada, tarefa de reconciliação agendada

---

## 14. FASE 8: Criação da Role Entra ID

### 14.1. Via Import (RAW XML)

```xml
<role xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
      xmlns:c="http://midpoint.evolveum.com/xml/ns/public/common/common-3">
    <name>Microsoft 365 E5</name>
    <displayName>Microsoft 365 E5 License</displayName>
    <description>Provisions a user in Microsoft Entra ID with M365 E5 license</description>
    <lifecycleState>active</lifecycleState>
    
    <!-- Atributos que podem ser herdados pelo usuário -->
    <inducement>
        <construction>
            <resourceRef oid="a6af855d-46b7-4c71-abe5-96c72b48863c" type="c:ResourceType"/>
            <kind>account</kind>
            <intent>entra-user</intent>
            
            <!-- Mapeamento de atributos -->
            <attribute>
                <ref>userPrincipalName</ref>
                <outbound>
                    <strength>strong</strength>
                    <expression>
                        <script>
                            <code>name + '@fiqueok.com.br'</code>
                        </script>
                    </expression>
                </outbound>
            </attribute>
            
            <attribute>
                <ref>givenName</ref>
                <outbound>
                    <strength>strong</strength>
                    <source>
                        <path>givenName</path>
                    </source>
                </outbound>
            </attribute>
            
            <attribute>
                <ref>surname</ref>
                <outbound>
                    <strength>strong</strength>
                    <source>
                        <path>familyName</path>
                    </source>
                </outbound>
            </attribute>
            
            <!-- Licenças M365 E5 -->
            <attribute>
                <ref>assignedLicenses</ref>
                <outbound>
                    <strength>strong</strength>
                    <expression>
                        <script>
                            <code>
                                import com.evolveum.midpoint.xml.ns._public.common.common_3.LicenseType;
                                def skus = [];
                                skus.add('06ebc4ee-1bb5-47dd-8120-11324bc54e06'); // M365 E5
                                skus.add('c42b9cae-ea4f-4ab7-8fb5-40b42e5c4f5e'); // EMS E5
                                return skus;
                            </code>
                        </script>
                    </expression>
                </outbound>
            </attribute>
        </construction>
    </inducement>
    
    <!-- Workflow de aprovação associado à role -->
    <policyRuleRef oid="workflow-entra-approval-oid" type="c:PolicyRuleType"/>
    
    <!-- Metadados de auditoria -->
    <extension>
        <certificationRequired>true</certificationRequired>
        <certificationPeriod>P90D</certificationPeriod>
        <securityLevel>high</securityLevel>
    </extension>
</role>
```

### 14.2. Importar Role

1. **Administration** → **Import object**
2. Cole o XML acima
3. Substitua os OIDs pelos valores reais do seu ambiente
4. Clique em **Import**

**Critério de Sucesso F8:** ✅ Role criada com inducement, mapeamentos e workflow

---

## 15. FASE 9: Atribuição da Role ao Usuário

### 15.1. Via GUI

1. Navegue para **Users** → **All users**
2. Clique no usuário desejado (ex: `FP008`)
3. Vá para a aba **Roles** (ou Assignments)
4. Clique em **Add** → **Role**
5. Digite `Microsoft 365 E5`
6. Selecione a role na lista
7. Clique em **Save**

### 15.2. Aguardar Workflow

Após salvar, o workflow de aprovação será disparado:

1. **Status do usuário:** muda para `workflowPending`
2. **Manager** recebe e-mail com link para aprovação
3. **Security Owner** recebe e-mail após aprovação do manager
4. Após ambas aprovações, o provisionamento é executado

### 15.3. Recalcular (se necessário)

```bash
# Via REST API
curl -X POST -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://xxx.xxx.xxx.xxx:<REDACTED_SECRET>ute"
```

**Critério de Sucesso F9:** ✅ Role atribuída, workflow disparado

---

## 16. FASE 10: Execução e Validação

### 16.1. Verificar no midPoint

No usuário, aba **Resource objects** → deve aparecer a shadow do **Microsoft Entra ID** com status **exists**.

### 16.2. Verificar no Entra ID (Portal Azure)

1. Acesse `https://portal.azure.com`
2. Navegue para **Microsoft Entra ID** → **Users**
3. Busque pelo usuário FP008@fiqueok.com.br
4. Verifique:
   - Conta criada
   - Licenças atribuídas (M365 E5)
   - Grupos (se configurado)

### 16.3. Verificar Logs de Provisionamento

```bash
# [iga-gf-02]$
sudo docker logs iga-midpoint --tail 100 | grep -E "FP008|Entra ID|provision|workflow"
```

**Saída esperada:**
```
INFO: Workflow 'Workflow-EntraRoleApproval' initiated for user FP008
INFO: Approval level 1 sent to manager@fiqueok.com.br
INFO: Approval level 1 granted by manager@fiqueok.com.br
INFO: Approval level 2 sent to security-owner@fiqueok.com.br
INFO: Approval level 2 granted by security-owner@fiqueok.com.br
INFO: Microsoft Entra ID - account | create | Status: Success -> FP008
INFO: License assigned to FP008: M365 E5
```

### 16.4. Validar Evidência de Auditoria

```bash
# Buscar logs de auditoria no midPoint
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/audit/search?target=FP008" \
  -H "Accept: application/json" | jq '.auditRecords[] | {timestamp, eventType, outcome}'
```

**Critério de Sucesso F10:** ✅ Usuário provisionado, logs de auditoria registrados

---

## 17. POP: Joiner Automático (Procedimento Operacional Padrão)

### 17.1. Fluxo Completo "Joiner"

| Fase | Responsável | Ação no OrangeHRM | Ação no midPoint | Evidência para Auditoria |
|------|-------------|-------------------|------------------|--------------------------|
| **1. Admissão** | RH | Cadastra funcionário → CSV exportado (PRJ022) | Importa usuário com status `PendingApproval` | Hash do CSV + Timestamp |
| **2. Atribuição de Role** | Gestor (via GUI) | N/A | Atribui role `Microsoft 365 E5` ao usuário | Assignment log |
| **3. SoD Check** | midPoint (automático) | N/A | Avalia regras SoD (ex: `Admin` + `Auditor`) | PolicyViolation log |
| **4. Workflow - Nível 1** | Manager do usuário | Recebe e-mail com link | Aprova ou rejeita via dashboard | Approval record + justificativa |
| **5. Workflow - Nível 2** | Security Owner | Recebe e-mail com link | Aprova ou rejeita via dashboard | Approval record + justificativa |
| **6. Provisionamento** | midPoint (automático) | N/A | Chama Graph API: `POST /users`, `POST /assignLicense` | `requestId` do Graph + `responseCode=201` |
| **7. Reconciliação** | midPoint (diário) | N/A | `GET /users` compara com shadows | Relatório de diff |

### 17.2. Workflow Detalhado (Passo a Passo)

#### Passo 1: RH exporta CSV (automático a cada 4h)
```bash
# [api-gf-01] - cron
0 */4 * * * /home/paulo/export_employees_to_csv.py
```

#### Passo 2: midPoint reconcilia CSV
```bash
# Tarefa agendada no midPoint
# Resource: Fiqueok HR (Shadow API CSV)
# Schedule: 0 5 */4 * * ? (15 min após exportação)
```

#### Passo 3: Gestor atribui role via GUI
1. Acessa usuário
2. Add → Role → `Microsoft 365 E5`
3. Preenche justificativa obrigatória

#### Passo 4: Workflow dispara
1. Manager recebe e-mail:
```
Subject: [Fiqueok GRC] Approval Required: FP008 - Microsoft 365 E5
Body: User Fernando Pereira (FP008) requests access to Microsoft 365 E5.
Justification: 'Necessário para atividades de análise de dados'
Approve: [link]
Reject: [link]
```

2. Security Owner recebe e-mail após aprovação do manager

#### Passo 5: Provisionamento
Após aprovações, o midPoint executa:
```http
POST https://graph.microsoft.com/v1.0/users
Authorization: Bearer <token>
Content-Type: application/json

{
    "userPrincipalName": "FP008@fiqueok.com.br",
    "displayName": "Fernando Pereira",
    "givenName": "Fernando",
    "surname": "Pereira",
    "mail": "fernando.pereira@fiqueok.com.br",
    "accountEnabled": true
}
```

### 17.3. Verificações Obrigatórias (Joiner)

| # | Verificação | Responsável | Antes do Provisionamento |
|---|-------------|-------------|--------------------------|
| V01 | Usuário existe no OrangeHRM | RH | ✅ |
| V02 | Manager do usuário está definido | RH | ✅ |
| V03 | Role não viola SoD existente | midPoint (automático) | ✅ |
| V04 | Justificativa preenchida na role assignment | Gestor | ✅ |
| V05 | Workflow aprovado por ambos níveis | Manager + Security | ✅ |

---

## 18. Resolução de Problemas Comuns

| Erro | Causa Provável | Solução |
|------|----------------|---------|
| **Test Connection falha** | Credenciais incorretas, permissões faltando | Verificar Tenant ID, Client ID, Secret no Vault |
| **No name in the new object** | Mapeamento `userPrincipalName` não configurado | Adicionar outbound mapping no Schema Handling |
| **Workflow não dispara** | Policy rule não associada à role | Verificar `policyRuleRef` na role |
| **SoD block não funciona** | Regra SoD com OID incorreto | Verificar OIDs das roles conflitantes |
| **Licença não atribuída** | SKU ID incorreto ou sem disponibilidade | Verificar SKU ID no portal Azure |
| **UPN já existe** | Usuário já provisionado manualmente | Reconciliação detecta e corrige |
| **Manager approver não encontrado** | Atributo `manager` vazio | Preencher manager no usuário |
| **Certification campaign não notifica** | E-mail não configurado | Configurar `mail.host` no midPoint |
| **Reconciliação detecta Shadow IT** | Conta criada manualmente no portal | Tarefa de reconciliação revoga automaticamente (configurável) |
| **curl SSL trustAnchors** | Java não encontra cacerts | Configurar `JAVA_OPTS` (ver PRJ023/024) |

---

## 19. Lições Aprendidas e Compliance

### 19.1. Lições Técnicas (PRJ027)

| # | Lição |
|---|-------|
| L01 | O conector Graph oficial suporta licenças e roles, diferentemente dos conectores comunitários AWS/GCP |
| L02 | Workflow de aprovação exige atributo `manager` preenchido no usuário — validar antes da atribuição |
| L03 | SoD rules devem ser testadas em sandbox antes de produção para evitar bloqueios inesperados |
| L04 | A certificação de acesso trimestral atende aos controles ISO 27001 A.9.2 e A.9.6 |
| L05 | A reconciliação diária detecta Shadow IT (contas manuais) e gera evidência para auditoria |
| L06 | O mapeamento `userPrincipalName` deve incluir domínio (`name@fiqueok.com.br`) |
| L07 | Licenças são atribuídas via SKU ID, não por nome amigável — manter documentação dos GUIDs |
| L08 | O workflow pode expirar (default 7 dias) — configurar notificações de lembrete |
| L09 | O conector Graph é mais estável que os conectores comunitários — recomendado para PRD |
| L10 | O futuro ERP deve confiar no Entra ID como IdP — midPoint não deve gerenciar senhas locais |

### 19.2. Verificações Obrigatórias Antes da Execução

| # | Verificação | Comando |
|---|-------------|---------|
| V01 | Resource Microsoft Entra ID existe | Verificar no GUI em Resources |
| V02 | Test connection OK | Resource → Test connection |
| V03 | Role Microsoft 365 E5 existe | Verificar no GUI em Roles |
| V04 | Role tem construction com resourceRef correto | Verificar RAW da role |
| V05 | Role tem mapeamento userPrincipalName | Verificar inducement/attribute |
| V06 | Workflow policy rule está associada | Verificar policyRuleRef na role |
| V07 | SoD rules estão ativas | Verificar em Policies → Policy Rules |
| V08 | Usuário tem name e manager preenchidos | Verificar usuário no GUI |
| V09 | Tarefa de reconciliação está agendada | Verificar Defined Tasks |
| V10 | Certificação campaign está criada | Verificar Access Certification → Campaigns |

### 19.3. Frameworks de Compliance Aplicados

| Framework | Controle | Implementação no PRJ027 |
|-----------|----------|-------------------------|
| **ISO 27001** | A.5.15 (Menor Privilégio) | Workflow de aprovação de 2 níveis |
| **ISO 27001** | A.5.16 (Gestão de Acessos) | Certificação trimestral + reconciliação |
| **ISO 27001** | A.5.17 (SoD - Usuários Privilegiados) | Regras SoD ativas (block + warn) |
| **ISO 27001** | A.8.12 (Gestão de Segredos) | Client Secret no Vault, não hardcoded |
| **ISO 27001** | A.8.15 (Logging) | Logs de auditoria com aprovação/justificativa |
| **ISO 27001** | A.8.16 (Monitoramento) | Reconciliação detecta Shadow IT |
| **ISO 27001** | A.9.2 (Controle de Acesso) | Provisionamento apenas via workflow aprovado |
| **ISO 27001** | A.9.6 (Revogação) | Reconciliar revoga contas manuais |
| **NIST SP 800-53** | AC-3 (Access Enforcement) | Provisionamento baseado em role + approval |
| **NIST SP 800-53** | AC-5 (SoD) | Regras SoD implementadas |
| **NIST SP 800-53** | AU-9 (Proteção de Logs) | Logs centralizados no midPoint |
| **CIS Controls** | 5 (Gestão de Contas) | Correlation rule previne duplicatas |
| **CIS Controls** | 6 (Controle de Acessos) | Workflow + SoD + Certificação |
| **PCI-DSS v4.0** | 7.2 (Access Control) | Atribuição controlada de role |
| **LGPD** | Art. 46 (Segurança) | Rastreabilidade total de acessos |

---

## 20. Decisões Arquiteturais para Futuro ERP (SSO)

### 20.1. ADR-004: Entra ID como IdP Soberano para ERP

**Contexto:** O futuro ERP (nomeado `erp-fiqueok`) não terá senhas locais. Toda autenticação será delegada ao Entra ID.

**Decisão:**
- **O midPoint NÃO gerencia senhas** para o ERP
- O midPoint **apenas provisiona** a conta no Entra ID (via Graph API)
- O ERP **confia exclusivamente** no Entra ID via SAML2 ou OIDC
- O fluxo de autenticação: `ERP → Entra ID → usuário autenticado → ERP recebe claims`

**Arquitetura:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    FLUXO DE AUTENTICAÇÃO ERP (SEM SENHAS LOCAIS)            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Usuário acessa ERP → ERP redireciona para Entra ID (SAML/OIDC)              │
│         │                                                                     │
│         ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  Microsoft Entra ID (IdP)                                               ││
│  │  - Autenticação (passwordless, MFA, conditional access)                 ││
│  │  - Emite token SAML/OIDC com claims: name, email, groups                ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│         │                                                                     │
│         ▼ (token)                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  ERP (SP - Service Provider)                                            ││
│  │  - Valida token (SAML signature / OIDC JWT)                             ││
│  │  - Extrai claims: name, email, roles                                    ││
│  │  - Concede acesso baseado nas roles                                     ││
│  │  - NUNCA armazena senha local                                           ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
│  ⚠️  A conta no Entra ID é criada ANTES pelo midPoint via workflow aprovado  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 20.2. Contrato entre midPoint e ERP

| Atributo | Origem (midPoint) | Destino (Entra ID) | Claim no ERP |
|----------|-------------------|--------------------|--------------|
| Identificador | `name` | `userPrincipalName` | `sub` (OIDC) / `NameID` (SAML) |
| Nome | `givenName` + `familyName` | `displayName` | `given_name`, `family_name` |
| E-mail | `email` | `mail` | `email` |
| Roles | `roleMembership` | `groups`/`roles` | `roles` |

### 20.3. Segurança e Rastreabilidade

| Requisito | Implementação |
|-----------|---------------|
| Prova de que conta foi criada via processo aprovado | Log do midPoint mostrando approval + provisionamento |
| Prova de que ERP não armazena senha | Auditoria do código do ERP (NIST SP 800-53) |
| Prova de que autenticação é delegada ao Entra ID | Configuração SAML/OIDC documentada |
| Recertificação de acesso | Campanha trimestral (Seção 13) |

---

## 21. Anexos: Comandos de Diagnóstico

### 21.1. Comandos no iga-gf-02

```bash
# Verificar conector instalado
sudo docker exec iga-midpoint ls -la /opt/midpoint/var/icf-connectors/ | grep -i graph

# Verificar log de provisionamento
sudo docker logs iga-midpoint --tail 200 | grep -E "Entra ID|Graph|provision"

# Verificar Resource pelo OID
curl -u administrator:'M1dP0!ntAdm!n#2026' \
  http://xxx.xxx.xxx.xxx:<REDACTED_SECRET>-46b7-4c71-abe5-96c72b48863c

# Listar shadows do Resource Entra ID
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/shadow/search?resource=ENTRA_RESOURCE_OID" \
  -H "Accept: application/json" | jq '.shadows[] | {name: .resourceObjectName, status: .state}'

# Verificar workflow pendente
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/cases/search?state=open" \
  -H "Accept: application/json" | jq '.cases[] | {name, createTimestamp}'
```

### 21.2. Comandos no Graph PowerShell

```powershell
# [PowerShell com módulo Microsoft.Graph]
Connect-MgGraph -Scopes "User.Read.All", "LicenseAssignment.Read.All"

# Listar usuários criados pelo midPoint
Get-MgUser -Filter "userPrincipalName -like '*@fiqueok.com.br'" | Select UserPrincipalName, DisplayName

# Verificar licenças atribuídas
Get-MgUserLicenseDetail -UserId "FP008@fiqueok.com.br"

# Verificar roles administrativas
Get-MgDirectoryRole | Where-Object {$_.DisplayName -eq "Global Administrator"}
```

### 21.3. Comandos no Windows Host (Hyper-V)

```powershell
# Listar snapshots
Get-VMSnapshot -VMName "iga-gf-02"

# Restaurar snapshot
Restore-VMSnapshot -VMName "iga-gf-02" -Name "PRJ027-Antes-Configuracao" -Confirm:$false
```

---

## 22. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| **1.0** | **06/05/2026** | **Paulo Feitosa Lima** | **Documento inicial baseado no TAP. Estrutura seguindo padrão PRJ022/023/024. Inclui: App Registration, Graph Connector, Schema Handling, Workflow de Aprovação, Regras SoD, Certificação de Acesso, Joiner POP, ADR para futuro ERP.** |

---

**Fim do POP-PRJ027-v1.0** ✅

---

*PRJ027 — Integração midPoint ↔ Microsoft Entra ID com Governança (Graph API)*  
*Living Lab Fiqueok*  
*Arquivado em: `FiqueokBrain/PRJ027/POP-PRJ027-v1.0.md`*
