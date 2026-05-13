# 📜

## 📋 Controle do Documento
| Atributo | Detalhe |
| :--- | :--- |
| **Versão** | 1.2 (Definitiva) |
| **Autoridade** | Diretoria Executiva (CEO) |
| **Aprovado em** | 23/12/2025 |
| **Revisão Prevista** | Dez/2026 (Anual) |
| **Abrangência** | Todos os Colaboradores, Terceiros e Sistemas |

---

## 1. Propósito
Estabelecer as diretrizes corporativas inegociáveis para proteção dos ativos de informação da **Fiqueok Consultoria**, garantindo a Confidencialidade, Integridade e Disponibilidade (CID) dos dados.

## 2. Princípios Fundamentais
1.  **Segurança como Enabler:** A segurança deve viabilizar o negócio, não impedi-lo.
2.  **Least Privilege:** O acesso é concedido no nível mínimo necessário.
3.  **Need-to-know:** O acesso é restrito àqueles que precisam da informação para sua função.
4.  **Rastreabilidade:** Toda ação crítica deve ser auditável e atribuível a uma identidade única.

---

## 3. Diretrizes Gerais (Os 10 Mandamentos)
*(Mantivemos os itens operacionais anteriores, pois são vitais para o dia a dia)*

1.  **Propriedade da Informação:** Dados corporativos são da Fiqueok, não do usuário.
2.  **Identificação Única:** Proibido uso de contas compartilhadas.
3.  **Gestão de Senhas:** Obrigatório uso de Cofre de Senhas e MFA onde disponível.
4.  **Mesa e Tela Limpa:** Bloqueio de tela (Win+L) ao se ausentar é mandatório.
5.  **Relato de Incidentes:** Dever de reportar qualquer anomalia em até 1 hora.
6.  **Uso de Ativos:** Proibido uso de recursos corporativos para fins ilícitos ou pirataria.
7.  **Shadow IT:** Proibida a contratação de softwares/SaaS sem homologação técnica.
8.  **Backup:** Dados críticos devem residir em servidores homologados, nunca apenas no endpoint.
9.  **Privacidade:** Respeito integral à LGPD no tratamento de dados pessoais.
10. **Monitoramento:** A Fiqueok reserva-se o direito de auditar logs para garantir conformidade.

---

## 4. Diretrizes de Arquitetura e Desenvolvimento (NOVO)
Esta seção estabelece o vínculo formal com a Arquitetura Corporativa (EA).

### 4.1. Security by Design & Default
A segurança da informação deve ser integrada no início de qualquer projeto de tecnologia, e não adicionada ao final.
* **Mandato:** Nenhum sistema entrará em produção sem passar pelo fluxo de aprovação definido na Metodologia Corporativa.
    * *Referência:* `[[MET-001 v1.2 - Framework de Integração GRC & EA 1]]]`

### 4.2. Conformidade Arquitetural
A implementação de novas tecnologias deve obedecer estritamente aos Padrões Arquiteturais (PADs) vigentes. Desvios devem ser justificados via documento de decisão (DDR).
* *Vínculo:* O descumprimento de um Padrão (ex: `[[PAD-001 - v1.2 - Padrão de Identidade e Governança (IGA)]]`) constitui violação desta Política.

---

## 5. Violações e Sanções
O não cumprimento desta política e de seus padrões vinculados pode acarretar medidas disciplinares, incluindo advertência, suspensão ou rescisão contratual por justa causa.

## 6. Referências Normativas
* **ABNT NBR ISO/IEC 27001:2022:**
    * A.5.1 (Políticas de segurança da informação)
    * A.5.8 (Segurança da informação no gerenciamento de projetos)
    * A.8.25 (Ciclo de vida de desenvolvimento seguro)
* **Framework Interno:** `[[MET-001 v1.2 - Framework de Integração GRC & EA 1]]]`