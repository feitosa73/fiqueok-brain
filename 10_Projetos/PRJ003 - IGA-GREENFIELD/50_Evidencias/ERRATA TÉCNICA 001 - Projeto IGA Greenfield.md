# 

**Data:** 19/01/2026

**Documentos Afetados:** GMUD-008 (v1.1/v1.2) e POP-IGA-001 (v2.0)

**Status:** Vigente (Aguardando atualização de versão)

## 1. Contexto

Durante a execução controlada do deploy automatizado, foram identificadas divergências técnicas entre o roteiro planejado e o comportamento do ambiente real (Ubuntu 24.04 e PowerShell Host). Esta errata visa corrigir esses pontos para garantir a reprodutibilidade e a segurança do processo.

## 2. Inconformidades e Correções

### 2.1. Localização do Arquivo de Rede (Netplan)

- **Onde ocorre:** POP-IGA-001 v2.0 e GMUD-008 v1.2 (Item 3.2).
    
- **Problema:** O arquivo `00-installer-config.yaml` pode não existir ou ter nomes variados conforme a instalação.
    
- **Correção:** Antes de editar a configuração de IP estático, deve-se listar o conteúdo do diretório com `ls /etc/netplan/` e editar o arquivo `.yaml` retornado pelo sistema.
    

### 2.2. Erro de Sintaxe no PowerShell (ParserError)

- **Onde ocorre:** Script de automação `GMUD-008-Deploy-v1.1.ps1` (Linha 142).
    
- **Problema:** O caractere `:` após a variável `$VM_USER` é interpretado pelo PowerShell como um drive de disco local, interrompendo a execução.
    
- **Correção:** Utilizar chaves para delimitar o nome da variável.
    
    - **Incorreto:** `sudo chown -R $VM_USER:$VM_USER $BASE_DIR`
        
    - **Correto:** `sudo chown -R ${VM_USER}:${VM_USER} $BASE_DIR`
        

### 2.3. Variáveis Obrigatórias no Arquivo `.env`

- **Onde ocorre:** GMUD-008 v1.1/v1.2 (Item 4.1).
    
- **Problema:** A ausência das variáveis `VM_USER` e `MIDPOINT_ADMIN_PASSWORD` no arquivo local impede a validação inicial do script.
    
- **Correção:** O arquivo `.env` deve obrigatoriamente conter os campos:
    
    - `VM_IP`: Endereço fixado na Fase 1.
        
    - `VM_USER`: Usuário com permissão de sudoers.
        
    - `POSTGRES_PASSWORD`: Senha do banco de dados.
        
    - `MIDPOINT_ADMIN_PASSWORD`: Senha inicial do administrador.
        

## 3. Ações Imediatas para Execução

Para prosseguir com a implementação sem falhas, o executor deve:

1. Aplicar o **Hardening de Sudoers** na VM garantindo a whitelist de binários.
    
2. Corrigir a linha 142 do script de automação no Host Windows.
    
3. Executar `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process` no terminal do Windows antes de disparar o script.