

| Campo | Valor |
|-------|-------|
| **Código** | TAP-PRJ015 |
| **Versão** | 1.0 |
| **Data** | 30/03/2026 |
| **Responsável** | Paulo Feitosa Lima — GRC Lead / Especialista IAM |
| **Ambiente** | Living Lab Fiqueok — On-Premise + Microsoft Entra ID (Trial) |
| **Status** | 📋 PLANEJADO — Aguardando execução |
| **Classificação** | Confidencial Interno |

---

## CHANGELOG

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 30/03/2026 | Paulo Feitosa Lima | Criação — IGA Híbrido Local via Entra Cloud Sync |

---

## 1. IDENTIFICAÇÃO DO PROJETO

| Campo | Valor |
|-------|-------|
| **Código** | PRJ015 |
| **Nome** | IGA Híbrido Local — AD → Entra Cloud Sync |
| **Categoria** | IGA Híbrido / Cloud Identity Sync / FinOps |
| **Patrocinador** | Paulo Feitosa Lima |
| **Data Início** | 30/03/2026 |
| **Duração Estimada** | 2-3 dias (10 horas) |
| **Pré-requisitos** | PRJ010, PRJ011, PRJ012 (ATOs 1 e 2), PRJ014 |
| **Sucessor Planejado** | PRJ016 — midPoint como motor IGA On-Premise |
| **Substitui** | Abordagem anterior com midPoint como primeiro passo |

---

## 2. CONTEXTO E JUSTIFICATIVA

### 2.1. Estado Atual

| Componente | Status | Observação |
|------------|--------|------------|
| **OrangeHRM** | ✅ Operacional | 100 colaboradores (FP001-FP100) |
| **Active Directory (ID-P-01)** | ✅ Operacional | 100 usuários com EmployeeID, Department, JobTitle |
| **Microsoft Entra ID** | ✅ Operacional | 100 usuários (PRJ011), App Registration (PRJ012) |
| **midPoint (IGA-GF-01)** | ✅ Operacional | Conectado ao Entra ID (PRJ012 ATO 2) |
| **Sincronização AD → Entra** | ❌ **NÃO CONFIGURADA** | Gap crítico |

### 2.2. Justificativa

A arquitetura de identidade do Living Lab possui todos os componentes funcionando individualmente, mas **não há integração entre eles**. O fluxo atual exige operações manuais para manter AD e Entra ID sincronizados.

**O PRJ015 estabelece a primeira ponte automatizada:**

```
AD (ID-P-01) → Entra Cloud Sync → Entra ID
```

**Por que esta abordagem?**

| Fator | Justificativa |
|-------|---------------|
| **Aproveitamento de ativos existentes** | AD já tem 100 usuários com atributos corretos |
| **Separação de responsabilidades** | Cloud Sync em VM dedicada (`SYNC-01`), não no controlador de domínio |
| **Preparação para futuro** | Quando midPoint assumir, `SYNC-01` pode ser desativada |
| **Custo zero** | Cloud Sync Agent é gratuito; Trial P2 opcional |
| **Aprendizado estratégico** | Validação do cenário híbrido (DPSP) |

---

## 3. ARQUITETURA DA SOLUÇÃO

### 3.1. Diagrama de Arquitetura

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                          PRJ015 - FASE 1 (OBJETIVO)                                 │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                         LIVING LAB FIQUEOK (ON-PREMISE)                     │   │
│  │                                                                              │   │
│  │  ┌─────────────────┐                       ┌─────────────────┐               │   │
│  │  │   ID-P-01       │                       │   SYNC-01       │               │   │
│  │  │   (AD Only)     │──────────────────────▶│   (Cloud Sync)  │               │   │
│  │  │   GEN2          │      LDAP / LDAPS     │   + Provisioner │               │   │
│  │  │   100 usuários  │                       │   GEN2          │               │   │
│  │  │   EmployeeID    │                       │   Golden Disk   │               │   │
│  │  └─────────────────┘                       └────────┬────────┘               │   │
│  │                                                    │                         │   │
│  └────────────────────────────────────────────────────┼─────────────────────────┘   │
│                                                       │                            │
│                                                       │ HTTPS / OAuth2            │
│                                                       ▼                            │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    MICROSOFT ENTRA ID (NUVEM)                              │   │
│  │                                                                              │   │
│  │  ┌──────────────────────────────────────────────────────────────────────┐ │   │
│  │  │  Identity Synchronization                                            │ │   │
│  │  │  • 100 usuários sincronizados via Cloud Sync                         │ │   │
│  │  │  • EmployeeID como âncora imutável                                   │ │   │
│  │  │  • Atributos: displayName, userPrincipalName, department, jobTitle   │ │   │
│  │  └──────────────────────────────────────────────────────────────────────┘ │   │
│  │                                                                              │   │
│  │  ┌──────────────────────────────────────────────────────────────────────┐ │   │
│  │  │  Dynamic Groups (Trial P2 - Opcional)                                │ │   │
│  │  │  • Grupos baseados em Department, JobTitle                           │ │   │
│  │  │  • Atualização automática                                            │ │   │
│  │  └──────────────────────────────────────────────────────────────────────┘ │   │
│  │                                                                              │   │
│  │  ┌──────────────────────────────────────────────────────────────────────┐ │   │
│  │  │  Lifecycle Workflows (Trial P2 - Opcional)                           │ │   │
│  │  │  • Joiner: criação de conta + atribuição de grupos                   │ │   │
│  │  │  • Leaver: desabilitação de conta + revogação de sessões             │ │   │
│  │  └──────────────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                     │
│  ✅ Separação de responsabilidades                                                  │
│  ✅ Preparação para substituir Entra P2 por midPoint                               │
│  ✅ SYNC-01 pode ser desativada quando midPoint assumir                            │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### 3.2. Componentes da Arquitetura

| Componente | Localização | Função | Status |
|------------|-------------|--------|--------|
| **ID-P-01 (AD)** | Hyper-V (GEN2) | Fonte autoritativa de identidades locais | ✅ Existente |
| **SYNC-01** | Hyper-V (GEN2) | VM dedicada para Entra Cloud Sync Agent | 🔄 A criar |
| **Entra Cloud Sync Agent** | SYNC-01 | Sincroniza AD → Entra ID | 🔄 A instalar |
| **Microsoft Entra ID** | Nuvem | Diretório de nuvem (Trial P2) | ✅ Existente |
| **Golden Disk Windows** | C:\Hyper-V\GoldenDisks\ | Template para SYNC-01 | ✅ Pronto |

---

## 4. ESCOPO

### 4.1. Incluído na Fase 1

| Item | Descrição |
|------|-----------|
| ✅ | Validação do AD existente (`ID-P-01`) — usuários, atributos, integridade |
| ✅ | Criação da VM `SYNC-01` a partir do Golden Disk oficial |
| ✅ | Instalação e configuração do Entra Cloud Sync Agent |
| ✅ | Configuração de sincronização AD → Entra ID (EmployeeID como âncora) |
| ✅ | Validação dos 100 usuários sincronizados |
| ✅ | Documentação técnica e evidências de auditoria |

### 4.2. Excluído da Fase 1

| Item | Motivo | Destino |
|------|--------|---------|
| ❌ | Integração OrangeHRM → AD | PRJ016 (midPoint) |
| ❌ | Provisionamento via midPoint | PRJ016 |
| ❌ | Dynamic Groups | Opcional (requer Trial P2) |
| ❌ | Lifecycle Workflows | Opcional (requer Trial P2) |
| ❌ | Alta disponibilidade | Fora do escopo do laboratório |

---

## 5. OBJETIVOS ESPECÍFICOS

| ID | Objetivo | Critério de Sucesso | Relacionamento com GRC |
|----|----------|---------------------|------------------------|
| OBJ-01 | Validar AD existente | 100 usuários com EmployeeID único, atributos preenchidos | **ISO 27001 A.9.2.3** — Gestão de privilégios |
| OBJ-02 | Criar VM SYNC-01 | VM rodando a partir do Golden Disk oficial | **ISO 27001 A.12.1.2** — Gestão de mudanças |
| OBJ-03 | Instalar Entra Cloud Sync Agent | Agente conectado ao tenant, serviço Running | **ISO 27001 A.9.4.1** — Autenticação segura |
| OBJ-04 | Configurar sincronização AD → Entra | EmployeeID como âncora, atributos mapeados | **NIST PR.AC-4** — Controle de acesso |
| OBJ-05 | Validar sincronização | 100 usuários no Entra ID com EmployeeID preservado | **ISO 27001 A.9.2.5** — Revisão de acessos |
| OBJ-06 | Documentar procedimento | POP-IAM-005, REL-PRJ015-Fase1 | **LGPD Art. 46** — Rastreabilidade |

---

## 6. PLANO DE EXECUÇÃO

### 6.1. Fase 0 — Validação do AD (1 hora)

| # | Atividade | Detalhe | Responsável |
|---|-----------|---------|-------------|
| 1 | Validar usuários FP | `Get-ADUser -Filter "EmployeeID -like 'FP*'"` | Paulo |
| 2 | Validar unicidade de EmployeeID | Verificar duplicatas | Paulo |
| 3 | Validar OUs e grupos | Confirmar estrutura organizacional | Paulo |
| 4 | Gerar relatório de validação | Documentar estado atual | Paulo |

### 6.2. Fase 1 — Criação da VM SYNC-01 (1 hora)

| # | Atividade | Detalhe | Responsável |
|---|-----------|---------|-------------|
| 5 | Criar diretório da VM | `C:\Hyper-V\VMs\SYNC-01\` | Paulo |
| 6 | Criar disco diferencial | `New-VHD -ParentPath <GD> -Path <diff> -Differencing` | Paulo |
| 7 | Criar VM | `New-VM -Name SYNC-01 -MemoryStartupBytes 2GB -Generation 2` | Paulo |
| 8 | Configurar recursos | 2 vCPUs, memória dinâmica 1-4GB, Secure Boot On | Paulo |
| 9 | Configurar rede | Conectar ao `vSwitch_External_PRJ003` | Paulo |
| 10 | Iniciar VM | `Start-VM -Name SYNC-01` | Paulo |

### 6.3. Fase 2 — Instalação do Cloud Sync Agent (2 horas)

| # | Atividade | Detalhe | Responsável |
|---|-----------|---------|-------------|
| 11 | Acessar VM SYNC-01 via console | `vmconnect.exe localhost SYNC-01` | Paulo |
| 12 | Fazer login | Credenciais do administrador | Paulo |
| 13 | Baixar Entra Cloud Sync Agent | Portal Entra ID → Hybrid management → Entra Connect | Paulo |
| 14 | Instalar agente | Seguir wizard de instalação | Paulo |
| 15 | Conectar ao tenant | Usar credenciais de administrador global | Paulo |
| 16 | Validar instalação | `Get-Service "Microsoft Entra Cloud Sync"` = Running | Paulo |

### 6.4. Fase 3 — Configuração da Sincronização (2 horas)

| # | Atividade | Detalhe | Responsável |
|---|-----------|---------|-------------|
| 17 | Acessar portal Entra ID | https://entra.microsoft.com | Paulo |
| 18 | Navegar para Provisioning | Identity → Hybrid management → Entra Connect → Cloud sync | Paulo |
| 19 | Criar configuração de sincronização | Selecionar domínio, OUs, atributos | Paulo |
| 20 | Configurar âncora | Mapear `employeeID` (AD) → `employeeId` (Entra) | Paulo |
| 21 | Configurar atributos | `displayName`, `userPrincipalName`, `department`, `jobTitle` | Paulo |
| 22 | Aplicar configuração | Salvar e iniciar sincronização inicial | Paulo |

### 6.5. Fase 4 — Validação (2 horas)

| # | Atividade | Detalhe | Responsável |
|---|-----------|---------|-------------|
| 23 | Aguardar sincronização inicial | 5-30 minutos | Paulo |
| 24 | Validar no portal Entra ID | Contar usuários com EmployeeID FP* | Paulo |
| 25 | Validar atributos | Amostra de 5 usuários (FP001, FP020, FP050, FP080, FP100) | Paulo |
| 26 | Validar EmployeeID como âncora | `Get-MgUser -UserId FP001@fiqueok.com.br -Select OnPremisesImmutableId` | Paulo |
| 27 | Gerar relatório de evidências | Screenshots, logs, JSON de validação | Paulo |

### 6.6. Fase 5 — Documentação (2 horas)

| # | Atividade | Detalhe | Responsável |
|---|-----------|---------|-------------|
| 28 | Criar REL-PRJ015-Fase1 | Relatório de execução | Paulo |
| 29 | Criar POP-IAM-005 | Procedimento de sincronização AD → Entra | Paulo |
| 30 | Arquivar evidências | Screenshots, logs, relatórios | Paulo |

---

## 7. CRONOGRAMA MACRO

| Fase | Atividade | Início | Duração | Entrega |
|------|-----------|--------|---------|---------|
| **F0** | Validação do AD | 30/03 | 1h | Relatório de validação |
| **F1** | Criação VM SYNC-01 | 30/03 | 1h | VM criada e rodando |
| **F2** | Instalação Cloud Sync | 30/03 | 2h | Agente instalado |
| **F3** | Configuração sincronização | 31/03 | 2h | Sincronização configurada |
| **F4** | Validação | 31/03 | 2h | 100 usuários sincronizados |
| **F5** | Documentação | 01/04 | 2h | REL-PRJ015-Fase1 |
| **TOTAL** | | | **10h (2-3 dias)** | |

---

## 8. DEPENDÊNCIAS

| Dependência | Projeto de Origem | Status |
|-------------|-------------------|--------|
| 100 usuários no AD (FP001-FP100) | PRJ010/PRJ014 | ✅ CONCLUÍDO |
| 100 usuários no Entra ID | PRJ011 | ✅ CONCLUÍDO |
| App Registration com permissões | PRJ012 ATO 1 | ✅ CONCLUÍDO |
| Golden Disk Windows OFICIAL | PRJ014 | ✅ CONCLUÍDO |
| Tailscale mesh | PRJ009 | ✅ OPERACIONAL |
| Vault operacional | PRJ007 | ✅ OPERACIONAL |

---

## 9. RISCOS E MITIGAÇÕES

| ID | Risco | Prob | Impacto | Mitigação |
|----|-------|------|---------|-----------|
| R01 | AD não tem EmployeeID único | Baixa | Alto | Validar antes de prosseguir; script de correção se necessário |
| R02 | EmployeeID não preservado na sincronização | Baixa | Alto | Validar manualmente os primeiros 5 usuários; configurar âncora corretamente |
| R03 | Cloud Sync Agent não conecta | Baixa | Médio | Verificar permissões do App Registration (PRJ012) |
| R04 | Sincronização falha por throttling | Baixa | Baixo | Aguardar retry; monitorar logs |
| R05 | Trial P2 expira | Média | Médio | Foco no MVP (sincronização básica); P2 é opcional |

---

## 10. CRITÉRIOS DE SUCESSO

| ID | Critério | Métrica | Status Esperado |
|----|----------|---------|-----------------|
| CS1 | AD validado | 100 usuários com EmployeeID único | ✅ |
| CS2 | VM SYNC-01 criada | VM rodando, disco diferencial OK | ✅ |
| CS3 | Cloud Sync Agent instalado | Serviço Running, conectado ao tenant | ✅ |
| CS4 | Sincronização configurada | EmployeeID como âncora, regras aplicadas | ✅ |
| CS5 | 100 usuários sincronizados | COUNT = 100 no Entra ID | ✅ |
| CS6 | EmployeeID preservado | Amostra de 5 usuários OK | ✅ |
| CS7 | Relatório de auditoria | Documento arquivado | ✅ |

---

## 11. LIÇÕES APRENDIDAS INCORPORADAS

| ID | Lição | Origem | Aplicação no PRJ015 |
|----|-------|--------|---------------------|
| L03 | EmployeeID como âncora imutável | PRJ010/011/012 | Mantido como critério crítico |
| L04 | Data Quality Gate antes de qualquer escrita | PRJ012 ATO 2 | Validação do AD antes de sincronizar |
| L16 | Pre-Flight obrigatório antes de homologar | PRJ014 | Validação do AD existente |
| L20 | Reparo de cadeia diferencial | PRJ014 | Aplicável na criação do SYNC-01 |

---

## 12. ENTREGÁVEIS

| ID | Entregável | Formato | Localização |
|----|------------|--------|-------------|
| E1 | Relatório de validação do AD | MD | `10_Projetos/PRJ015/` |
| E2 | VM SYNC-01 | VHDX | `C:\Hyper-V\VMs\SYNC-01\` |
| E3 | Evidências de instalação do Cloud Sync | PNG | `10_Projetos/PRJ015/Evidencias/` |
| E4 | Evidências de sincronização | PNG | `10_Projetos/PRJ015/Evidencias/` |
| E5 | REL-PRJ015-Fase1 | MD | `10_Projetos/PRJ015/` |
| E6 | POP-IAM-005 | MD | `05_BASE-LAB/03_Metodologia-e-Frameworks/` |

---

## 13. APROVAÇÕES

| Função | Nome | Data | Status |
|--------|------|------|:------:|
| GRC Lead / Responsável Técnico | Paulo Feitosa Lima | 30/03/2026 | ✅ APROVADO |
| GRC Advisor | DeepSeek | 30/03/2026 | ✅ REVISADO |
| FinOps / Custo | Paulo Feitosa Lima | 30/03/2026 | ✅ ZERO CUSTO CONFIRMADO |

---

## 14. NOTA DE TRANSIÇÃO PARA PRJ016

> **O PRJ015 estabelece a sincronização básica AD → Entra ID, utilizando o Cloud Sync Agent em VM dedicada.**
>
> **O PRJ016 (futuro) substituirá a inteligência de provisão pelo midPoint On-Premise, permitindo:**
> - Eliminação da dependência de licenças P2 (Dynamic Groups, Lifecycle Workflows)
> - Consolidação da governança em uma plataforma open-source
> - Automação completa do ciclo JML (Joiner, Mover, Leaver)
>
> **A VM SYNC-01 será mantida apenas para o Cloud Sync (AD → Entra), podendo ser desativada quando o midPoint assumir o provisionamento direto.**

---

**FIM DO TAP-PRJ015 v1.0**

---

*Documento mantido por Paulo Feitosa Lima — Living Lab Fiqueok*  
*Próxima revisão: Após conclusão da Fase 0 (validação do AD)*
