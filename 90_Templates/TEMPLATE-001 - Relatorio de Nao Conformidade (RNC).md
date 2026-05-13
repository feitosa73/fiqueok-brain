---
data_identificacao: {{date}}
id_relatorio: #RNC-YYYY-000
status: 🟡 Aberto
nivel_risco: Médio
impacto_negocio: Confidencialidade
sistema_afetado: 
---

# 📑 Relatório de Não-Conformidade (RNC)

## 1. Sumário Executivo
**Descrição do Risco:**
> [Descreva aqui em 1 linha o risco para o negócio. Ex: O sistema de pagamentos utiliza criptografia obsoleta, facilitando a interceptação de dados de clientes.]

**Impacto Potencial:**
* [ ] Financeiro (Multas, Perda de Receita)
* [ ] Reputacional (Danos à marca)
* [ ] Operacional (Parada de serviço)
* [ ] Legal/Compliance (Violação de leis/normas)

---

## 2. Detalhamento Técnico (A Evidência)
* **Fonte da Descoberta:** [ex: Scan OpenVAS / Auditoria Interna]
* **Vulnerabilidade Técnica:** [ex: Protocolo TLS 1.0 Habilitado]
* **CWE/CVE:** [ex: CWE-327]
* **Ativo Afetado:** `[IP ou Hostname]`
* **Link para Evidência:** [Link do DefectDojo ou Print]

---

## 3. Mapeamento de Conformidade (O "Porquê" corrigir)
| Framework | Controle / Requisito | Status |
| :--- | :--- | :--- |
| **ISO 27001:2022** | A.8.24 - Uso de Criptografia | ❌ Não Conforme |
| **ISO 27001:2022** | A.5.14 - Transferência de Info. | ❌ Não Conforme |
| **NIST CSF 2.0** | PR.DS-02 (Dados em Trânsito) | ⚠️ Parcial |
| **PCI-DSS 4.0** | Req. 4.2.1 (Criptografia Forte) | ❌ Não Conforme |

---

## 4. Plano de Ação e Tratamento
**Estratégia Escolhida:**
- [ ] **Mitigar:** Aplicar correção técnica.
- [ ] **Aceitar:** O risco está dentro do apetite (Requer aprovação da Diretoria).
- [ ] **Transferir:** Contratar seguro ou terceirizar.
- [ ] **Evitar:** Descontinuar o sistema/serviço.

**Definição de SLA (Política Interna):**
* **Prazo Limite:** [Data de Hoje + 60 dias]
* **Responsável Técnico:** [Nome da Área/Pessoa, ex: Infraestrutura Core]

**Ações Recomendadas:**
1. [Ação Técnica 1 - Ex: Alterar conf do Apache]
2. [Ação Técnica 2 - Ex: Rodar novo scan de validação]

---
#tags: #GRC #Risco #Compliance #Audit