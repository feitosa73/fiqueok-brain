# GMUD-009: Implementação OrangeHRM Community Edition (v1.1)

**Documento:** Guia de Mudança / Deploy (GMUD)  
**ID:** GMUD-009  
**Versão:** 1.1  
**Data:** 24 de dezembro de 2025  
**Status:** **Pronto para Execução**  
**Responsável:** Paulo (GRC/IAM Lead)  
**Ambiente:** IGA-P-01 (Lab Hyper-V Ubuntu xxx.xxx.xxx.xxx)  
**Duração Estimada:** 2 horas  
**Dependência:** GMUD-008 (midPoint 4.10 OK)

---

## 1. Objetivo da Mudança

Implantar **OrangeHRM Community Edition** como **fonte autoritativa de identidades** para integração com midPoint, conforme **ARQ003 - Arquitetura de Referência IGA**.[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/0fe05a0b-1e03-4eac-9d50-15cdc4340106/paste.txt)​

**Resultado Esperado:**

- ✅ Stack OrangeHRM em `http://xxx.xxx.xxx.xxx:8081`
    
- ✅ MariaDB com tabela `hs_hr_employee` populada
    
- ✅ Conta **READ-ONLY** para conector midPoint (GMUD-010)
    
- ✅ Volumes persistentes e `.env` com senhas no KeePass
    

---

## 2. Escopo e Pré-requisitos

## 2.1 Pré-requisitos (Verificados)

- ✅ VM Ubuntu 22.04 (xxx.xxx.xxx.xxx) com Docker Compose[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/0fe05a0b-1e03-4eac-9d50-15cdc4340106/paste.txt)​
    
- ✅ Stack midPoint 4.10 em `http://xxx.xxx.xxx.xxx:8080/midpoint`[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/0fe05a0b-1e03-4eac-9d50-15cdc4340106/paste.txt)​
    
- ✅ ARQ003 aprovado (seções 3.1, 4.4 OrangeHRM Stack) [canvas]
    
- ✅ Porta 8081 livre (`netstat -tlnp | grep 8081`)
    

## 2.2 Dependências Pós-Deploy

- **GMUD-010**: Resource OrangeHRM no midPoint (DatabaseTable)
    
- **GMUD-011**: Campanhas de Certificação de Acesso
    

---

## 3. Procedimento de Implementação

## 3.1 Preparação do Ambiente (15 min)

bash

`# 1. Criar estrutura de diretórios cd /home/paulo/iga-lab mkdir -p orangehrm_lab/{mariadb_data,config} cd orangehrm_lab # 2. CRIAR .env com senhas do KeePass (NUNCA commitar!) cat > .env << 'EOF' MYSQL_ROOT_PASSWORD=Fiqueok_MariaDB_Root_2025_StrongPass123! ORANGEHRM_DB_PASSWORD=Fiqueok_OrangeHRM_DB_2025_StrongPass123! ORANGEHRM_RO_PASSWORD=Fiqueok_OrangeHRM_RO_2025_StrongPass123! ORANGEHRM_ADMIN_PASSWORD=Fiqueok_OrangeHRM_Admin_2025_StrongPass123! EOF # 3. .env.example para repositório público cp .env .env.example sed -i 's/^[^=]*/# &/' .env.example # 4. .gitignore cat > .gitignore << 'EOF' .env mariadb_data/ config/ EOF`

## 3.2 Deploy docker-compose.yml (30 min)

**Criar `orangehrm_lab/docker-compose.yml`:**

text

`version: '3.8' services:   orangehrm-db:    image: mariadb:11.4    container_name: orangehrm-db    restart: unless-stopped    networks:      - orangehrm_lab_net    environment:      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}      MYSQL_DATABASE: orangehrm      MYSQL_USER: orangehrm      MYSQL_PASSWORD: ${ORANGEHRM_DB_PASSWORD}    ports:      - "3306:3306"  # TEMPORÁRIO LAB - midPoint acessa via VM IP    volumes:      - ./mariadb_data:/var/lib/mysql    healthcheck:      test: ["CMD", "mariadb-admin", "--protocol=tcp", "ping"]      interval: 10s      timeout: 5s      retries: 3   orangehrm-app:    image: orangehrm/orangehrm:latest    container_name: orangehrm-app    restart: unless-stopped    networks:      - orangehrm_lab_net    depends_on:      orangehrm-db:        condition: service_healthy    ports:      - "8081:80"    environment:      DB_HOST: orangehrm-db      DB_PORT: 3306      DB_NAME: orangehrm      DB_USERNAME: orangehrm      DB_PASSWORD: ${ORANGEHRM_DB_PASSWORD}    volumes:      - ./config:/var/www/html/config networks:   orangehrm_lab_net:    driver: bridge    ipam:      config:        - subnet: 172.19.0.0/16`

**Executar Deploy:**

bash

`# Carrega .env automaticamente docker compose up -d # Verificar status docker compose ps docker compose logs orangehrm-db --tail=50 docker compose logs orangehrm-app --tail=50`

## 3.3 Configuração Inicial OrangeHRM (30 min)

1. **Acessar GUI:** `http://xxx.xxx.xxx.xxx:8081`
    
2. **Instalador Web (Wizard):**
    
    text
    
    `Database Configuration: ├── Host: orangehrm-db ├── Port: 3306 ├── Database: orangehrm ├── Username: orangehrm └── Password: [ORANGEHRM_DB_PASSWORD do .env] Admin Account: ├── Username: admin └── Password: [ORANGEHRM_ADMIN_PASSWORD do .env]`
    
3. **Criar conta READ-ONLY para midPoint:**
    

bash

`docker exec -it orangehrm-db mariadb -u root -p${MYSQL_ROOT_PASSWORD} orangehrm`

sql

`-- No MariaDB prompt: CREATE USER 'orangehrm_ro'@'%' IDENTIFIED BY 'Fiqueok_OrangeHRM_RO_2025_StrongPass123!'; GRANT SELECT ON orangehrm.* TO 'orangehrm_ro'@'%'; FLUSH PRIVILEGES; SELECT User, Host FROM mysql.user WHERE User='orangehrm_ro'; EXIT;`

4. **Validar tabela hs_hr_employee:**
    

sql

`USE orangehrm; DESCRIBE hs_hr_employee; SELECT COUNT(*) FROM hs_hr_employee;`

## 3.4 Teste de Conformidade (15 min)

|Teste|Comando/URL|Resultado Esperado|Status|
|---|---|---|---|
|Stack UP|`docker compose ps`|2/2 Running|☐|
|.env carregado|`docker compose config|grep MYSQL_ROOT`|✅ Substituído|
|GUI OrangeHRM|`http://xxx.xxx.xxx.xxx:8081`|Dashboard login|☐|
|DB acessível VM|`nc -zv xxx.xxx.xxx.xxx 3306`|✅ Connected|☐|
|Conta RO|`docker exec -it orangehrm-db mariadb -u orangehrm_ro -p... -e "SELECT 1"`|✅ OK|☐|
|Tabela HR|`docker exec orangehrm-db mariadb -u root -p -e "USE orangehrm; DESCRIBE hs_hr_employee"`|✅ Tabela existe|☐|
|Rede isolada|`docker network ls|grep orangehrm`|✅ orangehrm_lab_net|
|Volumes OK|`ls -la mariadb_data/`|✅ mysql/ criado|☐|

---

## 4. Validação Pós-Deploy

**Checklist de Aceitação:**

-  ✅ OrangeHRM em `http://xxx.xxx.xxx.xxx:8081` (admin login OK)
    
-  ✅ Conta `orangehrm_ro` com SELECT no banco
    
-  ✅ Tabela `hs_hr_employee` existe (mesmo vazia)
    
-  ✅ Logs sem erros (`docker compose logs`)
    
-  ✅ `.env` criado e `.gitignore` ativo
    
-  ✅ Documentação KB atualizada (este GMUD)
    
-  ✅ ARQ003 seção 3.1.2 validada
    

---

## 5. Rollback (Emergência)

bash

`cd /home/paulo/iga-lab/orangehrm_lab docker compose down -v rm -rf mariadb_data config/ docker system prune -f  # Limpa imagens órfãs`

---

## 6. Riscos e Mitigações

|Risco|Probabilidade|Impacto|Mitigação|
|---|---|---|---|
|Conflito porta 8081|Baixa|Médio|`netstat -tlnp|
|Falha MariaDB init|Média|Alto|Volumes backup, `docker compose restart`|
|Senha .env incorreta|Baixa|Alto|Validar com `docker compose config`|
|Imagem orangehrm indisponível|Baixa|Alto|Pin: `orangehrm/orangehrm:5.0.5`|

---

## 7. Configuração para GMUD-010 (Preview)

**Resource midPoint (DatabaseTable) usará:**

text

`Host: xxx.xxx.xxx.xxx Port: 3306 Database: orangehrm Username: orangehrm_ro Password: Fiqueok_OrangeHRM_RO_2025_StrongPass123! Table: hs_hr_employee`

---

## 8. Referências

- **ARQ003** - Arquitetura de Referência – Infraestrutura de Governança de Identidades Fiqueok [canvas]
    
- **GMUD-008** - Implementação Stack midPoint 4.10[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/0fe05a0b-1e03-4eac-9d50-15cdc4340106/paste.txt)​
    
- OrangeHRM Docker: [https://hub.docker.com/r/orangehrm/orangehrm](https://hub.docker.com/r/orangehrm/orangehrm)[](https://www.orangehrm.com/en/open-source)​
    
- MariaDB Docker: [https://hub.docker.com/_/mariadb](https://hub.docker.com/_/mariadb)[](https://docs.evolveum.com/midpoint/devel/design/deployment-methodology/solution/)​
    
- Docker Compose .env: [https://docs.docker.com/compose/env-file/](https://docs.docker.com/compose/env-file/)[](https://docs.evolveum.com/midpoint/devel/design/deployment-methodology/solution/)​
    

---

**Aprovação para Execução:** Paulo (GRC/IAM Lead)  
**Data de Início:** 24/12/2025 15:24  
**Data de Conclusão:** ☐ DD/MM/2025  
**Status Final:** ☐ **Sucesso** / ☐ Falha / ☐ Parcial
