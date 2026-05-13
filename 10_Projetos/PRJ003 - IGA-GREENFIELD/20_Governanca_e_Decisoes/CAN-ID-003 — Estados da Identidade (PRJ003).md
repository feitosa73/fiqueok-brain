# 

**Projeto:** PRJ003 — IGA Greenfield Reference Architecture  
**Tipo:** Canvas de Decisão em Arquitetura de Identidade  
**Status:** Consolidado  
**Origem da Decisão:** GMUD-025  
**Dependências:**  
- CAN-ID-001 — Identidade Canônica  
- CAN-ID-002 — Autoridade de Dados  
**Data:** 2026-01-14  
**Owner:** Paulo Feitosa  

---

## Objetivo do Canvas

Este canvas define os **Estados da Identidade Canônica do PRJ003**, estabelecendo:

- quais estados existem
- o significado semântico de cada estado
- o que **os estados representam** (e o que não representam)

Este Canvas é **gate arquitetural obrigatório** antes de:
- definição de fluxos JML
- automação de provisionamento
- correlação com estados técnicos de sistemas
- qualquer GMUD que trate de lifecycle de identidade

---

## 1. Contexto

No ciclo anterior do Living Lab (PRJ002), observou-se confusão recorrente entre:

- estado da identidade
- estado de conta técnica
- estado operacional de sistemas

Essa confusão levou a:
- decisões inconsistentes de provisionamento
- correlação frágil
- automação baseada em efeitos colaterais

O PRJ003 estabelece que:
> **Estados de Identidade são conceitos semânticos próprios, independentes de sistemas.**

Este canvas materializa essa decisão.

---

## 2. Princípios dos Estados de Identidade

A arquitetura de identidade do PRJ003 adota os seguintes princípios:

1. Estados pertencem à **identidade**, não às contas
2. Estados não são inferidos automaticamente de sistemas
3. Estados técnicos **não redefinem** estados da identidade
4. Estados existem mesmo sem contas provisionadas
5. Transições de estado são decisões explícitas
6. Estados precedem automação

---

## 3. Estados Canônicos da Identidade

Os seguintes estados canônicos são definidos para o PRJ003:

### 3.1 Pré-criada
- Identidade registrada no domínio IGA
- Pode não possuir contas técnicas
- Ainda não ativa no contexto organizacional

### 3.2 Ativa
- Identidade válida no contexto organizacional
- Pode possuir uma ou mais contas técnicas
- Elegível para provisionamento e acessos

### 3.3 Suspensa
- Identidade temporariamente inativa
- Contas técnicas **podem existir**, mas não definem este estado
- Reversível mediante decisão explícita

### 3.4 Desligada
- Identidade não mais válida no contexto organizacional
- Não elegível para novos acessos
- Estado final do ciclo regular

### 3.5 Órfã
- Identidade sem vínculo válido com fonte de negócio
- Pode indicar falha de correlação ou exceção operacional
- Exige análise e tratamento explícito

---

## 4. Estados NÃO contemplados

Este Canvas define explicitamente que **não são estados da identidade**:

- habilitado / desabilitado de conta
- bloqueado por senha
- expirado em sistema técnico
- ativo/inativo em AD, HR ou aplicação

Esses são **estados técnicos**, não semânticos.

---

## 5. Relação entre Estados de Identidade e Sistemas

- Estados da identidade **não são derivados automaticamente** de sistemas
- Sistemas podem:
  - refletir estados
  - executar ações decorrentes de estados
- Sistemas **não definem** estados de identidade

O midPoint atua como:
- **orquestrador de transições**
- **guardião da semântica**
- **executor de regras derivadas**

---

## 6. Decisões Congeladas por este Canvas

Este Canvas congela as seguintes decisões:

- Estados da identidade são independentes de contas
- Estados técnicos não redefinem identidade
- “Órfã” é um estado canônico válido
- Transições exigem decisão explícita
- Estados precedem fluxos JML

Qualquer alteração exige **ADR formal**.

---

## 7. Relação com GMUDs

Este Canvas é **pré-requisito obrigatório** para:

- GMUDs de definição de fluxos JML
- GMUDs de automação de provisionamento
- GMUDs de offboarding
- GMUDs de tratamento de exceções
- GMUDs de correlação e reconciliação

---

## 8. Referências

- GMUD-025 — Declaração Formal do PRJ003  
- CAN-ID-001 — Identidade Canônica  
- CAN-ID-002 — Autoridade de Dados  
- DOC-ARC-000 — Fundamentos de Decisão em Arquitetura de Identidade  
- DOC-ARC-001 — Problemas de Decisão Observados em Arquitetura de Identidade  

---

## 9. Controle de Versão

| Versão | Data | Autor | Mudança |
|------|------|------|--------|
| 1.0 | 2026-01-14 | Paulo Feitosa | Criação do Canvas CAN-ID-003 |
