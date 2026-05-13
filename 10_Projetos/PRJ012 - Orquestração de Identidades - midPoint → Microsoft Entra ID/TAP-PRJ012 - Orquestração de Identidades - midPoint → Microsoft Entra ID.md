C

|Campo|Valor|
|---|---|
|**Código do Projeto**|PRJ012|
|**Data de Abertura**|04/03/2026|
|**Responsável Técnico**|Paulo Lima — Especialista IAM/IGA|
|**Organização**|Lab Fiqueok — Ambiente de Aprendizado e Simulação Técnica|
|**Versão do Documento**|1.0 — Draft|
|**Status**|INICIADO|
|**Classificação**|Interno — Lab Fiqueok|
|**Repositório**|`FiqueokBrain/1.0 Projetos/PRJ012/10 Iniciação/TAP-PRJ012.md`|

---

## 1. Resumo Executivo

O PRJ012 tem como objetivo implementar a orquestração de identidades entre o **OrangeHRM** (fonte autoritativa de RH) e o **Microsoft Entra ID** (diretório de nuvem), utilizando o **midPoint** como hub central de IGA (Identity Governance and Administration). O projeto entrega automação do ciclo JML (Joiner, Mover, Leaver) com rastreabilidade, auditabilidade e evidências técnicas alinhadas ao perfil de competências AZ-305/IAM.

O projeto adota uma **arquitetura faseada em três atos**, priorizando fundação de conectividade antes de complexidade de integração — padrão validado com sucesso no PRJ007 (ADR-005).

---

## 2. Contexto e Justificativa

## 2.1. Estado Atual da Infraestrutura

|Componente|Estado|Detalhe|
|---|---|---|
|**Rede**|✅ Operacional|Mesh via Tailscale|
|**OrangeHRM 5.x**|✅ Operacional|Container Docker — host `rh-gf-01` (IP Tailscale: `xxx.xxx.xxx.xxx`)|
|**MariaDB 10.11**|✅ Operacional|Container `orange-db` — banco de dados do OrangeHRM|
|**Microsoft Entra ID**|✅ Operacional|Tenant: `paulofiqueokcom.onmicrosoft.com` / Domínio: `fiqueok.com.br` — Tier Free|
|**midPoint**|⚠️ Greenfield|Container Docker no host `IGA-GF-01` — acessível via Tailscale, sem conectores configurados|
|**App Registration Azure**|❌ Inexistente|Nenhuma automação pode tocar o Entra ID hoje|
|**Identidades**|✅ 100 usuários|`FP001–FP100` provisionados manualmente via script (PRJ010/PRJ011)|

## 2.2. Justificativa do Projeto

O Entra ID possui 100 identidades fictícias com atributos de governança corretos (`Department`, `JobTitle`, `EmployeeID`) e grupos de segurança criados — ativo construído com esforço nos PRJ010 e PRJ011. O OrangeHRM possui os mesmos 100 colaboradores como fonte autoritativa, incluindo `Salary`, `SecurityGroup` e mapeamento `EmployeeID → OnPremisesImmutableId` conceitualmente definido.

A ausência do App Registration bloqueia qualquer automação via midPoint. Executar a integração completa com midPoint Greenfield e sem esta fundação repetiria o antipadrão evitado no PRJ007: construir cobertura antes do alicerce.

---

## 3. Objetivos do Projeto

|ID|Objetivo|Critério de Sucesso|
|---|---|---|
|OBJ-01|Criar App Registration no Azure com permissões corretas|Client Secret gerado, consentimento administrativo aplicado, teste via Graph Explorer OK|
|OBJ-02|Configurar conector midPoint → Entra ID via Graph API|midPoint importa schema dos 100 usuários existentes sem criar duplicatas|
|OBJ-03|Implementar reconciliação de leitura (Dry Run)|Relatório de reconciliação gerado, zero alterações destrutivas|
|OBJ-04|Mapear `EmployeeID` como `OnPremisesImmutableId` (âncora)|Matching 1:1 entre usuários midPoint e Entra ID sem colisões|
|OBJ-05|Configurar conector OrangeHRM → midPoint via DatabaseTable|midPoint lê os 100 registros do MariaDB com todos os atributos|
|OBJ-06|Implementar RBAC por `Department` em grupos estáticos do Entra ID|Usuários alocados automaticamente em grupos sem licença P1|
|OBJ-07|Implementar ciclo JML básico funcional|Joiner, Mover e Leaver detectados e refletidos no Entra ID com auditoria|

---

## 4. Escopo

## 4.1. Incluído

- Criação e configuração do App Registration no Microsoft Azure
    
- Configuração do conector Microsoft Graph API no midPoint
    
- Mapeamento de schema e definição de âncora `EmployeeID`
    
- Reconciliação de leitura (Dry Run) contra os 100 usuários existentes
    
- Configuração do conector DatabaseTable para MariaDB (OrangeHRM)
    
- Automação de RBAC por `Department` em grupos de segurança estáticos
    
- Ciclo JML: Joiner (novo colaborador), Mover (mudança de cargo/dept), Leaver (desligamento + disable + revogação de sessão)
    
- Estratégia de segurança via Tailscale para toda comunicação interna
    
- Documentação técnica de cada fase com evidências auditáveis
    

## 4.2. Excluído

- Migração de dados reais ou produtivos
    
- Configuração de Grupos Dinâmicos (requer licença Entra ID P1)
    
- Implementação de MFA ou Conditional Access
    
- Integração com Vault/PKI (prevista para PRJ013)
    
- Alta disponibilidade do midPoint (cluster multi-node)
    
- Automação de aprovações (workflows de access request)
    

---

## 5. Arquitetura da Solução

text

`┌─────────────────────────────────────────────────────────────────┐ │                        REDE TAILSCALE (MESH)                    │ │                                                                 │ │  ┌──────────────────┐        ┌──────────────────────────────┐  │ │  │   OrangeHRM 5.x  │        │         midPoint             │  │ │  │  rh-gf-01        │──SQL──▶│        IGA-GF-01             │  │ │  │  xxx.xxx.xxx.xxx    │        │  (Hub Central IGA)           │  │ │  │  [MariaDB 10.11] │        │                              │  │ │  └──────────────────┘        │  Conector DB ◀── MariaDB     │  │ │                              │  Conector Azure ──▶ Graph API│  │ │                              └──────────────┬───────────────┘  │ │                                             │                   │ │                                        HTTPS/OAuth2             │ │                                        (Client Credentials)     │ │                                             │                   │ └─────────────────────────────────────────────┼───────────────────┘                                               ▼                              ┌───────────────────────────────┐                              │      Microsoft Entra ID        │                              │  paulofiqueokcom.onmicrosoft   │                              │  100 usuários FP001–FP100      │                              │  Grupos de Segurança (Estáticos│                              └───────────────────────────────┘`

---

## 6. Plano de Execução — Três Atos

## ATO 1 — Fundação de Conectividade Azure

**Duração estimada:** 2–4 horas  
**Dependência:** Nenhuma

|Tarefa|Detalhe|
|---|---|
|Criar App Registration|Azure Portal → `midpoint-iga-connector`|
|Gerar Client Secret|Validade: 12 meses — armazenar no Vault (PRJ007)|
|Atribuir permissões de API|`User.ReadWrite.All`, `Group.ReadWrite.All` — tipo Application|
|Aplicar consentimento administrativo|Grant admin consent no tenant|
|Validar via Graph Explorer|`GET /users` e `GET /groups` — retorno HTTP 200 com dados dos 100 usuários|
|Documentar credenciais|`Client ID`, `Tenant ID`, `Client Secret` registrados como evidência|

**Evidência gerada:** Screenshot do Graph Explorer retornando os 100 usuários + registro do App Registration com permissões aprovadas.

---

## ATO 2 — midPoint → Entra ID (Dry Run e Reconciliação)

**Duração estimada:** 3–5 dias  
**Dependência:** ATO 1 concluído

|Tarefa|Detalhe|
|---|---|
|Instalar conector Microsoft Graph API no midPoint|Jar do `connector-microsoft-graph-api` no diretório de conectores|
|Criar Resource no midPoint|Tipo: Azure AD / Graph API — usar Client ID + Secret + Tenant ID do ATO 1|
|Importar schema|midPoint detecta atributos: `displayName`, `userPrincipalName`, `employeeId`, `department`, `jobTitle`, `accountEnabled`|
|Definir âncora (Correlation Rule)|`employeeId` no Entra ID ↔ `employeeID` no midPoint — evita duplicidade|
|Executar Dry Run (Simulation Mode)|Reconciliação em modo `dryRun: true` — nenhuma alteração é efetivada|
|Analisar relatório de reconciliação|Validar matching 1:1 dos 100 usuários — esperado: 100 LINKED, 0 UNMATCHED|
|Habilitar reconciliação real (Read)|Após Dry Run validado — importar os 100 usuários como shadows no midPoint|

**Evidência gerada:** Relatório de reconciliação do midPoint com 100 usuários linkados + log de auditoria da operação.

---

## ATO 3 — OrangeHRM → midPoint → JML + RBAC

**Duração estimada:** 3–5 dias  
**Dependência:** ATO 2 concluído

|Tarefa|Detalhe|
|---|---|
|Configurar conector DatabaseTable|JDBC → MariaDB `orange-db` (via Tailscale `xxx.xxx.xxx.xxx:3306`)|
|Mapear tabela de colaboradores|Atributos: `emp_number`, `first_name`, `last_name`, `department`, `job_title`, `salary`, `security_group`|
|Definir OrangeHRM como fonte autoritativa|Resource marcado como `authoritative source` no midPoint|
|Criar Object Type e Mapping|`emp_number` → `employeeID` (âncora end-to-end)|
|Implementar Joiner|Novo registro no OrangeHRM → midPoint cria/habilita conta no Entra ID|
|Implementar Mover|Mudança de `department` ou `job_title` → midPoint atualiza atributos + realocar grupos|
|Implementar Leaver|Status inativo no OrangeHRM → midPoint desabilita conta (`accountEnabled: false`) + revoga sessões via Graph API (`revokeSignInSessions`)|
|Implementar RBAC por Department|Role no midPoint: `department == "TI"` → membro do grupo `GRP-TI` no Entra ID (grupos estáticos — contorna ausência de licença P1)|

**Evidência gerada:** Demonstração end-to-end do ciclo JML com logs de auditoria do midPoint e evidência no Entra ID de cada operação.

---

## 7. Estratégia de Segurança

|Controle|Implementação|
|---|---|
|**Comunicação interna**|Todo tráfego midPoint ↔ MariaDB via Tailscale (rede mesh criptografada)|
|**Comunicação externa**|midPoint ↔ Entra ID via HTTPS/TLS 1.2+ com OAuth2 Client Credentials|
|**Armazenamento de secrets**|Client Secret armazenado no HashiCorp Vault (PRJ007, IP `xxx.xxx.xxx.xxx`)|
|**Princípio do menor privilégio**|App Registration com apenas as permissões necessárias (`User.ReadWrite.All`, `Group.ReadWrite.All`)|
|**Dry Run obrigatório**|Toda reconciliação nova executa em `dryRun: true` antes de qualquer escrita|
|**Auditoria**|Todos os eventos registrados no log de auditoria nativo do midPoint|

---

## 8. Riscos

|ID|Risco|Probabilidade|Impacto|Mitigação|
|---|---|---|---|---|
|R01|Client Secret expirado antes do fim do projeto|Baixa|Alto|Validade de 12 meses + alerta de expiração|
|R02|Dry Run identificar usuários não matchados|Média|Médio|Análise manual antes de habilitar escrita|
|R03|Schema do MariaDB incompatível com conector|Média|Médio|Testar query SQL antes de criar resource|
|R04|midPoint container instável durante testes|Baixa|Alto|Snapshot do container antes de cada fase|
|R05|Throttling da Graph API (limite de requisições)|Baixa|Baixo|Configurar retry policy no conector|

---

## 9. Cronograma Macro

|Fase|Ato|Início Previsto|Duração|Entrega|
|---|---|---|---|---|
|Fase 1|ATO 1 — App Registration|05/03/2026|1 dia|Conectividade Graph API validada|
|Fase 2|ATO 2 — midPoint → Entra ID|06/03/2026|3–5 dias|100 usuários reconciliados, Dry Run OK|
|Fase 3|ATO 3 — OrangeHRM → JML/RBAC|11/03/2026|3–5 dias|Ciclo JML funcional com evidências|
|**Encerramento**|Documentação final|16/03/2026|1 dia|REL-PRJ012 publicado|

---

## 10. Dependências

|Dependência|Projeto de Origem|Status|
|---|---|---|
|HashiCorp Vault operacional (armazenamento de secrets)|PRJ007|✅ Concluído|
|100 usuários provisionados no Entra ID|PRJ010/PRJ011|✅ Concluído|
|midPoint acessível via Tailscale|PRJ009|✅ Greenfield estável|
|OrangeHRM com 100 colaboradores|PRJ009/PRJ011|✅ Operacional|

---

## 11. Definição de Sucesso (DoD — Definition of Done)

-  App Registration criado com consentimento administrativo aplicado e teste Graph Explorer OK
    
-  midPoint conectado ao Entra ID com schema importado
    
-  Dry Run executado com relatório de 100 usuários LINKED e 0 erros
    
-  Conector OrangeHRM/MariaDB funcional com leitura de todos os atributos
    
-  Ciclo JML demonstrado: 1 Joiner, 1 Mover e 1 Leaver com evidência auditável
    
-  RBAC por Department funcional em pelo menos 2 grupos de segurança estáticos
    
-  REL-PRJ012 publicado no repositório com evidências técnicas
    

---

## 12. Aprovações

|Função|Nome|Data|Status|
|---|---|---|---|
|Responsável Técnico / Sponsor|Paulo Lima|04/03/2026|✅ APROVADO|
|GRC Advisor|Perplexity AI|04/03/2026|✅ REVISADO|

---

_— FIM DO DOCUMENTO TAP-PRJ012 v1.0 —_  
_Classificação: Interno — Lab Fiqueok_  
_Repositório: `FiqueokBrain/1.0 Projetos/PRJ012/10 Iniciação/TAP-PRJ012.md`_
