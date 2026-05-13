# 

**Projeto:** PRJ002 - Infraestrutura Fiqueok **Solicitante:** Paulo Feitosa (CISO/Arquiteto) **Data Planejada:** 22/12/2025 **Risco:** Alto (Definição de Raiz de Confiança) **Status:** ⏳ Aguardando Aprovação

---

## 1. Objetivo

Promover o servidor `ID-P-01` à função de **Controlador de Domínio (Domain Controller)**, estabelecendo a floresta `corp.fiqueok.com.br`. Isso criará a base centralizada de Autenticação e Autorização (IAM) da Fiqueok Consultoria.

## 2. Escopo Técnico

- **Instalação de Roles:** `AD-Domain-Services`, `DNS`, `GPMC`.
    
- **Definição da Floresta:**
    
    - _Root Domain:_ `corp.fiqueok.com.br`
        
    - _NetBIOS:_ `FIQUEOK`
        
    - _Functional Level:_ Windows Server 2016 (Mínimo para compatibilidade futura).
        
- **Recuperação:** Definição da senha DSRM (Directory Services Restore Mode).
    

## 3. Justificativa

Necessário para habilitar o RBAC (Controle de Acesso Baseado em Função), Políticas de Grupo (GPO) e centralização de identidades, substituindo contas locais isoladas.

## 4. Plano de Execução (PowerShell)

A execução será via IaC (Infrastructure as Code) para garantir repetibilidade:

1. Instalação dos binários do AD DS.
    
2. Execução do `Install-ADDSForest`.
    
3. Validação de DNS e replicação local.
    

## 5. Plano de Rollback

Em caso de falha crítica na promoção (ex: corrupção de banco de dados NTDS):

1. Desligar e excluir a VM `ID-P-01`.
    
2. Executar novamente o _Script 2_ (Provisionamento de VM) para recriar o servidor limpo.
    
3. Não há rollback parcial para falha de promoção de floresta; a reinstalação do OS é o caminho mais seguro.