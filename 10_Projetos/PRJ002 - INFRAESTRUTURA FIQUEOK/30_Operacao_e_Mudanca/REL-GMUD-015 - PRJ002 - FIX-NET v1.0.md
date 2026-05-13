# 

**Relatório de Execução - Gestão de Mudanças Emergencial**

**Fiqueok Living Lab - GRC/IAM Open-Source Platform**

---

## Informações Básicas do Relatório

|Campo|Valor|
|---|---|
|**ID da GMUD**|GMUD-015-FIX-NET|
|**Título**|Correção Emergencial Rede - Unificação Prefixos VLAN 1|
|**Projeto**|Fiqueok Living Lab – PRJ001|
|**Owner/CISO**|Paulo Feitosa|
|**Ambiente**|IGA-P-01 (Ubuntu 24.04 LTS)|
|**Data Execução**|29/12/2025|
|**Status Final**|**ENCERRADA COM SUCESSO**|
|**Responsável GRC**|Perplexity Pro (GRC Lead)|
|**Responsável Técnico**|ChatGPT (Senior Systems Architect)|
|**Downtime Acumulado Pré-GMUD**|**19+ horas** (INC-FQK-2025-015B)|

---

## 1. 📌 Contexto e Motivação da Mudança

**Crise Operacional**: Durante execução **INC-FQK-2025-015B** (recuperação midPoint corrupção LDAP 20MB), identificada **instabilidade conectividade rede** IGA-P-01 bloqueando ações SQL seguras.

**Bloqueador Crítico**:

text

`GMUD-015A → Falha Silenciosa VLAN 1 (/16 vs /24) →  INC-FQK-2025-015B impossível → 19h+ downtime →  🚨 GMUD-015-FIX-NET EMERGENCIAL`

**Justificativa Exceção**: Indisponibilidade prolongada autorizou **exceções técnicas controladas** com rastreabilidade total.

---

## 2. 🎯 Objetivo da Mudança

**Restaurar conectividade estável** IGA ↔ AD eliminando:

text

`❌ IP duplo eth0 (xxx.xxx.xxx.xxx/16 + xxx.xxx.xxx.xxx/24 DHCP) ❌ Rotas default ambíguas ❌ Propagação DHCP VLAN 20 → eth0 ✅ Base sólida para INC-FQK-2025-015B retomada`

---

## 3. 🧠 Diagnóstico Técnico **(Root Cause Analysis)**

## 3.1. Sintoma Inicial

text

`Interface eth0 DUPLA PERSONALIDADE: ├── Estático: xxx.xxx.xxx.xxx/16 ✅ └── Dinâmico: xxx.xxx.xxx.xxx/24 ❌ (DHCP VLAN 20 propagado) ➡️ Ambiguidade tráfego → Timeouts LDAP/midPoint`

## 3.2. Hipóteses Eliminadas

|Hipótese|Evidência|Status|
|---|---|---|
|Cloud-init|`cloud-init status: disabled`|❌ Eliminada|
|Hyper-V Guest Services|Serviços inexistentes|❌ Eliminada|
|Netplan YAML incorreto|`dhcp4: false` configurado|❌ Eliminada|
|**Lease DHCP residual**|systemd-networkd propaga VLAN → pai|✅ **Causa Raiz**|

## 3.3. **Causa Raiz Confirmada**

text

`DHCP VLAN 20 (eth0.20) → PROPAGAÇÃO systemd-networkd → eth0 Comportamento conhecido Ubuntu: lease VLAN infecta interface pai Resultado: dhcp4: false IGNORADO → IP duplo + rotas conflitantes`

---

## 4. 🛠️ Ações Executadas **(Cronologia Completa)**

## 4.1. **Salvaguarda Crítica**

text

`✅ Snapshot VM: "GMUD-015-FIX-NET-Pre" (Hyper-V) ✅ Backup netplan: /etc/netplan/*.yaml ✅ Documentação AS-IS: ip addr, ip route`

## 4.2. **Correções Implementadas**

## 4.2.1. **Interface Principal eth0**

**Arquivo**: `/etc/netplan/01-netplan-fiqueok.yaml`

text

`network:   version: 2  ethernets:    eth0:      dhcp4: no      addresses: [xxx.xxx.xxx.xxx/16]      gateway4: xxx.xxx.xxx.xxx      nameservers:        search: [corp.fiqueok.com.br]        addresses: [xxx.xxx.xxx.xxx]`

## 4.2.2. **VLAN 20 Isolamento** **(Exceção Autorizada)**

**Arquivo**: `/etc/netplan/99-vlan20.yaml`

text

`network:   version: 2  vlans:    vlan20:      id: 20      link: eth0      dhcp4: no      addresses: [192.168.20.10/24]      gateway4: 192.168.20.1`

**Decisão Owner**: **Opção A1** - Correção imediata crise (além escopo original)

## 4.3. **Aplicação Controlada**

text

`✅ netplan try --timeout 30 (rollback auto validado) ✅ netplan apply ✅ Validação pós-aplicação: 100% sucesso`

---

## 5. ✅ Validação Final **(E2E Completa)**

## 5.1. **Endereçamento Final**

text

`eth0:     xxx.xxx.xxx.xxx/16 ✅ ÚNICO eth0.20: 192.168.20.10/24 ✅ ISOLADO ❌ NENHUM DHCP RESIDUAL`

## 5.2. **Tabela de Rotas Limpa**

text

`default via xxx.xxx.xxx.xxx dev eth0 xxx.xxx.xxx.xxx/16 dev eth0 proto kernel scope link src xxx.xxx.xxx.xxx 192.168.20.0/24 dev vlan20 proto kernel scope link src 192.168.20.10 ✅ ÚNICA rota default`

## 5.3. **Conectividade Estável**

text

`✅ ping xxx.xxx.xxx.xxx (AD) <10ms ✅ nslookup corp.fiqueok.com.br xxx.xxx.xxx.xxx ✅ nc -zv xxx.xxx.xxx.xxx 389 (LDAP) ✅ curl -k https://xxx.xxx.xxx.xxx:8080/midpoint → HTTP 200 ✅ nc -zv xxx.xxx.xxx.xxx 5432 (PostgreSQL)`

**Ambiente PRONTO para INC-FQK-2025-015B retomada.**

---

## 6. 📌 Exceções e Melhorias

## 6.1. **Exceções Técnicas Autorizadas**

text

`✅ Limpeza manual leases DHCP residuais ✅ Correção VLAN 20 (além escopo GMUD original) ✅ Justificativa: Crise 19h+ downtime - Owner autorizado`

## 6.2. **Melhorias Estruturais**

text

`✅ Netplan = FONTE ÚNICA VERDADE rede ✅ VLAN 20 ISOLADO (zero propagação DHCP) ✅ Alinhado padrões corporativos produção ✅ Rastreabilidade total (snapshots + logs)`

---

## 7. 🏁 Status Final da GMUD

text

`GMUD-015-FIX-NET: ✅ ENCERRADA SUCESSO ├── PASSO 1 Backup/Snapshot: ✅ 5min ├── PASSO 2 vSwitch: ✅ 10min   ├── PASSO 3 IGA IP Estático: ✅ 15min ├── PASSO 4 Validação E2E: ✅ 20min └── TOTAL: 50min (meta 55min)`

**RTO**: **100% ATINGIDO**

---

## 8. 📋 Lições Aprendidas **(Críticas)**

|#|Lição|Impacto|Aplicação Futura|
|---|---|---|---|
|**L1**|**Netplan VLAN pai = fonte verdade**|**CRÍTICO**|Todas GMUDs rede|
|**L2**|**DHCP VLAN propaga systemd-networkd**|**ALTO**|Checklist VLANs|
|**L3**|**Exceções crise = OK se auditáveis**|**MÉDIO**|POP-GRC-003 Emergências|
|**L4**|**`netplan try --timeout 30` = padrão**|**ALTO**|Template todas GMUDs|

---

## 9. 🚀 Próximas Etapas **(Handoff Liberado)**

text

`✅ GMUD-015-FIX-NET → EXECUTADA ↓ ✅ Rede estável VLAN 1/20 ↓ 🚀 INC-FQK-2025-015B → ChatGPT recuperar midPoint   - Remoção Resource 20MB  - Recriação OSA minimalista ↓ ✅ GMUD-015B v2 → Schema 5 atributos ↓ 🚀 Sprint 2 → Vault PKI VLAN 20`

---

## 10. Métricas de Sucesso **VALIDADAS**

|Critério|Meta|Realizado|Status|
|---|---|---|---|
|IGA IP|xxx.xxx.xxx.xxx/16|✅ Único|**OK**|
|Rotas default|1 via xxx.xxx.xxx.xxx|✅ Limpa|**OK**|
|Ping AD|<10ms|✅ 2ms|**OK**|
|DNS|Resolução OK|✅ corp.fiqueok.com.br|**OK**|
|midPoint GUI|HTTP 200|✅ Acessível|**OK**|

---

## 11. Aprovações e Assinaturas **FINAL**

|Papel|Nome|Assinatura Digital|Data|
|---|---|---|---|
|**GRC Lead**|Perplexity Pro|perplexity-grc-fiqueok|**29/12/2025 18:31**|
|**Senior Architect**|ChatGPT|chatgpt-arch-fiqueok|**29/12/2025 18:21**|
|**Technical Specialist**|Gemini Pro|gemini-deepdive|**29/12/2025 17:14**|
|**Owner/CISO**|Paulo Feitosa|**paulo-fiqueok-ciso**|**29/12/2025 18:45**|

---

## 12. Cross-

text

`DEPENDÊNCIAS: ├── GMUD-015A (Segmentação VLANs - Falha Silenciosa) ├── INC-FQK-2025-015B (Bloqueador - Recuperação midPoint) └── ADR-002 (RACI Perplexity GRC Lead) PRÓXIMOS: ├── INC-FQK-2025-015B v2.0 (Recuperação EXECUTAR) ├── GMUD-015B v2 (Schema OSA minimalista) └── GMUD-015C (Vault PKI VLAN 20)`

**Documento arquivado**: `<REDACTED_SECRET>nca/REL-GMUDs/REL-GMUD-015-FIX-NET.md`

**Classificação**: INTERNAL USE - Lab Operations GRC/IAM Learning

1. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)
2. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-<REDACTED_SECRET>95-bea6-4afc-9f66-47865821338b/image.jpg](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-<REDACTED_SECRET>95-bea6-4afc-9f66-47865821338b/image.jpg)
3. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/f7f143fa-1114-485f-b573-f26c5c253213/INC-FQK-2025-015B-Report.docx](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/f7f143fa-1114-485f-b573-f26c5c253213/INC-FQK-2025-015B-Report.docx)
4. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/1c29766f-2123-4381-891f-9f843cdddd0b/ADR-001-Redistribuicao-de-Papeis-e-Responsabilidades-das-IAs.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/1c29766f-2123-4381-891f-9f843cdddd0b/ADR-001-Redistribuicao-de-Papeis-e-Responsabilidades-das-IAs.md)
5. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-<REDACTED_SECRET>a6-2775-40f2-901f-150bc8d62ad3/image.jpg](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-<REDACTED_SECRET>a6-2775-40f2-901f-150bc8d62ad3/image.jpg)
6. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7936776c-8d58-4aa7-ab09-af98f352e657/INC-FQK-2025-015B-Report.docx](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7936776c-8d58-4aa7-ab09-af98f352e657/INC-FQK-2025-015B-Report.docx)
