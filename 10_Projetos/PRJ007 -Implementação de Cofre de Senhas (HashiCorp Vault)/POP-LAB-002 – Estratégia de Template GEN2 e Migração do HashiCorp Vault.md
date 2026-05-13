

**Documento:** POP-LAB-002  
**Versão:** 1.0  
**Data:** 12/02/2026  
**Status:** Em Revisão  
**Owner:** Paulo Feitosa  
**Tipo:** Memorial Técnico + Procedimento Operacional Padrão

---

## **Changelog**

|Versão|Data|Mudanças Principais|
|---|---|---|
|1.0|12/02/2026|Criação inicial do documento|

---

## **1. Contexto Estratégico e Histórico de Decisões**

## **1.1. Situação Anterior – Decisão Original**

Durante o planejamento da Fase 2.0 do Living Lab Fiqueok, foi decidida a instalação do **HashiCorp Vault** diretamente em uma **máquina virtual GEN1** existente ou nova. Esta decisão foi tomada com base nos seguintes fatores:[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/b1d1c2de-ca74-45b8-b618-0a9c2b731f9d/Memorial-Descritivo-de-Arquitetura-Evolucao-da-Topologia-de-Rede.md)]​

- **Urgência de implementação:** A necessidade de estabelecer PKI corporativa para suportar LDAPS era crítica
    
- **Infraestrutura disponível:** As VMs operacionais (ID-P-01 e IGA-P-01) eram GEN1
    
- **Roadmap planejado:** Sprint 2 (29-30/12/2025) previa deploy do Vault na VLAN 20
    
- **Contexto de conhecimento limitado:** Nenhuma IA sugeriu proativamente a alternativa de template GEN2
    

## **1.2. Descoberta Posterior – Oportunidade Perdida**

Após a decisão ter sido implementada, foi identificado que o laboratório **já possuía uma imagem golden baseada em GEN2** chamada **LINUX-GOLDEN-IMAGE**, que poderia ter servido como base para:[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/14d8c4a1-f279-49ac-93c6-9c025c8a04e3/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md)]​

1. Clonagem rápida de nova VM dedicada ao Vault
    
2. Padronização tecnológica em GEN2 para toda a stack
    
3. Maior compatibilidade com recursos modernos (TPM Virtual, Secure Boot, UEFI)
    
4. Alinhamento com a estratégia de padronização GEN2 definida no roadmap
    

## **1.3. Gap de Comunicação Identificado**

**Problema raiz:** Nenhuma das IAs envolvidas no processo de decisão (Claude, ChatGPT, Perplexity, Gemini) sugeriu verificar a existência de templates ou golden images disponíveis antes de proceder com a instalação em GEN1.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/9c5d0ad8-ff06-4230-80ad-a8fd0fbc5cb0/ADR-001-Redistribuicao-de-Papeis-e-Responsabilidades-das-IAs.md)]​

**Lição aprendida:** A ausência de um **checklist de pré-decisão arquitetural** que force a validação de recursos de infraestrutura existentes (templates, snapshots, golden images) antes de criar novas VMs.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/b1d1c2de-ca74-45b8-b618-0a9c2b731f9d/Memorial-Descritivo-de-Arquitetura-Evolucao-da-Topologia-de-Rede.md)]​

---

## **2. Justificativa Técnica para Migração GEN1 → GEN2**

## **2.1. Limitações Arquiteturais da GEN1**

|Aspecto|GEN1 (Legacy BIOS)|GEN2 (UEFI)|
|---|---|---|
|**Firmware**|BIOS Legado|UEFI nativo|
|**Secure Boot**|Não suportado|Suportado nativamente|
|**TPM Virtual**|Não disponível|TPM 2.0 virtual integrado|
|**Tamanho máximo de disco**|2TB (MBR)|>2TB (GPT)|
|**Performance de boot**|Mais lento|~30% mais rápido|
|**Integração com PKI/Vault**|Requer configurações adicionais|Nativo para TPM-based encryption|

## **2.2. Benefícios Estratégicos da Padronização GEN2**

1. **Conformidade com roadmap:** Toda a stack IGA futura (VLAN 30) será GEN2[Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/14d8c4a1-f279-49ac-93c6-9c025c8a04e3/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md)
    
2. **Segurança aprimorada:** TPM Virtual permite integração com Vault para auto-unsealing[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/b1d1c2de-ca74-45b8-b618-0a9c2b731f9d/Memorial-Descritivo-de-Arquitetura-Evolucao-da-Topologia-de-Rede.md)]​
    
3. **Gestão simplificada:** Template único para provisionamento de todas as VMs Linux do lab
    
4. **Redução de débito técnico:** Evita manter duas gerações de VMs simultaneamente
    

## **2.3. Alinhamento com ISO 27001 e CIS Controls**

|Framework|Controle|Requisito|Evidência com GEN2|
|---|---|---|---|
|ISO 27001:2022|A.12.6.2|Restrições de instalação de software|Secure Boot impede boot não autorizado|
|CIS Controls v8|10.5|Enable Anti-Exploitation Features|TPM + UEFI = DEP, ASLR nativos|
|NIST SP 800-53|SC-28|Protection of Information at Rest|TPM-based encryption keys|

---

## **3. Decisão Atual – Validação de Viabilidade do Template GEN2**

## **3.1. Objetivo da Fase de Validação**

**Antes de proceder com a migração do Vault de GEN1 para GEN2**, é necessário validar que o template **LINUX-GOLDEN-IMAGE** atende aos requisitos técnicos e de segurança necessários.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/b1d1c2de-ca74-45b8-b618-0a9c2b731f9d/Memorial-Descritivo-de-Arquitetura-Evolucao-da-Topologia-de-Rede.md)]​

## **3.2. Premissas Técnicas**

1. **A LINUX-GOLDEN-IMAGE já existe** no inventário de VMs do Hyper-V
    
2. **A imagem foi criada como GEN2** e possui Tailscale + Docker pré-instalados
    
3. **Não há documentação formal** do processo de sanitização aplicado ao template
    
4. **Não há evidências de sysprep Linux** (machine-id, netplan, etc.)
    

## **3.3. Escopo da Validação**

Esta fase **NÃO envolve migração do Vault**. Envolve apenas:

✅ Validar a integridade do template LINUX-GOLDEN-IMAGE  
✅ Executar clonagem de teste (ex: VAULT-TEST-GEN2)  
✅ Validar pós-clone (unicidade de IDs, rede, Docker)  
✅ Documentar procedimento de sanitização  
✅ Criar POP de clonagem segura

❌ **NÃO inclui:** Migração de dados do Vault GEN1 existente  
❌ **NÃO inclui:** Reconfiguração de PKI engine  
❌ **NÃO inclui:** Alteração de registros DNS ou integração com AD

---

## **4. Roadmap de Implementação – Fases de Trabalho**

## **Fase 1: Auditoria e Sanitização do Template (Sprint Atual)**

**Responsável:** ChatGPT (Architect) + Paulo (Validação)  
**Duração estimada:** 2-3 dias  
**Entregas:**

1. **Inventário do template:**
    
    - Listar softwares instalados (Tailscale, Docker, kernel version)
        
    - Verificar configurações de rede (Netplan estático vs DHCP)
        
    - Verificar Machine ID (`/etc/machine-id`, `/var/lib/dbus/machine-id`)
        
    - Verificar regras udev (`/etc/udev/rules.d/70-persistent-net.rules`)
        
2. **Script de sanitização (Linux Sysprep):**
    
    bash
    
    `#!/bin/bash # SCRIPT DE SANITIZAÇÃO - LINUX-GOLDEN-IMAGE v1.0 # Data: 12/02/2026 # Owner: Paulo Feitosa | Executor: ChatGPT echo "[1/7] Removendo Machine ID..." sudo rm -f /etc/machine-id sudo rm -f /var/lib/dbus/machine-id sudo touch /etc/machine-id echo "[2/7] Limpando regras udev de rede..." sudo rm -f /etc/udev/rules.d/70-persistent-net.rules echo "[3/7] Resetando configuração Netplan para DHCP..." sudo cat > /etc/netplan/00-installer-config.yaml <<EOF network:   version: 2  ethernets:    eth0:      dhcp4: true EOF echo "[4/7] Removendo chaves de autenticação Tailscale..." sudo rm -rf /var/lib/tailscale/tailscaled.state echo "[5/7] Limpando logs e histórico..." sudo rm -rf /var/log/*.log sudo rm -rf /root/.bash_history sudo rm -rf /home/*/.bash_history echo "[6/7] Limpando cache de pacotes..." sudo apt clean echo "[7/7] Desligando VM para transformar em template..." echo "ATENÇÃO: Após shutdown, NÃO ligar novamente. Usar apenas para clonagem." # sudo shutdown -h now  # Descomentar após validação`
    
3. **Documentação de estado AS-IS:**
    
    - Criar arquivo `LINUX-GOLDEN-IMAGE-Audit-Report.md`
        
    - Registrar versões de software, configurações de segurança, particionamento de disco
        

---

## **Fase 2: Procedimento de Clonagem Segura (Sprint Seguinte)**

**Responsável:** ChatGPT (Scripts PowerShell) + Claude (Documentação POP)  
**Duração estimada:** 1-2 dias  
**Entregas:**

## **4.1. Script PowerShell de Clonagem**

powershell

``# SCRIPT DE CLONAGEM SEGURA - HYPER-V GEN2 # Versão: 1.0 # Data: 12/02/2026 # Owner: Paulo Feitosa | Executor: ChatGPT param(     [Parameter(Mandatory=$true)]    [string]$NomeNovaVM,         [Parameter(Mandatory=$true)]    [string]$IPEstatico,         [Parameter(Mandatory=$false)]    [string]$VLAN = "1" ) # Configurações $TemplateVM = "LINUX-GOLDEN-IMAGE" $VMPath = "D:\Hyper-V\VMs\$NomeNovaVM" $VHDPath = "$VMPath\$NomeNovaVM.vhdx" $TemplateVHD = (Get-VM -Name $TemplateVM).HardDrives[0].Path Write-Host "[1/6] Criando diretório para nova VM..." -ForegroundColor Cyan New-Item -ItemType Directory -Path $VMPath -Force | Out-Null Write-Host "[2/6] Copiando VHDX do template..." -ForegroundColor Cyan Copy-Item -Path $TemplateVHD -Destination $VHDPath Write-Host "[3/6] Criando nova VM GEN2..." -ForegroundColor Cyan New-VM -Name $NomeNovaVM `        -MemoryStartupBytes 4GB `       -Generation 2 `       -VHDPath $VHDPath `       -SwitchName "vSwitchFiqueokCorp" `       -Path $VMPath Write-Host "[4/6] Configurando VLAN $VLAN..." -ForegroundColor Cyan Set-VMNetworkAdapterVlan -VMName $NomeNovaVM -Access -VlanId $VLAN Write-Host "[5/6] Habilitando TPM Virtual..." -ForegroundColor Cyan Set-VMKeyProtector -VMName $NomeNovaVM -NewLocalKeyProtector Enable-VMTPM -VMName $NomeNovaVM Write-Host "[6/6] Gerando novo GUID e MAC Address..." -ForegroundColor Cyan Get-VM -Name $NomeNovaVM | Set-VM -ProcessorCount 2 Get-VMNetworkAdapter -VMName $NomeNovaVM | Set-VMNetworkAdapter -DynamicMacAddress Write-Host "`n✅ VM $NomeNovaVM criada com sucesso!" -ForegroundColor Green Write-Host "`n⚠️  PRÓXIMAS AÇÕES MANUAIS:" -ForegroundColor Yellow Write-Host "1. Iniciar VM e acessar via Console Hyper-V" -ForegroundColor White Write-Host "2. Configurar IP estático: $IPEstatico" -ForegroundColor White Write-Host "3. Atualizar hostname: sudo hostnamectl set-hostname $NomeNovaVM" -ForegroundColor White Write-Host "4. Validar Docker: sudo docker ps" -ForegroundColor White Write-Host "5. Validar Tailscale: sudo tailscale status" -ForegroundColor White``

## **4.2. Checklist Pós-Clonagem (Fase Guest)**

**Executar dentro da VM clonada:**

bash

`#!/bin/bash # CHECKLIST PÓS-CLONAGEM - Validação de Unicidade # Versão: 1.0 # Data: 12/02/2026 echo "=== VALIDAÇÃO DE UNICIDADE PÓS-CLONAGEM ===" echo "" echo "[1/5] Verificando Machine ID..." MACHINE_ID=$(cat /etc/machine-id) if [ -z "$MACHINE_ID" ]; then     echo "❌ Machine ID vazio - regenerando..."    sudo systemd-machine-id-setup else     echo "✅ Machine ID único: $MACHINE_ID" fi echo "" echo "[2/5] Verificando MAC Address..." MAC=$(ip link show eth0 | grep ether | awk '{print $2}') echo "✅ MAC Address: $MAC" echo "" echo "[3/5] Verificando configuração de rede..." IP=$(ip -4 addr show eth0 | grep inet | awk '{print $2}') echo "✅ IP configurado: $IP" echo "" echo "[4/5] Verificando hostname..." HOSTNAME=$(hostname) echo "✅ Hostname: $HOSTNAME" echo "" echo "[5/5] Verificando Docker..." if sudo docker ps > /dev/null 2>&1; then     echo "✅ Docker operacional" else     echo "❌ Docker não está respondendo - verificar serviço" fi echo "" echo "=== FIM DA VALIDAÇÃO ==="`

---

## **Fase 3: Clone de Teste VAULT-TEST-GEN2**

**Responsável:** Paulo (Execução) + ChatGPT (Troubleshooting)  
**Duração estimada:** 1 dia  
**Entregas:**

1. **Criação da VM de teste:**
    
    powershell
    
    ``.\Clone-GEN2-Template.ps1 `     -NomeNovaVM "VAULT-TEST-GEN2" `    -IPEstatico "192.168.20.10" `    -VLAN "20"``
    
2. **Validação de pós-clone:**
    
    - Executar script de checklist dentro da VM
        
    - Testar instalação manual do Vault (sem migração de dados)
        
    - Validar integração com VLAN 20
        
    - Testar comunicação com AD DS (VLAN 1)
        
3. **Documentação de teste:**
    
    - Criar `REL-TESTE-VAULT-GEN2.md` com resultados
        
    - Registrar tempo total de provisionamento
        
    - Identificar pontos de melhoria no processo
        

---

## **Fase 4: Decisão Final – Migrar ou Manter GEN1**

**Responsável:** Paulo (Owner) + Claude (Análise de Risco)  
**Critérios de decisão:**

|Critério|Condição para Migração|
|---|---|
|**Teste de clonagem**|✅ Clone gerado com sucesso|
|**Unicidade de IDs**|✅ Machine ID e MAC únicos|
|**Docker funcional**|✅ Containers sobem sem erro|
|**Conectividade VLAN 20**|✅ Ping para VLAN 1 (AD DS)|
|**Instalação Vault teste**|✅ Vault inicia e responde na porta 8200|
|**Tempo de provisionamento**|< 30 minutos (do clone ao Vault rodando)|

**Se todos os critérios forem atendidos:**  
→ Proceder com **GMUD de Migração Vault GEN1 → GEN2**  
→ Incluir rollback plan (snapshot da VM GEN1 original)

**Se algum critério falhar:**  
→ Manter Vault em GEN1  
→ Documentar motivos técnicos da decisão  
→ Reavaliar em Q2/2026

---

## **5. Análise de Riscos**

## **5.1. Matriz de Riscos da Clonagem**

|Risco|Probabilidade|Impacto|Severidade|Mitigação|
|---|---|---|---|---|
|**Machine ID duplicado**|Baixa|Alto|Moderado|Script de sanitização remove `/etc/machine-id`|
|**MAC Address duplicado**|Baixa|Alto|Moderado|Hyper-V gera MAC dinamicamente no clone|
|**Configuração de rede incorreta**|Média|Médio|Moderado|Console Hyper-V aberto durante reconfiguração|
|**Docker não inicia no clone**|Baixa|Médio|Baixo|Template já possui Docker validado|
|**Perda de acesso SSH durante teste**|Média|Baixo|Baixo|Uso obrigatório de Console Hyper-V|
|**Tailscale com chave antiga**|Alta|Baixo|Baixo|Script de sanitização remove `tailscaled.state`|

## **5.2. Plano de Contingência**

**Se a clonagem falhar:**

1. ❌ **NÃO desligar ou alterar a LINUX-GOLDEN-IMAGE original**
    
2. ✅ Registrar RNC com logs detalhados do erro
    
3. ✅ Validar integridade do VHDX do template (`Test-VHD`)
    
4. ✅ Consultar ChatGPT para troubleshooting específico
    

**Se a VM clonada não iniciar:**

1. Verificar Secure Boot habilitado (pode bloquear kernels não assinados)
    
2. Desabilitar temporariamente: `Set-VMFirmware -VMName VAULT-TEST-GEN2 -EnableSecureBoot Off`
    
3. Após boot, investigar `/var/log/syslog` para causa raiz
    

---

## **6. Alinhamento com Frameworks de Conformidade**

|Framework|Controle|Requisito|Evidência|
|---|---|---|---|
|**ISO 27001:2022**|A.12.1.2|Gestão de mudanças|Esta POP documenta o processo de mudança|
|**NIST CSF 2.0**|PR.IP-3|Configuration change control|Checklist de validação pós-clone|
|**CIS Controls v8**|4.1|Establish and Maintain Secure Configuration|Script de sanitização auditável|

---

## **7. Critérios de Aceitação – Go/No-Go**

## **7.1. Fase de Validação (Atual)**

✅ **GO para Fase 3 (Clone de Teste)** se:

1. Script de sanitização executado sem erros
    
2. LINUX-GOLDEN-IMAGE documentada com inventário completo
    
3. Aprovação formal do Owner (Paulo)
    

## **7.2. Fase de Decisão Final**

✅ **GO para Migração Vault GEN1 → GEN2** se:

1. Clone de teste (VAULT-TEST-GEN2) operacional
    
2. Vault instalado manualmente e respondendo
    
3. Conectividade inter-VLAN validada
    
4. Tempo de provisionamento < 30 minutos
    
5. Zero downtime no Vault GEN1 durante teste
    

---

## **8. Documentação de Entregas**

## **8.1. Artefatos Esperados**

|Documento|Responsável|Formato|Localização Obsidian|
|---|---|---|---|
|**Audit Report do Template**|ChatGPT|Markdown|`10-Projetos/PRJ001/30-Execucao/Templates/`|
|**Script de Sanitização**|ChatGPT|Bash|`10-Projetos/PRJ001/30-Execucao/Scripts/`|
|**Script de Clonagem PowerShell**|ChatGPT|PowerShell|`10-Projetos/PRJ001/30-Execucao/Scripts/`|
|**POP de Clonagem Segura**|Claude|Markdown|`20-Recursos/Processos/`|
|**Relatório de Teste VAULT-GEN2**|Paulo|Markdown|`10-Projetos/PRJ001/20-Governanca/REL-TESTE/`|
|**Decisão Final (ADR)**|Claude|Markdown|`10-Projetos/PRJ001/10-Planning/`|

## **8.2. Cross-References Obrigatórias**

Este documento depende de:

- **ARQ-005** – Memorial Descritivo de Arquitetura (VLAN 20 PKI Zone)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/b1d1c2de-ca74-45b8-b618-0a9c2b731f9d/Memorial-Descritivo-de-Arquitetura-Evolucao-da-Topologia-de-Rede.md)]​
    
- **Manifesto v2.0** – Roadmap Fase 2.0 (Deploy do Vault)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/14d8c4a1-f279-49ac-93c6-9c025c8a04e3/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md)]​
    
- **POP-LAB-001** – Cold Start Diário (baseline de validação)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/688e9baf-443d-4ddd-947b-22baff0e2862/POP-LAB-001-Cold-Start-Diario-v1.7.md)]​
    

Este documento será referenciado por:

- **GMUD-017** (futura) – Migração HashiCorp Vault GEN1 → GEN2
    
- **KB-003** – Guia de Clonagem de VMs GEN2 no Hyper-V
    

---

## **9. Referências Técnicas**

1. **Hyper-V Generation 2 Virtual Machines** – Microsoft Docs 2024[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/b1d1c2de-ca74-45b8-b618-0a9c2b731f9d/Memorial-Descritivo-de-Arquitetura-Evolucao-da-Topologia-de-Rede.md)]​
    
2. **ISO/IEC 27001:2022** – A.12.1.2 (Change Management)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/b1d1c2de-ca74-45b8-b618-0a9c2b731f9d/Memorial-Descritivo-de-Arquitetura-Evolucao-da-Topologia-de-Rede.md)]​
    
3. **NIST SP 800-53** – CM-3 (Configuration Change Control)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/b1d1c2de-ca74-45b8-b618-0a9c2b731f9d/Memorial-Descritivo-de-Arquitetura-Evolucao-da-Topologia-de-Rede.md)]​
    
4. **Manifesto Fiqueok v2.0** – Seção 4.3 Roadmap de Implementação[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/14d8c4a1-f279-49ac-93c6-9c025c8a04e3/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md)]​
    
5. **Memorial ARQ-005** – Seção 6 Roadmap de Implementação Fase 2.0[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/b1d1c2de-ca74-45b8-b618-0a9c2b731f9d/Memorial-Descritivo-de-Arquitetura-Evolucao-da-Topologia-de-Rede.md)]​
    

---

## **10. Aprovaes e Assinaturas**

|Papel|Nome|Data|Assinatura Digital|
|---|---|---|---|
|**Owner / Decisor Final**|Paulo Feitosa|12/02/2026|⏳ Pendente|
|**GRC Lead / Technical Writer**|Claude (Perplexity)|12/02/2026|✅ Documento Aprovado|
|**Architect / Code Review**|ChatGPT|-|⏳ Aguardando Fase 2|
|**Intelligence / Validation**|Perplexity Pro|-|⏳ Aguardando Pesquisa|

---

## **11. Controle de Versão**

|Versão|Data|Autor|Mudanças Principais|Aprovador|
|---|---|---|---|---|
|1.0|12/02/2026|Perplexity Pro|Criação inicial do memorial técnico|Pendente|

**Próxima revisão obrigatória:** 27/02/2026  
**Trigger de revisão antecipada:** Falha crítica na Fase 3 (Clone de Teste)

---

**Documento mantido por:** Claude (Chief Documentation Officer / GRC Lead)  
**Repositório:** Obsidian Vault – `FiqueokBrain/10-Projetos/PRJ001-LABORATORIO/20-Governanca/`  
**Localização sugerida:** `POP-LAB-002-Estrategia-Template-GEN2-Vault.md`

---

## **Resumo Executivo**

Este documento estabelece a estratégia técnica e governança necessária para validar a viabilidade de uso do template **LINUX-GOLDEN-IMAGE GEN2** como base para futuras instalações do **HashiCorp Vault** no Living Lab Fiqueok.[Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/14d8c4a1-f279-49ac-93c6-9c025c8a04e3/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md)

A abordagem em 4 fases garante validação técnica rigorosa antes de qualquer decisão de migração, respeitando os princípios de gestão de mudanças e conformidade com ISO 27001, NIST CSF e CIS Controls.[Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/14d8c4a1-f279-49ac-93c6-9c025c8a04e3/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md)

O processo documenta completamente o histórico de decisões anteriores, identifica gaps de comunicação entre IAs, e estabelece procedimentos replicáveis para futuras clonagens de VMs no ambiente.[ADR-001 - Redistribuição de Papéis e Responsabilidades das IAs.md+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/9c5d0ad8-ff06-4230-80ad-a8fd0fbc5cb0/ADR-001-Redistribuicao-de-Papeis-e-Responsabilidades-das-IAs.md)
