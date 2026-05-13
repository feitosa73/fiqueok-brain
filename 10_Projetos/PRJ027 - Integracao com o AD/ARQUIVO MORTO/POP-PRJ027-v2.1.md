## ✅ — Procedimento Operacional Padrão

### Integração midPoint 4.10 com Microsoft Entra ID Free (Governança + FinOps)

---

**Versão:** 2.1 ✅ **VALIDADO** — Baseado nas diretrizes do TAP e nos padrões dos POPs anteriores  
**Data:** 08/05/2026  
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

> Este projeto **NÃO** provisiona licenças Microsoft 365 E5, EMS E5 ou qualquer SKU que exija faturamento ativo no tenant. O ambiente utiliza **Microsoft Entra ID Free**, que suporta até 50.000 objetos de diretório sem custo.

**Diferenciais deste projeto:**

| Camada | Implementação |
|--------|---------------|
| **Provisionamento** | Usuário + Directory Roles (nativas) |
| **Workflow** | Aprovação de 2 níveis (Manager + Security) |
| **Segregação (SoD)** | Regras ativas (ex: AdminInfra + Auditor = BLOCK) |
| **Certificação** | Campanha trimestral com reconciliação |
| **Auditoria ISO 27001** | Evidência de aprovação + justificativa + rastreabilidade |
| **Custo de licenças Microsoft** | ✅ Zero — utiliza apenas Entra ID Free |

---

## 2. Arquitetura da Solução

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                         PRJ027 - midPoint 4.10 → Microsoft Entra ID Free            │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                         midPoint 4.10 (iga-gf-02)                                ││
│  │                         IP: xxx.xxx.xxx.xxx                                        ││
│  │                                                                                  ││
│  │  ┌─────────────┐    ┌─────────────────────────────────────────────────────────┐││
│  │  │  CSV HR     │───▶│  Usuário (ex: FP008)                                    │││
│  │  │  (PRJ022)   │    │  - name: FP008 → UPN: FP008@fiqueok.com.br              │││
│  │  └─────────────┘    │  - givenName, familyName, email                         │││
│  │                     └───────────────────────┬─────────────────────────────────┘││
│  │                                             │                                    ││
│  │                                             │ Atribuição da Role                 ││
│  │                                             ▼                                    ││
│  │  ┌─────────────────────────────────────────────────────────────────────────────┐││
│  │  │                    Role "Entra ID Basic User"                               │││
│  │  │  ├── Workflow de Aprovação (2 níveis: Manager + Security)                  │││
│  │  │  ├── SoD Rules (ex: AdminInfra + Auditor = BLOCK)                          │││
│  │  │  └── Account Construction (cria conta no Entra ID)                         │││
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
│  │  │  - Client ID, Tenant ID                                                     │││
│  │  │  - Client Secret (armazenado no Vault)                                      │││
│  │  │                                                                              │││
│  │  │  Permissões Graph API (Application):                                        │││
│  │  │  ├── User.ReadWrite.All                                                     │││
│  │  │  ├── Directory.ReadWrite.All                                                │││
│  │  │  ├── GroupMember.ReadWrite.All                                              │││
│  │  │  ├── RoleManagement.ReadWrite.Directory                                     │││
│  │  │  └── Organization.Read.All                                                  │││
│  │  └─────────────────────────────────────────────────────────────────────────────┘││
│  │                                                                                  ││
│  │  ⚠️ Nenhuma licença de produtividade (M365, EMS) será atribuída.                ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    FUTURO ERP (via SAML/OIDC)                                   ││
│  │                                                                                  ││
│  │  O Entra ID Free atuará como IdP para autenticação.                             ││
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

| Recurso | Suporte no Free | Observação |
|---------|-----------------|------------|
| Usuários (até 50.000) | ✅ | Objetos de diretório |
| Grupos (até 50.000) | ✅ | Grupos de segurança |
| Directory Roles | ✅ | Roles administrativas nativas |
| Autenticação (SAML/OIDC) | ✅ | SSO com aplicações |
| MFA (por usuário) | ✅ | Apenas MFA básica |
| Conditional Access | ❌ | Requer P1/P2 |
| PIM | ❌ | Requer P2 |

### 3.3. Diretriz Geral para Ambiente Greenfield (GF)

> ⚠️ **Esta seção documenta o procedimento padrão para um ambiente Greenfield (GF).**  
> *No caso específico do Living Lab Fiqueok, durante o Pre-Flight foram identificados artefatos residuais do PRJ012 (App Registration já existente). As adaptações necessárias estão documentadas na Seção 5.6. Para um ambiente Greenfield, siga rigorosamente as orientações das Fases abaixo.*

---

## 4. Pré-Requisitos Obrigatórios

| # | Pré-Requisito | Verificação | Critério |
|---|---------------|-------------|----------|
| PR-01 | Acesso ao servidor iga-gf-02 | `ssh paulo@xxx.xxx.xxx.xxx` | Login OK |
| PR-02 | Docker Compose funcionando | `cd /srv/iga-project && docker compose ps` | Container midpoint running |
| PR-03 | midPoint 4.10 operacional | `curl http://xxx.xxx.xxx.xxx:8080/midpoint` | HTTP 200 |
| PR-04 | Tenant Entra ID criado | `fiqueok.com.br` | Tenant existe |
| PR-05 | Global Admin no Entra ID | Acesso ao portal Azure | Conta com permissão |
| PR-06 | Snapshot das VMs realizado | Hyper-V checkpoint | Checkpoint existe |
| PR-07 | Usuários no midPoint com atributo `manager` | Verificar usuários no GUI | Manager preenchido |
| PR-08 | Confirmação de que não há licenças pagas no tenant | Portal Azure → Licenças | Nenhuma SKU ativa |

---

## 5. Checklist de Pré-Verificação (Pre-Flight)

### 5.1. Instruções de Execução

Antes de iniciar a implementação, execute os comandos abaixo para validar o ambiente.

### 5.2. Verificar Container do midPoint

```bash
# [iga-gf-02]
sudo docker ps --format "table {{.Names}}\t{{.Status}}" | grep midpoint
# Deve mostrar: iga-midpoint   Up X minutes (healthy)
```

### 5.3. Verificar Conectividade com Microsoft Graph

```bash
# [iga-gf-02]
sudo docker exec iga-midpoint curl -s -o /dev/null -w "HTTP: %{http_code}\n" \
  https://graph.microsoft.com/v1.0/
# Deve retornar: HTTP: 200
```

### 5.4. Verificar Usuários com Manager Preenchido

```bash
# [iga-gf-02]
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://localhost:8080/midpoint/ws/rest/users?search=manager" \
  -H "Accept: application/json" | jq '.users | length'
# Deve ser > 0
```

### 5.5. Criar Snapshot de Segurança (OBRIGATÓRIO)

```powershell
# [WinHost] (PowerShell como Administrador)
Checkpoint-VM -VMName "IGA-GF-02" -SnapshotName "PRJ027-Antes-Configuracao"
Checkpoint-VM -VMName "VAULT-GEN1" -SnapshotName "PRJ027-Antes-Configuracao"
```

### 5.6. 🔍 Adendo: Descoberta de Artefatos do PRJ012 (Contexto Específico do Lab)

> ⚠️ **Este adendo é específico para o Living Lab Fiqueok e NÃO se aplica a um ambiente Greenfield (GF).**  
> *Em um ambiente Greenfield, siga as orientações gerais das Fases 7 e 8 sem desvios.*

Durante a execução do Pre-Flight do PRJ027, foram identificados artefatos residuais de um projeto anterior (PRJ012). Abaixo o resumo da descoberta e as adaptações realizadas:

| Artefato | Estado Encontrado | Ação Adotada |
|----------|-------------------|--------------|
| App Registration `midpoint-iga-connector` | ✅ Ativo e preservado | Reaproveitado (evitou recriação) |
| Client ID | ✅ Válido | Reutilizado |
| Tenant ID | ✅ Correto | Reutilizado |
| Client Secret | ❌ Inválido (401 Não Autorizado) | Novo secret gerado |
| Permissões Graph | ⚠️ Parcial (3 de 5) | Adicionadas permissões faltantes |
| Conector Graph no midPoint | ❌ Não instalado | Instalado do zero |
| Shadows de usuários | ❌ 0 | Importados do zero |

**Conclusão:** A descoberta reduziu o esforço do projeto em aproximadamente 1-2 horas (criação do App Registration). Todas as demais etapas foram executadas conforme as orientações gerais deste POP.

---

## 6. Procedimento de Rollback

### 6.1. Rollback Completo (Recomendado)

```powershell
# [WinHost] (PowerShell como Administrador)
Restore-VMSnapshot -VMName "IGA-GF-02" -Name "PRJ027-Antes-Configuracao" -Confirm:$false
Restore-VMSnapshot -VMName "VAULT-GEN1" -Name "PRJ027-Antes-Configuracao" -Confirm:$false
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

### 7.1. Diretriz Geral (Ambiente Greenfield)

> ⚠️ **Esta seção descreve o procedimento padrão para um ambiente Greenfield.**  
> *No caso do Living Lab Fiqueok, o App Registration já existia (herdado do PRJ012). Pule para a Seção 7.6 para as adaptações específicas.*

### 7.2. Acessar o Portal do Azure

```
URL: https://portal.azure.com
Usuário: global-admin@fiqueok.com.br
```

### 7.3. Criar App Registration

1. Navegue para **Microsoft Entra ID** → **App registrations**
2. Clique em **+ New registration**
3. Preencha:

| Campo | Valor |
|-------|-------|
| **Name** | `midpoint-iga-connector` |
| **Supported account types** | `Accounts in this organizational directory only` |
| **Redirect URI** | (deixar em branco) |

4. Clique em **Register**

### 7.4. Configurar Client Secret

1. No App Registration, vá para **Certificates & secrets**
2. Clique em **+ New client secret**
3. Descrição: `midpoint-secret-2026`
4. Expira: `12 months`
5. Clique em **Add**

⚠️ **Copie o valor do segredo imediatamente** — será armazenado no Vault.

### 7.5. Configurar Permissões Graph API

1. Vá para **API permissions**
2. Clique em **+ Add a permission** → **Microsoft Graph** → **Application permissions**
3. Adicione as permissões:

| Permissão | Motivo |
|-----------|--------|
| `User.ReadWrite.All` | Criar/atualizar usuários |
| `Directory.ReadWrite.All` | Ler/atualizar diretório |
| `GroupMember.ReadWrite.All` | Gerenciar membros de grupos |
| `RoleManagement.ReadWrite.Directory` | Atribuir roles administrativas |
| `Organization.Read.All` | Ler informações do tenant |

4. Clique em **Grant admin consent for Fiqueok**

### 7.6. 🔍 Adendo: Adaptação para o Living Lab (Artefatos Existentes)

> ⚠️ **Esta seção é específica para o Living Lab Fiqueok e NÃO se aplica a um ambiente Greenfield.**

Em vez de criar um novo App Registration, reaproveitamos o existente (`midpoint-iga-connector`) com as seguintes adaptações:

| Ação | Procedimento |
|------|--------------|
| **Verificar App existente** | Confirmado no portal: Client ID `6df1b421-cf53-41c4-b4aa-9a5d50f65148`, Tenant ID `503bbd0e-f33f-4ebe-b12e-f24a506978c9` |
| **Verificar permissões** | 3 permissões já existiam (`User.ReadWrite.All`, `Group.ReadWrite.All`, `Directory.Read.All`) |
| **Adicionar permissões faltantes** | Adicionar `GroupMember.ReadWrite.All` e `Organization.Read.All` |
| **Verificar Client Secret** | Secret existente estava inválido (401) → **criar novo secret** |
| **Reaplicar consentimento** | Após adicionar permissões, clicar em **Grant admin consent** |

### 7.7. Coletar Credenciais

| Credencial | Valor |
|------------|-------|
| **Tenant ID** | `503bbd0e-f33f-4ebe-b12e-f24a506978c9` |
| **Client ID** | `6df1b421-cf53-41c4-b4aa-9a5d50f65148` |
| **Client Secret** | (valor gerado no passo 7.4 ou 7.6) |

### 7.8. Armazenar no HashiCorp Vault

```bash
# [vault-gf-01]
vault kv put secret/entra-id/auth \
  tenant_id="503bbd0e-f33f-4ebe-b12e-f24a506978c9" \
  client_id="6df1b421-cf53-41c4-b4aa-9a5d50f65148" \
  client_secret="NOVO_SECRET_AQUI"
```

**Critério de Sucesso F1:** ✅ App Registration configurado (ou reaproveitado), permissões consentidas, segredo armazenado no Vault

---

## 8. FASE 2: Instalação do Conector Graph

### 8.1. Download do Conector (Nexus Repository)

> ⚠️ **ATENÇÃO:** O nome correto do conector é `connector-msgraph`. O repositório GitHub NÃO contém releases prontos. Baixe via Nexus.

```powershell
# [PowerShell no Windows]
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
INFO: Discovered ICF bundle in JAR: .../connector-msgraph-1.0.2.0.jar
INFO: Discovered new connector com.evolveum.polygon.connector.msgraph.MsGraphConnector v1.0.2.0
```

**Critério de Sucesso F2:** ✅ Log mostra descoberta do MsGraphConnector

---

## 9. FASE 3: Criação do Resource Entra ID

### 9.1. Acessar o GUI do midPoint

```
URL: http://xxx.xxx.xxx.xxx:8080/midpoint
Usuário: administrator
Senha: M1dP0!ntAdm!n#2026
```

### 9.2. Criar novo Resource

1. Navegue para **Resources** → **All resources**
2. Clique em **New resource** (botão verde)
3. Escolha **Create from scratch**
4. Na lista de conectores, selecione **MsGraphConnector v1.0.2.0**
5. Clique em **Next**

### 9.3. Preencher Basic Information

| Campo | Valor |
|-------|-------|
| **Name** | `Microsoft Entra ID` |
| **Description** | `Microsoft Entra ID tenant - fiqueok.com.br` |
| **Lifecycle state** | `Active (production)` |

Clique em **Next**

### 9.4. Preencher Configuration (CRÍTICO)

| Campo | Valor | Observação |
|-------|-------|------------|
| **tenantId** | `503bbd0e-f33f-4ebe-b12e-f24a506978c9` | Do Vault |
| **clientId** | `6df1b421-cf53-41c4-b4aa-9a5d50f65148` | Do Vault |
| **clientSecret** | (referência Vault) | Use External Secret Store |
| **useCertificate** | `false` | Usamos secret |
| **graphEndpoint** | `https://graph.microsoft.com` | Padrão |

### 9.5. Testar Conexão

1. Clique em **Save**
2. Clique em **Test connection**

**Saída esperada:** ✅ `Connection test completed successfully`

**Critério de Sucesso F3:** ✅ Test Connection OK

---

## 10. FASE 4: Configuração do Schema Handling (Sem Licenças)

### 10.1. Acessar Schema handling

1. No Resource `Microsoft Entra ID`, clique na aba **Schema handling**
2. Clique em **Add object type**

### 10.2. Configurar o Object Type

| Campo | Valor |
|-------|-------|
| **Display name** | `Entra ID User` |
| **Kind** | `account` |
| **Intent** | `entra-user` |
| **Lifecycle state** | `Active (production)` |
| **Object class** | `UserType` |

### 10.3. Configurar Mapeamentos

Adicione os seguintes mapeamentos (outbound, strength=strong):

| Source (midPoint) | Target (Entra ID) | Expressão |
|-------------------|-------------------|-----------|
| `name` | `userPrincipalName` | `name + '@fiqueok.com.br'` |
| `givenName` | `givenName` | direto |
| `familyName` | `surname` | direto |
| `email` | `mail` | direto |

⚠️ **NÃO configurar mapeamento para `assignedLicenses`** (não há licenças pagas).

### 10.4. Configurar Correlação

| Campo | Valor |
|-------|-------|
| **Correlator item** | `userPrincipalName` |
| **Search method** | `Item` |
| **Source attribute** | `name` + domínio |
| **Target attribute** | `userPrincipalName` |

### 10.5. Configurar Sincronização

| Situation | Action |
|-----------|--------|
| `unmatched` | `addFocus` |
| `matched` | `link` |
| `deleted` | `unlink` |

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
            <message>SoD Violation: AdminInfra and Auditor cannot be combined</message>
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
            <message>SoD Warning: Desenvolvedor and BillingAdmin roles combined</message>
        </enforcement>
    </policyActions>
</policyRule>
```

### 11.2. Importar Regras

1. **Administration** → **Import object**
2. Cole o XML acima
3. Clique em **Import**

**Critério de Sucesso F5:** ✅ Regras SoD importadas

---

## 12. FASE 6: Workflow de Aprovação

### 12.1. Criar Policy Rule de Aprovação

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
| **Campaign type** | `Role Certification` |
| **Reviewer** | `Manager + Security Owner` |
| **Start** | `2026-07-01` |
| **Deadline** | `30 dias após início` |

### 13.2. Configurar Tarefa de Reconciliação

| Campo | Valor |
|-------|-------|
| **Resource** | `Microsoft Entra ID` |
| **Kind** | `account` |
| **Intent** | `entra-user` |
| **Schedule** | `0 0 2 * * ?` (diariamente às 2h) |

**Critério de Sucesso F7:** ✅ Campanha e reconciliação configuradas

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
</role>
```

### 14.2. Importar Role

1. **Administration** → **Import object**
2. Cole o XML acima
3. Substitua os OIDs pelos valores reais
4. Clique em **Import**

**Critério de Sucesso F8:** ✅ Role criada

---

## 15. FASE 9: Atribuição da Role ao Usuário

### 15.1. Via GUI

1. Navegue para **Users** → **All users**
2. Clique no usuário desejado (ex: `FP001`)
3. Vá para a aba **Roles**
4. Clique em **Add** → **Role**
5. Digite `Entra ID Basic User`
6. Selecione a role na lista
7. Clique em **Save**

### 15.2. Aprovar Workflow

1. Navegue para **Cases** → **My cases**
2. Aprove os dois níveis de aprovação

### 15.3. Recalcular (se necessário)

```bash
curl -X POST -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/users/FP001/recompute"
```

**Critério de Sucesso F9:** ✅ Role atribuída

---

## 16. FASE 10: Execução e Validação

### 16.1. Verificar no midPoint

No usuário, aba **Resource objects** → status **exists**

### 16.2. Verificar no Entra ID (Portal Azure)

1. Acesse `https://portal.azure.com`
2. **Microsoft Entra ID** → **Users**
3. Busque `FP001@fiqueok.com.br`
4. Conta deve existir

### 16.3. Verificar Logs

```bash
sudo docker logs iga-midpoint --tail 100 | grep -E "FP001|Entra ID|provision"
```

**Critério de Sucesso F10:** ✅ Usuário provisionado

---

## 17. POP: Joiner Automático

### 17.1. Fluxo Completo "Joiner"

| Fase | Responsável | Ação | Evidência |
|------|-------------|------|-----------|
| 1 | RH | Cadastra no OrangeHRM → CSV | Hash do CSV |
| 2 | Gestor | Atribui role `Entra ID Basic User` | Assignment log |
| 3 | midPoint | SoD Check | PolicyViolation log |
| 4 | Manager | Aprova via dashboard | Approval record |
| 5 | Security | Aprova via dashboard | Approval record |
| 6 | midPoint | Provisiona no Entra ID | `requestId` do Graph |
| 7 | midPoint | Reconciliação diária | Relatório de diff |

---

## 18. Resolução de Problemas Comuns

| Erro | Causa | Solução |
|------|-------|---------|
| **Test Connection falha** | Credenciais incorretas | Verificar Tenant ID, Client ID, Secret |
| **No name in new object** | Mapeamento `userPrincipalName` ausente | Adicionar outbound mapping |
| **Workflow não dispara** | Policy rule não associada | Verificar `policyRuleRef` |
| **Conector não aparece** | Nome do arquivo errado | Usar `connector-msgraph-*.jar` |

---

## 19. Lições Aprendidas e Compliance

### 19.1. Lições Técnicas

| # | Lição |
|---|-------|
| L01 | O nome correto do conector é `connector-msgraph`, não `connector-graph` |
| L02 | Baixar via Nexus Repository (GitHub não tem releases) |
| L03 | Workflow pode usar approver fixo "administrator" para testes |
| L04 | Nenhuma licença paga deve ser provisionada (FinOps) |

### 19.2. Frameworks de Compliance

| Framework | Controle | Implementação |
|-----------|----------|---------------|
| **ISO 27001** | A.5.15 (Menor Privilégio) | Workflow de aprovação |
| **ISO 27001** | A.5.16 (Gestão de Acessos) | Certificação trimestral |
| **ISO 27001** | A.5.17 (SoD) | Regras SoD ativas |
| **ISO 27001** | A.8.12 (Gestão de Segredos) | Client Secret no Vault |

---

## 20. Decisões Arquiteturais para Futuro ERP (SSO)

### 20.1. Entra ID como IdP Soberano

- midPoint **NÃO gerencia senhas** para o ERP
- midPoint **apenas provisiona** a conta no Entra ID
- ERP **confia** no Entra ID via SAML2 ou OIDC

---

## 21. Anexos: Comandos de Diagnóstico

```bash
# Verificar conector instalado
sudo docker exec iga-midpoint ls -la /opt/midpoint/var/icf-connectors/ | grep msg

# Verificar logs
sudo docker logs iga-midpoint --tail 200 | grep -E "Entra ID|msgraph"
```

---

## 22. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 06/05/2026 | Paulo Feitosa Lima | Documento inicial |
| **2.0** | **08/05/2026** | **Paulo Feitosa Lima** | **Adicionada Seção 5.6 com descoberta do PRJ012. Separadas orientações para Greenfield vs. Lab existente. Corrigido nome do conector para `connector-msgraph`. Removidas referências a licenças pagas (FinOps).** |

---

**Fim do POP-PRJ027-v2.0** ✅

---

*PRJ027 — Integração midPoint ↔ Microsoft Entra ID Free com Governança*  
*Living Lab Fiqueok*  
*Arquivado em: `FiqueokBrain/PRJ027/20 Execução/POP-PRJ027-v2.0.md`*
