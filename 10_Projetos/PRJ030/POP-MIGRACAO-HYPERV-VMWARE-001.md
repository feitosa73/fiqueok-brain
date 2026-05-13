# PROCEDIMENTO OPERACIONAL PADRÃO (POP)

## Código: 
## Versão: 1.0
## Data: 12/05/2026
## Autor: Paulo Feitosa Lima — GRC Lead

## Título: Migração de VMs do Hyper-V para VMware Workstation

---

## 1. OBJETIVO

Estabelecer o procedimento padrão e validado para migração de máquinas virtuais do ambiente Hyper-V (host com CONSTRAINT-001 — UEFI corrompido) para VMware Workstation, garantindo a integridade dos dados, a continuidade dos serviços e a rastreabilidade do processo.

---

## 2. APLICAÇÃO

Este POP aplica-se a todas as migrações de VMs do Living Lab Fiqueok que utilizem:

- Hyper-V como origem
- VMware Workstation 17.x como destino
- Tailscale como malha de conectividade

---

## 3. REFERÊNCIAS

| Documento | Descrição |
|-----------|-----------|
| PRJ014 | Saneamento e Padronização Hyper-V |
| TAP-PRJ030 | Termo de Abertura do Projeto de Migração |
| GMUD-001/PRJ030 | Autorização formal para execução |

---

## 4. DEFINIÇÕES

| Termo | Definição |
|-------|-----------|
| **VM Verde** | VM GEN1 (segura para conversão direta) |
| **VM Amarela** | VM GEN2 (tentar conversão com agente) |
| **VM Vermelha** | VM que não deve ser migrada (rebuild limpo) |
| **POC** | Prova de Conceito — primeira VM a ser convertida |
| **HD Externo** | Destino do backup completo antes da migração |

---

## 5. PREPARAÇÃO (PRÉ-EXECUÇÃO)

### 5.1. Verificações Obrigatórias

powershell
# 1. Confirmar que o backup existe
Test-Path "E:\PRJ030-BACKUP-$(Get-Date -Format 'yyyyMMdd')\"

# 2. Confirmar que o snapshot Hyper-V da VM existe
Get-VMSnapshot -VMName <VM_NAME>

# 3. Verificar espaço no destino VMware
Get-PSDrive -Name <DESTINO_LETRA> | Select-Object Free

# 4. Verificar que a Tailscale está ativa
tailscale status### 5.2. Ferramentas Necessárias

|Ferramenta|Local|Versão mínima|
|---|---|---|
|StarWind V2V Converter|Download|9.0|
|VMware Workstation|Instalado|17.x|
|PowerShell (Hyper-V módulos)|Windows|5.1|

---

## 6. PROCEDIMENTO PASSO A PASSO

### 6.1. Backup da VM (Hiper-V)

powershell

# Executar como Administrador no host Hyper-V
$vmName = "<NOME_DA_VM>"
$backupPath = "E:\PRJ030-BACKUP\01_VMS_EXPORTADAS\$vmName"
# Exportar VM (funciona com VM ligada ou desligada)
Export-VM -Name $vmName -Path $backupPath -Force
# Verificar integridade
Get-ChildItem -Path $backupPath -Recurse | Measure-Object -Property Length -Sum

### 6.2. Backup de Configurações Específicas (Apenas para VMs Críticas)

**Para SENTINEL-CORE (Wazuh + Loki):**

bash

# Dentro da VM, antes do desligamento
docker compose -f /opt/sentinel/wazuh/docker-compose.yml ps
docker compose -f /opt/sentinel/loki/docker-compose.yml ps
# Exportar configurações
tar -czf /tmp/sentinel-configs.tar.gz /opt/sentinel/

**Para VAULT-GEN1 (HashiCorp Vault):**

bash

# Verificar selo e status
vault status
# Backup do diretório de dados
sudo tar -czf /tmp/vault-data-backup.tar.gz /opt/vault/data/

### 6.3. Desligamento da VM (Opcional — Documentado na GMUD)

powershell

# Opção A: Desligar a VM (consistência garantida)
Stop-VM -Name $vmName
# Opção B: Manter ligada (Export-VM com VSS funciona)
# Nenhuma ação necessária

### 6.4. Conversão VHDX → VMDK (StarWind V2V Converter)

**Interface Gráfica:**

1. Abrir StarWind V2V Converter
    
2. **Local File** → Next
    
3. Selecionar o arquivo `.vhdx` exportado
    
4. **Destination:** `Local File` → Next
    
5. **VMware Workstation** → Next
    
6. **Pre-allocated** (recomendado para performance) ou **Stream Optimized** (menor espaço)
    
7. Escolher pasta de destino
    
8. **Convert**
    

**Linha de Comando (qemu-img, alternativa):**

bash

qemu-img convert -f vhdx -O vmdk -o adapter_type=lsilogic,subformat=streamOptimized \
    origem.vhdx destino.vmdk

### 6.5. Criação da VM no VMware Workstation

|Configuração|Valor|Observação|
|---|---|---|
|Guest OS|Igual à origem|Windows/Linux|
|Versão|Workstation 17.x||
|vCPUs|Mesmo número da origem||
|RAM|Mesmo valor da origem||
|Disco|Usar VMDK convertido|Attach existing disk|
|Rede|NAT ou Bridge|Para Tailscale, bridge recomendado|

### 6.6. Validação Pós-Boot

**Ordem obrigatória de verificações:**

powershell

# 1. Conectividade básica
ping <IP_DESTINO>
# 2. Acesso SSH/RDP
ssh paulo@<IP_DESTINO>  # Linux
mstsc /v:<IP_DESTINO>   # Windows
# 3. Tailscale
tailscale status
tailscale ping <OUTRA_VM>
# 4. Serviços específicos (depende da VM)
# SENTINEL-CORE: curl localhost:1514, curl localhost:3100, curl localhost:3000
# VAULT-GEN1: vault status
# IGA-GF-02: curl localhost:8080

---

## 7. TRILHAS POR TIPO DE VM

### 7.1. 🟢 VMs Verdes (GEN1) — Procedimento Padrão

|Etapa|Ação|
|---|---|
|1|Backup (Export-VM)|
|2|Conversão VHDX → VMDK|
|3|Criar VM no VMware|
|4|Validar boot e serviços|

### 7.2. 🟡 VMs Amarelas (GEN2) — Procedimento com Agente

|Etapa|Ação Adicional|
|---|---|
|1-4|Mesmo das VMs Verdes|
|5|**Se falhar o boot:** Tentar StarWind V2V Agent (instala dentro da VM antes da conversão)|

### 7.3. 🔴 VMs Vermelhas (NÃO MIGRAR)

|VM|Procedimento|
|---|---|
|ID-P-01 (AD)|Rebuild limpo: `Install-WindowsFeature AD-Domain-Services` + restaurar GPOs via backup do estado do sistema|

---

## 8. ROLLBACK (EM CASO DE FALHA)

### 8.1. Rollback da VM Individual

powershell

# 1. Desligar a VM no VMware
# 2. Remover a VM do inventário
# 3. Restaurar do backup do Hyper-V
Import-VM -Path "$backupPath\$vmName.vmcx" -Copy

### 8.2. Rollback de Falha Crítica (ex: SENTINEL-CORE)

1. Restaurar VM do snapshot Hyper-V original
    
2. Verificar serviços
    
3. Abortar migração até identificar a causa
    

---

## 9. REGISTRO DE EXECUÇÃO (OBRIGATÓRIO)

Para cada VM migrada, preencher:

|Campo|Valor|
|---|---|
|VM Name|_____________|
|Data da migração|_____________|
|Trilha (Verde/Amarela)|_____________|
|Backup realizado (S/N)|_____________|
|Conversão bem-sucedida (S/N)|_____________|
|Boot no VMware (S/N)|_____________|
|Tailscale funcional (S/N)|_____________|
|Serviços validados (S/N)|_____________|
|Responsável|_____________|

---

## 10. HISTÓRICO DE VERSÕES

|Versão|Data|Autor|Mudança|
|---|---|---|---|
|1.0|12/05/2026|Paulo Feitosa Lima|Criação inicial|

---

**FIM DO POP-MIGRACAO-HYPERV-VMWARE-001**