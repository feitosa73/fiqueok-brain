# 

**GMUD:** GMUD-002  
**Projeto:** PRJ003 — IGA Greenfield Reference Architecture  
**Tipo:** GMUD Arquitetural / Governança  
**Status:** Planejada  
**Data:** 2026-01-14  
**Solicitante:** Paulo Feitosa (Owner)  
**Executor:** Paulo Feitosa  
**Ambiente:** Living Lab Fiqueok 2.0  
**Prioridade:** Alta  

---

## 1. Objetivo da GMUD

Esta GMUD tem como objetivo **consolidar, registrar e congelar formalmente os Canvases de Decisão de Identidade do PRJ003**, estabelecendo o **contrato semântico obrigatório** que regerá todas as GMUDs técnicas subsequentes.

A GMUD-002 **não implementa automação**, **não cria integrações** e **não executa mudanças técnicas**.  
Seu papel é **arquitetural e de governança**.

---

## 2. Contexto

A GMUD-025 declarou formalmente a criação do PRJ003 em ambiente **greenfield**, estabelecendo que decisões de arquitetura de identidade deveriam preceder qualquer automação técnica.

Como desdobramento dessa decisão, foram criados os seguintes Canvases de Decisão:

- CAN-ID-001 — Identidade Canônica
- CAN-ID-002 — Autoridade de Dados de Identidade
- CAN-ID-003 — Estados da Identidade

Esta GMUD consolida esses artefatos como **fonte oficial de verdade semântica** do PRJ003.

---

## 3. Escopo da GMUD

### 3.1. Incluído no Escopo

- Consolidação formal dos Canvases de Decisão de Identidade
- Registro dos Canvases como artefatos oficiais do PRJ003
- Congelamento do contrato semântico de identidade
- Estabelecimento dos Canvases como *gate obrigatório* para GMUDs técnicas

### 3.2. Fora do Escopo

- Configuração de conectores
- Integração com HR, AD ou aplicações
- Implementação de fluxos JML
- Ajustes técnicos em midPoint
- Automação de provisionamento

---

## 4. Canvases Consolidados

Os seguintes Canvases passam a ter **status oficial e vinculante** no PRJ003:

### 4.1. CAN-ID-001 — Identidade Canônica
Define:
- Entidade canônica de identidade
- Identificador canônico
- Princípios de independência de sistemas
- Relação da identidade com GMUDs

### 4.2. CAN-ID-002 — Autoridade de Dados de Identidade
Define:
- Autoridade por atributo
- Precedência de dados
- Resolução de conflitos
- Papel do midPoint como orquestrador semântico

### 4.3. CAN-ID-003 — Estados da Identidade
Define:
- Estados canônicos da identidade
- Significado semântico de cada estado
- Separação entre estados de identidade e estados técnicos
- Princípios de transição de estado

---

## 5. Decisão Formal Consolidada

A partir desta GMUD, fica formalmente estabelecido que:

- Nenhuma GMUD técnica poderá ser executada no PRJ003 sem aderência aos Canvases CAN-ID
- Qualquer alteração nos Canvases:
  - exige ADR formal
  - não pode ocorrer durante GMUD técnica
- Os Canvases constituem o **contrato semântico oficial da identidade**

---

## 6. Impactos

### 6.1. Impactos Positivos

| Área | Impacto |
|----|--------|
| Governança | Eliminação de decisões implícitas |
| Arquitetura | Base semântica estável |
| Operação | Redução de retrabalho |
| GMUDs | Execução previsível |
| Aprendizado | Reutilização dos artefatos |

### 6.2. Impactos Negativos

- Nenhum impacto técnico imediato
- Nenhuma indisponibilidade de sistemas

---

## 7. Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-----|--------------|--------|----------|
| GMUD técnica sem aderência semântica | Baixa | Alto | Gate via GMUD-002 |
| Alteração informal de decisões | Baixa | Alto | Uso obrigatório de ADR |
| Interpretação equivocada de estados | Baixa | Médio | CAN-ID-003 |

---

## 8. Critérios de Sucesso da GMUD

Esta GMUD será considerada bem-sucedida quando:

- CAN-ID-001 estiver registrado e referenciado
- CAN-ID-002 estiver registrado e referenciado
- CAN-ID-003 estiver registrado e referenciado
- Os Canvases estiverem armazenados em:
Fiqueok_Brain/10_Projetos/PRJ003 - IGA-GREENFIELD/20_Governanca_e_Decisoes/

- As GMUDs técnicas passarem a referenciar explicitamente estes Canvases

---

## 9. Plano de Rollback

**Não aplicável.**

Esta GMUD é exclusivamente declarativa e de governança, não realizando alterações técnicas ou operacionais.

---

## 10. Documentos Relacionados

- GMUD-025 — Declaração Formal do PRJ003  
- CAN-ID-001 — Identidade Canônica  
- CAN-ID-002 — Autoridade de Dados de Identidade  
- CAN-ID-003 — Estados da Identidade  
- DOC-ARC-000 — Fundamentos de Decisão em Arquitetura de Identidade  
- DOC-ARC-001 — Problemas de Decisão Observados em Arquitetura de Identidade  

---

## 11. Aprovação

| Papel | Nome | Status |
|-----|------|-------|
| Solicitante | Paulo Feitosa | Aprovado |
| Executor | Paulo Feitosa | Aprovado |
| Aprovador Final | Paulo Feitosa | Aprovado |

---

## 12. Controle de Versão

| Versão | Data | Autor | Mudança |
|------|------|------|--------|
| 1.0 | 2026-01-14 | Paulo Feitosa | Criação da GMUD-002 |

---

**Repositório:** Obsidian Vault — Fiqueok_Brain  
**Caminho:** `/10_Projetos/PRJ003 - IGA-GREENFIELD/40_GMUDs/GMUD-002.md`
