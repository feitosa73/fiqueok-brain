**IDM-POL-001 v2.0**

**Política Corporativa de Governança de**

**Identidade e Acesso Multicloud**

Governança de Identidades e Acessos em Ambientes Híbridos Cloud-OnPrem

|                     |                                                                              |
|---------------------|------------------------------------------------------------------------------|
| **Identificador**   | **IDM-POL-001**                                                              |
| **Versao**          | 2.0 (Revisao e Expansao de GOV-IDM-v1.0)                                     |
| **Classificacao**   | **CONFIDENCIAL --- USO INTERNO**                                             |
| **Escopo**          | Qualquer organizacao com ambiente Azure / Hibrido / Multicloud               |
| **Publico-Alvo**    | CISO · IAM Architects · Internal Audit · DevSecOps · Compliance              |
| **Frameworks**      | ISO 27001:2022 · SOC 2 Type II · COBIT 2019 · NIST CSF 2.0 · CIS Controls v8 |
| **Idempotente**     | 100% --- Zero hardcodes. Aplicavel a qualquer Tenant / VM / DB / Stack       |
| **Organizacao**     | \[ORGANIZACAO\] \| \[DEPARTAMENTO_SEGURANCA\]                                |
| **Data Emissao**    | \[DATA_EMISSAO\]                                                             |
| **Proxima Revisao** | \[DATA_REVISAO\]                                                             |
| **Aprovado por**    | \[CISO_NOME\] \| \[CARGO\]                                                   |

Nota: Conceitos aplicaveis a qualquer infraestrutura hibrida Cloud-OnPrem. Ferramentas citadas sao exemplos --- nao obrigatorias.

**Sumario Executivo**

Este documento estabelece a Politica Corporativa de Governanca de Identidades e Acessos (IAM) para ambientes hibridos multicloud. Funciona como template 100% idempotente --- sem referencias a organizacoes, sistemas ou ferramentas especificas --- sendo aplicavel a qualquer empresa independentemente de seu tamanho, setor ou stack tecnologico.

O framework cobre o ciclo de vida completo de identidades humanas, de sistema e nao-humanas, integrando controles tecnicos, procedimentos operacionais e evidencias de auditoria alinhadas a ISO 27001:2022, SOC 2 Type II, COBIT 2019, NIST CSF 2.0 e CIS Controls v8.

**Escopo e Aplicabilidade**

- \[ORGANIZACAO\] --- Tenant ID: \[TENANT_ID\]

- Subscription(s): \[SUBSCRIPTION_ID_01\], \[SUBSCRIPTION_ID_N\]

- VMs Linux e Windows em Azure, on-premises ou qualquer provedor cloud

- Bancos de dados relacionais (MySQL/MariaDB/PostgreSQL/SQL Server) e nao-relacionais

- Redes overlay / VPN mesh (ex: \[Tailscale/WireGuard/Azure VPN Gateway\])

- Aplicacoes integradas ao provedor de identidade (IdP) corporativo

**Principios Fundamentais**

1.  **Zero Standing Privileges: nenhum acesso privilegiado permanente --- todo acesso elevado e JIT.**

2.  Least Privilege: cada identidade recebe apenas permissoes estritamente necessarias para sua funcao.

3.  Separacao de Funcoes (SoD): nenhuma pessoa detem, sozinha, controle sobre recursos criticos.

4.  Dupla Custodia: segredos de Tier CRITICO requerem dois custodiantes independentes.

5.  Auditabilidade Total: todo acesso privilegiado gera log imutavel e alertas automatizados.

6.  Zero Trust para SSH: autenticacao SSH centralizada no IdP --- sem chaves RSA locais em authorized_keys.

7.  Agnosticismo de Ferramentas: controles sao definidos por funcao, nao por produto especifico.

**Mapeamento Multi-Framework --- Visao Geral**

|                       |                    |                   |                |                  |
|-----------------------|--------------------|-------------------|----------------|------------------|
| **Dominio IAM**       | **ISO 27001:2022** | **SOC 2 Type II** | **COBIT 2019** | **NIST CSF 2.0** |
| Gestao de Identidades | A.5.15, A.5.16     | CC6.1, CC6.2      | APO13.01       | PR.AA-01         |
| Controle de Acesso    | A.5.18, A.8.2      | CC6.3, CC6.6      | DSS05.04       | PR.AA-05         |
| Privilegio & PAM      | A.8.18, A.5.17     | CC6.7, CC6.8      | APO13.02       | PR.AA-06         |
| Monitoramento & Audit | A.8.15, A.8.17     | CC7.2, CC7.3      | MEA01.03       | DE.CM-01         |
| Continuidade (DR/PCN) | A.5.29, A.8.14     | A1.2, A1.3        | DSS04.02       | RC.RP-01         |

**I · Politica Executiva de Governanca de Identidade**

**1.1 Statement Formal de Governanca**

\[ORGANIZACAO\] reconhece que identidades digitais sao o novo perimetro de seguranca. A presente politica estabelece controles mandatorios para o ciclo de vida de todas as identidades que interagem com recursos de tecnologia da organizacao, em conformidade com ISO 27001:2022, SOC 2 Type II e COBIT 2019.

Toda identidade --- humana ou nao-humana --- deve ser: (a) provisionada com privilegio minimo; (b) auditavel em tempo real; (c) revogada automaticamente ao termino do vinculo; (d) protegida por autenticacao forte quando aplicavel.

**1.2 SLA de Identidade --- Processo JML**

|            |                                             |                    |                 |               |                  |
|------------|---------------------------------------------|--------------------|-----------------|---------------|------------------|
| **Evento** | **Acao Mandatoria**                         | **SLA**            | **Responsavel** | **Sistema**   | **Evidencia**    |
| **JOINER** | Provisionar IdP + RBAC + MFA + JIT/PIM      | \<= 4h uteis       | \[IAM_TEAM\]    | \[ITSM_TOOL\] | Ticket + Log IdP |
| **MOVER**  | Remover roles anteriores + atribuir novos   | \<= 8h uteis       | \[IAM_TEAM\]    | \[ITSM_TOOL\] | Access Review    |
| **LEAVER** | Block IdP + Revogar SSH + Rotar PAM secrets | **\<= 15 MINUTOS** | \[IAM_TEAM\]+RH | \[SIEM_TOOL\] | Alert + Ticket   |

> **⚠ SLA de 15 minutos para LEAVER e requisito de conformidade ISO 27001 A.5.18. Violacoes devem ser registradas como Non-Conformity e reportadas ao CISO.**

**1.3 Matriz RACI Executiva**

|                             |          |              |           |               |         |           |
|-----------------------------|----------|--------------|-----------|---------------|---------|-----------|
| **Atividade**               | **CISO** | **IAM Team** | **Infra** | **RH/People** | **Dev** | **Audit** |
| Politica e Governanca IAM   | **A**    | R            | C         | C             | I       | I         |
| Provisionamento JML         | **A**    | **R**        | C         | R             | I       | I         |
| Break-Glass & Custodia      | **A**    | C            | I         | I             | I       | I         |
| Rotacao de Segredos         | I        | **A/R**      | R         | I             | C       | I         |
| Access Review Trimestral    | A        | R            | C         | I             | I       | **R**     |
| Hardening de Infraestrutura | A        | C            | **R**     | I             | C       | I         |
| Incident Response IAM       | A        | R            | R         | I             | C       | I         |

R = Responsible A = Accountable C = Consulted I = Informed

**II · Catalogo Completo de Identidades**

**2.1 Taxonomia e Classificacao de Risco**

Toda identidade e classificada em um Tier de criticidade que determina os controles mandatorios. Classificacao baseada em: impacto potencial de comprometimento, escopo de acesso e rastreabilidade.

|            |                             |                                         |               |         |               |                                  |                                           |
|------------|-----------------------------|-----------------------------------------|---------------|---------|---------------|----------------------------------|-------------------------------------------|
| **Tier**   | **Tipo**                    | **Exemplo**                             | **Proposito** | **MFA** | **Rotacao**   | **Custodia**                     | **Controles Mandatorios**                 |
| **P1       
 CRITICO**   | Humana Privilegiada         | **Global Admin Break-Glass**            | Emergencia    | Obrig.  | 90 dias       | **Dupla Custodia \[C1\]+\[C2\]** | SIEM Alert · HSM/KV · Teste 90d           |
| **P2       
 ALTO**      | Humana Operacional          | Subscription Owner                      | Operacional   | Obrig.  | 180 dias      | Individual + PIM JIT             | PIM JIT · CA Policy · Access Review       |
| **P3       
 MEDIO**     | Humana Tecnica              | VM Login · DBA User                     | Tecnico       | Obrig.  | 365 dias      | Individual                       | IdP SSO · RBAC · Log Analytics            |
| **P4       
 ALTO        
 Sistema**   | Sistema --- DB              | **DB Root / SA Account**                | Dados         | N/A     | 90 dias       | **PAM + \[KV_NAME\]**            | Sem login direto · Rotacao automatica     |
| **P5       
 MEDIO       
 Sistema**   | Sistema --- App             | Service Account · App Registration      | Aplicacoes    | N/A     | 30 dias       | \[KV_NAME\] (auto)               | Managed Identity preferida · Rotacao auto |
| **P6       
 BAIXO       
 Nao-Hum.**  | Nao-Humana Managed Identity | **\[VM_NAME\]-identity · Pod Identity** | Secretless    | N/A     | Ciclo recurso | Automatico (Cloud Provider)      | RBAC granular · Sem credenciais estaticas |

**2.2 Regras de Ouro --- Identidades Privilegiadas**

- **P1 (Break-Glass): NUNCA usar no dia a dia. Qualquer login dispara alerta P0 no SIEM.**

- P2 (Subscription Owner): Acesso sempre via JIT/PIM --- sem role permanente.

- DB Root: Senha em \[KV_NAME\] ou PAM (\[CyberArk/BeyondCorp/Key Vault\]). Sem login direto habitual.

- SSH: Somente via IdP corporativo --- arquivo authorized_keys proibido para humanos em producao.

- Managed Identity: Padrao para toda comunicacao VM-recurso Azure. Zero credenciais estaticas.

**2.3 Comparativo SSH --- RSA Local vs. IdP Centralizado**

|                          |                                              |                                            |
|--------------------------|----------------------------------------------|--------------------------------------------|
| **Criterio**             | **RSA Local (authorized_keys)**              | **IdP Centralizado (ex: Azure AD Login)**  |
| Revogacao JML            | Manual --- arquivo persiste apos demissao    | Automatica --- block IdP = sem acesso VM   |
| Auditoria                | Nenhuma --- authorized_keys sem log nativo   | Sign-in Logs + Monitor centralizado        |
| MFA                      | Impossivel nativamente                       | Obrigatorio via Conditional Access         |
| Portabilidade do Segredo | id_rsa copiavel para qualquer maquina        | Token efemero --- nao portavel             |
| Conformidade ISO/SOC2    | **NAO CONFORME --- CC6.2, A.9.4.2**          | **CONFORME --- A.5.15, CC6.1, CC6.2**      |
| Conta Orfa (Leaver)      | Alta probabilidade --- nenhum JML automatico | Zero --- vinculado ao ciclo de vida no IdP |

**III · Controles JML Automatizados**

**3.1 JOINER --- Onboarding de Identidade**

8.  RH cria ticket em \[ITSM_TOOL\] com: nome, funcao, gestor, data de inicio, perfil de acesso.

9.  \[IAM_TEAM\] valida e aprova o perfil baseado no Catalogo de Identidades (Secao II).

10. Automacao (\[Logic Apps/Power Automate/Azure Functions\]) cria conta no IdP corporativo.

11. Atribuicao de grupos e roles correspondentes ao perfil de funcao.

12. MFA obrigatorio habilitado --- usuario recebe instrucoes de onboarding via e-mail.

13. Para P2+: elegibilidade PIM configurada --- acesso JIT, nao permanente.

14. Confirmacao ao gestor com resumo de acessos provisionados.

**3.1.1 Script de Provisionamento --- PowerShell Idempotente**

> \# IDM-POL-001-JOINER-001 \| Provisionamento Identidade + RBAC
>
> \# Substitua todos os parametros \[VARIAVEL\] antes de executar
>
> param(
>
> \[string\]\$UserPrincipalName = \'usuario@\[TENANT_DOMAIN\]\',
>
> \[string\]\$DisplayName = \'\[NOME_COMPLETO\]\',
>
> \[string\]\$Department = \'\[DEPARTAMENTO\]\',
>
> \[string\]\$JobTitle = \'\[CARGO\]\',
>
> \[string\]\$SubscriptionId = \'\[SUBSCRIPTION_ID\]\',
>
> \[string\]\$RoleDefinition = \'\[ROLE_NAME\]\',
>
> \[string\]\$ResourceGroup = \'\[RESOURCE_GROUP\]\'
>
> )
>
> \# Conectar ao IdP e Cloud Provider
>
> Connect-MgGraph -Scopes \'User.ReadWrite.All\',\'Directory.ReadWrite.All\'
>
> Connect-AzAccount -TenantId \'\[TENANT_ID\]\' -SubscriptionId \$SubscriptionId
>
> \# Criar usuario (idempotente)
>
> \$u = Get-MgUser -Filter \"userPrincipalName eq \'\$UserPrincipalName\'\" -ErrorAction SilentlyContinue
>
> if (-not \$u) {
>
> \$pp = @{ Password=(New-Guid).Guid+\'!Az1\'; ForceChangePasswordNextSignIn=\$true }
>
> New-MgUser -UserPrincipalName \$UPN -DisplayName \$DisplayName -AccountEnabled \$true -PasswordProfile \$pp
>
> Write-Output \'\[OK\] Usuario criado: \'\$UserPrincipalName
>
> } else { Write-Output \'\[SKIP\] Usuario ja existe.\' }
>
> \# Atribuir RBAC (idempotente)
>
> \$scope=\'/subscriptions/\'+\$SubscriptionId+\'/resourceGroups/\'+\$ResourceGroup
>
> \$ex = Get-AzRoleAssignment -SignInName \$UserPrincipalName -RoleDefinitionName \$RoleDefinition -Scope \$scope -EA SilentlyContinue
>
> if (-not \$ex) {
>
> New-AzRoleAssignment -SignInName \$UserPrincipalName -RoleDefinitionName \$RoleDefinition -Scope \$scope
>
> Write-Output \'\[OK\] Role atribuida: \'\$RoleDefinition
>
> } else { Write-Output \'\[SKIP\] Role ja atribuida.\' }

**3.2 MOVER --- Transferencia de Funcao**

Tratado como Leaver + Joiner combinado: remocao total dos acessos anteriores e provisionamento dos novos. SLA: \<= 8 horas uteis. Nenhuma permissao da funcao anterior deve persistir.

**3.3 LEAVER --- Desligamento (SLA CRITICO: 15 MINUTOS)**

> **⚠ LEAVER e o processo de maior risco. O SLA de 15 minutos e mandatorio e auditavel. Violacoes devem ser escaladas ao CISO.**

**3.3.1 Sequencia Obrigatoria de Revogacao**

15. **RH notifica \[ITSM_TOOL\] + aciona automacao via webhook/API.**

16. **Block da conta no IdP corporativo --- IMEDIATO.**

17. **Revogacao de todas as sessoes ativas (Revoke Sign-in Sessions).**

18. Remocao de todos os grupos, roles e elegibilidades PIM.

19. Limpeza de authorized_keys em VMs Linux (se aplicavel --- via Run Command ou Ansible).

20. Rotacao de segredos que o usuario conhecia (service accounts, shared credentials).

21. Alerta no \[SIEM_TOOL\] + ticket ITSM encerrado com evidencia de conclusao.

**3.3.2 Script de Desligamento --- PowerShell**

> \# IDM-POL-001-LEAVER-001 \| Desligamento Automatizado
>
> param(\[string\]\$UserPrincipalName = \'usuario@\[TENANT_DOMAIN\]\')
>
> \# 1. Bloquear conta no IdP
>
> Update-MgUser -UserId \$UserPrincipalName -AccountEnabled \$false
>
> Write-Output \'\[OK\] Conta bloqueada\'
>
> \# 2. Revogar sessoes ativas
>
> Revoke-MgUserSignInSession -UserId \$UserPrincipalName
>
> Write-Output \'\[OK\] Sessoes revogadas\'
>
> \# 3. Remover grupos
>
> \$groups = Get-MgUserMemberOf -UserId \$UserPrincipalName
>
> foreach (\$g in \$groups) {
>
> Remove-MgGroupMemberByRef -GroupId \$g.Id -DirectoryObjectId (Get-MgUser -UserId \$UserPrincipalName).Id
>
> }
>
> Write-Output \'\[OK\] Grupos removidos: \'\$groups.Count
>
> \# 4. Remover role assignments Azure
>
> \$ra = Get-AzRoleAssignment -SignInName \$UserPrincipalName
>
> foreach (\$r in \$ra) { Remove-AzRoleAssignment -InputObject \$r }
>
> Write-Output \'\[OK\] Roles removidas: \'\$ra.Count
>
> Write-Output \'\[DONE\] Leaver concluido para: \'\$UserPrincipalName

**3.3.3 Script de Limpeza SSH --- Bash (via Run Command)**

> \#!/bin/bash
>
> \# IDM-POL-001-LEAVER-SSH-001 \| Remocao de conta local orphan
>
> USERNAME=\'\[USERNAME_DESLIGADO\]\'
>
> \# Zerar authorized_keys (idempotente)
>
> AUTH=\'/home/\'\${USERNAME}\'/.ssh/authorized_keys\'
>
> if \[ -f \"\$AUTH\" \]; then \> \"\$AUTH\"; echo \'\[OK\] authorized_keys limpo\'; fi
>
> \# Bloquear conta local se existir
>
> if id \"\$USERNAME\" &\>/dev/null; then
>
> usermod -L \"\$USERNAME\"
>
> usermod -s /usr/sbin/nologin \"\$USERNAME\"
>
> echo \'\[OK\] Conta local bloqueada: \'\$USERNAME
>
> else
>
> echo \'\[SKIP\] Conta nao encontrada: \'\$USERNAME
>
> fi

**3.3.4 DORMANT ACCOUNT DISCOVERY --- Anti-Orphan Automation**

**Automacao de descoberta de contas dormentes (inativas \> 90 dias) e essencial para prevencao de contas orfas. Deve ser executada mensalmente e os resultados registrados como evidencia de auditoria.**

**KQL --- Deteccao de Contas Dormentes (SIEM)**

> // IDM-POL-001-KQL-DORMANT-001 \| Contas sem login \> 90 dias
>
> // Evidencia: ISO 27001 A.5.18 \| SOC2 CC6.2 \| COBIT APO13.02
>
> SigninLogs
>
> \| where TimeGenerated \> ago(90d)
>
> \| where ResultType == 0
>
> \| summarize LastSignIn=max(TimeGenerated) by UserPrincipalName
>
> \| join kind=rightanti (
>
> SigninLogs
>
> \| where TimeGenerated \> ago(90d)
>
> \| summarize by UserPrincipalName
>
> ) on UserPrincipalName
>
> // Resultado: usuarios com conta ativa mas sem nenhum login nos ultimos 90 dias
>
> \| order by LastSignIn asc

**PowerShell --- Desativar Contas Dormentes Automaticamente**

> \# IDM-POL-001-DORMANT-DISABLE-001 \| Desativar contas inativas \> 90 dias
>
> \# ATENCAO: Executar em modo DryRun primeiro. Remover -WhatIf para aplicar.
>
> \$cutoff = (Get-Date).AddDays(-90)
>
> \$inactiveUsers = Get-MgUser -All -Filter \'accountEnabled eq true\' \|
>
> Where-Object { \$\_.SignInActivity.LastSignInDateTime -lt \$cutoff }
>
> foreach (\$u in \$inactiveUsers) {
>
> Write-Output \'\[DRY-RUN\] Desativando: \'\$u.UserPrincipalName\' \| Ultimo login: \'\$u.SignInActivity.LastSignInDateTime
>
> \# Update-MgUser -UserId \$u.Id -AccountEnabled \$false \# Remover comentario para aplicar
>
> }
>
> Write-Output \'Total contas dormentes identificadas: \'\$inactiveUsers.Count

**IV · Break-Glass & Dupla Custodia**

**4.1 Definicao e Justificativa**

Contas Break-Glass sao identidades de emergencia com privilegio maximo, utilizadas exclusivamente quando os mecanismos normais de autenticacao estao indisponiveis. Representam o cofre do cofre da organizacao.

O modelo de Dupla Custodia e mandatorio: dois custodiantes de alta confianca sao necessarios para reconstruir o segredo completo, eliminando o single point of failure humano.

**4.2 Custodiantes e Armazenamento**

|        |                              |                                   |                         |                        |
|--------|------------------------------|-----------------------------------|-------------------------|------------------------|
| **ID** | **Cargo/Funcao**             | **Responsabilidade**              | **Parte do Segredo**    | **Backup Custodiante** |
| C1     | \[C1_CARGO\] --- \[C1_NOME\] | Guarda Parte A --- \[KV_NAME_C1\] | **Metade A (1a parte)** | \[C1_BACKUP_NOME\]     |
| C2     | \[C2_CARGO\] --- \[C2_NOME\] | Guarda Parte B --- \[KV_NAME_C2\] | **Metade B (2a parte)** | \[C2_BACKUP_NOME\]     |

- Cofres em subscriptions ou vaults DISTINTAS para evitar comprometimento unico.

- Recomendado: \[Azure Dedicated HSM / CloudHSM / Hardware HSM\] para organizacoes regulamentadas.

- Opcao fisica: copia impressa em cofre certificado com registro de acesso em livro de custodia.

**4.3 Procedimento de Acionamento**

**Gatilhos Validos para Uso Break-Glass**

- Falha total do IdP corporativo / plataforma de identidade.

- Perda de acesso MFA do administrador principal.

- Incidente de seguranca exigindo acesso imediato sem espera de JIT/PIM.

- DR/PCN --- Plano de Continuidade de Negocios ativado.

**4.3.1 Fluxo de Acionamento --- Passo a Passo**

22. SOC/Time de Seguranca confirma necessidade e documenta justificativa no \[ITSM_TOOL\].

23. C1 e C2 sao contatados SIMULTANEAMENTE --- autorizacao verbal gravada ou registrada.

24. C1 acessa \[KV_NAME_C1\] e extrai Parte A. C2 acessa \[KV_NAME_C2\] e extrai Parte B.

25. As partes sao combinadas para reconstruir a senha completa da conta de emergencia.

26. Login na conta emergency-admin-\[01\]@\[TENANT_DOMAIN\] via browser (modo privado/incognito).

27. **\[SIEM_TOOL\] dispara alerta P0 automaticamente --- SOC e notificado.**

28. Acao executada com ESCOPO MINIMO possivel e tempo minimo.

29. ROTACAO OBRIGATORIA: senha rotacionada e re-armazenada nos cofres imediatamente apos uso.

30. RCA (Root Cause Analysis) no \[ITSM_TOOL\] dentro de 24 horas.

**4.4 Serial Console / Console de Emergencia --- Acesso DR a VM**

Para cenarios onde a VM nao esta acessivel via SSH/IdP (falha de rede, corrupcao de OS), o console de emergencia da plataforma cloud permite acesso de baixo nivel sem dependencia de conectividade.

> \# IDM-POL-001-BREAKGLASS-CONSOLE-001
>
> \# Acesso de emergencia via CLI (Azure como exemplo)
>
> \# 1. Habilitar boot diagnostics (pre-requisito --- executar proativamente)
>
> az vm boot-diagnostics enable \\
>
> \--name \[VM_NAME\] \\
>
> \--resource-group \[RESOURCE_GROUP\] \\
>
> \--storage \[STORAGE_ACCOUNT_URI\]
>
> \# 2. Via portal: VM \> Help \> Serial Console
>
> \# Equivalente em outros provedores:
>
> \# AWS: EC2 Instance Connect / EC2 Serial Console
>
> \# GCP: gcloud compute connect-to-serial-port \[INSTANCE\]
>
> \# 3. Apos acesso --- resetar senha root e armazenar no vault:
>
> \# echo \'root:\[NOVA_SENHA\]\' \| chpasswd
>
> \# az keyvault secret set \--vault-name \[KV_NAME\] \--name \[VM_NAME\]-root-pw \--value \'\[NOVA_SENHA\]\'
>
> \# OBRIGATORIO: Rotacionar apos qualquer uso manual

**4.5 Testes de Break-Glass --- Calendário Obrigatório**

|                   |                                                                             |                |                 |               |
|-------------------|-----------------------------------------------------------------------------|----------------|-----------------|---------------|
| **Tipo de Teste** | **Descricao**                                                               | **Frequencia** | **Responsavel** | **Evidencia** |
| Login Test        | Confirmar acesso funcional sem executar acoes criticas                      | 90 dias        | \[CISO\]        | Sign-in log   |
| Custodia Test     | C1 e C2 verificam que possuem suas partes e conseguem reconstruir o segredo | 180 dias       | \[C1\]+\[C2\]   | Ata assinada  |
| SIEM Alert Test   | Confirmar que alerta P0 e disparado ao logar com conta Break-Glass          | 90 dias        | \[SOC_LEAD\]    | Alert log     |

**V · SSH Zero Trust --- Autenticacao Centralizada**

**5.1 Risco de Conformidade --- Chaves RSA Locais**

O uso de chaves SSH RSA em authorized_keys locais viola principios fundamentais de governanca em ambientes auditados (ISO 27001, SOC 2, PCI-DSS). Detalhes no catalogo de identidades (Secao 2.3).

**5.1.1 Anatomia do Risco Tecnico**

> \# ANALISE DE RISCO --- authorized_keys (nao executar em producao)
>
> RISCO 1: Portabilidade do Segredo
>
> O arquivo \~/.ssh/id_rsa pode ser copiado para qualquer maquina.
>
> Qualquer pessoa com o arquivo tem acesso completo ao servidor.
>
> RISCO 2: Conta Orfa Automatica (Leaver Gap)
>
> /etc/passwd: \[usuario\]:x:1001:1001::/home/\[usuario\]:/bin/bash
>
> /home/\[usuario\]/.ssh/authorized_keys: \[chave publica ainda valida\]
>
> Apos demissao: IdP bloqueado. VM: ACESSO AINDA FUNCIONAL.
>
> RISCO 3: Ausencia de Auditoria Nativa
>
> authorized_keys nao registra: quem usou, quando, de onde, o que executou.
>
> Nao-repudio IMPOSSIVEL --- ISO 27001 A.12.4 violado.
>
> RISCO 4: Sem MFA
>
> SSH via chave RSA nao suporta segundo fator nativamente.
>
> SOC 2 CC6.1 violado para contas humanas.

**5.2 Solucao --- IdP Login for Linux**

Substitui chaves RSA locais por tokens de identidade do IdP corporativo, integrando o ciclo de vida da identidade da VM ao JML da organizacao. Exemplos de solucao: Azure AD Login for Linux, SSSD com LDAP/Kerberos, Teleport, HashiCorp Boundary.

**5.2.1 Habilitacao --- Azure AD Login for Linux (exemplo)**

> \# IDM-POL-001-SSH-ENABLE-001
>
> az vm extension set \\
>
> \--publisher Microsoft.Azure.ActiveDirectory \\
>
> \--name AADSSHLoginForLinux \\
>
> \--resource-group \[RESOURCE_GROUP\] \\
>
> \--vm-name \[VM_NAME\]

**5.2.2 Atribuicao de Roles para SSH**

> \# IDM-POL-001-SSH-RBAC-001
>
> VM_SCOPE=\'/subscriptions/\[SUBSCRIPTION_ID\]/resourceGroups/\[RESOURCE_GROUP\]
>
> /providers/Microsoft.Compute/virtualMachines/\[VM_NAME\]\'
>
> \# Acesso padrao (sem sudo)
>
> az role assignment create \--assignee \'usuario@\[TENANT_DOMAIN\]\' \\
>
> \--role \'Virtual Machine User Login\' \--scope \$VM_SCOPE
>
> \# Acesso administrativo (com sudo)
>
> az role assignment create \--assignee \'usuario@\[TENANT_DOMAIN\]\' \\
>
> \--role \'Virtual Machine Administrator Login\' \--scope \$VM_SCOPE

**5.2.3 Autenticacao SSH via IdP**

> \# IDM-POL-001-SSH-AUTH-001
>
> \# Acesso SSH via token IdP (sem chave RSA local)
>
> az ssh vm \\
>
> \--resource-group \[RESOURCE_GROUP\] \\
>
> \--name \[VM_NAME\]
>
> \# Token gerado automaticamente. MFA exigido via Conditional Access.
>
> \# Log: IdP Sign-in Logs + \[MONITOR_TOOL\]

**5.3 Hardening Root --- Conta de Emergencia**

> \#!/bin/bash
>
> \# IDM-POL-001-ROOT-HARDENING-001
>
> \# Desabilitar login SSH como root
>
> sed -i \'s/\^PermitRootLogin.\*/PermitRootLogin no/\' /etc/ssh/sshd_config
>
> \# Desabilitar autenticacao por senha
>
> sed -i \'s/\^PasswordAuthentication.\*/PasswordAuthentication no/\' /etc/ssh/sshd_config
>
> \# Desabilitar chave publica local (somente IdP)
>
> sed -i \'s/\^PubkeyAuthentication.\*/PubkeyAuthentication no/\' /etc/ssh/sshd_config
>
> systemctl restart sshd
>
> \# Gerar senha root aleatoria e armazenar no vault
>
> ROOT_PASS=\$(openssl rand -base64 32)
>
> echo \"root:\${ROOT_PASS}\" \| chpasswd
>
> \# Armazenar no vault (exemplo: Azure Key Vault)
>
> az keyvault secret set \\
>
> \--vault-name \'\[KV_NAME\]\' \\
>
> \--name \'\[VM_NAME\]-root-password\' \\
>
> \--value \"\${ROOT_PASS}\"
>
> echo \'\[OK\] Root hardened. Senha no vault. Rotacionar apos qualquer uso.\'

**5.4 Contas de Servico --- SSH Automatizado**

Quando automacoes (IaC, CI/CD, Ansible) precisam de acesso SSH, a abordagem preferida e Managed Identity + Run Command, eliminando chaves SSH. Se chaves forem inevitaveis:

- Chave privada armazenada em \[KV_NAME\] ou PAM equivalente.

- Rotacao automatica via \[Terraform/Ansible/Azure Automation\] a cada 30 dias.

- Nenhum humano deve conhecer a chave privada de uma service account.

- Comprometimento: regeneracao imediata + limpeza do authorized_keys nas VMs afetadas.

**5.5 Access Review --- Contas SSH Periodico**

> \#!/bin/bash
>
> \# IDM-POL-001-SSH-REVIEW-001 \| Auditoria de authorized_keys em VMs
>
> \# Executar via \[Ansible/Azure Run Command\] mensalmente
>
> echo \'=== Auditoria authorized_keys ===\'
>
> for HOME_DIR in /home/\*/; do
>
> USER=\$(basename \$HOME_DIR)
>
> AUTH_KEYS=\"\${HOME_DIR}.ssh/authorized_keys\"
>
> if \[ -f \"\$AUTH_KEYS\" \] && \[ -s \"\$AUTH_KEYS\" \]; then
>
> COUNT=\$(wc -l \< \"\$AUTH_KEYS\")
>
> echo \"\[ATENCAO\] \$USER tem \$COUNT chave(s) em authorized_keys\"
>
> cat \"\$AUTH_KEYS\"
>
> fi
>
> done
>
> echo \'=== Fim da Auditoria ===\'

**5.6 TIER 6 --- VPN Overlay Networks (Zero Trust Mesh)**

> ℹ Ferramentas VPN citadas sao exemplos: \[Tailscale/WireGuard/Azure VPN Gateway/OpenVPN\]. O principio Zero Trust se aplica independentemente da solucao escolhida.

**Em ambientes hibridos, expor SSH via IP publico e um vetor de ataque critico. O modelo recomendado e o uso de redes overlay (VPN mesh) que escondem VMs atras de um gateway de identidade, eliminando a exposicao direta.**

**5.6.1 Riscos de SSH com IP Publico**

- Superficie de ataque exposta a internet --- brute force, scanning, exploits zero-day.

- Sem governanca de quem pode se conectar (qualquer IP pode tentar).

- Dificuldade de correlacao de logs com identidade corporativa.

- Violacao de principio Zero Trust: nenhuma rede e confiavel por default.

**5.6.2 Arquitetura Zero Trust Mesh**

> \# IDM-POL-001-VPN-OVERLAY-001
>
> \# Exemplo com solucao overlay VPN (adapte para sua ferramenta)
>
> \# \-\-- GATEWAY NODE (servidor de acesso centralizado) \-\--
>
> \# \[tailscale up \--advertise-tags=tag:gateway\] \# Exemplo Tailscale
>
> \# \[wg-quick up wg0\] \# Exemplo WireGuard
>
> \# Equivalente: Azure VPN Gateway / AWS Client VPN / GCP Cloud VPN
>
> \# \-\-- VM ALVO (sem IP publico) \-\--
>
> \# \[tailscale up \--advertise-tags=tag:server\]
>
> \# NSG / Firewall: bloquear porta 22 para 0.0.0.0/0
>
> \# Permitir apenas UDP \[porta_overlay\] de IPs autorizados
>
> \# \-\-- POLITICA DE ACESSO (ACL centralizada) \-\--
>
> \# Grupos de acesso baseados em identidade corporativa (IdP):
>
> \# tag:admin -\> Acesso SSH completo
>
> \# tag:dev -\> Acesso SSH somente em ambientes nao-producao
>
> \# tag:audit -\> Acesso somente leitura via \[MONITOR_TOOL\]

**5.6.3 Integracao JML com VPN Overlay**

A revogacao de acesso VPN deve ser integrada ao processo LEAVER:

- JOINER: usuario adicionado ao grupo de acesso na ACL do gateway (ex: tag:dev).

- MOVER: grupo atualizado conforme novo perfil de funcao.

- LEAVER: usuario removido de todos os grupos da ACL no \[ITSM_TOOL\] --- acesso VPN revogado automaticamente.

> \# IDM-POL-001-VPN-JML-001 \| Revogacao VPN no LEAVER
>
> \# Adapte para a ferramenta VPN da organizacao
>
> \# Exemplo: Remover usuario de grupo de acesso via API
>
> \# curl -X DELETE \'https://\[VPN_API\]/api/v1/acl/users/usuario@\[TENANT_DOMAIN\]\'
>
> \# -H \'Authorization: Bearer \[API_TOKEN\]\'
>
> \# PowerShell generico para remocao de grupo de acesso:
>
> \$headers = @{ Authorization = \'Bearer \[API_TOKEN\]\'; \'Content-Type\'=\'application/json\' }
>
> Invoke-RestMethod -Method DELETE \\
>
> -Uri \'https://\[VPN_MGMT_API\]/users/usuario@\[TENANT_DOMAIN\]/groups/\[GROUP_NAME\]\' \\
>
> -Headers \$headers
>
> Write-Output \'\[OK\] Acesso VPN revogado para: usuario@\[TENANT_DOMAIN\]\'

**VI · PAM & Gestao de Segredos**

**6.1 Modelo de Tiering de Segredos**

|                |                 |                     |                        |                            |                 |                    |          |
|----------------|-----------------|---------------------|------------------------|----------------------------|-----------------|--------------------|----------|
| **Tier**       | **Tipo**        | **Exemplo**         | **Cofre**              | **Acesso**                 | **Rotacao**     | **Custodia**       | **SLA**  |
| **P1 CRITICO** | Break-Glass     | Global Admin Pwd    | **\[HSM/KV Premium\]** | Dupla Custodia Fisica+RBAC | **90d+pos-uso** | \[C1\]+\[C2\]      | Imediato |
| **P2 ALTO**    | DB Root         | DB Root / SA        | \[KV_NAME\] Premium    | PIM RBAC+Aprovacao         | 90 dias         | KV Secrets Officer | 15 min   |
| **P3 MEDIO**   | App Credentials | Service Account Pwd | \[KV_NAME\]            | RBAC Secrets User          | 30 dias (auto)  | \[IAM_TEAM\]       | 1h       |
| **P4 BAIXO**   | Secretless      | Managed Identity    | Nenhum --- token auto  | Automatico (MSAL)          | Ciclo recurso   | Cloud Provider     | N/A      |

**6.2 Vault --- Configuracao Base**

> ℹ Ferramenta de vault citada como exemplo: \[Azure Key Vault / AWS Secrets Manager / HashiCorp Vault / GCP Secret Manager\]. Os principios sao identicos.
>
> \# IDM-POL-001-KV-001 \| Criacao de Vault com seguranca maxima (Azure exemplo)
>
> az keyvault create \\
>
> \--name \'\[KV_NAME\]\' \\
>
> \--resource-group \'\[RESOURCE_GROUP\]\' \\
>
> \--location \'\[LOCATION\]\' \\
>
> \--sku \'premium\' \\
>
> \--enable-rbac-authorization true \\
>
> \--enable-soft-delete true \\
>
> \--soft-delete-retention-days 90 \\
>
> \--enable-purge-protection true \\
>
> \--public-network-access Disabled
>
> \# Atribuir \'Secrets Officer\' ao \[IAM_TEAM\]
>
> az role assignment create \\
>
> \--assignee \'\[IAM_TEAM_GROUP_ID\]\' \\
>
> \--role \'Key Vault Secrets Officer\' \\
>
> \--scope \'/subscriptions/\[SUBSCRIPTION_ID\]/resourceGroups/\[RESOURCE_GROUP\]/providers/Microsoft.KeyVault/vaults/\[KV_NAME\]\'
>
> \# Managed Identity pode apenas LER segredos
>
> az role assignment create \\
>
> \--assignee \'\[MANAGED_IDENTITY_PRINCIPAL_ID\]\' \\
>
> \--role \'Key Vault Secrets User\' \\
>
> \--scope \'/subscriptions/\[SUBSCRIPTION_ID\]/resourceGroups/\[RESOURCE_GROUP\]/providers/Microsoft.KeyVault/vaults/\[KV_NAME\]\'

**6.3 Managed Identity --- Padrao Secretless**

**Managed Identity e a solucao prioritaria para toda comunicacao VM/aplicacao com recursos cloud. Elimina credenciais estaticas e o risco de segredos em codigo-fonte ou variaveis de ambiente.**

> \# IDM-POL-001-MI-001 \| Managed Identity na VM
>
> \# Habilitar System-Assigned Managed Identity
>
> az vm identity assign \\
>
> \--resource-group \'\[RESOURCE_GROUP\]\' \\
>
> \--name \'\[VM_NAME\]\'
>
> \# Obter Principal ID
>
> PRINCIPAL_ID=\$(az vm identity show \\
>
> \--resource-group \'\[RESOURCE_GROUP\]\' \\
>
> \--name \'\[VM_NAME\]\' \--query principalId -o tsv)
>
> \# Atribuir permissao de leitura no vault
>
> az role assignment create \\
>
> \--assignee \$PRINCIPAL_ID \\
>
> \--role \'Key Vault Secrets User\' \\
>
> \--scope \'/subscriptions/\[SUBSCRIPTION_ID\]/resourceGroups/\[RESOURCE_GROUP\]/providers/Microsoft.KeyVault/vaults/\[KV_NAME\]\'

**6.4 DATABASE SERVICE ACCOUNTS --- Relational DBs**

> ℹ Scripts de hardening citam MySQL/MariaDB como exemplo. Principios aplicam-se a PostgreSQL, SQL Server, Oracle e outros bancos relacionais.

**Contas de banco de dados (root, sa, postgres, dba) sao identidades de Tier P4 (ALTO --- Sistema) e devem seguir controles equivalentes: sem login direto habitual, senha em vault, rotacao periodica e auditoria de acesso.**

**6.4.1 Hardening Idempotente de Banco de Dados**

> \#!/bin/bash
>
> \# IDM-POL-001-DB-HARDENING-001 \| MySQL/MariaDB (adapte para outros DBs)
>
> \# Equivalente a mysql_secure_installation --- automatizado e idempotente
>
> DB_ROOT_PASS=\'\[GERAR_VIA_OPENSSL_ARMAZENAR_NO_VAULT\]\'
>
> DB_NAME=\'\[DB_NAME\]\'
>
> DB_APP_USER=\'\[APP_DB_USER\]\'
>
> DB_APP_PASS=\'\[GERAR_VIA_OPENSSL_ARMAZENAR_NO_VAULT\]\'
>
> mysql -u root -p\${DB_ROOT_PASS} \<\<EOF
>
> \-- Remover usuarios anonimos
>
> DELETE FROM mysql.user WHERE User=\'\';
>
> \-- Desabilitar login root remoto
>
> DELETE FROM mysql.user WHERE User=\'root\' AND Host NOT IN (\'localhost\',\'127.0.0.1\',\'::1\');
>
> \-- Remover banco de dados de teste
>
> DROP DATABASE IF EXISTS test;
>
> DELETE FROM mysql.db WHERE Db=\'test\' OR Db=\'test\\%\';
>
> \-- Criar usuario de aplicacao com privilegio minimo
>
> CREATE USER IF NOT EXISTS \'\${DB_APP_USER}\'@\'localhost\' IDENTIFIED BY \'\${DB_APP_PASS}\';
>
> GRANT SELECT, INSERT, UPDATE, DELETE ON \${DB_NAME}.\* TO \'\${DB_APP_USER}\'@\'localhost\';
>
> FLUSH PRIVILEGES;
>
> EOF
>
> echo \'\[OK\] Hardening de banco de dados concluido\'

**6.4.2 Armazenamento e Rotacao de Credenciais DB**

> \# IDM-POL-001-DB-VAULT-001 \| Armazenar credenciais DB no vault
>
> \# Senha do root do banco
>
> az keyvault secret set \\
>
> \--vault-name \'\[KV_NAME\]\' \\
>
> \--name \'\[VM_NAME\]-db-root-password\' \\
>
> \--value \'\[DB_ROOT_PASS\]\'
>
> \# Senha do usuario de aplicacao
>
> az keyvault secret set \\
>
> \--vault-name \'\[KV_NAME\]\' \\
>
> \--name \'\[VM_NAME\]-db-app-password\' \\
>
> \--value \'\[DB_APP_PASS\]\'
>
> \# Rotacao manual (disparar tambem apos qualquer incidente de acesso privilegiado)
>
> NEW_ROOT_PASS=\$(openssl rand -base64 32)
>
> mysql -u root -p\$(az keyvault secret show \--vault-name \'\[KV_NAME\]\' \\
>
> \--name \'\[VM_NAME\]-db-root-password\' \--query value -o tsv) \\
>
> -e \"ALTER USER \'root\'@\'localhost\' IDENTIFIED BY \'\${NEW_ROOT_PASS}\';\"
>
> az keyvault secret set \--vault-name \'\[KV_NAME\]\' \--name \'\[VM_NAME\]-db-root-password\' \--value \"\${NEW_ROOT_PASS}\"
>
> echo \'\[OK\] Senha root do DB rotacionada e atualizada no vault\'

|                             |                                       |                          |                           |
|-----------------------------|---------------------------------------|--------------------------|---------------------------|
| **Evento de Rotacao**       | **Acao**                              | **Responsavel**          | **Evidencia**             |
| Rotacao Periodica (90 dias) | Script automatizado de rotacao        | \[IAM_TEAM\] / Automacao | Vault audit log           |
| Pos-Incidente               | Rotacao imediata + revisao de logs    | \[IAM_TEAM\] + SOC       | ITSM ticket + RCA         |
| Desligamento de DBA         | Rotacao em todas as senhas conhecidas | \[IAM_TEAM\]             | Ticket LEAVER + log vault |

**VII · Evidencias de Auditoria e Monitoramento**

**7.1 Mapeamento de Controles e Evidencias**

|               |                 |                                                  |                               |              |
|---------------|-----------------|--------------------------------------------------|-------------------------------|--------------|
| **Controle**  | **Framework**   | **Evidencia Requerida**                          | **Fonte de Log**              | **Retencao** |
| A.5.15        | ISO 27001:2022  | Inventario de identidades atualizado mensalmente | IdP + \[AUTOMACAO_TOOL\]      | 12 meses     |
| A.5.18        | ISO 27001:2022  | Logs de JML --- LEAVER em \<=15min               | \[ITSM_TOOL\] + \[SIEM_TOOL\] | 12 meses     |
| CC6.1         | SOC 2 Type II   | MFA habilitado para 100% das contas humanas      | IdP Sign-in Logs              | 12 meses     |
| CC6.2         | SOC 2 Type II   | Access Review trimestral documentado e assinado  | IdP Access Review             | 3 anos       |
| CC6.3         | SOC 2 Type II   | Aprovacao formal para todo acesso privilegiado   | PIM / PAM Audit Log           | 12 meses     |
| APO13.02      | COBIT 2019      | Inventario de identidades --- relatorio mensal   | IdP + KQL/\[SIEM\]            | 12 meses     |
| A.8.18        | ISO 27001:2022  | Logs de uso de contas privilegiadas (PIM/PAM)    | IdP Audit + \[SIEM_TOOL\]     | 12 meses     |
| PR.AA-01      | NIST CSF 2.0    | Autenticacao multifator para todos os usuarios   | IdP + Conditional Access      | 12 meses     |
| CIS Control 5 | CIS Controls v8 | Inventario e controle de contas de usuario       | \[SIEM_TOOL\] + Automacao     | 12 meses     |

**7.2 Alert Rules Obrigatorias no SIEM**

> ℹ SIEM citado como exemplo: \[Microsoft Sentinel / Splunk / IBM QRadar / ELK/OpenSearch\]. As regras de alerta devem ser adaptadas para a plataforma da organizacao.

|                        |                                            |                    |                                         |         |
|------------------------|--------------------------------------------|--------------------|-----------------------------------------|---------|
| **Alert Name**         | **Condicao**                               | **Severidade**     | **Acao Automatica**                     | **SLA** |
| **BREAK-GLASS-LOGIN**  | Login em conta de emergencia break-glass   | **P0 --- CRITICO** | Pager + E-mail CISO + Teams/Slack       | 5 min   |
| LEAVER-SLA-BREACH      | Conta ativa \>15min apos ticket LEAVER     | P1 --- ALTO        | \[ITSM_TOOL\] + \[CHAT_TOOL\]           | 15 min  |
| PRIVILEGED-NO-PIM      | Acao privilegiada sem JIT/PIM ativo        | P1 --- ALTO        | \[CHAT_TOOL\] + \[IAM_TEAM\]            | 30 min  |
| SSH-LOCAL-AUTH         | Login SSH via chave RSA local detectado    | P1 --- ALTO        | \[CHAT_TOOL\] + Revisar authorized_keys | 1h      |
| KV-SECRET-P1-ACCESS    | Acesso a segredo Tier P1/P2 no vault       | P2 --- MEDIO       | Log + Notificacao \[IAM_TEAM\]          | 4h      |
| MFA-DISABLED-PRIV      | MFA removido de conta P1-P2                | P1 --- ALTO        | Bloquear conta + Alerta                 | 15 min  |
| DORMANT-ACCOUNT-ACTIVE | Conta sem login \>90 dias com sessao ativa | P2 --- MEDIO       | Notificacao \[IAM_TEAM\]                | 24h     |

**7.3 KQL --- Queries de Auditoria Continua**

> // IDM-POL-001-KQL-MFA-001 \| Contas sem MFA (Auditoria mensal)
>
> // Evidencia: CC6.1 SOC 2 \| A.5.16 ISO 27001
>
> SigninLogs
>
> \| where TimeGenerated \> ago(30d)
>
> \| where ResultType == 0
>
> \| where AuthenticationRequirement == \'singleFactorAuthentication\'
>
> \| where UserType == \'Member\'
>
> \| summarize LastSignIn=max(TimeGenerated) by UserPrincipalName, AppDisplayName
>
> \| order by LastSignIn desc
>
> // IDM-POL-001-KQL-BREAKGLASS-001 \| Uso de Break-Glass (90 dias)
>
> // Evidencia: A.8.18 ISO 27001 \| APO13.02 COBIT
>
> SigninLogs
>
> \| where TimeGenerated \> ago(90d)
>
> \| where UserPrincipalName contains \'emergency-admin\'
>
> \| project TimeGenerated, UserPrincipalName, IPAddress, Location, ResultType
>
> \| order by TimeGenerated desc
>
> // IDM-POL-001-KQL-ROLES-001 \| Inventario de role assignments privilegiados
>
> // Evidencia: APO13.02 COBIT \| CC6.3 SOC 2 --- relatorio mensal
>
> AzureActivity
>
> \| where TimeGenerated \> ago(30d)
>
> \| where OperationNameValue contains \'Microsoft.Authorization/roleAssignments\'
>
> \| where ActivityStatusValue == \'Success\'
>
> \| project TimeGenerated, Caller, OperationNameValue, ResourceGroup, Properties
>
> \| order by TimeGenerated desc

**7.4 ENTERPRISE FRAMEWORK MAPPING MATRIX**

**Matriz completa de mapeamento de controles IAM entre os principais frameworks de conformidade. Permite ao time de auditoria identificar evidencias necessarias para cada framework de forma consolidada.**

|                        |                    |               |                |                  |                                                      |
|------------------------|--------------------|---------------|----------------|------------------|------------------------------------------------------|
| **Controle IAM**       | **ISO 27001:2022** | **SOC 2 TII** | **COBIT 2019** | **NIST CSF 2.0** | **Evidencia Automatizada**                           |
| Gestao de Identidades  | A.5.15, A.5.16     | CC6.1         | APO13.01       | PR.AA-01         | IdP User Inventory Report (mensal)                   |
| Provisionar/Revogar    | A.5.18, A.8.2      | CC6.2         | APO13.02       | PR.AA-05         | ITSM Ticket Log + IdP Audit Log (LEAVER \<15min)     |
| Acesso Privilegiado    | A.8.18, A.5.17     | CC6.3         | DSS05.04       | PR.AA-06         | PIM/PAM Audit Log + SIEM Alert P0                    |
| MFA Obrigatorio        | A.5.16, A.9.4.2    | CC6.6         | DSS05.05       | PR.AA-02         | Conditional Access Policy Report + Sign-in Logs      |
| Review de Acessos      | A.5.18, A.8.2      | CC6.2, CC6.3  | APO13.02       | PR.AA-05         | Access Review Report trimestral assinado + IdP log   |
| Break-Glass & Custodia | A.5.29, A.8.14     | A1.2          | DSS04.02       | RC.RP-01         | SIEM Alert P0 + Ata de Custodia + Test Log 90d       |
| Monitoramento Logs     | A.8.15, A.8.17     | CC7.2         | MEA01.03       | DE.CM-01         | SIEM Dashboard + Alert Rules ativas + Retencao 12m   |
| SSH Zero Trust         | A.5.15, A.8.18     | CC6.1, CC6.6  | DSS05.04       | PR.AA-05         | Evidencia: authorized_keys vazio + IdP SSH login log |
| Rotacao de Segredos    | A.9.4.3, A.8.24    | CC6.7         | APO13.02       | PR.DS-01         | Vault Rotation Log + Automacao audit trail           |
| Hardening DB           | A.8.9, A.8.28      | CC6.1         | DSS05.06       | PR.PS-01         | Hardening script output + Vault secret audit         |
| VPN/Rede Zero Trust    | A.8.20, A.8.21     | CC6.6, CC6.7  | DSS05.02       | PR.AA-05         | VPN ACL audit log + NSG/FW rule evidence             |

**VIII · Access Review --- Revisao Periodica de Acessos**

**8.1 Ciclo de Revisao**

|                             |                       |                    |               |                      |
|-----------------------------|-----------------------|--------------------|---------------|----------------------|
| **Escopo**                  | **Frequencia**        | **Responsavel**    | **Aprovador** | **Evidencia**        |
| Contas P1 --- Break-Glass   | 90 dias               | \[CISO\]           | \[CEO/Board\] | Ata + Log SIEM       |
| Contas P2 --- Privilegiadas | Trimestral            | \[IAM_TEAM\]       | \[CISO\]      | Access Review Report |
| Contas P3 --- Tecnicas      | Semestral             | Gestor Direto      | \[IAM_TEAM\]  | Access Review Report |
| Service Accounts / MI       | Trimestral            | \[IAM_TEAM\]       | \[CISO\]      | Inventory Report     |
| Contas Inativas \>90 dias   | Mensal (automatizado) | Automation Account | \[IAM_TEAM\]  | SIEM Alert + ITSM    |

**8.2 Script de Access Review --- PowerShell**

> \# IDM-POL-001-ACCESS-REVIEW-001 \| Criar Access Review via API IdP
>
> New-MgIdentityGovernanceAccessReview -BodyParameter @{
>
> displayName = \'Quarterly Review --- Subscription Owners \[DATA_EMISSAO\]\'
>
> startDateTime = \'\[YYYY-MM-DD\]T00:00:00Z\'
>
> endDateTime = \'\[YYYY-MM-DD_PLUS_30D\]T00:00:00Z\'
>
> scope = @{
>
> query = \'/groups/\[GROUP_ID_PRIVILEGED\]/transitiveMembers\'
>
> queryType = \'MicrosoftGraph\'
>
> }
>
> reviewers = @(@{ query=\'/users/\[IAM_TEAM_USER_ID\]\'; queryType=\'MicrosoftGraph\' })
>
> settings = @{
>
> mailNotificationsEnabled = \$true
>
> reminderNotificationsEnabled = \$true
>
> justificationRequiredOnApproval = \$true
>
> defaultDecision = \'Deny\' \# Sem revisao = acesso removido
>
> autoApplyDecisionsEnabled = \$true
>
> }
>
> }

**IX · Troubleshooting, Hardening e Cenarios de Excecao**

**9.1 Cenario: Conta Local Linux com Conta Orfa**

Sintoma: Colaborador desligado. IdP bloqueado. VM Linux com conta local ainda permitindo acesso via chave RSA em authorized_keys.

> \# IDM-POL-001-REMEDIATE-ORPHAN-001 \| Diagnostico e remediacacao
>
> \# Executar via \[Azure Run Command / AWS SSM / SSH direto com conta admin\]
>
> \# Diagnostico
>
> az vm run-command invoke \\
>
> \--resource-group \[RESOURCE_GROUP\] \\
>
> \--name \[VM_NAME\] \\
>
> \--command-id RunShellScript \\
>
> \--scripts \'getent passwd \[USERNAME\]; cat /home/\[USERNAME\]/.ssh/authorized_keys 2\>/dev/null\'
>
> \# Remediacao imediata
>
> az vm run-command invoke \\
>
> \--resource-group \[RESOURCE_GROUP\] \\
>
> \--name \[VM_NAME\] \\
>
> \--command-id RunShellScript \\
>
> \--scripts \'
>
> USERNAME=\"\[USERNAME\]\"
>
> \> /home/\${USERNAME}/.ssh/authorized_keys \# Zerar chaves
>
> usermod -L \${USERNAME} \# Bloquear senha
>
> usermod -s /usr/sbin/nologin \${USERNAME} \# Remover shell
>
> echo REMEDIADO: \${USERNAME}
>
> \'

**9.2 Cenario: Perda de Acesso ao Tenant (Break-Glass)**

31. Contatar C1 e C2 simultaneamente --- ambos obrigatorios.

32. C1 acessa \[KV_NAME_C1\] e extrai Parte A. C2 extrai Parte B.

33. Combinar partes para obter senha completa da conta de emergencia.

34. Acessar emergency-admin-\[01\]@\[TENANT_DOMAIN\] via browser privado.

35. SIEM dispara alerta P0 --- SOC notificado automaticamente.

36. Executar acao necessaria com escopo minimo.

37. IMEDIATAMENTE: rotar senha e re-armazenar nos cofres.

38. Registrar incidente no \[ITSM_TOOL\] + notificar CISO.

**9.3 Cenario: Chave SSH Privada Perdida ou Comprometida**

39. Identificar todas as VMs com a chave publica correspondente no authorized_keys.

40. **Executar IDM-POL-001-LEAVER-SSH-001 em todas as VMs afetadas.**

41. Gerar novo par: ssh-keygen -t ed25519 -C \'usuario@\[TENANT_DOMAIN\]\'

42. Se usando IdP SSH (recomendado): nenhuma acao necessaria --- tokens sao efemeros.

43. Registrar no \[ITSM_TOOL\] como Security Event.

**9.4 RESOURCE PERFORMANCE HARDENING (Memory-Constrained Instances)**

> ℹ Esta secao aborda otimizacao de instancias com memoria limitada (ex: VMs t-series, burstable, free tier). Aplicavel a qualquer provedor cloud ou on-premises.

**Instancias com pouca RAM (1-2 GB) --- tipicas em ambientes de laboratorio, staging ou workloads leves --- requerem configuracao de swap e ajuste de OOM Killer para evitar instabilidade e garantir disponibilidade do servico.**

**9.4.1 Configuracao de Swap --- WAF Efficiency Pillar**

> \#!/bin/bash
>
> \# IDM-POL-001-SWAP-001 \| Configuracao de swap (idempotente)
>
> SWAP_FILE=\'/swapfile\'
>
> SWAP_SIZE=\'1G\' \# Ajuste conforme necessidade: 512M, 1G, 2G
>
> \# Criar swapfile apenas se nao existir (idempotente)
>
> if \[ ! -f \"\$SWAP_FILE\" \]; then
>
> fallocate -l \$SWAP_SIZE \$SWAP_FILE
>
> chmod 600 \$SWAP_FILE
>
> mkswap \$SWAP_FILE
>
> swapon \$SWAP_FILE
>
> echo \"\${SWAP_FILE} none swap sw 0 0\" \>\> /etc/fstab
>
> echo \'\[OK\] Swap criado e ativado: \'\$SWAP_SIZE
>
> else
>
> echo \'\[SKIP\] Swap ja existe: \'\$SWAP_FILE
>
> fi

**9.4.2 Ajuste de OOM Killer e Swappiness**

> \#!/bin/bash
>
> \# IDM-POL-001-OOM-001 \| Otimizacao de memoria (idempotente)
>
> \# Swappiness: reduzir uso de swap em favor de RAM (0=nunca, 100=agressivo)
>
> \# Valor 10 = usar swap somente quando necessario
>
> if ! grep -q \'vm.swappiness=10\' /etc/sysctl.conf; then
>
> echo \'vm.swappiness=10\' \>\> /etc/sysctl.conf
>
> fi
>
> \# Reduzir cache pressure
>
> if ! grep -q \'vm.vfs_cache_pressure=50\' /etc/sysctl.conf; then
>
> echo \'vm.vfs_cache_pressure=50\' \>\> /etc/sysctl.conf
>
> fi
>
> \# Aplicar imediatamente
>
> sysctl -p
>
> echo \'\[OK\] Parametros de memoria aplicados\'

**9.4.3 Metricas de Monitoramento de Memoria**

> \#!/bin/bash
>
> \# IDM-POL-001-METRICS-001 \| Snapshot de metricas de recursos
>
> echo \'=== MEMORIA (free -h) ===\'
>
> free -h
>
> echo \'\'
>
> echo \'=== TOP PROCESSOS (top -b -n1) ===\'
>
> top -b -n1 \| head -20
>
> echo \'\'
>
> echo \'=== DISCO (df -h) ===\'
>
> df -h
>
> echo \'\'
>
> echo \'=== SWAP ===\'
>
> swapon \--show
>
> \# Integrar output com \[MONITOR_TOOL\] via Log Analytics Agent / CloudWatch Agent / Prometheus

|                |                |                         |                                                  |
|----------------|----------------|-------------------------|--------------------------------------------------|
| **Metrica**    | **Comando**    | **Threshold de Alerta** | **Acao**                                         |
| RAM disponivel | free -h        | \< 15% da RAM total     | Investigar processos + aumentar instancia        |
| Swap utilizado | swapon \--show | \> 80% do swap          | Escalar instancia ou adicionar swap              |
| CPU usage      | top -b -n1     | \> 90% por 5+ min       | Investigar OOM killer logs: dmesg \| grep -i oom |
| Disco raiz     | df -h /        | \> 85% ocupado          | Limpeza de logs ou expansao do volume            |

**X · Parametros Variaveis e Glossario**

**10.1 Tabela de Substituicao --- Idempotencia 100%**

> ℹ Substitua TODOS os parametros abaixo antes de usar este documento em producao. Nenhum valor especifico deve permanecer no documento final.

|                            |                                      |                                                   |
|----------------------------|--------------------------------------|---------------------------------------------------|
| **Parametro**              | **Descricao**                        | **Exemplo de Valor**                              |
| \[ORGANIZACAO\]            | Nome da organizacao                  | XPTO Servicos Financeiros Ltda.                   |
| \[DEPARTAMENTO_SEGURANCA\] | Time ou departamento responsavel     | Diretoria de Seguranca da Informacao              |
| \[TENANT_ID\]              | ID do tenant do provedor IdP         | xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx              |
| \[TENANT_DOMAIN\]          | Dominio principal do tenant/IdP      | empresa.com.br                                    |
| \[SUBSCRIPTION_ID\]        | ID da subscription cloud             | xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx              |
| \[RESOURCE_GROUP\]         | Resource group alvo                  | rg-seguranca-producao                             |
| \[VM_NAME\]                | Nome da VM Linux/Windows             | vm-api-producao-01                                |
| \[KV_NAME\]                | Nome do vault de segredos principal  | kv-segredos-producao                              |
| \[KV_NAME_C1\]             | Vault do Custodiante 1 (Break-Glass) | kv-breakglass-custodiante-1                       |
| \[KV_NAME_C2\]             | Vault do Custodiante 2 (Break-Glass) | kv-breakglass-custodiante-2                       |
| \[C1_NOME\] / \[C2_NOME\]  | Nomes dos custodiantes Break-Glass   | \[Nome Completo do CISO\] / \[CTO/CSO\]           |
| \[IAM_TEAM\]               | Identificador do time IAM            | iam-team@empresa.com.br                           |
| \[ITSM_TOOL\]              | Sistema de ITSM da organizacao       | \[ServiceNow / Jira Service Mgmt / TopDesk\]      |
| \[SIEM_TOOL\]              | Plataforma SIEM da organizacao       | \[Microsoft Sentinel / Splunk / IBM QRadar\]      |
| \[MONITOR_TOOL\]           | Ferramenta de monitoramento de infra | \[Azure Monitor / Prometheus / Zabbix / Datadog\] |
| \[AUTOMACAO_TOOL\]         | Plataforma de automacao              | \[Logic Apps / Power Automate / Azure Functions\] |
| \[CHAT_TOOL\]              | Canal de notificacao do time         | \[Microsoft Teams / Slack / PagerDuty\]           |
| \[DATA_EMISSAO\]           | Data de emissao do documento         | YYYY-MM-DD                                        |
| \[DATA_REVISAO\]           | Data da proxima revisao              | YYYY-MM-DD (geralmente +12 meses)                 |

**10.2 Glossario Tecnico**

|                              |                                                                                                                                          |
|------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| **Termo**                    | **Definicao**                                                                                                                            |
| **JML**                      | Joiner, Mover, Leaver --- ciclo de vida de identidades vinculado ao ciclo de vida do colaborador.                                        |
| **PIM / PAM**                | Privileged Identity/Access Management --- controle de acessos privilegiados JIT (Just-In-Time).                                          |
| **Break-Glass**              | Conta de emergencia com privilegio maximo, usada exclusivamente quando mecanismos normais falharam.                                      |
| **Dupla Custodia**           | Modelo onde dois custodiantes independentes detem partes distintas de um segredo --- ambos obrigatorios para uso.                        |
| **Zero Standing Privileges** | Principio onde nenhum usuario possui privilegios administrativos permanentes --- todo acesso elevado e JIT.                              |
| **Conta Orfa**               | Conta que permanece ativa apos desligamento do colaborador, sem custodiante. Principal vetor de acesso indevido.                         |
| **Managed Identity**         | Identidade nao-humana gerenciada pelo provedor cloud, sem credenciais estaticas --- padrao Secretless.                                   |
| **authorized_keys**          | Arquivo Linux que armazena chaves publicas SSH. Vetor de risco quando nao gerenciado centralmente --- proibido para humanos em producao. |
| **Serial Console**           | Acesso de baixo nivel a VM via console serial do provedor cloud, independente de rede. Usado em DR/PCN.                                  |
| **Zero Trust**               | Modelo de seguranca onde nenhuma rede ou dispositivo e confiavel por padrao. Verificacao continua de identidade.                         |
| **VPN Overlay/Mesh**         | Rede privada virtual que cria um tunel seguro entre dispositivos, eliminando exposicao SSH/RDP direto a internet.                        |
| **OOM Killer**               | Mecanismo do kernel Linux que encerra processos quando a memoria RAM se esgota para evitar travamento do sistema.                        |
| **Idempotente**              | Propriedade de scripts/documentos que produzem o mesmo resultado independentemente de quantas vezes sao executados.                      |

**10.3 Historico de Revisoes**

|            |                  |              |                                                                                                                   |               |
|------------|------------------|--------------|-------------------------------------------------------------------------------------------------------------------|---------------|
| **Versao** | **Data**         | **Autor**    | **Alteracoes Principais**                                                                                         | **Aprovador** |
| 1.0        | \[DATA_EMISSAO\] | \[AUTOR_v1\] | Criacao inicial: JML, Break-Glass, SSH Zero Trust, PAM, Auditoria                                                 | \[CISO\]      |
| 2.0        | \[DATA_EMISSAO\] | \[AUTOR_v2\] | Idempotencia 100%; +VPN Overlay; +DB Hardening; +Dormant Accounts; +Framework Matrix; Agnosticismo de ferramentas | \[CISO\]      |
|            |                  |              |                                                                                                                   |               |
|            |                  |              |                                                                                                                   |               |

> **✔ IDM-POL-001 v2.0 --- 100% Idempotente. Zero hardcodes. Aplicavel a qualquer organizacao, stack e provedor cloud.**
