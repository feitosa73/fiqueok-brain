
FOI REALIZADA A SEGUINTE CONSULTA A ALGUMAS IAS PARA DEFINIRMOS A CONTINUIDADE DO PROJ008


**Contexto do Desafio:** > Atue como um Comitê de Governança e Arquitetura de TI. O objetivo é estabelecer a integração automatizada entre um sistema de RH (Source of Truth - MariaDB) e uma solução de IGA (Identity Governance and Administration), eliminando processos manuais baseados em CSV que estão causando corrupção de dados (encoding) e falhas de integridade no Active Directory.

**Restrições de Ambiente:** > - A infraestrutura é baseada em Linux (Ubuntu 24.04), Docker e rede privada (Mesh VPN).

- As credenciais de infraestrutura e aplicações são geridas em um cofre de senhas (Vault).
    
- O desenvolvimento será assistido por Inteligência Artificial, exigindo rigor extremo em segurança de código.
    

**Solicitação de Parecer Técnico (Responda sem vieses):**

1. **Arquitetura de Integração:** Qual a arquitetura mais recomendada para expor dados de um banco legado de forma segura para uma ferramenta de IGA? Discorra sobre o uso de APIs intermediárias versus conexões diretas, focando em segurança e integridade de caracteres.
    
2. **Padrões de Desenvolvimento:** Proponha um padrão de design de software que maximize a auditabilidade e facilite a manutenção por terceiros (ou IAs). Como garantir que o tratamento de encodings (acentuação) seja tratado na raiz?
    
3. **Cadeia de Custódia do Código:** Como deve ser estruturado o ciclo de vida desse software? Proponha uma estratégia de repositório, fluxo de trabalho (Git) e como estabelecer uma esteira de CI/CD que garanta que nenhum código entre em produção sem validação automática.
    
4. **Camadas de Segurança (DevSecOps):** Quais são os controles indispensáveis para uma API que lida com dados de identidade? Liste as categorias de testes (SAST, DAST, SCA, etc.) e em que momento da esteira cada uma deve atuar para cumprir a ISO 27001.
    
5. **Gestão de Segredos Dinâmicos:** Como o software deve interagir com o Cofre de Senhas para evitar vazamento de credenciais? Qual o método de autenticação mais seguro para uma aplicação rodando em container?
    
6. **Monitoramento e Observabilidade:** Além dos logs tradicionais, como projetar um sistema de monitoramento de saúde que valide não apenas se a API está "no ar", mas se o fluxo de dados entre as pontas (RH -> API -> IGA) está íntegro?
    

**Requisito Final:** Apresente um veredito sobre os riscos críticos dessa implementação e quais são os "Non-Negotiables" (não negociáveis) do ponto de vista de um Auditor de Segurança.




### RESPOSTA DO CHATGPT



A seguir, apresento o parecer técnico estruturado sob a ótica de um Comitê de Governança e Arquitetura de TI, alinhado a boas práticas de mercado (NIST SP 800-53, ISO/IEC 27001:2022, CIS Controls v8, OWASP ASVS e ISACA COBIT).

---

# 1) Arquitetura de Integração

## Opção A — API Intermediária (Recomendada)

**Descrição:** Criar uma camada de API (microserviço) entre o MariaDB (SoT) e a solução de IGA.

### Vantagens

- **Segurança**
    
    - Evita exposição direta do banco (princípio de menor privilégio – ISO 27001 A.5.15)
        
    - Permite autenticação forte (OAuth2, mTLS)
        
    - Centraliza controles de acesso (RBAC/ABAC)
        
- **Integridade de dados**
    
    - Normalização de encoding (UTF-8) na camada de serviço
        
    - Validação de schema (JSON Schema / OpenAPI)
        
- **Governança**
    
    - Versionamento de contrato (API versioning)
        
    - Observabilidade e auditoria centralizadas
        
- **Resiliência**
    
    - Possibilidade de fila/event streaming (ex: Kafka) para desacoplamento
        

### Desvantagens

- Maior complexidade operacional
    
- Necessidade de governança de API (gateway, rate limiting)
    

---

## Opção B — Conexão Direta (Não recomendada)

**Descrição:** IGA acessa diretamente o MariaDB.

### Riscos

- **Violação de princípio de segurança**
    
    - Exposição direta do banco (alto risco – NIST AC-3, SC-7)
        
- **Integridade de encoding**
    
    - Dependência da configuração cliente → risco de corrupção (problema já existente)
        
- **Auditoria limitada**
    
    - Dificuldade de rastrear alterações e acessos
        
- **Acoplamento forte**
    
    - Mudanças no schema impactam diretamente o IGA
        

---

## Recomendação Final

**Arquitetura em camadas:**

```
MariaDB (UTF8MB4)
   ↓
Data Access Layer (read-only)
   ↓
API de Integração (containerizada)
   ↓
IGA (via REST/SCIM)
```

**Padrões sugeridos:**

- SCIM 2.0 (RFC 7643/7644) para identidade
    
- RESTful APIs com OpenAPI 3.1
    
- Encoding padrão: UTF-8 (end-to-end)
    

---

# 2) Padrões de Desenvolvimento

## Padrão Recomendado: Clean Architecture + Domain-Driven Design (DDD)

### Estrutura

- **Domain Layer:** regras de negócio (imutável e testável)
    
- **Application Layer:** orquestração
    
- **Infrastructure Layer:** MariaDB, APIs externas
    
- **Interface Layer:** REST controllers
    

### Benefícios

- Alta **auditabilidade**
    
- Facilidade para manutenção por terceiros/IA
    
- Baixo acoplamento
    

---

## Tratamento de Encoding (CRÍTICO)

### Medidas obrigatórias

1. **Banco**
    
    - Charset: `utf8mb4`
        
    - Collation: `utf8mb4_unicode_ci`
        
2. **Driver de conexão**
    
    - Forçar encoding UTF-8 explicitamente
        
3. **API**
    
    - Header obrigatório:
        
        ```
        Content-Type: application/json; charset=utf-8
        ```
        
4. **Validação**
    
    - Sanitização de input/output
        
    - Testes automatizados com caracteres especiais
        
5. **Contrato**
    
    - OpenAPI definindo encoding
        

---

# 3) Cadeia de Custódia do Código

## Estratégia de Repositório

- Mono-repo (se pequeno/médio) ou multi-repo (escala)
    
- Branching:
    
    - `main` (produção)
        
    - `develop`
        
    - `feature/*`
        
    - `hotfix/*`
        

---

## Workflow (GitOps)

- Pull Requests obrigatórios
    
- Revisão por pares (4-eyes principle – ISO 27001 A.5.3)
    
- Commits assinados (GPG)
    

---

## Pipeline CI/CD (Não negociável)

### Etapas mínimas

1. **Build**
    
2. **Lint + SAST**
    
3. **Testes unitários**
    
4. **SCA (dependências)**
    
5. **Testes de integração**
    
6. **DAST (ambiente staging)**
    
7. **Deploy automatizado (com aprovação)**
    

---

# 4) Camadas de Segurança (DevSecOps)

## Controles essenciais (OWASP ASVS + NIST)

### Tipos de testes

|Tipo|Objetivo|Momento|
|---|---|---|
|SAST|Vulnerabilidades no código|Build|
|SCA|Dependências vulneráveis|Build|
|DAST|Testes dinâmicos|Staging|
|IAST|Runtime analysis|Teste|
|Container Scan|Imagens Docker|Build|
|Secrets Scan|Vazamento de segredos|Commit/CI|

---

## Controles adicionais

- Autenticação forte (OAuth2 + mTLS)
    
- Rate limiting
    
- Input validation (OWASP Top 10)
    
- Logging auditável (ISO 27001 A.8.15)
    

---

# 5) Gestão de Segredos Dinâmicos

## Abordagem recomendada: Integração com Vault

### Métodos possíveis

### Opção A — AppRole

- Aplicação autentica via RoleID + SecretID
    
- **Prós:** simples, amplamente suportado
    
- **Contras:** gestão do SecretID
    

---

### Opção B — JWT/OIDC (Recomendado)

- Container autentica via identidade federada
    
- **Prós:**
    
    - Sem segredos estáticos
        
    - Rotação automática
        
- **Contras:**
    
    - Maior complexidade inicial
        

---

### Opção C — mTLS com identidade de workload

- Certificados para autenticação
    
- **Prós:** alta segurança
    
- **Contras:** gestão de certificados
    

---

## Boas práticas (CIS + NIST)

- Segredos **nunca** em código ou variáveis de ambiente persistentes
    
- Uso de **dynamic secrets**
    
- Rotação automática
    
- TTL curto
    

---

# 6) Monitoramento e Observabilidade

## Abordagem recomendada: Observabilidade completa (3 pilares)

### 1. Logs

- Estruturados (JSON)
    
- Correlacionados (trace-id)
    

### 2. Métricas

- Latência
    
- Taxa de erro
    
- Throughput
    

### 3. Tracing distribuído

- Fluxo RH → API → IGA
    

---

## Validação de Integridade (CRÍTICO)

### Estratégias

### Opção A — Checksums de dados

- Hash antes e depois da integração
    
- Detecta corrupção
    

---

### Opção B — Reconciliação periódica

- Comparação RH vs IGA
    
- Baseado em atributos críticos
    

---

### Opção C — Synthetic Transactions (Recomendado)

- Usuários fictícios de teste
    
- Validação contínua do fluxo
    

---

## Ferramentas sugeridas

- Prometheus + Grafana
    
- OpenTelemetry
    
- ELK Stack
    

---

# 7) Veredito — Riscos Críticos

## Principais riscos

1. **Corrupção de encoding**
    
    - Impacto direto na identidade digital
        
2. **Exposição de credenciais**
    
    - Comprometimento sistêmico
        
3. **Falta de rastreabilidade**
    
    - Não conformidade (ISO 27001)
        
4. **Integração direta com banco**
    
    - Alto risco estrutural
        
5. **Ausência de validação automatizada**
    
    - Entrada de código vulnerável
        

---

# 8) NON-NEGOTIABLES (Auditoria de Segurança)

Itens que **devem ser obrigatórios**:

### Arquitetura

- API intermediária (proibido acesso direto ao banco)
    
- TLS obrigatório (mTLS preferencial)
    

### Dados

- UTF-8 end-to-end
    
- Validação de schema
    

### Segurança

- Integração com Vault (sem segredos hardcoded)
    
- Autenticação forte (OAuth2/OIDC)
    

### DevSecOps

- Pipeline CI/CD com:
    
    - SAST
        
    - SCA
        
    - DAST
        
    - Scan de containers
        
- Code review obrigatório
    

### Observabilidade

- Logs auditáveis
    
- Tracing distribuído
    
- Reconciliação de dados
    

### Governança

- Versionamento de API
    
- Documentação OpenAPI
    
- Controle de acesso baseado em papéis
    

---

# Conclusão

A substituição do processo baseado em CSV por uma arquitetura orientada a APIs é não apenas recomendada, mas **essencial** para garantir:

- Integridade de dados
    
- Segurança operacional
    
- Conformidade regulatória
    
- Escalabilidade futura
    

Qualquer implementação que viole os "non-negotiables" acima deve ser considerada **não conforme** sob auditoria de segurança.



### RESPOSTA DO COPILOT


Vamos direto ao ponto, Paulo — isso aqui é arquitetura, mas também é governança e risco. Vou estruturar por tópico e fechar com um veredito claro.

---

## Arquitetura de integração: API intermediária vs conexão direta

**Veredito arquitetural:** use uma **API intermediária** (camada de integração) entre o RH (MariaDB) e a solução de IGA. Conexão direta do IGA ao banco legado só deveria existir em cenários muito controlados e simples — não é o seu caso.

**Por que API intermediária é preferível:**

- **Segurança de superfície:**
    - **Menos exposição:** o banco legado não fica exposto na rede; apenas a API é publicada na mesh VPN.
    - **Controle de acesso:** autenticação/autorização robustas (OAuth2/OIDC, mTLS, RBAC) na API, em vez de credenciais de banco espalhadas em múltiplos consumidores. [4spotconsulting.com](https://4spotconsulting.com/api-security-for-hr-data-12-critical-safeguards/)
- **Integridade de dados e caracteres:**
    - A API pode impor **contratos de dados versionados** (JSON com schemas bem definidos) e validar encoding (UTF‑8) em todos os pontos de entrada e saída.
    - É possível normalizar acentuação e garantir `SET NAMES utf8mb4`/collation consistente no driver de acesso ao MariaDB, encapsulado na camada de integração.
- **Governança e auditabilidade:**
    - Logs de auditoria ficam concentrados na API (quem consultou, quando, qual payload, qual resultado).
    - Facilita controles de LGPD (minimização de dados, masking, pseudonimização) antes de chegar ao IGA.
- **Evolução e desacoplamento:**
    - O RH pode ser trocado ou migrado sem impactar o IGA, desde que o contrato da API seja mantido.
    - Permite incluir regras de negócio (ex.: filtros de escopo, mapeamento de atributos, normalização de grupos).

**Quando a conexão direta seria aceitável (e ainda assim arriscada):**

- Ambiente extremamente controlado, com:
    - IGA e banco no mesmo domínio de confiança.
    - Sem necessidade de transformação de dados.
    - Sem requisitos fortes de auditoria de payload.
- Mesmo assim, você perde:
    - Camada de validação de encoding.
    - Ponto único de auditoria.
    - Flexibilidade de evolução.

**Conclusão:** API intermediária é o padrão recomendado — **é o seu “ponto de verdade” de integração**, não o banco.

---

## Padrões de desenvolvimento: design para auditabilidade e encoding “na raiz”

### Padrão de design recomendado

Use uma combinação de:

- **Arquitetura hexagonal (Ports & Adapters)** ou **Clean Architecture**:
    - **Domínio** (regras de negócio de identidade e RH) isolado.
    - **Adapters** para:
        - Banco RH (MariaDB).
        - IGA (conector, API, SCIM, etc.).
        - Active Directory (se houver interação direta).
        - Observabilidade (logs, métricas, tracing).
- **CQRS leve** (quando fizer sentido):
    - Separar comandos (provisionamento, atualização) de consultas (listagem de identidades) ajuda na rastreabilidade e testes.

Isso facilita:

- **Auditabilidade:** cada caso de uso é um “application service” claro, com logs estruturados por operação.
- **Manutenção por terceiros/IA:** código organizado por contexto, com contratos explícitos, reduz ambiguidade.

### Encoding tratado na raiz

**Princípios:**

- **Padrão único:** tudo em **UTF‑8/UTF‑8MB4**, do banco à API, passando por containers e sistema operacional. [OWASP Foundation](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/stable-en/02-checklist/05-checklist)
- **Configuração explícita em todos os pontos:**
    - MariaDB: `character_set_server=utf8mb4`, `collation_server=utf8mb4_unicode_ci`.
    - Conexão: `SET NAMES utf8mb4` ou equivalente no driver.
    - API: framework configurado para `Content-Type: application/json; charset=utf-8`.
    - Containers: locale configurado (`LANG`, `LC_ALL`) para UTF‑8.
- **Validação e normalização:**
    - Camada de entrada da API:
        - Valida charset.
        - Rejeita payloads com encoding inválido.
    - Normalização de strings (NFC) se houver integração com sistemas legados que tratam acentos de forma diferente.
- **Testes automatizados de encoding:**
    - Casos de teste com nomes acentuados, caracteres especiais, emojis.
    - Testes de ponta a ponta (RH → API → IGA → AD) verificando integridade de caracteres.

---

## Cadeia de custódia do código: repositório, Git e CI/CD

### Estratégia de repositório

- **Monorepo pequeno ou multi-repo organizado**, mas com:
    - **Repositório dedicado** para a API de integração.
    - Infraestrutura como código (IaC) em repositório próprio ou pasta separada (Terraform/Ansible/K8s manifests).
- **Branching model:**
    - `main`/`master`: sempre **deployável**.
    - `develop` (opcional): integração de features.
    - `feature/*`, `bugfix/*`, `hotfix/*`: trabalho diário.
    - Pull Requests obrigatórios para merge em `main`/`develop`.

### Fluxo de trabalho Git

1. **Feature branch** criada a partir de `develop` (ou `main` se fluxo trunk-based).
2. Commits pequenos, mensagens descritivas.
3. Pull Request com:
    - Revisão obrigatória de pelo menos 1 pessoa (4 olhos).
    - Checks automáticos de CI obrigatórios (não pode fazer override sem justificativa formal).
4. Merge apenas se:
    - Todos os testes passarem.
    - Scans de segurança estiverem verdes (ou findings tratados/aceitos formalmente).

### Esteira de CI/CD

**CI (por commit / PR):**

- **Build:**
    - Compilação.
    - Build de imagem Docker imutável (tag com hash do commit).
- **Testes automatizados:**
    - Unitários.
    - Integração (mock de RH/IGA).
    - Testes de encoding (casos com acentuação).
- **SAST (Static Application Security Testing):**
    - Rodar em cada PR (ex.: SonarQube, Semgrep, etc.). [cloudsecurityweb.com](https://cloudsecurityweb.com/articles/2023/12/01/best-practices-for-building-secure-api-integration-pipelines/)
- **SCA (Software Composition Analysis):**
    - Verificar vulnerabilidades em dependências (ex.: OWASP Dependency-Check, Trivy, etc.).

**CD (por ambiente):**

- **Ambientes:** `dev` → `homolog`/`staging` → `prod`.
- **Promoção baseada em artefato:**
    - A mesma imagem Docker é promovida entre ambientes (sem rebuild).
- **Gates de segurança:**
    - Antes de `staging`: SAST/SCA sem findings críticos.
    - Em `staging`: DAST (Dynamic Application Security Testing) e testes de integração ponta a ponta.
    - Em `prod`: deploy apenas com aprovação explícita (change management) e trilha de auditoria.

---

## Camadas de segurança (DevSecOps) e ISO 27001

### Controles indispensáveis para a API

- **Autenticação e autorização fortes:**
    - OAuth2/OIDC, mTLS ou ambos.
    - Princípio do menor privilégio (scopes, roles).
- **Criptografia em trânsito:**
    - TLS forte (versões modernas, ciphers seguros).
- **Criptografia em repouso:**
    - Dados sensíveis cifrados no banco (quando aplicável).
- **Rate limiting e proteção contra abuso:**
    - Limites por cliente, proteção contra brute force.
- **Validação de entrada e saída:**
    - Input validation rigorosa (OWASP), schemas JSON, sanitização. [OWASP Foundation](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/stable-en/02-checklist/05-checklist)
- **Logging e auditoria:**
    - Logs estruturados, sem dados sensíveis em claro.
    - Trilha de quem acessou quais identidades e quando.
- **Segregação de ambientes e redes:**
    - Dev, homolog e prod isolados.
    - Acesso à API apenas via mesh VPN e/ou gateways controlados.

### Categorias de testes e momento na esteira

- **SAST (Static Application Security Testing):**
    - Momento: em cada commit/PR (CI).
    - Objetivo: detectar vulnerabilidades de código (injeção, XSS, etc.).
- **SCA (Software Composition Analysis):**
    - Momento: em cada build (CI).
    - Objetivo: vulnerabilidades em bibliotecas e imagens base.
- **DAST (Dynamic Application Security Testing):**
    - Momento: em `staging`, antes de ir para produção.
    - Objetivo: testar a API rodando (SQLi, auth bypass, etc.).
- **IAST/RASP (se disponível):**
    - Momento: em ambientes de teste ou produção.
    - Objetivo: monitorar vulnerabilidades em tempo de execução.
- **Testes funcionais e de regressão automatizados:**
    - Momento: CI e `staging`.
- **Testes de conformidade e privacidade (LGPD/ISO 27001):**
    - Momento: revisões periódicas, auditorias internas.

---

## Gestão de segredos dinâmicos e autenticação de containers

### Interação com o cofre de senhas (Vault)

**Princípios:**

- **Segredos nunca em código ou em imagem Docker.**
- **Segredos sempre obtidos em tempo de execução** via cofre (HashiCorp Vault ou similar).

**Boas práticas:**

- **Dynamic secrets:**
    - Banco de dados (MariaDB) com credenciais geradas sob demanda, com TTL e revogação automática.
    - Reduz impacto de vazamento e facilita rotação.
- **Renovação automática:**
    - A aplicação renova leases de segredos antes do vencimento.
- **Políticas de acesso mínimas:**
    - Cada serviço/container tem uma policy específica no Vault, com apenas os segredos necessários.

### Método de autenticação mais seguro para containers

- **Se estiver em Kubernetes:**
    - **Kubernetes Auth Method** do Vault:
        - O pod se autentica usando o JWT do Service Account.
        - O Vault valida o token e emite um token de acesso com políticas específicas.
- **Se não estiver em Kubernetes (Docker puro):**
    - **AppRole** com:
        - `role_id` provisionado de forma segura.
        - `secret_id` injetado via mecanismo seguro (ex.: arquivo montado por outro agente, não por variável de ambiente).
- **Evitar:**
    - API keys fixas em variáveis de ambiente.
    - Arquivos de configuração com segredos em disco sem criptografia.

---

## Monitoramento e observabilidade: além de “está no ar”

### Camadas de observabilidade

- **Logs estruturados:**
    - Correlation IDs por requisição (ex.: `X-Correlation-Id`).
    - Logs de negócio: “funcionário X sincronizado com sucesso”, “atributo Y divergente”.
- **Métricas:**
    - Contadores:
        - Número de identidades sincronizadas.
        - Erros por tipo (validação, conexão, encoding).
    - Histogramas:
        - Latência por endpoint.
    - Gauges:
        - Tamanho de filas (se houver).
- **Tracing distribuído:**
    - OpenTelemetry/Jaeger/Tempo:
        - Traçar fluxo RH → API → IGA → AD.

### Monitoramento de integridade do fluxo de dados

Além de health checks básicos (`/health`), crie:

- **Health check sintético de negócio:**
    - Endpoint que:
        - Executa uma consulta controlada no RH (ex.: usuário de teste).
        - Passa pela mesma lógica de transformação.
        - Simula envio ao IGA (ou verifica status).
    - Retorna OK apenas se todas as etapas estiverem íntegras.
- **Validação de consistência periódica:**
    - Jobs que:
        - Comparam amostras de dados entre RH, IGA e AD (ex.: número de contas, atributos críticos).
        - Disparam alertas se divergência ultrapassar limiar.
- **Alertas:**
    - Em cima de:
        - Aumento de erros 4xx/5xx.
        - Falhas de autenticação no Vault.
        - Queda brusca no volume de sincronizações (indicando fluxo parado).
        - Erros de encoding detectados.

---

## Veredito final: riscos críticos e “Non‑Negotiables”

### Riscos críticos

1. **Exposição indevida de dados de identidade:**
    - API sem autenticação forte ou sem TLS adequado.
2. **Vazamento de credenciais:**
    - Segredos em código, imagens ou variáveis de ambiente sem controle.
3. **Corrupção silenciosa de dados (encoding):**
    - Acentos quebrados, nomes truncados, inconsistência entre RH, IGA e AD.
4. **Falta de trilha de auditoria:**
    - Impossibilidade de responder “quem alterou o quê, quando e por quê”.
5. **Dependência excessiva de processos manuais:**
    - CSVs, scripts ad hoc, intervenções humanas sem controle.
6. **Esteira de CI/CD sem gates de segurança:**
    - Código vulnerável indo para produção sem SAST/SCA/DAST.

### Non‑Negotiables de um Auditor de Segurança

Do ponto de vista de auditoria séria, estes pontos não são negociáveis:

1. **API intermediária com autenticação forte e TLS obrigatório.**
2. **Gestão de segredos centralizada em cofre, sem segredos hardcoded ou expostos em imagens.**
3. **Encoding padronizado (UTF‑8) e validado em toda a cadeia, com testes automatizados cobrindo acentuação.**
4. **Esteira CI/CD com:**
    - SAST e SCA obrigatórios em cada PR.
    - DAST antes de produção.
    - Deploy apenas de artefatos versionados e rastreáveis.
5. **Logs de auditoria completos e imutáveis:**
    - Acesso a dados de identidade, alterações, falhas de autenticação.
6. **Segregação de ambientes e princípio do menor privilégio em todos os acessos (banco, Vault, IGA, AD).**
7. **Monitoramento de integridade de fluxo (RH → API → IGA → AD) com alertas configurados.**

Se algum desses itens for relativizado, o risco deixa de ser “operacional” e passa a ser **estratégico** — com impacto direto em conformidade (ISO 27001, LGPD) e confiança dos colaboradores.

Se você quiser, no próximo passo podemos descer para algo ainda mais concreto: um diagrama de alto nível dessa arquitetura e um exemplo de pipeline CI/CD em YAML alinhado a tudo isso.



RESPOSTA DO PERPLEXITY

Meu parecer técnico é claro: **a arquitetura mais segura e auditável para esse cenário é uma Shadow API intermediária, com contrato canônico de identidade, autenticação forte, leitura controlada do MariaDB e observabilidade ponta a ponta**. **Conexão direta da ferramenta IGA ao banco legado só é aceitável como exceção temporária de laboratório; como padrão arquitetural, ela aumenta acoplamento, dificulta governança semântica, expõe o banco e perpetua os erros de integridade já observados no histórico do ambiente**.DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md+2[owasp](https://owasp.org/API-Security/editions/2023/en/0x11-t10/)

## Arquitetura recomendada

O histórico do próprio laboratório mostra que a conexão direta via JDBC foi tratada como etapa de evolução, mas também que as falhas recorrentes não eram apenas de tooling: elas surgiam da ausência de contrato semântico, identificador canônico e autoridade formal por atributo. Além disso, o post-mortem do PRJ006 registrou a migração conceitual para API REST justamente após limites e anti-patterns da integração direta, o que reforça que a camada intermediária não é “luxo”, mas mecanismo de governança e redução de risco.DOC-ARC-000-Fundamentos-de-Decisao-em-Arquitetura-de-Identidade.md+3

A Shadow API deve operar como **camada de abstração e controle** entre RH e IGA, com estas responsabilidades mínimas:

- Expor somente dados necessários ao ciclo JML.PRJ005-Documento-de-Abertura-de-Projeto.md+1
    
- Traduzir esquema legado em um **modelo canônico de identidade**.[DOC-ARC-000-Fundamentos-de-Decisao-em-Arquitetura-de-Identidade.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/b6287d04-0f10-45dc-8fc8-d840ac819d81/DOC-ARC-000-Fundamentos-de-Decisao-em-Arquitetura-de-Identidade.md)
    
- Fixar `employeeId` como âncora imutável de correlação.DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md+1
    
- Declarar OrangeHRM/MariaDB como fonte autoritativa apenas para atributos de RH, nunca como origem de escrita pelo IGA.PRJ005-Documento-de-Abertura-de-Projeto.md+1
    
- Normalizar charset na borda e devolver payloads UTF-8 consistentes.[PRJ005-Documento-de-Abertura-de-Projeto.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/1e672a9d-2677-461a-90ec-fcb1569ff5da/PRJ005-Documento-de-Abertura-de-Projeto.md)
    

## API intermediária vs conexão direta

|Critério|API intermediária|Conexão direta IGA -> MariaDB|
|---|---|---|
|Segurança|Reduz superfície do banco, permite autenticação forte, rate limit, validação e autorização por endpoint. owasp+1|Expõe mais o banco e amplia impacto de credenciais comprometidas ou queries mal definidas. PRJ006-Termo-de-Abertura-de-Projeto.md+1|
|Governança|Centraliza contrato canônico, mapeamento de estados e autoridade por atributo. DOC-ARC-000-Fundamentos-de-Decisao-em-Arquitetura-de-Identidade.md+1|Embute regra de negócio em query/conector, dificultando manutenção e auditoria. DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md+1|
|Integridade de caracteres|Permite padronizar UTF-8 na entrada, transformação e saída. [PRJ005-Documento-de-Abertura-de-Projeto.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/1e672a9d-2677-461a-90ec-fcb1569ff5da/PRJ005-Documento-de-Abertura-de-Projeto.md)|Depende de configurações difusas de driver, banco, collation e parser da ferramenta. PRJ005-Documento-de-Abertura-de-Projeto.md+1|
|Auditabilidade|Gera trilha por requisição, payload validado, decisão aplicada e resposta entregue. [owasp](https://owasp.org/www-project-devsecops-guideline/)[vault_implementation_guide_v3.0.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/0471c2c6-8dea-4ead-98e2-d48e0b5c821b/vault_implementation_guide_v3.0.md)|Logs tendem a ficar espalhados entre banco, conector e IGA. PRJ006-Termo-de-Abertura-de-Projeto.md+1|
|Evolução|Facilita troca futura de fonte, versionamento de contrato e testes automatizados. [DOC-ARC-000-Fundamentos-de-Decisao-em-Arquitetura-de-Identidade.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/b6287d04-0f10-45dc-8fc8-d840ac819d81/DOC-ARC-000-Fundamentos-de-Decisao-em-Arquitetura-de-Identidade.md)[owasp](https://owasp.org/www-project-devsecops-guideline/)|Alto acoplamento ao esquema legado e às tabelas internas. PRJ006-Termo-de-Abertura-de-Projeto.md+1|

Se o objetivo é eliminar CSV, evitar corrupção de acentuação e impedir novas falhas no AD, a API deve ser **read-only para o RH**, com endpoints orientados a domínio, por exemplo: `/workers`, `/workers/{employeeId}`, `/events/joiners`, `/events/movers`, `/events/leavers`. Isso preserva a soberania do sistema de RH e evita que o IGA “fale SQL” diretamente com um esquema legado sujeito a mudanças internas.PRJ006-Termo-de-Abertura-de-Projeto.md+3

## Contrato de identidade

O ponto mais crítico, do ponto de vista de governança, é formalizar antes do código um **Contrato de Identidade**. O documento fundacional do lab afirma que sem identificador canônico, autoridade de dados e estados compartilhados, a automação apenas amplifica ambiguidades. O diagnóstico DOC-ARC-001 também mostra que a falta dessa decisão já gerou duplicidade, perda de vínculo e sobrescritas indevidas entre sistemas.DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md+1

Os itens não negociáveis desse contrato são:

- **Identificador canônico:** `employeeId` como chave imutável de correlação fim a fim.DOC-ARC-000-Fundamentos-de-Decisao-em-Arquitetura-de-Identidade.md+1
    
- **Autoridade por atributo:** RH é soberano para nome, matrícula, departamento, cargo, gestor, status contratual e datas de admissão/desligamento.DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md+1
    
- **Mapa de estados:** valores do legado, como `termination_id` e equivalentes, devem ser traduzidos para estados de negócio inteligíveis ao midPoint, como `ACTIVE`, `INACTIVE`, `SUSPENDED`, `PENDING_LEAVER`.DOC-ARC-000-Fundamentos-de-Decisao-em-Arquitetura-de-Identidade.md+1
    
- **Direção de escrita:** RH -> API -> IGA -> targets; sem escrita reversa para o RH.PRJ005-Documento-de-Abertura-de-Projeto.md+1
    

## Padrão de desenvolvimento

O padrão mais recomendável aqui é **Hexagonal Architecture (Ports and Adapters) com Domain-Driven boundaries e Event/Change-driven synchronization**, porque separa regra de negócio, conectores e interfaces, facilitando auditoria, testes e manutenção por terceiros ou por IA. Em termos práticos, isso significa que o tratamento do legado MariaDB fica em um adapter de entrada, enquanto o contrato da API e as decisões JML ficam no domínio, não misturados em SQL, controller ou script ad-hoc.owasp+1DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md+1

Uma estrutura simples e auditável seria:

- `domain/`: regras JML, estados, políticas de correlação.
    
- `application/`: casos de uso `GetWorker`, `ListJoiners`, `DetectLeaver`.
    
- `adapters/inbound/api/`: controllers REST.
    
- `adapters/outbound/mariadb/`: consultas parametrizadas ao RH.
    
- `adapters/outbound/iga/`: integração com midPoint ou publicação de eventos.
    
- `observability/`: logs, métricas, tracing, health probes.
    
- `security/`: OAuth2, policies, mTLS interno, validações.
    

Esse desenho reduz “débito de decisão”, porque a semântica fica explícita em tipos, enums, testes e ADRs, em vez de escondida em scripts ou SQLs longos.DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md+1

## Encoding tratado na raiz

A correção de acentuação não deve ser “remendo no CSV”, mas política de arquitetura. Como a integração anterior já sofreu com corrupção de dados e encoding, a raiz do tratamento deve ser:

- Banco configurado com `utf8mb4` e collation consistente.
    
- Driver MariaDB/JDBC/ORM explicitamente configurado para UTF-8.
    
- API retornando `application/json; charset=utf-8`.
    
- Testes automatizados com nomes reais em português, como “João”, “Maíra”, “Gonçalves”, “São Paulo”.
    
- Proibição de conversões manuais de encoding no meio do fluxo, salvo em adapter isolado e testado.[PRJ005-Documento-de-Abertura-de-Projeto.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/1e672a9d-2677-461a-90ec-fcb1569ff5da/PRJ005-Documento-de-Abertura-de-Projeto.md)
    

Em outras palavras: **o domínio trabalha apenas com Unicode válido**; qualquer saneamento de legado acontece na borda de entrada, e qualquer serialização de saída acontece de forma determinística.[PRJ005-Documento-de-Abertura-de-Projeto.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/1e672a9d-2677-461a-90ec-fcb1569ff5da/PRJ005-Documento-de-Abertura-de-Projeto.md)

## Cadeia de custódia do código

Esse software deve nascer já com governança de cadeia de custódia, porque o contexto envolve identidades, segredos, AD e desenvolvimento assistido por IA. A diretriz correta é um **mono-repo ou repo dedicado por serviço**, com branch protection, commits assinados, revisão obrigatória e trilha de build imutável.devguide.owasp+1

## Estratégia de repositório

Estrutura mínima recomendada:

- `src/` código da API.
    
- `tests/` testes unitários, integração, contrato e segurança.
    
- `docs/adr/` decisões arquiteturais numeradas.
    
- `openapi/` contrato versionado.
    
- `infra/` Dockerfile, Compose, manifests, policies.
    
- `pipelines/` ou `.github/workflows/` CI/CD.
    
- `sbom/` artefatos de composição.
    
- `evidence/` relatórios de scan anexados à pipeline.
    

## Fluxo Git

O fluxo mais seguro aqui é **trunk-based com branches curtas + pull request obrigatório**, porque reduz desvio entre código e produção e melhora a inspeção contínua. Os gates mínimos devem ser:owasp+1

- PR com 2 olhos humanos quando houver mudança em segurança, auth, secrets ou mapeamento de identidade.
    
- Commits assinados.
    
- Branch protegida sem push direto.
    
- Merge bloqueado se qualquer teste ou scanner crítico falhar.
    
- Tag semântica para releases e changelog automático.
    

Para desenvolvimento com IA, o non-negotiable é: **todo código sugerido por IA entra como contribuição não confiável até passar pelos mesmos gates automáticos e revisão humana**.[owasp](https://owasp.org/www-project-devsecops-guideline/)

## CI/CD auditável

Nenhum código deve entrar em produção sem pipeline automática e reprodutível. A esteira deve validar desde o commit até a imagem final do container.devguide.owasp+1

## Sequência recomendada

1. **Pre-commit/local**
    

- Lint.
    
- Formatação.
    
- Unit tests rápidos.
    
- Secret scanning.
    
- Policy checks básicos.[owasp](https://owasp.org/www-project-devsecops-guideline/)
    

1. **Pull Request**
    

- SAST.
    
- SCA/dependency scanning.
    
- IaC scanning.
    
- Containerfile lint.
    
- Testes unitários.
    
- Testes de contrato OpenAPI.
    
- Testes de encoding/normalização.devguide.owasp+1
    

1. **Build**
    

- Geração de imagem imutável.
    
- SBOM.
    
- Assinatura do artefato.
    
- Scan de vulnerabilidades da imagem.[devguide.owasp](https://devguide.owasp.org/en/09-operations/01-devsecops/)
    

1. **Ambiente de homologação**
    

- Integration tests com MariaDB fake/mascarado.
    
- DAST contra ambiente efêmero.
    
- Testes de autenticação OAuth2 client credentials.
    
- Testes E2E JML.owasp+1
    

1. **Promoção para produção**
    

- Aprovação formal.
    
- Deploy automatizado.
    
- Verificação pós-deploy.
    
- Evidência arquivada do release.[owasp](https://owasp.org/www-project-devsecops-guideline/)
    

## Camadas de segurança

A OWASP API Security Top 10 destaca riscos centrais para APIs, como Broken Object Level Authorization, Broken Authentication e falhas de configuração, todos extremamente relevantes para dados de identidade. Para uma Shadow API JML, os controles indispensáveis são:owasp+1

- Autenticação forte para clientes máquina-a-máquina, preferencialmente OAuth 2.0 Client Credentials com escopos mínimos.owasp+1
    
- Autorização por função e por recurso, nunca apenas “autenticado = permitido”.[owasp](https://owasp.org/API-Security/editions/2023/en/0x11-t10/)
    
- Validação estrita de schema de entrada e saída.
    
- Queries parametrizadas e sem concatenação dinâmica.
    
- Idempotência em eventos de Joiner/Mover/Leaver.
    
- Rate limiting e proteção contra consumo abusivo.[owasp](https://owasp.org/API-Security/editions/2023/en/0x11-t10/)
    
- Audit log imutável sem expor segredo ou PII em excesso.[vault_implementation_guide_v3.0.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/0471c2c6-8dea-4ead-98e2-d48e0b5c821b/vault_implementation_guide_v3.0.md)[owasp](https://owasp.org/www-project-devsecops-guideline/)
    
- Hardening do container e da imagem base.
    
- TLS/mTLS em tráfego sensível dentro da malha privada, mesmo em VPN.
    

## Testes e momento na esteira

|Categoria|Objetivo|Momento ideal|
|---|---|---|
|Secret scanning|Impedir vazamento de credenciais no código. [owasp](https://owasp.org/www-project-devsecops-guideline/)|Pre-commit e PR|
|SAST|Encontrar padrões inseguros, auth falha, SQLi, validação insuficiente. owasp+1|PR|
|SCA|Detectar libs vulneráveis e licenças problemáticas. owasp+1|PR e build|
|IaC scanning|Validar Docker, Compose, manifests, policies e misconfigurations. [owasp](https://owasp.org/www-project-devsecops-guideline/)|PR|
|Container scanning|Ver CVEs da imagem final. [devguide.owasp](https://devguide.owasp.org/en/09-operations/01-devsecops/)|Build|
|Contract testing|Garantir que o OpenAPI e payloads permaneçam íntegros. [owasp](https://owasp.org/www-project-devsecops-guideline/)|PR e staging|
|Integration testing|Validar fluxo com banco e IGA. [PRJ005-Documento-de-Abertura-de-Projeto.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/1e672a9d-2677-461a-90ec-fcb1569ff5da/PRJ005-Documento-de-Abertura-de-Projeto.md)|Staging|
|DAST|Exercitar API rodando, headers, auth, enumeração, exposição indevida. owasp+1|Staging|
|Fuzzing/API security testing|Quebrar validações e schemas. [owasp](https://owasp.org/API-Security/editions/2023/en/0x11-t10/)|Staging/recorrente|
|E2E JML|Provar integridade ponta a ponta. DOC-ARC-000-Fundamentos-de-Decisao-em-Arquitetura-de-Identidade.md+1|Staging e pós-deploy|

Para aderência à ISO 27001, o essencial não é só “ter scanner”, mas **evidenciar controle, aprovação, tratamento de falhas e segregação de promoção**.[vault_implementation_guide_v3.0.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/0471c2c6-8dea-4ead-98e2-d48e0b5c821b/vault_implementation_guide_v3.0.md)[owasp](https://owasp.org/www-project-devsecops-guideline/)

## Gestão de segredos dinâmicos

As credenciais não devem existir em `.env`, compose commitado, imagem Docker ou variável fixa de longa duração. O guia interno do Vault já reforça hardening, service account sem shell, permissões restritas, audit log e escopo controlado. Para a aplicação, o ideal é que o segredo seja obtido em tempo de execução, com TTL curto e rotação simples.[developer.hashicorp](https://developer.hashicorp.com/vault/docs/auth/approle)[vault_implementation_guide_v3.0.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/0471c2c6-8dea-4ead-98e2-d48e0b5c821b/vault_implementation_guide_v3.0.md)

## Método mais seguro para container

Para aplicação máquina-a-máquina em container, o melhor método depende do orquestrador:

- **Kubernetes:** auth method nativo do Kubernetes é o mais forte, por ancorar a identidade da workload no service account do cluster.[oneuptime](https://oneuptime.com/blog/post/2026-02-02-vault-approle/view)
    
- **Docker/containers fora de Kubernetes:** **AppRole com SecretID de curta duração, entregue por mecanismo seguro no runtime, é o padrão mais robusto e apropriado**.[developer.hashicorp](https://developer.hashicorp.com/vault/docs/auth/approle)
    

A HashiCorp recomenda AppRole para automação e ainda recomenda uso de batch tokens com esse método. Na prática: o container autentica no Vault com identidade própria, recebe token efêmero, lê credencial dinâmica do banco e nunca persiste segredo em disco além do estritamente necessário.[vault_implementation_guide_v3.0.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/0471c2c6-8dea-4ead-98e2-d48e0b5c821b/vault_implementation_guide_v3.0.md)[developer.hashicorp](https://developer.hashicorp.com/vault/docs/auth/approle)

## Regras mínimas

- Nada de root token em aplicação.[vault_implementation_guide_v3.0.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/0471c2c6-8dea-4ead-98e2-d48e0b5c821b/vault_implementation_guide_v3.0.md)
    
- Role separada por serviço e ambiente.
    
- TTL curto para token e segredo.
    
- Rotação automática.
    
- Audit trail habilitado no Vault.[vault_implementation_guide_v3.0.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/0471c2c6-8dea-4ead-98e2-d48e0b5c821b/vault_implementation_guide_v3.0.md)
    
- Segredo injetado em memória ou arquivo efêmero montado pelo sidecar/agent, não em imagem.oneuptime+1
    

## Monitoramento e observabilidade

Health check que retorna apenas “200 OK” não serve para fluxo de identidade. O monitoramento precisa comprovar **disponibilidade, qualidade semântica e integridade transacional do encadeamento RH -> API -> IGA**.DOC-ARC-000-Fundamentos-de-Decisao-em-Arquitetura-de-Identidade.md+1

## Modelo recomendado

Separar em quatro níveis:

- **Liveness:** processo está vivo.
    
- **Readiness:** dependências essenciais estão acessíveis.
    
- **Dependency health:** MariaDB, Vault e endpoint do IGA respondem como esperado.
    
- **Business flow health:** um registro sintético ou conjunto de verificações comprova que Joiner/Mover/Leaver está fluindo sem perda de integridade.
    

## Métricas indispensáveis

- Latência por endpoint.
    
- Taxa de erro por tipo.
    
- Falhas de autenticação.
    
- Falhas de leitura do banco.
    
- Divergência entre contagem RH e contagem entregue à IGA.
    
- Eventos JML processados por período.
    
- Taxa de retries.
    
- Percentual de payloads rejeitados por schema.
    
- Número de caracteres inválidos ou normalizações aplicadas.
    
- Tempo entre evento de RH e visibilidade no IGA.[owasp](https://owasp.org/www-project-devsecops-guideline/)[PRJ005-Documento-de-Abertura-de-Projeto.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/1e672a9d-2677-461a-90ec-fcb1569ff5da/PRJ005-Documento-de-Abertura-de-Projeto.md)
    

## Controles de integridade fim a fim

Os mais importantes são:

- **Synthetic transactions** com colaborador de teste controlado.
    
- **Reconciliation job** periódico comparando RH, payload da API e objeto no IGA.
    
- **Checksum lógico** de atributos críticos por `employeeId`.
    
- **Alertas por desvio semântico**, por exemplo: funcionário desligado no RH ainda ativo no IGA após SLA definido.DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md+2
    

## Riscos críticos

Os riscos mais sérios desta implementação são:

- **Erro de correlação** por falta de identificador canônico estável, causando duplicidade ou sequestro de identidade.DOC-ARC-000-Fundamentos-de-Decisao-em-Arquitetura-de-Identidade.md+1
    
- **Autoridade de dados ambígua**, gerando sobrescrita indevida entre RH, IGA e AD.[DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/7749b546-19a0-490e-be2c-dc555467fda1/DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md)
    
- **Mapeamento incorreto de estados JML**, especialmente Leaver, com manutenção indevida de acesso.DOC-ARC-000-Fundamentos-de-Decisao-em-Arquitetura-de-Identidade.md+1
    
- **Exposição de credenciais** por uso inadequado de Vault ou segredos estáticos.[vault_implementation_guide_v3.0.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/0471c2c6-8dea-4ead-98e2-d48e0b5c821b/vault_implementation_guide_v3.0.md)
    
- **Falhas de autenticação/autorização em API**, alinhadas aos riscos OWASP API2 e API1.owasp+1
    
- **SQL injection e lógica insegura** se a API aceitar filtros dinâmicos sem parametrização.[owasp](https://owasp.org/www-project-devsecops-guideline/)
    
- **Corrupção de encoding**, que pode parecer detalhe técnico, mas quebra matching, atributos do AD e confiança na automação.[PRJ005-Documento-de-Abertura-de-Projeto.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/1e672a9d-2677-461a-90ec-fcb1569ff5da/PRJ005-Documento-de-Abertura-de-Projeto.md)
    
- **Falta de cadeia de custódia do código**, agravada por uso de IA sem gates rígidos.devguide.owasp+1
    

## Non-negotiables

Do ponto de vista de um Auditor de Segurança, estes são os não negociáveis:

- **Nada de scripts manuais como mecanismo operacional de produção.** Isso viola governança, rastreabilidade e o gatilho mestre do workspace.[DOC-ARC-000-Fundamentos-de-Decisao-em-Arquitetura-de-Identidade.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/b6287d04-0f10-45dc-8fc8-d840ac819d81/DOC-ARC-000-Fundamentos-de-Decisao-em-Arquitetura-de-Identidade.md)
    
- **Nada de conexão direta do IGA ao banco legado como solução definitiva.**PRJ006 - Relatório de Encerramento de Projeto (Post-Mortem).md+1
    
- **`employeeId` como identificador canônico imutável.**DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md+1
    
- **OrangeHRM como fonte autoritativa de RH, sem escrita reversa.**PRJ005-Documento-de-Abertura-de-Projeto.md+1
    
- **OAuth 2.0 Client Credentials na API e identidade de workload no Vault.**owasp+1
    
- **Segredos apenas via Vault, com TTL, rotação e audit log.**[developer.hashicorp](https://developer.hashicorp.com/vault/docs/auth/approle)[vault_implementation_guide_v3.0.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/0471c2c6-8dea-4ead-98e2-d48e0b5c821b/vault_implementation_guide_v3.0.md)
    
- **UTF-8/utf8mb4 fim a fim com testes automatizados de acentuação.**[PRJ005-Documento-de-Abertura-de-Projeto.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/1e672a9d-2677-461a-90ec-fcb1569ff5da/PRJ005-Documento-de-Abertura-de-Projeto.md)
    
- **PR obrigatório, branch protegida, scans automáticos e bloqueio de merge em falha.**devguide.owasp+1
    
- **SBOM, scan de dependências e imagem assinada antes de produção.**[devguide.owasp](https://devguide.owasp.org/en/09-operations/01-devsecops/)
    
- **Observabilidade com health técnico e health de negócio JML.**DOC-ARC-000-Fundamentos-de-Decisao-em-Arquitetura-de-Identidade.md+1
    
- **Leaver com prioridade máxima e revogação imediata baseada em estado formal.**DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md+1
    

## Veredito

O risco desta implementação é **alto se tratada como integração técnica simples**, mas **controlável e aceitável** se for conduzida como projeto de governança de identidade com Shadow API, contrato canônico, Vault, OAuth2, pipeline DevSecOps e observabilidade de negócio. Se eu estivesse atuando como comitê, eu aprovaria o desenho **somente** com esses não negociáveis formalizados em ADR, OpenAPI, testes automatizados e gates de promoção; sem isso, a probabilidade de repetir corrupção de dados, falhas no Leaver e inconsistências no AD permanece materialmente alta.[PRJ006 - Relatório de Encerramento de Projeto (Post-Mortem).md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/ffa4a527-3e94-4c4e-bdfd-9235e7fe81e9/PRJ006-Relatorio-de-Encerramento-de-Projeto-Post-Mortem.md)[owasp](https://owasp.org/www-project-devsecops-guideline/)DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md+1

Se quiser, no próximo passo eu posso transformar este parecer em um **documento executivo de arquitetura com blueprint alvo, fluxograma, RACI e matriz de controles ISO 27001:2022**.




## RESPOSTA DO MANUS

Excelentíssimo Comitê. Este é um cenário clássico de modernização com alto risco de segurança. Após análise das restrições e do ambiente apresentado, seguem o parecer técnico e as diretrizes para aprovação do projeto.

---

### 1. Arquitetura de Integração: API Intermediária vs. Conexão Direta

**Veredito:** **API Intermediária (RESTful) obrigatória.** Conexão direta (JDBC/ODBC) do IGA ao MariaDB é **proibida**.

**Justificativa Técnica:**
- **Segurança:** Conexão direta expõe portas do banco, exige credenciais estáticas no IGA e ignora o Vault. A API permite aplicar o *Princípio do Menor Privilégio* (usuário da API tem `SELECT` apenas em *views* específicas, não nas tabelas brutas).
- **Integridade de Caracteres:** O IGA pode interpretar errado o `charset` do MariaDB (latin1 vs utf8mb4). A API força a normalização para **UTF-8** (RFC 8259) na saída, resolvendo o encoding na raiz. O CSV corrompia porque o Windows e o Linux divergiam no BOM e no ISO-8859-1.
- **Rastreabilidade:** A API gera logs de *quem* (token do IGA), *o quê* (query) e *quando*. Conexão direta é uma caixa preta.

**Arquitetura Recomendada:**
`[MariaDB (Legado)] <-- TLS --> [API Gateway + Serviço em Go/Python] <-- mTLS --> [IGA]`
- O serviço intermediário consulta o banco através de *materialized views* ou *read replicas* para não impactar o RH.

### 2. Padrões de Desenvolvimento

**Padrão:** **Hexagonal (Ports & Adapters) + DTOs imutáveis.**

- **Maximizar Auditabilidade:** Cada *Adapter* de entrada (REST) e saída (MariaDB, Vault, IGA) deve implementar a interface `Auditable`. Cada requisição gera um `Correlation ID` persistido em log estruturado (JSON).
- **Facilidade para IA/Terceiros:** Use **OpenAPI 3.0** (contrato primeiro). IAs leem especificações YAML melhor que código. Nomes de funções devem ser verbos no imperativo: `FetchUserIdentities()`.

**Tratamento de Encoding na Raiz:**
1.  **Força bruta:** Ao conectar ao MariaDB, execute `SET NAMES 'utf8mb4'`.
2.  **Interceptor:** Um middleware na API que rejeita qualquer *payload* ou *response* com sequências UTF-8 inválidas (ataque de *overlong encoding*).
3.  **Normalização:** Use NFC (Normalization Form Canonical) para acentos. Ex: `é` deve ser U+00E9, não U+0065 + U+0301.

### 3. Cadeia de Custódia do Código

**Repositório:** Monorepo (`/integration-hub`) com pastas: `/api`, `/migrations`, `/scripts`, `/deploy`.

**Fluxo Git (GitHub Flow + Proteção):**
- `main` (produção) → bloqueada, sem push direto.
- `develop` (validação) → obrigatório.
- `feature/*` → origem.

**Esteira CI/CD (GitHub Actions/GitLab CI):**
1.  **Commit:** Linter (Segurança + Formatação).
2.  **PR para `develop`:** SAST (Semgrep) + SCA (Trivy) + Testes Unitários.
3.  **Merge para `main`:** Build da imagem Docker (assinar com Cosign), DAST (ZAP) em ambiente de staging, validação de encoding (injetar `café com pão` e verificar saída).
4.  **Deploy:** Apenas com *approval* manual via OIDC (sem credenciais hardcoded).

### 4. Camadas de Segurança (DevSecOps) e ISO 27001

**Controles Indispensáveis para a API:**
- **Rate Limiting** (evita scraping de identidades).
- **mTLS** (IGA só conecta se apresentar certificado válido).
- **JWT com curta duração (15 min)** + refresh token rotativo.
- **Content-Type fixo:** `application/json; charset=utf-8`.

**Categorias de Testes na Esteira (ISO 27001 A.14.2):**

| Teste | Ferramenta | Momento | Critério de Falha |
| :--- | :--- | :--- | :--- |
| **SAST** | Semgrep / CodeQL | Ao criar PR | Bloqueia merge se achar SQL injection ou logging de senha |
| **SCA** | Trivy / Snyk | Na build da imagem | Falha se vulnerabilidade `CRITICAL` em lib HTTP |
| **Secrets** | TruffleHog | Pre-commit hook | Impede commit se achar `vault.*token` |
| **DAST** | OWASP ZAP | Após deploy em staging | Falha se achar `CORS: *` ou falta de `HttpOnly` |
| **Fuzzing** | go-fuzz / radamsa | Semanal (offline) | Identifica crash por encoding malicioso |

### 5. Gestão de Segredos Dinâmicos

**Interação com Vault (Hashicorp Vault):**
- A aplicação **NUNCA** lê credenciais estáticas.
- **Método mais seguro para container:** **JWT OIDC Autenticação via Workload Identity**.
    - *Como funciona:* O container não tem senha. O orquestrador (Nomad/K8s) prova ao Vault que o pod é legítimo via um token de serviço assinado. O Vault gera um token efêmero (TTL = 1 hora) para a API acessar o MariaDB.
- **Evitar vazamento:** O segredo é injetado via variável de ambiente **só na inicialização** (um init container) e nunca persiste em volume. A aplicação pede renovação antes do TTL expirar.

### 6. Monitoramento e Observabilidade

Projetar saúde funcional, não apenas sintática (ping/pong).

**Métrica de Integridade do Fluxo: "Lantência de Propagação"**
1.  **Source (RH):** Hash (MD5) do registro completo (nome + CPF + cargo) no campo `row_hash` da view.
2.  **API:** Expõe endpoint `GET /v1/health/integrity`. Ele consulta o último hash enviado ao IGA e compara com o hash atual no banco.
3.  **Alerta:** Se o hash mudou no RH, mas o IGA não confirmou recepção (webhook) após 15 min → Alerta de **Data Drift**.

**Logs:** Todo log deve conter `correlation_id`, `source_system`, `row_count` e `encoding_validated: true`.

### 7. Veredito do Auditor de Segurança (Non-Negotiables)

**Riscos Críticos:**
1.  **Buffer Overflow no parser CSV (se usado ainda):** Descartem CSV. Isso corrompeu dados por encoding e ainda expõe a RCE.
2.  **Credencial no código-fonte:** Mesmo no Vault, se a aplicação pedir senha em texto plano, o ataque é trivial.
3.  **Time-of-check to time-of-use (TOCTOU):** Se a API consultar o banco e o IGA processar 5 seg depois, o RH pode ter mudado. Sem o hash de integridade, vocês nunca saberão.

**Non-Negotiables (Pare imediatamente se faltar):**
1.  **Nunca exponha o MariaDB diretamente para o IGA.**
2.  **Nunca permita `SELECT *` no código. Exija `SELECT campo, campo2, MD5(concat(...))`.**
3.  **Todo commit deve passar pelo pre-commit hook que rejeita qualquer caractere não-ASCII não-normalizado.**
4.  **A pipeline de CI/CD deve falhar se a imagem base do container (Ubuntu:latest) tiver vulnerabilidades conhecidas (CVE). Use `distroless` ou `alpine`.**
5.  **Logs de auditoria (quem leu quais dados) devem ser imutáveis e enviados para um bucket S3 separado (não apenas stdout do container).**

**Conclusão:** Aprovado com a condição de que o Comitê implemente **obrigatoriamente** a API em Go (por segurança de memória e tratamento nativo de UTF-8) ou Rust, e nunca em Python com pandas (histórico de falhas de encoding em CSVs). A integridade do caractere e a cadeia de custódia definem o sucesso.


RESPOSTA DO DEEP SEEK

Excelentíssimo Comitê. Este é um cenário clássico de modernização com alto risco de segurança. Após análise das restrições e do ambiente apresentado, seguem o parecer técnico e as diretrizes para aprovação do projeto.

---

### 1. Arquitetura de Integração: API Intermediária vs. Conexão Direta

**Veredito:** **API Intermediária (RESTful) obrigatória.** Conexão direta (JDBC/ODBC) do IGA ao MariaDB é **proibida**.

**Justificativa Técnica:**
- **Segurança:** Conexão direta expõe portas do banco, exige credenciais estáticas no IGA e ignora o Vault. A API permite aplicar o *Princípio do Menor Privilégio* (usuário da API tem `SELECT` apenas em *views* específicas, não nas tabelas brutas).
- **Integridade de Caracteres:** O IGA pode interpretar errado o `charset` do MariaDB (latin1 vs utf8mb4). A API força a normalização para **UTF-8** (RFC 8259) na saída, resolvendo o encoding na raiz. O CSV corrompia porque o Windows e o Linux divergiam no BOM e no ISO-8859-1.
- **Rastreabilidade:** A API gera logs de *quem* (token do IGA), *o quê* (query) e *quando*. Conexão direta é uma caixa preta.

**Arquitetura Recomendada:**
`[MariaDB (Legado)] <-- TLS --> [API Gateway + Serviço em Go/Python] <-- mTLS --> [IGA]`
- O serviço intermediário consulta o banco através de *materialized views* ou *read replicas* para não impactar o RH.

### 2. Padrões de Desenvolvimento

**Padrão:** **Hexagonal (Ports & Adapters) + DTOs imutáveis.**

- **Maximizar Auditabilidade:** Cada *Adapter* de entrada (REST) e saída (MariaDB, Vault, IGA) deve implementar a interface `Auditable`. Cada requisição gera um `Correlation ID` persistido em log estruturado (JSON).
- **Facilidade para IA/Terceiros:** Use **OpenAPI 3.0** (contrato primeiro). IAs leem especificações YAML melhor que código. Nomes de funções devem ser verbos no imperativo: `FetchUserIdentities()`.

**Tratamento de Encoding na Raiz:**
1.  **Força bruta:** Ao conectar ao MariaDB, execute `SET NAMES 'utf8mb4'`.
2.  **Interceptor:** Um middleware na API que rejeita qualquer *payload* ou *response* com sequências UTF-8 inválidas (ataque de *overlong encoding*).
3.  **Normalização:** Use NFC (Normalization Form Canonical) para acentos. Ex: `é` deve ser U+00E9, não U+0065 + U+0301.

### 3. Cadeia de Custódia do Código

**Repositório:** Monorepo (`/integration-hub`) com pastas: `/api`, `/migrations`, `/scripts`, `/deploy`.

**Fluxo Git (GitHub Flow + Proteção):**
- `main` (produção) → bloqueada, sem push direto.
- `develop` (validação) → obrigatório.
- `feature/*` → origem.

**Esteira CI/CD (GitHub Actions/GitLab CI):**
1.  **Commit:** Linter (Segurança + Formatação).
2.  **PR para `develop`:** SAST (Semgrep) + SCA (Trivy) + Testes Unitários.
3.  **Merge para `main`:** Build da imagem Docker (assinar com Cosign), DAST (ZAP) em ambiente de staging, validação de encoding (injetar `café com pão` e verificar saída).
4.  **Deploy:** Apenas com *approval* manual via OIDC (sem credenciais hardcoded).

### 4. Camadas de Segurança (DevSecOps) e ISO 27001

**Controles Indispensáveis para a API:**
- **Rate Limiting** (evita scraping de identidades).
- **mTLS** (IGA só conecta se apresentar certificado válido).
- **JWT com curta duração (15 min)** + refresh token rotativo.
- **Content-Type fixo:** `application/json; charset=utf-8`.

**Categorias de Testes na Esteira (ISO 27001 A.14.2):**

| Teste | Ferramenta | Momento | Critério de Falha |
| :--- | :--- | :--- | :--- |
| **SAST** | Semgrep / CodeQL | Ao criar PR | Bloqueia merge se achar SQL injection ou logging de senha |
| **SCA** | Trivy / Snyk | Na build da imagem | Falha se vulnerabilidade `CRITICAL` em lib HTTP |
| **Secrets** | TruffleHog | Pre-commit hook | Impede commit se achar `vault.*token` |
| **DAST** | OWASP ZAP | Após deploy em staging | Falha se achar `CORS: *` ou falta de `HttpOnly` |
| **Fuzzing** | go-fuzz / radamsa | Semanal (offline) | Identifica crash por encoding malicioso |

### 5. Gestão de Segredos Dinâmicos

**Interação com Vault (Hashicorp Vault):**
- A aplicação **NUNCA** lê credenciais estáticas.
- **Método mais seguro para container:** **JWT OIDC Autenticação via Workload Identity**.
    - *Como funciona:* O container não tem senha. O orquestrador (Nomad/K8s) prova ao Vault que o pod é legítimo via um token de serviço assinado. O Vault gera um token efêmero (TTL = 1 hora) para a API acessar o MariaDB.
- **Evitar vazamento:** O segredo é injetado via variável de ambiente **só na inicialização** (um init container) e nunca persiste em volume. A aplicação pede renovação antes do TTL expirar.

### 6. Monitoramento e Observabilidade

Projetar saúde funcional, não apenas sintática (ping/pong).

**Métrica de Integridade do Fluxo: "Lantência de Propagação"**
1.  **Source (RH):** Hash (MD5) do registro completo (nome + CPF + cargo) no campo `row_hash` da view.
2.  **API:** Expõe endpoint `GET /v1/health/integrity`. Ele consulta o último hash enviado ao IGA e compara com o hash atual no banco.
3.  **Alerta:** Se o hash mudou no RH, mas o IGA não confirmou recepção (webhook) após 15 min → Alerta de **Data Drift**.

**Logs:** Todo log deve conter `correlation_id`, `source_system`, `row_count` e `encoding_validated: true`.

### 7. Veredito do Auditor de Segurança (Non-Negotiables)

**Riscos Críticos:**
1.  **Buffer Overflow no parser CSV (se usado ainda):** Descartem CSV. Isso corrompeu dados por encoding e ainda expõe a RCE.
2.  **Credencial no código-fonte:** Mesmo no Vault, se a aplicação pedir senha em texto plano, o ataque é trivial.
3.  **Time-of-check to time-of-use (TOCTOU):** Se a API consultar o banco e o IGA processar 5 seg depois, o RH pode ter mudado. Sem o hash de integridade, vocês nunca saberão.

**Non-Negotiables (Pare imediatamente se faltar):**
1.  **Nunca exponha o MariaDB diretamente para o IGA.**
2.  **Nunca permita `SELECT *` no código. Exija `SELECT campo, campo2, MD5(concat(...))`.**
3.  **Todo commit deve passar pelo pre-commit hook que rejeita qualquer caractere não-ASCII não-normalizado.**
4.  **A pipeline de CI/CD deve falhar se a imagem base do container (Ubuntu:latest) tiver vulnerabilidades conhecidas (CVE). Use `distroless` ou `alpine`.**
5.  **Logs de auditoria (quem leu quais dados) devem ser imutáveis e enviados para um bucket S3 separado (não apenas stdout do container).**

**Conclusão:** Aprovado com a condição de que o Comitê implemente **obrigatoriamente** a API em Go (por segurança de memória e tratamento nativo de UTF-8) ou Rust, e nunca em Python com pandas (histórico de falhas de encoding em CSVs). A integridade do caractere e a cadeia de custódia definem o sucesso.


### RESPOSTA DA CLAUDE

Aqui está o parecer técnico completo do Comitê de Governança e Arquitetura de TI.

---

## Parecer Técnico — Integração HR-DB → API → IGA

---

### 1. Arquitetura de integração

A abordagem recomendada é uma **API intermediária dedicada** (não conexão direta do IGA ao banco legado), por razões que vão além de conveniência: trata-se de um controle de segurança estrutural.

Uma conexão direta do midPoint (ou qualquer IGA) ao MariaDB de produção cria acoplamento entre dois sistemas com ciclos de vida distintos, expõe o schema interno do RH a uma ferramenta terceira, e impossibilita auditoria granular de cada consulta. Qualquer mudança de schema do RH quebraria silenciosamente o IGA.

A API intermediária funciona como um **Anti-Corruption Layer**: ela traduz o modelo de dados do RH para o vocabulário de identidades (atributos SCIM), abstrai o banco, e é o único ponto onde a questão de encoding é tratada — de forma explícita e controlada. O IGA nunca "vê" o banco; ele vê apenas um endpoint SCIM-compliant com dados normalizados.

Para o problema de encoding especificamente, a raiz deve ser atacada na camada de conexão com o banco: a string de conexão MariaDB deve forçar `charset=utf8mb4&collation=utf8mb4_unicode_ci`. A API recebe bytes, converte para string Python/Java com codec explícito, e serializa para JSON com `ensure_ascii=False`. Não há CSV, não há pipeline de arquivos — o problema de acentuação desaparece por design.

---

### 2. Padrões de desenvolvimento

O padrão recomendado é **Ports and Adapters (Hexagonal Architecture)**, que maximiza auditabilidade e facilita manutenção por terceiros (incluindo IAs que lerão o código).

A estrutura conceitual é:

- `domain/` — lógica de negócio pura (mapeamento de atributos HR → SCIM, regras de normalização). Sem dependência de framework.
- `ports/` — interfaces abstratas: `IHRRepository`, `IIdentityPublisher`.
- `adapters/inbound/` — controladores HTTP (FastAPI/Flask). Recebem requisições SCIM.
- `adapters/outbound/` — implementações concretas: `MariaDBHRAdapter`, `MidPointSCIMAdapter`.
- `infrastructure/` — configuração, injeção de dependência, segredos.

Para encoding: toda string que sai do adapter de banco deve passar por uma função `normalize_identity_string(raw: str) -> str` centralizada, que aplica `unicodedata.normalize('NFC', raw)` e sanitiza caracteres de controle. Isso é testado unitariamente de forma isolada — qualquer regressão de encoding quebra o CI antes de tocar produção.

Cada função deve ter docstring com: propósito, parâmetros tipados, exceções esperadas, e um exemplo de input/output. Isso não é burocracia — é o que permite que uma IA (ou um novo membro do time) entenda o contrato sem ler o código interno.

---

### 3. Cadeia de custódia do código**Estratégia de repositório:** monorepo com estrutura `src/`, `tests/`, `infra/`, `docs/`. Branches protegidas: `main` (merge só via PR com 2 aprovações) e `release/v*` (só via CD automatizado). Commits devem seguir Conventional Commits (`feat:`, `fix:`, `security:`) — isso alimenta o CHANGELOG automaticamente e é auditável.

**Regra inviolável:** nenhum segredo em repositório. `.gitignore` inclui `*.env`, `*.key`, `vault_token`. Pre-commit hook com `detect-secrets` bloqueia o commit localmente antes de chegar ao servidor.

---

### 4. Camadas de segurança (DevSecOps)

As categorias de teste mapeadas à ISO 27001 (especificamente A.14 — Aquisição, Desenvolvimento e Manutenção de Sistemas):

**SAST (Static Application Security Testing)** — atua no PR, antes do merge. Ferramentas: Bandit (Python), Semgrep com ruleset OWASP. Bloqueia qualquer finding de severidade crítica ou alta. Controla: injection, hardcoded secrets, uso inseguro de crypto.

**SCA (Software Composition Analysis)** — atua junto ao SAST. Ferramentas: `pip-audit`, Trivy para dependências. Bloqueia CVEs com CVSS >= 7.0 nas dependências diretas e transitivas. Evita o cenário em que uma biblioteca do ORM introduz uma vulnerabilidade conhecida.

**Container Image Scanning** — atua no build da imagem Docker. Trivy ou Grype varrem a imagem final (OS packages + libs Python). A imagem base deve ser `python:3.12-slim` ou `distroless` — não `ubuntu` ou `debian` completos.

**DAST (Dynamic Application Security Testing)** — atua em staging, com a API rodando. OWASP ZAP em modo automatizado executa testes de: SQL Injection via parâmetros SCIM, autenticação quebrada, exposição de dados sensíveis em respostas de erro. Não é possível executar DAST em CI puro — exige um ambiente vivo.

**Secrets Scanning** — em todo push, via `git-secrets` ou `gitleaks`. É a última linha de defesa antes do código chegar ao servidor remoto.

**Testes de encoding** — categoria própria, executada como parte do unit test suite. Cada fixture de teste deve incluir strings com: acentos compostos (ã, ç, é), caracteres de controle (U+0000–U+001F), surrogates inválidos, e strings em NFD vs NFC. A função de normalização deve ser 100% coberta por esses casos.

---

### 5. Gestão de segredos dinâmicos

A API nunca deve possuir credenciais estáticas. O padrão correto para um container em ambiente Docker/Linux com Vault é **AppRole Authentication** combinado com **Dynamic Secrets**.

O fluxo é: o container obtém um `role_id` (não secreto, pode estar no environment) e um `secret_id` (injetado em runtime pelo orchestrator, com TTL de 60s). Com esses dois fatores, autentica no Vault e recebe um token de curta duração (TTL de 1 hora, renovável). Com esse token, solicita ao Vault uma **credencial dinâmica** para o MariaDB — o Vault cria um usuário temporário no banco, com permissões mínimas (SELECT nas tabelas de RH apenas), que expira junto com a lease.

O que isso resolve: mesmo que o container seja comprometido, o atacante tem credenciais de banco que expiram em horas, não acesso permanente. O `secret_id` de AppRole é de uso único — após o bootstrap, não existe mais.

O código da API deve usar um **Vault Agent** como sidecar ou implementar um cliente que renova o token automaticamente antes do TTL expirar (renovação a 75% do TTL). Nunca cachear o token em disco — apenas em memória do processo.

Para o caso do Living Lab com Vault OSS: implementar `vault agent` como processo no host, que escreve o token em `tmpfs` (`/dev/shm/vault_token`) e o renova automaticamente. O container monta o `tmpfs` como volume read-only.

---

### 6. Monitoramento e observabilidade

Saúde de API não é `HTTP 200`. Para um pipeline de identidade, o que importa é a **integridade do fluxo de dados de ponta a ponta**. O sistema de monitoramento deve ter três camadas:

**Camada 1 — Health checks estruturados.** O endpoint `/health` deve retornar um payload com: status da conexão ao banco (latência p99), status da conectividade ao endpoint SCIM do IGA, versão do schema em uso, e timestamp do último job de sync bem-sucedido. Um healthcheck que retorna apenas `{"status": "ok"}` é inútil para auditoria.

**Camada 2 — Data integrity probes.** Um job agendado (a cada 15 minutos) executa uma verificação de consistência: conta os registros ativos no RH, conta os identities correspondentes no IGA, e publica a diferença como métrica (`iga_sync_delta_count`). Um delta persistente acima de zero por mais de 2 ciclos dispara alerta — não é falha de disponibilidade, é falha de integridade, que é mais grave para um sistema IGA.

**Camada 3 — Audit log imutável.** Cada operação (leitura de identidade, criação/atualização no IGA, erro de normalização) deve gerar um log estruturado em JSON com: `timestamp` (ISO 8601 com timezone), `correlation_id` (UUID por requisição), `operation`, `entity_id` (employeeID), `source_checksum` (hash dos dados lidos), `target_checksum` (hash dos dados escritos), e `status`. Logs devem ser enviados para um destino externo (syslog, Loki, ou arquivo em volume separado) — nunca apenas `stdout` de container sem coleta.

Para o lab: Prometheus com exportador customizado para as métricas de sync, Grafana para dashboards, e Loki para os logs de auditoria. O dashboard mínimo deve mostrar: delta de identidades, taxa de erro de normalização, e latência do ciclo completo HR→API→IGA.

---

### Veredito — Riscos críticos e Non-Negotiables**Veredito do Auditor:**

Os dois riscos críticos têm natureza diferente dos demais: eles não são riscos de implementação incorreta — são riscos de arquitetura ausente. Se a API entrar em produção com credenciais estáticas ou sem autenticação entre camadas, nenhum dos controles dos demais níveis importa. A superfície de ataque é irremediável sem redesign.

O risco de encoding é insidioso porque não falha ruidosamente: ele introduz corrupção silenciosa que só é descoberta quando um usuário não consegue fazer login com seu próprio nome. Em um sistema IGA, isso tem impacto operacional imediato.

O risco de código gerado por IA merece atenção especial no contexto declarado do projeto. IAs (incluindo esta) são excelentes para estrutura e boilerplate, mas geram padrões inseguros conhecidos: concatenação de strings em queries SQL, logging de dados sensíveis, tratamento de exceções que vaza stacktraces com informações internas. O SAST obrigatório em todo PR não é desconfiança da IA — é o mesmo controle que se aplica a qualquer desenvolvedor humano.

Os **Non-Negotiables absolutos**, do ponto de vista de auditoria ISO 27001:

1. Nenhum segredo em repositório ou variável de ambiente de container — apenas injeção via Vault em runtime.
2. mTLS entre todos os componentes na rede interna (IGA ↔ API ↔ DB).
3. Princípio do menor privilégio no banco: a API tem acesso apenas às tabelas necessárias, com credenciais que expiram.
4. Toda operação de identidade é logada com correlation ID e checksum dos dados, em destino externo ao container.
5. Nenhum código entra em produção sem SAST automatizado — especialmente código gerado por IA.
6. Testes de encoding como cidadãos de primeira classe no suite de testes, bloqueando o CI em caso de falha.
   
   
   
   
   # STACK
   
   
   Foi realizada uma segunda rodada de peer review 
   
   > Atue como um Consultor de Tecnologia e Arquiteto de Software. O objetivo é selecionar a **Stack Tecnológica** para o desenvolvimento da **Shadow API (PRJ008)**. Esta API servirá de ponte entre um banco MariaDB (OrangeHRM) e uma solução de IGA (midPoint).
> 
> **Restrições e Critérios do Living Lab:**
> 
> 1. **Recursos de Hardware:** O ambiente roda em VMs Ubuntu 24.04 (Dockerizado). É necessário eficiência no consumo de memória e CPU.
>     
> 2. **Custo:** Preferência absoluta por ferramentas **Open Source** (Free Tier ou Community Edition).
>     
> 3. **Modernização:** A stack deve refletir as tecnologias mais adotadas e promissoras do mercado atual (2024-2026), visando valorização profissional e facilidade de manutenção assistida por IA.
>     
> 4. **Segurança (Core):** Deve haver suporte nativo ou via biblioteca madura para integração com **HashiCorp Vault** e tratamento rigoroso de **Unicode/UTF-8**.
>     
> 5. **Auditabilidade:** O código deve ser legível para auditoria e suportar logs estruturados.
>     
> 
> **Solicitação de Parecer Técnico:**
> 
> 6. **Linguagem e Framework:** Qual dupla de Linguagem + Framework você recomenda? Justifique comparando performance, curva de aprendizado e suporte de bibliotecas para IAM/API.
>     
> 7. **ORM / Acesso a Dados:** Qual padrão de acesso ao banco de dados (ORM ou Query Builder) garante maior proteção contra SQL Injection e melhor performance em ambientes de container?
>     
> 8. **Servidor de Aplicação / Web Server:** Qual a recomendação para o ambiente de produção em Docker (ex: Uvicorn, Gunicorn, etc.)?
>     
> 9. **Testes e Qualidade:** Indique ferramentas agnósticas para Unit Testing e Mocking de dados que se integrem bem a esteiras de CI/CD.
>     
> 10. **Documentação de API:** Qual padrão de documentação automática deve ser adotado para que o IGA (midPoint) consiga consumir o contrato sem ambiguidades?
>     
> 11. **Integração com Vault:** Qual o método mais leve e seguro para que esta stack específica consuma segredos do Vault em runtime?
>     
> 
> **Veredito de Valor:** Por que esta stack, em detrimento de outras (ex: Java/Spring, Node.js ou Go), é a mais equilibrada para um **profissional de Segurança/IAM** que busca fortalecer autoridade e agilidade em um laboratório pessoal?
> 
> 

RESPOSTA CHATGPT 

Apresento o parecer técnico com foco em eficiência operacional, segurança por design e alinhamento com práticas consolidadas (ISO/IEC 27001, NIST SP 800-53, OWASP ASVS, CIS Controls).

---

# 1) Linguagem e Framework

## 🏆 Recomendação Principal

**Python + FastAPI**

---

## Justificativa Técnica

### ✔ Performance

- Baseado em ASGI (alta concorrência)
    
- Performance próxima a Node.js e Go em I/O-bound
    
- Muito eficiente em containers leves
    

### ✔ Segurança

- Forte integração com padrões OWASP
    
- Suporte maduro para:
    
    - OAuth2
        
    - OpenID Connect
        
    - JWT
        
- Bibliotecas robustas para Vault (ex: `hvac`)
    

### ✔ Produtividade e IA

- Python é dominante em ferramentas de IA
    
- Código altamente legível → excelente auditabilidade (ISO 27001 A.8.15)
    

### ✔ Unicode/UTF-8

- UTF-8 nativo por padrão → reduz drasticamente risco de corrupção
    

---

## Comparativo

|Stack|Vantagens|Desvantagens|
|---|---|---|
|**Python + FastAPI**|Simples, rápido, moderno, ótimo para APIs|CPU-bound inferior ao Go|
|Java + Spring Boot|Robusto, padrão corporativo|Alto consumo de memória|
|Node.js + NestJS|Popular, async nativo|Complexidade de dependências|
|Go + Gin/Fiber|Extremamente performático|Menor ecossistema IAM|

---

# 2) ORM / Acesso a Dados

## 🏆 Recomendação: SQLAlchemy (Core + ORM híbrido)

---

## Estratégias

### Opção A — ORM completo

- ✔ Segurança contra SQL Injection
    
- ✔ Abstração elevada
    
- ❌ Overhead de performance
    

---

### Opção B — Query Builder (Recomendado)

- SQLAlchemy Core
    
- ✔ Melhor performance
    
- ✔ Controle explícito de queries
    
- ✔ Proteção contra SQL Injection via bind parameters
    

---

### Opção C — Driver puro (ex: asyncmy)

- ✔ Máxima performance
    
- ❌ Alto risco de erro humano
    

---

## Recomendação Final

- **SQLAlchemy Core + validação com Pydantic**
    
- Sempre usar **queries parametrizadas**
    

---

# 3) Servidor de Aplicação

## 🏆 Recomendação

- **Uvicorn + Gunicorn**
    

---

## Arquitetura

```bash
gunicorn -k uvicorn.workers.UvicornWorker
```

---

## Justificativa

- Uvicorn → alto desempenho (async)
    
- Gunicorn → gerenciamento de workers
    
- Ideal para Docker (resiliência + escalabilidade)
    

---

# 4) Testes e Qualidade

## Ferramentas recomendadas

### ✔ Unit Testing

- **pytest**
    
- Simples, poderoso, padrão de mercado
    

---

### ✔ Mocking

- **pytest-mock**
    
- Integração nativa com pytest
    

---

### ✔ Testes de API

- HTTPX (async testing)
    

---

### ✔ Qualidade de código

- Ruff (lint)
    
- MyPy (tipagem estática)
    
- Bandit (SAST básico)
    

---

## Integração CI/CD

- GitHub Actions / GitLab CI
    
- Gates obrigatórios:
    
    - Test coverage ≥ 80%
        
    - Zero vulnerabilidades críticas
        

---

# 5) Documentação de API

## 🏆 Padrão: OpenAPI 3.1

### Implementação

- Nativo no FastAPI
    
- Swagger UI automático
    

---

## Benefícios

- Integração direta com IGA (midPoint)
    
- Contrato versionado
    
- Redução de ambiguidades
    

---

## Alternativa

- SCIM 2.0 (recomendado para identidade)
    

---

# 6) Integração com Vault

## 🏆 Estratégia Recomendada: AppRole + hvac

---

## Fluxo

1. Container inicia
    
2. Autentica no Vault via AppRole
    
3. Recebe token temporário (TTL curto)
    
4. Busca credenciais dinâmicas
    

---

## Alternativas

### Opção A — AppRole

- ✔ Simples
    
- ✔ Leve
    
- ❌ Gestão de SecretID
    

---

### Opção B — JWT/OIDC

- ✔ Mais seguro (sem segredo fixo)
    
- ❌ Mais complexo
    

---

### Opção C — Sidecar Vault Agent (Recomendado em produção madura)

- ✔ Rotação automática
    
- ✔ Zero exposição no código
    
- ❌ Overhead operacional
    

---

# 7) Observabilidade e Logs

## Padrão

- Logs estruturados (JSON)
    
- Biblioteca: structlog ou loguru
    

---

## Integração

- OpenTelemetry
    
- Prometheus + Grafana
    

---

# 8) Veredito de Valor

## Por que Python + FastAPI é a melhor escolha?

### 🎯 Para Segurança/IAM

- Forte alinhamento com:
    
    - OWASP
        
    - APIs modernas (REST/SCIM)
        
- Facilidade de auditoria (código legível)
    
- Ecossistema maduro de segurança
    

---

### 🎯 Para o Living Lab

- Baixo consumo de recursos (vs Java)
    
- Alta produtividade (vs Go)
    
- Forte integração com IA (diferencial estratégico)
    

---

### 🎯 Para Carreira

- Alta demanda de mercado
    
- Sinergia com:
    
    - Automação
        
    - Segurança
        
    - Data/IA
        

---

## Quando NÃO usar essa stack?

- Sistemas altamente CPU-bound → preferir Go
    
- Ambientes enterprise legados → Java pode ser exigido
    

---

# 9) Conclusão Final

A stack:

**Python + FastAPI + SQLAlchemy + Uvicorn/Gunicorn + Vault (AppRole)**

é a mais equilibrada considerando:

- Segurança (by design)
    
- Eficiência em containers
    
- Facilidade de auditoria
    
- Aderência a padrões modernos
    
- Baixo custo (100% open source)
    

---

# 🔒 NON-NEGOTIABLES (Arquitetura Segura)

- UTF-8 end-to-end
    
- Queries parametrizadas
    
- Segredos dinâmicos (Vault)
    
- OpenAPI documentado
    
- Testes automatizados obrigatórios
    
- Logs estruturados e auditáveis
    

---

Se desejar, posso evoluir este parecer para um **blueprint de implementação (Dockerfile, estrutura de pastas e pipeline CI/CD)** já aderente a essas decisões.



### RESPOSTA COPILOT

Vou ser direto: para esse cenário, eu recomendo **Python 3.12 + FastAPI** como stack principal da Shadow API.

---

### Visão comparativa rápida

|Stack|Performance em API|Consumo de recursos|Curva de aprendizado|Ecossistema IAM/API|Fit p/ Lab Pessoal|
|---|---|---|---|---|---|
|Python + FastAPI|Muito boa|Boa|Suave|Forte|Excelente|
|Node.js + Express/Nest|Muito boa|Boa|Suave|Forte|Muito boa|
|Go + Gin|Excelente|Excelente|Média|Boa|Muito boa|
|Java + Spring Boot|Boa|Mais pesada|Mais íngreme|Muito forte|Menos leve|

Benchmarks recentes colocam **FastAPI, Gin e Spring Boot** todos em patamares sólidos para APIs REST modernas, com Go e Java geralmente à frente em throughput bruto, mas Python entregando um ótimo equilíbrio entre velocidade de desenvolvimento e performance. [amitk.io](https://www.amitk.io/rest-api-comparison-fastapi-gin-springboot/) [jagrit.dev](https://jagrit.dev/blog/backend-api-development-comprehensive-guide) [DEV Community](https://dev.to/3a5abi/choosing-the-right-backend-framework-a-comparison-of-c-python-nodejs-go-rust-c-and-java-279p)

---

## Linguagem e framework

**Recomendação:**  
**Linguagem:** Python 3.12  
**Framework:** FastAPI

**Justificativas principais:**

- **Performance e eficiência em container:**
    
    - FastAPI é assíncrono, usa Starlette/UVicorn e entrega performance muito boa para APIs I/O-bound (como integração com DB e IGA). [jagrit.dev](https://jagrit.dev/blog/backend-api-development-comprehensive-guide)
    - Em VMs Ubuntu 24.04 com Docker, você consegue containers leves (imagens slim, uso moderado de RAM/CPU).
- **Curva de aprendizado e manutenção assistida por IA:**
    
    - Python é extremamente bem suportado por ferramentas de IA (codegen, refactor, explicação de código).
    - FastAPI usa **type hints** de forma intensiva, o que:
        - Ajuda a IA a entender melhor o código.
        - Facilita auditoria (contratos explícitos, modelos Pydantic).
- **Ecossistema de segurança/IAM/API:**
    
    - Bibliotecas maduras para:
        - JWT, OAuth2/OIDC.
        - Integração com HashiCorp Vault (hvac, libs auxiliares).
        - SCIM/REST, clientes HTTP assíncronos (httpx).
    - Suporte nativo a **OpenAPI/Swagger** com geração automática de contrato.
- **Tratamento de Unicode/UTF‑8:**
    
    - Python 3 tem suporte nativo robusto a Unicode.
    - FastAPI/Starlette trabalham por padrão com `application/json; charset=utf-8`, facilitando padronização de encoding.

**Por que não colocar outra stack como principal:**

- **Java/Spring Boot:** excelente para ambientes corporativos grandes, mas:
    - Mais pesado em memória/CPU.
    - Curva de aprendizado maior.
    - Overkill para um laboratório pessoal dockerizado.
- **Node.js:** muito forte para APIs, mas:
    - Ecossistema mais “caótico” em termos de qualidade de libs.
    - Tipagem forte depende de TypeScript e disciplina.
- **Go/Gin:** tecnicamente ótimo, mas:
    - Curva de aprendizado maior se você já não vive em Go.
    - Menos “amigável” para experimentação rápida e IA explicando código.

---

## ORM / acesso a dados

**Recomendação:**  
**Padrão:** ORM leve com suporte a Query Builder  
**Opção concreta:** **SQLAlchemy 2.x** (modo 2.0, com ORM + Core) ou **SQLModel** (sobre SQLAlchemy) para MariaDB.

**Motivos:**

- **Proteção contra SQL Injection:**
    - ORMs maduros como SQLAlchemy usam **parametrização** por padrão, reduzindo muito o risco de SQL injection.
- **Flexibilidade e performance:**
    - Você pode:
        - Usar ORM para casos simples (CRUD de entidades).
        - Usar o Core/Query Builder para queries mais otimizadas.
    - Em ambiente container, isso ajuda a manter o código limpo sem sacrificar performance.
- **Auditabilidade:**
    - Mapeamentos explícitos de modelos (classes) para tabelas.
    - Facilita entender quais campos estão sendo lidos/escritos.

Se quiser algo ainda mais enxuto, pode usar **Query Builder puro** (SQLAlchemy Core) e evitar o ORM completo, mas para um projeto de integração de identidades, o ORM costuma ajudar mais do que atrapalhar.

---

## Servidor de aplicação / web server em Docker

**Recomendação para produção:**

- **Stack:** `gunicorn` + `uvicorn` workers (ou `uvicorn` standalone em setups menores).
- **Padrão comum:**
    - `gunicorn -k uvicorn.workers.UvicornWorker -w <num_workers> app:app`

**Por quê:**

- **Gunicorn**:
    - Gerencia múltiplos workers, reinício, sinais, etc.
    - Bem estabelecido em produção.
- **Uvicorn**:
    - ASGI server rápido, ideal para FastAPI.
- Em ambientes menores ou de lab, você pode rodar só `uvicorn` com configuração adequada, mas para algo que você quer tratar como “produção séria”, a dupla `gunicorn + uvicorn` é o padrão mais equilibrado.

---

## Testes e qualidade

**Testes unitários e de integração:**

- **Framework de testes:** `pytest`
    - Simples, poderoso, amplamente suportado em CI/CD.
- **Mocking:**
    - `unittest.mock` (nativo) ou `pytest-mock`.
    - Para HTTP externo (midPoint, etc.): `responses` ou `httpx.MockTransport`.

**Qualidade e segurança:**

- **Linting e estilo:** `ruff` (substitui flake8/isort em um só), `black` para formatação.
- **Type checking:** `mypy` ou `pyright`.
- **SAST/SCA:**
    - SAST: `bandit`, regras customizadas com `semgrep`.
    - SCA: `pip-audit`, `safety`, ou scanners de container (Trivy) na imagem Docker.

Tudo isso integra muito bem com GitHub Actions, GitLab CI, Azure DevOps, etc.

---

## Documentação de API

**Recomendação:**  
**Padrão:** OpenAPI 3.x (Swagger)  
**Implementação:** nativa do FastAPI

- FastAPI gera automaticamente:
    - `/openapi.json`
    - UIs em `/docs` (Swagger) e `/redoc`.
- Para integração com o **midPoint**, o importante é:
    - Ter um **OpenAPI 3 bem definido**, com:
        - Schemas de request/response.
        - Códigos de status.
        - Autenticação (securitySchemes).
- Isso reduz ambiguidades e facilita a criação de conectores ou scripts de integração no IGA.

---

## Integração com HashiCorp Vault

**Recomendação:**  
**Biblioteca:** `hvac` (cliente oficial em Python)  
**Método de autenticação (em container):**

- Se estiver em Kubernetes:
    - **Kubernetes Auth Method** do Vault, usando Service Accounts.
- Em Docker “puro”:
    - **AppRole** com:
        - `role_id` configurado no container via variável de ambiente ou arquivo.
        - `secret_id` injetado de forma segura (volume, init container, etc.), nunca hardcoded na imagem.

**Pontos importantes:**

- Obter segredos **em runtime**, com:
    - TTL curto (dynamic secrets para MariaDB, se possível).
    - Renovação automática.
- Nunca:
    - Comitar segredos em repositório.
    - Embutir segredos na imagem Docker.

Python + hvac é uma combinação bem estabelecida para isso.

---

## Veredito de valor: por que essa stack é a mais equilibrada para você

Para um profissional de **Segurança/IAM** montando um **Living Lab** pessoal, essa stack te dá:

- **Autoridade técnica:**
    
    - FastAPI hoje é uma das referências modernas em APIs Python, muito usada em empresas e projetos sérios. [jagrit.dev](https://jagrit.dev/blog/backend-api-development-comprehensive-guide)
    - Python é onipresente em segurança, automação, DevSecOps e data engineering—você conversa bem com o ecossistema inteiro.
- **Agilidade e experimentação:**
    
    - Ciclo de feedback rápido.
    - Menos boilerplate que Java/Spring.
    - Mais simples de ajustar, testar e refatorar com apoio de IA.
- **Equilíbrio entre modernidade e pragmatismo:**
    
    - Não é uma stack exótica: é mainstream, com muita documentação, exemplos e suporte.
    - Ao mesmo tempo, é moderna (async, type hints, OpenAPI nativo).
- **Fit com os critérios do lab:**
    
    - **Open Source / Community:** tudo que citei tem opções OSS.
    - **Eficiência em recursos:** containers leves, sem JVM pesada.
    - **Segurança e Vault:** ecossistema maduro, bibliotecas consolidadas.
    - **Auditabilidade:** type hints, Pydantic, OpenAPI, logs estruturados, tudo favorece leitura e auditoria.

Se você quiser, no próximo passo posso sugerir um **esqueleto de projeto** (estrutura de pastas, dependências no `pyproject.toml`, e um exemplo de endpoint que lê do MariaDB e expõe para o midPoint) já alinhado com essa stack.


### RESPOSTA MANUS

Como Consultor de Tecnologia e Arquiteto de Software, concluí a seleção da Stack Tecnológica para a **Shadow API (PRJ008)**.

A recomendação central é a adoção de **Python 3.12+ com FastAPI**, utilizando **SQLAlchemy 2.0 (Core)** para acesso a dados e **Gunicorn/Uvicorn** para o servidor de aplicação. Esta combinação foi selecionada por oferecer o melhor equilíbrio entre eficiência de recursos em containers Docker, segurança nativa contra SQL Injection e suporte robusto a Unicode — resolvendo diretamente o problema de corrupção de dados mencionado.

Além disso, a stack garante uma integração leve e segura com o **HashiCorp Vault via hvac** e fornece documentação automática via **OpenAPI**, essencial para o consumo pelo midPoint. O veredito de valor destaca que esta escolha fortalece a autoridade do profissional de IAM ao utilizar a linguagem padrão de automação de segurança do mercado atual.

Os detalhes completos e as justificativas técnicas estão disponíveis abaixo:

# Parecer Técnico: Seleção de Stack Tecnológica - Shadow API (PRJ008)

Assunto: Definição da Stack para Integração MariaDB (OrangeHRM) ↔ midPoint (IGA)

Arquiteto Responsável: Consultoria de Tecnologia e Arquitetura de Software

Ambiente: Ubuntu 24.04 (Docker), Mesh VPN, HashiCorp Vault.

## 1. Linguagem e Framework: Python + FastAPI

Recomendação: Python 3.12+ com FastAPI.

Justificativa Técnica:

•Performance: O FastAPI é um dos frameworks mais rápidos do mercado, construído sobre Starlette e Pydantic. Sua natureza assíncrona (async/await) é ideal para I/O intenso, como consultas ao MariaDB e chamadas REST ao midPoint.

•Curva de Aprendizado: Python possui a curva mais suave para profissionais de Segurança/IAM, permitindo foco na lógica de negócio e segurança em vez de sintaxes complexas.

•Ecossistema IAM: O ecossistema Python é vasto em bibliotecas para tratamento de identidades, criptografia e integração com protocolos de segurança.

•Assistência por IA: Por ser uma linguagem de alta legibilidade e amplamente documentada, as IAs geram código Python com menor taxa de erro e maior aderência a padrões de design.

|   |   |   |   |
|---|---|---|---|
|Critério|FastAPI (Python)|Go|Node.js (Express)|
|Velocidade de Dev|Alta|Média|Alta|
|Consumo RAM|Baixo/Médio|Baixíssimo|Médio|
|Tipagem Nativa|Sim (Pydantic)|Sim (Estática)|Não (Requer TS)|
|Suporte IA|Excelente|Bom|Excelente|

## 2. ORM / Acesso a Dados: SQLAlchemy 2.0 (Core + Async)

Recomendação: SQLAlchemy 2.0 utilizando o padrão Query Builder/Core.

Justificativa:

•Segurança: O SQLAlchemy utiliza parametrização automática de queries, eliminando nativamente o risco de SQL Injection.

•Performance: O modo "Core" oferece uma abstração leve sobre o SQL, evitando o overhead de mapeamento de objetos complexos (ORM tradicional) que consome CPU/RAM desnecessária em containers.

•Flexibilidade: Permite lidar com o banco legado do OrangeHRM (MariaDB) de forma precisa, facilitando o mapeamento de campos específicos e o tratamento de encodings.

## 3. Servidor de Aplicação: Gunicorn + Uvicorn Workers

Recomendação: Gunicorn como gerenciador de processos, utilizando a classe de worker Uvicorn.

Justificativa:

•Robustez: O Gunicorn atua como um "Process Manager", garantindo que, se um worker falhar, ele seja reiniciado automaticamente.

•Escalabilidade: Permite configurar o número de workers de acordo com o número de cores da CPU da VM Ubuntu, otimizando o throughput da API em Docker.

## 4. Testes e Qualidade: Pytest + Mockito

Recomendação: Pytest para testes unitários e de integração, com pytest-mock para mocking.

Justificativa:

•Simplicidade: O Pytest é agnóstico e extremamente poderoso, permitindo criar fixtures complexas para simular o comportamento do MariaDB e do midPoint sem necessidade de conexões reais durante o CI/CD.

•Integração: Gera relatórios em formatos compatíveis com ferramentas de qualidade de código (SCA/SAST) exigidas pela ISO 27001.

## 5. Documentação de API: OpenAPI (Swagger) + Redoc

Recomendação: OpenAPI 3.1 (Nativo do FastAPI).

Justificativa:

•Consumo pelo midPoint: O midPoint possui conectores REST que consomem contratos OpenAPI. O FastAPI gera essa documentação automaticamente no endpoint /docs, garantindo que o contrato esteja sempre sincronizado com o código.

•Tipagem Estrita: O uso de Pydantic Models no FastAPI garante que o contrato defina exatamente os tipos de dados (incluindo validações de string/Unicode), evitando ambiguidades na integração.

## 6. Integradção com Vault: HVAC (HashiCorp Vault Python Client)

Recomendação: Biblioteca hvac com autenticação via AppRole.

Justificativa:

•Leveza: O hvac é uma biblioteca madura e leve que permite buscar segredos em runtime sem a necessidade de agentes pesados dentro do container.

•Segurança Dinâmica: Facilita a implementação de renovação de tokens e busca de credenciais efêmeras (Dynamic Secrets) para o MariaDB.

## 7. Veredito de Valor: Por que esta stack?

A escolha de Python/FastAPI em detrimento de Java/Spring, Node.js ou Go para este projeto específico baseia-se no Equilíbrio de Autoridade e Agilidade:

1.Para o Profissional de Segurança/IAM: Python é a "língua franca" da automação de segurança. Dominar esta stack não apenas resolve o problema técnico, mas fortalece a autoridade do profissional em comunidades de SecOps e DevSecOps.

2.Agilidade no Laboratório: Diferente do Java/Spring (que possui alto consumo de memória e inicialização lenta) ou Go (que exige maior verbosidade para tratamento de erros e lógica de API), o FastAPI permite prototipar e auditar a lógica de identidade com velocidade extrema.

3.Tratamento de Unicode: Python 3 trata todas as strings como Unicode por padrão. Em conjunto com o Pydantic, a validação de caracteres acentuados (comum em nomes de usuários no RH) é tratada na "porta de entrada" da API, resolvendo o problema de corrupção de dados solicitado no desafio.

Conclusão: Esta stack é a mais eficiente para rodar em containers leves, a mais segura para lidar com segredos e a que oferece a melhor documentação automática para integração com o midPoint, garantindo um ciclo de vida sustentável e moderno.



### PARECER PERPLEXITY



Minha recomendação principal para o PRJ008 é **Python + FastAPI**, com **SQLAlchemy Core/2.0 + consultas parametrizadas**, executando em **Uvicorn** atrás de um processo gerenciado de produção, com **OpenAPI 3.1 como contrato oficial** e **Vault via AppRole + Vault Agent sidecar** para segredos em runtime. Essa combinação entrega o melhor equilíbrio entre leveza em Ubuntu/Docker, custo zero, velocidade de desenvolvimento, clareza para auditoria e ótima compatibilidade com manutenção assistida por IA.dev+1[Manifesto de Estratégia e Infraestrutura (Fiqueok).md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/5b5f9a6f-5c5a-45b1-918f-3daefecb491e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md)

## Linguagem e framework

**Python + FastAPI** é a dupla mais equilibrada para a Shadow API porque oferece tipagem e validação fortes com Pydantic, geração automática de OpenAPI e uma curva de desenvolvimento bem mais curta que Java/Spring para um laboratório pessoal com foco em agilidade e governança. Além disso, comparativos recentes apontam que FastAPI tende a iniciar mais rápido e consumir menos memória do que Spring Boot, o que pesa bastante em VMs Ubuntu 24.04 dockerizadas com recursos limitados.solodevstack+3

## Por que recomendo essa dupla

- **Performance suficiente e boa para I/O-bound**, que é exatamente o perfil de uma API ponte entre banco e IGA.auth0+1
    
- **OpenAPI nativo**, útil para contrato inequívoco com o midPoint e para inventário/versionamento de endpoints, algo alinhado ao risco API9 da OWASP.[dev](https://dev.to/johnjvester/fastapi-got-me-an-openapi-spec-really-fast-4ck0)[DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/7749b546-19a0-490e-be2c-dc555467fda1/DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md)
    
- **Validação rigorosa de dados** com Pydantic, o que ajuda no saneamento de Unicode, formatos e campos sensíveis.dev+1
    
- **Legibilidade alta para auditoria**, especialmente com type hints, models explícitos e logs estruturados.[auth0](https://auth0.com/blog/fastapi-best-practices/)
    

## Comparação resumida

|Stack|Pontos fortes|Limitações no PRJ008|
|---|---|---|
|**Python + FastAPI**|Rápida de desenvolver, OpenAPI nativo, tipagem com Pydantic, boa integração com SQLAlchemy e Vault, ótima para manutenção por IA. auth0+2|Menor throughput bruto que Go em cenários extremos, exige disciplina para não virar código “dinâmico demais”. [auth0](https://auth0.com/blog/fastapi-best-practices/)|
|**Java + Spring Boot**|Ecossistema enterprise vasto, forte em padrões corporativos e IAM.|Maior consumo de memória e startup mais pesado em containers pequenos. [solodevstack](https://solodevstack.com/blog/fastapi-vs-spring-boot-solo-developers)|
|**Node.js**|Bom ecossistema web, rapidez para CRUD/API.|Maior risco de heterogeneidade arquitetural e tipagem menos coesa no runtime se comparado a FastAPI + Pydantic. [auth0](https://auth0.com/blog/fastapi-best-practices/)|
|**Go**|Excelente performance, binários simples, baixo uso de memória.|Menor ergonomia para contratos ricos, validação e produtividade de laboratório orientado a evolução rápida e documentação automática. gofiber+1|

## Acesso a dados

Para esse projeto, eu **não recomendo ORM pesado como padrão dominante**. O melhor equilíbrio é **SQLAlchemy 2.0 no modo Core/Query Builder**, com modelos de domínio separados e uso de consultas parametrizadas.stackoverflow+2

Isso é superior aqui por três razões:

- reduz overhead em comparação com ORM completo;[builder.ai2sql](https://builder.ai2sql.io/blog/sql-injection-prevention-guide)
    
- mantém proteção forte contra SQL Injection quando se usa bind parameters e construção segura de queries;cheatsheetseries.owasp+1
    
- facilita escrever SQL explícito e auditável para um banco legado como o OrangeHRM, onde JOINs e mapeamentos semânticos costumam ser inevitáveis.PRJ005-Documento-de-Abertura-de-Projeto.md+1
    

## Padrão recomendado

- **SQLAlchemy Core 2.0** para consultas padrão.
    
- **`text()` apenas com bind parameters** quando a query exigir SQL explícito.towardsdatascience+1
    
- **Sem concatenação de strings SQL** em filtros vindos da API.[cheatsheetseries.owasp](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html)
    
- **Repository layer** para encapsular acesso ao MariaDB.
    
- **Read-only DB user** com privilégio mínimo, como já adotado no lab.[PRJ005-Documento-de-Abertura-de-Projeto.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/1e672a9d-2677-461a-90ec-fcb1569ff5da/PRJ005-Documento-de-Abertura-de-Projeto.md)
    

Em resumo: **query builder + parâmetros vinculados** entrega mais previsibilidade, melhor performance e menor risco do que um ORM “mágico” em um sistema de integração legado.builder.ai2sql+1

## Servidor de aplicação

Para produção em Docker, a recomendação prática é **Uvicorn** como ASGI server do FastAPI. Em um cenário pequeno e controlado de laboratório, ele já atende bem com workers ajustados ao tamanho da VM, sem necessidade de empilhar componentes pesados.solodevstack+1

Minha sugestão objetiva é:

- **Desenvolvimento:** `uvicorn` com reload.
    
- **Produção:** `uvicorn` sem reload, com número de workers pequeno e controlado, atrás de reverse proxy interno quando necessário.[auth0](https://auth0.com/blog/fastapi-best-practices/)
    

Eu evitaria complexidade desnecessária no PRJ008. O alvo aqui é uma Shadow API de governança, não uma plataforma de altíssimo throughput. O maior risco é semântico e de segurança, não de volume massivo.DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md+1

## Testes e qualidade

O ideal é adotar ferramentas simples, maduras e fáceis de integrar em CI/CD. A base mais equilibrada para essa stack é:

- **pytest** para unit e integration tests.
    
- **unittest.mock** ou **pytest-mock** para mocking.
    
- **Testcontainers** ou banco efêmero em Docker para testes de integração com MariaDB.
    
- **HTTPX/TestClient** para testes de API.
    
- **coverage.py** para cobertura.
    
- **Ruff** para lint/qualidade estática.
    
- **mypy** para reforço de tipagem.
    
- **Bandit** para SAST leve em Python.
    
- **pip-audit** ou equivalente para dependências vulneráveis.owasp+1
    

Essas ferramentas se encaixam bem em pipelines automatizadas e reforçam auditabilidade porque produzem relatórios claros e fáceis de anexar como evidência.devguide.owasp+1

## Documentação da API

O padrão que deve ser adotado é **OpenAPI 3.1**, com documentação automática exposta pela aplicação e contrato versionado em repositório. FastAPI já gera especificação OpenAPI automaticamente, o que reduz ambiguidade e ajuda a manter inventário de endpoints e versões, tema explicitamente sensível no OWASP API Security Top 10 2023.2025.pycon+1[DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/7749b546-19a0-490e-be2c-dc555467fda1/DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md)

Minha recomendação de governança é:

- manter o **OpenAPI como artefato versionado**;[2025.pycon](https://2025.pycon.de/talks/ZACM3E/)
    
- tratar o contrato como base de desenvolvimento **contract-first**, mesmo que o framework gere os docs automaticamente;[2025.pycon](https://2025.pycon.de/talks/ZACM3E/)
    
- versionar endpoints (`/api/v1/...`) e schemas;
    
- descrever enums de estado JML e restrições de campos semânticos diretamente no contrato.DOC-ARC-000-Fundamentos-de-Decisao-em-Arquitetura-de-Identidade.md+1
    

## Integração com Vault

Para containers fora de Kubernetes, o método mais leve e seguro para essa stack é **Vault AppRole**, preferencialmente com **Vault Agent sidecar** para autenticar e entregar segredos em runtime. A própria documentação da HashiCorp diz que AppRole é orientado a workflows automatizados de máquinas e serviços, e recomenda inclusive uso de batch tokens com esse método.[Manifesto de Estratégia e Infraestrutura (Fiqueok).md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/5b5f9a6f-5c5a-45b1-918f-3daefecb491e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md)

Além disso, a documentação da HashiCorp afirma que **Pull mode é mais seguro que Push mode** na maior parte dos casos, e que o SecretID deve ser tratado como segredo, idealmente com wrapping/resposta protegida. Em Docker, o sidecar com Vault Agent é uma forma leve de desacoplar a aplicação da lógica de renovação/autenticação, deixando a app apenas ler um segredo efêmero de volume compartilhado ou arquivo temporário.[oneuptime](https://oneuptime.com/blog/post/2026-02-02-vault-docker/view)[Manifesto de Estratégia e Infraestrutura (Fiqueok).md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/5b5f9a6f-5c5a-45b1-918f-3daefecb491e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md)

## Recomendação prática

- **Auth method:** AppRole.[Manifesto de Estratégia e Infraestrutura (Fiqueok).md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/5b5f9a6f-5c5a-45b1-918f-3daefecb491e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md)
    
- **Entrega:** Vault Agent sidecar renderizando secrets em volume compartilhado ou arquivo em memória.[oneuptime](https://oneuptime.com/blog/post/2026-02-02-vault-docker/view)
    
- **Token:** TTL curto e escopo mínimo.[Manifesto de Estratégia e Infraestrutura (Fiqueok).md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/5b5f9a6f-5c5a-45b1-918f-3daefecb491e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md)
    
- **Nada de `.env` fixo** com credenciais long-lived.[vault_implementation_guide_v3.0.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/0471c2c6-8dea-4ead-98e2-d48e0b5c821b/vault_implementation_guide_v3.0.md)
    

## Unicode e UTF-8

Como o problema original envolve corrupção de caracteres e integridade no AD, a stack precisa tratar Unicode como requisito de primeira classe. FastAPI e Pydantic trabalham naturalmente com strings Unicode, o que ajuda a manter consistência de payloads JSON e validação em runtime.dev+1

Mesmo assim, o controle precisa existir em camadas:

- MariaDB com `utf8mb4`;
    
- driver configurado corretamente;
    
- API sempre em JSON UTF-8;
    
- testes automatizados com nomes acentuados em português;
    
- normalização explícita quando houver integração com sistemas downstream mais rígidos.[PRJ005-Documento-de-Abertura-de-Projeto.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/1e672a9d-2677-461a-90ec-fcb1569ff5da/PRJ005-Documento-de-Abertura-de-Projeto.md)
    

## Logs estruturados

A stack deve produzir **logs JSON estruturados**, com `request_id`, `employeeId`, tipo de evento JML, status, latência e resultado de integração. Isso fortalece auditabilidade e ajuda a detectar riscos como autenticação falha, consumo indevido de recursos ou endpoints mal gerenciados, pontos que dialogam com OWASP API2, API4, API8 e API9.[DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/7749b546-19a0-490e-be2c-dc555467fda1/DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md)

## Veredito de valor

Eu escolheria **Python + FastAPI + SQLAlchemy Core + Uvicorn + OpenAPI 3.1 + Vault AppRole/Agent** porque essa é a stack mais equilibrada para um profissional de Segurança/IAM que quer **autoridade técnica, rapidez de entrega e baixo custo operacional**.solodevstack+1[Manifesto de Estratégia e Infraestrutura (Fiqueok).md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/5b5f9a6f-5c5a-45b1-918f-3daefecb491e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md)

Ela supera Java/Spring no contexto do lab por exigir menos memória, menos tempo de bootstrap e menos peso cognitivo para uma API pequena e altamente governada. Ela supera Node.js porque entrega tipagem e validação mais coesas no runtime com menos fragmentação de padrões, o que ajuda muito em auditoria e manutenção assistida por IA. E ela supera Go no seu contexto específico porque, embora Go seja excelente em eficiência, FastAPI oferece melhor ergonomia para contratos, validação, documentação automática e produtividade de laboratório, o que acelera a construção de um ativo demonstrável e bem governado.gofiber+5

## Stack final recomendada

- **Linguagem:** Python 3.12+[auth0](https://auth0.com/blog/fastapi-best-practices/)
    
- **Framework API:** FastAPIdev+1
    
- **Validação/serialização:** Pydanticdev+1
    
- **Acesso a dados:** SQLAlchemy 2.0 Core + bind parametersstackoverflow+1
    
- **Driver MariaDB:** driver Python maduro compatível com SQLAlchemy
    
- **Servidor:** Uvicorn[auth0](https://auth0.com/blog/fastapi-best-practices/)
    
- **Testes:** pytest + mocks + TestClient + cobertura[owasp](https://owasp.org/www-project-devsecops-guideline/)
    
- **Qualidade:** Ruff + mypy + Bandit + audit de dependênciasdevguide.owasp+1
    
- **Contrato:** OpenAPI 3.1 versionadodev+1
    
- **Segredos:** Vault AppRole + Vault Agent sidecar[oneuptime](https://oneuptime.com/blog/post/2026-02-02-vault-docker/view)[Manifesto de Estratégia e Infraestrutura (Fiqueok).md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/5b5f9a6f-5c5a-45b1-918f-3daefecb491e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok.md)
    
- **Logs:** JSON estruturado com correlação por requisição e por identidade[DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_922885c6-b348-4deb-87c7-d8d62886195e/7749b546-19a0-490e-be2c-dc555467fda1/DOC-ARC-001-Problemas-de-Decisao-Observados-em-Arquitetura-de-Identidade-Living-Lab.md)
    

Se você quiser, no próximo passo eu posso montar uma **decisão arquitetural formal (ADR)** com essa stack e já entregar também uma **estrutura inicial de repositório PRJ008** com pastas, dependências e pipeline mínima de CI/CD.


### PARECER DEEPSEEK

## Parecer Técnico: Stack Tecnológica para Shadow API (PRJ008)

**Consultor:** Arquiteto de Software Especializado em IAM/Segurança  
**Projeto:** Shadow API - Ponte OrangeHRM (MariaDB) → midPoint (IGA)  
**Ambiente:** Ubuntu 24.04 + Docker + Vault

---

## 1. Linguagem e Framework: **Rust + Axum**

### Veredito Final: **Rust com Axum** (2ª opção: Go + Gin)

| Critério | Rust + Axum | Go + Gin | Python + FastAPI | Java + Spring Boot |
|----------|-------------|----------|------------------|---------------------|
| **Performance** | 🏆 Excepcional (C-level) | Excelente | Moderada | Boa (mas pesada) |
| **Memória/CPU** | ~5-10MB idle | ~15-20MB | ~50-100MB | ~300-500MB |
| **Segurança Memória** | 🏆 Compile-time (sem GC) | Boa (GC, mas seguro) | Riscos (GIL, buffer overflow) | Moderada (JVM safe) |
| **Suporte Vault** | `vault-rs` (maduro) | `vault-api` (nativo) | `hvac` (excelente) | `spring-vault` (robusto) |
| **Tratamento UTF-8** | 🏆 Nativo (String é UTF-8) | Bom (rune/string) | Excelente (str Unicode) | Bom (String UTF-16) |
| **Curva Aprendizado** | Íngrime | 🏆 Suave | Muito Suave | Moderada |
| **Valor Profissional** | 🏆 Alta (diferenciador) | Alta (mercado forte) | Média (commoditizado) | Alta (empresarial) |
| **Open Source** | ✅ 100% | ✅ 100% | ✅ 100% | ✅ (mas ecossistema pesado) |

### Justificativa Detalhada:

**Por que Rust + Axum para IAM/Security?**
- **Zero-cost abstractions:** Ideal para parsing de headers, JWT validation sem overhead.
- **Memory safety garantida em compile-time:** Elimina classes inteiras de CVEs (use-after-free, buffer overflow).
- **Axum** é da Tokio stack (mesma do `reqwest` e `tower`), maduro para APIs REST com middleware nativo para tracing, compression, rate limiting.
- **Tratamento de encoding:** `String` em Rust é sempre UTF-8 válida - impossível corromper. O compilador força você a lidar com `FromUtf8Error`.
- **Valor profissional:** Engenheiros Rust são raros e bem pagos. Dominar Rust + IAM coloca você no topo 5% do mercado de segurança.

**Contra Rust (e como mitigar):**
- Curva inicial: 2-3 semanas para fluência básica. **Mitigação:** Cursor.ai + GitHub Copilot reduzem drasticamente esse gap.
- Compilação lenta em debug. **Mitigação:** Use `cargo-chef` para cache de dependências em Docker multi-stage.

**Por que não as outras?**
- **Java/Spring:** Overkill de memória (300MB+) e complexidade para uma API de ponte. Não justifica o consumo.
- **Node.js:** Callback hell + tipagem fraca levariam a erros de encoding e segurança frágil. Vault integration é imatura.
- **Python/FastAPI:** Ótimo para protótipo, mas GIL e consumo de memória inviáveis para high-throughput. **Mas** seria minha 2ª escolha se Rust for proibitivo.
- **Go:** Ponto ideal entre performance e simplicidade. Se o time não quiser Rust, **vá de Go + Gin**. Perde em segurança de memória (GC pauses, nil pointers) mas ganha em produtividade.

---

## 2. ORM / Acesso a Dados: **SQLx (Query Builder com Compile-time Checks)**

### Veredito: **SQLx** (Rust) - Nenhum ORM full, apenas Query Builder

| Abordagem | Proteção SQL Injection | Performance | Tipo em Compile-time | Recomendação |
|-----------|----------------------|-------------|----------------------|---------------|
| **SQLx (Raw + macros)** | 🏆 (Prepared statements) | 🏆 Máxima | ✅ (Verifica tabelas no compile) | **ESCOLHIDO** |
| **Diesel (ORM)** | Bom | Bom | ✅ | Rejeitado (complexo, pesado) |
| **SeaORM** | Bom | Médio | Parcial | Rejeitado (overhead) |
| **Go + sqlx** | Bom | Bom | ❌ (runtime) | 2ª opção |

### Padrão Recomendado:
```rust
// SQLx com query! macro - verifica em compile-time
let user = sqlx::query!(
    "SELECT id, nome, email, cargo FROM users WHERE id = ?",
    user_id
)
.fetch_one(&pool)
.await?;

// Força UTF-8 na raiz - o driver já retorna String válida
```

**Por que não ORM?**
- ORMs (Diesel, SeaORM) geram SQL complexo, difícil auditar e otimizar.
- Para IGA, queries são previsíveis (busca por CPF, e-mail, cargo). SQL simples resolve.
- **Benefício crítico:** `query!` macro valida **em tempo de compilação** que a tabela `users` existe e a coluna `email` é `VARCHAR(255)`. Zero surpresa em runtime.

**Proteção contra encoding corrompido:**  
Configure a pool com `&pool_options.after_connect(|conn| Box::pin(async move { conn.execute("SET NAMES utf8mb4").await?; Ok(()) }))`.

---

## 3. Servidor de Aplicação / Web Server: **Axum (embutido) + Tower Middleware**

### Veredito: **Axum roda diretamente** - sem camada extra (diferente de Python)

**Arquitetura Docker:**
```dockerfile
# Multi-stage build otimizado
FROM rust:1.82-slim-bookworm AS builder
WORKDIR /app
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim  # Sem glibc issues
COPY --from=builder /app/target/release/shadow-api /usr/local/bin/
USER 10001:10001
CMD ["shadow-api"]
```

**Por que sem Gunicorn/Uvicorn?**
- Rust não precisa de process manager (Tokio runtime já gerencia tasks assíncronas).
- Axum tem built-in `Router` com `Tower` middleware stack para rate limiting, CORS, logging.
- **Benchmark:** Rust + Axum processa ~120k req/s em VM modesta. Go + Gin ~80k. Python + Uvicorn ~15k.

**Configuração produção:**
```rust
let app = Router::new()
    .route("/v1/users", get(get_users))
    .layer(TraceLayer::new_for_http())  // Log estruturado
    .layer(RateLimitLayer::new(100, Duration::from_secs(60)))
    .layer(CompressionLayer::new());  // Gzip automático

let listener = TcpListener::bind("0.0.0.0:8080").await?;
axum::serve(listener, app).await?;
```

---

## 4. Testes e Qualidade: **Ferramentas Agnósticas CI/CD**

| Categoria | Ferramenta | Integração CI/CD | Comando Base |
|-----------|------------|------------------|---------------|
| **Unit Testing** | `cargo test` (built-in) | ✅ Nativo | `cargo test --release` |
| **Mocking** | `mockall` (Rust) | ✅ | Gera mocks via derive macro |
| **HTTP Mock** | `wiremock` | ✅ | Simula midPoint/Vault |
| **Test Coverage** | `tarpaulin` | ✅ (Codecov) | `cargo tarpaulin --out Xml` |
| **Mutation Testing** | `cargo-mutants` | ⚠️ (opcional) | Encontra testes fracos |
| **Fuzzing** | `cargo-fuzz` (libFuzzer) | ✅ Semanal | Testa encoding malicioso |

**Pipeline CI/CD (GitHub Actions):**
```yaml
- name: Run tests with coverage
  run: cargo tarpaulin --ignore-tests --out Xml
- name: Run fuzzing (daily)
  if: github.event_name == 'schedule'
  run: cargo fuzz run api_parser -- -max_total_time=300
```

**Mocking de dados para IGA:**
```rust
// mockall exemplo
#[automock]
trait UserRepository {
    fn find_by_cpf(&self, cpf: &str) -> Result<User, DbError>;
}

#[cfg(test)]
mod tests {
    use mockall::predicate::*;
    #[test]
    fn test_get_user_endpoint() {
        let mut mock_repo = MockUserRepository::new();
        mock_repo.expect_find_by_cpf()
            .with(eq("123.456.789-00"))
            .returning(|_| Ok(User::dummy()));
        // ... testa axum handler
    }
}
```

---

## 5. Documentação de API: **OpenAPI 3.1 (via `utoipa` crate)**

### Veredito: **OpenAPI 3.1 + Swagger UI**

**Por que OpenAPI é obrigatório para midPoint?**
- midPoint suporta nativamente integração via REST com OpenAPI contracts.
- Gera cliente automaticamente (elimina erros de parsing).
- **Contrato primeiro:** O YAML deve ser versionado no repositório e validado no CI.

**Implementação com `utoipa` (Rust):**
```rust
#[derive(utoipa::ToSchema, Serialize)]
#[schema(example = json!({"id": 1, "nome": "João Silva", "cpf": "123.456.789-00"}))]
struct User {
    id: i32,
    nome: String,  // auto-validado como UTF-8
    cpf: String,
}

#[utoipa::path(
    get,
    path = "/v1/users/{cpf}",
    responses(
        (status = 200, description = "User found", body = User),
        (status = 404, description = "User not found")
    ),
    params(("cpf" = String, Path, description = "CPF do usuário"))
)]
async fn get_user_by_cpf(Path(cpf): Path<String>) -> impl IntoResponse { ... }

// Gera Swagger UI automaticamente
let app = Router::new()
    .merge(SwaggerUi::new("/swagger-ui").url("/api-docs/openapi.json", ApiDoc::openapi()));
```

**Benefício para auditoria:** O contrato OpenAPI serve como documentação viva. Qualquer mudança breaking requer PR com diff do YAML.

---

## 6. Integração com Vault: **`vaultrs` + JWT Auth Method**

### Veredito: **JWT OIDC Auth (Workload Identity) + `vaultrs` crate**

**Método mais leve e seguro para Rust:**

```rust
use vaultrs::auth::jwt::{self, JwtLogin};
use vaultrs::client::VaultClient;
use vaultrs::kv2;

// 1. Container lê JWT do arquivo (injetado pelo K8s/Nomad)
let jwt_token = fs::read_to_string("/var/run/secrets/kubernetes.io/serviceaccount/token")?;

// 2. Autentica no Vault sem senha estática
let client = VaultClient::new(
    "https://vault.internal:8200".to_string(),
    "shadow-api".to_string(),
    None,
)?;

let login = JwtLogin {
    jwt: jwt_token,
    role: "shadow-api-role".to_string(),
};

let auth_response = jwt::login(&client, &login).await?;
client.set_token(&auth_response.auth.client_token);

// 3. Busca credencial do banco (TTL 1 hora)
let db_creds: DbCredentials = kv2::read(&client, "secret", "database/creds").await?;

// 4. Renova token antes do TTL expirar
spawn(async move {
    loop {
        tokio::time::sleep(Duration::from_secs(1800)).await; // 30 min
        let _ = jwt::renew(&client, &auth_response.auth.client_token).await;
    }
});
```

**Segurança adicional:**
- **AppRole** como fallback se não houver K8s (mas prefira JWT).
- **Nunca** use `VAULT_TOKEN` env var - isso aparece em logs e dumps.
- **Audit trail:** Vault registra cada acesso da API às credenciais.

---

## 7. Veredito de Valor: Por que Rust + Axum é a Escolha Equilibrada

### Para o Profissional de Segurança/IAM:

| Critério de Valor | Rust + Axum | Go + Gin | Python + FastAPI |
|-------------------|-------------|----------|-------------------|
| **Autoridade Técnica** | 🏆 Máxima (diferenciação radical) | Alta (respeitável) | Média (commodity) |
| **Velocidade de Desenvolvimento** | Média (curva inicial) | 🏆 Alta | Muito Alta |
| **Agilidade em Lab Pessoal** | Boa (após 2 semanas) | 🏆 Excelente | Excelente |
| **Portfólio (Valor de Mercado)** | 🏆 Raridade (top 5%) | Alto (top 20%) | Médio (top 60%) |
| **Facilidade para IA (Cursor/Codeium)** | Boa (IA generativa escreve Rust bem) | Muito Boa | Excelente |
| **Segurança como Default** | 🏆 (compile-time) | Boa (runtime) | Moderada (runtime) |

### O Argumento Decisivo:

**Escolha Rust + Axum se:**
- Você quer se posicionar como **especialista de elite** em IAM/Segurança.
- Tem 2-4 semanas para curva de aprendizado (investimento que se paga em 6 meses de mercado).
- A Shadow API vai processar **>10k req/s** ou lidar com dados sensíveis onde **buffer overflow é inaceitável**.
- Quer um código que o auditor de segurança **não consegue achar falhas de memória** (porque o compilador já bloqueou).

**Escolha Go + Gin se:**
- Você precisa entregar em **2 semanas** e não pode absorver curva de Rust.
- O time tem medo de Rust (argumento válido em empresa, mas em lab pessoal? invista).
- A carga é média (<5k req/s) e você aceita `nil pointer dereference` como risco residual.

**Escolha Python/FastAPI se:**
- É um protótipo descartável (mas o enunciado pede modernização).
- Você **não** quer crescer profissionalmente (porque Python para IAM é o básico do básico).

### Conclusão Final do Consultor:

> **Recomendo Rust com Axum + SQLx + utoipa + vaultrs.**  
> *Justificativa:* O Living Lab é um ambiente de aprendizado e demonstração de autoridade. Dominar Rust em 2025-2026 é o equivalente a dominar C++ em 1995 ou Java em 2005 - um **divisor de águas** de carreira. A eficiência de memória (5MB vs 300MB do Java) significa que você roda a API em um Raspberry Pi ou container gratuito. O tratamento de UTF-8 nativo elimina a classe inteira de problemas de encoding que matam integrações de RH. E para a IA assistente (Cursor/Copilot), Rust tem treinamento suficiente para gerar código correto e seguro.

**Stack Final (PRJ008):**
```
Linguagem:     Rust 1.82+ (edition 2024)
Framework:     Axum 0.8 (Tokio runtime)
DB Access:     SQLx 0.8 (query! macro)
Web Server:    Axum embutido (Tower middleware)
Vault:         vaultrs 0.8 (JWT auth)
Documentação:  utoipa 5.0 (OpenAPI 3.1)
Logs:          tracing + opentelemetry (JSON estruturado)
Testes:        cargo test + mockall + wiremock
Container:     Distroless (5MB final image)
```

**Não-negociável:** A imagem Docker final deve ser <10MB, assinada com Sigstore/cosign, e executar como usuário não-root (UID 10001). Qualquer desvio disso é rasoável para uma auditoria ISO 27001.



### PARECER CLAUDE

Aqui está o parecer técnico completo para a stack do PRJ008 — Shadow API.

---

## Parecer Técnico — Stack do PRJ008 (Shadow API)

---

### 1. Linguagem e Framework: Python 3.12 + FastAPI

A recomendação é **inequívoca**: Python 3.12 com FastAPI. Não por modismo, mas por uma convergência de fatores que se alinham exatamente com as restrições do Living Lab.

Python domina o ecossistema IAM/SecOps por razões práticas: as bibliotecas para integração com Vault (`hvac`), LDAP (`python-ldap`, `ldap3`), SCIM, Entra ID (`msal`) e manipulação de identidade existem, são maduras e são bem mantidas. FastAPI especificamente introduz tipagem estática com Pydantic, o que resolve o problema de encoding na camada de contrato — você declara `name: str` e o Pydantic garante que o valor é uma string Python válida (Unicode nativa), não bytes corrompidos.

Em comparação com as alternativas:

**Java/Spring Boot** entrega robustez corporativa, mas consome 400–800MB de RAM apenas para o processo base. Em VMs com recursos compartilhados, isso é inaceitável. O ciclo de feedback (compile → deploy → test) é lento demais para um lab assistido por IA onde você itera código rapidamente.

**Node.js/Express** tem excelente performance em I/O, mas o ecossistema IAM é raso. Não há equivalente maduro ao `hvac` ou ao `python-ldap`. Além disso, o tratamento de strings em JavaScript é historicamente problemático para encoding — o modelo de strings UTF-16 internas cria armadilhas sutis.

**Go** seria a escolha certa se o objetivo fosse um binário de alta performance em produção. Mas a curva de aprendizado para um profissional IAM que não é dev full-time é real, o ecossistema de bibliotecas de identidade é menor, e — criticamente — o suporte de ferramentas de IA (Copilot, Claude) para geração de código Go idiomático é inferior ao de Python. Para um lab onde a IA é parceira de desenvolvimento, Python ganha por margem.

FastAPI sobre Flask porque: validação automática com Pydantic, OpenAPI 3.0 gerado nativamente, suporte a async sem configuração extra, e type hints como contrato — uma IA lendo o código entende os tipos sem inferência.

---

### 2. ORM / Acesso a Dados: SQLAlchemy 2.x com Core + Pydantic como contrato

Para este caso específico — leitura de um schema legado (OrangeHRM) sem controle sobre o modelo de dados — a recomendação é usar **SQLAlchemy Core** (não ORM completo) combinado com queries parametrizadas explícitas.

O ORM completo (mapeamento de classes para tabelas) pressupõe que você "possui" o schema. No OrangeHRM você é apenas um leitor de um schema de terceiro, que pode mudar entre versões. O SQLAlchemy Core te dá proteção contra SQL Injection via bind parameters (nenhuma string interpolada chega à query) sem forçar um mapeamento de entidades que não é seu.

A configuração crítica para encoding é explícita na engine:

```python
engine = create_engine(
    DATABASE_URL,
    connect_args={"charset": "utf8mb4"},
    pool_pre_ping=True,
)
```

Após cada `fetchall()`, os resultados passam pela função de normalização `normalize_identity_string()` (como discutido no parecer anterior) antes de chegarem ao Pydantic. O Pydantic então serializa para JSON com suporte UTF-8 nativo do Python — nenhum dado corrompido chega à saída da API.

Para migrações e inspeção de schema: **Alembic** (mesmo que não gerencie o schema do OrangeHRM, é útil para tabelas de controle interno da própria Shadow API, como log de sync).

---

### 3. Servidor de Aplicação: Uvicorn + Gunicorn em modo worker

Para produção em container Docker, a recomendação é **Gunicorn com worker class Uvicorn** (`uvicorn.workers.UvicornWorker`).

Uvicorn sozinho é um servidor ASGI de processo único — excelente para desenvolvimento, mas sem gestão de workers. Gunicorn sozinho não entende ASGI. A combinação dos dois é o padrão recomendado pela própria documentação do FastAPI para produção: Gunicorn gerencia o ciclo de vida dos workers e reinicialização automática, Uvicorn executa o loop de eventos assíncrono em cada worker.

Configuração razoável para o Living Lab:

```dockerfile
CMD ["gunicorn", "app.main:app", \
     "--workers", "2", \
     "--worker-class", "uvicorn.workers.UvicornWorker", \
     "--bind", "0.0.0.0:8000", \
     "--timeout", "60", \
     "--access-logfile", "-"]
```

Com 2 workers em um ambiente com 1–2 vCPUs, o footprint de memória fica em torno de 80–120MB — viável para o Living Lab. O `--access-logfile -` envia logs para stdout, que é capturado pelo Docker e pelo Loki/Promtail sem configuração adicional.

---

### 4. Testes e Qualidade

A stack de testes recomendada para o PRJ008:**Detalhamento das ferramentas:**

`pytest` é o padrão absoluto do ecossistema Python. `pytest-cov` gera relatório de cobertura em formato que o CI/CD (GitHub Actions, GitLab CI) consome nativamente. `Faker` com `locale='pt_BR'` gera nomes com acentuação real — o único mock de dados confiável para testar encoding de identidades brasileiras.

`testcontainers-python` é o diferencial: ele sobe um container MariaDB real durante o suite de integração, executa os testes contra dados reais, e destrói o container ao final. Nenhum banco de dados mockado — o ORM e o charset são testados contra o motor real. Isso captura bugs que mocks nunca capturam.

`schemathesis` faz fuzzing automático baseado no seu contrato OpenAPI: gera inputs válidos e inválidos, testa boundary conditions, e verifica que a API nunca retorna 500 para inputs inesperados. É especialmente valioso para endpoints SCIM onde o midPoint pode enviar payloads parciais.

---

### 5. Documentação de API: OpenAPI 3.1 via FastAPI nativo

FastAPI gera documentação OpenAPI 3.1 automaticamente a partir dos type hints e modelos Pydantic — sem configuração adicional. O endpoint `/docs` (Swagger UI) e `/redoc` (ReDoc) ficam disponíveis out of the box.

Para o midPoint consumir o contrato sem ambiguidades, algumas práticas são obrigatórias no código:

Cada endpoint deve ter `response_model` explícito com um schema Pydantic. Cada campo do schema deve ter `description` e `example` preenchidos. Campos que representam identifiers do AD/SCIM devem usar `Field(pattern=r"...")` para deixar o contrato machine-readable. O midPoint tem um conector SCIM nativo — ao expor os endpoints no padrão RFC 7644 (SCIM 2.0), o midPoint consegue importar o contrato diretamente e configurar o provisioning sem programação adicional.

O endpoint `/openapi.json` deve ser versioned (`/v1/openapi.json`) para que mudanças de schema não quebrem silenciosamente a integração com o IGA.

---

### 6. Integração com Vault: `hvac` + AppRole + cache em memória

A biblioteca `hvac` (HashiCorp Vault API Client) é o cliente oficial Python para o Vault, open source, bem mantida. O padrão de integração recomendado para um container FastAPI:

```python
import hvac
import os
from functools import lru_cache
from datetime import datetime, timedelta

class VaultClient:
    def __init__(self):
        self._client = hvac.Client(url=os.environ["VAULT_ADDR"])
        self._db_creds = None
        self._creds_expiry = None

    def _authenticate(self):
        self._client.auth.approle.login(
            role_id=os.environ["VAULT_ROLE_ID"],
            secret_id=os.environ["VAULT_SECRET_ID"],
        )

    def get_db_credentials(self) -> dict:
        if self._db_creds and datetime.now() < self._creds_expiry:
            return self._db_creds
        self._authenticate()
        lease = self._client.secrets.database.generate_credentials(
            name="orangehrm-readonly"
        )
        self._db_creds = lease["data"]
        ttl = lease["lease_duration"]
        self._creds_expiry = datetime.now() + timedelta(seconds=ttl * 0.75)
        return self._db_creds
```

Pontos críticos deste padrão: o `secret_id` vem de variável de ambiente injetada pelo orchestrator (não de arquivo), o cache em memória respeita 75% do TTL da lease (renovação antes do vencimento), e nenhuma credencial é logada ou persistida em disco. O objeto `VaultClient` é instanciado como singleton no startup da aplicação FastAPI via `lifespan` context manager.

`VAULT_ROLE_ID` pode estar em variável de ambiente de container (não é secreto). `VAULT_SECRET_ID` deve ser injetado em runtime pelo `vault agent` ou pelo orchestrator com TTL de uso único.

---

### Veredito de valor: por que esta stack

O argumento definitivo não é técnico — é estratégico para o perfil IAM/GRC.O visualizador parece estar temporariamente indisponível, mas o argumento estratégico é claro e posso apresentá-lo diretamente.

---

### Veredito de valor — o argumento estratégico

A tabela comparativa em texto:

|Critério|Python + FastAPI|Java + Spring|Node.js|Go|
|---|---|---|---|---|
|Ecossistema IAM|`hvac`, `ldap3`, `msal`, `python-ldap`|Spring Security (bom)|Raso|Menor|
|Memória container|80–120 MB|400–800 MB|100–180 MB|20–40 MB|
|Suporte IA (geração)|Excelente|Bom|Bom|Regular|
|OpenAPI nativa|Automática via Pydantic|Springdoc (config)|Manual/lib|Manual/lib|
|Curva p/ IAM specialist|Baixa|Alta|Média|Alta|

Go vence em eficiência de memória — mas o ganho (60–80MB a menos) não justifica o custo de produtividade no contexto de um lab pessoal onde você é desenvolvedor, arquiteto e operador ao mesmo tempo. Java/Spring é a stack certa para times com engineers dedicados e arquitetura de longo prazo em enterprise. Não para um living lab de um especialista IAM que precisa de código funcionando em horas, não dias.

O argumento central é este: **Python com FastAPI é a única stack onde um profissional IAM/GRC — não um desenvolvedor full-time — consegue ir de zero a um endpoint SCIM seguro, documentado e testado em uma tarde**. Isso não é simplificação; é o que diferencia um laboratório produtivo de um projeto abandonado na metade.

Do ponto de vista de valorização profissional: Python é a língua franca de automação em segurança (Ansible, scripts de auditoria, integrações SIEM), FastAPI está nos top-5 frameworks mais citados em JDs de IAM Engineer e Security Automation Engineer. Dominar essa stack entrega portabilidade de conhecimento para os contextos onde você já trabalha — ao contrário de Go, que traz prestígio técnico mas com menor relevância direta para o nicho IAM/GRC brasileiro.

---

**Stack final recomendada para o PRJ008:**

`Python 3.12` + `FastAPI` + `SQLAlchemy Core` + `Pydantic v2` + `Gunicorn/Uvicorn` + `hvac` + `pytest/testcontainers` + `schemathesis`

Todas as ferramentas são open source, todas têm comunidade ativa, todas têm suporte de primeira classe em ferramentas de IA, e todas se encaixam em um container com menos de 200MB de footprint total.


# Contrato OpenAPI


**Papel:** Atue como um Arquiteto de Soluções IGA (especialista em midPoint e SailPoint).

**Missão:** Revisar o contrato OpenAPI (JSON) de uma Shadow API que servirá de fonte para o provisionamento de identidades. O objetivo é garantir que o contrato seja resiliente a mudanças, trate corretamente a integridade dos dados e facilite a correlação no Active Directory.

**Contexto Técnico:**

- **Source of Truth:** MariaDB (OrangeHRM).
    
- **Encoding:** UTF-8 mandatório (NFC Normalization).
    
- **Identificador Único:** Devemos usar `emp_number` (numérico) ou `user_name` (string) como âncora? Justifique.
    

**Desafio de Design:** Proponha o **Esquema JSON (OpenAPI 3.0)** para o endpoint `GET /api/v1/employees` considerando:

1. **Atributos Obrigatórios:** Além de nome e e-mail, quais atributos de "Ciclo de Vida" (status, data de contratação, cargo) são indispensáveis para que o IGA execute processos de Joiner/Mover/Leaver sem erros?
    
2. **Normalização de Nomes:** Como o contrato deve descrever o campo de nome para garantir que o consumidor receba caracteres acentuados (ex: André, Vitória) sem corrupção?
    
3. **Segurança do Contrato:** O contrato deve prever paginação (`limit/offset`) e `ETags` para evitar sobrecarga no IGA?
    
4. **Tratamento de Nulos:** Qual a melhor prática para campos vazios no RH para evitar que o midPoint limpe atributos incorretamente no AD?
    

**Restrição de Auditoria:** O contrato deve ser agnóstico à ferramenta, focado na **ISO 27001 (Integridade do Dado)**. Forneça o YAML/JSON de exemplo e um parecer sobre os riscos de usar um contrato mal definido nesta fase.

### Parecer DEEPSEEK

## Parecer Técnico: Revisão do Contrato OpenAPI para Shadow API (IGA)

**Arquiteto:** Especialista em IGA (midPoint/SailPoint)  
**Objetivo:** Provisionamento de identidades - OrangeHRM → midPoint → Active Directory  
**Foco:** Integridade de dados, encoding UTF-8, correlação AD

---

## 1. Identificador Único: **`emp_number` (Numérico) como Âncora Primária**

### Veredito: `emp_number` como `externalId` | `user_name` como atributo secundário

| Critério | `emp_number` (INT) | `user_name` (VARCHAR) | Decisão |
|----------|--------------------|------------------------|----------|
| **Imutabilidade** | 🏆 Imutável (nunca muda) | Risco (muda com casamento/nome social) | `emp_number` vence |
| **Correlação AD** | 🏆 `employeeID` no AD aceita número | Conflito (já é `sAMAccountName`) | `emp_number` ideal |
| **Caracteres Especiais** | 🏆 Apenas dígitos | Acentos, espaços, pontos | `emp_number` mais seguro |
| **Performance** | 🏆 Índice numérico (rápido) | String (mais lento) | `emp_number` vence |
| **Reconciliação midPoint** | 🏆 `externalId` nativo | Precisa de script | `emp_number` recomendado |

**Parecer Técnico:**
```yaml
# midPoint resource configuration
resource:
  schemaHandling:
    objectTypes:
      - kind: account
        focus:
          type: User
          attributeMapping:
            - source: attributes.emp_number
              target: externalId  # MIDPOINT NÃO ALTERA!
            - source: attributes.user_name
              target: name
            - source: attributes.emp_number
              target: ri:employeeNumber  # AD attribute
```

**Risco do `user_name` como âncora:**
- Mudança de nome social → Quebra correlação → Duplica identidade no AD
- Caracteres como "José Maria" → Problemas com escaping no LDAP
- **Conclusão:** Use `emp_number` para correlação, `user_name` apenas para display.

---

## 2. Atributos Indispensáveis para Joiner/Mover/Leaver

### Esquema Mínimo Obrigatório:

```json
{
  "emp_number": 1001,                    // ANCHOR (imutável)
  "user_name": "joao.silva",             // LOGIN ID
  "nome_completo": "João Silva Santos",  // DISPLAY NAME
  "email": "joao.silva@empresa.com",     // PRIMARY SMTP
  "status": "ACTIVE",                    // Joiner/Mover/Leaver
  "data_admissao": "2024-01-15",         // Joiner trigger
  "data_demissao": null,                 // Leaver trigger (nullable)
  "cargo": "Analista de Segurança Sr.",  // Role/title
  "departamento": "TI - Segurança",      // OU mapping
  "gestor_emp_number": 1002,             // Manager correlation
  "tipo_contrato": "CLT",                // HR classification
  "ultima_atualizacao": "2025-04-10T14:30:00Z"  // ETag base
}
```

**Justificativa por Fase do Ciclo de Vida:**

| Fase | Atributo | Ação no midPoint |
|------|----------|------------------|
| **Joiner** | `data_admissao` | Criar conta AD 30 dias antes (pré-boarding) |
| **Joiner** | `status=ACTIVE` | Habilitar conta no dia da admissão |
| **Mover** | `cargo` + `departamento` | Mover OU, ajustar grupos |
| **Mover** | `gestor_emp_number` | Atualizar manager no AD |
| **Leaver** | `data_demissao != null` | Iniciar workflow de desligamento |
| **Leaver** | `status=INACTIVE` | Desabilitar conta (não deletar!) |

**Crítico para ISO 27001:** `data_demissao` com valor presente **deve** iniciar revogação de acessos em até 4 horas.

---

## 3. Normalização de Nomes (Encoding UTF-8 NFC)

### Contrato OpenAPI para Garantir Integridade:

```yaml
components:
  schemas:
    Employee:
      properties:
        nome_completo:
          type: string
          description: |
            Nome completo em UTF-8 Normalization Form C (NFC).
            Exemplo: "João" (U+00E3o) NÃO "Jo~ao" (U+0065 + U+0303)
          pattern: '^[\p{L}\p{M}\p{Z}\p{P}]{2,100}$'
          example: "André Vitória São João"
          x-content-type: "text/plain; charset=utf-8"
          x-validation: "NFC_normalized"
```

**Middleware Obrigatório no Código (Rust/Go):**
```rust
// Força NFC normalization antes de serializar
fn normalize_utf8(s: &str) -> String {
    s.nfc().collect::<String>()  // Rust: unicode-normalization crate
}

// No handler
let employee = Employee {
    nome_completo: normalize_utf8(db_row.nome_completo),
    // ...
};
```

**Resposta HTTP Header:**
```http
Content-Type: application/json; charset=utf-8
Content-Transfer-Encoding: 8bit  # Indica UTF-8 puro
ETag: "hash_do_registro"          # Varia se encoding mudar
```

**Por que NFC e não NFD?**
- Windows/AD usa NFC (composed characters)
- Linux/macOS podem normalizar diferente - **force NFC no servidor**

---

## 4. Paginação e ETags (Obrigatório para midPoint)

### Estrutura de Paginação:

```yaml
paths:
  /api/v1/employees:
    get:
      parameters:
        - name: limit
          in: query
          schema: { type: integer, default: 100, maximum: 1000 }
        - name: offset
          in: query
          schema: { type: integer, default: 0 }
        - name: modified_since
          in: query
          schema: { type: string, format: date-time }
          description: "Reconciliation incremental"
      responses:
        200:
          headers:
            X-Total-Count:
              schema: { type: integer }
            ETag:
              schema: { type: string }
              description: "Hash de todo o conjunto (página atual)"
          content:
            application/json:
              schema:
                type: object
                properties:
                  items: { type: array, items: { $ref: '#/components/schemas/Employee' } }
                  next_offset: { type: integer, nullable: true }
                  total_count: { type: integer }
                  hash_consistencia: { type: string }
                    description: "MD5 de todos os emp_numbers + ultima_atualizacao"
```

**Riscos sem ETag/Paginação:**
- midPoint tenta baixar 50k usuários de uma vez → timeout/out-of-memory
- Sem `modified_since`, IGA faz full scan a cada hora → sobrecarga no MariaDB
- Sem `hash_consistencia`, não detecta corrupção silenciosa de encoding

**Exemplo de Uso no midPoint (Resource Configuration):**
```xml
<reconciliation>
  <incremental>
    <tokenUrl>https://shadow-api/api/v1/employees?modified_since={token}</tokenUrl>
    <tokenVariableName>modified_since</tokenVariableName>
  </incremental>
  <pageSize>200</pageSize>
  <pagingStyle>offset</pagingStyle>
</reconciliation>
```

---

## 5. Tratamento de Nulos (Evitar Limpeza Indevida no AD)

### Regra de Ouro no Contrato:

```yaml
components:
  schemas:
    Employee:
      properties:
        data_demissao:
          type: string
          format: date
          nullable: true
          description: |
            NULL = funcionário ativo (NÃO enviar campo vazio!)
            "2025-04-10" = data de desligamento
          x-midpoint-strategy: "REPLACE"  # Envia NULL para limpar AD
        telefone_ramal:
          type: string
          nullable: false  # SEMPRE enviar string vazia se não existir
          default: ""
          description: |
            IMPORTANTE: Enviar "" (vazio) se não tiver, NÃO omitir o campo
```

**Comportamento no midPoint (Crítico):**

| Envio do JSON | midPoint Interpreta | Ação no AD |
|---------------|---------------------|------------|
| `"data_demissao": null` | Valor nulo | Limpa atributo `employeeLeaveDate` |
| Campo omitido (`{}`) | Mantém valor anterior | **NÃO LIMPA!** (causa drift) |
| `"data_demissao": ""` | String vazia | Erro (tipo mismatch) |
| `"telefone_ramal": ""` | String vazia | Atualiza para vazio (correto) |

**Regra ISO 27001:** Campos obrigatórios sempre presentes. Campos opcionais com `nullable: true` para limpeza explícita.

**Boa Prática:** Documentar no contrato via `x-nullability` extension:
```yaml
x-handling-null:
  - attribute: data_demissao
    action: "Send NULL to clear AD attribute"
  - attribute: telefone_ramal
    action: "Send empty string, never NULL"
```

---

## 6. Contrato OpenAPI Completo (JSON/YAML)

### OpenAPI 3.0.3 - Shadow API para midPoint

```yaml
openapi: 3.0.3
info:
  title: Shadow API - OrangeHRM to midPoint
  version: 1.0.0
  description: |
    Provisionamento de identidades com garantia de encoding UTF-8 NFC.
    ISO 27001:2022 - A.9.1.2 (Access to networks and systems)

servers:
  - url: https://shadow-api.internal:8080/api/v1
    description: Ambiente interno (Mesh VPN)

paths:
  /employees:
    get:
      summary: Lista funcionários com paginação
      parameters:
        - name: limit
          in: query
          schema: { type: integer, minimum: 1, maximum: 500, default: 100 }
        - name: offset
          in: query
          schema: { type: integer, minimum: 0, default: 0 }
        - name: modified_since
          in: query
          schema: { type: string, format: date-time }
          description: Incremental reconciliation (RFC 3339)
      responses:
        200:
          headers:
            X-Total-Count:
              schema: { type: integer }
              description: Total de registros (ignorando paginação)
            ETag:
              schema: { type: string }
              description: W/"hash_do_conjunto"
          content:
            application/json; charset=utf-8:
              schema:
                $ref: '#/components/schemas/EmployeeList'
        400:
          description: Parâmetros inválidos (ex: offset negativo)
        429:
          description: Rate limit excedido (100 req/min)

  /employees/{emp_number}:
    get:
      parameters:
        - name: emp_number
          in: path
          required: true
          schema: { type: integer, minimum: 1 }
      responses:
        200:
          headers:
            ETag:
              schema: { type: string }
              description: W/"hash_do_registro"
          content:
            application/json; charset=utf-8:
              schema:
                $ref: '#/components/schemas/Employee'
        404:
          description: Funcionário não encontrado ou inativo

components:
  schemas:
    EmployeeList:
      type: object
      required: [items, total_count]
      properties:
        items:
          type: array
          items: { $ref: '#/components/schemas/Employee' }
        next_offset:
          type: integer
          nullable: true
          description: Próximo offset (null se fim)
        total_count:
          type: integer
          minimum: 0
        consistency_hash:
          type: string
          pattern: '^[a-f0-9]{32}$'
          description: MD5 de emp_numbers + ultima_atualizacao (detecta corrupção)

    Employee:
      type: object
      required:
        - emp_number
        - nome_completo
        - email
        - status
        - data_admissao
        - cargo
        - ultima_atualizacao
      properties:
        emp_number:
          type: integer
          minimum: 1
          description: ANCHOR - Nunca muda (employeeID no AD)
          example: 10042
        
        user_name:
          type: string
          pattern: '^[a-z0-9._]{3,50}$'
          description: Login para sAMAccountName (pode mudar)
          example: "maria.santos"
        
        nome_completo:
          type: string
          minLength: 3
          maxLength: 100
          pattern: '^[\p{L}\p{M}\p{Z}\p{P}]+$'
          description: |
            UTF-8 NFC normalizado. Ex: "André" (U+00E9) NÃO "Andre\u0301"
          example: "Ana Vitória São João"
        
        email:
          type: string
          format: email
          maxLength: 100
          example: "ana.vitoria@empresa.com.br"
        
        status:
          type: string
          enum: [ACTIVE, INACTIVE, ONBOARDING, OFFBOARDING]
          description: Joiner/Mover/Leaver state machine
          example: ACTIVE
        
        data_admissao:
          type: string
          format: date
          description: ISO 8601 date (YYYY-MM-DD)
          example: "2024-03-15"
        
        data_demissao:
          type: string
          format: date
          nullable: true
          description: |
            NULL = ativo. Data presente = iniciar revogação de acessos (máx 4h)
          example: null
        
        cargo:
          type: string
          maxLength: 100
          example: "Engenheiro de Segurança Pleno"
        
        departamento:
          type: string
          maxLength: 100
          example: "TI - Governança e Risco"
        
        gestor_emp_number:
          type: integer
          nullable: true
          description: Manager correlation (employeeID do gestor)
          example: 1001
        
        tipo_contrato:
          type: string
          enum: [CLT, PJ, Estagiário, Terceiro]
          default: CLT
        
        ultima_atualizacao:
          type: string
          format: date-time
          description: Timestamp da última mudança (ETag base)
          example: "2025-04-10T14:30:00-03:00"

  securitySchemes:
    mTLS:
      type: http
      scheme: mutual
      description: mTLS com certificados gerenciados pelo Vault
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: JWT com curta duração (15 min)

security:
  - mTLS: []
  - BearerAuth: []
```

---

## 7. Riscos de um Contrato Mal Definido (Parecer Final)

### Riscos Críticos para ISO 27001:

| Risco | Impacto | Exemplo Real |
|-------|---------|---------------|
| **Sem âncora imutável** | Duplicação de identidades | `user_name` muda → midPoint cria novo usuário no AD → dois objetos para mesma pessoa |
| **Sem `data_demissao`** | Ex-funcionário mantém acesso | Desligamento não revoga VPN/email por dias (violação A.9.2.6) |
| **Sem paginação** | API derruba IGA | midPoint tenta `GET /employees` com 50k registros → OOM kill |
| **Sem ETag** | Corrupção silenciosa | Encoding muda de ISO-8859-1 para UTF-8 → "João" vira "JoÃ£o" no AD |
| **Campo omitido vs null** | Atributo AD não limpo | `"data_demissao": null` (limpa) vs omitido (mantém) → ex-funcionário ativo |
| **Sem `modified_since`** | Sobrecarga no banco | Full scan a cada hora em 100k usuários → IOPS no MariaDB disparam |
| **Sem validação UTF-8** | Dado corrompido no AD | "Vitória" → "VitÃ³ria" (quebra busca por nome) |

### Non-Negotiables do Contrato (Auditoria):

1. **Âncora imutável:** `emp_number` como `externalId` - documentado explicitamente
2. **Campos de ciclo de vida:** `status` + `data_admissao` + `data_demissao` (todos obrigatórios)
3. **Encoding:** Header `Content-Type: application/json; charset=utf-8` e validação NFC
4. **Paginação:** `limit` e `offset` obrigatórios (nunca retornar lista sem paginar)
5. **Nullabilidade:** Todo campo opcional com `nullable: true` e documentação clara
6. **ETag:** Resposta de lista deve incluir `consistency_hash` (MD5 dos IDs + timestamps)
7. **Rate Limit:** 429 Too Many Requests implementado (protege o MariaDB)

### Veredito do Arquiteto IGA:

> **Contrato APROVADO com ressalvas.**  
> A implementação **deve** incluir middleware que valide UTF-8 NFC em todas as respostas. O midPoint será configurado com `reconciliation > incremental > modified_since` para evitar full scans. O campo `consistency_hash` será usado em health check periódico: se o hash da API divergir do hash calculado pelo midPoint, o pipeline de dados está corrompido (acionar alerta SRE imediato).

**Risco Residual Aceito:** Mudança no `emp_number` (quase impossível no OrangeHRM). Se ocorrer, requer reconciliação manual via script de migração. Documentar no Runbook.

**Próximo Passo:** Configurar Webhook no midPoint para consumir mudanças via `POST /api/v1/employees/webhook` (real-time sync), com fallback para polling a cada 15 minutos.


### PARECER CLAUDE

Excelente questão — este é exatamente o tipo de decisão que define se um projeto IGA vai ter sucesso ou virar um problema de manutenção nos próximos anos.

Vou estruturar a resposta em duas partes: o parecer arquitetural com as decisões fundamentadas, e o contrato OpenAPI 3.0 completo.

---

## Decisão sobre o Identificador (Âncora)

**Use `emp_number` como âncora primária, com `user_name` como atributo correlacionável secundário.**

O `emp_number` é numérico, gerado pelo sistema (sem intervenção humana), imutável por design no OrangeHRM e não carrega semântica de negócio — isso elimina a tentação de alterá-lo quando alguém muda de cargo ou sobrenome. Já o `user_name` é frequentemente reaproveitado, pode ser alterado pelo RH, e em ambientes com alto turnover (como o seu lab simulando FP001–FP100) gera colisões de correlação no midPoint.

No contexto do Living Lab Fiqueok, você já aprendeu a lição do PRJ015: o `EmployeeID` no AD deve mapear 1:1 para `emp_number`. Se você tivesse usado `user_name` como âncora no Cloud Sync, as proxyAddress conflicts seriam ainda mais difíceis de diagnosticar porque o campo carrega estado mutável.

---

## Atributos de Ciclo de Vida (Joiner/Mover/Leaver)

Para que o IGA execute os três processos sem erros, os campos abaixo são indispensáveis além de nome e e-mail:

**Joiner:** `hire_date`, `employment_status`, `job_title`, `department`, `emp_number` (âncora), `manager_id` (para provisionar grupos hierárquicos).

**Mover:** `job_title`, `department`, `manager_id` e `effective_date` (para saber _quando_ o trigger deve disparar, não apenas _que_ aconteceu).

**Leaver:** `termination_date`, `employment_status` com valor explícito `"terminated"`, e um campo `last_working_day` separado — porque em muitas organizações o vínculo formal termina dias depois do último dia ativo, e o IGA precisa saber qual data usar para revogar acessos.

---

## Normalização de Nomes (André, Vitória)

O contrato deve declarar explicitamente `charset: utf-8` no `Content-Type` e documentar que todos os campos de string seguem **NFC (Unicode Normalization Form C)**. Isso é crítico porque o AD armazena strings em UTF-16LE, e se o source entregar NFD (decomposto), você terá `André` representado como `A` + `n` + `d` + `r` + `e\u0301` — 6 code points em vez de 5 — causando mismatches silenciosos na correlação de contas existentes.

---

## Tratamento de Nulos (Anti-pattern midPoint)

Este é o ponto mais subestimado em projetos IGA. A melhor prática é **nunca retornar `null` para campos que existem mas estão vazios no RH** — em vez disso, **omitir o campo do payload**. O motivo: o midPoint em modo `RECONCILIATION` interpreta `null` em um atributo como instrução para limpar aquele valor no AD. Se o campo simplesmente não aparecer no JSON, o midPoint assume "sem mudança" e preserva o valor atual.

Isso deve estar documentado no contrato com `nullable: false` e os campos opcionais usando `required: false` sem default `null`.

---

## Paginação e ETags

Sim, são obrigatórios para produção, mesmo em lab. Sem paginação, um connector midPoint que processa 100 usuários hoje vai travar quando o lab crescer. Com `ETag` + `If-None-Match`, o IGA pode fazer polling frequente sem sobrecarregar o endpoint — o servidor responde `304 Not Modified` se nada mudou, e o midPoint não dispara reconciliação desnecessária.

---

Agora o contrato:Agora o contrato OpenAPI 3.0 completo:---

## Parecer de Risco — Contrato Mal Definido Nesta Fase

Um contrato OpenAPI vago ou ausente neste ponto do ciclo IGA é o equivalente arquitetural do erro que você viveu no PRJ015: você só descobre o problema quando está desfazendo 100 operações incorretas.

**Risco 1 — Corrupção silenciosa de nomes (Alta probabilidade, Alto impacto).** Sem a declaração explícita de NFC, um campo `André` entregue em NFD resulta em `givenName` com 6 code points no AD. A conta é provisionada, funciona, mas a busca LDAP falha intermitentemente — dependendo do cliente LDAP, ele pode normalizar ou não na comparação.

**Risco 2 — Limpeza indevida de atributos (Alta probabilidade, Altíssimo impacto).** Sem a política de "omitir vs null", o midPoint em modo reconciliação pode limpar `telephoneNumber`, `l` (city) e `manager` de contas ativas toda vez que o campo não aparecer no payload. Esse bug é especialmente destrutivo porque não gera erro — ele apenas apaga dados silenciosamente.

**Risco 3 — Identidade fantasma no Leaver (Médio, Altíssimo impacto).** Sem `last_working_day` separado de `termination_date`, o processo Leaver usa a data errada e a conta AD permanece ativa por dias após o último acesso do empregado. Em um cenário com acesso a dados financeiros, isso é uma não-conformidade ISO 27001 A.9.2.6 direta.

**Risco 4 — Colisão de âncora se `user_name` for usado.** Em um lab com FP001–FP100, se você deletar FP050 e recriar com o mesmo `user_name`, o midPoint vai correlacionar a nova identidade com a conta AD existente da identidade anterior. Com `emp_number` isso é impossível — o número nunca se repete.

**Risco 5 — Sem paginação, primeira sincronização de produção é um ataque DoS interno.** Um endpoint que retorna 10.000 empregados em resposta única vai derrubar a memória do connector midPoint, ou pior, fazer o timeout ser interpretado como falha de autenticação e logar um falso positivo de segurança.


OPENAPI IGA EMPLOYESEES V1

openapi: "3.0.3"

info:
  title: "IGA Identity Source API — OrangeHRM Shadow"
  version: "1.0.0"
  description: |
    Shadow API que expõe identidades do OrangeHRM (MariaDB) para consumo por
    motores IGA (midPoint, SailPoint). Agnóstica à ferramenta.

    ## Decisões de design

    ### Âncora de identidade
    O campo `emp_number` (inteiro, gerado pelo sistema OrangeHRM) é a âncora
    imutável. Ele NUNCA deve ser reutilizado após desligamento. O atributo
    `user_name` é fornecido como campo correlacionável secundário, mas NÃO deve
    ser usado como chave de correlação por ser mutável.

    ### Encoding e normalização
    Todos os campos string são entregues em UTF-8 com normalização Unicode NFC
    (Canonical Decomposition followed by Canonical Composition). Isso garante
    que caracteres acentuados como `André`, `Vitória`, `Conceição` sejam
    representados como code points compostos, evitando mismatches silenciosos
    durante correlação no Active Directory (UTF-16LE).

    ### Tratamento de nulos
    Campos opcionais ausentes no RH são **omitidos do payload** (não enviados
    como `null`). Um campo `null` explícito seria interpretado por alguns
    motores IGA (incluindo midPoint em modo RECONCILIATION) como instrução para
    limpar o atributo correspondente no sistema alvo. A omissão preserva o
    estado atual no AD.

    ### Conformidade ISO 27001
    - A.8.3  — Classificação e tratamento de informações
    - A.8.24 — Uso de criptografia (TLS 1.2+ obrigatório)
    - A.5.28 — Registro de eventos (cada requisição deve ser auditada)

  contact:
    name: "Fiqueok Living Lab"
    url: "https://github.com/fiqueok"
  license:
    name: "Internal Use Only"

servers:
  - url: "https://iga-source.fiqueok.internal/api/v1"
    description: "Ambiente de laboratório (Living Lab Fiqueok)"
  - url: "https://iga-source.prod.fiqueok.com.br/api/v1"
    description: "Produção (futuro)"

# ---------------------------------------------------------------------------
# SEGURANÇA
# ---------------------------------------------------------------------------
security:
  - BearerAuth: []

components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: |
        Token JWT emitido pelo IdP interno. Claim obrigatória: `scope:iga:read`.
        Expiração máxima recomendada: 3600s (1 hora).

  # -------------------------------------------------------------------------
  # SCHEMAS
  # -------------------------------------------------------------------------
  schemas:

    # -- Empregado completo -------------------------------------------------
    Employee:
      type: object
      description: |
        Representação de um empregado para fins de provisionamento IGA.
        Campos omitidos indicam ausência de dado no RH — o consumidor NÃO deve
        interpretar a ausência como instrução de limpeza no sistema alvo.
      required:
        - emp_number
        - first_name
        - last_name
        - employment_status
        - hire_date
        - work_email
        - job_title
        - department
      properties:

        # -- Identificação --------------------------------------------------
        emp_number:
          type: integer
          format: int64
          description: |
            Identificador primário gerado pelo OrangeHRM. IMUTÁVEL.
            Usar como `employeeID` no AD e como âncora de correlação no IGA.
            NUNCA reutilizar após desligamento.
          example: 42
          readOnly: true

        user_name:
          type: string
          minLength: 1
          maxLength: 50
          description: |
            Login do empregado no OrangeHRM. MUTÁVEL — não usar como âncora
            de correlação. Fornecido apenas para referência cruzada.
            Encoding: UTF-8 NFC.
          example: "paulo.feitosa"

        # -- Nome -----------------------------------------------------------
        first_name:
          type: string
          minLength: 1
          maxLength: 100
          description: |
            Primeiro nome em UTF-8 NFC. Pode conter caracteres acentuados
            (ex: André, Conceição). O consumidor DEVE preservar a normalização
            NFC ao gravar no AD (atributo `givenName`).
          example: "André"

        middle_name:
          type: string
          maxLength: 100
          description: |
            Nome do meio. Opcional — omitido quando vazio no RH.
            Encoding: UTF-8 NFC.
          example: "Luiz"

        last_name:
          type: string
          minLength: 1
          maxLength: 100
          description: |
            Sobrenome em UTF-8 NFC. Mapeia para `sn` (surname) no AD.
          example: "Feitosa"

        display_name:
          type: string
          maxLength: 255
          description: |
            Nome completo normalizado para exibição. Calculado pelo backend
            como `first_name [middle_name] last_name`. Encoding: UTF-8 NFC.
            Mapeia para `displayName` no AD.
          example: "André Luiz Feitosa"
          readOnly: true

        # -- Contato --------------------------------------------------------
        work_email:
          type: string
          format: email
          maxLength: 254
          description: |
            E-mail corporativo. Deve ser único por empregado ativo.
            Mapeia para `mail` e `userPrincipalName` no AD (após formatação).
          example: "andre.feitosa@fiqueok.com.br"

        personal_email:
          type: string
          format: email
          maxLength: 254
          description: |
            E-mail pessoal. Opcional. NÃO usar para provisionamento de contas.
            Relevante apenas para processos de offboarding (notificação ao ex-empregado).
          example: "andre.pessoal@gmail.com"

        work_phone:
          type: string
          maxLength: 50
          description: |
            Telefone corporativo. Opcional. Mapeia para `telephoneNumber` no AD.
            Formato sugerido: E.164 (+55 11 91234-5678).
          example: "+55 11 91234-5678"

        # -- Ciclo de vida (CRÍTICO para JML) --------------------------------
        employment_status:
          type: string
          description: |
            Status do vínculo empregatício. CAMPO CRÍTICO para processos Leaver.
            O motor IGA deve monitorar transições para `terminated` e
            `on_leave` para acionar workflows de desativação/suspensão.
          enum:
            - active          # empregado ativo
            - terminated      # desligado (permanente)
            - on_leave        # licença (temporária — conta deve ser suspensa, não removida)
            - probation       # período de experiência
            - pre_start       # contratado mas ainda não iniciou
          example: "active"

        hire_date:
          type: string
          format: date
          description: |
            Data de início do vínculo (ISO 8601: YYYY-MM-DD).
            Trigger do processo Joiner. Uso recomendado: provisionar conta
            N dias úteis antes desta data.
          example: "2025-03-01"

        termination_date:
          type: string
          format: date
          description: |
            Data formal de encerramento do contrato (ISO 8601).
            Omitido se `employment_status` != `terminated`.
            IMPORTANTE: pode ser posterior ao `last_working_day` — usar
            `last_working_day` para revogar acessos, não este campo.
          example: "2025-12-31"

        last_working_day:
          type: string
          format: date
          description: |
            Último dia efetivo de trabalho (ISO 8601).
            Usar como data-gatilho para revogação de acessos no AD.
            Pode diferir de `termination_date` em casos de aviso prévio.
          example: "2025-12-20"

        effective_date:
          type: string
          format: date
          description: |
            Data de vigência de alterações de cargo/departamento.
            Omitido quando não há mudança pendente.
            Trigger do processo Mover — aguardar esta data antes de reprovisionar.
          example: "2026-04-01"

        rehire_eligible:
          type: boolean
          description: |
            Indica se o empregado pode ser recontratado. Relevante para
            Leaver: se `false`, marcar conta AD para não restaurar automaticamente.
          example: true

        # -- Cargo e organização (CRÍTICO para Mover) -----------------------
        job_title:
          type: string
          maxLength: 100
          description: |
            Cargo atual. Mapeia para `title` no AD.
            Encoding: UTF-8 NFC.
          example: "GRC Lead"

        department:
          type: string
          maxLength: 100
          description: |
            Departamento atual. Mapeia para `department` no AD.
            Usado para determinar OU de destino no provisionamento.
          example: "Tecnologia da Informação"

        sub_unit:
          type: string
          maxLength: 100
          description: |
            Subdivisão dentro do departamento. Opcional.
            Mapeia para `physicalDeliveryOfficeName` ou atributo extensionAttribute.
          example: "Segurança da Informação"

        cost_center:
          type: string
          maxLength: 50
          description: |
            Centro de custo. Opcional. Útil para controle de licenças e auditoria.
          example: "CC-TI-001"

        location:
          type: string
          maxLength: 100
          description: |
            Localização física (cidade/escritório). Opcional.
            Mapeia para `l` (locality) no AD.
          example: "São Paulo"

        company:
          type: string
          maxLength: 100
          description: |
            Razão social da empresa. Relevante em estruturas com múltiplas
            entidades usando o mesmo IGA. Mapeia para `company` no AD.
          example: "Fiqueok Consultoria Ltda."

        # -- Hierarquia -----------------------------------------------------
        manager_id:
          type: integer
          format: int64
          description: |
            `emp_number` do gestor direto. Omitido para cargos de topo hierárquico.
            Usar para popular `manager` (DN) no AD e para herança de políticas de acesso.
          example: 7

        # -- Metadados de integridade ---------------------------------------
        record_updated_at:
          type: string
          format: date-time
          description: |
            Timestamp da última modificação do registro no OrangeHRM (ISO 8601 UTC).
            Usar para detectar mudanças incrementais entre ciclos de sincronização.
            Formato: `YYYY-MM-DDTHH:mm:ssZ`.
          example: "2026-04-10T14:30:00Z"
          readOnly: true

      additionalProperties: false

    # -- Envelope de resposta paginada ------------------------------------
    EmployeeListResponse:
      type: object
      required:
        - data
        - pagination
        - meta
      properties:

        data:
          type: array
          items:
            $ref: "#/components/schemas/Employee"
          description: "Lista de empregados para a página solicitada."

        pagination:
          type: object
          required:
            - total
            - limit
            - offset
          properties:
            total:
              type: integer
              description: "Total de registros que correspondem ao filtro aplicado."
              example: 100
            limit:
              type: integer
              description: "Número de registros retornados nesta página."
              example: 25
            offset:
              type: integer
              description: "Deslocamento da primeira posição desta página."
              example: 0
            next_offset:
              type: integer
              description: "Offset para a próxima página. Omitido na última página."
              example: 25

        meta:
          type: object
          required:
            - generated_at
            - encoding
            - unicode_normalization
          properties:
            generated_at:
              type: string
              format: date-time
              description: "Timestamp de geração do payload (UTC)."
              example: "2026-04-10T14:30:00Z"
            encoding:
              type: string
              description: "Encoding dos campos string."
              enum: ["UTF-8"]
              example: "UTF-8"
            unicode_normalization:
              type: string
              description: |
                Forma de normalização Unicode aplicada a todos os campos string.
                NFC garante compatibilidade com Active Directory (UTF-16LE).
              enum: ["NFC"]
              example: "NFC"
            source_system:
              type: string
              description: "Identificador do sistema de origem."
              example: "OrangeHRM/MariaDB"

    # -- Erro padrão -------------------------------------------------------
    ApiError:
      type: object
      required:
        - code
        - message
        - timestamp
      properties:
        code:
          type: string
          example: "INVALID_PARAMETER"
        message:
          type: string
          example: "Parâmetro 'limit' deve ser entre 1 e 100."
        timestamp:
          type: string
          format: date-time
          example: "2026-04-10T14:30:00Z"
        details:
          type: object
          additionalProperties: true

  # -------------------------------------------------------------------------
  # PARÂMETROS REUTILIZÁVEIS
  # -------------------------------------------------------------------------
  parameters:

    LimitParam:
      name: limit
      in: query
      required: false
      schema:
        type: integer
        minimum: 1
        maximum: 100
        default: 25
      description: |
        Número máximo de registros por página.
        Recomendação para motores IGA: usar 25–50 para evitar timeouts em
        connectors com transformação de atributos complexa.

    OffsetParam:
      name: offset
      in: query
      required: false
      schema:
        type: integer
        minimum: 0
        default: 0
      description: "Posição de início para paginação."

    IfNoneMatchHeader:
      name: If-None-Match
      in: header
      required: false
      schema:
        type: string
      description: |
        Valor do ETag recebido em resposta anterior. Se o conjunto de dados não
        tiver sido modificado, o servidor responde 304 Not Modified sem body,
        economizando processamento no motor IGA.
      example: '"v1-abc123def456"'

# ---------------------------------------------------------------------------
# ENDPOINTS
# ---------------------------------------------------------------------------
paths:

  /employees:
    get:
      operationId: "listEmployees"
      summary: "Listar empregados (fonte IGA)"
      description: |
        Retorna a lista paginada de empregados para consumo por motores IGA.

        ## Comportamento de ETag
        O servidor calcula um ETag sobre o hash do conjunto de dados retornado
        (considerando filtros aplicados). Se o cliente enviar `If-None-Match`
        com o ETag anterior e os dados não mudaram, o servidor retorna `304`.

        ## Campos omitidos vs null
        Campos opcionais ausentes no OrangeHRM são **omitidos** do payload JSON.
        O consumidor deve tratar a ausência de um campo como "sem mudança" —
        nunca como instrução de limpeza no sistema alvo.

        ## Auditoria
        Cada chamada deve ser registrada com: timestamp, IP do solicitante,
        claims do JWT, filtros aplicados e quantidade de registros retornados.
        Requisito: ISO 27001 A.5.28.

      tags: ["Employees"]

      parameters:
        - $ref: "#/components/parameters/LimitParam"
        - $ref: "#/components/parameters/OffsetParam"
        - $ref: "#/components/parameters/IfNoneMatchHeader"

        - name: status
          in: query
          required: false
          schema:
            type: string
            enum:
              - active
              - terminated
              - on_leave
              - probation
              - pre_start
          description: |
            Filtrar por `employment_status`. Se omitido, retorna TODOS os
            status — incluindo `terminated`. O motor IGA DEVE processar
            registros `terminated` para acionar o processo Leaver.

        - name: updated_since
          in: query
          required: false
          schema:
            type: string
            format: date-time
          description: |
            Filtrar registros modificados após este timestamp (ISO 8601 UTC).
            Útil para sincronizações incrementais (delta sync).
            Exemplo: `2026-04-01T00:00:00Z`

        - name: department
          in: query
          required: false
          schema:
            type: string
            maxLength: 100
          description: "Filtrar por departamento (correspondência exata, case-insensitive)."

      responses:

        "200":
          description: "Lista de empregados retornada com sucesso."
          headers:
            ETag:
              description: |
                Hash do conjunto de dados retornado. Enviar em `If-None-Match`
                na próxima requisição para habilitar resposta 304.
              schema:
                type: string
              example: '"v1-abc123def456"'
            Content-Type:
              description: "Tipo de conteúdo com charset explícito."
              schema:
                type: string
              example: "application/json; charset=utf-8"
            X-RateLimit-Remaining:
              description: "Requisições restantes na janela atual."
              schema:
                type: integer
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/EmployeeListResponse"
              example:
                data:
                  - emp_number: 42
                    first_name: "André"
                    last_name: "Feitosa"
                    display_name: "André Feitosa"
                    work_email: "andre.feitosa@fiqueok.com.br"
                    employment_status: "active"
                    hire_date: "2025-03-01"
                    job_title: "GRC Lead"
                    department: "Tecnologia da Informação"
                    manager_id: 7
                    record_updated_at: "2026-04-10T14:30:00Z"
                  - emp_number: 43
                    first_name: "Vitória"
                    last_name: "Conceição"
                    display_name: "Vitória Conceição"
                    work_email: "vitoria.conceicao@fiqueok.com.br"
                    employment_status: "terminated"
                    hire_date: "2024-06-01"
                    termination_date: "2025-12-31"
                    last_working_day: "2025-12-20"
                    job_title: "Analista IAM"
                    department: "Tecnologia da Informação"
                    record_updated_at: "2026-01-02T08:00:00Z"
                pagination:
                  total: 100
                  limit: 25
                  offset: 0
                  next_offset: 25
                meta:
                  generated_at: "2026-04-10T14:30:00Z"
                  encoding: "UTF-8"
                  unicode_normalization: "NFC"
                  source_system: "OrangeHRM/MariaDB"

        "304":
          description: |
            Não modificado. Os dados não mudaram desde o ETag enviado.
            O motor IGA deve ignorar este ciclo de sincronização.

        "400":
          description: "Parâmetros inválidos."
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/ApiError"

        "401":
          description: "Token ausente ou inválido."
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/ApiError"

        "403":
          description: "Token válido mas sem a claim `scope:iga:read`."
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/ApiError"

        "429":
          description: |
            Rate limit excedido. O motor IGA deve implementar backoff exponencial.
          headers:
            Retry-After:
              schema:
                type: integer
              description: "Segundos até a próxima tentativa permitida."
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/ApiError"

        "500":
          description: "Erro interno. Não acionar reprocessamento automático sem backoff."
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/ApiError"

  /employees/{emp_number}:
    get:
      operationId: "getEmployee"
      summary: "Obter empregado por emp_number"
      description: |
        Retorna um único empregado pela âncora imutável `emp_number`.
        Usado pelo motor IGA para reconciliação individual e validação
        de correlação antes de criar/atualizar conta no AD.
      tags: ["Employees"]

      parameters:
        - name: emp_number
          in: path
          required: true
          schema:
            type: integer
            format: int64
          description: "Identificador imutável do empregado (âncora IGA)."
          example: 42

        - $ref: "#/components/parameters/IfNoneMatchHeader"

      responses:

        "200":
          description: "Empregado encontrado."
          headers:
            ETag:
              schema:
                type: string
              example: '"v1-emp42-xyz789"'
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Employee"

        "304":
          description: "Registro não modificado desde o ETag enviado."

        "404":
          description: "Empregado não encontrado."
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/ApiError"

        "401":
          description: "Token ausente ou inválido."
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/ApiError"

# ---------------------------------------------------------------------------
# TAGS
# ---------------------------------------------------------------------------
tags:
  - name: Employees
    description: |
      Endpoints de identidade para consumo por motores IGA.
      Todos os dados originam do OrangeHRM (MariaDB) via camada Shadow API.