
# 📑 

|**Campo**|**Valor**|
|---|---|
|**ID da Mudança**|GMUD-007|
|**Título**|Configuração de IP Estático e DNS Corporativo no Ubuntu Server|
|**Projeto**|PRJ002 - Implementação de Infraestrutura IGA|
|**Executor**|Paulo - Fiqueok Consultoria|
|**Data de Conclusão**|23/12/2025|
|**Status Final**|🟢 **Executada com Sucesso**|

---

## 🎯 Resumo da Execução

A mudança foi realizada para estabilizar o Item de Configuração (IC) do servidor **iga-p-01**, eliminando a dependência de DHCP e garantindo que o serviço midPoint consiga resolver o Domain Controller via DNS interno.

### ✅ Resultados Alcançados

1. **IP Estático**: Fixado em `xxx.xxx.xxx.xxx/16`.
    
2. **Resolução de Nomes**: FQDN `ID-P-01.corp.fiqueok.com.br` resolvendo corretamente para `xxx.xxx.xxx.xxx`.
    
3. **Comunicação LDAP**: Conectividade via porta 389 validada com sucesso.
    

---

## 🔧 Detalhes Técnicos e Evidências

### 1. Configuração de Rede Aplicada

O arquivo `/etc/netplan/01-netplan-fiqueok.yaml` foi configurado com permissões restritas (**chmod 600**) conforme as boas práticas de segurança.

### 2. Validação de Interface (ip addr)

Bash

```
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:44:69:03 brd ff:ff:ff:ff:ff:ff
    inet xxx.xxx.xxx.xxx/16 brd 172.16.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

_(Nota: A tag `dynamic` foi removida com sucesso)_.

### 3. Teste de Conectividade e DNS

- **NSLOOKUP**: Resolvido via servidor `127.0.0.53` (systemd-resolved) apontando corretamente para o DC.
    
- **NC (Netcat)**: `Connection to xxx.xxx.xxx.xxx 389 port [tcp/ldap] succeeded!`.
    

---

## 🚨 Incidentes e Lições Aprendidas

Durante a execução, foram identificados e mitigados os seguintes pontos:

1. **Conflito de Precedência**: O arquivo `50-cloud-init.yaml` estava forçando o DHCP. **Ação**: O arquivo foi movido para `/tmp`, permitindo que o Netplan processasse apenas a configuração estática.
    
2. **Erro de Localização**: O arquivo de configuração foi inicialmente criado na _home_ do usuário. **Ação**: Corrigido movendo para `/etc/netplan/`.
    
3. **Permissões de Segurança**: O Netplan emitiu um alerta de "Permissions too open". **Ação**: Aplicado `chmod 600`, atendendo aos requisitos de auditoria.
    
4. **Queda de SSH**: Conforme previsto, a conexão caiu no `apply`. A recuperação foi feita via **Console Local do Hyper-V**.
    

---

## 📈 Próximos Passos

- [ ] Iniciar **GMUD-008**: Deploy do midPoint 4.10 utilizando Docker Compose.
    
- [ ] Validar injeção de segredos e Keystore JCEKS no container.
    

---

### ✍️ Encerramento

Relatório gerado por: Gemini (Google) como Thought Partner para Fiqueok Consultoria.

Aprovação Técnica: Paulo.


