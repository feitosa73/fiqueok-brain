


**Arquivo:** `20_Areas/Fiqueok_Consultoria/10_Estrategia_Identidade/GMUD-004 - Estruturação de Unidades Organizacionais (IAM)` **Status:** 🟡 Planejada **Data Planejada:** 19/12/2025 **Solicitante:** Paulo Feitosa (Security Architect) **Aprovador:** (Em Branco/Self)

### 1. Objetivo e Justificativa

**Objetivo:** Criar a estrutura lógica de contêineres (Organizational Units) no Active Directory. 

**Justificativa de Negócio:** 

Necessidade de segregar objetos de AD (Usuários, Computadores e Grupos) para aplicação granular de Políticas de Segurança (GPOs), garantindo conformidade com o controle **A.9.1.1 (Política de Controle de Acesso)** da ISO 27001. A estrutura padrão do Windows (`CN=Users`) não permite gestão adequada de riscos.

### 2. Escopo Técnico

- **Serviço Afetado:** Active Directory Domain Services (AD DS).
    
- **Ativos Envolvidos:** Domain Controller Primário (PDC).
    
- **Impacto no Usuário:** NENHUM. Mudança transparente (Back-end).
    

### 3. Análise de Riscos

- **Risco Identificado:** Conflito de nomenclatura com objetos legados ocultos.
    
- **Probabilidade:** Baixa (Ambiente Controlado/Novo).
    
- **Impacto:** Baixo (Falha na criação da pasta; não para o serviço).
    
- **Mitigação:** O script possui verificação prévia (`Try/Catch` e `Get-ADOrganizationalUnit`) antes de tentar criar.
    

### 4. Plano de Execução (Step-by-Step)

A execução será realizada via automação PowerShell para garantir padronização e evitar erro humano.

**Pré-requisitos:**

1. Acesso como `Enterprise Admin` ou `Domain Admin`.
    
2. PowerShell ISE ou VS Code aberto em modo Administrador.
    

**Script de Execução (`01_Build_Structure_v1.ps1`):**

PowerShell

```
# ==============================================================================
# ARTEFATO TÉCNICO: GMUD-004
# AÇÃO: Criação de Estrutura de OUs (Fiqueok Standard)
# ==============================================================================

Import-Module ActiveDirectory

$RootName = "Fiqueok_Corp"
$DomainDN = (Get-ADDomain).DistinguishedName
$RootPath = "OU=$RootName,$DomainDN"

# 1. Criar Raiz Corporativa (Isolamento do Built-in)
Write-Host ">>> Etapa 1: Criando Raiz $RootName..." -ForegroundColor Cyan
try {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$RootName'")) {
        New-ADOrganizationalUnit -Name $RootName -Path $DomainDN -ProtectedFromAccidentalDeletion $true
        Write-Host " [SUCESSO] Raiz criada." -ForegroundColor Green
    } else { Write-Host " [INFO] Raiz já existe." -ForegroundColor Yellow }
} catch { Write-Error "Falha Crítica na Raiz: $_"; Break }

# 2. Criar Sub-Estruturas (Camada de Gestão)
$SubOUs = @(
    "Admins",       # Contas Privilegiadas
    "Corp_Users",   # Usuários Normais
    "Corp_Devices", # Workstations
    "Sec_Groups",   # Grupos RBAC
    "Service_Acc"   # Contas de Serviço
)

Write-Host ">>> Etapa 2: Criando Sub-OUs..." -ForegroundColor Cyan
foreach ($Item in $SubOUs) {
    try {
        if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$Item'" -SearchBase $RootPath)) {
            New-ADOrganizationalUnit -Name $Item -Path $RootPath -ProtectedFromAccidentalDeletion $true
            Write-Host " [SUCESSO] OU Criada: $Item" -ForegroundColor Green
        }
    } catch { Write-Warning "Falha ao criar $Item: $_" }
}
```

### 5. Plano de Testes (Homologação)

A mudança será considerada **Sucesso** se:

1. [ ] O comando `Get-ADOrganizationalUnit -SearchBase "OU=Fiqueok_Corp,DC=fiqueok,DC=local" -Filter *` retornar a lista das 5 sub-OUs.
    
2. [ ] A tentativa de deletar a OU `Admins` via interface gráfica retornar "Acesso Negado" (validação da flag `ProtectedFromAccidentalDeletion`).
    

### 6. Plano de Rollback (Retorno)

Caso haja erro crítico de replicação ou nomenclatura incorreta.

1. Abrir console `Active Directory Users and Computers`.
    
2. Exibir "Advanced Features" (para ver atributos ocultos).
    
3. Nas propriedades da OU `Fiqueok_Corp`, aba "Object", desmarcar "Protect object from accidental deletion".
    
4. Excluir a OU `Fiqueok_Corp` (isso apagará todas as sub-OUs em cascata).