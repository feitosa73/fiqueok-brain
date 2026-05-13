# 📋 Procedimento de Inicialização do LAB - Cold Start Diário

**Status:** Ativo  
**Versão:** 1.7  
**Data de atualização:** 30/12/2025 14:03  
**Tipo:** POP - Procedimento Operacional Padrão  
**Owner:** Paulo Feitosa  
**Frequência:** Diária - antes de qualquer atividade no LAB  

**Changelog v1.7:**
- 🔧 **CORREÇÃO:** Seção 6.2 ajustada para refletir validação genérica de inventário (não análise pontual)
- ✅ Removida referência específica ao status "Unmatched" do registro 0001 (contexto transitório)
- ✅ Substituída por validação de sincronização e visibilidade de contas no inventário

---

## 🎯 Objetivo

Garantir que o ambiente de laboratório PRJ001 (AD DS + midPoint + OrangeHRM) esteja íntegro, operacional e no estado de referência esperado antes de iniciar qualquer atividade de configuração, teste, GMUD ou experimento de GRC/IGA.

---

## 📋 Pré-requisitos do Técnico

- Acesso físico ou RDP ao PC Host Hyper-V (Windows 11 Pro)
- **Perfil de usuário do LAB:** Fiqueok
- **Usuário admin local:** Win (para tarefas administrativas)
- Credenciais de administrador do midPoint (usuário `administrator` ou break-glass)
- Credenciais de administrador do OrangeHRM e do AD DS
- Acesso ao vault de senhas da Fiqueok (Obsidian ou gerenciador de senhas)

---

## 🚀 Procedimento de Inicialização

### 0️⃣ Iniciar Host e Verificações Básicas

#### 0.1. Ligar e acessar o host
- [ ] Ligar o PC Host (Hyper-V)
- [ ] Fazer login no Windows 11 Pro com o perfil **Fiqueok**
- [ ] Registrar horário de início: `______:______`

> 💡 **Nota:** Para tarefas administrativas que exigem elevação de privilégios, use o usuário **Win** quando solicitado pelo UAC.

#### 0.2. Teste automatizado de conectividade e configuração de rede

Abrir **PowerShell como Administrador** (usuário **Win** se solicitado) e executar:

```powershell
# ===== SCRIPT DE VALIDAÇÃO DE PRÉ-REQUISITOS DE REDE =====
# Versão: 1.2 - Cold Start LAB Fiqueok
# Data: 30/12/2025

Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  VALIDAÇÃO DE PRÉ-REQUISITOS - LAB FIQUEOK            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$erros = @()

# [1/4] Teste de conectividade com Internet
Write-Host "[1/4] Testando conectividade com Internet (8.8.8.8)..." -ForegroundColor Yellow
$testInternet = Test-NetConnection -ComputerName 8.8.8.8 -InformationLevel Quiet -WarningAction SilentlyContinue
if ($testInternet) {
    Write-Host "      ✓ Conectividade com Internet: OK" -ForegroundColor Green
} else {
    Write-Host "      ✗ Conectividade com Internet: FALHOU" -ForegroundColor Red
    $erros += "Internet"
}

# [2/4] Teste de resolução DNS
Write-Host "`n[2/4] Testando resolução DNS (www.google.com)..." -ForegroundColor Yellow
$testDNS = Test-NetConnection -ComputerName www.google.com -InformationLevel Quiet -WarningAction SilentlyContinue
if ($testDNS) {
    Write-Host "      ✓ Resolução DNS: OK" -ForegroundColor Green
} else {
    Write-Host "      ✗ Resolução DNS: FALHOU" -ForegroundColor Red
    $erros += "DNS"
}

# [3/4] Validação de IP da VLAN 1
Write-Host "`n[3/4] Validando IP da VLAN 1 (xxx.xxx.xxx.xxx/16)..." -ForegroundColor Yellow
$ipVLAN1 = Get-NetIPAddress | Where-Object {$_.IPAddress -like "172.16.*" -and $_.AddressFamily -eq "IPv4"}
if ($ipVLAN1) {
    Write-Host "      ✓ IP VLAN 1 encontrado: $($ipVLAN1.IPAddress) ($($ipVLAN1.InterfaceAlias))" -ForegroundColor Green
} else {
    Write-Host "      ✗ IP VLAN 1 não encontrado (esperado xxx.xxx.xxx.xxx)" -ForegroundColor Red
    $erros += "VLAN1_IP"
}

# [4/4] Validação de adaptador vSwitch FiqueokCorp
Write-Host "`n[4/4] Verificando adaptador vSwitch FiqueokCorp..." -ForegroundColor Yellow
$vSwitch = Get-NetAdapter | Where-Object {$_.Name -like "*vEthernet*" -or $_.InterfaceDescription -like "*Hyper-V*"}
if ($vSwitch) {
    Write-Host "      ✓ Adaptador Hyper-V encontrado: $($vSwitch.Name)" -ForegroundColor Green
} else {
    Write-Host "      ⚠ Adaptador Hyper-V não identificado claramente" -ForegroundColor Yellow
}

# Resultado final
Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
if ($erros.Count -eq 0) {
    Write-Host "║  ✓✓✓ TESTE DE CONECTIVIDADE: OK ✓✓✓                  ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
} else {
    Write-Host "║  ✗✗✗ TESTE DE CONECTIVIDADE: FALHOU ✗✗✗              ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

    Write-Host "`n⚠️  TROUBLESHOOTING NECESSÁRIO:" -ForegroundColor Yellow
    Write-Host "───────────────────────────────────────────────────────" -ForegroundColor Yellow

    if ($erros -contains "Internet") {
        Write-Host "• Internet: Verifique cabo de rede ou adaptador físico" -ForegroundColor White
        Write-Host "  Comando: Get-NetAdapter | Where-Object {`$_.Status -eq 'Up'}" -ForegroundColor Gray
    }
    if ($erros -contains "DNS") {
        Write-Host "• DNS: Verifique configuração de DNS nos adaptadores de rede" -ForegroundColor White
        Write-Host "  Comando: Get-DnsClientServerAddress" -ForegroundColor Gray
    }
    if ($erros -contains "VLAN1_IP") {
        Write-Host "• VLAN 1: IP xxx.xxx.xxx.xxx não encontrado - verificar configuração vSwitch" -ForegroundColor White
        Write-Host "  Comando: Get-NetIPAddress | Format-Table IPAddress, InterfaceAlias" -ForegroundColor Gray
        Write-Host "  Ação: Painel de Controle → Rede → Propriedades TCP/IPv4 do vSwitch" -ForegroundColor Gray
    }

    Write-Host "`n❌ RECOMENDAÇÃO: Corrija os erros antes de prosseguir com o Cold Start" -ForegroundColor Red
}
```

- [ ] Confirmar mensagem final: **"✓✓✓ TESTE DE CONECTIVIDADE: OK ✓✓✓"**
- [ ] Se houver falhas, seguir troubleshooting sugerido pelo script

---

### 1️⃣ Inicializar VM do Domain Controller (ID-P-01)

> ⚠️ **CRÍTICO:** O AD DS deve estar operacional ANTES de subir qualquer serviço de IGA.

#### 1.1. Subir a VM do AD DS no Hyper-V
- [ ] Abrir **Hyper-V Manager**
- [ ] Localizar VM **ID-P-01** (Windows Server 2022 - AD DS)
- [ ] Se estiver desligada: clicar com botão direito → **Start**
- [ ] Aguardar inicialização completa (cerca de 2-3 minutos)

#### 1.2. Validar serviços do AD DS

No **PowerShell como Administrador** (usuário **Win**), executar:

```powershell
# ===== SCRIPT DE VALIDAÇÃO DO AD DS (ID-P-01) =====
# Versão: 1.2 - Cold Start LAB Fiqueok
# Data: 30/12/2025

Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  VALIDAÇÃO DO ACTIVE DIRECTORY (ID-P-01)              ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$errosAD = @()
$ipDC = "xxx.xxx.xxx.xxx"
$dominio = "corp.fiqueok.com.br"

# [1/4] Teste de conectividade básica (ICMP)
Write-Host "[1/4] Testando conectividade ICMP com DC ($ipDC)..." -ForegroundColor Yellow
$testPing = Test-Connection -ComputerName $ipDC -Count 2 -Quiet -ErrorAction SilentlyContinue
if ($testPing) {
    Write-Host "      ✓ Ping para DC: OK" -ForegroundColor Green
} else {
    Write-Host "      ✗ Ping para DC: FALHOU" -ForegroundColor Red
    $errosAD += "PING"
}

# [2/4] Teste de porta LDAP (389)
Write-Host "`n[2/4] Testando porta LDAP (389)..." -ForegroundColor Yellow
$testLDAP = Test-NetConnection -ComputerName $ipDC -Port 389 -WarningAction SilentlyContinue -InformationLevel Quiet
if ($testLDAP) {
    Write-Host "      ✓ Porta LDAP (389): ABERTA" -ForegroundColor Green
} else {
    Write-Host "      ✗ Porta LDAP (389): FECHADA ou INACESSÍVEL" -ForegroundColor Red
    $errosAD += "LDAP"
}

# [3/4] Teste de resolução DNS do domínio
Write-Host "`n[3/4] Testando resolução DNS do domínio ($dominio)..." -ForegroundColor Yellow
$testDNSDomain = Resolve-DnsName -Name $dominio -Server $ipDC -ErrorAction SilentlyContinue
if ($testDNSDomain) {
    Write-Host "      ✓ Resolução DNS do domínio: OK" -ForegroundColor Green
    Write-Host "      └─ Resolvido para: $($testDNSDomain[0].IPAddress)" -ForegroundColor Gray
} else {
    Write-Host "      ✗ Resolução DNS do domínio: FALHOU" -ForegroundColor Red
    $errosAD += "DNS_DOMAIN"
}

# [4/4] Teste de porta LDAPS (636) - Opcional
Write-Host "`n[4/4] Testando porta LDAPS (636) - Opcional..." -ForegroundColor Yellow
$testLDAPS = Test-NetConnection -ComputerName $ipDC -Port 636 -WarningAction SilentlyContinue -InformationLevel Quiet
if ($testLDAPS) {
    Write-Host "      ✓ Porta LDAPS (636): ABERTA (certificado configurado)" -ForegroundColor Green
} else {
    Write-Host "      ⚠ Porta LDAPS (636): FECHADA (normal se PKI ainda não implementada)" -ForegroundColor Yellow
}

# Resultado final
Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
if ($errosAD.Count -eq 0) {
    Write-Host "║  ✓✓✓ VALIDAÇÃO AD DS: OK ✓✓✓                         ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
} else {
    Write-Host "║  ✗✗✗ VALIDAÇÃO AD DS: FALHOU ✗✗✗                     ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

    Write-Host "`n🚫 PONTO DE BLOQUEIO CRÍTICO ATIVADO" -ForegroundColor Red -BackgroundColor Black
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "⛔ O AD DS (xxx.xxx.xxx.xxx) NÃO ESTÁ RESPONDENDO CORRETAMENTE" -ForegroundColor Red
    Write-Host "⛔ PARAR IMEDIATAMENTE - NÃO PROSSEGUIR PARA ETAPAS DE IGA" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Red

    Write-Host "⚠️  TROUBLESHOOTING NECESSÁRIO:" -ForegroundColor Yellow
    Write-Host "───────────────────────────────────────────────────────" -ForegroundColor Yellow

    if ($errosAD -contains "PING") {
        Write-Host "• PING falhou:" -ForegroundColor White
        Write-Host "  └─ Verifique se a VM ID-P-01 está realmente ligada no Hyper-V" -ForegroundColor Gray
        Write-Host "  └─ Verifique se o IP xxx.xxx.xxx.xxx está configurado no servidor" -ForegroundColor Gray
        Write-Host "  └─ Aguarde mais 1-2 minutos (servidor pode estar finalizando boot)" -ForegroundColor Gray
    }
    if ($errosAD -contains "LDAP") {
        Write-Host "• Porta LDAP (389) inacessível:" -ForegroundColor White
        Write-Host "  └─ Verifique se o serviço 'Active Directory Domain Services' está rodando" -ForegroundColor Gray
        Write-Host "  └─ No servidor, execute: Get-Service NTDS | Select-Object Status" -ForegroundColor Gray
        Write-Host "  └─ Verifique logs do Event Viewer: Directory Service" -ForegroundColor Gray
    }
    if ($errosAD -contains "DNS_DOMAIN") {
        Write-Host "• Resolução DNS do domínio falhou:" -ForegroundColor White
        Write-Host "  └─ Verifique se o serviço DNS está rodando no DC" -ForegroundColor Gray
        Write-Host "  └─ No servidor, execute: Get-Service DNS | Select-Object Status" -ForegroundColor Gray
        Write-Host "  └─ Verifique zona corp.fiqueok.com.br no DNS Manager" -ForegroundColor Gray
    }

    Write-Host "`n📋 AÇÃO OBRIGATÓRIA:" -ForegroundColor Yellow
    Write-Host "   1. Registrar RNC (Relatório de Não-Conformidade)" -ForegroundColor White
    Write-Host "   2. Investigar causa raiz dos erros listados acima" -ForegroundColor White
    Write-Host "   3. Corrigir problemas antes de continuar o Cold Start" -ForegroundColor White
    Write-Host "   4. Não inicializar serviços de IGA enquanto AD DS estiver falho`n" -ForegroundColor White
}
```

- [ ] Confirmar mensagem final: **"✓✓✓ VALIDAÇÃO AD DS: OK ✓✓✓"**
- [ ] Se falhar, **PARAR IMEDIATAMENTE** e seguir troubleshooting

> 🚫 **PONTO DE BLOQUEIO CRÍTICO:** Se o AD DS não responder, registrar RNC e NÃO prosseguir para etapas de IGA.

---

### 2️⃣ Inicializar VM IGA-P-01 (Ubuntu 22.04 - Docker Host)

#### 2.1. Subir a VM no Hyper-V
- [ ] No **Hyper-V Manager**, localizar VM **IGA-P-01** (Ubuntu 22.04)
- [ ] Se estiver desligada: clicar com botão direito → **Start**
- [ ] Aguardar inicialização completa (cerca de 1-2 minutos)

#### 2.2. Acessar console e validar rede

- [ ] Clicar com botão direito em **IGA-P-01** → **Connect…**
- [ ] Fazer login no Ubuntu com conta administrativa do Docker Host

No terminal do Ubuntu, executar:

```bash
#!/bin/bash
# ===== SCRIPT DE VALIDAÇÃO DE REDE - VM IGA-P-01 =====
# Versão: 1.2 - Cold Start LAB Fiqueok
# Data: 30/12/2025

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║  VALIDAÇÃO DE REDE - VM IGA-P-01 (Ubuntu 22.04)       ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

ERROS=0
IP_ESPERADO="xxx.xxx.xxx.xxx"
IP_DC="xxx.xxx.xxx.xxx"

# [1/3] Validar IP da VM
echo "[1/3] Validando IP da VM (esperado: $IP_ESPERADO)..."
IP_ATUAL=$(ip -4 addr show | grep "172.16." | awk '{print $2}' | cut -d'/' -f1)

if [ "$IP_ATUAL" == "$IP_ESPERADO" ]; then
    echo -e "      [32m✓ IP da VM: $IP_ATUAL (OK)[0m"
else
    if [ -z "$IP_ATUAL" ]; then
        echo -e "      [31m✗ IP da VM: NÃO ENCONTRADO (esperado $IP_ESPERADO)[0m"
    else
        echo -e "      [33m⚠ IP da VM: $IP_ATUAL (diferente do esperado $IP_ESPERADO)[0m"
    fi
    ERROS=$((ERROS + 1))
fi

# [2/3] Testar conectividade com AD DS
echo ""
echo "[2/3] Testando conectividade com AD DS ($IP_DC)..."
if ping -c 2 -W 2 $IP_DC > /dev/null 2>&1; then
    echo -e "      [32m✓ Ping para AD DS: OK[0m"
else
    echo -e "      [31m✗ Ping para AD DS: FALHOU[0m"
    ERROS=$((ERROS + 1))
fi

# [3/3] Testar loopback local
echo ""
echo "[3/3] Testando loopback local ($IP_ESPERADO)..."
if ping -c 2 -W 2 $IP_ESPERADO > /dev/null 2>&1; then
    echo -e "      [32m✓ Loopback local: OK[0m"
else
    echo -e "      [31m✗ Loopback local: FALHOU[0m"
    ERROS=$((ERROS + 1))
fi

# Resultado final
echo ""
echo "╔════════════════════════════════════════════════════════╗"
if [ $ERROS -eq 0 ]; then
    echo -e "║  [32m✓✓✓ TESTE DE CONECTIVIDADE: OK ✓✓✓[0m                  ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
else
    echo -e "║  [31m✗✗✗ TESTE DE CONECTIVIDADE: FALHOU ✗✗✗[0m              ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "[33m⚠️  TROUBLESHOOTING NECESSÁRIO:[0m"
    echo "───────────────────────────────────────────────────────"

    if [ -z "$IP_ATUAL" ] || [ "$IP_ATUAL" != "$IP_ESPERADO" ]; then
        echo "• IP incorreto ou ausente:"
        echo "  └─ Verificar configuração Netplan: /etc/netplan/*.yaml"
        echo "  └─ Comando: sudo cat /etc/netplan/*.yaml"
        echo "  └─ Reconfigurar se necessário e aplicar: sudo netplan apply"
    fi

    if ! ping -c 1 -W 2 $IP_DC > /dev/null 2>&1; then
        echo "• Ping para AD DS falhou:"
        echo "  └─ Verificar se VM ID-P-01 está ligada e operacional"
        echo "  └─ Verificar configuração de vSwitch no Hyper-V (VLAN 1)"
        echo "  └─ Testar conectividade do host: ping xxx.xxx.xxx.xxx"
    fi

    echo ""
    echo -e "[31m❌ RECOMENDAÇÃO: Corrija os erros antes de iniciar serviços Docker[0m"
    echo ""
fi
```

- [ ] Confirmar mensagem final: **"✓✓✓ TESTE DE CONECTIVIDADE: OK ✓✓✓"**
- [ ] Se houver falhas, seguir troubleshooting sugerido pelo script

---

### 3️⃣ Verificar e Inicializar Bancos de Dados (Docker Containers)

> 📌 **ORDEM CRÍTICA:** Bancos de dados devem estar ativos **ANTES** das aplicações midPoint e OrangeHRM. Se o midPoint subir sem repositório, entrará em modo de falha e exigirá restart.

#### 3.1. Contexto de arquitetura

**Configuração REAL do LAB (identificada em 30/12/2025):**
- **PostgreSQL 16** roda como **container Docker** → `midpoint-db`
- **MariaDB 11.4** roda como **container Docker** → `orangehrm-db`

#### 3.2. Verificar status dos bancos de dados (Script Docker)

No terminal do Ubuntu (VM IGA-P-01), executar:




**Checklist após executar o script:**

- [ ] Se mensagem for **"✓✓✓ BANCOS DE DADOS: OK ✓✓✓"** → Containers já rodando, prosseguir para seção 4
- [ ] Se mensagem for **"Containers de banco iniciados com sucesso"** → Inicialização concluída, prosseguir para seção 4
- [ ] Se houver **ERRO CRÍTICO** → Seguir troubleshooting e registrar RNC

> 🚫 **PONTO DE BLOQUEIO:** Se containers de banco falharem, **NÃO prosseguir** para aplicações.

---

### 4️⃣ Verificar e Inicializar Containers de Aplicação (midPoint + OrangeHRM)

> 📌 **Contexto:** midPoint 4.10 e OrangeHRM 5.8 rodam containerizados sobre Docker no host IGA-P-01, integrando-se através de redes Docker específicas (midpointlabnet, orangehrmlabnet e fiqueok-backend-net).

#### 4.1. Verificar status dos containers de aplicação (Script inteligente - v1.6)

No terminal do Ubuntu (VM IGA-P-01), executar:

```bash
#!/bin/bash
# ===== SCRIPT DE VERIFICAÇÃO E INICIALIZAÇÃO DE APLICAÇÕES (DOCKER) =====
# Versão: 1.6 - Cold Start LAB Fiqueok
# Data: 30/12/2025 13:46
# CORREÇÃO CRÍTICA: Paths e nomes de containers validados em tempo de execução

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║  VERIFICAÇÃO DE CONTAINERS DE APLICAÇÃO - IGA-P-01    ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

PRECISA_INICIAR=0
ERRO_CRITICO=0

# ========== CONFIGURAÇÕES VALIDADAS EM TEMPO DE EXECUÇÃO (30/12/2025 13:46) ==========
DIRETORIO_STACK="/home/paulo/midpoint_lab"
CONTAINER_MIDPOINT="midpoint-server"
CONTAINER_ORANGEHRM="orangehrm-app"

# ========== VERIFICAÇÃO MIDPOINT 4.10 ==========
echo "[1/2] Verificando container: $CONTAINER_MIDPOINT (midPoint 4.10)..."

# Verificar se o container existe
if sudo docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_MIDPOINT}$"; then
    # Container existe, verificar se está rodando
    if [ "$(sudo docker inspect -f '{{.State.Running}}' $CONTAINER_MIDPOINT 2>/dev/null)" == "true" ]; then
        echo -e "      [32m✓ Container $CONTAINER_MIDPOINT: RODANDO[0m"

        # Verificação adicional: porta 8080 exposta
        PORTA_8080=$(sudo docker port $CONTAINER_MIDPOINT 2>/dev/null | grep 8080)
        if [ -n "$PORTA_8080" ]; then
            echo -e "      [32m✓ Porta 8080: EXPOSTA ($PORTA_8080)[0m"
        else
            echo -e "      [33m⚠ Porta 8080: Não detectada (verificar mapeamento)[0m"
        fi

        # Verificar saúde do container (se healthcheck configurado)
        HEALTH=$(sudo docker inspect -f '{{.State.Health.Status}}' $CONTAINER_MIDPOINT 2>/dev/null)
        if [ "$HEALTH" == "healthy" ]; then
            echo -e "      [32m✓ Health check: HEALTHY[0m"
        elif [ "$HEALTH" == "starting" ]; then
            echo -e "      [33m⚠ Health check: STARTING (aguardando estabilização)[0m"
        fi
    else
        echo -e "      [33m⚠ Container $CONTAINER_MIDPOINT: PARADO (será iniciado)[0m"
        PRECISA_INICIAR=1
    fi
else
    echo -e "      [31m✗ Container $CONTAINER_MIDPOINT: NÃO ENCONTRADO[0m"
    echo -e "      [31m  └─ Será criado via docker-compose up[0m"
    PRECISA_INICIAR=1
fi

echo ""

# ========== VERIFICAÇÃO ORANGEHRM 5.8 ==========
echo "[2/2] Verificando container: $CONTAINER_ORANGEHRM (OrangeHRM 5.8)..."

# Verificar se o container existe
if sudo docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_ORANGEHRM}$"; then
    # Container existe, verificar se está rodando
    if [ "$(sudo docker inspect -f '{{.State.Running}}' $CONTAINER_ORANGEHRM 2>/dev/null)" == "true" ]; then
        echo -e "      [32m✓ Container $CONTAINER_ORANGEHRM: RODANDO[0m"

        # Verificação adicional: porta 8081 exposta
        PORTA_8081=$(sudo docker port $CONTAINER_ORANGEHRM 2>/dev/null | grep 8081)
        if [ -n "$PORTA_8081" ]; then
            echo -e "      [32m✓ Porta 8081: EXPOSTA ($PORTA_8081)[0m"
        else
            echo -e "      [33m⚠ Porta 8081: Não detectada (verificar mapeamento)[0m"
        fi

        # Verificar saúde do container (se healthcheck configurado)
        HEALTH=$(sudo docker inspect -f '{{.State.Health.Status}}' $CONTAINER_ORANGEHRM 2>/dev/null)
        if [ "$HEALTH" == "healthy" ]; then
            echo -e "      [32m✓ Health check: HEALTHY[0m"
        elif [ "$HEALTH" == "starting" ]; then
            echo -e "      [33m⚠ Health check: STARTING (aguardando estabilização)[0m"
        fi
    else
        echo -e "      [33m⚠ Container $CONTAINER_ORANGEHRM: PARADO (será iniciado)[0m"
        PRECISA_INICIAR=1
    fi
else
    echo -e "      [31m✗ Container $CONTAINER_ORANGEHRM: NÃO ENCONTRADO[0m"
    echo -e "      [31m  └─ Será criado via docker-compose up[0m"
    PRECISA_INICIAR=1
fi

echo ""
echo "╔════════════════════════════════════════════════════════╗"

# ========== DECISÃO: INICIAR OU NOTIFICAR OK ==========
if [ $PRECISA_INICIAR -eq 0 ]; then
    # TODOS OS CONTAINERS JÁ RODANDO
    echo -e "║  [32m✓✓✓ CONTAINERS DE APLICAÇÃO: OK ✓✓✓[0m               ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "[32m✅ Containers $CONTAINER_MIDPOINT e $CONTAINER_ORANGEHRM já estão rodando.[0m"
    echo -e "[32m✅ Nenhuma ação de inicialização necessária.[0m"
    echo ""
    echo -e "[36m➜ Próximo passo: Testes de acesso às aplicações (Seção 5)[0m"
    echo ""

else
    # PRECISA INICIAR UM OU MAIS CONTAINERS
    echo -e "║  [33m⚠⚠⚠ CONTAINERS INATIVOS - INICIANDO STACK... ⚠⚠⚠[0m  ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "[33m⚙️  Um ou mais containers estão inativos. Iniciando stack via docker-compose...[0m"
    echo ""

    # Verificar se diretório do stack existe
    if [ ! -d "$DIRETORIO_STACK" ]; then
        echo -e "[31m✗ ERRO: Diretório $DIRETORIO_STACK não encontrado[0m"
        echo -e "[31m  └─ Path validado: $DIRETORIO_STACK[0m"
        echo -e "[31m  └─ Verificar se path está correto ou executar: find ~ -name docker-compose.yml[0m"
        echo ""
        exit 1
    fi

    # Navegar para diretório do stack
    cd "$DIRETORIO_STACK" || exit 1
    echo -e "[36m[→] Navegando para: $DIRETORIO_STACK[0m"

    # Verificar se docker-compose.yml existe
    if [ ! -f "docker-compose.yml" ]; then
        echo -e "[31m✗ ERRO: Arquivo docker-compose.yml não encontrado em $DIRETORIO_STACK[0m"
        echo ""
        exit 1
    fi

    echo -e "[36m[→] Executando: docker compose up -d[0m"
    echo ""

    # Executar docker-compose up -d
    sudo docker compose up -d

    echo ""
    echo -e "[36m[→] Aguardando estabilização dos containers (15 segundos)...[0m"
    sleep 15

    echo ""
    echo "╔════════════════════════════════════════════════════════╗"

    # Verificação final após inicialização
    MIDPOINT_OK=$([ "$(sudo docker inspect -f '{{.State.Running}}' $CONTAINER_MIDPOINT 2>/dev/null)" == "true" ] && echo "1" || echo "0")
    ORANGEHRM_OK=$([ "$(sudo docker inspect -f '{{.State.Running}}' $CONTAINER_ORANGEHRM 2>/dev/null)" == "true" ] && echo "1" || echo "0")

    if [ "$MIDPOINT_OK" == "1" ] && [ "$ORANGEHRM_OK" == "1" ]; then
        echo -e "║  [32m✓✓✓ CONTAINERS DE APLICAÇÃO: OK ✓✓✓[0m               ║"
        echo "╚════════════════════════════════════════════════════════╝"
        echo ""
        echo -e "[32m✅ Stack IGA iniciado com sucesso![0m"
        echo ""
        echo -e "[36m📊 Status dos containers:[0m"
        sudo docker ps --filter "name=$CONTAINER_MIDPOINT" --filter "name=$CONTAINER_ORANGEHRM" --format "table {{.Names}}	{{.Status}}	{{.Ports}}"
        echo ""
        echo -e "[33m⏱️  IMPORTANTE: midPoint leva 2-3 minutos para inicializar o Tomcat embarcado.[0m"
        echo -e "[33m   Aguarde antes de testar o acesso via navegador.[0m"
        echo ""
        echo -e "[36m➜ Próximo passo: Aguardar estabilização e testar acesso (Seção 5)[0m"
        echo ""
    else
        echo -e "║  [31m✗✗✗ INICIALIZAÇÃO FALHOU ✗✗✗[0m                     ║"
        echo "╚════════════════════════════════════════════════════════╝"
        echo ""
        echo -e "[31m🚫 PONTO DE BLOQUEIO CRÍTICO ATIVADO[0m"
        echo "═══════════════════════════════════════════════════════"
        echo -e "[31m⛔ Um ou mais containers de aplicação FALHARAM ao iniciar[0m"
        echo -e "[31m⛔ NÃO PROSSEGUIR para testes de acesso[0m"
        echo "═══════════════════════════════════════════════════════"
        echo ""
        echo -e "[33m⚠️  TROUBLESHOOTING:[0m"
        echo "───────────────────────────────────────────────────────"

        if [ "$MIDPOINT_OK" == "0" ]; then
            echo "• Container $CONTAINER_MIDPOINT não iniciou:"
            echo "  └─ Verificar logs: sudo docker logs $CONTAINER_MIDPOINT --tail 100"
            echo "  └─ Verificar dependências: containers de banco devem estar rodando"
            echo "  └─ Verificar: sudo docker-compose logs $CONTAINER_MIDPOINT"
        fi

        if [ "$ORANGEHRM_OK" == "0" ]; then
            echo "• Container $CONTAINER_ORANGEHRM não iniciou:"
            echo "  └─ Verificar logs: sudo docker logs $CONTAINER_ORANGEHRM --tail 100"
            echo "  └─ Verificar dependências: container orangehrm-db deve estar rodando"
            echo "  └─ Verificar: sudo docker-compose logs $CONTAINER_ORANGEHRM"
        fi

        echo ""
        echo "• Verificar status de todos os containers:"
        echo "  └─ Comando: sudo docker ps -a"
        echo ""
        echo "• Verificar logs do docker-compose:"
        echo "  └─ Comando: cd $DIRETORIO_STACK && sudo docker-compose logs --tail 50"
        echo ""
        echo -e "[33m📋 AÇÃO OBRIGATÓRIA:[0m"
        echo "   1. Registrar RNC (Relatório de Não-Conformidade)"
        echo "   2. Investigar logs dos containers que falharam"
        echo "   3. Verificar se containers de banco estão rodando (Seção 3)"
        echo "   4. Corrigir problemas antes de continuar"
        echo ""
    fi
fi
```

**Checklist após executar o script:**

- [ ] Se mensagem for **"✓✓✓ CONTAINERS DE APLICAÇÃO: OK ✓✓✓"** → Containers já rodando, prosseguir para seção 5
- [ ] Se mensagem for **"Stack IGA iniciado com sucesso"** → Aguardar 2-3 minutos para estabilização do midPoint, prosseguir para seção 5
- [ ] Se houver **ERRO CRÍTICO** → Seguir troubleshooting e registrar RNC

> ⏱️ **TEMPO DE ESTABILIZAÇÃO:** Após inicialização, o midPoint leva aproximadamente **2-3 minutos** para completar o carregamento do Tomcat embarcado. Aguarde este período antes de testar o acesso via navegador.

> 🚫 **PONTO DE BLOQUEIO:** Se containers de aplicação falharem, **NÃO prosseguir** para testes de acesso.

---

### 5️⃣ Testes de Acesso às Aplicações

> ⏱️ **Antes de iniciar:** Se os containers foram iniciados nesta execução do Cold Start, aguarde **2-3 minutos** para que o midPoint complete a inicialização do Tomcat.

No navegador (host Windows ou máquina com rota para VLAN 1):

#### 5.1. Acessar console do midPoint

- [ ] Acessar `http://xxx.xxx.xxx.xxx:8080/midpoint`
- [ ] Fazer login com usuário **administrator**
- [ ] Confirmar carregamento completo do dashboard

**Se receber erro de conexão ou timeout:**
- Aguardar mais 1-2 minutos (Tomcat ainda inicializando)
- Verificar logs: `sudo docker logs midpoint-server --tail 50`
- Procurar por mensagem "Server startup in [XXXX] milliseconds" nos logs

#### 5.2. Acessar interface do OrangeHRM

- [ ] Acessar `http://xxx.xxx.xxx.xxx:8081`
- [ ] Fazer login com conta administrativa de RH
- [ ] Confirmar carregamento da interface principal

---

### 6️⃣ Pre-Flight Check - Validação de Integridade do Sistema

> 🔍 **Objetivo:** Confirmar que o ambiente está no **estado de referência** esperado antes de qualquer mudança.

#### 6.1. Teste de conexão com recurso OrangeHRM (no midPoint) ⭐

No console do midPoint:
- [ ] **Resources** → **All resources** → **OrangeHRM-Source-v4.2**
- [ ] Clicar em **Test connection**
- [ ] Confirmar status **Success** (verde)

> 🚀 **DECISÃO CRÍTICA:** Se Test Connection der **Success**, o midPoint está comunicando corretamente com o OrangeHRM. **PROSSIGA** para próximas atividades planejadas.

**Se falhar:** Capturar print, verificar container orangehrm-db (porta 3306) e credenciais do recurso.

#### 6.2. Verificação de sincronização de inventário ⭐

**VALIDAÇÃO DE ESTADO DE SINCRONIZAÇÃO:**

- [ ] Aba **Accounts** do recurso OrangeHRM-Source-v4.2
- [ ] Verificar se o inventário de contas está **visível e acessível**
- [ ] Confirmar timestamp da última sincronização (se disponível)

> 📌 **Significado:** Esta validação confirma que o midPoint consegue listar contas do OrangeHRM. O **status específico** das contas (Linked, Unmatched, etc.) depende da configuração de correlação e mapeamento, que deve ser tratada em GMUDs específicas.

> ⚠️ **Nota importante:** A presença de contas com status "Unmatched" **não indica falha** neste procedimento de Cold Start. Isso é esperado quando as regras de correlação ainda não foram configuradas ou estão em processo de ajuste.

**Se o inventário não aparecer ou estiver vazio:**
- Verificar se a tarefa de importação foi executada pelo menos uma vez
- Verificar conectividade com o banco orangehrm-db
- Consultar logs do recurso OrangeHRM no midPoint

#### 6.3. Verificação de status de tarefas

- [ ] **Server tasks** → **List tasks**
- [ ] Localizar tarefa **Import OrangeHRM Identities**
- [ ] Verificar último status de execução (CLOSED, SUCCESS, ERROR)

**Se a tarefa estiver RUNNING sem ter sido iniciada manualmente:**
- Verificar se há agendamento automático configurado
- Se não esperado, pausar tarefa e investigar

**Se a tarefa estiver em ERROR:**
- Capturar mensagem de erro
- Verificar logs detalhados da tarefa
- Registrar RNC se necessário

---

### 7️⃣ Registro de Conclusão (Formato Lean)

#### 7.1. Criar log diário no Obsidian

**Caminho:** `10_Projetos/PRJ001- LABORATORIO DE SI/30_Operacao & Mudancas/`  
**Nome:** `LOG-COLD-START-YYYY-MM-DD.md`

**Template otimizado (30 segundos de preenchimento):**

```markdown
# Cold Start - DD/MM/YYYY

**Técnico:** [Nome]  
**Início:** HH:MM | **Fim:** HH:MM  

## Status Geral
- [ ] ✅ **ALL GREEN** - Todos os critérios de sucesso atendidos
- [ ] ⚠️ **YELLOW** - Sistema operacional com restrições (detalhar abaixo)
- [ ] ❌ **RED** - Sistema indisponível (RNC obrigatória)

## Exceções e Observações
<!-- Preencher SOMENTE se houver desvios do fluxo padrão -->

**Itens que falharam:**
- Nenhum / [Descrever]

**Ações corretivas aplicadas:**
- N/A / [Descrever]

**Pendências para próximo Cold Start:**
- Nenhuma / [Listar]

## Validação Pre-Flight ✓
- [ ] AD DS (xxx.xxx.xxx.xxx) respondendo
- [ ] Containers midpoint-db + orangehrm-db rodando
- [ ] Containers midpoint-server + orangehrm-app rodando
- [ ] midPoint acessível (http://xxx.xxx.xxx.xxx:8080/midpoint)
- [ ] OrangeHRM acessível (http://xxx.xxx.xxx.xxx:8081)
- [ ] Test connection OrangeHRM: **Success** ⭐
- [ ] Inventário de contas visível e acessível
- [ ] Última execução de tarefa Import: [Status]

---
**RNC aberta:** Nenhuma / [Link]  
**Próxima atividade:** [Descrever atividade planejada]
```

---

## 📊 Critérios de Sucesso (Checklist Final)

O Cold Start está **concluído com sucesso** quando:

1. ✅ AD DS (xxx.xxx.xxx.xxx) responde em LDAP (porta 389)
2. ✅ Containers **midpoint-db** e **orangehrm-db** rodando
3. ✅ Containers **midpoint-server** e **orangehrm-app** rodando
4. ✅ Console midPoint acessível via navegador (http://xxx.xxx.xxx.xxx:8080/midpoint)
5. ✅ Interface OrangeHRM acessível via navegador (http://xxx.xxx.xxx.xxx:8081)
6. ✅ **Test connection do recurso OrangeHRM retorna Success** ⭐ (critério decisivo)
7. ✅ **Inventário de contas do OrangeHRM está visível** no midPoint
8. ✅ Tarefas de importação sem erros críticos de execução

---

## 🚫 Pontos de Bloqueio Críticos

**NÃO prosseguir com atividades do LAB se:**

- ❌ AD DS (xxx.xxx.xxx.xxx) não responder - **Severity: CRÍTICO**
- ❌ Containers de banco não iniciarem - **Severity: CRÍTICO**
- ❌ Containers de aplicação não iniciarem - **Severity: CRÍTICO**
- ❌ **Test connection OrangeHRM falhar** - **Severity: CRÍTICO** (este é o critério decisivo)

**Ação obrigatória:** Registrar RNC e investigar causa raiz.

---

## 🎯 Próxima Ação Técnica

Após conclusão do Cold Start com **Test Connection = Success**, prosseguir com as atividades planejadas do dia conforme roadmap do projeto.

---

## 🔗 Referências

- **GMUD-007:** Alteração de Endereçamento IP Estático
- **GMUD-008:** Implantação da Stack midPoint 4.10
- **GMUD-011:** Rede de Integração Segura Backend Bridge
- **REL-GMUD-014:** Integração AD e IGA - Suspensão Técnica
- **Manifesto Fiqueok v2.0:** Arquitetura e Governança do LAB

---

## 📝 Changelog

| Versão | Data       | Autor         | Mudanças                                               |
|--------|------------|---------------|--------------------------------------------------------|
| 1.0    | 30/12/2025 | Paulo Feitosa | Criação inicial do procedimento                        |
| 1.1    | 30/12/2025 | Paulo Feitosa | Otimização baseada em feedback Gemini (Deep-Dive)      |
| 1.2    | 30/12/2025 | Paulo Feitosa | Ajustes de perfil, scripts melhorados com troubleshooting |
| 1.3    | 30/12/2025 | Paulo Feitosa | Script inteligente de verificação/inicialização de DBs |
| 1.4    | 30/12/2025 | Paulo Feitosa | Correção crítica: validação de containers Docker para DBs |
| 1.5    | 30/12/2025 | Paulo Feitosa | Script inteligente para containers de aplicação (Seção 4) |
| 1.6    | 30/12/2025 | Paulo Feitosa | Correção: Path e nomes de containers validados em runtime |
| 1.7    | 30/12/2025 | Paulo Feitosa | 🔧 Seção 6.2 ajustada para validação genérica de inventário |

**Principais ajustes v1.7:**
- **Seção 6.2 reformulada:** Removida validação pontual do status "Unmatched" do registro 0001
- **Substituída por validação genérica:** Verificação de visibilidade e acessibilidade do inventário de contas
- **Esclarecimento adicionado:** Status "Unmatched" não indica falha do Cold Start, mas sim necessidade de configuração de correlação (tratada em GMUD específica)
- **Alinhamento com propósito do POP:** Validação de infraestrutura operacional, não de configuração de IGA

---

**Documento mantido por:** Paulo Feitosa (Owner/CISO)  
**Última revisão:** 30/12/2025 14:03  
**Próxima revisão obrigatória:** 27/01/2026  

---

## 📍 Localização no Repositório Obsidian

**Caminho principal:**
```
10_Projetos/PRJ001- LABORATORIO DE SI/30_Operacao & Mudancas/POP-LAB-001-Cold-Start.md
```

**Referência cruzada (opcional):**
```
20_Areas/01_SGSI_Fiqueok/05_Operacao_e_Procedimentos/[Link para POP-LAB-001]
```

---

Este procedimento deve ser executado **diariamente** antes de qualquer GMUD, teste ou experimento no LAB PRJ001.

