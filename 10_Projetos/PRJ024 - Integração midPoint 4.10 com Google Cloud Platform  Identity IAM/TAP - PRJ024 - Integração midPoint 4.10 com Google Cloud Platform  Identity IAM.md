## 📋 **TAP - Technical Assessment Plan**
### 

---

| Campo | Valor |
|-------|-------|
| **Projeto** | PRJ024 |
| **Título** | Integração midPoint 4.10 com GCP Identity & IAM |
| **Data** | Maio/2026 |
| **Versão** | 1.0 |
| **Status** | 📝 Em Planejamento |
| **Responsável** | Paulo Feitosa Lima |
| **Pré-requisito** | PRJ022-A (CSV → midPoint → AD) funcionando |
| **Documentos Base** | PRJ022 POP v1.4, PRJ022 Relatório Técnico |

---

## 1. Objetivo

Estabelecer integração entre o **midPoint 4.10** e o **Google Cloud Platform (GCP)** utilizando **ScriptedREST Connector** para:

1. Provisionar usuários no Google Workspace / Cloud Identity
2. Gerenciar permissões IAM em projetos GCP
3. Sincronizar identidades entre midPoint e GCP

---

## 2. Escopo

### 2.1. Dentro do Escopo

| Item | Descrição |
|------|-----------|
| ✅ | Criar Resource GCP no midPoint usando ScriptedREST Connector |
| ✅ | Implementar geração de JWT e OAuth2 para autenticação |
| ✅ | Implementar SearchScript.groovy (listar usuários) |
| ✅ | Implementar CreateScript.groovy (criar usuário) |
| ✅ | Mapear atributos midPoint → GCP |
| ✅ | Testar reconcialiação e provisionamento |
| ✅ | Documentar scripts e configurações |

### 2.2. Fora do Escopo

| Item | Justificativa |
|------|---------------|
| ❌ | Sincronização de grupos Google Workspace | Pode ser fase 2 |
| ❌ | Gerenciamento de políticas IAM complexas | Apenas usuário básico |
| ❌ | Remoção/desativação de usuários | Fase posterior |
| ❌ | GCP Service Accounts | Foco em usuários humanos |

---

## 3. Arquitetura Proposta

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                         PRJ024 - midPoint ↔ GCP via ScriptedREST                     │
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
│                      │  │            Resource GCP (ScriptedREST)                │  ││
│                      │  │  ┌─────────────────────────────────────────────────┐  │  ││
│                      │  │  │ SearchScript.groovy (GET /users)               │  │  ││
│                      │  │  │ CreateScript.groovy (POST /users)              │  │  ││
│                      │  │  │ UpdateScript.groovy (PATCH /users)             │  │  ││
│                      │  │  │ Authenticator.groovy (OAuth2 + JWT)            │  │  ││
│                      │  │  └─────────────────────────────────────────────────┘  │  ││
│                      │  └─────────────────────────┬─────────────────────────────┘  ││
│                      │                            │                                ││
│                      │                            │ HTTPS + Bearer Token          ││
│                      │                            ▼                                ││
│                      │  ┌───────────────────────────────────────────────────────┐  ││
│                      │  │                   Google Cloud APIs                    │  ││
│                      │  │  ┌─────────────────────────────────────────────────┐  │  ││
│                      │  │  │ Cloud Identity API (usuários)                   │  │  ││
│                      │  │  │ Admin SDK Directory API                         │  │  ││
│                      │  │  │ Cloud IAM API (permissões)                      │  │  ││
│                      │  │  └─────────────────────────────────────────────────┘  │  ││
│                      │  └───────────────────────────────────────────────────────┘  ││
│                      │                                                              ││
│                      └──────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Pré-Requisitos

| # | Requisito | Status | Critério |
|---|-----------|--------|----------|
| PR-01 | PRJ022-A funcionando (CSV) | ✅ | 103 usuários processados |
| PR-02 | Projeto GCP `midpoint-iga` criado | ✅ | Project ID disponível |
| PR-03 | Service Account `midpoint-connector` | ✅ | Email da SA disponível |
| PR-04 | Permissão `roles/iam.securityAdmin` | ✅ | Atribuída à SA |
| PR-05 | Chave JSON da SA gerada | ✅ | `midpoint-gcp-key.json` |
| PR-06 | Chave transferida para `iga-gf-02` | ✅ | `/srv/iga-project/data/midpoint/` |
| PR-07 | Variável `GCP_CREDENTIALS_PATH` configurada | ✅ | No docker-compose.yml |
| PR-08 | APIs ativadas no GCP | ✅ | IAM, Cloud Resource Manager, Admin SDK |
| PR-09 | ScriptedREST Connector disponível | ✅ | Já presente no midPoint |

---

## 5. Estrutura de Scripts GCP

### 5.1. Diretório de Scripts

```bash
/srv/iga-project/data/midpoint/scripts/gcp/
├── Authenticator.groovy     # Geração de JWT e Access Token
├── SearchScript.groovy      # Listagem de usuários
├── CreateScript.groovy      # Criação de usuários
├── UpdateScript.groovy      # Atualização de usuários
└── config.groovy            # Configurações comuns
```

### 5.2. Pipeline de Autenticação OAuth2

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Fluxo de Autenticação GCP via JWT                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. Ler chave JSON da Service Account                                       │
│     ↓                                                                        │
│  2. Extrair: client_email, private_key, private_key_id                     │
│     ↓                                                                        │
│  3. Criar JWT Header: {"alg":"RS256","typ":"JWT"}                          │
│     ↓                                                                        │
│  4. Criar JWT Claim Set:                                                    │
│     {                                                                        │
│       "iss": client_email,                                                  │
│       "scope": "https://www.googleapis.com/auth/cloud-platform",           │
│       "aud": "https://oauth2.googleapis.com/token",                        │
│       "exp": now + 3600,                                                    │
│       "iat": now                                                            │
│     }                                                                        │
│     ↓                                                                        │
│  5. Assinar JWT com private_key (RSA SHA256)                               │
│     ↓                                                                        │
│  6. Trocar JWT por Access Token:                                           │
│     POST https://oauth2.googleapis.com/token                               │
│     ↓                                                                        │
│  7. Retornar Access Token (Bearer)                                          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Scripts Groovy Completos

### 6.1. Authenticator.groovy

```groovy
// /srv/iga-project/data/midpoint/scripts/gcp/Authenticator.groovy
import groovy.json.JsonSlurper
import groovy.json.JsonOutput
import java.security.KeyFactory
import java.security.PrivateKey
import java.security.Signature
import java.security.spec.PKCS8EncodedKeySpec
import java.time.Instant
import java.util.Base64
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.net.URI

class GCPAuthenticator {
    
    private String credentialsPath
    private String cachedToken
    private long tokenExpiresAt = 0
    
    GCPAuthenticator(String credentialsPath) {
        this.credentialsPath = credentialsPath
    }
    
    String getAccessToken() {
        // Verificar se token está expirado
        if (cachedToken != null && System.currentTimeMillis() < tokenExpiresAt) {
            return cachedToken
        }
        return refreshToken()
    }
    
    private String refreshToken() {
        def credentials = new JsonSlurper().parse(new File(credentialsPath))
        def jwt = generateJWT(credentials)
        
        def client = HttpClient.newHttpClient()
        def body = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}"
        
        def request = HttpRequest.newBuilder()
            .uri(URI.create("https://oauth2.googleapis.com/token"))
            .header("Content-Type", "application/x-www-form-urlencoded")
            .POST(HttpRequest.BodyPublishers.ofString(body))
            .build()
        
        def response = client.send(request, HttpResponse.BodyHandlers.ofString())
        def json = new JsonSlurper().parseText(response.body())
        
        cachedToken = json.access_token
        tokenExpiresAt = System.currentTimeMillis() + (json.expires_in * 1000) - 60000
        
        return cachedToken
    }
    
    private String generateJWT(Map credentials) {
        def now = Instant.now().getEpochSecond()
        def header = [
            alg: "RS256",
            typ: "JWT"
        ]
        
        def claimSet = [
            iss: credentials.client_email,
            scope: "https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/admin.directory.user",
            aud: "https://oauth2.googleapis.com/token",
            exp: now + 3600,
            iat: now
        ]
        
        def encodedHeader = base64UrlEncode(JsonOutput.toJson(header))
        def encodedClaimSet = base64UrlEncode(JsonOutput.toJson(claimSet))
        
        def signatureInput = "${encodedHeader}.${encodedClaimSet}"
        def signature = signRSA(signatureInput, credentials.private_key)
        def encodedSignature = base64UrlEncode(signature)
        
        return "${encodedHeader}.${encodedClaimSet}.${encodedSignature}"
    }
    
    private String base64UrlEncode(String data) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(data.getBytes("UTF-8"))
    }
    
    private String base64UrlEncode(byte[] data) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(data)
    }
    
    private String signRSA(String data, String privateKeyPEM) {
        def privateKeyContent = privateKeyPEM
            .replace("-----BEGIN PRIVATE KEY-----", "")
            .replace("-----END PRIVATE KEY-----", "")
            .replaceAll("\\s", "")
        
        def keyBytes = Base64.getDecoder().decode(privateKeyContent)
        def spec = new PKCS8EncodedKeySpec(keyBytes)
        def keyFactory = KeyFactory.getInstance("RSA")
        def privateKey = keyFactory.generatePrivate(spec)
        
        def signature = Signature.getInstance("SHA256withRSA")
        signature.initSign(privateKey)
        signature.update(data.getBytes("UTF-8"))
        
        return Base64.getUrlEncoder().withoutPadding().encodeToString(signature.sign())
    }
}
```

### 6.2. config.groovy

```groovy
// /srv/iga-project/data/midpoint/scripts/gcp/config.groovy
def GCP_CONFIG = [
    credentialsPath: System.getenv("GCP_CREDENTIALS_PATH") ?: "/opt/midpoint/var/midpoint-gcp-key.json",
    directoryApiUrl: "https://admin.googleapis.com/admin/directory/v1",
    iamApiUrl: "https://iam.googleapis.com/v1",
    customerId: "my_customer",
    maxResults: 100
]

// Inicializar autenticador
def authenticator = new GCPAuthenticator(GCP_CONFIG.credentialsPath)
def accessToken = authenticator.getAccessToken()
```

### 6.3. SearchScript.groovy

```groovy
// /srv/iga-project/data/midpoint/scripts/gcp/SearchScript.groovy
import groovy.json.JsonSlurper
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.net.URI

// Carregar configurações e autenticação
def config = new groovy.lang.Binding()
def gcpAuth = new GroovyShell(config).parse(new File("/opt/midpoint/var/scripts/gcp/Authenticator.groovy"))

def auth = gcpAuth.getClass().newInstance(System.getenv("GCP_CREDENTIALS_PATH"))
def token = auth.getAccessToken()

def client = HttpClient.newHttpClient()
def request = HttpRequest.newBuilder()
    .uri(URI.create("https://admin.googleapis.com/admin/directory/v1/users?customer=my_customer&maxResults=100"))
    .header("Authorization", "Bearer ${token}")
    .header("Content-Type", "application/json")
    .GET()
    .build()

def response = client.send(request, HttpResponse.BodyHandlers.ofString())

if (response.statusCode() == 200) {
    def json = new JsonSlurper().parseText(response.body())
    json.users.each { user ->
        handler([
            userName: user.primaryEmail,
            name: user.name.fullName,
            givenName: user.name.givenName,
            familyName: user.name.familyName
        ])
    }
} else {
    throw new RuntimeException("Erro GCP API: ${response.statusCode()} - ${response.body()}")
}
```

### 6.4. CreateScript.groovy

```groovy
// /srv/iga-project/data/midpoint/scripts/gcp/CreateScript.groovy
import groovy.json.JsonOutput
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.net.URI

// Obter token
def auth = new GCPAuthenticator(System.getenv("GCP_CREDENTIALS_PATH"))
def token = auth.getAccessToken()

// Construir payload do usuário
def userPayload = [
    primaryEmail: "${attributes.firstName.toLowerCase()}.${attributes.lastName.toLowerCase()}@midpoint-lab.com",
    name: [
        givenName: attributes.givenName,
        familyName: attributes.familyName
    ],
    password: generateRandomPassword(),
    changePasswordAtNextLogin: true
]

def client = HttpClient.newHttpClient()
def request = HttpRequest.newBuilder()
    .uri(URI.create("https://admin.googleapis.com/admin/directory/v1/users"))
    .header("Authorization", "Bearer ${token}")
    .header("Content-Type", "application/json")
    .POST(HttpRequest.BodyPublishers.ofString(JsonOutput.toJson(userPayload)))
    .build()

def response = client.send(request, HttpResponse.BodyHandlers.ofString())

if (response.statusCode() == 201) {
    def json = new groovy.json.JsonSlurper().parseText(response.body())
    handler([
        userName: json.primaryEmail,
        name: json.name.fullName
    ])
} else {
    throw new RuntimeException("Erro ao criar usuário: ${response.statusCode()} - ${response.body()}")
}
```

---

## 7. Mapeamento de Atributos

| Atributo midPoint | Atributo GCP | Regra |
|-------------------|--------------|-------|
| `name` | `primaryEmail` | `first_name.last_name@midpoint-lab.com` |
| `givenName` | `name.givenName` | Direto |
| `familyName` | `name.familyName` | Direto |
| `email` | `primaryEmail` | `first_name.last_name@midpoint-lab.com` |
| `personalNumber` | `externalIds` | `{ "value": "FP001", "type": "employeeId" }` |

---

## 8. Configuração do Resource no midPoint

### 8.1. Criar Resource via XML

```xml
<?xml version="1.0" encoding="UTF-8"?>
<resource xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3">
    <name>GCP Cloud Identity</name>
    <description>Integração com Google Cloud Identity via ScriptedREST</description>
    <lifecycleState>active</lifecycleState>
    
    <connectorRef oid="SCRIPTEDREST_CONNECTOR_OID"/>
    
    <connectorConfiguration>
        <groovyScripts>
            <searchScript>
                <source>
                    <include>/opt/midpoint/var/scripts/gcp/SearchScript.groovy</include>
                </source>
            </searchScript>
            <createScript>
                <source>
                    <include>/opt/midpoint/var/scripts/gcp/CreateScript.groovy</include>
                </source>
            </createScript>
        </groovyScripts>
    </connectorConfiguration>
    
    <schemaHandling>
        <objectType>
            <kind>account</kind>
            <intent>gcp-user</intent>
            <displayName>GCP User</displayName>
            
            <attribute>
                <ref>primaryEmail</ref>
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
                <ref>givenName</ref>
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
                <ref>familyName</ref>
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
                    <name>Correlacao_Email</name>
                    <item>
                        <source>
                            <path>primaryEmail</path>
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
```

---

## 9. Plano de Execução

| Fase | Atividade | Duração | Responsável |
|------|-----------|---------|-------------|
| **1** | Criar scripts Groovy no diretório | 1h | Paulo |
| **2** | Testar autenticação isoladamente | 30min | Paulo |
| **3** | Criar Resource via XML | 20min | Paulo |
| **4** | Configurar mapeamentos | 20min | Paulo |
| **5** | Executar teste com usuário único | 30min | Paulo |
| **6** | Validar reconciliação total | 30min | Paulo |
| **7** | Documentar e arquivar scripts | 30min | Paulo |
| **Total** | | **3h40min** | |

---

## 10. Critérios de Sucesso

| # | Critério | Métrica |
|---|----------|---------|
| 1 | Test Connection OK | Conexão com GCP estabelecida |
| 2 | Search retorna usuários | Lista de usuários existentes |
| 3 | CreateUser cria usuário | Usuário aparece no Google Admin |
| 4 | Reconciliation sem erros | Processados 0 erros |
| 5 | Correlação funciona | Usuários existentes encontrados |

---

## 11. Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| JWT não gera token válido | Alta | Alto | Validar com ferramenta externa JWT.io |
| Timeout de API | Média | Médio | Implementar retry com backoff |
| Rate limiting do Google | Baixa | Médio | Respeitar quotas da API |
| ScriptedREST incompatível | Baixa | Alto | Testar antes com endpoint simples |

---

## 12. Entregáveis

| Entregável | Formato | Local |
|------------|---------|-------|
| Scripts Groovy | `.groovy` | `/srv/iga-project/data/midpoint/scripts/gcp/` |
| Resource XML | `.xml` | Exportado do midPoint |
| TAP Documento | `.md` | Obsidian PRJ024 |
| POP de Execução | `.md` | Obsidian PRJ024 |
| Logs de teste | `.log` | `/tmp/prj024-gcp-test.log` |

---

## 13. Cronograma

```mermaid
gantt
    title PRJ024 - Cronograma
    dateFormat HH:mm
    section Desenvolvimento
    Criar scripts Groovy :a1, 09:00, 1h
    Testar autenticação :a2, 10:00, 30m
    section Configuração
    Criar Resource :a3, 10:30, 20m
    Configurar mapeamentos :a4, 10:50, 20m
    section Validação
    Teste com usuário único :a5, 11:10, 30m
    Reconciliação total :a6, 11:40, 30m
    Documentação :a7, 12:10, 30m
```

---

## 14. Aprovações

| Função | Nome | Data | Decisão |
|--------|------|------|---------|
| Arquiteto IGA | Paulo Feitosa Lima | Maio/2026 | ✅ APROVADO |
| GRC Lead | Paulo Feitosa Lima | Maio/2026 | ✅ APROVADO |

---

## 15. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 04/05/2026 | Paulo Feitosa Lima | Criação do TAP para PRJ024 - Integração midPoint com GCP |

---

**Fim do TAP PRJ024**

---

*TAP - Technical Assessment Plan*  
*Living Lab Fiqueok*  
*PRJ024 - midPoint ↔ GCP via ScriptedREST*