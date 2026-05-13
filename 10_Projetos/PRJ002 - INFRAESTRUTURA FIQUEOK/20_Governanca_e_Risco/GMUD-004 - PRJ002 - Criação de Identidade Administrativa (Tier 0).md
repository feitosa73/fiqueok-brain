# GMUD-2025-04: Criação de Identidade Administrativa (Tier 0)

**Projeto:** PRJ002 - Infraestrutura Fiqueok **Solicitante:** Paulo Feitosa (CISO/Arquiteto) **Data Planejada:** 22/12/2025 **Risco:** Médio (Criação de credencial de alto privilégio) **Status:** ⏳ Aguardando Aprovação

---

## 1. Objetivo

Provisionar a primeira identidade nominal com privilégios administrativos (Tier 0) na infraestrutura. Esta conta substituirá o uso da conta `Administrator` (Built-in) para tarefas diárias de gestão do Active Directory, garantindo rastreabilidade e conformidade com o princípio de atribuição única de credenciais.

## 2. Escopo Técnico

- **Identidade Alvo:** `paulo.feitosa.adm` (ou similar, conforme padrão de nomenclatura).
    
- **Localização:** `OU=00_Admins,OU=Fiqueok_Corp,DC=corp...`
    
- **Grupos de Acesso:** Adição aos grupos `Domain Admins`, `Enterprise Admins` e `Schema Admins`.
    
- **Segurança:** Senha definida como "Nunca Expira" (padrão para Service/Admin accounts em Lab) mas com complexidade forçada.
    

## 3. Justificativa

- **Conformidade ISO 27001 (A.9.2.1):** Registro e cancelamento de usuários (garantir identificação única).
    
- **Segurança Operacional:** Permite a futura desativação ou monitoramento intensivo da conta `Administrator` padrão, reduzindo a superfície de ataque para força bruta.
    

## 4. Plano de Execução (PowerShell)

Utilização do cmdlet `New-ADUser` para criação da conta já dentro da OU correta, seguido de `Add-ADGroupMember` para elevação de privilégios.

## 5. Plano de Rollback

Em caso de erro na criação ou perda da senha inicial:

1. Utilizar a conta `Administrator` (que ainda estará ativa) para resetar a senha ou remover o objeto criado via `Remove-ADUser`.
