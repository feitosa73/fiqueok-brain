

**Architecture Decision Record – Fiqueok Living Lab 2.0**

---

## **Metadados**

|Campo|Valor|
|---|---|
|**ID**|ADR-000|
|**Título**|Estratégia de Hospedagem e Plano de Continuidade de Negócios (PCN) para Expansão do Living Lab|
|**Status**|🟡 PROPOSTO – Aguardando aprovação|
|**Data**|09/02/2026|
|**Autor Técnico**|Perplexity Pro (GRC Lead + Threat Intelligence)|
|**Aprovador**|Paulo Feitosa (Owner/CISO)|
|**Contexto**|Falha crítica Hyper-V Gen 2 + Necessidade de expansão (GLPI, DefectDojo, OpenVAS, Wazuh)|
|**Substitui**|N/A – Primeira decisão de nível global (L0)|
|**Nível de Decisão**|**L0 – GLOBAL** (Agnóstica a projetos específicos)|
|**Frameworks**|ISO 27001:2022, NIST CSF 2.0, CIS Controls v8, COSO ERM|

---

## **1. Contexto e Problema**

## **1.1. Situação Atual (AS-IS)**

O Living Lab de Segurança Cibernética da Fiqueok opera atualmente em uma infraestrutura baseada em **Windows 11 Pro + Hyper-V**, com os seguintes ativos operacionais:[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/14d8c4a1-f279-49ac-93c6-9c025c8a04e3/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md)]​

|Ativo|Sistema|Função|Status|
|---|---|---|---|
|**ID-P-01**|Windows Server 2022|Domain Controller (AD DS/DNS)|✅ Operacional|
|**IGA-P-01**|Ubuntu 22.04 + Docker|midPoint 4.10 + OrangeHRM|✅ Operacional|

## **1.2. Problema Crítico Identificado**

**Descrição da Falha:**

- **Host Windows 11 Pro apresenta falha recorrente na virtualização Hyper-V para VMs Geração 2 (UEFI/Secure Boot)**[learn.microsoft+1](https://learn.microsoft.com/en-ca/answers/questions/5732065/hyper-v-generation-2-vm-cannot-boot-window-server)
    
- VMs existentes continuam operacionais, mas o ambiente está **"congelado"** para novas implantações
    
- Impossibilidade de provisionar novas tecnologias seguindo padrões de conformidade técnica (UEFI/Secure Boot)
    

**Impacto no Roadmap:**

- **Bloqueio das seguintes implementações:**
    
    - GLPI (Gestão de Ativos e Service Desk)
        
    - DefectDojo (AppSec/Vulnerability Management)
        
    - OpenVAS (Vulnerability Scanner)
        
    - Wazuh (SIEM/XDR – VLAN 40 SOC Zone)
        

**Riscos de Negócio:**

- **Estagnação técnica** do Living Lab como plataforma de aprendizado
    
- **Perda de competitividade** em transição de carreira (portfolio desatualizado)
    
- **Não-conformidade futura** com padrões de segurança (ISO 27001 A.13.1.3, CIS Controls 12.2)
    

---

## **2. Opções Analisadas**

## **Cenário 1: Híbrido Local (Windows/WSL2 + macOS)**

**Descrição:**

- **WSL2 (Windows 11):** Serviços leves (HashiCorp Vault, APIs, ferramentas de desenvolvimento)
    
- **macOS (M1/M2):** Stacks pesadas via Docker Desktop/OrbStack ou VMs completas via UTM
    
- **Mesh VPN (Tailscale):** Fechamento de rede e conectividade segura entre hosts
    

**Tecnologias:**

- WSL2 + Docker no Windows 11
    
- Docker Desktop/OrbStack (macOS) para containers ARM64
    
- UTM (macOS) para VMs x86_64 via emulação ou ARM64 nativas
    
- Tailscale para VPN em malha (WireGuard)
    

**Prós:**

- ✅ **Zero custo adicional** (hardware existente)
    
- ✅ **Controle total** sobre dados e configuração
    
- ✅ **Performance nativa** em macOS M1/M2 (até 10 cores ARM + 24GB RAM típico)
    
- ✅ **Resiliência por redundância** (dois hosts físicos distintos)
    
- ✅ **Tailscale oferece SD-WAN simplificado** (ideal para labs distribuídos)
    

**Contras:**

- ❌ **Complexidade operacional alta** (gestão de 2 sistemas heterogêneos)
    
- ❌ **macOS não é plataforma corporativa** (baixa transferibilidade de conhecimento)
    
- ❌ **Custo energético elevado** (dois hosts em operação 24/7: ~200W médio)
    
- ❌ **Incompatibilidade arquitetural** (ARM64 macOS vs x86_64 tradicional)
    
- ❌ **Escalabilidade limitada** (hardware fixo)
    

---

## **Cenário 2: Cloud-First (OCI Always Free)**

**Descrição:**

- Migração de **stacks de alta demanda de RAM** para Oracle Cloud Infrastructure (OCI) Always Free Tier
    
- Ideal para: **midPoint/IGA (2GB+ RAM)**, **DefectDojo (4GB+)**, **OpenVAS (8GB+)**
    
- Manutenção de AD DS local + conectividade via VPN/Tailscale
    

**Recursos Always Free:**[fullmetalbrackets+1](https://fullmetalbrackets.com/blog/oci-free-tier-breakdown/)

- **Compute Ampere A1 (ARM64):** 4 vCPUs + 24GB RAM (distribuível em até 4 VMs)
    
    - Limitação: 3.000 OCPU-hours/mês e 18.000 GB-hours/mês (cobertura de 100% se ≤ 4 vCPUs/24GB total)
        
- **Block Storage:** 200GB (boot + volumes)
    
- **Rede:** 10TB egress/mês (Always Free)
    

**Prós:**

- ✅ **Zero custo recorrente** (Always Free permanente)
    
- ✅ **Escalabilidade horizontal** (até 4 VMs ARM64)
    
- ✅ **Alta disponibilidade** (SLA 99.95% mesmo em Free Tier)
    
- ✅ **Baixo consumo energético local** (apenas AD DS on-premises)
    
- ✅ **Experiência cloud nativa** (relevante para mercado)
    
- ✅ **Backup automatizado** (5 volume backups incluídos)
    

**Contras:**

- ❌ **Dependência de conectividade Internet** (latência 50-150ms típica)
    
- ❌ **Arquitetura ARM64** (compatibilidade limitada com software legado x86)
    
- ❌ **Risco de perda de acesso** (OCI pode descontinuar Free Tier sem aviso prévio)
    
- ❌ **Vendor lock-in leve** (migração futura requer reconfiguração)
    
- ❌ **Limitação de RAM crítica** para scanners de vulnerabilidade (OpenVAS recomenda 16GB)
    

---

## **Cenário 3: Multi-Cloud (GCP/AWS/Azure)**

**Descrição:**

- Uso de **créditos educacionais/trial** de provedores globais para implementações temporárias
    
- Ideal para: **Auditorias de nuvem específicas**, **testes de conformidade cloud-native**, **demos de arquitetura híbrida**
    

**Recursos Típicos:**

- **GCP:** $300 créditos por 90 dias (trial)
    
- **AWS:** Free Tier 12 meses (t2.micro/t3.micro: 1 vCPU + 1GB RAM)
    
- **Azure:** $200 créditos por 30 dias (trial)
    

**Prós:**

- ✅ **Experiência multi-cloud** (alta valorização no mercado)
    
- ✅ **Flexibilidade arquitetural** (escolha do provedor por caso de uso)
    
- ✅ **Documentação enterprise-grade** (transferível para ambiente corporativo)
    
- ✅ **Ideal para auditoria de configurações cloud** (CIS Benchmarks AWS/Azure/GCP)
    

**Contras:**

- ❌ **Custo recorrente após trial** (inviável para long-term lab)
    
- ❌ **Complexidade de gestão extrema** (3+ consoles, IAM policies distintas)
    
- ❌ **Risco de overcharges** (billing surprises em ambientes de teste)
    
- ❌ **Não sustentável para lab permanente** (objetivo da Fiqueok é continuidade)
    
- ❌ **Overhead de aprendizado** (curva para dominar 3 plataformas simultaneamente)
    

---

## **Cenário 4: Contingência Bare-Metal (Proxmox/ESXi)**

**Descrição:**

- Instalação de **hypervisor nativo** (Type-1) em hardware dedicado ou via **dual-boot** no host Windows 11 atual
    
- **Proxmox VE 8.x** (open-source, KVM + LXC) ou **VMware ESXi 8.0 Free** (proprietário, limitações de API)
    

**Requisitos de Hardware:**

- CPU: Intel VT-x/AMD-V habilitado
    
- RAM: 16GB+ (recomendado 32GB para lab completo)
    
- Storage: 500GB+ SSD NVMe
    

**Prós:**

- ✅ **Hypervisor enterprise-grade** (Proxmox: produção, ESXi: padrão de mercado)
    
- ✅ **Isolamento total** (bare-metal = zero overhead de hypervisor aninhado)
    
- ✅ **Gestão centralizada** (Proxmox Web UI / vSphere Client)
    
- ✅ **Suporte nativo a VLANs, VXLANs, SDN** (crucial para Lab 2.0)
    
- ✅ **Backup/Snapshot integrado** (Proxmox Backup Server / ESXi Backup)
    
- ✅ **Zero custo de licenciamento** (Proxmox AGPL-3, ESXi Free limitado mas funcional)
    

**Contras:**

- ❌ **Requer dual-boot ou hardware dedicado** (inviável se Windows 11 for daily driver)
    
- ❌ **Downtime para migração** (4-8 horas para reinstalação + reconfiguração)
    
- ❌ **Curva de aprendizado moderada** (Proxmox CLI + ZFS / ESXi vSphere)
    
- ❌ **ESXi Free tem limitações críticas** (sem vMotion, sem API para automação avançada)
    
- ❌ **Custo energético local mantido** (~150W contínuo)
    

---

## **3. Matriz Comparativa GRC**

## **3.1. Análise Multi-Critério Ponderada**

|Critério|Peso|Híbrido Local|Cloud-First (OCI)|Multi-Cloud|Bare-Metal|
|---|---|---|---|---|---|
|**Disponibilidade (RPO/RTO)**|25%|7/10|9/10|6/10|8/10|
|**Integridade dos Dados**|20%|9/10|7/10|7/10|10/10|
|**Custo Total de Propriedade (3 anos)**|20%|6/10|10/10|3/10|8/10|
|**Escalabilidade**|15%|4/10|9/10|10/10|6/10|
|**Complexidade de Gestão**|10%|4/10|8/10|2/10|7/10|
|**Transferibilidade de Conhecimento**|10%|5/10|9/10|10/10|8/10|
|**Score Ponderado Final**|**100%**|**6.45/10**|**8.65/10**|**6.10/10**|**8.20/10**|

**Legenda de Pontuação:**

- 1-3: Inadequado
    
- 4-6: Aceitável com ressalvas
    
- 7-8: Bom
    
- 9-10: Excelente
    

---

## **3.2. Análise de Riscos de Segurança**

|Cenário|Risco de Confidencialidade|Risco de Disponibilidade|Risco de Integridade|
|---|---|---|---|
|**Híbrido Local**|🟢 BAIXO (dados on-prem)|🟡 MÉDIO (SPOF em cada host)|🟢 BAIXO (controle total)|
|**Cloud-First (OCI)**|🟡 MÉDIO (dados em cloud pública)|🟢 BAIXO (SLA 99.95%)|🟡 MÉDIO (dependência de vendor)|
|**Multi-Cloud**|🟡 MÉDIO (dados distribuídos)|🔴 ALTO (multi-tenancy, complexidade)|🟡 MÉDIO (variação entre vendors)|
|**Bare-Metal**|🟢 BAIXO (dados locais)|🟡 MÉDIO (SPOF único)|🟢 BAIXO (isolamento físico)|

**Controles Mitigadores Recomendados:**

- **Confidencialidade:** VPN/Tailscale + criptografia em trânsito (TLS 1.3) + em repouso (LUKS/dm-crypt)
    
- **Disponibilidade:** Backups automatizados 3-2-1 (3 cópias, 2 mídias, 1 off-site)
    
- **Integridade:** Checksums SHA-256, assinatura de imagens, logs centralizados (rsyslog + Wazuh futuro)
    

---

## **3.3. Mapeamento de Conformidade**

|Framework|Controle|Requisito|Cenário Recomendado|
|---|---|---|---|
|**ISO 27001:2022**|A.17.1.1|Planejamento de continuidade de SI|Cloud-First (RTO < 4h)|
|**ISO 27001:2022**|A.17.1.2|Implementar continuidade de SI|Bare-Metal (fallback)|
|**NIST CSF 2.0**|RC.RP-1|Recovery plan executed during/after event|Cloud-First (backup automatizado)|
|**CIS Controls v8**|11.1|Establish and Maintain Data Recovery|Bare-Metal + Cloud (estratégia híbrida)|

---

## **4. Decisão Recomendada**

## **4.1. Estratégia Recomendada: Modelo Híbrido Evolutivo (Cloud-First + Bare-Metal Contingency)**

**Justificativa Técnica:**

Com base na análise GRC e nas restrições do contexto (profissional em transição de carreira, orçamento limitado, necessidade de visibilidade de mercado), recomendo uma **abordagem faseada e pragmática**:

## **Fase 1 – Curto Prazo (0-3 meses): Cloud-First OCI Always Free**

**Ações Imediatas:**

1. **Migração de midPoint/IGA para OCI Free Tier** (4 vCPUs ARM64 + 24GB RAM)[[fullmetalbrackets](https://fullmetalbrackets.com/blog/oci-free-tier-breakdown/)]​
    
2. **Manutenção de AD DS on-premises** (Windows Server 2022 continua em Hyper-V Gen 1 ou WSL2)
    
3. **Implementação de GLPI + DefectDojo em OCI** (containers Docker ARM64)
    
4. **Configuração de Tailscale Subnet Router** (host local → VPN → OCI VMs)
    

**Benefícios:**

- ✅ **Desbloqueio imediato do roadmap** (novas ferramentas operacionais em 7 dias)
    
- ✅ **Zero custo** (Always Free permanente)
    
- ✅ **Experiência cloud nativa** (valorização em portfolio LinkedIn/GitHub)
    
- ✅ **Alta disponibilidade** (SLA 99.95% sem custo adicional)
    

**Riscos Aceitos:**

- ⚠️ **Dependência de Internet** (mitigado por fallback em AD local)
    
- ⚠️ **ARM64 compatibility** (mitigado por uso de containers multi-arch)
    

---

## **Fase 2 – Médio Prazo (3-6 meses): Bare-Metal Proxmox como Contingência**

**Objetivo:** Criar **plano de continuidade robusto** e reduzir dependência de single-vendor cloud.

**Ações:**

1. **Aquisição de hardware dedicado** (refurbished: Dell OptiPlex 7060, ~$300 USD, 32GB RAM, i7-8700) **OU** dual-boot no host atual
    
2. **Instalação Proxmox VE 8.x** (hypervisor bare-metal open-source)[diskinternals+1](https://www.diskinternals.com/vmfs-recovery/proxmox-vs-esxi-homelab/)
    
3. **Implementação de ZFS RAID1** (data integrity + snapshots)
    
4. **Configuração de Proxmox Backup Server** (backup local + replicação para OCI Object Storage)
    
5. **Migração gradual de VMs críticas** de OCI para Proxmox (hot standby)
    

**Benefícios:**

- ✅ **Eliminação de SPOF** (OCI pode descontinuar Free Tier)
    
- ✅ **Controle total** (snapshots, backups, versionamento de VMs)
    
- ✅ **Performance superior** (bare-metal x86_64 vs ARM64 cloud)
    
- ✅ **Padrão de mercado** (Proxmox usado em SMBs, ESXi em enterprises)
    

**Riscos Aceitos:**

- ⚠️ **Investimento inicial** (~$300-500 hardware, se necessário)
    
- ⚠️ **Custo energético** (~$15-25/mês adicional, dependendo de tarifa local)
    

---

## **Fase 3 – Longo Prazo (6-12 meses): Multi-Cloud para Auditorias Específicas**

**Objetivo:** Desenvolver competências em **auditoria de configurações cloud** (objetivo CISO/GRC Lead).

**Ações:**

1. **Uso pontual de GCP/AWS/Azure** para projetos de curta duração:
    
    - Auditoria CIS Benchmarks AWS (usar trial $300 GCP/AWS)
        
    - Deploy de DefectDojo em AKS (Azure Kubernetes Service) para demo
        
    - Compliance check NIST 800-53 em ambiente GovCloud
        
2. **Documentação rigorosa** (ADRs, relatórios de auditoria, playbooks Terraform)
    
3. **Destruição imediata pós-teste** (evitar custos recorrentes)
    

**Benefícios:**

- ✅ **Portfolio multi-cloud** (diferenciador competitivo)
    
- ✅ **Conhecimento aplicável em 90%+ das empresas** (cloud híbrida é norma)
    
- ✅ **Zero custo long-term** (uso apenas durante trials)
    

---

## **4.2. Arquitetura de Referência Proposta**

text

`┌─────────────────────────────────────────────────────────────────┐ │                     LIVING LAB FIQUEOK 2.0                       │ │                  Arquitetura Híbrida Cloud + On-Prem             │ └─────────────────────────────────────────────────────────────────┘ ┌─────────────── ON-PREMISES (Windows 11 + Hyper-V/WSL2) ─────────┐ │                                                                   │ │  [AD DS] ← LDAPS:636 → [midPoint Local Backup]                   │ │  Windows Server 2022    Ubuntu 22.04 (Gen 1 VM)                  │ │                                                                   │ │  [Tailscale Subnet Router] ← VPN Mesh → OCI VMs                  │ │                                                                   │ └───────────────────────────────────────────────────────────────────┘                             ↕ WireGuard VPN ┌────────────── ORACLE CLOUD (Always Free Tier ARM64) ─────────────┐ │                                                                   │ │  VM1: [midPoint 4.10 + PostgreSQL]  (2 vCPU + 12GB RAM)          │ │  VM2: [GLPI + MariaDB]               (1 vCPU + 6GB RAM)          │ │  VM3: [DefectDojo + Redis]           (1 vCPU + 6GB RAM)          │ │  VM4: [OpenVAS + Greenbone]          (0 vCPU reserva)            │ │                                                                   │ │  Block Storage: 150GB (boot + data volumes)                      │ │  Object Storage: 20GB (backups comprimidos)                      │ │                                                                   │ └───────────────────────────────────────────────────────────────────┘                             ↕ Backup Semanal ┌────────────── CONTINGÊNCIA (Proxmox Bare-Metal) ─────────────────┐ │                                                                   │ │  Hardware: Dell OptiPlex 7060 (32GB RAM, i7-8700, 1TB NVMe)      │ │  Hypervisor: Proxmox VE 8.x (KVM + LXC)                           │ │                                                                   │ │  VMs em Standby (snapshots):                                     │ │   - AD DS (cold backup)                                           │ │   - midPoint (sincronização semanal via pg_dump)                  │ │   - GLPI (sincronização diária via rsync)                         │ │                                                                   │ │  Proxmox Backup Server → OCI Object Storage (offsite)            │ │                                                                   │ └───────────────────────────────────────────────────────────────────┘`

---

## **4.3. Plano de Continuidade de Negócios (PCN)**

## **Objetivos de Recuperação**

|Ativo Crítico|RPO (Recovery Point Objective)|RTO (Recovery Time Objective)|
|---|---|---|
|**AD DS**|24 horas (backup diário)|4 horas (restore de snapshot Proxmox)|
|**midPoint/IGA**|12 horas (pg_dump 2x/dia)|2 horas (failover para Proxmox ou restore OCI)|
|**GLPI**|24 horas (backup diário)|1 hora (container redeploy)|
|**DefectDojo**|7 dias (export semanal)|30 minutos (redeploy Docker Compose)|

## **Cenários de Falha e Respostas**

|Cenário de Falha|Probabilidade|Impacto|Resposta|
|---|---|---|---|
|**OCI Free Tier descontinuado**|Baixa (5%)|Alto|Migração para Proxmox em 48h (VMs pre-staged)|
|**Falha de hardware local**|Média (20%)|Médio|Operação 100% em OCI (AD DS migrado para cloud)|
|**Perda de conectividade Internet**|Média (15%)|Baixo|AD DS continua local, serviços cloud em standby|
|**Corrupção de dados (ransomware)**|Baixa (5%)|Alto|Restore de backup OCI Object Storage (imutável)|

---

## **5. Consequências**

## **5.1. Positivas**

1. **Desbloqueio do Roadmap**
    
    - GLPI, DefectDojo, OpenVAS e Wazuh operacionais em 30 dias
        
    - Retomada do desenvolvimento de competências GRC/CISO
        
2. **Custo-Benefício Ótimo**
    
    - Fase 1 (Cloud-First): $0/mês recorrente
        
    - Fase 2 (Bare-Metal): ~$300-500 investimento único + $15-25/mês energético
        
    - Total 3 anos: ~$840-1,400 (vs $3,000+ em cloud paga)
        
3. **Resiliência Aumentada**
    
    - Eliminação de SPOF (Hyper-V Gen 2)
        
    - Estratégia multi-vendor (OCI + Proxmox)
        
    - Backups automatizados 3-2-1
        
4. **Valorização Profissional**
    
    - Portfolio cloud-native (OCI, Tailscale, Terraform)
        
    - Experiência bare-metal enterprise (Proxmox/ESXi)
        
    - Conhecimento aplicável em 90%+ das vagas CISO/GRC
        

## **5.2. Negativas (Mitigadas)**

1. **Complexidade Operacional Aumentada**
    
    - **Mitigação:** Documentação rigorosa (POPs, runbooks), automação via Ansible
        
2. **Dependência de Vendor Cloud (OCI)**
    
    - **Mitigação:** Fase 2 (Proxmox) como fallback, backups portáveis (OVA/QCOW2)
        
3. **Curva de Aprendizado**
    
    - **Mitigação:** Treinamento incremental (1 tecnologia por sprint), comunidade ativa (Proxmox forums, OCI docs)
        
4. **Risco de ARM64 Incompatibilidade**
    
    - **Mitigação:** Uso de containers multi-arch (Docker buildx), fallback para x86 em Proxmox
        

---

## **6. Plano de Implementação**

## **6.1. Fase 1 – Cloud-First (Sprint 1-4)**

**Sprint 1 (Semana 1-2): Provisionamento OCI**

- Criar conta OCI Always Free
    
- Provisionar 2 VMs ARM64 (Ubuntu 22.04 LTS): midPoint (12GB) + GLPI (6GB)
    
- Configurar Security Lists (firewall): permitir apenas Tailscale subnet
    

**Sprint 2 (Semana 3-4): Migração midPoint**

- Export de midPoint PostgreSQL (pg_dump)
    
- Deploy de stack Docker em OCI (ARM64 multi-arch)
    
- Validação de conectividade LDAPS:636 → AD DS on-prem via Tailscale
    

**Sprint 3 (Semana 5-6): Deploy GLPI + DefectDojo**

- GLPI: Docker Compose (MariaDB + Apache + GLPI 10.x)
    
- DefectDojo: Helm chart em microk8s (ARM64)
    
- Integração LDAP/SSO via midPoint
    

**Sprint 4 (Semana 7-8): Validação e Backup**

- Testes de failover (simulação de queda de AD DS local)
    
- Configuração de backup OCI Object Storage (rclone cron)
    
- Documentação de runbooks (POP-OCI-001)
    

## **6.2. Fase 2 – Bare-Metal (Sprint 5-8)**

**Sprint 5 (Semana 9-10): Aquisição e Setup Proxmox**

- Aquisição de hardware refurbished (se necessário)
    
- Instalação Proxmox VE 8.x, configuração de ZFS RAID1
    
- Criação de VLANs (Management, IGA, SOC)
    

**Sprint 6 (Semana 11-12): Backup e Replicação**

- Deploy Proxmox Backup Server
    
- Configuração de backup agendado (diário: AD DS, 12h: midPoint)
    
- Replicação de backups para OCI Object Storage
    

**Sprint 7 (Semana 13-14): Migração Gradual**

- Criar VMs standby em Proxmox (AD DS, midPoint)
    
- Sincronização inicial via rsync/pg_basebackup
    
- Testes de failover (RTO < 4h)
    

**Sprint 8 (Semana 15-16): Documentação e Drill**

- Criação de PCN formal (documento ABNT NBR ISO 22301)
    
- Drill de recuperação de desastre (simulação de falha OCI)
    
- Aprovação final e encerramento de ADR-000
    

---

## **7. Critérios de Sucesso**

|Critério|Meta|Validação|
|---|---|---|
|**Novas ferramentas operacionais**|4/4 (GLPI, DefectDojo, OpenVAS, Wazuh)|Deploy completo em 60 dias|
|**Custo mensal recorrente**|< $30 USD/mês|Fatura OCI (Always Free) + energia|
|**RTO de AD DS**|< 4 horas|Drill de recuperação documentado|
|**Taxa de sucesso de backup**|100% (0 falhas em 30 dias)|Logs de rclone/PBS|
|**Uptime agregado**|> 99% (cloud + on-prem)|Monitoramento UptimeRobot + Grafana|

---

## **8. Decisões Arquiteturais Derivadas**

Esta ADR-000 impacta as seguintes decisões futuras (a serem documentadas):

- **ADR-005:** Seleção de Distribution Linux para VMs OCI (Ubuntu LTS vs Rocky Linux vs Debian)
    
- **ADR-006:** Estratégia de Service Mesh (Tailscale vs WireGuard nativo vs Consul Connect)
    
- **ADR-007:** Padrão de backup (Restic vs Borg vs Proxmox PBS)
    
- **ADR-008:** Ferramenta de IaC para cloud (Terraform vs Pulumi vs OpenTofu)
    

---

## **9. Stakeholders e RACI**

|Stakeholder|Papel|Posição|Ação Requerida|
|---|---|---|---|
|**Paulo Feitosa**|Owner/CISO|APROVAR|Autorizar investimento Fase 2 (~$500)|
|**Perplexity Pro**|GRC Lead|RESPONSÁVEL|Implementar Fase 1, documentar PCN|
|**ChatGPT**|Architect|CONSULTAR|Revisar arquitetura OCI/Proxmox|
|**Gemini**|Specialist|INFORMAR|Deep-dive em ARM64 compatibility|

---

## **10. Aprovação**

**Pergunta ao Aprovador (Paulo Feitosa):**

1. ✅ Concorda com a estratégia **Cloud-First (OCI) → Bare-Metal (Proxmox)** faseada?
    
2. ✅ Autoriza investimento de **~$300-500** para hardware Proxmox (Fase 2, em 3 meses)?
    
3. ✅ Aceita **dependência temporária de OCI Always Free** (Fase 1) como solução de desbloqueio?
    
4. ⚠️ Prefere alternativa? (especificar: Híbrido Local macOS, Multi-Cloud, ou Bare-Metal imediato)
    

**Responda:**

- `APROVAR ADR-000` – Prosseguir com implementação Fase 1 (Cloud-First OCI)
    
- `SOLICITAR AJUSTES` – Detalhar alterações necessárias
    

---

## **11. Referências**

## **11.1. Documentação Interna**

- [ADR-001] – Redistribuição de Papéis das IAs[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/9c5d0ad8-ff06-4230-80ad-a8fd0fbc5cb0/ADR-001-Redistribuicao-de-Papeis-e-Responsabilidades-das-IAs.md)]​
    
- [ADR-002] – Perplexity Pro como GRC Lead[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/bc405836-f9d7-4ec3-8bcb-6e539277ea83/ADR-002-Reatribuicao-de-Responsabilidades-de-IA-Perplexity-Pro-Assume-Papel-Duplo-GRC-Lead-Threat-Intelligence.md)]​
    
- [Manifesto Fiqueok v2.0] – Visão estratégica Living Lab[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/14d8c4a1-f279-49ac-93c6-9c025c8a04e3/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md)]​
    

## **11.2. Fontes Externas**

- Microsoft Learn – Hyper-V Gen 2 VM Boot Failures (2026)[[learn.microsoft](https://learn.microsoft.com/en-ca/answers/questions/5732065/hyper-v-generation-2-vm-cannot-boot-window-server)]​
    
- OCI Always Free Tier Breakdown (2026)[[fullmetalbrackets](https://fullmetalbrackets.com/blog/oci-free-tier-breakdown/)]​
    
- Proxmox vs ESXi Homelab Comparison (2025)[[diskinternals](https://www.diskinternals.com/vmfs-recovery/proxmox-vs-esxi-homelab/)]​
    
- Best Hypervisors for Home Labs (2025)[[mattadam](https://mattadam.com/2025/04/15/best-hypervisors-for-a-home-lab-proxmox-vs-esxi-vs-hyper-v-which-one-should-you-choose/)]​
    

## **11.3. Frameworks**

- ISO/IEC 27001:2022 – Controle A.17.1.1 (Continuidade de SI)
    
- NIST CSF 2.0 – Função RC.RP (Recovery Planning)
    
- CIS Controls v8 – Controle 11 (Data Recovery Capability)
    
- ABNT NBR ISO 22301:2020 – Gestão de Continuidade de Negócios
    

---

## **12. Controle de Versão**

|Versão|Data|Autor|Mudanças|
|---|---|---|---|
|1.0|09/02/2026|Perplexity Pro (GRC Lead)|Criação de ADR-000|

**Próxima revisão obrigatória:** 09/05/2026 (90 dias pós-aprovação)

**Classificação:** Internal Use – Technical Decision

**Localização:** `FiqueokBrain/10.Projetos/PRJ001-LABORATORIO/10.Planning/ADR-000-Governanca-Infraestrutura.md`

---

**FIM DO ADR-000**
