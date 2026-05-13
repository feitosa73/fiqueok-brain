

**Projeto:** PRJ002 - Infraestrutura Fiqueok **Solicitante:** Paulo Feitosa (CISO/Arquiteto) **Data Planejada:** 22/12/2025 **Risco:** Baixo (Alteração lógica, sem impacto em serviço) **Status:** ⏳ Aguardando Aprovação

---

## 1. Objetivo

Implementar a hierarquia lógica de Unidades Organizacionais (OUs) no Active Directory `corp.fiqueok.com.br`. Esta estrutura servirá de base para a delegação de permissões (RBAC), aplicação de Políticas de Grupo (GPO) e segregação de contas privilegiadas (Tier Model), conforme definido na **ARQ-002**.

## 2. Escopo Técnico

A mudança consiste na criação de uma árvore de diretórios isolada da estrutura padrão do Windows:

- **Raiz de Gestão:** `OU=Fiqueok_Corp` (Com bloqueio de herança de GPO ativado para evitar poluição de políticas padrão).
    
- **Tier 0 (Administrativo):** `OU=00_Admins` (Exclusiva para Admin do Domínio e Break-glass).
    
- **Serviços:** `OU=01_Service_Accounts` (Contas de serviço, gMSA).
    
- **Segurança:** `OU=02_Security_Groups` (Grupos RBAC, Roles, ACLs).
    
- **Ativos:** `OU=03_Resources` (Subdividida em `Servers` e `Workstations`).
    
- **Pessoas:** `OU=04_People` (Subdividida por departamentos: Security, Cloud_Infra, etc.).
    

## 3. Justificativa

- **Conformidade ISO 27001 (A.9.4.1):** Limitar o acesso à informação e aos recursos de processamento de informações.
    
- **Segurança (Tier Model):** Impede que políticas aplicadas a estações de trabalho afetem servidores críticos e vice-versa.
    
- **Organização:** Facilita a automação de processos de _Onboarding_ e _Offboarding_.
    

## 4. Plano de Execução (PowerShell)

Utilização do cmdlet `New-ADOrganizationalUnit` para criar a estrutura em lote, garantindo padronização de nomes e proteção contra exclusão acidental.

## 5. Plano de Rollback

Caso a estrutura seja criada incorretamente (ex: erro de digitação nos nomes), o rollback consiste na remoção recursiva da OU raiz:

1. Remover a proteção contra exclusão acidental da OU `Fiqueok_Corp`.
    
2. Executar `Remove-ADOrganizationalUnit -Identity "OU=Fiqueok_Corp..." -Recursive`.