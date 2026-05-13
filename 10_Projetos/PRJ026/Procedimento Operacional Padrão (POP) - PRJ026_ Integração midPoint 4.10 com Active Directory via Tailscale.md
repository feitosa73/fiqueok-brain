# Procedimento Operacional Padrão (POP) - PRJ026: Integração midPoint 4.10 com Active Directory via Tailscale

## 1. Introdução

Este Procedimento Operacional Padrão (POP) detalha as etapas para a execução do Projeto PRJ026, que visa estabelecer a integração bidirecional entre o midPoint 4.10 e o Active Directory (AD) utilizando o Tailscale como camada de rede segura. O objetivo principal é automatizar o provisionamento de usuários (Joiner/Mover/Leaver) e centralizar a governança de identidades, conforme especificado na Gestão de Mudanças (GMUD) GMUD-001-PRJ026–IntegraçãomidPoint4.10comActiveDirectory(ViaTailscale).md [1].

O documento aborda tanto um **Processo de Prova de Conceito (POC)** simplificado e prático para validação inicial, quanto as etapas para a **Implementação em Produção**.

## 2. Escopo

### 2.1. Incluído

*   **Fase 0:** Preparação (criação de checkpoints de segurança).
*   **Fase 0.5 (POC):** Pre-Flight POC com CSV para validação de mapeamentos e regras de derivação.
*   **Fase 1:** Verificação de conectividade entre midPoint e AD via Tailscale.
*   **Fase 2:** Configuração do Resource AD no midPoint.
*   **Fase 3:** Configuração de mapeamentos de atributos.
*   **Fase 4:** Configuração de Correlation Rule (`employeeID` como âncora).
*   **Fase 5:** Configuração de Synchronization Reactions (Joiner/Mover/Leaver).
*   **Fase 6:** Configuração de regras de derivação (UPN, sAMAccountName, email).
*   **Fase 7:** Validação com usuário de teste (Joiner).
*   **Configuração de Persona:** Inclusão da configuração de Persona para usuários do AD no midPoint.

### 2.2. Excluído

*   Configuração de LDAPS (636).
*   Integração direta OrangeHRM → midPoint.
*   Provisionamento para Entra ID.

## 3. Pre-Flight POC com CSV (Ambiente de POC)

**Objetivo:** Validar todos os mapeamentos e regras de derivação em um ambiente controlado (CSV) antes de conectar ao AD real. Este passo é **crítico** para garantir a correção lógica antes de impactar o ambiente de produção.

### 3.1. Preparação do CSV de Teste

Crie o arquivo `test_users.csv` no servidor `iga-gf-02` (midPoint) no caminho `/opt/midpoint/var/import/` com o seguinte conteúdo:

```csv
employeeID,givenName,familyName,department,title
TEST001,João,Silva,Tecnologia,Analista
TEST002,Maria,Santos,Recursos Humanos,Coordenadora
TEST003,José,Oliveira,Vendas,Assistente
TEST004,João,Silva,Tecnologia,Analista Sênior
```

### 3.2. Configuração do Resource CSV Temporário no midPoint

Importe o seguinte XML para criar um Resource CSV temporário no midPoint. Certifique-se de substituir `...csv-connector-oid...` pelo OID real do CsvConnector no seu ambiente midPoint (geralmente `00000000-0000-0000-0000-000000000003`).

```xml
<resource xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
          xmlns:ri="http://midpoint.evolveum.com/xml/ns/public/resource/instance-3">
    <name>CSV-POC-PRJ026</name>
    <connectorRef oid="00000000-0000-0000-0000-000000000003"/> <!-- OID do CsvConnector -->
    <connectorConfiguration>
        <filePath>/opt/midpoint/var/import/test_users.csv</filePath>
        <keyColumn>employeeID</keyColumn>
        <fieldDelimiter>,</fieldDelimiter>
    </connectorConfiguration>
    <schemaHandling>
        <objectType>
            <kind>account</kind>
            <intent>test</intent>
            <attribute>
                <ref>ri:employeeID</ref>
                <inbound>
                    <strength>strong</strength>
                    <target>
                        <path>personalNumber</path>
                    </target>
                </inbound>
            </attribute>
            <!-- Demais atributos conforme seção 4.4 da GMUD -->
        </objectType>
    </schemaHandling>
</resource>
```

### 3.3. Validações da POC

Execute a importação do Resource CSV e valide os seguintes critérios:

| # | Validação | Critério de Sucesso |
|---|-----------|---------------------|
| 1 | Importação dos 4 usuários | ✅ 4 shadows criados no midPoint |
| 2 | Correlação por `employeeID` | ✅ Shadows LINKED corretamente aos usuários (Focus) |
| 3 | Derivação de UPN | `joao.silva@fiqueok.com.br`, `maria.santos@fiqueok.com.br`, etc. |
| 4 | Derivação de `sAMAccountName` | `joao.silva`, `maria.santos`, `jose.oliveira`, etc. |
| 5 | Derivação de `displayName` | `João Silva`, `Maria Santos`, `José Oliveira`, etc. |
| 6 | Colisão de nomes (`TEST004` com "João Silva") | Gera `joao.silva2@fiqueok.com.br` (resolução N+1) |
| 7 | Mudança de nome (simulada) | UPN renomeado, alias preservado |
| 8 | Leaver (simulado) | Usuário desabilitado no midPoint |

**Critério de Saída da POC:** A POC é considerada **SUCESSO** se todos os critérios acima forem atendidos. Caso contrário, diagnosticar e corrigir os mapeamentos e regras **ANTES** de prosseguir para a integração com o Active Directory.

## 4. Implementação em Produção (Integração Active Directory)

### 4.1. Fase 0 - Preparação

Crie checkpoints de segurança nas VMs do midPoint (`iga-gf-02`) e do Active Directory (`ID-P-01`) antes de iniciar a GMUD. Isso permite um rollback rápido em caso de problemas.

```powershell
# No Hyper-V host (PowerShell como Administrador)
Checkpoint-VM -VMName "iga-gf-02" -SnapshotName "PRE-GMUD-001-PRJ026-v3-$(Get-Date -Format 'yyyyMMdd-HHmm')"
Checkpoint-VM -VMName "ID-P-01" -SnapshotName "PRE-GMUD-001-PRJ026-v3-$(Get-Date -Format 'yyyyMMdd-HHmm')"
```

### 4.2. Fase 1 - Verificar Conectividade midPoint ↔ AD via Tailscale

No servidor `iga-gf-02` (midPoint), verifique a conectividade com o Active Directory (`ID-P-01`) via Tailscale. O IP do AD via Tailscale é `xxx.xxx.xxx.xxx` e a porta LDAP é `389`.

```bash
# No iga-gf-02 (via SSH)
ping xxx.xxx.xxx.xxx
nc -zv xxx.xxx.xxx.xxx 389
```

**Resultado Esperado:** `ping` com 0% de perda de pacotes e `nc` indicando conexão bem-sucedida na porta 389.

### 4.3. Fase 2 - Configurar Resource AD no midPoint

Crie ou atualize o Resource para o Active Directory no midPoint. Utilize o `AdLdapConnector`.

**Via GUI:**
1.  Acesse `Configuration` → `Resources` → `New Resource`.
2.  Selecione `AdLdapConnector`.
3.  Preencha os detalhes de conexão:
    *   **Host:** `xxx.xxx.xxx.xxx` (IP Tailscale do AD)
    *   **Port:** `389`
    *   **Principal:** `CN=paulo.feitosa,OU=00_Admins,OU=Fiqueok_Corp,DC=corp,DC=fiqueok,DC=com,DC=br` (ou usuário de serviço apropriado)
    *   **Credentials:** Senha do usuário `paulo.feitosa`.
4.  Clique em `Test Connection`. Deve retornar `5/5 Success`.
5.  Salve o Resource.

**Via XML (Exemplo base):**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<resource xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
          xmlns:c="http://midpoint.evolveum.com/xml/ns/public/connector/icf-1/connector-schema-3"
          xmlns:ri="http://midpoint.evolveum.com/xml/ns/public/resource/instance-3">

    <name>Active Directory (Tailscale)</name>
    <description>Integração com Active Directory via Tailscale - ADR-008</description>
    <lifecycleState>active</lifecycleState>

    <connectorRef oid="20f08b13-5ba3-414b-bfb9-0842e290c7e1"/> <!-- OID do AdLdapConnector -->

    <connectorConfiguration>
        <configuration>
            <c:host>xxx.xxx.xxx.xxx</c:host>
            <c:port>389</c:port>
            <c:connectionSecurity>none</c:connectionSecurity>
            <c:authenticationType>simple</c:authenticationType>
            <c:principal>CN=paulo.feitosa,OU=00_Admins,OU=Fiqueok_Corp,DC=corp,DC=fiqueok,DC=com,DC=br</c:principal>
            <c:credentials>
                <c:password>[SENHA_DO_PAULO]</c:password>
            </c:credentials>
            <c:baseContexts>
                <c:baseContext>DC=corp,DC=fiqueok,DC=com,DC=br</c:baseContext>
            </c:baseContexts>
            <c:accountBaseContext>OU=04_People,OU=Fiqueok_Corp,DC=corp,DC=fiqueok,DC=com,DC=br</c:accountBaseContext>
            <c:groupBaseContext>OU=02_Security_Groups,OU=Fiqueok_Corp,DC=corp,DC=fiqueok,DC=com,DC=br</c:groupBaseContext>
            <c:accountSynchronization>
                <c:enabled>true</c:enabled>
            </c:accountSynchronization>
        </configuration>
    </connectorConfiguration>

    <!-- Schema Handling será configurado nas próximas fases -->
</resource>
```

**Critério de Saída:** `Test Connection` bem-sucedido (5/5 SUCCESS).

### 4.4. Fase 3 - Configurar Mapeamentos de Atributos

Configure os mapeamentos de atributos no `Schema Handling` do Resource AD. Os mapeamentos devem seguir as decisões arquiteturais (ADR-008) e garantir a bidirecionalidade quando necessário. Exemplos de mapeamentos essenciais:

| midPoint (User) | Active Directory (Account) | Direção | Observações |
|-----------------|----------------------------|---------|-------------|
| `givenName`     | `givenName`                | Bidirecional | Nome do usuário |
| `familyName`    | `sn`                       | Bidirecional | Sobrenome do usuário |
| `fullName`      | `displayName`              | Outbound | Derivado de `givenName` e `familyName` |
| `personalNumber`| `employeeID`               | Bidirecional | Âncora de correlação (ImmutableId) |
| `emailAddress`  | `mail`                     | Outbound | Derivado (Mail-as-UPN) |
| `telephoneNumber`| `telephoneNumber`          | Bidirecional | Telefone de contato |
| `organizationalUnit`| `ou`                     | Outbound | Unidade Organizacional |
| `description`   | `description`              | Bidirecional | Descrição do usuário |
| `enabled`       | `userAccountControl`       | Bidirecional | Status da conta (habilitado/desabilitado) |

### 4.5. Fase 4 - Configurar Regras de Derivação

Configure as regras de derivação para atributos como UPN, `sAMAccountName` e `emailAddress` no `Object Template` do Resource AD ou no `User Template` global, conforme ADR-008. Estas regras garantem a padronização e a resolução de colisões (N+1).

**Exemplos de Regras de Derivação:**

*   **UPN (User Principal Name):** `givenName.familyName@fiqueok.com.br` com resolução de colisão (e.g., `joao.silva2@fiqueok.com.br`).
*   **sAMAccountName:** `givenName.familyName` com resolução de colisão.
*   **emailAddress:** `givenName.familyName@fiqueok.com.br`.

### 4.6. Fase 5 - Configurar Correlation Rule

Defina a regra de correlação para vincular as contas do AD aos usuários (Focus) no midPoint. Utilize o `employeeID` como âncora de correlação, garantindo que seja um atributo único e imutável.

```xml
<!-- No Resource AD, dentro de <schemaHandling> -->
<correlation>
    <correlationRule>
        <name>Correlate by employeeID</name>
        <description>Correlates accounts based on employeeID attribute.</description>
        <item>
            <ref>ri:employeeID</ref>
            <source>
                <path>personalNumber</path>
            </source>
            <target>
                <path>personalNumber</path>
            </target>
        </item>
    </correlationRule>
</correlation>
```

### 4.7. Fase 6 - Configurar Synchronization Reactions

Configure as reações de sincronização no Resource AD para lidar com os cenários de Joiner, Mover e Leaver.

```xml
<!-- No Resource AD, dentro de <synchronization> -->
<synchronization>
    <!-- Joiner - Criar usuário -->
    <reaction>
        <name>Joiner - Criar Usuario</name>
        <situation>unmatched</situation>
        <action>
            <type>addFocus</type>
        </action>
    </reaction>

    <!-- Mover - Atualizar usuário -->
    <reaction>
        <name>Mover - Atualizar Usuario</name>
        <situation>linked</situation>
        <action>
            <type>synchronize</type>
        </action>
    </reaction>

    <!-- Leaver - Desabilitar usuário -->
    <reaction>
        <name>Leaver - Desabilitar Usuario</name>
        <situation>deleted</situation>
        <action>
            <type>disable</type>
        </action>
    </reaction>

    <!-- UNLINKED (emergência) - Link manual -->
    <reaction>
        <name>UNLINKED - Link manual</name>
        <situation>unlinked</situation>
        <action>
            <type>link</type>
        </action>
    </reaction>
</synchronization>
```

### 4.8. Configuração de Persona (midPoint)

A Persona no midPoint permite definir diferentes visões e comportamentos para os usuários com base em seus papéis ou características. Para a integração com o Active Directory, podemos criar uma Persona padrão para usuários provisionados do AD, garantindo que eles tenham as permissões e configurações adequadas no midPoint.

**Exemplo de Configuração de Persona para Usuários do AD:**

1.  **Crie um Role (Papel) específico para usuários do AD:**
    *   Navegue para `Roles` → `New Role`.
    *   **Name:** `AD User`
    *   **Description:** `Role para usuários sincronizados do Active Directory.`
    *   Configure as permissões e atribuições padrão que todos os usuários do AD devem ter no midPoint (e.g., acesso a determinados dashboards, permissão para visualizar seus próprios dados).

2.  **Atribua este Role automaticamente aos usuários do AD:**
    *   No `User Template` global ou em um `Object Template` específico para usuários do AD, adicione uma regra de atribuição automática para o Role `AD User`.
    *   Isso pode ser feito através de uma inbound mapping no `User Template` que atribui o Role se o usuário for provisionado de um Resource AD.

    ```xml
    <!-- Exemplo de atribuição de Role no User Template -->
    <objectTemplate xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3">
        <name>Default User Template</name>
        <mapping>
            <name>Assign AD User Role</name>
            <strength>strong</strength>
            <source>
                <path>assignment</path>
                <condition>
                    <expression>
                        <script>
                            <code>
                                return input.accountMembership.any { it.resourceRef.oid == 'OID_DO_RESOURCE_AD' };
                            </code>
                        </script>
                    </expression>
                </condition>
            </source>
            <target>
                <path>assignment</path>
            </target>
            <expression>
                <value>
                    <targetRef type="RoleType" oid="OID_DO_ROLE_AD_USER"/>
                </value>
            </expression>
        </mapping>
    </objectTemplate>
    ```
    *   Substitua `OID_DO_RESOURCE_AD` pelo OID do seu Resource Active Directory e `OID_DO_ROLE_AD_USER` pelo OID do Role `AD User` que você criou.

3.  **Configure a Persona (Opcional, mas recomendado para personalização da UI):**
    *   Navegue para `Configuration` → `System Configuration` → `Personas`.
    *   Crie uma nova Persona (e.g., `AD User Persona`).
    *   Associe esta Persona ao Role `AD User` ou a uma condição que identifique usuários do AD.
    *   Personalize a interface do usuário (dashboards, menus, etc.) para esta Persona, se necessário.

### 4.9. Fase 7 - Validação com Usuário de Teste

Após a configuração completa, realize a validação com um usuário de teste para garantir que o provisionamento e a sincronização estão funcionando conforme o esperado.

1.  **Crie um novo usuário de teste no sistema de origem (e.g., OrangeHRM ou diretamente no midPoint se for o caso de um Joiner inicial):**
    *   Exemplo: `employeeID: TEST005, givenName: Ana, familyName: Paula, department: Marketing, title: Analista`

2.  **Execute a Reconciliação no midPoint:**
    *   Navegue para `Tasks` → `New Task`.
    *   Tipo: `Reconciliation`.
    *   Resource: `Active Directory (Tailscale)`.
    *   Execute: `Run now`.

3.  **Valide no Active Directory:**
    *   Verifique se o usuário `Ana Paula` foi criado no AD com os atributos corretos (`UPN: ana.paula@fiqueok.com.br`, `sAMAccountName: ana.paula`, `displayName: Ana Paula`, `employeeID: TEST005`).

    ```powershell
    # No console do AD
    Get-ADUser -Filter "EmployeeID -eq 'TEST005'" -Properties *
    ```

4.  **Valide no midPoint:**
    *   Verifique se o usuário (Focus) `Ana Paula` foi criado no midPoint e se o `Role AD User` foi atribuído corretamente.

    ```bash
    # No iga-gf-02
    curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
      "http://172.23.201.182:8080/midpoint/ws/rest/users?search=personalNumber=TEST005" \
      | jq '.users[0] | {name: .name, fullName: .fullName, emailAddress: .emailAddress, assignments: .assignment}'
    ```

## 5. Plano de Rollback

Em caso de falha crítica ou comportamento inesperado, siga o plano de rollback:

### 5.1. Critério de Ativação

Ativar o rollback se:
*   `Test Connection` falhar após 3 tentativas.
*   POC CSV falhar (mapeamentos incorretos).
*   `Import Task` retornar erro.
*   midPoint não criar shadows ou usuários (Focus).
*   Tempo de execução exceder 3 horas sem progresso.

### 5.2. Procedimento de Rollback

**Opção A - Restaurar Snapshots (Recomendado para falhas críticas):**

```powershell
# No Hyper-V host (PowerShell como Administrador)
Stop-VM -Name "iga-gf-02" -Force
Stop-VM -Name "ID-P-01" -Force
Restore-VMSnapshot -Name "PRE-GMUD-001-PRJ026-v3-*" -VMName "iga-gf-02" -Confirm:$false
Restore-VMSnapshot -Name "PRE-GMUD-001-PRJ026-v3-*" -VMName "ID-P-01" -Confirm:$false
Start-VM -Name "iga-gf-02"
Start-VM -Name "ID-P-01"
```

**Opção B - Remover Resource AD no midPoint (Para falhas menos críticas):**

*   Acesse a GUI do midPoint: `Configuration` → `Resources`.
*   Selecione o Resource `Active Directory (Tailscale)` e clique em `Delete`.

**Tempo estimado de rollback:** < 5 minutos.

## 6. Riscos e Mitigações

| ID | Risco | Probabilidade | Impacto | Mitigação |
|----|-------|--------------|---------|-----------|
| R01 | POC CSV falha | Baixa | Médio | Diagnosticar e corrigir mapeamentos antes de conectar ao AD real. |
| R02 | Colisão de nomes não resolvida | Baixa | Médio | Implementar regras de derivação com resolução N+1 (e.g., `joao.silva2`). |
| R03 | IP Tailscale do AD mudar | Muito Baixa | Médio | Tailscale oferece IPs fixos por dispositivo. Monitorar status do Tailscale. |
| R04 | ACLs do Tailscale bloqueiam acesso | Baixa | Alto | Verificar e validar as ACLs do Tailscale (`tag:midpoint → tag:ad:389`) antes da execução. |
| R05 | `employeeID` não único no sistema de origem | Baixa | Alto | Validar a unicidade do `employeeID` com o RH antes do provisionamento. |

## 7. Referências

[1] GMUD-001-PRJ026–IntegraçãomidPoint4.10comActiveDirectory(ViaTailscale).md

**Autor:** Manus AI
**Data:** 12 de Maio de 2026

