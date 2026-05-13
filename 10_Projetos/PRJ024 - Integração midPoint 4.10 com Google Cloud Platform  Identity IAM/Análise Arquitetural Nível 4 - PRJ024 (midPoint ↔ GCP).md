


### Camada 1: Conectividade e Infraestrutura

| Dimensão | Análise | Baseado na Lição |
|----------|---------|------------------|
| **existência de conector** | Conector GCP da Atricore existe, mas é **community-supported**  | Lição L04 do PRJ022 (validação multi-IA) — precisamos testar **antes** de planejar |
| **status de desenvolvimento** | Disponível no GitHub, documentação limitada | PRJ023-L04: schema do conector pode ser enganoso |
| **midPoint target version** | Requer midPoint 4.4+  — nosso 4.10 atende | ✅ critério atendido |
| **ambiente Java** | PRECISA validar compatibilidade com Java 21 | PRJ022: ScriptedREST quebrou na migração Groovy 2.x → 4.0 |

**🚨 ALERTA CRÍTICO:**
> O conector GCP da Atricore tem o mesmo padrão do AWS Connector: **community-supported**, código no GitHub da Atricore, documentação mínima. Precisamos antecipar que ele pode ter as mesmas limitações:
> - Schema declara atributos que o conector não implementa (ex: grupos/políticas no AWS)
> - Pode não suportar operações de escrita em todos os atributos declarados
> - Versionamento e releases podem ser esporádicos

### Camada 2: Autenticação e Autorização

| Dimensão | Análise | Baseado na Lição |
|----------|---------|------------------|
| **modelo de autenticação** | Service Account GCP com JWT/OAuth2 | Diferente da AWS (Access Key/Secret Key) |
| **desafio técnico** | midPoint precisa gerar JWT e trocar por Access Token | PRJ024-TAP já prevê Authenticator.groovy |
| **trustAnchors** | GCP APIs usam TLS (googleapis.com) | PRJ023-L02: `-Djavax.net.ssl.trustStore` necessário |
| **permissões mínimas** | Service Account precisa `roles/iam.securityAdmin` no projeto | ✅ `CHAVES-GCP.md` já confirma |

### Camada 3: Schema Handling e Mapeamentos

| Dimensão | Análise | Baseado na Lição |
|----------|---------|------------------|
| **atributo nome** | Mapeamento `name` → `__NAME__` (ou similar) | PRJ023-L03: mapeamento obrigatório |
| **correlação** | Definir `primaryEmail` ou `name` como chave | PRJ022-L03: correlation rule explícita obrigatória |
| **atributos adicionais** | Mapear `givenName` → `firstName`, `familyName` → `lastName` | PRJ023 (outbound mapping necessário) |
| **limitação antecipada** | Conector pode NÃO suportar grupos/políticas na escrita | PRJ023-L04: lição do AWS Connector |

### Camada 4: Provisionamento e Ciclo de Vida

| Dimensão | Análise | Baseado na Lição |
|----------|---------|------------------|
| **criação** | `POST /users` via Admin SDK API | PRJ023: CreateUser funcionou |
| **leitura** | `GET /users` para reconciliação | PRJ023: Search funcionou |
| **atualização** | `PATCH /users` | PRJ023: Update funcionou |
| **grupos** | `awsGroups` existe mas não escreve no AWS | 🔴 **Hipótese**: `gcpGroups` ou `gcpRoles` podem ter mesmo problema |
| **remoção** | Fase 1 fora do escopo (TAP PRJ024) | Aceito, mas planejar para Fase 2 |

**Diagrama de Risco Baseado nas Liências:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ANÁLISE DE RISCO CONECTOR GCP (Pré-Execução)              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  RISCO ALTO (precisa validar no pré-flight obrigatório)             │    │
│  │  ┌─────────────────────────────────────────────────────────────────┐│    │
│  │  │ • Conector é compatível com Java 21 (midPoint 4.10)?            ││    │
│  │  │ • Test Connection funciona sem trustAnchors error?              ││    │
│  │  │ • CreateUser envia nome corretamente?                           ││    │
│  │  └─────────────────────────────────────────────────────────────────┘│    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  RISCO MÉDIO (antecipar possível limitação)                         │    │
│  │  ┌─────────────────────────────────────────────────────────────────┐│    │
│  │  │ • Grupos GCP/IAM podem ser "read-only" no schema                ││    │
│  │  │ • Policies/roles podem não ser escritas pelo conector           ││    │
│  │  │ • Schema pode ter atributos declarados mas não implementados    ││    │
│  │  └─────────────────────────────────────────────────────────────────┘│    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  RISCO CONTROLADO (mitigado por procedimento)                       │    │
│  │  ┌─────────────────────────────────────────────────────────────────┐│    │
│  │  │ • trustAnchors → JAVA_OPTS (mitigado)                           ││    │
│  │  │ • Rollback → snapshot Hyper-V                                   ││    │
│  │  └─────────────────────────────────────────────────────────────────┘│    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Pré-Flight - Existência de Conectores GCP

### 2.1. Levantamento (mesmo processo do PRJ023)

| Etapa | Comando | Resultado Esperado | Status |
|-------|---------|---------------------|--------|
| **1. Busca no Nexus Evolveum** | `curl -I https://nexus.evolveum.com/.../gcp/` | HTTP 200 ou 404 | ⏳ PENDENTE |
| **2. GitHub Atricore** | `https://github.com/atricore/midpoint-connector-gcp` | Repositório existe ✅ | ✅ CONFIRMADO |
| **3. Documentação Evolveum** | `https://docs.evolveum.com/connectors/.../GCPConnector/` | Página existe ✅ | ✅ CONFIRMADO  |
| **4. JAR standalone** | Buscar no Maven Central ou Nexus | Deve existir | ⏳ PENDENTE |

### 2.2. Informações Já Confirmadas

| Informação | Valor | Fonte |
|------------|-------|-------|
| **Conector** | `GCPConnector` | Evolveum Docs  |
| **Origin** | Atricore | Evolveum Docs  |
| **Status** | community | Evolveum Docs  |
| **midPoint mín.** | 4.4 | Atricore Blog  |
| **Código fonte** | `https://github.com/atricore/midpoint-connector-gcp` | GitHub |
| **Função** | Gerenciar permissões IAM para usuários GWS e Service Accounts | Evolveum Docs  |

### 2.3. Procedimento de Pré-Flight Proposto (PRJ024)

**Objetivo:** Validar viabilidade técnica antes de comprometer tempo com scripts Groovy.

```bash
# [iga-gf-02]$ 
# Passo 1: Baixar conector (se disponível)
wget https://github.com/atricore/midpoint-connector-gcp/releases/download/v1.0.0/connector-gcp-1.0.0.jar -P /tmp/

# Passo 2: Copiar para diretório correto (ATENÇÃO: icf-connectors/, NÃO connid-connectors/)
sudo cp /tmp/connector-gcp-*.jar /srv/iga-project/data/midpoint/icf-connectors/
sudo chown 1000:1000 /srv/iga-project/data/midpoint/icf-connectors/connector-gcp-*.jar
sudo chmod 644 /srv/iga-project/data/midpoint/icf-connectors/connector-gcp-*.jar

# Passo 3: Reiniciar midPoint
cd /srv/iga-project && sudo docker compose restart midpoint

# Passo 4: Verificar descoberta do conector
sudo docker logs iga-midpoint --tail 50 | grep -i "gcpconnector"
```

---

## 3. Requisitos e Análises Necessárias Antes da Execução

### 3.1. Checklist de Pré-Requisitos (PRJ024)

| # | Requisito | Verificação | Critério | Baseado em |
|---|-----------|-------------|----------|-------------|
| PR-01 | JAR do conector disponível | Buscar no GitHub/Nexus | Download HTTP 200 | PRJ023 (AWS Connector) |
| PR-02 | Chave JSON da SA transferida | `scp midpoint-gcp-key.json iga-gf-02:/srv/iga-project/data/midpoint/` | Arquivo existe | CHAVES-GCP.md |
| PR-03 | `JAVA_OPTS` com trustStore | Verificar `docker-compose.yml` | Parâmetro presente | PRJ023-L02 |
| PR-04 | Variável de ambiente da chave | `GCP_CREDENTIALS_PATH` configurada | No docker-compose.yml | TAP PRJ024 |
| PR-05 | API Admin SDK ativada | `gcloud services enable admin.googleapis.com` | Já ativada ✅ | CHAVES-GCP.md |
| PR-06 | API IAM ativada | `gcloud services enable iam.googleapis.com` | Já ativada ✅ | CHAVES-GCP.md |
| PR-07 | Snapshot Hyper-V | Checkpoint das VMs | Criado antes da execução | Lição PRJ023 |
| PR-08 | Testar autenticação isolada | Script Groovy mínimo para JWT | Access Token gerado | TAP PRJ024 |

### 3.2. Análises Técnicas Necessárias (Pré-Execução)

| Análise | Descrição | Método | Prioridade |
|---------|-----------|--------|------------|
| **A01 - Schema Discovery** | Ver quais atributos o conector realmente expõe | Test Connection no midPoint → ver XML do schema | 🔴 Alta |
| **A02 - Teste de Criação Mínimo** | Criar usuário com apenas `name` | Resource → Test → Create | 🔴 Alta |
| **A03 - Mapeamento de Atributos** | Verificar se `givenName`/`familyName` são enviados | Criar usuário com atributos e verificar no GCP | 🟡 Média |
| **A04 - Teste de Grupos** | Verificar se `groups` é suportado na escrita | Tentar atribuir grupo durante criação | 🟡 Média |
| **A05 - Correlação** | Verificar se `primaryEmail` é retornado no Search | Buscar usuário recém-criado | 🔴 Alta |

### 3.3. Documentação a Ser Produzida (PRJ024)

| Documento | Conteúdo | Prazo |
|-----------|----------|-------|
| **POP-PRJ024-v1.0** | Procedimento completo de instalação e configuração | Pós-execução |
| **Scripts Groovy** | Authenticator, SearchScript, CreateScript | Pré-execução |
| **TEP-PRJ024** | Relatório de encerramento com lições aprendidas | Pós-execução |
| **Relatório de Limitações** | Documentar atributos não suportados (se aplicável) | Pós-execução |

---

## 4. Lições Aplicadas ao PRJ024

| # | Lição Original | Aplicação no PRJ024 |
|---|----------------|----------------------|
| **PRJ022-L04** | Validação multi-IA essencial | Antes de escrever scripts, validar conector com IAs diferentes |
| **PRJ022-L10** | CSV é fallback aceitável | Se GCP falhar, podemos usar CSV exportado da API |
| **PRJ023-L03** | Mapeamento `name` → `icfs:name` obrigatório | Mesma regra se aplica ao GCP |
| **PRJ023-L04** | Schema do conector pode ser enganoso | Validar atributos de grupos ANTES de planejar automação |
| **PRJ023-L05** | Test Connection OK não garante todas operações | Testar CREATE, SEARCH, UPDATE separadamente |
| **PRJ023-L02** | `trustAnchors` requer JAVA_OPTS | Configurar ANTES do Test Connection |

---

## 5. Plano de Ação Imediato (PRJ024)

| Fase | Atividade | Duração | Critério |
|------|-----------|---------|----------|
| **F0** | Snapshot Hyper-V (`PRJ024-Antes-Configuracao`) | 5min | Checkpoint criado |
| **F1** | Baixar conector GCP do GitHub | 10min | JAR disponível |
| **F2** | Instalar conector no midPoint | 10min | Log mostra descoberta |
| **F3** | Criar Resource GCP no midPoint | 20min | Test Connection OK |
| **F4** | Validar Schema Discovery | 15min | Atributos esperados presentes |
| **F5** | Teste de criação de usuário único | 30min | Usuário criado no GCP |
| **F6** | Documentar limitações encontradas | 30min | Relatório técnico |

**Duração total estimada:** 2 horas (spike)

---

**Status:** Aguardando autorização para executar o pré-flight e o PRJ024 propriamente dito. 🚀