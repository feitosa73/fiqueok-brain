# POP-GOLDEN-DISK-001
## Procedimento de Clonagem de Golden Disks

| Campo | Valor |
|---|---|
| **Código** | POP-GOLDEN-DISK-001 |
| **Versão** | 1.1 |
| **Data** | 01/04/2026 |
| **Responsável** | Paulo Feitosa Lima — GRC Lead |
| **Ambiente** | Living Lab Fiqueok — Hyper-V Host |
| **Classificação** | Confidencial Interno |

---

## 1. OBJETIVO

Este Procedimento Operacional Padrão descreve como criar novas máquinas virtuais a partir dos Golden Disks (templates) gerados no PRJ014.

---

## 2. GOLDEN DISKS DISPONÍVEIS

| Golden Disk | Arquivo | Tamanho | Geração | Uso Recomendado |
|---|---|---|---|---|
| **Windows Server 2022 GEN1** | `Win2022-GF-GEN1.vhdx` | 10.29 GB | 1 | Servidores Windows GEN1 / DCs sem Secure Boot |
| **Windows Server 2022 GEN2** | `Win2022-GF-GEN2.vhdx` | 13.82 GB | 2 | ⚠️ **Uso restrito — NÃO usar para AD DS. Ver Seção 2.1.** |
| **Windows Server 2022 PURE V3 ✅ OFICIAL** | `Win2022-GF-PURE-V3-GREENFIELD.vhdx` | 13.04 GB | 2 | **Template padrão GEN2 — incluindo DCs e servidores AD DS** |
| **Ubuntu 24.04 LTS GEN2** | `Ubuntu2404-GF-GEN2-Greenfield.vhdx` | 7.13 GB | 2 | Servidores Linux, containers, aplicações |

**Localização:** `C:\Hyper-V\GoldenDisks\`

### 2.1. ⚠️ Restrição — Win2022-GF-GEN2.vhdx e AD DS

**Este Golden Disk NÃO deve ser usado como base para Controladores de Domínio.**

Validado em 01/04/2026: VMs provisionadas a partir do `Win2022-GF-GEN2.vhdx` falham persistentemente na promoção a DC com o erro `DCPromo.General.54 - The parameter is incorrect`, independentemente do nome do domínio-alvo. A causa raiz é que o VHDX foi clonado de `ID-P-01`, servidor com histórico de AD DS (`corp.fiqueok.com.br`), cujos metadados persistem mesmo após limpeza manual de registro, SYSVOL e NTDS.

**Para qualquer servidor que será promovido a DC, utilizar obrigatoriamente:**
- `Win2022-GF-GEN1.vhdx` (GEN1 — instalação limpa, sem histórico de AD DS), **ou**
- `Win2022-GF-PURE-V3-GREENFIELD.vhdx` (GEN2 OFICIAL — Sysprep validado, estado Pure confirmado)

> 📎 Referência: Troubleshooting — Falha na Promoção de DC com Golden Disk GEN2 (01/04/2026)

---

## 3. PRÉ-REQUISITOS

- Acesso administrativo ao host Windows
- PowerShell com privilégios de administrador
- Espaço em disco suficiente (mínimo 50 GB livre)
- Switch virtual configurado (ex: `vSwitch_External_PRJ003`)

---

## 4. PROCEDIMENTO DE CLONAGEM

### 4.1. Clonar Golden Disk Windows Server 2022

```powershell
# ============================================
# CLONAR WINDOWS SERVER 2022 GOLDEN DISK
# ============================================
$NewVMName = "Nova-VM-Windows"           # Nome da nova VM

# ATENÇÃO: Para DCs, usar GEN1 ou PURE-V3-GREENFIELD. NÃO usar GEN2.
$GoldenDiskPath = "C:\Hyper-V\GoldenDisks\Win2022-GF\Win2022-GF-PURE-V3-GREENFIELD.vhdx"

$VMPath = "C:\Hyper-V\VMs\$NewVMName"
$MemoryMB = 4096                         # 4 GB RAM
$ProcessorCount = 2
$SwitchName = "vSwitch_External_PRJ003"

Write-Host "Criando VM: $NewVMName" -ForegroundColor Cyan

# 1. Criar pasta da VM
New-Item -ItemType Directory -Path $VMPath -Force | Out-Null

# 2. Copiar Golden Disk
$NewVHDX = "$VMPath\$NewVMName.vhdx"
Copy-Item -Path $GoldenDiskPath -Destination $NewVHDX -Force

# 3. Criar VM
New-VM -Name $NewVMName `
    -MemoryStartupBytes $MemoryMB `
    -Generation 2 `
    -VHDPath $NewVHDX `
    -SwitchName $SwitchName `
    -Path $VMPath

# 4. Configurar vCPUs
Set-VMProcessor -VMName $NewVMName -Count $ProcessorCount

# 5. Configurar TPM (para GEN2)
Enable-VMTPM -VMName $NewVMName -ErrorAction SilentlyContinue

# 6. Iniciar VM
Start-VM -Name $NewVMName

Write-Host "✅ VM $NewVMName criada com sucesso!" -ForegroundColor Green
Write-Host "   Acesse via console: vmconnect.exe localhost $NewVMName" -ForegroundColor Gray
```

### 4.2. Clonar Golden Disk Ubuntu 24.04 LTS

```powershell
# ============================================
# CLONAR UBUNTU 24.04 LTS GOLDEN DISK
# ============================================
$NewVMName = "Nova-VM-Ubuntu"
$GoldenDiskPath = "C:\Hyper-V\GoldenDisks\Ubuntu2404-GF\Ubuntu2404-GF-GEN2-Greenfield.vhdx"
$VMPath = "C:\Hyper-V\VMs\$NewVMName"
$MemoryMB = 2048
$ProcessorCount = 2
$SwitchName = "vSwitch_External_PRJ003"

Write-Host "Criando VM: $NewVMName" -ForegroundColor Cyan

# 1. Criar pasta da VM
New-Item -ItemType Directory -Path $VMPath -Force | Out-Null

# 2. Copiar Golden Disk
$NewVHDX = "$VMPath\$NewVMName.vhdx"
Copy-Item -Path $GoldenDiskPath -Destination $NewVHDX -Force

# 3. Criar VM (GEN2)
New-VM -Name $NewVMName `
    -MemoryStartupBytes $MemoryMB `
    -Generation 2 `
    -VHDPath $NewVHDX `
    -SwitchName $SwitchName `
    -Path $VMPath

# 4. Configurar vCPUs
Set-VMProcessor -VMName $NewVMName -Count $ProcessorCount

# 5. Desabilitar Secure Boot (necessário para Ubuntu)
Set-VMFirmware -VMName $NewVMName -EnableSecureBoot Off

# 6. Iniciar VM
Start-VM -Name $NewVMName

Write-Host "✅ VM $NewVMName criada com sucesso!" -ForegroundColor Green
Write-Host "   Acesse via console: vmconnect.exe localhost $NewVMName" -ForegroundColor Gray
```

---

## 5. PÓS-CLONAGEM — CONFIGURAÇÕES INICIAIS

### 5.1. Para Windows Server

```powershell
# 1. Alterar hostname
Rename-Computer -NewName "NOVO-NOME" -Force

# 2. Configurar IP estático (opcional)
New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress 192.168.x.x -PrefixLength 24 -DefaultGateway 192.168.x.1

# 3. Configurar DNS
Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses ("8.8.8.8", "8.8.4.4")

# 4. Instalar funções (ex: AD DS)
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# 5. Reiniciar
Restart-Computer
```

### 5.2. Para Ubuntu

```bash
# 1. Alterar hostname
sudo hostnamectl set-hostname novo-nome

# 2. Configurar IP estático (opcional)
sudo nano /etc/netplan/01-netcfg.yaml

# 3. Aplicar configuração
sudo netplan apply

# 4. Atualizar sistema (opcional)
sudo apt update && sudo apt upgrade -y

# 5. Reiniciar
sudo reboot
```

---

## 6. VALIDAÇÃO PÓS-CLONAGEM

| Verificação | Comando | Resultado Esperado |
|---|---|---|
| VM iniciou | `Get-VM -Name "Nova-VM" \| Select State` | `Running` |
| Acesso via SSH (Linux) | `ssh usuario@<IP>` | Conexão estabelecida |
| Acesso via RDP (Windows) | `mstsc /v:<IP>` | Login bem-sucedido |
| Hostname correto | `hostname` | Nome definido |
| Rede funcionando | `ping 8.8.8.8` | 0% perda |

---

## 7. SOLUÇÃO DE PROBLEMAS

| Problema | Causa | Solução |
|---|---|---|
| VM não inicia (UEFI) | Secure Boot ativo para Ubuntu | `Set-VMFirmware -VMName "VM" -EnableSecureBoot Off` |
| VM não inicia (GEN2) | CONSTRAINT-001 | Usar GEN1 ou clonar VM existente |
| IP não obtido | Netplan configurado incorretamente | `sudo netplan apply` ou configurar DHCP |
| SSH recusado | Serviço não iniciado | `sudo systemctl enable ssh && sudo systemctl start ssh` |
| **DCPromo.General.54 ao promover DC** | **Golden Disk GEN2 clonado de servidor com histórico AD DS** | **Substituir pelo GEN1 ou PURE-V3-GREENFIELD. Limpeza manual de registro/SYSVOL é insuficiente. Ver Seção 2.1.** |

---

## 8. REFERÊNCIAS

- TAP-PRJ014 v1.2 — Saneamento e Padronização Hyper-V
- TEP-PRJ014 v1.1 — Termo de Encerramento (adendo 29/03/2026)
- ADR-005 — Decisão Arquitetural (WSL2 vs Hyper-V)
- ADR-006 — Revisão (Falha WSL2 → Hyper-V GEN1)
- Troubleshooting — Falha na Promoção de DC com Golden Disk GEN2 (01/04/2026)

---

## 9. CHANGELOG

| Versão | Data | Autor | Mudanças |
|--------|------|-------|---------|
| 1.0 | 28/03/2026 | Paulo Feitosa Lima | Criação do procedimento |
| **1.1** | **01/04/2026** | **Paulo Feitosa Lima** | **Adicionada Seção 2.1: restrição de uso do GEN2 para AD DS (DCPromo.General.54). Golden Disk padrão do script 4.1 atualizado para PURE-V3-GREENFIELD. Adicionada entrada na tabela de troubleshooting (Seção 7).** |

---

**FIM DO POP-GOLDEN-DISK-001 — PROCEDIMENTO DE CLONAGEM v1.1**
