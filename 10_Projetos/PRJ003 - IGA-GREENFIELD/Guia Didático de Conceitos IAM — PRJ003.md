# 

## IGA Greenfield Reference Architecture

### Living Lab Fiqueok 2.0 — Documento de Estudo Pessoal

---

> **Como usar este guia:** Este documento foi escrito para você — Paulo — com base no que aconteceu de verdade no PRJ003. Cada conceito aparece primeiro como analogia do mundo real, depois como definição técnica, e depois conectado ao que você viveu. Não é um glossário — é um manual de entendimento.

---

# Parte 1 — O Problema que o PRJ003 Resolve

## Por que esse projeto existe?

**Analogia:** Imagine que você tem uma empresa de segurança, mas não sabe exatamente quem são seus funcionários, quem tem acesso a quê, e o que acontece com os acessos quando alguém é demitido. Cada setor tomou suas próprias decisões ao longo do tempo. Ninguém sabe dizer, de cabeça, o que é a "identidade oficial" de um colaborador.

**Tecnicamente:** Esse é o estado de uma organização sem IGA formalizado. Existem identidades em vários sistemas (AD, banco de dados, aplicações), tomadas de decisão implícitas sobre quem é quem, e nenhuma fonte única de verdade sobre o ciclo de vida das identidades.

**No PRJ003:** O projeto começa precisamente aí. Antes de implantar qualquer ferramenta, você documentou quem é a identidade canônica, qual sistema tem autoridade sobre quais atributos, e quais são os estados possíveis de uma identidade. Esse trabalho foi feito nas GMUDs 001–003 e resultou nos Canvases CAN-ID-001, 002 e 003. Só depois veio a infraestrutura.

---

# Parte 2 — Os Componentes Envolvidos

## 2.1 — IGA (Identity Governance and Administration)

**Analogia:** IGA é como o departamento de RH combinado com auditoria de uma empresa muito bem organizada. O RH sabe quem é cada pessoa, qual cargo tem, e o que muda quando alguém entra, muda de função ou sai. A auditoria garante que cada acesso concedido tem uma justificativa registrada e rastreável.

**Tecnicamente:** IGA é a disciplina (e o conjunto de ferramentas) que gerencia o ciclo de vida de identidades e seus acessos em sistemas de TI. Inclui provisionamento automático de contas, certificação periódica de acessos, e rastreabilidade de todas as alterações.

**No PRJ003:** O midPoint é a ferramenta IGA. O projeto inteiro gira em torno de implantar o midPoint de forma que ele seja o orquestrador central de identidade — o "RH digital" do Living Lab.

---

## 2.2 — midPoint

**Analogia:** O midPoint é o maestro de uma orquestra de identidades. Ele não é o violino nem o piano — ele coordena quem toca o quê, quando, com qual instrumento, e garante que o resultado final seja harmônico.

**Tecnicamente:** midPoint é uma plataforma open-source de IGA desenvolvida pela Evolveum. Ele recebe dados de fontes autorizativas (RH, diretórios), aplica políticas de identidade, e provisionou contas nos sistemas-alvo (AD, LDAP, aplicações via conectores). Utiliza repositório relacional (PostgreSQL na versão nativa "SQALE") para armazenar objetos de identidade.

**No PRJ003:** O midPoint foi o bloqueador técnico central do projeto. Versões 4.8 e 4.9 apresentaram comportamentos inesperados (fallback H2, bugs de entrypoint). Somente a versão 4.10 foi implantada com sucesso usando a estratégia de injeção manual prévia de schema.

---

## 2.3 — PostgreSQL como Repositório Nativo (SQALE)

**Analogia:** Se o midPoint é o maestro, o PostgreSQL é o arquivo central da orquestra — onde estão registradas todas as partituras (identidades), todas as apresentações passadas (auditoria), e todos os ensaios futuros (agendamentos).

**Tecnicamente:** O midPoint armazena seus objetos (usuários, recursos, roles, políticas) em um banco relacional. Na versão 4.10, usa o repositório "native" — chamado internamente de SQALE — que usa UUIDs como chaves primárias e JSONB para atributos extensíveis. Esse design é significativamente diferente do repositório Hibernate usado em versões 4.x anteriores (chaves BIGINT, schema ORM tradicional).

**No PRJ003:** O PostgreSQL 16 operou corretamente desde a GMUD-010 (Tentativa #6). O problema nunca foi o banco em si — foi o midPoint (versões 4.8/4.9) falhando em conectar-se a ele corretamente. O schema SQALE v51 foi injetado manualmente na GMUD-012, garantindo paridade exata com o que a versão 4.10 esperava.

---

## 2.4 — Docker e Docker Compose

**Analogia:** Docker é como um "apartamento montável". Você empacota tudo que o midPoint precisa (Java, arquivos de configuração, dependências) em uma "caixa padronizada" (container), e essa caixa funciona igual em qualquer máquina. Docker Compose é o manual de montagem que descreve como montar vários apartamentos (containers) ao mesmo tempo e fazer com que eles se comuniquem.

**Tecnicamente:** Docker é uma plataforma de containerização. Um container é um processo isolado com sistema de arquivos próprio, que inclui a aplicação e todas as suas dependências. Docker Compose é uma ferramenta que define e orquestra múltiplos containers via arquivo YAML (`docker-compose.yml`).

**No PRJ003:** midPoint e PostgreSQL cada um rodou em seu próprio container, dentro da mesma rede virtual (`iga-network`). Os dados foram persistidos em volumes (diretórios mapeados da VM para dentro dos containers) para sobreviver a reinicializações.

---

## 2.5 — Volumes Docker

**Analogia:** Um volume Docker é como a gaveta de documentos de um funcionário. O funcionário pode ser demitido e recontratado (container destruído e recriado), mas os documentos na gaveta permanecem.

**Tecnicamente:** Volumes Docker são mecanismos de persistência de dados fora do sistema de arquivos efêmero do container. Podem ser volumes nomeados (gerenciados pelo Docker) ou bind mounts (diretório real da VM mapeado dentro do container).

**No PRJ003:** Os volumes foram o palco de dois problemas críticos:

- "Envenenamento de volume" (GMUDs 008–009): o PostgreSQL persistiu uma senha incorreta no primeiro boot; tentativas subsequentes com a senha correta foram ignoradas porque o banco detectava o cluster como já inicializado.
- Keystores zumbi: arquivos `keystore.jceks` de tentativas anteriores com senhas diferentes corrompiam boots subsequentes do midPoint.

Solução: limpeza atômica obrigatória (`docker compose down -v` + `sudo rm -rf data/*`) antes de qualquer nova tentativa.

---

## 2.6 — Identidade Canônica

**Analogia:** Em um banco, cada cliente tem um número de CPF. Independentemente de quantas contas, cartões ou empréstimos ele tenha, existe um único identificador que o representa de forma oficial e inequívoca em todos os sistemas.

**Tecnicamente:** Identidade canônica é a representação oficial e única de um indivíduo no contexto de um sistema de identidade. Define qual sistema tem a última palavra sobre atributos conflitantes e qual identificador é usado como âncora de correlação entre sistemas.

**No PRJ003:** A formalização da identidade canônica foi o primeiro artefato produzido (CAN-ID-001, GMUD-002). Sem essa definição, qualquer integração posterior criaria ambiguidade: qual sistema tem razão sobre o nome completo de um usuário quando o RH diz uma coisa e o AD diz outra?

---

## 2.7 — Fonte Autorizativa

**Analogia:** Se você quer saber o nome oficial de uma empresa, você vai na Junta Comercial — não no cartão de visita do sócio. A Junta Comercial é a fonte autorizativa para esse dado.

**Tecnicamente:** Fonte autorizativa é o sistema que detém a "verdade" sobre um determinado atributo de identidade. Em arquiteturas IGA, diferentes sistemas podem ser autorizativos para diferentes atributos (ex: o sistema de RH é autorizativo para cargo e data de admissão; o AD é autorizativo para login name).

**No PRJ003:** A definição de autoridade de dados foi formalizada no CAN-ID-002. Esse documento define qual sistema "ganha" em caso de conflito de atributos — antes de qualquer conector ser configurado.

---

## 2.8 — Ciclo de Vida de Identidade (JML)

**Analogia:** Uma identidade segue o mesmo ciclo que um funcionário: é contratada (Joiner), pode ser transferida ou promovida (Mover), e eventualmente é demitida ou aposenta (Leaver). Cada etapa tem consequências em termos de acessos.

**Tecnicamente:** JML (Joiner, Mover, Leaver) é o modelo de gerenciamento de ciclo de vida de identidades. Define as ações automatizadas que devem ocorrer em cada transição: criação de conta, ajuste de permissões, suspensão ou remoção de acessos.

**No PRJ003:** O JML está fora do escopo deste projeto. Mas a formalização dos "estados da identidade" no CAN-ID-003 (Ativo, Inativo, Suspenso, etc.) prepara o terreno conceitual para o JML ser implementado em projetos futuros (ex: PRJ004).

---

# Parte 3 — Como o IGA Funciona por Dentro

## 3.1 — O Repositório do midPoint

**Analogia:** O repositório é o banco de dados interno do midPoint — como a agenda de contatos de um gerente de RH muito organizado. Cada identidade, cada regra, cada resource configurado, cada acesso concedido fica registrado aqui.

**Tecnicamente:** O repositório do midPoint armazena todos os objetos gerenciados pela plataforma: `UserType`, `RoleType`, `ResourceType`, `ShadowType`, etc. Na versão 4.10 (SQALE), o schema principal usa UUIDs como chaves primárias e JSONB para atributos extensíveis — o que dá flexibilidade para armazenar qualquer atributo sem alterar o schema relacional.

**No PRJ003:** O repositório foi o coração do problema técnico. Nas versões 4.8/4.9, o midPoint tentava conectar ao repositório via variáveis de ambiente que o `docker-entrypoint.sh` processava de forma imprevisível. Quando a conexão falha, o midPoint ativa o banco H2 embutido como fallback — e o container sobe "saudável" enquanto opera com dados em memória que desaparecem quando o container reinicia.

## 3.2 — O Bootstrap do midPoint

**Analogia:** O bootstrap é o rito de passagem do midPoint quando ele acorda pela primeira vez. Ele precisa: encontrar o banco de dados, verificar se o schema está na versão certa, criar o usuário administrador, e importar os objetos iniciais de configuração.

**Tecnicamente:** O processo de bootstrap do midPoint inclui:

1. Validação da conexão JDBC com o banco de dados
2. Verificação da versão do schema (Change #N)
3. Criação do keystore JCEKS para operações criptográficas
4. Criação do usuário `administrator` com senha inicial
5. Importação de objetos iniciais (marks, policies, templates)

**No PRJ003:** O Change #51 nos logs da GMUD-012 confirmou que o schema SQALE injetado manualmente correspondia exatamente à versão esperada pelo midPoint 4.10. Os 171 objetos importados com 0 erros validaram que o bootstrap completo funcionou.

## 3.3 — Fallback para H2

**Analogia:** Imagine uma empresa que, quando o sistema principal cai, automaticamente ativa uma planilha Excel local para registrar pedidos — sem avisar ninguém. Os pedidos ficam registrados "em algum lugar", mas somem quando o computador desliga, e ninguém sabe que está acontecendo.

**Tecnicamente:** O banco H2 é um banco de dados relacional embutido em Java, que o midPoint usa como solução de contingência quando não consegue conectar ao repositório externo configurado (PostgreSQL, Oracle, etc.). O H2 mantém dados em memória — eles desaparecem ao reiniciar o container. O midPoint pode iniciar, responder HTTP 200 e aceitar logins operando 100% com H2 sem nenhuma mensagem de erro óbvia na interface.

**No PRJ003:** Este foi o problema mais insidioso do projeto. Durante as GMUDs 007 a 011, o midPoint subia "com saúde" (healthcheck: healthy, HTTP 200 na interface), mas estava operando com H2. Só inspecionando a linha `midpoint.repository.database .:. h2` nos logs de inicialização foi possível detectar o problema. O critério correto de validação de sucesso passou a ser essa verificação explícita nos logs — não a interface web.

---

# Parte 4 — Infraestrutura e Protocolos Relevantes

## 4.1 — SCRAM-SHA-256

**Analogia:** SCRAM-SHA-256 é como um aperto de mão secreto entre dois agentes. Em vez de simplesmente trocar a senha (que poderia ser interceptada), os dois lados provam que conhecem a senha sem revelá-la diretamente, usando um protocolo de desafio-resposta criptográfico.

**Tecnicamente:** SCRAM-SHA-256 (Salted Challenge Response Authentication Mechanism) é o mecanismo padrão de autenticação de clientes no PostgreSQL 16. O cliente (midPoint, via driver JDBC) e o servidor trocam desafios assinados criptograficamente para provar conhecimento da senha sem transmiti-la em claro.

**No PRJ003:** Drivers JDBC mais antigos (usados nas versões 4.8 e 4.9 do midPoint) não suportavam adequadamente o SCRAM-SHA-256 do PostgreSQL 16. Resultado: a mensagem de erro `The server requested SCRAM-based authentication, but no password was provided` — mesmo com a senha correta configurada. A versão 4.10 do midPoint atualizou o driver JDBC e resolveu esse problema.

## 4.2 — Docker Compose e Dependências de Serviço

**Analogia:** Em uma fábrica, as linhas de montagem têm dependências: a pintura só começa depois da estrutura estar montada. Se você ligar as duas ao mesmo tempo, vai tentar pintar uma estrutura que ainda não existe.

**Tecnicamente:** No Docker Compose, a diretiva `depends_on` define que um serviço deve aguardar outro antes de iniciar. A versão simples (`depends_on: postgres`) apenas aguarda o container estar rodando — não que ele esteja pronto para aceitar conexões. A versão com healthcheck (`depends_on: postgres: condition: service_healthy`) aguarda até que o PostgreSQL responda `pg_isready` antes de iniciar o midPoint.

**No PRJ003:** A ausência do healthcheck na GMUD-005 foi identificada como causa potencial da falha de autenticação inicial. O midPoint poderia estar tentando conectar ao PostgreSQL antes de ele completar a inicialização do cluster. A solução foi adicionada nas GMUDs subsequentes.

## 4.3 — Hyper-V e Checkpoints de VM

**Analogia:** Um checkpoint de VM é como tirar uma foto completa do estado de um computador em determinado momento — não só os arquivos, mas a memória, o estado dos processos e a configuração de hardware virtual. Se algo der errado, você pode "voltar no tempo" para aquela foto.

**Tecnicamente:** Checkpoints Hyper-V (equivalentes a snapshots em outras plataformas) capturam o estado completo de uma VM: disco, memória e configuração de hardware virtual. O Switch Virtual Externo conecta a VM ao adaptador de rede físico do host — mas esse estado de conectividade pode não ser restaurado fielmente ao aplicar um checkpoint, especialmente se o adaptador físico do host mudou de estado entre o snapshot e a restauração.

**No PRJ003:** Na GMUD-006, após restaurar o checkpoint PRE-GMUD-005, a VM perdeu conectividade externa. `ping 8.8.8.8` e `ping xxx.xxx.xxx.xxx` falhavam, impedindo o download de imagens Docker. A causa foi o Hyper-V não restaurar completamente o estado do switch virtual externo. Lição: validar rede é o passo 1 obrigatório após qualquer restauração de checkpoint.

## 4.4 — SSH e Automação via PowerShell

**Analogia:** SSH é o telefone seguro que você usa para dar ordens à VM remotamente. PowerShell é o roteiro que automatiza essas ligações — em vez de você ligar e ditar cada comando, o script faz isso automaticamente em sequência.

**Tecnicamente:** SSH (Secure Shell) é o protocolo para acesso remoto criptografado a servidores Linux. PowerShell é a linguagem de script do Windows, capaz de abrir conexões SSH e executar comandos remotos via `Invoke-SSHCommand` ou o cliente SSH nativo. A combinação de PowerShell + SSH permitiu criar um pipeline de "Infrastructure as Code" executado do Windows para a VM Linux.

**No PRJ003:** O pipeline PowerShell → SSH → Docker Compose foi validado e funcionou na GMUD-010. Os bloqueadores de automação foram: sudoers sem `NOPASSWD` (exigia senha interativa que o script não conseguia fornecer), e expansão de variáveis em here-strings que gerava senhas vazias nos arquivos de configuração gerados.

---

# Parte 5 — Cada Falha Principal Explicada Tecnicamente

## 5.1 — A Falha da GMUD-005: Credencial de Repositório vs. Credencial de Aplicação

**O que aconteceu:** Containers subiram, midPoint gerou o usuário `administrator` nos logs, interface web respondeu — e o login com `administrator / 5ecurity` foi recusado.

**Por que aconteceu:** Em plataformas IGA existe uma distinção crítica entre dois tipos de credencial:

- **Credencial de repositório:** a senha que o midPoint usa para autenticar-se no PostgreSQL. É configurada via variáveis de ambiente no Docker Compose.
- **Credencial de aplicação:** a senha do objeto de usuário `administrator` armazenado dentro das tabelas do PostgreSQL. É definida durante o bootstrap da aplicação, via configuração separada.

A mensagem `Created User:administrator` nos logs confirma apenas que o bootstrap foi iniciado — não que a senha foi configurada com o valor esperado. Um bootstrap incompleto (race condition, estado residual em volumes) pode criar o usuário com uma senha diferente da esperada sem nenhuma mensagem de erro.

## 5.2 — A Falha das GMUDs 007–010: O Fallback Silencioso para H2

**O que aconteceu:** midPoint subia, interface respondia, healthcheck passava — mas o banco de dados real era H2 (em memória), não PostgreSQL.

**Por que aconteceu:** O `docker-entrypoint.sh` das imagens 4.8 e 4.9 verifica a presença de `REPO_DATABASE_TYPE`. Se esse gatilho não está presente, ou se as variáveis são processadas em ordem errada, o entrypoint assume que deve usar H2. Ele então sobrescreve qualquer configuração `MP_SET_*` que tenha sido definida. O container inicia "com sucesso", mas opera com banco em memória.

**Por que foi difícil detectar:** O midPoint com H2 e o midPoint com PostgreSQL têm aparência idêntica externamente: mesmo endpoint, mesma interface, mesmas respostas HTTP. A única forma de distinguir é verificar a linha `midpoint.repository.database .:. h2` ou `midpoint.repository.database .:. postgresql` nos logs de inicialização.

## 5.3 — A Falha da GMUD-009: Caracteres Especiais e o `sed`

**O que aconteceu:** A senha foi configurada corretamente no `.env`, mas chegava incompleta no `config.xml` gerado pelo entrypoint.

**Por que aconteceu:** O script `docker-entrypoint.sh` usa o comando `sed` para substituir placeholders no `config.xml`. O `sed` usa `/` como delimitador por padrão, mas aceita outros delimitadores — incluindo `#`. Quando a senha contém `#`, o `sed` interpreta o `#` como início de comentário de shell, truncando a senha. Senha `P0stgr3sS3cur3#2026!` chegava como `P0stgr3sS3cur3` no arquivo de configuração.

**O problema mais fundo:** Este comportamento não está documentado na documentação pública da Evolveum. Ele só pode ser descoberto inspecionando o código interno do `docker-entrypoint.sh` ou observando o padrão de truncamento nos logs.

## 5.4 — A Falha das GMUDs 008–010: Volumes Envenenados

**O que aconteceu:** Após um deploy falho, o próximo deploy apresentava um erro diferente do anterior — mesmo com a configuração corrigida.

**Por que aconteceu:** O PostgreSQL 16 persiste a configuração de autenticação no `pg_hba.conf` e o hash da senha no `pg_data` durante o **primeiro boot**. Se o primeiro boot ocorreu com uma senha incorreta (ex: senha vazia por vácuo de variável), o PostgreSQL armazena o hash dessa senha incorreta. Tentativas subsequentes com a senha correta são recusadas porque o banco compara com o hash persistido, não com a variável de ambiente atual. Isso acontecia mesmo após `docker compose down` sem a flag `-v`.

**A solução:** `docker compose down -v` (remove volumes nomeados) + `sudo rm -rf data/*` (remove bind mounts) — ambos obrigatórios, sempre juntos.

---

# Parte 6 — O que Deveria Ter Sido Feito

## 6.1 — A Arquitetura Correta desde o Início

O que a GMUD-012 revelou é que a estratégia correta era simples — mas exigia conhecimento que só foi adquirido após 19 tentativas:

1. Escolher a versão do midPoint **com teste de smoke prévio em VM isolada**
2. Usar **injeção manual prévia de schema** (baixar os SQLs do GitHub Evolveum, executar via `psql` antes do midPoint subir)
3. Usar **variáveis `MP_SET_*` modernas** com credenciais embutidas diretamente na URL JDBC, contornando o entrypoint legado
4. Garantir **limpeza atômica de volumes** antes de qualquer tentativa

## 6.2 — O Pré-Requisito que Faltou: ADR de Versão

Antes da GMUD-005, deveria existir um ADR registrando:

- Versão escolhida e por quê
- Resultado de teste básico de compatibilidade com PostgreSQL 16
- Estratégia de configuração (qual mecanismo de variáveis usar)
- Protocolo de validação de bootstrap

Esse ADR teria economizado as 24 horas de troubleshooting das GMUDs 005–011.

---

# Parte 7 — Glossário

|Termo|Definição Resumida|
|---|---|
|**IGA**|Identity Governance and Administration — disciplina e ferramentas para gerenciar ciclo de vida de identidades e acessos|
|**midPoint**|Plataforma IGA open-source da Evolveum|
|**PostgreSQL**|Banco de dados relacional open-source usado como repositório do midPoint|
|**SQALE**|Nome interno do repositório nativo do midPoint 4.9+ (schema com UUID + JSONB)|
|**Docker**|Plataforma de containerização de aplicações|
|**Container**|Processo isolado com sistema de arquivos próprio e dependências encapsuladas|
|**Volume Docker**|Mecanismo de persistência de dados fora do sistema de arquivos efêmero do container|
|**Docker Compose**|Ferramenta para orquestrar múltiplos containers via arquivo YAML|
|**SCRAM-SHA-256**|Mecanismo de autenticação criptográfico padrão no PostgreSQL 16|
|**JDBC**|Java Database Connectivity — API padrão Java para conexão a bancos de dados relacionais|
|**Entrypoint**|Script executado quando um container Docker inicia, antes da aplicação principal|
|**Fallback H2**|Comportamento do midPoint de usar banco H2 embutido quando falha a conexão ao banco externo|
|**Keystore JCEKS**|Arquivo de chaves criptográficas usado pelo midPoint para operações de criptografia|
|**Bootstrap**|Processo de inicialização inicial de uma aplicação que cria schema, usuários e configurações base|
|**Identidade Canônica**|Representação oficial e única de um indivíduo no sistema de identidade|
|**Fonte Autorizativa**|Sistema que detém a "verdade" sobre um determinado atributo de identidade|
|**JML**|Joiner, Mover, Leaver — modelo de ciclo de vida de identidades|
|**ADR**|Architecture Decision Record — documento que registra uma decisão arquitetural com justificativa|
|**Canvas de Identidade**|Artefato de governança que formaliza decisões semânticas sobre identidade antes da execução técnica|
|**Cold Start**|Provisionamento de infraestrutura do zero, sem dependência de estado anterior|
|**Checkpoint Hyper-V**|Snapshot completo do estado de uma VM para permitir rollback|
|**IaC**|Infrastructure as Code — prática de gerenciar infraestrutura por código versionável|
|**NOPASSWD (sudoers)**|Configuração que permite ao usuário executar comandos `sudo` sem digitar senha — necessário para automação SSH|
|**Race Condition**|Problema em que dois processos competem por um recurso e o resultado depende de qual chegou primeiro|
|**Envenenamento de Volume**|Estado em que dados persistidos de uma tentativa anterior corrompem tentativas subsequentes|
|**Schema SQALE v51**|Versão específica do schema de banco de dados do midPoint 4.10 (Change #51)|
|**Soberania de Dados**|Estratégia de injetar o schema PostgreSQL manualmente antes do boot da aplicação, eliminando dependência do autocreate do entrypoint|
|**GRC**|Governance, Risk and Compliance — conjunto de práticas de governança de TI|
|**Gate de Reversibilidade**|Critério formal que aciona rollback quando uma GMUD atinge condição de falha definida|

---

# Parte 8 — Como Estudar Cada Conceito na Prática

## 8.1 — Entendendo o Fallback H2

Estude este comando nos logs do midPoint. Se a linha for:

```
Processing variable (MAP) ... midpoint.repository.database .:. h2
```

O midPoint está usando H2 — falha. Se for:

```
Processing variable (MAP) ... midpoint.repository.database .:. postgresql
```

Está correto. Pratique verificando isso em qualquer deploy midPoint antes de fazer qualquer outra validação.

## 8.2 — Verificando o Schema SQALE

Acesse o PostgreSQL diretamente para inspecionar o schema:

bash

```bash
docker exec -it iga-postgres psql -U midpoint_user -d midpoint
\dt         -- lista todas as tabelas
SELECT * FROM m_global_metadata;   -- verifica versão do schema
SELECT COUNT(*) FROM m_object;     -- conta objetos importados
```

## 8.3 — Diagnosticando Problemas de Bootstrap

Sequência de verificação após qualquer deploy midPoint:

bash

```bash
# 1. Verificar banco de dados em uso
docker logs iga-midpoint 2>&1 | grep "midpoint.repository.database"

# 2. Verificar conexão ao PostgreSQL
docker logs iga-midpoint 2>&1 | grep -E "HikariPool|schema is compliant|Initial object import"

# 3. Verificar keystore
docker logs iga-midpoint 2>&1 | grep -i "keystore"

# 4. Verificar startup completo
docker logs iga-midpoint 2>&1 | grep "Started MidPointSpringApplication"
```

## 8.4 — Praticando Limpeza Atômica de Volumes

Memorize esta sequência como procedimento de rollback padrão:

bash

```bash
docker compose down -v                    # remove containers E volumes nomeados
sudo rm -rf /srv/prj003/data/postgres/*  # limpa bind mounts do PostgreSQL
sudo rm -rf /srv/prj003/data/midpoint/var/*  # limpa bind mounts do midPoint
```

Nunca fazer apenas `docker compose down` sem `-v` quando há suspeita de volume envenenado.

## 8.5 — Perguntas para Consolidar o Aprendizado

1. Qual a diferença entre a credencial de repositório e a credencial de aplicação no midPoint? O que valida cada uma?
2. Por que `docker ps` mostrando o container como `Up (healthy)` não é suficiente para confirmar que o midPoint está usando PostgreSQL?
3. O que é um "volume envenenado" e como evitar que ele persista entre tentativas de deploy?
4. Por que o SCRAM-SHA-256 causou problemas apenas nas versões 4.8 e 4.9 do midPoint?
5. O que a linha `Change #51 executed!` nos logs do PostgreSQL confirma sobre a compatibilidade de versões?
6. Qual é o papel do CAN-ID-001 antes de qualquer deploy técnico? O que teria acontecido se esse artefato não existisse?

## 8.6 — Próximos Conceitos para Estudar (PRJ004 em diante)

Temas que o PRJ003 introduziu mas não aprofundou — relevantes para os próximos projetos:

- Conectores midPoint (como o midPoint "fala" com sistemas externos: AD, LDAP, REST)
- Mapeamentos de atributos (como o midPoint traduz atributos entre sistemas)
- Políticas de senha (como o midPoint aplica regras de senha no provisionamento)
- Certificações de acesso (como auditar periodicamente quem tem acesso a quê)
- JML em ação (o que acontece no midPoint quando alguém é contratado, transferido ou demitido)

---

_Guia Didático PRJ003 v1.0 — Living Lab Fiqueok 2.0_
