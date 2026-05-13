# 

> **⚠️ Nota de GRC (ISO 27001 - Controle A.9.4.3):** O uso de senhas em texto puro neste documento é **PROVISÓRIO** e destinado apenas à fase de build. Assim que o componente de **Vault/PAM** for implementado, este documento deve ser atualizado para referenciar apenas o cofre de senhas.

## 1. Nível 0: Host de Virtualização (Hyper-V)

O ponto de partida para qualquer atividade de laboratório.

- **Acesso:** Console local do Windows Pro/Server.
    
- **Ação:** Abrir o "Gerenciador do Hyper-V" (virtmgmt.msc).
    
- **Checklist de Power-On:**
    
    1. [ ] **ID-P-01** (Domain Controller) - _Deve subir primeiro para garantir serviços de DNS/Auth._
        
    2. [ ] **IGA-P-01** (Ubuntu/Docker Host).
        

---

## 2. Nível 1: Infraestrutura de Identidade (AD & Linux)

### 🖥️ Máquina: ID-P-01 (Domain Controller)

- **Função:** Servidor Central de Autenticação (`corp.fiqueok.com.br`).
    
- **Método de Conexão:** RDP ou Console Hyper-V.
    
- **Usuário:** `CORP\paulo.feitosa (ou seu usuário de admin).
    
- **Senha:** ******
    
- **IP:** xxx.xxx.xxx.xxx
    

### 🐧 Máquina: IGA-P-01 (Docker Host)

- **Função:** Hospedagem das stacks midPoint e OrangeHRM.
    
- **IP de Acesso:** `xxx.xxx.xxx.xxx`.
    
- **Método de Conexão:** SSH via Terminal ou PowerShell.
    
    - `ssh paulo@xxx.xxx.xxx.xxx`
        
- **Senha:** ******
    

---

## 3. Nível 2: Aplicações de Identidade (Acesso Web)

|**Recurso**|**URL de Acesso**|**Usuário Padrão**|**Senha Provisória**|
|---|---|---|---|
|**midPoint 4.10**|`http://xxx.xxx.xxx.xxx:8080`|`administrator`|`[COLOCAR_SENHA]`|
|**OrangeHRM**|`http://xxx.xxx.xxx.xxx:8081`|`admin`|`[COLOCAR_SENHA]`|

> Dica Técnica: Se o midPoint não carregar, verifique o status dos containers via SSH no IGA-P-01:
> 
> docker ps ou docker logs -f midpoint-server

---

## 4. Nível 3: Integração de Dados (Banco de Dados)

Acesso necessário para validação da GMUD-010 (Integração IGA-HRM).

- **Recurso:** MariaDB 11.4 (OrangeHRM DB).
    
- **Host:** `xxx.xxx.xxx.xxx` | **Porta:** `3306`.
    
- **Conta de Serviço (Read-Only):** `orangehrm_ro`.

