# Guia de Implementação - HashiCorp Vault no WSL2 (Instalação Nativa)

**Projeto**: PRJ007 - Living Lab Fiqueok 2.0  
**Versão do Guia**: 2.0  
**Data**: 08 de Fevereiro de 2026  
**Arquitetura**: WSL2 Ubuntu 22.04 + Vault 1.21.2 (instalação nativa)  
**Assistente**: Claude (Anthropic)

---

## 🎯 Objetivo

Implementar HashiCorp Vault v1.21.2 de forma nativa no Ubuntu WSL2, eliminando problemas de file locking identificados na tentativa anterior com Docker.

---

## ✅ Pré-Requisitos

Antes de começar, verifique:

1. ✅ WSL2 instalado no Windows
2. ✅ Ubuntu 22.04 restaurado do backup Greenfield
3. ✅ Auditoria de segurança concluída (security_audit_checklist.md)
4. ✅ Conexão com internet ativa
5. ✅ Pelo menos 2GB de espaço em disco livre

---

## 📋 ETAPA 0: Verificações Iniciais

### 0.1 Confirmar Versão do Ubuntu

```bash
wsl -d Ubuntu-22.04 -u paulo

# Dentro do WSL2:
lsb_release -a
```

**Saída esperada**:
```
Distributor ID: Ubuntu
Description:    Ubuntu 22.04.x LTS
Release:        22.04
Codename:       jammy
```

### 0.2 Verificar systemd

```bash
systemctl --version
```

**Se retornar erro "System has not been booted with systemd"**:

```bash
# Editar configuração do WSL2
sudo nano /etc/wsl.conf

# Adicionar:
[boot]
systemd=true

# Salvar (Ctrl+O, Enter, Ctrl+X)

# Sair do WSL2
exit

# No PowerShell/CMD do Windows:
wsl --shutdown

# Aguardar 10 segundos e reiniciar WSL2
wsl -d Ubuntu-22.04 -u paulo

# Verificar novamente
systemctl --version
```

**Saída esperada**:
```
systemd 249 (249.11-0ubuntu3.x)
+PAM +AUDIT +SELINUX +APPARMOR +IMA +SMACK +SECCOMP ...
```

### 0.3 Atualizar Sistema

```bash
sudo apt update
sudo apt upgrade -y
```

---

## 📋 ETAPA 1: Instalação do HashiCorp Vault

### 1.1 Adicionar Repositório Oficial

```bash
# Baixar chave GPG
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Verificar fingerprint da chave (opcional mas recomendado)
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
```

**Fingerprint esperado**: `E8A0 32E0 94D8 EB4E A189  D270 DA41 8C88 A321 9F7B`

```bash
# Adicionar repositório
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Atualizar índice de pacotes
sudo apt update
```

### 1.2 Instalar Vault 1.21.2

```bash
# Verificar versões disponíveis
apt-cache policy vault

# Instalar versão específica (corrige CVE-2025-12044)
sudo apt install vault=1.21.2-1 -y

# Prevenir upgrades automáticos
sudo apt-mark hold vault
```

### 1.3 Verificar Instalação

```bash
vault version
```

**Saída esperada**:
```
Vault v1.21.2 (5e2dd7a21e64c45a2e1f06feb8629d3f6e8ccd76), built 2024-XX-XX
```

```bash
# Verificar binário
which vault
# Saída: /usr/bin/vault

# Verificar capabilities
getcap /usr/bin/vault
# Saída: /usr/bin/vault = cap_ipc_lock+ep
```

---

## 📋 ETAPA 2: Configuração de Usuário e Diretórios

### 2.1 Criar Usuário Dedicado

```bash
# Criar usuário de sistema sem login
sudo useradd --system --home /opt/vault --shell /bin/false vault

# Verificar criação
id vault
```

**Saída esperada**:
```
uid=XXX(vault) gid=XXX(vault) groups=XXX(vault)
```

### 2.2 Criar Estrutura de Diretórios

```bash
# Criar diretórios
sudo mkdir -p /opt/vault/data
sudo mkdir -p /opt/vault/logs
sudo mkdir -p /etc/vault.d

# Aplicar ownership
sudo chown -R vault:vault /opt/vault
sudo chown vault:vault /etc/vault.d

# Aplicar permissões seguras (750 = rwxr-x---)
sudo chmod 750 /opt/vault
sudo chmod 750 /opt/vault/data
sudo chmod 750 /opt/vault/logs
sudo chmod 750 /etc/vault.d

# Verificar permissões
ls -la /opt/ | grep vault
ls -la /opt/vault/
```

**Saída esperada**:
```
drwxr-x--- 4 vault vault 4096 Feb  8 20:00 vault
drwxr-x--- 2 vault vault 4096 Feb  8 20:00 data
drwxr-x--- 2 vault vault 4096 Feb  8 20:00 logs
```

---

## 📋 ETAPA 3: Configuração do Vault

### 3.1 Criar Arquivo de Configuração Principal

```bash
sudo tee /etc/vault.d/vault.hcl > /dev/null <<'EOF'
# Configuração do HashiCorp Vault - PRJ007 Living Lab Fiqueok
# Ambiente: Home Lab WSL2 Ubuntu 22.04
# Versão: 1.21.2
# Data: 08 de Fevereiro de 2026

# Backend de armazenamento integrado (Raft)
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-fiqueok-node1"
  
  # Performance tuning para ambiente de laboratório
  performance_multiplier = 1
}

# Listener HTTP (desenvolvimento)
listener "tcp" {
  address       = "127.0.0.1:8200"
  tls_disable   = "true"
  
  # ATENÇÃO: Em produção, sempre usar TLS
  # tls_cert_file = "/opt/vault/tls/vault.crt"
  # tls_key_file  = "/opt/vault/tls/vault.key"
}

# Listener para Tailscale VPN (quando configurado)
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = "true"
}

# API e cluster addressing
api_addr     = "http://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"

# Habilitar UI web
ui = true

# Telemetria (desabilitada para privacidade)
telemetry {
  disable_hostname = true
}

# Logs
log_level  = "info"
log_format = "json"

# Desabilitar mlock em ambientes virtualizados
# NOTA: Em produção bare-metal, remover esta linha
disable_mlock = true

# Configurações de performance
max_lease_ttl         = "768h"
default_lease_ttl     = "768h"
disable_cache         = false
disable_printable_check = false
EOF
```

### 3.2 Aplicar Permissões ao Arquivo de Configuração

```bash
sudo chown vault:vault /etc/vault.d/vault.hcl
sudo chmod 640 /etc/vault.d/vault.hcl

# Verificar
ls -la /etc/vault.d/
```

**Saída esperada**:
```
-rw-r----- 1 vault vault XXXX Feb  8 20:00 vault.hcl
```

### 3.3 Validar Configuração

```bash
# Testar sintaxe do arquivo
sudo -u vault vault server -config=/etc/vault.d/vault.hcl -test

# Se não houver erros, não haverá output
```

---

## 📋 ETAPA 4: Configuração do Systemd Service

### 4.1 Criar Unit File

```bash
sudo tee /etc/systemd/system/vault.service > /dev/null <<'EOF'
[Unit]
Description=HashiCorp Vault - Secrets Management Tool
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
Type=notify
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF
```

### 4.2 Recarregar Systemd e Habilitar Serviço

```bash
# Recarregar configurações
sudo systemctl daemon-reload

# Habilitar auto-start
sudo systemctl enable vault.service

# Verificar status (ainda não iniciado)
sudo systemctl status vault.service
```

**Saída esperada**:
```
● vault.service - HashiCorp Vault - Secrets Management Tool
     Loaded: loaded (/etc/systemd/system/vault.service; enabled; vendor preset: enabled)
     Active: inactive (dead)
```

---

## 📋 ETAPA 5: Inicialização do Vault

### 5.1 Iniciar Serviço

```bash
sudo systemctl start vault.service

# Aguardar 5 segundos
sleep 5

# Verificar status
sudo systemctl status vault.service
```

**Saída esperada**:
```
● vault.service - HashiCorp Vault - Secrets Management Tool
     Loaded: loaded
     Active: active (running) since ...
```

### 5.2 Verificar Logs

```bash
# Logs em tempo real
sudo journalctl -u vault.service -f

# Últimas 50 linhas
sudo journalctl -u vault.service -n 50 --no-pager
```

**Procurar por**:
- ✅ `"listener 1": tcp (addr: "127.0.0.1:8200", cluster address: ...)`
- ✅ `"ui": true`
- ✅ Vault server started! Log data will stream in below

### 5.3 Verificar Conectividade

```bash
# Exportar variável de ambiente
export VAULT_ADDR='http://127.0.0.1:8200'

# Adicionar ao perfil para persistência
echo 'export VAULT_ADDR="http://127.0.0.1:8200"' >> ~/.bashrc

# Verificar status
vault status
```

**Saída esperada**:
```
Key                Value
---                -----
Seal Type          shamir
Initialized        false
Sealed             true
...
```

---

## 📋 ETAPA 6: Inicialização (Operator Init)

### 6.1 Inicializar Vault

```bash
# Criar diretório para backup das keys
mkdir -p ~/vault-backup
chmod 700 ~/vault-backup

# Inicializar com 5 key shares, threshold de 3
vault operator init \
  -key-shares=5 \
  -key-threshold=3 \
  -format=json > ~/vault-backup/vault_init_$(date +%Y%m%d_%H%M%S).json

# Criar cópia em texto legível
vault operator init \
  -key-shares=5 \
  -key-threshold=3 > ~/vault-backup/vault_init_$(date +%Y%m%d_%H%M%S).txt
```

**⚠️ CRÍTICO - BACKUP DAS KEYS**:

```bash
# Exibir o arquivo para copiar manualmente
cat ~/vault-backup/vault_init_*.txt
```

**Você verá algo como**:
```
Unseal Key 1: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Unseal Key 2: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Unseal Key 3: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Unseal Key 4: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Unseal Key 5: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Initial Root Token: hvs.xxxxxxxxxxxxxxxxxxxx
```

**AÇÕES OBRIGATÓRIAS**:
1. ✅ Copiar TODAS as 5 unseal keys para 3 locais diferentes
2. ✅ Copiar o Root Token para local seguro
3. ✅ Fazer backup do arquivo `vault_init_*.txt` em pendrive/nuvem
4. ✅ **NUNCA** compartilhar ou commitar essas keys no Git

### 6.2 Unseal do Vault

```bash
# Unseal usando 3 das 5 keys
vault operator unseal <UNSEAL_KEY_1>
# Saída: Sealed: true, Unseal Progress: 1/3

vault operator unseal <UNSEAL_KEY_2>
# Saída: Sealed: true, Unseal Progress: 2/3

vault operator unseal <UNSEAL_KEY_3>
# Saída: Sealed: false ✅
```

### 6.3 Verificar Status Unsealed

```bash
vault status
```

**Saída esperada**:
```
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false    ← ✅ SUCESSO!
Total Shares            5
Threshold               3
Version                 1.21.2
Storage Type            raft
Cluster Name            vault-cluster-XXXX
Cluster ID              XXXX
HA Enabled              true
```

---

## 📋 ETAPA 7: Autenticação e Configuração Inicial

### 7.1 Login com Root Token

```bash
# Autenticar (usar token do arquivo vault_init_*.txt)
vault login <ROOT_TOKEN>
```

**Saída esperada**:
```
Success! You are now authenticated.
token: hvs.XXXX
token_policies: ["root"]
```

### 7.2 Habilitar Auditoria

```bash
# Criar diretório de audit logs
sudo mkdir -p /opt/vault/audit
sudo chown vault:vault /opt/vault/audit
sudo chmod 750 /opt/vault/audit

# Habilitar file audit backend
vault audit enable file file_path=/opt/vault/audit/vault_audit.log
```

### 7.3 Habilitar Autenticação UserPass

```bash
# Habilitar método userpass
vault auth enable userpass

# Verificar
vault auth list
```

**Saída esperada**:
```
Path         Type        ...
----         ----        ...
token/       token       ...
userpass/    userpass    ...
```

---

## 📋 ETAPA 8: Configuração de Políticas e Usuários

### 8.1 Criar Política de Administrador

```bash
vault policy write admin - <<EOF
# Política de Administrador - PRJ007 Living Lab Fiqueok
# Acesso total exceto para revogar root token

# Acesso de leitura/escrita em todos os paths
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Gerenciamento de políticas
path "sys/policies/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Gerenciamento de auth methods
path "sys/auth/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Gerenciamento de audit devices
path "sys/audit/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Gerenciamento de secrets engines
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF
```

### 8.2 Criar Política de Desenvolvedor

```bash
vault policy write developer - <<EOF
# Política de Desenvolvedor - PRJ007 Living Lab Fiqueok
# Acesso aos secrets do projeto, sem permissões de admin

# Acesso ao KV secrets engine
path "secret/data/*" {
  capabilities = ["create", "read", "update", "list"]
}

path "secret/metadata/*" {
  capabilities = ["list", "read", "delete"]
}

# Renovação de próprio token
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# Lookup de próprias capabilities
path "sys/capabilities-self" {
  capabilities = ["read"]
}
EOF
```

### 8.3 Criar Usuário Paulo (Admin)

```bash
# Criar usuário com política admin
vault write auth/userpass/users/paulo \
  password="<DEFINA_UMA_SENHA_FORTE>" \
  policies="admin"
```

**⚠️ IMPORTANTE**: Substitua `<DEFINA_UMA_SENHA_FORTE>` por uma senha segura (mínimo 16 caracteres, letras, números, símbolos)

### 8.4 Testar Autenticação

```bash
# Fazer logout do root token
vault token revoke -self

# Login com usuário paulo
vault login -method=userpass username=paulo

# Verificar token atual
vault token lookup
```

**Saída esperada**:
```
policies      [admin default]
...
```

---

## 📋 ETAPA 9: Configuração de Secrets Engine

### 9.1 Habilitar KV Secrets Engine v2

```bash
# Habilitar KV v2 no path 'secret'
vault secrets enable -version=2 -path=secret kv

# Verificar
vault secrets list
```

**Saída esperada**:
```
Path          Type         ...
----          ----         ...
secret/       kv           ...
sys/          system       ...
```

### 9.2 Criar Secret de Teste

```bash
# Criar secret de exemplo
vault kv put secret/fiqueok/project \
  project_name="Living Lab Fiqueok 2.0" \
  project_code="PRJ007" \
  environment="home_lab"

# Ler secret
vault kv get secret/fiqueok/project
```

**Saída esperada**:
```
====== Data ======
Key              Value
---              -----
environment      home_lab
project_code     PRJ007
project_name     Living Lab Fiqueok 2.0
```

---

## 📋 ETAPA 10: Configuração de Backup Automático

### 10.1 Criar Script de Backup

```bash
# Criar diretório para scripts
sudo mkdir -p /opt/vault/scripts
sudo chown vault:vault /opt/vault/scripts

# Criar script de snapshot
sudo tee /opt/vault/scripts/vault_snapshot.sh > /dev/null <<'EOF'
#!/bin/bash
# Script de Backup Automático - HashiCorp Vault PRJ007
# Executa snapshot do Raft storage

BACKUP_DIR="/opt/vault/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/vault_snapshot_${DATE}.snap"
RETENTION_DAYS=7

# Criar diretório se não existir
mkdir -p "${BACKUP_DIR}"

# Executar snapshot
vault operator raft snapshot save "${BACKUP_FILE}"

# Verificar sucesso
if [ $? -eq 0 ]; then
    echo "[$(date)] Snapshot criado com sucesso: ${BACKUP_FILE}"
    
    # Remover backups antigos
    find "${BACKUP_DIR}" -name "vault_snapshot_*.snap" -mtime +${RETENTION_DAYS} -delete
    echo "[$(date)] Backups antigos removidos (retenção: ${RETENTION_DAYS} dias)"
else
    echo "[$(date)] ERRO ao criar snapshot!"
    exit 1
fi
EOF

# Tornar executável
sudo chmod +x /opt/vault/scripts/vault_snapshot.sh
sudo chown vault:vault /opt/vault/scripts/vault_snapshot.sh

# Criar diretório de backups
sudo mkdir -p /opt/vault/backups
sudo chown vault:vault /opt/vault/backups
```

### 10.2 Configurar Cron Job

```bash
# Editar crontab do usuário vault
sudo -u vault crontab -e

# Adicionar (backup diário às 3h da manhã):
0 3 * * * /opt/vault/scripts/vault_snapshot.sh >> /opt/vault/logs/backup.log 2>&1
```

### 10.3 Testar Backup Manual

```bash
# Login no Vault
vault login -method=userpass username=paulo

# Executar backup
sudo -u vault /opt/vault/scripts/vault_snapshot.sh

# Verificar arquivo criado
ls -lh /opt/vault/backups/
```

---

## 📋 ETAPA 11: Configuração de Monitoramento

### 11.1 Script de Health Check

```bash
sudo tee /opt/vault/scripts/vault_healthcheck.sh > /dev/null <<'EOF'
#!/bin/bash
# Health Check - HashiCorp Vault PRJ007

export VAULT_ADDR='http://127.0.0.1:8200'

# Verificar se serviço está rodando
if ! systemctl is-active --quiet vault.service; then
    echo "[$(date)] CRÍTICO: Serviço Vault não está rodando!"
    exit 2
fi

# Verificar status do Vault
STATUS=$(vault status -format=json 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "[$(date)] CRÍTICO: Não foi possível conectar ao Vault!"
    exit 2
fi

# Verificar se está unsealed
SEALED=$(echo "$STATUS" | jq -r '.sealed')

if [ "$SEALED" = "true" ]; then
    echo "[$(date)] CRÍTICO: Vault está SELADO!"
    exit 2
fi

# Verificar se está inicializado
INITIALIZED=$(echo "$STATUS" | jq -r '.initialized')

if [ "$INITIALIZED" = "false" ]; then
    echo "[$(date)] AVISO: Vault não está inicializado!"
    exit 1
fi

# Tudo OK
echo "[$(date)] OK: Vault operacional (unsealed, initialized)"
exit 0
EOF

sudo chmod +x /opt/vault/scripts/vault_healthcheck.sh
sudo chown vault:vault /opt/vault/scripts/vault_healthcheck.sh

# Instalar jq (se não estiver instalado)
sudo apt install jq -y
```

### 11.2 Configurar Health Check Periódico

```bash
# Adicionar ao crontab (verificação a cada 5 minutos)
sudo -u vault crontab -e

# Adicionar:
*/5 * * * * /opt/vault/scripts/vault_healthcheck.sh >> /opt/vault/logs/healthcheck.log 2>&1
```

---

## 📋 ETAPA 12: Integração com Tailscale (Opcional)

### 12.1 Instalar Tailscale no WSL2

```bash
# Adicionar repositório Tailscale
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

# Instalar
sudo apt update
sudo apt install tailscale -y

# Iniciar serviço
sudo systemctl enable --now tailscaled

# Autenticar
sudo tailscale up
```

### 12.2 Verificar IP Tailscale

```bash
tailscale ip -4
```

**Anote o IP** (exemplo: 100.x.x.x)

### 12.3 Testar Acesso Remoto

```bash
# De outro dispositivo na rede Tailscale:
curl http://<TAILSCALE_IP>:8200/v1/sys/health
```

---

## ✅ CHECKLIST FINAL DE VALIDAÇÃO

Execute cada item e marque quando concluído:

```bash
# 1. Serviço ativo
systemctl is-active vault.service
# Resultado esperado: active

# 2. Vault unsealed
vault status | grep Sealed
# Resultado esperado: Sealed: false

# 3. Autenticação funcional
vault login -method=userpass username=paulo
# Resultado esperado: Success!

# 4. Secrets engine funcionando
vault kv get secret/fiqueok/project
# Resultado esperado: exibir dados do projeto

# 5. Backup funcionando
ls -lh /opt/vault/backups/
# Resultado esperado: pelo menos 1 arquivo .snap

# 6. Logs acessíveis
sudo journalctl -u vault.service --since "10 minutes ago" | tail -20
# Resultado esperado: sem erros críticos

# 7. UI acessível
curl -s http://127.0.0.1:8200/ui/ | grep -q "Vault"
# Resultado esperado: código 0 (encontrou)

# 8. Audit log criado
ls -lh /opt/vault/audit/
# Resultado esperado: vault_audit.log presente

# 9. Permissões corretas
ls -la /opt/vault/data/ | head -2
# Resultado esperado: drwxr-x--- vault vault

# 10. Auto-unseal funcional (após reboot WSL2)
wsl --shutdown
# Aguardar 10 segundos
wsl -d Ubuntu-22.04 -u paulo
vault status | grep Initialized
# Resultado esperado: Initialized: true
# NOTA: Vault estará SEALED após reboot - isso é normal!
```

---

## 🎉 IMPLEMENTAÇÃO CONCLUÍDA!

Seu HashiCorp Vault está agora:

- ✅ Instalado nativamente no Ubuntu WSL2
- ✅ Rodando como serviço systemd
- ✅ Configurado com permissões seguras (750)
- ✅ Inicializado e unsealed
- ✅ Com autenticação userpass configurada
- ✅ Com políticas RBAC (admin, developer)
- ✅ Com backup automático diário
- ✅ Com health check a cada 5 minutos
- ✅ Com audit logging habilitado
- ✅ Versão 1.21.2 (sem CVE-2025-12044)

---

## 📚 Próximos Passos Sugeridos

1. **Documentar no LinkedIn**: Criar post sobre a implementação
2. **Configurar TLS**: Para ambiente de produção
3. **Integrar com aplicações**: Usar Vault para armazenar credenciais
4. **Explorar Secrets Engines**: Database, SSH, PKI
5. **Implementar Auto-Unseal**: Usando AWS KMS ou Transit engine

---

## 🆘 Troubleshooting

### Problema: Serviço não inicia

```bash
# Verificar logs detalhados
sudo journalctl -u vault.service -n 100 --no-pager

# Verificar sintaxe do config
sudo -u vault vault server -config=/etc/vault.d/vault.hcl -test
```

### Problema: Não consigo fazer unseal

```bash
# Verificar se está inicializado
vault status

# Se Initialized: false, executar ETAPA 6 novamente
```

### Problema: Erro de permissões

```bash
# Reconfigurar ownership
sudo chown -R vault:vault /opt/vault
sudo chmod 750 /opt/vault/{data,logs,audit}
```

---

**Guia elaborado por**: Claude (Anthropic)  
**Para**: Projeto PRJ007 - Living Lab Fiqueok 2.0  
**Versão**: 2.0 - Instalação Nativa (pós-análise de falha Docker)
