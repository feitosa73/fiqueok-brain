# Matriz de Readiness PRJ008 — Gate Bloqueante para TAP v3.0
## Living Lab Fiqueok — Programa Greenfield

---

| Campo | Valor |
|---|---|
| **Documento** | GATE-PRJ008-001 — Matriz de Readiness |
| **Versão** | 1.0 |
| **Data de Emissão** | 13/02/2026 16:48 |
| **Responsável** | Paulo Feitosa Lima |
| **Tipo** | Checklist Bloqueante — Pré-requisito para TAP v3.0 |
| **Status** | 🔴 **BLOQUEADO** — Aguardando execução de 13 itens críticos |
| **Documento Base** | ARQ-PRJ003-AS-IS_e_ADR-PRJ008_v2.0-FINAL.md |
| **Aprovação GRC** | ✅ Perplexity AI (13/02/2026) |
| **Próxima Ação** | Executar itens 🔴 → Assinar gate → Solicitar TAP v3.0 |

---

## 🎯 Objetivo deste Documento

Este documento consolida **TODAS as ações pendentes** que impedem o início da Sprint 1 do PRJ008. Ele serve como:

1. **Gate Bloqueante** — TAP v3.0 não pode ser solicitado até que este gate seja liberado
2. **Checklist Executável** — Cada item tem comandos prontos para execução
3. **Rastreabilidade** — Registro formal do que foi feito e quando
4. **Evidência de Governança** — Demonstra disciplina de pré-validação antes de executar

---

## ⚠️ Regra de Bloqueio

```
┌────────────────────────────────────────────────────────────────┐
│                    GATE BLOQUEANTE ATIVO                       │
│                                                                │
│  Este documento NÃO PODE ter nenhum item 🔴 pendente antes de: │
│                                                                │
│  1. Solicitar TAP-PRJ008 v3.0                                  │
│  2. Iniciar Sprint 1 (desenvolvimento)                         │
│  3. Configurar Resource no midPoint                            │
│                                                                │
│  Violação desta regra = Risco R3 (Compliance ISO 27001)        │
└────────────────────────────────────────────────────────────────┘
```

---

## 📋 Sumário Executivo

| Categoria | Total | Concluídos | Pendentes | % Conclusão |
|-----------|-------|------------|-----------|-------------|
| 🔴 **Críticos (bloqueantes)** | 13 | 0 | 13 | 0% |
| 🟡 **Importantes (não bloqueantes)** | 5 | 0 | 5 | 0% |
| 🟢 **Opcionais (pós-execução)** | 4 | 0 | 4 | 0% |
| **TOTAL** | **22** | **0** | **22** | **0%** |

**Status Global:** 🔴 **BLOQUEADO**

**Tempo Estimado Total (Críticos):** ~6-8 horas  
**Prazo Recomendado:** Concluir até **14/02/2026 18:00**

---

## 🔴 SEÇÃO 1: Itens Críticos (Bloqueantes para Sprint 1)

### 1.1 Infraestrutura Base

#### I-01: Provisionar VM `api-gf-01` no Hyper-V

**Status:** ☐ Pendente  
**Prioridade:** 🔴 Crítico  
**Tempo Estimado:** 45 minutos  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 7 (P-01)

**Procedimento:**

```powershell
# PowerShell (Administrador) - Host DESKTOP-O87TPQI

# 1. Criar VM
New-VM -Name "api-gf-01" `
  -MemoryStartupBytes 2GB `
  -Generation 2 `
  -NewVHDPath "C:\Hyper-V\VHDX\api-gf-01\api-gf-01.vhdx" `
  -NewVHDSizeBytes 40GB `
  -SwitchName "vSwitch_External_PRJ003"

# 2. Configurar vCPU
Set-VMProcessor -VMName "api-gf-01" -Count 1

# 3. Configurar boot
Set-VMFirmware -VMName "api-gf-01" -EnableSecureBoot Off

# 4. Montar ISO do Ubuntu 24.04 LTS
Add-VMDvdDrive -VMName "api-gf-01" -Path "C:\ISOs\ubuntu-24.04-live-server-amd64.iso"

# 5. Iniciar instalação
Start-VM -VMName "api-gf-01"
```

**Instalação do Ubuntu:**
- Hostname: `api-gf-01`
- Usuário: `fiqueok`
- IP: DHCP (depois configurar Tailscale)
- Particionamento: Usar disco inteiro (40GB)
- Pacotes extras: `openssh-server`

**Critério de Aceite:**
```bash
# Dentro da VM após instalação
hostnamectl | grep "api-gf-01"
systemctl status ssh | grep "active (running)"
```

**Data de Conclusão:** _______________  
**Assinatura:** _______________

---

#### I-02: Migrar VHDX do `IGA-GF-01` para SSD (C:\)

**Status:** ☐ Pendente  
**Prioridade:** 🔴 Crítico  
**Tempo Estimado:** 30 minutos  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 8 (M-05)

**Risco se não executado:** Latência de I/O > 20ms causa timeout no midPoint

**Procedimento:**

```powershell
# PowerShell (Administrador)

# 1. Desligar VM
Stop-VM -Name "IGA-GF-01" -Force

# 2. Verificar localização atual
Get-VMHardDiskDrive -VMName "IGA-GF-01" | Select-Object Path

# Saída esperada: D:\BkpVM\IGA-GF-01\...

# 3. Criar diretório destino
New-Item -ItemType Directory -Path "C:\Hyper-V\VHDX\IGA-GF-01\" -Force

# 4. Copiar VHDX (manter backup em D:\)
Copy-Item "D:\BkpVM\IGA-GF-01\Virtual Hard Disks\IGA-GF-01.vhdx" `
  "C:\Hyper-V\VHDX\IGA-GF-01\IGA-GF-01.vhdx" -Verbose

# 5. Atualizar configuração da VM
Set-VMHardDiskDrive -VMName "IGA-GF-01" `
  -ControllerType SCSI `
  -ControllerNumber 0 `
  -ControllerLocation 0 `
  -Path "C:\Hyper-V\VHDX\IGA-GF-01\IGA-GF-01.vhdx"

# 6. Iniciar VM
Start-VM -Name "IGA-GF-01"
```

**Validação Pós-Migração:**

```bash
# Dentro da VM IGA-GF-01
sudo apt install ioping -y
sudo ioping -c 20 /var/lib/postgresql

# Critério: Latência média < 5ms
```

**Data de Conclusão:** _______________  
**Assinatura:** _______________

---

#### I-03: Instalar Docker + Docker Compose na `api-gf-01`

**Status:** ☐ Pendente (depende de I-01)  
**Prioridade:** 🔴 Crítico  
**Tempo Estimado:** 20 minutos  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 7 (P-02)

**Procedimento:**

```bash
# SSH para api-gf-01

# 1. Atualizar sistema
sudo apt update && sudo apt upgrade -y

# 2. Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 3. Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
newgrp docker

# 4. Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 5. Validar instalação
docker --version
docker-compose --version

# 6. Testar
docker run hello-world
```

**Critério de Aceite:**
```bash
docker --version  # Docker version 25.x
docker-compose --version  # Docker Compose version v2.24.0
docker ps  # Sem erro de permissão
```

**Data de Conclusão:** _______________  
**Assinatura:** _______________

---

#### I-04: Instalar e configurar Tailscale na `api-gf-01`

**Status:** ☐ Pendente (depende de I-01)  
**Prioridade:** 🔴 Crítico  
**Tempo Estimado:** 15 minutos  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 7 (P-03, P-04)

**Procedimento:**

```bash
# SSH para api-gf-01

# 1. Instalar Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# 2. Autenticar com chave efêmera (renovação automática 7 dias)
sudo tailscale up --authkey=tskey-auth-XXXXX-YYYYYYY --hostname=api-gf-01

# ⚠️ IMPORTANTE: Gerar chave efêmera no painel Tailscale antes
# https://login.tailscale.com/admin/settings/keys
# - Ephemeral: Yes
# - Reusable: No
# - Expiry: 7 days

# 3. Validar conectividade
tailscale status
tailscale ip -4  # Anotar IP Tailscale

# 4. Testar conectividade com outros nós
ping -c 3 xxx.xxx.xxx.xxx  # IGA-GF-01
ping -c 3 xxx.xxx.xxx.xxx   # VAULT-GEN1
ping -c 3 xxx.xxx.xxx.xxx   # rh-gf-01-local
```

**Critério de Aceite:**
```bash
tailscale status | grep "api-gf-01"
# Output: api-gf-01  fiqueok@  linux  active; direct, tx 1234 rx 5678
```

**Registrar IP Tailscale:** `100.___.___.___ ` ← **ANOTAR AQUI**

**Data de Conclusão:** _______________  
**Assinatura:** _______________

---

### 1.2 Banco de Dados e Conectividade

#### DB-01: Criar conta `svc_shadow_api` no MariaDB

**Status:** ☐ Pendente  
**Prioridade:** 🔴 Crítico  
**Tempo Estimado:** 10 minutos  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 7 (P-06)

**Procedimento:**

```bash
# SSH para rh-gf-01-local

# 1. Conectar ao MariaDB
docker exec -it orangehrm-mariadb-1 mysql -u root -p
# Senha: <senha do root>

# 2. Criar usuário com SELECT-only
CREATE USER 'svc_shadow_api'@'%' IDENTIFIED BY '<SENHA_FORTE_AQUI>';

GRANT SELECT ON orangehrm.hs_hr_employee TO 'svc_shadow_api'@'%';
GRANT SELECT ON orangehrm.ohrm_employment_status TO 'svc_shadow_api'@'%';
GRANT SELECT ON orangehrm.ohrm_job_title TO 'svc_shadow_api'@'%';

FLUSH PRIVILEGES;

# 3. Validar permissões
SHOW GRANTS FOR 'svc_shadow_api'@'%';

# 4. Testar conexão
mysql -h xxx.xxx.xxx.xxx -u svc_shadow_api -p orangehrm
SELECT COUNT(*) FROM hs_hr_employee;
```

**Critério de Aceite:**
```sql
-- Não deve funcionar (sem permissão de escrita)
DELETE FROM hs_hr_employee WHERE emp_number = 1;
-- ERROR 1142 (42000): DELETE command denied
```

**Salvar credenciais temporariamente:** `svc_shadow_api:<SENHA>` ← **ANOTAR AQUI** (será movida para Vault)

**Data de Conclusão:** _______________  
**Assinatura:** _______________

---

#### FW-01: Liberar porta 3306 no UFW da `rh-gf-01-local`

**Status:** ☐ Pendente  
**Prioridade:** 🔴 Crítico  
**Tempo Estimado:** 5 minutos  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 3 (FW-01)

**Procedimento:**

```bash
# SSH para rh-gf-01-local

# 1. Verificar status atual
sudo ufw status verbose

# 2. Liberar porta 3306 APENAS via interface Tailscale
sudo ufw allow in on tailscale0 to any port 3306 proto tcp comment "Shadow API MariaDB access"

# 3. Validar regra
sudo ufw status numbered | grep 3306
```

**Critério de Aceite:**
```bash
# De outra VM via Tailscale (ex: api-gf-01 após pronta)
nc -zv xxx.xxx.xxx.xxx 3306
# Connection to xxx.xxx.xxx.xxx 3306 port [tcp/mysql] succeeded!

# De fora da mesh (deve falhar)
nc -zv 192.168.70.11 3306
# nc: connect to 192.168.70.11 port 3306 (tcp) failed: Connection refused
```

**Data de Conclusão:** _______________  
**Assinatura:** _______________

---

### 1.3 HashiCorp Vault

#### VLT-01: Provisionar path `secret/orangehrm` no Vault

**Status:** ☐ Pendente  
**Prioridade:** 🔴 Crítico  
**Tempo Estimado:** 5 minutos  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 7 (P-08)

**Procedimento:**

```bash
# SSH para qualquer VM com Vault CLI configurado
# OU via Tailscale: export VAULT_ADDR=https://xxx.xxx.xxx.xxx:8200

# 1. Autenticar com root token
vault login <ROOT_TOKEN>

# 2. Criar secret com credenciais do MariaDB
vault kv put secret/orangehrm \
  host="xxx.xxx.xxx.xxx" \
  port="3306" \
  database="orangehrm" \
  username="svc_shadow_api" \
  password="<SENHA_DO_DB-01>"

# 3. Validar
vault kv get secret/orangehrm
```

**Critério de Aceite:**
```bash
vault kv get -field=username secret/orangehrm
# Output: svc_shadow_api
```

**Data de Conclusão:** _______________  
**Assinatura:** _______________

---

#### VLT-02: Provisionar path `secret/api-proxy` no Vault

**Status:** ☐ Pendente  
**Prioridade:** 🔴 Crítico  
**Tempo Estimado:** 5 minutos  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 7 (P-09)

**Procedimento:**

```bash
# 1. Criar secret com credenciais OAuth da Shadow API
vault kv put secret/api-proxy \
  client_id="midpoint-connector" \
  client_secret="$(openssl rand -base64 32)" \
  jwt_secret="$(openssl rand -base64 64)"

# 2. Validar
vault kv get secret/api-proxy
```

**Critério de Aceite:**
```bash
vault kv get -field=client_id secret/api-proxy
# Output: midpoint-connector
```

**Data de Conclusão:** _______________  
**Assinatura:** _______________

---

#### VLT-03: Criar política `api-proxy-policy` no Vault

**Status:** ☐ Pendente  
**Prioridade:** 🔴 Crítico  
**Tempo Estimado:** 10 minutos  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 7 (P-10)

**Procedimento:**

```bash
# 1. Criar arquivo de política
cat <<EOF > /tmp/api-proxy-policy.hcl
# Política para Shadow API - Least Privilege
path "secret/data/orangehrm" {
  capabilities = ["read"]
}

path "secret/data/api-proxy" {
  capabilities = ["read"]
}

# Deny all outros paths
path "secret/*" {
  capabilities = ["deny"]
}
EOF

# 2. Aplicar política
vault policy write api-proxy-policy /tmp/api-proxy-policy.hcl

# 3. Gerar token de serviço com TTL 24h
vault token create \
  -policy=api-proxy-policy \
  -period=24h \
  -display-name="shadow-api-service" \
  -format=json | tee /tmp/vault-token.json

# 4. Extrair token
cat /tmp/vault-token.json | jq -r .auth.client_token
```

**Critério de Aceite:**
```bash
# Testar token gerado
export VAULT_TOKEN="<TOKEN_GERADO>"

# Deve funcionar
vault kv get secret/orangehrm  # ✅ Sucesso

# Deve falhar
vault kv get secret/admin  # ❌ Permission denied
```

**Salvar token temporariamente:** `<TOKEN_AQUI>` ← **ANOTAR AQUI** (será copiado para VM)

**Data de Conclusão:** _______________  
**Assinatura:** _______________

---

#### VLT-04: Configurar token na `api-gf-01` com permissão 600

**Status:** ☐ Pendente (depende de VLT-03 e I-01)  
**Prioridade:** 🔴 Crítico  
**Tempo Estimado:** 5 minutos  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 8 (M-04)

**Procedimento:**

```bash
# SSH para api-gf-01

# 1. Criar diretório seguro
sudo mkdir -p /var/lib/shadow-api
sudo chown fiqueok:fiqueok /var/lib/shadow-api

# 2. Salvar token
echo "<TOKEN_DO_VLT-03>" | sudo tee /var/lib/shadow-api/vault_token > /dev/null

# 3. Configurar permissões restritivas
sudo chmod 600 /var/lib/shadow-api/vault_token
sudo chown root:root /var/lib/shadow-api/vault_token

# 4. Validar permissões
ls -la /var/lib/shadow-api/vault_token
# Output: -rw------- 1 root root 95 Feb 13 16:00 vault_token
```

**Critério de Aceite:**
```bash
# Usuário normal não pode ler
cat /var/lib/shadow-api/vault_token
# cat: /var/lib/shadow-api/vault_token: Permission denied

# Root pode ler
sudo cat /var/lib/shadow-api/vault_token
# hvs.XXXXXXX
```

**Data de Conclusão:** _______________  
**Assinatura:** _______________

---

### 1.4 DevSecOps

#### SEC-01: Criar repositório GitHub `shadow-api-orangehrm`

**Status:** ☐ Pendente  
**Prioridade:** 🔴 Crítico  
**Tempo Estimado:** 10 minutos  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 8 (M-01)

**Procedimento:**

```bash
# 1. Criar repositório no GitHub (via web)
# Nome: shadow-api-orangehrm
# Descrição: Shadow API REST para integração OrangeHRM × midPoint IGA
# Visibilidade: Private
# Initialize: README.md, .gitignore (Python), License (MIT)

# 2. Clonar localmente
cd ~/repos
git clone git@github.com:fiqueok/shadow-api-orangehrm.git
cd shadow-api-orangehrm

# 3. Criar estrutura inicial
mkdir -p app/routes app/managers tests/load scripts/security .github/workflows
touch app/__init__.py app/routes/__init__.py app/managers/__init__.py

# 4. Commit estrutura
git add .
git commit -m "chore: estrutura inicial do projeto"
git push origin main
```

**Critério de Aceite:**
```bash
# Repositório acessível
curl -H "Authorization: token <GITHUB_TOKEN>" \
  https://api.github.com/repos/fiqueok/shadow-api-orangehrm
# Status 200
```

**Data de Conclusão:** _______________  
**Assinatura:** _______________

---

#### SEC-02: Implementar GitHub Actions para validação de código

**Status:** ☐ Pendente (depende de SEC-01)  
**Prioridade:** 🔴 Crítico  
**Tempo Estimado:** 30 minutos  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 8 (M-01)

**Procedimento:**

```bash
# 1. Criar workflow de security gates
cat <<'EOF' > .github/workflows/security-gates.yml
name: Security Gates - PR Validation

on:
  pull_request:
    paths:
      - 'app/**/*.py'

jobs:
  auth-validation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install security tools
        run: |
          pip install bandit flake8 safety

      - name: Bandit SAST - Critical only
        run: |
          bandit -f json -o bandit.json app/ -s B101
          CRITICAL=$(jq '.results | map(select(.issue_severity == "HIGH")) | length' bandit.json)
          if [ "$CRITICAL" -gt "0" ]; then
            echo "❌ Found $CRITICAL HIGH severity issues"
            jq '.results[] | select(.issue_severity == "HIGH")' bandit.json
            exit 1
          fi
          echo "✅ No HIGH severity issues"

      - name: Require human approval
        uses: actions/github-script@v7
        with:
          script: |
            const { data: reviews } = await github.rest.pulls.listReviews({
              owner: context.repo.owner,
              repo: context.repo.repo,
              pull_number: context.payload.pull_request.number
            });

            const approved = reviews.some(r => 
              r.state === 'APPROVED' && r.user.type === 'User'
            );

            if (!approved) {
              core.setFailed('❌ Requer aprovação humana para código de autenticação');
            }
EOF

# 2. Commit workflow
git add .github/workflows/security-gates.yml
git commit -m "feat(security): adiciona gates de validação obrigatória"
git push origin main

# 3. Configurar branch protection no GitHub
# - Settings > Branches > Add rule
# - Branch name: main
# - [x] Require pull request reviews (1 approval)
# - [x] Require status checks (security-gates)
# - [x] Include administrators
```

**Critério de Aceite:**
```bash
# Criar PR de teste e validar que workflow executa
git checkout -b test/security-gate
echo "# Test" >> README.md
git add README.md
git commit -m "test: validar security gate"
git push origin test/security-gate

# Abrir PR no GitHub e verificar que workflow roda
```

**Data de Conclusão:** _______________  
**Assinatura:** _______________

---

#### SEC-03: Configurar Tailscale ACLs

**Status:** ☐ Pendente (depende de I-04)  
**Prioridade:** 🔴 Crítico  
**Tempo Estimado:** 15 minutos  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 5 (ADR-D2)

**Procedimento:**

```bash
# 1. Acessar Tailscale Admin Console
# https://login.tailscale.com/admin/acls

# 2. Aplicar ACLs (JSON)
{
  "acls": [
    {
      "action": "accept",
      "src": ["tag:api"],
      "dst": ["tag:vault:8200"]
    },
    {
      "action": "accept",
      "src": ["tag:midpoint"],
      "dst": ["tag:api:8000"]
    },
    {
      "action": "accept",
      "src": ["tag:api"],
      "dst": ["tag:rh:3306"]
    }
  ],
  "tagOwners": {
    "tag:api": ["autogroup:owner"],
    "tag:midpoint": ["autogroup:owner"],
    "tag:vault": ["autogroup:owner"],
    "tag:rh": ["autogroup:owner"]
  }
}

# 3. Aplicar tags aos nós
# api-gf-01 → tag:api
# IGA-GF-01 → tag:midpoint
# VAULT-GEN1 → tag:vault
# rh-gf-01-local → tag:rh

# 4. Validar conectividade
# De api-gf-01:
ping -c 2 xxx.xxx.xxx.xxx  # Vault - deve funcionar
ping -c 2 xxx.xxx.xxx.xxx  # OrangeHRM - deve funcionar
ping -c 2 xxx.xxx.xxx.xxx  # midPoint - deve FALHAR (api não inicia conexão)
```

**Critério de Aceite:**
```bash
# De IGA-GF-01 (midPoint):
curl http://100.x.y.z:8000/health  # Deve funcionar após API estar rodando
```

**Data de Conclusão:** _______________  
**Assinatura:** _______________

---

## 🟡 SEÇÃO 2: Itens Importantes (Não Bloqueantes para Sprint 1)

### 2.1 Buffer de Sprints (M-02)

**Status:** ☐ Pendente  
**Prioridade:** 🟡 Importante  
**Tempo Estimado:** 5 minutos  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 8 (M-02)

**Ação:**
```markdown
Atualizar cronograma no TAP v3.0:
- Sprint 1: 3h → 4h (+1h buffer)
- Sprint 2: 3h → 4h (+1h buffer)
- Sprint 3: 2h → 3h (+1h buffer)
```

**Data de Conclusão:** _______________

---

### 2.2 Script de Geração de Test Data (M-03)

**Status:** ☐ Pendente  
**Prioridade:** 🟡 Importante (bloqueante para aceite final, não para Sprint 1)  
**Tempo Estimado:** 1 hora  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 8 (M-03)

**Procedimento:**

```bash
# Criar script completo conforme documentado na análise do consultor
# (Ver ARQ v2.0 — Seção 8 — M-03 para código completo)

cd scripts
cat > generate_test_data.py <<'EOF'
#!/usr/bin/env python3
# [CÓDIGO COMPLETO NO ARQ v2.0 SEÇÃO 8]
EOF

chmod +x generate_test_data.py

# Executar após Sprint 2 estar concluída
python3 generate_test_data.py --host xxx.xxx.xxx.xxx --user svc_shadow_api --password <SENHA> --total 10000
```

**Data de Conclusão:** _______________

---

### 2.3 Runbook de Rotação de Token Vault (M-04)

**Status:** ☐ Pendente  
**Prioridade:** 🟡 Importante (bloqueante para produção, não para Sprint 1)  
**Tempo Estimado:** 45 minutos  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 8 (M-04)

**Ação:**

```bash
# Criar runbook
mkdir -p docs/runbook
cat > docs/runbook/token-rotation.md <<'EOF'
# Runbook: Rotação de Token Vault da Shadow API

## Frequência
- Automática: Diária (03:00 via cron)
- Manual: Sob demanda ou em caso de suspeita de vazamento

## Procedimento Automático
[CÓDIGO COMPLETO NO ARQ v2.0 SEÇÃO 8 - M-04]

## Procedimento Manual de Emergência
[DOCUMENTAR PASSO A PASSO]
EOF

# Configurar cron job (após deploy em produção)
```

**Data de Conclusão:** _______________

---

### 2.4 Testes de Conectividade End-to-End

**Status:** ☐ Pendente (depende de todos itens 🔴)  
**Prioridade:** 🟡 Importante  
**Tempo Estimado:** 30 minutos  
**Responsável:** Paulo

**Procedimento:**

```bash
# De api-gf-01, validar:

# 1. Conectividade Vault
export VAULT_ADDR=https://xxx.xxx.xxx.xxx:8200
export VAULT_TOKEN=$(sudo cat /var/lib/shadow-api/vault_token)
vault kv get secret/orangehrm  # ✅ Deve funcionar

# 2. Conectividade MariaDB
mysql -h xxx.xxx.xxx.xxx -u svc_shadow_api -p orangehrm
SELECT COUNT(*) FROM hs_hr_employee;  # ✅ Deve retornar > 0

# 3. Conectividade midPoint (após API rodando)
# De IGA-GF-01:
curl http://100.x.y.z:8000/health  # ✅ Deve retornar 200
```

**Data de Conclusão:** _______________

---

### 2.5 Documentar IP Tailscale da `api-gf-01` no TAP v3.0

**Status:** ☐ Pendente (depende de I-04)  
**Prioridade:** 🟡 Importante  
**Tempo Estimado:** 5 minutos  
**Responsável:** Paulo

**Ação:**
```markdown
Atualizar TAP v3.0 — Seção de Topologia:
- api-gf-01: 100.___.___.___  ← [PREENCHER APÓS I-04]
```

**Data de Conclusão:** _______________

---

## 🟢 SEÇÃO 3: Itens Opcionais (Pós-Execução)

### 3.1 Rate Limiting no Endpoint `/oauth/token`

**Status:** ☐ Pendente  
**Prioridade:** 🟢 Opcional  
**Tempo Estimado:** 30 minutos  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 10.6

**Implementação:** Sprint 3 ou pós-PRJ008

---

### 3.2 Webhook de Alerta no SchemaCache

**Status:** ☐ Pendente  
**Prioridade:** 🟢 Opcional  
**Tempo Estimado:** 1 hora  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 10.6

**Implementação:** Sprint 3 ou pós-PRJ008

---

### 3.3 Configurar Audit Logs do Tailscale

**Status:** ☐ Pendente  
**Prioridade:** 🟢 Opcional  
**Tempo Estimado:** 30 minutos  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 10.6

**Implementação:** Pós-PRJ008

---

### 3.4 Log Aggregation (Loki ou equivalente)

**Status:** ☐ Pendente  
**Prioridade:** 🟢 Opcional  
**Tempo Estimado:** 2 horas  
**Responsável:** Paulo  
**Referência:** ARQ v2.0 — Seção 10.6

**Implementação:** Fase futura (não faz parte do PRJ008)

---

## 📊 Dashboard de Progresso

```
┌────────────────────────────────────────────────────────────────┐
│                    PROGRESSO GERAL DO GATE                     │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  🔴 Críticos (13):        [░░░░░░░░░░░░░░░░░░░░] 0%          │
│  🟡 Importantes (5):      [░░░░░░░░░░░░░░░░░░░░] 0%          │
│  🟢 Opcionais (4):        [░░░░░░░░░░░░░░░░░░░░] 0%          │
│                                                                │
│  TOTAL (22):              [░░░░░░░░░░░░░░░░░░░░] 0%          │
│                                                                │
├────────────────────────────────────────────────────────────────┤
│  Status: 🔴 BLOQUEADO                                          │
│  Próxima Ação: Executar I-01 (Provisionar VM api-gf-01)       │
│  Tempo Restante: ~6-8 horas                                    │
└────────────────────────────────────────────────────────────────┘
```

---

## ✅ Critério de Liberação do Gate

```
┌────────────────────────────────────────────────────────────────┐
│                    GATE APPROVAL CHECKLIST                     │
│                                                                │
│  O gate está LIBERADO quando:                                  │
│                                                                │
│  [ ] Todos os 13 itens 🔴 estão concluídos                     │
│  [ ] Checklist Pre-Flight (ARQ v2.0 Seção 3) está assinada    │
│  [ ] Teste de conectividade end-to-end passou                  │
│  [ ] Nenhum item 🔴 tem status "Bloqueado por..."             │
│  [ ] IP Tailscale da api-gf-01 está documentado               │
│                                                                │
│  Aprovador: _____________________________                      │
│  Data/Hora: _____________________________                      │
│                                                                │
│  ⚠️ Após aprovação, pode-se:                                   │
│     ✅ Solicitar TAP-PRJ008 v3.0                               │
│     ✅ Iniciar Sprint 1 (desenvolvimento)                      │
│     ✅ Configurar Resource no midPoint                         │
└────────────────────────────────────────────────────────────────┘
```

---

## 📋 Log de Execução

| Data/Hora | Item | Responsável | Status | Observações |
|-----------|------|-------------|--------|-------------|
| | | | | |
| | | | | |
| | | | | |

---

## 🚨 Registro de Bloqueios

| Data | Item | Motivo do Bloqueio | Ação Corretiva | Status |
|------|------|-------------------|----------------|--------|
| | | | | |

---

## 📝 Notas Técnicas

### Ordem de Execução Recomendada

```
Dia 1 (2-3 horas):
├─ I-02: Migrar VHDX IGA-GF-01 para SSD (30 min)
├─ I-01: Provisionar VM api-gf-01 (45 min)
├─ I-03: Instalar Docker na api-gf-01 (20 min)
└─ I-04: Instalar Tailscale na api-gf-01 (15 min)

Dia 2 (2-3 horas):
├─ DB-01: Criar conta svc_shadow_api (10 min)
├─ FW-01: Liberar UFW porta 3306 (5 min)
├─ VLT-01: Path secret/orangehrm (5 min)
├─ VLT-02: Path secret/api-proxy (5 min)
├─ VLT-03: Política api-proxy-policy (10 min)
└─ VLT-04: Configurar token na VM (5 min)

Dia 3 (1-2 horas):
├─ SEC-01: Criar repositório GitHub (10 min)
├─ SEC-02: GitHub Actions (30 min)
├─ SEC-03: Tailscale ACLs (15 min)
└─ Testes end-to-end (30 min)
```

### Dependências Críticas

```
I-01 (VM) → I-03 (Docker), I-04 (Tailscale), VLT-04 (Token)
DB-01 (Usuário DB) → VLT-01 (Secret)
VLT-03 (Policy) → VLT-04 (Token)
SEC-01 (Repo) → SEC-02 (Workflow)
I-04 (Tailscale) → SEC-03 (ACLs)
```

---

## 🔗 Referências

| Documento | Seção | Descrição |
|-----------|-------|-----------|
| ARQ-PRJ003 v2.0 | Seção 3 | Checklist Pre-Flight |
| ARQ-PRJ003 v2.0 | Seção 7 | Matriz de Pré-Requisitos |
| ARQ-PRJ003 v2.0 | Seção 8 | Mitigações M-01 a M-05 |
| ARQ-PRJ003 v2.0 | Seção 11 | Plano de Ação Imediato |
| TAP-PRJ008 v2.0 | Seção 4 | Decisões D1, D2, D7 |

---

**FIM DO DOCUMENTO GATE-PRJ008-001 v1.0**

---

**PRÓXIMOS PASSOS:**
1. Imprimir este documento
2. Executar itens conforme ordem recomendada
3. Assinar cada item após conclusão
4. Quando gate estiver 100% verde, solicitar TAP v3.0

**Probabilidade de Sucesso Pós-Gate:** 96-98%

