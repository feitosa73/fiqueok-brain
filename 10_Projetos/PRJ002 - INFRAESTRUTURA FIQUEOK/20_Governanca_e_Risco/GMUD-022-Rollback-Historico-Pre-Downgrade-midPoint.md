# GMUD-022 - Rollback Histórico para Ponto Pré-Downgrade do midPoint

**Status:** 📋 Planejada  
**Versão:** 1.0  
**Data de Criação:** 06/01/2026 17:32  
**Responsável:** Perplexity Pro (GRC Lead) + ChatGPT (Systems Architect)  
**Aprovador:** Paulo Feitosa (Owner)

---

## 1. Identificação da Mudança

| Campo | Valor |
|-------|-------|
| **ID da GMUD** | GMUD-022 |
| **Título** | Rollback Histórico para Ponto Pré-Downgrade do midPoint visando Recuperação de Integrações Funcionais |
| **Categoria** | Mudança Corretiva / Recuperação de Baseline Funcional |
| **Tipo** | Rollback Controlado |
| **Prioridade** | Alta |
| **Ambiente** | Laboratório - IGA-P-01 (xxx.xxx.xxx.xxx) - Living Lab IAM |
| **Janela de Execução** | A definir (estimativa: 1h) |
| **Impacto Estimado** | Nenhum (rollback para estado funcional conhecido) |

---

## 2. Contexto e Justificativa

### 2.1. Histórico de GMUDs Anteriores

Após múltiplas GMUDs envolvendo sanitização, downgrade e mudanças estruturais no stack do midPoint, foi identificado que o **ambiente funcional mais próximo do objetivo do Living Lab existia ANTES da execução do downgrade para a versão 4.8.8**.

**Cronologia Relevante:**

| Data | GMUD | Ação Principal | Resultado |
|------|------|----------------|-----------|
| 03/01/2026 | GMUD-018 | midPoint funcional com integrações OrangeHRM + AD | ✅ Funcional (com limitação de conectores) |
| 04-05/01/2026 | GMUD-019 | Downgrade midPoint 4.10 → 4.8.8 | ⚠️ Perda de Resources e Tasks configurados |
| 06/01/2026 | GMUD-020A | Deploy midPoint com H2 Embedded | ❌ Falha (incompatibilidade H2) |
| 06/01/2026 | GMUD-021A | Sanitização total + correção baseline | ❌ Falha + Rollback (perda de dados OrangeHRM) |

### 2.2. Análise do Estado Funcional Anterior

Análises posteriores demonstraram que **antes do downgrade (GMUD-019)**:

- ✅ O midPoint **já havia sido integrado ao OrangeHRM e ao Active Directory**
- ✅ **Resources e Tasks já existiam** e estavam configurados
- ✅ A infraestrutura Docker estava estável e operacional
- ✅ Usuários de teste (`paulo.lima`, `carlos.silva`) haviam sido importados com sucesso
- ⚠️ **A única limitação conhecida:** Ausência de conectores JAR necessários à execução dos fluxos de reconciliação

### 2.3. Impacto das Mudanças Posteriores

Mudanças posteriores (downgrade, sanitização ampla e ajustes de stack) **introduziram complexidade adicional e perda de referência funcional**:

- ❌ Perda de configuração de Resources (OrangeHRM, Active Directory)
- ❌ Perda de Tasks de importação/reconciliação
- ❌ Perda de dados de usuários de teste
- ❌ Introdução de incompatibilidades técnicas (H2, Alpine, permissões)
- ❌ Custo cognitivo elevado com troubleshooting de infraestrutura

### 2.4. Decisão Estratégica

Diante desse cenário, optou-se por uma **estratégia de rollback histórico controlado**, com o objetivo de:

1. **Recuperar um estado funcional avançado** (integrações configuradas)
2. **Corrigir apenas o elo faltante** (instalação de conectores JAR)
3. **Evitar reconstrução manual** de Resources, Tasks e configurações

**Princípio Orientador:**
> "Rollback histórico pode ser mais eficiente que reconstrução. Recuperar um estado funcional conhecido e corrigir um problema pontual é mais sustentável do que reconstruir do zero."

---

## 3. Objetivo da Mudança

Restaurar o ambiente para um **ponto de verificação anterior ao downgrade do midPoint**, no qual:

1. ✅ A infraestrutura estava funcional (Docker, redes, volumes)
2. ✅ O midPoint possuía **Resources e Tasks configurados** (OrangeHRM, Active Directory)
3. ✅ Existia **integração lógica** com sistemas autoritativos (OrangeHRM, AD)
4. ⚠️ A única limitação conhecida era a **ausência de conectores** necessários à execução dos fluxos

**Objetivo Final:**
Obter um ambiente midPoint **100% funcional** com integrações operacionais, corrigindo apenas a dependência de conectores (se aplicável).

---

## 4. Escopo da Mudança

### 4.1. Incluído no Escopo

| Item | Descrição |
|------|-----------|
| **Rollback da VM** | Restauração para snapshot histórico selecionado |
| **Validação de Containers** | Verificação de serviços Docker ativos (midPoint, PostgreSQL, OrangeHRM, etc.) |
| **Validação de GUI** | Acesso à interface web do midPoint (porta 8080) |
| **Identificação de Resources** | Verificação de existência de Resource OrangeHRM e Active Directory |
| **Identificação de Tasks** | Verificação de Tasks de import/export/reconciliação |
| **Correção Pontual** | Instalação de conectores JAR (apenas se necessário) |
| **Validação de Usuários** | Verificação de existência de usuários de teste (`paulo.lima`, `carlos.silva`) |

### 4.2. Explicitamente Fora do Escopo

| Item | Justificativa |
|------|---------------|
| **Reinstalação do midPoint** | Objetivo é recuperar estado funcional, não reconstruir |
| **Sanitização de Bancos de Dados** | Estado histórico deve ser preservado integralmente |
| **Alteração de Versões** | Não alterar versão de imagem ou banco de dados |
| **Recriação Manual de Resources** | Resources devem existir no snapshot; recriação indica snapshot errado |
| **Recriação Manual de Tasks** | Tasks devem existir no snapshot; recriação indica snapshot errado |
| **Migração de Dados** | Dados históricos devem ser preservados |
| **Mudanças Estruturais no Stack** | Não alterar docker-compose.yml, redes ou volumes |

---

## 5. Snapshot Alvo para Rollback

### 5.1. Snapshot Primário (Prioritário)

**Nome:** `PRE-GMUD-019v2-ObjectTemplate`

**Características Esperadas:**
- Data de criação: Anterior ao downgrade (GMUD-019)
- midPoint versão: Provavelmente 4.10 (anterior ao downgrade)
- Estado esperado: Resources configurados, Tasks existentes, integrações funcionais
- Banco de dados: PostgreSQL (não H2)

**Justificativa:**
Este snapshot foi criado **antes do downgrade para 4.8.8**, momento em que as integrações já estavam configuradas e funcionais.

### 5.2. Snapshot Alternativo (Fallback)

**Nome:** `LAB-midPoint-OrangeHRM_PRE-LIMPEZA_2026-01-03`

**Características Esperadas:**
- Data de criação: 03/01/2026 (antes das sanitizações)
- Estado esperado: Ambiente funcional pré-limpeza
- Justificativa: Checkpoint anterior às sanitizações destrutivas

**Critério de Escolha:**
Usar snapshot alternativo **somente se** o snapshot primário não contiver o estado funcional esperado (ausência de Resources/Tasks).

### 5.3. Tabela de Decisão de Snapshot

| Condição | Snapshot a Usar |
|----------|-----------------|
| Snapshot primário contém Resources + Tasks | ✅ `PRE-GMUD-019v2-ObjectTemplate` |
| Snapshot primário não contém Resources/Tasks | ➡️ `LAB-midPoint-OrangeHRM_PRE-LIMPEZA_2026-01-03` |
| Ambos os snapshots não contêm estado funcional | ❌ Abortar GMUD-022 e reavaliar estratégia |

---

## 6. Plano de Execução

### 6.1. FASE 1 - Rollback da VM

**Duração Estimada:** 10-15 minutos  
**Impacto:** VM ficará indisponível durante restauração

**Procedimento:**

1. **Criar snapshot do estado atual** (segurança)
   ```bash
   # No Hyper-V Manager
   Nome: "PRE-GMUD-022-Estado-Atual-20260107"
   Descrição: "Checkpoint de segurança antes do rollback histórico"
   ```

2. **Restaurar snapshot primário**
   ```bash
   # No Hyper-V Manager
   Snapshot: "PRE-GMUD-019v2-ObjectTemplate"
   Ação: Aplicar (Apply)
   ```

3. **Iniciar VM**
   ```bash
   # Aguardar boot completo do Ubuntu Server
   # Não executar nenhuma sanitização ou alteração imediata
   ```

4. **Validar conectividade SSH**
   ```bash
   ssh paulo@xxx.xxx.xxx.xxx
   # Esperado: Login bem-sucedido
   ```

**Critério de Sucesso Fase 1:**
- ✅ VM restaurada e operacional
- ✅ SSH acessível
- ✅ Nenhuma modificação realizada ainda

---

### 6.2. FASE 2 - Verificação Pós-Rollback (Read-Only)

**Duração Estimada:** 20-30 minutos  
**Modo:** Somente leitura (nenhuma modificação permitida)

**Objetivo:** Validar se o snapshot restaurado contém o estado funcional esperado.

#### 6.2.1. Validação de Containers Docker

```bash
# 1. Listar containers ativos
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

# Esperado: Containers do midPoint, PostgreSQL, OrangeHRM (se aplicável)
# Registrar output completo em:
# /opt/stack-iga/GMUD-022-validacao-containers.txt

# 2. Validar logs do midPoint (sem modificar)
docker logs midpoint --tail 100 | grep -E "started|initialized|repository"

# Esperado: Mensagens de inicialização bem-sucedida
```

#### 6.2.2. Validação da GUI do midPoint

```bash
# 1. Testar acesso à GUI (do host Windows)
# URL: http://xxx.xxx.xxx.xxx:8080/midpoint/

# 2. Realizar login
# Usuário: administrator
# Senha: [recuperar dos logs ou usar senha conhecida do snapshot]

# 3. Navegar para Menu → Resources
# Esperado: Listar Resources configurados (OrangeHRM, Active Directory)

# 4. Navegar para Menu → Tasks
# Esperado: Listar Tasks existentes (Import, Reconciliation)
```

#### 6.2.3. Checklist de Validação (Preencher Durante Execução)

**Infraestrutura:**
- [ ] Container `midpoint` está ativo (status: Up)
- [ ] Container de banco de dados está ativo (PostgreSQL ou H2)
- [ ] Porta 8080 está acessível
- [ ] GUI do midPoint carrega corretamente
- [ ] Login no midPoint funciona

**Resources:**
- [ ] Resource "OrangeHRM" existe
- [ ] Resource "Active Directory" existe
- [ ] Resources estão com status "Up" ou similar

**Tasks:**
- [ ] Existem Tasks de importação (Import)
- [ ] Existem Tasks de reconciliação (Reconciliation)
- [ ] Tasks têm histórico de execução

**Usuários:**
- [ ] Usuário `paulo.lima` existe no midPoint
- [ ] Usuário `carlos.silva` existe no midPoint
- [ ] Usuários têm atributos populados (email, department, etc.)

**Critério de Sucesso Fase 2:**
- ✅ Todos os itens da checklist preenchidos positivamente
- ✅ State funcional confirmado
- ✅ Nenhuma modificação realizada

**Critério de Abort (Ir para Snapshot Alternativo):**
- ❌ Resources não existem
- ❌ Tasks não existem
- ❌ GUI não carrega ou apresenta erros críticos

---

### 6.3. FASE 3 - Correção Pontual (Se Necessária)

**Executar SOMENTE SE:**
- ✅ Resources e Tasks existem
- ✅ GUI está funcional
- ❌ Fluxos falham por ausência de conectores

**Ações Permitidas:**

#### 6.3.1. Instalação de Conectores JAR

```bash
# 1. Identificar conectores ausentes nos logs
docker logs midpoint | grep -i "connector.*not found"

# Exemplo de erro esperado:
# "Connector com.evolveum.polygon.connector.csv.CsvConnector not found"

# 2. Download de conectores necessários
# Ref: https://docs.evolveum.com/connectors/

# Exemplo para Connector CSV/DatabaseTable:
wget https://nexus.evolveum.<REDACTED_SECRET>um/polygon/connector-csv/1.4.7.0/connector-csv-1.4.7.0.jar

# 3. Copiar conectores para diretório de conectores do midPoint
docker cp connector-csv-1.4.7.0.jar midpoint:/opt/midpoint/var/icf-connectors/

# 4. Validar presença do conector
docker exec midpoint ls -lh /opt/midpoint/var/icf-connectors/
```

#### 6.3.2. Reinicialização Controlada do midPoint

```bash
# 1. Reiniciar container (para carregar novos conectores)
docker restart midpoint

# 2. Aguardar inicialização completa
sleep 60

# 3. Validar logs de inicialização
docker logs midpoint --tail 100 | grep -i "connector"

# Esperado: Mensagens de carregamento dos conectores instalados
```

#### 6.3.3. Reexecução de Tasks Existentes

```bash
# 1. Acessar GUI do midPoint
# URL: http://xxx.xxx.xxx.xxx:8080/midpoint/

# 2. Navegar para Menu → Server Tasks

# 3. Selecionar Task de importação (ex: "Import OrangeHRM Users")

# 4. Clicar em "Run Now"

# 5. Monitorar execução
# Esperado: Task conclui com sucesso, usuários são importados

# 6. Validar em Menu → Users
# Esperado: Usuários do OrangeHRM presentes no midPoint
```

**Critério de Sucesso Fase 3:**
- ✅ Conectores instalados e carregados
- ✅ Tasks executam sem erro de conector
- ✅ Usuários são importados/reconciliados com sucesso
- ✅ **Nenhum Resource ou Task foi recriado manualmente**

---

## 7. Critérios de Sucesso (Gerais)

| # | Critério | Validação |
|---|----------|-----------|
| 1 | midPoint operacional e acessível via GUI | ✅ Login bem-sucedido na porta 8080 |
| 2 | Resources OrangeHRM e AD visíveis | ✅ Menu → Resources lista ambos |
| 3 | Tasks existentes executam sem erro de conector | ✅ "Run Now" conclui com sucesso |
| 4 | Usuários são importados/reconciliados com sucesso | ✅ Usuários de teste presentes em Users |
| 5 | Nenhuma reinstalação ou recriação estrutural realizada | ✅ Apenas instalação de conectores (se necessário) |
| 6 | Ambiente reflete estado funcional pré-downgrade | ✅ Versão midPoint, banco de dados e configurações preservadas |

---

## 8. Riscos e Mitigações

| ID | Risco | Probabilidade | Impacto | Mitigação |
|----|-------|---------------|---------|-----------|
| R01 | Snapshot primário não contém estado funcional esperado | Média | Alto | Usar snapshot alternativo (fallback) |
| R02 | Ambiente inconsistente após rollback (containers não sobem) | Baixa | Crítico | Abort da GMUD e retorno ao snapshot atual |
| R03 | Dependência de conectores ausentes persiste | Alta | Médio | Correção pontual documentada (Fase 3) |
| R04 | Perda de rastreabilidade de mudanças históricas | Baixa | Médio | Registro completo das validações em logs |
| R05 | Versão do midPoint no snapshot incompatível com conectores atuais | Baixa | Alto | Usar conectores compatíveis com versão identificada |
| R06 | Credenciais de administrador do midPoint desconhecidas | Média | Médio | Recuperar senha dos logs do container ou redefinir via CLI |

---

## 9. Plano de Rollback da GMUD-022

### 9.1. Critérios de Ativação do Rollback

O rollback da GMUD-022 deve ser executado se:

1. ❌ Snapshot restaurado não contém Resources/Tasks configurados
2. ❌ Ambiente inconsistente após rollback (containers não inicializam)
3. ❌ GUI do midPoint não carrega ou apresenta erros críticos
4. ❌ Ambos os snapshots (primário e alternativo) não atendem aos critérios

### 9.2. Procedimento de Rollback

```bash
# <REDACTED_SECRET>===========================
# ROLLBACK DA GMUD-022
# Ação: Retornar ao snapshot atual estável (pós GMUD-021A)
# <REDACTED_SECRET>===========================

# 1. No Hyper-V Manager, restaurar snapshot de segurança
Snapshot: "PRE-GMUD-022-Estado-Atual-20260107"
Ação: Aplicar (Apply)

# 2. Iniciar VM
# Aguardar boot completo

# 3. Validar estado restaurado
ssh paulo@xxx.xxx.xxx.xxx
docker ps
# Esperado: Ambiente vazio (pós-rollback GMUD-021A)

# 4. Documentar rollback
cat <<EOF > /opt/stack-iga/GMUD-022-rollback.log
=====================================
ROLLBACK GMUD-022 - EXECUTADO
Data: $(date)
Motivo: Snapshot histórico não continha estado funcional esperado
Snapshot restaurado: PRE-GMUD-022-Estado-Atual-20260107
Status: Ambiente retornou ao estado pós GMUD-021A
Próxima ação: Reavaliar reconstrução controlada do ambiente
=====================================
EOF
```

### 9.3. Decisão Pós-Rollback

Se o rollback for executado:

1. ❌ **Encerrar GMUD-022 sem sucesso**
2. 📋 **Planejar GMUD-023:** Reconstrução controlada do ambiente com PostgreSQL 15 (abordagem original)
3. 📚 **Documentar lições aprendidas:** Snapshots históricos não continham estado esperado

---

## 10. Lições Aprendidas (Prévia)

### 10.1. Princípios Validados (Se GMUD-022 For Bem-Sucedida)

1. **Rollback Histórico como Estratégia Válida:**
   > "Rollback histórico pode ser mais eficiente que reconstrução. Recuperar um estado funcional conhecido e corrigir um problema pontual é mais sustentável do que reconstruir do zero."

2. **Conectores como Dependências Críticas:**
   > "Conectores são dependências críticas e devem ser tratados como artefatos de primeira classe. Sua ausência ou incompatibilidade pode inviabilizar integrações funcionais."

3. **Sanitização Sem Delimitação de Escopo:**
   > "Sanitização sem delimitação de escopo gera risco desnecessário. Mudanças destrutivas devem ter matriz de impacto explícita."

4. **Documentação de Checkpoints:**
   > "Documentação de checkpoints (snapshots) é essencial para decisões futuras. Snapshots sem metadados sobre seu conteúdo perdem valor de recuperação."

### 10.2. Aprendizados Potenciais (Se GMUD-022 Falhar)

1. **Limitação de Snapshots Históricos:**
   - Snapshots antigos podem não refletir o estado funcional esperado
   - Metadados insuficientes dificultam decisão de rollback

2. **Necessidade de Reconstrução Controlada:**
   - Se snapshots históricos não são viáveis, reconstrução é inevitável
   - Reconstrução deve ser documentada como GMUD independente

3. **Importância de Baselines Documentadas:**
   - Baselines funcionais devem ser documentadas detalhadamente
   - Inventário de Resources, Tasks e conectores deve ser mantido atualizado

---

## 11. Anexo A - Credenciais do midPoint

### A.1. Recuperação de Senha do Administrator

**Cenário 1: Senha definida explicitamente no snapshot**

Se o snapshot contiver variável de ambiente customizada:
```bash
docker inspect midpoint | grep MP_ADMIN_INITIAL_PASSWORD
# Retornará a senha configurada
```

**Cenário 2: Senha auto-gerada pelo midPoint**

A partir da versão 4.8.1, o midPoint gera automaticamente uma senha aleatória se não for definida explicitamente:

```bash
# Buscar senha nos logs do container
docker logs midpoint | grep "Administrator initial password"

# Exemplo de output:
# Administrator initial password: "R@nd0m P@ssw0rd!"
```

**Importante:** A senha pode conter espaços e virá entre aspas duplas [web:26].

**Cenário 3: Senha desconhecida (última opção)**

Se a senha não for recuperável, pode ser redefinida via CLI do midPoint:
```bash
docker exec -it midpoint bash
cd /opt/midpoint/bin
./ninja.sh set-password administrator
# Seguir prompt para definir nova senha
```

### A.2. Política de Senha Padrão (midPoint 4.8.x)

**Requisitos mínimos:**
- ✅ Mínimo 8 caracteres
- ✅ Pelo menos 1 letra maiúscula
- ✅ Pelo menos 1 letra minúscula
- ✅ Pelo menos 1 número
- ❌ NÃO pode conter username, nome ou sobrenome

---

## 12. Anexo B - Conectores Comuns do midPoint

### B.1. Conectores para Integrações Típicas

| Sistema Alvo | Conector | Versão Recomendada | Download |
|--------------|----------|-------------------|----------|
| **CSV/TSV** | connector-csv | 1.4.7.0 | [Nexus](https://nexus.evolveum.<REDACTED_SECRET>um/polygon/connector-csv/) |
| **Database Table** | connector-databasetable | 1.5.5.0 | [Nexus](https://nexus.evolveum.<REDACTED_SECRET>um/polygon/connector-databasetable/) |
| **LDAP/AD** | connector-ldap | 3.7 | Incluído no midPoint 4.8.x (bundled) |
| **REST** | connector-rest | 1.5.0.0 | [Nexus](https://nexus.evolveum.<REDACTED_SECRET>um/polygon/connector-rest/) |
| **ScriptedSQL** | connector-scriptedsql | 1.5.0.0 | [Nexus](https://nexus.evolveum.<REDACTED_SECRET>um/polygon/connector-scriptedsql/) |

**Nota:** Conectores LDAP geralmente já vêm incluídos (bundled) nas imagens oficiais do midPoint.

### B.2. Instalação Manual de Conectores

```bash
# 1. Download do conector
wget https://nexus.evolveum.<REDACTED_SECRET>um/polygon/connector-csv/1.4.7.0/connector-csv-1.4.7.0.jar

# 2. Copiar para diretório de conectores do midPoint
docker cp connector-csv-1.4.7.0.jar midpoint:/opt/midpoint/var/icf-connectors/

# 3. Validar presença
docker exec midpoint ls -lh /opt/midpoint/var/icf-connectors/

# 4. Reiniciar midPoint para carregar conector
docker restart midpoint

# 5. Validar nos logs
docker logs midpoint --tail 100 | grep -i "connector.*csv"
```

---

## 13. Matriz de Responsabilidades (RACI)

| Atividade | Paulo (Owner) | Perplexity (GRC) | ChatGPT (Architect) | Gemini |
|-----------|---------------|------------------|---------------------|--------|
| Aprovação da GMUD | **A** | R | C | I |
| Fase 1: Rollback da VM | **R/A** | I | C | I |
| Fase 2: Validação Read-Only | **R/A** | C | **R** | I |
| Fase 3: Correção Pontual | **R/A** | C | **R** | I |
| Análise de risco | **A** | **R** | C | I |
| Decisão de rollback da GMUD | **A** | R | C | I |
| Post-Mortem (se aplicável) | **A** | **R** | **R** | C |

**Legenda:** R = Responsible (Executor), A = Accountable (Aprovador), C = Consulted (Consultado), I = Informed (Informado)

---

## 14. Aprovações

| Papel | Nome | Data | Status |
|-------|------|------|--------|
| Executor Técnico | ChatGPT (Systems Architect) | 06/01/2026 | Planejado |
| Responsável GRC | Perplexity Pro (GRC Lead) | 06/01/2026 | Planejado |
| Consultor Deep-Dive | Gemini (Deep-Dive Consultant) | 06/01/2026 | Informado |
| Aprovador Final | Paulo Feitosa (Owner) | - | **Pendente** |

---

## 15. Controle de Versão

| Versão | Data | Autor | Mudanças Principais |
|--------|------|-------|---------------------|
| 1.0 | 06/01/2026 17:32 | Perplexity + ChatGPT | Criação da GMUD-022 - Rollback Histórico Controlado |

---

## 16. Documentos Relacionados

- **GMUD Anterior:** GMUD-021A - Rollback e Encerramento Sem Sucesso (H2 Embedded)
- **GMUD Relacionada:** GMUD-019 - Downgrade midPoint 4.10 → 4.8.8
- **GMUD Alternativa (Se Falhar):** GMUD-023 - Reconstrução Controlada com PostgreSQL 15
- **Manifesto de Estratégia Fiqueok v2.0**
- **ADR-002:** Redistribuição de Responsabilidades de IA

---

## 17. Frase de Encerramento

> "Esta GMUD representa uma mudança de paradigma: ao invés de reconstruir do zero, recuperamos um estado funcional conhecido e corrigimos apenas o elo faltante. Se bem-sucedida, valida que rollback histórico pode ser mais eficiente e sustentável do que reconstrução completa."

**Status Atual:** 📋 **GMUD-022 PLANEJADA - AGUARDANDO APROVAÇÃO PARA EXECUÇÃO**

---

**Documento mantido por:** Perplexity Pro (GRC Lead)  
**Executor Técnico:** ChatGPT (Systems Architect)  
**Repositório:** Obsidian Vault - `FiqueokBrain/10Projetos/PRJ001-LABORATORIO/20Governanca/`  
**Data de Criação:** 06/01/2026 17:32 (Hora de Brasília)

---

**🔑 Estratégia Central:** Recuperar estado funcional pré-downgrade e corrigir apenas conectores ausentes, evitando reconstrução completa de integrações.

