# 

**Projeto:** PRJ003 — IGA Greenfield Reference Architecture  
**Tipo:** Canvas de Decisão em Arquitetura de Identidade  
**Status:** Consolidado  
**Origem da Decisão:** GMUD-025  
**Data:** 2026-01-14  
**Owner:** Paulo Feitosa  

---

## Objetivo do Canvas

Este canvas consolida a **Identidade Canônica do PRJ003**, formalmente declarada na GMUD-025, servindo como **gate arquitetural obrigatório** para qualquer GMUD técnica ou decisão de integração IGA no projeto.
## 1. Contexto

Este documento materializa a **Identidade Canônica do PRJ003**, conforme declarada formalmente na GMUD-025.

A Identidade Canônica define o **modelo semântico central de identidade**, independente de sistemas, conectores ou implementações técnicas.

Nenhuma automação ou GMUD técnica poderá ser executada no PRJ003 sem aderência a este modelo.

---

## 2. Natureza da Identidade Canônica

A Identidade Canônica do PRJ003 possui as seguintes características:

- **Greenfield** — não herda identificadores, correlações ou decisões do PRJ002
- **IGA-first** — midPoint é o núcleo lógico da identidade
- **Semântica explícita** — contratos de identidade documentados antes da técnica
- **Independente de sistemas** — não pertence a AD, HR ou qualquer fonte externa
- **Rastreável** — toda decisão tem origem documentada

---

## 3. Entidade Canônica de Identidade

A entidade canônica representa uma **Pessoa** no contexto organizacional.

Ela existe independentemente de:
- vínculos técnicos
- contas
- permissões
- estados de provisionamento

A identidade canônica **não é uma conta**, **não é um usuário técnico** e **não é um registro de sistema**.

---

## 4. Identificador Canônico

O PRJ003 estabelece que:

- Existe **um identificador canônico único por identidade**
- O identificador:
  - é criado e mantido no domínio IGA
  - não depende de AD, HR ou sistemas externos
  - não muda ao longo do ciclo de vida
- Identificadores técnicos externos **não são âncoras de identidade**

Este identificador é a **âncora semântica** de toda correlação.

---

## 5. Autoridade de Dados (conceito)

A Identidade Canônica assume que:

- Não existe uma única fonte soberana para todos os atributos
- Cada atributo deve possuir:
  - uma autoridade primária definida
  - precedência clara em caso de conflito
- A definição de autoridade:
  - é arquitetural
  - precede integração
  - será documentada em canvas específico

---

## 6. Estados da Identidade

A identidade canônica possui **estados próprios**, independentes de contas técnicas.

Estados previstos (nível conceitual):

- Pré-criada
- Ativa
- Suspensa
- Desligada
- Órfã (sem vínculo válido)

Estados técnicos de sistemas **não substituem** estados da identidade.

---

## 7. Relação com GMUDs

- Esta Identidade Canônica é **input obrigatório** para:
  - GMUDs técnicas
  - desenho de conectores
  - correlação de identidades
- Alterações neste documento:
  - exigem ADR formal
  - não podem ocorrer “em voo”

---

## 8. Referências

- GMUD-025 — Declaração Formal do PRJ003  
- DOC-ARC-000 — Fundamentos de Decisão em Arquitetura de Identidade  
- DOC-ARC-001 — Problemas de Decisão Observados em Arquitetura de Identidade  

---

## 9. Controle de Versão

| Versão | Data | Autor | Mudança |
|------|------|------|--------|
| 1.0 | 2026-01-14 | Paulo Feitosa | Extração direta da GMUD-025 |
