# 

**Projeto:** Fiqueok Living Lab – PRJ002 (IGA Lifecycle) **Título:** Implementação de Provisionamento Outbound e Governança de Esquema AD

## 1. Identificação e Metadados

- **ID da Mudança:** GMUD-016 (Sucessora da GMUD-015-FIX-NET)
    
- **Data de Execução:** 30/12/2025 (16:40 – 18:00 BRT)
    
- **Responsável:** Paulo Feitosa (Owner/CISO)
    
- **Status Final:** ✅ **ENCERRADA COM SUCESSO**
    
- **Ambiente:** IGA-P-01 (midPoint 4.10) ↔ ID-P-01 (Windows Server 2022)
    

---

## 2. Sumário da Execução

A mudança visava realizar o primeiro provisionamento bem-sucedido de uma identidade humana (Paulo Lima - ID 001) para o Active Directory. Após a estabilização da rede na GMUD-015, o foco foi a configuração lógica de atributos de segurança.

### ❌ Desafios e Bloqueadores Detectados

1. **Erro de Atribuição:** O recurso `AD-Fiqueok` não permitia vinculação inicial por falta de flag de "Default Account".
    
2. **Falha de Integridade (`ResourceObject[null]`):** O midPoint tentava criar o objeto sem atributos mandatórios, resultando em erro fatal.
    
3. **Invisibilidade de Atributos (Schema):** O atributo `sAMAccountName` não era localizado devido ao uso da classe genérica `account` em vez da classe específica `ri:user`.
    

---

## 3. Ações Técnicas Realizadas (Step-by-Step)

### Fase I: Materialização do Esquema (Schema Handling)

- **Readequação de Classe:** Alteração da classe de objeto do recurso de `account` para **`user`** (necessário para atributos específicos de AD).
    
- **Schema Refresh:** Execução do comando **"Recarregar esquema"** para consolidar o dicionário de atributos do Windows Server no midPoint.
    

### Fase II: Configuração de Mapeamentos Outbound

Implementamos os três pilares obrigatórios para a criação de contas em AD:

1. **Identificação (DN):** Criação de script Groovy para derivar o _Distinguished Name_ dinamicamente: `'CN=' + name + ',OU=04_People,OU=Fiqueok_Corp,DC=corp,DC=fiqueok,DC=com,DC=br'`.
    
2. **Login (`sAMAccountName`):** Mapeamento direto do atributo `name` (ID 001) para o campo de login do Windows.
    
3. **Ativação (`userAccountControl`):** Definição da constante **`512`** para garantir que a conta nasça habilitada (Enabled).
    

---

## 4. Análise de Auditoria e Riscos (ISO 27001)

- **Controle A.9.2.2 (Provisionamento):** A automação via Script de DN garante que as identidades sejam alocadas na OU correta (`04_People`), mitigando o risco de contas órfãs ou em locais indevidos.
    
- **Controle A.12.1.2 (Gestão de Mudanças):** O registro desta GMUD pós-incidente demonstra maturidade na rastreabilidade de configurações de infraestrutura crítica.
    
- **Integridade de Dados:** A resolução do erro `ResourceObject[null]` assegura que o provisionamento respeite o esquema mínimo exigido pelo Target AD.
    

---

## 5. Resultados e Métricas de Sucesso

- **Conectividade:** 100% estável via porta 389/LDAP.
    
- **Provisionamento:** Usuário **001 (Paulo Lima)** criado com sucesso na OU correta do AD.
    
- **Status midPoint:** Ícone de projeção do AD em **Verde** no perfil do usuário.
    

---

## 6. Aprovações

- **Owner/CISO:** Paulo Feitosa
    
- **Parecer:** Mudança concluída. Ambiente de Laboratório 2.0 funcional e pronto para a Fase de Governança de Senhas.
