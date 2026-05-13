text

``# 📋 TERMO DE ABERTURA DO PROJETO (TAP) **Projeto:** PRJ007 - Implementação de Cofre de Senhas (HashiCorp Vault)   **Versão:** 2.0 (Final - Production-Ready)   **Data:** 03 de Fevereiro de 2026   **Responsável:** Paulo Feitosa   **Contexto:** Living Lab Fiqueok - Greenfield Environment --- ## 1. IDENTIFICAÇÃO DO PROJETO | Item | Descrição | |------|-----------| | **Código do Projeto** | PRJ007 | | **Nome** | Implementação de Privileged Access Management - HashiCorp Vault | | **Categoria** | Segurança da Informação / PAM (Privileged Access Management) | | **Programa** | Living Lab Fiqueok - Identity & Access Governance Stack | | **Patrocinador** | Paulo Feitosa (IAM Specialist/Auditor) | | **Gerente do Projeto** | Paulo Feitosa | | **Data de Início** | 03/02/2026 | | **Data de Término Prevista** | 04/02/2026 | | **Duração Estimada** | 2 dias úteis (7.5-8 horas efetivas) | --- ## 2. CONTEXTO E JUSTIFICATIVA ### 2.1 Situação Atual O Living Lab Fiqueok possui atualmente **múltiplos secrets críticos armazenados de forma insegura**: **Inventário de Secrets em Plaintext:** - Senhas de banco de dados (MySQL root, PostgreSQL midPoint) - Credenciais OAuth 2.0 (client_secret) - Senhas administrativas (midPoint admin) - Keystores e certificados - Tokens de API (futuros) **Métodos Inadequados de Armazenamento:** - ❌ Hardcoded em arquivos `.env` (exposto em versionamento) - ❌ Plaintext em `docker-compose.yml` - ❌ Senhas em linha de comando bash (histórico exposto) - ❌ Documentação em Obsidian (texto puro) **Evidência do Problema:** ```bash # Exemplo real identificado durante PRJ006: docker exec orange-db mysql -u root -pSENHA_EXPOSTA orangehrm                                     ↑                            Senha visível em:                            - bash_history                            - ps aux (durante execução)                            - logs de sistema``

## 2.2 Gatilho do Projeto

Durante planejamento do PRJ008 (API Proxy Integration), identificou-se que a implementação estava **repetindo anti-padrões de segurança**:

python

`# Código planejado (ANTES do PRJ007): db_config = {     "password": "SENHA_HARDCODED"  # ← Inaceitável! }`

**Decisão Estratégica:** Interromper PRJ008 e implementar **PAM Foundation** primeiro, garantindo que toda nova infraestrutura nasça com gestão adequada de secrets.

## 2.3 Alinhamento Estratégico

**Frameworks de Compliance:**

- **ISO 27001:2022**
    
    - A.9.4.3 - Password management system
        
    - A.8.3 - Media handling (cryptographic keys)
        
    - A.14.1.3 - Protection of transaction services
        
- **NIST Cybersecurity Framework**
    
    - PR.AC-1 - Identities and credentials managed
        
    - PR.DS-1 - Data-at-rest protected
        
    - DE.CM-3 - Personnel activity monitored
        
- **Zero Trust Architecture (NIST SP 800-207)**
    
    - Princípio: "Never trust, always verify"
        
    - Secrets com ciclo de vida gerenciado
        
    - Auditoria de acesso a credenciais
        

**Posicionamento no Living Lab:**  
O PRJ007 estabelece **fundação de segurança** para todos os projetos futuros, demonstrando que governança moderna exige **PAM + IGA** integrados desde a concepção.

---

## 3. OBJETIVOS DO PROJETO

## 3.1 Objetivo Geral

Implementar solução de **Privileged Access Management (PAM)** baseada em HashiCorp Vault para gerenciamento centralizado, auditável e seguro de secrets em todo o ambiente do Living Lab Fiqueok.

## 3.2 Objetivos Específicos

**OS1 - Infraestrutura:**  
Provisionar VM dedicada (`vault-gf-01`) com HashiCorp Vault em modo file storage, integrado à malha Tailscale existente.

**OS2 - Migração de Secrets:**  
Migrar 100% dos secrets atualmente em plaintext para Vault Key-Value store v2, documentados em inventário separado (`SECRETS.md` não versionado).

**OS3 - Integração:**  
Desenvolver scripts de automação e bibliotecas Python para acesso programático ao Vault, substituindo leitura de arquivos `.env`.

**OS4 - Políticas de Acesso:**  
Implementar Role-Based Access Control (RBAC) no Vault com políticas segregadas por sistema (OrangeHRM, midPoint, API Proxy).

**OS5 - Observabilidade:**  
Configurar audit logs do Vault para rastreabilidade completa de acesso a secrets (quem, quando, qual secret).

**OS6 - Documentação:**  
Produzir documentação técnica reproduzível, incluindo procedimentos de disaster recovery e rotação de secrets.

---

## 4. ESCOPO DO PROJETO

## 4.1 Dentro do Escopo

**Infraestrutura:**

- ✅ Criação de VM `vault-gf-01` (Ubuntu 24.04, 1 vCPU, 512MB RAM)
    
- ✅ Instalação Docker + Docker Compose
    
- ✅ Integração com Tailscale (rede mesh existente)
    
- ✅ Deploy de HashiCorp Vault 1.18 via container com **file storage backend**
    

**Configuração Vault:**

- ✅ Inicialização com unseal manual (modo produção simplificado)
    
- ✅ Habilitação de KV Secrets Engine v2
    
- ✅ Criação de estrutura hierárquica de secrets (sem valores no TAP)
    
- ✅ Configuração de políticas de acesso (ACL policies)
    
- ✅ Geração de tokens com auto-renewal
    

**Migração de Secrets:**

- ✅ Inventário completo em `SECRETS.md` (arquivo não versionado)
    
- ✅ Migração de secrets de MySQL, PostgreSQL, OAuth, JWT
    
- ✅ Versionamento automático via Vault KV v2
    
- ✅ Plano de rotação documentado
    

**Integração:**

- ✅ Scripts Bash para CLI Vault
    
- ✅ Biblioteca Python (`hvac`) com auto-renewal de tokens
    
- ✅ Variáveis de ambiente apontando para Vault
    

**Observabilidade:**

- ✅ Audit device configurado (file backend)
    
- ✅ Health checks via Docker
    
- ✅ Logs estruturados
    

**Documentação:**

- ✅ Procedimento de setup (reproduzível)
    
- ✅ Guia de uso para desenvolvedores
    
- ✅ Matriz de políticas de acesso
    
- ✅ Disaster recovery plan
    
- ✅ Considerações de produção
    

## 4.2 Fora do Escopo

**Não Inclui (Versão Laboratório):**

- ❌ Vault em cluster HA (High Availability) multi-node
    
- ❌ Auto-unseal via Cloud KMS
    
- ❌ Integração com LDAP/Active Directory
    
- ❌ Dynamic secrets (geração automática de credenciais temporárias)
    
- ❌ PKI (Public Key Infrastructure) backend
    
- ❌ Encryption as a Service
    
- ❌ Backup automático de secrets
    

**Exclusões Documentadas:**

- ❌ Migração de secrets de projetos fora do Living Lab
    
- ❌ Treinamento de terceiros no uso do Vault
    
- ❌ Integração com ferramentas externas (Ansible, Terraform) - reservado para PRJ futuros
    

## 4.3 Premissas

**P1:** Ambiente Hyper-V possui recursos disponíveis para VM adicional (1 vCPU, 512MB RAM, 10GB disco)

**P2:** Tailscale mesh VPN está operacional e estável (validado em PRJ006)

**P3:** Snapshots Hyper-V foram criados antes do início (rollback disponível)

**P4:** Vault será usado com file storage backend (persistência garantida)

**P5:** Secrets existentes estão documentados e acessíveis para migração

**P6:** Unseal manual após restarts é aceitável para ambiente de laboratório

## 4.4 Restrições

**R1 - Recursos Computacionais:**  
HomeLab possui limite de VMs simultâneas (4-5 máximo). Vault compartilha recursos com OrangeHRM, midPoint e futura API Proxy.

**R2 - Tempo de Implementação:**  
Conclusão obrigatória em 2 dias para não atrasar PRJ008 (API Proxy).

**R3 - Complexidade:**  
File storage backend (não Consul/Raft) para equilibrar aprendizado com viabilidade de cronograma.

**R4 - Conectividade:**  
Vault acessível apenas via Tailscale (isolamento de rede, sem exposição externa).

**R5 - Unseal Manual:**  
Após cada restart do container, unseal manual é necessário (sem auto-unseal).

---

## 5. ARQUITETURA PROPOSTA

## 5.1 Diagrama de Arquitetura

text

`┌─────────────────────────────────────────────────────────────┐ │                   TAILSCALE MESH VPN                         │ │              (100.x.x.0/24 - MagicDNS Enabled)              │ ├─────────────────────────────────────────────────────────────┤ │                                                               │ │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────┐│ │  │ vault      │  │ iga        │  │ api        │  │ rh     ││ │  │ -gf-01     │  │ -gf-01     │  │ -gf-01     │  │-gf-01  ││ │  │ (NOVA VM)  │  │            │  │ (futura)   │  │        ││ │  │            │  │            │  │            │  │        ││ │  │ HashiCorp  │◄─┤ midPoint   │◄─┤ API Proxy  │◄─┤Orange  ││ │  │ Vault      │  │ 4.10       │  │ FastAPI    │  │ HRM    ││ │  │ :8200      │  │ :8080      │  │ :8000      │  │ :8085  ││ │  │            │  │            │  │            │  │        ││ │  └────────────┘  └────────────┘  └────────────┘  └────────┘│ │       │               │                │              │     │ │       └───────────────┴────────────────┴──────────────┘     │ │               Todos leem secrets do Vault                   │ │           (Zero plaintext, audit completo)                  │ └─────────────────────────────────────────────────────────────┘ FLUXO DE ACESSO A SECRETS: 1. Aplicação autentica no Vault (via token) 2. Vault valida política de acesso (RBAC) 3. Vault retorna secret via API REST 4. Aplicação usa secret em memória (nunca em disco) 5. Vault registra acesso no audit log 6. Token renova-se automaticamente antes de expirar`

## 5.2 Estrutura de Secrets no Vault

> **IMPORTANTE:** Valores reais de secrets estão documentados em `SECRETS.md` (arquivo não versionado, protegido por `.gitignore`). Este TAP contém apenas referências aos IDs de secrets.

text

`vault/secret/ ├── orangehrm/ │   ├── mysql/ │   │   ├── root_password        → [REF: SECRETS.md #ORG-01] │   │   └── midpoint_user_password → (futuro) │   └── oauth/ │       ├── client_id             → [REF: SECRETS.md #ORG-02] │       └── client_secret         → [REF: SECRETS.md #ORG-03] │ ├── midpoint/ │   ├── database/ │   │   ├── user                  → [REF: SECRETS.md #MID-01] │   │   └── password              → [REF: SECRETS.md #MID-02] │   ├── admin/ │   │   └── password              → [REF: SECRETS.md #MID-03] │   └── keystore/ │       └── password              → [REF: SECRETS.md #MID-04] │ └── api-proxy/     └── jwt/        └── secret                → [Gerado via: openssl rand -base64 32]`

**Versionamento de Secrets:**

- Vault KV v2 mantém histórico automático de versões
    
- Cada alteração cria nova versão preservando anteriores
    
- Rollback possível via `vault kv get -version=N`
    
- Plano de rotação documentado em `SECRETS.md`
    

## 5.3 Stack Tecnológica

|Componente|Tecnologia|Versão|Justificativa|
|---|---|---|---|
|**Secret Manager**|HashiCorp Vault|1.18 (latest stable)|Industry standard, API REST completa|
|**Storage Backend**|File Storage|Nativo Vault|Persistência garantida, simples para lab|
|**Containerização**|Docker|29.x|Já instalado, portabilidade|
|**Orquestração**|Docker Compose|v5.x|Simplicidade para single-node|
|**Sistema Operacional**|Ubuntu Server|24.04 LTS|Suporte até 2029, leveza|
|**Rede**|Tailscale|Latest|VPN mesh já operacional|
|**Acesso Programático**|Python `hvac`|2.3+|SDK oficial HashiCorp|
|**CLI**|Vault CLI|1.18|Administração e troubleshooting|

---

## 6. FASES DE IMPLEMENTAÇÃO

## **FASE 1 - Provisionamento de Infraestrutura** (Duração: 1h)

**Atividades:**

-  Criar VM `vault-gf-01` no Hyper-V
    
    - OS: Ubuntu 24.04 LTS Server
        
    - vCPU: 1, RAM: 512MB, Disco: 10GB
        
    - User: paulo
        
-  Instalar atualizações do sistema
    
    bash
    
    `sudo apt update && sudo apt upgrade -y`
    
-  Instalar Docker + Docker Compose
    
    bash
    
    `curl -fsSL https://get.docker.com | sh sudo usermod -aG docker paulo newgrp docker`
    
-  Instalar Tailscale e integrar à malha VPN
    
    bash
    
    `curl -fsSL https://tailscale.com/install.sh | sh sudo tailscale up`
    
-  Verificar conectividade com outras VMs
    
    bash
    
    `ping rh-gf-01 ping iga-gf-01 tailscale status`
    

**Entregável:** VM `vault-gf-01` acessível via Tailscale e pronta para deployment

**Critério de Aceitação:** SSH funcional via `ssh paulo@vault-gf-01` e Docker operacional

---

## **FASE 2 - Deployment do Vault** (Duração: 50min)

**Atividades:**

-  Criar estrutura de diretórios
    
    bash
    
    `mkdir -p ~/vault-greenfield/{vault-config,vault-data,vault-logs,policies,tokens,scripts,backups} cd ~/vault-greenfield`
    
-  Criar arquivo de configuração `vault-config/vault.hcl`
    
    text
    
    `ui = true listener "tcp" {   address     = "0.0.0.0:8200"  tls_disable = 1 } storage "file" {   path = "/vault/data" } # Disable mlock para ambiente Docker disable_mlock = true api_addr = "http://0.0.0.0:8200"`
    
-  Criar `docker-compose.yml`
    
    text
    
    `services:   vault:    image: hashicorp/vault:1.18    container_name: vault    ports:      - "8200:8200"    environment:      VAULT_ADDR: "http://0.0.0.0:8200"    cap_add:      - IPC_LOCK    volumes:      - ./vault-config:/vault/config      - ./vault-data:/vault/data      - ./vault-logs:/vault/logs    command: server -config=/vault/config/vault.hcl    restart: unless-stopped    healthcheck:      test: ["CMD", "vault", "status", "|| exit 0"]      interval: 10s      timeout: 5s      retries: 3`
    
-  Iniciar Vault
    
    bash
    
    `docker-compose up -d docker logs vault --tail 30`
    
-  Instalar Vault CLI
    
    bash
    
    `wget https://releases.hashicorp.com/vault/1.18.0/vault_1.18.0_linux_amd64.zip unzip vault_1.18.0_linux_amd64.zip sudo mv vault /usr/local/bin/ vault version`
    
-  Inicializar Vault (primeira vez)
    
    bash
    
    `export VAULT_ADDR='http://localhost:8200' # Inicializar com 1 unseal key (simples para lab) vault operator init -key-shares=1 -key-threshold=1 # Output: # Unseal Key 1: <COPIAR PARA SECRETS.md> # Initial Root Token: <COPIAR PARA SECRETS.md>`
    
-  Unseal Vault
    
    bash
    
    `vault operator unseal <unseal_key> # Verificar status vault status # Deve mostrar: Sealed: false`
    
-  Autenticar com root token
    
    bash
    
    `export VAULT_TOKEN='<root_token>' vault token lookup`
    

**Entregável:** Vault operacional, unsealed e acessível em `http://vault-gf-01:8200`

**Critério de Aceitação:**

- `vault status` retorna `Sealed: false, Initialized: true`
    
- Health check passa: `curl http://localhost:8200/v1/sys/health`
    

---

## **FASE 3 - Configuração de Secrets Engine** (Duração: 40min)

**Atividades:**

-  Configurar variáveis de ambiente persistentes
    
    bash
    
    `cat >> ~/.bashrc <<'EOF' export VAULT_ADDR='http://localhost:8200' export VAULT_TOKEN='<root_token>' EOF source ~/.bashrc`
    
-  Habilitar KV Secrets Engine v2
    
    bash
    
    `vault secrets enable -version=2 -path=secret kv # Verificar vault secrets list`
    
-  Criar estrutura de secrets OrangeHRM
    
    bash
    
    `# Valores reais vêm de SECRETS.md vault kv put secret/orangehrm/mysql \   root_password="<REF: SECRETS.md #ORG-01>" vault kv put secret/orangehrm/oauth \   client_id="<REF: SECRETS.md #ORG-02>" \  client_secret="<REF: SECRETS.md #ORG-03>"`
    
-  Migrar secrets do midPoint
    
    bash
    
    `# SSH em iga-gf-01, copiar valores do .env # Voltar para vault-gf-01: vault kv put secret/midpoint/database \   user="<REF: SECRETS.md #MID-01>" \  password="<REF: SECRETS.md #MID-02>" vault kv put secret/midpoint/admin \   password="<REF: SECRETS.md #MID-03>" vault kv put secret/midpoint/keystore \   password="<REF: SECRETS.md #MID-04>"`
    
-  Gerar secret JWT para API Proxy
    
    bash
    
    `JWT_SECRET=$(openssl rand -base64 32) vault kv put secret/api-proxy/jwt secret="$JWT_SECRET" # Documentar valor em SECRETS.md echo "API-01: $JWT_SECRET" >> ~/SECRETS-TEMP.txt`
    
-  Verificar estrutura completa
    
    bash
    
    `vault kv list secret/ vault kv list secret/orangehrm vault kv list secret/midpoint vault kv list secret/api-proxy # Testar leitura vault kv get secret/orangehrm/mysql`
    
-  Criar arquivo `SECRETS.md` (documentação de valores)
    
    bash
    
    `# Ver Anexo B para template completo de SECRETS.md nano ~/vault-greenfield/SECRETS.md`
    

**Entregável:** Todos os secrets migrados e validados no Vault

**Critério de Aceitação:**

- `vault kv get secret/orangehrm/mysql` retorna dados corretamente
    
- Arquivo `SECRETS.md` criado e protegido (`chmod 600`)
    
- Zero secrets permanecem em arquivos `.env` das VMs
    

---

## **FASE 4 - Políticas de Acesso (RBAC)** (Duração: 50min)

**Atividades:**

-  Criar política para API Proxy
    
    bash
    
    `cat > policies/api-proxy-policy.hcl <<'EOF' # API Proxy pode ler secrets do OrangeHRM e próprios path "secret/data/orangehrm/*" {   capabilities = ["read"] } path "secret/data/api-proxy/*" {   capabilities = ["read"] } # Permitir renovação do próprio token path "auth/token/renew-self" {   capabilities = ["update"] } # Permitir lookup do próprio token (verificar TTL) path "auth/token/lookup-self" {   capabilities = ["read"] } EOF vault policy write api-proxy-policy policies/api-proxy-policy.hcl`
    
-  Criar política para midPoint
    
    bash
    
    `cat > policies/midpoint-policy.hcl <<'EOF' # midPoint pode ler apenas seus próprios secrets path "secret/data/midpoint/*" {   capabilities = ["read"] } path "auth/token/renew-self" {   capabilities = ["update"] } path "auth/token/lookup-self" {   capabilities = ["read"] } EOF vault policy write midpoint-policy policies/midpoint-policy.hcl`
    
-  Criar política administrativa (alternativa ao root)
    
    bash
    
    `cat > policies/admin-policy.hcl <<'EOF' # Admin pode gerenciar secrets mas NÃO modificar Vault core path "secret/*" {   capabilities = ["create", "read", "update", "delete", "list"] } path "auth/*" {   capabilities = ["create", "read", "update", "delete", "list"] } path "sys/policies/*" {   capabilities = ["create", "read", "update", "delete", "list"] } # BLOQUEADO: Modificar storage backend, unsealing path "sys/storage/*" {   capabilities = ["deny"] } path "sys/seal" {   capabilities = ["deny"] } EOF vault policy write admin-policy policies/admin-policy.hcl`
    
-  Gerar tokens com políticas aplicadas
    
    bash
    
    `# Token para API Proxy (auto-renovável, 24h period) vault token create \   -policy=api-proxy-policy \  -period=24h \  -renewable \  -display-name="api-proxy-auto-renew" \  -format=json | tee tokens/api-proxy-token.json # Extrair apenas o token jq -r .auth.client_token tokens/api-proxy-token.json > tokens/api-proxy-token.txt # Token para midPoint vault token create \   -policy=midpoint-policy \  -period=24h \  -renewable \  -display-name="midpoint-auto-renew" \  -format=json | tee tokens/midpoint-token.json # Token administrativo (uso diário, evitar root) vault token create \   -policy=admin-policy \  -ttl=8h \  -renewable \  -display-name="admin-daily" \  -format=json | tee tokens/admin-token.json`
    
-  Testar políticas (validação negativa)
    
    bash
    
    `# Com token do API Proxy, tentar ler secret do midPoint (deve falhar) VAULT_TOKEN=$(cat tokens/api-proxy-token.txt) vault kv get secret/midpoint/database # Esperado: Error 403 - permission denied # Com token do midPoint, tentar ler secret do OrangeHRM (deve falhar) VAULT_TOKEN=$(cat tokens/midpoint-token.txt) vault kv get secret/orangehrm/mysql # Esperado: Error 403 - permission denied # Restaurar root token export VAULT_TOKEN='<root_token>'`
    

**Entregável:** Políticas de acesso configuradas e tokens gerados

**Critério de Aceitação:**

- Tokens específicos conseguem acessar APENAS seus secrets autorizados
    
- Tentativa de acesso não autorizado retorna HTTP 403
    
- Tokens possuem capacidade de auto-renovação (`renewable: true`)
    

---

## **FASE 5 - Integração com Aplicações** (Duração: 1.5h)

**Atividades:**

**A) Scripts Bash para Operações MySQL:**

-  Criar script `scripts/orangehrm-vault.sh`
    
    bash
    
    `cat > scripts/orangehrm-vault.sh <<'EOF' #!/bin/bash # Script: orangehrm-vault.sh # Uso: ./orangehrm-vault.sh -e "SELECT * FROM ohrm_user;" export VAULT_ADDR='http://vault-gf-01:8200' export VAULT_TOKEN='<admin_token ou root_token>' # Ler senha do Vault MYSQL_PASSWORD=$(vault kv get -field=root_password secret/orangehrm/mysql) # Executar comando MySQL (senha NÃO exposta em histórico) ssh paulo@rh-gf-01 "docker exec orange-db mysql -u root -p'$MYSQL_PASSWORD' orangehrm $*" EOF chmod +x scripts/orangehrm-vault.sh`
    
-  Criar script `scripts/setup-oauth-client.sh`
    
    bash
    
    `cat > scripts/setup-oauth-client.sh <<'EOF' #!/bin/bash # Script: setup-oauth-client.sh # Configura OAuth client no OrangeHRM usando secrets do Vault export VAULT_ADDR='http://vault-gf-01:8200' export VAULT_TOKEN='<admin_token>' # Ler secrets do Vault MYSQL_PASSWORD=$(vault kv get -field=root_password secret/orangehrm/mysql) CLIENT_ID=$(vault kv get -field=client_id secret/orangehrm/oauth) CLIENT_SECRET=$(vault kv get -field=client_secret secret/orangehrm/oauth) # Inserir no banco via SSH ssh paulo@rh-gf-01 <<ENDSSH docker exec orange-db mysql -u root -p'$MYSQL_PASSWORD' orangehrm <<ENDSQL INSERT INTO ohrm_oauth_client    (client_id, client_secret, redirect_uri, grant_types, scope) VALUES    ('$CLIENT_ID', '$CLIENT_SECRET', 'http://api-gf-01:8000', 'client_credentials', 'read write') ON DUPLICATE KEY UPDATE    client_secret='$CLIENT_SECRET'; ENDSQL ENDSSH echo "✅ OAuth client configurado usando secrets do Vault" EOF chmod +x scripts/setup-oauth-client.sh`
    
-  Testar scripts
    
    bash
    
    `# Testar leitura do banco ./scripts/orangehrm-vault.sh -e "SELECT COUNT(*) FROM ohrm_user;" # Testar configuração OAuth ./scripts/setup-oauth-client.sh`
    

**B) Biblioteca Python para API Proxy (PRJ008):**

-  Criar template de biblioteca Python
    
    bash
    
    `mkdir -p ~/vault-greenfield/python-lib cat > ~/vault-greenfield/python-lib/vault_client.py <<'EOF' """ Vault Client com Auto-Renewal de Tokens Uso em PRJ008 (API Proxy) """ import hvac import os import threading import time from datetime import datetime class VaultClient:     def __init__(self):        self.client = hvac.Client(            url=os.getenv('VAULT_ADDR', 'http://vault-gf-01:8200'),            token=os.getenv('VAULT_TOKEN')        )                 if not self.client.is_authenticated():            raise Exception("❌ Vault authentication failed")                 print("✅ Vault client authenticated")                 # Iniciar thread de renovação automática        self._start_token_renewal()         def _start_token_renewal(self):        """Background thread que renova token automaticamente"""        def renewal_loop():            while True:                try:                    # Aguardar 12 horas (50% do period de 24h)                    time.sleep(12 * 60 * 60)                                         # Renovar token                    self.client.auth.token.renew_self()                    print(f"✅ Vault token renewed at {datetime.now().isoformat()}")                                     except Exception as e:                    print(f"❌ Token renewal failed: {e}")                    # Em produção: enviar alerta, tentar reautenticar                 renewal_thread = threading.Thread(target=renewal_loop, daemon=True)        renewal_thread.start()         def get_secret(self, path: str, field: str) -> str:        """        Ler secret do Vault com retry automático                 Args:            path: Caminho do secret (ex: 'orangehrm/mysql')            field: Campo específico (ex: 'root_password')                 Returns:            Valor do secret                 Raises:            Exception: Se falhar após retry        """        try:            response = self.client.secrets.kv.v2.read_secret_version(path=path)            return response['data']['data'][field]                 except hvac.exceptions.Forbidden:            # Token expirado, tentar renovar uma última vez            print(f"⚠️ Token forbidden for {path}, attempting renewal...")            try:                self.client.auth.token.renew_self()                # Retry após renovação                response = self.client.secrets.kv.v2.read_secret_version(path=path)                return response['data']['data'][field]            except Exception as e:                raise Exception(f"❌ Failed to read {path}/{field} after renewal: {e}")                 except Exception as e:            raise Exception(f"❌ Error reading {path}/{field}: {e}")         def get_token_info(self):        """Retornar informações do token atual (para debugging)"""        try:            info = self.client.auth.token.lookup_self()            return {                "display_name": info['data']['display_name'],                "ttl": info['data']['ttl'],                "renewable": info['data']['renewable'],                "policies": info['data']['policies']            }        except Exception as e:            return {"error": str(e)} # Singleton instance vault = VaultClient() EOF`
    
-  Criar exemplo de uso
    
    bash
    
    `cat > ~/vault-greenfield/python-lib/example_usage.py <<'EOF' """ Exemplo de uso da biblioteca Vault Client """ import os from vault_client import vault # Configurar ambiente os.environ['VAULT_ADDR'] = 'http://vault-gf-01:8200' os.environ['VAULT_TOKEN'] = '<token_da_aplicacao>' # Uso 1: Ler senha de banco de dados db_config = {     "host": "rh-gf-01",    "database": "orangehrm",    "user": "root",    "password": vault.get_secret('orangehrm/mysql', 'root_password') } print(f"Connecting to {db_config['host']}...") # Uso 2: Verificar informações do token token_info = vault.get_token_info() print(f"Token TTL remaining: {token_info['ttl']} seconds") print(f"Policies: {token_info['policies']}") EOF`
    
-  Criar requirements.txt para Python
    
    bash
    
    `cat > ~/vault-greenfield/python-lib/requirements.txt <<'EOF' hvac>=2.3.0 EOF`
    

**C) Criar arquivo .env.vault template:**

-  Template para API Proxy
    
    bash
    
    `cat > ~/vault-greenfield/.env.vault.template <<'EOF' # .env.vault - Configuração para aplicações que usam Vault # COPIAR para aplicação e renomear para .env # NUNCA versionar este arquivo com valores reais VAULT_ADDR=http://vault-gf-01:8200 VAULT_TOKEN=<inserir_token_da_aplicacao> # Para API Proxy (PRJ008) # VAULT_TOKEN=<valor de tokens/api-proxy-token.txt> # Para midPoint (futuro) # VAULT_TOKEN=<valor de tokens/midpoint-token.txt> EOF`
    

**Entregável:** Scripts, bibliotecas e templates prontos para PRJ008

**Critério de Aceitação:**

- Script `setup-oauth-client.sh` executa sem expor senhas
    
- Biblioteca Python consegue ler secrets do Vault
    
- Token renewal funciona (validar logs após 12h em produção)
    

---

## **FASE 6 - Observabilidade e Audit** (Duração: 40min)

**Atividades:**

-  Habilitar audit device
    
    bash
    
    `vault audit enable file file_path=/vault/logs/audit.log # Verificar vault audit list`
    
-  Configurar rotação de logs (logrotate)
    
    bash
    
    `sudo tee /etc/logrotate.d/vault-audit <<'EOF' /home/paulo/vault-greenfield/vault-logs/audit.log {     daily    rotate 30    compress    missingok    notifempty    postrotate        docker exec vault vault audit-reopen || true    endscript } EOF # Testar configuração sudo logrotate -d /etc/logrotate.d/vault-audit`
    
-  Testar geração de logs
    
    bash
    
    `# Fazer operações que geram audit logs vault kv get secret/orangehrm/mysql vault token lookup # Verificar logs tail -f ~/vault-greenfield/vault-logs/audit.log | jq .`
    
-  Criar script de análise de audit logs
    
    bash
    
    `cat > scripts/audit-analysis.sh <<'EOF' #!/bin/bash # Script: audit-analysis.sh # Análise rápida de audit logs do Vault AUDIT_LOG="$HOME/vault-greenfield/vault-logs/audit.log" echo "📊 Vault Audit Log Analysis" echo "==============================" # Total de operações echo "Total operations: $(wc -l < $AUDIT_LOG)" # Operações por tipo echo -e "\nOperations by type:" jq -r '.request.operation' $AUDIT_LOG | sort | uniq -c | sort -rn # Top 5 secrets acessados echo -e "\nTop 5 secrets accessed:" jq -r '.request.path' $AUDIT_LOG | grep "secret/data" | sort | uniq -c | sort -rn | head -5 # Falhas de autenticação echo -e "\nAuthentication failures:" jq 'select(.error != null and .request.operation == "login")' $AUDIT_LOG | wc -l # Uso de root token (deve ser ZERO em produção) echo -e "\nRoot token usage:" jq 'select(.auth.display_name == "root")' $AUDIT_LOG | wc -l EOF chmod +x scripts/audit-analysis.sh`
    
-  Documentar formato de log
    
    bash
    
    `# Exemplo de entrada de audit log cat > ~/vault-greenfield/docs/audit-log-format.md <<'EOF' # Formato de Audit Log do Vault ## Exemplo de Entrada ```json {   "type": "response",  "time": "2026-02-03T18:30:00.000000Z",  "auth": {    "client_token": "hmac-sha256:xxxxx",    "accessor": "hmac-sha256:yyyyy",    "display_name": "api-proxy-auto-renew",    "token_type": "service",    "policies": ["api-proxy-policy", "default"]  },  "request": {    "id": "abc123",    "operation": "read",    "client_token": "hmac-sha256:xxxxx",    "path": "secret/data/orangehrm/mysql",    "remote_address": "100.x.x.xxx"  },  "response": {    "data": {      "data": {        "root_password": "hmac-sha256:zzzzz"      },      "metadata": {        "created_time": "2026-02-03T18:00:00Z",        "version": 1      }    }  } }`
    
    ## Campos Importantes
    
    - `auth.display_name`: Identifica qual aplicação/usuário acessou
        
    - `request.operation`: Tipo de operação (read, update, delete, list)
        
    - `request.path`: Secret específico acessado
        
    - `response.data.data`: Valores de secrets são HASH (não plaintext em log)
        
    - `remote_address`: IP de origem (útil para detectar acesso não autorizado)
        
    
    ## Queries Úteis
    
    bash
    
    `# Encontrar todas as leituras de secrets do OrangeHRM jq 'select(.request.path | contains("orangehrm"))' audit.log # Encontrar operações de um token específico jq 'select(.auth.display_name == "api-proxy-auto-renew")' audit.log # Encontrar falhas (errors) jq 'select(.error != null)' audit.log`
    
    EOF
    
    text
    
    `undefined`
    

**Entregável:** Audit logs configurados, rotacionados e analisáveis

**Critério de Aceitação:**

- Toda operação gera entrada em `/vault/logs/audit.log`
    
- Logs contêm: timestamp, usuário, operação, path, remote_address
    
- Script de análise identifica padrões de uso
    

---

## **FASE 7 - Documentação e Snapshot Final** (Duração: 1.5h)

**Atividades:**

**A) Criar README.md principal:**

-  Documentação completa do projeto
    
    bash
    
    `# Ver Anexo C para README.md completo nano ~/vault-greenfield/README.md`
    

**B) Criar arquivo SECRETS.md:**

-  Inventário de secrets (NÃO versionado)
    
    bash
    
    `# Ver Anexo B para template SECRETS.md completo nano ~/vault-greenfield/SECRETS.md chmod 600 ~/vault-greenfield/SECRETS.md`
    

**C) Configurar .gitignore:**

-  Proteger arquivos sensíveis
    
    bash
    
    `cat > ~/vault-greenfield/.gitignore <<'EOF' # Secrets nunca devem ser commitados SECRETS.md secrets.md *.secret *.password # Tokens Vault tokens/*.txt tokens/*.json # Backups de secrets backups/*.json # Environment files .env .env.* !.env.vault.template # Vault data (gerado pelo container) vault-data/ vault-logs/*.log # Arquivos temporários *.tmp *.bak *~ # OS .DS_Store Thumbs.db EOF`
    

**D) Criar Disaster Recovery Plan:**

-  Procedimentos de recuperação
    
    bash
    
    ``cat > ~/vault-greenfield/docs/disaster-recovery.md <<'EOF' # Disaster Recovery Plan - PRJ007 Vault ## RTO e RPO - **RTO (Recovery Time Objective):** 15 minutos - **RPO (Recovery Point Objective):** 24 horas (backup diário manual) ## Cenários de Falha ### Cenário 1: Container Vault Corrompido **Sintomas:** - Container não inicia (`docker ps` não mostra vault) - Logs mostram erros críticos **Procedimento:** ```bash # 1. Parar container docker-compose down # 2. Verificar integridade dos dados ls -lh vault-data/ # 3. Recriar container docker-compose up -d # 4. Unseal Vault vault operator unseal <unseal_key> # 5. Validar vault kv get secret/orangehrm/mysql``
    
    **Tempo Estimado:** 5 minutos
    
    ---
    
    ## Cenário 2: VM vault-gf-01 Perdida
    
    **Sintomas:**
    
    - VM não responde a ping
        
    - Hyper-V mostra VM em estado crítico
        
    
    **Procedimento:**
    
    powershell
    
    `# 1. No Windows Host, restaurar snapshot Get-VMSnapshot -VMName "vault-gf-01" | Select-Object Name, CreationTime # 2. Aplicar snapshot mais recente Restore-VMSnapshot -Name "PRJ007-Complete-2026-02-04" -VMName "vault-gf-01" -Confirm:$false # 3. Iniciar VM Start-VM -Name "vault-gf-01" # 4. SSH e verificar Vault ssh paulo@vault-gf-01 docker ps # 5. Unseal se necessário vault operator unseal <unseal_key>`
    
    **Tempo Estimado:** 10 minutos
    
    ---
    
    ## Cenário 3: Perda de Unseal Key ou Root Token
    
    **Sintomas:**
    
    - Arquivo `SECRETS.md` perdido ou corrompido
        
    - Não consegue unseal o Vault
        
    
    **Procedimento:**
    
    bash
    
    `# CRÍTICO: Sem unseal key, dados são irrecuperáveis # Prevenção: Manter backups em múltiplos locais # Opção A: Recuperar de backup físico (USB, KeePass) # Verificar arquivo SECRETS.md em backup # Opção B: Recriar Vault (ÚLTIMA OPÇÃO - perda de dados) docker-compose down rm -rf vault-data/* docker-compose up -d vault operator init -key-shares=1 -key-threshold=1 # Re-popular secrets manualmente`
    
    **Tempo Estimado:** 15 minutos (com backup) / 60 minutos (sem backup)
    
    ---
    
    ## Cenário 4: Corrupção de Secrets
    
    **Sintomas:**
    
    - Secret retorna valor incorreto
        
    - Aplicações falham na autenticação
        
    
    **Procedimento:**
    
    bash
    
    `# Vault KV v2 mantém histórico de versões # 1. Ver histórico do secret vault kv metadata get secret/orangehrm/mysql # 2. Ler versão anterior vault kv get -version=1 secret/orangehrm/mysql # 3. Se versão anterior está correta, "rollar back" OLD_PASSWORD=$(vault kv get -version=1 -field=root_password secret/orangehrm/mysql) vault kv put secret/orangehrm/mysql root_password="$OLD_PASSWORD" # 4. Ou restaurar de backup JSON vault kv put secret/orangehrm/mysql @backups/orangehrm-mysql.json`
    
    **Tempo Estimado:** 5 minutos
    
    ---
    
    ## Procedimento de Backup
    
    ## Backup Manual (Executar Diariamente)
    
    bash
    
    `#!/bin/bash # Script: scripts/backup-all-secrets.sh BACKUP_DIR="$HOME/vault-greenfield/backups" DATE=$(date +%Y%m%d) mkdir -p $BACKUP_DIR # Backup de cada secret path vault kv get -format=json secret/orangehrm/mysql > $BACKUP_DIR/orangehrm-mysql-$DATE.json vault kv get -format=json secret/orangehrm/oauth > $BACKUP_DIR/orangehrm-oauth-$DATE.json vault kv get -format=json secret/midpoint/database > $BACKUP_DIR/midpoint-db-$DATE.json vault kv get -format=json secret/midpoint/admin > $BACKUP_DIR/midpoint-admin-$DATE.json vault kv get -format=json secret/api-proxy/jwt > $BACKUP_DIR/api-proxy-jwt-$DATE.json # Compactar tar czf $BACKUP_DIR/vault-backup-$DATE.tar.gz $BACKUP_DIR/*-$DATE.json # Remover JSONs individuais rm $BACKUP_DIR/*-$DATE.json echo "✅ Backup criado: vault-backup-$DATE.tar.gz" # Copiar para local externo (USB, NAS, etc.) # cp $BACKUP_DIR/vault-backup-$DATE.tar.gz /mnt/usb/vault-backups/`
    
    ## Restauração de Backup
    
    bash
    
    `# Extrair backup cd ~/vault-greenfield/backups tar xzf vault-backup-20260203.tar.gz # Restaurar cada secret vault kv put secret/orangehrm/mysql @orangehrm-mysql-20260203.json vault kv put secret/orangehrm/oauth @orangehrm-oauth-20260203.json # ... etc`
    
    ---
    
    ## Teste de DR (Executar Trimestralmente)
    
    1. Agendar janela de manutenção
        
    2. Criar snapshot PRJ007-PreDRTest
        
    3. Simular falha (parar container, deletar dados)
        
    4. Executar procedimento de recuperação
        
    5. Validar integridade de secrets
        
    6. Documentar tempo de recuperação real
        
    7. Atualizar procedimentos se necessário  
        EOF
        
    
    text
    
    `undefined`
    

**E) Criar Cheatsheet de Comandos:**

-  Referência rápida
    
    bash
    
    `cat > ~/vault-greenfield/docs/vault-cheatsheet.md <<'EOF' # Vault Cheatsheet - PRJ007 ## Conexão e Autenticação ```bash # Conectar ao Vault export VAULT_ADDR='http://vault-gf-01:8200' export VAULT_TOKEN='<seu_token>' # Verificar autenticação vault token lookup # Ver informações do token vault token lookup -format=json | jq .`
    
    ## Operações com Secrets
    
    bash
    
    `# Ler secret vault kv get secret/orangehrm/mysql vault kv get -field=root_password secret/orangehrm/mysql # Escrever/atualizar secret vault kv put secret/orangehrm/mysql root_password="NovaSenha123" # Listar secrets vault kv list secret/ vault kv list secret/orangehrm # Ver metadados (histórico de versões) vault kv metadata get secret/orangehrm/mysql # Ler versão específica vault kv get -version=1 secret/orangehrm/mysql # Deletar versão (soft delete, recuperável) vault kv delete -versions=2 secret/orangehrm/mysql # Deletar permanentemente vault kv destroy -versions=2 secret/orangehrm/mysql # Recuperar versão deletada vault kv undelete -versions=2 secret/orangehrm/mysql`
    
    ## Gerenciamento de Tokens
    
    bash
    
    `# Criar novo token vault token create -policy=api-proxy-policy -period=24h # Renovar token atual vault token renew # Revogar token vault token revoke <token> # Listar tokens (requer permissão) vault list auth/token/accessors`
    
    ## Políticas
    
    bash
    
    `# Listar políticas vault policy list # Ler política vault policy read api-proxy-policy # Criar/atualizar política vault policy write minha-policy minha-policy.hcl # Deletar política vault policy delete minha-policy`
    
    ## Unseal e Seal
    
    bash
    
    `# Verificar status vault status # Unseal (após restart do container) vault operator unseal <unseal_key> # Seal (emergência - bloqueia acesso) vault operator seal`
    
    ## Audit Logs
    
    bash
    
    `# Listar audit devices vault audit list # Ver logs em tempo real tail -f ~/vault-greenfield/vault-logs/audit.log | jq . # Reabrir audit log (após rotação) vault audit-reopen # Queries úteis jq 'select(.request.path | contains("orangehrm"))' audit.log jq 'select(.error != null)' audit.log jq 'select(.auth.display_name == "root")' audit.log`
    
    ## Troubleshooting
    
    bash
    
    `# Verificar health curl http://vault-gf-01:8200/v1/sys/health # Ver logs do container docker logs vault --tail 50 docker logs vault -f # Conectar ao container docker exec -it vault sh # Verificar conectividade ping vault-gf-01 telnet vault-gf-01 8200`
    
    EOF
    
    text
    
    `undefined`
    

**F) Procedimento de Snapshot Hyper-V:**

-  Criar snapshot final com VM desligada
    
    bash
    
    `# 1. Na vault-gf-01, parar aplicação cd ~/vault-greenfield docker-compose down # 2. Verificar que container parou docker ps # 3. No Windows Host (PowerShell como Admin):`
    
    powershell
    
    `# Parar VM Stop-VM -Name "vault-gf-01" # Aguardar shutdown completo Start-Sleep -Seconds 10 # Criar snapshot Checkpoint-VM -Name "vault-gf-01" -SnapshotName "PRJ007-Complete-2026-02-04" # Verificar snapshot criado Get-VMSnapshot -VMName "vault-gf-01" | Select-Object Name, CreationTime, SizeOfSystemFiles # Religar VM Start-VM -Name "vault-gf-01"`
    
    bash
    
    `# 4. SSH de volta e restartar Vault ssh paulo@vault-gf-01 cd ~/vault-greenfield docker-compose up -d # 5. Unseal vault operator unseal <unseal_key> # 6. Validar vault kv get secret/orangehrm/mysql`
    

**G) Criar Post-Mortem Template:**

-  Documento de lições aprendidas
    
    bash
    
    `cat > ~/vault-greenfield/docs/post-mortem.md <<'EOF' # Post-Mortem - PRJ007 HashiCorp Vault **Data de Conclusão:** [PREENCHER]   **Duração Real:** [PREENCHER]   **Status:** [Sucesso / Parcial / Falha] ## O Que Foi Bem - [ ] Vault instalado e operacional - [ ] Todos os secrets migrados - [ ] Políticas RBAC funcionais - [ ] Audit logs configurados - [ ] Documentação completa ## O Que Pode Melhorar - [ ] [PREENCHER após implementação] ## Métricas Reais vs Planejadas | Métrica | Planejado | Real | Diferença | |---------|-----------|------|-----------| | Tempo total | 7.5h | [PREENCHER] | [PREENCHER] | | Secrets migrados | 8 | [PREENCHER] | [PREENCHER] | | Políticas criadas | 3 | [PREENCHER] | [PREENCHER] | | Tokens gerados | 3 | [PREENCHER] | [PREENCHER] | ## Problemas Encontrados ### Problema 1: [TÍTULO] **Descrição:** [PREENCHER]   **Solução:** [PREENCHER]   **Tempo Perdido:** [PREENCHER] ## Lições Aprendidas 1. [PREENCHER] 2. [PREENCHER] ## Recomendações para Projetos Futuros 1. [PREENCHER] 2. [PREENCHER] ## Conhecimento Adquirido **Antes do PRJ007 (auto-avaliação 1-10):** - Vault: [PREENCHER] - PAM: [PREENCHER] - Secrets Management: [PREENCHER] **Após PRJ007:** - Vault: [PREENCHER] - PAM: [PREENCHER] - Secrets Management: [PREENCHER] EOF`
    

**Entregável:** Documentação completa e snapshot final validado

**Critério de Aceitação:**

- README.md permite reprodução completa por terceiro
    
- SECRETS.md protegido e não versionado
    
- DR plan cobre top 4 cenários de falha
    
- Snapshot criado com VM desligada e validado
    

---

## 7. ENTREGÁVEIS DO PROJETO

|#|Entregável|Descrição|Responsável|
|---|---|---|---|
|**E1**|VM `vault-gf-01`|Infraestrutura provisionada e operacional|Paulo Feitosa|
|**E2**|Vault Container|HashiCorp Vault 1.18 com file storage|Paulo Feitosa|
|**E3**|Secrets Migrados|100% dos secrets em Vault KV v2 + SECRETS.md|Paulo Feitosa|
|**E4**|Políticas RBAC|3 políticas (api-proxy, midpoint, admin)|Paulo Feitosa|
|**E5**|Scripts Bash|`orangehrm-vault.sh`, `setup-oauth-client.sh`, `backup-all-secrets.sh`|Paulo Feitosa|
|**E6**|Biblioteca Python|`vault_client.py` com auto-renewal|Paulo Feitosa|
|**E7**|Audit Logs|Logging configurado, rotacionado e analisável|Paulo Feitosa|
|**E8**|Documentação Técnica|README.md, DR Plan, Cheatsheet, considerações de produção|Paulo Feitosa|
|**E9**|Snapshot Hyper-V|"PRJ007-Complete-2026-02-04" (VM desligada)|Paulo Feitosa|
|**E10**|Post-Mortem|Documento de lições aprendidas|Paulo Feitosa|
|**E11**|.gitignore|Proteção de arquivos sensíveis|Paulo Feitosa|

---

## 8. CRITÉRIOS DE SUCESSO

## 8.1 Critérios Funcionais

|ID|Critério|Método de Validação|Meta|
|---|---|---|---|
|**CS1**|Vault acessível via Tailscale|`curl http://vault-gf-01:8200/v1/sys/health`|HTTP 200, sealed=false|
|**CS2**|Secrets persistem após restart|Restart container + unseal + ler secret|Valor correto retornado|
|**CS3**|RBAC funcional|Token limitado tenta acessar secret não autorizado|HTTP 403 esperado|
|**CS4**|Audit logs gerados|Toda operação registrada em audit.log|100% das operações|
|**CS5**|Zero secrets em plaintext|Grep em .env, docker-compose.yml, bash_history|0 ocorrências|
|**CS6**|Token auto-renewal|Verificar logs após 12h|Renovação bem-sucedida|
|**CS7**|Disponibilidade|Vault uptime durante testes (exceto restart intencional)|≥ 99%|

## 8.2 Critérios de Qualidade

**Segurança:**

- ✅ Tokens com TTL definido (não permanentes, exceto root para lab)
    
- ✅ Princípio de menor privilégio (cada app só acessa seus secrets)
    
- ✅ Audit trail completo e imutável
    
- ✅ Secrets versionados (rollback possível)
    
- ✅ Root token documentado como antipadrão em produção
    

**Usabilidade:**

- ✅ Scripts de uso documentados e testados
    
- ✅ Biblioteca Python com tratamento de erros e retry
    
- ✅ Cheatsheet de comandos disponível
    
- ✅ Procedimento de unseal documentado
    

**Manutenibilidade:**

- ✅ Código versionado em Git (sem secrets!)
    
- ✅ Docker Compose permite rebuild rápido
    
- ✅ Documentação permite operação por terceiro
    
- ✅ DR plan testável
    

**Portabilidade:**

- ✅ Ambiente reproduzível em nova VM
    
- ✅ Migração OCI facilitada (mesma arquitetura)
    
- ✅ Backups em formato JSON portável
    

## 8.3 Critérios de Aprendizado (Portfólio)

**Habilidades Demonstradas:**

- ✅ Privileged Access Management (PAM)
    
- ✅ HashiCorp Vault (industry standard)
    
- ✅ Role-Based Access Control (RBAC)
    
- ✅ Secrets lifecycle management
    
- ✅ Token renewal automático
    
- ✅ Audit e compliance
    
- ✅ Infrastructure as Code (Docker Compose)
    
- ✅ Disaster Recovery planning
    

**Aplicabilidade Mercado:**

- ✅ Consultoria IAM/GRC (secrets management é gap comum)
    
- ✅ Fintechs (compliance obriga PAM)
    
- ✅ Empresas reguladas (PCI-DSS, SOX, LGPD)
    

---

## 9. RISCOS E MITIGAÇÕES

|ID|Risco|Probabilidade|Impacto|Estratégia de Mitigação|Contingência|
|---|---|---|---|---|---|
|**R1**|VM vault-gf-01 não sobe (recursos insuficientes)|Baixa|Alto|Validar recursos antes de criar VM|Rodar Vault em VM existente temporariamente|
|**R2**|Perda de unseal key|Baixa|Crítico|Documentar em SECRETS.md + backup USB + KeePass|Recriar Vault e reimportar de backup JSON|
|**R3**|Falha na migração de secrets (valores incorretos)|Média|Alto|Validar cada secret após migração|Manter `.env` original até validação 100%|
|**R4**|Token expira e aplicação quebra|Média|Médio|Implementar auto-renewal em Python|Token com TTL longo (365d) para lab|
|**R5**|Performance ruim (latência Tailscale)|Baixa|Baixo|Benchmark inicial < 200ms|Aceitar latência (não é produção)|
|**R6**|Curva aprendizado Vault > estimado|Média|Médio|Documentação oficial + tutoriais pré-selecionados|Estender prazo em 1 dia|
|**R7**|Dados não persistem após restart|Média|Crítico|Usar file storage (não modo -dev puro)|Implementado na Fase 2|
|**R8**|Snapshot inconsistente|Baixa|Médio|Criar snapshot com VM desligada|Refazer snapshot seguindo procedimento|

---

## 10. ESTRUTURA ANALÍTICA DO PROJETO (EAP)

text

`PRJ007 - Implementação HashiCorp Vault │ ├── 1. Iniciação │   ├── 1.1 Criar snapshots Hyper-V (PRJ007-PreStart) │   ├── 1.2 Validar recursos disponíveis │   └── 1.3 Aprovar TAP │ ├── 2. Planejamento │   ├── 2.1 Definir estrutura de secrets │   ├── 2.2 Mapear políticas de acesso │   ├── 2.3 Preparar scripts de migração │   └── 2.4 Criar template SECRETS.md │ ├── 3. Execução │   ├── 3.1 Provisionamento Infraestrutura (Fase 1) │   ├── 3.2 Deployment Vault (Fase 2) │   ├── 3.3 Configuração Secrets Engine (Fase 3) │   ├── 3.4 Implementação RBAC (Fase 4) │   ├── 3.5 Integração Aplicações (Fase 5) │   └── 3.6 Configuração Observabilidade (Fase 6) │ ├── 4. Monitoramento e Controle │   ├── 4.1 Testes de acesso a secrets │   ├── 4.2 Validação de políticas │   ├── 4.3 Verificação de audit logs │   ├── 4.4 Teste de persistência (restart) │   └── 4.5 Teste de auto-renewal │ └── 5. Encerramento     ├── 5.1 Documentação técnica (Fase 7)    ├── 5.2 Snapshot final (VM desligada)    ├── 5.3 Post-mortem    ├── 5.4 Handoff para PRJ008    └── 5.5 Publicação no portfólio`

---

## 11. CRONOGRAMA

## Dia 1 (03/02/2026) - 4.5 horas

|Horário|Atividade|Fase|Duração|Responsável|
|---|---|---|---|---|
|18:00-18:15|Criar snapshots Hyper-V|Iniciação|15min|Paulo|
|18:15-19:15|Provisionar VM vault-gf-01 + Docker/Tailscale|Fase 1|60min|Paulo|
|19:15-19:30|**Break**|-|15min|-|
|19:30-20:20|Deploy Vault + inicializar + unseal|Fase 2|50min|Paulo|
|20:20-21:00|Configurar Secrets Engine + migrar secrets|Fase 3|40min|Paulo|
|21:00-21:10|Validação e checkpoint|Controle|10min|Paulo|

## Dia 2 (04/02/2026) - 3.5 horas

|Horário|Atividade|Fase|Duração|Responsável|
|---|---|---|---|---|
|18:00-18:50|Implementar políticas RBAC + gerar tokens|Fase 4|50min|Paulo|
|18:50-19:00|**Break**|-|10min|-|
|19:00-20:30|Criar scripts Bash + biblioteca Python|Fase 5|90min|Paulo|
|20:30-21:10|Configurar audit logs + análise|Fase 6|40min|Paulo|
|21:10-22:00|Documentação + snapshot final|Fase 7|50min|Paulo|

**Duração Total Planejada:** 8 horas  
**Buffer para Imprevistos:** Incluído nas fases  
**Conclusão Prevista:** 04/02/2026 22:00

---

## 12. ORÇAMENTO E RECURSOS

## 12.1 Recursos Humanos

|Papel|Responsável|Alocação|Custo (Oportunidade)|
|---|---|---|---|
|Gerente de Projeto|Paulo Feitosa|1h (planejamento)|N/A (laboratório)|
|Engenheiro de Infraestrutura|Paulo Feitosa|2h (Fases 1-2)|N/A|
|Especialista em Segurança|Paulo Feitosa|3.5h (Fases 3-5)|N/A|
|DevOps Engineer|Paulo Feitosa|1.5h (Fase 6)|N/A|
|Documentador Técnico|Paulo Feitosa|1.5h (Fase 7)|N/A|

## 12.2 Recursos Computacionais

|Recurso|Especificação|Custo|Provedor|
|---|---|---|---|
|VM vault-gf-01|1 vCPU, 512MB RAM, 10GB disco|$0 (HomeLab)|Hyper-V on-prem|
|Tailscale|Personal plan (100 devices)|$0 (free tier)|Tailscale|
|HashiCorp Vault|Community Edition|$0 (open source)|Docker Hub|
|Ubuntu Server 24.04|LTS|$0 (open source)|Canonical|

**Custo Total:** $0 (ambiente laboratório)

## 12.3 Ferramentas e Licenças

|Ferramenta|Licença|Uso|
|---|---|---|
|HashiCorp Vault|BSL 1.1 (Business Source License)|Secret management|
|Docker|Apache 2.0|Containerização|
|Python hvac|Apache 2.0|SDK Vault|
|Tailscale|BSD 3-Clause|VPN mesh|
|OpenSSL|Apache 2.0|Geração de secrets|
|jq|MIT|Parsing JSON (audit logs)|

---

## 13. COMUNICAÇÃO E STAK
