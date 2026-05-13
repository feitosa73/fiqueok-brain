---
**Documento:** DOC-ARC-001  
**Título:** Problemas de Decisão Observados em Arquitetura de Identidade (Living Lab)  
**Tipo:** Documento Analítico (Diagnóstico Arquitetural)  
**Status:** Ativo  
**Data:** 13/01/2026  
**Autor:** Paulo Feitosa (Owner)  
**Contexto:** Living Lab de IGA - Lab Fiqueok 2.0  
**Público-alvo:** Arquitetos de identidade, profissionais GRC, equipe do projeto  
**Documento relacionado:** DOC-ARC-000 (Fundamentos de Decisão em Arquitetura de Identidade)

---

## 1. Contexto e Objetivo do Documento

O DOC-ARC-000 estabeleceu que falhas observadas no Living Lab de IGA não decorreram de execução técnica inadequada, mas de lacunas em decisões semânticas e arquiteturais prévias à automação. Este documento complementa aquele diagnóstico identificando **quais tipos de decisão faltaram** e **quando sua ausência causou impacto**.

Identificar problemas de decisão observados é necessário porque:

- Permite reconhecer padrões recorrentes de lacunas decisórias antes de criar novos artefatos de governança
- Diferencia problemas de tooling de problemas de modelagem
- Fornece base factual para evolução arquitetural sem prescrever soluções específicas
- Evita repetição de ciclos de retrabalho em futuras integrações IGA

Este documento não propõe soluções, não define frameworks e não estabelece decisões obrigatórias. É um registro analítico de problemas observados.

## 2. Padrões Recorrentes de Problemas Observados

### 2.1. Identificador Canônico Indefinido

**Problema:** Ausência de decisão formal sobre qual atributo serve como identificador único universal entre sistemas integrados.

**Manifestação observada:** Diferentes sistemas utilizam diferentes atributos como chave primária (ex: número de matrícula no RH, sAMAccountName no AD, employeeNumber no diretório LDAP). Na ausência de decisão explícita sobre qual é o identificador canônico, sincronizações assumem equivalências que não existem, causando duplicação ou perda de vínculo entre registros.

**Característica:** Decisão assumida implicitamente durante implementação de conectores, não formalizada previamente.

### 2.2. Autoridade de Dados Implícita

**Problema:** Ausência de definição formal sobre qual sistema é fonte autoritativa (source of truth) para cada atributo de identidade.

**Manifestação observada:** Atributos como "status do usuário", "departamento" ou "data de término de contrato" existem em múltiplos sistemas. Sem autoridade declarada, sincronizações bidirecionais geram conflitos de precedência. Quando um atributo é atualizado em mais de uma fonte, não existe critério formal para resolver qual valor prevalece.

**Característica:** Decisão delegada ao comportamento padrão da ferramenta IGA ou ao conhecimento tácito de quem configura conectores.

### 2.3. Estados de Identidade Ambíguos

**Problema:** Ausência de definição compartilhada sobre estados válidos de ciclo de vida de identidade entre sistemas integrados.

**Manifestação observada:** Um sistema de RH considera um colaborador "em férias", outro sistema trata como "ativo", e um terceiro interpreta como "suspenso temporariamente". Mapeamentos de status não cobrem todas as combinações possíveis, levando a provisionamentos parciais ou dessincronizações silenciosas.

**Característica:** Cada sistema mantém seu próprio esquema de estados sem tradução semântica acordada.

### 2.4. Suposições Não Documentadas sobre Fluxo de Dados

**Problema:** Ausência de registro formal sobre direção de fluxo de dados (quem escreve onde) e dependências de sequência entre sincronizações.

**Manifestação observada:** GMUDs assumem que "o RH sempre é a origem" ou "o AD sempre reflete o estado final", mas essas premissas não estão documentadas. Quando uma exceção ocorre (ex: atualização manual no AD por equipe de TI), não existe protocolo definido sobre como reconciliar divergências.

**Característica:** Fluxo de dados tratado como conhecimento tácito, não como arquitetura formalizada.

### 2.5. Critérios de Correlação Não Especificados

**Problema:** Ausência de regras explícitas para correlacionar registros entre sistemas quando não existe identificador único comum.

**Manifestação observada:** Tentativas de correlação baseadas em combinações de atributos (nome + CPF, email + data de admissão) geram falsos positivos ou falhas de matching quando dados contêm inconsistências menores (ex: abreviações de nome, formatação de CPF).

**Característica:** Lógica de correlação implementada ad-hoc em scripts ou expressões Groovy sem validação prévia de qualidade de dados.

## 3. Exemplos Concretos Extraídos do Living Lab

### 3.1. GMUD-023 e Problema de Identificador Canônico

Em GMUD de integração entre OrangeHRM e midPoint, observou-se que o conector assumiu `emp_number` como identificador primário, enquanto sincronizações posteriores com AD utilizavam `sAMAccountName`. Não existia decisão documentada sobre qual seria o identificador canônico universal. Resultado: objetos duplicados no repositório midPoint quando um colaborador tinha matrícula alterada no RH.

**Tipo de decisão ausente:** Definição de identificador canônico e política de imutabilidade de chaves primárias.

### 3.2. GMUD-024 e Autoridade de Dados Implícita

Em GMUD de sincronização bidirecional AD-midPoint, atributo `department` existia em ambos os sistemas. Sem autoridade declarada, mudanças feitas manualmente no AD eram sobrescritas por sincronizações do midPoint, que assumia RH como origem. Equipe de TI não tinha visibilidade sobre essa precedência.

**Tipo de decisão ausente:** Mapa de autoridade de dados por atributo.

### 3.3. Integrações Anteriores e Estados Ambíguos

Em integrações de ciclo de vida (onboarding/offboarding), observou-se que colaborador "em aviso prévio" no RH não tinha equivalente claro no AD (ativo ou desabilitado?). Decisão tomada "em voo" durante implementação do conector: tratar como ativo até data de término. Essa decisão não foi registrada, causando retrabalho em GMUDs posteriores que assumiram comportamento diferente.

**Tipo de decisão ausente:** Modelo de estados de identidade e mapeamento formal entre esquemas de sistemas.

### 3.4. ADR-007 como Evidência de Decisão Tardia

ADR-007 documenta uma decisão arquitetural tomada após problemas de sincronização já terem ocorrido. Exemplifica padrão recorrente: decisões de modelagem sendo formalizadas **em resposta a falhas**, não **antes da automação**.

**Tipo de decisão ausente:** Governança prévia de decisões arquiteturais de identidade.

## 4. Impactos Arquiteturais Observados

### 4.1. Retrabalho em GMUDs

GMUDs tecnicamente corretas precisaram ser revertidas ou refeitas porque pressupostos não documentados revelaram-se incorretos em cenários reais. Tempo de implementação estendido, acúmulo de débito técnico.

### 4.2. Quebra de Idempotência

Sincronizações que deveriam ser idempotentes (mesma entrada gera mesma saída) geraram resultados diferentes em execuções consecutivas devido a ausência de critérios estáveis de correlação e autoridade de dados.

### 4.3. Ambiguidade entre Fontes

Impossibilidade de determinar, em situação de conflito, qual sistema contém o valor correto para determinado atributo. Resultou em intervenções manuais frequentes e perda de confiança na automação.

### 4.4. Dificuldade de Evolução do Modelo de Identidade

Adição de novos atributos ou novos sistemas ao fluxo de sincronização requer reanálise completa de toda a cadeia de integrações, pois não existe modelo canônico documentado para servir de referência. Escalabilidade comprometida.

### 4.5. Ausência de Rastreabilidade de Decisões

Decisões tomadas durante implementação de conectores não foram registradas formalmente. Quando problemas surgem meses depois, não existe documentação sobre **por que** determinada escolha foi feita, dificultando manutenção e auditoria.

## 5. Limites deste Documento

Este documento:

- **Não propõe soluções** para os problemas identificados
- **Não define frameworks, canvases ou modelos** de decisão
- **Não prescreve decisões obrigatórias** para futuras GMUDs
- **Não reexplica conceitos** já estabelecidos no DOC-ARC-000
- **Não é um ADR** — não declara mudanças arquiteturais aprovadas
- **Não é um post-mortem técnico** — foco em decisões ausentes, não em falhas de execução

Este documento serve como:

- **Insumo factual** para criação futura de artefatos de governança de identidade (quando e se necessário)
- **Registro de aprendizado arquitetural** do Living Lab
- **Base analítica** para priorização de decisões em futuras evoluções do modelo de identidade
- **Referência** para arquitetos que enfrentam problemas similares em outros contextos

Decisões sobre **como resolver** esses problemas pertencem a documentos futuros, ainda não criados.

## 6. Glossário Específico deste Documento

**Decisão em voo**  
Decisão arquitetural tomada durante implementação técnica, sem formalização prévia ou registro documental.

**Autoridade de dados implícita**  
Situação onde a precedência de uma fonte de dados sobre outra não está documentada formalmente, sendo assumida tacitamente.

**Correlação ad-hoc**  
Lógica de matching entre registros de sistemas diferentes implementada sem critérios explícitos ou validação de qualidade de dados.

**Débito de decisão**  
Acúmulo de decisões arquiteturais não formalizadas que precisam ser retroativamente documentadas ou refeitas.

---

## 7. Referências e Contexto

**GMUDs Relacionadas:**  
GMUD-023, GMUD-024 e outras integrações IGA do Living Lab (consultar repositório Obsidian).

**Decisões Arquiteturais:**  
ADR-007 (exemplo de decisão tomada tardiamente).

**Documentos Fundacionais:**  
- DOC-ARC-000 — Fundamentos de Decisão em Arquitetura de Identidade
- Manifesto de Estratégia e Infraestrutura Fiqueok v2.0
- ARQ-005 — Memorial Descritivo de Arquitetura

---

## 8. Controle de Versão

| Versão | Data       | Autor         | Mudanças Principais                          |
|--------|------------|---------------|----------------------------------------------|
| 1.0    | 13/01/2026 | Paulo Feitosa | Criação do documento analítico DOC-ARC-001   |

---

**Documento mantido por:** Paulo Feitosa (Owner) com suporte de Perplexity Pro (GRC Lead)  
**Repositório:** Obsidian Vault - FiqueokBrain/10-Projetos/PRJ001-LABORATORIO/10-Planning  
**Próxima revisão:** Sob demanda, após novos ciclos de integração IGA

---
