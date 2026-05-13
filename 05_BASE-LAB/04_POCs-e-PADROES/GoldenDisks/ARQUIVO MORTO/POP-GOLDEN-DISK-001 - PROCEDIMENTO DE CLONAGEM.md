
---

# POP-GOLDEN-DISK-001

## Procedimento de Clonagem de Golden Disks

|Campo|Valor|
|---|---|
|**Código**|POP-GOLDEN-DISK-001|
|**Versão**|1.0|
|**Data**|28/03/2026|
|**Responsável**|Paulo Feitosa Lima — GRC Lead|
|**Ambiente**|Living Lab Fiqueok — Hyper-V Host|
|**Classificação**|Confidencial Interno|

---

## 1. OBJETIVO

Este Procedimento Operacional Padrão descreve como criar novas máquinas virtuais a partir dos Golden Disks (templates) gerados no PRJ014.

---

## 2. GOLDEN DISKS DISPONÍVEIS

|Golden Disk|Arquivo|Tamanho|Geração|Uso Recomendado|
|---|---|---|---|---|
|**Windows Server 2022 GEN1**|`Win2022-GF-GEN1.vhdx`|10.29 GB|1|Servidores Windows em ambientes legados|
|**Windows Server 2022 GEN2**|`Win2022-GF-GEN2.vhdx`|13.82 GB|2|Servidores Windows modernos (Secure Boot, TPM)|
|**Ubuntu 24.04 LTS GEN2**|`Ubuntu2404-GF-GEN2-Greenfield.vhdx`|7.13 GB|2|Servidores Linux, containers, aplicações|

**Localização:** `C:\Hyper-V\GoldenDisks\`

---

## 3. PRÉ-REQUISITOS

- Acesso administrativo ao host Windows
    
- PowerShell com privilégios de administrador
    
- Espaço em disco suficiente (mínimo 50 GB livre)
    
- Switch virtual configurado (ex: `vSwitch_External_PRJ003`)
    

---

## 4. PROCEDIMENTO DE CLONAGEM

### 4.1. Clonar Golden Disk Windows Server 2022

powershell

# <REDACTED_SECRET>====
# CLONAR WINDOWS SERVER 2022 GOLDEN DISK
# <REDACTED_SECRET>====
$NewVMName = "Nova-VM-Windows"           # Nome da nova VM
$GoldenDiskPath = "C:\Hyper-V\GoldenDisks\Win2022-GF\Win2022-GF-GEN2.vhdx"  # Use GEN1 ou GEN2
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

### 4.2. Clonar Golden Disk Ubuntu 24.04 LTS

powershell

# <REDACTED_SECRET>====
# CLONAR UBUNTU 24.04 LTS GOLDEN DISK
# <REDACTED_SECRET>====
$NewVMName = "Nova-VM-Ubuntu"            # Nome da nova VM
$GoldenDiskPath = "C:\Hyper-V\GoldenDisks\Ubuntu2404-GF\Ubuntu2404-GF-GEN2-Greenfield.vhdx"
$VMPath = "C:\Hyper-V\VMs\$NewVMName"
$MemoryMB = 2048                          # 2 GB RAM (ajustável)
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

---

## 5. PÓS-CLONAGEM — CONFIGURAÇÕES INICIAIS

### 5.1. Para Windows Server

Dentro da VM clonada:

powershell

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

### 5.2. Para Ubuntu

Dentro da VM clonada:

bash

# 1. Alterar hostname
sudo hostnamectl set-hostname novo-nome
# 2. Configurar IP estático (opcional)
sudo nano /etc/netplan/01-netcfg.yaml
# Editar conforme necessário
# 3. Aplicar configuração
sudo netplan apply
# 4. Atualizar sistema (opcional)
sudo apt update && sudo apt upgrade -y
# 5. Reiniciar
sudo reboot

---

## 6. VALIDAÇÃO PÓS-CLONAGEM

|Verificação|Comando|Resultado Esperado|
|---|---|---|
|VM iniciou|`Get-VM -Name "Nova-VM" \| Select State`|`Running`|
|Acesso via SSH (Linux)|`ssh usuario@<IP>`|Conexão estabelecida|
|Acesso via RDP (Windows)|`mstsc /v:<IP>`|Login bem-sucedido|
|Hostname correto|`hostname`|Nome definido|
|Rede funcionando|`ping 8.8.8.8`|0% perda|

---

## 7. SOLUÇÃO DE PROBLEMAS

|Problema|Causa|Solução|
|---|---|---|
|VM não inicia (UEFI)|Secure Boot ativo para Ubuntu|`Set-VMFirmware -VMName "VM" -EnableSecureBoot Off`|
|VM não inicia (GEN2)|CONSTRAINT-001|Usar GEN1 ou clonar VM existente|
|IP não obtido|Netplan configurado incorretamente|`sudo netplan apply` ou configurar DHCP|
|SSH recusado|Serviço não iniciado|`sudo systemctl enable ssh && sudo systemctl start ssh`|

---

## 8. REFERÊNCIAS

- TAP-PRJ014 v1.2 — Saneamento e Padronização Hyper-V
    
- TEP-PRJ014 v1.0 — Termo de Encerramento
    
- ADR-005 — Decisão Arquitetural (WSL2 vs Hyper-V)
    
- ADR-006 — Revisão (Falha WSL2 → Hyper-V GEN1)
