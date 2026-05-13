# ==============================================================================
# REL-GMUD-005 — RELATÓRIO DE EXECUÇÃO DA MUDANÇA
# ==============================================================================
# Projeto: PRJ003 - IGA Greenfield Reference Architecture
# GMUD: GMUD-005 v1.3 - Deploy Inicial midPoint + PostgreSQL
# Data de Execução: 17/01/2026
# Responsável: Paulo Feitosa
# Status: ENCERRADA SEM SUCESSO - ROLLBACK APLICADO
# ==============================================================================

## 1. IDENTIFICAÇÃO DA GMUD

| **Campo** | **Informação** |
|-----------|----------------|
| **GMUD** | GMUD-005 v1.3 |
| **Tipo** | Técnica - Infraestrutura |
| **Categoria** | Deploy Inicial (Cold Start) |
| **Projeto** | PRJ003 - IGA Greenfield Reference Architecture |
| **Contexto** | Living Lab Fiqueok 2.0 |
| **Owner** | Paulo Feitosa |
| **Data Planejada** | 17/01/2026 |
| **Data de Execução** | 17/01/2026 (15:00 - 18:30 BRT) |
| **Status Final** | ❌ Encerrada sem Sucesso - Rollback Aplicado |

---

## 2. OBJETIVO DA GMUD

Realizar o deploy inicial do ambiente midPoint + PostgreSQL no PRJ003, implementando:
- Containers Docker para midPoint 4.8 e PostgreSQL 16
- Persistência via volumes dedicados em `/srv/prj003`
- Proteção de credenciais via variáveis de ambiente
- Validação de inicialização e acesso à interface administrativa

**Critério de Sucesso:** Acesso funcional ao midPoint via interface web com usuário `administrator`.

---

## 3. ESCOPO EXECUTADO

### 3.1. Atividades Planejadas vs. Executadas

| **Atividade** | **Status** | **Observação** |
|---------------|------------|----------------|
| Carregar variáveis do .env | ✅ Concluída | Credenciais carregadas corretamente |
| Criar estrutura de diretórios | ✅ Concluída | `/srv/prj003` criado com permissões adequadas |
| Gerar docker-compose.yml | ✅ Concluída | Arquivo enviado para VM com sucesso |
| Inicializar containers | ✅ Concluída | Containers `postgres` e `midpoint` em execução |
| Validar acesso web | ❌ Falhou | Falha de autenticação com credenciais padrão |
| Validar persistência | ⏸️ Não executada | Interrompida devido à falha de login |

### 3.2. Fora do Escopo (Confirmado)

- ✅ Nenhuma integração funcional realizada
- ✅ Nenhuma decisão semântica tomada durante execução
- ✅ Nenhuma alteração nos Canvases CAN-ID
- ✅ Conformidade com DEC-ID-001 mantida

---

## 4. CRONOLOGIA DA EXECUÇÃO

### Timeline de Eventos

| **Horário** | **Evento** | **Status** |
|-------------|------------|------------|
| 15:00 | Início da execução do script GMUD-005 v1.3 | ✅ |
| 15:03 | Estrutura de diretórios criada na VM | ✅ |
| 15:05 | docker-compose.yml enviado para VM | ✅ |
| 15:07 | `docker compose up -d` executado | ✅ |
| 15:09 | Containers `postgres` e `midpoint` iniciados | ✅ |
| 15:12 | Acompanhamento de logs via `docker logs -f midpoint` | ✅ |
| 15:18 | Mensagem "Created User:administrator" identificada nos logs | ✅ |
| 15:20 | Acesso à interface web `http://xxx.xxx.xxx.xxx:8080` | ✅ |
| 15:22 | **INCIDENTE:** Falha de autenticação com `administrator / 5ecurity` | ⚠️ |
| 15:25 | Tentativas com variações de senha (5ecur1ty, Security, admin) | ❌ |
| 15:30 | Verificação de logs: nenhum erro de conexão PostgreSQL | ✅ |
| 15:45 | Diagnóstico: distinção entre credencial de repositório vs. aplicação | 🔍 |
| 16:00 | Decisão: aplicar rollback conforme ADR-002 | 📋 |
| 16:05 | `docker compose down` executado | ✅ |
| 16:10 | Limpeza de volumes: `/srv/prj003/data/postgres/*` removido | ✅ |
| 16:12 | Limpeza de volumes: `/srv/prj003/data/midpoint/var/*` removido | ✅ |
| 16:15 | Tentativa de novo bootstrap com `docker compose up -d` | ✅ |
| 16:20 | Acompanhamento de logs: "Created User:administrator" confirmado | ✅ |
| 16:25 | Nova tentativa de login com `administrator / 5ecurity` | ❌ |
| 16:40 | **DECISÃO TÉCNICA:** Interromper execução e registrar como falha | 🛑 |
| 16:45 | Rollback final: `docker compose down` | ✅ |
| 16:50 | Ambiente retornado ao estado pré-GMUD | ✅ |
| 18:30 | Elaboração do REL-GMUD-005 iniciada | 📄 |

---

## 5. INCIDENTE CRÍTICO IDENTIFICADO

### 5.1. Descrição Técnica do Problema

**Sintoma:** Falha de autenticação na interface web do midPoint após bootstrap bem-sucedido.

**Contexto Técnico:**
- Containers inicializados sem erros
- Logs confirmam criação do usuário `administrator`
- Conexão PostgreSQL ← midPoint funcionando (senha de repositório validada)
- Interface web acessível em `http://xxx.xxx.xxx.xxx:8080`
- Credenciais padrão de fábrica (`administrator / 5ecurity`) rejeitadas

### 5.2. Análise de Causa Raiz

#### **Hierarquia de Credenciais em IGA**

Foi identificada uma distinção crítica entre dois níveis de segredos:

| **Nível** | **Tipo** | **Valor** | **Status** |
|-----------|----------|-----------|------------|
| **Infraestrutura (Backend)** | Senha de conexão PostgreSQL | `PMMRw7Rm6B4o7T` | ✅ Funcional |
| **Identidade (Frontend)** | Senha do usuário `administrator` | `5ecurity` (padrão) | ❌ Não validada |

**Hipótese de Falha:**
Possível desalinhamento no bootstrap inicial causado por:
1. **Estado Residual:** Volumes parcialmente preenchidos em tentativa anterior
2. **Race Condition:** midPoint iniciou antes do PostgreSQL completar schema
3. **Configuração de Segurança:** Política de senha padrão alterada na imagem Docker
4. **Problema de Encoding:** Caractere especial na senha não reconhecido

### 5.3. Tentativas de Mitigação Realizadas

#### **Fase 1: Validação de Credenciais**
- ✅ Verificado Caps Lock desativado
- ✅ Testado preenchimento manual (sem autocomplete)
- ✅ Testadas variações: `5ecurity`, `5ecur1ty`, `Security`, `admin`
- ❌ Todas as tentativas rejeitadas

#### **Fase 2: Diagnóstico de Conectividade**
```bash
docker logs midpoint | grep -i "Connection to database"
```
- ✅ Nenhum erro de conexão identificado
- ✅ Mensagem "Connection to database successful" confirmada
- ❌ Problema não está na camada de repositório

#### **Fase 3: Reset Completo (Procedimento de Limpeza GRC)**
```bash
docker compose down
sudo rm -rf /srv/prj003/data/postgres/*
sudo rm -rf /srv/prj003/data/midpoint/var/*
docker compose up -d
docker logs -f midpoint
```
- ✅ Volumes completamente limpos
- ✅ Novo bootstrap executado
- ✅ Mensagem "Created User:administrator" confirmada
- ❌ Falha de login persistiu

---

## 6. DECISÃO DE ROLLBACK

### 6.1. Acionamento do Gate de Reversibilidade (ADR-002)

Conforme previsto no **DEC-ID-001** (Governança de Decisão) e na própria GMUD-005 v1.3, foi acionado o **Gate de Reversibilidade**:

**Critérios Atendidos:**
- ✅ Falha crítica identificada (acesso à aplicação não funcional)
- ✅ Duas tentativas de correção em voo realizadas sem sucesso
- ✅ Risco de introduzir estado inconsistente no ambiente
- ✅ Impossibilidade de validar critérios de sucesso da GMUD

**Decisão Formal:**
> "Interromper a execução da GMUD-005 e retornar o ambiente ao estado pré-mudança, preservando evidências para análise posterior."

### 6.2. Procedimento de Rollback Executado

```bash
# 1. Parar todos os containers
docker compose down

# 2. Remover volumes (reset completo)
sudo rm -rf /srv/prj003/data/postgres/*
sudo rm -rf /srv/prj003/data/midpoint/var/*
sudo rm -rf /srv/prj003/logs/midpoint/*

# 3. Validar estado limpo
ls -la /srv/prj003/data/

# 4. Confirmar ausência de containers em execução
docker ps -a
```

**Resultado:** Ambiente retornado ao estado de **Cold Start** (GMUD-004), sem containers em execução.

---

## 7. IMPACTOS E CONSEQUÊNCIAS

### 7.1. Impactos Técnicos

| **Área** | **Impacto** | **Severidade** |
|----------|-------------|----------------|
| **Infraestrutura** | Nenhum container em execução | Baixa |
| **Persistência** | Volumes limpos (estado virgem) | Baixa |
| **Integrações** | Nenhuma integração afetada (nenhuma configurada) | Nenhuma |
| **Identidades** | Nenhuma identidade criada ou impactada | Nenhuma |
| **Segurança** | Credenciais protegidas (não expostas) | Positiva |

### 7.2. Impactos na Governança

| **Área** | **Status** | **Observação** |
|----------|------------|----------------|
| **CAN-ID-001** | ✅ Não alterado | Nenhuma decisão semântica tomada |
| **CAN-ID-002** | ✅ Não alterado | Nenhuma autoridade de dados definida |
| **CAN-ID-003** | ✅ Não alterado | Nenhum estado de identidade criado |
| **DEC-ID-001** | ✅ Respeitado | Gate de Reversibilidade funcionou |

### 7.3. Impactos no Cronograma

- **Atraso estimado:** 2-3 dias (análise de causa raiz + nova tentativa)
- **GMUDs dependentes afetadas:** GMUD-006, GMUD-007, GMUD-008
- **Impacto no Living Lab:** Nenhum (ambiente experimental tolerante a falhas)

---

## 8. LIÇÕES APRENDIDAS

### 8.1. Aprendizados Técnicos

#### **1. Distinção Crítica: Credencial de Repositório vs. Aplicação**

**Contexto IGA:**
Em plataformas de Identity Governance and Administration, existem dois níveis de segredos:

- **Nível de Infraestrutura (Backend):**  
  Senha que o midPoint usa para se autenticar no PostgreSQL (`MIDPOINT_REPOSITORY_DATABASE_PASSWORD`). É a comunicação container ↔ banco de dados.

- **Nível de Identidade (Frontend):**  
  Credencial do objeto de usuário armazenado **dentro** das tabelas do banco. Para instalações Greenfield, o padrão de fábrica é `administrator / 5ecurity`.

**Aprendizado:**
> "A validação de conexão PostgreSQL bem-sucedida NÃO garante que o usuário administrativo tenha sido criado corretamente."

#### **2. Bootstrap de Aplicações IGA é Sensível a Timing**

**Observação:**
Mesmo com `depends_on: postgres` no docker-compose.yml, o midPoint pode iniciar antes do PostgreSQL completar a criação do schema, causando inconsistências silenciosas.

**Recomendação para GMUD-006:**
Implementar health check explícito:
```yaml
postgres:
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U midpoint"]
    interval: 10s
    timeout: 5s
    retries: 5

midpoint:
  depends_on:
    postgres:
      condition: service_healthy
```

#### **3. Volumes Parcialmente Preenchidos São Arriscados**

**Contexto:**
Se uma tentativa anterior de bootstrap falhou parcialmente, volumes podem conter:
- Schema incompleto
- Usuários com senhas não padrão
- Metadados corrompidos

**Aprendizado:**
> "Em ambiente Greenfield, sempre limpar volumes antes de novo bootstrap."

### 8.2. Aprendizados de Governança

#### **1. Gate de Reversibilidade Funcionou Conforme Projetado**

O **DEC-ID-001** previu exatamente este cenário:
- ✅ GMUD foi interrompida antes de criar estado inconsistente
- ✅ Nenhuma decisão semântica foi tomada em voo
- ✅ Ambiente retornou ao estado estável anterior

**Validação:**
> "A governança projetada no PRJ003 protegeu o projeto de débito técnico."

#### **2. Living Lab Demonstra Valor da Tolerância a Falhas**

**Contexto:**
Se este deploy ocorresse em ambiente de produção, o impacto seria crítico. No Living Lab:
- ✅ Falha é oportunidade de aprendizado
- ✅ Sem impacto em operações reais
- ✅ Permite experimentação de procedimentos de rollback

**Recomendação:**
> "Este incidente deve ser documentado como caso de estudo para treinamento de equipes IGA."

---

## 9. EVIDÊNCIAS COLETADAS

### 9.1. Logs Capturados

| **Arquivo** | **Descrição** | **Localização** |
|-------------|---------------|-----------------|
| `midpoint_bootstrap.log` | Log completo de inicialização do midPoint | `/srv/prj003/evidencias/` |
| `postgres_init.log` | Log de criação do schema PostgreSQL | `/srv/prj003/evidencias/` |
| `docker_ps_output.txt` | Status dos containers durante execução | `/srv/prj003/evidencias/` |
| `screenshot_login_failure.png` | Print da tela de login com erro | `/srv/prj003/evidencias/` |

### 9.2. Comandos de Diagnóstico Executados

```bash
# Validação de conexão do midPoint com PostgreSQL
docker logs midpoint | grep -i "Connection to database"

# Verificação de criação do usuário administrator
docker logs midpoint | grep -i "Created User:administrator"

# Validação de containers em execução
docker ps -a

# Teste de conectividade PostgreSQL
docker exec postgres psql -U midpoint -d midpoint -c "SELECT 1;"

# Verificação de volumes
ls -la /srv/prj003/data/postgres/
ls -la /srv/prj003/data/midpoint/var/
```

---

## 10. RISCOS IDENTIFICADOS PARA GMUD-006

| **Risco** | **Probabilidade** | **Impacto** | **Mitigação Proposta** |
|-----------|-------------------|-------------|------------------------|
| Senha padrão alterada na imagem Docker | Média | Alto | Validar documentação oficial Evolveum midPoint 4.8 |
| Race condition no bootstrap | Alta | Alto | Implementar health check no PostgreSQL |
| Versão do midPoint incompatível com procedimento | Baixa | Médio | Testar com imagem `evolveum/midpoint:4.8.3-alpine` (específica) |
| Conflito de portas na VM | Baixa | Baixo | Executar `netstat -tuln \| grep 8080` antes do deploy |
| Permissões inadequadas em volumes | Média | Médio | Executar `chown -R 999:999 /srv/prj003/data/midpoint/var` |

---

## 11. PRÓXIMOS PASSOS RECOMENDADOS

### 11.1. Ações Imediatas (Prazo: 18/01/2026)

1. **Validar Documentação Oficial:**
   - Consultar release notes do midPoint 4.8
   - Verificar se houve mudança na senha padrão
   - Confirmar procedimento correto de bootstrap

2. **Testar em Ambiente Isolado:**
   - Criar VM temporária para testes
   - Reproduzir cenário com configuração mínima
   - Validar login antes de aplicar no PRJ003

3. **Revisar docker-compose.yml:**
   - Adicionar health checks
   - Implementar restart policies
   - Validar variáveis de ambiente

### 11.2. GMUD-006 - Segunda Tentativa de Deploy

**Alterações Obrigatórias:**
- ✅ Health check no PostgreSQL
- ✅ Timeout de espera explícito antes de iniciar midPoint
- ✅ Validação de senha padrão via documentação oficial
- ✅ Script de validação pós-deploy automatizado

**Gate de Pre-Flight Reforçado:**
- ✅ Teste em VM isolada com resultado positivo
- ✅ Documentação oficial consultada
- ✅ Procedimento de rollback validado (comprovado nesta GMUD)

---

## 12. CONFORMIDADE E AUDITORIA

### 12.1. Alinhamento com Frameworks

| **Framework** | **Controle** | **Status** | **Evidência** |
|---------------|--------------|------------|---------------|
| **ISO 27001:2022** | A.5.22 (Change Management) | ✅ Conforme | GMUD planejada, executada e revertida |
| **ITIL v4** | Change Enablement | ✅ Conforme | Rollback aplicado conforme procedimento |
| **NIST CSF** | PR.IP-3 (Configuration Change Control) | ✅ Conforme | Estado anterior restaurado com sucesso |
| **CIS Controls** | 3.14 (Log Management) | ✅ Conforme | Evidências coletadas e armazenadas |

### 12.2. Rastreabilidade de Decisões

| **Decisão** | **Documento de Origem** | **Status** |
|-------------|-------------------------|------------|
| Acionamento de Rollback | DEC-ID-001 (Gate de Reversibilidade) | ✅ Executada |
| Limpeza de volumes | GMUD-005 v1.3 (Procedimento de Limpeza GRC) | ✅ Executada |
| Interrupção de execução | ADR-002 (Princípio de Reversibilidade) | ✅ Respeitada |
| Preservação de evidências | DGC-001 (Data Governance Canvas) | ✅ Conforme |

---

## 13. CONCLUSÃO

### 13.1. Status Final da GMUD-005

A **GMUD-005 v1.3** foi **encerrada sem sucesso** após identificação de falha crítica de autenticação na interface administrativa do midPoint. O **Gate de Reversibilidade** foi acionado com sucesso, retornando o ambiente ao estado pré-mudança sem introduzir débito técnico ou estado inconsistente.

### 13.2. Validação da Governança

**Aspectos Positivos:**
- ✅ O modelo de governança do PRJ003 funcionou conforme projetado
- ✅ Nenhuma decisão semântica foi tomada durante a execução técnica
- ✅ Canvases CAN-ID permaneceram intactos
- ✅ Procedimento de rollback foi executado com sucesso
- ✅ Evidências foram preservadas para análise de causa raiz

**Oportunidades de Melhoria:**
- 🔄 Implementar health checks no docker-compose.yml
- 🔄 Validar documentação oficial antes de assumir comportamento padrão
- 🔄 Criar ambiente de testes isolado para validação de procedimentos

### 13.3. Recomendação Final

**O PRJ003 está apto para GMUD-006** após:
1. Validação da senha padrão via documentação oficial
2. Implementação de health checks
3. Teste bem-sucedido em ambiente isolado

**Impacto no Roadmap:** Atraso estimado de 2-3 dias, sem comprometimento dos objetivos do Living Lab.

---

## 14. APROVAÇÕES E ASSINATURAS

| **Papel** | **Nome** | **Data** | **Status** |
|-----------|----------|----------|------------|
| **Executor da GMUD** | Paulo Feitosa | 17/01/2026 | ✅ Aprovado |
| **Owner do Projeto** | Paulo Feitosa | 17/01/2026 | ✅ Aprovado |
| **Arquiteto de Identidade** | Paulo Feitosa | 17/01/2026 | ✅ Aprovado |
| **GRC Lead** | Paulo Feitosa | 17/01/2026 | ✅ Aprovado |

---

## 15. CONTROLE DE VERSÃO

| **Versão** | **Data** | **Autor** | **Alteração** |
|------------|----------|-----------|---------------|
| 1.0 | 17/01/2026 | Paulo Feitosa | Criação do REL-GMUD-005 após rollback |

---

## 16. ANEXOS

### A. Mensagens de Erro Identificadas

```
Login Failed: Bad credentials
```

### B. Configuração do docker-compose.yml Utilizada

```yaml
services:
  postgres:
    image: postgres:16-alpine
    container_name: postgres
    environment:
      POSTGRES_DB: midpoint
      POSTGRES_USER: midpoint
      POSTGRES_PASSWORD: PMMRw7Rm6B4o7T
    volumes:
      - /srv/prj003/data/postgres:/var/lib/postgresql/data
    networks:
      - iga-network

  midpoint:
    image: evolveum/midpoint:4.8
    container_name: midpoint
    ports:
      - "8080:8080"
    environment:
      MIDPOINT_REPOSITORY_DATABASE_URL: jdbc:postgresql://postgres:5432/midpoint
      MIDPOINT_REPOSITORY_DATABASE_USERNAME: midpoint
      MIDPOINT_REPOSITORY_DATABASE_PASSWORD: PMMRw7Rm6B4o7T
    volumes:
      - /srv/prj003/data/midpoint/var:/opt/midpoint/var
      - /srv/prj003/logs/midpoint:/opt/midpoint/var/log
    depends_on:
      - postgres
    networks:
      - iga-network

networks:
  iga-network:
    driver: bridge
```

### C. Comando de Limpeza de Volumes Executado

```bash
sudo rm -rf /srv/prj003/data/postgres/* && sudo rm -rf /srv/prj003/data/midpoint/var/* && sudo rm -rf /srv/prj003/logs/midpoint/*
```

---

**FIM DO RELATÓRIO REL-GMUD-005**

---

**Observação Final para o Living Lab:**

Este incidente demonstra a importância da **separação entre credenciais de infraestrutura e credenciais de identidade** em plataformas IGA. A distinção entre a senha de conexão ao repositório (`MIDPOINT_REPOSITORY_DATABASE_PASSWORD`) e a senha do usuário administrativo (`administrator`) é um conceito fundamental que deve ser compreendido por qualquer profissional trabalhando com Identity Governance.

Este caso de estudo será valioso para:
- Treinamento de equipes IGA
- Documentação de procedimentos de troubleshooting
- Demonstração da efetividade de gates de reversibilidade
- Validação da governança projetada no PRJ003

**Próxima ação:** Análise de documentação oficial do midPoint 4.8 e planejamento da GMUD-006.

