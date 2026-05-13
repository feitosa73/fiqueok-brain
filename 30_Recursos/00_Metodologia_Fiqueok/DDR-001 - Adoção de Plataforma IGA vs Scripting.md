# 🏗️ 

## 📋 Controle do Documento
| Atributo | Detalhe |
| :--- | :--- |
| **Versão** | 1.2 (Definitiva) |
| **Decisor** | Paulo Feitosa (Arquiteto/CISO) |
| **Data da Decisão** | 23/12/2025 |
| **Status** | ✅ Aprovado / Em Implementação |
| **Contexto** | PRJ-002 (Infraestrutura Fiqueok) |

---

## 1. Rastreabilidade e Compliance
Esta Decisão de Design (Design Decision Record) está vinculada hierarquicamente aos seguintes documentos mestres da Fiqueok:

### 🔗 Referências Cruzadas Obrigatórias
* **Segue a Metodologia:** `[[MET-001 v1.2 - Framework de Integração GRC & EA 1]]]`
* **Implementa o Padrão:** `[[PAD-001 - v1.2 - Padrão de Identidade e Governança (IGA)]]]`
* **Justificativa de Negócio:** Atende aos requisitos de auditoria e controle de acesso da ISO 27001 (A.9.2).

---

## 2. Contexto do Problema
A Fiqueok necessita estabelecer um processo robusto para gerenciar o Ciclo de Vida de Identidades (JML - Joiner, Mover, Leaver) no Active Directory. A solução precisa garantir que apenas usuários autorizados tenham acesso e que todos os acessos sejam auditáveis desde a origem.

## 3. Opções Avaliadas

### Opção A: Automação via Scripts (PowerShell/Python)
Desenvolvimento de scripts customizados que leem arquivos CSV do RH e criam usuários no AD.
* **Prós:** Rápido de implementar inicialmente; baixo consumo de recursos de hardware.
* **Contras:**
    * Criação de "Dívida Técnica" e dependência de manutenção manual.
    * Falta de interface amigável para aprovação de gestores.
    * Trilha de auditoria frágil (logs de texto dispersos).
    * Viola o princípio de *Governance First* da Fiqueok.

### Opção B: Plataforma IGA Open Source (MidPoint) - **[SELECIONADA]**
Implementação da solução *Evolveum MidPoint* rodando em container Docker sobre Linux.
* **Prós:**
    * Conformidade nativa com `[[PAD-001 - Padrao de Identidade e Governanca]]`.
    * Interface Web para solicitação e revisão de acessos.
    * Separação de Funções (SoD) nativa.
    * Reconciliação automática (detecta e corrige alterações indevidas no AD).
* **Contras:** Maior complexidade de infraestrutura inicial (requer servidor Linux dedicado).

## 4. Decisão
Optou-se pela **Opção B (MidPoint)**.

A decisão prioriza a **Maturidade de Governança** sobre a simplicidade de implementação. Aceita-se o custo inicial de configurar um servidor Linux (`IGA-P-01`) em troca da garantia de auditabilidade e escalabilidade futura.

## 5. Consequências Técnicas (Impacto)
* **Infraestrutura:** Necessidade de provisionar VM Linux (Ubuntu Server) no Hyper-V (GMUD-006).
* **Skills:** Necessidade de conhecimentos em Docker e configuração de recursos XML/JSON do MidPoint.
* **Processo:** O Active Directory passa a operar em modo "Target" (Escravo), sendo proibida a criação manual de usuários.

---
**Status da Implementação:**
Aguardando execução da GMUD-006 (Provisionamento do Servidor IGA).
