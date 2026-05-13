# 🏛️ 

**Local:** `30_Recursos/00_Metodologia_Fiqueok/PAD-001.md`
**Tipo:** Padrão Arquitetural (Enterprise Standard)
**Aplicabilidade:** Todos os projetos de infraestrutura gerenciados pela Fiqueok.

---

## 1. Diretriz Estratégica (O "Norte")
A Fiqueok adota uma postura de **"Governance First"**. Em qualquer projeto onde exista um diretório de usuários (Active Directory, LDAP, Entra ID), é **mandatória** a existência de uma camada de Governança (IGA) superior.

## 2. Decisão Tecnológica Padrão
Para operacionalizar esta diretriz, a tecnologia homologada como padrão é a plataforma **MidPoint (Evolveum)**.

### Por que esta escolha? (Racional)
* **Conformidade:** Garante nativamente os controles da ISO 27001 (A.9.2 e A.9.4).
* **Escalabilidade:** Permite gerenciar desde pequenos laboratórios até grandes corporações com o mesmo stack.
* **Independência:** Evita scripts manuais (PowerShell/Python) que geram dívida técnica e dependência de conhecimento tácito.

## 3. Regras de Implementação
1.  **Fonte Autoritativa:** Todo projeto deve identificar claramente a origem dos dados (RH, Planilha, API). O AD nunca deve ser a origem.
2.  **Fluxo Unidirecional:** O fluxo de dados deve ser sempre: `Origem -> IGA -> Destino (AD)`.
3.  **Vedação:** O uso de scripts diretos para criação de usuários é considerado "Débito Técnico" e só deve ser utilizado em Provas de Conceito (PoCs) descartáveis.

---

## 4. Histórico de Decisões (DDRs vinculados)
* *23/12/2025:* A decisão de abandonar scripts em favor do MidPoint foi tomada no contexto do PRJ-002 e promovida a padrão global.