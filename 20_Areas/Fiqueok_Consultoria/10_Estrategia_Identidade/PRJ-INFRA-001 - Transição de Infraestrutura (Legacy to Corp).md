---
tags:
  - "#Governance"
  - "#Infrastructure"
  - "#Architecture"
  - "#Fiqueok"
created: 2025-12-19
status: 🟡 Planning
---

# 🏗️ 
> [!abstract] Resumo Executivo
> Este documento formaliza a decisão estratégica de **descomissionar integralmente** o ambiente de laboratório legado ("LAB") baseada em VirtualBox e iniciar a construção da infraestrutura corporativa da **Fiqueok Consultoria** utilizando Hyper-V e padrões de mercado (ISO 27001/CIS).
>
> **Objetivo:** Estabelecer uma fundação segura, escalável e performática para suportar a operação e as demonstrações técnicas da consultoria.

---

## 1. Justificativa de Mudança (Business Case)

O ambiente atual (`lab.local`) cumpriu seu papel como Prova de Conceito (PoC), mas apresenta limitações técnicas e de governança que impedem a evolução da marca:

1.  **Limitação de Hypervisor:** O uso de *Oracle VirtualBox* (Type 2) degrada performance e não reflete a realidade de clientes corporativos (que usam Hyper-V/VMware).
2.  **Débito Técnico:** A estrutura de diretório (AD) possui vícios de configuração e objetos órfãos incompatíveis com um modelo de referência de segurança.
3.  **Identidade de Marca:** A nomenclatura genérica "LAB" enfraquece a autoridade técnica em demonstrações para clientes.

---

## 2. Escopo de Descomissionamento (The Purge)

Os seguintes ativos serão **permanentemente destruídos** sem migração de dados (apenas backup de propriedade intelectual, se houver):

| Ativo | Tecnologia | Ação | Status |
| :--- | :--- | :--- | :--- |
| **Plataforma de Virtualização** | Oracle VirtualBox | Desinstalação Completa | ⬜ A Fazer |
| **Controlador de Domínio** | Windows Server (LAB) | Delete (Wipe) | ⬜ A Fazer |
| **Ferramentas de Seg.** | OpenVAS / DefectDojo | Delete (Reinstalação Futura) | ⬜ A Fazer |
| **Redes Virtuais** | VBoxNet0 | Remoção | ⬜ A Fazer |

> [!danger] Ponto de Não Retorno
> Após a execução da Fase 1, toda a configuração antiga será perdida. O foco será 100% na construção do novo ambiente ("Greenfield").

---

## 3. Especificação da Nova Infraestrutura (TO-BE)

A nova estrutura nascerá em conformidade com o princípio *Secure by Design*.

### 3.1. Núcleo (Core)
- **Hypervisor:** Microsoft Hyper-V (Type 1) - Nativo do Windows 11 Pro.
- **Topologia de Rede:** `vSwitch_Fiqueok_Corp` (Internal/NAT) - Isolamento total da rede doméstica.
- **Sistema Operacional Server:** Windows Server 2022 (Evaluation/Standard).

### 3.2. Identidade e Acesso (IAM)
- **Nome da Floresta:** `corp.fiqueok.com.br` (Padrão Split-Brain DNS).
- **Nome NetBIOS:** `FIQUEOK\`
- **Hostname do DC:** `ID-P-01` (Identity - Prod - 01).
- **Nível Funcional:** Windows Server 2016 (ou superior).

### 3.3. Serviços Críticos (Roadmap)
1.  **Active Directory DS:** Estrutura hierárquica baseada em RBAC (Fiqueok Standard).
2.  **Docker Host:** VM dedicada para rodar containers de segurança (DefectDojo, etc).
3.  **Vulnerability Mng:** VM dedicada para Scanner (OpenVAS/Greenbone).

---

## 4. Plano de Execução (Checklist)

### Fase 1: Limpeza e Preparação
- [ ] Backup de scripts/arquivos essenciais do ambiente antigo para Host Físico.
- [ ] Desinstalação do Oracle VirtualBox.
- [ ] Ativação da Feature "Hyper-V Platform" no Windows 11.
- [ ] Reboot do Host Físico.

### Fase 2: Fundação
- [ ] Download da ISO Windows Server 2022 (Oficial Microsoft).
- [ ] Criação do Switch Virtual `vSwitch_Fiqueok_Corp` (Internal).
- [ ] Configuração de NAT (PowerShell) para saída de internet.

### Fase 3: Implementação do Domínio
- [ ] Provisionamento da VM `ID-P-01`.
- [ ] Instalação do AD DS.
- [ ] Promoção do Domínio `corp.fiqueok.com.br`.
- [ ] Execução da GMUD-004 (Criação de OUs e Estrutura).

---

## 5. Aprovação
**Data da Decisão:** 19/12/2025
**Responsável Técnico:** Paulo Feitosa (Head de Infraestrutura & Segurança)