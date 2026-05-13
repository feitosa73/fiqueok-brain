# POP-GOLDEN-DISK-001
## Procedimento Operacional Padrão — Gestão de Golden Disks Hyper-V

| Campo                 | Valor                                                                    |
| --------------------- | ------------------------------------------------------------------------ |
| **Código**            | POP-GOLDEN-DISK-001                                                      |
| **Versão**            | 1.1                                                                      |
| **Data de Criação**   | 29/03/2026                                                               |
| **Data de Revisão**   | 01/04/2026                                                               |
| **Autor**             | Paulo Feitosa Lima — GRC Lead                                            |
| **Projeto de Origem** | PRJ014 — Saneamento e Padronização Hyper-V                               |
| **Escopo**            | Criação, validação, proteção e uso de Golden Disks no Living Lab Fiqueok |
| **Aplicável a**       | Windows Server 2022, Ubuntu 24.04 LTS — Hyper-V (GEN1 e GEN2)           |
| **Classificação**     | Confidencial Interno — Lab Fiqueok                                       |

---

## 1. Objetivo

Este POP define os procedimentos obrigatórios para criação, validação, proteção e uso de Golden Disks (discos template) no ambiente Hyper-V do Living Lab Fiqueok. O objetivo é garantir que toda VM provisionada a partir de um template parta de um estado *Known Good*: generalizado, independente, protegido e validado.

Este documento incorpora as lições aprendidas **L12 a L21**, registradas no TEP-PRJ014 v1.1 e na base de conhecimento de 01/04/2026, incluindo os procedimentos descobertos durante o ciclo de purificação do ativo Win2022-GF em 29/03/2026 e a identificação da restrição de AD DS no GEN2 em 01/04/2026.

---

## 2. Conceitos Fundamentais

| Termo | Definição |
|-------|-----------|
| **Golden Disk (GD)** | Arquivo VHDX mestre, somente-leitura, generalizado, que serve como base para clonagem de VMs via disco diferencial. Nunca é iniciado diretamente. |
| **Estado Pure / Greenfield** | Estado em que o SO foi generalizado via Sysprep (Windows) ou sanitização cloud-init (Linux), sem roles, dados, ou identidades específicas. Validado pelo aparecimento da tela OOBE (Windows) ou prompt limpo sem machine-id (Linux). **Para Golden Disks Windows, o estado Pure também implica ausência de qualquer resquício de AD DS.** |
| **Disco Diferencial** | Arquivo VHDX do tipo Differencing que aponta para um Golden Disk como pai. Toda escrita vai para o diferencial; o GD permanece inalterado. É o único método de provisão de VMs a partir de GDs. |
| **ParentPath** | Atributo de um VHDX que indica dependência de um disco pai. Um Golden Disk legítimo deve ter ParentPath = null (disco independente/standalone). |
| **Pre-Flight** | Script de validação obrigatório executado antes de homologar qualquer VHDX como Golden Disk. Verifica: existência, integridade, ParentPath nulo, IsReadOnly e ausência de resquícios de AD DS. |
| **CONSTRAINT-001** | Restrição do ambiente: subsistema UEFI do Hyper-V corrompido, impedindo criação de VMs GEN2 a partir de ISO. Workaround: clonar VMs GEN2 existentes. |
| **Resquício de AD DS** | Metadados de Active Directory Domain Services que persistem em um VHDX clonado de servidor que exerceu função de DC. Não são removíveis por limpeza manual de registro/SYSVOL/NTDS. Impedem qualquer promoção a DC a partir desse VHDX. |

---

## 3. Regras de Governança (Não Negociáveis)

As 5 regras abaixo são obrigatórias e não podem ser contornadas:

| ID | Regra | Detalhe |
|----|-------|---------|
| **R01** | **Imutabilidade Obrigatória** | O arquivo VHDX do Golden Disk DEVE carregar o atributo `IsReadOnly = True`. Nenhuma VM pode ser conectada diretamente ao GD. Nunca desproteja o GD sem intenção explícita de atualização de versão. |
| **R02** | **Arquitetura Diferencial** | O provisionamento de VMs DEVE ocorrer estritamente via Differencing Disks. Nunca copie o VHDX do GD e use a cópia diretamente como disco de VM. |
| **R03** | **Reparo de Cadeia Após Rename** | Se o Golden Disk mestre for renomeado ou movido, a cadeia diferencial de TODAS as VMs dependentes deve ser reparada imediatamente via: `Set-VHD -Path <caminho_diff> -ParentPath <novo_caminho_mestre>` |
| **R04** | **Validação Greenfield Obrigatória** | Um Golden Disk só é homologado como oficial após validação de estado Pure: Windows = tela OOBE 'Hi there' ao ligar; Linux = ausência de machine-id e Tailscale residual. |
| **R05** | **Proibição de Clonagem de DC para GD com uso AD DS** | Golden Disks criados a partir de clonagem de servidores que exerceram função de Controlador de Domínio NÃO podem ser usados para provisionamento de novos DCs, mesmo após limpeza manual. A limpeza manual é insuficiente para remover metadados profundos de AD DS. |

---

## 4. Procedimento de Pre-Flight (Validação Obrigatória)

Execute este script PowerShell em qualquer VHDX candidato a Golden Disk antes de classificá-lo como oficial.

> ⚠️ **A partir da v1.1, o Pre-Flight inclui o CHECK 4 — Resquícios de AD DS. Este check é obrigatório para Golden Disks Windows.**

```powershell
# POP-GOLDEN-DISK-001 | Pre-Flight Check v1.1

# Substitua o caminho abaixo pelo arquivo a validar
$gdPath = 'C:\Hyper-V\GoldenDisks\<pasta>\<arquivo>.vhdx'

$file = Get-Item $gdPath
$vhdInfo = Get-VHD -Path $gdPath

Write-Host "=== PRE-FLIGHT CHECK — $($file.Name) ===" -ForegroundColor Cyan

# CHECK 1: Integridade
Write-Host "`n[CHECK 1] Integridade do VHDX:" -ForegroundColor Yellow
$vhdInfo | Select-Object VhdType, Size, MinimumSize | Format-Table

# CHECK 2: Imutabilidade
Write-Host "[CHECK 2] Imutabilidade:" -ForegroundColor Yellow
if ($file.IsReadOnly) {
    Write-Host '  [OK] IsReadOnly = True' -ForegroundColor Green
} else {
    Write-Host '  [FALHA] Aplicar: Set-ItemProperty -Path $gdPath -Name IsReadOnly -Value $true' -ForegroundColor Red
}

# CHECK 3: Independência (ParentPath nulo)
Write-Host "[CHECK 3] Independência (ParentPath):" -ForegroundColor Yellow
if ($null -eq $vhdInfo.ParentPath -or $vhdInfo.ParentPath -eq '') {
    Write-Host '  [OK] Disco standalone (sem ParentPath)' -ForegroundColor Green
} else {
    Write-Host "  [FALHA] ParentPath detectado: $($vhdInfo.ParentPath)" -ForegroundColor Red
    Write-Host '  Ação: Usar Convert-VHD para criar disco independente'
}

# CHECK 4: Resquícios de AD DS (Windows apenas)
Write-Host "[CHECK 4] Resquícios de AD DS (requer VM temporária — ver instrução abaixo):" -ForegroundColor Yellow
Write-Host "  Montar o VHDX em uma VM de validação (disco diferencial) e executar:" -ForegroundColor Gray
Write-Host @'
  # 4a. Verificar chave de registro NTDS
  $ntdsKey = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS" -ErrorAction SilentlyContinue
  if ($ntdsKey) { Write-Host "  [ALERTA] Chave NTDS presente no registro" -ForegroundColor Red }
  else { Write-Host "  [OK] Sem chave NTDS no registro" -ForegroundColor Green }

  # 4b. Verificar conteúdo de NTDS e SYSVOL
  $ntdsContent = Get-ChildItem "C:\Windows\NTDS" -ErrorAction SilentlyContinue
  $sysvolContent = Get-ChildItem "C:\Windows\SYSVOL" -Recurse -ErrorAction SilentlyContinue
  if ($ntdsContent) { Write-Host "  [ALERTA] C:\Windows\NTDS não está vazio" -ForegroundColor Red }
  else { Write-Host "  [OK] C:\Windows\NTDS vazio ou inexistente" -ForegroundColor Green }
  if ($sysvolContent) { Write-Host "  [ALERTA] C:\Windows\SYSVOL não está vazio" -ForegroundColor Red }
  else { Write-Host "  [OK] C:\Windows\SYSVOL vazio ou inexistente" -ForegroundColor Green }

  # 4c. Verificar sufixo DNS residual
  $dnsSuffix = (Get-DnsClientGlobalSetting).SuffixSearchList
  if ($dnsSuffix) { Write-Host "  [ALERTA] Sufixo DNS residual: $dnsSuffix" -ForegroundColor Red }
  else { Write-Host "  [OK] Sem sufixo DNS residual" -ForegroundColor Green }
'@

Write-Host "`n=== Se QUALQUER check falhar: NÃO homologar. Ver Seção 5 para remediação. ===" -ForegroundColor Yellow
```

> ⚠️ **Um VHDX só pode ser classificado como Golden Disk Oficial se os 4 checks passarem: VhdType = Dynamic, IsReadOnly = True, ParentPath nulo e ausência de resquícios de AD DS.**

> 🚨 **Se o CHECK 4 detectar resquícios de AD DS em um VHDX clonado de servidor que foi DC: o disco NÃO deve ser remediado para uso como base de novos DCs. A limpeza manual é insuficiente. Criar novo Golden Disk a partir de instalação limpa.**

---

## 5. Procedimento de Purificação de Disco (Remediação de Falha no Pre-Flight)

Se o Pre-Flight detectar ParentPath não nulo, o disco deve ser purificado via Convert-VHD:

```powershell
# Purificar disco com ParentPath (torná-lo standalone)
# A VM deve estar DESLIGADA
$origem = 'C:\Hyper-V\GoldenDisks\<pasta>\<arquivo-com-parentpath>.vhdx'
$destino = 'C:\Hyper-V\GoldenDisks\<pasta>\<arquivo-puro>.vhdx'

Convert-VHD -Path $origem -DestinationPath $destino -VHDType Dynamic

# Validar resultado
Get-VHD -Path $destino | Select-Object Path, VhdType, ParentPath

# Aplicar imutabilidade
Set-ItemProperty -Path $destino -Name IsReadOnly -Value $true
```

> 🚫 **NUNCA use Merge-VHD com destino inexistente — o cmdlet exige que o arquivo de destino já exista. Use sempre Convert-VHD para criar discos independentes.**

> 🚫 **Convert-VHD NÃO remove resquícios de AD DS. Se o CHECK 4 falhar, a purificação requer ciclo completo: descomissionamento de AD DS + Sysprep. Ver Seção 6.**

---

## 6. Procedimento de Criação de Golden Disk Windows Server 2022

### 6.1. Pré-requisitos e Restrições

| Item | Detalhe |
|---|---|
| **CONSTRAINT-001 ativa** | VMs GEN2 NÃO podem ser criadas a partir de ISO. Clonar VMs GEN2 existentes. |
| GEN1 — sem restrição | VMs GEN1 podem ser criadas normalmente a partir de ISO. |
| SO a instalar | Windows Server 2022 Datacenter (Desktop Experience) |
| ISO disponível | `C:\Hyper-V\ISOs\WindowsServer2022.iso` (4.7 GB) |
| Tamanho recomendado | 80 GB dinâmico |
| **Origem do servidor base** | **NÃO clonar servidores que exerceram função de DC para GDs destinados a AD DS (L21).** |

### 6.2. Sequência de Execução — Preparação para Sysprep

Esta sequência incorpora as lições L17, L18 e L21: roles de AD/DNS/DHCP devem ser removidas antes do Sysprep, pacotes Appx bloqueadores (como o Edge Stable) devem ser eliminados, e o servidor de origem não deve ter histórico de DC se o GD for usado para AD DS.

| Passo | Ação | Comando / Detalhe |
|---|---|---|
| 1 | Instalar o SO base | Instalar Windows Server 2022 — NÃO ingressar em domínio |
| 2 | Instalar roles de teste (opcional) | Instalar apenas o necessário para o lab. Documentar tudo que for instalado. |
| 3 | Remover DHCP (se instalado) | `Uninstall-WindowsFeature -Name DHCP -IncludeManagementTools; Restart-Computer` |
| 4 | Remover DNS (se instalado) | `Uninstall-WindowsFeature -Name DNS; Restart-Computer` |
| 5 | Rebaixar DC / Remover AD DS (se promovido) | `Uninstall-ADDSDomainController -LocalAdministratorPassword (Read-Host -Prompt 'Password' -AsSecureString) -Force; Restart-Computer` |
| 6 | Remover role AD DS | `Uninstall-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools; Restart-Computer` |
| 7 | Remover pacotes Appx bloqueadores | `Get-AppxPackage -AllUsers \| Where-Object {$_.Name -like '*Edge*'} \| Remove-AppxPackage -AllUsers` [Verificar SetupAct.log em C:\Windows\Panther\ se Sysprep falhar] |
| 8 | Executar Sysprep | `C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown` |
| 9 | Exportar VHDX via Convert-VHD | `Convert-VHD -Path <origem-diff> -DestinationPath <destino-gd> -VHDType Dynamic` |
| 10 | Aplicar imutabilidade | `Set-ItemProperty -Path <destino-gd> -Name IsReadOnly -Value $true` |
| 11 | Executar Pre-Flight (Seção 4) | **Todos os 4 checks devem passar.** Se algum falhar, NÃO homologar. |
| 12 | Validação OOBE | Criar VM de validação com disco diferencial, iniciar e confirmar tela 'Hi there' |

> ⚠️ **Atenção (L21):** Se o servidor de origem já foi DC, o ciclo de descomissionamento (passos 5 e 6) **não garante** a remoção completa de metadados de AD DS do VHDX. O CHECK 4 do Pre-Flight é a única forma de confirmar o estado Pure. Em caso de dúvida, prefira uma instalação limpa.

---

## 7. Procedimento de Provisionamento de VM a partir do Golden Disk

```powershell
# POP-GOLDEN-DISK-001 | Provisionamento de VM via Disco Diferencial
# 1. Variáveis — ajustar para cada novo provisionamento
$vmName = 'NOME-DA-VM'
$gdPath = 'C:\Hyper-V\GoldenDisks\Win2022-GF\Win2022-GF-PURE-V3-GREENFIELD.vhdx'
$vmDir = "C:\Hyper-V\VMs\$vmName"
$diffDisk = "$vmDir\$vmName-diff.vhdx"

# 2. Criar diretório da VM
New-Item -ItemType Directory -Path $vmDir -Force

# 3. Criar disco diferencial (O GD permanece intocado)
New-VHD -ParentPath $gdPath -Path $diffDisk -Differencing

# 4. Criar a VM (GEN2 para Windows Server 2022)
New-VM -Name $vmName -MemoryStartupBytes 2GB -Generation 2 -Path 'C:\Hyper-V\VMs\' -VHDPath $diffDisk

# 5. Configurar recursos
Set-VMMemory $vmName -DynamicMemoryEnabled $true -MinimumBytes 1GB -MaximumBytes 4GB
Set-VMProcessor $vmName -Count 2
Set-VMFirmware $vmName -EnableSecureBoot On -FirstBootDevice (Get-VMHardDiskDrive -VMName $vmName)

# 6. Iniciar
Start-VM -Name $vmName
vmconnect $env:COMPUTERNAME $vmName
```

> ℹ️ O disco diferencial criado no passo 3 ocupa apenas ~4 MB inicialmente. Cresce somente com as alterações feitas na VM, preservando o Golden Disk original intocado.

---

## 8. Procedimento de Reparo de Cadeia Diferencial (Pós-Rename do GD)

```powershell
# POP-GOLDEN-DISK-001 | Reparo de Cadeia Diferencial
# Executar com a VM DESLIGADA
$diffPath = 'C:\Hyper-V\VMs\<VM>\<VM>-diff.vhdx'
$novoGD = 'C:\Hyper-V\GoldenDisks\<pasta>\<novo-nome-gd>.vhdx'

# Verificar cadeia atual
Get-VHD -Path $diffPath | Select-Object Path, VhdType, ParentPath

# Reparar
Set-VHD -Path $diffPath -ParentPath $novoGD

# Confirmar
Get-VHD -Path $diffPath | Select-Object Path, ParentPath
```

> 🚫 **Execute o reparo de cadeia em TODAS as VMs dependentes do GD renomeado, não apenas na mais recente. Verifique a lista completa com:**
> `Get-VM | ForEach-Object { Get-VHD (Get-VMHardDiskDrive $_.Name).Path } | Where-Object { $_.ParentPath -like '*nome-antigo*' }`

---

## 9. Higienização de Entropia (Limpeza de Versões Intermediárias)

```powershell
# POP-GOLDEN-DISK-001 | Higienização
$path = 'C:\Hyper-V\GoldenDisks\<pasta>\'
$alvos = @('arquivo-intermediario-1.vhdx', 'arquivo-intermediario-2.vhdx')

foreach ($arquivo in $alvos) {
    $fullPath = Join-Path $path $arquivo
    if (Test-Path $fullPath) {
        Set-ItemProperty -Path $fullPath -Name IsReadOnly -Value $false
        Remove-Item -Path $fullPath -Force
        Write-Host "[OK] $arquivo removido." -ForegroundColor Green
    }
}

# Garantir ReadOnly em todos os GDs remanescentes
Get-ChildItem -Path 'C:\Hyper-V\GoldenDisks\' -Recurse -Include *.vhdx |
    Where-Object { $_.IsReadOnly -eq $false } |
    Set-ItemProperty -Name IsReadOnly -Value $true
```

---

## 10. Catálogo de Golden Disks — Estado em 01/04/2026

| Arquivo | Tamanho | ReadOnly | Status | Notas |
|---|---|---|---|---|
| Win2022-GF-GEN1.vhdx | 10.29 GB | ✅ True | Ativo / Legado | GEN1; sem Secure Boot; **apto para AD DS** |
| Win2022-GF-GEN2.vhdx | 13.82 GB | ✅ True | ⚠️ Uso Restrito | Clonado de DC (`corp.fiqueok.com.br`); **NÃO usar para AD DS** (DCPromo.General.54) |
| **Win2022-GF-PURE-V3-GREENFIELD.vhdx** | **13.04 GB** | ✅ True | **OFICIAL ✅** | **Standalone, OOBE validado, Novo SID. Template padrão para PRJ015+; apto para AD DS** |
| Ubuntu2404-GF-GEN2.vhdx | 13.19 GB | ✅ True | Arquivo base | Não usar diretamente |
| Ubuntu2404-GF-GEN2-Clone.vhdx | 6.94 GB | ✅ True | Pendente val. | Homologação OOBE pendente |
| Ubuntu2404-GF-GEN2-Greenfield.vhdx | 7.13 GB | ✅ True | Candidato oficial | Validação cloud-init pendente |

---

## 11. Lições Aprendidas Incorporadas

| ID | Lição | Incorporada em |
|----|-------|----------------|
| L12–L20 | Ver TEP-PRJ014 v1.1 | v1.0 deste POP |
| **L21** | **Golden Disks clonados de servidores que foram DC carregam metadados de AD DS irremovíveis por limpeza manual. O erro DCPromo.General.54 é indicativo. A única solução é usar GD de instalação limpa.** | **v1.1 — Seções 2, 4 (CHECK 4), 6.1, 6.2** |

---

## 12. Changelog

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 29/03/2026 | Paulo Feitosa Lima | Criação. Incorpora lições L12-L20 do TEP-PRJ014 v1.1. Pre-Flight com 3 checks. Procedimentos de purificação, provisionamento, reparo de cadeia e higienização. |
| **1.1** | **01/04/2026** | **Paulo Feitosa Lima** | **Incorpora lição L21 (resquícios de AD DS em GD clonado de DC). Adicionada R05 (governança). Pre-Flight expandido para 4 checks (CHECK 4: resquícios AD DS). Catálogo atualizado com restrição no GEN2. Alerta na Seção 6 sobre origem do servidor base.** |

---

## 13. Aprovações

| Função | Nome | Data | Status |
|--------|------|------|--------|
| GRC Lead / Autor | Paulo Feitosa Lima | 29/03/2026 | ✅ APROVADO (v1.0) |
| GRC Lead / Revisor | Paulo Feitosa Lima | 01/04/2026 | ✅ APROVADO (v1.1) |
| GRC Advisor | Claude (Anthropic) | 01/04/2026 | ✅ REVISADO (v1.1) |

---

**FIM DO POP-GOLDEN-DISK-001 v1.1**
