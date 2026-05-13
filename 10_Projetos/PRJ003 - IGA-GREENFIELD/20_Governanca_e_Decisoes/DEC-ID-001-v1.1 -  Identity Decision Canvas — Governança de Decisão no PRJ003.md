---
**Documento:** DEC-ID-001  
**Título:** Identity Decision Canvas — Governança de Decisão no PRJ003  
**Projeto:** PRJ003 — IGA Greenfield Reference Architecture  
**Tipo:** Canvas de Governança de Decisão em Arquitetura de Identidade  
**Status:** Consolidado  
**Versão:** 1.1  
**Data de Criação:** 14/01/2026  
**Última Revisão:** 17/01/2026  
**Owner do Canvas:** Paulo Feitosa  
**Contexto:** Living Lab Fiqueok 2.0 — Governança para ambiente Greenfield IGA-first  

---

## 1. Objetivo do Canvas

Este Canvas define **como decisões relacionadas à identidade são tomadas no PRJ003**, estabelecendo:

- Tipos de decisão existentes no domínio de identidade  
- Nível de formalidade exigido para cada categoria  
- Limites claros entre decisão semântica e implementação técnica  
- Integração entre Canvases (CAN-ID), ADRs e GMUDs  

O objetivo **não é criar burocracia**, mas **proteger o projeto contra decisões implícitas, improvisadas ou tomadas no nível errado**.

---

## 2. Princípios de Governança de Decisão

O PRJ003 adota os seguintes princípios fundamentais para decisões de identidade:

1. **Decisões semânticas precedem automação** — semântica deve estar congelada antes de qualquer configuração técnica.  
2. **GMUD técnica não cria semântica** — mudanças técnicas implementam, não definem.  
3. **Configuração não substitui decisão** — configurações não podem criar ou alterar semântica de identidade.  
4. **Estados de identidade não são inferidos por sistemas** — estados semânticos são definidos por eventos de negócio, não por flags técnicas.  
5. **Mudanças estruturais exigem ADR** — alterações no modelo conceitual de identidade requerem Architecture Decision Record.  
6. **Governança proporcional ao contexto do Lab** — formalidade adequada ao ambiente controlado de experimentação.

---

## 3. Escopo de Decisões Abrangidas

Este Canvas se aplica a decisões relacionadas aos seguintes temas no PRJ003:

- Identidade canônica e estrutura semântica  
- Atributos e dados de identidade (autoridade e precedência)  
- Estados e ciclo de vida da identidade  
- Integrações IAM/IGA no ambiente greenfield  
- Automação de acessos e fluxos JML  
- Políticas de segurança e segregação de funções  
- Exceções e desvios experimentais (específicos do Lab)  
- Compliance e rastreabilidade para auditoria  

**Decisões fora do escopo:** arquitetura física, escolha de ferramentas específicas, workflows operacionais de TI sem impacto em identidade.

---

## 4. Tipos de Decisão no PRJ003

| Tipo de Decisão | Descrição | Exemplos no PRJ003 |
|-----------------|-----------|-------------------|
| **Arquitetural** | Afeta significado, estrutura ou contratos semânticos de identidade | Identificador canônico; modelo de identidade; limites entre identidade/conta/sistema |
| **Governança** | Afeta autoridade, precedência, regras ou processos decisórios | Autoridade por atributo; resolução de conflitos; governança de estados |
| **Técnica** | Afeta implementação, configuração ou automação de ferramentas | Configuração de conectores; mappings de atributos; parâmetros de sincronização |
| **Operacional** | Afeta execução recorrente, manutenção ou suporte | Agendamento de sincronizações; monitoramento de integrações; troubleshooting |
| **Experimental** | Decisão controlada para aprendizado no Lab, com impacto limitado | Testes de hipóteses arquiteturais; validações de trade-offs; POCs sem precedentes |

---

## 5. Matriz de Decisão e Responsabilidade

| Tipo de Decisão | Responsável / Papel | Artefato Obrigatório | Aprovador | Pode ocorrer em GMUD técnica? | Prazo de Formalização |
|----------------|---------------------|----------------------|-----------|-------------------------------|----------------------|
| **Arquitetural** | Owner do Projeto (Paulo Feitosa) | ADR + Canvas CAN-ID | Owner do Projeto + Arquiteto | ❌ Não | Antes da implementação |
| **Governança** | Owner do Projeto | Canvas CAN-ID | Comitê de Governança (Owner + GRC) | ❌ Não | Antes da automação |
| **Técnica** | Executor da GMUD | GMUD Técnica | Arquiteto (review obrigatório) | ✅ Sim | Durante GMUD |
| **Operacional** | Executor | Procedimento Operacional (POP) | Gestor de Operações | ✅ Sim | Conforme SLA do Lab |
| **Experimental** | Owner do Projeto | Registro no Canvas DEC-ID | Owner (auto-aprovação) | ⚠️ Exceção controlada | Máximo 48h após experimento |

**Observações sobre a matriz:**  
- **ADR:** Documento formal com contexto, alternativas, consequências e justificativa.  
- **Canvas CAN-ID:** Artefato estruturado para decisões semânticas/governança (CAN-ID-001, 002, 003).  
- **Experimental:** Permitido apenas no Lab, com registro explícito e limite de impacto.

---

## 6. Relação com Canvases de Identidade (CAN-ID)

As seguintes decisões **já estão congeladas** no PRJ003 e não podem ser alteradas sem ADR formal:

| Canvas | Tipo de Decisão Predominante | Restrições no PRJ003 |
|--------|------------------------------|----------------------|
| **CAN-ID-001** — Identidade Canônica | Arquitetural | Nenhuma GMUD pode alterar identificador ou estrutura semântica |
| **CAN-ID-002** — Autoridade de Dados | Governança | Nenhuma sincronização pode violar autoridade definida por atributo |
| **CAN-ID-003** — Estados da Identidade | Governança | Nenhum sistema pode criar estados implícitos ou inferidos |

**Regra de precedência:**  
Nenhuma GMUD técnica pode contradizer esses canvases. Ajustes experimentais devem ser explicitamente registrados neste DEC-ID-001.

---

## 7. Regras de Escalonamento de Decisão

Uma decisão deve ser escalada para ADR quando:

- Altera semântica congelada em Canvas CAN-ID.
- Impacta múltiplos sistemas ou integrações greenfield.
- Afeta ciclo de vida da identidade ou fluxos JML.
- Gera impacto regulatório ou de auditoria (ISO/IEC 27001:2022, LGPD).
- Introduz exceção permanente ou risco de retrabalho.

**Fluxo de escalonamento:**
1. Executor identifica decisão fora de escopo técnico.  
2. Notifica Owner/Arquiteto imediatamente.  
3. GMUD é suspensa até decisão formal.  
4. ADR ou Canvas é criado/atualizado.  
5. GMUD é retomada com referências explícitas.

---

## 8. Decisões Explicitamente PROIBIDAS "em voo"

No PRJ003, **não é permitido** tomar as seguintes decisões durante GMUD técnica ou configuração ad hoc:

- Redefinir identidade canônica ou identificador durante implementação.
- Alterar autoridade de dados por simples configuração de sincronização.
- Criar estados implícitos via sistema técnico (ex.: inferir "suspenso" de bloqueio de conta).
- Resolver conflito semântico apenas "fazendo funcionar" (workaround sem governança).
- Modificar precedência de fontes sem atualizar CAN-ID-002.

**Consequências de violação:**  
- GMUD suspensa imediatamente.  
- Registro como não conformidade (RNC).  
- Escalação para Owner e análise de causa raiz.

**Justificativa:** Essas práticas geram retrabalho, fragilidade arquitetural e violam princípios do greenfield IGA-first.

---

## 9. Exceções e Decisões Experimentais (Lab)

Por se tratar de um **Living Lab**, o PRJ003 permite **decisões experimentais**, desde que:

- O impacto seja **limitado ao ambiente do Lab** (sem propagação para outros projetos).  
- A decisão seja **registrada explicitamente** neste Canvas (seção 16).  
- Não contradiga um Canvas CAN-ID consolidado.  
- Seja tratada como **aprendizado controlado**, não como padrão reutilizável.  

**Prazo de validade de experimentos:** Máximo 7 dias, com análise de lições aprendidas obrigatória.  
**Regularização:** Experimentos bem-sucedidos evoluem para ADR/Canvas; falhas viram lições em REL-GMUD.

---

## 10. Integração com GMUD e REL-GMUD

| Artefato | Papel no Processo |
|----------|-------------------|
| **Canvas (CAN-ID/DEC-ID)** | Congela decisões semânticas e de governança antes da automação |
| **ADR** | Altera ou cria decisões congeladas (ex.: revisão de Canvas) |
| **GMUD** | Implementa decisões aprovadas em ambiente técnico (deve referenciar Canvas) |
| **REL-GMUD** | Evidencia execução, resultado e sinaliza decisões não formalizadas |

**Fluxo no PRJ003:**  
GMUD-002 consolidou os Canvases CAN-ID. Este DEC-ID-001 atua como **guia obrigatório** para todas as GMUDs subsequentes do PRJ003.

---

## 11. Critérios de Sucesso do Canvas

Este Canvas é considerado **eficaz** quando:

- GMUDs técnicas deixam de "decidir em silêncio" (100% referenciam Canvas aplicável).  
- Conflitos semânticos são tratados antes da automação (zero incidentes por ambiguidade).  
- Decisões ficam **rastreáveis** (todas vinculadas a ADR/Canvas/GMUD).  
- O Lab mantém **previsibilidade e aprendizado controlado** (lições capturadas em REL-GMUD).

---

## 12. Limites do Canvas

Este documento **não define**:

- Arquitetura física ou infraestrutura (ex.: VLANs, servidores).  
- Escolha de ferramentas ou produtos específicos.  
- Workflows técnicos detalhados de implementação.  
- Processos corporativos completos (foco em identidade/IAM).  

Ele governa **decisão**, não **execução técnica**.

---

## 13. Stakeholders e Aprovações

| Papel | Nome | Área | Data de Aprovação | Status |
|-------|------|------|-------------------|--------|
| Owner do Projeto | Paulo Feitosa | GRC / IAM Lead | 14/01/2026 | ✅ Aprovado |
| Arquiteto de Identidade | Paulo Feitosa | Arquitetura | 14/01/2026 | ✅ Aprovado |
| GRC Lead | Paulo Feitosa | Governança | 14/01/2026 | ✅ Aprovado |
| Gestor de Mudanças | Paulo Feitosa | Change Management | 14/01/2026 | ✅ Aprovado |

---

## 14. Referências

- **GMUDs:** GMUD-025 (Declaração Formal do PRJ003), GMUD-002 (Consolidação dos Canvases CAN-ID), GMUD-005 (Deploy Funcional midPoint).
- **Canvases:** CAN-ID-001 (Identidade Canônica), CAN-ID-002 (Autoridade de Dados), CAN-ID-003 (Estados da Identidade).
- **ADRs:** ADR-001 (Estratégia de Reversibilidade via Checkpoint e Priorização de IaC).
- **Outros:** README — Framework de Canvases de Arquitetura de Identidade; REL-GMUD-024 (lições de brownfield).
- **Frameworks:** ISO/IEC 27001:2022 (A.8.32 — Gestão de Mudanças), ITIL v4 (Change Enablement).

---

## 15. Controle de Versão

| Versão | Data | Autor | Mudança |
|--------|------|-------|---------|
| 1.0 | 2026-01-14 | Paulo Feitosa | Criação inicial do DEC-ID-001 |
| 1.1 | 2026-01-17 | Paulo Feitosa | Correção de referência normativa para ISO/IEC 27001:2022 (A.8.32) e inclusão de diretriz de Rollback via Hyper-V |

---

## 16. Observações e Notas de Governança

- Este Canvas é **proporcional ao contexto do Living Lab**: formalidade alta para decisões semânticas, flexibilidade para experimentos controlados.
- **Primeira violação** de decisão proibida gera alerta e registro. **Segunda violação** gera escalação para Owner e análise de causa raiz.
- Canvas deve ser revisado **trimestralmente** ou após cada sprint de experimentação significativa.

### Nota Técnica de Conformidade ISO/IEC 27001:2022

**Este canvas implementa os requisitos de controle de mudanças internas conforme o controle A.8.32 (Gestão de Mudanças), utilizando Pontos de Verificação (Checkpoints) de infraestrutura como mecanismo formal de fallback e recuperação de desastres.**

A estratégia de reversibilidade obrigatória via Checkpoint Hyper-V (formalizada no ADR-001) atende diretamente aos requisitos de:

- **Procedimentos de recuperação documentados**: Scripts de automação (IaC) servem como documentação executável de mudanças.
- **Capacidade de rollback**: Checkpoints garantem retorno ao estado anterior validado em caso de falha.
- **Rastreabilidade de mudanças**: GMUDs referenciam checkpoints específicos e scripts versionados.
- **Minimização de impacto**: Rollbacks instantâneos reduzem janela de indisponibilidade.
- **Testes de procedimentos de mudança**: Checkpoints permitem múltiplas execuções em ambiente controlado.

Esta abordagem posiciona o PRJ003 como **audit-ready** para avaliações de conformidade em gestão de mudanças de TI.

---

**Nome do arquivo:** `DEC-ID-001-Identity-Decision-Canvas-PRJ003-v1.1.md`  

**Localização recomendada no Obsidian:**  
`/10-Projetos/PRJ003-IGA-GREENFIELD/20-Governanca-e-Decisoes/Canvases/DEC-ID-001.md`

**Status do documento:** ✅ **Pronto para uso e auditoria**.
