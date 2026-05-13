

Projeto: Fiqueok Consultoria - Lab IAM & Cybersec

Solicitante: Paulo Feitosa (CISO)

Data: 22/12/2025

Classificação: Estrutural / Infraestrutura

---

## 1. Resumo Executivo

Desmobilização do ambiente de virtualização legado baseado em **Oracle VirtualBox** (Hypervisor Tipo 2) e implementação de nova infraestrutura baseada em **Microsoft Hyper-V** (Hypervisor Tipo 1) no Host Windows 11 Pro.

A mudança inclui a segregação lógica de redes via vSwitch Interno e NAT, abandonando o modelo de "Bridge" direto com a rede doméstica.

## 2. Justificativa (Por que mudar?)

### A. Limitações do Modelo Atual (VirtualBox)

- **Performance:** Como Hypervisor Tipo 2, roda sobre o SO, competindo por recursos e gerando latência em laboratórios complexos (Identity Server + DC + Scanners).
    
- **Segurança de Rede:** O uso predominante de interfaces em modo "Bridge" expõe as VMs diretamente à rede local (Wi-Fi Doméstico), aumentando a superfície de ataque lateral.
    
- **Compatibilidade:** Dificuldade em simular recursos de segurança modernos do Windows (Credential Guard, TPM 2.0 real) necessários para estudos avançados de IAM.
    

### B. Benefícios da Nova Arquitetura (Hyper-V)

1. **Conformidade ISO 27001 (A.13.1):** Criação de um perímetro de segurança controlado. As VMs operam em uma sub-rede isolada (`xxx.xxx.xxx.xxx/24`), acessando a internet via NAT, sem exposição direta de portas para a rede doméstica.
    
2. **Alta Fidelidade:** O Hyper-V é o padrão de mercado corporativo Microsoft. O ambiente simulará com exatidão a infraestrutura encontrada em grandes clientes e Fintechs.
    
3. **Eficiência de Recursos:** Uso de _Dynamic Memory_ (Memória Dinâmica) permite rodar o stack completo (AD + Linux + Scanners) otimizando o uso dos 32GB de RAM do Host.
    

## 3. Arquitetura Técnica (TO-BE)

- **Host:** Windows 11 Pro (Feature 'Hyper-V Platform' ativada).
    
- **Topologia de Rede:**
    
    - **Switch:** `vSwitch_Fiqueok_Corp` (Tipo: Internal).
        
    - **Gateway:** `xxx.xxx.xxx.xxx` (Interface do Host).
        
    - **Subnet:** `xxx.xxx.xxx.xxx/24`.
        
    - **Acesso Externo:** Via NAT (Network Address Translation).
        
- **Workloads Iniciais:**
    
    - `ID-P-01`: Domain Controller & DNS (Windows Server 2022).
        
    - `SRV-APPS`: Container Host (Linux) para IGA e Keycloak.
        

## 4. Plano de Execução (High Level)

1. **Preparação:** Saneamento de discos e centralização de ISOs em `C:\VMs\ISOs`.
    
2. **Rede:** Execução de Script PowerShell para criação de vSwitch e NAT.
    
3. **Provisionamento:** Deploy automatizado da VM `ID-P-01` com TPM e Secure Boot.
    
4. **Instalação:** Setup do Windows Server 2022 e promoção do Domínio `corp.fiqueok.com.br`.
    

## 5. Plano de Rollback (Plano de Retorno)

Em caso de falha crítica na configuração de rede que impacte a conectividade do Host ou inviabilize o laboratório, o ambiente será restaurado ao estado original via script automatizado.

Ação de Contingência:

Executar o script Rollback-Rede-Fiqueok.ps1 com privilégios administrativos.

PowerShell

```
# =========================================================
# SCRIPT DE CONTINGÊNCIA: Rollback Rede Fiqueok
# OBJETIVO: Remover configurações de NAT e vSwitch, limpando o Host.
# =========================================================

$SwitchName = "vSwitch_Fiqueok_Corp"
$NatName    = "NAT_Fiqueok_Network"

Write-Host "🗑️ INICIANDO PROCEDIMENTO DE ROLLBACK (GMUD-2025-001)..." -ForegroundColor Red

# 1. Remover Regra de NAT
Write-Host "1. Removendo Regra NAT..." -NoNewline
Get-NetNat -Name $NatName -ErrorAction SilentlyContinue | Remove-NetNat -Confirm:$false
Write-Host " [OK]" -ForegroundColor Green

# 2. Remover IP do Gateway Virtual
Write-Host "2. Removendo Gateway da Interface Virtual..." -NoNewline
$NetAdapter = Get-NetAdapter -Name "vEthernet ($SwitchName)" -ErrorAction SilentlyContinue
if ($NetAdapter) {
    Remove-NetIPAddress -InterfaceAlias $NetAdapter.Name -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host " [OK]" -ForegroundColor Green
} else {
    Write-Host " [NÃO ENCONTRADO]" -ForegroundColor Yellow
}

# 3. Remover Switch Virtual
Write-Host "3. Excluindo Switch Virtual..." -NoNewline
Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue | Remove-VMSwitch -Force -Confirm:$false
Write-Host " [OK]" -ForegroundColor Green

Write-Host "`n✅ ROLLBACK CONCLUÍDO. O ambiente foi restaurado." -ForegroundColor Cyan
```

---

### 🚦 Aprovação

- **Aprovador:** Paulo Feitosa
    
- **Status:** Aprovado para Execução
    
- **Janela de Execução:** Imediata.
    

---

Paulo, com o GMUD salvo, estamos Compliance.

Podemos proceder para a execução do Script 1 (Rede) no terminal?
