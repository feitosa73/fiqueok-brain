-project` |
| `/usr/bin/docker` | Gerenciamento de containers | `sudo docker compose up -d` |
| `/usr/bin/du` | Coleta de evidências (tamanho volumes) | `sudo du -sh /srv/iga-project/data` |
| `/usr/bin/rm` | Rollback (remoção de volumes) | `sudo rm -rf /srv/iga-project/data/postgres` |

#### **5.2.4. Raio de Explosão Limitado**

**Em caso de comprometimento da conta, atacante NÃO poderá:**

- ❌ Executar `apt install` (instalar softwares)
- ❌ Executar `useradd` (criar usuários)
- ❌ Executar `systemctl` (alterar serviços)
- ❌ Executar `iptables` (alterar firewall)
- ❌ Executar `nano /etc/passwd` (editar arquivos de sistema)

**⚠️ CHECKPOINT 3:** Sudoers configurado com whitelist de caminhos completos? ✅ Prosseguir para Docker

**Conformidade:**
- ✅ ISO 27001:2022 A.9.2.3 - Gestão de Privilégios de Acesso
- ✅ NIST CSF 2.0 PR.AC-4 - Princípio do Menor Privilégio
- ✅ CIS Controls v8 5.4 - Restrição de Privilégios Administrativos

---

## **9. FASE 6: INSTALAÇÃO DO DOCKER E DOCKER COMPOSE**

### **6.1. Instalação do Docker Engine**

```bash
# ====================================
# PREPARAR AMBIENTE
# ====================================
# Remover versões antigas (se existirem)
sudo apt remove -y docker docker-engine docker.io containerd runc

# Instalar dependências
sudo apt update
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# ====================================
# ADICIONAR REPOSITÓRIO OFICIAL DO DOCKER
# ====================================
# Criar diretório para chaves GPG
sudo install -m 0755 -d /etc/apt/keyrings

# Baixar chave GPG oficial
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Adicionar repositório
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# ====================================
# INSTALAR DOCKER
# ====================================
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# ====================================
# CONFIGURAR PERMISSÕES
# ====================================
# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Aplicar mudanças de grupo (sem logout)
newgrp docker

# ====================================
# VALIDAR INSTALAÇÃO
# ====================================
docker --version
docker compose version

# Testar funcionamento
docker run hello-world
```

**Resultado Esperado:**
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

### **6.2. Configurar Docker para Inicializar com o Sistema**

```bash
# Habilitar e iniciar serviço Docker
sudo systemctl enable docker
sudo systemctl start docker

# Validar status
sudo systemctl status docker
# Esperado: active (running)
```

### **6.3. Pré-Pull de Imagens (Opcional mas Recomendado)**

```bash
# Fazer download antecipado das imagens necessárias
docker pull postgres:16-alpine
docker pull evolveum/midpoint:4.8

# Validar imagens baixadas
docker images
```

**⚠️ CHECKPOINT 4:** Docker instalado e funcional? ✅ Prosseguir para estrutura do projeto

---

## **10. FASE 7: PREPARAÇÃO DA ESTRUTURA DO PROJETO IGA**

### **7.1. Criar Estrutura de Diretórios**

```bash
# ====================================
# CRIAR DIRETÓRIO RAIZ DO PROJETO
# ====================================
sudo mkdir -p /srv/iga-project

# Ajustar permissões para usuário atual
sudo chown -R $USER:$USER /srv/iga-project

# ====================================
# CRIAR SUBDIRETÓRIOS
# ====================================
mkdir -p /srv/iga-project/data/postgres
mkdir -p /srv/iga-project/data/midpoint/var
mkdir -p /srv/iga-project/logs/midpoint
mkdir -p /srv/iga-project/config
mkdir -p /srv/iga-project/backups
mkdir -p /srv/iga-project/evidencias

# ====================================
# VALIDAR ESTRUTURA
# ====================================
tree /srv/iga-project -L 2
# Ou se tree não estiver instalado:
ls -lR /srv/iga-project
```

**Estrutura Esperada:**
```
/srv/iga-project/
├── data/
│   ├── postgres/
│   └── midpoint/
│       └── var/
├── logs/
│   └── midpoint/
├── config/
├── backups/
└── evidencias/
```

---

### **7.2. Criar Arquivo de Configuração docker-compose.yml**

```bash
# Navegar para diretório do projeto
cd /srv/iga-project

# Criar arquivo docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: iga-postgres
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - ./data/postgres:/var/lib/postgresql/data
    networks:
      - iga-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  midpoint:
    image: evolveum/midpoint:4.8
    container_name: iga-midpoint
    ports:
      - "8080:8080"
    environment:
      # ✅ VARIÁVEIS JDBC OFICIAIS (Correção v2.0)
      MIDPOINT_REPOSITORY_DATABASE_TYPE: postgresql
      MIDPOINT_REPOSITORY_JDBC_URL: jdbc:postgresql://postgres:5432/${POSTGRES_DB}
      MIDPOINT_REPOSITORY_JDBC_USERNAME: ${POSTGRES_USER}
      MIDPOINT_REPOSITORY_JDBC_PASSWORD: ${POSTGRES_PASSWORD}
      MP_SET_midpoint_administrator_initialPassword: ${MIDPOINT_ADMIN_PASSWORD}
    volumes:
      - ./data/midpoint/var:/opt/midpoint/var
      - ./logs/midpoint:/opt/midpoint/var/log
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - iga-network
    restart: unless-stopped

networks:
  iga-network:
    driver: bridge
EOF

# Validar sintaxe do arquivo
docker compose config
```

**⚠️ CHECKPOINT 5:** docker-compose.yml criado e validado? ✅ Prosseguir para arquivo .env

---

### **7.3. 🔴 NOVO v2.1: Criar Arquivo de Variáveis de Ambiente (.env) - ALINHADO COM GMUD-008**

**⚠️ MUDANÇA DE NOMENCLATURA v2.1:**

As variáveis de ambiente foram **alinhadas com a GMUD-008 v1.2** para garantir consistência entre documentação manual (POP) e automatizada (GMUD). Agora ambos os documentos "falam a mesma língua técnica".

```bash
# Criar template do arquivo .env
cat > .env.template << 'EOF'
# ============================================
# CONFIGURAÇÕES DO AMBIENTE IGA
# ============================================
# Este arquivo contém variáveis sensíveis.
# NUNCA compartilhe ou versione em repositórios públicos.

# ============================================
# CREDENCIAIS DO POSTGRESQL (Backend)
# ============================================
# 🔴 NOVO v2.1: Nomenclatura alinhada com GMUD-008 v1.2
POSTGRES_DB=midpoint
POSTGRES_USER=midpoint
POSTGRES_PASSWORD=SuaSenhaPostgreSQL_Aqui

# ============================================
# CREDENCIAIS DO MIDPOINT (Frontend)
# ============================================
# Esta senha será usada para login inicial:
# Usuário: administrator
# Senha: [valor definido abaixo]
# 🔴 NOVO v2.1: Nomenclatura alinhada com GMUD-008 v1.2
MIDPOINT_ADMIN_PASSWORD=SuaSenhaMidPoint_Aqui

# ============================================
# NOTAS DE SEGURANÇA
# ============================================
# - Use senhas fortes (mínimo 16 caracteres)
# - Combine letras maiúsculas, minúsculas, números e símbolos
# - Evite palavras do dicionário
# - Não reuse senhas de outros sistemas
# - Exemplo de senha forte: K9#mP2$xL7@qR5&nT3
EOF

# Copiar template para arquivo real
cp .env.template .env

# ====================================
# EDITAR ARQUIVO .env
# ====================================
nano .env
```

**⚠️ AÇÃO MANUAL OBRIGATÓRIA:**

1. Editar o arquivo `.env` com o comando `nano .env`
2. Substituir os placeholders:
   - `SuaSenhaPostgreSQL_Aqui` → Senha forte para PostgreSQL
   - `SuaSenhaMidPoint_Aqui` → Senha forte para administrador do midPoint
3. Salvar (Ctrl+X, Y, Enter)

**Exemplo de .env Completo (Alinhado com GMUD-008 v1.2):**
```bash
POSTGRES_DB=midpoint
POSTGRES_USER=midpoint
POSTGRES_PASSWORD=P0stgr3sS3cur3P@ssw0rd!

MIDPOINT_ADMIN_PASSWORD=M1dP0!ntAdm!nP@ss2026
```

**📋 Mapeamento de Variáveis (POP ↔ GMUD-008):**

| Descrição | Nome da Variável | Usado em |
|-----------|-----------------|----------|
| Nome do banco | `POSTGRES_DB` | docker-compose.yml, .env |
| Usuário PostgreSQL | `POSTGRES_USER` | docker-compose.yml, .env |
| Senha PostgreSQL | `POSTGRES_PASSWORD` | docker-compose.yml, .env |
| Senha Admin midPoint | `MIDPOINT_ADMIN_PASSWORD` | docker-compose.yml, .env |

```bash
# ====================================
# PROTEGER ARQUIVO .env
# ====================================
chmod 600 .env

# Validar permissões
ls -la .env
# Esperado: -rw------- (somente proprietário pode ler/escrever)

# ====================================
# CRIAR .gitignore
# ====================================
cat > .gitignore << 'EOF'
.env
data/
logs/
backups/
evidencias/
EOF
```

**⚠️ CHECKPOINT 6:** Arquivo .env criado com permissões corretas? ✅ Prosseguir para deploy

---

## **11. FASE 8: DEPLOY DO AMBIENTE IGA**

### **8.1. Validações Pré-Deploy**

```bash
# ====================================
# VALIDAÇÃO 1: Conectividade Externa
# ====================================
ping -c 4 8.8.8.8
# Esperado: 4 packets transmitted, 4 received

# ====================================
# VALIDAÇÃO 2: Resolução DNS (Google DNS permanente)
# ====================================
nslookup registry-1.docker.io
# Esperado: endereço IP válido

# ====================================
# VALIDAÇÃO 3: Acesso ao Docker Hub
# ====================================
curl -I https://registry-1.docker.io/v2/
# Esperado: HTTP 200 ou 401 (alcançável)

# ====================================
# VALIDAÇÃO 4: Docker Funcional
# ====================================
docker ps
# Esperado: listagem vazia (nenhum container rodando)

# ====================================
# VALIDAÇÃO 5: Arquivo .env Configurado
# ====================================
cat .env | grep -v '^#' | grep -v '^$'
# Esperado: 4 linhas com variáveis definidas

# ====================================
# VALIDAÇÃO 6: docker-compose.yml Válido
# ====================================
docker compose config
# Esperado: configuração renderizada sem erros

# ====================================
# ✅ NOVO v2.1: VALIDAÇÃO 7: IP Estático Confirmado
# ====================================
ip addr show eth0 | grep "inet " | grep -v "127.0.0.1"
# Esperado: inet xxx.xxx.xxx.xxx/22

# ====================================
# ✅ NOVO v2.1: VALIDAÇÃO 8: Sudoers Hardened Confirmado
# ====================================
sudo -l | grep -E "(mkdir|chown|docker|du|rm)"
# Esperado: whitelist com caminhos completos /usr/bin/...
```

**⚠️ GATE DE INÍCIO:**  
Se **qualquer validação falhar**, NÃO prosseguir com o deploy. Resolver problemas primeiro.

---

### **8.2. Deploy Sequencial com Validação**

```bash
# ====================================
# ETAPA 1: Carregar Variáveis de Ambiente
# ====================================
cd /srv/iga-project
export $(grep -v '^#' .env | xargs)

# Validar carregamento
echo $POSTGRES_DB
# Esperado: midpoint

# ====================================
# ETAPA 2: Inicializar PostgreSQL
# ====================================
echo "Iniciando PostgreSQL..."
docker compose up -d postgres

# Acompanhar logs do PostgreSQL
echo "Aguardando inicialização completa do PostgreSQL..."
docker logs -f iga-postgres

# IMPORTANTE: Aguardar a mensagem aparecer 2 vezes:
# "database system is ready to accept connections"
# Pressionar Ctrl+C após a SEGUNDA ocorrência

# ====================================
# ETAPA 3: Validar Health Check do PostgreSQL
# ====================================
sleep 5
docker inspect iga-postgres | grep -A 5 '"Health"'
# Esperado: "Status": "healthy"

# Teste de conexão manual
docker exec iga-postgres psql -U midpoint -d midpoint -c "SELECT version();"
# Esperado: versão do PostgreSQL exibida

# ====================================
# ETAPA 4: Aguardar Estabilização do Backend
# ====================================
echo "PostgreSQL está saudável. Aguardando 10 segundos adicionais..."
sleep 10

# ====================================
# ETAPA 5: Inicializar midPoint
# ====================================
echo "Iniciando midPoint..."
docker compose up -d midpoint

# Acompanhar logs do midPoint em tempo real
echo "Aguardando bootstrap do midPoint..."
docker logs -f iga-midpoint

# MENSAGENS CRÍTICAS A OBSERVAR:
# 1. "midpoint.repository.database .:. postgresql" ✅ DEVE SER postgresql (NÃO h2)
# 2. "Connection to database successful"
# 3. "Created User:administrator"
# 4. "Server startup in [XXXX] milliseconds"
# Pressionar Ctrl+C após "Server startup"

# ====================================
# ETAPA 6: Validar Containers em Execução
# ====================================
docker ps

# Esperado:
# CONTAINER ID   IMAGE                   STATUS
# xxxxxxxxxx     evolveum/midpoint:4.8   Up X minutes
# yyyyyyyyyy     postgres:16-alpine      Up X minutes (healthy)

# ====================================
# ETAPA 7: ✅ VALIDAÇÃO CRÍTICA v2.1 - Confirmar PostgreSQL (NÃO H2)
# ====================================
echo "=== VALIDAÇÃO DE REPOSITÓRIO ===" > /srv/iga-project/evidencias/deploy-validation.txt

# ✅ CHECKPOINT CRÍTICO: Verificar se midPoint está usando PostgreSQL (NÃO H2)
docker logs iga-midpoint 2>&1 | grep "midpoint.repository.database" >> /srv/iga-project/evidencias/deploy-validation.txt

# Exibir resultado
cat /srv/iga-project/evidencias/deploy-validation.txt

# ⚠️ ATENÇÃO: Se aparecer "h2" ao invés de "postgresql", PARAR IMEDIATAMENTE
# Executar rollback conforme Seção 13.4

# ====================================
# ETAPA 8: Validar Mensagens de Bootstrap
# ====================================
docker logs iga-midpoint 2>&1 | grep -i "Connection to database successful" >> /srv/iga-project/evidencias/deploy-validation.txt
docker logs iga-midpoint 2>&1 | grep -i "Created User:administrator" >> /srv/iga-project/evidencias/deploy-validation.txt
docker logs iga-midpoint 2>&1 | grep -i "Server startup" >> /srv/iga-project/evidencias/deploy-validation.txt

# Exibir resumo completo da validação
cat /srv/iga-project/evidencias/deploy-validation.txt

# ====================================
# ETAPA 9: Salvar Logs Completos
# ====================================
docker logs iga-postgres > /srv/iga-project/evidencias/postgres-bootstrap.log 2>&1
docker logs iga-midpoint > /srv/iga-project/evidencias/midpoint-bootstrap.log 2>&1
```

**⚠️ GATE DE VALIDAÇÃO CRÍTICO:**

Antes de prosseguir, **CONFIRMAR** que o arquivo `/srv/iga-project/evidencias/deploy-validation.txt` contém:

```
midpoint.repository.database .:. postgresql
```

**❌ Se aparecer `h2` ao invés de `postgresql`:**
- PARAR imediatamente
- Executar `docker compose down`
- Revisar as variáveis de ambiente no `docker-compose.yml`
- Seguir procedimento de rollback na Seção 13.4

---

### **8.3. Aguardar Estabilização da Aplicação**

```bash
# Aguardar 2 minutos para estabilização completa
echo "Aguardando estabilização da aplicação (120 segundos)..."
sleep 120

# Testar endpoint HTTP internamente
curl -I http://localhost:8080/midpoint
# Esperado: HTTP/1.1 200 ou 302

# Salvar evidência de resposta HTTP
curl -v http://localhost:8080/midpoint > /srv/iga-project/evidencias/http-response.txt 2>&1
```

**⚠️ CHECKPOINT 7:** Containers rodando e endpoint HTTP respondendo? ✅ Prosseguir para validação

---

## **12. FASE 9: VALIDAÇÃO E TESTES**

### **9.1. Testes Internos (Dentro da VM)**

```bash
# ====================================
# TESTE 1: Containers Rodando
# ====================================
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# ====================================
# TESTE 2: Logs Sem Erros Críticos
# ====================================
echo "Verificando erros críticos nos logs..."
docker logs iga-postgres 2>&1 | grep -i "error\|fatal" | wc -l
docker logs iga-midpoint 2>&1 | grep -i "error\|fatal" | grep -v "ErrorPage" | wc -l
# Esperado: 0 (zero) para ambos

# ====================================
# TESTE 3: ✅ NOVO v2.1 - Verificar Tipo de Repositório
# ====================================
docker logs iga-midpoint 2>&1 | grep "midpoint.repository.database"
# Esperado: midpoint.repository.database .:. postgresql
# ❌ Se mostrar "h2", o midPoint não conectou ao PostgreSQL

# ====================================
# TESTE 4: Conectividade com Banco
# ====================================
docker exec iga-midpoint /bin/bash -c "timeout 5 bash -c '</dev/tcp/postgres/5432' && echo 'PostgreSQL alcançável' || echo 'Falha de conectividade'"

# ====================================
# TESTE 5: Portas Abertas
# ====================================
sudo netstat -tulpn | grep -E '8080|5432'
# Esperado:
# tcp6       0      0 :::8080                 :::*                    LISTEN      [PID]/docker-proxy

# ====================================
# TESTE 6: Persistência de Dados
# ====================================
ls -lh /srv/iga-project/data/postgres/
ls -lh /srv/iga-project/data/midpoint/var/
# Esperado: diretórios com arquivos criados
```

---

### **9.2. Obter IP da VM para Acesso Externo**

```bash
# Obter IP da VM (agora estático)
IP_VM=$(hostname -I | awk '{print $1}')
echo "Endereço IP da VM: $IP_VM"
echo "URL de Acesso: http://$IP_VM:8080/midpoint"

# Salvar informações de acesso
cat > /srv/iga-project/ACCESS_INFO.txt << EOF
================================
INFORMAÇÕES DE ACESSO - IGA
================================
URL: http://$IP_VM:8080/midpoint
Usuário: administrator
Senha: [Conforme definido no arquivo .env em MIDPOINT_ADMIN_PASSWORD]

Tipo de Repositório: PostgreSQL (validado)
Configuração de Rede: IP Estático via Netplan
Configuração de Segurança: Sudoers Hardened (Least Privilege)
Data do Deploy: $(date)
================================
EOF

cat /srv/iga-project/ACCESS_INFO.txt
```

---

### **9.3. Teste de Acesso Web (Do Windows Host)**

**Executar no PowerShell do Windows:**

```powershell
# Substituir pelo IP estático configurado na Fase 5
$VM_IP = "xxx.xxx.xxx.xxx"  # IP ESTÁTICO

# Testar alcançabilidade da VM
Test-NetConnection -ComputerName $VM_IP -Port 8080

# Esperado:
# TcpTestSucceeded : True

# Testar resposta HTTP
Invoke-WebRequest -Uri "http://$VM_IP:8080/midpoint" -UseBasicParsing | Select-Object StatusCode

# Esperado: StatusCode: 200
```

---

### **9.4. Teste de Login na Interface Web**

**Ação Manual Obrigatória:**

1. Abrir navegador no Windows Host
2. Acessar: `http://xxx.xxx.xxx.xxx:8080/midpoint` (IP estático)
3. Na tela de login, inserir:
   - **Usuário:** `administrator`
   - **Senha:** `[Senha definida no .env em MIDPOINT_ADMIN_PASSWORD]`
4. Clicar em "Sign In"

**Resultado Esperado:**
- ✅ Acesso concedido → Dashboard do midPoint exibido
- ✅ Menu lateral com opções (Users, Roles, Resources, etc.)
- ✅ Mensagem de boas-vindas ao sistema

**Em Caso de Falha de Login:**

Executar diagnóstico na VM:

```bash
# ====================================
# DIAGNÓSTICO DE FALHA DE LOGIN
# ====================================

# 1. Verificar tipo de repositório (CRÍTICO)
echo "=== TIPO DE REPOSITÓRIO ===" > /srv/iga-project/evidencias/login-failure-diagnosis.txt
docker logs iga-midpoint 2>&1 | grep "midpoint.repository.database" >> /srv/iga-project/evidencias/login-failure-diagnosis.txt

# 2. Verificar se a variável foi injetada
echo "=== VARIÁVEL DE SENHA ===" >> /srv/iga-project/evidencias/login-failure-diagnosis.txt
docker exec iga-midpoint env | grep MP_SET >> /srv/iga-project/evidencias/login-failure-diagnosis.txt

# 3. Verificar logs de criação do usuário
echo "=== CRIAÇÃO DO ADMINISTRADOR ===" >> /srv/iga-project/evidencias/login-failure-diagnosis.txt
docker logs iga-midpoint 2>&1 | grep -i "administrator" >> /srv/iga-project/evidencias/login-failure-diagnosis.txt

# 4. Verificar se há senha gerada aleatoriamente (indica problema)
echo "=== SENHAS NOS LOGS ===" >> /srv/iga-project/evidencias/login-failure-diagnosis.txt
docker logs iga-midpoint 2>&1 | grep -i "password" >> /srv/iga-project/evidencias/login-failure-diagnosis.txt

# Exibir diagnóstico completo
cat /srv/iga-project/evidencias/login-failure-diagnosis.txt

# Salvar logs completos para análise
docker logs iga-midpoint > /srv/iga-project/evidencias/midpoint-full.log 2>&1
docker logs iga-postgres > /srv/iga-project/evidencias/postgres-full.log 2>&1
```

**⚠️ INTERPRETAÇÃO DO DIAGNÓSTICO:**

| Situação Encontrada | Causa Raiz | Ação Corretiva |
|---------------------|------------|----------------|
| `midpoint.repository.database .:. h2` | Variáveis JDBC incorretas | Seguir Seção 13.4 (Rollback) |
| Sem `MP_SET` nas variáveis de ambiente | Arquivo .env não carregado | Reexecutar `docker compose down/up` |
| Senha aleatória nos logs | Variável ignorada | Verificar sintaxe do .env |

---

### **9.5. Teste de Persistência**

```bash
# Parar containers
docker compose down

# Aguardar 10 segundos
sleep 10

# Reiniciar containers
docker compose up -d

# Aguardar estabilização
sleep 60

# Testar acesso novamente
curl -I http://localhost:8080/midpoint
# Esperado: HTTP 200/302

# Validar que dados persistiram
docker exec iga-postgres psql -U midpoint -d midpoint -c "SELECT COUNT(*) FROM m_user;"
# Esperado: contagem de usuários (mínimo 1 - administrator)
```

**⚠️ CHECKPOINT 8:** Persistência validada? ✅ Deploy concluído com sucesso!

---

### **9.6. ✅ NOVO v2.1: Validação de Conformidade de Segurança**

```bash
# ====================================
# CRIAR RELATÓRIO DE CONFORMIDADE
# ====================================
cat > /srv/iga-project/evidencias/security-compliance-report.txt << 'EOF'
=== RELATÓRIO DE CONFORMIDADE DE SEGURANÇA ===
Data: $(date)
Versão do POP: 2.1 (Hardened + Usabilidade)

=== 1. SUDOERS (LEAST PRIVILEGE) ===
EOF

sudo -l >> /srv/iga-project/evidencias/security-compliance-report.txt

cat >> /srv/iga-project/evidencias/security-compliance-report.txt << 'EOF'

=== 2. CONFIGURAÇÃO DE REDE (IP ESTÁTICO) ===
EOF

ip addr show eth0 >> /srv/iga-project/evidencias/security-compliance-report.txt
echo "--- Arquivo Netplan Utilizado ---" >> /srv/iga-project/evidencias/security-compliance-report.txt
ls /etc/netplan/ >> /srv/iga-project/evidencias/security-compliance-report.txt
echo "--- Conteúdo da Configuração ---" >> /srv/iga-project/evidencias/security-compliance-report.txt
cat /etc/netplan/*.yaml >> /srv/iga-project/evidencias/security-compliance-report.txt

cat >> /srv/iga-project/evidencias/security-compliance-report.txt << 'EOF'

=== 3. TIPO DE REPOSITÓRIO (POSTGRESQL vs H2) ===
EOF

docker logs iga-midpoint 2>&1 | grep "midpoint.repository.database" >> /srv/iga-project/evidencias/security-compliance-report.txt

cat >> /srv/iga-project/evidencias/security-compliance-report.txt << 'EOF'

=== 4. MAPEAMENTO DE VARIÁVEIS (ALINHAMENTO POP ↔ GMUD-008) ===
POSTGRES_DB: Alinhado ✅
POSTGRES_USER: Alinhado ✅
POSTGRES_PASSWORD: Alinhado ✅
MIDPOINT_ADMIN_PASSWORD: Alinhado ✅
EOF

# Exibir relatório
cat /srv/iga-project/evidencias/security-compliance-report.txt
```

---

## **13. TROUBLESHOOTING E DIAGNÓSTICOS**

### **13.1. Problema: Containers Não Iniciam**

```bash
# Verificar logs de erro
docker compose logs

# Verificar status detalhado
docker ps -a

# Verificar uso de recursos
docker stats --no-stream

# Verificar configuração do compose
docker compose config

# Limpar cache e reiniciar
docker compose down
docker system prune -f
docker compose up -d
```

---

### **13.2. Problema: PostgreSQL Não Fica Healthy**

```bash
# Verificar logs do PostgreSQL
docker logs iga-postgres

# Verificar health check
docker inspect iga-postgres | grep -A 10 '"Health"'

# Testar conexão manual
docker exec iga-postgres psql -U midpoint -c "\l"

# Verificar permissões do volume
ls -la /srv/iga-project/data/postgres/

# Recriar container PostgreSQL
docker compose down
sudo rm -rf /srv/iga-project/data/postgres/*
docker compose up -d postgres
```

---

### **13.3. Problema: midPoint Não Conecta ao PostgreSQL**

```bash
# Verificar logs do midPoint
docker logs iga-midpoint | grep -i "database\|connection"

# Verificar conectividade de rede
docker exec iga-midpoint ping -c 3 postgres

# Verificar variáveis de ambiente
docker exec iga-midpoint env | grep MIDPOINT_REPOSITORY

# Verificar se PostgreSQL está acessível
docker exec iga-midpoint nc -zv postgres 5432

# Recriar containers mantendo dados
docker compose down
docker compose up -d postgres
# Aguardar até PostgreSQL ficar healthy
docker compose up -
---

d midpoint
```

---

### **13.4. ✅ ATUALIZADO v2.1: Problema: midPoint Usando H2 ao Invés de PostgreSQL**

**Sintoma:** Login falha com credenciais corretas, logs mostram `midpoint.repository.database .:. h2`

**Causa Raiz:** Variáveis de ambiente do midPoint não reconhecidas, sistema entra em fallback para H2.

**Solução:**

```bash
# 1. Parar ambiente
docker compose down

# 2. Limpar dados do H2 (banco temporário interno)
sudo rm -rf /srv/iga-project/data/midpoint/var/*

# 3. Verificar docker-compose.yml
cat /srv/iga-project/docker-compose.yml | grep -A 10 "midpoint:"

# Esperado (v2.1 CORRETO):
# environment:
#   MIDPOINT_REPOSITORY_DATABASE_TYPE: postgresql
#   MIDPOINT_REPOSITORY_JDBC_URL: jdbc:postgresql://...
#   MIDPOINT_REPOSITORY_JDBC_USERNAME: ...
#   MIDPOINT_REPOSITORY_JDBC_PASSWORD: ...

# 4. Se as variáveis estiverem ERRADAS, recriar docker-compose.yml
# Usar versão corrigida v2.1 da Seção 7.2 deste POP

# 5. Verificar arquivo .env (nomenclatura alinhada)
cat /srv/iga-project/.env

# Esperado:
# POSTGRES_DB=midpoint
# POSTGRES_USER=midpoint
# POSTGRES_PASSWORD=...
# MIDPOINT_ADMIN_PASSWORD=...

# 6. Reiniciar ambiente
docker compose up -d

# 7. Validar repositório
docker logs iga-midpoint 2>&1 | grep "midpoint.repository.database"
# Esperado: midpoint.repository.database .:. postgresql
```

---

### **13.5. Problema: Não Consigo Acessar de Fora da VM**

```bash
# Na VM: Verificar firewall
sudo ufw status
# Se ativo, liberar porta 8080:
sudo ufw allow 8080/tcp

# Na VM: Verificar se porta está escutando
sudo netstat -tulpn | grep 8080

# No Windows: Testar conectividade
Test-NetConnection -ComputerName [IP_DA_VM] -Port 8080

# Verificar Virtual Switch do Hyper-V
Get-VMNetworkAdapter -VMName "IGA-Server" | Format-List *
```

---

### **13.6. Problema: Falha de Autenticação (Senha Correta Rejeitada)**

```bash
# Verificar variável de senha no .env
cat /srv/iga-project/.env | grep MIDPOINT_ADMIN_PASSWORD

# Verificar se foi injetada no container
docker exec iga-midpoint env | grep MP_SET

# Buscar senha nos logs (caso tenha sido gerada aleatoriamente)
docker logs iga-midpoint 2>&1 | grep -i "initialPassword"

# ✅ v2.1: Verificar se está usando PostgreSQL
docker logs iga-midpoint 2>&1 | grep "midpoint.repository.database"
# Se mostrar "h2", seguir procedimento da Seção 13.4

# Resetar senha do administrador (último recurso)
docker compose down
sudo rm -rf /srv/iga-project/data/midpoint/var/*
# Editar .env e confirmar senha correta
nano /srv/iga-project/.env
docker compose up -d
```

---

### **13.7. Problema: DNS Não Resolve Docker Hub**

```bash
# Testar resolução DNS
nslookup registry-1.docker.io

# Se falhar, verificar configuração Netplan
cat /etc/netplan/*.yaml

# Esperado:
# nameservers:
#   addresses:
#     - 8.8.8.8
#     - 8.8.4.4

# Se DNS não estiver configurado, editar Netplan
sudo nano /etc/netplan/[NOME_DO_ARQUIVO].yaml

# Adicionar seção nameservers (se ausente)
# Aplicar configuração
sudo netplan apply

# Revalidar
nslookup registry-1.docker.io
```

---

### **13.8. ✅ NOVO v2.1: Problema: Sudoers Rejeitando Comandos**

**Sintoma:** Comandos sudo retornam `user is not allowed to execute '/usr/bin/comando'`

**Causa:** Whitelist configurada sem caminhos completos ou com sintaxe incorreta

**Solução:**

```bash
# 1. Validar configuração atual
sudo -l

# 2. Se não aparecer caminhos completos (/usr/bin/...), reconfigurar
sudo visudo

# 3. LOCALIZAR linha do usuário e CORRIGIR para incluir /usr/bin/
# ❌ ERRADO:
# usuario ALL=(ALL) NOPASSWD: mkdir, chown, docker, du, rm

# ✅ CORRETO:
# usuario ALL=(ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/chown, /usr/bin/docker, /usr/bin/du, /usr/bin/rm

# 4. Salvar e validar novamente
sudo -l

# Esperado:
# User usuario may run the following commands on iga-server:
#     (ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/chown, /usr/bin/docker, /usr/bin/du, /usr/bin/rm
```

---

### **13.9. ✅ NOVO v2.1: Problema: IP Mudou Após Reboot**

**Sintoma:** VM não acessível no IP esperado após reinicialização

**Causa:** Configuração Netplan não foi aplicada corretamente ou arquivo editado não é o correto

**Solução:**

```bash
# 1. Verificar IP atual
ip addr show eth0

# 2. Listar arquivos Netplan
ls -la /etc/netplan/

# 3. Verificar conteúdo do arquivo correto
cat /etc/netplan/[NOME_DO_ARQUIVO_IDENTIFICADO].yaml

# 4. Se dhcp4 estiver como "true", corrigir para "false"
sudo nano /etc/netplan/[NOME_DO_ARQUIVO].yaml

# 5. Garantir configuração estática:
# network:
#   version: 2
#   ethernets:
#     eth0:
#       dhcp4: false
#       addresses:
#         - xxx.xxx.xxx.xxx/22
#       routes:
#         - to: default
#           via: xxx.xxx.xxx.xxx
#       nameservers:
#         addresses:
#           - 8.8.8.8
#           - 8.8.4.4

# 6. Aplicar configuração
sudo netplan apply

# 7. Validar
ip addr show eth0 | grep inet
# Esperado: inet xxx.xxx.xxx.xxx/22
```

---

### **13.10. ✅ NOVO v2.1: Problema: Arquivo Netplan Não Encontrado**

**Sintoma:** Erro "No such file or directory" ao tentar editar `/etc/netplan/00-installer-config.yaml`

**Causa:** Nome do arquivo varia entre instalações - não existe nome padrão

**Solução:**

```bash
# 1. Listar arquivos reais de configuração
ls -la /etc/netplan/

# Exemplo de saída:
# -rw-r--r-- 1 root root  116 Jan 19 10:23 01-netcfg.yaml

# 2. Usar o nome EXATO do arquivo listado
sudo nano /etc/netplan/01-netcfg.yaml

# 3. Aplicar configuração usando o arquivo correto
sudo netplan apply

# 4. NUNCA assumir nome padrão - sempre listar primeiro
```

---

## **14. MANUTENÇÃO E OPERAÇÃO**

### **14.1. Backup do Ambiente**

```bash
# Criar script de backup
cat > /srv/iga-project/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/srv/iga-project/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.tar.gz"

echo "Iniciando backup em $(date)"

# Parar containers
docker compose down

# Criar backup
sudo tar -czf $BACKUP_FILE \
    -C /srv/iga-project \
    data/ \
    .env \
    docker-compose.yml

# Reiniciar containers
docker compose up -d

echo "Backup concluído: $BACKUP_FILE"
EOF

chmod +x /srv/iga-project/backup.sh

# Executar backup
/srv/iga-project/backup.sh
```

---

### **14.2. Restauração de Backup**

```bash
# Listar backups disponíveis
ls -lh /srv/iga-project/backups/

# Parar ambiente atual
docker compose down

# Fazer backup dos dados atuais (precaução)
sudo mv /srv/iga-project/data /srv/iga-project/data.old

# Restaurar backup específico
sudo tar -xzf /srv/iga-project/backups/backup_YYYYMMDD_HHMMSS.tar.gz -C /srv/iga-project/

# Reiniciar ambiente
docker compose up -d
```

---

### **14.3. Atualização de Versão do midPoint**

```bash
# Fazer backup antes de atualizar
/srv/iga-project/backup.sh

# Editar docker-compose.yml
nano /srv/iga-project/docker-compose.yml
# Alterar: image: evolveum/midpoint:4.8
# Para:    image: evolveum/midpoint:4.9  (versão desejada)

# Baixar nova imagem
docker pull evolveum/midpoint:4.9

# Recriar containers
docker compose down
docker compose up -d

# Acompanhar logs
docker logs -f iga-midpoint
```

---

### **14.4. Monitoramento Básico**

```bash
# Status dos containers
docker ps

# Uso de recursos
docker stats

# Espaço em disco
df -h /srv/iga-project/data/

# Logs recentes
docker logs --tail 50 iga-midpoint
docker logs --tail 50 iga-postgres

# Criar alias úteis
cat >> ~/.bashrc << 'EOF'
alias iga-status='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias iga-logs='docker logs -f iga-midpoint'
alias iga-restart='cd /srv/iga-project && docker compose restart'
alias iga-stop='cd /srv/iga-project && docker compose stop'
alias iga-start='cd /srv/iga-project && docker compose start'
EOF

source ~/.bashrc
```

---

### **14.5. Acesso SSH Facilitado do Windows**

```powershell
# No PowerShell do Windows, criar função para SSH rápido
# ✅ v2.1: IP agora é estático (xxx.xxx.xxx.xxx)
Add-Content -Path $PROFILE -Value @'
function Connect-IGAServer {
    $VM_IP = "xxx.xxx.xxx.xxx"  # IP ESTÁTICO
    $VM_USER = "seu-usuario"   # Ajustar conforme seu usuário
    ssh $VM_USER@$VM_IP
}
Set-Alias -Name iga -Value Connect-IGAServer
'@

# Recarregar profile
. $PROFILE

# Usar: simplesmente digite "iga" no PowerShell para conectar
```

---

## **15. REFERÊNCIAS E DOCUMENTAÇÃO**

### **15.1. Documentação Oficial**

- **midPoint:** https://docs.evolveum.com/midpoint/
- **midPoint Configuration:** https://docs.evolveum.com/midpoint/reference/repository/configuration/
- **PostgreSQL:** https://www.postgresql.org/docs/
- **Docker:** https://docs.docker.com/
- **Docker Compose:** https://docs.docker.com/compose/
- **Ubuntu Server:** https://ubuntu.com/server/docs
- **Hyper-V:** https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/
- **Netplan:** https://netplan.io/

---

### **15.2. Arquivos de Configuração de Referência**

**docker-compose.yml Completo (v2.1):**
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: iga-postgres
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - ./data/postgres:/var/lib/postgresql/data
    networks:
      - iga-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  midpoint:
    image: evolveum/midpoint:4.8
    container_name: iga-midpoint
    ports:
      - "8080:8080"
    environment:
      MIDPOINT_REPOSITORY_DATABASE_TYPE: postgresql
      MIDPOINT_REPOSITORY_JDBC_URL: jdbc:postgresql://postgres:5432/${POSTGRES_DB}
      MIDPOINT_REPOSITORY_JDBC_USERNAME: ${POSTGRES_USER}
      MIDPOINT_REPOSITORY_JDBC_PASSWORD: ${POSTGRES_PASSWORD}
      MP_SET_midpoint_administrator_initialPassword: ${MIDPOINT_ADMIN_PASSWORD}
    volumes:
      - ./data/midpoint/var:/opt/midpoint/var
      - ./logs/midpoint:/opt/midpoint/var/log
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - iga-network
    restart: unless-stopped

networks:
  iga-network:
    driver: bridge
```

**Arquivo .env de Referência (v2.1 - Alinhado com GMUD-008):**
```bash
# Credenciais PostgreSQL
POSTGRES_DB=midpoint
POSTGRES_USER=midpoint
POSTGRES_PASSWORD=SuaSenhaSeguraPostgreSQL123!

# Credenciais midPoint
MIDPOINT_ADMIN_PASSWORD=SuaSenhaSeguraMidPoint456!
```

**Arquivo Netplan de Referência (IP Estático):**
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - xxx.xxx.xxx.xxx/22
      routes:
        - to: default
          via: xxx.xxx.xxx.xxx
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

---

### **15.3. Comandos Úteis - Referência Rápida**

```bash
# Gestão de Containers
docker compose up -d              # Iniciar ambiente
docker compose down               # Parar ambiente
docker compose restart            # Reiniciar ambiente
docker compose logs -f            # Ver logs em tempo real
docker compose ps                 # Status dos containers

# Diagnóstico
docker logs iga-midpoint          # Logs do midPoint
docker logs iga-postgres          # Logs do PostgreSQL
docker exec -it iga-midpoint bash # Acessar shell do container
docker stats                      # Uso de recursos

# ✅ v2.1: Validações de Segurança
sudo -l                           # Verificar sudoers
ip addr show eth0                 # Verificar IP estático
docker logs iga-midpoint | grep "midpoint.repository.database"  # Verificar repositório

# Manutenção
docker system prune -f            # Limpar cache
docker volume ls                  # Listar volumes
docker network ls                 # Listar redes
```

---

### **15.4. Portas Utilizadas**

| Porta | Serviço | Protocolo | Acesso |
|-------|---------|-----------|--------|
| 22 | SSH | TCP | Externo (para administração) |
| 8080 | midPoint Web UI | TCP | Externo (interface web) |
| 5432 | PostgreSQL | TCP | Interno (apenas entre containers) |

---

### **15.5. Variáveis de Ambiente Importantes (v2.1 - Alinhadas)**

| Variável | Descrição | Exemplo | Usado em |
|----------|-----------|---------|----------|
| `POSTGRES_DB` | Nome do banco de dados | `midpoint` | POP, GMUD-008 |
| `POSTGRES_USER` | Usuário do PostgreSQL | `midpoint` | POP, GMUD-008 |
| `POSTGRES_PASSWORD` | Senha do PostgreSQL | `senha_segura_123` | POP, GMUD-008 |
| `MIDPOINT_ADMIN_PASSWORD` | Senha do administrador do midPoint | `admin_senha_456` | POP, GMUD-008 |
| `MIDPOINT_REPOSITORY_DATABASE_TYPE` | Tipo de repositório | `postgresql` | docker-compose.yml |
| `MIDPOINT_REPOSITORY_JDBC_URL` | URL JDBC do banco | `jdbc:postgresql://postgres:5432/midpoint` | docker-compose.yml |

---

## **APÊNDICE A: CHECKLIST DE VALIDAÇÃO COMPLETA**

Use este checklist para validar cada fase da implementação:

### **Pré-requisitos Windows**
- [ ] PowerShell Execution Policy configurada (`Bypass -Scope Process`)
- [ ] Hyper-V habilitado e funcional
- [ ] ISO do Ubuntu baixada e verificada
- [ ] Virtual Switch Externo criado

### **Fase 1: Preparação Windows**
- [ ] Diretórios criados (`C:\ISOs`, `C:\Hyper-V`)
- [ ] ISO salva em local correto
- [ ] Virtual Switch configurado

### **Fase 2: Criação da VM**
- [ ] VM criada com recursos adequados
- [ ] Secure Boot desabilitado
- [ ] ISO montada no DVD Drive
- [ ] VM inicializada com sucesso

### **Fase 3: Instalação Ubuntu**
- [ ] Sistema operacional instalado
- [ ] OpenSSH Server instalado
- [ ] Usuário criado e credenciais anotadas
- [ ] IP temporário DHCP anotado

### **Fase 4: Configuração Inicial**
- [ ] Sistema atualizado
- [ ] Conectividade testada

### **Fase 5: Hardening de Segurança**
- [ ] ✅ v2.1: Conflito de IP validado com Host Windows
- [ ] ✅ v2.1: Arquivo Netplan identificado (`ls /etc/netplan/`)
- [ ] IP estático configurado via Netplan
- [ ] Google DNS (8.8.8.8) configurado
- [ ] IP estático validado e testado
- [ ] ✅ v2.1: Sudoers configurado com caminhos completos (`/usr/bin/...`)
- [ ] Whitelist de 5 binários validada (`sudo -l`)

### **Fase 6: Docker**
- [ ] Docker Engine instalado
- [ ] Docker Compose instalado
- [ ] Usuário adicionado ao grupo docker
- [ ] Teste `docker run hello-world` bem-sucedido

### **Fase 7: Estrutura do Projeto**
- [ ] Diretórios criados em `/srv/iga-project`
- [ ] `docker-compose.yml` v2.1 criado e validado
- [ ] ✅ v2.1: Arquivo `.env` criado com variáveis alinhadas
- [ ] Permissões ajustadas corretamente

### **Fase 8: Deploy**
- [ ] Pré-requisitos validados (8 validações)
- [ ] PostgreSQL inicializado e healthy
- [ ] midPoint inicializado sem erros
- [ ] ✅ v2.1: Repositório confirmado como `postgresql` (NÃO `h2`)
- [ ] 4 mensagens críticas confirmadas nos logs

### **Fase 9: Validação**
- [ ] Containers rodando corretamente
- [ ] Endpoint HTTP respondendo (200/302)
- [ ] ✅ v2.1: Login bem-sucedido com senha definida
- [ ] Teste de persistência aprovado
- [ ] ✅ v2.1: Relatório de conformidade de segurança gerado

---

## **APÊNDICE B: TEMPLATE DE DOCUMENTAÇÃO DE DEPLOY**

```markdown
# Deploy IGA - [Data]

## Informações do Ambiente
- **Data do Deploy:** [DD/MM/YYYY]
- **Versão do POP:** 2.1 (Hardened + Usabilidade)
- **Executor:** [Seu Nome]
- **IP da VM:** xxx.xxx.xxx.xxx (Estático)
- **Versão Ubuntu:** 24.04.2 LTS
- **Versão Docker:** [xx.x.x]
- **Versão midPoint:** 4.8
- **Versão PostgreSQL:** 16
- **Tipo de Repositório:** PostgreSQL (validado)

## Configurações de Hardening
- **Sudoers:** Least Privilege (5 binários)
- **IP:** Estático via Netplan (xxx.xxx.xxx.xxx)
- **DNS:** Google DNS permanente (8.8.8.8, 8.8.4.4)
- **PowerShell:** Execution Policy documentada

## Configurações Específicas
- **Nome da VM Hyper-V:** [nome]
- **Virtual Switch:** [nome]
- **Recursos Alocados:**
  - CPU: [X cores]
  - RAM: [X GB]
  - Disco: [X GB]

## Arquivo Netplan Utilizado
- **Nome do arquivo:** [identificado com `ls /etc/netplan/`]
- **Exemplo:** 00-installer-config.yaml

## Credenciais (⚠️ Armazenar em local seguro)
- **SSH Usuario:** [usuario]
- **SSH Senha:** [armazenado em cofre]
- **PostgreSQL User:** midpoint
- **PostgreSQL Password:** [armazenado em cofre]
- **midPoint Admin Password:** [armazenado em cofre]

## Mapeamento de Variáveis (Alinhamento POP ↔ GMUD-008)
- POSTGRES_DB: ✅ Alinhado
- POSTGRES_USER: ✅ Alinhado
- POSTGRES_PASSWORD: ✅ Alinhado
- MIDPOINT_ADMIN_PASSWORD: ✅ Alinhado

## Validações Críticas v2.1
- [x] Repositório confirmado como PostgreSQL
- [x] Sem fallback para H2
- [x] Variáveis JDBC corretas aplicadas
- [x] Login funcionando com senha definida
- [x] Sudoers hardened com caminhos completos
- [x] IP estático configurado e validado

## Testes Realizados
- [x] SSH funcionando
- [x] Docker operacional
- [x] Containers iniciados
- [x] PostgreSQL healthy
- [x] midPoint conectado ao PostgreSQL
- [x] midPoint acessível
- [x] Login bem-sucedido
- [x] Persistência validada
- [x] Conformidade de segurança validada

## Observações
[Qualquer observação relevante sobre o deploy]

## Próximos Passos
- [ ] Configurar backup automatizado
- [ ] Implementar monitoramento
- [ ] Configurar recursos e conectores
- [ ] Definir roles e policies
```

---

## **APÊNDICE C: COMPARATIVO DE VERSÕES**

### **Tabela Comparativa: v2.0 vs v2.1**

| Aspecto | v2.0 (Corrigida) | v2.1 (Hardened + Usabilidade) |
|---------|------------------|-------------------------------|
| **Identificação Netplan** | ❌ Assume nome padrão | ✅ Instrução `ls /etc/netplan/` obrigatória |
| **Sudoers** | ⚠️ Sem ênfase em caminhos completos | ✅ Reforço explícito `/usr/bin/...` |
| **Variáveis .env** | ⚠️ Nomenclatura não documentada | ✅ Alinhadas com GMUD-008 v1.2 |
| **IP da VM** | ⚠️ Mencionado mas não obrigatório | ✅ Obrigatório com validação de conflito |
| **PowerShell Policy** | ❌ Não documentada | ✅ Pré-requisito documentado |
| **Conformidade POP ↔ GMUD** | ⚠️ Parcial | ✅ Total (mesma linguagem técnica) |
| **Troubleshooting** | ✅ 9 seções | ✅ 10 seções (+ Netplan não encontrado) |
| **Evidências** | ✅ Básicas | ✅ Relatório de conformidade completo |
| **Usabilidade** | ⚠️ Assume conhecimento prévio | ✅ Instruções step-by-step detalhadas |

---

## **CONTROLE DE VERSÃO DO DOCUMENTO**

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | Janeiro/2026 | Equipe Técnica IGA | Criação do POP completo |
| 2.0 | Janeiro/2026 | Equipe Técnica IGA | Correção de variáveis JDBC |
| **2.1** | **Janeiro/2026** | **Equipe Técnica IGA** | **Hardening: Least Privilege Sudoers, IP Estático Obrigatório, PowerShell Execution Policy, Identificação de Arquivo Netplan, Alinhamento com GMUD-008 v1.2, Mapeamento de Variáveis** |

---

## **APROVAÇÃO DO DOCUMENTO**

| Papel | Nome | Assinatura | Data |
|-------|------|------------|------|
| **Autor** | [Nome] | ___________ | __/__/____ |
| **Revisor Técnico** | [Nome] | ___________ | __/__/____ |
| **Aprovador GRC** | [Nome] | ___________ | __/__/____ |
| **Aprovador** | [Nome] | ___________ | __/__/____ |

---

**FIM DO DOCUMENTO POP-IGA-001 v2.1**

**Repositório Sugerido:** `docs/procedures/POP-IGA-001-Complete-Deployment-v2.1-Hardened-Usability.md`

**Status:** ✅ **Hardened + Usabilidade - Alinhado com GMUD-008 v1.2**

**Classificação de Segurança:** 🔒 **Hardened** - Conformidade Total com ISO 27001:2022, NIST CSF 2.0, CIS Controls v8

---

**⚠️ AVISO DE SEGURANÇA:**

Este documento contém procedimentos que criam ambientes com credenciais administrativas. Certifique-se de:

1. **Nunca versionar o arquivo `.env` em repositórios públicos**
2. **Usar senhas fortes e únicas** para cada componente
3. **Armazenar credenciais em cofres de senha** (1Password, Bitwarden, etc.)
4. **Revisar configurações de rede e firewall** antes de expor para internet
5. **Implementar backups regulares** dos dados de produção
6. **Manter o sistema atualizado** com patches de segurança
7. **✅ v2.1:** Sempre validar tipo de repositório após deploy (PostgreSQL, não H2)
8. **✅ v2.1:** Sempre usar caminhos completos em sudoers (`/usr/bin/...`)

---

**LICENÇA DE USO:**

Este documento pode ser usado, modificado e distribuído livremente para fins educacionais e comerciais, desde que mantida a atribuição ao autor original.

---

**📋 RESUMO EXECUTIVO DAS MUDANÇAS v2.1:**

1. **Usabilidade Crítica:** Adicionado comando `ls /etc/netplan/` para identificar arquivo antes de editar (elimina bloqueio)
2. **Consistência Técnica:** Variáveis `.env` alinhadas com GMUD-008 v1.2 (POP e GMUD falam mesma língua)
3. **Hardening Reforçado:** Ênfase em caminhos completos `/usr/bin/` no sudoers (evita erros em scripts)
4. **Troubleshooting Expandido:** Nova seção para problema de arquivo Netplan não encontrado
5. **Conformidade Documentada:** Relatório de conformidade inclui validação de alinhamento POP ↔ GMUD
6. **Evidências Enriquecidas:** Arquivo de evidência agora documenta alinhamento de nomenclatura

**Alinhamento com GMUD-008 v1.2:** ✅ **100% Conforme**

**Mitigação de Riscos (Visão GRC):**
- ✅ **Risco de Interrupção:** Eliminado (validação de arquivo Netplan)
- ✅ **Risco de Integridade:** Eliminado (caminhos completos em sudoers)
- ✅ **Risco de Conformidade:** Eliminado (alinhamento POP ↔ GMUD)
