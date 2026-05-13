
Implementação da Rede de Gerência (OOB)

> ID da Mudança: GMUD-2025-001
> 
> Data: 16/12/2025
> 
> Solicitante: Paulo (Arquiteto de Segurança)
> 
> Status: Planejada / Aprovada
> 
> Impacto: Interrupção total da comunicação entre VMs durante a reconfiguração.

---

## 1. Contexto e Justificativa (O "Porquê")

A arquitetura inicial do laboratório utilizava uma mistura de redes NAT e Rede Interna (`LAB_NET`) que impedia a visibilidade do Scanner de Vulnerabilidades (**OpenVAS**), que roda no Host via Docker, sobre os ativos virtualizados.

Além disso, máquinas intencionalmente vulneráveis (Windows 7 e Metasploitable) estavam configuradas em NAT, expondo-as desnecessariamente à internet, o que viola o princípio de _Security First_.

Objetivo da Mudança:

Criar um plano de gerenciamento isolado (Out-of-Band Management - OOB) usando a rede Host-Only do VirtualBox, permitindo que o OpenVAS escaneie as VMs sem expô-las à internet e sem depender de roteamento da rede de produção simulada (LAB_NET).

---

## 2. Cenário "De-Para" (Arquitetura)

### Situação Atual (Legado/Inseguro)

- **Mistura de Redes:** VMs espalhadas entre NAT e Rede Interna sem padrão de gerência.
    
- **Ponto Cego:** O Docker (Host) não tem rota para a rede `LAB_NET`.
    
- **Risco:** Windows 7 (Legado) com acesso à Internet via NAT.
    

### Situação Alvo (Segura/Gerenciável)

A nova topologia introduz a **Rede Host-Only (192.168.56.x)** como VLAN de Gerência/Scan.

|**VM / Ativo**|**Função**|**Adaptador 1 (Prod/WAN)**|**Adaptador 2 (LAN Corp)**|**Adaptador 3 (Gerência OOB)**|**Status de Segurança**|
|---|---|---|---|---|---|
|**Host (Físico)**|Docker / OpenVAS|Wi-Fi (Internet)|N/A|**vboxnet0 (GW)**|Scanner Origem|
|**LinuxLite**|Gateway / Proxy|**NAT** (WAN)|**Rede Interna** (`LAB_NET`)|**Host-Only**|Dual-homed|
|**DC01 (Win Server)**|AD / Identidade|-|**Rede Interna** (`LAB_NET`)|**Host-Only**|Isolado da Web|
|**Win10**|Cliente Corp|-|**Rede Interna** (`LAB_NET`)|**Host-Only**|Isolado da Web|
|**Win11**|Lab Homologação|**Host-Only**|-|-|Totalmente Isolado|
|**Win7**|Legado/Alvo|**Host-Only**|-|-|**Air-Gapped** (Seguro)|
|**Metasploitable**|Alvo Crítico|**Host-Only**|-|-|**Air-Gapped** (Seguro)|

---

## 3. Plano de Execução (Script da Mudança)

1. **Parar todas as VMs:** Garantir desligamento gracioso (ACPI Shutdown).
    
2. **Configurar Rede Global:**
    
    - VirtualBox > Network Manager.
        
    - Validar `VirtualBox Host-Only Ethernet Adapter`.
        
    - IP Host: `192.168.56.1` / Máscara: `255.255.255.0`.
        
    - DHCP: Ativado (Faixa `.100` a `.200`).
        
3. **Reconfigurar Adaptadores (VM por VM):**
    
    - _LinuxLite:_ Manter NAT + Internal; Adicionar Host-Only.
        
    - _DC01/Win10:_ Manter Internal; Adicionar Host-Only.
        
    - _Win7/Metasploitable/Win11:_ Remover NAT; Definir **apenas** Host-Only.
        
    - _Segurança:_ Definir "Modo Promíscuo: Recusar" em todas as interfaces Host-Only.
        
4. **Start-up:** Ligar VMs na ordem: Gateway -> AD -> Clientes.
    

---

## 4. Plano de Teste e Validação (Rollback)

Para considerar a GMUD com sucesso, os seguintes testes devem passar:

- [ ] **Teste de Conectividade Host:** O Host consegue pingar o IP de Gerência de todas as VMs (`ping 192.168.56.x`).
    
- [ ] **Teste de Isolamento:** O Windows 7 **NÃO** consegue acessar `google.com` (Ping falha, Navegador falha).
    
- [ ] **Teste de Operação:** O Win10 consegue logar no domínio (tráfego da `LAB_NET` preservado).
    

Plano de Rollback:

Caso a comunicação falhe, reverter o Adaptador 1 das VMs críticas para NAT para recuperar acesso administrativo.

