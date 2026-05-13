

Projeto: PRJ002 - Infraestrutura Fiqueok (Greenfield)

Responsável: Paulo Feitosa (CISO/Architect)

Data de Aprovação: 22/12/2025

Status: Baseline Inicial

Classificação: Confidencial - Uso Interno

---

## 1. Visão Executiva

Esta arquitetura define o padrão para a construção do novo ambiente de laboratório da _Fiqueok Consultoria_. O objetivo é substituir a infraestrutura legada (baseada em VirtualBox) por um ambiente de **Alta Fidelidade** baseado em Microsoft Hyper-V, focado em **Governança de Identidade (IGA)**, **Gestão de Vulnerabilidades** e conformidade com **ISO/IEC 27001**.

O ambiente simula uma rede corporativa segregada ("Corp"), utilizando virtualização de Nível 1 para garantir performance e controles de segurança avançados (TPM, Secure Boot).

## 2. Princípios de Arquitetura

1. **Segurança por Design (ISO 27001 A.14.2.5):** O ambiente nasce segregado da rede doméstica. A comunicação externa é restrita via NAT e o acesso administrativo remoto é protegido por ZTNA (Zero Trust Network Access).
    
2. **Modelo de Camadas (Tier Model):** Segregação estrita de identidades. Administradores de Domínio (Tier 0) nunca logarão em máquinas de usuários comuns (Tier 2) para prevenir roubo de credenciais (Pass-the-Hash).
    
3. **Privilégio Mínimo (PoLP):** Direitos de acesso são concedidos apenas conforme a necessidade da função (RBAC), gerenciados por uma solução de IGA (MidPoint).
    
4. **Imutabilidade e IaC:** Sempre que possível, a infraestrutura é provisionada via script (PowerShell), garantindo reprodutibilidade e recuperação de desastres.
    

## 3. Desenho Lógico de Rede

A rede opera em uma topologia "Hub-and-Spoke" lógica, onde o Host Físico atua como Gateway.

### 3.1. Endereçamento IP (IPv4)

|**Segmento**|**CIDR**|**Função**|**VLAN/Switch**|
|---|---|---|---|
|**Corp Network**|`xxx.xxx.xxx.xxx/24`|Rede Principal (Servidores e Clientes)|`vSwitch_Fiqueok_Corp`|
|**Gateway**|`xxx.xxx.xxx.xxx`|Interface do Host (Hyper-V)|N/A|
|**Services Range**|`.10` - `.50`|IPs Estáticos (Servidores)|N/A|
|**DHCP Scope**|`.100` - `.200`|Estações de Trabalho / Guests|Gerido pelo DC|

### 3.2. Fluxo de Tráfego

- **Saída (Outbound):** VMs -> Gateway (xxx.xxx.xxx.xxx) -> NAT -> Interface Física -> Internet.
    
- **Entrada (Inbound):** Bloqueada por padrão. Não há Port Forwarding direto do roteador doméstico.
    
- **Gestão (OOB):** Acesso via Console Hyper-V (Local) ou Mesh VPN (Tailscale) instalada individualmente nos servidores críticos.
    

## 4. Stack de Servidores (Componentes)

### 4.1. Tier 0 - Identity Core

- **Hostname:** `ID-P-01`
    
- **OS:** Windows Server 2022 Standard (Desktop Exp.)
    
- **Função:** Domain Controller (AD DS), DNS, Root CA (AD CS).
    
- **Hardware Virtual:** 2 vCPU, 4GB RAM (Dyn), 60GB vDisk.
    
- **IP:** `xxx.xxx.xxx.xxx`
    

### 4.2. Tier 1 - Application Servers (Planejado)

- **Hostname:** `SRV-APPS-01`
    
- **OS:** Linux (Ubuntu Server ou Debian)
    
- **Função:** Docker Host.
    
- **Workloads:**
    
    - _MidPoint:_ Governança e Ciclo de Vida de Identidade.
        
    - _Keycloak:_ SSO e Federação (OIDC/SAML).
        
- **IP:** `xxx.xxx.xxx.xxx`
    

### 4.3. Tier 1 - Security Operations (Planejado)

- **Hostname:** `SRV-SEC-01`
    
- **OS:** Linux (Kali ou Greenbone OS)
    
- **Função:** Gestão de Vulnerabilidades.
    
- **Workloads:** OpenVAS / Greenbone Security Manager.
    
- **IP:** `xxx.xxx.xxx.xxx`
    

## 5. Arquitetura de Diretório (AD Design)

A estrutura de Unidades Organizacionais (OUs) foi desenhada para suportar **Delegação Granular** e aplicação de **GPOs** específicas, evitando a "pasta padrão" `Users`.

Namespace DNS: corp.fiqueok.com.br (Split-Brain)

NetBIOS: FIQUEOK

Plaintext

```
DC=corp,DC=fiqueok,DC=com,DC=br
├── 📂 Fiqueok_Corp             (Raiz de Gestão - Bloqueio de Herança GPO aqui)
│   ├── 📂 00_Admins            (Tier 0 - Apenas Domain Admins e Break-glass)
│   ├── 📂 01_Service_Accounts  (Contas de Serviço: svc.midpoint, gMSA)
│   ├── 📂 02_Security_Groups   (RBAC: Subpastas "Roles" e "ACLs")
│   ├── 📂 03_Resources         (Computadores)
│   │    ├── 📂 Servers         (Servidores Membros)
│   │    └── 📂 Workstations    (Windows 10/11)
│   └── 📂 04_People            (Usuários Padrão - Alimentado via IGA)
│        ├── 📂 Security        (Paulo Feitosa - CISO)
│        ├── 📂 Cloud_Infra     (Antonio Figueiredo)
│        ├── 📂 Engineering     (Joao Maia)
│        ├── 📂 Data_Analytics  (Mauro Zimaq)
│        ├── 📂 Innovation_AI   (Wagner Silva)
│        ├── 📂 Customer_Exp    (Fernando Teixeira)
│        └── 📂 Guests
```

## 6. Controles de Conformidade (Mapeamento ISO 27001:2022)

|**Controle**|**Descrição**|**Implementação na Arquitetura**|
|---|---|---|
|**A.13.1**|Gerenciamento de rede|Uso de vSwitch Interno + NAT para segregação lógica.|
|**A.9.2.3**|Gerenciamento de direitos de acesso privilegiado|Uso da OU `00_Admins` e contas separadas (Admin x Usuário).|
|**A.8.9**|Gerenciamento de configuração|Scripts PowerShell para definição de Rede e VM (IaC).|
|**A.8.12**|Prevenção de vazamento de dados|Discos VHDX criptografados (BitLocker no Host).|
|**A.5.15**|Controle de acesso|Modelo Zero Trust via Tailscale (Planejado).|

---

### 📝 Histórico de Revisão

- **v1.0 (22/12/2025):** Emissão inicial. Definição de Rede NAT e VM ID-P-01.
    

---


