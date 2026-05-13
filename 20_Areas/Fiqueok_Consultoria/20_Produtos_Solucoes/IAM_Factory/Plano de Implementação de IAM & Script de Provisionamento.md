---
tags:
  - "#IAM"
  - "#PowerShell"
  - "#Fiqueok"
  - "#ISO27001"
  - "#Gov"
created: 2025-12-19
status: 🟢 Draft
type: 📄 Template
---

# 🛡️

> [!abstract] Resumo Executivo
> Estrutura padrão para implementação de um ambiente de Active Directory seguro, segregado por função (RBAC) e preparado para auditoria. Inclui script de automação e modelo de GMUD.

## 1. Estrutura Lógica (OUs)

A arquitetura de OUs deve refletir o modelo de segurança, não apenas o organograma de RH.

- **`DC=Fiqueok`**
	- 📂 `_Admin_Tier` (Contas Privilegiadas - **Tier 0/1**)
	- 📂 `Corp_Users` (Identidades Standard)
	- 📂 `Corp_Computers`
	- 📂 `Sec_Groups` (RBAC Roles)

> [!info] Convenção de Nomenclatura
> - **Logon:** `nome.sobrenome`
> - **Grupos:** `ROLE_<Depto>_<Função>` ou `ACL_<Recurso>_<Permissão>`

---

## 2. Script de Execução (PowerShell)

> [!warning] Pré-requisitos
> 1. Executar como **Domain Admin**.
> 2. Arquivo `C:\Temp\usuarios.csv` deve existir com encoding UTF-8.

```powershell
# SCRIPT: Provisionamento IAM Fiqueok v1.0
# DATA: 2025-12-19

Import-Module ActiveDirectory

$DomainBase = "DC=fiqueok,DC=local"
$CsvPath = "C:\Temp\usuarios.csv"
$DefaultPass = ConvertTo-SecureString "Mudar123!@#" -AsPlainText -Force

# --- [1] Validação de Estrutura ---
$OUs = @("OU=Corp_Users,$DomainBase", "OU=Sec_Groups,$DomainBase")
# (Lógica de validação e criação de OUs aqui...)

# --- [2] Loop de Criação ---
if (Test-Path $CsvPath) {
    $Users = Import-Csv $CsvPath
    foreach ($User in $Users) {
        $Sam = ($User.Nome + "." + $User.Sobrenome).ToLower()
        
        try {
            New-ADUser -Name "$($User.Nome) $($User.Sobrenome)" `
                       -SamAccountName $Sam `
                       -UserPrincipalName "$Sam@fiqueok.local" `
                       -Path "OU=Corp_Users,$DomainBase" `
                       -AccountPassword $DefaultPass `
                       -Enabled $true `
                       -ChangePasswordAtLogon $true
            
            Write-Host "✅ Criado: $Sam" -ForegroundColor Green
        } catch {
            Write-Host "❌ Erro: $_" -ForegroundColor Red
        }
    }
}