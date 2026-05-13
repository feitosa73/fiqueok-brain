Crie agora um readme baseado neste esboço:

# README — Framework de Canvases de Arquitetura de Identidade (IAM)

## 1. Objetivo deste Documento

Este documento descreve o **Framework de Canvases de Arquitetura de Identidade** utilizado em projetos de IAM / IGA.

Seu objetivo não é criar burocracia ou documentação excessiva, mas **apoiar decisões difíceis, ambíguas ou de alto impacto**, comuns em iniciativas de identidade e acesso.

O framework ajuda a:
- tornar decisões implícitas explícitas
- reduzir retrabalho técnico
- evitar conflitos silenciosos entre áreas
- aumentar previsibilidade de GMUDs
- melhorar rastreabilidade para auditoria e GRC

> **Importante:**  
> Os **templates são agnósticos** (vendor, ferramenta, arquitetura física ou cenário).  
> Eles podem ser aplicados em **greenfield, brownfield ou ambientes híbridos**.

---

## 2. Conceitos Fundamentais

### 2.1 Template vs Canvas

- **Template**  
  Estrutura reutilizável, neutra e institucional. Vive em `90_Templates`.

- **Canvas**  
  Instância preenchida para um projeto específico, criada a partir de um template.

> Template é o molde.  
> Canvas é a decisão congelada do projeto.

---

### 2.2 Princípio Central

> **Decisões precedem implementação.**

Nenhuma automação, conector ou fluxo de lifecycle deve ser implementado sem que as **decisões semânticas e de governança** estejam explícitas.

O framework existe para **decidir antes de configurar**, não para documentar depois do problema.

---

## 3. Quando este Framework REALMENTE vale a pena

Este framework **não foi criado para documentar o óbvio**.

Ele deve ser usado quando:
- há múltiplas fontes de identidade
- existe conflito (ou potencial conflito) de dados
- o ciclo de vida gera impacto operacional ou regulatório
- a automação pode causar incidente se estiver errada
- a decisão é difícil de reverter depois de implementada

### Regra prática
> Se a decisão pode gerar **retrabalho, incidente, auditoria ou desgaste entre áreas**, ela merece um canvas.

O uso dos canvases é **proporcional ao risco e à complexidade** do cenário.

---

## 4. Dimensões de Decisão em Identidade

O framework organiza decisões em **quatro dimensões complementares**:

1. Estrutura Semântica da Identidade  
2. Governança de Dados de Identidade  
3. Ciclo de Vida da Identidade  
4. Governança do Processo Decisório  

Cada dimensão possui um canvas específico.

---

## 5. CAN-ID-001 — Identidade Canônica  
### (Estrutura Semântica)

**Template:** `Template-CAN-ID`  
**Tipo de Decisão:** Decisão Semântica Estrutural de Identidade  

### Pergunta que responde
> **O que é uma identidade neste ecossistema?**

### Congela decisões como
- definição de identidade canônica
- identificador canônico
- limites entre identidade, conta e sistema
- invariantes semânticas que não podem variar por configuração

### Aplicação por cenário
- **Greenfield:** define a identidade desde a origem.
- **Brownfield:** formaliza o que já existe e explicita incoerências.
- **Híbrido:** define o núcleo canônico e regras de convivência com legados.

---

## 6. CAN-ID-002 — Autoridade de Dados de Identidade  
### (Governança de Atributos)

**Template:** `Template-CAN-ID-DG`  
**Tipo de Decisão:** Governança de Dados por Atributo  

### Pergunta que responde
> **Quem é autoridade de cada dado da identidade e como conflitos são resolvidos?**

### Congela decisões como
- autoridade por categoria de atributo
- precedência entre fontes
- resolução de conflitos
- limites do IGA como orquestrador semântico

### Aplicação por cenário
- **Greenfield:** evita split-brain desde o início.
- **Brownfield:** explicita disputas silenciosas entre sistemas.
- **Híbrido:** define fonte de verdade por atributo.

---

## 7. CAN-ID-003 — Estados da Identidade  
### (Lifecycle Semântico)

**Template:** `Template-CAN-ID-LC`  
**Tipo de Decisão:** Decisão Semântica de Ciclo de Vida  

### Pergunta que responde
> **Em que estados a identidade pode existir e o que cada estado significa?**

### Congela decisões como
- estados canônicos da identidade
- significado organizacional de cada estado
- separação entre estado semântico e estado técnico
- limites conceituais de transições

### Aplicação por cenário
- **Greenfield:** define estados antes de automatizar.
- **Brownfield:** normaliza estados conflitantes e exceções.
- **Híbrido:** define equivalências entre estados novos e legados.

---

## 8. DEC-ID — Identity Decision Canvas  
### (Governança das Decisões)

**Template:** `Template-DEC-ID`  
**Tipo de Decisão:** Governança do Processo Decisório  

### Pergunta que responde
> **Quem decide o quê, quando e com qual nível de formalidade?**

### Congela decisões como
- tipos de decisão (arquitetural, governança, técnica, operacional)
- responsáveis e limites de autoridade
- decisões proibidas “em voo”
- regras de exceção e escalonamento

Este canvas evita que:
- decisões arquiteturais sejam tomadas em GMUD técnica
- problemas semânticos sejam “resolvidos” por configuração

---

## 9. Exemplos Práticos de Cenários de Uso

### Cenário 1 — Integração de sistema crítico
Exemplo: ERP, Financeiro, Clínico  
Canvases recomendados:
- CAN-ID-002
- CAN-ID-003

---

### Cenário 2 — Automação de Joiner / Mover / Leaver
Canvases recomendados:
- CAN-ID-003
- DEC-ID

---

### Cenário 3 — Ambiente legado complexo (brownfield)
Canvases recomendados:
- CAN-ID-001
- CAN-ID-002

---

### Cenário 4 — Projeto simples / piloto
Uso sugerido:
- CAN-ID-001 simplificado  
Demais canvases apenas se surgir ambiguidade.

---

## 10. Atores Envolvidos na Elaboração dos Canvases

Os canvases **não devem ser preenchidos isoladamente**.

### Owner do Canvas
Normalmente:
- Arquitetura de Identidade
- Segurança / IAM Lead

Responsável por:
- conduzir o canvas
- consolidar decisões
- garantir coerência entre canvases

---

### Áreas Consultadas

**Negócio / RH**
- significado dos estados
- ownership de dados
- regras de lifecycle

**TI / Infra**
- impactos técnicos
- limitações operacionais
- reflexo nos sistemas

**Segurança / GRC**
- riscos
- impactos regulatórios
- exigências de auditoria

---

### Validação (quando aplicável)
- Segurança
- GRC
- Donos de sistemas críticos
- Gestão de TI

> Os canvases não criam decisões do zero.  
> Eles **tornam explícitas decisões que já existem**, mas normalmente estão dispersas em reuniões, e-mails ou configurações.

---

## 11. Regra de Ouro (Anti-Burocracia)

> Se um canvas não puder ser preenchido em uma conversa estruturada  
> de **60 a 90 minutos** com as áreas corretas,  
> o problema provavelmente **não é o template**,  
> mas a ausência de decisão clara no ambiente.

---

## 12. Relação com ADR, GMUD e REL

- **Canvas:** congela decisões
- **ADR:** altera decisões congeladas
- **GMUD:** implementa decisões aprovadas
- **REL-GMUD:** evidencia execução

Nenhuma GMUD técnica deve contradizer um canvas consolidado sem ADR formal.

---

## 13. Controle de Versão

| Versão | Data | Autor | Mudança |
|------|------|------|--------|
| 2.0 | 2026-01-14 | Paulo Feitosa | Reescrita completa com foco em aplicabilidade e anti-burocracia |