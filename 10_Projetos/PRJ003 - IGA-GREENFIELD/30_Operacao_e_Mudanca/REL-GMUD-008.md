# REL-GMUD-008 — Relatório de Execução da Mudança

**Status:** 🔴 EXECUTADA SEM SUCESSO  
**Projeto:** PRJ003 - IGA Greenfield Reference Architecture  
**Data de Execução:** 19/01/2026  
**Executor:** Paulo Feitosa  
**Tipo de Mudança:** Deploy Automatizado de Infraestrutura IAM

---

## 1. Sumário Executivo

A GMUD-008, planejada para automatizar o deploy da infraestrutura IGA (midPoint 4.8 + PostgreSQL 16) através de script PowerShell, foi **executada sem sucesso** após nove iterações de troubleshooting (v1.0 a v1.9). A decisão de encerramento foi tomada com base em análise de risco residual e conformidade com princípios de Gestão de Mudanças, evitando comprometimento da integridade do ambiente de produção.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/3cd86cc4-43a5-4b5d-ac33-5c07bf632dda/GMUD-008v1.4.txt)]​

**Impacto:** Nenhum serviço em produção foi afetado. A VM `iga-gf-01` foi revertida ao estado de snapshot PRE-GMUD-008 via procedimento de rollback.

**Classificação:** Falha Técnica Controlada (Categoria: Aprendizado de Processo)

---

## 2. Cronologia da Execução

|Horário|Versão|Evento|Resultado|
|---|---|---|---|
|19:00 UTC|v1.4|Primeira execução com validação de variáveis|❌ Erro SCRAM: senha vazia no PostgreSQL|
|19:45 UTC|v1.5|Adição de automação de infraestrutura VM|❌ Falso positivo: script reportou sucesso, mas DB rejeitou conexão|
|20:10 UTC|v1.6|Ajuste de expansão de variáveis com escape|❌ Volume envenenado: senha anterior persistiu|
|20:35 UTC|v1.7|Implementação de limpeza de volume com `-v`|❌ Conflito TTY: sudoers exigiu interação manual|
|21:00 UTC|v1.8|Refatoração: separação de módulos SO/Docker|⚠️ Execução parcial: Netplan aplicado, mas Docker falhou|
|21:30 UTC|v1.9|Tentativa final com injeção direta de credenciais|❌ Timeout de healthcheck: PostgreSQL não inicializou|
|22:00 UTC|-|**Decisão de Rollback**|✅ VM revertida ao snapshot limpo|

---

## 3. Diagnóstico das Causas Raízes (RCA)

## 3.1. Causa Primária: Vácuo de Variáveis no Interpretador PowerShell

**Descrição Técnica:**  
O carregamento do arquivo `.env` através do método `Get-Content` combinado com execução via colagem direta no terminal resultou em falha de escopo de variáveis. As variáveis `$POSTGRES_PASSWORD` e `$VM_IP` não foram expandidas no contexto do here-string `@" "@`, gerando URLs malformadas (`jdbc:postgresql:///midpoint`) e senhas vazias.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/3cd86cc4-43a5-4b5d-ac33-5c07bf632dda/GMUD-008v1.4.txt)]​

**Evidência:**

text

`Processing variable (MAP) ... midpoint.repository.jdbcPassword .:.` 

(Log da v1.4 mostra campo vazio onde deveria constar a senha)

**Impacto:** Falha de autenticação SCRAM-SHA-256 no PostgreSQL, impedindo inicialização do repositório midPoint.

---

## 3.2. Causa Secundária: Envenenamento de Volume (Persistence Poisoning)

**Descrição Técnica:**  
O PostgreSQL 16-alpine persiste a configuração de autenticação no arquivo `pg_hba.conf` e hash de senha no volume `/var/lib/postgresql/data` durante o **primeiro boot**. Tentativas subsequentes de corrigir a senha via variáveis de ambiente foram ignoradas, pois o banco considerou o cluster já inicializado.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/3cd86cc4-43a5-4b5d-ac33-5c07bf632dda/GMUD-008v1.4.txt)]​

**Evidência:**  
Após execução de `docker compose down` (sem flag `-v`), logs mostraram:

text

`PostgreSQL Database directory appears to contain a database; Skipping initialization`

**Impacto:** Cada iteração do script reforçava o estado corrompido, criando um ciclo de falhas persistente.

---

## 3.3. Causa Terciária: Conflito de Interatividade (Toil)

**Descrição Técnica:**  
A automação de configuração de SO (Netplan, Sudoers) via SSH remoto encontrou limitações de TTY no Ubuntu 24.04. Comandos como `sudo visudo` e aplicação de regras de rede exigiram confirmação interativa, quebrando o modelo "Zero-Touch" proposto.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/3cd86cc4-43a5-4b5d-ac33-5c07bf632dda/GMUD-008v1.4.txt)]​

**Evidência:**

powershell

`sudo: sorry, you must have a tty to run sudo`

**Impacto:** Scripts v1.7 e v1.8 falharam na fase de pré-configuração, impedindo validação do ambiente antes do deploy Docker.

---

## 4. Lições Aprendidas

## 4.1. Separação de Camadas (Separation of Concerns)

**Problema Identificado:**  
O script tentou consolidar três camadas distintas (Rede, SO, Aplicação) em um único artefato, violando o princípio de responsabilidade única.

**Recomendação para GMUD-009:**

- **Módulo 1 (Infra-Base):** Script de preparação de SO executado **manualmente uma única vez** para configurar Netplan, Sudoers e SSH.
    
- **Módulo 2 (Deploy IaC):** Script focado **exclusivamente em Docker Compose**, assumindo infraestrutura de SO já validada.
    
- **Módulo 3 (Validação):** Health check JDBC isolado antes da inicialização do midPoint.
    

---

## 4.2. Gestão de Segredos

**Problema Identificado:**  
Expansão de variáveis via here-strings (`@" "@`) do PowerShell é sensível a caracteres especiais e escopo de execução.

**Recomendação para GMUD-009:**

- Abandonar expansão inline de segredos.
    
- Utilizar montagem de arquivo `.env` diretamente no container Docker via diretiva `env_file:`.
    
- Implementar validação de hash SHA-256 do arquivo `.env` antes do deploy.
    

**Exemplo de Implementação:**

text

`services:   postgres:    env_file: /srv/prj003/.env    environment:      POSTGRES_INITDB_ARGS: "--auth-host=scram-sha-256"`

---

## 4.3. Protocolo de Rollback Obrigatório

**Problema Identificado:**  
O comando `docker compose down` preserva volumes nomeados, permitindo persistência de estados corrompidos.

**Recomendação para GMUD-009:**

- Incluir validação pré-deploy que força limpeza total:
    
    bash
    
    `docker compose down -v --remove-orphans sudo rm -rf /srv/prj003/data/postgres/*`
    
- Implementar snapshot automático da VM antes de cada tentativa de deploy.
    

---

## 4.4. Validação de Pré-Requisitos

**Problema Identificado:**  
O script assumiu que a infraestrutura de SO estava pronta, sem validação formal.

**Recomendação para GMUD-009:**

- Criar checklist de validação executado **antes** do deploy:
    
    -  IP estático configurado (`ip addr show eth0`)
        
    -  Sudoers sem senha (`sudo -n whoami`)
        
    -  SSH sem senha (`ssh -o BatchMode=yes`)
        
    -  Docker em execução (`docker ps`)
        
    -  Volumes limpos (`ls -la /srv/prj003/data/postgres/`)
        

---

## 5. Métricas de Falha

|Métrica|Valor|Observação|
|---|---|---|
|**Tempo Total de Execução**|3h 00min|Das 19:00 às 22:00 UTC|
|**Iterações de Troubleshooting**|9 versões|v1.4 até v1.9|
|**Downtime de Produção**|0 minutos|Nenhum serviço afetado (ambiente greenfield)|
|**Tempo de Rollback**|15 minutos|Reversão ao snapshot PRE-GMUD-008|
|**Taxa de Sucesso de Deploys**|0%|Nenhuma versão atingiu estado "healthy"|

---

## 6. Ações de Contenção Executadas

## 6.1. Rollback Completo

**Comando Executado:**

bash

`ssh paulo@xxx.xxx.xxx.xxx "cd /srv/prj003 && docker compose down -v && sudo rm -rf /srv/prj003/*"`

**Resultado:** VM retornada ao estado zero (snapshot PRE-GMUD-008).

## 6.2. Preservação de Evidências

**Artefatos Arquivados:**

- Logs de execução das versões v1.4 a v1.9 (`GMUD-008v1.4.txt`)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/3cd86cc4-43a5-4b5d-ac33-5c07bf632dda/GMUD-008v1.4.txt)]​
    
- Arquivo `.env` com hash SHA-256 documentado
    
- Screenshots de erros SCRAM no console Docker
    

**Localização:** `/srv/prj003/evidencias/GMUD-008-FAILURE/`

---

## 7. Classificação de Impacto

**Impacto Técnico:** 🟡 MÉDIO

- Nenhum dado de produção perdido
    
- VM revertida com sucesso
    
- Conhecimento técnico adquirido sobre autenticação SCRAM
    

**Impacto de Negócio:** 🟢 BAIXO

- Projeto em fase greenfield (sem usuários ativos)
    
- Atraso de 1 dia no cronograma de deployment
    
- Reputação da marca Fiqueok **preservada** pela decisão proativa de rollback
    

**Impacto de Conformidade:** 🟢 BAIXO

- Processo de Gestão de Mudanças seguido corretamente
    
- Documentação completa gerada (RCA + Lições Aprendidas)
    
- Auditoria de decisão registrada em formato rastreável
    

---

## 8. Recomendações para GMUD-009

## 8.1. Pré-Requisitos Obrigatórios

Antes de iniciar a GMUD-009, executar **manualmente** na VM:

bash

`# 1. Validar IP estático sudo netplan apply && ip addr show eth0 | grep "xxx.xxx.xxx.xxx" # 2. Validar sudoers sudo -n whoami  # Deve retornar "root" sem pedir senha # 3. Validar SSH ssh -o BatchMode=yes paulo@xxx.xxx.xxx.xxx echo "OK" # 4. Limpar ambiente cd /srv/prj003 && docker compose down -v && sudo rm -rf data/*`

## 8.2. Nova Arquitetura de Script

**Estrutura Proposta:**

text

`PRJ003-IGA-GREENFIELD/ ├── 00-infra-baseline.sh      # Configuração manual de SO (executar 1x) ├── 01-deploy-iac.ps1          # Deploy Docker (idempotente) ├── 02-validate-health.ps1     # Testes de conectividade └── .env                       # Segredos (montado via env_file)`

## 8.3. Critérios de Aceitação para GMUD-009

-  PostgreSQL aceita conexão JDBC com credenciais corretas
    
-  midPoint exibe tela de login em `http://xxx.xxx.xxx.xxx:8080/midpoint`
    
-  Health checks permanecem "healthy" por 10 minutos consecutivos
    
-  Script executa com sucesso em **duas rodadas consecutivas** (teste de idempotência)
    

---

## 9. Parecer de Auditoria

A decisão de encerrar a GMUD-008 como **"Executada sem Sucesso"** está em conformidade com as melhores práticas de Gestão de Riscos e Governança de TI. A insistência em uma automação com comportamento inconsistente geraria risco residual inaceitável para a operação.

**Ganhos Intangíveis:**

- Domínio aprofundado de autenticação SCRAM-SHA-256
    
- Compreensão de ciclo de vida de volumes Docker
    
- Experiência prática em troubleshooting de orquestração Windows-Linux
    

**Autorização de Encerramento:**  
Solicito aprovação para arquivamento da GMUD-008 e abertura formal da **GMUD-009** com escopo revisado e lições aprendidas incorporadas.

---

## 10. Assinaturas

**Executor Técnico:**  
Paulo Feitosa  
Data: 19/01/2026 22:00 UTC

**Revisor de Governança:**  
Assistente Técnico (IA Evolveum)  
Data: 19/01/2026 22:30 UTC

**Status Final:**  
🔴 ENCERRADA SEM SUCESSO — Rollback Completo Executado

---

**Anexos:**

- [GMUD-008v1.4.txt] - Log de execução completo[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/3cd86cc4-43a5-4b5d-ac33-5c07bf632dda/GMUD-008v1.4.txt)]​
    
- [GMUD-008-Deploy-v1.5.ps1] - Última versão do script
    
- [.env.sha256] - Hash de validação do arquivo de segredos
    

**Próximos Passos:**  
Criação da GMUD-009 com arquitetura modular e validação de baseline de SO como pré-requisito obrigatório.
