
---

# 

**Status:** Aprovado  
**Data:** 10 de Fevereiro de 2026  
**Autor:** Paulo Feitosa Lima  
**Projeto:** PRJ007 – Living Lab Fiqueok  
**Revisa:** ADR-005 (Escolha do WSL2 como Plataforma)

---

## **1. Contexto**

O **ADR-005** estabeleceu o Windows Subsystem for Linux 2 (WSL2) como plataforma de hospedagem para o HashiCorp Vault no escopo do PRJ007, fundamentado em argumentos de conveniência operacional, integração com o ambiente Windows existente e redução de complexidade inicial.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

A decisão foi baseada em análises preliminares realizadas por assistentes de IA (incluindo múltiplas plataformas consultadas), que não identificaram restrições críticas ao uso do WSL2 como ambiente de produção para serviços críticos de gerenciamento de segredos.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

Durante a fase de implementação (janeiro-fevereiro de 2026), foram executadas as seguintes etapas:

- Instalação do HashiCorp Vault v1.21.2 via repositório oficial
    
- Configuração de Raft Storage como backend de persistência
    
- Integração com Tailscale para conectividade mesh VPN
    
- Configuração de systemd para gerenciamento de serviços
    
- Migração de segredos do cofre anterior (PRJ007 concluído)
    

A solução foi considerada funcional até o **primeiro ciclo de desligamento/religamento** da estação de trabalho.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

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

|**Risco**|**Probabilidade**|**Impacto**|**Mitigação Atual**|
|---|---|---|---|
|Perda de acesso a segredos em emergência|Alta|Crítico|Backups manuais em `/mnt/d/Fiqueok_Vault_Backups`|
|Corrupção de dados Raft após shutdown abrupto|Média|Alto|Nenhuma (arquitetura inadequada)|
|Bloqueio do PRJ008 por indisponibilidade|Certa|Alto|Necessidade de migração de plataforma|
|Dependência de conhecimento tácito (Unseal manual)|Alta|Médio|Documentação de procedimento|

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
    

## **6.2. Migração para Plataforma Adequada**

**Prós:**

- Alinhamento com melhores práticas de mercado
    
- Habilitação do Auto-Unseal via Cloud KMS
    
- Confiabilidade de serviços systemd
    
- Portfólio técnico robusto para LinkedIn/GRC
    

**Contras:**

- Esforço de migração (estimado: 4-8 horas)
    
- Possível custo de infraestrutura (mitigável com tier gratuito de clouds)
    

---

## **7. Decisão**

**O ADR-005 é formalmente REVOGADO.**

O WSL2 é **tecnicamente inadequado** como plataforma de hospedagem para HashiCorp Vault em cenários que exigem:

- Alta disponibilidade
    
- Persistência de serviços de rede
    
- Automação de unsealing
    
- Integração com workloads Serverless
    

**Decisão:** Migrar o HashiCorp Vault para uma plataforma de infraestrutura convencional até o início do PRJ008.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

---

## **8. Próximos Passos**

## **8.1. Alternativas Avaliadas para ADR-007**

## **Opção 1: Oracle Cloud Infrastructure (OCI) – Free Tier**

- **Características:** VM.Standard.A1.Flex (ARM) com 4 OCPUs + 24GB RAM (Always Free)
    
- **Vantagens:** Zero custo, hardware real, systemd completo, Auto-Unseal via OCI Vault Service
    
- **Desvantagens:** Latência de rede para acesso doméstico
    
- **Timeline:** 2-3 dias
    

## **Opção 2: Máquina Virtual Hyper-V Gen1 (Temporária)**

- **Características:** Ubuntu Server 22.04 LTS em VM Windows Hyper-V
    
- **Vantagens:** Acesso local, sem custo, ambiente isolado
    
- **Desvantagens:** Limitações de recursos da máquina física, sem Auto-Unseal nativo
    
- **Timeline:** 4-6 horas
    

## **Opção 3: Reinstalação do Windows + Bare Metal Linux**

- **Características:** Dual-boot ou Linux nativo
    
- **Vantagens:** Controle total, máximo desempenho
    
- **Desvantagens:** Perda temporária do ambiente Windows
    
- **Timeline:** 1-2 dias
    

## **Opção 4: Proxmox (Futuro Estado Desejado)**

- **Características:** Hypervisor bare-metal com LXC/VMs
    
- **Vantagens:** Infraestrutura profissional completa, clusters HA, backups automáticos
    
- **Desvantagens:** Requer hardware dedicado
    
- **Timeline:** 1-2 semanas
    

## **8.2. Recomendação Imediata**

**Caminho rápido (72h):** Opção 1 (OCI Free Tier)

- Criar conta OCI
    
- Provisionar VM ARM Always Free
    
- Migrar configuração do Vault
    
- Configurar Auto-Unseal via OCI Vault Service
    
- Validar conectividade Tailscale
    
- Iniciar PRJ008
    

**Caminho seguro (1 semana):** Opção 2 (Hyper-V) + Planejamento de migração para Opção 1

## **8.3. Ações Técnicas**

1. **Backup completo do estado atual** (já realizado em `/mnt/d/Fiqueok_Vault_Backups`)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​
    
2. **Exportação da configuração do Vault**:
    
    bash
    
    `vault operator raft list-peers vault secrets list -detailed vault auth list -detailed`
    
3. **Documentação das chaves de Unseal** (já existente, em cofre físico)
    
4. **Definição de plataforma alvo** → ADR-007
    
5. **Execução de migração** → REL-PRJ007-B (Relatório de Migração)
    

---

## **9. Anexos**

## **Anexo A: Evidências Técnicas**

## **A.1. Logs de Falha do Tailscale**

text

`TPM: error opening: stat /dev/tpmrm0: no such file or directory safesocket.Listen: /var/run/tailscale/tailscaled.sock: address already in use Exit 1`

## **A.2. Logs de Falha do Vault (Raft)**

text

`"@level":"error","@message":"failed to accept connection", "@module":"storage.raft.raft-net","error":"Raft RPC layer closed" "@message":"vault is sealed"`

## **A.3. Status do Serviço Após Reboot**

text

`○ vault.service - "HashiCorp Vault - PRJ007 Living Lab Fiqueok" Active: inactive (dead) since Tue 2026-02-10 11:41:19`

## **Anexo B: Procedimento de Workaround Manual (Não Sustentável)**

bash

`# 1. Iniciar daemon Tailscale sudo tailscaled --tun=userspace-networking --socks5-server=localhost:1055 & # 2. Ativar túnel sudo tailscale up # 3. Iniciar Vault sudo systemctl start vault # 4. Unseal manual (3 chaves) export VAULT_ADDR='http://127.0.0.1:8200' vault operator unseal  # (3x)`

**Tempo médio de recuperação:** 5-7 minutos por ciclo de boot.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​

## **Anexo C: Requisitos Não-Funcionais Violados (PRJ007)**

- **RNF-01:** Disponibilidade ≥99.5% → **FALHOU** (0% sem intervenção manual)
    
- **RNF-02:** Recuperação automática após falhas → **FALHOU** (unseal manual obrigatório)
    
- **RNF-03:** Auditabilidade completa → **COMPROMETIDO** (logs fragmentados)
    
- **RNF-04:** Integração com automação → **BLOQUEADO** (dependência humana)
    

---

## **10. Referências**

- [ADR-005] Decisão de Uso do WSL2 como Plataforma
    
- [REL-PRJ007] Relatório de Conclusão da Migração para Vault Nativo
    
- [PRJ008] Planejamento de API Serverless com Autenticação AppRole
    
- Histórico completo de problemas (10/02/2026)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/d717180f-2cfb-41a8-875d-4e3ac308ebf5/Historico-de-Problemas-com-a-solucao-Hashicorp-em-WSL.txt)]​
    
- HashiCorp Vault Documentation v1.21.2
    
- Tailscale in WSL2 Known Limitations (upstream issue tracker)
    

---

## **Assinaturas**

**Elaborado por:** Paulo Feitosa Lima – Lead Auditor / GRC Specialist  
**Data:** 10 de Fevereiro de 2026  
**Aprovação:** Auto-aprovado (Living Lab individual)

**Próximo documento:** ADR-007 – Seleção de Plataforma Definitiva para HashiCorp Vault

---

**Fim do ADR-006**
