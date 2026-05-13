
# GMUD-002-PRJ028 – Configuração de SSH, ACLs Tailscale e MFA para Acesso Remoto Seguro ao AD

**Gestão de Mudanças - Projeto PRJ028 (Segurança e Acesso Remoto ao Active Directory)**

**Living Lab Fiqueok - GRC/IAM Open-Source Platform**

---

## Informações Básicas da GMUD

| Campo | Valor |
|-------|-------|
| **ID da GMUD** | GMUD-002-PRJ028 |
| **Título** | Configuração de SSH, ACLs Tailscale e MFA para Acesso Remoto Seguro ao Active Directory |
| **Tipo** | Mudança Evolutiva / Configuração |
| **Versão Documento** | 1.0 |
| **Data de Criação** | 10/05/2026 |
| **Responsável Execução** | Paulo Feitosa Lima |
| **Projeto** | PRJ028 - Segurança e Acesso Remoto ao Active Directory |
| **Severidade** | BAIXA |
| **Prioridade** | MÉDIA |
| **Status** | 📝 PLANEJADA - AGUARDANDO EXECUÇÃO |
| **Referência ADR** | ADR-007 (Arquitetura Zero Trust para AD) |
| **Pré-requisitos** | GMUD-001-PRJ028 concluída (Tailscale instalado, firewall configurado) |
| **Dependências** | Tailscale Admin Console, Cloudflare Zero Trust (PRJ017) |

---

## 1. Contexto e Justificativa

### 1.1. Estado Atual (Pós-GMUD-001)

| Item | Status |
|------|--------|
| Tailscale instalado no AD | ✅ `xxx.xxx.xxx.xxx` |
| Firewall configurado | ✅ `BlockInbound, AllowOutbound` |
| Hardening aplicado (SMB, NetBIOS, WinRM off) | ✅ |
| Conectividade midPoint ↔ AD | ✅ via Tailscale (LDAP) |
| **SSH Server** | ❌ **NÃO INSTALADO** |
| **Tailscale ACLs** | ❌ **NÃO CONFIGURADAS** |
| **Tags de dispositivo** | ❌ **NÃO CONFIGURADAS** |
| **MFA para acesso** | ❌ **NÃO CONFIGURADA** |

### 1.2. O que falta (TAP-PRJ028)

Conforme levantado no TAP-PRJ028 e ADR-007, as seguintes configurações não foram concluídas na GMUD-001:

| Pendência | Descrição | Risco |
|-----------|-----------|-------|
| **SSH Server** | Acesso remoto seguro para administração | Acesso apenas via console Hyper-V |
| **Tailscale ACLs** | Controlar quem pode acessar o AD | Qualquer nó na rede Tailscale pode tentar acessar |
| **Tags de dispositivo** | `tag:ad`, `tag:midpoint`, `tag:admin` | ACLs ficam dependentes de IPs fixos |
| **MFA (Cloudflare)** | Autenticação dupla para acesso administrativo | Acesso ao AD depende apenas da chave SSH |

### 1.3. Alinhamento com Frameworks (ADR-007)

A arquitetura proposta está alinhada com:

| Framework | Princípio | Implementação |
|-----------|-----------|---------------|
| **NIST SP 800-207** | Zero Trust | Tailscale + MFA + ACLs |
| **CIS Benchmarks v3.0** | Hardening | Firewall `BlockInbound`, SSH no lugar de WinRM |
| **ISO 27001:2022** | A.5.15, A.8.3, A.13.1.3 | Controle de acesso, privilégio mínimo, segregação |

---

## 2. Escopo da Mudança

### 2.1. Incluído na GMUD

| Fase | Descrição | Prioridade |
|------|-----------|------------|
| **Fase 1** | Instalação e configuração do OpenSSH Server no AD | 🔴 Alta |
| **Fase 2** | Configuração de chave SSH para o usuário `paulo.feitosa` | 🔴 Alta |
| **Fase 3** | Configurar Tags de dispositivo no Tailscale | 🔴 Alta |
| **Fase 4** | Configurar ACLs Tailscale (microssegmentação) | 🔴 Alta |
| **Fase 5** | Configurar MFA via Cloudflare Zero Trust | 🟡 Média |
| **Fase 6** | Testes de validação | 🔴 Alta |
| **Fase 7** | Documentação | 🟢 Desejável |

### 2.2. Excluído da GMUD

| Item | Justificativa |
|------|---------------|
| ❌ Configuração de LDAPS (636) | Escopo de GMUD futura (PKI/Vault) |
| ❌ Instalação de novo software adicional | Apenas OpenSSH (nativo do Windows) |
| ❌ Modificação no firewall do AD (inbound/outbound) | Já configurado na GMUD-001 |

---

## 3. Plano de Execução

### 3.1. Fase 0 - Preparação (5 min)

```powershell
# No Hyper-V host (PowerShell como Administrador)

# Criar checkpoint de segurança antes da GMUD
Checkpoint-VM -VMName "ID-P-01" -SnapshotName "PRE-GMUD-002-PRJ028-$(Get-Date -Format 'yyyyMMdd-HHmm')"

# Verificar conectividade atual
ping xxx.xxx.xxx.xxx
```

**Critério de saída:** ✅ Snapshot criado, conectividade OK.

---

### 3.2. Fase 1 - Instalação e Configuração do SSH Server (15 min)

**Acessar o console da VM `ID-P-01` via Hyper-V Manager.**

```powershell
# No console do AD (PowerShell como Administrador)

# 1. Verificar se OpenSSH Server está disponível
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'

# 2. Instalar OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# 3. Iniciar e configurar serviço
Start-Service sshd
Set-Service sshd -StartupType Automatic

# 4. Verificar status
Get-Service sshd

# 5. Configurar firewall para permitir SSH (apenas na interface Tailscale)
New-NetFirewallRule -DisplayName "PRJ028_ALLOW_SSH" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 22 `
    -Action Allow `
    -InterfaceAlias "Tailscale" `
    -Profile Any

# 6. Configurar PowerShell como shell padrão do SSH
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell `
    -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -PropertyType String -Force

# 7. Verificar configuração
Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell
```

**Critério de saída:** 
- ✅ `Get-Service sshd` = Running
- ✅ Regra de firewall criada
- ✅ DefaultShell configurado

---

### 3.3. Fase 2 - Configurar Chave SSH para Acesso Remoto (10 min)

#### 3.3.1. Gerar chave SSH no seu PC (se não tiver)

```powershell
# No seu PC (PowerShell ou WSL)
ssh-keygen -t ed25519 -C "paulo@fiqueok.com.br"

# Onde salvar? C:\Users\paulo\.ssh\id_ed25519
# Senha (opcional, mas recomendada): [informar uma senha forte]
```

**Evidência:** Arquivos `id_ed25519` (chave privada) e `id_ed25519.pub` (chave pública) criados.

#### 3.3.2. Copiar chave pública para o AD

```powershell
# No seu PC, exibir a chave pública
Get-Content C:\Users\paulo\.ssh\id_ed25519.pub

# Copiar o conteúdo (ex: ssh-ed25519 AAAAC3... paulo@fiqueok.com.br)
```

#### 3.3.3. Instalar chave pública no AD

```powershell
# No console do AD (PowerShell como Administrador)

# Criar diretório .ssh para o usuário (se não existir)
$sshPath = "C:\Users\paulo.feitosa\.ssh"
if (-not (Test-Path $sshPath)) {
    New-Item -ItemType Directory -Path $sshPath -Force
}

# Criar arquivo authorized_keys com a chave pública
# (substituir pela chave gerada no seu PC)
$publicKey = "ssh-ed25519 AAAAC3... paulo@fiqueok.com.br"
$publicKey | Out-File -FilePath "$sshPath\authorized_keys" -Encoding ascii -Append

# Ajustar permissões (importante para segurança)
icacls "$sshPath\authorized_keys" /inheritance:r /grant "paulo.feitosa:(R,W)" /grant "SYSTEM:(R)"

# Verificar
Get-Content "$sshPath\authorized_keys"
```

**Critério de saída:** ✅ Arquivo `authorized_keys` criado com a chave pública.

---

### 3.4. Fase 3 - Configurar Tags no Tailscale (5 min)

**Acessar:** https://login.tailscale.com/admin/acls

```json
{
  "tagOwners": {
    "tag:ad":       ["paulo@fiqueok.com.br"],
    "tag:midpoint": ["paulo@fiqueok.com.br"],
    "tag:admin":    ["paulo@fiqueok.com.br"]
  }
}
```

**Aplicar tags aos dispositivos (Admin Console → Machines):**

| Dispositivo | IP Tailscale | Tag |
|-------------|--------------|-----|
| id-p-01 | `xxx.xxx.xxx.xxx` | `tag:ad` |
| iga-gf-02 | `xxx.xxx.xxx.xxx` | `tag:midpoint` |
| desktop-o87tpqi | `xxx.xxx.xxx.xxx` | `tag:admin` |

**Como aplicar:**
1. Machines → id-p-01 → Edit → Tags → adicionar `tag:ad`
2. Machines → iga-gf-02 → Edit → Tags → adicionar `tag:midpoint`
3. Machines → desktop-o87tpqi → Edit → Tags → adicionar `tag:admin`

**Critério de saída:** ✅ Dispositivos com tags aplicadas visíveis no console.

---

### 3.5. Fase 4 - Configurar ACLs Tailscale (10 min)

**No mesmo arquivo ACLs (`https://login.tailscale.com/admin/acls`):**

```json
{
  "acls": [
    // midPoint acessa LDAP do AD (via Tailscale)
    {
      "action": "accept",
      "src": ["tag:midpoint"],
      "dst": ["tag:ad:389"]
    },
    // midPoint acessa LDAPS do AD (futuro - PKI/Vault)
    {
      "action": "accept",
      "src": ["tag:midpoint"],
      "dst": ["tag:ad:636"]
    },
    // Paulo (admin) acessa AD via SSH
    {
      "action": "accept",
      "src": ["tag:admin"],
      "dst": ["tag:ad:22"]
    },
    // Paulo (admin) acessa AD via RDP (emergência)
    {
      "action": "accept",
      "src": ["tag:admin"],
      "dst": ["tag:ad:3389"]
    }
  ],
  "tests": [
    {
      "src": "tag:midpoint",
      "dst": "tag:ad:389",
      "expect": "accept"
    },
    {
      "src": "tag:admin",
      "dst": "tag:ad:22",
      "expect": "accept"
    }
  ]
}
```

**Critério de saída:** ✅ ACLs salvas sem erro de sintaxe.

---

### 3.6. Fase 5 - Configurar MFA via Cloudflare (15 min)

**Pré-requisito:** PRJ017 (Cloudflare Zero Trust) concluído.

**Acessar:** https://one.dash.cloudflare.com/

#### 5.1. Criar aplicação

```
Applications → Add an application → Self-hosted

Application name: AD - Tailscale Access
Application domain: ad-tailscale.fiqueok.com.br
```

#### 5.2. Configurar política de acesso

```
Policy name: Acesso AD com MFA
Action: Allow

Include rules:
  - Emails ending with @fiqueok.com.br

Require rules:
  - mfa (OTP)
```

#### 5.3. Configurar Tailscale para usar Cloudflare

```powershell
# No console do AD (opcional - já integrado)
tailscale set --webclient=true
```

**Critério de saída:** ✅ Política criada e ativa no Cloudflare.

---

### 3.7. Fase 6 - Testes de Validação (15 min)

#### Teste 1: Acesso SSH (deve funcionar)

```powershell
# No seu PC (PowerShell)
ssh paulo.feitosa@xxx.xxx.xxx.xxx

# Deve conectar ao PowerShell do AD
```

**Esperado:** Conexão estabelecida, prompt do PowerShell aparece.

#### Teste 2: Execução de comando remoto via SSH

```powershell
# No seu PC
ssh paulo.feitosa@xxx.xxx.xxx.xxx "whoami"
ssh paulo.feitosa@xxx.xxx.xxx.xxx "ipconfig"
```

**Esperado:** Retorna informações do AD.

#### Teste 3: Transferência de arquivo via SCP

```powershell
# No seu PC
echo "teste" > C:\temp\teste.txt
scp C:\temp\teste.txt paulo.feitosa@xxx.xxx.xxx.xxx:C:\temp\
```

**Esperado:** Arquivo copiado com sucesso.

#### Teste 4: midPoint → AD (LDAP) - Deve funcionar

```bash
# No iga-gf-02
nc -zv xxx.xxx.xxx.xxx 389
```

**Esperado:** `Connection succeeded`

#### Teste 5: Dispositivo não autorizado → AD - Deve falhar

```bash
# Em qualquer outro nó Tailscale sem tag apropriada
nc -zv xxx.xxx.xxx.xxx 389
```

**Esperado:** `Connection refused` ou `timeout`

#### Teste 6: Acesso SSH sem MFA (se aplicável)

O acesso SSH não passa pelo Cloudflare (é direto via Tailscale). O MFA é aplicado em camada separada (Cloudflare Access para RDP/Web).

**Critério de saída:** ✅ Todos os testes OK.

---

### 3.8. Fase 7 - Documentação (10 min)

| # | Entregável | Formato | Localização |
|---|------------|--------|-------------|
| 1 | REL-GMUD-002-PRJ028 | MD | `10_Projetos/PRJ028/30_Operacao_e_Mudanca/` |
| 2 | Configuração final das ACLs | JSON | `10_Projetos/PRJ028/10_Arquitetura_Tecnica/` |
| 3 | POP-PRJ028 (Procedimento de acesso remoto) | MD | `05_BASE-LAB/03_Metodologia-e-Frameworks/` |
| 4 | Chave pública SSH (backup) | TXT | `10_Projetos/PRJ028/50_Evidencias/` |

**Critério de saída:** ✅ Documentação concluída.

---

## 4. Cronograma Estimado

| Fase | Atividade | Duração | Tempo Acumulado |
|------|-----------|---------|-----------------|
| 0 | Preparação (checkpoint) | 5 min | 5 min |
| 1 | Instalação OpenSSH Server | 15 min | 20 min |
| 2 | Configurar chave SSH | 10 min | 30 min |
| 3 | Configurar Tags Tailscale | 5 min | 35 min |
| 4 | Configurar ACLs Tailscale | 10 min | 45 min |
| 5 | Configurar MFA (Cloudflare) | 15 min | 60 min |
| 6 | Testes de validação | 15 min | 75 min |
| 7 | Documentação | 10 min | 85 min |
| **TOTAL** | | **~1h25min** | |

---

## 5. Matriz de Validação

| # | Teste | Comando | Resultado Esperado | Status |
|---|-------|---------|-------------------|--------|
| 1 | Checkpoint criado | `Get-VMSnapshot -VMName ID-P-01` | Snapshot OK | □ |
| 2 | SSH instalado | `Get-Service sshd` | Running | □ |
| 3 | Chave SSH configurada | `ssh paulo.feitosa@xxx.xxx.xxx.xxx` | Conexão OK | □ |
| 4 | Tags aplicadas | Console Tailscale | `tag:ad`, `tag:midpoint`, `tag:admin` | □ |
| 5 | ACLs salvas | Console Tailscale | Sem erros de sintaxe | □ |
| 6 | midPoint → AD (LDAP) | `nc -zv xxx.xxx.xxx.xxx 389` | Connection succeeded | □ |
| 7 | Dispositivo não autorizado | `nc -zv xxx.xxx.xxx.xxx 389` | Connection refused | □ |
| 8 | MFA configurada | Cloudflare Dashboard | Política ativa | □ |
| 9 | SCP funcionando | `scp teste.txt ...` | Arquivo copiado | □ |
| 10 | Documentação concluída | REL + POP | Entregues | □ |

---

## 6. Plano de Rollback

### 6.1. Critério de Ativação

Ativar rollback se qualquer um dos cenários ocorrer:
- ❌ Acesso SSH não funciona após 3 tentativas
- ❌ ACLs bloqueiam acesso legítimo do midPoint
- ❌ MFA não funciona após 15 minutos de troubleshooting
- ❌ AD fica inacessível após configuração
- ❌ Tempo de execução > 2 horas sem progresso

### 6.2. Procedimento de Rollback

#### Opção A - Restaurar Snapshot (Recomendado)

```powershell
# No Hyper-V host
Stop-VM -Name "ID-P-01" -Force
Restore-VMSnapshot -Name "PRE-GMUD-002-PRJ028-*" -VMName "ID-P-01" -Confirm:$false
Start-VM -Name "ID-P-01"
```

#### Opção B - Desfazer configurações (se snapshot não disponível)

```powershell
# Remover regra de firewall SSH
Remove-NetFirewallRule -DisplayName "PRJ028_ALLOW_SSH"

# Desabilitar SSH
Stop-Service sshd
Set-Service sshd -StartupType Disabled

# Remover chave SSH autorizada
Remove-Item "C:\Users\paulo.feitosa\.ssh\authorized_keys" -Force
```

**Tempo estimado de rollback:** < 5 minutos (snapshot) ou 15 minutos (manual)

---

## 7. Riscos e Mitigações

| ID | Risco | Probabilidade | Impacto | Mitigação |
|----|-------|--------------|---------|-----------|
| R01 | SSH não instala (OpenSSH indisponível) | Baixa | Médio | Verificar Windows Server 2022; fallback para RDP |
| R02 | Chave SSH não autentica | Baixa | Médio | Verificar permissões do arquivo authorized_keys |
| R03 | ACL mal configurada bloqueia acesso legítimo | Baixa | Médio | Testar com regras permissivas primeiro |
| R04 | MFA não recebida (e-mail) | Baixa | Médio | Configurar e-mail alternativo |
| R05 | Tag não aplicada corretamente | Baixa | Baixo | Verificar no Admin Console |
| R06 | Cloudflare inacessível | Baixa | Médio | Manter Tailscale como fallback (MFA é adicional) |

---

## 8. Critérios de Sucesso

| # | Critério | Métrica | Peso |
|---|----------|---------|------|
| 1 | SSH instalado e funcionando | `ssh` conecta ao AD | 🔴 Crítico |
| 2 | Tags aplicadas | 3 dispositivos com tags | 🔴 Crítico |
| 3 | ACLs configuradas e testadas | Apenas autorizados acessam | 🔴 Crítico |
| 4 | midPoint → AD funcionando | `nc -zv xxx.xxx.xxx.xxx 389` OK | 🔴 Crítico |
| 5 | MFA configurada | Acesso exige OTP | 🟡 Importante |
| 6 | SCP funcionando | Transferência de arquivos OK | 🟢 Desejável |
| 7 | Documentação completa | REL + POP entregues | 🟢 Desejável |

---

## 9. Aprovações

| Função | Nome | Data | Status |
|--------|------|------|:------:|
| Responsável Técnico | Paulo Feitosa Lima | 10/05/2026 | 🟡 Pendente |
| GRC Lead | Paulo Feitosa Lima | 10/05/2026 | 🟡 Pendente |
| Aprovador Final | Paulo Feitosa Lima | 10/05/2026 | 🟡 Pendente |

---

## 10. Próximos Passos Pós-GMUD

| Ordem | Ação | Projeto |
|-------|------|---------|
| 1 | Validar SSH, ACLs e MFA | GMUD-002-PRJ028 |
| 2 | Atualizar Resource do AD no midPoint para IP Tailscale (`xxx.xxx.xxx.xxx`) | PRJ026 |
| 3 | Retomar execução do PRJ026 (integração midPoint ↔ AD) | PRJ026 |
| 4 | Documentar POP-PRJ028 completo (acesso remoto via SSH) | PRJ028 |
| 5 | Configurar LDAPS (636) com certificados do Vault | GMUD futura |

---

**FIM DA GMUD-002-PRJ028 v1.0**

---

*Documento mantido por Paulo Feitosa Lima — Living Lab Fiqueok*  
*PRJ028 - Segurança e Acesso Remoto ao Active Directory*  
*Referência: ADR-007 (Arquitetura Zero Trust para AD)*  
*Data: 10/05/2026*
```
