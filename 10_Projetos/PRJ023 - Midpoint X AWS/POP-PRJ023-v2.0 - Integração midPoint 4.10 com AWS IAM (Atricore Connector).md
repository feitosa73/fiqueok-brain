

**Versão:** 2.0 ✅ **VALIDADO** — Baseado na execução real no Living Lab Fiqueok  
**Data:** 05/05/2026  
**Responsável:** Paulo Feitosa Lima  
**Status:** ✅ Pronto para produção

---

## ÍNDICE

1. [Objetivo do Documento](#1-objetivo-do-documento)
2. [Arquitetura da Solução](#2-arquitetura-da-solução)
3. [Conceitos Fundamentais (Leitura Obrigatória)](#3-conceitos-fundamentais-leitura-obrigatória)
4. [Pré-Requisitos Obrigatórios](#4-pré-requisitos-obrigatórios)
5. [Checklist de Pré-Verificação (Pre-Flight)](#5-checklist-de-pré-verificação-pre-flight)
6. [Procedimento de Rollback](#6-procedimento-de-rollback)
7. [FASE 1: Instalação do Conector AWS](#7-fase-1-instalação-do-conector-aws)
8. [FASE 2: Correção do Ambiente Java (trustAnchors)](#8-fase-2-correção-do-ambiente-java-trustanchors)
9. [FASE 3: Criação do Resource AWS IAM](#9-fase-3-criação-do-resource-aws-iam)
10. [FASE 4: Configuração do Schema Handling](#10-fase-4-configuração-do-schema-handling)
11. [FASE 5: Criação da Role AWS IAM](#11-fase-5-criação-da-role-aws-iam)
12. [FASE 6: Atribuição da Role ao Usuário](#12-fase-6-atribuição-da-role-ao-usuário)
13. [FASE 7: Execução e Validação](#13-fase-7-execução-e-validação)
14. [Resolução de Problemas Comuns](#14-resolução-de-problemas-comuns)
15. [Lições Aprendidas e Compliance](#15-lições-aprendidas-e-compliance)
16. [Anexos: Comandos de Diagnóstico](#16-anexos-comandos-de-diagnóstico)
17. [Histórico de Versões](#17-histórico-de-versões)

---

## 1. Objetivo do Documento

Este Procedimento Operacional Padrão (POP) descreve o passo a passo para integrar o **midPoint 4.10** com a **AWS IAM** utilizando o **AWSConnector v1.1.2 da Atricore**, permitindo o provisionamento automático de usuários IAM.

A solução consiste em:
1. Instalação do conector AWS no midPoint
2. Configuração do Resource AWS IAM com credenciais
3. Criação de Role com account construction e mapeamento de atributos
4. Atribuição da Role ao usuário para provisionamento automático

---

## 2. Arquitetura da Solução

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    FLUXO DE PROVISIONAMENTO AWS IAM                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                         midPoint 4.10 (iga-gf-02)                        ││
│  │                         IP: xxx.xxx.xxx.xxx                                ││
│  │                                                                          ││
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────────┐  ││
│  │  │  AWS IAM    │    │  Role       │    │  Usuário FP004               │  ││
│  │  │  Resource   │◄───│  AWS IAM    │◄───│  (assign role)               │  ││
│  │  │  (connector)│    │  (inducement│    │                              │  ││
│  │  └─────────────┘    │   + mapping)│    └─────────────────────────────┘  ││
│  │         │           └─────────────┘                                      ││
│  │         │                    │                                           ││
│  │         ▼                    ▼                                           ││
│  │  ┌─────────────────────────────────────────────────────────────────┐    ││
│  │  │                    Provisionamento Automático                    │    ││
│  │  │  - Account construction com resourceRef correto                  │    ││
│  │  │  - Mapeamento name → icfs:name (obrigatório)                     │    ││
│  │  └─────────────────────────────────────────────────────────────────┘    ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│         │                                                                     │
│         │ AWS API (HTTPS)                                                     │
│         ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                           AWS IAM                                        ││
│  │  ┌─────────────────────────────────────────────────────────────────┐    ││
│  │  │  Usuários criados: FP004, FP008, etc.                            │    ││
│  │  └─────────────────────────────────────────────────────────────────┘    ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Conceitos Fundamentais (Leitura Obrigatória)

### 3.1. O que é um Connector no midPoint?

Um **Connector** é o componente que permite ao midPoint se comunicar com um sistema externo. O AWSConnector da Atricore implementa as operações de CRUD (Create, Read, Update, Delete) para usuários IAM da AWS.

### 3.2. O que é um Resource?

Um **Resource** é a instância configurada de um conector. Ele contém:
- Credenciais de acesso (Access Key, Secret Key)
- Configuração de região
- Definição de como os atributos são mapeados (Schema Handling)

### 3.3. O que é uma Role no midPoint?

Uma **Role** é um conjunto de políticas, permissões e **inductions** (construções de conta) que podem ser atribuídas a usuários. Quando um usuário recebe uma role, o midPoint automaticamente tenta provisionar as contas definidas nas **account constructions**.

### 3.4. O que é uma Account Construction?

É a definição dentro de uma role que diz: "Quando esta role for atribuída, crie uma conta no Resource X com kind Y e intent Z".

**Exemplo:**
```xml
<inducement>
    <construction>
        <resourceRef oid="a6af855d-46b7-4c71-abe5-96c72b48863c"/>
        <kind>account</kind>
        <intent>aws-iam-user</intent>
    </construction>
</inducement>
```

### 3.5. Por que o mapeamento `icfs:name` é OBRIGATÓRIO?

O conector da AWS espera receber o atributo `icfs:name` (que corresponde ao `userName` no IAM) para criar o usuário. Sem este mapeamento, o erro ocorre:

```
Required attribute is missing: Cannot invoke "User.userName()" because "user" is null
```

**Mapeamento correto:**
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

### 3.6. O que é o problema `trustAnchors`?

O Java dentro do container do midPoint precisa confiar nos certificados SSL da AWS. O erro `trustAnchors parameter must be non-empty` indica que o keystore de certificados não foi encontrado. A solução é configurar o `JAVA_OPTS` apontando para o cacerts correto.

---

## 4. Pré-Requisitos Obrigatórios

| # | Pré-Requisito | Verificação | Critério |
|---|---------------|-------------|----------|
| PR-01 | Acesso ao servidor iga-gf-02 | `ssh paulo@xxx.xxx.xxx.xxx` | Login OK |
| PR-02 | Docker Compose funcionando | `cd /srv/iga-project && docker compose ps` | Container midpoint running |
| PR-03 | midPoint 4.10 operacional | `curl http://xxx.xxx.xxx.xxx:8080/midpoint` | HTTP 200 |
| PR-04 | Credenciais AWS disponíveis | Access Key e Secret Key | Válidas e ativas |
| PR-05 | Snapshot das VMs realizado | Hyper-V checkpoint | Checkpoint existe |
| PR-06 | Internet no container | `docker exec iga-midpoint curl -I https://aws.amazon.com` | HTTP 200 |

---

## 5. Checklist de Pré-Verificação (Pre-Flight)

Execute os comandos abaixo **antes** de iniciar qualquer configuração.

### 5.1. Verificar Container do midPoint

```bash
# [iga-gf-02]$
sudo docker ps --format "table {{.Names}}\t{{.Status}}" | grep midpoint
# Deve mostrar: iga-midpoint   Up X minutes
```

### 5.2. Verificar Conectividade com AWS

```bash
# [iga-gf-02]$
sudo docker exec iga-midpoint curl -s -o /dev/null -w "HTTP: %{http_code}\n" https://iam.amazonaws.com
# Deve retornar: HTTP: 200
```

### 5.3. Verificar Arquivo do Conector

```bash
# [iga-gf-02]$
ls -la /tmp/connector-aws-*.jar
# Deve mostrar o arquivo connector-aws-1.1.2.jar
```

### 5.4. Criar Snapshot de Segurança (OBRIGATÓRIO)

```powershell
# [WinHost]$ (PowerShell como Administrador)
Checkpoint-VM -VMName "iga-gf-02" -SnapshotName "PRJ023-Antes-Configuracao"
```

---

## 6. Procedimento de Rollback

### 6.1. Rollback Completo (Recomendado)

```powershell
# [WinHost]$ (PowerShell como Administrador)
Restore-VMSnapshot -VMName "iga-gf-02" -Name "PRJ023-Antes-Configuracao" -Confirm:$false
Start-VM -Name "iga-gf-02"
```

### 6.2. Rollback Parcial (Apenas Role/Resource)

Se apenas a Role ou Resource precisar ser removido:

1. Acesse o GUI do midPoint
2. Delete o Resource AWS IAM (se existir)
3. Delete a Role AWS IAM (se existir)
4. Recalcule o usuário afetado

---

## 7. FASE 1: Instalação do Conector AWS

### 7.1. Via Interface Gráfica (GUI)

O midPoint 4.10 **não** permite upload de conector via GUI. Esta etapa é **necessariamente via linha de comando**.

### 7.2. Via Prompt (OBRIGATÓRIO)

```bash
# [iga-gf-02]$

# Passo 1: Copiar o JAR para o diretório de connectors
sudo cp /tmp/connector-aws-1.1.2.jar /srv/iga-project/data/midpoint/icf-connectors/

# Passo 2: Ajustar permissões
sudo chown 1000:1000 /srv/iga-project/data/midpoint/icf-connectors/connector-aws-*.jar
sudo chmod 644 /srv/iga-project/data/midpoint/icf-connectors/connector-aws-*.jar

# Passo 3: Reiniciar o midPoint
cd /srv/iga-project
sudo docker compose restart midpoint
sleep 30

# Passo 4: Verificar descoberta do conector
sudo docker logs iga-midpoint --tail 100 | grep -i "awsconnector"
```

**Saída esperada:**
```
INFO: Discovered ICF bundle in JAR: file:/opt/midpoint/var/icf-connectors/connector-aws-1.1.2.jar
```

**Critério de Sucesso F1:** ✅ Log mostra descoberta do AWSConnector

---

## 8. FASE 2: Correção do Ambiente Java (trustAnchors)

### 8.1. Via Interface Gráfica (GUI)

❌ **Não aplicável** — esta configuração é feita no `docker-compose.yml`

### 8.2. Via Prompt (OBRIGATÓRIO)

```bash
# [iga-gf-02]$

# Passo 1: Verificar estado atual do cacerts
sudo docker exec iga-midpoint ls -la /usr/lib/jvm/java-21-openjdk-amd64/lib/security/cacerts

# Passo 2: Editar docker-compose.yml
cd /srv/iga-project
sudo nano docker-compose.yml
```

**Adicionar/modificar a linha JAVA_OPTS:**
```yaml
      JAVA_OPTS: "-Xms512m -Xmx1024m -Dfile.encoding=UTF-8 -Djavax.net.ssl.trustStore=/usr/lib/jvm/java-21-openjdk-amd64/lib/security/cacerts -Djavax.net.ssl.trustStorePassword=changeit"
```

```bash
# Passo 3: Reiniciar para aplicar alterações
sudo docker compose down
sudo docker compose up -d
sleep 30

# Passo 4: Validar conectividade SSL
sudo docker exec iga-midpoint curl -s -o /dev/null -w "HTTP: %{http_code}\n" https://iam.amazonaws.com
```

**Saída esperada:** `HTTP: 200`

**Critério de Sucesso F2:** ✅ curl retorna HTTP 200

---

## 9. FASE 3: Criação do Resource AWS IAM

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
4. Na lista de conectores, selecione **AWSConnector v1.1.2**
5. Clique em **Next**

#### Passo 3: Preencher Basic Information

| Campo | Valor |
|-------|-------|
| **Name** | `AWS IAM` |
| **Description** | `AWS Identity and Access Management` |
| **Lifecycle state** | `Active (production)` |

Clique em **Next**

#### Passo 4: Preencher Configuration (CRÍTICO)

| Campo | Valor | Observação |
|-------|-------|------------|
| **awsAccessKeyId** | `<REDACTED_SECRET>` | Digitar diretamente |
| **awsSecretAccessKey** | `<REDACTED_SECRET>` | Selecionar "Use clear value" |
| **awsRegion** | `us-east-1` | Digitar |
| **Allow Cache** | `False` (desmarcado) | Manter desativado |

Clique em **Next** até finalizar

#### Passo 5: Testar Conexão
1. Clique em **Save**
2. Clique em **Test connection**

**Saída esperada:** `Connection test completed successfully`

---

### 9.2. Via Prompt (RAW XML) — ALTERNATIVO

```xml
<resource xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3" 
          oid="a6af855d-46b7-4c71-abe5-96c72b48863c">
    <name>AWS IAM</name>
    <connectorRef oid="327a818b-96a2-44b1-a2d2-096f27a3cb94"/>
    <connectorConfiguration>
        <icfc:configurationProperties>
            <cfg:awsAccessKeyId><REDACTED_SECRET></cfg:awsAccessKeyId>
            <cfg:awsSecretAccessKey>
                <t:clearValue><REDACTED_SECRET></t:clearValue>
            </cfg:awsSecretAccessKey>
            <cfg:awsRegion>us-east-1</cfg:awsRegion>
            <cfg:allowCache>false</cfg:allowCache>
        </icfc:configurationProperties>
    </connectorConfiguration>
</resource>
```

**Como importar:**
1. Acesse **Administration** → **Import**
2. Cole o XML
3. Clique em **Import**

---

## 10. FASE 4: Configuração do Schema Handling

### 10.1. Via Interface Gráfica (GUI) — RECOMENDADO

Após criar o Resource, você será redirecionado para a tela principal.

#### Passo 1: Acessar Schema handling
1. No menu lateral do Resource, clique em **Schema handling**
2. Clique em **Add object type**

#### Passo 2: Preencher Basic Information

| Campo | Valor |
|-------|-------|
| **Display name** | `IAM User` |
| **Kind** | `account` |
| **Intent** | `aws-iam-user` |
| **Lifecycle state** | `Active (production)` |

Clique em **Next → Save → Next** até finalizar

#### Passo 3: Verificar atributos
O Schema handling deve ter **pelo menos** o mapeamento do nome:

| Source (midPoint) | Target (AWS) | Direction |
|-------------------|--------------|-----------|
| `name` | `__NAME__` | outbound |

**Observação:** O midPoint 4.10 pode criar automaticamente este mapeamento. Verifique se existe. Caso contrário, adicione manualmente.

---

### 10.2. Via Prompt (RAW XML) — ALTERNATIVO

```xml
<schemaHandling>
    <objectType>
        <kind>account</kind>
        <intent>aws-iam-user</intent>
        <displayName>IAM User</displayName>
        <delineation>
            <objectClass>ri:AccountObjectClass</objectClass>
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
    </objectType>
</schemaHandling>
```

---

## 11. FASE 5: Criação da Role AWS IAM

### 11.1. Via Interface Gráfica (GUI) — RECOMENDADO

#### Passo 1: Criar nova Role
1. Navegue para **Roles** → **All roles**
2. Clique em **New role** (botão verde)
3. Escolha **Create from scratch**

#### Passo 2: Preencher Basic Information

| Campo | Valor |
|-------|-------|
| **Name** | `AWS IAM` |
| **Description** | `Provisiona usuário no AWS IAM` |
| **Lifecycle state** | `Active (production)` |

#### Passo 3: Adicionar Account Construction (Inducement)

1. Vá para a aba **Inducements**
2. Clique em **Add** → **Construction**
3. Preencha:

| Campo | Valor |
|-------|-------|
| **Resource** | `AWS IAM` (selecione da lista) |
| **Kind** | `account` |
| **Intent** | `aws-iam-user` |

#### Passo 4: Adicionar mapeamento do nome (CRÍTICO)

1. Dentro da mesma construction, clique em **Add** → **Attribute**
2. Preencha:

| Campo | Valor |
|-------|-------|
| **Name** | `Nome do usuário IAM` |
| **Ref** | `icfs:name` |
| **Direction** | `outbound` |
| **Strength** | `strong` |
| **Source** | `path: name` |

3. Clique em **Save**

#### Passo 5: Salvar a Role
Clique em **Save**

---

### 11.2. Via Prompt (RAW XML) — ALTERNATIVO

```xml
<role xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3" 
      oid="f41883a2-4822-4d45-ae2c-df12eb0f6999">
    <name>AWS IAM</name>
    <inducement>
        <construction>
            <resourceRef oid="a6af855d-46b7-4c71-abe5-96c72b48863c"/>
            <kind>account</kind>
            <intent>aws-iam-user</intent>
            <attribute>
                <ref>icfs:name</ref>
                <outbound>
                    <strength>strong</strength>
                    <source>
                        <path>name</path>
                    </source>
                </outbound>
            </attribute>
        </construction>
    </inducement>
</role>
```

**Como importar:**
1. Acesse **Administration** → **Import**
2. Cole o XML
3. Clique em **Import**

---

## 12. FASE 6: Atribuição da Role ao Usuário

### 12.1. Via Interface Gráfica (GUI)

#### Passo 1: Localizar o usuário
1. Navegue para **Users** → **All users**
2. Clique no usuário desejado (ex: `FP004`)

#### Passo 2: Atribuir a Role
1. Vá para a aba **Roles** (ou Assignments)
2. Clique em **Add** → **Role**
3. Digite `AWS IAM`
4. Selecione a role na lista
5. Clique em **Save**

#### Passo 3: Recalcular o usuário
1. Clique em **More actions** → **Recompute**
2. Confirme

---

### 12.2. Via Prompt (RAW XML) — ALTERNATIVO

```xml
<user oid="oid_do_usuario_FP004" version="atual">
    <name>FP004</name>
    <assignment>
        <targetRef oid="f41883a2-4822-4d45-ae2c-df12eb0f6999" type="c:RoleType"/>
    </assignment>
</user>
```

**Como aplicar:**
1. Acesse o RAW do usuário
2. Adicione o assignment dentro de `<user>`
3. Salve e faça recompute

---

## 13. FASE 7: Execução e Validação

### 13.1. Verificar Provisionamento no GUI

Após o recompute, o provisionamento acontece automaticamente. Verifique:

1. Acesse o usuário `FP004`
2. Vá para a aba **Resource objects**
3. Deve aparecer uma conta no **AWS IAM**

### 13.2. Verificar na AWS Console

1. Acesse AWS Console → IAM → Users
2. Verifique se o usuário `FP004` foi criado

### 13.3. Verificar Logs

```bash
# [iga-gf-02]$
sudo docker logs iga-midpoint --tail 50 | grep -E "FP004|AWS IAM|create"
```

**Saída esperada:**
```
INFO: Account (aws-iam-user) on AWS IAM: Add:Success -> FP004
```

---

## 14. Resolução de Problemas Comuns

| Erro | Causa Provável | Solução |
|------|----------------|---------|
| **Resource reference seems to be invalid** | OID do Resource na role está incorreto ou Resource não existe | Verificar OID correto e atualizar `<resourceRef>` |
| **Required attribute is missing: user.userName() null** | Mapeamento `icfs:name` não configurado | Adicionar `<attribute>` com `ref="icfs:name"` mapeando `name` |
| **trustAnchors parameter must be non-empty** | Java não encontra cacerts | Adicionar `-Djavax.net.ssl.trustStore` no JAVA_OPTS |
| **Test connection fails** | Credenciais AWS incorretas ou rede bloqueada | Verificar Access Key, Secret Key e região |
| **Conector não aparece na lista** | JAR não foi descoberto | Verificar permissões e reiniciar midPoint |
| **Role não provisiona conta** | Role não tem construction ou resourceRef errado | Verificar inducement e resourceRef |
| **Usuário não tem name** | Atributo `name` do usuário está vazio | Preencher `name` no usuário antes de atribuir role |

---

## 15. Lições Aprendidas e Compliance

### 15.1. Lições Técnicas (PRJ023)

| # | Lição |
|---|-------|
| L01 | O mapeamento `icfs:name` → `name` é **OBRIGATÓRIO** para criação de usuário no AWS IAM |
| L02 | O `resourceRef` na role deve usar o OID **correto** do Resource, não um OID antigo ou inexistente |
| L03 | O erro `trustAnchors` é resolvido configurando `JAVA_OPTS` no docker-compose.yml |
| L04 | O conector AWS precisa ser instalado via cópia do JAR e reinicialização do container |
| L05 | A role pode ser corrigida diretamente pelo RAW, sem precisar recriar do zero |
| L06 | Após corrigir a role, é **obrigatório** fazer recompute do usuário afetado |
| L07 | O intent `aws-iam-user` deve existir no Schema Handling do Resource |
| L08 | O provisionamento acontece **automaticamente** no recompute, não precisa de tarefa separada |
| L09 | O container do midPoint pode ter problemas de SSL se o cacerts não estiver acessível |
| L10 | O campo `awsSecretAccessKey` pode ser inserido como `clearValue` para testes, mas em produção deve ser criptografado |

### 15.2. Verificações Obrigatórias Antes da Execução

| # | Verificação | Comando |
|---|-------------|---------|
| V01 | Resource AWS IAM existe | Verificar no GUI em Resources |
| V02 | Test connection OK | Resource → Test connection |
| V03 | Role AWS IAM existe | Verificar no GUI em Roles |
| V04 | Role tem construction com resourceRef correto | Verificar RAW da role |
| V05 | Role tem mapeamento icfs:name | Verificar inducement/attribute |
| V06 | Usuário tem name preenchido | Verificar usuário no GUI |

### 15.3. Frameworks de Compliance Aplicados

| Framework | Controle | Implementação |
|-----------|----------|---------------|
| **ISO 27001** | A.5.15 (Menor Privilégio) | Role específica para AWS IAM |
| **ISO 27001** | A.8.12 (Gestão de Segredos) | Senha AWS não hardcoded no POP (exemplo ofuscado) |
| **ISO 27001** | A.8.15 (Logging) | Logs do midPoint rastreiam criação de contas |
| **NIST SP 800-53** | AC-3 (Access Enforcement) | Provisionamento baseado em role |
| **PCI-DSS v4.0** | 7.2 (Access Control) | Atribuição controlada de role |

---

## 16. Anexos: Comandos de Diagnóstico

### 16.1. Comandos no iga-gf-02

```bash
# Verificar conector instalado
sudo docker exec iga-midpoint ls -la /opt/midpoint/var/icf-connectors/ | grep -i aws

# Verificar Java SSL
sudo docker exec iga-midpoint curl -v https://iam.amazonaws.com 2>&1 | head -20

# Verificar log de provisionamento
sudo docker logs iga-midpoint --tail 200 | grep -E "AWS IAM|provision|create"

# Verificar Resource pelo OID
curl -u administrator:M1dP0!ntAdm!n#2026 \
  http://xxx.xxx.xxx.xxx:<REDACTED_SECRET>-46b7-4c71-abe5-96c72b48863c

# Verificar Role pelo OID
curl -u administrator:M1dP0!ntAdm!n#2026 \
  http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/roles/f41883a2-4822-4d45-ae2c-df12eb0f6999
```

### 16.2. Comandos no Windows Host (Hyper-V)

```powershell
# Listar snapshots
Get-VMSnapshot -VMName "iga-gf-02"

# Restaurar snapshot
Restore-VMSnapshot -VMName "iga-gf-02" -Name "PRJ023-Antes-Configuracao" -Confirm:$false
```

---

## 17. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 05/05/2026 | Paulo Feitosa Lima | Documento inicial baseado no TAP |
| **2.0** | **05/05/2026** | **Paulo Feitosa Lima** | **Versão VALIDADA após execução real. Adicionados: mapeamento icfs:name obrigatório, correção resourceRef, resolução trustAnchors, procedimentos via GUI e RAW, lições aprendidas L01-L10, verificações V01-V06.** |

---

**Fim do POP-PRJ023-v2.0** ✅

---

*PRJ023 — Integração midPoint ↔ AWS IAM*  
*Living Lab Fiqueok*  
*Arquivado em: `FiqueokBrain/PRJ023/POP-PRJ023-v2.0.md`*
