## 📋 - Procedimento Operacional Padrão**

### **Integração midPoint 4.10 com AWS IAM via Atricore Connector**

---

| Campo | Valor |
|-------|-------|
| **Documento** | POP-PRJ023-v1.0 |
| **Versão** | 1.0 |
| **Data** | 05/05/2026 |
| **Status** | ✅ **VALIDADO** - Pronto para Execução |
| **Responsável** | Paulo Feitosa Lima |
| **Projeto** | PRJ023 |
| **TAP Base** | TAP-PRJ023-v2.0 |

---

## 1. Objetivo

Este POP documenta o procedimento completo e validado para integrar o **midPoint 4.10** com a **AWS IAM** utilizando o **AWSConnector v1.1.2 da Atricore**, permitindo o provisionamento automático de usuários IAM.

---

## 2. Pré-Requisitos

| # | Requisito | Comando de Verificação | Status |
|---|-----------|------------------------|--------|
| PR-01 | Acesso ao servidor iga-gf-02 | `ssh paulo@iga-gf-02` | ⬜ |
| PR-02 | Docker Compose funcionando | `cd /srv/iga-project && docker compose ps` | ⬜ |
| PR-03 | midPoint 4.10 operacional | `curl http://localhost:8080/midpoint` | ⬜ |
| PR-04 | Credenciais AWS disponíveis | Access Key e Secret Key | ✅ |
| PR-05 | Snapshot das VMs realizado | Hyper-V checkpoint | ⬜ |
| PR-06 | Internet no container | `docker exec iga-midpoint curl -I https://aws.amazon.com` | ⬜ |

---

## 3. Procedimento de Execução

### **FASE 1: Instalação do Conector**

#### Passo 1.1: Verificar o arquivo JAR
```bash
# No servidor iga-gf-02
ls -la /tmp/connector-aws-*.jar
# Deve mostrar: -rw-rw-r-- 1 paulo paulo 12544446 May 5 14:25 /tmp/connector-aws-1.1.2.jar
```

#### Passo 1.2: Copiar para o diretório correto
```bash
sudo cp /tmp/connector-aws-1.1.2.jar /srv/iga-project/data/midpoint/icf-connectors/
```

#### Passo 1.3: Ajustar permissões
```bash
sudo chown 1000:1000 /srv/iga-project/data/midpoint/icf-connectors/connector-aws-*.jar
sudo chmod 644 /srv/iga-project/data/midpoint/icf-connectors/connector-aws-*.jar
```

#### Passo 1.4: Reiniciar o midPoint
```bash
cd /srv/iga-project
sudo docker compose restart midpoint
sleep 30
```

#### Passo 1.5: Verificar descoberta do conector
```bash
sudo docker logs iga-midpoint --tail 100 | grep -i "awsconnector"
# Saída esperada: "Discovered ICF bundle in JAR: com.atricore.iam.evolveum.connector.connector-aws version: 1.1.2"
```

**Critério de Sucesso F1:** ✅ Log mostra descoberta do AWSConnector

---

### **FASE 2: Correção do Ambiente Java (trustAnchors)**

#### Passo 2.1: Verificar estado atual do cacerts
```bash
sudo docker exec iga-midpoint ls -la /usr/lib/jvm/java-21-openjdk-amd64/lib/security/cacerts
# Deve mostrar link simbólico para /etc/ssl/certs/java/cacerts
```

#### Passo 2.2: Verificar conteúdo do cacerts
```bash
sudo docker exec iga-midpoint keytool -list -keystore /usr/lib/jvm/java-21-openjdk-amd64/lib/security/cacerts -storepass changeit 2>/dev/null | head -5
# Deve mostrar: "Keystore type: JKS" e "Your keystore contains X entries"
```

#### Passo 2.3: Editar docker-compose.yml para adicionar JAVA_OPTS
```bash
cd /srv/iga-project
sudo nano docker-compose.yml
```

**Adicionar/modificar a linha JAVA_OPTS no environment do midpoint:**
```yaml
      JAVA_OPTS: "-Xms512m -Xmx1024m -Dfile.encoding=UTF-8 -Djavax.net.ssl.trustStore=/usr/lib/jvm/java-21-openjdk-amd64/lib/security/cacerts -Djavax.net.ssl.trustStorePassword=changeit"
```

#### Passo 2.4: Reiniciar para aplicar alterações
```bash
cd /srv/iga-project
sudo docker compose down
sudo docker compose up -d
sleep 30
```

#### Passo 2.5: Validar conectividade SSL
```bash
sudo docker exec iga-midpoint curl -s -o /dev/null -w "HTTP: %{http_code}\n" https://iam.amazonaws.com
# Saída esperada: HTTP: 200 ou HTTP: 302 (aceitável)
```

**Critério de Sucesso F2:** ✅ curl retorna HTTP 200/302 (conexão estabelecida)

---

### **FASE 3: Configuração do Resource no midPoint**

#### Passo 3.1: Acessar o GUI do midPoint
```
URL: http://xxx.xxx.xxx.xxx:8080/midpoint (ou https://iga.fiqueok.local/admin)
Usuário: administrator
Senha: M1dP0!ntAdm!n#2026
```

#### Passo 3.2: Criar novo Resource
1. Navegue para **Resources** → **New resource**
2. Na lista de conectores, selecione **AWSConnector v1.1.2**
3. Clique em **Next**

#### Passo 3.3: Preencher configurações

| Campo | Valor | Observação |
|-------|-------|------------|
| **Name** | `AWS IAM` | Nome do Resource |
| **Display Name** | `AWS Identity and Access Management` | Opcional |
| **awsAccessKeyId** | `AKIAVZCTR5O4PVUJR54U` | Digitar no campo |
| **awsSecretAccessKey** | `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` | Selecionar "Use clear value" |
| **awsRegion** | `us-east-1` | Digitar no campo |
| **Allow Cache** | `False` (desmarcado) | Manter desativado |

#### Passo 3.4: Salvar e Testar
1. Clique em **Next** até finalizar
2. Clique em **Save**
3. Clique em **Test Connection**

**Critério de Sucesso F3:** ✅ Test Connection retorna "Connection test completed successfully"

---

### **FASE 4: Configuração do Schema Handling**

#### Passo 4.1: Adicionar Object Type
1. No Resource AWS IAM, vá para **Schema Handling**
2. Clique em **Add** em Object Types

| Campo | Valor |
|-------|-------|
| **Kind** | `account` |
| **Intent** | `aws-iam-user` |
| **Display Name** | `IAM User` |

#### Passo 4.2: Configurar mapeamentos de atributos

| Source (midPoint) | Target (AWS) | Direction |
|-------------------|--------------|-----------|
| `name` | `__NAME__` | inbound/outbound |
| `givenName` | `firstName` | outbound |
| `familyName` | `lastName` | outbound |
| `personalNumber` | `employeeNumber` | outbound |
| `emailAddress` | `email` | outbound |

#### Passo 4.3: Salvar alterações
Clique em **Save**

**Critério de Sucesso F4:** ✅ Schema Handling salvo sem erros

---

### **FASE 5: Validação e Testes**

#### Passo 5.1: Teste de Listagem
No Resource AWS IAM, clique em **Live Sync** ou **View** → **Resource Objects**
- Deve listar usuários IAM existentes (ou nenhum, se for primeira execução)

#### Passo 5.2: Teste de Criação (via tarefa de reconciliação)
1. **Tasks** → **New Task** → **Synchronization / Reconciliation**
2. Selecione o Resource **AWS IAM**
3. Configure **Synchronization**:
   - **Unmatched** → `link` (se usuário não existe na AWS)
   - **Unlinked** → `unlink` (se shadow existe mas não tem dono)
4. Execute a tarefa

#### Passo 5.3: Verificar na AWS Console
1. Acesse AWS Console → IAM → Users
2. Verifique se os usuários foram criados

**Critério de Sucesso F5:** ✅ Usuários aparecem no console AWS

---

## 4. Troubleshooting

### Erro 1: `trustAnchors parameter must be non-empty`

| Causa | Solução |
|-------|---------|
| Java não encontra o arquivo cacerts | Adicionar `-Djavax.net.ssl.trustStore` no JAVA_OPTS (Fase 2) |
| Link simbólico quebrado | `sudo docker exec -u root iga-midpoint update-ca-certificates -f` |

### Erro 2: `Access Denied` ou `Unauthorized`

| Causa | Solução |
|-------|---------|
| Permissões IAM insuficientes | Adicionar política: `iam:ListUsers`, `iam:CreateUser`, `iam:TagUser` |
| Access Key inválida | Verificar no console AWS se a chave está ativa |

### Erro 3: Conector não aparece na lista

| Causa | Solução |
|-------|---------|
| JAR no diretório errado | Mover para `/opt/midpoint/var/icf-connectors/` |
| Permissões incorretas | `chown 1000:1000` e `chmod 644` |
| MidPoint não reiniciado | `docker compose restart midpoint` |

---

## 5. Verificação Final (Checklist)

| # | Verificação | Comando/Procedimento | Status |
|---|-------------|----------------------|--------|
| V01 | Conector instalado | `docker exec iga-midpoint ls /opt/midpoint/var/icf-connectors/ \| grep aws` | ⬜ |
| V02 | Java SSL configurado | `docker exec iga-midpoint curl https://iam.amazonaws.com` | ⬜ |
| V03 | Resource criado | GUI → Resources → AWS IAM | ⬜ |
| V04 | Test Connection OK | Resource → Test Connection | ⬜ |
| V05 | Schema Handling configurado | GUI → Schema Handling → account/aws-iam-user | ⬜ |
| V06 | Tarefa de reconciliação executada | Tasks → verificar sucesso | ⬜ |
| V07 | Usuário criado na AWS | Console AWS → IAM Users | ⬜ |

---

## 6. Rollback Procedure

Se qualquer etapa falhar e não puder ser corrigida em 30 minutos:

```bash
# No PowerShell do Windows (como Administrador)
Get-VMSnapshot -VMName "iga-gf-02" | Where-Object {$_.Name -like "*PRJ023*"} | Restore-VMSnapshot -Confirm:$false
Get-VMSnapshot -VMName "api-gf-01" | Where-Object {$_.Name -like "*PRJ023*"} | Restore-VMSnapshot -Confirm:$false

# Aguardar 60 segundos e iniciar as VMs
Start-VM -Name "iga-gf-02", "api-gf-01"
```

---

## 7. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 05/05/2026 | Paulo Feitosa Lima | Criação do POP baseado no TAP-PRJ023-v2.0 e validação Gemini |

---

## 8. Aprovação

| Função | Nome | Data | Decisão |
|--------|------|------|---------|
| Arquiteto IGA | Paulo Feitosa Lima | 05/05/2026 | ✅ APROVADO PARA EXECUÇÃO |

---

**Fim do POP-PRJ023-v1.0**

---

*Documento gerado com base na análise do Gemini (05/05/2026) e evidências de execução*
*Living Lab Fiqueok - PRJ023 - Integração midPoint ↔ AWS IAM*
