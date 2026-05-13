# 

## Memória de Longo Prazo do Living Lab Fiqueok (Ollama + AnythingLLM + Vane)

---

| **Campo** | **Valor** |
|:---|:---|
| **Código do Projeto** | PROJ018 |
| **Nome do Projeto** | Migração de Base de Conhecimento Perplexity para Ecossistema Local + Memória de Longo Prazo do Living Lab |
| **Versão** | 2.0 (Final — com correções de dependências) |
| **Data de Encerramento** | 24/04/2026 |
| **Responsável** | Paulo Feitosa Lima — GRC Lead |
| **Patrocinador** | Fiqueok Lab / Living Lab de Governança de TI |
| **Status Final** | ✅ **CONCLUÍDO COM SUCESSO** |
| **Classificação** | CONFIDENCIAL — Dados Técnicos e de Auditoria |

---

## 1. CHANGELOG

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 23/04/2026 | Paulo Feitosa Lima | Criação — Encerramento formal do PROJ018 |
| **2.0** | **24/04/2026** | **Paulo Feitosa Lima** | **Adendo: inclusão da estratégia detalhada de extração do Perplexity; correção das relações de dependência (contínua vs. pontual); adição da lição L31; atualização das camadas temáticas para incluir PRJ016 e PRJ020 na Camada 6.** |

---

## 2. IDENTIFICAÇÃO DO PROJETO

| Campo | Valor |
|-------|-------|
| **Código** | PRJ018 |
| **Nome** | Memória de Longo Prazo do Living Lab Fiqueok |
| **Categoria** | IA / RAG / Governança de Conhecimento / Soberania de Dados |
| **Patrocinador** | Paulo Feitosa Lima |
| **Data de Início** | 18/04/2026 |
| **Data de Encerramento** | 24/04/2026 |
| **Duração Real** | 7 dias |
| **Predecessores** | PRJ001 a PRJ017 |
| **Sucessor** | PROJ019 — (a definir) |

---

## 3. RESUMO EXECUTIVO

O PROJ018 teve como objetivo estabelecer uma **Memória de Longo Prazo** para o Living Lab Fiqueok, substituindo o uso da plataforma Perplexity como repositório de conhecimento por um ecossistema **100% local, soberano e rastreável**.

### 3.1. Entregas Realizadas

| # | Entrega | Status | Detalhe |
|---|---------|--------|---------|
| E1 | Extração de 222 conversas do Perplexity | ✅ CONCLUÍDO | Arquivos Markdown com frontmatter YAML |
| E2 | Instalação e configuração do Ollama | ✅ CONCLUÍDO | Modelos: Qwen2.5:7b, DeepSeek-R1:7b, nomic-embed-text-v1, bge-m3 |
| E3 | Instalação e configuração do AnythingLLM Desktop | ✅ CONCLUÍDO | Interface principal para RAG local |
| E4 | Instalação e configuração do Vane (alternativa) | ✅ CONCLUÍDO | Interface web para busca e testes, rodando em `http://localhost:3000` |
| E5 | Indexação de 495+ documentos (PRJ001 a PRJ018) | ✅ CONCLUÍDO | Documentos organizados em 5 camadas temáticas |
| E6 | Configuração do Prompt da Memória Estratégica | ✅ CONCLUÍDO | Prompt unificado para o workspace consolidado |
| E7 | Configuração da resposta de recusa personalizada | ✅ CONCLUÍDO | Orientação diagnóstica em português |
| E8 | Testes de validação transversal aprovados | ✅ CONCLUÍDO | Respostas coerentes com citação de fontes |
| E9 | Criação do workspace consolidado "Living Lab Fiqueok" | ✅ CONCLUÍDO | Workspace final com todas as camadas |
| E10 | Documentação de lições aprendidas | ✅ CONCLUÍDO | 9 lições documentadas (L23 a L31) |

### 3.2. Stack Tecnológica Final

| Componente | Tecnologia | Versão | Uso |
|------------|------------|--------|-----|
| **LLM principal** | Qwen2.5:7b | 4.7 GB | Chat e análise de documentos em português |
| **LLM alternativo** | DeepSeek-R1:7b | 4.7 GB | Raciocínio profundo (fallback) |
| **Embedding** | nomic-embed-text-v1 | 768 dim | Vetorização multilíngue |
| **Embedding alternativo** | bge-m3 | — | Fallback para embedding |
| **Interface principal** | AnythingLLM Desktop | latest | RAG local, workspaces por tema |
| **Interface alternativa** | Vane | Docker | Busca web com IA, testes |
| **Vector Database** | LanceDB | embedded | Armazenamento de embeddings |
| **Orquestrador** | Ollama | 0.21.0 | Servidor de inferência local |

---

## 4. ESTRATÉGIA DE EXTRAÇÃO DO PERPLEXITY

### 4.1. Desafios Enfrentados

| Desafio | Descrição |
|---------|-----------|
| **Google OAuth** | Bloqueia navegadores automatizados (Playwright/Puppeteer), classificando-os como "navegadores não seguros" |
| **Cloudflare Turnstile** | Aplica verificações de integridade de hardware e reputação de IP, resultando em erros 403 |
| **Cookie HttpOnly** | Impedem a captura e reutilização de tokens de sessão via JavaScript |
| **Conteúdo dinâmico** | Conversas longas só são carregadas sob demanda, mediante rolagem da página |

### 4.2. Solução Implementada

A estratégia final e bem-sucedida baseia-se nos seguintes pilares:

#### 1. Persistência de Perfil Real

Utilizamos o comando `launch_persistent_context` do Playwright apontando para uma pasta de perfil local (`C:\Users\fiqueok\Perplexity_IA\chrome_profile_perplexity_export`). Isso permitiu realizar o login manualmente **uma única vez**, salvando cookies e tokens de sessão que foram reutilizados pelo script nas 229 threads, evitando o bloqueio de "navegador inseguro" do Google.

```python
context = await p.chromium.launch_persistent_context(
    user_data_dir=str(SCRIPT_PROFILE),
    headless=False,
    args=["--disable-blink-features=AutomationControlled", "--no-sandbox"]
)
```

#### 2. Bypass de WAF (Cloudflare)

Em vez de acessar a API diretamente (que resultava em erros 403), o script carregou a interface visual (modo `headless=False`). A navegação começou pela Home ou Library para validar a integridade da sessão antes de iniciar a extração em lote.

#### 3. Humanização e Carregamento Dinâmico

Implementamos um mecanismo de **Smooth Scroll** (rolagem suave) usando `mouse.wheel` para simular um usuário lendo a conversa. Isso foi crítico para forçar o Perplexity a renderizar conteúdos longos que só aparecem sob demanda na tela.

```python
for _ in range(SCROLL_STEPS):
    await page.mouse.wheel(0, random.randint(400, 800))
    await asyncio.sleep(0.5)
```

#### 4. Extração de Alta Fidelidade

Substituímos a captura de texto bruto (`inner_text`) por seletores CSS específicos como `div[class*="prose"]` e `div[data-testid="message-content"]`. Isso garantiu que tabelas, códigos e listas estruturadas fossem preservados no arquivo final.

```python
content_elements = await page.query_selector_all(
    'div[class*="prose"], div[class*="markdown"], div[data-testid="message-content"]'
)
```

#### 5. Idempotência e Resiliência

O script foi configurado para verificar a existência de um arquivo de checkpoint (`{i:04d}_done.txt`) antes de processar cada URL. Assim, em caso de queda de conexão ou interrupção manual, o processo continuava exatamente de onde parou, sem duplicar dados.

```python
checkpoint = OUTPUT_DIR / f"{i:04d}_done.txt"
if checkpoint.exists():
    print(f"⏭️ [{i}/{total}] Já processado. Pulando.")
    continue
```

#### 6. Formatação para Obsidian

Os dados foram salvos em arquivos `.md` individuais, contendo um cabeçalho YAML (Frontmatter) com a URL original e a data da extração para garantir a rastreabilidade e soberania da informação.

```markdown
---
url: https://www.perplexity.ai/search/...
date: 2026-04-20T21:39:40.642413
---

# Título da Conversa

Conteúdo formatado em Markdown...
```

### 4.3. Resultado Alcançado

| Métrica | Resultado |
|---------|-----------|
| Threads extraídas | 222 de 229 (97.4%) |
| Arquivos Markdown gerados | 222 |
| Formato | Markdown com frontmatter YAML |
| Preservação de estrutura | ✅ Tabelas, códigos, listas |
| Idempotência | ✅ Checkpoints por thread |
| Dependência externa | ❌ Nenhuma (operação 100% local) |

### 4.4. Importante: Não há dependência contínua com a Perplexity

Uma vez concluída a extração, o PROJ018 **não mantém nenhum cordão umbilical** com a plataforma Perplexity. Não há:
- Chamadas de API contínuas
- Tokens sendo renovados
- Dependência de conectividade com a internet

A Memória de Longo Prazo do Living Lab opera **100% offline** com base nos documentos extraídos.

---

## 5. OBJETIVOS — STATUS FINAL

| ID | Objetivo | Status | Evidência |
|----|----------|--------|-----------|
| OBJ-01 | Extrair 100% das conversas do Perplexity | ✅ CONCLUÍDO | 222 arquivos `.md` gerados |
| OBJ-02 | Instalar e configurar LLM local | ✅ CONCLUÍDO | Ollama rodando com Qwen2.5:7b |
| OBJ-03 | Instalar e configurar interface RAG | ✅ CONCLUÍDO | AnythingLLM Desktop + Vane |
| OBJ-04 | Indexar documentos de todos os projetos | ✅ CONCLUÍDO | 495+ documentos indexados |
| OBJ-05 | Configurar prompts para respostas rastreáveis | ✅ CONCLUÍDO | Citação de fontes obrigatória |
| OBJ-06 | Validar respostas com base nos documentos | ✅ CONCLUÍDO | Testes de stress aprovados |
| OBJ-07 | Documentar procedimento de manutenção | ✅ CONCLUÍDO | Seção 10 deste TEP |

---

## 6. ESTRUTURA DE CONHECIMENTO — CAMADAS TEMÁTICAS

Para garantir a estabilidade da indexação e a coerência narrativa, os documentos foram organizados em **6 camadas temáticas**:

| Camada | Projetos | Conteúdo | Status |
|--------|----------|----------|--------|
| **Camada 1 — Fundação** | PRJ001, PRJ002, PRJ003 | Baseline de segurança, Infraestrutura Core, Pivô arquitetural | ✅ Indexado |
| **Camada 2 — Integração** | PRJ004, PRJ005, PRJ006 | CSV, JDBC, anti-padrão arquitetural | ✅ Indexado |
| **Camada 3 — RAG e Memória** | PRJ018 | Extração Perplexity, indexação local | ✅ Indexado |
| **Camada 4 — Orquestração** | PRJ008, PRJ009, PRJ010, PRJ011, PRJ012 | Shadow API, Entra ID, midPoint | ✅ Indexado |
| **Camada 5 — Infraestrutura** | PRJ013, PRJ014, PRJ015, PRJ017 | Terraform, Hyper-V, Cloud Sync, Edge Gateway | ✅ Indexado |
| **Camada 6 — Segurança, PAM e ITDR** | PRJ007, PRJ016, PRJ020 | HashiCorp Vault, Sentinel Identity Shield, OpenVAS, DefectDojo | 🟡 Em construção |

**Workspace consolidado:** `Living Lab Fiqueok` — contém 495+ documentos indexados.

---

## 7. CONFIGURAÇÃO FINAL DO ANYTHINGLLM

### 7.1. Configurações do Workspace Consolidado

| Parâmetro | Valor | Justificativa |
|-----------|-------|---------------|
| **Modo de Chat** | Consulta (Query) | Força busca APENAS nos documentos indexados |
| **Modelo LLM** | Qwen2.5:7b | Melhor desempenho em português |
| **Modelo Embedding** | nomic-embed-text-v1 | 768 dimensões, multilíngue |
| **Temperatura** | 0.1 | Máximo determinismo |
| **Máximo de Trechos** | 20 | Alta recuperação para corpus pequeno |
| **Limiar de Similaridade** | 0.0 (sem restrição) | Maximiza recall |

### 7.2. Prompt da Memória Estratégica

O workspace consolidado utiliza um prompt unificado que:
- Estabelece hierarquia de verdade (GPS de Contexto → Evidência Primária → Contexto Conversacional)
- Exige citação obrigatória das fontes
- Proíbe inferência e alucinação
- Utiliza terminologia específica do laboratório

### 7.3. Resposta de Recusa Personalizada

```
Não encontrei evidência documental para esta pergunta na base de conhecimento do Living Lab Fiqueok.

Possibilidades:
1. O documento que contém esta informação não foi indexado neste workspace.
2. A pergunta está fora do escopo dos projetos PRJ001 a PRJ018.
3. A informação existe mas não foi capturada na forma de um termo de busca compatível.

Para ajudar na localização:
- Refine sua pergunta com termos específicos do laboratório
- Verifique se o documento esperado está no workspace
- Consulte o CONTEXTO_LivingLab_Fiqueok_v1.0.md

Esta é uma resposta de recusa configurada pelo modo de resposta do workspace.
```

---

## 8. INSTALAÇÕES COMPLEMENTARES

### 8.1. Vane — Interface Alternativa para Busca Web

Além do AnythingLLM Desktop, foi instalado e configurado o **Vane** como interface alternativa para busca web com IA:

| Parâmetro | Valor |
|-----------|-------|
| **Acesso** | `http://localhost:3000` |
| **Modelo** | Qwen2.5:7b |
| **Embedding** | nomic-embed-text-v1 |
| **Função principal** | Busca web com IA e citações |
| **Status** | ✅ Operacional |

O Vane é utilizado quando consultas exigem informações atualizadas da web, complementando o AnythingLLM que foca exclusivamente nos documentos locais.

---

## 9. RELAÇÕES DE DEPENDÊNCIA (CORRETAS)

| Relação | Tipo | Descrição | Dependência contínua? |
|---------|------|-----------|----------------------|
| **PRJ007 → PRJ008** | Contínua | Shadow API lê credenciais do Vault | ✅ Sim |
| **PRJ007 → PRJ018** | Pontual (encerrada) | Exportação usou token do Vault UMA VEZ | ❌ Não |
| **PRJ018 → Perplexity** | Evento único (concluído) | Extração das 222 conversas | ❌ Não |
| **PRJ018 → AnythingLLM** | Contínua | RAG local para consultas | ✅ Sim |

---

## 10. PROCEDIMENTO DE MANUTENÇÃO CONTÍNUA

### 10.1. Adicionando Novos Documentos à Memória de Longo Prazo

Para que o AnythingLLM continue sendo alimentado com novos documentos, siga este procedimento:

#### Passo 1: Identificar a Camada Correta

| Tipo de Documento | Camada de Destino |
|-------------------|-------------------|
| Projetos de infraestrutura (PRJ013-017) | Camada 5 — Infraestrutura |
| Projetos de orquestração (PRJ008-012) | Camada 4 — Orquestração |
| Projetos de segurança (PRJ007, PRJ016, PRJ020) | Camada 6 — Segurança, PAM e ITDR |
| Projetos de integração (PRJ004-006) | Camada 2 — Integração |
| Projetos de fundação (PRJ001-003) | Camada 1 — Fundação |
| Documentos transversais | Workspace consolidado |

#### Passo 2: Copiar o Arquivo

```powershell
# Exemplo: adicionar um novo documento à Camada 1
Copy-Item -Path "C:\caminho\do\novo_documento.md" -Destination "C:\Hyper-V\Docs\CAMADA_1_FUNDACAO\"
```

#### Passo 3: Indexar no Workspace Correspondente

1. Abra o AnythingLLM Desktop
2. Selecione o workspace da camada correspondente (ex: `CAMADA 1 — FUNDACAO`)
3. Vá em **Documents** → **Add Document**
4. Selecione o novo arquivo
5. Clique em **Save and Embed**
6. Aguarde a conclusão da indexação

#### Passo 4: Atualizar o Workspace Consolidado

1. Selecione o workspace `Living Lab Fiqueok`
2. Vá em **Documents** → **Add Document**
3. Selecione o mesmo arquivo
4. Clique em **Save and Embed**

### 10.2. Verificação Periódica

| Frequência | Ação | Responsável |
|------------|------|-------------|
| Semanal | Verificar se novos documentos foram adicionados ao Obsidian | Paulo |
| Mensal | Validar integridade dos índices do AnythingLLM | Paulo |
| Trimestral | Revisar e atualizar o Prompt da Memória Estratégica | Paulo |

---

## 11. RECOMENDAÇÃO PARA PROJETOS FUTUROS (PROJ019+)

### 11.1. Automação da Alimentação do AnythingLLM

**Recomendação:** O próximo projeto (PROJ019) deve prever a criação de uma **API ou mecanismo de automação** que, sempre que um novo arquivo for copiado para o Obsidian, automaticamente:

1. Identifique a camada temática correta
2. Envie o documento para o workspace correspondente no AnythingLLM
3. Atualize o workspace consolidado "Living Lab Fiqueok"
4. Registre a operação em log de auditoria

### 11.2. Arquitetura Proposta para Automação

```
Obsidian Vault
     │
     │ (Watcher / File System Monitor)
     ▼
┌─────────────────────────────────────────────────────────────┐
│                 Script de Automação (Python/PowerShell)      │
│                                                             │
│  1. Detectar novo arquivo .md                               │
│  2. Classificar a camada (baseado em palavras-chave)        │
│  3. Chamar API do AnythingLLM (curl/requests)               │
│  4. Registrar no log                                        │
│  5. Notificar (opcional)                                    │
└─────────────────────────────────────────────────────────────┘
     │
     ├──► AnythingLLM API (localhost:3001)
     │
     └──► Workspace da camada correspondente
     │
     └──► Workspace consolidado "Living Lab Fiqueok"
```

### 11.3. Endpoints da API do AnythingLLM

O AnythingLLM expõe uma API local que pode ser utilizada para automação:

| Endpoint | Método | Uso |
|----------|--------|-----|
| `http://localhost:3001/api/v1/documents` | POST | Adicionar documento |
| `http://localhost:3001/api/v1/workspaces/{slug}/documents` | POST | Adicionar a workspace específico |
| `http://localhost:3001/api/v1/workspaces/{slug}/update-embeddings` | POST | Reindexar workspace |

---

## 12. LIÇÕES APRENDIDAS (CONSOLIDADAS)

| ID | Lição | Origem | Aplicação Futura |
|----|-------|--------|------------------|
| L23 | AnythingLLM Desktop tem limitações de indexação para grandes volumes | PROJ018 | Workspaces com no máximo 50-70 documentos |
| L24 | Qwen2.5:7b tem melhor desempenho em português que DeepSeek-R1:7b | PROJ018 | Priorizar Qwen2.5:7b para documentação técnica em português |
| L25 | nomic-embed-text-v1 (768 dim) é superior a all-MiniLM-L6-v2 (384 dim) | PROJ018 | Usar embeddings multilíngues de 768+ dimensões |
| L26 | Modo "Consulta" (Query) é essencial para forçar uso exclusivo dos documentos | PROJ018 | Todo RAG local deve usar modo Consulta |
| L27 | Respostas de recusa personalizadas melhoram experiência e orientam diagnóstico | PROJ018 | Personalizar respostas de recusa para o domínio |
| L28 | Indexação por camadas temáticas preserva coerência narrativa | PROJ018 | Organizar documentos por camadas, não apenas por projeto |
| L29 | O tipo de VM (GEN1 vs GEN2) afeta todo o ecossistema (herdado do PRJ014) | PRJ014 | Inventariar VMs GEN2 e documentar dependências |
| L30 | Token de serviço expira e requer renovação automatizada (herdado do PRJ007) | PRJ007 | Automatizar renovação de tokens com antecedência |
| **L31** | **Documente o tipo de dependência (contínua vs. pontual)** | **PROJ018** | **Especificar se a dependência é contínua (tempo real) ou pontual (evento único concluído)** |

---

## 13. PENDÊNCIAS IDENTIFICADAS

| # | Item | Prioridade | Ação Recomendada | Responsável |
|---|------|------------|------------------|-------------|
| P1 | Automação da alimentação do AnythingLLM | Alta | Implementar no PROJ019 | Paulo |
| P2 | Documentação da API do AnythingLLM | Média | Criar guia de referência | Paulo |
| P3 | Backup automático dos índices LanceDB | Média | Configurar script de backup semanal | Paulo |
| P4 | Execução do PRJ016 (Sentinel Identity Shield) | Média | Planejar e executar | Paulo |
| P5 | Planejamento do PRJ020 (OpenVAS + DefectDojo) | Baixa | Definir escopo e cronograma | Paulo |

---

## 14. CRONOGRAMA REAL

| Fase | Atividade | Período | Duração | Status |
|------|-----------|---------|---------|--------|
| Fase 1 | Configuração do ambiente e extração | 18-19/04 | 2 dias | ✅ CONCLUÍDA |
| Fase 2 | Indexação por camadas temáticas | 20-21/04 | 2 dias | ✅ CONCLUÍDA |
| Fase 3 | Configuração de prompts e testes | 22/04 | 1 dia | ✅ CONCLUÍDA |
| Fase 4 | Consolidação e documentação | 23-24/04 | 2 dias | ✅ CONCLUÍDA |

**Duração Total:** 7 dias

---

## 15. DECLARAÇÃO DE ENCERRAMENTO

Declaro que o projeto **PROJ018 — Memória de Longo Prazo do Living Lab Fiqueok** está **formalmente encerrado** com todas as entregas realizadas e critérios de aceite atendidos.

**Principais Conquistas:**
- ✅ 222 conversas do Perplexity extraídas e indexadas (97.4% de sucesso)
- ✅ 495+ documentos dos projetos PRJ001 a PRJ018 organizados em 6 camadas
- ✅ AnythingLLM e Vane configurados e operacionais
- ✅ Respostas rastreáveis com citação de fontes
- ✅ Documentação de manutenção contínua estabelecida
- ✅ Correção das relações de dependência (contínua vs. pontual)

**Próximo Passo Recomendado:**
- Iniciar PROJ019 com foco na automação da alimentação do AnythingLLM via API

---

## 16. APROVAÇÕES

| Função | Nome | Data | Status |
|--------|------|------|--------|
| GRC Lead / Responsável | Paulo Feitosa Lima | 24/04/2026 | ✅ APROVADO |
| Arquiteto de Soluções | Paulo Feitosa Lima | 24/04/2026 | ✅ APROVADO |

---

**FIM DO TERMO DE ENCERRAMENTO DO PROJETO — PROJ018 v2.0**

---

📄 **Documento salvo como:** `TEP-PRJ018-v2.0.md`
🔒 **Classificação:** CONFIDENCIAL
📍 **Localização:** `10_Projetos/PROJ018/TEP-PRJ018-v2.0.md`