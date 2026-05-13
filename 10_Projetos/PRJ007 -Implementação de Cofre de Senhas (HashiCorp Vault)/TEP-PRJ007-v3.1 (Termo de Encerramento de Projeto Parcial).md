

## Atualização do PRJ007 — Pós-GMUD-PRJ007-003

---

|Campo|Valor|
|---|---|
|**Código do Projeto**|PRJ007|
|**Versão do TAP**|3.1 (atualização pós-GMUD)|
|**Data**|18 de Abril de 2026|
|**Responsável**|Paulo — Arquiteto de Segurança e Redes|
|**Status do Projeto**|Em operação — Fase de Melhorias Contínuas|

---

## 1. Atualização do Estado dos Objetivos

|ID|Objetivo|Status anterior (v3.0)|Status atual (v3.1)|Observação|
|---|---|---|---|---|
|OS6|Documentação técnica reproduzível|🔄 Em atualização|✅ Concluído|GMUD e REL registrados|
|OS8|RBAC sem root token operacional|🔴 Parcial|🔴 Parcial|Ainda pendente (R2)|
|OS10|Controles de disco (logrotate)|🔴 Pendente|✅ Concluído|DEP-001 PRJ016 atendida|

---

## 2. Atualização do Estado dos Riscos

|ID|Risco|Status anterior|Status atual|Observação|
|---|---|---|---|---|
|R1|Disco cheio → Fail-Closed|🔴 Aberto|✅ Mitigado|logrotate configurado (PRO-01)|
|R2|Root token em uso ativo|🔴 Aberto|🔴 Aberto|Requer GMUD dedicada (PF-006)|
|R8|Token svc-shadow-api sem renovação automática|🟡 Investigar|✅ Confirmado|Ver seção 4 abaixo|

---

## 3. Pendências Futuras — Atualização Pós-GMUD

|ID|Pendência|Prioridade|Responsável|Prazo sugerido|
|---|---|---|---|---|
|PF-001|Migração GEN1 → GEN2|Média|Paulo|Q3 2026|
|PF-002|TLS no listener|Média|Paulo|Q3 2026|
|PF-003|Auto-unseal (Transit ou Cloud KMS)|Alta|Paulo|Q2 2026|
|PF-004|Investigação warning Raft TLS|Baixa|Paulo|Q3 2026|
|PF-005|Backup automatizado (Raft snapshot diário)|Alta|Paulo|Q2 2026|
|PF-006|Revogar root token e migrar para admin user|**Alta**|Paulo|**Maio 2026**|

---

## 4. Confirmação Adicional Pós-Execução

### Token `svc-shadow-api` (PRJ008)

**Evidência coletada durante a GMUD:**

text

display_name: token-svc-shadow-api
creation_time: 1776453086
creation_ttl: 720h
expire_time: 2026-05-17T19:11:26Z
renewable: true

**Status:** Token ativo com TTL de 30 dias. A renovação automática deve ser verificada no crontab da VM `api-gf-01`. Caso ausente, configurar como tarefa operacional separada.

---

## 5. Documentação do Projeto — Estado Atualizado

|Artefato|Versão|Data|Status|
|---|---|---|---|
|GMUD-PRJ007-003|1.0|18/04/2026|✅ Executada|
|REL-GMUD-PRJ007-003|1.0|18/04/2026|✅ Gerado|
|TAP PRJ007|**3.1**|18/04/2026|✅ Atualizado|
|Lições Aprendidas|2.0|18/04/2026|✅ Mantido|
|SOP-03|1.0|18/04/2026|✅ Mantido|

---

*TEP-PRJ007-v3.1 — Atualização pós-GMUD-PRJ007-003*  
_Living Lab Fiqueok — 18 de Abril de 2026_