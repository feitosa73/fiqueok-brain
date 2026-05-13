## **TAP - Technical Assessment Plan**



---

|Campo|Valor|
|---|---|
|**Projeto**|PRJ025|
|**Título**|Integração midPoint 4.10 com Keycloak para SSO e Provisionamento|
|**Data**|Maio/2026|
|**Versão**|1.0|
|**Status**|📝 Em Planejamento|
|**Responsável**|Paulo Feitosa Lima|
|**Pré-requisito**|PRJ022-A (CSV → midPoint → AD) funcionando|
|**Complexidade**|Baixa (conector maduro, documentação extensa)|
|**Tempo Estimado**|2 horas|

---

## 1. Objetivo

Estabelecer integração entre o **midPoint 4.10** e o **Keycloak** para:

1. Provisionamento automático de usuários no Keycloak
    
2. Gerenciamento de grupos e roles
    
3. SSO (Single Sign-On) para aplicações web
    
4. Sincronização de identidades (midPoint como fonte autoritativa)
    

---

## 2. Por que Keycloak?

|Benefício|Descrição|
|---|---|
|**Open Source**|Sem custo de licença, comunidade ativa|
|**Conector maduro**|ScriptedREST com exemplos disponíveis|
|**API REST completa**|`/admin/realms/{realm}/users` bem documentada|
|**SSO nativo**|OIDC, SAML, Social Login|
|**Grupos e Roles**|Gerenciamento centralizado de permissões|
|**Baixa complexidade**|Comparado a AWS/GCP, muito mais simples|

---

## 3. Arquitetura Proposta

text

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                    PRJ025 - midPoint ↔ Keycloak para SSO e Provisionamento           │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  ┌─────────────┐     ┌─────────────────────────────────────────────────────────────┐│
│  │  Shadow API │     │                        midPoint 4.10                        ││
│  │  (PRJ008)   │────▶│  ┌───────────────────────────────────────────────────────┐  ││
│  └─────────────┘     │  │              Recurso CSV (PRJ022-A)                   │  ││
│                      │  │  employee_id, first_name, last_name, email...         │  ││
│                      │  └─────────────────────────┬─────────────────────────────┘  ││
│                      │                            │                                ││
│                      │                            ▼                                ││
│                      │  ┌───────────────────────────────────────────────────────┐  ││
│                      │  │          Resource Keycloak (ScriptedREST)             │  ││
│                      │  │  ┌─────────────────────────────────────────────────┐  │  ││
│                      │  │  │ SearchScript.groovy (GET /users)               │  │  ││
│                      │  │  │ CreateScript.groovy (POST /users)              │  │  ││
│                      │  │  │ UpdateScript.groovy (PUT /users/{id})          │  │  ││
│                      │  │  │ GroupScript.groovy (group assignments)         │  │  ││
│                      │  │  └─────────────────────────────────────────────────┘  │  ││
│                      │  └─────────────────────────┬─────────────────────────────┘  ││
│                      │                            │                                ││
│                      │                            │ HTTPS + Bearer Token          ││
│                      │                            ▼                                ││
│                      │  ┌───────────────────────────────────────────────────────┐  ││
│                      │  │                      Keycloak                          │  ││
│                      │  │  ┌─────────────────────────────────────────────────┐  │  ││
│                      │  │  │ Realm: fiqueok                                  │  │  ││
│                      │  │  │ Users: 102 usuários criados                     │  │  ││
│                      │  │  │ Groups: employees, finance, hr, it              │  │  ││
│                      │  │  │ Clients: portal, app, api                       │  │  ││
│                      │  │  └─────────────────────────────────────────────────┘  │  ││
│                      │  └───────────────────────────────────────────────────────┘  ││
│                      │                            │                                ││
│                      │                            │ OIDC / SAML                    ││
│                      │                            ▼                                ││
│                      │  ┌───────────────────────────────────────────────────────┐  ││
│                      │  │              Aplicações Web (SSO)                      │  ││
│                      │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │  ││
│                      │  │  │   Portal    │  │    ERP      │  │    CRM      │    │  ││
│                      │  │  └─────────────┘  └─────────────┘  └─────────────┘    │  ││
│                      │  └───────────────────────────────────────────────────────┘  ││
│                      │                                                              ││
│                      └──────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────────────┘

---

## 4. Pré-Requisitos

|#|Requisito|Status|Critério|
|---|---|---|---|
|PR-01|PRJ022-A funcionando (CSV)|✅|103 usuários processados|
|PR-02|Docker Compose no `iga-gf-02`|✅|Já em uso|
|PR-03|Portas disponíveis (8080, 8443)|✅|Keycloak usará 8081 ou 8443|
|PR-04|ScriptedREST Connector disponível|✅|Já presente|
|PR-05|Memória RAM disponível (>2GB)|✅|VM com recursos suficientes|
|PR-06|Acesso à internet para download do container|⚠️|Verificar conectividade|

---

## 5. Configuração do Keycloak

### 5.1. Docker Compose para Keycloak

bash

# [iga-gf-02]$
cat >> /srv/iga-project/docker-compose.yml << 'EOF'
  keycloak:
    image: quay.io/keycloak/keycloak:25.0.6
    container_name: iga-keycloak
    restart: unless-stopped
    environment:
      KC_BOOTSTRAP_ADMIN_USERNAME: admin
      KC_BOOTSTRAP_ADMIN_PASSWORD: 'Keycloak#2026'
      KC_DB: postgres
      KC_DB_URL_HOST: postgres
      KC_DB_URL_DATABASE: keycloak
      KC_DB_USERNAME: keycloak_user
      KC_DB_PASSWORD: 'Keyc10ak#2026'
      KC_HOSTNAME: localhost
      KC_HTTP_ENABLED: true
      KC_PROXY: edge
    ports:
      - "8081:8080"
      - "8443:8443"
    command: start-dev
    depends_on:
      postgres:
        condition: service_healthy
  postgres:
    # Adicionar banco de dados para Keycloak
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: keycloak_user
      POSTGRES_PASSWORD: 'Keyc10ak#2026'

### 5.2. Criar Realm e Clientes

bash

# [iga-gf-02]$
# Aguardar Keycloak iniciar
sleep 60
# Criar realm "fiqueok"
curl -X POST http://localhost:8081/admin/realms \
  -H "Content-Type: application/json" \
  -u admin:'Keycloak#2026' \
  -d '{"realm": "fiqueok", "enabled": true}'
# Criar cliente "midpoint"
curl -X POST http://localhost:8081/admin/realms/fiqueok/clients \
  -H "Content-Type: application/json" \
  -u admin:'Keycloak#2026' \
  -d '{
    "clientId": "midpoint",
    "enabled": true,
    "publicClient": false,
    "serviceAccountsEnabled": true,
    "protocol": "openid-connect"
  }'

### 5.3. Obter Client Secret

bash

# [iga-gf-02]$
# Obter OID do cliente
CLIENT_OID=$(curl -s -X GET "http://localhost:8081/admin/realms/fiqueok/clients" \
  -H "Content-Type: application/json" \
  -u admin:'Keycloak#2026' \
  | jq -r '.[] | select(.clientId=="midpoint") | .id')
# Obter Client Secret
curl -s -X GET "http://localhost:8081/admin/realms/fiqueok/clients/${CLIENT_OID}/client-secret" \
  -H "Content-Type: application/json" \
  -u admin:'Keycloak#2026'

---

## 6. Scripts Groovy para Keycloak

### 6.1. SearchScript.groovy

groovy

// /srv/iga-project/data/midpoint/scripts/keycloak/SearchScript.groovy
import groovy.json.JsonSlurper
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.net.URI
def KEYCLOAK_URL = "http://keycloak:8080/admin/realms/fiqueok/users"
def ACCESS_TOKEN = getAccessToken()
def client = HttpClient.newHttpClient()
def request = HttpRequest.newBuilder()
    .uri(URI.create(KEYCLOAK_URL + "?max=100"))
    .header("Authorization", "Bearer ${ACCESS_TOKEN}")
    .header("Content-Type", "application/json")
    .GET()
    .build()
def response = client.send(request, HttpResponse.BodyHandlers.ofString())
def users = new JsonSlurper().parseText(response.body())
users.each { user ->
    handler([
        userName: user.username,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        enabled: user.enabled
    ])
}
def getAccessToken() {
    def tokenUrl = "http://keycloak:8080/realms/master/protocol/openid-connect/token"
    def body = "client_id=admin-cli&username=admin&password=Keycloak%232026&grant_type=password"
    
    def client = HttpClient.newHttpClient()
    def request = HttpRequest.newBuilder()
        .uri(URI.create(tokenUrl))
        .header("Content-Type", "application/x-www-form-urlencoded")
        .POST(HttpRequest.BodyPublishers.ofString(body))
        .build()
    
    def response = client.send(request, HttpResponse.BodyHandlers.ofString())
    def json = new JsonSlurper().parseText(response.body())
    return json.access_token
}

### 6.2. CreateScript.groovy

groovy

// /srv/iga-project/data/midpoint/scripts/keycloak/CreateScript.groovy
import groovy.json.JsonOutput
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.net.URI
def KEYCLOAK_URL = "http://keycloak:8080/admin/realms/fiqueok/users"
def ACCESS_TOKEN = getAccessToken()  // Mesma função do SearchScript
def userPayload = [
    username: attributes.name,
    email: attributes.email,
    firstName: attributes.givenName,
    lastName: attributes.familyName,
    enabled: true,
    credentials: [
        [
            type: "password",
            value: "Temporary@2026",
            temporary: true
        ]
    ]
]
def client = HttpClient.newHttpClient()
def request = HttpRequest.newBuilder()
    .uri(URI.create(KEYCLOAK_URL))
    .header("Authorization", "Bearer ${ACCESS_TOKEN}")
    .header("Content-Type", "application/json")
    .POST(HttpRequest.BodyPublishers.ofString(JsonOutput.toJson(userPayload)))
    .build()
def response = client.send(request, HttpResponse.BodyHandlers.ofString())
if (response.statusCode() == 201) {
    // Extrair ID do usuário criado do header Location
    def location = response.headers().firstValue("Location").orElse("")
    def userId = location.substring(location.lastIndexOf("/") + 1)
    
    handler([
        userName: attributes.name,
        keycloakId: userId
    ])
} else {
    throw new RuntimeException("Failed to create user: ${response.statusCode()} - ${response.body()}")
}

### 6.3. GroupScript.groovy (para atribuição de grupos)

groovy

// /srv/iga-project/data/midpoint/scripts/keycloak/GroupScript.groovy
import groovy.json.JsonOutput
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.net.URI
def KEYCLOAK_URL = "http://keycloak:8080/admin/realms/fiqueok"
def ACCESS_TOKEN = getAccessToken()
// Mapear grupos do midPoint para grupos do Keycloak
def groupMapping = [
    "employees": "/employees",
    "finance": "/finance",
    "hr": "/hr",
    "it": "/it"
]
def groups = attributes.groups ?: []
groups.each { groupName ->
    def keycloakGroupPath = groupMapping[groupName]
    if (keycloakGroupPath) {
        // Adicionar usuário ao grupo
        def groupId = getGroupId(keycloakGroupPath)
        if (groupId) {
            def assignUrl = "${KEYCLOAK_URL}/users/${attributes.keycloakId}/groups/${groupId}"
            def assignRequest = HttpRequest.newBuilder()
                .uri(URI.create(assignUrl))
                .header("Authorization", "Bearer ${ACCESS_TOKEN}")
                .PUT(HttpRequest.BodyPublishers.noBody())
                .build()
            client.send(assignRequest, HttpResponse.BodyHandlers.ofString())
        }
    }
}

---

## 7. Mapeamento de Atributos

|Atributo midPoint|Atributo Keycloak|Regra|
|---|---|---|
|`name`|`username`|`first_name.lower() + '.' + last_name.lower()`|
|`givenName`|`firstName`|Direto (`David`)|
|`familyName`|`lastName`|Direto (`Velez`)|
|`email`|`email`|`first_name.last_name@lab.fiqueok.com`|
|`personalNumber`|`attributes.employeeID`|Direto (`FP001`)|
|`costCenter`|`attributes.costCenter`|Direto|
|`groups`|`groups`|Mapeamento via regra|

---

## 8. Configuração do Resource no midPoint

### 8.1. Criar Resource via XML

xml

<?xml version="1.0" encoding="UTF-8"?>
<resource xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3">
    <name>Keycloak (SSO)</name>
    <description>Integração com Keycloak para SSO e provisionamento</description>
    <lifecycleState>active</lifecycleState>
    
    <connectorRef oid="SCRIPTEDREST_CONNECTOR_OID"/>
    
    <connectorConfiguration>
        <groovyScripts>
            <searchScript>
                <source>
                    <include>/opt/midpoint/var/scripts/keycloak/SearchScript.groovy</include>
                </source>
            </searchScript>
            <createScript>
                <source>
                    <include>/opt/midpoint/var/scripts/keycloak/CreateScript.groovy</include>
                </source>
            </createScript>
        </groovyScripts>
    </connectorConfiguration>
    
    <schemaHandling>
        <objectType>
            <kind>account</kind>
            <intent>keycloak-user</intent>
            <displayName>Keycloak User</displayName>
            
            <attribute>
                <ref>username</ref>
                <inbound>
                    <strength>strong</strength>
                    <target>
                        <path>name</path>
                    </target>
                </inbound>
                <outbound>
                    <source>
                        <path>name</path>
                    </source>
                </outbound>
            </attribute>
            
            <attribute>
                <ref>email</ref>
                <inbound>
                    <target>
                        <path>email</path>
                    </target>
                </inbound>
                <outbound>
                    <source>
                        <path>email</path>
                    </source>
                </outbound>
            </attribute>
            
            <attribute>
                <ref>firstName</ref>
                <inbound>
                    <target>
                        <path>givenName</path>
                    </target>
                </inbound>
                <outbound>
                    <source>
                        <path>givenName</path>
                    </source>
                </outbound>
            </attribute>
            
            <attribute>
                <ref>lastName</ref>
                <inbound>
                    <target>
                        <path>familyName</path>
                    </target>
                </inbound>
                <outbound>
                    <source>
                        <path>familyName</path>
                    </source>
                </outbound>
            </attribute>
            
            <correlation>
                <correlationRule>
                    <name>Correlacao_Username</name>
                    <item>
                        <source>
                            <path>username</path>
                        </source>
                        <target>
                            <path>name</path>
                        </target>
                    </item>
                </correlationRule>
            </correlation>
            
            <synchronization>
                <reaction>
                    <situation>unmatched</situation>
                    <action>
                        <type>addFocus</type>
                    </action>
                </reaction>
            </synchronization>
        </objectType>
    </schemaHandling>
</resource>

---

## 9. Plano de Execução

|Fase|Atividade|Duração|Comandos/Procedimentos|
|---|---|---|---|
|**1**|Adicionar Keycloak ao docker-compose|10min|`nano docker-compose.yml` + `docker compose up -d`|
|**2**|Aguardar inicialização|1min|`sleep 60`|
|**3**|Criar realm e cliente|10min|Comandos curl|
|**4**|Obter Client Secret|5min|Salvar para uso futuro|
|**5**|Criar scripts Groovy|20min|Criar arquivos em `/srv/iga-project/data/midpoint/scripts/keycloak/`|
|**6**|Copiar scripts para container|5min|`docker cp`|
|**7**|Criar Resource Keycloak|15min|Via XML ou GUI|
|**8**|Configurar mapeamentos|10min|Adicionar inbound mappings|
|**9**|Testar conexão|5min|Test connection|
|**10**|Executar reconciliação|10min|Criar tarefa, Save & Run|
|**11**|Validar usuários criados|5min|Acessar Keycloak Admin Console|
|**Total**||**~1h40min**||

---

## 10. Verificações Pós-Configuração

### 10.1. Verificar Keycloak

bash

# [iga-gf-02]$
# Verificar container
docker ps | grep keycloak
# Verificar se realm foi criado
curl -s http://localhost:8081/admin/realms/fiqueok \
  -u admin:'Keycloak#2026' | jq '.realm'
# Verificar usuários criados
curl -s http://localhost:8081/admin/realms/fiqueok/users \
  -u admin:'Keycloak#2026' | jq '.[] | {username: .username, email: .email}'

### 10.2. Verificar no midPoint

bash

# [iga-gf-02]$
# Verificar resource criado
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/resources" \
  | jq '.[] | select(.name | contains("Keycloak"))'
# Verificar tarefa de reconciliação
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/tasks" \
  | jq '.tasks[] | {name: .name, status: .executionStatus}'

---

## 11. Critérios de Sucesso

|#|Critério|Métrica|
|---|---|---|
|1|Keycloak container rodando|`docker ps` mostra `iga-keycloak`|
|2|Realm `fiqueok` criado|API retorna realm|
|3|Cliente `midpoint` criado|Client secret gerado|
|4|Test Connection OK|Success no midPoint|
|5|Search retorna usuários|Lista de usuários existentes|
|6|CreateUser cria usuário|Usuário aparece no Keycloak|
|7|Reconciliação processa 102 objetos|`processed 102 objects`|
|8|Acesso SSO funcional|Login via Keycloak redireciona|

---

## 12. Riscos e Mitigações

|Risco|Probabilidade|Impacto|Mitigação|
|---|---|---|---|
|**Keycloak não inicia**|Baixa|Alto|Verificar logs `docker logs iga-keycloak`|
|**Porta 8081 ocupada**|Baixa|Médio|Alterar para 8082|
|**Banco de dados conflito**|Baixa|Médio|Usar schema separado|
|**ScriptedREST incompatível**|Baixa|Alto|Testar com endpoint simples primeiro|
|**Senha temporária não funciona**|Média|Baixo|Configurar fluxo de reset de senha|

---

## 13. Entregáveis

|Entregável|Formato|Local|
|---|---|---|
|Scripts Groovy|`.groovy`|`/srv/iga-project/data/midpoint/scripts/keycloak/`|
|Resource XML|`.xml`|Exportado do midPoint|
|TAP Documento|`.md`|Obsidian PRJ025|
|POP de Execução|`.md`|Obsidian PRJ025|
|Docker Compose atualizado|`.yml`|`/srv/iga-project/docker-compose.yml`|

---

## 14. Cronograma Estimado

---

## 15. Aprovações

|Função|Nome|Data|Decisão|
|---|---|---|---|
|Arquiteto IGA|Paulo Feitosa Lima|Maio/2026|✅ APROVADO|
|GRC Lead|Paulo Feitosa Lima|Maio/2026|✅ APROVADO|

---

## 16. Histórico de Versões

|Versão|Data|Autor|Mudanças|
|---|---|---|---|
|1.0|04/05/2026|Paulo Feitosa Lima|Criação do TAP para PRJ025 - Integração midPoint com Keycloak|

---

**Fim do TAP PRJ025**

---

_TAP - Technical Assessment Plan_  
_Living Lab Fiqueok_  
*PRJ025 - midPoint ↔ Keycloak via ScriptedREST*
