
Gestão de Mudanças - Projeto PRJ026 (Integração midPoint ↔ Active Directory)**

**Living Lab Fiqueok - GRC/IAM Open-Source Platform**

---

## Informações Básicas da GMUD

| Campo | Valor |
|-------|-------|
| **ID da GMUD** | GMUD-001-PRJ026 |
| **Título** | Integração midPoint 4.10 com Active Directory via Tailscale |
| **Tipo** | Mudança Configuracional / IGA |
| **Versão Documento** | 3.0 |
| **Data de Criação** | 10/05/2026 |
| **Data de Atualização** | 10/05/2026 |
| **Responsável Execução** | Paulo Feitosa Lima |
| **Projeto** | PRJ026 - Integração midPoint 4.10 com Active Directory |
| **Severidade** | MÉDIA |
| **Prioridade** | ALTA |
| **Status** | 📝 PLANEJADA - PRONTA PARA EXECUÇÃO |
| **Pré-requisito** | ✅ PRJ028 CONCLUÍDO (Tailscale no AD, firewall configurado) |
| **Referências** | ADR-007, ADR-008, GMUD-001/002-PRJ028, TAP-PRJ028 |

---

## 1. Contexto e Problema

### 1.1. Objetivo do PRJ026

Estabelecer integração bidirecional entre o **midPoint 4.10** e o **Active Directory** via Tailscale, permitindo provisionamento automático de usuários (Joiner/Mover/Leaver) e governança centralizada de identidades.

### 1.2. Decisões Arquiteturais (ADR-008)

| Decisão | Valor |
|---------|-------|
| **Âncora de correlação (ImmutableId)** | `employeeID` |
| **Formato do UPN** | `nome.sobrenome@fiqueok.com.br` (Mail-as-UPN) |
| **Origem do e-mail** | IGA gera (RH fornece nome/sobrenome) |
| **Política de colisão** | Resolução automática (N+1) com fallback seguro |

### 1.3. Estado Atual da Infraestrutura (Pré-GMUD)

| Componente | IP | Status |
|------------|-----|--------|
| **AD (ID-P-01)** | `xxx.xxx.xxx.xxx` (Tailscale) | ✅ Operacional, seguro |
| **midPoint (iga-gf-02)** | `xxx.xxx.xxx.xxx` (Tailscale) | ✅ Operacional |
| **Rede de comunicação** | Tailscale overlay | ✅ Criptografada (WireGuard) |
| **Firewall AD** | `BlockInbound, AllowOutbound` | ✅ Configurado |
| **ACLs Tailscale** | `tag:midpoint → tag:ad:389` | ✅ Configurado |

---

## 2. Escopo da Mudança

### 2.1. Incluído na GMUD

| Fase | Descrição | Prioridade |
|------|-----------|------------|
| **Fase 0** | Preparação (checkpoints, validação pré-voo) | 🔴 Crítica |
| **Fase 0.5** | **Pre-Flight POC com CSV** (validação de mapeamentos) | 🔴 **NOVO** |
| **Fase 1** | Verificar conectividade midPoint ↔ AD via Tailscale | 🔴 Crítica |
| **Fase 2** | Configurar Resource AD no midPoint | 🔴 Crítica |
| **Fase 3** | Configurar mapeamentos de atributos (conforme ADR-008) | 🔴 Crítica |
| **Fase 4** | Configurar Correlation Rule (employeeID como âncora) | 🔴 Crítica |
| **Fase 5** | Configurar Synchronization Reactions (Joiner/Mover/Leaver) | 🔴 Crítica |
| **Fase 6** | Configurar regras de derivação (UPN, sAMAccountName, email) | 🔴 Crítica |
| **Fase 7** | Validação com usuário de teste (Joiner) | 🔴 Crítica |
| **Fase 8** | Documentação | 🟢 Desejável |

### 2.2. Excluído da GMUD

| Item | Justificativa |
|------|---------------|
| ❌ Configuração de LDAPS (636) | Será GMUD futura (PKI/Vault) |
| ❌ Integração direta OrangeHRM → midPoint | PRJ008 (FROZEN); será retomada após esta GMUD |
| ❌ Provisionamento para Entra ID | Escopo futuro |

---

## 3. Pre-Flight POC com CSV (Validação de Mapeamentos)

**Objetivo:** Validar todos os mapeamentos e regras de derivação em um ambiente controlado (CSV) antes de conectar ao AD real.

**Por que CSV?** O conector CSV é simples, rápido e permite debug visual dos dados. Se funcionar no CSV, funcionará no AD (mesma lógica de mapeamento).

### 3.1. Preparação do CSV de Teste

```csv
employeeID,givenName,familyName,department,title
TEST001,João,Silva,Tecnologia,Analista
TEST002,Maria,Santos,Recursos Humanos,Coordenadora
TEST003,José,Oliveira,Vendas,Assistente
```

**Localização no midPoint:** `/opt/midpoint/var/import/test_users.csv`

### 3.2. Configuração do Resource CSV (Temporário)

```xml
<resource>
    <name>CSV-POC-PRJ026</name>
    <connectorRef oid="...csv-connector-oid..."/>
    <connectorConfiguration>
        <filePath>/opt/midpoint/var/import/test_users.csv</filePath>
        <keyColumn>employeeID</keyColumn>
        <fieldDelimiter>,</fieldDelimiter>
    </connectorConfiguration>
</resource>
```

### 3.3. Validações da POC

| # | Validação | Critério de Sucesso |
|---|-----------|---------------------|
| 1 | Importação dos 3 usuários | ✅ 3 shadows criados |
| 2 | Correlação por employeeID | ✅ Shadows LINKED corretamente |
| 3 | Derivação de UPN | `joao.silva@fiqueok.com.br`, `maria.santos@...` |
| 4 | Derivação de sAMAccountName | `joao.silva`, `maria.santos`, `jose.oliveira` |
| 5 | Derivação de displayName | `João Silva`, `Maria Santos`, `José Oliveira` |
| 6 | Colisão de nomes (TEST004 com "João Silva" novamente) | Gera `joao.silva2@...` |
| 7 | Mudança de nome | UPN renomeado, alias preservado |
| 8 | Leaver | Usuário desabilitado |

### 3.4. Critério de Saída da POC

**✅ A POC é considerada SUCESSO se:**

- Todos os 3 usuários são materializados como Users no midPoint
- UPN, sAMAccountName, displayName, emailAddress gerados conforme regras
- Colisão de nomes resolvida automaticamente
- Mudança de nome preserva alias

**❌ Se falhar:** Diagnosticar e corrigir mapeamentos ANTES de prosseguir para o AD.

---

## 4. Plano de Execução

### 4.1. Fase 0 - Preparação (5 min)

```powershell
# No Hyper-V host (PowerShell como Administrador)

# Criar checkpoint de segurança
Checkpoint-VM -VMName "iga-gf-02" -SnapshotName "PRE-GMUD-001-PRJ026-v3-$(Get-Date -Format 'yyyyMMdd-HHmm')"
Checkpoint-VM -VMName "ID-P-01" -SnapshotName "PRE-GMUD-001-PRJ026-v3-$(Get-Date -Format 'yyyyMMdd-HHmm')"
```

**Critério de saída:** ✅ Snapshots criados.

---

### 4.2. Fase 0.5 - Pre-Flight POC com CSV (20 min)

#### 4.2.1. Criar arquivo CSV de teste no midPoint

```bash
# No iga-gf-02 (via SSH)
cat > /opt/midpoint/var/import/test_users.csv << 'EOF'
employeeID,givenName,familyName,department,title
TEST001,João,Silva,Tecnologia,Analista
TEST002,Maria,Santos,Recursos Humanos,Coordenadora
TEST003,José,Oliveira,Vendas,Assistente
TEST004,João,Silva,Tecnologia,Analista Sênior
EOF
```

#### 4.2.2. Criar Resource CSV Temporário no midPoint

```xml
<!-- Resource CSV para POC -->
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
            <!-- Demais atributos conforme seção 4.4 -->
        </objectType>
    </schemaHandling>
</resource>
```

#### 4.2.3. Validar POC

```bash
# No iga-gf-02
# Executar importação
curl -X POST -u administrator:'M1dP0!ntAdm!n#2026' \
  -H "Content-Type: application/xml" \
  "http://172.23.201.182:8080/midpoint/ws/rest/tasks" \
  -d '<task><name>POC-Import-CSV</name><resourceRef oid="CSV-POC-OID"/><activity><work><import/></work></activity></task>'

# Verificar usuários criados
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://172.23.201.182:8080/midpoint/ws/rest/users?search=personalNumber=TEST001" \
  | jq '.users[0] | {name: .name, fullName: .fullName, personalNumber: .personalNumber}'
```

**Critério de saída:** ✅ POC validada com sucesso.

---

### 4.3. Fase 1 - Verificar Conectividade (5 min)

```bash
# No iga-gf-02 (via SSH)
ping xxx.xxx.xxx.xxx
nc -zv xxx.xxx.xxx.xxx 389
```

**Resultado esperado:** ✅ Ping OK, porta 389 acessível.

---

### 4.4. Fase 2 - Configurar Resource AD no midPoint (15 min)

#### 4.4.1. XML do Resource AD (Base)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<resource xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
          xmlns:c="http://midpoint.evolveum.com/xml/ns/public/connector/icf-1/connector-schema-3"
          xmlns:ri="http://midpoint.evolveum.com/xml/ns/public/resource/instance-3">

    <name>Active Directory (Tailscale)</name>
    <description>Integração com Active Directory via Tailscale - ADR-008</description>
    <lifecycleState>active</lifecycleState>

    <connectorRef oid="20f08b13-5ba3-414b-bfb9-0842e290c7e1"/>

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

    <!-- Schema Handling conforme seção 4.5 -->
</resource>
```

#### 4.4.2. Aplicar via GUI (Alternativa)

```
1. Configuration → Resources → New Resource
2. Selecionar AdLdapConnector
3. Preencher:
   - Host: xxx.xxx.xxx.xxx
   - Port: 389
   - Principal: CN=paulo.feitosa,OU=00_Admins,OU=Fiqueok_Corp,DC=corp,DC=fiqueok,DC=com,DC=br
4. Test Connection → Deve retornar 5/5 Success
5. Save
```

**Critério de saída:** ✅ Test Connection OK (5/5 SUCCESS).

---

### 4.5. Fase 3 - Configurar Mapeamentos de Atributos (15 min)

Segundo **ADR-008**, a tabela de autoridade é:

| Atributo AD | Origem | Direção | Regra |
|-------------|--------|---------|-------|
| `employeeID` | RH | IGA → AD | Âncora de correlação |
| `givenName` | RH | IGA → AD | Direto |
| `sn` | RH | IGA → AD | Direto |
| `userPrincipalName` | IGA (derivado) | IGA → AD | `nome.sobrenome@fiqueok.com.br` |
| `sAMAccountName` | IGA (derivado) | IGA → AD | Parte antes do `@` do UPN |
| `mail` | IGA (derivado) | IGA → AD | Mesmo valor do UPN |
| `displayName` | IGA (derivado) | IGA → AD | `givenName + " " + sn` |
| `department` | RH | IGA → AD | Direto |
| `title` | RH | IGA → AD | Direto |

---

### 4.6. Fase 4 - Configurar Regras de Derivação (Object Template) (20 min)

```xml
<objectTemplate xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
                oid="00000000-0000-0000-0000-000000000222">

    <name>User Object Template - ADR-008</name>

    <!-- <REDACTED_SECRET>==================== -->
    <!-- REGRA DE DERIVAÇÃO DE E-MAIL, UPN E sAMAccountName          -->
    <!-- Conforme ADR-008: Resolução automática de colisões (N+1)    -->
    <!-- <REDACTED_SECRET>==================== -->
    <mapping>
        <name>email-upn-generation</name>
        <strength>strong</strength>

        <source>
            <path>givenName</path>
        </source>
        <source>
            <path>familyName</path>
        </source>
        <source>
            <path>personalNumber</path>
        </source>

        <target>
            <path>emailAddress</path>
        </target>
        <target>
            <path>name</path>
        </target>

        <expression>
            <script>
                <code>
                    import com.evolveum.midpoint.util.logging.Trace;
                    import com.evolveum.midpoint.util.logging.LoggingUtils;

                    // <REDACTED_SECRET>====================
                    // REGRA DE DERIVAÇÃO DE E-MAIL E UPN (ADR-008)
                    // <REDACTED_SECRET>====================
                    // Input: givenName, familyName, personalNumber (employeeID)
                    // Output: emailAddress, userPrincipalName, sAMAccountName
                    // <REDACTED_SECRET>====================

                    def given = basic.norm(givenName)
                    def family = basic.norm(familyName)
                    def domain = "fiqueok.com.br"
                    def employeeId = basic.stringify(personalNumber)

                    // Validação: dados mínimos obrigatórios
                    if (!given || !family) {
                        log.error("Dados insuficientes: givenName=${given}, familyName=${family}")
                        return null
                    }

                    // Geração do base email
                    def baseEmail = given + '.' + family + '@' + domain
                    def emailAddress = baseEmail
                    def counter = 1

                    // <REDACTED_SECRET>====================
                    // Resolução automática de colisões (lógica N+1)
                    // <REDACTED_SECRET>====================
                    while (true) {
                        // Verificar se email já existe no repositório
                        def query = prismContext.queryFor(UserType.class)
                            .item(UserType.F_EMAIL_ADDRESS, prismContext.q().eq(emailAddress))
                            .build()
                        def existing = repositoryService.searchObjects(UserType.class, query, null)

                        if (existing.isEmpty()) {
                            break  // Email único, pode usar
                        }

                        // Colisão detectada - tentar próximo
                        counter++
                        emailAddress = given + '.' + family + counter + '@' + domain

                        // Fallback seguro: se atingir limite, usa employeeID
                        if (counter > 99) {
                            emailAddress = "user." + employeeId + '@' + domain
                            log.warn("Colisão excessiva para ${given}.${family}. Usando fallback: ${emailAddress}")
                            break
                        }
                    }

                    // UPN = emailAddress (Mail-as-UPN)
                    def userPrincipalName = emailAddress

                    // sAMAccountName = parte antes do @ (limitado a 20 caracteres)
                    def samAccountName = emailAddress.split('@')[0]
                    if (samAccountName.length() > 20) {
                        samAccountName = samAccountName.substring(0, 20)
                    }

                    log.info("UPN gerado: ${userPrincipalName}, sAMAccountName: ${samAccountName}")

                    // Retornar valores (emailAddress e name/sAMAccountName)
                    return emailAddress
                </code>
            </script>
        </expression>

        <condition>
            <script>
                <code>
                    // Só gerar se email não existir
                    return !emailAddress
                </code>
            </script>
        </condition>
    </mapping>

    <!-- <REDACTED_SECRET>==================== -->
    <!-- REGRA DE DERIVAÇÃO DE DISPLAYNAME                            -->
    <!-- <REDACTED_SECRET>==================== -->
    <mapping>
        <name>displayName-generation</name>
        <strength>strong</strength>

        <source>
            <path>givenName</path>
        </source>
        <source>
            <path>familyName</path>
        </source>

        <target>
            <path>fullName</path>
        </target>

        <expression>
            <script>
                <code>
                    def given = basic.stringify(givenName)
                    def family = basic.stringify(familyName)
                    def fullName = given + " " + family
                    return fullName
                </code>
            </script>
        </expression>
    </mapping>

    <!-- <REDACTED_SECRET>==================== -->
    <!-- REGRA PARA MUDANÇA DE NOME (MOVER) - Preservar alias         -->
    <!-- <REDACTED_SECRET>==================== -->
    <mapping>
        <name>move-name-preserve-alias</name>
        <strength>strong</strength>

        <source>
            <path>emailAddress</path>
        </source>

        <target>
            <path>extension/proxyAddresses</path>
        </target>

        <expression>
            <script>
                <code>
                    // Verificar se o e-mail mudou
                    def oldEmail = focusOld?.getEmailAddress()
                    def newEmail = emailAddress

                    if (oldEmail && oldEmail != newEmail) {
                        def oldProxy = 'smtp:' + oldEmail
                        log.info("Preservando alias: ${oldProxy}")
                        return oldProxy
                    }
                    return null
                </code>
            </script>
        </expression>
    </mapping>
</objectTemplate>
```

---

### 4.7. Fase 5 - Configurar Correlation Rule (5 min)

```xml
<!-- No Resource AD -->
<correlation>
    <correlationRule>
        <name>Correlacao_EmployeeID</name>
        <item>
            <source>
                <path>employeeID</path>
            </source>
            <target>
                <path>personalNumber</path>
            </target>
        </item>
    </correlationRule>
</correlation>
```

---

### 4.8. Fase 6 - Configurar Synchronization Reactions (10 min)

```xml
<!-- No Resource AD -->
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

    <!-- UNLINKED (emergência) -->
    <reaction>
        <name>UNLINKED - Link manual</name>
        <situation>unlinked</situation>
        <action>
            <type>link</type>
        </action>
    </reaction>
</synchronization>
```

---

### 4.9. Fase 7 - Validação com Usuário de Teste (15 min)

#### 7.1. Joiner - Criar usuário de teste no CSV/OrangeHRM

```csv
employeeID,givenName,familyName,department,title
TEST005,Ana,Paula,Marketing,Analista
```

#### 7.2. Executar Reconciliation

```
1. Tasks → New Task
2. Type: Reconciliation
3. Resource: Active Directory (Tailscale)
4. Execute: Run now
```

#### 7.3. Validar no AD

```powershell
# No console do AD
Get-ADUser -Filter "EmployeeID -eq 'TEST005'" -Properties *
```

**Esperado:** Usuário criado com UPN `ana.paula@fiqueok.com.br`, sAMAccountName `ana.paula`

#### 7.4. Validar no midPoint

```bash
# No iga-gf-02
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://172.23.201.182:8080/midpoint/ws/rest/users?search=personalNumber=TEST005" \
  | jq '.users[0] | {name: .name, fullName: .fullName, emailAddress: .emailAddress}'
```

---

## 5. Cronograma Estimado

| Fase | Atividade | Duração | Tempo Acumulado |
|------|-----------|---------|-----------------|
| 0 | Preparação (checkpoints) | 5 min | 5 min |
| 0.5 | Pre-Flight POC com CSV | 20 min | 25 min |
| 1 | Verificar conectividade | 5 min | 30 min |
| 2 | Configurar Resource AD | 15 min | 45 min |
| 3 | Configurar mapeamentos | 15 min | 60 min |
| 4 | Configurar regras de derivação | 20 min | 80 min |
| 5 | Configurar Correlation | 5 min | 85 min |
| 6 | Configurar Reactions | 10 min | 95 min |
| 7 | Validação com usuário teste | 15 min | 110 min |
| 8 | Documentação | 10 min | 120 min |
| **TOTAL** | | **~2 horas** | |

---

## 6. Matriz de Validação

| # | Teste | Comando | Resultado Esperado | Status |
|---|-------|---------|-------------------|--------|
| 0.5 | POC CSV | Importar 4 usuários | 4 users criados | □ |
| 0.5 | Colisão N+1 | TEST004 (João Silva) | `joao.silva2@...` | □ |
| 1 | Conectividade | `ping xxx.xxx.xxx.xxx` | 0% loss | □ |
| 2 | Porta LDAP | `nc -zv xxx.xxx.xxx.xxx 389` | succeeded | □ |
| 3 | Test Connection | GUI Resource | 5/5 Success | □ |
| 4 | Joiner | Criar TEST005 | UPN `ana.paula@fiqueok.com.br` | □ |
| 5 | sAMAccountName | Verificar no AD | `ana.paula` | □ |
| 6 | displayName | Verificar no AD | `Ana Paula` | □ |
| 7 | Mover | Alterar department | Sincronizado | □ |
| 8 | Leaver | Desabilitar conta | Usuário desabilitado | □ |

---

## 7. Plano de Rollback

### 7.1. Critério de Ativação

Ativar rollback se qualquer um dos cenários ocorrer:
- ❌ Test Connection falha após 3 tentativas
- ❌ POC CSV falha (mapeamentos incorretos)
- ❌ Import Task retorna erro
- ❌ midPoint não cria shadows
- ❌ Tempo de execução > 3 horas sem progresso

### 7.2. Procedimento de Rollback

```powershell
# Opção A - Restaurar snapshots
Stop-VM -Name "iga-gf-02" -Force
Stop-VM -Name "ID-P-01" -Force
Restore-VMSnapshot -Name "PRE-GMUD-001-PRJ026-v3-*" -VMName "iga-gf-02" -Confirm:$false
Restore-VMSnapshot -Name "PRE-GMUD-001-PRJ026-v3-*" -VMName "ID-P-01" -Confirm:$false
Start-VM -Name "iga-gf-02"
Start-VM -Name "ID-P-01"

# Opção B - Remover Resource AD no midPoint
# GUI: Configuration → Resources → Active Directory (Tailscale) → Delete
```

**Tempo estimado de rollback:** < 5 minutos

---

## 8. Riscos e Mitigações

| ID | Risco | Probabilidade | Impacto | Mitigação |
|----|-------|--------------|---------|-----------|
| R01 | POC CSV falha | Baixa | Médio | Diagnosticar mapeamentos antes do AD |
| R02 | Colisão de nomes não resolvida | Baixa | Médio | Fallback `user.employeeID@...` |
| R03 | IP Tailscale do AD mudar | Muito Baixa | Médio | Tailscale oferece IP fixo por dispositivo |
| R04 | ACL bloqueia acesso do midPoint | Baixa | Alto | Verificar ACLs antes da GMUD |
| R05 | employeeID não único | Baixa | Alto | Validar no RH antes do provisionamento |

---

## 9. Lições Aprendidas

| ID | Lição | Origem | Aplicação |
|----|-------|--------|-----------|
| L01 | CSV POC como pre-flight reduz risco | GMUD-023 | Padrão para futuras integrações |
| L02 | Resolução automática de colisões (N+1) é essencial | ADR-008 | Implementado nas regras de derivação |
| L03 | Mail-as-UPN melhora experiência do usuário | ADR-008 | Padrão adotado |
| L04 | Preservar aliases em mudanças de nome | ADR-008 | Implementado no Object Template |

---

## 10. Documentos Relacionados

| Documento | Localização | Relevância |
|-----------|-------------|------------|
| ADR-007 | `10_Projetos/PRJ028/20_Governanca_e_Decisoes/ADRs/` | Arquitetura Zero Trust |
| ADR-008 | `10_Projetos/PRJ028/20_Governanca_e_Decisoes/ADRs/` | Modelo de Identidade |
| GMUD-001-PRJ028 | `10_Projetos/PRJ028/20_Governanca_e_Decisoes/` | Hardening e Tailscale |
| GMUD-002-PRJ028 | `10_Projetos/PRJ028/20_Governanca_e_Decisoes/` | SSH, ACLs e MFA |
| PRJ003 Canvases | `10_Projetos/PRJ003/` | Fundamentos de identidade |

---

## 11. Aprovações

| Função | Nome | Data | Status |
|--------|------|------|:------:|
| Responsável Técnico | Paulo Feitosa Lima | 10/05/2026 | 🟡 Pendente |
| GRC Lead | Paulo Feitosa Lima | 10/05/2026 | 🟡 Pendente |
| Aprovador Final | Paulo Feitosa Lima | 10/05/2026 | 🟡 Pendente |

---

## 12. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 10/05/2026 | Paulo Feitosa Lima | Criação da GMUD (planejamento original) |
| 2.0 | 10/05/2026 | Paulo Feitosa Lima | Atualização para usar Tailscale (IP `xxx.xxx.xxx.xxx`) |
| **3.0** | **10/05/2026** | **Paulo Feitosa Lima** | **Adicionada Fase 0.5 (Pre-Flight POC com CSV). Regras de derivação conforme ADR-008. Resolução automática de colisões (N+1).** |

---

**FIM DA GMUD-001-PRJ026 v3.0**

---

*Documento mantido por Paulo Feitosa Lima — Living Lab Fiqueok*  
*PRJ026 - Integração midPoint 4.10 com Active Directory*  
*Pré-requisito: PRJ028 concluído (Tailscale no AD)*  
*Referências: ADR-007, ADR-008*  
*Data: 10/05/2026*
```
