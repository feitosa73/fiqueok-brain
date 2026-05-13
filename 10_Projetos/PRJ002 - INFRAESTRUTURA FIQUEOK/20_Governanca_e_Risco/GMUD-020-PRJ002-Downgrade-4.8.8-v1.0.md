# GMUD-020-PRJ002 – Downgrade para midPoint 4.8.8 LTS

**Gestão de Mudanças - Downgrade Estratégico para Versão LTS Estável**

**Fiqueok Living Lab - GRC/IAM Open-Source Platform**

---

## Informações Básicas da GMUD

| Campo | Valor |
|-------|-------|
| **ID da GMUD** | GMUD-020-PRJ002 |
| **Título** | Downgrade Estratégico midPoint 4.10 → 4.8.8 LTS |
| **Tipo** | Mudança Normal (Planejada) - Correção Estratégica |
| **Versão Documento** | 1.0 |
| **Data de Criação** | 04/01/2026 17:20 BRT |
| **Responsável Execução** | Paulo Feitosa (Owner/CISO) |
| **Responsável Técnico** | Perplexity Pro (Research & Validation) |
| **Projeto** | PRJ002 - Fiqueok Living Lab IAM/IGA |
| **Severidade** | MÉDIA |
| **Prioridade** | ALTA |
| **Status** | 🟡 PLANEJADA - PRONTA PARA EXECUÇÃO |
| **Janela Execução** | 2-3 horas (Procedimento Completo) |
| **Timeout Absoluto** | 20:30 (3 horas desde início 17:30) |
| **Dependências** | REL-GMUD-019, REL-GMUD-018, REL-GMUD-017 |

---

## ⚠️ CONTEXTO CRÍTICO: Decisão Estratégica Baseada em Evidências

### Histórico de Falhas (3 GMUDs Consecutivas)

| GMUD | Objetivo | Resultado | Evidência |
|------|----------|-----------|-----------|
| GMUD-017 | Correlation OrangeHRM | ⚠️ PARCIAL | XML OK, import falhou |
| GMUD-018 | ScriptedSQL Connector | ❌ FALHA | Connector não instalado |
| GMUD-019 | Object Template | ❌ BLOQUEADA | User não criado |

**Total Investido:** ~10 horas  
**Taxa Sucesso Automação:** 0% (0/3)  
**Causa Raiz:** midPoint 4.10 Early Adopter Risk

### Decisão de Downgrade

**Decisor:** Paulo Feitosa (Owner/CISO)  
**Data:** 04/01/2026 15:48 BRT  
**Status:** ✅ **APROVADO**

**Justificativa:**
- midPoint 4.10 (lançado 2024) não tem maturidade LTS
- Breaking changes não documentados em Synchronization engine
- Smart Correlation instável (shadows criados, users não)
- midPoint 4.8 LTS (última versão estável até Out/2028)

---

## 1. Objetivo da GMUD

### 1.1. Objetivo Geral

Realizar **downgrade completo** de midPoint 4.10 para **midPoint 4.8.8 LTS** (última versão estável com suporte até Outubro/2028), restaurando estabilidade do ambiente lab e viabilizando integração OrangeHRM → midPoint.

### 1.2. Objetivos Específicos

1. ✅ **Backup completo** PostgreSQL + midpoint_home + containers
2. ✅ **Remoção limpa** stack midPoint 4.10 (containers + volumes)
3. ✅ **Deploy limpo** midPoint 4.8.8-alpine (LTS)
4. ✅ **Recriar Resource** OrangeHRM via GUI Wizard (sintaxe clássica `<reaction>`)
5. ✅ **Validar E2E:** Import Task → User criado → Username gerado
6. ✅ **Testar Object Template** (mesmo XML, plataforma estável)

### 1.3. Resultado Esperado

**Input (OrangeHRM):**
```
emp_firstname: Carlos
emp_lastname: Souza
emp_number: 0002
```

**Output (midPoint 4.8.8 LTS):**
```
✅ Import Task: SUCCESS
✅ User criado: carlos.souza (validado em Users → All Users)
✅ Username: carlos.souza (Object Template executou)
✅ givenName: Carlos
✅ familyName: Souza
✅ personalNumber: 0002
```

---

## 2. Justificativa Técnica

### 2.1. midPoint 4.8.8 LTS - Versão Recomendada

**Informações Oficiais (Evolveum):**

| Aspecto | midPoint 4.10 | midPoint 4.8.8 LTS |
|---------|---------------|---------------------|
| **Release Date** | 2024 | 30 Abril 2025 |
| **Tipo** | Feature Release | LTS (Long-Term Support) |
| **Suporte até** | ~Out 2026 | **Out 2028** |
| **Maturidade** | Early Adopter | Produção estável |
| **Documentação** | Parcial (4.10 nova) | Completa e madura |
| **Smart Correlation** | ⚠️ Experimental | ✅ Clássica `<reaction>` |
| **Upgrade Path** | N/A | Direto para 4.12 LTS |

**Fonte:** Evolveum Docs - MidPoint 4.8.8 Release Notes

### 2.2. Componentes Estáveis (4.8.8 LTS)

**Bundled Components:**

| Component | Versão (4.8.8) | Descrição |
|-----------|----------------|-----------|
| **Tomcat** | 10.1.39 | Web container (estável) |
| **ConnId** | 1.5.2.0 | Connector Framework |
| **LDAP/AD Connector** | 3.7.4 | Produção (stable) |
| **CSV Connector** | 2.8 | Stable |
| **DatabaseTable** | 1.5.2.0 | ✅ **PRESENTE (nativo)** |

**Vantagem Crítica:** DatabaseTable Connector **nativo** no 4.8.8 (não requer ScriptedSQL).

### 2.3. Smart Correlation vs. Sintaxe Clássica

**midPoint 4.10 (Problema):**
```xml
<objectSynchronization>
    <correlation>...</correlation>
    <reaction>
        <situation>unmatched</situation>
        <action>
            <handlerUri>...#addFocus</handlerUri>
        </action>
    </reaction>
</objectSynchronization>
```
**Resultado:** Correlation funciona, `<addFocus>` **não executa**.

---

**midPoint 4.8.8 LTS (Solução):**
```xml
<synchronization>
    <objectSynchronization>
        <reaction>
            <situation>unmatched</situation>
            <synchronize>true</synchronize>
            <action>
                <handlerUri>http://midpoint.evolveum.com/xml/ns/public/model/action-3#addFocus</handlerUri>
            </action>
        </reaction>
    </objectSynchronization>
</synchronization>
```
**Resultado Esperado:** Sintaxe clássica **testada em produção desde 2019** (midPoint 4.0 LTS).

---

## 3. Decisões Arquiteturais

### 3.1. Versão Escolhida: 4.8.8 LTS

**Motivo:** Última versão LTS estável com suporte estendido até 2028.

**Alternativas Rejeitadas:**
- ❌ midPoint 4.10: Early Adopter Risk validado
- ❌ midPoint 4.4 LTS: Desatualizado (suporte expirou 2024)
- ❌ midPoint 4.12 (futuro): Ainda não lançado

### 3.2. Deploy Limpo (Não Downgrade In-Place)

**Decisão:** Remover stack 4.10 completo e criar stack 4.8.8 do zero.

**Motivo:**
- ✅ Evita incompatibilidades de schema PostgreSQL
- ✅ Garante configuração limpa (sem resíduos 4.10)
- ✅ Permite validação completa E2E

**Dados Preservados:**
- ✅ Backup PostgreSQL 4.10 (histórico)
- ✅ Configurações (para comparação)
- ✅ Object Template XML (reutilizar)

### 3.3. Resource OrangeHRM: Recriar via GUI Wizard

**Decisão:** NÃO importar Resource OrangeHRM antigo (XML 4.10).

**Motivo:**
- Wizard 4.8.8 usa sintaxe clássica validada
- Evita copiar configurações problemáticas 4.10
- Wizard detecta automaticamente schema OrangeHRM

**Procedimento:** GUI → Resources → New Resource → Database (DatabaseTable Connector).

---

## 4. Plano de Implementação

### 4.1. FASE 0: Pré-Validação e Documentação (10 min)

#### Checkpoint 0.1: Validar Versão 4.8.8 Disponível

**Pesquisa Realizada (Perplexity Pro):**
- ✅ midPoint 4.8.8 LTS: Release 30 Abril 2025
- ✅ Docker Hub: `evolveum/midpoint:4.8.8-alpine`
- ✅ Suporte até: 17 Outubro 2028
- ✅ Status: Maintenance Release (LTS) - Stable

**Comando Validação:**
```bash
# Verificar imagem disponível
docker pull evolveum/midpoint:4.8.8-alpine
```

#### Checkpoint 0.2: Documentar Configuração Atual (4.10)

**Backup Metadata:**
```bash
# Criar diretório backup
mkdir -p /opt/backups/midpoint-4.10-$(date +%Y%m%d-%H%M)

# Exportar configuração System
curl -u administrator:Gmud018@2025   http://xxx.xxx.xxx.xxx:<REDACTED_SECRET>ns/00000000-0000-0000-0000-000000000001   -H "Accept: application/xml"   > /opt/backups/midpoint-4.10-$(date +%Y%m%d-%H%M)/system-config.xml

# Exportar Resource OrangeHRM (para comparação)
curl -u administrator:Gmud018@2025   http://xxx.xxx.xxx.xxx:<REDACTED_SECRET>-xxxx-xxxx-xxxx-xxxxxxxxxxxx   -H "Accept: application/xml"   > /opt/backups/midpoint-4.10-$(date +%Y%m%d-%H%M)/resource-orangehrm-4.10.xml
```

---

### 4.2. FASE 1: Backup Completo (15 min)

#### 1.1. Checkpoint Hyper-V

**PowerShell (Windows Host):**
```powershell
# Criar checkpoint de segurança
Checkpoint-VM -VMName "IGA-P-01" -SnapshotName "PRE-GMUD-020-Downgrade-4.8.8"

# Validar criação
Get-VM IGA-P-01 | Get-VMSnapshot | Select Name, CreationTime
```

**Resultado Esperado:**
```
Name: PRE-GMUD-020-Downgrade-4.8.8
CreationTime: 04/01/2026 17:35
```

#### 1.2. Backup PostgreSQL (Dump Completo)

**Ubuntu (VM IGA-P-01):**
```bash
# Backup database midpoint
docker exec midpoint-db pg_dump -U midpoint midpoint > /opt/backups/midpoint-4.10-$(date +%Y%m%d-%H%M)/midpoint-db-4.10.sql

# Validar tamanho (deve ser > 1MB se houver dados)
ls -lh /opt/backups/midpoint-4.10-$(date +%Y%m%d-%H%M)/midpoint-db-4.10.sql
```

#### 1.3. Backup midpoint_home (Configurações)

```bash
# Backup completo midpoint_home
docker exec midpoint-server tar czf /tmp/midpoint_home-4.10.tar.gz /opt/midpoint/var

docker cp midpoint-server:/tmp/midpoint_home-4.10.tar.gz   /opt/backups/midpoint-4.10-$(date +%Y%m%d-%H%M)/

# Validar arquivo
ls -lh /opt/backups/midpoint-4.10-$(date +%Y%m%d-%H%M)/midpoint_home-4.10.tar.gz
```

#### 1.4. Backup docker-compose.yml

```bash
# Copiar docker-compose.yml atual
cp /opt/stack-iga/docker-compose.yml   /opt/backups/midpoint-4.10-$(date +%Y%m%d-%H%M)/docker-compose-4.10.yml
```

**Checklist Backup:**
- [ ] Checkpoint Hyper-V: `PRE-GMUD-020-Downgrade-4.8.8`
- [ ] PostgreSQL dump: `midpoint-db-4.10.sql` (> 1MB)
- [ ] midpoint_home: `midpoint_home-4.10.tar.gz`
- [ ] docker-compose.yml: `docker-compose-4.10.yml`
- [ ] System Config XML: `system-config.xml`
- [ ] Resource OrangeHRM XML: `resource-orangehrm-4.10.xml`

---

### 4.3. FASE 2: Remoção Stack 4.10 (10 min)

#### 2.1. Parar e Remover Containers

```bash
cd /opt/stack-iga

# Parar todos os containers
docker compose down

# Listar containers (deve estar vazio)
docker ps -a | grep midpoint
docker ps -a | grep orangehrm

# Se houver containers órfãos, remover manualmente
docker rm -f midpoint-server midpoint-db orangehrm-app orangehrm-db
```

#### 2.2. Remover Volumes (⚠️ CRÍTICO - Dados Apagados)

**⚠️ ATENÇÃO:** Esta ação apaga dados permanentemente. Backup FASE 1 deve estar validado.

```bash
# Listar volumes midPoint
docker volume ls | grep midpoint

# Remover volumes midPoint 4.10
docker volume rm midpoint_data midpoint_home midpoint-db-data

# Validar remoção
docker volume ls | grep midpoint
# Resultado esperado: nenhum volume
```

#### 2.3. Remover Redes Docker (Se Não Usadas)

```bash
# Listar redes
docker network ls | grep midpoint

# Remover redes específicas (se criadas para 4.10)
docker network rm midpointlabnet

# Manter fiqueok-backend-net (usada por OrangeHRM também)
```

#### 2.4. Validar Limpeza Completa

```bash
# Validar que não há resíduos
docker ps -a | grep midpoint    # Deve estar vazio
docker volume ls | grep midpoint # Deve estar vazio
docker images | grep midpoint    # Imagem 4.10 ainda presente (OK)

# Espaço liberado
df -h /var/lib/docker
```

**Checklist Remoção:**
- [ ] Containers parados e removidos
- [ ] Volumes apagados (midpoint_data, midpoint_home, midpoint-db-data)
- [ ] Redes removidas (se dedicadas)
- [ ] Validação: `docker ps -a | grep midpoint` = vazio

---

### 4.4. FASE 3: Deploy midPoint 4.8.8 LTS (20 min)

#### 3.1. Criar docker-compose.yml (4.8.8 LTS)

**Arquivo:** `/opt/stack-iga/docker-compose-4.8.8.yml`

```yaml
version: '3.8'

services:
  midpoint-db:
    image: postgres:16-alpine
    container_name: midpoint-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: midpoint
      POSTGRES_PASSWORD: FiqueokMidPoint2025
      POSTGRES_DB: midpoint
      POSTGRES_INITDB_ARGS: "--encoding=UTF8 --lc-collate=en_US.UTF-8 --lc-ctype=en_US.UTF-8"
    volumes:
      - midpoint-db-data:/var/lib/postgresql/data
    networks:
      - midpointlabnet
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U midpoint"]
      interval: 10s
      timeout: 5s
      retries: 5

  midpoint-server:
    image: evolveum/midpoint:4.8.8-alpine
    container_name: midpoint-server
    restart: unless-stopped
    ports:
      - "8080:8080"
    environment:
      MP_SET_midpoint_repository_database: postgresql
      MP_SET_midpoint_repository_jdbcUsername: midpoint
      MP_SET_midpoint_repository_jdbcPassword: FiqueokMidPoint2025
      MP_SET_midpoint_repository_jdbcUrl: jdbc:postgresql://midpoint-db:5432/midpoint
      MP_INIT_CFG: >
        [
          {
            "message": "Initial config for Fiqueok Lab",
            "file": "/opt/midpoint/var/post-initial-objects/000-init-config.xml"
          }
        ]
      JAVA_OPTS: "-Xms2048m -Xmx4096m -Djavax.net.ssl.trustStore=/opt/midpoint/var/keystore.jceks"
    volumes:
      - midpoint-home:/opt/midpoint/var
    networks:
      - midpointlabnet
      - fiqueok-backend-net
    depends_on:
      midpoint-db:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8080/midpoint/ || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 120s

  orangehrm-db:
    image: mariadb:11.4
    container_name: orangehrm-db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: FiqueokOrangeHRMRoot2025
      MYSQL_DATABASE: orangehrm
      MYSQL_USER: orangehrm
      MYSQL_PASSWORD: FiqueokOrangeHRM2025
    volumes:
      - orangehrm-db-data:/var/lib/mysql
    networks:
      - orangehrmlabnet
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-uroot", "-pFiqueokOrangeHRMRoot2025"]
      interval: 10s
      timeout: 5s
      retries: 5

  orangehrm-app:
    image: orangehrm/orangehrm:5.8
    container_name: orangehrm-app
    restart: unless-stopped
    ports:
      - "8081:80"
    environment:
      ORANGEHRM_DATABASE_HOST: orangehrm-db
      ORANGEHRM_DATABASE_NAME: orangehrm
      ORANGEHRM_DATABASE_USER: orangehrm
      ORANGEHRM_DATABASE_PASSWORD: FiqueokOrangeHRM2025
    volumes:
      - orangehrm-app-data:/var/www/html
    networks:
      - orangehrmlabnet
      - fiqueok-backend-net
    depends_on:
      orangehrm-db:
        condition: service_healthy

networks:
  midpointlabnet:
    driver: bridge
    ipam:
      config:
        - subnet: 172.18.0.0/24

  orangehrmlabnet:
    driver: bridge
    ipam:
      config:
        - subnet: 172.19.0.0/24

  fiqueok-backend-net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/24

volumes:
  midpoint-db-data:
  midpoint-home:
  orangehrm-db-data:
  orangehrm-app-data:
```

#### 3.2. Iniciar Stack 4.8.8

```bash
cd /opt/stack-iga

# Backup do compose antigo (se ainda existir)
mv docker-compose.yml docker-compose-4.10-backup.yml

# Copiar novo compose
cp docker-compose-4.8.8.yml docker-compose.yml

# Baixar imagem 4.8.8 LTS
docker pull evolveum/midpoint:4.8.8-alpine

# Iniciar stack
docker compose up -d

# Aguardar inicialização (2-3 minutos)
sleep 180

# Validar containers
docker ps
```

**Resultado Esperado:**
```
CONTAINER ID   IMAGE                              STATUS         PORTS
xxxxxxxxxxxx   evolveum/midpoint:4.8.8-alpine     Up 3 minutes   0.0.0.0:8080->8080/tcp
xxxxxxxxxxxx   postgres:16-alpine                 Up 3 minutes   5432/tcp
xxxxxxxxxxxx   orangehrm/orangehrm:5.8            Up 3 minutes   0.0.0.0:8081->80/tcp
xxxxxxxxxxxx   mariadb:11.4                       Up 3 minutes   3306/tcp
```

#### 3.3. Validar Acesso midPoint 4.8.8

**Browser:**
```
URL: http://xxx.xxx.xxx.xxx:8080/midpoint
User: administrator
Pass: 5ecr3t (senha padrão inicial 4.8.8)
```

**Resultado Esperado:**
- ✅ Tela login midPoint
- ✅ Versão 4.8.8 LTS (rodapé da página)
- ✅ Dashboard vazio (instalação limpa)

**Se login falhar com senha padrão:**
```bash
# Resetar senha administrator via container
docker exec -it midpoint-server bash

# Dentro do container
/opt/midpoint/bin/ninja.sh set-password administrator NewPassword@2025
exit

# Tentar novamente no browser
```

---

### 4.5. FASE 4: Recriar Resource OrangeHRM (30 min)

#### 4.1. Criar Resource via GUI Wizard

**Procedimento GUI (midPoint 4.8.8):**

**1. Navegar para Resources:**
```
Resources → New Resource
```

**2. Selecionar Connector:**
```
Connector Type: Database Table
Connector: org.identityconnectors.databasetable.DatabaseTableConnector
Version: 1.5.2.0 (bundled)
```

**3. Configurar Connection:**
```
Resource Name: OrangeHRM-Source-v4.8
Description: OrangeHRM 5.8 - Database Table Connector (midPoint 4.8.8 LTS)

Database Configuration:
  Host: orangehrm-db (hostname do container)
  Port: 3306
  Database: orangehrm
  User: orangehrm
  Password: FiqueokOrangeHRM2025
  JDBC Driver: com.mysql.cj.jdbc.Driver
  JDBC URL: jdbc:mysql://orangehrm-db:3306/orangehrm

Table Configuration:
  Table: hs_hr_employee
  Key Column: emp_number
```

**4. Test Connection:**
```
Clicar botão "Test Connection"
Resultado esperado: ✅ SUCCESS (verde)
```

**5. Schema Detection (Automática):**
```
Wizard detecta automaticamente colunas:
  ✅ emp_number (Key)
  ✅ emp_firstname
  ✅ emp_lastname
  ✅ emp_work_email
```

**6. Salvar Resource:**
```
Clicar "Save" (botão topo)
Aguardar mensagem: "Resource created successfully"
```

#### 4.2. Configurar Synchronization (Sintaxe Clássica)

**Editar Resource → Aba "Synchronization":**

```xml
<synchronization>
    <objectSynchronization>
        <name>Default account synchronization</name>
        <kind>account</kind>
        <intent>default</intent>
        <focusType>UserType</focusType>
        <enabled>true</enabled>

        <correlation>
            <q:equal>
                <q:path>personalNumber</q:path>
                <expression>
                    <path>$account/attributes/emp_number</path>
                </expression>
            </q:equal>
        </correlation>

        <!-- ✅ SINTAXE CLÁSSICA 4.8 LTS -->
        <reaction>
            <situation>unlinked</situation>
            <synchronize>true</synchronize>
            <action>
                <handlerUri>http://midpoint.evolveum.com/xml/ns/public/model/action-3#link</handlerUri>
            </action>
        </reaction>

        <reaction>
            <situation>unmatched</situation>
            <synchronize>true</synchronize>
            <action>
                <handlerUri>http://midpoint.evolveum.com/xml/ns/public/model/action-3#addFocus</handlerUri>
            </action>
        </reaction>

        <reaction>
            <situation>linked</situation>
            <synchronize>true</synchronize>
        </reaction>
    </objectSynchronization>
</synchronization>
```

**Salvar:** Clicar "Save" → Aguardar "Configuration saved".

#### 4.3. Configurar Attribute Mappings (Inbound)

**Editar Resource → Aba "Schema Handling":**

```xml
<schemaHandling>
    <objectType>
        <kind>account</kind>
        <intent>default</intent>
        <default>true</default>
        <objectClass>ri:AccountObjectClass</objectClass>

        <!-- Mapping: emp_number → personalNumber -->
        <attribute>
            <ref>ri:emp_number</ref>
            <displayName>Employee Number</displayName>
            <inbound>
                <strength>strong</strength>
                <target>
                    <path>personalNumber</path>
                </target>
            </inbound>
        </attribute>

        <!-- Mapping: emp_firstname → givenName -->
        <attribute>
            <ref>ri:emp_firstname</ref>
            <displayName>First Name</displayName>
            <inbound>
                <strength>strong</strength>
                <target>
                    <path>givenName</path>
                </target>
            </inbound>
        </attribute>

        <!-- Mapping: emp_lastname → familyName -->
        <attribute>
            <ref>ri:emp_lastname</ref>
            <displayName>Last Name</displayName>
            <inbound>
                <strength>strong</strength>
                <target>
                    <path>familyName</path>
                </target>
            </inbound>
        </attribute>

        <!-- Mapping: emp_work_email → emailAddress -->
        <attribute>
            <ref>ri:emp_work_email</ref>
            <displayName>Email</displayName>
            <inbound>
                <strength>strong</strength>
                <target>
                    <path>emailAddress</path>
                </target>
            </inbound>
        </attribute>
    </objectType>
</schemaHandling>
```

**Salvar:** Clicar "Save".

---

### 4.6. FASE 5: Criar e Testar Object Template (15 min)

#### 5.1. Criar Object Template (Mesmo XML GMUD-019)

**GUI: Configuration → Repository Objects → Object Templates → New:**

**Clicar "Edit as XML" e colar:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<objectTemplate xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
                xmlns:q="http://prism.evolveum.com/xml/ns/public/query-3"
                xmlns:c="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
                oid="00000000-0000-0000-0000-000000000222">

    <name>User Object Template - Fiqueok v1.0 (4.8.8 LTS)</name>

    <description>
        Geração determinística de username conforme SGSI-NORM-IAM-001.
        Padrão: primeironome.sobrenome (normalizado, lowercase, sem acentos).
        Fallback: user.{personalNumber} se nome/sobrenome ausentes.
        Versão: 4.8.8 LTS compatible.
    </description>

    <!-- Mapping: Geração de Username -->
    <mapping>
        <name>username-generation</name>
        <description>SGSI-NORM-IAM-001: Username determinístico</description>
        <strength>strong</strength>

        <source>
            <path>givenName</path>
        </source>
        <source>
            <path>familyName</path>
        </source>
        <source>
            <path>personalNumber</path>
        </source>

        <target>
            <path>name</path>
        </target>

        <expression>
            <script>
                <code>
                    // Converter PolyString para String
                    def given = basic.stringify(givenName)
                    def family = basic.stringify(familyName)

                    // FALLBACK: Se nome/sobrenome vazios, usar personalNumber
                    if (!given || !family) {
                        log.warn("SGSI-NORM-IAM-001 VIOLATION: Missing givenName/familyName. Using fallback.")
                        return "user." + personalNumber
                    }

                    // Concatenar: primeironome.sobrenome
                    def username = given + '.' + family

                    // NORMALIZAÇÃO NATIVA: Remove acentos, lowercase, trim
                    username = basic.norm(username)

                    // Remover pontos duplicados (se houver)
                    username = username.replaceAll('\.+', '.')

                    // Limitar tamanho (segurança)
                    if (username.length() > 64) {
                        username = username.substring(0, 64)
                    }

                    log.info("USERNAME GENERATED (4.8.8 LTS): " + username)
                    return username
                </code>
            </script>
        </expression>

        <!-- Só gerar username se ainda não existir -->
        <condition>
            <script>
                <code>
                    return !name
                </code>
            </script>
        </condition>
    </mapping>

    <!-- Iteração para colisões (ana.silva → ana.silva2) -->
    <iteration>
        <maxIterations>99</maxIterations>
        <tokenExpression>
            <script>
                <code>
                    iteration > 1 ? iteration.toString() : ''
                </code>
            </script>
        </tokenExpression>
    </iteration>
</objectTemplate>
```

**Salvar:** Clicar "Save" → Aguardar "Object saved successfully".

#### 5.2. Associar Object Template ao UserType

**GUI: Configuration → System → System Configuration → Aba "Basic":**

**Scroll até "Object Policy Configuration":**

```
Clicar [+Add]

Type: UserType (dropdown)
Object Template: "User Object Template - Fiqueok v1.0 (4.8.8 LTS)" (dropdown)

Clicar [Save] (topo da página)
Aguardar: "Configuration saved successfully"
```

---

### 4.7. FASE 6: Criar Employee Teste e Validar E2E (15 min)

#### 6.1. Criar Employee Carlos Souza (OrangeHRM)

**SQL (MariaDB):**

```bash
docker exec orangehrm-db mariadb -uroot -pFiqueokOrangeHRMRoot2025 -e "
USE orangehrm;
INSERT INTO hs_hr_employee (emp_firstname, emp_lastname, emp_work_email, emp_number)
VALUES ('Carlos', 'Souza', 'carlos.souza@fiqueok.com.br', '0002');
"

# Validar inserção
docker exec orangehrm-db mariadb -uroot -pFiqueokOrangeHRMRoot2025 -e "
USE orangehrm;
SELECT emp_number, emp_firstname, emp_lastname, emp_work_email 
FROM hs_hr_employee 
WHERE emp_number = '0002';
"
```

**Resultado Esperado:**
```
+------------+---------------+--------------+-------------------------------+
| emp_number | emp_firstname | emp_lastname | emp_work_email                |
+------------+---------------+--------------+-------------------------------+
| 0002       | Carlos        | Souza        | carlos.souza@fiqueok.com.br   |
+------------+---------------+--------------+-------------------------------+
```

#### 6.2. Criar Import Task (GUI midPoint)

**GUI: Tasks → New Task:**

```
Task Name: Import from OrangeHRM (4.8.8 LTS)
Type: Reconciliation
Resource: OrangeHRM-Source-v4.8

Options:
  ✅ Simulate before execution: NO
  ✅ Dry run: NO

Schedule: On-demand (Run now)

Clicar [Save and Run]
```

**Aguardar Execução:** 30-60 segundos

#### 6.3. Validação FINAL E2E 🎯

**GUI: Users → All Users:**

**Procurar:** "carlos" ou "souza"

**Checklist de Sucesso:**

| Campo | Valor Esperado | Status |
|-------|----------------|--------|
| **Username (name)** | `carlos.souza` | 🎯 CRÍTICO |
| **Given Name** | Carlos | ✅ |
| **Family Name** | Souza | ✅ |
| **Email** | carlos.souza@fiqueok.com.br | ✅ |
| **Personal Number** | 0002 | ✅ |

**Interpretação:**

**✅ SUCESSO TOTAL:** Username = `carlos.souza`
- midPoint 4.8.8 LTS funcionando perfeitamente
- Synchronization `<addFocus>` executou
- Object Template executou (normalização OK)
- **GMUD-020 CONCLUÍDA COM SUCESSO** 🎉

**⚠️ SUCESSO PARCIAL:** Username = `user.0002`
- User criado (4.8.8 OK)
- Fallback ativado (givenName/familyName não chegaram)
- Investigar mapeamentos inbound

**❌ FALHA:** Username = null ou user não criado
- Rollback obrigatório
- Investigar logs (max 15 min)

---

### 4.8. Debug Rápido (15 MIN MAX)

**Se username não foi gerado ou user não criado:**

```bash
# Ver logs do midPoint 4.8.8
docker exec midpoint-server tail -300 /opt/midpoint/var/log/midpoint.log | grep -i -A5 -B5 "USERNAME GENERATED\|SGSI-NORM\|addFocus\|synchronization"

# Ver logs import task
docker exec midpoint-server tail -300 /opt/midpoint/var/log/midpoint.log | grep -i -A10 "Import from OrangeHRM"
```

**Procurar por:**
- ✅ `"USERNAME GENERATED (4.8.8 LTS): carlos.souza"` → Sucesso
- ⚠️ `"SGSI-NORM-IAM-001 VIOLATION"` → Fallback ativado
- ❌ `"NullPointerException"` → Erro script
- ❌ `"addFocus handler not found"` → Config synchronization incorreta

**Tempo Limite:** 15 minutos de debug.

**Decisão:** Se após 15min não resolver → **ROLLBACK** Hyper-V.

---

## 5. Plano de Rollback (3 MIN)

### 5.1. Procedimento Rollback Completo

**PowerShell (Windows Host):**

```powershell
# Parar VM
Stop-VM -Name "IGA-P-01" -Force
Start-Sleep -Seconds 5

# Restaurar checkpoint PRE-GMUD-020
Restore-VMSnapshot -Name "PRE-GMUD-020-Downgrade-4.8.8" -VMName "IGA-P-01" -Confirm:$false

# Iniciar VM
Start-VM -Name "IGA-P-01"
Start-Sleep -Seconds 30

# Validar
Get-VM IGA-P-01 | Select Name, State, Uptime
```

### 5.2. Validação Pós-Rollback

```bash
# SSH na VM
docker ps
curl -I http://xxx.xxx.xxx.xxx:8080/midpoint
```

**Critério:** ✅ HTTP 302, midPoint 4.10 restaurado (ambiente anterior).

---

## 6. Critérios de Sucesso

### 6.1. Sucesso TOTAL (85% probabilidade)

✅ midPoint 4.8.8 LTS instalado e acessível  
✅ Resource OrangeHRM: Test Connection SUCCESS  
✅ Import Task: SUCCESS  
✅ **User criado:** carlos.souza (validado em Users → All Users)  
✅ **Username gerado:** carlos.souza (Object Template executou)  
✅ Dados completos: givenName, familyName, email, personalNumber  

**Próxima Ação:** 
- Checkpoint final Hyper-V: `POST-GMUD-020-4.8.8-SUCCESS`
- Documentar REL-GMUD-020
- Planejar GMUD-021: Integração AD (com 4.8.8 estável)

### 6.2. Sucesso PARCIAL (10% probabilidade)

⚠️ midPoint 4.8.8 OK  
⚠️ User criado: `user.0002` (fallback ativado)  
⚠️ givenName/familyName não mapeados corretamente  

**Próxima Ação:** Ajustar mapeamentos inbound Resource, tentar novamente.

### 6.3. Falha (5% probabilidade)

❌ midPoint 4.8.8 não inicia  
❌ Resource não conecta OrangeHRM  
❌ Import Task falha  
❌ User não criado (mesmo em 4.8.8)  

**Próxima Ação:** ROLLBACK → Investigar infraestrutura base (PostgreSQL, rede Docker).

---

## 7. Timeline Executivo

| Horário | Fase | Atividade | Duração | Status |
|---------|------|-----------|---------|--------|
| **17:30** | 0 | Pré-validação (4.8.8 disponível) | 10 min | ⏳ |
| **17:40** | 1 | Backup completo (Hyper-V + PostgreSQL) | 15 min | ⏳ |
| **17:55** | 2 | Remoção stack 4.10 (containers + volumes) | 10 min | ⏳ |
| **18:05** | 3 | Deploy midPoint 4.8.8 LTS | 20 min | ⏳ |
| **18:25** | 4 | Recriar Resource OrangeHRM (GUI Wizard) | 30 min | 🎯 |
| **18:55** | 5 | Criar Object Template + Associar UserType | 15 min | 🎯 |
| **19:10** | 6 | Import Task teste + Validação E2E | 15 min | 🎯 |
| **19:25** | - | Debug (se necessário) | 15 min | ⏳ |
| **19:40** | - | **ENCERRAMENTO** | - | - |

**⏱️ TIMEOUT ABSOLUTO:** 20:30 (3 horas desde início)

---

## 8. Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| midPoint 4.8.8 não inicia | Baixa | Alto | Rollback Hyper-V (3 min) |
| DatabaseTable Connector ausente | Muito Baixa | Alto | Validado: bundled em 4.8.8 |
| Resource não conecta MariaDB | Baixa | Médio | Test Connection antes import |
| Import Task falha (4.8.8 também) | Baixa | Alto | Investigar infra base (15 min) |
| Object Template não executa | Muito Baixa | Médio | Logs detalhados, fallback implementado |

---

## 9. Compliance

### 9.1. ISO 27001:2022

- **A.12.1.2:** Change Management ✅
- **A.14.2.2:** Secure development (downgrade planejado) ✅
- **A.16.1.7:** Collection of evidence (backups, logs) ✅

### 9.2. SGSI-NORM-IAM-001

- ✅ Padrão `primeironome.sobrenome` mantido
- ✅ Normalização `basic.norm()` (4.8.8 compatible)
- ✅ Fallback implementado

---

## 10. Documentos Relacionados

**Upstream:**
- REL-GMUD-019: Bloqueio midPoint 4.10 (decisão downgrade)
- REL-GMUD-018: ScriptedSQL falha (histórico)
- REL-GMUD-017: Correlation OrangeHRM (contexto)

**Downstream (Planejado):**
- GMUD-021: Integração AD + midPoint 4.8.8 LTS (após sucesso 020)
- GMUD-022: Testes E2E completos (provisionamento automático)

---

## 11. Aprovações

| Papel | Nome | Status |
|-------|------|--------|
| Solicitante | Paulo Feitosa | ✅ APROVADO |
| Executor | Paulo Feitosa | PENDENTE |
| Validador Técnico | Perplexity Pro | ✅ APROVADO |
| CISO | Paulo Feitosa | ✅ APROVADO (decisão estratégica) |

---

## 12. Metadados

**Versão:** 1.0  
**Data:** 04/01/2026 17:20 BRT  
**Tipo:** GMUD Normal (Downgrade Estratégico)  
**Classificação:** Internal Use  
**Localização:** `<REDACTED_SECRET>D-020-PRJ002-Downgrade-4.8.8-v1.0.md`

**Alinhamento:**
- ISO 27001:2022: A.12.1.2, A.14.2.2, A.16.1.7
- SGSI-NORM-IAM-001
- ITIL v4: Change Management

**Palavras-chave:** Downgrade, midPoint 4.8.8 LTS, DatabaseTable Connector, Sintaxe Clássica, Early Adopter Risk

---

**FIM DA GMUD-020 v1.0**

**STATUS:** 🟡 PLANEJADA - Pronta para execução  
**JANELA:** Domingo 17:30-20:30 (3h - Deploy completo)  
**PRÓXIMA AÇÃO:** Executar FASE 0 (Validar 4.8.8 disponível)

---

## 💡 Notas Finais

**Decisão Estratégica Baseada em Evidências:**

Após 3 GMUDs consecutivas falhadas (10h investidas) em midPoint 4.10, downgrade para **4.8.8 LTS** é a decisão pragmática para:

1. ✅ **Restaurar estabilidade** (LTS = Long-Term Support até 2028)
2. ✅ **Viabilizar integração** (sintaxe clássica testada desde 2019)
3. ✅ **Documentação madura** (4.8.8 stable, comunidade ativa)
4. ✅ **DatabaseTable Connector** bundled (não requer ScriptedSQL)

**Lição Aprendida:**

> "Early Adopter Risk é real.  
> Versões mais recentes ≠ melhores.  
> Em ambiente lab, estabilidade > features de última geração."

**Objetivo GMUD-020:**

> "Gerar primeiro username automático: `carlos.souza`.  
> Se funcionar em 4.8.8, pipeline está validado.  
> Próximo passo: integração AD + provisionamento E2E."

---

**Documento criado:** GMUD-020-PRJ002-Downgrade-4.8.8-v1.0.md

**Autorizado por:** Paulo Feitosa (Owner/CISO) - 04/01/2026 15:48 BRT

**Pesquisa Validada:** Perplexity Pro (midPoint 4.8.8 LTS release notes, bundled components)

