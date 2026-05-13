# TERMO DE ABERTURA DE PROJETO (TAP) - PROJ018 v1.1

## **Migração de Base de Conhecimento Perplexity para Ecossistema Local (Ollama + AnythingLLM + HashiCorp Vault)**

---

| **Campo** | **Valor** |
|:---|:---|
| **ID do Projeto** | PROJ018 |
| **Versão** | 1.1 (Final) |
| **Patrocinador** | Fiqueok Lab / Living Lab de Governança de TI |
| **Gerente do Projeto** | Arquiteto de Soluções (a definir) |
| **Data de Aprovação** | (Data atual) |
| **Classificação** | CONFIDENCIAL - Dados Técnicos e de Auditoria |
| **Sigilo** | Alto (envolve token de acesso a serviço de IA em nuvem) |

---

## 1. IDENTIFICAÇÃO DO PROJETO

### 1.1. Nome do Projeto
**PROJ018 - Migração de Base de Conhecimento Perplexity para Ecossistema Local (Ollama + Obsidian/AnythingLLM)**

### 1.2. Escopo Resumido
Extrair, armazenar e indexar localmente todo o histórico de conversas, threads e artefatos técnicos gerados na plataforma Perplexity AI, alimentando um sistema de **RAG (Retrieval-Augmented Generation)** baseado em **DeepSeek-R1 (7b)** e **bge-m3 (embedding)** para suporte à elaboração de documentos de Segurança da Informação, Auditoria ISO 27001 e Gestão de Identidade e Acesso (IAM).

### 1.3. Stakeholders Críticos
| **Papel** | **Responsabilidade** |
|:---|:---|
| **Fiqueok Lab** | Fornecer infraestrutura (i5-12400F, 64GB RAM, Ollama 0.21.0) |
| **Arquiteto de Soluções** | Desenhar arquitetura segura e integrar HashiCorp Vault |
| **Gestor de Segurança (ISO 27001)** | Validar conformidade e mitigação de riscos de Shadow AI |
| **Operador de Exportação** | Executar runbook no Windows 11 com PowerShell |

---

## 2. JUSTIFICATIVA ESTRATÉGICA

### 2.1. Soberania de Dados e GRC

A utilização da plataforma Perplexity AI no ambiente corporativo, embora produtiva, introduz riscos significativos de **Shadow AI** - uso não gerenciado de ferramentas de IA em nuvem que pode expor dados sensíveis a terceiros sem a devida autorização contratual e técnica.

**Riscos Mitigados pelo PROJ018:**
- ❌ **Vazamento de Dados Estratégicos:** Conversas sobre vulnerabilidades, lacunas de auditoria e arquitetura de IAM podem ser usadas para treinamento de modelos da Perplexity, dependendo da política vigente.
- ❌ **Indisponibilidade de Serviço:** Dependência de conexão com a internet e disponibilidade da API da Perplexity para consultar histórico técnico.
- ❌ **Falta de Rastreabilidade (Logs):** A plataforma de nuvem não fornece trilhas de auditoria completas sobre quem consultou quais dados e quando.

**Benefícios da Arquitetura Local (Ollama + AnythingLLM + LanceDB):**
- ✅ **Soberania Total:** Dados armazenados em `C:\PROJ018\data` sob controle criptográfico local.
- ✅ **Disponibilidade Offline:** Acesso 100% garantido mesmo em cenários de contingência de rede.
- ✅ **RAG Baseado em Evidências:** O modelo DeepSeek-R1 responde **exclusivamente** com base nos documentos exportados, eliminando alucinações e garantindo rastreabilidade das fontes.

### 2.2. Lições Aprendidas (PRJ007 - Incidente de Root Token)

Conforme documentado na pendência **PF-006**, o projeto anterior (PRJ007) sofreu um **Fail-Closed** por armazenamento de logs com credenciais em texto claro no disco do host. O PROJ018 adota as seguintes diretrizes corretivas:
- **Proibição explícita** de arquivos `.env` ou `.json` com segredos.
- **Consumo de token via HashiCorp Vault** com TTL (Time-To-Live) curto.
- **Logs sanitizados** (comando `Remove-Item Env:*token*` pós-execução e limpeza automática de variáveis de ambiente).

---

## 3. ARQUITETURA DE SEGURANÇA (DESCRITIVA)

### 3.1. Diagrama de Fluxo de Dados e Controles

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LIVING LAB FIQUEOK (Windows 11)                      │
│                                                                              │
│  ┌──────────────────┐    1. Requisição Token    ┌────────────────────────┐  │
│  │  PowerShell      │ ◄───────────────────────  │  HashiCorp Vault       │  │
│  │  (Execução)      │                           │  (VM Hyper-V / Ubuntu) │  │
│  └────────┬─────────┘                           │  IP: 192.168.x.x       │  │
│           │                                      │  Path: secret/data/    │  │
│           │ 2. Token (memória RAM)              │        PROJ018/        │  │
│           ▼                                      └────────────────────────┘  │
│  ┌──────────────────┐                                                       │
│  │  Perplexport     │  3. Export via HTTPS                                 │
│  │  (Node.js +      │ ──────────────────────────────────────────────┐      │
│  │   Puppeteer)     │                                               │      │
│  └────────┬─────────┘                                               ▼      │
│           │                                        ┌─────────────────────┐  │
│           │ 4. Markdown + JSON                     │   Perplexity AI     │  │
│           │    (C:\PROJ018\raw\)                   │   (Cloud - Internet) │  │
│           ▼                                        └─────────────────────┘  │
│  ┌──────────────────┐                                                       │
│  │  Obsidian Vault  │ ◄── 5. Edição/Revisão Manual                         │
│  │  (Markdown)      │                                                       │
│  └────────┬─────────┘                                                       │
│           │                                                                  │
│           │ 6. Indexação (Embedding)                                        │
│           ▼                                                                  │
│  ┌──────────────────┐    7. Query RAG          ┌────────────────────────┐  │
│  │  AnythingLLM     │ ◄───────────────────────  │  Ollama Server         │  │
│  │  + LanceDB       │                           │  (localhost:11434)     │  │
│  │  (Vector DB)     │                           │  - deepseek-r1:7b      │  │
│  └──────────────────┘                           │  - bge-m3 (embedding)  │  │
│                                                  └────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2. Descrição dos Controles de Segurança por Camada

| **Camada** | **Componente** | **Controle de Segurança** |
|:---|:---|:---|
| **Autenticação** | HashiCorp Vault | Token `svc-shadow-api` com política de **Least Privilege** (apenas leitura no path `secret/data/PROJ018/`). TTL de 15 minutos. |
| **Extração** | Perplexport + Puppeteer | Execução em sessão PowerShell **sem persistência de token** em disco. Variável `$env:PERPLEXITY_TOKEN` vive apenas na RAM. |
| **Armazenamento** | C:\PROJ018\raw\ | Permissões NTFS restritas ao usuário `Fiqueok` e grupo `Auditores`. Criptografia BitLocker ativa na unidade. |
| **Indexação** | LanceDB (embedded) | Banco de vetores **sem exposição de rede** (apenas localhost). Não exige autenticação adicional por ser restrito ao host. |
| **Inferência** | Ollama (DeepSeek-R1) | API restrita a `127.0.0.1:11434` (sem exposição externa). Sem telemetria ou logging de prompts. |

---

## 4. RUNBOOK DE EXECUÇÃO (POWERSHELL - WINDOWS 11)

### 4.1. Pré-requisitos e Checklist

Antes da execução, verificar:

```powershell
# [CHECKLIST] Executar como Administrador ou com privilégios de usuário
# 1. Node.js e npm instalados
node --version  # Deve retornar v18+

# 2. Git instalado
git --version

# 3. Acesso ao HashiCorp Vault (via VM Hyper-V)
# Testar conectividade com o Vault
Test-NetConnection -ComputerName 192.168.x.x -Port 8200

# 4. Variável de ambiente do Vault configurada
$env:VAULT_ADDR = "http://192.168.x.x:8200"
$env:VAULT_TOKEN = "s.svc-shadow-api-token"  # Token de serviço (não o root!)
```

### 4.2. Integração com HashiCorp Vault (Recuperação do Token `_leosession`)

```powershell
# ---------------------------------------------------------------------
# PROJ018 - BLOCO 1: Recuperação Segura do Token via Vault
# ---------------------------------------------------------------------

# Definir endpoint do Vault (substituir IP real)
$env:VAULT_ADDR = "http://192.168.100.50:8200"

# Autenticar com o token de serviço (svc-shadow-api)
$env:VAULT_TOKEN = "s.abc123def456ghi789"  # Exemplo - usar token real do lab

# Buscar o segredo no path correto
$secret = vault kv get -format=json secret/PROJ018

# Extrair o valor do campo '_leosession'
$vaultData = $secret | ConvertFrom-Json
$leosessionToken = $vaultData.data.data._leosession

# Validar se o token foi recuperado
if (-not $leosessionToken) {
    Write-Error "ERRO: Token '_leosession' não encontrado no Vault. Verifique o path 'secret/data/PROJ018'."
    exit 1
}

Write-Host "✅ Token recuperado com sucesso do Vault (TTL: 15 minutos)" -ForegroundColor Green

# Exportar para a sessão (vive apenas na RAM)
$env:PERPLEXITY_TOKEN = $leosessionToken

# Limpar variável imediatamente após uso para evitar vazamento
Remove-Variable leosessionToken -Force
```

### 4.3. Execução da Exportação (Perplexport)

```powershell
# ---------------------------------------------------------------------
# PROJ018 - BLOCO 2: Clonagem e Execução do Perplexport
# ---------------------------------------------------------------------

# Criar estrutura de diretórios
$PROJECT_ROOT = "C:\PROJ018"
$RAW_DATA_DIR = "$PROJECT_ROOT\raw\markdown_files"
$LOG_DIR = "$PROJECT_ROOT\logs"

New-Item -ItemType Directory -Force -Path $RAW_DATA_DIR, $LOG_DIR | Out-Null

# Clonar o repositório (caso não exista)
if (-not (Test-Path "$PROJECT_ROOT\perplexport")) {
    git clone https://github.com/leonid-shevtsov/perplexport.git "$PROJECT_ROOT\perplexport"
}

# Navegar para o diretório
Set-Location "$PROJECT_ROOT\perplexport"

# Instalar dependências (primeira execução apenas)
npm install

# Executar a exportação usando o token da variável de ambiente
# ATENÇÃO: O log NÃO deve conter o token. Sanitização automática.
npx perplexport -o $RAW_DATA_DIR --token $env:PERPLEXITY_TOKEN 2>&1 | Tee-Object -FilePath "$LOG_DIR\export_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Verificar código de saída
if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Falha na exportação. Verifique o log em $LOG_DIR"
    exit $LASTEXITCODE
}

Write-Host "✅ Exportação concluída. Arquivos salvos em $RAW_DATA_DIR" -ForegroundColor Green

# ---------------------------------------------------------------------
# BLOCO 3: Limpeza de Segredos (Mitigação R2 - PRJ007)
# ---------------------------------------------------------------------

# Remover a variável de ambiente do token
Remove-Item Env:PERPLEXITY_TOKEN -Force

# Limpar o histórico do PowerShell (últimos 100 comandos)
Clear-History -Count 100

# Opcional: Forçar garbage collection para limpar vestígios na RAM
[GC]::Collect()
[GC]::WaitForPendingFinalizers()

Write-Host "✅ Segredos removidos da memória e do histórico" -ForegroundColor Yellow
```

### 4.4. Indexação no AnythingLLM (LanceDB + Ollama)

```powershell
# ---------------------------------------------------------------------
# PROJ018 - BLOCO 4: Configuração do RAG Local
# ---------------------------------------------------------------------

# Verificar se o Ollama está rodando
$ollamaStatus = Get-Process -Name "ollama" -ErrorAction SilentlyContinue
if (-not $ollamaStatus) {
    Write-Host "Iniciando serviço Ollama..." -ForegroundColor Yellow
    Start-Process "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe"
    Start-Sleep -Seconds 5
}

# Verificar modelos disponíveis
ollama list

# Garantir que o modelo de embedding bge-m3 está disponível
$models = ollama list | Out-String
if ($models -notmatch "bge-m3") {
    Write-Host "Baixando modelo bge-m3 para embedding..." -ForegroundColor Yellow
    ollama pull bge-m3
}

# Configuração manual no AnythingLLM Desktop:
Write-Host @"
------------------------------------------------------------
CONFIGURAÇÃO MANUAL NO ANYTHINGLLM:
1. Abra o AnythingLLM Desktop
2. Crie novo Workspace: 'ISO27001_Audit'
3. Settings -> LLM Preference -> Ollama -> deepseek-r1:7b
4. Settings -> Embedder Preference -> Ollama -> bge-m3
5. Documents -> Add Document -> Selecione a pasta:
   $RAW_DATA_DIR
6. Clique em 'Save and Embed' (vetorização via LanceDB)
------------------------------------------------------------
"@ -ForegroundColor Cyan

Read-Host "Pressione Enter após concluir a configuração manual"
```

---

## 5. ANÁLISE SWOT ATUALIZADA (COM LANCEDB E i5-12400F)

| **Fator** | **Análise** |
|:---|:---|
| **Strengths (Forças)** | ✅ **LanceDB (embedded):** Zero latência de rede para consultas vetoriais. <br> ✅ **64GB RAM:** Permite carregar o modelo 7b (5-6GB) + índice vetorial em memória sem swap. <br> ✅ **Soberania total:** Nenhum dado cruza a fronteira do lab. |
| **Weaknesses (Fraquezas)** | ⚠️ **i5-12400F sem GPU dedicada:** Inferência depende exclusivamente da CPU (AVX2). Latência estimada: 15-25 tokens/segundo (vs 50+ tokens/s em GPU). <br> ⚠️ **LanceDB não é distribuído:** Escala apenas verticalmente, limitado ao hardware do host. |
| **Oportunidades** | 🔄 **Fine-tuning futuro:** Com 64GB RAM, é possível fazer LoRA fine-tuning do modelo 7b para jargões específicos de ISO 27001. <br> 🔄 **Integração com Vault:** Uso de segredos dinâmicos reduz janela de exposição. |
| **Threats (Ameaças)** | ⚠️ **Obsolescência do modelo 7b:** Modelos maiores (14B/32B) exigiriam GPU dedicada ou reduziriam drasticamente a performance. <br> ⚠️ **Corrupção do índice LanceDB:** Backup manual necessário (sem HA nativo). |

---

## 6. MATRIZ DE RISCOS E MITIGAÇÕES

| **ID** | **Risco** | **Prob.** | **Impacto** | **Mitigação** | **Responsável** |
|:---|:---|:---|:---|:---|:---|
| **R01** | **Root Token ativo no Vault** (conforme PRJ007/PF-006) | Média | Crítico | Revogação imediata do token root pós-configuração. Uso exclusivo de tokens de serviço (`svc-shadow-api`) com TTL curto. | Gestor de Segurança |
| **R02** | **Vazamento do token `_leosession` em logs** | Baixa | Alto | Script sanitizado (sem `set -x`). Logs são gravados sem o token. Comando `Clear-History` pós-execução. | Operador |
| **R03** | **Alta latência do DeepSeek-R1 no i5-12400F** | Média | Médio | Adoção de modelo alternativo `deepseek-r1:1.5b` para consultas rápidas; manter 7b apenas para tarefas complexas. | Arquiteto |
| **R04** | **Corrupção do índice LanceDB** | Baixa | Alto | Backup semanal da pasta `%APPDATA%\anythingllm\storage\*.lancedb`. Documentos fonte permanecem em Markdown no Obsidian. | Administrador |
| **R05** | **Mudança na estrutura HTML da Perplexity (scraping)** | Média | Médio | Manter fork local do `perplexport` com capacidade de ajuste manual. Plano B: exportação manual via copy/paste das conversas críticas. | Arquiteto |

---

## 7. APROVAÇÕES E PRÓXIMOS PASSOS

### 7.1. Pendências Críticas (PF-006 - Revogação de Root Token)

Conforme exigido pela lição aprendida do PRJ007, antes da execução do PROJ018, **deve ser comprovada a revogação do token root do HashiCorp Vault** utilizado no laboratório. O token ativo identificado no pendência PF-006 deve ser substituído por tokens de serviço com política de **Least Privilege**.

- [ ] **Ação 1:** Revogar token root via `vault token revoke <token_root>`.
- [ ] **Ação 2:** Criar política `shadow-api-policy` com permissão apenas para `secret/data/PROJ018/*`.
- [ ] **Ação 3:** Gerar token `svc-shadow-api` com TTL de 15 minutos.

### 7.2. Critérios de Aceite do Projeto

1. ✅ 100% das conversas identificadas no Perplexity foram exportadas para Markdown.
2. ✅ Nenhum token ou credencial foi persistido em disco (verificação via `findstr /s "token" C:\PROJ018\logs\`).
3. ✅ O workspace do AnythingLLM responde a perguntas sobre ISO 27001 com citações diretas dos documentos exportados.
4. ✅ O tempo médio de resposta do modelo 7b no i5-12400F é documentado e aceito pelo patrocinador.

### 7.3. Aprovação Final

**Declaro que li e compreendo os riscos associados ao PROJ018, incluindo a dependência de scraping da plataforma Perplexity AI e as limitações de performance do hardware i5-12400F. Autorizo o início da execução conforme runbook anexo.**

__________________________________________
**Assinatura do Patrocinador (Fiqueok Lab)**

Data: ___ / ___ / 2026

---

📄 **Documento salvo como:** `PROJ018_TAP_v1.1.md`
🔒 **Classificação:** CONFIDENCIAL
⏱️ **Tempo estimado de execução:** 30-45 minutos (dependendo do volume de conversas)
