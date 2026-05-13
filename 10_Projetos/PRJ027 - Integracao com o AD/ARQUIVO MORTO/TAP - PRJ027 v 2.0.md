# DOCUMENTO 1: TAP (Technical Assessment Plan) — PRJ027 (v2.0)

**Versão:** 2.0 — **Aprovado para Implementação (FinOps Compliant)**  
**Data:** 06/05/2026  
**Arquiteto:** Paulo Feitosa Lima  
**Status:** ✅ Pronto para execução

---

## 1. Escopo de Governança (Versão FinOps)

Este projeto integra o **midPoint 4.10** ao **Microsoft Entra ID Free** utilizando o conector oficial via Microsoft Graph API.

**Diferencial desta versão:** Nenhuma licença paga de produtividade (M365 E5, EMS E5) será provisionada. O foco é exclusivamente:

|Camada|Implementação|Custo|
|---|---|---|
|**Provisionamento de identidade**|Usuário (UPN, nome, e-mail)|✅ Gratuito (até 50k objetos)|
|**Directory Roles (Admin)**|User Administrator, Helpdesk Admin, etc.|✅ Gratuito (nativas)|
|**Workflow de aprovação**|Manager + Security Owner|✅ Sem custo adicional|
|**Segregação de Funções (SoD)**|Regras no midPoint|✅ Sem custo adicional|
|**Certificação de acesso**|Campanhas trimestrais|✅ Sem custo adicional|
|**Reconciliação (Shadow IT)**|Detecção de contas manuais|✅ Sem custo adicional|

**O que NÃO será provisionado (para evitar erros e expectativas incorretas):**

- Licenças Microsoft 365 E5 / EMS E5
    
- Qualquer SKU que exija faturamento ativo no tenant
    

---

## 2. Arquitetura de Integração (FinOps Aligned)

text

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                    PRJ027 - midPoint → Entra ID Free (Custo Zero)                   │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                         midPoint 4.10 (iga-gf-02)                                ││
│  │                                                                                  ││
│  │  ┌─────────────┐    ┌─────────────────────────────────────────────────────────┐││
│  │  │  CSV HR     │───▶│  Usuário (ex: FP008)                                    │││
│  │  │  (PRJ022)   │    │  - name: FP008 → UPN: FP008@fiqueok.com.br              │││
│  │  └─────────────┘    │  - givenName, familyName, email                         │││
│  │                     └───────────────────────┬─────────────────────────────────┘││
│  │                                             │                                    ││
│  │                                             ▼                                    ││
│  │  ┌─────────────────────────────────────────────────────────────────────────────┐││
│  │  │                    Role "Entra ID Basic User"                               │││
│  │  │  ├── Workflow de Aprovação (2 níveis: Manager + Security)                  │││
│  │  │  ├── SoD Rules (ex: AdminInfra + Auditor = BLOCK)                          │││
│  │  │  └── Account Construction (cria conta no Entra ID)                         │││
│  │  └─────────────────────────────────────────────────────────────────────────────┘││
│  │                                             │                                    ││
│  │                                             │ HTTPS + Graph API                  ││
│  │                                             ▼                                    ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    Microsoft Entra ID Free (tenant: fiqueok.com.br)             ││
│  │                                                                                  ││
│  │  ┌─────────────────────────────────────────────────────────────────────────────┐││
│  │  │  Objetos gerenciados (gratuito até 50.000):                                 │││
│  │  │  ├── Usuários (UPN, nome, e-mail)                                           │││
│  │  │  └── Directory Roles (User Administrator, etc.)                             │││
│  │  └─────────────────────────────────────────────────────────────────────────────┘││
│  │                                                                                  ││
│  │  ⚠️ Nenhuma licença de produtividade (M365, EMS) será atribuída.                ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    FUTURO ERP (via SAML/OIDC)                                   ││
│  │                                                                                  ││
│  │  O Entra ID Free atuará como IdP para autenticação.                             ││
│  │  ⚠️ Recursos avançados (Conditional Access, PIM) exigem licenças P1/P2.         ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘

---

## 3. Benefícios Estratégicos (Segurança + FinOps)

|Benefício|Como o PRJ027 entrega|Impacto Financeiro|
|---|---|---|
|**Evita licenças PIM pagas**|O workflow + SoD do midPoint substituem a necessidade do Privileged Identity Management da Microsoft (requer Entra ID P2)|✅ Economia de ~R$ 150/usuario/mês|
|**Detecta Shadow IT**|Reconciliação diária identifica contas criadas manualmente no portal|✅ Evita provisionamento fantasma sem governança|
|**Certificação de acesso**|Campanhas trimestrais substituem ferramentas pagas de recertificação|✅ Economia de ferramentas de terceiros|
|**Auditoria ISO 27001**|Logs de aprovação + justificativa + reconciliação|✅ Reduz custo de auditoria externa|
|**Base para SSO do ERP**|Entra ID Free já suporta SAML/OIDC (protocolos abertos)|✅ Sem custo adicional|

---

## 4. Entregáveis do Projeto

|ID|Entregável|Descrição|
|---|---|---|
|E1|Resource XML|Configuração do conector Graph no midPoint|
|E2|Mapeamento de atributos|UPN, givenName, surname, mail|
|E3|Role XML|`Entra ID Basic User` com account construction|
|E4|Workflow de aprovação|Policy rule com 2 níveis (Manager + Security)|
|E5|Regras SoD|AdminInfra + Auditor (block); Desenvolvedor + Billing (warn)|
|E6|Tarefa de reconciliação|Diária, detecta contas manuais|
|E7|Campanha de certificação|Trimestral, com deadline de 30 dias|
|E8|POP Joiner|Procedimento completo de admissão|

---

## 5. Controles de Auditoria (ISO 27001)

| Controle ISO                 | Evidência gerada                                     | Custo  |
| ---------------------------- | ---------------------------------------------------- | ------ |
| **A.9.1.2** (Acesso a redes) | Log de aprovação antes de atribuir role no Entra     | ✅ Zero |
| **A.9.2.6** (Revogação)      | Reconciliação diária detecta e revoga contas manuais | ✅ Zero |
| **A.9.4.2** (Login seguro)   | SSO futuro via SAML/OIDC                             | ✅ Zero |
| **A.12.4.1** (Registro)      | Logs de auditoria com justificativa e approver       | ✅ Zero |
