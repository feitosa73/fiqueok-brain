PowerShell 7.5.5

   A new PowerShell stable release is available: v7.6.0
   Upgrade now, or check out the release page at:
     https://aka.ms/PowerShell-Release?tag=v7.6.0

PS C:\Windows\System32> ssh paulo@xxx.xxx.xxx.xxx
The authenticity of host 'xxx.xxx.xxx.xxx (xxx.xxx.xxx.xxx)' can't be established.
ED25519 key fingerprint is SHA256:MU20LDLRxqc//DMVExUqWrjrNUJo5xFdgah3FP3DsbE.
This host key is known by the following other names/addresses:
    C:\Users\win/.ssh/known_hosts:23: xxx.xxx.xxx.xxx
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'xxx.xxx.xxx.xxx' (ED25519) to the list of known hosts.
paulo@xxx.xxx.xxx.xxx's password:
Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.8.0-107-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sat Apr 11 07:31:44 PM UTC 2026

  System load:           0.0
  Usage of /:            29.1% of 18.53GB
  Memory usage:          31%
  Swap usage:            0%
  Processes:             110
  Users logged in:       1
  IPv4 address for eth0: 192.168.15.6
  IPv6 address for eth0: 2804:1b3:a3c2:36a8:215:5dff:fe44:6919

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

38 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


Last login: Fri Apr 10 23:02:37 2026 from xxx.xxx.xxx.xxx
paulo@api-gf-01:~$ # Cria o diretório seguro
sudo mkdir -p /var/lib/shadow-api

# Grava o token no arquivo (Cole o token gerado anteriormente)
echo "hvs.CAESINLtw0ByJ1L8VCG7Z_O2yC4wF_goktJsPlbt0RDwIbegGh4KHGh2cy56M1RjWVZNU0JlZ0xsMlRSNEZrZm1WZVE" | sudo tee /var/lib/shadow-api/vault_token > /dev/null

# Restringe o acesso: apenas o root poderá ler este arquivo
sudo chmod 600 /var/lib/shadow-api/vault_token
[sudo] password for paulo:
Sorry, try again.
[sudo] password for paulo:
paulo@api-gf-01:~$ sudo cat /var/lib/shadow-api/vault_token
hvs.CAESINLtw0ByJ1L8VCG7Z_O2yC4wF_goktJsPlbt0RDwIbegGh4KHGh2cy56M1RjWVZNU0JlZ0xsMlRSNEZrZm1WZVE
paulo@api-gf-01:~$
paulo@api-gf-01:~$ # Cria a árvore de diretórios do projeto
mkdir -p ~/prj008-shadow-api/{app,tests,config,scripts}

# Cria os arquivos iniciais vazios
cd ~/prj008-shadow-api
touch app/__init__.py app/main.py app/database.py app/vault.py .env .gitignore
paulo@api-gf-01:~/prj008-shadow-api$
paulo@api-gf-01:~/prj008-shadow-api$ # Instala o pacote venv se necessário
sudo apt update && sudo apt install -y python3-venv

# Cria e ativa o ambiente virtual
python3 -m venv venv
source venv/bin/activate
Hit:1 https://download.docker.com/linux/ubuntu noble InRelease
Get:2 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Get:3 https://pkgs.tailscale.com/stable/ubuntu noble InRelease
Hit:4 http://archive.ubuntu.com/ubuntu noble InRelease
Get:5 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Get:6 http://security.ubuntu.com/ubuntu noble-security/main amd64 Components [21.5 kB]
Get:7 http://security.ubuntu.com/ubuntu noble-security/restricted amd64 Components [212 B]
Get:8 http://security.ubuntu.com/ubuntu noble-security/universe amd64 Components [74.2 kB]
Get:9 http://security.ubuntu.com/ubuntu noble-security/universe amd64 c-n-f Metadata [22.9 kB]
Get:10 http://security.ubuntu.com/ubuntu noble-security/multiverse amd64 Components [208 B]
Get:11 http://archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
Get:12 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages [1,881 kB]
Get:13 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Components [177 kB]
Get:14 http://archive.ubuntu.com/ubuntu noble-updates/restricted amd64 Components [212 B]
Get:15 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 Packages [1,665 kB]
Get:16 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 Components [386 kB]
Get:17 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 c-n-f Metadata [34.3 kB]
Get:18 http://archive.ubuntu.com/ubuntu noble-updates/multiverse amd64 Components [940 B]
Get:19 http://archive.ubuntu.com/ubuntu noble-backports/main amd64 Components [7,380 B]
Get:20 http://archive.ubuntu.com/ubuntu noble-backports/restricted amd64 Components [212 B]
Get:21 http://archive.ubuntu.com/ubuntu noble-backports/universe amd64 Components [13.2 kB]
Get:22 http://archive.ubuntu.com/ubuntu noble-backports/multiverse amd64 Components [212 B]
Fetched 4,669 kB in 4s (1,120 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
39 packages can be upgraded. Run 'apt list --upgradable' to see them.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  python3-pip-whl python3-setuptools-whl python3.12-venv
The following NEW packages will be installed:
  python3-pip-whl python3-setuptools-whl python3-venv python3.12-venv
0 upgraded, 4 newly installed, 0 to remove and 39 not upgraded.
Need to get 2,430 kB of archives.
After this operation, 2,783 kB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 python3-pip-whl all 24.0+dfsg-1ubuntu1.3 [1,707 kB]
Get:2 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 python3-setuptools-whl all 68.1.2-2ubuntu1.2 [716 kB]
Get:3 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 python3.12-venv amd64 3.12.3-1ubuntu0.12 [5,666 B]
Get:4 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 python3-venv amd64 3.12.3-0ubuntu2.1 [1,032 B]
Fetched 2,430 kB in 3s (792 kB/s)
Selecting previously unselected package python3-pip-whl.
(Reading database ... 125793 files and directories currently installed.)
Preparing to unpack .../python3-pip-whl_24.0+dfsg-1ubuntu1.3_all.deb ...
Unpacking python3-pip-whl (24.0+dfsg-1ubuntu1.3) ...
Selecting previously unselected package python3-setuptools-whl.
Preparing to unpack .../python3-setuptools-whl_68.1.2-2ubuntu1.2_all.deb ...
Unpacking python3-setuptools-whl (68.1.2-2ubuntu1.2) ...
Selecting previously unselected package python3.12-venv.
Preparing to unpack .../python3.12-venv_3.12.3-1ubuntu0.12_amd64.deb ...
Unpacking python3.12-venv (3.12.3-1ubuntu0.12) ...
Selecting previously unselected package python3-venv.
Preparing to unpack .../python3-venv_3.12.3-0ubuntu2.1_amd64.deb ...
Unpacking python3-venv (3.12.3-0ubuntu2.1) ...
Setting up python3-setuptools-whl (68.1.2-2ubuntu1.2) ...
Setting up python3-pip-whl (24.0+dfsg-1ubuntu1.3) ...
Setting up python3.12-venv (3.12.3-1ubuntu0.12) ...
Setting up python3-venv (3.12.3-0ubuntu2.1) ...
Scanning processes...
Scanning linux images...

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ # Cria o arquivo de requerimentos
cat <<EOF > requirements.txt
fastapi==0.115.0
uvicorn==0.30.6
hvac==2.3.0
python-dotenv==1.0.1
sqlalchemy==2.0.35
pymysql==1.1.1
EOF

# Instala as bibliotecas
pip install --upgrade pip
pip install -r requirements.txt
Requirement already satisfied: pip in ./venv/lib/python3.12/site-packages (24.0)
WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'ConnectTimeoutError(<pip._vendor.urllib3.connection.HTTPSConnection object at 0x7dbdb08c8890>, 'Connection to pypi.org timed out. (connect timeout=15)')': /simple/pip/
client_loop: send disconnect: Connection reset
PS C:\Windows\System32> ssh paulo@xxx.xxx.xxx.xxx
ssh: connect to host xxx.xxx.xxx.xxx port 22: Connection timed out
PS C:\Windows\System32> ssh paulo@xxx.xxx.xxx.xxx
ssh: connect to host xxx.xxx.xxx.xxx port 22: Connection timed out
PS C:\Windows\System32> ssh paulo@xxx.xxx.xxx.xxx
ssh: connect to host xxx.xxx.xxx.xxx port 22: Connection timed out
PS C:\Windows\System32>
PS C:\Windows\System32>
PS C:\Windows\System32>
PS C:\Windows\System32> ssh paulo@xxx.xxx.xxx.xxx
ssh: connect to host xxx.xxx.xxx.xxx port 22: Connection timed out
PS C:\Windows\System32>
PS C:\Windows\System32>
PS C:\Windows\System32> ipconfig /all

Configuração de IP do Windows

   Nome do host. . . . . . . . . . . . . . . . : DESKTOP-O87TPQI
   Sufixo DNS primário . . . . . . . . . . . . :
   Tipo de nó. . . . . . . . . . . . . . . . . : híbrido
   Roteamento de IP ativado. . . . . . . . . . : não
   Proxy WINS ativado. . . . . . . . . . . . . : não
   Lista de pesquisa de sufixo DNS . . . . . . : tail28dcd4.ts.net

Adaptador desconhecido Tailscale:

   Sufixo DNS específico de conexão. . . . . . : tail28dcd4.ts.net
   Descrição . . . . . . . . . . . . . . . . . : Tailscale Tunnel
   Endereço Físico . . . . . . . . . . . . . . :
   DHCP Habilitado . . . . . . . . . . . . . . : Não
   Configuração Automática Habilitada. . . . . : Sim
   Endereço IPv6 . . . . . . . . . . : fd7a:115c:a1e0::4501:4997(Preferencial)
   Endereço IPv6 de link local . . . . . . . . : fe80::77b6:94ba:c813:c8c6%9(Preferencial)
   Endereço IPv4. . . . . . . .  . . . . . . . : xxx.xxx.xxx.xxx(Preferencial)
   Máscara de Sub-rede . . . . . . . . . . . . : 255.255.255.255
   Gateway Padrão. . . . . . . . . . . . . . . :
   NetBIOS em Tcpip. . . . . . . . . . . . . . : Desabilitado
   Lista de pesquisa de sufixos DNS específicos da conexão:
                                                 tail28dcd4.ts.net

Adaptador Ethernet vEthernet (vSwitch_External_PRJ003):

   Sufixo DNS específico de conexão. . . . . . :
   Descrição . . . . . . . . . . . . . . . . . : Hyper-V Virtual Ethernet Adapter #2
   Endereço Físico . . . . . . . . . . . . . . : 60-45-2E-BE-D5-B1
   DHCP Habilitado . . . . . . . . . . . . . . : Sim
   Configuração Automática Habilitada. . . . . : Sim
   Endereço IPv6 . . . . . . . . . . : 2804:1b3:a3c2:36a8:50b4:cb62:feb1:b58(Preferencial)
   Endereço IPv6 Temporário. . . . . . . . : 2804:1b3:a3c2:36a8:1591:baa6:9015:eb56(Preferencial)
   Endereço IPv6 de link local . . . . . . . . : fe80::3662:9956:90af:3798%8(Preferencial)
   Endereço IPv4. . . . . . . .  . . . . . . . : 192.168.15.4(Preferencial)
   Máscara de Sub-rede . . . . . . . . . . . . : 255.255.255.0
   Concessão Obtida. . . . . . . . . . . . . . : Saturday, April 11, 2026 11:28:38 AM
   Concessão Expira. . . . . . . . . . . . . . : Saturday, April 11, 2026 7:09:03 PM
   Gateway Padrão. . . . . . . . . . . . . . . : fe80::920a:62ff:fe9e:eb30%8
                                                 192.168.15.1
   Servidor DHCP . . . . . . . . . . . . . . . : 192.168.15.1
   IAID de DHCPv6. . . . . . . . . . . . . . . : 912278830
   DUID de Cliente DHCPv6. . . . . . . . . . . : 00-01-00-01-2F-FF-AA-FC-10-FF-E0-67-52-72
   Servidores DNS. . . . . . . . . . . . . . . : fe80::920a:62ff:fe9e:eb30%8
                                                 192.168.15.1
                                                 fe80::920a:62ff:fe9e:eb30%8
   NetBIOS em Tcpip. . . . . . . . . . . . . . : Habilitado

Adaptador de Rede sem Fio Wi-Fi 2:

   Estado da mídia. . . . . . . . . . . . . .  : mídia desconectada
   Sufixo DNS específico de conexão. . . . . . :
   Descrição . . . . . . . . . . . . . . . . . : 802.11n USB Wireless LAN Card
   Endereço Físico . . . . . . . . . . . . . . : DC-4E-F4-0A-E7-CB
   DHCP Habilitado . . . . . . . . . . . . . . : Sim
   Configuração Automática Habilitada. . . . . : Sim

Adaptador de Rede sem Fio Conexão Local* 11:

   Estado da mídia. . . . . . . . . . . . . .  : mídia desconectada
   Sufixo DNS específico de conexão. . . . . . :
   Descrição . . . . . . . . . . . . . . . . . : Microsoft Wi-Fi Direct Virtual Adapter #3
   Endereço Físico . . . . . . . . . . . . . . : DC-4E-F4-0A-E7-CD
   DHCP Habilitado . . . . . . . . . . . . . . : Sim
   Configuração Automática Habilitada. . . . . : Sim

Adaptador de Rede sem Fio Conexão Local* 13:

   Estado da mídia. . . . . . . . . . . . . .  : mídia desconectada
   Sufixo DNS específico de conexão. . . . . . :
   Descrição . . . . . . . . . . . . . . . . . : Microsoft Wi-Fi Direct Virtual Adapter #4
   Endereço Físico . . . . . . . . . . . . . . : DC-4E-F4-0A-E7-CE
   DHCP Habilitado . . . . . . . . . . . . . . : Sim
   Configuração Automática Habilitada. . . . . : Sim

Adaptador Ethernet Conexão de Rede Bluetooth:

   Estado da mídia. . . . . . . . . . . . . .  : mídia desconectada
   Sufixo DNS específico de conexão. . . . . . :
   Descrição . . . . . . . . . . . . . . . . . : Bluetooth Device (Personal Area Network)
   Endereço Físico . . . . . . . . . . . . . . : 60-45-2E-BE-D5-B5
   DHCP Habilitado . . . . . . . . . . . . . . : Sim
   Configuração Automática Habilitada. . . . . : Sim

Adaptador Ethernet Ethernet:

   Estado da mídia. . . . . . . . . . . . . .  : mídia desconectada
   Sufixo DNS específico de conexão. . . . . . :
   Descrição . . . . . . . . . . . . . . . . . : Realtek Gaming 2.5GbE Family Controller
   Endereço Físico . . . . . . . . . . . . . . : 10-FF-E0-67-52-72
   DHCP Habilitado . . . . . . . . . . . . . . : Sim
   Configuração Automática Habilitada. . . . . : Sim

Adaptador Ethernet vEthernet (Default Switch):

   Sufixo DNS específico de conexão. . . . . . :
   Descrição . . . . . . . . . . . . . . . . . : Hyper-V Virtual Ethernet Adapter
   Endereço Físico . . . . . . . . . . . . . . : 00-15-5D-44-69-00
   DHCP Habilitado . . . . . . . . . . . . . . : Não
   Configuração Automática Habilitada. . . . . : Sim
   Endereço IPv6 de link local . . . . . . . . : fe80::6e1d:8816:8cd9:e206%29(Preferencial)
   Endereço IPv4. . . . . . . .  . . . . . . . : 192.168.96.1(Preferencial)
   Máscara de Sub-rede . . . . . . . . . . . . : 255.255.240.0
   Gateway Padrão. . . . . . . . . . . . . . . :
   IAID de DHCPv6. . . . . . . . . . . . . . . : 486544733
   DUID de Cliente DHCPv6. . . . . . . . . . . : 00-01-00-01-2F-FF-AA-FC-10-FF-E0-67-52-72
   NetBIOS em Tcpip. . . . . . . . . . . . . . : Habilitado
PS C:\Windows\System32>
PS C:\Windows\System32>
PS C:\Windows\System32>
PS C:\Windows\System32> ssh paulo@xxx.xxx.xxx.xxx
ssh: connect to host xxx.xxx.xxx.xxx port 22: Connection timed out
PS C:\Windows\System32> ssh paulo@xxx.xxx.xxx.xxx
PS C:\Windows\System32>
PS C:\Windows\System32>
PS C:\Windows\System32> ssh paulo@192.168.99.64
The authenticity of host '192.168.99.64 (192.168.99.64)' can't be established.
ED25519 key fingerprint is SHA256:MU20LDLRxqc//DMVExUqWrjrNUJo5xFdgah3FP3DsbE.
This host key is known by the following other names/addresses:
    C:\Users\win/.ssh/known_hosts:23: xxx.xxx.xxx.xxx
    C:\Users\win/.ssh/known_hosts:32: xxx.xxx.xxx.xxx
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.99.64' (ED25519) to the list of known hosts.
paulo@192.168.99.64's password:
Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.8.0-107-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sat Apr 11 08:17:39 PM UTC 2026

  System load:  0.0                Processes:             107
  Usage of /:   29.7% of 18.53GB   Users logged in:       1
  Memory usage: 31%                IPv4 address for eth0: 192.168.99.64
  Swap usage:   0%

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

38 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


Last login: Sat Apr 11 19:31:44 2026 from xxx.xxx.xxx.xxx
paulo@api-gf-01:~$ sudo tailscale up --hostname=api-gf-01 --accept-routes
ip addr show tailscale0
[sudo] password for paulo:

To authenticate, visit:

        https://login.tailscale.com/a/90b192f01cd26

Success.
3: tailscale0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1280 qdisc fq_codel state UNKNOWN group default qlen 500
    link/none
    inet xxx.xxx.xxx.xxx/32 scope global tailscale0
       valid_lft forever preferred_lft forever
    inet6 fd7a:115c:a1e0::5d33:6666/128 scope global
       valid_lft forever preferred_lft forever
    inet6 fe80::ee36:731c:3b73:373f/64 scope link stable-privacy
       valid_lft forever preferred_lft forever
paulo@api-gf-01:~$
paulo@api-gf-01:~$
paulo@api-gf-01:~$ exit
logout
Connection to 192.168.99.64 closed.
PS C:\Windows\System32> ssh paulo@xxx.xxx.xxx.xxx
The authenticity of host 'xxx.xxx.xxx.xxx (xxx.xxx.xxx.xxx)' can't be established.
ED25519 key fingerprint is SHA256:MU20LDLRxqc//DMVExUqWrjrNUJo5xFdgah3FP3DsbE.
This host key is known by the following other names/addresses:
    C:\Users\win/.ssh/known_hosts:23: xxx.xxx.xxx.xxx
    C:\Users\win/.ssh/known_hosts:32: xxx.xxx.xxx.xxx
    C:\Users\win/.ssh/known_hosts:33: 192.168.99.64
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'xxx.xxx.xxx.xxx' (ED25519) to the list of known hosts.
paulo@xxx.xxx.xxx.xxx's password:
Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.8.0-107-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sat Apr 11 08:18:47 PM UTC 2026

  System load:  0.0                Processes:             109
  Usage of /:   29.7% of 18.53GB   Users logged in:       1
  Memory usage: 31%                IPv4 address for eth0: 192.168.99.64
  Swap usage:   0%

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

38 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


Last login: Sat Apr 11 20:17:39 2026 from 192.168.96.1
paulo@api-gf-01:~$
paulo@api-gf-01:~$ # 1. Entre na pasta do projeto
cd ~/prj008-shadow-api

# 2. Ative o ambiente virtual
source venv/bin/activate

# 3. Tente a instalação novamente (agora com a rede estável)
pip install -r requirements.txt
Requirement already satisfied: fastapi==0.115.0 in ./venv/lib/python3.12/site-packages (from -r requirements.txt (line 1)) (0.115.0)
Requirement already satisfied: uvicorn==0.30.6 in ./venv/lib/python3.12/site-packages (from -r requirements.txt (line 2)) (0.30.6)
Requirement already satisfied: hvac==2.3.0 in ./venv/lib/python3.12/site-packages (from -r requirements.txt (line 3)) (2.3.0)
Requirement already satisfied: python-dotenv==1.0.1 in ./venv/lib/python3.12/site-packages (from -r requirements.txt (line 4)) (1.0.1)
Requirement already satisfied: sqlalchemy==2.0.35 in ./venv/lib/python3.12/site-packages (from -r requirements.txt (line 5)) (2.0.35)
Requirement already satisfied: pymysql==1.1.1 in ./venv/lib/python3.12/site-packages (from -r requirements.txt (line 6)) (1.1.1)
Requirement already satisfied: starlette<0.39.0,>=0.37.2 in ./venv/lib/python3.12/site-packages (from fastapi==0.115.0->-r requirements.txt (line 1)) (0.38.6)
Requirement already satisfied: pydantic!=1.8,!=1.8.1,!=2.0.0,!=2.0.1,!=2.1.0,<3.0.0,>=1.7.4 in ./venv/lib/python3.12/site-packages (from fastapi==0.115.0->-r requirements.txt (line 1)) (2.12.5)
Requirement already satisfied: typing-extensions>=4.8.0 in ./venv/lib/python3.12/site-packages (from fastapi==0.115.0->-r requirements.txt (line 1)) (4.15.0)
Requirement already satisfied: click>=7.0 in ./venv/lib/python3.12/site-packages (from uvicorn==0.30.6->-r requirements.txt (line 2)) (8.3.2)
Requirement already satisfied: h11>=0.8 in ./venv/lib/python3.12/site-packages (from uvicorn==0.30.6->-r requirements.txt (line 2)) (0.16.0)
Requirement already satisfied: requests<3.0.0,>=2.27.1 in ./venv/lib/python3.12/site-packages (from hvac==2.3.0->-r requirements.txt (line 3)) (2.33.1)
Requirement already satisfied: greenlet!=0.4.17 in ./venv/lib/python3.12/site-packages (from sqlalchemy==2.0.35->-r requirements.txt (line 5)) (3.4.0)
Requirement already satisfied: annotated-types>=0.6.0 in ./venv/lib/python3.12/site-packages (from pydantic!=1.8,!=1.8.1,!=2.0.0,!=2.0.1,!=2.1.0,<3.0.0,>=1.7.4->fastapi==0.115.0->-r requirements.txt (line 1)) (0.7.0)
Requirement already satisfied: pydantic-core==2.41.5 in ./venv/lib/python3.12/site-packages (from pydantic!=1.8,!=1.8.1,!=2.0.0,!=2.0.1,!=2.1.0,<3.0.0,>=1.7.4->fastapi==0.115.0->-r requirements.txt (line 1)) (2.41.5)
Requirement already satisfied: typing-inspection>=0.4.2 in ./venv/lib/python3.12/site-packages (from pydantic!=1.8,!=1.8.1,!=2.0.0,!=2.0.1,!=2.1.0,<3.0.0,>=1.7.4->fastapi==0.115.0->-r requirements.txt (line 1)) (0.4.2)
Requirement already satisfied: charset_normalizer<4,>=2 in ./venv/lib/python3.12/site-packages (from requests<3.0.0,>=2.27.1->hvac==2.3.0->-r requirements.txt (line 3)) (3.4.7)
Requirement already satisfied: idna<4,>=2.5 in ./venv/lib/python3.12/site-packages (from requests<3.0.0,>=2.27.1->hvac==2.3.0->-r requirements.txt (line 3)) (3.11)
Requirement already satisfied: urllib3<3,>=1.26 in ./venv/lib/python3.12/site-packages (from requests<3.0.0,>=2.27.1->hvac==2.3.0->-r requirements.txt (line 3)) (2.6.3)
Requirement already satisfied: certifi>=2023.5.7 in ./venv/lib/python3.12/site-packages (from requests<3.0.0,>=2.27.1->hvac==2.3.0->-r requirements.txt (line 3)) (2026.2.25)
Requirement already satisfied: anyio<5,>=3.4.0 in ./venv/lib/python3.12/site-packages (from starlette<0.39.0,>=0.37.2->fastapi==0.115.0->-r requirements.txt (line 1)) (4.13.0)
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ vi smoke_test_vault.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat smoke_test_vault.py
# Arquivo: smoke_test_vault.py
import hvac
import os

# Configurações de Auditoria
VAULT_URL = "http://xxx.xxx.xxx.xxx:8200"
TOKEN_PATH = "/var/lib/shadow-api/vault_token"

def test_vault_connection():
    try:
        # 1. Lê o token do arquivo seguro
        with open(TOKEN_PATH, 'r') as f:
            client_token = f.read().strip()

        # 2. Autentica no Vault
        client = hvac.Client(url=VAULT_URL, token=client_token)

        # 3. Tenta ler o segredo do OrangeHRM
        read_response = client.secrets.kv.v2.read_secret_version(
            path='orangehrm/mysql',
            mount_point='secret'
        )

        username = read_response['data']['data']['username']
        print(f"✅ SUCESSO: Conexão com Vault OK!")
        print(f"✅ AUDITORIA: Usuário '{username}' recuperado do cofre.")

    except Exception as e:
        print(f"❌ ERRO: Falha na validação do cofre.")
        print(f"🔍 DETALHE: {str(e)}")

if __name__ == "__main__":
    test_vault_connection()
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ # Garante que o venv está ativo
source venv/bin/activate

# Roda o teste
python smoke_test_vault.py
❌ ERRO: Falha na validação do cofre.
🔍 DETALHE: [Errno 13] Permission denied: '/var/lib/shadow-api/vault_token'
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ # Lembre-se de apontar para o python do seu ambiente virtual
sudo ./venv/bin/python smoke_test_vault.py
[sudo] password for paulo:
Sorry, try again.
[sudo] password for paulo:
/home/paulo/prj008-shadow-api/smoke_test_vault.py:19: DeprecationWarning: The raise_on_deleted_version parameter will change its default value to False in hvac v3.0.0. The current default of True will presere previous behavior. To use the old behavior with no warning, explicitly set this value to True. See https://github.com/hvac/hvac/pull/907
  read_response = client.secrets.kv.v2.read_secret_version(
❌ ERRO: Falha na validação do cofre.
🔍 DETALHE: None, on get http://xxx.xxx.xxx.xxx:8200/v1/secret/data/orangehrm/mysql
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ curl -I http://xxx.xxx.xxx.xxx:8200/v1/sys/health
HTTP/1.1 200 OK
Cache-Control: no-store
Content-Type: application/json
Strict-Transport-Security: max-age=31536000; includeSubDomains
Date: Sat, 11 Apr 2026 20:27:25 GMT

(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nano smoke_test_vault.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$ (venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat smoke_test_vault.py
# Arquivo: smoke_test_vault.py
import hvac
import os

# Configurações de Auditoria
VAULT_URL = "http://xxx.xxx.xxx.xxx:8200"
TOKEN_PATH = "/var/lib/shadow-api/vault_token"

def test_vault_connection():
    try:
        # 1. Lê o token do arquivo seguro
        with open(TOKEN_PATH, 'r') as f:
            client_token = f.read().strip()

        # 2. Autentica no Vault
        client = hvac.Client(url=VAULT_URL, token=client_token)

        # 3. Tenta ler o segredo do OrangeHRM
        read_response = client.secrets.kv.v2.read_secret_version(
            path='orangehrm/mysql',
            mount_point='secret'
        )

        username = read_response['data']['data']['username']
        print(f"✅ SUCESSO: Conexão com Vault OK!")
        print(f"✅ AUDITORIA: Usuário '{username}' recuperado do cofre.")

    except Exception as e:
        print(f"❌ ERRO: Falha na validação do cofre.")
        print(f"🔍 DETALHE: {str(e)}")

if __name__ == "__main__":
    test_vault_connection()
(venv) paulo@api-gf-01:~/prj008-shadow-api$ sudo chown paulo:paulo /var/lib/shadow-api/vault_token
chmod 600 /var/lib/shadow-api/vault_token
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nano smoke_test_vault.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat smoke_test_vault.py
# Arquivo: smoke_test_vault.py
import hvac
import sys

# Configurações de Auditoria - Living Lab Fiqueok
VAULT_URL = "http://xxx.xxx.xxx.xxx:8200"
TOKEN_PATH = "/var/lib/shadow-api/vault_token"

def test_vault_connection():
    print(f"--- Iniciando Validação de GRC (Vault Connection) ---")

    # 1. Tentativa de leitura do Token
    try:
        with open(TOKEN_PATH, 'r') as f:
            client_token = f.read().strip()
        print(f"✅ Arquivo de token lido com sucesso.")
    except Exception as e:
        print(f"❌ Erro ao ler arquivo de token: {e}")
        return

    # 2. Inicialização do Cliente
    client = hvac.Client(url=VAULT_URL, token=client_token)

    # 3. Validação de Autenticação
    if not client.is_authenticated():
        print(f"❌ Erro: O token fornecido é inválido ou expirou.")
        return
    print(f"✅ Autenticação no Vault confirmada.")

    # 4. Tentativa de leitura do Segredo (Path de Auditoria)
    try:
        # Nota: 'secret' é o mount point padrão KV v2
        read_response = client.secrets.kv.v2.read_secret_version(
            path='orangehrm/mysql',
            mount_point='secret'
        )

        # Navega no dicionário de resposta do Vault
        secret_data = read_response['data']['data']
        username = secret_data.get('username', 'N/A')

        print(f"✅ SUCESSO TOTAL!")
        print(f"✅ Usuário recuperado do cofre: {username}")
        print(f"--- Fim da Validação ---")

    except hvac.exceptions.Forbidden:
        print(f"❌ ERRO 403: O token NÃO tem permissão para acessar 'secret/orangehrm/mysql'.")
        print(f"💡 Verifique a política 'api-proxy-policy' no Vault.")
    except hvac.exceptions.InvalidPath:
        print(f"❌ ERRO 404: O caminho 'secret/orangehrm/mysql' não existe.")
        print(f"💡 Verifique se o segredo foi criado com esse nome exato.")
    except Exception as e:
        print(f"❌ Erro inesperado: {str(e)}")

if __name__ == "__main__":
    test_vault_connection()
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ python smoke_test_vault.py
--- Iniciando Validação de GRC (Vault Connection) ---
✅ Arquivo de token lido com sucesso.
✅ Autenticação no Vault confirmada.
/home/paulo/prj008-shadow-api/smoke_test_vault.py:33: DeprecationWarning: The raise_on_deleted_version parameter will change its default value to False in hvac v3.0.0. The current default of True will presere previous behavior. To use the old behavior with no warning, explicitly set this value to True. See https://github.com/hvac/hvac/pull/907
  read_response = client.secrets.kv.v2.read_secret_version(
❌ ERRO 404: O caminho 'secret/orangehrm/mysql' não existe.
💡 Verifique se o segredo foi criado com esse nome exato.
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nano smoke_test_vault.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat smoke_test_vault.py
# Arquivo: smoke_test_vault.py
import hvac
import sys

# Configurações de Auditoria - Living Lab Fiqueok
VAULT_URL = "http://xxx.xxx.xxx.xxx:8200"
TOKEN_PATH = "/var/lib/shadow-api/vault_token"

def test_vault_connection():
    print(f"--- Iniciando Validação de GRC (Vault Connection) ---")

    # 1. Tentativa de leitura do Token
    try:
        with open(TOKEN_PATH, 'r') as f:
            client_token = f.read().strip()
        print(f"✅ Arquivo de token lido com sucesso.")
    except Exception as e:
        print(f"❌ Erro ao ler arquivo de token: {e}")
        return

    # 2. Inicialização do Cliente
    client = hvac.Client(url=VAULT_URL, token=client_token)

    # 3. Validação de Autenticação
    if not client.is_authenticated():
        print(f"❌ Erro: O token fornecido é inválido ou expirou.")
        return
    print(f"✅ Autenticação no Vault confirmada.")

    # 4. Tentativa de leitura do Segredo (Path de Auditoria)
    try:
        # Nota: 'secret' é o mount point padrão KV v2
        read_response = client.secrets.kv.v2.read_secret_version(
            path='orangehrm/db_api',
            mount_point='secret'
        )

        # Navega no dicionário de resposta do Vault
        secret_data = read_response['data']['data']
        username = secret_data.get('username', 'N/A')

        print(f"✅ SUCESSO TOTAL!")
        print(f"✅ Usuário recuperado do cofre: {username}")
        print(f"--- Fim da Validação ---")

    except hvac.exceptions.Forbidden:
        print(f"❌ ERRO 403: O token NÃO tem permissão para acessar 'secret/orangehrm/mysql'.")
        print(f"💡 Verifique a política 'api-proxy-policy' no Vault.")
    except hvac.exceptions.InvalidPath:
        print(f"❌ ERRO 404: O caminho 'secret/orangehrm/mysql' não existe.")
        print(f"💡 Verifique se o segredo foi criado com esse nome exato.")
    except Exception as e:
        print(f"❌ Erro inesperado: {str(e)}")

if __name__ == "__main__":
    test_vault_connection()
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ python smoke_test_vault.py
--- Iniciando Validação de GRC (Vault Connection) ---
✅ Arquivo de token lido com sucesso.
✅ Autenticação no Vault confirmada.
/home/paulo/prj008-shadow-api/smoke_test_vault.py:33: DeprecationWarning: The raise_on_deleted_version parameter will change its default value to False in hvac v3.0.0. The current default of True will presere previous behavior. To use the old behavior with no warning, explicitly set this value to True. See https://github.com/hvac/hvac/pull/907
  read_response = client.secrets.kv.v2.read_secret_version(
✅ SUCESSO TOTAL!
✅ Usuário recuperado do cofre: svc_shadow_api
--- Fim da Validação ---
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ python smoke_test_vault.py
--- Iniciando Validação de GRC (Vault Connection) ---
✅ Arquivo de token lido com sucesso.
✅ Autenticação no Vault confirmada.
/home/paulo/prj008-shadow-api/smoke_test_vault.py:33: DeprecationWarning: The raise_on_deleted_version parameter will change its default value to False in hvac v3.0.0. The current default of True will presere previous behavior. To use the old behavior with no warning, explicitly set this value to True. See https://github.com/hvac/hvac/pull/907
  read_response = client.secrets.kv.v2.read_secret_version(
✅ SUCESSO TOTAL!
✅ Usuário recuperado do cofre: svc_shadow_api
--- Fim da Validação ---
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ ping -c 3 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=116 time=11.4 ms


64 bytes from 8.8.8.8: icmp_seq=2 ttl=116 time=22.2 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=116 time=5.87 ms

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 5.866/13.147/22.193/6.781 ms
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ ls -l /var/lib/shadow-api/vault_token
-rw------- 1 paulo paulo 96 Apr 11 19:32 /var/lib/shadow-api/vault_token
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nc -zv xxx.xxx.xxx.xxx
nc: missing port number
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nc -zv xxx.xxx.xxx.xxx 3306



^C
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ ping -c 4 xxx.xxx.xxx.xxx
PING xxx.xxx.xxx.xxx (xxx.xxx.xxx.xxx) 56(84) bytes of data.

--- xxx.xxx.xxx.xxx ping statistics ---
4 packets transmitted, 0 received, 100% packet loss, time 3053ms

(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ ls
app  config  requirements.txt  scripts  smoke_test_vault.py  tests  venv
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cd app
(venv) paulo@api-gf-01:~/prj008-shadow-api/app$ ls
database.py  __init__.py  main.py  vault.py
(venv) paulo@api-gf-01:~/prj008-shadow-api/app$
(venv) paulo@api-gf-01:~/prj008-shadow-api/app$
(venv) paulo@api-gf-01:~/prj008-shadow-api/app$ nano database.py
(venv) paulo@api-gf-01:~/prj008-shadow-api/app$
(venv) paulo@api-gf-01:~/prj008-shadow-api/app$
(venv) paulo@api-gf-01:~/prj008-shadow-api/app$ cat database.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from app.vault import get_db_credentials

# 1. Recupera credenciais dinamicamente do Vault
try:
    creds = get_db_credentials()

    # Mapeamento conforme seu 'vault kv get' validado
    DB_USER = creds['username']
    DB_PASS = creds['password']
    DB_HOST = creds['db_host']
    DB_NAME = creds['db_name']
    DB_PORT = "3306"

    # 2. String de conexão para o dialeto PyMySQL
    SQLALCHEMY_DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

    print(f"✅ GRC: Infraestrutura de conexão pronta para o host {DB_HOST}")

except KeyError as e:
    raise Exception(f"❌ Erro de Configuração: Chave {str(e)} ausente no segredo do Vault.")

# 3. Configuração do Motor e Sessão
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Dependência de Banco para o FastAPI
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
(venv) paulo@api-gf-01:~/prj008-shadow-api/app$ nano test_db_real.py
(venv) paulo@api-gf-01:~/prj008-shadow-api/app$
(venv) paulo@api-gf-01:~/prj008-shadow-api/app$ cat test_db_real.py
from app.database import engine
from sqlalchemy import text

def test_connection():
    try:
        with engine.connect() as connection:
            # Tenta rodar um comando simples no MariaDB
            result = connection.execute(text("SELECT DATABASE();"))
            db_name = result.fetchone()[0]
            print(f"🔥 SUCESSO: Conectado ao banco '{db_name}' via Shadow API!")
    except Exception as e:
        print(f"❌ FALHA NA SPRINT 2: {e}")

if __name__ == "__main__":
    test_connection()
(venv) paulo@api-gf-01:~/prj008-shadow-api/app$ python test_db_real.py
Traceback (most recent call last):
  File "/home/paulo/prj008-shadow-api/app/test_db_real.py", line 1, in <module>
    from app.database import engine
ModuleNotFoundError: No module named 'app'
(venv) paulo@api-gf-01:~/prj008-shadow-api/app$
(venv) paulo@api-gf-01:~/prj008-shadow-api/app$
(venv) paulo@api-gf-01:~/prj008-shadow-api/app$ cd ~/prj008-shadow-api
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ mv app/test_db_real.py .
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ python test_db_real.py
Traceback (most recent call last):
  File "/home/paulo/prj008-shadow-api/test_db_real.py", line 1, in <module>
    from app.database import engine
  File "/home/paulo/prj008-shadow-api/app/database.py", line 3, in <module>
    from app.vault import get_db_credentials
ImportError: cannot import name 'get_db_credentials' from 'app.vault' (/home/paulo/prj008-shadow-api/app/vault.py)
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nano ~/prj008-shadow-api/app/vault.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/vault.py
import hvac

VAULT_URL = "http://xxx.xxx.xxx.xxx:8200"
TOKEN_PATH = "/var/lib/shadow-api/vault_token"

def get_db_credentials():
    """Recupera as credenciais do MariaDB de forma segura no Vault."""
    try:
        with open(TOKEN_PATH, 'r') as f:
            token = f.read().strip()

        client = hvac.Client(url=VAULT_URL, token=token)

        # Validação de autenticação
        if not client.is_authenticated():
            raise Exception("Token do Vault inválido ou expirado.")

        # Leitura do segredo
        response = client.secrets.kv.v2.read_secret_version(
            path='orangehrm/db_api',
            mount_point='secret'
        )

        return response['data']['data']
    except Exception as e:
        raise Exception(f"Erro ao acessar o Vault: {str(e)}")
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cd ~/prj008-shadow-api
python test_db_real.py
✅ GRC: Infraestrutura de conexão pronta para o host xxx.xxx.xxx.xxx
❌ FALHA NA SPRINT 2: (pymysql.err.OperationalError) (2003, "Can't connect to MySQL server on '2025@xxx.xxx.xxx.xxx' ([Errno -2] Name or service not known)")
(Background on this error at: https://sqlalche.me/e/20/e3q8)
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nano ~/prj008-shadow-api/app/database.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/database.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from app.vault import get_db_credentials

# 1. Recupera credenciais dinamicamente do Vault
try:
    creds = get_db_credentials()

    # Mapeamento conforme seu 'vault kv get' validado
    DB_USER = creds['username']
    DB_PASS = creds['password']
    DB_HOST = creds['db_host']
    DB_NAME = creds['db_name']
    DB_PORT = "3306"

    # 2. String de conexão para o dialeto PyMySQL
    SQLALCHEMY_DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

    print(f"✅ GRC: Infraestrutura de conexão pronta para o host {DB_HOST}")

except KeyError as e:
    raise Exception(f"❌ Erro de Configuração: Chave {str(e)} ausente no segredo do Vault.")

# 3. Configuração do Motor e Sessão
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Dependência de Banco para o FastAPI
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from app.vault import get_db_credentials
import urllib.parse  # <--- NOVA IMPORTAÇÃO

try:
    creds = get_db_credentials()

    DB_USER = creds['username']
    # Aplicamos quote_plus para lidar com o '@' na senha **********
    DB_PASS = urllib.parse.quote_plus(creds['password'])
    DB_HOST = creds['db_host']
    DB_NAME = creds['db_name']
    DB_PORT = "3306"

    # String de conexão segura
    SQLALCHEMY_DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

    print(f"✅ GRC: Infraestrutura de conexão pronta para o host {DB_HOST}")

except KeyError as e:
    raise Exception(f"❌ Erro de Configuração: Chave {str(e)} ausente no Vault.")

# ... resto do arquivo permanece igual
(venv) paulo@api-gf-01:~/prj008-shadow-api$ python test_db_real.py
✅ GRC: Infraestrutura de conexão pronta para o host xxx.xxx.xxx.xxx
✅ GRC: Infraestrutura de conexão pronta para o host xxx.xxx.xxx.xxx
❌ FALHA NA SPRINT 2: (pymysql.err.OperationalError) (2003, "Can't connect to MySQL server on '2025@xxx.xxx.xxx.xxx' ([Errno -2] Name or service not known)")
(Background on this error at: https://sqlalche.me/e/20/e3q8)
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nano ~/prj008-shadow-api/app/database.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/database.py
import urllib.parse
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from app.vault import get_db_credentials

# 1. Recupera credenciais dinamicamente do Vault
try:
    creds = get_db_credentials()

    DB_USER = creds['username']
    # O Pulo do Gato: Codifica a senha ********** para Rosa%402025
    DB_PASS = urllib.parse.quote_plus(creds['password'])
    DB_HOST = creds['db_host']
    DB_NAME = creds['db_name']
    DB_PORT = "3306"

    # 2. String de conexão sanitizada
    SQLALCHEMY_DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

    print(f"✅ GRC: Infraestrutura de conexão pronta para o host {DB_HOST}")

except KeyError as e:
    raise Exception(f"❌ Erro de Configuração: Chave {str(e)} ausente no segredo do Vault.")

# 3. Configuração do Engine e Sessão
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ python test_db_real.py
✅ GRC: Infraestrutura de conexão pronta para o host xxx.xxx.xxx.xxx
🔥 SUCESSO: Conectado ao banco 'orangehrm' via Shadow API!
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ curl -I http://xxx.xxx.xxx.xxx:8200/v1/sys/health
HTTP/1.1 200 OK
Cache-Control: no-store
Content-Type: application/json
Strict-Transport-Security: max-age=31536000; includeSubDomains
Date: Sat, 11 Apr 2026 23:23:18 GMT

(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nc -zv xxx.xxx.xxx.xxx 3306
Connection to xxx.xxx.xxx.xxx 3306 port [tcp/mysql] succeeded!
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nano ~/prj008-shadow-api/app/models.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/models.py
from sqlalchemy import Column, Integer, String
from app.database import Base

class Employee(Base):
    __tablename__ = "hs_hr_employee"

    # No OrangeHRM, a chave primária é o emp_number (interno)
    emp_number = Column(Integer, primary_key=True, index=True)

    # O employee_id é o que costuma ir para o midPoint (ID de Negócio)
    employee_id = Column(String(50), unique=True)

    # Dados de identidade
    first_name = Column("emp_firstname", String(100))
    last_name = Column("emp_lastname", String(100))
    middle_name = Column("emp_middle_name", String(100))

    def __repr__(self):
        return f"<Employee {self.employee_id}: {self.first_name} {self.last_name}>"
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nano ~/prj008-shadow-api/app/main.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/main.py
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models import Employee

app = FastAPI(title="Fiqueok Shadow API", version="0.1.0")

@app.get("/")
def read_root():
    return {"status": "Shadow API is operational", "target": "OrangeHRM"}

@app.get("/employees")
def list_employees(db: Session = Depends(get_db)):
    # Busca os primeiros 5 funcionários para validar
    employees = db.query(Employee).limit(5).all()
    return employees
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cd ~/prj008-shadow-api
# Comando para rodar a API ouvindo em todas as interfaces da VM
uvicorn app.main:app --host 0.0.0.0 --port 8000
✅ GRC: Infraestrutura de conexão pronta para o host xxx.xxx.xxx.xxx
INFO:     Started server process [1794]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     xxx.xxx.xxx.xxx:58202 - "GET /docs HTTP/1.1" 200 OK
INFO:     xxx.xxx.xxx.xxx:58202 - "GET /openapi.json HTTP/1.1" 200 OK
INFO:     xxx.xxx.xxx.xxx:55124 - "GET / HTTP/1.1" 200 OK
INFO:     xxx.xxx.xxx.xxx:62573 - "GET /employees HTTP/1.1" 200 OK
^CINFO:     Shutting down
INFO:     Waiting for application shutdown.
INFO:     Application shutdown complete.
INFO:     Finished server process [1794]
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nano ~/prj008-shadow-api/app/main.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/main.py
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models import Employee

app = FastAPI(title="Fiqueok Shadow API", version="0.1.0")

@app.get("/")
def read_root():
    return {"status": "Shadow API is operational", "target": "OrangeHRM"}

@app.get("/employees")
def list_employees(db: Session = Depends(get_db)):
    # Busca os primeiros 5 funcionários para validar
    employees = db.query(Employee).limit(5).all()
    return employees
# Adicione este endpoint abaixo do list_employees
@app.get("/employees/{emp_id}", response_model=EmployeeSchema)
def get_employee(emp_id: str, db: Session = Depends(get_db)):
    employee = db.query(Employee).filter(Employee.employee_id == emp_id).first()
    if not employee:
        raise HTTPException(status_code=404, detail="Funcionário não encontrado no OrangeHRM")
    return employee1~# Adicione este endpoint abaixo do list_employees
@app.get("/employees/{emp_id}", response_model=EmployeeSchema)
def get_employee(emp_id: str, db: Session = Depends(get_db)):
    employee = db.query(Employee).filter(Employee.employee_id == emp_id).first()
    if not employee:
        raise HTTPException(status_code=404, detail="Funcionário não encontrado no OrangeHRM")
    return employee
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nano ~/prj008-shadow-api/app/main.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/main.py
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models import Employee
from app.schemas import EmployeeSchema # <--- IMPORTANTE: Importar o Schema

app = FastAPI(title="Fiqueok Shadow API", version="0.1.0")

@app.get("/")
def read_root():
    return {"status": "Shadow API is operational", "target": "OrangeHRM"}

@app.get("/employees", response_model=List[EmployeeSchema])
def list_employees(db: Session = Depends(get_db)):
    # Agora listamos todos, mas formatados pelo Schema
    employees = db.query(Employee).all()
    return employees

@app.get("/employees/{emp_id}", response_model=EmployeeSchema)
def get_employee(emp_id: str, db: Session = Depends(get_db)):
    # Busca pelo ID de negócio (ex: 0001)
    employee = db.query(Employee).filter(Employee.employee_id == emp_id).first()
    if not employee:
        raise HTTPException(status_code=404, detail="Funcionário não encontrado no OrangeHRM")
    return employee
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nano ~/prj008-shadow-api/app/vault.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/vault.py
import hvac

VAULT_URL = "http://xxx.xxx.xxx.xxx:8200"
TOKEN_PATH = "/var/lib/shadow-api/vault_token"

def get_db_credentials():
    """Recupera as credenciais do MariaDB de forma segura no Vault."""
    try:
        with open(TOKEN_PATH, 'r') as f:
            token = f.read().strip()

        client = hvac.Client(url=VAULT_URL, token=token)

        # Validação de autenticação
        if not client.is_authenticated():
            raise Exception("Token do Vault inválido ou expirado.")

        # Leitura do segredo
        response = client.secrets.kv.v2.read_secret_version(
            path='orangehrm/db_api',
            mount_point='secret'
        )

        return response['data']['data']
    except Exception as e:
        raise Exception(f"Erro ao acessar o Vault: {str(e)}")

def get_api_token():
    """Recupera a API Key de autenticação no Vault para proteger os endpoints."""
    try:
        with open(TOKEN_PATH, 'r') as f:
            token = f.read().strip()
        client = hvac.Client(url=VAULT_URL, token=token)

        # Note que o path aqui bate com o que você acabou de colocar na política
        response = client.secrets.kv.v2.read_secret_version(
            path='shadow-api/auth',
            mount_point='secret'
        )
        return response['data']['data']['api_key']
    except Exception as e:
        raise Exception(f"Erro ao buscar API Key de segurança no Vault: {e}")
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/main.py
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models import Employee
from app.schemas import EmployeeSchema # <--- IMPORTANTE: Importar o Schema

app = FastAPI(title="Fiqueok Shadow API", version="0.1.0")

@app.get("/")
def read_root():
    return {"status": "Shadow API is operational", "target": "OrangeHRM"}

@app.get("/employees", response_model=List[EmployeeSchema])
def list_employees(db: Session = Depends(get_db)):
    # Agora listamos todos, mas formatados pelo Schema
    employees = db.query(Employee).all()
    return employees

@app.get("/employees/{emp_id}", response_model=EmployeeSchema)
def get_employee(emp_id: str, db: Session = Depends(get_db)):
    # Busca pelo ID de negócio (ex: 0001)
    employee = db.query(Employee).filter(Employee.employee_id == emp_id).first()
    if not employee:
        raise HTTPException(status_code=404, detail="Funcionário não encontrado no OrangeHRM")
    return employee
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nano ~/prj008-shadow-api/app/main.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/main.py
from fastapi import FastAPI, Depends, HTTPException, Security
from fastapi.security.api_key import APIKeyHeader
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models import Employee
from app.schemas import EmployeeSchema
from app.vault import get_api_token

app = FastAPI(title="Fiqueok Shadow API", version="0.1.0")

# --- Configuração de Segurança (API Key) ---
API_KEY_NAME = "X-API-KEY"
api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=True)

# Recupera a chave do Vault uma única vez na inicialização (mais performático)
try:
    API_KEY_VAL = get_api_token()
except Exception as e:
    # Se não conseguir pegar a chave, a API nem sobe (Fail-safe)
    print(f"❌ ERRO CRÍTICO: Não foi possível carregar a API Key do Vault: {e}")
    raise e

async def validate_api_key(api_key: str = Security(api_key_header)):
    if api_key != API_KEY_VAL:
        raise HTTPException(
            status_code=403,
            detail="Acesso Negado: API Key inválida ou não autorizada."
        )
    return api_key
# ------------------------------------------

@app.get("/")
def read_root():
    return {"status": "Operational", "auth": "Vault-Protected"}

# Aplicamos 'dependencies=[Depends(validate_api_key)]' para proteger as rotas
@app.get("/employees", response_model=List[EmployeeSchema], dependencies=[Depends(validate_api_key)])
def list_employees(db: Session = Depends(get_db)):
    return db.query(Employee).all()

@app.get("/employees/{emp_id}", response_model=EmployeeSchema, dependencies=[Depends(validate_api_key)])
def get_employee(emp_id: str, db: Session = Depends(get_db)):
    employee = db.query(Employee).filter(Employee.employee_id == emp_id).first()
    if not employee:
        raise HTTPException(status_code=404, detail="Funcionário não encontrado")
    return employee
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cd ~/prj008-shadow-api
source venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 8000
✅ GRC: Infraestrutura de conexão pronta para o host xxx.xxx.xxx.xxx
Traceback (most recent call last):
  File "/home/paulo/prj008-shadow-api/venv/bin/uvicorn", line 6, in <module>
    sys.exit(main())
             ^^^^^^
  File "/home/paulo/prj008-shadow-api/venv/lib/python3.12/site-packages/click/core.py", line 1485, in __call__
    return self.main(*args, **kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/paulo/prj008-shadow-api/venv/lib/python3.12/site-packages/click/core.py", line 1406, in main
    rv = self.invoke(ctx)
         ^^^^^^^^^^^^^^^^
  File "/home/paulo/prj008-shadow-api/venv/lib/python3.12/site-packages/click/core.py", line 1269, in invoke
    return ctx.invoke(self.callback, **ctx.params)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/paulo/prj008-shadow-api/venv/lib/python3.12/site-packages/click/core.py", line 824, in invoke
    return callback(*args, **kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/paulo/prj008-shadow-api/venv/lib/python3.12/site-packages/uvicorn/main.py", line 410, in main
    run(
  File "/home/paulo/prj008-shadow-api/venv/lib/python3.12/site-packages/uvicorn/main.py", line 577, in run
    server.run()
  File "/home/paulo/prj008-shadow-api/venv/lib/python3.12/site-packages/uvicorn/server.py", line 65, in run
    return asyncio.run(self.serve(sockets=sockets))
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3.12/asyncio/runners.py", line 194, in run
    return runner.run(main)
           ^^^^^^^^^^^^^^^^
  File "/usr/lib/python3.12/asyncio/runners.py", line 118, in run
    return self._loop.run_until_complete(task)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3.12/asyncio/base_events.py", line 687, in run_until_complete
    return future.result()
           ^^^^^^^^^^^^^^^
  File "/home/paulo/prj008-shadow-api/venv/lib/python3.12/site-packages/uvicorn/server.py", line 69, in serve
    await self._serve(sockets)
  File "/home/paulo/prj008-shadow-api/venv/lib/python3.12/site-packages/uvicorn/server.py", line 76, in _serve
    config.load()
  File "/home/paulo/prj008-shadow-api/venv/lib/python3.12/site-packages/uvicorn/config.py", line 434, in load
    self.loaded_app = import_from_string(self.app)
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/paulo/prj008-shadow-api/venv/lib/python3.12/site-packages/uvicorn/importer.py", line 22, in import_from_string
    raise exc from None
  File "/home/paulo/prj008-shadow-api/venv/lib/python3.12/site-packages/uvicorn/importer.py", line 19, in import_from_string
    module = importlib.import_module(module_str)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3.12/importlib/__init__.py", line 90, in import_module
    return _bootstrap._gcd_import(name[level:], package, level)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "<frozen importlib._bootstrap>", line 1387, in _gcd_import
  File "<frozen importlib._bootstrap>", line 1360, in _find_and_load
  File "<frozen importlib._bootstrap>", line 1331, in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 935, in _load_unlocked
  File "<frozen importlib._bootstrap_external>", line 995, in exec_module
  File "<frozen importlib._bootstrap>", line 488, in _call_with_frames_removed
  File "/home/paulo/prj008-shadow-api/app/main.py", line 7, in <module>
    from app.schemas import EmployeeSchema
ModuleNotFoundError: No module named 'app.schemas'
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nano ~/prj008-shadow-api/app/schemas.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/schemas.py
from pydantic import BaseModel
from typing import Optional

class EmployeeSchema(BaseModel):
    emp_number: int
    employee_id: Optional[str]
    first_name: str
    last_name: str

    class Config:
        # Isso permite que o Pydantic leia os dados do SQLAlchemy (objetos)
        from_attributes = True
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cd ~/prj008-shadow-api
uvicorn app.main:app --host 0.0.0.0 --port 8000
✅ GRC: Infraestrutura de conexão pronta para o host xxx.xxx.xxx.xxx
INFO:     Started server process [1829]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     xxx.xxx.xxx.xxx:54163 - "GET /docs HTTP/1.1" 200 OK
INFO:     xxx.xxx.xxx.xxx:54163 - "GET /openapi.json HTTP/1.1" 200 OK
INFO:     xxx.xxx.xxx.xxx:64128 - "GET /employees HTTP/1.1" 200 OK
^CINFO:     Shutting down
INFO:     Waiting for application shutdown.
INFO:     Application shutdown complete.
INFO:     Finished server process [1829]
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cd ~/prj008-shadow-api
# Remove os scripts que expõem senhas ou bypassam a segurança no terminal
rm smoke_test_vault.py test_db_real.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nano ~/prj008-shadow-api/app/schemas.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/schemas.py
import unicodedata
from pydantic import BaseModel, field_validator
from typing import Optional

class EmployeeSchema(BaseModel):
    emp_number: int
    employee_id: Optional[str] = None
    first_name: str
    last_name: str
    middle_name: Optional[str] = None

    # Validador para normalizar strings para UTF-8 NFC
    @field_validator('first_name', 'last_name', 'middle_name', mode='before')
    @classmethod
    def normalize_unicode(cls, v):
        if isinstance(v, str):
            # Normaliza acentos e caracteres especiais
            return unicodedata.normalize('NFC', v)
        return v

    class Config:
        from_attributes = True
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/main.py
from fastapi import FastAPI, Depends, HTTPException, Security
from fastapi.security.api_key import APIKeyHeader
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models import Employee
from app.schemas import EmployeeSchema
from app.vault import get_api_token

app = FastAPI(title="Fiqueok Shadow API", version="0.1.0")

# --- Configuração de Segurança (API Key) ---
API_KEY_NAME = "X-API-KEY"
api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=True)

# Recupera a chave do Vault uma única vez na inicialização (mais performático)
try:
    API_KEY_VAL = get_api_token()
except Exception as e:
    # Se não conseguir pegar a chave, a API nem sobe (Fail-safe)
    print(f"❌ ERRO CRÍTICO: Não foi possível carregar a API Key do Vault: {e}")
    raise e

async def validate_api_key(api_key: str = Security(api_key_header)):
    if api_key != API_KEY_VAL:
        raise HTTPException(
            status_code=403,
            detail="Acesso Negado: API Key inválida ou não autorizada."
        )
    return api_key
# ------------------------------------------

@app.get("/")
def read_root():
    return {"status": "Operational", "auth": "Vault-Protected"}

# Aplicamos 'dependencies=[Depends(validate_api_key)]' para proteger as rotas
@app.get("/employees", response_model=List[EmployeeSchema], dependencies=[Depends(validate_api_key)])
def list_employees(db: Session = Depends(get_db)):
    return db.query(Employee).all()

@app.get("/employees/{emp_id}", response_model=EmployeeSchema, dependencies=[Depends(validate_api_key)])
def get_employee(emp_id: str, db: Session = Depends(get_db)):
    employee = db.query(Employee).filter(Employee.employee_id == emp_id).first()
    if not employee:
        raise HTTPException(status_code=404, detail="Funcionário não encontrado")
    return employee
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nano ~/prj008-shadow-api/app/main.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/main.py
import logging
from fastapi import FastAPI, Depends, HTTPException, Security
from fastapi.security.api_key import APIKeyHeader
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models import Employee
from app.schemas import EmployeeSchema
from app.vault import get_api_token

# --- Configuração de Logging (Auditoria ISO 27001) ---
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("shadow-api-auditoria")

app = FastAPI(
    title="Fiqueok Shadow API",
    description="Interface de Identidades para Integração com midPoint",
    version="0.1.1"
)

# --- Camada de Segurança (Vault Integration) ---
API_KEY_NAME = "X-API-KEY"
api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=True)

try:
    API_KEY_VAL = get_api_token()
    logger.info("✅ GRC: API Key carregada com sucesso do Vault.")
except Exception as e:
    logger.error(f"❌ ERRO CRÍTICO: Falha ao carregar segredos: {e}")
    raise e

async def validate_api_key(api_key: str = Security(api_key_header)):
    if api_key != API_KEY_VAL:
        logger.warning(f"🚨 TENTATIVA DE ACESSO NÃO AUTORIZADO: API Key inválida.")
        raise HTTPException(
            status_code=403,
            detail="Acesso Negado: API Key inválida ou não autorizada."
        )
    return api_key
# -----------------------------------------------

@app.get("/", tags=["Health"])
def read_root():
    return {"status": "Operational", "auth": "Vault-Protected", "normalization": "UTF-8 NFC"}

@app.get("/employees",
         response_model=List[EmployeeSchema],
         dependencies=[Depends(validate_api_key)],
         response_model_exclude_none=True,
         tags=["Identities"])
def list_employees(db: Session = Depends(get_db)):
    """Retorna a lista de todos os funcionários normalizados."""
    logger.info("🔍 Auditoria: Consulta de lista completa de funcionários realizada.")
    return db.query(Employee).all()

@app.get("/employees/{emp_id}",
         response_model=EmployeeSchema,
         dependencies=[Depends(validate_api_key)],
         response_model_exclude_none=True,
         tags=["Identities"])
def get_employee(emp_id: str, db: Session = Depends(get_db)):
    """Busca um funcionário específico pelo ID de negócio."""
    logger.info(f"🔍 Auditoria: Consulta unitária do funcionário ID: {emp_id}")
    employee = db.query(Employee).filter(Employee.employee_id == emp_id).first()
    if not employee:
        logger.info(f"⚠️ Auditoria: Funcionário ID {emp_id} não localizado.")
        raise HTTPException(status_code=404, detail="Funcionário não encontrado")
    return employee
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ fuser -k 8000/tcp
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cd ~/prj008-shadow-api
source venv/bin/activate
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ uvicorn app.main:app --host 0.0.0.0 --port 8000 --log-level info
✅ GRC: Infraestrutura de conexão pronta para o host xxx.xxx.xxx.xxx
INFO:shadow-api-auditoria:✅ GRC: API Key carregada com sucesso do Vault.
INFO:     Started server process [1954]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     xxx.xxx.xxx.xxx:61292 - "GET /docs HTTP/1.1" 200 OK
INFO:     xxx.xxx.xxx.xxx:61292 - "GET /openapi.json HTTP/1.1" 200 OK
INFO:shadow-api-auditoria:🔍 Auditoria: Consulta de lista completa de funcionários realizada.
INFO:     xxx.xxx.xxx.xxx:53367 - "GET /employees HTTP/1.1" 200 OK
^CINFO:     Shutting down
INFO:     Waiting for application shutdown.
INFO:     Application shutdown complete.
INFO:     Finished server process [1954]
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/schemas.py
import unicodedata
from pydantic import BaseModel, field_validator
from typing import Optional

class EmployeeSchema(BaseModel):
    emp_number: int
    employee_id: Optional[str] = None
    first_name: str
    last_name: str
    middle_name: Optional[str] = None

    # Validador para normalizar strings para UTF-8 NFC
    @field_validator('first_name', 'last_name', 'middle_name', mode='before')
    @classmethod
    def normalize_unicode(cls, v):
        if isinstance(v, str):
            # Normaliza acentos e caracteres especiais
            return unicodedata.normalize('NFC', v)
        return v

    class Config:
        from_attributes = True
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nano ~/prj008-shadow-api/app/schemas.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/schemas.py
import unicodedata
from pydantic import BaseModel, field_validator
from typing import Optional

class EmployeeSchema(BaseModel):
    emp_number: int
    employee_id: Optional[str] = None
    first_name: str
    last_name: str
    middle_name: Optional[str] = None

    # O "Filtro de Qualidade": Analisa os campos antes de gerar o JSON
    @field_validator('first_name', 'last_name', 'middle_name', mode='before')
    @classmethod
    def normalize_and_sanitize(cls, v):
        if isinstance(v, str):
            # 1. Remove espaços em branco inúteis nas pontas
            v = v.strip()
            # 2. Normaliza para UTF-8 NFC (Evita erros de acentuação no midPoint)
            v = unicodedata.normalize('NFC', v)
            # 3. A MÁGICA: Se a string for vazia "", transforma em None
            return v if v != "" else None
        return v

    class Config:
        from_attributes = True
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ fuser -k 8000/tcp
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ source venv/bin/activate
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ uvicorn app.main:app --host 0.0.0.0 --port 8000 --log-level info
✅ GRC: Infraestrutura de conexão pronta para o host xxx.xxx.xxx.xxx
INFO:shadow-api-auditoria:✅ GRC: API Key carregada com sucesso do Vault.
INFO:     Started server process [1968]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:shadow-api-auditoria:🔍 Auditoria: Consulta de lista completa de funcionários realizada.
INFO:     xxx.xxx.xxx.xxx:65231 - "GET /employees HTTP/1.1" 200 OK
^CINFO:     Shutting down
INFO:     Waiting for application shutdown.
INFO:     Application shutdown complete.
INFO:     Finished server process [1968]
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/main.py
import logging
from fastapi import FastAPI, Depends, HTTPException, Security
from fastapi.security.api_key import APIKeyHeader
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models import Employee
from app.schemas import EmployeeSchema
from app.vault import get_api_token

# --- Configuração de Logging (Auditoria ISO 27001) ---
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("shadow-api-auditoria")

app = FastAPI(
    title="Fiqueok Shadow API",
    description="Interface de Identidades para Integração com midPoint",
    version="0.1.1"
)

# --- Camada de Segurança (Vault Integration) ---
API_KEY_NAME = "X-API-KEY"
api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=True)

try:
    API_KEY_VAL = get_api_token()
    logger.info("✅ GRC: API Key carregada com sucesso do Vault.")
except Exception as e:
    logger.error(f"❌ ERRO CRÍTICO: Falha ao carregar segredos: {e}")
    raise e

async def validate_api_key(api_key: str = Security(api_key_header)):
    if api_key != API_KEY_VAL:
        logger.warning(f"🚨 TENTATIVA DE ACESSO NÃO AUTORIZADO: API Key inválida.")
        raise HTTPException(
            status_code=403,
            detail="Acesso Negado: API Key inválida ou não autorizada."
        )
    return api_key
# -----------------------------------------------

@app.get("/", tags=["Health"])
def read_root():
    return {"status": "Operational", "auth": "Vault-Protected", "normalization": "UTF-8 NFC"}

@app.get("/employees",
         response_model=List[EmployeeSchema],
         dependencies=[Depends(validate_api_key)],
         response_model_exclude_none=True,
         tags=["Identities"])
def list_employees(db: Session = Depends(get_db)):
    """Retorna a lista de todos os funcionários normalizados."""
    logger.info("🔍 Auditoria: Consulta de lista completa de funcionários realizada.")
    return db.query(Employee).all()

@app.get("/employees/{emp_id}",
         response_model=EmployeeSchema,
         dependencies=[Depends(validate_api_key)],
         response_model_exclude_none=True,
         tags=["Identities"])
def get_employee(emp_id: str, db: Session = Depends(get_db)):
    """Busca um funcionário específico pelo ID de negócio."""
    logger.info(f"🔍 Auditoria: Consulta unitária do funcionário ID: {emp_id}")
    employee = db.query(Employee).filter(Employee.employee_id == emp_id).first()
    if not employee:
        logger.info(f"⚠️ Auditoria: Funcionário ID {emp_id} não localizado.")
        raise HTTPException(status_code=404, detail="Funcionário não encontrado")
    return employee
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ nano ~/prj008-shadow-api/app/main.py
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ cat ~/prj008-shadow-api/app/main.py
import logging
from fastapi import FastAPI, Depends, HTTPException, Security
from fastapi.security.api_key import APIKeyHeader
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models import Employee
from app.schemas import EmployeeSchema
from app.vault import get_api_token

# --- Auditoria ---
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("shadow-api-auditoria")

app = FastAPI(title="Fiqueok Shadow API", version="0.1.1")

# --- Segurança ---
API_KEY_NAME = "X-API-KEY"
api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=True)
API_KEY_VAL = get_api_token()

async def validate_api_key(api_key: str = Security(api_key_header)):
    if api_key != API_KEY_VAL:
        logger.warning("🚨 Acesso negado: Chave inválida.")
        raise HTTPException(status_code=403, detail="API Key inválida.")
    return api_key

# --- Rotas ---

@app.get("/employees",
         response_model=List[EmployeeSchema],
         dependencies=[Depends(validate_api_key)],
         response_model_exclude_none=True)
def list_employees(db: Session = Depends(get_db)):
    logger.info("🔍 Consulta: Lista completa de funcionários.")
    return db.query(Employee).all()

# CORREÇÃO AQUI: O nome 'emp_id' na URL deve bater com o nome no argumento da função
@app.get("/employees/{emp_id}",
         response_model=EmployeeSchema,
         dependencies=[Depends(validate_api_key)],
         response_model_exclude_none=True)
def get_employee(emp_id: str, db: Session = Depends(get_db)):
    logger.info(f"🔍 Consulta: Buscando funcionário ID: {emp_id}")

    # Busca na coluna employee_id do banco (ex: "0001")
    employee = db.query(Employee).filter(Employee.employee_id == emp_id).first()

    if not employee:
        logger.warning(f"⚠️ Funcionário {emp_id} não encontrado.")
        raise HTTPException(status_code=404, detail="Funcionário não encontrado")

    return employee
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ fuser -k 8000/tcp
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ source venv/bin/activate
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$
(venv) paulo@api-gf-01:~/prj008-shadow-api$ uvicorn app.main:app --host 0.0.0.0 --port 8000 --log-level info
✅ GRC: Infraestrutura de conexão pronta para o host xxx.xxx.xxx.xxx
INFO:     Started server process [1982]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)


INFO:     xxx.xxx.xxx.xxx:54041 - "GET / HTTP/1.1" 404 Not Found
INFO:     xxx.xxx.xxx.xxx:54041 - "GET /favicon.ico HTTP/1.1" 404 Not Found
INFO:     xxx.xxx.xxx.xxx:60128 - "GET /docs HTTP/1.1" 200 OK
INFO:     xxx.xxx.xxx.xxx:60128 - "GET /openapi.json HTTP/1.1" 200 OK
INFO:shadow-api-auditoria:🔍 Consulta: Lista completa de funcionários.
INFO:     xxx.xxx.xxx.xxx:60944 - "GET /employees HTTP/1.1" 200 OK
INFO:shadow-api-auditoria:🔍 Consulta: Buscando funcionário ID: 0001
INFO:     xxx.xxx.xxx.xxx:60140 - "GET /employees/0001 HTTP/1.1" 200 OK
client_loop: send disconnect: Connection reset
PS C:\Windows\System32> ssh paulo@xxx.xxx.xxx.xxx
paulo@xxx.xxx.xxx.xxx's password:
Permission denied, please try again.
paulo@xxx.xxx.xxx.xxx's password:
Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.8.0-107-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue Apr 14 12:33:39 PM UTC 2026

  System load:  0.0                Processes:             112
  Usage of /:   29.9% of 18.53GB   Users logged in:       1
  Memory usage: 26%                IPv4 address for eth0: 192.168.99.64
  Swap usage:   0%

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

38 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


Last login: Sat Apr 11 20:18:47 2026 from xxx.xxx.xxx.xxx
paulo@api-gf-01:~$
paulo@api-gf-01:~$
paulo@api-gf-01:~$ # 1. Verificar existência e permissões do token (Deve ser 600)
ls -la /var/lib/shadow-api/vault_token

# 2. Validar o conteúdo do token (Verificar se não está vazio)
sudo cat /var/lib/shadow-api/vault_token

# 3. Teste de conectividade L7 com o Vault (Verificar se o token é válido)
# Substitua o IP pelo IP do seu vault-gf-01 se for diferente
export VAULT_TOKEN=$(sudo cat /var/lib/shadow-api/vault_token)
curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request GET \
     xxx.xxx.xxx.xxx:8200/v1/secret/data/orangehrm/db_api
-rw------- 1 paulo paulo 96 Apr 11 19:32 /var/lib/shadow-api/vault_token
[sudo] password for paulo:
Sorry, try again.
[sudo] password for paulo:
hvs.CAESINLtw0ByJ1L8VCG7Z_O2yC4wF_goktJsPlbt0RDwIbegGh4KHGh2cy56M1RjWVZNU0JlZ0xsMlRSNEZrZm1WZVE
{"errors":["2 errors occurred:\n\t* permission denied\n\t* invalid token\n\n"]}
paulo@api-gf-01:~$
paulo@api-gf-01:~$
paulo@api-gf-01:~$ # 1. Verificar versão do Python (Requisito: 3.12+)
python3 --version

# 2. Garantir que o venv e pip estão instalados
sudo apt update && sudo apt install -y python3-venv python3-pip

# 3. Validar se o Docker está operacional (Para o deploy final)
sudo docker ps
Python 3.12.3
Get:1 https://download.docker.com/linux/ubuntu noble InRelease [48.5 kB]
Get:2 https://download.docker.com/linux/ubuntu noble/stable amd64 Packages [50.1 kB]
Get:3 https://pkgs.tailscale.com/stable/ubuntu noble InRelease
Get:4 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Hit:5 http://archive.ubuntu.com/ubuntu noble InRelease
Get:6 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Get:7 http://security.ubuntu.com/ubuntu noble-security/main amd64 Packages [1,586 kB]
Get:8 http://archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
Get:9 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages [1,897 kB]
Get:10 http://security.ubuntu.com/ubuntu noble-security/main Translation-en [255 kB]
Get:11 http://security.ubuntu.com/ubuntu noble-security/main amd64 Components [21.5 kB]
Get:12 http://security.ubuntu.com/ubuntu noble-security/main amd64 c-n-f Metadata [10.7 kB]
Get:13 http://security.ubuntu.com/ubuntu noble-security/restricted amd64 Packages [2,775 kB]
Get:14 http://security.ubuntu.com/ubuntu noble-security/restricted Translation-en [646 kB]
Get:15 http://security.ubuntu.com/ubuntu noble-security/restricted amd64 Components [212 B]
Get:16 http://security.ubuntu.com/ubuntu noble-security/universe amd64 Packages [1,170 kB]
Get:17 http://security.ubuntu.com/ubuntu noble-security/universe Translation-en [225 kB]
Get:18 http://security.ubuntu.com/ubuntu noble-security/universe amd64 Components [74.1 kB]
Get:19 http://security.ubuntu.com/ubuntu noble-security/universe amd64 c-n-f Metadata [22.9 kB]
Get:20 http://security.ubuntu.com/ubuntu noble-security/multiverse amd64 Components [208 B]
Get:21 http://archive.ubuntu.com/ubuntu noble-updates/main Translation-en [345 kB]
Get:22 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Components [177 kB]
Get:23 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 c-n-f Metadata [16.9 kB]
Get:24 http://archive.ubuntu.com/ubuntu noble-updates/restricted amd64 Packages [2,946 kB]
Get:25 http://archive.ubuntu.com/ubuntu noble-updates/restricted Translation-en [684 kB]
Get:26 http://archive.ubuntu.com/ubuntu noble-updates/restricted amd64 Components [212 B]
Get:27 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 Packages [1,666 kB]
Get:28 http://archive.ubuntu.com/ubuntu noble-updates/universe Translation-en [323 kB]
Get:29 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 Components [386 kB]
Get:30 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 c-n-f Metadata [34.3 kB]
Get:31 http://archive.ubuntu.com/ubuntu noble-updates/multiverse Translation-en [7,752 B]
Get:32 http://archive.ubuntu.com/ubuntu noble-updates/multiverse amd64 Components [940 B]
Get:33 http://archive.ubuntu.com/ubuntu noble-backports/main amd64 Components [7,380 B]
Get:34 http://archive.ubuntu.com/ubuntu noble-backports/restricted amd64 Components [216 B]
Get:35 http://archive.ubuntu.com/ubuntu noble-backports/universe amd64 Packages [30.7 kB]
Get:36 http://archive.ubuntu.com/ubuntu noble-backports/universe amd64 Components [10.5 kB]
Get:37 http://archive.ubuntu.com/ubuntu noble-backports/universe amd64 c-n-f Metadata [1,484 B]
Get:38 http://archive.ubuntu.com/ubuntu noble-backports/multiverse amd64 Components [212 B]
Fetched 15.8 MB in 3s (4,612 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
51 packages can be upgraded. Run 'apt list --upgradable' to see them.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
python3-venv is already the newest version (3.12.3-0ubuntu2.1).
The following additional packages will be installed:
  binutils binutils-common binutils-x86-64-linux-gnu build-essential bzip2 cpp cpp-13 cpp-13-x86-64-linux-gnu
  cpp-x86-64-linux-gnu dpkg-dev fakeroot g++ g++-13 g++-13-x86-64-linux-gnu g++-x86-64-linux-gnu gcc gcc-13
  gcc-13-base gcc-13-x86-64-linux-gnu gcc-x86-64-linux-gnu javascript-common libalgorithm-diff-perl
  libalgorithm-diff-xs-perl libalgorithm-merge-perl libasan8 libatomic1 libbinutils libcc1-0 libctf-nobfd0 libctf0
  libdpkg-perl libexpat1-dev libfakeroot libfile-fcntllock-perl libgcc-13-dev libgomp1 libgprofng0 libhwasan0 libisl23
  libitm1 libjs-jquery libjs-sphinxdoc libjs-underscore liblsan0 libmpc3 libpython3-dev libpython3.12-dev libquadmath0
  libsframe1 libstdc++-13-dev libtsan2 libubsan1 lto-disabled-list make python3-dev python3-wheel python3.12-dev
  zlib1g-dev
Suggested packages:
  binutils-doc gprofng-gui bzip2-doc cpp-doc gcc-13-locales cpp-13-doc debian-keyring g++-multilib g++-13-multilib
  gcc-13-doc gcc-multilib autoconf automake libtool flex bison gdb gcc-doc gcc-13-multilib gdb-x86-64-linux-gnu
  apache2 | lighttpd | httpd bzr libstdc++-13-doc make-doc
The following NEW packages will be installed:
  binutils binutils-common binutils-x86-64-linux-gnu build-essential bzip2 cpp cpp-13 cpp-13-x86-64-linux-gnu
  cpp-x86-64-linux-gnu dpkg-dev fakeroot g++ g++-13 g++-13-x86-64-linux-gnu g++-x86-64-linux-gnu gcc gcc-13
  gcc-13-base gcc-13-x86-64-linux-gnu gcc-x86-64-linux-gnu javascript-common libalgorithm-diff-perl
  libalgorithm-diff-xs-perl libalgorithm-merge-perl libasan8 libatomic1 libbinutils libcc1-0 libctf-nobfd0 libctf0
  libdpkg-perl libexpat1-dev libfakeroot libfile-fcntllock-perl libgcc-13-dev libgomp1 libgprofng0 libhwasan0 libisl23
  libitm1 libjs-jquery libjs-sphinxdoc libjs-underscore liblsan0 libmpc3 libpython3-dev libpython3.12-dev libquadmath0
  libsframe1 libstdc++-13-dev libtsan2 libubsan1 lto-disabled-list make python3-dev python3-pip python3-wheel
  python3.12-dev zlib1g-dev
0 upgraded, 59 newly installed, 0 to remove and 51 not upgraded.
Need to get 76.1 MB of archives.
After this operation, 270 MB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 binutils-common amd64 2.42-4ubuntu2.10 [240 kB]
Get:2 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libsframe1 amd64 2.42-4ubuntu2.10 [15.7 kB]
Get:3 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libbinutils amd64 2.42-4ubuntu2.10 [577 kB]
Get:4 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libctf-nobfd0 amd64 2.42-4ubuntu2.10 [98.0 kB]
Get:5 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libctf0 amd64 2.42-4ubuntu2.10 [94.5 kB]
Get:6 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libgprofng0 amd64 2.42-4ubuntu2.10 [849 kB]
Get:7 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 binutils-x86-64-linux-gnu amd64 2.42-4ubuntu2.10 [2,463 kB]
Get:8 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 binutils amd64 2.42-4ubuntu2.10 [18.2 kB]
Get:9 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 gcc-13-base amd64 13.3.0-6ubuntu2~24.04.1 [51.6 kB]
Get:10 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libisl23 amd64 0.26-3build1.1 [680 kB]
Get:11 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libmpc3 amd64 1.3.1-1build1.1 [54.6 kB]
Get:12 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 cpp-13-x86-64-linux-gnu amd64 13.3.0-6ubuntu2~24.04.1 [10.7 MB]
Get:13 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 cpp-13 amd64 13.3.0-6ubuntu2~24.04.1 [1,042 B]
Get:14 http://archive.ubuntu.com/ubuntu noble/main amd64 cpp-x86-64-linux-gnu amd64 4:13.2.0-7ubuntu1 [5,326 B]
Get:15 http://archive.ubuntu.com/ubuntu noble/main amd64 cpp amd64 4:13.2.0-7ubuntu1 [22.4 kB]
Get:16 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libcc1-0 amd64 14.2.0-4ubuntu2~24.04.1 [48.0 kB]
Get:17 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libgomp1 amd64 14.2.0-4ubuntu2~24.04.1 [148 kB]
Get:18 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libitm1 amd64 14.2.0-4ubuntu2~24.04.1 [29.7 kB]
Get:19 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libatomic1 amd64 14.2.0-4ubuntu2~24.04.1 [10.5 kB]
Get:20 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libasan8 amd64 14.2.0-4ubuntu2~24.04.1 [3,027 kB]
Get:21 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 liblsan0 amd64 14.2.0-4ubuntu2~24.04.1 [1,322 kB]
Get:22 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libtsan2 amd64 14.2.0-4ubuntu2~24.04.1 [2,772 kB]
Get:23 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libubsan1 amd64 14.2.0-4ubuntu2~24.04.1 [1,184 kB]
Get:24 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libhwasan0 amd64 14.2.0-4ubuntu2~24.04.1 [1,641 kB]
Get:25 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libquadmath0 amd64 14.2.0-4ubuntu2~24.04.1 [153 kB]
Get:26 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libgcc-13-dev amd64 13.3.0-6ubuntu2~24.04.1 [2,681 kB]
Get:27 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 gcc-13-x86-64-linux-gnu amd64 13.3.0-6ubuntu2~24.04.1 [21.1 MB]
Get:28 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 gcc-13 amd64 13.3.0-6ubuntu2~24.04.1 [494 kB]
Get:29 http://archive.ubuntu.com/ubuntu noble/main amd64 gcc-x86-64-linux-gnu amd64 4:13.2.0-7ubuntu1 [1,212 B]
Get:30 http://archive.ubuntu.com/ubuntu noble/main amd64 gcc amd64 4:13.2.0-7ubuntu1 [5,018 B]
Get:31 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libstdc++-13-dev amd64 13.3.0-6ubuntu2~24.04.1 [2,420 kB]
Get:32 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 g++-13-x86-64-linux-gnu amd64 13.3.0-6ubuntu2~24.04.1 [12.2 MB]
Get:33 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 g++-13 amd64 13.3.0-6ubuntu2~24.04.1 [16.0 kB]
Get:34 http://archive.ubuntu.com/ubuntu noble/main amd64 g++-x86-64-linux-gnu amd64 4:13.2.0-7ubuntu1 [964 B]
Get:35 http://archive.ubuntu.com/ubuntu noble/main amd64 g++ amd64 4:13.2.0-7ubuntu1 [1,100 B]
Get:36 http://archive.ubuntu.com/ubuntu noble/main amd64 make amd64 4.3-4.1build2 [180 kB]
Get:37 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libdpkg-perl all 1.22.6ubuntu6.5 [269 kB]
Get:38 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 bzip2 amd64 1.0.8-5.1build0.1 [34.5 kB]
Get:39 http://archive.ubuntu.com/ubuntu noble/main amd64 lto-disabled-list all 47 [12.4 kB]
Get:40 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 dpkg-dev all 1.22.6ubuntu6.5 [1,074 kB]
Get:41 http://archive.ubuntu.com/ubuntu noble/main amd64 build-essential amd64 12.10ubuntu1 [4,928 B]
Get:42 http://archive.ubuntu.com/ubuntu noble/main amd64 libfakeroot amd64 1.33-1 [32.4 kB]
Get:43 http://archive.ubuntu.com/ubuntu noble/main amd64 fakeroot amd64 1.33-1 [67.2 kB]
Get:44 http://archive.ubuntu.com/ubuntu noble/main amd64 javascript-common all 11+nmu1 [5,936 B]
Get:45 http://archive.ubuntu.com/ubuntu noble/main amd64 libalgorithm-diff-perl all 1.201-1 [41.8 kB]
Get:46 http://archive.ubuntu.com/ubuntu noble/main amd64 libalgorithm-diff-xs-perl amd64 0.04-8build3 [11.2 kB]
Get:47 http://archive.ubuntu.com/ubuntu noble/main amd64 libalgorithm-merge-perl all 0.08-5 [11.4 kB]
Get:48 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libexpat1-dev amd64 2.6.1-2ubuntu0.4 [140 kB]
Get:49 http://archive.ubuntu.com/ubuntu noble/main amd64 libfile-fcntllock-perl amd64 0.22-4ubuntu5 [30.7 kB]
Get:50 http://archive.ubuntu.com/ubuntu noble/main amd64 libjs-jquery all 3.6.1+dfsg+~3.5.14-1 [328 kB]
Get:51 http://archive.ubuntu.com/ubuntu noble/main amd64 libjs-underscore all 1.13.4~dfsg+~1.11.4-3 [118 kB]
Get:52 http://archive.ubuntu.com/ubuntu noble/main amd64 libjs-sphinxdoc all 7.2.6-6 [149 kB]
Get:53 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 zlib1g-dev amd64 1:1.3.dfsg-3.1ubuntu2.1 [894 kB]
Get:54 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libpython3.12-dev amd64 3.12.3-1ubuntu0.12 [5,681 kB]
Get:55 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 libpython3-dev amd64 3.12.3-0ubuntu2.1 [10.3 kB]
Get:56 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 python3.12-dev amd64 3.12.3-1ubuntu0.12 [498 kB]
Get:57 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 python3-dev amd64 3.12.3-0ubuntu2.1 [26.7 kB]
Get:58 http://archive.ubuntu.com/ubuntu noble/universe amd64 python3-wheel all 0.42.0-2 [53.1 kB]
Get:59 http://archive.ubuntu.com/ubuntu noble-updates/universe amd64 python3-pip all 24.0+dfsg-1ubuntu1.3 [1,320 kB]
Fetched 76.1 MB in 5s (15.9 MB/s)
Extracting templates from packages: 100%
Selecting previously unselected package binutils-common:amd64.
(Reading database ... 125810 files and directories currently installed.)
Preparing to unpack .../00-binutils-common_2.42-4ubuntu2.10_amd64.deb ...
Unpacking binutils-common:amd64 (2.42-4ubuntu2.10) ...
Selecting previously unselected package libsframe1:amd64.
Preparing to unpack .../01-libsframe1_2.42-4ubuntu2.10_amd64.deb ...
Unpacking libsframe1:amd64 (2.42-4ubuntu2.10) ...
Selecting previously unselected package libbinutils:amd64.
Preparing to unpack .../02-libbinutils_2.42-4ubuntu2.10_amd64.deb ...
Unpacking libbinutils:amd64 (2.42-4ubuntu2.10) ...
Selecting previously unselected package libctf-nobfd0:amd64.
Preparing to unpack .../03-libctf-nobfd0_2.42-4ubuntu2.10_amd64.deb ...
Unpacking libctf-nobfd0:amd64 (2.42-4ubuntu2.10) ...
Selecting previously unselected package libctf0:amd64.
Preparing to unpack .../04-libctf0_2.42-4ubuntu2.10_amd64.deb ...
Unpacking libctf0:amd64 (2.42-4ubuntu2.10) ...
Selecting previously unselected package libgprofng0:amd64.
Preparing to unpack .../05-libgprofng0_2.42-4ubuntu2.10_amd64.deb ...
Unpacking libgprofng0:amd64 (2.42-4ubuntu2.10) ...
Selecting previously unselected package binutils-x86-64-linux-gnu.
Preparing to unpack .../06-binutils-x86-64-linux-gnu_2.42-4ubuntu2.10_amd64.deb ...
Unpacking binutils-x86-64-linux-gnu (2.42-4ubuntu2.10) ...
Selecting previously unselected package binutils.
Preparing to unpack .../07-binutils_2.42-4ubuntu2.10_amd64.deb ...
Unpacking binutils (2.42-4ubuntu2.10) ...
Selecting previously unselected package gcc-13-base:amd64.
Preparing to unpack .../08-gcc-13-base_13.3.0-6ubuntu2~24.04.1_amd64.deb ...
Unpacking gcc-13-base:amd64 (13.3.0-6ubuntu2~24.04.1) ...
Selecting previously unselected package libisl23:amd64.
Preparing to unpack .../09-libisl23_0.26-3build1.1_amd64.deb ...
Unpacking libisl23:amd64 (0.26-3build1.1) ...
Selecting previously unselected package libmpc3:amd64.
Preparing to unpack .../10-libmpc3_1.3.1-1build1.1_amd64.deb ...
Unpacking libmpc3:amd64 (1.3.1-1build1.1) ...
Selecting previously unselected package cpp-13-x86-64-linux-gnu.
Preparing to unpack .../11-cpp-13-x86-64-linux-gnu_13.3.0-6ubuntu2~24.04.1_amd64.deb ...
Unpacking cpp-13-x86-64-linux-gnu (13.3.0-6ubuntu2~24.04.1) ...
Selecting previously unselected package cpp-13.
Preparing to unpack .../12-cpp-13_13.3.0-6ubuntu2~24.04.1_amd64.deb ...
Unpacking cpp-13 (13.3.0-6ubuntu2~24.04.1) ...
Selecting previously unselected package cpp-x86-64-linux-gnu.
Preparing to unpack .../13-cpp-x86-64-linux-gnu_4%3a13.2.0-7ubuntu1_amd64.deb ...
Unpacking cpp-x86-64-linux-gnu (4:13.2.0-7ubuntu1) ...
Selecting previously unselected package cpp.
Preparing to unpack .../14-cpp_4%3a13.2.0-7ubuntu1_amd64.deb ...
Unpacking cpp (4:13.2.0-7ubuntu1) ...
Selecting previously unselected package libcc1-0:amd64.
Preparing to unpack .../15-libcc1-0_14.2.0-4ubuntu2~24.04.1_amd64.deb ...
Unpacking libcc1-0:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Selecting previously unselected package libgomp1:amd64.
Preparing to unpack .../16-libgomp1_14.2.0-4ubuntu2~24.04.1_amd64.deb ...
Unpacking libgomp1:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Selecting previously unselected package libitm1:amd64.
Preparing to unpack .../17-libitm1_14.2.0-4ubuntu2~24.04.1_amd64.deb ...
Unpacking libitm1:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Selecting previously unselected package libatomic1:amd64.
Preparing to unpack .../18-libatomic1_14.2.0-4ubuntu2~24.04.1_amd64.deb ...
Unpacking libatomic1:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Selecting previously unselected package libasan8:amd64.
Preparing to unpack .../19-libasan8_14.2.0-4ubuntu2~24.04.1_amd64.deb ...
Unpacking libasan8:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Selecting previously unselected package liblsan0:amd64.
Preparing to unpack .../20-liblsan0_14.2.0-4ubuntu2~24.04.1_amd64.deb ...
Unpacking liblsan0:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Selecting previously unselected package libtsan2:amd64.
Preparing to unpack .../21-libtsan2_14.2.0-4ubuntu2~24.04.1_amd64.deb ...
Unpacking libtsan2:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Selecting previously unselected package libubsan1:amd64.
Preparing to unpack .../22-libubsan1_14.2.0-4ubuntu2~24.04.1_amd64.deb ...
Unpacking libubsan1:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Selecting previously unselected package libhwasan0:amd64.
Preparing to unpack .../23-libhwasan0_14.2.0-4ubuntu2~24.04.1_amd64.deb ...
Unpacking libhwasan0:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Selecting previously unselected package libquadmath0:amd64.
Preparing to unpack .../24-libquadmath0_14.2.0-4ubuntu2~24.04.1_amd64.deb ...
Unpacking libquadmath0:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Selecting previously unselected package libgcc-13-dev:amd64.
Preparing to unpack .../25-libgcc-13-dev_13.3.0-6ubuntu2~24.04.1_amd64.deb ...
Unpacking libgcc-13-dev:amd64 (13.3.0-6ubuntu2~24.04.1) ...
Selecting previously unselected package gcc-13-x86-64-linux-gnu.
Preparing to unpack .../26-gcc-13-x86-64-linux-gnu_13.3.0-6ubuntu2~24.04.1_amd64.deb ...
Unpacking gcc-13-x86-64-linux-gnu (13.3.0-6ubuntu2~24.04.1) ...
Selecting previously unselected package gcc-13.
Preparing to unpack .../27-gcc-13_13.3.0-6ubuntu2~24.04.1_amd64.deb ...
Unpacking gcc-13 (13.3.0-6ubuntu2~24.04.1) ...
Selecting previously unselected package gcc-x86-64-linux-gnu.
Preparing to unpack .../28-gcc-x86-64-linux-gnu_4%3a13.2.0-7ubuntu1_amd64.deb ...
Unpacking gcc-x86-64-linux-gnu (4:13.2.0-7ubuntu1) ...
Selecting previously unselected package gcc.
Preparing to unpack .../29-gcc_4%3a13.2.0-7ubuntu1_amd64.deb ...
Unpacking gcc (4:13.2.0-7ubuntu1) ...
Selecting previously unselected package libstdc++-13-dev:amd64.
Preparing to unpack .../30-libstdc++-13-dev_13.3.0-6ubuntu2~24.04.1_amd64.deb ...
Unpacking libstdc++-13-dev:amd64 (13.3.0-6ubuntu2~24.04.1) ...
Selecting previously unselected package g++-13-x86-64-linux-gnu.
Preparing to unpack .../31-g++-13-x86-64-linux-gnu_13.3.0-6ubuntu2~24.04.1_amd64.deb ...
Unpacking g++-13-x86-64-linux-gnu (13.3.0-6ubuntu2~24.04.1) ...
Selecting previously unselected package g++-13.
Preparing to unpack .../32-g++-13_13.3.0-6ubuntu2~24.04.1_amd64.deb ...
Unpacking g++-13 (13.3.0-6ubuntu2~24.04.1) ...
Selecting previously unselected package g++-x86-64-linux-gnu.
Preparing to unpack .../33-g++-x86-64-linux-gnu_4%3a13.2.0-7ubuntu1_amd64.deb ...
Unpacking g++-x86-64-linux-gnu (4:13.2.0-7ubuntu1) ...
Selecting previously unselected package g++.
Preparing to unpack .../34-g++_4%3a13.2.0-7ubuntu1_amd64.deb ...
Unpacking g++ (4:13.2.0-7ubuntu1) ...
Selecting previously unselected package make.
Preparing to unpack .../35-make_4.3-4.1build2_amd64.deb ...
Unpacking make (4.3-4.1build2) ...
Selecting previously unselected package libdpkg-perl.
Preparing to unpack .../36-libdpkg-perl_1.22.6ubuntu6.5_all.deb ...
Unpacking libdpkg-perl (1.22.6ubuntu6.5) ...
Selecting previously unselected package bzip2.
Preparing to unpack .../37-bzip2_1.0.8-5.1build0.1_amd64.deb ...
Unpacking bzip2 (1.0.8-5.1build0.1) ...
Selecting previously unselected package lto-disabled-list.
Preparing to unpack .../38-lto-disabled-list_47_all.deb ...
Unpacking lto-disabled-list (47) ...
Selecting previously unselected package dpkg-dev.
Preparing to unpack .../39-dpkg-dev_1.22.6ubuntu6.5_all.deb ...
Unpacking dpkg-dev (1.22.6ubuntu6.5) ...
Selecting previously unselected package build-essential.
Preparing to unpack .../40-build-essential_12.10ubuntu1_amd64.deb ...
Unpacking build-essential (12.10ubuntu1) ...
Selecting previously unselected package libfakeroot:amd64.
Preparing to unpack .../41-libfakeroot_1.33-1_amd64.deb ...
Unpacking libfakeroot:amd64 (1.33-1) ...
Selecting previously unselected package fakeroot.
Preparing to unpack .../42-fakeroot_1.33-1_amd64.deb ...
Unpacking fakeroot (1.33-1) ...
Selecting previously unselected package javascript-common.
Preparing to unpack .../43-javascript-common_11+nmu1_all.deb ...
Unpacking javascript-common (11+nmu1) ...
Selecting previously unselected package libalgorithm-diff-perl.
Preparing to unpack .../44-libalgorithm-diff-perl_1.201-1_all.deb ...
Unpacking libalgorithm-diff-perl (1.201-1) ...
Selecting previously unselected package libalgorithm-diff-xs-perl:amd64.
Preparing to unpack .../45-libalgorithm-diff-xs-perl_0.04-8build3_amd64.deb ...
Unpacking libalgorithm-diff-xs-perl:amd64 (0.04-8build3) ...
Selecting previously unselected package libalgorithm-merge-perl.
Preparing to unpack .../46-libalgorithm-merge-perl_0.08-5_all.deb ...
Unpacking libalgorithm-merge-perl (0.08-5) ...
Selecting previously unselected package libexpat1-dev:amd64.
Preparing to unpack .../47-libexpat1-dev_2.6.1-2ubuntu0.4_amd64.deb ...
Unpacking libexpat1-dev:amd64 (2.6.1-2ubuntu0.4) ...
Selecting previously unselected package libfile-fcntllock-perl.
Preparing to unpack .../48-libfile-fcntllock-perl_0.22-4ubuntu5_amd64.deb ...
Unpacking libfile-fcntllock-perl (0.22-4ubuntu5) ...
Selecting previously unselected package libjs-jquery.
Preparing to unpack .../49-libjs-jquery_3.6.1+dfsg+~3.5.14-1_all.deb ...
Unpacking libjs-jquery (3.6.1+dfsg+~3.5.14-1) ...
Selecting previously unselected package libjs-underscore.
Preparing to unpack .../50-libjs-underscore_1.13.4~dfsg+~1.11.4-3_all.deb ...
Unpacking libjs-underscore (1.13.4~dfsg+~1.11.4-3) ...
Selecting previously unselected package libjs-sphinxdoc.
Preparing to unpack .../51-libjs-sphinxdoc_7.2.6-6_all.deb ...
Unpacking libjs-sphinxdoc (7.2.6-6) ...
Selecting previously unselected package zlib1g-dev:amd64.
Preparing to unpack .../52-zlib1g-dev_1%3a1.3.dfsg-3.1ubuntu2.1_amd64.deb ...
Unpacking zlib1g-dev:amd64 (1:1.3.dfsg-3.1ubuntu2.1) ...
Selecting previously unselected package libpython3.12-dev:amd64.
Preparing to unpack .../53-libpython3.12-dev_3.12.3-1ubuntu0.12_amd64.deb ...
Unpacking libpython3.12-dev:amd64 (3.12.3-1ubuntu0.12) ...
Selecting previously unselected package libpython3-dev:amd64.
Preparing to unpack .../54-libpython3-dev_3.12.3-0ubuntu2.1_amd64.deb ...
Unpacking libpython3-dev:amd64 (3.12.3-0ubuntu2.1) ...
Selecting previously unselected package python3.12-dev.
Preparing to unpack .../55-python3.12-dev_3.12.3-1ubuntu0.12_amd64.deb ...
Unpacking python3.12-dev (3.12.3-1ubuntu0.12) ...
Selecting previously unselected package python3-dev.
Preparing to unpack .../56-python3-dev_3.12.3-0ubuntu2.1_amd64.deb ...
Unpacking python3-dev (3.12.3-0ubuntu2.1) ...
Selecting previously unselected package python3-wheel.
Preparing to unpack .../57-python3-wheel_0.42.0-2_all.deb ...
Unpacking python3-wheel (0.42.0-2) ...
Selecting previously unselected package python3-pip.
Preparing to unpack .../58-python3-pip_24.0+dfsg-1ubuntu1.3_all.deb ...
Unpacking python3-pip (24.0+dfsg-1ubuntu1.3) ...
Setting up javascript-common (11+nmu1) ...
Setting up lto-disabled-list (47) ...
Setting up libfile-fcntllock-perl (0.22-4ubuntu5) ...
Setting up libalgorithm-diff-perl (1.201-1) ...
Setting up binutils-common:amd64 (2.42-4ubuntu2.10) ...
Setting up libctf-nobfd0:amd64 (2.42-4ubuntu2.10) ...
Setting up libgomp1:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Setting up bzip2 (1.0.8-5.1build0.1) ...
Setting up python3-wheel (0.42.0-2) ...
Setting up libsframe1:amd64 (2.42-4ubuntu2.10) ...
Setting up libfakeroot:amd64 (1.33-1) ...
Setting up fakeroot (1.33-1) ...
update-alternatives: using /usr/bin/fakeroot-sysv to provide /usr/bin/fakeroot (fakeroot) in auto mode
Setting up gcc-13-base:amd64 (13.3.0-6ubuntu2~24.04.1) ...
Setting up libexpat1-dev:amd64 (2.6.1-2ubuntu0.4) ...
Setting up make (4.3-4.1build2) ...
Setting up libquadmath0:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Setting up libmpc3:amd64 (1.3.1-1build1.1) ...
Setting up libatomic1:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Setting up python3-pip (24.0+dfsg-1ubuntu1.3) ...
Setting up libdpkg-perl (1.22.6ubuntu6.5) ...
Setting up libubsan1:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Setting up zlib1g-dev:amd64 (1:1.3.dfsg-3.1ubuntu2.1) ...
Setting up libhwasan0:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Setting up libasan8:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Setting up libtsan2:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Setting up libjs-jquery (3.6.1+dfsg+~3.5.14-1) ...
Setting up libbinutils:amd64 (2.42-4ubuntu2.10) ...
Setting up libisl23:amd64 (0.26-3build1.1) ...
Setting up libalgorithm-diff-xs-perl:amd64 (0.04-8build3) ...
Setting up libcc1-0:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Setting up liblsan0:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Setting up libitm1:amd64 (14.2.0-4ubuntu2~24.04.1) ...
Setting up libjs-underscore (1.13.4~dfsg+~1.11.4-3) ...
Setting up libalgorithm-merge-perl (0.08-5) ...
Setting up libctf0:amd64 (2.42-4ubuntu2.10) ...
Setting up cpp-13-x86-64-linux-gnu (13.3.0-6ubuntu2~24.04.1) ...
Setting up libpython3.12-dev:amd64 (3.12.3-1ubuntu0.12) ...
Setting up libgprofng0:amd64 (2.42-4ubuntu2.10) ...
Setting up python3.12-dev (3.12.3-1ubuntu0.12) ...
Setting up libjs-sphinxdoc (7.2.6-6) ...
Setting up libgcc-13-dev:amd64 (13.3.0-6ubuntu2~24.04.1) ...
Setting up libstdc++-13-dev:amd64 (13.3.0-6ubuntu2~24.04.1) ...
Setting up binutils-x86-64-linux-gnu (2.42-4ubuntu2.10) ...
Setting up cpp-x86-64-linux-gnu (4:13.2.0-7ubuntu1) ...
Setting up libpython3-dev:amd64 (3.12.3-0ubuntu2.1) ...
Setting up cpp-13 (13.3.0-6ubuntu2~24.04.1) ...
Setting up gcc-13-x86-64-linux-gnu (13.3.0-6ubuntu2~24.04.1) ...
Setting up binutils (2.42-4ubuntu2.10) ...
Setting up dpkg-dev (1.22.6ubuntu6.5) ...
Setting up python3-dev (3.12.3-0ubuntu2.1) ...
Setting up gcc-13 (13.3.0-6ubuntu2~24.04.1) ...
Setting up cpp (4:13.2.0-7ubuntu1) ...
Setting up g++-13-x86-64-linux-gnu (13.3.0-6ubuntu2~24.04.1) ...
Setting up gcc-x86-64-linux-gnu (4:13.2.0-7ubuntu1) ...
Setting up gcc (4:13.2.0-7ubuntu1) ...
Setting up g++-x86-64-linux-gnu (4:13.2.0-7ubuntu1) ...
Setting up g++-13 (13.3.0-6ubuntu2~24.04.1) ...
Setting up g++ (4:13.2.0-7ubuntu1) ...
update-alternatives: using /usr/bin/g++ to provide /usr/bin/c++ (c++) in auto mode
Setting up build-essential (12.10ubuntu1) ...
Processing triggers for man-db (2.12.0-4build2) ...
Processing triggers for libc-bin (2.39-0ubuntu8.7) ...
Scanning processes...
Scanning linux images...

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
paulo@api-gf-01:~$
paulo@api-gf-01:~$
paulo@api-gf-01:~$
paulo@api-gf-01:~$ # Testar se a porta do banco está aberta no destino
# Substitua pelo IP real do seu MariaDB/OrangeHRM
nc -zv xxx.xxx.xxx.xxx 3306
Connection to xxx.xxx.xxx.xxx 3306 port [tcp/mysql] succeeded!
paulo@api-gf-01:~$
paulo@api-gf-01:~$
paulo@api-gf-01:~$
