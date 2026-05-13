# TAP - PRJ014: IGA Híbrido Local (OrangeHRM → AD → Entra ID)

| Campo | Valor |
| :--- | :--- |
| **Código** | TAP-PRJ014 |
| **Versão** | 1.0 |
| **Data** | 26/03/2026 |
| **Responsável** | Paulo Feitosa Lima — GRC Lead |
| **Ambiente** | Living Lab Fiqueok — On-Premise |
| **Status** | **ATIVO** |
| **Classificação** | Confidencial Interno |

## 1. CHANGELOG

| Versão | Data | Autor | Mudanças |
| :--- | :--- | :--- | :--- |
| 1.0 | 26/03/2026 | Paulo Feitosa Lima | Criação — IGA Híbrido Local |

## 2. IDENTIFICAÇÃO DO PROJETO

| Campo | Valor |
| :--- | :--- |
| **Código** | PRJ014 |
| **Nome** | IGA Híbrido Local — OrangeHRM → Active Directory → Microsoft Entra ID |
| **Categoria** | On-Premise IGA / Identity Hybrid Sync |
| **Patrocinador** | Paulo Feitosa Lima |
| **Data Início** | 26/03/2026 |
| **Duração Estimada** | 5 dias (contínuo) |
| **Pré-requisitos** | PRJ010, PRJ011, PRJ012 (ATOs 1 e 2) |
| **Sucessor de** | PRJ009 (encerrado devido a custos Azure) |

## 3. CONTEXTO E JUSTIFICATIVA

### 3.1. Situação Anterior

| Projeto | Status | Contribuição |
| :--- | :--- | :--- |
| **PRJ010** | ✅ Concluído | 100 colaboradores no OrangeHRM |
| **PRJ011** | ✅ Concluído | 100 usuários no Entra ID, grupos de segurança criados |
| **PRJ012** | ⚠️ ATO 1 e 2 concluídos | App Registration + midPoint ↔ Entra ID funcional |
| **PRJ009** | ⚠️ Encerrado | VM Azure desprovisionada, aprendizado preservado |

### 3.2. Justificativa
A **expiração dos créditos Azure** e o surgimento de uma **demanda externa (DPSP)** que requer aprendizado em **Microsoft Entra Cloud Sync** motivaram a revisão da estratégia original. Em vez de manter um gateway na nuvem (PRJ009), o PRJ014 adota uma abordagem **totalmente on-premise** para o motor de sincronização:

`OrangeHRM (local) → AD Local → Entra Cloud Sync → Entra ID`

**Esta arquitetura:**
1. **Elimina custos recorrentes** (sem VMs em nuvem).
2. **Demonstra competência** em Cloud Sync (alinhado à demanda DPSP).
3. **Preserva o valor** dos projetos anteriores (100 usuários, âncora EmployeeID).
4. **Mantém a âncora EmployeeID** como imutável entre sistemas.

## 4. OBJETIVOS

| ID | Objetivo | Critério de Sucesso |
| :--- | :--- | :--- |
| **OBJ-01** | Configurar Active Directory local (Greenfield) | VM Windows Server com AD funcional, OUs espelhando OrangeHRM |
| **OBJ-02** | Implementar script de ingestão OrangeHRM → AD | 100 usuários criados no AD com atributos corretos |
| **OBJ-03** | Configurar Microsoft Entra Cloud Sync | Agente instalado no AD, conectado ao tenant fiqueok.com.br |
| **OBJ-04** | Sincronizar AD → Entra ID | 100 usuários sincronizados, EmployeeID como âncora |
| **OBJ-05** | Validar RBAC no Entra ID | Grupos de segurança populados conforme Department no AD |
| **OBJ-06** | Documentar procedimento | POP-IAM-003 atualizado |

## 5. ARQUITETURA DA SOLUÇÃO

```text
┌─────────────────────────────────────────────────────────────────────┐
│                        LIVING LAB FIQUEOK                          │
│                         On-Premise Only                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────┐    ┌──────────────────┐    ┌───────────────┐ │
│  │   OrangeHRM      │───▶│   PowerShell     │───▶│    Active     │ │
│  │   (rh-gf-01)     │SQL │   Script        │LDAP │   Directory   │ │
│  │   100 usuários   │    │   (Python/PS)   │     │   (Greenfield)│ │
│  └──────────────────┘    └──────────────────┘     └───────┬───────┘ │
│                                                            │         │
│                                                            │         │
│                                                    ┌───────▼───────┐ │
│                                                    │   Entra Cloud │ │
│                                                    │   Sync Agent  │ │
│                                                    │   (on AD VM)  │ │
│                                                    └───────┬───────┘ │
│                                                            │         │
└────────────────────────────────────────────────────────────┼─────────┘
                                                             │
                                                             │ HTTPS
                                                             ▼
                                            ┌────────────────────────────┐
                                            │   Microsoft Entra ID       │
                                            │   tenant fiqueok.com.br    │
                                            │   100 usuários sincronizados│
                                            └────────────────────────────┘
```

## 6. ESCOPO

### 6.1. Incluído
* ✅ Criação de VM Windows Server (Hyper-V) para AD.
* ✅ Instalação e configuração do Active Directory Domain Services.
* ✅ Criação de OUs espelhando a estrutura do OrangeHRM.
* ✅ Script de ingestão OrangeHRM → AD (PowerShell ou Python).
* ✅ Instalação do Microsoft Entra Cloud Sync Agent.
* ✅ Configuração de sincronização AD → Entra ID.
* ✅ Validação da âncora EmployeeID em todo o fluxo.

### 6.2. Excluído
* ❌ Migração de dados reais ou produtivos.
* ❌ Configuração de Grupos Dinâmicos (requer licença P1).
* ❌ Implementação de MFA ou Conditional Access (fora do escopo deste TAP).

## 7. DEPENDÊNCIAS

| Dependência | Projeto de Origem | Status |
| :--- | :--- | :--- |
| 100 usuários no OrangeHRM | PRJ010 | ✅ CONCLUÍDO |
| 100 usuários no Entra ID | PRJ011 | ✅ CONCLUÍDO |
| App Registration com permissões | PRJ012 ATO 1 | ✅ CONCLUÍDO |
| Tailscale mesh | PRJ009 | ✅ OPERACIONAL |
| Vault operacional | PRJ007 | ✅ OPERACIONAL |

## 8. RISCOS E MITIGAÇÕES

| ID | Risco | Prob | Imp | Mitigação |
| :--- | :--- | :--- | :--- | :--- |
| **R01** | AD não sincroniza com Entra ID | Baixa | Alto | Teste de conectividade prévio, logs do Cloud Sync |
| **R02** | EmployeeID não preservado | Média | Alto | Validação manual dos primeiros 5 usuários |
| **R03** | Script de ingestão falha | Média | Médio | Teste com 1 usuário antes do bulk |

## 9. CRONOGRAMA MACRO

| Fase | Atividade | Início | Duração | Entrega |
| :--- | :--- | :--- | :--- | :--- |
| **Fase 1** | Provisionar AD Local | 26/03 | 1 dia | VM Windows + AD funcional |
| **Fase 2** | Script de ingestão | 27/03 | 1 dia | 100 usuários no AD |
| **Fase 3** | Configurar Cloud Sync | 28/03 | 1 dia | Agente instalado e sincronizando |
| **Fase 4** | Validação end-to-end | 29/03 | 1 dia | Joiner/Mover/Leaver validados |
| **Fase 5** | Documentação | 30/03 | 1 dia | REL-PRJ014 |

## 10. CRITÉRIOS DE SUCESSO

| ID | Critério | Métrica |
| :--- | :--- | :--- |
| **CS1** | 100 usuários no AD | COUNT = 100 |
| **CS2** | 100 usuários no Entra ID | COUNT = 100 |
| **CS3** | EmployeeID preservado | Amostra de 5 usuários OK |
| **CS4** | Joiner funcional | Novo usuário no Entra em < 15min |

## 11. APROVAÇÕES

| Função | Nome | Data | Status |
| :--- | :--- | :--- | :--- |
| **GRC Lead / Responsável** | Paulo Feitosa Lima | 26/03/2026 | ✅ APROVADO |
| **GRC Advisor** | Gemini (Google) | 26/03/2026 | ✅ REVISADO |
