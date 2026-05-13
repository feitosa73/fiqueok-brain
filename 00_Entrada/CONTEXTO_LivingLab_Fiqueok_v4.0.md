
```markdown
# CONTEXTO — Living Lab Fiqueok

## Documento de Referência para RAG — v4.0

**Gerado em:** Maio de 2026  
**Responsável:** Paulo Feitosa Lima (IAM Specialist / Auditor / GRC Lead)  
**Fonte:** Evidência primária — vaults Obsidian exportados (PRJ001 a PRJ027) + TEPs documentados  
**Uso:** Contexto para AnythingLLM + Ollama / DeepSeek-R1  
**Versão anterior:** v3.0 (PRJ001–PRJ020)  
**Esta versão adiciona:** PRJ022 a PRJ027; lições L36–L75; atualiza PRJ003, PRJ002, PRJ012, PRJ018; adendo de rede PRJ008; camada temática 6 consolidada

---

## ÍNDICE

1. Sobre o Living Lab Fiqueok
2. Identidade do Responsável
3. Infraestrutura Base do Laboratório
4. Princípios Arquiteturais Consolidados
5. **Linha do Tempo Narrativa da Saga (PRJ001–PRJ027)**
6. PRJ001 — Laboratório de SI
7. PRJ002 — Infraestrutura Fiqueok (Atualizado)
8. PRJ003 — IGA Greenfield (Atualizado)
9. PRJ004 — IGA Data Lifecycle (CSV)
10. PRJ005 — Integração de Fonte Autoritativa (OrangeHRM)
11. PRJ006 — Integração Dinâmica via JDBC (Abortado)
12. PRJ007 — HashiCorp Vault (PAM)
13. PRJ008 — Shadow API REST (Atualizado — Adendo Rede)
14. PRJ009 — Hybrid Identity Bridge (Encerrado)
15. PRJ010 — Join Massivo OrangeHRM (Concluído)
16. PRJ011 — Entra ID Identity JOIN (Concluído)
17. PRJ012 — midPoint como Motor IGA On-Premise (Reavaliado)
18. PRJ014 — Saneamento e Padronização Hyper-V (Concluído)
19. PRJ015 — IGA Híbrido Local — AD → Entra Cloud Sync (Encerrado)
20. PRJ016 — Sentinel Identity Shield (Em Execução)
21. PRJ017 — Secure Edge Gateway & Identity-First Perimeter (Concluído)
22. **PRJ018 — Memória de Longo Prazo (Atualizado v2.0)**
23. PRJ019 — Watcher e Ingestor Automatizados para Obsidian (Frozen)
24. PRJ020 — OpenVAS/GVM + DefectDojo (Gestão de Vulnerabilidades)
25. **PRJ022 — Integração IGA: OrangeHRM × midPoint via CSV (Concluído)** ← NOVO
26. **PRJ023 — Integração midPoint com AWS IAM (Sucesso Parcial)** ← NOVO
27. **PRJ024 — Integração midPoint com GCP IAM (Sucesso Parcial)** ← NOVO
28. **PRJ025 — Integração midPoint com Keycloak (Planejado)** ← NOVO
29. **PRJ026 — Integração midPoint com Active Directory (Planejado)** ← NOVO
30. **PRJ027 — Integração midPoint com Entra ID Free (Encerrado sem Sucesso)** ← NOVO
31. Lições Aprendidas Transversais (L01–L75)
32. Frameworks de Conformidade Adotados
33. Inventário de Ativos e Topologia de Rede (Atualizado)
34. Governança e Gestão de Decisões
35. Papel das IAs no Laboratório
36. Riscos Abertos e Pendências Futuras (Atualizado)
37. Glossário Técnico do Laboratório

---

## 1. Sobre o Living Lab Fiqueok

*(mantido inalterado da v3.0)*

---

## 2. Identidade do Responsável

*(mantido inalterado da v3.0)*

---

## 3. Infraestrutura Base do Laboratório

*(mantido inalterado da v3.0)*

### CONSTRAINT-001 (ativa desde 09/02/2026)
*(mantido inalterado da v3.0)*

---

## 4. Princípios Arquiteturais Consolidados

*(mantidos da v3.0, com acréscimos abaixo)*

15. **CSV é um pipeline IGA válido** — demonstrado no PRJ022: 102 usuários em 5,1 segundos, 0 erros. Apesar de ser uma inconformidade arquitetural documentada, é robusto e operacional.
16. **Conectores comunitários para clouds são limitados** — AWSConnector e GCPConnector da Atricore provisionam usuários, mas NÃO escrevem grupos/políticas.
17. **Cloud Identity é pré-requisito para GCP** — sem ele, usuários criados pelo conector não são visíveis.
18. **App Registration sobrevive a qualquer restore local** — recursos na nuvem persistem; recursos no midPoint (conectores, resources, shadows) são voláteis.
19. **Documente o tipo de dependência** — contínua (tempo real) vs. pontual (evento único concluído). Exemplo: PRJ007→PRJ008 é contínua; PRJ018→Perplexity é pontual.

---

## 5. Linha do Tempo Narrativa da Saga (PRJ001–PRJ027)

| Período | Projeto | Status | Resultado Principal |
|---------|---------|--------|---------------------|
| Dez/2025 | PRJ001 | ✅ Concluído | Baseline de SI; migração VirtualBox → Hyper-V; scans OpenVAS; hardening inicial |
| Jan/2026 | PRJ002 | ✅ Concluído | Infra core (AD, midPoint, OrangeHRM); 25+ GMUDs; retrospectiva arquitetural |
| Jan/2026 | PRJ003 | ✅ Concluído | Fundamentos arquiteturais IGA; 19 tentativas de deploy; "Soberania de Dados" |
| Jan/2026 | PRJ004 | ✅ Concluído | CSV como fonte autoritativa; primeiro ciclo JML completo validado |
| Fev/2026 | PRJ005 | ✅ Concluído | OrangeHRM como fonte autoritativa; conectividade JDBC segura |
| Fev/2026 | PRJ006 | ⚠️ Abortado | Anti-padrão JDBC identificado; decisão API-first formalizada |
| Fev–Abr/2026 | PRJ007 | 🟡 Ativo | HashiCorp Vault operacional em GEN1; 3 plataformas tentadas |
| Abr/2026 | PRJ008 | 🟡 Parcial | Shadow API REST certificada; conector REST nativo indisponível; tag consultor removida |
| Fev–Mar/2026 | PRJ009 | ⚠️ Encerrado | Hybrid Identity Bridge abortada por expiração de créditos Azure |
| Fev/2026 | PRJ010 | ✅ Concluído | Join massivo de 100 colaboradores FinPay no OrangeHRM |
| Mar/2026 | PRJ011 | ✅ Concluído | 100 identidades provisionadas no Entra ID |
| Mar/2026 | PRJ012 | 🟡 Sucesso Parcial | midPoint como motor IGA; artefatos perdidos por rollback |
| Mar–Abr/2026 | PRJ014 | ✅ Concluído | Saneamento Hyper-V; Golden Disk mestre substituído |
| Mar–Abr/2026 | PRJ015 | ⚠️ Encerrado | Cloud Sync falhou por conflito cloud-first vs. sync-first |
| Abr/2026 | PRJ016 | 🔵 Em Execução | Sentinel Identity Shield — ITDR com Wazuh + eBPF |
| Abr/2026 | PRJ017 | ✅ Concluído | Cloudflare Zero Trust; exposição segura via OTP |
| Abr/2026 | PRJ018 | ✅ Concluído | Migração Perplexity → RAG local; 222 conversas extraídas |
| Abr/2026 | PRJ019 | ❌ Frozen | Watcher/Ingestor abortado por incompatibilidade Vault Agent + WSL2 |
| Abr/2026 | PRJ020 | 🟢 Fase B | DefectDojo + Kali Linux + GVM operacionais |
| **Mai/2026** | **PRJ022** | ✅ **Concluído** | **Pipeline IGA CSV: 102 usuários em 5,1s; Estágio B frozen por GPathResult** |
| **Mai/2026** | **PRJ023** | 🟡 **Sucesso Parcial** | **midPoint → AWS IAM: provisionamento OK; grupos/policies não escrevem** |
| **Mai/2026** | **PRJ024** | 🟡 **Sucesso Parcial** | **midPoint → GCP IAM: provisionamento reportado; Cloud Identity não ativado** |
| **Mai/2026** | **PRJ025** | 📝 **Planejado** | **midPoint → Keycloak (SSO) — TAP criado, aguardando execução** |
| **Mai/2026** | **PRJ026** | 📝 **Planejado** | **midPoint → Active Directory (LDAP) — TAP criado, aguardando execução** |
| **Mai/2026** | **PRJ027** | ❌ **Encerrado s/ Sucesso** | **midPoint → Entra ID Free: Resource nunca funcional; App Registration mantido** |

---

## 6. PRJ001 — Laboratório de SI

*(mantido inalterado da v3.0)*

---

## 7. PRJ002 — Infraestrutura Fiqueok (Atualizado)

**Status:** ✅ CONCLUÍDO  
**Período:** Dezembro/2025 — Janeiro/2026  
**GMUDs executadas:** 17 (GMUD-008 a GMUD-024)

### Resumo do TEP-PRJ002-v1.0

O projeto percorreu um ciclo completo de tentativas, bloqueadores, rollbacks e aprendizados. O fluxo completo automatizado OrangeHRM → midPoint → AD não foi atingido, mas a prova de conceito foi parcialmente validada — com linking manual funcionando e infraestrutura base consolidada.

### O que foi construído

| Componente | Status |
|------------|--------|
| midPoint 4.10 + PostgreSQL 16 | ✅ Estável |
| OrangeHRM + MariaDB | ✅ Operacional |
| Conexão midPoint → AD (LDAP 389) | ✅ Linking manual validado |
| Conexão midPoint → OrangeHRM (JDBC) | ⚠️ Test Connection OK, sync não funcional |
| Importação automática end-to-end | ❌ Não atingida |

### Estado Final do Ambiente (PRJ002)

```
OrangeHRM ──JDBC──► midPoint         ⚠️ conector configurado, sincronização automática não funcional
midPoint   ──LDAP──► AD              ✅ LDAP 389 funcional, linking manual validado
Importação via CSV                    ✅ mecanismo validado posteriormente (PRJ022)
Fluxo Joiner end-to-end              ❌ não automatizado
```

### Retrospectiva Arquitetural (Adendo)

**Decisão que nunca foi feita:** o conector escolhido foi DatabaseTable — por conveniência, não por decisão arquitetural. O conector correto para uma fonte autoritativa de RH é sempre a **interface pública** (API REST), não o banco de dados interno.

**Padrão identificado:** refinamento tático sem revisão estratégica — 17 GMUDs, múltiplas tentativas com a mesma abordagem, sem questionar o pressuposto subjacente.

### Lições do PRJ002 (L01–L12)

| ID | Lição |
|----|-------|
| L01 | Test Connection 5/5 não garante sincronização funcional |
| L02 | Import Task SUCCESS não garante criação de User (shadow ≠ focus) |
| L03 | midPoint exige `User.name` obrigatório — ausência causa falha silenciosa |
| L04 | Imagem Docker oficial do midPoint é lean — connectors opcionais requerem JAR manual |
| L05 | midPoint 4.10 tem breaking changes em Smart Correlation não documentados |
| L06 | Configurações manuais de rede Docker são efêmeras — devem ser codificadas em IaC |
| L07 | Checkpoint Hyper-V imediatamente antes da GMUD é obrigatório |
| L08 | Sanitização agressiva deve ter escopo explícito |
| L09 | Versões non-LTS têm Early Adopter Risk mensurável |
| L10 | Linking manual ≠ provisionamento automático |
| L11 | Schema discovery parcial é red flag |
| L12 | Documentação retroativa é válida mas subótima |

---

## 8. PRJ003 — IGA Greenfield (Atualizado)

**Status:** ✅ ENCERRADO COM SUCESSO  
**Período:** 14/01/2026 – 21/01/2026  
**GMUDs executadas:** 12 (GMUD-001 a GMUD-012)

### Resumo do TEP-PRJ003-v1.0

O PRJ003 formalizou a governança de identidade (GMUDs 001–004) e implantou midPoint com PostgreSQL em Docker. A fase técnica (GMUDs 005–012) enfrentou 19 tentativas de deploy com bloqueadores em midPoint 4.8 e 4.9. O sucesso foi alcançado na GMUD-012 com midPoint 4.10 e a estratégia de **"Soberania de Dados"** (injeção manual prévia do schema PostgreSQL).

### Linha do Tempo das GMUDs

| GMUD | Descrição | Resultado |
|------|-----------|-----------|
| 001-004 | Governança e Canvases | ✅ Sucesso |
| 005-007 | midPoint 4.8 tentativas | ❌ Falha |
| 008-010 | Automatização e causa raiz | ❌ Falha |
| 011 | midPoint 4.9 avaliação | ❌ Falha |
| 012 | midPoint 4.10 + Soberania de Dados | ✅ Sucesso |

### Estratégia "Soberania de Dados" (GMUD-012)

1. Limpeza nuclear de volumes
2. Boot isolado do PostgreSQL (healthcheck validado)
3. Injeção manual dos 3 scripts SQL oficiais via `psql`
4. Boot do midPoint 4.10 com variáveis `MP_SET_*`

**Duração total do deploy:** 1 minuto e 19 segundos

### Estado Final

| Componente | Status |
|------------|--------|
| VM IGA-GF-01 | ✅ Ubuntu 24.04, IP xxx.xxx.xxx.xxx |
| PostgreSQL 16 | ✅ Schema SQALE v51, 89 tabelas |
| midPoint 4.10 | ✅ Startup em 19.63s |
| Interface Web | ✅ `http://xxx.xxx.xxx.xxx:8080` |

### Lições do PRJ003 (L-01 a L-16)

| ID | Lição |
|----|-------|
| L-01 | Canvases de decisão antes da execução técnica eliminam ambiguidade |
| L-02 | Dois níveis de credenciais: infraestrutura (PostgreSQL) e aplicação (administrator) |
| L-03 | Healthcheck explícito é obrigatório — `depends_on` não é suficiente |
| L-04 | Checkpoints Hyper-V podem não restaurar estado de rede — validar DNS pós-restore |
| L-05 | Scripts SSH exigem `NOPASSWD` no sudoers — validar no Pre-Flight |
| L-06 | midPoint 4.8/4.9 têm fallback silencioso para H2 — verificar `midpoint.repository.database` |
| L-07 | Expansão de variáveis em PowerShell here-strings falha silenciosamente |
| L-08 | Volumes Docker persistem hash do primeiro boot — rollback atômico obrigatório |
| L-09 | `sed` interpreta `#`, `!`, `@` como delimitadores — usar senhas alfanuméricas |
| L-10 | Máximo 3 tentativas com mesma abordagem; na quarta, pivot estratégico |
| L-11 | midPoint 4.8 não inclui scripts SQL embutidos — baixar do GitHub |
| L-12 | Nunca fornecer `config.xml` manual no primeiro boot — keystore ainda não existe |
| L-13 | Conflito de precedência resolvido no midPoint 4.10 |
| L-14 | "Soberania de Dados" elimina dependência do entrypoint |
| L-15 | Gate de Reversibilidade (ADR-002) funcionou em 8 GMUDs |
| L-16 | 19 deploys fracassados geraram conhecimento não documentado oficialmente |

---

## 9. PRJ004 — IGA Data Lifecycle (CSV)

*(mantido inalterado da v3.0)*

---

## 10. PRJ005 — Integração de Fonte Autoritativa (OrangeHRM)

*(mantido inalterado da v3.0)*

---

## 11. PRJ006 — Integração Dinâmica via JDBC (Abortado)

*(mantido inalterado da v3.0)*

---

## 12. PRJ007 — HashiCorp Vault (PAM)

*(mantido inalterado da v3.0)*

---

## 13. PRJ008 — Shadow API REST (Atualizado)

**Status:** 🟡 ACEITAÇÃO PARCIAL (FROZEN desde 14/04/2026)  
**Adendo:** ARQ-PRJ008-v2.1-MANUT-REDES (29/04/2026)

### O que foi entregue (v3.0)
- Shadow API FastAPI operacional em `api-gf-01`
- Integração midPoint via DatabaseTable Connector
- Conector REST nativo indisponível (GPathResult)

### Adendo de Rede (29/04/2026) — Remoção da `tag:consultor`

| Item | Antes | Depois |
|------|-------|--------|
| Tag da VM `api-gf-01` | `tag:consultor` | **Removida** |
| Permissão de egresso | Bloqueada para Sentinel-Core | ✅ Restaurada |
| Modelo de segurança | Microsegmentação (PoC) | Permissões globais do proprietário |

**Justificativa:**
- PRJ008 em estado FROZEN
- Colaboração externa não se realizou
- A tag gerou "vácuo de permissões" (Default Deny), bloqueando telemetria para o Sentinel-Core

**Validação pós-remoção:**
- ICMP: `api-gf-01` → `sentinel-core` — 0% packet loss
- Promtail: envio de logs para Loki — HTTP 200
- MTU: 1280 bytes mantido

**Nota de Auditoria:** O controle de microsegmentação documentado na v2.1 permanece válido como prova de conceito (PoC) de controles de IAM, mas foi desativado na produção para garantir a disponibilidade do monitoramento eBPF/Tetragon.

---

## 14. PRJ009 — Hybrid Identity Bridge (Encerrado)

*(mantido inalterado da v3.0)*

---

## 15. PRJ010 — Join Massivo OrangeHRM (Concluído)

*(mantido inalterado da v3.0)*

---

## 16. PRJ011 — Entra ID Identity JOIN (Concluído)

*(mantido inalterado da v3.0)*

---

## 17. PRJ012 — midPoint como Motor IGA On-Premise (Reavaliado)

**Status:** 🟡 ENCERRADO COM SUCESSO PARCIAL (retroativo)  
**Data de execução original:** 06/03/2026 – 10/03/2026  
**Reavaliação:** 08/05/2026 (REL-PRJ012-v2.0)  
**Projeto sucessor:** PRJ027

### Resumo do REL-PRJ012-v2.0

O PRJ012 foi reavaliado durante a execução do PRJ027. Uma forense completa do ambiente em 08/05/2026 identificou o estado real dos artefatos.

### Estado dos Artefatos — Forense (08/05/2026)

| Artefato | Status Original (ATO 2) | Status Atual |
|----------|------------------------|---------------|
| App Registration `midpoint-iga-connector` | ✅ Criado | ✅ **PRESERVADO** |
| Client Secret | ✅ Gerado | ❌ **INVÁLIDO** (HTTP 401) |
| Permissões Graph | ✅ Concedidas | ⚠️ Parcialmente preservadas |
| Conector Graph API | ✅ Instalado | ❌ **AUSENTE** |
| Resource Entra ID | ✅ Criado | ❌ **AUSENTE** |
| Shadows (100 usuários) | ✅ Importados | ❌ **0 shadows** |
| Usuários FP001-FP012 | ✅ Existentes | ❌ **AUSENTES** |

### Diagnóstico da Causa Raiz

**O container do midPoint (`IGA-GF-02`) foi restaurado a partir de um snapshot anterior à conclusão do PRJ012** em algum momento entre março e maio de 2026.

**Evidências:**
- App Registration no Entra ID intacto (está na nuvem)
- Vault manteve o secret (independente do snapshot)
- Todos os artefatos **dentro do midPoint** (conector, resource, shadows, usuários) foram perdidos

### Avaliação vs. TAP-PRJ012

| Critério | Status |
|----------|--------|
| OBJ-01: App Registration com permissões | ✅ Atingido |
| OBJ-02: Conector midPoint → Entra ID | ❌ Não atingido |
| OBJ-03: Reconciliação de leitura | ❌ Não atingido |
| OBJ-04: Mapeamento EmployeeID | ❌ Não atingido |

### Decisão de Encerramento

**PRJ012 ENCERRADO COM SUCESSO PARCIAL**

- **FASE 1 (ATO 1)** — Fundação de Conectividade Azure: ✅ 100% bem-sucedida e permanece válida
- **FASE 2 (ATO 2)** — midPoint → Entra ID: ✅ executada com sucesso na época, mas não persistiu
- **FASE 3 (ATO 3)** — OrangeHRM → JML/RBAC: ❌ nunca foi executada

### Lições do PRJ012 (L12–L15)

| ID | Lição |
|----|-------|
| L12 | Configurações dentro do midPoint são voláteis se o container for restaurado de snapshot |
| L13 | Client Secret armazenado no Vault pode ser revogado externamente sem atualização |
| L14 | App Registrations no Entra ID sobrevivem a qualquer restore de VM local |
| L15 | Forense prévia à implementação é essencial para identificar degradação de configurações |

---

## 18. PRJ014 — Saneamento e Padronização Hyper-V (Concluído)

*(mantido inalterado da v3.0)*

---

## 19. PRJ015 — IGA Híbrido Local — AD → Entra Cloud Sync (Encerrado)

*(mantido inalterado da v3.0)*

---

## 20. PRJ016 — Sentinel Identity Shield (Em Execução)

*(mantido inalterado da v3.0)*

---

## 21. PRJ017 — Secure Edge Gateway & Identity-First Perimeter (Concluído)

*(mantido inalterado da v3.0)*

---

## 22. PRJ018 — Memória de Longo Prazo do Living Lab (Atualizado v2.0)

**Status:** ✅ CONCLUÍDO COM SUCESSO  
**Período:** 18/04/2026 – 24/04/2026  
**Versão do TEP:** 2.0 (24/04/2026)

### Resumo Executivo

O PRJ018 substituiu o uso da plataforma Perplexity por um ecossistema **100% local, soberano e rastreável** — eliminando dependência de SaaS e estabelecendo memória de longo prazo para o Living Lab.

### Entregas Realizadas

| Entrega | Resultado |
|---------|-----------|
| Extração de 222 conversas do Perplexity | ✅ 97.4% de sucesso (222 de 229 threads) |
| Instalação Ollama | ✅ Qwen2.5:7b, DeepSeek-R1:7b, nomic-embed-text-v1, bge-m3 |
| AnythingLLM Desktop configurado | ✅ Interface principal para RAG local |
| Vane (alternativa web) | ✅ Rodando em `http://localhost:3000` |
| Indexação de 495+ documentos | ✅ Organizados em 6 camadas temáticas |
| Workspace consolidado | ✅ Respostas coerentes com citação de fontes |

### Estratégia de Extração do Perplexity

A extração das 222 conversas exigiu contornar:
- **Google OAuth** — bloqueio de navegadores automatizados
- **Cloudflare Turnstile** — verificações de hardware e IP
- **Cookie HttpOnly** — impossibilidade de captura via JS
- **Conteúdo dinâmico** — carregamento sob demanda

**Solução:** `launch_persistent_context` do Playwright com perfil local persistente — login manual único, sessão reutilizada automaticamente nas 229 threads.

**Mecanismos implementados:**
- Smooth scroll (`mouse.wheel`) para forçar renderização
- Seletores CSS específicos (`div[class*="prose"]`, `div[data-testid="message-content"]`)
- Checkpoint por thread (`{i:04d}_done.txt`) para idempotência
- Frontmatter YAML com URL original e data de extração

### Estrutura de Conhecimento — 6 Camadas Temáticas

| Camada | Projetos | Status |
|--------|----------|--------|
| Camada 1 — Fundação | PRJ001, PRJ002, PRJ003 | ✅ Indexado |
| Camada 2 — Integração | PRJ004, PRJ005, PRJ006 | ✅ Indexado |
| Camada 3 — RAG e Memória | PRJ018 | ✅ Indexado |
| Camada 4 — Orquestração | PRJ008, PRJ009, PRJ010, PRJ011, PRJ012 | ✅ Indexado |
| Camada 5 — Infraestrutura | PRJ013, PRJ014, PRJ015, PRJ017 | ✅ Indexado |
| Camada 6 — Segurança, PAM e ITDR | PRJ007, PRJ016, PRJ020 | 🟡 Em construção |

### Relações de Dependência (Corretas)

| Relação | Tipo | Dependência contínua? |
|---------|------|----------------------|
| PRJ007 → PRJ008 | Contínua | ✅ Sim (Shadow API lê credenciais do Vault) |
| PRJ007 → PRJ018 | Pontual | ❌ Não (exportação usou token UMA VEZ) |
| PRJ018 → Perplexity | Evento único | ❌ Não (extração concluída) |
| PRJ018 → AnythingLLM | Contínua | ✅ Sim (RAG local para consultas) |

### Procedimento de Manutenção Contínua

Para adicionar novos documentos à Memória de Longo Prazo:

1. **Identificar a camada correta** (tabela no TEP-PRJ018-v2.0)
2. **Copiar o arquivo** para a pasta da camada (`C:\Hyper-V\Docs\CAMADA_X_...`)
3. **Indexar no workspace** da camada no AnythingLLM
4. **Atualizar o workspace consolidado** "Living Lab Fiqueok"

### Lições do PRJ018 (L23–L31)

| ID | Lição |
|----|-------|
| L23 | AnythingLLM Desktop tem limitações de indexação para grandes volumes — workspaces com no máximo 50-70 documentos |
| L24 | Qwen2.5:7b tem melhor desempenho em português que DeepSeek-R1:7b |
| L25 | nomic-embed-text-v1 (768 dim) é superior a all-MiniLM-L6-v2 (384 dim) |
| L26 | Modo "Consulta" (Query) é essencial para forçar uso exclusivo dos documentos |
| L27 | Respostas de recusa personalizadas melhoram experiência e orientam diagnóstico |
| L28 | Indexação por camadas temáticas preserva coerência narrativa |
| L29 | O tipo de VM (GEN1 vs GEN2) afeta todo o ecossistema (herdado do PRJ014) |
| L30 | Token de serviço expira e requer renovação automatizada (herdado do PRJ007) |
| **L31** | **Documente o tipo de dependência (contínua vs. pontual)** |

---

## 23. PRJ019 — Watcher e Ingestor Automatizados para Obsidian (Frozen)

*(mantido inalterado da v3.0)*

---

## 24. PRJ020 — OpenVAS/GVM + DefectDojo (Gestão de Vulnerabilidades)

*(mantido inalterado da v3.0)*

---

## 25. PRJ022 — Integração IGA: OrangeHRM × midPoint via CSV + Spike ScriptedSQL

**Status:** 🟡 PARCIALMENTE CONCLUÍDO  
**Data de Encerramento:** 04/05/2026  
**Documento:** TEP-PRJ022-v1.0

### Resumo Executivo

O PRJ022 foi aberto para resolver o bloqueio herdado do PRJ008 (ausência de conector REST compatível com midPoint 4.10 / Java 21) e estabelecer um pipeline IGA funcional entre o OrangeHRM e o midPoint 4.10.

**Estrutura em dois estágios:**

| Estágio | Status | Resultado |
|---------|--------|-----------|
| **Estágio A (CSV via Shadow API)** | ✅ **CONCLUÍDO COM SUCESSO** | Pipeline end-to-end operacional |
| **Estágio B (Spike ScriptedSQL + HTTP)** | 🔴 **FROZEN** | Bloqueio GPathResult confirmado |

### Estágio A — Pipeline CSV (Concluído)

**Dados validados:**
- CSV `hr_export.csv` com 103 linhas (1 cabeçalho + 102 registros)
- Arquivo validado dentro do container: `docker exec iga-midpoint wc -l` → 103

**Resource e Tarefa:**
- Resource: `Fiqueok HR (Shadow API CSV)` — OID `2fe1b874-8a5f-41d2-8ea9-9f4224c5f327`
- Tarefa: `Reconciliacao CSV PRJ022 - v2` — OID `15307a64-d97d-4534-b69f-92e65440c02e`

**Resultado da Reconciliação:**
```
totalSuccessCount: 102 (AccountType — add)
totalSuccessCount: 102 (UserType — add)
totalFailureCount: 0
Duration: 5.1 seconds (start 14:50:54 → end 14:51:00)
Throughput: 1.270 itens/minuto · 40,8 ms por objeto
```

### Estágio B — Spike ScriptedSQL (Frozen)

**Vetores investigados:**

| Vetor | Resultado |
|-------|-----------|
| V1 — ScriptedREST 1.1.1.e2 | `NoClassDefFoundError: GPathResult` |
| V2 — Download connector-scripted-sql via container | `wget not found in $PATH` (Alpine) |
| V3 — Download via host (`repo.evolveum.com`) | `unable to resolve host address` |
| V4 — Pré-flight Build Maven | Maven não instalado; não avançado |

**Confirmação do bloqueio (log midPoint):**
```
groovy/util/slurpersupport/GPathResult,
reason: groovy/util/slurpersupport/GPathResult
(class java.lang.NoClassDefFoundError)
```

### Caminhos para Desbloqueio Futuro

| Caminho | Descrição |
|---------|-----------|
| A | Aguardar release oficial da Evolveum (connector-rest >= 3.x) |
| B | Build Maven do polygon (`mvn clean install -pl connector-rest`) |
| C | Conector HTTP de terceiros |
| D | Reporte à comunidade Evolveum |

### Lições do PRJ022 (L32–L43)

| ID | Lição |
|----|-------|
| L32 | CSV dentro do container é o que importa — validar via `docker exec`, não apenas no host |
| L33 | O atributo `name` do User é obrigatório no midPoint |
| L34 | Correlation rule explícita é OBRIGATÓRIA no midPoint 4.10 com CsvConnector v2.9 |
| L35 | `employee_id → personalNumber` com `Strength: Strong` é a âncora da correlação |
| L36 | `wget` não está disponível no container Alpine do midPoint — usar `curl` |
| L37 | `repo.evolveum.com` pode estar inacessível via DNS em redes restritas |
| L38 | Rollback via snapshot Hyper-V é determinístico e confiável (< 2 minutos) |
| L39 | Tarefa de reconciliação antiga deve ser excluída antes de criar nova |
| L40 | Bloqueio `GPathResult` é estrutural no JAR do ScriptedREST — ocorre antes de qualquer script |
| L41 | Validação multicamada + evidência de terminal é o padrão de encerramento audit-ready |
| L42 | Pipeline CSV — apesar de inconformidade arquitetural — entregou 102 usuários em 5,1s com 0 erros |

---

## 26. PRJ023 — Integração midPoint 4.10 com AWS IAM

**Status:** ✅ ENCERRADO — SUCESSO PARCIAL  
**Data de Encerramento:** 05/05/2026  
**Conector:** AWSConnector v1.1.2 (Atricore)

### O que Funcionou

| Funcionalidade | Status |
|----------------|--------|
| Instalação do conector | ✅ |
| Correção `trustAnchors` (JAVA_OPTS com cacerts) | ✅ |
| Resource AWS IAM criado | ✅ |
| Test Connection | ✅ |
| Schema descoberto (AccountObjectClass) | ✅ |
| Mapeamento `icfs:name` → `name` | ✅ |
| Provisionamento de usuário FP004 | ✅ (GUI: "Add:Success -> FP004") |
| Remoção de usuário | ✅ |

### O que Não Funcionou

| Funcionalidade | Status | Causa |
|----------------|--------|-------|
| Gestão de grupos IAM (`awsGroups`) | ❌ | Conector **lê** grupos mas **não escreve** |
| Gestão de políticas anexadas | ❌ | Conector ignora o atributo na operação CREATE/UPDATE |

**Evidência:** O schema declara `awsGroups` como multivalue string, mas durante CREATE/UPDATE o conector não persiste os valores enviados — sem erro reportado, apenas ignorados.

### Recomendações para Fase 2

| Opção | Descrição |
|-------|-----------|
| A (recomendado) | AWS CLI via ScriptedREST para grupos/políticas |
| B | Migrar para AWS Identity Center (SCIM nativo) |
| C | Aguardar atualização do conector |

### Lições do PRJ023 (L44–L50)

| ID | Lição |
|----|-------|
| L44 | Conector Atricore é a solução correta para usuários AWS, não ScriptedREST |
| L45 | Erro `trustAnchors` é resolvido com `JAVA_OPTS` apontando cacerts |
| L46 | Mapeamento `icfs:name` → `name` é OBRIGATÓRIO para criação de usuário |
| L47 | AWSConnector **lê** grupos/políticas mas **não escreve** — limitação documentada |
| L48 | Schema do conector pode ser enganoso — declarar atributo não significa implementá-lo |
| L49 | Test Connection bem-sucedido não garante todas as operações |
| L50 | Provisionamento de usuários funciona perfeitamente; grupos/políticas pendentes |

---

## 27. PRJ024 — Integração midPoint 4.10 com GCP IAM

**Status:** 🟡 ENCERRADO — SUCESSO PARCIAL  
**Data de Encerramento:** 06/05/2026  
**Conector:** GCPConnector v1.3.0 (Atricore)

### O que Funcionou

| Funcionalidade | Status |
|----------------|--------|
| Conector baixado e copiado para `/icf-connectors/` | ✅ |
| Permissões ajustadas (`chown 1000:1000`, `chmod 644`) | ✅ |
| Conector descoberto pelo midPoint | ✅ (log: "Discovered ICF bundle ... gcp version: 1.3.0") |
| Resource GCP IAM criado (OID `16478ce0-2831-4380-8176-ab795c4f16ba`) | ✅ |
| Test Connection | ✅ (`lastAvailabilityStatus: up`) |
| Schema descoberto (`GWSAccount`) | ✅ |
| Mapeamento outbound `icfs:name` ← `name` | ✅ |
| Provisionamento reportado | ✅ (GUI: "AddSuccess -> FP001" em 1.227ms) |

### O que Não Funcionou ou Não foi Validado

| Pendência | Causa | Severidade |
|-----------|-------|------------|
| Cloud Identity não ativado | Serviço não ativado no projeto `midpoint-iga` | 🔴 Alta |
| Domínio não verificado | Cloud Identity requer domínio válido (`fiqueok.com.br`) | 🔴 Alta |
| Usuário FP001 não visível no GCP | Consequência do item acima | 🔴 Alta |
| Shadow FP001 não localizada via API | Pode ter sido removida ou nome diferente | 🟡 Média |
| Conector minimalista | Apenas `icfs:name` e `icfs:groups` suportados | 🟡 Média |

### Shadow Antiga Corrompida

Log identificou shadow de tentativa anterior:
```
ERROR: SYNCHRONIZATION: NoFocusNameSchemaException: No name in the new object. 
currentShadow=shadow:d894752f... (feitosa.lima@gmail.com)
```

### Comparação com PRJ023 (AWS)

| Critério | PRJ023 (AWS) | PRJ024 (GCP) |
|----------|--------------|--------------|
| Provisionamento usuário | ✅ (validado visualmente) | ✅ (reportado, não validado) |
| Grupos/Policies | ❌ (não escreve) | ❌ (não testado) |
| Validação visual | ✅ (AWS Console) | ❌ (Cloud Identity não ativado) |

### Caminhos para Desbloqueio Futuro

| Caminho | Esforço | Prioridade |
|---------|---------|------------|
| A — Ativar Cloud Identity com domínio `fiqueok.com.br` | 1 hora | 🔴 Alta |
| B — Verificar domínio via DNS TXT | 30 min | 🔴 Alta |
| C — Re-testar provisionamento | 30 min | 🔴 Alta |
| D — SCIM nativo do Google | 2-3 dias | 🟡 Média |
| E — Admin SDK API via ScriptedREST | 1 dia | 🟡 Média |

### Lições do PRJ024 (L51–L60)

| ID | Lição |
|----|-------|
| L51 | Conector GCP da Atricore segue o mesmo padrão do AWS: community-supported e minimalista |
| L52 | **Cloud Identity é OBRIGATÓRIO** para visualizar usuários criados pelo conector |
| L53 | Domínio válido e verificado é pré-requisito para Cloud Identity |
| L54 | Configuração via GUI é mais estável que curl com XML |
| L55 | Mapeamento `icfs:name` → `name` é obrigatório (mesma lição do AWS) |
| L56 | `trustAnchors` continua sendo problema (mesma solução do PRJ023) |
| L57 | Shadows órfãs podem causar erros de sync — limpar antes de novos testes |
| L58 | Schema minimalista do conector é limitação técnica documentada |
| L59 | POC demonstrou viabilidade, mas PRD exige decisão arquitetural (ADR) |
| L60 | Mesmo padrão de provisionamento (Role + inducement) funciona para GCP |

---

## 28. PRJ025 — Integração midPoint 4.10 com Keycloak (Planejado)

**Status:** 📝 EM PLANEJAMENTO (TAP criado, não executado)  
**Data do TAP:** Maio/2026

### Objetivo

Estabelecer integração entre midPoint 4.10 e Keycloak para:
1. Provisionamento automático de usuários no Keycloak
2. Gerenciamento de grupos e roles
3. SSO (Single Sign-On) para aplicações web
4. Sincronização de identidades (midPoint como fonte autoritativa)

### Por que Keycloak

| Benefício | Descrição |
|-----------|-----------|
| Open Source | Sem custo de licença |
| Conector maduro | ScriptedREST com exemplos disponíveis |
| API REST completa | `/admin/realms/{realm}/users` bem documentada |
| SSO nativo | OIDC, SAML, Social Login |
| Baixa complexidade | Comparado a AWS/GCP |

### Arquitetura Proposta

```
Shadow API (PRJ008) → midPoint → Keycloak (Docker, porta 8081) → Aplicações SSO
```

### Scripts Groovy Planejados

| Script | Função |
|--------|--------|
| SearchScript.groovy | GET /admin/realms/fiqueok/users |
| CreateScript.groovy | POST /admin/realms/fiqueok/users |
| GroupScript.groovy | Atribuição de grupos via PUT |

### Tempo Estimado

2 horas

---

## 29. PRJ026 — Integração midPoint 4.10 com Active Directory (Planejado)

**Status:** 📝 EM PLANEJAMENTO (TAP criado, não executado)  
**Data do TAP:** Maio/2026

### Objetivo

Estabelecer integração bidirecional entre midPoint 4.10 e Active Directory para:
1. Provisionamento automático de usuários no AD (Joiner)
2. Atualização de atributos (Mover)
3. Desativação/remoção (Leaver)
4. Gerenciamento de grupos e associações
5. Reconciliação contínua

### Por que Active Directory

| Benefício | Descrição |
|-----------|-----------|
| Conector nativo | AdLdapConnector incluso no midPoint |
| Maduro e testado | Usado em centenas de projetos |
| Bidirecional | Sincronização em ambos os sentidos |
| Alta performance | Suporte a LDAP, LDAPS, GSSAPI |

### Conta de Serviço no AD

```powershell
New-ADUser -Name "svc_midpoint" -UserPrincipalName "svc_midpoint@fiqueok.local"`
    -Enabled $true -PasswordNeverExpires $true
Add-ADGroupMember -Identity "Domain Admins" -Members "svc_midpoint"
```

### Mapeamento de Atributos

| Atributo AD | Atributo midPoint | Direção |
|-------------|-------------------|---------|
| `sAMAccountName` | `name` | inbound/outbound |
| `employeeID` | `personalNumber` | inbound/outbound |
| `givenName` | `givenName` | inbound/outbound |
| `sn` | `familyName` | inbound/outbound |
| `memberOf` | `groups` | inbound/outbound |

### Tempo Estimado

1h30min

---

## 30. PRJ027 — Integração midPoint 4.10 com Microsoft Entra ID Free

**Status:** ❌ ENCERRADO SEM SUCESSO  
**Data de Encerramento:** 08/05/2026  
**Conector:** connector-msgraph-1.0.2.0  
**Projeto predecessor:** PRJ012

### Resumo Executivo

O PRJ027 teve como objetivo integrar o midPoint 4.10 ao Microsoft Entra ID Free utilizando o conector Graph API.

**Resultado Final:** ❌ NÃO IMPLEMENTADO

| Item | Status |
|------|--------|
| App Registration criado e preservado | ✅ |
| Permissões Graph API concedidas | ✅ (5 permissões) |
| Client Secret armazenado no Vault | ✅ |
| Conector Graph instalado e descoberto | ✅ |
| Test Connection | ⚠️ Funcionou intermitentemente |
| Resource nunca ficou 100% funcional | ❌ |
| Nenhum usuário foi provisionado | ❌ |

### O que Não Funcionou

| Componente | Causa |
|------------|-------|
| Resource XML | Inconsistências de schema do midPoint 4.10 |
| Correlation | Path `attributes/employeeId` não reconhecido |
| Synchronization | Tags `<synchronize>` e `<action>` não aceitas |
| Provisionamento | Bloqueado pelos erros acima |

### Estado dos Artefatos Pós-Encerramento

| Artefato | Decisão |
|----------|---------|
| App Registration `midpoint-iga-connector` | ✅ **MANTER** (reuso futuro) |
| Client Secret | ✅ **MANTER** |
| Permissões Graph API | ✅ **MANTER** |
| Vault (`secret/entra-id/auth`) | ✅ **MANTER** |
| Snapshots das VMs | ✅ **MANTER** |

### Lições do PRJ027 (L61–L70)

| ID | Lição |
|----|-------|
| L61 | Resources antigos em maintenance mode antes de testar novos |
| L62 | midPoint provisiona TODOS os Resources de um usuário de uma vez |
| L63 | Scripts Groovy usam `<expression><script><code>`, NUNCA `<path>` |
| L64 | Scripts precisam declarar `<source>` para atributos referenciados |
| L65 | `icfs:name` precisa de source explícito |
| L66 | Schema do midPoint 4.10 para `<synchronization>` é inconsistente com documentação |
| L67 | `<synchronize>true</synchronize>` NÃO é aceito |
| L68 | `<action>` com `reconcile` NÃO é aceito para `linked` |
| L69 | Para `unlinked`, usar `<link>true</link>` em vez de `<action>` |
| L70 | Maneira mais confiável é exportar um Resource funcional do sistema |

---

## 31. Lições Aprendidas Transversais (L01–L75)

### Lições da v3.0 (L01–L08 — PRJ001–PRJ008)
*(mantidas inalteradas)*

### Lições PRJ009 (L09–L11)
*(mantidas inalteradas)*

### Lições PRJ014 (L12–L22)
*(mantidas inalteradas)*

### Lições PRJ018 (L23–L31)
*(ver seção 22)*

### Lições PRJ015 (L27–L35) — conflito de numeração resolvido
*Nota: As lições L27–L35 do PRJ015 foram renomeadas para L27_PRJ015 a L35_PRJ015 para evitar conflito com PRJ018. No contexto consolidado, usa-se a numeração original do PRJ015.*
*(detalhadas na seção 19 do v3.0)*

### Lições PRJ022 (L32–L42)
*(ver seção 25)*

### Lições PRJ023 (L44–L50)
*(ver seção 26)*

### Lições PRJ024 (L51–L60)
*(ver seção 27)*

### Lições PRJ027 (L61–L70)
*(ver seção 30)*

### Lições PRJ003 (L-01 a L-16) — numeração negativa
*(ver seção 8)*

### Lições PRJ002 (L01–L12) — conflito com v3.0
*Nota: As lições L01–L12 do PRJ002 foram renomeadas para L01_PRJ002 a L12_PRJ002 para evitar conflito com as lições da v3.0. No contexto consolidado, usa-se a numeração original do PRJ002.*
*(ver seção 7)*

### Lições PRJ012 (L12–L15) — conflito com PRJ014
*Nota: As lições L12–L15 do PRJ012 foram renomeadas para L12_PRJ012 a L15_PRJ012.*
*(ver seção 17)*

---

## 32. Frameworks de Conformidade Adotados

*(mantido inalterado da v3.0)*

---

## 33. Inventário de Ativos e Topologia de Rede (Atualizado)

### VMs Ativas (estado em maio/2026)

| VM (Hyper-V) | Hostname | Função | Status |
|--------------|----------|--------|--------|
| VAULT-GEN1 | vault-gf-01 | HashiCorp Vault 1.21.3 | ✅ Ativo |
| rh-gf-01-local | rh-gf-01 | OrangeHRM 5.x + MariaDB | ✅ Ativo (fora do padrão) |
| iga-gf-02 | iga-gf-02 | midPoint 4.10 (Docker) | ✅ Ativo |
| api-gf-01 | api-gf-01 | Shadow API FastAPI (PRJ008) | ✅ Ativo (tag consultor removida) |
| defectdojo-gf-01 | defectdojo-gf-01 | DefectDojo (Docker) | ✅ Ativo |
| sec-openvas-kali | kali | GVM (OpenVAS) nativo | ✅ Ativo |
| sentinel-core | sentinel-core | Sentinel (PRJ016) | ✅ Ativo |
| ID-P-01 | id-p-01 | AD DS (corp.fiqueok.com.br) | ⚠️ Salva |
| SYNC-01 | sync-01 | Entra Cloud Sync Agent | ⚠️ Desligada |

### Serviços Cloudflare Zero Trust (PRJ017)
*(mantido inalterado da v3.0)*

### Tenant Microsoft Entra ID

| Tenant | Domínio | Estado (maio/2026) |
|--------|---------|---------------------|
| `paulofiqueokcom.onmicrosoft.com` | `fiqueok.com.br` | App Registration `midpoint-iga-connector` preservado |

### Rede Tailscale — Tags (Atualizado)

| Tag | Status | VMs associadas |
|-----|--------|----------------|
| `tag:consultor` | ❌ **REMOVIDA** (29/04/2026) | Nenhuma |
| Permissões padrão | ✅ Ativo | `api-gf-01` com permissões de proprietário |

---

## 34. Governança e Gestão de Decisões

*(mantido inalterado da v3.0)*

---

## 35. Papel das IAs no Laboratório (Atualizado)

*(mantido o conteúdo da v3.0, com acréscimos abaixo)*

**Complemento desta versão (v4.0):**

- **PRJ002/PRJ003 (Retrospectivas):** As IAs que orientaram os projetos operaram consistentemente no nível de execução ("como configurar"), não no nível arquitetural ("o que configurar e por quê"). A ausência de orientação N4 (diagnóstico de causa raiz sistêmica e revisão de arquitetura) contribuiu para múltiplas iterações sobre o mesmo bloqueador.
- **PRJ018:** A extração do Perplexity não poderia ter sido automatizada via IA genérica — exigiu engenharia reversa de mecanismos anti-bot (Google OAuth, Cloudflare Turnstile). As IAs auxiliaram na estruturação do código, mas não previram os bloqueadores.
- **PRJ022:** IAs sugeriram continuar refinando o ScriptedREST, mas nenhuma previu que o bloqueio `GPathResult` era estrutural (classpath do JAR, não script). A solução veio da engenharia reversa do entrypoint.
- **PRJ027:** IAs forneceram exemplos de Resource XML que não funcionavam com midPoint 4.10 — as tags `<synchronize>` e `<action>` foram copiadas de documentação de versões anteriores, sem validação de compatibilidade.

---

## 36. Riscos Abertos e Pendências Futuras (Atualizado)

### Riscos de Alto Impacto (estado em maio/2026)

| Risco | Projeto | Urgência | Ação Necessária |
|-------|---------|----------|-----------------|
| Root token Vault em uso ativo | PRJ007 | Alta | GMUD dedicada para revogar |
| Token `svc-shadow-api` expira 2026-05-17 | PRJ007/PRJ008 | **URGENTE** | Verificar renovação automática |
| Backup automático Vault não configurado | PRJ007 | Alta | Implementar cron Raft snapshot |
| Auto-unseal não implementado | PRJ007 | Alta | PF-003 — backlog |
| CONSTRAINT-001 (novas VMs GEN2 impossíveis) | Lab | Média | Reinstalação Windows Q2/2026 |
| Conector REST indisponível para midPoint 4.10 | PRJ008 | Média | Build Maven ou aguardar release |
| **Cloud Identity não ativado (GCP)** | PRJ024 | **Alta** | Ativar com domínio `fiqueok.com.br` |
| **Domínio não verificado (GCP)** | PRJ024 | **Alta** | Adicionar registro TXT no DNS |
| App Registration preservado mas Client Secret inválido | PRJ027 | Média | Regenerar secret e testar |
| PRJ019 frozen — ingestão Obsidian sem solução | PRJ019 | Baixa | Alternativas documentadas (rodar como root ou VM dedicada) |

### Projetos em Fila

| Projeto | Descrição | Status |
|---------|-----------|--------|
| PRJ016 | Sentinel Identity Shield (Wazuh + eBPF) | Em execução |
| PRJ020 | OpenVAS + DefectDojo — primeiro scan API PRJ008 | Aguardando feeds |
| PRJ025 | midPoint → Keycloak (SSO) | Planejado (TAP criado) |
| PRJ026 | midPoint → Active Directory (LDAP) | Planejado (TAP criado) |
| PRJ021 | Automação OpenVAS → DefectDojo via API | PRJ020 funcional |
| PRJ019 Redesign | Ingestor Obsidian sem Vault Agent | Alternativas documentadas |
| PRJ024 Validação | Ativar Cloud Identity e re-testar GCP | Pendente |

---

## 37. Glossário Técnico do Laboratório (Atualizado)

| Termo | Definição no Contexto Fiqueok |
|-------|-------------------------------|
| **GMUD** | Gestão de Mudança — documento formal de planejamento |
| **ADR** | Architecture Decision Record |
| **Canvas (CAN-ID)** | Contrato semântico de identidade |
| **Production Checkpoint** | Checkpoint Hyper-V com VSS |
| **Soberania de Dados** | Estratégia de injeção manual de schema PostgreSQL antes do boot do midPoint (PRJ003) |
| **Smooth Scroll** | Técnica de rolagem suave usada no PRJ018 para forçar renderização do Perplexity |
| **Dependência contínua** | Relação que requer conexão em tempo real (ex: PRJ007→PRJ008) |
| **Dependência pontual** | Evento único concluído (ex: PRJ018→Perplexity) |
| **Camadas Temáticas** | Organização de documentos do PRJ018 em 6 camadas (Fundação a Segurança) |
| **GPathResult** | Erro `NoClassDefFoundError` no ScriptedREST com Java 21 (PRJ022) |
| **AWSConnector / GCPConnector** | Conectores Atricore para clouds — provisionam usuários mas não grupos/políticas |
| **Cloud Identity** | Serviço obrigatório do GCP para visualizar usuários criados via conector (PRJ024) |
| **App Registration** | Recurso do Entra ID que sobrevive a restores de VM local (PRJ012/PRJ027) |

---

**CONTEXTO_LivingLab_Fiqueok_v4.0.md — Documento de Referência para RAG**  
*Baseado exclusivamente em evidência primária dos vaults Obsidian exportados + TEPs PRJ002, PRJ003, PRJ012, PRJ018, PRJ022–PRJ027*  
*Cobrindo PRJ001 a PRJ027 — Dezembro/2025 a Maio/2026*  
*Paulo Feitosa Lima — Living Lab Fiqueok*  
*Gerado com Claude Sonnet como GRC Lead — Maio de 2026*
```

---

**Resumo do que foi adicionado/alterado no v4.0:**

| Categoria | Itens |
|-----------|-------|
| **Novos projetos** | PRJ022, PRJ023, PRJ024, PRJ025, PRJ026, PRJ027 |
| **Projetos atualizados** | PRJ002, PRJ003, PRJ008 (adendo rede), PRJ012 (reavaliação), PRJ018 (v2.0) |
| **Novas lições** | L32–L42 (PRJ022), L44–L50 (PRJ023), L51–L60 (PRJ024), L61–L70 (PRJ027), L-01–L-16 (PRJ003), L01–L12_PRJ002, L12–L15_PRJ012 |
| **Princípios arquiteturais** | +4 (CSV pipeline, conectores Atricore, Cloud Identity, dependências contínuas/pontuais) |
| **Inventário** | Atualizado: tag consultor removida, sentinel-core adicionado |
| **Riscos** | +3 (Cloud Identity, domínio, Client Secret inválido) |
| **Glossário** | +7 termos (Soberania de Dados, Smooth Scroll, GPathResult, etc.) |
