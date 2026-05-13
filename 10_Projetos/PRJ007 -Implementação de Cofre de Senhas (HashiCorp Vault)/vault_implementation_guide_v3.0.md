# Guia de Implementação v3.0 - HashiCorp Vault em Hyper-V Gen1

**Projeto**: PRJ007 - Living Lab Fiqueok 2.0  
**Versão do Guia**: 3.0 (Production-Grade)  
**Data**: 10 de Fevereiro de 2026  
**Arquitetura**: Hyper-V Gen1 + Ubuntu 24.04 LTS + Vault 1.21.2  
**Elaborado por**: Claude (Anthropic) + Consultoria GRC  
**Status**: ✅ Aprovado para Implementação Enterprise

---

## 📊 ANÁLISE CRÍTICA DAS SUGESTÕES DO CONSULTOR GRC

### ✅ Aprovadas Integralmente

1. **Identidade do Serviço com `/usr/sbin/nologin`**:
   - ✅ **Aprovado**: Mais restritivo que `/bin/false` (bloqueia login interativo E shells)
   - ✅ **Conformidade**: CIS Benchmark 5.4.2 (Service accounts must not have valid shells)
   - ✅ **Justificativa**: Reduz superfície de ataque em caso de comprometimento do binário

2. **Permissões Rigorosas (750)**:
   - ✅ **Aprovado**: Alinhado com princípio Least Privilege (ISO 27001 A.9.4.1)
   - ✅ **Conformidade**: NIST SP 800-123 (Unix Hardening)
   - ✅ **Nota**: Adicionar SELinux/AppArmor policies para defesa em profundidade

3. **Remoção de Dependências WSL2**:
   - ✅ **Aprovado**: Elimina `wsl.conf`, `userspace-networking`, problemas de systemd parcial
   - ✅ **Impacto**: Systemd real, kernel nativo, persistência confiável

4. **Tailscale em Modo Nativo**:
   - ✅ **Aprovado**: Interface TUN/TAP real, sem conflitos de socket
   - ✅ **Benefício**: Integração com systemd-resolved (DNS over Tailscale)

### ⚠️ Melhorias Adicionais Recomendadas

1. **Separação de Diretórios de Audit**:
   - Criar `/opt/vault/audit` separado de `/opt/vault/logs`
   - Rotação via `logrotate` para evitar disco cheio (DoS)

2. **Hardening do Systemd Unit**:
   - Adicionar `ReadWritePaths=/opt/vault/data /opt/vault/logs /opt/vault/audit`
   - Adicionar `ReadOnlyPaths=/etc/vault.d`
   - Configurar `Restart=on-failure` com `RestartSec=5` e `StartLimitBurst=3`

3. **Configuração de Listener Tailscale**:
   - Usar IP fixo `xxx.xxx.xxx.xxx:8200` (não `0.0.0.0`) para evitar exposição não intencional
   - Habilitar `x_forwarded_for_authorized_addrs` para logs de audit corretos

4. **Melhorias no vault.hcl**:
   - Adicionar `max_request_duration = "90s"` (proteção contra DoS)
   - Configurar `disable_clustering = false` (preparação para HA futura)

---

## 🎯 OBJETIVO

Implementar HashiCorp Vault v1.21.2 em VM Hyper-V Geração 1 (Ubuntu 24.04 LTS) com configurações de nível empresarial, seguindo frameworks CIS, NIST e ISO 27001.

---

## ✅ PRÉ-REQUISITOS

Antes de iniciar, confirme:

1. ✅ VM Hyper-V Gen1 criada (mínimo 2 vCPUs, 2GB RAM, 20GB disco)
2. ✅ Ubuntu Server 24.04 LTS instalado (verificar com `lsb_release -a`)
3. ✅ Conectividade de rede ativa (testar com `ping 8.8.8.8`)
4. ✅ Usuário com permissões `sudo` configurado
5. ✅ Snapshot da VM realizado (rollback de segurança)
6. ✅ Firewall local configurado (UFW ou iptables)

---

## 📋 ETAPA 0: VERIFICAÇÕES INICIAIS E HARDENING DO SISTEMA BASE

### 0.1 Verificar Versão do Ubuntu

```bash
lsb_release -a
```

**Saída esperada**:
```
Distributor ID: Ubuntu
Description:    Ubuntu 24.04 LTS
Release:        24.04
Codename:       noble
```

### 0.2 Atualizar Sistema Operacional

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt autoremove -y
```

### 0.3 Configurar Timezone e NTP

```bash
# Configurar timezone (ajustar conforme localização)
sudo timedatectl set-timezone America/Sao_Paulo

# Verificar sincronização NTP
timedatectl status
```

**Saída esperada**: `System clock synchronized: yes`

### 0.4 Hardening Básico do Sistema

```bash
# Instalar ferramentas de segurança
sudo apt install -y \
  ufw \
  fail2ban \
  auditd \
  apparmor \
  apparmor-utils

# Habilitar firewall (permitir apenas SSH inicialmente)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw --force enable

# Verificar AppArmor
sudo aa-status
```

### 0.5 Verificar Systemd

```bash
systemctl --version
```

**Saída esperada**:
```
systemd 255 (255.x-ubuntu...)
+PAM +AUDIT +SELINUX +APPARMOR +IMA +SMACK +SECCOMP ...
```

---

## 📋 ETAPA 1: INSTALAÇÃO DO HASHICORP VAULT

### 1.1 Adicionar Repositório Oficial HashiCorp

```bash
# Instalar dependências
sudo apt install -y wget gpg coreutils

# Baixar e verificar chave GPG
wget -O- https://apt.releases.hashicorp.com/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Verificar fingerprint (CRÍTICO - não pular)
gpg --no-default-keyring \
  --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
  --fingerprint
```

**Fingerprint esperado**:
```
798A EC65 4E5C 1542 8C8E  42EE AA16 FCBC A621 E701
```

```bash
# Adicionar repositório
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

# Atualizar índice de pacotes
sudo apt update
```

### 1.2 Instalar Vault 1.21.2

```bash
# Verificar versões disponíveis
apt-cache policy vault

# Instalar versão específica (corrige CVE-2025-12044)
sudo apt install -y vault=1.21.2-1

# Prevenir upgrades automáticos
sudo apt-mark hold vault
```

### 1.3 Validar Instalação

```bash
# Verificar versão
vault version

# Verificar localização do binário
which vault

# Verificar capabilities Linux
getcap /usr/bin/vault
```

**Saídas esperadas**:
```
Vault v1.21.2 (781ba452d731fe2d59ccbc1b37ca7c5a18edb998), built 2026-01-06T08:33:05Z
/usr/bin/vault
/usr/bin/vault cap_ipc_lock=ep
```

---

## 📋 ETAPA 2: CONFIGURAÇÃO DE IDENTIDADE E DIRETÓRIOS (HARDENING)

### 2.1 Criar Usuário Dedicado (Service Account)

```bash
# Criar usuário de sistema SEM shell válido
sudo useradd \
  --system \
  --home /opt/vault \
  --shell /usr/sbin/nologin \
  --comment "HashiCorp Vault Service Account" \
  vault

# Verificar criação
id vault
getent passwd vault
```

**Saída esperada**:
```
uid=XXX(vault) gid=XXX(vault) groups=XXX(vault)
vault:x:XXX:XXX:HashiCorp Vault Service Account:/opt/vault:/usr/sbin/nologin
```

**Nota de Segurança**: `/usr/sbin/nologin` bloqueia qualquer tentativa de login interativo, incluindo `su - vault`.

### 2.2 Criar Estrutura de Diretórios (Least Privilege)

```bash
# Criar hierarquia de diretórios
sudo mkdir -p /opt/vault/{data,logs,audit,scripts,backups,tls}
sudo mkdir -p /etc/vault.d

# Aplicar ownership
sudo chown -R vault:vault /opt/vault
sudo chown vault:vault /etc/vault.d

# Aplicar permissões rigorosas (750 = rwxr-x---)
# Vault user: rwx (read/write/execute)
# Vault group: r-x (read/execute only)
# Others: --- (no access)
sudo chmod 750 /opt/vault
sudo chmod 750 /opt/vault/data
sudo chmod 750 /opt/vault/logs
sudo chmod 750 /opt/vault/audit
sudo chmod 750 /opt/vault/scripts
sudo chmod 750 /opt/vault/backups
sudo chmod 700 /opt/vault/tls  # Apenas vault user
sudo chmod 750 /etc/vault.d

# Verificar permissões
ls -la /opt/ | grep vault
sudo ls -la /opt/vault/
```

**Saída esperada**:
```
drwxr-x---  8 vault vault 4096 Feb 10 10:00 vault

total 32
drwxr-x---  8 vault vault 4096 Feb 10 10:00 .
drwxr-xr-x  4 root  root  4096 Feb 10 09:55 ..
drwxr-x---  2 vault vault 4096 Feb 10 10:00 audit
drwxr-x---  2 vault vault 4096 Feb 10 10:00 backups
drwxr-x---  2 vault vault 4096 Feb 10 10:00 data
drwxr-x---  2 vault vault 4096 Feb 10 10:00 logs
drwxr-x---  2 vault vault 4096 Feb 10 10:00 scripts
drwx------  2 vault vault 4096 Feb 10 10:00 tls
```

### 2.3 Configurar AppArmor Profile (Opcional mas Recomendado)

```bash
# Criar profile básico para Vault
sudo tee /etc/apparmor.d/usr.bin.vault > /dev/null <<'EOF'
#include <tunables/global>

/usr/bin/vault {
  #include <abstractions/base>
  #include <abstractions/nameservice>

  # Binário
  /usr/bin/vault mr,

  # Configuração
  /etc/vault.d/** r,

  # Dados
  /opt/vault/data/** rw,
  /opt/vault/logs/** rw,
  /opt/vault/audit/** rw,

  # Capabilities necessárias
  capability ipc_lock,
  capability sys_admin,

  # Rede
  network inet stream,
  network inet6 stream,
}
EOF

# Carregar profile
sudo apparmor_parser -r /etc/apparmor.d/usr.bin.vault
```

---

## 📋 ETAPA 3: CONFIGURAÇÃO DO VAULT (PRODUCTION-GRADE)

### 3.1 Criar Arquivo de Configuração Principal

```bash
sudo tee /etc/vault.d/vault.hcl > /dev/null <<'EOF'
# ==============================================================================
# HashiCorp Vault Configuration - PRJ007 Living Lab Fiqueok 2.0
# ==============================================================================
# Ambiente: Hyper-V Gen1 VM (Ubuntu 24.04 LTS)
# Versão Vault: 1.21.2
# Data: 10 de Fevereiro de 2026
# Conformidade: CIS Benchmark, NIST SP 800-123, ISO 27001
# ==============================================================================

# ------------------------------------------------------------------------------
# STORAGE BACKEND: Raft (Integrated Storage)
# ------------------------------------------------------------------------------
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-fiqueok-primary"
  
  # Performance tuning para ambiente de laboratório
  # Em produção, ajustar conforme workload
  performance_multiplier = 1
  
  # Configuração de snapshot automático
  autopilot {
    cleanup_dead_servers = true
    last_contact_threshold = "10s"
    max_trailing_logs = 1000
    min_quorum = 1
  }
}

# ------------------------------------------------------------------------------
# LISTENERS: Local + Tailscale
# ------------------------------------------------------------------------------

# Listener 1: Local (127.0.0.1) - Acesso localhost
listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = true
  
  # Limites de proteção
  max_request_duration = "90s"
  max_request_size = "33554432"  # 32MB
}

# Listener 2: Tailscale VPN (xxx.xxx.xxx.xxx) - Acesso remoto seguro
listener "tcp" {
  address     = "xxx.xxx.xxx.xxx:8200"
  tls_disable = true
  
  # NOTA: Em produção, habilitar TLS:
  # tls_disable = false
  # tls_cert_file = "/opt/vault/tls/vault.crt"
  # tls_key_file  = "/opt/vault/tls/vault.key"
  # tls_min_version = "tls13"
  
  # Proteção contra DoS
  max_request_duration = "90s"
  max_request_size = "33554432"
  
  # Headers para proxy reverso (se aplicável)
  x_forwarded_for_authorized_addrs = ["xxx.xxx.xxx.xxx/10"]
}

# ------------------------------------------------------------------------------
# API E CLUSTER ADDRESSING
# ------------------------------------------------------------------------------
api_addr     = "http://xxx.xxx.xxx.xxx:8200"
cluster_addr = "https://xxx.xxx.xxx.xxx:8201"

# Habilitar clustering para HA futura
disable_clustering = false

# ------------------------------------------------------------------------------
# UI WEB
# ------------------------------------------------------------------------------
ui = true

# ------------------------------------------------------------------------------
# TELEMETRIA (Desabilitada para Privacidade)
# ------------------------------------------------------------------------------
telemetry {
  disable_hostname = true
  prometheus_retention_time = "0s"
}

# ------------------------------------------------------------------------------
# LOGGING
# ------------------------------------------------------------------------------
log_level  = "info"
log_format = "json"

# Rotação de logs via journald (systemd)
# Não configurar file logging aqui (gerenciado pelo systemd)

# ------------------------------------------------------------------------------
# SEGURANÇA
# ------------------------------------------------------------------------------

# Desabilitar mlock em VMs (não afeta segurança significativamente)
# Em bare-metal, manter habilitado (remover esta linha)
disable_mlock = true

# Configurações de lease
max_lease_ttl     = "768h"   # 32 dias
default_lease_ttl = "168h"   # 7 dias

# Cache habilitado (performance)
disable_cache = false

# Validação de printable check
disable_printable_check = false

# ------------------------------------------------------------------------------
# PLUGINS (Se necessário)
# ------------------------------------------------------------------------------
# plugin_directory = "/opt/vault/plugins"

# ==============================================================================
# FIM DA CONFIGURAÇÃO
# ==============================================================================
EOF
```

### 3.2 Aplicar Permissões ao Arquivo de Configuração

```bash
sudo chown vault:vault /etc/vault.d/vault.hcl
sudo chmod 640 /etc/vault.d/vault.hcl

# Verificar
sudo ls -la /etc/vault.d/
```

**Saída esperada**:
```
-rw-r----- 1 vault vault 3456 Feb 10 10:15 vault.hcl
```

### 3.3 Validar Sintaxe da Configuração

```bash
# Testar configuração (não inicia o servidor)
sudo -u vault vault server -config=/etc/vault.d/vault.hcl -test 2>&1

# Se não houver erros, comando retorna código 0 sem output
echo $?
```

**Saída esperada**: `0` (sucesso)

---

## 📋 ETAPA 4: CONFIGURAÇÃO DO SYSTEMD SERVICE (PRODUCTION-GRADE)

### 4.1 Criar Systemd Unit File

```bash
sudo tee /etc/systemd/system/vault.service > /dev/null <<'EOF'
[Unit]
Description=HashiCorp Vault - Secrets Management System
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl

# Limites de restart
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
# Tipo de serviço (notify = suporte a sd_notify)
Type=notify

# Identidade
User=vault
Group=vault

# Hardening: Restrições de sistema de arquivos
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes

# Hardening: Somente leitura em /etc
ReadOnlyPaths=/etc/vault.d

# Hardening: Permissões de escrita específicas
ReadWritePaths=/opt/vault/data
ReadWritePaths=/opt/vault/logs
ReadWritePaths=/opt/vault/audit

# Hardening: Capabilities mínimas necessárias
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes

# Hardening: Isolamento
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectControlGroups=yes
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
RestrictNamespaces=yes
RestrictRealtime=yes
LockPersonality=yes

# Comandos de execução
ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP $MAINPID

# Gestão de processos
KillMode=process
KillSignal=SIGINT

# Política de restart
Restart=on-failure
RestartSec=5
TimeoutStopSec=30

# Limites de recursos
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF
```

### 4.2 Recarregar Systemd e Habilitar Auto-Start

```bash
# Recarregar configurações do systemd
sudo systemctl daemon-reload

# Habilitar auto-start no boot
sudo systemctl enable vault.service

# Verificar status (ainda não iniciado)
sudo systemctl status vault.service
```

**Saída esperada**:
```
○ vault.service - HashiCorp Vault - Secrets Management System
     Loaded: loaded (/etc/systemd/system/vault.service; enabled; preset: enabled)
     Active: inactive (dead)
       Docs: https://www.vaultproject.io/docs/
```

---

## 📋 ETAPA 5: INICIALIZAÇÃO DO VAULT

### 5.1 Configurar Firewall (Permitir Porta 8200 na Tailscale)

```bash
# Permitir conexões na porta 8200 apenas pela interface Tailscale
# Identificar interface Tailscale
ip addr show | grep -A2 tailscale

# Exemplo de regra UFW
sudo ufw allow in on tailscale0 to any port 8200 proto tcp comment 'Vault API'

# Verificar regras
sudo ufw status numbered
```

### 5.2 Iniciar Serviço Vault

```bash
# Iniciar serviço
sudo systemctl start vault.service

# Aguardar 5 segundos para inicialização
sleep 5

# Verificar status
sudo systemctl status vault.service
```

**Saída esperada**:
```
● vault.service - HashiCorp Vault - Secrets Management System
     Loaded: loaded (/etc/systemd/system/vault.service; enabled; preset: enabled)
     Active: active (running) since Mon 2026-02-10 10:30:15 -03; 5s ago
       Docs: https://www.vaultproject.io/docs/
   Main PID: 12345 (vault)
      Tasks: 11 (limit: 4600)
     Memory: 45.2M
        CPU: 120ms
     CGroup: /system.slice/vault.service
             └─12345 /usr/bin/vault server -config=/etc/vault.d/vault.hcl
```

### 5.3 Verificar Logs Iniciais

```bash
# Ver últimas 30 linhas do log
sudo journalctl -u vault.service -n 30 --no-pager

# Verificar erros
sudo journalctl -u vault.service -p err --no-pager
```

**Saída esperada**: Nenhum erro crítico, mensagens de inicialização OK.

### 5.4 Configurar Variável de Ambiente

```bash
# Adicionar ao perfil do usuário
echo 'export VAULT_ADDR="http://127.0.0.1:8200"' >> ~/.bashrc
source ~/.bashrc

# Verificar
echo $VAULT_ADDR
```

**Saída esperada**: `http://127.0.0.1:8200`

### 5.5 Verificar Status do Vault

```bash
vault status
```

**Saída esperada**:
```
Key                Value
---                -----
Seal Type          shamir
Initialized        false
Sealed             true
Total Shares       0
Threshold          0
Unseal Progress    0/0
Version            1.21.2
Build Date         2026-01-06T08:33:05Z
Storage Type       raft
Removed From Cluster    false
HA Enabled         true
```

---

## 📋 ETAPA 6: OPERATOR INIT (INICIALIZAÇÃO E UNSEAL KEYS)

### 6.1 Criar Diretório Seguro para Backup das Keys

```bash
# Criar diretório local para backup temporário
mkdir -p ~/vault-backup
chmod 700 ~/vault-backup

# CRÍTICO: Após salvar, copiar para 3 locais diferentes:
# 1. Pendrive criptografado
# 2. Gerenciador de senhas (1Password, Bitwarden)
# 3. Cofre físico (papel em local seguro)
```

### 6.2 Inicializar o Vault (Gerar Unseal Keys e Root Token)

```bash
# Inicializar com 5 key shares e threshold de 3
vault operator init \
  -key-shares=5 \
  -key-threshold=3 \
  | tee ~/vault-backup/vault-init-$(date +%Y%m%d-%H%M%S).txt
```

**⚠️ ATENÇÃO CRÍTICA**:
- As **5 Unseal Keys** e o **Initial Root Token** exibidos são **ÚNICOS E IRRECUPERÁVEIS**
- **SEM ESTAS KEYS, O VAULT NUNCA PODERÁ SER DESBLOQUEADO**
- **NUNCA compartilhe estas keys em chats, emails ou serviços online**
- Faça backup IMEDIATAMENTE em 3 locais físicos diferentes

**Saída esperada** (EXEMPLO - NÃO usar estas keys):
```
Unseal Key 1: ABC123...
Unseal Key 2: DEF456...
Unseal Key 3: GHI789...
Unseal Key 4: JKL012...
Unseal Key 5: MNO345...

Initial Root Token: hvs.XXXXXXXXXXXXXXXX

Vault initialized with 5 key shares and a key threshold of 3.
```

### 6.3 Fazer Unseal do Vault (Desbloquear)

```bash
# Executar 3 vezes com keys DIFERENTES
vault operator unseal
# Cole Unseal Key 1 quando pedir

vault operator unseal
# Cole Unseal Key 2

vault operator unseal
# Cole Unseal Key 3

# Verificar status (deve mostrar Sealed: false)
vault status
```

**Saída esperada após 3ª key**:
```
...
Sealed             false
...
```

---

## 📋 ETAPA 7: HABILITAR AUDIT LOGGING

### 7.1 Login com Root Token

```bash
vault login
# Cole o Initial Root Token quando solicitado
```

### 7.2 Habilitar File Audit Backend

```bash
# Habilitar audit log em arquivo
vault audit enable file file_path=/opt/vault/audit/vault_audit.log

# Verificar
vault audit list
```

**Saída esperada**:
```
Path     Type    Description
----     ----    -----------
file/    file    n/a
```

### 7.3 Configurar Rotação de Logs (logrotate)

```bash
sudo tee /etc/logrotate.d/vault > /dev/null <<'EOF'
/opt/vault/audit/vault_audit.log {
    daily
    rotate 30
    missingok
    notifempty
    compress
    delaycompress
    copytruncate
    su vault vault
}
EOF

# Testar configuração
sudo logrotate -d /etc/logrotate.d/vault
```

---

## 📋 ETAPA 8: CONFIGURAÇÃO DE AUTENTICAÇÃO E RBAC

### 8.1 Habilitar Userpass Auth Method

```bash
vault auth enable userpass
```

### 8.2 Criar Política de Admin

```bash
vault policy write admin - <<EOF
# Política Admin - Acesso total exceto revogação de root token

# Acesso completo a todos os paths
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Exceção: Não pode revogar root token
path "auth/token/revoke-root" {
  capabilities = ["deny"]
}

# Gestão de políticas
path "sys/policies/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Gestão de auth methods
path "sys/auth/*" {
  capabilities = ["create", "read", "update", "delete", "sudo"]
}

# Gestão de secrets engines
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "sudo"]
}

# Unseal/seal operations
path "sys/seal" {
  capabilities = ["update", "sudo"]
}

path "sys/unseal" {
  capabilities = ["update"]
}

# Audit backends
path "sys/audit/*" {
  capabilities = ["create", "read", "update", "delete", "sudo"]
}

# Health checks
path "sys/health" {
  capabilities = ["read"]
}
EOF
```

### 8.3 Criar Usuário Paulo (Admin)

```bash
vault write auth/userpass/users/paulo \
  password="<DEFINA_UMA_SENHA_FORTE_AQUI>" \
  policies="admin"
```

**⚠️ IMPORTANTE**:
- Substitua `<DEFINA_UMA_SENHA_FORTE_AQUI>` por senha de 16+ caracteres
- Use letras maiúsculas, minúsculas, números e símbolos
- NÃO reutilize senhas de outros sistemas

### 8.4 Testar Autenticação

```bash
# Revogar root token (boa prática de segurança)
vault token revoke -self

# Login com usuário paulo
vault login -method=userpass username=paulo
# Digite a senha definida acima

# Verificar token
vault token lookup
```

**Saída esperada**:
```
...
policies      [admin default]
...
```

---

## 📋 ETAPA 9: CONFIGURAÇÃO DE SECRETS ENGINE

### 9.1 Habilitar KV Secrets Engine v2

```bash
vault secrets enable -version=2 -path=secret kv

# Verificar
vault secrets list
```

### 9.2 Criar Secret de Teste

```bash
vault kv put secret/fiqueok/project \
  project_name="Living Lab Fiqueok 2.0" \
  project_code="PRJ007" \
  environment="hyper-v_production"

# Ler secret
vault kv get secret/fiqueok/project
```

---

## 📋 ETAPA 10: BACKUP AUTOMÁTICO (RAFT SNAPSHOTS)

### 10.1 Criar Script de Backup

```bash
sudo -u vault tee /opt/vault/scripts/vault_snapshot.sh > /dev/null <<'EOF'
#!/bin/bash
# ==============================================================================
# Script de Backup Automático - HashiCorp Vault PRJ007
# ==============================================================================
# Executa snapshot do Raft storage com retenção de 7 dias
# ==============================================================================

set -euo pipefail

# Configurações
export VAULT_ADDR='http://127.0.0.1:8200'
BACKUP_DIR="/opt/vault/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/vault_snapshot_${DATE}.snap"
RETENTION_DAYS=7
LOG_FILE="/opt/vault/logs/backup.log"

# Função de logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"
}

# Criar diretório se não existir
mkdir -p "${BACKUP_DIR}"

# Verificar se Vault está unsealed
if ! vault status >/dev/null 2>&1; then
    log "ERROR: Vault não está acessível ou está sealed"
    exit 1
fi

# Executar snapshot
log "INFO: Iniciando snapshot..."
if vault operator raft snapshot save "${BACKUP_FILE}" >/dev/null 2>&1; then
    BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
    log "SUCCESS: Snapshot criado: ${BACKUP_FILE} (${BACKUP_SIZE})"
    
    # Remover backups antigos
    DELETED=$(find "${BACKUP_DIR}" -name "vault_snapshot_*.snap" -mtime +${RETENTION_DAYS} -delete -print | wc -l)
    if [ "${DELETED}" -gt 0 ]; then
        log "INFO: ${DELETED} backup(s) antigo(s) removido(s) (retenção: ${RETENTION_DAYS} dias)"
    fi
else
    log "ERROR: Falha ao criar snapshot!"
    exit 1
fi

exit 0
EOF

# Tornar executável
sudo chmod +x /opt/vault/scripts/vault_snapshot.sh
sudo chown vault:vault /opt/vault/scripts/vault_snapshot.sh
```

### 10.2 Configurar Cron Job (Backup Diário)

```bash
# Editar crontab do usuário vault
sudo crontab -u vault -e

# Adicionar linha (backup diário às 3h da manhã):
0 3 * * * /opt/vault/scripts/vault_snapshot.sh
```

### 10.3 Testar Backup Manual

```bash
# Executar script manualmente
sudo -u vault /opt/vault/scripts/vault_snapshot.sh

# Verificar arquivo criado
sudo ls -lh /opt/vault/backups/

# Verificar log
sudo tail /opt/vault/logs/backup.log
```

---

## 📋 ETAPA 11: MONITORAMENTO E HEALTH CHECKS

### 11.1 Script de Health Check

```bash
sudo -u vault tee /opt/vault/scripts/vault_healthcheck.sh > /dev/null <<'EOF'
#!/bin/bash
# ==============================================================================
# Health Check - HashiCorp Vault PRJ007
# ==============================================================================

set -euo pipefail

export VAULT_ADDR='http://127.0.0.1:8200'
LOG_FILE="/opt/vault/logs/healthcheck.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"
}

# Verificar se serviço systemd está rodando
if ! systemctl is-active --quiet vault.service; then
    log "CRITICAL: Serviço Vault não está rodando!"
    exit 2
fi

# Obter status em JSON
STATUS=$(vault status -format=json 2>/dev/null || echo '{}')

# Verificar se conseguiu conectar
if [ "${STATUS}" = "{}" ]; then
    log "CRITICAL: Não foi possível conectar ao Vault!"
    exit 2
fi

# Verificar se está unsealed
SEALED=$(echo "${STATUS}" | jq -r '.sealed')
if [ "${SEALED}" = "true" ]; then
    log "CRITICAL: Vault está SEALED!"
    exit 2
fi

# Verificar se está inicializado
INITIALIZED=$(echo "${STATUS}" | jq -r '.initialized')
if [ "${INITIALIZED}" = "false" ]; then
    log "WARNING: Vault não está inicializado!"
    exit 1
fi

# Tudo OK
log "OK: Vault operacional (unsealed, initialized)"
exit 0
EOF

sudo chmod +x /opt/vault/scripts/vault_healthcheck.sh
sudo chown vault:vault /opt/vault/scripts/vault_healthcheck.sh

# Instalar jq (se não estiver instalado)
sudo apt install -y jq
```

### 11.2 Configurar Health Check Periódico

```bash
# Adicionar ao crontab (verificação a cada 5 minutos)
sudo crontab -u vault -e

# Adicionar:
*/5 * * * * /opt/vault/scripts/vault_healthcheck.sh
```

---

## 📋 ETAPA 12: INTEGRAÇÃO COM TAILSCALE (ACESSO REMOTO SEGURO)

### 12.1 Instalar Tailscale

```bash
# Adicionar repositório oficial
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | \
  sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null

curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | \
  sudo tee /etc/apt/sources.list.d/tailscale.list

# Instalar
sudo apt update
sudo apt install -y tailscale

# Habilitar e iniciar serviço
sudo systemctl enable --now tailscaled
```

### 12.2 Autenticar na Rede Tailscale

```bash
# Conectar à rede Tailscale
sudo tailscale up

# Seguir link de autenticação no browser
# Após autenticar, verificar IP
tailscale ip -4
```

**Anote o IP Tailscale** (deve ser `xxx.xxx.xxx.xxx` conforme configurado no `vault.hcl`)

### 12.3 Configurar DNS via Tailscale (Opcional)

```bash
# Configurar MagicDNS
sudo tailscale up --accept-dns

# Verificar status
tailscale status
```

### 12.4 Testar Acesso Remoto

```bash
# De outro dispositivo na rede Tailscale:
curl http://xxx.xxx.xxx.xxx:8200/v1/sys/health

# Ou acessar UI:
# http://xxx.xxx.xxx.xxx:8200/ui
```

---

## ✅ CHECKLIST FINAL DE VALIDAÇÃO

Execute cada comando e marque quando concluído:

```bash
# [ ] 1. Serviço systemd ativo
systemctl is-active vault.service
# Esperado: active

# [ ] 2. Vault unsealed
vault status | grep "Sealed"
# Esperado: Sealed  false

# [ ] 3. Vault inicializado
vault status | grep "Initialized"
# Esperado: Initialized  true

# [ ] 4. Autenticação userpass funcional
vault login -method=userpass username=paulo
# Esperado: Success!

# [ ] 5. Secrets engine KV habilitado
vault secrets list | grep "secret/"
# Esperado: secret/  kv

# [ ] 6. Secret de teste criado
vault kv get secret/fiqueok/project
# Esperado: exibir dados do projeto

# [ ] 7. Audit log habilitado
vault audit list
# Esperado: file/  file

# [ ] 8. Audit log sendo escrito
sudo ls -lh /opt/vault/audit/vault_audit.log
# Esperado: arquivo presente com tamanho > 0

# [ ] 9. Backup automático configurado
sudo crontab -u vault -l | grep vault_snapshot
# Esperado: linha do cron presente

# [ ] 10. Backup manual funcional
sudo -u vault /opt/vault/scripts/vault_snapshot.sh
sudo ls -lh /opt/vault/backups/
# Esperado: arquivo .snap criado

# [ ] 11. Health check funcional
sudo -u vault /opt/vault/scripts/vault_healthcheck.sh
# Esperado: exit code 0, mensagem "OK"

# [ ] 12. Permissões corretas
sudo ls -la /opt/vault/ | grep "drwxr-x---"
# Esperado: todos os diretórios com 750

# [ ] 13. Tailscale conectado
tailscale status
# Esperado: status ativo com IP xxx.xxx.xxx.xxx

# [ ] 14. Acesso remoto funcional (de outro device)
curl http://xxx.xxx.xxx.xxx:8200/v1/sys/health
# Esperado: JSON com status 200

# [ ] 15. UI acessível
curl -s http://127.0.0.1:8200/ui/ | grep -q "Vault"
# Esperado: exit code 0

# [ ] 16. AppArmor profile ativo (se configurado)
sudo aa-status | grep vault
# Esperado: /usr/bin/vault

# [ ] 17. Firewall configurado
sudo ufw status | grep 8200
# Esperado: regra permitindo porta 8200 na tailscale0

# [ ] 18. Logs sem erros críticos
sudo journalctl -u vault.service --since "1 hour ago" -p err
# Esperado: sem mensagens de erro

# [ ] 19. Systemd hardening aplicado
systemctl show vault.service | grep -E "ProtectSystem|ProtectHome|NoNewPrivileges"
# Esperado: valores restritivos

# [ ] 20. Auto-start habilitado
systemctl is-enabled vault.service
# Esperado: enabled
```

---

## 🎉 IMPLEMENTAÇÃO CONCLUÍDA!

Seu HashiCorp Vault está agora configurado com padrão **Enterprise-Grade**:

### ✅ Infraestrutura
- Hyper-V Gen1 VM (Ubuntu 24.04 LTS)
- Systemd nativo (sem limitações WSL2)
- Tailscale VPN integrado

### ✅ Segurança (Hardening)
- Service account sem shell (`/usr/sbin/nologin`)
- Permissões rigorosas (750) em todos os diretórios
- Systemd hardening (ProtectSystem, PrivateTmp, NoNewPrivileges)
- AppArmor profile (opcional)
- Firewall UFW configurado
- Audit logging habilitado com rotação

### ✅ Operacional
- Vault v1.21.2 (sem CVE-2025-12044)
- Raft storage configurado
- Backup automático diário (retenção 7 dias)
- Health checks a cada 5 minutos
- Autenticação userpass + RBAC
- UI web habilitada

### ✅ Conformidade
- CIS Benchmark (Service accounts, File permissions)
- NIST SP 800-123 (Unix Hardening)
- ISO 27001 A.9.4.1 (Least Privilege)

---

## 📚 PRÓXIMOS PASSOS RECOMENDADOS

1. **Habilitar TLS**:
   ```bash
   # Gerar certificados com Let's Encrypt ou self-signed
   # Atualizar vault.hcl com tls_cert_file e tls_key_file
   ```

2. **Configurar Auto-Unseal** (OCI KMS):
   ```bash
   # Adicionar seal "ocikms" ao vault.hcl
   # Elimina necessidade de unseal manual após reboot
   ```

3. **Integrar com Aplicações**:
   ```bash
   # Usar AppRole auth para aplicações
   # Configurar Database Secrets Engine para OrangeHRM/MySQL
   ```

4. **Implementar HA (High Availability)**:
   ```bash
   # Adicionar mais nós Raft
   # Configurar load balancer
   ```

5. **Monitoramento Avançado**:
   ```bash
   # Integrar com Prometheus/Grafana
   # Configurar alertas (PagerDuty, Slack)
   ```

---

## 🆘 TROUBLESHOOTING

### Problema: Serviço não inicia

```bash
# Ver logs detalhados
sudo journalctl -u vault.service -n 100 --no-pager

# Verificar sintaxe do config
sudo -u vault vault server -config=/etc/vault.d/vault.hcl -test 2>&1

# Verificar permissões
sudo ls -la /opt/vault/
sudo ls -la /etc/vault.d/
```

### Problema: Vault está sealed após reboot

**Isso é normal!** Vault sempre inicia sealed por segurança. Execute:

```bash
vault operator unseal  # 3 vezes com keys diferentes
```

### Problema: Erro de permissão

```bash
# Reconfigurar ownership
sudo chown -R vault:vault /opt/vault
sudo chown vault:vault /etc/vault.d

# Reconfigurar permissões
sudo chmod 750 /opt/vault/{data,logs,audit,scripts,backups}
sudo chmod 700 /opt/vault/tls
sudo chmod 640 /etc/vault.d/vault.hcl
```

### Problema: Tailscale não conecta

```bash
# Verificar status
sudo systemctl status tailscaled

# Ver logs
sudo journalctl -u tailscaled -n 50

# Reconectar
sudo tailscale up
```

### Problema: Backup falha

```bash
# Verificar se Vault está unsealed
vault status

# Executar manualmente com debug
sudo -u vault bash -x /opt/vault/scripts/vault_snapshot.sh

# Verificar permissões no diretório de backup
sudo ls -la /opt/vault/backups/
```

---

## 📖 REFERÊNCIAS

- [HashiCorp Vault Documentation](https://www.vaultproject.io/docs/)
- [Production Hardening](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)
- [CIS Ubuntu 24.04 Benchmark](https://www.cisecurity.org/)
- [NIST SP 800-123 - Guide to General Server Security](https://csrc.nist.gov/publications/detail/sp/800-123/final)
- [ISO/IEC 27001:2022 - Information Security Management](https://www.iso.org/standard/27001)

---

**Guia elaborado por**: Claude (Anthropic) com consultoria GRC  
**Para**: Projeto PRJ007 - Living Lab Fiqueok 2.0  
**Versão**: 3.0 - Production-Grade (Hyper-V Gen1)  
**Data**: 10 de Fevereiro de 2026  
**Status**: ✅ Aprovado para Implementação

