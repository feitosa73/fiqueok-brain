# 

> **Status:** 🟢 Ativo  
> **Versão:** 2.0  
> **Data:** 28/12/2025  
> **Visão:** Arquitetura de Segurança, GRC & CISO Enablement  
> **Owner:** Paulo Feitosa (Fiqueok Consultoria)

---

## 📋 Changelog

| Versão | Data | Mudanças Principais | Documento de Decisão |
|--------|------|---------------------|----------------------|
| **1.0** | 19/12/2025 | Manifesto inicial - Migração VirtualBox → Hyper-V | [[PRJ-INFRA-001]] |
| **2.0** | 28/12/2025 | Redistribuição de papéis das IAs + RACI integrado | [[ADR-001]] |

---

## 1. O Conceito (Visão Estratégica)

Este ambiente é um **Ecossistema Integrado de Experimentação e Governança**, projetado para transpor a teoria dos frameworks de segurança para a prática tecnológica.

### 1.1. Natureza da Fiqueok

**A Fiqueok não é uma consultoria comercial ativa.** É uma **plataforma de aprendizado técnico** e **marca pessoal** do Paulo, criada como espaço para:

- 🎓 **Desenvolvimento de maturidade** em GRC, risco cibernético e IAM
- 🔬 **Aplicação prática de frameworks** (ISO 27001/27005, NIST, COSO)
- 📊 **Simulação de ambientes corporativos** em labs controlados
- 📝 **Produção de análises técnicas** e documentação de alto nível
- 🌐 **Compartilhamento transparente** da jornada de transição profissional

**Não há cases reais de consultoria ou auditoria comercial neste momento.** Todo o trabalho é focado em **aprendizado aplicado, análise e simulação**.

---

### 1.2. Objetivos do Lab

O Lab não se trata apenas de configurar ferramentas, mas de simular a convergência entre:

1. **Infraestrutura de Base:** Redes e Diretórios (AD)
2. **Operação de Cibersegurança:** IAM, PAM, IGA, SIEM, DLP, AppSec
3. **Gestão de Risco e Conformidade (GRC):** ISO 27001, CIS Controls, NIST

**Objetivo Final:** Habilitar atuação de alto nível como **Arquiteto de Soluções**, **Gestor de Cibersegurança (CISO)** e **Líder de GRC**, desenvolvendo competências para desenhar, implementar e auditar ambientes corporativos complexos.

---

## 2. Arquitetura Organizacional (Governança de IAs)

### 2.1. Estrutura de Equipe (Humano + IAs)

```
                    ┌─────────────────────┐
                    │   Paulo Feitosa     │
                    │   (Owner & CISO)    │
                    │   Decision Maker    │
                    └──────────┬──────────┘
                               │
                ┌──────────────┼──────────────┐
                │              │              │
        ┌───────▼──────┐ ┌────▼─────┐ ┌─────▼──────┐
        │    Claude    │ │ ChatGPT  │ │Perplexity  │
        │ GRC Lead     │ │Architect │ │Intelligence│
        │ (Memory)     │ │(Executor)│ │ (Research) │
        └──────┬───────┘ └────┬─────┘ └─────┬──────┘
               │              │              │
               └──────────────┼──────────────┘
                              │
                        ┌─────▼──────┐
                        │   Gemini   │
                        │ Specialist │
                        │ (Pontual)  │
                        └────────────┘
```

---

### 2.2. Distribuição de Papéis (v2.0)

#### **Claude - Chief Documentation Officer & GRC Lead**

**Responsabilidades Principais:**
- 🎯 **Governança Estratégica:** Planejamento de roadmaps e gestão de dependências
- 📚 **Memory Keeper:** Manutenção de contexto entre sprints
- ✍️ **Documentação Formal:** GMUDs, RNCs, memoriais descritivos
- 🗺️ **Compliance Mapping:** ISO 27001, NIST CSF, CIS Controls
- 🔄 **Cross-referencing:** Ligação entre GMUDs e lições aprendidas

**Entregáveis Típicos:**
- GMUDs completas (8-12 páginas)
- Relatórios de Não-Conformidade (RNC)
- Memoriais descritivos de arquitetura
- Roadmaps de projeto com análise de dependências
- Consolidação de lições aprendidas

**Referência:** [[ADR-001]] Seção 2.1

---

#### **ChatGPT - Senior Systems Architect & Lead Engineer**

**Responsabilidades Principais:**
- 🏗️ **Arquitetura Técnica:** Design de topologias (VLANs, routing, segmentação)
- 🔐 **Segurança Técnica:** ACLs, firewalls, encryption, hardening
- 🤖 **Automação:** Playbooks Ansible, scripts PowerShell/Bash
- 🐳 **Infraestrutura como Código:** Docker Compose, configurações de serviços
- 🔧 **Troubleshooting:** Debugging de implementações e análise de logs

**Entregáveis Típicos:**
- Diagramas de arquitetura de rede
- Playbooks Ansible completos e testados
- Scripts de automação e validação
- Docker Compose files otimizados
- Análises de trade-offs técnicos (performance vs. segurança)

**Referência:** [[ADR-001]] Seção 2.2

---

#### **Perplexity Pro - Intelligence Officer & Validation Specialist**

**Responsabilidades Principais:**
- 🔎 **Threat Intelligence:** Pesquisa de CVEs e vulnerabilidades
- 📰 **Monitoramento:** Tendências de segurança e atualizações de frameworks
- 🆚 **Comparativos:** Ferramentas e tecnologias com dados atualizados
- ✅ **Validação:** Versões de software, EOL, compatibilidade
- 📚 **Fact-checking:** Verificação de informações de outras IAs

**Entregáveis Típicos:**
- Relatórios de vulnerabilidades com fontes primárias
- Comparativos de ferramentas (ex: Vault vs. AD CS)
- Validação de versões e compatibilidade
- Alertas de segurança e patches necessários
- Documentação oficial e best practices atualizadas

**Referência:** [[ADR-001]] Seção 2.4

---

#### **Gemini Pro - Technical Specialist & Deep-Dive Consultant**

**Responsabilidades FOCADAS:**
- 🔬 **Deep-dives Técnicos:** Análises profundas de tecnologias específicas
- 📖 **Explicações Didáticas:** Conceitos técnicos complexos
- 🧠 **Brainstorming:** Soluções alternativas para problemas complexos
- 🆚 **Comparações Detalhadas:** Análises técnicas isoladas

**O que Gemini NÃO faz mais:**
- ❌ Planejamento de roadmaps (requer memória de longo prazo)
- ❌ Decisões arquiteturais finais (requer contexto histórico)
- ❌ Gestão de dependências entre fases
- ❌ Acompanhamento de evolução do projeto

**Regras de Engajamento:**
- ✅ Sessões isoladas com briefing completo no prompt inicial
- ✅ Perguntas específicas sem assumir conhecimento prévio
- ✅ Análises pontuais sem expectativa de follow-up
- ✅ Validação de conceitos antes de implementação

**Entregáveis Típicos:**
- Análises técnicas detalhadas (ex: "Como funciona Sqale Repository?")
- Comparações arquiteturais profundas
- Brainstorming de alternativas técnicas
- Explicações didáticas para documentação

**Referência:** [[ADR-001]] Seção 2.3

---

## 3. Matriz RACI - Processos-Chave

### Legenda
- **R** (Responsible): Executa a tarefa
- **A** (Accountable): Responsável final/decisor
- **C** (Consulted): Consultado antes da decisão
- **I** (Informed): Informado após a decisão

---

### 3.1. Planejamento de Roadmap

| Atividade | Claude | ChatGPT | Gemini | Perplexity | Paulo |
|-----------|--------|---------|--------|------------|-------|
| Definir visão de longo prazo | **A/R** | C | - | - | **A** |
| Identificar dependências técnicas | **R** | C | - | - | I |
| Faseamento e sprints | **A/R** | C | - | - | **A** |
| Validar viabilidade técnica | C | **R** | C | I | A |

---

### 3.2. Implementação de GMUD

| Atividade | Claude | ChatGPT | Gemini | Perplexity | Paulo |
|-----------|--------|---------|--------|------------|-------|
| Redação da GMUD | **A/R** | C | - | C | **A** |
| Análise de risco | **R** | C | - | - | A |
| Design arquitetural | C | **R** | C | - | I |
| Desenvolvimento de código | I | **A/R** | - | - | I |
| Pesquisa de best practices | C | C | - | **R** | I |
| Validação de implementação | **R** | C | - | C | **A** |

---

### 3.3. Troubleshooting de Incidentes

| Atividade | Claude | ChatGPT | Gemini | Perplexity | Paulo |
|-----------|--------|---------|--------|------------|-------|
| Documentação do incidente | **A/R** | I | - | I | **A** |
| Análise técnica | C | **R** | C | C | I |
| Deep-dive de causa raiz | C | C | **R** | - | I |
| Pesquisa de CVEs/patches | I | I | - | **R** | I |
| Plano de remediação | **R** | C | - | C | **A** |

---

### 3.4. Decisões Arquiteturais

| Atividade | Claude | ChatGPT | Gemini | Perplexity | Paulo |
|-----------|--------|---------|--------|------------|-------|
| Análise de trade-offs | **R** | C | C | - | **A** |
| Design de topologia | C | **R** | C | - | A |
| Mapeamento de compliance | **R** | - | - | C | A |
| Comparação de ferramentas | C | C | C | **R** | A |
| Decisão final | I | I | I | I | **A** |

---

### 3.5. Consultas Técnicas Pontuais

| Atividade | Claude | ChatGPT | Gemini | Perplexity | Paulo |
|-----------|--------|---------|--------|------------|-------|
| Deep-dive técnico | - | C | **A/R** | C | I |
| Explicação didática | C | C | **R** | - | I |
| Comparação detalhada | - | C | **R** | C | I |
| Brainstorming alternativas | C | C | **R** | - | I |

---

## 4. Arquitetura do Lab (Estado Atual e Futuro)

### 4.1. Infraestrutura Atual (AS-IS - Lab 1.0)

**Hypervisor:** Microsoft Hyper-V (Windows 11 Pro)  
**Topologia:** Rede flat xxx.xxx.xxx.xxx/16 (vSwitch_Fiqueok_Corp - Internal/NAT)

**Ativos Ativos:**

| Hostname | IP | Sistema Operacional | Função Principal | Status |
|----------|-----|---------------------|------------------|--------|
| **ID-P-01** | xxx.xxx.xxx.xxx | Windows Server 2022 | Domain Controller (AD DS/DNS) | ✅ Operacional |
| **IGA-P-01** | xxx.xxx.xxx.xxx | Ubuntu 22.04 | Docker Host (midPoint + OrangeHRM) | ✅ Operacional |

**Serviços Containerizados (IGA-P-01):**
- **midPoint 4.10** (IGA Engine) - Porta 8080
- **PostgreSQL 16** (midPoint Repository) - Porta 5432 (interno)
- **OrangeHRM 5.8** (HR Source) - Porta 8081
- **MariaDB 11.4** (OrangeHRM DB) - Porta 3306

**Redes Docker:**
- `midpoint_lab_net` (172.18.0.0/16) - Stack IGA
- `orangehrm_lab_net` (172.19.0.0/16) - Stack HR
- `fiqueok-backend-net` (172.20.0.0/16) - Bridge para integração

**Referências:** [[GMUD-001]] [[GMUD-008 - Deploy Automatizado IaC do Ambiente IGA]] [[GMUD-009]] [[GMUD-011]]

---

### 4.2. Infraestrutura Futura (SHOULD-BE - Lab 2.0)

**Evolução Principal:** Segmentação por VLANs com micro-segmentação de rede

```
┌─────────────────────────────────────────────────────────────┐
│              vSwitch_Fiqueok_Corp (TRUNK Mode)              │
│           Tagged VLANs: 1 (Native), 20, 30, 40              │
└──────────────────┬──────────────┬──────────────┬────────────┘
                   │              │              │
          VLAN 1 (Mgmt)    VLAN 20 (PKI)  VLAN 30 (IGA)
        xxx.xxx.xxx.xxx/16    192.168.20.0/24  192.168.30.0/24
                   │              │              │
            ┌──────▼──────┐ ┌────▼─────┐ ┌──────▼──────┐
            │   ID-P-01   │ │IGA-P-01  │ │(Future IGA) │
            │    .10      │ │   .10    │ │    VMs      │
            │  (AD DS)    │ │ (Vault)  │ │             │
            └─────────────┘ └──────────┘ └─────────────┘
```

**Zonas de Segurança:**

| VLAN | Nome | Subnet | Função | Ativos Críticos |
|------|------|--------|--------|-----------------|
| **1** (Native) | Management Zone | xxx.xxx.xxx.xxx/16 | Infraestrutura e diretório | AD DS, DHCP, DNS |
| **20** | Security Zone (PKI) | 192.168.20.0/24 | PKI e secrets management | HashiCorp Vault |
| **30** | IGA Zone | 192.168.30.0/24 | Governança de identidades | midPoint, Keycloak |
| **40** | SOC Zone (Futuro) | 192.168.40.0/24 | Monitoramento e resposta | Wazuh, TheHive |

**Políticas de Roteamento Inter-VLAN:**
- VLAN 30 → VLAN 20: HTTPS/8200 (Vault API) **PERMITIDO**
- VLAN 1 → VLAN 20: **BLOQUEADO** (Zero Trust)
- VLAN 20 → VLAN 1: LDAPS/636 (Certificate Enrollment) **PERMITIDO**

**Referência:** [[📐 Memorial Descritivo de Arquitetura - Evolução da Topologia de Rede]]

---

### 4.3. Roadmap de Implementação (Fases)

#### **Fase 1.0: Fundação (✅ Concluída)**
- ✅ Migração VirtualBox → Hyper-V
- ✅ Implantação do AD DS (corp.fiqueok.com.br)
- ✅ Stack midPoint 4.10 + PostgreSQL 16
- ✅ Stack OrangeHRM + MariaDB 11.4
- ✅ Rede bridge para integração (fiqueok-backend-net)

**GMUDs:** 001-013  
**Status:** ✅ Operacional com limitações

---

#### **Fase 2.0: Segmentação e PKI (🟡 Em Planejamento)**

**Sprint 1 (27-28/12/2025): GMUD-015A**
- Criação de `svc_ansible` (conta de serviço)
- Configuração de VLAN 20 (trunk + subinterface)
- Validação de conectividade básica

**Sprint 2 (29-30/12/2025): GMUD-015B**
- Deploy do HashiCorp Vault na VLAN 20
- Configuração de PKI Engine
- Emissão de certificado para AD DS

**Sprint 3 (31/12/2025 - 02/01/2026): GMUD-015C**
- Binding de certificado no ID-P-01
- Validação de LDAPS (porta 636)
- Retomada de GMUD-013/014 (provisionamento IGA completo)

**Sprint 4 (03-05/01/2026): GMUD-016**
- Migração gradual de midPoint para VLAN 30
- Configuração de ACLs inter-VLAN
- Testes de resiliência (failover de rede)

**Referência:** [[ADR-001]] [[ARQ-005 - Integrações do midPoint 4.10 com Active Directory, Entra ID, Keycloak, SAP, AWS e GCP]]

---

#### **Fase 3.0: Observabilidade (🔵 Futuro - Q1/2026)**
- Deploy de Wazuh SIEM (VLAN 40)
- Integração de logs (AD, midPoint, Vault)
- Dashboards de compliance (ISO 27001)

---

## 5. Gestão do Conhecimento (Second Brain)

### 5.1. Estrutura de Documentação (Obsidian)

```
Fiqueok_Brain/
├── 10_Projetos/
│   ├── PRJ001-LABORATORIO/
│   │   ├── 10_Planning/
│   │   │   ├── Manifesto v2.0 (este documento)
│   │   │   ├── ADR-001 - Redistribuição de IAs
│   │   │   └── ARQ-005 - Memorial de Topologia
│   │   ├── 20_Governanca/
│   │   │   ├── GMUDs (001-016)
│   │   │   ├── REL-GMUDs (Relatórios de Encerramento)
│   │   │   └── RNCs (Não-Conformidades)
│   │   ├── 30_Execucao/
│   │   │   ├── Scripts/
│   │   │   ├── Playbooks Ansible/
│   │   │   └── Docker Compose files/
│   │   └── 40_Arquivo/
│   │       └── (Documentos descontinuados)
│   └── PRJ002-DEFECTDOJO/
│       └── (Futuro)
├── 20_Recursos/
│   ├── Templates/
│   │   ├── TEMPLATE-001 - RNC
│   │   ├── TEMPLATE-002 - GMUD
│   │   └── TEMPLATE-003 - Memorial Descritivo
│   └── Processos/
│       ├── POP-GRC-001 - Gestão de Vulnerabilidades
│       └── POP-GRC-002 - Tomada de Decisão Arquitetural
└── 30_Conhecimento/
    ├── Base de Conhecimento/
    │   ├── KB-001 - midPoint 4.10 (Sqale)
    │   ├── KB-002 - HashiCorp Vault PKI
    │   └── KB-003 - VLANs em Hyper-V
    └── Lições Aprendidas/
        └── (Consolidado de REL-GMUDs)
```

---

### 5.2. Rastreabilidade de Decisões

**Princípio:** Toda decisão técnica ou estratégica deve ser rastreável até sua origem.

**Mecanismos:**
- ✅ ADRs para mudanças arquiteturais
- ✅ Cross-references entre GMUDs (ex: "GMUD-015 depende de GMUD-007")
- ✅ Changelog em todos os documentos versionados
- ✅ Log de decisões com data e responsável

**Exemplo de Cross-reference:**
```markdown
## Dependências
Esta GMUD depende das seguintes mudanças anteriores:
- [[GMUD-007]] - Configuração de IP estático (IGA-P-01)
- [[GMUD-011]] - Rede bridge para integração
- [[REL-GMUD-014]] - Lições aprendidas sobre LDAPS
```

---

## 6. Alinhamento com Frameworks de Conformidade

### 6.1. Frameworks Adotados

| Framework | Versão | Objetivo no Lab | Status |
|-----------|--------|-----------------|--------|
| **ISO/IEC 27001** | 2022 | Base para estrutura de controles | 🟡 Em implementação |
| **NIST CSF** | 2.0 | Framework de cybersecurity | 🟡 Em implementação |
| **CIS Controls** | v8 | Hardening e best practices | 🟢 Referência ativa |
| **ISO/IEC 27005** | 2022 | Gestão de riscos | 🔵 Futuro |
| **COSO ERM** | 2017 | Enterprise Risk Management | 🔵 Futuro |

---

### 6.2. Mapeamento de Controles (Exemplo)

**Cenário:** Segmentação de rede por VLANs (Lab 2.0)

| Framework | Controle | Requisito | Status AS-IS | Status SHOULD-BE | Evidência |
|-----------|----------|-----------|--------------|------------------|-----------|
| **ISO 27001:2022** | A.13.1.3 | Segregação de redes | 🔴 NC | 🟢 C | ARQ-005 + Firewall policy |
| **NIST CSF 2.0** | PR.AC-5 | Network segmentation | 🟡 PC | 🟢 C | Diagrama de VLANs |
| **CIS Controls v8** | 12.2 | Isolated network segments | 🔴 NC | 🟢 C | Configuração Hyper-V trunk mode |

**Legenda:**
- 🔴 NC = Não Conforme
- 🟡 PC = Parcialmente Conforme
- 🟢 C = Conforme

---

## 7. Regras de Engajamento (Operacional)

### 7.1. Início de Sprint

**Responsável:** Paulo (Owner)

**Checklist:**
1. Definir objetivo claro do sprint
2. Identificar tipo de trabalho (Nova Feature / Troubleshooting / Pesquisa)
3. Acionar IA apropriada conforme RACI:
   - **Planejamento:** Claude (GRC Lead)
   - **Implementação:** ChatGPT (Architect)
   - **Pesquisa:** Perplexity (Intelligence)
   - **Deep-dive:** Gemini (Specialist)

---

### 7.2. Handoffs entre IAs

**Princípio:** Cada IA deve receber contexto completo, mesmo quando há trabalho prévio de outra IA.

**Exemplo de Handoff Correto:**
```
# Para ChatGPT (após Claude planejar)
Paulo: "ChatGPT, Claude planejou a GMUD-015 (anexada). 
       Preciso do design técnico da VLAN 20.
       
       Contexto adicional:
       - Infraestrutura atual: [resumo]
       - Restrições: [lista]
       
       Entregável: Diagrama + configuração Netplan"
```

**Exemplo de Handoff Incorreto:**
```
❌ Paulo: "ChatGPT, continue o que o Claude começou"
   (Assume conhecimento prévio sem fornecer contexto)
```

---

### 7.3. Encerramento de Sprint

**Responsável:** Claude (GRC Lead)

**Checklist:**
1. Validar critérios de aceite da GMUD
2. Documentar evidências de sucesso/falha
3. Criar REL-GMUD com lições aprendidas
4. Atualizar matriz de conformidade
5. Identificar impacto em GMUDs futuras
6. Arquivar documentos no Obsidian

---

## 8. Métricas de Sucesso

### 8.1. KPIs do Lab (Técnico)

| Métrica | Meta | Frequência de Medição |
|---------|------|----------------------|
| Uptime do AD DS | > 99% | Semanal |
| Taxa de sucesso de GMUDs | > 80% | Por sprint |
| Conformidade ISO 27001 | > 70% controles | Mensal |
| Cobertura de documentação | 100% de GMUDs concluídas | Contínua |

---

### 8.2. KPIs da Governança de IAs (Novo)

| Métrica | Meta | Como Medir | Frequência |
|---------|------|------------|------------|
| Retrabalho por "esquecimento" | < 10% | Contagem de re-briefings | Mensal |
| Coerência entre GMUDs | > 90% | Auditoria de cross-references | Sprint |
| Taxa de código funcional (1ª tentativa) | > 80% | Scripts executados sem erro | Sprint |
| Tempo de deep-dive com Gemini | < 1h/sessão | Log de conversas | Por consulta |
| Satisfação do Owner (Paulo) | > 8/10 | Auto-avaliação | Mensal |

**Próxima revisão de KPIs:** 27/01/2026

---

## 9. Glossário de Termos

| Termo | Definição |
|-------|-----------|
| **Lab** | Ambiente de laboratório (substitui "Living Lab") |
| **IGA** | Identity Governance and Administration |
| **GMUD** | Gestão de Mudanças (Change Management) |
| **RNC** | Relatório de Não-Conformidade |
| **ADR** | Architecture Decision Record |
| **RACI** | Responsible, Accountable, Consulted, Informed |
| **Blast Radius** | Raio de impacto de um incidente de segurança |
| **Memory Keeper** | Papel de manter contexto histórico do projeto |
| **Deep-dive** | Análise técnica profunda de um tópico específico |

---

## 10. Referências e Links

### 10.1. Documentos Estruturantes
- [[ADR-001 - Redistribuição de Papéis das IAs]]
- [[ARQ-005 - Memorial Descritivo de Arquitetura]]
- [[POP-GRC-001 - Gestão de Vulnerabilidades]]
- [[TEMPLATE-001 - RNC]]
- [[TEMPLATE-002 - GMUD]]

### 10.2. GMUDs Fundamentais
- [[GMUD-001]] - Implementação de Infraestrutura Core (Hyper-V)
- [[GMUD-007 - Deploy Manual Passo-a-Passo do Ambiente IGA]] - Alteração de Endereçamento IP (Estático)
- [[GMUD-008 - Deploy Automatizado IaC do Ambiente IGA]] - Implantação da Stack midPoint 4.10
- [[GMUD-011]] - Rede de Integração Segura (Backend Bridge)
- [[REL-GMUD-014]] - Integração AD e IGA (Suspensão Técnica)

### 10.3. Bases de Conhecimento
- [[KB-001 - midPoint 4.10 (Sqale Repository)]]
- [[Diagnóstico de Maturidade de IAM - AS IS vs. SHOULD BE]]
- [[Plano de Implementação de IAM & Script de Provisionamento]]

---

## 11. Aprovações e Assinaturas

| Papel | Nome | Data | Assinatura Digital |
|-------|------|------|-------------------|
| **Owner & Decisor Final** | Paulo Feitosa | 28/12/2025 | _Pendente_ |
| **GRC Lead & Technical Writer** | Claude (Anthropic) | 28/12/2025 | ✅ Documento Aprovado |
| **Arquiteto de Revisão** | ChatGPT (OpenAI) | - | _Aguardando_ |
| **Validação de Research** | Perplexity Pro | - | _Aguardando_ |

---

## 12. Controle de Versão

| Versão | Data | Autor | Mudanças Principais | Aprovador |
|--------|------|-------|---------------------|-----------|
| 1.0 | 19/12/2025 | Gemini Pro | Criação do manifesto inicial | Paulo |
| 2.0 | 28/12/2025 | Claude | Redistribuição de IAs + RACI | _Pendente_ |

---

**Próxima revisão obrigatória:** 27/01/2026  
**Trigger de revisão antecipada:** Mudança significativa em capacidades de qualquer IA ou alteração de escopo do projeto

---

**Documento mantido por:** Claude (Chief Documentation Officer & GRC Lead)  
**Repositório:** Obsidian Vault - `Fiqueok_Brain/10_Projetos/PRJ001
