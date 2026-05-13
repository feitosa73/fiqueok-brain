$VM_IP = "xxx.xxx.xxx.xxx"
$VM_USER = "paulo"
$COMPOSE_FILE = "docker-compose-4.9.yml"

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   PRE-FLIGHT CHECK: LAB FIQUEOK 2.0 - GMUD-010          " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$Ready = $true

# 1. VALIDAÇÃO LOCAL
Write-Host "[1] Verificando arquivos locais..." -NoNewline
if (Test-Path "./$COMPOSE_FILE") {
    Write-Host " [OK]" -ForegroundColor Green
} else {
    Write-Host " [FALHA] - Arquivo $COMPOSE_FILE não encontrado!" -ForegroundColor Red
    $Ready = $false
}

# 2. VALIDAÇÃO DE CONECTIVIDADE
Write-Host "[2] Testando conexão SSH ($VM_USER@$VM_IP)..." -NoNewline
$sshTest = ssh -o ConnectTimeout=5 -o BatchMode=yes "$VM_USER@$VM_IP" "echo 1" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host " [OK]" -ForegroundColor Green
} else {
    Write-Host " [FALHA] - Não foi possível conectar via SSH." -ForegroundColor Red
    $Ready = $false
}

if ($Ready) {
    # 3. VALIDAÇÃO DE PRIVILÉGIOS DOCKER
    Write-Host "[3] Verificando privilégios Sudo NOPASSWD (Docker)..." -NoNewline
    $sudoTest = ssh "$VM_USER@$VM_IP" "sudo -n docker ps > /dev/null && echo 'OK' || echo 'FAIL'"
    if ($sudoTest -match "OK") {
        Write-Host " [OK]" -ForegroundColor Green
    } else {
        Write-Host " [FALHA] - Sudo exige senha para o Docker!" -ForegroundColor Red
        $Ready = $false
    }

    # 4. VERIFICAÇÃO DE CONFLITOS
    Write-Host "[4] Verificando containers residuais..." -NoNewline
    $containers = ssh "$VM_USER@$VM_IP" "sudo docker ps -a --filter 'name=iga-' --format '{{.Names}}'"
    if ($containers) {
        Write-Host " [AVISO] - Containers antigos detectados: $containers" -ForegroundColor Yellow
        Write-Host "    (O script de deploy irá removê-los automaticamente)" -ForegroundColor Gray
    } else {
        Write-Host " [LIMPO]" -ForegroundColor Green
    }
}

Write-Host "==========================================================" -ForegroundColor Cyan
if ($Ready) {
    Write-Host " RESULTADO: AMBIENTE PRONTO PARA O DEPLOY! " -BackgroundColor Green -ForegroundColor White
    Write-Host " Próximo passo: .\Deploy-Midpoint49-Ajustado.ps1" -ForegroundColor White
} else {
    Write-Host " RESULTADO: AMBIENTE NÃO ESTÁ PRONTO. " -BackgroundColor Red -ForegroundColor White
    Write-Host " Corrija os itens marcados como [FALHA] antes de prosseguir." -ForegroundColor White
}
Write-Host "==========================================================" -ForegroundColor Cyan

Write-Host "`nPressione qualquer tecla para sair..."
$null = [Console]::ReadKey()

