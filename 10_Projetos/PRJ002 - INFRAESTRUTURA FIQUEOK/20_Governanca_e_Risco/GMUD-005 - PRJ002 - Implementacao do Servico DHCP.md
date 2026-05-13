

# GMUD-005 - PRJ002 - Implementação do Serviço DHCP

**Projeto:** PRJ002 - Infraestrutura Fiqueok **Solicitante:** Paulo Feitosa (Arquiteto/SysAdmin) **Data Planejada:** 22/12/2025 **Risco:** Baixo **Status:** ⏳ Aguardando Aprovação

---

## 1. Objetivo

Ativar a função de Servidor DHCP no Controlador de Domínio `ID-P-01`. Isso automatizará a atribuição de endereços IP para o parque de máquinas.

## 2. Escopo Técnico

- **Role:** `DHCP Server`.
    
- **Escopo:** `xxx.xxx.xxx.xxx/24`.
    
- **Range:** `xxx.xxx.xxx.xxx` a `xxx.xxx.xxx.xxx`.
    
- **Hardening:** Credencial de serviço DHCP autorizada no AD (evita Rogue DHCP).
    

## 3. Alinhamento de Frameworks (Racional Técnico)

Esta implementação atende aos requisitos de "Como Fazer" dos seguintes frameworks:

- **CIS Control 01 (Inventory and Control of Enterprise Assets):**
    
    - _Sub-control 1.1:_ O DHCP fornece visibilidade ativa de quais ativos estão conectados à rede, facilitando o inventário dinâmico.
        
- **CIS Control 04 (Secure Configuration of Enterprise Assets):**
    
    - _Sub-control 4.1:_ Garante que todos os hosts recebam configurações de DNS e Gateway seguros centralizadamente, evitando configurações manuais vulneráveis.
        
- **NIST CSF (ID.AM - Asset Management):**
    
    - O DHCP é a fonte primária de dados para identificar ativos físicos e virtuais na rede (ID.AM-01).
        

## 4. Justificativa de Negócio (ISO 27001)

- **A.13.1 (Gerenciamento de Rede):** Garante que apenas endereços autorizados e configurações de rota controladas sejam distribuídos, mitigando riscos de _Man-in-the-Middle_ por configuração errada de DNS.
    

## 5. Plano de Execução (IaC)

Instalação via PowerShell (`Install-WindowsFeature`), Autorização no AD (Security Group `DhcpAdministrators`) e Criação de Escopo.

## 6. Plano de Rollback

Remoção da role via `Uninstall-WindowsFeature` e retorno ao endereçamento estático.
