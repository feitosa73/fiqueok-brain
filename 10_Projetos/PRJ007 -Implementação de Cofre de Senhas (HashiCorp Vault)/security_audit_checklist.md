# Checklist de Auditoria de Segurança - Pós-Incidente WSL2/Vault

**Projeto**: PRJ007 - Living Lab Fiqueok 2.0  
**Data**: 08 de Fevereiro de 2026  
**Responsável**: Paulo  
**Objetivo**: Verificar vulnerabilidades introduzidas pela tentativa falha de implementação do Vault

---

## 1. Verificação de Permissões Críticas

### 1.1 Diretórios com Permissões Inseguras
Execute no WSL2 Ubuntu restaurado:

```bash
# Verificar se existem diretórios com permissões 777
find ~ -type d -perm 0777 2>/dev/null
```

**Ação esperada**: Nenhum resultado. Se houver, corrigir com:
```bash
chmod 750 <diretório>
```

### 1.2 Arquivos de Configuração Docker
```bash
# Verificar permissões do daemon Docker
ls -la /var/run/docker.sock 2>/dev/null
# Deve ser: srw-rw---- 1 root docker

# Verificar grupo do usuário
groups
# Deve conter 'docker' se instalado corretamente
```

---

## 2. Containers e Imagens Órfãs

### 2.1 Remover Containers Vault Falhos
```bash
# Listar todos os containers (incluindo parados)
docker ps -a

# Remover containers do Vault
docker rm -f $(docker ps -aq -f "ancestor=hashicorp/vault") 2>/dev/null

# Verificar containers em loop de restart
docker ps -a --filter "status=restarting"
```

### 2.2 Limpar Imagens não Utilizadas
```bash
# Remover imagens do Vault (se presentes)
docker rmi hashicorp/vault:1.21.2 2>/dev/null

# Limpar cache do Docker
docker system prune -af --volumes
```

**⚠️ ATENÇÃO**: O comando acima remove TODOS os containers, imagens e volumes não utilizados.

---

## 3. Volumes Docker Persistentes

### 3.1 Verificar Volumes Órfãos
```bash
# Listar volumes
docker volume ls

# Verificar volumes do Vault
docker volume ls | grep vault

# Inspecionar conteúdo (se existir)
docker volume inspect vault_data 2>/dev/null
```

### 3.2 Remover Volumes Inseguros
```bash
# Se houver volumes com dados do Vault comprometidos
docker volume rm vault_data vault_logs 2>/dev/null
```

---

## 4. Arquivos de Configuração Residuais

### 4.1 Verificar Diretório Home
```bash
# Procurar arquivos de configuração do Vault
find ~ -name "*vault*" -type f 2>/dev/null
find ~ -name "*vault*" -type d 2>/dev/null

# Verificar logs residuais
ls -la ~/vault/logs/ 2>/dev/null
```

### 4.2 Verificar Variáveis de Ambiente
```bash
# Verificar se há tokens ou credenciais expostas
env | grep -i vault
printenv | grep -i vault

# Verificar arquivos de perfil
grep -i vault ~/.bashrc ~/.profile ~/.bash_profile 2>/dev/null
```

**Ação**: Se encontrar variáveis como `VAULT_TOKEN` ou `VAULT_ADDR`, removê-las.

---

## 5. Verificação de Processos Suspeitos

### 5.1 Processos Docker
```bash
# Verificar processos do Docker
ps aux | grep docker

# Verificar se há processos do Vault rodando
ps aux | grep vault
```

### 5.2 Portas Expostas
```bash
# Verificar se a porta 8200 (Vault) está aberta
sudo netstat -tulpn | grep 8200
# ou
ss -tulpn | grep 8200
```

**Ação**: Se houver processo na porta 8200, identificar e encerrar:
```bash
sudo kill -9 <PID>
```

---

## 6. Verificação de Integridade do WSL2

### 6.1 Validar Restauração do Backup
```bash
# Verificar versão do Ubuntu
lsb_release -a

# Verificar integridade do Docker Engine
docker --version
docker info | grep "Server Version"

# Verificar systemd (se disponível)
systemctl --version 2>/dev/null
```

### 6.2 Verificar Logs do Sistema
```bash
# Logs recentes do Docker
sudo journalctl -u docker --since "2 hours ago" --no-pager | tail -50

# Logs do kernel WSL2
dmesg | tail -50
```

---

## 7. Checklist de Compliance GRC

| Item | Controle ISO 27001 | Status | Ação Corretiva |
|------|-------------------|--------|----------------|
| Permissões 777 removidas | A.9.4.1 | ⬜ | Executar item 1.1 |
| Containers órfãos removidos | A.12.6.1 | ⬜ | Executar item 2.1 |
| Volumes com dados sensíveis excluídos | A.10.1.2 | ⬜ | Executar item 3.2 |
| Variáveis de ambiente limpas | A.9.4.5 | ⬜ | Executar item 4.2 |
| Portas não autorizadas fechadas | A.13.1.3 | ⬜ | Executar item 5.2 |
| Backup Greenfield validado | A.12.3.1 | ✅ | Confirmado no relatório |

---

## 8. Relatório de Auditoria

Após executar todos os itens, documentar:

```markdown
## Relatório de Auditoria de Segurança - PRJ007
**Data**: [DATA_EXECUCAO]
**Auditor**: Paulo

### Vulnerabilidades Identificadas:
- [ ] Permissões inseguras encontradas: [DETALHAR]
- [ ] Containers/imagens órfãos: [LISTAR]
- [ ] Volumes persistentes comprometidos: [LISTAR]
- [ ] Variáveis de ambiente expostas: [LISTAR]

### Ações Corretivas Aplicadas:
- [ ] [DESCREVER AÇÕES]

### Estado Final:
- [ ] Ambiente WSL2 sanitizado e seguro para nova implementação
- [ ] Backup Greenfield restaurado e validado
- [ ] Nenhuma vulnerabilidade residual identificada

**Assinatura Digital**: [HASH DO RELATÓRIO]
```

---

## 9. Validação Final (Pre-Flight Check)

Antes de prosseguir com nova implementação:

```bash
# Teste 1: Docker funcional
docker run --rm hello-world

# Teste 2: Permissões corretas
ls -la ~ | grep -E "drwx------"

# Teste 3: Nenhum processo Vault
ps aux | grep -v grep | grep vault || echo "OK: Nenhum processo Vault"

# Teste 4: Porta 8200 livre
ss -tulpn | grep 8200 || echo "OK: Porta 8200 disponível"
```

**Critério de Aprovação**: Todos os testes devem retornar "OK" ou resultados esperados.

---

**Próximo Documento**: `vault_implementation_plan_v2.md` (aguardando aprovação desta auditoria)
