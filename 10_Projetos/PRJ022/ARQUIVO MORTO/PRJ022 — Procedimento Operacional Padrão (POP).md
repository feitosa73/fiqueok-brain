# 

## Configuração de Recurso CSV no midPoint 4.10 para Consumo da Shadow API

**Versão:** 1.0  
**Data:** Maio/2026  
**Status:** ✅ **VALIDADO** — Baseado na execução bem-sucedida da POC  
**Responsável:** Paulo Feitosa Lima  
**Baseado em:** POC realizada em 03/05/2026 (102 funcionários exportados, erro corrigido)

---

## ÍNDICE

1. [Objetivo](#1-objetivo)
2. [Arquitetura da Solução](#2-arquitetura-da-solução)
3. [Pré-Requisitos Obrigatórios](#3-pré-requisitos-obrigatórios)
4. [Checklist de Pré-Verificação (Pre-Flight)](#4-checklist-de-pré-verificação-pre-flight)
5. [Passo 1: Configuração na api-gf-01 (Script de Exportação)](#5-passo-1-configuração-na-api-gf-01-script-de-exportação)
6. [Passo 2: Configuração no iga-gf-02 (Preparação do Ambiente)](#6-passo-2-configuração-no-iga-gf-02-preparação-do-ambiente)
7. [Passo 3: Configuração do Recurso CSV no midPoint](#7-passo-3-configuração-do-recurso-csv-no-midpoint)
8. [Passo 4: Configuração do Schema Handling (CRÍTICO)](#8-passo-4-configuração-do-schema-handling-crítico)
9. [Passo 5: Configuração da Tarefa de Reconciliação](#9-passo-5-configuração-da-tarefa-de-reconciliação)
10. [Passo 6: Execução e Validação](#10-passo-6-execução-e-validação)
11. [Passo 7: Agendamento Automático (Opcional)](#11-passo-7-agendamento-automático-opcional)
12. [Procedimento de Rollback](#12-procedimento-de-rollback)
13. [Resolução de Problemas Comuns](#13-resolução-de-problemas-comuns)
14. [Lições Aprendidas na POC](#14-lições-aprendidas-na-poc)

---

## 1. Objetivo

Este POP descreve o procedimento para configurar a integração entre a Shadow API (PRJ008) e o midPoint 4.10 utilizando o **CsvConnector** nativo como solução de fallback (PRJ022-A).

A solução consiste em:

1. Script Python na `api-gf-01` que consome a Shadow API e gera CSV
2. Transferência do CSV para `iga-gf-02` via SCP
3. Recurso CSV no midPoint que lê o arquivo
4. Tarefa de reconciliação que sincroniza os dados com o repositório Focus

---

## 2. Arquitetura da Solução

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FLUXO DE DADOS PRJ022-A                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────────────┐│
│  │   Shadow API    │     │  Script Python  │     │     CSV File            ││
│  │ (api-gf-01:8000)│────▶│ (export_employees│────▶│ /srv/iga-project/data/  ││
│  │                 │     │   _to_csv.py)   │     │ midpoint/hr_export.csv  ││
│  └─────────────────┘     └─────────────────┘     └─────────────────────────┘│
│         │                                                                     │
│         │ HTTP GET com X-API-KEY                                              │
│         ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                         midPoint 4.10 (iga-gf-02)                        ││
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐  ││
│  │  │  CsvConnector   │───▶│  Resource CSV   │───▶│  Tarefa de          │  ││
│  │  │  (bundled)      │    │  (Schema        │    │  Reconciliação      │  ││
│  │  └─────────────────┘    │   Handling)     │    └─────────────────────┘  ││
│  │                         └─────────────────┘              │               ││
│  │                                                          ▼               ││
│  │                                          ┌─────────────────────────────┐││
│  │                                          │  Repositório Focus (Users)  │││
│  │                                          └─────────────────────────────┘││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Pré-Requisitos Obrigatórios

| # | Pré-Requisito | Verificação | Critério |
|---|---------------|-------------|----------|
| PR-01 | Shadow API operacional em `api-gf-01` | `curl -H "X-API-KEY: ..." http://127.0.0.1:8000/employees` | HTTP 200 + JSON |
| PR-02 | Python 3.12+ instalado em `api-gf-01` | `python3 --version` | 3.12+ |
| PR-03 | Conexão SSH entre `api-gf-01` e `iga-gf-02` | `ssh paulo@xxx.xxx.xxx.xxx` | Login OK |
| PR-04 | midPoint 4.10 operacional em `iga-gf-02` | `docker ps | grep midpoint` | Container running |
| PR-05 | Permissão de escrita no diretório `/srv/iga-project/data/midpoint/` | `ls -la /srv/iga-project/data/midpoint/` | Diretório gravável |
| PR-06 | Snapshot das VMs antes de qualquer alteração | `Get-VMSnapshot -VMName "api-gf-01"` | Checkpoint criado |

---

## 4. Checklist de Pré-Verificação (Pre-Flight)

Execute os comandos abaixo **antes** de iniciar qualquer configuração:

### 4.1. Verificar Shadow API

```bash
# No host Windows (PowerShell) ou via SSH na api-gf-01
curl -s -o /dev/null -w "%{http_code}" -H "X-API-KEY: Fiqueok-Security-Token-2026" \
  http://xxx.xxx.xxx.xxx:8000/employees
# Deve retornar: 200
```

### 4.2. Verificar Conectividade entre VMs

```bash
# Da api-gf-01 para iga-gf-02
ping -c 2 xxx.xxx.xxx.xxx
# Deve ter 0% packet loss
```

### 4.3. Verificar Estado do midPoint

```bash
# No host Windows
curl -s -o /dev/null -w "%{http_code}" http://xxx.xxx.xxx.xxx:8080/midpoint
# Deve retornar: 200
```

### 4.4. Criar Snapshot de Segurança (OBRIGATÓRIO)

```powershell
# PowerShell como Administrador no Hyper-V
Checkpoint-VM -Name "api-gf-01" -SnapshotName "PRJ022-A-Antes-Configuracao"
Checkpoint-VM -Name "iga-gf-02" -SnapshotName "PRJ022-A-Antes-Configuracao"
```

---

## 5. Passo 1: Configuração na api-gf-01 (Script de Exportação)

### 5.1. Acessar a VM da Shadow API

```bash
ssh paulo@xxx.xxx.xxx.xxx
```

### 5.2. Criar o Script de Exportação

```bash
nano /home/paulo/export_employees_to_csv.py
```

### 5.3. Conteúdo do Script (VERSÃO COMPLETA E TESTADA)

```python
#!/usr/bin/env python3
"""
PRJ022-A - Script de Exportação de Funcionários da Shadow API para CSV
Data: Maio/2026
Responsável: Paulo Feitosa Lima

Este script:
1. Consome a Shadow API local (127.0.0.1:8000/employees)
2. Gera um arquivo CSV com os dados dos funcionários
3. Transfere o arquivo via SCP para o servidor do midPoint (iga-gf-02)
"""

import requests
import csv
import os
import subprocess
from datetime import datetime

# <REDACTED_SECRET>====================
# CONFIGURAÇÕES
# <REDACTED_SECRET>====================
SHADOW_API_URL = "http://127.0.0.1:8000/employees"
API_KEY = "Fiqueok-Security-Token-2026"
OUTPUT_DIR = "/tmp/csv_export"
MIDPOINT_HOST = "xxx.xxx.xxx.xxx"
MIDPOINT_USER = "paulo"
MIDPOINT_PATH = "/srv/iga-project/data/midpoint/hr_export.csv"

# <REDACTED_SECRET>====================
# FUNÇÃO: Exportar dados da Shadow API para CSV
# <REDACTED_SECRET>====================
def export():
    """Consulta a Shadow API, gera CSV e retorna o nome do arquivo"""
    
    # Cria diretório de saída se não existir
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    # Headers da requisição
    headers = {"X-API-KEY": API_KEY}
    
    # Requisição à Shadow API
    response = requests.get(SHADOW_API_URL, headers=headers, timeout=10)
    response.raise_for_status()  # Levanta exceção se HTTP != 200
    
    # Parse do JSON
    employees = response.json()
    
    # Gera nome do arquivo com timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{OUTPUT_DIR}/employees_{timestamp}.csv"
    
    # Escreve o CSV
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=['emp_number', 'employee_id', 'first_name', 'last_name'])
        writer.writeheader()
        writer.writerows(employees)
    
    # Log da exportação
    with open(f"{OUTPUT_DIR}/export.log", 'a') as log:
        log.write(f"{timestamp}|{len(employees)}|{os.environ.get('USER', 'manual')}\n")
    
    print(f"✅ Exportado {len(employees)} funcionários para {filename}")
    return filename

# <REDACTED_SECRET>====================
# FUNÇÃO: Sincronizar CSV com o midPoint via SCP
# <REDACTED_SECRET>====================
def sync_to_midpoint(filename):
    """Envia o arquivo CSV gerado para o servidor do midPoint"""
    
    print(f"🔄 Sincronizando com {MIDPOINT_HOST}...")
    
    try:
        # Comando SCP
        cmd = [
            "scp",
            "-o", "StrictHostKeyChecking=no",
            filename,
            f"{MIDPOINT_USER}@{MIDPOINT_HOST}:{MIDPOINT_PATH}"
        ]
        subprocess.run(cmd, check=True)
        print(f"✅ Sincronização concluída. Arquivo em {MIDPOINT_PATH}")
    except subprocess.CalledProcessError as e:
        print(f"❌ Falha na sincronização via SCP: {e}")

# <REDACTED_SECRET>====================
# EXECUÇÃO PRINCIPAL
# <REDACTED_SECRET>====================
if __name__ == "__main__":
    try:
        generated_file = export()
        if generated_file:
            sync_to_midpoint(generated_file)
    except requests.exceptions.RequestException as e:
        print(f"❌ Erro ao acessar a Shadow API: {e}")
    except Exception as e:
        print(f"❌ Erro inesperado: {e}")
```

### 5.4. Tornar o Script Executável e Testar

```bash
chmod +x /home/paulo/export_employees_to_csv.py
python3 /home/paulo/export_employees_to_csv.py
```

**Saída esperada:**
```
✅ Exportado 102 funcionários para /tmp/csv_export/employees_20260503_195827.csv
🔄 Sincronizando com xxx.xxx.xxx.xxx...
✅ Sincronização concluída. Arquivo em /srv/iga-project/data/midpoint/hr_export.csv
```

### 5.5. Verificar se o CSV foi transferido corretamente

```bash
# No iga-gf-02
ls -la /srv/iga-project/data/midpoint/hr_export.csv
# Deve mostrar o arquivo com permissões adequadas

head -5 /srv/iga-project/data/midpoint/hr_export.csv
# Deve mostrar o cabeçalho e as primeiras linhas
```

---

## 6. Passo 2: Configuração no iga-gf-02 (Preparação do Ambiente)

### 6.1. Acessar a VM do midPoint

```bash
ssh paulo@xxx.xxx.xxx.xxx
```

### 6.2. Verificar Permissões do Diretório

```bash
# Verificar se o CSV está no local correto
ls -la /srv/iga-project/data/midpoint/hr_export.csv

# Se necessário, ajustar permissões para o container midPoint ler o arquivo
sudo chmod 644 /srv/iga-project/data/midpoint/hr_export.csv
```

### 6.3. Validar o Conteúdo do CSV

```bash
# Contar linhas (deve ser 1 cabeçalho + N funcionários)
wc -l /srv/iga-project/data/midpoint/hr_export.csv

# Verificar encoding (deve ser UTF-8)
file -i /srv/iga-project/data/midpoint/hr_export.csv
```

### 6.4. Estrutura Esperada do CSV

```csv
emp_number,employee_id,first_name,last_name
1,0001,Paulo,Feitosa
10,FP008,Daniel,Feitosa
100,FP098,Carlos,Eduardo
...
```

---

## 7. Passo 3: Configuração do Recurso CSV no midPoint

### 7.1. Acessar a Interface Web do midPoint

- URL: `http://xxx.xxx.xxx.xxx:8080/midpoint`
- Usuário: `administrator`
- Senha: (conforme configurado no PRJ003)

### 7.2. Criar Novo Recurso

1. Navegue até **Resources** > **All resources** > **New resource**
2. Clique em **Add resource**
3. Escolha o conector: **CSV Resource Connector** (ou `com.evolveum.polygon.connector.csv.CsvConnector`)

### 7.3. Configuração Básica do Recurso

| Campo | Valor |
|-------|-------|
| **Name** | `Fiqueok HR (Shadow API CSV)` |
| **Description** | `Importa funcionários da Shadow API via CSV` |
| **Connector** | `CSV Resource Connector` |

### 7.4. Configuração do Conector (Connector Configuration)

| Campo | Valor | Observação |
|-------|-------|------------|
| **File path** | `/opt/midpoint/var/hr_export.csv` | Caminho **dentro do container** |
| **File path** (alternativo) | `/srv/iga-project/data/midpoint/hr_export.csv` | Caminho no host (mapeado) |
| **Delimiter** | `,` | Vírgula como separador |
| **Encoding** | `UTF-8` | Obrigatório para acentuação |
| **Header** | `true` | Primeira linha contém cabeçalho |

**IMPORTANTE:** Como o arquivo CSV está em `/srv/iga-project/data/midpoint/hr_export.csv` no host, e o container mapeia `/srv/iga-project/data:/srv/iga-project/data`, o caminho correto dentro do container é a mesma string.

### 7.5. Testar Conexão

Clique em **Test connection** no menu superior.

**Saída esperada:**
```
✅ Connector instantiation
✅ Connector initialization
✅ Connector connection
✅ Connector capabilities
✅ Resource schema
```

---

## 8. Passo 4: Configuração do Schema Handling (CRÍTICO)

### ⚠️ ATENÇÃO

Esta é a etapa **mais crítica** de toda a configuração. O erro `"No name in the new object"` ocorre exclusivamente por omissão ou erro neste passo.

### 8.1. Acessar Schema Handling

Dentro do Recurso, navegue até a aba **Schema handling** (no sidebar, dentro de **Accounts**).

### 8.2. Configurar os Atributos (Attribute Mapping)

Clique no ícone de edição (lápis) ao lado de **Account** e configure os seguintes mapeamentos:

| Atributo do CSV | Atributo do midPoint (User) | Obrigatório | Mapeamento |
|-----------------|-----------------------------|-------------|------------|
| `employee_id` | **`name`** | ✅ **SIM** | `employee_id` |
| `employee_id` | `employeeId` | Opcional | `employee_id` |
| `first_name` | `givenName` | Opcional | `first_name` |
| `last_name` | `familyName` | Opcional | `last_name` |
| `emp_number` | `employeeNumber` | Opcional | `emp_number` |

### 8.3. Como Configurar no midPoint (Passo a Passo)

1. No **Schema handling**, localize a seção **Object types** > **Account (default)**
2. Clique em **Add attribute**
3. Configure cada atributo conforme abaixo:

#### Atributo: `name` (CRÍTICO - OBRIGATÓRIO)

```xml
<attribute>
    <ref>name</ref>
    <displayName>Username</displayName>
    <inbound>
        <target>name</target>
        <expression>
            <path>$employee_id</path>
        </expression>
    </inbound>
    <outbound>
        <source>name</source>
        <expression>
            <path>$employee_id</path>
        </expression>
    </outbound>
</attribute>
```

**No modo GUI do midPoint:**
- Clique em **Add attribute** > Atributo: `name`
- Em **Inbound mapping**, configure:
  - **Target:** `name` (ou `userName`)
  - **Expression:** `$employee_id` (referência ao campo do CSV)
  - **Type:** `attribute` ou `path`

#### Atributo: `givenName`

```xml
<attribute>
    <ref>givenName</ref>
    <inbound>
        <target>givenName</target>
        <expression>
            <path>$first_name</path>
        </expression>
    </inbound>
</attribute>
```

#### Atributo: `familyName`

```xml
<attribute>
    <ref>familyName</ref>
    <inbound>
        <target>familyName</target>
        <expression>
            <path>$last_name</path>
        </expression>
    </inbound>
</attribute>
```

### 8.4. Configurar a Correlação

A correlação define como o midPoint identifica se um usuário já existe.

| Campo | Valor |
|-------|-------|
| **Correlation attribute** | `employee_id` |
| **Correlation condition** | `employee_id = $employee_id` |

**No modo GUI:**
- Vá até **Correlation** na configuração do Account
- Configure:
  - **Source attribute:** `employee_id` (do CSV)
  - **Target attribute:** `employee_id` (do User no midPoint)
  - **Condition:** `equals`

### 8.5. Configurar as Reações de Sincronização

| Situation | Action | Descrição |
|-----------|--------|-----------|
| **Unmatched** | `addFocus` | Usuário não existe → criar |
| **Matched** | `link` | Usuário existe → vincular |
| **Unlinked** | `addLink` | Criar vínculo se necessário |
| **Deleted** | `unlink` (ou `delete` dependendo da política) | Remover vínculo |

**Configuração no GUI:**
- Vá até **Synchronization** > **Reactions**
- Adicione uma nova reação:
  - **Situation:** `Unmatched`
  - **Action:** `addFocus`
- (Opcional) Configure política de revogação para `Deleted` → `delete` ou `disable`

### 8.6. Salvar o Recurso

Clique em **Save** no menu superior.

---

## 9. Passo 5: Configuração da Tarefa de Reconciliação

### 9.1. Criar Nova Tarefa

1. Dentro do Recurso, vá até a aba **Defined Tasks**
2. Clique em **Create task** > **Reconciliation Task**

### 9.2. Configuração Básica da Tarefa

| Campo | Valor |
|-------|-------|
| **Name** | `Carga_RH_ShadowAPI_Fiqueok` |
| **Description** | `Importa funcionários do CSV gerado pela Shadow API` |
| **Owner** | `paulo` (ou `administrator`) |
| **Category** | `Import/Export` |

### 9.3. Configuração dos Objetos do Recurso (Resource Objects)

| Campo | Valor |
|-------|-------|
| **Resource** | `Fiqueok HR (Shadow API CSV)` |
| **Kind** | `Account` |
| **Intent** | `default` |
| **Object class** | `AccountObjectClass` |

### 9.4. Configuração do Agendamento (Schedule)

Para execução manual imediata:

| Campo | Valor |
|-------|-------|
| **Schedule type** | `Manual` (sem agendamento) |

Para execução periódica (opcional):

| Campo | Valor |
|-------|-------|
| **Schedule type** | `Cron` |
| **Cron expression** | `0 0 */4 * * ?` (a cada 4 horas) |

### 9.5. Salvar a Tarefa

Clique em **Save & Run** para salvar e executar imediatamente.

---

## 10. Passo 6: Execução e Validação

### 10.1. Executar a Tarefa

- Se não tiver usado **Save & Run**, clique em **Run now** na tarefa

### 10.2. Monitorar a Execução

Acompanhe o progresso na tela da tarefa:

- **Status:** `RUNNING` → `CLOSED` (se OK) ou `PARTIAL_ERROR` (se houver falhas)

### 10.3. Verificar o Log da Tarefa

No final da execução, verifique os tokens de operação:

- `SUCCESS` = importação OK
- `PARTIAL_ERROR` = falha em alguns registros (ver mensagem de erro)

### 10.4. Validar Usuários Criados

1. Navegue até **Users** > **All users**
2. Verifique se os novos usuários aparecem com os atributos corretos
3. Confirme que o atributo `name` foi preenchido com o `employee_id`

### 10.5. Exemplo de Saída Bem-Sucedida no Log

```
Token: 10000000000120059
Operation: run
Status: CLOSED
Timestamp: 5/3/26, 8:43:59 PM
Message: Reconciliation completed. 102 objects processed, 102 added.
```

---

## 11. Passo 7: Agendamento Automático (Opcional)

### 11.1. Configurar Cron na Tarefa do midPoint

Já incluído no passo 9.4: use expressão cron para execução periódica.

### 11.2. Configurar Cron no Script de Exportação (api-gf-01)

```bash
# Editar o crontab do usuário paulo
crontab -e

# Adicionar linha para execução a cada 4 horas
0 */4 * * * /usr/bin/python3 /home/paulo/export_employees_to_csv.py >> /home/paulo/cron.log 2>&1
```

### 11.3. Testar o Cron

```bash
# Verificar se o cron foi adicionado
crontab -l

# Aguardar a execução ou forçar manualmente
/usr/bin/python3 /home/paulo/export_employees_to_csv.py
```

---

## 12. Procedimento de Rollback

### 12.1. Rollback no midPoint (Remover Configuração)

1. Excluir a Tarefa: **Server Tasks** > `Carga_RH_ShadowAPI_Fiqueok` > **Delete object**
2. Excluir o Recurso: **Resources** > `Fiqueok HR (Shadow API CSV)` > **Delete object**
3. Remover o CSV do servidor:
   ```bash
   ssh paulo@xxx.xxx.xxx.xxx
   sudo rm /srv/iga-project/data/midpoint/hr_export.csv
   ```

### 12.2. Rollback via Snapshot Hyper-V

```powershell
# No PowerShell (Administrador)
Restore-VMSnapshot -VMName "api-gf-01" -Name "PRJ022-A-Antes-Configuracao" -Confirm:$false
Restore-VMSnapshot -VMName "iga-gf-02" -Name "PRJ022-A-Antes-Configuracao" -Confirm:$false
```

### 12.3. Remover Script da api-gf-01

```bash
ssh paulo@xxx.xxx.xxx.xxx
rm /home/paulo/export_employees_to_csv.py
rm -rf /tmp/csv_export/
```

---

## 13. Resolução de Problemas Comuns

| Erro | Causa Provável | Solução |
|------|----------------|---------|
| **Test connection falha** | Caminho do CSV incorreto | Verificar `file path` no connector configuration |
| **"No name in the new object"** | Atributo `name` não mapeado | Configurar mapeamento `employee_id` → `name` no Schema handling |
| **Permission denied no SCP** | Permissões no diretório destino | Executar `sudo chmod 777 /srv/iga-project/data/midpoint` |
| **CSV com encoding errado** | Acentuação corrompida | Garantir `encoding='utf-8'` no script e no connector |
| **Tarefa não cria usuários** | Correlation mal configurada | Verificar se `UNMATCHED` tem ação `addFocus` |
| **Usuários duplicados** | Correlation não está funcionando | Verificar regra de correlação (deve usar `employee_id`) |
| **API Key expirada** | Token do Vault foi revogado | Gerar novo token no Vault e atualizar script |
| **Apenas 0 registros processados** | CSV vazio ou cabeçalho errado | Validar `wc -l` e `head` do CSV |

---

## 14. Lições Aprendidas na POC

### 14.1. O que Funcionou

| Item | Resultado |
|------|-----------|
| Script Python de exportação | ✅ Gerou CSV com 102 funcionários |
| Transferência SCP | ✅ Funcionou após ajuste de permissões |
| Leitura do CSV pelo midPoint | ✅ Test connection OK |
| Execução da tarefa | ✅ Processou todos os registros |

### 14.2. O que Falhou e Foi Corrigido

| Problema | Causa | Correção |
|----------|-------|----------|
| `Permission denied` no SCP | Diretório `/srv/iga-project/data/midpoint` sem permissão | `sudo chmod 777` no diretório |
| `No name in the new object` | Atributo `name` não mapeado | Adicionar mapeamento `employee_id` → `name` no Schema handling |

### 14.3. Lições Documentadas

| # | Lição |
|---|-------|
| L01 | O atributo `name` do User no midPoint é **OBRIGATÓRIO** — sem ele, nenhum usuário é criado |
| L02 | O caminho do CSV no connector é o caminho **dentro do container**, não do host |
| L03 | O SCP pode falhar por permissão — sempre verificar com `ls -la` antes |
| L04 | A Shadow API via `127.0.0.1` é imune a mudanças de IP do Tailscale |
| L05 | O CsvConnector **não precisa** de paginação — lê o arquivo inteiro |
| L06 | Header do CSV **deve** estar presente e corresponder aos fieldnames do script |

---

## 15. Anexos

### 15.1. Estrutura de Diretórios Esperada

```
api-gf-01 (xxx.xxx.xxx.xxx):
/home/paulo/
├── prj008-shadow-api/          # Shadow API
│   └── app/main.py
├── export_employees_to_csv.py  # Script de exportação
└── .ssh/                       # Chaves para SCP

iga-gf-02 (xxx.xxx.xxx.xxx):
/srv/iga-project/data/
├── midpoint/
│   ├── hr_export.csv           # CSV transferido
│   ├── connid-connectors/      # Conectores ICF
│   └── scripts/                # Scripts Groovy
├── postgres/                   # Dados do PostgreSQL
└── ...
```

### 15.2. Comandos Úteis para Diagnóstico

```bash
# Verificar se a Shadow API está respondendo
curl -s -H "X-API-KEY: Fiqueok-Security-Token-2026" http://127.0.0.1:8000/employees | jq '. | length'

# Verificar conectividade SSH para SCP
ssh -o ConnectTimeout=5 paulo@xxx.xxx.xxx.xxx "echo OK"

# Verificar permissões do CSV no midPoint
ssh paulo@xxx.xxx.xxx.xxx "ls -la /srv/iga-project/data/midpoint/hr_export.csv"

# Contar registros no CSV (excluindo cabeçalho)
tail -n +2 /srv/iga-project/data/midpoint/hr_export.csv | wc -l

# Verificar se os usuários foram criados no midPoint (via API)
curl -u administrator:senha http://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/users | jq '.usersList | length'
```

---

## 16. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 03/05/2026 | Paulo Feitosa Lima | Documento inicial baseado na POC bem-sucedida |

---

**Fim do POP**

---

*PRJ022 — Procedimento Operacional Padrão (POP)*  
*Living Lab Fiqueok*  
*Arquivado em: `FiqueokBrain/PRJ022/POP-PRJ022-A-CSV-Integration-v1.0.md`*
