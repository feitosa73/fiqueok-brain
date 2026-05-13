# TAP PRJ007 v3.0 — Implementação de PAM com HashiCorp Vault
## Living Lab Fiqueok

---

| Campo | Valor |
|-------|-------|
| **Código do Projeto** | PRJ007 |
| **Nome** | Implementação de Privileged Access Management — HashiCorp Vault |
| **Versão do TAP** | 3.0 — Atualização de estado real pós-Fase 2 |
| **Data de Atualização** | 18 de Abril de 2026 |
| **Responsável** | Paulo — Arquiteto de Segurança e Redes |
| **Status do Projeto** | Ativo — Operação contínua com melhorias incrementais via GMUD |

### Histórico de Versões do TAP

| Versão | Data | Descrição |
|--------|------|-----------|
| 1.0 | 03/02/2026 | Versão inicial — Vault em Docker, file storage, VM dedicada planejada |
| 2.0 | 03/02/2026 | Revisão final pré-execução — mesmo escopo, ajustes de premissas |
| 3.0 | 18/04/2026 | Atualização para estado real pós-Fase 2: runtime nativo, Raft, WSL2→GEN1, Cloudflare ZT, RBAC nominal |

---

## 1. Identificação do Projeto

| Item | Descrição |
|------|-----------|
| **Categoria** | Segurança da Informação / PAM (Privileged Access Management) |
| **Programa** | Living Lab Fiqueok — Identity & Access Governance Stack |
| **Patrocinador** | Paulo (IAM Specialist / Arquiteto de Segurança) |
| **Data de Início** | 03/02/2026 |
| **Data de Conclusão da Fase 2** | 18/04/2026 (GMUD-PRJ007-003) |
| **Status** | Operação contínua |

---

## 2. Contexto e Justificativa

### 2.1 Histórico de Fases

O PRJ007 foi executado em duas fases, com um gap operacional entre elas:

**Fase 1 (03–09/02/2026):**
Vault implantado via Docker em WSL2 com Raft storage. Encerrado com sucesso em 09/02/2026. Referência: `REL-PRJ007 v1.0`.

**Evento crítico (10/02/2026):**
24 horas após o encerramento da Fase 1, falhas estruturais do WSL2 tornaram o ambiente instável. Vault não persistia após reboot, Tailscale conflitava com o daemon Windows. Decisão: migração para Hyper-V GEN1. Referência: `ADD-PRJ007-FASE2`.

**Fase 2 (10/02/2026 — em curso):**
Migração para VM `VAULT-GEN1` (Hyper-V GEN1), instalação nativa via systemd, manutenção do Raft storage. Entre 12/02 e 18/04/2026 foram implementadas evoluções sem GMUD formal, formalizadas pela `GMUD-PRJ007-003`.

### 2.2 Justificativa estratégica (mantida)

O PRJ007 estabelece a **fundação de segurança** para todos os projetos do Living Lab que requerem gestão de secrets. Sem ele, as integrações PRJ008 (Shadow API), PRJ009 e futuras ficam sem PAM, violando o princípio de Zero Plaintext na infraestrutura.

---

## 3. Objetivos do Projeto

### 3.1 Objetivos originais — status atual

| ID | Objetivo | Status |
|----|----------|--------|
| OS1 | VM dedicada `vault-gf-01` integrada ao Tailscale | ✅ Concluído — `VAULT-GEN1`, IP `xxx.xxx.xxx.xxx` |
| OS2 | Migrar 100% dos secrets para Vault KV v2 | ✅ Concluído — secrets em `/opt/vault/data` (Raft) |
| OS3 | Scripts e biblioteca Python para acesso programático | ✅ Concluído — token `svc-shadow-api` ativo (PRJ008) |
| OS4 | RBAC com políticas segregadas por sistema | ✅ Concluído — 4 políticas ativas + modelo de papéis |
| OS5 | Audit logs para rastreabilidade completa | ✅ Concluído — Fail-Closed, `/opt/vault/logs/vault_audit.log` |
| OS6 | Documentação técnica reproduzível | 🔄 Em atualização — TAP v3.0, GMUD-PRJ007-003, SOP-03 |

### 3.2 Objetivos adicionados na evolução do projeto

| ID | Objetivo | Status |
|----|----------|--------|
| OS7 | Exposição segura via Cloudflare ZT + OTP | ✅ Concluído — 18/04/2026, `vault.fiqueok.com.br` |
| OS8 | RBAC com usuários nominais (sem root token operacional) | 🔴 Parcial — root token em uso ativo (ver seção 8) |
| OS9 | SSH Secrets Engine para assinatura de chaves | ✅ Implementado — `ssh-client-signer/`, PRJ009 |
| OS10 | Controles de disco para Fail-Closed (logrotate) | 🔴 Pendente — GMUD-PRJ007-003 PRO-01 |

---

## 4. Arquitetura Atual (Estado Real — 18/04/2026)

### 4.1 Infraestrutura

| Componente | Valor |
|------------|-------|
| **Host físico** | i5-12400F · 64 GB RAM · Windows 11 Pro · Hyper-V |
| **VM** | `VAULT-GEN1` — Hyper-V **Geração 1** · 1.2 GB RAM alocado |
| **OS** | Ubuntu 24.04.3 LTS · Kernel `6.8.0-107-generic` |
| **Hostname** | `vault-gf-01` |
| **IP Tailscale** | `xxx.xxx.xxx.xxx` |
| **IP eth0** | `172.25.25.41` (rede interna Hyper-V) |
| **Virtualização detectada** | `microsoft` (Hyper-V) |
| **Disco** | 9.8 GB total · 5.7 GB usado · **61% de uso** |
| **RAM** | 1.1 GB total · 509 MB usado · 97 MB livre · 715 MB cache |
| **vCPUs** | 2 |

> **Nota de arquitetura:** A VM permanece em GEN1 por decisão tática documentada no `CONSTRAINT-001` (UEFI corrompido no Hyper-V em 10/02/2026). A migração para GEN2 está registrada como `PF-001` (pendência futura) na `GMUD-PRJ007-003`.

### 4.2 Stack tecnológica real

| Componente | Versão | Método de instalação | Gerenciamento |
|------------|--------|---------------------|---------------|
| **HashiCorp Vault** | 1.21.3 | Pacote apt nativo | systemd (`vault.service`) |
| **Storage backend** | Raft Integrated | `/opt/vault/data`, `node_id: fiqueok-gen1-node` | Single-node, HA habilitado |
| **cloudflared** | 2026.3.0 | Pacote apt | systemd (`cloudflared.service`) |
| **Tailscale** | Estável | Pacote apt | systemd |
| **Docker** | Não presente na VM do Vault | — | N/A |

### 4.3 Configuração atual do vault.hcl

```hcl
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "fiqueok-gen1-node"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
}

api_addr     = "http://xxx.xxx.xxx.xxx:8200"
cluster_addr = "https://127.0.0.1:8201"

ui           = true
disable_mlock = true
log_level    = "info"
log_format   = "json"
```

> **Blocos ausentes a adicionar na GMUD-PRJ007-003:** `x_forwarded_for_*` no listener e bloco `telemetry`.

### 4.4 Engines montadas

| Path | Tipo | Uso |
|------|------|-----|
| `secret/` | KV v2 | Secrets de aplicações (OrangeHRM, MidPoint, Shadow API) |
| `ssh-client-signer/` | SSH | Assinatura de chaves SSH para colaboradores (PRJ009) |
| `auth/token/` | Token | Autenticação por token |
| `auth/userpass/` | Userpass | Autenticação por usuário/senha |

### 4.5 Acesso e exposição

| Canal | Endereço | Autenticação | Uso |
|-------|----------|-------------|-----|
| **Cloudflare ZT** | `vault.fiqueok.com.br` | OTP por e-mail (Cloudflare Access) + senha Vault | Acesso externo, co-criadores, parceiros |
| **Tailscale** | `xxx.xxx.xxx.xxx:8200` | Senha Vault (userpass) | Administração, SSH, manutenção de VMs |

---

## 5. Stakeholders e Modelo de Papéis

O PRJ007 adota um **modelo baseado em papéis**, não em identidades nominais. A gestão nominal (quem ocupa cada papel) é operacional e não deve constar neste TAP — ela é gerenciada via GMUDs de identidade.

| Papel | Política Vault | Acesso | Responsabilidade |
|-------|---------------|--------|-----------------|
| **Administrador** | `admin-policy` — `path "*" { all capabilities }` | Total sobre secrets, políticas e engines | Manutenção do Vault, rotação de tokens, GMUDs |
| **Operacional** | `reader-policy` — leitura de `secret/data/*` e metadata | Leitura de secrets e navegação na UI | Consulta de secrets para desenvolvimento |
| **Serviço (aplicação)** | `api-proxy-policy` ou política dedicada | Leitura restrita ao path da aplicação | Acesso programático por tokens de serviço |
| **Colaborador SSH** | `policy-colaborador-prj009` | Assinatura de chaves SSH + leitura de `secret/data/projeto009/*` | Acesso SSH a nós do lab via chave assinada |
| **Co-criador / Parceiro** | `reader-policy` ou derivada | Equivalente ao Operacional | Demonstrações e acesso ao ambiente |

> **Nota sobre root token:** O root token (`token_issue_time: 2026-02-10`) está em uso ativo para acesso à UI. Isso é identificado como risco operacional — ver seção 8.

---

## 6. Políticas RBAC Ativas

| Política | Path(s) | Capabilities | Uso atual |
|----------|---------|-------------|-----------|
| `admin-policy` | `*` | create, read, update, delete, list, sudo | Usuário `paulo` |
| `reader-policy` | `secret/data/*`, `secret/metadata/*`, `sys/mounts` | read, list | Usuários operacionais |
| `api-proxy-policy` | `secret/data/orangehrm/*`, `secret/data/api-proxy/*`, `auth/token/renew-self` | read, update | Token `svc-shadow-api` (PRJ008) |
| `policy-colaborador-prj009` | `ssh-client-signer/sign/role-colaborador-prj009`, `secret/data/projeto009/*` | create, update, read | Colaboradores PRJ009 |
| `policy-metrics` | `/sys/metrics` | read | Token `prometheus-scraper` (a criar — GMUD-PRJ007-003) |

---

## 7. Tokens de Serviço Ativos

| Display name | Política | TTL | Uso | Expiração |
|-------------|----------|-----|-----|-----------|
| `token-svc-shadow-api` | `api-proxy-policy` | 720h | Shadow API / PRJ008 | 2026-05-17 |
| `prometheus-scraper-prj016` | `policy-metrics` | 8760h | Prometheus / PRJ016 | A criar — GMUD-PRJ007-003 |

> **Crontab de renovação:** Token da Shadow API expira em 30 dias. Verificar crontab em `api-gf-01` para renovação automática. Se ausente, configurar como parte da GMUD-PRJ007-003 ou tarefa operacional separada.

---

## 8. Riscos Ativos e Mitigações

| ID | Risco | Probabilidade | Impacto | Mitigação atual | Status |
|----|-------|--------------|---------|-----------------|--------|
| R1 | Disco cheio → Fail-Closed → Vault para | **Alta** | **Crítico** | Nenhuma — logrotate ausente | 🔴 Aberto — GMUD-PRJ007-003 PRO-01 |
| R2 | Root token em uso ativo para UI (antipadrão) | Alta | Alto | Nenhuma | 🔴 Aberto — requer GMUD futura |
| R3 | Unseal manual obrigatório após cada restart | Alta | Alto | Procedimento documentado no SOP-03 | 🟡 Aceito — auto-unseal em PF-003 |
| R4 | VM em GEN1 (sem UEFI, TPM, Secure Boot) | Média | Médio | Aceito conscientemente — PF-001 | 🟡 Aceito |
| R5 | TLS desabilitado no listener (HTTP) | Média | Médio | Mitigado por Cloudflare ZT + Tailscale E2EE | 🟡 Aceito — PF-002 |
| R6 | Warning Raft TLS `keys are pending` | Baixa | Baixo | Monitorar — não afeta operação single-node | 🟡 OBS-01 GMUD-PRJ007-003 |
| R7 | Kernel desatualizado (`6.8.0-107`, esperado `6.8.0-110`) | Baixa | Baixo | `apt upgrade` pendente + reboot necessário | 🟡 Aberto |
| R8 | Token `svc-shadow-api` sem renovação automática confirmada | Média | Alto | Verificar crontab em `api-gf-01` | 🟡 Investigar |

---

## 9. Conformidade com Frameworks

| Controle | Framework | Status | Observação |
|----------|-----------|--------|------------|
| A.8.15 — Logging | ISO 27001:2022 | ✅ Atendido | Audit device Fail-Closed ativo |
| A.8.3 — Privilégio Mínimo | ISO 27001:2022 | ✅ Atendido | `reader-policy` implementada |
| A.5.18 — Gestão de Identidades | ISO 27001:2022 | ✅ Atendido | Usuários nominais, RBAC por política |
| A.12.3 — Backup | ISO 27001:2022 | 🟡 Parcial | Snapshot manual Hyper-V; automação em PF-005 |
| A.13.1.3 — Segregação de Rede | ISO 27001:2022 | 🟡 Parcial | GEN1 sem VLAN dedicada; mitigado por Tailscale |
| Root token desativado | CIS Vault Benchmark | 🔴 Não atendido | Root token em uso ativo — R2 |
| TLS no listener | CIS Vault Benchmark | 🟡 Parcial | HTTP local; TLS na borda (Cloudflare) |
| PR.AC-1 — Identidades gerenciadas | NIST CSF | ✅ Atendido | Cloudflare + Vault Userpass |

---

## 10. Pendências Futuras (PF)

| ID | Pendência | Prioridade | Referência |
|----|-----------|-----------|------------|
| PF-001 | Migração `VAULT-GEN1` GEN1 → GEN2 | Média | POP-LAB-002 / CONSTRAINT-001 |
| PF-002 | TLS no listener do Vault | Média | REL-PRJ007 lições aprendidas |
| PF-003 | Auto-unseal (Transit ou Cloud KMS) | Alta | REL-PRJ007 lições aprendidas |
| PF-004 | Resolução do warning Raft TLS `keys are pending` | Média | OBS-01 GMUD-PRJ007-003 |
| PF-005 | Backup automatizado (Raft snapshot diário via cron) | Alta | TAP PRJ007 v1.0 — não implementado |
| PF-006 | Desativar uso do root token — criar token admin com TTL | Alta | R2 desta seção |
| PF-007 | Atualização do kernel (`6.8.0-107` → `6.8.0-110`) + reboot | Baixa | Evidência terminal 18/04/2026 |
| PF-008 | Confirmar e/ou configurar renovação automática do token `svc-shadow-api` | Alta | R8 desta seção |

---

## 11. Documentação do Projeto

| Artefato | Versão | Data | Status |
|----------|--------|------|--------|
| TAP PRJ007 | **3.0** | 18/04/2026 | ✅ Atual |
| REL-PRJ007 (Fase 1) | 1.0 | 09/02/2026 | ✅ Fechado |
| ADD-PRJ007-FASE2 | 1.0 | 10/02/2026 | ✅ Fechado |
| POP-LAB-002 | 1.0 | 12/02/2026 | ✅ Ativo |
| POP-DR-001 | 1.1 | 12/02/2026 | ✅ Ativo |
| Lições Aprendidas | **2.0** | 18/04/2026 | ✅ Atual |
| GMUD-PRJ007-001 | — | — | ❌ Não registrada (gap) |
| GMUD-PRJ007-002 | — | — | ❌ Não registrada (gap) |
| GMUD-PRJ007-003 | 1.0 | 18/04/2026 | ✅ Aprovada para execução |
| SOP-03 | 1.0 | 18/04/2026 | ✅ Ativo |

---

*TAP PRJ007 — Implementação de PAM com HashiCorp Vault*
*Living Lab Fiqueok — Versão 3.0 — Abril 2026*
*Baseado em evidências coletadas em 18/04/2026 via SSH em vault-gf-01*

