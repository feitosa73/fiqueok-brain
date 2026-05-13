<#
.SYNOPSIS
    Orquestrador Profissional de Recovery - GMUD-010
    Projeto: PRJ003 - IGA-GREENFIELD
    Versão: 4.9 (LTS) + PostgreSQL 16
#>

# --- CONFIGURAÇÕES ---
$VM_IP = "xxx.xxx.xxx.xxx"
$VM_USER = "paulo"
$REMOTE_PATH = "/home/paulo/prj003-deploy"
$LOCAL_FILES = @("docker-compose-4.9.yml", "midpoint.env")

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   RECOVERY ORCHESTRATOR v4.9.1 - LAB FIQUEOK 2.0        " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

try {
    # 1. VALIDAÇÃO LOCAL
    Write-Host "[1/5] Validando arquivos locais..." -ForegroundColor Yellow
    foreach ($file in $LOCAL_FILES) {
        if (-not (Test-Path "./$file")) { throw "Arquivo $file não encontrado!" }
    }

    # 2. PREPARAÇÃO REMOTA (Ajustada para privilégios restritos)
    Write-Host "[2/5] Preparando ambiente remoto..." -ForegroundColor Yellow
    $InfraCommands = @"
# Limpeza de containers antigos (Comandos permitidos no seu sudoers)
sudo /usr/bin/docker-compose -f $REMOTE_PATH/docker-compose-4.9.yml down -v 2>/dev/null
sudo /usr/bin/docker rm -f iga-midpoint iga-postgres 2>/dev/null

# Criação da pasta de deploy (Home do usuário, não exige sudo)
mkdir -p $REMOTE_PATH
"@
    ssh -t "${VM_USER}@${VM_IP}" $InfraCommands

    # 3. TRANSPORTE (Correção do erro de Drive do PowerShell)
    Write-Host "[3/5] Transportando pacotes via SCP..." -ForegroundColor Yellow
    scp $LOCAL_FILES "${VM_USER}@${VM_IP}:${REMOTE_PATH}/"
    if ($LASTEXITCODE -ne 0) { throw "Falha no transporte SCP." }

    # 4. DEPLOY
    Write-Host "[4/5] Executando Deploy..." -ForegroundColor Yellow
    $DeployCommand = "cd $REMOTE_PATH && sudo /usr/bin/docker-compose --env-file midpoint.env -f docker-compose-4.9.yml up -d"
    ssh -t "${VM_USER}@${VM_IP}" $DeployCommand

    # 5. MONITORAMENTO DE BOOTSTRAP
    Write-Host "[5/5] Monitorando Bootstrap (Aguarde)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 20
    ssh "${VM_USER}@${VM_IP}" "sudo /usr/bin/docker logs midpoint 2>&1 | grep -i 'Database platform' || echo 'Aguardando logs...'"

    Write-Host "`n==========================================================" -ForegroundColor Green
    Write-Host "   DEPLOY ENVIADO! VERIFIQUE O ACESSO EM BREVE.          " -ForegroundColor Green
    Write-Host "   URL: http://$VM_IP:8080"
    Write-Host "==========================================================" -ForegroundColor Green

} catch {
    Write-Host "`nERRO CRÍTICO: $($_.Exception.Message )" -ForegroundColor Red
}

Write-Host "`nPressione qualquer tecla para sair..."
$null = [Console]::ReadKey()

