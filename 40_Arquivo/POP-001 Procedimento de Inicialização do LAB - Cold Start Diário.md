# 📋

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

Garantir que o ambiente de laboratório PRJ001 (AD DS + midPoint + OrangeHRM) esteja íntegro, operacional e no estado de referência esperado antes de iniciar qualquer atividade de configuração, teste, GMUD ou experimento de GRC/IGA.[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

---

## 📋 Pré-requisitos do Técnico

- Acesso físico ou RDP ao PC Host Hyper-V (Windows 11 Pro)[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- **Perfil de usuário do LAB:** Fiqueok[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- **Usuário admin local:** Win (para tarefas administrativas)[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- Credenciais de administrador do midPoint (usuário `administrator` ou break-glass)[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- Credenciais de administrador do OrangeHRM e do AD DS[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- Acesso ao vault de senhas da Fiqueok (Obsidian ou gerenciador de senhas)[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

---

## 🚀 Procedimento de Inicialização

## 0️⃣ Iniciar Host e Verificações Básicas

## 0.1. Ligar e acessar o host

-  Ligar o PC Host (Hyper-V)[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Fazer login no Windows 11 Pro com o perfil **Fiqueok**[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Registrar horário de início: `______:______`[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

> 💡 **Nota:** Para tarefas administrativas que exigem elevação de privilégios, use o usuário **Win** quando solicitado pelo UAC.[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

## 0.2. Teste automatizado de conectividade e configuração de rede

Abrir **PowerShell como Administrador** (usuário **Win** se solicitado) e executar:

powershell

``# ===== SCRIPT DE VALIDAÇÃO DE PRÉ-REQUISITOS DE REDE ===== # Versão: 1.2 - Cold Start LAB Fiqueok # Data: 30/12/2025 Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan Write-Host "║  VALIDAÇÃO DE PRÉ-REQUISITOS - LAB FIQUEOK            ║" -ForegroundColor Cyan Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan $erros = @() # [1/4] Teste de conectividade com Internet Write-Host "[1/4] Testando conectividade com Internet (8.8.8.8)..." -ForegroundColor Yellow $testInternet = Test-NetConnection -ComputerName 8.8.8.8 -InformationLevel Quiet -WarningAction SilentlyContinue if ($testInternet) {     Write-Host "      ✓ Conectividade com Internet: OK" -ForegroundColor Green } else {     Write-Host "      ✗ Conectividade com Internet: FALHOU" -ForegroundColor Red    $erros += "Internet" } # [2/4] Teste de resolução DNS Write-Host "`n[2/4] Testando resolução DNS (www.google.com)..." -ForegroundColor Yellow $testDNS = Test-NetConnection -ComputerName www.google.com -InformationLevel Quiet -WarningAction SilentlyContinue if ($testDNS) {     Write-Host "      ✓ Resolução DNS: OK" -ForegroundColor Green } else {     Write-Host "      ✗ Resolução DNS: FALHOU" -ForegroundColor Red    $erros += "DNS" } # [3/4] Validação de IP da VLAN 1 Write-Host "`n[3/4] Validando IP da VLAN 1 (xxx.xxx.xxx.xxx/16)..." -ForegroundColor Yellow $ipVLAN1 = Get-NetIPAddress | Where-Object {$_.IPAddress -like "172.16.*" -and $_.AddressFamily -eq "IPv4"} if ($ipVLAN1) {     Write-Host "      ✓ IP VLAN 1 encontrado: $($ipVLAN1.IPAddress) ($($ipVLAN1.InterfaceAlias))" -ForegroundColor Green } else {     Write-Host "      ✗ IP VLAN 1 não encontrado (esperado xxx.xxx.xxx.xxx)" -ForegroundColor Red    $erros += "VLAN1_IP" } # [4/4] Validação de adaptador vSwitch FiqueokCorp Write-Host "`n[4/4] Verificando adaptador vSwitch FiqueokCorp..." -ForegroundColor Yellow $vSwitch = Get-NetAdapter | Where-Object {$_.Name -like "*vEthernet*" -or $_.InterfaceDescription -like "*Hyper-V*"} if ($vSwitch) {     Write-Host "      ✓ Adaptador Hyper-V encontrado: $($vSwitch.Name)" -ForegroundColor Green } else {     Write-Host "      ⚠ Adaptador Hyper-V não identificado claramente" -ForegroundColor Yellow } # Resultado final Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan if ($erros.Count -eq 0) {     Write-Host "║  ✓✓✓ TESTE DE CONECTIVIDADE: OK ✓✓✓                  ║" -ForegroundColor Green    Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan } else {     Write-Host "║  ✗✗✗ TESTE DE CONECTIVIDADE: FALHOU ✗✗✗              ║" -ForegroundColor Red    Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan         Write-Host "`n⚠️  TROUBLESHOOTING NECESSÁRIO:" -ForegroundColor Yellow    Write-Host "───────────────────────────────────────────────────────" -ForegroundColor Yellow         if ($erros -contains "Internet") {        Write-Host "• Internet: Verifique cabo de rede ou adaptador físico" -ForegroundColor White        Write-Host "  Comando: Get-NetAdapter | Where-Object {`$_.Status -eq 'Up'}" -ForegroundColor Gray    }    if ($erros -contains "DNS") {        Write-Host "• DNS: Verifique configuração de DNS nos adaptadores de rede" -ForegroundColor White        Write-Host "  Comando: Get-DnsClientServerAddress" -ForegroundColor Gray    }    if ($erros -contains "VLAN1_IP") {        Write-Host "• VLAN 1: IP xxx.xxx.xxx.xxx não encontrado - verificar configuração vSwitch" -ForegroundColor White        Write-Host "  Comando: Get-NetIPAddress | Format-Table IPAddress, InterfaceAlias" -ForegroundColor Gray        Write-Host "  Ação: Painel de Controle → Rede → Propriedades TCP/IPv4 do vSwitch" -ForegroundColor Gray    }         Write-Host "`n❌ RECOMENDAÇÃO: Corrija os erros antes de prosseguir com o Cold Start" -ForegroundColor Red }``

-  Confirmar mensagem final: **"✓✓✓ TESTE DE CONECTIVIDADE: OK ✓✓✓"**[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Se houver falhas, seguir troubleshooting sugerido pelo script[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

---

## 1️⃣ Inicializar VM do Domain Controller (ID-P-01)

> ⚠️ **CRÍTICO:** O AD DS deve estar operacional ANTES de subir qualquer serviço de IGA.[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

## 1.1. Subir a VM do AD DS no Hyper-V

-  Abrir **Hyper-V Manager**[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Localizar VM **ID-P-01** (Windows Server 2022 - AD DS)[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Se estiver desligada: clicar com botão direito → **Start**[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Aguardar inicialização completa (cerca de 2-3 minutos)[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

## 1.2. Validar serviços do AD DS

No **PowerShell como Administrador** (usuário **Win**), executar:

powershell

``# ===== SCRIPT DE VALIDAÇÃO DO AD DS (ID-P-01) ===== # Versão: 1.2 - Cold Start LAB Fiqueok # Data: 30/12/2025 Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan Write-Host "║  VALIDAÇÃO DO ACTIVE DIRECTORY (ID-P-01)              ║" -ForegroundColor Cyan Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan $errosAD = @() $ipDC = "xxx.xxx.xxx.xxx" $dominio = "corp.fiqueok.com.br" # [1/4] Teste de conectividade básica (ICMP) Write-Host "[1/4] Testando conectividade ICMP com DC ($ipDC)..." -ForegroundColor Yellow $testPing = Test-Connection -ComputerName $ipDC -Count 2 -Quiet -ErrorAction SilentlyContinue if ($testPing) {     Write-Host "      ✓ Ping para DC: OK" -ForegroundColor Green } else {     Write-Host "      ✗ Ping para DC: FALHOU" -ForegroundColor Red    $errosAD += "PING" } # [2/4] Teste de porta LDAP (389) Write-Host "`n[2/4] Testando porta LDAP (389)..." -ForegroundColor Yellow $testLDAP = Test-NetConnection -ComputerName $ipDC -Port 389 -WarningAction SilentlyContinue -InformationLevel Quiet if ($testLDAP) {     Write-Host "      ✓ Porta LDAP (389): ABERTA" -ForegroundColor Green } else {     Write-Host "      ✗ Porta LDAP (389): FECHADA ou INACESSÍVEL" -ForegroundColor Red    $errosAD += "LDAP" } # [3/4] Teste de resolução DNS do domínio Write-Host "`n[3/4] Testando resolução DNS do domínio ($dominio)..." -ForegroundColor Yellow $testDNSDomain = Resolve-DnsName -Name $dominio -Server $ipDC -ErrorAction SilentlyContinue if ($testDNSDomain) {     Write-Host "      ✓ Resolução DNS do domínio: OK" -ForegroundColor Green    Write-Host "      └─ Resolvido para: $($testDNSDomain[0].IPAddress)" -ForegroundColor Gray } else {     Write-Host "      ✗ Resolução DNS do domínio: FALHOU" -ForegroundColor Red    $errosAD += "DNS_DOMAIN" } # [4/4] Teste de porta LDAPS (636) - Opcional Write-Host "`n[4/4] Testando porta LDAPS (636) - Opcional..." -ForegroundColor Yellow $testLDAPS = Test-NetConnection -ComputerName $ipDC -Port 636 -WarningAction SilentlyContinue -InformationLevel Quiet if ($testLDAPS) {     Write-Host "      ✓ Porta LDAPS (636): ABERTA (certificado configurado)" -ForegroundColor Green } else {     Write-Host "      ⚠ Porta LDAPS (636): FECHADA (normal se PKI ainda não implementada)" -ForegroundColor Yellow } # Resultado final Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan if ($errosAD.Count -eq 0) {     Write-Host "║  ✓✓✓ VALIDAÇÃO AD DS: OK ✓✓✓                         ║" -ForegroundColor Green    Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan } else {     Write-Host "║  ✗✗✗ VALIDAÇÃO AD DS: FALHOU ✗✗✗                     ║" -ForegroundColor Red    Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan         Write-Host "`n🚫 PONTO DE BLOQUEIO CRÍTICO ATIVADO" -ForegroundColor Red -BackgroundColor Black    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red    Write-Host "⛔ O AD DS (xxx.xxx.xxx.xxx) NÃO ESTÁ RESPONDENDO CORRETAMENTE" -ForegroundColor Red    Write-Host "⛔ PARAR IMEDIATAMENTE - NÃO PROSSEGUIR PARA ETAPAS DE IGA" -ForegroundColor Red    Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Red         Write-Host "⚠️  TROUBLESHOOTING NECESSÁRIO:" -ForegroundColor Yellow    Write-Host "───────────────────────────────────────────────────────" -ForegroundColor Yellow         if ($errosAD -contains "PING") {        Write-Host "• PING falhou:" -ForegroundColor White        Write-Host "  └─ Verifique se a VM ID-P-01 está realmente ligada no Hyper-V" -ForegroundColor Gray        Write-Host "  └─ Verifique se o IP xxx.xxx.xxx.xxx está configurado no servidor" -ForegroundColor Gray        Write-Host "  └─ Aguarde mais 1-2 minutos (servidor pode estar finalizando boot)" -ForegroundColor Gray    }    if ($errosAD -contains "LDAP") {        Write-Host "• Porta LDAP (389) inacessível:" -ForegroundColor White        Write-Host "  └─ Verifique se o serviço 'Active Directory Domain Services' está rodando" -ForegroundColor Gray        Write-Host "  └─ No servidor, execute: Get-Service NTDS | Select-Object Status" -ForegroundColor Gray        Write-Host "  └─ Verifique logs do Event Viewer: Directory Service" -ForegroundColor Gray    }    if ($errosAD -contains "DNS_DOMAIN") {        Write-Host "• Resolução DNS do domínio falhou:" -ForegroundColor White        Write-Host "  └─ Verifique se o serviço DNS está rodando no DC" -ForegroundColor Gray        Write-Host "  └─ No servidor, execute: Get-Service DNS | Select-Object Status" -ForegroundColor Gray        Write-Host "  └─ Verifique zona corp.fiqueok.com.br no DNS Manager" -ForegroundColor Gray    }         Write-Host "`n📋 AÇÃO OBRIGATÓRIA:" -ForegroundColor Yellow    Write-Host "   1. Registrar RNC (Relatório de Não-Conformidade)" -ForegroundColor White    Write-Host "   2. Investigar causa raiz dos erros listados acima" -ForegroundColor White    Write-Host "   3. Corrigir problemas antes de continuar o Cold Start" -ForegroundColor White    Write-Host "   4. Não inicializar serviços de IGA enquanto AD DS estiver falho`n" -ForegroundColor White }``

-  Confirmar mensagem final: **"✓✓✓ VALIDAÇÃO AD DS: OK ✓✓✓"**[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Se falhar, **PARAR IMEDIATAMENTE** e seguir troubleshooting[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

> 🚫 **PONTO DE BLOQUEIO CRÍTICO:** Se o AD DS não responder, registrar RNC e NÃO prosseguir para etapas de IGA.[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

---

## 2️⃣ Inicializar VM IGA-P-01 (Ubuntu 22.04 - Docker Host)

## 2.1. Subir a VM no Hyper-V

-  No **Hyper-V Manager**, localizar VM **IGA-P-01** (Ubuntu 22.04)[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Se estiver desligada: clicar com botão direito → **Start**[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Aguardar inicialização completa (cerca de 1-2 minutos)[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

## 2.2. Acessar console e validar rede

-  Clicar com botão direito em **IGA-P-01** → **Connect…**[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Fazer login no Ubuntu com conta administrativa do Docker Host[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

No terminal do Ubuntu, executar:

bash

`#!/bin/bash # ===== SCRIPT DE VALIDAÇÃO DE REDE - VM IGA-P-01 ===== # Versão: 1.2 - Cold Start LAB Fiqueok # Data: 30/12/2025 echo "" echo "╔════════════════════════════════════════════════════════╗" echo "║  VALIDAÇÃO DE REDE - VM IGA-P-01 (Ubuntu 22.04)       ║" echo "╚════════════════════════════════════════════════════════╝" echo "" ERROS=0 IP_ESPERADO="xxx.xxx.xxx.xxx" IP_DC="xxx.xxx.xxx.xxx" # [1/3] Validar IP da VM echo "[1/3] Validando IP da VM (esperado: $IP_ESPERADO)..." IP_ATUAL=$(ip -4 addr show | grep "172.16." | awk '{print $2}' | cut -d'/' -f1) if [ "$IP_ATUAL" == "$IP_ESPERADO" ]; then     echo -e "      \033[32m✓ IP da VM: $IP_ATUAL (OK)\033[0m" else     if [ -z "$IP_ATUAL" ]; then        echo -e "      \033[31m✗ IP da VM: NÃO ENCONTRADO (esperado $IP_ESPERADO)\033[0m"    else        echo -e "      \033[33m⚠ IP da VM: $IP_ATUAL (diferente do esperado $IP_ESPERADO)\033[0m"    fi    ERROS=$((ERROS + 1)) fi # [2/3] Testar conectividade com AD DS echo "" echo "[2/3] Testando conectividade com AD DS ($IP_DC)..." if ping -c 2 -W 2 $IP_DC > /dev/null 2>&1; then     echo -e "      \033[32m✓ Ping para AD DS: OK\033[0m" else     echo -e "      \033[31m✗ Ping para AD DS: FALHOU\033[0m"    ERROS=$((ERROS + 1)) fi # [3/3] Testar loopback local echo "" echo "[3/3] Testando loopback local ($IP_ESPERADO)..." if ping -c 2 -W 2 $IP_ESPERADO > /dev/null 2>&1; then     echo -e "      \033[32m✓ Loopback local: OK\033[0m" else     echo -e "      \033[31m✗ Loopback local: FALHOU\033[0m"    ERROS=$((ERROS + 1)) fi # Resultado final echo "" echo "╔════════════════════════════════════════════════════════╗" if [ $ERROS -eq 0 ]; then     echo -e "║  \033[32m✓✓✓ TESTE DE CONECTIVIDADE: OK ✓✓✓\033[0m                  ║"    echo "╚════════════════════════════════════════════════════════╝"    echo "" else     echo -e "║  \033[31m✗✗✗ TESTE DE CONECTIVIDADE: FALHOU ✗✗✗\033[0m              ║"    echo "╚════════════════════════════════════════════════════════╝"    echo ""    echo -e "\033[33m⚠️  TROUBLESHOOTING NECESSÁRIO:\033[0m"    echo "───────────────────────────────────────────────────────"         if [ -z "$IP_ATUAL" ] || [ "$IP_ATUAL" != "$IP_ESPERADO" ]; then        echo "• IP incorreto ou ausente:"        echo "  └─ Verificar configuração Netplan: /etc/netplan/*.yaml"        echo "  └─ Comando: sudo cat /etc/netplan/*.yaml"        echo "  └─ Reconfigurar se necessário e aplicar: sudo netplan apply"    fi         if ! ping -c 1 -W 2 $IP_DC > /dev/null 2>&1; then        echo "• Ping para AD DS falhou:"        echo "  └─ Verificar se VM ID-P-01 está ligada e operacional"        echo "  └─ Verificar configuração de vSwitch no Hyper-V (VLAN 1)"        echo "  └─ Testar conectividade do host: ping xxx.xxx.xxx.xxx"    fi         echo ""    echo -e "\033[31m❌ RECOMENDAÇÃO: Corrija os erros antes de iniciar serviços Docker\033[0m"    echo "" fi`

-  Confirmar mensagem final: **"✓✓✓ TESTE DE CONECTIVIDADE: OK ✓✓✓"**[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Se houver falhas, seguir troubleshooting sugerido pelo script[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

---

## 3️⃣ Verificar e Inicializar Bancos de Dados (Docker Containers)

> 📌 **ORDEM CRÍTICA:** Bancos de dados devem estar ativos **ANTES** das aplicações midPoint e OrangeHRM. Se o midPoint subir sem repositório, entrará em modo de falha e exigirá restart.[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

## 3.1. Contexto de arquitetura

**Configuração REAL do LAB (identificada em 30/12/2025):**

- **PostgreSQL 16** roda como **container Docker** → `midpoint-db`[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- **MariaDB 11.4** roda como **container Docker** → `orangehrm-db`[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

## 3.2. Verificar status dos bancos de dados (Script Docker)

No terminal do Ubuntu (VM IGA-P-01), executar:

bash

`#!/bin/bash # ===== SCRIPT DE VERIFICAÇÃO E INICIALIZAÇÃO DE BANCOS (DOCKER) ===== # Versão: 1.4 - Cold Start LAB Fiqueok # Data: 30/12/2025 echo "" echo "╔════════════════════════════════════════════════════════╗" echo "║  VERIFICAÇÃO DE BANCOS DE DADOS (DOCKER) - IGA-P-01   ║" echo "╚════════════════════════════════════════════════════════╝" echo "" PRECISA_INICIAR=0 ERRO_CRITICO=0 # ========== VERIFICAÇÃO POSTGRESQL 16 (Container: midpoint-db) ========== echo "[1/2] Verificando container: midpoint-db (PostgreSQL 16)..." # Verificar se o container existe if sudo docker ps -a --format '{{.Names}}' | grep -q "^midpoint-db$"; then     # Container existe, verificar se está rodando    if [ "$(sudo docker inspect -f '{{.State.Running}}' midpoint-db 2>/dev/null)" == "true" ]; then        echo -e "      \033[32m✓ Container midpoint-db: RODANDO\033[0m"                 # Verificação adicional: porta 5432 exposta        PORTA_5432=$(sudo docker port midpoint-db 2>/dev/null | grep 5432)        if [ -n "$PORTA_5432" ]; then            echo -e "      \033[32m✓ Porta 5432: EXPOSTA ($PORTA_5432)\033[0m"        else            echo -e "      \033[33m⚠ Porta 5432: Não exposta (pode ser rede interna Docker)\033[0m"        fi    else        echo -e "      \033[33m⚠ Container midpoint-db: PARADO (será iniciado)\033[0m"        PRECISA_INICIAR=1    fi else     echo -e "      \033[31m✗ Container midpoint-db: NÃO ENCONTRADO\033[0m"    echo -e "      \033[31m  └─ ERRO CRÍTICO: Verificar docker-compose.yml\033[0m"    ERRO_CRITICO=1 fi echo "" # ========== VERIFICAÇÃO MARIADB 11.4 (Container: orangehrm-db) ========== echo "[2/2] Verificando container: orangehrm-db (MariaDB 11.4)..." # Verificar se o container existe if sudo docker ps -a --format '{{.Names}}' | grep -q "^orangehrm-db$"; then     # Container existe, verificar se está rodando    if [ "$(sudo docker inspect -f '{{.State.Running}}' orangehrm-db 2>/dev/null)" == "true" ]; then        echo -e "      \033[32m✓ Container orangehrm-db: RODANDO\033[0m"                 # Verificação adicional: porta 3306 exposta        PORTA_3306=$(sudo docker port orangehrm-db 2>/dev/null | grep 3306)        if [ -n "$PORTA_3306" ]; then            echo -e "      \033[32m✓ Porta 3306: EXPOSTA ($PORTA_3306)\033[0m"        else            echo -e "      \033[33m⚠ Porta 3306: Não exposta (pode ser rede interna Docker)\033[0m"        fi    else        echo -e "      \033[33m⚠ Container orangehrm-db: PARADO (será iniciado)\033[0m"        PRECISA_INICIAR=1    fi else     echo -e "      \033[31m✗ Container orangehrm-db: NÃO ENCONTRADO\033[0m"    echo -e "      \033[31m  └─ ERRO CRÍTICO: Verificar docker-compose.yml\033[0m"    ERRO_CRITICO=1 fi echo "" echo "╔════════════════════════════════════════════════════════╗" # ========== DECISÃO: INICIAR OU NOTIFICAR OK ========== if [ $ERRO_CRITICO -eq 1 ]; then     # ERRO CRÍTICO: Container não existe    echo -e "║  \033[31m✗✗✗ ERRO CRÍTICO: CONTAINER NÃO EXISTE ✗✗✗\033[0m        ║"    echo "╚════════════════════════════════════════════════════════╝"    echo ""    echo -e "\033[31m🚫 PONTO DE BLOQUEIO CRÍTICO ATIVADO\033[0m"    echo "═══════════════════════════════════════════════════════"    echo -e "\033[31m⛔ Um ou mais containers de banco NÃO FORAM ENCONTRADOS\033[0m"    echo -e "\033[31m⛔ PARAR IMEDIATAMENTE - VERIFICAR ARQUITETURA\033[0m"    echo "═══════════════════════════════════════════════════════"    echo ""    echo -e "\033[33m📋 AÇÃO OBRIGATÓRIA:\033[0m"    echo "   1. Registrar RNC (Relatório de Não-Conformidade)"    echo "   2. Verificar docker-compose.yml do stack IGA"    echo "   3. Listar todos os containers: sudo docker ps -a"    echo "   4. Consultar GMUDs anteriores de instalação"    echo "" elif [ $PRECISA_INICIAR -eq 0 ]; then     # TODOS OS CONTAINERS JÁ RODANDO    echo -e "║  \033[32m✓✓✓ BANCOS DE DADOS: OK ✓✓✓\033[0m                       ║"    echo "╚════════════════════════════════════════════════════════╝"    echo ""    echo -e "\033[32m✅ Containers midpoint-db e orangehrm-db já estão rodando.\033[0m"    echo -e "\033[32m✅ Nenhuma ação de inicialização necessária.\033[0m"    echo ""    echo -e "\033[36m➜ Próximo passo: Verificar containers de aplicação (midPoint + OrangeHRM)\033[0m"    echo "" else     # PRECISA INICIAR UM OU MAIS CONTAINERS    echo -e "║  \033[33m⚠⚠⚠ CONTAINERS PARADOS - INICIANDO... ⚠⚠⚠\033[0m        ║"    echo "╚════════════════════════════════════════════════════════╝"    echo ""    echo -e "\033[33m⚙️  Um ou mais containers estão parados. Iniciando...\033[0m"    echo ""         # Iniciar midpoint-db se necessário    if [ "$(sudo docker inspect -f '{{.State.Running}}' midpoint-db 2>/dev/null)" != "true" ]; then        echo -e "\033[36m[→] Iniciando container midpoint-db...\033[0m"        sudo docker start midpoint-db        sleep 3                 if [ "$(sudo docker inspect -f '{{.State.Running}}' midpoint-db 2>/dev/null)" == "true" ]; then            echo -e "    \033[32m✓ midpoint-db iniciado com sucesso\033[0m"        else            echo -e "    \033[31m✗ FALHA ao iniciar midpoint-db\033[0m"            echo -e "    \033[31m  └─ Verificar logs: sudo docker logs midpoint-db\033[0m"        fi    fi         echo ""         # Iniciar orangehrm-db se necessário    if [ "$(sudo docker inspect -f '{{.State.Running}}' orangehrm-db 2>/dev/null)" != "true" ]; then        echo -e "\033[36m[→] Iniciando container orangehrm-db...\033[0m"        sudo docker start orangehrm-db        sleep 3                 if [ "$(sudo docker inspect -f '{{.State.Running}}' orangehrm-db 2>/dev/null)" == "true" ]; then            echo -e "    \033[32m✓ orangehrm-db iniciado com sucesso\033[0m"        else            echo -e "    \033[31m✗ FALHA ao iniciar orangehrm-db\033[0m"            echo -e "    \033[31m  └─ Verificar logs: sudo docker logs orangehrm-db\033[0m"        fi    fi         echo ""    echo "╔════════════════════════════════════════════════════════╗"         # Verificação final após inicialização    POSTGRES_OK=$([ "$(sudo docker inspect -f '{{.State.Running}}' midpoint-db 2>/dev/null)" == "true" ] && echo "1" || echo "0")    MARIADB_OK=$([ "$(sudo docker inspect -f '{{.State.Running}}' orangehrm-db 2>/dev/null)" == "true" ] && echo "1" || echo "0")         if [ "$POSTGRES_OK" == "1" ] && [ "$MARIADB_OK" == "1" ]; then        echo -e "║  \033[32m✓✓✓ BANCOS DE DADOS: OK ✓✓✓\033[0m                       ║"        echo "╚════════════════════════════════════════════════════════╝"        echo ""        echo -e "\033[32m✅ Containers de banco iniciados com sucesso.\033[0m"        echo ""        echo -e "\033[36m➜ Próximo passo: Verificar containers de aplicação (midPoint + OrangeHRM)\033[0m"        echo ""    else        echo -e "║  \033[31m✗✗✗ INICIALIZAÇÃO FALHOU ✗✗✗\033[0m                     ║"        echo "╚════════════════════════════════════════════════════════╝"        echo ""        echo -e "\033[31m🚫 PONTO DE BLOQUEIO CRÍTICO ATIVADO\033[0m"        echo "═══════════════════════════════════════════════════════"        echo -e "\033[31m⛔ Um ou mais containers de banco FALHARAM ao iniciar\033[0m"        echo -e "\033[31m⛔ NÃO PROSSEGUIR para containers de aplicação\033[0m"        echo "═══════════════════════════════════════════════════════"        echo ""        echo -e "\033[33m⚠️  TROUBLESHOOTING:\033[0m"        echo "───────────────────────────────────────────────────────"                 if [ "$POSTGRES_OK" == "0" ]; then            echo "• Container midpoint-db não iniciou:"            echo "  └─ Verificar logs: sudo docker logs midpoint-db --tail 100"            echo "  └─ Verificar status: sudo docker inspect midpoint-db"            echo "  └─ Testar manualmente: sudo docker exec -it midpoint-db psql -U midpoint"        fi                 if [ "$MARIADB_OK" == "0" ]; then            echo "• Container orangehrm-db não iniciou:"            echo "  └─ Verificar logs: sudo docker logs orangehrm-db --tail 100"            echo "  └─ Verificar status: sudo docker inspect orangehrm-db"            echo "  └─ Testar manualmente: sudo docker exec -it orangehrm-db mysql -u root -p"        fi                 echo ""        echo -e "\033[33m📋 AÇÃO OBRIGATÓRIA:\033[0m"        echo "   1. Registrar RNC (Relatório de Não-Conformidade)"        echo "   2. Investigar logs dos containers que falharam"        echo "   3. Corrigir problemas antes de continuar"        echo ""    fi fi`

**Checklist após executar o script:**

-  Se mensagem for **"✓✓✓ BANCOS DE DADOS: OK ✓✓✓"** → Containers já rodando, prosseguir para seção 4[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Se mensagem for **"Containers de banco iniciados com sucesso"** → Inicialização concluída, prosseguir para seção 4[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Se houver **ERRO CRÍTICO** → Seguir troubleshooting e registrar RNC[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

> 🚫 **PONTO DE BLOQUEIO:** Se containers de banco falharem, **NÃO prosseguir** para aplicações.[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

---

## 4️⃣ Verificar e Inicializar Containers de Aplicação (midPoint + OrangeHRM)

> 📌 **Contexto:** midPoint 4.10 e OrangeHRM 5.8 rodam containerizados sobre Docker no host IGA-P-01, integrando-se através de redes Docker específicas (midpointlabnet, orangehrmlabnet e fiqueok-backend-net).[evolveum+1](https://docs.evolveum.com/midpoint/install/containers/docker/)​

## 4.1. Verificar status dos containers de aplicação (Script inteligente - v1.6)

No terminal do Ubuntu (VM IGA-P-01), executar:

bash

`#!/bin/bash # ===== SCRIPT DE VERIFICAÇÃO E INICIALIZAÇÃO DE APLICAÇÕES (DOCKER) ===== # Versão: 1.6 - Cold Start LAB Fiqueok # Data: 30/12/2025 13:46 # CORREÇÃO CRÍTICA: Paths e nomes de containers validados em tempo de execução echo "" echo "╔════════════════════════════════════════════════════════╗" echo "║  VERIFICAÇÃO DE CONTAINERS DE APLICAÇÃO - IGA-P-01    ║" echo "╚════════════════════════════════════════════════════════╝" echo "" PRECISA_INICIAR=0 ERRO_CRITICO=0 # ========== CONFIGURAÇÕES VALIDADAS EM TEMPO DE EXECUÇÃO (30/12/2025 13:46) ========== DIRETORIO_STACK="/home/paulo/midpoint_lab" CONTAINER_MIDPOINT="midpoint-server" CONTAINER_ORANGEHRM="orangehrm-app" # ========== VERIFICAÇÃO MIDPOINT 4.10 ========== echo "[1/2] Verificando container: $CONTAINER_MIDPOINT (midPoint 4.10)..." # Verificar se o container existe if sudo docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_MIDPOINT}$"; then     # Container existe, verificar se está rodando    if [ "$(sudo docker inspect -f '{{.State.Running}}' $CONTAINER_MIDPOINT 2>/dev/null)" == "true" ]; then        echo -e "      \033[32m✓ Container $CONTAINER_MIDPOINT: RODANDO\033[0m"                 # Verificação adicional: porta 8080 exposta        PORTA_8080=$(sudo docker port $CONTAINER_MIDPOINT 2>/dev/null | grep 8080)        if [ -n "$PORTA_8080" ]; then            echo -e "      \033[32m✓ Porta 8080: EXPOSTA ($PORTA_8080)\033[0m"        else            echo -e "      \033[33m⚠ Porta 8080: Não detectada (verificar mapeamento)\033[0m"        fi                 # Verificar saúde do container (se healthcheck configurado)        HEALTH=$(sudo docker inspect -f '{{.State.Health.Status}}' $CONTAINER_MIDPOINT 2>/dev/null)        if [ "$HEALTH" == "healthy" ]; then            echo -e "      \033[32m✓ Health check: HEALTHY\033[0m"        elif [ "$HEALTH" == "starting" ]; then            echo -e "      \033[33m⚠ Health check: STARTING (aguardando estabilização)\033[0m"        fi    else        echo -e "      \033[33m⚠ Container $CONTAINER_MIDPOINT: PARADO (será iniciado)\033[0m"        PRECISA_INICIAR=1    fi else     echo -e "      \033[31m✗ Container $CONTAINER_MIDPOINT: NÃO ENCONTRADO\033[0m"    echo -e "      \033[31m  └─ Será criado via docker-compose up\033[0m"    PRECISA_INICIAR=1 fi echo "" # ========== VERIFICAÇÃO ORANGEHRM 5.8 ========== echo "[2/2] Verificando container: $CONTAINER_ORANGEHRM (OrangeHRM 5.8)..." # Verificar se o container existe if sudo docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_ORANGEHRM}$"; then     # Container existe, verificar se está rodando    if [ "$(sudo docker inspect -f '{{.State.Running}}' $CONTAINER_ORANGEHRM 2>/dev/null)" == "true" ]; then        echo -e "      \033[32m✓ Container $CONTAINER_ORANGEHRM: RODANDO\033[0m"                 # Verificação adicional: porta 8081 exposta        PORTA_8081=$(sudo docker port $CONTAINER_ORANGEHRM 2>/dev/null | grep 8081)        if [ -n "$PORTA_8081" ]; then            echo -e "      \033[32m✓ Porta 8081: EXPOSTA ($PORTA_8081)\033[0m"        else            echo -e "      \033[33m⚠ Porta 8081: Não detectada (verificar mapeamento)\033[0m"        fi                 # Verificar saúde do container (se healthcheck configurado)        HEALTH=$(sudo docker inspect -f '{{.State.Health.Status}}' $CONTAINER_ORANGEHRM 2>/dev/null)        if [ "$HEALTH" == "healthy" ]; then            echo -e "      \033[32m✓ Health check: HEALTHY\033[0m"        elif [ "$HEALTH" == "starting" ]; then            echo -e "      \033[33m⚠ Health check: STARTING (aguardando estabilização)\033[0m"        fi    else        echo -e "      \033[33m⚠ Container $CONTAINER_ORANGEHRM: PARADO (será iniciado)\033[0m"        PRECISA_INICIAR=1    fi else     echo -e "      \033[31m✗ Container $CONTAINER_ORANGEHRM: NÃO ENCONTRADO\033[0m"    echo -e "      \033[31m  └─ Será criado via docker-compose up\033[0m"    PRECISA_INICIAR=1 fi echo "" echo "╔════════════════════════════════════════════════════════╗" # ========== DECISÃO: INICIAR OU NOTIFICAR OK ========== if [ $PRECISA_INICIAR -eq 0 ]; then     # TODOS OS CONTAINERS JÁ RODANDO    echo -e "║  \033[32m✓✓✓ CONTAINERS DE APLICAÇÃO: OK ✓✓✓\033[0m               ║"    echo "╚════════════════════════════════════════════════════════╝"    echo ""    echo -e "\033[32m✅ Containers $CONTAINER_MIDPOINT e $CONTAINER_ORANGEHRM já estão rodando.\033[0m"    echo -e "\033[32m✅ Nenhuma ação de inicialização necessária.\033[0m"    echo ""    echo -e "\033[36m➜ Próximo passo: Testes de acesso às aplicações (Seção 5)\033[0m"    echo "" else     # PRECISA INICIAR UM OU MAIS CONTAINERS    echo -e "║  \033[33m⚠⚠⚠ CONTAINERS INATIVOS - INICIANDO STACK... ⚠⚠⚠\033[0m  ║"    echo "╚════════════════════════════════════════════════════════╝"    echo ""    echo -e "\033[33m⚙️  Um ou mais containers estão inativos. Iniciando stack via docker-compose...\033[0m"    echo ""         # Verificar se diretório do stack existe    if [ ! -d "$DIRETORIO_STACK" ]; then        echo -e "\033[31m✗ ERRO: Diretório $DIRETORIO_STACK não encontrado\033[0m"        echo -e "\033[31m  └─ Path validado: $DIRETORIO_STACK\033[0m"        echo -e "\033[31m  └─ Verificar se path está correto ou executar: find ~ -name docker-compose.yml\033[0m"        echo ""        exit 1    fi         # Navegar para diretório do stack    cd "$DIRETORIO_STACK" || exit 1    echo -e "\033[36m[→] Navegando para: $DIRETORIO_STACK\033[0m"         # Verificar se docker-compose.yml existe    if [ ! -f "docker-compose.yml" ]; then        echo -e "\033[31m✗ ERRO: Arquivo docker-compose.yml não encontrado em $DIRETORIO_STACK\033[0m"        echo ""        exit 1    fi         echo -e "\033[36m[→] Executando: docker compose up -d\033[0m"    echo ""         # Executar docker-compose up -d    sudo docker compose up -d         echo ""    echo -e "\033[36m[→] Aguardando estabilização dos containers (15 segundos)...\033[0m"    sleep 15         echo ""    echo "╔════════════════════════════════════════════════════════╗"         # Verificação final após inicialização    MIDPOINT_OK=$([ "$(sudo docker inspect -f '{{.State.Running}}' $CONTAINER_MIDPOINT 2>/dev/null)" == "true" ] && echo "1" || echo "0")    ORANGEHRM_OK=$([ "$(sudo docker inspect -f '{{.State.Running}}' $CONTAINER_ORANGEHRM 2>/dev/null)" == "true" ] && echo "1" || echo "0")         if [ "$MIDPOINT_OK" == "1" ] && [ "$ORANGEHRM_OK" == "1" ]; then        echo -e "║  \033[32m✓✓✓ CONTAINERS DE APLICAÇÃO: OK ✓✓✓\033[0m               ║"        echo "╚════════════════════════════════════════════════════════╝"        echo ""        echo -e "\033[32m✅ Stack IGA iniciado com sucesso!\033[0m"        echo ""        echo -e "\033[36m📊 Status dos containers:\033[0m"        sudo docker ps --filter "name=$CONTAINER_MIDPOINT" --filter "name=$CONTAINER_ORANGEHRM" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"        echo ""        echo -e "\033[33m⏱️  IMPORTANTE: midPoint leva 2-3 minutos para inicializar o Tomcat embarcado.\033[0m"        echo -e "\033[33m   Aguarde antes de testar o acesso via navegador.\033[0m"        echo ""        echo -e "\033[36m➜ Próximo passo: Aguardar estabilização e testar acesso (Seção 5)\033[0m"        echo ""    else        echo -e "║  \033[31m✗✗✗ INICIALIZAÇÃO FALHOU ✗✗✗\033[0m                     ║"        echo "╚════════════════════════════════════════════════════════╝"        echo ""        echo -e "\033[31m🚫 PONTO DE BLOQUEIO CRÍTICO ATIVADO\033[0m"        echo "═══════════════════════════════════════════════════════"        echo -e "\033[31m⛔ Um ou mais containers de aplicação FALHARAM ao iniciar\033[0m"        echo -e "\033[31m⛔ NÃO PROSSEGUIR para testes de acesso\033[0m"        echo "═══════════════════════════════════════════════════════"        echo ""        echo -e "\033[33m⚠️  TROUBLESHOOTING:\033[0m"        echo "───────────────────────────────────────────────────────"                 if [ "$MIDPOINT_OK" == "0" ]; then            echo "• Container $CONTAINER_MIDPOINT não iniciou:"            echo "  └─ Verificar logs: sudo docker logs $CONTAINER_MIDPOINT --tail 100"            echo "  └─ Verificar dependências: containers de banco devem estar rodando"            echo "  └─ Verificar: sudo docker-compose logs $CONTAINER_MIDPOINT"        fi                 if [ "$ORANGEHRM_OK" == "0" ]; then            echo "• Container $CONTAINER_ORANGEHRM não iniciou:"            echo "  └─ Verificar logs: sudo docker logs $CONTAINER_ORANGEHRM --tail 100"            echo "  └─ Verificar dependências: container orangehrm-db deve estar rodando"            echo "  └─ Verificar: sudo docker-compose logs $CONTAINER_ORANGEHRM"        fi                 echo ""        echo "• Verificar status de todos os containers:"        echo "  └─ Comando: sudo docker ps -a"        echo ""        echo "• Verificar logs do docker-compose:"        echo "  └─ Comando: cd $DIRETORIO_STACK && sudo docker-compose logs --tail 50"        echo ""        echo -e "\033[33m📋 AÇÃO OBRIGATÓRIA:\033[0m"        echo "   1. Registrar RNC (Relatório de Não-Conformidade)"        echo "   2. Investigar logs dos containers que falharam"        echo "   3. Verificar se containers de banco estão rodando (Seção 3)"        echo "   4. Corrigir problemas antes de continuar"        echo ""    fi fi`

**Checklist após executar o script:**

-  Se mensagem for **"✓✓✓ CONTAINERS DE APLICAÇÃO: OK ✓✓✓"** → Containers já rodando, prosseguir para seção 5[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Se mensagem for **"Stack IGA iniciado com sucesso"** → Aguardar 2-3 minutos para estabilização do midPoint, prosseguir para seção 5[evolveum+2](https://docs.evolveum.<REDACTED_SECRET>bedded-tomcat/)​
    
-  Se houver **ERRO CRÍTICO** → Seguir troubleshooting e registrar RNC[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

> ⏱️ **TEMPO DE ESTABILIZAÇÃO:** Após inicialização, o midPoint leva aproximadamente **2-3 minutos** para completar o carregamento do Tomcat embarcado. Aguarde este período antes de testar o acesso via navegador.[evolveum+2](https://docs.evolveum.com/midpoint/reference/support-4.10/deployment/stand-alone-deployment/)​

> 🚫 **PONTO DE BLOQUEIO:** Se containers de aplicação falharem, **NÃO prosseguir** para testes de acesso.[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

---

## 5️⃣ Testes de Acesso às Aplicações

> ⏱️ **Antes de iniciar:** Se os containers foram iniciados nesta execução do Cold Start, aguarde **2-3 minutos** para que o midPoint complete a inicialização do Tomcat.[evolveum+2](https://docs.evolveum.<REDACTED_SECRET>bedded-tomcat/)​

No navegador (host Windows ou máquina com rota para VLAN 1):

## 5.1. Acessar console do midPoint

-  Acessar `http://xxx.xxx.xxx.xxx:8080/midpoint`[evolveum+1](https://docs.evolveum.com/midpoint/install/containers/docker/)​
    
-  Fazer login com usuário **administrator**[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Confirmar carregamento completo do dashboard[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

**Se receber erro de conexão ou timeout:**

- Aguardar mais 1-2 minutos (Tomcat ainda inicializando)[evolveum+1](https://docs.evolveum.com/midpoint/reference/support-4.10/deployment/stand-alone-deployment/)​
    
- Verificar logs: `sudo docker logs midpoint-server --tail 50`[evolveum](https://docs.evolveum.com/midpoint/install/containers/docker/)​
    
- Procurar por mensagem "Server startup in [XXXX] milliseconds" nos logs[evolveum](https://docs.evolveum.<REDACTED_SECRET>bedded-tomcat/)​
    

## 5.2. Acessar interface do OrangeHRM

-  Acessar `http://xxx.xxx.xxx.xxx:8081`[mariushosting+1](https://mariushosting.com/how-to-install-orangehrm-on-your-synology-nas/)​
    
-  Fazer login com conta administrativa de RH[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Confirmar carregamento da interface principal[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

---

## 6️⃣ Pre-Flight Check - Validação de Integridade do Sistema

> 🔍 **Objetivo:** Confirmar que o ambiente está no **estado de referência** esperado antes de qualquer mudança.[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

## 6.1. Teste de conexão com recurso OrangeHRM (no midPoint) ⭐

No console do midPoint:

-  **Resources** → **All resources** → **OrangeHRM-Source-v4.2**[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Clicar em **Test connection**[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Confirmar status **Success** (verde)[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

> 🚀 **DECISÃO CRÍTICA:** Se Test Connection der **Success**, o midPoint está comunicando corretamente com o OrangeHRM. **PROSSIGA** para próximas atividades planejadas.

**Se falhar:** Capturar print, verificar container orangehrm-db (porta 3306) e credenciais do recurso.[hub.docker+1](https://hub.docker.com/_/mariadb)​

## 6.2. Verificação de sincronização de inventário ⭐

**VALIDAÇÃO DE ESTADO DE SINCRONIZAÇÃO:**

-  Aba **Accounts** do recurso OrangeHRM-Source-v4.2[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Verificar se o inventário de contas está **visível e acessível**[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Confirmar timestamp da última sincronização (se disponível)[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

> 📌 **Significado:** Esta validação confirma que o midPoint consegue listar contas do OrangeHRM. O **status específico** das contas (Linked, Unmatched, etc.) depende da configuração de correlação e mapeamento, que deve ser tratada em GMUDs específicas.[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

> ⚠️ **Nota importante:** A presença de contas com status "Unmatched" **não indica falha** neste procedimento de Cold Start. Isso é esperado quando as regras de correlação ainda não foram configuradas ou estão em processo de ajuste.[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

**Se o inventário não aparecer ou estiver vazio:**

- Verificar se a tarefa de importação foi executada pelo menos uma vez[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- Verificar conectividade com o banco orangehrm-db[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- Consultar logs do recurso OrangeHRM no midPoint[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

## 6.3. Verificação de status de tarefas

-  **Server tasks** → **List tasks**[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Localizar tarefa **Import OrangeHRM Identities**[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Verificar último status de execução (CLOSED, SUCCESS, ERROR)[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

**Se a tarefa estiver RUNNING sem ter sido iniciada manualmente:**

- Verificar se há agendamento automático configurado[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- Se não esperado, pausar tarefa e investigar[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

**Se a tarefa estiver em ERROR:**

- Capturar mensagem de erro[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- Verificar logs detalhados da tarefa[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- Registrar RNC se necessário[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

---

## 7️⃣ Registro de Conclusão (Formato Lean)

## 7.1. Criar log diário no Obsidian

**Caminho:** `10_Projetos/PRJ001- LABORATORIO DE SI/30_Operacao & Mudancas/`  
**Nome:** `LOG-COLD-START-YYYY-MM-DD.md`

**Template otimizado (30 segundos de preenchimento):**

text

`# Cold Start - DD/MM/YYYY **Técnico:** [Nome]   **Início:** HH:MM | **Fim:** HH:MM   ## Status Geral - [ ] ✅ **ALL GREEN** - Todos os critérios de sucesso atendidos - [ ] ⚠️ **YELLOW** - Sistema operacional com restrições (detalhar abaixo) - [ ] ❌ **RED** - Sistema indisponível (RNC obrigatória) ## Exceções e Observações <!-- Preencher SOMENTE se houver desvios do fluxo padrão --> **Itens que falharam:** - Nenhum / [Descrever] **Ações corretivas aplicadas:** - N/A / [Descrever] **Pendências para próximo Cold Start:** - Nenhuma / [Listar] ## Validação Pre-Flight ✓ - [ ] AD DS (xxx.xxx.xxx.xxx) respondendo - [ ] Containers midpoint-db + orangehrm-db rodando - [ ] Containers midpoint-server + orangehrm-app rodando - [ ] midPoint acessível (http://xxx.xxx.xxx.xxx:8080/midpoint) - [ ] OrangeHRM acessível (http://xxx.xxx.xxx.xxx:8081) - [ ] Test connection OrangeHRM: **Success** ⭐ - [ ] Inventário de contas visível e acessível - [ ] Última execução de tarefa Import: [Status] --- **RNC aberta:** Nenhuma / [Link]   **Próxima atividade:** [Descrever atividade planejada]`

---

## 📊 Critérios de Sucesso (Checklist Final)

O Cold Start está **concluído com sucesso** quando:

1. ✅ AD DS (xxx.xxx.xxx.xxx) responde em LDAP (porta 389)[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
2. ✅ Containers **midpoint-db** e **orangehrm-db** rodando[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
3. ✅ Containers **midpoint-server** e **orangehrm-app** rodando[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
4. ✅ Console midPoint acessível via navegador ([http://xxx.xxx.xxx.xxx:8080/midpoint)[2](http://xxx.xxx.xxx.xxx:8080/midpoint\)%5B2)][ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
5. ✅ Interface OrangeHRM acessível via navegador ([http://xxx.xxx.xxx.xxx:8081)[5](http://xxx.xxx.xxx.xxx:8081\)%5B5/)][ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
6. ✅ **Test connection do recurso OrangeHRM retorna Success** ⭐ (critério decisivo)[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
7. ✅ **Inventário de contas do OrangeHRM está visível** no midPoint[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
8. ✅ Tarefas de importação sem erros críticos de execução[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

---

## 🚫 Pontos de Bloqueio Críticos

**NÃO prosseguir com atividades do LAB se:**

- ❌ AD DS (xxx.xxx.xxx.xxx) não responder - **Severity: CRÍTICO**[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- ❌ Containers de banco não iniciarem - **Severity: CRÍTICO**[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- ❌ Containers de aplicação não iniciarem - **Severity: CRÍTICO**[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- ❌ **Test connection OrangeHRM falhar** - **Severity: CRÍTICO** (este é o critério decisivo)[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

**Ação obrigatória:** Registrar RNC e investigar causa raiz.[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

---

## 🎯 Próxima Ação Técnica

Após conclusão do Cold Start com **Test Connection = Success**, prosseguir com as atividades planejadas do dia conforme roadmap do projeto.[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

---

## 🔗 Referências

- **GMUD-007:** Alteração de Endereçamento IP Estático[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- **GMUD-008:** Implantação da Stack midPoint 4.10[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- **GMUD-011:** Rede de Integração Segura Backend Bridge[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- **REL-GMUD-014:** Integração AD e IGA - Suspensão Técnica[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- **Manifesto Fiqueok v2.0:** Arquitetura e Governança do LAB[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

---

## 📝 Changelog

|Versão|Data|Autor|Mudanças|
|---|---|---|---|
|1.0|30/12/2025|Paulo Feitosa|Criação inicial do procedimento|
|1.1|30/12/2025|Paulo Feitosa|Otimização baseada em feedback Gemini (Deep-Dive)|
|1.2|30/12/2025|Paulo Feitosa|Ajustes de perfil, scripts melhorados com troubleshooting|
|1.3|30/12/2025|Paulo Feitosa|Script inteligente de verificação/inicialização de DBs|
|1.4|30/12/2025|Paulo Feitosa|Correção crítica: validação de containers Docker para DBs|
|1.5|30/12/2025|Paulo Feitosa|Script inteligente para containers de aplicação (Seção 4)|
|1.6|30/12/2025|Paulo Feitosa|Correção: Path e nomes de containers validados em runtime|
|1.7|30/12/2025|Paulo Feitosa|🔧 Seção 6.2 ajustada para validação genérica de inventário|

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

text

`10_Projetos/PRJ001- LABORATORIO DE SI/30_Operacao & Mudancas/POP-LAB-001-Cold-Start.md`

**Referência cruzada (opcional):**

text

`20_Areas/01_SGSI_Fiqueok/05_Operacao_e_Procedimentos/[Link para POP-LAB-001]`

---

Este procedimento deve ser executado **diariamente** antes de qualquer GMUD, teste ou experimento no LAB PRJ001.[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

1. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)
2. [https://docs.evolveum.com/midpoint/install/containers/docker/](https://docs.evolveum.com/midpoint/install/containers/docker/)
3. [https://docs.evolveum.<REDACTED_SECRET>bedded-tomcat/](https://docs.evolveum.<REDACTED_SECRET>bedded-tomcat/)
4. [https://docs.evolveum.com/midpoint/reference/support-4.10/deployment/stand-alone-deployment/](https://docs.evolveum.com/midpoint/reference/support-4.10/deployment/stand-alone-deployment/)
5. [https://mariushosting.com/how-to-install-orangehrm-on-your-synology-nas/](https://mariushosting.com/how-to-install-orangehrm-on-your-synology-nas/)
6. [https://hub.docker.com/_/mariadb](https://hub.docker.com/_/mariadb)
