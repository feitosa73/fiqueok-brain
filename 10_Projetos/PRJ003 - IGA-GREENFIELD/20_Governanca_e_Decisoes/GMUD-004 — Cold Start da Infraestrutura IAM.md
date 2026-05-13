

**Projeto:** PRJ003 — IGA Greenfield Reference Architecture  
**Tipo de Mudança:** Técnica (Infraestrutura)  
**Categoria:** Cold Start (sem integração funcional)  
**Status:** Planejada  
**Owner:** Paulo Feitosa  
**Contexto:** Living Lab Fiqueok 2.0  
**Dependências:** GMUD-003 encerrada com sucesso  

---

## 1. Objetivo da Mudança

Esta GMUD tem como objetivo **realizar o Cold Start da infraestrutura IAM**, criando um ambiente técnico **estável, reproduzível e neutro**, apto a receber futuras GMUDs de integração, **sem introduzir qualquer decisão semântica ou funcional de identidade**.

A GMUD-004 **não busca valor funcional**. Seu foco é **infraestrutura e estabilidade**.

---

## 2. Escopo da GMUD

### 2.1 Incluído no Escopo
- Provisionamento de ambiente IAM em estado virgem
- Execução do midPoint em ambiente controlado
- Configuração de persistência (PostgreSQL + volumes Docker)
- Validação de inicialização, estabilidade e reinício
- Configuração mínima de logging e evidência
- Registro técnico e rastreável da infraestrutura base

### 2.2 Fora do Escopo (Explícito)
- Integração com AD
- Integração com OrangeHRM
- Ingestão de identidades
- Automação de lifecycle (JML)
- Criação de workflows
- Criação de roles ou grupos
- Decisões semânticas de identidade
- Inferência de estados de identidade

---

## 3. Pré-condições (Pre-Flight)

A execução desta GMUD está condicionada ao **Pre-Flight aprovado**, com os seguintes gates atendidos:

- Governança (CAN-ID / DEC-ID / DGC consolidados)
- Escopo claramente limitado a Cold Start
- Arquitetura coerente (IGA como plataforma técnica)
- Pré-requisitos técnicos definidos
- Estratégia de evidência estabelecida

---

## 4. Arquitetura Técnica da GMUD-004

### 4.1 Ambiente de Execução
- **Plataforma:** VM Ubuntu dedicada ao Lab
- **Orquestração:** Docker Compose
- **Serviços nesta GMUD:**
  - midPoint
  - PostgreSQL

> Observação: A arquitetura conceitual já prevê futuras integrações com AD e OrangeHRM, que serão tratadas em GMUDs específicas.

---

### 4.2 Persistência
- Banco de dados PostgreSQL persistente
- Volumes Docker explicitamente mapeados
- Dados sobrevivem a `docker compose down/up`
- Caminhos de persistência documentados na VM

---

### 4.3 Logs e Observabilidade
- Logs do midPoint armazenados em volume persistente na VM  
  Exemplo:
  ```text
  /srv/prj003/logs/midpoint
  - Logs dos containers via mecanismo padrão do Docker (`docker logs`)
    
- Captura manual de logs quando necessário como evidência


## 5. Atividades Planejadas

1. Preparação da VM Ubuntu
    
2. Instalação e validação do Docker e Docker Compose
    
3. Criação da estrutura de diretórios para persistência e logs
    
4. Definição do arquivo `docker-compose.yml`
    
5. Subida inicial dos serviços
    
6. Validação de inicialização do midPoint
    
7. Validação de persistência após restart
    
8. Validação de estabilidade básica
    
9. Coleta de evidências técnicas
    

---

## 6. Controles e Restrições

- Nenhuma integração funcional será realizada
    
- Nenhuma identidade será criada ou importada
    
- Nenhuma automação será configurada
    
- Nenhuma limitação técnica autoriza alteração arquitetural
    
- Exceções devem ser registradas e **não normalizadas**
    

---

## 7. Riscos Identificados

|Risco|Mitigação|
|---|---|
|Ambiente não persistir após restart|Validação explícita de volumes|
|Erros de bootstrap do midPoint|Logs persistentes e captura de evidências|
|Escopo creep técnico|Escopo fora claramente definido|

---

## 8. Critérios de Sucesso

A GMUD-004 será considerada **bem-sucedida** quando:

- O midPoint inicializar corretamente
    
- O ambiente permanecer estável após reinicializações
    
- A persistência for validada
    
- Nenhuma decisão semântica tiver sido tomada
    
- Nenhuma integração funcional tiver ocorrido
    
- Evidências estiverem armazenadas no local correto
    

---

## 9. Evidências Esperadas

- Logs de inicialização do midPoint
    
- Prints da interface administrativa
    
- Registro do `docker-compose.yml`
    
- Registro dos volumes e caminhos de persistência
    
- Anotações técnicas relevantes
    

---

## 10. Resultado Esperado

Ao final desta GMUD, o PRJ003 contará com:

- Infraestrutura IAM funcional em nível técnico
    
- Base estável para futuras GMUDs de integração
    
- Ambiente reproduzível para aprendizado do midPoint
    
- Nenhum débito semântico ou arquitetural introduzido
    

---

## 11. Próximos Passos Recomendados

- Execução da **GMUD-005 — Integração da Fonte de Negócio (HR)**  
    ou
    
- Execução da **GMUD-005 — Integração com Active Directory**
    

A escolha deverá respeitar os contratos definidos nos CAN-ID e DEC-ID.



|Versão|Data|Autor|Observação|
|---|---|---|---|
|1.0|2026-01-14|Paulo Feitosa|Criação da GMUD-004|
