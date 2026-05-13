#

**Documento:** ARQ-005  
**Versão:** 1.0  
**Data:** 27/12/2025  
**Responsável:** Paulo Feitosa (Owner) & Gemini Pro (Arquiteto CTO)  
**Revisor:** Claude 3.5 (Technical Writer & Auditor GRC)  
**Status:** 🟢 Aprovado para Implementação

---

## 1. Contexto Estratégico

Este memorial documenta a **transição arquitetural** do Living Lab Fiqueok 1.0 (rede flat) para o Living Lab 2.0 (segmentação por VLANs), estabelecendo as bases técnicas e de governança para a implementação da **Security Zone** dedicada à PKI corporativa (HashiCorp Vault).

A mudança representa o **pivô estratégico** entre a Fase 1.0 (circuito básico de identidade) e a Fase 2.0 (ecossistema GRC enterprise-grade), atendendo aos requisitos de **micro-segmentação de rede** exigidos por frameworks de conformidade.

---

## 2. Estado Atual (AS-IS) - Living Lab 1.0

### 2.1. Topologia de Rede

```
┌─────────────────────────────────────────────────────────────┐
│                    HOST WINDOWS 11 (Hyper-V)                │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │          vSwitch_Fiqueok_Corp (Internal)               │ │
│  │                 Subnet: xxx.xxx.xxx.xxx/16                  │ │
│  │                 Gateway: xxx.xxx.xxx.xxx (NAT)              │ │
│  └────────────────────────────────────────────────────────┘ │
│           │              │              │                    │
│           │              │              │                    │
│     ┌─────▼─────┐  ┌────▼────┐  ┌──────▼──────┐           │
│     │  ID-P-01  │  │ IGA-P-01│  │ (Futuras VMs)│           │
│     │ Win2022   │  │ Ubuntu  │  │              │           │
│     │ .10       │  │ .100    │  │              │           │
│     └───────────┘  └─────────┘  └──────────────┘           │
│          │              │                                    │
│     [AD DS/DNS]    [Docker Host]                           │
│                         │                                    │
│              ┌──────────┴──────────┐                        │
│              │                      │                        │
│       ┌──────▼──────┐      ┌───────▼────────┐              │
│       │  midPoint   │      │   OrangeHRM    │              │
│       │ 172.18.0.x  │      │   172.19.0.x   │              │
│       └─────────────┘      └────────────────┘              │
│       (midpoint_net)       (orangehrm_net)                  │
└─────────────────────────────────────────────────────────────┘
             │
             │ NAT (Acesso Internet)
             ▼
        [ISP Router]
```

### 2.2. Características Técnicas

|Aspecto|Implementação Atual|Limitação Identificada|
|---|---|---|
|**Segmentação**|Flat network xxx.xxx.xxx.xxx/16|Todo tráfego na mesma broadcast domain|
|**Isolamento**|Apenas via Docker networks (L7)|Sem segregação física/lógica (L2/L3)|
|**Roteamento**|NAT único no gateway .0.1|Impossível aplicar ACLs por zona|
|**Auditoria**|Logs dispersos por container|Dificulta correlação de eventos de segurança|
|**Blast Radius**|Compromisso de 1 VM = acesso a toda subnet|Violação de princípios Zero Trust|

### 2.3. Conformidade - Gaps Identificados

|Framework|Controle|Status Atual|Justificativa do Gap|
|---|---|---|---|
|**ISO 27001:2022**|A.13.1.3 - Segregação de redes|🔴 Não Conforme|Rede flat sem separação lógica de zonas de segurança|
|**NIST CSF 2.0**|PR.AC-5 - Segmentação de rede|🟡 Parcial|Segmentação apenas em nível de aplicação (Docker)|
|**CIS Controls v8**|12.2 - Segmentos de rede isolados|🔴 Não Conforme|Ausência de VLANs ou subnets isoladas para ativos críticos|

---

## 3. Estado Futuro (SHOULD-BE) - Living Lab 2.0

### 3.1. Topologia de Rede Segmentada

```
┌──────────────────────────────────────────────────────────────────┐
│                    HOST WINDOWS 11 (Hyper-V)                     │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │     vSwitch_Fiqueok_Corp (Internal - TRUNK Mode)            │ │
│  │              Tagged VLANs: 1 (Native), 20, 30               │ │
│  └─────────────────────────────────────────────────────────────┘ │
│           │                    │                    │             │
│      VLAN 1 (Native)      VLAN 20 (PKI)      VLAN 30 (IGA)      │
│    xxx.xxx.xxx.xxx/16        192.168.20.0/24    192.168.30.0/24      │
│           │                    │                    │             │
│     ┌─────▼─────┐        ┌────▼────┐         ┌─────▼─────┐      │
│     │  ID-P-01  │        │IGA-P-01 │         │  (Future) │      │
│     │   .10     │        │  .10    │         │  IGA VMs  │      │
│     │           │        │ (VLAN20)│         │           │      │
│     └───────────┘        └─────────┘         └───────────┘      │
│          │                    │                                   │
│     [AD DS/DNS]          [Vault PKI]                             │
│                               │                                   │
│                         [Certificate                              │
│                          Authority]                               │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │              Inter-VLAN Routing Policy                       │ │
│  │  • VLAN 30 → VLAN 20: HTTPS/8200 (Vault API)               │ │
│  │  • VLAN 1 → VLAN 20: Bloqueado (Zero Trust)                │ │
│  │  • VLAN 20 → VLAN 1: LDAPS/636 (Certificate Enrollment)    │ │
│  └─────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

### 3.2. Mapeamento de Zonas de Segurança

|VLAN ID|Nome da Zona|Subnet|Função Estratégica|Ativos Críticos|
|---|---|---|---|---|
|**1** (Native)|**Management Zone**|xxx.xxx.xxx.xxx/16|Gestão de infraestrutura e diretório|AD DS, DHCP, DNS|
|**20**|**Security Zone (PKI)**|192.168.20.0/24|Autoridade certificadora e secrets management|HashiCorp Vault|
|**30**|**IGA Zone** (Futuro)|192.168.30.0/24|Governança de identidades e provisionamento|midPoint, Keycloak|
|**40**|**SOC Zone** (Futuro)|192.168.40.0/24|Monitoramento e resposta a incidentes|Wazuh, TheHive|

### 3.3. Benefícios Estratégicos da Segmentação

#### **3.3.1. Redução de Blast Radius**

- **Antes:** Compromisso de um container Docker = acesso potencial a toda subnet xxx.xxx.xxx.xxx/16
- **Depois:** Ataque limitado à VLAN comprometida, com firewall inter-VLAN bloqueando pivoting

**Exemplo de Cenário:**

```
🔴 Ataque em AS-IS:
   Vulnerabilidade no OrangeHRM → Shell reverso → 
   Scan de xxx.xxx.xxx.xxx/16 → Descoberta do AD (.10) →
   Pass-the-Hash → Domain Admin

🟢 Mitigação em SHOULD-BE:
   Vulnerabilidade no OrangeHRM (VLAN 30) → Shell reverso →
   Scan bloqueado por ACL → Impossível alcançar VLAN 20/1 →
   Ataque contido na zona IGA
```

#### **3.3.2. Conformidade Regulatória**

|Framework|Controle Atendido|Evidência de Implementação|
|---|---|---|
|**ISO 27001:2022**|A.13.1.3 - Segregação de redes|VLANs com ACLs documented em firewall policy|
|**NIST CSF 2.0**|PR.AC-5 - Segmentação|Zonas isoladas com controle de tráfego L3|
|**CIS Controls v8**|12.2 - Network segmentation|4 VLANs segregadas por função (Management, PKI, IGA, SOC)|
|**PCI-DSS 4.0**|Req. 1.3.1 - DMZ implementation|PKI Zone (VLAN 20) atua como DMZ para secrets|

#### **3.3.3. Observabilidade e Auditoria**

**Antes (AS-IS):**

```
Logs de rede → Dispersos entre VMs e containers
Correlação de eventos → Manual e demorada
Detecção de lateral movement → Impossível sem EDR
```

**Depois (SHOULD-BE):**

```
Logs de firewall inter-VLAN → Centralizados no Wazuh (Fase 2.0)
Alertas de tráfego anômalo → IDS/IPS em pontos de choke
Auditoria de acesso à PKI → Trail completo de quem solicitou certificados
```

---

## 4. Arquitetura de Identidade e Automação

### 4.1. Introdução da Conta de Serviço `svc_ansible`

#### **4.1.1. Justificativa (ISO 27001 A.9.2.1 - Registro de Usuários)**

**Problema Identificado:**

- Todas as ações de automação (deploy Docker, configuração Netplan, etc.) eram executadas com a conta pessoal `paulo`
- Violação do princípio de **não repúdio**: impossível distinguir ações manuais de scripts automatizados em logs

**Solução Implementada:**

```yaml
Segregação de Funções (SoD):
  Owner (paulo):
    Escopo: Decisões estratégicas, aprovações de GMUD, supervisão
    Acesso: Interativo via SSH, console Hyper-V
    
  Service Account (svc_ansible):
    Escopo: Execução de playbooks, deploy de stacks, configuração de rede
    Acesso: Não-interativo (apenas via Ansible Control Node)
    Auditoria: Todos os comandos logados com prefixo [svc_ansible]
```

#### **4.1.2. Modelo de Privilégios (NIST SP 800-53 AC-6 - Least Privilege)**

**Implementação Sudoers:**

```bash
# /etc/sudoers.d/svc_ansible
# Criado via GMUD-015A - 27/12/2025
# Owner: Paulo Feitosa | Auditor: Claude 3.5

svc_ansible ALL=(ALL) NOPASSWD: /usr/bin/netplan apply
svc_ansible ALL=(ALL) NOPASSWD: /usr/bin/netplan try
svc_ansible ALL=(ALL) NOPASSWD: /usr/bin/systemctl start vault
svc_ansible ALL=(ALL) NOPASSWD: /usr/bin/systemctl stop vault
svc_ansible ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart vault
svc_ansible ALL=(ALL) NOPASSWD: /usr/bin/docker compose up -d
svc_ansible ALL=(ALL) NOPASSWD: /usr/bin/docker compose down
svc_ansible ALL=(ALL) NOPASSWD: /usr/bin/ip link *
```

**Controles de Auditoria:**

```bash
# Habilitar log de comandos sudo (syslog)
Defaults:svc_ansible log_output
Defaults:svc_ansible!/usr/bin/sudoreplay

# Retenção de logs: 90 dias (ISO 27001 A.12.4.1)
```

### 4.2. Roadmap de Integração com Active Directory (Fase 2.0)

|Fase|Implementação|Status|Data Prevista|
|---|---|---|---|
|**1.0**|Conta local `svc_ansible` no Ubuntu|🟢 GMUD-015A|28/12/2025|
|**2.0**|Usuário de domínio `svc_ansible@corp.fiqueok.com.br`|🟡 Planejado|Q1/2026|
|**2.1**|gMSA (Group Managed Service Account) no AD|🟡 Planejado|Q1/2026|
|**2.2**|Integração Ansible → AD via Kerberos (WinRM)|🟡 Planejado|Q2/2026|

---

## 5. Análise de Riscos e Mitigações

### 5.1. Matriz de Riscos da Transição

|Risco|Probabilidade|Impacto|Severidade|Mitigação|
|---|---|---|---|---|
|Perda de acesso SSH durante reconfiguração de rede|🟡 Média|🔴 Alto|**Crítico**|Console Hyper-V aberta + `netplan try --timeout 30`|
|Falha de roteamento inter-VLAN bloqueando midPoint→Vault|🟡 Média|🟡 Médio|**Moderado**|Validação de ACLs em ambiente de teste antes do deploy|
|Conta `svc_ansible` comprometida por chave SSH vazada|🟢 Baixa|🔴 Alto|**Moderado**|Chaves Ed25519 únicas + rotação a cada 90 dias|
|Configuração incorreta de sudoers permitindo escalação|🟢 Baixa|🔴 Alto|**Moderado**|Whitelist restrita + auditoria semanal via `sudo -l`|

### 5.2. Lições Aprendidas de Incidentes Anteriores

#### **Incidente #1: Perda de SSH na GMUD-007 (23/12/2025)**

**Descrição:** Durante alteração de IP estático no Ubuntu, conexão SSH caiu e não reconectou automaticamente.

**Causa Raiz:** Cloud-init sobrescreveu configuração Netplan após `apply`.

**Ação Corretiva Aplicada:**

- Mover `50-cloud-init.yaml` para `/tmp` antes de qualquer mudança de rede
- Documentar uso obrigatório de Console Hyper-V como fallback

**Incorporação na GMUD-015A:**

- Passo obrigatório de pré-execução: abrir Console Hyper-V antes de iniciar mudanças de rede
- Timeout reduzido de 120s → 30s no `netplan try`

---

## 6. Roadmap de Implementação

### 6.1. Fases de Execução

```
┌─────────────────────────────────────────────────────────────┐
│ Fase 1.0 → 2.0: Transição de Arquitetura                   │
└─────────────────────────────────────────────────────────────┘

Sprint 1 (27-28/12/2025): GMUD-015A
├─ Criação de svc_ansible
├─ Configuração de VLAN 20 (trunk + subinterface)
└─ Validação de conectividade básica

Sprint 2 (29-30/12/2025): GMUD-015B
├─ Deploy do HashiCorp Vault na VLAN 20
├─ Configuração de PKI Engine
└─ Emissão de certificado para AD DS

Sprint 3 (31/12/2025 - 02/01/2026): GMUD-015C
├─ Binding de certificado no ID-P-01
├─ Validação de LDAPS (porta 636)
└─ Retomada de GMUD-013/014 (provisionamento completo)

Sprint 4 (03-05/01/2026): GMUD-016
├─ Migração gradual de midPoint para VLAN 30
├─ Configuração de ACLs inter-VLAN
└─ Testes de resiliência (failover de rede)
```

### 6.2. Critérios de Aceitação da Transição

|Critério|Método de Validação|Responsável|
|---|---|---|
|Todas as 4 VLANs operacionais|`ping` entre gateways de cada VLAN|svc_ansible (automatizado)|
|ACLs inter-VLAN configuradas|Teste de bloqueio de porta não autorizada|Paulo (manual)|
|Logs centralizados no Wazuh|Query de eventos de firewall no SIEM|Gemini (análise de dados)|
|Zero downtime no AD DS|Monitoramento de serviços críticos (LDAP, DNS)|Netdata (observabilidade)|

---

## 7. Alinhamento com Frameworks de Conformidade

### 7.1. Mapeamento de Controles

|Framework|Controle|Status AS-IS|Status SHOULD-BE|Evidência Documental|
|---|---|---|---|---|
|**ISO 27001:2022**|A.13.1.3|🔴 NC|🟢 C|Este memorial + firewall policy|
|**ISO 27001:2022**|A.9.2.3|🟡 PC|🟢 C|Sudoers whitelist + logs de auditoria|
|**NIST CSF 2.0**|PR.AC-5|🔴 NC|🟢 C|Diagrama de VLANs + ACLs|
|**NIST SP 800-53**|AC-6|🟡 PC|🟢 C|Política de least privilege (svc_ansible)|
|**CIS Controls v8**|12.2|🔴 NC|🟢 C|Configuração de trunk mode Hyper-V|
|**CIS Controls v8**|5.4|N/A|🟢 C|Conta de serviço dedicada para automação|

**Legenda:**

- 🔴 NC = Não Conforme
- 🟡 PC = Parcialmente Conforme
- 🟢 C = Conforme

### 7.2. Benefícios para Auditoria Externa

**Valor Agregado para Certificação ISO 27001:**

1. **Evidência de melhoria contínua** (Cláusula 10.2): Transição documentada de arquitetura inadequada para conforme
2. **Segregação de ambientes** (A.13.1.3): VLANs com ACLs rastreáveis
3. **Gestão de privilégios** (A.9.2.3): Conta de serviço com princípio de menor privilégio
4. **Rastreabilidade** (A.9.2.1): Logs diferenciados de ações humanas vs. automatizadas

---

## 8. Conclusão e Recomendações

### 8.1. Sumário Executivo

A transição de arquitetura do Living Lab Fiqueok representa um marco estratégico na maturidade de segurança do projeto. A introdução de **segmentação por VLANs** e **contas de serviço dedicadas** não apenas resolve gaps de conformidade, mas estabelece as fundações para:

1. **Escalabilidade:** Adição de novas zonas (SOC, Observabilidade) sem reestruturação
2. **Resiliência:** Contenção de incidentes por zona, reduzindo MTTR (Mean Time To Recover)
3. **Governança:** Rastreabilidade completa de ações humanas e automatizadas
4. **Compliance:** Aderência imediata a ISO 27001, NIST CSF e CIS Controls

### 8.2. Próximos Passos

1. ✅ **Aprovação formal** deste memorial pelo Owner (Paulo)
2. 🔄 **Execução da GMUD-015A** (preparação de infraestrutura)
3. 🔄 **Validação de pré-requisitos** antes da GMUD-015B (Vault deployment)
4. 📊 **Atualização de ARQ-003** (Arquitetura de Referência IGA) com nova topologia

---

## 9. Referências Técnicas

1. **GMUD-001** - Implementação de Infraestrutura Core (Hyper-V)
2. **GMUD-007** - Alteração de Endereçamento IP (Estático)
3. **REL-GMUD-014** - Integração AD e IGA (MidPoint) - Suspensão Técnica
4. ISO/IEC 27001:2022 - Annex A Control A.13.1.3 (Network Segregation)
5. NIST Cybersecurity Framework 2.0 - PR.AC-5 (Network Segmentation)
6. CIS Controls v8 - Control 12.2 (Establish and Maintain Dedicated Computing Resources)
7. Hyper-V Networking Best Practices - Microsoft Docs (2024)

---

**Aprovações:**

|Papel|Nome|Data|Assinatura Digital|
|---|---|---|---|
|**Owner**|Paulo Feitosa|27/12/2025|_Pendente_|
|**Arquiteto CTO**|Gemini Pro|27/12/2025|_Pendente_|
|**Auditor GRC**|Claude 3.5|27/12/2025|✅ Documento Técnico Aprovado|

---

**Changelog:**

- v1.0 (27/12/2025): Criação inicial do memorial descritivo
