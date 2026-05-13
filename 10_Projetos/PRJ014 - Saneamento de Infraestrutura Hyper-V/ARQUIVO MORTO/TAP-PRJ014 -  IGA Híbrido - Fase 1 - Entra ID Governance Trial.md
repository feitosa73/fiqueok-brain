> [!warning] DOCUMENTO SUPERSEDIDO — NÃO UTILIZAR COMO REFERÊNCIA ATIVA
> 
> **Status:** ~~ATIVO~~ → **SUPERSEDIDO em 27/03/2026**
> 
> Este TAP foi elaborado em 26/03/2026 com o escopo original do PRJ014 (IGA Híbrido Local: OrangeHRM → AD → Entra Cloud Sync). Durante a execução, o escopo foi **dividido em três projetos distintos** por razões técnicas e de governança:
> 
> |Projeto|Escopo herdado deste TAP|Status|Documento de referência|
> |---|---|---|---|
> |**PRJ014**|Saneamento da infraestrutura Hyper-V (pré-requisito para tudo)|✅ Concluído|`TEP-PRJ014-v1.1`|
> |**PRJ015**|AD → Entra Cloud Sync (este escopo, renumerado)|📋 Planejado|`TAP-PRJ015-v1.0`|
> |**PRJ016**|midPoint como motor IGA on-premise|📋 Futuro|A criar|
> 
> **Motivo da divisão:**
> 
> - A infraestrutura Hyper-V precisava de saneamento antes de qualquer projeto IGA (virou PRJ014).
> - O Golden Disk Windows Server 2022 exigiu ciclo de purificação não previsto (descomissionamento de AD/DNS/DHCP + remoção do Edge para viabilizar Sysprep), atrasando o início do IGA.
> - A separação de responsabilidades entre o DC (`ID-P-01`) e o agente de sincronização (`SYNC-01`) foi adotada como decisão arquitetural — diferente do design original que colocava o Cloud Sync Agent no próprio DC.
> 
> **Este arquivo é mantido como registro histórico do planejamento original.** Não representa o estado atual de nenhum projeto ativo.
> 
> → Consulte `TAP-PRJ015-v1.0` para o planejamento vigente do IGA Híbrido.

---

# TAP - PRJ014: IGA Híbrido Local (OrangeHRM → AD → Entra ID)

_(conteúdo original preservado abaixo)_

---# 

| Campo | Valor |
|-------|-------|
| **Código** | TAP-PRJ014 |
| **Versão** | 1.1 |
| **Data** | 26/03/2026 |
| **Responsável** | Paulo Feitosa Lima — GRC Lead / Especialista IAM |
| **Ambiente** | Living Lab Fiqueok — On-Premise + Microsoft Entra ID (Trial) |
| **Status** | ATIVO — Fase 1 em andamento |
| **Classificação** | Confidencial Interno |

---

## CHANGELOG

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 26/03/2026 | Paulo Feitosa Lima | Criação — IGA Híbrido Local |
| 1.1 | 26/03/2026 | Paulo Feitosa Lima | **Revisão estratégica** — Adoção de abordagem em duas fases, ativação do Trial Entra ID Governance, planejamento de transição para PRJ015 (midPoint). |

---

## 1. IDENTIFICAÇÃO DO PROJETO

| Campo | Valor |
|-------|-------|
| **Código** | PRJ014 |
| **Nome** | IGA Híbrido — Fase 1: Entra ID Governance Trial |
| **Categoria** | IGA Híbrido / Cloud Identity Governance / FinOps |
| **Patrocinador** | Paulo Feitosa Lima |
| **Data Início** | 26/03/2026 |
| **Duração Estimada** | 30–45 dias (período do Trial) |
| **Pré-requisitos** | PRJ010, PRJ011, PRJ012 (ATOs 1 e 2) |
| **Sucessor Planejado** | PRJ015 — midPoint como motor de IGA On-Premise |
| **Substitui** | PRJ009 (encerrado por custo de infraestrutura) |

---

## 2. CONTEXTO E JUSTIFICATIVA ESTRATÉGICA

### 2.1. Histórico e Pivotagem

O **PRJ009** foi concebido como um experimento de arquitetura híbrida, utilizando uma VM Gateway no Azure para conectar o OrangeHRM local ao midPoint. Com a expiração dos créditos da subscrição Azure, a estratégia foi revista.

**Decisão documentada no ADR-PRJ009-002:** Desprovisionar a VM e transferir a inteligência de sincronização para a borda (on-premise).

No entanto, essa decisão abriu uma oportunidade estratégica:

> *Em vez de migrar imediatamente a inteligência de IGA para o midPoint, podemos aproveitar o período de Trial do Microsoft Entra ID Governance (P2) para validar funcionalidades nativas de nuvem — sem custo de infraestrutura e com baixo esforço de implementação.*

### 2.2. Justificativa para a Abordagem em Duas Fases

| Fator | Impacto | Decisão |
|-------|---------|---------|
| **Custo de Infraestrutura** | VM Azure = custo recorrente | Eliminado — sync via AD local + Cloud Sync |
| **Custo de Licenciamento** | Entra ID Governance (P2) = pago | Mitigado — uso de Trial de 30–90 dias |
| **Aprendizado Estratégico** | Demanda externa (DPSP) exige conhecimento em Cloud Sync e Access Reviews | Atendido — Fase 1 foca exatamente nessas competências |
| **Governança de Longo Prazo** | midPoint é gratuito e on-premise | Preservado — Fase 2 (PRJ015) migrará a inteligência para midPoint |

### 2.3. Resumo Executivo

O PRJ014 é um projeto de **duas fases**:

- **Fase 1 (este TAP):** Utilizar o Trial do Microsoft Entra ID Governance para implementar sincronização de identidades (Cloud Sync), Dynamic Groups e Lifecycle Workflows (Joiner/Leaver), aproveitando o licenciamento temporário para validar funcionalidades de nuvem sem custo de infraestrutura.

- **Fase 2 (PRJ015 — futuro):** Após o término do Trial (ou em paralelo), migrar a inteligência de IGA para o **midPoint On-Premise**, eliminando a dependência de licenças pagas e consolidando a governança em uma solução open-source.

---

## 3. ARQUITETURA DA SOLUÇÃO — FASE 1

### 3.1. Diagrama de Arquitetura

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           LIVING LAB FIQUEOK                               │
│                           FASE 1 — Entra ID Governance Trial               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────────┐  │
│  │   OrangeHRM      │───▶│   PowerShell     │───▶│      Active          │  │
│  │   (rh-gf-01)     │SQL │   Script        │LDAP│      Directory       │  │
│  │   100 usuários   │    │   (Python/PS)   │    │      (Greenfield)    │  │
│  └──────────────────┘    └──────────────────┘    └──────────┬───────────┘  │
│                                                            │              │
│                                                    ┌───────▼───────────┐  │
│                                                    │   Microsoft Entra │  │
│                                                    │   Cloud Sync      │  │
│                                                    │   Agent (local)   │  │
│                                                    └───────┬───────────┘  │
│                                                            │              │
└────────────────────────────────────────────────────────────┼──────────────┘
                                                             │ HTTPS / TLS 1.2
                                                             ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                    MICROSOFT ENTRA ID (TRIAL P2/GOVERNANCE)               │
├────────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────────────────────┐ │
│  │  Identity Synchronization                                            │ │
│  │  • 100 usuários sincronizados via Cloud Sync                         │ │
│  │  • EmployeeID como âncora imutável                                   │ │
│  └──────────────────────────────────────────────────────────────────────┘ │
│  ┌──────────────────────────────────────────────────────────────────────┐ │
│  │  Dynamic Groups (Licenciamento P1/P2)                                │ │
│  │  • Grupos baseados em Department, JobTitle, EmployeeID               │ │
│  │  • Atualização automática sem intervenção manual                     │ │
│  └──────────────────────────────────────────────────────────────────────┘ │
│  ┌──────────────────────────────────────────────────────────────────────┐ │
│  │  Lifecycle Workflows (Licenciamento Governance)                      │ │
│  │  • Joiner: criação de conta + atribuição de grupos                   │ │
│  │  • Leaver: desabilitação de conta + revogação de sessões             │ │
│  │  • Access Reviews: certificação periódica de acessos                 │ │
│  └──────────────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────────────┘
```

### 3.2. Componentes da Arquitetura

| Componente | Localização | Função |
|------------|-------------|--------|
| **OrangeHRM** | rh-gf-01 (local) | Fonte autoritativa — dados de RH |
| **Script de Ingestão** | Windows/Linux | Lê OrangeHRM, cria/atualiza usuários no AD |
| **Active Directory** | VM Windows Server (local) | Diretório intermediário — mantém identidades locais |
| **Entra Cloud Sync Agent** | VM AD (local) | Sincroniza AD → Entra ID |
| **Microsoft Entra ID** | Nuvem (Trial P2) | Diretório de nuvem com funcionalidades de governança |
| **Dynamic Groups** | Entra ID | Grupos baseados em regras dinâmicas |
| **Lifecycle Workflows** | Entra ID | Automação de Joiner/Mover/Leaver |
| **Access Reviews** | Entra ID | Certificação periódica de acessos |

---

## 4. ESCOPO

### 4.1. Incluído na Fase 1

| Item | Descrição |
|------|-----------|
| ✅ | Ativação do Trial do Microsoft Entra ID Governance (P2) |
| ✅ | Configuração do Active Directory local (Greenfield) |
| ✅ | Script de ingestão OrangeHRM → AD (PowerShell) |
| ✅ | Instalação e configuração do Entra Cloud Sync Agent |
| ✅ | Sincronização dos 100 usuários AD → Entra ID |
| ✅ | Configuração de Dynamic Groups baseados em Department e JobTitle |
| ✅ | Configuração de Lifecycle Workflows (Joiner e Leaver) |
| ✅ | Configuração de Access Reviews para grupos críticos |
| ✅ | Documentação técnica e evidências de auditoria |

### 4.2. Excluído da Fase 1

| Item | Motivo | Destino |
|------|--------|---------|
| ❌ | midPoint como motor de IGA | PRJ015 (Fase 2) |
| ❌ | Provisionamento reverso (Entra → OrangeHRM) | Não aplicável |
| ❌ | Alta disponibilidade do AD | Fora do escopo do laboratório |
| ❌ | Conditional Access / MFA avançado | Fora do escopo da Fase 1 |

### 4.3. Transição para PRJ015 (Fase 2)

| Item | Descrição |
|------|-----------|
| **Objetivo** | Migrar a inteligência de IGA do Entra ID para o midPoint |
| **Motivo** | Eliminar dependência de licenças pagas após o Trial |
| **Ativos reutilizados** | AD local, 100 usuários, EmployeeID como âncora, grupos de segurança |
| **Arquitetura prevista** | OrangeHRM → midPoint → AD → Entra ID (com Cloud Sync mantido) |
| **Cronograma estimado** | Após 30–90 dias do Trial (ou em paralelo) |

---

## 5. OBJETIVOS ESPECÍFICOS DA FASE 1

| ID | Objetivo | Critério de Sucesso | Relacionamento com GRC |
|----|----------|---------------------|------------------------|
| OBJ-01 | Ativar Trial do Microsoft Entra ID Governance (P2) | Licenciamento P2 ativo no tenant, funcionalidades de Governance disponíveis | **ISO 27001 A.9.2.1** — Registro de usuários |
| OBJ-02 | Configurar AD local e sincronizar 100 usuários | 100 usuários no AD, 100 usuários sincronizados no Entra ID | **ISO 27001 A.9.2.3** — Gestão de privilégios |
| OBJ-03 | Implementar Dynamic Groups baseados em atributos | Grupos atualizam automaticamente com base em Department/JobTitle | **NIST PR.AC-4** — Controle de acesso baseado em atributos |
| OBJ-04 | Configurar Lifecycle Workflows (Joiner/Leaver) | Novo usuário no OrangeHRM → conta criada e grupos atribuídos em < 30 min | **ISO 27001 A.9.2.2** — Processo de onboarding |
| OBJ-05 | Configurar Access Reviews para grupos críticos | Revisão de acessos agendada e executada com evidências | **ISO 27001 A.9.2.5** — Revisão periódica de acessos |
| OBJ-06 | Documentar procedimento e evidências | POP-IAM-004 atualizado, evidências arquivadas | **LGPD Art. 46** — Rastreabilidade |

---

## 6. PLANO DE EXECUÇÃO — FASE 1

### 6.1. Fase 1A — Fundação (Dias 1–2)

| # | Atividade | Detalhe | Responsável |
|---|-----------|---------|-------------|
| 1 | Ativar Trial do Entra ID Governance | Portal Microsoft 365 → Licenças → Ativar Trial P2 | Paulo |
| 2 | Provisionar AD Local (Greenfield) | VM Windows Server + AD DS + OUs (espelhando estrutura OrangeHRM) | Paulo |
| 3 | Testar conectividade Tailscale | Confirmar comunicação entre VMs | Paulo |

### 6.2. Fase 1B — Ingestão e Sincronização (Dias 3–4)

| # | Atividade | Detalhe | Responsável |
|---|-----------|---------|-------------|
| 4 | Desenvolver script de ingestão | PowerShell: lê OrangeHRM via MySQL, cria usuários no AD | Paulo |
| 5 | Executar ingestão | 100 usuários criados no AD com atributos: EmployeeID, Department, JobTitle, DisplayName | Paulo |
| 6 | Instalar Entra Cloud Sync Agent | Baixar do portal, instalar na VM AD, conectar ao tenant | Paulo |
| 7 | Configurar regras de sincronização | Mapear atributos AD → Entra ID, garantir EmployeeID como âncora | Paulo |
| 8 | Executar sincronização inicial | 100 usuários no Entra ID, validar integridade | Paulo |

### 6.3. Fase 1C — Governança (Dias 5–6)

| # | Atividade | Detalhe | Responsável |
|---|-----------|---------|-------------|
| 9 | Criar Dynamic Groups | Regras baseadas em Department e JobTitle (ex: GRP_IT_DEV = Department eq "Technology - Dev") | Paulo |
| 10 | Configurar Lifecycle Workflows | Workflow de Joiner: criar usuário, atribuir grupos, enviar e-mail | Paulo |
| 11 | Configurar Access Reviews | Revisão trimestral para grupos de segurança críticos | Paulo |
| 12 | Testar ciclo JML | Criar novo usuário no OrangeHRM → AD → Entra ID → grupos atribuídos | Paulo |

### 6.4. Fase 1D — Validação e Documentação (Dia 7)

| # | Atividade | Detalhe | Responsável |
|---|-----------|---------|-------------|
| 13 | Validar todos os 100 usuários | EmployeeID preservado, grupos corretos, atributos sincronizados | Paulo |
| 14 | Coletar evidências | Screenshots, logs, relatórios de auditoria | Paulo |
| 15 | Documentar POP | POP-IAM-004 — Provisionamento OrangeHRM → Entra ID via Cloud Sync | Paulo |
| 16 | Preparar relatório de encerramento | REL-PRJ014-Fase1 | Paulo |

---

## 7. LICENCIAMENTO E CUSTOS

### 7.1. Fase 1 — Entra ID Governance Trial

| Item | Custo | Observação |
|------|-------|------------|
| Microsoft Entra ID P2 (Trial) | R$ 0,00 | 30–90 dias de avaliação |
| Entra Cloud Sync Agent | R$ 0,00 | Gratuito |
| Active Directory (on-premise) | R$ 0,00 | Infraestrutura local já existente |
| OrangeHRM | R$ 0,00 | Docker local |
| Tailscale | R$ 0,00 | Free tier (até 3 usuários) |
| **TOTAL FASE 1** | **R$ 0,00** | |

### 7.2. Transição para PRJ015 (Fase 2 — midPoint)

| Item | Custo | Observação |
|------|-------|------------|
| midPoint | R$ 0,00 | Open-source |
| Entra ID Free | R$ 0,00 | Após Trial, mantém sincronização básica |
| Dynamic Groups | ❌ Perdido | Funcionalidade P1/P2 — será substituído por RBAC no midPoint |
| Lifecycle Workflows | ❌ Perdido | Será substituído por workflows no midPoint |

---

## 8. RISCOS E MITIGAÇÕES

| ID | Risco | Prob | Impacto | Mitigação |
|----|-------|------|---------|-----------|
| R01 | Trial do Entra ID Governance expira antes da conclusão | Média | Alto | Ativar Trial imediatamente; planejar execução em 7 dias contínuos |
| R02 | Dynamic Groups exigem atributos consistentes no AD | Média | Médio | Script de ingestão sanitiza dados antes da criação no AD |
| R03 | EmployeeID não preservado na sincronização AD → Entra | Baixa | Alto | Validar manualmente os primeiros 5 usuários; usar `OnPremisesImmutableId` |
| R04 | Lifecycle Workflows não disparam para usuários existentes | Baixa | Médio | Criar usuário de teste novo para validar fluxo |
| R05 | Dependência de licença P1/P2 após Trial | Alta | Alto | **Plano de transição definido** — PRJ015 (midPoint) será ativado antes do fim do Trial |
| R06 | Script de ingestão falha por encoding ou caracteres especiais | Média | Médio | Teste com 1 usuário antes do bulk; usar UTF-8 |

---

## 9. CRITÉRIOS DE SUCESSO

| ID | Critério | Métrica | Status Esperado |
|----|----------|---------|-----------------|
| CS1 | Trial do Entra ID Governance ativado | Licenciamento P2 visível no portal | ✅ ATIVO |
| CS2 | 100 usuários no AD | COUNT = 100 | ✅ |
| CS3 | 100 usuários sincronizados no Entra ID | COUNT = 100, EmployeeID preservado | ✅ |
| CS4 | Dynamic Groups funcionando | Grupos atualizam automaticamente com base em Department | ✅ |
| CS5 | Lifecycle Workflow de Joiner validado | Novo usuário criado no OrangeHRM → conta no Entra ID em < 30 min | ✅ |
| CS6 | Lifecycle Workflow de Leaver validado | Usuário desabilitado no AD → desabilitado no Entra ID | ✅ |
| CS7 | Access Reviews configuradas | Revisão agendada, convites enviados | ✅ |
| CS8 | Documentação e evidências arquivadas | POP-IAM-004, REL-PRJ014-Fase1 | ✅ |

---

## 10. PLANO DE TRANSIÇÃO PARA PRJ015 (FASE 2 — MIDPOINT)

### 10.1. Justificativa

O Trial do Entra ID Governance tem duração limitada (30–90 dias). Para manter as funcionalidades de IGA sem custo recorrente, a inteligência de governança será migrada para o **midPoint On-Premise**.

### 10.2. Arquitetura da Fase 2

```
OrangeHRM (local) → midPoint → AD → Entra Cloud Sync → Entra ID (Free)
```

| Componente | Função na Fase 2 |
|------------|------------------|
| **OrangeHRM** | Fonte autoritativa |
| **midPoint** | Motor de IGA — Joiner, Mover, Leaver, RBAC |
| **AD** | Diretório intermediário (mantido) |
| **Entra Cloud Sync** | Sincroniza AD → Entra ID (gratuito) |
| **Entra ID Free** | Diretório de nuvem (sem Dynamic Groups, sem Lifecycle Workflows) |

### 10.3. Ativos Reutilizados da Fase 1

| Ativo | Reutilização |
|-------|--------------|
| AD local | Mantido como diretório intermediário |
| 100 usuários no AD | Reutilizados como base para midPoint |
| EmployeeID como âncora | Mantido em todo o fluxo |
| Grupos de segurança | Mantidos, mas gerenciados pelo midPoint |

### 10.4. Cronograma Estimado para PRJ015

| Fase | Atividade | Duração |
|------|-----------|---------|
| 1 | Configurar conector midPoint → AD | 1 dia |
| 2 | Configurar conector OrangeHRM → midPoint | 1 dia |
| 3 | Implementar RBAC (grupos baseados em Department) | 1 dia |
| 4 | Testar ciclo JML completo | 1 dia |
| 5 | Documentar e encerrar | 1 dia |

---

## 11. DEPENDÊNCIAS

| Dependência | Projeto de Origem | Status |
|-------------|-------------------|--------|
| 100 usuários no OrangeHRM | PRJ010 | ✅ CONCLUÍDO |
| 100 usuários no Entra ID (baseline) | PRJ011 | ✅ CONCLUÍDO |
| App Registration com permissões | PRJ012 ATO 1 | ✅ CONCLUÍDO |
| Tailscale mesh | PRJ009 | ✅ OPERACIONAL |
| Vault operacional | PRJ007 | ✅ OPERACIONAL |
| AD local (Greenfield) | PRJ014 | 🔄 A SER PROVISIONADO |
| Trial Entra ID Governance | PRJ014 | 🔄 A SER ATIVADO |

---

## 12. LIÇÕES APRENDIDAS INCORPORADAS

| ID | Lição | Origem | Aplicação no PRJ014 |
|----|-------|--------|---------------------|
| L03 | EmployeeID como âncora imutável | PRJ010/011/012 | Mantido como critério crítico |
| L04 | Data Quality Gate antes de qualquer escrita | PRJ012 ATO 2 | Script de ingestão valida atributos antes da criação no AD |
| L05 | Dry Run obrigatório | PRJ012 ATO 2 | Aplicável na migração para PRJ015 |
| L06 | Documentar decisão de abortar | PRJ009 | Aplicado no ADR-PRJ009-002 e neste TAP |
| L07 | Projetos com componentes pagos exigem plano de continuidade | PRJ009 | **Plano de transição para PRJ015 documentado** |

---

## 13. CRONOGRAMA MACRO

| Fase | Atividade | Início | Duração | Entrega |
|------|-----------|--------|---------|---------|
| 1A | Fundação (AD + Trial) | 26/03 | 2 dias | AD operacional, Trial ativado |
| 1B | Ingestão e Sincronização | 28/03 | 2 dias | 100 usuários sincronizados |
| 1C | Governança (Dynamic Groups, Workflows) | 30/03 | 2 dias | Grupos, workflows, access reviews |
| 1D | Validação e Documentação | 01/04 | 1 dia | REL-PRJ014-Fase1 |
| **Transição** | Planejamento PRJ015 | 02/04 | 1 dia | TAP-PRJ015 |

---

## 14. APROVAÇÕES

| Função | Nome | Data | Status |
|--------|------|------|:------:|
| GRC Lead / Responsável Técnico | Paulo Feitosa Lima | 26/03/2026 | ✅ APROVADO |
| GRC Advisor | Perplexity AI | 26/03/2026 | ✅ REVISADO |
| FinOps / Custo | Paulo Feitosa Lima | 26/03/2026 | ✅ ZERO CUSTO CONFIRMADO |

---

## 15. NOTA DE TRANSIÇÃO PARA PRJ015

> **O PRJ014 (Fase 1) é um projeto de validação de funcionalidades nativas de nuvem utilizando o Trial do Microsoft Entra ID Governance.**
>
> **Após o término do Trial (ou em paralelo), a inteligência de IGA será migrada para o midPoint On-Premise no PRJ015.**
>
> **Esta decisão é baseada em:**
> - Eliminação de custos recorrentes (licenças P2)
> - Consolidação da governança em uma plataforma open-source
> - Preservação dos ativos construídos (AD, 100 usuários, EmployeeID como âncora)
>
> **O PRJ015 está planejado para início em abril/2026, com conclusão antes da expiração do Trial.**

---

**FIM DO TAP-PRJ014 v1.1**

---

*Documento mantido por Paulo Feitosa Lima — Living Lab Fiqueok*  
*Próxima revisão: Após conclusão da Fase 1B (sincronização dos 100 usuários)*
