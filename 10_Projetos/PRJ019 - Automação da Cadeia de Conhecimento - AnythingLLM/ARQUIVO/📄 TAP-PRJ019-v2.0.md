

## Termo de Abertura do Projeto — PRJ019

---

| **Campo**             | **Valor**                                    |
| --------------------- | -------------------------------------------- |
| **Código do Projeto** | PRJ019                                       |
| **Nome do Projeto**   |                                              |
| **Versão**            | 2.0                                          |
| **Data de Abertura**  | 24/04/2026                                   |
| **Responsável**       | Paulo Feitosa Lima — GRC Lead                |
| **Patrocinador**      | Living Lab Fiqueok                           |
| **Classificação**     | CONFIDENCIAL — Dados Técnicos e de Auditoria |

---

## 1. OBJETIVOS DO PROJETO

|ID|Objetivo|Critério de Sucesso|
|---|---|---|
|OBJ-01|Implementar watcher automatizado para novos arquivos no Obsidian|Detecção de novos arquivos `.md` em < 5 segundos|
|OBJ-02|Classificar documentos por camada temática (1 a 6)|95% de acurácia na classificação automática|
|OBJ-03|Enviar documentos ao workspace correto no AnythingLLM via API|Documento indexado em < 15 segundos após criação|
|OBJ-04|Autenticar via HashiCorp Vault (AppRole) sem credenciais hardcoded|Nenhum segredo armazenado em código ou `.env` versionado|
|OBJ-05|Registrar todas as operações em log de auditoria|Trilha rastreável para conformidade ISO 27001|

---

## 2. ESCOPO

### 2.1. Dentro do Escopo

|Item|Descrição|
|---|---|
|**Watcher**|Monitoramento da pasta `10_Projetos/` e `20_Governanca/` no Obsidian usando `watchdog`|
|**Classificador**|Roteamento baseado em frontmatter YAML (`projeto: PRJXXX`) ou palavras-chave no caminho|
|**API Service**|FastAPI exposta em `localhost:8000`, endpoint `/ingest` para testes manuais|
|**Integração Vault**|AppRole authentication, leitura da API Key do AnythingLLM em `secret/data/anythingllm`|
|**AnythingLLM Client**|Chamada HTTP para `POST /api/v1/workspace/{slug}/documents`|
|**Logging**|JSON estruturado para `/var/log/prj019/audit.log` com campos: `timestamp, file, workspace, hash, status`|
|**Resiliência**|Retry com backoff exponencial (3 tentativas: 60s, 120s, 240s)|
|**Rollback**|Production Checkpoint Hyper-V pré-GMUD obrigatório|

### 2.2. Fora do Escopo

|Item|Justificativa|
|---|---|
|**SAST/DAST automatizado**|Tratado no PRJ021 (DevSecOps Pipeline)|
|**Interface gráfica**|Operação headless, sem GUI|
|**Sincronização bidirecional**|Apenas Obsidian → AnythingLLM, não o inverso|
|**Migração retroativa**|Não reindexará documentos existentes (apenas novos)|
|**Pipeline CI/CD**|Tratado no PRJ021|

---

## 3. ARQUITETURA DECIDIDA

|Componente|Tecnologia|Decisão|
|---|---|---|
|**Watcher**|Python 3.11 + `watchdog`|Leve, nativo no Ubuntu, sem dependências pesadas|
|**API Service**|FastAPI + Uvicorn|Performance assíncrona, documentação automática (`/docs`)|
|**Classificador**|Regras baseadas em YAML + regex|Simples, determinístico, sem ML (overkill)|
|**Autenticação**|HashiCorp Vault AppRole|Gestão centralizada de segredos (PRJ007)|
|**Containerização**|Docker (GEN1, Ubuntu 24.04)|Portabilidade, isolamento, respeita CONSTRAINT-001|
|**Logs**|JSON + rotação (`logrotate`)|Rastreabilidade para ISO 27001 A.12.4|

### 3.1. Fluxo de Execução

text

1. Watcher detecta novo arquivo em 10_Projetos/PRJXXX/
2. API Service recebe evento via callback
3. Autentica no Vault (AppRole) → obtém API Key do AnythingLLM
4. Classificador determina a camada (1 a 6)
5. Chama POST /workspace/{slug}/documents no AnythingLLM
6. Registra operação em audit.log (hash SHA256 do arquivo)
7. Em caso de falha: retry exponencial até 3 tentativas
8. Falha persistente → move para DEAD_LETTER e notifica log crítico

### 3.2. Mapeamento Camada → Workspace

|Camada|Workspace Slug no AnythingLLM|Critério de Classificação|
|---|---|---|
|1 — Fundação|`camada-1-fundacao`|Caminho contém `PRJ001`, `PRJ002`, `PRJ003`|
|2 — Integração|`camada-2-integracao`|Caminho contém `PRJ004`, `PRJ005`, `PRJ006`|
|3 — RAG e Memória|`camada-3-rag`|Caminho contém `PRJ018`|
|4 — Orquestração|`camada-4-orquestracao`|Caminho contém `PRJ008` a `PRJ012`|
|5 — Infraestrutura|`camada-5-infra`|Caminho contém `PRJ013` a `PRJ017`|
|6 — Segurança|`camada-6-seguranca`|Caminho contém `PRJ007`, `PRJ016`, `PRJ020`|
|Consolidado|`living-lab-fiqueok`|**Sempre** (além da camada específica)|

---

## 4. REQUISITOS TÉCNICOS

### 4.1. Infraestrutura

|Recurso|Especificação|Status|
|---|---|---|
|**VM**|Ubuntu 24.04 LTS, GEN1 (Hyper-V)|✅ Disponível (respeita CONSTRAINT-001)|
|**RAM**|1 GB (512 MB para API + 512 MB overhead)|✅ Dentro da margem de 18 GB|
|**Disco**|10 GB para código + logs|✅ Disponível|
|**Docker**|Docker Engine 24+|✅ Já instalado|

### 4.2. Dependências de Projetos Existentes

|Dependência|Projeto|Status|Ação|
|---|---|---|---|
|**Vault AppRole**|PRJ007|🔴 Pendente|Criar política `policy-svc-ingestor` e RoleID/SecretID|
|**AnythingLLM API**|PRJ018|✅ Concluído|Workspaces já criados, API key a ser gerada|
|**Workspaces**|PRJ018|✅ Concluído|6 workspaces por camada + 1 consolidado|

### 4.3. Controles de Segurança (Sem SAST/DAST - PRJ021)

|Controle|Implementação|Responsável|
|---|---|---|
|**Revisão de código manual**|Todo commit revisado antes do merge|Paulo|
|**Scan de dependências**|`pip-audit` manual pré-deploy|Paulo|
|**Logging seguro**|Filtro automático de `Authorization:`, `X-Vault-Token:`|Implementação|
|**Container não root**|`USER appuser` no Dockerfile|Implementação|
|**Isolamento de rede**|API bind em `127.0.0.1:8000` (não exposta ao Tailscale)|Implementação|

---

## 5. CRONOGRAMA ESTIMADO

|Fase|Atividade|Período|Dependência|
|---|---|---|---|
|**Fase 1**|Configurar Vault (política + AppRole)|0.5 dia|PRJ007 operacional|
|**Fase 2**|Desenvolver API Service + Watcher|2 dias|Fase 1|
|**Fase 3**|Implementar classificador por camadas|0.5 dia|Fase 2|
|**Fase 4**|Testes de integração (watcher → Vault → AnythingLLM)|1 dia|Fase 3|
|**Fase 5**|Documentação (POP) e GMUD|0.5 dia|Fase 4|
|**Duração total**|**4.5 dias**|—|—|

---

## 6. RISCOS ACEITOS E CONTROLES

|ID|Risco|Prob.|Impacto|Controle (sem PRJ021)|
|---|---|---|---|---|
|R01|Token Vault exposto em log|Baixa|Alto|Filtro automático + revisão manual|
|R02|Dependência vulnerável|Média|Médio|`pip-audit` manual pré-deploy|
|R03|Path traversal no watcher|Baixa|Médio|Validação com `os.path.abspath`|
|R04|Falha na classificação|Média|Baixo|Fallback para workspace consolidado|
|R05|AnythingLLM offline|Média|Médio|Retry com backoff + DEAD_LETTER|

**Riscos transferidos ao PRJ021:**

- Automação de SAST (SonarCloud ou GitLab SAST)
    
- Pipeline CI/CD para testes automáticos
    
- DAST da API Service
    

---

## 7. ENTREGÁVEIS PREVISTOS

|ID|Entregável|Formato|Localização|
|---|---|---|---|
|E01|API Service (código)|Python/FastAPI|`C:\Git\prj019-ingestor\`|
|E02|Dockerfile + docker-compose.yml|YAML|Mesmo repositório|
|E03|Watcher service (systemd)|`.service`|VM do PRJ019|
|E04|POP-PRJ019-001 (operação)|Markdown|`10_Projetos/PRJ019/`|
|E05|GMUD-PRJ019-001|Markdown|`20_Governanca_e_Decisoes/GMUDs/`|
|E06|REL-PRJ019 (validação)|Markdown|`30_Operacao_e_Mudanca/`|
|E07|TEP-PRJ019|Markdown|`00_Gestao_do_Projeto/`|

---

## 8. CRITÉRIOS DE ACEITE (DEFINIÇÃO DE PRONTO)

- Novo arquivo `.md` em `10_Projetos/PRJ020/` é indexado na Camada 6 em < 15 segundos
    
- Vault autentica via AppRole sem credenciais hardcoded no código
    
- Log de auditoria contém: timestamp, file path, workspace, SHA256 hash, HTTP status
    
- Falha do AnythingLLM (simulada) resulta em retry exponencial e log de DEAD_LETTER
    
- Container roda como `appuser` (não root)
    
- `pip-audit` não reporta vulnerabilidades críticas ou altas
    
- Production Checkpoint criado antes da GMUD de deploy
    

---

## 9. APROVAÇÕES

|Função|Nome|Data|Status|
|---|---|---|---|
|GRC Lead / Responsável|Paulo Feitosa Lima|24/04/2026|✅ APROVADO|
|Arquiteto de Soluções|Paulo Feitosa Lima|24/04/2026|✅ APROVADO|

---

**FIM DO TERMO DE ABERTURA DO PROJETO — PRJ019 v2.0**

📄 **Documento salvo como:** `TAP-PRJ019-v2.0.md`  
📁 **Localização:** `10_Projetos/PRJ019/00_Gestao_do_Projeto/`  
🔒 **Classificação:** CONFIDENCIAL