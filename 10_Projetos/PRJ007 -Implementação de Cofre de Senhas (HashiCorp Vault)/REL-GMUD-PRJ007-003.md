

## Relatório de Execução — Hardening e Governança de Identidade

### HashiCorp Vault — Living Lab Fiqueok

---

|Campo|Valor|
|---|---|
|**Código GMUD**|GMUD-PRJ007-003|
|**Título**|Hardening e Governança de Identidade — HashiCorp Vault|
|**Data de execução**|18 de Abril de 2026|
|**Hora de início**|19:08 UTC (snapshot)|
|**Hora de término**|22:57 UTC|
|**Executor**|Paulo (Arquiteto de Segurança e Redes)|
|**Ambiente**|Produção Living Lab — VM `VAULT-GEN1` (Hyper-V GEN1)|

---

## Sumário Executivo

A GMUD-PRJ007-003 foi executada em **18 de abril de 2026** com duração aproximada de **3 horas e 49 minutos** (incluindo coleta de evidências, configuração, restart, unseal e validações). Todas as ações prospectivas (PRO-01 a PRO-04) foram concluídas com sucesso. Os critérios de validação V1 a V7 foram aprovados. Nenhum rollback foi necessário.

**Principais entregas realizadas:**

- Configuração de logrotate para o `vault_audit.log` (mitigação do risco de Fail-Closed por disco cheio)
    
- Adição do bloco `X-Forwarded-For` no `vault.hcl` (captura de IP real do cliente via Cloudflare)
    
- Adição do bloco `telemetry` no `vault.hcl` (habilitação do endpoint `/v1/sys/metrics` para Prometheus)
    
- Criação da política `policy-metrics` e do token `prometheus-scraper-prj016` (TTL 8760h)
    

---

## 1. Execução — Ações Prospectivas

### 1.1 PRO-01 — Configurar logrotate para vault_audit.log

|Atividade|Comando / Ação|Resultado|
|---|---|---|
|Criar arquivo de configuração|`sudo tee /etc/logrotate.d/vault`|Arquivo criado com 273 bytes|
|Validar sintaxe|`sudo logrotate -d /etc/logrotate.d/vault`|Sem erros — "log does not need rotating"|
|Verificar permissões|`ls -l /etc/logrotate.d/vault`|`-rw-r--r-- 1 root root`|
|Baseline do audit log|`ls -lh /opt/vault/logs/vault_audit.log`|1.8 MB (baseline registrado)|

**Status:** ✅ Concluído

**Evidência:**

text

-rw-r--r-- 1 root root 273 Apr 18 22:15 /etc/logrotate.d/vault
-rw------- 1 vault vault 1.8M Apr 18 21:37 /opt/vault/logs/vault_audit.log

---

### 1.2 PRO-02 e PRO-03 — Atualizar vault.hcl (X-Forwarded-For + Telemetry)

|Atividade|Comando / Ação|Resultado|
|---|---|---|
|Backup do vault.hcl|`sudo cp /etc/vault.d/vault.hcl /etc/vault.d/vault.hcl.bkp-20260418-2216`|Backup criado|
|Editar configuração|`sudo nano /etc/vault.d/vault.hcl`|Blocos adicionados conforme GMUD|
|Reiniciar serviço|`sudo systemctl restart vault`|Serviço reiniciado|
|Verificar status pós-restart|`vault status`|`Sealed: true` (esperado)|
|Unseal (3 de 5 chaves)|`vault operator unseal` (3x com chaves válidas)|`Sealed: false`, `HA Mode: standby`|

**vault.hcl final (blocos adicionados destacados):**

hcl

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
  # DEP-002 PRJ016: Capturar IP real via túnel Cloudflare
  x_forwarded_for_authorized_addrs     = "127.0.0.1/8"
  x_forwarded_for_hop_skips            = 0
  x_forwarded_for_reject_not_authorized = false
}
# DEP-003 PRJ016: Habilitar telemetria para Prometheus
telemetry {
  prometheus_retention_time = "30s"
  disable_hostname          = true
}

**Status:** ✅ Concluído

**Observação de execução:** Durante o unseal, houve duas tentativas com erro `'key' must be specified in request body`. O operador repetiu o comando sem digitar a chave nesses momentos, mas as tentativas com fornecimento correto da chave avançaram o progresso de 1/3 → 2/3 → concluído. O unseal foi bem-sucedido.

---

### 1.3 PRO-04 — Criar policy-metrics e token prometheus-scraper

|Atividade|Comando / Ação|Resultado|
|---|---|---|
|Criar política `policy-metrics`|`vault policy write policy-metrics`|✅ Sucesso|
|Criar token (TTL 8760h)|`vault token create -policy=policy-metrics -ttl=8760h`|Token gerado|
|Salvar token em arquivo|`sudo tee /var/lib/prometheus/vault_token`|96 bytes|
|Hardening do arquivo|`sudo chmod 600 && sudo chown root:root`|Permissão 600|
|Testar endpoint de métricas|`curl -H "X-Vault-Token: $PROM_TOKEN" /v1/sys/metrics`|✅ Retornou métricas Prometheus|

**Token criado:**

text

hvs.CAESICxfhVX-NKR73QGmo3yEOMU3BHHevS7YF_r5sRvekF_<REDACTED_SECRET>xR3g

**Evidência do teste:**

text

# HELP go_gc_duration_seconds A summary of the wall-time pause...
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 3.8772e-05

**Status:** ✅ Concluído

**Observação:** O erro de login `invalid username or password` ocorreu no início do passo, mas não bloqueou a execução. O operador já estava autenticado via token root da sessão anterior (após o unseal). Este ponto está alinhado com o risco R2 documentado no TAP-PRJ007-v3.0 (root token em uso operacional) e será tratado em GMUD futura.

---

## 2. Critérios de Validação

|ID|Critério|Resultado|Evidência|
|---|---|---|---|
|V1|logrotate configurado e sem erros|✅ Aprovado|`logrotate -d` sem erros|
|V2|Vault operacional após restart|✅ Aprovado|`Sealed: false`, `HA Mode: standby`|
|V3|X-Forwarded-For ativo (IP real nos logs)|✅ Aprovado|Captura de IPv6 real do cliente via Cloudflare confirmada|
|V4|Endpoint `/sys/metrics` acessível com token|✅ Aprovado|HTTP 200 com métricas Prometheus|
|V5|Endpoint `/sys/metrics` bloqueado sem token|✅ Aprovado|HTTP 403 (validado na GMUD)|
|V6|policy-metrics restrita (não acessa outros paths)|✅ Aprovado|`VAULT_TOKEN=$PROM_TOKEN vault kv list secret/` → permission denied|
|V7|Disco com logrotate projetado|✅ Aprovado|61% de uso — baseline estável|

**Validação adicional confirmada pelo executor:**

> *"Validação técnica confirmou a captura de IP real (IPv6) via X-Forwarded-For e a acessibilidade das métricas via token dedicado prometheus-scraper-prj016. Baseline de disco estável em 61%."*

---

## 3. Itens de Observação — Tratamento

### OBS-01 — Warning Raft TLS: keys pending

**Status:** 🔵 Monitorado — sem ação nesta GMUD

**Evidência pós-execução:** O warning continua presente no `journalctl -u vault` com frequência de ~5 minutos. Não impacta a operação em single-node com `tls_disable=true`. Registrado como PF-004 para investigação futura.

### OBS-02 — policy-colaborador-prj009 sem rastreabilidade

**Status:** 🟡 Mantida — documentada

**Decisão:** A política `policy-colaborador-prj009` está em uso pelo PRJ009 (assinatura de chaves SSH). Não foi removida. Foi documentada:

- No TAP PRJ007 v3.0 (seção 6 — Políticas RBAC Ativas)
    
- Na GMUD-PRJ007-003 (OBS-02)
    
- Pendente: referência cruzada no TAP do PRJ009
    

### OBS-03 — Hostname inconsistente (VAULT-GEN1 vs vault-gf-01)

**Status:** 🔵 Registrado — sem ação técnica

Documentado no inventário do Living Lab.

---

## 4. Pendências Futuras — Atualização

|ID|Pendência|Status após GMUD|
|---|---|---|
|PF-001|Migração GEN1 → GEN2|🔴 Pendente — mesma prioridade|
|PF-002|TLS no listener|🔴 Pendente — mesma prioridade|
|PF-003|Auto-unseal|🔴 Pendente — mesma prioridade|
|PF-004|Investigação warning Raft TLS|🟡 Pendente — OBS-01 monitorado|
|PF-005|Backup automatizado (Raft snapshot)|🔴 Pendente — mesma prioridade|
|PF-006|Revogar root token e migrar para admin user|🔴 Pendente — risco R2 ainda aberto|

---

## 5. Rastreabilidade com PRJ016

|DEP PRJ016|Ação|Status|
|---|---|---|
|DEP-001 — Logrotate|PRO-01|✅ Implementada|
|DEP-002 — X-Forwarded-For|PRO-02|✅ Implementada|
|DEP-003 — Telemetry + Token|PRO-03 + PRO-04|✅ Implementada|

**Recomendação:** Atualizar a Matriz de Rastreabilidade (Seção 9.2) do Blueprint PRJ016 v2.0 marcando as colunas "Implementada" e "Validada pelo PRJ016" como concluídas.

---

## 6. Registro de Rollback

|Cenário|Ocorreu?|
|---|---|
|Erro de sintaxe no vault.hcl|❌ Não|
|Falha no unseal|❌ Não|
|Necessidade de restauração de snapshot|❌ Não|
|Erro no logrotate|❌ Não|
|Token criado com erro|❌ Não|

**Rollback necessário:** ❌ Não

**Snapshot de segurança:** `PRE-GMUD-PRJ007-003-20260418-1908` — mantido por 7 dias conforme política de backup do Living Lab.

---

## 7. Observações Gerais

### 7.1 Fator de sucesso crítico

A criação do snapshot Hyper-V antes do restart foi essencial para garantir rollback seguro. Recomenda-se manter esta prática em todas as GMUDs que envolvam restart de serviços críticos.

### 7.2 Ponto de atenção — root token

Durante a execução, observou-se que o operador ainda depende do token root para operações administrativas (evidenciado pelo erro de login no userpass que não bloqueou a criação da política). O risco R2 do TAP (root token em uso operacional) permanece aberto e requer GMUD dedicada.

### 7.3 Ponto de atenção — intermitência no unseal

A sequência de unseal apresentou erro quando o comando `vault operator unseal` foi executado sem fornecer a chave. Recomenda-se documentar no SOP-03 a forma correta de uso interativo do comando, ou migrar para script com as chaves armazenadas externamente (KeePass + cópia manual).

### 7.4 Métricas finais do ambiente

|Métrica|Valor|
|---|---|
|Uso de disco (`/`)|61% (estável)|
|Tamanho audit log|1.8 MB (baseline)|
|Vault version|1.21.3|
|HA Mode|standby (single-node)|
|Políticas ativas|admin-policy, reader-policy, api-proxy-policy, policy-colaborador-prj009, policy-metrics|
|Tokens de serviço ativos|svc-shadow-api (720h), prometheus-scraper-prj016 (8760h)|

---

## 8. Aprovações Pós-Execução

|Papel|Nome|Data|Assinatura|
|---|---|---|---|
|Executor|Paulo|18/04/2026|✅ (conforme declaração)|
|Validação técnica|Paulo|18/04/2026|✅ (validação confirmada)|

---

*REL-GMUD-PRJ007-003 — Relatório de Execução*  
_Living Lab Fiqueok — 18 de Abril de 2026_  
_Documento gerado com base em evidências coletadas durante a execução da GMUD_
