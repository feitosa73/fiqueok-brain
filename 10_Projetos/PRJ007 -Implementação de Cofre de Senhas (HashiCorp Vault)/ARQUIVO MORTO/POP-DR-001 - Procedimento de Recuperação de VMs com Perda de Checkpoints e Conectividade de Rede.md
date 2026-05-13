Com base no documento anexo e nos seus arquivos de procedimentos operacionais, criei um **POP completo e detalhado** para recuperação das máquinas OrangeHRM, LDAP e AD que perderam conexões de rede e histórico de checkpoints.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​

# **POP-DR-001 - Procedimento de Recuperação de VMs com Perda de Checkpoints e Conectividade de Rede**

**Status:** Ativo  
**Versão:** 1.0  
**Data:** 10/02/2026  
**Tipo:** POP - Disaster Recovery  
**Owner:** Paulo Feitosa  
**Classificação:** Crítico

---

## **1. Objetivo**

Recuperar máquinas virtuais (OrangeHRM, LDAP, AD) no Hyper-V que perderam suas conexões de rede e histórico em pontos de verificação (checkpoints), consolidando discos diferenciais (.avhdx) em discos únicos (.vhdx) e reconfigurando a conectividade de rede.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​

---

## **2. Escopo**

**Máquinas abrangidas:**

- **FOK-SRV-LDAP-01** - Servidor LDAP
    
- **VAULT-GEN1** - HashiCorp Vault (já recuperada)
    
- **OrangeHRM/midPoint (IGA-GF-01)** - Sistema de RH e governança de identidades (já recuperada)
    
- **AD DS (ID-P-01)** - Active Directory Domain Services
    

**Máquinas excluídas:**

- **IGA-P-01** (já foi recuperada no documento anexo)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​
    

---

## **3. Pré-requisitos**

## **3.1. Hardware e Software**

- Acesso administrativo ao Windows Host (Hyper-V Manager)[POP-LAB-001-Cold-Start-Diario-v1.7.md+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/688e9baf-443d-4ddd-947b-22baff0e2862/POP-LAB-001-Cold-Start-Diario-v1.7.md)
    
- Espaço em disco externo mínimo: 50GB por VM a ser recuperada
    
- PowerShell com privilégios de administrador
    
- Console Hyper-V aberto como fallback para reconexão
    

## **3.2. Conhecimentos Necessários**

- Operação de Hyper-V Manager
    
- Comandos PowerShell: `Get-VHD`, `Convert-VHD`, `Get-VMCheckpoint`
    
- Configuração de Netplan (Ubuntu)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​
    
- Validação de serviços AD DS e Docker[POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/366f258b-e506-4d6e-847b-20919b159980/POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md)
    

## **3.3. Credenciais**

- Usuário Windows com privilégios de administrador
    
- Credenciais de acesso às VMs Ubuntu e Windows Server
    
- Acesso ao vault de senhas Fiqueok (Obsidian ou gerenciador)[POP-LAB-001-Cold-Start-Diario-v1.7.md+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/688e9baf-443d-4ddd-947b-22baff0e2862/POP-LAB-001-Cold-Start-Diario-v1.7.md)
    

---

## **4. Diagnóstico Inicial**

## **4.1. Identificar VMs Afetadas**

No **PowerShell como Administrador**, execute:[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​

powershell

`# Listar VMs e seus checkpoints Get-VM | ForEach-Object {     Write-Host "VM: $($_.Name) - Status: $($_.State)" -ForegroundColor Cyan    Get-VMCheckpoint -VMName $_.Name | Format-Table Name, CreationTime }`

## **4.2. Verificar Discos Diferenciais**

powershell

`# Localizar arquivos .avhdx (checkpoints) Get-ChildItem "C:\ProgramData\Microsoft\Windows\Virtual Hard Disks" -Filter *.avhdx |      Format-Table Name, LastWriteTime, @{Name="Size(GB)";Expression={[math]::Round($_.Length/1GB,2)}}`

## **4.3. Identificar Problemas de Rede**

Sintomas comuns:[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​

- VM liga mas não obtém IP via DHCP
    
- IP estático configurado em subnet inexistente (ex: `192.168.70.10` quando Default Switch usa `172.26.x.x`)
    
- Perda de conectividade após reinício do host
    

---

## **5. Procedimento de Recuperação**

## **IMPORTANTE - Ponto de Bloqueio Crítico**

**NÃO prossiga se:**

- VM estiver em uso ou ligada[POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/366f258b-e506-4d6e-847b-20919b159980/POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md)
    
- Backup não foi realizado[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​
    
- Espaço em disco insuficiente
    

---

## **5.1. Backup de Segurança (Obrigatório)**

## **5.1.1. Criar Pasta de Backup**

powershell

`# No drive externo (exemplo: D:) New-Item -Path "D:\BkpVM_DR_$(Get-Date -Format 'yyyyMMdd_HHmm')" -ItemType Directory cd D:\BkpVM_DR_*`

## **5.1.2. Copiar Discos VHDX e AVHDX**

Para cada VM afetada (exemplo: FOK-SRV-LDAP-01):[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​

powershell

``# Desligar VM Stop-VM -Name "FOK-SRV-LDAP-01" -Force # Copiar todos os arquivos da VM $VMName = "FOK-SRV-LDAP-01" Copy-Item -Path "C:\ProgramData\Microsoft\Windows\Virtual Hard Disks\$VMName*" `           -Destination "D:\BkpVM_DR_$(Get-Date -Format 'yyyyMMdd')" -Verbose``

## **5.1.3. Validar Backup**

powershell

`# Verificar tamanho total copiado $BackupSize = (Get-ChildItem "D:\BkpVM_DR_*" -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB Write-Host "Backup realizado: $([math]::Round($BackupSize,2)) GB" -ForegroundColor Green`

---

## **5.2. Consolidação de Discos Diferenciais**

## **5.2.1. Identificar Checkpoint Mais Recente**

powershell

`# Para VM FOK-SRV-LDAP-01 $LatestCheckpoint = Get-ChildItem "D:\BkpVM_DR_*\FOK-SRV-LDAP-01_*.avhdx" |      Sort-Object LastWriteTime -Descending | Select-Object -First 1 Write-Host "Checkpoint mais recente: $($LatestCheckpoint.Name)" -ForegroundColor Cyan Write-Host "Data: $($LatestCheckpoint.LastWriteTime)" -ForegroundColor Yellow`

## **5.2.2. Inspecionar Cadeia de Discos**

powershell

`# Verificar ParentPath (disco pai) Get-VHD -Path $LatestCheckpoint.FullName | Select-Object Path, ParentPath, FileSize, VhdType`

## **5.2.3. Consolidar em Disco Único**

powershell

``# Converter todos os checkpoints em um disco único $VMName = "FOK-SRV-LDAP-01" $SourceAVHDX = $LatestCheckpoint.FullName $DestinationVHDX = "D:\BkpVM_DR_*\$VMName`_RECUPERADO.vhdx" Convert-VHD -Path $SourceAVHDX -DestinationPath $DestinationVHDX -VHDType Dynamic Write-Host "Conversão concluída: $DestinationVHDX" -ForegroundColor Green``

**Tempo estimado:** 5-15 minutos por VM (dependendo do tamanho)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​

---

## **5.3. Reconfiguração da VM no Hyper-V**

## **5.3.1. Remover Disco Antigo**

1. Abra **Hyper-V Manager**
    
2. Clique com botão direito na VM → **Configurações**
    
3. Vá em **Controladora SCSI** → **Disco Rígido**
    
4. Clique em **Remover** (NÃO delete o arquivo físico)
    

## **5.3.2. Adicionar Disco Recuperado**

1. Clique em **Adicionar** → **Disco Rígido**
    
2. Escolha **Disco Rígido Virtual**
    
3. Navegue até `D:\BkpVM_DR_*\FOK-SRV-LDAP-01_RECUPERADO.vhdx`
    
4. Clique **Aplicar** → **OK**
    

---

## **5.4. Recuperação de Conectividade de Rede**

## **5.4.1. Validar Adaptador de Rede no Hyper-V**

1. Em **Configurações da VM** → **Adaptador de Rede**
    
2. Verificar se está conectado ao **Default Switch**[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​
    
3. Se houver erro de configuração:
    
    - Remover adaptador
        
    - Adicionar novo adaptador
        
    - Conectar ao Default Switch
        

## **5.4.2. Iniciar VM e Acessar Console**

powershell

`Start-VM -Name "FOK-SRV-LDAP-01"`

Aguarde 2-3 minutos e conecte via **Console Hyper-V**.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​

---

## **5.5. Reconfiguração de Rede (Ubuntu)**

## **5.5.1. Verificar IP Atual**

No console da VM Ubuntu:[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​

bash

`ip a`

**Problema comum:** IP estático antigo (ex: `192.168.70.10`) não pertence à subnet do Default Switch (`172.26.x.x`).

## **5.5.2. Reconfigurar Netplan para DHCP**

bash

`# Editar arquivo de configuração sudo nano /etc/netplan/50-cloud-init.yaml`

**Substituir conteúdo por**:[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​

text

`network:     version: 2    ethernets:        eth0:            dhcp4: true`

**Aplicar configuração**:

bash

`sudo netplan apply`

## **5.5.3. Validar Novo IP**

bash

`ip a | grep inet ping -c 4 8.8.8.8`

**Resultado esperado:** IP na faixa `172.26.x.x` e conectividade com Internet.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​

---

## **5.6. Reinstalar Tailscale (Opcional)**

Se a VM usa Tailscale para acesso remoto:[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​

bash

`# Remover instalação antiga sudo tailscale down sudo apt-get remove --purge tailscale -y sudo rm -rf /var/lib/tailscale/ # Reinstalar curl -fsSL https://tailscale.com/install.sh | sh # Autenticar sudo tailscale up --hostname=fok-srv-ldap-01 --force-reauth`

Copie o link de autenticação e cole no navegador Windows.

---

## **5.7. Reconfiguração de Rede (Windows Server - AD DS)**

## **5.7.1. Verificar IP do Servidor**

No console Windows Server:[POP-LAB-001-Cold-Start-Diario-v1.7.md+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/688e9baf-443d-4ddd-947b-22baff0e2862/POP-LAB-001-Cold-Start-Diario-v1.7.md)

powershell

`Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like "172.16.*"}`

**IP esperado:** `xxx.xxx.xxx.xxx` (conforme arquitetura).[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/d41448dc-0735-4293-b3c3-7b735e9566b8/ARQ-001-PRJ002-Arquitetura-de-Referencia-Infraestrutura-Fiqueok.md)]​

## **5.7.2. Reconfigurar IP Estático (se necessário)**

powershell

``# Obter interface $Interface = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} # Configurar IP estático New-NetIPAddress -InterfaceIndex $Interface.ifIndex -IPAddress xxx.xxx.xxx.xxx `                  -PrefixLength 24 -DefaultGateway xxx.xxx.xxx.xxx # Configurar DNS (apontar para si mesmo) Set-DnsClientServerAddress -InterfaceIndex $Interface.ifIndex -ServerAddresses 127.0.0.1``

## **5.7.3. Validar Serviços AD DS**

Execute o script de validação:[POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/366f258b-e506-4d6e-847b-20919b159980/POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md)

powershell

`# Testar porta LDAP Test-NetConnection -ComputerName xxx.xxx.xxx.xxx -Port 389 # Validar serviços Get-Service NTDS, DNS | Format-Table Name, Status`

**Resultado esperado:** Ambos os serviços devem estar **Running**.[POP-LAB-001-Cold-Start-Diario-v1.7.md+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/688e9baf-443d-4ddd-947b-22baff0e2862/POP-LAB-001-Cold-Start-Diario-v1.7.md)

---

## **6. Validação Pós-Recuperação**

## **6.1. Checklist de Conectividade**

Para cada VM recuperada:[POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/366f258b-e506-4d6e-847b-20919b159980/POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md)

|**Item**|**Comando**|**Resultado Esperado**|
|---|---|---|
|VM iniciada|`Get-VM -Name <VM>`|State = Running|
|IP atribuído|`ip a` (Linux) ou `ipconfig` (Windows)|IP na subnet correta|
|Ping para gateway|`ping 172.26.32.1` ou `ping xxx.xxx.xxx.xxx`|Resposta com sucesso|
|Ping para Internet|`ping 8.8.8.8`|Resposta com sucesso|
|DNS funcional|`nslookup google.com`|Resolução com sucesso|
|Serviços críticos|`docker ps` (Ubuntu) ou `Get-Service` (Windows)|Containers/serviços ativos|

## **6.2. Teste de Integração**

## **6.2.1. Validar AD DS**

No host Windows:[POP-LAB-001-Cold-Start-Diario-v1.7.md+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/688e9baf-443d-4ddd-947b-22baff0e2862/POP-LAB-001-Cold-Start-Diario-v1.7.md)

powershell

`# Resolver domínio Resolve-DnsName -Name corp.fiqueok.com.br -Server xxx.xxx.xxx.xxx # Testar autenticação Test-ComputerSecureChannel -Server ID-P-01 -Verbose`

## **6.2.2. Validar Docker Services (IGA-GF-01)**

No console Ubuntu:[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​

bash

`cd /srv/iga-project sudo docker compose ps # Verificar logs docker logs iga-midpoint --tail 50 docker logs iga-postgres --tail 50`

## **6.2.3. Testar Acesso Web**

No navegador Windows:[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​

- **midPoint:** `http://<IP_IGA-GF-01>:8080/midpoint`
    
- **OrangeHRM:** `http://<IP_IGA-GF-01>:8081`
    

---

## **7. Troubleshooting**

## **7.1. Erro "Arquivo já está sendo usado" (0x80070020)**

**Causa:** Windows Explorer ou serviço VMMS está bloqueando o arquivo.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​

**Solução:**

powershell

`# Reiniciar serviço do Hyper-V Restart-Service vmms # Desanexar VHD pelo Gerenciamento de Disco # 1. Win + X → Gerenciamento de Disco # 2. Localizar disco com ícone azul # 3. Botão direito → Desanexar VHD`

## **7.2. VM não obtém IP via DHCP**

**Causa:** Netplan configurado com IP estático.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​

**Solução:** Seguir seção **5.5.2** deste POP.

## **7.3. AD DS não responde na porta LDAP (389)**

**Causa:** Serviço NTDS não iniciou.[POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/366f258b-e506-4d6e-847b-20919b159980/POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md)

**Solução:**

powershell

`# No console do servidor AD Start-Service NTDS Get-Service NTDS | Select-Object Status`

Verificar Event Viewer → Windows Logs → Directory Service para erros.

## **7.4. Containers Docker não iniciam**

**Causa:** Banco de dados não está rodando.[POP-LAB-001-Cold-Start-Diario-v1.7.md+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/688e9baf-443d-4ddd-947b-22baff0e2862/POP-LAB-001-Cold-Start-Diario-v1.7.md)

**Solução:**

bash

`# Verificar containers de banco docker ps -a | grep -E "postgres|mariadb" # Iniciar manualmente docker start iga-postgres docker start orangehrm-db # Aguardar 10 segundos sleep 10 # Subir aplicações cd /srv/iga-project sudo docker compose up -d`

---

## **8. Critérios de Aceitação**

A recuperação é considerada **bem-sucedida** quando:[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/b1d1c2de-ca74-45b8-b618-0a9c2b731f9d/Memorial-Descritivo-de-Arquitetura-Evolucao-da-Topologia-de-Rede.md)]​

✅ Todas as VMs iniciam sem erros  
✅ Conectividade de rede validada (ping, DNS, acesso web)  
✅ Serviços críticos operacionais (AD DS, Docker, LDAP)  
✅ Backup dos discos originais preservado  
✅ Logs de auditoria registrados (quem executou, quando)

---

## **9. Registro de Auditoria (Obrigatório)**

Após conclusão, documentar no **Obsidian/OneNote**:[POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/366f258b-e506-4d6e-847b-20919b159980/POP-001-Procedimento-de-Inicializacao-do-LAB-Cold-Start-Diario.md)

text

`## Registro de Recuperação - POP-DR-001 - **Data:** 10/02/2026 - **Executado por:** Paulo Feitosa - **VMs recuperadas:** FOK-SRV-LDAP-01, IGA-GF-01 - **Tempo total:** XX minutos - **Incidentes:** (descrever problemas encontrados) - **RNC gerada:** (se aplicável)`

---

## **10. Manutenção Preventiva**

Para evitar futuros incidentes:[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/b1d1c2de-ca74-45b8-b618-0a9c2b731f9d/Memorial-Descritivo-de-Arquitetura-Evolucao-da-Topologia-de-Rede.md)]​

1. **Não criar mais de 3 checkpoints por VM** (política de retenção)
    
2. **Exportar VMs mensalmente** como backup incremental
    
3. **Validar backups** (testar restauração em ambiente isolado)
    
4. **Documentar mudanças de rede** em ADRs (Architecture Decision Records)
    
5. **Usar IaC** (Infrastructure as Code) para configurações de rede (Netplan via Ansible)
    

---

## **11. Referências**

- - Histórico de recuperação IGA-GF-01[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/074b5524-65be-4f6a-b296-731a87ee7c95/paste.txt)]​
        
- - POP-LAB-001 Cold Start Diário[POP-LAB-001-Cold-Start-Diario-v1.7.md+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/688e9baf-443d-4ddd-947b-22baff0e2862/POP-LAB-001-Cold-Start-Diario-v1.7.md)
        
- - Memorial de Transição Arquitetural[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/b1d1c2de-ca74-45b8-b618-0a9c2b731f9d/Memorial-Descritivo-de-Arquitetura-Evolucao-da-Topologia-de-Rede.md)]​
        
- - Arquitetura de Referência Fiqueok[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/d41448dc-0735-4293-b3c3-7b735e9566b8/ARQ-001-PRJ002-Arquitetura-de-Referencia-Infraestrutura-Fiqueok.md)]​
        
- Microsoft Docs: [Convert-VHD Cmdlet](https://learn.microsoft.com/powershell/module/hyper-v/convert-vhd)
    

---

**Aprovação:**  
Paulo Feitosa - Lead Auditor ISO 27001  
Data: 10/02/2026
