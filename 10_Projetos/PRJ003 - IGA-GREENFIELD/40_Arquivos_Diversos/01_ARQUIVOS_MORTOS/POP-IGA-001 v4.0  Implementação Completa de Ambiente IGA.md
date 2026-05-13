# 

**Identity Governance & Administration - Arquitetura midPoint + PostgreSQL em Ubuntu Server sobre Hyper-V**

---

## 📋 CONTROLE DE DOCUMENTO

|Campo|Informação|
|---|---|
|**Código POP**|POP-IGA-001|
|**Versão**|4.0 **PRODUCTION-READY**|
|**Tipo**|Infraestrutura - Implementação Greenfield|
|**Objetivo**|Guia completo para deploy de ambiente IGA do zero|
|**Escopo**|Download ISO → Criação VM → Configuração OS → Deploy Aplicação|
|**Pré-requisitos**|Windows 10/11 Pro com Hyper-V, 8GB RAM disponível, 100GB disco|
|**Tempo Estimado**|2-4 horas (primeira execução)|
|**Dificuldade**|Intermediária|
|**Público-alvo**|Administradores de Infraestrutura, Equipes DevOps|
|**Data de Criação**|Janeiro/2026|
|**Data de Revisão**|20/Janeiro/2026|
|**Status**|✅ **Validado em Produção - GMUD-009 Aprovada**|

---

## 🔄 CHANGELOG v4.0 - CORREÇÕES CRÍTICAS

|Item|Problema v3.0|Correção v4.0|Severidade|
|---|---|---|---|
|**1**|Fallback silencioso para H2|Adicionada trava `embedded: "false"` obrigatória|⭐⭐⭐⭐⭐|
|**2**|Aspas no .env causam erro SCRAM|**EXCLUÍDA** recomendação de aspas simples|⭐⭐⭐⭐⭐|
|**3**|Caractere `$` corrompe senha|Nova política: proibição absoluta de `$`|⭐⭐⭐⭐⭐|
|**4**|Queda de SSH não alertada|Alerta operacional crítico em Netplan|⭐⭐⭐⭐|
|**5**|Gateway fora da sub-rede|Validação pré-aplicação obrigatória|⭐⭐⭐⭐⭐|
|**6**|Comandos Docker sem `sudo`|Padronização com `sudo` + justificativa GRC|⭐⭐⭐|
|**7**|Volume envenenado entre tentativas|Comando de purge obrigatório (ETAPA 0)|⭐⭐⭐⭐⭐|
|**8**|Validação de repositório fraca|Validação tripla (ENV + logs + SQL)|⭐⭐⭐⭐⭐|
|**9**|Imagem Alpine inconsistente|Especificada imagem oficial `4.8` (não Alpine)|⭐⭐⭐|
|**10**|Divergência de nomes de banco|Unificação: tudo como `midpoint`|⭐⭐⭐⭐|
|**11**|Versão de schema não declarada|Adicionada variável `schemaVersion: "4.8"`|⭐⭐⭐⭐|

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
    
12. [Troubleshooting e Diagnósticos](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#12-troubleshooting-e-diagn%C3%B3sticos)
    
13. [Manutençã e Operação](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#13-manuten%C3%A7%C3%A3o-e-opera%C3%A7%C3%A3o)
    
14. [Referências e Documentação](https://www.perplexity.ai/search/o-erro-apresentado-no-seu-log-nfPNwFA1TXubzgD7bCVXIg#14-refer%C3%AAncias-e-documenta%C3%A7%C3%A3o)
    

---

## 1. VISÃO GERAL DA ARQUITETURA

## 1.1. Componentes da Solução

text

`┌─────────────────────────────────────────────────────────┐ │              HOST WINDOWS                                │ │              Hyper-V Habilitado                          │ │                                                          │ │  ┌────────────────────────────────────────────────────┐ │ │  │   MÁQUINA VIRTUAL                                   │ │ │  │   Ubuntu Server 24.04 LTS                          │ │ │  │                                                     │ │ │  │   ┌─────────────────────────────────────────────┐  │ │ │  │   │  DOCKER ENVIRONMENT                         │  │ │ │  │   │                                             │  │ │ │  │   │  ┌──────────────┐  ┌───────────────────┐   │  │ │ │  │   │  │ PostgreSQL   │  │   midPoint        │   │  │ │ │  │   │  │ Database     │  │   IGA Server      │   │  │ │ │  │   │  │ Port: 5432   │  │   Port: 8080      │   │  │ │ │  │   │  └──────────────┘  └───────────────────┘   │  │ │ │  │   │         ▲                    ▲              │  │ │ │  │   │         │                    │              │  │ │ │  │   │         └────────────────────┘              │  │ │ │  │   │           Volumes Persistentes              │  │ │ │  │   └─────────────────────────────────────────────┘  │ │ │  │                                                     │ │ │  │   SSH Port: 22 ◄──────────────────────────────────┼─┤ │  └────────────────────────────────────────────────────┘ │ │                                                          │ │  PowerShell/SSH Client                                   │ └─────────────────────────────────────────────────────────┘`

## 1.2. Stack Tecnológico

|Camada|Tecnologia|Versão Recomendada|Função|
|---|---|---|---|
|**Hypervisor**|Microsoft Hyper-V|Windows 10/11 Pro|Virtualização|
|**Sistema Operacional**|Ubuntu Server|24.04.2 LTS|Base Linux|
|**Container Runtime**|Docker Engine|29.x|Orquestração de containers|
|**Orquestrador**|Docker Compose|5.x|Definição multi-container|
|**Banco de Dados**|PostgreSQL|**16** (não Alpine)|Repositório de identidades|
|**Aplicação IGA**|midPoint|**4.8** (não Alpine)|Governança de Identidades|

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

`# VALIDAÇÃO 1: Hyper-V Instalado Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V # Resultado esperado: State = Enabled # VALIDAÇÃO 2: Virtualização Habilitada no BIOS Get-ComputerInfo | Select-Object -Property HyperVisorPresent, <REDACTED_SECRET>nabled # Resultado esperado: HyperVisorPresent = True, <REDACTED_SECRET>nabled = True # VALIDAÇÃO 3: Espaço em Disco Disponível Get-PSDrive C | Select-Object Used,Free # Resultado esperado: Free > 100 GB # VALIDAÇÃO 4: Conectividade com Internet Test-NetConnection -ComputerName releases.ubuntu.com -Port 443 # Resultado esperado: TcpTestSucceeded = True`

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

- Interface detectada automaticamente (ex: `eth0`)
    
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

## 7.1. Configurar IP Estático (Obrigatório)

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

`# Substitua NOME_DO_ARQUIVO pelo nome identificado no passo 1 sudo nano /etc/netplan/NOME_DO_ARQUIVO.yaml`

**Substitua o conteúdo por (ajuste conforme sua rede):**

text

`network:   version: 2  ethernets:    eth0:      dhcp4: false      addresses:        - xxx.xxx.xxx.xxx/24  # Ajustar conforme seu range      routes:        - to: default          via: xxx.xxx.xxx.xxx  # Gateway da sua rede (MESMA sub-rede do IP!)      nameservers:        addresses:          - 8.8.8.8          - 8.8.4.4`

---

## ⚠️ ALERTA OPERACIONAL CRÍTICO

**ATENÇÃO:** Ao executar `sudo netplan apply` via conexão SSH, sua sessão será **DESCONECTADA IMEDIATAMENTE** devido ao reset da interface de rede.

**Procedimento de Recuperação:**

1. **Aguarde 30 segundos** após a desconexão
    
2. Tente restabelecer:
    
    bash
    
    `ssh usuario@xxx.xxx.xxx.xxx`
    
3. **Se o SSH não responder:**
    
    - Acesse pelo **Console do Hyper-V**
        
    - Valide o IP: `ip addr show eth0`
        
    - Teste conectividade: `ping -c 4 8.8.8.8`
        

**Mitigação Recomendada:**

- ✅ Execute alterações de rede pelo **Console do Hyper-V** (não via SSH)
    
- ✅ Ou: Tenha janela do Console aberta como fallback antes de aplicar
    

---

## ETAPA 4: Aplicar e Validar

bash

`sudo netplan apply ip addr show eth0 ping -c 4 8.8.8.8`

---

## ✅ VALIDAÇÃO ADICIONAL - Protocolo de Rota

Após `sudo netplan apply`, valide que o protocolo mudou para `static`:

bash

`# Verificar protocolo da rota ip route # ✅ ESPERADO (estático configurado corretamente): default via xxx.xxx.xxx.xxx dev eth0 proto static # ⚠️ ATENÇÃO (DHCP residual - requer limpeza): default via xxx.xxx.xxx.xxx dev eth0 proto dhcp`

**Se aparecer `proto dhcp`, executar limpeza:**

bash

`sudo ip addr flush dev eth0 sudo netplan apply ip route  # Validar novamente`

---

## ETAPA 5: Documentar IP

bash

`echo "IP Estático da VM: $(hostname -I | awk '{print $1}')" > network-info.txt cat network-info.txt`

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

**Conformidade de Seguranç:**

- **ISO 27001:2022** A.9.2.3 - Gestão de Privilégios de Acesso
    
- **NIST CSF 2.0** PR.AC-4 - Princípio do Menor Privilégio
    
- **CIS Controls v8** 5.4 - Restrição de Privilégios Administrativos
    

---

## 8. FASE 6 - INSTALAÇÃO DO DOCKER E DOCKER COMPOSE

## 8.1. Instalação do Docker Engine

bash

`# PREPARAR AMBIENTE sudo apt remove -y docker docker-engine docker.io containerd runc sudo apt update sudo apt install -y ca-certificates curl gnupg lsb-release # ADICIONAR REPOSITÓRIO OFICIAL DO DOCKER sudo install -m 0755 -d /etc/apt/keyrings curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg sudo chmod a+r /etc/apt/keyrings/docker.gpg echo \   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null # INSTALAR DOCKER sudo apt update sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin # VALIDAR INSTALAÇÃO docker --version docker compose version sudo docker run hello-world # Resultado Esperado: "Hello from Docker! This message shows that your installation appears to be working correctly."`

## 8.2. Configurar Docker para Inicializar com o Sistema

bash

`sudo systemctl enable docker sudo systemctl start docker sudo systemctl status docker # Esperado: active (running)`

---

## 8.3. Política de Privilégios Docker

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

## 7.2. Criar Arquivo docker-compose.yml (Sintaxe Oficial v4.0)

bash

`cd /srv/iga-project nano docker-compose.yml`

**Copiar EXATAMENTE o conteúdo abaixo:**

text

`version: '3.8' services:   postgres:    image: postgres:16  # ⚠️ NÃO usar "postgres:16-alpine"    container_name: iga-postgres    environment:      POSTGRES_DB: ${POSTGRES_DB}      POSTGRES_USER: ${POSTGRES_USER}      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}    volumes:      - ./data/postgres:/var/lib/postgresql/data    networks:      - iga-network    healthcheck:      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]      interval: 10s      timeout: 5s      retries: 5    restart: unless-stopped   midpoint:    image: evolveum/midpoint:4.8  # ⚠️ NÃO usar "evolveum/midpoint:4.8-alpine"    container_name: iga-midpoint    ports:      - "8080:8080"    environment:      # 🔒 TRAVA ANTI-H2 (obrigatória - previne fallback silencioso)      MP_SET_midpoint.repository.embedded: "false"             # Configuração de Banco de Dados      MP_SET_midpoint.repository.database: postgresql      MP_SET_midpoint.repository.jdbcUrl: jdbc:postgresql://postgres:5432/${POSTGRES_DB}      MP_SET_midpoint.repository.jdbcUsername: ${POSTGRES_USER}      MP_SET_midpoint.repository.jdbcPassword: ${POSTGRES_PASSWORD}             # 🔒 TRAVA DE VERSÃO (previne busca de scripts legados)      MP_SET_midpoint.repository.schemaVersion: "4.8"             # Senha do Administrador      MP_SET_midpoint.administrator.initialPassword: ${MIDPOINT_ADMIN_PASSWORD}    volumes:      - ./data/midpoint/var:/opt/midpoint/var      - ./logs/midpoint:/opt/midpoint/var/log    depends_on:      postgres:        condition: service_healthy    networks:      - iga-network    restart: unless-stopped networks:   iga-network:    driver: bridge`

**Validar sintaxe:**

bash

`sudo docker compose config`

---

## 📝 NOTAS TÉCNICAS v4.0

**1. Por que NÃO usar imagens Alpine:**

- Imagens Alpine usam `sh` em vez de `bash`, causando problemas de compatibilidade
    
- Binários diferentes podem causar falhas em scripts de inicialização
    
- Para ambientes Greenfield, imagens oficiais baseadas em Debian/Ubuntu são mais resilientes
    

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

`# CRIAR TEMPLATE DO ARQUIVO .env cat > /srv/iga-project/.env.template <<'EOF' # <REDACTED_SECRET>==================== # CONFIGURAÇÕES DO AMBIENTE IGA v4.0 # <REDACTED_SECRET>==================== # 🔐 POLÍTICA DE SEGREDOS (LEIA ANTES DE EDITAR) # # ❌ PROIBIÇÕES ABSOLUTAS: # 1. NÃO use aspas simples ou duplas # 2. NÃO use o caractere cifrão ($) # 3. NÃO use espaços em branco # # ✅ FORMATO CORRETO: # POSTGRES_PASSWORD=P0stgr3sS3cur3#2026! # # ❌ FORMATO ERRADO: # POSTGRES_PASSWORD='P0stgr3sS3cur3#2026!'  (tem aspas) # POSTGRES_PASSWORD=P@$$w0rd  (tem cifrão) # # <REDACTED_SECRET>==================== # CREDENCIAIS DO POSTGRESQL POSTGRES_DB=midpoint POSTGRES_USER=midpoint POSTGRES_PASSWORD=SuaSenhaPostgreSQLAqui # CREDENCIAIS DO MIDPOINT # Usuário de login: administrator # Senha: valor abaixo MIDPOINT_ADMIN_PASSWORD=SuaSenhaMidPointAqui # <REDACTED_SECRET>==================== # NOTAS DE SEGURANÇA # - Use senhas fortes (mínimo 16 caracteres) # - Combine letras maiúsculas, minúsculas, números e símbolos # - Caracteres permitidos: @ # ! % & * - _ + = # <REDACTED_SECRET>==================== EOF # Copiar template para arquivo real cp /srv/iga-project/.env.template /srv/iga-project/.env`

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

`# EDITAR ARQUIVO .env nano /srv/iga-project/.env # AO MANUAL OBRIGATÓRIA: # 1. Substituir os placeholders MANTENDO o formato sem aspas: #    - SuaSenhaPostgreSQLAqui → P0stgr3sS3cur3#2026! #    - SuaSenhaMidPointAqui → M1dP0!ntAdm!n2026 # # 2. Salvar: Ctrl+X, Y, Enter`

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

`cd /srv/iga-project # VALIDAÇÃO 1: Conectividade Externa ping -c 4 8.8.8.8 # Esperado: 4 packets transmitted, 4 received # VALIDAÇÃO 2: Resolução DNS nslookup registry-1.docker.io # Esperado: endereço IP válido # VALIDAÇÃO 3: Docker Funcional sudo docker ps # Esperado: listagem vazia # VALIDAÇÃO 4: Arquivo .env Configurado cat .env | grep -v '^#' | grep -v '^$' # Esperado: 4 linhas SEM aspas # VALIDAÇÃO 5: docker-compose.yml Válido sudo docker compose config # Esperado: configuração renderizada # VALIDAÇÃO 6: IP Estático Confirmado ip addr show eth0 | grep inet # Esperado: inet xxx.xxx.xxx.xxx/XX (não deve ser DHCP) # VALIDAÇÃO 7: Sudoers Hardened sudo -l | grep -E "mkdir|chown|docker|du|rm|whoami" # Esperado: whitelist com caminhos completos`

**🛑 GATE DE INÍCIO:**  
Se **qualquer** validação falhar, **NÃO prosseguir** com o deploy.

---

## 8.2. Deploy Sequencial com Validação Tripla

## ETAPA 0: Garantia de Estado Zero (Purge) - OBRIGATÓRIO

**OBRIGATÓRIO antes de iniciar o deploy:**

bash

`# 1. Parar containers se existirem cd /srv/iga-project sudo docker compose down -v # 2. Limpar volumes de dados (CRÍTICO) sudo rm -rf /srv/iga-project/data/postgres/* sudo rm -rf /srv/iga-project/data/midpoint/var/* # 3. Validar limpeza ls -la /srv/iga-project/data/postgres/ # ✅ ESPERADO: Vazio (total 8) ls -la /srv/iga-project/data/midpoint/var/ # ✅ ESPERADO: Vazio (total 8)`

**Justificativa Técnica:**

PostgreSQL 16 grava senha no volume durante **primeira inicialização**. Se o volume já existir com senha anterior, a nova senha do `.env` é **ignorada**.

**Sintomas de volume envenenado:**

- ❌ Erro SCRAM: `password authentication failed`
    
- ❌ Log mostra: `Database directory appears to contain a database; Skipping initialization`
    

**Quando executar este purge:**

- ✅ Sempre antes de nova tentativa de deploy
    
- ✅ Após mudança de senhas no `.env`
    
- ✅ Após rollback de GMUD
    

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
    
2. Executar rollback imediato
    
3. Investigar causa raiz:
    
    - Aspas no `.env`?
        
    - Variável `embedded: false` ausente?
        
    - Volume envenenado?
        

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

`# TESTE 1: Containers Rodando sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" # TESTE 2: Logs Sem Erros Críticos sudo docker logs iga-postgres 2>&1 | grep -i 'error\|fatal' | wc -l sudo docker logs iga-midpoint 2>&1 | grep -i 'error\|fatal' | grep -v 'ErrorPage' | wc -l # Esperado: 0 para ambos # TESTE 3: Verificar Tipo de Repositório (já realizado na ETAPA 5) # Ver seção 8.2 - ETAPA 5: VALIDAÇÃO TRIPLA DE REPOSITÓRIO # TESTE 4: Conectividade com Banco sudo docker exec iga-midpoint /bin/bash -c "timeout 5 bash -c '</dev/tcp/postgres/5432' && echo 'PostgreSQL alcançável' || echo 'Falha'" # TESTE 5: Portas Abertas sudo netstat -tulpn | grep -E "8080|5432" # Esperado: # tcp6 ... :8080 ... LISTEN # tcp ... :5432 ... LISTEN # TESTE 6: Persistência de Dados ls -lh /srv/iga-project/data/postgres ls -lh /srv/iga-project/data/midpoint/var # Esperado: diretórios com arquivos`

---

## 9.2. Obter IP da VM para Acesso Externo

bash

`IP_VM=$(hostname -I | awk '{print $1}') echo "Endereço IP da VM: $IP_VM" echo "URL de Acesso: http://$IP_VM:8080/midpoint" # Salvar informações de acesso cat > /srv/iga-project/ACCESS-INFO.txt <<EOF <REDACTED_SECRET>====== INFORMAÇÕES DE ACESSO - IGA <REDACTED_SECRET>====== URL: http://$IP_VM:8080/midpoint Usuário: administrator Senha: Conforme .env (MIDPOINT_ADMIN_PASSWORD) Tipo de Repositório: PostgreSQL (validado) Data do Deploy: $(date) <REDACTED_SECRET>====== EOF cat /srv/iga-project/ACCESS-INFO.txt`

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

## 12. TROUBLESHOOTING E DIAGNÓSTICOS

## 12.1. Problema: midPoint Usando H2 ao Invés de PostgreSQL

**Sintoma:** Login falha, logs mostram `h2` ao invés de `postgresql`

**Causa Raiz:** Variável `embedded: "false"` ausente ou fallback por erro de conexão

**Solução:**

bash

`# 1. Parar ambiente sudo docker compose down -v # 2. Limpar dados do H2 sudo rm -rf /srv/iga-project/data/midpoint/var/* # 3. Verificar docker-compose.yml cat docker-compose.yml | grep -A 10 "midpoint:" | grep embedded # Esperado: MP_SET_midpoint.repository.embedded: "false" # 4. Verificar .env cat .env # Esperado: valores SEM aspas # 5. Reiniciar sudo docker compose up -d # 6. Validar sudo docker logs iga-midpoint 2>&1 | grep "repository.database" # Esperado: postgresql`

---

## 12.2. Problema: Erro SCRAM - password authentication failed

**Sintoma:** PostgreSQL rejeita conexão do midPoint

**Causa Raiz:** Caracteres especiais na senha interpretados incorretamente ou volume envenenado

**Solução:**

bash

`# 1. Verificar .env cat .env | grep POSTGRES_PASSWORD # ❌ ERRADO: POSTGRES_PASSWORD='Pssw0rd!'  # Tem aspas POSTGRES_PASSWORD=P@$$w0rd    # Tem cifrão # ✅ CORRETO: POSTGRES_PASSWORD=P@ssw0rd!   # Sem aspas, sem cifrão # 2. Se .env estiver correto, limpar volume envenenado sudo docker compose down -v sudo rm -rf /srv/iga-project/data/postgres/* # 3. Reiniciar sudo docker compose up -d`

---

## 12.3. Problema: Arquivo Netplan Não Encontrado

**Sintoma:** `No such file or directory` ao editar `/etc/netplan/00-installer-config.yaml`

**Solução:**

bash

`# 1. Listar arquivos reais ls -la /etc/netplan/ # Exemplo de saída: -rw-r--r-- 1 root root 116 Jan 19 10:23 01-netcfg.yaml # 2. Usar o nome EXATO sudo nano /etc/netplan/01-netcfg.yaml # 3. NUNCA assuma nome padrão`

---

## 12.4. Problema: Sudoers Rejeitando Comandos

**Sintoma:** `user is not allowed to execute /usr/bin/comando`

**Solução:**

bash

`# 1. Validar configuração sudo -l # 2. Se não aparecer caminhos completos, reconfigurar sudo visudo # 3. CORRIGIR linha # ❌ ERRADO: usuario ALL=(ALL) NOPASSWD: mkdir, chown # ✅ CORRETO: usuario ALL=(ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/chown, /usr/bin/docker, /usr/bin/du, /usr/bin/rm, /usr/bin/whoami`

---

## 12.5. Problema: Network Unreachable Após Netplan

**Sintoma:** `RTNETLINK answers: Network is unreachable` ou perda total de conectividade

**Causa Raiz:** Gateway configurado fora da sub-rede do IP

**Solução:**

bash

`# 1. Acessar pelo Console do Hyper-V (não via SSH) # 2. Verificar configuração atual cat /etc/netplan/*.yaml # 3. Corrigir gateway (exemplo): # IP: xxx.xxx.xxx.xxx/24 # Gateway DEVE ser: xxx.xxx.xxx.xxx (mesma sub-rede 192.168.68.X) # NÃO PODE ser: 192.168.1.1 (sub-rede diferente) # 4. Editar arquivo sudo nano /etc/netplan/ARQUIVO.yaml # 5. Corrigir linha: via: xxx.xxx.xxx.xxx  # Ajustar para gateway correto # 6. Aplicar sudo netplan apply # 7. Testar ping -c 4 8.8.8.8`

---

## 12.6. Problema: Erro "postgresql-4.6-all.sql" em Imagem 4.8

**Sintoma:** Log mostra `Attempting to create database tables from file 'postgresql-4.6-all.sql'` mas imagem é 4.8

**Causa Raiz:** Versão de schema não declarada ou metadados residuais no volume

**Solução:**

bash

`# 1. Parar containers sudo docker compose down -v # 2. Limpar volumes completamente sudo rm -rf /srv/iga-project/data/postgres/* sudo rm -rf /srv/iga-project/data/midpoint/var/* # 3. Verificar docker-compose.yml tem variável de versão cat docker-compose.yml | grep schemaVersion # Esperado: MP_SET_midpoint.repository.schemaVersion: "4.8" # 4. Se ausente, adicionar ao bloco environment do midPoint: nano docker-compose.yml # Adicionar: MP_SET_midpoint.repository.schemaVersion: "4.8" # 5. Reiniciar sudo docker compose up -d # 6. Validar logs sudo docker logs iga-midpoint 2>&1 | grep "postgresql-4.8-all.sql" # Esperado: Attempting to create database tables from file 'postgresql-4.8-all.sql'`

---

## 13. MANUTENÇÃO E OPERAÇÃO

## 13.1. Backup do Ambiente

bash

`# Criar script de backup cat > /srv/iga-project/backup.sh <<'EOF' #!/bin/bash BACKUP_DIR="/srv/iga-project/backups" DATE=$(date +%Y%m%d_%H%M%S) BACKUP_FILE="$BACKUP_DIR/backup_$DATE.tar.gz" echo "Iniciando backup em $(date)" sudo docker compose down sudo tar -czf "$BACKUP_FILE" -C /srv/iga-project data/ .env docker-compose.yml sudo docker compose up -d echo "Backup concluído: $BACKUP_FILE" EOF chmod +x /srv/iga-project/backup.sh # Executar backup ./srv/iga-project/backup.sh`

---

## 13.2. Comandos Úteis

**Gestão de Containers:**

bash

`sudo docker compose up -d       # Iniciar sudo docker compose down        # Parar sudo docker compose restart     # Reiniciar sudo docker compose logs -f     # Logs em tempo real`

**Diagnóstico:**

bash

`sudo docker logs iga-midpoint                          # Logs do midPoint sudo docker logs iga-postgres                          # Logs do PostgreSQL sudo docker exec -it iga-midpoint bash                 # Shell do container sudo docker stats                                      # Uso de recursos`

**Validação de Repositório:**

bash

`sudo docker logs iga-midpoint 2>&1 | grep "repository.database" sudo docker logs iga-midpoint 2>&1 | grep "repository.embedded" sudo docker exec iga-postgres psql -U midpoint -d midpoint -c "\dt"`

---

## 14. REFERÊNCIAS E DOCUMENTAÇÃO

## 14.1. Documentação Oficial

- **midPoint:** [https://docs.evolveum.com/midpoint/](https://docs.evolveum.com/midpoint/)
    
- **PostgreSQL:** [https://www.postgresql.org/docs/](https://www.postgresql.org/docs/)
    
- **Docker:** [https://docs.docker.com/](https://docs.docker.com/)
    
- **Ubuntu Server:** [https://ubuntu.com/server/docs](https://ubuntu.com/server/docs)
    

---

## 14.2. Configuração de Referência Completa

**docker-compose.yml v4.0:**

text

`version: '3.8' services:   postgres:    image: postgres:16    container_name: iga-postgres    environment:      POSTGRES_DB: ${POSTGRES_DB}      POSTGRES_USER: ${POSTGRES_USER}      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}    volumes:      - ./data/postgres:/var/lib/postgresql/data    networks:      - iga-network    healthcheck:      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]      interval: 10s      timeout: 5s      retries: 5    restart: unless-stopped   midpoint:    image: evolveum/midpoint:4.8    container_name: iga-midpoint    ports:      - "8080:8080"    environment:      MP_SET_midpoint.repository.embedded: "false"      MP_SET_midpoint.repository.database: postgresql      MP_SET_midpoint.repository.jdbcUrl: jdbc:postgresql://postgres:5432/${POSTGRES_DB}      MP_SET_midpoint.repository.jdbcUsername: ${POSTGRES_USER}      MP_SET_midpoint.repository.jdbcPassword: ${POSTGRES_PASSWORD}      MP_SET_midpoint.repository.schemaVersion: "4.8"      MP_SET_midpoint.administrator.initialPassword: ${MIDPOINT_ADMIN_PASSWORD}    volumes:      - ./data/midpoint/var:/opt/midpoint/var      - ./logs/midpoint:/opt/midpoint/var/log    depends_on:      postgres:        condition: service_healthy    networks:      - iga-network    restart: unless-stopped networks:   iga-network:    driver: bridge`

**Arquivo .env v4.0:**

bash

`POSTGRES_DB=midpoint POSTGRES_USER=midpoint POSTGRES_PASSWORD=P0stgr3sS3cur3#2026! MIDPOINT_ADMIN_PASSWORD=M1dP0!ntAdm!n2026`

---

## 14.3. Portas Utilizadas

|Porta|Serviço|Protocolo|Acesso|
|---|---|---|---|
|**22**|SSH|TCP|Externo (administração)|
|**8080**|midPoint Web UI|TCP|Externo (interface web)|
|**5432**|PostgreSQL|TCP|Interno (apenas containers)|

---

## APÊNDICE A - CHECKLIST DE VALIDAÇÃO COMPLETA

## Pré-requisitos (Windows)

-  Hyper-V habilitado e funcional
    
-  ISO do Ubuntu baixada
    
-  Virtual Switch criado
    

## Fase 1-4: Infraestrutura

-  VM criada com recursos adequados
    
-  Ubuntu instalado
    
-  SSH acessível
    
-  Sistema atualizado
    

## Fase 5: Hardening

-  Arquivo Netplan identificado (`ls /etc/netplan/`)
    
-  Gateway na mesma sub-rede validado
    
-  IP estático configurado
    
-  Protocolo de rota confirmado como `static`
    
-  Sudoers com caminhos completos (`/usr/bin/...`)
    
-  Whitelist de 6 binários validada
    

## Fase 6-7: Docker e Estrutura

-  Docker instalado
    
-  Teste `hello-world` bem-sucedido
    
-  Diretórios criados
    
-  `docker-compose.yml` v4.0 criado com travas Anti-H2
    
-  `.env` criado SEM aspas e SEM cifrão
    
-  Permissões 600 aplicadas no `.env`
    

## Fase 8-9: Deploy e Validação

-  7 validações pré-deploy aprovadas
    
-  ETAPA 0 (Purge) executada
    
-  PostgreSQL `healthy`
    
-  midPoint inicializado
    
-  Validação tripla de repositório aprovada (3/3 checkpoints)
    
-  Login bem-sucedido
    
-  Teste de persistência aprovado
    

---

## AVISO DE SEGURANÇA

**1. Nunca versione o arquivo `.env`**  
**2. Use senhas fortes (mínimo 16 caracteres)**  
**3. NUNCA use aspas ou cifrão (`$`) no `.env`**  
**4. Valide tipo de repositório após cada deploy**  
**5. Implemente backups regulares**

---

## CONTROLE DE VERSÃO DO DOCUMENTO

|Versão|Data|Mudanças|
|---|---|---|
|**1.0**|Janeiro/2026|Criação do POP|
|**2.0**|Janeiro/2026|Correção variáveis JDBC|
|**2.1**|Janeiro/2026|Hardening alinhamento GMUD|
|**3.0**|Janeiro/2026|Sintaxe MP_SET, proteção caracteres especiais, remoção dados sensíveis, validação tripla|
|**4.0**|20/Jan/2026|✅ **Trava Anti-H2**, ❌ **Exclusão de aspas**, **Política anti-cifrão**, **Alerta SSH**, **Validação de gateway**, **Sudo obrigatório**, **Purge de volumes**, **Validação tripla reforçada**, **Versão de schema**, **Imagens não-Alpine**|

---

## STATUS DO DOCUMENTO

|Campo|Valor|
|---|---|
|**Versão**|4.0 **PRODUCTION-READY**|
|**Status**|✅ **Validado em Produção - GMUD-009 Aprovada**|
|**Conformidade**|ISO 27001:2022, NIST CSF 2.0, CIS Controls v8|
|**Classificação**|Público (dados sensíveis removidos)|

---

**LICENÇA DE USO**  
Este documento pode ser usado, modificado e distribuído livremente para fins educacionais e comerciais, desde que mantida a atribuição ao autor original.

---

**FIM DO DOCUMENTO POP-IGA-001 v4.0**

**Repositório Sugerido:** `docs/procedures/POP-IGA-001-v4.0-Production-Ready.md`
