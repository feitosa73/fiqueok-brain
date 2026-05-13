---
**Documento:** TEMPLATE-C4-CONTEXT-IDENTITY  
**Título:** Template — C4 Contexto: Arquitetura de Identidade (IAM/IGA)  
**Tipo:** Template Reutilizável — Artefato C4 Model (Nível 1: Context)  
**Domínio:** Identidade e Acesso (IAM / IGA / GRC)  
**Versão:** 2.0  
**Data:** 14/01/2026  
**Aplicabilidade:** Universal — Projetos IAM/IGA/Identity Governance  
**Independente de:** Ferramenta, vendor, plataforma, organização  

---

## Propósito do Template

Este template define a estrutura para criar **diagramas C4 de Contexto** (Nível 1) em projetos de identidade, visualizando:

- Sistemas principais envolvidos no ecossistema de identidade  
- Limites de responsabilidade entre domínios arquiteturais  
- Interações de alto nível (fluxos de informação semântica)  
- Posicionamento do IGA no contexto organizacional  

**O C4 não toma decisões.** Ele **materializa decisões já congeladas** em Canvases (CAN-ID), ADRs e princípios arquiteturais.[conversation_history]

**C4 Context (L1):** Visão "a 30.000 pés de altitude" — para alinhamento com stakeholders de negócio, gestão e auditoria.

---

## 1. Identificação

**Projeto:**  
_(Nome do projeto ou iniciativa IAM/IGA)_

**Artefato:** C4 — Diagrama de Contexto (Nível 1)  
**Escopo:** Ecossistema de Identidade e Acesso  
**Versão:**  
_(Formato: X.Y — major.minor)_

**Status:**  
- [ ] Rascunho  
- [ ] Validado  
- [ ] Aprovado  
- [ ] Ativo  
- [ ] Obsoleto  

**Data de Criação:**  
_(dd/mm/aaaa)_

**Última Revisão:**  
_(dd/mm/aaaa)_

**Owner:**  
_(Nome e área do responsável pelo artefato)_

---

## 2. Objetivo do Artefato

Este artefato tem como objetivo **visualizar o contexto arquitetural da identidade**, mostrando:

- **Principais sistemas** que geram, consomem ou governam identidade  
- **Limites de responsabilidade** entre domínios (negócio, TI, segurança)  
- **Interações de alto nível** (fluxos semânticos, não técnicos)  
- **Posicionamento do IGA** como orquestrador semântico no ecossistema  
- **Fronteiras claras** entre identidade canônica, contas técnicas e acessos  

**Uso recomendado:**
- Onboarding de stakeholders não técnicos  
- Alinhamento inicial de arquitetura  
- Validação de entendimento comum  
- Base para níveis C4 subsequentes (Containers, Components)  
- Comunicação com auditoria e compliance  

---

## 3. Escopo e Limites

### 3.1 Incluído no Escopo

- **Atores humanos** relevantes (usuários finais, RH, segurança, TI)  
- **Sistemas principais** que interagem com identidade (fontes, IGA, diretórios, aplicações)  
- **Fluxos de informação de alto nível** (eventos semânticos, não protocolos técnicos)  
- **Fronteiras entre domínios** arquiteturais (negócio, identidade, TI, segurança)  

### 3.2 Fora do Escopo (Explicitamente Excluído)

- Detalhes técnicos (protocolos, portas, formatos, conectores)  
- Fluxos JML detalhados (Joiner/Mover/Leaver)  
- Mapeamento de atributos ou schemas  
- Configurações específicas de ferramentas  
- Automações ou workflows operacionais  
- Infraestrutura física (redes, servidores, storage)  

**Regra:** Se precisa de zoom técnico, use C4 Containers/Components. Este é **alto nível puro**.[conversation_history]

---

## 4. Atores (Pessoas / Personas)

Listar os **principais atores humanos** que interagem com o ecossistema de identidade.

| Ator | Papel / Responsabilidade | Interação Principal com Identidade |
|------|---------------------------|------------------------------------|
| **Usuário Final** | Consome acessos e serviços | Autenticação, autorização, self-service básico |
| **Gestor de RH / Negócio** | Origina dados e eventos de lifecycle | Fornece dados de onboarding/offboarding, mudanças organizacionais |
| **Equipe de Segurança / IAM** | Governa identidade e acessos | Monitora, aprova exceções, gerencia políticas |
| **Equipe de TI / Infra** | Opera sistemas técnicos | Provisiona contas, gerencia diretórios, integra aplicações |
| **Auditor / Compliance** | Valida conformidade e rastreabilidade | Consulta logs, valida controles, audita processos |

**Notas sobre atores:**
- Foco em **papéis organizacionais**, não pessoas específicas.  
- Incluir apenas atores que **geram ou consomem identidade diretamente**.[conversation_history]

---

## 5. Sistemas Principais (Nível Contexto)

Listar os **sistemas relevantes** no ecossistema de identidade, **sem entrar em detalhes técnicos**.

| Sistema | Tipo | Responsabilidade Principal | Fonte/Consumidor de Identidade |
|---------|------|-----------------------------|-------------------------------|
| **IGA / Identity Platform** | Orquestrador Central | Consolida identidade canônica, governa estados e acessos | Fonte canônica / Consumidor de fontes externas |
| **Sistema de RH / HRIS** | Fonte de Negócio | Origem de dados pessoais, organizacionais e eventos de lifecycle | Fonte autoritativa (dados de negócio) |
| **Active Directory / LDAP** | Sistema Técnico | Autenticação, autorização, contas técnicas | Consumidor (reflete identidade canônica) |
| **Aplicações Críticas** | Consumidor de Acessos | Executam autorização baseada em identidade | Consumidor (recebe acessos do IGA) |
| **Outras Fontes** | Fontes Específicas | Dados complementares (ex.: terceiros, fornecedores) | Fonte secundária / Consumidor |

**Critérios de inclusão:**
- Sistemas que **geram, modificam ou consomem** dados de identidade.  
- Máximo 6–8 sistemas para manter legibilidade no nível contexto.[conversation_history]

---

## 6. Domínios Arquiteturais

Descrever os **domínios organizacionais** envolvidos no ecossistema de identidade.

| Domínio | Descrição | Responsabilidade em Identidade | Exemplos de Sistemas |
|---------|-----------|--------------------------------|----------------------|
| **Domínio de Negócio** | Origem de eventos e dados de negócio | Gera mudanças de lifecycle, dados pessoais/organizacionais | RH/HRIS, ERP, CRM |
| **Domínio de Identidade** | Governança semântica centralizada | Consolida identidade canônica, aplica regras de governança | Plataforma IGA (midPoint, SailPoint, Okta) |
| **Domínio Técnico** | Infraestrutura de acessos e autenticação | Executa autenticação, provisiona contas técnicas | AD/LDAP, SSO, VPN |
| **Domínio de Governança** | Decisões e conformidade | Define políticas, aprova exceções, audita | GRC tools, Auditoria, Compliance |

**Fronteiras claras:**
- **Negócio → Identidade:** eventos semânticos (contratação, promoção, desligamento).  
- **Identidade → Técnico:** decisões executáveis (provisionar conta, desabilitar acesso).  
- **Governança:** supervisiona todos os domínios, sem executar operações.[conversation_history]

---

## 7. Relações de Alto Nível

Descrever as **interações principais** entre atores, domínios e sistemas, em nível conceitual.

### Fluxos Semânticos Principais

1. **Eventos de Negócio → IGA:**  
   RH informa contratação/promoção/desligamento → IGA atualiza estado canônico → propaga para sistemas técnicos.[conversation_history]

2. **IGA → Sistemas Técnicos:**  
   IGA orquestra provisionamento/deprovisionamento → AD provisiona conta → aplicações consomem acessos.

3. **Usuário → Sistemas:**  
   Usuário autentica no AD → aplicações autorizam via identidade propagada.

4. **Governança → Todos:**  
   Políticas e exceções aprovadas → aplicadas via IGA.

**Representação textual (pré-diagrama):**

[RH/Negócio] --> eventos de lifecycle --> [IGA]  
[IGA] --> identidade canônica --> [AD/LDAP]  
[AD/LDAP] --> autenticação/autorização --> [Aplicações]  
[Governança] ⊢ regras/políticas ⊢ [IGA]  
[Usuário] --> acessa --> [Aplicações]



**Notas:** Fluxos são **semânticos**, não técnicos (sem protocolos, formatos ou ferramentas específicas).[conversation_history]

---

## 8. Representação Visual (C4 – Contexto)

### 8.1 Ferramenta Utilizada

- **Ferramenta:** Draw.io / Excalidraw / PlantUML / Mermaid (recomendado para MD)  
- **Versão do Diagrama:** 1.0  
- **Link/Embed:**  
  _(Inserir link para diagrama ou código Mermaid/PlantUML abaixo)_

### 8.2 Código Mermaid para Diagrama C4 Context (Copiar e Colar)



```mermaid
C4Context
    title "Ecossistema de Identidade - Contexto (C4 L1)"
    
    Person(ator1, "Usuário Final", "Consome acessos")
    Person(ator2, "RH/Negócio", "Origina eventos e dados")
    Person(ator3, "Segurança/IAM", "Governa acessos")
    Person(ator4, "TI/Infra", "Opera sistemas técnicos")
    
    System(iga, "IGA", "Orquestrador Central", "Consolida identidade canônica")
    System(hr, "Sistema RH/HRIS", "Fonte de Negócio", "Dados pessoais e eventos")
    System(ad, "AD/LDAP", "Sistema Técnico", "Autenticação e contas")
    System(apps, "Aplicações Críticas", "Consumidor", "Executam autorização")
    
    System_Ext(gov, "Governança/GRC", "Define políticas e aprova exceções")
    
    Rel(ator2, hr, "Fornece dados\neventos")
    Rel(hr, iga, "Dados de negócio\nevents de lifecycle")
    Rel(iga, ad, "Identidade canônica\nestados")
    Rel(ad, apps, "Autenticação\nautorização")
    Rel(ator1, apps, "Acessa serviços")
    Rel(gov, iga, "Políticas\nexceções")
    Rel(ator3, iga, "Monitora\ngoverna")
    Rel(ator4, ad, "Opera\nmantém")


**Instruções para visualização:**

1. Copie o código Mermaid acima.
    
2. Cole em ferramenta compatível (Obsidian com plugin Mermaid, GitHub, Mermaid.live).
    
3. Ajuste ícones, cores e legendas conforme necessário.
    
4. Exporte como SVG/PNG para inclusão em documentação.
    

**Legenda do Diagrama:**

- **Personas azuis:** Atores humanos.
    
- **Sistemas verdes:** Domínio de controle do projeto.
    
- **Sistemas amarelos:** Sistemas externos/integrados.
    
- Setas: Fluxos semânticos de alto nível.[conversation_history]
    

---

###  9. Alinhamento com Decisões de Identidade

Indicar explicitamente **quais decisões este C4 materializa**:

|Decisão Congelada|Canvas/ADR Referenciado|Reflexo no Diagrama|
|---|---|---|
|Identidade Canônica|CAN-ID-001|IGA como orquestrador central|
|Autoridade de Dados|CAN-ID-002|HR como fonte de negócio|
|Estados da Identidade|CAN-ID-003|Fluxos de lifecycle → IGA|
|Governança de Decisão|DEC-ID-001|Governança ⊢ IGA|

**Regra de integridade:**  
Se houver divergência entre o diagrama e os Canvases/ADRs, **o C4 está errado**, não os Canvases. Sempre validar contra decisões congeladas.[conversation_history]

---

## 10. Uso do Artefato

Este C4 deve ser utilizado para:

- **Onboarding de stakeholders** não técnicos (negócio, gestão, auditoria)
    
- **Validação de entendimento comum** entre áreas
    
- **Comunicação visual** com executivos e comitês
    
- **Base para níveis C4 subsequentes** (Containers → Components → Code)
    
- **Referência em auditorias** e revisões de arquitetura
    

**Boas práticas:**

- Manter **máximo 6–8 sistemas** para legibilidade.
    
- Usar **linguagem semântica**, não técnica (ex.: "eventos de lifecycle", não "LDAP sync").
    
- Atualizar sempre que **nova fonte de identidade** for onboarded.[conversation_history]
    

---

## 11. Limitações do Artefato

Este C4 **não substitui**:

- Documentação técnica detalhada (conectores, mappings, configs)
    
- Fluxos JML ou workflows operacionais
    
- GMUDs ou change requests
    
- Decisões semânticas (Canvases CAN-ID)
    

Ele é **visual e explicativo**, não normativo ou prescritivo. Para detalhes, descer para C4 Containers/Components.[conversation_history]

---

## 12. Referências

- **Canvases de Decisão:** CAN-ID-001, CAN-ID-002, CAN-ID-003, DEC-ID-001
    
- **ADRs:** _(Listar ADRs relevantes para decisões arquiteturais)_
    
- **README Framework:** README — Framework de Canvases de Arquitetura de Identidade
    
- **C4 Model:** c4model.com (referência original do método C4)
    
- **GMUDs Relacionadas:** _(GMUDs que dependem deste contexto)_
    

---

## 13. Controle de Versão

|Versão|Data|Autor|Mudança|
|---|---|---|---|
|1.0|||Criação inicial do C4 Context|
|||||

---

## 14. Observações e Notas de Governança

_(Espaço para considerações específicas do projeto)_

**Exemplos:**

- "Este C4 reflete arquitetura IGA-first greenfield; brownfield requer C4 separado."
    
- "IGA é fonte canônica; sistemas são consumidores."
    
- "Atualizar após onboarding de nova fonte de identidade (ex.: fornecedores)."
    

---

## Instruções de Uso

## Para criar C4 Context a partir deste template:

1. Copie este template para novo arquivo MD.
    
2. Renomeie: `C4-CONTEXT-IDENTITY-[Projeto]-vX.Y.md`.
    
3. Preencha seções 1–7 com dados do projeto.
    
4. **Copie o código Mermaid da seção 8.2** e ajuste:
    
    - Adicione/remova atores e sistemas conforme tabela 4–5.
        
    - Defina relações conforme seção 7.
        
5. Renderize em Mermaid.live ou Obsidian (plugin Mermaid).
    
6. Exporte como SVG/PNG e inclua no documento.
    
7. Valide alinhamento com Canvases CAN-ID (seção 9).
    
8. Obtenha aprovação dos stakeholders (seção 13).
    
9. Publique junto à documentação de arquitetura do projeto.
    

**Ferramentas recomendadas:**

- **Mermaid** (nativo MD, GitHub, Obsidian).
    
- **Draw.io** (export SVG para documentação).
    
- **PlantUML** (para integrações CI/CD).
    

**Nome do arquivo sugerido:** `TEMPLATE-C4-CONTEXT-IDENTITY-v2.0.md`

**Localização recomendada:** `/Templates/Arquitetura/C4-Identity/` ou pasta de templates de arquitetura

**Status:** ✅ **Pronto para download e uso imediato**. Template completo, agnóstico e alinhado com o framework de Canvases de Identidade!