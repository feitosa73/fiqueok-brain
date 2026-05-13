---
id_mudanca: GMUD-003
titulo: Hardening de RPC - Bloqueio de Sessão Nula
solicitante: GRC (Via RNC002)
responsavel_execucao: SysAdmin
data_planejada: 2025-12-19
status: 🔵 Planejada
tags: #GMUD #Hardening #WindowsServer #ActiveDirectory
---

# 🛠️ GMUD-003: Bloqueio de Enumeração Anônima (RPC)

## 1. Objetivo
Impedir que atacantes não autenticados listem usuários e grupos do domínio através da exploração de "Null Sessions" no protocolo RPC (Porta 135).

## 2. Escopo
* **Ativo Alvo:** DC01 (Domain Controller)
* **IP:** 192.168.56.10
* **Impacto:** Nenhum impacto para clientes autenticados no domínio. Pode bloquear scanners de rede legados.

## 3. Plano de Execução (Powershell)
1.  Acessar o DC01 via Console (VirtualBox).
2.  Abrir o PowerShell como Administrador.
3.  **Verificar status atual:**
    `Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Lsa -Name RestrictAnonymous`
    *(Se retornar 0, está vulnerável)*.
4.  **Aplicar Correção (Hardening):**
    `Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Lsa -Name RestrictAnonymous -Value 1`
5.  **Reiniciar Serviço Server (Opcional, mas recomendado reiniciar o servidor):**
    `Restart-Computer`

## 4. Validação
Após o reboot, o DefectDojo/OpenVAS não deve mais conseguir listar usuários anonimamente.

### 🧪 Plano de Validação Robusto (Adicione à GMUD)

#### 1. Teste de Regressão (Garantir que não quebramos o DC)

_Objetivo: Confirmar que as funções vitais do Controlador de Domínio continuam operando._

Execute estes testes **após** o reinício, logado como Administrator no DC01:

- **Teste A: Saúde do AD (DCDiag)** O `dcdiag` é o estetoscópio do Windows Server. Ele verifica DNS, Replicação e Serviços.
    
    PowerShell
    
    ```
    dcdiag /q
    ```
    
    - _Resultado Esperado:_ Nenhum erro fatal. (Alguns erros de log de evento são normais em lab, mas falhas em `NetLogons` ou `Advertising` são críticas).
        
- **Teste B: Acesso a Políticas (SYSVOL)** Se o bloqueio for agressivo demais, o servidor pode não conseguir ler suas próprias políticas de grupo.
    
    PowerShell
    
    ```
    gpupdate /force
    ```
    
    - _Resultado Esperado:_ "Computer Policy update has completed successfully."
        
- **Teste C: Login e Autenticação**
    
    - _Ação:_ Faça Logoff e Logon novamente.
        
    - _Resultado Esperado:_ O login deve ocorrer normalmente, sem demoras excessivas ou erros de "O sistema não pode logar você".
        

---

#### 2. Teste de Eficácia (Garantir que a vulnerabilidade sumiu)

_Objetivo: Tentar explorar a falha novamente (Teste Negativo)._

Vamos simular o ataque de "Sessão Nula" localmente ou a partir de outra máquina (se tivermos conectividade).

- **Teste D: Tentativa de Conexão Nula (Null Session)** Tente conectar no compartilhamento IPC$ sem usuário e senha.
    
    PowerShell
    
    ```
    net use \\192.168.56.10\ipc$ "" /u:""
    ```
    
    - _Resultado Esperado (Com Correção):_ **Erro de Acesso Negado (System error 5 has occurred)** ou falha de logon.
        
    - _Nota:_ Se retornar "The command completed successfully", **a correção FALHOU** e a vulnerabilidade persiste.


### 5. Plano de Rollback (Adicione à GMUD-003)

Se após o reinício o DC01 apresentar falhas críticas (ex: não aceitar logons de domínio, serviço netlogon falhar), este é o procedimento de reversão:

1. **Acesso de Emergência:** Logar no console local do VirtualBox como Administrator local (`.\Administrator`).
    
2. **Comando de Reversão (PowerShell):**
    
    PowerShell
    
    ```
    Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Lsa -Name RestrictAnonymous -Value 0
    ```
    
3. **Validação:** Confirme se voltou para 0:
    
    PowerShell
    
    ```
    Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Lsa -Name RestrictAnonymous
    ```
    
4. **Aplicação:**
    
    PowerShell
    
    ```
    Restart-Computer
    ```
