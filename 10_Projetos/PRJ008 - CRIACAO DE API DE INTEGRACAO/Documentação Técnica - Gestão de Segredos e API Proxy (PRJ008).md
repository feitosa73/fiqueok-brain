# 

## 1. Visão Geral do Cenário

Nesta etapa do laboratório, configuramos a camada de **Secret Management** (Gestão de Segredos) utilizando o **HashiCorp Vault**. O objetivo é garantir que a nossa API (Shadow-API) não exponha credenciais sensíveis e utilize um modelo de autenticação profissional antes de acessar recursos críticos.

## 2. O Que Fizemos (Passo a Passo)

1. **Criação de Política (Policy):** Definimos uma política no Vault chamada `api-proxy-policy` que restringe o que este token pode ler ou gravar.
    
2. **Geração do Token de Serviço:** Geramos um token com identidade específica (`svc-shadow-api`) e um tempo de vida (TTL) estendido de **720 horas (30 dias)**.
    
3. **Abstração via API Key:** Criamos uma "chave de fachada" no Swagger chamada `Fiqueok-Security-Token-2026`. Isso separa a chave que o usuário usa da chave real que o sistema usa internamente.
    
4. **Persistência e Hardening:** Salvamos o token no diretório `/var/lib/shadow-api/` com permissões restritas (`chmod 600`) para que apenas o sistema possa lê-lo.
    

---

## 3. Anatomia do Token do Vault

- **Token (O Segredo):** `<REDACTED_SECRET><REDACTED_SECRET>VHJKUDA3aXZPSGt2NEhtUzVnSmQ`
    
    - _Para que serve:_ É a credencial mestre para a API. Sem ele, o API Proxy não consegue buscar informações no Vault.
        
- **Token Accessor:** `h9LEIdhrKf2enoUbFMAh42XA`
    
    - _Para que serve:_ É o "ID" público do token. Você usa o Accessor para renovar ou revogar o token sem precisar ver ou digitar a chave secreta acima.
        
- **TTL (Time To Live):** 720h (30 dias).
    

---

## 4. Quando devo usar este Token novamente?

Você precisará interagir com este token ou com o processo de geração nos seguintes casos:

1. **Expiração (Daqui a 30 dias):** O token deixará de funcionar. Você deverá gerar um novo ou renovar o atual usando o `accessor`.
    
2. **Falha na API (Status 403/401):** Se o Swagger retornar erro de autorização, o primeiro passo do troubleshooting é verificar se o token ainda é válido com o comando `vault token lookup`.
    
3. **Reinstalação do Serviço:** Se você recriar o container ou o servidor da Shadow-API, precisará reinjetar este token no caminho `/var/lib/shadow-api/vault_token`.
    

---

## 5. Checklist de Manutenção (Comandos Rápidos)

### Verificar se o Token ainda vale:

Bash

```
VAULT_TOKEN="[COLE_O_TOKEN_AQUI]" vault token lookup
```

### Persistir o Token no Servidor:

Bash

```
echo "<REDACTED_SECRET><REDACTED_SECRET>VHJKUDA3aXZPSGt2NEhtUzVnSmQ" | sudo tee /var/lib/shadow-api/vault_token
sudo chmod 600 /var/lib/shadow-api/vault_token
```

### Revogar o Token (Se houver vazamento):

Bash

```
vault token revoke -accessor h9LEIdhrKf2enoUbFMAh42XA
```

---

## 6. Visão de Auditoria e Riscos

- **Segregação de Funções:** O uso do `display-name="svc-shadow-api"` permite rastrear exatamente qual serviço está fazendo chamadas ao Vault.
    
- **Princípio do Menor Privilégio:** O token está amarrado a uma política específica. Mesmo se este token vazar, o invasor não terá acesso total ao Vault (Root), apenas ao que o Proxy precisa.
    
- **Hardening Local:** O armazenamento em `/var/lib/` com permissão `600` protege contra usuários não-root que tentem ler o segredo dentro do servidor Linux.
    

---

**Data de Criação:** 2026-04-17 **Projeto:** PRJ005 - IGA Greenfield **Responsável:** Paulo - IAM & Security Specialist
