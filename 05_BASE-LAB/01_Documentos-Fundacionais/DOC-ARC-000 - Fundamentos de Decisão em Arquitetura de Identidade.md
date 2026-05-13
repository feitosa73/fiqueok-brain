---
**Documento:** DOC-ARC-000  
**Título:** Fundamentos de Decisão em Arquitetura de Identidade (Living Lab)  
**Tipo:** Documento Fundacional  
**Status:** Ativo  
**Data:** 13/01/2026  
**Autor:** Paulo Feitosa (Owner)  
**Contexto:** Living Lab de IGA - Lab Fiqueok 2.0  
**Público-alvo:** Arquitetos de identidade, profissionais GRC, equipe do projeto, IAs assistentes  

---

## 1. Contexto do Living Lab

O Living Lab de IGA com midPoint serve como ambiente de aprendizado arquitetural no Lab Fiqueok, simulando integrações entre sistemas de RH, diretórios corporativos e engine IGA para testar fluxos de ciclo de vida de identidades (JML). Após mais de 20 GMUDs executadas, como observado em GMUDs recentes de integração IGA e em decisões arquiteturais relacionadas (ex: ADR-007), identificou-se um padrão consistente: falhas não surgiram de limitações da ferramenta midPoint, mas de lacunas em decisões prévias de modelagem de identidade.

O foco deste ambiente é aprendizado arquitetural, revelando que falhas em automações de identidade surgem principalmente de modelagem semântica prévia inadequada, não de execução técnica.[^1]

## 2. O que funcionou tecnicamente

Configurações de conectores e sincronizações básicas executaram sem erros de tooling. Deploy de stacks e automações de integração atenderam requisitos isolados quando testados de forma independente. As ferramentas operaram conforme documentado pelos fabricantes.

A infraestrutura técnica — repositório de dados, conectores LDAP, scripts de automação — demonstrou estabilidade operacional. Quando instruídas com parâmetros claros e consistentes, as ferramentas responderam adequadamente.[^2]

## 3. O que falhou semanticamente

GMUDs tecnicamente corretas falharam porque atributos de identidade não tinham definições compartilhadas entre sistemas, levando a mismatches em sincronizações. Isso evidencia a ausência de um **contrato de identidade semântico**, onde significados de atributos, estados de objetos e autoridade de dados não são alinhados antes da automação.

Sem acordo explícito sobre o que representa conceitos básicos — como "usuário ativo", "identificador primário" ou "fonte autoritativa para atributo X" — os estados de objetos divergem entre fontes. Automações propagam essas divergências, causando inconsistências em cascata.

**Essa ausência de formalização semântica prévia é típica em muitos projetos IAM/IGA**, onde convenções implícitas funcionam em escala pequena mas falham em integrações complexas ou quando equipes distintas assumem significados diferentes para os mesmos termos técnicos.

## 4. O tipo de decisão que faltou

Faltou um **"contrato de identidade"** — um acordo semântico e arquitetural (não jurídico) que define:

- **Identificador canônico**: qual atributo serve como chave única universal (identificador único vs. atributo local)
- **Autoridade de dados**: qual sistema é fonte autoritativa para cada atributo de identidade
- **Estados válidos de sincronização**: quais estados de ciclo de vida são reconhecidos por todos os sistemas (ex: ativo, suspenso, desativado)
- **Modelo canônico**: estrutura comum de dados de identidade que todos os sistemas devem respeitar

Sem esse contrato, cada GMUD assume convenções locais ou implícitas, quebrando consistência em correntes de automação. Sua falta gera inconsistências estruturais em provisionamento e sincronizações.

**Projetos IAM frequentemente pulam essa etapa**, assumindo alinhamento implícito entre sistemas que quebra em cenários reais de integração multi-fonte.

## 5. Por que isso antecede qualquer automação

Decisões semânticas definem:

1. **O modelo canônico de identidade** — estrutura de dados comum entre sistemas
2. **Governança de dados de identidade** — quem edita o quê, e quando
3. **Visão de contexto arquitetural** — quais sistemas são fontes vs. targets, e para quais atributos

O contrato de identidade é pré-requisito, pois define o que a automação deve propagar. Sem esses artefatos prévios, GMUDs técnicas repetem ciclos de retrabalho. Automação sem base semântica amplifica erros iniciais em escala, propagando ambiguidades observadas em integrações IGA.

**Ferramentas IGA são motores de execução, não de decisão semântica.** Elas executam fielmente o que foi modelado — incluindo inconsistências.

## 6. Para que este documento existe

Este registro consolida aprendizados observados no Living Lab como **base conceitual não prescritiva** para futuros artefatos (ex: visões arquiteturais, canvases de decisão, modelos de dados). 

**Não é um ADR.** Não declara decisões obrigatórias nem prescreve frameworks ou soluções. É um documento fundacional que:

- Explica por que decisões de identidade precisam preceder a automação
- Posiciona lições observadas como fundação para evolução do Living Lab
- Serve de referência para arquitetos e GRC no Lab, guiando modelagem antes de novas GMUDs técnicas
- Funciona como base reutilizável para labs semelhantes, priorizando modelagem antes de GMUDs técnicas

Este documento prepara o terreno conceitual para que artefatos de decisão e governança façam sentido quando forem criados.

---

## 7. Glossário de Conceitos

**Contrato de Identidade**  
Acordo semântico e arquitetural (não jurídico) que define identificador canônico, autoridade de dados por atributo, estados válidos de sincronização e modelo canônico de identidade. Pré-requisito para automações IGA consistentes.

**Modelo Canônico de Identidade**  
Estrutura comum de dados de identidade que todos os sistemas integrados devem respeitar, independente de seus esquemas internos.

**Autoridade de Dados**  
Sistema designado como fonte autoritativa (source of truth) para determinado conjunto de atributos de identidade.

**Estados de Sincronização**  
Conjunto acordado de estados de ciclo de vida de identidade reconhecidos por todos os sistemas (ex: ativo, suspenso, desativado, em processo de offboarding).

---

## 8. Referências e Contexto

**GMUDs Relacionadas:**  
Detalhes técnicos em GMUDs 023, 024 e outras integrações IGA (consultar repositório Obsidian).

**Decisões Arquiteturais:**  
ADR-007 e decisões relacionadas a sincronização IGA (arquivo disponível no Lab).

**Documentos Estruturantes:**  
- Manifesto de Estratégia e Infraestrutura Fiqueok v2.0
- ARQ-005 — Memorial Descritivo de Arquitetura
- REL-GMUDs — Relatórios de Encerramento de GMUDs

---

## 9. Controle de Versão

| Versão | Data       | Autor         | Mudanças Principais                          |
|--------|------------|---------------|----------------------------------------------|
| 1.0    | 13/01/2026 | Paulo Feitosa | Criação do documento fundacional DOC-ARC-000 |

---

**Documento mantido por:** Paulo Feitosa (Owner) com suporte de Perplexity Pro (GRC Lead)  
**Repositório:** Obsidian Vault - FiqueokBrain/10-Projetos/PRJ001-LABORATORIO/10-Planning  
**Próxima revisão:** Sob demanda, após ciclos significativos de GMUDs IGA

---

[^1]: Manifesto de Estratégia e Infraestrutura Fiqueok v2.0, ARQ-005 Memorial Descritivo  
[^2]: Detalhes técnicos em GMUDs iniciais disponíveis no repositório do projeto
