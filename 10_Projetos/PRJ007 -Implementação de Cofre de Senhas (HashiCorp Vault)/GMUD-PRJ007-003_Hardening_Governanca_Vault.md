# GMUD-PRJ007-003 — Hardening e Governança de Identidade
## HashiCorp Vault — Living Lab Fiqueok

---

| Campo | Valor |
|-------|-------|
| **Código** | GMUD-PRJ007-003 |
| **Projeto de origem** | PRJ007 — HashiCorp Vault (Fase 2) |
| **Tipo de mudança** | Normal — Hardening de segurança e conformidade |
| **Classificação de risco** | Médio — restart do serviço Vault necessário para aplicar `vault.hcl` |
| **Data de elaboração** | 18 de Abril de 2026 |
| **Responsável técnico** | Paulo — Arquiteto de Segurança e Redes |
| **Ambiente** | Produção Living Lab — VM `VAULT-GEN1` (Hyper-V GEN1) |
| **Status** | Aprovada para execução |
| **Projetos impactados** | PRJ016 – Sentinel Identity Shield (DEP-001, DEP-002, DEP-003) |
| **Janela de execução** | A definir — estimativa: 30 minutos |

---

## Histórico de Versões

| Versão | Data | Autor | Descrição |
|--------|------|-------|-----------|
| 1.0 | 18/04/2026 | Paulo | Criação — formalização retroativa e ações prospectivas |

---

## Sumário

1. [Contexto e Justificativa](#1-contexto-e-justificativa)
2. [Estado Atual (AS-IS)](#2-estado-atual-as-is)
3. [Estado Desejado (TO-BE)](#3-estado-desejado-to-be)
4. [Escopo da Mudança](#4-escopo-da-mudança)
5. [Plano de Execução](#5-plano-de-execução)
6. [Plano de Rollback](#6-plano-de-rollback)
7. [Critérios de Validação](#7-critérios-de-validação)
8. [Itens de Observação](#8-itens-de-observação)
9. [Pendências Futuras Registradas](#9-pendências-futuras-registradas)
10. [Fora do Escopo](#10-fora-do-escopo)
11. [Rastreabilidade com PRJ016](#11-rastreabilidade-com-prj016)
12. [Registro de Execução](#12-registro-de-execução)

---

## 1. Contexto e Justificativa

### 1.1 Contexto

O PRJ007 implementou o HashiCorp Vault em duas fases:

- **Fase 1** (03–09/02/2026): deploy via WSL2, storage Raft, Tailscale mesh
- **Fase 2** (10/02/2026): migração WSL2 → VM `VAULT-GEN1` (Hyper-V GEN1) por falha estrutural do WSL2 documentada no ADD-PRJ007-FASE2

Entre 12/02/2026 e 18/04/2026 (64 dias), uma série de evoluções foi implementada sem GMUD registrada. Esta GMUD tem dupla função: **formalizar retroativamente** as mudanças realizadas nesse período e **documentar prospectivamente** as ações corretivas exigidas pelo PRJ016 – Sentinel Identity Shield.

### 1.2 Evidências do estado atual (coletadas em 18/04/2026)

| Item         | Evidência coletada                                                               |
| ------------ | -------------------------------------------------------------------------------- |
| Runtime      | `systemctl status vault` → `active (running)` desde 2026-04-11 14:28:37 UTC      |
| Versão       | `vault version` → `1.21.3`                                                       |
| Storage      | `vault status` → `Storage Type: raft`, `node_id: fiqueok-gen1-node`              |
| Binário      | `/usr/bin/vault server -config=/etc/vault.d/vault.hcl`                           |
| Disco        | `df -h` → 9.8 GB total, 5.7 GB usado, **61% de uso**                             |
| Audit log    | `/opt/vault/logs/vault_audit.log` → **1.7 MB**, sem logrotate configurado        |
| Logrotate    | `ls /etc/logrotate.d/` → **nenhuma entrada para vault**                          |
| Cloudflare   | `cloudflared.service` → `active (running)` desde 2026-04-18 15:54:46 UTC (hoje)  |
| IP Tailscale | `xxx.xxx.xxx.xxx`                                                                   |
| Hostname     | `vault-gf-01` (diverge do nome Hyper-V `VAULT-GEN1`)                             |
| Usuários     | `daniel`, `paulo`, `rose` no método `userpass`                                   |
| Políticas    | `admin-policy`, `reader-policy`, `api-proxy-policy`, `policy-colaborador-prj009` |

### 1.3 Justificativa das ações prospectivas

O Vault está configurado em modo **Fail-Closed**: se o arquivo de auditoria não puder ser gravado por falta de espaço em disco, o serviço encerra automaticamente para impedir operações sem rastro. Com 3.7 GB livres e o `vault_audit.log` crescendo sem rotação, o risco de indisponibilidade por disco cheio é real e sem mitigação atual. Adicionalmente, o PRJ016 requer três configurações no Vault para que seus controles de monitoramento funcionem corretamente (DEP-001, DEP-002, DEP-003).

---

## 2. Estado Atual (AS-IS)

```
VM: VAULT-GEN1 (Hyper-V GEN1)
├── Hostname: vault-gf-01
├── OS: Ubuntu (verificado via systemd-detect-virt)
├── Vault: 1.21.3 — systemd nativo (/usr/bin/vault)
├── Storage: Raft Integrated (/opt/vault/data, node: fiqueok-gen1-node)
├── Listener: 0.0.0.0:8200, tls_disable=true
├── api_addr: http://xxx.xxx.xxx.xxx:8200
├── Autenticação: token/ + userpass/ (paulo, rose, daniel)
├── Políticas: admin-policy, reader-policy, api-proxy-policy,
│             policy-colaborador-prj009 (origem não rastreada)
├── Audit: file → /opt/vault/logs/vault_audit.log (1.7 MB, Fail-Closed)
│         SEM logrotate configurado ← RISCO CRÍTICO
├── Cloudflare: tunnel-vault HEALTHY (implementado hoje 18/04/2026)
│              vault.fiqueok.com.br — 1 política, Self-Hosted
├── Tailscale: xxx.xxx.xxx.xxx, ativo
│
├── AUSENTE: bloco X-Forwarded-For no vault.hcl
│            (todos os acessos via Cloudflare aparecem como 127.0.0.1)
├── AUSENTE: bloco telemetry no vault.hcl
│            (endpoint /v1/sys/metrics retorna HTTP 403)
├── AUSENTE: token prometheus-scraper
└── AVISO: "skipping new raft TLS config creation, keys are pending"
           (repetindo a cada ~5 minutos nos logs do systemd)
```

---

## 3. Estado Desejado (TO-BE)

```
VM: VAULT-GEN1 (Hyper-V GEN1)
├── [IGUAL] Vault 1.21.3 — systemd nativo
├── [IGUAL] Storage: Raft Integrated
│
├── [NOVO] vault.hcl atualizado com:
│   ├── bloco X-Forwarded-For no listener
│   └── bloco telemetry
│
├── [NOVO] logrotate configurado:
│   └── /etc/logrotate.d/vault
│       retenção 7 dias · gzip · copytruncate · root:vault 640
│
├── [NOVO] token prometheus-scraper:
│   ├── policy-metrics → path "/sys/metrics" read
│   ├── TTL 8760h (1 ano)
│   └── token salvo em /var/lib/prometheus/vault_token
│
├── [FORMALIZADO] Cloudflare ZT + OTP em vault.fiqueok.com.br
├── [FORMALIZADO] Usuários nominais paulo/rose/daniel com RBAC
└── [FORMALIZADO] Audit Device Fail-Closed ativo
```

---

## 4. Escopo da Mudança

### 4.1 Ações retroativas — formalização

Estas mudanças já estão implementadas. Esta GMUD as registra formalmente para rastreabilidade.

| ID | Mudança | Data de implementação | Evidência |
|----|---------|----------------------|-----------|
| RET-01 | Cloudflare ZT + OTP em `vault.fiqueok.com.br` | 18/04/2026 | Dashboard CF: App criada 12:59:10 PM |
| RET-02 | Criação dos usuários `paulo`, `rose`, `daniel` no `userpass` | Não documentada (entre 12/02 e 18/04/2026) | `vault list auth/userpass/users` |
| RET-03 | Políticas `admin-policy`, `reader-policy`, `api-proxy-policy` | Não documentada | `vault policy list` |
| RET-04 | Ativação do Audit Device Fail-Closed em `/opt/vault/logs/` | Não documentada | `vault audit list -detailed` |

### 4.2 Ações prospectivas — a executar

| ID | Ação | Impacto | Restart necessário |
|----|------|---------|--------------------|
| PRO-01 | Configurar logrotate para `vault_audit.log` | Mitiga risco de disco cheio e Fail-Closed | Não |
| PRO-02 | Adicionar `X-Forwarded-For` no `vault.hcl` | Habilita IP real nos logs de auditoria | **Sim** |
| PRO-03 | Adicionar bloco `telemetry` no `vault.hcl` | Habilita endpoint `/v1/sys/metrics` | **Sim** |
| PRO-04 | Criar `policy-metrics` e token `prometheus-scraper` | Permite scrape pelo Prometheus do PRJ016 | Não |

> **Nota de janela de manutenção:** PRO-02 e PRO-03 requerem restart do `vault.service`.
> O Vault voltará em modo **sealed** após o restart — o procedimento de unseal
> (3 de 5 chaves Shamir) deve ser executado imediatamente na sequência.
> Tempo estimado de indisponibilidade: **2–3 minutos**.

---

## 5. Plano de Execução

### Pré-requisitos

```bash
# 1. Criar snapshot Hyper-V ANTES de iniciar (no host Windows, PowerShell Admin)
Checkpoint-VM -Name "VAULT-GEN1" -SnapshotName "PRE-GMUD-PRJ007-003-$(Get-Date -Format 'yyyyMMdd-HHmm')"
Get-VMSnapshot -VMName "VAULT-GEN1" | Select-Object Name, CreationTime

# 2. Confirmar que as unseal keys estão acessíveis (não executar, apenas verificar)
# Localização: KeePass / SECRETS.md (fora do Git)
# Threshold: 3 de 5 chaves necessárias

# 3. Autenticar no Vault com usuário admin
export VAULT_ADDR='http://xxx.xxx.xxx.xxx:8200'
vault login -method=userpass username=paulo
```

---

### Passo 1 — PRO-01: Configurar logrotate (sem restart)

```bash
# Criar arquivo de configuração do logrotate
sudo tee /etc/logrotate.d/vault > /dev/null <<'EOF'
/opt/vault/logs/vault_audit.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
    create 640 vault vault
    postrotate
        /bin/kill -HUP $(cat /var/run/vault.pid 2>/dev/null) 2>/dev/null || true
    endscript
}
EOF

# Verificar sintaxe
sudo logrotate -d /etc/logrotate.d/vault

# Testar execução manual (sem rotacionar de fato)
sudo logrotate --debug /etc/logrotate.d/vault

# Confirmar que o arquivo foi criado corretamente
cat /etc/logrotate.d/vault
ls -lh /opt/vault/logs/
```

**Resultado esperado:** `logrotate -d` sem erros, arquivo de configuração presente.

---

### Passo 2 — PRO-02 e PRO-03: Atualizar vault.hcl (requer restart)

```bash
# Fazer backup do vault.hcl atual ANTES de editar
sudo cp /etc/vault.d/vault.hcl /etc/vault.d/vault.hcl.bkp-$(date +%Y%m%d-%H%M)

# Editar o vault.hcl
sudo nano /etc/vault.d/vault.hcl
```

O `vault.hcl` após a edição deve conter exatamente:

```hcl
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "fiqueok-gen1-node"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"

  # DEP-002 PRJ016: capturar IP real do cliente via túnel Cloudflare
  x_forwarded_for_authorized_addrs     = "127.0.0.1/8"
  x_forwarded_for_hop_skips            = 0
  x_forwarded_for_reject_not_authorized = false
}

api_addr     = "http://xxx.xxx.xxx.xxx:8200"
cluster_addr = "https://127.0.0.1:8201"

ui           = true
disable_mlock = true
log_level    = "info"
log_format   = "json"

# DEP-003 PRJ016: habilitar endpoint de métricas para Prometheus
telemetry {
  prometheus_retention_time = "30s"
  disable_hostname          = true
}
```

```bash
# Verificar sintaxe antes de reiniciar
sudo vault server -config=/etc/vault.d/vault.hcl -dev-listen-address="127.0.0.1:18200" &
TEST_PID=$!
sleep 3
kill $TEST_PID 2>/dev/null
# Se não houver erro de parse, prosseguir

# Reiniciar o serviço
sudo systemctl restart vault

# Verificar que voltou running (aguardar ~10 segundos)
sleep 10
sudo systemctl status vault | head -5
```

**IMEDIATAMENTE após o restart — Unseal obrigatório:**

```bash
export VAULT_ADDR='http://127.0.0.1:8200'

# Verificar status (deve mostrar Sealed: true)
vault status

# Aplicar 3 das 5 unseal keys (executar 3 vezes com chaves diferentes)
vault operator unseal   # chave 1
vault operator unseal   # chave 2
vault operator unseal   # chave 3

# Confirmar operacional
vault status
# Esperado: Sealed: false, HA Mode: active
```

---

### Passo 3 — PRO-04: Criar policy-metrics e token prometheus-scraper (sem restart)

```bash
# Reautenticar após o restart
export VAULT_ADDR='http://xxx.xxx.xxx.xxx:8200'
vault login -method=userpass username=paulo

# Criar política restrita para métricas
vault policy write policy-metrics - <<'EOF'
# Permite apenas leitura do endpoint de métricas (DEP-003 PRJ016)
path "/sys/metrics" {
  capabilities = ["read"]
}
EOF

# Verificar política criada
vault policy read policy-metrics

# Criar token dedicado para o Prometheus
# NÃO usar o token root nem o token admin para scraping
vault token create \
  -policy=policy-metrics \
  -ttl=8760h \
  -renewable=true \
  -display-name="prometheus-scraper-prj016" \
  -format=json | jq -r '.auth.client_token' \
  | sudo tee /var/lib/prometheus/vault_token

# Proteger o arquivo do token
sudo chmod 600 /var/lib/prometheus/vault_token
sudo chown root:root /var/lib/prometheus/vault_token

# Criar diretório caso não exista
sudo mkdir -p /var/lib/prometheus

# Verificar que o token funciona
PROM_TOKEN=$(sudo cat /var/lib/prometheus/vault_token)
curl -s -H "X-Vault-Token: $PROM_TOKEN" \
     http://127.0.0.1:8200/v1/sys/metrics?format=prometheus | head -5
# Esperado: linhas iniciando com "# HELP vault_..."
```

---

### Passo 4 — Investigar policy-colaborador-prj009

```bash
# Ler conteúdo da política antes de qualquer decisão
vault policy read policy-colaborador-prj009

# Verificar se algum token ativo usa essa política
vault list auth/token/accessors 2>/dev/null | while read accessor; do
  INFO=$(vault token lookup -accessor "$accessor" -format=json 2>/dev/null)
  POLICIES=$(echo "$INFO" | jq -r '.data.policies[]' 2>/dev/null)
  if echo "$POLICIES" | grep -q "policy-colaborador-prj009"; then
    echo "Token com essa política:"
    echo "$INFO" | jq '{display_name: .data.display_name, ttl: .data.ttl, policies: .data.policies}'
  fi
done

# DECISÃO a registrar no campo 12 (Registro de Execução):
# [ ] Política em uso — documentar propósito e manter
# [ ] Política sem uso — remover com: vault policy delete policy-colaborador-prj009
```

---

## 6. Plano de Rollback

| Cenário | Procedimento |
|---------|--------------|
| `vault.hcl` com erro de sintaxe impede restart | `sudo cp /etc/vault.d/vault.hcl.bkp-* /etc/vault.d/vault.hcl && sudo systemctl restart vault` |
| Vault não unseala após restart | Verificar `vault status`; aplicar as 3 unseal keys; se falhar, restaurar snapshot Hyper-V |
| Restaurar snapshot Hyper-V (último recurso) | `Stop-VM "VAULT-GEN1" -Force; Restore-VMSnapshot -VMName "VAULT-GEN1" -Name "PRE-GMUD-PRJ007-003-*"; Start-VM "VAULT-GEN1"` |
| logrotate com erro de configuração | `sudo rm /etc/logrotate.d/vault` — sem impacto no Vault em si |
| Token prometheus-scraper criado com TTL errado | `vault token revoke <token>` e recriar com parâmetros corretos |

**Nota:** O snapshot criado no pré-requisito é o ponto de restauração garantido. O rollback completo restaura o ambiente ao estado de antes da GMUD em ~5 minutos.

---

## 7. Critérios de Validação

Execute após a conclusão de todos os passos:

```bash
# V1: logrotate configurado e sem erros
sudo logrotate -d /etc/logrotate.d/vault
# Esperado: saída sem "error"

# V2: Vault operacional após restart
vault status | grep -E "Sealed|HA Mode|Version"
# Esperado: Sealed: false | HA Mode: active | Version: 1.21.3

# V3: X-Forwarded-For ativo
# Fazer login via vault.fiqueok.com.br e verificar o log de auditoria
tail -5 /opt/vault/logs/vault_audit.log | jq '.request.remote_address'
# Esperado: IP real do cliente, não "127.0.0.1"

# V4: Endpoint de métricas acessível com token prometheus
PROM_TOKEN=$(sudo cat /var/lib/prometheus/vault_token)
curl -s -o /dev/null -w "%{http_code}" \
     -H "X-Vault-Token: $PROM_TOKEN" \
     "http://127.0.0.1:8200/v1/sys/metrics?format=prometheus"
# Esperado: 200

# V5: Endpoint de métricas bloqueado sem token
curl -s -o /dev/null -w "%{http_code}" \
     "http://127.0.0.1:8200/v1/sys/metrics?format=prometheus"
# Esperado: 403

# V6: policy-metrics não permite nada além de /sys/metrics
PROM_TOKEN=$(sudo cat /var/lib/prometheus/vault_token)
VAULT_TOKEN=$PROM_TOKEN vault kv list secret/ 2>&1 | grep -i "permission denied"
# Esperado: "permission denied" — token não pode ler secrets

# V7: Disco com logrotate projetado
ls -lh /opt/vault/logs/
df -h /
# Registrar uso atual de disco para baseline
```

---

## 8. Itens de Observação

### OBS-01 — Warning Raft TLS: keys pending

**Evidência:** Mensagem `"skipping new raft TLS config creation, keys are pending"` repetindo a cada ~5 minutos no `journalctl -u vault`.

**Análise:** Em configuração single-node com `tls_disable = true` no listener, o Raft opera sem TLS entre nós (não há outros nós). O aviso indica que o processo de rotação de chaves TLS do Raft foi iniciado mas não concluído. Não impacta a operação atual.

**Ação:** Nenhuma nesta GMUD. Registrar para investigação antes de qualquer expansão para multi-node ou habilitação de TLS. Monitorar se a mensagem passa a incluir erros além de warnings.

**Referência futura:** Investigar `vault operator raft list-peers` e `vault operator key-status` em janela de manutenção dedicada.

---

### OBS-02 — policy-colaborador-prj009 sem rastreabilidade

**Evidência:** `vault policy list` retorna `policy-colaborador-prj009`. Nenhum documento do PRJ007 (TAP, REL, ADD-FASE2, Lições Aprendidas) menciona essa política.

**Análise:** Política criada fora de qualquer GMUD registrada. Pode estar relacionada ao PRJ009 (mencionado no `api-proxy-policy` do TAP original) mas não há confirmação.

**Ação nesta GMUD:** Executar o Passo 4 do plano de execução para verificar se há tokens ativos usando essa política. Registrar a decisão (manter documentando ou remover) no campo 12.

---

### OBS-03 — Hostname inconsistente

**Evidência:** Nome da VM no Hyper-V é `VAULT-GEN1`. Hostname dentro da VM (e registrado no Cloudflare/Tailscale) é `vault-gf-01`.

**Análise:** Inconsistência cosmética entre inventário Hyper-V e hostname do sistema. Não impacta operação.

**Ação:** Sem ação técnica. Registrar no inventário do Living Lab que `VAULT-GEN1` (Hyper-V) = `vault-gf-01` (hostname) = `xxx.xxx.xxx.xxx` (Tailscale IP).

---

## 9. Pendências Futuras Registradas

Estas pendências não são bloqueantes para esta GMUD e devem ser tratadas em projetos ou GMUDs futuras:

| ID | Pendência | Origem | Prioridade |
|----|-----------|--------|------------|
| PF-001 | Migração `VAULT-GEN1` de GEN1 para GEN2 | CONSTRAINT-001 / POP-LAB-002 | Média |
| PF-002 | Habilitação de TLS no listener do Vault | REL-PRJ007 lições aprendidas | Média |
| PF-003 | Auto-unseal (Transit ou Cloud KMS) | REL-PRJ007 lições aprendidas | Alta |
| PF-004 | Investigação e resolução do warning Raft TLS | OBS-01 desta GMUD | Média |
| PF-005 | Backup automatizado com cron job (Raft snapshot diário) | TAP PRJ007 — não implementado | Alta |

---

## 10. Fora do Escopo

As seguintes ações foram explicitamente excluídas desta GMUD:

- Migração da VM para GEN2
- Configuração de auto-unseal
- Habilitação de TLS no listener (`tls_disable = true` permanece)
- Alteração, rotação ou migração de secrets armazenados no KV
- Configuração de dynamic secrets
- Expansão para cluster multi-node
- Integração com LDAP/Active Directory

---

## 11. Rastreabilidade com PRJ016

Esta GMUD atende às dependências formalizadas na **Seção 9 do Blueprint PRJ016 v2.0**:

| DEP PRJ016 | Ação nesta GMUD | Status após execução |
|------------|-----------------|----------------------|
| DEP-001 — Logrotate | PRO-01: `/etc/logrotate.d/vault` configurado | [ ] Pendente → [ ] Concluído |
| DEP-002 — X-Forwarded-For | PRO-02: bloco adicionado no `vault.hcl` | [ ] Pendente → [ ] Concluído |
| DEP-003 — Telemetry + Token | PRO-03 + PRO-04: bloco `telemetry` + token `prometheus-scraper` | [ ] Pendente → [ ] Concluído |

Após execução, atualizar a **Matriz de Rastreabilidade (Seção 9.2)** do Blueprint PRJ016 v2.0 marcando as colunas "Implementada" e "Validada pelo PRJ016".

---

## 12. Registro de Execução

*Preencher durante e após a execução da GMUD.*

| Campo | Valor |
|-------|-------|
| **Data de execução** | _______________ |
| **Hora de início** | _______________ |
| **Hora de término** | _______________ |
| **Executor** | _______________ |
| **Snapshot criado** | [ ] Sim — Nome: _______________ |
| **PRO-01 logrotate** | [ ] Concluído [ ] Falhou — Observação: _______________ |
| **PRO-02 X-Forwarded-For** | [ ] Concluído [ ] Falhou — Observação: _______________ |
| **PRO-03 telemetry** | [ ] Concluído [ ] Falhou — Observação: _______________ |
| **Restart vault.service** | [ ] Executado — Hora: _______________ |
| **Unseal executado** | [ ] Sim — Tempo de indisponibilidade: _______________ min |
| **PRO-04 token prometheus** | [ ] Concluído [ ] Falhou — Observação: _______________ |
| **OBS-02 policy-prj009** | [ ] Mantida (documentar motivo) [ ] Removida |
| **Todos os critérios V1–V7** | [ ] Aprovados [ ] Parcial — Itens pendentes: _______________ |
| **Rollback necessário** | [ ] Não [ ] Sim — Motivo: _______________ |
| **Disco após execução** | ___% de uso — Arquivo audit: ___ MB |
| **Observações gerais** | _______________ |

---

*GMUD-PRJ007-003 — Hardening e Governança de Identidade do HashiCorp Vault*
*Living Lab Fiqueok — Versão 1.0 — Abril 2026*
*Elaborado com base em evidências coletadas em 18/04/2026*

