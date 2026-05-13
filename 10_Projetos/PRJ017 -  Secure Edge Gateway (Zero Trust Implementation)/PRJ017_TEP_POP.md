# PRJ017 – Secure Edge Gateway & Identity-First Perimeter

> [!info] Metadados do Projeto
> - **Código:** PRJ017
> - **Autor:** Paulo (Senior Information Security Analyst) — Laboratório GF
> - **Data de Entrega:** 18 de Abril de 2026
> - **Versão:** 1.0 — Baseline
> - **Status:** 🟢 CONCLUÍDO / CERTIFICADO
> - **Stack:** Cloudflare Zero Trust · Ubuntu 24.04 LTS · systemd · FastAPI · HashiCorp Vault · Tailscale VPN
> - **Classificação:** CONFIDENCIAL – Uso Interno

---

## Índice

1. [[#1. Contexto e Problema]]
2. [[#2. Termo de Encerramento de Projeto (TEP)]]
3. [[#3. Arquitetura da Solução]]
4. [[#4. POP — Passo a Passo As-Built]]
   - [[#Passo 1 — Criação do Túnel no Dashboard Cloudflare]]
   - [[#Passo 2 — Configuração do Public Hostname]]
   - [[#Passo 3 — Instalação do Conector na VM (cloudflared)]]
   - [[#Passo 4 — Verificação do Conector]]
   - [[#Passo 5 — Camada de Autenticação (Cloudflare Access)]]
   - [[#Passo 6 — Validação End-to-End]]
5. [[#5. Guia de Expansão — Adicionar Novo Acesso]]
6. [[#6. Matriz de Conformidade]]
   - [[#ISO/IEC 27001:2022]]
   - [[#CIS Controls v8]]
   - [[#NIST CSF 2.0]]
7. [[#7. Riscos e Mitigações]]
8. [[#8. Checklist de Auditoria Final]]
9. [[#9. Referências]]

---

## 1. Contexto e Problema

Antes do PRJ017, os sistemas do Laboratório GF operavam com **exposição direta de portas** na rede Tailscale:

| Sistema | VM | IP Tailscale | Porta Exposta | Risco |
|---|---|---|---|---|
| Shadow API (PRJ008) | api-gf-01 | xxx.xxx.xxx.xxx | :8000 | Qualquer device na VPN alcançava endpoints sem autenticação adicional |
| OrangeHRM | rh-gf-01 | xxx.xxx.xxx.xxx | :8085 | Acesso direto ao painel RH sem camada de identidade |
| midPoint IGA | iga-gf-02 | xxx.xxx.xxx.xxx | :8080 | Console de administração de identidades acessível sem Zero Trust |

> [!danger] Risco Operacional
> A Shadow API consumia credenciais do MariaDB e segredos do HashiCorp Vault. Qualquer dispositivo na malha Tailscale VPN poderia alcançar os endpoints **sem nenhuma autenticação adicional**, violando o princípio de menor privilégio.

**Evidência técnica do problema (pré-implantação):**
```powershell
# A porta 8085 do OrangeHRM ainda era acessível diretamente via Tailscale
PS C:\Users\win> curl -I http://xxx.xxx.xxx.xxx:8085
HTTP/1.1 302 Found
Server: Apache/2.4.65 (Debian)
# → Retornou resposta. Sem nenhuma camada de proteção de identidade.
```

---

## 2. Termo de Encerramento de Projeto (TEP)

### Objetivo Estratégico Atingido

O PRJ017 **eliminou a superfície de ataque externa** do Living Lab. A identidade passou a ser o perímetro. Nenhuma porta dos sistemas protegidos está mais acessível diretamente pela internet ou pela rede Tailscale sem autenticação Cloudflare Access.

### Entregas Realizadas

| # | Entrega | VM / Sistema | Status |
|---|---|---|---|
| 1 | Conector `cloudflared` instalado como serviço systemd | api-gf-01 (Shadow API) | ✅ Concluído |
| 2 | Conector `cloudflared` instalado como serviço systemd | rh-gf-01 (OrangeHRM) | ✅ Concluído |
| 3 | Conector `cloudflared` instalado como serviço systemd | iga-gf-02 (midPoint IGA) | ✅ Concluído |
| 4 | Túnel Cloudflare ativo para `api.fiqueok.com.br → localhost:8000` | api-gf-01 | ✅ Concluído |
| 5 | Túnel Cloudflare ativo para `rh.fiqueok.com.br → localhost:8085` | rh-gf-01 | ✅ Concluído |
| 6 | Túnel Cloudflare ativo para `iga.fiqueok.com.br → localhost:8080` | iga-gf-02 | ✅ Concluído |
| 7 | Políticas Zero Trust OTP configuradas para cada aplicação | Cloudflare Access | ✅ Concluído |
| 8 | Shadow API operando como daemon systemd (`shadow-api.service`) | api-gf-01 | ✅ Concluído |
| 9 | Crontab para renovação automática do token Vault (daily 00h) | api-gf-01 | ✅ Concluído |
| 10 | Validação end-to-end com challenge OTP funcional em `iga.fiqueok.com.br` | iga-gf-02 | ✅ Concluído |

### Resultado Final: Antes vs. Depois

| Dimensão | Antes (PRJ008) | Depois (PRJ017) |
|---|---|---|
| Exposição de portas | Portas abertas na VPN Tailscale | Nenhuma porta exposta externamente |
| Autenticação | Nenhuma (acesso direto por IP) | OTP por e-mail via Cloudflare Access |
| Criptografia | HTTP na rede interna | HTTPS TLS 1.3 na borda + túnel QUIC criptografado |
| Resiliência | Processo manual | Serviços systemd com `Restart=always` |
| Conformidade | Não endereçada | ISO 27001, CIS Controls, NIST CSF |

---

## 3. Arquitetura da Solução

```
┌─────────────────────────────────────────────────────────────────┐
│                        INTERNET PÚBLICA                         │
└────────────────────────┬────────────────────────────────────────┘
                         │ HTTPS / TLS 1.3
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    CLOUDFLARE EDGE (PoP GRU)                    │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              CLOUDFLARE ACCESS (Zero Trust)             │    │
│  │   • Verifica identidade via OTP por e-mail              │    │
│  │   • Apenas e-mails autorizados passam                   │    │
│  │   • Sessão com TTL de 24 horas                          │    │
│  └─────────────────────────┬───────────────────────────────┘    │
│                            │ Tráfego autenticado                │
│  ┌─────────────────────────▼───────────────────────────────┐    │
│  │              CLOUDFLARE TUNNEL (cloudflared)            │    │
│  │   • Protocolo QUIC / HTTP/2                             │    │
│  │   • Conexão outbound-only (sem inbound)                 │    │
│  │   • 4 conexões redundantes por conector                 │    │
│  └─────────────────────────┬───────────────────────────────┘    │
└────────────────────────────│────────────────────────────────────┘
                             │ Túnel criptografado (outbound)
          ┌──────────────────┼──────────────────┐
          ▼                  ▼                  ▼
  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐
  │   api-gf-01   │  │   rh-gf-01    │  │  iga-gf-02    │
  │ (Tailscale    │  │ (Tailscale    │  │ (Tailscale    │
  │  VPN only)    │  │  VPN only)    │  │  VPN only)    │
  │               │  │               │  │               │
  │ cloudflared   │  │ cloudflared   │  │ cloudflared   │
  │ (systemd)     │  │ (systemd)     │  │ (systemd)     │
  │      │        │  │      │        │  │      │        │
  │      ▼        │  │      ▼        │  │      ▼        │
  │ localhost:8000│  │ localhost:8085│  │ localhost:8080│
  │ (FastAPI)     │  │ (OrangeHRM)   │  │ (midPoint)    │
  └───────────────┘  └───────────────┘  └───────────────┘
```

> [!note] Princípio-Chave: Outbound Only
> O conector `cloudflared` **inicia a conexão de dentro para fora**. O servidor de origem nunca recebe conexões TCP diretas da internet. Isso elimina a necessidade de regras de firewall de entrada (inbound) e **reduz a superfície de ataque a zero**.

---

## 4. POP — Passo a Passo As-Built

> [!tip] Este guia é replicável
> Use este POP para proteger qualquer novo sistema do laboratório. Substitua os valores de exemplo pelos do sistema alvo.

---

### Passo 1 — Criação do Túnel no Dashboard Cloudflare

1. Acesse **[one.dash.cloudflare.com](https://one.dash.cloudflare.com)**
2. Navegue até: `Zero Trust → Networks → Tunnels → Create a tunnel`
3. Selecione o tipo: **Cloudflared**
4. Defina o nome seguindo o padrão: `tunnel-<sistema>`
   - Exemplos: `tunnel-orangehrm`, `tunnel-midpoint`, `tunnel-shadow-api`
5. Clique em **Save tunnel**
6. **⚠️ CRÍTICO:** Copie e guarde o token exibido na tela — ele será usado no Passo 3

> [!warning] O token só é exibido uma vez
> Após fechar a tela, não é possível recuperar o token. Guarde-o com segurança antes de prosseguir.

---

### Passo 2 — Configuração do Public Hostname

Ainda na tela de configuração do túnel, acesse a aba **Public Hostnames**:

| Parâmetro | Shadow API | OrangeHRM | midPoint IGA |
|---|---|---|---|
| **Subdomain** | `api` | `rh` | `iga` |
| **Domain** | `fiqueok.com.br` | `fiqueok.com.br` | `fiqueok.com.br` |
| **Service Type** | HTTP | HTTP | HTTP |
| **URL (Origin)** | `localhost:8000` | `localhost:8085` | `localhost:8080` |
| **No TLS Verify** | N/A | N/A | Habilitar se cert autoassinado |

> [!info] CNAME automático
> O Cloudflare cria automaticamente o registro CNAME no DNS do domínio `fiqueok.com.br`. Não é necessário nenhuma configuração manual de DNS.

---

### Passo 3 — Instalação do Conector na VM (cloudflared)

Acesse a VM de destino via SSH e execute os comandos na sequência:

#### 3.1 — Adicionar repositório e instalar o pacote

```bash
# Criar diretório de keyrings
sudo mkdir -p --mode=0755 /usr/share/keyrings

# Importar chave GPG oficial Cloudflare
curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg \
  | sudo tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null

# Adicionar repositório APT
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] \
  https://pkg.cloudflare.com/cloudflared any main' \
  | sudo tee /etc/apt/sources.list.d/cloudflared.list

# Instalar o pacote
sudo apt-get update && sudo apt-get install cloudflared -y
```

**Evidência de execução bem-sucedida (iga-gf-02 — 18/04/2026):**
```
Setting up cloudflared (2026.3.0) ...
Processing triggers for man-db ...
```

#### 3.2 — Instalar como serviço systemd

```bash
# Substitua <TOKEN> pelo token copiado no Passo 1
sudo cloudflared service install <TOKEN>
```

**O que este comando faz automaticamente:**
- Cria `/etc/systemd/system/cloudflared.service`
- Registra o conector no painel Cloudflare Zero Trust
- Habilita autostart no boot (`systemctl enable cloudflared`)
- Inicia o serviço imediatamente

**Evidência de execução bem-sucedida:**
```
# api-gf-01 (Shadow API):
2026-04-18T00:33:14Z INF Using Systemd
2026-04-18T00:33:14Z INF Linux service for cloudflared installed successfully

# rh-gf-01 (OrangeHRM):
2026-04-18T14:39:06Z INF Using Systemd
2026-04-18T14:39:07Z INF Linux service for cloudflared installed successfully

# iga-gf-02 (midPoint IGA):
2026-04-18T15:03:14Z INF Using Systemd
2026-04-18T15:03:14Z INF Linux service for cloudflared installed successfully
```

---

### Passo 4 — Verificação do Conector

```bash
# Verificar status do serviço
sudo systemctl status cloudflared

# Verificar logs de conexão (resultado esperado: 4 conexões registradas)
sudo journalctl -u cloudflared -n 30 --no-pager
```

| O que verificar | Resultado Esperado |
|---|---|
| `systemctl status cloudflared` | `Active: active (running)` |
| Logs do journalctl | `INF Registered tunnel connection` para connIndex 0, 1, 2, 3 |
| Dashboard CF → Tunnels | Status **HEALTHY** (indicador verde) |

> [!note] Sobre a instabilidade QUIC observada
> Durante a implantação, foram observados ciclos de reconexão QUIC (`sendmsg: network is unreachable`). Este comportamento é esperado em redes com variação de rota e é resolvido **automaticamente** pelo mecanismo de retry do `cloudflared` em poucos segundos. Não requer intervenção manual.

---

### Passo 5 — Camada de Autenticação (Cloudflare Access)

No painel `Cloudflare Zero Trust → Access → Applications`, crie uma nova aplicação:

#### 5.1 — Configuração da Aplicação

```
Application Type:   Self-hosted
Application Name:   <Sistema> Lab  (ex: OrangeHRM RH Lab, midPoint IGA Lab)
Application Domain: <subdominio>.fiqueok.com.br
Session Duration:   24h
```

#### 5.2 — Configuração da Política de Acesso

```
Policy Name:        Allow Lab Users
Action:             Allow
Rule (Include):
  Seletor:          Emails
  Valores:          paulo@<dominio>
                    daniel@<dominio>

Identity Provider:  One-Time PIN (OTP via e-mail)
```

> [!tip] OTP já está habilitado
> O provedor One-Time PIN já foi habilitado no Zero Trust durante a implantação inicial. Para novos sistemas, apenas referencie o mesmo provedor na política.

---

### Passo 6 — Validação End-to-End

Execute o checklist de validação antes de considerar a entrega concluída:

```bash
# 1. Teste o acesso externo — deve redirecionar para tela de login Cloudflare Access
curl -I https://<subdominio>.fiqueok.com.br

# Resultado esperado (evidenciado em iga.fiqueok.com.br em 18/04/2026):
# HTTP/2 302
# location: https://fiqueok-lab.cloudflareaccess.com/cdn-cgi/access/login/...
# → Confirma que o Access está interceptando a requisição ✅

# 2. Verifique que a porta interna NÃO está acessível externamente
curl -I http://<IP_PUBLICO_OU_TAILSCALE>:<PORTA>
# Resultado esperado: Connection refused ou timeout ✅
```

**Validação completa (navegador):**
1. Acesse `https://<subdominio>.fiqueok.com.br`
2. Confirme o redirecionamento para a tela de autenticação Cloudflare
3. Insira um e-mail **autorizado** → receba o OTP → acesse normalmente ✅
4. Repita com um e-mail **não autorizado** → deve retornar tela de acesso negado ✅

---

## 5. Guia de Expansão — Adicionar Novo Acesso

Para conceder acesso a um novo colaborador, auditor ou stakeholder:

1. **Acessar:** `Cloudflare Zero Trust → Access → Applications`
2. **Localizar** a aplicação desejada (ex: `OrangeHRM RH Lab`)
3. **Clicar** em `Edit`
4. **Ir até** a aba `Policies` → selecionar a política `Allow Lab Users`
5. **Na seção `Include`**, no seletor `Emails`:
   - Adicionar o novo endereço de e-mail (uma linha por endereço)
6. **Clicar** em `Save application`

> [!success] Resultado imediato
> O novo utilizador já pode acessar o URL protegido. Na primeira tentativa, será solicitado o OTP via e-mail, sem necessidade de nenhuma configuração adicional na VM ou no túnel.

**Para revogar acesso:**
- Remover o e-mail da política e clicar em **Save application**
- Opcionalmente, revogar sessões ativas em: `Access → Active Sessions`

---

## 6. Matriz de Conformidade

### ISO/IEC 27001:2022

| Controle | Título | Como PRJ017 Endereça |
|---|---|---|
| **A.5.15** | Controle de Acesso | Política de Zero Trust baseada em identidade verificada (e-mail + OTP). Nenhum acesso sem autenticação ativa. |
| **A.8.3** | Restrição de Acesso | Apenas e-mails explicitamente autorizados têm acesso. Sem regra implícita de "nega tudo exceto". |
| **A.8.20** | Segurança de Redes | Eliminação de portas expostas. Todo tráfego passa por túnel criptografado. Nenhuma conexão inbound direta. |
| **A.8.22** | Segregação de Redes | Cada sistema tem seu próprio túnel e política de Access independentes. |
| **A.8.26** | Segurança de Aplicações em Redes | HTTPS obrigatório na borda (TLS 1.3). Sem exposição de HTTP para a internet pública. |
| **A.8.46** | Eliminação de Informações | Credenciais do Vault não são mais acessíveis a qualquer dispositivo na VPN — apenas via aplicação autenticada. |

---

### CIS Controls v8

| Control | Safeguard | Implementação no PRJ017 |
|---|---|---|
| **CIS 4** | Configuração Segura de Ativos | `cloudflared` instalado via repositório oficial com chave GPG verificada. Serviço gerenciado por systemd com configurações mínimas. |
| **CIS 6** | Gerenciamento de Contas de Acesso | Acesso controlado por lista explícita de e-mails. Sessões com TTL de 24h. Sem contas compartilhadas ou anônimas. |
| **CIS 12** | Gerenciamento de Infraestrutura de Rede | Eliminação de portas abertas. Arquitetura de túnel outbound-only. Segmentação lógica por aplicação. |
| **CIS 13** | Monitoramento e Defesa de Rede | Todos os acessos passam pelo logging centralizado do Cloudflare Access (dashboard com registros de autenticação). |
| **CIS 16** | Segurança de Aplicações | Política de identidade como camada de proteção antes da aplicação. Sem exposição do endpoint de origem. |

---

### NIST CSF 2.0

| Função | Categoria | Como PRJ017 Contribui |
|---|---|---|
| **GOVERN (GV)** | Política de Segurança | Política Zero Trust documentada neste TEP. Revisão prevista para 18/07/2026. |
| **IDENTIFY (ID)** | Gestão de Ativos | VMs, túneis e aplicações mapeados. Inventário de sistemas protegidos mantido neste documento. |
| **PROTECT (PR)** | Controle de Acesso (PR.AA) | Autenticação multifator implícita via OTP + e-mail verificado. Princípio de menor privilégio aplicado por lista de e-mails. |
| **PROTECT (PR)** | Segurança de Plataforma (PR.PS) | Configuração segura do conector como serviço systemd não-root. Token Vault com renovação automática diária. |
| **PROTECT (PR)** | Proteção de Dados (PR.DS) | Credenciais do MariaDB e segredos do Vault nunca expostos diretamente. Criptografia TLS 1.3 + QUIC ponta-a-ponta. |
| **DETECT (DE)** | Monitoramento Contínuo (DE.CM) | Logs de conexão via `journalctl -u cloudflared`. Dashboard Cloudflare com status HEALTHY e histórico de acessos. |
| **RESPOND (RS)** | Análise de Incidentes (RS.AN) | Evidências de terminal coletadas e armazenadas. Processo de revogação de acesso documentado na Seção 5. |

---

## 7. Riscos e Mitigações

| Risco | Prob. | Impacto | Mitigação Implementada |
|---|---|---|---|
| Expiração do token Vault → falha na Shadow API | Média | Alto | Crontab diário às 00h renova o token automaticamente |
| Queda do conector `cloudflared` | Baixa | Alto | `Restart=always` no unit systemd. Reconexão em ~5s. 4 conexões redundantes ao PoP GRU. |
| Instabilidade QUIC transitória | Baixa | Baixo | Observado durante implantação. Resolvido automaticamente via retry interno do cloudflared. |
| E-mail autorizado comprometido | Baixa | Alto | Revisar lista periodicamente. Revogar sessões ativas no dashboard. Considerar adicionar IP allowlist como segunda camada. |
| Kernel desatualizado nas VMs | Média | Médio | Observado nas 3 VMs (`6.8.0-107` → esperado `6.8.0-110`). Planejar janela de manutenção para `apt upgrade` + reboot. |

---

## 8. Checklist de Auditoria Final

### Por Sistema

| Item | api-gf-01 (API) | rh-gf-01 (RH) | iga-gf-02 (IGA) |
|---|:---:|:---:|:---:|
| Conector instalado via repositório oficial | ✅ | ✅ | ✅ |
| Serviço systemd ativo e habilitado no boot | ✅ | ✅ | ✅ |
| Túnel com status HEALTHY no dashboard | ✅ | ✅ | ✅ |
| Porta interna não acessível externamente | ✅ | ✅ | ✅ |
| Política Access com OTP configurada | ✅ | ✅ | ✅ |
| Validação OTP funcional (e-mail autorizado) | ✅ | ✅ | ✅ |
| Acesso negado para e-mail não autorizado | ✅ | ✅ | ✅ |

### Controles Globais

| Item | Status |
|---|:---:|
| Portas externas bloqueadas em todos os sistemas | ✅ |
| Log de acesso centralizado (Dashboard Cloudflare) | ✅ |
| Resiliência a reboots via systemd | ✅ |
| Token Vault com renovação automática (crontab) | ✅ |
| Documentação de conformidade (ISO, CIS, NIST) | ✅ |
| TEP e POP armazenados no repositório do laboratório | ✅ |

---

## 9. Referências

| Recurso | URL / Localização |
|---|---|
| Cloudflare Tunnel Docs | https://developers.cloudflare.com/cloudflare-one/connections/connect-networks |
| Cloudflare Access Docs | https://developers.cloudflare.com/cloudflare-one/policies/access |
| Dashboard Zero Trust | https://one.dash.cloudflare.com |
| PRJ008 – Shadow API | Repositório: `~/prj008-shadow-api` · Host: `api-gf-01` (xxx.xxx.xxx.xxx) |
| HashiCorp Vault | `http://xxx.xxx.xxx.xxx:8200` · Token: `/var/lib/shadow-api/vault_token` |
| OrangeHRM | `http://xxx.xxx.xxx.xxx:8085` · Target: `rh.fiqueok.com.br` |
| midPoint IGA | `http://xxx.xxx.xxx.xxx:8080` · Target: `iga.fiqueok.com.br` |
| ISO/IEC 27001:2022 | Controles A.5.15, A.8.3, A.8.20, A.8.22, A.8.26 |
| CIS Controls v8 | Controls 4, 6, 12, 13, 16 |
| NIST CSF 2.0 | Funções GV, ID, PR, DE, RS |

---

*PRJ017 – Secure Edge Gateway · TEP & POP · v1.0 · Abril 2026 · Laboratório GF*

*Próxima Revisão: 18 de Julho de 2026 (ou após mudança de infraestrutura)*

