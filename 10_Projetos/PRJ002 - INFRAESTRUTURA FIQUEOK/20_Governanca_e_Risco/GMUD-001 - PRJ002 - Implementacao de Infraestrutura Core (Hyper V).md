# 

**Projeto:** PRJ002 - Infraestrutura Fiqueok (Greenfield) **Solicitante:** Paulo Feitosa (CISO/Arquiteto) **Data de Execução:** 22/12/2025 **Tipo:** Implementação Estrutural (Critical Path) **Status:** ✅ Executado com Sucesso

---

## 1. Objetivo Executivo

Estabelecer a camada base de virtualização (Rede e Computação) no Host Físico (Windows 11) para suportar o novo laboratório de Identidade e Governança da _Fiqueok Consultoria_. Esta mudança visa substituir o ambiente legado (VirtualBox) por uma arquitetura corporativa baseada em Hyper-V, alinhada a requisitos de segurança de perímetro e performance.

## 2. Escopo da Mudança (Detalhamento Técnico)

A execução foi dividida em duas etapas lógicas interdependentes:

### 🏗️ Etapa 1: A Fundação (Camada de Rede e Isolamento)

Criação do perímetro de rede lógica para garantir isolamento do tráfego corporativo simulado em relação à rede doméstica (ISP), atendendo ao controle **A.13.1 da ISO 27001 (Gerenciamento de Rede)**.

- **Switch Virtual (vSwitch):**
    
    - _Nome:_ `vSwitch_Fiqueok_Corp`
        
    - _Tipo:_ **Internal** (Garante que as VMs não tenham acesso direto "Bridge" à placa física, forçando todo o tráfego a passar pelo Gateway controlado).
        
- **Gateway Lógico:**
    
    - _Interface:_ vEthernet (Host)
        
    - _Endereço IP:_ `xxx.xxx.xxx.xxx/24`
        
    - _Função:_ Atuar como Roteador de Borda para o ambiente virtual.
        
- **NAT (Network Address Translation):**
    
    - _Nome:_ `NAT_Fiqueok_Network`
        
    - _Subnet Alvo:_ `xxx.xxx.xxx.xxx/24`
        
    - _Função:_ Permitir que as VMs acessem a internet (Download de updates/pacotes) mascarando seus IPs internos, sem permitir conexões de entrada não solicitadas da internet.
        

### 🧱 Etapa 2: As Paredes (Provisionamento de Computação/VM)

Deploy automatizado do primeiro ativo crítico (Tier 0) da infraestrutura: o futuro Controlador de Domínio.

- **Ativo:** Máquina Virtual `ID-P-01`
    
- **Localização Física:** Padronizada em `C:\VMs\ID-P-01` (para evitar _Data Sprawl_).
    
- **Especificações de Hardware Virtual:**
    
    - **Geração 2 (UEFI):** Habilitada para suporte a sistemas operacionais modernos e boot seguro.
        
    - **Segurança (Hardening):** Ativação de **TPM 2.0** (Trusted Platform Module) e **Secure Boot**. Isso prepara o ambiente para simulações avançadas de _Credential Guard_ e criptografia de disco (BitLocker).
        
    - **Processamento:** Ajustado para **2 vCPUs** (evitando gargalos de interrupção de hardware durante instalação de Updates).
        
    - **Memória:** Dinâmica (Startup: 2048MB / Max: 4096MB). Otimização para garantir boot rápido do instalador sem alocar recursos desnecessários em _idle_.
        
    - **Mídia:** Montagem da ISO `WindowsServer2022.iso` a partir do repositório centralizado `C:\VMs\ISOs`.
        

## 3. Justificativa e Benefícios

1. **Segurança por Design:** A arquitetura de NAT impede que dispositivos IoT ou convidados na rede Wi-Fi doméstica acessem as portas de administração (RDP/SSH) dos servidores do laboratório.
    
2. **Alta Fidelidade:** O uso de Hyper-V com TPM simulado replica com exatidão ambientes de Fintechs e Grandes Empresas, permitindo estudos de cenários de ataque e defesa impossíveis no VirtualBox padrão.
    
3. **Organização:** Centralização de ativos em `C:\VMs` facilita rotinas futuras de Backup e Disaster Recovery.
    

## 4. Plano de Rollback (Contingência)

Caso o novo stack de rede cause instabilidade no Host Físico, o seguinte procedimento de reversão foi validado:

1. Execução do script `Rollback-Rede-Fiqueok.ps1` (Remove NAT, IP e vSwitch).

   C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ001- LABORATORIO DE SI\20_Governanca & Risco\GMUD-006 - Migracao de Infraestrutura De Virtual Box para Hyper V.md
    
3. Exclusão da pasta `C:\VMs\ID-P-01`.
    

## 5. Evidências de Sucesso

- Logs do PowerShell indicando: `[OK] Switch Criado`, `[OK] NAT Ativo`, `✅ VM CRIADA COM SUCESSO`.
    
- VM `ID-P-01` iniciada e aguardando instalação do OS via console.
