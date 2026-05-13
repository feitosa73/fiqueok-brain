# 

## **Deploy Manual Passo-a-Passo do Ambiente IGA**

## **Projeto PRJ003 - IGA Greenfield Reference Architecture**

---

|Campo|Informação|
|---|---|
|**GMUD**|GMUD-007|
|**Versão**|1.0|
|**Tipo**|Técnica - Infraestrutura (Exploratória Manual)|
|**Categoria**|Deploy Incremental com Validação por Etapa|
|**Projeto**|PRJ003 - IGA Greenfield Reference Architecture|
|**Contexto**|Living Lab Fiqueok 2.0|
|**Owner/Executor**|Paulo Feitosa|
|**Data de Criação**|18/01/2026|
|**Data Planejada**|19/01/2026|
|**Status**|Planejada|
|**Prioridade**|Alta|
|**VM Alvo**|IGA-GF-01 (Ubuntu 24.04.2 LTS)|
|**IP da VM**|xxx.xxx.xxx.xxx|
|**Dependências**|GMUD-004 (Cold Start), Lições GMUD-005/006|

---

## **1. OBJETIVO DA GMUD**

Realizar o **deploy manual e incremental** do ambiente midPoint 4.8 + PostgreSQL 16 no PRJ003, executando cada etapa de forma **interativa e validada** para:

- **Identificar exatamente onde ocorrem falhas** nas tentativas anteriores
    
- **Validar conectividade de rede antes de pull de imagens**
    
- **Confirmar credenciais e bootstrap do midPoint manualmente**
    
- **Documentar todos os passos bem-sucedidos** para posterior automação na GMUD-008
    
- **Eliminar incertezas técnicas** sobre Race Conditions, DNS, sudo e autenticação
    

**Critério de Sucesso:**  
Acesso funcional ao midPoint via interface web com credenciais validadas, **documentando cada comando executado com sucesso**.

---

## **2. CONTEXTO E JUSTIFICATIVA**

## **2.1. Histórico de Falhas**

|GMUD|Problema Principal|Causa Raiz|
|---|---|---|
|GMUD-005|Falha de autenticação `administrator:5ecur!ty`|Race Condition no bootstrap PostgreSQL/midPoint ​|
|GMUD-006|Falha de resolução DNS do Docker Hub|Problema de rede do Hyper-V + sudo sem senha ​|

## **2.2. Estratégia de Mudança**

Ao invés de executar **script automatizado completo** (que falhou 2x), a GMUD-007 adota:

✅ **Execução manual via SSH** - Comandos executados um a um com validação humana  
✅ **Checkpoints entre etapas** - Possibilidade de parar e diagnosticar a qualquer momento  
✅ **Documentação em tempo real** - Cada comando e resultado registrado  
✅ **Validação de pré-requisitos rigorosa** - Rede, sudo, Docker funcional antes de iniciar  
✅ **Coleta de evidências contínua** - Logs salvos após cada etapa

**Diferencial Estratégico:**  
Esta GMUD é **exploratória e educacional** - o objetivo é **aprender o que funciona** para então automatizar na GMUD-008.​

---

## **3. PRÉ-REQUISITOS OBRIGATÓRIOS**

## **3.1. Validação de Infraestrutura**

Antes de iniciar a GMUD-007, validar **manualmente** na VM:

bash

`# 1. Conectividade SSH ssh paulo@xxx.xxx.xxx.xxx "echo 'SSH OK'" # 2. Sudo sem senha configurado ssh paulo@xxx.xxx.xxx.xxx "sudo -n whoami" # Esperado: root (sem solicitar senha) # 3. Docker instalado e funcional ssh paulo@xxx.xxx.xxx.xxx "docker --version" # Esperado: Docker version 29.1.4 ou superior # 4. Docker Compose instalado ssh paulo@xxx.xxx.xxx.xxx "docker compose version" # Esperado: Docker Compose version v5.0.1 ou superior # 5. CRÍTICO: Conectividade Externa (lição GMUD-006) ssh paulo@xxx.xxx.xxx.xxx "ping -c 4 8.8.8.8" # Esperado: 4 packets transmitted, 4 received # 6. CRÍTICO: Resolução DNS ssh paulo@xxx.xxx.xxx.xxx "nslookup registry-1.docker.io" # Esperado: endereço IP válido retornado # 7. CRÍTICO: Acesso ao Docker Hub ssh paulo@xxx.xxx.xxx.xxx "curl -I https://registry-1.docker.io/v2/" # Esperado: HTTP 200 ou 401 (autenticação requerida, mas alcançável) # 8. Estado limpo - nenhum container em execução ssh paulo@xxx.xxx.xxx.xxx "docker ps -a" # Esperado: CONTAINER ID... (sem containers listados)`

**Gate de Início:**  
❌ Se **qualquer validação falhar**, a GMUD-007 **NÃO pode iniciar**. Resolver problemas de infraestrutura primeiro.​

---

## **4. ESCOPO DA GMUD**

## **4.1. Incluído no Escopo**

✅ Criação manual da estrutura de diretórios `/srv/prj003`  
✅ Criação manual do arquivo `.env` com credenciais  
✅ Criação manual do `docker-compose.yml`  
✅ Pull manual das imagens Docker (PostgreSQL e midPoint)  
✅ Inicialização sequencial: PostgreSQL → validação → midPoint  
✅ Acompanhamento de logs em tempo real  
✅ Teste de autenticação na interface web  
✅ Documentação de **todos os comandos executados**  
✅ Coleta de evidências técnicas em `/srv/prj003/evidencias`

## **4.2. Fora do Escopo**

❌ Automação via script PowerShell ou Bash  
❌ Configuração funcional do midPoint (sincronizações, recursos, roles)  
❌ Integração com fontes de dados externas (HR, AD)  
❌ Definição de fluxos JML ou automações de provisionamento  
❌ Criação de identidades ou objetos de negócio

---

## **5. PLANO DE EXECUÇÃO MANUAL - PASSO A PASSO**

## **ETAPA 1: Preparação do Ambiente**

bash

`# Conectar na VM via SSH ssh paulo@xxx.xxx.xxx.xxx # Criar estrutura de diretórios sudo mkdir -p /srv/prj003/data/postgres sudo mkdir -p /srv/prj003/data/midpoint/var sudo mkdir -p /srv/prj003/logs/midpoint sudo mkdir -p /srv/prj003/evidencias # Ajustar permissões sudo chown -R paulo:paulo /srv/prj003 # Validar criação ls -la /srv/prj003`

**Checkpoint 1:** Diretórios criados? ✅ Prosseguir | ❌ Diagnosticar

---

## **ETAPA 2: Criação do Arquivo de Credenciais**

bash

`# Criar arquivo .env com credenciais cat > /srv/prj003/.env << 'EOF' # Credenciais do PostgreSQL (Backend - Repositório) POSTGRES_DB=midpoint POSTGRES_USER=midpoint POSTGRES_PASSWORD=P@ssw0rd_Postgres_2026 # Credenciais do midPoint (Frontend - Aplicação) MIDPOINT_ADMIN_USERNAME=administrator MIDPOINT_ADMIN_PASSWORD=5ecur!ty EOF # Proteger o arquivo chmod 600 /srv/prj003/.env # Validar conteúdo (SEM expor senhas no log) ls -la /srv/prj003/.env`

**Checkpoint 2:** Arquivo `.env` criado com permissões corretas? ✅ Prosseguir | ❌ Corrigir

---

## **ETAPA 3: Criação do docker-compose.yml**

bash

`# Criar arquivo docker-compose.yml cat > /srv/prj003/docker-compose.yml << 'EOF' services:   postgres:    image: postgres:16-alpine    container_name: postgres    environment:      POSTGRES_DB: ${POSTGRES_DB}      POSTGRES_USER: ${POSTGRES_USER}      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}    volumes:      - /srv/prj003/data/postgres:/var/lib/postgresql/data    networks:      - iga-network    healthcheck:      test: ["CMD-SHELL", "pg_isready -U midpoint"]      interval: 10s      timeout: 5s      retries: 5   midpoint:    image: evolveum/midpoint:4.8    container_name: midpoint    ports:      - "8080:8080"    environment:      MIDPOINT_REPOSITORY_DATABASE_URL: jdbc:postgresql://postgres:5432/midpoint      MIDPOINT_REPOSITORY_DATABASE_USERNAME: ${POSTGRES_USER}      MIDPOINT_REPOSITORY_DATABASE_PASSWORD: ${POSTGRES_PASSWORD}    volumes:      - /srv/prj003/data/midpoint/var:/opt/midpoint/var      - /srv/prj003/logs/midpoint:/opt/midpoint/var/log    depends_on:      postgres:        condition: service_healthy    networks:      - iga-network networks:   iga-network:    driver: bridge EOF # Validar sintaxe do arquivo cd /srv/prj003 docker compose config`

**Checkpoint 3:** Arquivo `docker-compose.yml` válido? ✅ Prosseguir | ❌ Corrigir sintaxe

---

## **ETAPA 4: Pull Manual das Imagens Docker**

bash

`# Fazer pull da imagem do PostgreSQL (validar rede) docker pull postgres:16-alpine # Validar download docker images | grep postgres # Fazer pull da imagem do midPoint docker pull evolveum/midpoint:4.8 # Validar download docker images | grep midpoint`

**Checkpoint 4:** Imagens baixadas com sucesso? ✅ Prosseguir | ❌ Diagnosticar rede

---

## **ETAPA 5: Inicialização do PostgreSQL (Fase 1)**

bash

`# Carregar variáveis de ambiente cd /srv/prj003 export $(grep -v '^#' .env | xargs) # Inicializar APENAS o PostgreSQL docker compose up -d postgres # Aguardar inicialização completa (acompanhar logs) docker logs -f postgres # Aguardar mensagem: "database system is ready to accept connections" # Pressionar CTRL+C após ver a mensagem 2 vezes # Validar health check docker inspect postgres | grep -A 5 Health # Esperado: "Status": "healthy" # Testar conexão ao banco docker exec postgres psql -U midpoint -d midpoint -c "SELECT version();"`

**Checkpoint 5:** PostgreSQL inicializado e saudável? ✅ Prosseguir | ❌ Diagnosticar

---

## **ETAPA 6: Inicialização do midPoint (Fase 2)**

bash

`# Inicializar o midPoint docker compose up -d midpoint # Acompanhar bootstrap em tempo real docker logs -f midpoint # Aguardar mensagens: # - "Connection to database successful" # - "Created User:administrator" # - "Server startup in [XXXX] milliseconds" # Pressionar CTRL+C após "Server startup" # Validar containers em execução docker ps # Esperado: 2 containers (postgres e midpoint) com status "Up" # Salvar evidência de runtime docker ps > /srv/prj003/evidencias/containers-runtime.txt`

**Checkpoint 6:** midPoint inicializado sem erros? ✅ Prosseguir | ❌ Diagnosticar

---

## **ETAPA 7: Validação de Acesso Web**

bash

`# Aguardar 2 minutos para estabilização sleep 120 # Testar endpoint HTTP curl -I http://xxx.xxx.xxx.xxx:8080/midpoint # Esperado: HTTP/1.1 200 ou 302 (redirect para login) # Salvar evidência de acesso HTTP curl -v http://xxx.xxx.xxx.xxx:8080/midpoint > /srv/prj003/evidencias/http-response.txt 2>&1`

**Checkpoint 7:** Endpoint HTTP respondendo? ✅ Prosseguir | ❌ Diagnosticar

---

## **ETAPA 8: Teste de Autenticação Manual**

**Ação Manual Obrigatória:**

1. Abrir navegador web no host Windows
    
2. Acessar: `http://xxx.xxx.xxx.xxx:8080/midpoint`
    
3. Tentar login com:
    
    - **Usuário:** `administrator`
        
    - **Senha:** `5ecur!ty`
        
4. **Documentar resultado:**
    
    - ✅ Login bem-sucedido → Dashboard do midPoint acessível
        
    - ❌ Login rejeitado → Capturar screenshot do erro
        

**Checkpoint 8:** Login bem-sucedido? ✅ GMUD-007 CONCLUÍDA | ❌ Diagnosticar

---

## **ETAPA 9: Coleta de Evidências Finais**

bash

`# Coletar logs completos docker logs postgres > /srv/prj003/evidencias/postgres-bootstrap.log 2>&1 docker logs midpoint > /srv/prj003/evidencias/midpoint-bootstrap.log 2>&1 # Salvar configurações docker inspect postgres > /srv/prj003/evidencias/postgres-config.json docker inspect midpoint > /srv/prj003/evidencias/midpoint-config.json # Salvar estado dos volumes du -sh /srv/prj003/data/postgres du -sh /srv/prj003/data/midpoint/var ls -lR /srv/prj003/data > /srv/prj003/evidencias/volumes-structure.txt # Validar persistência docker compose down docker compose up -d sleep 60 curl -I http://xxx.xxx.xxx.xxx:8080/midpoint # Esperado: HTTP 200/302 novamente (dados persistiram)`

**Checkpoint 9:** Persistência validada? ✅ Evidências coletadas | ❌ Registrar falha

---

## **6. ESTRATÉGIA DE REVERSIBILIDADE (ADR-002)**

## **6.1. Rollback Manual**

Em caso de falha em **qualquer etapa**:

bash

`# 1. Parar todos os containers docker compose down # 2. Remover volumes (reset completo) sudo rm -rf /srv/prj003/data/postgres sudo rm -rf /srv/prj003/data/midpoint/var sudo rm -rf /srv/prj003/logs/midpoint # 3. Validar limpeza ls -la /srv/prj003/data # Esperado: diretórios vazios # 4. Preservar evidências # NÃO remover /srv/prj003/evidencias`

## **6.2. Gate de Decisão**

Rollback deve ser acionado quando:​

- Falha de pull de imagens Docker (problema de rede)
    
- PostgreSQL não atinge estado `healthy`
    
- midPoint não inicializa corretamente
    
- Falha de autenticação na interface web
    
- Qualquer erro crítico não previsto
    

**Tempo Estimado de Rollback:** 3 minutos​

---

## **7. ALINHAMENTO COM GOVERNANÇA**

## **7.1. Aderência aos Canvases de Identidade**

|Canvas|Status|Observação|
|---|---|---|
|**CAN-ID-001**|Não alterado|Nenhuma identidade criada nesta GMUD ​|
|**CAN-ID-002**|Não alterado|Nenhuma autoridade de dados definida ​|
|**CAN-ID-003**|Não alterado|Nenhum estado de identidade implementado ​|
|**DEC-ID-001**|Respeitado|GMUD técnica sem decisões semânticas ​|

## **7.2. Conformidade com Frameworks**

|Framework|Controle|Implementação|
|---|---|---|
|**ISO 27001:2022**|A.8.32 Gestão de Mudanças|GMUD formal com rollback documentado ​|
|**ITIL v4**|Change Enablement|Orquestração manual controlada ​|
|**NIST CSF 2.0**|PR.IP-3 Configuration Control|Comandos documentados e versionáveis ​|
|**CIS Controls**|3.14 Log Management|Evidências coletadas em `/srv/prj003/evidencias` ​|

---

## **8. RISCOS E MITIGAÇÕES**

|Risco|Probabilidade|Impacto|Mitigação|
|---|---|---|---|
|Problema de rede persistir|Média|Alto|Validação obrigatória no Pré-Requisito #5-7 ​|
|Sudo solicitar senha|Baixa|Médio|Validação obrigatória no Pré-Requisito #2 ​|
|Race Condition no bootstrap|Baixa|Médio|Health check implementado + aguardo manual ​|
|Falha de autenticação|Média|Alto|Documentar exatamente erro apresentado para análise|
|Volumes corrompidos|Baixa|Baixo|Limpeza completa antes de iniciar|

---

## **9. CRITÉRIOS DE SUCESSO**

A GMUD-007 será considerada **bem-sucedida** quando:

✅ Todos os pré-requisitos validados com sucesso  
✅ PostgreSQL em estado `healthy` confirmado  
✅ midPoint inicializado com mensagem `Server startup` nos logs  
✅ Endpoint HTTP `http://xxx.xxx.xxx.xxx:8080/midpoint` acessível  
✅ **Login com `administrator:5ecur!ty` bem-sucedido**  
✅ Dashboard do midPoint acessível via navegador  
✅ Persistência validada (sobrevive a `docker compose down/up`)  
✅ Evidências técnicas coletadas e armazenadas  
✅ **Todos os comandos executados documentados** para GMUD-008

---

## **10. IMPACTOS ESPERADOS**

## **10.1. Impactos Positivos**

- **Eliminação de incertezas técnicas** sobre o que funciona
    
- **Base sólida para automação** na GMUD-008
    
- **Validação do modelo de governança** do PRJ003
    
- **Documentação detalhada** de procedimentos funcionais
    
- **Confiança técnica** para próximas integrações
    

## **10.2. Impactos Negativos**

- **Tempo de execução maior** (estimado: 1-2 horas vs. 15 min automatizado)
    
- **Requer interação humana constante** (não pode ser agendado)
    
- **Não reusável diretamente** (serve apenas para aprendizado)
    

---

## **11. DOCUMENTOS RELACIONADOS**

- **GMUDs Anteriores:** GMUD-004 (Cold Start), GMUD-005 (Falha Race Condition), GMUD-006 (Falha Rede)​
    
- **Canvases:** CAN-ID-001, CAN-ID-002, CAN-ID-003​
    
- **ADRs:** ADR-002 (Reversibilidade e IaC), ADR-003 (Cross-Mapping GRC)​
    
- **Governança:** DEC-ID-001 (Governança de Decisão), DGC-001 (Data Governance)​
    
- **POPs:** POP-001 (Implementação Infraestrutura IGA)​
    

---

## **12. APROVAÇÃO**

|Papel|Nome|Status|Data|
|---|---|---|---|
|**Solicitante**|Paulo Feitosa|Aprovado|18/01/2026|
|**Executor**|Paulo Feitosa|Aprovado|18/01/2026|
|**Aprovador GRC**|Paulo Feitosa|Aprovado|18/01/2026|
|**Aprovador Técnico**|Paulo Feitosa|Aprovado|18/01/2026|

---

## **13. CONTROLE DE VERSÃO**

|Versão|Data|Autor|Mudança|
|---|---|---|---|
|1.0|18/01/2026|Paulo Feitosa|Criação da GMUD-007 - Deploy Manual Passo-a-Passo|

---

## **14. PRÓXIMOS PASSOS**

**Após conclusão bem-sucedida da GMUD-007:**

1. **Criar GMUD-008** - Automação IaC completa baseada nos comandos validados
    
2. **Gerar script PowerShell** com todos os comandos da GMUD-007
    
3. **Implementar testes automatizados** de validação de cada etapa
    
4. **Criar template reutilizável** para deploys futuros
    
5. **Documentar lições aprendidas** em formato de tutorial
    

---

**Repositório:** `FiqueokBrain/10-Projetos/PRJ003-IGA-GREENFIELD/40-GMUDs/GMUD-007.md`

**Status:** 📋 **Pronto para Execução Manual**
