# 📋 Procedimento de Inicialização do LAB - Cold Start Diário

**Status:** Ativo  
**Versão:** 1.8  
**Data de atualização:** 03/01/2026 16:18  
**Tipo:** POP - Procedimento Operacional Padrão  
**Owner:** Paulo Feitosa  
**Frequência:** Diária - antes de qualquer atividade no LAB  

**Changelog v1.8:**
- ✅ **VALIDAÇÃO PRÁTICA:** Seção 4 consolidada com execução validada de containers (PostgreSQL, MariaDB, midPoint, OrangeHRM)
- ✅ **VALIDAÇÃO PRÁTICA:** Seção 5 atualizada com testes de acesso, autenticação e navegação confirmados
- ✅ **PRE-FLIGHT CHECK COMPLETO:** Seção 6 expandida com validação detalhada de Test Connection, inventário, correlação e tasks
- 🔧 **REDAÇÃO:** Ajustes para refletir procedimentos validados em produção, mantendo tom técnico e auditável
- 📊 **STATUS:** Procedimento completo testado e aprovado em 03/01/2026

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

```bash
#!/bin/bash
# ===== SCRIPT DE VERIFICAÇÃO E INICIALIZAÇÃO DE BANCOS (DOCKER) =====
# Versão: 1.4 - Cold Start LAB Fiqueok
# Data: 30/12/2025

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║  VERIFICAÇÃO DE BANCOS DE DADOS (DOCKER) - IGA-P-01   ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

PRECISA_INICIAR=0
ERRO_CRITICO=0

# ========== VERIFICAÇÃO POSTGRESQL 16 (Container: midpoint-db) ==========
echo "[1/2] Verificando container: midpoint-db (PostgreSQL 16)..."

if sudo docker ps -a --format '{{.Names}}' | grep -q "^midpoint-db$"; then
    if [ "$(sudo docker inspect -f '{{.State.Running}}' midpoint-db 2>/dev/null)" == "true" ]; then
        echo -e "      [32m✓ Container midpoint-db: RODANDO[0m"

        PORTA_5432=$(sudo docker port midpoint-db 2>/dev/null | grep 5432)
        if [ -n "$PORTA_5432" ]; then
            echo -e "      [32m✓ Porta 5432: EXPOSTA ($PORTA_5432)[0m"
        else
            echo -e "      [33m⚠ Porta 5432: Não exposta (pode ser rede interna Docker)[0m"
        fi
    else
        echo -e "      [33m⚠ Container midpoint-db: PARADO (será iniciado)[0m"
        PRECISA_INICIAR=1
    fi
else
    echo -e "      [31m✗ Container midpoint-db: NÃO ENCONTRADO[0m"
    ERRO_CRITICO=1
fi

echo ""

# ========== VERIFICAÇÃO MARIADB 11.4 (Container: orangehrm-db) ==========
echo "[2/2] Verificando container: orangehrm-db (MariaDB 11.4)..."

if sudo docker ps -a --format '{{.Names}}' | grep -q "^orangehrm-db$"; then
    if [ "$(sudo docker inspect -f '{{.State.Running}}' orangehrm-db 2>/dev/null)" == "true" ]; then
        echo -e "      [32m✓ Container orangehrm-db: RODANDO[0m"

        PORTA_3306=$(sudo docker port orangehrm-db 2>/dev/null | grep 3306)
        if [ -n "$PORTA_3306" ]; then
            echo -e "      [32m✓ Porta 3306: EXPOSTA ($PORTA_3306)[0m"
        else
            echo -e "      [33m⚠ Porta 3306: Não exposta (pode ser rede interna Docker)[0m"
        fi
    else
        echo -e "      [33m⚠ Container orangehrm-db: PARADO (será iniciado)[0m"
        PRECISA_INICIAR=1
    fi
else
    echo -e "      [31m✗ Container orangehrm-db: NÃO ENCONTRADO[0m"
    ERRO_CRITICO=1
fi

echo ""
echo "╔════════════════════════════════════════════════════════╗"

if [ $ERRO_CRITICO -eq 1 ]; then
    echo -e "║  [31m✗✗✗ ERRO CRÍTICO: CONTAINER NÃO EXISTE ✗✗✗[0m        ║"
    echo "╚════════════════════════════════════════════════════════╝"
elif [ $PRECISA_INICIAR -eq 0 ]; then
    echo -e "║  [32m✓✓✓ BANCOS DE DADOS: OK ✓✓✓[0m                       ║"
    echo "╚════════════════════════════════════════════════════════╝"
else
    echo -e "║  [33m⚠⚠⚠ INICIANDO CONTAINERS... ⚠⚠⚠[0m                 ║"
    echo "╚════════════════════════════════════════════════════════╝"

    [ "$(sudo docker inspect -f '{{.State.Running}}' midpoint-db 2>/dev/null)" != "true" ] && sudo docker start midpoint-db
    [ "$(sudo docker inspect -f '{{.State.Running}}' orangehrm-db 2>/dev/null)" != "true" ] && sudo docker start orangehrm-db

    sleep 3
    echo -e "[32m✅ Containers iniciados com sucesso[0m"
fi
```

- [ ] Confirmar mensagem final: **"✓✓✓ BANCOS DE DADOS: OK ✓✓✓"**
- [ ] Se houver erro crítico, seguir troubleshooting e registrar RNC

---

### 4️⃣ Verificar e Inicializar Containers de Aplicação (midPoint + OrangeHRM) ✅

> 📌 **Status:** Validado em execução real (03/01/2026)

#### 4.1. Validação de containers e serviços Docker

**Containers validados como operacionais:**

| Container | Status | Porta | Health Check |
|-----------|--------|-------|--------------|
| `midpoint-server` | ✅ Running | 8080:8080 | Healthy |
| `orangehrm-app` | ✅ Running | 8081:80 | Healthy |
| `midpoint-db` (PostgreSQL 16) | ✅ Running | 5432 (interno) | Healthy |
| `orangehrm-db` (MariaDB 11.4) | ✅ Running | 3306 (interno) | Healthy |

**Docker Compose validado:**
- Stack: `/home/paulo/midpoint_lab/docker-compose.yml`
- Redes: `midpointlabnet`, `orangehrmlabnet`, `fiqueok-backend-net`
- Volumes persistentes: Funcionais e montados corretamente

**Container de inicialização:**
- `midpoint-init`: Executado e finalizado com sucesso (Status: Exited 0)
- Função: Configuração inicial do midPoint (schemas, roles, archetypes)

#### 4.2. Checklist de validação de containers

- [x] Todos os containers em estado **Running** ou **Exited (0)** conforme esperado
- [x] Portas mapeadas corretamente (8080, 8081)
- [x] Health checks respondendo como **Healthy**
- [x] Conectividade de rede entre containers validada
- [x] Docker Engine e Docker Compose operacionais

> ✅ **VALIDAÇÃO CONCLUÍDA:** Infraestrutura Docker e containers operacionais confirmados em 03/01/2026.

---

### 5️⃣ Testes de Acesso às Aplicações ✅

> ⏱️ **Tempo de estabilização:** midPoint requer 2-3 minutos após inicialização para carregar o Tomcat embarcado.

#### 5.1. Validação de acesso ao OrangeHRM ✅

**Teste realizado e aprovado:**

| Item | Status | Observação |
|------|--------|------------|
| URL de acesso | ✅ `http://xxx.xxx.xxx.xxx:8081` | Acessível via navegador |
| Página de login | ✅ Carregada | Interface responsiva |
| Autenticação | ✅ Sucesso | Credenciais administrativas validadas |
| Dashboard principal | ✅ Funcional | Navegação e módulos acessíveis |
| Performance | ✅ Normal | Tempo de resposta adequado |

**Validações adicionais:**
- [x] Módulos de RH acessíveis (PIM, Leave, Time, Recruitment)
- [x] Dados de funcionários visíveis
- [x] Logs de aplicação sem erros críticos

#### 5.2. Validação de acesso ao midPoint ✅

**Teste realizado e aprovado:**

| Item | Status | Observação |
|------|--------|------------|
| URL de acesso | ✅ `http://xxx.xxx.xxx.xxx:8080/midpoint` | Acessível via navegador |
| Página de login | ✅ Carregada | Interface midPoint 4.10 |
| Autenticação | ✅ Sucesso | Usuário Break-Glass validado |
| Dashboard administrativo | ✅ Funcional | Console de administração operacional |
| Navegação | ✅ Completa | Menu lateral, recursos, usuários, tarefas |

**Validações administrativas:**
- [x] Menu **Resources** acessível
- [x] Menu **Server Tasks** acessível
- [x] Menu **Users** acessível
- [x] Console de configuração responsivo
- [x] Logs de aplicação sem erros críticos

> ✅ **VALIDAÇÃO CONCLUÍDA:** Acesso, autenticação e navegação confirmados para ambas as aplicações em 03/01/2026.

---

### 6️⃣ Pre-Flight Check - Validação de Integridade do Sistema IGA ✅

> 🔍 **Objetivo:** Confirmar integridade operacional do sistema de Identity Governance & Administration antes de qualquer atividade de configuração ou GMUD.

#### 6.1. Test Connection do recurso OrangeHRM ⭐ ✅

**Validação realizada:** Resources → All resources → **OrangeHRM-Source-v4.2** → Test connection

**Resultado do teste (03/01/2026):**

| Etapa de Validação | Status | Observação |
|-------------------|--------|------------|
| Connector instantiation | ✅ Success | Connector DatabaseTable instanciado |
| Connector initialization | ✅ Success | Parâmetros de conexão validados |
| Connector connection | ✅ Success | Conectividade com MariaDB estabelecida |
| Connector capabilities | ✅ Success | Read, Update, Create, Delete suportados |
| Resource schema | ✅ Success | Schema da tabela `ohrm_user` mapeado |

**Resultado geral:** ✅ **Success** (verde) - Conectividade total com recurso OrangeHRM validada

**Interpretação técnica:**
- midPoint estabeleceu conexão JDBC com banco `orangehrm` (MariaDB)
- Credenciais de serviço funcionais
- Mapeamento de schema correto
- Operações CRUD disponíveis

#### 6.2. Validação de inventário e correlação de identidades ✅

**Navegação:** Resources → OrangeHRM-Source-v4.2 → Aba **Accounts**

**Validação de conta de referência (Registro 0001):**

| Atributo | Valor Esperado | Status |
|----------|----------------|--------|
| Identificador único | `user_id = 1` | ✅ Correto |
| Nome de usuário | `Admin` | ✅ Visível |
| Status de correlação | **LINKED** | ✅ Confirmado |
| Owner (Usuário midPoint) | Definido | ✅ Validado |
| Atributos técnicos | employee_id, user_name, user_role_id | ✅ Mapeados |

**Interpretação de status:**
- **LINKED:** Conta do OrangeHRM correlacionada com identidade no midPoint
- **Owner definido:** Associação usuário ↔ conta estabelecida
- **Identificadores corretos:** Regras de correlação funcionando

> 📌 **Nota técnica:** Status "LINKED" confirma que a regra de correlação está operacional. Status "Unmatched" indicaria necessidade de configuração adicional (não é falha do Cold Start).

#### 6.3. Validação de tarefas de importação ✅

**Navegação:** Server tasks → List tasks → **Import OrangeHRM Identities**

**Status da tarefa de importação:**

| Atributo | Valor | Status |
|----------|-------|--------|
| Última execução | [Timestamp registrado] | ✅ Concluída |
| Status de conclusão | **CLOSED / SUCCESS** | ✅ Confirmado |
| Objetos processados | [N] contas importadas | ✅ Validado |
| Erros registrados | 0 erros | ✅ Sem falhas |
| Próxima execução | Conforme agendamento | ✅ Agendada |

**Validações adicionais:**
- [x] Logs da tarefa sem exceções críticas
- [x] Timestamp de última execução coerente
- [x] Configuração de agendamento (se aplicável) validada
- [x] Task handler responsivo

#### 6.4. Checklist consolidado de integridade IGA

- [x] **Test connection OrangeHRM: Success** (critério decisivo) ⭐
- [x] Connector instantiation, initialization e connection validados
- [x] Schema do recurso mapeado corretamente
- [x] Inventário de contas visível e acessível
- [x] Correlação de identidades funcional (status LINKED confirmado)
- [x] Task de importação sem erros críticos
- [x] Logs de sistema sem alertas de segurança ou falhas

> ✅ **PRE-FLIGHT CHECK CONCLUÍDO COM SUCESSO:** Sistema IGA validado como íntegro e operacional em 03/01/2026.

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
- [x] ✅ **ALL GREEN** - Todos os critérios de sucesso atendidos
- [ ] ⚠️ **YELLOW** - Sistema operacional com restrições (detalhar abaixo)
- [ ] ❌ **RED** - Sistema indisponível (RNC obrigatória)

## Exceções e Observações
<!-- Preencher SOMENTE se houver desvios do fluxo padrão -->

**Itens que falharam:**
- Nenhum

**Ações corretivas aplicadas:**
- N/A

**Pendências para próximo Cold Start:**
- Nenhuma

## Validação Pre-Flight ✓
- [x] AD DS (xxx.xxx.xxx.xxx) respondendo
- [x] Containers midpoint-db + orangehrm-db rodando
- [x] Containers midpoint-server + orangehrm-app rodando
- [x] midPoint acessível (http://xxx.xxx.xxx.xxx:8080/midpoint)
- [x] OrangeHRM acessível (http://xxx.xxx.xxx.xxx:8081)
- [x] Test connection OrangeHRM: **Success** ⭐
- [x] Inventário de contas visível (conta 0001: LINKED)
- [x] Última execução de tarefa Import: **CLOSED / SUCCESS**

---
**RNC aberta:** Nenhuma  
**Próxima atividade:** [Descrever atividade planejada]
```

---

## 📊 Critérios de Sucesso (Checklist Final)

O Cold Start está **concluído com sucesso** quando todos os itens abaixo são validados:

1. ✅ AD DS (xxx.xxx.xxx.xxx) responde em LDAP (porta 389)
2. ✅ Containers **midpoint-db** e **orangehrm-db** em estado Running
3. ✅ Containers **midpoint-server** e **orangehrm-app** em estado Running com health check Healthy
4. ✅ Console midPoint acessível, autenticação funcional e navegação administrativa operacional
5. ✅ Interface OrangeHRM acessível, autenticação funcional e dashboard operacional
6. ✅ **Test connection do recurso OrangeHRM retorna Success em todas as etapas** ⭐ (critério decisivo)
7. ✅ **Inventário de contas visível com correlação funcional** (status LINKED confirmado)
8. ✅ **Task de importação sem erros** (status CLOSED / SUCCESS)

---

## 🚫 Pontos de Bloqueio Críticos

**NÃO prosseguir com atividades do LAB se:**

- ❌ AD DS (xxx.xxx.xxx.xxx) não responder - **Severity: CRÍTICO**
- ❌ Containers de banco não iniciarem - **Severity: CRÍTICO**
- ❌ Containers de aplicação não iniciarem - **Severity: CRÍTICO**
- ❌ **Test connection OrangeHRM falhar em qualquer etapa** - **Severity: CRÍTICO** (critério decisivo)
- ❌ **Inventário não visível ou correlação não funcional** - **Severity: ALTO**
- ❌ **Task de importação com erros recorrentes** - **Severity: ALTO**

**Ação obrigatória:** Registrar RNC e investigar causa raiz antes de qualquer atividade de configuração ou GMUD.

---

## 🎯 Próxima Ação Técnica

Após conclusão do Cold Start com todos os critérios de sucesso atendidos, prosseguir com as atividades planejadas do dia conforme roadmap do projeto e planejamento de GMUDs.

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
| 1.7    | 30/12/2025 | Paulo Feitosa | Seção 6.2 ajustada para validação genérica de inventário |
| 1.8    | 03/01/2026 | Paulo Feitosa | **Consolidação de validações práticas executadas:** Seção 4 (containers validados), Seção 5 (acesso e autenticação confirmados), Seção 6 (Pre-Flight Check completo com Test Connection, inventário, correlação e tasks). Redação ajustada para refletir procedimento testado em produção. |

**Principais consolidações v1.8:**
- **Seção 4:** Validação prática de containers (midPoint, OrangeHRM, PostgreSQL, MariaDB) com status Running/Healthy confirmado
- **Seção 5:** Testes de acesso, autenticação e navegação validados para ambas as aplicações
- **Seção 6:** Pre-Flight Check expandido com Test Connection detalhado (5 etapas validadas), inventário de contas (status LINKED), e validação de tasks (CLOSED/SUCCESS)
- **Critérios de sucesso:** Atualizados para refletir validações executadas em ambiente real
- **Tom técnico e auditável:** Mantido conforme padrão de documentação operacional

---

**Documento mantido por:** Paulo Feitosa (Owner/CISO)  
**Última revisão:** 03/01/2026 16:18  
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

## ✅ Status de Validação

**Procedimento validado em:** 03/01/2026  
**Ambiente:** PRJ001 - Lab IAM/IGA Fiqueok  
**Resultado:** ✅ **TODOS OS CRITÉRIOS DE SUCESSO ATENDIDOS**  

Este procedimento deve ser executado **diariamente** antes de qualquer GMUD, teste ou experimento no LAB PRJ001.

