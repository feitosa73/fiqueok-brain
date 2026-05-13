# TERMO DE ENCERRAMENTO DO PROJETO

| Campo             | Valor                                                                      |
| ----------------- | -------------------------------------------------------------------------- |
| **Código**        | TEP-PRJ015                                                                 |
| **Versão**        | 1.0                                                                        |
| **Data**          | 31/03/2026                                                                 |
| **Responsável**   | Paulo Feitosa Lima — GRC Lead / Especialista IAM                           |
| **Projeto**       | PRJ015 — IGA Híbrido Local (AD → Entra Cloud Sync)                         |
| **Status Final**  | ✅ **CONCLUÍDO** — Sincronização AD → Entra ID operacional com 100 usuários |
| **Classificação** | Confidencial Interno — Lab Fiqueok                                         |

---

## 1. CHANGELOG

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 31/03/2026 | Paulo Feitosa Lima | Criação — Encerramento formal do PRJ015 |

---

## 2. EXECUÇÃO DO PROJETO

### 2.1. Resumo Executivo

O projeto foi executado entre **30/03/2026 e 31/03/2026**, com duração total de **2 dias (aproximadamente 14 horas)**. A execução enfrentou desafios significativos relacionados à infraestrutura de rede (mudança de IP do AD) e configuração de permissões do gMSA, mas todos os critérios de sucesso foram atingidos.

### 2.2. Fases Executadas

| Fase | Atividade | Duração Real | Status |
|------|-----------|--------------|--------|
| F0 | Validação do AD | 1h | ✅ |
| F1 | Criação VM SYNC-01 | 1h | ✅ |
| F2 | Instalação Cloud Sync Agent | 2h | ✅ |
| F3 | Configuração sincronização | 3h | ✅ |
| F4 | Validação | 2h | ✅ |
| F5 | Documentação | 2h | ✅ |

---

## 3. ARQUITETURA FINAL

### 3.1. Componentes Implementados

| Componente | Localização | Função | Status |
|------------|-------------|--------|--------|
| **ID-P-01 (AD)** | Hyper-V (GEN2) | Fonte autoritativa de identidades locais | ✅ Operacional |
| **SYNC-01** | Hyper-V (GEN2) | VM dedicada para Entra Cloud Sync Agent | ✅ Operacional |
| **Entra Cloud Sync Agent** | SYNC-01 | Sincroniza AD → Entra ID | ✅ Instalado e registrado |
| **gMSA** | AD | Conta de serviço gerenciada | ✅ `pGMSA_03ec3eec$` criado |
| **Microsoft Entra ID** | Nuvem | Diretório de nuvem | ✅ Sincronização ativa |

### 3.2. Diagrama Final

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                          PRJ015 - EXECUTADO COM SUCESSO                             │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                         LIVING LAB FIQUEOK (ON-PREMISE)                     │   │
│  │                                                                              │   │
│  │  ┌─────────────────┐                       ┌─────────────────┐               │   │
│  │  │   ID-P-01       │                       │   SYNC-01       │               │   │
│  │  │   (AD Only)     │──────────────────────▶│   (Cloud Sync)  │               │   │
│  │  │   172.28.98.200 │      LDAP / LDAPS     │   + Provisioner │               │   │
│  │  │   100 usuários  │                       │   172.28.99.136 │               │   │
│  │  │   EmployeeID    │                       │   gMSA ativo    │               │   │
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
│  │  │  • EmployeeID como âncora imutável (employeeID → employeeId)        │ │   │
│  │  │  • Atributos: displayName, userPrincipalName, department, title      │ │   │
│  │  └──────────────────────────────────────────────────────────────────────┘ │   │
│  │                                                                              │   │
│  │  ┌──────────────────────────────────────────────────────────────────────┐ │   │
│  │  │  Provisioning Logs                                                   │ │   │
│  │  │  • Sincronização ativa desde 31/03/2026 11:43:58                     │ │   │
│  │  │  • Status "Success" para usuários e grupos                           │ │   │
│  │  └──────────────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                     │
│  ✅ Separação de responsabilidades (SYNC-01 dedicada)                               │
│  ✅ gMSA configurado com permissões adequadas                                       │
│  ✅ Sincronização operacional com 100 usuários                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. CRITÉRIOS DE SUCESSO — VERIFICAÇÃO

| ID | Critério | Métrica | Status | Evidência |
|----|----------|---------|--------|-----------|
| CS1 | AD validado | 100 usuários com EmployeeID único | ✅ | `Get-ADUser -Filter "EmployeeID -like 'FP*'"` retornou 100 |
| CS2 | VM SYNC-01 criada | VM rodando, disco diferencial OK | ✅ | VM criada a partir do Golden Disk oficial |
| CS3 | Cloud Sync Agent instalado | Serviço Running, conectado ao tenant | ✅ | `sc query AADConnectProvisioningAgent` = Running |
| CS4 | Sincronização configurada | EmployeeID como âncora | ✅ | Configuração `corp.fiqueok.com.br` ativa no portal |
| CS5 | 100 usuários sincronizados | COUNT = 100 no Entra ID | ✅ | Provisioning logs confirmam sincronização |
| CS6 | EmployeeID preservado | Amostra de 5 usuários OK | ✅ | FP001, FP020, FP050, FP080, FP100 validados |
| CS7 | Relatório de auditoria | Documento arquivado | ✅ | TEP-PRJ015 v1.0 |

---

## 5. OBSTÁCULOS ENFRENTADOS E SOLUÇÕES

### 5.1. Mudança de IP do AD (xxx.xxx.xxx.xxx → 172.28.98.200)

| Problema | Impacto | Solução |
|----------|---------|---------|
| DNS Server com erros de bind (408, 404, 407) | Agente não conseguia se comunicar com o AD | Correção manual: `ipconfig /registerdns`, `nltest /dsregdns`, reinício do DNS |
| Registros SRV do AD não publicados | Descoberta do DC falhava | Verificação e correção manual dos registros DNS |
| Server Manager com status "Manageability" vermelho | Dificuldade de gerenciamento | Reinício do ADWS (`net stop ADWS /y; net start ADWS`) |

### 5.2. Configuração do gMSA

| Problema | Impacto | Solução |
|----------|---------|---------|
| Nome do gMSA não correspondia ao esperado | Comandos de permissão falhavam | Identificação do SamAccountName correto: `pGMSA_03ec3eec$` |
| Permissões de leitura não concedidas automaticamente | Agente não conseguia ler o AD | Concessão manual de permissões via dsacls e ADSI |
| Erro "The parameter is incorrect" no dsacls | Sintaxe do comando incorreta | Uso de ADSI PowerShell como alternativa |

### 5.3. Provision on Demand

| Problema | Impacto | Solução |
|----------|---------|---------|
| Erro "The input entry was not found in Active Directory" | Teste inicial falhou | Correção das permissões do gMSA e reinício do serviço |
| Cache do navegador bloqueando configuração | Domínio não aparecia no dropdown | Uso de janela de navegação privada/incógnita |

---

## 6. LIÇÕES APRENDIDAS

| ID | Lição | Origem | Aplicação Futura |
|----|-------|--------|------------------|
| L21 | Mudança de IP do AD requer correção manual do DNS | Mudança de rede | Documentar procedimento de troca de IP em DCs |
| L22 | O gMSA criado pelo wizard tem SamAccountName diferente do nome comum | Configuração do Cloud Sync | Sempre verificar `Get-ADObject` para obter SamAccountName correto |
| L23 | Permissões do gMSA não são herdadas automaticamente na OU de usuários | Configuração do Cloud Sync | Conceder permissões explicitamente na OU alvo |
| L24 | ADWS pode ficar inconsistente após mudanças de IP | Reinício de serviços | Incluir `Restart-Service ADWS` no procedimento pós-mudança de IP |
| L25 | Provision on demand é o melhor teste de validação | Fase de validação | Usar como primeiro passo antes de aguardar sincronização completa |
| L26 | Navegação privada/incógnita resolve problemas de cache do portal | Configuração do portal | Documentar como etapa de troubleshooting |

---

## 7. ENTREGÁVEIS REALIZADOS

| ID | Entregável | Formato | Localização | Status |
|----|------------|--------|-------------|--------|
| E1 | Relatório de validação do AD | MD | `10_Projetos/PRJ015/` | ✅ |
| E2 | VM SYNC-01 | VHDX | `C:\Hyper-V\VMs\SYNC-01\` | ✅ |
| E3 | Evidências de instalação do Cloud Sync | PNG | `10_Projetos/PRJ015/Evidencias/` | ✅ |
| E4 | Evidências de sincronização | PNG | `10_Projetos/PRJ015/Evidencias/` | ✅ |
| E5 | REL-PRJ015-Fase1 | MD | `10_Projetos/PRJ015/` | ✅ (TEP-PRJ015) |
| E6 | POP-IAM-005 | MD | `05_BASE-LAB/03_Metodologia-e-Frameworks/` | 📋 Pendente |

---

## 8. CONFIGURAÇÕES TÉCNICAS FINAIS

### 8.1. Active Directory (ID-P-01)

| Parâmetro | Valor |
|-----------|-------|
| IP Address | 172.28.98.200 |
| Subnet Mask | 255.255.0.0 |
| Gateway | 172.28.96.1 |
| DNS | 127.0.0.1 (próprio) |
| Domínio | corp.fiqueok.com.br |
| Usuários | 100 (FP001-FP100) |
| Atributos | EmployeeID, Department, Title, displayName |

### 8.2. VM SYNC-01

| Parâmetro | Valor |
|-----------|-------|
| IP Address | 172.28.99.136 (DHCP) |
| DNS | 172.28.98.200 (AD) |
| Serviço | AADConnectProvisioningAgent (Running) |
| Conta de Serviço | corp.fiqueok.com.br\pGMSA_03ec3eec$ |

### 8.3. Entra Cloud Sync

| Parâmetro | Valor |
|-----------|-------|
| Configuração | corp.fiqueok.com.br |
| Status | Enabled / Healthy |
| Domínio | corp.fiqueok.com.br |
| OU Escopo | OU=04_People,OU=Fiqueok_Corp,DC=corp,DC=fiqueok,DC=com,DC=br |
| Âncora | employeeID (AD) → employeeId (Entra) |
| Atributos | department, title, displayName, userPrincipalName |
| Password Hash Sync | Enabled |

---

## 9. PENDÊNCIAS (Não Bloqueantes)

| # | Item | Prioridade | Ação Recomendada |
|---|------|------------|------------------|
| P1 | POP-IAM-005 (Procedimento de sincronização) | Média | Criar documento formal com passo a passo da configuração |
| P2 | Relatório de validação de atributos | Baixa | Gerar relatório completo dos 100 usuários com atributos |
| P3 | Teste de fallback/recuperação | Baixa | Documentar procedimento de recuperação em caso de falha |

---

## 10. PRÓXIMOS PASSOS — PRJ016

| Atividade | Descrição | Dependência |
|-----------|-----------|-------------|
| **PRJ016 - midPoint como motor IGA** | Substituir inteligência de provisão pelo midPoint On-Premise | PRJ015 concluído |
| **Eliminação de dependência P2** | Dynamic Groups e Lifecycle Workflows migrados para midPoint | PRJ016 |
| **Automação JML** | Joiner, Mover, Leaver via midPoint | PRJ016 |
| **Desativação do Cloud Sync (opcional)** | Quando midPoint assumir provisionamento direto | PRJ016 validado |

---

## 11. APROVAÇÕES

| Função | Nome | Data | Status |
|--------|------|------|:------:|
| GRC Lead / Responsável Técnico | Paulo Feitosa Lima | 31/03/2026 | ✅ APROVADO |
| GRC Advisor | DeepSeek | 31/03/2026 | ✅ REVISADO |
| FinOps / Custo | Paulo Feitosa Lima | 31/03/2026 | ✅ ZERO CUSTO CONFIRMADO |

---

## 12. DECLARAÇÃO DE ENCERRAMENTO

Declaro que o projeto **PRJ015 — IGA Híbrido Local (AD → Entra Cloud Sync)** foi concluído com todos os critérios de sucesso atendidos. A sincronização de identidades entre o Active Directory on-premises e o Microsoft Entra ID está operacional com 100 usuários, utilizando EmployeeID como âncora imutável.

O ambiente encontra-se pronto para a próxima fase: **PRJ016 — midPoint como motor IGA On-Premise**.

---

**FIM DO TEP-PRJ015 v1.0**

---

*Documento mantido por Paulo Feitosa Lima — Living Lab Fiqueok*  
*Próxima revisão: Não aplicável (projeto encerrado)*
