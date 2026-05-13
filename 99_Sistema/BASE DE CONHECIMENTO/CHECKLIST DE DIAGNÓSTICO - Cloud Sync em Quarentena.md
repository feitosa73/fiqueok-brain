# 🧭 

## 🟦 1. **Verificar o estado dos agentes do Cloud Sync**

🔹 Os agentes estão **online**? 🔹 Estão **atualizados**? 🔹 O serviço “Microsoft Entra Connect Provisioning Agent” está rodando? 🔹 Há múltiplos agentes instalados? Todos estão saudáveis?

**Sinais de problema:**

- Agente offline
    
- Agente desatualizado
    
- Falha de comunicação com o Entra ID
    

## 🟩 2. **Checar permissões no Active Directory local**

🔹 A conta usada pelo agente tem permissão para:

- Ler usuários
    
- Ler grupos
    
- Ler OUs configuradas
    
- Ler atributos necessários (UPN, proxyAddress, etc.)
    

🔹 A conta perdeu permissão após alguma mudança de GPO?

**Sinais de problema:**

- Erros de “insufficient privileges”
    
- O agente não consegue ler objetos configurados
    

## 🟧 3. **Validar o escopo de sincronização**

🔹 O Cloud Sync está sincronizando **apenas** usuários e grupos? 🔹 O AADC está sincronizando **apenas** devices? 🔹 Há OUs sobrepostas entre Cloud Sync e AADC?

**Sinais de conflito:**

- Mesma OU sincronizada pelos dois
    
- Mesmo usuário sincronizado pelos dois
    
- Mesmo grupo sincronizado pelos dois
    

👉 **Esse é o ponto onde o AADC pode causar problemas indiretamente.**

## 🟥 4. **Procurar conflitos de atributos (causa mais comum de quarentena)**

Verifique se há conflitos nos atributos:

- `userPrincipalName`
    
- `proxyAddresses`
    
- `mail`
    
- `sourceAnchor`
    
- `objectGUID`
    
- `sAMAccountName`
    

**Sinais de conflito:**

- Dois objetos com o mesmo UPN
    
- Dois objetos com o mesmo proxyAddress
    
- Objeto sincronizado por AADC e Cloud Sync ao mesmo tempo
    

## 🟪 5. **Verificar o Source of Authority (SOA)**

🔹 O objeto está marcado como vindo do AADC ou do Cloud Sync? 🔹 O objeto mudou de SOA recentemente? 🔹 Há objetos com SOA inconsistente?

**Sinais de problema:**

- Objeto sincronizado por AADC, mas Cloud Sync tenta sobrescrever
    
- Objeto sincronizado por Cloud Sync, mas AADC tenta sobrescrever
    

## 🟫 6. **Checar logs de Provisioning**

No portal do Entra ID:

- Provisioning → Logs
    
- Filtrar por “Errors”
    
- Filtrar por “Quarantine”
    

Procure por:

- Duplicate attribute
    
- Permission denied
    
- Unable to read object
    
- Unable to write object
    
- Invalid attribute value
    

## 🟨 7. **Verificar se o AADC está saudável**

Mesmo que ele não cause quarentena diretamente, ele pode gerar conflitos.

Verifique:

- Última sincronização
    
- Health status
    
- Escopo de OUs
    
- Se está sincronizando usuários por engano
    
- Se o writeback está funcionando
    

**Sinais de problema:**

- AADC sincronizando objetos que deveriam ser do Cloud Sync
    
- AADC com escopo mal configurado
    

## 🟫 8. **Confirmar se há coexistência suportada**

Coexistência suportada:

- Cloud Sync → usuários e grupos
    
- AADC → devices
    

Coexistência **não** suportada:

- Ambos sincronizando os mesmos usuários
    
- Ambos sincronizando os mesmos grupos
    
- Ambos sincronizando as mesmas OUs
    

# 🎯 **Resumo rápido**

Se o Cloud Sync entrou em quarentena, as causas mais prováveis são:

1. **Conflito de atributos** (mais comum)
    
2. **Escopo sobreposto com o AADC**
    
3. **Permissões insuficientes no AD local**
    
4. **Agente offline ou desatualizado**
    
5. **Objeto sincronizado por ambos os métodos**
    

E sim — **o AADC pode causar conflitos que levam o Cloud Sync à quarentena**, mesmo sem ser a causa direta.
