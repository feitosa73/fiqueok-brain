# # Plano de Mudança

## 1. Metadados de Governança

- **ID:** GMUD-013 (Substitui a GMUD-010)
    
- **Versão:** 1.0
    
- **Data de Execução:** 26/12/2025
    
- **Responsável:** Paulo (Consultor Sênior IAM/IGA & Auditor ISO 27001)
    
- **Ambiente:** LAB Fiqueok (IGA-P-01 | Ubuntu 22.04 | midPoint 4.10)
    
- **Status:** 🟡 **EM EXECUÇÃO**
    

---

## 2. Análise de Causa Raiz (Anterior: GMUD-010)

Para garantir que a GMUD-013 seja bem-sucedida, documentamos por que a GMUD-010 foi interrompida:

1. **Indisponibilidade de Driver:** O motor Java do midPoint não possuía o conector MariaDB no classpath, impossibilitando a comunicação com a porta 3306.
    
2. **Inconsistência de Schema (XML):** A tentativa de importar o Resource via XML "estático" causou um _mismatch_ com o motor de persistência Sqale do midPoint 4.10, gerando erros de `Schema Violation`.
    
3. **Abordagem de Descoberta:** O sistema não conseguiu realizar o _Discovery_ dos atributos da tabela `hs_hr_employee` de forma autônoma.
    

---

## 3. Procedimento Técnico Detalhado (Passo a Passo)

### Fase I: Preparação do Ambiente (Sanitização)

- **Injeção do Driver:** Copiar o `mariadb-java-client-3.1.2.jar` para `/opt/midpoint/var/lib/` dentro do container.
    
- **Reinicialização da Stack:** Executar `docker compose restart` para garantir que a JVM carregue o novo binário e limpe o cache de tentativas falhas.
    

### Fase II: Configuração do Resource via GUI (Discovery)

Diferente da GMUD-010, utilizaremos a interface gráfica para permitir a introspecção dinâmica:

1. **Conectividade:** Configurar Host (`xxx.xxx.xxx.xxx`), Porta (`3306`) e Usuário (`orangehrm_ro`).
    
2. **Schema Discovery:** Clicar em **Test Connection** para que o midPoint mapeie automaticamente as colunas da tabela `hs_hr_employee`.
    
3. **Schema Handling:** * Definir o identificador único (`ICF Name`) como `employee_id`.
    
    - Mapear `emp_firstname` para `givenName` e `emp_lastname` para `familyName` (Strength: **Strong**).
        
    - Mapear `job_title` para a extensão de cargo do usuário.
        

### Fase III: Lógica de Sincronização e Importação

1. **Correlation Rule:** Configurar o midPoint para buscar usuários existentes pelo `personalNumber` antes de criar novos, evitando duplicidade.
    
2. **Task de Importação:** Criar uma tarefa de "Importação do Recurso OrangeHRM".
    

---

## 4. Plano de Testes e Critérios de Aceite (Evidências)

A mudança só será considerada **Sucesso** após a validação dos seguintes itens:

|**Teste**|**Critério de Sucesso**|**Evidência Esperada**|
|---|---|---|
|**Conectividade**|Test Connection Verde|Log: "Connection to resource successful"|
|**Integridade**|Existência da Rose Araujo|Usuário "Rose Araujo" listado em **Users**|
|**Integridade**|Existência do Daniel Ribeiro|Usuário "Daniel Ribeiro" listado em **Users**|
|**Atributos**|Cargo Corretamente Mapeado|Atributo `jobTitle` populado para ambos|

---

## 5. Plano de Rollback

Em caso de nova falha de Schema:

1. Remover o Resource `OrangeHRM` via interface.
    
2. Limpar a Task de importação.
    
3. Verificar logs do `midpoint-server` para identificar se há travas no banco Sqale.
    

---


