# CONTEXTO — Living Lab Fiqueok

## Documento de Referência para RAG — v3.0

**Gerado em:** Maio de 2026  
**Responsável:** Paulo Feitosa Lima (IAM Specialist / Auditor / GRC Lead)  
**Fonte:** Evidência primária — vaults Obsidian exportados (PRJ001 a PRJ020) + TEPs PRJ009–PRJ019  
**Uso:** Contexto para AnythingLLM + Ollama / DeepSeek-R1  
**Versão anterior:** v2.1 (PRJ001–PRJ020, foco em PRJ020)  
**Esta versão adiciona:** Hiato PRJ009–PRJ019 preenchido com narrativa cronológica completa; lições L09–L35 incorporadas; inventário de ativos atualizado para abril/2026

---

## ÍNDICE

1. Sobre o Living Lab Fiqueok
2. Identidade do Responsável
3. Infraestrutura Base do Laboratório
4. Princípios Arquiteturais Consolidados
5. **Linha do Tempo Narrativa da Saga (PRJ001–PRJ020)**
6. PRJ001 — Laboratório de SI
7. PRJ002 — Infraestrutura Fiqueok
8. PRJ003 — IGA Greenfield (Fundamentos Arquiteturais)
9. PRJ004 — IGA Data Lifecycle (CSV)
10. PRJ005 — Integração de Fonte Autoritativa (OrangeHRM)
11. PRJ006 — Integração Dinâmica via JDBC (Abortado)
12. PRJ007 — HashiCorp Vault (PAM)
13. PRJ008 — Shadow API REST (Integração IGA)
14. **PRJ009 — Hybrid Identity Bridge (Encerrado)** ← NOVO
15. **PRJ010 — Join Massivo OrangeHRM (Concluído)** ← NOVO
16. **PRJ011 — Entra ID Identity JOIN (Concluído)** ← NOVO
17. **PRJ012 — midPoint como Motor IGA On-Premise (Referenciado)** ← NOVO
18. **PRJ014 — Saneamento e Padronização Hyper-V (Concluído)** ← NOVO
19. **PRJ015 — IGA Híbrido Local — AD → Entra Cloud Sync (Encerrado com Aprendizado)** ← NOVO
20. **PRJ016 — Sentinel Identity Shield (Em Execução)** ← NOVO
21. **PRJ017 — Secure Edge Gateway & Identity-First Perimeter (Concluído)** ← NOVO
22. **PRJ018 — Memória de Longo Prazo do Living Lab (Concluído)** ← NOVO
23. **PRJ019 — Watcher e Ingestor Automatizados para Obsidian (Frozen)** ← NOVO
24. PRJ020 — OpenVAS/GVM + DefectDojo (Gestão de Vulnerabilidades)
25. Lições Aprendidas Transversais (L01–L35)
26. Frameworks de Conformidade Adotados
27. Inventário de Ativos e Topologia de Rede
28. Governança e Gestão de Decisões
29. Papel das IAs no Laboratório
30. Riscos Abertos e Pendências Futuras
31. Glossário Técnico do Laboratório

---

## 1. Sobre o Living Lab Fiqueok

O Living Lab Fiqueok é um laboratório de experimentação técnica pessoal, operado por Paulo Feitosa em ambiente doméstico (HomeLab) com Hyper-V sobre Windows 11 Pro. Seu propósito é simular ambientes corporativos reais de IAM (Identity and Access Management) e IGA (Identity Governance and Administration), documentando a jornada com rigor de governança equivalente ao de uma organização Fintech.

O laboratório serve três objetivos simultâneos:

- **Aprendizado aplicado** — implementação real de tecnologias IAM/IGA com falhas, pivôs e soluções documentadas honestamente
- **Portfólio técnico** — evidências públicas de competência para LinkedIn e mercado de trabalho
- **Repositório de conhecimento** — base de referência para futuras consultorias e projetos profissionais

A documentação é produzida integralmente no Obsidian (vault `FiqueokBrain`) e segue o modelo formal de GMUD, ADR, REL e TAP/TEP. O laboratório opera desde dezembro/2025 e está em curso ativo.

---

## 2. Identidade do Responsável

- **Nome:** Paulo Feitosa Lima
- **Perfil profissional:** IAM Specialist / Auditor / GRC Lead
- **Localização:** São Paulo, SP, Brasil
- **Área de atuação:** IAM, IGA, GRC, Microsoft Entra ID, SAP Identity, compliance ISO 27001/SOX
- **Modelo de uso de IAs:** multi-IA com papéis especializados — Claude como GRC Lead e documentador, ChatGPT como arquiteto/executor, Perplexity como pesquisa/inteligência (substituído por RAG local no PRJ018), Gemini para análise (com ressalvas após incidente PRJ007), DeepSeek-R1 como motor de raciocínio local
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

Corrupção do subsistema UEFI do Hyper-V impede criação de novas VMs GEN2. VMs existentes não são afetadas. Sintomas: novas VMs não inicializam com erro "The boot loader did not load"; desligamento via GUI retorna erro `0x800710DF`. `SFC /scannow` e `DISM /RestoreHealth` não corrigem. A CONSTRAINT-001 foi comprovada também como fator de bloqueio na **recuperação** de VMs GEN2 existentes (caso `FOK-SRV-LDAP-01`, perdida em 23/04/2026 — PRJ014 v1.3). Workaround ativo: uso de GEN1 ou WSL2. Resolução definitiva planejada para Q2/2026 (reinstalação do Windows).

---

## 4. Princípios Arquiteturais Consolidados

Estes princípios foram destilados a partir das evidências de PRJ001 a PRJ020. Cada um foi validado empiricamente — a maioria por uma falha que o tornou necessário.

1. **Decisão antes da automação** — contratos de identidade (canvases, ADRs) devem preceder qualquer GMUD técnica. Regra formalizada no PRJ003.
2. **Identidade canônica explícita** — o identificador único e imutável da pessoa deve ser definido no IGA, não herdado de sistemas externos.
3. **Idempotência como regra** — scripts e configurações devem poder ser executados múltiplas vezes sem efeitos colaterais.
4. **API-first, nunca JDBC direto** — acessar banco de dados de terceiros diretamente é anti-padrão arquitetural. Comprovado por 30 dias de esforço perdido no PRJ006.
5. **WSL2 não é plataforma para workloads críticos** — falhas estruturais de systemd, rede e persistência foram comprovadas empiricamente no PRJ007 e reconfirmadas no PRJ019.
6. **Blast radius controlado** — rollback via checkpoint Hyper-V é o mecanismo oficial de reversão. Production Checkpoints obrigatórios antes de qualquer mudança técnica.
7. **Documentação como parte do sistema** — GMUDs, ADRs, TAPs e RELs são ativos técnicos, não burocracia.
8. **Infraestrutura como alicerce, não afterthought** — IPs estáticos, rede estável e segmentação devem preceder qualquer integração.
9. **Validações empíricas superam análises sintéticas de IA** — testes de ciclo completo obrigatórios antes de encerrar qualquer fase.
10. **IaC com gestão de segredos via .env** — credenciais hardcoded são estritamente proibidas em qualquer artefato.
11. **Distros especializadas para ferramentas complexas** — Ubuntu LTS 24.04 não é ideal para GVM; Kali Linux nativo provou-se mais estável (PRJ020).
12. **Docker não é solução universal para permissões de rede** — scanners como OpenVAS precisam de `CAP_NET_RAW` que pode ser bloqueado por AppArmor/Kernel (PRJ020 e PRJ019).
13. **Single Source of Truth define a arquitetura híbrida** — a fonte de verdade (AD vs. Entra) deve ser definida *antes* da criação de qualquer objeto. Criar usuários no Entra antes de sincronizar gera conflito estrutural irreconciliável (PRJ015 — L27/L28).
14. **Encerrar e documentar é tão válido quanto concluir** — projetos abortados com lições capturadas geram valor permanente ao portfólio (PRJ009, PRJ015, PRJ019).

---

## 5. Linha do Tempo Narrativa da Saga (PRJ001–PRJ020)

Esta seção conta a história cronológica do Living Lab, incluindo o hiato PRJ009–PRJ019 que estava ausente na v2.1.

| Período | Projeto | Status | Resultado Principal |
|---------|---------|--------|---------------------|
| Dez/2025 | PRJ001 | ✅ Concluído | Baseline de SI; migração VirtualBox → Hyper-V; scans OpenVAS; hardening inicial |
| Jan/2026 | PRJ002 | ✅ Concluído | Infra core (AD, midPoint, OrangeHRM); 25+ GMUDs; incidente de rede; domínio `corp.fiqueok.com.br` |
| Jan/2026 | PRJ003 | ✅ Concluído | Fundamentos arquiteturais IGA Greenfield; Canvases de Identidade; midPoint 4.10 funcional |
| Jan/2026 | PRJ004 | ✅ Concluído | CSV como fonte autoritativa; primeiro ciclo JML completo validado |
| Fev/2026 | PRJ005 | ✅ Concluído | OrangeHRM como fonte autoritativa; conectividade JDBC segura estabelecida em 2 dias |
| Fev/2026 | PRJ006 | ⚠️ Abortado | Anti-padrão JDBC identificado; decisão API-first formalizada; higiene de infraestrutura executada |
| Fev–Abr/2026 | PRJ007 | 🟡 Ativo | HashiCorp Vault operacional em GEN1; 3 plataformas tentadas; GMUD-003 executada abr/2026 |
| Abr/2026 | PRJ008 | 🟡 Aceitação Parcial | Shadow API REST certificada; integração midPoint via DatabaseTable Connector; conector REST nativo indisponível |
| **Fev–Mar/2026** | **PRJ009** | **⚠️ Encerrado** | **Hybrid Identity Bridge abortada por expiração de créditos Azure; SSH CA com Vault validada; Tailscale consolidado** |
| **Fev/2026** | **PRJ010** | **✅ Concluído** | **Join massivo de 100 colaboradores FinPay no OrangeHRM; RH como Fonte Autoritativa; POP-IAM-001 homologado** |
| **Mar/2026** | **PRJ011** | **✅ Concluído** | **100 identidades provisionadas no Entra ID (tenant fiqueok.com.br); 10 grupos RBAC GRP_\*; POP-IAM-002 entregue** |
| **Mar/2026** | **PRJ012** | **🔄 Referenciado** | **midPoint como motor IGA on-premise; App Registration Service Principal configurado** |
| **Mar–Abr/2026** | **PRJ014** | **✅ Concluído** | **Saneamento Hyper-V; Golden Disk mestre substituído; FOK-SRV-LDAP-01 perdida por CONSTRAINT-001** |
| **Mar–Abr/2026** | **PRJ015** | **⚠️ Encerrado com Aprendizado** | **Cloud Sync falhou por conflito cloud-first vs. sync-first; 99 usuários purgados; tenant mantido limpo** |
| **Abr/2026** | **PRJ016** | **🔵 Em Execução** | **Sentinel Identity Shield — ITDR com Wazuh + eBPF (Tetragon); observabilidade de segurança cloud-native** |
| **Abr/2026** | **PRJ017** | **✅ Concluído** | **Cloudflare Zero Trust; exposição segura de Shadow API, OrangeHRM e midPoint via OTP; superfície de ataque eliminada** |
| **Abr/2026** | **PRJ018** | **✅ Concluído** | **Migração Perplexity → RAG local; 222 conversas extraídas; AnythingLLM + Ollama + DeepSeek-R1 operacionais** |
| **Abr/2026** | **PRJ019** | **❌ Frozen** | **Watcher/Ingestor Obsidian abortado por incompatibilidade Vault Agent + WSL2; CAP_SETFCAP bloqueado pelo kernel** |
| Abr/2026 | PRJ020 | 🟢 Fase B Concluída | DefectDojo operacional; Kali Linux + GVM funcionando; aguardando primeiro scan da API PRJ008 |

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

## 14. PRJ009 — Hybrid Identity Bridge (Encerrado)

**Período:** Fevereiro–Março de 2026  
**Status:** ⚠️ ENCERRADO / ESTRATÉGIA DESCONTINUADA  
**Sucessor:** PRJ014

### Contexto e Objetivos

O PRJ009 nasceu como um **experimento de arquitetura híbrida** com objetivo de validar a conectividade entre o OrangeHRM hospedado em PaaS Azure e o midPoint local, utilizando uma VM Gateway (`fiqueok-prj009-gtw-canada`) como ponte de identidade. O projeto carregava também o objetivo de preparação para o exame AZ-305.

### O Que Foi Entregue

| Entregável | Status |
|------------|--------|
| SSH Certificate Authority com HashiCorp Vault (POP-SSH-CA-PRJ009-v3.0) | ✅ Entregue — conceito validado |
| VM Azure Gateway operacional | ✅ Criada — depois desprovisionada |
| Tailscale mesh consolidado como backbone de conectividade | ✅ — permanece como legado estrutural do Living Lab |
| Validação de identidade rastreável com persona `laszlo.bock` | ✅ Entregue |
| ADR-PRJ009-001 e ADR-PRJ009-002 | ✅ Entregues |

### Causa do Encerramento

A subscrição de avaliação Azure expirou, criando risco de custo residual. Simultaneamente, surgiu uma demanda externa real (DPSP) com necessidade de Microsoft Entra Cloud Sync, o que justificou o redirecionamento estratégico. A manutenção da VM Gateway consumiria tempo e recursos sem alinhamento com os objetivos então atuais.

A decisão foi formalizada no ADR-PRJ009-002: **encerrar e documentar**, em vez de migrar a VM para o HomeLab (perderia Managed Identity) ou manter com recursos próprios (custo desnecessário).

### Lições Aprendidas

| ID | Lição |
|----|-------|
| L09 | Projetos híbridos com componentes pagos devem ter plano de continuidade financeira claro desde o TAP |
| L10 | O custo de oportunidade de manter infraestrutura não utilizada supera o valor do aprendizado marginal |
| L11 | Documentar a decisão de abortar é tão importante quanto documentar sucessos |

---

## 15. PRJ010 — Join Massivo OrangeHRM (Concluído)

**Período:** Fevereiro de 2026  
**Status:** ✅ CONCLUÍDO COM SUCESSO  
**POP Homologado:** POP-IAM-001

### Contexto

O PRJ010 executou a **carga massiva e automação do processo Joiner** para 100 colaboradores da empresa fictícia FinPay no OrangeHRM 5.x. O objetivo era estabelecer o RH como Fonte Autoritativa única, garantindo integridade de dados biográficos, financeiros e de acesso — preparando o terreno para o PRJ011 (Entra ID).

### Entregas e Resultados

- **100% dos colaboradores** da `Lista De Funcionarios.txt` foram provisionados no OrangeHRM
- **Integridade financeira:** transposição de salários concluída após saneamento de metadados
- **Governança RBAC:** matriz de acesso vinculando `SecurityGroups` a `User Roles` implementada
- **POP-IAM-001** homologado para replicação futura

### Incidentes Gerenciados

| Incidente | Categoria | Mitigação |
|-----------|-----------|-----------|
| Divergência de Metadados — falha no JOIN de Cargos/Departamentos | Integridade | Injeção massiva de Job Titles via script antes da carga |
| Violação de FK (Pay Period) — Erro 1452 na inserção de salários | Compliance | Saneamento da tabela `hs_hr_payperiod` |
| Inconsistência de String — zero registros afetados inicialmente | Qualidade | Aplicação de `TRIM()` na Fonte Autoritativa |

### Conformidade

- **ISO 27001 A.9.2.2:** Concessão de acesso 100% automatizada, eliminando risco de privilégios por erro manual
- **ISO 27001 A.12.1.2:** Uso de Staging Table isolada no banco `greenfield_hr` para proteger produção

---

## 16. PRJ011 — Entra ID Identity JOIN (Concluído)

**Período:** 01/03/2026 – 06/03/2026  
**Status:** ✅ CONCLUÍDO (OS1–OS4 entregues; OS5–OS7 postergados)  
**Domínio:** `fiqueok.com.br` (Registro.br + Cloudflare DNS)  
**POP Homologado:** POP-IAM-002

### Contexto

Com 100 identidades estabelecidas no OrangeHRM (PRJ010), o PRJ011 provisioning essas identidades no **Microsoft Entra ID** (tenant `fiqueok.com.br`), criando o diretório de nuvem corporativo da FinPay Lab com UPNs profissionais e estrutura RBAC.

### Execução em Dois Sprints

**Sprint 1 — 01/03/2026:** Provisionamento dos 100 usuários via CSV exportado do MariaDB → PowerShell Microsoft Graph API. Correção de erro de splatting (INC01) documentada como L03 no POP-IAM-002.

**Sprint 2 — 06/03/2026:** Criação dos 10 grupos de segurança `GRP_*` e alocação total de 100 membros, eliminando identidades órfãs (INC04 — mapeamento parcial corrigido com adição de `GRP_OPERATIONS`).

### Resultados Finais

| Métrica | Resultado |
|---------|-----------|
| Usuários provisionados no Entra ID | **100** |
| Grupos GRP_* criados | **10** |
| Membros alocados em grupos | **100** |
| Identidades órfãs | **0** |
| Cobertura RBAC | **100%** |

### Decisões de Arquitetura

- **EmployeeID (FP001–FP100)** como `ImmutableID` — âncora de identidade consistente entre OrangeHRM e Entra ID para IGA futura
- **JOIN direto via CSV + PowerShell** (sem midPoint/SCIM) — API OrangeHRM 5.x não expõe endpoints RESTful estáveis para salary + securityGroup
- **Grupos estáticos** (sem licença P2) como estrutura RBAC inicial — tenant Free não suporta Grupos Dinâmicos
- **PRJ009 (midPoint) mantido em FREEZE** — incompatibilidade SQL staging cross-DB identificada como risco

### Pendências Herdadas pelo PRJ012

- Conditional Access (CA-CEO-FIDO2 para C-Level) — requer Entra ID P2
- PIM para Donner Marcos (CSO) e Laszlo Bock (CHRO) — requer P2
- Break-glass account — configuração pendente

---

## 17. PRJ012 — midPoint como Motor IGA On-Premise (Referenciado)

**Período:** Março de 2026  
**Status:** 🔄 Referenciado — continuidade do PRJ011

O PRJ012 foi identificado como sucessor do PRJ011 para implementar o **midPoint como motor IGA on-premise**, substituindo o provisionamento manual via PowerShell por orquestração automatizada. O marco inicial previsto era a criação de um **App Registration no Entra ID** (Service Principal) para permitir que o midPoint operasse com identidade própria — sem dependência de sessões interativas de Paulo.

Não há TEP formal do PRJ012 disponível nesta versão do contexto. Referências ao `svc_midpoint@paulofiqueokcom.onmicrosoft.com` (conta de serviço no Entra) e ao conector REST bloqueado são evidências de esforço parcial.

---

## 18. PRJ014 — Saneamento e Padronização Hyper-V (Concluído)

**Período:** 28/03/2026 – 23/04/2026  
**Status:** ✅ CONCLUÍDO — Golden Disk Mestre Substituído e Homologado  
**Versão Final do TEP:** v1.3 (23/04/2026)

### Contexto

O PRJ014 surgiu como resposta ao crescimento desordenado do parque de VMs e ao débito técnico acumulado de Golden Disks mal gerenciados, checkpoints duplicados e ISOs espalhadas. O objetivo era estabelecer um padrão de infraestrutura Hyper-V limpo e replicável.

### Saga dos Golden Disks

O projeto passou por três ciclos de tentativa e erro antes de chegar ao Golden Disk final homologado:

**Ciclo 1 (v1.0 — 28/03/2026):** Criação do Golden Disk Windows. Falha: GEN2 reprovado no Pre-Flight por metadados de AD DS irremovíveis (o disco havia sido clonado de um DC — erro de design).

**Ciclo 2 (v1.1 — 29/03/2026):** Substituição por `Win2022-GF-PURE-V3-GREENFIELD.vhdx`. Processo de purificação via `Convert-VHD` (merge correto de disco diferencial). Homologação bem-sucedida.

**Ciclo 3 (v1.2 — 01/04/2026):** Segunda reprovação do `Win2022-GF-GEN2.vhdx` — inapto para AD DS por metadados residuais irremovíveis (DCPromo.General.54). Decisão: nunca usar Golden Disk clonado de um DC.

**Adendo v1.3 (23/04/2026) — Perda da FOK-SRV-LDAP-01:** Durante tentativa de recuperação da VM `FOK-SRV-LDAP-01`, confirmou-se que a CONSTRAINT-001 não afeta apenas a *criação* de novas VMs GEN2, mas também a *recuperação* de VMs existentes. A VM não bootava por erro de assinatura UEFI/Secure Boot mesmo com VHDX íntegro. Decisão: remoção definitiva, liberando 7,45 GB.

### Lições de Golden Disk (L12–L22)

| ID | Lição |
|----|-------|
| L12 | Golden Disks GEN2 devem ser criados por clonagem de VM existente, nunca por Sysprep de DC |
| L13 | Limpeza pós-clonagem requer ordem específica: remover Tailscale por último, via console |
| L14 | Checkpoints acumulados impactam performance — consolidar antes de criar Golden Disk |
| L15 | Manter única pasta de ISOs para evitar desperdício de espaço |
| L16 | Pre-Flight obrigatório antes de homologar qualquer Golden Disk |
| L17 | Roles de AD/DNS/DHCP devem ser removidas antes do Sysprep |
| L18 | Microsoft Edge Stable pode bloquear Sysprep — remover Appx problemáticos antes |
| L19 | `Convert-VHD` é o método correto para purificar discos diferenciais (`Merge-VHD` falhou) |
| L20 | Após renomear o Golden Disk mestre, reparar a cadeia diferencial com `Set-VHD -ParentPath` |
| L21 | Nunca usar GD clonado de servidor que foi DC — metadados AD DS são irremovíveis |
| L22 | CONSTRAINT-001 bloqueia também a recuperação de VMs GEN2 existentes, não apenas a criação de novas |

### Inventário Final de VMs (23/04/2026)

| VM | Estado | Observação |
|----|--------|------------|
| api-gf-01 | Executando | Shadow API operacional |
| ID-P-01 | Salva | AD original preservado |
| IGA-GF-02 | Executando | midPoint operacional |
| Linux Lite | Salva | Gateway VM preservada |
| PRJ015-PROD-BASE | Desligada | Base para PRJ015 |
| rh-gf-01-local | Executando | ⚠️ Fora do padrão — pendente migração |
| SYNC-01 | Desligada | VM Cloud Sync Agent |
| VAULT-GEN1 | Executando | HashiCorp Vault operacional |
| FOK-SRV-LDAP-01 | ❌ REMOVIDA | Perda por CONSTRAINT-001 + falhas de sanitização |

---

## 19. PRJ015 — IGA Híbrido Local — AD → Entra Cloud Sync (Encerrado com Aprendizado)

**Período:** 30/03/2026 – 01/04/2026  
**Status:** ⚠️ ENCERRADO COM APRENDIZADO — Sincronização não alcançada por falha arquitetural  
**Versão Final do TEP:** v3.0 (01/04/2026)

### O Que Foi Tentado

Com o Entra ID populado com 100 usuários cloud-only (PRJ011) e o AD on-premises com os mesmos 100 usuários, o PRJ015 tentou conectar os dois mundos via **Entra Cloud Sync Agent** instalado na VM `SYNC-01`.

### A Falha Arquitetural Fundamental

**Causa Raiz:** O Entra ID não foi projetado para "começar cloud-only e depois decidir sincronizar". O modelo híbrido saudável exige que a fonte de verdade seja definida *antes* da criação dos objetos.

| Problema | Impacto |
|----------|---------|
| Conflito de proxyAddresses | Objetos duplicados impediam o soft-match |
| OnPremisesImmutableId residual | Bloqueava o hard-match |
| Objetos "zumbis" na lixeira do Entra | Continuavam indexados, causando conflitos invisíveis |
| Soft-match falhou sistematicamente | O Entra não vinculou objetos do AD aos existentes |

O princípio violado foi o **Single Source of Truth (SSoT)**: ao popular o Entra diretamente antes de qualquer plano de sincronização, criou-se uma segunda fonte autoritativa paralela ao AD.

> **Nota sobre suporte de IA:** As ferramentas de IA utilizadas focaram em resolução de sintomas sem identificar a falha arquitetural subjacente. Essa abordagem reativa contribuiu para o agravamento do estado do tenant (L33).

### Decisão Final (v3.0)

A decisão inicial (v2.0) era recriar o tenant do zero. Após análise de trade-offs, foi **revisada**: o tenant foi mantido, com 99 usuários cloud-only purgados via PowerShell + Graph API. Usuários preservados: `fiqueok@fiqueok.com.br`, `laszlo.bock@fiqueok.com.br`, `sso-teste@fiqueok.com.br` e contas de serviço `.onmicrosoft.com`.

Motivo para não excluir o tenant: dependências de projetos anteriores (PRJ007, PRJ009, PRJ012), Azure Workspace Analytics com dados não descartáveis, e contas de serviço vinculadas (`svc_midpoint`, `ADToAADSyncServiceAccount`, etc.) que requeriam inventário completo antes de qualquer ação.

### Lições Aprendidas (L27–L35)

| ID | Lição |
|----|-------|
| L27 | Defina a fonte de verdade antes de criar qualquer usuário — AD ou Entra, nunca ambos simultaneamente |
| L28 | Nunca crie usuários no Entra que serão sincronizados depois — sync-first: AD cria → Entra espelha |
| L29 | Objetos deletados (soft-delete) continuam ocupando namespace — purgue imediatamente quando há conflito |
| L30 | O Graph Explorer e o portal enxergam menos que o backend — usar `az rest` para limpeza profunda |
| L31 | O Provision on Demand é o melhor teste, mas não é suficiente — falha no piloto indica problema estrutural |
| L32 | Deletar e recriar não é fraqueza — é decisão estratégica quando custo de limpeza supera benefício |
| L33 | Ferramentas de IA resolvem sintomas, não causas — validar a causa raiz antes de seguir qualquer orientação técnica de IA |
| L34 | Decisão de excluir tenant exige inventário completo antes — mapear contas de serviço, apps, analytics e licenças |
| L35 | Trade-offs de dependências podem mudar decisões já tomadas — mudar é governança, não inconsistência |

---

## 20. PRJ016 — Sentinel Identity Shield (Em Execução)

**Período:** Abril de 2026  
**Status:** 🔵 EM EXECUÇÃO  
**Documento:** Blueprint v1.0

### Missão

O PRJ016 implementa uma camada de **Observabilidade de Segurança Cloud-Native** sobre o ecossistema IGA do Living Lab, tratando a **identidade como o novo perímetro** de segurança. Em uma rede mesh criptografada ponta a ponta (Tailscale ZTNA), ferramentas tradicionais de inspeção de rede tornam-se cegas. A solução desloca a inteligência de detecção para duas camadas: o **kernel do SO** (via eBPF/Tetragon) e a **camada de aplicação** (APIs L7).

Categoria: **ITDR — Identity Threat Detection and Response**.

### Objetivos

| # | Objetivo | Métrica |
|---|----------|---------|
| O1 | Visibilidade 100% de chamadas de sistema nos containers IGA | Zero eventos perdidos no Tetragon → Wazuh |
| O2 | Descoberta de Shadow APIs não documentadas no stack OrangeHRM/midPoint | 100% dos endpoints catalogados |
| O3 | MTTD de ataques BOLA < 60 segundos | Alerta no Wazuh em até 60s após simulação |
| O4 | Resposta automática de isolamento de nó via Tailscale em < 2 minutos | Workflow n8n executado com sucesso |
| O5 | Conformidade com ISO 27001 A.12.4 e A.12.7 | Logs assinados com retenção mínima de 30 dias |

### Stack Tecnológica

- **Wazuh** — SIEM/HIDS centralizado, coleta de eventos de todos os nós via agentes
- **Tetragon (eBPF)** — DaemonSet por VM, visibilidade de syscalls nos namespaces IGA
- **n8n** — Orquestrador de resposta automática (isolamento Tailscale)

### Alinhamento ISO 27001

| Controle | Implementação |
|----------|---------------|
| A.12.4.1 — Registro de eventos | Wazuh coletando eventos de todos os nós IGA |
| A.12.4.2 — Proteção de logs | Arquivos `archives.json` assinados em volume externo persistente |
| A.12.4.3 — Logs de administrador | Sysmon EID 4624/4625/4648 do AD encaminhados ao Wazuh |
| A.12.7.1 — Controles de auditoria | Trilhas Tetragon para cada `execve` nos namespaces IGA |

---

## 21. PRJ017 — Secure Edge Gateway & Identity-First Perimeter (Concluído)

**Período:** Concluído em 18/04/2026  
**Status:** 🟢 CONCLUÍDO / CERTIFICADO  
**Stack:** Cloudflare Zero Trust · Ubuntu 24.04 LTS · systemd · FastAPI · HashiCorp Vault · Tailscale

### O Problema Resolvido

Antes do PRJ017, os sistemas do Lab operavam com **exposição direta de portas** na rede Tailscale — qualquer dispositivo na malha VPN alcançava endpoints sem autenticação adicional:

| Sistema | Porta | Risco |
|---------|-------|-------|
| Shadow API (PRJ008) | :8000 | Acesso a endpoints sem autenticação |
| OrangeHRM | :8085 | Acesso ao painel RH sem Zero Trust |
| midPoint IGA | :8080 | Console de administração exposto |

### O Que Foi Entregue

- **3 conectores `cloudflared`** instalados como serviço `systemd` em api-gf-01, rh-gf-01 e iga-gf-02
- **3 túneis Cloudflare** ativos: `api.fiqueok.com.br`, `rh.fiqueok.com.br`, `iga.fiqueok.com.br`
- **Políticas Zero Trust OTP** configuradas para cada aplicação via Cloudflare Access
- **Shadow API migrada para daemon `shadow-api.service`** (systemd), eliminando dependência de sessão ativa
- **Crontab de renovação automática do token Vault** (daily 00h) em api-gf-01

### Resultado Estratégico

A identidade passou a ser o perímetro. Nenhuma porta dos sistemas protegidos está mais acessível pela internet ou pela rede Tailscale sem autenticação Cloudflare Access com OTP por e-mail. Superfície de ataque externa **eliminada**.

### Alinhamento de Conformidade

- **ISO 27001 A.6.2.2** — Teleworking: controles formais de acesso remoto
- **ISO 27001 A.9.4.2** — Procedimentos seguros de log-on
- **CIS Controls v8 — 6.3** — Autenticação multifator obrigatória
- **NIST CSF PR.AC-3** — Gestão de acesso remoto

---

## 22. PRJ018 — Memória de Longo Prazo do Living Lab (Concluído)

**Período:** 18/04/2026 – 24/04/2026  
**Status:** ✅ CONCLUÍDO COM SUCESSO  
**Duração:** 7 dias

### Objetivo

Substituir o uso da plataforma Perplexity como repositório de conhecimento por um ecossistema **100% local, soberano e rastreável** — eliminando dependência de serviço SaaS e estabelecendo memória de longo prazo para o Living Lab.

### Entregas

| Entrega | Resultado |
|---------|-----------|
| Extração de 222 conversas do Perplexity | ✅ Arquivos Markdown com frontmatter YAML |
| Instalação Ollama (Qwen2.5:7b, DeepSeek-R1:7b) | ✅ Modelos locais operacionais |
| AnythingLLM Desktop configurado | ✅ Interface principal para RAG local |
| Vane (alternativa web) | ✅ Rodando em `http://localhost:3000` |
| Indexação de 495+ documentos (PRJ001–PRJ018) | ✅ Organizados em 5 camadas temáticas |
| Workspace consolidado "Living Lab Fiqueok" | ✅ Respostas coerentes com citação de fontes |

### Stack Tecnológica Final

| Componente | Tecnologia | Uso |
|------------|------------|-----|
| LLM principal | Qwen2.5:7b (4.7 GB) | Chat e análise em português |
| LLM alternativo | DeepSeek-R1:7b (4.7 GB) | Raciocínio profundo (fallback) |
| Embedding | nomic-embed-text-v1 (768 dim) | Vetorização multilíngue |
| Interface principal | AnythingLLM Desktop | RAG local com workspaces |
| Interface alternativa | Vane (Docker) | Busca e testes |
| Vector Database | LanceDB (embedded) | Armazenamento de embeddings |
| Orquestrador | Ollama 0.21.0 | Servidor de inferência local |

### Desafio de Extração do Perplexity

A extração das 222 conversas exigiu contornar: Google OAuth (bloqueio de navegadores automatizados), Cloudflare Turnstile (verificações de hardware e IP), cookies HttpOnly e conteúdo dinâmico carregado sob demanda. A solução foi `launch_persistent_context` do Playwright com perfil local persistente — login manual único, sessão reutilizada pelo script automaticamente nas 229 threads.

### Significado Estratégico

O PRJ018 encerrou a dependência do Perplexity e estabeleceu **soberania de dados**: todo o conhecimento acumulado no Living Lab (PRJ001–PRJ018) passou a residir localmente, indexado e consultável via LLM rodando no próprio host. O documento de contexto `CONTEXTO_LivingLab_Fiqueok_v2.1.md` foi o primeiro artefato gerado para alimentar esse sistema.

---

## 23. PRJ019 — Watcher e Ingestor Automatizados para Obsidian (Frozen)

**Período:** 24/04/2026  
**Status:** ❌ ENCERRADO SEM SUCESSO (FREEZED)  
**Versão Final do TEP:** v3.0

### Objetivo

Criar um sistema de ingestão automática de novos documentos do vault Obsidian para o AnythingLLM local, composto por:
- **Watcher:** monitora a pasta do vault em tempo real (Watchdog)
- **Ingestor:** API FastAPI que processa e envia documentos ao AnythingLLM
- **Vault Agent (Sidecar):** fornece token de autenticação via AppRole, eliminando secrets hardcoded

### O Que Funcionou

O código foi desenvolvido com sucesso em ambiente isolado:

| Componente | Status |
|------------|--------|
| API Service (FastAPI) | ✅ Código funcional em testes isolados |
| Watcher (Watchdog) | ✅ Implementado com Bind Mounts |
| Vault Client (leitura de sink) | ✅ Implementado |
| Dockerfile e containerização | ✅ Imagem construída com sucesso |
| Configuração Vault (política + role) | ✅ AppRole configurado no vault-gf-01 |

### O Impedimento Irreconciliável

**Falha Crítica:** O Vault Agent (hashicorp/vault:1.15) não consegue iniciar no Docker Desktop Windows/WSL2 com hardening habilitado (usuário não-root UID 1000:1000 + mlock).

```
prj019-vault-agent  | unable to set CAP_SETFCAP effective capability: Operation not permitted
prj019-vault-agent exited with code 1
```

**Causa Raiz:** O kernel WSL2 não implementa o conjunto completo de Linux Capabilities necessário para o Vault Agent em modo não-privilegiado. `CAP_SETFCAP` é requerida e não pode ser adicionada via `cap_add` no Windows.

Seis tentativas de configuração diferentes (com e sem `disable_mlock`, diferentes combinações de `cap_add/cap_drop`, `security_opt: no-new-privileges`) — todas falharam. Rodar como `root` funcionaria, mas foi rejeitado pela governança interna (PAD-002).

**Conclusão do Diagnóstico:** O Vault Agent no modelo Sidecar **não é compatível com Docker Desktop Windows/WSL2** quando se exige hardening. A limitação está no kernel WSL2, reconfirmando o Princípio Arquitetural nº 5 do Living Lab.

### Alternativas para Versão Futura

| Alternativa | Viabilidade | Segurança |
|-------------|-------------|-----------|
| Vault Agent com `user: root` + compensações documentadas | Alta | ⚠️ Aceito com risco documentado |
| API consome Vault diretamente via AppRole (variáveis injetadas) | Alta | ✅ Aceitável |
| Migrar workload para VM Linux dedicada no Hyper-V | Média | ✅ Ideal |
| Docker Secrets (modo swarm) | Média | ✅ Aceitável |

---

## 24. PRJ020 — OpenVAS/GVM + DefectDojo (Gestão de Vulnerabilidades)

**Período:** Abril/2026  
**Status:** 🟢 Fase B Concluída — GVM operacional em Kali, aguardando primeiro scan da API PRJ008

*(conteúdo mantido inalterado da v2.1)*

---

## 25. Lições Aprendidas Transversais (L01–L35)

### Lições L01–L08 (v2.0 — PRJ001–PRJ008)

*(mantidas inalteradas da v2.0)*

### Lições L09–L11 (PRJ009 — Hybrid Identity Bridge)

| ID | Lição | Origem |
|----|-------|--------|
| L09 | Projetos híbridos com componentes pagos devem ter plano de continuidade financeira claro desde o TAP | PRJ009 |
| L10 | Custo de oportunidade de manter infraestrutura não utilizada supera o valor do aprendizado marginal | PRJ009 |
| L11 | Documentar a decisão de abortar é tão importante quanto documentar sucessos | PRJ009 |

### Lições L12–L22 (PRJ014 — Saneamento Hyper-V)

*(detalhadas na seção 18 — PRJ014)*

### Lições L23–L26 (PRJ018 — Memória de Longo Prazo)

| ID | Lição | Origem |
|----|-------|--------|
| L23 | RAG local com Ollama é viável em hardware consumer (i5 + 64 GB) para documentação técnica | PRJ018 |
| L24 | Extração de dados de plataformas SaaS exige estratégia de persistência de sessão real, não automação pura | PRJ018 |
| L25 | Soberania de dados começa com a decisão de não depender de um SaaS como repositório de memória organizacional | PRJ018 |
| L26 | Camadas temáticas de indexação são mais eficientes que indexação monolítica para RAG de qualidade | PRJ018 |

### Lições L27–L35 (PRJ015 — Cloud Sync)

*(detalhadas na seção 19 — PRJ015)*

### Lições do PRJ019 (Vault Agent + WSL2)

| Lição | Descrição |
|-------|-----------|
| Conflito de camadas | Controles de segurança rígidos em ambientes não preparados causam indisponibilidade total — validar compatibilidade antes do TAP |
| Vault Agent não é universal | Otimizado para Kubernetes/Linux nativo; não compatível com Docker Desktop Windows/WSL2 em modo hardened |
| Rollback de arquitetura "Zero Secrets" | Exige limpeza em múltiplas camadas: revogar SecretID → remover Role → remover Policy |

### Lições do PRJ020 (GVM/OpenVAS)

| ID | Lição | Origem |
|----|-------|--------|
| L05 | Kali Linux nativo para GVM é mais estável que Ubuntu 24.04 + Docker, com atualizações manuais seletivas | PRJ020 |
| L06 | Primeiro sync dos feeds SCAP/CERT leva 1-3 horas — planejar como tempo de setup, não falha | PRJ020 |
| L07 | Bug cosmético `GLib-CRITICAL` no `gvm-check-setup` é inofensivo — gsad funciona normalmente | PRJ020 |
| L08 | Remoção da GUI (`multi-user.target`) libera recursos significativos: 464 MB vs. 1.5 GB com GUI | PRJ020 |
| L09 | Docker não é solução universal para scanners que requerem `CAP_NET_RAW` | PRJ020 |

---

## 26. Frameworks de Conformidade Adotados

*(conteúdo mantido inalterado da v2.0)*

---

## 27. Inventário de Ativos e Topologia de Rede

### VMs Ativas (estado em abr/2026)

| VM (Hyper-V) | Hostname | Função | IP Local | IP Tailscale | Status |
|--------------|----------|--------|----------|--------------|--------|
| VAULT-GEN1 | vault-gf-01 | HashiCorp Vault 1.21.3 | 172.25.25.41 | xxx.xxx.xxx.xxx | ✅ Ativo |
| rh-gf-01-local | rh-gf-01 | OrangeHRM 5.x + MariaDB | 192.168.70.11 | Ativo via mesh | ✅ Ativo ⚠️ Fora do padrão de diretório |
| iga-gf-01 | iga-gf-01 | midPoint 4.10 (original) | 192.168.70.10 | Ativo via mesh | ✅ Ativo |
| iga-gf-02 | iga-gf-02 | midPoint 4.10 (instalação limpa) | 192.168.111.153 | xxx.xxx.xxx.xxx | ✅ Ativo |
| api-gf-01 | api-gf-01 | Shadow API FastAPI (PRJ008) | 192.168.99.64 | xxx.xxx.xxx.xxx | ✅ Ativo |
| defectdojo-gf-01 | defectdojo-gf-01 | DefectDojo (Docker) | — | xxx.xxx.xxx.xxx | ✅ Ativo |
| sec-openvas-kali | kali | GVM (OpenVAS) nativo | — | xxx.xxx.xxx.xxx | ✅ Ativo |
| ID-P-01 | id-p-01 | AD DS (corp.fiqueok.com.br) | xxx.xxx.xxx.xxx | — | ✅ Ativo (Salva) |
| SYNC-01 | sync-01 | Entra Cloud Sync Agent (PRJ015) | — | — | ⚠️ Desligada |
| Linux Lite | — | Gateway VM preservada | — | — | ⚠️ Salva |
| FOK-SRV-LDAP-01 | — | OpenLDAP | — | — | ❌ REMOVIDA (CONSTRAINT-001) |

### Serviços Cloudflare Zero Trust (PRJ017)

| URL Pública | VM de Destino | Serviço | Autenticação |
|-------------|---------------|---------|--------------|
| `api.fiqueok.com.br` | api-gf-01 | Shadow API FastAPI | OTP por e-mail |
| `rh.fiqueok.com.br` | rh-gf-01 | OrangeHRM | OTP por e-mail |
| `iga.fiqueok.com.br` | iga-gf-02 | midPoint IGA | OTP por e-mail |

### Tenant Microsoft Entra ID

| Tenant | Domínio | Estado (abr/2026) |
|--------|---------|-------------------|
| `paulofiqueokcom.onmicrosoft.com` | `fiqueok.com.br` | Limpo parcialmente — 3 usuários preservados + contas de serviço |

---

## 28. Governança e Gestão de Decisões

*(conteúdo mantido inalterado da v2.0)*

---

## 29. Papel das IAs no Laboratório

*(conteúdo mantido inalterado da v2.0)*

**Complemento desta versão (v3.0):**

- **PRJ015:** Ferramentas de IA focaram em resolução de sintomas sem identificar a falha arquitetural (cloud-first vs. sync-first). A L33 documenta esse padrão.
- **PRJ018:** Perplexity substituído por RAG local. O modelo de uso multi-IA evoluiu: DeepSeek-R1 adicionado como motor de raciocínio local; Ollama/AnythingLLM como plataforma de memória soberana.
- **PRJ019:** Vault Agent Sidecar foi sugerido por IA como arquitetura de segurança ideal — mas nenhuma IA previu a incompatibilidade com WSL2. Reforça: IAs são ferramentas de apoio, não substitutas de teste empírico.
- **PRJ020:** Nenhuma IA previu a migração das imagens Docker do Greenbone para registro privado, os PPAs quebrados para Ubuntu 24.04, nem recomendou Kali nativo proativamente — só após múltiplas falhas documentadas.

---

## 30. Riscos Abertos e Pendências Futuras

### Riscos de Alto Impacto (estado em abr/2026)

| Risco | Projeto | Urgência | Ação Necessária |
|-------|---------|----------|-----------------|
| Root token Vault em uso ativo (antipadrão) | PRJ007 | Alta | GMUD dedicada para revogar (PF-006) |
| Token `svc-shadow-api` expira 2026-05-17 | PRJ007/PRJ008 | **URGENTE** | Verificar renovação automática em api-gf-01 |
| Backup automático Vault não configurado | PRJ007 | Alta | Implementar cron Raft snapshot (PF-005) |
| Auto-unseal não implementado | PRJ007 | Alta | PF-003 — backlog |
| CONSTRAINT-001 (novas VMs GEN2 impossíveis) | Lab | Média | Reinstalação Windows planejada Q2/2026 |
| Vault em GEN1 (sem TPM, Secure Boot) | PRJ007 | Média | PF-001 — migração GEN2 pós-CONSTRAINT |
| TLS desabilitado no listener Vault | PRJ007 | Média | Mitigado por Cloudflare ZT + Tailscale; PF-002 |
| Conector REST indisponível para midPoint 4.10/Java 21 | PRJ008 | Média | Aguardar release oficial |
| Feeds GVM ainda sincronizando | PRJ020 | Baixa | Aguardar 1–3 horas para conclusão |
| Kali `apt full-upgrade` pode quebrar GVM | PRJ020 | Média | Modo appliance — atualizações manuais e seletivas |
| PRJ019 frozen — ingestão Obsidian sem solução | PRJ019 | Baixa | Sessão de revisão arquitetural planejada 27/04/2026 |
| rh-gf-01-local fora do padrão de diretório | PRJ014 | Baixa | Migrar para `C:\Hyper-V\VMs\rh-gf-01-local\` |
| Tenant Entra — inventário completo não executado | PRJ015 | Baixa | Necessário antes de qualquer decisão de exclusão |

### Projetos em Fila

| Projeto | Descrição | Dependência |
|---------|-----------|-------------|
| PRJ016 | Sentinel Identity Shield (Wazuh + eBPF) | Em execução |
| PRJ020 | OpenVAS + DefectDojo — primeiro scan API PRJ008 | 🟡 Aguardando feeds |
| PRJ021 | Automação OpenVAS → DefectDojo via API | PRJ020 funcional |
| PRJ009 Sucessor | SSH Secrets Engine | SSH engine já configurado no Vault |
| PRJ015 Continuidade | Sync-first com tenant limpo | SYNC-01 + tenant parcialmente limpo |
| PRJ019 Redesign | Ingestor Obsidian sem Vault Agent (alternativas documentadas) | Sessão arquitetural |

---

## 31. Glossário Técnico do Laboratório

*(conteúdo mantido inalterado da v2.0, com adições desta versão)*

| Termo | Definição no Contexto Fiqueok |
|-------|-------------------------------|
| **GMUD** | Gestão de Mudança — documento formal de planejamento e execução |
| **ADR** | Architecture Decision Record — registro de decisão arquitetural |
| **Canvas (CAN-ID)** | Artefato de contrato semântico de identidade — gate obrigatório antes de GMUDs técnicas |
| **DEC-ID** | Identity Decision Canvas |
| **DGC** | Data Governance Canvas |
| **Production Checkpoint** | Checkpoint Hyper-V com VSS — garante consistência de PostgreSQL durante rollback |
| **Identidade Canônica** | Representação única e imutável de uma pessoa no domínio IGA |
| **Fail-Closed** | Vault para completamente se o log de auditoria não puder ser gravado |
| **Stop Work Authority** | Autoridade para interromper atividade que viola princípio de segurança |
| **Marco Zero** | Snapshot de VMs antes do início de novo projeto |
| **Golden Image** | VM template padronizado para clonagem |
| **Unseal** | Processo de desbloqueio do Vault após restart (3 de 5 chaves Shamir) |
| **Raft Storage** | Backend de armazenamento integrado do Vault |
| **JML** | Joiner-Mover-Leaver — ciclo de vida de identidades |
| **GVM** | Greenbone Vulnerability Manager |
| **GSA** | Greenbone Security Assistant — interface web do GVM |
| **NVT** | Network Vulnerability Test (95.086 no primeiro sync do PRJ020) |
| **Modo Appliance** | Kali Linux sem GUI (`multi-user.target`) para operação como servidor dedicado |
| **TEP de Freezing** | Termo de Encerramento com status FROZEN — interrompido por bloqueio externo, não falha de execução |
| **CAP_SETFCAP** | Linux Capability exigida pelo Vault Agent — não suportada pelo kernel WSL2 (PRJ019) |
| **Cloud-first** | Modelo onde o Entra ID é a fonte de verdade; AD periférico ou inexistente |
| **Sync-first** | Modelo onde o AD é a fonte de verdade; Entra espelha via Cloud Sync |
| **Soft-match** | Mecanismo do Entra Cloud Sync para vincular objetos cloud a objetos on-premises por UPN/proxyAddresses |
| **Hard-match** | Mecanismo de vinculação por `OnPremisesImmutableId` / `ImmutableID` |
| **ITDR** | Identity Threat Detection and Response — categoria de segurança implementada no PRJ016 |
| **eBPF** | Extended Berkeley Packet Filter — tecnologia de observabilidade de kernel usada pelo Tetragon (PRJ016) |
| **RAG** | Retrieval-Augmented Generation — técnica de IA que enriquece respostas com documentos indexados (PRJ018) |
| **POP-IAM-001** | Procedimento operacional para carga de identidades no OrangeHRM (homologado no PRJ010) |
| **POP-IAM-002** | Procedimento operacional para provisionamento OrangeHRM → Entra ID (homologado no PRJ011) |

---

**CONTEXTO_LivingLab_Fiqueok_v3.0.md — Documento de Referência para RAG**  
*Baseado exclusivamente em evidência primária dos vaults Obsidian exportados*  
*Cobrindo PRJ001 a PRJ020 — Dezembro/2025 a Abril/2026*  
*Hiato PRJ009–PRJ019 preenchido com narrativa cronológica completa nesta versão*  
*Paulo Feitosa Lima — Living Lab Fiqueok*  
*Gerado com Claude Sonnet como GRC Lead — Maio de 2026*

