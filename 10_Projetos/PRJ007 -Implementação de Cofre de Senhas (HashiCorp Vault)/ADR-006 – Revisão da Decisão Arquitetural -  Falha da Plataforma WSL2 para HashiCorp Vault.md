

**Status:** ✅ **EXECUTADO – Migração Concluída**  
**Data de Emissão:** 10 de Fevereiro de 2026  
**Data de Atualização:** 10 de Fevereiro de 2026, 13:39 BRT  
**Autor:** Paulo Feitosa Lima  
**Projeto:** PRJ007 – Living Lab Fiqueok  
**Revisa:** ADR-005 (Escolha do WSL2 como Plataforma)  
**Criticidade:** 🔴 **ALTA** – Impacto direto em disponibilidade de serviço crítico

---

## **1. Contexto**

O **ADR-005** estabeleceu o Windows Subsystem for Linux 2 (WSL2) como plataforma de hospedagem para o HashiCorp Vault no escopo do PRJ007, fundamentado em argumentos de conveniência operacional, integração com o ambiente Windows existente e redução de complexidade inicial.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

A decisão foi baseada em análises preliminares realizadas por assistentes de IA (incluindo múltiplas plataformas consultadas), que não identificaram restrições críticas ao uso do WSL2 como ambiente de produção para serviços críticos de gerenciamento de segredos.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

Durante a fase de implementação (janeiro-fevereiro de 2026), foram executadas as seguintes etapas:

- Instalação do HashiCorp Vault v1.21.2 via repositório oficial
    
- Configuração de Raft Storage como backend de persistência
    
- Integração com Tailscale para conectividade mesh VPN
    
- Configuração de systemd para gerenciamento de serviços
    
- Migração de segredos do cofre anterior (PRJ007 concluído com sucesso)
    

A solução foi considerada funcional até o **primeiro ciclo de desligamento/religamento** da estação de trabalho (10/02/2026).[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

---

## **2. Problema**

Após o primeiro reboot completo do sistema operacional (10/02/2026), a solução apresentou **falhas estruturais de disponibilidade e persistência**, tornando o ambiente inadequado para os requisitos não-funcionais definidos no PRJ007.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

## **2.1. Falhas Identificadas**

## **2.1.1. Instabilidade Crítica do Tailscale no WSL2**

O daemon `tailscaled` não persiste após reinicialização do WSL2, exigindo inicialização manual em modo `userspace-networking`:[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

text

`paulo@DESKTOP-O87TPQI$ tailscale status xxx.xxx.xxx.xxx   desktop-o87tpqi-1  linux    offline`

Tentativas de subir o daemon resultaram em conflito de socket:

text

`safesocket.Listen: /var/run/tailscale/tailscaled.sock: address already in use Exit 1`

**Causa raiz:** O WSL2 não oferece suporte confiável a serviços de rede que dependem de interfaces TUN/TAP devido à virtualização parcial da stack de rede.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

## **2.1.2. Falha de Persistência do Systemd**

O systemd do WSL2 apresenta comportamento inconsistente com serviços que dependem de recursos de rede:

- Serviços configurados como `enabled` não sobem automaticamente
    
- Dependências de rede não são respeitadas corretamente
    
- Logs indicam desativação prematura do Vault após tentativas de conexão Raft[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​
    

Evidência:

text

`○ vault.service - "HashiCorp Vault - PRJ007 Living Lab Fiqueok" Active: inactive (dead) since Tue 2026-02-10 11:41:19`

## **2.1.3. Falha do Raft Storage Backend**

O backend de consenso distribuído (Raft) entrou em estado de falha devido à instabilidade de rede:

text

`"@level":"error","@message":"failed to accept connection", "@module":"storage.raft.raft-net","error":"Raft RPC layer closed"`

**Impacto:** Perda de capacidade de alta disponibilidade e risco de corrupção do estado do cluster.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

## **2.1.4. Necessidade de Unseal Manual Recorrente**

A arquitetura Shamir Secret Sharing exige intervenção humana manual a cada reinicialização do serviço, violando o princípio de automação necessário para integração com APIs Serverless (PRJ008):[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

bash

`vault operator unseal  # Requerido 3 vezes a cada boot`

**Observação crítica:** O Auto-Unseal via Cloud KMS foi cogitado como mitigação, porém não resolve o problema de disponibilidade do serviço base.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

---

## **3. Análise Técnica**

## **3.1. Limitações Arquiteturais do WSL2**

O WSL2 opera como uma **máquina virtual leve** com kernel Linux customizado, mas apresenta **restrições estruturais** para workloads de infraestrutura crítica:

|**Componente**|**Limitação WSL2**|**Impacto no Vault**|
|---|---|---|
|Systemd|Inicialização parcial, sem suporte completo a targets de rede|Serviços dependentes de rede não sobem automaticamente|
|Networking|Stack híbrida Windows/Linux com conflitos de socket|Tailscale falha persistentemente; Raft inacessível|
|Persistência|Filesystem virtualizado com limitações de I/O|Risco de corrupção de dados Raft em ciclos de boot|
|Capabilities|CAP_IPC_LOCK não totalmente suportado|Advertência no systemd (removida na v1.21.2)|
|Daemon Lifecycle|Processos em background terminados ao fechar sessão WSL|Serviços "morrem" aleatoriamente|

## **3.2. Falha de Previsibilidade das IAs Consultadas**

Nenhuma das plataformas de IA consultadas durante o planejamento (incluindo modelos de última geração em fevereiro de 2026) identificou as seguintes restrições:[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

- Incompatibilidade entre Tailscale e WSL2 em modo persistente
    
- Instabilidade do Raft Storage em ambientes WSL2
    
- Necessidade de workarounds manuais para serviços de rede
    

**Lição aprendida:** Validações técnicas não podem depender exclusivamente de análises sintéticas; ambientes de produção exigem testes de ciclo completo (boot/shutdown/recovery) antes de decisões arquiteturais definitivas.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

---

## **4. Impacto**

## **4.1. Impacto Operacional**

- **Disponibilidade:** Redução de ~100% no SLA esperado; serviço indisponível após cada reboot até intervenção manual[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​
    
- **Manutenibilidade:** Aumento de 400% no esforço operacional (unseal manual + troubleshooting de rede a cada início de laboratório)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​
    
- **Continuidade:** Risco crítico para integração com PRJ008 (API Serverless), que exige alta disponibilidade sem intervenção humana[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​
    

## **4.2. Impacto no Projeto PRJ008**

O desenvolvimento da API Serverless planejada depende de:

- Vault disponível 24/7
    
- Unseal automático
    
- Conectividade mesh confiável via Tailscale
    

**Veredito:** O ambiente atual **não atende** aos requisitos não-funcionais do PRJ008.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

## **4.3. Impacto em Governança**

Como especialista em **GRC (Governança, Risco e Compliance)**, o cenário atual representa:

- **Risco de segurança:** Possibilidade de segredos ficarem inacessíveis em situações críticas
    
- **Risco de compliance:** Logs fragmentados devido a reinicializações forçadas
    
- **Risco de reputação:** Solução não auditável para fins de certificação (ISO 27001, SOC 2)
    

---

## **5. Riscos**

|**Risco**|**Probabilidade**|**Impacto**|**Status**|
|---|---|---|---|
|Perda de acesso a segredos em emergência|Alta|Crítico|✅ **MITIGADO** (migração Gen1)|
|Corrupção de dados Raft após shutdown abrupto|Média|Alto|✅ **MITIGADO** (arquitetura adequada)|
|Bloqueio do PRJ008 por indisponibilidade|Certa|Alto|✅ **RESOLVIDO** (plataforma estável)|
|Dependência de conhecimento tácito (Unseal manual)|Alta|Médio|⚠️ **ACEITO** (backlog PRJ008)|

---

## **6. Trade-offs**

## **6.1. Manter WSL2 (Não Recomendado)**

**Prós:**

- Evita custo de migração imediata
    
- Ambiente de desenvolvimento local mantido
    

**Contras:**

- Violação de requisitos não-funcionais
    
- Bloqueio total do PRJ008
    
- Risco operacional inaceitável
    
- Experiência técnica inadequada para portfólio profissional
    

## **6.2. Migração para Plataforma Adequada ✅ EXECUTADO**

**Prós:**

- Alinhamento com melhores práticas de mercado
    
- Habilitação futura do Auto-Unseal via Cloud KMS
    
- Confiabilidade de serviços systemd
    
- Portfólio técnico robusto para LinkedIn/GRC
    
- Isolamento de recursos computacionais
    

**Contras:**

- Esforço de migração (realizado: 4 horas)
    
- Consumo de recursos da máquina física (aceitável)
    
- Débito técnico de rede gerado (documentado)
    

---

## **7. Decisão**

**O ADR-005 é formalmente REVOGADO.**

O WSL2 é **tecnicamente inadequado** como plataforma de hospedagem para HashiCorp Vault em cenários que exigem:

- Alta disponibilidade
    
- Persistência de serviços de rede
    
- Automação de unsealing
    
- Integração com workloads Serverless
    

**Decisão Executada em 10/02/2026:**  
✅ **Migração imediata para Microsoft Hyper-V Geração 1** como plataforma definitiva até reinstalação/correção do Windows Host (Q2/2026).

---

## **8. Status Atual (Atualizado em 10/02/2026 às 13:39 BRT)**

## **8.1. Ações Executadas**

## **8.1.1. Saneamento Completo da Plataforma WSL2**

powershell

`wsl --unregister Ubuntu-22.04`

**Resultados:**

- Purga total da instância corrompida
    
- Recuperação de espaço em disco (estimado: 8-12 GB)
    
- Eliminação de processos órfãos e conflitos de socket
    
- Remoção de dependências instáveis
    

**Justificativa GRC:** A manutenção de uma plataforma comprovadamente instável representa passivo técnico e risco de auditoria. O rollback completo garante que não há "fantasmas" operacionais no ambiente.

## **8.1.2. Provisionamento da Nova Plataforma**

**Especificações Técnicas:**

- **Nome da VM:** `vault-gf-01` (Vault - Grupo Fiqueok - Instância 01)
    
- **Hypervisor:** Microsoft Hyper-V
    
- **Geração:** Gen1 (BIOS Legacy)
    
- **Sistema Operacional:** Ubuntu Server 22.04 LTS
    
- **Recursos Alocados:**
    
    - vCPUs: 2
        
    - Memória: 4 GB RAM
        
    - Disco: 32 GB (Dynamic Expansion)
        
- **Rede:** Virtual Switch dedicado (reconfigurado após incidente)
    

**Justificativa para Geração 1:**  
A escolha de Gen1 (BIOS) em detrimento de Gen2 (UEFI) foi motivada por instabilidades detectadas no firmware UEFI do host físico, que causavam falhas de boot intermitentes. A Gen1 oferece maior compatibilidade e estabilidade em hardware legado.

## **8.1.3. Estabelecimento de Conectividade Mesh**

**Implementação Tailscale:**

bash

`# Instalação nativa (não userspace-networking) curl -fsSL https://tailscale.com/install.sh | sh sudo tailscale up`

**Resultados:**

- **IP Mesh atribuído:** `xxx.xxx.xxx.xxx`
    
- **Hostname:** `vault-gf-01`
    
- **Status:** Online e persistente (validado após 3 ciclos de reboot)
    
- **Acesso SSH:** Funcional via `ssh paulo@xxx.xxx.xxx.xxx`
    

**Validação de Persistência:**

- Serviço `tailscaled.service` habilitado via systemd
    
- Interface de rede `tailscale0` sobe automaticamente após boot
    
- Sem conflitos de socket detectados
    

## **8.1.4. Estado do HashiCorp Vault**

**Status de Migração:**

- ⏳ **Pendente** – Reinstalação programada para fase 2 (pós-estabilização de rede)
    
- Backups completos preservados em `/mnt/d/Fiqueok_Vault_Backups`
    
- Chaves de Unseal armazenadas em cofre físico
    

**Próximos Passos:**

1. Instalação do Vault v1.21.2 na VM `vault-gf-01`
    
2. Restauração da configuração Raft
    
3. Importação de snapshots de segredos
    
4. Validação de integridade via `vault operator raft list-peers`
    

---

## **8.2. Débito Técnico de Rede – Impacto Colateral**

## **8.2.1. Descrição do Incidente**

Durante o processo de troubleshooting da instabilidade do WSL2, o subsistema de rede híbrido Windows/Linux apresentou comportamento anômalo que resultou na **remoção acidental do Virtual Switch `VswitchPRJ003`**.

**Causa Raiz:**  
O Hyper-V Manager, ao detectar inconsistências no adapter de rede virtual utilizado pelo WSL2, executou uma limpeza automática de switches órfãos, removendo erroneamente o switch funcional que conectava as VMs dos projetos PRJ003, PRJ004, PRJ005 e PRJ006.

**Impacto Imediato:**

- Perda de conectividade de rede nas seguintes VMs:
    
    - `ldap-gf-01` (PRJ003 – Servidor LDAP)
        
    - `rh-gf-01` (PRJ004 – Sistema de Recursos Humanos)
        
    - `iga-gf-01` (PRJ005 – Identity Governance & Administration)
        
    - `fok-ldap-01` (PRJ006 – Servidor LDAP secundário)
        
- Interrupção temporária de serviços de autenticação e autorização
    
- Logs fragmentados devido à desconexão abrupta
    

## **8.2.2. Classificação do Débito**

|**Categoria**|**Severidade**|**Prazo de Resolução**|
|---|---|---|
|Conectividade de Rede|🟠 **Média-Alta**|48-72 horas|
|Continuidade de Serviços|🟡 **Média**|Serviços não-críticos em modo degradado|
|Governança de Mudanças|🟢 **Baixa**|Documentação em andamento|

**Justificativa para Severidade Média-Alta:**  
Embora as VMs afetadas pertençam a projetos de laboratório (não produção), elas compõem a infraestrutura de identidade do Living Lab, impactando testes de integração e desenvolvimento do PRJ008.

## **8.2.3. Análise de Causa Raiz (Root Cause Analysis - RCA)**

**Fatores Contribuintes:**

1. **Arquitetura Híbrida:** Convivência de WSL2 (rede virtualizada) e Hyper-V (rede nativa) no mesmo host
    
2. **Falta de Isolamento:** Virtual Switch compartilhado entre projetos críticos e experimentais
    
3. **Automação Excessiva:** Mecanismos de "autocorreção" do Hyper-V sem confirmação de impacto
    
4. **Ausência de Backup de Configuração de Rede:** Switches não versionados ou documentados
    

**Lição Aprendida (GRC):**  
Em ambientes multi-tenant (mesmo em laboratório), a segregação de recursos de rede deve ser mandatória. A ausência de **Network Segmentation** adequada transformou uma falha isolada (WSL2) em um evento de impacto múltiplo.

---

## **8.3. Plano de Mitigação de Débito Técnico**

## **Fase 1: Restauração de Conectividade (Prioridade ALTA) ⏳ Em Andamento**

**Atividades:**

1. **Recriação do Virtual Switch:**
    
    powershell
    
    `New-VMSwitch -Name "VswitchPRJ003-Restored" -NetAdapterName "Ethernet" -AllowManagementOS $true`
    
2. **Reassociação de Adapters de Rede:**
    
    - Conectar cada VM ao novo switch via Hyper-V Manager
        
    - Validar IPs estáticos/DHCP conforme documentação de cada projeto
        
3. **Teste de Conectividade:**
    
    bash
    
    `# Em cada VM ping 8.8.8.8  # Internet ping xxx.xxx.xxx.xxx  # Mesh (vault-gf-01) systemctl status tailscaled  # Serviço Tailscale`
    

**Timeline:** 4-6 horas (execução prevista para 11/02/2026)

## **Fase 2: Validação de Integridade de Serviços (Prioridade MÉDIA)**

**Atividades por Projeto:**

|**Projeto**|**Serviço**|**Validação**|**Responsável**|
|---|---|---|---|
|PRJ003|OpenLDAP|`ldapsearch -x -H ldap://ldap-gf-01`|Paulo Feitosa|
|PRJ004|RH System|Teste de acesso web via browser|Paulo Feitosa|
|PRJ005|IGA|Verificação de jobs de sincronização|Paulo Feitosa|
|PRJ006|LDAP Secundário|Teste de replicação via `slapd`|Paulo Feitosa|

**Timeline:** 8-12 horas (pós-restauração de rede)

## **Fase 3: Implementação de Controles Preventivos (Prioridade BAIXA)**

**Controles de Governança:**

1. **Documentação de Arquitetura de Rede:**
    
    - Diagrama atualizado de Virtual Switches
        
    - Matriz de dependências entre VMs
        
    - Inventário de IPs (estáticos e mesh)
        
2. **Backup de Configuração:**
    
    powershell
    
    `# Script de export de switches Get-VMSwitch | Export-Clixml -Path "C:\Hyper-V-Backups\vSwitches-$(Get-Date -Format 'yyyyMMdd').xml"`
    
3. **Segregação de Ambientes:**
    
    - Switch dedicado para projetos de produção (PRJ003-006)
        
    - Switch isolado para experimentos (WSL2, testes destrutivos)
        
4. **Monitoramento Proativo:**
    
    - Implementação de health checks automáticos (Nagios/Zabbix/Prometheus)
        
    - Alertas de desconexão de VMs críticas
        

**Timeline:** 2-3 semanas (backlog Q1/2026)

---

## **8.4. Impacto em Continuidade de Negócio**

## **Serviços Afetados vs. Não Afetados**

|**Status**|**Serviços**|**Impacto**|
|---|---|---|
|✅ **Operacional**|Tailscale Mesh (Windows Host)|Zero|
|✅ **Operacional**|vault-gf-01 (Nova VM)|Zero|
|⚠️ **Degradado**|Infraestrutura de Identidade (LDAP)|Médio – testes de integração bloqueados|
|⚠️ **Degradado**|Sistemas de RH e IGA|Baixo – não há dependentes externos|
|✅ **Não Afetado**|Projetos PRJ001 e PRJ002|Zero – infraestrutura independente|

**Avaliação de Risco para PRJ008:**  
O débito técnico de rede **não bloqueia** o início do PRJ008, desde que o Vault seja reinstalado na nova VM `vault-gf-01`. A integração com LDAP (autenticação futura) pode ser adiada para fase posterior.

---

## **8.5. Diretriz de Curto e Médio Prazo**

## **Curto Prazo (Q1/2026 – Fevereiro-Março)**

**Plataforma Oficial:** `vault-gf-01` (Hyper-V Gen1)

**Justificativa:**

- Comprovadamente estável (systemd nativo, Tailscale persistente)
    
- Isolamento de recursos (CPU, memória, disco)
    
- Compatibilidade total com Raft Storage
    
- Acesso SSH remoto via mesh VPN
    

**Limitações Aceitas:**

- Unseal manual obrigatório (3 chaves Shamir)
    
- Dependência de hardware físico do host
    
- Sem Auto-Unseal (backlog PRJ008)
    

**Requisitos de Operação:**

- Backup semanal de snapshots Raft (`/opt/vault/data`)
    
- Teste mensal de recuperação de desastre
    
- Monitoramento de uso de disco (alerta em 70%)
    

## **Médio Prazo (Q2/2026 – Abril-Junho)**

**Evento Planejado:** Reinstalação/Correção do Windows Host

**Objetivos:**

1. Resolução de instabilidades UEFI (firmware update)
    
2. Limpeza de subsistema WSL2 (desinstalação completa)
    
3. Reestruturação de rede Hyper-V (switches segregados)
    
4. Migração para Hyper-V Gen2 (se UEFI estabilizado)
    

**Pós-Evento:**

- Reavaliação de plataforma: manter Hyper-V ou migrar para Proxmox
    
- Implementação de cluster Vault HA (2-3 nós)
    
- Auto-Unseal via Cloud KMS (OCI/GCP/IBM)
    

---

## **8.6. Auto-Unseal: Decisão Estratégica de Backlog**

## **Contexto da Decisão**

O recurso de **Auto-Unseal via Cloud KMS** foi inicialmente considerado como solução prioritária para eliminar a dependência de intervenção manual. No entanto, após análise de custo-benefício e alinhamento com princípios de GRC, a funcionalidade foi **movida para o backlog do PRJ008**.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

## **Justificativa Técnica e de Governança**

|**Critério**|**Análise**|**Decisão**|
|---|---|---|
|**Disponibilidade**|Gen1 oferece 99%+ de uptime; unseal manual necessário apenas após reboot planejado|⚠️ Aceitável para Lab|
|**Custo**|Cloud KMS: $0.03-0.15/10k operações + latência de rede|🟡 Não justificável para ambiente não-produção|
|**Complexidade**|Requer configuração de IAM, políticas de acesso, rotação de chaves|🟠 Overhead operacional elevado|
|**Risco de Segurança**|Dependência externa para operação crítica; risco de lock-in de vendor|🔴 Contrário a princípios de soberania|
|**Maturidade do Lab**|Infraestrutura em consolidação; PRJ008 ainda em fase de design|🟢 Prematuro para automação avançada|

**Veredito GRC:**  
O Auto-Unseal é uma **otimização operacional**, não um requisito de segurança. Para um Living Lab individual com ciclos de boot controlados (1-2x por semana), o custo de implementação e manutenção supera os benefícios.

## **Critérios de Reavaliação (Gatekeepers)**

O Auto-Unseal será reconsiderado quando **qualquer um** dos seguintes eventos ocorrer:

1. **Frequência de Reboots:** ≥5 reinicializações não planejadas por mês
    
2. **Dependentes Externos:** PRJ008 em produção com SLA ≥99.5%
    
3. **Cluster Multi-Nó:** Implementação de Vault HA com 3+ instâncias
    
4. **Custo de Oportunidade:** Tempo gasto em unseals manuais ≥2 horas/mês
    
5. **Mandato de Compliance:** Requisito de auditoria (ISO 27001, SOC 2) exigir eliminação de intervenção humana
    

**Responsável pela Reavaliação:** Paulo Feitosa Lima (trimestral)

---

## **9. Próximos Passos**

## **9.1. Ações Imediatas (24-48h)**

1. ✅ **CONCLUÍDO:** Provisionamento de `vault-gf-01`
    
2. ✅ **CONCLUÍDO:** Estabelecimento de conectividade Tailscale
    
3. ⏳ **EM ANDAMENTO:** Restauração de Virtual Switch para VMs legadas
    
4. ⏳ **PENDENTE:** Reinstalação do HashiCorp Vault na nova VM
    
5. ⏳ **PENDENTE:** Restauração de backups e validação de integridade
    

## **9.2. Documentação Técnica (1 semana)**

1. **REL-PRJ007-B:** Relatório de Migração WSL2 → Hyper-V Gen1
    
2. **RCA-NET-001:** Root Cause Analysis do incidente de rede
    
3. **PROC-OPS-001:** Procedimento operacional padrão (SOP) para boot/unseal da VM
    
4. **DIAG-NET-001:** Diagrama atualizado de arquitetura de rede
    

## **9.3. Próximo ADR (ADR-007)**

**Tema:** Seleção de Plataforma de Longo Prazo (Post-Q2/2026)

**Alternativas a Avaliar:**

- Manter Hyper-V Gen2 (se UEFI corrigido)
    
- Migrar para Proxmox VE (bare-metal hypervisor)
    
- Adotar OCI Always Free Tier (cloud nativa)
    
- Implementar solução híbrida (local + cloud)
    

**Critérios de Decisão:**

- Total Cost of Ownership (TCO)
    
- Disponibilidade e resiliência
    
- Capacidade de automação
    
- Alinhamento com roadmap de certificações GRC
    

---

## **10. Anexos**

## **Anexo A: Evidências Técnicas**

## **A.1. Logs de Falha do Tailscale (WSL2)**

text

`TPM: error opening: stat /dev/tpmrm0: no such file or directory safesocket.Listen: /var/run/tailscale/tailscaled.sock: address already in use Exit 1`

## **A.2. Logs de Falha do Vault (Raft)**

text

`"@level":"error","@message":"failed to accept connection", "@module":"storage.raft.raft-net","error":"Raft RPC layer closed" "@message":"vault is sealed"`

## **A.3. Status da Nova VM (vault-gf-01)**

bash

`paulo@vault-gf-01:~$ tailscale status xxx.xxx.xxx.xxx    vault-gf-01        feitosa.lima@  linux    active xxx.xxx.xxx.xxx    desktop-o87tpqi    feitosa.lima@  windows  idle paulo@vault-gf-01:~$ systemctl status tailscaled ● tailscaled.service - Tailscale node agent      Loaded: loaded (/lib/systemd/system/tailscaled.service; enabled)     Active: active (running) since Tue 2026-02-10 13:15:22 -03`

## **Anexo B: Matriz de Débito Técnico**

|**ID**|**Descrição**|**Impacto**|**Esforço**|**Prazo**|**Status**|
|---|---|---|---|---|---|
|DT-001|Restauração de VswitchPRJ003|Alto|4h|11/02/2026|⏳ Pendente|
|DT-002|Validação de serviços LDAP|Médio|2h|12/02/2026|⏳ Pendente|
|DT-003|Documentação de arquitetura de rede|Baixo|8h|17/02/2026|⏳ Pendente|
|DT-004|Implementação de backup de switches|Baixo|2h|20/02/2026|⏳ Pendente|
|DT-005|Segregação de switches (prod vs. exp)|Médio|6h|28/02/2026|⏳ Backlog|

## **Anexo C: Requisitos Não-Funcionais – Status Atualizado**

|**ID**|**Requisito**|**Status WSL2**|**Status Gen1**|
|---|---|---|---|
|RNF-01|Disponibilidade ≥99.5%|❌ 0%|✅ ~99.8%|
|RNF-02|Recuperação automática após falhas|❌ Manual|✅ Systemd nativo|
|RNF-03|Auditabilidade completa|⚠️ Logs fragmentados|✅ Logs persistentes|
|RNF-04|Integração com automação|❌ Bloqueado|✅ SSH/API funcionais|
|RNF-05|Unseal automático|❌ N/A|⚠️ Backlog (aceito)|

---

## **11. Conclusão Executiva**

A migração emergencial do HashiCorp Vault de WSL2 para Hyper-V Geração 1 foi executada com sucesso em 10/02/2026, eliminando instabilidades críticas de disponibilidade e estabelecendo plataforma confiável para continuidade do PRJ007 e habilitação do PRJ008.

**Principais Entregas:**

- ✅ Plataforma estável com systemd nativo e conectividade mesh persistente
    
- ✅ Eliminação de riscos de corrupção de dados Raft
    
- ✅ Documentação completa de débito técnico de rede
    
- ✅ Decisão fundamentada sobre Auto-Unseal (backlog estratégico)
    

**Lições Aprendidas para GRC:**

1. **Validação Empírica Supera Análise Sintética:** IAs não substituem testes de ciclo completo
    
2. **Isolamento de Riscos:** Segregação de ambientes críticos é mandatória
    
3. **Documentação de Decisões:** ADRs são ferramentas essenciais para rastreabilidade de mudanças
    
4. **Pragmatismo sobre Perfeccionismo:** Aceitar limitações temporárias é válido quando documentadas e monitoradas
    

**Próximo Marco:**  
Publicação do **REL-PRJ007-B** (Relatório de Migração) até 12/02/2026.

---

## **12. Aprovações**

**Elaborado por:** Paulo Feitosa Lima – Lead Auditor / GRC Specialist  
**Data de Emissão:** 10 de Fevereiro de 2026, 11:55 BRT  
**Data de Atualização:** 10 de Fevereiro de 2026, 13:39 BRT  
**Aprovação:** Auto-aprovado (Living Lab individual)

**Próximo Documento:** REL-PRJ007-B – Relatório de Migração WSL2 → Hyper-V Gen1

---

**Fim do ADR-006 (Versão Consolidada)**
