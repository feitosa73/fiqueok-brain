# <REDACTED_SECRET>======================================
# AUDITORIA: BASELINE INICIAL (AS-IS)
# DATA: 19/12/2025
# <REDACTED_SECRET>======================================

$ReportFile = "C:\Temp\Auditoria_AS_IS_$(Get-Date -Format 'yyyyMMdd').txt"

Start-Transcript -Path $ReportFile -Append

Write-Host ">>> RELATÓRIO DE ESTRUTURA ATUAL (AS-IS) <<<" -ForegroundColor Cyan
Write-Host "Data da Coleta: $(Get-Date)"
Write-Host "---------------------------------------------------"

# 1. Contagem de Objetos na Raiz Padrão (O "Sintoma do Caos")
$DefaultUsers = Get-ADUser -Filter * -SearchBase "CN=Users,DC=fiqueok,DC=local" -ErrorAction SilentlyContinue
Write-Host "1. ANÁLISE DO CONTAINER PADRÃO 'CN=Users'"
Write-Host "   Total de Usuários Misturados na Raiz: $($DefaultUsers.Count)" 
if ($DefaultUsers.Count -gt 0) {
    Write-Host "   [ALERTA] Usuários encontrados fora de OUs gerenciadas. Risco de falta de GPO." -ForegroundColor Red
}

Write-Host "`n---------------------------------------------------"

# 2. Listagem de OUs Existentes
Write-Host "2. ESTRUTURA DE OUS ATUAL"
$OUs = Get-ADOrganizationalUnit -Filter * | Sort-Object DistinguishedName
if ($OUs) {
    $OUs | Select-Object Name, DistinguishedName | Format-Table -AutoSize
} else {
    Write-Host "   [CRÍTICO] Nenhuma OU encontrada. Ambiente operando em modo Flat (Padrão Windows)." -ForegroundColor Yellow
}

Write-Host "---------------------------------------------------"
Write-Host ">>> FIM DO RELATÓRIO <<<"
Stop-Transcript

Write-Host "Relatório gerado em: $ReportFile" -ForegroundColor Green
Invoke-Item $ReportFile
