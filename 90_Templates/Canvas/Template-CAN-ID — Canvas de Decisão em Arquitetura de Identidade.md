
---
**Documento:** TEMPLATE-CANVAS-IDENTITY-001  
**Título:** Template — Canvas de Decisão em Arquitetura de Identidade  
**Tipo:** Template Reutilizável  
**Versão:** 2.0  
**Data:** 14/01/2026  
**Aplicabilidade:** Universal — Projetos IAM/IGA/Identity Governance  
**Independente de:** Ferramenta, vendor, plataforma, organização  

---

## Propósito do Template

Este template define a estrutura canônica para criação de **canvases de decisão em Arquitetura de Identidade** em qualquer contexto IAM/IGA.

**Características:**
- Reutilizável em múltiplos projetos (corporativos, labs, consultorias, POCs)
- Independente de ferramenta específica (midPoint, Okta, SailPoint, AD, Entra ID, etc.)
- Agnóstico de vendor e tecnologia
- Deve ser preenchido **antes de qualquer implementação técnica** envolvendo automação de identidade
- Formaliza decisões que costumam permanecer implícitas em projetos IAM/IGA

**Princípio Fundamental:**  
Decisões de arquitetura de identidade precedem automação. Este template materializa esse princípio.

---

## 1. Identificação do Canvas

**Nome do Canvas:**  
_(Descrição clara e objetiva do tema central)_

**Exemplos:**
- Identificador Canônico de Identidade
- Autoridade de Dados por Atributo
- Estados de Ciclo de Vida de Identidade
- Modelo de Correlação entre Fontes

**Código:**  
_(Padrão sugerido: CAN-ID-XXX ou similar, conforme taxonomia da organização)_

**Versão:**  
_(Formato: X.Y — major.minor)_

**Status:**  
- [ ] Rascunho  
- [ ] Em Validação  
- [ ] Ativo  
- [ ] Arquivado  

**Autor / Owner:**  
_(Responsável pela criação e manutenção deste canvas)_

**Data de Criação:**  
_(dd/mm/aaaa)_

**Última Revisão:**  
_(dd/mm/aaaa)_

---

## 2. Contexto da Decisão

### Pergunta Central que Este Canvas Responde

_(Formular como pergunta clara, direta e objetiva)_

**Exemplos:**
- "Qual atributo serve como identificador único universal entre todos os sistemas integrados?"
- "Qual sistema é fonte autoritativa para cada atributo de identidade?"
- "Quais estados de ciclo de vida de identidade são reconhecidos por todos os sistemas?"

### Por Que Essa Decisão é Necessária

_(Explique o problema arquitetural ou operacional que surge quando essa decisão não existe)_

**Exemplo:**  
"Sem identificador canônico definido, sistemas utilizam atributos diferentes como chave primária, causando duplicação de registros, perda de vínculo entre fontes, impossibilidade de rastreamento de ciclo de vida e falhas em processos de reconciliação."

### Em Que Momento Este Canvas Deve Ser Usado

- [ ] Antes de implementação técnica de integrações IAM  
- [ ] Antes de criar conectores ou adaptadores  
- [ ] Antes de definir políticas de sincronização  
- [ ] Antes de onboarding de nova fonte de dados  
- [ ] Durante redesign de arquitetura de identidade  
- [ ] Outro: ___________________

---

## 3. Escopo do Canvas

### Este Canvas Cobre

_(Liste claramente o que está dentro do escopo desta decisão)_

**Exemplo:**
- Definição de identificador único universal
- Regras de imutabilidade do identificador
- Tratamento de identificadores legados ou duplicados
- Critérios de geração de novos identificadores

### Este Canvas NÃO Cobre

_(Liste explicitamente o que não deve ser decidido aqui — evita scope creep)_

**Exemplo:**
- Formato de atributos descritivos (nome completo, email)
- Políticas de senha ou autenticação
- Modelos de papéis, grupos ou permissões
- Detalhes de implementação técnica em ferramentas específicas

---

## 4. Decisões Obrigatórias

**Regra:** Estas decisões não podem ficar implícitas. Se não forem tomadas, a automação não deve prosseguir.

| Nº | Decisão a Ser Tomada | Status | Responsável | Prazo |
|----|---------------------|--------|-------------|-------|
| 1  |                     |        |             |       |
| 2  |                     |        |             |       |
| 3  |                     |        |             |       |

**Status possíveis:**  
- Pendente  
- Em Discussão  
- Decidida  
- Validada  
- Implementada  

---

## 5. Opções de Decisão (Análise Não Prescritiva)

**Objetivo:** Tornar explícitas as escolhas possíveis sem indicar "certo" ou "errado" a priori.

### Opção A

**Descrição:**  
_(O que é esta opção)_

**Benefícios:**  
- _(Vantagem 1)_
- _(Vantagem 2)_
- _(Vantagem 3)_

**Riscos / Trade-offs:**  
- _(Risco ou limitação 1)_
- _(Risco ou limitação 2)_

**Exemplo de Aplicação:**  
_(Cenário real ou hipotético onde esta opção seria adequada)_

**Requisitos para Implementação:**  
_(Pré-requisitos técnicos ou organizacionais)_

---

### Opção B

**Descrição:**  
_(O que é esta opção)_

**Benefícios:**  
- _(Vantagem 1)_
- _(Vantagem 2)_
- _(Vantagem 3)_

**Riscos / Trade-offs:**  
- _(Risco ou limitação 1)_
- _(Risco ou limitação 2)_

**Exemplo de Aplicação:**  
_(Cenário real ou hipotético onde esta opção seria adequada)_

**Requisitos para Implementação:**  
_(Pré-requisitos técnicos ou organizacionais)_

---

### Opção C (se aplicável)

**Descrição:**  
_(O que é esta opção)_

**Benefícios:**  
- _(Vantagem 1)_
- _(Vantagem 2)_

**Riscos / Trade-offs:**  
- _(Risco ou limitação 1)_
- _(Risco ou limitação 2)_

**Exemplo de Aplicação:**  
_(Cenário real ou hipotético onde esta opção seria adequada)_

**Requisitos para Implementação:**  
_(Pré-requisitos técnicos ou organizacionais)_

---

### Matriz Comparativa (Opcional)

| Critério | Opção A | Opção B | Opção C |
|----------|---------|---------|---------|
| Complexidade de implementação |  |  |  |
| Custo operacional |  |  |  |
| Escalabilidade |  |  |  |
| Compatibilidade com sistemas legados |  |  |  |
| Tempo de implementação |  |  |  |

---

## 6. Consequências Arquiteturais

### Se Esta Decisão for Tomada

_(Impactos positivos, restrições criadas, dependências estabelecidas)_

**Exemplos:**
- Sincronizações tornam-se idempotentes
- Rastreamento de identidade entre sistemas passa a ser confiável
- Restrição: atributo escolhido deve ser imutável
- Dependência: sistema X deve ser fonte primária do atributo Y

### Se Esta Decisão NÃO for Tomada

_(Falhas observáveis, retrabalho esperado, riscos operacionais)_

**Exemplos:**
- Duplicação de identidades no repositório central
- Impossibilidade de correlacionar eventos de auditoria
- Retrabalho em implementações futuras para reconciliação manual
- Violação de requisitos de compliance (ex: rastreabilidade ISO 27001)

---

## 7. Análise de Riscos

| Risco | Impacto | Probabilidade | Mitigação | Responsável |
|-------|---------|---------------|-----------|-------------|
|       |         |               |           |             |
|       |         |               |           |             |
|       |         |               |           |             |

**Escala de Impacto:** Baixo / Médio / Alto / Crítico  
**Escala de Probabilidade:** Baixa / Média / Alta

**Riscos Comuns em Decisões de Identidade:**
- Mudança futura de requisitos quebrando decisão atual
- Incompatibilidade com sistemas legados não mapeados
- Resistência organizacional a mudanças de processo
- Limitações técnicas de ferramentas específicas

---

## 8. Evidências e Artefatos Esperados

**Pergunta:** Quais evidências demonstram que esta decisão foi realmente tomada e implementada?

- [ ] Documento formal de decisão (ADR, política, norma)  
- [ ] Modelo de dados atualizado (diagramas ER, schemas)  
- [ ] Configuração em ferramentas IAM/IGA (schemas, mappings)  
- [ ] Documentação técnica de integração  
- [ ] Testes de validação executados e aprovados  
- [ ] Treinamento de equipes realizado  
- [ ] Outro: ___________________

**Observação:** Decisões sem evidências documentais são consideradas implícitas e não atendem a padrões de governança corporativa.

---

## 9. Relacionamentos com Outros Artefatos

### Canvases Relacionados

_(Liste outros canvases que dependem deste ou que este depende)_

**Exemplo:**
- Depende de: CAN-ID-001 (Identificador Canônico)
- Impacta: CAN-ID-003 (Estados de Ciclo de Vida)

### Implementações Técnicas Impactadas

_(Liste projetos, integrações ou sistemas afetados)_

### Decisões Arquiteturais Relacionadas (ADRs)

_(Referencie ADRs que documentam decisões relacionadas ao tema deste canvas)_

### Documentos de Governança

_(Políticas, normas, padrões corporativos relacionados)_

### Frameworks de Compliance

_(ISO 27001, NIST, SOX, GDPR, LGPD, etc. — controles impactados)_

---

## 10. Validação e Testes

_(Seção opcional, mas recomendada)_

### Cenários de Teste Sugeridos

1. **Teste de caso normal:**  
   _(Descrever cenário de uso padrão)_

2. **Teste de caso de exceção:**  
   _(Descrever cenário de borda ou falha)_

3. **Teste de integração:**  
   _(Validar interação com outros sistemas)_

### Critérios de Aceitação

- [ ] Decisão documentada formalmente  
- [ ] Aprovação de stakeholders obtida  
- [ ] Testes de validação executados com sucesso  
- [ ] Equipes treinadas  
- [ ] Implementação técnica concluída  

---

## 11. Stakeholders e Aprovações

| Papel | Nome | Área | Data de Aprovação | Status |
|-------|------|------|-------------------|--------|
| Arquiteto de Identidade |  |  |  |  |
| Gestor de Segurança |  |  |  |  |
| Compliance / GRC |  |  |  |  |
| Liderança Técnica |  |  |  |  |
| Owner do Projeto |  |  |  |  |

---

## 12. Histórico de Revisões

| Versão | Data | Autor | Alteração | Motivo |
|--------|------|-------|-----------|--------|
| 1.0    |      |       |           |        |
|        |      |       |           |        |
|        |      |       |           |        |

---

## 13. Observações e Notas de Governança

_(Espaço livre para considerações arquiteturais, alertas, dependências externas ou notas importantes)_

**Exemplos:**
- "Esta decisão deve ser revisada a cada onboarding de nova fonte de dados"
- "Identificador canônico não pode ser alterado sem decisão arquitetural formal (ADR)"
- "Consultar equipe de Compliance antes de validar este canvas em ambiente de produção"
- "Decisão válida apenas para ambiente X; ambiente Y requer canvas separado"

---

## Regras de Governança

### Princípio de Bloqueio

**Nenhuma implementação técnica de IAM/IGA deve ser iniciada sem que os canvases aplicáveis estejam:**

1. ✅ Preenchidos completamente
2. ✅ Revisados por arquiteto responsável
3. ✅ Validados por stakeholders relevantes
4. ✅ Aprovados formalmente pelo owner do projeto

**Exceções:**

- Ambientes de laboratório ou prova de conceito podem preencher canvases retroativamente
- Exceções devem ser documentadas em relatório de lições aprendidas
- Decisões "em voo" devem ser formalizadas em até 30 dias após implementação

### Ciclo de Vida do Canvas

**Criação** → **Validação** → **Ativo** → **Revisão Periódica** → **Atualização ou Arquivamento**

**Gatilhos de revisão obrigatória:**
- Mudança significativa de requisitos
- Onboarding de novo sistema integrado
- Incidente de segurança relacionado
- Auditoria interna ou externa
- Mudança de framework de compliance

---

## Instruções de Uso

### Para criar novo canvas a partir deste template:

1. Copie este template para novo arquivo
2. Renomeie seguindo padrão da organização (ex: `CAN-ID-XXX-NomeDoCanvas.md`)
3. Preencha **todas as seções obrigatórias** (1-9)
4. Preencha seções opcionais conforme aplicável (10-13)
5. Marque status como "Rascunho" até validação completa
6. Submeta para revisão técnica
7. Obtenha aprovações necessárias
8. Marque como "Ativo" após aprovação final
9. Vincule a implementações técnicas e ADRs relevantes
10. Mantenha histórico de revisões atualizado

---

## Metadados do Template

**Versão do Template:** 2.0  
**Data de Criação:** 14/01/2026  
**Compatível com:** Projetos IAM/IGA/Identity Governance multi-ferramenta  
**Frameworks de Referência:** ISO/IEC 27001, NIST CSF, TOGAF (Identity Domain), COBIT  
**Independente de:** Vendor, plataforma, ferramenta, organização  
**Licença de Uso:** Reutilizável em qualquer contexto IAM  

**Mantido por:** Comunidade de Arquitetos de Identidade  
**Localização Sugerida:** `/Templates/Identity-Architecture/` ou equivalente  
**Próxima revisão do template:** Anual ou sob demanda

---

## Glossário de Termos

**Canvas de Decisão**  
Artefato estruturado que formaliza decisões arquiteturais antes de implementação técnica.

**Contrato de Identidade**  
Acordo semântico e arquitetural sobre identificador canônico, autoridade de dados, estados válidos e modelo canônico de identidade.

**Identificador Canônico**  
Atributo único e imutável que serve como chave primária universal para correlação de identidades entre sistemas.

**Autoridade de Dados**  
Sistema designado como fonte autoritativa (source of truth) para determinado conjunto de atributos.

**Estados de Ciclo de Vida**  
Conjunto acordado de estados de identidade reconhecidos por todos os sistemas integrados.

**Decisão em Voo**  
Decisão arquitetural tomada durante implementação técnica, sem formalização prévia.

**IGA (Identity Governance and Administration)**  
Disciplina que combina governança de identidades, administração de acessos e compliance.

---
