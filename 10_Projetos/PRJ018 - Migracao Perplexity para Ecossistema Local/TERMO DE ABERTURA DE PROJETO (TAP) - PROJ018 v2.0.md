# 

## **Migração de Base de Conhecimento Perplexity para Ecossistema Local + Memória de Longo Prazo do Living Lab (Ollama + AnythingLLM + HashiCorp Vault)**

---

| **Campo** | **Valor** |
|:---|:---|
| **ID do Projeto** | PROJ018 |
| **Versão** | 2.0 (Final) |
| **Patrocinador** | Fiqueok Lab / Living Lab de Governança de TI |
| **Gerente do Projeto** | Arquiteto de Soluções |
| **Data de Aprovação** | 22/04/2026 |
| **Classificação** | CONFIDENCIAL - Dados Técnicos e de Auditoria |
| **Sigilo** | Alto (envolve token de acesso a serviço de IA em nuvem) |

---

## 1. IDENTIFICAÇÃO DO PROJETO

### 1.1. Nome do Projeto
**PROJ018 - Migração de Base de Conhecimento Perplexity para Ecossistema Local + Memória de Longo Prazo do Living Lab (Ollama + AnythingLLM + Obsidian)**

### 1.2. Escopo Resumido
Extrair, armazenar e indexar localmente:
- **222 conversas e threads** da plataforma Perplexity AI
- **Todos os documentos dos projetos PRJ001 a PRJ018** (TAPs, TEPs, GMUDs, ADRs, POPs, relatórios)

Alimentando um sistema de **RAG (Retrieval-Augmented Generation)** baseado em **LLM local** para suporte à elaboração de documentos de Segurança da Informação, Auditoria ISO 27001 e Gestão de Identidade e Acesso (IAM), com **memória de longo prazo** sobre todo o histórico do Living Lab.

### 1.3. Stakeholders Críticos
| **Papel** | **Responsabilidade** |
|:---|:---|
| **Fiqueok Lab** | Fornecer infraestrutura (i5-12400F, 64GB RAM, Ollama) |
| **Arquiteto de Soluções** | Desenhar arquitetura de RAG, configurar LLM e embedding |
| **Gestor de Segurança (ISO 27001)** | Validar conformidade e mitigação de riscos |
| **Operador de Extração** | Executar runbook de extração do Perplexity |

---

## 2. JUSTIFICATIVA ESTRATÉGICA

### 2.1. Soberania de Dados e GRC

A utilização da plataforma Perplexity AI no ambiente corporativo introduz riscos significativos de **Shadow AI** - uso não gerenciado de ferramentas de IA em nuvem que pode expor dados sensíveis.

**Riscos Mitigados:**
- ❌ Vazamento de dados estratégicos (vulnerabilidades, lacunas de auditoria)
- ❌ Indisponibilidade de serviço (dependência de conexão com internet)
- ❌ Falta de rastreabilidade (logs)

**Benefícios da Arquitetura Local:**
- ✅ **Soberania Total:** Dados armazenados localmente sob controle criptográfico
- ✅ **Disponibilidade Offline:** Acesso garantido mesmo em contingência de rede
- ✅ **RAG Baseado em Evidências:** O modelo responde exclusivamente com base nos documentos exportados
- ✅ **Memória de Longo Prazo:** Todo o histórico do Living Lab (PRJ001 a PRJ018) indexado e pesquisável

### 2.2. Lições Aprendidas Incorporadas
- **PRJ007 (PF-006):** Proibição de arquivos `.env` com segredos; consumo de token via Vault
- **PRJ006:** API-first sobre JDBC direto (anti-padrão arquitetural)
- **PRJ014:** Golden disks e saneamento de infraestrutura
- **PRJ015:** Single Source of Truth definida antes da sincronização

---

## 3. CONFIGURAÇÃO DO MODELO E EMBEDDING (PADRÃO)

### 3.1. Stack Tecnológica Recomendada

| Componente | Tecnologia | Versão | Justificativa |
|------------|------------|--------|---------------|
| **LLM para Chat** | Qwen2.5:7b | 4.7 GB | Melhor desempenho em português; janela de contexto 16384; suporte a function calling |
| **LLM Alternativo** | DeepSeek-R1:7b | 4.7 GB | Raciocínio profundo para tarefas complexas (fallback) |
| **Embedding** | nomic-embed-text-v1 | 768 dim | Superior para textos técnicos multilíngues (vs MiniLM 384 dim) |
| **Vector Database** | LanceDB | embedded | Zero latência de rede, integrado ao AnythingLLM |
| **Interface** | AnythingLLM Desktop | latest | Workspaces por tema, chat nativo |
| **Orquestrador** | AnythingLLM + Vane (alternativo) | - | Vane para testes, AnythingLLM para produção |

### 3.2. Configuração do Workspace (Padrão Obrigatório)

| Parâmetro | Valor Recomendado | Por quê? |
|-----------|-------------------|----------|
| **Modo de Chat** | **Consulta** (Query) | Força busca APENAS nos documentos indexados; evita alucinações |
| **Modelo LLM** | `qwen2.5:7b` | Melhor desempenho em português para documentação técnica |
| **Modelo Embedding** | `nomic-embed-text-v1` | 768 dimensões, superior para multilíngue e jargão IAM/GRC |
| **Temperatura** | **0.1** | Máximo determinismo; respostas consistentes e rastreáveis |
| **Máximo de Trechos** | 20 | Alta recuperação (recall) para corpus pequeno |
| **Limiar de Similaridade** | 0.0 (sem restrição) | Maximiza recall para documentos técnicos |
| **Context Window** | 16384 (ou 8192 se lento) | Processa documentos longos (TAPs, RELs) sem truncar |
| **Prompt de Sistema** | (conforme seção 3.4) | Força citação de fontes e uso exclusivo do RAG |

### 3.3. Estrutura de Workspaces por Camada

Para contornar limitações de contexto e indexação do AnythingLLM Desktop, adotar **workspaces separados por tema**:

| Workspace                       | Conteúdo                                   | Objetivo                                       |
| ------------------------------- | ------------------------------------------ | ---------------------------------------------- |
| **Fundação (PRJ001-003)**       | PRJ001 + PRJ002 + PRJ003                   | Narrativa de evolução do laboratório           |
| **Integração (PRJ004-006)**     | PRJ004 + PRJ005 + PRJ006                   | Conexão OrangeHRM → midPoint; anti-padrão JDBC |
| **PAM e RAG (PRJ007 + PRJ018)** | PRJ007 + PRJ018                            | Fundação de segurança + projeto atual          |
| **Orquestração (PRJ008-012)**   | PRJ008 + PRJ009 + PRJ010 + PRJ011 + PRJ012 | Shadow API, Entra ID, midPoint                 |
| **Infraestrutura (PRJ013-017)** | PRJ013 + PRJ014 + PRJ015 + PRJ016 + PRJ017 | Terraform, Hyper-V, Cloud Sync, Sentinel, Edge |
| **Consolidação Final**          | Documentos das camadas anteriores          | Visão transversal do Living Lab                |

### 3.4. Prompt de Sistema Padrão

```
Você é um assistente técnico especializado em IAM (Identity and Access Management), IGA (Identity Governance and Administration) e GRC (Governança, Risco e Conformidade), com conhecimento profundo do Living Lab Fiqueok.

Seu conhecimento é construído exclusivamente a partir dos documentos indexados nesta base de conhecimento. Não utilize conhecimento externo nem invente informações. Se a resposta não estiver nos documentos, diga explicitamente: "Não encontrei evidência nos documentos disponíveis."

Contexto do laboratório: ambiente HomeLab de Paulo Feitosa, operado em Hyper-V + Windows 11 Pro, com foco em midPoint 4.10, Active Directory, OrangeHRM e HashiCorp Vault. Toda decisão relevante é documentada em GMUDs, ADRs, TAPs e TEPs.

Ao responder:
1. Cite sempre o artefato de origem (ex: "conforme TEP-PRJ014 v1.2" ou "conforme GMUD-023").
2. Diferencie fatos documentados de inferências suas.
3. Quando solicitado análise ou conclusão, apresente apenas o que os documentos suportam.
4. Use terminologia do laboratório: GMUD, ADR, checkpoint, Raft Storage, identidade canônica, fail-closed.
5. Prefira respostas em português do Brasil com termos técnicos em inglês quando consagrados.

Idioma de resposta: Português do Brasil.
Tom: técnico, direto, sem floreios.
```

### 3.5. Prompts Específicos por Workspace

**Para workspace Fundação (PRJ001-003):**
```
Foco especial nesta thread: PRJ001 (baseline de segurança), PRJ002 (infraestrutura Core + ciclo de maturidade IGA) e PRJ003 (pivô arquitetural com midPoint 4.10). Entenda a evolução do laboratório e por que o PRJ003 foi o divisor de águas.
```

**Para workspace Integração (PRJ004-006):**
```
Foco especial nesta thread: integração OrangeHRM → midPoint via JDBC e a decisão de migração para API REST. Entenda o anti-padrão arquitetural identificado no PRJ006 e suas consequências.
```

**Para workspace PAM e RAG (PRJ007 + PRJ018):**
```
Foco especial nesta thread: HashiCorp Vault como fundação PAM do laboratório, incluindo histórico de plataformas (OCI → WSL2 → Hyper-V GEN1), riscos abertos (R2: root token, R8: token svc-shadow-api) e o projeto atual PRJ018 de RAG local.
```

---

## 4. ARQUITETURA DE SEGURANÇA (DESCRITIVA)

### 4.1. Diagrama de Fluxo de Dados e Controles

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
│  │  Perplexity AI   │  3. Export via HTTPS                                 │
│  │  (Cloud)         │ ──────────────────────────────────────────────┐      │
│  └────────┬─────────┘                                               │      │
│           │                                        ┌─────────────────▼────┐ │
│           │ 4. Markdown + JSON                     │  Documentos Locais   │ │
│           │    (C:\PROJ018\raw\)                   │  (Perplexity + PRJs) │ │
│           ▼                                        └─────────┬───────────┘ │
│  ┌──────────────────┐                                          │           │
│  │  Obsidian Vault  │ ◄── 5. Edição/Revisão Manual            │           │
│  │  (Markdown)      │                                          │           │
│  └────────┬─────────┘                                          │           │
│           │                                                    │           │
│           └─────────────────────┬──────────────────────────────┘           │
│                                 │                                          │
│                                 │ 6. Indexação (Embedding)                 │
│                                 ▼                                          │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    ANYTHINGLLM (Workspaces por Tema)                  │  │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐        │  │
│  │  │ Fundação   │ │ Integração │ │ PAM + RAG  │ │ Consolida- │        │  │
│  │  │ PRJ001-003 │ │ PRJ004-006 │ │ PRJ007+018 │ │ ção Final  │        │  │
│  │  └────────────┘ └────────────┘ └────────────┘ └────────────┘        │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                      │                                     │
│                                      │ 7. Query RAG                        │
│                                      ▼                                     │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                         OLLAMA SERVER                                 │  │
│  │  ┌────────────────────┐  ┌────────────────────────────────────────┐  │  │
│  │  │ Qwen2.5:7b (chat)  │  │ nomic-embed-text-v1 (embedding)       │  │  │
│  │  └────────────────────┘  └────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2. Descrição dos Controles de Segurança por Camada

| **Camada** | **Componente** | **Controle de Segurança** |
|:---|:---|:---|
| **Autenticação** | HashiCorp Vault | Token com política de Least Privilege, TTL curto, armazenamento seguro |
| **Extração** | Script PowerShell | Sem persistência de token em disco; variável vive apenas na RAM |
| **Armazenamento** | `C:\PROJ018\` | Permissões NTFS restritas; criptografia BitLocker |
| **Indexação** | LanceDB (embedded) | Banco de vetores sem exposição de rede |
| **Inferência** | Ollama | API restrita a `127.0.0.1:11434`; sem telemetria |

---

## 5. ESTRATÉGIA DE CONSOLIDAÇÃO DE DOCUMENTOS (CAMADAS)

### 5.1. Camada 1 — Fundação (PRJ001 + PRJ002 + PRJ003)

Estes três projetos formam um bloco coerente:
- **PRJ001:** Baseline de segurança, hardening de TLS/RPC, estrutura de AD
- **PRJ002:** Infraestrutura Core + ciclo de maturidade IGA (GMUDs 022-024)
- **PRJ003:** Pivô arquitetural — midPoint 4.10, 24h de troubleshooting, 8 antipadrões catalogados

**Objetivo da consolidação:** Preservar a narrativa de evolução mais importante do laboratório.

### 5.2. Camada 2 — Integração (PRJ004 + PRJ005 + PRJ006)

Três projetos giram em torno do mesmo problema — conectar OrangeHRM ao midPoint:
- **PRJ004:** Validação do conceito com CSV
- **PRJ005:** Estabelecimento do canal JDBC
- **PRJ006:** Falha e descoberta do anti-padrão arquitetural (API-first é obrigatório)

**Objetivo da consolidação:** Contar uma história completa com começo, meio e lição.

### 5.3. Camada 3 — PAM e Contexto Atual (PRJ007 + PRJ018)

- **PRJ007:** Fundação de segurança (HashiCorp Vault), riscos abertos R2/PF-006
- **PRJ018:** Projeto atual de RAG local que usa essa fundação

**Objetivo da consolidação:** Modelo entender que o Vault usado é o mesmo que gerou os riscos documentados.

### 5.4. Camada 4 — Consolidação Final

Uma thread final que utiliza os três documentos de camada como input para visão transversal do Living Lab.

---

## 6. ANÁLISE SWOT ATUALIZADA

| **Fator** | **Análise** |
|:---|:---|
| **Strengths (Forças)** | ✅ Qwen2.5:7b superior em português<br>✅ nomic-embed-text-v1 (768 dim) para multilíngue<br>✅ 64GB RAM para múltiplos workspaces<br>✅ Soberania total dos dados |
| **Weaknesses (Fraquezas)** | ⚠️ i5-12400F sem GPU → inferência em CPU<br>⚠️ AnythingLLM Desktop com limitação de indexação<br>⚠️ Necessidade de múltiplos workspaces |
| **Oportunidades** | 🔄 Consolidação transversal após indexação por camada<br>🔄 Uso do Vane como alternativa para testes |
| **Threats (Ameaças)** | ⚠️ Indexação falha em grandes volumes<br>⚠️ Perda de correlação entre projetos em workspaces separados |

---

## 7. MATRIZ DE RISCOS E MITIGAÇÕES

| **ID** | **Risco** | **Prob.** | **Impacto** | **Mitigação** |
|:---|:---|:---|:---|:---|
| **R01** | Indexação falha no AnythingLLM Desktop | Média | Alto | Usar workspaces menores (<50 documentos) ou migrar para Vane |
| **R02** | Perda de correlação entre projetos | Média | Médio | Camada de consolidação final com documentos agregados |
| **R03** | Context window estourada em documentos longos | Baixa | Médio | Configurar 16384 (ou 8192) e monitorar performance |
| **R04** | Qwen2.5 lento no i5 sem GPU | Média | Médio | Fallback para DeepSeek-R1:7b ou reduzir context window |

---

## 8. CRITÉRIOS DE ACEITE DO PROJETO

1. ✅ 100% das conversas do Perplexity exportadas para Markdown (222 arquivos)
2. ✅ Documentos de todos os projetos (PRJ001 a PRJ018) indexados em workspaces por tema
3. ✅ Modelo Qwen2.5:7b configurado com temperatura 0.1 e modo Consulta
4. ✅ Embedding nomic-embed-text-v1 configurado (768 dimensões)
5. ✅ Workspace responde a perguntas com citações diretas dos documentos
6. ✅ Estratégia de consolidação por camadas documentada e aplicada

---

## 9. APROVAÇÕES

**Declaro que li e compreendo os riscos associados ao PROJ018, incluindo as limitações de indexação do AnythingLLM Desktop e a necessidade de múltiplos workspaces por tema. Autorizo a execução conforme estratégia de camadas definida.**

__________________________________________
**Assinatura do Patrocinador (Fiqueok Lab)**

Data: 22/04/2026

---

📄 **Documento salvo como:** `PROJ018_TAP_v2.0.md`
🔒 **Classificação:** CONFIDENCIAL
⏱️ **Tempo estimado de execução:** 2-3 horas (configuração + indexação por camadas)
