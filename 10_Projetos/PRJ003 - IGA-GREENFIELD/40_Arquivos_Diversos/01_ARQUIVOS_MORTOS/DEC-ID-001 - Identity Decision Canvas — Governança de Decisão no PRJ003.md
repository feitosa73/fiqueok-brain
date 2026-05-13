---
**Documento:** DEC-ID-001  
**Título:** Identity Decision Canvas — Governança de Decisão no PRJ003  
**Projeto:** PRJ003 — IGA Greenfield Reference Architecture  
**Tipo:** Canvas de Governança de Decisão em Arquitetura de Identidade  
**Status:** Consolidado  
**Versão:** 1.0  
**Data de Criação:** 14/01/2026  
**Última Revisão:** 14/01/2026  
**Owner do Canvas:** Paulo Feitosa  
**Contexto:** Living Lab Fiqueok 2.0 — Governança para ambiente Greenfield IGA-first  

---

## 1. Objetivo do Canvas

Este Canvas define **como decisões relacionadas à identidade são tomadas no PRJ003**, estabelecendo:

- Tipos de decisão existentes no domínio de identidade  
- Nível de formalidade exigido para cada categoria  
- Limites claros entre decisão semântica e implementação técnica  
- Integração entre Canvases (CAN-ID), ADRs e GMUDs  

O objetivo **não é criar burocracia**, mas **proteger o projeto contra decisões implícitas, improvisadas ou tomadas no nível errado**.[conversation_history]

---

## 2. Princípios de Governança de Decisão

O PRJ003 adota os seguintes princípios fundamentais para decisões de identidade:

1. **Decisões semânticas precedem automação** — semântica deve estar congelada antes de qualquer configuração técnica.  
2. **GMUD técnica não cria semântica** — mudanças técnicas implementam, não definem.  
3. **Configuração não substitui decisão** — configurações não podem criar ou alterar semântica de identidade.  
4. **Estados de identidade não são inferidos por sistemas** — estados semânticos são definidos por eventos de negócio, não por flags técnicas.  
5. **Mudanças estruturais exigem ADR** — alterações no modelo conceitual de identidade requerem Architecture Decision Record.  
6. **Governança proporcional ao contexto do Lab** — formalidade adequada ao ambiente controlado de experimentação.[conversation_history]

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

**Decisões fora do escopo:** arquitetura física, escolha de ferramentas específicas, workflows operacionais de TI sem impacto em identidade.[conversation_history]

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
- **Experimental:** Permitido apenas no Lab, com registro explícito e limite de impacto.[conversation_history]

---

## 6. Relação com Canvases de Identidade (CAN-ID)

As seguintes decisões **já estão congeladas** no PRJ003 e não podem ser alteradas sem ADR formal:

| Canvas | Tipo de Decisão Predominante | Restrições no PRJ003 |
|--------|------------------------------|----------------------|
| **CAN-ID-001** — Identidade Canônica | Arquitetural | Nenhuma GMUD pode alterar identificador ou estrutura semântica |
| **CAN-ID-002** — Autoridade de Dados | Governança | Nenhuma sincronização pode violar autoridade definida por atributo |
| **CAN-ID-003** — Estados da Identidade | Governança | Nenhum sistema pode criar estados implícitos ou inferidos |

**Regra de precedência:**  
Nenhuma GMUD técnica pode contradizer esses canvases. Ajustes experimentais devem ser explicitamente registrados neste DEC-ID-001.[conversation_history]

---

## 7. Regras de Escalonamento de Decisão

Uma decisão deve ser escalada para ADR quando:

- Altera semântica congelada em Canvas CAN-ID.[conversation_history]
- Impacta múltiplos sistemas ou integrações greenfield.[conversation_history]
- Afeta ciclo de vida da identidade ou fluxos JML.[conversation_history]
- Gera impacto regulatório ou de auditoria (ISO 27001, LGPD).[file:21]
- Introduz exceção permanente ou risco de retrabalho.[file:22]

**Fluxo de escalonamento:**
1. Executor identifica decisão fora de escopo técnico.  
2. Notifica Owner/Arquiteto imediatamente.  
3. GMUD é suspensa até decisão formal.  
4. ADR ou Canvas é criado/atualizado.  
5. GMUD é retomada com referências explícitas.[conversation_history]

---

## 8. Decisões Explicitamente PROIBIDAS "em voo"

No PRJ003, **não é permitido** tomar as seguintes decisões durante GMUD técnica ou configuração ad hoc:

- Redefinir identidade canônica ou identificador durante implementação.[conversation_history]
- Alterar autoridade de dados por simples configuração de sincronização.[conversation_history]
- Criar estados implícitos via sistema técnico (ex.: inferir "suspenso" de bloqueio de conta).[conversation_history]
- Resolver conflito semântico apenas “fazendo funcionar” (workaround sem governança).[file:22]
- Modificar precedência de fontes sem atualizar CAN-ID-002.[conversation_history]

**Consequências de violação:**  
- GMUD suspensa imediatamente.  
- Registro como não conformidade (RNC).  
- Escalação para Owner e análise de causa raiz.[file:9]

**Justificativa:** Essas práticas geram retrabalho, fragilidade arquitetural e violam princípios do greenfield IGA-first.[conversation_history]

---

## 9. Exceções e Decisões Experimentais (Lab)

Por se tratar de um **Living Lab**, o PRJ003 permite **decisões experimentais**, desde que:

- O impacto seja **limitado ao ambiente do Lab** (sem propagação para outros projetos).  
- A decisão seja **registrada explicitamente** neste Canvas (seção 15).  
- Não contradiga um Canvas CAN-ID consolidado.  
- Seja tratada como **aprendizado controlado**, não como padrão reutilizável.  

**Prazo de validade de experimentos:** Máximo 7 dias, com análise de lições aprendidas obrigatória.  
**Regularização:** Experimentos bem-sucedidos evoluem para ADR/Canvas; falhas viram lições em REL-GMUD.[file:22]

---

## 10. Integração com GMUD e REL-GMUD

| Artefato | Papel no Processo |
|----------|-------------------|
| **Canvas (CAN-ID/DEC-ID)** | Congela decisões semânticas e de governança antes da automação |
| **ADR** | Altera ou cria decisões congeladas (ex.: revisão de Canvas) |
| **GMUD** | Implementa decisões aprovadas em ambiente técnico (deve referenciar Canvas) |
| **REL-GMUD** | Evidencia execução, resultado e sinaliza decisões não formalizadas |

**Fluxo no PRJ003:**  
GMUD-002 consolidou os Canvases CAN-ID. Este DEC-ID-001 atua como **guia obrigatório** para todas as GMUDs subsequentes do PRJ003.[conversation_history]

---

## 11. Critérios de Sucesso do Canvas

Este Canvas é considerado **eficaz** quando:

- GMUDs técnicas deixam de “decidir em silêncio” (100% referenciam Canvas aplicável).  
- Conflitos semânticos são tratados antes da automação (zero incidentes por ambiguidade).  
- Decisões ficam **rastreáveis** (todas vinculadas a ADR/Canvas/GMUD).  
- O Lab mantém **previsibilidade e aprendizado controlado** (lições capturadas em REL-GMUD).[file:22]

---

## 12. Limites do Canvas

Este documento **não define**:

- Arquitetura física ou infraestrutura (ex.: VLANs, servidores).  
- Escolha de ferramentas ou produtos específicos.  
- Workflows técnicos detalhados de implementação.  
- Processos corporativos completos (foco em identidade/IAM).  

Ele governa **decisão**, não **execução técnica**.[conversation_history]

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

- **GMUDs:** GMUD-025 (Declaração Formal do PRJ003), GMUD-002 (Consolidação dos Canvases CAN-ID).[conversation_history]
- **Canvases:** CAN-ID-001 (Identidade Canônica), CAN-ID-002 (Autoridade de Dados), CAN-ID-003 (Estados da Identidade).[conversation_history]
- **Outros:** README — Framework de Canvases de Arquitetura de Identidade; REL-GMUD-024 (lições de brownfield).[file:22]
- **Frameworks:** ISO 27001:2022 (A.5.22 — Change Management), ITIL v4 (Change Enablement).[file:21]

---

## 15. Controle de Versão

| Versão | Data       | Autor          | Mudança |
|--------|------------|----------------|---------|
| 1.0    | 2026-01-14 | Paulo Feitosa  | Criação do DEC-ID-001 para governança do PRJ003 |

---

## 16. Observações e Notas de Governança

- Este Canvas é **proporcional ao contexto do Living Lab**: formalidade alta para decisões semânticas, flexibilidade para experimentos controlados.[conversation_history]
- **Primeira violação** de decisão proibida gera alerta e registro. **Segunda violação** gera escalação para Owner e análise de causa raiz.[file:22]
- Canvas deve ser revisado **trimestralmente** ou após cada sprint de experimentação significativa.[conversation_history]

---

**Nome do arquivo:** `DEC-ID-001-Identity-Decision-Canvas-PRJ003-v1.0.md`  

**Localização recomendada no Obsidian:**  
`/10-Projetos/PRJ003-IGA-GREENFIELD/20-Governanca/Canvases/DEC-ID-001-Identity-Decision-Canvas.md`

**Status do documento:** ✅ **Pronto para download e uso**. Todas as dúvidas foram resolvidas com base no esboço, templates anteriores e histórico de conversa. Copie o conteúdo acima diretamente para o arquivo MD!

---
