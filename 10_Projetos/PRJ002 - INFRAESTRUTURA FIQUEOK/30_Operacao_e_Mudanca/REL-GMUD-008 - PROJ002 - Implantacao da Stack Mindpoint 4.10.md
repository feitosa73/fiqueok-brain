# Base de Conhecimento  
## Implantação midPoint 4.10 (Sqale Repository + Docker + Postgres)

---

## 1. Contexto e Escopo

Esta base de conhecimento documenta a implantação do **midPoint 4.10** utilizando:

- Imagem oficial `evolveum/midpoint:latest-alpine` em container.  
- Repositório **PostgreSQL 16** nativo (Sqale Repository), sem uso de H2.  
- Orquestração via **Docker Compose** em VM Linux (Ubuntu) sob Hyper‑V.  
- Objetivo: criação da infraestrutura base que será futuramente a **infra corporativa da Fiqueok Consultoria**, não apenas um lab descartável.

---

## 2. Histórico da Implementação e Desafios

Durante a execução foram identificados alguns pontos críticos:

1. **Conflito de Repositório (H2 vs Postgres)**  
   - As imagens 4.10 mantêm o H2 como padrão; ao subir sem configuração adequada, o midPoint tenta usar H2 em vez do Postgres.  
   - Foi necessário forçar a configuração JDBC para o Postgres via variáveis de ambiente, usando o mecanismo de sobreposição suportado.

2. **Obrigatoriedade do Prefixo `MP_SET_`**  
   - Para sobrescrever propriedades de configuração do midPoint/Spring Boot em ambiente de container, as variáveis precisam ser declaradas com o prefixo `MP_SET_` (por exemplo, `MP_SET_midpoint_repository_jdbcUrl`).  
   - Variáveis sem esse prefixo não eram aplicadas, o que explicava a persistência de parâmetros incorretos.

3. **Recursos Insuficientes (RAM)**  
   - O ambiente inicial contava com apenas **3 GB de RAM**, provocando instabilidade e possíveis falhas no bootstrap da JVM e do container de aplicação.  
   - Após o **upgrade para 8 GB**, o midPoint passou a iniciar de forma consistente.

4. **Erro de Schema: `m_global_metadata` inexistente**  
   - Erro do tipo `relation "m_global_metadata" does not exist` apontou que o repositório Sqale **não cria automaticamente** todo o schema no Postgres;  
   - Tentativas manuais de criar apenas essa tabela mostraram‑se inviáveis, porque o schema completo envolve diversas tabelas, índices e relações que devem ser criados de forma coordenada pelo próprio produto.

5. **Manipulações manuais de banco (lição negativa)**  
   - Foram feitas tentativas de corrigir o problema diretamente no Postgres (criação/alteração de `m_global_metadata` e ajustes na tabela `m_user`).  
   - Essa abordagem foi abandonada por não ser sustentável nem aderente às boas práticas de operação do midPoint.

---

## 3. Linha do Tempo das Ações Técnicas

| **Fase** | **Ação Realizada** | **Resultado / Observação** |
|---------|---------------------|----------------------------|
| **Infra** | Upgrade de RAM de 3 GB para 8 GB na VM Hyper‑V | Estabilização do ambiente Java e redução de falhas de inicialização. |
| **Config 1** | Definição de variáveis JDBC para Postgres sem prefixo `MP_SET_` | midPoint continuou tentando usar configurações padrão (H2/antigas). |
| **Config 2** | Adoção do prefixo `MP_SET_` em todas as variáveis (`jdbcUrl`, `jdbcUsername`, `jdbcPassword`, `database`, etc.) | midPoint passou a usar corretamente o banco Postgres como repositório nativo. |
| **DB Manual (tentativa)** | Criação manual de `m_global_metadata` e ajustes em tabelas | Não sustentável; corrigia sintomas mas não a origem do problema de schema. |
| **Init Container** | Introdução do serviço `data_init` com `midpoint.sh init-native` e `run-sql --create --mode REPOSITORY/AUDIT` | Criação completa e suportada do schema Sqale no Postgres, sem necessidade de scripts manuais. |
| **Reset de Lab** | `docker compose down -v` + `rm -rf postgresdata midpoint_home ...` | Limpeza total de volumes, remoção de dados antigos e estados inconsistentes. |
| **Senha Inicial** | Inclusão de `MP_SET_midpoint_administrator_initialPassword=MidP0int2025` no serviço `midpoint_server` | Definição controlada da senha inicial do usuário `administrator` no primeiro bootstrap. |
| **Validação REST** | Uso de `curl -u administrator:MidP0int2025 http://<IP_VM>:8080/midpoint/ws/rest/self` | Retorno HTTP 200 + XML do usuário `administrator`, confirmando senha e repositório OK. |
| **Acesso GUI** | Acesso via navegador a `http://<IP_VM>:8080/midpoint` | Login bem-sucedido com `administrator / MidP0int2025` e dashboard carregado normalmente. |
| **Rede Hyper‑V** | Ajuste de acesso de `localhost:8080` (falho) para `http://xxx.xxx.xxx.xxx:8080` (IP da VM) | Soluciona erro `ERR_CONNECTION_REFUSED` no host Windows, pois `localhost` do host não é o da VM. |

---

## 4. Lições Aprendidas

### 4.1 Arquitetura Sqale e Init Container

- A partir das versões 4.9/4.10 o midPoint utiliza o **Sqale Repository**, que pressupõe um banco relacional inicializado de forma controlada.  
- A criação do esquema não deve ser feita manualmente nem depender de auto‑DDL; em ambiente de containers o fluxo recomendado é:  
  - um **init container** (`data_init`) executa `midpoint.sh init-native` e, se necessário, comandos `ninja.sh run-sql` para criar/atualizar o schema de repositório e auditoria;  
  - apenas depois disso o `midpoint_server` é iniciado.

### 4.2 Ordem Correta de Provisionamento

- A senha inicial do administrador (`midpoint.administrator.initialPassword`) **só é aplicada na primeira inicialização** do repositório.  
- Uma vez criado o usuário `administrator` no banco, alterar a variável de ambiente no Compose **não altera a senha existente**.  
- Para reutilizar uma senha inicial diferente, é necessário recriar o repositório (por exemplo, `docker compose down -v` + remoção dos volumes) ou usar mecanismos internos de troca de senha.

### 4.3 Separação entre LAB e “Infra Base”

- Embora o ambiente esteja em Hyper‑V como laboratório, ele já representa a **infraestrutura base corporativa**;  
- Manipulações diretas em tabelas (`m_user`, `m_global_metadata`, etc.) devem ser evitadas em favor dos mecanismos oficiais (init container, scripts suportados, GUI, REST API).  
- Reset estruturado de lab (quando necessário) deve ser documentado como procedimento formal de “recriação controlada de ambiente”.

### 4.4 Configuração e YAML

- Arquivos `docker-compose.yml` são sensíveis à indentação;  
- Erros sutis de recuo podem fazer com que diretivas como `volumes`, `environment` ou `depends_on` sejam interpretadas de forma incorreta ou ignoradas.  
- Adoção de um padrão de formatação (2 espaços, validação com linter/YAML checker) ajuda a prevenir erros operacionais.

### 4.5 Validação por REST antes da GUI

- A experiência mostrou que é muito mais eficiente validar a credencial com REST antes de gastar tempo na tela de login.  
- Padrão adotado:  
curl -vk
-u administrator:<senha_teste>
http://<IP_VM>:8080/midpoint/ws/rest/self

text
- Resultado esperado:  
- `HTTP/1.1 200` → senha correta, seguir para GUI;  
- `HTTP/1.1 401` → senha incorreta ou usuário bloqueado, tratar antes de abrir navegador.

### 4.6 Rede e Acesso em Hyper‑V

- Dentro da VM, `curl http://localhost:8080` funcionava, mas no host Windows o acesso via `http://localhost:8080` era recusado.  
- Foi necessário usar o IP da VM (`http://xxx.xxx.xxx.xxx:8080/midpoint`) no navegador do host.  
- Lição: em ambientes de virtualização, **documentar sempre o IP da VM e o tipo de virtual switch**; não assumir que `localhost` é compartilhado entre host e guest.

### 4.7 Senha Inicial x Senha Definitiva

- A senha configurada em `MP_SET_midpoint_administrator_initialPassword` é apenas um **bootstrap**.  
- Após o primeiro login com sucesso:  
- a senha do `administrator` deve ser trocada por uma senha definitiva e armazenada em cofre de segredos corporativo;  
- em produção, o Compose não deve conter senhas reais em texto claro (usar `.env`, secrets ou cofre externo).

---

## 5. Procedimento Padrão de Implantação midPoint 4.10

### 5.1 Pré‑requisitos

1. VM Linux com pelo menos **8 GB de RAM** e espaço de disco suficiente.  
2. Docker Engine e Docker Compose instalados.  
3. Acesso administrativo à VM (sudo).

### 5.2 Estrutura do Docker Compose (visão geral)

- Serviço `midpoint_data`  
- Imagem `postgres:16-alpine`.  
- Variáveis: `POSTGRES_PASSWORD`, `POSTGRES_USER`, `POSTGRES_INITDB_ARGS` (locale).  
- Volume persistente para dados do Postgres.

- Serviço `data_init`  
- Imagem `evolveum/midpoint:<versão>-alpine` (mesma do servidor).  
- Comando: `midpoint.sh init-native` + scripts `run-sql --create --mode REPOSITORY/AUDIT`.  
- Depende de `midpoint_data`.  
- Sem exposição de portas.

- Serviço `midpoint_server`  
- Imagem `evolveum/midpoint:<versão>-alpine`.  
- Depende de `data_init` (condição: `service_completed_successfully`) e de `midpoint_data`.  
- Porta `8080:8080`.  
- Variáveis de ambiente com prefixo `MP_SET_` para JDBC e senha inicial do administrador:  
  - `MP_SET_midpoint_repository_jdbcUsername`  
  - `MP_SET_midpoint_repository_jdbcPassword`  
  - `MP_SET_midpoint_repository_jdbcUrl`  
  - `MP_SET_midpoint_repository_database`  
  - `MP_SET_midpoint_administrator_initialPassword=MidP0int2025`  
  - `MP_UNSET_midpoint_repository_hibernateHbm2ddl=1`  
  - `MP_NO_ENV_COMPAT=1`

### 5.3 Passo a passo operacional

1. **Reset controlado (somente quando necessário)**  
 - Parar containers e remover volumes:  
   ```
   docker compose down -v
   sudo rm -rf postgresdata midpoint_home midpointhome
   ```  

2. **Subir o ambiente**  
docker compose up -d
docker ps -a

text
- Confirmar:  
  - `midpoint_data` → `Up`  
  - `data_init` → `Exited (0)`  
  - `midpoint_server` → `Up (healthy)`  

3. **Validar via REST**  
curl -vk
-u administrator:MidP0int2025
http://<IP_DA_VM>:8080/midpoint/ws/rest/self

text
- Se resposta for HTTP 200 com XML do usuário `administrator`, seguir.  
- Se for 401, revisar senha inicial e estado do usuário antes de abrir GUI.

4. **Acessar GUI**  
- Navegador (no host ou em outra máquina da rede):  
  ```
  http://<IP_DA_VM>:8080/midpoint
  ```  
- Login inicial com `administrator / MidP0int2025`.

5. **Hardening inicial**  
- Alterar a senha do `administrator`.  
- Criar um segundo usuário com `superuserRole` (conta de break‑glass).  
- Habilitar logs, ajustar locale/idioma, timezone, etc., conforme padrões Fiqueok.

---

## 6. Recomendações Futuras (Governança Fiqueok)

1. **Versionamento em Git**  
- Criar repositório `fiqueok-midpoint-infra` com:  
  - `docker-compose.yml` parametrizado (sem senhas reais);  
  - `.env.example` com placeholders;  
  - `.gitignore` incluindo `.env` e volumes.  

2. **Integração com outros stacks**  
- Manter padrão semelhante para `fiqueok-defectdojo-infra`, `fiqueok-main` (documentação geral), etc., garantindo coerência de nomenclatura e pasta.

3. **Reuso da KB**  
- Utilizar esta base como referência para novas implantações (clientes, ambientes homologação/produção), adaptando apenas:  
  - nomes de serviços,  
  - nomes de bancos,  
  - política de senhas e secrets.

---
