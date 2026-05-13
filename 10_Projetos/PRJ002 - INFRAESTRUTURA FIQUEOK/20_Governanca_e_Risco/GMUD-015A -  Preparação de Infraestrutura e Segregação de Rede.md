
# 📑 

**ID da Mudança:** GMUD-015A

**Data de Emissão:** 27/12/2025

**Status:** Pronta para Execução (Pós-Revisão de Arquitetura ARQ-005)

**Responsável:** Paulo Feitosa (Owner)

---

### 1. Resumo Executivo e Justificativa

Esta mudança visa estabelecer os pré-requisitos de identidade e rede para o deploy do **HashiCorp Vault**. A transição para o modelo de segmentação por **VLANs** atende diretamente ao controle **ISO 27001 A.13.1.3 (Segregação de Redes)**, reduzindo o raio de exposição (_blast radius_) de ativos críticos de identidade.

### 2. Escopo da Mudança

- **Identidade (SoD):** Criação da conta de serviço local `svc_ansible` para automação, segregando funções administrativas (ISO 27001 A.9.2.1).
    
- **Privilégios (Least Privilege):** Implementação de _whitelist_ no Sudoers (NIST SP 800-53 AC-6).
    
- **Conectividade (L2/L3):** Ativação de modo **Trunk** no Hyper-V e configuração de subinterface **VLAN 20** via Netplan no Ubuntu (`192.168.20.10/24`).
    

### 3. Janela de Execução e Impacto

- **Tempo Estimado:** 30 minutos.
    
- **Indisponibilidade Prevista:** Até 5 minutos durante o _handshake_ de rede entre Host e Guest.
    
- **Impacto de Negócio:** Baixo, restrito ao ambiente de laboratório, mas com risco de perda temporária de acesso administrativo SSH.
    

### 4. Plano de Implementação Detalhado

Para evitar a reincidência do incidente documentado em **27/12/2025 18:51**, onde a conectividade foi perdida por descompasso de configuração, a ordem deve ser estritamente seguida:

|**Passo**|**Ação**|**Comando / Ferramenta**|
|---|---|---|
|**1**|**Login Fallback**|Manter a Console do Hyper-V logada e aberta (Obrigatório).|
|**2**|**Config. Sudoers**|Criar `/etc/sudoers.d/svc_ansible` com a _whitelist_ aprovada.|
|**3**|**Config. Netplan**|Criar `/etc/netplan/99-vlan20.yaml` (Sem aplicar ainda).|
|**4**|**Config. Host**|Ativar modo Trunk via PowerShell: `Set-VMNetworkAdapterVlan -VMName "iga-p-01" -Trunk -AllowedVlanIdList "1,20" -NativeVlanId 1`.|
|**5**|**Aplicação Safe**|Executar no Ubuntu: `sudo netplan try --timeout 30`.|

### 5. Análise de Risco e Lições Aprendidas

- **Risco Crítico:** Perda de acesso SSH à interface `eth0` (`xxx.xxx.xxx.xxx`).
    
- **Evidência de Incidente Prévio:** As imagens de log confirmam que, sem a subinterface configurada no Linux, o modo Trunk do Hyper-V causou um _timeout_ na porta 22 e 100% de perda de pacotes (ping 8.8.8.8).
    
- **Mitigação Ativa:** Uso de `netplan try` garante o retorno automático à última configuração válida se o comando não for confirmado manualmente.
    

### 6. Plano de Rollback (Contingência)

Caso a conectividade SSH não seja restabelecida em 30 segundos após o passo 5:

1. **No Host Windows:** Executar `Set-VMNetworkAdapterVlan -VMName "iga-p-01" -Untagged`.
    
2. **No Guest Ubuntu:** (Via Console Hyper-V) Remover o arquivo `/etc/netplan/99-vlan20.yaml` e executar `sudo netplan apply`.
    

### 7. Critérios de Sucesso (Validação)

- [ ] Interface `eth0.20` ativa com IP `192.168.20.10`.
    
- [ ] Sucesso no teste de conectividade: `ping -c 3 192.168.20.1` (Gateway VLAN 20).
    
- [ ] Persistência de acesso SSH na rede de gerência (`xxx.xxx.xxx.xxx`).
    
- [ ] Validação de porta LDAP básica: `nc -zv xxx.xxx.xxx.xxx 389`.
    

---

### 🏛️ Visão de Gestão

Paulo, agora você tem a **GMUD-015A** pronta para ser integrada ao seu **Obsidian** e ao seu repositório de evidências. O fato de você ter registrado o "erro" de conectividade anterior como uma lição aprendida e mitigação é o que tornaria esta documentação imbatível em uma auditoria real.

**O que você deseja fazer agora?**

1. **Executar a GMUD:** Posso aguardar você realizar os passos técnicos conforme a ordem segura que definimos?
    
2. **Preparação do Vault:** Deseja que eu já prepare o roteiro técnico que você passará ao Engenheiro (ChatGPT) para o deploy do Vault, considerando que a rede VLAN 20 será validada agora?
