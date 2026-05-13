<#
.SYNOPSIS
    Script de Orquestração para Deploy do midPoint 4.9 + PostgreSQL 16 no Lab Fiqueok 2.0.
    Ajustado para visibilidade total e usuário 'paulo'.
#>

# --- CONFIGURAÇÕES DO AMBIENTE ---
$VM_IP = "xxx.xxx.xxx.xxx"
$VM_USER = "paulo"
$REMOTE_PATH = "/home/paulo/prj003-deploy"
$DOCKER_COMPOSE_FILE = "docker-compose-4.9.yml"
$REPO_PASSWORD = "FiqueokPostgres2026"

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   INICIANDO DEPLOY GMUD-010 (RECOVERY v4.9) - LAB 2.0    " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

try {
    # 1. VERIFICAÇÃO DE ARQUIVOS LOCAIS
    Write-Host "[1/4] Verificando arquivos locais..." -ForegroundColor Yellow
    if (-not (Test-Path "./$DOCKER_COMPOSE_FILE")) {
        throw "ERRO: Arquivo $DOCKER_COMPOSE_FILE não encontrado no diretório atual!"
    }

    # 2. LIMPEZA E PREPARAÇÃO NA VM (VIA SSH)
    Write-Host "[2/4] Preparando ambiente remoto na VM ($VM_IP)..." -ForegroundColor Yellow
    $CleanupCommand = @"
sudo docker compose -f $REMOTE_PATH/$DOCKER_COMPOSE_FILE down -v 2>/dev/null
sudo rm -rf $REMOTE_PATH
mkdir -p $REMOTE_PATH
sudo mkdir -p /srv/prj003/data/postgres /srv/prj003/data/midpoint/var /srv/prj003/logs/midpoint
sudo chown -R 1000:1000 /srv/prj003/data/midpoint/var /srv/prj003/logs/midpoint
sudo chmod -R 775 /srv/prj003/data/midpoint/var
"@
    ssh -o ConnectTimeout=5 "$VM_USER@$VM_IP" $CleanupCommand
    if ($LASTEXITCODE -ne 0) { throw "Falha ao conectar via SSH ou executar comandos de limpeza." }

    # 3. UPLOAD DOS ARQUIVOS (VIA SCP)
    Write-Host "[3/4] Enviando Docker Compose para a VM..." -ForegroundColor Yellow
    scp "./$DOCKER_COMPOSE_FILE" "${VM_USER}@${VM_IP}:${REMOTE_PATH}/"
    if ($LASTEXITCODE -ne 0) { throw "Falha ao enviar arquivo via SCP." }

    # 4. EXECUÇÃO DO DEPLOY (VIA SSH)
    Write-Host "[4/4] Iniciando containers (midPoint 4.9 + PostgreSQL 16)..." -ForegroundColor Yellow
    $DeployCommand = @"
cd $REMOTE_PATH
export REPO_PASSWORD='$REPO_PASSWORD'
sudo docker compose -f $DOCKER_COMPOSE_FILE up -d
"@
    ssh "$VM_USER@$VM_IP" $DeployCommand
    if ($LASTEXITCODE -ne 0) { throw "Falha ao iniciar os containers via Docker Compose." }

    Write-Host "`n==========================================================" -ForegroundColor Green
    Write-Host "   DEPLOY FINALIZADO COM SUCESSO!                         " -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "Aguarde ~2 minutos para o bootstrap inicial."
    Write-Host "Acesse: http://$VM_IP:8080"
    Write-Host "Credenciais: administrator / 5ecr3t"

} catch {
    Write-Host "`n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
    Write-Host "   ERRO DURANTE O DEPLOY:                                 " -ForegroundColor Red
    Write-Host "   $($_.Exception.Message )" -ForegroundColor Red
    Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
}

Write-Host "`nPressione qualquer tecla para fechar esta janela..."
$null = [Console]::ReadKey()

