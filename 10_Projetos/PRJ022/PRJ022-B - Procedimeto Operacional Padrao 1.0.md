
## Procedimento Operacional Padrão (POP) - 
## Spike Técnico: ScriptedSQL+HTTP para Consumo Direto da Shadow API

**Versão:** 1.0  
**Data:** Maio/2026  
**Status:** 📝 **EM EXECUÇÃO** — Spike técnico para validação do Caminho 2  
**Responsável:** Paulo Feitosa Lima  
**Auditoria:** ISO 27001, NIST SP 800-53, CIS Controls, PCI-DSS, SOX, LGPD  
**Tentativas Máximas:** 3 (Três) — Após 3 falhas consecutivas, o spike é ABORTADO e o PRJ022-A (CSV) torna-se solução final definitiva.

---

## ÍNDICE

1. [Objetivo do Documento](#1-objetivo-do-documento)
2. [Arquitetura da Solução (Spike)](#2-arquitetura-da-solução-spike)
3. [Conceitos Fundamentais](#3-conceitos-fundamentais)
4. [Pré-Requisitos Obrigatórios](#4-pré-requisitos-obrigatórios)
5. [Verificação do PRJ022-A (Baseline Funcional)](#5-verificação-do-prj022-a-baseline-funcional)
6. [Procedimento de Rollback para PRJ022-A](#6-procedimento-de-rollback-para-prj022-a)
7. [Método 1: ScriptedSQL com H2 em Memória (Recomendado)](#7-método-1-scriptedsql-com-h2-em-memória-recomendado)
8. [Método 2: ScriptedSQL com PostgreSQL Local (Alternativo)](#8-método-2-scriptedsql-com-postgresql-local-alternativo)
9. [Método 3: ScriptedSQL com Arquivo CSV Dummy (Última Alternativa)](#9-método-3-scriptedsql-com-arquivo-csv-dummy-última-alternativa)
10. [Configuração dos Scripts Groovy](#10-configuração-dos-scripts-groovy)
11. [Configuração do Resource no midPoint](#11-configuração-do-resource-no-midpoint)
12. [Configuração da Correlation e Synchronization](#12-configuração-da-correlation-e-synchronization)
13. [Criação da Tarefa de Reconciliação](#13-criação-da-tarefa-de-reconciliação)
14. [Execução e Validação do Spike](#14-execução-e-validação-do-spike)
15. [Matriz de Decisão - 3 Tentativas](#15-matriz-de-decisão---3-tentativas)
16. [Checklist de Verificação Pós-Spike](#16-checklist-de-verificação-pós-spike)
17. [Resolução de Problemas Comuns](#17-resolução-de-problemas-comuns)
18. [Lições Aprendidas (PRJ022-B)](#18-lições-aprendidas-prj022-b)
19. [Anexos: Comandos de Diagnóstico](#19-anexos-comandos-de-diagnóstico)
20. [Histórico de Versões](#20-histórico-de-versões)

---

## 1. Objetivo do Documento

Este Procedimento Operacional Padrão (POP) descreve o **Spike Técnico (PRJ022-B)** para validar a viabilidade de conexão direta entre o **midPoint 4.10** e a **Shadow API (PRJ008)** utilizando o **ScriptedSQL Connector** como veículo para executar chamadas HTTP via Groovy.

### 1.1. Objetivos do Spike

| # | Objetivo | Critério de Sucesso |
|---|----------|---------------------|
| 1 | Estabelecer conexão HTTP do midPoint à Shadow API | `Test Connection` retorna OK |
| 2 | Executar `GET /employees` via Script Groovy | Retorna JSON com 102 funcionários |
| 3 | Mapear atributos do JSON para atributos do midPoint | Schema descoberto corretamente |
| 4 | Realizar correlação por `employee_id` | Usuários existentes são encontrados |
| 5 | Executar reconciliação com sucesso | Usuários criados/atualizados no repositório |

### 1.2. Regra das 3 Tentativas

**Este spike tem limite máximo de 3 (três) tentativas consecutivas.**

| Tentativa | Ação em caso de falha |
|-----------|----------------------|
| **Tentativa 1** | Documentar erro, ajustar configuração, reexecutar |
| **Tentativa 2** | Documentar erro, trocar de método (Método 1 → 2 → 3), reexecutar |
| **Tentativa 3** | Documentar erro, **ABORTAR SPIKE**, aceitar PRJ022-A como solução final |

**Após 3 falhas, o PRJ022-A (CSV) torna-se a solução definitiva e os recursos do spike devem ser removidos do midPoint.**

---

## 2. Arquitetura da Solução (Spike)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           SPIKE TÉCNICO PRJ022-B - SCRIPTEDSQL+HTTP                  │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  ┌─────────────────┐     ┌─────────────────────────────────────────────────────────┐│
│  │   Shadow API    │     │                    midPoint 4.10 (iga-gf-02)            ││
│  │ (api-gf-01:8000)│     │                                                         ││
│  │  xxx.xxx.xxx.xxx  │     │  ┌─────────────────────────────────────────────────────┐││
│  └────────┬────────┘     │  │              ScriptedSQL Connector                   │││
│           │              │  │  ┌─────────────────────────────────────────────────┐│││
│           │ HTTP GET     │  │  │           JDBC Dummy (H2 em memória)            ││││
│           │ X-API-KEY    │  │  │  ┌─────────────────────────────────────────────┐││││
│           ▼              │  │  │  │         SearchScript.groovy                  │││││
│  ┌─────────────────┐     │  │  │  │  ┌─────────────────────────────────────────┐│││││
│  │   GET /employees │─────┼──┼──┼──┼─▶│  java.net.http.HttpClient              ││││││
│  │   JSON Response  │     │  │  │  │  │  GET http://xxx.xxx.xxx.xxx:8000/employees ││││││
│  │   (102 itens)    │◄────┼──┼──┼──┼─▶│  Header: X-API-KEY                     ││││││
│  └─────────────────┘     │  │  │  │  │  Parse JSON → Map<String, Object>        ││││││
│                           │  │  │  └─────────────────────────────────────────────┘││││
│                           │  │  └─────────────────────────────────────────────────┘│││
│                           │  └─────────────────────────────────────────────────────┘││
│                           │                          │                              ││
│                           │                          ▼                              ││
│                           │  ┌─────────────────────────────────────────────────────┐││
│                           │  │            Schema Handling (Object Type)            │││
│                           │  │  ┌─────────────────────────────────────────────────┐│││
│                           │  │  │ Mappings: employee_id → name/personalNumber     ││││
│                           │  │  │ Correlation: employee_id → personalNumber       ││││
│                           │  │  │ Synchronization: Unmatched → addFocus           ││││
│                           │  │  └─────────────────────────────────────────────────┘│││
│                           │  └─────────────────────────────────────────────────────┘││
│                           │                          │                              ││
│                           │                          ▼                              ││
│                           │  ┌─────────────────────────────────────────────────────┐││
│                           │  │            Repositório Focus (Users)                │││
│                           │  │            (102 usuários criados/atualizados)       │││
│                           │  └─────────────────────────────────────────────────────┘││
│                           └─────────────────────────────────────────────────────────┘│
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Conceitos Fundamentais

### 3.1. O que é o ScriptedSQL Connector?

O **ScriptedSQL Connector** é um conector ICF (Identity Connector Framework) bundled no midPoint que permite executar scripts Groovy para acessar dados de qualquer fonte que possua uma conexão JDBC.

**No contexto deste spike:** Usaremos o ScriptedSQL não para acessar um banco de dados real, mas como um **"veículo"** para executar código Groovy que faz chamadas HTTP à Shadow API.

### 3.2. Por que JDBC Dummy?

O ScriptedSQL connector **exige** uma conexão JDBC configurada para inicializar, mesmo que não seja utilizada. Usaremos um banco H2 em memória como **JDBC dummy**:

- **H2 Database:** Banco Java embutido, leve, não persiste dados
- **URL:** `jdbc:h2:mem:dummy;DB_CLOSE_DELAY=-1`
- **Driver:** `org.h2.Driver`

### 3.3. Como Funciona o Fluxo?

```
Tarefa de Reconciliação
         │
         ▼
ScriptedSQL Connector
         │
         ├──► SchemaScript.groovy (define os atributos esperados)
         │
         └──► SearchScript.groovy (executa HTTP GET na Shadow API)
                   │
                   ├──► java.net.http.HttpClient
                   ├──► X-API-KEY header
                   ├──► Parse JSON com JsonSlurper
                   └──► handler(attributes) → retorna ao midPoint
         │
         ▼
midPoint processa os atributos → Correlation → Synchronization → User
```

### 3.4. Métodos de Implementação do Spike

Este POP documenta **3 métodos diferentes** para implementar o spike, em ordem decrescente de recomendação:

| Método | Descrição | Complexidade | Chance de Sucesso |
|--------|-----------|--------------|-------------------|
| **Método 1** | H2 em memória (JDBC dummy) + Groovy puro | Baixa | 75% |
| **Método 2** | PostgreSQL local (tabela vazia) + Groovy | Média | 65% |
| **Método 3** | CSV dummy como fonte + Groovy para HTTP | Alta | 50% |

**Recomendação:** Iniciar pelo **Método 1**. Se falhar na Tentativa 1, avançar para o Método 2 na Tentativa 2. Se falhar novamente, Método 3 na Tentativa 3.

---

## 4. Pré-Requisitos Obrigatórios

| # | Pré-Requisito | Verificação | Critério |
|---|---------------|-------------|----------|
| PR-01 | PRJ022-A funcionando (CSV) | `sudo wc -l /srv/iga-project/data/midpoint/hr_export.csv` | 103 linhas |
| PR-02 | Shadow API operacional | `curl -H "X-API-KEY: Fiqueok-Security-Token-2026" http://127.0.0.1:8000/employees \| jq '. \| length'` | 102 |
| PR-03 | midPoint 4.10 operacional | `sudo docker ps \| grep midpoint` | Container running |
| PR-04 | Container tem acesso à rede da Shadow API | `sudo docker exec iga-midpoint curl -s -o /dev/null -w "%{http_code}" http://xxx.xxx.xxx.xxx:8000/employees` | 200 |
| PR-05 | Snapshot do PRJ022-A criado | `Get-VMSnapshot -VMName "iga-gf-02" \| grep PRJ022-A` | Snapshot existe |
| PR-06 | Scripts Groovy preparados | `ls -la /srv/iga-project/data/midpoint/scripts/` | SchemaScript.groovy e SearchScript.groovy |
| PR-07 | JDBC driver H2 disponível | `sudo docker exec iga-midpoint ls /opt/midpoint/var/connid-connectors/ \| grep h2` | h2 jar existe |
| PR-08 | Variável SHADOW_API_KEY configurada | `sudo docker exec iga-midpoint env \| grep SHADOW_API_KEY` | Variável definida |

---

## 5. Verificação do PRJ022-A (Baseline Funcional)

**CRÍTICO:** Antes de iniciar qualquer configuração do spike, verifique se o PRJ022-A está funcionando. Esta é a baseline para rollback.

### 5.1. Verificar CSV no Host

```bash
# [iga-gf-02]$
sudo wc -l /srv/iga-project/data/midpoint/hr_export.csv
# Deve mostrar: 103 /srv/iga-project/data/midpoint/hr_export.csv

sudo head -5 /srv/iga-project/data/midpoint/hr_export.csv
# Deve mostrar cabeçalho + 4 linhas de dados
```

### 5.2. Verificar CSV no Container

```bash
# [iga-gf-02]$
sudo docker exec iga-midpoint wc -l /opt/midpoint/var/hr_export.csv
# Deve mostrar: 103 /opt/midpoint/var/hr_export.csv
```

### 5.3. Verificar Resource CSV

```bash
# [iga-gf-02]$
# Via API do midPoint (substituir senha)
curl -u administrator:'M1dP0!ntAdm!n#2026' \
  http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/resources \
  | jq '.[] | select(.name=="Fiqueok HR (Shadow API CSV)") | .name'
# Deve retornar o nome do resource
```

### 5.4. Verificar Usuários Criados

```bash
# [iga-gf-02]$
curl -u administrator:'M1dP0!ntAdm!n#2026' \
  http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/users?size=10 \
  | jq '.users[] | .name'
# Deve mostrar usuários como "0001", "FP001", etc.
```

### 5.5. Registrar Estado Atual

```bash
# Criar arquivo de baseline
cat > /tmp/prj022-a-baseline.txt << EOF
Data: $(date)
CSV Host Lines: $(sudo wc -l /srv/iga-project/data/midpoint/hr_export.csv)
CSV Container Lines: $(sudo docker exec iga-midpoint wc -l /opt/midpoint/var/hr_export.csv)
Usuários no midPoint: $(curl -s -u administrator:'M1dP0!ntAdm!n#2026' http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/users?size=1000 | jq '.users | length')
EOF

cat /tmp/prj022-a-baseline.txt
```

---

## 6. Procedimento de Rollback para PRJ022-A

### 6.1. Rollback Rápido (Restaurar Resource CSV)

Se o spike falhar e precisar restaurar o funcionamento do PRJ022-A:

```bash
# [iga-gf-02]$

# 1. Desativar o Resource do spike (se existir)
# Via GUI: Resources → Fiqueok Shadow API (ScriptedSQL) → Lifecycle state → "Proposed"

# 2. Reativar o Resource CSV
# Via GUI: Resources → Fiqueok HR (Shadow API CSV) → Lifecycle state → "Active"

# 3. Verificar se o CSV ainda está íntegro
sudo docker exec iga-midpoint wc -l /opt/midpoint/var/hr_export.csv

# 4. Executar tarefa de reconciliação do CSV
# Via GUI: Resources → Fiqueok HR (Shadow API CSV) → Defined Tasks → Reconciliacao CSV PRJ022 → Run now
```

### 6.2. Rollback Completo (Via Snapshot)

Se o spike causar danos ao ambiente:

```powershell
# [WinHost]$ (PowerShell como Administrador)

# Restaurar snapshot do PRJ022-A
Restore-VMSnapshot -VMName "iga-gf-02" -Name "PRJ022-A-Antes-Configuracao" -Confirm:$false

# Iniciar a VM
Start-VM -Name "iga-gf-02"

# Aguardar midPoint iniciar (cerca de 2 minutos)
ping -n 120 xxx.xxx.xxx.xxx > $null
```

### 6.3. Verificação Pós-Rollback

```bash
# [iga-gf-02]$
# Verificar CSV
sudo docker exec iga-midpoint wc -l /opt/midpoint/var/hr_export.csv

# Verificar Resource CSV ativo
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/resources \
  | jq '.[] | select(.lifecycleState=="ACTIVE") | .name'
```

---

## 7. Método 1: ScriptedSQL com H2 em Memória (Recomendado)

### 7.1. Verificar Disponibilidade do H2 Driver

```bash
# [iga-gf-02]$
# Verificar se o H2 driver já existe no midPoint
sudo docker exec iga-midpoint find /opt/midpoint -name "*h2*.jar" 2>/dev/null

# Se não existir, baixar o H2 driver
sudo docker exec iga-midpoint wget -O /opt/midpoint/var/connid-connectors/h2-2.2.224.jar \
  https://repo1.maven.org/maven2/com/h2database/h2/2.2.224/h2-2.2.224.jar

# Ajustar permissões
sudo docker exec iga-midpoint chmod 644 /opt/midpoint/var/connid-connectors/h2-2.2.224.jar
```

### 7.2. Configurar JDBC Dummy (H2)

A configuração do JDBC dummy será feita diretamente no Resource XML.

### 7.3. Vantagens do Método 1

| Aspecto | Benefício |
|---------|-----------|
| **Leveza** | H2 roda em memória, sem persistência |
| **Isolamento** | Não afeta outros Resources |
| **Simplicidade** | Não requer banco de dados adicional |

---

## 8. Método 2: ScriptedSQL com PostgreSQL Local (Alternativo)

### 8.1. Criar Tabela Dummy no PostgreSQL

```bash
# [iga-gf-02]$
# Criar banco de dados dummy
sudo docker exec -i iga-postgres psql -U midpoint_user -d midpoint << EOF
CREATE SCHEMA IF NOT EXISTS dummy;
CREATE TABLE IF NOT EXISTS dummy.employees (
    id SERIAL PRIMARY KEY,
    employee_id VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100)
);
TRUNCATE dummy.employees;
INSERT INTO dummy.employees (employee_id, first_name, last_name) VALUES ('dummy', 'Dummy', 'User');
EOF
```

### 8.2. Configurar JDBC Connection

```bash
# [iga-gf-02]$
# Verificar conexão
sudo docker exec iga-midpoint java -cp /opt/midpoint/var/connid-connectors/postgresql-42.7.3.jar \
  org.postgresql.Driver jdbc:postgresql://postgres:5432/midpoint?user=midpoint_user
```

### 8.3. Quando Usar o Método 2

- Se o H2 driver não puder ser adicionado ao midPoint
- Se houver problemas de compatibilidade do H2 com o midPoint 4.10
- Se precisar de persistência para depuração

---

## 9. Método 3: ScriptedSQL com Arquivo CSV Dummy (Última Alternativa)

### 9.1. Criar CSV Dummy

```bash
# [iga-gf-02]$
# Criar CSV dummy com uma linha
cat > /tmp/dummy.csv << 'EOF'
id,employee_id,first_name,last_name
1,dummy,Dummy,User
EOF

# Copiar para o container
sudo docker cp /tmp/dummy.csv iga-midpoint:/opt/midpoint/var/dummy.csv
```

### 9.2. Configurar CSV Connector como Base

Neste método, usamos o CsvConnector para ler o CSV dummy (1 linha) e o ScriptedSQL para fazer a chamada HTTP real.

### 9.3. Quando Usar o Método 3

- Se ambos os métodos anteriores falharem
- Se houver problemas de classe no ClassLoader do midPoint
- **Última tentativa antes de abortar o spike**

---

## 10. Configuração dos Scripts Groovy

### 10.1. Criar Diretório de Scripts

```bash
# [iga-gf-02]$
sudo mkdir -p /srv/iga-project/data/midpoint/scripts
sudo chown paulo:paulo /srv/iga-project/data/midpoint/scripts
```

### 10.2. SchemaScript.groovy

```bash
# [iga-gf-02]$
cat > /srv/iga-project/data/midpoint/scripts/SchemaScript.groovy << 'EOF'
// SchemaScript.groovy
// Define os atributos que o midPoint espera receber da Shadow API
import org.identityconnectors.framework.common.objects.*

def schema = new Schema()

def empNumber = new AttributeInfoBuilder() {
    setName("emp_number")
    setType(Integer.class)
    setRequired(true)
    setCreateable(false)
    setUpdateable(false)
}.build()

def employeeId = new AttributeInfoBuilder() {
    setName("employee_id")
    setType(String.class)
    setRequired(true)
    setCreateable(false)
    setUpdateable(false)
}.build()

def firstName = new AttributeInfoBuilder() {
    setName("first_name")
    setType(String.class)
    setRequired(false)
    setCreateable(false)
    setUpdateable(false)
}.build()

def lastName = new AttributeInfoBuilder() {
    setName("last_name")
    setType(String.class)
    setRequired(true)
    setCreateable(false)
    setUpdateable(false)
}.build()

schema.defineAttribute(empNumber)
schema.defineAttribute(employeeId)
schema.defineAttribute(firstName)
schema.defineAttribute(lastName)

def objectClassInfo = new ObjectClassInfoBuilder() {
    setType(ObjectClass.ACCOUNT_NAME)
    addAllAttributeInfo(schema.getAttributeInfo())
}.build()

schema.defineObjectClass(objectClassInfo)
return schema
EOF
```

### 10.3. SearchScript.groovy

```bash
# [iga-gf-02]$
cat > /srv/iga-project/data/midpoint/scripts/SearchScript.groovy << 'EOF'
// SearchScript.groovy
// Busca todos os funcionários na Shadow API via HTTP GET
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.net.URI
import java.time.Duration
import groovy.json.JsonSlurper

def SHADOW_API_URL = "http://xxx.xxx.xxx.xxx:8000/employees"
def API_KEY = System.getenv("SHADOW_API_KEY")

if (!API_KEY) {
    throw new RuntimeException("SHADOW_API_KEY environment variable not set")
}

def client = HttpClient.newBuilder()
    .connectTimeout(Duration.ofSeconds(5))
    .build()

def request = HttpRequest.newBuilder()
    .uri(URI.create(SHADOW_API_URL))
    .timeout(Duration.ofSeconds(10))
    .header("X-API-KEY", API_KEY)
    .header("Accept", "application/json")
    .GET()
    .build()

try {
    def response = client.send(request, HttpResponse.BodyHandlers.ofString())
    
    if (response.statusCode() != 200) {
        throw new RuntimeException("HTTP ${response.statusCode()}: Falha ao acessar Shadow API")
    }
    
    def jsonSlurper = new JsonSlurper()
    def employees = jsonSlurper.parseText(response.body())
    
    employees.each { emp ->
        def attributes = [
            "emp_number": emp.emp_number,
            "employee_id": emp.employee_id,
            "first_name": emp.first_name,
            "last_name": emp.last_name
        ]
        handler(attributes)
    }
    
} catch (Exception e) {
    throw new RuntimeException("Erro no SearchScript: ${e.message}", e)
}
EOF
```

### 10.4. Copiar Scripts para o Container

```bash
# [iga-gf-02]$
sudo docker cp /srv/iga-project/data/midpoint/scripts/SchemaScript.groovy iga-midpoint:/opt/midpoint/var/scripts/
sudo docker cp /srv/iga-project/data/midpoint/scripts/SearchScript.groovy iga-midpoint:/opt/midpoint/var/scripts/
```

### 10.5. Configurar Variável de Ambiente SHADOW_API_KEY

```bash
# [iga-gf-02]$
# Editar docker-compose.yml para adicionar a variável
sudo nano /srv/iga-project/docker-compose.yml

# Adicionar na seção environment do midpoint:
#   SHADOW_API_KEY: 'Fiqueok-Security-Token-2026'

# Exemplo:
#   midpoint:
#     environment:
#       MP_SET_midpoint_repository_jdbcUrl: 'jdbc:postgresql://postgres:5432/midpoint?user=midpoint_user&password=P0stgr3sS3cur3#2026!'
#       SHADOW_API_KEY: 'Fiqueok-Security-Token-2026'

# Reiniciar o container
sudo docker compose -f /srv/iga-project/docker-compose.yml down
sudo docker compose -f /srv/iga-project/docker-compose.yml up -d

# Aguardar inicialização (cerca de 30 segundos)
sleep 30

# Verificar variável
sudo docker exec iga-midpoint env | grep SHADOW_API_KEY
```

---

## 11. Configuração do Resource no midPoint

### 11.1. Criar Novo Resource com ScriptedSQL

1. Acessar `http://xxx.xxx.xxx.xxx:8080/midpoint`
2. **Resources** → **All resources** → **New resource**
3. **Create from scratch** → Selecione **ScriptedSQLConnector**

### 11.2. Configuração do Resource (XML)

Após criar o resource básico, edite o XML diretamente:

1. No resource, clique em **Edit raw** (ícone de código)
2. Substitua o conteúdo pelo XML abaixo:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<resource xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
          xmlns:c="http://midpoint.evolveum.com/xml/ns/public/connector/icf-1/connector-schema-3"
          xmlns:q="http://prism.evolveum.com/xml/ns/public/query-3"
          xmlns:ri="http://midpoint.evolveum.com/xml/ns/public/resource/instance-3">

    <name>Fiqueok Shadow API (Spike ScriptedSQL)</name>
    <description>Spike técnico - Conexão direta à Shadow API via ScriptedSQL+HTTP</description>
    <lifecycleState>proposed</lifecycleState>

    <connectorRef oid="c89f121b-f6a3-483e-9300-91b91bbe06f5"/>

    <connectorConfiguration>
        <groovyScripts>
            <schemaScript>
                <source>
                    <include>SchemaScript.groovy</include>
                </source>
            </schemaScript>
            <searchScript>
                <source>
                    <include>SearchScript.groovy</include>
                </source>
            </searchScript>
        </groovyScripts>

        <connection>
            <driverClassName>org.h2.Driver</driverClassName>
            <url>jdbc:h2:mem:dummy;DB_CLOSE_DELAY=-1</url>
            <username>sa</username>
            <password></password>
        </connection>
    </connectorConfiguration>

    <schemaHandling>
        <objectType>
            <kind>account</kind>
            <intent>employee</intent>
            <displayName>Colaborador Shadow API</displayName>

            <attribute>
                <ref>employee_id</ref>
                <inbound>
                    <strength>strong</strength>
                    <target>
                        <path>name</path>
                    </target>
                </inbound>
                <inbound>
                    <strength>strong</strength>
                    <target>
                        <path>personalNumber</path>
                    </target>
                </inbound>
            </attribute>

            <attribute>
                <ref>first_name</ref>
                <inbound>
                    <target>
                        <path>givenName</path>
                    </target>
                </inbound>
            </attribute>

            <attribute>
                <ref>last_name</ref>
                <inbound>
                    <target>
                        <path>familyName</path>
                    </target>
                </inbound>
            </attribute>

            <correlation>
                <correlationRule>
                    <name>Correlacao_employee_id</name>
                    <item>
                        <source>
                            <path>employee_id</path>
                        </source>
                        <target>
                            <path>personalNumber</path>
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

### 11.3. Salvar e Testar Conexão

1. Clique em **Save**
2. Volte para o resource e clique em **Test connection**
3. Deve retornar **Success**

---

## 12. Configuração da Correlation e Synchronization

### 12.1. Verificar Configurações

Após salvar o XML, verifique no GUI:

1. **Schema handling** → Clique no Object Type
2. **Mappings:** Deve ter 4 mapeamentos (employee_id → name, employee_id → personalNumber, first_name → givenName, last_name → familyName)
3. **Correlation:** Deve ter regra `Correlacao_employee_id` com item `employee_id → personalNumber`
4. **Synchronization:** Deve ter reação `Unmatched → addFocus`

### 12.2. Ajustes Manuais (se necessário)

Se algum mapeamento estiver faltando, configure manualmente conforme o PRJ022-A (POP v1.4, Passos 11 e 12).

---

## 13. Criação da Tarefa de Reconciliação

### 13.1. Criar Nova Tarefa

1. **Resources** → **Fiqueok Shadow API (Spike ScriptedSQL)** → **Defined Tasks**
2. **Create task** → **Reconciliation Task**
3. **Nome:** `Spike ScriptedSQL - Tentativa 1`

### 13.2. Configurar a Tarefa

| Aba | Campo | Valor |
|-----|-------|-------|
| Basic | Name | `Spike ScriptedSQL - Tentativa 1` |
| Basic | Description | `Spike técnico - Tentativa 1 (Método 1 - H2)` |
| Activity | Resource | `Fiqueok Shadow API (Spike ScriptedSQL)` |
| Activity | Kind | `Account` |
| Activity | Intent | `employee` |
| Schedule | No schedule | ✅ Marcar |

### 13.3. Salvar e Executar

Clique em **Save & Run**

---

## 14. Execução e Validação do Spike

### 14.1. Monitorar Logs

```bash
# [iga-gf-02]$
sudo docker logs -f iga-midpoint --tail 50
```

### 14.2. Verificar Sucesso

**Critérios de sucesso do spike:**

| # | Critério | Verificação |
|---|----------|-------------|
| 1 | Tarefa conclui com status CLOSED | GUI mostra 100% |
| 2 | Objetos processados = 102 | Operation statistics mostra 102 |
| 3 | Sucessos = 102 | Nenhum erro na tarefa |
| 4 | Usuários criados no repositório | Users lista os 102 funcionários |
| 5 | Nenhum erro de correlação | Logs sem "No correlator configurations" |

### 14.3. Verificação Rápida

```bash
# [iga-gf-02]$
# Contar usuários criados pelo spike
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/users?size=1000" \
  | jq '.users[] | select(.name | test("^[0-9]{4}$|^FP[0-9]{3}$")) | .name' \
  | wc -l
# Deve mostrar: 102
```

---

## 15. Matriz de Decisão - 3 Tentativas

### 15.1. Fluxo de Decisão

```
┌─────────────────────────────────────────────────────────────────┐
│                    INÍCIO DO SPIKE PRJ022-B                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Tentativa 1: Método 1 (H2 em memória)                          │
│  Critério: Test Connection OK + Tarefa processa 102 objetos     │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              │                               │
              ▼                               ▼
        ✅ SUCESSO                        ❌ FALHA
              │                               │
              ▼                               ▼
    ┌─────────────────┐             ┌─────────────────────────────┐
    │ SPIKE CONCLUÍDO │             │ Registrar erro               │
    │ PRJ022-B ✅     │             │ Tentativa 2: Método 2 (PG)   │
    └─────────────────┘             └─────────────────────────────┘
                                              │
                              ┌───────────────┴───────────────┐
                              │                               │
                              ▼                               ▼
                        ✅ SUCESSO                        ❌ FALHA
                              │                               │
                              ▼                               ▼
                    ┌─────────────────┐             ┌─────────────────────────────┐
                    │ SPIKE CONCLUÍDO │             │ Registrar erro               │
                    │ PRJ022-B ✅     │             │ Tentativa 3: Método 3 (CSV)  │
                    └─────────────────┘             └─────────────────────────────┘
                                                                  │
                                                  ┌───────────────┴───────────────┐
                                                  │                               │
                                                  ▼                               ▼
                                            ✅ SUCESSO                        ❌ FALHA
                                                  │                               │
                                                  ▼                               ▼
                                        ┌─────────────────┐             ┌─────────────────────────────┐
                                        │ SPIKE CONCLUÍDO │             │ SPIKE ABORTADO               │
                                        │ PRJ022-B ✅     │             │ PRJ022-D ativado             │
                                        └─────────────────┘             │ CSV = solução final         │
                                                                        └─────────────────────────────┘
```

### 15.2. Registro de Tentativas

| Tentativa | Data | Método | Resultado | Erro (se aplicável) | Ação Tomada |
|-----------|------|--------|-----------|---------------------|-------------|
| 1 | ___/___/2026 | Método 1 (H2) | ⬜ Pendente | | |
| 2 | ___/___/2026 | Método 2 (PG) | ⬜ Pendente | | |
| 3 | ___/___/2026 | Método 3 (CSV) | ⬜ Pendente | | |

### 15.3. Termo de Abortamento do Spike

Caso as 3 tentativas falhem, preencher e anexar ao relatório:

```markdown
## TERMO DE ABORTAMENTO DO SPIKE PRJ022-B

Eu, Paulo Feitosa Lima, na qualidade de Responsável Técnico do Living Lab Fiqueok,
DECLARO que o spike técnico PRJ022-B (ScriptedSQL+HTTP) foi executado em 3 (três)
tentativas conforme documentado no POP PRJ022-B v1.0, todas resultando em FALHA.

Registro das tentativas:
- Tentativa 1 (Método 1 - H2): FALHA - Erro: _________________________
- Tentativa 2 (Método 2 - PostgreSQL): FALHA - Erro: _________________________
- Tentativa 3 (Método 3 - CSV dummy): FALHA - Erro: _________________________

Com base na decisão arquitetural documentada no PRJ022 - Relatório de Análise Técnica,
o PRJ022-D (CSV como fallback oficial) é ATIVADO como solução final definitiva.

O recurso "Fiqueok Shadow API (Spike ScriptedSQL)" será removido do midPoint,
e o ambiente será restaurado para o estado funcional do PRJ022-A.

Data: ___/___/2026
Assinatura: _________________
```

---

## 16. Checklist de Verificação Pós-Spike

### 16.1. Em Caso de Sucesso do Spike

| # | Verificação | Comando | Status |
|---|-------------|---------|--------|
| S01 | Tarefa concluída com sucesso | `sudo docker logs iga-midpoint --tail 100 \| grep "Completed.*reconciliation"` | ⬜ |
| S02 | 102 objetos processados | GUI → Operation statistics → Resource objects processed = 102 | ⬜ |
| S03 | 102 usuários criados/atualizados | `curl ... \| jq '.users \| length'` | ⬜ |
| S04 | Shadow API acessada via HTTP | `sudo docker logs iga-midpoint \| grep "GET /employees"` | ⬜ |
| S05 | Resource pode ser reutilizado em PRJ022-C | Test connection OK | ⬜ |

### 16.2. Em Caso de Falha do Spike (PRJ022-D Ativado)

| # | Verificação | Comando | Status |
|---|-------------|---------|--------|
| F01 | PRJ022-A ainda funciona | `sudo wc -l /srv/iga-project/data/midpoint/hr_export.csv` | ⬜ |
| F02 | Resource CSV está Active | GUI → Resources → Lifecycle state = Active | ⬜ |
| F03 | Tarefa CSV executa | Executar tarefa → Status CLOSED | ⬜ |
| F04 | Usuários ainda existem | `curl ... \| jq '.users \| length'` ≥ 102 | ⬜ |
| F05 | Recurso do spike removido | Resource "Fiqueok Shadow API (Spike)" não existe | ⬜ |
| F06 | Variável SHADOW_API_KEY removida | `sudo docker exec iga-midpoint env \| grep SHADOW_API_KEY` vazio | ⬜ |

---

## 17. Resolução de Problemas Comuns

| Erro | Causa Provável | Solução |
|------|----------------|---------|
| **Test Connection falha** | ScriptedSQL connector não encontrado | Verificar OID do conector: `c89f121b-f6a3-483e-9300-91b91bbe06f5` |
| **Groovy script não encontrado** | Scripts não estão no container | Executar `sudo docker cp` novamente |
| **SHADOW_API_KEY not set** | Variável não configurada | Adicionar ao docker-compose.yml e reiniciar |
| **HTTP 401 Unauthorized** | API Key incorreta | Verificar `echo $SHADOW_API_KEY` |
| **HTTP 404 Not Found** | URL da Shadow API incorreta | Verificar IP: `xxx.xxx.xxx.xxx:8000` |
| **Connection refused** | Shadow API não está rodando | `ssh paulo@xxx.xxx.xxx.xxx "systemctl status shadow-api"` |
| **No correlator configurations** | Correlation não configurada | Verificar XML do resource, seção `<correlation>` |
| **ClassNotFoundException: org.h2.Driver** | H2 driver não disponível | Baixar H2 JAR e copiar para connid-connectors |
| **JDBC connection timeout** | H2 URL incorreta | Usar `jdbc:h2:mem:dummy;DB_CLOSE_DELAY=-1` |
| **Tarefa processa 0 objetos** | SearchScript não retorna dados | Verificar logs: `sudo docker logs iga-midpoint \| grep "SearchScript"` |

---

## 18. Lições Aprendidas (PRJ022-B)

| # | Lição | Expectativa para o spike |
|---|-------|--------------------------|
| L-B01 | O H2 em memória é o método mais leve e provavelmente o mais funcional | Método 1 tem maior chance de sucesso |
| L-B02 | A variável SHADOW_API_KEY precisa ser injetada no container | Configurar antes da primeira tentativa |
| L-B03 | Os scripts Groovy devem ser testados isoladamente antes de configurar o resource | Testar com `groovy SearchScript.groovy` |
| L-B04 | O JDBC dummy é exigido mesmo que não seja usado | Configurar corretamente a URL do H2 |
| L-B05 | A correlação explícita é obrigatória (já validado no PRJ022-A) | Incluir no XML do resource |
| L-B06 | Em caso de falha nas 3 tentativas, o CSV é a solução final | Aceitar PRJ022-D sem remorso |

---

## 19. Anexos: Comandos de Diagnóstico

### 19.1. Verificar ScriptedSQL Connector

```bash
# [iga-gf-02]$
# Listar conectores disponíveis
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/connectors \
  | jq '.[] | {name: .name, oid: .oid}'
```

### 19.2. Testar Script Groovy Isoladamente

```bash
# [iga-gf-02]$
# Testar SearchScript isoladamente (requer groovy no container)
sudo docker exec iga-midpoint bash -c "
  export SHADOW_API_KEY='Fiqueok-Security-Token-2026'
  echo '
def SHADOW_API_URL = \"http://xxx.xxx.xxx.xxx:8000/employees\"
def API_KEY = System.getenv(\"SHADOW_API_KEY\")
def url = new URL(SHADOW_API_URL)
def conn = url.openConnection()
conn.setRequestProperty(\"X-API-KEY\", API_KEY)
def employees = new groovy.json.JsonSlurper().parse(conn.inputStream)
println \"Total employees: \${employees.size()}\"
' | groovy -
"
```

### 19.3. Verificar Logs Detalhados do ScriptedSQL

```bash
# [iga-gf-02]$
sudo docker exec iga-midpoint grep -i "ScriptedSQL\|ScriptedSQLConnector" \
  /opt/midpoint/var/log/idm.log | tail -50
```

### 19.4. Remover Recurso do Spike (em caso de abortamento)

```bash
# [iga-gf-02]$
# Obter OID do resource
RESOURCE_OID=$(curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/resources \
  | jq -r '.[] | select(.name=="Fiqueok Shadow API (Spike ScriptedSQL)") | .oid')

# Deletar resource
curl -X DELETE -u administrator:'M1dP0!ntAdm!n#2026' \
  http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/resources/${RESOURCE_OID}
```

---

## 20. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 04/05/2026 | Paulo Feitosa Lima | Documento inicial do spike PRJ022-B. Incluídos 3 métodos de implementação, regra das 3 tentativas, verificações de baseline PRJ022-A, procedimentos de rollback, matriz de decisão, checklists pós-spike e termo de abortamento. |

---

**Fim do POP v1.0 - PRJ022-B**

---

*PRJ022-B — Procedimento Operacional Padrão (POP) v1.0 - Spike Técnico ScriptedSQL+HTTP*  
*Living Lab Fiqueok*  
*Arquivado em: `FiqueokBrain/PRJ022/POP-PRJ022-B-ScriptedSQL-Spike-v1.0.md`*
