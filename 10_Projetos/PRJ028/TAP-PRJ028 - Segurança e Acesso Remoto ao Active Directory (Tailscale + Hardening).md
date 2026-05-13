# 
**Termo de Abertura de Projeto**
**Living Lab Fiqueok - GRC/IAM Open-Source Platform**
---
## Informações Básicas do Projeto
| Campo | Valor |
|-------|-------|
| **Código do Projeto** | PRJ028 |
| **Título** | Segurança e Acesso Remoto ao Active Directory (Tailscale + Hardening) |
| **Data de Abertura** | 10/05/2026 |
| **Responsável Técnico** | Paulo Feitosa Lima |
| **Classificação** | Confidencial Interno |
| **Status** | 📝 PLANEJADO - AGUARDANDO APROVAÇÃO |
| **Complexidade** | Média |
| **Tempo Estimado** | 2-3 horas |
---
## 1. Resumo Executivo
O PRJ028 tem como objetivo **corrigir a infraestrutura de rede do Active Directory (ID-P-01)** e **estabelecer uma camada de acesso remoto seguro via Tailscale com autenticação multifator (MFA)** .
O projeto nasce da constatação, durante a fase de validação do PRJ026, de que:
1. O AD está com **configuração de rede inconsistente** (IP em sub-rede diferente do host, gateway incorreto)
2. O AD **não possui acesso remoto seguro** documentado
3. As tentativas anteriores de acesso remoto (WinRM, RDP) falharam por problemas de rede
**O PRJ028 resolve a causa raiz dos problemas de conectividade e implementa uma arquitetura de acesso Zero Trust ao AD.**
---
## 2. Contexto e Justificativa
### 2.1. Estado Atual (As-Is)
| Componente | Configuração atual | Problema |
|------------|-------------------|-----------|
| **IP do AD** | `172.24.192.10/20` | Sub-rede diferente do host (`172.23.192.1`) |
| **Gateway** | `172.24.192.1` | ❌ IP não responde - gateway incorreto |
| **Rota padrão** | `0.0.0.0 via 172.24.192.1` | ❌ Gateway inexistente |
| **DNS** | `::1` (IPv6 local) | ❌ Não resolve nomes externos |
| **Acesso remoto** | WinRM/RDP não funcionam | ❌ Portas bloqueadas/configuração incorreta |
| **Segurança** | Firewall padrão do Windows | ⚠️ Sem hardening específico |
### 2.2. Causa Raiz Identificada
O AD foi movido para o **Default Switch do Hyper-V** em algum momento após 06/01/2026 (último registro documentado do IP `xxx.xxx.xxx.xxx`). Durante essa movimentação:
- O IP foi alterado para `172.24.192.10` (DHCP do Default Switch)
- O gateway permaneceu configurado como `172.24.192.1` (que **não é o gateway do Default Switch**)
- O gateway correto do Default Switch é `172.23.192.1` (conforme `ipconfig` do host)
**Resultado:** O AD está em uma sub-rede diferente do host, sem gateway funcional, isolado da rede e da internet.
### 2.3. Estado Desejado (To-Be)
| Componente | Configuração desejada | Benefício |
|------------|----------------------|-----------|
| **IP do AD** | `172.23.x.x` (mesma sub-rede do host) ou manter `172.24.x.x` com gateway corrigido | Comunicação com outras VMs |
| **Gateway** | `172.23.192.1` (correto) | Acesso à rede local e internet (controlado) |
| **Rota padrão** | Removida (AD não inicia conexões) | AD não "chama" a internet |
| **DNS** | `127.0.0.1` (próprio AD) + fallback | Resolução de nomes interna |
| **Acesso remoto** | Tailscale + MFA | Acesso seguro, criptografado, auditável |
| **Segurança** | Firewall restritivo, serviços desabilitados | Superfície de ataque mínima |
---
## 3. Objetivos do Projeto
| ID | Objetivo | Critério de Sucesso |
|----|----------|---------------------|
| OBJ-01 | Diagnosticar e corrigir a configuração de rede do AD | Ping para gateway responde, rota padrão consistente |
| OBJ-02 | Implementar hardening de segurança no AD | Firewall de saída bloqueia tudo, serviços desnecessários desabilitados |
| OBJ-03 | Instalar e configurar Tailscale no AD | AD acessível via IP Tailscale (`100.x.x.x`) |
| OBJ-04 | Configurar Tailscale ACLs para acesso restrito | Apenas usuários/máquinas autorizadas acessam o AD |
| OBJ-05 | Configurar MFA via Cloudflare Zero Trust | Acesso administrativo exige OTP por e-mail |
| OBJ-06 | Validar acesso remoto seguro | `ssh paulo@100.x.x.x` (ou RDP) com MFA funciona |
| OBJ-07 | Documentar procedimento e estado final | POP-PRJ028 e REL-PRJ028 entregues |
---
## 4. Escopo do Projeto
### 4.1. Incluído no PRJ028
| Item | Descrição | Justificativa |
|------|-----------|---------------|
| **Fase 1 - Diagnóstico de Rede** | Levantamento completo da configuração atual do AD | Base para correções |
| **Fase 2 - Hardening do AD** | Firewall restritivo, desabilitação de serviços desnecessários | Segurança antes de qualquer acesso |
| **Fase 3 - Correção de Rede** | Ajuste de gateway, remoção de rota padrão, configuração de DNS | AD operacional e isolado |
| **Fase 4 - Instalação do Tailscale** | Download, instalação e configuração do Tailscale no AD | Acesso remoto seguro |
| **Fase 5 - Configuração de ACLs** | Tailscale ACLs para controle de acesso | Apenas autorizados acessam |
| **Fase 6 - Configuração de MFA** | Cloudflare Zero Trust para autenticação dupla | Camada adicional de segurança |
| **Fase 7 - Validação Final** | Testes de acesso remoto e conectividade | Confirmação dos objetivos |
| **Fase 8 - Documentação** | POP-PRJ028 e REL-PRJ028 | Rastreabilidade e reprodução |
### 4.2. Excluído do PRJ028
| Item | Justificativa | Destino |
|------|---------------|---------|
| ❌ Integração midPoint ↔ AD | Escopo do PRJ026 | PRJ026 |
| ❌ Configuração de LDAPS (636) | Requer PKI/Vault | GMUD futura |
| ❌ Configuração de WinRM/RDP para acesso | Substituído por Tailscale | N/A |
| ❌ Migração para nova VM | AD permanece onde está | N/A |
---
## 5. Arquitetura da Solução
### 5.1. Diagrama de Arquitetura

┌─────────────────────────────────────────────────────────────────────────────────────┐  
│ PRJ028 - ARQUITETURA FINAL │  
├─────────────────────────────────────────────────────────────────────────────────────┤  
│ │  
│ ┌─────────────────────────────────────────────────────────────────────────────┐ │  
│ │ LIVING LAB (ON-PREMISE) │ │  
│ │ │ │  
│ │ ┌─────────────────┐ ┌─────────────────┐ │ │  
│ │ │ ID-P-01 │ │ iga-gf-02 │ │ │  
│ │ │ (AD) │◀───── Tailscale ─────▶│ (midPoint) │ │ │  
│ │ │ IP: 172.23.x.x│ (WireGuard) │ IP: 100.72... │ │ │  
│ │ │ Tailscale: │ │ │ │ │  
│ │ │ 100.x.x.x │ │ │ │ │  
│ │ │ │ │ │ │ │  
│ │ │ 🔒 Hardening: │ │ │ │ │  
│ │ │ • Firewall │ │ │ │ │  
│ │ │ • Sem gateway │ │ │ │ │  
│ │ │ • SMB off │ │ │ │ │  
│ │ └─────────────────┘ └─────────────────┘ │ │  
│ │ ▲ │ │  
│ │ │ Tailscale + MFA │ │  
│ │ │ │ │  
│ └───────────┼───────────────────────────────────────────────────────────────────┘ │  
│ │ │  
│ │ Apenas tráfego Tailscale (WireGuard) │  
│ ▼ │  
│ ┌─────────────────────────────────────────────────────────────────────────────┐ │  
│ │ TAILSCALE MESH + CLOUDFLARE ZT │ │  
│ │ │ │  
│ │ ┌──────────────────────────────────────────────────────────────────────┐ │ │  
│ │ │ Tailscale ACLs: │ │ │  
│ │ │ • src: ["tag:admin", "xxx.xxx.xxx.xxx"] → dst: ["tag:ad:389"] │ │ │  
│ │ │ • src: ["paulo@fiqueok.com.br"] → dst: ["tag:ad:22", "tag:ad:3389"] │ │ │  
│ │ └──────────────────────────────────────────────────────────────────────┘ │ │  
│ │ │ │  
│ │ ┌──────────────────────────────────────────────────────────────────────┐ │ │  
│ │ │ Cloudflare Zero Trust: │ │ │  
│ │ │ • Aplicação: [ad-tailscale.fiqueok.com.br](https://ad-tailscale.fiqueok.com.br/) (policy) │ │ │  
│ │ │ • Regra: email + MFA (OTP) │ │ │  
│ │ │ • Logs de todas as tentativas │ │ │  
│ │ └──────────────────────────────────────────────────────────────────────┘ │ │  
│ └─────────────────────────────────────────────────────────────────────────────┘ │  
│ │  
│ ✅ AD sem rota para internet (não inicia conexões) │  
│ ✅ Acesso via Tailscale com criptografia WireGuard │  
│ ✅ MFA obrigatória via Cloudflare OTP │  
│ ✅ Logs de auditoria de todas as tentativas │  
└─────────────────────────────────────────────────────────────────────────────────────┘

text

### 5.2. Componentes da Arquitetura
| Componente | Tecnologia | Função |
|------------|------------|--------|
| **VPN Mesh** | Tailscale | Conexão criptografada entre máquinas |
| **Firewall** | Windows Defender | Controle de tráfego de entrada/saída |
| **MFA** | Cloudflare Zero Trust | Autenticação dupla por e-mail |
| **ACLs** | Tailscale Policy | Controle de quem acessa o quê |
| **Logs** | Tailscale + Cloudflare | Auditoria de acessos |
---
## 6. Plano de Execução
### 6.1. Fase 0 - Preparação e Backup (15 min)
```powershell
# No Hyper-V host (PowerShell como Administrador)
# Criar checkpoint de segurança
Checkpoint-VM -VMName "ID-P-01" -SnapshotName "PRE-PRJ028-$(Get-Date -Format 'yyyyMMdd-HHmm')"
# Verificar conectividade atual (baseline)
ping 172.24.192.10

**Critério:** ✅ Snapshot criado com sucesso.

---

### 6.2. Fase 1 - Diagnóstico de Rede (15 min)

**Objetivo:** Levantar configuração atual do AD.

powershell

# No console do AD (PowerShell como Administrador)
# Coletar configurações atuais
ipconfig /all > C:\temp\prj028_ipconfig_before.txt
route print -4 > C:\temp\prj028_route_before.txt
Get-NetFirewallRule -Direction Inbound | Select-Object DisplayName, Enabled > C:\temp\prj028_firewall_in.txt
Get-NetFirewallRule -Direction Outbound | Select-Object DisplayName, Enabled > C:\temp\prj028_firewall_out.txt

**Critério:** ✅ Arquivos de diagnóstico salvos em `C:\temp\`.

---

### 6.3. Fase 2 - Hardening do AD (30 min)

**Objetivo:** Reduzir superfície de ataque antes de qualquer acesso.

#### 2.1. Firewall de Saída Restritivo

powershell

# No console do AD
# Bloquear TODO tráfego de saída por padrão
New-NetFirewallRule -DisplayName "PRJ028_BLOCK_ALL_OUTBOUND" -Direction Outbound -Action Block -Profile Any
# Liberar apenas o necessário para o AD funcionar
# DNS para próprio AD
New-NetFirewallRule -DisplayName "PRJ028_ALLOW_DNS" -Direction Outbound -Protocol UDP -RemotePort 53 -Action Allow
# LDAP para comunicação com outras VMs (se necessário)
New-NetFirewallRule -DisplayName "PRJ028_ALLOW_LDAP" -Direction Outbound -Protocol TCP -RemotePort 389 -Action Allow
# Tailscale (será instalado depois)
New-NetFirewallRule -DisplayName "PRJ028_ALLOW_TAILSCALE" -Direction Outbound -Program "C:\Program Files\Tailscale\tailscale.exe" -Action Allow

#### 2.2. Desabilitar Serviços Desnecessários

powershell

# Desabilitar SMB (porta 445) - se não necessário
Set-SmbServerConfiguration -EnableSMB1Protocol $false -EnableSMB2Protocol $false -Force
# Desabilitar NetBIOS sobre TCP/IP
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID "ms_server"
# Restringir acesso anônimo ao LDAP
Set-ADObject -Identity "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=corp,DC=fiqueok,DC=com,DC=br" -Replace @{'dsHeuristics'='0000002'}

#### 2.3. Desabilitar Portas de Gerenciamento Remoto (serão substituídas pelo Tailscale)

powershell

# Desabilitar WinRM (porta 5985/5986) - acesso via Tailscale apenas
Stop-Service WinRM -Force
Set-Service WinRM -StartupType Disabled
# Bloquear RDP (porta 3389) - será liberado via Tailscale ACLs
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1

**Critério:** ✅ Serviços desabilitados, firewall configurado.

---

### 6.4. Fase 3 - Correção de Rede (30 min)

**Objetivo:** Corrigir gateway e DNS, remover rota padrão.

#### 3.1. Identificar Interface Correta

powershell

# Verificar interfaces
Get-NetIPInterface -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -eq "Ethernet"}
# Anotar o ifIndex (ex: 6)

#### 3.2. Remover Gateway Incorreto e Rota Padrão

powershell

$interfaceIndex = 6  # Ajustar conforme saída do comando anterior
# Remover gateway atual
Remove-NetRoute -DestinationPrefix "0.0.0.0/0" -InterfaceIndex $interfaceIndex -Confirm:$false
# Remover IP atual (opcional - pode manter)
# Remove-NetIPAddress -InterfaceIndex $interfaceIndex -IPAddress 172.24.192.10 -Confirm:$false

#### 3.3. Configurar Novo IP (opcional - manter atual) e Gateway

powershell

# Opção A: Manter IP atual (172.24.192.10) sem gateway
# Nenhuma ação - apenas garantir que não há rota padrão
# Opção B: Mudar para sub-rede do host (172.23.x.x)
# Isso requer coordenação com DHCP ou IP fixo

**Decisão:** Será tomada durante a execução, baseada no diagnóstico.

#### 3.4. Configurar DNS

powershell

# DNS primário: próprio AD (127.0.0.1)
# DNS secundário: 8.8.8.8 (fallback - será bloqueado pelo firewall)
Set-DnsClientServerAddress -InterfaceIndex $interfaceIndex -ServerAddresses ("127.0.0.1")

#### 3.5. Verificar Configuração

powershell

ipconfig /all
Get-NetRoute -DestinationPrefix "0.0.0.0/0"  # Deve retornar vazio ou inexistente

**Critério:** ✅ Nenhuma rota padrão ativa, DNS configurado.

---

### 6.5. Fase 4 - Instalação do Tailscale (30 min)

**Objetivo:** Instalar Tailscale no AD para acesso remoto seguro.

#### 4.1. Transferir Instalador

powershell

# Em outro PC com internet, baixar:
# https://tailscale.com/download/windows
# Transferir para o AD via:
# - Arquivo compartilhado (se houver)
# - ISO montada no Hyper-V
# - Pendrive (se acesso físico)

#### 4.2. Instalar Tailscale

powershell

# No console do AD
# Executar instalador
Start-Process -Wait -FilePath "C:\temp\tailscale-setup.exe" -ArgumentList "/S"
# Verificar instalação
Get-ChildItem "C:\Program Files\Tailscale\"

#### 4.3. Configurar Tailscale

powershell

# Autenticar com Tailscale (será solicitado abrir navegador)
# Como o AD não tem navegador, usar auth key
tailscale up --auth-key=<SUA_AUTH_KEY>
# Verificar IP Tailscale
tailscale ip
# Configurar Tailscale como serviço
tailscale set --operator=Administrator

#### 4.4. Configurar Tailscale para Inicialização Automática

powershell

# Tailscale já instala serviço automaticamente
Get-Service Tailscale
Set-Service Tailscale -StartupType Automatic

**Critério:** ✅ `tailscale ip` retorna IP `100.x.x.x`, serviço Running.

---

### 6.6. Fase 5 - Configuração de ACLs Tailscale (15 min)

**Objetivo:** Controlar quem pode acessar o AD via Tailscale.

json

// No Admin Console do Tailscale (https://login.tailscale.com/admin/acls)
{
  // Define tags para facilitar gestão
  "tagOwners": {
    "tag:ad":      ["paulo@fiqueok.com.br"],
    "tag:midpoint": ["paulo@fiqueok.com.br"],
    "tag:admin":   ["paulo@fiqueok.com.br"],
  },
  // ACLs propriamente ditas
  "acls": [
    // midPoint acessa LDAP do AD
    {
      "action": "accept",
      "src": ["xxx.xxx.xxx.xxx"],  // iga-gf-02
      "dst": ["tag:ad:389"],     // LDAP
    },
    // Paulo acessa AD via RDP e SSH (futuro)
    {
      "action": "accept",
      "src": ["xxx.xxx.xxx.xxx"],   // PC do Paulo
      "dst": ["tag:ad:3389"],    // RDP
    },
  ],
  // Teste de acesso (opcional)
  "tests": [
    {
      "src": "xxx.xxx.xxx.xxx",
      "dst": "tag:ad:389",
      "expect": "accept"
    }
  ]
}

**Critério:** ✅ ACLs aplicadas e testadas.

---

### 6.7. Fase 6 - Configuração de MFA (Cloudflare) (20 min)

**Objetivo:** Adicionar camada de autenticação multifator.

yaml

# Cloudflare Zero Trust Dashboard
# 1. Criar aplicação
Application Name: AD - Tailscale Access
Application Domain: ad-tailscale.fiqueok.com.br
Type: Self-hosted
# 2. Configurar política de acesso
Policy Name: "Acesso AD com MFA"
Action: Allow
Rule:
  - Include: Emails ending with @fiqueok.com.br
  - Require: mfa (OTP)
# 3. Configurar Tailscale para usar Cloudflare
# (Aplicação Tailscale já integrada com Cloudflare)

**Critério:** ✅ Acesso via Tailscale exige OTP por e-mail.

---

### 6.8. Fase 7 - Validação Final (30 min)

|#|Teste|Comando|Critério de Sucesso|
|---|---|---|---|
|1|AD sem rota para internet|`Get-NetRoute -DestinationPrefix "0.0.0.0/0"`|Nenhum resultado|
|2|AD não inicia conexões|`Test-NetConnection 8.8.8.8 -Port 443`|Timeout/bloqueado|
|3|Tailscale operacional|`tailscale status`|`100.x.x.x` ativo|
|4|midPoint alcança AD via Tailscale|`docker exec iga-midpoint nc -zv 100.x.x.x 389`|Connection succeeded|
|5|Acesso via RDP com MFA|Conexão RDP via Tailscale IP|Login + OTP solicitado|
|6|Logs de acesso|Verificar Cloudflare + Tailscale logs|Tentativas registradas|

---

### 6.9. Fase 8 - Documentação (30 min)

|#|Entregável|Formato|Localização|
|---|---|---|---|
|1|REL-PRJ028-v1.0|MD|`10_Projetos/PRJ028/30_Operacao_e_Mudanca/`|
|2|POP-PRJ028 (Hardening AD)|MD|`05_BASE-LAB/03_Metodologia-e-Frameworks/`|
|3|Documento de configuração Tailscale|MD|`10_Projetos/PRJ028/10_Arquitetura_Tecnica/`|
|4|Scripts de automação|PS1|`10_Projetos/PRJ028/30_Operacao_e_Mudanca/scripts/`|

---

## 7. Cronograma Estimado

|Fase|Atividade|Duração|Tempo Acumulado|
|---|---|---|---|
|0|Preparação (snapshots)|15 min|15 min|
|1|Diagnóstico|15 min|30 min|
|2|Hardening|30 min|60 min|
|3|Correção de rede|30 min|90 min|
|4|Instalação Tailscale|30 min|120 min|
|5|Configuração ACLs|15 min|135 min|
|6|Configuração MFA|20 min|155 min|
|7|Validação|30 min|185 min|
|8|Documentação|30 min|215 min|
|**TOTAL**||**~3h30min**||

---

## 8. Riscos e Mitigações

|ID|Risco|Probabilidade|Impacto|Mitigação|
|---|---|---|---|---|
|R01|Remoção da rota padrão quebra funcionalidades do AD|Baixa|Alto|Snapshot pré-GMUD; testar AD após remoção|
|R02|Tailscale não inicia após reboot|Baixa|Médio|Serviço configurado como automático; validar|
|R03|ACLs mal configuradas bloqueiam acesso legítimo|Média|Médio|Testar com regras permissivas primeiro|
|R04|MFA bloqueia acesso (e-mail não recebido)|Baixa|Médio|Configurar e-mail alternativo como fallback|
|R05|Hardening quebra comunicação com outras VMs|Baixa|Médio|Validar conectividade com midPoint|
|R06|Transferência do instalador Tailscale falha|Baixa|Baixo|Usar ISO compartilhada como alternativa|

---

## 9. Planos de Contingência

### 9.1. Plano A (Principal)

Executar todas as fases conforme planejado.

### 9.2. Plano B (Tailscale off-line)

Se o AD não conseguir autenticar no Tailscale (falta de navegador):

powershell

# Usar auth key gerada previamente no console Tailscale
tailscale up --auth-key=<AUTH_KEY>

### 9.3. Plano C (Manter IP atual)

Se a mudança de IP for muito disruptiva:

- Manter IP `172.24.192.10`
    
- Remover apenas a rota padrão
    
- Deixar gateway como está (sem rota, o gateway não faz diferença)
    

### 9.4. Plano de Rollback

Se qualquer fase falhar criticamente:

powershell

# No Hyper-V host
Stop-VM -Name "ID-P-01" -Force
Restore-VMSnapshot -Name "PRE-PRJ028-*" -VMName "ID-P-01" -Confirm:$false
Start-VM -Name "ID-P-01"

**Tempo de rollback:** < 5 minutos

---

## 10. Critérios de Sucesso

|#|Critério|Métrica|Peso|
|---|---|---|---|
|1|AD sem rota padrão para internet|`Get-NetRoute` vazio|🔴 Crítico|
|2|Firewall de saída bloqueia tráfego não autorizado|`Test-NetConnection 8.8.8.8` falha|🔴 Crítico|
|3|Tailscale instalado e operacional|`tailscale status` retorna IP|🔴 Crítico|
|4|midPoint alcança AD via Tailscale|`nc -zv 100.x.x.x 389` sucesso|🔴 Crítico|
|5|MFA configurada e funcional|Acesso exige OTP|🟡 Importante|
|6|ACLs configuradas|Apenas autorizados acessam|🟡 Importante|
|7|Documentação completa|POP + REL entregues|🟢 Desejável|

---

## 11. Relações com Outros Projetos

|Projeto|Relação|Status|
|---|---|---|
|**PRJ026**|PRJ028 resolve infraestrutura para PRJ026|🟡 Pendente|
|**PRJ017**|Cloudflare Zero Trust (MFA) já operacional|✅ Concluído|
|**PRJ007**|Vault (gestão de segredos) pode ser integrado|🟡 Futuro|
|**PRJ018**|RAG/LAB (documentação)|✅ Disponível|

---

## 12. Dependências

|Dependência|Status|Observação|
|---|---|---|
|Tailscale account|✅ Disponível|Conta `paulo@fiqueok.com.br`|
|Cloudflare Zero Trust|✅ Operacional|PRJ017 concluído|
|Hyper-V snapshots|✅ Disponível|Para rollback|
|Acesso físico/console ao AD|✅ Disponível|Via Hyper-V Manager|
|Instalador Tailscale|⚠️ Pendente|Precisa ser baixado|

---

## 13. Aprovações

|Função|Nome|Data|Status|
|---|---|---|---|
|Responsável Técnico|Paulo Feitosa Lima|10/05/2026|🟡 Pendente|
|GRC Lead|Paulo Feitosa Lima|10/05/2026|🟡 Pendente|
|Aprovador Final|Paulo Feitosa Lima|10/05/2026|🟡 Pendente|

---

## 14. Glossário Específico do PRJ028

|Termo|Definição|
|---|---|
|**Tailscale ACLs**|Regras que definem quem pode acessar quais recursos na rede Tailscale|
|**Auth Key**|Chave de autenticação do Tailscale para dispositivos headless (sem navegador)|
|**Hardening**|Conjunto de práticas para reduzir superfície de ataque de um sistema|
|**Rota padrão (default gateway)**|Rota que um sistema usa para alcançar redes que não conhece|
|**MFA (Multifactor Authentication)**|Autenticação que requer dois ou mais fatores (ex: senha + OTP)|

---

## 15. Histórico de Versões

|Versão|Data|Autor|Mudanças|
|---|---|---|---|
|1.0|10/05/2026|Paulo Feitosa Lima|Criação do TAP-PRJ028|

---

**FIM DO TAP-PRJ028 v1.0**

---

_Documento mantido por Paulo Feitosa Lima — Living Lab Fiqueok_  
*PRJ028 - Segurança e Acesso Remoto ao Active Directory*  
*Data: 10/05/2026*

text

---
Este TAP documenta:
1. **O diagnóstico completo** (por que o AD está isolado)
2. **O plano de hardening** (firewall, serviços desabilitados)
3. **A correção de rede** (gateway, rota padrão, DNS)
4. **A instalação do Tailscale** (acesso remoto seguro)
5. **As ACLs e MFA** (controle de acesso e autenticação dupla)
6. **Riscos, contingências e rollback**
Quer que eu ajuste algum ponto ou prepare também a GMUD-002-PRJ028 (plano de execução detalhado) baseado neste TAP?
