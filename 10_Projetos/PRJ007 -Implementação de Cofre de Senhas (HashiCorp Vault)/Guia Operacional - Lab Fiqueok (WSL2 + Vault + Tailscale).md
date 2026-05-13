

### 1. Acesso e Navegação (WSL2)

- **Entrar na máquina:** No PowerShell do Windows, digite: `wsl -d Ubuntu-22.04 -u paulo`
    
- **Sair da máquina:** Digite `exit` ou `Ctrl + D`.
    
    - _Nota de Auditoria:_ Sair do terminal (`exit`) **não** desliga o Linux. Ele continua rodando em background até que o Windows seja reiniciado ou você force o desligamento com `wsl --shutdown`.
        

### 2. Gestão do Tailscale (Conectividade)

O Tailscale no WSL2 (modo _userspace_) se comporta de forma diferente de um serviço nativo:

- **Persistência:** Ele sobrevive ao `exit` do terminal porque o processo `tailscaled` fica atachado à instância do WSL ativa.
    
- **Como validar se está rodando:** `tailscale status`
    
- **Como iniciar (caso tenha caído após reboot do Windows):** `sudo tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &` _(O `&` no final é vital para liberar o seu terminal)._
    

### 3. Estado do Cofre (Sealed vs. Unsealed)

O Vault é projetado para **não confiar no disco**. Se a luz cair ou o serviço reiniciar, ele "se tranca" (Sealed).

- **Sealed (Lacrado):** O Vault está ligado, mas os dados estão criptografados. A API Serverless **falhará** (Erro 503).
    
- **Unsealed (Aberto):** Estado operacional. Os dados estão acessíveis na memória RAM.
    
- **O que muda o estado?**
    
    1. Reiniciar o serviço (`systemctl restart vault`).
        
    2. Reiniciar o computador.
        
    3. Comando manual de selagem (`vault operator seal`).
        
- **O que fazer?** Sempre que o status for `Sealed: true`, execute o rito de unseal com 3 das suas 5 chaves.
    

### 4. Procedimento de Emergência: Reset de Root Token

Se você perder o Token de Root mas ainda tiver as **Chaves de Unseal** (as 5 chaves), você pode gerar um novo Token sem perder os dados:

1. **Inicie a geração:** `vault operator generate-root -init` _Isso retornará um **Nonce** e um **OTP**._
    
2. **Insira suas chaves de unseal (repetir 3 vezes):** `vault operator generate-root` _(Insira a chave quando solicitado)._
    
3. **Finalização:** Após a 3ª chave, o Vault entregará um Token codificado. Use o **OTP** gerado no passo 1 para decodificá-lo e obter seu novo `hvs.xxxx` Root Token.