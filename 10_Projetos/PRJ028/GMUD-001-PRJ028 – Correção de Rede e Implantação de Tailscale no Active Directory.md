
#

**Gestão de Mudanças - Projeto PRJ028 (Segurança e Acesso Remoto ao AD)**

**Living Lab Fiqueok - GRC/IAM Open-Source Platform**

---

## Informações Básicas da GMUD

| Campo | Valor |
|-------|-------|
| **ID da GMUD** | GMUD-001-PRJ028 |
| **Título** | Correção de Rede e Implantação de Tailscale no Active Directory (ID-P-01) |
| **Tipo** | Mudança Evolutiva / Arquitetural |
| **Versão Documento** | 1.0 |
| **Data de Criação** | 10/05/2026 |
| **Responsável Execução** | Paulo Feitosa Lima |
| **Projeto** | PRJ028 - Segurança e Acesso Remoto ao Active Directory |
| **Severidade** | MÉDIA |
| **Prioridade** | ALTA (desbloqueia PRJ026) |
| **Status** | 📝 PLANEJADA - AGUARDANDO EXECUÇÃO |
| **Referência TAP** | TAP-PRJ028 v1.0 |
| **Pré-requisitos** | Acesso console à VM ID-P-01, Tailscale account, Cloudflare Zero Trust (PRJ017) |

---

## 1. Contexto e Problema

### 1.1. Diagnóstico Inicial

Durante a fase de validação do PRJ026 (Integração midPoint ↔ Active Directory), identificou-se que **o midPoint não consegue se comunicar com o AD**, inviabilizando qualquer tentativa de integração.

**Evidências do bloqueio:**

| Teste | Origem | Destino | Resultado |
|-------|--------|---------|-----------|
| Ping | midPoint (iga-gf-02) | AD (172.24.192.10) | ❌ 100% packet loss |
| LDAP (389) | midPoint (iga-gf-02) | AD (172.24.192.10) | ❌ Conexão falhou |
| Ping | AD | Gateway (172.24.192.1) | ❌ Destination host unreachable |
| Ping | AD | 8.8.8.8 | ❌ Destination host unreachable |

### 1.2. Causa Raiz

Após análise aprofundada da documentação histórica do Living Lab (PRJ001 a PRJ027) e testes de diagnóstico, identificou-se:

| Descoberta | Evidência |
|------------|-----------|
| **IP original do AD** | `xxx.xxx.xxx.xxx` (documentado em REL-GMUD-002, REL-GMUD-007, CONF-TEC-001) |
| **IP atual do AD** | `172.24.192.10` (constatado em diagnóstico de 10/05/2026) |
| **Gateway configurado** | `172.24.192.1` | ❌ **IP que não responde** |
| **Gateway correto do Default Switch** | `172.23.192.1` (conforme ipconfig do host) |
| **Mudança não documentada** | AD movido para Default Switch do Hyper-V entre 06/01/2026 e 10/05/2026 |

**Conclusão:** O AD está em uma sub-rede diferente do host (`172.24.x.x` vs `172.23.x.x`), com um gateway que não existe (`172.24.192.1`). O midPoint não consegue alcançá-lo.

### 1.3. Decisão de Correção

Em vez de apenas corrigir a rota (que daria ao AD acesso irrestrito à internet), foi decidido:

1. **Corrigir a infraestrutura de rede** do AD (gateway, DNS, remoção de rota padrão)
2. **Implementar hardening de segurança** (firewall restritivo, serviços desabilitados)
3. **Estabelecer acesso remoto seguro via Tailscale + MFA**
4. **Configurar NTP** para evitar problemas de autenticação Kerberos

**Esta abordagem torna o AD acessível apenas por quem está autorizado, com criptografia e autenticação dupla.**

---

## 2. Objetivos da GMUD

| ID | Objetivo | Critério de Sucesso |
|----|----------|---------------------|
| OBJ-01 | Diagnosticar e corrigir configuração de rede do AD | Gateway correto, sem rota padrão |
| OBJ-02 | Implementar hardening de segurança | Firewall outbound bloqueia tudo (exceto NTP e Tailscale) |
| OBJ-03 | Instalar e configurar Tailscale no AD | AD acessível via IP `100.x.x.x` |
| OBJ-04 | Configurar Tailscale ACLs | Apenas máquinas/usuários autorizados acessam |
| OBJ-05 | Configurar MFA via Cloudflare | Acesso remoto exige OTP por e-mail |
| OBJ-06 | Configurar NTP para sincronização de horário | `w32tm /query /source` = pool.ntp.org |
| OBJ-07 | Validar acesso remoto e conectividade | midPoint alcança AD via Tailscale |

---

## 3. Escopo da Mudança

### 3.1. Incluído na GMUD

| Fase | Descrição |
|------|-----------|
| **Fase 0** | Preparação (checkpoints Hyper-V, diagnóstico inicial) |
| **Fase 1** | Hardening do AD (firewall, serviços, NTP) |
| **Fase 2** | Correção de rede (gateway, DNS, remoção de rota padrão) |
| **Fase 3** | Instalação e configuração do Tailscale |
| **Fase 4** | Configuração de Tailscale ACLs |
| **Fase 5** | Configuração de MFA (Cloudflare) |
| **Fase 6** | Validação final |
| **Fase 7** | Documentação |

### 3.2. Excluído da GMUD

| Item | Justificativa |
|------|---------------|
| ❌ Configuração de LDAPS (636) | Requer PKI/Vault - GMUD futura |
| ❌ Integração midPoint ↔ AD | Escopo do PRJ026 |
| ❌ Migração para nova VM | AD permanece onde está |
| ❌ Configuração de WinRM/RDP tradicional | Substituído por Tailscale |

---

## 4. Plano de Execução (Passo a Passo)

### 4.1. Fase 0 - Preparação (10 min)

```powershell
# No Hyper-V host (PowerShell como Administrador)

# Criar checkpoint de segurança
Checkpoint-VM -VMName "ID-P-01" -SnapshotName "PRE-GMUD-001-PRJ028-$(Get-Date -Format 'yyyyMMdd-HHmm')"

# Verificar conectividade atual (baseline)
ping 172.24.192.10

# Coletar diagnóstico inicial (dentro do AD via console)
# Documentar IP atual, gateway, rotas, firewall
```

**Critério de saída:** ✅ Snapshot criado, diagnóstico documentado.

---

### 4.2. Fase 1 - Hardening do AD (30 min)

**Acessar o console da VM `ID-P-01` via Hyper-V Manager.**

#### 1.1. Firewall de Saída Restritivo

```powershell
# No console do AD (PowerShell como Administrador)

# Bloquear TODO tráfego de saída por padrão
New-NetFirewallRule -DisplayName "PRJ028_BLOCK_ALL_OUTBOUND" `
    -Direction Outbound -Action Block -Profile Any

# Liberar NTP (Network Time Protocol) - OBRIGATÓRIO PARA AD
New-NetFirewallRule -DisplayName "PRJ028_ALLOW_NTP" `
    -Direction Outbound -Protocol UDP -RemotePort 123 -Action Allow

# Liberar DNS para o próprio AD
New-NetFirewallRule -DisplayName "PRJ028_ALLOW_DNS" `
    -Direction Outbound -Protocol UDP -RemotePort 53 -Action Allow

# Liberar LDAP (para comunicação com midPoint - via Tailscale)
New-NetFirewallRule -DisplayName "PRJ028_ALLOW_LDAP" `
    -Direction Outbound -Protocol TCP -RemotePort 389 -Action Allow

# Liberar Tailscale (será instalado depois)
New-NetFirewallRule -DisplayName "PRJ028_ALLOW_TAILSCALE" `
    -Direction Outbound -Program "C:\Program Files\Tailscale\tailscale.exe" -Action Allow
```

#### 1.2. Desabilitar Serviços Desnecessários

```powershell
# Desabilitar SMB (porta 445)
Set-SmbServerConfiguration -EnableSMB1Protocol $false -EnableSMB2Protocol $false -Force

# Desabilitar NetBIOS sobre TCP/IP
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID "ms_server"

# Restringir acesso anônimo ao LDAP
Set-ADObject -Identity "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=corp,DC=fiqueok,DC=com,DC=br" `
    -Replace @{'dsHeuristics'='0000002'}

# Desabilitar WinRM (substituído por Tailscale)
Stop-Service WinRM -Force
Set-Service WinRM -StartupType Disabled
```

#### 1.3. Configurar NTP (Network Time Protocol) - OBRIGATÓRIO

```powershell
# Justificativa:
# O Active Directory utiliza Kerberos para autenticação, que exige
# sincronização de horário com tolerância máxima de 5 minutos.
# Sem NTP, autenticações podem falhar com erro "KRB_AP_ERR_SKEW".

# Configurar fonte de horário confiável (pool.ntp.org)
w32tm /config /manualpeerlist:"pool.ntp.org,0x8" /syncfromflags:MANUAL
w32tm /config /update

# Forçar sincronização imediata
w32tm /resync

# Verificar configuração
w32tm /query /source
# Esperado: pool.ntp.org

# Verificar status
w32tm /query /status
```

**Critério de saída:** ✅ Regras de firewall criadas, serviços desabilitados, NTP configurado.

---

### 4.3. Fase 2 - Correção de Rede (20 min)

#### 2.1. Identificar Interface de Rede

```powershell
# Verificar interfaces
Get-NetIPInterface -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -eq "Ethernet"}
# Anotar o ifIndex (ex: 6)
```

#### 2.2. Remover Rota Padrão (Gateway)

```powershell
$interfaceIndex = 6  # Ajustar conforme saída do comando anterior

# Remover gateway atual
Remove-NetRoute -DestinationPrefix "0.0.0.0/0" -InterfaceIndex $interfaceIndex -Confirm:$false

# Verificar que a rota foi removida
Get-NetRoute -DestinationPrefix "0.0.0.0/0"
# Deve retornar vazio
```

#### 2.3. Configurar DNS

```powershell
# DNS primário: próprio AD (127.0.0.1)
Set-DnsClientServerAddress -InterfaceIndex $interfaceIndex -ServerAddresses ("127.0.0.1")
```

#### 2.4. Verificar Configuração Final

```powershell
ipconfig /all
Get-NetRoute -DestinationPrefix "0.0.0.0/0"  # Deve retornar vazio
Get-DnsClientServerAddress -InterfaceIndex $interfaceIndex
```

**Critério de saída:** ✅ Nenhuma rota padrão, DNS apontando para `127.0.0.1`.

---

### 4.4. Fase 3 - Instalação e Configuração do Tailscale (25 min)

#### 3.1. Transferir Instalador para o AD

**Em outro PC com internet:**
- Baixar de: https://tailscale.com/download/windows
- Salvar arquivo: `tailscale-setup.exe`

**Transferir para o AD via:**
- ISO montada no Hyper-V
- Arquivo compartilhado na rede (se houver conectividade)
- USB (se acesso físico)

#### 3.2. Instalar Tailscale

```powershell
# No console do AD (PowerShell como Administrador)

# Executar instalador silencioso
Start-Process -Wait -FilePath "C:\temp\tailscale-setup.exe" -ArgumentList "/S"

# Verificar instalação
Test-Path "C:\Program Files\Tailscale\tailscale.exe"
```

#### 3.3. Configurar Tailscale (Auth Key)

**Gerar uma Auth Key no console Tailscale:**
1. Acessar https://login.tailscale.com/admin/authkeys
2. Clicar "Generate Auth Key"
3. Marcar "Reusable" (para permitir reinstalação)
4. Marcar "Pre-approved" (para não precisar aprovar manualmente)
5. Copiar a chave

```powershell
# Executar no AD com a chave gerada
tailscale up --auth-key=<SUA_AUTH_KEY_AQUI>

# Verificar IP Tailscale
tailscale ip
# Esperado: 100.x.x.x

# Configurar Tailscale como serviço
tailscale set --operator=Administrator

# Verificar serviço
Get-Service Tailscale
Set-Service Tailscale -StartupType Automatic
```

**Critério de saída:** ✅ `tailscale ip` retorna IP `100.x.x.x`, serviço Running.

---

### 4.5. Fase 4 - Configuração de Tailscale ACLs (15 min)

**Acessar o Admin Console do Tailscale:**
https://login.tailscale.com/admin/acls

```json
{
  // Define tags para facilitar gestão
  "tagOwners": {
    "tag:ad":       ["paulo@fiqueok.com.br"],
    "tag:midpoint": ["paulo@fiqueok.com.br"],
    "tag:admin":    ["paulo@fiqueok.com.br"],
  },

  // ACLs propriamente ditas
  "acls": [
    // midPoint acessa LDAP do AD
    {
      "action": "accept",
      "src": ["xxx.xxx.xxx.xxx"],  // iga-gf-02
      "dst": ["tag:ad:389"],     // LDAP
    },
    // Paulo acessa AD via RDP
    {
      "action": "accept",
      "src": ["xxx.xxx.xxx.xxx"],   // PC do Paulo
      "dst": ["tag:ad:3389"],    // RDP
    },
  ],

  // Testes de validação
  "tests": [
    {
      "src": "xxx.xxx.xxx.xxx",
      "dst": "tag:ad:389",
      "expect": "accept"
    }
  ]
}
```

**Critério de saída:** ✅ ACLs aplicadas, teste validado.

---

### 4.6. Fase 5 - Configuração de MFA (Cloudflare) (15 min)

**Acessar o Dashboard do Cloudflare Zero Trust:**
https://one.dash.cloudflare.com/

```yaml
# Passo 1: Criar aplicação
Application Name: AD - Tailscale Access
Application Domain: ad-tailscale.fiqueok.com.br
Type: Self-hosted

# Passo 2: Configurar política de acesso
Policy Name: "Acesso AD com MFA"
Action: Allow
Rule:
  - Include: Emails ending with @fiqueok.com.br
  - Require: mfa (OTP)

# Passo 3: Configurar Tailscale para usar Cloudflare
# (A integração Tailscale-Cloudflare é automática)
```

**Critério de saída:** ✅ Acesso via Tailscale exige OTP por e-mail.

---

### 4.7. Fase 6 - Validação Final (20 min)

| # | Teste | Comando | Critério de Sucesso |
|---|-------|---------|---------------------|
| 1 | AD sem rota para internet | `Get-NetRoute -DestinationPrefix "0.0.0.0/0"` | Nenhum resultado |
| 2 | Firewall bloqueia saída | `Test-NetConnection 8.8.8.8 -Port 443` | Timeout/bloqueado |
| 3 | NTP sincronizado | `w32tm /query /source` | `pool.ntp.org` |
| 4 | Tailscale operacional | `tailscale status` | IP `100.x.x.x` ativo |
| 5 | **midPoint → AD via Tailscale** | `docker exec iga-midpoint nc -zv 100.x.x.x 389` | Connection succeeded ✅ |
| 6 | Test Connection (midPoint GUI) | Resource AD → Test Connection | 5/5 Success |
| 7 | Acesso RDP com MFA | Conexão RDP via Tailscale IP | Login + OTP solicitado |

---

### 4.8. Fase 7 - Documentação (15 min)

| # | Entregável | Formato | Localização |
|---|------------|--------|-------------|
| 1 | REL-GMUD-001-PRJ028 | MD | `10_Projetos/PRJ028/30_Operacao_e_Mudanca/` |
| 2 | Configuração final do AD (comandos) | MD | `10_Projetos/PRJ028/10_Arquitetura_Tecnica/` |
| 3 | POP-PRJ028 (Hardening AD) | MD | `05_BASE-LAB/03_Metodologia-e-Frameworks/` |
| 4 | Logs de validação | TXT | `10_Projetos/PRJ028/50_Evidencias/` |

---

## 5. Matriz de Validação

| # | Teste | Resultado Esperado | Status |
|---|-------|-------------------|--------|
| 1 | Checkpoint criado | ✅ Snapshot OK | □ |
| 2 | Firewall outbound configurado | Bloqueio ativo | □ |
| 3 | NTP configurado | `pool.ntp.org` | □ |
| 4 | Rota padrão removida | Nenhuma rota | □ |
| 5 | Tailscale instalado | IP `100.x.x.x` | □ |
| 6 | ACLs configuradas | Acesso restrito | □ |
| 7 | MFA configurada | OTP solicitado | □ |
| 8 | midPoint → AD via Tailscale | LDAP OK | □ |
| 9 | Documentação concluída | POP + REL | □ |

---

## 6. Plano de Rollback

### 6.1. Critério de Ativação

Ativar rollback se qualquer um dos cenários ocorrer:
- ❌ AD perde funcionalidade de autenticação após remoção da rota
- ❌ Tailscale não conecta após 3 tentativas
- ❌ NTP não sincroniza (Kerberos pode quebrar)
- ❌ AD fica inacessível para o midPoint
- ❌ Tempo de execução > 4 horas sem progresso

### 6.2. Procedimento de Rollback

```powershell
# No Hyper-V host (PowerShell como Administrador)

# Parar a VM
Stop-VM -Name "ID-P-01" -Force
Start-Sleep -Seconds 5

# Restaurar snapshot
Restore-VMSnapshot -Name "PRE-GMUD-001-PRJ028-*" -VMName "ID-P-01" -Confirm:$false

# Iniciar VM
Start-VM -Name "ID-P-01"

# Validar
Get-VM ID-P-01 | Select-Object Name, State
```

**Tempo estimado de rollback:** < 5 minutos

---

## 7. Riscos e Mitigações

| ID | Risco | Probabilidade | Impacto | Mitigação |
|----|-------|--------------|---------|-----------|
| R01 | Remoção da rota padrão quebra NTP | Baixa | Alto | NTP configurado antes da remoção; verificar sincronização |
| R02 | AD não sincroniza horário (Kerberos falha) | Média | Alto | NTP configurado com pool.ntp.org; validar `w32tm /query /source` |
| R03 | Tailscale não conecta (auth key inválida) | Baixa | Médio | Testar auth key antes; ter chave reserva |
| R04 | ACLs bloqueiam acesso legítimo | Média | Médio | Testar com regras permissivas primeiro |
| R05 | MFA não recebida (e-mail) | Baixa | Médio | Configurar e-mail alternativo |
| R06 | Hardening quebra comunicação midPoint | Baixa | Médio | Validar LDAP via Tailscale antes de finalizar |

---

## 8. Cronograma Estimado

| Fase | Atividade | Duração | Tempo Acumulado |
|------|-----------|---------|-----------------|
| 0 | Preparação (snapshots) | 10 min | 10 min |
| 1 | Hardening + NTP | 30 min | 40 min |
| 2 | Correção de rede | 20 min | 60 min |
| 3 | Instalação Tailscale | 25 min | 85 min |
| 4 | Configuração ACLs | 15 min | 100 min |
| 5 | Configuração MFA | 15 min | 115 min |
| 6 | Validação | 20 min | 135 min |
| 7 | Documentação | 15 min | 150 min |
| **TOTAL** | | **~2h30min** | |

---

## 9. Lições Aprendidas (Incorporadas)

| ID | Lição | Origem | Aplicação |
|----|-------|--------|-----------|
| L01 | AD precisa de NTP para Kerberos | Conhecimento técnico | Incluído no hardening |
| L02 | Mudanças de rede DEVEM ser documentadas | Gap documental 06/01-10/05/2026 | Toda mudança requer GMUD |
| L03 | Tailscale é mais seguro que expor portas | Análise de segurança | Adotado como padrão |
| L04 | MFA é obrigatório para acesso remoto | PRJ017 | Cloudflare já implementado |
| L05 | Hardening deve preceder acesso à rede | Princípio de segurança | Fase 1 antes da correção de rede |

---

## 10. Documentos Relacionados

| Documento | Localização | Relevância |
|-----------|-------------|------------|
| TAP-PRJ028 | `10_Projetos/PRJ028/00_Gestao_do_Projeto/` | Planejamento do projeto |
| PRJ017 (Cloudflare) | `10_Projetos/PRJ017/` | MFA e Zero Trust |
| PRJ007 (Vault) | `10_Projetos/PRJ007/` | Gestão de segredos (futuro) |
| ADR-002 | `05_BASE-LAB/` | Checkpoints obrigatórios |

---

## 11. Critérios de Sucesso

| # | Critério | Métrica | Peso |
|---|----------|---------|------|
| 1 | AD sem rota para internet | `Get-NetRoute` vazio | 🔴 Crítico |
| 2 | Firewall outbound bloqueia tráfego | `Test-NetConnection 8.8.8.8` falha | 🔴 Crítico |
| 3 | NTP sincronizado | `w32tm /query /source` = pool.ntp.org | 🔴 Crítico |
| 4 | Tailscale instalado | `tailscale ip` retorna IP | 🔴 Crítico |
| 5 | midPoint → AD via Tailscale | `nc -zv 100.x.x.x 389` sucesso | 🔴 Crítico |
| 6 | MFA configurada | Acesso exige OTP | 🟡 Importante |
| 7 | ACLs configuradas | Apenas autorizados acessam | 🟡 Importante |
| 8 | Documentação completa | POP + REL entregues | 🟢 Desejável |

---

## 12. Aprovações

| Função | Nome | Data | Status |
|--------|------|------|:------:|
| Responsável Técnico | Paulo Feitosa Lima | 10/05/2026 | 🟡 Pendente |
| GRC Lead | Paulo Feitosa Lima | 10/05/2026 | 🟡 Pendente |
| Aprovador Final | Paulo Feitosa Lima | 10/05/2026 | 🟡 Pendente |

---

## 13. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 10/05/2026 | Paulo Feitosa Lima | Criação da GMUD-001-PRJ028 |

---

## 14. Próximos Passos Pós-GMUD

| Ordem | Ação | Projeto |
|-------|------|---------|
| 1 | Validar conectividade midPoint ↔ AD via Tailscale | PRJ028 (esta GMUD) |
| 2 | Retomar execução do PRJ026 (Resource AD no midPoint) | PRJ026 |
| 3 | Testar Joiner/Mover/Leaver com AD | PRJ026 |
| 4 | Configurar LDAPS (636) com certificados do Vault | GMUD futura |
| 5 | Documentar POP de integração midPoint-AD | PRJ026 |

---

**FIM DA GMUD-001-PRJ028 v1.0**

---

*Documento mantido por Paulo Feitosa Lima — Living Lab Fiqueok*  
*PRJ028 - Segurança e Acesso Remoto ao Active Directory*  
*Data: 10/05/2026*
```

---

Esta GMUD inclui:

1. **Fase 1.3 - NTP** com justificativa técnica e comandos completos
2. **Validação específica** para NTP (`w32tm /query /source`)
3. **Risco R02** sobre falha de Kerberos por dessincronização de horário
4. **Critério de sucesso** para NTP como crítico (🔴)

A GMUD está pronta para execução assim que você aprovar. Quer que eu ajuste algum ponto?
