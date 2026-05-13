## 📄  — TERMO DE ABERTURA DO PROJETO (VERSÃO CONSOLIDADA FINAL)

### Implementação de DefectDojo + OpenVAS (Kali) para Descoberta e Gestão de Vulnerabilidades de API

---

| Campo | Valor |
|:---|:---|
| **Código do Projeto** | PROJ020 |
| **Nome do Projeto** | Implementação de DefectDojo + OpenVAS (Kali) para Descoberta e Gestão de Vulnerabilidades de API |
| **Versão** | **1.7 (DOCUMENTO ÚNICO CONSOLIDADO — versão final)** |
| **Data de Criação** | 24/04/2026 |
| **Data de Atualização** | 28/04/2026 |
| **Responsável** | Paulo Feitosa Lima — GRC Lead |
| **Patrocinador** | Living Lab Fiqueok |
| **Status** | 🟢 **PROJETO CONCLUÍDO** — Primeiro scan executado, integração com Cloudflare Tunnel validada |
| **Classificação** | CONFIDENCIAL — Dados Técnicos e de Auditoria |

---

## 📌 SUMÁRIO EXECUTIVO PARA O LEITOR

> *Este documento é a versão final e consolidada do PROJ020 (v1.7). Ele contém toda a jornada do projeto, incluindo as **lições críticas descobertas durante a estabilização do acesso remoto via Cloudflare Tunnel** e o **Caminho Feliz** documentado como novo padrão ouro do Living Lab.*

| O que você precisa saber | Resumo |
|--------------------------|--------|
| **O que é este projeto?** | Implantar um scanner de vulnerabilidades (OpenVAS/GVM) e um sistema de gestão (DefectDojo) para testar a segurança da API do PRJ008 |
| **Qual a arquitetura final?** | Duas VMs: `defectdojo-gf-01` (Ubuntu + DefectDojo) e `sec-openvas-kali` (Kali + GVM nativo) |
| **O que já foi feito?** | ✅ Tudo — ambiente 100% operacional, acesso via Cloudflare Tunnel validado |
| **Qual foi o maior aprendizado?** | **L06:** A flag correta é `--munix-socket` (não `--gmp-socket` ou `--mgsmd`). Documentação online estava desatualizada; a resposta estava no `--help` do binário |
| **Qual o novo padrão?** | **"Caminho Feliz"** — roteiro validado em 15-20 minutos (excluindo sync de feeds) |

---

## 📋 ÍNDICE DE VERSÕES (HISTÓRICO MANTIDO)

| Versão | Data | Mudança | Justificativa |
|--------|------|---------|----------------|
| v1.0 | 24/04/2026 | Criação inicial | Arquitetura de três ferramentas em uma VM |
| v1.1 | 25/04/2026 | Ajustes de configuração | Correções no docker-compose do Akto |
| v1.2 | 26/04/2026 | Identificação de falhas | Akto em loop com erro `-Xmx0m` |
| v1.3 | 26/04/2026 | Tentativa de correção | Stack não sobe |
| v1.4 | 27/04/2026 | Revisão arquitetural | FROZEN do Akto + decisão de separar VMs |
| v1.5 | 27/04/2026 | Pivotamento para Kali | Ubuntu 24.04 inviável para GVM |
| v1.6 | 27/04/2026 | Documento único consolidado | Unificar toda a história do projeto |
| **v1.7** | **28/04/2026** | **Integração do "Caminho Feliz" e L06** | **Padrão ouro para futuras implantações** |

---

## 🛤️ SEÇÃO ESPECIAL: O "CAMINHO FELIZ" (PADRÃO OURO DO LIVING LAB)

*Esta seção documenta o procedimento validado que deveria ter sido seguido desde o início. Serve como referência para futuras implantações do GVM/OpenVAS com Cloudflare Tunnel.*

### Pré-requisitos

| Item | Estado |
|------|--------|
| Snapshot limpo do Kali (ex: `Pre-Scan-Inaugural-GVM-OK`) | ✅ Disponível |
| Acesso SSH à VM | ✅ `ssh paulo@xxx.xxx.xxx.xxx` |
| Cloudflare Tunnel configurado (token instalado) | ✅ |

### Roteiro validado (15-20 minutos, excluindo sync de feeds)

```bash
# === FASE 1: INSTALAÇÃO LIMPA ===
sudo apt update && sudo apt install -y gvm
sudo gvm-setup                    # Aguardar feeds (senha gerada)
sudo gvm-check-setup              # Confirmar "installation is OK"
sudo gvmd --user=admin --new-password='**********'

# === FASE 2: CONFIGURAR GSAD ===
# Editar serviço systemd
sudo systemctl edit gsad.service
```

```ini
[Service]
ExecStart=
ExecStart=/usr/sbin/gsad --foreground --listen=0.0.0.0 --port=9392 --munix-socket=/run/gvmd/gvmd.sock
```

```bash
sudo systemctl daemon-reload
sudo systemctl restart gsad

# === FASE 3: VERIFICAÇÃO ===
sudo ss -tulpn | grep 9392       # Deve mostrar LISTEN em 0.0.0.0:9392
curl -k https://localhost:9392 -I # Deve retornar HTTP 200
```

### Configuração no Cloudflare Dashboard (APENAS)

| Configuração | Valor |
|--------------|-------|
| **Service URL** | `https://localhost:9392` |
| **No TLS Verify** | ✅ ON |
| **HTTP Host Header** | `gvm.fiqueok.com.br` (opcional) |

> ⚠️ **Importante:** NÃO é necessário configurar arquivo `config.yml` local para túneis gerenciados por token. A configuração é 100% via dashboard.

---

## 📚 LIÇÕES APRENDIDAS (BASE DE CONHECIMENTO DO LIVING LAB)

### L01: Distros "bleeding edge" não são para ferramentas complexas

| Lição | Impacto |
|-------|---------|
| Ubuntu 24.04 lançado com bibliotecas muito recentes | PPAs comunitários não tiveram tempo de homologar |
| **Recomendação:** | Para ferramentas complexas, utilizar Kali Linux ou aguardar 6-12 meses após lançamento de uma LTS |

### L02: Scripts de terceiros são pontos de falha

| Falha | Mitigação |
|-------|-----------|
| `gvm-setup.sh` → 404 (Greenbone reorganizou repositórios) | Preferir pacotes empacotados (`apt`) ou containers oficiais |

### L03: Docker não é solução universal para permissões de rede

**Conclusão:** Scanner precisa de permissões de rede que containers modernos podem não ter. **Nativo ainda ganha em casos de ferramentas de baixo nível.**

### L04: Kali Linux como appliance funciona

| Característica | Resultado |
|----------------|-----------|
| Rolling release | Risco controlado com atualizações manuais |
| Pacote `gvm` nativo | ✅ Mantido pela Offensive Security |
| Memória RAM | **464 MB** após remoção da GUI |

### L05: Hierarquia de configuração do Systemd é implacável

| Problema | Solução |
|----------|---------|
| Customizações em `/etc` atropelam o padrão de `/lib` | Sempre verificar `systemctl status` por `Drop-In` e limpar `override.conf` antigos |

### 🆕 L06: A Sintaxe de Socket — O Divisor de Águas (CRÍTICA)

| O que tentamos | Resultado |
|----------------|-----------|
| `--gmp-socket` (documentação online desatualizada) | `Unknown option` + `free(): invalid pointer` |
| `--mgsmd` (palpite) | `Unknown option` + `free(): invalid pointer` |
| `--mlisten 127.0.0.1 --mport 9390` | Falha silenciosa — `gvmd` foi compilado com `-DGVM_USE_UNIX_SOCKET_ONLY=ON` e **NÃO ACEITA TCP** |

**A flag correta (descoberta via `gsad --help | grep -i socket`):**
```bash
--munix-socket=<file>                   # Path to Manager unix socket
```

| Impacto | Severidade |
|---------|------------|
| Horas de troubleshooting perdidas | 🔴 Alta |
| Divergência entre documentação online e binário | 🔴 Crítica para Governança |

**Recomendação para futuras implantações:** Sempre consultar `--help` do binário antes de confiar em documentação online de terceiros.

---

## 🚨 ERROS DOCUMENTADOS DURANTE A ESTABILIZAÇÃO

| Fase | Erro | Causa Raiz | Solução |
|------|------|------------|---------|
| 1 | `free(): invalid pointer` + `Aborted` | Conflito de ABI entre `gsad 24.16.0~git` e `gvmd 26.15.0` | Alinhar versões ou usar `--munix-socket` |
| 2 | `Binding to port 9392 failed` | Daemon de redirecionamento interno colide consigo mesmo | Usar `--munix-socket` (elimina conflito de porta) |
| 3 | `502 Bad Gateway` (Cloudflare) | Certificado autoassinado rejeitado pelo túnel | Ativar `No TLS Verify` no dashboard |
| 4 | `Authentication failure Status 1` | GSAD tentando TCP em porta 9390; `gvmd` só aceita Unix socket | Usar `--munix-socket=/run/gvmd/gvmd.sock` |
| 5 | `No such file or directory` (socket) | Diretório `/run/gvmd` não existe ou permissão incorreta | `sudo mkdir -p /run/gvmd && sudo chown _gvm:_gvm /run/gvmd` |

---

## 🏗️ ARQUITETURA FINAL APROVADA (v1.7)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LIVING LAB — PROJ020 v1.7                           │
│                                                                             │
│  ┌─────────────────────────────┐    ┌─────────────────────────────────────┐│
│  │  defectdojo-gf-01           │    │  sec-openvas-kali                   ││
│  │  Ubuntu 24.04               │    │  Kali Linux Rolling                 ││
│  │  DefectDojo (Docker)        │    │  GVM (Nativo)                       ││
│  │  Porta: 8080                │    │  Porta: 9392                        ││
│  │  Tailscale: xxx.xxx.xxx.xxx    │    │  Tailscale: xxx.xxx.xxx.xxx           ││
│  │  ✅ Funcional               │    │  ✅ Funcional                       ││
│  └─────────────────────────────┘    └─────────────────────────────────────┘│
│                    │                           │                            │
│                    └───────────┬───────────────┘                            │
│                                │                                            │
│                                ▼                                            │
│                    ┌───────────────────────────────────────┐               │
│                    │  Cloudflare Tunnel (gvm.fiqueok.com.br)│               │
│                    │  No TLS Verify = ON                    │               │
│                    │  ✅ Acesso externo validado            │               │
│                    └───────────────────────────────────────┘               │
│                                │                                            │
│                                ▼                                            │
│                    ┌───────────────────────────────────────┐               │
│                    │  api-gf-01 (xxx.xxx.xxx.xxx)          │               │
│                    │  API REST PRJ008 (FastAPI)            │               │
│                    │  Porta: 8000                          │               │
│                    └───────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 STATUS ATUAL DO PROJETO (v1.7)

### O que foi CONCLUÍDO ✅

| Etapa | Detalhe | Data |
|-------|---------|------|
| VM DefectDojo | Criada, configurada e funcional | 26-27/04 |
| DefectDojo Product/Engagement | "Living Lab — Segurança" criado | 27/04 |
| VM Kali `sec-openvas-kali` | Criada (GEN2, 4-8 GB RAM) | 27/04 |
| GVM instalado | `sudo apt install -y gvm` | 27/04 |
| `gvm-setup` executado | Feeds sincronizados (>95k NVTs) | 27-28/04 |
| `gvm-check-setup` | OK | 27/04 |
| Senhas configuradas | `admin/**********`, usuário `paulo` criado | 27/04 |
| Interface gráfica desligada | Modo texto (appliance) | 27/04 |
| **Cloudflare Tunnel** | **Acesso externo validado com No TLS Verify** | **28/04** |
| **GSAD estabilizado** | **Flag `--munix-socket` identificada e aplicada** | **28/04** |
| **Primeiro scan** | **Executado contra API PRJ008** | **28/04** |

---

## 📈 MÉTRICAS DE SUCESSO

| Métrica | Resultado |
|---------|-----------|
| Tempo total do "Caminho Feliz" | **15-20 minutos** (excluindo sync de feeds) |
| NVTs carregados | **175.814** |
| Memória RAM em idle (sem GUI) | **~464 MB** |
| Acesso externo via Cloudflare | **Validado (502 resolvido)** |
| Lições documentadas | **6 (L01 a L06)** |

---

## 🔐 PROCEDIMENTO OPERACIONAL PADRÃO (POP) — PROJ020-002 (Versão Estabilizada)

### Para futuras implantações do GVM com Cloudflare Tunnel:

1. **Reverter para snapshot limpo** (ex: `Pre-Scan-Inaugural-GVM-OK`)
2. **Instalar GVM:** `sudo apt update && sudo apt install -y gvm`
3. **Executar setup:** `sudo gvm-setup` (aguardar feeds)
4. **Configurar GSAD via systemd:**
   ```bash
   sudo systemctl edit gsad.service
   ```
   ```ini
   [Service]
   ExecStart=
   ExecStart=/usr/sbin/gsad --foreground --listen=0.0.0.0 --port=9392 --munix-socket=/run/gvmd/gvmd.sock
   ```
5. **Reiniciar serviços:** `sudo systemctl daemon-reload && sudo systemctl restart gsad`
6. **No Cloudflare Dashboard:** Service URL `https://localhost:9392`, **No TLS Verify = ON**
7. **Verificar acesso:** `https://gvm.fiqueok.com.br`

---

## 📁 REFERÊNCIAS CRUZADAS

| Documento | Relação |
|-----------|---------|
| `TAP-PRJ008-v1.0-FREEZING.md` | Alvo primário — API REST PRJ008 |
| `Evidencias PRJ020 f - Problemas de Autenticacao pos CloudFlared.txt` | Logs completos da estabilização |
| `POP-GRC-001` | Processo de gestão de vulnerabilidades |
| **`L06 - Sintaxe de Socket`** | **Nova entrada na base de conhecimento** |

---

## ✅ APROVAÇÕES

| Função | Nome | Data | Status |
|--------|------|------|--------|
| GRC Lead / Responsável | Paulo Feitosa Lima | 28/04/2026 | ✅ APROVADO |
| Arquiteto de Soluções | Paulo Feitosa Lima | 28/04/2026 | ✅ APROVADO |

---

**FIM DO TERMO DE ABERTURA DO PROJETO — PROJ020 v1.7 (VERSÃO CONSOLIDADA FINAL)**

---

> 📄 **Documento:** `TAP-PROJ020-v1.7.md`
> 🔒 **Classificação:** CONFIDENCIAL
> 📍 **Localização:** `10_Projetos/PROJ020/00_Gestao_do_Projeto/TAP-PROJ020-v1.7.md`
> 🗄️ **Versões anteriores (v1.0 a v1.6):** `10_Projetos/PROJ020/Arquivo_Morto/`
> ✍️ **Redigido com apoio de Claude (Anthropic) — Living Lab Fiqueok**

---

## 📁 INSTRUÇÕES PARA ARQUIVAMENTO

As versões anteriores (`TAP-PROJ020-v1.0.md` a `TAP-PROJ020-v1.6.md`) devem ser mantidas em:

```
10_Projetos/PROJ020/Arquivo_Morto/
```

**Este documento (v1.7) é a versão final consolidada e contém toda a história do projeto, incluindo as lições críticas e o "Caminho Feliz" como padrão ouro do Living Lab.**
