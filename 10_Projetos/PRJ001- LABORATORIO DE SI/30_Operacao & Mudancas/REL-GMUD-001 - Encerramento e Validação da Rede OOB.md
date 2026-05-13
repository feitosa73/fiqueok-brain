---
id_relatorio: REL-GMUD-001
referencia: [[GMUD-001 - Implementação da Rede de Gerência (OOB)]]
data_execucao: 2025-12-16
executor: Operação (Paulo)
status_final: ✅ Sucesso
tags: #Relatorio #Pos-Mudanca #Evidencia
---

# 📋 Relatório de Execução: GMUD-001

## 1. Vínculo de Origem
Este documento registra a conclusão técnica da mudança planejada em:
> **[[GMUD-001 - Implementação da Rede de Gerência (OOB)]]**

## 2. Resumo da Execução
A mudança foi realizada conforme o script planejado, sem desvios significativos.
* **Início:** 2025-12-16
* **Término:** 2025-12-16
* **Incidentes:** Nenhum incidente registrado durante a janela de manutenção.

## 3. Validação dos Critérios de Sucesso
Conforme definido no plano de testes original:

| Critério Planejado | Resultado Obtido | Status |
| :--- | :--- | :--- |
| **Conectividade Host** | O Host (Docker) alcança os IPs `192.168.56.x`. | ✅ OK |
| **Isolamento Win7** | Windows 7 perdeu acesso à Internet (NAT removido). | ✅ OK |
| **Operação AD** | DC01 manteve comunicação com clientes na rede interna. | ✅ OK |

## 4. Evidências Técnicas
A eficácia da mudança é comprovada pela execução bem-sucedida do primeiro Scan de Vulnerabilidade, que depende integralmente desta nova topologia de rede para funcionar.

* **Evidência Principal:** Relatório de Scan gerado no DefectDojo.
    * *Link:* [[RES01 - Relatório de Execução de Scan - Ato 1]]
    * *Detalhe:* O scan identificou corretamente os ativos `192.168.56.101` e `192.168.56.103`.

## 5. Parecer Final (Post-Mortem)
A implementação da Rede OOB atingiu 100% dos objetivos de segurança (isolamento) e operacionais (gerência). A infraestrutura está homologada para suportar as próximas atividades de Hardening.

---
