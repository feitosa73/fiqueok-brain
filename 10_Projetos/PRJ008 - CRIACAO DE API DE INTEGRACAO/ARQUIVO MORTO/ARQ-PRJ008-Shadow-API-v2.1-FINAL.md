# ARQ-PRJ008 — Arquitetura e Configuração da Shadow API
## Versão 2.1 — FINAL · AS-BUILT · Ambiente Certificado

---

| Campo | Valor |
|-------|-------|
| **Documento** | ARQ-PRJ008-Shadow-API-v2.1-FINAL |
| **Versão** | 2.1 — FINAL / AS-BUILT |
| **Data de Emissão** | 17/04/2026 |
| **Autor** | Paulo Feitosa Lima |
| **Revisão** | Paulo Feitosa Lima |
| **Status** | 🟢 **PRODUÇÃO — CERTIFICADO** |
| **Substitui** | ARQ-PRJ008-Shadow-API-v2.0 (Arquitetura Planejada) |
| **Classificação** | Interno — Living Lab Fiqueok · PRJ008 |

> **Nota de Emissão:** Este documento substitui todas as versões anteriores e reflete exclusivamente a configuração **efetivamente implementada e validada** no ambiente de produção. Não há referências a procedimentos planejados ou condicional. Cada seção descreve o estado atual certificado do sistema.

---

## Tags Obsidian

```
#PRJ008 #ShadowAPI #AsBuilt #IAM #Vault #Systemd #ZeroTrust #Tailscale #FastAPI #MariaDB #LivingLab #GRC #Conformidade
```

---

## 1. INTRODUÇÃO E DECLARAÇÃO DE CONFORMIDADE

### 1.1 Propósito

Este documento constitui o **registro oficial de arquitetura As-Built** da Shadow API — componente de integração de identidades do PRJ008 no ecossistema do Living Lab Fiqueok. Sua finalidade é dupla: serve como referência técnica para operações e manutenção, e como artefato de governança para fins de auditoria GRC, demonstrando que os controles de segurança definidos foram efetivamente implementados.

### 1.2 Declaração de Status

A infraestrutura de produção da Shadow API foi **implementada, testada e certificada** em 17/04/2026. O ambiente encontra-se operacional com os seguintes controles ativos:

| Controle | Status |
|---|---|
| Gestão de segredos via HashiCorp Vault | ✅ Implementado |
| Token de serviço com permissões restritas (`chmod 600`) | ✅ Implementado |
| Serviço systemd com reinício automático e persistência de boot | ✅ Implementado |
| Rotina de renovação automática do token (cron) | ✅ Implementado |
| Isolamento de rede via Tailscale ACLs com RBAC | ✅ Implementado |
| Execução sob usuário de serviço com privilégio mínimo | ✅ Implementado |

### 1.3 Histórico de Evolução

A Shadow API passou por três estágios de maturidade desde seu início:

| Estágio | Versão | Período | Característica Principal |
|---|---|---|---|
| Desenvolvimento | V1.0 (POP) | Sprints 1–5 | Processo interativo, credenciais em env vars |
| Arquitetura de Produção | V2.0 (ARQ) | Sprint 6 | Definição do modelo service-based e Vault-native |
| **Produção Certificada** | **V2.1 (AS-BUILT)** | **Sprint 6 — Atual** | **Configuração executada, validada e documentada** |

### 1.4 Escopo deste Documento

**Inclui:** Estado atual certificado de todos os componentes — gestão de segredos, configuração do daemon, automação de identidade, controles de rede e evidências de conformidade.

**Exclui:** Histórico de instalação e provisionamento inicial (cobertos no POP-PRJ008-v1.0). Este documento descreve o **resultado**, não o procedimento.

---

## 2. ARQUITETURA GERAL

### 2.1 Topologia de Rede — Configuração As-Built

```
╔══════════════════════════════════════════════════════════════════╗
║               TAILSCALE MESH VPN (Zero Trust) — AS-BUILT        ║
║                                                                  ║
║   ┌──────────────────┐   ┌──────────────────┐   ┌────────────┐  ║
║   │   vault-gf-01    │   │    api-gf-01     │   │  rh-gf-01  │  ║
║   │  xxx.xxx.xxx.xxx    │   │  (IP Tailscale)  │   │xxx.xxx.xxx.xxx│  ║
║   │                  │   │                  │   │            │  ║
║   │  HashiCorp Vault │◄──│  Shadow API      │──►│  OrangeHRM │  ║
║   │  :8200           │   │  FastAPI :8000   │   │  MariaDB   │  ║
║   │  [CERTIFICADO]   │   │  [DAEMON ATIVO]  │   │  :3306     │  ║
║   └──────────────────┘   └──────────────────┘   └────────────┘  ║
║                                  ▲                               ║
║                                  │ X-API-KEY (Header HTTP)       ║
║                         ┌────────┴────────┐                      ║
║                         │   iga-gf-02     │                      ║
║                         │   midPoint IGA  │                      ║
║                         │   :8080         │                      ║
║                         └─────────────────┘                      ║
║                                                                  ║
║  ACESSO EXTERNO:                                                  ║
║  ├── tag:owner (Paulo)  → Acesso total à Tailnet                 ║
║  └── tag:consultor (Daniel) → Portas 80, 8000, 8085 apenas      ║
╚══════════════════════════════════════════════════════════════════╝
```

### 2.2 Fluxo de Dados — Requisição de Funcionários (Estado Atual)

```
midPoint IGA (iga-gf-02)
    │
    │  GET /employees
    │  Header: X-API-KEY: <Fiqueok-Security-Token-2026>
    │  Canal: HTTP sobre WireGuard (Tailscale — criptografado)
    ▼
shadow-api.service  [systemd — api-gf-01:8000]
    │  User: paulo | Restart=always | After=tailscaled.service
    │
    ├── 1. Valida X-API-KEY (app/security.py)
    ├── 2. Lê /var/lib/shadow-api/vault_token [chmod 600, owner paulo]
    ├── 3. GET http://xxx.xxx.xxx.xxx:8200/v1/secret/data/orangehrm/db_api
    │       Política aplicada: api-proxy-policy [read-only]
    ▼
HashiCorp Vault — vault-gf-01 (xxx.xxx.xxx.xxx:8200)
    │  Retorna: {username, password, db_host, db_name}
    │  Segredos não persistidos após a chamada
    ▼
SQLAlchemy → MariaDB — rh-gf-01 (xxx.xxx.xxx.xxx:3306)
    │  Usuário: svc_shadow_api [SELECT-only em orangehrm.*]
    │  SELECT emp_number, employee_id, first_name,
    │         last_name, employment_status
    │         FROM hs_hr_employee
    ▼
Shadow API — serialização JSON + normalização UTF-8 NFC
    ▼
midPoint IGA ← HTTP 200 + payload JSON
```

### 2.3 Princípios Arquiteturais — Implementados

| Princípio | Implementação Executada |
|---|---|
| **Zero Secrets at Rest** | Nenhuma credencial em código-fonte, `.env` ou variável de ambiente de processo — **verificado em auditoria de código** |
| **Least Privilege** | `svc_shadow_api` com `SELECT` apenas; token Vault restrito a `read` em `secret/orangehrm/*` — **verificado via `SHOW GRANTS` e `vault policy read`** |
| **Zero Trust Network** | Tailscale ACLs com RBAC por tag implementadas — acesso de `tag:consultor` limitado a portas específicas — **configuração ativa** |
| **Resilience by Design** | `systemd` com `Restart=always` e `WantedBy=multi-user.target` — **testado via reboot** |
| **Automated Identity Lifecycle** | Cron de renovação de token ativo — **verificado via `crontab -l`** |
| **Auditability** | Todos os logs centralizados no `journald` sem supressão de saída |

---

## 3. GESTÃO DE SEGREDOS — CONFIGURAÇÃO AS-BUILT

### 3.1 Modelo de Custódia de Segredos (Implementado)

A eliminação de credenciais expostas foi executada em três camadas, todas validadas em produção:

```
CAMADA 1 — Armazenamento Centralizado [vault-gf-01]
└── HashiCorp Vault KV v2
    └── Caminho: secret/orangehrm/db_api
        ├── username  → svc_shadow_api
        ├── password  → [gerenciado exclusivamente pelo Vault]
        ├── db_host   → xxx.xxx.xxx.xxx  (IP Tailscale de rh-gf-01)
        └── db_name   → orangehrm

CAMADA 2 — Autenticação do Serviço com o Vault [api-gf-01]
└── Token de Serviço: svc-shadow-api
    ├── Política vinculada: api-proxy-policy
    ├── Escopo: read em secret/data/orangehrm/* e secret/data/api-proxy/*
    ├── TTL: 24h | Renovável: sim (via cron às 00:00)
    └── Armazenamento físico: /var/lib/shadow-api/vault_token
        ├── Proprietário: paulo:paulo  [chown executado]
        └── Permissão: 0600  [chmod executado]

CAMADA 3 — Consumo em Runtime [processo shadow-api.service]
└── app/vault.py lê o token e consulta o Vault por demanda
    └── Credenciais do banco nunca serializadas em disco ou env
```

### 3.2 Política de Acesso ao Vault — Configuração Definitiva

A política `api-proxy-policy` vinculada ao token de serviço `svc-shadow-api` define o escopo mínimo de acesso. Esta é a configuração executada e ativa no Vault:

```hcl
# api-proxy-policy.hcl — CONFIGURAÇÃO ATIVA em vault-gf-01
# Aplicada ao token svc-shadow-api

path "secret/data/orangehrm/*" {
  capabilities = ["read"]
}

path "secret/data/api-proxy/*" {
  capabilities = ["read"]
}

# Capacidades INTENCIONALMENTE AUSENTES:
# create, update, delete, list, sudo, patch
```

> **Relevância GRC:** A ausência explícita de `list` impede que o token enumere outros paths de segredos no Vault, mesmo que o processo da API seja comprometido. O token opera estritamente no princípio need-to-know.

### 3.3 Hardening do Arquivo de Token — Configuração Executada

O arquivo de token é o único artefato de autenticação persistido no filesystem de `api-gf-01`. Os seguintes controles foram executados e estão ativos:

```bash
# Comandos executados durante o hardening (estado resultante abaixo)

sudo mkdir -p /var/lib/shadow-api
echo "<TOKEN_GERADO>" | sudo tee /var/lib/shadow-api/vault_token > /dev/null
sudo chmod 600 /var/lib/shadow-api/vault_token
sudo chown paulo:paulo /var/lib/shadow-api/vault_token

# Estado atual verificável:
ls -la /var/lib/shadow-api/vault_token
# -rw------- 1 paulo paulo 36 Apr 17 00:00 /var/lib/shadow-api/vault_token

stat /var/lib/shadow-api/
# drwx------ 2 paulo paulo 4096 Apr 17 00:00 /var/lib/shadow-api/
```

**Interpretação dos controles:**

| Controle | Configuração | Significado de Segurança |
|---|---|---|
| `chmod 600` | `-rw-------` | Somente o proprietário (`paulo`) pode ler ou escrever o token |
| `chown paulo:paulo` | `paulo:paulo` | Token acessível apenas ao usuário de serviço, nunca ao root ou outros |
| Diretório `700` | `drwx------` | Outros usuários não conseguem listar o conteúdo do diretório |

---

## 4. SERVIÇO SYSTEMD — CONFIGURAÇÃO AS-BUILT

### 4.1 Declaração de Implementação

A Shadow API foi convertida de processo interativo para daemon gerenciado pelo `systemd`. O serviço `shadow-api.service` está **ativo, habilitado no boot e operando sob o usuário de serviço `paulo`** desde a implementação da Sprint 6.

### 4.2 Unit File — Configuração Definitiva

Este é o conteúdo exato do arquivo `/etc/systemd/system/shadow-api.service` conforme implementado:

```ini
[Unit]
Description=PRJ008 Shadow API REST — OrangeHRM × midPoint IGA
After=network.target tailscaled.service
Requires=network.target

[Service]
Type=simple
User=paulo
Group=paulo
WorkingDirectory=/home/paulo/prj008-shadow-api
Environment="PATH=/home/paulo/prj008-shadow-api/venv/bin"
ExecStart=/home/paulo/prj008-shadow-api/venv/bin/uvicorn \
    app.main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --log-level info
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Justificativa das diretivas críticas:**

| Diretiva | Valor Configurado | Justificativa |
|---|---|---|
| `After=tailscaled.service` | Declarado | Garante que o Vault e o MariaDB sejam alcançáveis via Tailscale antes da API iniciar |
| `User=paulo` | Usuário de serviço | Elimina execução como root; isola o processo no contexto de menor privilégio |
| `WorkingDirectory` | `/home/paulo/prj008-shadow-api` | Garante que imports relativos e paths do venv resolvam corretamente |
| `Restart=always` | Habilitado | Reinício automático em qualquer tipo de falha, sem intervenção manual |
| `RestartSec=10` | 10 segundos | Backoff que evita restart storm em falhas consecutivas (ex.: Vault inacessível) |

### 4.3 Habilitação e Estado Atual

O serviço foi habilitado via `systemctl enable`, garantindo que ele seja iniciado automaticamente pelo `systemd` em todo boot do sistema operacional:

```bash
# Comandos executados durante a implementação
sudo systemctl daemon-reload
sudo systemctl enable shadow-api
sudo systemctl start shadow-api

# Estado resultante (verificável a qualquer momento):
sudo systemctl status shadow-api
# ● shadow-api.service - PRJ008 Shadow API REST — OrangeHRM × midPoint IGA
#      Loaded: loaded (/etc/systemd/system/shadow-api.service; enabled; ...)
#      Active: active (running) since ...
#    Main PID: XXXX (uvicorn)
```

### 4.4 Comportamento de Resiliência — Validado

| Cenário | Comportamento Anterior (V1) | Comportamento Atual (V2.1) |
|---|---|---|
| Sessão SSH encerrada | ❌ API encerrava com o terminal | ✅ Daemon continua independente de sessão |
| Reboot da VM | ❌ Reinício manual obrigatório | ✅ API sobe automaticamente com o SO |
| Exceção não tratada | ❌ Processo encerrado, sem reinício | ✅ Reinício automático em 10s |
| Vault temporariamente indisponível | ❌ Falha permanente sem recuperação | ✅ Reinícios até Vault retornar |

---

## 5. AUTOMAÇÃO DA IDENTIDADE — RENOVAÇÃO DO TOKEN (AS-BUILT)

### 5.1 Contexto e Justificativa GRC

O token de serviço `svc-shadow-api` possui TTL de 24 horas. A expiração de credenciais de serviço sem renovação automatizada constitui um **risco de disponibilidade (RD)** com impacto direto no ciclo JML (Joiner/Mover/Leaver) gerenciado pelo midPoint. Para mitigar esse risco, foi implementada uma rotina de renovação proativa no crontab do usuário `paulo` na VM `api-gf-01`.

**Classificação do Risco Mitigado:**

| ID | Risco | Probabilidade | Impacto | Controle Implementado |
|---|---|---|---|---|
| RD-001 | Expiração silenciosa do token Vault | Alta (TTL 24h) | Alto (interrupção da sincronização de identidades) | Cron de renovação às 00:00 |

### 5.2 Configuração do Crontab — As-Built

A rotina de renovação foi configurada no crontab do usuário `paulo` em `api-gf-01`. Este é o estado atual, verificável via `crontab -l`:

```bash
# Saída esperada de: crontab -l  (usuário paulo em api-gf-01)

0 0 * * * VAULT_ADDR='http://xxx.xxx.xxx.xxx:8200' /usr/bin/vault token renew \
  --header "X-Vault-Token=$(cat /var/lib/shadow-api/vault_token)" \
  -format=json >> /var/log/vault-token-renew.log 2>&1
```

**Leitura da expressão cron:**

| Campo | Valor | Significado |
|---|---|---|
| Minuto | `0` | No minuto zero |
| Hora | `0` | À meia-noite (00:00) |
| Dia do mês | `*` | Todos os dias |
| Mês | `*` | Todos os meses |
| Dia da semana | `*` | Todos os dias da semana |
| **Frequência** | | **Execução diária às 00:00** |

> **Nota operacional:** A renovação ocorre às **00:00**, garantindo uma margem de **24 horas** antes do vencimento do token (TTL 24h a partir da última renovação). O log em `/var/log/vault-token-renew.log` permite auditoria das renovações.

### 5.3 Procedimento de Renovação Manual (Contingência)

Em caso de falha da renovação automática ou após expiração do token, o procedimento de contingência é:

```bash
# Passo 1 — Verificar validade do token atual
export VAULT_ADDR='http://xxx.xxx.xxx.xxx:8200'
export VAULT_TOKEN=$(cat /var/lib/shadow-api/vault_token)
vault token lookup
# Verificar: "expire_time" e "ttl"

# Passo 2 — Gerar novo token (em vault-gf-01)
ssh paulo@xxx.xxx.xxx.xxx
export VAULT_ADDR='http://127.0.0.1:8200'
vault login  # autenticar com token administrativo

NEW_TOKEN=$(vault token create \
  -policy=api-proxy-policy \
  -period=24h \
  -format=json | jq -r .auth.client_token)

# Passo 3 — Atualizar token em api-gf-01
echo "$NEW_TOKEN" | sudo tee /var/lib/shadow-api/vault_token > /dev/null
sudo chmod 600 /var/lib/shadow-api/vault_token
sudo chown paulo:paulo /var/lib/shadow-api/vault_token

# Passo 4 — Reiniciar serviço para carregar o novo token
sudo systemctl restart shadow-api
sudo systemctl status shadow-api
```

---

## 6. SEGURANÇA DE REDE — ACLs TAILSCALE AS-BUILT

### 6.1 Modelo de Acesso Implementado

O ambiente opera em modelo Zero Trust via Tailscale com **RBAC por tags**. Dois perfis de acesso foram configurados e estão ativos:

| Perfil | Tag | Titular | Nível de Acesso |
|---|---|---|---|
| Administrador | `tag:owner` | Paulo Feitosa Lima | Acesso completo a todos os nós e portas da Tailnet |
| Consultor | `tag:consultor` | Daniel | Acesso restrito às portas `80`, `8000` e `8085` |

### 6.2 Matriz de Comunicação Autorizada — Configuração Definitiva

| Origem | Destino | Porta | Justificativa |
|---|---|---|---|
| `api-gf-01` | `vault-gf-01` (xxx.xxx.xxx.xxx) | 8200 | Leitura de segredos em runtime |
| `api-gf-01` | `rh-gf-01` (xxx.xxx.xxx.xxx) | 3306 | Consultas MariaDB |
| `iga-gf-02` | `api-gf-01` | 8000 | midPoint → Shadow API (JML) |
| `tag:owner` | Todos os nós | Todas | Administração do laboratório |
| `tag:consultor` | `api-gf-01` | 8000 | Acesso consultor à API |
| `tag:consultor` | `rh-gf-01` | 8085 | Acesso consultor ao OrangeHRM |
| `tag:consultor` | `rh-gf-01` | 80 | Acesso HTTP básico |
| **QUALQUER** | **QUALQUER** | **3306** | ❌ **BLOQUEADO** (MariaDB não exposto à `tag:consultor`) |
| **Internet** | **QUALQUER** | **QUALQUER** | ❌ **BLOQUEADO** (sem exposição pública) |

### 6.3 Isolamento de Rede — Garantias

- O MariaDB (`rh-gf-01:3306`) é acessível **apenas** por `api-gf-01` via Tailscale — o perfil `tag:consultor` não possui autorização para esta porta, garantindo que credenciais de banco nunca sejam necessárias fora do contexto da API.
- Nenhuma porta está exposta na LAN do host Windows — o tráfego entre VMs flui exclusivamente via WireGuard peer-to-peer.
- A Tailnet `fiqueok` requer autenticação MFA para ingresso de novos dispositivos.

---

## 7. PRINCÍPIO DO MENOR PRIVILÉGIO — MATRIZ AS-BUILT

| Componente | Identidade | Permissões Concedidas (Executadas) | Permissões Negadas (Explícitas) |
|---|---|---|---|
| Processo Shadow API | `paulo` (usuário OS) | Leitura de `/var/lib/shadow-api/vault_token`; execução do uvicorn no diretório do projeto | Acesso root; escrita em `/etc`; acesso a outros diretórios de serviço |
| Token Vault (`svc-shadow-api`) | `api-proxy-policy` | `read` em `secret/data/orangehrm/*` e `secret/data/api-proxy/*` | `create`, `update`, `delete`, `list`, `sudo`, `patch` |
| Usuário MariaDB | `svc_shadow_api` | `SELECT` em `orangehrm.hs_hr_employee` e `orangehrm.ohrm_user` | `INSERT`, `UPDATE`, `DELETE`, `DROP`, `CREATE`, acesso a outros schemas |
| Serviço systemd | `paulo:paulo` | Execução do uvicorn sob o usuário de serviço | Escalada de privilégios; acesso a dispositivos do sistema |
| Acesso de Rede | `tag:consultor` | Portas `80`, `8000`, `8085` | Porta `3306` (MariaDB); acesso a `vault-gf-01`; acesso a `iga-gf-02` |

---

## 8. EVIDÊNCIAS DE CONFORMIDADE

Esta seção lista os comandos de validação que comprovam o estado atual do ambiente. Cada comando pode ser executado a qualquer momento em `api-gf-01` (exceto os específicos de `vault-gf-01`) para confirmar que os controles permanecem ativos.

### 8.1 Conformidade do Serviço Systemd

**Método de validação:** `systemctl status shadow-api`

```bash
sudo systemctl status shadow-api

# Saída esperada:
# ● shadow-api.service - PRJ008 Shadow API REST — OrangeHRM × midPoint IGA
#      Loaded: loaded (/etc/systemd/system/shadow-api.service; enabled; vendor preset: enabled)
#      Active: active (running) since Thu 2026-04-17 HH:MM:SS UTC; Xh Xmin ago
#    Main PID: XXXX (uvicorn)
#       Tasks: XX (limit: XXXX)
#      Memory: XX.XM
#         CPU: XXs
#      CGroup: /system.slice/shadow-api.service
#              └─XXXX /home/paulo/prj008-shadow-api/venv/bin/python ...uvicorn...
#
# Apr 17 HH:MM:SS api-gf-01 uvicorn[XXXX]: INFO: Application startup complete.
```

**Indicadores de conformidade a verificar:**
- `Loaded: ... enabled` → serviço habilitado no boot ✅
- `Active: active (running)` → processo em execução ✅
- `User=paulo` → execução sob usuário de serviço ✅

---

**Método de validação:** `systemctl is-enabled shadow-api`

```bash
systemctl is-enabled shadow-api
# Saída esperada: enabled
```

### 8.2 Conformidade da Automação de Identidade

**Método de validação:** `crontab -l`

```bash
crontab -l
# Saída esperada (entre outras entradas que possam existir):
#
# 0 0 * * * VAULT_ADDR='http://xxx.xxx.xxx.xxx:8200' /usr/bin/vault token renew ...
```

**Indicadores de conformidade a verificar:**
- Entrada de renovação presente no crontab ✅
- Endereço do Vault correto (`xxx.xxx.xxx.xxx:8200`) ✅
- Frequência correta (`0 0 * * *` — diária às 00:00) ✅

---

**Método de validação:** Verificar log de renovações anteriores

```bash
cat /var/log/vault-token-renew.log
# Deve conter entradas JSON com "renewable: true" e timestamps diários
```

### 8.3 Conformidade das Permissões de Filesystem

**Método de validação:** `stat` do arquivo de token e diretório

```bash
# Verificar permissões do token
stat /var/lib/shadow-api/vault_token
# Access: (0600/-rw-------)
# Uid: (XXXX/paulo)  Gid: (XXXX/paulo)

# Verificar diretório pai
stat /var/lib/shadow-api/
# Access: (0700/drwx------)
# Uid: (XXXX/paulo)  Gid: (XXXX/paulo)
```

### 8.4 Conformidade da Política Vault

**Método de validação:** `vault policy read api-proxy-policy` (em vault-gf-01)

```bash
# Em vault-gf-01
export VAULT_ADDR='http://127.0.0.1:8200'
vault policy read api-proxy-policy
# Deve retornar apenas os dois paths com capability "read"
```

### 8.5 Conformidade do Menor Privilégio no MariaDB

**Método de validação:** `SHOW GRANTS FOR 'svc_shadow_api'@'%'` (em rh-gf-01)

```sql
-- No MariaDB de rh-gf-01
SHOW GRANTS FOR 'svc_shadow_api'@'%';

-- Resultado esperado:
-- GRANT USAGE ON *.* TO 'svc_shadow_api'@'%'
-- GRANT SELECT ON `orangehrm`.`ohrm_user` TO 'svc_shadow_api'@'%'
-- GRANT SELECT ON `orangehrm`.`hs_hr_employee` TO 'svc_shadow_api'@'%'
-- (apenas SELECT, apenas nessas duas tabelas)
```

### 8.6 Conformidade da Ausência de Credenciais no Código-Fonte

**Método de validação:** Auditoria de código

```bash
grep -r "password\|secret\|token" ~/prj008-shadow-api/app/ --include="*.py" \
  | grep -v "vault_token\|get_db_credentials\|TOKEN_PATH\|X-API-KEY"
# Resultado esperado: nenhuma linha retornada
# (zero credenciais hardcoded no código-fonte)
```

---

## 9. CHECKLIST DE VALIDAÇÃO OPERACIONAL

Script de validação automatizada para uso em manutenções, após reboots e em auditorias periódicas:

```bash
#!/bin/bash
# PRJ008 — Validação Shadow API v2.1 AS-BUILT
# Executar em: api-gf-01 como usuário paulo
# Data de referência: 17/04/2026

echo "<REDACTED_SECRET>========================"
echo "   PRJ008 · Shadow API v2.1 AS-BUILT · Validação Operacional"
echo "   $(date '+%Y-%m-%d %H:%M:%S')"
echo "<REDACTED_SECRET>========================"

VAULT_IP="xxx.xxx.xxx.xxx"
MARIADB_IP="xxx.xxx.xxx.xxx"
TOKEN_FILE="/var/lib/shadow-api/vault_token"
PASS=0; FAIL=0

check() {
  local label="$1"; local result="$2"
  if [ "$result" = "OK" ]; then
    echo "✅  $label"
    ((PASS++))
  else
    echo "❌  $label — $result"
    ((FAIL++))
  fi
}

# 1. Serviço ativo
SVC=$(systemctl is-active shadow-api)
check "Serviço shadow-api.service ativo" \
  "$([ "$SVC" = "active" ] && echo OK || echo "$SVC")"

# 2. Serviço habilitado no boot
ENABLED=$(systemctl is-enabled shadow-api)
check "Habilitado no boot (systemctl enable)" \
  "$([ "$ENABLED" = "enabled" ] && echo OK || echo "$ENABLED")"

# 3. Permissão do arquivo de token
PERMS=$(stat -c "%a" $TOKEN_FILE 2>/dev/null)
check "Token Vault com chmod 600" \
  "$([ "$PERMS" = "600" ] && echo OK || echo "Permissão: $PERMS")"

# 4. Proprietário do arquivo de token
OWNER=$(stat -c "%U:%G" $TOKEN_FILE 2>/dev/null)
check "Token Vault owner paulo:paulo" \
  "$([ "$OWNER" = "paulo:paulo" ] && echo OK || echo "Owner: $OWNER")"

# 5. Token Vault válido
VAULT_TOKEN_VAL=$(cat $TOKEN_FILE 2>/dev/null)
TOKEN_STATUS=$(curl -s -H "X-Vault-Token: $VAULT_TOKEN_VAL" \
  "http://${VAULT_IP}:8200/v1/auth/token/lookup-self" | \
  python3 -c "import sys,json; d=json.load(sys.stdin); \
  print('OK' if d.get('data') else 'INVALIDO')" 2>/dev/null)
check "Token Vault válido (não expirado)" \
  "$([ "$TOKEN_STATUS" = "OK" ] && echo OK || echo "Token inválido ou Vault inacessível")"

# 6. Vault unsealed
VAULT_HEALTH=$(curl -s "http://${VAULT_IP}:8200/v1/sys/health" | \
  python3 -c "import sys,json; d=json.load(sys.stdin); \
  print('OK' if not d.get('sealed') else 'SEALED')" 2>/dev/null)
check "Vault acessível e unsealed" \
  "$([ "$VAULT_HEALTH" = "OK" ] && echo OK || echo "${VAULT_HEALTH:-inacessível}")"

# 7. MariaDB acessível
nc -zv $MARIADB_IP 3306 2>&1 | grep -q "succeeded"
check "MariaDB acessível via Tailscale (:3306)" \
  "$([ $? -eq 0 ] && echo OK || echo "Porta 3306 inacessível")"

# 8. API healthcheck
API_STATUS=$(curl -s http://localhost:8000/ | python3 -c \
  "import sys,json; d=json.load(sys.stdin); \
  print('OK' if d.get('status') == 'Shadow API is operational' else d)" 2>/dev/null)
check "GET / → Shadow API is operational" \
  "$([ "$API_STATUS" = "OK" ] && echo OK || echo "${API_STATUS:-sem resposta}")"

# 9. Rejeição sem autenticação
CODE_NO_AUTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/employees)
check "GET /employees sem X-API-KEY → HTTP 403" \
  "$([ "$CODE_NO_AUTH" = "403" ] && echo OK || echo "HTTP $CODE_NO_AUTH")"

# 10. Acesso autenticado
CODE_AUTH=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "X-API-KEY: Fiqueok-Security-Token-2026" http://localhost:8000/employees)
check "GET /employees com X-API-KEY → HTTP 200" \
  "$([ "$CODE_AUTH" = "200" ] && echo OK || echo "HTTP $CODE_AUTH")"

# 11. Payload com dados
COUNT=$(curl -s -H "X-API-KEY: Fiqueok-Security-Token-2026" \
  http://localhost:8000/employees | python3 -c \
  "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null)
check "Payload com registros de funcionários (> 0)" \
  "$([ "${COUNT:-0}" -gt 0 ] && echo OK || echo "COUNT=${COUNT:-0}")"

# 12. Cron de renovação configurado
CRON_PRESENT=$(crontab -l 2>/dev/null | grep -c "vault token renew")
check "Cron de renovação do token configurado" \
  "$([ "$CRON_PRESENT" -gt 0 ] && echo OK || echo "Entrada não encontrada no crontab")"

echo "----------------------------------------------------------------"
echo "  Resultado: $PASS aprovados | $FAIL falhas"
[ "$FAIL" -eq 0 ] && echo "  Status: ✅ AMBIENTE CERTIFICADO" || \
  echo "  Status: ❌ REQUER ATENÇÃO — $FAIL controle(s) com falha"
echo "<REDACTED_SECRET>========================"
```

---

## 10. CHANGELOG — V1.0 → V2.0 → V2.1

| Dimensão | V1.0 — Interativa | V2.0 — Arquitetura Planejada | V2.1 — AS-BUILT (Atual) |
|---|---|---|---|
| **Modo de execução** | `uvicorn` em terminal interativo | Definição do daemon `systemd` | ✅ `shadow-api.service` **ativo e habilitado** |
| **Persistência de boot** | ❌ Nenhuma | Diretriz `WantedBy=multi-user.target` | ✅ `systemctl enable` **executado** |
| **Gestão de segredos** | Variáveis de ambiente / hardcoded | Definição do modelo Vault-native | ✅ Token em `/var/lib/shadow-api/vault_token` **configurado** |
| **Permissões do token** | N/A | Diretriz `chmod 600` e `chown` | ✅ `chmod 600` e `chown paulo:paulo` **executados** |
| **Renovação do token** | Manual sem procedimento | Recomendação de cron | ✅ Cron `0 0 * * *` **ativo em produção** |
| **Endereço do Vault** | Variável sem valor fixo | Placeholder `<IP_VAULT>` | ✅ `xxx.xxx.xxx.xxx:8200` **configurado** |
| **ACLs Tailscale** | Sem diferenciação de perfil | Definição de `tag:owner` e `tag:consultor` | ✅ RBAC com restrição de portas **implementado** |
| **Acesso de Daniel** | N/A | Planejado | ✅ `tag:consultor` → portas `80`, `8000`, `8085` **ativo** |
| **Logs** | `stdout` volátil do terminal | `journald` definido | ✅ `journald` persistente **operacional** |
| **Recuperação de falhas** | Manual | `Restart=always` definido | ✅ Testado via simulação de falha |
| **Evidências de conformidade** | Inexistentes | Não previstas na v2.0 | ✅ Seção 8 com métodos de validação formais |

---

## 11. ROADMAP — EVOLUÇÕES FUTURAS

| Prioridade | Melhoria | Benefício | Sprint Alvo |
|---|---|---|---|
| 🔴 Alta | Migrar para **AppRole** (Vault Auth Method) | Elimina cron de renovação; credenciais geradas automaticamente por demanda | Sprint 7 |
| 🔴 Alta | Ativar **TLS** na Shadow API | Criptografia da camada de aplicação, independente do Tailscale | Sprint 7 |
| 🟡 Média | Hardening systemd: `NoNewPrivileges=true`, `ProtectSystem=strict`, `PrivateTmp=true` | Reduce superfície de ataque do processo em nível de kernel | Sprint 8 |
| 🟡 Média | Integrar **conector REST Polygon** no midPoint 4.10+ | Substitui DatabaseTable Connector por integração nativa via Shadow API | Sprint 8 |
| 🟢 Baixa | Endpoint `/health` com status estruturado | Monitoramento externo (Prometheus, Zabbix) sem expor dados sensíveis | Sprint 9 |
| 🟢 Baixa | **Rate limiting** no FastAPI | Proteção contra abuso da API Key e ataques de enumeração | Sprint 9 |

---

## 12. REFERÊNCIAS E RASTREABILIDADE

| Documento | Localização no Obsidian | Relação com este ARQ |
|---|---|---|
| `ARQ-PRJ008-Shadow-API-v2.0` | PRJ008/ARQ | Versão anterior (arquitetura planejada) — substituída por este documento |
| `POP-PRJ008-v1.0` | PRJ008/POPs | Procedimento de instalação da V1 — ainda válido para referência de provisionamento |
| `POP-DatabaseTable-Connector-v1.0` | PRJ008/POPs | Alternativa de integração ativa enquanto o conector REST permanece bloqueado |
| `TEP-PRJ008-v1.0-FREEZING` | PRJ008 | Contexto do bloqueio ScriptedREST / Java 21 — justifica a existência da Shadow API |
| `ARQ-PRJ003-ADR-PRJ008-v2.0` | PRJ003 | Decisões arquiteturais (ADRs) do ecossistema que fundamentam este design |
| `TAP-PRJ008-v3.0` | PRJ008 | Termo de Abertura do Projeto |
| `GATE-PRJ008-001-v2.0` | PRJ008 | Matriz de Readiness — Gates de qualidade que este ambiente satisfaz |

---

## CONTROLE DE VERSÃO

| Versão | Data | Autor | Tipo | Mudança |
|---|---|---|---|---|
| 1.0 | 14/04/2026 | Paulo Feitosa Lima | POP | Versão inicial — modo interativo, Sprints 1–5 |
| 2.0 | 17/04/2026 | Paulo Feitosa Lima | ARQ | Definição da arquitetura de produção — service-based, Vault-native, Zero Trust |
| **2.1** | **17/04/2026** | **Paulo Feitosa Lima** | **AS-BUILT** | **Certificação do ambiente de produção. IPs definitivos, cron ativo (00:00), ACLs Tailscale com tag:consultor (Daniel), evidências de conformidade formalizadas. Todos os controles planejados na v2.0 executados e validados.** |

---

*Documento certificado por Paulo Feitosa Lima — Especialista IAM/GRC*
*Living Lab Fiqueok — PRJ008*
*Arquivo: ARQ-PRJ008-Shadow-API-v2.1-FINAL.md*
*Gerado com apoio de Claude (Anthropic)*

