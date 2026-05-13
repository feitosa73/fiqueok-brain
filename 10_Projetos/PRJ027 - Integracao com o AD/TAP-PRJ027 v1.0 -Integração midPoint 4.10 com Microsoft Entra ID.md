
# TAP-PRJ027 v1.0 — Technical Assessment Plan

## Integração midPoint 4.10 com Microsoft Entra ID (Governança + FinOps)

---

| Campo | Valor |
|-------|-------|
| **Código do Projeto** | PRJ027 |
| **Versão do TAP** | 1.0 |
| **Data** | 08/05/2026 |
| **Responsável** | Paulo Feitosa Lima — Arquiteto de Segurança e IAM |
| **Status** | ✅ Aprovado para Implementação |
| **Classificação** | Interno — Living Lab Fiqueok |

---

## ÍNDICE

1. [Resumo Executivo](#1-resumo-executivo)
2. [Objetivos do Projeto](#2-objetivos-do-projeto)
3. [Escopo do Projeto](#3-escopo-do-projeto)
4. [Arquitetura da Solução](#4-arquitetura-da-solução)
5. [Pré-Requisitos Obrigatórios](#5-pré-requisitos-obrigatórios)
6. [Pre-Flight e Descoberta de Artefatos do PRJ012](#6-pre-flight-e-descoberta-de-artefatos-do-prj012)
7. [Componentes a Serem Criados/Configurados](#7-componentes-a-serem-criadosconfigurados)
8. [Cronograma e Entregáveis](#8-cronograma-e-entregáveis)
9. [Riscos e Mitigações](#9-riscos-e-mitigações)
10. [Benefícios Estratégicos (Segurança + FinOps)](#10-benefícios-estratégicos-segurança--finops)
11. [Controles de Auditoria (ISO 27001)](#11-controles-de-auditoria-iso-27001)
12. [Aprovações](#12-aprovações)
13. [Histórico de Versões](#13-histórico-de-versões)

---

## 1. Resumo Executivo

O **PRJ027** tem como objetivo estabelecer a integração governada entre o **midPoint 4.10** (hub de IGA do Living Lab) e o **Microsoft Entra ID Free** (diretório de nuvem), utilizando o conector oficial da Evolveum via Microsoft Graph API.

**Diferenciais do projeto:**

| Aspecto | Descrição |
|---------|-----------|
| **Governança** | Workflow de aprovação de 2 níveis, Segregação de Funções (SoD), Certificação trimestral de acesso |
| **FinOps** | Nenhuma licença paga (M365 E5, EMS E5) será provisionada — uso exclusivo do Entra ID Free |
| **Segurança** | Client Secret armazenado no HashiCorp Vault (Zero Plaintext), reconciliação diária contra Shadow IT |
| **Rastreabilidade** | Logs completos de aprovação, justificativa de acesso, evidências para auditoria ISO 27001 |

**Ao final do projeto, o midPoint será capaz de:**
- Provisionar automaticamente usuários no Entra ID (Joiner)
- Atualizar atributos (Mover)
- Desabilitar contas e revogar sessões (Leaver)
- Aplicar regras de SoD antes do provisionamento
- Exigir aprovação de manager e security owner para acessos privilegiados

---

## 2. Objetivos do Projeto

| ID | Objetivo | Critério de Sucesso |
|----|----------|---------------------|
| **OBJ-01** | Estabelecer comunicação segura entre midPoint e Entra ID via Graph API | Test Connection OK no Resource do midPoint |
| **OBJ-02** | Configurar Schema Handling com mapeamento correto de atributos | Atributos (UPN, givenName, surname, mail) mapeados corretamente |
| **OBJ-03** | Implementar Workflow de Aprovação de 2 níveis (Manager + Security Owner) | Atribuição de role só é provisionada após dupla aprovação |
| **OBJ-04** | Implementar regras de Segregação de Funções (SoD) | Tentativa de atribuir roles conflitantes é bloqueada |
| **OBJ-05** | Configurar Certificação trimestral de acesso | Campanha criada com revisores definidos |
| **OBJ-06** | Configurar Reconciliação diária para detecção de Shadow IT | Tarefa agendada detecta contas criadas manualmente no portal |
| **OBJ-07** | Garantir rastreabilidade total para auditoria ISO 27001 | Logs de aprovação, justificativa e provisionamento disponíveis |

---

## 3. Escopo do Projeto

### 3.1. Incluído no Projeto

- App Registration no Microsoft Entra ID (ou reutilização de existente)
- Conector Microsoft Graph API no midPoint (`connector-msgraph`)
- Resource `Microsoft Entra ID` com Schema Handling
- Mapeamento de atributos: `name → userPrincipalName`, `givenName → givenName`, `familyName → surname`, `email → mail`
- Correlation Rule baseada em `userPrincipalName`
- Workflow de aprovação de 2 níveis (Manager + Security Owner)
- Regras SoD (AdminInfra + Auditor = BLOCK; Desenvolvedor + Billing = ALERT)
- Certificação trimestral de acesso
- Reconciliação diária para detecção de Shadow IT
- POP Joiner (Procedimento Operacional Padrão para admissão de funcionários)

### 3.2. Excluído do Projeto

- Provisionamento de licenças Microsoft 365 E5, EMS E5 ou qualquer SKU paga
- Configuração de Conditional Access ou PIM (requerem licenças P1/P2)
- Migração de dados de produção
- Alta disponibilidade do midPoint (cluster multi-node)

---

## 4. Arquitetura da Solução

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                         PRJ027 - midPoint 4.10 → Microsoft Entra ID Free            │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                         midPoint 4.10 (iga-gf-02)                                ││
│  │                         IP: xxx.xxx.xxx.xxx                                        ││
│  │                                                                                  ││
│  │  ┌─────────────┐    ┌─────────────────────────────────────────────────────────┐││
│  │  │  CSV HR     │───▶│  Usuário (ex: FP008)                                    │││
│  │  │  (PRJ022)   │    │  - name: FP008 → UPN: FP008@fiqueok.com.br              │││
│  │  └─────────────┘    │  - givenName, familyName, email                         │││
│  │                     └───────────────────────┬─────────────────────────────────┘││
│  │                                             │                                    ││
│  │                                             ▼                                    ││
│  │  ┌─────────────────────────────────────────────────────────────────────────────┐││
│  │  │                    Role "Entra ID Basic User"                               │││
│  │  │  ├── Workflow de Aprovação (2 níveis)                                       │││
│  │  │  ├── SoD Rules (ex: AdminInfra + Auditor = BLOCK)                          │││
│  │  │  └── Account Construction (cria conta no Entra ID)                         │││
│  │  └─────────────────────────────────────────────────────────────────────────────┘││
│  │                                             │                                    ││
│  │                                             │ HTTPS + Graph API                  ││
│  │                                             ▼                                    ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    Microsoft Entra ID Free (tenant: fiqueok.com.br)             ││
│  │                                                                                  ││
│  │  ┌─────────────────────────────────────────────────────────────────────────────┐││
│  │  │  App Registration: midpoint-iga-connector                                   │││
│  │  │  - Client ID, Tenant ID                                                     │││
│  │  │  - Client Secret (armazenado no Vault)                                      │││
│  │  │                                                                              │││
│  │  │  Permissões Graph API (Application):                                        │││
│  │  │  ├── User.ReadWrite.All                                                     │││
│  │  │  ├── Directory.ReadWrite.All                                                │││
│  │  │  ├── GroupMember.ReadWrite.All                                              │││
│  │  │  ├── RoleManagement.ReadWrite.Directory                                     │││
│  │  │  └── Organization.Read.All                                                  │││
│  │  └─────────────────────────────────────────────────────────────────────────────┘││
│  │                                                                                  ││
│  │  ⚠️ Nenhuma licença de produtividade (M365, EMS) será atribuída.                ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    FUTURO ERP (via SAML/OIDC)                                   ││
│  │                                                                                  ││
│  │  O Entra ID Free atuará como IdP para autenticação.                             ││
│  │  ⚠️ Recursos avançados (Conditional Access, PIM) exigem licenças P1/P2.         ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Pré-Requisitos Obrigatórios

| # | Pré-Requisito | Verificação | Critério |
|---|---------------|-------------|----------|
| PR-01 | Acesso ao servidor iga-gf-02 | `ssh paulo@xxx.xxx.xxx.xxx` | Login OK |
| PR-02 | midPoint 4.10 operacional | `curl http://xxx.xxx.xxx.xxx:8080/midpoint` | HTTP 200 |
| PR-03 | Tenant Entra ID criado | `fiqueok.com.br` | Tenant existe |
| PR-04 | Conta com permissão de Global Admin no Entra ID | Acesso ao portal Azure | OK |
| PR-05 | HashiCorp Vault operacional | `vault status` | Sealed: false |
| PR-06 | Snapshot das VMs (IGA-GF-02 e VAULT-GEN1) | Hyper-V checkpoint | Criado antes da implementação |

---

## 6. Pre-Flight e Descoberta de Artefatos do PRJ012

### 6.1. Contexto da Descoberta

Durante a execução do **Pre-Flight** do PRJ027 (procedimento padrão de validação de ambiente anterior a qualquer implementação), foi identificada a existência de artefatos residuais de um projeto anterior — o **PRJ012 (Orquestração de Identidades)** — que havia sido encerrado sem a devida documentação de encerramento (TEP).

### 6.2. O que foi Encontrado

| Artefato Encontrado | Estado | Implicação para o PRJ027 |
|---------------------|--------|--------------------------|
| App Registration `midpoint-iga-connector` | ✅ Ativo e preservado | **Pode ser reaproveitado** — evita recriação |
| Client ID | ✅ Válido | **Pode ser reutilizado** |
| Tenant ID | ✅ Correto | **Mesmo tenant** |
| Client Secret | ❌ Inválido (401 Não Autorizado) | **Requer geração de novo secret** |
| Permissões Graph | ⚠️ Parcial (3 de 5) | **Requer adição de 2 permissões** |
| Conector Graph no midPoint | ❌ Não instalado | **Requer instalação do zero** |
| Shadows de usuários | ❌ 0 | **Requer importação do zero** |

### 6.3. Decisão Tomada

Após análise forense detalhada (documentada separadamente no relatório `REL-PRJ012-v2.0.md`), foi decidido:

1. **Reaproveitar o App Registration existente** — economiza tempo e evita a criação de um novo artefato desnecessário
2. **Criar um novo Client Secret** — o existente está inválido
3. **Adicionar as permissões faltantes** — para atender aos requisitos de governança do PRJ027
4. **Instalar o conector Graph no midPoint do zero** — todos os artefatos no midPoint foram perdidos (provavelmente devido a restore de snapshot)

### 6.4. Impacto no Cronograma

A descoberta dos artefatos do PRJ012 **reduziu o esforço estimado** do PRJ027, pois eliminou a necessidade de:
- Criar um novo App Registration
- Configurar permissões base (3 já estavam presentes)

**Tempo economizado:** aproximadamente 1-2 horas.

---

## 7. Componentes a Serem Criados/Configurados

### 7.1. No Microsoft Entra ID (Ação Única)

| Componente | Ação | Observação |
|------------|------|------------|
| App Registration | Reaproveitar existente (`midpoint-iga-connector`) | Já existe |
| Client Secret | Criar novo (o existente está inválido) | 12 meses de validade |
| Permissões | Adicionar `GroupMember.ReadWrite.All` e `Organization.Read.All` | Já existem 3 permissões |
| Grant admin consent | Reaplicar após adicionar permissões | Obrigatório |

### 7.2. No HashiCorp Vault

| Componente | Ação |
|------------|------|
| Secret path | Criar `secret/entra-id/auth` (ou reutilizar `secret/prj012/entra-connector`) |
| Credenciais | Armazenar Tenant ID, Client ID e novo Client Secret |

### 7.3. No midPoint (IGA-GF-02)

| Componente | Ação |
|------------|------|
| Conector Graph | Instalar `connector-msgraph-1.0.2.0.jar` no diretório `icf-connectors/` |
| Resource | Criar `Microsoft Entra ID` com as credenciais do Vault |
| Schema Handling | Configurar mapeamentos de atributos |
| Correlation Rule | Configurar baseada em `userPrincipalName` |
| Políticas SoD | Importar regras de segregação de funções |
| Workflow | Importar policy rule de aprovação de 2 níveis |
| Reconciliation Task | Configurar tarefa diária para detecção de Shadow IT |
| Certification Campaign | Configurar campanha trimestral |

---

## 8. Cronograma e Entregáveis

### 8.1. Cronograma Estimado

| Fase | Atividade | Duração |
|------|-----------|---------|
| **Fase 1** | Preparação do Entra ID (novo secret + permissões) | 30 min |
| **Fase 2** | Instalação do conector Graph no midPoint | 15 min |
| **Fase 3** | Criação do Resource e Schema Handling | 30 min |
| **Fase 4** | Configuração de SoD e Workflow | 30 min |
| **Fase 5** | Configuração de Certificação e Reconciliação | 30 min |
| **Fase 6** | Validação e testes | 30 min |
| **Total** | | **~2,5 horas** |

### 8.2. Entregáveis

| ID | Entregável | Descrição |
|----|------------|-----------|
| E1 | Resource XML | Configuração do conector Graph no midPoint |
| E2 | Mapeamento de atributos | UPN, givenName, surname, mail |
| E3 | Role XML | `Entra ID Basic User` com account construction |
| E4 | Workflow de aprovação | Policy rule com 2 níveis |
| E5 | Regras SoD | AdminInfra + Auditor (block); Desenvolvedor + Billing (warn) |
| E6 | Tarefa de reconciliação | Diária, detecta contas manuais |
| E7 | Campanha de certificação | Trimestral |
| E8 | POP Joiner | Procedimento completo de admissão |

---

## 9. Riscos e Mitigações

| ID | Risco | Probabilidade | Impacto | Mitigação |
|----|-------|---------------|---------|-----------|
| R01 | Client Secret expirado durante o projeto | Baixa | Alto | Validade de 12 meses + alerta documentado |
| R02 | Workflow não dispara por falta de manager | Média | Médio | Validar atributo `manager` nos usuários antes da atribuição |
| R03 | SoD bloqueia provisionamento legitimate | Baixa | Baixo | Testar regras em sandbox antes da produção |
| R04 | Reconciliação detecta Shadow IT | Média | Baixo | Configurar ação apenas como alerta, não deleção automática |
| R05 | Throttling da Graph API | Baixa | Baixo | Configurar retry policy no conector |

---

## 10. Benefícios Estratégicos (Segurança + FinOps)

| Benefício | Como o PRJ027 entrega | Impacto Financeiro |
|-----------|----------------------|---------------------|
| **Evita licenças PIM pagas** | Workflow + SoD substituem PIM (requer Entra ID P2) | ✅ Economia de ~R$ 150/usuario/mês |
| **Detecta Shadow IT** | Reconciliação diária identifica contas manuais | ✅ Evita provisionamento fantasma |
| **Certificação de acesso** | Campanhas trimestrais substituem ferramentas pagas | ✅ Economia de ferramentas de terceiros |
| **Auditoria ISO 27001** | Logs de aprovação + justificativa + reconciliação | ✅ Reduz custo de auditoria externa |
| **Base para SSO do ERP** | Entra ID Free suporta SAML/OIDC | ✅ Sem custo adicional |

---

## 11. Controles de Auditoria (ISO 27001)

| Controle ISO | Evidência gerada | Custo |
|--------------|------------------|-------|
| **A.9.1.2** (Acesso a redes e sistemas) | Log de aprovação antes de atribuir role no Entra | ✅ Zero |
| **A.9.2.6** (Revogação de direitos) | Reconciliação diária detecta e revoga contas manuais | ✅ Zero |
| **A.9.4.2** (Processo de login seguro) | SSO futuro via SAML/OIDC | ✅ Zero |
| **A.12.4.1** (Registro de eventos) | Logs de auditoria com justificativa e approver | ✅ Zero |

---

## 12. Aprovações

| Função | Nome | Data | Decisão |
|--------|------|------|---------|
| **Responsável Técnico** | Paulo Feitosa Lima | 08/05/2026 | ✅ **APROVADO** |
| **GRC Advisor** | Perplexity AI | 08/05/2026 | ✅ **REVISADO** |
| **Auditoria** | Claude (Anthropic) | 08/05/2026 | ✅ **CONSOLIDADO** |

---

## 13. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| **1.0** | **08/05/2026** | **Paulo Feitosa Lima** | **Documento inicial. Define escopo, arquitetura, pré-requisitos, cronograma e entregáveis do PRJ027. Inclui seção sobre descoberta de artefatos do PRJ012 durante o Pre-Flight.** |

---

**Fim do TAP-PRJ027-v1.0** ✅

---

*PRJ027 — Integração midPoint ↔ Microsoft Entra ID com Governança*  
*Living Lab Fiqueok*  
*Arquivado em: `FiqueokBrain/PRJ027/10 Iniciação/TAP-PRJ027-v1.0.md`*
