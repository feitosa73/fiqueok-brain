

**Projeto:** PRJ003 â€” IGA Greenfield  
**Tipo:** GMUD â€” MudanÃ§a TÃ©cnica (Plataforma)  
**Status:** Planejada  
**ResponsÃ¡vel:** Paulo Feitosa  
**Apoio TÃ©cnico:** ChatGPT  
**Data:** 14/01/2026  
**Contexto:** Living Lab Fiqueok 2.0  
**DependÃªncias:** GMUD-004 (REL-GMUD-004) concluÃ­da com sucesso

---

## 1. Objetivo da GMUD

Estabelecer a plataforma funcional IGA do PRJ003, executando o midPoint com persistÃªncia PostgreSQL em ambiente Docker, criando a base tÃ©cnica operacional para futuras integraÃ§Ãµes de identidade, sem realizar ingesto de dados ou configuraÃ§Ãµes funcionais de conectores.GMUD-004-Cold-Start-da-Infraestrutura-IAM.md+1â€‹

Esta GMUD materializa tecnicamente o IGA como orquestrador de identidade, respeitando integralmente os contratos semÃ¢nticos estabelecidos nos Canvases CAN-ID-001, CAN-ID-002 e CAN-ID-003.REL-GMUD-003-Relatorio-de-Execucao-da-Mudanca.md+1â€‹

---

## 2. Escopo da MudanÃ§a

## 2.1. Includo no Escopo

- CriaÃ§Ã£o e validaÃ§Ã£o do arquivo `docker-compose.yml` para orquestraÃ§Ã£o dos serviÃ§os
    
- ExecuÃ§Ã£o do container midPoint em versÃ£o estÃ¡vel LTS
    
- ExecuÃ§Ã£o do container PostgreSQL como repositÃ³rio de persistÃªncia do midPoint
    
- ConfiguraÃ§Ã£o de volumes Docker persistentes para:
    
    - Banco de dados PostgreSQL
        
    - Dados de configuraÃ§Ã£o do midPoint (`/opt/midpoint/var`)
        
    - Logs do midPoint
        
- ConfiguraÃ§Ã£o de rede interna Docker entre midPoint e PostgreSQL
    
- ValidaÃ§Ã£o de inicializaÃ§Ã£o e acesso Ã  interface administrativa do midPoint
    
- ValidaÃ§Ã£o de persistÃªncia apÃ³s `docker compose down` e `docker compose up`
    
- ValidaÃ§Ã£o de estabilidade bÃ¡sica da plataforma
    
- Coleta e armazenamento de evidÃªncias tÃ©cnicas
    

## 2.2. Explicitamente Fora do Escopo

- IntegraÃ§Ã£o com Active Directory, LDAP ou qualquer fonte tÃ©cnica
    
- IntegraÃ§Ã£o com OrangeHRM ou qualquer fonte de negÃ³cio
    
- Ingesto, criaÃ§Ã£o ou provisionamento de identidades
    
- ConfiguraÃ§Ã£o de recursos (resources) no midPoint
    
- CriaÃ§Ã£o de conectores ou mapeamentos de atributos
    
- AutomaÃ§Ã£o de lifecycle (JML - Joiner/Mover/Leaver)
    
- CriaÃ§Ã£o de roles, organizaÃ§Ãµes ou polÃ­ticas de acesso
    
- ConfiguraÃ§Ã£o de workflows ou aprovaÃ§Ãµes
    
- DecisÃµes semÃ¢nticas de identidade em tempo de execuÃ§Ã£o
    
- Tuning de performance ou hardening de seguranÃ§a
    

---

## 3. Contexto e Justificativa

A GMUD-004 estabeleceu com sucesso a infraestrutura base (VM Ubuntu, Docker Engine, Docker Compose), criando o ambiente virgem necessÃ¡rio para execuÃ§Ã£o da plataforma IGA.GMUD-004-Cold-Start-da-Infraestrutura-IAM-v1.1.md+1â€‹

A GMUD-005 representa o prÃ³ximo marco tÃ©cnico natural: materializar o IGA como plataforma operacional, mantendo o ambiente em estado neutro e preparado para receber, em GMUDs subsequentes, as integraÃ§Ãµes com fontes de identidade respeitando os contratos de autoridade de dados e estados da identidade jÃ¡ consolidados.REL-GMUD-003-Relatorio-de-Execucao-da-Mudanca.mdâ€‹

---

## 4. Arquitetura TÃ©cnica da GMUD-005

## 4.1. Ambiente de ExecuÃ§Ã£o

- **Plataforma:** VM Ubuntu 24.04 LTS (IGA-GF-01) - IP <LAB_VM_IP>
    
- **OrquestraÃ§Ã£o:** Docker Compose v5.0.1
    
- **Rede:** Bridge interna Docker (`iga-network`)
    

## 4.2. Componentes e ServiÃ§os

|Componente|Imagem Docker|VersÃ£o Alvo|FunÃ§Ã£o|
|---|---|---|---|
|midPoint|evolveum/midpoint|4.8 LTS|Plataforma IGA - orquestrador de identidade|
|PostgreSQL|postgres|16-alpine|RepositÃ³rio de persistÃªncia do midPoint|

## 4.3. PersistÃªncia e Volumes

Os seguintes volumes Docker persistentes serÃ£o criados e mapeados:

text

`/srv/prj003/data/postgres     â†’ Dados do PostgreSQL /srv/prj003/data/midpoint/var â†’ Dados de configuraÃ§Ã£o e estado do midPoint /srv/prj003/logs/midpoint     â†’ Logs aplicacionais do midPoint`

**PrincÃ­pio:** Todos os dados devem sobreviver a `docker compose down` e reinicializaÃ§Ãµes da VM.GMUD-004-Cold-Start-da-Infraestrutura-IAM.mdâ€‹

## 4.4. ConfiguraÃ§Ã£o de Rede

- Rede bridge interna: `iga-network`
    
- midPoint â†’ PostgreSQL: comunicaÃ§Ã£o via hostname `postgres` na porta `5432`
    
- Acesso externo ao midPoint: porta `8080` (HTTP)
    
- PostgreSQL nÃ£o exposto externamente (somente acesso interno)
    

---

## 5. Atividades Planejadas

1. CriaÃ§Ã£o da estrutura de diretÃ³rios de persistÃªncia na VM (`/srv/prj003/data`, `/srv/prj003/logs`)
    
2. DefiniÃ§Ã£o do arquivo `docker-compose.yml` com configuraÃ§Ãµes de:
    
    - ServiÃ§o PostgreSQL (credenciais, volumes, rede)
        
    - ServiÃ§o midPoint (conexÃ£o ao PostgreSQL, volumes, portas)
        
    - Rede interna Docker
        
    - PolÃ­tica de restart (unless-stopped)
        
3. ValidaÃ§Ã£o sintÃ¡tica do `docker-compose.yml`
    
4. Primeira execuÃ§Ã£o: `docker compose up -d`
    
5. ValidaÃ§Ã£o de logs de inicializaÃ§Ã£o:
    
    - PostgreSQL: criaÃ§Ã£o de banco `midpoint`
        
    - midPoint: bootstrap inicial, conexÃ£o ao banco
        
6. Acesso Ã  interface administrativa do midPoint (`http://<LAB_VM_IP>:8080/midpoint`)
    
7. Login com credenciais default (`<SENHA_EXEMPLO>`)
    
8. ValidaÃ§Ã£o de interface funcional (sem configuraÃ§Ãµes)
    
9. Teste de persistÃªncia:
    
    - `docker compose down`
        
    - `docker compose up -d`
        
    - VerificaÃ§Ã£o de estado preservado
        
10. Coleta de evidÃªncias tÃ©cnicas (logs, prints, configuraÃ§Ãµes)
    

---

## 6. PrÃ©-condiÃ§Ãµes e DependÃªncias

## 6.1. Gates ObrigatÃ³rios

- âœ… GMUD-004 concluÃ­da com sucesso (REL-GMUD-004)
    
- âœ… Infraestrutura base operacional (VM, Docker, rede)
    
- âœ… GovernanÃ§a de identidade consolidada (CAN-ID, DEC-ID, DGC)
    
- âœ… Escopo tÃ©cnico claramente delimitado
    

## 6.2. DependÃªncias TÃ©cnicas

- VM IGA-GF-01 acessÃ­vel via SSH
    
- Acesso Ã  internet para download de imagens Docker (Docker Hub)
    
- EspaÃ§o em disco: mÃ­nimo 10 GB livres em `/srv`
    

---

## 7. Controles e RestriÃ§Ãµes

- Nenhuma integraÃ§Ã£o funcional serÃ¡ realizada nesta GMUD
    
- Nenhuma identidade serÃ¡ criada, importada ou provisionada
    
- Nenhuma automaÃ§Ã£o ou workflow serÃ¡ configurado
    
- Nenhum conector ou recurso serÃ¡ criado
    
- A plataforma serÃ¡ mantida em estado funcional neutro
    
- ConfiguraÃ§Ãµes devem ser mÃ­nimas (apenas as necessÃ¡rias para bootstrap)
    
- Nenhuma limitaÃ§Ã£o tÃ©cnica autoriza alteraÃ§Ã£o de decisÃµes semÃ¢nticas
    
- ExcepÃ§Ãµes devem ser registradas explicitamente, nÃ£o normalizadas
    

---

## 8. Riscos Identificados e MitigaÃ§Ã£o

|Risco|Probabilidade|Impacto|MitigaÃ§Ã£o|
|---|---|---|---|
|Falha de bootstrap do midPoint|MÃ©dia|Alto|Logs persistentes, anÃ¡lise de troubleshooting oficial Evolveum|
|Incompatibilidade PostgreSQL/midPoint|Baixa|Alto|Uso de versÃµes LTS documentadas e testadas|
|Perda de dados apÃ³s restart|Baixa|MÃ©dio|ValidaÃ§Ã£o explÃ­cita de volumes antes de prosseguir|
|Escopo creep tÃ©cnico (criaÃ§Ã£o de conectores)|MÃ©dia|MÃ©dio|RevisÃ£o rigorosa do escopo, separaÃ§Ã£o clara em GMUD-006+|

---

## 9. CritÃ©rios de Sucesso

A GMUD-005 serÃ¡ considerada bem-sucedida quando:

- âœ… O midPoint inicializar corretamente e se conectar ao PostgreSQL
    
- âœ… A interface administrativa estiver acessÃ­vel via navegador
    
- âœ… Login com credenciais default funcionar corretamente
    
- âœ… A persistÃªncia for validada apÃ³s `docker compose down/up`
    
- âœ… Os volumes estiverem corretamente mapeados e funcionais
    
- âœ… Logs estiverem sendo armazenados em diretÃ³rios persistentes
    
- âœ… O ambiente permanecer estÃ¡vel apÃ³s reinicializaÃ§Ã£o
    
- âœ… Nenhuma decisÃ£o semÃ¢ntica tiver sido tomada
    
- âœ… Nenhuma integraÃ§Ã£o funcional tiver sido realizada
    
- âœ… EvidÃªncias tÃ©cnicas estiverem coletadas e armazenadas
    

---

## 10. EvidÃªncias Esperadas

As seguintes evidÃªncias deverÃ£o ser coletadas e consolidadas no REL-GMUD-005:

- ConteÃºdo completo do arquivo `docker-compose.yml`
    
- Output de `docker compose up -d` (primeira execuÃ§Ã£o)
    
- Logs de inicializaÃ§Ã£o do PostgreSQL (`docker logs postgres`)
    
- Logs de inicializaÃ§Ã£o do midPoint (`docker logs midpoint`)
    
- Print da interface administrativa do midPoint (tela de login)
    
- Print da interface administrativa do midPoint (dashboard pÃ³s-login)
    
- Output de `docker ps` (containers em execuÃ§Ã£o)
    
- Output de `docker volume ls` (volumes criados)
    
- ValidaÃ§Ã£o de persistÃªncia (logs antes e depois do restart)
    
- Estrutura de diretÃ³rios criada em `/srv/prj003`
    

---

## 11. Resultado Esperado

Ao final desta GMUD, o PRJ003 contarÃ¡ com:

- Plataforma IGA midPoint funcional e acessÃ­vel
    
- RepositÃ³rio de persistÃªncia PostgreSQL operacional
    
- Ambiente Docker estÃ¡vel com volumes persistentes
    
- Base tÃ©cnica pronta para GMUDs de integraÃ§Ã£o (GMUD-006+)
    
- Nenhum dÃ©bito semÃ¢ntico ou arquitetural introduzido
    
- Ambiente reproduzÃ­vel para aprendizado e evoluÃ§Ã£o controlada
    

---

## 12. Plano de Rollback

Em caso de falha crÃ­tica ou necessidade de reversÃ£o:

1. Executar `docker compose down` (para os serviÃ§os)
    
2. Remover volumes Docker criados (se necessÃ¡rio reset completo): `docker volume rm prj003_postgres_data prj003_midpoint_var`
    
3. Remover diretÃ³rios de persistÃªncia: `sudo rm -rf /srv/prj003`
    
4. Retornar ao estado pÃ³s-GMUD-004 (infraestrutura virgem)
    
5. Registrar causa raiz no REL-GMUD-005
    
6. Replanejar GMUD-005 com ajustes identificados
    

**Tempo estimado de rollback:** < 10 minutos

---

## 13. PrÃ³ximos Passos Recomendados

ApÃ³s conclusÃ£o bem-sucedida da GMUD-005, as seguintes GMUDs tornam-se viÃ¡veis:

- **GMUD-006:** IntegraÃ§Ã£o com Fonte de NegÃ³cio (OrangeHRM)
    
- **GMUD-007:** IntegraÃ§Ã£o com Active Directory (fonte tÃ©cnica)
    

A escolha deverÃ¡ respeitar:

- Contratos definidos em CAN-ID-002 (Autoridade de Dados de Identidade)
    
- PrincÃ­pios de precedÃªncia de fontes de negÃ³cio sobre fontes tÃ©cnicas
    
- GovernanÃ§a estabelecida em DEC-ID-001
    

---

## 14. ReferÃªncias

- GMUD-004 v1.1 â€” Cold Start da Infraestrutura IAM
    
- REL-GMUD-004 â€” Cold Start da Infraestrutura IAM
    
- CAN-ID-001 â€” Identidade CanÃ´nica (PRJ003)
    
- CAN-ID-002 â€” Autoridade de Dados de Identidade (PRJ003)
    
- CAN-ID-003 â€” Estados da Identidade (PRJ003)
    
- DEC-ID-001 â€” Identity Decision Canvas (PRJ003)
    
- DGC-001 â€” Data Governance Canvas (PRJ003)
    
- DocumentaÃ§Ã£o oficial midPoint: [https://docs.evolveum.com/midpoint/](https://docs.evolveum.com/midpoint/)
    

---

## 15. AprovaÃ§Ã£o

|Papel|Nome|Status|
|---|---|---|
|Solicitante|Paulo Feitosa|Aprovado|
|Executor|Paulo Feitosa|Aprovado|
|Aprovador Final|Paulo Feitosa|Aprovado|

---

## 16. Controle de VersÃ£o

|VersÃ£o|Data|Autor|MudanÃ§a|
|---|---|---|---|
|1.0|2026-01-14|Paulo Feitosa|CriaÃ§Ã£o da GMUD-005|

---

**RepositÃ³rio:** Obsidian Vault FiqueokBrain  
**Caminho:** `10_Projetos/PRJ003 - IGA-GREENFIELD/40_GMUDs/GMUD-005.md`

---

**Documento de planejamento conforme modelo definido no Living Lab Fiqueok 2.0**

1. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/aaaa6d73-8046-4c03-a615-42951a1b8e48/GMUD-004-Cold-Start-da-Infraestrutura-IAM.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/aaaa6d73-8046-4c03-a615-42951a1b8e48/GMUD-004-Cold-Start-da-Infraestrutura-IAM.md)
2. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/99743f5c-9217-451b-aca3-4970283c8e45/GMUD-004-Cold-Start-da-Infraestrutura-IAM-v1.1.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/99743f5c-9217-451b-aca3-4970283c8e45/GMUD-004-Cold-Start-da-Infraestrutura-IAM-v1.1.md)
3. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/5509885c-1c39-4fe8-94ab-549f1746392e/REL-GMUD-003-Relatorio-de-Execucao-da-Mudanca.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/5509885c-1c39-4fe8-94ab-549f1746392e/REL-GMUD-003-Relatorio-de-Execucao-da-Mudanca.md)
4. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/3a5b9880-2d04-451a-9e59-5f0471282cd5/GMUD-002-Consolidacao-dos-Canvases-de-Decisao-de-Identidade-PRJ003.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/3a5b9880-2d04-451a-9e59-5f0471282cd5/GMUD-002-Consolidacao-dos-Canvases-de-Decisao-de-Identidade-PRJ003.md)
5. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/c8358c09-5c8b-47ef-88a9-a801f452e48d/GMUD-004-Evidencias-de-Execucao.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/c8358c09-5c8b-47ef-88a9-a801f452e48d/GMUD-004-Evidencias-de-Execucao.md)
6. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/66d831c4-92fd-4549-b70d-04a82c076b73/REL-GMUD-002-Relatorio-de-Execucao-da-Consolidacao-dos-Canvases-de-Decisao-de-Identidade-PRJ003.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/66d831c4-92fd-4549-b70d-04a82c076b73/REL-GMUD-002-Relatorio-de-Execucao-da-Consolidacao-dos-Canvases-de-Decisao-de-Identidade-PRJ003.md)
7. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/6374a263-00df-44b8-b6d1-d518153c4ccf/C4-Contexto-Arquitetura-de-Identidade-PRJ003.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/6374a263-00df-44b8-b6d1-d518153c4ccf/C4-Contexto-Arquitetura-de-Identidade-PRJ003.md)
8. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/84dac2cc-1149-4c4c-8e10-01dc42be01fa/GMUD-001.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/84dac2cc-1149-4c4c-8e10-01dc42be01fa/GMUD-001.md)
9. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/6a67cddf-a2e1-4b91-8618-8af90657342f/DGC-001-Data-Governance-Canvas-PRJ003.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/6a67cddf-a2e1-4b91-8618-8af90657342f/DGC-001-Data-Governance-Canvas-PRJ003.md)
10. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/e69cb7ac-4871-4e56-9ffb-499a1dc97db2/DEC-ID-001-Identity-Decision-Canvas-Governanca-de-Decisao-no-PRJ003.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/e69cb7ac-4871-4e56-9ffb-499a1dc97db2/DEC-ID-001-Identity-Decision-Canvas-Governanca-de-Decisao-no-PRJ003.md)
11. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/8e87282f-0177-417b-bcb3-8c40bd8fc414/CAN-ID-003-Estados-da-Identidade-PRJ003.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/8e87282f-0177-417b-bcb3-8c40bd8fc414/CAN-ID-003-Estados-da-Identidade-PRJ003.md)
12. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/f041cff2-e637-4cee-b8b3-b4dbd02b5618/CAN-ID-002-Autoridade-de-Dados-de-Identidade-PRJ003.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/f041cff2-e637-4cee-b8b3-b4dbd02b5618/CAN-ID-002-Autoridade-de-Dados-de-Identidade-PRJ003.md)
13. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/d95fc2b9-3e01-4ad4-89c3-7c9bf963d12f/CAN-ID-001-Identidade-Canonica-PRJ003.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/d95fc2b9-3e01-4ad4-89c3-7c9bf963d12f/CAN-ID-001-Identidade-Canonica-PRJ003.md)
