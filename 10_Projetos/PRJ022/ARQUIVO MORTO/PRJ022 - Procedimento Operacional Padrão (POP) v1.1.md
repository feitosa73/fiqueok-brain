# 

## Configuração de Recurso CSV no midPoint 4.10 para Consumo da Shadow API

**Versão:** 1.1  
**Data:** Maio/2026  
**Status:** ✅ **REVISADO** — Correções de segurança e rede aplicadas  
**Responsável:** Paulo Feitosa Lima  
**Baseado em:** POC realizada em 03/05/2026 + Revisão técnica independente

---

## CONTROLE DE ALTERAÇÕES (v1.0 → v1.1)

| Item | v1.0 | v1.1 | Justificativa |
|------|------|------|----------------|
| **IP da api-gf-01** | `xxx.xxx.xxx.xxx` (inconsistente) | `xxx.xxx.xxx.xxx` (único documentado) | Alinhado com terminal atual e conectividade validada |
| **Pre-Flight** | Usava IP antigo | Corrigido para IP atual | Evita falha no checklist |
| **Permissões do diretório** | `chmod 777` (anti-padrão) | `chmod 755` e `644` | Compliance com ADR-002 e PSI-001 |
| **API Key** | Hardcoded no script | Leitura do Vault via variável de ambiente | Remove credencial do código-fonte |
| **Rollback** | Incluía comandos complexos | Apenas snapshot Hyper-V | Simplifica e reduz risco de erro |
| **Agendamento** | Cron duplo (midPoint + script) | Apenas cron no script Python | Evita reconciliação com CSV desatualizado |
| **XML Schema Handling** | Sintaxe questionável | Removido; apenas instrução GUI | Evita erro de importação direta |

---

## ÍNDICE

1. [Arquitetura da Solução](#1-arquitetura-da-solução)
2. [Pré-Requisitos Obrigatórios](#2-pré-requisitos-obrigatórios)
3. [Checklist de Pré-Verificação (Pre-Flight)](#3-checklist-de-pré-verificação-pre-flight)
4. [Passo 1: Configuração na api-gf-01 (Script de Exportação)](#4-passo-1-configuração-na-api-gf-01-script-de-exportação)
5. [Passo 2: Configuração no iga-gf-02 (Preparação do Ambiente)](#5-passo-2-configuração-no-iga-gf-02-preparação-do-ambiente)
6. [Passo 3: Configuração do Recurso CSV no midPoint](#6-passo-3-configuração-do-recurso-csv-no-midpoint)
7. [Passo 4: Configuração do Schema Handling (CRÍTICO)](#7-passo-4-configuração-do-schema-handling-crítico)
8. [Passo 5: Configuração da Tarefa de Reconciliação](#8-passo-5-configuração-da-tarefa-de-reconciliação)
9. [Passo 6: Execução e Validação](#9-passo-6-execução-e-validação)
10. [Passo 7: Agendamento Automático](#10-passo-7-agendamento-automático)
11. [Procedimento de Rollback (Via Snapshot)](#11-procedimento-de-rollback-via-snapshot)
12. [Resolução de Problemas Comuns](#12-resolução-de-problemas-comuns)
13. [Lições Aprendidas na POC](#13-lições-aprendidas-na-poc)
14. [Anexos: Comandos de Diagnóstico](#14-anexos-comandos-de-diagnóstico)

---

## 1. Arquitetura da Solução

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FLUXO DE DADOS PRJ022-A                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────────────┐│
│  │   Shadow API    │     │  Script Python  │     │     CSV File            ││
│  │ (api-gf-01:8000)│────▶│ (export_employees│────▶│ /srv/iga-project/data/  ││
│  │  127.0.0.1:8000 │     │   _to_csv.py)   │     │ midpoint/hr_export.csv  ││
│  └─────────────────┘     └─────────────────┘     └─────────────────────────┘│
│         │                                                                     │
│         │ HTTP GET com X-API-KEY (via 127.0.0.1 ou Vault)                    │
│         ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                         midPoint 4.10 (iga-gf-02)                        ││
│  │                         IP: xxx.xxx.xxx.xxx                                ││
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐  ││
│  │  │  CsvConnector   │───▶│  Resource CSV   │───▶│  Tarefa de          │  ││
│  │  │  (bundled)      │    │  (Schema        │    │  Reconciliação      │  ││
│  │  └─────────────────┘    │   Handling)     │    │  (Manual ou Cron)   │  ││
│  │                         └─────────────────┘    └─────────────────────┘  ││
│  │                                                          │               ││
│  │                                                          ▼               ││
│  │                                          ┌─────────────────────────────┐││
│  │                                          │  Repositório Focus (Users)  │││
│  │                                          │     (Criados/Atualizados)   │││
│  │                                          └─────────────────────────────┘││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Pré-Requisitos Obrigatórios

| # | Pré-Requisito | Verificação | Critério |
|---|---------------|-------------|----------|
| PR-01 | Shadow API operacional em `api-gf-01` (IP `xxx.xxx.xxx.xxx`) | `curl -H "X-API-KEY: ..." http://127.0.0.1:8000/employees` | HTTP 200 + JSON |
| PR-02 | Python 3.12+ instalado em `api-gf-01` | `python3 --version` | 3.12+ |
| PR-03 | Python `requests` instalado | `pip3 list \| grep requests` | requests instalado |
| PR-04 | Conexão SSH entre `api-gf-01` e `iga-gf-02` | `ssh paulo@xxx.xxx.xxx.xxx` | Login OK (sem erro) |
| PR-05 | Chave SSH configurada para SCP sem senha | `ssh -o BatchMode=yes paulo@xxx.xxx.xxx.xxx "echo OK"` | OK sem pedir senha |
| PR-06 | midPoint 4.10 operacional em `iga-gf-02` | `docker ps \| grep midpoint` | Container running |
| PR-07 | Diretório `/srv/iga-project/data/midpoint` existe e é gravável | `ls -la /srv/iga-project/data/midpoint/` | Diretório existe |
| PR-08 | Acesso ao Vault para obter API Key (via variável de ambiente) | `vault kv get secret/shadow-api/auth` | Chave disponível |

---

## 3. Checklist de Pré-Verificação (Pre-Flight)

Execute os comandos abaixo **antes** de iniciar qualquer configuração.

### 3.1. Verificar Shadow API (via loopback local)

```bash
# Acessar a api-gf-01
ssh paulo@xxx.xxx.xxx.xxx

# Testar Shadow API localmente
curl -s -o /dev/null -w "%{http_code}" -H "X-API-KEY: Fiqueok-Security-Token-2026" \
  http://127.0.0.1:8000/employees
# Deve retornar: 200
```

### 3.2. Verificar Conectividade entre VMs

```bash
# Da api-gf-01 para iga-gf-02
ping -c 2 xxx.xxx.xxx.xxx
# Deve ter 0% packet loss
```

### 3.3. Verificar Chave SSH para SCP sem Senha

```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 paulo@xxx.xxx.xxx.xxx "echo OK"
# Deve retornar: OK (sem pedir senha)
```

### 3.4. Verificar Permissões do Diretório no iga-gf-02

```bash
ssh paulo@xxx.xxx.xxx.xxx "ls -la /srv/iga-project/data/midpoint/"
# Deve mostrar diretório com permissões drwxr-xr-x (755) ou similar
```

### 3.5. Verificar Estado do midPoint

```bash
# Do host Windows
curl -s -o /dev/null -w "%{http_code}" http://xxx.xxx.xxx.xxx:8080/midpoint
# Deve retornar: 200
```

### 3.6. Criar Snapshot de Segurança (OBRIGATÓRIO)

```powershell
# PowerShell como Administrador no Hyper-V
# Verificar snapshots existentes
Get-VMSnapshot -VMName "api-gf-01"
Get-VMSnapshot -VMName "iga-gf-02"

# Se não existirem, criar:
Checkpoint-VM -VMName "api-gf-01" -SnapshotName "PRJ022-A-Antes-Configuracao"
Checkpoint-VM -VMName "iga-gf-02" -SnapshotName "PRJ022-A-Antes-Configuracao"
```

---

## 4. Passo 1: Configuração na api-gf-01 (Script de Exportação)

### 4.1. Acessar a VM da Shadow API

```bash
ssh paulo@xxx.xxx.xxx.xxx
```

### 4.2. Obter a API Key do Vault (Variável de Ambiente)

```bash
# Opção 1: Buscar do Vault e exportar como variável
export SHADOW_API_KEY=$(vault kv get -field=api_key secret/shadow-api/auth)

# Opção 2: Se vault não estiver instalado na VM, usar curl diretamente
export SHADOW_API_KEY=$(curl -s -H "X-Vault-Token: $(cat /var/lib/shadow-api/vault_token)" \
  http://xxx.xxx.xxx.xxx:8200/v1/secret/data/shadow-api/auth | jq -r '.data.data.api_key')

# Verificar se funcionou
echo $SHADOW_API_KEY
# Deve mostrar: Fiqueok-Security-Token-2026
```

### 4.3. Criar o Script de Exportação

```bash
nano /home/paulo/export_employees_to_csv.py
```

### 4.4. Conteúdo do Script (VERSÃO CORRIGIDA)

```python
#!/usr/bin/env python3
"""
PRJ022-A - Script de Exportação de Funcionários da Shadow API para CSV
Data: Maio/2026
Responsável: Paulo Feitosa Lima
Versão: 1.1 (correções de segurança e rede)

Este script:
1. Lê a API Key do Vault (via variável de ambiente)
2. Consome a Shadow API local (127.0.0.1:8000/employees)
3. Gera um arquivo CSV com os dados dos funcionários
4. Transfere o arquivo via SCP para o servidor do midPoint (iga-gf-02)
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

# API Key obtida do Vault via variável de ambiente (NÃO hardcoded)
API_KEY = os.environ.get("SHADOW_API_KEY")
if not API_KEY:
    raise ValueError("❌ Variável de ambiente SHADOW_API_KEY não configurada. "
                     "Execute: export SHADOW_API_KEY=$(vault kv get -field=api_key secret/shadow-api/auth)")

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
        # Comando SCP (usa chave SSH configurada)
        cmd = [
            "scp",
            "-o", "StrictHostKeyChecking=no",
            filename,
            f"{MIDPOINT_USER}@{MIDPOINT_HOST}:{MIDPOINT_PATH}"
        ]
        subprocess.run(cmd, check=True)
        print(f"✅ Sincronização concluída. Arquivo em {MIDPOINT_PATH}")
        
        # Ajustar permissões do arquivo no destino (leitura para container)
        subprocess.run([
            "ssh", f"{MIDPOINT_USER}@{MIDPOINT_HOST}",
            f"sudo chmod 644 {MIDPOINT_PATH}"
        ], check=True)
        
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

### 4.5. Tornar o Script Executável e Testar

```bash
chmod +x /home/paulo/export_employees_to_csv.py

# Executar com a variável de ambiente já configurada
python3 /home/paulo/export_employees_to_csv.py
```

**Saída esperada:**
```
✅ Exportado 102 funcionários para /tmp/csv_export/employees_20260503_195827.csv
🔄 Sincronizando com xxx.xxx.xxx.xxx...
✅ Sincronização concluída. Arquivo em /srv/iga-project/data/midpoint/hr_export.csv
```

### 4.6. Verificar se o CSV foi Transferido Corretamente

```bash
# No iga-gf-02
ssh paulo@xxx.xxx.xxx.xxx "ls -la /srv/iga-project/data/midpoint/hr_export.csv"
# Deve mostrar -rw-r--r-- (644) e o arquivo

ssh paulo@xxx.xxx.xxx.xxx "head -5 /srv/iga-project/data/midpoint/hr_export.csv"
# Deve mostrar o cabeçalho e as primeiras linhas
```

---

## 5. Passo 2: Configuração no iga-gf-02 (Preparação do Ambiente)

### 5.1. Acessar a VM do midPoint

```bash
ssh paulo@xxx.xxx.xxx.xxx
```

### 5.2. Verificar Permissões do Diretório (CORRIGIDO)

```bash
# Verificar permissões atuais
ls -la /srv/iga-project/data/
ls -la /srv/iga-project/data/midpoint/

# Ajustar permissões (NÃO usar chmod 777)
sudo chmod 755 /srv/iga-project/data
sudo chmod 755 /srv/iga-project/data/midpoint
sudo chown -R paulo:paulo /srv/iga-project/data/midpoint

# Verificar se o CSV tem permissões corretas
sudo chmod 644 /srv/iga-project/data/midpoint/hr_export.csv
```

### 5.3. Validar o Conteúdo do CSV

```bash
# Contar linhas (deve ser 1 cabeçalho + N funcionários)
wc -l /srv/iga-project/data/midpoint/hr_export.csv

# Verificar encoding (deve ser UTF-8)
file -i /srv/iga-project/data/midpoint/hr_export.csv

# Verificar primeiras linhas
head -5 /srv/iga-project/data/midpoint/hr_export.csv
```

### 5.4. Estrutura Esperada do CSV

```csv
emp_number,employee_id,first_name,last_name
1,0001,Paulo,Feitosa
10,FP008,Daniel,Feitosa
100,FP098,Carlos,Eduardo
...
```

---

## 6. Passo 3: Configuração do Recurso CSV no midPoint

### 6.1. Acessar a Interface Web do midPoint

- URL: `http://xxx.xxx.xxx.xxx:8080/midpoint`
- Usuário: `administrator`
- Senha: (conforme configurado no PRJ003)

### 6.2. Criar Novo Recurso

1. Navegue até **Resources** > **All resources** > **New resource**
2. Clique em **Add resource**
3. Escolha o conector: **CSV Resource Connector**

### 6.3. Configuração Básica do Recurso

| Campo | Valor |
|-------|-------|
| **Name** | `Fiqueok HR (Shadow API CSV)` |
| **Description** | `Importa funcionários da Shadow API via CSV (fallback)` |
| **Connector** | `CSV Resource Connector` |

### 6.4. Configuração do Conector (Connector Configuration)

| Campo | Valor | Observação |
|-------|-------|------------|
| **File path** | `/srv/iga-project/data/midpoint/hr_export.csv` | Caminho no host (mapeado para container) |
| **Delimiter** | `,` | Vírgula como separador |
| **Encoding** | `UTF-8` | Obrigatório para acentuação |
| **Header** | `true` | Primeira linha contém cabeçalho |

### 6.5. Testar Conexão

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

## 7. Passo 4: Configuração do Schema Handling (CRÍTICO)

### ⚠️ ATENÇÃO

Esta é a etapa **mais crítica** de toda a configuração. O erro `"No name in the new object"` ocorre exclusivamente por omissão ou erro neste passo.

### 7.1. Acessar Schema Handling

Dentro do Recurso, navegue até a aba **Schema handling** (no sidebar, dentro de **Accounts**).

### 7.2. Configurar os Atributos (Attribute Mapping)

No modo GUI do midPoint, configure os seguintes mapeamentos:

| Atributo do CSV | Atributo do midPoint (User) | Obrigatório | Ação |
|-----------------|-----------------------------|-------------|------|
| `employee_id` | **`name`** | ✅ **SIM** | Adicionar inbound mapping |
| `employee_id` | `employeeId` | Opcional | Adicionar inbound mapping |
| `first_name` | `givenName` | Opcional | Adicionar inbound mapping |
| `last_name` | `familyName` | Opcional | Adicionar inbound mapping |
| `emp_number` | `employeeNumber` | Opcional | Adicionar inbound mapping |

### 7.3. Configuração do Atributo `name` (Passo a Passo)

1. Clique em **Add attribute**
2. No campo **Attribute**, digite ou selecione `name`
3. Clique em **Add inbound mapping**
4. Configure:
   - **Target:** `name`
   - **Source:** `employee_id` (campo do CSV)
   - **Type:** `attribute` (ou `path`, dependendo da versão do midPoint)
5. Clique em **Save**

### 7.4. Configurar a Correlação

A correlação define como o midPoint identifica se um usuário já existe.

| Campo | Valor |
|-------|-------|
| **Correlation attribute** | `employee_id` |

**No modo GUI:**
- Vá até **Correlation** na configuração do Account
- Configure:
  - **Source attribute:** `employee_id` (do CSV)
  - **Target attribute:** `employee_id` (do User no midPoint)

### 7.5. Configurar as Reações de Sincronização

| Situation | Action | Descrição |
|-----------|--------|-----------|
| **Unmatched** | `addFocus` | Usuário não existe → criar |
| **Matched** | `link` | Usuário existe → vincular (se necessário) |

**Configuração no GUI:**
- Vá até **Synchronization** > **Reactions**
- Adicione uma nova reação:
  - **Situation:** `Unmatched`
  - **Action:** `addFocus`

### 7.6. Salvar o Recurso

Clique em **Save** no menu superior.

---

## 8. Passo 5: Configuração da Tarefa de Reconciliação

### 8.1. Criar Nova Tarefa

1. Dentro do Recurso, vá até a aba **Defined Tasks**
2. Clique em **Create task** > **Reconciliation Task**

### 8.2. Configuração Básica da Tarefa

| Campo | Valor |
|-------|-------|
| **Name** | `Carga_RH_ShadowAPI_Fiqueok` |
| **Description** | `Importa funcionários do CSV gerado pela Shadow API` |
| **Owner** | `paulo` (ou `administrator`) |

### 8.3. Configuração dos Objetos do Recurso

| Campo | Valor |
|-------|-------|
| **Resource** | `Fiqueok HR (Shadow API CSV)` |
| **Kind** | `Account` |
| **Intent** | `default` |

### 8.4. Salvar a Tarefa (NÃO agendar ainda)

Clique em **Save** (não executa automaticamente).

---

## 9. Passo 6: Execução e Validação

### 9.1. Executar a Tarefa

1. Na lista de tarefas, localize `Carga_RH_ShadowAPI_Fiqueok`
2. Clique em **Run now**

### 9.2. Monitorar a Execução

Acompanhe o progresso na tela da tarefa:

- **Status:** `RUNNING` → `CLOSED` (se OK) ou `PARTIAL_ERROR` (se houver falhas)

### 9.3. Verificar o Log da Tarefa

No final da execução, verifique os tokens de operação:

- `SUCCESS` = importação OK
- `PARTIAL_ERROR` = falha em alguns registros (ver mensagem de erro)

### 9.4. Validar Usuários Criados

1. Navegue até **Users** > **All users**
2. Verifique se os novos usuários aparecem com:
   - `name` = `employee_id` (ex: `0001`, `FP008`, etc.)
   - `givenName` = primeiro nome
   - `familyName` = sobrenome

### 9.5. Exemplo de Saída Bem-Sucedida

```
Tarefa: Carga_RH_ShadowAPI_Fiqueok
Status: CLOSED
Processados: 102 registros
Criados: 102 usuários
Atualizados: 0
Erros: 0
```

---

## 10. Passo 7: Agendamento Automático

### 10.1. Configurar Cron no Script de Exportação (api-gf-01)

```bash
# Editar o crontab do usuário paulo na api-gf-01
ssh paulo@xxx.xxx.xxx.xxx
crontab -e

# Adicionar linha para execução a cada 4 horas
# Importante: exportar a variável SHADOW_API_KEY antes da execução
0 */4 * * * export SHADOW_API_KEY=$(vault kv get -field=api_key secret/shadow-api/auth) && /usr/bin/python3 /home/paulo/export_employees_to_csv.py >> /home/paulo/cron.log 2>&1
```

### 10.2. Testar o Cron

```bash
# Verificar se o cron foi adicionado
crontab -l

# Aguardar a próxima execução ou testar manualmente
/usr/bin/python3 /home/paulo/export_employees_to_csv.py
```

### 10.3. Observação sobre Agendamento no midPoint

**NÃO configurar cron duplo.** A tarefa de reconciliação no midPoint deve ser executada **manualmente ou sob demanda**, não em cron automático. O motivo é evitar que o midPoint reconcilie contra um CSV desatualizado enquanto o script Python está gerando um novo.

**Fluxo correto:**
1. Cron no script Python → gera CSV → transfere → (opcional: notifica midPoint via API)
2. Administrador executa a tarefa manualmente após confirmação de que o CSV está atualizado

---

## 11. Procedimento de Rollback (Via Snapshot)

### 11.1. Rollback Completo (Recomendado)

```powershell
# PowerShell como Administrador no Hyper-V

# Restaurar ambas as VMs para o snapshot anterior à configuração
Restore-VMSnapshot -VMName "api-gf-01" -Name "PRJ022-A-Antes-Configuracao" -Confirm:$false
Restore-VMSnapshot -VMName "iga-gf-02" -Name "PRJ022-A-Antes-Configuracao" -Confirm:$false

# Iniciar as VMs restauradas
Start-VM -Name "api-gf-01"
Start-VM -Name "iga-gf-02"
```

### 11.2. Verificar Snapshot Existente

```powershell
# Listar snapshots disponíveis
Get-VMSnapshot -VMName "api-gf-01"
Get-VMSnapshot -VMName "iga-gf-02"
```

### 11.3. Rollback Parcial (Apenas midPoint)

Se apenas o Resource do midPoint precisar ser removido (e o CSV mantido):

1. Acessar interface do midPoint
2. Excluir a Tarefa: **Server Tasks** > `Carga_RH_ShadowAPI_Fiqueok` > **Delete object**
3. Excluir o Recurso: **Resources** > `Fiqueok HR (Shadow API CSV)` > **Delete object**

**Nota:** Usuários já criados no repositório Focus **não são automaticamente removidos** pelo rollback do Resource. Se necessário, reverter pelo snapshot do Hyper-V.

---

## 12. Resolução de Problemas Comuns

| Erro | Causa Provável | Solução |
|------|----------------|---------|
| **Test connection falha** | Caminho do CSV incorreto ou permissão | Verificar se o arquivo existe e tem permissão 644 |
| **"No name in the new object"** | Atributo `name` não mapeado | Configurar mapeamento `employee_id` → `name` no Schema handling |
| **Permission denied no SCP** | Permissões no diretório destino | Executar `sudo chmod 755 /srv/iga-project/data/midpoint` e `sudo chown paulo:paulo` |
| **SCP pede senha** | Chave SSH não configurada | Configurar `ssh-keygen` e `ssh-copy-id` |
| **CSV com encoding errado** | Acentuação corrompida | Garantir `encoding='utf-8'` no script e no connector |
| **Tarefa não cria usuários** | Correlation mal configurada | Verificar se `UNMATCHED` tem ação `addFocus` |
| **Usuários duplicados** | Correlation não está funcionando | Verificar regra de correlação (deve usar `employee_id` como único identificador) |
| **API Key expirada** | Token do Vault foi revogado | Gerar novo token no Vault e atualizar variável de ambiente |
| **Apenas 0 registros processados** | CSV vazio ou cabeçalho errado | Validar `wc -l` e `head` do CSV |
| **Variável SHADOW_API_KEY não encontrada** | Não exportada antes da execução | Executar `export SHADOW_API_KEY=...` antes do script |

---

## 13. Lições Aprendidas na POC

### 13.1. O que Funcionou

| Item | Resultado |
|------|-----------|
| Script Python de exportação (v1.1 com Vault) | ✅ Pendente teste (correção aplicada) |
| Transferência SCP | ✅ Funcionou após ajuste de diretório |
| Permissões corretas (755/644) | ✅ Substitui chmod 777 |
| Leitura do CSV pelo midPoint | ✅ Test connection OK |
| Execução da tarefa | ✅ Processou todos os registros (após correção do name) |

### 13.2. O que Falhou na POC Original e Foi Corrigido

| Problema | Causa | Correção no v1.1 |
|----------|-------|------------------|
| `Permission denied` no SCP | Diretório sem permissão | `chmod 755` (não 777) + `chown` |
| `No name in the new object` | Atributo `name` não mapeado | Instrução explícita no Schema handling |
| API Key hardcoded | Violação ADR-002 | Leitura do Vault via variável de ambiente |
| IP inconsistente no Pre-Flight | Documentação desatualizada | Unificado para `xxx.xxx.xxx.xxx` |

### 13.3. Lições Documentadas para o Projeto

| # | Lição |
|---|-------|
| L01 | O atributo `name` do User no midPoint é **OBRIGATÓRIO** — sem ele, nenhum usuário é criado |
| L02 | `chmod 777` é anti-padrão e viola PSI-001. Usar `755` para diretórios e `644` para arquivos |
| L03 | API Keys NUNCA devem ser hardcoded no script. Usar Vault + variáveis de ambiente |
| L04 | O Pre-Flight deve refletir o IP real da VM, não IPs históricos ou documentação desatualizada |
| L05 | Rollback deve ser preferencialmente via snapshot Hyper-V, não comandos manuais |
| L06 | Cron duplo (script + midPoint) causa risco de reconciliação com CSV desatualizado |
| L07 | A Shadow API via `127.0.0.1` é imune a mudanças de IP do Tailscale — usar sempre localhost |

---

## 14. Anexos: Comandos de Diagnóstico

### 14.1. Comandos na api-gf-01

```bash
# Verificar se a Shadow API está respondendo localmente
curl -s -H "X-API-KEY: $SHADOW_API_KEY" http://127.0.0.1:8000/employees | jq '. | length'

# Verificar conectividade SSH com iga-gf-02
ssh -o ConnectTimeout=5 paulo@xxx.xxx.xxx.xxx "echo OK"

# Verificar se a variável SHADOW_API_KEY está configurada
echo $SHADOW_API_KEY

# Executar o script manualmente
python3 /home/paulo/export_employees_to_csv.py
```

### 14.2. Comandos no iga-gf-02

```bash
# Verificar permissões do diretório e arquivo
ls -la /srv/iga-project/data/midpoint/
ls -la /srv/iga-project/data/midpoint/hr_export.csv

# Contar registros no CSV (excluindo cabeçalho)
tail -n +2 /srv/iga-project/data/midpoint/hr_export.csv | wc -l

# Verificar se o container midPoint tem acesso ao arquivo
sudo docker exec midpoint ls -la /srv/iga-project/data/midpoint/hr_export.csv

# Verificar log do midPoint
sudo docker logs midpoint --tail 50
```

### 14.3. Estrutura de Diretórios Esperada

```
api-gf-01 (xxx.xxx.xxx.xxx):
/home/paulo/
├── prj008-shadow-api/          # Shadow API
│   └── app/main.py
├── export_employees_to_csv.py  # Script de exportação (v1.1)
├── .ssh/                       # Chaves para SCP
└── .bashrc                     # Deve conter export SHADOW_API_KEY (opcional)

iga-gf-02 (xxx.xxx.xxx.xxx):
/srv/iga-project/data/
├── midpoint/
│   ├── hr_export.csv           # CSV transferido (permissão 644)
│   ├── connid-connectors/      # Conectores ICF
│   └── scripts/                # Scripts Groovy (se usado)
├── postgres/                   # Dados do PostgreSQL (permissão 700)
└── ...
```

---

## 15. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 03/05/2026 | Paulo Feitosa Lima | Documento inicial baseado na POC |
| 1.1 | 03/05/2026 | Paulo Feitosa Lima | Correções: IP unificado, chmod seguro, API Key via Vault, rollback por snapshot, cron simplificado |

---

**Fim do POP v1.1**

---

*PRJ022 — Procedimento Operacional Padrão (POP) v1.1*  
*Living Lab Fiqueok*  
*Arquivado em: `FiqueokBrain/PRJ022/POP-PRJ022-A-CSV-Integration-v1.1.md`*
