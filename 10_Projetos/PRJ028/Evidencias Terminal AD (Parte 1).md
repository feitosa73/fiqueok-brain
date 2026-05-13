PS C:\Windows\system32> # No AD
PS C:\Windows\system32> ipconfig | findstr "Default Gateway"
   Default Gateway . . . . . . . . . : 172.24.192.1
PS C:\Windows\system32> # No AD
PS C:\Windows\system32> ping 172.24.192.1

Pinging 172.24.192.1 with 32 bytes of data:
Reply from 172.24.192.10: Destination host unreachable.
Reply from 172.24.192.10: Destination host unreachable.
Reply from 172.24.192.10: Destination host unreachable.
Reply from 172.24.192.10: Destination host unreachable.

Ping statistics for 172.24.192.1:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
PS C:\Windows\system32> # No AD
PS C:\Windows\system32> ping 8.8.8.8

Pinging 8.8.8.8 with 32 bytes of data:
Reply from 172.24.192.10: Destination host unreachable.
Reply from 172.24.192.10: Destination host unreachable.
Reply from 172.24.192.10: Destination host unreachable.
Reply from 172.24.192.10: Destination host unreachable.

Ping statistics for 8.8.8.8:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
PS C:\Windows\system32> ping 1.1.1.1# No AD
Ping request could not find host 1.1.1.1#. Please check the name and try again.
PS C:\Windows\system32> ipconfig /all | findstr "DNS"
   DNS Suffix Search List. . . . . . : corp.fiqueok.com.br
   Connection-specific DNS Suffix  . :
   DNS Servers . . . . . . . . . . . : ::1
PS C:\Windows\system32> # No AD
PS C:\Windows\system32> nslookup google.com
DNS request timed out.
    timeout was 2 seconds.
Server:  UnKnown
Address:  ::1

DNS request timed out.
    timeout was 2 seconds.
DNS request timed out.
    timeout was 2 seconds.
DNS request timed out.
    timeout was 2 seconds.
DNS request timed out.
    timeout was 2 seconds.
*** Request to UnKnown timed-out
PS C:\Windows\system32> nslookup google.com 8.8.8.8^C
PS C:\Windows\system32> # No AD
PS C:\Windows\system32> route print -4
===========================================================================
Interface List
  6...00 15 5d 44 69 02 ......Microsoft Hyper-V Network Adapter
  1...........................Software Loopback Interface 1
===========================================================================

IPv4 Route Table
===========================================================================
Active Routes:
Network Destination        Netmask          Gateway       Interface  Metric
          0.0.0.0          0.0.0.0     172.24.192.1    172.24.192.10     16
        127.0.0.0        255.0.0.0         On-link         127.0.0.1    331
        127.0.0.1  255.255.255.255         On-link         127.0.0.1    331
  127.255.255.255  255.255.255.255         On-link         127.0.0.1    331
     172.24.192.0    255.255.240.0         On-link     172.24.192.10    271
    172.24.192.10  255.255.255.255         On-link     172.24.192.10    271
   172.24.207.255  255.255.255.255         On-link     172.24.192.10    271
        224.0.0.0        240.0.0.0         On-link         127.0.0.1    331
        224.0.0.0        240.0.0.0         On-link     172.24.192.10    271
  255.255.255.255  255.255.255.255         On-link         127.0.0.1    331
  255.255.255.255  255.255.255.255         On-link     172.24.192.10    271
===========================================================================
Persistent Routes:
  Network Address          Netmask  Gateway Address  Metric
          0.0.0.0          0.0.0.0     172.24.192.1       1
===========================================================================
PS C:\Windows\system32>
PS C:\Windows\system32> # No AD
PS C:\Windows\system32> Get-NetFirewallRule -Direction Outbound -Action Block | Select-Object DisplayName, Enabled
Get-NetFirewallRule : No matching MSFT_NetFirewallRule objects found by CIM query for instances of the
root/standardcimv2/MSFT_NetFirewallRule class on the  CIM server: SELECT * FROM MSFT_NetFirewallRule  WHERE ((Direction = 2)) AND ((Action
= 4)). Verify query parameters and retry.
At line:1 char:1
+ Get-NetFirewallRule -Direction Outbound -Action Block | Select-Object ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (MSFT_NetFirewallRule:String) [Get-NetFirewallRule], CimJobException
    + FullyQualifiedErrorId : CmdletizationQuery_NotFound,Get-NetFirewallRule

PS C:\Windows\system32>
PS C:\Windows\system32> # No console do AD (PowerShell como Administrador)
PS C:\Windows\system32> ipconfig | findstr "Gateway"
   Default Gateway . . . . . . . . . : 172.24.192.1
PS C:\Windows\system32>
PS C:\Windows\system32> ping 172.24.192.1

Pinging 172.24.192.1 with 32 bytes of data:
Reply from 172.24.192.10: Destination host unreachable.
Reply from 172.24.192.10: Destination host unreachable.
Reply from 172.24.192.10: Destination host unreachable.
Reply from 172.24.192.10: Destination host unreachable.

Ping statistics for 172.24.192.1:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
PS C:\Windows\system32> nslookup google.com
DNS request timed out.
    timeout was 2 seconds.
Server:  UnKnown
Address:  ::1

DNS request timed out.
    timeout was 2 seconds.
DNS request timed out.
    timeout was 2 seconds.
DNS request timed out.
    timeout was 2 seconds.
DNS request timed out.
    timeout was 2 seconds.
*** Request to UnKnown timed-out
PS C:\Windows\system32> route print -4 | findstr "0.0.0.0"^C
PS C:\Windows\system32>
PS C:\Windows\system32> # Testar conexão TLS com login.microsoftonline.com
PS C:\Windows\system32> Test-NetConnection login.microsoftonline.com -Port 443
PS C:\Windows\system32> # Testar conexão com Graph API
PS C:\Windows\system32> Test-NetConnection graph.microsoft.com -Port 443
WARNING: Name resolution of graph.microsoft.com failed


ComputerName   : graph.microsoft.com
RemoteAddress  :
InterfaceAlias :
SourceAddress  :
PingSucceeded  : False



PS C:\Windows\system32> # Verificar se há regras bloqueando saída
PS C:\Windows\system32> Get-NetFirewallRule -Direction Outbound -Action Block | Select-Object DisplayName, Enabled
Get-NetFirewallRule : No matching MSFT_NetFirewallRule objects found by CIM query for instances of the
root/standardcimv2/MSFT_NetFirewallRule class on the  CIM server: SELECT * FROM MSFT_NetFirewallRule  WHERE ((Direction = 2)) AND ((Action
= 4)). Verify query parameters and retry.
At line:1 char:1
+ Get-NetFirewallRule -Direction Outbound -Action Block | Select-Object ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (MSFT_NetFirewallRule:String) [Get-NetFirewallRule], CimJobException
    + FullyQualifiedErrorId : CmdletizationQuery_NotFound,Get-NetFirewallRule

PS C:\Windows\system32> # No console do AD
PS C:\Windows\system32> nslookup iga-gf-02
DNS request timed out.
    timeout was 2 seconds.
Server:  UnKnown
Address:  ::1

DNS request timed out.
    timeout was 2 seconds.
DNS request timed out.
    timeout was 2 seconds.
*** Request to UnKnown timed-out
PS C:\Windows\system32> Get-NetIPInterface -AddressFamily IPv4

ifIndex InterfaceAlias                  AddressFamily NlMtu(Bytes) InterfaceMetric Dhcp     ConnectionState PolicyStore
------- --------------                  ------------- ------------ --------------- ----     --------------- -----------
6       Ethernet                        IPv4                  1500              15 Disabled Connected       ActiveStore
1       Loopback Pseudo-Interface 1     IPv4            4294967295              75 Disabled Connected       ActiveStore


PS C:\Windows\system32>
PS C:\Windows\system32>
PS C:\Windows\system32>
PS C:\Windows\system32>
PS C:\Windows\system32>
PS C:\Windows\system32> New-NetFirewallRule -DisplayName "PRJ028_ALLOW_NTP" `
>>     -Direction Outbound -Protocol UDP -RemotePort 123 -Action Allow


Name                          : {10922d63-3f72-4884-b476-e47840afc042}
DisplayName                   : PRJ028_ALLOW_NTP
Description                   :
DisplayGroup                  :
Group                         :
Enabled                       : True
Profile                       : Any
Platform                      : {}
Direction                     : Outbound
Action                        : Allow
EdgeTraversalPolicy           : Block
LooseSourceMapping            : False
LocalOnlyMapping              : False
Owner                         :
PrimaryStatus                 : OK
Status                        : The rule was parsed successfully from the store. (65536)
EnforcementStatus             : NotApplicable
PolicyStoreSource             : PersistentStore
PolicyStoreSourceType         : Local
RemoteDynamicKeywordAddresses : {}



PS C:\Windows\system32>
PS C:\Windows\system32> # Liberar DNS para o próprio AD
PS C:\Windows\system32> New-NetFirewallRule -DisplayName "PRJ028_ALLOW_DNS" `
>>     -Direction Outbound -Protocol UDP -RemotePort 53 -Action Allow


Name                          : {3aefbfc6-6410-48bb-b44f-5105c5290a43}
DisplayName                   : PRJ028_ALLOW_DNS
Description                   :
DisplayGroup                  :
Group                         :
Enabled                       : True
Profile                       : Any
Platform                      : {}
Direction                     : Outbound
Action                        : Allow
EdgeTraversalPolicy           : Block
LooseSourceMapping            : False
LocalOnlyMapping              : False
Owner                         :
PrimaryStatus                 : OK
Status                        : The rule was parsed successfully from the store. (65536)
EnforcementStatus             : NotApplicable
PolicyStoreSource             : PersistentStore
PolicyStoreSourceType         : Local
RemoteDynamicKeywordAddresses : {}



PS C:\Windows\system32>
PS C:\Windows\system32> # Liberar LDAP (para comunicação com midPoint - via Tailscale)
PS C:\Windows\system32> New-NetFirewallRule -DisplayName "PRJ028_ALLOW_LDAP" `
>>     -Direction Outbound -Protocol TCP -RemotePort 389 -Action Allow


Name                          : {366af746-c55c-490c-961b-0cad9c32d618}
DisplayName                   : PRJ028_ALLOW_LDAP
Description                   :
DisplayGroup                  :
Group                         :
Enabled                       : True
Profile                       : Any
Platform                      : {}
Direction                     : Outbound
Action                        : Allow
EdgeTraversalPolicy           : Block
LooseSourceMapping            : False
LocalOnlyMapping              : False
Owner                         :
PrimaryStatus                 : OK
Status                        : The rule was parsed successfully from the store. (65536)
EnforcementStatus             : NotApplicable
PolicyStoreSource             : PersistentStore
PolicyStoreSourceType         : Local
RemoteDynamicKeywordAddresses : {}



PS C:\Windows\system32>
PS C:\Windows\system32> # Liberar Tailscale (será instalado depois)
PS C:\Windows\system32> New-NetFirewallRule -DisplayName "PRJ028_ALLOW_TAILSCALE" `
>>     -Direction Outbound -Program "C:\Program Files\Tailscale\tailscale.exe" -Action Allow


Name                          : {b52876ae-cd69-4794-9588-fe438074186d}
DisplayName                   : PRJ028_ALLOW_TAILSCALE
Description                   :
DisplayGroup                  :
Group                         :
Enabled                       : True
Profile                       : Any
Platform                      : {}
Direction                     : Outbound
Action                        : Allow
EdgeTraversalPolicy           : Block
LooseSourceMapping            : False
LocalOnlyMapping              : False
Owner                         :
PrimaryStatus                 : OK
Status                        : The rule was parsed successfully from the store. (65536)
EnforcementStatus             : NotApplicable
PolicyStoreSource             : PersistentStore
PolicyStoreSourceType         : Local
RemoteDynamicKeywordAddresses : {}



PS C:\Windows\system32>
PS C:\Windows\system32> # Verificar regras criadas
PS C:\Windows\system32> Get-NetFirewallRule -DisplayName "PRJ028_*" | Select-Object DisplayName, Direction, Action

DisplayName            Direction Action
-----------            --------- ------
PRJ028_ALLOW_NTP        Outbound  Allow
PRJ028_ALLOW_DNS        Outbound  Allow
PRJ028_ALLOW_LDAP       Outbound  Allow
PRJ028_ALLOW_TAILSCALE  Outbound  Allow


PS C:\Windows\system32>
PS C:\Windows\system32>
PS C:\Windows\system32>
PS C:\Windows\system32>
PS C:\Windows\system32>
PS C:\Windows\system32>
PS C:\Windows\system32> # Desabilitar SMB (porta 445)
PS C:\Windows\system32> Set-SmbServerConfiguration -EnableSMB1Protocol $false -EnableSMB2Protocol $false -Force
PS C:\Windows\system32>
PS C:\Windows\system32> # Desabilitar NetBIOS sobre TCP/IP
PS C:\Windows\system32> Disable-NetAdapterBinding -Name "Ethernet" -ComponentID "ms_server"
PS C:\Windows\system32>
PS C:\Windows\system32> # Restringir acesso anônimo ao LDAP
PS C:\Windows\system32> Set-ADObject -Identity "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=corp,DC=fiqueok,DC=com,DC=br" `
>>     -Replace @{'dsHeuristics'='0000002'}
PS C:\Windows\system32>
PS C:\Windows\system32> # Desabilitar WinRM (substituído por Tailscale)
PS C:\Windows\system32> Stop-Service WinRM -Force
PS C:\Windows\system32> Set-Service WinRM -StartupType Disabled
PS C:\Windows\system32>
PS C:\Windows\system32> # Verificar serviços
PS C:\Windows\system32> Get-Service WinRM | Select-Object Name, Status, StartType

Name   Status StartType
----   ------ ---------
WinRM Stopped  Disabled


PS C:\Windows\system32> # Configurar fonte de horário confiável (pool.ntp.org)
PS C:\Windows\system32> w32tm /config /manualpeerlist:"pool.ntp.org,0x8" /syncfromflags:MANUAL
The command completed successfully.
PS C:\Windows\system32> w32tm /config /update
The command completed successfully.
PS C:\Windows\system32>
PS C:\Windows\system32> # Forçar sincronização imediata
PS C:\Windows\system32> w32tm /resync
Sending resync command to local computer
The command completed successfully.
PS C:\Windows\system32>
PS C:\Windows\system32> # Verificar configuração
PS C:\Windows\system32> w32tm /query /source
VM IC Time Synchronization Provider
PS C:\Windows\system32>
PS C:\Windows\system32> # Verificar status
PS C:\Windows\system32> w32tm /query /status
Leap Indicator: 3(not synchronized)
Stratum: 1 (primary reference - syncd by radio clock)
Precision: -23 (119.209ns per tick)
Root Delay: 0.0002565s
Root Dispersion: 0.0100002s
ReferenceId: 0x564D5450 (source name:  "VMTP")
Last Successful Sync Time: 5/10/2026 3:35:20 PM
Source: VM IC Time Synchronization Provider
Poll Interval: 6 (64s)

PS C:\Windows\system32>
PS C:\Windows\system32> # Coletar configurações atuais para auditoria
PS C:\Windows\system32> ipconfig /all > C:\temp\prj028_ipconfig_before.txt                                                                  PS C:\Windows\system32> Get-NetRoute -DestinationPrefix "0.0.0.0/0" > C:\temp\prj028_route_before.txt                                       PS C:\Windows\system32> Get-DnsClientServerAddress > C:\temp\prj028_dns_before.txt                                                          PS C:\Windows\system32>                                                                                                                     PS C:\Windows\system32>                                                                                                                     PS C:\Windows\system32> # Desabilitar Time Sync do Hyper-V                                                                                  PS C:\Windows\system32> Reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\VMICTimeProvider" /v Enabled /t REG_DWORD /d 0 /f
The operation completed successfully.
PS C:\Windows\system32>
PS C:\Windows\system32> # Reconfigurar NTP
PS C:\Windows\system32> w32tm /config /manualpeerlist:"pool.ntp.org,0x8" /syncfromflags:MANUAL
The command completed successfully.
PS C:\Windows\system32> w32tm /config /update
The command completed successfully.
PS C:\Windows\system32> w32tm /resync
Sending resync command to local computer
The computer did not resync because no time data was available.
PS C:\Windows\system32>
PS C:\Windows\system32> # Verificar
PS C:\Windows\system32> w32tm /query /source
VM IC Time Synchronization Provider
PS C:\Windows\system32>
PS C:\Windows\system32>
PS C:\Windows\system32>
PS C:\Windows\system32> # Identificar o índice da interface (deve ser 6, como vimos)
PS C:\Windows\system32> $interfaceIndex = 6
PS C:\Windows\system32>
PS C:\Windows\system32> # Remover a rota padrão incorreta
PS C:\Windows\system32> Remove-NetRoute -DestinationPrefix "0.0.0.0/0" -InterfaceIndex $interfaceIndex -Confirm:$false
PS C:\Windows\system32>
PS C:\Windows\system32> # Verificar que foi removida
PS C:\Windows\system32> Get-NetRoute -DestinationPrefix "0.0.0.0/0"
Get-NetRoute : No MSFT_NetRoute objects found with property 'DestinationPrefix' equal to '0.0.0.0/0'.  Verify the value of the property
and retry.
At line:1 char:1
+ Get-NetRoute -DestinationPrefix "0.0.0.0/0"
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (0.0.0.0/0:String) [Get-NetRoute], CimJobException
    + FullyQualifiedErrorId : CmdletizationQuery_NotFound_DestinationPrefix,Get-NetRoute

PS C:\Windows\system32> # Deve retornar vazio ou "No matching MSFT_NetRoute objects found"
PS C:\Windows\system32>
PS C:\Windows\system32>
PS C:\Windows\system32> # Configurar DNS para apontar para o próprio AD
PS C:\Windows\system32> Set-DnsClientServerAddress -InterfaceIndex 6 -ServerAddresses ("127.0.0.1")
PS C:\Windows\system32>
PS C:\Windows\system32> # Verificar
PS C:\Windows\system32> Get-DnsClientServerAddress -InterfaceIndex 6

InterfaceAlias               Interface Address ServerAddresses
                             Index     Family
--------------               --------- ------- ---------------
Ethernet                             6 IPv4    {127.0.0.1}
Ethernet                             6 IPv6    {::1}


PS C:\Windows\system32>
PS C:\Windows\system32>
PS C:\Windows\system32> # Verificar rotas persistentes
PS C:\Windows\system32> Get-NetRoute -DestinationPrefix "0.0.0.0/0" -PolicyStore PersistentStore
Get-NetRoute : No MSFT_NetRoute objects found with property 'DestinationPrefix' equal to '0.0.0.0/0'.  Verify the value of the property
and retry.
At line:1 char:1
+ Get-NetRoute -DestinationPrefix "0.0.0.0/0" -PolicyStore PersistentSt ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (0.0.0.0/0:String) [Get-NetRoute], CimJobException
    + FullyQualifiedErrorId : CmdletizationQuery_NotFound_DestinationPrefix,Get-NetRoute

PS C:\Windows\system32>
PS C:\Windows\system32> # Se existir (retornar algo), remover. Se não existir, ignorar.
PS C:\Windows\system32> Remove-NetRoute -DestinationPrefix "0.0.0.0/0" -PolicyStore PersistentStore -Confirm:$false
Remove-NetRoute : No MSFT_NetRoute objects found with property 'DestinationPrefix' equal to '0.0.0.0/0'.  Verify the value of the property
and retry.
At line:1 char:1
+ Remove-NetRoute -DestinationPrefix "0.0.0.0/0" -PolicyStore Persisten ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (0.0.0.0/0:String) [Remove-NetRoute], CimJobException
    + FullyQualifiedErrorId : CmdletizationQuery_NotFound_DestinationPrefix,Remove-NetRoute

PS C:\Windows\system32>
PS C:\Windows\system32>
PS C:\Windows\system32>
PS C:\Windows\system32>
PS C:\Windows\system32> # Exibir configuração de rede atual
PS C:\Windows\system32> ipconfig /all

Windows IP Configuration

   Host Name . . . . . . . . . . . . : ID-P-01
   Primary Dns Suffix  . . . . . . . : corp.fiqueok.com.br
   Node Type . . . . . . . . . . . . : Hybrid
   IP Routing Enabled. . . . . . . . : No
   WINS Proxy Enabled. . . . . . . . : No
   DNS Suffix Search List. . . . . . : corp.fiqueok.com.br

Ethernet adapter Ethernet:

   Connection-specific DNS Suffix  . :
   Description . . . . . . . . . . . : Microsoft Hyper-V Network Adapter
   Physical Address. . . . . . . . . : 00-15-5D-44-69-02
   DHCP Enabled. . . . . . . . . . . : No
   Autoconfiguration Enabled . . . . : Yes
   Link-local IPv6 Address . . . . . : fe80::c503:7c60:75f4:438%6(Preferred)
   IPv4 Address. . . . . . . . . . . : 172.24.192.10(Preferred)
   Subnet Mask . . . . . . . . . . . : 255.255.240.0
   Default Gateway . . . . . . . . . :
   DHCPv6 IAID . . . . . . . . . . . : 100668765
   DHCPv6 Client DUID. . . . . . . . : 00-01-00-01-30-DB-C2-AF-00-15-5D-44-69-02
   DNS Servers . . . . . . . . . . . : ::1
                                       127.0.0.1
   NetBIOS over Tcpip. . . . . . . . : Enabled
PS C:\Windows\system32>
PS C:\Windows\system32> # Verificar tabela de rotas (deve mostrar apenas a rota local da sub-rede, sem 0.0.0.0)
PS C:\Windows\system32> route print -4
===========================================================================
Interface List
  6...00 15 5d 44 69 02 ......Microsoft Hyper-V Network Adapter
  1...........................Software Loopback Interface 1
===========================================================================

IPv4 Route Table
===========================================================================
Active Routes:
Network Destination        Netmask          Gateway       Interface  Metric
        127.0.0.0        255.0.0.0         On-link         127.0.0.1    331
        127.0.0.1  255.255.255.255         On-link         127.0.0.1    331
  127.255.255.255  255.255.255.255         On-link         127.0.0.1    331
     172.24.192.0    255.255.240.0         On-link     172.24.192.10    271
    172.24.192.10  255.255.255.255         On-link     172.24.192.10    271
   172.24.207.255  255.255.255.255         On-link     172.24.192.10    271
        224.0.0.0        240.0.0.0         On-link         127.0.0.1    331
        224.0.0.0        240.0.0.0         On-link     172.24.192.10    271
  255.255.255.255  255.255.255.255         On-link         127.0.0.1    331
  255.255.255.255  255.255.255.255         On-link     172.24.192.10    271
===========================================================================
Persistent Routes:
  None
PS C:\Windows\system32>
PS C:\Windows\system32> # Testar ping para o gateway correto do Default Switch
PS C:\Windows\system32> ping 172.23.192.1

Pinging 172.23.192.1 with 32 bytes of data:
PING: transmit failed. General failure.
PING: transmit failed. General failure.
PING: transmit failed. General failure.
PING: transmit failed. General failure.

Ping statistics for 172.23.192.1:
    Packets: Sent = 4, Received = 0, Lost = 4 (100% loss),
PS C:\Windows\system32>
PS C:\Windows\system32> # Testar ping para o midPoint
PS C:\Windows\system32> ping 172.23.201.182

Pinging 172.23.201.182 with 32 bytes of data:
PING: transmit failed. General failure.
PING: transmit failed. General failure.
PING: transmit failed. General failure.
PING: transmit failed. General failure.

Ping statistics for 172.23.201.182:
    Packets: Sent = 4, Received = 0, Lost = 4 (100% loss),
PS C:\Windows\system32>
PS C:\Windows\system32> # Testar se o AD ainda consegue resolver nomes (deve falhar, pois DNS aponta para 127.0.0.1)
PS C:\Windows\system32> nslookup google.com
DNS request timed out.
    timeout was 2 seconds.
Server:  UnKnown
Address:  ::1

DNS request timed out.
    timeout was 2 seconds.
DNS request timed out.
    timeout was 2 seconds.
DNS request timed out.
    timeout was 2 seconds.
DNS request timed out.
    timeout was 2 seconds.
*** Request to UnKnown timed-out
PS C:\Windows\system32>
PS C:\Windows\system32>
PS C:\Windows\system32> cd \temp
PS C:\temp> dir


    Directory: C:\temp


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        12/26/2025   2:54 PM            766 ad_ca.cer
-a----         3/31/2026   7:53 AM           8789 orangehrm_full_import.csv
-a----         5/10/2026   3:35 PM           1988 prj028_dns_before.txt
-a----         5/10/2026   3:35 PM           2396 prj028_ipconfig_before.txt
-a----         5/10/2026   3:35 PM            794 prj028_route_before.txt
-a----         5/10/2026   3:43 PM        1394944 tailscale-setup-1.96.3.exe
-a----          4/1/2026   3:24 PM           5665 Untitled1.ps1


PS C:\temp> # No console do AD (PowerShell como Administrador)
PS C:\temp> cd C:\temp
PS C:\temp>
PS C:\temp> # Instalar Tailscale (modo silencioso)
PS C:\temp> Start-Process -Wait -FilePath "C:\temp\tailscale-setup-1.96.3.exe" -ArgumentList "/S"
PS C:\temp>
PS C:\temp> # Aguardar a instalação (alguns segundos)
PS C:\temp>
PS C:\temp> # Verificar instalação
PS C:\temp> Test-Path "C:\Program Files\Tailscale\tailscale.exe"
False
PS C:\temp>
PS C:\temp> # Verificar se o serviço foi criado
PS C:\temp> Get-Service Tailscale
Get-Service : Cannot find any service with service name 'Tailscale'.
At line:1 char:1
+ Get-Service Tailscale
+ ~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (Tailscale:String) [Get-Service], ServiceCommandException
    + FullyQualifiedErrorId : NoServiceFoundForGivenName,Microsoft.PowerShell.Commands.GetServiceCommand

PS C:\temp> # Verificar se o arquivo ainda está lá
PS C:\temp> dir C:\temp\tailscale*.exe


    Directory: C:\temp


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----         5/10/2026   3:43 PM        1394944 tailscale-setup-1.96.3.exe


PS C:\temp>
PS C:\temp> # Tentar executar o instalador em modo interativo (sem /S) para ver o erro
PS C:\temp> Start-Process -FilePath "C:\temp\tailscale-setup-1.96.3.exe"
PS C:\temp>
PS C:\temp> # Verificar se o arquivo está bloqueado (muitos arquivos baixados vêm bloqueados)
PS C:\temp> Get-Item "C:\temp\tailscale-setup-1.96.3.exe" | Select-Object * -ExpandProperty Attributes