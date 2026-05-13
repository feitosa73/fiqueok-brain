---
**GMUD:** GMUD-025  
**Título:** Declaração Formal do Projeto PRJ003 — IGA Greenfield Reference Architecture  
**Tipo:** GMUD Estratégica / Organizacional  
**Status:** Aprovada  
**Data de Criação:** 13/01/2026  
**Data de Aprovação:** 13/01/2026  
**Solicitante:** Paulo Feitosa (Owner)  
**Executor Responsável:** Paulo Feitosa  
**Aprovador:** Paulo Feitosa  
**Projetos Impactados:**  
- PRJ002 — Infraestrutura Fiqueok (pausa controlada)  
- PRJ003 — IGA Greenfield Reference Architecture (criação)  

**Prioridade:** Alta  
**Janela de Execução:** Declarativa (sem execução técnica)  
**Risco:** Baixo (governança e estruturação)  

---

## 1. Identificação da GMUD

Esta GMUD não executa mudanças técnicas em infraestrutura ou sistemas. Seu propósito é exclusivamente organizacional e arquitetural:

- Formalizar a criação do **PRJ003 — IGA Greenfield Reference Architecture**
- Declarar a pausa controlada do **PRJ002 — Infraestrutura Fiqueok** na GMUD-024
- Estabelecer escopo macro de atividades do PRJ003
- Reconhecer artefatos arquiteturais como entregáveis válidos do ciclo de aprendizado do PRJ002

**Natureza da GMUD:** Estratégica, declarativa, de governança.

---

## 2. Contexto e Motivação

### 2.1. Situação Atual do PRJ002

O PRJ002 (Infraestrutura Fiqueok) atingiu a GMUD-024 com mais de 20 GMUDs executadas, implementando integração entre OrangeHRM, midPoint e Active Directory em ambiente brownfield (infraestrutura legada preexistente).

Durante esse ciclo, observou-se que:

- **Falhas recorrentes não eram de natureza técnica**, mas de decisões arquiteturais de identidade não formalizadas previamente (conforme documentado em DOC-ARC-000 e DOC-ARC-001)
- **Decisões críticas foram tomadas "em voo"** durante implementação de GMUDs técnicas, sem artefatos de governança prévios
- **Ambiente brownfield introduzia complexidade adicional**, dificultando isolamento de problemas de modelagem vs. problemas de integração com sistemas legados

### 2.2. Aprendizados Observados

Os documentos fundacionais criados recentemente (DOC-ARC-000, DOC-ARC-001, template base do Canvas de Decisão em Arquitetura de Identidade) estabeleceram que:

- Decisões de arquitetura de identidade devem preceder automação
- Contratos semânticos (identificador canônico, autoridade de dados, estados de identidade) são pré-requisitos para integrações IGA consistentes
- Ambientes greenfield permitem validar esses princípios sem interferência de dívidas técnicas ou decisões legadas

### 2.3. Decisão Estratégica

Foi decidido **pausar conscientemente o PRJ002** na GMUD-024 para:

1. Consolidar aprendizados arquiteturais em novo projeto dedicado
2. Validar princípios de arquitetura de identidade em ambiente greenfield controlado
3. Criar referência arquitetural reutilizável para futuras retomadas do PRJ002 ou novos projetos

Essa pausa **não é abandono, rollback ou falha**. É maturação técnica intencional.

---

## 3. Decisão de Pausa do PRJ002

### 3.1. Estado do PRJ002 no Momento da Pausa

- **Última GMUD executada:** GMUD-024 (encerrada conforme REL-GMUD-024 v1.0)
- **Status da infraestrutura:** Operacional, mas com decisões arquiteturais pendentes
- **Histórico de GMUDs:** Preservado integralmente no Obsidian
- **Documentação:** Completa e rastreável
- **Artefatos técnicos:** Mantidos sem alteração

### 3.2. Formalização da Pausa

O PRJ002 é oficialmente pausado a partir da aprovação desta GMUD-025, com as seguintes garantias:

- **Nenhum rollback será executado** — infraestrutura permanece no estado da GMUD-024
- **Histórico de GMUDs preservado** — toda documentação continua disponível para consulta
- **Lições aprendidas registradas** — problemas de decisão observados documentados em DOC-ARC-001
- **Retomada futura planejada** — PRJ002 poderá ser retomado após validação de arquitetura no PRJ003

### 3.3. Reconhecimento do REL-GMUD-024

**A GMUD-025 reconhece formalmente o REL-GMUD-024 (já existente) como registro válido de encerramento controlado do ciclo atual do PRJ002**, não havendo criação ou modificação desse relatório no escopo desta GMUD.

O REL-GMUD-024 v1.0:
- Documenta formalmente o encerramento controlado da GMUD-024
- Consolida lições aprendidas do ciclo atual do PRJ002
- Apresenta análise de causa raiz e justificativa de governança
- Serve como referência histórica para o PRJ003

### 3.4. Entregáveis Finais do PRJ002 (Ciclo Atual)

Os seguintes artefatos são considerados entregáveis válidos do PRJ002 até a GMUD-024:

- DOC-ARC-000 — Fundamentos de Decisão em Arquitetura de Identidade
- DOC-ARC-001 — Problemas de Decisão Observados em Arquitetura de Identidade
- Template base do Canvas de Decisão em Arquitetura de Identidade (CAN-ID)
- Conjunto de GMUDs 001-024 documentadas
- REL-GMUD-024 v1.0 (encerramento controlado)

**Critério de aceite desses entregáveis:** Documentação completa, rastreável e reutilizável em projetos futuros.

---

## 4. Declaração Formal de Criação do PRJ003

### 4.1. Nome e Código do Projeto

**Nome:** IGA Greenfield Reference Architecture  
**Código:** PRJ003  
**Tipo:** Projeto de Arquitetura de Referência  
**Ambiente:** Greenfield (nova infraestrutura, sem dependências legadas)  

### 4.2. Objetivo do PRJ003

Implementar uma **arquitetura de identidade de referência** em ambiente greenfield, validando princípios arquiteturais estabelecidos em DOC-ARC-000 e materializando decisões formais através de canvases antes de qualquer automação técnica.

### 4.3. Princípios Arquiteturais do PRJ003

1. **Decisão precede automação** — nenhuma GMUD técnica sem canvases validados
2. **IGA-first design** — midPoint como núcleo da arquitetura, não como camada adicional
3. **Contratos semânticos explícitos** — identificador canônico, autoridade de dados e estados de identidade documentados antes de conectores
4. **Rastreabilidade total** — toda decisão registrada em ADR ou canvas
5. **Ambiente isolado** — sem reaproveitamento automático de configurações do PRJ002

### 4.4. Independência do PRJ003

O PRJ003:

- **Não herda configurações técnicas do PRJ002** (nova infraestrutura, novo AD, novo OrangeHRM, novo midPoint)
- **Não herda numeração de GMUDs** (inicia em GMUD-001)
- **Pode replicar estrutura organizacional e documental** do PRJ002, se aplicável (ex: templates, processos)
- **Pode referenciar lições aprendidas** do PRJ002 documentadas em DOC-ARC-001 e REL-GMUD-024

---

## 5. Escopo Macro de Atividades do PRJ003

As seguintes atividades são planejadas para o PRJ003, sem ordem de execução definida neste momento:

### 5.1. Governança e Estruturação

- Criação da estrutura do projeto no Obsidian (`/10-Projetos/PRJ003-IGA-GREENFIELD/`)
- Definição de templates de documentação específicos do PRJ003
- Estabelecimento de critérios de aceite para GMUDs do PRJ003

### 5.2. Arquitetura de Identidade

- Criação do Canvas de Identidade Canônica (CAN-ID-001)
- Criação do Canvas de Autoridade de Dados (CAN-ID-002)
- Criação do Canvas de Estados de Ciclo de Vida (CAN-ID-003)
- Definição do Modelo Canônico de Identidade
- Documentação de políticas de governança de dados de identidade

### 5.3. Infraestrutura Técnica

- Criação de nova infraestrutura dedicada ao PRJ003 (Hyper-V ou equivalente)
- Implementação de novo Active Directory exclusivo
- Implementação de novo OrangeHRM exclusivo
- Deploy de ambiente midPoint greenfield
- Configuração de rede e segmentação (VLANs, se aplicável)

### 5.4. Implementação IGA

- Configuração de conectores midPoint baseados em decisões formalizadas via canvas
- Implementação de fluxos JML simples e controlados (onboarding, offboarding)
- Validação de sincronizações idempotentes
- Testes de correlação de identidades

### 5.5. Documentação e Aprendizado

- Registro de todas as decisões em ADRs formais
- Criação de REL-GMUDs para cada GMUD executada
- Documentação de lições aprendidas comparando greenfield vs. brownfield
- Preparação de artefatos reutilizáveis para futura retomada do PRJ002

### 5.6. Planejamento de Retomada do PRJ002

- Análise de viabilidade de aplicar decisões do PRJ003 em ambiente brownfield
- Documentação de estratégia de migração ou convergência entre PRJ002 e PRJ003
- Definição de critérios para retomada do PRJ002 após validação do PRJ003

**Importante:** Este escopo é macro e declarativo. Detalhamento técnico será feito em GMUDs específicas do PRJ003.

---

## 6. Entregáveis Esperados

### 6.1. Entregáveis Imediatos (GMUD-025)

- Estrutura do PRJ003 criada no Obsidian
- Documento de declaração formal do projeto (este documento)
- Reconhecimento formal do REL-GMUD-024 como referência histórica

### 6.2. Entregáveis do PRJ003 (Ciclo Completo)

- Conjunto de canvases de decisão validados (mínimo: CAN-ID-001, 002, 003)
- Modelo Canônico de Identidade documentado
- Ambiente IGA greenfield funcional
- Fluxos JML básicos validados
- ADRs documentando todas as decisões arquiteturais
- Relatório de lições aprendidas: greenfield vs. brownfield
- Estratégia de retomada do PRJ002 (se aplicável)

---

## 7. Critérios de Aceite

A GMUD-025 será considerada **encerrada com sucesso** quando:

1. ✅ PRJ003 estiver formalmente criado no Obsidian com estrutura organizacional definida
2. ✅ PRJ002 estiver formalmente pausado na GMUD-024 sem rollback
3. ✅ Artefatos arquiteturais (DOC-ARC-000, DOC-ARC-001, template base Canvas CAN-ID) estiverem reconhecidos como entregáveis válidos
4. ✅ REL-GMUD-024 estiver formalmente reconhecido como registro de encerramento controlado
5. ✅ Escopo macro do PRJ003 estiver documentado e aprovado

**Evidências de aceite:**
- Diretório `/10-Projetos/PRJ003-IGA-GREENFIELD/` criado
- REL-GMUD-024 v1.0 referenciado formalmente nesta GMUD
- Esta GMUD-025 marcada como "Concluída"

---

## 8. Impactos e Riscos

### 8.1. Impactos

| Área Impactada | Tipo de Impacto | Descrição |
|----------------|-----------------|-----------|
| PRJ002 | Organizacional | Pausa consciente na GMUD-024 |
| Infraestrutura | Técnico | Criação de novo ambiente isolado para PRJ003 |
| Documentação | Positivo | Elevação de artefatos arquiteturais a entregáveis formais |
| Governança | Positivo | Institucionalização de decisão prévia à automação |
| Aprendizado | Positivo | Validação de princípios em greenfield |

### 8.2. Riscos

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| Retrabalho por divergência entre PRJ002 e PRJ003 | Baixa | Médio | Documentação clara de diferenças arquiteturais; PRJ003 como referência, não substituição |
| Esquecimento de lições aprendidas do PRJ002 | Baixa | Médio | DOC-ARC-001 e REL-GMUD-024 preservam histórico; cross-reference obrigatório |
| Dificuldade de retomada do PRJ002 | Média | Médio | Planejamento de retomada incluído no escopo do PRJ003 |
| Interpretação de pausa como abandono | Baixa | Baixo | Comunicação clara: pausa é maturação intencional, não desistência |

---

## 9. Plano de Rollback

**Não aplicável.**

Esta GMUD é declarativa e organizacional. Não há mudanças técnicas a reverter.

Em caso de não aprovação:
- PRJ002 continua ativo na GMUD-024
- PRJ003 não é criado
- Artefatos arquiteturais permanecem como documentos de referência sem status formal de entregável

---

## 10. Conclusão

A GMUD-025 representa um marco de maturidade arquitetural no Living Lab Fiqueok, reconhecendo que:

- **Limites do brownfield foram atingidos** — ambiente legado introduz complexidade que dificulta isolamento de problemas de modelagem
- **Greenfield é necessário para validação** — princípios arquiteturais precisam ser testados sem interferência de dívidas técnicas
- **Arquitetura é entregável** — decisões formalizadas (canvases, ADRs, modelos) são tão importantes quanto código funcional
- **Pausa é estratégia** — interromper conscientemente para amadurecer é sinal de governança, não de falha

Este documento será referenciado como exemplo de **governança de projetos IAM** em futuros ciclos de aprendizado.

---

## 11. Aprovações

| Papel | Nome | Data | Status |
|-------|------|------|--------|
| Solicitante | Paulo Feitosa | 13/01/2026 | ✅ Aprovado |
| Executor | Paulo Feitosa | 13/01/2026 | ✅ Aprovado |
| Aprovador Final | Paulo Feitosa | 13/01/2026 | ✅ Aprovado |

---

## 12. Documentos Relacionados

**GMUDs:**
- GMUD-024 — Última GMUD do PRJ002 (pausa)
- REL-GMUD-024 v1.0 — Relatório de encerramento controlado da GMUD-024

**Documentos Fundacionais:**
- DOC-ARC-000 — Fundamentos de Decisão em Arquitetura de Identidade
- DOC-ARC-001 — Problemas de Decisão Observados em Arquitetura de Identidade
- Template base do Canvas de Decisão em Arquitetura de Identidade (CAN-ID)

**Projetos:**
- PRJ002 — Infraestrutura Fiqueok (pausado)
- PRJ003 — IGA Greenfield Reference Architecture (novo)

---

## 13. Controle de Versão

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 13/01/2026 | Paulo Feitosa | Criação e aprovação da GMUD-025 |

---

**Documento mantido por:** Paulo Feitosa (Owner)  
**Repositório:** Obsidian Vault - FiqueokBrain/10-Projetos/PRJ002-LABORATORIO/20-Governanca/GMUDs/  
**Nome do arquivo:** `GMUD-025-Declaracao-Formal-PRJ003-IGA-Greenfield.md`  
**Próxima ação:** Estruturação do PRJ003 no Obsidian

---
