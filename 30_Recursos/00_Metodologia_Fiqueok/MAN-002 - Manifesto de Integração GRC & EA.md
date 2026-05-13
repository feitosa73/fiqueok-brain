# 🧬 

## 📋 Controle do Documento
| Atributo             | Detalhe                                      |
| :------------------- | :------------------------------------------- |
| **Versão**           | 1.2 (Definitiva)                             |
| **Responsável**      | Paulo Feitosa (Arquiteto Corporativo & CISO) |
| **Aprovado em**      | 23/12/2025                                   |
| **Ciclo de Revisão** | Anual (Próx: Dez/2026)                       |
| **Classificação**    | Uso Interno - Fiqueok Consultoria            |

---

## 1. O Manifesto de Integração
Na **Fiqueok Consultoria**, rejeitamos a visão tradicional onde "Segurança" (GRC) e "Tecnologia" (Engenharia) operam em silos distintos. Adotamos uma abordagem unificada onde **a Segurança é um atributo de qualidade da Arquitetura**, intrínseca ao design desde a concepção.

Este framework operacionaliza os compromissos assumidos na nossa Política Maior:
> **Vínculo Mandatório:** `[[PSI-001 - Política Geral de Segurança da Informação]]`

## 2. A Pirâmide de Decisão (Cadeia de Rastreabilidade)
Para garantir consistência e auditoria, todas as decisões técnicas devem possuir **Rastreabilidade Vertical**. Nenhuma tecnologia é implementada sem que suporte uma Diretriz, que por sua vez suporta uma Política.



### 2.1. Definição das Camadas

| Nível | Tipo de Artefato | Definição & Propósito | Local Padrão no Obsidian |
| :--- | :--- | :--- | :--- |
| **1. Estratégico** | **POL (Política)** | **O QUE / POR QUÊ.** Define as "Leis" da organização baseadas em riscos e compliance. | `20_Areas/01_SGSI.../01_Governanca...` |
| **2. Tático** | **PAD (Padrão/Diretriz)** | **O CAMINHO.** Define a direção arquitetural e tecnológica aprovada para atender a lei. | `30_Recursos/00_Metodologia...` |
| **3. Técnico** | **STD (Norma Técnica)** | **O COMO (Genérico).** Especificações técnicas reutilizáveis (Hardening, Configs). | `20_Areas/01_SGSI.../02_Normas` |
| **4. Execução** | **ADR/DDR (Decisão)** | **O COMO (Específico).** A escolha pontual para um projeto, justificada pelos itens acima. | `10_Projetos/...` (Início) -> `30_Recursos` (Fim) |

## 3. Matriz de Conexão Obrigatória (Links)
Todo documento criado na Fiqueok deve conter uma seção "Referências Cruzadas" apontando para seu "pai" imediato.

* **Ao escrever um ADR (Decisão),** você deve linkar: `[[PAD Correspondente]]` e `[[MET-001]]`.
* **Ao escrever um PAD (Padrão),** você deve linkar: `[[PSI-001]]` e `[[MET-001]]`.
* **Ao escrever uma POL (Política),** você deve citar: **ISO 27001 / NIST CSF**.

## 4. Princípios Orientadores (Design Principles)

1.  **Compliance by Design:** A tecnologia escolhida deve facilitar o compliance, não dificultá-lo.
    * *Exemplo:* Se a `[[PSI-001 - Política Geral de Segurança]]]` exige auditoria de acesso, a escolha do `[[PAD-001 - Padrão de Identidade e Governança (IGA)]]` (MidPoint) se justifica por ter logs nativos.
2.  **Reuso antes de Compra/Build:** Antes de criar uma nova solução, verifique na pasta `30_Recursos` se já existe um Padrão aprovado.
3.  **Vedação ao "Shadow IT":** Implementações técnicas sem documentação nos níveis 3 e 4 são consideradas Não-Conformidades (NC) imediatas.

## 5. Referências de Mercado
Esta metodologia é uma adaptação híbrida dos seguintes frameworks globais:

* **ISO/IEC 27001:2022:** Sistema de Gestão (Foco em Risco).
* **TOGAF 10:** Arquitetura Corporativa (Foco em Estrutura).
* **SABSA:** Arquitetura de Segurança de Negócio (Foco em Atributos).

---
**Histórico de Revisão:**
* *v1.0:* Criação inicial.
* *v1.2:* Adição da tabela de locais do Obsidian e regras de linkagem (Referência Cruzada).
