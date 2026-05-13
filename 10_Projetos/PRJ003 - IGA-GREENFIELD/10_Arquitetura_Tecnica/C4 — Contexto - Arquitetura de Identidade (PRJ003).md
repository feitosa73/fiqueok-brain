

**Projeto:** PRJ003 — IGA Greenfield Reference Architecture  
**Artefato:** C4 – Diagrama de Contexto (Identidade e Acesso)  
**Status:** Consolidado  
**Data:** 2026-01-14  
**Owner:** Paulo Feitosa  
**Contexto:** Living Lab Fiqueok 2.0  

---

## 1. Objetivo do Artefato

Este artefato descreve o **contexto arquitetural da identidade** no PRJ003, apresentando:

- os principais atores e sistemas
- os domínios envolvidos
- as relações de alto nível
- o posicionamento do IGA como **orquestrador semântico**

O C4 **não cria decisões**.  
Ele **materializa decisões já congeladas** nos Canvases CAN-ID e no DEC-ID.

---

## 2. Escopo e Limites

### Incluído no Escopo
- fontes de identidade
- orquestração de identidade
- sistemas consumidores de acesso
- governança de decisão

### Fora do Escopo
- protocolos técnicos
- conectores
- workflows JML
- mapeamento de atributos
- automações específicas

---

## 3. Atores (Pessoas)

| Ator | Papel no Ecossistema |
|----|----------------------|
| Colaborador / Usuário | Possui identidade e consome acesso |
| RH / Negócio | Origina eventos e dados organizacionais |
| Segurança / IAM | Governa identidade e decisões |
| TI / Infra | Opera sistemas técnicos |

---

## 4. Sistemas Principais (Nível Contexto)

| Sistema | Tipo | Responsabilidade |
|------|------|------------------|
| **IGA** | Orquestrador | Consolidação da identidade canônica, estados e decisões |
| **HR / Sistema de Negócio** | Fonte Autoritativa | Eventos de lifecycle e dados organizacionais |
| **Diretório (AD / LDAP)** | Sistema Técnico | Autenticação e contas |
| **Aplicações** | Consumidores | Autorização baseada em identidade |
| **Plataforma de Governança** | Governança | Auditoria, evidências, compliance |

> O IGA **não é fonte primária de verdade do negócio**  
> e **não decide semântica em isolamento**.

---

## 5. Domínios Arquiteturais

| Domínio | Descrição |
|------|-----------|
| **Domínio de Identidade** | Onde a identidade canônica é definida e consolidada |
| **Domínio de Negócio** | Onde eventos organizacionais se originam |
| **Domínio Técnico** | Onde autenticação e acesso são executados |
| **Domínio de Governança** | Onde decisões são tomadas e rastreadas |

Cada domínio possui **responsabilidade clara** e **limites explícitos**.

---

## 6. Relações de Alto Nível

- O **Domínio de Negócio** (HR) origina eventos de identidade
- O **IGA** consolida a identidade canônica e seus estados
- Sistemas técnicos **consomem decisões**, não as criam
- O **Domínio de Governança** define regras e valida mudanças
- Nenhum sistema técnico altera semântica de identidade

---

## 7. Posicionamento do IGA

No PRJ003, o IGA atua como:

- **Orquestrador semântico**
- **Ponto de consolidação da identidade**
- **Executor de decisões aprovadas**
- **Produtor de evidências**

O IGA **não**:
- substitui sistemas de negócio
- decide autoridade de dados
- cria estados implícitos
- resolve conflitos por configuração

---

## 8. Representação Visual (C4 – Contexto)

> **Diagrama a ser mantido alinhado aos Canvases CAN-ID**

Componentes esperados no diagrama:
- Pessoas (Usuário, RH, Segurança)
- Sistemas (HR, IGA, Diretório, Apps)
- Fronteiras de domínio
- Fluxos de alto nível (informativos)

Ferramenta sugerida:
- Draw.io / Excalidraw / PlantUML

---

## 9. Alinhamento com Decisões de Identidade

Este C4 materializa explicitamente:

- **CAN-ID-001** — Identidade Canônica  
- **CAN-ID-002** — Autoridade de Dados de Identidade  
- **CAN-ID-003** — Estados da Identidade  
- **DEC-ID-001** — Governança de Decisão  

> Em caso de divergência, **o C4 deve ser ajustado**, não os Canvases.

---

## 10. Uso do Artefato

Este C4 deve ser utilizado para:
- entendimento comum entre áreas
- onboarding técnico e não técnico
- base para decisões de integração
- ponto de partida para C4 – Container e Component

---

## 11. Limitações

Este artefato **não substitui**:
- GMUDs técnicas
- documentação de integração
- fluxos JML
- decisões semânticas

Ele **explica o contexto**, não **normatiza execução**.

---

## 12. Referências

- GMUD-003 — Arquitetura Lógica de Identidade  
- DEC-ID-001 — Identity Decision Canvas  
- CAN-ID-001 — Identidade Canônica  
- CAN-ID-002 — Autoridade de Dados  
- CAN-ID-003 — Estados da Identidade  

---

## 13. Controle de Versão

| Versão | Data | Autor | Mudança |
|------|------|------|--------|
| 1.0 | 2026-01-14 | Paulo Feitosa | Criação do C4 de Contexto do PRJ003 |
