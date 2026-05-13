# 

**Identity Governance & Administration - Arquitetura midPoint + PostgreSQL em Ubuntu Server sobre Hyper-V**

---

## 📋 CONTROLE DE DOCUMENTO

|Campo|Informação|
|---|---|
|**Código POP**|POP-IGA-001|
|**Versão**|4.1 **PRODUCTION-READY - BASELINE HARDENED**|
|**Tipo**|Infraestrutura - Implementação Greenfield|
|**Objetivo**|Guia completo para deploy de ambiente IGA do zero|
|**Escopo**|Download ISO → Criação VM → Configuração OS → Deploy Aplicação|
|**Pré-requisitos**|Windows 10/11 Pro com Hyper-V, 8GB RAM disponível, 100GB disco|
|**Tempo Estimado**|2-4 horas (primeira execução)|
|**Dificuldade**|Intermediária|
|**Público-alvo**|Administradores de Infraestrutura, Equipes DevOps, Auditores GRC|
|**Data de Criação**|Janeiro/2026|
|**Data de Revisão**|20/Janeiro/2026|
|**Status**|✅ **Validado em Produção - GMUD-009 Aprovada**|

---

## 🔄 CHANGELOG v4.1 - HARDENING DE BASELINE

|Item|Problema v4.0|Correção v4.1|Severidade|Fase|
|---|---|---|---|---|
|**1**|Imagem PostgreSQL Alpine sem ferramentas diagnóstico|Especificada `postgres:16` (Debian)|⭐⭐⭐⭐|7.2|
|**2**|Nomes de interface de rede assumidos (`eth0`)|Adicionada descoberta via `ip link show`|⭐⭐⭐⭐|5.1|
|**3**|Purge de volumes não obrigatório|Elevado para **ETAPA 0** obrigatória|⭐⭐⭐⭐⭐|8.2|
|**4**|Checklist de baseline disperso|Nova **Fase 10: Checklist de Baseline**|⭐⭐⭐⭐|10|
|**5**|Alerta de lockout SSH insuficiente|Reforço: "Desconexão é sinal de sucesso"|⭐⭐⭐⭐|5.1|

---

## 📑 ÍNDICE

1. [Visão Geral da Arquitetura](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#1-vis%C3%A3o-geral-da-arquitetura)
    
2. [Pré-requisitos e Validações](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#2-pr%C3%A9-requisitos-e-valida%C3%A7%C3%B5es)
    
3. [Fase 1 - Preparação do Ambiente Windows](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#3-fase-1-prepara%C3%A7%C3%A3o-do-ambiente-windows)
    
4. [Fase 2 - Criação da Máquina Virtual no Hyper-V](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#4-fase-2-cria%C3%A7%C3%A3o-da-m%C3%A1quina-virtual-no-hyper-v)
    
5. [Fase 3 - Instalação do Ubuntu Server](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#5-fase-3-instala%C3%A7%C3%A3o-do-ubuntu-server)
    
6. [Fase 4 - Configuração Pós-Instalação do Ubuntu](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#6-fase-4-configura%C3%A7%C3%A3o-p%C3%B3s-instala%C3%A7%C3%A3o-do-ubuntu)
    
7. [Fase 5 - Hardening de Segurança](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#7-fase-5-hardening-de-seguran%C3%A7a)
    
8. [Fase 6 - Instalação do Docker e Docker Compose](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#8-fase-6-instala%C3%A7%C3%A3o-do-docker-e-docker-compose)
    
9. [Fase 7 - Preparação da Estrutura do Projeto IGA](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#9-fase-7-prepara%C3%A7%C3%A3o-da-estrutura-do-projeto-iga)
    
10. [Fase 8 - Deploy do Ambiente IGA](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#10-fase-8-deploy-do-ambiente-iga)
    
11. [Fase 9 - Validação e Testes](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#11-fase-9-valida%C3%A7%C3%A3o-e-testes)
    
12. [Fase 10 - Checklist de Baseline de Segurança](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#12-fase-10-checklist-de-baseline-de-seguran%C3%A7a)
    
13. [Troubleshooting e Diagnósticos](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#13-troubleshooting-e-diagn%C3%B3sticos)
    
14. [Manutenção e Operação](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#14-manuten%C3%A7%C3%A3o-e-opera%C3%A7%C3%A3o)
    
15. [Referências e Documentação](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#15-refer%C3%AAncias-e-documenta%C3%A7%C3%A3o)
    

---

## 1. VISÃO GERAL DA ARQUITETURA

## 1.1. Componentes da Solução

text

`┌─────────────────────────────────────────────────────────┐ │              HOST WINDOWS                                │ │              Hyper-V Habilitado                          │ │                                                          │ │  ┌────────────────────────────────────────────────────┐ │ │  │   MÁQUINA VIRTUAL                                   │ │ │  │   Ubuntu Server 24.04 LTS                          │ │ │  │                                                     │ │ │  │   ┌─────────────────────────────────────────────┐  │ │ │  │   │  DOCKER ENVIRONMENT                         │  │ │ │  │   │                                             │  │ │ │  │   │  ┌──────────────┐  ┌───────────────────┐   │  │ │ │  │   │  │ PostgreSQL   │  │   midPoint        │   │  │ │ │  │   │  │ Database     │  │   IGA Server      │   │  │ │ │  │   │  │ Port: 5432   │  │   Port: 8080      │   │  │ │ │  │   │  │ (Debian)     │  │   (Debian)        │   │  │ │ │  │   │  └──────────────┘  └───────────────────┘   │  │ │ │  │   │         ▲                    ▲              │  │ │ │  │   │         │                    │              │  │ │ │  │   │         └────────────────────┘              │  │ │ │  │   │           Volumes Persistentes              │  │ │ │  │   └─────────────────────────────────────────────┘  │ │ │  │                                                     │ │ │  │   SSH Port: 22 ◄──────────────────────────────────┼─┤ │  └────────────────────────────────────────────────────┘ │ │                                                          │ │  PowerShell/SSH Client                                   │ └─────────────────────────────────────────────────────────┘`

## 1.2. Stack Tecnológico

|Camada|Tecnologia|Versão Recomendada|Função|Base|
|---|---|---|---|---|
|**Hypervisor**|Microsoft Hyper-V|Windows 10/11 Pro|Virtualização|-|
|**Sistema Operacional**|Ubuntu Server|24.04.2 LTS|Base Linux|-|
|**Container Runtime**|Docker Engine|29.x|Orquestração de containers|-|
|**Orquestrador**|Docker Compose|5.x|Definição multi-container|-|
|**Banco de Dados**|PostgreSQL|**16** (Debian)|Repositório de identidades|**Debian**|
|**Aplicação IGA**|midPoint|**4.8** (Debian)|Governança de Identidades|**Debian**|

**⚠️ NOTA TÉCNICA v4.1:** Todas as imagens Docker utilizam base **Debian/Ubuntu** (não Alpine) para garantir compatibilidade total com ferramentas de diagnóstico (`psql`, `bash`, `netstat`, etc).

## 1.3. Requisitos de Hardware

|Recurso|Mínimo|Recomendado|Observação|
|---|---|---|---|
|**CPU**|2 cores|4 cores|Processador com suporte a virtualização (Intel VT-x/AMD-V)|
|**RAM**|4 GB|8 GB|midPoint + PostgreSQL + OS|
|**Disco**|40 GB|80 GB|SSD recomendado para performance|
|**Rede**|1 NIC|1 NIC|Acesso à internet obrigatório|

---

## 2. PRÉ-REQUISITOS E VALIDAÇÕES

## 2.1. Checklist de Pré-requisitos

Execute as validações abaixo **antes** de iniciar o procedimento:

powershell

`# VALIDAÇÃO 1: Hyper-V Instalado Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V # Resultado esperado: State = Enabled # VALIDAÇÃO 2: Virtualização Habilitada no BIOS Get-ComputerInfo | Select-Object -Property HyperVisorPresent, HyperVRequirementVirtualizationFirmwareEnabled # Resultado esperado: HyperVisorPresent = True, HyperVRequirementVirtualizationFirmwareEnabled = True # VALIDAÇÃO 3: Espaço em Disco Disponível Get-PSDrive C | Select-Object Used,Free # Resultado esperado: Free > 100 GB # VALIDAÇÃO 4: Conectividade com Internet Test-NetConnection -ComputerName releases.ubuntu.com -Port 443 # Resultado esperado: TcpTestSucceeded = True`

## 2.2. Instalação do Hyper-V (Se Necessário)

Se o Hyper-V não estiver habilitado:

powershell

`# Executar PowerShell como Administrador # Habilitar Hyper-V Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All # Reiniciar o computador Restart-Computer`

**ATENÇÃO:** Após reinicialização, validar novamente com os comandos da seção 2.1.

---

## 3. FASE 1 - PREPARAÇÃO DO AMBIENTE WINDOWS

## 3.1. Download da ISO do Ubuntu Server

powershell

`# Criar diretório para downloads New-Item -Path "C:\ISO" -ItemType Directory -Force # Abrir navegador para download manual Start-Process "https://releases.ubuntu.com/24.04.2/ubuntu-24.04.2-live-server-amd64.iso"`

**Ação Manual Requerida:**

1. Aguardar download completo do arquivo (~2.5 GB)
    
2. Salvar em `C:\ISO\ubuntu-24.04.2-live-server-amd64.iso`
    
3. Verificar integridade do arquivo (opcional mas recomendado)
    

## 3.2. Verificação de Integridade (Opcional)

powershell

`# Calcular SHA256 do arquivo baixado Get-FileHash -Path "C:\ISO\ubuntu-24.04.2-live-server-amd64.iso" -Algorithm SHA256 # Comparar com hash oficial em https://releases.ubuntu.com/24.04.2/SHA256SUMS`

## 3.3. Criar Virtual Switch no Hyper-V

powershell

`# Listar adaptadores de rede físicos Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Format-Table Name, InterfaceDescription, Status # Criar Virtual Switch Externo # Substitua "Ethernet" pelo nome real do seu adaptador New-VMSwitch -Name "External-Switch" -NetAdapterName "Ethernet" -AllowManagementOS $true # Validar criação Get-VMSwitch -Name "External-Switch"`

**Nota Técnica:** O Virtual Switch Externo permite que a VM tenha acesso à rede física e internet.

---

## 4. FASE 2 - CRIAÇÃO DA MÁQUINA VIRTUAL NO HYPER-V

## 4.1. Criação da VM via PowerShell

powershell

``# DEFINIR PARÂMETROS DA VM $VMName = "IGA-Server" $VMPath = "C:\Hyper-V\VMs" $VHDPath = "C:\Hyper-V\VHDs\$VMName.vhdx" $ISOPath = "C:\ISO\ubuntu-24.04.2-live-server-amd64.iso" $SwitchName = "External-Switch" $Memory = 8GB $CPUCount = 4 $VHDSize = 80GB # CRIAR ESTRUTURA DE DIRETÓRIOS New-Item -Path "C:\Hyper-V\VMs" -ItemType Directory -Force New-Item -Path "C:\Hyper-V\VHDs" -ItemType Directory -Force # CRIAR MÁQUINA VIRTUAL New-VM -Name $VMName `        -MemoryStartupBytes $Memory `       -Generation 2 `       -NewVHDPath $VHDPath `       -NewVHDSizeBytes $VHDSize `       -Path $VMPath `       -SwitchName $SwitchName # CONFIGURAR RECURSOS DA VM Set-VM -Name $VMName -ProcessorCount $CPUCount Set-VM -Name $VMName -AutomaticCheckpointsEnabled $false Set-VM -Name $VMName -CheckpointType Production # CONFIGURAR BOOT E SECURE BOOT # Desabilitar Secure Boot (compatibilidade com Linux) Set-VMFirmware -VMName $VMName -EnableSecureBoot Off # Adicionar ISO ao DVD Drive Add-VMDvdDrive -VMName $VMName -Path $ISOPath # Configurar ordem de boot $DVDDrive = Get-VMDvdDrive -VMName $VMName Set-VMFirmware -VMName $VMName -FirstBootDevice $DVDDrive # VALIDAR CONFIGURAÇÃO Get-VM -Name $VMName | Format-List``

## 4.2. Iniciar a VM

powershell

`# Iniciar a VM Start-VM -Name $VMName # Abrir console de conexão vmconnect.exe localhost $VMName`

---

## 5. FASE 3 - INSTALAÇÃO DO UBUNTU SERVER

## 5.1. Processo de Instalação Interativa

Siga o assistente de instalação do Ubuntu Server:

**1. Seleção de Idioma**

- Escolha: **English** (recomendado para compatibilidade)
    

**2. Installer Update**

- Se solicitado: **Continue without updating**
    

**3. Keyboard Configuration**

- Layout: Selecione conforme sua região
    

**4. Type of Install**

- Selecione: **Ubuntu Server (minimized)**
    

**5. Network Connections**

- Interface detectada automaticamente (ex: `eth0`, `ens33`, `enp0s3`)
    
- DHCP: Aceitar configuração automática
    
- **CRÍTICO:** Anotar o endereço IP atribuído (exemplo: `192.168.1.100`)
    

**6. Configure Proxy**

- Deixar em branco se não houver proxy
    
- Continuar com **Done**
    

**7. Ubuntu Archive Mirror**

- Aceitar padrão
    
- Continuar com **Done**
    

**8. Guided Storage Configuration**

- Selecionar: **Use an entire disk**
    
- **NÃO** selecionar "Set up this disk as an LVM group"
    
- Disco: `/dev/sda`
    
- Confirmar com **Done**
    

**9. Profile Setup (INFORMAÇÕES CRÍTICAS)**

text

`Your name: Seu nome completo Your server's name: iga-server Pick a username: seu-usuario Choose a password: senha-segura Confirm your password: senha-segura`

**⚠️ ATENÇÃO:** Anotar estas credenciais - serão usadas para acesso SSH

**10. SSH Setup**

- **MARCAR:** Install OpenSSH server
    
- Continuar com **Done**
    

**11. Featured Server Snaps**

- **NÃO** selecionar nenhum snap adicional
    
- Continuar com **Done**
    

**12. Installation Complete**

- Aguardar conclusão (5-10 minutos)
    
- Quando aparecer **Reboot Now**, aguardar ejeção automática do ISO
    

**13. Primeiro Boot**

- Fazer login com as credenciais criadas no passo 9
    

---

## 6. FASE 4 - CONFIGURAÇÃO PÓS-INSTALAÇÃO DO UBUNTU

## 6.1. Primeiro Acesso e Atualização do Sistema

bash

`# VALIDAR CONECTIVIDADE ip addr show ping -c 4 8.8.8.8 nslookup ubuntu.com # ATUALIZAR SISTEMA sudo apt update sudo apt upgrade -y sudo apt autoremove -y # Reiniciar se houver atualizações de kernel sudo reboot`

---

## 7. FASE 5 - HARDENING DE SEGURANÇA

## 5.1. Configurar IP Estático (Obrigatório)

## 🔍 ETAPA 0: Descoberta de Interface de Rede (NOVA v4.1)

**ANTES de editar qualquer arquivo Netplan, descubra o nome REAL da interface:**

bash

`# Listar interfaces de rede disponíveis ip link show`

**Saída esperada (exemplo):**

text

`1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00 2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000     link/ether 00:0c:29:3a:2f:1b brd ff:ff:ff:ff:ff:ff`

**📝 ANOTAR:** O nome da interface de rede (exemplos comuns):

- `eth0` (nomenclatura clássica)
    
- `ens33` (VMware/virtual)
    
- `enp0s3` (VirtualBox/Hyper-V)
    
- `ens160` (ESXi)
    

**⚠️ ATENÇÃO CRÍTICA v4.1:**  
**NUNCA** assuma que a interface é `eth0`. Use **SEMPRE** o nome exato retornado pelo comando `ip link show`. Nos passos seguintes, **substitua `eth0` pelo nome real** identificado aqui.

---

## ETAPA 1: Identificar Arquivo Netplan

bash

`ls -la /etc/netplan/`

**ATENÇÃO:** **NUNCA** assuma o nome do arquivo. Anote o nome **EXATO** retornado (ex: `00-installer-config.yaml`, `01-netcfg.yaml`, `50-cloud-init.yaml`)

---

## ✅ VALIDAÇÃO CRÍTICA - Gateway na Mesma Sub-rede

**ANTES de editar o Netplan, calcule a sub-rede:**

bash

`# Exemplo: IP xxx.xxx.xxx.xxx/24 # Sub-rede: xxx.xxx.xxx.xxx - xxx.xxx.xxx.xxx # Gateway DEVE estar entre xxx.xxx.xxx.xxx e xxx.xxx.xxx.xxx # ❌ ERRO COMUM (gateway fora da sub-rede): addresses: [xxx.xxx.xxx.xxx/24] via: 192.168.1.1  # ❌ ERRADO: 192.168.1.X fora da sub-rede 192.168.68.X # ✅ CORRETO (gateway na mesma sub-rede): addresses: [xxx.xxx.xxx.xxx/24] via: xxx.xxx.xxx.xxx  # ✅ Mesmo prefixo 192.168.68.X`

**Validação Pré-Aplicação:**

bash

`# 1. Descobrir gateway atual ip route | grep default # 2. Testar alcançabilidade do novo gateway ANTES de aplicar ping -c 1 xxx.xxx.xxx.xxx # 3. Se ping falhar → gateway está incorreto`

**Diagnóstico de Erro:**

Se após `netplan apply` aparecer:

text

`RTNETLINK answers: Network is unreachable`

**Causa:** Gateway fora da sub-rede  
**Solução:** Corrigir o arquivo Netplan com gateway correto e reaplicar

---

## ETAPA 2: Validar Conflito de IP no Windows

**No PowerShell do Windows:**

powershell

`Test-NetConnection -ComputerName IP_DESEJADO -InformationLevel Detailed # Se retornar PingSucceeded = False → IP disponível`

---

## ETAPA 3: Editar Arquivo Netplan

bash

`# Substitua NOME_DO_ARQUIVO pelo nome identificado na ETAPA 1 # Substitua INTERFACE_DE_REDE pelo nome identificado na ETAPA 0 sudo nano /etc/netplan/NOME_DO_ARQUIVO.yaml`

**Substitua o conteúdo por (ajuste conforme sua rede):**

text

`network:   version: 2  ethernets:    INTERFACE_DE_REDE:  # ⚠️ SUBSTITUIR por ens33, eth0, enp0s3, etc      dhcp4: false      addresses:        - xxx.xxx.xxx.xxx/24  # Ajustar conforme seu range      routes:        - to: default          via: xxx.xxx.xxx.xxx  # Gateway da sua rede (MESMA sub-rede do IP!)      nameservers:        addresses:          - 8.8.8.8          - 8.8.4.4`

**Exemplo com interface `ens33`:**

text

`network:   version: 2  ethernets:    ens33:      dhcp4: false      addresses:        - xxx.xxx.xxx.xxx/24      routes:        - to: default          via: xxx.xxx.xxx.xxx      nameservers:        addresses:          - 8.8.8.8          - 8.8.4.4`

---

## ⚠️ ALERTA OPERACIONAL CRÍTICO - LOCKOUT SSH (v4.1 REFORÇADO)

**COMPORTAMENTO ESPERADO AO APLICAR NETPLAN VIA SSH:**

Ao executar `sudo netplan apply` via conexão SSH:

1. **A interface de rede será reinicializada**
    
2. **Sua sessão SSH será DESCONECTADA IMEDIATAMENTE**
    
3. **Você verá a mensagem: `client_loop: send disconnect: Connection reset`**
    

**🟢 ISSO É NORMAL E ESPERADO - NÃO É UMA FALHA**

A desconexão SSH é um **sinal de que a configuração está sendo processada corretamente**. A interface de rede precisa ser reiniciada para aplicar o novo IP estático.

---

**Procedimento de Recuperação:**

1. **Aguarde 30 segundos** após a desconexão (tempo para interface reiniciar)
    
2. **NÃO entre em pânico** - o servidor está processando a mudança
    
3. Tente restabelecer a conexão com o **NOVO IP**:
    
    bash
    
    `ssh usuario@xxx.xxx.xxx.xxx  # Usar IP configurado no Netplan`
    
4. **Se o SSH não responder após 60 segundos:**
    
    - Acesse pelo **Console do Hyper-V** (vmconnect)
        
    - Valide o IP aplicado: `ip addr show INTERFACE_DE_REDE`
        
    - Verifique conectividade: `ping -c 4 8.8.8.8`
        
    - Verifique rotas: `ip route`
        

---

**Mitigação Recomendada para Administradores:**

- ✅ **SEMPRE** tenha o Console do Hyper-V aberto em paralelo antes de aplicar Netplan
    
- ✅ **OU**: Execute a configuração de rede diretamente pelo Console (não via SSH)
    
- ✅ **OU**: Use ferramentas de automação que suportem reconexão automática
    

---

**Mensagens de Sucesso (após reconexão):**

bash

`# Validar IP aplicado ip addr show ens33  # Substituir pelo nome da sua interface # Esperado: inet xxx.xxx.xxx.xxx/24 # Validar gateway ip route # Esperado: default via xxx.xxx.xxx.xxx dev ens33 proto static # Validar conectividade ping -c 4 8.8.8.8 # Esperado: 4 packets transmitted, 4 received`

---

## ETAPA 4: Aplicar e Validar

bash

`sudo netplan apply # ⚠️ ESPERE DESCONEXÃO SSH (comportamento normal) # Após reconexão, validar: ip addr show INTERFACE_DE_REDE  # Substituir pelo nome real ping -c 4 8.8.8.8`

---

## ✅ VALIDAÇÃO ADICIONAL - Protocolo de Rota

Após `sudo netplan apply` e reconexão, valide que o protocolo mudou para `static`:

bash

`# Verificar protocolo da rota ip route # ✅ ESPERADO (estático configurado corretamente): default via xxx.xxx.xxx.xxx dev ens33 proto static # ⚠️ ATENÇÃO (DHCP residual - requer limpeza): default via xxx.xxx.xxx.xxx dev ens33 proto dhcp`

**Se aparecer `proto dhcp`, executar limpeza:**

bash

`sudo ip addr flush dev INTERFACE_DE_REDE  # Substituir pelo nome real sudo netplan apply ip route  # Validar novamente`

---

## ETAPA 5: Documentar IP e Interface

bash

`echo "IP Estático da VM: $(hostname -I | awk '{print $1}')" > network-info.txt echo "Interface de Rede: $(ip route | grep default | awk '{print $5}')" >> network-info.txt cat network-info.txt`

---

## 7.2. Configurar Sudoers Hardened (Least Privilege)

bash

`# Editar sudoers com visudo sudo visudo`

**Adicionar WHITELIST no final do arquivo:**

text

`# Substitua "seu-usuario" pelo seu usuário real seu-usuario ALL=(ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/chown, /usr/bin/docker, /usr/bin/du, /usr/bin/rm, /usr/bin/whoami`

**Salvar e sair:** Ctrl+X, Y, Enter

**Validar configuração:**

bash

`sudo -l # Esperado:  # User seu-usuario may run the following commands on iga-server: #     (ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/chown, /usr/bin/docker, /usr/bin/du, /usr/bin/rm, /usr/bin/whoami`

**Conformidade de Segurança:**

- **ISO 27001:2022** A.9.2.3 - Gestão de Privilégios de Acesso
    
- **NIST CSF 2.0** PR.AC-4 - Princípio do Menor Privilégio
    
- **CIS Controls v8** 5.4 - Restrição de Privilégios Administrativos
    

---

## 8. FASE 6 - INSTALAÇÃO DO DOCKER E DOCKER COMPOSE

## 6.1. Instalação do Docker Engine

bash

`# PREPARAR AMBIENTE sudo apt remove -y docker docker-engine docker.io containerd runc sudo apt update sudo apt install -y ca-certificates curl gnupg lsb-release # ADICIONAR REPOSITÓRIO OFICIAL DO DOCKER sudo install -m 0755 -d /etc/apt/keyrings curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg sudo chmod a+r /etc/apt/keyrings/docker.gpg echo \   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null # INSTALAR DOCKER sudo apt update sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin # VALIDAR INSTALAÇÃO docker --version docker compose version sudo docker run hello-world # Resultado Esperado: "Hello from Docker! This message shows that your installation appears to be working correctly."`

## 6.2. Configurar Docker para Inicializar com o Sistema

bash

`sudo systemctl enable docker sudo systemctl start docker sudo systemctl status docker # Esperado: active (running)`

---

## 6.3. Política de Privilégios Docker

## 🔒 TODOS os comandos Docker neste POP exigem `sudo`:

bash

`# ❌ ERRADO (comando falhará com "permission denied"): docker compose up -d docker ps docker logs iga-midpoint # ✅ CORRETO (conforme hardening de segurança): sudo docker compose up -d sudo docker ps sudo docker logs iga-midpoint`

## Justificativa de Segurança (GRC):

|Princípio|Norma|Como Atende|
|---|---|---|
|**Menor Privilégio**|ISO 27001:2022 A.9.2.3|Usuário não tem acesso direto ao daemon Docker|
|**Auditabilidade**|NIST CSF 2.0 PR.PT-1|Comandos registrados em `/var/log/auth.log`|
|**Não-Repúdio**|CIS Controls v8 8.2|Timestamp e usuário rastreável por sudo|

## ⚠️ Por que NÃO adicionar ao grupo docker:

- ❌ Risco de escalação de privilégio (usuário vira root efetivo)
    
- ❌ Perde rastreabilidade de quem executou o comando
    
- ❌ Viola princípio de segregação de funções
    

---

## 9. FASE 7 - PREPARAÇÃO DA ESTRUTURA DO PROJETO IGA

## 7.1. Criar Estrutura de Diretórios

bash

`# CRIAR DIRETÓRIO RAIZ DO PROJETO sudo mkdir -p /srv/iga-project sudo chown -R $USER:$USER /srv/iga-project # CRIAR SUBDIRETÓRIOS mkdir -p /srv/iga-project/data/postgres mkdir -p /srv/iga-project/data/midpoint/var mkdir -p /srv/iga-project/logs/midpoint mkdir -p /srv/iga-project/config mkdir -p /srv/iga-project/backups mkdir -p /srv/iga-project/evidencias # VALIDAR ESTRUTURA tree /srv/iga-project -L 2 # Ou (se tree não estiver instalado): ls -lR /srv/iga-project`

---

## 7.2. Criar Arquivo docker-compose.yml (Sintaxe Oficial v4.1)

bash

`cd /srv/iga-project nano docker-compose.yml`

**Copiar EXATAMENTE o conteúdo abaixo:**

text

`version: '3.8' services:   postgres:    image: postgres:16  # ⚠️ v4.1: Debian (NÃO Alpine) para compatibilidade total    container_name: iga-postgres    environment:      POSTGRES_DB: ${POSTGRES_DB}      POSTGRES_USER: ${POSTGRES_USER}      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}    volumes:      - ./data/postgres:/var/lib/postgresql/data    networks:      - iga-network    healthcheck:      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]      interval: 10s      timeout: 5s      retries: 5    restart: unless-stopped   midpoint:    image: evolveum/midpoint:4.8  # ⚠️ v4.1: Debian (NÃO Alpine) para compatibilidade total    container_name: iga-midpoint    ports:      - "8080:8080"    environment:      # 🔒 TRAVA ANTI-H2 (obrigatória - previne fallback silencioso)      MP_SET_midpoint.repository.embedded: "false"             # Configuração de Banco de Dados      MP_SET_midpoint.repository.database: postgresql      MP_SET_midpoint.repository.jdbcUrl: jdbc:postgresql://postgres:5432/${POSTGRES_DB}      MP_SET_midpoint.repository.jdbcUsername: ${POSTGRES_USER}      MP_SET_midpoint.repository.jdbcPassword: ${POSTGRES_PASSWORD}             # 🔒 TRAVA DE VERSÃO (previne busca de scripts legados)      MP_SET_midpoint.repository.schemaVersion: "4.8"             # Senha do Administrador      MP_SET_midpoint.administrator.initialPassword: ${MIDPOINT_ADMIN_PASSWORD}    volumes:      - ./data/midpoint/var:/opt/midpoint/var      - ./logs/midpoint:/opt/midpoint/var/log    depends_on:      postgres:        condition: service_healthy    networks:      - iga-network    restart: unless-stopped networks:   iga-network:    driver: bridge`

**Validar sintaxe:**

bash

`sudo docker compose config`

---

## 📝 NOTAS TÉCNICAS v4.1

**1. Por que usar `postgres:16` (Debian) em vez de `postgres:16-alpine`:**

|Aspecto|postgres:16 (Debian)|postgres:16-alpine|
|---|---|---|
|**Ferramentas de diagnóstico**|✅ `psql`, `pg_dump`, `bash`, `netstat`|❌ Limitadas (sh, sem bash)|
|**Compatibilidade**|✅ Total com scripts padrão|⚠️ Pode ter problemas com binários|
|**Tamanho da imagem**|~350 MB|~200 MB|
|**Uso em produção**|✅ Recomendado para ambientes críticos|⚠️ Apenas para ambientes minimalistas|
|**Troubleshooting**|✅ Ferramentas completas disponíveis|❌ Ferramentas limitadas|

**Justificativa v4.1:** Para ambientes de aprendizado e produção crítica (GRC/IGA), a diferença de ~150MB não justifica a perda de ferramentas de diagnóstico.

---

**2. Importância de `embedded: "false"`:**

- Sem esta configuração, midPoint faz fallback silencioso para H2 se houver latência no PostgreSQL
    
- Sistema sobe "healthy" mas usa banco errado (H2 em vez de PostgreSQL)
    
- Trava força "Fail Fast" (falha imediata se PostgreSQL não estiver disponível)
    

**3. Importância de `schemaVersion: "4.8"`:**

- Previne que midPoint busque scripts de versões antigas (ex: 4.6)
    
- Garante consistência entre imagem Docker e schema do banco
    
- Evita erro: "Attempting to create database tables from file 'postgresql-4.6-all.sql'"
    

---

## 7.3. Criar Arquivo .env com Proteção de Caracteres Especiais

bash

`# CRIAR TEMPLATE DO ARQUIVO .env cat > /srv/iga-project/.env.template <<'EOF' # ============================================================ # CONFIGURAÇÕES DO AMBIENTE IGA v4.1 # ============================================================ # 🔐 POLÍTICA DE SEGREDOS (LEIA ANTES DE EDITAR) # # ❌ PROIBIÇÕES ABSOLUTAS: # 1. NÃO use aspas simples ou duplas # 2. NÃO use o caractere cifrão ($) # 3. NÃO use espaços em branco # # ✅ FORMATO CORRETO: # POSTGRES_PASSWORD=P0stgr3sS3cur3#2026! # # ❌ FORMATO ERRADO: # POSTGRES_PASSWORD='P0stgr3sS3cur3#2026!'  (tem aspas) # POSTGRES_PASSWORD=P@$$w0rd  (tem cifrão) # # ============================================================ # CREDENCIAIS DO POSTGRESQL POSTGRES_DB=midpoint POSTGRES_USER=midpoint POSTGRES_PASSWORD=SuaSenhaPostgreSQLAqui # CREDENCIAIS DO MIDPOINT # Usuário de login: administrator # Senha: valor abaixo MIDPOINT_ADMIN_PASSWORD=SuaSenhaMidPointAqui # ============================================================ # NOTAS DE SEGURANÇA # - Use senhas fortes (mínimo 16 caracteres) # - Combine letras maiúsculas, minúsculas, números e símbolos # - Caracteres permitidos: @ # ! % & * - _ + = # ============================================================ EOF # Copiar template para arquivo real cp /srv/iga-project/.env.template /srv/iga-project/.env`

---

## 7.3.1. Política de Sintaxe de Segredos (CRÍTICO)

## ❌ PROIBIÇÕES ABSOLUTAS

**1. Caractere Cifrão (`$`):**

bash

`# ❌ ERRADO: Docker tenta expandir como variável POSTGRES_PASSWORD=P@$$w0rd2026 # ✅ CORRETO: Substituir $ por outro símbolo POSTGRES_PASSWORD=P@ssw0rd2026#`

**2. Aspas Simples ou Duplas:**

bash

`# ❌ ERRADO: Aspas são lidas literalmente pelo JDBC POSTGRES_PASSWORD='P@ssw0rd!' POSTGRES_PASSWORD="P@ssw0rd!" # ✅ CORRETO: Sem aspas POSTGRES_PASSWORD=P@ssw0rd!`

---

## ✅ CARACTERES PERMITIDOS

- Letras maiúsculas: **A-Z**
    
- Letras minúsculas: **a-z**
    
- Números: **0-9**
    
- Símbolos especiais: **`@#!%&*-_+=`**
    

---

## 📝 EXEMPLO DE .env VÁLIDO

bash

`POSTGRES_DB=midpoint POSTGRES_USER=midpoint POSTGRES_PASSWORD=P0stgr3sS3cur3#2026! MIDPOINT_ADMIN_PASSWORD=M1dP0!ntAdm!n2026`

---

## ⚠️ ATENÇÃO DE AUDITORIA

**Senhas que violarem estas regras causarão:**

- ❌ Erro SCRAM no PostgreSQL (autenticação falhará)
    
- ❌ Fallback silencioso para H2 (se `embedded` não estiver `false`)
    
- ❌ Perda de rastreabilidade de dados
    

---

## 7.3.2. Editar e Proteger o Arquivo .env

bash

`# EDITAR ARQUIVO .env nano /srv/iga-project/.env # AÇÃO MANUAL OBRIGATÓRIA: # 1. Substituir os placeholders MANTENDO o formato sem aspas: #    - SuaSenhaPostgreSQLAqui → P0stgr3sS3cur3#2026! #    - SuaSenhaMidPointAqui → M1dP0!ntAdm!n2026 # # 2. Salvar: Ctrl+X, Y, Enter`

**Exemplo de .env Completo:**

bash

`POSTGRES_DB=midpoint POSTGRES_USER=midpoint POSTGRES_PASSWORD=P0stgr3sS3cur3#2026! MIDPOINT_ADMIN_PASSWORD=M1dP0!ntAdm!n2026`

---

## 7.3.3. Proteger Arquivo e Criar .gitignore

bash

`# PROTEGER ARQUIVO .env chmod 600 /srv/iga-project/.env ls -la /srv/iga-project/.env # Esperado: -rw------- # CRIAR .gitignore cat > /srv/iga-project/.gitignore <<'EOF' .env data/ logs/ backups/ evidencias/ EOF`

---

## 10. FASE 8 - DEPLOY DO AMBIENTE IGA

## 8.1. Validações Pré-Deploy (Gate de Início)

bash

`cd /srv/iga-project # VALIDAÇÃO 1: Conectividade Externa ping -c 4 8.8.8.8 # Esperado: 4 packets transmitted, 4 received # VALIDAÇÃO 2: Resolução DNS nslookup registry-1.docker.io # Esperado: endereço IP válido # VALIDAÇÃO 3: Docker Funcional sudo docker ps # Esperado: listagem vazia # VALIDAÇÃO 4: Arquivo .env Configurado cat .env | grep -v '^#' | grep -v '^$' # Esperado: 4 linhas SEM aspas # VALIDAÇÃO 5: docker-compose.yml Válido sudo docker compose config # Esperado: configuração renderizada # VALIDAÇÃO 6: IP Estático Confirmado ip addr show | grep inet | grep -v '127.0.0.1' # Esperado: inet xxx.xxx.xxx.xxx/XX (não deve ser DHCP) # VALIDAÇÃO 7: Sudoers Hardened sudo -l | grep -E "mkdir|chown|docker|du|rm|whoami" # Esperado: whitelist com caminhos completos`

**🛑 GATE DE INÍCIO:**  
Se **qualquer** validação falhar, **NÃO prosseguir** com o deploy.

---

## 8.2. Deploy Sequencial com Validação Tripla

## 🚨 ETAPA 0: GARANTIA DE ESTADO ZERO (PURGE) - OBRIGATÓRIO v4.1

**⚠️ ATENÇÃO CRÍTICA:** Esta etapa é **MANDATÓRIA** antes de qualquer deploy ou tentativa de reinicialização.

**Por que este passo é obrigatório:**

PostgreSQL 16 grava a senha inicial no volume `/var/lib/postgresql/data` durante a **primeira inicialização** do container. Se o volume já existir com configurações anteriores:

- ✅ PostgreSQL **IGNORA** as novas variáveis de ambiente do `.env`
    
- ✅ PostgreSQL **MANTÉM** a senha antiga gravada no volume
    
- ✅ Resultado: Erro SCRAM `password authentication failed`
    

**O PostgreSQL só assume senhas do .env em volumes virgens (vazios).**

---

**Comando de Purge Obrigatório:**

bash

`# 1. Parar containers se existirem cd /srv/iga-project sudo docker compose down -v # 2. LIMPAR VOLUMES DE DADOS (CRÍTICO - NÃO PULE ESTE PASSO) sudo rm -rf /srv/iga-project/data/postgres/* sudo rm -rf /srv/iga-project/data/midpoint/var/* # 3. Validar limpeza (OBRIGATÓRIO) ls -la /srv/iga-project/data/postgres/ # ✅ ESPERADO: Vazio (total 8) # ❌ FALHA: Se aparecer arquivos/diretórios → repetir rm -rf ls -la /srv/iga-project/data/midpoint/var/ # ✅ ESPERADO: Vazio (total 8) # ❌ FALHA: Se aparecer arquivos/diretórios → repetir rm -rf`

---

**Quando executar o Purge:**

- ✅ **SEMPRE** antes de nova tentativa de deploy
    
- ✅ Após mudança de senhas no `.env`
    
- ✅ Após rollback de GMUD
    
- ✅ Após erro SCRAM de autenticação
    
- ✅ Após detecção de fallback para H2
    
- ✅ Após qualquer erro de inicialização do PostgreSQL
    

---

**Sintomas de volume envenenado (Purge NÃO executado):**

text

`# Logs do PostgreSQL mostrarão: PostgreSQL Database directory appears to contain a database; Skipping initialization # Logs do midPoint mostrarão: SCRAM authentication failed for user "midpoint" password authentication failed for user "midpoint"`

**Se estes erros aparecerem:** PARE, execute o Purge e reinicie o deploy.

---

**Conformidade GRC:**

|Controle|Norma|Implementação|
|---|---|---|
|**Baseline Conhecida**|ISO 27001:2022 A.12.1.2|Purge garante estado zero documentado|
|**Integridade de Dados**|NIST CSF 2.0 PR.DS-1|Evita corrupção por credenciais inconsistentes|
|**Rastreabilidade**|CIS Controls v8 3.12|Logs mostram apenas tentativas com credenciais corretas|

---

## ETAPA 1: Inicializar PostgreSQL

bash

`echo "Iniciando PostgreSQL..." sudo docker compose up -d postgres # Acompanhar logs em tempo real sudo docker logs -f iga-postgres`

**AGUARDAR até aparecer 2x:**

text

`database system is ready to accept connections`

**Pressionar Ctrl+C após a segunda ocorrência**

---

## ETAPA 2: Validar Health Check do PostgreSQL

bash

`sleep 5 sudo docker inspect iga-postgres | grep -A 5 '"Health"' # Esperado: "Status": "healthy" sudo docker exec iga-postgres psql -U midpoint -d midpoint -c "SELECT version();" # Esperado: PostgreSQL 16.x`

---

## ETAPA 3: Aguardar Estabilização

bash

`echo "PostgreSQL healthy. Aguardando 10 segundos..." sleep 10`

---

## ETAPA 4: Inicializar midPoint

bash

`echo "Iniciando midPoint..." sudo docker compose up -d midpoint # Acompanhar logs em tempo real sudo docker logs -f iga-midpoint`

**MENSAGENS CRÍTICAS A OBSERVAR:**

1. ✅ `MP configuration property: midpoint.repository.database = postgresql`
    
2. ✅ `MP configuration property: midpoint.repository.embedded = false`
    
3. ✅ `Connection to database successful`
    
4. ✅ `Attempting to create database tables from file 'postgresql-4.8-all.sql'`
    
5. ✅ `Created User:administrator`
    
6. ✅ `Server startup in XXXX milliseconds`
    

**Pressionar Ctrl+C após "Server startup"**

---

## ETAPA 5: VALIDAÇÃO TRIPLA DE REPOSITÓRIO (CHECKPOINT CRÍTICO)

**Este teste tem 3 checkpoints obrigatórios:**

## Checkpoint 5.1 - Variáveis de Ambiente

bash

`echo "=== CHECKPOINT 5.1: Variáveis Injetadas ===" > /srv/iga-project/evidencias/repository-validation.txt sudo docker exec iga-midpoint env | grep MP_SET_midpoint.repository >> /srv/iga-project/evidencias/repository-validation.txt`

**✅ ESPERADO (todas as linhas devem aparecer):**

text

`MP_SET_midpoint.repository.embedded=false MP_SET_midpoint.repository.database=postgresql MP_SET_midpoint.repository.jdbcUrl=jdbc:postgresql://postgres:5432/midpoint MP_SET_midpoint.repository.jdbcUsername=midpoint MP_SET_midpoint.repository.jdbcPassword=P0stgr3sS3cur3#2026! MP_SET_midpoint.repository.schemaVersion=4.8`

---

## Checkpoint 5.2 - Logs de Bootstrap

bash

`echo "=== CHECKPOINT 5.2: Tipo de Repositório nos Logs ===" >> /srv/iga-project/evidencias/repository-validation.txt sudo docker logs iga-midpoint 2>&1 | grep "repository.database" >> /srv/iga-project/evidencias/repository-validation.txt sudo docker logs iga-midpoint 2>&1 | grep "repository.embedded" >> /srv/iga-project/evidencias/repository-validation.txt`

**✅ ESPERADO:**

text

`midpoint.repository.database .:. postgresql midpoint.repository.embedded .:. false`

**❌ FALHA CRÍTICA (se aparecer):**

text

`midpoint.repository.database .:. h2`

---

## Checkpoint 5.3 - Query SQL Direta

bash

`echo "=== CHECKPOINT 5.3: Conexão PostgreSQL Ativa ===" >> /srv/iga-project/evidencias/repository-validation.txt sudo docker exec iga-postgres psql -U midpoint -d midpoint -c "\dt" 2>&1 | head -10 >> /srv/iga-project/evidencias/repository-validation.txt`

**✅ ESPERADO (tabelas PostgreSQL existem):**

text

 `public | m_user      | table | midpoint public | m_role      | table | midpoint public | m_object    | table | midpoint`

---

## Exibir Resultado Consolidado

bash

`# Exibir resultado cat /srv/iga-project/evidencias/repository-validation.txt`

---

**🚨 GATE DE FALHA:**

Se **QUALQUER** checkpoint falhar:

1. ❌ **NÃO prosseguir** com a GMUD
    
2. Executar rollback imediato (ETAPA 0 - Purge)
    
3. Investigar causa raiz:
    
    - Aspas no `.env`?
        
    - Variável `embedded: false` ausente?
        
    - Volume NÃO foi limpo (Purge não executado)?
        
    - Caractere `$` na senha?
        

---

## ETAPA 6: Validar Containers

bash

`sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"`

**Esperado:**

text

`NAMES           STATUS              PORTS iga-midpoint    Up X minutes        0.0.0.0:8080->8080/tcp iga-postgres    Up X minutes (healthy)`

---

## ETAPA 7: Salvar Logs Completos

bash

`sudo docker logs iga-postgres > /srv/iga-project/evidencias/postgres-bootstrap.log 2>&1 sudo docker logs iga-midpoint > /srv/iga-project/evidencias/midpoint-bootstrap.log 2>&1`

---

## 8.3. Aguardar Estabilização da Aplicação

bash

`echo "Aguardando estabilização completa (120 segundos)..." sleep 120 # Testar endpoint HTTP curl -I http://localhost:8080/midpoint # Esperado: HTTP/1.1 200 ou 302 # Salvar evidência curl -v http://localhost:8080/midpoint > /srv/iga-project/evidencias/http-response.txt 2>&1`

---

## 11. FASE 9 - VALIDAÇÃO E TESTES

## 9.1. Testes Internos (Dentro da VM)

bash

`# TESTE 1: Containers Rodando sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" # TESTE 2: Logs Sem Erros Críticos sudo docker logs iga-postgres 2>&1 | grep -i 'error\|fatal' | wc -l sudo docker logs iga-midpoint 2>&1 | grep -i 'error\|fatal' | grep -v 'ErrorPage' | wc -l # Esperado: 0 para ambos # TESTE 3: Verificar Tipo de Repositório (já realizado na ETAPA 5) # Ver seção 10 - ETAPA 5: VALIDAÇÃO TRIPLA DE REPOSITÓRIO # TESTE 4: Conectividade com Banco sudo docker exec iga-midpoint /bin/bash -c "timeout 5 bash -c '</dev/tcp/postgres/5432' && echo 'PostgreSQL alcançável' || echo 'Falha'" # TESTE 5: Portas Abertas sudo netstat -tulpn | grep -E "8080|5432" # Esperado: # tcp6 ... :8080 ... LISTEN # tcp ... :5432 ... LISTEN # TESTE 6: Persistência de Dados ls -lh /srv/iga-project/data/postgres ls -lh /srv/iga-project/data/midpoint/var # Esperado: diretórios com arquivos`

---

## 9.2. Obter IP da VM para Acesso Externo

bash

`IP_VM=$(hostname -I | awk '{print $1}') echo "Endereço IP da VM: $IP_VM" echo "URL de Acesso: http://$IP_VM:8080/midpoint" # Salvar informações de acesso cat > /srv/iga-project/ACCESS-INFO.txt <<EOF ============================================== INFORMAÇÕES DE ACESSO - IGA ============================================== URL: http://$IP_VM:8080/midpoint Usuário: administrator Senha: Conforme .env (MIDPOINT_ADMIN_PASSWORD) Tipo de Repositório: PostgreSQL (validado) Data do Deploy: $(date) ============================================== EOF cat /srv/iga-project/ACCESS-INFO.txt`

---

## 9.3. Teste de Acesso Web (Do Windows Host)

**Executar no PowerShell do Windows:**

powershell

`# Substituir pelo IP real da VM $VM_IP = "xxx.xxx.xxx.xxx" # Testar alcançabilidade Test-NetConnection -ComputerName $VM_IP -Port 8080 # Esperado: TcpTestSucceeded = True # Testar resposta HTTP Invoke-WebRequest -Uri "http://$VM_IP:8080/midpoint" -UseBasicParsing | Select-Object StatusCode # Esperado: StatusCode = 200`

---

## 9.4. Teste de Login na Interface Web

**Ação Manual Obrigatória:**

1. Abrir navegador no Windows
    
2. Acessar `http://xxx.xxx.xxx.xxx:8080/midpoint`
    
3. Na tela de login:
    
    - Usuário: `administrator`
        
    - Senha: Valor definido no `.env` (MIDPOINT_ADMIN_PASSWORD)
        
4. Clicar em **Sign In**
    

**Resultado Esperado:**

- ✅ Acesso concedido
    
- ✅ Dashboard do midPoint exibido
    
- ✅ Menu lateral funcional
    

---

## 9.5. Teste de Persistência

bash

`# Parar containers sudo docker compose down sleep 10 # Reiniciar sudo docker compose up -d sleep 60 # Validar dados persistiram sudo docker exec iga-postgres psql -U midpoint -d midpoint -c "SELECT COUNT(*) FROM m_user;" # Esperado: count = 1 (administrator existe)`

---

## 12. FASE 10 - CHECKLIST DE BASELINE DE SEGURANÇA

## 📋 Checklist de Validação Final (v4.1)

Execute este checklist **ANTES de encerrar a GMUD** para garantir conformidade com baseline de segurança e evitar rollbacks futuros.

---

## ✅ ITEM 1: Interface de Rede Validada?

bash

`# Validar nome real da interface descoberto na Fase 5 ip link show | grep -E "state UP" # Esperado: Mostrar interface configurada (ens33, eth0, enp0s3, etc) # Validar IP estático aplicado ip addr show $(ip route | grep default | awk '{print $5}') # Esperado: inet xxx.xxx.xxx.xxx/24 (seu IP configurado) # Validar protocolo de rota ip route | grep default # Esperado: "proto static" (NÃO "proto dhcp") # Validar gateway alcançável ping -c 1 $(ip route | grep default | awk '{print $3}') # Esperado: 1 packets transmitted, 1 received`

**❌ Se falhar:** Retornar à Fase 5.1 e corrigir configuração Netplan

---

## ✅ ITEM 2: Volumes Limpos (Estado Zero Garantido)?

bash

`# Validar que o Purge foi executado ANTES do deploy # Verificar timestamp de criação dos arquivos PostgreSQL ls -lat /srv/iga-project/data/postgres/ | head -5 # Todos os arquivos devem ter timestamp APÓS a execução da ETAPA 0 # Se houver arquivos com timestamp antigo → Volume NÃO foi limpo # Validar tamanho do volume PostgreSQL du -sh /srv/iga-project/data/postgres/ # Esperado: ~100-200MB (novo deployment) # ⚠️ Se > 500MB: pode haver dados de tentativas anteriores`

**❌ Se falhar:** Executar Purge (Fase 8.2 - ETAPA 0) e reiniciar deploy

---

## ✅ ITEM 3: Senhas Sem Aspas e Sem Cifrão ($)?

bash

`# Validar formato do arquivo .env cat /srv/iga-project/.env # VERIFICAR MANUALMENTE: # ✅ CORRETO: # POSTGRES_PASSWORD=P0stgr3sS3cur3#2026! # ❌ ERRADO (aspas): # POSTGRES_PASSWORD='P0stgr3sS3cur3#2026!' # POSTGRES_PASSWORD="P0stgr3sS3cur3#2026!" # ❌ ERRADO (cifrão): # POSTGRES_PASSWORD=P@$$w0rd # Validar que senha foi injetada corretamente no container sudo docker exec iga-midpoint env | grep MP_SET_midpoint.repository.jdbcPassword # Esperado: MP_SET_midpoint.repository.jdbcPassword=P0stgr3sS3cur3#2026! # ❌ FALHA: Se aparecer aspas literais ou cifrão não expandido`

**❌ Se falhar:** Corrigir `.env` (Fase 7.3.1), executar Purge e reiniciar

---

## ✅ ITEM 4: Gateway Alcançável e DNS Configurado?

bash

`# Validar gateway GATEWAY=$(ip route | grep default | awk '{print $3}') echo "Gateway configurado: $GATEWAY" ping -c 3 $GATEWAY # Esperado: 3 packets transmitted, 3 received # Validar DNS cat /etc/netplan/*.yaml | grep -A 2 "nameservers" # Esperado: 8.8.8.8 e 8.8.4.4 (ou DNS da sua rede) # Testar resolução DNS nslookup google.com nslookup registry-1.docker.io # Esperado: Retornar IP válido # Validar conectividade externa ping -c 3 8.8.8.8 # Esperado: 3 packets transmitted, 3 received`

**❌ Se falhar:** Retornar à Fase 5.1 e corrigir Netplan (gateway/DNS)

---

## ✅ ITEM 5: Validação Tripla de Repositório Aprovada?

bash

`# Verificar arquivo de evidência gerado na ETAPA 5 cat /srv/iga-project/evidencias/repository-validation.txt # DEVE CONTER (3 checkpoints aprovados): # 1. MP_SET_midpoint.repository.embedded=false # 2. midpoint.repository.database .:. postgresql # 3. Tabelas PostgreSQL (m_user, m_role, m_object) # Teste adicional: confirmar que midPoint NÃO está usando H2 sudo docker logs iga-midpoint 2>&1 | grep -i "h2" | grep -v "SHA-2" # Esperado: Nenhuma linha relacionada a banco H2 # Teste adicional: confirmar conexão JDBC ativa sudo docker exec iga-postgres psql -U midpoint -d midpoint -c "SELECT COUNT(*) FROM m_user;" # Esperado: count = 1 (usuário administrator criado)`

**❌ Se falhar:** Investigar causa raiz (aspas, embedded, volume), executar Purge e reiniciar

---

## 📊 Resumo do Checklist

|Item|Status|Ação se Falhar|
|---|---|---|
|1. Interface de rede validada|☐|Retornar Fase 5.1 (Netplan)|
|2. Volumes limpos (Purge executado)|☐|Executar ETAPA 0 + redeploy|
|3. Senhas sem aspas/cifrão|☐|Corrigir `.env` + Purge + redeploy|
|4. Gateway/DNS alcançável|☐|Retornar Fase 5.1 (Netplan)|
|5. Validação Tripla aprovada|☐|Troubleshooting + Purge + redeploy|

---

## 🔒 Conformidade GRC - Fase 10

|Controle|Norma|Implementação|
|---|---|---|
|**Baseline de Segurança**|ISO 27001:2022 A.12.1.2|Checklist documentado e rastreável|
|**Integridade de Configuração**|NIST CSF 2.0 PR.IP-1|Validação de 5 pontos críticos|
|**Auditoria de Deployment**|CIS Controls v8 4.1|Evidências armazenadas em `/evidencias/`|

---

**✅ SE TODOS OS 5 ITENS ESTIVEREM APROVADOS:**  
Ambiente IGA está em conformidade com baseline de segurança e pronto para uso.

**❌ SE QUALQUER ITEM FALHAR:**  
NÃO prosseguir. Corrigir a falha, executar Purge (se necessário) e validar novamente.

---

## 13. TROUBLESHOOTING E DIAGNÓSTICOS

## 13.1. Problema: midPoint Usando H2 ao Invés de PostgreSQL

**Sintoma:** Login falha, logs mostram `h2` ao invés de `postgresql`

**Causa Raiz:** Variável `embedded: "false"` ausente ou fallback por erro de conexão

**Solução:**

bash

`# 1. Parar ambiente sudo docker compose down -v # 2. Limpar dados do H2 (EXECUTAR PURGE COMPLETO) sudo rm -rf /srv/iga-project/data/midpoint/var/* sudo rm -rf /srv/iga-project/data/postgres/* # 3. Verificar docker-compose.yml cat docker-compose.yml | grep -A 10 "midpoint:" | grep embedded # Esperado: MP_SET_midpoint.repository.embedded: "false" # 4. Verificar .env cat .env # Esperado: valores SEM aspas # 5. Reiniciar sudo docker compose up -d # 6. Validar sudo docker logs iga-midpoint 2>&1 | grep "repository.database" # Esperado: postgresql`

---

## 13.2. Problema: Erro SCRAM - password authentication failed

**Sintoma:** PostgreSQL rejeita conexão do midPoint

**Causa Raiz:** Caracteres especiais na senha interpretados incorretamente ou **volume envenenado (Purge NÃO executado)**

**Solução:**

bash

`# 1. Verificar .env cat .env | grep POSTGRES_PASSWORD # ❌ ERRADO: POSTGRES_PASSWORD='Pssw0rd!'  # Tem aspas POSTGRES_PASSWORD=P@$$w0rd    # Tem cifrão # ✅ CORRETO: POSTGRES_PASSWORD=P@ssw0rd!   # Sem aspas, sem cifrão # 2. Se .env estiver correto, EXECUTAR PURGE OBRIGATÓRIO sudo docker compose down -v sudo rm -rf /srv/iga-project/data/postgres/* sudo rm -rf /srv/iga-project/data/midpoint/var/* # 3. Validar limpeza ls -la /srv/iga-project/data/postgres/ # Esperado: Vazio (total 8) # 4. Reiniciar sudo docker compose up -d`

---

## 13.3. Problema: Arquivo Netplan Não Encontrado

**Sintoma:** `No such file or directory` ao editar `/etc/netplan/00-installer-config.yaml`

**Solução:**

bash

`# 1. Listar arquivos reais ls -la /etc/netplan/ # Exemplo de saída: -rw-r--r-- 1 root root 116 Jan 19 10:23 01-netcfg.yaml # 2. Usar o nome EXATO sudo nano`
