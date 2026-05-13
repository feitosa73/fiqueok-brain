# PRJ011 - Provisionamento Massivo v2 (Resiliente)
$CSVPath = "C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\fiqueok_entraid_users.csv"
$Users = Import-Csv $CSVPath -Encoding UTF8

if (!(Get-MgContext)) { Connect-MgGraph -Scopes "User.ReadWrite.All" }

foreach ($User in $Users) {
    $MailNick = $User.UserPrincipalName.Split('@')[0]
    
    $UserParams = @{
        DisplayName           = $User.DisplayName
        UserPrincipalName     = $User.UserPrincipalName
        MailNickname          = $MailNick
        AccountEnabled        = $true
        PasswordProfile       = @{ Password = "Fiqueok@2026!"; ForceChangePasswordNextSignIn = $true }
        JobTitle              = $User.JobTitle
        Department            = $User.Department
        EmployeeId            = $User.EmployeeID
        OnPremisesImmutableId = $User.EmployeeID
    }

    try {
        # Usando o parâmetro explícito de PasswordProfile para evitar o erro 405
        New-MgUser -BodyParameter $UserParams
        Write-Host "[SUCCESS] $($User.EmployeeID): $($User.UserPrincipalName)" -ForegroundColor Green
    }
    catch {
        if ($_.Exception.Message -match "already exists") {
            Write-Host "[SKIP] $($User.UserPrincipalName) já existe." -ForegroundColor Yellow
        } else {
            Write-Host "[ERROR] $($User.UserPrincipalName): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}