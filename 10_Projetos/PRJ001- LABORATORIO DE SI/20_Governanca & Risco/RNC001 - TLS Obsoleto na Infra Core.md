---
data_identificacao: 2025-12-18
id_relatorio: RNC-2025-001
status: 🟡 Aberto
nivel_risco: Médio
impacto_negocio: Conformidade e Segurança de Dados
sistema_afetado: Infraestrutura Core (Web Services)
tags: #GRC #RNC #ISO27001 #Laboratorio
---

# 📑 Relatório de Não-Conformidade (RNC)

## 1. Sumário Executivo
**Descrição do Risco:**
> A infraestrutura central utiliza protocolos de criptografia obsoletos (TLS 1.0/1.1), permitindo que atacantes interceptem ou decifrem comunicações sensíveis (Ataques *Man-in-the-Middle*).

**Impacto Potencial:**
* [ ] Financeiro (Multas, Perda de Receita)
* [ ] Reputacional (Danos à marca)
* [ ] Operacional (Parada de serviço)
* [x] Legal/Compliance (Violação da ISO 27001 e PCI-DSS)

---

## 2. Detalhamento Técnico (A Evidência)
* **Fonte da Descoberta:** Scan de Vulnerabilidade (OpenVAS / DefectDojo Ato 1)
* **Vulnerabilidade Técnica:** Protocolos TLS 1.0 e TLS 1.1 habilitados no serviço web.
* **CWE:** CWE-327 (Use of a Broken or Risky Cryptographic Algorithm)
* **Ativo Afetado:** `192.168.56.x` (Servidor Web/App)
* **Link para Evidência:** [Inserir Link do seu DefectDojo aqui]

---

## 3. Mapeamento de Conformidade (O "Porquê" corrigir)
| Framework | Controle / Requisito | Status |
| :--- | :--- | :--- |
| **ISO 27001:2022** | A.8.24 - Uso de Criptografia | ❌ Não Conforme (Uso ineficaz de criptografia) |
| **ISO 27001:2022** | A.5.14 - Transferência de Info. | ❌ Não Conforme (Risco no trânsito de dados) |
| **NIST CSF 2.0** | PR.DS-02 (Dados em Trânsito) | ⚠️ Parcial (Confidencialidade não garantida) |
| **PCI-DSS 4.0** | Req. 4.2.1 (Criptografia Forte) | ❌ Não Conforme (Uso de SSL/TLS antigo) |

---

## 4. Plano de Ação e Tratamento
**Estratégia Escolhida:**
- [x] **Mitigar:** Aplicar correção técnica (Hardening).
- [ ] **Aceitar:** O risco está dentro do apetite.
- [ ] **Transferir:** Contratar seguro ou terceirizar.
- [ ] **Evitar:** Descontinuar o sistema/serviço.

**Definição de SLA (Política Interna):**
* **Prazo Limite:** 2026-01-17 (30 dias - Risco Médio)
* **Responsável Técnico:** Equipe de Infraestrutura / SRE

**Ações Recomendadas:**
1. Reconfigurar o serviço Web (Apache/Nginx) para desabilitar TLS 1.0 e 1.1.
2. Habilitar exclusivamente TLS 1.2 e 1.3.
3. Executar novo scan de vulnerabilidade para validação (Reteste).
