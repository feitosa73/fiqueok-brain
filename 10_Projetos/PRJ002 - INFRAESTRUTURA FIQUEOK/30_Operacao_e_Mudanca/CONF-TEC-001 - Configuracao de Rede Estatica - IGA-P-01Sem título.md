---

## tags: [infraestrutura, rede, ubuntu, active-directory, gmud-001] projeto: Laboratório IGA - midPoint data: 2024-12-23 status: em-progresso tipo: configuracao-tecnica

# Configuração de Rede Estática - Ubuntu IGA-P-01

## 📌 Contexto

Como parte da [[Implantação do Laboratório IGA]], precisamos configurar o Ubuntu Server (iga-p-01) para se comunicar com o [[Domain Controller ID-P-01]] via resolução DNS interna.

**Relacionado com:**

- [[GMUD-001 - Configuração de Rede]]
- [[Arquitetura do Laboratório Fiqueok]]
- [[Integração LDAP midPoint-AD]]

---

## 🎯 Objetivo

Configurar IP estático e DNS corporativo para permitir:

1. Resolução de nomes internos do AD
2. Conectividade Docker ↔ Domain Controller
3. Preparação para integração LDAP

---

## 📊 Configuração Aplicada

### Estado Antes

```yaml
IP: xxx.xxx.xxx.xxx/24 (DHCP)
DNS: 8.8.8.8
Status: Não resolve nomes internos
```

### Estado Depois

```yaml
IP: xxx.xxx.xxx.xxx/16 (Estático)
DNS: xxx.xxx.xxx.xxx (DC) + 8.8.8.8 (Fallback)
Search Domain: corp.fiqueok.com.br
Status: Resolve ID-P-01.corp.fiqueok.com.br ✅
```

---

## 🔧 Implementação Técnica

### Arquivo Netplan

**Localização:** `/etc/netplan/01-netplan-fiqueok.yaml`

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

### Comandos Executados

```bash
sudo cp 01-netplan-fiqueok.yaml /etc/netplan/
sudo netplan --debug generate
sudo netplan apply
```

---

## ✅ Validação

### Testes Realizados

```bash
# 1. IP Estático
ip addr show eth0 | grep "xxx.xxx.xxx.xxx"
# ✅ Resultado: inet xxx.xxx.xxx.xxx/16 (sem "dynamic")

# 2. DNS Configurado
cat /etc/resolv.conf
# ✅ nameserver xxx.xxx.xxx.xxx
# ✅ search corp.fiqueok.com.br

# 3. Resolução DC
nslookup ID-P-01.corp.fiqueok.com.br
# ✅ Address: xxx.xxx.xxx.xxx

# 4. Conectividade LDAP
nc -zv xxx.xxx.xxx.xxx 389
# ✅ Connection succeeded
```

---

## 🔗 Dependências

### Windows Server (ID-P-01)

**Ação Requerida:** Exclusão do IP no DHCP

```powershell
Add-DhcpServerv4ExclusionRange -ScopeId xxx.xxx.xxx.xxx `
  -StartRange xxx.xxx.xxx.xxx -EndRange xxx.xxx.xxx.xxx
```

**Status:** ⬜ Pendente / ✅ Concluído

---

## 📸 Evidências

### Screenshots

- [ ] Configuração DHCP no Windows Server
- [ ] Resultado do `ip addr show` após mudança
- [ ] Resultado do `nslookup` DC
- [ ] Teste de conectividade LDAP

### Arquivos de Log

```bash
~/evidencias/
├── ip_addr_before.txt
├── ip_addr_after.txt
├── resolv_before.txt
├── resolv_after.txt
└── nslookup_dc.txt
```

---

## 🚨 Problemas Conhecidos

### Issue #1: Máscara de Rede Diferente

- **Descrição:** DC usa /16, Ubuntu original estava com /24
- **Impacto:** Possível problema de roteamento
- **Solução:** Padronizado para /16 em ambos
- **Status:** ✅ Resolvido

---

## 🔄 Rollback

Se necessário reverter:

```bash
sudo rm /etc/netplan/01-netplan-fiqueok.yaml
sudo nano /etc/netplan/00-installer-config.yaml
# (Configurar DHCP padrão)
sudo netplan apply
```

---

## 📚 Referências

- [[Ubuntu Netplan Documentation]]
- [[Active Directory DNS Best Practices]]
- [[GMUD-007- PRJ002 - Alteração de Endereçamento IP (Estático)]]
- [Netplan Reference](https://netplan.io/reference/)

---

## 🔜 Próximos Passos

1. [ ] Executar `validate-fiqueok-network.sh`
2. [ ] Validar conectividade LDAP (porta 389)
3. [ ] Executar `preflight-check.sh`
4. [ ] Iniciar deploy do midPoint
5. [ ] Documentar em [[REL-GMUD-007 - PRJ002 - Validação de Endereçamento Estático]]

---

## 🗒️ Notas Técnicas

### Por que /16 e não /24?

O Domain Controller está configurado com máscara /16 (255.255.0.0), permitindo 65.534 hosts na rede xxx.xxx.xxx.xxx. Para consistência e evitar problemas de roteamento, o Ubuntu foi configurado com a mesma máscara.

### Por que DNS Primário = DC?

Para que o Ubuntu resolva nomes internos do Active Directory (como ID-P-01.corp.fiqueok.com.br), o DNS primário deve apontar para o Domain Controller, que também é o servidor DNS da rede corporativa.

### Fallback DNS (8.8.8.8)

Garantir que nomes externos (google.com, etc.) sejam resolvidos caso o DC esteja indisponível ou não conheça o domínio.

---

## 📝 Changelog

|Data|Autor|Mudança|
|---|---|---|
|2024-12-23|Paulo|Criação da nota|
|2024-12-23|Paulo|Configuração aplicada|
|2024-12-23|Paulo|Validação concluída|

---

**Links Relacionados:**

- [[Laboratório IGA - Índice]]
- [[midPoint 4.10 - Configuração]]
- [[Troubleshooting - Rede]]
