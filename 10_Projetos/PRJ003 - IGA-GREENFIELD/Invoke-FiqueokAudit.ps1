<#
.SYNOPSIS
    Script de Auditoria Pré-Publicação - Projeto Fiqueok GRC.
.DESCRIPTION
    Realiza varredura em busca de segredos e IPs reais antes do push para o GitHub.
#>

$Keywords = "password", "secret", "key", "token", "pwd", "credential", "administrator"
$IPRegex  = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'
$Extensions = "*.md", "*.ps1", "*.yml", "*.yaml", "*.sh", "*.env"
$OutputFile = "auditoria_pre_publicacao.csv"

Write-Host "--- Iniciando Auditoria Contínua Fiqueok ---" -ForegroundColor Cyan

$Results = Get-ChildItem -Recurse -Include $Extensions | ForEach-Object {
    $File = $_
    $Content = Get-Content $File.FullName
    
    foreach ($Word in $Keywords) {
        $Matches = $Content | Select-String -Pattern $Word
        foreach ($Match in $Matches) {
            [PSCustomObject]@{
                Arquivo = $File.Name
                Linha   = $Match.LineNumber
                Tipo    = "Keyword ($Word)"
                Trecho  = $Match.Line.Trim()
            }
        }
    }

    $IPMatches = $Content | Select-String -Pattern $IPRegex -AllMatches
    foreach ($IPMatch in $IPMatches.Matches) {
        [PSCustomObject]@{
            Arquivo = $File.Name
            Linha   = $IPMatches.LineNumber
            Tipo    = "IP Address"
            Trecho  = $IPMatch.Value
        }
    }
}

if ($Results) {
    $Results | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding utf8
    Write-Host "[ALERTA] Auditoria concluída. Achados registrados em: $OutputFile" -ForegroundColor Yellow
} else {
    Write-Host "[SUCESSO] Ambiente sanitizado. Pronto para publicação." -ForegroundColor Green
}