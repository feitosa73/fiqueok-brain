
# 
Cold Start da Infraestrutura IAM (PRJ003)

## Contexto
Este documento consolida as evidÃªncias tÃ©cnicas da GMUD-004, cujo objetivo
foi realizar o cold start da infraestrutura IGA em ambiente Greenfield,
sem qualquer integraÃ§Ã£o funcional ou ingestÃ£o de identidades.

## 1. Acesso Remoto SSH

ssh paulo@<LAB_VM_IP>

### Resultado

ConexÃ£o estabelecida com sucesso.  
Sistema Ubuntu 24.04.3 LTS acessÃ­vel remotamente.

---

## 2. InstalaÃ§Ã£o do Docker

### VerificaÃ§Ã£o de versÃµes

`docker --version docker compose version`

### Resultado

- Docker Engine: 29.1.4
    
- Docker Compose Plugin: v5.0.1
    

---

## 3. Estado do Runtime

### VerificaÃ§Ã£o de containers

`docker ps`

### Resultado

Nenhum container em execuÃ§Ã£o.  
Ambiente mantido em estado virgem.

---

## 4. Controle de Acesso ao Docker

`sudo usermod -aG docker paulo`

SessÃ£o reiniciada com sucesso.  
ExecuÃ§Ã£o de comandos Docker sem necessidade de sudo confirmada.

---

## ConclusÃ£o

As evidÃªncias acima comprovam que a infraestrutura base do ambiente IGA  
foi inicializada com sucesso, mantendo o escopo estritamente limitado  
ao cold start, conforme definido na GMUD-004.

---

## 1. Acesso Remoto (SSH)

### Comando executado (Host â†’ VM)
```bash
ssh paulo@<LAB_VM_IP>




O Windows PowerShell
Copyright (C) Microsoft Corporation. Todos os direitos reservados.

Instale o PowerShell mais recente para obter novos recursos e aprimoramentos! https://aka.ms/PSWindows

PS C:\WINDOWS\system32> Get-ChildItem -Path C:\ -Recurse -Filter "*ubuntu*.iso" -ErrorAction SilentlyContinue


    DiretÃ³rio: C:\Users\fiqueok\Downloads


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        12/23/2025   3:27 PM     3303444480 ubuntu-24.04.3-live-server-amd64.iso


PS C:\WINDOWS\system32> ssh paulo@<LAB_VM_IP>
The authenticity of host '<LAB_VM_IP> (<LAB_VM_IP>)' can't be established.
ED25519 key fingerprint is SHA256:<REDACTED_SECRET>VNI.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '<LAB_VM_IP>' (ED25519) to the list of known hosts.

Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.8.0-90-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Wed Jan 14 09:33:37 PM UTC 2026

  System load:  0.0                Processes:             139
  Usage of /:   16.5% of 27.86GB   Users logged in:       1
  Memory usage: 43%                IPv4 address for eth0: <LAB_VM_IP>
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


paulo@iga-gf-01:~$ sudo apt remove -y docker docker-engine docker.io containerd runc

Sorry, try again.

Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Package 'docker' is not installed, so not removed
E: Unable to locate package docker-engine
paulo@iga-gf-01:~$ sudo apt update
sudo apt install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release
Hit:1 http://security.ubuntu.com/ubuntu noble-security InRelease
Hit:2 http://archive.ubuntu.com/ubuntu noble InRelease
Hit:3 http://archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:4 http://archive.ubuntu.com/ubuntu noble-backports InRelease
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
All packages are up to date.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
ca-certificates is already the newest version (20240203).
ca-certificates set to manually installed.
curl is already the newest version (8.5.0-2ubuntu10.6).
curl set to manually installed.
gnupg is already the newest version (2.4.4-2ubuntu17.4).
gnupg set to manually installed.
lsb-release is already the newest version (12.0-2).
lsb-release set to manually installed.
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
paulo@iga-gf-01:~$ sudo install -m 0755 -d /etc/apt/keyrings
paulo@iga-gf-01:~$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
paulo@iga-gf-01:~$ sudo chmod a+r /etc/apt/keyrings/docker.gpg
paulo@iga-gf-01:~$ echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
paulo@iga-gf-01:~$ sudo apt update
sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin
Get:1 https://download.docker.com/linux/ubuntu noble InRelease [48.5 kB]
Get:2 https://download.docker.com/linux/ubuntu noble/stable amd64 Packages [42.0 kB]
Hit:3 http://archive.ubuntu.com/ubuntu noble InRelease
Hit:4 http://archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:5 http://security.ubuntu.com/ubuntu noble-security InRelease
Hit:6 http://archive.ubuntu.com/ubuntu noble-backports InRelease
Fetched 90.4 kB in 1s (99.9 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
All packages are up to date.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  docker-ce-rootless-extras libslirp0 pigz slirp4netns
Suggested packages:
  cgroupfs-mount | cgroup-lite docker-model-plugin
The following NEW packages will be installed:
  containerd.io docker-buildx-plugin docker-ce docker-ce-cli docker-ce-rootless-extras docker-compose-plugin libslirp0
  pigz slirp4netns
0 upgraded, 9 newly installed, 0 to remove and 0 not upgraded.
Need to get 91.3 MB of archives.
After this operation, 364 MB of additional disk space will be used.
Get:1 https://download.docker.com/linux/ubuntu noble/stable amd64 containerd.io amd64 2.2.1-1~ubuntu.24.04~noble [23.4 MB]
Get:2 http://archive.ubuntu.com/ubuntu noble/universe amd64 pigz amd64 2.8-1 [65.6 kB]
Get:3 https://download.docker.com/linux/ubuntu noble/stable amd64 docker-ce-cli amd64 5:29.1.4-1~ubuntu.24.04~noble [16.3 MB]
Get:4 https://download.docker.com/linux/ubuntu noble/stable amd64 docker-ce amd64 5:29.1.4-1~ubuntu.24.04~noble [21.0 MB]
Get:5 https://download.docker.com/linux/ubuntu noble/stable amd64 docker-buildx-plugin amd64 0.30.1-1~ubuntu.24.04~noble [16.4 MB]
Get:6 http://archive.ubuntu.com/ubuntu noble/main amd64 libslirp0 amd64 4.7.0-1ubuntu3 [63.8 kB]
Get:7 http://archive.ubuntu.com/ubuntu noble/universe amd64 slirp4netns amd64 1.2.1-1build2 [34.9 kB]
Get:8 https://download.docker.com/linux/ubuntu noble/stable amd64 docker-ce-rootless-extras amd64 5:29.1.4-1~ubuntu.24.04~noble [6,383 kB]
Get:9 https://download.docker.com/linux/ubuntu noble/stable amd64 docker-compose-plugin amd64 5.0.1-1~ubuntu.24.04~noble [7,713 kB]
Fetched 91.3 MB in 4s (22.0 MB/s)
Selecting previously unselected package containerd.io.
(Reading database ... 87460 files and directories currently installed.)
Preparing to unpack .../0-containerd.io_2.2.1-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking containerd.io (2.2.1-1~ubuntu.24.04~noble) ...
Selecting previously unselected package docker-ce-cli.
Preparing to unpack .../1-docker-ce-cli_5%3a29.1.4-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking docker-ce-cli (5:29.1.4-1~ubuntu.24.04~noble) ...
Selecting previously unselected package docker-ce.
Preparing to unpack .../2-docker-ce_5%3a29.1.4-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking docker-ce (5:29.1.4-1~ubuntu.24.04~noble) ...
Selecting previously unselected package pigz.
Preparing to unpack .../3-pigz_2.8-1_amd64.deb ...
Unpacking pigz (2.8-1) ...
Selecting previously unselected package docker-buildx-plugin.
Preparing to unpack .../4-docker-buildx-plugin_0.30.1-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking docker-buildx-plugin (0.30.1-1~ubuntu.24.04~noble) ...
Selecting previously unselected package docker-ce-rootless-extras.
Preparing to unpack .../5-docker-ce-rootless-extras_5%3a29.1.4-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking docker-ce-rootless-extras (5:29.1.4-1~ubuntu.24.04~noble) ...
Selecting previously unselected package docker-compose-plugin.
Preparing to unpack .../6-docker-compose-plugin_5.0.1-1~ubuntu.24.04~noble_amd64.deb ...
Unpacking docker-compose-plugin (5.0.1-1~ubuntu.24.04~noble) ...
Selecting previously unselected package libslirp0:amd64.
Preparing to unpack .../7-libslirp0_4.7.0-1ubuntu3_amd64.deb ...
Unpacking libslirp0:amd64 (4.7.0-1ubuntu3) ...
Selecting previously unselected package slirp4netns.
Preparing to unpack .../8-slirp4netns_1.2.1-1build2_amd64.deb ...
Unpacking slirp4netns (1.2.1-1build2) ...
Setting up docker-buildx-plugin (0.30.1-1~ubuntu.24.04~noble) ...
Setting up containerd.io (2.2.1-1~ubuntu.24.04~noble) ...
Created symlink /etc/systemd/system/multi-user.target.wants/containerd.service â†’ /usr/lib/systemd/system/containerd.service.
Setting up docker-compose-plugin (5.0.1-1~ubuntu.24.04~noble) ...
Setting up docker-ce-cli (5:29.1.4-1~ubuntu.24.04~noble) ...
Setting up libslirp0:amd64 (4.7.0-1ubuntu3) ...
Setting up pigz (2.8-1) ...
Setting up docker-ce-rootless-extras (5:29.1.4-1~ubuntu.24.04~noble) ...
Setting up slirp4netns (1.2.1-1build2) ...
Setting up docker-ce (5:29.1.4-1~ubuntu.24.04~noble) ...
Created symlink /etc/systemd/system/multi-user.target.wants/docker.service â†’ /usr/lib/systemd/system/docker.service.
Created symlink /etc/systemd/system/sockets.target.wants/docker.socket â†’ /usr/lib/systemd/system/docker.socket.
Processing triggers for man-db (2.12.0-4build2) ...
Processing triggers for libc-bin (2.39-0ubuntu8.6) ...
Scanning processes...
Scanning candidates...
Scanning linux images...

Running kernel seems to be up-to-date.

Restarting services...

Service restarts being deferred:
 /etc/needrestart/restart.d/dbus.service
 systemctl restart systemd-logind.service
 systemctl restart unattended-upgrades.service

No containers need to be restarted.

User sessions running outdated binaries:
 paulo @ session #1: login[924]
 paulo @ user manager service: systemd[1044]

No VM guests are running outdated hypervisor (qemu) binaries on this host.
paulo@iga-gf-01:~$ docker --version
docker compose version
Docker version 29.1.4, build 0e6fee6
Docker Compose version v5.0.1
paulo@iga-gf-01:~$ sudo usermod -aG docker paulo
paulo@iga-gf-01:~$ exit
logout
Connection to <LAB_VM_IP> closed.
PS C:\WINDOWS\system32> ssh paulo@<LAB_VM_IP>
paulo@<LAB_VM_IP>'s password:
Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.8.0-90-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Wed Jan 14 09:37:12 PM UTC 2026

  System load:  0.13               Processes:             145
  Usage of /:   17.7% of 27.86GB   Users logged in:       1
  Memory usage: 28%                IPv4 address for eth0: <LAB_VM_IP>
  Swap usage:   1%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


Last login: Wed Jan 14 21:33:38 2026 from xxx.xxx.xxx.xxx
paulo@iga-gf-01:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
paulo@iga-gf-01:~$

