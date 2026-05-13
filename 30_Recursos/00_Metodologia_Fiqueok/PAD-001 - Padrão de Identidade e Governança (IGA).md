# 🏛️

## 📋 Controle do Documento
| Atributo | Detalhe |
| :--- | :--- |
| **Versão** | 1.2 (Definitiva) |
| **Responsável** | Paulo Feitosa (CISO & Arquiteto) |
| **Aprovado em** | 23/12/2025 |
| **Ciclo de Revisão** | Semestral |
| **Classificação** | Uso Interno - Fiqueok Consultoria |

---

## 1. Contexto e Rastreabilidade
Este padrão técnico não existe no vácuo. Ele foi desenhado para atender requisitos específicos de negócio e compliance definidos na nossa metodologia e política superior.

### 🔗 Referências Cruzadas Obrigatórias
* **Segue a Metodologia:** `[[MET-001 v1.2 - Framework de Integração GRC & EA 1]]]`
* **Responde à Política:** `[[PSI-001 - Política Geral de Segurança]]`
    * *Capítulo:* Controle de Acesso (Requisito de Identificação Única e Gestão de Privilégios).
* **Compliance ISO 27001:** Controles A.9.2 (Gerenciamento de acesso) e A.9.4 (Gerenciamento de informações de autenticação).

---

## 2. Diretriz Estratégica: "Governance First"
A Fiqueok adota uma postura mandatória de Governança de Identidade.
Em qualquer projeto de infraestrutura onde exista um diretório de usuários (Active Directory, LDAP, Entra ID), é **proibido** tratar a identidade apenas como um "objeto técnico".

**A Regra de Ouro:**
> "Nenhuma conta de usuário deve ser criada manualmente no sistema de destino (Target System) sem que tenha nascido previamente em um processo governado de IGA."

## 3. Padrão Tecnológico Homologado (Technical Standard)
Para operacionalizar esta diretriz, a stack tecnológica padrão definida para clientes e laboratórios Fiqueok é:

| Componente | Tecnologia Padrão | Justificativa Arquitetural |
| :--- | :--- | :--- |
| **Plataforma IGA** | **MidPoint (Evolveum)** | Open Source, suporte nativo a Auditoria, Fluxos de Aprovação e Reconciliação automática. |
| **Banco de Dados** | **PostgreSQL** | Robustez, licença livre e alta compatibilidade com containers. |
| **Deployment** | **Docker / Docker Compose** | Portabilidade e facilidade de atualização (Imutabilidade). |

### 3.1. Por que MidPoint e não Scripts? (Rationale)
Esta decisão visa mitigar o **Risco de Dependência de Conhecimento Tácito**. Scripts customizados (PowerShell/Python) tendem a se tornar "caixas pretas" não auditáveis. O uso de uma plataforma de mercado garante:
1.  **Interface Gráfica** para auditores e gestores (não técnicos).
2.  **Logs de Auditoria** à prova de manipulação.
3.  **Separação de Funções (SoD):** Quem pede o acesso não é quem aprova.

## 4. Regras de Implementação (Implementation Rules)

1.  **Fonte Autoritativa (Source of Truth):**
    Todo projeto deve identificar claramente a origem do dado (RH, Planilha Mestra, API). O Active Directory é sempre **Escravo** (Downstream), nunca Mestre.

2.  **Fluxo Unidirecional de Dados:**
    `[Fonte Autoritativa]` ➔ `[MidPoint]` ➔ `[Active Directory]`
    * Qualquer alteração feita diretamente no AD será considerada "Drift" (Desvio) e deve ser corrigida pela rotina de reconciliação do MidPoint.

3.  **Ciclo JML (Joiner, Mover, Leaver):**
    A automação deve cobrir todo o ciclo de vida. O processo de **Leaver** (Desligamento) deve ser prioridade zero para evitar contas órfãs ativas.

---

## 5. Artefatos Relacionados
Documentos que derivam deste padrão:
* Decisão de Projeto: `[[DDR-001 - Estrategia de Identidade]]` (Adoção inicial no PRJ-002).
* Procedimentos (Futuros): *POP-IAM-001 - Onboarding de Colaboradores via MidPoint*.
