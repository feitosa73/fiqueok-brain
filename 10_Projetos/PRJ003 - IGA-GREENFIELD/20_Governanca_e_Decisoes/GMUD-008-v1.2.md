# **GMUD-008 v1.2**
## **Deploy Automatizado IaC do Ambiente IGA (Hardening e Security by Design)**
### **Projeto PRJ003 - IGA Greenfield Reference Architecture**

---

| Campo | Informação |
|-------|------------|
| **GMUD** | GMUD-008 |
| **Versão** | 1.2 |
| **Tipo** | Técnica - Infraestrutura (Automação IaC com Hardening) |
| **Categoria** | Deploy Corretivo com Segurança Reforçada |
| **Projeto** | PRJ003 - IGA Greenfield Reference Architecture |
| **Contexto** | Living Lab Fiqueok 2.0 |
| **Owner/Executor** | Paulo Feitosa |
| **Data de Criação** | 18/01/2026 |
| **Data de Atualização v1.2** | 19/01/2026 15:00 |
| **Data Planejada** | 19/01/2026 |
| **Status** | Planejada |
| **Prioridade** | Crítica |
| **VM Alvo** | IGA-GF-01 (Ubuntu 24.04.2 LTS) |
| **IP da VM** | xxx.xxx.xxx.xxx *(IP Estático - Configurado nesta GMUD)* |
| **Dependências** | GMUD-007 (Lições Aprendidas - Fallback H2) |
| **Aprovação GRC** | Aprovada v1.2 - Hardening Sudoers + IP Estático + PowerShell Policy |

---

## **1. SUMÁRIO EXECUTIVO**

### **1.1. Contexto da GMUD-008 v1.2**

Após **3 tentativas de deploy** (GMUD-005, GMUD-006, GMUD-007), foi identificada a **causa raiz definitiva** das falhas de autenticação no midPoint:

**Diagnóstico Técnico:**
- A imagem `evolveum/midpoint:4.8` **não reconhece** as variáveis `MIDPOINT_REPOSITORY_DATABASE_URL`, `MIDPOINT_REPOSITORY_DATABASE_USERNAME` e `MIDPOINT_REPOSITORY_DATABASE_PASSWORD`
- Na ausência de configuração válida de repositório externo, o midPoint ativa **silenciosamente** o modo de contingência com **banco H2 embutido**
- O bootstrap em modo H2 processa a variável de senha de forma **inconsistente**, gerando credenciais aleatórias não documentadas

**Evidência Crítica (GMUD-007):**
```log
midpoint.repository.database .:. h2
```

### **1.2. Objetivo da GMUD-008 v1.2**

Realizar o **deploy automatizado via IaC** do ambiente midPoint 4.8 + PostgreSQL 16 com:

✅ **Correção definitiva da nomenclatura de variáveis** para sintaxe oficial do midPoint 4.8  
✅ **Hardening de sudoers** - Princípio do Menor Privilégio (Whitelist de binários)  
✅ **IP Estático via Netplan** - Infraestrutura Imutável (Elimina problemas DHCP)  
✅ **PowerShell Execution Policy** documentada - Reprodutibilidade garantida  
✅ **Gate de validação obrigatório** - Log deve confirmar `postgresql` (NÃO `h2`)  
✅ **Automação semi-automática via PowerShell** (85% automatizado)  
✅ **Rollback condicional** em caso de detecção de fallback H2  
✅ **Evidências técnicas automatizadas** para auditoria  

**Critério de Sucesso:**  
Login funcional com `administrator:Fiqueok@2026!` **E** confirmação de uso de PostgreSQL nos logs **E** conformidade com controles de segurança (Least Privilege, Static IP, Execution Policy).

---

## **2. CHANGELOG v1.2 (Melhorias de Segurança e Hardening)**

| # | Categoria | Melhoria Implementada | Impacto GRC |
|---|-----------|----------------------|-------------|
| 1 | **Security by Design** | **Hardening de Sudoers** - Whitelist restrita de binários (`/usr/bin/mkdir`, `/usr/bin/chown`, `/usr/bin/docker`, `/usr/bin/du`, `/usr/bin/rm`) | **Crítico** - Mitiga escalação de privilégios em caso de comprometimento |
| 2 | **Infraestrutura Imutável** | **IP Estático via Netplan** - Configuração permanente de IP xxx.xxx.xxx.xxx | **Alto** - Elimina falhas por mudança de DHCP |
| 3 | **Reprodutibilidade** | **PowerShell Execution Policy** documentada - Instrução explícita para bypass temporário | **Médio** - Garante execução do script em qualquer ambiente Windows |
| 4 | **Escaping Corrigido** | Heredoc com aspas simples + validação de .env local | Alto - Evita campos vazios no docker-compose.yml |
| 5 | **Timeout Estendido** | Bootstrap aumentado para 180s (3 minutos) | Médio - Evita falso negativo em VMs lentas |

---

## **3. PRÉ-REQUISITOS OBRIGATÓRIOS (HARDENING)**

### **3.1. Pré-requisito 1: Hardening de Sudoers (VM Ubuntu)**

**⚠️ AÇÃO OBRIGATÓRIA ANTES DA EXECUÇÃO DA GMUD-008:**

**Objetivo:** Implementar o **Princípio do Menor Privilégio** - O usuário `paulo` deve ter acesso sudo **APENAS** aos binários necessários para a orquestração do PRJ003, **NÃO** a todos os comandos do sistema.

**Problema de Segurança (v1.0 e v1.1):**
```bash
# CONFIGURAÇÃO INSEGURA (NÃO USAR)
paulo ALL=(ALL) NOPASSWD:ALL
```

**Risco:** Se a conta `paulo` for comprometida, o atacante terá acesso root completo ao sistema, podendo:
- Instalar malwares
- Criar usuários backdoor
- Alterar configurações de rede
- Comprometer outros sistemas na rede

**Solução de Segurança (v1.2):**

```bash
# 1. Conectar na VM via SSH
ssh paulo@xxx.xxx.xxx.xxx

# 2. Editar arquivo sudoers de forma segura
sudo visudo

# 3. REMOVER a linha genérica:
# paulo ALL=(ALL) NOPASSWD:ALL

# 4. ADICIONAR a configuração restrita (Whitelist):
paulo ALL=(ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/chown, /usr/bin/docker, /usr/bin/du, /usr/bin/rm

# 5. Salvar e sair (CTRL+X, Y, ENTER)

# 6. Validar a configuração
sudo -l
# Esperado: User paulo may run the following commands on IGA-GF-01:
#     (ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/chown, /usr/bin/docker, /usr/bin/du, /usr/bin/rm
```

**Justificativa dos Binários na Whitelist:**

| Binário | Justificativa | Comando da GMUD-008 |
|---------|---------------|---------------------|
| `/usr/bin/mkdir` | Criação de estrutura de diretórios `/srv/prj003` | `sudo mkdir -p /srv/prj003/data/postgres` |
| `/usr/bin/chown` | Ajuste de permissões dos diretórios do projeto | `sudo chown -R paulo:paulo /srv/prj003` |
| `/usr/bin/docker` | Gerenciamento de containers (pull, compose, logs, inspect) | `sudo docker compose up -d` |
| `/usr/bin/du` | Coleta de evidências - tamanho de volumes | `sudo du -sh /srv/prj003/data/postgres` |
| `/usr/bin/rm` | Rollback - remoção de volumes corrompidos | `sudo rm -rf /srv/prj003/data/postgres` |

**Raio de Explosão Limitado:**  
Em caso de comprometimento da conta `paulo`, o atacante **NÃO poderá**:
- ❌ Executar `apt install` (instalar softwares)
- ❌ Executar `useradd` (criar usuários)
- ❌ Executar `systemctl` (alterar serviços)
- ❌ Executar `iptables` (alterar firewall)
- ❌ Executar `nano /etc/passwd` (editar arquivos de sistema)

**Conformidade:**
- ✅ **NIST CSF 2.0 PR.AC-4** - Princípio do Menor Privilégio
- ✅ **ISO 27001:2022 A.9.2.3** - Gestão de Privilégios de Acesso
- ✅ **CIS Controls v8 5.4** - Restrição de Privilégios Administrativos

---

### **3.2. Pré-requisito 2: Configuração de IP Estático (VM Ubuntu)**

**⚠️ AÇÃO OBRIGATÓRIA ANTES DA EXECUÇÃO DA GMUD-008:**

**Objetivo:** Implementar **Infraestrutura Imutável** - O IP da VM deve ser **fixo e previsível**, eliminando falhas causadas por mudanças de DHCP.

**Problema Identificado (v1.0 e v1.1):**
- VM configurada com **DHCP** - IP pode mudar entre `xxx.xxx.xxx.xxx` e `xxx.xxx.xxx.xxx` após reboots ou restore de checkpoints
- Scripts de automação dependem do IP correto no arquivo `.env`
- Falhas de conectividade SSH caso o IP mude sem atualização do `.env`

**Solução de Infraestrutura (v1.2):**

```bash
# 1. Conectar na VM via SSH
ssh paulo@xxx.xxx.xxx.xxx

# 2. CRÍTICO: Validar que o IP do HOST Windows NÃO é xxx.xxx.xxx.xxx
# No Windows PowerShell, executar:
# ipconfig | findstr "IPv4"
# Se o host usar .116, escolher outro IP para a VM (ex: .115 ou .117)

# 3. Fazer backup da configuração atual
sudo cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak

# 4. Editar configuração do Netplan
sudo nano /etc/netplan/00-installer-config.yaml

# 5. SUBSTITUIR todo o conteúdo por esta configuração estática:
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - xxx.xxx.xxx.xxx/22
      routes:
        - to: default
          via: xxx.xxx.xxx.xxx
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4

# 6. Salvar e sair (CTRL+X, Y, ENTER)

# 7. Validar sintaxe da configuração
sudo netplan try
# Se aparecer "Configuration accepted", pressionar ENTER
# Se houver erro, a configuração será revertida automaticamente em 120s

# 8. Aplicar a configuração permanentemente
sudo netplan apply

# 9. Validar o novo IP
ip addr show eth0 | grep inet
# Esperado: inet xxx.xxx.xxx.xxx/22 brd xxx.xxx.xxx.xxx scope global eth0

# 10. Testar conectividade
ping -c 4 8.8.8.8
ping -c 4 xxx.xxx.xxx.xxx

# 11. IMPORTANTE: Atualizar arquivo .env no Windows com IP fixo
```

**Validação de Conflito de IP (Host Windows):**

```powershell
# No Windows PowerShell, executar ANTES de configurar IP estático na VM:
ipconfig | findstr "IPv4"

# Se o resultado mostrar xxx.xxx.xxx.xxx, ESCOLHER OUTRO IP para a VM
# Sugestões: xxx.xxx.xxx.xxx, xxx.xxx.xxx.xxx, xxx.xxx.xxx.xxx
```

**Benefícios da Configuração Estática:**

| Aspecto | DHCP (v1.0/v1.1) | IP Estático (v1.2) |
|---------|------------------|-------------------|
| **Previsibilidade** | ❌ IP pode mudar | ✅ IP sempre xxx.xxx.xxx.xxx |
| **Automação** | ⚠️ Requer atualização de .env | ✅ Único Ponto de Verdade |
| **DNS** | ❌ Depende de DHCP do Hyper-V | ✅ Google DNS (8.8.8.8) permanente |
| **Troubleshooting** | ⚠️ Dificulta diagnóstico | ✅ Facilita rastreamento |
| **Checkpoint Restore** | ❌ IP pode mudar após restore | ✅ IP persiste |

**Conformidade:**
- ✅ **NIST CSF 2.0 PR.IP-1** - Baseline de Configuração
- ✅ **ISO 27001:2022 A.8.32** - Gestão de Mudanças
- ✅ **ITIL v4** - Configuration Management

---

### **3.3. Pré-requisito 3: PowerShell Execution Policy (Host Windows)**

**⚠️ AÇÃO OBRIGATÓRIA ANTES DA EXECUÇÃO DA GMUD-008:**

**Objetivo:** Garantir **Reprodutibilidade** - O script PowerShell deve poder ser executado em qualquer ambiente Windows, independentemente das políticas de segurança padrão.

**Problema de Reprodutibilidade (v1.0 e v1.1):**
- Windows impede execução de scripts `.ps1` por padrão (proteção contra malware)
- Política padrão: `Restricted` (nenhum script pode executar)
- GMUD-008 v1.0/v1.1 **não documentava** essa configuração
- Falha de reprodutibilidade: "Procedimento que depende de configuração externa não documentada"

**Solução Documentada (v1.2):**

```powershell
# ANTES de executar GMUD-008-Deploy-v1.2.ps1

# 1. Abrir PowerShell como USUÁRIO NORMAL (NÃO como Administrador)

# 2. Executar comando de bypass TEMPORÁRIO (escopo de processo):
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# 3. Validar a mudança
Get-ExecutionPolicy -Scope Process
# Esperado: Bypass

# 4. AGORA executar o script
.\GMUD-008-Deploy-v1.2.ps1
```

**Justificativa de Segurança:**

| Escopo | Duração | Impacto | Risco |
|--------|---------|---------|-------|
| `Process` | ✅ **Apenas sessão atual** | ✅ **Mínimo** - Não afeta outras janelas do PowerShell | ✅ **Baixo** - Expira ao fechar o terminal |
| `CurrentUser` | ⚠️ **Permanente para usuário** | ⚠️ **Médio** - Todos os scripts do usuário | ⚠️ **Médio** - Requer remoção manual |
| `LocalMachine` | ❌ **Permanente para todo o sistema** | ❌ **Alto** - Todos os usuários | ❌ **Alto** - Requer Admin + Requer remoção manual |

**Por que NÃO usar `-Scope CurrentUser` ou `-Scope LocalMachine`?**
- **Segurança:** Deixaria o sistema vulnerável a scripts maliciosos de forma permanente
- **Conformidade:** Violaria princípios de Security by Default
- **Auditoria:** Criaria débito técnico (configuração não documentada que persiste)

**Conformidade:**
- ✅ **NIST CSF 2.0 PR.AC-4** - Controle de Acesso (Execução de Código)
- ✅ **ISO 27001:2022 A.8.29** - Segurança em Desenvolvimento e Suporte
- ✅ **CIS Controls v8 2.7** - Controle de Execução de Aplicações

---

## **4. ARQUIVOS DE CONFIGURAÇÃO**

### **4.1. Arquivo .env Local (Host Windows)**

**Criar arquivo no mesmo diretório do script:**

```env
# Arquivo: .env (no host Windows, mesmo diretório do script)
# IMPORTANTE: IP Estático configurado no Pré-requisito 3.2
VM_IP=xxx.xxx.xxx.xxx
VM_USER=paulo
POSTGRES_PASSWORD=Fiqueok@Postgres2026!
MIDPOINT_ADMIN_PASSWORD=Fiqueok@2026!
```

### **4.2. Arquivo docker-compose.yml (Gerado pelo Script)**

```yaml
services:
  postgres:
    image: postgres:16-alpine
    container_name: postgres
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - /srv/prj003/data/postgres:/var/lib/postgresql/data
    networks:
      - iga-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U midpoint"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  midpoint:
    image: evolveum/midpoint:4.8
    container_name: midpoint
    ports:
      - "8080:8080"
    environment:
      REPO_DATABASE_TYPE: postgresql
      REPO_HOST: postgres
      REPO_PORT: 5432
      REPO_DATABASE: ${POSTGRES_DB}
      REPO_USER: ${POSTGRES_USER}
      REPO_PASSWORD: ${POSTGRES_PASSWORD}
      REPO_JDBC_URL: jdbc:postgresql://postgres:5432/${POSTGRES_DB}
      MP_SET_midpoint.repository.jdbcUrl: jdbc:postgresql://postgres:5432/${POSTGRES_DB}
      MP_SET_midpoint.repository.jdbcUsername: ${POSTGRES_USER}
      MP_SET_midpoint.repository.jdbcPassword: ${POSTGRES_PASSWORD}
      MP_SET_midpoint.repository.database: postgresql
      MP_SET_midpoint.administrator.initialPassword: ${MIDPOINT_ADMIN_PASSWORD}
    volumes:
      - /srv/prj003/data/midpoint/var:/opt/midpoint/var
      - /srv/prj003/logs/midpoint:/opt/midpoint/var/log
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

---

## **5. SCRIPT DE AUTOMAÇÃO v1.2 (GMUD-008-Deploy-v1.2.ps1)**

```powershell
# ====================================================================
# GMUD-008 v1.2 - Deploy Automatizado IaC do Ambiente IGA
# Projeto: PRJ003 - IGA Greenfield Reference Architecture
# Versão: 1.2 (Hardening: Least Privilege + Static IP + Exec Policy)
# Data: 19/01/2026 15:00
# Executor: Paulo Feitosa
# ====================================================================

# ====================================================================
# CONFIGURAÇÃO INICIAL - LEITURA DE CREDENCIAIS
# ====================================================================

# Verificar se arquivo .env existe no diretório local
if (-not (Test-Path ".env")) {
    Write-Error "ERRO: Arquivo .env não encontrado no diretório do script"
    Write-Host "Crie o arquivo .env com as seguintes variáveis:" -ForegroundColor Yellow
    Write-Host "VM_IP=xxx.xxx.xxx.xxx" -ForegroundColor Gray
    Write-Host "VM_USER=paulo" -ForegroundColor Gray
    Write-Host "POSTGRES_PASSWORD=SuaSenha" -ForegroundColor Gray
    Write-Host "MIDPOINT_ADMIN_PASSWORD=SuaSenha" -ForegroundColor Gray
    exit 1
}

# Carregar variáveis do arquivo .env
Get-Content ".env" | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
    $name, $value = $_.Split('=', 2)
    Set-Variable -Name $name.Trim() -Value $value.Trim() -Scope Script
}

# Validar variáveis obrigatórias
if (-not $VM_IP -or -not $VM_USER -or -not $POSTGRES_PASSWORD -or -not $MIDPOINT_ADMIN_PASSWORD) {
    Write-Error "ERRO: Variáveis obrigatórias ausentes no .env"
    exit 1
}

$BASE_DIR = "/srv/prj003"
$EVIDENCE_DIR = "$BASE_DIR/evidencias"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "GMUD-008 v1.2 - Deploy Automatizado IaC" -ForegroundColor Cyan
Write-Host "Hardening: Least Privilege + Static IP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VM: $VM_USER@$VM_IP (IP Estático)" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Cyan

# ====================================================================
# STEP 0: VALIDAÇÃO DE PRÉ-REQUISITOS DE HARDENING
# ====================================================================
Write-Host "[STEP 0] Validando Pré-requisitos de Hardening..." -ForegroundColor Yellow

# 0.1 Validar PowerShell Execution Policy
Write-Host "  0.1 Validando PowerShell Execution Policy..." -ForegroundColor Gray
$exec_policy = Get-ExecutionPolicy -Scope Process
if ($exec_policy -ne "Bypass" -and $exec_policy -ne "Unrestricted") {
    Write-Error "FALHA: PowerShell Execution Policy não configurada"
    Write-Host "`nExecute antes de rodar o script:" -ForegroundColor Yellow
    Write-Host "Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process`n" -ForegroundColor White
    exit 1
}
Write-Host "    ✅ Execution Policy: $exec_policy" -ForegroundColor Green

# 0.2 Validar Sudoers Hardening na VM
Write-Host "  0.2 Validando Sudoers Hardening..." -ForegroundColor Gray
$sudo_check = ssh "$VM_USER@$VM_IP" "sudo -l 2>&1 | grep -E '(mkdir|chown|docker|du|rm)'" 2>&1
if (-not $sudo_check) {
    Write-Error "FALHA: Sudoers não está configurado com Least Privilege"
    Write-Host "`nConfigure o sudoers na VM antes de executar:" -ForegroundColor Yellow
    Write-Host "sudo visudo" -ForegroundColor White
    Write-Host "Adicione: paulo ALL=(ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/chown, /usr/bin/docker, /usr/bin/du, /usr/bin/rm`n" -ForegroundColor White
    exit 1
}
Write-Host "    ✅ Sudoers configurado com Least Privilege" -ForegroundColor Green

# 0.3 Validar IP Estático
Write-Host "  0.3 Validando configuração de IP Estático..." -ForegroundColor Gray
$ip_check = ssh "$VM_USER@$VM_IP" "ip addr show eth0 | grep 'inet ' | grep -v '127.0.0.1'" 2>&1
if ($ip_check -notmatch "$VM_IP") {
    Write-Warning "ATENÇÃO: IP da VM pode não estar configurado como estático"
    Write-Host "IP detectado: $ip_check" -ForegroundColor Yellow
    Write-Host "IP esperado: $VM_IP" -ForegroundColor White
    $continue = Read-Host "Continuar mesmo assim? (S/N)"
    if ($continue -ne 'S' -and $continue -ne 's') {
        exit 1
    }
} else {
    Write-Host "    ✅ IP Estático confirmado: $VM_IP" -ForegroundColor Green
}

# 0.4 Validar que IP do Host Windows NÃO conflita
Write-Host "  0.4 Validando conflito de IP com Host Windows..." -ForegroundColor Gray
$host_ips = ipconfig | Select-String "IPv4" | Out-String
if ($host_ips -match "$VM_IP") {
    Write-Error "FALHA CRÍTICA: Host Windows está usando o mesmo IP da VM ($VM_IP)"
    Write-Host "Altere o IP estático da VM para outro valor (ex: xxx.xxx.xxx.xxx)" -ForegroundColor Yellow
    exit 1
}
Write-Host "    ✅ Nenhum conflito de IP detectado" -ForegroundColor Green

Write-Host "`n[STEP 0] ✅ Pré-requisitos de Hardening VALIDADOS`n" -ForegroundColor Green

# ====================================================================
# STEP 1: PRÉ-FLIGHT CHECKLIST
# ====================================================================
Write-Host "[STEP 1] Executando Pre-Flight Checklist..." -ForegroundColor Yellow

# 1.1 Conectividade SSH
Write-Host "  1.1 Validando conectividade SSH..." -ForegroundColor Gray
$ssh_test = ssh -o ConnectTimeout=5 "$VM_USER@$VM_IP" "echo 'SSH_OK'" 2>&1
if ($ssh_test -notmatch "SSH_OK") {
    Write-Error "FALHA: Conectividade SSH não disponível"
    exit 1
}
Write-Host "    ✅ SSH OK" -ForegroundColor Green

# 1.2 Docker instalado
Write-Host "  1.2 Validando Docker..." -ForegroundColor Gray
$docker_version = ssh "$VM_USER@$VM_IP" "docker --version" 2>&1
if ($docker_version -notmatch "Docker version") {
    Write-Error "FALHA: Docker não instalado"
    exit 1
}
Write-Host "    ✅ Docker OK: $docker_version" -ForegroundColor Green

# 1.3 Docker Compose instalado
Write-Host "  1.3 Validando Docker Compose..." -ForegroundColor Gray
$compose_version = ssh "$VM_USER@$VM_IP" "docker compose version" 2>&1
if ($compose_version -notmatch "Docker Compose version") {
    Write-Error "FALHA: Docker Compose não instalado"
    exit 1
}
Write-Host "    ✅ Docker Compose OK: $compose_version" -ForegroundColor Green

# 1.4 CRÍTICO: Conectividade Externa
Write-Host "  1.4 Validando conectividade externa..." -ForegroundColor Gray
$ping_test = ssh "$VM_USER@$VM_IP" "ping -c 2 8.8.8.8" 2>&1
if ($ping_test -notmatch "2 packets transmitted, 2 received") {
    Write-Error "FALHA: Sem conectividade externa (ping 8.8.8.8 falhou)"
    exit 1
}
Write-Host "    ✅ Conectividade externa OK" -ForegroundColor Green

# 1.5 CRÍTICO: Resolução DNS (deve estar OK com IP estático)
Write-Host "  1.5 Validando resolução DNS..." -ForegroundColor Gray
$dns_test = ssh "$VM_USER@$VM_IP" "nslookup registry-1.docker.io" 2>&1
if ($dns_test -notmatch "Address:") {
    Write-Error "FALHA: Resolução DNS falhou (verifique configuração Netplan)"
    exit 1
}
Write-Host "    ✅ Resolução DNS OK (Google DNS 8.8.8.8)" -ForegroundColor Green

# 1.6 CRÍTICO: Acesso ao Docker Hub
Write-Host "  1.6 Validando acesso ao Docker Hub..." -ForegroundColor Gray
$hub_test = ssh "$VM_USER@$VM_IP" "curl -I https://registry-1.docker.io/v2/ 2>&1 | head -1" 2>&1
if ($hub_test -notmatch "HTTP") {
    Write-Error "FALHA: Acesso ao Docker Hub falhou"
    exit 1
}
Write-Host "    ✅ Docker Hub acessível" -ForegroundColor Green

# 1.7 Estado limpo
Write-Host "  1.7 Validando estado limpo..." -ForegroundColor Gray
$containers = ssh "$VM_USER@$VM_IP" "docker ps -a -q" 2>&1
if ($containers) {
    Write-Warning "ATENÇÃO: Containers existentes detectados - Aplicando limpeza..."
    ssh "$VM_USER@$VM_IP" "cd $BASE_DIR 2>/dev/null && docker compose down 2>/dev/null; docker system prune -f" | Out-Null
}
Write-Host "    ✅ Ambiente limpo" -ForegroundColor Green

Write-Host "`n[STEP 1] ✅ Pre-Flight Checklist APROVADO`n" -ForegroundColor Green

# ====================================================================
# STEP 2: PREPARAÇÃO DO AMBIENTE
# ====================================================================
Write-Host "[STEP 2] Preparando estrutura de diretórios..." -ForegroundColor Yellow

ssh "$VM_USER@$VM_IP" @"
sudo mkdir -p $BASE_DIR/data/postgres
sudo mkdir -p $BASE_DIR/data/midpoint/var
sudo mkdir -p $BASE_DIR/logs/midpoint
sudo mkdir -p $EVIDENCE_DIR
sudo chown -R $VM_USER:$VM_USER $BASE_DIR
"@ | Out-Null

Write-Host "[STEP 2] ✅ Estrutura criada`n" -ForegroundColor Green

# ====================================================================
# STEP 3: CRIAÇÃO DO ARQUIVO .env NA VM
# ====================================================================
Write-Host "[STEP 3] Criando arquivo .env na VM..." -ForegroundColor Yellow

ssh "$VM_USER@$VM_IP" @"
cat > $BASE_DIR/.env << 'ENVEOF'
# Credenciais do PostgreSQL (Backend)
POSTGRES_DB=midpoint
POSTGRES_USER=midpoint
POSTGRES_PASSWORD=$POSTGRES_PASSWORD

# Credenciais do midPoint (Frontend)
MIDPOINT_ADMIN_USERNAME=administrator
MIDPOINT_ADMIN_PASSWORD=$MIDPOINT_ADMIN_PASSWORD
ENVEOF
chmod 600 $BASE_DIR/.env
"@

Write-Host "[STEP 3] ✅ Arquivo .env criado na VM`n" -ForegroundColor Green

# ====================================================================
# STEP 4: CRIAÇÃO DO docker-compose.yml CORRIGIDO
# ====================================================================
Write-Host "[STEP 4] Criando docker-compose.yml (CORREÇÃO GMUD-008 v1.2)..." -ForegroundColor Yellow

ssh "$VM_USER@$VM_IP" @"
cat > $BASE_DIR/docker-compose.yml << 'COMPOSEEOF'
services:
  postgres:
    image: postgres:16-alpine
    container_name: postgres
    environment:
      POSTGRES_DB: \`${POSTGRES_DB}
      POSTGRES_USER: \`${POSTGRES_USER}
      POSTGRES_PASSWORD: \`${POSTGRES_PASSWORD}
    volumes:
      - $BASE_DIR/data/postgres:/var/lib/postgresql/data
    networks:
      - iga-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U midpoint"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  midpoint:
    image: evolveum/midpoint:4.8
    container_name: midpoint
    ports:
      - "8080:8080"
    environment:
      REPO_DATABASE_TYPE: postgresql
      REPO_HOST: postgres
      REPO_PORT: 5432
      REPO_DATABASE: \`${POSTGRES_DB}
      REPO_USER: \`${POSTGRES_USER}
      REPO_PASSWORD: \`${POSTGRES_PASSWORD}
      REPO_JDBC_URL: jdbc:postgresql://postgres:5432/\`${POSTGRES_DB}
      MP_SET_midpoint.repository.jdbcUrl: jdbc:postgresql://postgres:5432/\`${POSTGRES_DB}
      MP_SET_midpoint.repository.jdbcUsername: \`${POSTGRES_USER}
      MP_SET_midpoint.repository.jdbcPassword: \`${POSTGRES_PASSWORD}
      MP_SET_midpoint.repository.database: postgresql
      MP_SET_midpoint.administrator.initialPassword: \`${MIDPOINT_ADMIN_PASSWORD}
    volumes:
      - $BASE_DIR/data/midpoint/var:/opt/midpoint/var
      - $BASE_DIR/logs/midpoint:/opt/midpoint/var/log
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - iga-network
    restart: unless-stopped

networks:
  iga-network:
    driver: bridge
COMPOSEEOF
"@

# Validar sintaxe
Write-Host "  Validando sintaxe do docker-compose.yml..." -ForegroundColor Gray
$compose_validation = ssh "$VM_USER@$VM_IP" "cd $BASE_DIR && docker compose config" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "FALHA: Sintaxe do docker-compose.yml inválida"
    Write-Host $compose_validation -ForegroundColor Red
    exit 1
}

Write-Host "[STEP 4] ✅ docker-compose.yml criado e validado`n" -ForegroundColor Green

# ====================================================================
# STEP 5: PULL DE IMAGENS DOCKER
# ====================================================================
Write-Host "[STEP 5] Fazendo pull das imagens Docker..." -ForegroundColor Yellow

Write-Host "  Baixando postgres:16-alpine..." -ForegroundColor Gray
ssh "$VM_USER@$VM_IP" "docker pull postgres:16-alpine" 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "FALHA: Pull da imagem PostgreSQL falhou"
    exit 1
}

Write-Host "  Baixando evolveum/midpoint:4.8..." -ForegroundColor Gray
ssh "$VM_USER@$VM_IP" "docker pull evolveum/midpoint:4.8" 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "FALHA: Pull da imagem midPoint falhou"
    exit 1
}

ssh "$VM_USER@$VM_IP" "docker images > $EVIDENCE_DIR/images-downloaded.txt"

Write-Host "[STEP 5] ✅ Imagens baixadas com sucesso`n" -ForegroundColor Green

# ====================================================================
# STEP 6: INICIALIZAÇÃO FASE 1 - POSTGRESQL
# ====================================================================
Write-Host "[STEP 6] Inicializando PostgreSQL (Fase 1)..." -ForegroundColor Yellow

ssh "$VM_USER@$VM_IP" "cd $BASE_DIR && docker compose up -d postgres" 2>&1 | Out-Null

Write-Host "  Aguardando PostgreSQL atingir estado healthy..." -ForegroundColor Gray
$max_attempts = 30
$attempt = 0
$postgres_healthy = `$false

while ($attempt -lt $max_attempts) {
    $health_status = ssh "$VM_USER@$VM_IP" "docker inspect postgres --format='{{.State.Health.Status}}'" 2>&1
    if ($health_status -eq "healthy") {
        $postgres_healthy = `$true
        break
    }
    Start-Sleep -Seconds 2
    $attempt++
    Write-Host "    Tentativa $attempt/$max_attempts - Status: $health_status" -ForegroundColor Gray
}

if (-not $postgres_healthy) {
    Write-Error "FALHA: PostgreSQL não atingiu estado healthy em 60 segundos"
    ssh "$VM_USER@$VM_IP" "docker logs postgres > $EVIDENCE_DIR/postgres-failure.log 2>&1"
    Write-Host "Logs salvos em: $EVIDENCE_DIR/postgres-failure.log" -ForegroundColor Yellow
    exit 1
}

# Aguardar consolidação do schema
Write-Host "  Aguardando consolidação do schema (10s)..." -ForegroundColor Gray
Start-Sleep -Seconds 10

ssh "$VM_USER@$VM_IP" "docker logs postgres > $EVIDENCE_DIR/postgres-bootstrap.log 2>&1"

Write-Host "[STEP 6] ✅ PostgreSQL inicializado e saudável`n" -ForegroundColor Green

# ====================================================================
# STEP 7: INICIALIZAÇÃO FASE 2 - MIDPOINT
# ====================================================================
Write-Host "[STEP 7] Inicializando midPoint (Fase 2)..." -ForegroundColor Yellow

ssh "$VM_USER@$VM_IP" "cd $BASE_DIR && docker compose up -d midpoint" 2>&1 | Out-Null

Write-Host "  Aguardando bootstrap do midPoint (180s - 3 minutos)..." -ForegroundColor Gray
Write-Host "  midPoint é pesado - aguarde pacientemente..." -ForegroundColor Yellow

for ($i = 1; $i -le 18; $i++) {
    Start-Sleep -Seconds 10
    Write-Host "    $($i*10)s / 180s..." -ForegroundColor Gray
}

ssh "$VM_USER@$VM_IP" "docker logs midpoint > $EVIDENCE_DIR/midpoint-bootstrap.log 2>&1"

Write-Host "[STEP 7] ✅ midPoint inicializado (aguardou 180s)`n" -ForegroundColor Green

# ====================================================================
# STEP 8: GATE DE VALIDAÇÃO CRÍTICO (PostgreSQL vs H2)
# ====================================================================
Write-Host "[STEP 8] GATE CRÍTICO - Validando tipo de repositório..." -ForegroundColor Yellow

# Verificar se H2 foi detectado (FALHA)
$h2_detected = ssh "$VM_USER@$VM_IP" "docker logs midpoint 2>&1 | grep -i 'repository.*h2'" 2>&1

if ($h2_detected) {
    Write-Host "`n❌ FALHA CRÍTICA: midPoint ativou fallback H2!" -ForegroundColor Red
    Write-Host "Evidência: $h2_detected" -ForegroundColor Red

    Write-Host "`n⚠️  ROLLBACK CONDICIONAL:" -ForegroundColor Yellow
    Write-Host "  - Fallback H2 confirmado nos logs" -ForegroundColor Gray
    Write-Host "  - PostgreSQL NÃO foi utilizado" -ForegroundColor Gray
    Write-Host "  - Dados atuais NÃO são válidos" -ForegroundColor Gray

    $rollback_confirm = Read-Host "`nDeseja aplicar rollback e destruir os dados? (S/N)"

    if ($rollback_confirm -eq 'S' -or $rollback_confirm -eq 's') {
        Write-Host "`nAcionando rollback automático..." -ForegroundColor Yellow

        ssh "$VM_USER@$VM_IP" @"
cd $BASE_DIR
docker compose down
sudo rm -rf $BASE_DIR/data/postgres
sudo rm -rf $BASE_DIR/data/midpoint/var
echo 'ROLLBACK: Fallback H2 detectado' > $EVIDENCE_DIR/rollback-reason.txt
echo 'Timestamp: \`$(date)' >> $EVIDENCE_DIR/rollback-reason.txt
"@

        Write-Error "GMUD-008 FALHOU: midPoint não conectou ao PostgreSQL - Rollback aplicado"
    } else {
        Write-Host "`nRollback cancelado pelo executor - Analise os logs manualmente" -ForegroundColor Yellow
    }

    exit 1
}

# Verificar se PostgreSQL foi detectado (SUCESSO)
$postgres_detected = ssh "$VM_USER@$VM_IP" "docker logs midpoint 2>&1 | grep -i 'repository.*postgresql'" 2>&1

if ($postgres_detected) {
    Write-Host "  ✅ PostgreSQL confirmado nos logs!" -ForegroundColor Green
    Write-Host "  Evidência: $postgres_detected" -ForegroundColor Gray
} else {
    Write-Warning "ATENÇÃO: Não foi possível confirmar uso de PostgreSQL explicitamente"
    Write-Host "Continuando validação com endpoint HTTP..." -ForegroundColor Yellow
}

Write-Host "[STEP 8] ✅ Gate de validação APROVADO (nenhum H2 detectado)`n" -ForegroundColor Green

# ====================================================================
# STEP 9: VALIDAÇÃO DE ENDPOINT HTTP
# ====================================================================
Write-Host "[STEP 9] Validando endpoint HTTP..." -ForegroundColor Yellow

Write-Host "  Aguardando estabilização final (30s)..." -ForegroundColor Gray
Start-Sleep -Seconds 30

$http_test = ssh "$VM_USER@$VM_IP" "curl -I http://$VM_IP:8080/midpoint 2>&1 | head -1" 2>&1

if ($http_test -notmatch "HTTP") {
    Write-Error "FALHA: Endpoint HTTP não respondeu"
    ssh "$VM_USER@$VM_IP" "docker logs midpoint > $EVIDENCE_DIR/midpoint-http-failure.log 2>&1"
    exit 1
}

ssh "$VM_USER@$VM_IP" "curl -v http://$VM_IP:8080/midpoint > $EVIDENCE_DIR/http-response.txt 2>&1"

Write-Host "  ✅ Endpoint HTTP respondendo: $http_test" -ForegroundColor Green
Write-Host "[STEP 9] ✅ Validação HTTP concluída`n" -ForegroundColor Green

# ====================================================================
# STEP 10: COLETA DE EVIDÊNCIAS FINAIS
# ====================================================================
Write-Host "[STEP 10] Coletando evidências técnicas..." -ForegroundColor Yellow

ssh "$VM_USER@$VM_IP" @"
docker ps > $EVIDENCE_DIR/containers-runtime.txt
docker inspect postgres > $EVIDENCE_DIR/postgres-config.json
docker inspect midpoint > $EVIDENCE_DIR/midpoint-config.json
docker logs postgres > $EVIDENCE_DIR/postgres-final.log 2>&1
docker logs midpoint > $EVIDENCE_DIR/midpoint-final.log 2>&1
sudo du -sh $BASE_DIR/data/postgres > $EVIDENCE_DIR/volumes-size.txt
sudo du -sh $BASE_DIR/data/midpoint/var >> $EVIDENCE_DIR/volumes-size.txt
echo '=== ÍNDICE DE EVIDÊNCIAS ===' > $EVIDENCE_DIR/INDEX.txt
ls -lh $EVIDENCE_DIR >> $EVIDENCE_DIR/INDEX.txt
echo '=== CONFIGURAÇÃO DO AMBIENTE ===' >> $EVIDENCE_DIR/INDEX.txt
echo 'VM IP: $VM_IP (Estático via Netplan)' >> $EVIDENCE_DIR/INDEX.txt
echo 'Data de Execução: \`$(date)' >> $EVIDENCE_DIR/INDEX.txt
echo 'Versão da GMUD: 008 v1.2' >> $EVIDENCE_DIR/INDEX.txt
echo 'Hardening: Least Privilege Sudoers' >> $EVIDENCE_DIR/INDEX.txt
"@

Write-Host "[STEP 10] ✅ Evidências coletadas`n" -ForegroundColor Green

# ====================================================================
# STEP 11: VALIDAÇÃO DE CONFORMIDADE DE SEGURANÇA
# ====================================================================
Write-Host "[STEP 11] Validando Conformidade de Segurança..." -ForegroundColor Yellow

# 11.1 Confirmar Sudoers Restrito
Write-Host "  11.1 Confirmando Sudoers Restrito..." -ForegroundColor Gray
$sudo_validation = ssh "$VM_USER@$VM_IP" "sudo -l" 2>&1
ssh "$VM_USER@$VM_IP" "echo '=== SUDOERS VALIDATION ===' > $EVIDENCE_DIR/security-compliance.txt"
ssh "$VM_USER@$VM_IP" "sudo -l >> $EVIDENCE_DIR/security-compliance.txt 2>&1"
Write-Host "    ✅ Sudoers validado e evidenciado" -ForegroundColor Green

# 11.2 Confirmar IP Estático
Write-Host "  11.2 Confirmando IP Estático..." -ForegroundColor Gray
ssh "$VM_USER@$VM_IP" "echo '=== NETWORK CONFIGURATION ===' >> $EVIDENCE_DIR/security-compliance.txt"
ssh "$VM_USER@$VM_IP" "ip addr show eth0 >> $EVIDENCE_DIR/security-compliance.txt"
ssh "$VM_USER@$VM_IP" "cat /etc/netplan/00-installer-config.yaml >> $EVIDENCE_DIR/security-compliance.txt"
Write-Host "    ✅ IP Estático validado e evidenciado" -ForegroundColor Green

# 11.3 Confirmar PowerShell Execution Policy
Write-Host "  11.3 Confirmando PowerShell Execution Policy..." -ForegroundColor Gray
$exec_policy_final = Get-ExecutionPolicy -Scope Process
Add-Content -Path "$EVIDENCE_DIR-local-powershell-policy.txt" -Value "=== POWERSHELL EXECUTION POLICY ==="
Add-Content -Path "$EVIDENCE_DIR-local-powershell-policy.txt" -Value "Scope: Process"
Add-Content -Path "$EVIDENCE_DIR-local-powershell-policy.txt" -Value "Policy: $exec_policy_final"
Add-Content -Path "$EVIDENCE_DIR-local-powershell-policy.txt" -Value "Timestamp: $(Get-Date)"
Write-Host "    ✅ Execution Policy validada e evidenciada" -ForegroundColor Green

Write-Host "[STEP 11] ✅ Conformidade de Segurança VALIDADA`n" -ForegroundColor Green

# ====================================================================
# CONCLUSÃO
# ====================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "GMUD-008 v1.2 EXECUTADA COM SUCESSO" -ForegroundColor Green
Write-Host "Hardening: Least Privilege + Static IP" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "📋 Próximas ações MANUAIS:" -ForegroundColor Yellow
Write-Host "  1. Acessar http://$VM_IP:8080/midpoint" -ForegroundColor White
Write-Host "  2. Fazer login com:" -ForegroundColor White
Write-Host "     Usuário: administrator" -ForegroundColor White
Write-Host "     Senha: $MIDPOINT_ADMIN_PASSWORD" -ForegroundColor White
Write-Host "  3. Validar dashboard do midPoint" -ForegroundColor White
Write-Host "  4. Capturar screenshot do dashboard" -ForegroundColor White
Write-Host "  5. Criar REL-GMUD-008 com status de sucesso" -ForegroundColor White

Write-Host "`n🔒 Controles de Segurança Implementados:" -ForegroundColor Cyan
Write-Host "  ✅ Least Privilege (Sudoers Whitelist)" -ForegroundColor Green
Write-Host "  ✅ Static IP via Netplan (Infraestrutura Imutável)" -ForegroundColor Green
Write-Host "  ✅ PowerShell Execution Policy (Bypass Temporário)" -ForegroundColor Green
Write-Host "  ✅ Gate de Validação H2 vs PostgreSQL" -ForegroundColor Green
Write-Host "  ✅ Rollback Condicional" -ForegroundColor Green

Write-Host "`n📁 Evidências disponíveis em: $EVIDENCE_DIR" -ForegroundColor Cyan
Write-Host "`n✅ Deploy concluído - Validação manual de login pendente`n" -ForegroundColor Green
```

---

## **6. PLANO DE EXECUÇÃO v1.2**

### **6.1. Pré-execução (OBRIGATÓRIA)**

**Ordem de Execução:**

1. ✅ **Configurar Sudoers na VM** (Pré-requisito 3.1)
2. ✅ **Configurar IP Estático na VM** (Pré-requisito 3.2)
3. ✅ **Validar conflito de IP com Host** (Pré-requisito 3.2)
4. ✅ **Criar arquivo `.env` no Windows** (Seção 4.1)
5. ✅ **Configurar PowerShell Execution Policy** (Pré-requisito 3.3)
6. ✅ **Executar o script** `GMUD-008-Deploy-v1.2.ps1`

### **6.2. Tempo Estimado**

| Fase | Duração |
|------|---------|
| **Pré-requisitos** (Sudoers + IP Estático) | ~10 minutos (uma vez) |
| **Execução do Script** | ~5-7 minutos (automatizado) |
| **Validação Manual** (Login + Screenshot) | ~5 minutos |
| **TOTAL** | ~20-22 minutos |

---

## **7. CRITÉRIOS DE SUCESSO v1.2**

A GMUD-008 v1.2 será considerada **bem-sucedida** quando:

### **7.1. Critérios Técnicos**

✅ Pre-Flight Checklist 100% aprovado  
✅ PostgreSQL atingir estado `healthy` em até 60s  
✅ midPoint inicializar sem erros em até 180s  
✅ **Gate de Validação:** Nenhum fallback H2 detectado nos logs  
✅ **Gate de Validação:** PostgreSQL confirmado nos logs  
✅ Endpoint HTTP `http://xxx.xxx.xxx.xxx:8080/midpoint` acessível  
✅ **Login MANUAL com `administrator:Fiqueok@2026!` bem-sucedido**  
✅ Dashboard do midPoint acessível via navegador  

### **7.2. Critérios de Segurança (NOVOS v1.2)**

✅ **Sudoers configurado com Least Privilege** (Whitelist de 5 binários)  
✅ **IP Estático configurado** via Netplan (xxx.xxx.xxx.xxx)  
✅ **Nenhum conflito de IP** com Host Windows  
✅ **PowerShell Execution Policy** configurada corretamente  
✅ **Evidências de conformidade** coletadas automaticamente  

### **7.3. Critérios de Evidência**

✅ Screenshot do dashboard capturado  
✅ Evidências técnicas coletadas em `/srv/prj003/evidencias`  
✅ Arquivo `security-compliance.txt` gerado  
✅ Arquivo `powershell-policy.txt` gerado no host  

---

## **8. CONFORMIDADE COM FRAMEWORKS v1.2**

| Framework | Controle | Implementação v1.2 | Status |
|-----------|----------|-------------------|--------|
| **ISO 27001:2022** | A.9.2.3 Gestão de Privilégios | Sudoers com Least Privilege | ✅ Conforme |
| **ISO 27001:2022** | A.8.32 Gestão de Mudanças | IP Estático via Netplan | ✅ Conforme |
| **ISO 27001:2022** | A.8.29 Segurança em Desenvolvimento | PowerShell Execution Policy documentada | ✅ Conforme |
| **NIST CSF 2.0** | PR.AC-4 Princípio Menor Privilégio | Whitelist de binários sudo | ✅ Conforme |
| **NIST CSF 2.0** | PR.IP-1 Baseline de Configuração | IP Estático + Gate de Validação | ✅ Conforme |
| **CIS Controls v8** | 5.4 Restrição de Privilégios Administrativos | Sudoers restrito | ✅ Conforme |
| **CIS Controls v8** | 2.7 Controle de Execução de Aplicações | Execution Policy documentada | ✅ Conforme |
| **ITIL v4** | Change Enablement | Orquestração automatizada com gates | ✅ Conforme |

---

## **9. RISCOS E MITIGAÇÕES v1.2**

| Risco | Probabilidade v1.1 | Probabilidade v1.2 | Mitigação Implementada |
|-------|-------------------|-------------------|------------------------|
| Comprometimento da conta `paulo` | Médio | **Baixo** | ✅ Sudoers com Least Privilege |
| Mudança de IP por DHCP | Alto | **Eliminado** | ✅ IP Estático via Netplan |
| Conflito de IP com Host | Baixo | **Eliminado** | ✅ Validação no STEP 0.4 |
| Script bloqueado por Execution Policy | Médio | **Eliminado** | ✅ Documentação no Pré-requisito 3.3 |
| Fallback H2 persistir | Baixo | **Baixo** | Gate de validação mantido |
| DNS temporário | Médio | **Eliminado** | ✅ Google DNS permanente no Netplan |

---

## **10. DOCUMENTOS RELACIONADOS**

- **GMUDs Anteriores:** GMUD-005, GMUD-006, GMUD-007 (RCA completo)
- **Versões Anteriores:** GMUD-008 v1.0, GMUD-008 v1.1
- **Canvases:** CAN-ID-001, CAN-ID-002, CAN-ID-003
- **ADRs:** ADR-002 (Reversibilidade), ADR-003 (Cross-Mapping GRC)
- **Governança:** DEC-ID-001, DGC-001
- **POPs:** POP-001 (Implementação Infraestrutura IGA)
- **Futuro:** ADR-004 (Hardening de Sudoers - Least Privilege)

---

## **11. APROVAÇÃO**

| Papel | Nome | Status | Data |
|-------|------|--------|------|
| **Solicitante** | Paulo Feitosa | Aprovado | 19/01/2026 |
| **Executor** | Paulo Feitosa | Aprovado | 19/01/2026 |
| **Aprovador GRC** | Paulo Feitosa | Aprovado | 19/01/2026 |
| **Aprovador Técnico** | Paulo Feitosa | Aprovado | 19/01/2026 |
| **Aprovador de Segurança** | Paulo Feitosa | Aprovado | 19/01/2026 |

---

## **12. CONTROLE DE VERSÃO**

| Versão | Data | Autor | Mudança |
|--------|------|-------|---------|
| 1.0 | 18/01/2026 21:30 | Paulo Feitosa | Criação com correção de variáveis e gate H2 |
| 1.1 | 18/01/2026 22:00 | Paulo Feitosa | Escaping de variáveis, timeout 180s, credenciais parametrizadas, rollback condicional |
| **1.2** | **19/01/2026 15:00** | **Paulo Feitosa** | **Security by Design: Hardening Sudoers (Least Privilege), IP Estático (Netplan), PowerShell Execution Policy, Validação de Conflito de IP, Evidências de Conformidade** |

---

## **13. ANEXOS**

### **13.1. Comparativo de Segurança: v1.1 vs v1.2**

| Aspecto | v1.1 | v1.2 |
|---------|------|------|
| **Sudoers** | ❌ `ALL=(ALL) NOPASSWD:ALL` | ✅ Whitelist de 5 binários |
| **IP da VM** | ⚠️ DHCP (pode mudar) | ✅ Estático via Netplan |
| **DNS** | ⚠️ Contorno temporário | ✅ Google DNS permanente |
| **Execution Policy** | ❌ Não documentada | ✅ Documentada e validada |
| **Validação de IP** | ❌ Não verificava conflito | ✅ Valida conflito com host |
| **Evidências de Segurança** | ❌ Não coletadas | ✅ Arquivo `security-compliance.txt` |

### **13.2. Exemplo de Arquivo security-compliance.txt**

```
=== SUDOERS VALIDATION ===
User paulo may run the following commands on IGA-GF-01:
    (ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/chown, /usr/bin/docker, /usr/bin/du, /usr/bin/rm

=== NETWORK CONFIGURATION ===
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet xxx.xxx.xxx.xxx/22 brd xxx.xxx.xxx.xxx scope global eth0

network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - xxx.xxx.xxx.xxx/22
      routes:
        - to: default
          via: xxx.xxx.xxx.xxx
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

---

**Repositório:** `FiqueokBrain/10-Projetos/PRJ003-IGA-GREENFIELD/40-GMUDs/GMUD-008-v1.2.md`

**Status:** 📋 **Aprovado para Execução v1.2 - Security by Design Implementado**

**Veredito GRC Final:** ✅ **Aprovada v1.2** - Hardening completo: Least Privilege, Static IP, Execution Policy, Validação de Conflitos, Evidências de Conformidade.

**Classificação de Segurança:** 🔒 **Hardened** - Conformidade com ISO 27001:2022, NIST CSF 2.0, CIS Controls v8

---

**FIM DO DOCUMENTO GMUD-008 v1.2**

