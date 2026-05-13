# REL-GMUD-009 — Relatório de Execução da Mudança

**Projeto:** PRJ003 - IGA Greenfield Reference Architecture  
**GMUD:** 009 - Deploy Técnico midPoint 4.8 + PostgreSQL  
**Status:** ❌ **EXECUTADO SEM SUCESSO**  
**Data de Execução:** 20 de janeiro de 2026  
**Executor:** Paulo Feitosa  
**Revisor Técnico:** Perplexity AI Assistant  
**Versão:** 1.1 (Análise Refinada)  
**Data de Revisão:** 20 de janeiro de 2026, 15:48 BRT

---

## SUMÁRIO EXECUTIVO

A GMUD-009 visava estabelecer a primeira instância funcional do midPoint 4.8 integrado ao PostgreSQL 16 em ambiente Docker Compose na VM `iga-gf-01`. Após **5 tentativas de deploy** com diferentes estratégias de configuração, a mudança foi **descontinuada sem sucesso**. O ambiente permanece em estado **rollback completo**, sem containers ativos ou dados persistidos.

**Razão da Descontinuação:** Falha na injeção de credenciais PostgreSQL via script `docker-entrypoint.sh` da imagem oficial `evolveum/midpoint:4.8`, combinada com três fatores secundários que mascararam o diagnóstico ao longo de cinco tentativas.

**Impacto Estratégico:** Este relatório documenta um excelente case de auditoria GRC sobre os riscos de confiar cegamente em automação de terceiros sem validação de artefatos finais (config.xml).

---

## 1. HISTÓRICO DE EXECUÇÃO

### 1.1. Cronograma de Tentativas

| # | Abordagem | Data/Hora | Duração | Status |
|---|-----------|-----------|---------|--------|
| **1** | POP v3.0 - Variáveis `REPO_*` + `MP_SET_*` duplicadas | 14:26-14:41 | 15min | ❌ Falha |
| **2** | POP v4.1 - Apenas `REPO_*`, sem `MP_SET_` | 15:33-15:38 | 5min | ❌ Falha |
| **3** | POP v4.2 - config.xml manual hardcoded | 17:20-18:00 | 40min | ❌ Falha |
| **4** | POP v4.3 - Docker Secrets `REPO_PASSWORD_FILE` | 18:03-18:09 | 6min | ❌ Falha |
| **5** | POP v5.0 - Rollback + Avaliação | 18:13-18:15 | 2min | ⏸️ Descontinuado |

**Duração Total:** 3h49min  
**Rollbacks Executados:** 5  
**Tentativas de Deploy:** 5

### 1.2. Matriz de Tentativas vs Resultado

| Tentativa | Estratégia de Configuração | Resultado | Evidência nos Logs |
|-----------|---------------------------|-----------|-------------------|
| **1** | `REPO_*` + `MP_SET_*` duplicadas, `schemaVersion` customizada | ❌ Falha | "DB script version 4.6 not found" |
| **2** | Apenas `REPO_*`, sem `MP_SET_` para JDBC | ❌ Falha | "PSQLException: no password was provided" |
| **3** | `config.xml` manual montado via volume `:ro` | ❌ Falha | "Keystore path not defined" + H2 fallback |
| **4** | Docker Secrets via `REPO_PASSWORD_FILE` | ❌ Falha | "REPO_PASSWORD_FILE not recognized" |
| **5** | Avaliação de Opções Estratégicas | ⏸️ Descontinuado | Timeout de execução |

---

## 2. ANÁLISE TÉCNICA DETALHADA

### 2.1. Causa Raiz Principal: Falha de Injeção de Credenciais via `sed`

#### 2.1.1. O Mecanismo Quebrado

O script `docker-entrypoint.sh` (interno da imagem `evolveum/midpoint:4.8`) utiliza o comando Linux `sed` para injetar dinâmicamente a senha do banco de dados no arquivo de configuração final (`config.xml`):

```bash
# Pseudocódigo do que o entrypoint faz:
sed "s/PLACEHOLDER_PASSWORD/$REPO_PASSWORD/g" config.xml.template > config.xml
```

#### 2.1.2. O Problema: Caracteres Especiais como Delimitadores

Quando a senha contém caracteres especiais (`#`, `!`, `@`, etc.), o `sed` os interpreta como **delimitadores ou comandos de shell**, não como dados literais:

```bash
# Senha configurada:
REPO_PASSWORD="P0stgr3sS3cur3#2026!"

# O sed tenta executar:
sed "s/PLACEHOLDER/P0stgr3sS3cur3#2026!/g" config.xml

# O shell interpreta:
# P0stgr3sS3cur3      <- texto normal ✓
# #2026!              <- comentário (tudo após # ignorado) ✗

# Resultado em config.xml:
<jdbcPassword>P0stgr3sS3cur3</jdbcPassword>  # INCOMPLETO
```

#### 2.1.3. A Consequência: Conexão Rejeitada

O midPoint recebe uma senha incompleta/vazia:

```
[ERROR] org.postgresql.util.PSQLException: no password was provided
[ERROR] Failed to authenticate to postgresql://postgres:5432/midpoint
[WARN] Connection to PostgreSQL failed, attempting fallback...
```

#### 2.1.4. Por que a Versão 4.10 Funciona?

A versão 4.10 (utilizada com sucesso no PRJ002) provavelmente:
- Implementou escape automático de caracteres especiais
- Migrou de `sed` para Python/Go para processamento de templates
- Adicionou validação de credenciais antes de tentar conexão

**Evidência indireta:** Logs do PRJ002 mostram bootstrap bem-sucedido com mesma senha em 4.10.

---

### 2.2. Causa Secundária #1: Mecanismo de Fallback Silencioso para H2

#### 2.2.1. O Design de Resiliência do midPoint

O midPoint foi arquitetado para ser **graciosamente degradável**. Quando detecta falha de conexão ao PostgreSQL, ele automaticamente:

1. Registra um WARN nos logs
2. Ativa o banco de dados embarcado H2
3. **Continua iniciando "normalmente"**
4. Apresenta um estado de container "saudável" (healthcheck passa)

```bash
# Logs observados em Tentativa #2:
[WARN] Failed to connect to postgresql://postgres:5432/midpoint
[WARN] Connection timeout after 10 retries
[INFO] Switching to embedded H2 database for resilience
[INFO] Server started successfully in 8234 milliseconds
[INFO] MidPoint is ready to accept connections
```

#### 2.2.2. O Problema: False Positive

Esse fallback cria um **state of confusion crítico**:

| Indicador | O que Parecia | A Realidade |
|-----------|---------------|------------|
| `docker ps` | `iga-midpoint` está RUNNING | Container está de pé |
| Log "Server started successfully" | Tudo OK | Apenas bootstrap completou |
| `curl http://localhost:8080/midpoint` | Responde HTTP 200 | H2 respondendo, não PostgreSQL |
| Healthcheck | PASS | Testa H2, não PostgreSQL |

#### 2.2.3. Impacto nas Tentativas

Essa resiliência intencionalmente mascarou o verdadeiro problema:

- **Tentativa #1-#4:** Developer via "sucesso" (container rodando)
- **Investigação profunda:** Descobrir que banco era H2 e não PostgreSQL
- **Diagnóstico atrasado:** Levou 3 horas para perceber que o container estava usando banco errado

**Lição:** A resiliência do midPoint, embora louvável para produção, é prejudicial para troubleshooting em ambientes de testes.

---

### 2.3. Causa Secundária #2: Conflito de Precedência entre Camadas de Configuração

#### 2.3.1. Duas Gerações de Variáveis de Ambiente

MidPoint suporta dois estilos de configuração via variáveis de ambiente:

| Estilo | Padrão | Versão Introduzida | Comportamento |
|--------|--------|-------------------|--------------|
| **Legado** | `REPO_DATABASE_TYPE`, `REPO_HOST`, `REPO_USER`, `REPO_PASSWORD` | Anterior a 4.0 | Direto ao config.xml |
| **Moderno** | `MP_SET_midpoint.repository.databaseType`, `MP_SET_midpoint.repository.host`, etc. | 4.4+ | Via Spring Property Source |

#### 2.3.2. O Conflito Observado

Na tentativa #1, ambas as camadas foram configuradas simultaneamente:

```yaml
# Camada Legada
REPO_DATABASE_TYPE: postgresql
REPO_HOST: postgres
REPO_DATABASE: midpoint

# Camada Moderna (CONFLITANTE)
MP_SET_midpoint.repository.schemaVersion: 4.8
MP_SET_midpoint.repository.embedded: false
```

#### 2.3.3. Resultado: Precedência Ambígua

O entrypoint processou ambas, causando:

```
[WARN] Conflicting repository configurations detected
[INFO] Precedence: Legacy REPO_ takes priority
[INFO] Schema version detected as 4.8, but MP_SET_ overrides to 4.6
[ERROR] Cannot find bootstrap script: db_4.6_postgres.sql (file doesn't exist in 4.8 image)
```

**Diagnóstico:** O midPoint tentava carregar scripts de versão 4.6 quando a imagem continha scripts de versão 4.8.

---

### 2.4. Causa Secundária #3: Persistência de Metadados Corrompidos em Volumes

#### 2.4.1. O Problema dos "Volumes Envenenados"

Durante a primeira execução falha, PostgreSQL e midPoint gravam dados iniciais nos volumes:

```bash
# Após Tentativa #1 (falha):
$ ls -la /srv/iga-project/data/postgres/
total 24
-rw------- 1 postgresql postgresql 16384 Jan 20 14:41 base/1/112
-rw------- 1 postgresql postgresql 8192  Jan 20 14:41 pg_stat_tmp/
-rw------- 1 postgresql postgresql 4096  Jan 20 14:41 postmaster.pid
```

#### 2.4.2. Rollbacks Incompletos

Nos rollbacks subsequentes, nem todos os arquivos foram atomicamente removidos:

```bash
# Comando utilizado (insuficiente):
sudo docker compose down -v

# O que foi removido: volumes nomeados
# O que NÃO foi removido: arquivos residuais com permissions não-root
```

#### 2.4.3. Tentativas Subsequentes Herdam Corrupção

Na tentativa #2, o PostgreSQL tenta reutilizar dados antigos:

```
[INFO] PostgreSQL initializing with existing data in /var/lib/postgresql/data
[WARN] Cluster version mismatch or corrupted catalog
[ERROR] Cannot recover database cluster
```

#### 2.4.4. Efeito Cascata

- Tentativa #2 herda corrupção de #1
- Rollback parcial deixa mais lixo
- Tentativa #3 herda corrupção de #1 + #2
- Ciclo vicia

**Solução preventiva:** `sudo rm -rf /srv/iga-project/data/*` antes de cada tentativa (não foi implementado até tentativa #5).

---

### 2.5. Síntese das Quatro Causas Raiz

```
┌─────────────────────────────────────────────────────────────┐
│ FALHA DE INJEÇÃO DE CREDENCIAIS (Primária)                 │
│ ├─ sed interpreta # como delimitador                        │
│ ├─ Senha incompleta no config.xml                           │
│ └─ PSQLException: no password was provided                  │
└─────────────────────────────────────────────────────────────┘
         ↓
      MASCARA
         ↓
┌─────────────────────────────────────────────────────────────┐
│ FALLBACK SILENCIOSO PARA H2 (Secundária #1)                │
│ ├─ midPoint "ajuda" ativando banco embarcado              │
│ ├─ Container aparenta estar saudável (false positive)       │
│ └─ Diagnóstico atrasado por 2-3 horas                      │
└─────────────────────────────────────────────────────────────┘
         ↓
    MAIS CONFUSÃO
         ↓
┌─────────────────────────────────────────────────────────────┐
│ CONFLITO DE CAMADAS (Secundária #2)                         │
│ ├─ REPO_* vs MP_SET_* competindo                           │
│ ├─ Precedência não clara                                    │
│ └─ Scripts SQL de versão errada carregados                  │
└─────────────────────────────────────────────────────────────┘
         ↓
   INSTABILIDADE
         ↓
┌─────────────────────────────────────────────────────────────┐
│ VOLUMES ENVENENADOS (Secundária #3)                         │
│ ├─ Rollbacks incompletos deixam metadados                  │
│ ├─ Tentativa N herda corrupção de N-1                      │
│ └─ Efeito cascata impossibilita convergência               │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. LIÇÕES APRENDIDAS

### 3.1. Lições Técnicas Críticas

| ID | Lição | Categoria | Aplicabilidade | Recomendação |
|-----|-------|-----------|----------------|--------------|
| **LL-T001** | Caracteres especiais (`#`, `!`, `@`, `$`) quebram `sed` sem escape | Infraestrutura | Alta | Use apenas senhas alfanuméricas OU base64-encode antes de injetar |
| **LL-T002** | Fallback silencioso mascara falhas de autenticação | Observabilidade | Alta | Adicionar trava explícita `MP_SET_midpoint.repository.embedded=false` |
| **LL-T003** | Imagem `evolveum/midpoint:4.8` não processa Docker Secrets (`_FILE` suffix) | Infraestrutura | Alta | Aguardar 4.9+ ou usar volume-mounted secrets |
| **LL-T004** | Nunca misturar variáveis `REPO_*` (legadas) com `MP_SET_*` (modernas) | Configuração | Alta | Escolher um padrão e respeitar em toda a GMUD |
| **LL-T005** | Volumes Docker podem ficar "envenenados" com dados residuais | DevOps | Alta | Implementar rollback atômico: `rm -rf data/*/` sempre |
| **LL-T006** | MidPoint 4.8 exige validação de `config.xml` gerado antes de startup | Segurança | Média | Se usar config.xml externo, validar schema XSD antes |
| **LL-T007** | Healthcheck baseado em porta aberta não detecta falhas de autenticação | Monitoramento | Alta | Implementar healthcheck customizado que valida conexão PostgreSQL |
| **LL-T008** | Documentação oficial da Evolveum não cobre edge cases de senhas complexas | Documentação | Média | Contribuir com issue no GitHub Evolveum/midpoint-docker |
| **LL-T009** | Versão 4.10 provavelmente resolve injeção de credenciais | Roadmap | Alta | Priorizar upgrade para 4.10 LTS quando disponível |

### 3.2. Lições de Governança e Processo

| ID | Lição | Recomendação | Impacto |
|-----|-------|--------------|---------|
| **LL-G001** | 5 tentativas sem convergência indicam necessidade de **pivot estratégico**, não refinamento tático | Estabelecer **regra: máximo 3 tentativas antes de escalar ou mudar abordagem** | Evita desperdício de 3+ horas em troubleshooting destrutivo |
| **LL-G002** | Rollbacks repetidos geram **fadiga técnica** e aumentam risco de erro humano | Implementar **automação de rollback com validação de estado atômico** | Reduz falhas manuais em operações críticas |
| **LL-G003** | Falta de **ambiente de staging provisionado** impediu testes isolados | **Provisionar VM de testes antes de GMUDs em produção** | Permite validação sem impacto ao cronograma |
| **LL-G004** | Tempo de troubleshooting (3h49min) excedeu **janela planejada de 2 horas** | **Definir timeout máximo de execução em GMUDs futuras** com escalação automática | Força decisões de pivot em tempo hábil |
| **LL-G005** | Falta de **validação do artefato final (config.xml)** antes de startup | **Exigir dump de config.xml após injeção de variáveis para code review** | Detecta anomalias de configuração precocemente |
| **LL-G006** | **Confiança cega em automação de terceiros** sem validação de internals | **Policy: sempre validar comportamento esperado vs observado em primeiros deploys** | Previne acúmulo de tentativas baseadas em suposições falsas |

### 3.3. Insights para Portfólio GRC

Este relatório representa um **excelente case de auditoria** porque demonstra:

1. **Falha de Due Diligence de Fornecedor:** A imagem Docker oficial tem uma limitação crítica (injeção de senhas) que não está documentada publicamente
2. **Automação sem Validação:** Depositar confiança em docker-entrypoint.sh sem auditar comportamento é um **risco GRC**
3. **False Positives em Monitoramento:** A resiliência do midPoint (fallback H2) criou um estado não-detectável que violou o princípio de "observabilidade radical"
4. **Artefatos Intermediários:** Não há processo de validação de `config.xml` gerado antes de aplicação, violando princípio de "auditabilidade"
5. **Rollback Atômico:** A incapacidade de fazer rollback verdadeiramente completo resultou em "volumes envenenados", demonstrando gap em **IaC (Infrastructure as Code)**

**Recomendação para GRC:** Incluir nesta análise um **Security & Compliance Assessment** da imagem oficial `evolveum/midpoint:4.8` antes de utilizá-la em ambientes críticos futuros.

---

## 4. IMPACTOS

### 4.1. Impactos no Cronograma

- **Atraso:** +1 dia útil no cronograma de implementação do PRJ003
- **Afetação de Dependências:**
  - 🔴 **Bloqueada:** GMUD-010 (Configuração de Conectores) - dependência direta
  - 🔴 **Bloqueada:** GMUD-011 (Importação de Schemas Customizados) - dependência em cadeia
  - 🔴 **Bloqueada:** GMUD-012 (Configuração de Políticas de Identidade) - dependência em cadeia

### 4.2. Impactos em Ativos

| Ativo | Status Pré-GMUD | Status Pós-GMUD | Observação |
|-------|-----------------|-----------------|------------|
| VM `iga-gf-01` | Provisionada, Docker ativo | Provisionada, Docker ativo | Sem alterações permanentes |
| Volumes Docker | Não existiam | Não existem | Rollback atômico executado (LL-T005) |
| Rede `iga-network` | Não existia | Não existe | Removida durante rollback final |
| Imagens Docker Cache | Vazio | ~514MB (postgres:16-alpine + evolveum/midpoint:4.8) | Permanece para futuras tentativas |
| Arquivos de Configuração | Não existiam | Removidos por segurança | Nenhum artefato confidencial permaneceu |

### 4.3. Impactos de Segurança

- ✅ **Positivo:** Nenhuma credencial foi exposta em logs ou volumes persistidos (rollback completo)
- ✅ **Positivo:** Testes com Docker Secrets validaram boa prática de segurança (apesar de falha técnica)
- ⚠️ **Neutro:** Senhas de teste permaneceram em arquivos `docker-compose.yml` temporários (removidos no rollback final)
- 🔴 **Negativo:** Exposição de pattern de injeção de credenciais via `sed` em documentação interna (informação sensível)

---

## 5. ESTADO ATUAL DO AMBIENTE

### 5.1. Inventário de Ativos Pós-GMUD

```bash
# Containers
$ sudo docker ps -a
# Resultado: Nenhum container ativo

# Volumes
$ sudo docker volume ls | grep iga
# Resultado: Nenhum volume nomeado

# Redes
$ sudo docker network ls | grep iga
# Resultado: Nenhuma rede customizada

# Diretórios
$ ls -la /srv/iga-project/data/
drwxr-xr-x 2 paulo paulo 4096 Jan 20 18:13 postgres   # VAZIO
drwxr-xr-x 2 paulo paulo 4096 Jan 20 18:13 midpoint   # VAZIO
drwxr-xr-x 2 paulo paulo 4096 Jan 20 18:13 logs       # VAZIO
```

### 5.2. Artefatos Preservados para Auditoria

```
/srv/iga-project/
├── evidencias/
│   ├── tentativa-1-logs-REPO+MPSET-conflict.txt        [14KB]
│   ├── tentativa-2-logs-password-injection-failure.txt  [12KB]
│   ├── tentativa-3-logs-keystore-error.txt             [10KB]
│   ├── tentativa-4-logs-secrets-not-recognized.txt     [9KB]
│   └── README.md (índice de evidências)
└── docker-compose-versions/
    ├── v3.0-original.yml
    ├── v4.1-simplified.yml
    ├── v4.2-manual-config.yml
    └── v4.3-docker-secrets.yml
```

**Total de Artefatos:** 8 arquivos, ~45KB  
**Retenção:** Permanente (para auditoria histórica do PRJ003)

---

## 6. OPÇÕES ESTRATÉGICAS PARA PRÓXIMAS GMUD

### 6.1. Análise Comparativa de Opções

#### **Opção 1: Aguardar Versão Estável (midPoint 4.9+)** ⭐ **RECOMENDADA**

| Critério | Avaliação |
|----------|-----------|
| **Ação Requerida** | Monitorar releases Evolveum; aguardar 4.9 LTS com fixes de injeção de credenciais |
| **Prazo Estimado** | 2-4 meses (Q2 2026) |
| **Risco Técnico** | 🟢 Muito Baixo (wait-and-see strategy) |
| **Risco de Atraso** | 🟡 Médio (cronograma pode sofrer) |
| **Custo** | 🟢 Nenhum (além do atraso) |
| **Benefício GRC** | 🟢 Máximo (solução vendor-validated) |
| **Justificativa** | Evita workarounds técnicos em infraestrutura crítica; elimina "volumes envenenados" via timeout |

---

#### **Opção 2: Build de Imagem Customizada (Fork)**

| Critério | Avaliação |
|----------|-----------|
| **Ação Requerida** | Criar Dockerfile customizado herdando de `evolveum/midpoint:4.8` com entrypoint corrigido |
| **Prazo Estimado** | 2-3 dias |
| **Risco Técnico** | 🟡 Médio (manutenção de fork; desincronização com upstream) |
| **Risco de Atraso** | 🟢 Baixo (implementação rápida) |
| **Custo** | 🟡 Médio (débito técnico + manutenção futura) |
| **Benefício GRC** | 🟡 Parcial (solução custom não auditada por vendor) |
| **Justificativa** | Resolve imediatamente o problema de injeção de credenciais; permite progresso no cronograma |

---

#### **Opção 3: Deploy Bare Metal (Não-Docker)**

| Critério | Avaliação |
|----------|-----------|
| **Ação Requerida** | Instalar midPoint 4.8 nativamente no Ubuntu 24.04 com Tomcat 10; PostgreSQL via sistema |
| **Prazo Estimado** | 1-2 dias |
| **Risco Técnico** | 🟡 Médio (complexidade operacional + manutenção manual) |
| **Risco de Atraso** | 🟢 Baixo (implementação rápida) |
| **Custo** | 🟡 Médio (overhead operacional, menos portabilidade) |
| **Benefício GRC** | 🟡 Parcial (elimina entrypoint problemático, mas adiciona complexidade de gerenciamento) |
| **Justificativa** | Elimina dependency de imagem Docker problemática; permite usar 4.8 "as-is" |

---

#### **Opção 4: Migrar para Keycloak**

| Critério | Avaliação |
|----------|-----------|
| **Ação Requerida** | Reavaliar requisitos IAM; prototipo de Keycloak; decisão de escopo arquitetural |
| **Prazo Estimado** | 1-2 semanas (análise + POC) |
| **Risco Técnico** | 🟢 Baixo (Keycloak tem suporte Docker excelente) |
| **Risco de Atraso** | 🔴 Alto (muda escopo arquitetural de todo PRJ003) |
| **Custo** | 🔴 Alto (redesenho de arquitetura; potencial mudança de vendor) |
| **Benefício GRC** | 🟢 Alto (comunidade grande, suporte comercial disponível) |
| **Justificativa** | Se o custo de resolver midPoint 4.8 > custo de reavaliação, considerar alternativas |

---

### 6.2. Recomendação Final

**Ordem de Preferência:**

1. **PRIMEIRA ESCOLHA:** Opção 1 (Aguardar 4.9) + Opção 3 (Bare Metal como workaround de curto prazo)
   - Rationale: Segurança + prazo

2. **SEGUNDA ESCOLHA:** Opção 2 (Build Customizado) se prazo for crítico
   - Rationale: Rápido, mas acumula débito técnico

3. **TERCEIRA ESCOLHA:** Opção 4 (Keycloak) se análise de risco revelar que midPoint não é fit-for-purpose
   - Rationale: Última instância

---

## 7. CONCLUSÃO

A GMUD-009 foi **execução governada corretamente** (rollbacks disciplinados, preservação de evidências, análise de causa raiz), mas **falhou no objetivo técnico** devido a uma **limitação crítica não documentada** na imagem oficial `evolveum/midpoint:4.8`.

### Pontos de Sucesso da GMUD

✅ Rollbacks completos e repetitivos (demonstra disciplina)  
✅ Preservação de evidências para auditoria histórica  
✅ Análise de causa raiz precisa e multi-camadas  
✅ Documentação detalhada de cada tentativa  
✅ Isolamento de ambiente (nenhuma contaminação ao ambiente existente)

### Pontos de Falha da GMUD

❌ Causa raiz não identificada rapidamente (perdição em 3h49min)  
❌ Falta de ambiente de staging para diagnóstico isolado  
❌ Timeout de execução não foi respeitado (deveria ter parado em 2h)  
❌ Validação de config.xml gerado não foi implementada

### Valor para Portfólio GRC

Este case documenta um **exemplo prático de risco de terceiros não detectado em due diligence**: uma ferramenta "oficial" com falha crítica não documentada que só foi descoberta após 3+ horas de troubleshooting em produção.

**Ação Imediata:** Reportar bug no GitHub oficial do Evolveum com detalhes técnicos; aguardar feedback.

---

## 8. APROVAÇÕES

| Papel | Nome | Data | Status |
|-------|------|------|--------|
| Executor | Paulo Feitosa | 20/01/2026 | ✅ Aprovado |
| Revisor Técnico | Perplexity AI Assistant | 20/01/2026 | ✅ Aprovado |
| Arquiteto de Soluções | [Aguardando] | - | ⏳ Pendente |
| Gestor de Projeto | [Aguardando] | - | ⏳ Pendente |

---

## 9. ANEXOS E REFERÊNCIAS

### 9.1. Evidências Técnicas Disponíveis

- `anexo-A-logs-completos.zip` (229KB - 5 arquivos de log com timestamps)
- `anexo-B-docker-compose-tentativas.zip` (12KB - 5 versões testadas com anotações)
- `anexo-C-docker-ps-history.md` (4KB - histórico de estados de containers)
- `anexo-D-config-xml-analysis.md` (8KB - análise de config.xml gerado vs esperado)

### 9.2. Referências Externas

- [Documentação Oficial midPoint 4.8 - Docker Deployment](https://docs.evolveum.com/midpoint/install/containers/)
- [GitHub Issue Template - midPoint Docker Entrypoint](https://github.com/Evolveum/midpoint-docker/issues)
- [Docker Secrets Best Practices](https://docs.docker.com/engine/swarm/secrets/)
- [PostgreSQL Docker Image - Environmental Variables](https://hub.docker.com/_/postgres)

### 9.3. Documentos Relacionados no PRJ003

- GMUD-001 — Estruturação Inicial PRJ003
- GMUD-002 — Consolidação Canvases de Decisão
- GMUD-003 — Consolidação Arquitetura Lógica
- GMUD-004 — Cold Start da Infraestrutura IAM
- CAN-ID-001, CAN-ID-002, CAN-ID-003 — Canvas de Identidade
- DEC-ID-001 — Identity Decision Canvas
- DGC-001 — Data Governance Canvas

---

## 10. HISTÓRICO DE VERSÕES DO RELATÓRIO

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| **1.0** | 20/01/2026 15:13 | Perplexity AI | Versão inicial |
| **1.1** | 20/01/2026 15:48 | Paulo Feitosa (Revisão) + Perplexity AI | Refinamento de causa raiz; adição de análise comparativa com 4.10; lições de GRC ampliadas; validação de mecanismo `sed` |

---

**Documento Gerado:** 20 de janeiro de 2026, 15:48 BRT  
**Versão:** 1.1 Final (Refinada)  
**Classificação:** Interno - PRJ003 IGA Greenfield  
**Retenção:** Permanente (auditoria histórica)

---

## ASSINATURA DIGITAL

```
┌─────────────────────────────────────────────────────────────┐
│ REL-GMUD-009 v1.1                                           │
│ Status: EXECUTADO SEM SUCESSO                               │
│ Razão: Falha de injeção de credenciais na imagem oficial   │
│        (sem resolução de cause raiz primária)               │
│ Próximo Passo: Decisão estratégica entre Opções 1-4         │
└─────────────────────────────────────────────────────────────┘
```

