Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

Install the latest PowerShell for new features and improvements! https://aka.ms/PSWindows

PS C:\Users\paulo.feitosa> # 1. Monitorar logs de segurança (logins, autenticações)
PS C:\Users\paulo.feitosa> Get-WinEvent -FilterHashtable @{LogName='Security'; StartTime=(Get-Date).AddMinutes(-10)} |
>>     Where-Object {$_.Id -in 4624,4625,4648,4776} |
>>     Select-Object TimeCreated, Id, Message -First 20
Get-WinEvent : No events were found that match the specified selection criteria.
At line:1 char:1
+ Get-WinEvent -FilterHashtable @{LogName='Security'; StartTime=(Get-Da ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (:) [Get-WinEvent], Exception
    + FullyQualifiedErrorId : NoMatchingEventsFound,Microsoft.PowerShell.Commands.GetWinEventCommand

PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa> # 2. Monitorar tentativas de conexão na porta 389 (LDAP)
PS C:\Users\paulo.feitosa> netstat -an | findstr ":389"
  TCP    0.0.0.0:389            0.0.0.0:0              LISTENING
  TCP    [::]:389               [::]:0                 LISTENING
  TCP    [::1]:389              [::1]:49674            ESTABLISHED
  TCP    [::1]:389              [::1]:49675            ESTABLISHED
  TCP    [::1]:389              [::1]:49719            ESTABLISHED
  TCP    [::1]:389              [::1]:49734            ESTABLISHED
  TCP    [::1]:49674            [::1]:389              ESTABLISHED
  TCP    [::1]:49675            [::1]:389              ESTABLISHED
  TCP    [::1]:49719            [::1]:389              ESTABLISHED
  TCP    [::1]:49734            [::1]:389              ESTABLISHED
  TCP    [fe80::f1fc:108d:f77a:7f18%7]:389  [fe80::f1fc:108d:f77a:7f18%7]:49737  ESTABLISHED
  TCP    [fe80::f1fc:108d:f77a:7f18%7]:389  [fe80::f1fc:108d:f77a:7f18%7]:49775  ESTABLISHED
  TCP    [fe80::f1fc:108d:f77a:7f18%7]:389  [fe80::f1fc:108d:f77a:7f18%7]:49778  ESTABLISHED
  TCP    [fe80::f1fc:108d:f77a:7f18%7]:49737  [fe80::f1fc:108d:f77a:7f18%7]:389  ESTABLISHED
  TCP    [fe80::f1fc:108d:f77a:7f18%7]:49775  [fe80::f1fc:108d:f77a:7f18%7]:389  ESTABLISHED
  TCP    [fe80::f1fc:108d:f77a:7f18%7]:49778  [fe80::f1fc:108d:f77a:7f18%7]:389  ESTABLISHED
  UDP    0.0.0.0:389            *:*
  UDP    [::]:389               *:*
PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa> # 3. Monitorar tentativas de conexão na porta 445 (SMB - já desabilitado)
PS C:\Users\paulo.feitosa> netstat -an | findstr ":445"
  TCP    0.0.0.0:445            0.0.0.0:0              LISTENING
  TCP    [::]:445               [::]:0                 LISTENING
PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa> # 4. Monitorar tentativas de conexão na porta 3389 (RDP)
PS C:\Users\paulo.feitosa> netstat -an | findstr ":3389"
PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa> # 5. Verificar se há usuários desconhecidos logados
PS C:\Users\paulo.feitosa> query user
 USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
>paulo.feitosa         31c5ce94259d...     2  Active          .  5/10/2026 3:57 PM
PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa> # 6. Verificar processos suspeitos
PS C:\Users\paulo.feitosa> Get-Process | Where-Object {$_.CPU -gt 10 -or $_.WorkingSet64 -gt 500MB} |
>>     Select-Object Name, CPU, WorkingSet64
PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa> # 1. Remover o gateway (bloquear acesso à internet)
PS C:\Users\paulo.feitosa> $interfaceIndex = 6  # Ethernet 2 (seu IP atual está em 172.23.195.2)
PS C:\Users\paulo.feitosa> Remove-NetRoute -DestinationPrefix "0.0.0.0/0" -InterfaceIndex $interfaceIndex -Confirm:$false
Remove-NetRoute : No matching MSFT_NetRoute objects found by CIM query for instances of the
ROOT/StandardCimv2/MSFT_NetRoute class on the  CIM server: SELECT * FROM MSFT_NetRoute  WHERE ((DestinationPrefix LIKE
'0.0.0.0/0')) AND ((InterfaceIndex = 6)). Verify query parameters and retry.
At line:1 char:1
+ Remove-NetRoute -DestinationPrefix "0.0.0.0/0" -InterfaceIndex $inter ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (MSFT_NetRoute:String) [Remove-NetRoute], CimJobException
    + FullyQualifiedErrorId : CmdletizationQuery_NotFound,Remove-NetRoute

PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa> # 2. Restaurar DNS para loopback
PS C:\Users\paulo.feitosa> Set-DnsClientServerAddress -InterfaceIndex $interfaceIndex -ServerAddresses ("127.0.0.1")
Set-DnsClientServerAddress : No MSFT_DNSClientServerAddress objects found with property 'InterfaceIndex' equal to '6'.
 Verify the value of the property and retry.
At line:1 char:1
+ Set-DnsClientServerAddress -InterfaceIndex $interfaceIndex -ServerAdd ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (6:UInt32) [Set-DnsClientServerAddress], CimJobException
    + FullyQualifiedErrorId : CmdletizationQuery_NotFound_InterfaceIndex,Set-DnsClientServerAddress

PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa> # 3. Verificar que o AD está isolado novamente
PS C:\Users\paulo.feitosa> ping 8.8.8.8  # Deve falhar

Pinging 8.8.8.8 with 32 bytes of data:
Reply from 8.8.8.8: bytes=32 time=8ms TTL=115
Reply from 8.8.8.8: bytes=32 time=8ms TTL=115
Reply from 8.8.8.8: bytes=32 time=6ms TTL=115
Reply from 8.8.8.8: bytes=32 time=8ms TTL=115

Ping statistics for 8.8.8.8:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 6ms, Maximum = 8ms, Average = 7ms
PS C:\Users\paulo.feitosa> Get-NetRoute -DestinationPrefix "0.0.0.0/0"  # Deve retornar vazio

ifIndex DestinationPrefix                              NextHop                                  RouteMetric ifMetric Po
                                                                                                                     li
                                                                                                                     cy
                                                                                                                     St
                                                                                                                     or
                                                                                                                     e
------- -----------------                              -------                                  ----------- -------- --
7       0.0.0.0/0                                      172.23.192.1                                       0 15       Ac


PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa> # 4. Verificar que o Tailscale continua funcionando
PS C:\Users\paulo.feitosa> tailscale status
xxx.xxx.xxx.xxx   id-p-01                    feitosa.lima@   windows  -
xxx.xxx.xxx.xxx    alk-c02gf8bu-1             feitosa.lima@   macOS    offline, last seen 67d ago
xxx.xxx.xxx.xxx    alk-c02gf8bu               feitosa.lima@   macOS    offline, last seen 71d ago
xxx.xxx.xxx.xxx    api-gf-01                  feitosa.lima@   linux    offline, last seen 1d ago
xxx.xxx.xxx.xxx     defectdojo-gf-01           feitosa.lima@   linux    offline, last seen 1d ago
xxx.xxx.xxx.xxx     desktop-o87tpqi            feitosa.lima@   windows  -
xxx.xxx.xxx.xxx   fok-ldap-01                feitosa.lima@   linux    offline, last seen 43d ago
xxx.xxx.xxx.xxx    iga-gf-02                  feitosa.lima@   linux    -
xxx.xxx.xxx.xxx     linuxlite-virtual-machine  tagged-devices  linux    offline, last seen 1d ago
xxx.xxx.xxx.xxx     rh-gf-01                   feitosa.lima@   linux    offline, last seen 1d ago
xxx.xxx.xxx.xxx    sec-openvas-kali           feitosa.lima@   linux    offline, last seen 1d ago
xxx.xxx.xxx.xxx  sentinel-core              feitosa.lima@   linux    offline, last seen 1d ago
xxx.xxx.xxx.xxx     vault-gf-01                feitosa.lima@   linux    -
PS C:\Users\paulo.feitosa> tailscale ip
xxx.xxx.xxx.xxx
fd7a:115c:a1e0::5533:696c
PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa> # 5. Verificar conectividade com o midPoint via Tailscale
PS C:\Users\paulo.feitosa> ping xxx.xxx.xxx.xxx  # IP Tailscale do iga-gf-02

Pinging xxx.xxx.xxx.xxx with 32 bytes of data:
Reply from xxx.xxx.xxx.xxx: bytes=32 time=52ms TTL=64
Reply from xxx.xxx.xxx.xxx: bytes=32 time=2ms TTL=64
Reply from xxx.xxx.xxx.xxx: bytes=32 time<1ms TTL=64
Reply from xxx.xxx.xxx.xxx: bytes=32 time<1ms TTL=64

Ping statistics for xxx.xxx.xxx.xxx:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 0ms, Maximum = 52ms, Average = 13ms
PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa> # Verificar interfaces
PS C:\Users\paulo.feitosa> Get-NetIPInterface -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -like "*Ethernet*"}

ifIndex InterfaceAlias                  AddressFamily NlMtu(Bytes) InterfaceMetric Dhcp     ConnectionState PolicyStore
------- --------------                  ------------- ------------ --------------- ----     --------------- -----------
7       Ethernet 2                      IPv4                  1500              15 Enabled  Connected       ActiveStore


PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa> # Verificar configuração atual
PS C:\Users\paulo.feitosa> ipconfig

Windows IP Configuration


Unknown adapter Tailscale:

   Connection-specific DNS Suffix  . : tail28dcd4.ts.net
   IPv6 Address. . . . . . . . . . . : fd7a:115c:a1e0::5533:696c
   Link-local IPv6 Address . . . . . : fe80::99d0:ec2d:b2e7:536b%11
   IPv4 Address. . . . . . . . . . . : xxx.xxx.xxx.xxx
   Subnet Mask . . . . . . . . . . . : 255.255.255.255
   Default Gateway . . . . . . . . . :

Ethernet adapter Ethernet 2:

   Connection-specific DNS Suffix  . : mshome.net
   Link-local IPv6 Address . . . . . : fe80::f1fc:108d:f77a:7f18%7
   IPv4 Address. . . . . . . . . . . : 172.23.195.2
   Subnet Mask . . . . . . . . . . . : 255.255.240.0
   Default Gateway . . . . . . . . . : 172.23.192.1
PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa> # No console do AD (PowerShell como Administrador)
PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa> # Bloquear todas as conexões de entrada
PS C:\Users\paulo.feitosa> Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultInboundAction Block
Set-NetFirewallProfile : Access is denied.
At line:1 char:1
+ Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultInbound ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : PermissionDenied: (MSFT_NetFirewal...rofile?Domain"):root/standardci...FirewallProfile)
   [Set-NetFirewallProfile], CimException
    + FullyQualifiedErrorId : Windows System Error 5,Set-NetFirewallProfile

Set-NetFirewallProfile : Access is denied.
At line:1 char:1
+ Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultInbound ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : PermissionDenied: (MSFT_NetFirewal...rofile?Public"):root/standardci...FirewallProfile)
   [Set-NetFirewallProfile], CimException
    + FullyQualifiedErrorId : Windows System Error 5,Set-NetFirewallProfile

Set-NetFirewallProfile : Access is denied.
At line:1 char:1
+ Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultInbound ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : PermissionDenied: (MSFT_NetFirewal...ofile?Private"):root/standardci...FirewallProfile)
   [Set-NetFirewallProfile], CimException
    + FullyQualifiedErrorId : Windows System Error 5,Set-NetFirewallProfile

PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa>
PS C:\Users\paulo.feitosa>
