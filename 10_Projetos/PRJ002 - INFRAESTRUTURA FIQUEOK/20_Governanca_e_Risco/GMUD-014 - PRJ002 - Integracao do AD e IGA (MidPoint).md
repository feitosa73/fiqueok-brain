## 

## 1. Metadados de Governança

- **ID:** GMUD-014 (Versão Final)
    
- **Título:** Integração de Provisionamento Outbound AD via LDAPS
    
- **Responsável:** Paulo (IAM/IGA Lead & Auditor ISO 27001)
    
- **Status:** 🟡 EM ELABORAÇÃO
    
- **Dependência:** ARQ-004 (Framework de Confiança) e GMUD-013 (Fonte HR).
    

---

## 2. Descrição Técnica do "Como" (Implementação)

A implementação consiste em três camadas de configuração que garantem que o midPoint não apenas se conecte ao AD, mas governe a criação de objetos de forma inteligente e segura.

### 2.1. Camada de Segurança (SSL Handshake)

Seguindo a **ARQ-004**, a comunicação deve ser obrigatoriamente criptografada para proteger dados PII e senhas em trânsito.

- **Comando de Injeção no Container:**
    
    Bash
    
    ```
    docker exec -it midpoint-server keytool -importcert -alias ad_ca \
    -file /opt/midpoint/var/ad_ca.cer \
    -keystore /opt/java/openjdk/lib/security/cacerts \
    -storepass changeit -noprompt
    ```
    
- **Parâmetros de Conexão (GUI):**
    
    - **Host:** `id-p-01.corp.fiqueok.com.br`
        
    - **Porta:** `636`
        
    - **Connection Security:** `ssl`
        

### 2.2. Lógica de Provisionamento de OUs (Outbound Mapping)

Esta é a configuração global que automatiza a alocação de colaboradores. O script abaixo deve ser inserido na definição do `Resource AD` -> `Schema Handling` -> `Account` -> `Attributes` -> `dn`.

**Script de Atribuição Dinâmica (Groovy):**

XML

```
<mapping>
    <source>
        <path>extension/department</path>
    </source>
    <target>
        <path>dn</path>
    </target>
    <expression>
        <script>
            <code>
                import attr.*
                
                // Definição da Base DN conforme ARQ-003
                String baseDN = ",OU=04_People,OU=Fiqueok_Corp,DC=corp,DC=fiqueok,DC=com,DC=br"
                String dept = input // Atributo vindo do HR (OrangeHRM)
                
                // Lógica de Direcionamento por Departamento
                if (dept == 'RH') {
                    return "CN=" + givenName + " " + familyName + ",OU=RH" + baseDN
                } else if (dept == 'Marketing') {
                    return "CN=" + givenName + " " + familyName + ",OU=Marketing" + baseDN
                } else {
                    // Fallback para Segurança e Auditoria
                    return "CN=" + givenName + " " + familyName + ",OU=Guests" + baseDN
                }
            </code>
        </script>
    </expression>
</mapping>
```

---

## 3. Plano de Testes Exaustivo

|**ID**|**Teste**|**Critério de Aceitação**|**Evidência**|
|---|---|---|---|
|**T01**|Conexão LDAPS|Sucesso no handshake SSL porta 636.|"Test Connection" Verde.|
|**T02**|Provisionamento RH|Usuário criado em `OU=RH` via automação.|Log de Atividade do AD.|
|**T03**|Provisionamento Mkt|Usuário criado em `OU=Marketing` via automação.|Log de Atividade do AD.|
|**T04**|Escrita de Senha|Alteração de senha no midPoint refletida no AD.|Sucesso no login AD.|

---

## 4. Plano de Rollback e Contingência

1. **Falha de Conexão:** Reverter para porta 389 (sem SSL) apenas para validação de Bind DN, desativando o provisionamento de senhas (que exige SSL).
    
2. **Erro de DN:** Excluir os objetos criados incorretamente no AD e ajustar a lógica de concatenização do script XML.
    
3. **Log de Erros:** Monitorar o arquivo `var/log/midpoint.log` para capturar falhas de `LDAP Result Code 32` (Target not found).
    

---

### 📊 Visão Estratégica e Impacto Financeiro (Audit-Ready)

- **ROI:** A automação da Fase III desta GMUD reduz em **90% o tempo de provisionamento manual**.
    
- **Compliance ISO 27001 (A.9.2.2):** Garante o provisionamento de acesso consistente com a função organizacional, eliminando o risco de usuários "perdidos" em OUs com permissões excessivas.
## 5. Critérios de Aceite e Evidências Cruzadas

A conclusão desta mudança será validada em conjunto com a **GMUD-013**. A evidência definitiva de sucesso será:

1. **Verde no Test Connection:** Validação do handshake SSL na porta 636.
    
2. **Criação de Objetos:** Presença das contas de **Rose Araujo** e **Daniel Ribeiro** no AD, populadas via midPoint com as senhas iniciais devidamente criptografadas.
