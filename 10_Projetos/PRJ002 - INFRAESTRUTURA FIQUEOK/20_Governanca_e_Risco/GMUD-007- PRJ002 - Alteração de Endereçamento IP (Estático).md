## 



## 📊 Informações da Mudança

| Campo                | Valor                                                          |
| -------------------- | -------------------------------------------------------------- |
| **ID da GMUD**       | GMUD-007                                                       |
| **Título**           | Configuração de IP Estático e DNS Corporativo no Ubuntu Server |
| **Solicitante**      | Paulo - Fiqueok Consultoria                                    |
| **Executor**         | Paulo - Fiqueok Consultoria                                    |
| **Data de Criação**  | 23/12/2024                                                     |
| **Data de Execução** | 23/12/2024                                                     |
| **Prioridade**       | Alta                                                           |
| **Categoria**        | Infraestrutura de Rede                                         |
| **Impacto**          | Médio (Breve interrupção de conectividade)                     |
| **Risco**            | Baixo (Configuração reversível)                                |
| **Status**           | 🟡 Planejada / 🟢 Executada / 🔴 Rollback                      |

---

## 🎯 Objetivo

Configurar IP estático e DNS corporativo no Ubuntu Server (iga-p-01) para garantir:

1. Resolução de nomes do Active Directory (corp.fiqueok.com.br)
2. Conectividade estável entre containers Docker e Domain Controller
3. Preparação para integração LDAP do midPoint com AD

---

## 📝 Descrição Técnica

### Estado Atual (Antes)

```
Hostname: iga-p-01
IP: xxx.xxx.xxx.xxx/24 (DHCP - dinâmico)
Gateway: xxx.xxx.xxx.xxx
DNS: 8.8.8.8 (Google DNS)
Search Domain: Nenhum
```

**Problema:** Ubuntu não consegue resolver nomes internos do Active Directory (ID-P-01.corp.fiqueok.com.br).

### Estado Desejado (Depois)

```
Hostname: iga-p-01
IP: xxx.xxx.xxx.xxx/16 (Estático)
Gateway: xxx.xxx.xxx.xxx
DNS Primário: xxx.xxx.xxx.xxx (Domain Controller)
DNS Secundário: 8.8.8.8 (Fallback)
Search Domain: corp.fiqueok.com.br
```

---

## 🔧 Mudanças a Serem Realizadas

### 1️⃣ Windows Server 2022 (ID-P-01)

**Ação:** Excluir IP xxx.xxx.xxx.xxx do pool DHCP

**Comandos (PowerShell Admin):**

```powershell
Add-DhcpServerv4ExclusionRange -ScopeId xxx.xxx.xxx.xxx -StartRange xxx.xxx.xxx.xxx -EndRange xxx.xxx.xxx.xxx
Get-DhcpServerv4ExclusionRange -ScopeId xxx.xxx.xxx.xxx
```

**Justificativa:** Prevenir conflito de IP quando o Ubuntu passar a usar IP estático.

---

### 2️⃣ Ubuntu Server 24.04 (IGA-P-01)

**Ação:** Aplicar configuração netplan com IP estático

**Arquivo:** `/etc/netplan/01-netplan-fiqueok.yaml`

**Conteúdo:**

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - xxx.xxx.xxx.xxx/16
      routes:
        - to: default
          via: xxx.xxx.xxx.xxx
      nameservers:
        addresses:
          - xxx.xxx.xxx.xxx
          - 8.8.8.8
        search:
          - corp.fiqueok.com.br
```

**Comandos:**

```bash
sudo cp 01-netplan-fiqueok.yaml /etc/netplan/
sudo netplan --debug generate
sudo netplan apply
```

---

## ⏱️ Janela de Manutenção

|Item|Descrição|
|---|---|
|**Data**|23/12/2024|
|**Horário**|23:00 - 23:15 BRT|
|**Duração Estimada**|15 minutos|
|**Downtime Esperado**|~30 segundos (reconexão SSH)|
|**Sistemas Afetados**|Ubuntu Server (iga-p-01)|

---

## ✅ Critérios de Sucesso

### Testes de Validação

```bash
# 1. Verificar IP estático aplicado
ip addr show eth0 | grep "inet xxx.xxx.xxx.xxx"
# Esperado: inet xxx.xxx.xxx.xxx/16 (sem "dynamic")

# 2. Verificar DNS configurado
cat /etc/resolv.conf | grep "nameserver xxx.xxx.xxx.xxx"
# Esperado: nameserver xxx.xxx.xxx.xxx

# 3. Testar resolução do Domain Controller
nslookup ID-P-01.corp.fiqueok.com.br
# Esperado: Address: xxx.xxx.xxx.xxx

# 4. Testar conectividade LDAP
nc -zv xxx.xxx.xxx.xxx 389
# Esperado: Connection to xxx.xxx.xxx.xxx 389 port [tcp/ldap] succeeded!

# 5. Testar resolução de nomes externos (fallback DNS)
nslookup google.com
# Esperado: Resposta bem-sucedida
```

---

## 🔄 Plano de Rollback

### Se algo der errado:

#### Opção 1: Reverter para DHCP

```bash
# Remover arquivo netplan customizado
sudo rm /etc/netplan/01-netplan-fiqueok.yaml

# Recriar configuração DHCP padrão
sudo nano /etc/netplan/00-installer-config.yaml
```

Conteúdo (DHCP padrão):

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
```

```bash
sudo netplan apply
```

#### Opção 2: Acessar via Console Hyper-V

Se perder conectividade SSH:

1. Hyper-V Manager → iga-p-01 → Connect
2. Login local
3. Executar rollback manualmente

---

## 📊 Impacto nos Sistemas

|Sistema|Impacto|Duração|Mitigação|
|---|---|---|---|
|Ubuntu SSH|Conexão perdida|~30 seg|Reconectar após netplan apply|
|Containers Docker|Nenhum|N/A|Containers não afetados|
|midPoint|Nenhum|N/A|Ainda não implantado|
|Domain Controller|Nenhum|N/A|Apenas exclusão no DHCP|

---

## 🔐 Requisitos de Segurança

- ✅ Acesso sudo no Ubuntu (usuário: paulo)
- ✅ Acesso Admin no Windows Server (PowerShell)
- ✅ Backup da configuração de rede anterior
- ✅ Acesso físico via Console Hyper-V (se SSH falhar)

---

## 📸 Evidências (Preencher Após Execução)

### Antes da Mudança

```bash
# Capturar configuração atual
ip addr show > ~/evidencias/ip_addr_before.txt
cat /etc/resolv.conf > ~/evidencias/resolv_before.txt
```

### Depois da Mudança

```bash
# Capturar nova configuração
ip addr show > ~/evidencias/ip_addr_after.txt
cat /etc/resolv.conf > ~/evidencias/resolv_after.txt
nslookup ID-P-01.corp.fiqueok.com.br > ~/evidencias/nslookup_dc.txt
```

---

## 📋 Checklist de Execução

### Pré-Execução

- [ ] Backup da configuração de rede atual
- [ ] Criar pasta de evidências: `mkdir -p ~/evidencias`
- [ ] Capturar estado atual (ip addr, resolv.conf)
- [ ] Notificar stakeholders (se aplicável)

### Execução - Windows Server

- [ ] Conectar ao ID-P-01 via RDP
- [ ] Abrir PowerShell como Admin
- [ ] Executar: `Add-DhcpServerv4ExclusionRange`
- [ ] Validar: `Get-DhcpServerv4ExclusionRange`
- [ ] Screenshot da exclusão criada

### Execução - Ubuntu Server

- [ ] Conectar via SSH: `ssh paulo@xxx.xxx.xxx.xxx`
- [ ] Criar arquivo: `nano 01-netplan-fiqueok.yaml`
- [ ] Copiar para /etc/netplan: `sudo cp ...`
- [ ] Validar sintaxe: `sudo netplan --debug generate`
- [ ] Aplicar: `sudo netplan apply`
- [ ] Aguardar 30 segundos
- [ ] Reconectar SSH

### Pós-Execução

- [ ] Executar testes de validação (todos os 5)
- [ ] Capturar evidências (ip addr, resolv.conf, nslookup)
- [ ] Validar que containers Docker continuam funcionando
- [ ] Atualizar documentação no Obsidian
- [ ] Atualizar status da GMUD para "Executada"

---

## 📝 Observações e Lições Aprendidas

### Observações Durante Execução

_(Preencher durante a execução)_

### Problemas Encontrados

_(Se houver)_

### Melhorias para Próximas GMUDs

_(Preencher após conclusão)_

---

## ✍️ Aprovações e Assinaturas

|Papel|Nome|Data|Assinatura|
|---|---|---|---|
|Solicitante|Paulo|23/12/2024|________|
|Executor|Paulo|23/12/2024|________|
|Aprovador|Paulo|23/12/2024|________|

---

## 📎 Anexos

1. `01-netplan-fiqueok.yaml` - Arquivo de configuração
2. `ip_addr_before.txt` - Estado da rede antes
3. `ip_addr_after.txt` - Estado da rede depois
4. `nslookup_dc.txt` - Teste de resolução DNS
5. Screenshots do DHCP Exclusion Range

---

**Criado por:** Claude (Anthropic) para Fiqueok Consultoria  
**Última Atualização:** 23/12/2024  
**Versão:** 1.0
