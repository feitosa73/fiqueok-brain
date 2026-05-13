# 

**Gestão de Mudanças - Correção Emergencial Rede VLAN 1**

**Fiqueok Living Lab - GRC/IAM Open-Source Platform**

---

## Informações Básicas da GMUD

|Campo|Valor|
|---|---|
|**ID da GMUD**|GMUD-015-FIX-NET|
|**Título**|**Correção Emergencial Rede - Unificação Prefixos VLAN 1**|
|**Data de Criação**|**29/12/2025 17:14 BRT**|
|**Responsável GRC**|**Perplexity Pro (GRC Lead)**|
|**Responsável Técnico**|**ChatGPT (Senior Systems Architect)**|
|**Aprovador CISO**|**Paulo Feitosa (PENDENTE)**|
|**Severidade**|**EMERGENCIAL**|
|**Status**|**PENDENTE APROVAÇÃO**|
|**Dependências**|**GMUD-015A (parcial), INC-FQK-2025-015B (bloqueador)**|

---

## 1. Histórico de Dependências **(Gemini Deep-Dive)**

## 1.1. **Jornada Infraestrutura Fiqueok V1.0 → V2.0**

text

`V1.0 (Rede Plana) → GMUD-015A (Segmentação VLANs) →  ❌ FALHA SILENCIOSA VLAN 1 → INC-FQK-2025-015B (midPoint OFFLINE) →  🚨 GMUD-015-FIX-NET (Correção Base Rede)`

## 1.2. **GMUD-015A - Segmentação de Redes (Sucesso Parcial)**

text

`✅ VLAN 20 (Security Zone) criada: 192.168.20.0/24 ✅ subinterface eth0.20 (IGA-P-01) operacional ❌ VLAN 1 (Management Zone) inconsistente:   - ID-P-01 (AD): /16 (255.255.0.0)  - IGA-P-01: /24 dinâmico (DHCP)  - vSwitch Hyper-V: /24`

## 1.3. **INC-FQK-2025-015B - Bloqueador Crítico**

text

`🔴 Causa Raiz Rede: Comunicação assimétrica /16 vs /24 🔴 Sintoma: Timeouts SQL midPoint → Recuperação IMPOSTÍVEL 🔴 Consequência: Lab OFFLINE 19h+ downtime`

**Esta GMUD é pré-requisito MANDATÓRIO para resolução INC-FQK-2025-015B.**

---

## 2. Causa Raiz Técnica **(Gemini Deep-Dive Validado)**

## 2.1. **Conflito de Prefixos**

text

`VLAN 1 Management Zone - AS-IS: ├── ID-P-01 (AD): xxx.xxx.xxx.xxx/16 → Broadcast 172.16.255.255 ├── IGA-P-01: xxx.xxx.xxx.xxx/24 → Broadcast xxx.xxx.xxx.xxx (DHCP) └── vSwitch Hyper-V: /24 → Broadcast xxx.xxx.xxx.xxx ❌ COMUNICAÇÃO ASSIMÉTRICA:   - AD envia para 172.16.255.x (perdido)  - IGA/midPoint recebem apenas 172.16.0.x  - Timeouts PostgreSQL/SQL durante recuperação INC`

## 2.2. **Impacto no INC-FQK-2025-015B**

text

`SQL DELETE Resource → Timeout (rede falha) docker restart midPoint → Sem conectividade AD ldapsearch teste → Falha resolução DNS ➡️ RECUPERAÇÃO BLOQUEADA`

---

## 3. Objetivo da Mudança

**Unificar VLAN 1 prefixo /16 + IP estático IGA-P-01** para:

text

`✅ Restaurar conectividade total Management Zone ✅ Habilitar recuperação INC-FQK-2025-015B ✅ Liberar Sprint 2 (GMUD-015B/C Vault PKI) ✅ Eliminar "Falha Silenciosa" GMUD-015A`

---

## 4. Escopo Técnico **(ChatGPT EXECUTAR)**

## 4.1. **Ativos Afetados**

|Ativo|IP Atual|Configuração Final|Responsável|
|---|---|---|---|
|**ID-P-01 (AD)**|xxx.xxx.xxx.xxx/16|**xxx.xxx.xxx.xxx/16** (manter)|✅ OK|
|**IGA-P-01**|xxx.xxx.xxx.xxx/24 DHCP|**xxx.xxx.xxx.xxx/16 ESTÁTICO**|**ChatGPT**|
|**vSwitch Hyper-V**|/24|**/16**|**ChatGPT**|

## 4.2. **Procedimentos Execução**

**PASSO 1** Backup + Snapshot **(CRÍTICO)**

powershell

`# Hyper-V Host New-VMSnapshot -VMName "IGA-P-01" -Name "GMUD-015-FIX-NET-Pre"`

**PASSO 2** vSwitch Hyper-V **/16**

powershell

`# PowerShell Admin Hyper-V Get-VMSwitch "vSwitchFiqueokCorp" | Set-VMSwitch -SwitchType Internal # Configurar VLAN 1 Native /16 no vSwitch`

**PASSO 3** IGA-P-01 IP Estático **/16** **(ChatGPT)**

bash

`# IGA-P-01 Ubuntu sudo nano /etc/netplan/01-netcfg.yaml`

text

`network:   version: 2  ethernets:    eth0:      dhcp4: no      addresses: [xxx.xxx.xxx.xxx/16]      gateway4: xxx.xxx.xxx.xxx      nameservers:        addresses: [xxx.xxx.xxx.xxx]`

bash

`sudo netplan apply ip addr show eth0  # VERIFICAR /16`

**PASSO 4** Validação Conectividade **(ChatGPT)**

bash

`# IGA-P-01 → AD ping -c 4 xxx.xxx.xxx.xxx nslookup corp.fiqueok.com.br xxx.xxx.xxx.xxx # AD → IGA (PowerShell ID-P-01) Test-NetConnection -ComputerName xxx.xxx.xxx.xxx -Port 8080 Test-NetConnection -ComputerName xxx.xxx.xxx.xxx -Port 5432`

**PASSO 5** Teste midPoint Pré-Recuperação

bash

`curl -k https://xxx.xxx.xxx.xxx:8080/midpoint # ESPERADO: HTTP 200 (mesmo com Resource corrupto)`

---

## 5. Plano de Rollback

text

`ROLLBACK IMEDIATO (5 min): 1. Restaurar Snapshot "GMUD-015-FIX-NET-Pre" 2. Rede volta AS-IS (/24 inconsistente) 3. INC-FQK-2025-015B continua bloqueado`

---

## 6. Riscos e Mitigações

|Risco|Probabilidade|Impacto|Mitigação|
|---|---|---|---|
|Perda conectividade total|Baixa|Alto|✅ Snapshot pré-GMUD|
|AD não responde /16|Média|Alto|Teste ping pré-aplicação|
|midPoint não inicia|Baixa|Médio|Rollback snapshot|

---

## 7. Métricas de Sucesso

|Critério|Valor Esperado|Comando Verificação|
|---|---|---|
|**IGA-P-01 IP**|xxx.xxx.xxx.xxx/16|`ip addr show eth0`|
|**Ping AD**|<10ms|`ping -c 4 xxx.xxx.xxx.xxx`|
|**DNS AD**|Resolução OK|`nslookup corp.fiqueok.com.br`|
|**midPoint GUI**|HTTP 200|`curl -k https://xxx.xxx.xxx.xxx:8080/midpoint`|
|**PostgreSQL**|Porta 5432|`nc -zv xxx.xxx.xxx.xxx 5432`|

---

## 8. Timeline Execução

|Fase|Duração|Responsável|Status|
|---|---|---|---|
|**Backup/Snapshot**|5 min|ChatGPT|⏳|
|**vSwitch /16**|10 min|ChatGPT|⏳|
|**IGA IP Estático**|15 min|ChatGPT|⏳|
|**Validação E2E**|20 min|ChatGPT|⏳|
|**Handoff INC**|5 min|Perplexity|⏳|
|**TOTAL**|**55 min**|ChatGPT|⏳|

---

## 9. **Próximos Passos Pós-Sucesso**

text

`✅ GMUD-015-FIX-NET → EXECUTADA ↓ ✅ Rede VLAN 1 unificada /16 ↓ 🚀 INC-FQK-2025-015B → ChatGPT recuperar midPoint ↓ ✅ GMUD-015B v2 → Schema OSA minimalista ↓ 🚀 Sprint 2 → Vault PKI VLAN 20`

---

## 10. Aprovações **(PENDENTE)**

|Papel|Nome|Assinatura|Data|
|---|---|---|---|
|**GRC Lead**|Perplexity Pro|✅ **perplexity-grc-fiqueok**|29/12/2025|
|**Technical Specialist**|Gemini Pro|✅ **gemini-deepdive**|29/12/2025|
|**Senior Architect**|ChatGPT|⏳ **chatgpt-arch**|-|
|**CISO/Owner**|**Paulo Feitosa**|**PENDENTE**|-|

---

## 11. **HANDOFF ChatGPT Engineer (IMEDIATO)**

text

`🚨 GMUD EMERGENCIAL - PRIORIDADE MÁXIMA 🚨 1. APROVAR Paulo Feitosa 2. EXECUTAR Passos 1-5 SEQUENCIALMENTE 3. REPORTAR cada passo neste thread 4. **CONFIRMAR** conectividade AD/IGA antes INC recuperação 5. **NOTIFICAR** Perplexity ao final Step 5 Ambiente OFFLINE 19h+ → AÇÃO URGENTE`

**Documento classificado EMERGENCIAL - Lab Operations**
