$VM_IP = "xxx.xxx.xxx.xxx"
$VM_USER = "paulo"
$REMOTE_PATH = "/home/paulo/prj003-deploy"
$LOCAL_FILES = @("docker-compose-4.9.yml", "midpoint.env")

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   RECOVERY ORCHESTRATOR v4.9.2 - FINAL CHECK            " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

try {
    # 1. Validação Local
    if (-not (Test-Path "./docker-compose-4.9.yml")) { throw "Arquivo docker-compose-4.9.yml ausente." }
    if (-not (Test-Path "./midpoint.env")) { throw "Arquivo midpoint.env ausente." }

    # 2. Preparação e Limpeza (Usando binários permitidos no seu sudo -l)
    Write-Host "[1/3] Limpando ambiente e preparando pastas..." -ForegroundColor Yellow
    $PreCmd = "sudo /usr/bin/docker compose -f ${REMOTE_PATH}/docker-compose-4.9.yml down -v 2>/dev/null; mkdir -p ${REMOTE_PATH}"
    ssh -t "${VM_USER}@${VM_IP}" $PreCmd

    # 3. Transporte e Deploy
    Write-Host "[2/3] Transportando arquivos e iniciando containers..." -ForegroundColor Yellow
    scp $LOCAL_FILES "${VM_USER}@${VM_IP}:${REMOTE_PATH}/"
    
    $DeployCmd = "cd ${REMOTE_PATH} && sudo /usr/bin/docker compose --env-file midpoint.env -f docker-compose-4.9.yml up -d"
    ssh -t "${VM_USER}@${VM_IP}" $DeployCmd

    # 4. Validação de Saúde
    Write-Host "[3/3] Validando Bootstrap..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    ssh "${VM_USER}@${VM_IP}" "sudo /usr/bin/docker logs midpoint 2>&1 | grep -i 'Database platform' || echo 'Bootstrap em andamento...'"

    Write-Host "`n==========================================================" -ForegroundColor Green
    Write-Host "   DEPLOY EXECUTADO COM SUCESSO!                         " -ForegroundColor Green
    Write-Host "   URL: http://${VM_IP}:8080"
    Write-Host "==========================================================" -ForegroundColor Green

} catch {
    Write-Host "`nERRO: $($_.Exception.Message )" -ForegroundColor Red
}

Write-Host "`nPressione ENTER para fechar..."
Read-Host

