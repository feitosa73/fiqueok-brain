Markdown

````
# 🏗️ 

> **Doc ID:** ARQ-LAB-001
> **Versão:** 1.0
> **Status:** Ativo (Legacy)
> **Data de Revisão:** 16/12/2025
> **Classificação:** Interno

---

## 1. Topologia Lógica (Diagrama)

```mermaid
graph TD
    subgraph Host_Fisico [Desktop Alta Performance]
        Docker[Docker Desktop / WSL2]
        VirtualBox[Hypervisor VirtualBox]
        
        subgraph Container_Stack [Stack de Gestão GRC - Perfil Fiqueok]
            DD[DefectDojo]
            OV[OpenVAS Scanner]
        end
        
        subgraph Virtual_Net [Rede Virtualizada]
            subgraph Rede_NAT [NAT Network - 10.0.2.0/24]
                Win11[Win11 - Lab Apps]
                Win7[Win7 - Legado]
                LinuxGW_ETH0[LinuxLite ETH0 - WAN]
            end
            
            subgraph Rede_Interna [LAB_NET - 192.168.10.0/24]
                LinuxGW_ETH1[LinuxLite ETH1 - LAN]
                DC01[DC01 - Active Directory]
                Win10[Win10 - Corp]
            end
            
            subgraph Rede_HostOnly [Host Only - 192.168.56.0/24]
                Meta[Metasploitable]
            end
        end
    end

    Docker -->|Reside no Host| Host_Fisico
    VirtualBox -->|Reside no Host| Host_Fisico
    LinuxGW_ETH0 <--> LinuxGW_ETH1
    LinuxGW_ETH1 <--> DC01
    DC01 <--> Win10
````

---

## 2. Especificações Técnicas dos Ativos

### 2.1 Camada de Virtualização (Infraestrutura)

- **Hypervisor:** Oracle VirtualBox 7.x
    
- **Rede de Gerência:** Inexistente nesta versão (Gestão via console ou RDP direto via NAT/Port Forwarding).
    

### 2.2 Inventário de Máquinas Virtuais (Workloads)

|**Hostname**|**Função**|**SO**|**vCPU**|**RAM**|**Rede Configurada**|
|---|---|---|---|---|---|
|**LinuxLite**|Gateway / Proxy|Linux Lite 6.x|1|2GB|Adaptador 1: NAT<br><br>  <br><br>Adaptador 2: Internal (`LAB_NET`)|
|**DC01**|Domain Controller|Win Server 2022|2|4GB|Adaptador 1: Internal (`LAB_NET`)|
|**Win10-Corp**|Estação Cliente|Windows 10 Pro|2|4GB|Adaptador 1: Internal (`LAB_NET`)|
|**Win11-Lab**|Homologação|Windows 11 Ent|2|4GB|Adaptador 1: NAT|
|**Win7-Legado**|Alvo Legado|Windows 7 SP1|1|2GB|Adaptador 1: NAT|
|**Metasploitable**|Alvo Vulnerável|Ubuntu 14.04|1|1GB|Adaptador 1: Host-Only|

---

## 3. Stack de Aplicação (Host)

Ferramentas executadas no Sistema Operacional Hospedeiro (Windows 11 Host), segregadas no perfil de usuário `fiqueok`.

|**Componente**|**Versão**|**Método de Deploy**|**Dependências**|
|---|---|---|---|
|**Docker Desktop**|Latest|MSI Installer|WSL2 Backend|
|**DefectDojo**|Latest|Docker Compose|PostgreSQL, RabbitMQ, Nginx|
|**OpenVAS (GVM)**|Community|Docker Compose|Redis, Greenbone Feeds|

---

## 4. Documentos Relacionados

- **Análise de Riscos e Gaps:** [[RISK-001 - Riscos da Arquitetura v1.0]]
    
- **Plano de Mudança:** [[GMUD-001 - Reestruturação de Rede OOB]]
