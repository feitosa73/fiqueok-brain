

## 1. Cabeçalho de Governança

| Campo                   | Valor                                                                     |
| ----------------------- | ------------------------------------------------------------------------- |
| **Nome do Documento**   | POP-PRJ004: Implementação de Fonte Autoritativa CSV                       |
| **Versão**              | 1.0                                                                       |
| **Autor**               | Paulo Feitosa - Fiqueok Living Lab                                        |
| **Data de Homologação** | 27/01/2026                                                                |
| **Status**              | Homologado                                                                |
| **Projeto**             | PRJ004 - IGA Data Lifecycle                                               |
| **Plataforma**          | midPoint 4.10 (Evolveum)                                                  |
| **Objetivo**            | Estabelecer ciclo de vida automatizado de identidades (JML) via fonte CSV |

---

## 2. Escopo e Contexto

### 2.1 Objetivo do Procedimento

Este POP documenta a configuração técnica de uma fonte autoritativa baseada em arquivo CSV no midPoint 4.10, estabelecendo o fluxo completo de Joiner (entrada), Mover (atualização) e Leaver (saída) para gerenciamento de identidades canônicas.

### 2.2 Pré-requisitos Técnicos

- midPoint 4.10 instalado e operacional
- Acesso administrativo à interface web
- Arquivo CSV estruturado no servidor (caminho: `/opt/midpoint/var/import/`)
- Permissões de leitura configuradas (UID 1000:1000, chmod 644)

### 2.3 Arquitetura da Solução

```
CSV (Fonte Autoritativa)
    ↓
Conector CSV v2.9
    ↓
Schema Handling (Mapeamento de Atributos)
    ↓
Correlation Engine (Busca por personalNumber)
    ↓
Synchronization Reactions (Unmatched/Unlinked/Linked)
    ↓
Repositório Canônico de Identidades (UserType)
```

---

## 3. Configuração do Resource (Fonte de Dados)

### 3.1 Criação do Recurso

**Caminho de Navegação:**

```
Resources → New resource → From Scratch → CsvConnector (v2.9)
```

**Etapa 1: Basic Information**

|Campo|Valor|Justificativa|
|---|---|---|
|Name|`CSV-Authoritative-Source-PRJ004`|Identificador único do recurso|
|Description|Fonte autoritativa de identidades para validação do PRJ004|Documentação de propósito|
|Lifecycle state|`Active (production)`|Habilita processamento de tarefas|

**Etapa 2: Configuration**

|Campo|Valor|Observação|
|---|---|---|
|File path|`/opt/midpoint/var/import/employees_prj004.csv`|Caminho interno do container Docker|
|Field delimiter|`,` (vírgula)|Separador padrão CSV|
|First line contains headers|`True`|Habilita mapeamento automático|

**Etapa 3: Discovery**

|Campo|Valor|Função|
|---|---|---|
|Name attribute|`name`|Identificador técnico (username)|
|Unique attribute|`personalNumber`|Âncora de correlação (ID de negócio)|

---

## 4. Schema Handling (Mapeamento de Atributos)

### 4.1 Estrutura do Object Type

**Caminho de Navegação:**

```
Resource → Schema handling → Add object type
```

**Configuração Base:**

|Campo|Valor|
|---|---|
|Display name|Colaboradores (Fonte Autoritativa)|
|Kind|`account`|
|Intent|`default`|
|Object class|`AccountObjectClass`|
|Focus type|`UserType`|
|Default|`True`|
|Lifecycle state|`Active (production)`|

### 4.2 Mapeamento de Atributos (Inbound)

A tabela abaixo define o mapeamento completo entre os campos do CSV e os atributos canônicos do midPoint:

|Nome do Mapeamento|Atributo CSV|Atributo midPoint|Strength|Authoritative|Observação|
|---|---|---|---|---|---|
|map_personalNumber|personalNumber|personalNumber|**Strong**|**True**|Âncora de Ouro para correlação|
|map_username|name|name|**Strong**|True|Identificador técnico (login)|
|map_lifecycleState|lifecycleState|lifecycleState|**Strong**|**True**|Controle de estado JML|
|map_fullName|fullName|fullName|Normal|False|Nome completo para exibição|
|map_givenName|givenName|givenName|Normal|False|Primeiro nome|
|map_familyName|familyName|familyName|Normal|False|Sobrenome|
|map_email|emailAddress|emailAddress|Normal|False|E-mail corporativo|
|map_telephone|telephoneNumber|telephoneNumber|Normal|False|Contato telefônico|
|map_title|title|title|Normal|False|Cargo para políticas RBAC|
|map_costCenter|costCenter|costCenter|Normal|False|Centro de custo para auditoria|
|map_organization|organization|organization|Normal|False|Empresa|
|map_orgUnit|organizationalUnit|organizationalUnit|Normal|False|Departamento (SoD)|
|map_locality|locality|locality|Normal|False|Localidade física|
|map_prefix|honorificPrefix|honorificPrefix|Normal|False|Prefixo formal|
|map_suffix|honorificSuffix|honorificSuffix|Normal|False|Sufixo de qualificação|
|map_nickname|nickName|nickName|Normal|False|Apelido ou nome social|

**Referência Visual - Lista de Mapeamentos:** ![Mapeamentos Configurados](https://claude.ai/chat/image_145ad3.png)

**Referência Visual - Configuração de Força (Strong):** ![Strength Configuration](https://claude.ai/chat/image_145a95.png)

### 4.3 Criticidade da Configuração "Strong"

**Definição Técnica:**

- **Strong:** O valor da fonte autoritativa **sempre prevalece** sobre alterações manuais no midPoint
- **Normal:** Permite que alterações manuais sejam mantidas até a próxima sincronização

**Campos Obrigatoriamente Strong:**

1. **personalNumber**: Garantir integridade do identificador de negócio
2. **lifecycleState**: Assegurar que o status de ativo/inativo seja controlado exclusivamente pela fonte RH
3. **name**: Evitar divergências de login entre sistemas

**Implicação de GRC:** Sem a configuração Strong nos campos críticos, o sistema perde a característica de "Single Source of Truth", permitindo que alterações ad-hoc corrompam a trilha de auditoria.

---

## 5. Correlation (Motor de Busca e Anti-Duplicidade)

### 5.1 Fundamento da Correlação

A correlação é o mecanismo que previne a criação de identidades duplicadas ao processar dados de fontes externas. Sem uma regra de correlação adequada, o midPoint criaria um novo usuário a cada execução da tarefa de importação, mesmo para colaboradores já existentes.

### 5.2 Configuração da Regra de Correlação

**Caminho de Navegação:**

```
Resource → Configuration → Correlation → Add rule
```

**Parâmetros da Regra:**

|Campo|Valor|Justificativa|
|---|---|---|
|Rule name|`cor_personalNumber`|Identificador da regra|
|Description|Correlação mandatória via personalNumber para evitar duplicidade|Documentação de propósito|
|Weight|`1`|Prioridade máxima|
|Tier|`1`|Primeira rodada de verificação|
|Enabled|`True`|Regra ativa|

**Referência Visual - Visão Geral da Regra:** ![Correlation Rule Overview](https://claude.ai/chat/image_14527a.png)

### 5.3 Configuração do Item de Correlação

**Dentro da regra `cor_personalNumber`, configure o item de busca:**

|Campo|Valor|Observação|
|---|---|---|
|Item|`personalNumber`|Atributo do usuário no midPoint|
|Search method|`Exact match`|Busca exata (não fuzzy)|
|Match threshold|(desabilitado)|Preenchimento automático com Exact match|
|Inclusive|(desabilitado)|Preenchimento automático com Exact match|

**Referência Visual - Detalhamento do Item:** ![Correlation Item Configuration](https://claude.ai/chat/image_144eb8.png)

### 5.4 Comportamento Esperado

Ao executar a tarefa de importação:

1. **Se personalNumber existe:** O sistema atualiza o usuário existente (Mover)
2. **Se personalNumber não existe:** O sistema cria um novo usuário (Joiner)
3. **Se personalNumber é nulo no CSV:** O sistema rejeita a linha com erro

---

## 6. Synchronization (Lógica de Reações do JML)

### 6.1 Conceito de Situações de Sincronização

O midPoint classifica cada objeto processado em uma "situação" baseada no resultado da correlação:

|Situação|Significado|Ação Padrão|
|---|---|---|
|**Unmatched**|O ID não existe no midPoint|Requer criação (Joiner)|
|**Unlinked**|O usuário existe mas não está vinculado ao recurso|Requer vínculo|
|**Linked**|O usuário existe e está vinculado|Requer atualização (Mover)|
|**Disputed**|Múltiplos usuários correspondem ao ID|Requer decisão manual|
|**Deleted**|O ID sumiu da fonte|Requer inativação (Leaver)|

### 6.2 Configuração das Reações

**Caminho de Navegação:**

```
Resource → Configuration → Synchronization → Add reaction
```

**Reação 1: Joiner (Criação de Novos Usuários)**

|Campo|Valor|Justificativa|
|---|---|---|
|Name|`Reaction - Joiner (Unmatched)`|Identificador da reação|
|Situation|`Unmatched`|ID ausente no IGA|
|Action|**`Add focus`**|Cria o usuário e o vínculo|
|Enabled|`True`|Reação ativa|

**⚠️ CRÍTICO:** A ação deve ser **`Add focus`** e não apenas `Link`. Se configurada como `Link`, o sistema reportará sucesso mas não criará os usuários, pois não há objeto existente para vincular.

**Reação 2: Reconciliação (Vínculo de Usuários Órfãos)**

|Campo|Valor|Justificativa|
|---|---|---|
|Name|`Reaction - Mover (Unlinked)`|Identificador da reação|
|Situation|`Unlinked`|Usuário existe mas sem vínculo|
|Action|`Link`|Cria o vínculo com o recurso|
|Enabled|`True`|Reação ativa|

**Reação 3: Mover (Atualização de Atributos)**

|Campo|Valor|Justificativa|
|---|---|---|
|Name|`Reaction - Mover (Linked)`|Identificador da reação|
|Situation|`Linked`|ID vinculado ao recurso|
|Action|**`Synchronize`**|Atualiza atributos alterados|
|Enabled|`True`|Reação ativa|

**Referência Visual - Reações Configuradas:** ![Synchronization Reactions](https://claude.ai/chat/image_13e2f2.png)

### 6.3 Diagnóstico de Falha Comum

**Sintoma:** A tarefa reporta "Success" mas os usuários não aparecem na lista.

**Causa Raiz:** Falta da reação `Unmatched → Add focus`.

**Prova Técnica:** O log de transição de estados mostra:

```
Original state: No record
Start: Unmatched
End: Unmatched
Result: Succeeded: 9
```

Isso indica que o sistema processou 9 linhas com sucesso, mas como não havia uma instrução de criação (`Add focus`), ele apenas "reconheceu" os dados sem persistir as identidades.

**Referência Visual - Log de Transição:** ![Synchronization Situation Transitions](https://claude.ai/chat/image_135e79.png)

---

## 7. Import Task (Execução e Orquestração)

### 7.1 Criação da Tarefa

**Caminho de Navegação:**

```
Server tasks → New task → Import task
```

### 7.2 Configuração Detalhada

**Aba: Basic (Propriedades da Tarefa)**

**Referência Visual - Basic Properties:** ![Task Basic Configuration](https://claude.ai/chat/image_13d337.png)

|Campo|Valor|Observação|
|---|---|---|
|Name|`Task - Import PRJ004 (CSV Authoritative)`|Identificador único|
|Description|Carga e sincronização de colaboradores para validação do PRJ004.|Contexto de auditoria|

**Aba: Activity > Work (Lógica de Origem)**

**Referência Visual - Activity Navigation:** ![Activity Tab](https://claude.ai/chat/image_13db3a.png)

**⚠️ IMPORTANTE:** A configuração do recurso **não está na aba Basic**, mas sim em **Activity → Work**. Este é um padrão do midPoint 4.10 que difere de versões anteriores.

**Referência Visual - Work Configuration:** ![Work Configuration](https://claude.ai/chat/image_1375f9.png)

**Bloco: Resource objects**

|Campo|Valor|Justificativa|
|---|---|---|
|Resource|`CSV-Authoritative-Source-PRJ004`|Fonte de dados|
|Kind|`Account`|Tipo de objeto a processar|
|Intent|`default`|Perfil de importação|
|Object class|`AccountObjectClass`|Classe descoberta no Schema|
|Query|`Undefined`|Importar todos os registros|

**Bloco: Search options**

|Campo|Valor|Observação|
|---|---|---|
|(todos os campos)|`Undefined`|Respeita a Correlation Rule configurada no recurso|

### 7.3 Execução da Tarefa

**Comando:** Clique no botão **"Save & Run"** no topo da tela.

**Monitoramento:** O sistema redireciona para a tela de status da tarefa.

**Indicadores de Sucesso:**

|Métrica|Valor Esperado|Significado|
|---|---|---|
|Expected total|10|Total de linhas no CSV|
|Processed|10|Linhas processadas|
|Successes|10|Operações bem-sucedidas|
|Failures|0|Nenhum erro|
|Status|`Closed/Success`|Tarefa concluída|

**Referência Visual - Task Status:** ![Task Execution Status](https://claude.ai/chat/image_13717d.png)

---

## 8. Validação e Auditoria

### 8.1 Verificação de Identidades Criadas

**Caminho de Navegação:**

```
Users → All users
```

**Validação Esperada:**

1. Total de usuários: **11** (10 do CSV + 1 administrator)
2. Cada usuário deve conter:
    - **personalNumber** preenchido (ex: 1001, 1002, etc.)
    - **title** preenchido (ex: "Especialista GRC Senior")
    - **lifecycleState** = "Active (production)"
    - **emailAddress** preenchido

**Referência Visual - Lista de Usuários:** ![User List](https://claude.ai/chat/image_1304a2.png)

### 8.2 Análise de Logs de Auditoria

**Caminho de Navegação:**

```
Audit → List audit logs
```

**Filtros Recomendados:**

- **Object type:** `UserType`
- **Event type:** `Add` (para validar Joiner)
- **Timestamp:** Últimos 30 minutos

**Evidências a Coletar:**

1. Log de criação de cada usuário com timestamp
2. Transição de estado: `No record → Unmatched → Linked`
3. Confirmação de vínculo com o recurso CSV

### 8.3 Checklist de Homologação

- [ ] Os 10 colaboradores aparecem na lista de usuários
- [ ] Nenhum usuário duplicado foi criado (validar por personalNumber)
- [ ] Todos os 16 atributos foram populados corretamente
- [ ] O log de auditoria registra 10 eventos de criação
- [ ] A tarefa pode ser executada novamente sem gerar duplicatas (validação da correlação)
- [ ] O arquivo CSV pode ser atualizado e a tarefa sincroniza as mudanças (validação do Mover)

---

## 9. Troubleshooting (Resolução de Problemas)

### 9.1 Problema: "Tarefa reporta sucesso mas usuários não aparecem"

**Sintoma:**

- Status da tarefa: `Success`
- Total processado: 10
- Lista de usuários: Apenas administrator e pfeitosa (usuário manual)

**Causa:**

- Falta da reação `Unmatched → Add focus` na configuração de Synchronization

**Solução:**

1. Acesse `Resource → Configuration → Synchronization`
2. Adicione a reação:
    - Situation: `Unmatched`
    - Action: `Add focus`
3. Execute a tarefa novamente

**Evidência de Sucesso:**

- O log de transição deve mostrar: `Start: Unmatched → End: Linked`

### 9.2 Problema: "Usuários duplicados após múltiplas execuções"

**Sintoma:**

- Usuários com sufixo numérico (ex: pfeitosa, pfeitosa_1, pfeitosa_2)

**Causa:**

- Regra de correlação ausente ou mal configurada
- Atributo de correlação incorreto (ex: usando `name` em vez de `personalNumber`)

**Solução:**

1. Verifique a regra `cor_personalNumber`:
    - Item deve ser `personalNumber`
    - Search method deve ser `Exact match`
2. Delete os usuários duplicados
3. Execute a tarefa novamente

### 9.3 Problema: "Erro de permissão ao ler o arquivo CSV"

**Sintoma:**

- Tarefa falha com erro: `Permission denied` ou `File not found`

**Causa:**

- Arquivo CSV não possui permissões de leitura para o usuário do midPoint (UID 1000)

**Solução (via terminal SSH):**

```bash
sudo chown 1000:1000 /srv/iga-<REDACTED_SECRET>es_prj004.csv
sudo chmod 644 /srv/iga-<REDACTED_SECRET>es_prj004.csv
```

**Validação:**

```bash
docker exec -it iga-midpoint cat /opt/midpoint/var/import/employees_prj004.csv
```

O conteúdo do CSV deve ser exibido no terminal.

---

## 10. Próximos Passos (Roadmap PRJ004)

### 10.1 Fase 2: Teste do Mover

**Objetivo:** Validar se alterações no CSV são sincronizadas automaticamente.

**Procedimento:**

1. Editar o arquivo CSV e alterar o campo `title` de um usuário
2. Executar a tarefa de importação
3. Verificar se o campo `title` foi atualizado no midPoint

**Evidência:** Log de auditoria deve registrar evento `Modify` no atributo `title`.

### 10.2 Fase 3: Teste do Leaver

**Objetivo:** Validar se usuários removidos do CSV são inativados.

**Procedimento:**

1. Alterar o campo `lifecycleState` de `active` para `archived` no CSV
2. Executar a tarefa de importação
3. Verificar se o usuário foi marcado como `Archived` no midPoint

**Evidência:** Usuário deve aparecer com status "Archived" e as marcas de ativação devem refletir a inativação.

### 10.3 Fase 4: Integração com OrangeHRM

**Objetivo:** Substituir o CSV por uma fonte autoritativa via API REST.

**Pré-requisito:** Sucesso nas fases 1, 2 e 3 com o CSV.

**Vantagem:** A lógica de Schema Handling, Correlation e Synchronization já estará validada e poderá ser reutilizada com o novo conector.

---

## 11. Anexos

### 11.1 Estrutura do Arquivo CSV (employees_prj004.csv)

```csv
name,fullName,givenName,familyName,nickName,honorificPrefix,honorificSuffix,title,emailAddress,telephoneNumber,personalNumber,costCenter,organization,organizationalUnit,locality,lifecycleState
pfeitosa,Paulo Feitosa de Lima,Paulo,Feitosa de Lima,Paulo GRC,Sr.,Lead Auditor,Especialista GRC Senior,paulo.feitosa@fiqueok.com.br,+55 11 99999-9999,1001,SEC-GRC-2026,Fiqueok Fintech,Cyber Security & GRC,São Paulo,active
```

### 11.2 Glossário Técnico

|Termo|Definição|
|---|---|
|**Âncora de Ouro**|Atributo imutável usado para correlação de identidades (ex: personalNumber)|
|**Focus**|Objeto de identidade no repositório do midPoint (UserType)|
|**Shadow**|Representação de uma conta em um sistema externo|
|**Inbound Mapping**|Fluxo de dados da fonte externa → midPoint|
|**Outbound Mapping**|Fluxo de dados do midPoint → sistema de destino|
|**Strength: Strong**|Valor da fonte sempre prevalece sobre alterações manuais|
|**JML**|Joiner, Mover, Leaver (ciclo de vida de identidades)|
|**SoD**|Segregation of Duties (segregação de funções)|

### 11.3 Referências Normativas

- **ISO/IEC 27001:2013** - Controle A.9.2 (Gerenciamento de acesso do usuário)
- **NIST CSF 2.0** - PR.AC-1 (Identities and credentials)
- **CIS Controls v8** - Control 5 (Account Management)
- **LGPD** - Art. 6º, inciso VI (Transparência e precisão de dados)

---

## 12. Controle de Alterações

|Versão|Data|Autor|Descrição|
|---|---|---|---|
|1.0|27/01/2026|Paulo Feitosa|Versão inicial homologada após validação no Living Lab|

---

## 13. Aprovação

|Papel|Nome|Assinatura|Data|
|---|---|---|---|
|**Autor**|Paulo Feitosa|_________________|27/01/2026|
|**Revisor Técnico**|(A definir)|_________________|_**/**_/____|
|**Aprovador Final**|(A definir)|_________________|_**/**_/____|

---

**Classificação de Segurança:** Interno - Uso Educacional  
**Distribuição:** Fiqueok Living Lab / GitHub / Obsidian  
**Próxima Revisão:** 27/04/2026
