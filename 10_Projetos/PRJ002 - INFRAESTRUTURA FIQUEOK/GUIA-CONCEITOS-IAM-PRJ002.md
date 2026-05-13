# Guia Didático de Conceitos IAM
## Tudo o que você precisava saber antes de executar o PRJ-002

**Para:** Paulo Feitosa  
**Nível:** N1 → N2  
**Objetivo:** Entender o que foi feito, por que foi feito, e o que significa cada componente  
**Método:** Conceito + analogia + conexão com o PRJ-002  

---

> **Como usar este documento**  
> Cada seção começa com uma analogia do mundo real, depois explica o conceito técnico, e termina conectando com o que você viveu no PRJ-002. Leia na ordem — cada conceito constrói sobre o anterior.

---

# PARTE 1 — O Problema que IAM Resolve

## 1.1 Por que gerenciar identidades?

Imagine uma empresa com 500 funcionários. Cada funcionário precisa de acesso a sistemas diferentes: e-mail, ERP, VPN, pastas de rede, aplicações internas. Quando alguém é contratado, alguém precisa criar a conta em cada sistema. Quando é demitido, alguém precisa desativar em todos. Quando muda de área, precisa perder alguns acessos e ganhar outros.

Feito manualmente, isso é caótico:
- Contas esquecidas de ex-funcionários continuam ativas (risco de segurança)
- Novo funcionário fica dias sem acesso ao que precisa (risco operacional)
- Ninguém sabe ao certo quem tem acesso a quê (risco de compliance)

**IAM (Identity and Access Management)** é a disciplina que resolve esse problema de forma sistemática, auditável e automatizada.

**IGA (Identity Governance and Administration)** é a camada de governança do IAM — não só gerencia, mas garante que os acessos estão corretos, revisados e justificados.

---

## 1.2 Os três momentos do ciclo de vida de uma identidade

Todo funcionário passa por três momentos que o IAM precisa tratar:

| Momento | Nome técnico | O que acontece |
|---------|-------------|----------------|
| Contratação | **Joiner** | Conta criada, acessos iniciais provisionados |
| Mudança de área | **Mover** | Acessos removidos e adicionados conforme nova função |
| Demissão | **Leaver** | Todas as contas desativadas imediatamente |

Esse ciclo se chama **JML (Joiner-Mover-Leaver)**. É o coração de qualquer projeto IGA.

**No PRJ-002:** O objetivo era automatizar o **Joiner** — quando um funcionário é cadastrado no OrangeHRM (RH), o midPoint detecta e cria automaticamente a conta no AD. Isso nunca foi atingido de forma automática, mas o linking manual (GMUD-016) provou que o caminho estava correto.

---

# PARTE 2 — Os Componentes do PRJ-002

## 2.1 O que é um Diretório de Identidades

**Analogia:** Pense em uma lista telefônica corporativa. Ela contém o nome de cada pessoa, seu ramal, departamento e cargo. Qualquer sistema da empresa pode consultar essa lista para saber quem é quem.

Um **diretório de identidades** é exatamente isso — um banco de dados especializado que armazena informações sobre usuários, grupos e computadores de forma hierárquica e consultável por qualquer sistema.

A diferença de um banco de dados comum é que o diretório é otimizado para **leituras rápidas** e usa um protocolo específico para ser consultado: o **LDAP**.

---

## 2.2 LDAP — A Língua dos Diretórios

**Analogia:** Se o diretório é uma lista telefônica, o LDAP é o idioma que você usa para perguntar: "Qual é o ramal do João Silva do departamento de TI?"

**LDAP (Lightweight Directory Access Protocol)** é o protocolo de comunicação usado para consultar e modificar diretórios de identidades. Ele define como fazer perguntas como:
- "Existe um usuário com login `joao.silva`?"
- "Quais grupos o usuário `joao.silva` pertence?"
- "Crie uma conta para `maria.souza` com esses atributos."

**LDAP vs LDAPS:**
- **LDAP** (porta 389) — comunicação sem criptografia. Os dados trafegam em texto claro na rede. Aceitável em lab isolado, proibido em produção.
- **LDAPS** (porta 636) — LDAP com TLS (criptografia). É o padrão seguro. Requer que o servidor tenha um certificado digital válido.

**No PRJ-002:** A GMUD-014 tentou usar LDAPS mas o AD não tinha certificado configurado no binding do serviço NTDS. A GMUD-016 usou LDAP 389 como decisão consciente de velocidade sobre segurança, aceita para lab.

---

## 2.3 Active Directory — O Diretório da Microsoft

O **Active Directory (AD)** é a implementação da Microsoft de um diretório de identidades baseado em LDAP. É o sistema mais usado em empresas para gerenciar usuários, computadores e políticas de acesso em redes Windows.

**Conceitos fundamentais do AD:**

**Domínio:** O "território" do AD. No PRJ-002, o domínio era `corp.fiqueok.com.br`. Todos os usuários e computadores pertencem a um domínio.

**DN (Distinguished Name):** O endereço completo e único de qualquer objeto no AD. É como o CEP completo de um imóvel.
```
CN=Paulo Lima,CN=Users,DC=corp,DC=fiqueok,DC=com,DC=br
```
Lendo da direita para esquerda: domínio `corp.fiqueok.com.br` → container `Users` → usuário `Paulo Lima`.

**sAMAccountName:** O login do usuário no domínio. É o que a pessoa digita para entrar no computador. No PRJ-002, era `paulo.lima`.

**Atributos:** Cada usuário no AD tem dezenas de atributos — `givenName` (primeiro nome), `sn` (sobrenome), `mail` (e-mail), `memberOf` (grupos), etc. A GMUD-016 descobriu 78 atributos na instância do PRJ-002.

**Domain Controller (DC):** O servidor que hospeda e gerencia o AD. No PRJ-002, era a VM `ID-P-01` no IP `xxx.xxx.xxx.xxx`.

**Service Account:** Uma conta criada especificamente para que um sistema (não uma pessoa) se autentique no AD. No PRJ-002, a conta `svc-midpoint` foi criada para que o midPoint pudesse ler e escrever no AD.

---

## 2.4 OrangeHRM — A Fonte Autoritativa

**O conceito de SSoT (Single Source of Truth):**

**Analogia:** Em uma empresa, quem decide se uma pessoa trabalha lá ou não? O RH. Quando o RH registra uma contratação, isso é a verdade oficial. O TI não inventa usuários — ele reage ao que o RH declara.

**SSoT** significa que existe uma única fonte que define a verdade sobre uma informação. Para identidades de funcionários, o SSoT é sempre o sistema de RH — porque é lá que contratação e demissão acontecem oficialmente.

O **OrangeHRM** é um sistema de gestão de RH open-source. No PRJ-002, ele foi escolhido como SSoT — a fonte autoritativa de identidades. Quando um funcionário existe no OrangeHRM, ele deve existir nos sistemas de TI. Quando é removido do OrangeHRM, deve ser removido de tudo.

**Por que isso importa:** No PRJ-015 (outro projeto seu), a violação de SSoT foi exatamente o que causou o problema — usuários foram criados no Entra ID antes de definir quem era a fonte de verdade, gerando conflitos.

**Banco de dados interno do OrangeHRM:** O OrangeHRM armazena os dados em MariaDB. A tabela principal de funcionários é `hs_hr_employee`, com colunas como `employee_id`, `empfirstname`, `emplastname`, `jobtitle`. Foi essa tabela que o conector DatabaseTable tentou ler diretamente.

---

## 2.5 midPoint — O Motor IGA

**Analogia:** Se o OrangeHRM é o RH que decide quem são os funcionários, e o AD é o diretório onde as contas existem, o midPoint é o gerente de TI que fica olhando o RH o tempo todo e traduz as mudanças em ações nos sistemas.

O **midPoint** é uma plataforma IGA open-source desenvolvida pela Evolveum (empresa tcheca). Ele é o equivalente open-source do SailPoint IdentityIQ.

**O que o midPoint faz:**
- Lê dados de fontes autoritativas (OrangeHRM, CSV, LDAP)
- Aplica regras de transformação e mapeamento
- Cria, modifica ou desativa contas em sistemas-alvo (AD, LDAP, aplicações)
- Mantém rastreabilidade de todas as ações
- Executa certificações de acesso e políticas

**Como o midPoint armazena seus dados:** O midPoint usa um banco de dados PostgreSQL com um schema próprio chamado **Sqale Repository** (introduzido na versão 4.4). Esse schema tem mais de 100 tabelas criadas por scripts SQL específicos — não podem ser criadas manualmente.

**No PRJ-002:** A GMUD-008 resolveu exatamente o problema de inicializar o schema Sqale corretamente via init container, em vez de tentar criar as tabelas manualmente.

---

# PARTE 3 — Como o midPoint Funciona Por Dentro

Esta é a parte mais importante para entender o que aconteceu no PRJ-002.

## 3.1 O Modelo de Objetos do midPoint

O midPoint trabalha com três tipos principais de objetos. Entender a diferença entre eles é fundamental.

---

### Resource (Recurso)

**O que é:** A definição de um sistema externo com o qual o midPoint vai se comunicar. É como uma ficha de configuração que diz: "Para falar com o OrangeHRM, use este driver, este endereço, estas credenciais, e espere encontrar estes atributos."

No PRJ-002, havia dois Resources:
- **Resource OrangeHRM** — apontava para o MariaDB do OrangeHRM
- **Resource AD** — apontava para o Active Directory via LDAP

Um Resource não faz nada sozinho. Ele é só a configuração de como se conectar.

---

### Shadow (Conta/Projeção)

**Analogia:** Imagine que o midPoint é um espelho. Cada conta que existe em um sistema externo (AD, OrangeHRM) tem um reflexo dentro do midPoint. Esse reflexo é o Shadow.

**O que é:** Uma representação interna de uma conta que existe em um sistema externo. O Shadow guarda os atributos que o midPoint leu daquele sistema.

**Importante:** O Shadow é a conta no sistema externo vista pelo midPoint. Não é a identidade da pessoa — é a conta dela em um sistema específico.

Exemplos:
- Shadow OrangeHRM do Paulo Lima: `{ employeeId: "0001", empfirstname: "Paulo", emplastname: "Lima" }`
- Shadow AD do Paulo Lima: `{ sAMAccountName: "paulo.lima", givenName: "Paulo", sn: "Lima" }`

**No PRJ-002:** A GMUD-019 descobriu que Import Tasks criavam Shadows corretamente, mas não criavam o User (Focus). Isso confundia porque a task dizia "SUCCESS" mas nenhum usuário aparecia na lista.

---

### User / Focus (Identidade)

**Analogia:** Se o Shadow é o reflexo de uma conta em um sistema, o User é a pessoa real. Uma pessoa pode ter múltiplos reflexos (conta no AD, conta no OrangeHRM, conta no ServiceNow), mas é sempre a mesma identidade.

**O que é:** O objeto central do midPoint que representa a identidade da pessoa. É onde os atributos consolidados ficam — nome, e-mail, departamento — independente de qual sistema originou essa informação.

**A relação Shadow ↔ User:**
```
User (Paulo Feitosa)
├── Shadow OrangeHRM (employeeId: 0001)
└── Shadow AD (sAMAccountName: paulo.lima)
```

O processo de conectar um Shadow a um User se chama **Linking**. Isso pode acontecer de duas formas:
- **Automático:** O midPoint usa regras de correlação para descobrir que o Shadow do OrangeHRM e o Shadow do AD pertencem ao mesmo User
- **Manual:** O administrador faz o linking na interface — foi o que a GMUD-016 fez

**O `User.name` obrigatório:** O midPoint exige que todo User tenha um atributo `name` preenchido — é o identificador único interno. A GMUD-023 descobriu que quando o inbound mapping não populava `User.name`, o midPoint criava o Shadow mas rejeitava silenciosamente a criação do User. A solução foi mapear `employeeId → User.name`.

---

## 3.2 O Fluxo de Sincronização

Agora que você conhece os três objetos, entenda como eles se conectam no fluxo:

```
[OrangeHRM MariaDB]
        ↓
   Resource lê os dados
        ↓
   Shadow criado (reflexo da conta no OrangeHRM)
        ↓
   Correlation Rule verifica:
   "Existe um User com este employeeId?"
        ↓
   SE SIM → Link Shadow ao User existente
   SE NÃO → Reaction: addFocus → CRIA novo User
        ↓
   Inbound Mapping popula atributos do User
   (empfirstname → givenName, etc.)
        ↓
   Outbound Mapping provisiona no AD
   (givenName → AD.givenName, etc.)
        ↓
   [Active Directory]
```

**O que quebrou no PRJ-002:**

O passo `addFocus` (criar novo User quando não encontra correlação) nunca executou com o OrangeHRM como fonte. O midPoint 4.10 introduziu mudanças no mecanismo de Smart Correlation que alteraram esse comportamento sem documentação clara — foi isso que a GMUD-019 identificou como Early Adopter Risk.

---

## 3.3 Connectors — Como o midPoint Fala com Sistemas Externos

O midPoint não sabe falar com o AD, OrangeHRM ou qualquer outro sistema nativamente. Ele usa **connectors** — plugins que implementam a comunicação com cada tipo de sistema.

**ICF (Identity Connector Framework):** É o padrão de interface que todos os connectors do midPoint seguem. Define que todo connector deve implementar operações básicas: criar conta, ler conta, modificar conta, deletar conta, listar contas.

**Connectors incluídos na imagem Docker padrão do midPoint:**

| Connector               | Para quê serve                        | Incluído?          |
| ----------------------- | ------------------------------------- | ------------------ |
| LDAP Connector          | AD, OpenLDAP, qualquer LDAP           | ✅ Sim              |
| CSV Connector           | Arquivos CSV como fonte               | ✅ Sim              |
| DatabaseTable Connector | Tabelas de banco de dados via JDBC    | ✅ Sim              |
| ScriptedSQL Connector   | Banco via scripts Groovy customizados | ❌ Não (JAR manual) |
| REST Connector          | APIs REST genéricas                   | ❌ Não (JAR manual) |

**DatabaseTable Connector:** Conecta diretamente a uma tabela de banco de dados. Simples de configurar, mas limitado — não suporta bem schemas complexos como o do OrangeHRM. Foi o conector escolhido no PRJ-002, e foi a escolha errada.

**ScriptedSQL Connector:** Permite escrever scripts Groovy para customizar cada operação SQL. Muito mais flexível. Requer que o JAR seja instalado manualmente no diretório `/opt/midpoint/lib/` do container. A GMUD-018 falhou por não ter feito isso antes de executar.

**JDBC (Java Database Connectivity):** É a interface padrão do Java para conectar a bancos de dados. O `mariadb-java-client-3.1.2.jar` que foi injetado no PRJ-002 é o driver JDBC do MariaDB — sem ele, o midPoint não consegue nem abrir conexão com o banco do OrangeHRM.

---

## 3.4 Schema Handling e Mapeamentos

**Schema Handling:** É a configuração que diz ao midPoint quais atributos existem em um sistema externo e como eles se chamam lá dentro.

Exemplo: No OrangeHRM, o primeiro nome do funcionário se chama `empfirstname`. No midPoint, o atributo equivalente é `givenName`. O Schema Handling define essa tradução.

**Inbound Mapping:** Regra que diz como trazer dados do sistema externo para dentro do midPoint (do Shadow para o User).
```
empfirstname (OrangeHRM) → givenName (User midPoint)
```

**Outbound Mapping:** Regra que diz como levar dados do midPoint para um sistema-alvo (do User para o Shadow/conta no AD).
```
givenName (User midPoint) → givenName (AD)
```

**Strength (força do mapeamento):**
- **Strong:** O midPoint sempre sobrescreve o valor no destino, mesmo que já exista algo lá
- **Weak:** O midPoint só preenche se o campo estiver vazio no destino

No PRJ-002, o `sAMAccountName` foi mapeado como Strong — porque é o identificador principal e nunca pode ser sobrescrito por um valor vazio acidentalmente.

---

## 3.5 Reconciliation vs Live Sync

**Como o midPoint descobre mudanças?** Existem dois mecanismos:

**Reconciliation (Reconciliação):** O midPoint faz uma varredura completa do sistema externo em intervalos definidos. Lê todos os registros, compara com o que tem internamente, e trata as diferenças. É como fazer um inventário completo periodicamente.

**Live Sync (Sincronização ao Vivo):** O sistema externo notifica o midPoint quando algo muda. É em tempo real, mas requer que o sistema externo suporte esse mecanismo.

No PRJ-002, o foco era Reconciliation — o midPoint rodaria uma task periódica para ler todos os funcionários do OrangeHRM e criar/atualizar contas no AD.

---

# PARTE 4 — Infraestrutura e Protocolos

## 4.1 Docker e Docker Compose

**Analogia:** Um container Docker é como um apartamento mobiliado. Você pode pegar o mesmo apartamento e instalar em qualquer prédio (servidor) — ele já vem com tudo o que precisa dentro, sem depender do que tem no prédio.

**Docker:** Tecnologia que empacota um aplicativo com todas as suas dependências em um container isolado. O midPoint em Docker já vem com Java, bibliotecas e configurações — você não precisa instalar nada manualmente no servidor.

**Docker Compose:** Arquivo de configuração (`docker-compose.yml`) que define múltiplos containers e como eles se conectam. No PRJ-002, um único arquivo definia o midPoint, o PostgreSQL e como eles se comunicavam.

**Volumes:** Pastas persistentes que sobrevivem ao reinício do container. Sem volumes, tudo que o midPoint configura some quando o container reinicia. A GMUD-020 perdeu dados do OrangeHRM por uma sanitização que removeu volumes de forma agressiva.

**Rede bridge Docker:** Rede virtual interna que conecta containers no mesmo host. Containers na mesma rede bridge se enxergam pelo nome (DNS interno). Por isso `orangehrm-db` funcionava como endereço de rede — o Docker resolvia o nome para o IP correto automaticamente.

---

## 4.2 TLS e Certificados Digitais

**Analogia:** Imagine que você liga para o banco. Antes de falar qualquer dado, você quer ter certeza que está falando com o banco de verdade, não com um impostor. O banco prova sua identidade apresentando um certificado — como um RG com foto verificável.

**TLS (Transport Layer Security):** Protocolo de criptografia que garante duas coisas: que os dados não podem ser lidos por terceiros no caminho (criptografia), e que o servidor é quem diz ser (autenticação via certificado).

**Certificado digital:** Arquivo que prova a identidade de um servidor. Contém a chave pública do servidor e é assinado por uma Autoridade Certificadora (CA) confiável.

**EKU (Extended Key Usage):** Campo dentro do certificado que especifica para quê ele pode ser usado. Um certificado com EKU "Server Authentication" é válido para autenticar um servidor. Sem esse campo específico, o TLS rejeita o certificado.

**Por que a GMUD-014 falhou:** O Domain Controller tinha a porta 636 aberta (LDAPS), mas o serviço NTDS (o serviço LDAP do AD) não tinha um certificado com EKU "Server Authentication" vinculado a ele. A porta respondia, mas o handshake TLS falhava porque não havia certificado para apresentar.

**Keystore Java:** Arquivo onde o Java armazena certificados confiáveis. Para o midPoint (que é Java) aceitar o certificado do AD, o certificado da CA que assinou o certificado do AD precisa estar no Keystore. A GMUD-014 fez isso corretamente — o problema estava no lado do AD, não do midPoint.

---

## 4.3 OAuth2 — Autenticação de APIs

**Analogia:** Você vai a uma festa exclusiva. Na entrada, você mostra seu convite (credenciais), recebe uma pulseira (token de acesso), e a partir daí usa só a pulseira para entrar em qualquer área da festa. Você não precisa mostrar o convite original toda vez.

**OAuth2** é o protocolo padrão para autenticação em APIs REST modernas. O fluxo básico é:

1. Sistema apresenta suas credenciais (client_id + client_secret)
2. Servidor valida e emite um token de acesso temporário
3. Sistema usa o token em todas as requisições subsequentes
4. Token expira e precisa ser renovado

**Client Credentials Flow:** Modalidade do OAuth2 onde um sistema (não uma pessoa) se autentica. É o fluxo correto para integração máquina-a-máquina — exatamente o que o midPoint precisaria para consumir a API REST do OrangeHRM.

**Por que isso é relevante:** Se o PRJ-002 tivesse usado a API REST do OrangeHRM em vez do banco direto, seria necessário configurar OAuth2 Client Credentials. O endpoint seria algo como:
```
POST /oauth/issueToken
  client_id=api_oauth_id
  client_secret=oauth_secret
  grant_type=client_credentials
```

---

## 4.4 REST API e JSON

**REST API:** Interface de comunicação entre sistemas via HTTP. Em vez de conectar diretamente ao banco de dados, você faz requisições como "me dê a lista de funcionários" e recebe os dados em formato JSON.

**JSON:** Formato de texto para representar dados estruturados.
```json
{
  "employeeId": "0001",
  "firstName": "Paulo",
  "lastName": "Lima",
  "jobTitle": "Analista IAM",
  "email": "paulo.lima@fiqueok.com.br"
}
```

**Por que REST é melhor que JDBC direto para uma fonte autoritativa:**

| Critério | JDBC (banco direto) | REST API |
|----------|--------------------|-----------| 
| Estabilidade | Quebra se o schema mudar | Contrato público versionado |
| Segurança | Expõe banco de dados | Expõe apenas o que foi publicado |
| Facilidade | Simples de configurar | Requer autenticação OAuth2 |
| Corretude | Errada para SSoT | Correta para SSoT |

---

# PARTE 5 — Os Erros do PRJ-002 Explicados Tecnicamente

Agora você tem o vocabulário para entender exatamente o que aconteceu em cada falha.

## 5.1 GMUD-010 — Schema Violation no XML

**O que aconteceu:** Tentou-se importar a configuração do Resource OrangeHRM diretamente como XML.

**Por que falhou:** O midPoint 4.10 usa o framework **Prism** para validar todos os objetos. O Prism é extremamente rigoroso com namespaces XML e ordem de elementos. Um XML gerado manualmente ou copiado de documentação antiga provavelmente tinha elementos fora de ordem ou com namespaces incorretos.

**A solução correta:** Criar o Resource pela GUI Wizard — o midPoint gera o XML internamente com a estrutura correta. Foi o que a GMUD-013 fez.

---

## 5.2 GMUD-017 — DatabaseTable não sincronizava

**O que aconteceu:** Test Connection funcionava, dados existiam no banco, mas Import Task retornava 0 objetos.

**Por que falhou:** O conector DatabaseTable é genérico — ele espera uma tabela com estrutura simples (uma linha = um objeto, colunas diretas). O schema do OrangeHRM Community não é uma tabela simples — tem joins entre tabelas, campos com convenções de nomenclatura antigas e colunas que podem ser NULL de formas que o conector não tolera.

**Schema discovery parcial** (apenas 60% dos atributos encontrados) era o sinal de que o conector não entendia completamente a estrutura da tabela.

---

## 5.3 GMUD-018 — ScriptedSQL JAR não encontrado

**O que aconteceu:** Tentou-se configurar o Resource para usar o ScriptedSQL Connector, mas o midPoint retornou "Connector type not found".

**Por que falhou:** A imagem Docker oficial do midPoint inclui apenas os connectors core (LDAP, CSV, DatabaseTable). O ScriptedSQL é um conector opcional que precisa ser baixado separadamente como arquivo `.jar` e colocado em `/opt/midpoint/lib/` antes de iniciar o container. O download falhou porque o link do Nexus estava desatualizado e o GitHub teve timeout.

**O que deveria ter sido feito antes da GMUD:** Validar se o connector estava disponível com:
```bash
docker exec midpoint-server find /opt/midpoint -name "*scripted*sql*.jar"
```
Se retornasse vazio — pré-requisito não atendido, GMUD não começa.

---

## 5.4 GMUD-019 — addFocus não executava

**O que aconteceu:** Import Task retornava SUCCESS, Shadows eram criados, mas nenhum User aparecia na lista de usuários.

**Por que falhou:** O midPoint 4.10 reformulou o mecanismo de correlação com "Smart Correlation". A sintaxe clássica `<reaction><situation>unmatched</situation><action>addFocus</action>` ainda era aceita pelo XML, mas o comportamento interno mudou — a ação `addFocus` não era disparada para situações "unmatched" da forma esperada.

**Shadow sem User = identidade sem dono.** O midPoint cria o reflexo (Shadow) mas não cria a pessoa (User) — porque a regra que deveria dizer "crie uma pessoa para este reflexo" não estava funcionando.

**A descoberta da GMUD-023** foi que o problema também estava no `User.name` obrigatório — sem mapear um atributo para `name`, o midPoint rejeitava silenciosamente a criação do User mesmo quando `addFocus` era disparado.

---

## 5.5 GMUD-020/021 — Caos do Downgrade

**O que aconteceu:** Série de tentativas de instalar midPoint 4.8 que falharam por problemas encadeados.

**Por que falhou:** Vários problemas independentes se somaram:
- PostgreSQL 9.5 instalado na VM era incompatível (midPoint 4.8 exige PostgreSQL 12+)
- Imagem Alpine vs Debian do midPoint 4.8 tinha comportamentos diferentes com H2
- H2 (banco embedded) tinha problemas de schema com a versão Alpine
- Sanitização agressiva removeu volumes do OrangeHRM que estavam fora do escopo

**A lição de Early Adopter Risk:** Tanto o 4.10 (muito novo) quanto o 4.8 (dependências desatualizadas no ambiente) causaram problemas. A versão certa era 4.8 **em um ambiente preparado especificamente para ela**, com PostgreSQL 15+ e a imagem Docker correta.

---

# PARTE 6 — O Que Deveria Ter Sido Feito

## 6.1 A Arquitetura Correta

```
OrangeHRM
└── API REST (OAuth2 Client Credentials)
        ↓
   midPoint REST Connector (JAR instalado manualmente)
        ↓
   User criado com: name, givenName, familyName, employeeId
        ↓
   LDAPS (porta 636, certificado válido no AD)
        ↓
   Active Directory
```

## 6.2 Os Pré-Requisitos que Faltaram

**Antes de qualquer GMUD de integração:**

1. Verificar versão do OrangeHRM e se a API REST está habilitada
2. Testar a API manualmente via curl:
   ```bash
   curl -X POST http://IP-ORANGEHRM/oauth/issueToken \
     -d "client_id=api_oauth_id&client_secret=SECRET&grant_type=client_credentials"
   ```
3. Fazer um GET de funcionários e ver o JSON retornado
4. Verificar quais connectors estão na imagem Docker do midPoint:
   ```bash
   docker exec midpoint-server find /opt/midpoint -name "*.jar" | grep connector
   ```
5. Verificar se o AD tem certificado válido para LDAPS:
   ```powershell
   Get-ChildItem Cert:\LocalMachine\My | Where-Object {
     $_.EnhancedKeyUsageList -match "Server Authentication"
   }
   ```
6. Desenhar o mapa de atributos antes de configurar qualquer Resource

---

# PARTE 7 — Glossário Rápido

| Termo | Significado simples |
|-------|---------------------|
| **IAM** | Disciplina de gerenciar identidades e acessos |
| **IGA** | IAM com governança — quem tem o quê e por quê |
| **JML** | Joiner-Mover-Leaver — ciclo de vida de uma identidade |
| **SSoT** | Single Source of Truth — a fonte oficial de uma informação |
| **LDAP** | Protocolo para consultar diretórios de identidade |
| **LDAPS** | LDAP com criptografia TLS |
| **AD** | Active Directory — diretório de identidades da Microsoft |
| **DN** | Distinguished Name — endereço único de um objeto no AD |
| **sAMAccountName** | Login do usuário no domínio Windows |
| **midPoint** | Motor IGA open-source da Evolveum |
| **Sqale** | Schema de banco de dados do midPoint (PostgreSQL) |
| **Resource** | Configuração de um sistema externo no midPoint |
| **Shadow** | Reflexo de uma conta externa dentro do midPoint |
| **User/Focus** | A identidade da pessoa dentro do midPoint |
| **Linking** | Conectar um Shadow a um User |
| **addFocus** | Ação do midPoint para criar um novo User |
| **Connector** | Plugin que implementa comunicação com um sistema externo |
| **ICF** | Interface padrão que todos os connectors seguem |
| **JDBC** | Interface Java para conectar a bancos de dados |
| **JAR** | Arquivo executável Java (como um .exe, mas para Java) |
| **Groovy** | Linguagem de script usada no ScriptedSQL Connector |
| **Inbound Mapping** | Regra que traz dados do sistema externo para o midPoint |
| **Outbound Mapping** | Regra que leva dados do midPoint para sistema-alvo |
| **Reconciliation** | Varredura periódica para sincronizar dados |
| **Live Sync** | Sincronização em tempo real quando algo muda |
| **OAuth2** | Protocolo de autenticação para APIs REST |
| **TLS** | Protocolo de criptografia para comunicações seguras |
| **Certificado digital** | Prova de identidade de um servidor |
| **EKU** | Campo do certificado que define seu uso permitido |
| **Docker** | Tecnologia de containers — aplicações isoladas e portáteis |
| **Docker Compose** | Arquivo que define e orquestra múltiplos containers |
| **Volume Docker** | Pasta persistente que sobrevive ao reinício do container |

---

# PARTE 8 — Como Estudar Cada Conceito na Prática

Ler este documento é o começo. Para internalizar cada conceito, você precisa executar com entendimento, não seguir procedimento cegamente.

**Para LDAP:** Quando o ambiente estiver ligado, execute um `ldapsearch` manual e leia o resultado. Tente encontrar um usuário pelo `sAMAccountName`. Pergunte-se: o que cada linha significa?

**Para midPoint:** Antes de configurar qualquer Resource, abra a documentação oficial da Evolveum e leia o que é um Resource, um Shadow e um User. Depois compare com o que você vê na GUI.

**Para Docker:** Quando subir os containers, execute `docker ps`, `docker logs midpoint-server`, e `docker exec midpoint-server ls /opt/midpoint/var/connectors`. Entenda o que cada comando retorna.

**Para cada GMUD futura:** Antes de executar, escreva com suas palavras o que você espera que aconteça. Depois execute. Depois compare o que aconteceu com o que você esperava. A diferença é onde está o aprendizado.

---

*Fiqueok Living Lab — Documento didático PRJ-002*  
*Produzido como base de conhecimento para evolução N1 → N2 → N5*

