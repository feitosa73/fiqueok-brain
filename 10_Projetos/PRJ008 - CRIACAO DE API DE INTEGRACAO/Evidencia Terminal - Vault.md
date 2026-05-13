PowerShell 7.5.5

   A new PowerShell stable release is available: v7.6.0
   Upgrade now, or check out the release page at:
     https://aka.ms/PowerShell-Release?tag=v7.6.0

PS C:\Users\win> paulo ssh@xxx.xxx.xxx.xxx
paulo: The term 'paulo' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
PS C:\Users\win> ssh paulo@xxx.xxx.xxx.xxx
paulo@xxx.xxx.xxx.xxx's password:
Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.8.0-107-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sat Apr 11 07:05:49 PM UTC 2026

  System load:  0.0               Processes:             117
  Usage of /:   55.8% of 9.75GB   Users logged in:       1
  Memory usage: 38%               IPv4 address for eth0: 192.168.102.153
  Swap usage:   0%

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

62 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status

Failed to connect to https://changelogs.ubuntu.com/meta-release-lts. Check your Internet connection or proxy settings


Last login: Fri Apr 10 19:45:14 2026 from xxx.xxx.xxx.xxx
paulo@vault-gf-01:~$ cat <<EOF > api-proxy-policy.hcl
path "secret/data/orangehrm/*" { capabilities = ["read"] }
path "secret/data/api-proxy/*" { capabilities = ["read"] }
EOF
vault policy write api-proxy-policy api-proxy-policy.hcl
WARNING! VAULT_ADDR and -address unset. Defaulting to https://127.0.0.1:8200.
Error uploading policy: Put "https://127.0.0.1:8200/v1/sys/policies/acl/api-proxy-policy": http: server gave HTTP response to HTTPS client
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ # Define o endereço explicitamente com HTTP para evitar o erro de protocolo
export VAULT_ADDR='http://127.0.0.1:8200'

# Tente gravar a política novamente
vault policy write api-proxy-policy api-proxy-policy.hcl
Error uploading policy: Error making API request.

URL: PUT http://127.0.0.1:8200/v1/sys/policies/acl/api-proxy-policy
Code: 503. Errors:

* Vault is sealed
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ vault operator unseal
Unseal Key (will be hidden):
Error unsealing: Error making API request.

URL: PUT http://127.0.0.1:8200/v1/sys/unseal
Code: 400. Errors:

* 'key' must be specified in request body as JSON, or 'reset' set to true
paulo@vault-gf-01:~$ vault operator unseal
Unseal Key (will be hidden):
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  true
Total Shares            5
Threshold               3
Unseal Progress         1/3
Unseal Nonce            4a14f89a-802c-ae87-6336-6e24033a8791
Version                 1.21.3
Build Date              2026-02-03T14:56:30Z
Storage Type            raft
Removed From Cluster    false
HA Enabled              true
paulo@vault-gf-01:~$ vault operator unseal
Unseal Key (will be hidden):
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  true
Total Shares            5
Threshold               3
Unseal Progress         2/3
Unseal Nonce            4a14f89a-802c-ae87-6336-6e24033a8791
Version                 1.21.3
Build Date              2026-02-03T14:56:30Z
Storage Type            raft
Removed From Cluster    false
HA Enabled              true
paulo@vault-gf-01:~$ vault operator unseal
Unseal Key (will be hidden):
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
Total Shares            5
Threshold               3
Version                 1.21.3
Build Date              2026-02-03T14:56:30Z
Storage Type            raft
Cluster Name            vault-cluster-163d0020
Cluster ID              54d3873b-d4ff-233a-22b2-dbe231db4963
Removed From Cluster    false
HA Enabled              true
HA Cluster              n/a
HA Mode                 standby
Active Node Address     <none>
Raft Committed Index    194
Raft Applied Index      194
paulo@vault-gf-01:~$ vault status
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
Total Shares            5
Threshold               3
Version                 1.21.3
Build Date              2026-02-03T14:56:30Z
Storage Type            raft
Cluster Name            vault-cluster-163d0020
Cluster ID              54d3873b-d4ff-233a-22b2-dbe231db4963
Removed From Cluster    false
HA Enabled              true
HA Cluster              https://127.0.0.1:8201
HA Mode                 active
Active Since            2026-04-11T19:08:46.578369192Z
Raft Committed Index    199
Raft Applied Index      199
paulo@vault-gf-01:~$ # Garante a variável no terminal atual
export VAULT_ADDR='http://127.0.0.1:8200'

# Grava a política de acesso da API
vault policy write api-proxy-policy api-proxy-policy.hcl
Success! Uploaded policy: api-proxy-policy
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ # Gera o token de serviço (VLT-04)
vault token create -policy=api-proxy-policy -period=24h -format=json | jq -r .auth.client_token
hvs.CAESINLtw0ByJ1L8VCG7Z_O2yC4wF_goktJsPlbt0RDwIbegGh4KHGh2cy56M1RjWVZNU0JlZ0xsMlRSNEZrZm1WZVE
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ sudo mkdir -p /var/lib/shadow-api echo "hvs.CAESINLtw0ByJ1L8VCG7Z_O2yC4wF_goktJsPlbt0RDwIbegGh4KHGh2cy56M1RjWVZNU0JlZ0xsMlRSNEZrZm1WZVE" | sudo tee /var/lib/shadow-api/vault_token > /dev/null sudo chmod 600 /var/lib/shadow-api/vault_token
[sudo] password for paulo:
tee: /var/lib/shadow-api/vault_token: No such file or directory
tee: /var/lib/shadow-api/vault_token: No such file or directory
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ ifconfig
Command 'ifconfig' not found, but can be installed with:
sudo apt install net-tools
paulo@vault-gf-01:~$ ip addr show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:44:69:15 brd ff:ff:ff:ff:ff:ff
    inet 192.168.102.153/20 metric 100 brd 192.168.111.255 scope global dynamic eth0
       valid_lft 66060sec preferred_lft 66060sec
    inet6 fe80::215:5dff:fe44:6915/64 scope link
       valid_lft forever preferred_lft forever
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ vault status
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
Total Shares            5
Threshold               3
Version                 1.21.3
Build Date              2026-02-03T14:56:30Z
Storage Type            raft
Cluster Name            vault-cluster-163d0020
Cluster ID              54d3873b-d4ff-233a-22b2-dbe231db4963
Removed From Cluster    false
HA Enabled              true
HA Cluster              https://127.0.0.1:8201
HA Mode                 active
Active Since            2026-04-11T19:08:46.578369192Z
Raft Committed Index    214
Raft Applied Index      214
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ # Lista todos os segredos no mount point 'secret'
vault kv list secret/
Keys
----
orangehrm/
prj012/
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ vault kv list secret/orangehrm/
Keys
----
admin
db_api
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$








SPRINT 2 



PowerShell 7.5.5

   A new PowerShell stable release is available: v7.6.0
   Upgrade now, or check out the release page at:
     https://aka.ms/PowerShell-Release?tag=v7.6.0

PS C:\Users\win> paulo ssh@xxx.xxx.xxx.xxx
paulo: The term 'paulo' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
PS C:\Users\win> ssh paulo@xxx.xxx.xxx.xxx
paulo@xxx.xxx.xxx.xxx's password:
Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.8.0-107-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sat Apr 11 07:05:49 PM UTC 2026

  System load:  0.0               Processes:             117
  Usage of /:   55.8% of 9.75GB   Users logged in:       1
  Memory usage: 38%               IPv4 address for eth0: 192.168.102.153
  Swap usage:   0%

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

62 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status

Failed to connect to https://changelogs.ubuntu.com/meta-release-lts. Check your Internet connection or proxy settings


Last login: Fri Apr 10 19:45:14 2026 from xxx.xxx.xxx.xxx
paulo@vault-gf-01:~$ cat <<EOF > api-proxy-policy.hcl
path "secret/data/orangehrm/*" { capabilities = ["read"] }
path "secret/data/api-proxy/*" { capabilities = ["read"] }
EOF
vault policy write api-proxy-policy api-proxy-policy.hcl
WARNING! VAULT_ADDR and -address unset. Defaulting to https://127.0.0.1:8200.
Error uploading policy: Put "https://127.0.0.1:8200/v1/sys/policies/acl/api-proxy-policy": http: server gave HTTP response to HTTPS client
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ # Define o endereço explicitamente com HTTP para evitar o erro de protocolo
export VAULT_ADDR='http://127.0.0.1:8200'

# Tente gravar a política novamente
vault policy write api-proxy-policy api-proxy-policy.hcl
Error uploading policy: Error making API request.

URL: PUT http://127.0.0.1:8200/v1/sys/policies/acl/api-proxy-policy
Code: 503. Errors:

* Vault is sealed
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ vault operator unseal
Unseal Key (will be hidden):
Error unsealing: Error making API request.

URL: PUT http://127.0.0.1:8200/v1/sys/unseal
Code: 400. Errors:

* 'key' must be specified in request body as JSON, or 'reset' set to true
paulo@vault-gf-01:~$ vault operator unseal
Unseal Key (will be hidden):
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  true
Total Shares            5
Threshold               3
Unseal Progress         1/3
Unseal Nonce            4a14f89a-802c-ae87-6336-6e24033a8791
Version                 1.21.3
Build Date              2026-02-03T14:56:30Z
Storage Type            raft
Removed From Cluster    false
HA Enabled              true
paulo@vault-gf-01:~$ vault operator unseal
Unseal Key (will be hidden):
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  true
Total Shares            5
Threshold               3
Unseal Progress         2/3
Unseal Nonce            4a14f89a-802c-ae87-6336-6e24033a8791
Version                 1.21.3
Build Date              2026-02-03T14:56:30Z
Storage Type            raft
Removed From Cluster    false
HA Enabled              true
paulo@vault-gf-01:~$ vault operator unseal
Unseal Key (will be hidden):
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
Total Shares            5
Threshold               3
Version                 1.21.3
Build Date              2026-02-03T14:56:30Z
Storage Type            raft
Cluster Name            vault-cluster-163d0020
Cluster ID              54d3873b-d4ff-233a-22b2-dbe231db4963
Removed From Cluster    false
HA Enabled              true
HA Cluster              n/a
HA Mode                 standby
Active Node Address     <none>
Raft Committed Index    194
Raft Applied Index      194
paulo@vault-gf-01:~$ vault status
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
Total Shares            5
Threshold               3
Version                 1.21.3
Build Date              2026-02-03T14:56:30Z
Storage Type            raft
Cluster Name            vault-cluster-163d0020
Cluster ID              54d3873b-d4ff-233a-22b2-dbe231db4963
Removed From Cluster    false
HA Enabled              true
HA Cluster              https://127.0.0.1:8201
HA Mode                 active
Active Since            2026-04-11T19:08:46.578369192Z
Raft Committed Index    199
Raft Applied Index      199
paulo@vault-gf-01:~$ # Garante a variável no terminal atual
export VAULT_ADDR='http://127.0.0.1:8200'

# Grava a política de acesso da API
vault policy write api-proxy-policy api-proxy-policy.hcl
Success! Uploaded policy: api-proxy-policy
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ # Gera o token de serviço (VLT-04)
vault token create -policy=api-proxy-policy -period=24h -format=json | jq -r .auth.client_token
hvs.CAESINLtw0ByJ1L8VCG7Z_O2yC4wF_goktJsPlbt0RDwIbegGh4KHGh2cy56M1RjWVZNU0JlZ0xsMlRSNEZrZm1WZVE
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ sudo mkdir -p /var/lib/shadow-api echo "hvs.CAESINLtw0ByJ1L8VCG7Z_O2yC4wF_goktJsPlbt0RDwIbegGh4KHGh2cy56M1RjWVZNU0JlZ0xsMlRSNEZrZm1WZVE" | sudo tee /var/lib/shadow-api/vault_token > /dev/null sudo chmod 600 /var/lib/shadow-api/vault_token
[sudo] password for paulo:
tee: /var/lib/shadow-api/vault_token: No such file or directory
tee: /var/lib/shadow-api/vault_token: No such file or directory
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ ifconfig
Command 'ifconfig' not found, but can be installed with:
sudo apt install net-tools
paulo@vault-gf-01:~$ ip addr show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:44:69:15 brd ff:ff:ff:ff:ff:ff
    inet 192.168.102.153/20 metric 100 brd 192.168.111.255 scope global dynamic eth0
       valid_lft 66060sec preferred_lft 66060sec
    inet6 fe80::215:5dff:fe44:6915/64 scope link
       valid_lft forever preferred_lft forever
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ vault status
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
Total Shares            5
Threshold               3
Version                 1.21.3
Build Date              2026-02-03T14:56:30Z
Storage Type            raft
Cluster Name            vault-cluster-163d0020
Cluster ID              54d3873b-d4ff-233a-22b2-dbe231db4963
Removed From Cluster    false
HA Enabled              true
HA Cluster              https://127.0.0.1:8201
HA Mode                 active
Active Since            2026-04-11T19:08:46.578369192Z
Raft Committed Index    214
Raft Applied Index      214
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ # Lista todos os segredos no mount point 'secret'
vault kv list secret/
Keys
----
orangehrm/
prj012/
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ vault kv list secret/orangehrm/
Keys
----
admin
db_api
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ vault kv get secret/orangehrm/db_api
======== Secret Path ========
secret/data/orangehrm/db_api

======= Metadata =======
Key                Value
---                -----
created_time       2026-04-10T23:08:38.538811339Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1

====== Data ======
Key         Value
---         -----
db_host     xxx.xxx.xxx.xxx
db_name     orangehrm
password    **********
username    svc_shadow_api
paulo@vault-gf-01:~$ ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:44:69:15 brd ff:ff:ff:ff:ff:ff
    inet 192.168.102.153/20 metric 100 brd 192.168.111.255 scope global dynamic eth0
       valid_lft 57958sec preferred_lft 57958sec
    inet6 fe80::215:5dff:fe44:6915/64 scope link
       valid_lft forever preferred_lft forever
4: tailscale0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1280 qdisc fq_codel state UNKNOWN group default qlen 500
    link/none
    inet xxx.xxx.xxx.xxx/32 scope global tailscale0
       valid_lft forever preferred_lft forever
    inet6 fd7a:115c:a1e0::ba34:2a5d/128 scope global
       valid_lft forever preferred_lft forever
    inet6 fe80::7044:cc2b:1bf8:c86e/64 scope link stable-privacy
       valid_lft forever preferred_lft forever
paulo@vault-gf-01:~$ ping -c 2 192.168.1.100
ip neigh show | grep 192.168.1.100
PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.

--- 192.168.1.100 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1052ms

paulo@vault-gf-01:~$ sudo nmap -sn 192.168.1.0/24 | grep -i "192.168.1.100"
[sudo] password for paulo:
sudo: nmap: command not found
paulo@vault-gf-01:~$




SPRINT 3


PowerShell 7.5.5

   A new PowerShell stable release is available: v7.6.0
   Upgrade now, or check out the release page at:
     https://aka.ms/PowerShell-Release?tag=v7.6.0

PS C:\Users\win> paulo ssh@xxx.xxx.xxx.xxx
paulo: The term 'paulo' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
PS C:\Users\win> ssh paulo@xxx.xxx.xxx.xxx
paulo@xxx.xxx.xxx.xxx's password:
Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.8.0-107-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sat Apr 11 07:05:49 PM UTC 2026

  System load:  0.0               Processes:             117
  Usage of /:   55.8% of 9.75GB   Users logged in:       1
  Memory usage: 38%               IPv4 address for eth0: 192.168.102.153
  Swap usage:   0%

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

62 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status

Failed to connect to https://changelogs.ubuntu.com/meta-release-lts. Check your Internet connection or proxy settings


Last login: Fri Apr 10 19:45:14 2026 from xxx.xxx.xxx.xxx
paulo@vault-gf-01:~$ cat <<EOF > api-proxy-policy.hcl
path "secret/data/orangehrm/*" { capabilities = ["read"] }
path "secret/data/api-proxy/*" { capabilities = ["read"] }
EOF
vault policy write api-proxy-policy api-proxy-policy.hcl
WARNING! VAULT_ADDR and -address unset. Defaulting to https://127.0.0.1:8200.
Error uploading policy: Put "https://127.0.0.1:8200/v1/sys/policies/acl/api-proxy-policy": http: server gave HTTP response to HTTPS client
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ # Define o endereço explicitamente com HTTP para evitar o erro de protocolo
export VAULT_ADDR='http://127.0.0.1:8200'

# Tente gravar a política novamente
vault policy write api-proxy-policy api-proxy-policy.hcl
Error uploading policy: Error making API request.

URL: PUT http://127.0.0.1:8200/v1/sys/policies/acl/api-proxy-policy
Code: 503. Errors:

* Vault is sealed
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ vault operator unseal
Unseal Key (will be hidden):
Error unsealing: Error making API request.

URL: PUT http://127.0.0.1:8200/v1/sys/unseal
Code: 400. Errors:

* 'key' must be specified in request body as JSON, or 'reset' set to true
paulo@vault-gf-01:~$ vault operator unseal
Unseal Key (will be hidden):
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  true
Total Shares            5
Threshold               3
Unseal Progress         1/3
Unseal Nonce            4a14f89a-802c-ae87-6336-6e24033a8791
Version                 1.21.3
Build Date              2026-02-03T14:56:30Z
Storage Type            raft
Removed From Cluster    false
HA Enabled              true
paulo@vault-gf-01:~$ vault operator unseal
Unseal Key (will be hidden):
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  true
Total Shares            5
Threshold               3
Unseal Progress         2/3
Unseal Nonce            4a14f89a-802c-ae87-6336-6e24033a8791
Version                 1.21.3
Build Date              2026-02-03T14:56:30Z
Storage Type            raft
Removed From Cluster    false
HA Enabled              true
paulo@vault-gf-01:~$ vault operator unseal
Unseal Key (will be hidden):
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
Total Shares            5
Threshold               3
Version                 1.21.3
Build Date              2026-02-03T14:56:30Z
Storage Type            raft
Cluster Name            vault-cluster-163d0020
Cluster ID              54d3873b-d4ff-233a-22b2-dbe231db4963
Removed From Cluster    false
HA Enabled              true
HA Cluster              n/a
HA Mode                 standby
Active Node Address     <none>
Raft Committed Index    194
Raft Applied Index      194
paulo@vault-gf-01:~$ vault status
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
Total Shares            5
Threshold               3
Version                 1.21.3
Build Date              2026-02-03T14:56:30Z
Storage Type            raft
Cluster Name            vault-cluster-163d0020
Cluster ID              54d3873b-d4ff-233a-22b2-dbe231db4963
Removed From Cluster    false
HA Enabled              true
HA Cluster              https://127.0.0.1:8201
HA Mode                 active
Active Since            2026-04-11T19:08:46.578369192Z
Raft Committed Index    199
Raft Applied Index      199
paulo@vault-gf-01:~$ # Garante a variável no terminal atual
export VAULT_ADDR='http://127.0.0.1:8200'

# Grava a política de acesso da API
vault policy write api-proxy-policy api-proxy-policy.hcl
Success! Uploaded policy: api-proxy-policy
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ # Gera o token de serviço (VLT-04)
vault token create -policy=api-proxy-policy -period=24h -format=json | jq -r .auth.client_token
hvs.CAESINLtw0ByJ1L8VCG7Z_O2yC4wF_goktJsPlbt0RDwIbegGh4KHGh2cy56M1RjWVZNU0JlZ0xsMlRSNEZrZm1WZVE
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ sudo mkdir -p /var/lib/shadow-api echo "hvs.CAESINLtw0ByJ1L8VCG7Z_O2yC4wF_goktJsPlbt0RDwIbegGh4KHGh2cy56M1RjWVZNU0JlZ0xsMlRSNEZrZm1WZVE" | sudo tee /var/lib/shadow-api/vault_token > /dev/null sudo chmod 600 /var/lib/shadow-api/vault_token
[sudo] password for paulo:
tee: /var/lib/shadow-api/vault_token: No such file or directory
tee: /var/lib/shadow-api/vault_token: No such file or directory
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ ifconfig
Command 'ifconfig' not found, but can be installed with:
sudo apt install net-tools
paulo@vault-gf-01:~$ ip addr show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:44:69:15 brd ff:ff:ff:ff:ff:ff
    inet 192.168.102.153/20 metric 100 brd 192.168.111.255 scope global dynamic eth0
       valid_lft 66060sec preferred_lft 66060sec
    inet6 fe80::215:5dff:fe44:6915/64 scope link
       valid_lft forever preferred_lft forever
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ vault status
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
Total Shares            5
Threshold               3
Version                 1.21.3
Build Date              2026-02-03T14:56:30Z
Storage Type            raft
Cluster Name            vault-cluster-163d0020
Cluster ID              54d3873b-d4ff-233a-22b2-dbe231db4963
Removed From Cluster    false
HA Enabled              true
HA Cluster              https://127.0.0.1:8201
HA Mode                 active
Active Since            2026-04-11T19:08:46.578369192Z
Raft Committed Index    214
Raft Applied Index      214
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ # Lista todos os segredos no mount point 'secret'
vault kv list secret/
Keys
----
orangehrm/
prj012/
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ vault kv list secret/orangehrm/
Keys
----
admin
db_api
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ vault kv get secret/orangehrm/db_api
======== Secret Path ========
secret/data/orangehrm/db_api

======= Metadata =======
Key                Value
---                -----
created_time       2026-04-10T23:08:38.538811339Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1

====== Data ======
Key         Value
---         -----
db_host     xxx.xxx.xxx.xxx
db_name     orangehrm
password    **********
username    svc_shadow_api
paulo@vault-gf-01:~$ ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:44:69:15 brd ff:ff:ff:ff:ff:ff
    inet 192.168.102.153/20 metric 100 brd 192.168.111.255 scope global dynamic eth0
       valid_lft 57958sec preferred_lft 57958sec
    inet6 fe80::215:5dff:fe44:6915/64 scope link
       valid_lft forever preferred_lft forever
4: tailscale0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1280 qdisc fq_codel state UNKNOWN group default qlen 500
    link/none
    inet xxx.xxx.xxx.xxx/32 scope global tailscale0
       valid_lft forever preferred_lft forever
    inet6 fd7a:115c:a1e0::ba34:2a5d/128 scope global
       valid_lft forever preferred_lft forever
    inet6 fe80::7044:cc2b:1bf8:c86e/64 scope link stable-privacy
       valid_lft forever preferred_lft forever
paulo@vault-gf-01:~$ ping -c 2 192.168.1.100
ip neigh show | grep 192.168.1.100
PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.

--- 192.168.1.100 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1052ms

paulo@vault-gf-01:~$ sudo nmap -sn 192.168.1.0/24 | grep -i "192.168.1.100"
[sudo] password for paulo:
sudo: nmap: command not found
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ # Gere uma chave (ex: shadow-secret-2026) e salve no path da API
vault kv put secret/shadow-api/auth api_key="Fiqueok-Security-Token-2026"
======= Secret Path =======
secret/data/shadow-api/auth

======= Metadata =======
Key                Value
---                -----
created_time       2026-04-11T23:44:00.262384612Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ ls
 600                    hvs.CAESINLtw0ByJ1L8VCG7Z_O2yC4wF_goktJsPlbt0RDwIbegGh4KHGh2cy56M1RjWVZNU0JlZ0xsMlRSNEZrZm1WZVE
 api-proxy-policy.hcl   role-prj009.json
 chmod                  sudo
 colaborador-ssh.hcl   ':USERPROFILE\.ssh\id_rsa_vault'
 echo                  ':USERPROFILE\.ssh\id_rsa_vault.pub'
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ cat api-proxy-policy.hcl
path "secret/data/orangehrm/*" { capabilities = ["read"] }
path "secret/data/api-proxy/*" { capabilities = ["read"] }
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ cat <<EOF > api-proxy-policy.hcl
# Permissão para as credenciais do DB (Sprint 2)
path "secret/data/orangehrm/*" {
  capabilities = ["read"]
}

# Permissão para a API Key de segurança (Sprint 4)
path "secret/data/shadow-api/auth" {
  capabilities = ["read"]
}
EOF
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ cat api-proxy-policy.hcl
# Permissão para as credenciais do DB (Sprint 2)
path "secret/data/orangehrm/*" {
  capabilities = ["read"]
}

# Permissão para a API Key de segurança (Sprint 4)
path "secret/data/shadow-api/auth" {
  capabilities = ["read"]
}
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ vault policy write api-proxy-policy api-proxy-policy.hcl
Success! Uploaded policy: api-proxy-policy
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ vault kv get secret/orangehrm/db_api
======== Secret Path ========
secret/data/orangehrm/db_api

======= Metadata =======
Key                Value
---                -----
created_time       2026-04-10T23:08:38.538811339Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1

====== Data ======
Key         Value
---         -----
db_host     xxx.xxx.xxx.xxx
db_name     orangehrm
password    **********
username    svc_shadow_api
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$ vault kv get secret/orangehrm/mysql
No value found at secret/data/orangehrm/mysql
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$
paulo@vault-gf-01:~$



