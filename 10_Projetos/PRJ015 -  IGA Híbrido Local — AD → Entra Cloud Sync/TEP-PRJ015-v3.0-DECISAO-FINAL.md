# TERMO DE ENCERRAMENTO DO PROJETO — PRJ015

| Campo | Valor |
|-------|-------|
| **Código** | TEP-PRJ015 |
| **Versão** | 3.0 (Decisão Final) |
| **Data** | 01/04/2026 |
| **Responsável** | Paulo Feitosa Lima — GRC Lead / Especialista IAM |
| **Projeto** | PRJ015 — IGA Híbrido Local (AD → Entra Cloud Sync) |
| **Status Final** | ⚠️ ENCERRADO COM APRENDIZADO — Sincronização não alcançada por falha arquitetural; tenant mantido com limpeza parcial; decisão de exclusão total postergada |
| **Classificação** | Confidencial Interno — Lab Fiqueok |

---

## 1. CHANGELOG

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 31/03/2026 | Paulo Feitosa Lima | Criação inicial — registrou critérios de sucesso prematuros |
| 2.0 | 01/04/2026 | Paulo Feitosa Lima | Revisão com realidade, causa raiz, lições aprendidas e decisão de reinício via novo tenant |
| 3.0 | 01/04/2026 | Paulo Feitosa Lima | Revisão da decisão: tenant mantido após análise de trade-offs; limpeza parcial executada; exclusão total postergada |

---

## 2. EXECUÇÃO DO PROJETO — REALIDADE

### 2.1. Resumo Executivo

O projeto foi executado entre **30/03/2026 e 01/04/2026**, com duração total de **3 dias**.

A execução enfrentou desafios técnicos significativos, mas o principal obstáculo foi de natureza **arquitetural**: a tentativa de sincronizar um AD on-premises com um Entra ID que já continha os mesmos usuários criados previamente (cloud-first) revelou um conflito estrutural que não pôde ser resolvido com ferramentas de sync.

A decisão inicial (v2.0) era recriar o tenant do zero. Após análise de trade-offs, essa decisão foi **revisada**: o tenant será mantido, com limpeza parcial já executada, e a exclusão total fica como opção futura condicionada à conclusão de um inventário de dependências.

> **Nota sobre suporte externo:** As ferramentas de IA utilizadas como suporte técnico ao longo da execução focaram em resolução de sintomas sem identificar a falha arquitetural subjacente. Essa abordagem reativa contribuiu para o agravamento do estado do tenant. A L33 documenta essa lição formalmente.

### 2.2. Fases Executadas

| Fase | Atividade | Duração Real | Status |
|------|-----------|--------------|--------|
| F0 | Validação do AD | 1h | ✅ |
| F1 | Criação VM SYNC-01 | 1h | ✅ |
| F2 | Instalação Cloud Sync Agent | 2h | ✅ |
| F3 | Configuração sincronização | 3h | ✅ |
| F4 | Tentativas de validação / diagnóstico | 8h | ❌ FALHOU |
| F5 | Análise de causa raiz | 2h | ✅ |
| F6 | Limpeza parcial do tenant (99 usuários cloud-only) | 1h | ✅ |
| F7 | Análise de trade-offs para decisão de tenant | 1h | ✅ |
| F8 | Documentação de lições e encerramento | 2h | ✅ |

---

## 3. O QUE DEU ERRADO — CAUSA RAIZ

### 3.1. Cenário Original

| Componente | Estado |
|------------|--------|
| **AD** | 100 usuários com EmployeeID, UPN, mail preenchidos |
| **Entra ID** | 100 usuários com os mesmos UPNs, criados anteriormente (cloud-only) |
| **Objetivo** | Sincronizar AD → Entra mantendo os objetos existentes |

### 3.2. Problemas Enfrentados

| Problema | Impacto |
|----------|---------|
| Conflito de proxyAddresses | Objetos duplicados no Entra impediam o soft-match |
| OnPremisesImmutableId residual | Bloqueava o hard-match |
| Objetos "zumbis" na lixeira | Continuavam indexados, causando conflitos invisíveis |
| Soft-match falhou sistematicamente | O Entra ID não vinculou os objetos do AD aos existentes |

### 3.3. Causa Raiz

**O Entra ID não foi projetado para "começar cloud-only e depois decidir sincronizar".**

O modelo híbrido saudável exige que a **fonte de verdade seja definida antes da criação dos objetos**. Quando os objetos já existem em ambos os lados sem um vínculo claro, a reconciliação via Cloud Sync se torna inviável — especialmente quando há objetos na lixeira ou atributos residuais.

> **Princípio violado:** Single Source of Truth (SSoT). Ao popular o Entra ID diretamente antes de qualquer plano de sincronização, criou-se uma segunda fonte autoritativa paralela ao AD. Qualquer tentativa de sync nessas condições resulta em duplicação ou conflito — não por falha técnica, mas por falha de arquitetura de identidade.

---

## 4. DECISÃO DE ENCERRAMENTO — ANÁLISE DE TRADE-OFFS

### 4.1. Opções Avaliadas

| Opção | Viabilidade | Risco | Status |
|-------|-------------|-------|--------|
| A — Continuar tentando limpar e sincronizar | Baixa | Alto | ❌ Descartada |
| B — Excluir tenant e recriar do zero | Alta (técnica) | Médio (dependências) | ⏸️ Postergada |
| C — Manter tenant, limpeza parcial, recomeço sync-first no mesmo tenant | Alta | Baixo | ✅ **Adotada** |

### 4.2. Motivos para Não Excluir o Tenant (revisão da v2.0)

| Motivo | Detalhe |
|--------|---------|
| **Azure Workspace Analytics** | Contém dados de estudos que não podem ser descartados |
| **Contas de serviço preservadas** | `laszlo.bock@fiqueok.com.br`, `sso-teste@fiqueok.com.br` e contas `.onmicrosoft.com` vinculadas a projetos anteriores (ex: integração midPoint, PRJ009 Tailscale, PRJ007 Vault) |
| **Dependências não mapeadas** | Inventário completo do tenant ainda não foi executado — podem existir recursos, subscriptions, enterprise apps ou configurações que impedem exclusão segura |
| **Custo de recriar** | Não é zero: domínio customizado, MFA, App Registrations e integrações de projetos anteriores precisariam ser recriados |

### 4.3. Decisão Final

**Manter o tenant `fiqueok.com.br` / `paulofiqueokcom.onmicrosoft.com`.**

Ações executadas como limpeza parcial:
- 99 usuários cloud-only (`@fiqueok.com.br`) removidos e purgados via PowerShell + Graph API
- Usuários preservados: `fiqueok@fiqueok.com.br`, `laszlo.bock@fiqueok.com.br`, `sso-teste@fiqueok.com.br` e contas de serviço `.onmicrosoft.com`

Próxima etapa para sync-first: ligar o Cloud Sync com o tenant limpo, deixando o AD provisionar os 100 usuários diretamente no Entra agora vazio de conflitos.

---

## 5. LIMPEZA EXECUTADA — EVIDÊNCIAS

### 5.1. Script de Remoção Executado

```powershell
# Usuários preservados
$preserve = @(
    "fiqueok@fiqueok.com.br",
    "laszlo.bock@fiqueok.com.br",
    "sso-teste@fiqueok.com.br"
)

# Listar todos os cloud-only @fiqueok.com.br
$allCloudOnly = az ad user list --query "[?contains(userPrincipalName, '@fiqueok.com.br') && onPremisesSyncEnabled == null].{UPN:userPrincipalName, ID:id}" | ConvertFrom-Json

# Filtrar removendo os preservados
$toRemove = $allCloudOnly | Where-Object { $_.UPN -notin $preserve }

# Remover: soft-delete + purge imediato
foreach ($u in $toRemove) {
    az ad user delete --id $u.ID
    Start-Sleep -Seconds 2
    az rest --method DELETE --url "https://graph.microsoft.com/v1.0/directory/deletedItems/$($u.ID)"
}
```

### 5.2. Resultado

| Item | Valor |
|------|-------|
| Usuários identificados para remoção | 99 |
| Usuários removidos (soft-delete + purge) | 99 |
| Usuários preservados | 3 (`fiqueok`, `laszlo.bock`, `sso-teste`) |
| Contas de serviço preservadas (`.onmicrosoft.com`) | `ADToAADSyncServiceAccount`, `core-vlt-prj009-01`, `paulo.feitosa`, `svc_midpoint`, `st-paulo-prj009`, `laszlo.bock@paulofiqueokcom`, `paulo_fiqueok#EXT#` |

---

## 6. PENDÊNCIA CRÍTICA — INVENTÁRIO PARA FUTURA EXCLUSÃO DO TENANT

Caso a decisão de excluir o tenant seja retomada no futuro, o seguinte inventário **deve ser executado e analisado antes de qualquer ação**.

### 6.1. Checklist de Pré-Exclusão de Tenant

| # | Item | Por que bloqueia exclusão | Status |
|---|------|--------------------------|--------|
| 1 | Assinaturas Azure ativas | Qualquer subscription impede exclusão | ⚠️ Não verificado |
| 2 | Licenças pagas ou trials ativas | Precisam ser canceladas antes | ⚠️ Não verificado |
| 3 | Billing account associada | Precisa ser desvinculada | ⚠️ Não verificado |
| 4 | Domínio customizado `fiqueok.com.br` removido | Domínio precisa ser liberado para uso no novo tenant | ⚠️ Não verificado |
| 5 | Todos os usuários removidos (exceto 1 Global Admin) | Tenant só aceita exclusão com 1 usuário | ✅ Parcialmente feito (99 removidos) |
| 6 | Objetos deletados purgados (lixeira vazia) | Objetos na lixeira podem manter namespace poluído | ✅ Purgados junto com remoção |
| 7 | Todos os grupos excluídos | Impedem exclusão | ⚠️ Não verificado |
| 8 | App Registrations excluídos | Impedem exclusão | ⚠️ Não verificado |
| 9 | Enterprise Apps removidos | Alguns impedem exclusão | ⚠️ Não verificado |
| 10 | Conditional Access Policies removidas | Impedem exclusão | ⚠️ Não verificado |
| 11 | Dispositivos removidos | Impedem exclusão | ⚠️ Não verificado |
| 12 | Administrative Units removidas | Impedem exclusão | ⚠️ Não verificado |
| 13 | Roles customizadas removidas | Impedem exclusão | ⚠️ Não verificado |
| 14 | Azure Workspace Analytics exportado | Dados de estudo não podem ser perdidos | ⚠️ Pendente exportação |
| 15 | Logs exportados (Sign-in, Audit, Provisioning) | Evidências de auditoria | ⚠️ Pendente exportação |

### 6.2. Script de Inventário Completo (a executar antes de qualquer exclusão futura)

```powershell
# Pré-requisito: instalar e conectar Microsoft Graph
Install-Module Microsoft.Graph -Scope CurrentUser
Import-Module Microsoft.Graph
Connect-MgGraph -Scopes "Directory.Read.All","AuditLog.Read.All","Policy.Read.All",`
    "User.Read.All","Group.Read.All","Application.Read.All","Domain.Read.All",`
    "Device.Read.All","RoleManagement.Read.All"

Write-Host "=== INVENTÁRIO COMPLETO DO TENANT ===" -ForegroundColor Cyan

Write-Host "`n--- DOMÍNIOS CUSTOMIZADOS ---"
Get-MgDomain | Select-Object Id, IsVerified, IsDefault

Write-Host "`n--- USUÁRIOS ATIVOS ---"
Get-MgUser -All | Select-Object Id, UserPrincipalName, AccountEnabled

Write-Host "`n--- USUÁRIOS DELETADOS (LIXEIRA) ---"
Get-MgDirectoryDeletedItem -All | Where-Object {
    $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.user'
} | Select-Object Id, AdditionalProperties

Write-Host "`n--- GRUPOS ---"
Get-MgGroup -All | Select-Object Id, DisplayName, GroupTypes

Write-Host "`n--- GRUPOS DELETADOS ---"
Get-MgDirectoryDeletedItem -All | Where-Object {
    $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.group'
} | Select-Object Id, AdditionalProperties

Write-Host "`n--- APP REGISTRATIONS ---"
Get-MgApplication -All | Select-Object Id, DisplayName

Write-Host "`n--- ENTERPRISE APPS (SERVICE PRINCIPALS) ---"
Get-MgServicePrincipal -All | Select-Object Id, DisplayName, AppId

Write-Host "`n--- CONDITIONAL ACCESS POLICIES ---"
Get-MgIdentityConditionalAccessPolicy -All | Select-Object Id, DisplayName, State

Write-Host "`n--- DISPOSITIVOS ---"
Get-MgDevice -All | Select-Object Id, DisplayName, DeviceId

Write-Host "`n--- ADMINISTRATIVE UNITS ---"
Get-MgAdministrativeUnit -All | Select-Object Id, DisplayName

Write-Host "`n--- LICENÇAS DO TENANT ---"
Get-MgSubscribedSku | Select-Object SkuId, SkuPartNumber, ConsumedUnits, PrepaidUnits

Write-Host "`n--- ROLES CUSTOMIZADAS ---"
Get-MgRoleManagementDirectoryRoleDefinition -All |
    Where-Object { $_.IsBuiltIn -eq $false } |
    Select-Object Id, DisplayName

Write-Host "`n--- SUBSCRIPTIONS AZURE ---"
try {
    Get-AzSubscription | Select-Object Id, Name, State
} catch {
    Write-Host "Módulo Az não instalado ou sem permissões. Verificar manualmente no portal."
}

Write-Host "`n=== FIM DO INVENTÁRIO ===" -ForegroundColor Cyan
```

### 6.3. Contas de Serviço a Avaliar Antes de Excluir

| Conta | Projeto Vinculado | Ação Necessária |
|-------|-------------------|-----------------|
| `ADToAADSyncServiceAccount@paulofiqueokcom.onmicrosoft.com` | Cloud Sync Agent | Desinstalar agente antes de excluir |
| `core-vlt-prj009-01@paulofiqueokcom.onmicrosoft.com` | PRJ009 — Tailscale / Vault | Verificar dependência ativa |
| `st-paulo-prj009@paulofiqueokcom.onmicrosoft.com` | PRJ009 | Verificar dependência ativa |
| `svc_midpoint@paulofiqueokcom.onmicrosoft.com` | PRJ012 — midPoint / App Registration | Verificar App Registration vinculado |
| `laszlo.bock@paulofiqueokcom.onmicrosoft.com` | Conta de teste de federação | Avaliar se pode ser removida |
| `paulo.feitosa@paulofiqueokcom.onmicrosoft.com` | Global Admin principal | Último a ser removido; só após todos os outros |
| `paulo_fiqueok.com.br#EXT#@paulofiqueokcom.onmicrosoft.com` | Guest / conta externa | Verificar uso |

---

## 7. LIÇÕES APRENDIDAS (ATIVO PERMANENTE)

| ID | Lição | Origem | Aplicação Futura |
|----|-------|--------|------------------|
| L27 | Defina a fonte de verdade antes de criar qualquer usuário | PRJ015 | Em qualquer projeto IAM híbrido, definir se a fonte será AD (sync-first) ou Entra (cloud-first) antes da primeira criação |
| L28 | Nunca crie usuários no Entra que serão sincronizados depois | PRJ015 | Sync-first: AD cria → Entra espelha. Cloud-first: Entra cria → AD não existe ou é periférico |
| L29 | Objetos deletados (soft-delete) continuam ocupando namespace | PRJ015 | Purgue objetos permanentemente quando houver conflito de proxyAddresses |
| L30 | O Graph Explorer e o portal Entra enxergam menos que o backend | PRJ015 | Para limpeza profunda, usar `az rest` ou Graph API direta; objetos zumbis podem ser invisíveis ao portal mas ativos para o Cloud Sync |
| L31 | O Provision on Demand é o melhor teste, mas não é suficiente | PRJ015 | Falha no piloto indica problema estrutural, não pontual |
| L32 | Deletar e recriar não é fraqueza — é decisão estratégica | PRJ015 | Quando custo de limpeza supera benefício, recriar é a escolha certa |
| L33 | Ferramentas de IA resolvem sintomas, não causas | PRJ015 | Antes de seguir qualquer orientação técnica de IA, validar se a causa raiz foi identificada; orientações reativas podem agravar o problema |
| L34 | Decisão de excluir tenant exige inventário completo antes | PRJ015 | Nunca excluir tenant sem mapear todas as dependências: contas de serviço, apps, analytics, licenças e projetos vinculados |
| L35 | Trade-offs de dependências podem mudar decisões já tomadas | PRJ015 | Decisões de infraestrutura devem ser revisadas quando novas dependências são identificadas — mudar é governança, não inconsistência |

---

## 8. ENTREGÁVEIS REALIZADOS

| ID | Entregável | Status | Observação |
|----|------------|--------|------------|
| E1 | Relatório de validação do AD | ✅ | 100 usuários com EmployeeID único confirmados |
| E2 | VM SYNC-01 criada e operacional | ✅ | GEN2, disco diferencial, Cloud Sync Agent instalado |
| E3 | Evidências de instalação do Cloud Sync | ✅ | Screenshots e logs coletados |
| E4 | Evidências das tentativas de sincronização | ✅ | Erros, conflitos e diagnósticos — valor de auditoria |
| E5 | Diagnóstico de causa raiz | ✅ | Documentado neste TEP, seção 3 |
| E6 | Limpeza parcial do tenant (99 usuários purgados) | ✅ | Script executado com sucesso, evidenciado no TEP |
| E7 | Lições aprendidas documentadas (L27–L35) | ✅ | Documentado neste TEP, seção 7 |
| E8 | Checklist de pré-exclusão de tenant | ✅ | Documentado neste TEP, seção 6.1 |
| E9 | Script de inventário completo do tenant | ✅ | Documentado neste TEP, seção 6.2 |
| E10 | POP-IAM-005 (sync-first) | 📋 Pendente | A ser criado após validação do sync com tenant limpo |

---

## 9. PRÓXIMOS PASSOS

### 9.1. Imediato — Continuar PRJ015 com tenant limpo

| Etapa | Ação | Pré-condição |
|-------|------|--------------|
| 1 | Validar estado atual do tenant (usuários remanescentes, lixeira) | Limpeza já executada |
| 2 | Validar SYNC-01 e Cloud Sync Agent ainda operacionais | VM criada em F1/F2 |
| 3 | Ligar sincronização AD → Entra com tenant limpo | Nenhum usuário `@fiqueok.com.br` no Entra |
| 4 | Validar 100 usuários provisionados pelo AD | EmployeeID como âncora |
| 5 | Documentar POP-IAM-005 com fluxo sync-first | Após validação bem-sucedida |

### 9.2. Futuro — Se decisão de excluir o tenant for retomada

| Etapa | Ação |
|-------|------|
| 1 | Executar script de inventário completo (seção 6.2) |
| 2 | Exportar Azure Workspace Analytics |
| 3 | Exportar logs de Sign-in, Audit e Provisioning |
| 4 | Avaliar e remover dependências de PRJ007, PRJ009, PRJ012 |
| 5 | Seguir checklist de pré-exclusão completo (seção 6.1) |
| 6 | Executar exclusão do tenant |
| 7 | Recriar tenant limpo com sync-first desde o início |

---

## 10. APROVAÇÕES

| Função | Nome | Data | Status |
|--------|------|------|:------:|
| GRC Lead / Responsável Técnico | Paulo Feitosa Lima | 01/04/2026 | ✅ APROVADO |
| GRC Advisor | DeepSeek | 01/04/2026 | ✅ REVISADO |
| FinOps / Custo | Paulo Feitosa Lima | 01/04/2026 | ✅ ZERO CUSTO |

---

## 11. DECLARAÇÃO DE ENCERRAMENTO

Declaro que o projeto **PRJ015 — IGA Híbrido Local (AD → Entra Cloud Sync)** não atingiu o objetivo operacional original, mas gerou valor estratégico permanente e documentado:

- Identificou os limites do modelo híbrido com criação prévia de objetos no Entra ID
- Validou na prática o princípio de **Single Source of Truth** como pré-requisito de qualquer integração de identidade
- Executou limpeza parcial do tenant (99 usuários cloud-only removidos e purgados), preparando o ambiente para recomeço com modelo sync-first
- Documentou checklist e script de inventário para futura exclusão segura do tenant, caso essa decisão seja retomada
- Consolidou lições (L27–L35) aplicáveis a cenários reais de empresas em migração para Microsoft 365

O projeto é encerrado com o **tenant mantido, limpo parcialmente e pronto para nova tentativa de sincronização com arquitetura correta**. A decisão de excluir o tenant permanece em aberto, condicionada à execução do inventário completo documentado neste TEP.

O ambiente evolui para o **PRJ016 — midPoint como motor IGA On-Premise**, que sucede este projeto com a identidade saneada.

---

**FIM DO TEP-PRJ015 v3.0**

---

*Documento mantido por Paulo Feitosa Lima — Living Lab Fiqueok*
*Próxima revisão: Após validação do sync-first com tenant limpo*
