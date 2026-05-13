# Variáveis — substitua pelos valores reais
$ClientId     = "6df1b421-cf53-41c4-b4aa-9a5d50f65148"
$ClientSecret = "ENb8Q~i5hyurafuA6mqmQxpYqlZM36FZCp4locIP"
$TenantId     = "503bbd0e-f33f-4ebe-b12e-f24a506978c9"

# 1. Obter Token OAuth2
$Body = @{
    client_id     = $ClientId
    client_secret = $ClientSecret
    scope         = "https://graph.microsoft.com/.default"
    grant_type    = "client_credentials"
}

$TokenRequest = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Body $Body
$AccessToken  = $TokenRequest.access_token

if ($AccessToken) {
    Write-Host "✅ Token gerado com sucesso! Tamanho: $($AccessToken.Length)" -ForegroundColor Green
} else {
    Write-Host "❌ Falha ao gerar token." -ForegroundColor Red
    exit
}

# 2. Testar leitura de usuários
$Users = Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/v1.0/users" -Headers @{Authorization = "Bearer $AccessToken"}
Write-Host "Usuários retornados: $($Users.value.Count)" -ForegroundColor Cyan

# 3. Testar leitura de grupos
$Groups = Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/v1.0/groups" -Headers @{Authorization = "Bearer $AccessToken"}
Write-Host "Grupos retornados: $($Groups.value.Count)" -ForegroundColor Cyan

# 4. Evidência — salvar em arquivo de auditoria
$LogPath = "C:\Logs\PRJ012_ATO1_Validation.json"
$Output = @{
    Timestamp   = (Get-Date)
    ClientId    = $ClientId
    TenantId    = $TenantId
    TokenLength = $AccessToken.Length
    UsersCount  = $Users.value.Count
    GroupsCount = $Groups.value.Count
}
$Output | ConvertTo-Json | Out-File $LogPath -Encoding UTF8

Write-Host "📓 Evidência salva em $LogPath" -ForegroundColor Yellow
