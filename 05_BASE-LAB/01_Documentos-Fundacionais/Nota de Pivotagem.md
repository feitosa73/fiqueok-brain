# NOTA_DE_PIVOTAGEM — Living Lab Fiqueok

## 1. Propósito

Este documento é o **mapa de continuidade** do Living Lab Fiqueok. Ele registra as **transições estratégicas** entre projetos, as decisões que motivaram mudanças de direção e a localização dos ativos reutilizáveis.

Qualquer pessoa que ler este documento entenderá:

- Por que projetos foram iniciados, congelados ou encerrados
- Onde encontrar os artefatos de cada projeto
- Como os projetos se conectam entre si
- Qual é a arquitetura atual e para onde estamos indo

> **Este não é um documento técnico de execução.**  
> É um documento de **governança e rastreabilidade arquitetural**.

---

## 2. Linha do Tempo dos Projetos

| Período | Projeto | Status | Objetivo Principal | Sucessor |
|---------|---------|--------|--------------------|----------|
| Dez/2025 | PRJ001 | ✅ CONCLUÍDO | Laboratório de SI — baseline de segurança | PRJ002 |
| Jan/2026 | PRJ002 | ✅ CONCLUÍDO | Infraestrutura Core (AD, DHCP, midPoint, OrangeHRM) | PRJ003 |
| Jan/2026 | PRJ003 | ✅ CONCLUÍDO | IGA Greenfield — primeira camada de governança | PRJ005 |
| Fev/2026 | PRJ005 | ✅ CONCLUÍDO | Integração OrangeHRM como fonte autoritativa | PRJ006 |
| Fev/2026 | PRJ006 | ⚠️ ABORTADO | JDBC direto — anti-padrão identificado | PRJ008 |
| Fev/2026 | PRJ007 | ✅ CONCLUÍDO | HashiCorp Vault — cofre de senhas | PRJ012 |
| Fev/2026 | PRJ008 | 🧊 FREEZE | API de integração — aguardando decisão | PRJ009 |
| Fev-Mar/2026 | PRJ009 | ⚠️ ENCERRADO | Hybrid Identity Bridge (Azure Gateway) | PRJ014 |
| Mar/2026 | PRJ010 | ✅ CONCLUÍDO | 100 colaboradores no OrangeHRM | PRJ011 |
| Mar/2026 | PRJ011 | ✅ CONCLUÍDO | 100 usuários no Entra ID | PRJ012 |
| Mar/2026 | PRJ012 | ⚠️ PARCIAL | midPoint → Entra ID (ATOs 1 e 2 concluídos) | PRJ014 |
| Mar/2026 | PRJ013 | ❌ CANCELADO | Planejado, não iniciado | — |
| Mar/2026 | PRJ014 | 🟢 ATIVO | IGA Híbrido Local (AD → Cloud Sync → Entra ID) | PRJ015 (planejado) |

---

## 3. Transições Estratégicas e Decisões Documentadas

### 3.1. PRJ006 → PRJ008 (Abandono de JDBC)

| Item | Descrição |
|------|-----------|
| **Motivo** | JDBC direto identificado como anti-padrão arquitetural — schema do OrangeHRM altamente normalizado |
| **Decisão** | Abortar PRJ006, migrar para abordagem API-first |
| **Documento** | REL-PRJ006 (Relatório de Encerramento) |

### 3.2. PRJ008 → PRJ009 (Pivot para Hybrid)

| Item | Descrição |
|------|-----------|
| **Motivo** | Validação de arquitetura híbrida para AZ-305 + demanda por PaaS |
| **Decisão** | Congelar PRJ008, iniciar experimento de 7 dias com VM Azure Gateway |
| **Documento** | ADR-PRJ009-001 |

### 3.3. PRJ009 → PRJ014 (Encerramento por Custo)

| Item | Descrição |
|------|-----------|
| **Motivo** | Créditos Azure expirando + surgimento de demanda externa (DPSP) por Cloud Sync |
| **Decisão** | Desprovisionar VM Azure, encerrar PRJ009, migrar inteligência para borda |
| **Documento** | ADR-PRJ009-002, TEP-PRJ009 |

### 3.4. PRJ012 (ATO 3) → PRJ014 (Redirecionamento)

| Item | Descrição |
|------|-----------|
| **Motivo** | Decisão de usar Cloud Sync (gratuito) em vez de midPoint para sync AD → Entra durante o Trial |
| **Decisão** | ATO 3 do PRJ012 substituído pelo PRJ014 (Fase 1) |
| **Documento** | TAP-PRJ012 (Nota de Evolução), TAP-PRJ014 |

---

## 4. Arquitetura Atual (PRJ014 — Fase 1)
