
### 

**Versão:** 1.0  
**Data:** Maio/2026  
**Status:** ✅ **VALIDADO** — Baseado nas lições do Living Lab Fiqueok (PRJ001-PRJ022)  
**Responsável:** Paulo Feitosa Lima  
**Classificação:** Público (Laboratório) / Interno (Produção)  

---

## ÍNDICE

1. [Objetivo do Documento](#1-objetivo-do-documento)
2. [Visão Geral da Arquitetura](#2-visão-geral-da-arquitetura)
3. [Conceitos Fundamentais](#3-conceitos-fundamentais)
4. [Matriz de Integrações](#4-matriz-de-integrações)
5. [Integração com Active Directory / Entra ID](#5-integração-com-active-directory--entra-id)
6. [Integração com Keycloak (SSO)](#6-integração-com-keycloak-sso)
7. [Integração com SAP](#7-integração-com-sap)
8. [Integração com AWS](#8-integração-com-aws)
9. [Integração com GCP](#9-integração-com-gcp)
10. [Estratégia de Correlação Multissistemas](#10-estratégia-de-correlação-multissistemas)
11. [Governança e Ciclo de Vida (JML)](#11-governança-e-ciclo-de-vida-jml)
12. [Topologias de Implantação](#12-topologias-de-implantação)
13. [Requisitos de Segurança](#13-requisitos-de-segurança)
14. [Checklist de Validação](#14-checklist-de-validação)
15. [Resolução de Problemas](#15-resolução-de-problemas)
16. [Lições Aprendidas](#16-lições-aprendidas)
17. [Anexos: Scripts e Configurações](#17-anexos-scripts-e-configurações)
18. [Histórico de Versões](#18-histórico-de-versões)

---

## 1. Objetivo do Documento

Este documento define a **arquitetura de referência** para integração do **midPoint 4.10** com os principais sistemas corporativos e de nuvem:

| Sistema | Tipo | Caso de Uso Primário |
|---------|------|---------------------|
| **Active Directory / Entra ID** | Diretório | Autenticação, grupos, estações de trabalho |
| **Keycloak** | SSO/IdP | Autenticação federada para aplicações web |
| **SAP** | ERP | Governança de acessos a sistemas core |
| **AWS** | IaaS/PaaS | Provisionamento de usuários e funções IAM |
| **GCP** | IaaS/PaaS | Provisionamento de identidades e políticas |

### 1.1. Público-Alvo

- Arquitetos de Soluções IAM/IGA
- Engenheiros de Identidade
- Administradores de midPoint
- Equipes de GRC (Governança, Risco e Compliance)

---

## 2. Visão Geral da Arquitetura

### 2.1. Diagrama de Contexto

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                          FONTES AUTORITATIVAS (Sistemas Fonte)                        │
├─────────────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐           │
│  │     RH      │    │  Shadow     │    │  Workday/   │    │  CSV/       │           │
│  │  (HRM)      │    │  API        │    │  SAP HR     │    │  LDAP       │           │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘           │
│         │                  │                  │                  │                   │
│         └──────────────────┼──────────────────┼──────────────────┘                   │
│                            │                  │                                      │
└────────────────────────────┼──────────────────┼──────────────────────────────────────┘
                             │                  │
                             ▼                  ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              midPoint (IGA Core)                                      │
│  ┌───────────────────────────────────────────────────────────────────────────────┐  │
│  │                         CORRELAÇÃO (Correlation Engine)                        │  │
│  │                                                                               │  │
│  │  Atributos base:                                                              │  │
│  │  • employeeID (Chave primária - RH)                                           │  │
│  │  • mail (Chave secundária - universal)                                        │  │
│  │  • sAMAccountName (Chave terciária - AD)                                      │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                      │
│  ┌───────────────────────────────────────────────────────────────────────────────┐  │
│  │                      MA PEAMENTO E REGRAS (Mapping Engine)                    │  │
│  │                                                                               │  │
│  │  Regras de geração:                                                           │  │
│  │  • name = first_name.last_name (AD/Keycloak)                                  │  │
│  │  • personalNumber = employeeID (SAP/RACF)                                     │  │
│  │  • email = first_name.last_name@dominio (Gmail/Exchange)                      │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                      │
│  ┌───────────────────────────────────────────────────────────────────────────────┐  │
│  │                 PROVISIONAMENTO (Provisioning Engine)                         │  │
│  │                                                                               │  │
│  │  Lifecycle Reactions:                                                         │  │
│  │  • Unmatched → addFocus (Joiner)                                              │  │
│  │  • Matched → link (Correlação existente)                                      │  │
│  │  • Deleted → unlink/disable (Leaver)                                          │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────────┘
                             │                  │                  │
        ┌────────────────────┼──────────────────┼──────────────────┼────────────────────┐
        │                    │                  │                  │                    │
        ▼                    ▼                  ▼                  ▼                    ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│      AD/      │  │   Keycloak    │  │     SAP       │  │     AWS       │  │     GCP       │
│   Entra ID    │  │    (SSO)      │  │   (ERP)       │  │   (Cloud)     │  │   (Cloud)     │
├───────────────┤  ├───────────────┤  ├───────────────┤  ├───────────────┤  ├───────────────┤
│ sAMAccountName│  │   username    │  │   SAP USR     │  │  IAM User     │  │  GCP Account  │
│ userPrincipal │  │   email       │  │   GRP         │  │  IAM Role     │  │  GCP Group    │
│ memberOf      │  │   groups      │  │   Profile     │  │  Policy       │  │  Policy       │
│ employeeID    │  │   attributes  │  │   CUA         │  │  Permission   │  │  Permission   │
└───────────────┘  └───────────────┘  └───────────────┘  └───────────────┘  └───────────────┘
```

### 2.2. Fluxo de Dados Típico (Joiner)

```
[RH] Contrata novo funcionário (employeeID = FP001)
    │
    ▼
[Shadow API] Normaliza e expõe os dados: FP001, David Velez, david.velez@email.com
    │
    ▼
[midPoint] Detecta novo recurso (CSV ou REST)
    │
    ├──► Correlação: Nenhum FP001 encontrado → UNMATCHED
    │
    ├──► Sync: addFocus → Cria User no midPoint
    │       ├── name = david.velez
    │       ├── personalNumber = FP001
    │       ├── givenName = David
    │       └── familyName = Velez
    │
    └──► Provisionamento (Add) para cada target:
            │
            ├──► AD: create david.velez, set employeeID=FP001
            ├──► Keycloak: create davvelez, assign default roles
            ├──► SAP: create user FP001, assign base profile
            ├──► AWS: create IAM user, assign default policy
            └──► GCP: create account, assign basic roles
```

---

## 3. Conceitos Fundamentais

### 3.1. O Papel do midPoint na Arquitetura

O midPoint atua como **Motor de Orquestração de Identidades**, sendo:

| Função | Descrição |
|--------|-----------|
| **Correlation Engine** | Conecta identidades de diferentes fontes (RH, AD, SAP) |
| **Policy Decision Point (PDP)** | Aplica regras de negócio (Joiner/Mover/Leaver) |
| **Provisioning Point** | Executa ações de criação, modificação e remoção |
| **Audit Trail** | Registra todas as ações para compliance (SOX, LGPD) |

### 3.2. Atributos Base Recomendados

Para uma arquitetura robusta, estes atributos devem existir em TODOS os sistemas:

| Atributo | Formato | Imutável | Uso |
|----------|---------|----------|-----|
| **employeeID** | `FP001` / `123456` | ✅ Sim | Chave de correlação primária |
| **mail** | `user@domain.com` | ⚠️ Pode mudar | Chave de correlação secundária |
| **displayName** | `David Velez` | ⚠️ Pode mudar | Exibição em interfaces |
| **status** | `active/inactive` | ❌ Não | Controle de ciclo de vida |

---

## 4. Matriz de Integrações

### 4.1. Visão Geral por Sistema

| Sistema | Conector midPoint | Conector Bundle | Dependências |
|---------|-------------------|-----------------|--------------|
| **AD / Entra ID** | `AdLdapConnector` | `com.evolveum.polygon.connector-ldap` | Java, LDAP/Graph API |
| **Keycloak** | `ScriptedREST` ou `connector-rest` | Custom ou comunidade | Java, REST API |
| **SAP** | `DatabaseTableConnector` ou RFC | `org.identityconnectors.databasetable` | JDBC, RFC SDK |
| **AWS** | `com.atricore.midpoint.aws` | Atricore (comunidade) | Java, AWS SDK |
| **GCP** | `com.evolveum.polygon.googlecloud` | Evolveum (roadmap) | Java, GCP SDK |

### 4.2. Métodos de Provisionamento

| Sistema | Método | Síncrono/Assíncrono | Bulk Supported |
|---------|--------|---------------------|----------------|
| **AD** | LDAP/ LDAPS | Síncrono | ✅ Sim (reconciliação) |
| **Entra ID** | Microsoft Graph REST | Assíncrono | ⚠️ Limitado |
| **Keycloak** | REST API (`/admin/realms`) | Síncrono | ✅ Sim |
| **SAP** | RFC / JDBC | Síncrono | ✅ Sim (batch) |
| **AWS** | AWS SDK / REST | Síncrono | ✅ Sim (CloudFormation) |
| **GCP** | GCP SDK / REST | Síncrono | ✅ Sim (Deployment Manager) |

---

## 5. Integração com Active Directory / Entra ID

### 5.1. Arquitetura

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Integração midPoint ↔ Active Directory                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐                     ┌─────────────────────────────────────┐│
│  │  midPoint   │  ◄─── LDAP/LDAPS ───►│        Active Directory            ││
│  │             │                     │  ┌─────────────────────────────┐    ││
│  │  Connector: │                     │  │ sAMAccountName: david.velez │    ││
│  │  AdLdap     │                     │  │ userPrincipalName: david.v@  │    ││
│  │             │                     │  │ employeeID: FP001            │    ││
│  │  Port: 389  │                     │  │ mail: david.velez@empresa.com│    ││
│  │  (636 SSL)  │                     │  │ memberOf: Domain Users       │    ││
│  └─────────────┘                     │  └─────────────────────────────┘    ││
│         │                            └─────────────────────────────────────┘│
│         │                                                                    │
│         │ (Opcional) 📡 Graph API                                            │
│         ▼                                                                    │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                         Microsoft Entra ID (Cloud)                       ││
│  │  ┌─────────────────────────────────────────────────────────────────────┐││
│  │  │ • Sincronização via Azure AD Connect (dirigida pelo midPoint? Não)  │││
│  │  │ • Recomendação: midPoint → On-Prem AD → Entra Connect               │││
│  │  └─────────────────────────────────────────────────────────────────────┘││
│  └─────────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.2. Mapeamento de Atributos Recomendado

| Atributo midPoint | Atributo AD | Regra | Direção |
|-------------------|-------------|-------|---------|
| `name` | `sAMAccountName` | `first_name.lower() + '.' + last_name.lower()` | inbound/outbound |
| `personalNumber` | `employeeID` | Direto (`FP001`) | inbound/outbound |
| `givenName` | `givenName` | Direto (`David`) | inbound/outbound |
| `familyName` | `sn` | Direto (`Velez`) | inbound/outbound |
| `email` | `mail` | `first_name.last_name@dominio` | inbound/outbound |
| `fullName` | `displayName` | `givenName + ' ' + familyName` | inbound/outbound |
| `userPrincipalName` | `userPrincipalName` | `email` (mesmo valor) | inbound/outbound |

### 5.3. Configuração do Resource (XML Base)

```xml
<resource>
    <name>Active Directory (On-Prem)</name>
    <connectorRef oid="20f08b13-5ba3-414b-bfb9-0842e290c7e1"/>
    <connectorConfiguration>
        <connection>
            <host>ad.fiqueok.local</host>
            <port>389</port>
            <connectionSecurity>starttls</connectionSecurity>
            <bindDn>CN=svc_midpoint,OU=Service Accounts,DC=fiqueok,DC=local</bindDn>
            <bindPassword>
                <value>********</value>
            </bindPassword>
        </connection>
        <accountSynchronization>
            <enabled>true</enabled>
        </accountSynchronization>
    </connectorConfiguration>
    <schemaHandling>
        <objectType>
            <kind>account</kind>
            <intent>user</intent>
            <attribute>
                <ref>sAMAccountName</ref>
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
                <ref>employeeID</ref>
                <inbound>
                    <strength>strong</strength>
                    <target>
                        <path>personalNumber</path>
                    </target>
                </inbound>
                <outbound>
                    <source>
                        <path>personalNumber</path>
                    </source>
                </outbound>
            </attribute>
        </objectType>
    </schemaHandling>
</resource>
```

### 5.4. Boas Práticas para AD

| Boa Prática | Justificativa |
|-------------|---------------|
| Usar conta de serviço dedicada (`svc_midpoint`) | Auditoria, menor privilégio |OK|
| Conectar via LDAPS (636) ou STARTTLS (389) | Segurança em trânsito |OK|
| Estender esquema AD para incluir `employeeID` | Correlação direta com RH |OK|
| NÃO sincronizar senhas via midPoint | Usar SSPR ou AD self-service |OK|
| Para Entra ID, usar Azure AD Connect (não midPoint) | Escala, resiliência, suporte Microsoft |OK|

---

## 6. Integração com Keycloak (SSO)

### 6.1. Arquitetura

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       Integração midPoint ↔ Keycloak                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐                     ┌─────────────────────────────────────┐│
│  │  midPoint   │  ◄─── REST API ────►│           Keycloak                  ││
│  │             │   (Admin Token)     │  ┌─────────────────────────────┐    ││
│  │  Connector: │                     │  │ username: david.velez       │    ││
│  │  ScriptedSQL│                     │  │ email: david.velez@empresa  │    ││
│  │  (HTTP)     │                     │  │ firstName: David            │    ││
│  │   ou        │                     │  │ lastName: Velez             │    ││
│  │  REST (Mvn) │                     │  │ groups: employees, finance  │    ││
│  └─────────────┘                     │  └─────────────────────────────┘    ││
│         │                            └─────────────────────────────────────┘│
│         │                                                                    │
│         │  🔄 User Federation (Opcional)                                     │
│         ▼                                                                    │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                    Aplicações Web (SSO)                                  ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     ││
│  │  │   Portal    │  │    ERP      │  │   CRM       │  │   Help Desk │     ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘     ││
│  └─────────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.2. Mapeamento de Atributos

| Atributo midPoint | Atributo Keycloak | Regra | Direção |
|-------------------|-------------------|-------|---------|
| `name` | `username` | `first_name.lower() + '.' + last_name.lower()` | outbound |
| `givenName` | `firstName` | Direto (`David`) | outbound |
| `familyName` | `lastName` | Direto (`Velez`) | outbound |
| `email` | `email` | `first_name.last_name@dominio` | outbound |
| `personalNumber` | `attributes.employeeID` | Direto (`FP001`) | outbound |

### 6.3. Script Groovy para Keycloak (REST)

```groovy
// Provisionamento Keycloak via REST
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.net.URI

def KEYCLOAK_URL = "http://keycloak:8080/admin/realms/fiqueok/users"
def ACCESS_TOKEN = System.getenv("KEYCLOAK_TOKEN")

def createUser(attributes) {
    def userJson = """
    {
        "username": "${attributes.name}",
        "firstName": "${attributes.givenName}",
        "lastName": "${attributes.familyName}",
        "email": "${attributes.email}",
        "enabled": true,
        "attributes": {
            "employeeID": ["${attributes.personalNumber}"]
        }
    }
    """
    
    def request = HttpRequest.newBuilder()
        .uri(URI.create(KEYCLOAK_URL))
        .header("Authorization", "Bearer ${ACCESS_TOKEN}")
        .header("Content-Type", "application/json")
        .POST(BodyPublishers.ofString(userJson))
        .build()
    
    return client.send(request, HttpResponse.BodyHandlers.ofString())
}
```

### 6.4. Boas Práticas para Keycloak

| Boa Prática | Justificativa |
|-------------|---------------|
| Usar client ID e secret para autenticação da API | Mais seguro que token fixo |OK|
| Criar realms por ambiente (dev/hom/prod) | Isolamento de configurações |OK|
| Sincronizar grupos do midPoint para Keycloak | Autorização centralizada |OK|
| NÃO provisionar senhas via API | Usar fluxo de reset de senha (e-mail) |OK|

---

## 7. Integração com SAP

### 7.1. Arquitetura

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Integração midPoint ↔ SAP                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐                     ┌─────────────────────────────────────┐│
│  │  midPoint   │                     │               SAP                   ││
│  │             │                     │  ┌─────────────────────────────┐    ││
│  │  Connector: │  ◄─── RFC ─────────►│  │ User Type: Dialog           │    ││
│  │  SAP (JCo)  │                     │  │ Alias: FP001                 │    ││
│  │             │  ◄─── JDBC ─────────►│  │ Profile: Z_BASIC_USER        │    ││
│  └─────────────┘                     │  │ Role: Z_EMPLOYEE_ROLE        │    ││
│         │                            │  │ CUA: Central User Admin      │    ││
│         │                            │  └─────────────────────────────┘    ││
│         │ (Opcional) 🔄 CUA (Central)│                                       ││
│         ▼                            └─────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                    Sistemas SAP Satélites                                ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                      ││
│  │  │  SAP ECC    │  │  SAP S/4    │  │  SAP BW     │                      ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘                      ││
│  └─────────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.2. Mapeamento de Atributos

| Atributo midPoint | Atributo SAP | Regra | Direção |
|-------------------|--------------|-------|---------|
| `personalNumber` | `BNAME` (User ID) | Direto (FP001) | inbound/outbound |
| `givenName` | `NAME_FIRST` | Direto (`David`) | inbound/outbound |
| `familyName` | `NAME_LAST` | Direto (`Velez`) | inbound/outbound |
| `email` | `E_MAIL` | Direto | inbound/outbound |
| `costCenter` | `KOSTL` | Direto | inbound/outbound |
| `department` | `DEPARTMENT` | Direto | inbound/outbound |

### 7.3. Estrutura de Provisionamento SAP

```
midPoint detecta novo funcionário (FP001)
    │
    ├──► Criação no SAP CUA (Central User Administration)
    │       ├── USR01 (Logon data)
    │       ├── USR02 (Password data)
    │       └── USR21 (User address)
    │
    ├──► Atribuição de Profiles (SU01)
    │       └── Z_BASIC_EMPLOYEE
    │
    ├──► Atribuição de Roles (PFCG)
    │       ├── Z_EMPLOYEE_PORTAL
    │       └── Z_HR_SELF_SERVICE
    │
    └──► Distribuição para sistemas satélites (CUA)
            ├── SAP ECC (Production)
            └── SAP BW (Reporting)
```

### 7.4. Boas Práticas para SAP

| Boa Prática | Justificativa |
|-------------|---------------|
| Usar SAP CUA (Central User Administration) | Ponto único de gestão para múltiplos sistemas SAP |OK|
| NUNCA provisionar senhas em texto plano | SAP exige hash específico; usar fluxo de reset |OK|
| Criar usuários técnicos com GRAPHICAL | Contas de serviço para integrações |OK|
| Usar RFC com segurança (SNC/SSO) | Proteção contra ataques de rede |OK|
| Implementar SAP GRC para segregação de funções | Compliance SOX para acessos críticos |OK|

---

## 8. Integração com AWS

### 8.1. Arquitetura

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Integração midPoint ↔ AWS                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐                     ┌─────────────────────────────────────┐│
│  │  midPoint   │                     │               AWS                   ││
│  │             │                     │  ┌─────────────────────────────┐    ││
│  │  Connector: │  ◄─── AWS SDK ─────►│  │ IAM User: david.velez       │    ││
│  │  AWS        │                     │  │ Access Key: AKIA...          │    ││
│  │  (Atricore) │                     │  │ Groups: developers           │    ││
│  │             │                     │  │ Policies: S3ReadOnly        │    ││
│  └─────────────┘                     │  │ Roles: OrganizationAdmin     │    ││
│         │                            │  │ Console Access: true         │    ││
│         │                            │  └─────────────────────────────┘    ││
│         │ (Opcional) 🔄 CloudFormation  │                                   ││
│         ▼                            └─────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                    Recursos AWS (por região)                             ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     ││
│  │  │     S3      │  │   DynamoDB  │  │    Lambda   │  │     EC2     │     ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘     ││
│  └─────────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.2. Mapeamento de Atributos

| Atributo midPoint | Atributo AWS IAM | Regra | Direção |
|-------------------|------------------|-------|---------|
| `name` | `UserName` | `first_name.lower() + '.' + last_name.lower()` | outbound |
| `personalNumber` | `Tags.employeeID` | Direto (`FP001`) | outbound |
| `email` | `Tags.email` | Direto | outbound |
| `department` | `Tags.department` | Direto | outbound |

### 8.3. Provisionamento de IAM

```xml
<!-- Exemplo de atribuição de política AWS -->
<assignment>
    <targetRef oid="aws-role-developer-oid" type="RoleType"/>
    <construction>
        <resourceRef oid="aws-resource-oid" type="ResourceType"/>
        <kind>account</kind>
        <intent>iam-user</intent>
        <association>
            <attribute>
                <ref>policyName</ref>
                <value>arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess</value>
            </attribute>
        </association>
    </construction>
</assignment>
```

### 8.4. Boas Práticas para AWS

| Boa Prática | Justificativa |
|-------------|---------------|
| **NUNCA** provisionar Access Keys automaticamente | Risco de exposição; usar roles/STS |OK|
| Usar AWS Organizations para múltiplas contas | Governança centralizada |OK|
| Provisionar apenas grupos e policies | Gerenciar permissões em nível de grupo |OK|
| Usar Tags para rastreabilidade (`createdBy=midpoint`) | Auditoria e custo por departamento |OK|
| Implementar IAM Access Analyzer | Validação de políticas antes de provisionar |OK|

---

## 9. Integração com GCP

### 9.1. Arquitetura

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Integração midPoint ↔ GCP                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐                     ┌─────────────────────────────────────┐│
│  │  midPoint   │                     │               GCP                   ││
│  │             │                     │  ┌─────────────────────────────┐    ││
│  │  Connector: │  ◄─── GCP SDK ─────►│  │ Account: david.velez@emp     │    ││
│  │  GCP (roadma│                     │  │ Groups: gcp-developers       │    ││
│  │  p)         │                     │  │ Roles: roles/viewer          │    ││
│  │             │                     │  │ Permissions: compute.inst    │    ││
│  └─────────────┘                     │  │ Service Account? false       │    ││
│         │                            │  └─────────────────────────────┘    ││
│         │ (Opcional) 🔄 Deployment Mgr│                                     ││
│         ▼                            └─────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                    Recursos GCP (por projeto)                            ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     ││
│  │  │   GCS (S3)  │  │  BigQuery   │  │   Cloud Run │  │    GKE      │     ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘     ││
│  └─────────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.2. Mapeamento de Atributos

| Atributo midPoint | Atributo GCP | Regra | Direção |
|-------------------|--------------|-------|---------|
| `email` | `primaryEmail` | Direto (`david.velez@fiqueok.com`) | outbound |
| `name` | `name.familyName` + `givenName` | `givenName + ' ' + familyName` | outbound |
| `personalNumber` | `externalIds` | Direto (`FP001`) | outbound |
| `department` | `orgUnitPath` | Direto | outbound |

### 9.3. Estrutura de Provisionamento GCP

```
midPoint detecta novo funcionário (FP001)
    │
    ├──► Criação de conta Google (se não existir via Workspace)
    │
    ├──► Atribuição a grupos organizacionais
    │       └── gcp-developers@fiqueok.com
    │
    ├──► Atribuição de roles IAM (por projeto)
    │       ├── Project: fiqueok-dev
    │       │   └── roles/viewer
    │       ├── Project: fiqueok-prod
    │       │   └── roles/bigquery.dataViewer
    │       └── Folder: /Finance
    │           └── roles/compute.viewer
    │
    └──► Provisionamento de Service Accounts (apenas para automação)
            └── sa-fp001@project.iam.gserviceaccount.com
```

### 9.4. Boas Práticas para GCP

| Boa Prática | Justificativa |
|-------------|---------------|
| Usar grupos do Google Workspace para permissões | Centraliza gestão de membros |OK|
| Evitar Service Accounts para usuários humanos | Prefira Identity-Aware Proxy (IAP) |OK|
| Usar hierarquia de recursos (Org → Folder → Project) | Governança escalável |OK|
| Provisionar acessos via grupos, não diretamente | Facilita recertificação |OK|
| Monitorar com Policy Intelligence | Identificar acessos excessivos |OK|

---

## 10. Estratégia de Correlação Multissistemas

### 10.1. Hierarquia de Correlação

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Estratégia de Correlação - 3 Níveis                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Nível 1 (Strong) - Identificador Único Corporativo                         │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  employeeID = personalNumber (midPoint)                                 ││
│  │                                                                          ││
│  │  Usado quando: RH publica employeeID e sistemas o suportam              ││
│  │  Aplicável para: AD (employeeID), SAP (BNAME), RACF (USERID)            ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                    │                                         │
│                                    ▼                                         │
│  Nível 2 (Medium) - E-mail Corporativo                                       │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  mail = email primário                                                  ││
│  │                                                                          ││
│  │  Usado quando: employeeID não disponível ou sistema não suporta         ││
│  │  Aplicável para: Keycloak, AWS, GCP, Exchange                           ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                    │                                         │
│                                    ▼                                         │
│  Nível 3 (Weak) - Nome + Sobrenome + Departamento                           │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  givenName + familyName + department                                    ││
│  │                                                                          ││
│  │  Usado quando: Outros atributos não disponíveis                         ││
│  │  Aplicável para: Sistemas legados sem estrutura de ID único             ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 10.2. Configuração de Correlation no midPoint

```xml
<correlation>
    <!-- Nível 1: employeeID (Strong) -->
    <correlationRule>
        <name>Correlacao_EmployeeID</name>
        <item>
            <source>
                <path>personalNumber</path>
            </source>
            <target>
                <path>employeeID</path>
            </target>
        </item>
        <item>
            <source>
                <path>mail</path>
            </source>
            <target>
                <path>mail</path>
            </target>
        </item>
    </correlationRule>
    
    <!-- Nível 2: E-mail (Medium) - usado apenas se Nível 1 falhar -->
    <correlationRule>
        <name>Correlacao_Email</name>
        <item>
            <source>
                <path>mail</path>
            </source>
            <target>
                <path>mail</path>
            </target>
        </item>
        <weight>50</weight>
    </correlationRule>
    
    <!-- Nível 3: Nome + Departamento (Weak) - alta chance de falso positivo -->
    <correlationRule>
        <name>Correlacao_Nome_Departamento</name>
        <item>
            <source>
                <path>givenName</path>
            </source>
            <target>
                <path>givenName</path>
            </target>
        </item>
        <item>
            <source>
                <path>familyName</path>
            </source>
            <target>
                <path>familyName</path>
            </target>
        </item>
        <item>
            <source>
                <path>costCenter</path>
            </source>
            <target>
                <path>costCenter</path>
            </target>
        </item>
        <weight>10</weight>
        <tier>3</tier>
    </correlationRule>
</correlation>
```

---

## 11. Governança e Ciclo de Vida (JML)

### 11.1. Ciclo de Vida JML (Joiner-Mover-Leaver)

| Fase | Evento | Ações do midPoint |
|------|--------|-------------------|
| **Joiner** | RH contrata ✅ | Criar usuário em AD, Keycloak, SAP, AWS, GCP |OK|
| **Mover** | RH transfere 🔄 | Ajustar grupos, permissões, cust center |OK|
| **Leaver** | RH desliga ❌ | Desabilitar AD, revogar acessos, arquivar |OK|

### 11.2. Política de Provisionamento por Sistema

| Sistema | Joiner | Mover | Leaver |
|---------|--------|-------|--------|
| **AD** | Create user, set attributes | Update groups, OU | Disable, move to OU "Disabled" |
| **Keycloak** | Create user, assign roles | Update groups | Disable, revoke sessions |
| **SAP** | Create user, assign profiles | Update roles | Lock, deactivate |
| **AWS** | Create IAM user, assign groups | Update policies | Delete access keys, disable |
| **GCP** | Create account, assign groups | Update roles | Disable, revoke |

### 11.3. Fluxo de Aprovação (Workflow)

```
Solicitação de acesso (midPoint Self-Service)
    │
    ▼
Aprovação do gestor (e-mail / GUI)
    │
    ▼
Aprovação do compliance (para acesso crítico)
    │
    ▼
midPoint executa provisionamento
    │
    ▼
Certificação periódica (recertificação a cada 6 meses)
```

---

## 12. Topologias de Implantação

### 12.1. Topologia On-Premises (Recomendada)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        INFRAESTRUTURA ON-PREMISES                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                    midPoint Cluster (HA)                                ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                     ││
│  │  │  midPoint   │  │  midPoint   │  │  PostgreSQL │                     ││
│  │  │  Node 1     │  │  Node 2     │  │  (HA)       │                     ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘                     ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│         │              │              │              │                      │
│         ▼              ▼              ▼              ▼                      │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐                │
│  │    AD     │  │ Keycloak  │  │   SAP     │  │  Shadow   │                │
│  │  (LDAP)   │  │  (SSO)    │  │  (RFC)    │  │   API     │                │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘                │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 12.2. Topologia Híbrida (Cloud + On-Prem)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           ON-PREMISES                                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                         │
│  │  midPoint   │  │     AD      │  │    SAP      │                         │
│  └──────┬──────┘  └─────────────┘  └─────────────┘                         │
│         │                                                                    │
│         │ 🔒 VPN / ExpressRoute                                             │
│         ▼                                                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                              CLOUD                                           │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                         midPoint Replica (DR)                           ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│         │              │              │                                     │
│         ▼              ▼              ▼                                     │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐                               │
│  │  Entra ID │  │    AWS    │  │    GCP    │                               │
│  │  (Cloud)  │  │  (Cloud)  │  │  (Cloud)  │                               │
│  └───────────┘  └───────────┘  └───────────┘                               │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 12.3. Segurança na Comunicação

| Conexão | Protocolo | Porta | Autenticação |
|---------|-----------|-------|--------------|
| midPoint → AD | LDAPS | 636 | Conta de serviço + certificado |
| midPoint → Keycloak | HTTPS | 8443 | Client ID + Secret + Bearer Token |
| midPoint → SAP | RFC/SNC | 3300 | Usuário técnico + certificado |
| midPoint → AWS | HTTPS | 443 | Access Key + Secret Key |
| midPoint → GCP | HTTPS | 443 | Service Account + JWT |

---

## 13. Requisitos de Segurança

### 13.1. Controles Obrigatórios

| Controle | Descrição | Aplicável a |
|----------|-----------|-------------|
| **Autenticação forte** | MFA para administradores do midPoint | Todos |
| **TLS/mTLS** | Criptografia de todas as comunicações | AD, Keycloak, AWS, GCP |
| **Segregação de contas** | Contas de serviço dedicadas por sistema | AD, SAP, AWS, GCP |
| **Auditoria** | Log de todas as ações de provisionamento | Todos |
| **Menor privilégio** | Contas de serviço com permissões mínimas | Todos |

### 13.2. Exemplo: Contas de Serviço

| Sistema | Conta | Permissões Mínimas |
|---------|-------|-------------------|
| **AD** | `svc_midpoint` | Criar/alterar usuários, resetar senha, mover OUs |
| **Keycloak** | `midpoint-client` | `manage-users`, `view-users`, `manage-clients` |
| **SAP** | `MIDPOINT_USER` | `S_USER_GRP`, `S_USER_PRO`, `S_USER_AUT` |
| **AWS** | `midpoint-iam-role` | `iam:CreateUser`, `iam:AttachGroupPolicy` |
| **GCP** | `midpoint-sa@project.iam` | `iam.serviceAccountAdmin`, `resourcemanager.projectIamAdmin` |

### 13.3. Compliance

| Framework | Controles aplicáveis | Implementação |
|-----------|---------------------|---------------|
| **ISO 27001** | A.5.15, A.8.12, A.8.15, A.9.2 | OK |
| **NIST SP 800-53** | AC-2, AC-3, AC-5, AU-2 | OK |
| **SOX** | Segregação de deveres, Auditoria | OK |
| **LGPD** | Art. 6, Art. 46 | OK |

---

## 14. Checklist de Validação

### 14.1. Pré-Integração

| # | Verificação | Comando/Procedimento |
|---|-------------|----------------------|
| P01 | Conector instalado | `ls /opt/midpoint/var/connid-connectors/` |
| P02 | Conta de serviço criada | Verificar no sistema alvo |
| P03 | Conectividade de rede | `telnet target 389` |
| P04 | Certificados TLS válidos | `openssl s_client -connect target:636` |
| P05 | Test Connection OK | GUI do resource → Test connection |

### 14.2. Pós-Integração

| # | Verificação | Comando/Procedimento |
|---|-------------|----------------------|
| R01 | Resource ativo | `curl /resources` |
| R02 | Correlação funcionando | Executar tarefa de reconciliação |
| R03 | Provisionamento OK | Verificar usuário criado no target |
| R04 | Logs sem erros | `grep -i error /opt/midpoint/var/log/idm.log` |
| R05 | Auditoria registrando | `curl /audit` |

---

## 15. Resolução de Problemas

| Problema | Causa Provável | Solução |
|----------|----------------|---------|
| **Test Connection falha** | Conta inválida, firewall | Verificar credenciais, portas |
| **Erro de correlação** | Atributos não mapeados | Configurar correlation rules |
| **Provisionamento não executa** | Synchronization mal configurada | Verificar Unmatched → addFocus |
| **Timeout** | Rede lenta, target sobrecarregado | Aumentar timeouts, revisar rede |
| **Usuários duplicados** | Falha na correlação | Revisar atributos de correlação |

---

## 16. Lições Aprendidas (Living Lab)

| # | Lição | Aplicabilidade |
|---|-------|----------------|
| L01 | Use `employeeID` como chave de correlação primária | Todos os sistemas |
| L02 | NUNCA provisione senhas (use fluxo de reset) | SAP, AD, Keycloak |
| L03 | Prefira grupos a permissões diretas | AWS, GCP, AD |
| L04 | Documente o mapeamento de atributos | Todos |
| L05 | Teste com dataset pequeno antes do bulk | Todos |

---

## 17. Anexos: Scripts e Configurações

### 17.1. Script de Teste de Conectividade (AD)

```bash
#!/bin/bash
# test_ad_connection.sh
ldapsearch -H ldap://ad.fiqueok.local:389 \
  -D "CN=svc_midpoint,OU=Service Accounts,DC=fiqueok,DC=local" \
  -w "P@ssw0rd" \
  -b "DC=fiqueok,DC=local" \
  -s base
```

### 17.2. Script de Teste de Conectividade (Keycloak)

```bash
#!/bin/bash
# test_keycloak_connection.sh
TOKEN=$(curl -s -X POST \
  "http://keycloak:8080/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=admin-cli" \
  -d "username=admin" \
  -d "password=admin" \
  -d "grant_type=password" | jq -r '.access_token')

curl -s -H "Authorization: Bearer $TOKEN" \
  "http://keycloak:8080/admin/realms/fiqueok/users"
```

### 17.3. Script de Teste de Conectividade (AWS)

```bash
#!/bin/bash
# test_aws_connection.sh
aws sts get-caller-identity --profile midpoint
```

### 17.4. Script de Teste de Conectividade (GCP)

```bash
#!/bin/bash
# test_gcp_connection.sh
gcloud auth application-default login --impersonate-service-account=midpoint-sa@project.iam
gcloud projects list
```

---

## 18. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | Maio/2026 | Paulo Feitosa Lima | Documento inicial. Arquitetura de referência para integrações com AD, Entra ID, Keycloak, SAP, AWS e GCP. Incluídas estratégias de correlação, topologias de implantação, requisitos de segurança e lições do Living Lab Fiqueok. |

---

**Fim do Documento**

---

*Arquitetura de Referência IGA - midPoint 4.10*  
*Living Lab Fiqueok*  
*Arquivado em: `FiqueokBrain/PRJ022/Arquitetura-Referencia-IGA-midPoint-v1.0.md`*