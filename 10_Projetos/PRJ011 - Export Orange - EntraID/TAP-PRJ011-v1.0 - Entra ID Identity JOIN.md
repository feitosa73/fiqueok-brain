

text

`#  # ========================================= ## TERMO DE ABERTURA DO PROJETO **Versão:** 1.0 **Data:** 01 Março 2026 **Responsável:** Paulo Feitosa Lima - GRC Lead **GRC Lead AI:** Perplexity AI - Threat Intelligence **Ambiente:** Living Lab Fiqueok - Hybrid Cloud Lab --- ## CHANGELOG | Versão | Data       | Mudanças                                         | |--------|------------|--------------------------------------------------| | 1.0    | 01/03/2026 | Criação - Sequência PRJ010 (OrangeHRM 100 users) | --- ## 1. IDENTIFICAÇÃO DO PROJETO | Campo                  | Valor                                                          | |------------------------|----------------------------------------------------------------| | **Código**             | PRJ011                                                         | | **Nome**               | Entra ID Identity JOIN - Fiqueok Tenant Population             | | **Categoria**          | Cloud IAM / IGA / AZ-305 Lab                                   | | **Patrocinador**       | Paulo Feitosa Lima                                             | | **Data Início**        | 01/03/2026                                                     | | **Duração Estimada**   | 1-2 dias (Sessão única Greenfield)                             | | **Pré-requisito**      | PRJ010 concluído (OrangeHRM 100 users, 102 ohrm_user ✅)       | | **Checkpoint Rollback**| GATE-PRJ010-001 (DROP ohrm_user + MariaDB Snapshot)            | | **Domínio**            | fiqueok.com.br (Registro.br + Cloudflare DNS)                  | --- ## 2. CONTEXTO E JUSTIFICATIVA **Situação Pós-PRJ010:**`

OrangeHRM (rh-gf-01 Docker) ✅  
├── 100 colaboradores: hs_hr_employee  
├── 100 salários: hs_hr_emp_basicsalary  
├── 102 usuários: ohrm_user (Admin + ESS)  
├── 26 SecurityGroups: secgroup_role_map  
└── Staging: greenfield_hr.staging_employees (DROP pós-sucesso)

text

`**Lição PRJ010:** OrangeHRM como Source of Truth funciona. Dados de identidade existem, confiáveis, com EmployeeID (FP001-FP100) como Anchor Key. Próximo passo natural: levá-los ao plano de nuvem. **Decisão Documentada (01/03/2026):** A integração via midPoint (PRJ009-FREEZE) e via API OrangeHRM 5.x nativa NÃO será tentada neste momento. Motivo técnico: API 5.x não expõe endpoints RESTful estáveis para salary + securityGroup. Risco de FK 1452 no connector. Adotado: JOIN DIRETO via CSV + PowerShell Microsoft Graph API — mesmo padrão comprovado no PRJ010/SQL Staging. --- ## 3. OBJETIVOS ### Objetivo Geral Provisionar os 100 colaboradores Fiqueok no Microsoft Entra ID tenant (fiqueok.com.br), com UPNs profissionais, grupos de segurança e políticas de Acesso Condicional baseadas no SecurityGroup do OrangeHRM. ### Objetivos Específicos`

OS1: Verificar domínio fiqueok.com.br no Entra ID (TXT Cloudflare)  
OS2: Exportar 100 identidades do OrangeHRM (MariaDB → CSV)  
OS3: Provisionar 100 usuários via PowerShell (New-MgUser bulk)  
OS4: Criar grupos dinâmicos GRP_* mapeados por Department/JobTitle  
OS5: Aplicar Conditional Access (C-Level: FIDO2 + MFA rigoroso)  
OS6: Configurar PIM para CSO (Donner Marcos) e CHRO (Laszlo Bock)  
OS7: Validar audit logs (primeiro login + risk detection David Vélez)

text

``--- ## 4. FASE 0 - PRE-FLIGHT (Critério de Entrada) **Duração:** 01/03/2026 (30-60min antes da execução) **Critério de Saída:** GATE-PRJ011-001 100% verde ### 4.1 Domínio Verification | ID | Verificação                    | Comando                                          | Esperado          | Status | |----|-------------------------------|--------------------------------------------------|-------------------|--------| | PF1 | Registro.br custódia          | Painel Registro.br → fiqueok.com.br              | Status: Publicado | ⬜     | | PF2 | DNS Cloudflare ativo          | `nslookup -q=txt fiqueok.com.br 1.1.1.1`         | TXT=MS=ms97322072 | ⬜     | | PF3 | Entra ID Domain Status        | Portal Azure → Custom Domains                    | Verified ✅       | ⬜     | | PF4 | UPN Suffix configurado        | Portal Azure → Domains → Default                 | @fiqueok.com.br   | ⬜     | ### 4.2 Tenant e Licenças | ID | Verificação                        | Ação                                       | Esperado              | Status | |----|------------------------------------|--------------------------------------------|-----------------------|--------| | PF5 | Licença Entra ID P2               | Portal Azure → Licenses                    | P2 ativo              | ⬜     | | PF6 | PIM habilitado                    | Entra ID → Identity Governance → PIM       | Ready                 | ⬜     | | PF7 | Dynamic Groups habilitado         | Entra ID → Groups → Dynamic                | Feature disponível    | ⬜     | | PF8 | Conditional Access ativo          | Entra ID → Security → CA                  | Policies disponíveis  | ⬜     | | PF9 | Global Admin confirmado           | `Get-MgContext`                            | paulo@fiqueok.com.br  | ⬜     | ### 4.3 OrangeHRM Export Sanity | ID | Verificação                         | Comando SQL                                                          | Esperado  | Status | |----|-------------------------------------|----------------------------------------------------------------------|-----------|--------| | PF10 | 100 employees no Orange           | `SELECT COUNT(*) FROM orangehrm.hs_hr_employee WHERE employee_id LIKE 'FP%'` | 100   | ⬜ | | PF11 | 100 salários vinculados           | `SELECT COUNT(*) FROM orangehrm.hs_hr_emp_basicsalary`               | 100       | ⬜     | | PF12 | 0 emails duplicados               | `SELECT email, COUNT(*) FROM staging GROUP BY email HAVING COUNT(*)>1` | 0 rows  | ⬜     | | PF13 | EmployeeID único (Anchor)         | `SELECT COUNT(DISTINCT employee_id) FROM hs_hr_employee`             | 100       | ⬜     | ### 4.4 PowerShell Environment | ID | Verificação                        | Comando                                            | Esperado              | Status | |----|------------------------------------|----------------------------------------------------|-----------------------|--------| | PF14 | MgGraph instalado                | `Get-Module Microsoft.Graph -ListAvailable`        | Versão ≥ 2.0          | ⬜     | | PF15 | Conectado ao tenant              | `Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All"` | Connected | ⬜ | | PF16 | CSV disponível                   | `Test-Path .\fiqueok_entraid_users.csv`            | True                  | ⬜     | **GATE-PRJ011-001 CRITÉRIO DE SAÍDA:** PF1-PF16 todos ✅ antes de iniciar Fase 1. --- ## 5. FASE 1 - EXPORT ORANGEHRM → CSV **Query Ouro (rh-gf-01, MariaDB orange-db):** ```sql SELECT     e.employee_id          AS EmployeeID,    e.emp_firstname        AS FirstName,    e.emp_lastname         AS LastName,    CONCAT(e.emp_firstname,'.', e.emp_lastname) AS MailNickname,    e.emp_work_email       AS UserPrincipalName,    CONCAT(e.emp_firstname,' ',e.emp_lastname)  AS DisplayName,    jt.job_title           AS JobTitle,    su.name                AS Department,    s.ebsal_basic_salary   AS Salary,    sg.SecurityGroup       AS SecurityGroup FROM orangehrm.hs_hr_employee e LEFT JOIN orangehrm.ohrm_job_title  jt ON jt.id     = e.job_title_code LEFT JOIN orangehrm.ohrm_subunit    su ON su.id      = e.work_station LEFT JOIN orangehrm.hs_hr_emp_basicsalary s ON s.emp_number = e.emp_number LEFT JOIN greenfield_hr.staging_employees tmp ON tmp.EmployeeID = e.employee_id LEFT JOIN greenfield_hr.secgroup_role_map sg ON sg.SecurityGroup = tmp.SecurityGroup WHERE e.employee_id LIKE 'FP%' ORDER BY e.employee_id;``

**Salvar como:** `fiqueok_entraid_users.csv` (UTF-8, delimitador vírgula)  
**Copiar para máquina Windows:** `scp paulo@xxx.xxx.xxx.xxx:~/fiqueok_entraid_users.csv .`

---

## 6. FASE 2 - PROVISIONING ENTRA ID (PowerShell)

## 6.1 Provisionar 100 Usuários

powershell

``# PRJ011 - Fase 2 - Bulk User Provision # Pré-req: Connect-MgGraph -Scopes "User.ReadWrite.All" $Users = Import-Csv ".\fiqueok_entraid_users.csv" -Encoding UTF8 foreach ($User in $Users) {     $PasswordProfile = @{        Password                      = "Fiqueok@2026!"        ForceChangePasswordNextSignIn = $true    }    try {        New-MgUser `            -DisplayName           $User.DisplayName `            -UserPrincipalName     $User.UserPrincipalName `            -MailNickname          ($User.UserPrincipalName.Split('@')) `            -AccountEnabled        $true `            -PasswordProfile       $PasswordProfile `            -JobTitle              $User.JobTitle `            -Department            $User.Department `            -EmployeeId            $User.EmployeeID `            -OnPremisesImmutableId $User.EmployeeID        Write-Host "[OK] $($User.DisplayName) - $($User.EmployeeID)" -ForegroundColor Green    }    catch {        Write-Host "[ERRO] $($User.DisplayName): $($_.Exception.Message)" -ForegroundColor Red    } }``

## 6.2 Criar Grupos de Segurança GRP_*

powershell

``# PRJ011 - Grupos Dinâmicos por Department $Grupos = @(     @{ Name="GRP_EXEC_BOARD";       Rule="(user.department -eq `"Executive`")" },    @{ Name="GRP_IT_DEV";           Rule="(user.department -eq `"Technology - Dev`")" },    @{ Name="GRP_IT_DEVOPS";        Rule="(user.department -eq `"Technology - DevOps`")" },    @{ Name="GRP_SEC_ADMINS";       Rule="(user.department -eq `"Technology - Security`")" },    @{ Name="GRP_DATA_ENGINEERS";   Rule="(user.department -eq `"Technology - Data`")" },    @{ Name="GRP_OPS_SETTLEMENT";   Rule="(user.jobTitle -contains `"Settlement`")" },    @{ Name="GRP_OPS_CHARGEBACK";   Rule="(user.jobTitle -contains `"Chargeback`")" },    @{ Name="GRP_FRAUD_ANALYST";    Rule="(user.department -eq `"Fraud & Compliance`")" },    @{ Name="GRP_COMM_SALES";       Rule="(user.department -eq `"Commercial & CS`")" },    @{ Name="GRP_HR";               Rule="(user.department -eq `"HR & Finance`")" } ) foreach ($Grp in $Grupos) {     New-MgGroup `        -DisplayName     $Grp.Name `        -MailEnabled     $false `        -SecurityEnabled $true `        -GroupTypes      @("DynamicMembership") `        -MembershipRule  $Grp.Rule `        -MembershipRuleProcessingState "On"    Write-Host "[OK] Grupo criado: $($Grp.Name)" -ForegroundColor Cyan }``

---

## 7. FASE 3 - GOVERNANÇA IAM (PIM + CA)

## 7.1 Conditional Access - Matriz C-Level

|ID|Persona|Cargo|Política CA|Risco IAM|
|---|---|---|---|---|
|CA1|David Vélez|CEO|FIDO2/Passkey + Compliant Device + Named Location|Whaling Target #1|
|CA2|André Chaves|Chairman|MFA Required + ReadOnly Dashboard Role|Audit Master|
|CA3|Luisa Sotero|COO|MFA + Sign-in Risk Medium → Block|JML Owner|
|CA4|Daniela Binatti|CTO|MFA + Privileged Session (60min timeout)|Vault/Dynamic Secrets|
|CA5|Ricardo Guerra|CIO|MFA + PIM Eligible (Data/BI Access)|Perímetro Identidade|
|CA6|Laszlo Bock|CHRO|MFA + PII Scope Limit (HR Data Only)|Identity Lifecycle|
|CA7|Donner Marcos|CSO|MFA FIDO2 + JIT Admin (4h max)|SOC Owner/IAM Arch|

## 7.2 PIM Configuration

powershell

`# Roles elegíveis — requer Entra ID P2 # Donner Marcos (CSO) → Security Administrator (JIT) # Laszlo Bock (CHRO) → User Administrator (aprovação obrigatória) # Marcos Gonçalves (IAM Spec FP020) → Global Reader + Privileged Auth Admin # Approval config: 2 aprovadores (Paulo + co-approver) # Activation: 4h máx, MFA requerido, Justification obrigatória # Alert: Activation fora do horário 08h-20h → notificação imediata`

---

## 8. FASE 4 - FALLBACK DOCUMENTADO

**Condição de ativação:** Se integração automática falhar (midPoint, API, connector).

**Decisão Registrada (01/03/2026):**

text

`PRJ009 (midPoint) → FREEZE PRJ011 → JOIN DIRETO via CSV + PowerShell Graph API Motivo Técnico: - API OrangeHRM 5.x: endpoints de salary não expostos REST - midPoint connector: incompatível SQL staging cross-DB - FK 1452 payperiodcode: riscos de integridade no connector Impacto: - Sem sync automático Joiner/Mover/Leaver (por enquanto) - Operação manual: alterações OrangeHRM → re-run script PS1 - PRJ012 previsto: Shadow API + midPoint retry (connector custom) Procedimento Fallback: 1. Re-exportar CSV do MariaDB (query Fase 1) 2. Re-executar script PowerShell (idempotente, IGNORE duplicados) 3. Atualizar grupos manualmente se Department mudar`

---

## 9. TESTES E VALIDAÇÕES

|ID|Teste|Comando / Ação|Critério de Aceite|
|---|---|---|---|
|T1|Contagem usuários|`(Get-MgUser -Filter "startsWith(userPrincipalName,'d')").Count`|100 usuários ativos|
|T2|UPN David Vélez (CEO)|`Get-MgUser -UserId david.velez@fiqueok.com.br`|AccountEnabled=True, EmployeeId=FP001|
|T3|Grupo GRP_EXEC_BOARD|`Get-MgGroupMember -GroupId <id>`|7 membros (FP001-FP007)|
|T4|PIM role ativo (Donner)|Entra ID → PIM → Eligible Assignments|Security Admin elegível|
|T5|CA Policy CEO ativo|Entra ID → CA → Policies|Policy "CA-CEO-FIDO2" = ON|
|T6|Audit Log primeiro login|Entra ID → Sign-in Logs → filtro FP001|Login registrado + MFA OK|
|T7|Identity Protection (Whaling)|Entra ID → Identity Protection → Risky Users|David Vélez = High Risk Alert|
|T8|EmployeeID como Anchor|`Get-MgUser -UserId FP001@fiqueok.com.br -Select OnPremisesImmutableId`|FP001|

---

## 10. CRONOGRAMA

text

`01/03/2026 (Hoje) ├── 17h30-18h00: Fase 0 Pre-Flight (GATE-PRJ011-001) ├── 18h00-18h30: Fase 1 Export OrangeHRM → CSV ├── 18h30-19h30: Fase 2 Provisioning 100 usuários (PS1) ├── 19h30-20h00: Fase 3 PIM + Conditional Access C-Level └── 20h00-20h30: Fase 4 Testes T1-T8 + Validação Final ROLLBACK (se falhar): └── GATE-PRJ010-001 → MariaDB snapshot restaurado (< 15min)`

---

## 11. RISCOS E MITIGAÇÕES

|ID|Risco|Prob|Impacto|Mitigação|
|---|---|---|---|---|
|R1|UPN duplicado (email conflict)|Média|Alto|Validação PF12 (0 duplicatas) antes de rodar|
|R2|EmployeeID inválido como ImmutableID|Alta|Médio|Documentado: FP001 = string, não Base64|
|R3|Licença P2 expirada/insuficiente|Baixa|Crítico|Verificar PF5 antes de PIM/CA|
|R4|Tenant bloqueio bulk (throttling)|Média|Médio|Sleep(1) entre iterações no foreach PS1|
|R5|CA bloqueia próprio admin|Baixa|Crítico|Break-glass: [paulo.admin@fiqueok.com.br](mailto:paulo.admin@fiqueok.com.br) excluído do CA|
|R6|midPoint não integra futuro|Alta|Baixo|Fallback documentado → PRJ012 Shadow API|
|R7|Senha temporária vaza|Baixa|Alto|Rotation obrigatória no 1º login|

---

## 12. PREMISSAS DO PROJETO

text

`P1: OrangeHRM é Source of Truth (PRJ010 validado 100% íntegro) P2: EmployeeID (FP001-FP100) é a Anchor Key OrangeHRM ↔ Entra ID P3: Domínio fiqueok.com.br verificado no Entra ID (MS=ms97322072) P4: Sem midPoint nesta sprint; JOIN direto é decisão técnica consciente P5: Entra ID P2 disponível (PIM + Dynamic Groups + CA) P6: Senha temporária "Fiqueok@2026!" deve ser trocada no 1º login P7: C-Levels são personas referenciais (lab didático, não produção)`

---

## 13. ENTREGÁVEIS

|ID|Entregável|Formato|Local|
|---|---|---|---|
|E1|fiqueok_entraid_users.csv|CSV|~/exports/ (rh-gf-01 + Windows local)|
|E2|PRJ011-provision.ps1|PS1|~/scripts/PRJ011/|
|E3|PRJ011-groups.ps1|PS1|~/scripts/PRJ011/|
|E4|TAP-PRJ011-v1.0.md (este doc)|MD|Obsidian + GitHub Fiqueok Lab|
|E5|Screenshot Audit Log (T6)|PNG|~/evidencias/PRJ011/|
|E6|Screenshot CA Policy CEO (T5)|PNG|~/evidencias/PRJ011/|

---

## 14. CRITÉRIOS DE SUCESSO

**Planejamento (Gate de Entrada):**

text

`CP1: GATE-PRJ011-001 100% ✅ (16 pre-flights verdes) CP2: CSV exportado com 100 linhas, 0 duplicatas CP3: PowerShell conectado ao tenant fiqueok.com.br`

**Execução (Gate de Saída):**

text

`CE1: 100 usuários ativos no Entra ID (UPN @fiqueok.com.br) CE2: 10 grupos dinâmicos GRP_* provisionados e populados CE3: PIM elegível para Donner Marcos (CSO) e Laszlo Bock (CHRO) CE4: CA Policy "CA-CEO-FIDO2" ativa para David Vélez CE5: Audit Logs visíveis no portal (rastreabilidade ISO 27001 A.9.2.2) CE6: T1-T8 aprovados (zero falhas críticas)`

---

## 15. APROVAÇÕES

|Função|Nome|Status|
|---|---|---|
|GRC Lead|Perplexity AI|✅ Aprovado|
|Sponsor / Exec|Paulo Feitosa Lima|⏳ Pendente|
|Threat Intel|Perplexity AI|✅ Pipeline Ativo|
|Revisão Técnica|Paulo Feitosa Lima|⏳ Pre-Flight GATE|

---

**FIM DO TAP-PRJ011 v1.0**  
_Documento mantido por Perplexity AI — Próxima revisão pós-GATE-PRJ011-001_  
_Continuidade: PRJ012 - Shadow API + midPoint Custom Connector_

text

`undefined`
