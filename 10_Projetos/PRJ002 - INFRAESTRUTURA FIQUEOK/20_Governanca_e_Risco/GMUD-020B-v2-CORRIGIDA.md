================================================================================
GMUD-020B - RESTAURAÇÃO MIDPOINT 4.8.8 LTS (CLEAN SLATE)
================================================================================
Projeto: PRJ-002 Identity Governance & Administration (IGA)
Título: Restauração da Fundação de Dados e Estabilização midPoint 4.8 LTS
ID da Mudança: GMUD-020B-PRJ002
Tipo: CORRETIVA
Severidade: MÉDIA (Recuperação de Ambiente)
Responsável: Paulo Feitosa (Owner/CISO)
Orquestrador Técnico: Gemini Deep-Dive (CTO/Arch)
Data de Execução: 05/01/2026
Status: 🟡 PLANEJADA - PRONTA PARA EXECUÇÃO

================================================================================
1. CONTEXTO E JUSTIFICATIVA
================================================================================

## 1.1 Situação Atual

Conforme documentado no REL-GMUD-020.md, a tentativa de downgrade midPoint 
4.10 → 4.8.8 resultou em implementação parcial:

✅ FASE 1: Preparação e Backup (100% concluída)
✅ FASE 2: Remoção midPoint 4.10 (100% concluída)
❌ FASE 3: Deploy midPoint 4.8.8 (0% concluída - 3 tentativas falhadas)

Problema Identificado:
- Estado corrompido do banco de dados PostgreSQL
- 72 tabelas Generic Repository vs 130+ tabelas Native Sqale esperadas
- Container midpoint-server permanece unhealthy
- Erro: "missing table [m_acc_cert_campaign]"

## 1.2 Root Cause Analysis (Gemini)

Cadeia de Causalidade:
1. Injeção manual de scripts SQL (Generic Repository)
2. Incompatibilidade com arquitetura Native Sqale do midPoint 4.8.8
3. Violação do princípio "Integridade por Design" (ISO 27001)

## 1.3 Estratégia de Correção (Clean Slate)

Diferente da tentativa anterior, a GMUD-020B foca na automação nativa:

❌ Anterior: Injeção manual de SQL + troubleshooting reativo
✅ Nova: Remoção completa do volume + inicialização nativa

Objetivo: Atingir estado HEALTHY do servidor IGA em menos de 15 minutos,
eliminando qualquer intervenção manual no banco de dados.

## 1.4 Lições Aplicadas (GMUD-020)

✅ L1: Priorizar recursos embarcados (evitar GitHub/fontes externas)
✅ L2: Confiar em automação nativa de ferramentas enterprise
✅ L3: Validação incremental de estado após cada mudança crítica
✅ L4: Diagnóstico contextual considerando histórico completo
✅ L5: Circuit breaker de 20 minutos por fase sem progresso

================================================================================
2. ESCOPO E OBJETIVOS
================================================================================

## 2.1 Escopo da Mudança

Esta GMUD abrange EXCLUSIVAMENTE a Fase 3 da GMUD-020 original:

IN SCOPE:
✅ Descomissionamento do estado inconsistente (72 tabelas)
✅ Troca de imagem Alpine → Standard (Debian-based)
✅ Inicialização nativa Sqale (130+ tabelas)
✅ Validação de integridade do banco de dados
✅ Validação de acesso web ao midPoint

OUT OF SCOPE:
❌ Atualização de outros sistemas (OrangeHRM, AD, etc.)
❌ Configuração de conectores
❌ Carga de dados de teste (massa de dados)
❌ Integração com sistemas externos

## 2.2 Objetivos Mensuráveis

| Objetivo | Meta | Validação |
|----------|------|-----------|
| **Tempo de Boot** | < 15 minutos | docker logs \| grep "midPoint started" |
| **Integridade DB** | > 100 tabelas | psql -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name LIKE 'm_%';" |
| **Versão Schema** | 4.8 | psql -c "SELECT databaseschemaversion FROM m_global_metadata;" |
| **Disponibilidade Web** | HTTP 200 | curl -I http://xxx.xxx.xxx.xxx:8080/midpoint/ |
| **Login Funcional** | Dashboard visível | Browser login administrator/5ecr3t |

## 2.3 Benefícios Esperados

- **Integridade (A.12.1.2)**: Ambiente reflete exatamente a arquitetura 
  homologada pela Evolveum para versão 4.8 LTS
- **Disponibilidade (A.17.1.1)**: Imagem standard reduz probabilidade de 
  erros de "arquivo não encontrado"
- **Rastreabilidade**: Base limpa para futuras integrações (OrangeHRM, AD)

================================================================================
3. PRÉ-REQUISITOS E VALIDAÇÕES INICIAIS
================================================================================

## 3.1 Validações de Ambiente (Obrigatórias)

Executar ANTES de iniciar a GMUD:

```bash
# 1. VM operacional
systemctl status docker
# Esperado: active (running)

# 2. Espaço em disco
df -h /var/lib/docker
# Esperado: > 5 GB disponível

# 3. Conectividade de rede
ping -c 3 8.8.8.8
# Esperado: 0% packet loss

# 4. PostgreSQL 16 respondendo
docker ps | grep postgres
# Esperado: Container postgres:16-alpine UP
```

Checklist de Pré-requisitos:

□ VM IGA-P-01 operacional (Hyper-V)
□ Docker daemon funcional
□ Espaço em disco: > 5 GB em /var/lib/docker
□ Espaço em /backup: > 2 GB disponível
□ Conectividade de rede validada
□ PostgreSQL 16 container respondendo

## 3.2 Backups Validados (da GMUD-020)

Backups criados durante a GMUD-020 e disponíveis para rollback:

✅ **Checkpoint Hyper-V**: IGA-P-01_Checkpoint_GMUD-020
   - Criado: 2026-01-04 20:30 BRT
   - Status: Disponível (validado)
   - Uso: Rollback completo de VM

✅ **Backup PostgreSQL**: /tmp/midpoint_backup_20260104.sql
   - Tamanho: ~2.5 MB
   - Conteúdo: Dump do midPoint 4.10 original
   - Validação: pg_restore --list executado com sucesso

✅ **Backup midpoint_home**: /backup/midpoint_home_backup_20260104.tar.gz
   - Conteúdo: Configurações, logs, objetos iniciais
   - Status: Íntegro

## 3.3 Estado Atual do Ambiente

Containers:
- midpoint-db: ⏹️ Stopped (volume corrompido)
- midpoint-server: ⏹️ Stopped
- orangehrm: ✅ Up (não será afetado)

Volumes Docker:
- midpoint-db-data: ❌ CORROMPIDO (72 tabelas Generic)
- midpoint_home: ⚠️ Estado indefinido

Network:
- midpoint-net: ✅ Funcional (bridge driver)

Imagens Locais:
- evolveum/midpoint:4.8.8-alpine (testada - falha de schema)
- postgres:16-alpine ✅

================================================================================
4. PROCEDIMENTO DE EXECUÇÃO (FASE 3 - RESTAURAÇÃO)
================================================================================

Esta fase substitui integralmente a Fase 3 falha da GMUD-020 e utiliza a
estratégia de "Clean Slate".

## PASSO 1: DESCOMISSIONAMENTO DO ESTADO INCONSISTENTE

### Objetivo
Apagar completamente o "rastro" das 72 tabelas legadas que impedem o boot
do sistema.

### Comando 1.1: Parar containers (se estiverem rodando)
```bash
cd /caminho/para/docker-compose/
docker compose down
```

**Validação:**
```bash
docker ps -a | grep midpoint
# Esperado: Nenhuma saída (containers removidos)
```

### Comando 1.2: Remover volume corrompido
```bash
docker volume rm midpoint-db-data
```

**⚠️ CRÍTICO**: Este é o passo mais importante da GMUD. Sem a remoção completa
do volume, o PostgreSQL manterá as 72 tabelas inconsistentes.

**Validação GRC (Obrigatória):**
```bash
docker volume ls | grep midpoint-db-data
# Esperado: Nenhuma saída (volume não existe mais)
```

**Se o volume ainda aparecer:**
```bash
# Forçar remoção
docker volume rm -f midpoint-db-data

# Verificar novamente
docker volume ls | grep midpoint-db-data
```

### Critério de Aceite PASSO 1:
✅ Containers midpoint removidos
✅ Volume midpoint-db-data NÃO aparece em docker volume ls
✅ Tempo < 2 minutos

---

## PASSO 2: AJUSTE DE ROBUSTEZ DA IMAGEM

### Objetivo
Trocar a imagem Alpine pela Standard (Debian-based), que é mais resiliente
em relação aos caminhos de scripts internos.

### Contexto da Mudança
Durante a GMUD-020, a imagem 4.8.8-alpine apresentou erro:
"DB script (/sql/postgresql-4.8-all.sql) couldn't be found"

**Root Cause**: Imagem Alpine usa paths otimizados, menos tolerantes a
variações de estrutura de diretórios.

**Solução**: Imagem Standard (Debian) é mais verbosa e robusta.

### Comando 2.1: Backup do docker-compose.yml
```bash
cp docker-compose.yml docker-compose.yml.bak_$(date +%Y%m%d)
```

### Comando 2.2: Substituir imagem Alpine → Standard
```bash
sed -i 's/evolveum\/midpoint:4\.8\.8-alpine/evolveum\/midpoint:4.8.8/' docker-compose.yml
```

**Alternativa manual (nano/vim):**
```yaml
# Antes:
image: evolveum/midpoint:4.8.8-alpine

# Depois:
image: evolveum/midpoint:4.8.8
```

**Validação:**
```bash
grep "image: evolveum/midpoint:" docker-compose.yml
# Esperado: evolveum/midpoint:4.8.8 (SEM sufixo -alpine)
```

### Critério de Aceite PASSO 2:
✅ Backup do docker-compose.yml criado
✅ Imagem alterada para 4.8.8 (sem -alpine)
✅ Sintaxe do YAML validada
✅ Tempo < 2 minutos

---

## PASSO 3: INICIALIZAÇÃO NATIVA SQALE

### Objetivo
Permitir que o midPoint detecte o banco vazio e crie automaticamente as 
130+ tabelas necessárias para o repositório Native Sqale.

### Comando 3.1: Subir containers
```bash
docker compose up -d
```

### Comando 3.2: Monitoramento em tempo real
```bash
docker logs -f midpoint-server
```

**Pressionar Ctrl+C para sair do modo follow quando "midPoint started" aparecer**

### Marcos de Progresso Esperados

```
[00:00-02:00] Downloading layers (se imagem não estiver em cache)...
[02:00-04:00] Starting PostgreSQL connection...
[04:00-08:00] Initializing Native Repository Sqale...
              Mensagem esperada: "Creating database schema..."
[08:00-10:00] Creating tables (m_*, audit.*, quartz.*)...
              Mensagem esperada: "Creating table m_abstract_role..."
[10:00-12:00] Loading initial objects (Administrator, Superuser Role)...
              Mensagem esperada: "Loading initial objects from..."
[12:00-14:00] Starting web server (Tomcat)...
              Mensagem esperada: "Starting ProtocolHandler..."
[14:00-15:00] Mensagem: "midPoint started (v4.8.8)"
```

### Mensagens de Sucesso (Esperadas)

```
INFO: midPoint started
INFO: midPoint home: /opt/midpoint/var
INFO: Repository: Native (Sqale)
INFO: Database: PostgreSQL 16.x
```

### Mensagens de Alerta (Aceitáveis)

```
WARN: Some XML schemas are not up-to-date (primeira inicialização)
WARN: No keystore found (certificados podem ser configurados depois)
```

### Mensagens de Erro (Críticas - Ativar Rollback)

```
FATAL: Could not connect to database
ERROR: Missing table m_*
ERROR: Schema version mismatch
```

### Critério de Aceite PASSO 3:
✅ Log exibe "midPoint started"
✅ Container status: healthy
✅ Nenhuma mensagem FATAL ou ERROR nos logs
✅ Tempo < 15 minutos

**Se o tempo exceder 15 minutos SEM progresso:**
- Ativar Circuit Breaker (Lição L5)
- Proceder para Rollback (Seção 6)

---

## PASSO 4: VALIDAÇÃO DE INTEGRIDADE DO BANCO

### Objetivo
Confirmar que o Native Sqale criou corretamente as 130+ tabelas necessárias.

### Comando 4.1: Contagem de tabelas midPoint (prefixo m_)
```bash
docker exec midpoint-db psql -U midpoint -d midpoint -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'm_%';"
```

**Resultado Esperado:**
```
 count
-------
   132
(1 row)
```

**Interpretação:**
- < 100 tabelas: ❌ FALHA - Native Sqale não inicializou corretamente
- 100-130 tabelas: ⚠️ ATENÇÃO - Validar logs para warnings
- > 130 tabelas: ✅ SUCESSO - Repositório completo

### Comando 4.2: Verificar tabelas críticas
```bash
docker exec midpoint-db psql -U midpoint -d midpoint -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename IN ('m_user', 'm_role', 'm_abstract_role', 'm_acc_cert_campaign') ORDER BY tablename;"
```

**Resultado Esperado:**
```
     tablename
-------------------
 m_abstract_role
 m_acc_cert_campaign
 m_role
 m_user
(4 rows)
```

**Se alguma tabela estiver faltando**: ❌ FALHA - Ativar Rollback

### Comando 4.3: Versão do schema
```bash
docker exec midpoint-db psql -U midpoint -d midpoint -c "SELECT databaseschemaversion FROM m_global_metadata;"
```

**Resultado Esperado:**
```
 databaseschemaversion
-----------------------
 4.8
(1 row)
```

### Comando 4.4: Verificar schema audit
```bash
docker exec midpoint-db psql -U midpoint -d midpoint -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'audit';"
```

**Resultado Esperado:**
```
 count
-------
    15
(1 row)
```

### Critério de Aceite PASSO 4:
✅ Banco com > 100 tabelas (prefixo m_)
✅ Tabelas críticas presentes (m_user, m_role, etc.)
✅ Versão schema: 4.8
✅ Schema audit criado (15+ tabelas)
✅ Tempo < 5 minutos

---

## PASSO 5: VALIDAÇÃO DE DISPONIBILIDADE WEB

### Objetivo
Confirmar que o midPoint está acessível via navegador e que o login funcional
está operacional.

### Comando 5.1: Health check HTTP
```bash
curl -I http://xxx.xxx.xxx.xxx:8080/midpoint/
```

**Resultado Esperado:**
```
HTTP/1.1 302 
Location: http://xxx.xxx.xxx.xxx:8080/midpoint/login
...
```

**Interpretação:**
- HTTP 302: ✅ Redirecionamento para /login (comportamento esperado)
- HTTP 200: ✅ Página carregou
- HTTP 404: ❌ midPoint não está respondendo
- HTTP 500: ❌ Erro interno do servidor

### Comando 5.2: Verificar porta escutando
```bash
netstat -tlnp | grep 8080
```

**Resultado Esperado:**
```
tcp6  0  0 :::8080  :::*  LISTEN  12345/java
```

### Comando 5.3: Status do container
```bash
docker ps --format "table {{.Names}}	{{.Status}}" | grep midpoint
```

**Resultado Esperado:**
```
midpoint-server    Up 10 minutes (healthy)
midpoint-db        Up 10 minutes
```

**Se status for "unhealthy":**
```bash
# Verificar health check logs
docker inspect midpoint-server | grep -A 10 "Health"
```

### Validação Manual (Navegador)

**Passo 5.4: Acessar via browser**
1. Abrir navegador
2. URL: http://xxx.xxx.xxx.xxx:8080/midpoint/
3. Aguardar redirecionamento para /login

**Checklist Visual:**
□ Página de login carrega sem erros 404/500
□ Logo midPoint visível
□ Campos "Username" e "Password" presentes
□ Versão exibida no rodapé: 4.8.8
□ Nenhuma mensagem de erro em vermelho

**Passo 5.5: Realizar login**
- Username: `administrator`
- Password: `5ecr3t`
- Clicar em "Sign in"

**Resultado Esperado:**
□ Login bem-sucedido (sem mensagens de erro)
□ Dashboard do midPoint visível
□ Menu lateral esquerdo presente (Users, Roles, Resources, etc.)
□ Nenhum erro em console do navegador (F12)

### Critério de Aceite PASSO 5:
✅ Curl retorna HTTP 200 ou 302
✅ Porta 8080 escutando
✅ Container status: healthy
✅ Página de login carrega no navegador
✅ Login com administrator/5ecr3t funcional
✅ Dashboard visível sem erros
✅ Tempo < 5 minutos

================================================================================
5. MATRIZ DE VALIDAÇÃO CONSOLIDADA
================================================================================

Executar TODOS os testes abaixo após a conclusão do Passo 5:

| # | Teste | Comando de Verificação | Resultado Esperado | Status |
|---|-------|------------------------|-------------------|--------|
| 1 | **Boot do midPoint** | `docker logs midpoint-server \| grep "started"` | "midPoint started" | □ |
| 2 | **Contagem de Tabelas** | `docker exec midpoint-db psql -U midpoint -d midpoint -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name LIKE 'm_%';"` | > 100 tabelas | □ |
| 3 | **Versão do Schema** | `docker exec midpoint-db psql -U midpoint -d midpoint -c "SELECT databaseschemaversion FROM m_global_metadata;"` | 4.8 | □ |
| 4 | **Tabela Crítica** | `docker exec midpoint-db psql -U midpoint -d midpoint -c "SELECT * FROM m_acc_cert_campaign LIMIT 1;"` | (0 rows) ou resultado sem erro | □ |
| 5 | **HTTP Health Check** | `curl -I http://xxx.xxx.xxx.xxx:8080/midpoint/` | HTTP 200 ou 302 | □ |
| 6 | **Container Status** | `docker ps \| grep midpoint-server` | Up X minutes (healthy) | □ |
| 7 | **Porta Listening** | `netstat -tlnp \| grep 8080` | LISTEN | □ |
| 8 | **Login Web** | Browser: http://xxx.xxx.xxx.xxx:8080/midpoint/ | Tela de Login visível | □ |
| 9 | **Autenticação** | Credenciais: administrator/5ecr3t | Dashboard visível | □ |
| 10 | **Versão Exibida** | Rodapé da interface web | 4.8.8 | □ |

**Taxa de Sucesso Requerida**: 10/10 testes (100%)

**Se algum teste falhar:**
- Revisar logs: `docker logs midpoint-server --tail 100`
- Verificar conectividade DB: `docker exec midpoint-db psql -U midpoint -d midpoint -c "\dt" | head -20`
- Se não houver resolução em 10 minutos: Ativar Rollback (Seção 6)

================================================================================
6. ROLLBACK PLAN
================================================================================

## 6.1 Critérios de Ativação de Rollback

Ativar rollback IMEDIATAMENTE SE:

❌ Tempo de execução de qualquer passo > 20 minutos sem progresso
❌ Erros críticos em logs (ex: "FATAL", "Cannot connect to database")
❌ Container permanece unhealthy por > 10 minutos
❌ Teste de validação falha após 3 tentativas de correção
❌ Tabelas críticas ausentes no banco (m_user, m_role, etc.)

## 6.2 Estratégia de Rollback Completo (Recomendada)

**Cenário**: Falha crítica sem possibilidade de correção rápida

**Tempo Estimado**: 5-8 minutos

### Rollback 6.2.1: Restaurar Checkpoint Hyper-V

**No host Hyper-V (PowerShell como Administrador):**
```powershell
# Parar a VM
Stop-VM -Name "IGA-P-01" -Force

# Restaurar checkpoint
Restore-VMSnapshot -Name "IGA-P-01_Checkpoint_GMUD-020" -VMName "IGA-P-01" -Confirm:$false

# Iniciar VM
Start-VM -Name "IGA-P-01"

# Aguardar boot (2-3 minutos)
Start-Sleep -Seconds 180

# Verificar status
Get-VM -Name "IGA-P-01" | Select-Object Name, State, Status
```

**Validação:**
```powershell
# Esperado: State = Running, Status = Operating normally
```

**Resultado do Rollback:**
- VM retorna ao estado PRÉ-GMUD-020
- midPoint: Estado corrompido (72 tabelas) - como estava antes
- OrangeHRM: Operacional (não afetado)
- Todos os backups: Preservados

**Próxima Ação:**
- Análise de root cause da falha da GMUD-020B
- Planejamento de GMUD-020C (se necessário)

## 6.3 Rollback Parcial (Apenas Docker)

**Cenário**: Falha específica no midPoint, sem necessidade de restaurar VM completa

**Tempo Estimado**: 8-10 minutos

### Rollback 6.3.1: Parar containers
```bash
docker compose down
```

### Rollback 6.3.2: Remover volumes
```bash
docker volume rm midpoint-db-data
docker volume rm midpoint_home
```

### Rollback 6.3.3: Restaurar docker-compose.yml original
```bash
cp docker-compose.yml.bak_20260105 docker-compose.yml
```

### Rollback 6.3.4: Voltar para imagem Alpine (se necessário)
```bash
sed -i 's/evolveum\/midpoint:4.8.8/evolveum\/midpoint:4.8.8-alpine/' docker-compose.yml
```

**Resultado do Rollback:**
- Retorno ao estado pós-Fase 2 da GMUD-020
- midPoint: Indisponível (esperado)
- Possibilidade de nova tentativa com estratégia diferente

## 6.4 Rollback de Emergência (Restauração de Backup)

**Cenário**: Checkpoint Hyper-V indisponível ou corrompido

**Tempo Estimado**: 15-20 minutos

### Rollback 6.4.1: Restaurar banco PostgreSQL
```bash
# Parar containers
docker compose down

# Remover volume corrompido
docker volume rm midpoint-db-data

# Recriar volume
docker volume create midpoint-db-data

# Subir apenas o PostgreSQL
docker compose up -d midpoint-db

# Aguardar 30 segundos
sleep 30

# Restaurar dump
cat /tmp/midpoint_backup_20260104.sql | docker exec -i midpoint-db psql -U midpoint -d midpoint
```

### Rollback 6.4.2: Restaurar midpoint_home
```bash
docker volume rm midpoint_home
docker volume create midpoint_home
docker run --rm -v midpoint_home:/target -v /backup:/source alpine tar xzf /source/midpoint_home_backup_20260104.tar.gz -C /target
```

### Rollback 6.4.3: Subir midPoint 4.10 (versão original)
```bash
# Editar docker-compose.yml para usar 4.10
sed -i 's/evolveum\/midpoint:4.8.8/evolveum\/midpoint:4.10/' docker-compose.yml

# Subir containers
docker compose up -d
```

**Resultado do Rollback:**
- midPoint 4.10 restaurado (versão original pré-downgrade)
- Dados preservados
- Possibilidade de replanejar estratégia de downgrade

================================================================================
7. ANÁLISE DE RISCO E AUDITORIA (ISO 27001)
================================================================================

## 7.1 Riscos Técnicos

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| **R1: midPoint não inicializar Native Sqale** | BAIXA | ALTO | Validação incremental (Passo 4). Rollback via Checkpoint disponível. |
| **R2: Volume não ser removido completamente** | BAIXA | ALTO | Validação GRC obrigatória no Passo 1.2. Comando force (-f) disponível. |
| **R3: Timeout de download da imagem** | BAIXA | MÉDIO | Executar `docker pull evolveum/midpoint:4.8.8` antes da GMUD. |
| **R4: PostgreSQL não responder** | MUITO BAIXA | ALTO | Container postgres testado e funcional antes da GMUD. |
| **R5: Conflito de porta 8080** | MUITO BAIXA | MÉDIO | Validação de porta livre no pré-requisito 3.1. |

## 7.2 Controles ISO 27001 Implementados

| Controle | Descrição | Evidência |
|----------|-----------|-----------|
| **A.12.1.2 - Gestão de Mudanças** | GMUD documentada, aprovada e rastreável | Este documento (GMUD-020B.md) |
| **A.12.3.1 - Backup de Informações** | Backups validados antes da mudança | Seção 3.2 (3 camadas de backup) |
| **A.12.4.1 - Log de Eventos** | Logs completos da execução serão arquivados | docker logs > execution_log.txt |
| **A.14.2.2 - Procedimentos de Entrega** | Validação de integridade pós-deploy | Matriz de Validação (Seção 5) |
| **A.16.1.7 - Lições Aprendidas** | Aplicação de 5 lições da GMUD-020 | Seção 1.4 |
| **A.17.1.2 - Continuidade de TI** | Rollback plan com RTO < 10 minutos | Seção 6 (3 estratégias) |

## 7.3 Conformidade e Evidências

**Evidências Geradas:**
□ REL-GMUD-020B.md (relatório pós-execução)
□ execution_log_20260105.txt (logs completos)
□ screenshots/ (evidências visuais de validação)
□ docker-compose.yml.bak_* (backup de configuração)

**Rastreabilidade:**
- Ticket Original: GMUD-020 (Fase 3 incompleta)
- Continuação: GMUD-020B (esta GMUD)
- Projeto: PRJ-002 (IGA)
- Epic: Identity Governance
- Responsável: Paulo Feitosa

**Auditoria:**
- Todos os comandos executados serão documentados com timestamp
- Aprovações registradas na Seção 12
- Relatório pós-GMUD obrigatório (modelo em Seção 11.3)

================================================================================
8. MÉTRICAS E KPIs
================================================================================

## 8.1 Tempo de Execução (RTO)

| Passo | Atividade | Tempo Planejado | Tempo Máximo | Buffer |
|-------|-----------|----------------|--------------|--------|
| Passo 1 | Descomissionamento | 2 min | 3 min | +1 min |
| Passo 2 | Ajuste de Imagem | 2 min | 3 min | +1 min |
| Passo 3 | Inicialização Native | 12 min | 15 min | +3 min |
| Passo 4 | Validação DB | 3 min | 5 min | +2 min |
| Passo 5 | Validação Web | 3 min | 5 min | +2 min |
| **TOTAL** | **Fase 3 Completa** | **22 min** | **31 min** | **+9 min** |

**RTO Global (incluindo Rollback):**
- Execução Normal: 22 minutos
- Rollback (se necessário): +8 minutos
- **Máximo Absoluto**: 40 minutos

## 8.2 Objetivos de Recuperação (RPO)

| Ativo | RPO | Backup Disponível | Localização |
|-------|-----|------------------|-------------|
| VM IGA-P-01 | 0 min | Checkpoint Hyper-V | Host Hyper-V |
| Banco PostgreSQL | 24h | Dump SQL | /tmp/midpoint_backup_20260104.sql |
| Configurações midPoint | 24h | Tar.gz | /backup/midpoint_home_backup_20260104.tar.gz |

## 8.3 Indicadores de Sucesso

| KPI | Meta | Medição | Status |
|-----|------|---------|--------|
| **Taxa de Sucesso da GMUD** | 100% | Todos os 10 testes da matriz passam | □ |
| **Tempo de Indisponibilidade** | < 15 min | Tempo entre docker compose down e login funcional | □ |
| **Integridade de Dados** | 100% | 0 perda de tabelas ou configurações | □ |
| **Performance Login** | < 5s | Tempo de resposta da página de login | □ |
| **Disponibilidade Pós-GMUD** | > 99% | Container healthy por > 24h sem reiniciar | □ |

## 8.4 Checklist de Conformidade Final

□ Backups validados antes do início (ISO 27001 A.12.3.1)
□ Mudança documentada e aprovada (ISO 27001 A.12.1.2)
□ Validações de integridade executadas (ISO 27001 A.14.2.2)
□ Lições aprendidas aplicadas (ISO 27001 A.16.1.7)
□ Rollback plan testável disponível (ISO 27001 A.17.1.2)
□ Evidências geradas e arquivadas (ISO 27001 A.18.1.3)
□ Relatório pós-GMUD elaborado (Seção 11.3)
□ Comunicação aos stakeholders (Seção 9)

================================================================================
9. COMUNICAÇÃO E STAKEHOLDERS
================================================================================

## 9.1 Notificação Pré-GMUD (T-2h)

**Destinatários**: Equipe técnica (se aplicável)

**Mensagem**:
```
Assunto: GMUD-020B - Restauração midPoint 4.8.8 (05/01/2026)

Será realizada correção do ambiente midPoint conforme detalhes:

Data/Hora: 05/01/2026 às [HORÁRIO] BRT
Duração Estimada: 22 minutos
Impacto: Indisponibilidade temporária do midPoint

Sistema Afetado:
- midPoint 4.8.8 (http://xxx.xxx.xxx.xxx:8080)

Sistemas NÃO Afetados:
- OrangeHRM (http://xxx.xxx.xxx.xxx:8081)
- Active Directory
- PKI

Ações:
✅ Backups validados
✅ Rollback plan com RTO < 10 minutos
✅ Comunicação de conclusão será enviada ao término

Contexto: Correção da Fase 3 da GMUD-020 (downgrade 4.10 → 4.8.8)
```

## 9.2 Notificação Pós-GMUD (T+0)

**Mensagem de Sucesso**:
```
Assunto: ✅ GMUD-020B CONCLUÍDA - midPoint 4.8.8 Operacional

GMUD-020B executada com sucesso em [XX] minutos.

Sistema Disponível:
✅ midPoint 4.8.8: http://xxx.xxx.xxx.xxx:8080/midpoint/
   - Login: administrator / 5ecr3t
   - Banco: 130+ tabelas Native Sqale (integridade confirmada)

Melhorias Implementadas:
- Base de dados corrigida (Native Sqale)
- Imagem Standard (Debian) para maior robustez

Próximos Passos:
- Monitoramento 24h
- Configuração de conectores (OrangeHRM, AD)
- Relatório detalhado: REL-GMUD-020B.md
```

**Mensagem de Rollback (se necessário)**:
```
Assunto: ⚠️ GMUD-020B SUSPENSA - Rollback Executado

GMUD-020B foi suspensa devido a [razão].

Ação Tomada:
✅ Rollback completo executado via Checkpoint Hyper-V
✅ Ambiente restaurado ao estado pré-GMUD
✅ Nenhuma perda de dados

Status Atual:
- midPoint: Estado anterior (corrompido - aguardando nova estratégia)
- OrangeHRM: Operacional (não afetado)

Próxima Ação:
- Análise de root cause detalhada
- Reprogramação da GMUD-020B ou criação de GMUD-020C
```

================================================================================
10. LIÇÕES APRENDIDAS (Aplicadas e Esperadas)
================================================================================

## 10.1 Lições Aplicadas da GMUD-020

| ID | Lição | Aplicação na GMUD-020B |
|----|-------|------------------------|
| L1 | Dependência de Recursos Externos | Troca Alpine→Standard elimina dependência de GitHub/caminhos externos |
| L2 | Intervenção Manual vs. Automação | Remoção total do volume + auto-init (zero SQL manual) |
| L3 | Validação Incremental | Validações obrigatórias após cada passo (1-5) |
| L4 | Diagnóstico Contextual | Histórico GMUD-020 considerado no design (72 tabelas Generic) |
| L5 | Circuit Breaker | Limite de 20 min por passo definido explicitamente |

## 10.2 Novas Lições Esperadas (Pós-GMUD-020B)

**L6: Clean Slate vs. Repair**
- Contexto: Remoção completa de volume vs. tentativa de reparo
- Aprendizado esperado: Quando vale a pena "reconstruir do zero"
- Aplicação futura: Template para outras migrações de banco

**L7: Imagem Alpine vs. Standard**
- Contexto: Escolha de base de imagem Docker afeta robustez
- Aprendizado esperado: Trade-off tamanho vs. compatibilidade
- Aplicação futura: Política de seleção de imagens para lab

**L8: Validação de Integridade de Schema**
- Contexto: Contagem de tabelas como métrica de saúde
- Aprendizado esperado: Thresholds esperados por versão (4.8 = 130+ tabelas)
- Aplicação futura: Script automatizado de health check

================================================================================
11. DOCUMENTAÇÃO E EVIDÊNCIAS
================================================================================

## 11.1 Artefatos Gerados Durante a GMUD

```
/backup/GMUD-020B/
├── docker-compose.yml.bak_20260105     # Backup de configuração
├── execution_log_20260105.txt          # Log completo de execução
├── validation_results.txt              # Saída da Matriz de Validação
└── screenshots/
    ├── 01_volume_removed.png           # Evidência Passo 1
    ├── 02_docker_compose_edited.png    # Evidência Passo 2
    ├── 03_midpoint_started_log.png     # Evidência Passo 3
    ├── 04_db_table_count.png           # Evidência Passo 4
    └── 05_login_success.png            # Evidência Passo 5
```

## 11.2 Checkpoint Hyper-V

**Nome**: IGA-P-01_Checkpoint_GMUD-020 (existente)
**Uso**: Rollback de emergência
**Retenção**: 7 dias (até 12/01/2026)

**Novo Checkpoint (Pós-GMUD-020B):**
- Nome sugerido: IGA-P-01_Checkpoint_POST-GMUD-020B
- Quando criar: Após validação bem-sucedida (Seção 5)
- Comando PowerShell:
```powershell
Checkpoint-VM -Name "IGA-P-01" -SnapshotName "IGA-P-01_Checkpoint_POST-GMUD-020B"
```

## 11.3 Relatório Pós-GMUD (Template)

Documento a ser criado: `REL-GMUD-020B.md`

**Estrutura Obrigatória:**
1. Sumário Executivo
   - Status final: SUCESSO / SUCESSO PARCIAL / ROLLBACK
   - Tempo de execução real vs. planejado
   - Desvios e incidentes

2. Execução Passo a Passo
   - Timestamp de início/término de cada passo
   - Validações executadas
   - Screenshots anexados

3. Matriz de Validação Preenchida
   - Todos os 10 testes com status (✅ ou ❌)
   - Evidências de cada teste

4. Lições Aprendidas Consolidadas
   - Lições aplicadas (L1-L5)
   - Novas lições identificadas (L6-L8)
   - Recomendações para GMUDs futuras

5. Métricas Finais
   - KPIs atingidos (Seção 8.3)
   - Tempo de indisponibilidade real
   - Performance pós-GMUD

6. Assinaturas e Aprovações
   - Executor técnico
   - Aprovador de mudanças

================================================================================
12. APROVAÇÕES E ASSINATURAS
================================================================================

## 12.1 Elaboração e Revisão

**Elaborado por:**
Nome: Gemini Deep-Dive (CTO/Arch)
Data: 04/01/2026 21:30 BRT
Versão: 1.0 (Clean Slate Strategy)

**Revisado por:**
Nome: Paulo Feitosa (Owner/CISO)
Data: ___/___/______
Assinatura: _________________________________

**Observações de Revisão:**
_________________________________________________________________
_________________________________________________________________

## 12.2 Aprovação de Mudança

**Change Manager (Ambiente Lab):**
Nome: Paulo Feitosa
Data de Aprovação: ___/___/______
Assinatura: _________________________________

**Decisão**: □ APROVADA   □ REJEITADA   □ ADIADA

**Justificativa (se rejeitada/adiada):**
_________________________________________________________________
_________________________________________________________________

## 12.3 Execução

**Executor Técnico:**
Nome: Paulo Feitosa (IGA-P-01)
Data de Execução: ___/___/______
Horário de Início: ___:___ BRT
Horário de Término: ___:___ BRT

**Resultado Final**: □ SUCESSO   □ SUCESSO PARCIAL   □ ROLLBACK

**Observações de Execução:**
_________________________________________________________________
_________________________________________________________________

**Desvios do Planejado:**
_________________________________________________________________
_________________________________________________________________

**Incidentes Registrados:**
_________________________________________________________________
_________________________________________________________________

================================================================================
13. PRÓXIMOS PASSOS (PÓS-GMUD-020B)
================================================================================

## 13.1 Imediato (Próximas 24h)

□ Monitoramento contínuo de logs (docker logs -f midpoint-server)
□ Validação de estabilidade (container não reinicia espontaneamente)
□ Elaboração do REL-GMUD-020B.md
□ Criar novo checkpoint Hyper-V (POST-GMUD-020B)
□ Comunicação de conclusão aos stakeholders

## 13.2 Curto Prazo (1 semana)

□ Excluir checkpoint antigo (GMUD-020) se não for mais necessário
□ Atualizar documentação de ambiente (diagrama de topologia)
□ Arquivar logs e evidências em storage secundário
□ Validar performance do midPoint sob carga simulada

## 13.3 Médio Prazo (1 mês)

□ GMUD-021: Configuração de conector OrangeHRM no midPoint
□ GMUD-022: Integração midPoint ↔ Active Directory
□ Implementação de massa de dados de teste (7 personas brasileiras)
□ Configuração de políticas de provisionamento automático

## 13.4 Longo Prazo (Roadmap IGA)

□ Implementação de workflows de aprovação (Role Assignment)
□ Auditoria de acessos (compliance ISO 27001 A.9.2.4)
□ Integração com PKI (certificados digitais via midPoint)
□ Monitoramento com Prometheus/Grafana

================================================================================
14. REFERÊNCIAS E ANEXOS
================================================================================

## 14.1 Documentos Relacionados

- **REL-GMUD-020.md**: Relatório de Implementação Parcial (Fases 1-2)
- **Manifesto Fiqueok v2.0.pdf**: Estratégia GRC e Arquitetura
- **POP-001**: Procedimento Operacional de Gestão de Mudanças

## 14.2 Referências Técnicas

- Evolveum midPoint 4.8 Documentation: https://docs.evolveum.com/midpoint/4.8/
- Native Repository (Sqale): https://docs.evolveum.com/midpoint/reference/repository/native-postgresql/
- Docker Compose Best Practices: https://docs.docker.com/compose/production/
- ISO/IEC 27001:2013 - Controles A.12 (Segurança nas Operações)

## 14.3 Glossário

- **Clean Slate**: Estratégia de remoção completa e reconstrução do zero
- **Native Sqale**: Repositório nativo do midPoint 4.x baseado em SQL
- **Generic Repository**: Repositório legado do midPoint 3.x (72 tabelas)
- **RTO**: Recovery Time Objective (tempo máximo de recuperação)
- **RPO**: Recovery Point Objective (ponto máximo de perda de dados)

## 14.4 Contatos de Emergência

**Responsável Técnico:**
Nome: Paulo Feitosa
Email: paulo@fiqueok.com.br
Telefone: [REDACTED]

**Suporte Hyper-V (Host Físico):**
Acesso: RDP xxx.xxx.xxx.xxx
Credenciais: [Armazenadas em Bitwarden]

**Escalação Externa (se necessário):**
- Evolveum Community: https://evolveum.com/services/professional-support/
- Fórum midPoint: https://lists.evolveum.com/

================================================================================
FIM DA GMUD-020B - RESTAURAÇÃO MIDPOINT 4.8.8 LTS (CLEAN SLATE)
================================================================================

**Status**: 🟡 AGUARDANDO APROVAÇÃO
**Próxima Ação**: Revisão e assinatura por Paulo Feitosa
**Data Prevista de Execução**: 05/01/2026
**Tempo Estimado Total**: 22 minutos
**Janela de Execução**: A definir pelo executor

================================================================================

