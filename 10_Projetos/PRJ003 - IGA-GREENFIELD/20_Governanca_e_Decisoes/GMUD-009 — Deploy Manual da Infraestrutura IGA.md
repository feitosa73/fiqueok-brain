# 

**Tipo:** Mudança de Infraestrutura  
**Prioridade:** Alta  
**Categoria:** Deploy Manual Controlado  
**Status:** Planejada  
**Projeto:** PRJ003 - IGA Greenfield Reference Architecture

---

## 1. Identificação da Mudança

|Campo|Informação|
|---|---|
|**Número GMUD**|GMUD-009|
|**Título**|Deploy Manual da Infraestrutura IGA (midPoint 4.8 + PostgreSQL 16)|
|**Solicitante**|Paulo Feitosa|
|**Executor**|Paulo Feitosa|
|**Data de Planejamento**|20/01/2026|
|**Data de Execução Prevista**|20/01/2026|
|**Janela de Execução**|2-4 horas (primeira execução)|
|**Tipo de Mudança**|Padrão|
|**Impacto**|Baixo (ambiente greenfield)|
|**Risco**|Médio (procedimento manual com múltiplos checkpoints)|

---

## 2. Contexto e Justificativa

## 2.1. Contexto da Mudança

A GMUD-008 foi encerrada com status "Executada sem Sucesso" após nove iterações de troubleshooting que identificaram incompatibilidades entre automação PowerShell e gerenciamento de credenciais em ambiente Docker Linux. A análise de causa raiz revelou três problemas fundamentais: vácuo de variáveis no interpretador, envenenamento de volume PostgreSQL e conflitos de interatividade TTY.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/3cd86cc4-43a5-4b5d-ac33-5c07bf632dda/GMUD-008v1.4.txt)]​

## 2.2. Justificativa de Abordagem Manual

A GMUD-009 adota **estratégia de execução manual controlada** com os seguintes objetivos:

- **Coleta de Evidências**: Observação detalhada de logs durante bootstrap do PostgreSQL e midPoint para validação de comportamento esperado
    
- **Validação de Lições Aprendidas**: Confirmação prática das correções propostas (aspas simples em senhas, sintaxe MP_SET correta, validação tripla de repositório)
    
- **Base para Automação Futura**: Documentação de comportamento correto do sistema para implementação de automação na GMUD-010
    
- **Redução de Risco**: Eliminação de variáveis de interpretador e escopo que causaram falhas na GMUD-008
    

## 2.3. Alinhamento com Governança

Esta mudança está em conformidade com as lições aprendidas documentadas na REL-GMUD-008 e segue o princípio de **Separação de Camadas**, tratando infraestrutura de SO como baseline pré-requisito separado do deploy da aplicação.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/50abc276-d12a-41c6-a373-2967c17d2975/pop_iga_v3.md)]​

---

## 3. Escopo da Mudança

## 3.1. Inclusões

**Componentes de Infraestrutura:**

- Configuração de rede estática (Netplan) na VM `iga-gf-01` (xxx.xxx.xxx.xxx/22)
    
- Hardening de sudoers com whitelist de comandos
    
- Estrutura de diretórios do projeto em `/srv/prj003`
    

**Componentes da Aplicação:**

- Deploy manual do PostgreSQL 16 Alpine via Docker Compose
    
- Deploy manual do midPoint 4.8 via Docker Compose
    
- Configuração de credenciais via arquivo `.env` com proteção de caracteres especiais
    
- Validação tripla de repositório (variáveis de ambiente, logs de bootstrap, query SQL)
    

**Evidências e Documentação:**

- Logs completos de inicialização do PostgreSQL
    
- Logs completos de bootstrap do midPoint
    
- Arquivo de validação de repositório (`repository-validation.txt`)
    
- Testes de persistência de dados
    
- Screenshots de acesso web bem-sucedido
    

## 3.2. Exclusões

- **Automação via script**: Nenhum script PowerShell ou Bash será executado para o deploy da aplicação
    
- **Integrações funcionais**: Conectores com sistemas externos (LDAP, AD, bases HR)
    
- **Customizações de fluxo**: Workflows, políticas e regras de negócio do midPoint
    
- **Configuração de alta disponibilidade**: Clusters, réplicas ou load balancers
    

## 3.3. Mudanças em Relação à GMUD-008

|Aspecto|GMUD-008 (Falhou)|GMUD-009 (Manual)|
|---|---|---|
|**Método de Deploy**|Script PowerShell automatizado|Execução manual passo-a-passo via SSH|
|**Gestão de Credenciais**|Expansão via here-string|Edição direta do arquivo `.env` com aspas simples|
|**Sintaxe de Variáveis**|Tentativas múltiplas (REPO_*, MP_SET)|Sintaxe oficial `MP_SET_midpoint.repository.*` validada|
|**Validação de Repositório**|Implícita nos logs|Validação tripla explícita (ENV + logs + SQL)|
|**Tratamento de Volumes**|Limpeza inconsistente|Limpeza manual com verificação visual|
|**Tempo de Execução**|Tentativa de zero-touch|2-4 horas com checkpoints obrigatórios|

---

## 4. Procedimento de Execução

A GMUD-009 seguirá rigorosamente o **POP-IGA-001 v3.0**, que foi desenvolvido incorporando todas as lições aprendidas da GMUD-008. O procedimento está estruturado em 14 fases com checkpoints de validação.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/50abc276-d12a-41c6-a373-2967c17d2975/pop_iga_v3.md)]​

## 4.1. Fases de Execução

## **FASE 1-4: Preparação de Infraestrutura Base (Pré-requisito)**

_Status: Assumido como concluído pela GMUD-004_

- VM `iga-gf-01` criada no Hyper-V com 8GB RAM, 4 vCPUs, 80GB disco
    
- Ubuntu Server 24.04.2 LTS instalado
    
- SSH configurado e acessível
    
- Docker Engine 29.x e Docker Compose 5.x instalados
    

**Validação Inicial:**

bash

`ssh paulo@xxx.xxx.xxx.xxx docker --version docker compose version`

---

## **FASE 5: Hardening de Segurança**

**5.1. Configurar IP Estático (Netplan)**

_Objetivo: Garantir que a VM mantenha IP fixo xxx.xxx.xxx.xxx_

bash

`# Identificar arquivo Netplan correto ls -la /etc/netplan/ # Editar arquivo (substituir pelo nome real) sudo nano /etc/netplan/50-cloud-init.yaml`

**Configuração esperada:**

text

`network:   version: 2  ethernets:    eth0:      dhcp4: false      addresses:        - xxx.xxx.xxx.xxx/22      routes:        - to: default          via: xxx.xxx.xxx.xxx      nameservers:        addresses:          - 8.8.8.8          - 8.8.4.4`

**Aplicar e validar:**

bash

`sudo netplan apply ip addr show eth0 ping -c 4 8.8.8.8`

**Checkpoint 5.1:**

-  IP `xxx.xxx.xxx.xxx` confirmado
    
-  Conectividade externa OK
    

---

**5.2. Configurar Sudoers Hardened**

_Objetivo: Permitir execução de comandos Docker sem senha (Least Privilege)_

bash

`sudo visudo`

**Adicionar no final do arquivo:**

text

`paulo ALL=(ALL) NOPASSWD: /usr/bin/mkdir, /usr/bin/chown, /usr/bin/docker, /usr/bin/du, /usr/bin/rm, /usr/bin/whoami`

**Validar:**

bash

`sudo -l sudo -n whoami  # Deve retornar "root" sem pedir senha`

**Checkpoint 5.2:**

-  Sudoers validado com whitelist de 6 comandos
    
-  Conformidade ISO 27001:2022 A.9.2.3 (Gestão de Privilégios)
    

---

## **FASE 7: Preparação da Estrutura do Projeto**

**7.1. Criar Estrutura de Diretórios**

bash

`# Criar diretório raiz sudo mkdir -p /srv/prj003 sudo chown -R paulo:paulo /srv/prj003 # Criar subdiretórios mkdir -p /srv/prj003/data/postgres mkdir -p /srv/prj003/data/midpoint/var mkdir -p /srv/prj003/logs/midpoint mkdir -p /srv/prj003/config mkdir -p /srv/prj003/evidencias # Validar estrutura tree /srv/prj003 -L 2`

**Checkpoint 7.1:**

-  Estrutura de diretórios criada
    
-  Permissões corretas (paulo:paulo)
    

---

**7.2. Criar Arquivo docker-compose.yml**

_Objetivo: Definir stack IGA com sintaxe oficial MP_SET validada_

bash

`cd /srv/prj003 nano docker-compose.yml`

**Conteúdo (copiar exatamente do POP-IGA-001 v3.0):**

text

`version: '3.8' services:   postgres:    image: postgres:16-alpine    container_name: iga-postgres    environment:      POSTGRES_DB: ${POSTGRES_DB}      POSTGRES_USER: ${POSTGRES_USER}      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}    volumes:      - ./data/postgres:/var/lib/postgresql/data    networks:      - iga-network    healthcheck:      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]      interval: 10s      timeout: 5s      retries: 5    restart: unless-stopped   midpoint:    image: evolveum/midpoint:4.8    container_name: iga-midpoint    ports:      - "8080:8080"    environment:      MP_SET_midpoint.repository.database: postgresql      MP_SET_midpoint.repository.jdbcUrl: jdbc:postgresql://postgres:5432/${POSTGRES_DB}      MP_SET_midpoint.repository.jdbcUsername: ${POSTGRES_USER}      MP_SET_midpoint.repository.jdbcPassword: ${POSTGRES_PASSWORD}      MP_SET_midpoint.administrator.initialPassword: ${MIDPOINT_ADMIN_PASSWORD}    volumes:      - ./data/midpoint/var:/opt/midpoint/var      - ./logs/midpoint:/opt/midpoint/var/log    depends_on:      postgres:        condition: service_healthy    networks:      - iga-network    restart: unless-stopped networks:   iga-network:    driver: bridge`

**Validar sintaxe:**

bash

`docker compose config`

**Checkpoint 7.2:**

-  Arquivo `docker-compose.yml` criado com sintaxe MP_SET oficial
    
-  Validação de sintaxe aprovada (sem erros)
    

---

**7.3. Criar Arquivo .env com Proteção de Caracteres Especiais**

_Objetivo: Configurar credenciais com aspas simples para proteção de caracteres especiais_

bash

`nano /srv/prj003/.env`

**Conteúdo (ajustar senhas):**

bash

`POSTGRES_DB=midpoint POSTGRES_USER=midpointuser POSTGRES_PASSWORD='P0stgr3sS3cur32026!' MIDPOINT_ADMIN_PASSWORD='M1dP0!ntAdm!n2026'`

**ATENÇÃO CRÍTICA:**

- ✅ **CORRETO**: `POSTGRES_PASSWORD='Senh@123!'` (com aspas simples)
    
- ❌ **ERRADO**: `POSTGRES_PASSWORD=Senh@123!` (sem aspas)
    

**Proteger arquivo:**

bash

`chmod 600 .env ls -la .env  # Deve mostrar -rw-------`

**Checkpoint 7.3:**

-  Arquivo `.env` criado com senhas entre aspas simples
    
-  Permissões 600 aplicadas
    

---

## **FASE 8: Deploy do Ambiente IGA (CRÍTICO)**

**8.1. Validações Pré-Deploy (Gate de Início)**

_Objetivo: Garantir que todos os pré-requisitos estejam atendidos antes do deploy_

bash

`cd /srv/prj003 # Validação 1: Conectividade Externa ping -c 4 8.8.8.8 # Validação 2: Resolução DNS nslookup registry-1.docker.io # Validação 3: Docker Funcional docker ps # Validação 4: Arquivo .env Configurado cat .env | grep -v '^#' | grep -v '^$' # Validação 5: docker-compose.yml Válido docker compose config # Validação 6: IP Estático Confirmado ip addr show eth0 | grep inet # Validação 7: Sudoers Hardened sudo -l | grep -E "mkdir|chown|docker|du|rm|whoami"`

**GATE DE INÍCIO:**  
🛑 **Se qualquer validação falhar, NÃO prosseguir com o deploy**

**Checkpoint 8.1:**

-  Todas as 7 validações aprovadas
    
-  Gate de início liberado
    

---

**8.2. Deploy Sequencial com Validação Tripla**

_Objetivo: Executar deploy em etapas controladas com validação explícita de repositório PostgreSQL_

**ETAPA 1: Inicializar PostgreSQL**

bash

`echo "Iniciando PostgreSQL..." docker compose up -d postgres # Acompanhar logs em tempo real docker logs -f iga-postgres`

**AGUARDAR até aparecer 2x:**

text

`database system is ready to accept connections`

**Pressionar Ctrl+C após a segunda ocorrência**

---

**ETAPA 2: Validar Health Check do PostgreSQL**

bash

`sleep 5 docker inspect iga-postgres | grep -A 5 '"Health"' # Esperado: "Status": "healthy" docker exec iga-postgres psql -U midpointuser -d midpoint -c "SELECT version();" # Esperado: PostgreSQL 16.x`

---

**ETAPA 3: Aguardar Estabilização**

bash

`echo "PostgreSQL healthy. Aguardando 10 segundos..." sleep 10`

---

**ETAPA 4: Inicializar midPoint**

bash

`echo "Iniciando midPoint..." docker compose up -d midpoint # Acompanhar logs em tempo real docker logs -f iga-midpoint`

**MENSAGENS CRÍTICAS A OBSERVAR:**

1. ✅ `MP configuration property: midpoint.repository.database = postgresql`
    
2. ✅ `Connection to database successful`
    
3. ✅ `Created User:administrator`
    
4. ✅ `Server startup in XXXX milliseconds`
    

**Pressionar Ctrl+C após "Server startup"**

---

**ETAPA 5: VALIDAÇÃO TRIPLA DE REPOSITÓRIO (CHECKPOINT CRÍTICO)**

_Objetivo: Confirmar que midPoint está usando PostgreSQL e não H2_

bash

`echo "=== CHECKPOINT CRÍTICO: VALIDAÇÃO DE REPOSITÓRIO ===" > /srv/prj003/evidencias/repository-validation.txt # Validação 1: Verificar variáveis de ambiente echo "--- Variáveis Injetadas ---" >> /srv/prj003/evidencias/repository-validation.txt docker exec iga-midpoint env | grep MP_SET >> /srv/prj003/evidencias/repository-validation.txt # Validação 2: Verificar logs de bootstrap echo "--- Tipo de Repositório nos Logs ---" >> /srv/prj003/evidencias/repository-validation.txt docker logs iga-midpoint 2>&1 | grep "midpoint.repository.database" >> /srv/prj003/evidencias/repository-validation.txt # Validação 3: Query SQL direta echo "--- Conexão PostgreSQL Ativa ---" >> /srv/prj003/evidencias/repository-validation.txt docker exec iga-postgres psql -U midpointuser -d midpoint -c "\dt" 2>&1 | head -5 >> /srv/prj003/evidencias/repository-validation.txt # Exibir resultado cat /srv/prj003/evidencias/repository-validation.txt`

**CHECKPOINT CRÍTICO:**  
🛑 **Se o arquivo `repository-validation.txt` NÃO contiver:**

- `MP_SET_midpoint.repository.database=postgresql`
    
- `midpoint.repository.database .:. postgresql`
    
- Tabelas do PostgreSQL (`m_user`, `m_role`, etc.)
    

**➡️ PARAR IMEDIATAMENTE e executar rollback**

**Checkpoint 8.2:**

-  PostgreSQL inicializado com sucesso
    
-  midPoint inicializado com sucesso
    
-  Validação tripla de repositório aprovada
    
-  Arquivo `repository-validation.txt` gerado
    

---

**ETAPA 6: Validar Containers**

bash

`docker ps`

**Esperado:**

text

`CONTAINER ID   IMAGE                     STATUS xxxxxxxxxx     evolveum/midpoint:4.8     Up X minutes yyyyyyyyyy     postgres:16-alpine        Up X minutes (healthy)`

---

**ETAPA 7: Salvar Logs Completos**

bash

`docker logs iga-postgres > /srv/prj003/evidencias/postgres-bootstrap.log 2>&1 docker logs iga-midpoint > /srv/prj003/evidencias/midpoint-bootstrap.log 2>&1`

**Checkpoint 8.2 Final:**

-  Containers em execução
    
-  Logs salvos em `/srv/prj003/evidencias/`
    

---

**8.3. Aguardar Estabilização da Aplicação**

bash

`echo "Aguardando estabilização completa (120 segundos)..." sleep 120 # Testar endpoint HTTP curl -I http://localhost:8080/midpoint # Esperado: HTTP/1.1 200 ou 302 # Salvar evidência curl -v http://localhost:8080/midpoint > /srv/prj003/evidencias/http-response.txt 2>&1`

**Checkpoint 8.3:**

-  Aguardado 2 minutos de estabilização
    
-  Endpoint HTTP respondendo
    

---

## **FASE 9: Validação e Testes**

**9.1. Testes Internos (Dentro da VM)**

bash

`# TESTE 1: Containers Rodando docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" # TESTE 2: Logs Sem Erros Críticos docker logs iga-postgres 2>&1 | grep -i 'error\|fatal' | wc -l docker logs iga-midpoint 2>&1 | grep -i 'error\|fatal' | grep -v 'ErrorPage' | wc -l # Esperado: 0 para ambos # TESTE 3: Verificar Tipo de Repositório docker logs iga-midpoint 2>&1 | grep "midpoint.repository.database" # Esperado: "postgresql" # 🚨 Se mostrar "h2" → FALHA CRÍTICA # TESTE 4: Conectividade com Banco docker exec iga-midpoint /bin/bash -c "timeout 5 bash -c '</dev/tcp/postgres/5432' && echo 'PostgreSQL alcançável' || echo 'Falha'" # TESTE 5: Portas Abertas sudo netstat -tulpn | grep -E "8080|5432" # TESTE 6: Persistência de Dados ls -lh /srv/prj003/data/postgres ls -lh /srv/prj003/data/midpoint/var`

**Checkpoint 9.1:**

-  Todos os 6 testes internos aprovados
    
-  Nenhum erro crítico nos logs
    
-  Repositório confirmado como PostgreSQL
    

---

**9.2. Obter IP da VM para Acesso Externo**

bash

`IP_VM=$(hostname -I | awk '{print $1}') echo "Endereço IP da VM: $IP_VM" echo "URL de Acesso: http://$IP_VM:8080/midpoint" # Salvar informações de acesso cat > /srv/prj003/ACCESS-INFO.txt <<EOF ============================================== INFORMAÇÕES DE ACESSO - IGA ============================================== URL: http://$IP_VM:8080/midpoint Usuário: administrator Senha: Conforme .env (MIDPOINT_ADMIN_PASSWORD) Tipo de Repositório: PostgreSQL (validado) Data do Deploy: $(date) ============================================== EOF cat /srv/prj003/ACCESS-INFO.txt`

**Checkpoint 9.2:**

-  IP da VM documentado
    
-  Arquivo `ACCESS-INFO.txt` criado
    

---

**9.3. Teste de Acesso Web (Do Windows Host)**

**Executar no PowerShell do Windows:**

powershell

`# Substituir pelo IP real da VM $VM_IP = "xxx.xxx.xxx.xxx" # Testar alcançabilidade Test-NetConnection -ComputerName $VM_IP -Port 8080 # Esperado: TcpTestSucceeded = True # Testar resposta HTTP Invoke-WebRequest -Uri "http://$VM_IP:8080/midpoint" -UseBasicParsing | Select-Object StatusCode # Esperado: StatusCode = 200`

**Checkpoint 9.3:**

-  Conectividade do Windows para VM confirmada
    
-  Porta 8080 acessível
    

---

**9.4. Teste de Login na Interface Web**

**Ação Manual Obrigatória:**

1. Abrir navegador no Windows
    
2. Acessar `http://xxx.xxx.xxx.xxx:8080/midpoint`
    
3. Na tela de login:
    
    - Usuário: `administrator`
        
    - Senha: Valor definido no `.env` (MIDPOINT_ADMIN_PASSWORD)
        
4. Clicar em **Sign In**
    

**Resultado Esperado:**

- ✅ Acesso concedido
    
- ✅ Dashboard do midPoint exibido
    
- ✅ Menu lateral funcional
    

**Checkpoint 9.4:**

-  Login bem-sucedido
    
-  Interface web carregada corretamente
    
-  Screenshot capturado e salvo
    

---

**9.5. Teste de Persistência**

_Objetivo: Validar que dados sobrevivem a reinicializações_

bash

`# Parar containers docker compose down sleep 10 # Reiniciar docker compose up -d sleep 60 # Validar dados persistiram docker exec iga-postgres psql -U midpointuser -d midpoint -c "SELECT COUNT(*) FROM m_user;" # Esperado: count = 1 (administrator existe)`

**Checkpoint 9.5:**

-  Containers reiniciados com sucesso
    
-  Usuário administrator persistiu
    
-  Teste de persistência aprovado
    

---

## 5. Critérios de Sucesso

A GMUD-009 será considerada **bem-sucedida** se **TODOS** os critérios abaixo forem atendidos:

## 5.1. Critérios Técnicos

-  PostgreSQL 16 inicializado e com status `healthy`
    
-  midPoint 4.8 inicializado sem erros críticos
    
-  Validação tripla de repositório confirmando uso de PostgreSQL (não H2)
    
-  Endpoint HTTP `http://xxx.xxx.xxx.xxx:8080/midpoint` respondendo com status 200
    
-  Login com usuário `administrator` bem-sucedido
    
-  Teste de persistência aprovado (dados sobrevivem a reinicializações)
    
-  Logs completos salvos em `/srv/prj003/evidencias/`
    

## 5.2. Critérios de Evidência

-  Arquivo `repository-validation.txt` contendo as 3 validações
    
-  Arquivo `postgres-bootstrap.log` completo
    
-  Arquivo `midpoint-bootstrap.log` completo
    
-  Arquivo `ACCESS-INFO.txt` com credenciais de acesso
    
-  Screenshot da interface web do midPoint após login
    

## 5.3. Critérios de Conformidade

-  IP estático `xxx.xxx.xxx.xxx` configurado e validado
    
-  Sudoers hardened com whitelist de 6 comandos
    
-  Arquivo `.env` com permissões 600
    
-  Conformidade com ISO 27001:2022 A.9.2.3 (Gestão de Privilégios)
    

---

## 6. Plano de Rollback

## 6.1. Gatilhos para Rollback

O rollback será executado **IMEDIATAMENTE** se:

- Validação tripla de repositório falhar (midPoint usando H2 em vez de PostgreSQL)
    
- Erro SCRAM de autenticação do PostgreSQL
    
- midPoint não inicializar após 10 minutos
    
- Endpoint HTTP não responder após 5 minutos de containers rodando
    
- Login com `administrator` falhar
    

## 6.2. Procedimento de Rollback

bash

`# 1. Parar containers cd /srv/prj003 docker compose down -v # 2. Limpar dados corrompidos sudo rm -rf /srv/prj003/data/postgres/* sudo rm -rf /srv/prj003/data/midpoint/var/* # 3. Preservar evidências mkdir -p /srv/prj003/evidencias/GMUD-009-ROLLBACK cp /srv/prj003/evidencias/*.log /srv/prj003/evidencias/GMUD-009-ROLLBACK/ cp /srv/prj003/.env /srv/prj003/evidencias/GMUD-009-ROLLBACK/.env.backup # 4. Validar limpeza docker ps -a  # Deve estar vazio ls -lh /srv/prj003/data/postgres/  # Deve estar vazio`

## 6.3. Tempo de Rollback

**Tempo estimado:** 5 minutos

---

## 7. Comunicação e Stakeholders

## 7.1. Equipe Envolvida

|Papel|Nome|Responsabilidade|
|---|---|---|
|**Executor**|Paulo Feitosa|Execução manual do procedimento POP-IGA-001 v3.0|
|**Revisor Técnico**|Assistente IA|Validação de lições aprendidas da GMUD-008|
|**Aprovador**|Paulo Feitosa|Decisão de prosseguir ou executar rollback|

## 7.2. Comunicação

**Antes da Execução:**

- Nenhuma comunicação necessária (ambiente greenfield sem usuários)
    

**Durante a Execução:**

- Documentação contínua via log de terminal
    
- Captura de screenshots em pontos críticos
    

**Após a Execução:**

- Criação de REL-GMUD-009 com status (sucesso ou falha)
    
- Se sucesso: Planejamento da GMUD-010 (automação)
    

---

## 8. Documentação e Evidências

## 8.1. Artefatos Obrigatórios

Todos os arquivos abaixo devem ser gerados em `/srv/prj003/evidencias/`:

- `repository-validation.txt` - Validação tripla de repositório
    
- `postgres-bootstrap.log` - Log completo de inicialização do PostgreSQL
    
- `midpoint-bootstrap.log` - Log completo de bootstrap do midPoint
    
- `http-response.txt` - Resposta HTTP do endpoint web
    
- `ACCESS-INFO.txt` - Credenciais e URLs de acesso
    
- Screenshots da interface web (formato PNG)
    

## 8.2. Relatório de Execução

Após conclusão da GMUD-009, será criado o documento **REL-GMUD-009** contendo:

- Cronologia de execução (timestamp de cada fase)
    
- Status de todos os checkpoints
    
- Análise comparativa com GMUD-008 (o que foi corrigido)
    
- Observações para GMUD-010 (automação futura)
    
- Lições aprendidas adicionais
    

---

## 9. Riscos Identificados e Mitigações

|Risco|Probabilidade|Impacto|Mitigação|
|---|---|---|---|
|**Caracteres especiais na senha causarem erro SCRAM**|Média|Alto|Uso obrigatório de aspas simples no `.env` conforme POP-IGA-001 v3.0|
|**midPoint usar H2 em vez de PostgreSQL**|Baixa|Crítico|Validação tripla explícita de repositório (checkpoint obrigatório)|
|**Volume PostgreSQL corrompido**|Baixa|Médio|Limpeza manual de volumes antes do deploy + validação visual|
|**Timeout na inicialização**|Baixa|Médio|Logs monitorados em tempo real + sleep estratégico entre etapas|
|**Erro de digitação manual**|Média|Médio|Uso de copiar/colar do POP-IGA-001 v3.0 + validação de sintaxe `docker compose config`|

---

## 10. Conformidade e Governança

## 10.1. Alinhamento com Frameworks

|Framework|Requisito|Como a GMUD-009 Atende|
|---|---|---|
|**ISO 27001:2022**|A.9.2.3 - Gestão de Privilégios|Sudoers hardened com whitelist mínima|
|**NIST CSF 2.0**|PR.AC-4 - Princípio do Menor Privilégio|Permissões 600 no `.env`, whitelist de comandos|
|**CIS Controls v8**|5.4 - Restrinção de Privilégios Administrativos|Validação de sudoers no checkpoint 5.2|

## 10.2. Rastreabilidade

- **Origem**: Lições aprendidas da REL-GMUD-008
    
- **Base Técnica**: POP-IGA-001 v3.0 (procedimento validado)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/50abc276-d12a-41c6-a373-2967c17d2975/pop_iga_v3.md)]​
    
- **Próximos Passos**: GMUD-010 (tentativa de automação com base no sucesso da GMUD-009)
    

---

## 11. Aprovações

|Papel|Nome|Data|Assinatura|
|---|---|---|---|
|**Solicitante**|Paulo Feitosa|20/01/2026|_________________|
|**Executor**|Paulo Feitosa|20/01/2026|_________________|
|**Aprovador Técnico**|Paulo Feitosa|20/01/2026|_________________|

---

## 12. Anexos

- **Anexo A**: POP-IGA-001 v3.0 - Procedimento Operacional Padrão[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/50abc276-d12a-41c6-a373-2967c17d2975/pop_iga_v3.md)]​
    
- **Anexo B**: REL-GMUD-008 - Relatório de Falha (lições aprendidas)
    
- **Anexo C**: Arquivo `docker-compose.yml` de referência
    
- **Anexo D**: Template de arquivo `.env` com aspas simples
    

---

## 13. Próximos Passos Pós-GMUD-009

## 13.1. Se a GMUD-009 For Bem-Sucedida

1. **Análise de Logs**: Revisar logs completos para identificar padrões de inicialização
    
2. **Documentação de Comportamento**: Criar baseline de comportamento esperado do sistema
    
3. **Planejamento GMUD-010**: Projetar automação com base no procedimento manual validado
    
4. **Estratégia de Automação**:
    
    - Módulo 1: Script de preparação de SO (executado 1x manualmente)
        
    - Módulo 2: Script de deploy IaC (idempotente)
        
    - Módulo 3: Script de validação de health (automatizado)
        

## 13.2. Se a GMUD-009 Falhar

1. **Análise de Causa Raiz**: Identificar qual checkpoint falhou
    
2. **Revisão do POP-IGA-001**: Atualizar procedimento com correções
    
3. **Nova Tentativa**: GMUD-009.1 com procedimento corrigido
    
4. **Adiamento da Automação**: GMUD-010 só será iniciada após sucesso manual consistente
    

---

**Status do Documento:** Aprovado para Execução  
**Versão:** 1.0  
**Data de Criação:** 20/01/2026  
**Próxima Revisão:** Após execução (REL-GMUD-009)

---

**FIM DO DOCUMENTO GMUD-009**
