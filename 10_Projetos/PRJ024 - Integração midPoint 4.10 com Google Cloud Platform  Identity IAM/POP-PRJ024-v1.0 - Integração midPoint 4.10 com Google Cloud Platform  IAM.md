
---


---

**Versão:** 1.0 ✅ **VALIDADO** — Baseado na execução real no Living Lab Fiqueok (POC)  
**Data:** 06/05/2026  
**Responsável:** Paulo Feitosa Lima  
**Status:** ✅ POC Concluída · Aguardando Decisão Arquitetural para PRD

---

## **ÍNDICE**

1. [Objetivo do Documento](#1-objetivo-do-documento)
2. [Arquitetura da Solução (POC vs PRD)](#2-arquitetura-da-solução-poc-vs-prd)
3. [Conceitos Fundamentais (Leitura Obrigatória)](#3-conceitos-fundamentais-leitura-obrigatória)
4. [Pré-Requisitos Obrigatórios](#4-pré-requisitos-obrigatórios)
5. [Checklist de Pré-Verificação (Pre-Flight)](#5-checklist-de-pré-verificação-pre-flight)
6. [Procedimento de Rollback](#6-procedimento-de-rollback)
7. [FASE 1: Instalação do Conector GCP](#7-fase-1-instalação-do-conector-gcp)
8. [FASE 2: Correção do Ambiente Java (trustAnchors)](#8-fase-2-correção-do-ambiente-java-trustanchors)
9. [FASE 3: Criação do Resource GCP IAM](#9-fase-3-criação-do-recurso-gcp-iam)
10. [FASE 4: Configuração do Schema Handling](#10-fase-4-configuração-do-schema-handling)
11. [FASE 5: Criação da Role GCP User](#11-fase-5-criação-da-role-gcp-user)
12. [FASE 6: Atribuição da Role ao Usuário](#12-fase-6-atribuição-da-role-ao-usuário)
13. [FASE 7: Execução e Validação](#13-fase-7-execução-e-validação)
14. [Resolução de Problemas Comuns](#14-resolução-de-problemas-comuns)
15. [Lições Aprendidas e Compliance](#15-lições-aprendidas-e-compliance)
16. [Decisões Arquiteturais para PRD (ADR)](#16-decisões-arquiteturais-para-prd-adr)
17. [Anexos: Comandos de Diagnóstico](#17-anexos-comandos-de-diagnóstico)
18. [Histórico de Versões](#18-histórico-de-versões)

---

## **1. Objetivo do Documento**

Este Procedimento Operacional Padrão (POP) descreve o passo a passo para integrar o **midPoint 4.10** com o **Google Cloud Platform (GCP) IAM** utilizando o **GCPConnector v1.3.0 da Atricore**, permitindo o provisionamento automático de usuários no Cloud Identity/Google Workspace.

**⚠️ IMPORTANTE:** Este POP documenta uma **POC (Prova de Conceito)** bem-sucedida. Para um ambiente de **PRODUÇÃO (PRD)** , consulte a **Seção 16 - Decisões Arquiteturais (ADR)** antes de qualquer implementação.

---

## **2. Arquitetura da Solução (POC vs PRD)**

### **2.1. Arquitetura da POC (Implementada no Lab)**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PRJ024 - midPoint ↔ GCP via Atricore Connector           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐     ┌─────────────────────────────────────────────────────┐│
│  │  Shadow API │     │                    midPoint 4.10                    ││
│  │  (PRJ008)   │────▶│  ┌───────────────────────────────────────────────┐  ││
│  └─────────────┘     │  │         Resource CSV (PRJ022-A)               │  ││
│                      │  │   employee_id, first_name, last_name, email   │  ││
│                      │  └─────────────────────┬─────────────────────────┘  ││
│                      │                        │                            ││
│                      │                        ▼                            ││
│                      │  ┌───────────────────────────────────────────────┐  ││
│                      │  │         Resource GCP (Atricore Connector)     │  ││
│                      │  │  - Configuração via GUI (mais estável)        │  ││
│                      │  │  - Outbound mapping: name → icfs:name         │  ││
│                      │  │  - Correlation por name                       │  ││
│                      │  └─────────────────────┬─────────────────────────┘  ││
│                      │                        │                            ││
│                      │                        │ HTTPS + Service Account    ││
│                      │                        ▼                            ││
│  ┌─────────────────────────────────────────────────────────────────────┐    ││
│  │                         GCP APIs (projeto midpoint-iga)              │    ││
│  │  ┌───────────────────────────────────────────────────────────────┐  │    ││
│  │  │  Cloud Identity API (cria usuários no diretório do projeto)   │  │    ││
│  │  └───────────────────────────────────────────────────────────────┘  │    ││
│  └─────────────────────────────────────────────────────────────────────┘    ││
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### **2.2. Arquitetura Recomendada para PRD (Multi-Cloud + Hybrid)**

Para um ambiente de produção com AWS, GCP, OCI, Entra ID e AD, a arquitetura deve ser:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ARQUITETURA IGA MULTI-CLOUD (PRD)                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │              FONTE AUTORITATIVA (HR System - OrangeHRM/SAP/Workday)  │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                      │                                       │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    midPoint 4.10+ (IdM / IGA Central)                │    │
│  │  - Ciclo de vida completo (Joiner/Mover/Leaver)                     │    │
│  │  - Reconciliação e Correlação                                       │    │
│  │  - Políticas de governança e certificação                           │    │
│  │  - Provisionamento para todos os targets via conectores/SCIM        │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                      │                                       │
│         ┌────────────────────────────┼────────────────────────────┐         │
│         ▼                            ▼                            ▼         │
│  ┌─────────────┐              ┌─────────────┐              ┌─────────────┐  │
│  │   Entra ID  │              │    AWS      │              │    GCP      │  │
│  │  (IdP +     │              │   IAM       │              │   IAM       │  │
│  │   Target)   │              │  (Target)   │              │  (Target)   │  │
│  └─────────────┘              └─────────────┘              └─────────────┘  │
│         │                            │                            │         │
│  ┌─────────────┐              ┌─────────────┐              ┌─────────────┐  │
│  │    AD       │              │    OCI      │              │  Keycloak   │  │
│  │  (Target)   │              │   IAM       │              │  (IdP alt)  │  │
│  └─────────────┘              └─────────────┘              └─────────────┘  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### **2.3. Trade-offs da Abordagem Atual (Atricore Connector)**

| Aspecto | POC (Atricore Connector) | PRD (Recomendado) |
|---------|--------------------------|-------------------|
| **Atributos suportados** | Apenas `icfs:name` e `icfs:groups` | Usar Admin SDK API diretamente |
| **Grupos** | Suporte não testado | Gerenciar via SCIM ou script complementar |
| **Cloud Identity** | Requer domínio (`fiqueok.com.br`) | Mesmo requisito |
| **Custo** | Gratuito (versão Free) | Gratuito até 50 usuários |
| **Manutenção** | Conector community-supported | API oficial do Google |

---

## **3. Conceitos Fundamentais (Leitura Obrigatória)**

### **3.1. O que é um Connector no midPoint?**

Um **Connector** é o componente que permite ao midPoint se comunicar com um sistema externo. O GCPConnector da Atricore implementa operações CRUD para usuários no Google Cloud Identity/Workspace.

### **3.2. O que é Cloud Identity?**

O **Cloud Identity** é o diretório de usuários do Google para organizações. Ele armazena identidades e pode ser usado para SSO, MFA e gerenciamento de dispositivos. **Não inclui** Gmail, Drive ou Agenda (esses são do Google Workspace).

### **3.3. Diferença entre Cloud Identity e IAM do GCP**

| Recurso | Cloud Identity | IAM do GCP |
|---------|----------------|------------|
| **O que faz** | Gerencia **quem** é o usuário | Gerencia **o que** o usuário pode fazer |
| **Exemplo** | Cria `fp001@fiqueok.com.br` | Atribui `roles/viewer` para FP001 |
| **Conector** | GCPConnector (este POP) | Outro conector ou API |

### **3.4. Por que o mapeamento `icfs:name` é OBRIGATÓRIO?**

O conector GCP exige o atributo `icfs:name` (que corresponde ao email do usuário) para criar a identidade. Sem este mapeamento, ocorre o erro:

```
No name in the new object. Cannot process an object without a name.
```

**Mapeamento correto no Schema Handling:**
```xml
<attribute>
    <ref>icfs:name</ref>
    <outbound>
        <strength>strong</strength>
        <source>
            <path>name</path>
        </source>
    </outbound>
</attribute>
```

### **3.5. O que é um Resource no midPoint?**

Um **Resource** é a instância configurada de um conector. Contém:
- Credenciais (Service Account Key JSON)
- Configuração do projeto GCP
- Schema Handling (mapeamentos)

---

## **4. Pré-Requisitos Obrigatórios**

| # | Pré-Requisito | Verificação | Critério |
|---|---------------|-------------|----------|
| PR-01 | Acesso ao servidor iga-gf-02 | `ssh paulo@xxx.xxx.xxx.xxx` | Login OK |
| PR-02 | Docker Compose funcionando | `cd /srv/iga-project && docker compose ps` | Container midpoint running |
| PR-03 | midPoint 4.10 operacional | `curl http://xxx.xxx.xxx.xxx:8080/midpoint` | HTTP 200 |
| PR-04 | Projeto GCP `midpoint-iga` criado | `gcloud projects describe midpoint-iga` | Projeto existe |
| PR-05 | Service Account `midpoint-connector` | `gcloud iam service-accounts list --project=midpoint-iga` | SA existe |
| PR-06 | Chave JSON da SA gerada | Arquivo `midpoint-gcp-key.json` | Existe no PC |
| PR-07 | Permissão `roles/iam.securityAdmin` | Verificar no GCP Console | Atribuída à SA |
| PR-08 | APIs ativadas | `admin.googleapis.com`, `cloudidentity.googleapis.com` | Ativadas |
| PR-09 | Snapshot das VMs realizado | Hyper-V checkpoint | Checkpoint existe |
| PR-10 | **Decisão arquitetural documentada (PRD)** | ADR aprovado | **Obrigatório para PRD** |

---

## **5. Checklist de Pré-Verificação (Pre-Flight)**

Execute os comandos abaixo **antes** de iniciar qualquer configuração.

### **5.1. Verificar Container do midPoint**

```bash
# [iga-gf-02]$
sudo docker ps --format "table {{.Names}}\t{{.Status}}" | grep midpoint
# Deve mostrar: iga-midpoint   Up X minutes
```

### **5.2. Verificar Conectividade com GCP**

```bash
# [iga-gf-02]$
sudo docker exec iga-midpoint curl -s -o /dev/null -w "HTTP: %{http_code}\n" https://iam.googleapis.com/
# Deve retornar: HTTP: 200
```

### **5.3. Verificar Arquivo do Conector**

```bash
# [iga-gf-02]$
ls -la /tmp/connector-gcp-*.jar
# Deve mostrar o arquivo connector-gcp-1.3.0.jar
```

### **5.4. Criar Snapshot de Segurança (OBRIGATÓRIO)**

```powershell
# [WinHost]$ (PowerShell como Administrador)
Checkpoint-VM -VMName "IGA-GF-02" -SnapshotName "PRJ024-Antes-Configuracao"
```

---

## **6. Procedimento de Rollback**

### **6.1. Rollback Completo (Recomendado)**

```powershell
# [WinHost]$ (PowerShell como Administrador)
Restore-VMSnapshot -VMName "IGA-GF-02" -Name "PRJ024-Antes-Configuracao" -Confirm:$false
Start-VM -Name "IGA-GF-02"
```

### **6.2. Rollback Parcial (Apenas Role/Resource)**

Se apenas a Role ou Resource precisar ser removido:

1. Acesse o GUI do midPoint
2. Delete o Resource GCP IAM (se existir)
3. Delete a Role GCP User (se existir)
4. Recalcule o usuário afetado

---

## **7. FASE 1: Instalação do Conector GCP**

### **7.1. Via Terminal (OBRIGATÓRIO)**

```bash
# [iga-gf-02]$

# Passo 1: Baixar o conector (se não tiver)
cd /tmp
wget https://github.com/atricore/midpoint-connector-gcp/releases/download/v1.3.0/connector-gcp-1.3.0.jar

# Passo 2: Copiar para o diretório de connectors
sudo cp /tmp/connector-gcp-1.3.0.jar /srv/iga-project/data/midpoint/icf-connectors/

# Passo 3: Ajustar permissões
sudo chown 1000:1000 /srv/iga-project/data/midpoint/icf-connectors/connector-gcp-*.jar
sudo chmod 644 /srv/iga-project/data/midpoint/icf-connectors/connector-gcp-*.jar

# Passo 4: Reiniciar o midPoint
cd /srv/iga-project
sudo docker compose restart midpoint
sleep 30

# Passo 5: Verificar descoberta do conector
sudo docker logs iga-midpoint --tail 100 | grep -i "gcp"
```

**Saída esperada:**
```
INFO: Discovered ICF bundle in JAR: com.atricore.iam.evolveum.connetor.connector-gcp version: 1.3.0
INFO: Discovered new connector connector:a19c4698-7912-4fee-be7d-51723021775c(ConnId com.atricore.iam.midpoint.connector.gcp.GoogleCloudConnector v1.3.0)
```

**Critério de Sucesso F1:** ✅ Log mostra descoberta do GCPConnector

---

## **8. FASE 2: Correção do Ambiente Java (trustAnchors)**

O Java dentro do container precisa confiar nos certificados SSL do GCP.

### **8.1. Configurar no docker-compose.yml (OBRIGATÓRIO)**

```bash
# [iga-gf-02]$
cd /srv/iga-project
sudo nano docker-compose.yml
```

**Adicionar/modificar a linha JAVA_OPTS:**
```yaml
environment:
  JAVA_OPTS: "-Xms512m -Xmx1024m -Dfile.encoding=UTF-8 -Djavax.net.ssl.trustStore=/usr/lib/jvm/java-21-openjdk-amd64/lib/security/cacerts -Djavax.net.ssl.trustStorePassword=changeit"
```

```bash
# Passo 2: Reiniciar para aplicar alterações
sudo docker compose down
sudo docker compose up -d
sleep 30

# Passo 3: Validar conectividade SSL
sudo docker exec iga-midpoint curl -s -o /dev/null -w "HTTP: %{http_code}\n" https://iam.googleapis.com/
```

**Saída esperada:** `HTTP: 200`

**Critério de Sucesso F2:** ✅ curl retorna HTTP 200

---

## **9. FASE 3: Criação do Resource GCP IAM**

### **9.1. Via Interface Gráfica (GUI) — RECOMENDADO PARA POC**

#### **Passo 1: Acessar o GUI do midPoint**
```
URL: http://xxx.xxx.xxx.xxx:8080/midpoint
Usuário: administrator
Senha: M1dP0!ntAdm!n#2026
```

#### **Passo 2: Criar novo Resource**
1. Navegue para **Resources** → **All resources**
2. Clique em **New resource** (botão verde)
3. Escolha **Create from scratch**
4. Na lista de conectores, selecione **GoogleCloudConnector v1.3.0**

#### **Passo 3: Preencher Basic Information**
| Campo | Valor |
|-------|-------|
| **Name** | `GCP IAM` |
| **Description** | `Google Cloud Identity & IAM - Atricore Connector v1.3.0` |
| **Lifecycle state** | `Active (production)` |

#### **Passo 4: Preencher Configuration**
| Campo | Valor | Observação |
|-------|-------|------------|
| **GCP Project ID** | `midpoint-iga` | Digitar |
| **Service Account Key** | Cole o JSON completo | Use "Use clear value" |
| **Allow Cache** | `false` (desmarcado) | Manter desativado |

**Conteúdo do JSON a colar:**
```json
{
  "type": "service_account",
  "project_id": "midpoint-iga",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "midpoint-connector@midpoint-iga.iam.gserviceaccount.com",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "...",
  "universe_domain": "googleapis.com"
}
```

#### **Passo 5: Selecionar Schema**
Marque **GWSAccount** (usuários do Workspace/Cloud Identity)

#### **Passo 6: Salvar e Testar**
1. Clique em **Save**
2. Clique em **Test connection**

**Saída esperada:** `Connection test completed successfully`

**Critério de Sucesso F3:** ✅ Test Connection OK

---

## **10. FASE 4: Configuração do Schema Handling**

### **10.1. Via Interface Gráfica (GUI)**

#### **Passo 1: Acessar Schema handling**
1. No Resource `GCP IAM`, clique na aba **Schema handling**
2. Clique em **Add object type** (já deve ter um criado)

#### **Passo 2: Configurar o Object Type**
| Campo | Valor |
|-------|-------|
| **Display name** | `GWS User` |
| **Kind** | `account` |
| **Intent** | `gws-account` |
| **Lifecycle state** | `Active (production)` |
| **Object class** | `GWSAccount` |

#### **Passo 3: Configurar atributos**
Adicione o mapeamento do nome:

| Configuração | Valor |
|--------------|-------|
| **Ref** | `icfs:name` |
| **Direction** | `outbound` |
| **Strength** | `strong` |
| **Source** | `path: name` |

#### **Passo 4: Configurar correlação**
Adicione correlator:
- **Item path:** `name`
- **Search path:** `icfs:name`

#### **Passo 5: Configurar sincronização**
Adicione reação para `unmatched` → `addFocus`

### **10.2. Alternativa: Raw XML**

```xml
<schemaHandling>
    <objectType>
        <kind>account</kind>
        <intent>gws-account</intent>
        <displayName>GWS User</displayName>
        <delineation>
            <objectClass>ri:GWSAccount</objectClass>
        </delineation>
        <attribute>
            <ref>icfs:name</ref>
            <outbound>
                <strength>strong</strength>
                <source>
                    <path>name</path>
                </source>
            </outbound>
        </attribute>
        <correlation>
            <correlators>
                <items>
                    <item>
                        <path>name</path>
                        <search>
                            <path>icfs:name</path>
                        </search>
                    </item>
                </items>
            </correlators>
        </correlation>
        <synchronization>
            <reaction>
                <situation>unmatched</situation>
                <actions>
                    <addFocus/>
                </actions>
            </reaction>
        </synchronization>
    </objectType>
</schemaHandling>
```

**Critério de Sucesso F4:** ✅ Schema Handling salvo sem erros

---

## **11. FASE 5: Criação da Role GCP User**

### **11.1. Via Import (RAW XML)**

```xml
<role xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
      xmlns:c="http://midpoint.evolveum.com/xml/ns/public/common/common-3">
    <name>GCP User Role</name>
    <displayName>GCP User Role</displayName>
    <description>Provisions a user account in Google Cloud Identity</description>
    <lifecycleState>active</lifecycleState>
    <inducement>
        <construction>
            <resourceRef oid="16478ce0-2831-4380-8176-ab795c4f16ba" type="c:ResourceType"/>
            <kind>account</kind>
            <intent>gws-account</intent>
        </construction>
    </inducement>
</role>
```

**Como importar:**
1. **Administration** → **Import object**
2. Cole o XML
3. Clique em **Import**

**Critério de Sucesso F5:** ✅ Role criada

---

## **12. FASE 6: Atribuição da Role ao Usuário**

### **12.1. Via GUI**

1. Navegue para **Users** → **All users**
2. Clique no usuário desejado (ex: `FP001`)
3. Vá para a aba **Roles**
4. Clique em **Add** → **Role**
5. Selecione `GCP User Role`
6. Clique em **Save**
7. Clique em **More actions** → **Recompute**

**Critério de Sucesso F6:** ✅ Recompute sem erros fatais

---

## **13. FASE 7: Execução e Validação**

### **13.1. Verificar no midPoint**

No usuário, aba **Resource objects** → deve aparecer a shadow do **GCP IAM** com status **exists**.

### **13.2. Verificar no GCP (Console Web)**

1. Acesse `https://console.cloud.google.com`
2. Selecione o projeto `midpoint-iga`
3. Ative **Cloud Identity** (gratuito) com domínio `fiqueok.com.br`
4. Acesse **Cloud Identity** → **Usuários**
5. O usuário `FP001` (ou `fp001@fiqueok.com.br`) deve aparecer

### **13.3. Verificar Logs**

```bash
# [iga-gf-02]$
sudo docker logs iga-midpoint --tail 50 | grep -E "FP001|GCP IAM|create"
```

**Saída esperada:**
```
GCP IAM - GWSAccount | create | Status: Success | AddSuccess -> FP001
```

---

## **14. Resolução de Problemas Comuns**

| Erro | Causa Provável | Solução |
|------|----------------|---------|
| **Test Connection falha** | Credenciais incorretas ou projeto não existe | Verificar JSON e project_id |
| **Undeclared namespace prefix 'c'** | Namespace `c` não declarado no XML | Adicionar `xmlns:c="..."` |
| **No name in the new object** | Mapeamento `icfs:name` não configurado | Adicionar outbound mapping no Schema Handling |
| **trustAnchors parameter must be non-empty** | Java não encontra cacerts | Adicionar `-Djavax.net.ssl.trustStore` no JAVA_OPTS |
| **Conector não aparece na lista** | JAR não foi descoberto | Verificar diretório `icf-connectors/` e permissões |
| **Usuário não aparece no Cloud Identity** | Cloud Identity não ativado ou domínio não verificado | Ativar Cloud Identity e validar domínio |

---

## **15. Lições Aprendidas e Compliance**

### **15.1. Lições Técnicas (PRJ024)**

| # | Lição |
|---|-------|
| L01 | O conector GCP da Atricore é minimalista — apenas `icfs:name` e `icfs:groups` estão disponíveis |
| L02 | O mapeamento `icfs:name` → `name` é **OBRIGATÓRIO** para criação de usuário |
| L03 | O erro `trustAnchors` é resolvido configurando `JAVA_OPTS` no docker-compose.yml |
| L04 | A configuração via GUI é mais estável que via curl com XML (escaping de JSON) |
| L05 | O projeto GCP `midpoint-iga` precisa ter o Cloud Identity ativado com domínio válido |
| L06 | A Service Account precisa das APIs `admin.googleapis.com` e `cloudidentity.googleapis.com` ativadas |
| L07 | O conector não suporta atributos como `givenName`, `familyName`, `primaryEmail` |
| L08 | Para PRD, recomenda-se usar a Admin SDK API diretamente para atributos adicionais |
| L09 | A versão gratuita do Cloud Identity suporta até 50 usuários — suficiente para POC |
| L10 | O mesmo padrão do AWS Connector se aplica: conector community-supported com limitações |

### **15.2. Verificações Obrigatórias Antes da Execução**

| # | Verificação | Comando |
|---|-------------|---------|
| V01 | Resource GCP IAM existe | Verificar no GUI em Resources |
| V02 | Test connection OK | Resource → Test connection |
| V03 | Role GCP User existe | Verificar no GUI em Roles |
| V04 | Role tem construction com resourceRef correto | Verificar RAW da role |
| V05 | Role tem mapeamento icfs:name | Verificar inducement/attribute |
| V06 | Usuário tem name preenchido | Verificar usuário no GUI |

### **15.3. Frameworks de Compliance Aplicados**

| Framework | Controle | Implementação |
|-----------|----------|---------------|
| **ISO 27001** | A.5.15 (Menor Privilégio) | Role específica para GCP |
| **ISO 27001** | A.8.12 (Gestão de Segredos) | Chave JSON armazenada criptografada no midPoint |
| **ISO 27001** | A.8.15 (Logging) | Logs do midPoint rastreiam criação de contas |
| **NIST SP 800-53** | AC-3 (Access Enforcement) | Provisionamento baseado em role |
| **CIS Controls** | 5 (Gestão de Contas) | Correlation rule garantindo unicidade |

---

## **16. Decisões Arquiteturais para PRD (ADR)**

### **16.1. ADR-001: Modelo de Identidade para Multi-Cloud**

**Contexto:** O Living Lab possui (ou terá) integrações com AWS, GCP, OCI, Entra ID e AD. Cada cloud tem seu próprio modelo de IAM, e o midPoint atua como motor central de governança.

**Decisão:** 
- **midPoint como IdM (Identity Management) central** — responsável por joiner/mover/leaver, reconciliação e provisionamento
- **Entra ID como IdP (Identity Provider) principal** — responsável por autenticação, SSO, MFA e Conditional Access
- **AD on-prem como target** — provisionado via midPoint (não via Cloud Sync, para evitar conflitos)
- **Keycloak como IdP alternativo** — para testes e ambientes não-Microsoft

**Trade-offs avaliados:**

| Modelo | Vantagens | Desvantagens | Decisão |
|--------|-----------|--------------|---------|
| **AD + Entra Cloud Sync + midPoint** | Mantém AD como fonte para legados | Dois motores de sync (risco de conflito) | ❌ Rejeitado |
| **Entra ID como IdP + IdM completo** | Simplicidade, ecossistema Microsoft | Vendor lock, custo P2, menos flexível | ⚠️ Parcial |
| **midPoint (IdM) + Entra ID (IdP)** | Separação clara, flexível, usa investimento existente | Duas ferramentas para gerenciar | ✅ **Aprovado** |

**Consequências:**
- midPoint deve provisionar **todos** os targets (incluindo Entra ID via Microsoft Graph)
- Cloud Sync do Azure não será utilizado
- Políticas de governança centralizadas no midPoint
- Para PRD: documentar approved workflow e recertification requirements

### **16.2. ADR-002: Abordagem para Conectores com Limitações**

**Contexto:** Os conectores comunitários para AWS e GCP (Atricore) são limitados — suportam apenas atributos básicos (nome), sem grupos ou políticas.

**Decisão:**
- Para **PRD**, usar conectores apenas para criação de usuários básicos
- Para **grupos/políticas**, usar APIs nativas (AWS CLI, gcloud, Azure Graph) via ScriptedREST como complemento
- Documentar como dívida técnica a ser resolvida em projetos futuros

**Alternativas consideradas:**
- Build Maven customizado do conector (descartado por esforço/risco)
- ScriptedSQL+HTTP (spike do PRJ022, não implementado)

### **16.3. ADR-003: Domínio e Cloud Identity para PRD**

**Contexto:** O GCP Connector requer um domínio verificado para criar usuários no Cloud Identity.

**Decisão:**
- Usar domínio corporativo existente (ex: `fiqueok.com.br`)
- Ativar Cloud Identity Free (sem custo até 50 usuários)
- Verificar propriedade do domínio via registro TXT no DNS

**Critérios para PRD:**
- Domínio principal definido e verificado
- Cloud Identity ativado antes do provisionamento em massa
- Validação de criação de usuário no diretório

---

## **17. Anexos: Comandos de Diagnóstico**

### **17.1. Comandos no iga-gf-02**

```bash
# Verificar conector instalado
sudo docker exec iga-midpoint ls -la /opt/midpoint/var/icf-connectors/ | grep -i gcp

# Verificar Java SSL
sudo docker exec iga-midpoint curl -v https://iam.googleapis.com 2>&1 | head -20

# Verificar log de provisionamento
sudo docker logs iga-midpoint --tail 200 | grep -E "GCP IAM|provision|create"

# Verificar Resource pelo OID
curl -u administrator:M1dP0!ntAdm!n#2026 \
  http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/resources/16478ce0-2831-4380-8176-ab795c4f16ba

# Listar shadows do Resource GCP
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/resources/16478ce0-2831-4380-8176-ab795c4f16ba/shadows" \
  -H "Accept: application/xml" | grep -o 'resourceObjectName="[^"]*"'
```

### **17.2. Comandos no Windows (GCP CLI)**

```cmd
# Verificar projeto
gcloud projects describe midpoint-iga

# Verificar Service Account
gcloud iam service-accounts list --project=midpoint-iga

# Ativar Cloud Identity (se necessário)
gcloud services enable cloudidentity.googleapis.com --project=midpoint-iga

# Trocar para conta pessoal (para listar projetos)
gcloud config set account feitosa.lima@gmail.com
gcloud projects list
```

### **17.3. Comandos no Windows Host (Hyper-V)**

```powershell
# Listar snapshots
Get-VMSnapshot -VMName "IGA-GF-02"

# Restaurar snapshot
Restore-VMSnapshot -VMName "IGA-GF-02" -Name "PRJ024-Antes-Configuracao" -Confirm:$false
```

---

## **18. Histórico de Versões**

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 06/05/2026 | Paulo Feitosa Lima |
