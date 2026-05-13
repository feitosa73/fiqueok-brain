

---

## 🚀  — Versão Final com Pre-Flight Incorporado

---

**Versão:** 2.0 ✅ **VALIDADO** — Baseado nas diretrizes do TAP, padrões PRJ022/023/024 e Pre-Flight executado em 08/05/2026  
**Data:** 08/05/2026  
**Responsável:** Paulo Feitosa Lima  
**Status:** ✅ **PRONTO PARA IMPLEMENTAÇÃO**

---

## ÍNDICE

1. [Objetivo do Documento](#1-objetivo-do-documento)
2. [Arquitetura da Solução (FinOps Aligned)](#2-arquitetura-da-solução-finops-aligned)
3. [Conceitos Fundamentais (Leitura Obrigatória)](#3-conceitos-fundamentais-leitura-obrigatória)
4. [Pré-Requisitos Obrigatórios](#4-pré-requisitos-obrigatórios)
5. [Checklist de Pré-Verificação (Pre-Flight)](#5-checklist-de-pré-verificação-pre-flight)
   - 5.1. Resultado do Pre-Flight Executado em 08/05/2026
6. [Procedimento de Rollback](#6-procedimento-de-rollback)
7. [FASE 1: Preparação do Entra ID (App Registration)](#7-fase-1-preparação-do-entra-id-app-registration)
8. [FASE 2: Instalação do Conector Graph (Nota: Nome Correto)](#8-fase-2-instalação-do-conector-graph-nota-nome-correto)
9. [FASE 3: Criação do Resource Entra ID](#9-fase-3-criação-do-resource-entra-id)
10. [FASE 4: Configuração do Schema Handling (Sem Licenças)](#10-fase-4-configuração-do-schema-handling-sem-licenças)
11. [FASE 5: Regras de Segregação de Funções (SoD)](#11-fase-5-regras-de-segregação-de-funções-sod)
12. [FASE 6: Workflow de Aprovação](#12-fase-6-workflow-de-aprovação)
13. [FASE 7: Certificação de Acesso (Campanha)](#13-fase-7-certificação-de-acesso-campanha)
14. [FASE 8: Criação da Role "Entra ID Basic User" (Sem Licenças)](#14-fase-8-criação-da-role-entra-id-basic-user-sem-licenças)
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

Este Procedimento Operacional Padrão (POP) descreve o passo a passo para integrar o **midPoint 4.10** com o **Microsoft Entra ID Free** utilizando o **GraphConnector oficial** (Evolveum), estabelecendo não apenas conectividade, mas uma camada completa de **Governança de Acessos** **sem custo adicional de licenças de produtividade**.

**⚠️ Declaração de Escopo (FinOps):**

> Este projeto **NÃO** provisiona licenças Microsoft 365 E5, EMS E5 ou qualquer SKU que exija faturamento ativo no tenant. O ambiente utiliza **Microsoft Entra ID Free**, que suporta até 50.000 objetos de diretório sem custo. O foco é exclusivamente na criação de identidades (User) e na atribuição de Directory Roles nativas (gratuitas).

**Diferenciais deste projeto em relação aos anteriores (PRJ023/AWS, PRJ024/GCP):**

| Camada | PRJ023/024 (Anterior) | PRJ027 (Este POP) |
|--------|----------------------|-------------------|
| **Provisionamento** | Apenas criação de usuário | Usuário + Directory Roles (nativas) |
| **Workflow** | Ausente | Aprovação de 2 níveis (Manager + Security) |
| **Segregação (SoD)** | Não implementada | Regras ativas (ex: AdminInfra + Auditor = BLOCK) |
| **Certificação** | Não implementada | Campanha trimestral com reconciliação |
| **Auditoria ISO 27001** | Logs básicos | Evidência de aprovação + justificativa + rastreabilidade |
| **Custo de licenças Microsoft** | N/A (AWS/GCP) | ✅ Zero — utiliza apenas Entra ID Free |

A solução consiste em:
1. App Registration no Entra ID com permissões Graph API
2. Instalação do conector oficial Graph (`connector-msgraph-1.0.2.0.jar`)
3. Resource com Schema Handling para usuários e Directory Roles (sem licenças)
4. Workflow de aprovação para provisionamento
5. Regras SoD para prevenção de conflitos
6. Tarefa de reconciliação para detecção de Shadow IT
7. Certificação periódica de acesso

---

## 2. Arquitetura da Solução (FinOps Aligned)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                    PRJ027 - midPoint 4.10 → Microsoft Entra ID Free                 │
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
│  │  │                    Role "Entra ID Basic User"                               │││
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
│  │  │  │  ├── name → userPrincipalName (UPN@fiqueok.com.br)                    │  │││
│  │  │  │  ├── givenName → givenName                                            │  │││
│  │  │  │  ├── familyName → surname                                             │  │││
│  │  │  │  └── email → mail                                                     │  │││
│  │  │  │                                                                        │  │││
│  │  │  │  ⚠️ NENHUMA LICENÇA (SKU) é provisionada (Entra ID Free)              │  │││
│  │  │  └───────────────────────────────────────────────────────────────────────┘  │││
│  │  └─────────────────────────────────────────────────────────────────────────────┘││
│  │                                             │                                    ││
│  │                                             │ HTTPS + Graph API                  ││
│  │                                             ▼                                    ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    Microsoft Entra ID Free (tenant: fiqueok.com.br)             ││
│  │                                                                                  ││
│  │  ┌─────────────────────────────────────────────────────────────────────────────┐││
│  │  │  App Registration: midpoint-iga-connector                                   │││
│  │  │  - Client ID, Tenant ID (configurados no midPoint)                          │││
│  │  │  - Client Secret (armazenado no Vault ou cofre segregado)                  │││
│  │  │                                                                              │││
│  │  │  Permissões Graph API (Application):                                        │││
│  │  │  ├── User.ReadWrite.All                                                     │││
│  │  │  ├── Directory.ReadWrite.All                                                │││
│  │  │  ├── GroupMember.ReadWrite.All                                              │││
│  │  │  ├── RoleManagement.ReadWrite.Directory                                     │││
│  │  │  └── Organization.Read.All                                                  │││
│  │  │                                                                              │││
│  │  │  ⚠️ Nenhuma permissão de LicenseAssignment (não será usado)                 │││
│  │  └─────────────────────────────────────────────────────────────────────────────┘││
│  │                                                                                  ││
│  │  ┌─────────────────────────────────────────────────────────────────────────────┐││
│  │  │  Objetos provisionados (Entra ID Free - gratuito até 50.000 objetos):       │││
│  │  │  ├── Usuários (UPN, nome, e-mail)                                           │││
│  │  │  ├── Directory Roles (User Administrator, Helpdesk Admin, etc.)             │││
│  │  │  └── ⚠️ NENHUMA LICENÇA DE PRODUTIVIDADE (M365, EMS)                        │││
│  │  └─────────────────────────────────────────────────────────────────────────────┘││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    FUTURO ERP (via SAML/OIDC)                                   ││
│  │                                                                                  ││
│  │  Usuário acessa ERP → Redirecionado para Entra ID Free → Autenticação →        ││
│  │  ERP recebe claims (nome, email) → Acesso concedido                             ││
│  │                                                                                  ││
│  │  ⚠️ O ERP NÃO terá senhas locais. Toda autenticação delegada ao Entra ID.       ││
│  │  ⚠️ Recursos avançados (Conditional Access, PIM) exigem licenças P1/P2.         ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Conceitos Fundamentais (Leitura Obrigatória)

### 3.1. O que é o Graph Connector?

O **GraphConnector** da Evolveum é o conector oficial para Microsoft Graph API. Ele suporta:

| Operação | Suporte | Observação |
|----------|---------|------------|
| `createUser` | ✅ Completo | Cria usuário no Entra ID |
| `updateUser` | ✅ Completo | Atualiza atributos |
| `deleteUser` | ✅ Completo | Remove (ou desabilita) |
| `addToGroup` | ✅ Completo | Membros de grupos |
| `assignRole` | ✅ Completo | Directory roles (Admin, etc.) |
| `sync` | ✅ Completo | Reconciliação |
| `assignLicense` | ❌ **Não utilizado** | Não há licenças pagas no escopo |

### 3.2. O que é Microsoft Entra ID Free?

O **Entra ID Free** é a camada gratuita do diretório da Microsoft. Para este projeto, utilizamos apenas recursos gratuitos:

| Recurso | Suporte no Free | Observação |
|---------|-----------------|------------|
| Usuários (até 50.000) | ✅ | Objetos de diretório |
| Grupos (até 50.000) | ✅ | Grupos de segurança |
| Directory Roles | ✅ | Roles administrativas nativas |
| Autenticação (SAML/OIDC) | ✅ | SSO com aplicações |
| MFA (por usuário) | ✅ | Apenas MFA básica |
| Conditional Access | ❌ | Requer P1/P2 |
| PIM | ❌ | Requer P2 |

### 3.3. O que são Directory Roles no Entra ID?

Todas disponíveis no nível Free:

| Role | ID do Template | Uso no Projeto |
|------|----------------|----------------|
| Global Administrator | `62e90394-69f5-4237-9190-012177145e10` | Restrito (SoD) |
| User Administrator | `fe930be7-5e62-47db-91af-98c3a49a38b1` | Provisionamento |
| Helpdesk Administrator | `729827e3-9c14-49f7-bb1b-9608f156bbb8` | Suporte N1 |
| Security Reader | `5d6b6bb7-de71-4623-b4af-96380a352509` | Auditoria |

### 3.4. Workflow de Aprovação (Policy Rule)

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

### 3.5. Segregação de Funções (SoD) e FinOps

As regras SoD substituem a necessidade de ferramentas pagas como PIM (requer Entra ID P2, ~R$ 150/usuario/mês).

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

---

## 4. Pré-Requisitos Obrigatórios

| # | Pré-Requisito | Verificação | Critério |
|---|---------------|-------------|----------|
| PR-01 | Acesso ao servidor iga-gf-02 | `ssh paulo@xxx.xxx.xxx.xxx` | Login OK |
| PR-02 | Docker Compose funcionando | `cd /srv/iga-project && docker compose ps` | Container midpoint running |
| PR-03 | midPoint 4.10 operacional | `curl http://xxx.xxx.xxx.xxx:8080/midpoint` | HTTP 200 |
| PR-04 | Tenant Entra ID criado | `fiqueok.com.br` ou `fiqueok.onmicrosoft.com` | Tenant existe |
| PR-05 | Global Admin no Entra ID | Acesso ao portal Azure | Conta com permissão |
| PR-06 | Snapshot das VMs realizado | Hyper-V checkpoint | Checkpoint existe |
| PR-07 | Usuários no midPoint com atributo `manager` | Verificar usuários no GUI | Manager preenchido |
| PR-08 | Confirmação de que não há licenças pagas no tenant | Portal Azure → Licenças | Nenhuma SKU ativa |

---

## 5. Checklist de Pré-Verificação (Pre-Flight)

### 5.1. Instruções de Execução do Pre-Flight

Antes de iniciar a implementação, execute os comandos abaixo para validar o ambiente.

### 5.2. Comandos de Verificação

```bash
# [PowerShell - Hyper-V]
Get-VM | Select-Object Name, State, Uptime
Get-VMSnapshot -VMName "IGA-GF-02" | Select-Object Name, CreationTime
Get-VMSnapshot -VMName "VAULT-GEN1" | Select-Object Name, CreationTime

# [PowerShell - Tailscale]
tailscale status

# [SSH - iga-gf-02]
sudo docker ps --format "table {{.Names}}\t{{.Status}}" | grep midpoint
sudo docker exec iga-midpoint curl -s -o /dev/null -w "HTTP: %{http_code}\n" https://graph.microsoft.com/v1.0/
sudo docker exec iga-midpoint ls -la /opt/midpoint/var/icf-connectors/

# [SSH - vault-gf-01]
export VAULT_ADDR=http://127.0.0.1:8200
vault status
vault policy list

# [PowerShell - Entra ID]
Connect-MgGraph -Scopes "Application.Read.All", "Organization.Read.All"
Get-MgOrganization | Select Id, DisplayName
```

### 5.3. Resultado do Pre-Flight Executado em 08/05/2026

| Seção | Verificação | Status | Observação |
|-------|-------------|--------|-------------|
| **A1** | VM `iga-gf-02` Running | ✅ | `IGA-GF-02` Running |
| **A2** | VM `VAULT-GEN1` Running | ✅ | `VAULT-GEN1` Running |
| **A3** | Snapshot IGA-GF-02 | ✅ | `PRJ027-Antes-Implementacao-20260508` criado |
| **A4** | Snapshot VAULT-GEN1 | ✅ | `PRJ027-Antes-Implementacao-20260508` criado |
| **B1** | Container `iga-midpoint` Up | ✅ | `Up (healthy)` |
| **B4** | Acesso ao Graph API | ✅ | `HTTP: 200` |
| **B5** | Conector Graph presente | ✅ | `connector-msgraph-1.0.2.0.jar` instalado |
| **C1** | Vault unsealed | ✅ | `Sealed: false` |
| **C2** | Versão Vault | ✅ | `v1.21.3` |
| **C5** | Health Check HTTP 200 | ✅ | `{"initialized":true,"sealed":false}` |
| **D** | Conectividade Tailscale | ✅ | Todas as VMs ativas |
| **D5** | Latência entre VMs | ✅ | `0.4-1.1ms` |
| **E** | Entra ID conectado | ✅ | `Tenant ID: 503bbd0e-f33f-4ebe-b12e-f24a5069789c` |
| **F1** | CSV importado | ✅ | `103 linhas` |
| **F3** | Usuários FP001-FP012 | ✅ | Existem no midPoint |
| **G** | Snapshots rollback | ✅ | Criados para ambas VMs |

**Pre-Flight Status:** ✅ **APROVADO** — Ambiente pronto para implementação.

---

## 6. Procedimento de Rollback

### 6.1. Rollback Completo (Recomendado)

```powershell
# [WinHost]$ (PowerShell como Administrador)
Restore-VMSnapshot -VMName "IGA-GF-02" -Name "PRJ027-Antes-Implementacao-20260508" -Confirm:$false
Restore-VMSnapshot -VMName "VAULT-GEN1" -Name "PRJ027-Antes-Implementacao-20260508" -Confirm:$false
Start-VM -Name "IGA-GF-02"
Start-VM -Name "VAULT-GEN1"
```

### 6.2. Rollback Parcial (Apenas Role/Resource)

1. Acesse o GUI do midPoint
2. Delete o Resource Microsoft Entra ID (se existir)
3. Delete a Role Entra ID Basic User (se existir)
4. Remova as regras SoD e Workflow associadas
5. Recalcule os usuários afetados

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
| **Redirect URI** | (deixar em branco) |

Clique em **Register**

### 7.3. Configurar Client Secret

1. No App Registration, vá para **Certificates & secrets**
2. Clique em **New client secret**
3. Descrição: `midpoint-secret-2026`
4. Expira: `12 months`
5. Clique em **Add**

⚠️ **Copie o valor do segredo imediatamente** — será armazenado em local seguro.

### 7.4. Configurar Permissões Graph API

1. Vá para **API permissions**
2. Clique em **Add a permission** → **Microsoft Graph** → **Application permissions**
3. Adicione:

| Permissão | Motivo |
|-----------|--------|
| `User.ReadWrite.All` | Criar/atualizar usuários |
| `Directory.ReadWrite.All` | Ler/atualizar diretório |
| `GroupMember.ReadWrite.All` | Gerenciar membros de grupos |
| `RoleManagement.ReadWrite.Directory` | Atribuir roles administrativas |
| `Organization.Read.All` | Ler informações do tenant |

4. Clique em **Grant admin consent for Fiqueok**

### 7.5. Coletar Credenciais

| Credencial | Onde encontrar | Exemplo |
|------------|----------------|---------|
| **Tenant ID** | Overview do App Registration | `503bbd0e-f33f-4ebe-b12e-f24a5069789c` |
| **Client ID** | Overview do App Registration | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| **Client Secret** | Certificates & secrets | `cCc~cCc~cCc~cCc~` |

---

## 8. FASE 2: Instalação do Conector Graph (Nota: Nome Correto)

### ⚠️ ATENÇÃO: Nome Correto do Conector

O conector oficial da Evolveum para Microsoft Graph API chama-se **`connector-msgraph`** (não `connector-graph`). O repositório correto é:
- URL: `https://github.com/Evolveum/connector-microsoft-graph-api`

O arquivo JAR deve ser obtido via **Nexus Repository** (não há releases no GitHub):
- URL: `https://nexus.evolveum.com/nexus/repository/public/com/evolveum/polygon/connector-msgraph/1.0.2.0/connector-msgraph-1.0.2.0.jar`

### 8.1. Baixar o Conector (via PowerShell no Windows)

```powershell
# [PowerShell] - Baixar do Nexus
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "https://nexus.evolveum.com/nexus/repository/public/com/evolveum/polygon/connector-msgraph/1.0.2.0/connector-msgraph-1.0.2.0.jar" `
  -OutFile "C:\temp\midpoint-connectors\connector-msgraph-1.0.2.0.jar"
```

### 8.2. Copiar para o midPoint (SCP)

```powershell
# [PowerShell]
scp C:\temp\midpoint-connectors\connector-msgraph-1.0.2.0.jar paulo@xxx.xxx.xxx.xxx:/tmp/
```

### 8.3. Instalar no midPoint

```bash
# [iga-gf-02]
sudo cp /tmp/connector-msgraph-1.0.2.0.jar /srv/iga-project/data/midpoint/icf-connectors/
sudo chown 1000:1000 /srv/iga-project/data/midpoint/icf-connectors/connector-msgraph-*.jar
sudo chmod 644 /srv/iga-project/data/midpoint/icf-connectors/connector-msgraph-*.jar

# Reiniciar o midPoint
cd /srv/iga-project
sudo docker compose restart midpoint

# Verificar descoberta
sleep 30
sudo docker logs iga-midpoint --tail 50 | grep -i "msgraph"
```

**Saída esperada:**
```
INFO: Discovered ICF bundle in JAR: file:/opt/midpoint/var/icf-connectors/connector-msgraph-1.0.2.0.jar
INFO: Discovered new connector com.evolveum.polygon.connector.msgraph.MsGraphConnector v1.0.2.0
```

**Critério de Sucesso F2:** ✅ Log mostra descoberta do MsGraphConnector

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
4. Na lista de conectores, selecione **MsGraphConnector v1.0.2.0**
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
| **tenantId** | `503bbd0e-f33f-4ebe-b12e-f24a5069789c` | Seu Tenant ID |
| **clientId** | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` | Client ID do App |
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

## 10. FASE 4: Configuração do Schema Handling (Sem Licenças)

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

⚠️ **NÃO configurar mapeamento para `assignedLicenses`** (não há licenças pagas no escopo).

#### Passo 4: Configurar Correlação

| Campo | Valor |
|-------|-------|
| **Correlator item** | `userPrincipalName` |
| **Search method** | `Item` |
| **Source attribute** | `name` + domínio |
| **Target attribute** | `userPrincipalName` |

#### Passo 5: Configurar Sincronização

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
        </assignment>
    </policyConstraints>
    <policyActions>
        <approvalWorkflow>
            <level>
                <name>Manager Approval</name>
                <approverExpression>
                    <script>
                        <code>return "administrator";</code>
                    </script>
                </approverExpression>
                <autoApprovalIfEmpty>false</autoApprovalIfEmpty>
            </level>
            <level>
                <name>Security Owner Approval</name>
                <approverExpression>
                    <script>
                        <code>return "administrator";</code>
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

**Critério de Sucesso F6:** ✅ Workflow importado

---

## 13. FASE 7: Certificação de Acesso (Campanha)

### 13.1. Criar Campanha via GUI

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

### 13.2. Configurar Tarefa de Reconciliação

**Configuração da tarefa:**
- **Resource:** Microsoft Entra ID
- **Kind:** account
- **Intent:** entra-user
- **Schedule:** 0 0 2 * * ? (diariamente às 2h)

**Critério de Sucesso F7:** ✅ Campanha configurada, tarefa de reconciliação agendada

---

## 14. FASE 8: Criação da Role "Entra ID Basic User" (Sem Licenças)

### 14.1. Via Import (RAW XML)

```xml
<role xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
      xmlns:c="http://midpoint.evolveum.com/xml/ns/public/common/common-3">
    <name>Entra ID Basic User</name>
    <displayName>Entra ID Basic User</displayName>
    <description>Provisions a user in Microsoft Entra ID Free (no licenses)</description>
    <lifecycleState>active</lifecycleState>
    
    <inducement>
        <construction>
            <resourceRef oid="a6af855d-46b7-4c71-abe5-96c72b48863c" type="c:ResourceType"/>
            <kind>account</kind>
            <intent>entra-user</intent>
            
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
            
            <attribute>
                <ref>mail</ref>
                <outbound>
                    <strength>strong</strength>
                    <source>
                        <path>email</path>
                    </source>
                </outbound>
            </attribute>
            
            <!-- ⚠️ NENHUMA LICENÇA (SKU) é provisionada -->
        </construction>
    </inducement>
    
    <policyRuleRef oid="workflow-entra-approval-oid" type="c:PolicyRuleType"/>
    
    <extension>
        <certificationRequired>true</certificationRequired>
        <certificationPeriod>P90D</certificationPeriod>
        <securityLevel>standard</securityLevel>
    </extension>
</role>
```

### 14.2. Importar Role

1. **Administration** → **Import object**
2. Cole o XML acima
3. Substitua os OIDs pelos valores reais do seu ambiente
4. Clique em **Import**

**Critério de Sucesso F8:** ✅ Role criada com inducement e mapeamentos (sem licenças)

---

## 15. FASE 9: Atribuição da Role ao Usuário

### 15.1. Via GUI

1. Navegue para **Users** → **All users**
2. Clique no usuário desejado (ex: `FP001`)
3. Vá para a aba **Roles** (ou Assignments)
4. Clique em **Add** → **Role**
5. Digite `Entra ID Basic User`
6. Selecione a role na lista
7. Clique em **Save**

### 15.2. Aguardar Workflow

Após salvar, o workflow de aprovação será disparado. Aprove os casos no dashboard de **Cases** do midPoint.

### 15.3. Recalcular (se necessário)

```bash
# Via REST API
curl -X POST -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/users/FP001/recompute"
```

**Critério de Sucesso F9:** ✅ Role atribuída

---

## 16. FASE 10: Execução e Validação

### 16.1. Verificar no midPoint

No usuário, aba **Resource objects** → deve aparecer a shadow do **Microsoft Entra ID** com status **exists**.

### 16.2. Verificar no Entra ID (Portal Azure)

1. Acesse `https://portal.azure.com`
2. Navegue para **Microsoft Entra ID** → **Users**
3. Busque pelo usuário `FP001@fiqueok.com.br`
4. Verifique: Conta criada

### 16.3. Verificar Logs de Provisionamento

```bash
# [iga-gf-02]$
sudo docker logs iga-midpoint --tail 100 | grep -E "FP001|Entra ID|provision|workflow"
```

**Critério de Sucesso F10:** ✅ Usuário provisionado

---

## 17. POP: Joiner Automático (Procedimento Operacional Padrão)

### 17.1. Fluxo Completo "Joiner"

| Fase | Responsável | Ação no OrangeHRM | Ação no midPoint | Evidência para Auditoria |
|------|-------------|-------------------|------------------|--------------------------|
| **1. Admissão** | RH | Cadastra funcionário → CSV exportado (PRJ022) | Importa usuário com status `PendingApproval` | Hash do CSV + Timestamp |
| **2. Atribuição de Role** | Gestor (via GUI) | N/A | Atribui role `Entra ID Basic User` ao usuário | Assignment log |
| **3. SoD Check** | midPoint (automático) | N/A | Avalia regras SoD | PolicyViolation log |
| **4. Workflow - Nível 1** | Approver | Recebe e-mail com link | Aprova ou rejeita via dashboard | Approval record |
| **5. Workflow - Nível 2** | Security Owner | Recebe e-mail com link | Aprova ou rejeita via dashboard | Approval record |
| **6. Provisionamento** | midPoint (automático) | N/A | Chama Graph API: `POST /users` | `requestId` do Graph |
| **7. Reconciliação** | midPoint (diário) | N/A | `GET /users` compara com shadows | Relatório de diff |

---

## 18. Resolução de Problemas Comuns

| Erro | Causa Provável | Solução |
|------|----------------|---------|
| **Test Connection falha** | Credenciais incorretas | Verificar Tenant ID, Client ID, Secret |
| **No name in the new object** | Mapeamento `userPrincipalName` não configurado | Adicionar outbound mapping |
| **Workflow não dispara** | Policy rule não associada à role | Verificar `policyRuleRef` na role |
| **UPN já existe** | Usuário já provisionado manualmente | Reconciliação detecta e corrige |
| **Conector não aparece na lista** | Nome do arquivo incorreto | Usar `connector-msgraph-*.jar`, não `connector-graph-*.jar` |

---

## 19. Lições Aprendidas e Compliance

### 19.1. Lições Técnicas (PRJ027)

| # | Lição |
|---|-------|
| L01 | O nome correto do conector é `connector-msgraph`, não `connector-graph` |
| L02 | O repositório não tem releases; baixar via Nexus Repository |
| L03 | Workflow de aprovação pode usar approver fixo ("administrator") para testes |
| L04 | Usuários FP001-FP012 já existem no midPoint; manager pode ser atribuído via GUI |
| L05 | Nenhuma licença paga (SKU) deve ser provisionada (Entra ID Free) |

### 19.2. Verificações Obrigatórias Antes da Execução

| # | Verificação | Status |
|---|-------------|--------|
| V01 | Snapshots criados | ✅ |
| V02 | Conector Graph instalado | ✅ |
| V03 | Tenant ID obtido | ✅ |
| V04 | Usuários FP001 existem | ✅ |
| V05 | Vault operacional | ✅ |
| V06 | Tailscale conectividade | ✅ |

---

## 20. Decisões Arquiteturais para Futuro ERP (SSO)

### 20.1. Entra ID como IdP Soberano para ERP

**Contexto:** O futuro ERP não terá senhas locais. Toda autenticação será delegada ao Entra ID.

**Decisão:**
- O midPoint **NÃO gerencia senhas** para o ERP
- O midPoint **apenas provisiona** a conta no Entra ID
- O ERP **confia exclusivamente** no Entra ID via SAML2 ou OIDC

**Arquitetura:**
```
ERP → Entra ID (SAML/OIDC) → Autenticação → ERP recebe claims → Acesso concedido
```

---

## 21. Anexos: Comandos de Diagnóstico

### 21.1. Comandos no iga-gf-02

```bash
# Verificar conector instalado
sudo docker exec iga-midpoint ls -la /opt/midpoint/var/icf-connectors/ | grep msg

# Verificar log de provisionamento
sudo docker logs iga-midpoint --tail 200 | grep -E "Entra ID|msgraph|provision"
```

### 21.2. Comandos no Graph PowerShell

```powershell
Connect-MgGraph -Scopes "User.Read.All"
Get-MgUser -Filter "userPrincipalName -like '*@fiqueok.com.br'" | Select UserPrincipalName
```

---

## 22. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 06/05/2026 | Paulo Feitosa Lima | Documento inicial |
| **2.0** | **08/05/2026** | **Paulo Feitosa Lima** | **Incorporado Pre-Flight executado. Corrigido nome do conector para `connector-msgraph`. Adicionada nota sobre download via Nexus. Removidas referências a licenças pagas (FinOps). Simplificado workflow com approver fixo.** |

---

**Fim do POP-PRJ027-v2.0** ✅

---

*PRJ027 — Integração midPoint ↔ Microsoft Entra ID Free com Governança*  
*Living Lab Fiqueok*  
*Arquivado em: `FiqueokBrain/PRJ027/POP-PRJ027-v2.0.md`*
