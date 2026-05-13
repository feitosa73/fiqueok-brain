## 📊 Informações da Mudança

|**Campo**|**Valor**|
|---|---|
|**ID da GMUD**|GMUD-008|
|**Título**|Implantação da Stack IGA (midPoint 4.10 + PostgreSQL 16)|
|**Solicitante**|Paulo - Fiqueok Consultoria|
|**Executor**|Paulo - Fiqueok Consultoria|
|**Data de Criação**|24/12/2025|
|**Data de Execução**|24/12/2025|
|**Prioridade**|Alta|
|**Categoria**|Aplicação / Gestão de Identidades|
|**Impacto**|Baixo (Novo serviço, sem downtime de sistemas existentes)|
|**Risco**|Médio (Complexidade no bootstrap da aplicação)|
|**Status**|🟡 Planejada|

---

## 🎯 Objetivo

Realizar o deploy da stack de IGA no servidor `iga-p-01` via Docker Compose para garantir:

1. Ambiente de IGA persistente com PostgreSQL 16.
    
2. Comunicação nativa entre midPoint e Domain Controller (DNS interno).
    
3. Base tecnológica para a governança de acessos do projeto PRJ002.
    

---

## 📝 Descrição Técnica

### Estado Atual (Antes)

- Servidor `iga-p-01` com IP estático e Docker instalado.
    
- Nenhuma stack de IGA em execução.
    
- Banco de dados não inicializado.
    

### Estado Desejado (Depois)

- Container `midpoint-server` rodando na versão 4.10.
    
- Container `midpoint-db` rodando PostgreSQL 16.
    
- Acesso Web disponível em `http://xxx.xxx.xxx.xxx:8080/midpoint`.
    
- Persistência de dados configurada em volumes locais.
    

---

## 🔧 Mudanças a Serem Realizadas

### 1️⃣ Preparação do File System

**Ação:** Criação de diretórios e ajuste de permissões para o UID 1000 (usuário midpoint).

Bash

```
cd ~/midpoint_lab
mkdir -p midpoint_home postgres_data
sudo chown -R 1000:1000 ./midpoint_home
```

### 2️⃣ Configuração da Stack (Docker Compose)

Arquivo: ~/midpoint_lab/docker-compose.yml

Conteúdo: (Utilizando injeção de variáveis via lista para evitar erros de bootstrap)

YAML

```
services:
  midpoint-db:
    image: postgres:16-alpine
    container_name: midpoint-db
    environment:
      POSTGRES_DB: midpoint
      POSTGRES_USER: midpoint
      POSTGRES_PASSWORD: password_fiqueok
    volumes:
      - ./postgres_data:/var/lib/postgresql/data
    networks:
      - midpoint-net

  midpoint-server:
    image: evolveum/midpoint:4.10
    container_name: midpoint-server
    depends_on:
      - midpoint-db
    ports:
      - "8080:8080"
    environment:
      - midpoint.repository.jdbcUrl=jdbc:postgresql://midpoint-db:5432/midpoint
      - midpoint.repository.jdbcUsername=midpoint
      - midpoint.repository.jdbcPassword=password_fiqueok
      - midpoint.repository.databasePlatform=postgresql
    volumes:
      - ./midpoint_home:/opt/midpoint/var
    dns:
      - xxx.xxx.xxx.xxx
    networks:
      - midpoint-net

networks:
  midpoint-net:
    driver: bridge
```

---

## ⏱️ Janela de Manutenção

|**Item**|**Descrição**|
|---|---|
|**Data**|24/12/2025|
|**Horário**|09:30 - 10:00 BRT|
|**Duração Estimada**|30 minutos|
|**Downtime Esperado**|N/A (Novo Serviço)|
|**Sistemas Afetados**|Nenhum|

---

## ✅ Critérios de Sucesso

### Testes de Validação

1. **Container Status:** `docker ps` deve mostrar ambos os containers como "Up".
    
2. **Logs de Inicialização:** `docker logs midpoint-server` deve exibir "Started MidPoint Application".
    
3. **Acesso Web:** Sucesso ao carregar a página de login no IP `.100`.
    
4. **Login:** Acesso com `administrator` / `5ecr3t`.
    

---

## 🔄 Plano de Rollback

### Se a aplicação falhar no bootstrap:

1. Parar e remover volumes (limpeza total):
    
    Bash
    
    ```
    docker compose down -v
    ```
    
2. Validar logs do banco de dados para descartar falha de autenticação.
    
3. Reavaliar permissões da pasta `midpoint_home`.
    

---

## 🔐 Requisitos de Segurança

- ✅ Senhas de banco de dados não expostas em repositórios públicos.
    
- ✅ DNS apontando para o Domain Controller para futuras integrações seguras.
    
- ✅ Permissões de sistema de arquivos restritas ao processo do midPoint.
    

---

## 📋 Checklist de Execução

### Pré-Execução

- [ ] Validar se o IP estático está ativo (`ip addr`).
    
- [ ] Validar se o DNS resolve o AD (`nslookup`).
    
- [ ] Garantir espaço em disco suficiente (> 10GB).
    

### Execução

- [ ] Criar `docker-compose.yml`.
    
- [ ] Aplicar permissões `chown` na pasta home.
    
- [ ] Executar `docker compose up -d`.
    
- [ ] Monitorar logs: `docker logs -f midpoint-server`.
    

### Pós-Execução

- [ ] Realizar login na interface Web.
    
- [ ] Tirar screenshot do Dashboard inicial.
    
- [ ] Atualizar status da GMUD no Obsidian.
    

---

## ✍️ Aprovações e Assinaturas

|**Papel**|**Nome**|**Data**|**Assinatura**|
|---|---|---|---|
|Solicitante|Paulo|24/12/2025|Paulo F.|
|Executor|Paulo|24/12/2025|Paulo F.|
|Aprovador|Paulo|24/12/2025|Paulo F.|

---

**Criado por:** Gemini (Google) para Fiqueok Consultoria

**Status:** Pronta para Execução.
