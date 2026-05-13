## ✅ Análise Prévia — Impacto das Novas Decisões no que Iriamos Fazer

Antes de gerar o POP-PRJ027-v4.0, fiz uma análise de como cada nova decisão impacta a implementação **que já estava em andamento** no Living Lab.

---

## 📊 Impacto por Decisão — O que MUDA na Execução

| Decisão | Impacta o que JÁ IRIAMOS FAZER? | Ação Diferente Agora |
|---------|-------------------------------|----------------------|
| **1. Source of Truth (SoT)** | ❌ Não — é documentação, não configuração | Apenas declarar tabela no POP |
| **2. Leaver (Desprovisionamento)** | ✅ **SIM** — Iríamos pular essa etapa | Adicionar synchronization reaction para `deleted` e `unlink` |
| **3. Correlação com employeeNumber** | ✅ **SIM** — Iríamos usar apenas UPN | Configurar correlation com `employeeNumber` como primário |
| **4. Retry Policy (Throttling)** | ✅ **SIM** — Iríamos deixar em branco | Configurar `throttlingMaxWait` e `throttlingMaxReplyCount` |
| **5. Shadows órfãs pós-rollback** | ❌ Não — é procedimento, não configuração | Adicionar checklist no rollback |
| **6. Substituir senhas hardcoded** | ⚠️ **Parcial** — Já usamos Vault para Client Secret | Remover `administrator` hardcoded do workflow |
| **7. Workflow dinâmico (managerRef)** | ⚠️ **Parcial** — Iríamos usar `administrator` fixo | Configurar workflow dinâmico para PRD, manter fixo para LAB |
| **8. Rotação Client Secret** | ❌ Não — é política futura | Apenas documentar procedimento |

### Conclusão sobre Impacto na Implementação

| Tipo de Impacto | Itens |
|-----------------|-------|
| **Muda a configuração agora** | #2, #3, #4, #6, #7 (parcial) |
| **Apenas documentação** | #1, #5, #8 |

**Podemos prosseguir com a implementação** — as mudanças são incrementais e melhoram o que já faríamos, não invalidam nada já feito.

---

## 📝 — Procedimento Operacional Padrão

### Integração midPoint 4.10 com Microsoft Entra ID Free (Lifecycle IGA Completa)

---

**Versão:** 4.0 ✅ **APROVADO** — Enterprise-Grade, Lifecycle IGA Completa  
**Data:** 08/05/2026  
**Responsável:** Paulo Feitosa Lima  
**Status:** ✅ Pronto para implementação

---

## ÍNDICE

1. [Objetivo do Documento](#1-objetivo-do-documento)
2. [Arquitetura da Solução (Lifecycle IGA)](#2-arquitetura-da-solução-lifecycle-iga)
3. [Conceitos Fundamentais (Leitura Obrigatória)](#3-conceitos-fundamentais-leitura-obrigatória)
4. [Source of Truth (SoT) — Autoridade de Atributos](#4-source-of-truth-sot--autoridade-de-atributos)
5. [Pré-Requisitos Obrigatórios](#5-pré-requisitos-obrigatórios)
6. [Checklist de Pré-Verificação (Pre-Flight)](#6-checklist-de-pré-verificação-pre-flight)
7. [Procedimento de Rollback com Validação Pós-Restore](#7-procedimento-de-rollback-com-validação-pós-restore)
8. [FASE 1: Preparação do Entra ID (App Registration)](#8-fase-1-preparação-do-entra-id-app-registration)
9. [FASE 2: Instalação do Conector Graph](#9-fase-2-instalação-do-conector-graph)
10. [FASE 3: Criação do Resource Entra ID (com Retry Policy)](#10-fase-3-criação-do-resource-entra-id-com-retry-policy)
11. [FASE 4: Configuração do Schema Handling](#11-fase-4-configuração-do-schema-handling)
12. [FASE 5: Decisão sobre Direção dos Mappings](#12-fase-5-decisão-sobre-direção-dos-mappings)
13. [FASE 6: Configuração dos OUTBOUND Mappings](#13-fase-6-configuração-dos-outbound-mappings)
14. [FASE 7: Estratégia de Correlação (employeeNumber como Âncora)](#14-fase-7-estratégia-de-correlação-employeenumber-como-âncora)
15. [FASE 8: Regras de Sincronização (Joiner + Leaver)](#15-fase-8-regras-de-sincronização-joiner--leaver)
16. [FASE 9: Criação da Role e Atribuição (Joiner)](#16-fase-9-criação-da-role-e-atribuição-joiner)
17. [FASE 10: Validação do Provisionamento](#17-fase-10-validação-do-provisionamento)
18. [FASE 11: Workflow de Aprovação Dinâmico (managerRef)](#18-fase-11-workflow-de-aprovação-dinâmico-managerref)
19. [Regras de Segregação de Funções (SoD)](#19-regras-de-segregação-de-funções-sod)
20. [Certificação de Acesso (Campanha)](#20-certificação-de-acesso-campanha)
21. [Política de Rotação de Client Secret](#21-política-de-rotação-de-client-secret)
22. [POP: Lifecycle Joiner-Mover-Leaver (JML)](#22-pop-lifecycle-joiner-mover-leaver-jml)
23. [Resolução de Problemas Comuns](#23-resolução-de-problemas-comuns)
24. [Lições Aprendidas e Compliance](#24-lições-aprendidas-e-compliance)
25. [Decisões Arquiteturais Registradas (ADR-007)](#25-decisões-arquiteturais-registradas-adr-007)
26. [Anexos: Comandos de Diagnóstico](#26-anexos-comandos-de-diagnóstico)
27. [Histórico de Versões](#27-histórico-de-versões)

---

## 1. Objetivo do Documento

Este Procedimento Operacional Padrão (POP) descreve o passo a passo para implementar um **Ciclo de Vida Completo de Identidades (Lifecycle IGA)** entre o **midPoint 4.10** e o **Microsoft Entra ID Free**, abrangendo:

- **Joiner:** Provisionamento de novos usuários (OUTBOUND)
- **Mover:** Atualização de atributos (departamento, cargo, e-mail)
- **Leaver:** Desativação de contas e revogação de acesso
- **Reconciliação:** Detecção de Shadow IT e consistência pós-rollback
- **Governança:** Workflow de aprovação dinâmico, SoD, certificação trimestral

**⚠️ Declaração de Escopo (FinOps):**

> Este projeto **NÃO** provisiona licenças pagas. Utiliza **Microsoft Entra ID Free** (até 50.000 objetos).

---

## 2. Arquitetura da Solução (Lifecycle IGA)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                    PRJ027 - Lifecycle IGA: midPoint → Microsoft Entra ID Free              │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────┐│
│  │                         midPoint 4.10 (iga-gf-02) — SOURCE OF TRUTH MIDPOINT            ││
│  │                                                                                          ││
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────┐││
│  │  │  Fonte Autoritativa (RH) — CSV / OrangeHRM                                         │││
│  │  │  Atributos: givenName, familyName, email, employeeNumber, department, jobTitle     │││
│  │  └─────────────────────────────────────────────────────────────────────────────────────┘││
│  │                                             │                                            ││
│  │                                             ▼                                            ││
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────┐││
│  │  │  JOINER (OUTBOUND)                                                                  │││
│  │  │  ├── employeeNumber → employeeNumber (âncora imutável)                              │││
│  │  │  ├── name + '@dominio' → userPrincipalName                                          │││
│  │  │  ├── givenName → givenName                                                          │││
│  │  │  ├── familyName → surname                                                           │││
│  │  │  └── email → mail                                                                   │││
│  │  └─────────────────────────────────────────────────────────────────────────────────────┘││
│  │                                                                                          ││
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────┐││
│  │  │  LEAVER (Sincronização)                                                             │││
│  │  │  ├── Ao remover role → unlink (desvincula shadow, não deleta)                       │││
│  │  │  ├── Ao desligar usuário → disable (accountEnabled = false)                         │││
│  │  │  └── Opcional: revokeSignInSessions (revogar tokens ativos)                        │││
│  │  └─────────────────────────────────────────────────────────────────────────────────────┘││
│  │                                                                                          ││
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────┐││
│  │  │  RECONCILIAÇÃO (INBOUND)                                                            │││
│  │  │  ├── employeeNumber → employeeNumber (match da âncora)                              │││
│  │  │  ├── userPrincipalName → name (trazer UPN gerado)                                   │││
│  │  │  └── Detecção de contas órfãs (Shadow IT)                                           │││
│  │  └─────────────────────────────────────────────────────────────────────────────────────┘││
│  └─────────────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────┐│
│  │                    Microsoft Entra ID Free (fiqueok.com.br) — TARGET                    ││
│  │                                                                                          ││
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────┐││
│  │  │  Atributos gerenciados:                                                             │││
│  │  │  ├── userPrincipalName (FP001@fiqueok.com.br) — gerado pelo midPoint                │││
│  │  │  ├── employeeNumber (extension attribute) — âncora imutável                         │││
│  │  │  ├── givenName, surname, mail — sincronizados do RH                                 │││
│  │  │  └── accountEnabled — controlado pelo midPoint (Joiner/Leaver)                      │││
│  │  └─────────────────────────────────────────────────────────────────────────────────────┘││
│  └─────────────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                              │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Conceitos Fundamentais (Leitura Obrigatória)

### 3.1. Direção dos Mappings

| Direção | Fluxo | Uso | Quando |
|---------|-------|-----|--------|
| **OUTBOUND** | midPoint → Entra ID | Criar/Atualizar | Joiner, Mover |
| **INBOUND** | Entra ID → midPoint | Ler | Reconciliação, Shadow IT |

### 3.2. Âncora de Correlação

| Tipo | Atributo | Estabilidade | Recomendação |
|------|----------|--------------|--------------|
| **Primária** | `employeeNumber` | ✅ Imutável | Correlação principal |
| **Secundária** | `userPrincipalName` | ⚠️ Pode mudar | Fallback |

**Por que employeeNumber?** Se uma funcionária casa e muda de nome, o UPN muda, mas o employeeNumber permanece o mesmo. Com employeeNumber como âncora, o midPoint ainda reconhece a mesma pessoa.

### 3.3. Retry Policy (Throttling)

A Graph API tem limites de requisição. O conector suporta:

| Parâmetro | Valor | Efeito |
|-----------|-------|--------|
| `throttlingMaxReplyCount` | 20 | Máximo de respostas a processar por ciclo |
| `throttlingMaxWait` | 30 | Tempo máximo de espera (segundos) em caso de throttle |

---

## 4. Source of Truth (SoT) — Autoridade de Atributos

| Atributo | Fonte Autoritativa | Quem Atualiza | Observação |
|----------|---------------------|---------------|------------|
| `givenName` | RH (OrangeHRM/CSV) | RH | Primeiro nome |
| `familyName` | RH (OrangeHRM/CSV) | RH | Sobrenome |
| `email` | RH (OrangeHRM/CSV) | RH | E-mail corporativo |
| `employeeNumber` | RH (OrangeHRM/CSV) | RH | Matrícula — **ÂNCORA IMUTÁVEL** |
| `department` | RH (OrangeHRM/CSV) | RH | Departamento (RBAC) |
| `jobTitle` | RH (OrangeHRM/CSV) | RH | Cargo |
| `name` (midPoint) | midPoint | midPoint | Identificador canônico (FP001) |
| `userPrincipalName` | midPoint | midPoint | Construído: `name + '@dominio'` |
| `accountEnabled` | midPoint | midPoint (workflow) | Status da conta (Joiner/Leaver) |

**Princípio:** O midPoint é o **orquestrador**, não o dono dos dados biográficos. Ele lê do RH e escreve no Entra ID.

---

## 5. Pré-Requisitos Obrigatórios

| # | Pré-Requisito | Verificação | Critério |
|---|---------------|-------------|----------|
| PR-01 | Acesso ao servidor iga-gf-02 | `ssh paulo@xxx.xxx.xxx.xxx` | Login OK |
| PR-02 | midPoint 4.10 operacional | `docker ps \| grep midpoint` | Container running |
| PR-03 | Tenant Entra ID criado | `fiqueok.com.br` | Tenant existe |
| PR-04 | Global Admin no Entra ID | Acesso ao portal Azure | Conta com permissão |
| PR-05 | HashiCorp Vault operacional | `vault status` | Sealed: false |
| PR-06 | Usuários FPxxx no midPoint (com employeeNumber) | GUI → Users | Existem |
| PR-07 | Snapshots das VMs | Hyper-V checkpoint | Criado |

---

## 6. Checklist de Pré-Verificação (Pre-Flight)

```bash
# [iga-gf-02]
sudo docker ps | grep midpoint                    # Container running
sudo docker exec iga-midpoint curl -s -o /dev/null -w "HTTP: %{http_code}\n" https://graph.microsoft.com/v1.0/  # HTTP 200
sudo docker exec iga-midpoint ls -la /opt/midpoint/var/icf-connectors/ | grep msg  # connector-msgraph presente
```

```powershell
# [PowerShell]
Checkpoint-VM -VMName "IGA-GF-02" -SnapshotName "PRJ027-Antes-Configuracao"
Checkpoint-VM -VMName "VAULT-GEN1" -SnapshotName "PRJ027-Antes-Configuracao"
```

---

## 7. Procedimento de Rollback com Validação Pós-Restore

### 7.1. Rollback Completo

```powershell
# [PowerShell]
Restore-VMSnapshot -VMName "IGA-GF-02" -Name "PRJ027-Antes-Configuracao" -Confirm:$false
Restore-VMSnapshot -VMName "VAULT-GEN1" -Name "PRJ027-Antes-Configuracao" -Confirm:$false
Start-VM -Name "IGA-GF-02"
Start-VM -Name "VAULT-GEN1"
```

### 7.2. Validação Pós-Rollback (Evitar Shadows Órfãs)

Após o restore, validar:

```bash
# [iga-gf-02]
# Verificar se shadows existem
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://localhost:8080/midpoint/ws/rest/shadow/search?resource=ENTRA_RESOURCE_OID" \
  -H "Accept: application/json" | jq '.shadows | length'

# Se shadows count = 0, reexecutar reconciliação
# Se shadows count > 0, verificar consistência dos links
```

**Checklist de Validação Pós-Rollback:**

- [ ] Container midPoint está `Up` e saudável
- [ ] Resource Entra ID existe e Test Connection OK
- [ ] Shadows count > 0 ou reconciliação executada
- [ ] Usuários FPxxx têm manager preenchido
- [ ] Workflow de aprovação está ativo

---

## 8. FASE 1: Preparação do Entra ID (App Registration)

### 8.1. Acessar o Portal do Azure

```
URL: https://portal.azure.com
Usuário: global-admin@fiqueok.com.br
```

### 8.2. Criar ou Reaproveitar App Registration

| Cenário | Ação |
|---------|------|
| **Greenfield (GF)** | Criar novo com nome `midpoint-iga-connector` |
| **Ambiente existente** | Verificar se já existe; se sim, reaproveitar |

### 8.3. Configurar Permissões Graph API (Application Permissions)

| Permissão | Motivo |
|-----------|--------|
| `User.ReadWrite.All` | Criar/atualizar/desabilitar usuários (Joiner/Leaver) |
| `Directory.ReadWrite.All` | Ler/atualizar diretório |
| `GroupMember.ReadWrite.All` | Gerenciar membros de grupos (RBAC) |
| `RoleManagement.ReadWrite.Directory` | Atribuir roles administrativas |
| `Organization.Read.All` | Ler informações do tenant |

Clique em **Grant admin consent for Fiqueok**

### 8.4. Criar Client Secret

1. **Certificates & secrets** → **New client secret**
2. Descrição: `midpoint-secret-YYYY` (ano da rotação)
3. Expira: `12 months`
4. **Copiar o valor imediatamente**

### 8.5. Armazenar no HashiCorp Vault

```bash
# [vault-gf-01]
vault kv put secret/entra-id/auth \
  tenant_id="503bbd0e-f33f-4ebe-b12e-f24a506978c9" \
  client_id="6df1b421-cf53-41c4-b4aa-9a5d50f65148" \
  client_secret="NOVO_SECRET_AQUI"
```

---

## 9. FASE 2: Instalação do Conector Graph

```powershell
# [PowerShell]
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "https://nexus.evolveum.com/nexus/repository/public/com/evolveum/polygon/connector-msgraph/1.0.2.0/connector-msgraph-1.0.2.0.jar" \
  -OutFile "C:\temp\midpoint-connectors\connector-msgraph-1.0.2.0.jar"

scp C:\temp\midpoint-connectors\connector-msgraph-1.0.2.0.jar paulo@xxx.xxx.xxx.xxx:/tmp/
```

```bash
# [iga-gf-02]
sudo cp /tmp/connector-msgraph-1.0.2.0.jar /srv/iga-project/data/midpoint/icf-connectors/
sudo chown 1000:1000 /srv/iga-project/data/midpoint/icf-connectors/connector-msgraph-*.jar
sudo chmod 644 /srv/iga-project/data/midpoint/icf-connectors/connector-msgraph-*.jar
cd /srv/iga-project && sudo docker compose restart midpoint
sleep 30
sudo docker logs iga-midpoint --tail 50 | grep -i "msgraph"
```

**Saída esperada:** `Discovered ICF bundle ... connector-msgraph version: 1.0.2.0`

---

## 10. FASE 3: Criação do Resource Entra ID (com Retry Policy)

### 10.1. Acessar o GUI do midPoint

```
URL: http://xxx.xxx.xxx.xxx:8080/midpoint
Usuário: administrator
Senha: M1dP0!ntAdm!n#2026
```

### 10.2. Criar novo Resource

1. **Resources** → **All resources** → **New resource**
2. Selecione **MsGraphConnector v1.0.2.0**

### 10.3. Preencher Configuration (CRÍTICO)

| Campo | Valor | Observação |
|-------|-------|------------|
| **Name** | `Microsoft Entra ID` | |
| **tenantId** | `503bbd0e-f33f-4ebe-b12e-f24a506978c9` | Do Vault |
| **clientId** | `6df1b421-cf53-41c4-b4aa-9a5d50f65148` | Do Vault |
| **clientSecret** | (referência Vault) | Zero Plaintext |
| **throttlingMaxReplyCount** | `20` | Evita throttling |
| **throttlingMaxWait** | `30` | Tempo de espera (segundos) |

### 10.4. Testar Conexão

Clique em **Test connection** → deve retornar ✅ sucesso

---

## 11. FASE 4: Configuração do Schema Handling

### 11.1. Adicionar Object Type

| Campo                    | Valor                |
| ------------------------ | -------------------- |
| **Display name**         | `Entra ID User`      |
| **Kind**                 | `account`            |
| **Intent**               | `entra-user`         |
| **Object class**         | `AccountObjectClass` |
| **Type (MidPoint data)** | `User`               |

### 11.2. Importar Atributos Necessários

Certifique-se de que os seguintes atributos estão disponíveis no schema:

| Atributo Entra ID | Atributo midPoint | Uso |
|-------------------|-------------------|-----|
| `userPrincipalName` | `name` (outbound) | Identificador |
| `employeeNumber` | `employeeNumber` | **Âncora imutável** |
| `givenName` | `givenName` | Primeiro nome |
| `surname` | `familyName` | Sobrenome |
| `mail` | `email` | E-mail |
| `accountEnabled` | `activation` | Status da conta |

---

## 12. FASE 5: Decisão sobre Direção dos Mappings

> ⚠️ **Leia com atenção antes de prosseguir.**

| Cenário | Sequência Recomendada |
|---------|----------------------|
| **Greenfield (sem usuários no Entra ID)** | 1º OUTBOUND (criar) → 2º INBOUND (reconciliar) |
| **Migração (usuários já no Entra ID)** | 1º INBOUND (importar) → 2º OUTBOUND (atualizar) |
| **Living Lab (caso atual)** | FPxxx existem no midPoint, NÃO existem no Entra ID → **OUTBOUND primeiro** |

**Este POP segue o cenário Greenfield:** OUTBOUND primeiro.

---

## 13. FASE 6: Configuração dos OUTBOUND Mappings

### 13.1. Acessar Mappings (Outbound)

No Object Type `Entra ID User` → bloco **Mappings** → **Add outbound**

### 13.2. Mapeamento 1: `employeeNumber` → `employeeNumber` (Âncora)

| Campo | Valor |
|-------|-------|
| **Source** | `employeeNumber` |
| **Target** | `employeeNumber` |
| **Strength** | `strong` |

**Importância:** Este é o atributo que permite correlação imutável mesmo se o UPN mudar.

### 13.3. Mapeamento 2: `name` → `userPrincipalName`

| Campo | Valor |
|-------|-------|
| **Source** | `name` |
| **Target** | `userPrincipalName` |
| **Expression** | `name + '@fiqueok.com.br'` |
| **Strength** | `strong` |

### 13.4. Mapeamento 3: `givenName` → `givenName`

| Campo | Valor |
|-------|-------|
| **Source** | `givenName` |
| **Target** | `givenName` |
| **Strength** | `strong` |

### 13.5. Mapeamento 4: `familyName` → `surname`

| Campo | Valor |
|-------|-------|
| **Source** | `familyName` |
| **Target** | `surname` |
| **Strength** | `strong` |

### 13.6. Mapeamento 5: `email` → `mail`

| Campo | Valor |
|-------|-------|
| **Source** | `email` |
| **Target** | `mail` |
| **Strength** | `strong` |

### 13.7. Salvar

Clique em **Save mappings**

---

## 14. FASE 7: Estratégia de Correlação (employeeNumber como Âncora)

### 14.1. Configurar Correlation Rule

No Object Type `Entra ID User` → bloco **Correlation**

| Campo | Valor |
|-------|-------|
| **Rule name** | `Correlacao-employeeNumber` |
| **Source attribute** | `employeeNumber` (midPoint) |
| **Target attribute** | `employeeNumber` (Entra ID) |
| **Match threshold** | `1` |

### 14.2. Âncora Secundária (Fallback)

| Campo | Valor |
|-------|-------|
| **Rule name** | `Correlacao-UPN-fallback` |
| **Source attribute** | `name + '@fiqueok.com.br'` |
| **Target attribute** | `userPrincipalName` |
| **Priority** | `2` (apenas se primária falhar) |

**Por que esta ordem?** employeeNumber nunca muda. UPN pode mudar (casamento, rebranding). employeeNumber como primária garante resiliência.

---

## 15. FASE 8: Regras de Sincronização (Joiner + Leaver)

### 15.1. Configurar Synchronization

No Object Type `Entra ID User` → bloco **Synchronization**

| Situation                     | Action                 | Descrição                                 |
| ----------------------------- | ---------------------- | ----------------------------------------- |
| `unmatched`                   | `addFocus` + provision | **Joiner:** cria conta no Entra ID        |
| `matched`                     | `link` + update        | **Mover:** atualiza atributos se mudaram  |
| `deleted` (role removida)     | `unlink`               | Desvincula shadow, NÃO deleta conta       |
| `deleted` (usuário desligado) | `disable` + `unlink`   | Desabilita conta (`accountEnabled=false`) |

### 15.2. Leaver — Desativação de Conta

Quando um usuário é desligado no RH (status inativo), o midPoint deve:

1. **Desabilitar a conta:** `accountEnabled = false`
2. **Desvincular shadow:** `unlink` (mantém histórico)
3. **Opcional — revogar sessões ativas:** chamar `revokeSignInSessions` via script

---

## 16. FASE 9: Criação da Role e Atribuição (Joiner)

### 16.1. Criar Role "Entra ID Basic User"

```xml
<role xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3">
    <name>Entra ID Basic User</name>
    <displayName>Entra ID Basic User</displayName>
    <description>Provisions a user in Microsoft Entra ID Free (no licenses)</description>
    <lifecycleState>active</lifecycleState>
    
    <inducement>
        <construction>
            <resourceRef oid="RESOURCE_ENTRA_OID" type="c:ResourceType"/>
            <kind>account</kind>
            <intent>entra-user</intent>
            
            <!-- OUTBOUND Mappings já definidos no Schema Handling -->
        </construction>
    </inducement>
</role>
```

### 16.2. Atribuir Role ao Usuário FP001

1. **Users** → **All users** → `FP001`
2. **Roles** → **Add** → `Entra ID Basic User`
3. **Save**

### 16.3. Provisionamento Automático

Ao salvar, o midPoint:
1. Aplica OUTBOUND mappings
2. Cria o usuário no Entra ID
3. Registra shadow com status LINKED

---

## 17. FASE 10: Validação do Provisionamento

### 17.1. Verificar no midPoint

No usuário FP001, aba **Resource objects** → status **exists**

### 17.2. Verificar no Entra ID

1. `https://portal.azure.com` → **Microsoft Entra ID** → **Users**
2. Buscar `FP001@fiqueok.com.br`
3. Confirmar atributos: `employeeNumber`, `givenName`, `surname`, `mail`

### 17.3. Verificar Logs

```bash
sudo docker logs iga-midpoint --tail 100 | grep -E "FP001|provision|correlation"
```

---

## 18. FASE 11: Workflow de Aprovação Dinâmico (managerRef)

### 18.1. Modo LAB (Approver Fixo — Para Testes)

```xml
<approverExpression>
    <script>
        <code>return "administrator";</code>
    </script>
</approverExpression>
```

### 18.2. Modo PRD (Approver Dinâmico — Manager Real)

```xml
<approverExpression>
    <script>
        <code>
            import com.evolveum.midpoint.xml.ns._public.common.common_3.UserType;
            def managerRef = user.getManagerRef();
            if (managerRef != null) {
                def manager = midpoint.getObject(UserType.class, managerRef.getOid()).getFocus();
                return manager.getName();
            }
            return "security-owner@fiqueok.com.br"; // fallback
        </code>
    </script>
</approverExpression>
```

### 18.3. Pré-Requisito para Workflow Dinâmico

O atributo `manager` do usuário deve estar preenchido no midPoint.

```bash
# Verificar se manager está preenchido
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://localhost:8080/midpoint/ws/rest/users/FP001" \
  -H "Accept: application/json" | jq '.managerRef'
```

---

## 19. Regras de Segregação de Funções (SoD)

```xml
<policyRule>
    <name>SoD-AdminInfra-AuditorInterno</name>
    <policyConstraints>
        <and>
            <hasAssignment>
                <targetRef oid="role-admin-infra-oid" type="c:RoleType"/>
            </hasAssignment>
            <hasAssignment>
                <targetRef oid="role-auditor-oid" type="c:RoleType"/>
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

## 20. Certificação de Acesso (Campanha)

| Campo | Valor |
|-------|-------|
| **Name** | `Certificacao-Trimestral-EntraID` |
| **Campaign type** | `Role Certification` |
| **Reviewer** | `Manager + Security Owner` (dinâmico) |
| **Schedule** | Trimestral (janeiro, abril, julho, outubro) |
| **Deadline** | 30 dias após início |

---

## 21. Política de Rotação de Client Secret

### 21.1. Validade

- **Criação:** 12 meses
- **Alerta de expiração:** 30 dias antes

### 21.2. Procedimento de Rotação

1. **Gerar novo Client Secret** no portal Azure (mantendo o antigo por 24h)
2. **Atualizar Vault** com o novo secret
3. **Testar conexão** no Resource do midPoint
4. **Remover o secret antigo** do portal Azure
5. **Registrar rotação** no log do projeto

### 21.3. Comando de Rotação (Vault)

```bash
# [vault-gf-01]
vault kv put secret/entra-id/auth \
  tenant_id="503bbd0e-f33f-4ebe-b12e-f24a506978c9" \
  client_id="6df1b421-cf53-41c4-b4aa-9a5d50f65148" \
  client_secret="NOVO_SECRET_RODADO"
```

### 21.4. Monitoramento (Health Check Mensal)

```powershell
# [PowerShell] - Health check do secret
$clientId = "6df1b421-cf53-41c4-b4aa-9a5d50f65148"
$clientSecret = (vault kv get -field=client_secret secret/entra-id/auth)
$tenantId = "503bbd0e-f33f-4ebe-b12e-f24a506978c9"

try {
    $token = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Body @{
        client_id = $clientId
        client_secret = $clientSecret
        scope = "https://graph.microsoft.com/.default"
        grant_type = "client_credentials"
    }
    Write-Host "✅ Client Secret OK - Expira em: $($token.expires_in) segundos"
} catch {
    Write-Host "❌ Client Secret INVÁLIDO - ROTAÇÃO NECESSÁRIA" -ForegroundColor Red
}
```

---

## 22. POP: Lifecycle Joiner-Mover-Leaver (JML)

### 22.1. Joiner (Admissão)

| Fase | Responsável | Ação | Evidência |
|------|-------------|------|-----------|
| 1 | RH | Cadastra no OrangeHRM → CSV exportado | Hash do CSV |
| 2 | midPoint | Reconciliação CSV cria usuário (FPxxx) | Log de importação |
| 3 | Gestor | Atribui role `Entra ID Basic User` | Assignment log |
| 4 | Workflow | Manager + Security Owner aprovam | Approval records |
| 5 | midPoint | OUTBOUND provisioning | `requestId` do Graph |
| 6 | Entra ID | Conta criada com UPN gerado | Portal Azure |

### 22.2. Mover (Atualização de Atributos)

| Fase | Ação | Evidência |
|------|------|-----------|
| 1 | RH atualiza dado no OrangeHRM (ex: department) | |
| 2 | CSV atualizado (exportação automática) | |
| 3 | midPoint reconcilia CSV → atualiza usuário | Log de update |
| 4 | midPoint OUTBOUND → atualiza Entra ID | Log de provisionamento |

### 22.3. Leaver (Desligamento)

| Fase | Ação | Evidência |
|------|------|-----------|
| 1 | RH marca usuário como inativo no OrangeHRM | |
| 2 | CSV reflete status inativo | |
| 3 | midPoint reconcilia → detecta mudança | Log de reconciliação |
| 4 | midPoint desabilita conta (`accountEnabled=false`) | Log de provisionamento |
| 5 | (Opcional) midPoint revoga sessões ativas | Log de revogação |

---

## 23. Resolução de Problemas Comuns

| Erro | Causa | Solução |
|------|-------|---------|
| **Test Connection falha** | Credenciais incorretas | Verificar Tenant ID, Client ID, Secret no Vault |
| **No name in new object** | OUTBOUND mapping ausente | Adicionar `name` → `userPrincipalName` |
| **Correlation falha** | employeeNumber não preenchido | Verificar se CSV tem employeeNumber |
| **Workflow não dispara** | managerRef vazio | Preencher manager do usuário |
| **Throttling (429)** | Muitas requisições | Ajustar `throttlingMaxReplyCount` |

---

## 24. Lições Aprendidas e Compliance

### 24.1. Lições Técnicas (PRJ027 v4.0)

| # | Lição |
|---|-------|
| L01 | **Âncora com employeeNumber** é mais resiliente que UPN isolado |
| L02 | **Source of Truth declarada** evita conflitos de sincronização (drift) |
| L03 | **OUTBOUND primeiro** para provisionamento; INBOUND para reconciliação |
| L04 | **Retry policy** (`throttlingMaxWait`, `throttlingMaxReplyCount`) mitiga throttling da Graph API |
| L05 | **Pós-rollback checklist** evita shadows órfãs |
| L06 | **Workflow dinâmico** (managerRef) é essencial para IGA corporativo |
| L07 | **Roteação de Client Secret** com monitoramento mensal evita falhas por expiração |

### 24.2. Frameworks de Compliance

| Framework | Controle | Implementação |
|-----------|----------|---------------|
| **ISO 27001** | A.5.15 (Menor Privilégio) | Workflow de aprovação dinâmico |
| **ISO 27001** | A.5.16 (Gestão de Acessos) | Certificação trimestral + JML |
| **ISO 27001** | A.8.12 (Gestão de Segredos) | Client Secret no Vault + rotação anual |
| **ISO 27001** | A.9.2.6 (Revogação) | Leaver: desabilita conta + revoga sessões |

---

## 25. Decisões Arquiteturais Registradas (ADR-007)

**Título:** Lifecycle IGA Completa — Direção de Mappings, Âncora e Workflow

**Decisões:**

1. **OUTBOUND primeiro:** Usuários existem no midPoint (CSV), não no Entra ID
2. **Âncora primária:** `employeeNumber` (imutável) em vez de UPN
3. **Retry policy:** `throttlingMaxReplyCount=20`, `throttlingMaxWait=30`
4. **Workflow:** Dinâmico (managerRef) para PRD, fixo (administrator) para LAB
5. **Leaver:** `disable` + `unlink` ao desligar usuário

---

## 26. Anexos: Comandos de Diagnóstico

```bash
# Verificar shadows
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://localhost:8080/midpoint/ws/rest/shadow/search?resource=ENTRA_RESOURCE_OID" \
  -H "Accept: application/json" | jq '.shadows | length'

# Verificar manager de um usuário
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://localhost:8080/midpoint/ws/rest/users/FP001" \
  -H "Accept: application/json" | jq '.managerRef'

# Verificar employeeNumber
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://localhost:8080/midpoint/ws/rest/users/FP001" \
  -H "Accept: application/json" | jq '.employeeNumber'
```

---

## 27. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 06/05/2026 | Paulo Feitosa Lima | Documento inicial |
| 2.0 | 08/05/2026 | Paulo Feitosa Lima | Forense do PRJ012 |
| 3.0 | 08/05/2026 | Paulo Feitosa Lima | Decisão OUTBOUND vs INBOUND |
| **4.0** | **08/05/2026** | **Paulo Feitosa Lima** | **Lifecycle IGA Completa: Source of Truth, employeeNumber como âncora, Retry Policy, Workflow dinâmico, Leaver, Rotação de secret, Checklist pós-rollback** |

---

**Fim do POP-PRJ027-v4.0** ✅

---

*PRJ027 — Lifecycle IGA: midPoint ↔ Microsoft Entra ID Free*  
*Living Lab Fiqueok — Enterprise-Grade*  
*Arquivado em: `FiqueokBrain/PRJ027/20 Execução/POP-PRJ027-v4.0.md`*
