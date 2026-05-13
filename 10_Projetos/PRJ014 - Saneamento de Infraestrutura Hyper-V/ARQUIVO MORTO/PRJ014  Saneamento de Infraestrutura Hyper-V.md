## **Projeto: 

---

## 1. IDENTIFICAÇÃO DO PROJETO

|Campo|Valor|
|---|---|
|**Código**|PRJ014|
|**Nome**|Saneamento e Padronização da Infraestrutura Hyper-V|
|**Categoria**|Infraestrutura / Governança de Laboratório|
|**Responsável**|Paulo Feitosa Lima|
|**Data Início**|27/03/2026|
|**Duração Estimada**|2-3 dias|
|**Objetivo**|Consolidar VMs, padronizar estrutura, criar Golden Disks|

---

## 2. JUSTIFICATIVA

Após diagnóstico da infraestrutura Hyper-V, foram identificadas:

|Problema|Impacto|
|---|---|
|VMs espalhadas em 3 locais diferentes|Dificuldade de gestão e backup|
|ISOs duplicadas em 3 pastas|6.3 GB de espaço desperdiçado|
|VM `LINUX-GOLDEN-IMAGE` com disco inexistente|VM inoperante|
|Múltiplos checkpoints acumulados|Risco de corrupção e degradação de performance|
|Ausência de template padronizado para Windows Server|Dificuldade para criar novas VMs|

---

## 3. ESCOPO

### 3.1. Incluído

|Item|Descrição|
|---|---|
|✅|Consolidação de ISOs em `C:\Hyper-V\ISOs\`|
|✅|Migração de todas as VMs para `C:\Hyper-V\VMs\[VMName]\`|
|✅|Consolidação de checkpoints (onde aplicável)|
|✅|Correção/remoção da VM `LINUX-GOLDEN-IMAGE`|
|✅|Criação do Golden Disk **Windows Server 2022**|
|✅|Criação do Golden Disk **Ubuntu 24.04 LTS**|
|✅|Documentação da nova estrutura|

### 3.2. Excluído

|Item|Motivo|
|---|---|
|❌|Migração de dados do OrangeHRM ou midPoint|Fora do escopo deste projeto|
|❌|Configuração de Entra Cloud Sync|Será PRJ015|
|❌|Criação de novas VMs de produção|Apenas templates|

---

## 4. ARQUITETURA FINAL DESEJADA

text

C:\Hyper-V\
│
├── ISOs\                                    # ÚNICA pasta de ISOs
│   ├── WindowsServer2022.iso
│   └── ubuntu-24.04.3-live-server-amd64.iso
│
├── VMs\                                      # TODAS as VMs
│   ├── api-gf-01\
│   │   └── api-gf-01.vhdx
│   ├── ID-P-01\
│   │   └── ID-P-01.vhdx
│   ├── IGA-GF-01\
│   │   └── IGA-GF-01.vhdx
│   ├── IGA-P-01\
│   │   └── IGA-P-01.vhdx
│   ├── rh-gf-01-local\
│   │   └── rh-gf-01-local.vhdx
│   ├── VAULT-GEN1\
│   │   └── VAULT-GEN1.vhdx
│   ├── FOK-SRV-LDAP-01\
│   │   └── FOK-SRV-LDAP-01.vhdx
│   └── (outras VMs conforme necessário)
│
├── GoldenDisks\                              # Templates para clonagem
│   ├── Win2022-GF\
│   │   ├── Win2022-GF.vhdx
│   │   └── README.md
│   └── Ubuntu2404-GF\
│       ├── Ubuntu2404-GF.vhdx
│       └── README.md
│
└── Scripts\                                  # Automação
    ├── Clone-Win2022FromGF.ps1
    ├── Clone-UbuntuFromGF.ps1
    └── Consolidate-VMs.ps1

---

## 5. ESCLARECIMENTO SOBRE CHECKPOINTS

> **Pergunta:** _"os checkpoints nao serao eliminados correto?"_

**Resposta:** **Depende da VM e do objetivo.**

|Cenário|Ação|Justificativa|
|---|---|---|
|**VM com checkpoints ativos e em uso** (ID-P-01, rh-gf-01-local, VAULT-GEN1)|**Manter**|Checkpoints representam pontos de recuperação importantes. A migração preserva a cadeia de discos diferenciais.|
|**VM com checkpoints antigos e não utilizados** (FOK-SRV-LDAP-01, IGA-P-01)|**Consolidar (mesclar)**|Checkpoints antigos consomem espaço e podem ser mesclados sem perda de dados.|
|**VM com disco inexistente** (LINUX-GOLDEN-IMAGE)|**Remover ou recriar**|Não há o que preservar.|

**Importante:** Durante a migração, **não perdemos checkpoints** — copiamos toda a cadeia de arquivos (`.vhdx` base + todos os `.avhdx`).

---

## 6. GOLDEN DISKS

### 6.1. Windows Server 2022 GF

|Item|Detalhe|
|---|---|
|**Base**|Windows Server 2022 Datacenter (Desktop Experience)|
|**Tamanho**|80 GB (dinâmico)|
|**Sysprep**|Sim (generalizado)|
|**Pré-instalações**|Nenhuma (template limpo)|
|**Uso**|Base para DC, servidores Windows|

### 6.2. Ubuntu 24.04 LTS GF

|Item|Detalhe|
|---|---|
|**Base**|Ubuntu 24.04 LTS Server|
|**Tamanho**|40 GB (dinâmico)|
|**Sysprep**|`cloud-init` + remoção de machine-id|
|**Pré-instalações**|Docker, Tailscale (opcional)|
|**Uso**|Base para containers, serviços Linux|

---

## 7. PLANO DE EXECUÇÃO

### **Fase 1: Consolidação de ISOs** (Dia 1, 30 min)

- Criar pasta `C:\Hyper-V\ISOs\`
    
- Mover Windows Server ISO
    
- Mover Ubuntu ISO (apenas uma cópia)
    
- Remover pastas duplicadas
    
- Atualizar referências das VMs (se necessário)
    

### **Fase 2: Consolidação de VMs** (Dia 1-2, 2-3 horas)

- Consolidar checkpoints antigos (FOK-SRV-LDAP-01, IGA-P-01)
    
- Migrar cada VM para `C:\Hyper-V\VMs\`
    
- Validar que cada VM inicia após migração
    

### **Fase 3: Correção da LINUX-GOLDEN-IMAGE** (Dia 2, 30 min)

- Opção A: Remover a VM (se não necessária)
    
- Opção B: Recriar o Golden Disk Ubuntu (será feito na Fase 4)
    

### **Fase 4: Criação dos Golden Disks** (Dia 2-3, 2-3 horas)

- Criar VM base para Windows Server 2022
    
- Instalar Windows Server 2022
    
- Executar Sysprep e generalizar
    
- Copiar VHDX para `C:\Hyper-V\GoldenDisks\Win2022-GF\`
    
- Criar VM base para Ubuntu 24.04 LTS
    
- Instalar Ubuntu Server
    
- Executar sanitização (remover machine-id, limpar logs)
    
- Copiar VHDX para `C:\Hyper-V\GoldenDisks\Ubuntu2404-GF\`
    

### **Fase 5: Documentação e Encerramento** (Dia 3, 1 hora)

- Criar README para cada Golden Disk
    
- Criar scripts de clonagem
    
- Atualizar documentação no Obsidian
    

---

## 8. RENOMEIO DOS PROJETOS

> **Sua sugestão:** _"Cloud Sync (local poderia ser o PROJ015 em vez do 014 projetado anteriormente"_

**Aceito.** Ajustando a nomenclatura:

|Projeto|Nome|Status|
|---|---|---|
|**PRJ014**|Saneamento e Padronização Hyper-V|🔄 Novo|
|**PRJ015**|IGA Híbrido Local (AD → Cloud Sync)|📋 Planejado|
|**PRJ016**|midPoint como Motor IGA (pós-Trial)|📋 Futuro|
