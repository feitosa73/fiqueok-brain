

---

# 🏗️ Arquitetura de Referência do Lab - Versão 1.0 (Baseline)

> Doc ID: ARQ-LAB-001
> 
> Versão: 1.0 (As-Is / Pré-GMUD)
> 
> Data: 16/12/2025
> 
> Status: Obsoleto / Risco Identificado
> 
> Responsável: Paulo (Fiqueok)

---

## 1. Visão Geral da Topologia

Nesta versão inicial (v1.0), o ambiente opera em um modelo híbrido não padronizado. A infraestrutura de virtualização (VirtualBox) e a camada de gestão (Docker) operam no mesmo Host físico, mas com segmentação de rede incompleta, resultando em riscos de exposição de ativos vulneráveis.

## 2. Inventário de Hardware e Host (Camada Física)

- **Hardware:** Desktop Pessoal de Alta Performance.
    
- **Sistema Operacional:** Windows 11 (Otimizado).
    
- **Segregação de Acesso:**
    
    - **Perfil `win` (Admin):** Manutenção e Drivers.
        
    - **Perfil `feitosa73` (Gamer):** Lazer e Alta Performance Gráfica.
        
    - **Perfil `fiqueok` (GRC/Lab):** Ambiente de trabalho, Docker e Virtualização (Isolado).
        

## 3. Inventário de Ativos Virtuais (Camada de Simulação)

Abaixo, a configuração de rede atual (estado atual, _antes_ da correção de segurança).

| **Hostname**       | **Função**             | **SO**           | **Rede Atual (Config)** | **Status de Risco**   |
| ------------------ | ---------------------- | ---------------- | ----------------------- | --------------------- |
| **LinuxLite**      | Gateway / Proxy        | Linux            | NAT + Rede Interna      | Baixo                 |
| **DC01**           | Domain Controller (AD) | Win Server 2022  | Rede Interna            | Baixo                 |
| **Win10-Corp**     | Estação de Trabalho    | Windows 10       | Rede Interna            | Baixo                 |
| **Win11-Lab**      | Homologação Apps       | Windows 11       | **NAT**                 | Médio (Exposto à Web) |
| **Win7-Legado**    | Alvo de Pentest        | Windows 7        | **NAT**                 | **CRÍTICO**           |
| **Metasploitable** | Alvo de Pentest        | Linux Vulnerável | **Host-Only**           | Controlado            |
|                    |                        |                  |                         |                       |

### 🚨 Análise de Risco da Arquitetura v1.0

1. **Exposição Desnecessária:** A máquina **Windows 7 (Legado)** está configurada em NAT, o que permite saída para a internet. Sendo um SO sem suporte, isso representa um vetor de ataque real.
    
2. **Ponto Cego de Auditoria:** O Docker (onde roda o OpenVAS) reside na rede do Host e não possui rota clara para alcançar as máquinas na "Rede Interna" (`LAB_NET`), impedindo scans de vulnerabilidade eficazes sem reconfiguração.
    

---

## 4. Camada de Aplicação e Gestão (AppSec Stack)

Ferramentas implementadas via Container (Docker/WSL2) no perfil `fiqueok`.

|**Ferramenta**|**Função**|**Versão**|**Status**|
|---|---|---|---|
|**DefectDojo**|Gestão de Vulnerabilidades|Latest|**Operacional**|
|**OpenVAS (GVM)**|Scanner de Infraestrutura|Community|**Em Deploy/Sync**|
|**Obsidian**|Base de Conhecimento|Latest|**Operacional**|

---

## 5. Próximos Passos (Plano de Evolução)

Esta arquitetura será descontinuada e substituída pela **Versão 1.1** após a execução da **GMUD-001**, que visa:

1. Isolar ativos vulneráveis (Win7) em rede Host-Only (OOB).
    
2. Estabelecer rota de varredura para o OpenVAS.
    
3. Remover acesso à internet de máquinas legadas.
    

---

