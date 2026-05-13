# 

## Metadados

**ID:** GMUD-010  
**Versão:** 1.0  
**Data:** 24/12/2025  
**Responsável:** Consultor Sênior IAM/IGA  
**Ambiente:** LAB Fiqueok (IGA-P-01, Ubuntu 22.04, Hyper-V)  
**Status:** Em Elaboração

## Objetivo

Configurar o Resource OrangeHRM no midPoint 4.10 como fonte autoritativa de identidades, utilizando o conector DatabaseTable para acessar a tabela `hs_hr_employee` no MariaDB (porta 3306). Isso habilita importação e sincronização de funcionários (Joiner/Mover/Leaver) alinhada à ARQ003, com mapeamentos inbound para usuários midPoint.[evolveum+1](https://docs.evolveum.com/connectors/resources/databasetable/)​

## Escopo

**Inclui:**

- Criação do Resource OrangeHRM com conector DatabaseTable.
    
- Definição de schema e inbound mappings para `hs_hr_employee`.
    
- Import inicial e configuração de job de reconciliação.
    
- Testes de conectividade e sincronização.
    

**Não inclui:**

- Provisionamento outbound (somente leitura como HR autoritativo).
    
- Integração com targets downstream (ex.: AD, Linux).
    
- Configuração de roles dinâmicas (apenas diretrizes).[evolveum](https://docs.evolveum.com/connectors/resources/databasetable/)​
    

## Pré-requisitos

- GMUD-008 concluída: midPoint 4.10 rodando em `http://xxx.xxx.xxx.xxx:8080/midpoint`.[evolveum](https://docs.evolveum.com/connectors/resources/databasetable/)​
    
- GMUD-009 concluída: OrangeHRM 5.8 acessível em `http://xxx.xxx.xxx.xxx:8081`, MariaDB em porta 3306 com usuário `orangehrm_ro` (senha: `FiqueokOrangeHRMRO2025StrongPass`, SELECT only).[evolveum](https://docs.evolveum.com/connectors/resources/databasetable/)​
    
- ARQ003: Redes segregadas (`midpoint_lab_net: 172.18.0.0/16`, `orangehrm_lab_net: 172.19.0.0/16`), host acessível `xxx.xxx.xxx.xxx:3306`.
    
- Acesso admin no midPoint (Admin → Configuration → Resources).
    
- JDBC Driver MariaDB/MySQL em classpath do midPoint (copiar `mariadb-java-client-*.jar` para `~/midpoint_lab/docker/midpoint-server/lib` e reiniciar stack).[evolveum](https://docs.evolveum.com/connectors/resources/databasetable/)​
    

## Procedimento

## 1. Teste de Conectividade

No host VM IGA-P-01:

text

`mysql -h xxx.xxx.xxx.xxx -P 3306 -u orangehrm_ro -p orangehrm -e "SELECT employee_id, emp_firstname, emp_lastname FROM hs_hr_employee LIMIT 5;"`

Verifique saída com dados de exemplo (ex.: usuário `paulo`).[evolveum](https://docs.evolveum.com/connectors/resources/databasetable/)​

## 2. Criação do Resource via XML

Baixe e importe o XML abaixo via **Repository Objects → Import** no midPoint (salve como `resource-orangehrm.xml`):

xml

`<resource xmlns="http://midpoint.evolveum.com/xml/ns/public/resource/resource-schema-3"           xmlns:c="http://midpoint.evolveum.com/xml/ns/public/common/common-3"          xmlns:icfc="http://midpoint.evolveum.com/xml/ns/public/connector/icf-1/connector-schema-3"          xmlns:icscdbtable="http://midpoint.evolveum.com/xml/ns/public/connector/icf-1/bundle/org.forgerock.openicf.connectors.databasetable-connector/org.identityconnectors.databasetable.DatabaseTableConnector"          xmlns:ri="http://midpoint.evolveum.com/xml/ns/public/resource/instance-3"          xmlns:q="http://prism.evolveum.com/xml/ns/public/query-3"          xmlns:t="http://prism.evolveum.com/xml/ns/public/types-3"          oid="f226d3f6-6c95-4c2e-9fdc-b29c5d4d4f5a"          version="1.0"          name="OrangeHRM HR Source">  <description>Fonte autoritativa HR OrangeHRM via DatabaseTable (somente leitura)</description>     <!-- Conector DatabaseTable -->  <connectorRef>    <filter>      <q:text>connectorType = 'org.identityconnectors.databasetable.DatabaseTableConnector'</q:text>    </filter>  </connectorRef>     <connectorConfiguration>    <icfc:configurationProperties>      <icscdbtable:host>xxx.xxx.xxx.xxx</icscdbtable:host>      <icscdbtable:port>3306</icscdbtable:port>      <icscdbtable:database>orangehrm</icscdbtable:database>      <icscdbtable:user>orangehrm_ro</icscdbtable:user>      <icscdbtable:password>        <clearValue>FiqueokOrangeHRMRO2025StrongPass</clearValue>      </icscdbtable:password>      <icscdbtable:table>hs_hr_employee</icscdbtable:table>      <icscdbtable:keyColumn>employee_id</icscdbtable:keyColumn>      <icscdbtable:jdbcDriver>org.mariadb.jdbc.Driver</icscdbtable:jdbcDriver>      <icscdbtable:jdbcUrlTemplate>jdbc:mariadb://%h:%p/%d?useSSL=false&amp;allowPublicKeyRetrieval=true</icscdbtable:jdbcUrlTemplate>      <icscdbtable:enableEmptyString>false</icscdbtable:enableEmptyString>      <icscdbtable:rethrowAllSQLExceptions>true</icscdbtable:rethrowAllSQLExceptions>      <icscdbtable:nativeTimestamps>false</icscdbtable:nativeTimestamps>      <icscdbtable:SQLStateExceptionHandling>true</icscdbtable:SQLStateExceptionHandling>    </icfc:configurationProperties>  </connectorConfiguration>     <!-- Schema Handling: Employee como AccountType (HR autoritativo) -->  <schemaHandling>    <objectType>      <objectClass>ri:employee</objectClass>      <accountType/>      <defaultObjectClass>true</defaultObjectClass>      <inbound>        <!-- Mapeamentos Inbound: HR → midPoint User -->        <mapping>          <strength>strong</strength>          <target>            <path>personalNumber</path>          </target>          <source>            <path>employee_id</path>          </source>        </mapping>        <mapping>          <strength>strong</strength>          <target>            <path>givenName</path>          </target>          <source>            <path>emp_firstname</path>          </source>        </mapping>        <mapping>          <strength>strong</strength>          <target>            <path>familyName</path>          </target>          <source>            <path>emp_lastname</path>          </source>        </mapping>        <mapping>          <target>            <path>extension/jobTitle</path>          </target>          <source>            <path>job_title</path>          </source>        </mapping>        <mapping>          <target>            <path>assignment/orgRef</path>          </target>          <source>            <path>department</path>            <expression>              <path>$department</path> <!-- Futuro: mapear para OU via lookup -->            </expression>          </source>        </mapping>        <mapping>          <target>            <path>activation/administrativeStatus</path>          </target>          <source>            <path>termination_date</path>            <expression>              <script>                <code>if (termination_date != null &amp;&amp; termination_date &lt; now()) { 'disabled' } else { 'enabled' }</code>              </script>            </expression>          </source>        </mapping>      </inbound>    </objectType>  </schemaHandling>     <!-- Capabilities: Somente LiveSync/Import, sem provisioning -->  <capabilities>    <configuredService>      <capability>        <type>LiveSynchronizationCapability</type>      </capability>    </configuredService>  </capabilities>     <!-- Projection: Somente import, sem enforcement -->  <projection>    <assignmentPolicyEnforcement>none</assignmentPolicyEnforcement>  </projection> </resource>`

Após import, clique **Test Connection** no Resource. Schema será gerado automaticamente.[evolveum](https://docs.evolveum.com/connectors/resources/databasetable/)​

## 3. Configuração de Correlation e Sync

No Resource → **Synchronization** tab:

- **Correlation**: `equal( personalNumber , employee_id )`.
    
- **Intent**: `employee` (ri:employee).[evolveum](https://docs.evolveum.com/connectors/resources/databasetable/)​
    

## 4. Criação de Job de Import

**Tasks → New Task → Import from Resource**:

- Resource: OrangeHRM HR Source.
    
- Object Type: Account (employee).
    
- Correlation: enabled.
    
- Execute **Run** para import inicial.[evolveum](https://docs.evolveum.<REDACTED_SECRET>hronization-tasks/)​
    

## Plano de Testes

1. **Conectividade**: Test Connection → verde.[evolveum](https://docs.evolveum.com/connectors/resources/databasetable/)​
    
2. **Schema**: Verifique atributos `employee_id`, `emp_firstname` etc. no Schema tab.
    
3. **Import**: Rode job → Verifique usuários criados em **Users** (ex.: paulo com givenName/familyName populados).
    
4. **Reconciliação**: Adicione/altere employee no OrangeHRM → Rode LiveSync → Confirme sync.
    
5. **Critérios**: 100% match por `personalNumber`; `termination_date` ativa/desativa corretamente.[evolveum](https://docs.evolveum.<REDACTED_SECRET>hronization-tasks/)​
    

|Teste|Critério|Evidência|
|---|---|---|
|Conexão|Sucesso sem erro|Log midPoint|
|Import|Usuários criados|Users list|
|Leaver|Status disabled|activation/administrativeStatus|

## Rollback

1. **Tasks → Delete** jobs de OrangeHRM.
    
2. **Users**: Search `reference:OrangeHRM` → Bulk Action → Delete.
    
3. **Resources → OrangeHRM → Delete**.
    
4. Reimport GMUD-009 se DB alterado (backup `mariadb_data/` antes).[evolveum](https://docs.evolveum.com/connectors/resources/databasetable/)​
    

## Riscos e Mitigação

- **Risco**: Falha JDBC (driver ausente). **Mitigação**: Copiar JAR, reiniciar stack.[evolveum](https://docs.evolveum.com/connectors/resources/databasetable/)​
    
- **Risco**: Leak senha. **Mitigação**: Usar `orangehrm_ro` ONLY-SELECT (least privilege, ISO 27001 A.9.2.3).[evolveum](https://docs.evolveum.com/connectors/resources/databasetable/)​
    
- **Risco**: Sync em loop. **Mitigação**: `assignmentPolicyEnforcement: none`; monitor logs.
    
- **Risco**: Performance DB. **Mitigação**: Index `hs_hr_employee(employee_id, termination_date)`; job diário.[evolveum](https://docs.evolveum.com/connectors/resources/databasetable/)​
    

## Referências

- ARQ003 – Arquitetura de Referência IGA Fiqueok.
    
- GMUD-008: Implantação midPoint.
    
- GMUD-009: Implantação OrangeHRM.
    
- midPoint Docs: DatabaseTable Connector.[evolveum](https://docs.evolveum.com/connectors/resources/databasetable/)​
    
- midPoint Docs: Resource Schema Handling.[evolveum](https://docs.evolveum.com/midpoint/reference/before-4.8/repository/generic/mariadb/)​
    
- ISO 27001: Gestão de Identidades (A.9.2); NIST 800-53: AC-2.
    

1. [https://docs.evolveum.com/connectors/resources/databasetable/](https://docs.evolveum.com/connectors/resources/databasetable/)
2. [https://docs.evolveum.com/midpoint/reference/before-4.8/repository/generic/mariadb/](https://docs.evolveum.com/midpoint/reference/before-4.8/repository/generic/mariadb/)
3. [https://docs.evolveum.<REDACTED_SECRET>hronization-tasks/](https://docs.evolveum.<REDACTED_SECRET>hronization-tasks/)
4. [https://docs.evolveum.com/connectors/connectors/org.identityconnectors.databasetable.DatabaseTableConnector/](https://docs.evolveum.com/connectors/connectors/org.identityconnectors.databasetable.DatabaseTableConnector/)
5. [https://docs.evolveum.com/midpoint/reference/support-4.9/repository/generic/mysql/](https://docs.evolveum.com/midpoint/reference/support-4.9/repository/generic/mysql/)
6. [https://estuary.dev/blog/mariadb-connectors/](https://estuary.dev/blog/mariadb-connectors/)
7. [https://docs.evolveum.<REDACTED_SECRET>resource-schema/](https://docs.evolveum.<REDACTED_SECRET>resource-schema/)
8. [https://docs.evolveum.com/book/02-midpoint-overview/](https://docs.evolveum.com/book/02-midpoint-overview/)
9. [https://docs.evolveum.com/midpoint/exercises/08-orgstruct-sync-magic/](https://docs.evolveum.com/midpoint/exercises/08-orgstruct-sync-magic/)
10. [https://github.<REDACTED_SECRET>elease/4.2/index.adoc](https://github.<REDACTED_SECRET>elease/4.2/index.adoc)
11. [https://docs.evolveum.<REDACTED_SECRET>resource-configuration/](https://docs.evolveum.<REDACTED_SECRET>resource-configuration/)
12. [https://docs.evolveum.<REDACTED_SECRET>s/mappings/range/custom/](https://docs.evolveum.<REDACTED_SECRET>s/mappings/range/custom/)
13. [https://docs.evolveum.com/midpoint/exercises/07-orgstruct-ldap-sync/](https://docs.evolveum.com/midpoint/exercises/07-orgstruct-ldap-sync/)
14. [https://docs.evolveum.com/midpoint/release/4.3/](https://docs.evolveum.com/midpoint/release/4.3/)
15. [https://lists.evolveum.com/pipermail/midpoint/2016-June/001961.html](https://lists.evolveum.com/pipermail/midpoint/2016-June/001961.html)
16. [https://docs.evolveum.<REDACTED_SECRET>resource-configuration/schema-handling/](https://docs.evolveum.<REDACTED_SECRET>resource-configuration/schema-handling/)
17. [https://docs.evolveum.<REDACTED_SECRET>ory-tests/orgsync/](https://docs.evolveum.<REDACTED_SECRET>ory-tests/orgsync/)
18. [https://docs.evolveum.<REDACTED_SECRET>/repository-database-support/](https://docs.evolveum.<REDACTED_SECRET>/repository-database-support/)
19. [https://docs.evolveum.com/midpoint/reference/before-4.8/repository/generic/configuration/](https://docs.evolveum.com/midpoint/reference/before-4.8/repository/generic/configuration/)
20. [https://docs.evolveum.<REDACTED_SECRET>s/mappings/](https://docs.evolveum.<REDACTED_SECRET>s/mappings/)
