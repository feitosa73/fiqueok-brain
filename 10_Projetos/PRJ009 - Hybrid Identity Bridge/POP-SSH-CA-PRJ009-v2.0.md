# POP-SSH-CA-PRJ009-v2.0
**Título:** Acesso SSH com Certificados Efêmeros via SSH CA  
**Projeto:** PRJ009 – Living Lab Fiqueok  
**Data:** 28/02/2026  
**Versão:** 2.0 — Revisado com evidências reais do Lab + Recomendações de Arquitetura  
**Ferramenta de referência:** HashiCorp Vault (exemplo do lab) — agnóstico para outros SSH CAs  

---

## Nota do Autor — Por que este POP existe

> Este documento nasceu de uma dor real: no Living Lab PRJ009, a VM Ubuntu 22.04 hospedada no Azure não suportava nenhuma das soluções "nativas" para eliminar chaves SSH RSA locais.
>
> - **Azure AD Login for Linux (AADSSHLoginForLinux):** não suporta Ubuntu 22.04.
> - **Azure Arc:** bloqueado para VMs já hospedadas no Azure (*"cannot install on an Azure Virtual Machine"*).
> - **AuthD (Canonical):** viável para Ubuntu 20.04+, mas exige broker configurado e não estava disponível no ambiente do lab.
>
> A solução encontrada foi **SSH CA com certificados efêmeros via HashiCorp Vault** — que funciona em qualquer distro Linux, qualquer provedor cloud e qualquer versão do OpenSSH >= 6.9.
>
> **Lição aprendida:** antes de escolher a ferramenta, mapeie as restrições do seu ambiente. O caminho "nativo" nem sempre está disponível.

---

## 1. Finalidade

Definir o procedimento padrão para:

- Configurar uma **Autoridade Certificadora SSH (SSH CA)** — usando HashiCorp Vault como exemplo — para emitir certificados de curta duração em substituição a chaves RSA estáticas.
- Implementar **JML (Joiner, Mover, Leaver)** de usuários SSH de forma centralizada, auditável e sem contas órfãs.
- Documentar **evidências reais** coletadas no Living Lab PRJ009 como prova de conceito.

**Por que SSH CA resolve o problema das chaves RSA locais:**

| Problema (RSA local) | Solução (SSH CA) |
|---|---|
| `authorized_keys` persiste após demissão | Certificado expira automaticamente (TTL) |
| Sem auditoria de quem usou qual chave | Vault registra cada assinatura no audit log |
| Chave privada copiável para qualquer máquina | Certificado vinculado à identidade do emissor |
| Revogação manual e sujeita a erro | Revogação imediata via token do Vault |
| Sem MFA nativo no SSH por chave | Token do Vault pode exigir MFA antes da assinatura |

---

## 2. Topologia do Lab PRJ009

```
[Windows — Desktop]          [vault-gf-01]              [fiqueok-prj009-gtw-canada]
 xxx.xxx.xxx.xxx           ←→    xxx.xxx.xxx.xxx         ←→      xxx.xxx.xxx.xxx
 (cliente SSH)               Ubuntu 24.04                   Ubuntu 22.04
 ssh-keygen aqui             HashiCorp Vault 1.21.3         Servidor alvo
                             Tailscale Mesh                  Tailscale Mesh
                             eth0: 172.20.239.100            eth0: 10.0.0.4
```

> **Rede overlay:** Toda a comunicação ocorre via **Tailscale Mesh** (range `xxx.xxx.xxx.xxx/10`).  
> A porta 22 da VM alvo **não está exposta à internet** — acesso somente via IP Tailscale.  
> A porta 8200 (Vault) está liberada no NSG apenas para o range Tailscale.

---

## 3. RACI

| Atividade | R (Responsável) | A (Aprovador) | C (Consultado) | I (Informado) |
|---|---|---|---|---|
| Configurar SSH CA (Vault/equivalente) | Vault/IAM Admin | CISO/Lab Owner | SecOps | DevOps/Colaboradores |
| Configurar SSH na VM alvo | Server Admin | Lab Owner | Vault Admin | SecOps |
| Onboarding (JOINER) de colaboradores | Vault/IAM Admin | Lab Owner | RH | Colaborador |
| Emissão de certificado SSH | Colaborador | — | — | — |
| Monitorar logs (Vault + VM) | SecOps | CISO/Lab Owner | Auditor | — |
| LEAVER — revogar token/CA | Vault/IAM Admin | CISO/Lab Owner | RH | SecOps, Auditor |
| Backup da CA pública | Server Admin | Lab Owner | Vault Admin | SecOps |

---

## 4. Visão Geral do Fluxo

```
JOINER:
  1. Usuário gera par de chaves SSH local
  2. Envia chave pública ao Vault (CLI ou UI)
  3. Vault assina a chave → emite certificado com TTL (ex: 30 min)
  4. Usuário conecta com chave + certificado
  5. VM valida o certificado contra a CA pública (TrustedUserCAKeys)

AUDITORIA:
  Vault audit log ←→ VM auth.log (correlação por Key ID / serial)

LEAVER:
  Revogar token do colaborador → sem novos certificados
  TTL curto garante expiração automática do último emitido
  Emergência: rotacionar CA → todos os certificados antigos invalidados
```

---

## 5. Pré-requisitos

### 5.1 Vault

- Vault instalado, inicializado e **unsealed** (Shamir, 3 de 5 chaves no lab).
- Vault acessível via Tailscale: `http://[VAULT_TAILSCALE_IP]:8200`.
- `VAULT_ADDR` configurado: `export VAULT_ADDR="http://127.0.0.1:8200"` (no servidor Vault).

> **Lição do Lab — Vault sealed após reinício:**  
> O Vault usa **Integrated Storage (Raft)** e requer unseal manual após cada reinício.  
> No PRJ009, o processo levou 3 rounds de `vault operator unseal` (threshold 3/5).  
> **Recomendação:** configurar [Auto Unseal](https://developer.hashicorp.com/vault/docs/concepts/seal#auto-unseal) via [Azure Key Vault / AWS KMS / GCP KMS] em ambientes de produção.

```bash
# Verificar status antes de qualquer operação
vault status

# Se Sealed = true, realizar unseal (repetir até Sealed = false)
vault operator unseal   # Informar chave 1
vault operator unseal   # Informar chave 2
vault operator unseal   # Informar chave 3 → Sealed: false
```

### 5.2 VM Alvo

- OpenSSH >= 6.9 (Ubuntu 22.04 inclui versão compatível).
- Conectividade com o Vault via Tailscale.
- Usuário Linux alvo criado: `[USERNAME_ALVO]` (ex: `fiqueok` no lab).

### 5.3 NSG / Firewall

- Porta 8200 (Vault) liberada **apenas** para o range da rede overlay (`xxx.xxx.xxx.xxx/10` para Tailscale).
- Porta 22 **não exposta** à internet — acesso somente via IP da rede overlay.

```bash
# Exemplo: liberar porta 8200 somente para rede Tailscale (Azure CLI)
az network nsg rule create \
  --resource-group "[RESOURCE_GROUP]" \
  --nsg-name "[NSG_NAME]" \
  --name "AllowVaultInbound" \
  --priority 900 \
  --source-address-prefixes "xxx.xxx.xxx.xxx/10" \
  --destination-port-ranges 8200 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --description "Vault acessivel somente via rede overlay (Tailscale/WireGuard)"
```

> **Lição do Lab — Nome do NSG:**  
> O nome do NSG no Azure pode não seguir a convenção esperada.  
> Sempre confirme antes: `az network nsg list --resource-group "[RG]" --query "[].name" -o tsv`

---

## 6. Configuração da SSH CA no Vault

### 6.1 Habilitar SSH Secrets Engine

```bash
# No servidor Vault — com token root ou policy adequada
export VAULT_ADDR="http://127.0.0.1:8200"

# Verificar se já está habilitado (idempotente)
vault secrets list | grep ssh-client-signer

# Habilitar se não existir
vault secrets enable -path=ssh-client-signer ssh

# Gerar par de chaves da CA
vault write ssh-client-signer/config/ca generate_signing_key=true

# Obter e salvar a chave pública da CA (OBRIGATÓRIO — ver Seção 6.4)
vault read -field=public_key ssh-client-signer/config/ca
```

> **Saída esperada (exemplo do lab):**
> ```
> ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD...
> ```

### 6.2 Criar Role de Assinatura

> **Lição do Lab — `default_extensions` exige JSON válido:**  
> Tentativas com string simples (`"permit-pty,permit-port-forwarding"`) falharam com:  
> *"expected a map, got 'string'"*  
> A solução correta é usar um arquivo JSON.

```bash
# Criar arquivo JSON da role (método correto descoberto no lab)
cat > /tmp/role-[PROJETO].json <<'EOF'
{
  "key_type": "ca",
  "allow_user_certificates": true,
  "allowed_users": "[USERNAME_ALVO]",
  "ttl": "30m",
  "allow_extensions": true,
  "default_extensions": {
    "permit-pty": "",
    "permit-port-forwarding": ""
  },
  "key_id_format": "vault-{{token_display_name}}-{{public_key_fingerprint}}"
}
EOF

vault write ssh-client-signer/roles/[ROLE_NAME] @/tmp/role-[PROJETO].json
```

> **Por que `key_id_format` importa para auditoria:**  
> O campo `key_id_format` define o valor que aparece em `/var/log/auth.log` na VM.  
> Com o formato acima, o log mostrará algo como:  
> `ID vault-root-<REDACTED_SECRET>a28d1d0eeda1810788d37ad2`  
> Isso permite correlacionar diretamente o login SSH com a entrada no audit log do Vault.

### 6.3 Validar a Role

```bash
vault read ssh-client-signer/roles/[ROLE_NAME]
```

Verificar:
- `allow_user_certificates = true`
- `allowed_users = [USERNAME_ALVO]`
- `ttl = 30m`
- `default_extensions` com `permit-pty` e `permit-port-forwarding`
- `key_id_format` conforme definido

### 6.4 Backup da Chave Pública da CA

> **CRÍTICO — Não pule este passo:**  
> Se o Vault for reiniciado, recriado ou migrado, a CA **pode ser perdida**.  
> Guarde a chave pública em local seguro e documente o procedimento de restauração.

```bash
# Salvar chave pública da CA em arquivo
vault read -field=public_key ssh-client-signer/config/ca \
  > /tmp/vault-ca-public-key-[DATA].pub

# Validar que é uma única linha (requisito para trusted-user-ca-keys.pem)
wc -l /tmp/vault-ca-public-key-[DATA].pub
# Resultado esperado: 1

# Armazenar em local seguro (ex: [KV_NAME] ou repositório privado criptografado)
```

---

## 7. Configuração da VM Alvo

### 7.1 Instalar Chave Pública da CA

```bash
# Na VM alvo — como usuário com sudo
sudo tee /etc/ssh/trusted-user-ca-keys.pem > /dev/null << 'EOF'
[COLAR AQUI A SAÍDA DO COMANDO: vault read -field=public_key ssh-client-signer/config/ca]
EOF

# Validar: deve ser exatamente 1 linha
wc -l /etc/ssh/trusted-user-ca-keys.pem
# Esperado: 1 /etc/ssh/trusted-user-ca-keys.pem

sudo chmod 644 /etc/ssh/trusted-user-ca-keys.pem
```

> **ATENÇÃO:** O conteúdo deve ser **uma única linha** começando com `ssh-rsa` (ou `ecdsa-sha2-nistp256`, etc.).  
> Quebras de linha intermediárias ou espaços extras causarão falha silenciosa na autenticação.

### 7.2 Configurar sshd_config

```bash
# Adicionar no final do /etc/ssh/sshd_config (ou em /etc/ssh/sshd_config.d/vault-ca.conf)
sudo tee -a /etc/ssh/sshd_config > /dev/null <<'EOF'

# SSH CA — Vault PRJ009
TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem
PubkeyAuthentication yes
KbdInteractiveAuthentication no
UsePAM yes
EOF

# Reiniciar SSH
sudo systemctl restart sshd
```

> **Evidência do Lab (sshd_config final — TERMINAL-011):**
> ```
> ChallengeResponseAuthentication no
> PasswordAuthentication yes
> TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem
> ```

> **Recomendação pós-lab:**  
> Com a SSH CA funcionando, o próximo passo é desabilitar `PasswordAuthentication yes` → `no`  
> para eliminar completamente a autenticação por senha. Fazer em janela de manutenção com acesso console garantido.

---

## 8. JOINER — Onboarding de Colaborador

### 8.1 Opção A: Via CLI (Windows PowerShell — método do Lab)

```powershell
# Passo 1: Gerar par de chaves no cliente
# Recomendado: ed25519 (mais moderno e seguro que RSA 4096)
ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\id_ed25519_[PROJETO]"

# Alternativa RSA (compatibilidade com sistemas legados):
ssh-keygen -t rsa -b 4096 -f "$env:USERPROFILE\.ssh\id_rsa_[PROJETO]"
```

```bash
# Passo 2: Copiar chave pública para o servidor Vault
scp "$env:USERPROFILE\.ssh\id_ed25519_[PROJETO].pub" [VAULT_USER]@[VAULT_TAILSCALE_IP]:~/.ssh/

# Passo 3: No servidor Vault — assinar a chave
export VAULT_ADDR="http://127.0.0.1:8200"

vault write -field=signed_key ssh-client-signer/sign/[ROLE_NAME] \
    public_key=@$HOME/.ssh/id_ed25519_[PROJETO].pub \
    valid_principals="[USERNAME_ALVO]" \
    > $HOME/.ssh/id_ed25519_[PROJETO]-cert.pub

# Inspecionar o certificado gerado
ssh-keygen -L -f ~/.ssh/id_ed25519_[PROJETO]-cert.pub
```

> **Evidência do Lab (TERMINAL-009) — certificado inspecionado:**
> ```
> Type: ssh-rsa-cert-v01@openssh.com user certificate
> Signing CA: RSA SHA256:<REDACTED_SECRET>W60
> Key ID: "vault-root-<REDACTED_SECRET>6c56ee3446ba88a763f433b9"
> Valid: from 2026-02-28T01:40:43 to 2026-02-28T02:11:13
> Principals: fiqueok
> Extensions: permit-port-forwarding, permit-pty
> ```

```bash
# Passo 4: Copiar certificado de volta para o Windows
scp [VAULT_USER]@[VAULT_TAILSCALE_IP]:~/.ssh/id_ed25519_[PROJETO]-cert.pub \
    "$env:USERPROFILE\.ssh\id_ed25519_[PROJETO]-cert.pub"
```

```powershell
# Passo 5: Conectar na VM alvo com chave + certificado
ssh -i "$env:USERPROFILE\.ssh\id_ed25519_[PROJETO]" \
    -i "$env:USERPROFILE\.ssh\id_ed25519_[PROJETO]-cert.pub" \
    [USERNAME_ALVO]@[VM_TAILSCALE_IP]
```

> **Lição do Lab — `valid_principals` é obrigatório:**  
> Omitir o parâmetro `valid_principals` resulta em erro:  
> *"empty valid principals not allowed by role"*  
> Sempre informar o usuário Linux alvo explicitamente.

> **Lição do Lab — CLI `vault` não disponível no Windows:**  
> O binário `vault` não vem instalado no Windows por padrão.  
> Solução usada no lab: executar o comando de assinatura **no servidor Vault** (via SSH) e transferir o certificado de volta via `scp`.  
> **Recomendação:** instalar o [Vault CLI para Windows](https://developer.hashicorp.com/vault/install) ou usar a UI Web (Opção B abaixo).

---

### 8.2 Opção B: Via UI Web do Vault (Mac/Linux — método agnóstico)

```bash
# Passo 1: Gerar par de chaves no cliente (Mac/Linux)
# Recomendado: ed25519
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_[PROJETO] -N ""

# Alternativa RSA:
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_[PROJETO] -N ""
```

```bash
# Passo 2: Criar policy e token de escopo limitado (no servidor Vault)
cat > /tmp/policy-colaborador.hcl <<'EOF'
path "ssh-client-signer/sign/[ROLE_NAME]" {
  capabilities = ["update"]
}
EOF

vault policy write policy-colaborador-[PROJETO] /tmp/policy-colaborador.hcl

# Token com validade de 24h (renovável)
vault token create -policy=policy-colaborador-[PROJETO] -period=24h
# Anotar o token retornado (hvs.XXXXX...) e entregar ao colaborador de forma segura
```

```
Passo 3: Colaborador acessa a UI do Vault
  URL: http://[VAULT_TAILSCALE_IP]:8200
  Login: Token → colar o token recebido
  Navegação: Secrets Engines → ssh-client-signer → Roles → [ROLE_NAME] → Sign Key
  Campo "Public Key": colar conteúdo de ~/.ssh/id_ed25519_[PROJETO].pub
  Campo "Valid Principals": [USERNAME_ALVO]
  Clicar em "Sign" → copiar certificado → salvar como ~/.ssh/id_ed25519_[PROJETO]-cert.pub
```

```bash
# Passo 4: Conectar na VM alvo
chmod 600 ~/.ssh/id_ed25519_[PROJETO]*

ssh -i ~/.ssh/id_ed25519_[PROJETO] \
    -i ~/.ssh/id_ed25519_[PROJETO]-cert.pub \
    [USERNAME_ALVO]@[VM_TAILSCALE_IP]
```

---

## 9. Evidências de Auditoria

### 9.1 Habilitar Audit Log no Vault

```bash
sudo mkdir -p /var/log/vault
sudo chown vault:vault /var/log/vault

vault audit enable file file_path=/var/log/vault/audit.log
```

### 9.2 Coletar Evidências — Vault

```bash
sudo tail -n 30 /var/log/vault/audit.log | python3 -m json.tool 2>/dev/null \
  || sudo tail -n 30 /var/log/vault/audit.log
```

### 9.3 Coletar Evidências — VM Alvo

```bash
sudo tail -n 20 /var/log/auth.log
```

> **Evidência Real do Lab (TERMINAL-010 — auth.log da VM):**
> ```
> Feb 28 01:54:03 fiqueok-prj009-gtw-canada sshd[14916]: Accepted publickey for fiqueok
>   from xxx.xxx.xxx.xxx port 55514 ssh2: RSA-CERT
>   SHA256:<REDACTED_SECRET>etI
>   ID vault-root-<REDACTED_SECRET>a28d1d0eeda1810788d37ad2
>   (serial 5656530220978839826)
>   CA RSA SHA256:<REDACTED_SECRET>W60
> ```
>
> **O que este log prova:**
> - Autenticação via certificado (não chave RSA estática).
> - `ID vault-root-...` correlaciona com o audit log do Vault.
> - IP de origem `xxx.xxx.xxx.xxx` é o IP Tailscale do Windows — não um IP público.
> - Serial `5656530220978839826` é único por certificado — rastreável.

### 9.4 Correlação Vault ↔ VM

```
auth.log:   ID vault-root-<FINGERPRINT>  →  identifica o token e a chave usados
audit.log:  entrada com mesmo fingerprint →  mostra quem solicitou a assinatura, quando e de onde
```

---

## 10. LEAVER — Processo de Desligamento

### 10.1 LEAVER Normal (Saída Planejada)

```bash
# 1. Identificar o token do colaborador (registrado na entrega inicial)
# 2. Revogar o token — sem novos certificados a partir deste momento
vault token revoke [TOKEN_DO_COLABORADOR]

# 3. Verificar que foi revogado
vault token lookup [TOKEN_DO_COLABORADOR]
# Esperado: Error — permission denied ou token not found
```

> **Risco Residual:** certificados já emitidos permanecem válidos até o fim do TTL (30 min no lab).  
> Para o processo LEAVER com SLA de 15 minutos, o TTL de 30 min é um gap.  
> **Recomendação:** reduzir TTL para `15m` ou `10m` em ambientes que exigem SLA mais curto.

### 10.2 LEAVER Emergencial (Incidente ou Demissão Hostil)

```bash
# Passo 1: Revogar token do colaborador (imediato)
vault token revoke [TOKEN_DO_COLABORADOR]

# Passo 2: Bloquear acesso via rede overlay (mitigação imediata enquanto TTL expira)
# Exemplo Tailscale: remover o dispositivo do colaborador da tailnet via portal/API
# Isso corta a conectividade ANTES do TTL expirar — elimina o gap de 30 min

# Passo 3: Se necessário — rotacionar CA (invalida TODOS os certificados)
vault write ssh-client-signer/config/ca generate_signing_key=true
# ATENÇÃO: Isso exige re-emissão de certificados para TODOS os colaboradores

# Passo 4: Atualizar TrustedUserCAKeys em TODAS as VMs alvo
# Repetir Seção 7.1 em cada servidor com a nova chave pública da CA

# Passo 5: Documentar o incidente no [ITSM_TOOL]
```

### 10.3 Matriz de Decisão LEAVER

| Cenário | Ação Mínima | TTL Cobre? | Ação Adicional |
|---|---|---|---|
| Saída voluntária planejada | Revogar token | Sim (aguardar TTL) | Nenhuma |
| Demissão imediata | Revogar token | Gap de até 30 min | Bloquear na rede overlay |
| Incidente de segurança | Revogar token | NÃO — risco ativo | Rotacionar CA + bloquear rede |
| Chave privada comprometida | Revogar token | NÃO | Rotacionar CA + nova chave para todos |

---

## 11. Troubleshooting — Erros Reais do Lab

### 11.1 `default_extensions` — "expected a map, got 'string'"

**Causa:** O Vault espera um mapa JSON, não uma string.

**Comandos que falharam no lab:**
```bash
# ERRADO — string simples
default_extensions="permit-pty,permit-port-forwarding"

# ERRADO — JSON inline no shell (problemas de escaping)
default_extensions='{"permit-pty": "", "permit-port-forwarding": ""}'
```

**Solução correta — arquivo JSON:**
```bash
cat > /tmp/role.json <<'EOF'
{
  "key_type": "ca",
  "allow_user_certificates": true,
  "allowed_users": "[USERNAME_ALVO]",
  "ttl": "30m",
  "default_extensions": {
    "permit-pty": "",
    "permit-port-forwarding": ""
  }
}
EOF
vault write ssh-client-signer/roles/[ROLE_NAME] @/tmp/role.json
```

### 11.2 `empty valid principals not allowed by role`

**Causa:** O parâmetro `valid_principals` foi omitido no comando de assinatura.

```bash
# ERRADO — sem valid_principals
vault write -field=signed_key ssh-client-signer/sign/[ROLE_NAME] \
    public_key=@~/.ssh/id_rsa.pub > ~/.ssh/id_rsa-cert.pub

# CORRETO
vault write -field=signed_key ssh-client-signer/sign/[ROLE_NAME] \
    public_key=@~/.ssh/id_rsa.pub \
    valid_principals="[USERNAME_ALVO]" > ~/.ssh/id_rsa-cert.pub
```

### 11.3 Vault Sealed após Reinício

**Causa:** O Vault usa Shamir Secret Sharing — requer unseal manual após cada reinício.

```bash
vault status  # Verificar Sealed: true/false
vault operator unseal  # Repetir [THRESHOLD] vezes (3x no lab)
```

**Recomendação para produção:** Auto Unseal via [Azure Key Vault / AWS KMS / GCP KMS].

### 11.4 `WARNING! VAULT_ADDR and -address unset`

**Causa:** Variável de ambiente não configurada.

```bash
export VAULT_ADDR="http://127.0.0.1:8200"
# Adicionar ao ~/.bashrc ou ~/.profile para persistir
```

### 11.5 `vault: command not found` no Windows PowerShell

**Causa:** Vault CLI não instalado no Windows.

**Opções:**
1. Instalar Vault CLI: https://developer.hashicorp.com/vault/install
2. Executar assinatura no servidor Vault via SSH + transferir certificado via `scp`
3. Usar a UI Web do Vault (Seção 8.2)

### 11.6 Certificado "not yet valid" ou "expired"

**Causa:** Dessincronização de clock entre Vault e VM alvo.

```bash
# Verificar e sincronizar NTP
timedatectl status
sudo systemctl restart systemd-timesyncd
```

### 11.7 Arquivo de CA com múltiplas linhas

**Causa:** `trusted-user-ca-keys.pem` com quebra de linha interna.

```bash
wc -l /etc/ssh/trusted-user-ca-keys.pem  # Deve retornar: 1
cat -A /etc/ssh/trusted-user-ca-keys.pem  # Verificar caracteres ocultos
```

---

## 12. Recomendações de Evolução

### 12.1 Imediatas (próxima sessão do lab)

- [ ] **Desabilitar `PasswordAuthentication yes`** após confirmar que SSH CA está 100% funcional.  
      Adicionar ao `sshd_config`: `PasswordAuthentication no`
- [ ] **Configurar Auto Unseal** no Vault para evitar indisponibilidade após reinício.
- [ ] **Usar ed25519** em vez de RSA 4096 para novas chaves (mais moderno, menor, igualmente seguro).
- [ ] **Coletar e armazenar** os Anexos A-D (evidências de auditoria) antes de encerrar o lab.

### 12.2 Médio Prazo

- [ ] **Integrar LEAVER ao ITSM:** quando colaborador é marcado como "desligado" no [ITSM_TOOL], um webhook chama a API do Vault e revoga o token automaticamente.
- [ ] **Reduzir TTL:** avaliar TTL de `15m` ou `10m` para alinhar com SLA LEAVER de 15 minutos.
- [ ] **Centralizar logs:** enviar `/var/log/vault/audit.log` e `/var/log/auth.log` para o [SIEM_TOOL] para queries centralizadas.
- [ ] **Política de rotação de CA:** definir periodicidade (ex: anual ou pós-incidente) e procedimento de re-emissão de certificados para todos os colaboradores.

### 12.3 Cenários Futuros de Ferramenta

> Este POP usa HashiCorp Vault como exemplo. Os mesmos princípios se aplicam a:

| Ferramenta | Tipo | Contexto de Uso |
|---|---|---|
| HashiCorp Vault (Community) | Self-hosted | Lab, on-prem, multicloud |
| HashiCorp Vault (Enterprise) | Self-hosted | Corporativo com HA/DR nativo |
| [Teleport](https://goteleport.com) | SaaS/Self-hosted | SSH CA + BastionHost + Auditoria integrada |
| [Smallstep CA](https://smallstep.com) | Self-hosted | SSH CA open source, integra com OIDC |
| AWS Systems Manager (Session Manager) | Cloud-native | SSH sem portas abertas (apenas AWS) |
| AuthD (Canonical) | OS-level | Ubuntu 20.04+ com Entra ID — sem Vault |

---

## 13. Infraestrutura Tailscale — Contexto do Lab

O Living Lab PRJ009 opera com rede mesh Tailscale. Dispositivos ativos na data do lab:

```
xxx.xxx.xxx.xxx   fiqueok-prj009-gtw-canada   Ubuntu 22.04   [VM ALVO — Azure Canada Central]
xxx.xxx.xxx.xxx     vault-gf-01                 Ubuntu 24.04   [VAULT SERVER]
xxx.xxx.xxx.xxx     desktop-o87tpqi             Windows        [CLIENTE — ATIVO]
```

> **Importância da rede overlay para o modelo SSH CA:**  
> Sem a Tailscale Mesh, seria necessário expor a porta 22 da VM à internet ou configurar um Bastion Host.  
> Com a Mesh, o acesso SSH ocorre diretamente via IP Tailscale — sem exposição pública, sem IP transitório.  
> Este modelo é agnóstico: o mesmo padrão funciona com [WireGuard / OpenVPN / Netbird / ZeroTier].

---

## 14. Decisão de Caminho — Árvore de Escolha SSH Zero Trust

```
VM Linux no Azure com Ubuntu 22.04?
│
├── É uma VM Azure nativa?
│   ├── Ubuntu >= 24.04 LTS?
│   │   └── → AADSSHLoginForLinux (extensão nativa Azure) ✓
│   └── Ubuntu 22.04 ou inferior?
│       └── AADSSHLoginForLinux NÃO suportado
│           └── Azure Arc?
│               └── BLOQUEADO para VMs já no Azure
│                   └── → SSH CA (Vault / Teleport / Smallstep) ✓ [ESTE POP]
│
└── VM on-premises ou outro cloud?
    ├── Já tem HashiCorp Vault?
    │   └── → SSH CA via Vault (este POP) ✓
    ├── Prefere solução gerenciada?
    │   └── → Teleport ou Smallstep ✓
    └── Ubuntu 20.04/22.04/24.04 com Entra ID?
        └── → AuthD (Canonical) ✓
```

---

## 15. Histórico de Versões

| Versão | Data | Autor | Alterações |
|---|---|---|---|
| 1.0 | 28/02/2026 | [AUTOR] | Criação inicial |
| 2.0 | 28/02/2026 | [AUTOR] | Evidências reais do lab incorporadas; Troubleshooting com erros reais; Árvore de decisão de ferramenta; Recomendações de evolução; Nota sobre Arc/AADSSHLoginForLinux/AuthD; Backup de CA como passo obrigatório; Lições aprendidas inline |

---

*Living Lab Fiqueok — onde teoria encontra o terminal.*  
*Este documento é agnóstico de provedor cloud. Substitua os parâmetros `[VARIAVEL]` para adaptar ao seu ambiente.*

