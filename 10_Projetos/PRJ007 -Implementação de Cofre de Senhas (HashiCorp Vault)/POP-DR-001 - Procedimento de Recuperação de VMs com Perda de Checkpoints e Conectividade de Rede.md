

**Status:** Ativo  
**Versão:** 1.1  
**Data de Atualização:** 12/02/2026  
**Tipo:** POP - Disaster Recovery  
**Owner:** Paulo Feitosa  
**Classificação:** Crítico

---

## **Changelog v1.1 (12/02/2026)**

- **ADIÇÃO:** Seção 5.3.0 - Tratamento de Bloqueio de Arquivo (Handle Lock) com procedimento para erro 0x80070020
    
- **CORREÇÃO:** Seção 5.2.3 - Nota técnica priorizando `Convert-VHD` sobre `Merge-VHD` para resiliência
    
- **ADIÇÃO:** Seção 10.4 - Regra de Ouro para migração de disco consolidado do drive externo para C: após estabilização
    
- **MELHORIA:** Seção 5.5.2 - Configuração de Netplan simplificada e validada em ambiente real
    
- **ADIÇÃO:** Seção 6.3 - Checklist de Encerramento expandido com validações críticas
    
- **ATUALIZAÇÃO:** Seção 11 - Referências incluindo incidente de recuperação IGA-GF-01 (Fev/2026)
    

---

## **1. Objetivo**

Recuperar máquinas virtuais (OrangeHRM, LDAP, AD) no Hyper-V que perderam suas conexões de rede e histórico em pontos de verificação (checkpoints), consolidando discos diferenciais (.avhdx) em discos únicos (.vhdx) e reconfigurando a conectividade de rede.​

---

## **2. Escopo**

**Máquinas abrangidas:**

- **FOK-SRV-LDAP-01** - Servidor LDAP
    
- **VAULT-GEN1** - HashiCorp Vault (recuperada em 10/02/2026)
    
- **OrangeHRM/midPoint (IGA-GF-01)** - Sistema de RH e governança de identidades (recuperada em 10/02/2026)
    
- **AD DS (ID-P-01)** - Active Directory Domain Services
    

**Máquinas excluídas:**

- **IGA-P-01** (já foi recuperada no documento anexo)​
    

---

## **3. Pré-requisitos**

## **3.1. Hardware e Software**

- Acesso administrativo ao Windows Host (Hyper-V Manager)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/688e9baf-443d-4ddd-947b-22baff0e2862/POP-LAB-001-Cold-Start-Diario-v1.7.md)
    
- **Espaço em disco externo mínimo:** 50GB + 20% do tamanho do disco da VM
    
- PowerShell com privilégios de administrador
    
- Console Hyper-V aberto como fallback para reconexão
    
- **Drive de backup externo:** Recomendado D: (USB 3.0 ou superior para IOPS adequado)
    

## **3.2. Conhecimentos Necessários**

- Operação de Hyper-V Manager
    
- Comandos PowerShell: `Get-VHD`, `Convert-VHD`, `Get-VMCheckpoint`, `Restart-Service`
    
- Configuração de Netplan (Ubuntu)​
    
- Validação de serviços AD DS e Docker[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/366f258b-e506-4d6e-847b-20919b159980/POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md)
    
- Gerenciamento de Disco Windows (para desanexar VHDs montados)
    

## **3.3. Credenciais**

- Usuário Windows com privilégios de administrador
    
- Credenciais de acesso às VMs Ubuntu e Windows Server
    
- Acesso ao vault de senhas Fiqueok (Obsidian ou gerenciador)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/688e9baf-443d-4ddd-947b-22baff0e2862/POP-LAB-001-Cold-Start-Diario-v1.7.md)
    

---

## **4. Diagnóstico Inicial**

## **4.1. Identificar VMs Afetadas**

No **PowerShell como Administrador**, execute:​

powershell

`# Listar VMs e seus checkpoints Get-VM | ForEach-Object {     Write-Host "VM: $($_.Name) - Status: $($_.State)" -ForegroundColor Cyan    Get-VMCheckpoint -VMName $_.Name | Format-Table Name, CreationTime }`

## **4.2. Verificar Discos Diferenciais**

powershell

`# Localizar arquivos .avhdx (checkpoints) Get-ChildItem "C:\ProgramData\Microsoft\Windows\Snapshots" -Filter *.avhdx -Recurse |      Format-Table Name, LastWriteTime, @{Name="Size(GB)";Expression={[math]::Round($_.Length/1GB,2)}}`

## **4.3. Identificar Problemas de Rede**

Sintomas comuns:​

- VM liga mas não obtém IP via DHCP
    
- IP estático configurado em subnet inexistente (ex: `192.168.70.10` quando Default Switch usa `172.26.x.x`)
    
- Perda de conectividade após reinício do host
    
- Erro "Host de destino inacessível" ao tentar ping
    

---

## **5. Procedimento de Recuperação**

## **IMPORTANTE - Ponto de Bloqueio Crítico**

**NÃO prossiga se:**

- VM estiver em uso ou ligada[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/366f258b-e506-4d6e-847b-20919b159980/POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md)
    
- Backup não foi realizado​
    
- Espaço em disco insuficiente (verifique com `Get-PSDrive`)
    
- Serviço VMMS do Hyper-V estiver instável
    

---

## **5.1. Backup de Segurança (Obrigatório)**

## **5.1.1. Criar Pasta de Backup**

powershell

`# No drive externo (exemplo: D:) $BackupPath = "D:\BkpVM_DR_$(Get-Date -Format 'yyyyMMdd_HHmm')" New-Item -Path $BackupPath -ItemType Directory Set-Location $BackupPath Write-Host "Backup será salvo em: $BackupPath" -ForegroundColor Green`

## **5.1.2. Copiar Discos VHDX e AVHDX**

Para cada VM afetada (exemplo: FOK-SRV-LDAP-01):​

powershell

`# Desligar VM (se estiver ligada) $VMName = "FOK-SRV-LDAP-01" if ((Get-VM -Name $VMName).State -eq "Running") {     Stop-VM -Name $VMName -Force    Write-Host "VM $VMName desligada" -ForegroundColor Yellow    Start-Sleep -Seconds 5 } # Obter caminho do disco principal $VHDPath = (Get-VMHardDiskDrive -VMName $VMName).Path Write-Host "Disco principal: $VHDPath" -ForegroundColor Cyan # Copiar disco e checkpoints relacionados Copy-Item -Path $VHDPath -Destination $BackupPath -Verbose Copy-Item -Path "C:\ProgramData\Microsoft\Windows\Snapshots\*$VMName*" -Destination $BackupPath -Recurse -ErrorAction SilentlyContinue`

## **5.1.3. Validar Backup**

powershell

`# Verificar tamanho total copiado $BackupSize = (Get-ChildItem $BackupPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB Write-Host "Backup realizado: $([math]::Round($BackupSize,2)) GB" -ForegroundColor Green # Validar integridade do arquivo principal if (Test-Path "$BackupPath\*.vhdx") {     Write-Host "✓ Arquivo VHDX copiado com sucesso" -ForegroundColor Green } else {     Write-Host "✗ ERRO: Arquivo VHDX não foi copiado!" -ForegroundColor Red    exit }`

---

## **5.2. Consolidação de Discos Diferenciais**

## **5.2.1. Identificar Checkpoint Mais Recente**

powershell

`# Buscar todos os AVHDXs da VM no backup $VMName = "FOK-SRV-LDAP-01" $CheckpointFiles = Get-ChildItem "$BackupPath\*$VMName*.avhdx" -ErrorAction SilentlyContinue if ($CheckpointFiles) {     $LatestCheckpoint = $CheckpointFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1    Write-Host "Checkpoint mais recente: $($LatestCheckpoint.Name)" -ForegroundColor Cyan    Write-Host "Data de criação: $($LatestCheckpoint.LastWriteTime)" -ForegroundColor Yellow } else {     Write-Host "Nenhum checkpoint encontrado. Usando disco base VHDX." -ForegroundColor Yellow }`

## **5.2.2. Inspecionar Cadeia de Discos**

powershell

``# Verificar ParentPath (disco pai) para entender a hierarquia if ($LatestCheckpoint) {     $DiskInfo = Get-VHD -Path $LatestCheckpoint.FullName    Write-Host "`nInformações do disco diferencial:" -ForegroundColor Cyan    $DiskInfo | Format-List Path, ParentPath, FileSize, VhdType }``

## **5.2.3. Consolidar em Disco Único**

**NOTA TÉCNICA CRÍTICA:**  
✅ **Use `Convert-VHD`** (recomendado) - Cria disco independente sem modificar origem  
❌ **Evite `Merge-VHD`** - Altera arquivos fonte e pode causar perda de dados​

powershell

``$VMName = "FOK-SRV-LDAP-01" $SourceDisk = if ($LatestCheckpoint) { $LatestCheckpoint.FullName } else { "$BackupPath\$VMName.vhdx" } $DestinationVHDX = "$BackupPath\$VMName`_FINAL_RECUPERADA.vhdx" Write-Host "`nIniciando consolidação de disco..." -ForegroundColor Yellow Write-Host "Origem: $SourceDisk" -ForegroundColor Gray Write-Host "Destino: $DestinationVHDX" -ForegroundColor Gray Convert-VHD -Path $SourceDisk -DestinationPath $DestinationVHDX -VHDType Dynamic -Verbose if (Test-Path $DestinationVHDX) {     $FinalSize = (Get-Item $DestinationVHDX).Length / 1GB    Write-Host "`n✓ Conversão concluída com sucesso!" -ForegroundColor Green    Write-Host "Disco consolidado: $([math]::Round($FinalSize,2)) GB" -ForegroundColor Green } else {     Write-Host "✗ ERRO: Falha na conversão do disco!" -ForegroundColor Red    exit }``

**Tempo estimado:** 5-20 minutos por VM (varia conforme tamanho e velocidade do disco)​

---

## **5.3. Reconfiguração da VM no Hyper-V**

## **5.3.0. Tratamento de Bloqueio de Arquivo (Handle Lock)**

**NOVO - v1.1:** Este passo previne o erro crítico `0x80070020` (arquivo em uso)​

## **5.3.0.1. Verificar Bloqueios Ativos**

powershell

`# Reiniciar serviço de gerenciamento do Hyper-V Write-Host "Reiniciando serviço VMMS para liberar handles..." -ForegroundColor Yellow Restart-Service vmms -Force Start-Sleep -Seconds 10 Write-Host "✓ Serviço VMMS reiniciado" -ForegroundColor Green`

## **5.3.0.2. Desanexar VHDs Montados Acidentalmente**

1. Pressione **Win + X** → **Gerenciamento de Disco**
    
2. Procure por discos com ícone **azul de CD/DVD** (VHDs montados)
    
3. Se encontrar o disco da VM:
    
    - Clique com botão direito no disco
        
    - Selecione **Desanexar VHD**
        
    - Marque a opção **"Excluir o arquivo de disco rígido virtual após remover o disco"** (se aplicável)
        

## **5.3.0.3. Validar Liberação**

powershell

``# Tentar acessar o arquivo (não deve gerar erro) $TestVHD = "$BackupPath\$VMName`_FINAL_RECUPERADA.vhdx" try {     $Stream = [System.IO.File]::Open($TestVHD, 'Open', 'Read', 'None')    $Stream.Close()    Write-Host "✓ Arquivo está livre de bloqueios" -ForegroundColor Green } catch {     Write-Host "✗ Arquivo ainda está bloqueado: $($_.Exception.Message)" -ForegroundColor Red    Write-Host "Aguarde 30 segundos e tente novamente..." -ForegroundColor Yellow    Start-Sleep -Seconds 30 }``

---

## **5.3.1. Remover Disco Antigo**

1. Abra **Hyper-V Manager**
    
2. Clique com botão direito na VM → **Configurações**
    
3. Vá em **Controladora SCSI** (ou IDE para Gen1) → **Disco Rígido**
    
4. Selecione o disco atual e clique em **Remover**
    
5. **NÃO marque** a opção "Excluir arquivo físico" (manter backup)
    

## **5.3.2. Adicionar Disco Recuperado**

1. Clique em **Adicionar** → **Disco Rígido**
    
2. Selecione **Disco Rígido Virtual**
    
3. Navegue até `D:\BkpVM_DR_*\FOK-SRV-LDAP-01_FINAL_RECUPERADA.vhdx`
    
4. Clique **Aplicar** → **OK**
    

## **5.3.3. Verificar Adaptador de Rede**

**CRÍTICO:** Antes de ligar a VM​

1. Em **Configurações da VM** → **Adaptador de Rede**
    
2. Verificar se está conectado ao **Default Switch**
    
3. Se houver erro "Configuração inválida":
    
    - Remover adaptador
        
    - Adicionar novo **Adaptador de Rede**
        
    - Conectar ao **Default Switch**
        

---

## **5.4. Inicialização e Validação Básica**

## **5.4.1. Iniciar VM com Monitoramento**

powershell

`# Abrir console antes de ligar (fallback crítico) vmconnect.exe localhost $VMName # Iniciar VM Start-VM -Name $VMName Write-Host "VM $VMName iniciada. Aguarde 60-90 segundos para boot completo..." -ForegroundColor Yellow Start-Sleep -Seconds 90 # Verificar estado Get-VM -Name $VMName | Select-Object Name, State, Status, Uptime`

## **5.4.2. Validar Boot Inicial**

No **console Hyper-V** (não via SSH ainda):

- **Ubuntu:** Deve chegar na tela de login
    
- **Windows Server:** Deve exibir Ctrl+Alt+Del para login
    

**Se houver erro de boot:**

1. Verificar Event Viewer → Hyper-V-Worker
    
2. Confirmar se BIOS/UEFI está configurado corretamente
    
3. Validar integridade do disco: `Test-VHD -Path "D:\...\*_FINAL_RECUPERADA.vhdx"`
    

---

## **5.5. Reconfiguração de Rede (Ubuntu)**

## **5.5.1. Verificar IP Atual**

No **console da VM Ubuntu**:​

bash

`ip a`

**Problema comum:** IP estático antigo (ex: `192.168.70.10`) não pertence à subnet do Default Switch (`172.26.x.x`).

## **5.5.2. Reconfigurar Netplan para DHCP**

**ATUALIZADO - v1.1:** Configuração simplificada e validada​

bash

`# Fazer backup da configuração antiga sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.bak # Editar arquivo de configuração sudo nano /etc/netplan/50-cloud-init.yaml`

**Substituir TODO o conteúdo por**:​

text

`network:   version: 2  ethernets:    eth0:      dhcp4: true`

**⚠️ ATENÇÃO:** YAML é sensível a indentação. Use **2 espaços** (não TAB).

**Aplicar configuração com timeout de segurança:**

bash

`# Modo seguro: reverte automaticamente após 30s se conexão cair sudo netplan try --timeout 30`

Se tudo funcionar, pressione **Enter** para confirmar. Caso contrário, aguarde 30s e a configuração antiga será restaurada.

## **5.5.3. Validar Novo IP**

bash

`# Verificar IP atribuído (deve estar em 172.26.x.x) ip a | grep inet # Testar conectividade externa ping -c 4 8.8.8.8 # Testar resolução DNS nslookup google.com`

**Resultado esperado:**

- IP na faixa `172.26.x.x`
    
- Ping com 0% de perda
    
- DNS resolvendo corretamente​
    

---

## **5.6. Reinstalar Tailscale (Rede Segura)**

Se a VM usa Tailscale para acesso remoto Zero Trust:​

bash

`# Remover instalação corrupta sudo tailscale down sudo apt-get remove --purge tailscale -y sudo rm -rf /var/lib/tailscale/ # Reinstalar versão mais recente curl -fsSL https://tailscale.com/install.sh | sh # Autenticar com hostname descritivo sudo tailscale up --hostname=fok-srv-ldap-01 --force-reauth`

**Ação obrigatória:** Copie o link de autenticação exibido e cole no navegador Windows para autorizar o dispositivo.

**Validar conexão:**

bash

`# Verificar status tailscale status # Obter IP Tailscale tailscale ip -4 # Testar ping para outro nó (ex: Vault) ping -c 4 100.x.x.x`

---

## **5.7. Reconfiguração de Rede (Windows Server - AD DS)**

## **5.7.1. Verificar IP do Servidor**

No console Windows Server:[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/688e9baf-443d-4ddd-947b-22baff0e2862/POP-LAB-001-Cold-Start-Diario-v1.7.md)

powershell

`Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like "172.16.*"} |      Format-Table IPAddress, InterfaceAlias, PrefixLength`

**IP esperado:** `xxx.xxx.xxx.xxx` (conforme arquitetura).​

## **5.7.2. Reconfigurar IP Estático (se necessário)**

Se o IP não estiver correto:

powershell

``# Obter interface ativa $Interface = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} # Remover IP antigo (se existir) Remove-NetIPAddress -InterfaceIndex $Interface.ifIndex -Confirm:$false -ErrorAction SilentlyContinue Remove-NetRoute -InterfaceIndex $Interface.ifIndex -Confirm:$false -ErrorAction SilentlyContinue # Configurar IP estático (AD DS) New-NetIPAddress -InterfaceIndex $Interface.ifIndex -IPAddress xxx.xxx.xxx.xxx `                  -PrefixLength 24 -DefaultGateway xxx.xxx.xxx.xxx # Configurar DNS (apontar para si mesmo - loopback) Set-DnsClientServerAddress -InterfaceIndex $Interface.ifIndex -ServerAddresses 127.0.0.1 Write-Host "IP configurado: xxx.xxx.xxx.xxx" -ForegroundColor Green``

## **5.7.3. Validar Serviços AD DS**

Execute o script de validação:[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/366f258b-e506-4d6e-847b-20919b159980/POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md)

powershell

`# Testar porta LDAP Test-NetConnection -ComputerName xxx.xxx.xxx.xxx -Port 389 -InformationLevel Detailed # Validar serviços críticos Get-Service NTDS, DNS, Netlogon, ADWS | Format-Table Name, Status, StartType # Testar resolução DNS do domínio Resolve-DnsName -Name corp.fiqueok.com.br -Server 127.0.0.1`

**Resultado esperado:**

- Porta 389 (LDAP) acessível
    
- Todos os serviços **Running**
    
- Domínio resolve para `xxx.xxx.xxx.xxx`[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/688e9baf-443d-4ddd-947b-22baff0e2862/POP-LAB-001-Cold-Start-Diario-v1.7.md)
    

**Se serviço NTDS não iniciar:**

powershell

`# Verificar logs de erro Get-EventLog -LogName "Directory Service" -Newest 20 -EntryType Error # Tentar reparar database AD ntdsutil "activate instance ntds" "files" "integrity" quit quit`

---

## **5.8. Validar Serviços Docker (IGA-GF-01)**

## **5.8.1. Localizar Diretório do Projeto**

No console Ubuntu:​

bash

`# Procurar docker-compose.yml find ~ -name "docker-compose.yml" 2>/dev/null # Se não encontrar, verificar locais comuns ls -la /srv/iga-project ls -la ~/midpoint-lab ls -la ~/docker/iga`

**Problema comum:** Arquivos podem ter sido perdidos com os checkpoints.​

## **5.8.2. Verificar Containers**

bash

`# Listar todos os containers (rodando e parados) docker ps -a # Verificar redes Docker docker network ls`

## **5.8.3. Reiniciar Stack Docker**

Se os containers existirem mas estiverem parados:

bash

`# Navegar para diretório do projeto cd /srv/iga-project  # ajuste conforme encontrado # Subir bancos de dados PRIMEIRO docker start iga-postgres orangehrm-db sleep 10 # Subir aplicações docker compose up -d # Aguardar estabilização sleep 15 # Validar status docker ps docker logs iga-midpoint --tail 50`

## **5.8.4. Testar Acesso Web**

No navegador Windows:​

**Via IP local:**

- midPoint: `http://172.26.x.x:8080/midpoint`
    
- OrangeHRM: `http://172.26.x.x:8081`
    

**Via Tailscale (recomendado):**

- midPoint: `http://100.x.x.x:8080/midpoint`
    
- OrangeHRM: `http://100.x.x.x:8081`
    

**Credenciais padrão midPoint:**

- Usuário: `administrator`
    
- Senha: (verificar vault de senhas)
    

---

## **6. Validação Pós-Recuperação**

## **6.1. Checklist de Conectividade**

Para cada VM recuperada:[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/366f258b-e506-4d6e-847b-20919b159980/POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md)

|**Item**|**Comando**|**Resultado Esperado**|
|---|---|---|
|VM iniciada|`Get-VM -Name <VM>`|State = Running|
|IP atribuído|`ip a` (Linux) ou `ipconfig` (Windows)|IP na subnet correta|
|Ping para gateway|`ping 172.26.32.1` ou `ping xxx.xxx.xxx.xxx`|0% perda|
|Ping para Internet|`ping 8.8.8.8`|0% perda|
|DNS funcional|`nslookup google.com`|Resolução com sucesso|
|Tailscale ativo|`tailscale status`|Connected|
|Serviços críticos|`docker ps` ou `Get-Service NTDS`|Serviços ativos|

## **6.2. Teste de Integração**

## **6.2.1. Validar AD DS**

No host Windows:[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/688e9baf-443d-4ddd-947b-22baff0e2862/POP-LAB-001-Cold-Start-Diario-v1.7.md)

powershell

`# Resolver domínio Resolve-DnsName -Name corp.fiqueok.com.br -Server xxx.xxx.xxx.xxx # Testar autenticação de domínio Test-ComputerSecureChannel -Server ID-P-01 -Verbose # Listar DCs disponíveis nltest /dclist:corp.fiqueok.com.br`

## **6.2.2. Validar Integração LDAP → midPoint**

No navegador, acesse midPoint e execute:

1. **Configuration** → **Repository Objects** → **Resources**
    
2. Localizar recurso **AD DS (LDAP)**
    
3. Clicar em **Test Connection**
    
4. Resultado esperado: **Success** com mensagem verde
    

## **6.2.3. Validar Provisionamento JML (Opcional)**

Se já havia integração configurada:

1. Criar usuário de teste no OrangeHRM
    
2. Aguardar 5 minutos (sincronização)
    
3. Verificar se conta foi criada no AD via ADUC (Active Directory Users and Computers)
    

---

## **6.3. Checklist de Encerramento (Selo de Auditoria)**

**NOVO - v1.1:** Checklist expandido para validação completa

text

`[ ] VM inicia sem erros de checkpoint ou disco? [ ] Disco consolidado (_FINAL_RECUPERADA.vhdx) está em unidade segura (D:)? [ ] Conectividade de rede validada (IP correto, gateway, DNS)? [ ] Tailscale operacional (se aplicável)? [ ] Serviços críticos iniciando automaticamente? [ ] Senhas administrativas validadas ou prontas para reset? [ ] Logs de auditoria registrados (quem, quando, o quê)? [ ] Backup dos discos originais preservado (não deletado)? [ ] RNC gerada se houve desvios do procedimento? [ ] Documentação atualizada no Obsidian/OneNote?`

---

## **7. Troubleshooting**

## **7.1. Erro "Arquivo já está sendo usado" (0x80070020)**

**Causa:** Windows Explorer, Backup do Windows ou serviço VMMS está bloqueando o arquivo.​

**Solução:**

powershell

`# 1. Reiniciar serviço do Hyper-V Restart-Service vmms -Force Start-Sleep -Seconds 10 # 2. Verificar processos usando o arquivo (Sysinternals Handle.exe) # Baixar: https://learn.microsoft.com/sysinternals/downloads/handle .\handle.exe -a -l | Select-String "LDAP-01" # 3. Desanexar VHD pelo Gerenciamento de Disco # Win + X → Gerenciamento de Disco # Localizar disco com ícone azul # Botão direito → Desanexar VHD # 4. Verificar se Windows Backup está rodando Get-Process -Name *backup*, *vss* -ErrorAction SilentlyContinue`

## **7.2. VM não obtém IP via DHCP**

**Causa:** Netplan configurado com IP estático ou cloud-init sobrescrevendo configuração.​

**Solução:**

bash

`# Desabilitar cloud-init temporariamente sudo touch /etc/cloud/cloud-init.disabled # Remover configuração antiga sudo rm /etc/netplan/50-cloud-init.yaml # Criar nova configuração limpa sudo nano /etc/netplan/01-netcfg.yaml`

Conteúdo:

text

`network:   version: 2  renderer: networkd  ethernets:    eth0:      dhcp4: true`

Aplicar:

bash

`sudo netplan apply sudo systemctl restart systemd-networkd`

## **7.3. AD DS não responde na porta LDAP (389)**

**Causa:** Serviço NTDS não iniciou ou firewall bloqueando.[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/366f258b-e506-4d6e-847b-20919b159980/POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md)

**Solução:**

powershell

`# No console do servidor AD Start-Service NTDS Start-Sleep -Seconds 30 Get-Service NTDS | Select-Object Status # Verificar logs Get-EventLog -LogName "Directory Service" -Newest 10 -EntryType Error | Format-List # Testar porta localmente Test-NetConnection -ComputerName localhost -Port 389 # Verificar regras de firewall Get-NetFirewallRule -DisplayName "*LDAP*" | Select-Object DisplayName, Enabled, Direction`

Se serviço não iniciar:

powershell

`# Verificar integridade do database ntdsutil "activate instance ntds" "files" "info" quit quit # Reparar se necessário ntdsutil "activate instance ntds" "files" "integrity" quit quit`

## **7.4. Containers Docker não iniciam**

**Causa:** Banco de dados não está rodando ou rede Docker corrompida.[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/688e9baf-443d-4ddd-947b-22baff0e2862/POP-LAB-001-Cold-Start-Diario-v1.7.md)

**Solução:**

bash

`# Verificar containers de banco docker ps -a | grep -E "postgres|mariadb" # Iniciar bancos manualmente docker start iga-postgres orangehrm-db # Verificar logs de erro docker logs iga-postgres --tail 100 docker logs orangehrm-db --tail 100 # Se rede estiver corrompida docker network prune -f docker network create --driver bridge fiqueok-backend-net # Recriar containers cd /srv/iga-project docker compose down docker compose up -d`

## **7.5. Erro "Convert-VHD: Acesso Negado"**

**Causa:** Disco ainda montado no Hyper-V ou permissões insuficientes.

**Solução:**

powershell

`# Desmontar todos os discos da VM Get-VM -Name $VMName | Get-VMHardDiskDrive | Remove-VMHardDiskDrive # Executar PowerShell como SYSTEM (para casos extremos) # Usar PsExec: https://learn.microsoft.com/sysinternals/downloads/psexec .\PsExec.exe -s -i PowerShell.exe # Tentar conversão novamente Convert-VHD -Path "D:\...\checkpoint.avhdx" -DestinationPath "D:\...\final.vhdx"`

---

## **8. Critérios de Aceitação**

A recuperação é considerada **bem-sucedida** quando:​

✅ **Disponibilidade:** Todas as VMs iniciam sem erros e permanecem estáveis por 24h  
✅ **Conectividade:** Rede validada (IP correto, gateway, DNS, Internet)  
✅ **Serviços:** AD DS, Docker, LDAP operacionais e respondendo  
✅ **Integridade:** Backup dos discos originais preservado e verificado  
✅ **Auditoria:** Logs registrados com timestamp, executor e ações realizadas  
✅ **Performance:** IOPS adequado (disco consolidado em SSD/NVMe se possível)

---

## **9. Registro de Auditoria (Obrigatório)**

Após conclusão, documentar no **Obsidian/OneNote**:[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/366f258b-e506-4d6e-847b-20919b159980/POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md)

text

``## Registro de Recuperação - POP-DR-001 v1.1 - **Data de Execução:** 12/02/2026 - **Executado por:** Paulo Feitosa - **VMs recuperadas:** FOK-SRV-LDAP-01, VAULT-GEN1, IGA-GF-01 - **Tempo total:** XX minutos - **Disco consolidado:** D:\BkpVM_DR_20260212\*_FINAL_RECUPERADA.vhdx - **Tamanho final:** XX GB - **Incidentes encontrados:**   - Erro 0x80070020 resolvido com `Restart-Service vmms`  - IP estático antigo corrigido via Netplan - **RNC gerada:** RNC-2026-002 (se aplicável) - **Status final:** ✅ Sucesso | ❌ Falha Parcial``

---

## **10. Manutenção Preventiva**

## **10.1. Política de Checkpoints**

Para evitar futuros incidentes:​

1. **Limite:** Máximo de 3 checkpoints ativos por VM
    
2. **Nomenclatura:** `<VM>_<Data>_<Motivo>` (ex: `LDAP-01_20260212_PreGMUD`)
    
3. **Retenção:** Remover checkpoints com mais de 30 dias
    
4. **Consolidação:** Mesclar checkpoints após validação de GMUD bem-sucedida
    

powershell

`# Script para limpeza automática (executar semanalmente) Get-VM | ForEach-Object {     $Checkpoints = Get-VMCheckpoint -VMName $_.Name |                   Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-30)}    if ($Checkpoints) {        Write-Host "Removendo checkpoints antigos de $($_.Name)" -ForegroundColor Yellow        $Checkpoints | Remove-VMCheckpoint -Confirm:$false    } }`

## **10.2. Backup Incremental**

powershell

`# Exportar VM completa mensalmente (offline) $VMName = "FOK-SRV-LDAP-01" $ExportPath = "D:\VMExports\$(Get-Date -Format 'yyyyMM')" Export-VM -Name $VMName -Path $ExportPath -Verbose Write-Host "Exportação concluída: $ExportPath" -ForegroundColor Green`

## **10.3. Validação de Backups**

Testar restauração em ambiente isolado trimestralmente:

1. Criar vSwitch temporário isolado
    
2. Importar VM do backup
    
3. Validar boot e serviços
    
4. Documentar tempo de recuperação (RTO)
    

## **10.4. Regra de Ouro - Migração para Produção**

**NOVO - v1.1:** Após 24h de estabilização

Após validar que a VM recuperada está 100% funcional:

powershell

`# 1. Desligar VM Stop-VM -Name "FOK-SRV-LDAP-01" -Force # 2. Copiar disco consolidado para drive principal (C:) $SourceVHD = "D:\BkpVM_DR_20260212\FOK-SRV-LDAP-01_FINAL_RECUPERADA.vhdx" $DestVHD = "C:\ProgramData\Microsoft\Windows\Virtual Hard Disks\FOK-SRV-LDAP-01.vhdx" # Backup do disco antigo (se ainda existir) if (Test-Path $DestVHD) {     Move-Item -Path $DestVHD -Destination "$DestVHD.OLD" -Force } # Copiar disco consolidado Copy-Item -Path $SourceVHD -Destination $DestVHD -Verbose # 3. Reanexar disco na VM Add-VMHardDiskDrive -VMName "FOK-SRV-LDAP-01" -Path $DestVHD # 4. Iniciar VM Start-VM -Name "FOK-SRV-LDAP-01" Write-Host "✓ VM migrada para disco principal com sucesso" -ForegroundColor Green Write-Host "Disco externo (D:) pode ser mantido como backup por mais 30 dias" -ForegroundColor Yellow`

**Justificativa:** Discos em unidades externas (USB) têm IOPS significativamente menor que SSDs internos, impactando performance do laboratório.​

## **10.5. Documentação Contínua**

text

`## Histórico de Mudanças - VM FOK-SRV-LDAP-01 | Data | Ação | Executado por | Motivo | |------|------|---------------|--------| | 12/02/2026 | Recuperação via POP-DR-001 v1.1 | Paulo | Perda de checkpoints | | 15/02/2026 | Migração para drive C: | Paulo | Melhoria de performance |`

---

## **11. Referências**

1. - Histórico de recuperação IGA-GF-01 (Fev/2026) - **Caso real documentado**​
        
2. - POP-LAB-001 Cold Start Diário - Procedimentos de inicialização[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/688e9baf-443d-4ddd-947b-22baff0e2862/POP-LAB-001-Cold-Start-Diario-v1.7.md)
        
3. - Memorial de Transição Arquitetural - Evolução de topologia de rede​
        
4. - ARQ-001 Arquitetura de Referência Fiqueok - Desenho de infraestrutura​
        
5. Microsoft Docs: [Convert-VHD Cmdlet](https://learn.microsoft.com/powershell/module/hyper-v/convert-vhd)
    
6. Microsoft Docs: [Test-VHD Cmdlet](https://learn.microsoft.com/powershell/module/hyper-v/test-vhd)
    
7. Microsoft Docs: [Gerenciar Checkpoints do Hyper-V](https://learn.microsoft.com/windows-server/virtualization/hyper-v/manage/manage-hyper-v-checkpoints)
    
8. Sysinternals: [Handle.exe - Identificar handles de arquivo](https://learn.microsoft.com/sysinternals/downloads/handle)
    
9. Ubuntu Netplan: [Documentação oficial](https://netplan.io/reference/)
    

---

## **Histórico de Revisões**

|Versão|Data|Autor|Descrição|
|---|---|---|---|
|1.0|10/02/2026|Paulo Feitosa|Versão inicial baseada em recuperação IGA-GF-01|
|1.1|12/02/2026|Paulo Feitosa|Adição de seções 5.3.0 (Handle Lock), 10.4 (Regra de Ouro), melhorias em Netplan e Checklist expandido|

---

**Aprovação v1.1:**  
Paulo Feitosa - Lead Auditor ISO 27001  
Data: 12/02/2026 11:11 AM
