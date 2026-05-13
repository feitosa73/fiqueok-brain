
# TAP-PRJ009-v1.0: Hybrid Identity Bridge
# <REDACTED_SECRET>

## TERMO DE ABERTURA DO PROJETO
**Versão:** 1.0  
**Data:** 26 Fevereiro 2026  
**Responsável:** Paulo Feitosa Lima - GRC Lead  
**GRC Lead AI:** Perplexity AI - Threat Intelligence  
**Ambiente:** Living Lab Fiqueok - Hybrid Cloud Lab  

---

## CHANGELOG
| Versão | Data | Mudanças |
|--------|------|----------|
| 1.0 | 26/02/2026 | Criação - Pivot PRJ008 → PRJ009 Hybrid |

---

## 1. IDENTIFICAÇÃO DO PROJETO

| Campo                   | Valor                                                          |
| ----------------------- | -------------------------------------------------------------- |
| **Código**              | PRJ009                                                         |
| **Nome**                | Hybrid Identity Bridge - OrangeHRM Azure PaaS → midPoint Local |
| **Categoria**           | Cloud Hybrid IGA + AZ-305 Lab                                  |
| **Patrocinador**        | Paulo Feitosa                                                  |
| **Data Início**         | 26/02/2026                                                     |
| **Duração**             | 7 dias (Experimento)                                           |
| **Checkpoint Rollback** | GATE-PRJ008-001                                                |

---

## 2. CONTEXTO E JUSTIFICATIVA

**Situação Anterior (PRJ008 FREEZE):**
```
100% LOCAL MESH (100.69.x.x)
├── OrangeHRM → Docker Local
├── Shadow API → VM api-gf-01  
├── Vault → Local PAM
└── midPoint → DESKTOP-O87TPQI
```

**Lição PRJ008:** Valida On-Prem mas não Hybrid Connectivity AZ-305.

**Nova Realidade Corporativa:** RH Cloud-first (PaaS) + IGA Local (Compliance).

---

## 3. OBJETIVOS

### Objetivo Geral
Validar Shadow API como ponte segura entre OrangeHRM Azure PaaS → midPoint Local via Tailscale Mesh.

### Objetivos Específicos (OS1-OS4)
```
OS1: Provisionar infra Azure Zero Custo (VM B1s Gateway + App Service F1)
OS2: Migrar OrangeHRM → Azure PaaS com conectividade híbrida
OS3: Evoluir Shadow API (Local → Azure Managed Identity + Key Vault)
OS4: Validar ciclo JML end-to-end via tailscale0
```

---

## 4. FASE 0 - PRE-FLIGHT (80% Esforço - 2 dias)

**Duração:** 26-27/02 (6h/dia)  
**Critério Saída:** GATE-PRJ009-001 100% verde

| ID | Decisão | Opções | Prazo |
|----|---------|--------|-------|
| D1 | Gateway VM | B1s (Copilot) ✓ | 26/02 |
| D2 | VNET/Region | Canada Central (Zero Latency) | 26/02 |
| D3 | DB Strategy | Container VM vs PaaS | 26/02 |
| D4 | Secret Mgmt | Managed Identity + Key Vault ✓ | 26/02 |
| D5 | NSG Rules | Tailscale 41641 + API 8000 | 27/02 |

---

## 5. FASE 1 - DESIGN E GOVERNANÇA (3 dias)

**Cronograma:** 28-30/02

| Dia | Horário | Atividade | Responsável |
|-----|---------|-----------|-------------|
| 28/02 | 18h-20h | ARQ-PRJ009-002 (Arquitetura) | Perplexity |
| 29/02 | 18h-20h | OpenAPI Contract Shadow API Azure | Gemini |
| 30/02 | 18h-20h | Threat Model Hybrid Transit | Perplexity |

**Entregáveis:**
```
- ARQ-PRJ009-002.md
- docs/openapi-hybrid.yaml  
- ThreatModel-PRJ009.md
```

---

## 6. FASE 2 - DESENVOLVIMENTO ASSISTIDO IA (2 dias)

**Pipeline 4 Camadas (Anexo E PRJ008):**
```
1. GERAÇÃO: Claude/ChatGPT (Código Azure)
2. ARQUITETURA: Gemini Deep Review
3. THREAT INTEL: Perplexity CVEs
4. HUMANO: Paulo (Logs + Testes)
```

**Sprints Diários:**
```
Sprint 1 (01/03): OAuth2 + Key Vault Manager
Sprint 2 (02/03): /employees + Azure MariaDB
Sprint 3 (03/03): Health Check L3 Hybrid
```

---

## 7. FASE 3 - INTEGRAÇÃO E TESTES (2 dias)

**Objetivo:** JML via ponte híbrida

| Teste | Cenário | Endpoint | Assert |
|-------|---------|----------|--------|
| T1 | Joiner | POST /employees | 200 + dados Azure |
| T2 | Connectivity | GET /health | `status: healthy, latency_hybrid: <50ms` |
| T3 | Rollback | PRJ008 Restore | 100% funcional em 30min |

---

## 8. CRONOGRAMA 80/20 REVISADO

```
DIA 1-2 (26-27/02): Fase 0 Pre-Flight (GATE-PRJ009-001)
DIA 3-5 (28-30/02): Fase 1 Design (ARQ + OpenAPI)
DIA 6-7 (01-02/03): Fase 2 Dev IA (Shadow API Azure)
DIA 8-9 (03-04/03): Fase 3 Testes JML
```

**TOTAL:** 9 dias (Rollback em 7 dias se falhar)

---

## 9. RISCOS E MITIGAÇÕES

| ID | Risco | Prob | Impacto | Mitigação |
|----|-------|------|---------|-----------|
| R1 | Tailscale falha | Média | Crítico | PRJ008 FREEZE |
| R2 | Custo Azure | Baixa | Alto | VM B1s + F1 Free |
| R3 | IA gera CVE | Média | Crítico | Pipeline 4 camadas |
| R4 | Latência >100ms | Média | Médio | Canada Central VNET |

---

## 10. CRITÉRIOS DE SUCESSO

**Planejamento 80%:**
```
CP1: GATE-PRJ009-001 100% ✓
CP2: ARQ-PRJ009-002 aprovado ✓
CP3: OpenAPI sem erros ✓
```

**Execução 20%:**
```
CE1: /health retorna hybrid_latency <50ms
CE2: midPoint lê employees da Azure MariaDB
CE3: Zero CVEs (Perplexity scan)
```

---

## 11. APROVAÇÕES PENDENTES

| Função | Nome | Status |
|--------|------|--------|
| GRC Lead | Perplexity AI | ✓ Aprovado |
| Sponsor | Paulo Feitosa | ⏳ Pendente |
| Threat Intel | Perplexity AI | ✓ Pipeline pronto |

---

**FIM DO TAP-PRJ009 v1.0**  
*Documento mantido por Perplexity AI - Próxima revisão pós-GATE-PRJ009-001*
