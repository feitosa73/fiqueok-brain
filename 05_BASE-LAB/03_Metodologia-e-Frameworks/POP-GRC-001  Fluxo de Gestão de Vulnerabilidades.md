---
id_processo: POP-GRC-001
titulo: Procedimento de Gestão de Vulnerabilidades e Tratamento de RNC
dono: Governança de TI
versao: 1.0
data_criacao: 2025-12-18
tags: #Processo #GRC #Vulnerabilidade #Playbook
---

# 📘 POP-GRC-001: Fluxo de Gestão de Vulnerabilidades

## 1. Objetivo
Estabelecer o processo padrão para identificação, análise, documentação e tratamento de vulnerabilidades técnicas, garantindo conformidade com a **ISO 27001 (A.8.8)** e alinhamento com os riscos de negócio.

## 2. Ferramentas Homologadas
* **Identificação:**  C:\Projetos\Obsidian\Fiqueok_Brain\30_Recursos\Tec - Ferramentas & Stacks
* **Documentação:** Obsidian (Templates de RNC).
* **Mapeamento:** Normas ISO 27001:2022, NIST CSF 2.0 e PCI-DSS.

---

## 3. Macrofluxo do Processo
1.  **Detectar** (Scan Técnico).
2.  **Analisar** (Triagem GRC e Enriquecimento).
3.  **Documentar** (Emissão de RNC).
4.  **Solicitar Correção** (Abertura de Ticket/E-mail).
5.  **Validar** (Reteste).

---

## 4. Procedimento Passo a Passo

### Fase 1: Análise e Triagem (O Olhar do Auditor)
*Ao receber o relatório bruto do scanner (DefectDojo):*
1.  **Validar Falso-Positivo:** Verificar se a falha é real.
2.  **Classificar a Natureza:**
    * *Bug de Software:* Requer Patch/CVE (Ex: Atualizar Apache).
    * *Má Configuração:* Requer Ajuste/Hardening (Ex: Desabilitar TLS 1.0).
3.  **Enriquecimento de Dados:** Se a ferramenta não trouxer, identificar manualmente o **CWE** correspondente para métricas.

### Fase 2: Documentação Formal (RNC)
*Antes de acionar a TI, o GRC deve gerar a evidência.*
1.  Criar nova nota no projeto correspondente.
2.  Aplicar o template oficial: `TEMPLATE-001 - Relatorio de Nao Conformidade`.
3.  **Realizar o "De-Para" Normativo:**
    * Consultar a tabela de controles (ISO/NIST).
    * Descrever o impacto focando no **Negócio** (Risco Legal, Financeiro), não apenas no Técnico.

### Fase 3: Acionamento e SLA
1.  Encaminhar o RNC para a área responsável (Infra/Dev/SRE).
2.  **Estabelecer Prazo (SLA) conforme Política:**
    * 🔴 **Crítico:** 24h a 7 dias.
    * 🟠 **Alto:** 15 dias.
    * 🟡 **Médio:** 30 dias.
    * 🔵 **Baixo:** 90 dias / Melhor esforço.

### Fase 4: Validação (Check)
1.  Após notificação de correção, **nunca confiar apenas na palavra**.
2.  Executar **Reteste (Rescan)** no DefectDojo.
3.  Se resolvido: Alterar status do RNC para "Fechado".
4.  Se não resolvido: Reabrir RNC e escalar para a Gerência se o SLA estourar.

---

## 5. Referências
* [[TEMPLATE-001 - Relatorio de Nao Conformidade (RNC)]]
* Matriz de Riscos Corporativa