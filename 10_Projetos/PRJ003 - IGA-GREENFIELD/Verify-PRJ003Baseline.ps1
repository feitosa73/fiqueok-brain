# ============================================================================
# AUDITORIA DE BASELINE - PRJ003 GREENFIELD (Versao Sem Acentos)
# Objetivo: Validar arquivos para a GMUD-013 (Encerramento e Publicacao)
# ============================================================================

$reportFile = "Auditoria_PRJ003_Pre_Push.txt"
$report = "--- RELATORIO DE AUDITORIA DE INFRAESTRUTURA (PRJ003) ---`n"
$report += "Data: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')`n`n"

$filesToVerify = @("docker-compose.yml", ".env", "postgres.sql", "postgres-audit.sql", "postgres-quartz.sql")

Write-Host "Iniciando validacao de Baseline..." -ForegroundColor Cyan

foreach ($file in $filesToVerify) {
    if (Test-Path $file) {
        $report += "[OK] Arquivo encontrado: $file`n"
        $content = Get-Content $file -Raw

        # Validacao especifica: docker-compose.yml
        if ($file -eq "docker-compose.yml") {
            if ($content -match '\$\{') {
                $report += "   - Check: Variaveis de ambiente detectadas (${...})`n"
            } else {
                $report += "   - [ERRO]: O Compose parece conter senhas fixas (hardcoded)!`n"
            }
        }

        # Validacao especifica: .env
        if ($file -eq ".env") {
            $requiredKeys = @("DB_PASSWORD", "MP_KEYSTORE_PASSWORD", "MP_ADMIN_PASSWORD")
            foreach ($key in $requiredKeys) {
                if ($content -match $key) {
                    $report += "   - Check: Chave $key presente`n"
                } else {
                    $report += "   - [ERRO]: Chave $key AUSENTE no arquivo .env`n"
                }
            }
        }

        # Validacao especifica: postgres.sql (Versao do Schema)
        if ($file -eq "postgres.sql") {
            if ($content -match "Change #51") {
                $report += "   - Check: Versao do Schema confirmada como v51 (midPoint 4.10)`n"
            } else {
                $report += "   - [AVISO]: Marcador 'Change #51' nao encontrado. Verifique o SQL!`n"
            }
        }
    } else {
        $report += "[ERRO CRITICO] Arquivo NAO encontrado: $file`n"
        Write-Host "Falha ao localizar $file" -ForegroundColor Red
    }
}

$report += "`n--- FIM DO RELATORIO ---"
$report | Out-File -FilePath $reportFile -Encoding UTF8
Write-Host "Relatorio gerado com sucesso: $reportFile" -ForegroundColor Green