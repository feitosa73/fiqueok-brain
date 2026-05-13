# Análise de Viabilidade Técnica - HashiCorp Vault no Living Lab Fiqueok

**Projeto**: PRJ007  
**Data**: 08 de Fevereiro de 2026  
**Análise por**: Claude (Anthropic)  
**Contexto**: Recuperação pós-incidente OCI + falha WSL2/Docker

---

## 1. Análise das Tentativas Anteriores

### 1.1 Implementação OCI (✅ Sucesso Técnico / ❌ Falha Operacional)

**Configuração**:
- Plataforma: Oracle Cloud Infrastructure - ARM Ampere
- Localização: Vinhedo, Brasil
- Recursos: 24GB RAM, Ubuntu + Docker
- Vault: v1.21.2
- Conectividade: Tailscale Mesh VPN (xxx.xxx.xxx.xxx)

**Causa da Falha**: Erro humano (terminate acidental) + indisponibilidade de novas instâncias ARM gratuitas

**Lições Aprendidas**:
- ✅ Arquitetura funcionou perfeitamente
- ❌ Falta de proteção contra exclusão acidental
- ❌ Ausência de snapshots/backups automáticos
- ✅ Documentação adequada (evidências para LinkedIn)

### 1.2 Tentativa WSL2 + Docker (❌ Falha Técnica + Segurança)

**Problemas Identificados**:

1. **Violação de Segurança Crítica**:
   - Sugestão de `chmod 777` em diretórios sensíveis
   - Quebra de princípio Least Privilege (ISO 27001 A.9.4.1)
   - Risco de exposão de master keys/unseal tokens

2. **Incompatibilidade Técnica**:
   - Raft Storage Backend requer file locking
   - WSL2 não suporta adequadamente syscalls de bloqueio em bind mounts
   - Container em loop de restart (status "Restarting (1)")

3. **Análise de CVEs Incompleta**:
   - CVE-2025-12044 mencionada mas não validada
   - Versão 1.21.0 recomendada corretamente, mas não implementada
   - Faltou contexto sobre cadeia de 6 CVEs descobertas

**Decisão Correta**: Rollback para Greenfield (Stop Work Authority aplicado)

---

## 2. Opções de Implementação Avaliadas

### Opção A: WSL2 + Instalação Nativa (SEM Docker)

**Descrição**: Instalar Vault diretamente no Ubuntu WSL2 como serviço systemd.

**Vantagens**:
- ✅ Elimina problemas de file locking do Docker
- ✅ Controle total sobre permissões e configurações
- ✅ Melhor performance (sem overhead de container)
- ✅ Logs nativos do systemd (journalctl)
- ✅ Backup simplificado (exportação WSL2)

**Desvantagens**:
- ⚠️ WSL2 pode não ter systemd habilitado por padrão
- ⚠️ Requer configuração manual de auto-start
- ⚠️ Menos portável que containers

**Complexidade**: Média  
**Tempo Estimado**: 1-2 horas  
**Risco de Falha**: Baixo (se systemd disponível)

**Verificação Prévia Necessária**:
```bash
wsl -d Ubuntu-22.04 -- systemctl --version
```

---

### Opção B: Docker no WSL2 com Volumes Nomeados

**Descrição**: Usar volumes gerenciados pelo Docker em vez de bind mounts.

**Vantagens**:
- ✅ Contorna limitações de file locking do WSL2
- ✅ Portabilidade (docker-compose.yml)
- ✅ Facilidade de backup (docker volume export)
- ✅ Isolamento de recursos

**Desvantagens**:
- ❌ Mesma base da tentativa anterior (WSL2 + Docker)
- ⚠️ Histórico de problemas de permissões em WSL2
- ⚠️ Menor visibilidade de logs

**Complexidade**: Média  
**Tempo Estimado**: 2-3 horas (incluindo testes)  
**Risco de Falha**: Médio

**Configuração Proposta**:
```yaml
version: '3.8'
services:
  vault:
    image: hashicorp/vault:1.21.2
    container_name: vault
    cap_add:
      - IPC_LOCK
    volumes:
      - vault-data:/vault/data      # Volume nomeado (não bind mount)
      - vault-logs:/vault/logs       # Volume nomeado
    ports:
      - "8200:8200"
    environment:
      VAULT_ADDR: 'http://0.0.0.0:8200'
    command: server

volumes:
  vault-data:
    driver: local
  vault-logs:
    driver: local
```

---

### Opção C: Hyper-V com Linux VM Dedicada

**Descrição**: Criar VM Ubuntu Server no Hyper-V para rodar Vault nativamente.

**Vantagens**:
- ✅ Ambiente Linux completo (sem limitações WSL2)
- ✅ Suporte nativo a systemd
- ✅ Melhor isolamento de segurança
- ✅ Snapshots nativos do Hyper-V

**Desvantagens**:
- ❌ Histórico de problemas de estabilidade (citado nos documentos)
- ❌ Maior consumo de recursos (overhead do hypervisor)
- ❌ Complexidade de gestão de rede

**Complexidade**: Alta  
**Tempo Estimado**: 3-4 horas  
**Risco de Falha**: Alto (problemas conhecidos)

**Nota**: Descartada pelo próprio projeto devido a "desafios recorrentes de estabilidade".

---

### Opção D: Retorno à Nuvem (OCI AMD Micro ou AWS Free Tier)

**Descrição**: Utilizar instâncias gratuitas em outras regiões/tipos.

**OCI - Instância AMD Micro (1GB RAM)**:
- ✅ Gratuita permanentemente
- ✅ Arquitetura validada anteriormente
- ⚠️ Recursos limitados (1GB RAM vs 24GB anterior)
- ⚠️ Requer proteção contra exclusão

**AWS Free Tier (t2.micro - 1GB RAM, 12 meses)**:
- ✅ 750 horas/mês grátis (primeiro ano)
- ✅ Ampla documentação
- ❌ Limitado a 12 meses
- ❌ Custos após período gratuito

**Google Cloud Free Tier (e2-micro)**:
- ✅ Gratuito permanentemente (com limitações)
- ✅ 1GB RAM
- ⚠️ Complexidade de configuração

**Complexidade**: Média-Alta  
**Tempo Estimado**: 2-3 horas  
**Risco de Falha**: Baixo (técnico) / Médio (disponibilidade de recursos)

---

## 3. Recomendação Baseada em GRC e Viabilidade

### 🏆 Opção Recomendada: **Opção A - WSL2 + Instalação Nativa**

**Justificativa**:

1. **Técnica**:
   - Elimina o problema raiz identificado (file locking do Docker em WSL2)
   - Comprovadamente estável em ambientes WSL2 com systemd
   - Controle total sobre configurações de segurança

2. **Segurança (ISO 27001)**:
   - Permissões granulares (A.9.4.1)
   - Logs auditáveis via journalctl (A.12.4.1)
   - Segregação de duties mais clara

3. **Operacional**:
   - Backup via exportação WSL2 (validado no Greenfield)
   - Menor complexidade de troubleshooting
   - Sem dependências externas (Docker layers)

4. **Econômica**:
   - Zero custo (Home Lab)
   - Sem limitações de tempo (vs AWS 12 meses)

5. **Aprendizado**:
   - Demonstra conhecimento de instalação nativa
   - Adiciona competência em systemd management
   - Mais próximo de ambientes enterprise

---

## 4. Plano de Implementação (Opção A)

### Fase 1: Pré-Requisitos (15 min)

```bash
# 1. Verificar systemd no WSL2
wsl -d Ubuntu-22.04 -- systemctl --version

# 2. Se necessário, habilitar systemd
# Editar /etc/wsl.conf:
[boot]
systemd=true

# Reiniciar WSL:
wsl --shutdown
```

### Fase 2: Instalação do Vault (30 min)

```bash
# 1. Adicionar repositório HashiCorp
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# 2. Instalar Vault 1.21.2 (corrige CVE-2025-12044)
sudo apt update
sudo apt install vault=1.21.2-1

# 3. Verificar instalação
vault version
```

### Fase 3: Configuração de Segurança (45 min)

```bash
# 1. Criar usuário dedicado
sudo useradd --system --home /opt/vault --shell /bin/false vault

# 2. Criar diretórios com permissões adequadas
sudo mkdir -p /opt/vault/data
sudo mkdir -p /opt/vault/logs
sudo chown -R vault:vault /opt/vault
sudo chmod 750 /opt/vault/{data,logs}

# 3. Criar arquivo de configuração
sudo tee /etc/vault.d/vault.hcl > /dev/null <<EOF
storage "raft" {
  path = "/opt/vault/data"
  node_id = "vault-node-1"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = "true"  # Apenas para desenvolvimento
}

api_addr = "http://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"
ui = true
disable_mlock = true  # Necessário em ambientes virtualizados
EOF

sudo chown vault:vault /etc/vault.d/vault.hcl
sudo chmod 640 /etc/vault.d/vault.hcl
```

### Fase 4: Configuração Systemd (20 min)

```bash
# Criar service unit
sudo tee /etc/systemd/system/vault.service > /dev/null <<EOF
[Unit]
Description=HashiCorp Vault - Secrets Management
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl

[Service]
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
ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitInterval=60
StartLimitBurst=3
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

# Habilitar serviço
sudo systemctl daemon-reload
sudo systemctl enable vault
sudo systemctl start vault
```

### Fase 5: Inicialização e Unseal (30 min)

```bash
# 1. Exportar variável de ambiente
export VAULT_ADDR='http://127.0.0.1:8200'

# 2. Inicializar Vault
vault operator init -key-shares=5 -key-threshold=3 > /tmp/vault_init.txt

# ⚠️ CRÍTICO: Fazer backup seguro de /tmp/vault_init.txt
# Este arquivo contém as unseal keys e root token

# 3. Unseal (usar 3 das 5 keys)
vault operator unseal <KEY1>
vault operator unseal <KEY2>
vault operator unseal <KEY3>

# 4. Autenticar com root token
vault login <ROOT_TOKEN>
```

### Fase 6: Configuração RBAC (1 hora)

```bash
# 1. Habilitar userpass
vault auth enable userpass

# 2. Criar política admin
vault policy write admin - <<EOF
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF

# 3. Criar usuário admin
vault write auth/userpass/users/paulo \
  password="<SENHA_SEGURA>" \
  policies="admin"

# 4. Testar autenticação
vault login -method=userpass username=paulo
```

---

## 5. Plano de Contingência

### Se systemd não estiver disponível no WSL2:

**Alternativa 1**: Usar script de inicialização no `.bashrc`
```bash
# Adicionar ao ~/.bashrc
if ! pgrep -x vault > /dev/null; then
  nohup vault server -config=/etc/vault.d/vault.hcl > /opt/vault/logs/vault.log 2>&1 &
fi
```

**Alternativa 2**: Migrar para Opção B (Docker com volumes nomeados)

---

## 6. Critérios de Sucesso

- [ ] Vault versão 1.21.2 instalado
- [ ] Serviço rodando com usuário dedicado `vault`
- [ ] Permissões 750 em `/opt/vault/{data,logs}`
- [ ] Unseal realizado com sucesso
- [ ] Autenticação userpass funcional
- [ ] UI acessível em http://localhost:8200
- [ ] Logs auditáveis em journalctl
- [ ] Backup do estado inicial (export WSL2)

---

## 7. Mitigação de Riscos Identificados

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| systemd indisponível | Baixa | Médio | Alternativa 1 ou 2 |
| Perda de unseal keys | Média | Crítico | Backup em 3 locais distintos |
| Exclusão acidental | Baixa | Alto | Snapshot WSL2 pré e pós-init |
| CVE não patcheada | Baixa | Alto | Validação de versão 1.21.2 |

---

**Tempo Total Estimado**: 3-4 horas  
**Nível de Complexidade**: Médio  
**Adequação ao Plano Free**: ✅ Total  
**Conformidade ISO 27001**: ✅ A.9.4.1, A.10.1.2, A.12.3.1, A.12.4.1

**Próximo Passo**: Executar auditoria de segurança antes de implementar este plano.

