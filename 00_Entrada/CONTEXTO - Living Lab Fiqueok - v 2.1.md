#

## Documento de Referência para RAG — v2.1

**Gerado em:** Abril de 2026  
**Responsável:** Paulo Feitosa (IAM Specialist / Auditor / GRC Lead)  
**Fonte:** Evidência primária — vaults Obsidian exportados (PRJ001 a PRJ020)  
**Uso:** Contexto para AnythingLLM + Ollama / DeepSeek-R1  
**Versão anterior:** v2.0 (PRJ001–PRJ008)  
**Esta versão adiciona:** PROJ020 (OpenVAS/GVM + DefectDojo), Kali Linux como appliance, lições de instalação de scanner

---

## ÍNDICE

1. Sobre o Living Lab Fiqueok
2. Identidade do Responsável
3. Infraestrutura Base do Laboratório
4. Princípios Arquiteturais Consolidados
5. Linha do Tempo da Saga (PRJ001–PRJ020)
6. PRJ001 — Laboratório de SI
7. PRJ002 — Infraestrutura Fiqueok
8. PRJ003 — IGA Greenfield (Fundamentos Arquiteturais)
9. PRJ004 — IGA Data Lifecycle (CSV)
10. PRJ005 — Integração de Fonte Autoritativa (OrangeHRM)
11. PRJ006 — Integração Dinâmica via JDBC (Abortado)
12. PRJ007 — HashiCorp Vault (PAM)
13. PRJ008 — Shadow API REST (Integração IGA)
14. **PRJ020 — OpenVAS/GVM + DefectDojo (Gestão de Vulnerabilidades)** ← **NOVO**
15. Lições Aprendidas Transversais
16. Frameworks de Conformidade Adotados
17. Inventário de Ativos e Topologia de Rede
18. Governança e Gestão de Decisões
19. Papel das IAs no Laboratório
20. Riscos Abertos e Pendências Futuras
21. Glossário Técnico do Laboratório

---

## 1. Sobre o Living Lab Fiqueok

O Living Lab Fiqueok é um laboratório de experimentação técnica pessoal, operado por Paulo Feitosa em ambiente doméstico (HomeLab) com Hyper-V sobre Windows 11 Pro. Seu propósito é simular ambientes corporativos reais de IAM (Identity and Access Management) e IGA (Identity Governance and Administration), documentando a jornada com rigor de governança equivalente ao de uma organização Fintech.

O laboratório serve três objetivos simultâneos:

- **Aprendizado aplicado** — implementação real de tecnologias IAM/IGA com falhas, pivôs e soluções documentadas honestamente
- **Portfólio técnico** — evidências públicas de competência para LinkedIn e mercado de trabalho
- **Repositório de conhecimento** — base de referência para futuras consultorias e projetos profissionais

A documentação é produzida integralmente no Obsidian (vault `FiqueokBrain`) e segue o modelo formal de GMUD (Gestão de Mudanças), ADR (Architecture Decision Record), REL (Relatório de Execução) e TAP/TEP (Termos de Abertura/Encerramento de Projeto). O laboratório opera desde dezembro/2025 e está em curso.

---

## 2. Identidade do Responsável

- **Nome:** Paulo Feitosa
- **Perfil profissional:** IAM Specialist / Auditor / GRC Lead
- **Localização:** São Paulo, SP, Brasil
- **Área de atuação:** IAM, IGA, GRC, Microsoft Entra ID, SAP Identity, compliance ISO 27001/SOX
- **Modelo de uso de IAs:** multi-IA com papéis especializados — Claude como GRC Lead e documentador, ChatGPT como arquiteto/executor, Perplexity como pesquisa/inteligência, Gemini para análise (com ressalvas após incidente PRJ007)
- **Objetivo de carreira:** transição da execução operacional para posições seniores em IAM/GRC

---

## 3. Infraestrutura Base do Laboratório

### Host físico

- **CPU:** Intel i5-12400F
- **RAM:** 64 GB
- **OS:** Windows 11 Pro (Build 26200.7623)
- **Hypervisor:** Microsoft Hyper-V
- **Rede doméstica:** TP-Link Deco mesh, SSID dedicado para IoT (`Sabaoth_Iot`)

### Conectividade entre VMs

- **Tailscale Mesh VPN** — espinha dorsal de conectividade Zero Trust entre todos os nós do laboratório; MagicDNS ativo para resolução de nomes
- **Cloudflare Zero Trust** — exposição segura de serviços com OTP via e-mail (implementado no PRJ017)
- Virtual Switches Hyper-V para redes internas

### Plataforma de documentação

- **Obsidian** (vault `FiqueokBrain`) — fonte única de verdade para toda documentação do laboratório
- Organização por projeto com pastas padronizadas: `00_Gestao_do_Projeto`, `10_Arquitetura_Tecnica`, `20_Governanca_e_Decisoes`, `30_Operacao_e_Mudanca`, `50_Evidencias`

### CONSTRAINT-001 (ativa desde 09/02/2026)

Corrupção do subsistema UEFI do Hyper-V impede criação de novas VMs do tipo GEN2. VMs existentes não são afetadas. Sintomas: novas VMs não inicializam com erro "The boot loader did not load"; desligamento via GUI retorna erro `0x800710DF`. `SFC /scannow` e `DISM /RestoreHealth` não corrigem. Workaround ativo: uso de GEN1 ou WSL2. Resolução definitiva planejada para Q2/2026 (reinstalação do Windows).

---

## 4. Princípios Arquiteturais Consolidados

Estes princípios foram destilados a partir das evidências de PRJ001 a PRJ020. Cada um foi validado empiricamente — a maioria por uma falha que o tornou necessário.

1. **Decisão antes da automação** — contratos de identidade (canvases, ADRs) devem preceder qualquer GMUD técnica. Regra formalizada no PRJ003.
2. **Identidade canônica explícita** — o identificador único e imutável da pessoa deve ser definido no IGA, não herdado de sistemas externos. Identificadores técnicos externos não são âncoras de identidade.
3. **Idempotência como regra** — scripts e configurações devem poder ser executados múltiplas vezes sem efeitos colaterais. Requisito de qualidade para aprovação de qualquer GMUD.
4. **API-first, nunca JDBC direto** — acessar banco de dados de terceiros diretamente é anti-padrão arquitetural. Comprovado por 30 dias de esforço perdido no PRJ006, onde 8+ JOINs foram necessários para dados que uma API entrega em 1 endpoint.
5. **WSL2 não é plataforma para workloads críticos** — falhas estruturais de systemd, rede e persistência foram comprovadas empiricamente no PRJ007. Nenhuma IA previu essas limitações antes do evento.
6. **Blast radius controlado** — rollback via checkpoint Hyper-V é o mecanismo oficial de reversão em todas as GMUDs. Production Checkpoints (com VSS para consistência de PostgreSQL) são obrigatórios antes de qualquer mudança técnica.
7. **Documentação como parte do sistema** — GMUDs, ADRs, TAPs e RELs são ativos técnicos, não burocracia. Gap de 64 dias sem GMUD no PRJ007 gerou 6 mudanças sem rastreabilidade — débito de auditoria documentado.
8. **Infraestrutura como alicerce, não afterthought** — IPs estáticos, rede estável e segmentação de ambientes devem preceder qualquer integração. Lição crítica do PRJ006, onde SSH instável impossibilitava distinguir problema de rede de problema de configuração.
9. **Validações empíricas superam análises sintéticas de IA** — testes de ciclo completo (boot → operação → shutdown → recovery) são obrigatórios antes de encerrar qualquer fase. Race condition midPoint/PostgreSQL (PRJ003) e falhas WSL2 (PRJ007) não foram previstas por nenhuma IA.
10. **IaC com gestão de segredos via .env** — credenciais hardcoded são estritamente proibidas em qualquer artefato. `.env` protegido e não versionado. `.gitignore` obrigatório.
11. **Distros especializadas para ferramentas complexas** — Ubuntu LTS recente (24.04) não é ideal para OpenVAS/GVM devido a bibliotecas muito novas; Kali Linux nativo com suporte Offensive Security provou-se mais estável (PRJ020).
12. **Docker não é solução universal para permissões de rede** — scanners como OpenVAS precisam de `CAP_NET_RAW` que mesmo containers privilegiados podem ter bloqueado por AppArmor/Kernel (PRJ020).

---

## 5. Linha do Tempo da Saga (PRJ001–PRJ020)

| Período | Projeto | Status | Resultado Principal |
|---------|---------|--------|---------------------|
| Dez/2025 | PRJ001 | ✅ Concluído | Baseline de SI; migração VirtualBox → Hyper-V; scans OpenVAS; hardening inicial |
| Jan/2026 | PRJ002 | ✅ Concluído | Infra core (AD, midPoint, OrangeHRM); 25+ GMUDs; incidente de rede; domínio `corp.fiqueok.com.br` |
| Jan/2026 | PRJ003 | ✅ Concluído | Fundamentos arquiteturais IGA Greenfield; Canvases de Identidade; midPoint 4.10 funcional |
| Jan/2026 | PRJ004 | ✅ Concluído | CSV como fonte autoritativa; primeiro ciclo JML completo validado |
| Fev/2026 | PRJ005 | ✅ Concluído | OrangeHRM como fonte autoritativa; conectividade JDBC segura estabelecida em 2 dias |
| Fev/2026 | PRJ006 | ⚠️ Abortado | Anti-padrão JDBC identificado; decisão API-first; higiene de infraestrutura executada |
| Fev–Abr/2026 | PRJ007 | 🟡 Ativo | HashiCorp Vault operacional em GEN1; 3 plataformas tentadas; GMUD-003 executada abr/2026 |
| Abr/2026 | PRJ008 | 🟡 Aceitação Parcial | Shadow API REST certificada; integração midPoint via DatabaseTable Connector; conector REST nativo indisponível (bloqueio técnico) |
| **Abr/2026** | **PRJ020** | 🟢 **Fase B Concluída** | **DefectDojo operacional; Kali Linux + GVM funcionando; scanner pronto para primeiro scan** |

---

## 6. PRJ001 — Laboratório de SI

*(conteúdo mantido inalterado da v2.0)*

---

## 7. PRJ002 — Infraestrutura Fiqueok

*(conteúdo mantido inalterado da v2.0)*

---

## 8. PRJ003 — IGA Greenfield (Fundamentos Arquiteturais)

*(conteúdo mantido inalterado da v2.0)*

---

## 9. PRJ004 — IGA Data Lifecycle (CSV)

*(conteúdo mantido inalterado da v2.0)*

---

## 10. PRJ005 — Integração de Fonte Autoritativa (OrangeHRM)

*(conteúdo mantido inalterado da v2.0)*

---

## 11. PRJ006 — Integração Dinâmica via JDBC (Abortado)

*(conteúdo mantido inalterado da v2.0)*

---

## 12. PRJ007 — HashiCorp Vault (PAM)

*(conteúdo mantido inalterado da v2.0)*

---

## 13. PRJ008 — Shadow API REST (Integração IGA)

*(conteúdo mantido inalterado da v2.0)*

---

## 14. PRJ020 — OpenVAS/GVM + DefectDojo (Gestão de Vulnerabilidades)

**Período:** Abril/2026  
**Status:** 🟢 **Fase B Concluída** — GVM operacional em Kali, aguardando primeiro scan da API PRJ008  
**Objetivo:** Implementar um scanner de vulnerabilidades (OpenVAS/GVM) e um sistema de gestão (DefectDojo) para testar a segurança da API do PRJ008 e descobrir serviços não inventariados na mesh Tailscale.

### Contexto e Justificativa

O PROJ020 nasceu para fechar a lacuna de gestão de vulnerabilidades no Living Lab. Os projetos anteriores (PRJ001–PRJ016) construíram governança de *quem tem acesso*, mas faltava visibilidade sistemática sobre *o que está exposto*. O PROJ020 introduz a camada de Gestão de Vulnerabilidades, fechando o loop entre identidade e superfície de ataque.

O alvo primário é a API REST do PRJ008 (`api-gf-01:8000`), que nunca foi submetida a um scan formal de segurança. Alvos secundários são os demais serviços acessíveis via mesh Tailscale.

### Falha da Hipótese Inicial (v1.0–v1.4)

| Premissa Original | Realidade Encontrada |
|-------------------|----------------------|
| Ubuntu LTS → estável e suportado para GVM | Biblioteca libical + Python muito novas → PPAs quebrados (404) |
| Docker → isolamento fácil para OpenVAS | Greenbone migrou imagens para registro privado (`pull access denied`) |
| Scripts oficiais → funcionam | `gvm-setup.sh` removido/substituído (404) |
| Container tem permissões totais | AppArmor/Kernel bloqueia `CAP_NET_RAW` mesmo em modo privilegiado |
| Akto seria viável | Múltiplas falhas (`-Xmx0m`, `free: command not found`, Kafka, imagem `:0.5.5` não encontrada) |

**Decisão de pivotamento (v1.5):** Akto removido do escopo. OpenVAS migrado para Kali Linux nativo.

### Arquitetura Final (v1.6)

**Estratégia de duas VMs especializadas:**

| Componente | Sistema | Método | Porta | IP Tailscale | Status |
|------------|---------|--------|-------|--------------|--------|
| DefectDojo | Ubuntu 24.04 | Docker | 8080 | xxx.xxx.xxx.xxx | ✅ |
| OpenVAS/GVM | Kali Rolling | Nativo (`apt`) | 9392 | xxx.xxx.xxx.xxx | ✅ |

**VM Kali `sec-openvas-kali`:**

| Parâmetro | Valor | Justificativa |
|-----------|-------|---------------|
| Geração | GEN2 (com Secure Boot desligado) | CONSTRAINT-001 contornada |
| RAM | 4-8 GB (dinâmica) | Suficiente para GVM + feeds |
| vCPU | 2 | Scans não exigem mais |
| Disco | 80 GB (VHDX dinâmico) | Feeds NVTs (vários GB) |
| SO | Kali Linux Rolling (2026.1) | Suporte nativo ao GVM |

### Implementação no Kali Linux

**Instalação do GVM (bem-sucedida):**
```bash
sudo apt install -y gvm
# Saída: Installing: gvm, greenbone-security-assistant, gsad, gvm-tools

sudo gvm-setup
# Senha admin gerada: 69637965-4ae0-4dea-84f7-21134fd45a7b

sudo gvm-check-setup
# Resultado: "It seems like your GVM-25.04.0 installation is OK."
# NVTs carregados: 95.086 NVTs
```

**Correção do acesso remoto (gsad):**
```bash
# Configurar override do serviço
sudo systemctl edit gsad.service
# Adicionar: Environment="GSAD_OPTIONS=--listen=0.0.0.0 --port=9392"

# Verificar resultado
sudo ss -tunlp | grep 9392
# Saída: tcp LISTEN 0 4096 0.0.0.0:9392
```

**Usuários e segurança:**
```bash
# Alterar senha do admin
sudo gvmd --user=admin --new-password='**********'

# Criar usuário paulo com sudo
sudo adduser paulo
sudo usermod -aG sudo paulo

# Bloquear usuário kali padrão
sudo usermod -L kali
```

**Otimização para servidor (modo appliance):**
```bash
# Desabilitar interface gráfica
sudo systemctl set-default multi-user.target
sudo systemctl stop lightdm

# Desabilitar atualizações automáticas
sudo systemctl disable --now apt-daily.timer
sudo systemctl disable --now apt-daily-upgrade.timer

# Resultado de memória
free -h
# Saída: Mem: 3.8Gi total, 464Mi usado, 3.4Gi livre
```

### DefectDojo (Fase A)

**VM `defectdojo-gf-01` (ex-`sec-scanner-gf-01`):**
```bash
# Renomeação da VM
Rename-VM -Name "sec-scanner-gf-01" -NewName "defectdojo-gf-01"
sudo hostnamectl set-hostname defectdojo-gf-01
sudo tailscale set --hostname defectdojo-gf-01
```

**Configuração final:**
| Parâmetro | Valor |
|-----------|-------|
| URL | `http://xxx.xxx.xxx.xxx:8080` |
| Usuário admin | `admin` |
| Senha admin | `K6hiVpTKlkn8Jox705unHP` |
| Product | "Living Lab — Segurança" |

### Status Atual do PROJ020

| Etapa | Status | Detalhe |
|-------|--------|---------|
| VM defectdojo-gf-01 | ✅ Concluída | Ubuntu 24.04 + Docker, funcional |
| Product/Engagement | ✅ Concluído | Criado no DefectDojo |
| VM sec-openvas-kali | ✅ Concluída | Kali Rolling, GEN2 |
| GVM instalado | ✅ Concluído | Pacote `gvm` |
| `gvm-setup` | ✅ Concluído | 95.086 NVTs carregados |
| gsad configurado | ✅ Concluído | Escutando em `0.0.0.0:9392` |
| Interface gráfica desligada | ✅ Concluído | Modo appliance |
| Feeds sincronizando | 🔄 Em progresso | SCAP, CERT, GVMD_DATA via rsync |
| Primeiro scan da API PRJ008 | ⬜ Pendente | Aguardando fim do sync |
| Importação XML no DefectDojo | ⬜ Pendente | — |

### Lições do PRJ020

- **L05 (Kali como appliance):** Kali Linux nativo para GVM é mais estável que Ubuntu 24.04 + Docker, desde que as atualizações sejam **controladas manualmente** (`apt upgrade --no-upgrade gvm*`) e não automáticas (`full-upgrade` proibido sem teste).
- **L06 (Feeds rsync são lentos mas confiáveis):** O primeiro sync dos feeds SCAP/CERT leva 1-3 horas — planejar isso como tempo de setup, não como falha.
- **L07 (Bug cosmético não impede operação):** O erro `GLib-CRITICAL: g_file_get_contents` no `gvm-check-setup` é um warning inofensivo — o gsad funciona normalmente.
- **L08 (Remoção da GUI libera recursos significativos):** Após `multi-user.target`, o Kali consumiu apenas 464 MB RAM vs. ~1.5 GB com GUI.

---

## 15. Lições Aprendidas Transversais

*(conteúdo mantido inalterado da v2.0, com adição das lições do PRJ020)*

### Lições do PROJ020 incorporadas:

**L05: Kali Linux como appliance funciona para scanners**
- Kali Rolling com atualizações manuais e seletivas (`--no-upgrade gvm*`) é estável para uso como servidor de scan
- Remoção da GUI (`multi-user.target`) libera recursos significativos (464 MB RAM vs. 1.5 GB)
- Scripts `gvm-start/stop/check-setup` da Offensive Security são mais confiáveis que PPAs de terceiros

**L06: Feeds rsync são lentos mas confiáveis**
- O primeiro sync dos feeds SCAP/CERT leva 1-3 horas — planejar isso como tempo de setup
- Não interromper o processo; logs mostram downloads ativos de CVE de 2000 a 2026

**L07: Bugs cosméticos não impedem operação**
- O erro `GLib-CRITICAL: g_file_get_contents` no `gvm-check-setup` é um warning inofensivo do script de verificação — o gsad funciona normalmente

**L08: Remoção da GUI libera recursos significativos**
- Kali com `multi-user.target` consumiu apenas 464 MB RAM vs. ~1.5 GB com GUI
- Essencial para VM dedicada com recursos limitados (4-8 GB RAM)

**L09: Docker não é solução universal para permissões de rede**
- OpenVAS precisa de `CAP_NET_RAW` que mesmo containers privilegiados podem ter bloqueado por AppArmor/Kernel (PRJ020)

---

## 16. Frameworks de Conformidade Adotados

*(conteúdo mantido inalterado da v2.0)*

---

## 17. Inventário de Ativos e Topologia de Rede

### VMs Ativas (estado em abr/2026, atualizado com PROJ020)

| VM (Hyper-V) | Hostname | Função | IP Local | IP Tailscale | Status |
|--------------|----------|--------|----------|--------------|--------|
| VAULT-GEN1 | vault-gf-01 | HashiCorp Vault 1.21.3 | 172.25.25.41 | xxx.xxx.xxx.xxx | ✅ Ativo |
| rh-gf-01-local | rh-gf-01 | OrangeHRM 5.x + MariaDB | 192.168.70.11 | Ativo via mesh | ✅ Ativo |
| iga-gf-01 | iga-gf-01 | midPoint 4.10 (original) | 192.168.70.10 | Ativo via mesh | ✅ Ativo |
| iga-gf-02 | iga-gf-02 | midPoint 4.10 (instalação limpa) | 192.168.111.153 | xxx.xxx.xxx.xxx | ✅ Ativo |
| api-gf-01 | api-gf-01 | Shadow API FastAPI (PRJ008) | 192.168.99.64 | xxx.xxx.xxx.xxx | ✅ Ativo |
| **defectdojo-gf-01** | **defectdojo-gf-01** | **DefectDojo (Docker)** | — | **xxx.xxx.xxx.xxx** | ✅ **Ativo (PROJ020)** |
| **sec-openvas-kali** | **kali** | **GVM (OpenVAS) nativo** | — | **xxx.xxx.xxx.xxx** | ✅ **Ativo (PROJ020)** |
| ID-P-01 | id-p-01 | AD DS (corp.fiqueok.com.br) | xxx.xxx.xxx.xxx | — | ✅ Ativo |
| ldap-gf-01 | ldap-gf-01 | OpenLDAP | — | — | ⚠️ Dependente de VSwitch |

### Serviços por VM (adições do PROJ020)

**defectdojo-gf-01:**
- DefectDojo Community Edition via Docker (porta 8080)
- Tailscale via systemd (IP fixo xxx.xxx.xxx.xxx)
- Credencial admin: `K6hiVpTKlkn8Jox705unHP`

**sec-openvas-kali:**
- GVM (Greenbone Vulnerability Manager) 25.04.0 via pacote nativo `gvm`
- GSA (Greenbone Security Assistant) na porta 9392
- Tailscale via systemd (IP fixo xxx.xxx.xxx.xxx)
- Credencial admin: `**********`
- Usuário administrativo: `paulo` (sudo)
- Modo appliance: `multi-user.target`, GUI desligada

---

## 18. Governança e Gestão de Decisões

*(conteúdo mantido inalterado da v2.0)*

---

## 19. Papel das IAs no Laboratório

*(conteúdo mantido inalterado da v2.0)*

**Complemento do PROJ020:** Nenhuma IA previu que as imagens Docker do Greenbone seriam migradas para registro privado ou que os PPAs para Ubuntu 24.04 estariam quebrados. A recomendação de IA para usar Kali nativo só veio após múltiplas falhas documentadas. Isso reforça o princípio de que IAs são ferramentas de apoio, não substitutas de teste empírico.

---

## 20. Riscos Abertos e Pendências Futuras

### Riscos de Alto Impacto (estado em abr/2026, atualizado com PROJ020)

| Risco | Projeto | Urgência | Ação Necessária |
|-------|---------|----------|-----------------|
| Root token Vault em uso ativo (antipadrão) | PRJ007 | Alta | GMUD dedicada para revogar (PF-006) |
| Token `svc-shadow-api` expira 2026-05-17 | PRJ007/PRJ008 | Urgente | Verificar renovação automática em `api-gf-01` |
| Backup automático Vault não configurado | PRJ007 | Alta | Implementar cron Raft snapshot (PF-005) |
| Auto-unseal não implementado | PRJ007 | Alta | PF-003 — backlog |
| CONSTRAINT-001 (novas VMs GEN2 impossíveis) | Lab | Média | Reinstalação Windows planejada Q2/2026 |
| Vault em GEN1 (sem TPM, Secure Boot) | PRJ007 | Média | PF-001 — migração GEN2 pós-CONSTRAINT |
| TLS desabilitado no listener Vault | PRJ007 | Média | Mitigado por Cloudflare ZT + Tailscale; PF-002 |
| Conector REST indisponível para midPoint 4.10/Java 21 | PRJ008 | Média | Aguardar release oficial ou build customizado |
| **Feeds GVM ainda sincronizando** | **PRJ020** | **Baixa** | **Aguardar 1-3 horas para conclusão** |
| **Kali `apt full-upgrade` pode quebrar GVM** | **PRJ020** | **Média** | **Modo appliance: atualizações manuais e seletivas** |

### Projetos em Fila (atualizado com PROJ020)

| Projeto | Descrição | Dependência |
|---------|-----------|-------------|
| PRJ008 | Shadow API REST / FastAPI — proxy de autenticação Vault | Vault estável (atendido); **Aguardando conector REST** |
| PRJ009 | SSH Secrets Engine — assinatura de chaves para colaboradores | SSH engine já configurado no Vault |
| PRJ016 | Sentinel Identity Shield — blueprint de monitoramento com Prometheus | DEP-001/002/003 atendidas na GMUD-003 |
| PRJ017 | Cloudflare Zero Trust | ✅ Concluído |
| PRJ018 | Migração Perplexity → RAG local (222 conversas) | — |
| **PRJ020** | **OpenVAS/GVM + DefectDojo** | **🟡 Aguardando primeiro scan; pendente integração XML** |
| PRJ021 | Automação OpenVAS → DefectDojo via API | PRJ020 funcional |

---

## 21. Glossário Técnico do Laboratório

*(conteúdo mantido inalterado da v2.0, com adição de termos do PROJ020)*

| Termo | Definição no Contexto Fiqueok |
|-------|-------------------------------|
| **GMUD** | Gestão de Mudança — documento formal de planejamento e execução de mudanças técnicas; inclui escopo, rollback, critérios de sucesso |
| **ADR** | Architecture Decision Record — registro de decisão arquitetural com contexto, alternativas avaliadas, decisão final e consequências |
| **Canvas (CAN-ID)** | Artefato de contrato semântico de identidade — gate obrigatório antes de GMUDs técnicas de IGA |
| **DEC-ID** | Identity Decision Canvas — define tipos de decisão e regras de governança para mudanças de identidade |
| **DGC** | Data Governance Canvas — define retenção, auditabilidade e tratamento dos dados de identidade |
| **Production Checkpoint** | Checkpoint Hyper-V do tipo Production (usa VSS + PostgreSQL Writer) — garante consistência de dados durante rollback |
| **Identidade Canônica** | Representação única e imutável de uma pessoa no domínio IGA, independente de sistemas técnicos |
| **Fail-Closed** | Comportamento de segurança do Vault: se o log de auditoria não puder ser gravado (disco cheio, permissão negada), o serviço para completamente para evitar operações sem rastro |
| **Stop Work Authority** | Autoridade exercida para interromper imediatamente atividade que viola princípio de segurança, independentemente de quem a propôs |
| **Marco Zero** | Snapshot de VMs em estado saneado antes do início de novo projeto — ponto de rollback garantido |
| **Golden Image** | VM template padronizado para clonagem (LINUX-GOLDEN-IMAGE, Win2022-GF) |
| **Unseal** | Processo de desbloqueio do Vault após restart, fornecendo 3 das 5 chaves Shamir para reconstruir a root key |
| **Raft Storage** | Backend de armazenamento integrado do Vault — sem dependência de Consul ou etcd externo, suporta HA futura |
| **JML** | Joiner-Mover-Leaver — ciclo de vida de identidades (admissão, movimentação, desligamento) |
| **GVM** | Greenbone Vulnerability Manager — plataforma open-source de gerenciamento de vulnerabilidades |
| **GSA** | Greenbone Security Assistant — interface web do GVM |
| **NVT** | Network Vulnerability Test — testes de vulnerabilidade do OpenVAS/GVM (95.086 no primeiro sync) |
| **Modo Appliance** | Configuração de Kali Linux sem interface gráfica (`multi-user.target`), com atualizações manuais controladas, para operação como servidor dedicado |
| **TEP de Freezing** | Termo de Encerramento de Projeto com status "FROZEN" — projeto interrompido por bloqueio externo, não por falha de execução |

---

**CONTEXTO_LivingLab_Fiqueok_v2.1.md — Documento de Referência para RAG**  
*Baseado exclusivamente em evidência primária dos vaults Obsidian exportados*  
*Cobrindo PRJ001 a PRJ020 — Dezembro/2025 a Abril/2026*  
*Paulo Feitosa — Living Lab Fiqueok*  
*Gerado com Claude Sonnet como GRC Lead*
