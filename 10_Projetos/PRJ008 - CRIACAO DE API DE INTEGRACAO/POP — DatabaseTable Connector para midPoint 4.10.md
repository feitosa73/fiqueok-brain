
# 
## Integração direta com MariaDB do OrangeHRM (substituto da Shadow API para JML)

---

| Campo | Valor |
|-------|-------|
| **Documento** | POP-DatabaseTable-Connector-v1.0 |
| **Versão** | 1.0 |
| **Data** | 14/04/2026 |
| **Autor** | Paulo Feitosa Lima |
| **Baseado no bloqueio** | TEP-PRJ008-v1.0-FREEZING.md |
| **Pré-requisito** | midPoint 4.10 operacional (iga-gf-02) + MariaDB acessível (rh-gf-01) |
| **Tempo estimado** | 15–20 minutos |

---

## OBJETIVO

Contornar o bloqueio do conector REST (incompatível com midPoint 4.10/Java 21) utilizando o **DatabaseTable Connector** nativo do midPoint para acessar diretamente o MariaDB do OrangeHRM, permitindo a conclusão do ciclo JML (Joiner/Mover/Leaver) no Living Lab.

> **Nota:** Esta abordagem **substitui a Shadow API** como fonte de dados para o midPoint, mas mantém a Shadow API como ativo futuro. O objetivo é **entregar valor funcional imediato** (sincronização de identidades) enquanto o conector REST não está disponível.

---

## PRÉ-REQUISITOS VERIFICADOS

Antes de iniciar, confirme os itens abaixo (evidências já documentadas):

| Item | Status | Como verificar |
|------|--------|----------------|
| midPoint 4.10 em `iga-gf-02` rodando | ✅ | `docker ps \| grep iga-midpoint` |
| PostgreSQL 16 íntegro | ✅ | `docker exec iga-postgres pg_isready` |
| MariaDB em `rh-gf-01` acessível via Tailscale | ✅ | `ping xxx.xxx.xxx.xxx` |
| Usuário `svc_shadow_api` com SELECT nas tabelas | ✅ | Testado no `Evidencias_Prompt_Orange.md` |
| Conector `DatabaseTableConnector` já registrado | ✅ | OID `50a3ab9f-...` (listado no banco) |

Se algum item não estiver OK, resolva antes de prosseguir.

---

## PASSO A — BAIXAR O DRIVER MYSQL/MARIADB (1 minuto)

O DatabaseTable Connector do midPoint **não inclui o driver JDBC para MariaDB** (ele vem apenas com PostgreSQL). Precisamos adicioná-lo manualmente.

### A.1 Baixar o JAR do driver

No **seu computador Windows** (ou onde tiver acesso à internet), baixe o driver MySQL Connector/J versão 8.0.33 (compatível com MariaDB 10.11):

```powershell
# PowerShell (Windows)
Invoke-WebRequest -Uri "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar" -OutFile "$env:USERPROFILE\Downloads\mysql-connector-j-8.0.33.jar"
```

Se o link falhar, use o navegador:  
https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar

### A.2 Transferir para a VM midPoint

```powershell
# No PowerShell (Windows)
scp "$env:USERPROFILE\Downloads\mysql-connector-j-8.0.33.jar" paulo@xxx.xxx.xxx.xxx:/tmp/
```

---

## PASSO B — COPIAR O DRIVER PARA O VOLUME DO MIDPOINT (2 minutos)

Conecte-se à VM `iga-gf-02` via SSH e mova o JAR para o diretório correto:

```bash
ssh paulo@xxx.xxx.xxx.xxx

# Garantir que o diretório de conectores existe
sudo mkdir -p /srv/iga-project/data/midpoint/connid-connectors

# Copiar o driver do /tmp para o volume persistente
sudo cp /tmp/mysql-connector-j-8.0.33.jar /srv/iga-project/data/midpoint/connid-connectors/

# Remover o arquivo temporário (opcional)
rm /tmp/mysql-connector-j-8.0.33.jar

# Verificar
ls -lh /srv/iga-project/data/midpoint/connid-connectors/
# Deve mostrar o JAR com tamanho ~2.4MB
```

---

## PASSO C — REINICIAR O MIDPOINT (30 segundos)

O midPoint precisa ser reiniciado para detectar o novo driver no classpath.

```bash
cd /srv/iga-project
docker compose restart midpoint
sleep 45

# Verificar se o container está saudável
docker ps | grep iga-midpoint
# Status deve ser "Up" ou "healthy"
```

---

## PASSO D — CRIAR O XML DO RESOURCE (DATABASETABLE CONNECTOR)

### D.1 Criar o arquivo XML

```bash
cd /srv/iga-project

cat > database-table-resource.xml << 'EOF'
<resource xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
          xmlns:c="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
          xmlns:icfc="http://midpoint.evolveum.com/xml/ns/public/connector/icf-1/connector-schema-3"
          xmlns:ri="http://midpoint.evolveum.com/xml/ns/public/resource/instance-3">
    <name>OrangeHRM via DatabaseTable Connector</name>
    <connectorRef oid="50a3ab9f-87b0-4537-a31a-22d072d88b68" type="ConnectorType"/>
    <connectorConfiguration>
        <icfc:configurationProperties>
            <!-- JDBC URL para MariaDB (com charset utf8mb4 para acentuação) -->
            <icfc:connectionUrl>jdbc:mysql://xxx.xxx.xxx.xxx:3306/orangehrm?useSSL=false&amp;serverTimezone=UTC&amp;characterEncoding=utf8mb4</icfc:connectionUrl>
            <icfc:user>svc_shadow_api</icfc:user>
            <icfc:password>
                <clearValue>**********</clearValue>
            </icfc:password>
            <icfc:driver>com.mysql.cj.jdbc.Driver</icfc:driver>
            <icfc:table>hs_hr_employee</icfc:table>
        </icfc:configurationProperties>
    </connectorConfiguration>
    <schemaHandling>
        <objectType>
            <kind>account</kind>
            <intent>default</intent>
            <displayName>OrangeHRM Employee</displayName>
            <default>true</default>
            <objectClass>ri:AccountObjectClass</objectClass>
            <attribute>
                <c:ref>ri:emp_number</c:ref>
                <displayName>Internal Anchor (Immutable)</displayName>
                <matchingRule>mr:stringIgnoreCase</matchingRule>
            </attribute>
            <attribute>
                <c:ref>ri:employee_id</c:ref>
                <displayName>Business ID</displayName>
            </attribute>
            <attribute>
                <c:ref>ri:first_name</c:ref>
                <displayName>First Name</displayName>
            </attribute>
            <attribute>
                <c:ref>ri:last_name</c:ref>
                <displayName>Last Name</displayName>
            </attribute>
            <attribute>
                <c:ref>ri:employment_status</c:ref>
                <displayName>Employment Status</displayName>
            </attribute>
        </objectType>
    </schemaHandling>
</resource>
EOF
```

> **Atenção:** Se a senha do `svc_shadow_api` for diferente de `**********`, substitua no campo `<clearValue>`.

---

## PASSO E — IMPORTAR O RESOURCE (2 minutos)

### E.1 Importar via API REST (recomendado)

```bash
curl -u administrator:'M1dP0!ntAdm!n#2026' \
     -H "Content-Type: application/xml" \
     -X POST \
     -d @database-table-resource.xml \
     http://localhost:8080/midpoint/ws/rest/resources
```

**Resposta esperada:** HTTP 201 (Created) com um XML contendo o OID do novo Resource. Anote o OID.

### E.2 Alternativa: importar pela interface

1. Acesse `http://192.168.111.153:8080/midpoint` (login: administrator / M1dP0!ntAdm!n#2026)
2. **Configuration → Import Objects**
3. Selecione o arquivo `database-table-resource.xml` e clique em **Import**
4. Confirme a mensagem de sucesso.

---

## PASSO F — TESTAR A CONEXÃO (30 segundos)

### F.1 Via CLI (REST)

```bash
# Substitua <OID_DO_RESOURCE> pelo OID retornado no passo anterior
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
     -X POST \
     http://localhost:8080/midpoint/ws/rest/resources/<OID_DO_RESOURCE>/test \
     | grep -o '<status>[^<]*</status>' | head -1
```

**Esperado:** `<status>success</status>` (pode aparecer dentro de um bloco maior, mas deve existir um `success`).

### F.2 Via interface

- Vá em **Resources** → **OrangeHRM via DatabaseTable Connector**
- Clique em **Test Connection**
- Deve aparecer uma mensagem verde: "Connection test succeeded"

---

## PASSO G — IMPORTAR OS FUNCIONÁRIOS (5 minutos)

### G.1 Executar a importação (reconciliação)

```bash
# Através da API (substitua o OID)
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
     -X POST \
     -H "Content-Type: application/xml" \
     -d '<task xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3"><name>Import OrangeHRM Employees</name><resourceRef oid="<OID_DO_RESOURCE>"/><synchronization><objectSynchronization><kind>account</kind></objectSynchronization></synchronization></task>' \
     http://localhost:8080/midpoint/ws/rest/tasks
```

**Ou via interface:**

- **Resources** → **OrangeHRM via DatabaseTable Connector** → **Import** → **Run**
- Aguarde a conclusão (a página recarregará)

### G.2 Verificar os dados importados

```bash
# Contar quantos funcionários foram trazidos para o midPoint
docker exec -it iga-postgres psql -U midpoint_user -d midpoint -c "SELECT COUNT(*) FROM m_user WHERE name LIKE 'emp_%';"
# Deve retornar o número de registros do hs_hr_employee (ex: 102)

# Verificar um registro específico
docker exec -it iga-postgres psql -U midpoint_user -d midpoint -c "SELECT name, givenName, familyName FROM m_user WHERE name = 'emp_1' LIMIT 1;"
```

---

## PASSO H — VALIDAÇÃO DO CICLO JML (OPCIONAL, PARA FUTURO)

Após a importação bem-sucedida, você pode configurar a **sincronização** (synchronization) para automatizar Joiner/Mover/Leaver. Isso exige a criação de uma política de sincronização no mesmo Resource, baseada no campo `employment_status` ou em outras regras.

Exemplo de política (simplificada):

```xml
<synchronization>
    <objectSynchronization>
        <kind>account</kind>
        <intent>default</intent>
        <reaction>
            <condition>
                <script>
                    <code>employee.attributes.find{it.name == 'employment_status'}?.value == 'Active'</code>
                </script>
            </condition>
            <action>
                <actionType>add</actionType>
            </action>
        </reaction>
        <reaction>
            <condition>
                <script>
                    <code>employee.attributes.find{it.name == 'employment_status'}?.value == 'Terminated'</code>
                </script>
            </condition>
            <action>
                <actionType>delete</actionType>
            </action>
        </reaction>
    </objectSynchronization>
</synchronization>
```

Este passo **não é obrigatório** para a prova de conceito, mas pode ser adicionado posteriormente.

---

## CHECKLIST DE SUCESSO

Após executar os passos, verifique:

```bash
echo "=== CHECKLIST DatabaseTable Connector ==="

echo -n "1. Driver MySQL no volume: "
ls /srv/iga-project/data/midpoint/connid-connectors/mysql-connector-j-8.0.33.jar > /dev/null 2>&1 && echo "✅" || echo "❌"

echo -n "2. Container midPoint rodando: "
docker ps | grep -q iga-midpoint && echo "✅" || echo "❌"

echo -n "3. Resource importado: "
curl -s -u administrator:'M1dP0!ntAdm!n#2026' http://localhost:8080/midpoint/ws/rest/resources | grep -q "OrangeHRM via DatabaseTable Connector" && echo "✅" || echo "❌"

echo -n "4. Test Connection: "
curl -s -u administrator:'M1dP0!ntAdm!n#2026' -X POST http://localhost:8080/midpoint/ws/rest/resources/<OID>/test | grep -q "success" && echo "✅" || echo "❌"

echo -n "5. Funcionários importados: "
COUNT=$(docker exec -it iga-postgres psql -U midpoint_user -d midpoint -t -c "SELECT COUNT(*) FROM m_user WHERE name LIKE 'emp_%'" | tr -d ' ')
[ "$COUNT" -gt 0 ] && echo "✅ $COUNT registros" || echo "❌"
```

---

## ROLLBACK (CASO ALGO DÊ ERRADO)

Se o `Test Connection` falhar ou a importação não funcionar:

1. **Deletar o Resource** (pela interface ou API)  
2. **Remover o driver** do volume:  
   `sudo rm /srv/iga-project/data/midpoint/connid-connectors/mysql-connector-j-8.0.33.jar`
3. **Reiniciar o midPoint**  
4. **Restaurar o snapshot** da VM `iga-gf-02` se necessário (recomendado antes de iniciar o POP)

---

## TEMPO TOTAL ESTIMADO (REEXECUÇÃO FUTURA)

| Passo | Descrição | Tempo |
|-------|-----------|-------|
| A | Baixar e transferir driver | 3 min |
| B | Copiar para o volume | 1 min |
| C | Reiniciar midPoint | 1 min |
| D | Criar XML | 2 min |
| E | Importar Resource | 2 min |
| F | Testar conexão | 1 min |
| G | Importar funcionários | 5 min |
| H | Validar | 2 min |
| **TOTAL** | | **~17 minutos** |

---

## OBSERVAÇÕES FINAIS

- Este POP **substitui a necessidade da Shadow API** para a integração imediata, mas **não invalida** o trabalho da Shadow API. Ela pode ser reativada no futuro quando houver um conector REST compatível.
- O DatabaseTable Connector acessa o banco diretamente, **contornando** o problema de compatibilidade do ScriptedREST.
- A senha `**********` está em texto claro no XML. Para hardening futuro, considere usar o Vault ou criptografia nativa do midPoint.
- Se o midPoint 4.10 for atualizado para uma versão futura que inclua um conector REST nativo, você pode simplesmente trocar o conector no Resource sem perder os dados.

---

**Próximo passo quando retomar:** executar este POP do início ao fim, sem pular etapas. O tempo de execução é curto e o risco é baixo.

*Documento preparado para retomada futura.*
*Living Lab Fiqueok — PRJ008*
*Arquivo: POP-DatabaseTable-Connector-v1.0.md*
```
