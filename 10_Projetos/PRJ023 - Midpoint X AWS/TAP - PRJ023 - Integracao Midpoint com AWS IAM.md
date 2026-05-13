
---

## 📄 **TAP PRJ023 v2.0 - Integração midPoint com AWS IAM via Atricore Connector**

---

| Campo | Valor |
|-------|-------|
| **Projeto** | PRJ023 |
| **Título** | Integração midPoint 4.10 com AWS IAM via Atricore Connector |
| **Versão** | 2.0 |
| **Data** | 05/05/2026 |
| **Status** | 📝 Em Execução - Bloqueio Técnico em Análise |
| **Responsável** | Paulo Feitosa Lima |
| **Pré-requisito** | PRJ022-A (CSV → midPoint) funcionando |
| **Documentos Base** | TAP-PRJ022-v1.0, TEP-PRJ022-v1.0, ARQ-PRJ008-v2.1 |

---

## 1. Resumo Executivo

O PRJ023 foi originalmente planejado para utilizar **ScriptedREST Connector** com implementação manual da AWS Signature V4 em Groovy. Durante a fase de preparação, foi descoberto o **AWSConnector v1.1.2 da Atricore**, um conector nativo que elimina completamente a complexidade da assinatura manual.

Este TAP revisado incorpora:
- Uso do conector Atricore como solução primária
- POP detalhado para instalação e configuração
- Procedimento de correção do ambiente Java (trustAnchors)

---

## 2. Escopo Revisado

### 2.1. Dentro do Escopo

| Item | Descrição | Status |
|------|-----------|--------|
| ✅ | Baixar conector Atricore AWSConnector v1.1.2 | Concluído |
| ✅ | Instalar JAR em `/opt/midpoint/var/icf-connectors/` | Concluído |
| ✅ | Verificar descoberta do conector pelo midPoint | Concluído |
| 🔄 | Corrigir problema de certificados Java (trustAnchors) | Em andamento |
| ⏳ | Configurar Resource AWS no midPoint | Pendente |
| ⏳ | Configurar Schema Handling e mapeamentos | Pendente |
| ⏳ | Executar Test Connection e validar | Pendente |
| ⏳ | Provisionar usuários IAM na AWS | Pendente |

### 2.2. Fora do Escopo

| Item | Justificativa |
|------|---------------|
| ❌ | Grupos e políticas IAM | Fase 2 do projeto |
| ❌ | AWS Identity Center (SSO) | Complexidade adicional |
| ❌ | ScriptedREST com Signature V4 | Substituído pelo conector nativo |

---

## 3. POP - Procedimento Operacional Padrão

### **Fase 1: Download e Instalação do Conector** ✅ CONCLUÍDO

| Passo | Comando | Status |
|-------|---------|--------|
| 1.1 | Baixar JAR do GitHub Atricore | `wget https://github.com/atricore/midpoint-connector-aws/releases/download/v1.0.0/connector-aws-1.1.2.jar` | ✅ |
| 1.2 | Copiar para host do IGA | `scp connector-aws-*.jar paulo@iga-gf-02:/tmp/` | ✅ |
| 1.3 | Mover para diretório de conectores | `sudo cp /tmp/connector-aws-*.jar /srv/iga-project/data/midpoint/icf-connectors/` | ✅ |
| 1.4 | Ajustar permissões | `sudo chown 1000:1000 ... && sudo chmod 644 ...` | ✅ |
| 1.5 | Reiniciar midPoint | `sudo docker compose restart midpoint` | ✅ |
| 1.6 | Verificar descoberta | `sudo docker logs iga-midpoint \| grep -i "awsconnector"` | ✅ |

**Evidência de sucesso:**
```
Discovered ICF bundle in JAR: com.atricore.iam.evolveum.connector.connector-aws version: 1.1.2
```

### **Fase 2: Correção do Ambiente Java (trustAnchors)** 🔄 EM ANDAMENTO

**Problema identificado:** O conector falha no Test Connection com erro `java.security.InvalidAlgorithmParameterException: the trustAnchors parameter must be non-empty`. Isto indica que a JVM do midPoint 4.10 não está conseguindo ler o repositório de certificados confiáveis (cacerts) durante o handshake SSL com a AWS[cite: 6].

| Passo | Comando | Status |
|-------|---------|--------|
| 2.1 | Verificar estado do cacerts | `sudo docker exec iga-midpoint ls -la /etc/ssl/certs/java/` | ⏳ |
| 2.2 | Adicionar parâmetros SSL ao JAVA_OPTS | Editar `docker-compose.yml` | ⏳ |
| 2.3 | Reiniciar container | `sudo docker compose down && up -d` | ⏳ |
| 2.4 | Testar conectividade SSL | `curl -v https://iam.amazonaws.com` | ⏳ |

**Correção a ser aplicada no `docker-compose.yml`:**
```yaml
environment:
  JAVA_OPTS: "-Xms512m -Xmx1024m -Dfile.encoding=UTF-8 -Djavax.net.ssl.trustStore=/usr/lib/jvm/java-21-openjdk-amd64/lib/security/cacerts -Djavax.net.ssl.trustStorePassword=changeit"
```

### **Fase 3: Configuração do Resource** ⏳ PENDENTE

| Passo | Ação | Detalhe |
|-------|------|---------|
| 3.1 | Acessar GUI | `https://iga.fiqueok.local/admin` |
| 3.2 | Criar Resource | Resources → New resource → AWSConnector v1.1.2 |
| 3.3 | Configurar credenciais | awsAccessKeyId, awsSecretAccessKey, awsRegion |
| 3.4 | Test Connection | Validar conectividade com AWS |

**Configuração do Resource:**
```json
{
  "awsAccessKeyId": "<REDACTED_SECRET>",
  "awsSecretAccessKey": "<REDACTED_SECRET>",
  "awsRegion": "us-east-1",
  "allowCache": false
}
```

### **Fase 4: Schema Handling e Mapeamentos** ⏳ PENDENTE

| midPoint Attribute | AWS Attribute | Direction |
|--------------------|---------------|-----------|
| `name` | `__NAME__` | inbound/outbound |
| `givenName` | `firstName` | outbound |
| `familyName` | `lastName` | outbound |
| `personalNumber` | `employeeNumber` | outbound |

### **Fase 5: Validação** ⏳ PENDENTE

| Teste | Critério |
|-------|----------|
| Test Connection | HTTP 200 ou mensagem de sucesso |
| ListUsers | Retornar usuários existentes (ou lista vazia) |
| CreateUser | Criar usuário de teste na AWS |

---

## 4. Riscos e Mitigações (Atualizado)

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Problema trustAnchors (Java SSL) | Alta | Alto | Configurar JAVA_OPTS com trustStore explícito |
| Conector incompatível com Java 21 | Média | Alto | Conector v1.1.2 compatível com Java 17+ |
| Permissões IAM insuficientes | Baixa | Médio | Revisar política IAM anexada à Access Key |

---

## 5. Lições Aprendidas (PRJ023)

| # | Lição | Categoria |
|---|-------|-----------|
| L01 | O conector Atricore AWSConnector existe e é a solução correta, não ScriptedREST | Arquitetura |
| L02 | O erro `trustAnchors` é problema do ambiente Java, não do conector | Infraestrutura |
| L03 | A solução é forçar o caminho do trustStore via `-Djavax.net.ssl.trustStore` | Operacional |
| L04 | O AWSConnector requer permissões IAM mínimas: `iam:ListUsers`, `iam:CreateUser`, `iam:TagUser` | Segurança |
| L05 | O conector deve ser instalado em `/icf-connectors/`, não `/connid-connectors/` | Técnica |

---

## 6. Aprovações

| Função | Nome | Data | Decisão |
|--------|------|------|---------|
| Arquiteto IGA | Paulo Feitosa Lima | 05/05/2026 | 🔄 AGUARDANDO RESOLUÇÃO DO TRUSTANCHORS |

---

## 7. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 04/05/2026 | Paulo Feitosa Lima | TAP original (ScriptedREST/Signature V4) |
| 2.0 | 05/05/2026 | Paulo Feitosa Lima | Revisão completa para usar Atricore Connector; inclusão do POP e solução trustAnchors |

---

## 8. Próximos Passos Imediatos

1. **Aplicar correção do JAVA_OPTS** no `docker-compose.yml`
2. **Reiniciar o container** e testar conectividade SSL
3. **Executar Test Connection** no Resource AWS
4. **Documentar resultado** - sucesso ou novo erro

---

**Fim do TAP PRJ023 v2.0**

---

*Documento baseado na análise do Gemini (05/05/2026) e nas evidências de execução*
*Living Lab Fiqueok - PRJ023 - Integração midPoint ↔ AWS IAM*
