## 📄 TERMO DE ENCERRAMENTO DO PROJETO (TEP) — PROJ020 v1.0

### Implementação de DefectDojo + OpenVAS (Kali) para Descoberta e Gestão de Vulnerabilidades de API
### **Documento de Encerramento — Fase de Estabilização e Blindagem ZTNA**

---

| Campo                         | Valor                                                                                            |
| :---------------------------- | :----------------------------------------------------------------------------------------------- |
| **Código do Projeto**         | PROJ020                                                                                          |
| **Nome do Projeto**           | Implementação de DefectDojo + OpenVAS (Kali) para Descoberta e Gestão de Vulnerabilidades de API |
| **Tipo de Documento**         | **TERMO DE ENCERRAMENTO DO PROJETO (TEP)**                                                       |
| **Versão**                    | **1.0**                                                                                          |
| **Data de Encerramento**      | 28/04/2026                                                                                       |
| **Responsável pela Execução** | Paulo Feitosa Lima — GRC Lead                                                                    |
| **Patrocinador**              | Living Lab Fiqueok                                                                               |
| **Status do Projeto**         | 🟢 **ENCERRADO — AMBIENTE OPERACIONAL E AUDITÁVEL**                                              |
| **Classificação**             | CONFIDENCIAL — Dados Técnicos e de Governança                                                    |

---

## 1. RESUMO EXECUTIVO

O PROJ020 foi concebido para estabelecer uma camada de **Gestão de Vulnerabilidades** que fechasse o ciclo GRC do Living Lab Fiqueok, integrando capacidades de descoberta de vulnerabilidades (OpenVAS/GVM) com orquestração e gestão de riscos (DefectDojo).

**O que foi entregue:**

O projeto entregou um **pipeline operacional de Vulnerability Management** estruturado nos seguintes pilares:

| Pilar | Entrega | Status |
|-------|---------|--------|
| **Orquestração** | DefectDojo em Docker Compose, acessível via `dojo.fiqueok.com.br` | ✅ |
| **Descoberta** | GVM/OpenVAS no Kali Linux com 175.814 NVTs atualizados | ✅ |
| **ZTNA** | Cloudflare Tunnel + MFA, eliminando exposição pública de portas | ✅ |
| **Integração** | Pipeline Detecção → Ingestão → Tratamento de Risco validado | ✅ |

**Resultado Estratégico:**

O Living Lab agora possui um **sistema de gestão de vulnerabilidades auditável** que:

- Opera sob princípios de **Zero Trust** (exposição zero)
- Suporta **decisões de GRC documentadas** (ex: Risk Acceptance com controles compensatórios)
- Oferece **resiliência operacional** via snapshots e documentação de "Caminho Feliz"

---

## 2. OBJETIVOS DO PROJETO — STATUS DE ENTREGA

| Objetivo Planejado | Status | Evidência |
|--------------------|--------|-----------|
| Implantar DefectDojo operacional | ✅ | Acesso via `dojo.fiqueok.com.br` com CSRF/Allowed Hosts configurados |
| Implantar OpenVAS/GVM funcional | ✅ | 175.814 NVTs; scan executado na API PRJ008 |
| Integrar ambas as ferramentas | ✅ | XML exportado do GVM e importado no DefectDojo |
| Estabelecer acesso remoto seguro | ✅ | Cloudflare Tunnel + MFA; **nenhuma porta pública exposta** |
| Documentar procedimento de scan | ✅ | POP-PROJ020-001 e "Caminho Feliz" documentados |
| Criar baseline de recuperação | ✅ | Snapshot `PROJ020_DOJO_STABLE_ZTNA` no Hyper-V |

### 2.1. Escopo Executado vs. Planejado

| Item | Planejado | Executado | Status |
|------|-----------|-----------|--------|
| Akto (API Security) | Incluído no v1.0 | Removido (FROZEN) | ⚠️ Escopo ajustado |
| OpenVAS em Ubuntu 24.04 | Tentado | Falhou (PPAs 404) | 🔄 Pivotado para Kali |
| Cloudflare Tunnel | Não planejado | Implementado | ✅ Valor agregado |
| MFA na camada de identidade | Não planejado | Implementado | ✅ Valor agregado |

> **Justificativa:** As adições de Cloudflare Tunnel e MFA representam **valor agregado** não previsto, resultando em uma postura de segurança superior ao planejado original.

---

## 3. CONTROLE DE RISCOS E POSTURA DE SEGURANÇA

### 3.1. Evolução da Postura de Risco (Pré vs. Pós-Projeto)

| Dimensão | Pré-PROJ020 | Pós-PROJ020 | Redução de Risco |
|----------|-------------|-------------|------------------|
| **Superfície de ataque** | Portas 8080 e 9392 expostas | Nenhuma porta pública (Tailscale + Tunnel) | 🔴 **Crítica** |
| **Autenticação** | Apenas senha local | MFA via Cloudflare Access | 🟠 **Alta** |
| **Gestão de vulnerabilidades** | Inexistente | Pipeline documentado e auditável | 🔴 **Crítica** |
| **Recuperação** | Nenhum backup | Snapshot com baseline validada | 🟡 **Média** |

### 3.2. Decisão Estratégica de GRC — Risk Acceptance Documentado

**Achado:** Algoritmos fracos de MAC no SSH da VM API (severidade 2.6)

**Decisão:** Risk Accepted

**Justificativa Técnica (Controle Compensatório):**
> O acesso à VM API é exclusivamente realizado via malha Tailscale (Zero Trust Network Access), que Opera em uma camada de criptografia e autenticação independente do SSH. A vulnerabilidade de MAC fraca no SSH **não é explorável** no contexto do Living Lab porque:
> 1. A API não está acessível via internet pública
> 2. O Tailscale exige autenticação mútua e autorização baseada em identidade
> 3. O Cloudflare Tunnel adiciona uma camada adicional de MFA antes de qualquer roteamento

**Evidência documentada no DefectDojo:** Finding "Weak MAC Algorithm(s) Supported (SSH)" com status "Risk Accepted" e justificativa anexada.

---

## 4. ARQUITETURA FINAL ENTREGUE

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PROJ020 — VULNERABILITY MANAGEMENT PIPELINE              │
│                                                                             │
│  ┌─────────────────────────────┐    ┌─────────────────────────────────────┐│
│  │  DEFECTDOJO                  │    │  OPENVAS/GVM                       ││
│  │  dojo.fiqueok.com.br         │    │  gvm.fiqueok.com.br                 ││
│  │  Docker Compose              │    │  Kali Linux + 175.814 NVTs          ││
│  │  CSRF_TRUSTED_ORIGINS config │    │  Systemd com --munix-socket         ││
│  └─────────────┬───────────────┘    └─────────────────┬───────────────────┘│
│                │                                      │                     │
│                └──────────────┬───────────────────────┘                     │
│                               │                                             │
│                               ▼                                             │
│                    ┌───────────────────────────────────────┐               │
│                    │  CLOUDFLARE ZERO TRUST                │               │
│                    │  Tunnel + MFA + No TLS Verify         │               │
│                    │  ✅ Nenhuma porta pública exposta     │               │
│                    └───────────────────────────────────────┘               │
│                               │                                             │
│                               ▼                                             │
│                    ┌───────────────────────────────────────┐               │
│                    │  TAILSCALE MESH                       │               │
│                    │  api-gf-01 (xxx.xxx.xxx.xxx)          │               │
│                    └───────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.1. Configurações Críticas Documentadas

| Componente | Configuração Chave | Local da Documentação |
|------------|-------------------|----------------------|
| DefectDojo | `DD_CSRF_TRUSTED_ORIGINS`, `DD_ALLOWED_HOSTS` | TAP-PROJ020-v1.7 |
| GSAD | `--munix-socket=/run/gvmd/gvmd.sock` | "Caminho Feliz" |
| Cloudflare Tunnel | `No TLS Verify = ON` | Dashboard Cloudflare |
| Recuperação | Snapshot `PROJ020_DOJO_STABLE_ZTNA` | Hyper-V Manager |

---

## 5. LIÇÕES APRENDIDAS (BASE DE CONHECIMENTO DO LIVING LAB)

### L01: O "Caminho Feliz" é um ativo de governança

A documentação do procedimento correto (após 6 versões de TAP) tornou-se um **ativo estratégico** que reduzirá o tempo de futuras implantações de 6-8 horas para **15-20 minutos**.

### L02: Divergência entre documentação online e binário local é um risco de auditoria

A descoberta de que a flag correta era `--munix-socket` (e não `--gmp-socket` ou `--mgsmd`) foi feita via `--help`, não pela documentação oficial. **A lição:** Sempre validar com o binário local.

### L03: Zero Trust exige repensar o tratamento de vulnerabilidades

O achado de severidade 2.6 (MAC fraca no SSH) foi aceito como risco porque os controles de identidade e perímetro (Tailscale + Cloudflare MFA) anulam o vetor de ataque. **A lição:** Vulnerabilidades não são avaliadas isoladamente, mas no contexto dos controles compensatórios existentes.

### L04: Snapshots são o último recurso de resiliência

A capacidade de reverter para `Pre-Scan-Inaugural-GVM-OK` e `PROJ020_DOJO_STABLE_ZTNA` salvou horas de retrabalho. **A lição:** Documentar e manter baselines funcionais é tão importante quanto a configuração ativa.

---

## 6. MÉTRICAS DE SUCESSO DO PROJETO

| Métrica | Valor Alvo | Valor Realizado | Status |
|---------|-----------|-----------------|--------|
| Tempo de implantação (pós-"Caminho Feliz") | < 30 min | 15-20 min | 🟢 **Superado** |
| NVTs carregados | > 100k | 175.814 | 🟢 **Superado** |
| Exposição pública de portas | Nenhuma | 0 portas | 🟢 **Atendido** |
| MFA implementado | Desejável | ✅ | 🟢 **Valor agregado** |
| Pipeline documentado | Sim | POP + TAP + TEP | 🟢 **Atendido** |

---

## 7. PRÓXIMOS PASSOS (TRANSIÇÃO PARA OPERAÇÃO CONTÍNUA)

O projeto é **encerrado** do ponto de vista de implantação. As seguintes atividades transitam para o regime de **operação contínua** e evolução futura:

| Ordem | Atividade | Vinculação | Responsável |
|-------|-----------|------------|-------------|
| 1 | Scans periódicos (mensais ou por demanda) | POP-PROJ020-001 | Paulo |
| 2 | Atualização de feeds do GVM | Operação contínua | Automático |
| 3 | Revisão periódica do "Risk Accepted" | Ciclo de risco GRC | Paulo |
| 4 | **ITDR (PRJ016)** — Expansão para detecção de identidade | Próximo projeto | Paulo |

### 7.1. Transição para ITDR (PRJ016)

O PROJ020 estabeleceu a base de **detecção de vulnerabilidades**. O próximo projeto (PRJ016) expandirá para **ITDR (Identity Threat Detection and Response)**, integrando:

- Detecção de anomalias de identidade
- Correlação com achados de vulnerabilidade
- Automação de resposta a incidentes de identidade

---

## 8. ENTREGÁVEIS DO PROJETO

| ID | Entregável | Status | Localização |
|----|------------|--------|-------------|
| E01 | VM defectdojo-gf-01 (DefectDojo) | ✅ | Hyper-V |
| E02 | VM sec-openvas-kali (Kali + GVM) | ✅ | Hyper-V |
| E03 | Snapshot `PROJ020_DOJO_STABLE_ZTNA` | ✅ | Hyper-V |
| E04 | Acesso externo via Cloudflare Tunnel | ✅ | `gvm.fiqueok.com.br` |
| E05 | Primeiro scan executado | ✅ | XML exportado |
| E06 | Finding tratado no DefectDojo | ✅ | Risk Accepted documentado |
| E07 | POP-PROJ020-001 | ✅ | `10_Projetos/PROJ020/` |
| E08 | TAP-PROJ020-v1.7 | ✅ | `10_Projetos/PROJ020/` |
| E09 | **TEP-PROJ020-v1.0 (este doc)** | ✅ | `10_Projetos/PROJ020/` |

---

## 9. APROVAÇÕES E ENCERRAMENTO

| Função | Nome | Data | Assinatura |
|--------|------|------|------------|
| GRC Lead / Responsável Técnico | Paulo Feitosa Lima | 28/04/2026 | ✅ |
| Patrocinador do Projeto | Paulo Feitosa Lima | 28/04/2026 | ✅ |

---

## 10. DECLARAÇÃO DE ENCERRAMENTO

Declaro que o PROJ020 — "Implementação de DefectDojo + OpenVAS (Kali) para Descoberta e Gestão de Vulnerabilidades de API" — está **formalmente encerrado**.

Todos os objetivos técnicos foram alcançados, os entregáveis foram validados, e o ambiente encontra-se operacional dentro dos padrões de segurança e governança do Living Lab Fiqueok.

O projeto transita agora para o regime de **operação contínua**, com os achados de risco devidamente documentados e monitorados. As lições aprendidas foram incorporadas à base de conhecimento do laboratório e servirão como referência para futuras iniciativas, incluindo o PRJ016 (ITDR).

---

**Living Lab Fiqueok — GRC Lead**

*Paulo Feitosa Lima*

28 de abril de 2026

---

> 📄 **Documento:** `TEP-PROJ020-v1.0.md`
> 🔒 **Classificação:** CONFIDENCIAL
> 📍 **Localização:** `10_Projetos/PROJ020/00_Gestao_do_Projeto/TEP-PROJ020-v1.0.md`
> 🔗 **Documentos relacionados:** `TAP-PROJ020-v1.7.md`, `POP-PROJ020-001.md`

---

**FIM DO TERMO DE ENCERRAMENTO DO PROJETO — PROJ020**
