# 

**Projeto:** PRJ003 — IGA Greenfield Reference Architecture  
**Tipo:** Canvas de Decisão em Arquitetura de Identidade  
**Status:** Consolidado  
**Origem da Decisão:** GMUD-025  
**Dependência:** CAN-ID-001 — Identidade Canônica  
**Data:** 2026-01-14  
**Owner:** Paulo Feitosa  

---

## Objetivo do Canvas

Este canvas define o **modelo de Autoridade de Dados de Identidade do PRJ003**, estabelecendo **quem é responsável por cada atributo**, como conflitos são resolvidos e quais princípios regem a precedência de dados.

Este Canvas é **gate obrigatório** antes de:
- configuração de conectores
- mapeamento de atributos
- correlação de identidades
- qualquer GMUD técnica envolvendo dados de identidade

---

## 1. Contexto

Durante o ciclo anterior do Living Lab (PRJ002), observou-se que **falhas de integração e inconsistências de identidade** não eram causadas por conectores, mas por **ausência de definição clara de autoridade de dados**.

O PRJ003, como ambiente greenfield, adota o princípio de que:
> **autoridade de dados é decisão arquitetural, não detalhe técnico.**

Este canvas materializa esse princípio.

---

## 2. Princípios de Autoridade de Dados

A arquitetura de identidade do PRJ003 adota os seguintes princípios:

1. **Não existe fonte soberana única**
2. **Autoridade é definida por atributo**, não por sistema
3. **Precedência deve ser explícita**
4. **midPoint não “inventa” dados**
5. **Conflitos são resolvidos por regra, não por ordem de chegada**
6. **Autoridade precede integração técnica**

---

## 3. Categorias de Fontes de Dados

As fontes de dados de identidade são classificadas conceitualmente em:

- **Fontes de Negócio**
  - Ex.: HR, sistemas administrativos
- **Fontes Técnicas**
  - Ex.: Active Directory, LDAP
- **Fonte de Identidade Canônica**
  - midPoint (domínio IGA)

Essa classificação **não implica precedência automática**.

---

## 4. Autoridade por Categoria de Atributo (nível conceitual)

| Categoria de Atributo | Autoridade Primária | Observações |
|----------------------|--------------------|-------------|
| Identificador Canônico | IGA (midPoint) | Criado e mantido internamente |
| Dados pessoais básicos (nome, sobrenome) | Fonte de Negócio | Não alterados por fontes técnicas |
| Dados organizacionais (cargo, área) | Fonte de Negócio | Alterações disparam eventos |
| Credenciais técnicas | Sistema Técnico | Não redefinem identidade |
| Estados de conta | Sistema Técnico | Não alteram estado da identidade |
| Estado da identidade | IGA (midPoint) | Definido no CAN-ID-003 |

> **Nota:** Esta tabela é conceitual. Detalhamento por atributo será feito em artefato derivado.

---

## 5. Precedência e Resolução de Conflitos

Em caso de conflito entre fontes:

1. **Prevalece a autoridade definida por atributo**
2. Se a autoridade estiver indisponível:
   - o dado **não é sobrescrito**
   - o conflito é registrado
3. Fontes técnicas **nunca sobrescrevem dados de negócio**
4. midPoint **não normaliza dados sem regra explícita**

---

## 6. Papel do midPoint na Autoridade de Dados

O midPoint atua como:

- **orquestrador**, não como “dono absoluto” dos dados
- **guardião da semântica**
- **executor de regras de precedência**

O midPoint:
- pode armazenar dados
- pode consolidar visões
- **não redefine autoridade sem decisão formal**

---

## 7. Decisões Congeladas por este Canvas

Este Canvas congela as seguintes decisões:

- Autoridade de dados é definida por atributo
- Não existe fonte soberana única
- Fontes técnicas não sobrescrevem dados de negócio
- Conflitos não são resolvidos implicitamente
- Precedência é decisão arquitetural

Qualquer alteração exige **ADR formal**.

---

## 8. Relação com GMUDs

Este Canvas é **pré-requisito obrigatório** para:

- GMUDs de integração com HR
- GMUDs de integração com AD / LDAP
- GMUDs de correlação e reconciliação
- GMUDs de ajustes de mapeamento de atributos

---

## 9. Referências

- GMUD-025 — Declaração Formal do PRJ003  
- CAN-ID-001 — Identidade Canônica  
- DOC-ARC-000 — Fundamentos de Decisão em Arquitetura de Identidade  
- DOC-ARC-001 — Problemas de Decisão Observados em Arquitetura de Identidade  

---

## 10. Controle de Versão

| Versão | Data | Autor | Mudança |
|------|------|------|--------|
| 1.0 | 2026-01-14 | Paulo Feitosa | Criação do Canvas CAN-ID-002 |
