# SOP-03 — Runbook de Emergência: Disco do Vault
## HashiCorp Vault — Living Lab Fiqueok

---

| Campo | Valor |
|-------|-------|
| **Código** | SOP-03 |
| **Tipo** | Runbook Operacional — Resposta a Incidente |
| **Severidade** | Crítica — Fail-Closed ativo |
| **Projeto de origem** | PRJ007 / PRJ016 ADR-005 |
| **VM alvo** | `VAULT-GEN1` · hostname `vault-gf-01` · IP Tailscale `xxx.xxx.xxx.xxx` |
| **Versão** | 1.0 |
| **Data** | 18 de Abril de 2026 |
| **Autor** | Paulo — Arquiteto de Segurança e Redes |

---

## Contexto e Risco

O Vault está configurado em modo **Fail-Closed**: se o arquivo `/opt/vault/logs/vault_audit.log` não puder ser gravado por falta de espaço em disco, o serviço **encerra imediatamente** sem possibilidade de recuperação automática. Todas as integrações dependentes (Shadow API, OrangeHRM, MidPoint via PRJ008/PRJ009) param simultaneamente.

**Baseline coletado em 18/04/2026:**

| Métrica | Valor | Limite seguro |
|---------|-------|---------------|
| Disco total (`/`) | 9.8 GB | — |
| Espaço usado | 5.7 GB (61%) | — |
| Espaço livre | 3.7 GB | Mínimo 1.5 GB |
| Arquivo audit | 1.7 MB | — |
| Logrotate configurado | **NÃO** | Obrigatório (DEP-001 PRJ016) |

**Thresholds de alerta Prometheus (ADR-005 PRJ016 v2.0):**

| Nível | Threshold | Ação esperada |
|-------|-----------|---------------|
| Warning | 70% de uso (`/`) | Verificar log e executar logrotate manual |
| Emergência | 85% de uso (`/`) | Executar este SOP imediatamente |
| Crítico | ~97% | Vault já pode estar em Fail-Closed |

---

## Diagnóstico Rápido (2 minutos)

Execute via SSH: `ssh paulo@xxx.xxx.xxx.xxx`

```bash
export VAULT_ADDR='http://127.0.0.1:8200'

# 1. Verificar se o Vault ainda está vivo
vault status 2>&1 | grep -E "Sealed|Error"

# 2. Verificar uso de disco
df -h / | tail -1

# 3. Verificar tamanho atual do audit log
ls -lh /opt/vault/logs/vault_audit.log

# 4. Verificar top consumidores de disco
du -sh /opt/vault/* 2>/dev/null | sort -rh | head -10
du -sh /opt/* 2>/dev/null | sort -rh | head -5
```

**Interpretar resultado:**

| Condição | Ação |
|----------|------|
| `vault status` retorna dados normais + disco < 85% | Executar Cenário A (preventivo) |
| `vault status` retorna dados normais + disco ≥ 85% | Executar Cenário B (urgente) |
| `vault status` retorna `Error` ou conexão recusada | Executar Cenário C (Vault caiu) |

---

## Cenário A — Intervenção Preventiva (disco 70–84%)

*Tempo estimado: 5 minutos. Sem impacto de disponibilidade.*

```bash
# Passo A1: Forçar rotação manual do logrotate
sudo logrotate -f /etc/logrotate.d/vault

# Verificar resultado
ls -lh /opt/vault/logs/
df -h /

# Passo A2: Se logrotate ainda não estiver configurado (DEP-001 pendente)
# Truncar o log com segurança usando copytruncate manual
sudo cp /opt/vault/logs/vault_audit.log \
        /opt/vault/logs/vault_audit.log.$(date +%Y%m%d-%H%M).bkp
sudo truncate -s 0 /opt/vault/logs/vault_audit.log
sudo chown vault:vault /opt/vault/logs/vault_audit.log

# Verificar que o Vault continua gravando no log após truncamento
sleep 5
ls -lh /opt/vault/logs/vault_audit.log
# Esperado: arquivo com poucos KB (novas entradas)

# Passo A3: Registrar ação no log de manutenção
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) SOP-03 CENARIO-A: logrotate manual executado. Disco antes: $(df -h / | tail -1 | awk '{print $5}')" \
  | sudo tee -a /var/log/vault-maintenance.log
```

---

## Cenário B — Intervenção de Urgência (disco ≥ 85%)

*Tempo estimado: 10 minutos. Possível breve interrupção de 30–60 segundos.*

```bash
# Passo B1: Liberar espaço imediatamente — limpar logs antigos comprimidos
sudo find /opt/vault/logs/ -name "*.gz" -mtime +3 -delete
sudo find /var/log/ -name "*.gz" -mtime +7 -delete
sudo journalctl --vacuum-size=100M

# Verificar ganho
df -h /

# Passo B2: Truncar o audit log ativamente
sudo cp /opt/vault/logs/vault_audit.log \
        /opt/vault/logs/vault_audit.log.EMERGENCY-$(date +%Y%m%d-%H%M).bkp
sudo truncate -s 0 /opt/vault/logs/vault_audit.log
sudo chown vault:vault /opt/vault/logs/vault_audit.log

# Passo B3: Verificar que o Vault continua operando
export VAULT_ADDR='http://127.0.0.1:8200'
vault status | grep -E "Sealed|HA Mode"
# Esperado: Sealed: false | HA Mode: active

# Passo B4: Verificar disco pós-intervenção
df -h /
# Esperado: abaixo de 70%

# Passo B5: Registrar incidente
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) SOP-03 CENARIO-B EMERGENCIA: disco atingiu threshold critico. Acao: truncate manual + limpeza de logs. Disco pos: $(df -h / | tail -1 | awk '{print $5}')" \
  | sudo tee -a /var/log/vault-maintenance.log

# Passo B6: Abrir ticket de acompanhamento para configurar DEP-001 (logrotate)
# Referenciar GMUD-PRJ007-003 PRO-01
```

---

## Cenário C — Vault em Fail-Closed (serviço parado)

*Tempo estimado: 15 minutos. Serviço indisponível até conclusão.*

```bash
# Passo C1: Confirmar que o Vault está parado
sudo systemctl status vault | head -5
# Active: failed OU inactive

# Passo C2: Verificar motivo no log do sistema
sudo journalctl -u vault -n 50 --no-pager | grep -E "error|fatal|disk|audit"

# Passo C3: LIBERAR DISCO IMEDIATAMENTE (sem o Vault rodando é seguro)
sudo find /opt/vault/logs/ -name "*.gz" -delete
sudo find /var/log/ -name "*.gz" -mtime +3 -delete
sudo journalctl --vacuum-size=50M

# Truncar o audit log
sudo truncate -s 0 /opt/vault/logs/vault_audit.log
sudo chown vault:vault /opt/vault/logs/vault_audit.log
chmod 600 /opt/vault/logs/vault_audit.log

# Verificar disco — precisa de pelo menos 500 MB livres para o Vault subir
df -h /
# Se ainda abaixo de 500 MB livres, executar:
sudo apt-get clean
sudo find /tmp -mtime +1 -delete 2>/dev/null

# Passo C4: Reiniciar o serviço
sudo systemctl start vault
sleep 10
sudo systemctl status vault | head -5

# Passo C5: UNSEAL OBRIGATÓRIO (Vault volta sealed após restart)
export VAULT_ADDR='http://127.0.0.1:8200'
vault status | grep Sealed
# Sealed: true → aplicar 3 das 5 unseal keys

vault operator unseal  # chave 1 — buscar no KeePass
vault operator unseal  # chave 2
vault operator unseal  # chave 3

vault status | grep -E "Sealed|HA Mode"
# Esperado: Sealed: false | HA Mode: active

# Passo C6: Verificar que o audit log voltou a ser gravado
sleep 10
ls -lh /opt/vault/logs/vault_audit.log
# Esperado: tamanho > 0 e timestamp recente

# Passo C7: Registrar incidente completo
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) SOP-03 CENARIO-C FAIL-CLOSED: Vault parou por disco cheio. Downtime inicio: [PREENCHER]. Downtime fim: $(date -u +%Y-%m-%dT%H:%M:%SZ). Unseal executado." \
  | sudo tee -a /var/log/vault-maintenance.log
```

---

## Checklist pós-incidente

Execute após qualquer cenário:

```bash
# 1. Vault operacional?
vault status | grep "Sealed: false"

# 2. Audit log gravando?
tail -1 /opt/vault/logs/vault_audit.log | jq '.time' 2>/dev/null

# 3. Disco em nível seguro?
df -h / | awk 'NR==2 {print "Uso: "$5" — Livre: "$4}'

# 4. Aplicações dependentes respondendo?
# Shadow API
curl -s -o /dev/null -w "%{http_code}" http://xxx.xxx.xxx.xxx:8000/health

# 5. Gerar relatório de incidente se Cenário B ou C
cat /var/log/vault-maintenance.log | tail -20
```

---

## Prevenção — Ações de longo prazo

| Ação | Referência | Status |
|------|-----------|--------|
| Configurar logrotate (`/etc/logrotate.d/vault`) | GMUD-PRJ007-003 PRO-01 | [ ] Pendente |
| Configurar alerta Prometheus 70%/85% | PRJ016 ADR-005 | [ ] Pendente |
| Expandir disco da VM para 20 GB | PF-001 registrada | [ ] Backlog |

---

*SOP-03 — Runbook de Emergência: Disco do Vault*
*Living Lab Fiqueok — Versão 1.0 — Abril 2026*
*Referências: GMUD-PRJ007-003 · PRJ016 Blueprint v2.0 ADR-005*

