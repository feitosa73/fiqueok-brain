

## **Procedimento Operacional Padrão**
## **Implementação Completa de Ambiente IGA (Identity Governance & Administration)**
### **Arquitetura midPoint + PostgreSQL em Ubuntu Server sobre Hyper-V**

---

## **CONTROLE DE DOCUMENTO**

| Campo | Informação |
|-------|------------|
| **Código POP** | POP-IGA-001 |
| **Versão** | **3.0 (ESTÁVEL - GITHUB READY)** |
| **Tipo** | Infraestrutura - Implementação Greenfield |
| **Objetivo** | Guia completo para deploy de ambiente IGA do zero |
| **Escopo** | Download ISO → Criação VM → Configuração OS → Deploy Aplicação |
| **Pré-requisitos** | Windows 10/11 Pro com Hyper-V, 8GB RAM disponível, 100GB disco |
| **Tempo Estimado** | 2-4 horas (primeira execução) |
| **Dificuldade** | Intermediária |
| **Público-alvo** | Administradores de Infraestrutura, Equipes DevOps |
| **Data de Criação** | Janeiro/2026 |
| **Data de Revisão** | Janeiro/2026 |
| **Status** | ✅ **Validado - Versão Estável para Produção** |

---

## **📋 CHANGELOG v3.0 - CORREÇÕES CRÍTICAS**

| Item | Problema v2.1 | Correção v3.0 |
|------|--------------|---------------|
| **1** | Nomenclatura de variáveis inconsistente | Padronizado `MP_SET_midpoint.repository.*` (sintaxe oficial) |
| **2** | Escape de senhas vulnerável | Implementado aspas simples no `.env` + validação |
| **3** | Netplan com nome assumido | Comando obrigatório `ls /etc/netplan/` antes de editar |
| **4** | Sudoers incompleto | Adicionado `/usr/bin/whoami` à whitelist |
| **5** | Informações internas expostas | Removido IPs específicos, GMUDs, dados sensíveis |
| **6** | Validação de repositório fraca | Checkpoint triplo: variáveis + logs + query SQL |

---

## **ÍNDICE**

1. [Visão Geral da Arquitetura](#1-visão-geral-da-arquitetura)
2. [Pré-requisitos e Validações](#2-pré-requisitos-e-validações)
3. [Fase 1: Preparação do Ambiente Windows](#3-fase-1-preparação-do-ambiente-windows)
4. [Fase 2: Criação da Máquina Virtual no Hyper-V](#4-fase-2-criação-da-máquina-virtual-no-hyper-v)
5. [Fase 3: Instalação do Ubuntu Server](#5-fase-3-instalação-do-ubuntu-server)
6. [Fase 4: Configuração Pós-Instalação do Ubuntu](#6-fase-4-configuração-pós-instalação-do-ubuntu)
7. [Fase 5: Hardening de Segurança](#7-fase-5-hardening-de-segurança)
8. [Fase 6: Instalação do Docker e Docker Compose](#8-fase-6-instalação-do-docker-e-docker-compose)
9. [Fase 7: Preparação da Estrutura do Projeto IGA](#9-fase-7-preparação-da-estrutura-do-projeto-iga)
10. [Fase 8: Deploy do Ambiente IGA](#10-fase-8-deploy-do-ambiente-iga)
11. [Fase 9: Validação e Testes](#11-fase-9-validação-e-testes)
12. [Troubleshooting e Diagnósticos](#12-troubleshooting-e-diagnósticos)
13. [Manutenção e Operação](#13-manutenção-e-operação)
14. [Referências e Documentação](#14-referências-e-documentação)

---

## **1. VISÃO GERAL DA ARQUITETURA**

### **1.1. Componentes da Solução**

```
┌───────────────────────────────────────────────────────┐
│          HOST WINDOWS (Hyper-V Habilitado)           │
│  ┌─────────────────────────────────────────────────┐  │
│  │  MÁQUINA VIRTUAL UBUNTU SERVER 24.04 LTS        │  │
│  │  ┌───────────────────────────────────────────┐  │  │
│  │  │          DOCKER ENVIRONMENT               │  │  │
│  │  │  ┌──────────────┐   ┌──────────────┐      │  │  │
│  │  │  │  PostgreSQL  │◄──┤   midPoint   │      │  │  │
│  │  │  │  (Database)  │   │ (IGA Server) │      │  │  │
│  │  │  │   Port 5432  │   │  Port 8080   │      │  │  │
│  │  │  └──────────────┘   └──────────────┘      │  │  │
│  │  │         ▲                   ▲              │  │  │
│  │  │         │                   │              │  │  │
│  │  │   [Volumes Persistentes]                  │  │  │
│  │  └───────────────────────────────────────────┘  │  │
│  │                      ▲                           │  │
│  │              SSH (Port 22)                       │  │
│  └─────────────────────────────────────────────────┘  │
│                      ▲                                │
│              PowerShell/SSH Client                    │
└───────────────────────────────────────────────────────┘
```

### **1.2. Stack Tecnológico**

| Camada | Tecnologia | Versão Recomendada | Função |
|--------|-----------|-------------------|--------|
| **Hypervisor** | Microsoft Hyper-V | Windows 10/11 Pro | Virtualização |
| **Sistema Operacional** | Ubuntu Server | 24.04.2 LTS | Base Linux |
| **Container Runtime** | Docker Engine | 29.x+ | Orquestração de containers |
| **Orquestrador** | Docker Compose | 5.x+ | Definição multi-container |
| **Banco de Dados** | PostgreSQL | 16 Alpine | Repositório de identidades |
| **Aplicação IGA** | midPoint | 4.8 | Governança de Identidades |

### **1.3. Requisitos de Hardware**

| Recurso | Mínimo | Recomendado | Observação |
|---------|--------|-------------|------------|
| **CPU** | 2 cores | 4 cores | Processador com suporte a virtualização (Intel VT-x/AMD-V) |
| **RAM** | 4 GB | 8 GB | midPoint + PostgreSQL + OS |
| **Disco** | 40 GB | 80 GB | SSD recomendado para performance |
| **Rede** | 1 NIC | 1 NIC | Acesso à internet obrigatório |

---

## **2. PRÉ-REQUISITOS E VALIDAÇÕES**

### **2.1. Checklist de Pré-requisitos**

Execute as validações abaixo **antes de iniciar** o procedimento:

```powershell
# ====================================
# VALIDAÇÃO 1: Hyper-V Instalado
# ====================================
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V

# Resultado esperado:
# State: Enabled

# ====================================
# VALIDAÇÃO 2: Virtualização Habilitada no BIOS
# ====================================
Get-ComputerInfo | Select-Object -Property HyperVisorPresent, HyperVRequirementVirtualizationFirmwareEnabled

# Resultado esperado:
# HyperVisorPresent: True
# HyperVRequirementVirtualizationFirmwareEnabled: True

# ====================================
# VALIDAÇÃO 3: Espaço em Disco Disponível
# ====================================
Get-PSDrive C | Select-Object Used,Free

# Resultado esperado:
# Free: maior que 100 GB

# ====================================
# VALIDAÇÃO 4: Conectividade com Internet
# ====================================
Test-NetConnection -ComputerName releases.ubuntu.com -Port 443

# Resultado esperado:
# TcpTestSucceeded: True
```

### **2.2. Instalação do Hyper-V (Se Necessário)**

Se o Hyper-V não estiver habilitado:

```powershell
# Executar PowerShell como Administrador

# Habilitar Hyper-V
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

# Reiniciar o computador
Restart-Computer
```

**⚠️ ATENÇÃO:** Após reinicialização, validar novamente com os comandos da seção 2.1.

---

## **3. FASE 1: PREPARAÇÃO DO AMBIENTE WINDOWS**

### **3.1. Download da ISO do Ubuntu Server**

```powershell
# Criar diretório para downloads
New-Item -Path "C:\ISOs" -ItemType Directory -Force

# Abrir navegador para download manual
Start-Process "https://releases.ubuntu.com/24.04.2/ubuntu-24.04.2-live-server-amd64.iso"
```

**Ação Manual Requerida:**
1. Aguardar download completo do arquivo ISO (~2.5 GB)
2. Salvar em `C:\ISOs\ubuntu-24.04.2-live-server-amd64.iso`
3. Verificar integridade do arquivo (opcional mas recomendado)

### **3.2. Verificação de Integridade (Opcional)**

```powershell
# Calcular SHA256 do arquivo baixado
Get-FileHash -Path "C:\ISOs\ubuntu-24.04.2-live-server-amd64.iso" -Algorithm SHA256

# Comparar com hash oficial em:
# https://releases.ubuntu.com/24.04.2/SHA256SUMS
```

### **3.3. Criar Virtual Switch no Hyper-V**

```powershell
# Listar adaptadores de rede físicos
Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Format-Table Name, InterfaceDescription, Status

# Criar Virtual Switch Externo
# Substitua "Ethernet" pelo nome real do seu adaptador
New-VMSwitch -Name "External-Switch" -NetAdapterName "Ethernet" -AllowManagementOS $true

# Validar criação
Get-VMSwitch -Name "External-Switch"
```

**Nota Técnica:** O Virtual Switch Externo permite que a VM tenha acesso à rede física e à internet.

---

## **4. FASE 2: CRIAÇÃO DA MÁQUINA VIRTUAL NO HYPER-V**

### **4.1. Criação da VM via PowerShell**

```powershell
# ====================================
# DEFINIR PARÂMETROS DA VM
# ====================================
$VMName = "IGA-Server"
$VMPath = "C:\Hyper-V\VMs"
$VHDPath = "C:\Hyper-V\VHDs\$VMName.vhdx"
$ISOPath = "C:\ISOs\ubuntu-24.04.2-live-server-amd64.iso"
$SwitchName = "External-Switch"
$Memory = 8GB
$CPUCount = 4
$VHDSize = 80GB

# ====================================
# CRIAR ESTRUTURA DE DIRETÓRIOS
# ====================================
New-Item -Path "C:\Hyper-V\VMs" -ItemType Directory -Force
New-Item -Path "C:\Hyper-V\VHDs" -ItemType Directory -Force

# ====================================
# CRIAR MÁQUINA VIRTUAL
# ====================================
New-VM -Name $VMName `
       -MemoryStartupBytes $Memory `
       -Generation 2 `
       -NewVHDPath $VHDPath `
       -NewVHDSizeBytes $VHDSize `
       -Path $VMPath `
       -SwitchName $SwitchName

# ====================================
# CONFIGURAR RECURSOS DA VM
# ====================================
Set-VM -Name $VMName -ProcessorCount $CPUCount
Set-VM -Name $VMName -AutomaticCheckpointsEnabled $false
Set-VM -Name $VMName -CheckpointType Production

# ====================================
# CONFIGURAR BOOT E SECURE BOOT
# ====================================
# Desabilitar Secure Boot (compatibilidade com Linux)
Set-VMFirmware -VMName $VMName -EnableSecureBoot Off

# Adicionar ISO ao DVD Drive
Add-VMDvdDrive -VMName $VMName -Path $ISOPath

# Configurar ordem de boot
$DVDDrive = Get-VMDvdDrive -VMName $VMName
Set-VMFirmware -VMName $VMName -FirstBootDevice $DVDDrive

# ====================================
# VALIDAR CONFIGURAÇÃO
# ====================================
Get-VM -Name $VMName | Format-List *
```

### **4.2. Iniciar a VM**

```powershell
# Iniciar a VM
Start-VM -Name $VMName

# Abrir console de conexão
vmconnect.exe localhost $VMName
```

---

## **5. FASE 3: INSTALAÇÃO DO UBUNTU SERVER**

### **5.1. Processo de Instalação Interativa**

**Siga o assistente de instalação do Ubuntu Server:**

1. **Seleção de Idioma**
   - Escolha: `English` (recomendado para compatibilidade)

2. **Installer Update**
   - Se solicitado: `Continue without updating`

3. **Keyboard Configuration**
   - Layout: Selecione conforme sua região

4. **Type of Install**
   - Selecione: `Ubuntu Server (minimized)`

5. **Network Connections**
   - Interface detectada automaticamente (ex: `eth0`)
   - **DHCP:** Aceitar configuração automática
   - **⚠️ CRÍTICO:** Anotar o endereço IP atribuído (exemplo: `192.168.1.100`)

6. **Configure Proxy**
   - Deixar em branco se não houver proxy
   - Continuar com `Done`

7. **Ubuntu Archive Mirror**
   - Aceitar padrão
   - Continuar com `Done`

8. **Guided Storage Configuration**
   - Selecionar: `Use an entire disk`
   - **NÃO** selecionar `Set up this disk as an LVM group`
   - Disco: `/dev/sda`
   - Confirmar com `Done`

9. **Profile Setup** (⚠️ **INFORMAÇÕES CRÍTICAS**)
   ```
   Your name: [Seu nome completo]
   Your server's name: iga-server
   Pick a username: [seu-usuario]
   Choose a password: [senha-segura]
   Confirm your password: [senha-segura]
   ```
   - **Anotar estas credenciais** - serão usadas para acesso SSH

10. **SSH Setup**
    - **☑️ MARCAR:** `Install OpenSSH server`
    - Continuar com `Done`

11. **Featured Server Snaps**
    - **NÃO** selecionar nenhum snap adicional
    - Continuar com `Done`

12. **Installation Complete**
    - Aguardar conclusão (~5-10 minutos)
    - Quando aparecer "Reboot Now": aguardar ejeção automática do ISO

13. **Primeiro Boot**
    - Fazer login com as credenciais criadas no passo 9

---

## **6. FASE 4: CONFIGURAÇÃO PÓS-INSTALAÇÃO DO UBUNTU**

### **6.1. Primeiro Acesso e Atualização do Sistema**

```bash
# ====================================
# VALIDAR CONECTIVIDADE
# ====================================
ip addr show
ping -c 4 8.8.8.8
nslookup ubuntu.com

# ====================================
# ATUALIZAR SISTEMA
# ====================================
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

# Reiniciar se houver atualizações de kernel
sudo reboot
```

---

## **7. FASE 5: HARDENING DE SEGURANÇA**

### **7.1. ✅ Configurar IP Estático (Obrigatório)**

```bash
# ====================================
# ETAPA 1: Identificar Arquivo Netplan
# ====================================
ls -la /etc/netplan/

# ⚠️ ATENÇÃO: NUNCA assuma o nome do arquivo
# Anote o nome EXATO retornado (ex: 00-installer-config.yaml, 01-netcfg.yaml)

# ====================================
# ETAPA 2: Validar Conflito de IP no Windows
# ====================================
# No PowerShell do Windows:
# Test-NetConnection -ComputerName <IP_DESEJADO> -InformationLevel Detailed
# Se retornar "PingSucceeded: False" → IP disponível ✅

# ====================================
# ETAPA 3: Editar Arquivo Netplan
# ====================================
# Substitua [NOME_DO_ARQUIVO] pelo nome identificado no passo 1
sudo nano /etc/netplan/[NOME_DO_ARQUIVO].yaml

# Substitua o conteúdo por (ajuste conforme sua rede):
```

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - 192.168.1.100/24  # Ajustar conforme seu range
      routes:
        - to: default
          via: 192.168.1.1  # Gateway da sua rede
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

```bash
# ====================================
# ETAPA 4: Aplicar e Validar
# ====================================
d
ip addr show eth0
ping -c 4 8.8.8.8

# ====================================
# ETAPA 5: Documentar IP
# ====================================
echo "IP Estático da VM: $(hostname -I | awk '{print $1}')" > ~/network-info.txt
cat ~/network-info.txt
```

### **7.2. ✅ Configurar Sudoers Hardened (Least Privilege)**

```bash
# ====================================
# Editar sudoers com visudo
# ====================================
sudo visudo

# ====================================
# Adicionar WHITELIST no final do arquivo
# ====================================
# Substitua [seu-usuario] pelo seu usuário real
[seu-usuario] ALL=(ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/chown, /usr/bin/docker, /usr/bin/du, /usr/bin/rm, /usr/bin/whoami

# Salvar e sair (Ctrl+X, Y, Enter)

# ====================================
# Validar configuração
# ====================================
sudo -l

# Esperado:
# User [seu-usuario] may run the following commands on iga-server:
#     (ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/chown, /usr/bin/docker, /usr/bin/du, /usr/bin/rm, /usr/bin/whoami
```

**⚠️ Conformidade de Segurança:**
- ✅ ISO 27001:2022 A.9.2.3 - Gestão de Privilégios de Acesso
- ✅ NIST CSF 2.0 PR.AC-4 - Princípio do Menor Privilégio
- ✅ CIS Controls v8 5.4 - Restrição de Privilégios Administrativos

---

## **8. FASE 6: INSTALAÇÃO DO DOCKER E DOCKER COMPOSE**

### **8.1. Instalação do Docker Engine**

```bash
# ====================================
# PREPARAR AMBIENTE
# ====================================
sudo apt remove -y docker docker-engine docker.io containerd runc
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# ====================================
# ADICIONAR REPOSITÓRIO OFICIAL DO DOCKER
# ====================================
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# ====================================
# INSTALAR DOCKER
# ====================================
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# ====================================
# CONFIGURAR PERMISSÕES
# ====================================
sudo usermod -aG docker $USER
newgrp docker

# ====================================
# VALIDAR INSTALAÇÃO
# ====================================
docker --version
docker compose version
docker run hello-world
```

**Resultado Esperado:**
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

### **8.2. Configurar Docker para Inicializar com o Sistema**

```bash
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
# Esperado: active (running)
```

---

## **9. FASE 7: PREPARAÇÃO DA ESTRUTURA DO PROJETO IGA**

### **7.1. Criar Estrutura de Diretórios**

```bash
# ====================================
# CRIAR DIRETÓRIO RAIZ DO PROJETO
# ====================================
sudo mkdir -p /srv/iga-project
sudo chown -R $USER:$USER /srv/iga-project

# ====================================
# CRIAR SUBDIRETÓRIOS
# ====================================
mkdir -p /srv/iga-project/data/postgres
mkdir -p /srv/iga-project/data/midpoint/var
mkdir -p /srv/iga-project/logs/midpoint
mkdir -p /srv/iga-project/config
mkdir -p /srv/iga-project/backups
mkdir -p /srv/iga-project/evidencias

# ====================================
# VALIDAR ESTRUTURA
# ====================================
tree /srv/iga-project -L 2
# Ou se tree não estiver instalado:
ls -lR /srv/iga-project
```

### **7.2. ✅ Criar Arquivo docker-compose.yml (Sintaxe Oficial v3.0)**

```bash
cd /srv/iga-project

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: iga-postgres
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - ./data/postgres:/var/lib/postgresql/data
    networks:
      - iga-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  midpoint:
    image: evolveum/midpoint:4.8
    container_name: iga-midpoint
    ports:
      - "8080:8080"
    environment:
      # ✅ SINTAXE OFICIAL v3.0 - Prefixo MP_SET
      MP_SET_midpoint.repository.database: postgresql
      MP_SET_midpoint.repository.jdbcUrl: jdbc:postgresql://postgres:5432/${POSTGRES_DB}
      MP_SET_midpoint.repository.jdbcUsername: ${POSTGRES_USER}
      MP_SET_midpoint.repository.jdbcPassword: ${POSTGRES_PASSWORD}
      MP_SET_midpoint.administrator.initialPassword: ${MIDPOINT_ADMIN_PASSWORD}
    volumes:
      - ./data/midpoint/var:/opt/midpoint/var
      - ./logs/midpoint:/opt/midpoint/var/log
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - iga-network
    restart: unless-stopped

networks:
  iga-network:
    driver: bridge
EOF

# Validar sintaxe
docker compose config
```

### **7.3. ✅ Criar Arquivo .env com Proteção de Caracteres Especiais**

```bash
# ====================================
# CRIAR TEMPLATE DO ARQUIVO .env
# ====================================
cat > .env.template << 'EOF'
# ============================================
# CONFIGURAÇÕES DO AMBIENTE IGA v3.0
# ============================================
# ⚠️ ATENÇÃO: Use aspas simples para senhas
# Exemplo CORRETO: POSTGRES_PASSWORD='Senh@123!'
# Exemplo ERRADO: POSTGRES_PASSWORD=Senh@123!

# ============================================
# CREDENCIAIS DO POSTGRESQL
# ============================================
POSTGRES_DB='midpoint'
POSTGRES_USER='midpoint_user'
POSTGRES_PASSWORD='SuaSenhaPostgreSQL_Aqui'

# ============================================
# CREDENCIAIS DO MIDPOINT
# ============================================
# Usuário de login: administrator
# Senha: [valor abaixo]
MIDPOINT_ADMIN_PASSWORD='SuaSenhaMidPoint_Aqui'

# ============================================
# NOTAS DE SEGURANÇA
# ============================================
# - Use senhas fortes (mínimo 16 caracteres)
# - Combine letras maiúsculas, minúsculas, números e símbolos
# - SEMPRE use aspas simples para proteger caracteres especiais
# - Exemplo: POSTGRES_PASSWORD='P@ssw0rd#2026!'
EOF

# Copiar template para arquivo real
cp .env.template .env

# ====================================
# EDITAR ARQUIVO .env
# ====================================
nano .env
```

**⚠️ AÇÃO MANUAL OBRIGATÓRIA:**

1. Editar o arquivo `.env` com `nano .env`
2. Substituir os placeholders **mantendo as aspas simples**:
   - `POSTGRES_PASSWORD='SuaSenhaAqui!'` → `POSTGRES_PASSWORD='P0stgr3s#2026!'`
   - `MIDPOINT_ADMIN_PASSWORD='SuaSenhaAqui!'` → `MIDPOINT_ADMIN_PASSWORD='M1dP0!nt#2026'`
3. Salvar (Ctrl+X, Y, Enter)

**Exemplo de .env Completo:**
```bash
POSTGRES_DB='midpoint'
POSTGRES_USER='midpoint_user'
POSTGRES_PASSWORD='P0stgr3sS3cur3#2026!'

MIDPOINT_ADMIN_PASSWORD='M1dP0!ntAdm!n#2026'
```

```bash
# ====================================
# PROTEGER ARQUIVO .env
# ====================================
chmod 600 .env
ls -la .env
# Esperado: -rw-------

# ====================================
# CRIAR .gitignore
# ====================================
cat > .gitignore << 'EOF'
.env
data/
logs/
backups/
evidencias/
EOF
```

---

## **10. FASE 8: DEPLOY DO AMBIENTE IGA**

### **8.1. Validações Pré-Deploy**

```bash
cd /srv/iga-project

# ====================================
# VALIDAÇÃO 1: Conectividade Externa
# ====================================
ping -c 4 8.8.8.8
# Esperado: 4 packets transmitted, 4 received

# ====================================
# VALIDAÇÃO 2: Resolução DNS
# ====================================
nslookup registry-1.docker.io
# Esperado: endereço IP válido

# ====================================
# VALIDAÇÃO 3: Docker Funcional
# ====================================
docker ps
# Esperado: listagem vazia

# ====================================
# VALIDAÇÃO 4: Arquivo .env Configurado
# ====================================
cat .env | grep -v '^#' | grep -v '^$'
# Esperado: 4 linhas com aspas simples

# ====================================
# VALIDAÇÃO 5: docker-compose.yml Válido
# ====================================
docker compose config
# Esperado: configuração renderizada

# ====================================
# ✅ VALIDAÇÃO 6: IP Estático Confirmado
# ====================================
ip addr show eth0 | grep "inet "
# Esperado: inet <SEU_IP>/XX (não deve ser DHCP)

# ====================================
# ✅ VALIDAÇÃO 7: Sudoers Hardened
# ====================================
sudo -l | grep -E "(mkdir|chown|docker|du|rm|whoami)"
# Esperado: whitelist com caminhos completos
```

**⚠️ GATE DE INÍCIO:** Se qualquer validação falhar, NÃO prosseguir com o deploy.

---

### **8.2. Deploy Sequencial com Validação Tripla**

```bash
# ====================================
# ETAPA 1: Inicializar PostgreSQL
# ====================================
echo "Iniciando PostgreSQL..."
docker compose up -d postgres

# Acompanhar logs
docker logs -f iga-postgres

# AGUARDAR a mensagem aparecer 2 vezes:
# "database system is ready to accept connections"
# Pressionar Ctrl+C após a SEGUNDA ocorrência

# ====================================
# ETAPA 2: Validar Health Check
# ====================================
sleep 5
docker inspect iga-postgres | grep -A 5 '"Health"'
# Esperado: "Status": "healthy"

docker exec iga-postgres psql -U midpoint_user -d midpoint -c "SELECT version();"
# Esperado: PostgreSQL 16.x

# ====================================
# ETAPA 3: Aguardar Estabilização
# ====================================
echo "PostgreSQL healthy. Aguardando 10 segundos..."
sleep 10

# ====================================
# ETAPA 4: Inicializar midPoint
# ====================================
echo "Iniciando midPoint..."
docker compose up -d midpoint

# Acompanhar logs
docker logs -f iga-midpoint

# MENSAGENS CRÍTICAS A OBSERVAR:
# 1. "MP configuration property: midpoint.repository.database = postgresql" ✅
# 2. "Connection to database successful"
# 3. "Created User:administrator"
# 4. "Server startup in [XXXX] milliseconds"
# Pressionar Ctrl+C após "Server startup"

# ====================================
# ETAPA 5: ✅ VALIDAÇÃO TRIPLA DE REPOSITÓRIO
# ====================================
echo "=== CHECKPOINT CRÍTICO: VALIDAÇÃO DE REPOSITÓRIO ===" > evidencias/repository-validation.txt

# Validação 1: Verificar variáveis de ambiente
echo "--- Variáveis Injetadas ---" >> evidencias/repository-validation.txt
docker exec iga-midpoint env | grep MP_SET >> evidencias/repository-validation.txt

# Validação 2: Verificar logs de bootstrap
echo "--- Tipo de Repositório nos Logs ---" >> evidencias/repository-validation.txt
docker logs iga-midpoint 2>&1 | grep "midpoint.repository.database" >> evidencias/repository-validation.txt

# Validação 3: Query SQL direta
echo "--- Conexão PostgreSQL Ativa ---" >> evidencias/repository-validation.txt
docker exec iga-postgres psql -U midpoint_user -d midpoint -c "\dt" 2>&1 | head -5 >> evidencias/repository-validation.txt

# Exibir resultado
cat evidencias/repository-validation.txt

# ====================================
# ⚠️ CHECKPOINT CRÍTICO
# ====================================
# Se o arquivo evidencias/repository-validation.txt NÃO contiver:
# - "MP_SET_midpoint.repository.database=postgresql"
# - "midpoint.repository.database .:. postgresql"
# - Tabelas do PostgreSQL (m_user, m_role, etc.)
# PARAR IMEDIATAMENTE e executar rollback

# ====================================
# ETAPA 6: Validar Containers
# ====================================
docker ps

# Esperado:
# CONTAINER ID   IMAGE                   STATUS
# xxxxxxxxxx     evolveum/midpoint:4.8   Up X minutes
# yyyyyyyyyy     postgres:16-alpine      Up X minutes (healthy)

# ====================================
# ETAPA 7: Salvar Logs Completos
# ====================================
docker logs iga-postgres > evidencias/postgres-bootstrap.log 2>&1
docker logs iga-midpoint > evidencias/midpoint-bootstrap.log 2>&1
```

### **8.3. Aguardar Estabilização da Aplicação**

```bash
# Aguardar 2 minutos
echo "Aguardando estabilização completa (120 segundos)..."
sleep 120

# Testar endpoint HTTP
curl -I http://localhost:8080/midpoint
# Esperado: HTTP/1.1 200 ou 302

# Salvar evidência
curl -v http://localhost:8080/midpoint > evidencias/http-response.txt 2>&1
```

---

## **11. FASE 9: VALIDAÇÃO E TESTES**

### **9.1. Testes Internos (Dentro da VM)**

```bash
# ====================================
# TESTE 1: Containers Rodando
# ====================================
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# ====================================
# TESTE 2: Logs Sem Erros Críticos
# ====================================
docker logs iga-postgres 2>&1 | grep -i "error\|fatal" | wc -l
docker logs iga-midpoint 2>&1 | grep -i "error\|fatal" | grep -v "ErrorPage" | wc -l
# Esperado: 0 para ambos

# ====================================
# TESTE 3: ✅ Verificar Tipo de Repositório
# ====================================
docker logs iga-midpoint 2>&1 | grep "midpoint.repository.database"
# Esperado: midpoint.repository.database .:. postgresql
# ❌ Se mostrar "h2", FALHA CRÍTICA

# ====================================
# TESTE 4: Conectividade com Banco
# ====================================
docker exec iga-midpoint /bin/bash -c "timeout 5 bash -c '</dev/tcp/postgres/5432' && echo 'PostgreSQL alcançável' || echo 'Falha'"

# ====================================
# TESTE 5: Portas Abertas
# ====================================
sudo netstat -tulpn | grep -E '8080|5432'
# Esperado: tcp6 ... :::8080 ... LISTEN

# ====================================
# TESTE 6: Persistência de Dados
# ====================================
ls -lh /srv/iga-project/data/postgres/
ls -lh /srv/iga-project/data/midpoint/var/
# Esperado: diretórios com arquivos
```

### **9.2. Obter IP da VM para Acesso Externo**

```bash
IP_VM=$(hostname -I | awk '{print $1}')
echo "Endereço IP da VM: $IP_VM"
echo "URL de Acesso: http://$IP_VM:8080/midpoint"

# Salvar informações
cat > ACCESS_INFO.txt << EOF
================================
INFORMAÇÕES DE ACESSO - IGA
================================
URL: http://$IP_VM:8080/midpoint
Usuário: administrator
Senha: [Conforme .env em MIDPOINT_ADMIN_PASSWORD]

Tipo de Repositório: PostgreSQL (validado)
Data do Deploy: $(date)
================================
EOF

cat ACCESS_INFO.txt
```

### **9.3. Teste de Acesso Web (Do Windows Host)**

**Executar no PowerShell do Windows:**

```powershell
# Substitua pelo IP da sua VM
$VM_IP = "192.168.1.100"

# Testar alcançabilidade
Test-NetConnection -ComputerName $VM_IP -Port 8080
# Esperado: TcpTestSucceeded : True

# Testar resposta HTTP
Invoke-WebRequest -Uri "http://$VM_IP:8080/midpoint" -UseBasicParsing | Select-Object StatusCode
# Esperado: StatusCode: 200
```

### **9.4. Teste de Login na Interface Web**

**Ação Manual Obrigatória:**

1. Abrir navegador no Windows
2. Acessar: `http://[IP_DA_VM]:8080/midpoint`
3. Na tela de login:
   - **Usuário:** `administrator`
   - **Senha:** [Valor definido no .env]
4. Clicar em "Sign In"

**Resultado Esperado:**
- ✅ Acesso concedido
- ✅ Dashboard do midPoint exibido
- ✅ Menu lateral funcional

### **9.5. Teste de Persistência**

```bash
# Parar containers
docker compose down
sleep 10

# Reiniciar
docker compose up -d
sleep 60

# Validar dados persistiram
docker exec iga-postgres psql -U midpoint_user -d midpoint -c "SELECT COUNT(*) FROM m_user;"
# Esperado: count >= 1 (administrator existe)
```

---

## **12. TROUBLESHOOTING E DIAGNÓSTICOS**

### **12.1. ✅ Problema: midPoint Usando H2 ao Invés de PostgreSQL**

**Sintoma:** Login falha, logs mostram `h2` ao invés de `postgresql`

**Causa Raiz:** Variáveis de ambiente não reconhecidas

**Solução:**

```bash
# 1. Parar ambiente
docker compose down

# 2. Limpar dados do H2
sudo rm -rf /srv/iga-project/data/midpoint/var/*

# 3. Verificar docker-compose.yml
cat docker-compose.yml | grep -A 5 "midpoint:" | grep MP_SET

# Esperado (v3.0 CORRETO):
# MP_SET_midpoint.repository.database: postgresql
# MP_SET_midpoint.repository.jdbcUrl: jdbc:postgresql://...
# MP_SET_midpoint.repository.jdbcUsername: ${POSTGRES_USER}
# MP_SET_midpoint.repository.jdbcPassword: ${POSTGRES_PASSWORD}

# 4. Verificar .env
cat .env

# Esperado: valores entre aspas simples
# POSTGRES_PASSWORD='SenhaAqui!'

# 5. Reiniciar
docker compose up -d

# 6. Validar
docker logs iga-midpoint 2>&1 | grep "midpoint.repository.database"
# Esperado: postgresql
```

### **12.2. ✅ Problema: Erro SCRAM - "password authentication failed"**

**Sintoma:** PostgreSQL rejeita conexão do midPoint

**Causa Raiz:** Caracteres especiais na senha interpretados pelo shell

**Solução:**

```bash
# 1. Verificar .env
cat .env | grep POSTGRES_PASSWORD

# ❌ ERRADO: POSTGRES_PASSWORD=P@ssw0rd!
# ✅ CORRETO: POSTGRES_PASSWORD='P@ssw0rd!'

# 2. Editar .env
nano .env
# Adicionar aspas simples em TODAS as senhas

# 3. Limpar volumes
docker compose down
sudo rm -rf /srv/iga-project/data/postgres/*

# 4. Reiniciar
docker compose up -d
```

### **12.3. Problema: Arquivo Netplan Não Encontrado**

**Sintoma:** `No such file or directory` ao editar `/etc/netplan/00-installer-config.yaml`

**Solução:**

```bash
# 1. Listar arquivos reais
ls -la /etc/netplan/

# Exemplo de saída:
# -rw-r--r-- 1 root root  116 Jan 19 10:23 01-netcfg.yaml

# 2. Usar o nome EXATO
sudo nano /etc/netplan/01-netcfg.yaml

# 3. NUNCA assuma nome padrão
```

### **12.4. Problema: Sudoers Rejeitando Comandos**

**Sintoma:** `user is not allowed to execute '/usr/bin/comando'`

**Solução:**

```bash
# 1. Validar configuração
sudo -l

# 2. Se não aparecer caminhos completos, reconfigurar
sudo visudo

# 3. CORRIGIR linha:
# ❌ ERRADO: usuario ALL=(ALL) NOPASSWD: mkdir, chown
# ✅ CORRETO: usuario ALL=(ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/chown, /usr/bin/docker, /usr/bin/du, /usr/bin/rm, /usr/bin/whoami
```

---

## **13. MANUTENÇÃO E OPERAÇÃO**

### **13.1. Backup do Ambiente**

```bash
cat > /srv/iga-project/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/srv/iga-project/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.tar.gz"

echo "Iniciando backup em $(date)"
docker compose down

sudo tar -czf $BACKUP_FILE \
    -C /srv/iga-project \
    data/ \
    .env \
    docker-compose.yml

docker compose up -d
echo "Backup concluído: $BACKUP_FILE"
EOF

chmod +x backup.sh
./backup.sh
```

### **13.2. Comandos Úteis**

```bash
# Gestão de Containers
docker compose up -d              # Iniciar
docker compose down               # Parar
docker compose restart            # Reiniciar
docker compose logs -f            # Logs em tempo real

# Diagnóstico
docker logs iga-midpoint          # Logs do midPoint
docker logs iga-postgres          # Logs do PostgreSQL
docker exec -it iga-midpoint bash # Shell do container
docker stats                      # Uso de recursos

# ✅ Validação de Repositório
docker logs iga-midpoint 2>&1 | grep "midpoint.repository.database"
```

---

## **14. REFERÊNCIAS E DOCUMENTAÇÃO**

### **14.1. Documentação Oficial**

- **midPoint:** https://docs.evolveum.com/midpoint/
- **PostgreSQL:** https://www.postgresql.org/docs/
- **Docker:** https://docs.docker.com/
- **Ubuntu Server:** https://ubuntu.com/server/docs

### **14.2. Configuração de Referência Completa**

**docker-compose.yml (v3.0):**
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: iga-postgres
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - ./data/postgres:/var/lib/postgresql/data
    networks:
      - iga-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  midpoint:
    image: evolveum/midpoint:4.8
    container_name: iga-midpoint
    ports:
      - "8080:8080"
    environment:
      MP_SET_midpoint.repository.database: postgresql
      MP_SET_midpoint.repository.jdbcUrl: jdbc:postgresql://postgres:5432/${POSTGRES_DB}
      MP_SET_midpoint.repository.jdbcUsername: ${POSTGRES_USER}
      MP_SET_midpoint.repository.jdbcPassword: ${POSTGRES_PASSWORD}
      MP_SET_midpoint.administrator.initialPassword: ${MIDPOINT_ADMIN_PASSWORD}
    volumes:
      - ./data/midpoint/var:/opt/midpoint/var
      - ./logs/midpoint:/opt/midpoint/var/log
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - iga-network
    restart: unless-stopped

networks:
  iga-network:
    driver: bridge
```

**Arquivo .env (v3.0):**
```bash
POSTGRES_DB='midpoint'
POSTGRES_USER='midpoint_user'
POSTGRES_PASSWORD='SuaSenhaSeguraPostgreSQL123!'
MIDPOINT_ADMIN_PASSWORD='SuaSenhaSeguraMidPoint456!'
```

### **14.3. Portas Utilizadas**

| Porta | Serviço | Protocolo | Acesso |
|-------|---------|-----------|--------|
| 22 | SSH | TCP | Externo (administração) |
| 8080 | midPoint Web UI | TCP | Externo (interface web) |
| 5432 | PostgreSQL | TCP | Interno (apenas containers) |

---

## **APÊNDICE A: CHECKLIST DE VALIDAÇÃO COMPLETA**

### **Pré-requisitos Windows**
- [ ] Hyper-V habilitado e funcional
- [ ] ISO do Ubuntu baixada
- [ ] Virtual Switch criado

### **Fase 1-4: Infraestrutura**
- [ ] VM criada com recursos adequados
- [ ] Ubuntu instalado
- [ ] SSH acessível
- [ ] Sistema atualizado

### **Fase 5: Hardening**
- [ ] Arquivo Netplan identificado (`ls /etc/netplan/`)
- [ ] IP estático configurado
- [ ] Sudoers com caminhos completos (`/usr/bin/...`)
- [ ] Whitelist de 6 binários validada

### **Fase 6-7: Docker e Estrutura**
- [ ] Docker instalado
- [ ] Teste `hello-world` bem-sucedido
- [ ] Diretórios criados
- [ ] `docker-compose.yml` v3.0 criado
- [ ] `.env` criado com aspas simples

### **Fase 8-9: Deploy e Validação**
- [ ] 7 validações pré-deploy aprovadas
- [ ] PostgreSQL healthy
- [ ] midPoint inicializado
- [ ] ✅ **Validação tripla de repositório aprovada**
- [ ] Login bem-sucedido
- [ ] Teste de persistência aprovado

---

## **CONTROLE DE VERSÃO DO DOCUMENTO**

| Versão | Data | Mudanças |
|--------|------|----------|
| 1.0 | Janeiro/2026 | Criação do POP |
| 2.0 | Janeiro/2026 | Correção variáveis JDBC |
| 2.1 | Janeiro/2026 | Hardening + alinhamento GMUD |
| **3.0** | **Janeiro/2026** | **Sintaxe MP_SET + proteção caracteres especiais + remoção dados sensíveis + validação tripla** |

---

## **STATUS DO DOCUMENTO**

**Versão:** v3.0 (ESTÁVEL - GITHUB READY)  
**Status:** ✅ **Aprovado para Publicação**  
**Conformidade:** ISO 27001:2022, NIST CSF 2.0, CIS Controls v8  
**Classificação:** 🔓 Público (dados sensíveis removidos)

---

## **⚠️ AVISO DE SEGURANÇA**

1. **Nunca versione o arquivo `.env`**
2. **Use senhas fortes** (mínimo 16 caracteres)
3. **Sempre use aspas simples** no `.env` para caracteres especiais
4. **Valide tipo de repositório** após cada deploy
5. **Implemente backups regulares**

---

**LICENÇA DE USO:**

Este documento pode ser usado, modificado e distribuído livremente para fins educacionais e comerciais, desde que mantida a atribuição ao autor original.

---

**FIM DO DOCUMENTO POP-IGA-001 v3.0**

**Repositório Sugerido:** `docs/procedures/POP-IGA-001-v3.0-Stable.md`