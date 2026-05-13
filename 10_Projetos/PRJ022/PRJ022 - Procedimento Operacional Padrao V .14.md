

## Configuração de Recurso CSV no midPoint 4.10 para Consumo da Shadow API

**Versão:** 1.4  
**Data:** Maio/2026  
**Status:** ✅ **VALIDADO** — Baseado na execução da POC, nas lições do PRJ004 e na validação prática do PRJ022  
**Responsável:** Paulo Feitosa Lima  
**Auditoria:** ISO 27001, NIST SP 800-53, CIS Controls, PCI-DSS, SOX, LGPD

---

## ÍNDICE

1. [Objetivo do Documento](#1-objetivo-do-documento)
2. [Arquitetura da Solução](#2-arquitetura-da-solução)
3. [Conceitos Fundamentais (Leitura Obrigatória)](#3-conceitos-fundamentais-leitura-obrigatória)
4. [Pré-Requisitos Obrigatórios](#4-pré-requisitos-obrigatórios)
5. [Checklist de Pré-Verificação (Pre-Flight)](#5-checklist-de-pré-verificação-pre-flight)
6. [Procedimento de Rollback (Via Snapshot)](#6-procedimento-de-rollback-via-snapshot)
7. [Passo 1: Configuração na api-gf-01 (Script de Exportação)](#7-passo-1-configuração-na-api-gf-01-script-de-exportação)
8. [Passo 2: Configuração no iga-gf-02 (Preparação do Ambiente)](#8-passo-2-configuração-no-iga-gf-02-preparação-do-ambiente)
9. [Passo 3: Criação do Recurso CSV no midPoint](#9-passo-3-criação-do-recurso-csv-no-midpoint)
10. [Passo 4: Configuração do Schema Handling (Object Type)](#10-passo-4-configuração-do-schema-handling-object-type)
11. [Passo 5: Configuração dos Mappings (Inbound)](#11-passo-5-configuração-dos-mappings-inbound)
12. [Passo 6: Configuração da Correlation](#12-passo-6-configuração-da-correlation)
13. [Passo 7: Configuração da Synchronization](#13-passo-7-configuração-da-synchronization)
14. [Passo 8: Criação da Tarefa de Reconciliação](#14-passo-8-criação-da-tarefa-de-reconciliação)
15. [Passo 9: Execução e Validação](#15-passo-9-execução-e-validação)
16. [Passo 10: Agendamento Automático (Opcional)](#16-passo-10-agendamento-automático-opcional)
17. [Resolução de Problemas Comuns](#17-resolução-de-problemas-comuns)
18. [Lições Aprendidas e Compliance](#18-lições-aprendidas-e-compliance)
19. [Anexos: Comandos de Diagnóstico](#19-anexos-comandos-de-diagnóstico)
20. [Histórico de Versões](#20-histórico-de-versões)

---

## 1. Objetivo do Documento

Este Procedimento Operacional Padrão (POP) descreve o passo a passo para configurar a integração entre a **Shadow API (PRJ008)** e o **midPoint 4.10** utilizando o **CsvConnector** nativo como solução de fallback (PRJ022-A).

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
│  │  127.0.0.1:8000 │     │   _to_csv.py)   │     │ midpoint/hr_export.csv  ││
│  └─────────────────┘     └─────────────────┘     └─────────────────────────┘│
│         │                                                                     │
│         │ HTTP GET com X-API-KEY (via Vault)                                 │
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
│  │                                          │     (102 usuários criados)  │││
│  │                                          └─────────────────────────────┘││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Conceitos Fundamentais (Leitura Obrigatória)

Antes de iniciar a execução, é fundamental entender o que cada componente faz e por que estamos configurando desta forma.

### 3.1. O que é um Resource no midPoint?

Um **Resource** é a representação de um sistema externo que contém identidades (usuários, contas, grupos). Pode ser um banco de dados, um arquivo CSV, um diretório LDAP, uma API REST, etc.

**No nosso caso:** O Resource vai apontar para o arquivo CSV gerado pela Shadow API. O midPoint vai "ler" este CSV como se fosse uma lista de contas de um sistema remoto.

### 3.2. O Wizard de Criação do Resource (4 Telas)

O midPoint 4.10 utiliza um assistente (**wizard**) com 4 telas obrigatórias para criar um Resource CSV:

| Tela | Nome | Propósito | O que fazemos |
|------|------|-----------|---------------|
| **1** | Basic Information | Identificar o Resource no sistema | Dar um nome, descrição e ativar |
| **2** | Configuration | Conectar o midPoint ao arquivo CSV | Informar caminho, delimitador, encoding |
| **3** | Discovery | "Descobrir" a estrutura do CSV | Aguardar leitura e validar atributos |
| **4** | Schema | Revisar a estrutura descoberta | Confirmar Object Class e criar |

### 3.3. O Wizard de Object Type (8 Blocos)

Após criar o Resource, precisamos definir um **Object Type** dentro do **Schema handling**. Este Object Type diz ao midPoint:

- Quais dados do CSV serão importados
- Que tipo de objeto eles representam (Account)
- Para que tipo de foco eles serão convertidos (User)

O midPoint 4.10 usa um wizard com os seguintes blocos (os que configuramos):

| Bloco | Propósito |
|-------|-----------|
| **Mappings** | Mapeia colunas do CSV para atributos do User |
| **Correlation** | Define como identificar se usuário já existe |
| **Synchronization** | Define o que fazer quando encontra (ou não) um usuário |

### 3.4. A Tela Discovery — A Mais Importante

Na tela **Discovery**, o midPoint pede que você identifique **duas colunas especiais** do seu CSV:

| Campo | O que significa | Por que é importante |
|-------|----------------|----------------------|
| **Name attribute** | A coluna que identifica **cada objeto** dentro do Resource | O midPoint usa este valor para nomear a "shadow" |
| **Unique attribute name** | A coluna que garante que não há registros duplicados | Evita duplicidade de contas no Resource |

### 3.5. De onde vem o `employee_id`? Por que escolher ele?

O arquivo CSV gerado pelo script Python contém as seguintes colunas:

| Coluna | Origem (Shadow API) | Descrição |
|--------|---------------------|-----------|
| `emp_number` | `emp_number` do OrangeHRM | Número interno do funcionário (inteiro) |
| **`employee_id`** | `employee_id` do OrangeHRM | **Identificador de negócio** (ex: `0001`, `FP008`) |
| `first_name` | `first_name` do funcionário | Primeiro nome |
| `last_name` | `last_name` do funcionário | Sobrenome |

**Decisão:** Selecionar `employee_id` como **Name attribute** e **Unique attribute name** porque:

1. **É o identificador de negócio** — o mesmo usado no Active Directory (`employeeID`)
2. **Garante correlação correta** — o midPoint consegue encontrar o usuário existente
3. **É imutável** — não muda mesmo se o funcionário trocar de nome
4. **Já foi validado no PRJ004** — a integração via CSV funcionou com `employee_id`

### 3.6. O que é Correlation?

**Correlation** é o mecanismo que o midPoint usa para responder à pergunta:

> *"Este registro do CSV já existe como um usuário no meu sistema?"*

| Situação | O que o midPoint faz |
|----------|---------------------|
| **Match encontrado** | Vincula a conta do CSV ao usuário existente (não cria duplicata) |
| **Match não encontrado** | Considera como `UNMATCHED` e aplica a reação configurada |

### 3.7. O que é Synchronization?

**Synchronization** define as reações automáticas que o midPoint toma com base nos resultados da correlação:

| Situation | Action | O que acontece |
|-----------|--------|----------------|
| **Unmatched** | `addFocus` | Cria um novo usuário no midPoint |
| **Matched** | `link` | Vincula a conta ao usuário existente (opcional) |
| **Deleted** | `unlink` ou `delete` | Remove o vínculo ou desabilita o usuário |

### 3.8. O que é uma Reconciliation Task?

Uma **Reconciliation Task** é o mecanismo que executa o "motor" configurado. Ela:

1. Lê o arquivo CSV
2. Aplica as regras de **Mappings** (transforma dados)
3. Aplica as regras de **Correlation** (encontra ou não usuários existentes)
4. Aplica as regras de **Synchronization** (cria, atualiza ou remove usuários)

---

## 4. Pré-Requisitos Obrigatórios

| #     | Pré-Requisito                                              | Verificação                                                | Critério           |
| ----- | ---------------------------------------------------------- | ---------------------------------------------------------- | ------------------ |
| PR-01 | Shadow API operacional em `api-gf-01` (IP `xxx.xxx.xxx.xxx`) | `curl -H "X-API-KEY: ..." http://127.0.0.1:8000/employees` | HTTP 200 + JSON    |
| PR-02 | Python 3.12+ instalado em `api-gf-01`                      | `python3 --version`                                        | 3.12+              |
| PR-03 | Python `requests` instalado                                | `pip3 list \| grep requests`                               | requests instalado |
| PR-04 | Conexão SSH entre `api-gf-01` e `iga-gf-02`                | `ssh paulo@xxx.xxx.xxx.xxx`                                  | Login OK           |
| PR-05 | Chave SSH configurada para SCP sem senha                   | `ssh -o BatchMode=yes paulo@xxx.xxx.xxx.xxx "echo OK"`       | OK sem pedir senha |
| PR-06 | midPoint 4.10 operacional em `iga-gf-02`                   | `docker ps \| grep midpoint`                               | Container running  |
| PR-07 | Acesso ao Vault para obter API Key                         | `vault kv get secret/shadow-api/auth`                      | Chave disponível   |
| PR-08 | Snapshot das VMs criado                                    | `Get-VMSnapshot -VMName "api-gf-01"`                       | Checkpoint existe  |

---

## 5. Checklist de Pré-Verificação (Pre-Flight)

Execute os comandos abaixo **antes** de iniciar qualquer configuração.

### 5.1. Verificar Shadow API

```bash
# [api-gf-01]$ (acessar via ssh paulo@xxx.xxx.xxx.xxx)
curl -s -o /dev/null -w "%{http_code}" -H "X-API-KEY: Fiqueok-Security-Token-2026" \
  http://127.0.0.1:8000/employees
# Deve retornar: 200
```

### 5.2. Verificar Conectividade entre VMs

```bash
# [api-gf-01]$
ping -c 2 xxx.xxx.xxx.xxx
# Deve ter 0% packet loss
```

### 5.3. Verificar Chave SSH para SCP sem Senha

```bash
# [api-gf-01]$
ssh -o BatchMode=yes -o ConnectTimeout=5 paulo@xxx.xxx.xxx.xxx "echo OK"
# Deve retornar: OK (sem pedir senha)
```

### 5.4. Verificar Permissões do Diretório no iga-gf-02

```bash
# [iga-gf-02]$ (acessar via ssh paulo@xxx.xxx.xxx.xxx)
ls -la /srv/iga-project/data/midpoint/
# Deve mostrar diretório com permissões drwxr-xr-x (755)
```

### 5.5. Verificar Estado do midPoint

```bash
# [WinHost]$ (PowerShell)
curl -s -o /dev/null -w "%{http_code}" http://xxx.xxx.xxx.xxx:8080/midpoint
# Deve retornar: 200
```

### 5.6. Identificar o Nome do Container do midPoint

```bash
# [iga-gf-02]$
sudo docker ps --format "table {{.Names}}\t{{.Image}}" | grep -i midpoint
# Exemplo de saída: iga-midpoint   evolveum/midpoint:4.10
```

### 5.7. Verificar Mapeamento de Volumes do Docker

```bash
# [iga-gf-02]$
grep -A 5 "volumes:" /srv/iga-project/docker-compose.yml
# Deve mostrar: - ./data/midpoint:/opt/midpoint/var
```

### 5.8. Criar Snapshot de Segurança (OBRIGATÓRIO)

```powershell
# [WinHost]$ (PowerShell como Administrador)
Checkpoint-VM -VMName "api-gf-01" -SnapshotName "PRJ022-A-Antes-Configuracao"
Checkpoint-VM -VMName "iga-gf-02" -SnapshotName "PRJ022-A-Antes-Configuracao"
```

---

## 6. Procedimento de Rollback (Via Snapshot)

### 6.1. Rollback Completo (Recomendado)

```powershell
# [WinHost]$ (PowerShell como Administrador)
Restore-VMSnapshot -VMName "api-gf-01" -Name "PRJ022-A-Antes-Configuracao" -Confirm:$false
Restore-VMSnapshot -VMName "iga-gf-02" -Name "PRJ022-A-Antes-Configuracao" -Confirm:$false

Start-VM -Name "api-gf-01"
Start-VM -Name "iga-gf-02"
```

### 6.2. Procedimento Pós-Rollback (Verificações Obrigatórias)

Após restaurar os snapshots, execute estas verificações:

```bash
# [iga-gf-02]$
# 1. Verificar owner do diretório
ls -la /srv/iga-project/data/ | grep midpoint
# Se owner não for paulo:paulo, executar:
sudo chown paulo:paulo /srv/iga-project/data/midpoint/

# 2. Verificar permissões
sudo chmod 755 /srv/iga-project/data/midpoint/

# 3. Verificar se o CSV ainda existe (opcional)
ls -la /srv/iga-project/data/midpoint/hr_export.csv
```

---

## 7. Passo 1: Configuração na api-gf-01 (Script de Exportação)

### 7.1. Acessar a VM da Shadow API

```bash
# [WinHost]$
ssh paulo@xxx.xxx.xxx.xxx
```

### 7.2. Obter a API Key do Vault (Variável de Ambiente)

```bash
# [api-gf-01]$
export SHADOW_API_KEY=$(curl -s -H "X-Vault-Token: $(cat /var/lib/shadow-api/vault_token)" \
  http://xxx.xxx.xxx.xxx:8200/v1/secret/data/shadow-api/auth | jq -r '.data.data.api_key')

# Validar
echo $SHADOW_API_KEY
# Deve mostrar: Fiqueok-Security-Token-2026
```

### 7.3. Criar o Script de Exportação

```bash
# [api-gf-01]$
nano /home/paulo/export_employees_to_csv.py
```

### 7.4. Conteúdo do Script (VERSÃO COMPLETA)

```python
#!/usr/bin/env python3
"""
PRJ022-A - Script de Exportação de Funcionários da Shadow API para CSV
Versão: 1.4
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
    raise ValueError("❌ Variável de ambiente SHADOW_API_KEY não configurada")

OUTPUT_DIR = "/tmp/csv_export"
MIDPOINT_HOST = "xxx.xxx.xxx.xxx"
MIDPOINT_USER = "paulo"
MIDPOINT_PATH = "/srv/iga-project/data/midpoint/hr_export.csv"

# <REDACTED_SECRET>====================
# FUNÇÃO: Exportar dados da Shadow API para CSV
# <REDACTED_SECRET>====================
def export():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    headers = {"X-API-KEY": API_KEY}
    response = requests.get(SHADOW_API_URL, headers=headers, timeout=10)
    response.raise_for_status()
    employees = response.json()
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{OUTPUT_DIR}/employees_{timestamp}.csv"
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=['emp_number', 'employee_id', 'first_name', 'last_name'])
        writer.writeheader()
        writer.writerows(employees)
    print(f"✅ Exportado {len(employees)} funcionários para {filename}")
    return filename

# <REDACTED_SECRET>====================
# FUNÇÃO: Sincronizar CSV com o midPoint via SCP
# <REDACTED_SECRET>====================
def sync_to_midpoint(filename):
    print(f"🔄 Sincronizando com {MIDPOINT_HOST}...")
    try:
        # Primeiro copia para /tmp
        tmp_path = f"/tmp/hr_export.csv"
        cmd_scp = ["scp", "-o", "StrictHostKeyChecking=no", filename, f"{MIDPOINT_USER}@{MIDPOINT_HOST}:{tmp_path}"]
        subprocess.run(cmd_scp, check=True)
        
        # Depois move com sudo para o local definitivo
        cmd_move = ["ssh", f"{MIDPOINT_USER}@{MIDPOINT_HOST}", 
                    f"sudo mv {tmp_path} {MIDPOINT_PATH} && sudo chown paulo:paulo {MIDPOINT_PATH} && sudo chmod 644 {MIDPOINT_PATH}"]
        subprocess.run(cmd_move, check=True)
        print(f"✅ Sincronização concluída.")
    except Exception as e:
        print(f"❌ Falha: {e}")

# <REDACTED_SECRET>====================
# EXECUÇÃO PRINCIPAL
# <REDACTED_SECRET>====================
if __name__ == "__main__":
    try:
        generated_file = export()
        if generated_file:
            sync_to_midpoint(generated_file)
    except Exception as e:
        print(f"❌ Erro: {e}")
```

### 7.5. Tornar o Script Executável e Testar

```bash
# [api-gf-01]$
chmod +x /home/paulo/export_employees_to_csv.py
python3 /home/paulo/export_employees_to_csv.py
```

**Saída esperada:**
```
✅ Exportado 102 funcionários para /tmp/csv_export/employees_20260503_220442.csv
🔄 Sincronizando com xxx.xxx.xxx.xxx...
✅ Sincronização concluída.
```

---

## 8. Passo 2: Configuração no iga-gf-02 (Preparação do Ambiente)

### 8.1. Acessar a VM do midPoint

```bash
# [WinHost]$
ssh paulo@xxx.xxx.xxx.xxx
```

### 8.2. Verificar e Ajustar Permissões

```bash
# [iga-gf-02]$
# Verificar permissões atuais
ls -la /srv/iga-project/data/midpoint/

# Ajustar permissões (NÃO usar 777)
sudo chown paulo:paulo /srv/iga-project/data/midpoint/
sudo chmod 755 /srv/iga-project/data/midpoint/

# Verificar o CSV
ls -la /srv/iga-project/data/midpoint/hr_export.csv
# Deve mostrar: -rw-r--r-- (644) e o arquivo
```

### 8.3. Validar o Conteúdo do CSV

```bash
# [iga-gf-02]$
head -5 /srv/iga-project/data/midpoint/hr_export.csv
# Deve mostrar cabeçalho e primeiras linhas

wc -l /srv/iga-project/data/midpoint/hr_export.csv
# Deve mostrar 103 (1 cabeçalho + 102 funcionários)
```

---

## 9. Passo 3: Criação do Recurso CSV no midPoint

### 9.1. Acessar a Interface Web do midPoint

- URL: `http://xxx.xxx.xxx.xxx:8080/midpoint`
- Usuário: `administrator`
- Senha: `M1dP0!ntAdm!n#2026`

### 9.2. Criar Novo Recurso

1. No menu lateral, clique em **Resources** > **All resources**
2. Clique no botão **New resource** (canto superior direito)
3. Na tela "Resource catalog", escolha **Create from scratch**
4. No catálogo de conectores, localize e selecione **CsvConnector** (v2.9)

### 9.3. Tela 1 — Basic Information

| Campo | Valor |
|-------|-------|
| **Name** | `Fiqueok HR (Shadow API CSV)` |
| **Description** | `Importa funcionários da Shadow API via CSV (fallback)` |
| **Lifecycle state** | `Active (production)` (NÃO deixar como Proposed) |

Clique em **Next: Configuration**

### 9.4. Tela 2 — Configuration (CRÍTICO)

| Campo | Valor | Observação |
|-------|-------|------------|
| **File path** | `/opt/midpoint/var/hr_export.csv` | Caminho DENTRO do container |
| **Delimiter** | `,` | Vírgula |
| **Encoding** | `UTF-8` | Obrigatório para acentuação |
| **Header** | `true` | Primeira linha é cabeçalho |

Clique em **Next: Discovery**

### 9.5. Tela 3 — Discovery (CRÍTICO — NÃO PULAR)

O midPoint leu o CSV e está pedindo confirmação de quais colunas representam os atributos de identidade.

| Campo | Valor | Observação |
|-------|-------|------------|
| **Multivalue delimiter** | `;` (padrão) | Manter |
| **Field delimiter** | `,` | Confirmar |
| **User password attribute name** | (deixar em branco) | Não importamos senhas |
| **Name attribute *** | `employee_id` | Identificador do objeto no recurso |
| **Unique attribute name *** | `employee_id` | Garante unicidade |

Clique em **Next: Schema**

### 9.6. Tela 4 — Schema (Object Class)

| Elemento | Ação |
|----------|------|
| **AccountObjectClass** | Verificar se está selecionado (marcado) |

**O que NÃO aparece nesta tela:** Lista de atributos individuais (`emp_number`, `first_name`, etc.). Eles serão configurados no Schema handling APÓS a criação do recurso.

Clique no botão verde **Create resource**

---

## 10. Passo 4: Configuração do Schema Handling (Object Type)

Após criar o recurso, você será redirecionado para a tela principal do recurso.

### 10.1. Acessar Schema handling

1. No menu lateral esquerdo, clique em **Schema handling**
2. Clique no botão **Add object type**

### 10.2. Tela 1 — Basic Information

| Campo | Valor | Explicação |
|-------|-------|------------|
| **Display name** | `Colaborador HR` | Nome amigável |
| **Description** | (deixar vazio) | Opcional |
| **Kind** | `Account` | Tipo de objeto |
| **Intent** | `default` | Sub-tipo |
| **Security policy** | `Undefined` (manter) | Política de segurança (não necessário) |
| **Lifecycle state** | `Active (production)` | Ativo |

Clique em **Next: Resource data**

### 10.3. Tela 2 — Resource Data

| Campo | Valor |
|-------|-------|
| **Object class** | `AccountObjectClass` (já selecionado) |
| **Auxiliary object class** | (não adicionar nada) |
| **Filter** | (não adicionar nada) |

Clique em **Next: MidPoint data**

### 10.4. Tela 3 — MidPoint Data

| Campo | Valor |
|-------|-------|
| **Type** | `User` |
| **Archetype** | `No archetype` (manter) |

Clique em **Save settings**

### 10.5. Acessar o Wizard de Object Type

Após salvar, você voltará para a lista de Object Types. **Clique no nome do Object Type (`Colaborador HR`)** para abrir o wizard de 8 blocos.

---

## 11. Passo 5: Configuração dos Mappings (Inbound)

No wizard de Object Type, clique no bloco **Mappings**.

### 11.1. Adicionar mapeamento do `employee_id` → `name` (CRÍTICO)

Clique em **Add inbound** e preencha:

| Campo | Valor |
|-------|-------|
| **Name** | `Mapeamento de Nome de Sistema` |
| **From resource attribute** | `employee_id` |
| **Strength** | `Strong` |
| **Expression** | `As is` |
| **Target** | `name` |
| **Lifecycle state** | `Active (production)` |

**Por que este mapeamento é crítico?** O atributo `name` é **obrigatório** no midPoint. Sem ele, erro `"No name in the new object"`.

### 11.2. Adicionar mapeamento do `employee_id` → `personalNumber`

Clique em **Add inbound** e preencha:

| Campo | Valor |
|-------|-------|
| **Name** | `Mapeamento de Matrícula` |
| **From resource attribute** | `employee_id` |
| **Strength** | `Strong` |
| **Expression** | `As is` |
| **Target** | `personalNumber` |
| **Lifecycle state** | `Active (production)` |

**Por que?** Este campo será a **chave de correlação** para o midPoint.

### 11.3. Adicionar mapeamento do `first_name` → `givenName`

Clique em **Add inbound** e preencha:

| Campo | Valor |
|-------|-------|
| **Name** | `Mapeamento de Primeiro Nome` |
| **From resource attribute** | `first_name` |
| **Strength** | `Normal` (padrão) |
| **Expression** | `As is` |
| **Target** | `givenName` |
| **Lifecycle state** | `Active (production)` |

### 11.4. Adicionar mapeamento do `last_name` → `familyName`

Clique em **Add inbound** e preencha:

| Campo | Valor |
|-------|-------|
| **Name** | `Mapeamento de Sobrenome` |
| **From resource attribute** | `last_name` |
| **Strength** | `Normal` (padrão) |
| **Expression** | `As is` |
| **Target** | `familyName` |
| **Lifecycle state** | `Active (production)` |

### 11.5. Salvar os Mappings

1. Clique no botão verde **Save mappings**
2. Clique em **Exit wizard** para voltar à tela principal do wizard de 8 blocos

---

## 12. Passo 6: Configuração da Correlation

No wizard de Object Type, clique no bloco **Correlation**.

### 12.1. Adicionar Regra de Correlação

Clique em **Add rule** e preencha os campos da regra:

| Campo | Valor |
|-------|-------|
| **Rule name** | `Correlacao_employee_id` |
| **Description** | (deixar vazio) |
| **Weight** | `1` |
| **Tier** | `1` |
| **Ignore if matched by** | `Undefined` (manter) |
| **Enabled** | ✅ (marcado) |

### 12.2. Configurar os Itens de Correlação

Após criar a regra, é necessário configurar o **item de correlação** que define quais atributos serão comparados.

Clique em **Add correlator** e preencha:

| Campo | Valor |
|-------|-------|
| **Search method** | `Item` (Exact match) |
| **Source attribute** | `employee_id` |
| **Target attribute** | `personalNumber` |
| **Match threshold** | (deixar vazio) |
| **Exclusive** | (deixar desmarcado) |

### 12.3. Finalizar a Configuração da Correlação

1. Clique em **Confirm settings** para confirmar o item de correlação
2. Clique em **Save correlation settings** para salvar a regra completa

### 12.4. Por que a Correlação é Obrigatória

O CsvConnector v2.9 no midPoint 4.10 exige uma configuração explícita de correlação para que o motor de sincronização possa identificar se um registro do CSV já existe como usuário no repositório. Sem esta configuração, a tarefa de reconciliação falha com o erro:

```
Error occurred during resource object shadow owner lookup, 
reason: No correlator configurations in CompositeCorrelatorType
```

A configuração descrita acima estabelece que o atributo `employee_id` do CSV deve ser comparado com o atributo `personalNumber` do usuário existente. Quando um match é encontrado, o midPoint vincula a conta ao usuário; quando não encontrado, a situação `UNMATCHED` é acionada e a Synchronization cria um novo usuário.

---

## 13. Passo 7: Configuração da Synchronization

No wizard de Object Type, clique no bloco **Synchronization**.

### 13.1. Adicionar reação para criação de usuários

Clique em **Add reaction** e preencha:

| Campo | Valor |
|-------|-------|
| **Name** | `Criar Novo Usuario` |
| **Situation *** | `Unmatched` |
| **Action** | `addFocus` |
| **Lifecycle state** | `Active (production)` |

### 13.2. Salvar a Synchronization

1. Clique no botão verde **Save synchronization settings**
2. Clique em **Exit wizard** para voltar à tela principal do recurso

---

## 14. Passo 8: Criação da Tarefa de Reconciliação

### 14.1. Acessar Defined Tasks

No menu lateral do recurso, clique em **Defined Tasks**

### 14.2. Criar Nova Tarefa

Clique em **Create task** > **Reconciliation Task**

### 14.3. Tela 1 — Basic

| Campo | Valor |
|-------|-------|
| **Name** | `Reconciliacao CSV PRJ022` |
| **Description** | `Importa os funcionários do CSV gerado pela Shadow API` |
| **Documentation** | (deixar vazio) |
| **Owner** | (deixar vazio) |
| **Category** | (deixar vazio) |

Clique em **Next** ou vá para a aba **Activity**

### 14.4. Tela 2 — Activity (Configuração dos Resource Objects)

| Campo | Valor |
|-------|-------|
| **Resource** | `Fiqueok HR (Shadow API CSV)` |
| **Kind** | `Account` |
| **Intent** | `default` |
| **Object class** | `AccountObjectClass` |

**As demais seções (Work, Control flow, Distribution, Policies, Tailoring, Execution, Reporting):** DEIXAR TODAS VAZIAS ou com os valores padrão.

### 14.5. Tela 3 — Schedule

- **Não preencher nada** (execução manual imediata)

### 14.6. Tela 4 — Advanced options e Operational attributes

- **Não preencher nada** (manter valores padrão)

### 14.7. Finalizar

Clique em **Save & Run** (botão verde)

---

## 15. Passo 9: Execução e Validação

### 15.1. Monitorar a Execução

1. Após clicar em "Save & Run", você voltará para a lista de **Defined Tasks**
2. O status da tarefa aparecerá como **RUNNING**
3. Clique no nome da tarefa para ver os detalhes
4. Verifique o contador de **Resource objects processed** — deve chegar a **102**

### 15.2. Aguardar Conclusão

A tarefa deve levar alguns segundos para processar 102 registros. O status mudará para **CLOSED** quando concluída.

### 15.3. Validar Usuários Criados

1. Navegue até **Users** > **All users**
2. Verifique se os novos usuários aparecem com:
   - `name` = `employee_id` (ex: `0001`, `FP008`)
   - `givenName` = primeiro nome
   - `familyName` = sobrenome
   - `personalNumber` = `employee_id`

---

## 16. Passo 10: Agendamento Automático (Opcional)

### 16.1. Configurar Cron no Script de Exportação (api-gf-01)

```bash
# [api-gf-01]$
crontab -e

# Adicionar linha para execução a cada 4 horas
0 */4 * * * export SHADOW_API_KEY=$(vault kv get -field=api_key secret/shadow-api/auth) && /usr/bin/python3 /home/paulo/export_employees_to_csv.py >> /home/paulo/cron.log 2>&1
```

### 16.2. Configurar Tarefa Periódica no midPoint (Opcional)

Se desejar que o midPoint execute automaticamente:

1. Vá até **Server Tasks** > localize a tarefa criada
2. Clique em **Edit** (lápis)
3. Vá até a aba **Schedule**
4. Configure o cron desejado (ex: `0 0 */4 * * ?` para cada 4 horas)
5. Salve

**Observação:** Recomenda-se apenas um dos dois agendamentos para evitar reconciliação com CSV desatualizado.

---

## 17. Resolução de Problemas Comuns

| Erro | Causa Provável | Solução |
|------|----------------|---------|
| **Test connection falha** | Caminho do CSV incorreto ou permissão | Verificar `/opt/midpoint/var/hr_export.csv` e permissões 755 no diretório |
| **"No name in the new object"** | Atributo `name` não mapeado | Verificar Mappings: `employee_id` → `name` |
| **Permission denied no SCP** | Permissões no diretório destino | Executar `sudo chown paulo:paulo /srv/iga-project/data/midpoint/` |
| **SCP pede senha** | Chave SSH não configurada | Executar `ssh-copy-id paulo@xxx.xxx.xxx.xxx` |
| **Tarefa não cria usuários** | Synchronization mal configurada | Verificar `UNMATCHED` → `addFocus` |
| **Usuários duplicados** | Correlation não está funcionando | Verificar se `employee_id` → `personalNumber` está configurado na Correlation |
| **No correlator configurations** | Correlation não configurada | Seguir o Passo 6 para criar regra de correlação |
| **Container do midPoint não encontra o CSV** | Mapeamento de volumes incorreto | Verificar `docker-compose.yml`: `./data/midpoint:/opt/midpoint/var` |
| **CSV dentro do container tem apenas 1 linha** | Sincronização do arquivo falhou | Executar `sudo docker cp /srv/.../hr_export.csv iga-midpoint:/opt/midpoint/var/` |

---

## 18. Lições Aprendidas e Compliance

### 18.1. Lições Técnicas (PRJ022)

| # | Lição |
|---|-------|
| L01 | O atributo `name` do User é **obrigatório** — sem ele, erro "No name in the new object" |
| L02 | O caminho do CSV no midPoint deve ser o **caminho dentro do container** (`/opt/midpoint/var/`), não do host |
| L03 | `chmod 777` é anti-padrão — usar `755` para diretórios e `644` para arquivos |
| L04 | API Keys **nunca** devem ser hardcoded — usar Vault + variáveis de ambiente |
| L05 | O wizard de criação do Resource tem 4 telas obrigatórias; nenhuma pode ser pulada |
| L06 | Na tela Discovery, é obrigatório selecionar `employee_id` como Name attribute e Unique attribute name |
| L07 | O wizard de Object Type tem 8 blocos; Mappings, Correlation e Synchronization são os essenciais |
| L08 | O mapeamento `employee_id` → `personalNumber` com **Strength Strong** é parte da estratégia de correlação |
| L09 | O botão "Save & Run" na tarefa salva **e** executa imediatamente |
| L10 | A configuração explícita de Correlation é **OBRIGATÓRIA** no midPoint 4.10 com CsvConnector v2.9 |
| L11 | O item de correlação deve configurar `employee_id` (source) → `personalNumber` (target) com Search method = Item |
| L12 | O arquivo CSV deve ser validado dentro do container após cada atualização |
| L13 | A tarefa de reconciliação antiga deve ser deletada antes de criar uma nova após mudanças na configuração |

### 18.2. Verificações Obrigatórias Antes da Execução

| # | Verificação | Comando |
|---|-------------|---------|
| V01 | CSV tem 103 linhas no host | `wc -l /srv/iga-project/data/midpoint/hr_export.csv` |
| V02 | CSV tem 103 linhas no container | `sudo docker exec iga-midpoint wc -l /opt/midpoint/var/hr_export.csv` |
| V03 | Correlation rule está criada | Verificar no GUI se a regra `Correlacao_employee_id` existe |
| V04 | Correlation item está configurado | Verificar se `employee_id` → `personalNumber` está configurado |
| V05 | Synchronization tem Unmatched → addFocus | Verificar no bloco Synchronization |
| V06 | Tarefa antiga foi deletada | Verificar se não há tarefas em estado CLOSED |

### 18.3. Frameworks de Compliance Aplicados

| Framework | Controle | Implementação |
|-----------|----------|---------------|
| **ISO 27001** | A.5.15 (Menor Privilégio) | Usuário `svc_shadow_api` com SELECT apenas |
| **ISO 27001** | A.8.12 (Gestão de Segredos) | API Key no Vault, não hardcoded |
| **ISO 27001** | A.8.15 (Logging) | Log de exportação e logs do midPoint |
| **ISO 27001** | A.8.15 (Log de Auditoria) | Transições de estado registradas na tarefa |
| **NIST SP 800-53** | SA-15 (Dependências) | Validação de mapeamento de volumes |
| **CIS Controls** | 4 (Secure Configuration) | Permissões 755/644, não 777 |
| **PCI-DSS v4.0** | 6.3 (Dev Seguro) | Script Python validado |
| **SOX** | Segregação de deveres | Separação entre exportação (script) e importação (midPoint) |
| **LGPD** | Art. 46 (Segurança) | CSV tratado com UTF-8, permissões restritas |

---

## 19. Anexos: Comandos de Diagnóstico

### 19.1. Comandos na api-gf-01

```bash
# Verificar Shadow API
curl -s -H "X-API-KEY: $SHADOW_API_KEY" http://127.0.0.1:8000/employees | jq '. | length'

# Executar script manualmente
python3 /home/paulo/export_employees_to_csv.py

# Verificar variável de ambiente
echo $SHADOW_API_KEY
```

### 19.2. Comandos no iga-gf-02

```bash
# Verificar permissões
ls -la /srv/iga-project/data/midpoint/

# Verificar CSV no host
head -5 /srv/iga-project/data/midpoint/hr_export.csv
wc -l /srv/iga-project/data/midpoint/hr_export.csv

# Verificar CSV dentro do container
sudo docker exec iga-midpoint head -5 /opt/midpoint/var/hr_export.csv
sudo docker exec iga-midpoint wc -l /opt/midpoint/var/hr_export.csv

# Verificar container
sudo docker ps | grep midpoint

# Verificar mapeamento de volumes
grep -A 5 "volumes:" /srv/iga-project/docker-compose.yml

# Verificar log do midPoint
sudo docker logs iga-midpoint --tail 100

# Verificar logs específicos de reconciliação
sudo docker logs iga-midpoint --tail 500 | grep -E "processed|correlation|unmatched"
```

### 19.3. Comandos no Hyper-V (PowerShell)

```powershell
# Listar snapshots
Get-VMSnapshot -VMName "api-gf-01"
Get-VMSnapshot -VMName "iga-gf-02"

# Restaurar snapshot
Restore-VMSnapshot -VMName "iga-gf-02" -Name "PRJ022-A-Antes-Configuracao" -Confirm:$false
```

---

## 20. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 03/05/2026 | Paulo Feitosa Lima | Documento inicial baseado na POC |
| 1.1 | 03/05/2026 | Paulo Feitosa Lima | Correções: IP unificado, chmod seguro, API Key via Vault, rollback por snapshot |
| 1.2 | 03/05/2026 | Paulo Feitosa Lima | Adicionadas: seção explicativa completa, wizard de 4 telas do Resource, wizard de 3 telas do Object Type, tela Discovery com Name/Unique attribute, Correlation com campos explicados, Synchronization, wizard de 4 telas da tarefa, procedimento pós-rollback, comandos de diagnóstico por VM |
| 1.3 | 03/05/2026 | Paulo Feitosa Lima | Estratégia de Correlation: Projeção Direta. Documentadas as tentativas fracassadas com `<source>`, `<expression>` e `<filter>` |
| **1.4** | **04/05/2026** | **Paulo Feitosa Lima** | **Correlation explícita OBRIGATÓRIA. Adicionado Passo 6 completo com criação de regra e item de correlação `employee_id` → `personalNumber`. Incluídas verificações V01-V06. Atualizada Resolução de Problemas. Lições L10-L13 adicionadas.** |

---

**Fim do POP v1.4**

---

*PRJ022 — Procedimento Operacional Padrão (POP) v1.4*  
*Living Lab Fiqueok*  
*Arquivado em: `FiqueokBrain/PRJ022/POP-PRJ022-A-CSV-Integration-v1.4.md`*
