# 

## Memória de Longo Prazo do Living Lab Fiqueok

---

| **Campo** | **Valor** |
|-----------|-----------|
| **Projeto** | PROJ018 — Migração de Base de Conhecimento Perplexity para Ecossistema Local |
| **Documento** | Lições Aprendidas — PROJ018 |
| **Versão** | 1.0 |
| **Data** | 23/04/2026 |
| **Responsável** | Paulo Feitosa Lima — GRC Lead |
| **Status** | ✅ CONCLUÍDO |

---

## 1. SUMÁRIO EXECUTIVO

O PROJ018 teve como objetivo estabelecer uma **Memória de Longo Prazo** para o Living Lab Fiqueok, substituindo o uso da Perplexity como repositório de conhecimento por um ecossistema local baseado em **Ollama + AnythingLLM + LanceDB**.

O projeto extraiu **222 conversas** do Perplexity, indexou **495+ documentos** dos projetos PRJ001 a PRJ018, e configurou **5 camadas temáticas** de conhecimento, permitindo consultas transversais com citação de fontes e rastreabilidade total.

Este documento consolida as **lições aprendidas** durante a execução do PROJ018, abrangendo desde a escolha da stack tecnológica até a operação do RAG local.

---

## 2. LIÇÕES APRENDIDAS

### L23 — AnythingLLM Desktop tem limitações de indexação para grandes volumes de documentos

**Origem:** PROJ018 — Indexação de 495+ documentos

**Problema:** O AnythingLLM Desktop apresentou falhas consistentes de indexação quando tentamos adicionar muitos documentos de uma vez. Workspaces com mais de 50 documentos frequentemente corrompiam o índice, resultando em documentos "fantasma" ou respostas incompletas do modelo.

**Solução adotada:**
- Dividir os documentos em **workspaces menores por tema** (5 camadas)
- Adicionar documentos em lotes de até **30-50 arquivos**
- Aguardar a conclusão do "Save and Embed" antes de adicionar o próximo lote
- Criar um workspace consolidado apenas para consultas transversais

**Aplicação futura:**
- Qualquer novo projeto que exija RAG local deve planejar a divisão temática dos documentos
- Manter workspaces com no máximo 50-70 documentos para garantir estabilidade

---

### L24 — Qwen2.5:7b tem melhor desempenho em português que DeepSeek-R1:7b

**Origem:** PROJ018 — Testes comparativos de modelos

**Problema:** O DeepSeek-R1:7b, embora excelente para raciocínio profundo, apresentava respostas inconsistentes em português e maior taxa de alucinação quando confrontado com documentação técnica do laboratório.

**Solução adotada:**
- Adotar **Qwen2.5:7b** como modelo padrão para o RAG local
- Manter DeepSeek-R1:7b como fallback para tarefas que exigem raciocínio matemático ou lógico aprofundado

**Evidência:**
- Respostas do Qwen2.5:7b em português foram mais naturais e precisas
- O modelo seguiu instruções de formato com maior fidelidade

**Aplicação futura:**
- Para documentação técnica em português, priorizar Qwen2.5:7b
- Para tarefas de código ou matemática, considerar DeepSeek-R1:7b

---

### L25 — nomic-embed-text-v1 (768 dim) é superior a all-MiniLM-L6-v2 (384 dim) para multilíngue

**Origem:** PROJ018 — Comparação de modelos de embedding

**Problema:** O modelo `all-MiniLM-L6-v2` (384 dimensões) foi treinado predominantemente em inglês e apresentava dificuldades para capturar a semântica de termos técnicos em português, especialmente jargões de IAM/GRC.

**Solução adotada:**
- Substituir por **nomic-embed-text-v1** (768 dimensões)
- O modelo tem suporte multilíngue nativo e melhor desempenho em recuperação semântica

**Evidência:**
- A qualidade das respostas melhorou significativamente após a troca
- Menos documentos irrelevantes retornados nas consultas

**Aplicação futura:**
- Para qualquer RAG com documentos em português, priorizar embeddings multilíngues de 768+ dimensões
- Evitar embeddings monolíngues (inglês) para documentação técnica

---

### L26 — Modo "Consulta" (Query) é essencial para forçar o uso exclusivo dos documentos

**Origem:** PROJ018 — Configuração do AnythingLLM

**Problema:** O modo "Chat" padrão permite que o modelo use seu conhecimento interno de treinamento, gerando alucinações e respostas não baseadas nos documentos indexados.

**Solução adotada:**
- Configurar o **Modo de Chat** como **"Consulta" (Query)**
- Isso força o modelo a buscar APENAS nos documentos indexados no workspace

**Evidência:**
- Antes: respostas genéricas e inferências não documentadas
- Depois: respostas com citações diretas dos documentos

**Aplicação futura:**
- Todo workspace de RAG local deve usar modo "Consulta"
- Temperatura deve ser mantida baixa (0.1-0.3) para respostas determinísticas

---

### L27 — Respostas de recusa personalizadas melhoram a experiência e orientam diagnóstico

**Origem:** PROJ018 — Experiência do usuário

**Problema:** A resposta de recusa padrão `"There is no relevant information in this workspace to answer your query."` é genérica e não orienta o usuário sobre como resolver o problema.

**Solução adotada:**
- Personalizar a resposta de recusa para incluir diagnóstico e próximos passos
- Usar português do Brasil e terminologia do laboratório

**Resposta de recusa final:**
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

**Aplicação futura:**
- Sempre personalizar respostas de recusa para o domínio do conhecimento
- Incluir orientações diagnósticas, não apenas negativas

---

### L28 — A indexação por camadas temáticas preserva a coerência narrativa

**Origem:** PROJ018 — Estratégia de organização do conhecimento

**Problema:** Indexar todos os documentos juntos dilui a narrativa de evolução do laboratório. O modelo não conseguia entender que PRJ001, PRJ002 e PRJ003 formam uma unidade coesa (Fundação), enquanto PRJ004-006 formam outra (Integração).

**Solução adotada:**
- Dividir os documentos em **5 camadas temáticas**:
  - Camada 1 — Fundação (PRJ001-003)
  - Camada 2 — Integração (PRJ004-006)
  - Camada 3 — PAM e RAG (PRJ007 + PRJ018)
  - Camada 4 — Orquestração (PRJ008-012)
  - Camada 5 — Infraestrutura (PRJ013-017)

**Evidência:**
- O modelo consegue contar a história correta de cada camada
- A causalidade entre projetos é preservada (ex: PRJ003 não existe sem PRJ002)

**Aplicação futura:**
- Projetos futuros devem seguir a mesma lógica de indexação por camadas
- A camada de consolidação final pode unificar as visões transversais

---

### L29 — O tipo de VM (GEN1 vs GEN2) afeta todo o ecossistema

**Origem:** PROJ014 (herdado pelo PROJ018) — CONSTRAINT-001

**Problema:** A CONSTRAINT-001 (UEFI corrompido) impede a criação e execução confiável de VMs GEN2. Isso afetou não apenas o PRJ014, mas também o PROJ018, que depende da estabilidade do ambiente para operar o AnythingLLM e o Ollama.

**Impacto no PROJ018:**
- A VM `FOK-SRV-LDAP-01` foi perdida devido à CONSTRAINT-001
- A recuperação da VM foi impossível mesmo com VHDX íntegro
- A perda não impactou criticamente o PROJ018, mas documenta uma fragilidade do ambiente

**Aplicação futura:**
- Inventariar todas as VMs GEN2 do laboratório
- Considerar migração para GEN1 ou substituição do host

---

### L30 — O token de serviço expira e requer renovação automatizada

**Origem:** PROJ018 — Dependência do HashiCorp Vault

**Problema:** O token `svc-shadow-api` (token-svc-shadow-api) expira em 2026-05-17. Se não for renovado, a extração de novas conversas do Perplexity ficará bloqueada.

**Solução adotada:**
- Documentar a data de expiração no TAP-PRJ007-v3.0
- Configurar renovação automática via crontab (diária às 00:00)

**Aplicação futura:**
- Todo token de serviço deve ter renovação automatizada documentada
- Alertas de expiração devem ser configurados com antecedência

---

## 3. MATRIZ DE LIÇÕES POR CATEGORIA

| Categoria | Lições | Origem |
|-----------|--------|--------|
| **Ferramenta (AnythingLLM)** | L23, L26, L27 | PROJ018 |
| **Modelos (LLM e Embedding)** | L24, L25 | PROJ018 |
| **Organização do Conhecimento** | L28 | PROJ018 |
| **Infraestrutura (herdada)** | L29 | PRJ014 |
| **Segurança (herdada)** | L30 | PRJ007 |

---

## 4. RECOMENDAÇÕES PARA PROJETOS FUTUROS

| Recomendação | Baseada em |
|--------------|------------|
| Use workspaces menores (<50 documentos) para evitar corrupção de índice | L23 |
| Priorize Qwen2.5:7b para documentação em português | L24 |
| Use nomic-embed-text-v1 (768 dim) para embedding multilíngue | L25 |
| Configure o modo "Consulta" e temperatura baixa (0.1) | L26 |
| Personalize respostas de recusa para orientar diagnóstico | L27 |
| Organize documentos por camadas temáticas, não apenas por projeto | L28 |
| Inventarie VMs GEN2 e documente dependências da CONSTRAINT-001 | L29 |
| Automatize renovação de tokens de serviço com antecedência | L30 |

---

## 5. APROVAÇÕES

| Função | Nome | Data | Status |
|--------|------|------|--------|
| GRC Lead / Responsável | Paulo Feitosa Lima | 23/04/2026 | ✅ APROVADO |
| GRC Advisor | DeepSeek | 23/04/2026 | ✅ REVISADO |

---

**FIM DO DOCUMENTO — LIÇÕES APRENDIDAS PROJ018 v1.0**