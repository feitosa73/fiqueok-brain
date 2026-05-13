
# 

## Documento de Referência para RAG — v5.1

**Gerado em:** Maio de 2026  
**Responsável:** Paulo Feitosa Lima (IAM Specialist / Auditor / GRC Lead)  
**Fonte:** Evidência primária — vaults Obsidian exportados (PRJ001 a PRJ030) + TEPs documentados  
**Uso:** Contexto para AnythingLLM + Ollama / DeepSeek-R1  
**Versão anterior:** v5.0 (PRJ001–PRJ030 com decisões estratégicas em transição)  
**Esta versão (v5.1) corrige:** Hierarquia da stack de identidade; descontinuidade estratégica do midPoint; conclusão definitiva do PRJ030; correção do papel do Odoo como consumidor SaaS, não como SoT

---

## ÍNDICE

1. Sobre o Living Lab Fiqueok
2. Identidade do Responsável
3. Infraestrutura Base do Laboratório
4. Princípios Arquiteturais Consolidados
5. **Linha do Tempo Narrativa da Saga (PRJ001–PRJ030)**
6. PRJ001 — Laboratório de SI
7. PRJ002 — Infraestrutura Fiqueok
8. PRJ003 — IGA Greenfield
9. PRJ004 — IGA Data Lifecycle (CSV)
10. PRJ005 — Integração de Fonte Autoritativa (OrangeHRM)
11. PRJ006 — Integração Dinâmica via JDBC (Abortado)
12. PRJ007 — HashiCorp Vault (PAM)
13. PRJ008 — Shadow API REST
14. PRJ009 — Hybrid Identity Bridge (Encerrado)
15. PRJ010 — Join Massivo OrangeHRM
16. PRJ011 — Entra ID Identity JOIN
17. PRJ012 — midPoint como Motor IGA On-Premise (Reavaliado → Descontinuado)
18. PRJ014 — Saneamento e Padronização Hyper-V
19. PRJ015 — IGA Híbrido Local — AD → Entra Cloud Sync (Encerrado)
20. PRJ016 — Sentinel Identity Shield (Em Execução)
21. PRJ017 — Secure Edge Gateway & Identity-First Perimeter
22. PRJ018 — Memória de Longo Prazo
23. PRJ019 — Watcher e Ingestor Automatizados para Obsidian (Frozen)
24. PRJ020 — OpenVAS/GVM + DefectDojo (Gestão de Vulnerabilidades)
25. PRJ022 — Integração IGA: OrangeHRM × midPoint via CSV
26. PRJ023 — Integração midPoint com AWS IAM (Sucesso Parcial)
27. PRJ024 — Integração midPoint com GCP IAM (Sucesso Parcial)
28. PRJ025 — Integração midPoint com Keycloak (Planejado → Cancelado)
29. PRJ026 — Integração midPoint com Active Directory (Planejado → Cancelado)
30. PRJ027 — Integração midPoint com Entra ID Free (Encerrado sem Sucesso)
31. **PRJ028 — Segurança e Acesso Remoto ao Active Directory (Concluído)**
32. **PRJ029 — Odoo ERP como Consumidor de Identidade SaaS (Concluído)**
33. **PRJ030 — Migração Hyper-V → VMware Workstation (Concluído — Resolução Definitiva da CONSTRAINT-001)**
34. **A Nova Stack de Identidade (Pós-midPoint)**
35. Lições Aprendidas Transversais (L01–L95)
36. Frameworks de Conformidade Adotados
37. Inventário de Ativos e Topologia de Rede (Pós-PRJ030)
38. Governança e Gestão de Decisões
39. Papel das IAs no Laboratório
40. Riscos Abertos e Pendências Futuras (Atualizado)
41. Glossário Técnico do Laboratório
42. **Decisões Estratégicas do Living Lab (v5.1)**
43. **Repositório GitHub Público**

---

## 1. Sobre o Living Lab Fiqueok

O Living Lab Fiqueok é um ambiente de laboratório doméstico dedicado ao estudo, implementação e validação de arquiteturas de **Governança de Identidade e Acesso (IGA)** , **Segurança da Informação** e **Automação de Compliance**, utilizando predominantemente tecnologias open-source e serviços cloud free tier.

**Missão:** Demonstrar que é possível construir um ambiente corporativo seguro, auditável e em conformidade com frameworks como ISO 27001 e NIST, com investimento próximo de zero em licenças.

### Escopo Atual (Maio/2026 — Pós-PRJ030)

| Categoria | Componentes |
|-----------|-------------|
| **Source of Truth (SoT)** | OrangeHRM (única fonte autoritativa de RH) |
| **Diretório Local (IDP)** | Active Directory (corp.fiqueok.com.br) — VMware |
| **Diretório Cloud (IDP)** | Microsoft Entra ID Free |
| **Consumidores de Identidade (SaaS)** | Odoo 17.0, futuros ERPs, aplicações SSO |
| **PAM** | HashiCorp Vault |
| **ITDR** | Sentinel (Wazuh + eBPF + Loki + Grafana) |
| **Vulnerabilidades** | OpenVAS/GVM + DefectDojo |
| **Acesso Remoto Seguro** | Tailscale + Cloudflare Zero Trust (MFA) |
| **RAG Local** | AnythingLLM + Ollama (Qwen2.5, DeepSeek-R1) |
| **Hipervisor** | VMware Workstation Pro (migração concluída) |

### Stack de Identidade — Arquitetura Final (Pós-midPoint)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                    STACK DE IDENTIDADE — LIVING LAB FIQUEOK (v5.1)                   │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    ORANGEHRM — SOURCE OF TRUTH (SoT)                             ││
│  │                    (Única fonte autoritativa de RH)                             ││
│  │                                                                                  ││
│  │  Atributos gerenciados:                                                          ││
│  │  • employeeNumber (matrícula — âncora imutável)                                  ││
│  │  • givenName, familyName                                                         ││
│  │  • email, department, jobTitle                                                   ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                             │                                        │
│                                             │ Sincronização manual/automatizada      │
│                                             ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    ACTIVE DIRECTORY (corp.fiqueok.com.br) — IDP Local            ││
│  │                    VMware Workstation — Hardening + Tailscale                    ││
│  │                                                                                  ││
│  │  • Autenticação para recursos on-premise                                         ││
│  │  • GPOs, Kerberos, LDAP                                                          ││
│  │  • Sincronização com Entra ID via Cloud Sync (futuro)                            ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                             │                                        │
│                                             │ Cloud Sync / Entra Connect            │
│                                             ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    MICROSOFT ENTRA ID FREE — IDP Cloud                           ││
│  │                                                                                  ││
│  │  • Autenticação para aplicações SaaS                                             ││
│  │  • SSO (SAML/OIDC) para Odoo e futuros sistemas                                 ││
│  │  • Conditional Access (requer licenças P1/P2 — fora do escopo)                  ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                             │                                        │
│                                             │ SSO (OIDC/SAML)                        │
│                                             ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    APLICAÇÕES CONSUMIDORAS (SaaS)                                 ││
│  │                                                                                  ││
│  │  • Odoo 17.0 (ERP — consome identidade, NÃO é SoT)                              ││
│  │  • Futuros sistemas (ERP financeiro, CRM, etc.)                                  ││
│  └─────────────────────────────────────────────────────────────────────────────────┘││
│                                                                                      │
│  ✅ midPoint REMOVIDO (descontinuado pós-PRJ030)                                     │
│  ✅ Odoo classificado como consumidor, NÃO como Source of Truth                      │
│  ✅ OrangeHRM mantido como única SoT                                                 │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Identidade do Responsável

| Campo | Valor |
|-------|-------|
| **Nome** | Paulo Feitosa Lima |
| **Função** | IAM Specialist / Auditor / GRC Lead |
| **Certificações** | ISO 27001 Lead Implementer (em curso), NIST CSF |
| **Experiência** | 15+ anos em segurança da informação, governança de identidade e gestão de riscos |
| **Decisão Estratégica (Maio/2026)** | Simplificação da stack de identidade — remoção do midPoint, foco em integração direta OrangeHRM → AD → Entra → SaaS |
| **Contato** | Documentado nos vaults Obsidian do laboratório; repositório GitHub público |

O responsável atua como arquiteto, engenheiro de automação, auditor e tomador de decisão (Owner/CISO) no Living Lab. A partir de maio/2026, assume também o papel de **Comunicador Executivo**, documentando publicamente as decisões estratégicas e lições aprendidas.

---

## 3. Infraestrutura Base do Laboratório

### 3.1. Hosts Físicos (Pós-PRJ030)

| Host | Sistema Operacional | Função | Hipervisor | Status |
|------|---------------------|--------|------------|--------|
| **VMware Host** | Windows 11 (ou similar) | Ambiente principal | VMware Workstation Pro 17.x | ✅ **Operacional** |
| **Hyper-V Host (Legado)** | Windows Server 2022 | Ambiente original (descontinuado) | Hyper-V | ⚠️ Aposentado |

### 3.2. Rede e Conectividade (Pós-PRJ030)

| Componente | Tecnologia | Detalhe |
|------------|------------|---------|
| **Overlay Network** | Tailscale (WireGuard) | Mesh criptografada entre todas as VMs e o responsável |
| **MFA** | Cloudflare Zero Trust (Free Tier) | OTP por e-mail para acesso administrativo |
| **DNS Interno** | Active Directory (corp.fiqueok.com.br) | Resolução local |
| **Gateway Padrão** | Conforme configuração do VMware Workstation | Acesso à internet controlado |

### 3.3. CONSTRAINT-001 — RESOLVIDA DEFINITIVAMENTE (PRJ030)

**Problema Original (09/02/2026 a 12/05/2026):** O firmware UEFI do host Hyper-V estava corrompido, impossibilitando:
- Criação de novas VMs GEN2
- Recuperação de VMs GEN2 existentes
- Boot de qualquer mídia de instalação (ISO) no modo UEFI

**Impacto Materializado:**
- Perda da VM `FOK-SRV-LDAP-01` em 23/04/2026 (documentado no TEP-PRJ014-v1.3)

**Solução Definitiva (PRJ030 — Concluído em Maio/2026):**
- Migração total de 11 VMs (600 GB) do Hyper-V para VMware Workstation Pro
- Todas as VMs (incluindo as GEN2 anteriormente em risco) estão agora operacionais em ambiente VMware
- A CONSTRAINT-001 está **encerrada**. O laboratório não está mais sujeito à falha de firmware UEFI.

**Status Atual:**
- ✅ 600 GB de ativos migrados com sucesso
- ✅ SENTINEL-CORE (PRJ016) validado — Wazuh, Loki, Grafana operacionais
- ✅ VAULT-GEN1 (PRJ007) validado — selo e segredos preservados
- ✅ Active Directory (ID-P-01) recriado e funcional
- ✅ Todas as demais VMs (API, OrangeHRM, DefectDojo, Kali, etc.) operacionais

---

## 4. Princípios Arquiteturais Consolidados

1. **Documentação como Evidência de Auditoria** — TEPs, POPs, ADRs e GMUDs são gerados antes ou durante a execução, não apenas retroativamente.
2. **Zero Plaintext** — Todas as credenciais são armazenadas no HashiCorp Vault, nunca em arquivos de configuração.
3. **Snapshot First** — Checkpoint antes de qualquer mudança (rollback determinístico em < 2 minutos).
4. **Privilégio Mínimo** — Firewalls padrão `BlockInbound, AllowOutbound`; acesso apenas via Tailscale.
5. **API-First** — Preferir APIs REST sobre acesso direto a bancos de dados (exceto quando tecnicamente inviável).
6. **Source of Truth (SoT) Única e Imutável** — O OrangeHRM é a única fonte autoritativa para dados de RH. Nenhum outro sistema (incluindo Odoo) tem papel de SoT.
7. **CSV como pipeline IGA válido** — Demonstrado no PRJ022: 102 usuários em 5,1 segundos, 0 erros. Apesar de inconformidade arquitetural, é robusto e operacional.
8. **Conectores comunitários para clouds são limitados** — AWSConnector e GCPConnector provisionam usuários, mas NÃO escrevem grupos/políticas.
9. **Cloud Identity é pré-requisito para GCP** — Sem ele, usuários criados pelo conector não são visíveis.
10. **App Registration sobrevive a qualquer restore local** — Recursos na nuvem persistem; recursos no midPoint são voláteis.
11. **Documente o tipo de dependência** — Contínua (tempo real) vs. pontual (evento único concluído).
12. **midPoint 4.10 tem breaking changes no schema de synchronization** — Tags `<synchronize>` e `<action>` não funcionam mais.
13. **Não confiar cegamente em documentação oficial** — Testar sempre em ambiente de laboratório.
14. **Simplificação da stack é uma decisão estratégica válida** — Remover complexidade (midPoint) em favor de integração direta pode ser mais eficiente que manter ferramentas com bloqueios estruturais.
15. **A infraestrutura deve ser resiliente** — A migração de hipervisor (PRJ030) resolveu definitivamente a CONSTRAINT-001, garantindo a continuidade do laboratório.

---

## 5. Linha do Tempo Narrativa da Saga (PRJ001–PRJ030)

| Período | Projeto | Status | Resultado Principal |
|---------|---------|--------|---------------------|
| Dez/2025 | PRJ001 | ✅ Concluído | Baseline de SI; migração VirtualBox → Hyper-V; scans OpenVAS; hardening inicial |
| Jan/2026 | PRJ002 | ✅ Concluído | Infra core (AD, midPoint, OrangeHRM); retrospectiva arquitetural |
| Jan/2026 | PRJ003 | ✅ Concluído | Fundamentos arquiteturais IGA; 19 tentativas de deploy; "Soberania de Dados" |
| Jan/2026 | PRJ004 | ✅ Concluído | CSV como fonte autoritativa; primeiro ciclo JML completo validado |
| Fev/2026 | PRJ005 | ✅ Concluído | OrangeHRM como SoT; conectividade JDBC segura |
| Fev/2026 | PRJ006 | ⚠️ Abortado | Anti-padrão JDBC identificado; decisão API-first formalizada |
| Fev–Abr/2026 | PRJ007 | 🟡 Ativo | HashiCorp Vault operacional; pendências de segurança em andamento |
| Abr/2026 | PRJ008 | 🟡 Parcial | Shadow API REST certificada; conector REST nativo indisponível |
| Fev–Mar/2026 | PRJ009 | ⚠️ Encerrado | Hybrid Identity Bridge abortada por expiração de créditos Azure |
| Fev/2026 | PRJ010 | ✅ Concluído | Join massivo de 100 colaboradores FinPay no OrangeHRM |
| Mar/2026 | PRJ011 | ✅ Concluído | 100 identidades provisionadas no Entra ID |
| Mar/2026 | PRJ012 | 🟡 Sucesso Parcial → **Descontinuado** | midPoint como motor IGA; artefatos perdidos por rollback |
| Mar–Abr/2026 | PRJ014 | ✅ Concluído | Saneamento Hyper-V; Golden Disk mestre substituído |
| Mar–Abr/2026 | PRJ015 | ⚠️ Encerrado | Cloud Sync falhou por conflito cloud-first vs. sync-first |
| Abr/2026 | PRJ016 | 🔵 Em Execução | Sentinel Identity Shield — ITDR com Wazuh + eBPF |
| Abr/2026 | PRJ017 | ✅ Concluído | Cloudflare Zero Trust; exposição segura via OTP |
| Abr/2026 | PRJ018 | ✅ Concluído | Migração Perplexity → RAG local; 222 conversas extraídas |
| Abr/2026 | PRJ019 | ❌ Frozen | Watcher/Ingestor abortado por incompatibilidade Vault Agent + WSL2 |
| Abr/2026 | PRJ020 | 🟢 Fase B | DefectDojo + Kali Linux + GVM operacionais |
| Mai/2026 | PRJ022 | ✅ Parcial | Pipeline IGA CSV: 102 usuários em 5,1s; Estágio B frozen por GPathResult |
| Mai/2026 | PRJ023 | 🟡 Sucesso Parcial | midPoint → AWS IAM: provisionamento OK; grupos/policies não escrevem |
| Mai/2026 | PRJ024 | 🟡 Sucesso Parcial | midPoint → GCP IAM: provisionamento reportado; Cloud Identity não ativado |
| Mai/2026 | PRJ025 | ❌ Cancelado | midPoint → Keycloak — cancelado com a descontinuidade do midPoint |
| Mai/2026 | PRJ026 | ❌ Cancelado | midPoint → AD — cancelado com a descontinuidade do midPoint |
| Mai/2026 | PRJ027 | ❌ Encerrado s/ Sucesso | midPoint → Entra ID Free: Resource nunca funcional; App Registration mantido |
| **Mai/2026** | **PRJ028** | ✅ **Concluído** | **Hardening do AD + Tailscale + MFA; acesso remoto seguro estabelecido** |
| **Mai/2026** | **PRJ029** | ✅ **Concluído** | **Odoo 17.0 como consumidor SaaS de identidade (NÃO é SoT)** |
| **Mai/2026** | **PRJ030** | ✅ **Concluído** | **Migração Hyper-V → VMware Workstation (600 GB, 11 VMs) — CONSTRAINT-001 resolvida** |

### Marco Estratégico — Descontinuidade do midPoint (Pós-PRJ030)

Após a migração do hipervisor (PRJ030) e a análise aprofundada das limitações do midPoint 4.10 (PRJ022, PRJ023, PRJ024, PRJ027), foi tomada a **decisão estratégica de remover o midPoint do Living Lab**.

**Racional:**
- O midPoint apresentou bloqueios estruturais (GPathResult, breaking changes em synchronization)
- A complexidade de manutenção superava os benefícios para o porte do laboratório
- A stack simplificada (OrangeHRM → AD → Entra → SaaS) atende aos objetivos de governança com menor esforço operacional
- A decisão reflete foco em **habilidades de comunicação executiva e tomada de decisão estratégica**, não apenas execução técnica

**A partir de v5.1, o midPoint é considerado DESCONTINUADO no Living Lab.**

---

## 6. PRJ001 — Laboratório de SI

**Status:** ✅ CONCLUÍDO  
**Período:** Dezembro/2025

### Resumo
Projeto fundacional do Living Lab. Estabeleceu a baseline de Segurança da Informação, migrou o ambiente de VirtualBox para Hyper-V, realizou os primeiros scans de vulnerabilidade com OpenVAS e implementou hardening inicial nas VMs.

### Entregáveis
- Ambiente Hyper-V operacional (primeiras VMs)
- Scans de vulnerabilidade baseline
- Hardening inicial documentado
- Primeiras GMUDs formalizadas

### Lições (L01–L02)
| ID | Lição |
|----|-------|
| L01 | A baseline de segurança deve ser estabelecida antes de qualquer projeto de IGA |
| L02 | Scans de vulnerabilidade devem ser repetidos após cada GMUD significativa |

---

## 7. PRJ002 — Infraestrutura Fiqueok

**Status:** ✅ CONCLUÍDO  
**Período:** Dezembro/2025 — Janeiro/2026

### Resumo
Projeto construiu a infraestrutura core do laboratório: Active Directory (ID-P-01), midPoint 4.10, OrangeHRM e PostgreSQL. O fluxo completo automatizado OrangeHRM → midPoint → AD não foi atingido, mas a prova de conceito foi parcialmente validada.

### O que foi construído

| Componente | Status |
|------------|--------|
| midPoint 4.10 + PostgreSQL 16 | ✅ Estável |
| OrangeHRM + MariaDB | ✅ Operacional |
| Conexão midPoint → AD (LDAP 389) | ✅ Linking manual validado |
| Conexão midPoint → OrangeHRM (JDBC) | ⚠️ Test Connection OK, sync não funcional |

### Retrospectiva Arquitetural
O conector escolhido foi DatabaseTable — por conveniência, não por decisão arquitetural. O conector correto para uma fonte autoritativa de RH é sempre a **interface pública** (API REST).

### Lições (L01_PRJ002 a L12_PRJ002)
| ID | Lição |
|----|-------|
| L01_PRJ002 | Test Connection 5/5 não garante sincronização funcional |
| L02_PRJ002 | Import Task SUCCESS não garante criação de User |
| L03_PRJ002 | midPoint exige `User.name` obrigatório |
| L04_PRJ002 | Imagem Docker oficial é lean — connectors opcionais requerem JAR manual |
| L05_PRJ002 | midPoint 4.10 tem breaking changes em Smart Correlation |
| L06_PRJ002 | Configurações manuais de rede Docker são efêmeras |
| L07_PRJ002 | Checkpoint Hyper-V imediatamente antes da GMUD é obrigatório |
| L08_PRJ002 | Sanitização agressiva deve ter escopo explícito |
| L09_PRJ002 | Versões non-LTS têm Early Adopter Risk mensurável |
| L10_PRJ002 | Linking manual ≠ provisionamento automático |
| L11_PRJ002 | Schema discovery parcial é red flag |
| L12_PRJ002 | Documentação retroativa é válida mas subótima |

---

## 8. PRJ003 — IGA Greenfield

**Status:** ✅ ENCERRADO COM SUCESSO  
**Período:** 14/01/2026 – 21/01/2026

### Resumo
Formalizou a governança de identidade e implantou midPoint com PostgreSQL em Docker. A fase técnica enfrentou 19 tentativas de deploy com bloqueadores em midPoint 4.8 e 4.9. O sucesso foi alcançado na GMUD-012 com midPoint 4.10 e a estratégia de **"Soberania de Dados"** (injeção manual prévia do schema PostgreSQL).

### Estratégia "Soberania de Dados" (GMUD-012)
1. Limpeza nuclear de volumes
2. Boot isolado do PostgreSQL (healthcheck validado)
3. Injeção manual dos 3 scripts SQL oficiais via `psql`
4. Boot do midPoint 4.10 com variáveis `MP_SET_*`

**Duração total do deploy:** 1 minuto e 19 segundos

### Lições (L-01 a L-16)
| ID | Lição |
|----|-------|
| L-01 | Canvases de decisão antes da execução técnica eliminam ambiguidade |
| L-02 | Dois níveis de credenciais: infraestrutura e aplicação |
| L-03 | Healthcheck explícito é obrigatório |
| L-04 | Checkpoints podem não restaurar estado de rede |
| L-05 | Scripts SSH exigem `NOPASSWD` no sudoers |
| L-06 | midPoint 4.8/4.9 têm fallback silencioso para H2 |
| L-07 | Expansão de variáveis em PowerShell here-strings falha silenciosamente |
| L-08 | Volumes Docker persistem hash do primeiro boot |
| L-09 | `sed` interpreta `#`, `!`, `@` como delimitadores |
| L-10 | Máximo 3 tentativas com mesma abordagem; na quarta, pivot estratégico |
| L-11 | midPoint 4.8 não inclui scripts SQL embutidos |
| L-12 | Nunca fornecer `config.xml` manual no primeiro boot |
| L-13 | Conflito de precedência resolvido no midPoint 4.10 |
| L-14 | "Soberania de Dados" elimina dependência do entrypoint |
| L-15 | Gate de Reversibilidade funcionou em 8 GMUDs |
| L-16 | 19 deploys fracassados geraram conhecimento não documentado oficialmente |

---

## 9. PRJ004 — IGA Data Lifecycle (CSV)

**Status:** ✅ CONCLUÍDO  
**Período:** Janeiro/2026

### Resumo
Estabeleceu o primeiro pipeline IGA funcional utilizando CSV como fonte autoritativa. Primeiro ciclo completo Joiner/Mover/Leaver validado.

### Entregáveis
- CSV importado no midPoint
- Reconciliação automática
- Provisionamento de usuários no AD (manual)
- Documentação do fluxo JML

### Lições (L-17–L-18)
| ID | Lição |
|----|-------|
| L-17 | CSV é uma fonte autoritativa válida para POC, mas não para produção |
| L-18 | O ciclo JML deve ser testado com pelo menos 3 cenários |

---

## 10. PRJ005 — Integração de Fonte Autoritativa (OrangeHRM)

**Status:** ✅ CONCLUÍDO  
**Período:** Fevereiro/2026

### Resumo
Integração do OrangeHRM como fonte autoritativa de RH, utilizando conectividade JDBC segura. A base de 100 colaboradores FinPay foi carregada.

### Entregáveis
- OrangeHRM operacional (rh-gf-01-local)
- Conectividade midPoint ↔ OrangeHRM via JDBC
- 100 registros de colaboradores importados

### Lições (L19–L20)
| ID | Lição |
|----|-------|
| L19 | JDBC funciona para leitura, mas não é a abordagem recomendada |
| L20 | A importação massiva deve ser testada em lotes |

---

## 11. PRJ006 — Integração Dinâmica via JDBC (Abortado)

**Status:** ⚠️ ABORTADO  
**Período:** Fevereiro/2026

### Resumo
Tentativa de utilizar JDBC para sincronização dinâmica entre OrangeHRM e midPoint. O projeto foi abortado após a identificação do anti-padrão arquitetural: acessar diretamente o banco de dados da aplicação viola o princípio de encapsulamento.

### Decisão
Adotar **API-First** para todas as integrações futuras.

### Lições (L21–L22)
| ID | Lição |
|----|-------|
| L21 | JDBC para fonte autoritativa é anti-padrão — API REST é a abordagem correta |
| L22 | Anti-padrões identificados devem ser documentados como "não fazer" |

---

## 12. PRJ007 — HashiCorp Vault (PAM)

**Status:** 🟡 ATIVO  
**Período:** Fevereiro – Abril/2026

### Resumo
Implementação do HashiCorp Vault como PAM e segredo centralizado para o Living Lab. Foram tentadas 3 plataformas antes da decisão final pelo Vault.

### Entregáveis
- Vault 1.21.3 operacional na VM `VAULT-GEN1` (migrada para VMware no PRJ030)
- Secret `secret/entra-id/auth` armazenando credenciais
- Integração com Shadow API (PRJ008)

### Pendências Críticas
| Pendência | Severidade | Ação Necessária |
|-----------|------------|-----------------|
| Root token em uso ativo | Alta | GMUD dedicada para revogar |
| Backup automático não configurado | Alta | Implementar cron Raft snapshot |
| Auto-unseal não implementado | Alta | Backlog |
| Token `svc-shadow-api` expira 2026-05-17 | **URGENTE** | Verificar renovação automática |

### Lições (L23–L25)
| ID | Lição |
|----|-------|
| L23 | O Vault deve ser a única fonte de verdade para segredos |
| L24 | Tokens de serviço devem ter renovação automática |
| L25 | Auto-unseal é obrigatório para alta disponibilidade |

---

## 13. PRJ008 — Shadow API REST

**Status:** 🟡 ACEITAÇÃO PARCIAL (FROZEN)  
**Período:** Abril/2026

### Resumo
Implementação de uma Shadow API REST em FastAPI (VM `api-gf-01`) para expor os dados do OrangeHRM de forma segura, contornando a ausência de um conector REST nativo compatível com midPoint 4.10 / Java 21.

### O que foi entregue
- Shadow API FastAPI operacional
- Integração midPoint via DatabaseTable Connector (lendo CSV gerado pela API)
- Conector REST nativo indisponível (GPathResult — bloqueio estrutural)

### Adendo de Rede (29/04/2026) — Remoção da `tag:consultor`
A tag `tag:consultor` foi removida da VM `api-gf-01` porque gerou "vácuo de permissões" (Default Deny), bloqueando telemetria para o Sentinel-Core.

### Bloqueio Estrutural Confirmado (PRJ022)
```
groovy/util/slurpersupport/GPathResult,
reason: groovy/util/slurpersupport/GPathResult
(class java.lang.NoClassDefFoundError)
```

### Lições (L26–L28)
| ID | Lição |
|----|-------|
| L26 | CSV dentro do container é o que importa — validar via `docker exec` |
| L27 | `wget` não está disponível no Alpine — usar `curl` |
| L28 | Bloqueio `GPathResult` é estrutural — ocorre antes de qualquer script |

---

## 14. PRJ009 — Hybrid Identity Bridge (Encerrado)

**Status:** ⚠️ ENCERRADO  
**Período:** Fevereiro – Março/2026

### Resumo
Projeto para estabelecer ponte de identidade híbrida entre AD on-premise e Entra ID. Encerrado prematuramente devido à expiração dos créditos Azure.

### Lições (L09–L11)
| ID | Lição |
|----|-------|
| L09 | Projetos com dependência de nuvem devem ter orçamento reservado |
| L10 | A expiração de créditos pode ocorrer no pior momento |
| L11 | Documentar lições mesmo de projetos encerrados prematuramente |

---

## 15. PRJ010 — Join Massivo OrangeHRM

**Status:** ✅ CONCLUÍDO  
**Período:** Fevereiro/2026

### Resumo
Join massivo de 100 colaboradores da FinPay no OrangeHRM.

### Entregáveis
- 100 registros de colaboradores carregados
- Dados sintéticos realistas

### Lições (L12–L13)
| ID | Lição |
|----|-------|
| L12 | Dados de teste devem ser tão realistas quanto possível |
| L13 | O join massivo deve ser validado em lotes menores primeiro |

---

## 16. PRJ011 — Entra ID Identity JOIN

**Status:** ✅ CONCLUÍDO  
**Período:** Março/2026

### Resumo
Provisionamento de 100 identidades no Microsoft Entra ID Free.

### Entregáveis
- 100 usuários criados no Entra ID
- Mapeamento de atributos básicos

### Lições (L14–L15)
| ID | Lição |
|----|-------|
| L14 | O Free Tier do Entra ID é suficiente para laboratórios de pequeno porte |
| L15 | A criação massiva via Graph API requer throttling controlado |

---

## 17. PRJ012 — midPoint como Motor IGA On-Premise (Reavaliado → Descontinuado)

**Status:** 🟡 ENCERRADO COM SUCESSO PARCIAL → **DESCONTINUADO**  
**Data de execução original:** 06/03/2026 – 10/03/2026  
**Reavaliação:** 08/05/2026  
**Decisão final (v5.1):** midPoint removido do Living Lab

### Resumo
O PRJ012 foi reavaliado durante a execução do PRJ027. Uma forense completa identificou que o container do midPoint foi restaurado de um snapshot anterior à conclusão do projeto, perdendo todos os artefatos.

### Estado dos Artefatos (Forense)

| Artefato | Status Original | Status Atual (à época) |
|----------|----------------|------------------------|
| App Registration | ✅ Criado | ✅ PRESERVADO |
| Client Secret | ✅ Gerado | ❌ INVÁLIDO |
| Permissões Graph | ✅ Concedidas | ⚠️ Parciais |
| Conector Graph | ✅ Instalado | ❌ AUSENTE |
| Resource Entra ID | ✅ Criado | ❌ AUSENTE |

### Decisão de Descontinuidade (Pós-PRJ030)
Com a migração do hipervisor e a decisão estratégica de simplificação da stack, o midPoint foi **removido do Living Lab**. Os artefatos de nuvem (App Registration, permissões) foram mantidos para potencial uso futuro com outras ferramentas.

### Lições (L12_PRJ012 a L15_PRJ012)
| ID | Lição |
|----|-------|
| L12_PRJ012 | Configurações dentro do midPoint são voláteis |
| L13_PRJ012 | Client Secret pode ser revogado externamente |
| L14_PRJ012 | App Registrations sobrevivem a restores de VM |
| L15_PRJ012 | Forense prévia é essencial para identificar degradação |

---

## 18. PRJ014 — Saneamento e Padronização Hyper-V

**Status:** ✅ CONCLUÍDO  
**Período:** Março – Abril/2026

### Resumo
Saneamento completo do ambiente Hyper-V: padronização de nomes, eliminação de ISOs duplicadas (6.3 GB recuperados), substituição do Golden Disk mestre, documentação da CONSTRAINT-001.

### Entregáveis
- Estrutura de diretórios padronizada
- Golden Disk mestre substituído
- CONSTRAINT-001 documentada

### Lições (L12–L14)
| ID | Lição |
|----|-------|
| L12 | CONSTRAINT-001 era um risco iminente para VMs GEN2 |
| L13 | Golden Disks devem ser validados periodicamente |
| L14 | A padronização reduz o tempo de diagnóstico em 70% |

---

## 19. PRJ015 — IGA Híbrido Local — AD → Entra Cloud Sync (Encerrado)

**Status:** ⚠️ ENCERRADO  
**Período:** Março – Abril/2026

### Resumo
Tentativa de implementar Cloud Sync entre AD e Entra ID. O projeto falhou devido a conflitos arquiteturais entre cloud-first e sync-first.

### Lições (L27_PRJ015 a L35_PRJ015 — consolidadas)
| ID | Lição |
|----|-------|
| L27_PRJ015 | Cloud-first e sync-first são filosofias conflitantes |
| L28_PRJ015 | A escolha da direção de sincronização deve ser estratégica, não tática |

---

## 20. PRJ016 — Sentinel Identity Shield (Em Execução)

**Status:** 🔵 EM EXECUÇÃO  
**Período:** Abril/2026 — presente

### Resumo
Implementação do Sentinel Identity Shield — plataforma ITDR (Identity Threat Detection and Response) baseada em Wazuh + eBPF + Loki + Grafana. A VM `SENTINEL-CORE` foi migrada com sucesso para VMware no PRJ030.

### Entregáveis
- Wazuh manager + workers
- Loki para agregação de logs
- Grafana para dashboards
- eBPF para monitoramento em tempo real

---

## 21. PRJ017 — Secure Edge Gateway & Identity-First Perimeter

**Status:** ✅ CONCLUÍDO  
**Período:** Abril/2026

### Resumo
Implementação do Cloudflare Zero Trust como edge gateway, com exposição segura de serviços via OTP (MFA por e-mail). Estabeleceu o perímetro identity-first do Living Lab.

### Entregáveis
- Cloudflare Zero Trust Free Tier configurado
- MFA por e-mail (OTP) para acesso administrativo
- Aplicações protegidas: Tailscale, painéis administrativos

---

## 22. PRJ018 — Memória de Longo Prazo do Living Lab

**Status:** ✅ CONCLUÍDO COM SUCESSO  
**Período:** 18/04/2026 – 24/04/2026

### Resumo
Substituiu o uso da plataforma Perplexity por um ecossistema **100% local, soberano e rastreável** — eliminando dependência de SaaS e estabelecendo memória de longo prazo para o Living Lab.

### Entregas Realizadas
- Extração de 222 conversas do Perplexity (97,4% de sucesso)
- Instalação Ollama (Qwen2.5:7b, DeepSeek-R1:7b, nomic-embed-text-v1, bge-m3)
- AnythingLLM Desktop configurado
- Indexação de 495+ documentos em 6 camadas temáticas

### Estrutura de Conhecimento — 6 Camadas Temáticas

| Camada | Projetos | Status |
|--------|----------|--------|
| Camada 1 — Fundação | PRJ001, PRJ002, PRJ003 | ✅ Indexado |
| Camada 2 — Integração | PRJ004, PRJ005, PRJ006 | ✅ Indexado |
| Camada 3 — RAG e Memória | PRJ018 | ✅ Indexado |
| Camada 4 — Orquestração | PRJ008, PRJ009, PRJ010, PRJ011, PRJ012 | ✅ Indexado |
| Camada 5 — Infraestrutura | PRJ013, PRJ014, PRJ015, PRJ017 | ✅ Indexado |
| Camada 6 — Segurança, PAM e ITDR | PRJ007, PRJ016, PRJ020 | ✅ Indexado |

### Lições (L23–L31)
| ID | Lição |
|----|-------|
| L23 | AnythingLLM Desktop tem limitações de indexação para grandes volumes |
| L24 | Qwen2.5:7b tem melhor desempenho em português |
| L25 | nomic-embed-text-v1 (768 dim) é superior |
| L26 | Modo "Consulta" é essencial para forçar uso exclusivo dos documentos |
| L27 | Indexação por camadas temáticas preserva coerência narrativa |
| L28 | O tipo de VM (GEN1 vs GEN2) afeta todo o ecossistema |
| L29 | Token de serviço expira e requer renovação automatizada |
| L30 | Documente o tipo de dependência (contínua vs. pontual) |

---

## 23. PRJ019 — Watcher e Ingestor Automatizados para Obsidian (Frozen)

**Status:** ❌ FROZEN  
**Período:** Abril/2026

### Resumo
Projeto para automatizar a ingestão de novos documentos no RAG local. Foi congelado devido a incompatibilidade entre Vault Agent e WSL2.

### Lições (consolidadas na v3.0)
| ID | Lição |
|----|-------|
| L31 | Vault Agent não funciona corretamente no WSL2 |
| L32 | Alternativas: rodar como root ou VM dedicada |

---

## 24. PRJ020 — OpenVAS/GVM + DefectDojo (Gestão de Vulnerabilidades)

**Status:** 🟢 FASE B  
**Período:** Abril/2026 — presente

### Resumo
Implementação de gestão de vulnerabilidades com OpenVAS/GVM (Kali Linux) e DefectDojo para consolidação de resultados. As VMs foram migradas para VMware no PRJ030.

### Entregáveis
- Kali Linux com GVM nativo
- DefectDojo em Docker
- Primeiros scans realizados (API PRJ008)

---

## 25. PRJ022 — Integração IGA: OrangeHRM × midPoint via CSV + Spike ScriptedSQL

**Status:** 🟡 PARCIALMENTE CONCLUÍDO  
**Data de Encerramento:** 04/05/2026

### Resumo
Projeto aberto para resolver o bloqueio herdado do PRJ008 (ausência de conector REST compatível com midPoint 4.10) e estabelecer um pipeline IGA funcional.

### Estágio A — Pipeline CSV (Concluído)
- CSV `hr_export.csv` com 103 linhas (1 cabeçalho + 102 registros)
- Reconciliacão: 102 usuários criados em 5,1 segundos, 0 erros
- Throughput: 1.270 itens/minuto · 40,8 ms por objeto

### Estágio B — Spike ScriptedSQL (Frozen)
- Bloqueio `NoClassDefFoundError: GPathResult` confirmado
- `wget` não disponível no Alpine, `repo.evolveum.com` inacessível via DNS

### Lições (L32–L43)
| ID | Lição |
|----|-------|
| L32 | CSV dentro do container é o que importa |
| L33 | Atributo `name` do User é obrigatório |
| L34 | Correlation rule explícita é OBRIGATÓRIA |
| L35 | `employee_id → personalNumber` com `Strength: Strong` é a âncora |
| L36 | `wget` não disponível no Alpine — usar `curl` |
| L37 | `repo.evolveum.com` pode estar inacessível |
| L38 | Rollback via snapshot Hyper-V é determinístico |
| L39 | Tarefa antiga deve ser excluída antes de nova |
| L40 | Bloqueio `GPathResult` é estrutural |
| L41 | Validação multicamada é o padrão audit-ready |
| L42 | Pipeline CSV entregou 102 usuários em 5,1s com 0 erros |

---

## 26. PRJ023 — Integração midPoint 4.10 com AWS IAM

**Status:** ✅ ENCERRADO — SUCESSO PARCIAL  
**Data de Encerramento:** 05/05/2026

### O que Funcionou
- Instalação do conector AWSConnector v1.1.2
- Correção `trustAnchors` (JAVA_OPTS com cacerts)
- Provisionamento de usuário FP004
- Remoção de usuário

### O que Não Funcionou
- Gestão de grupos IAM (`awsGroups`) — conector **lê** mas **não escreve**
- Gestão de políticas anexadas — conector ignora

### Lições (L44–L50)
| ID | Lição |
|----|-------|
| L44 | Conector Atricore é a solução correta para usuários AWS |
| L45 | Erro `trustAnchors` resolvido com `JAVA_OPTS` |
| L46 | Mapeamento `icfs:name` → `name` é OBRIGATÓRIO |
| L47 | AWSConnector **lê** grupos/políticas mas **não escreve** |
| L48 | Schema do conector pode ser enganoso |
| L49 | Test Connection OK não garante todas as operações |
| L50 | Provisionamento de usuários funciona perfeitamente |

---

## 27. PRJ024 — Integração midPoint 4.10 com GCP IAM

**Status:** 🟡 ENCERRADO — SUCESSO PARCIAL  
**Data de Encerramento:** 06/05/2026

### O que Funcionou
- Conector GCPConnector v1.3.0 descoberto
- Resource criado, Test Connection OK
- Provisionamento reportado como sucesso

### O que Não Funcionou ou Não foi Validado
- **Cloud Identity não ativado** — usuário não visível no GCP
- Domínio `fiqueok.com.br` não verificado
- Shadow antiga corrompida

### Lições (L51–L60)
| ID | Lição |
|----|-------|
| L51 | Conector GCP segue mesmo padrão: minimalista |
| L52 | **Cloud Identity é OBRIGATÓRIO** para visualizar usuários |
| L53 | Domínio válido e verificado é pré-requisito |
| L54 | Configuração via GUI é mais estável que curl |
| L55 | Mapeamento `icfs:name` → `name` é obrigatório |
| L56 | `trustAnchors` continua sendo problema |
| L57 | Shadows órfãs podem causar erros de sync |
| L58 | Schema minimalista é limitação técnica |
| L59 | POC demonstrou viabilidade, mas PRD exige ADR |
| L60 | Mesmo padrão de provisionamento funciona para GCP |

---

## 28. PRJ025 — Integração midPoint com Keycloak (Planejado → Cancelado)

**Status:** ❌ CANCELADO  
**Data da decisão:** Maio/2026 (pós-descontinuidade do midPoint)

### Resumo
O projeto estava planejado para estabelecer integração entre midPoint 4.10 e Keycloak para SSO. Foi **cancelado** como parte da decisão estratégica de remover o midPoint do Living Lab.

---

## 29. PRJ026 — Integração midPoint com Active Directory (Planejado → Cancelado)

**Status:** ❌ CANCELADO  
**Data da decisão:** Maio/2026 (pós-descontinuidade do midPoint)

### Resumo
O projeto estava planejado para estabelecer integração bidirecional entre midPoint 4.10 e Active Directory. Foi **cancelado** como parte da decisão estratégica de remover o midPoint do Living Lab.

**Nota:** A infraestrutura de acesso remoto ao AD (Tailscale + hardening) foi implementada no PRJ028 e permanece válida para uso com outras ferramentas ou sincronização direta com Entra ID.

---

## 30. PRJ027 — Integração midPoint com Microsoft Entra ID Free

**Status:** ❌ ENCERRADO SEM SUCESSO  
**Data de Encerramento:** 08/05/2026

### Resumo Executivo
O PRJ027 teve como objetivo integrar o midPoint 4.10 ao Microsoft Entra ID Free utilizando o conector Graph API.

**Resultado Final:** ❌ NÃO IMPLEMENTADO

| Item | Status |
|------|--------|
| App Registration criado e preservado | ✅ |
| Permissões Graph API concedidas | ✅ |
| Client Secret armazenado no Vault | ✅ |
| Conector Graph instalado e descoberto | ✅ |
| Test Connection | ⚠️ Funcionou intermitentemente |
| Resource nunca ficou 100% funcional | ❌ |
| Nenhum usuário foi provisionado | ❌ |

### Causas Raiz Identificadas
1. **Conflito com projetos anteriores** (AWS IAM, GCP IAM) — shadows corrompidas
2. **Erros de sintaxe nos mappings do XML** — uso de `<path>` em vez de `<expression><script><code>`
3. **Falta de declaração explícita de dependências (source)**
4. **Problemas de ordem de execução** — recompute tenta provisionar tudo de uma vez

### Validação com Usuário Limpo (FP010)
O erro persistiu com FP010 (usuário sem shadows antigas), confirmando que o problema era **sistêmico** — configuração do Resource.

### Estado dos Artefatos Pós-Encerramento

| Artefato | Decisão |
|----------|---------|
| App Registration `midpoint-iga-connector` | ✅ **MANTER** (reuso futuro) |
| Client Secret | ✅ **MANTER** |
| Permissões Graph API | ✅ **MANTER** |
| Vault (`secret/entra-id/auth`) | ✅ **MANTER** |

### Lições do PRJ027 (L61–L70)
| ID | Lição |
|----|-------|
| L61 | Resources antigos em maintenance mode antes de testar novos |
| L62 | midPoint provisiona TODOS os Resources de um usuário de uma vez |
| L63 | Scripts Groovy usam `<expression><script><code>`, NUNCA `<path>` |
| L64 | Scripts precisam declarar `<source>` para atributos referenciados |
| L65 | `icfs:name` precisa de source explícito |
| L66 | Schema do midPoint 4.10 para `<synchronization>` é inconsistente |
| L67 | `<synchronize>true</synchronize>` NÃO é aceito |
| L68 | `<action>` com `reconcile` NÃO é aceito para `linked` |
| L69 | Para `unlinked`, usar `<link>true</link>` |
| L70 | Maneira mais confiável é exportar um Resource funcional do sistema |

---

## 31. PRJ028 — Segurança e Acesso Remoto ao Active Directory

**Status:** ✅ CONCLUÍDO COM SUCESSO  
**Data de Execução:** 10/05/2026  
**GMUDs executadas:** GMUD-001-PRJ028

### Resumo Executivo
O PRJ028 estabeleceu uma **arquitetura de acesso remoto seguro e auditável** para o Active Directory (ID-P-01), resolvendo problemas históricos de conectividade e implementando hardening baseado em princípios Zero Trust.

### O que foi Entregue

| Componente | Tecnologia | Status |
|------------|------------|--------|
| Overlay Network | Tailscale (WireGuard) | ✅ Instalado e configurado |
| Firewall | Windows Defender (`BlockInbound, AllowOutbound`) | ✅ Configurado |
| Acesso administrativo | OpenSSH Server (substituiu WinRM) | ✅ Ativo |
| Autenticação | Chave SSH (ed25519) | ✅ Configurada |
| MFA | Cloudflare Zero Trust (OTP por e-mail) | ✅ Integrada |
| Hardening | CIS Benchmarks v3.0 | ✅ Aplicado |
| Conectividade midPoint ↔ AD | LDAP via Tailscale | ✅ Validada |

### Correção de Rede (Causa Raiz Histórica)

| Problema | Solução |
|----------|---------|
| IP do AD: `172.24.192.10` (sub-rede diferente do host) | IP ajustado para `172.23.195.2/20` |
| Gateway: `172.24.192.1` (inexistente) | Gateway corrigido para `172.23.192.1` |
| Rota padrão ausente | Rota padrão mantida (acesso outbound) |
| DNS: `::1` (IPv6 local) | DNS configurado para `127.0.0.1` |

### Validação Pós-Implementação

| Teste | Resultado |
|-------|-----------|
| Ping do midPoint para AD via Tailscale | ✅ succeeded |
| `nc -zv <TAILSCALE_IP> 389` (LDAP) | ✅ succeeded |
| Firewall `BlockInbound, AllowOutbound` | ✅ Ativo |
| Ping `8.8.8.8` (saída para internet) | ✅ succeeded |
| SSH com chave ed25519 | ✅ succeeded |

### Decisão de Desvio Aprovada
**Manter rota padrão** (em vez de remover, conforme previsto originalmente). Justificativa: AD precisa de saída para internet (NTP, atualizações); firewall `BlockInbound` já protege contra acessos não autorizados.

### Lições do PRJ028 (L71–L75)
| ID | Lição |
|----|-------|
| L71 | Tailscale pode ser instalado com acesso temporário à internet |
| L72 | Firewall `BlockInbound, AllowOutbound` é suficiente para laboratório |
| L73 | Hyper-V Time Sync é alternativa válida ao NTP externo |
| L74 | Remoção e recriação do adaptador de rede resolve IP persistente |
| L75 | Validar conectividade via Tailscale antes de bloquear acesso físico |

---

## 32. PRJ029 — Odoo ERP como Consumidor de Identidade SaaS

**Status:** ✅ CONCLUÍDO  
**Data de Execução:** 11/05/2026  
**GMUDs executadas:** GMUD-001-PRJ029

### Resumo Executivo
Implantação do Odoo 17.0 em contêiner Docker na VM `erp-odoo-mac` (VMware, pós-migração). O Odoo foi classificado estritamente como **aplicação SaaS consumidora de identidade**, NÃO como Source of Truth.

### ⚠️ Correção Arquitetural Importante (v5.1)

**O que foi corrigido nesta versão do documento:**

| Afirmação incorreta (v5.0) | Correção (v5.1) |
|---------------------------|-----------------|
| Odoo como "Source of Truth" | ❌ INCORRETO — Odoo é consumidor de identidade |
| Odoo como substituto do OrangeHRM | ❌ INCORRETO — OrangeHRM é a única SoT |
| Odoo como integrador IGA | ❌ INCORRETO — Odoo não tem papel de orquestração |

**Posição correta do Odoo na stack:**
OrangeHRM (SoT) → Active Directory (IDP Local) → Entra ID (IDP Cloud) → **Odoo (SaaS consumidor)**

### O que foi Entregue

| Componente | Especificação | Status |
|------------|---------------|--------|
| VM `erp-odoo-mac` | Ubuntu 26.04, 2 vCPUs, 3.3GB RAM | ✅ Operacional |
| Docker + Compose | Docker CE 29.4.3 | ✅ Instalado |
| PostgreSQL 15 | Container `db` | ✅ Saudável |
| Odoo 17.0 | Container `web`, porta 8069 | ✅ Saudável |
| Tailscale | IP `xxx.xxx.xxx.xxx` | ✅ Conectado |
| Correção de permissão | `chown 101:101 ./odoo-data` | ✅ Aplicada |

### Correção de Permissão (Desvio durante execução)

**Problema:** O usuário do Odoo no container (UID 101) não tinha permissão de escrita no volume `./odoo-data`, causando erro 500.

**Solução:** `chown -R 101:101 ./odoo-data` antes do restart.

### Pendências (Fora do Escopo do PRJ029)
- Criação do banco de dados mestre do Odoo
- Criação do usuário técnico `svc_midpoint` (ou equivalente para integração futura)
- Geração de API Key para Odoo
- Configuração de SSO via Entra ID (SAML/OIDC)

### Lições do PRJ029 (L76–L80)
| ID | Lição |
|----|-------|
| L76 | Odoo exige `chown 101:101` no diretório de dados — documentar desde o início |
| L77 | Validar logs imediatamente após `docker compose up -d` |
| L78 | A memória RAM da VM (3.3GB) é suficiente para Odoo + Postgres em laboratório |
| L79 | **Classificar corretamente o papel de cada sistema** — Odoo é consumidor, não SoT |
| L80 | A integração futura deve ser via SSO (Entra ID), não via acesso direto ao banco de dados |

---

## 33. PRJ030 — Migração Hyper-V → VMware Workstation

**Status:** ✅ CONCLUÍDO COM SUCESSO  
**Data de Execução:** 12/05/2026 — 16/05/2026  
**GMUDs executadas:** GMUD-001/PRJ030

### Resumo Executivo
O PRJ030 migrou toda a infraestrutura do Living Lab (11 VMs, 600 GB) do Hyper-V (ambiente com CONSTRAINT-001 — UEFI corrompido) para o VMware Workstation Pro, resolvendo definitivamente o risco de perda de VMs GEN2.

### Resolução Definitiva da CONSTRAINT-001

| Antes (Hyper-V) | Depois (VMware) |
|-----------------|-----------------|
| UEFI corrompido impedia criação/recuperação de VMs GEN2 | ✅ UEFI funcional |
| Risco de perda iminente (FOK-SRV-LDAP-01 já perdida) | ✅ Risco eliminado |
| VMs GEN2 em estado crítico | ✅ Todas as VMs operacionais |
| Backup complexo (Export-VM) | ✅ Snapshots nativos do VMware |

### Inventário Migrado (11 VMs, 600 GB)

| VM | Projeto | Tamanho | Trilha | Status |
|----|---------|---------|--------|--------|
| SENTINEL-CORE | PRJ016 | 80 GB | 🟢 Verde | ✅ Migrada |
| VAULT-GEN1 | PRJ007 | 20 GB | 🟢 Verde | ✅ Migrada |
| defectdojo-gf-01 | PRJ020 | 100 GB | 🟢 Verde | ✅ Migrada |
| api-gf-01 | PRJ008 | 40 GB | 🟢 Verde | ✅ Migrada |
| Linux Lite | PRJ017 | 40 GB | 🟢 Verde | ✅ Migrada |
| SYNC-01 | PRJ015 | 60 GB | 🟡 Amarela | ✅ Migrada |
| sec-openvas-kali | PRJ020 | 80 GB | 🟡 Amarela | ✅ Migrada |
| rh-gf-01-local | PRJ005 | 40 GB | 🟡 Amarela | ✅ Migrada |
| IGA-GF-02 | PRJ022-024 | 20 GB | 🟡 Amarela | ✅ Migrada (midPoint será descontinuado) |
| PRJ015-PROD-BASE | PRJ015 | 60 GB | 🟡 Amarela | ✅ Migrada |
| ID-P-01 | PRJ002/012 | 60 GB | 🔴 Vermelha | ✅ Reconstruída |

### Procedimento de Migração (POP-MIGRACAO-HYPERV-VMWARE-001)

| Trilha | Método | Aplicável | Resultado |
|--------|--------|-----------|-----------|
| 🟢 Verde | Export-VM + conversão VHDX → VMDK | VMs GEN1 (6 VMs) | ✅ 100% sucesso |
| 🟡 Amarela | Conversão assistida por agente (StarWind V2V) | VMs GEN2 funcionais (4 VMs) | ✅ 100% sucesso |
| 🔴 Vermelha | Rebuild limpo + restore de dados | ID-P-01 (AD) | ✅ Reconstruída |

### Validação Pós-Migração (Todas as VMs)

| Verificação | Critério | Resultado |
|-------------|----------|-----------|
| Boot da VM | Inicialização sem erros | ✅ 11/11 |
| Tailscale | `tailscale status` mostra todos os nós | ✅ Conectado |
| Serviços críticos | Wazuh, Loki, Grafana, Vault, Odoo, AD | ✅ Operacionais |
| Conectividade | Ping entre VMs via Tailscale | ✅ succeeded |

### Decisão Estratégica Pós-PRJ030

Com a migração concluída e o ambiente estabilizado no VMware, foi tomada a decisão de **remover o midPoint do Living Lab**. A stack de identidade passa a ser:

**OrangeHRM (SoT) → Active Directory (IDP Local) → Entra ID (IDP Cloud) → SaaS (Odoo e futuros sistemas)**

### Lições do PRJ030 (L81–L90)
| ID | Lição |
|----|-------|
| L81 | A CONSTRAINT-001 foi resolvida definitivamente com a migração para VMware |
| L82 | O procedimento de migração por trilhas (Verde/Amarela/Vermelha) é robusto e reutilizável |
| L83 | StarWind V2V Converter é ferramenta confiável para conversão VHDX → VMDK |
| L84 | O rebuild do AD (trilha vermelha) é mais seguro que tentar migrar uma VM corrompida |
| L85 | Backup completo (Export-VM) antes da migração é obrigatório e funcionou como segurança |
| L86 | A migração de 600 GB pode ser concluída em menos de uma semana com planejamento adequado |
| L87 | VMware Workstation Pro é mais resiliente que Hyper-V para laboratórios domésticos |
| L88 | A infraestrutura está agora estável e sem riscos de perda de VMs |
| L89 | A decisão de remover o midPoint foi viabilizada pela migração bem-sucedida |
| L90 | Documentar o "Caminho Feliz" (POP) antes da execução reduz o tempo de migração em 50% |

---

## 34. A Nova Stack de Identidade (Pós-midPoint)

### 34.1. Arquitetura Final

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                    STACK DE IDENTIDADE — LIVING LAB FIQUEOK (v5.1)                   │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    ORANGEHRM — SOURCE OF TRUTH (SoT)                             ││
│  │                    (Única fonte autoritativa de RH)                             ││
│  │                                                                                  ││
│  │  Atributos gerenciados:                                                          ││
│  │  • employeeNumber (matrícula — âncora imutável)                                  ││
│  │  • givenName, familyName                                                         ││
│  │  • email, department, jobTitle                                                   ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                             │                                        │
│                                             │ Sincronização manual/automatizada      │
│                                             ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    ACTIVE DIRECTORY (corp.fiqueok.com.br) — IDP Local            ││
│  │                    VMware Workstation — Hardening + Tailscale (PRJ028)          ││
│  │                                                                                  ││
│  │  • Autenticação para recursos on-premise                                         ││
│  │  • GPOs, Kerberos, LDAP                                                          ││
│  │  • Sincronização com Entra ID via Cloud Sync (em estudo)                         ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                             │                                        │
│                                             │ Cloud Sync / Entra Connect (futuro)    │
│                                             ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    MICROSOFT ENTRA ID FREE — IDP Cloud                           ││
│  │                                                                                  ││
│  │  • Autenticação para aplicações SaaS                                             ││
│  │  • SSO (SAML/OIDC) para Odoo e futuros sistemas                                 ││
│  │  • App Registration preservado (PRJ012/PRJ027)                                  ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                             │                                        │
│                                             │ SSO (OIDC/SAML)                        │
│                                             ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    APLICAÇÕES CONSUMIDORAS (SaaS)                                 ││
│  │                                                                                  ││
│  │  • Odoo 17.0 (ERP — consome identidade, NÃO é SoT)                              ││
│  │  • Futuros sistemas (ERP financeiro, CRM, etc.)                                  ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                      │
│  ✅ midPoint REMOVIDO (descontinuado pós-PRJ030)                                     │
│  ✅ Odoo classificado como consumidor, NÃO como Source of Truth                      │
│  ✅ OrangeHRM mantido como única SoT                                                 │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### 34.2. Papéis e Responsabilidades

| Sistema | Papel | Responsabilidade |
|---------|-------|------------------|
| **OrangeHRM** | Source of Truth (SoT) | Única fonte autoritativa para dados de RH |
| **Active Directory** | IDP Local | Autenticação para recursos on-premise, sincronização com a nuvem |
| **Microsoft Entra ID** | IDP Cloud | Autenticação para SaaS, SSO, MFA |
| **Odoo 17.0** | Consumidor SaaS | Consome identidade via SSO, NÃO gerencia identidades |
| **Tailscale + Cloudflare** | Overlay + MFA | Acesso remoto seguro, autenticação multifator |
| **HashiCorp Vault** | PAM | Gestão de segredos, credenciais privilegiadas |

### 34.3. Justificativa para Remoção do midPoint

| Fator | Análise |
|-------|---------|
| **Complexidade** | midPoint 4.10 apresentou bloqueios estruturais (GPathResult, breaking changes) |
| **Manutenção** | A curva de aprendizado e o esforço de manutenção superam os benefícios para o porte do laboratório |
| **Alternativa** | A stack simplificada OrangeHRM → AD → Entra → SaaS atende aos objetivos com menor esforço |
| **Foco Estratégico** | A decisão reflete foco em habilidades de comunicação executiva e tomada de decisão, não apenas execução técnica |
| **Resiliência** | Com a migração para VMware (PRJ030), o ambiente está estável e não requer orquestração complexa |

---

## 35. Lições Aprendidas Transversais (L01–L95)

### Lições da v3.0 (L01–L08 — PRJ001–PRJ008)
| ID | Lição |
|----|-------|
| L01 | A baseline de segurança deve ser estabelecida antes de qualquer projeto de IGA |
| L02 | Scans de vulnerabilidade devem ser repetidos após cada GMUD significativa |
| L03 | Ferramentas de IGA open-source exigem curva de aprendizado íngreme |
| L04 | A documentação deve ser gerada antes ou durante a execução |
| L05 | O rollback via snapshot é a última linha de defesa |
| L06 | Test Connection bem-sucedida não garante sincronização funcional |
| L07 | O tipo de VM (GEN1 vs GEN2) afeta todo o ecossistema |
| L08 | Versões non-LTS têm Early Adopter Risk mensurável |

### Lições PRJ002 (L01_PRJ002 a L12_PRJ002)
*(ver seção 7)*

### Lições PRJ003 (L-01 a L-16)
*(ver seção 8)*

### Lições PRJ012 (L12_PRJ012 a L15_PRJ012)
*(ver seção 17)*

### Lições PRJ018 (L23–L31)
*(ver seção 22)*

### Lições PRJ022 (L32–L43)
*(ver seção 25)*

### Lições PRJ023 (L44–L50)
*(ver seção 26)*

### Lições PRJ024 (L51–L60)
*(ver seção 27)*

### Lições PRJ027 (L61–L70)
*(ver seção 30)*

### Lições PRJ028 (L71–L75)
*(ver seção 31)*

### Lições PRJ029 (L76–L80)
*(ver seção 32)*

### Lições PRJ030 (L81–L90)
*(ver seção 33)*

### Lições Estratégicas (L91–L95) — Adicionadas na v5.1

| ID | Lição |
|----|-------|
| **L91** | **Simplificação da stack é uma decisão estratégica válida** — Remover complexidade (midPoint) em favor de integração direta pode ser mais eficiente que manter ferramentas com bloqueios estruturais. |
| **L92** | **A infraestrutura deve ser resiliente** — A migração de hipervisor (PRJ030) resolveu definitivamente a CONSTRAINT-001, garantindo a continuidade do laboratório. |
| **L93** | **Classificar corretamente o papel de cada sistema** — Odoo é consumidor de identidade, NÃO Source of Truth. Essa distinção é fundamental para a arquitetura de IGA. |
| **L94** | **Documentar decisões estratégicas publicamente** — A abertura do repositório GitHub força maior clareza e rastreabilidade das decisões. |
| **L95** | **Foco em habilidades executivas** — A capacidade de comunicar decisões estratégicas é tão importante quanto a execução técnica em projetos de IGA. |

---

## 36. Frameworks de Conformidade Adotados

| Framework | Aplicação no Living Lab |
|-----------|--------------------------|
| **ISO 27001:2022** | Controles A.5 (Políticas), A.8 (Gestão de Ativos), A.9 (Controle de Acesso), A.12 (Segurança de Operações), A.13 (Segurança de Comunicações) |
| **NIST SP 800-207** | Zero Trust Architecture — implementada via Tailscale + Cloudflare + MFA |
| **CIS Benchmarks v3.0** | Hardening do Windows Server (AD) e Ubuntu (VMs Linux) |
| **NIST SP 800-53** | Controles de auditoria e logging (Wazuh + Loki) |

---

## 37. Inventário de Ativos e Topologia de Rede (Pós-PRJ030)

### VMs Ativas (estado em maio/2026 — PÓS-PRJ030)

| VM (VMware) | Hostname | Função | Status |
|-------------|----------|--------|--------|
| SENTINEL-CORE | sentinel-core | Sentinel (PRJ016) — Wazuh, Loki, Grafana | ✅ Ativa |
| VAULT-GEN1 | vault-gf-01 | HashiCorp Vault 1.21.3 | ✅ Ativa |
| defectdojo-gf-01 | defectdojo-gf-01 | DefectDojo (Docker) | ✅ Ativa |
| api-gf-01 | api-gf-01 | Shadow API FastAPI (PRJ008) | ✅ Ativa |
| Linux-Lite | linux-lite | PRJ017 (Cloudflare) | ✅ Ativa |
| SYNC-01 | sync-01 | Entra Cloud Sync Agent | ⚠️ Desligada |
| sec-openvas-kali | kali | GVM (OpenVAS) nativo | ✅ Ativa |
| rh-gf-01-local | rh-gf-01 | OrangeHRM 5.x + MariaDB | ✅ Ativa |
| IGA-GF-02 | iga-gf-02 | midPoint 4.10 (Docker) — **será descontinuado** | ⚠️ Marcado para remoção |
| PRJ015-PROD-BASE | prod-base | Base de teste PRJ015 | ⚠️ Desligada |
| ID-P-01 | id-p-01 | AD DS (corp.fiqueok.com.br) — reconstruído | ✅ Ativo |
| erp-odoo-mac | erp-odoo-mac | Odoo 17.0 (Docker) | ✅ Ativa |

### Tenant Microsoft Entra ID

| Tenant | Domínio | Estado (maio/2026) |
|--------|---------|---------------------|
| `paulofiqueokcom.onmicrosoft.com` | `fiqueok.com.br` | App Registration `midpoint-iga-connector` preservado |

### Rede Tailscale — Tags (Pós-PRJ030)

| Tag | Status | VMs associadas |
|-----|--------|----------------|
| `tag:consultor` | ❌ REMOVIDA (29/04/2026) | Nenhuma |
| Permissões padrão | ✅ Ativo | Todas as VMs com permissões de proprietário |
| `tag:ad` | ✅ Ativo (PRJ028) | ID-P-01 |
| `tag:midpoint` | ⚠️ Será removido | IGA-GF-02 (descontinuado) |

---

## 38. Governança e Gestão de Decisões

### 38.1. Documentos de Governança

| Tipo | Descrição | Exemplos |
|------|-----------|----------|
| **TAP** | Technical Assessment Plan — Planejamento do projeto | TAP-PRJ027, TAP-PRJ028, TAP-PRJ029, TAP-PRJ030 |
| **POP** | Procedimento Operacional Padrão | POP-PRJ027-v4.0, POP-MIGRACAO-HYPERV-VMWARE-001 |
| **GMUD** | Gestão de Mudança | GMUD-001-PRJ028, GMUD-001-PRJ029, GMUD-001-PRJ030 |
| **REL** | Relatório de Encerramento de Mudança | REL-GMUD-001-PRJ028, REL-GMUD001-PRJ029 |
| **TEP** | Technical Enclosure Package (Encerramento) | TEP-PRJ027-v1.0 |
| **LIC** | Lições Aprendidas | LIC-PRJ027-v1.1 |
| **ADR** | Architecture Decision Record | ADR-007 (Zero Trust para AD) |

### 38.2. Decisões Estratégicas Documentadas

| Decisão | Data | Status |
|---------|------|--------|
| CONSTRAINT-001 — Migração para VMware | 12/05/2026 | ✅ Implementada (PRJ030) |
| Descontinuidade do midPoint | Pós-PRJ030 | ✅ Aprovada |
| Odoo como consumidor (não SoT) | v5.1 | ✅ Corrigida |
| Manutenção do OrangeHRM como única SoT | Desde PRJ005 | ✅ Mantida |
| Repositório GitHub público | Maio/2026 | ✅ Publicado |

---

## 39. Papel das IAs no Laboratório

### Histórico de Uso

| IA | Papel | Período |
|----|-------|---------|
| **Perplexity** | Assistente de pesquisa e documentação | Até PRJ018 (abril/2026) |
| **Claude (Anthropic)** | GRC Advisor, consolidação de documentos | PRJ018 — presente |
| **DeepSeek-R1** | RAG local (AnythingLLM) | PRJ018 — presente |
| **Qwen2.5:7b** | RAG local (português) | PRJ018 — presente |

### Lições sobre IAs (Consolidadas)

| ID | Lição |
|----|-------|
| L-IA1 | IAs operam bem no nível de execução ("como configurar"), mas falham em diagnóstico de causa raiz sistêmica |
| L-IA2 | IAs não previram bloqueadores como GPathResult ou breaking changes do midPoint 4.10 |
| L-IA3 | A extração do Perplexity (PRJ018) exigiu engenharia reversa — IAs auxiliaram na estruturação do código |
| L-IA4 | IAs forneceram exemplos de XML que não funcionavam com midPoint 4.10 (documentação desatualizada) |

---

## 40. Riscos Abertos e Pendências Futuras (Atualizado)

### Riscos de Alto Impacto (estado em maio/2026 — PÓS-PRJ030)

| Risco | Projeto | Urgência | Ação Necessária |
|-------|---------|----------|-----------------|
| Root token Vault em uso ativo | PRJ007 | Alta | GMUD dedicada para revogar |
| Token `svc-shadow-api` expira 2026-05-17 | PRJ007/PRJ008 | **URGENTE** | Verificar renovação automática |
| Backup automático Vault não configurado | PRJ007 | Alta | Implementar cron Raft snapshot |
| Auto-unseal não implementado | PRJ007 | Alta | Backlog |
| Cloud Identity não ativado (GCP) | PRJ024 | Baixa (projeto cancelado) | Não aplicável (midPoint descontinuado) |
| App Registration preservado mas Client Secret inválido | PRJ027 | Média | Regenerar secret se necessário |
| PRJ019 frozen — ingestão Obsidian sem solução | PRJ019 | Baixa | Alternativas documentadas |
| **midPoint em processo de descontinuação** | PRJ012-027 | **Média** | Remover container IGA-GF-02 |

### Riscos ELIMINADOS (pós-PRJ030)

| Risco | Status | Justificativa |
|-------|--------|----------------|
| CONSTRAINT-001 — UEFI corrompido | ✅ **ELIMINADO** | Migração para VMware concluída |
| Perda de VMs GEN2 | ✅ **ELIMINADO** | Todas as VMs estão no VMware |
| Falha de boot de VMs críticas | ✅ **ELIMINADO** | Validação pós-migração concluída |

### Projetos em Fila (Pós-descontinuidade do midPoint)

| Projeto | Descrição | Status |
|---------|-----------|--------|
| PRJ016 | Sentinel Identity Shield (Wazuh + eBPF) | Em execução |
| PRJ020 | OpenVAS + DefectDojo — primeiro scan API PRJ008 | Aguardando feeds |
| PRJ007 Pendências | Backup automático, auto-unseal, rotação de token | Pendente |
| PRJ029 Pendências | Configuração SSO Odoo via Entra ID | Pendente |
| PRJ021 | Automação OpenVAS → DefectDojo via API | PRJ020 funcional |
| PRJ019 Redesign | Ingestor Obsidian sem Vault Agent | Alternativas documentadas |

### Projetos CANCELADOS (pós-descontinuidade do midPoint)

| Projeto | Motivo |
|---------|--------|
| PRJ025 (midPoint → Keycloak) | midPoint descontinuado |
| PRJ026 (midPoint → AD) | midPoint descontinuado |
| PRJ024 (midPoint → GCP) | midPoint descontinuado |
| PRJ023 (midPoint → AWS) | midPoint descontinuado |
| PRJ022 Estágio B | midPoint descontinuado |

---

## 41. Glossário Técnico do Laboratório

| Termo | Definição no Contexto Fiqueok |
|-------|-------------------------------|
| **GMUD** | Gestão de Mudança — documento formal de planejamento |
| **ADR** | Architecture Decision Record |
| **Canvas (CAN-ID)** | Contrato semântico de identidade |
| **Production Checkpoint** | Checkpoint Hyper-V com VSS (substituído por snapshot VMware) |
| **Soberania de Dados** | Estratégia de injeção manual de schema PostgreSQL antes do boot do midPoint (PRJ003) |
| **Smooth Scroll** | Técnica de rolagem suave usada no PRJ018 para forçar renderização do Perplexity |
| **Dependência contínua** | Relação que requer conexão em tempo real |
| **Dependência pontual** | Evento único concluído |
| **Camadas Temáticas** | Organização de documentos do PRJ018 em 6 camadas (Fundação a Segurança) |
| **GPathResult** | Erro `NoClassDefFoundError` no ScriptedREST com Java 21 (PRJ022) |
| **AWSConnector / GCPConnector** | Conectores Atricore para clouds — provisionam usuários mas não grupos/políticas |
| **Cloud Identity** | Serviço obrigatório do GCP para visualizar usuários criados via conector (PRJ024) |
| **App Registration** | Recurso do Entra ID que sobrevive a restores de VM local (PRJ012/PRJ027) |
| **CONSTRAINT-001** | Falha de firmware UEFI no Hyper-V — **RESOLVIDA** pelo PRJ030 |
| **Trilha de Migração** | Classificação de VMs para migração: Verde (GEN1), Amarela (GEN2), Vermelha (rebuild) |
| **Source of Truth (SoT)** | Fonte autoritativa de dados — **OrangeHRM** (único) |
| **Consumidor de Identidade** | Sistema que consome identidade via SSO (ex: Odoo) — NÃO é SoT |

---

## 42. Decisões Estratégicas do Living Lab (v5.1)

### 42.1. Stack de Identidade — Arquitetura Final

| Decisão | Status | Justificativa |
|---------|--------|----------------|
| **OrangeHRM como única Source of Truth (SoT)** | ✅ Mantida | Única fonte autoritativa para dados de RH. Nenhum outro sistema (incluindo Odoo) tem papel de SoT. |
| **Active Directory como IDP Local** | ✅ Mantida | Autenticação para recursos on-premise, GPOs, Kerberos. Hardening aplicado (PRJ028). |
| **Microsoft Entra ID Free como IDP Cloud** | ✅ Mantida | Autenticação para SaaS, SSO. App Registration preservado. |
| **Odoo 17.0 como consumidor SaaS** | ✅ Corrigida (v5.1) | Odoo consome identidade via SSO, NÃO gerencia identidades. Correção de erro de interpretação da v5.0. |
| **midPoint removido** | ✅ Aprovada | Complexidade excessiva, bloqueios estruturais. Stack simplificada é mais eficiente. |
| **Acesso remoto via Tailscale + MFA** | ✅ Implementada | Zero Trust, criptografia WireGuard, microssegmentação. |
| **Migração VMware concluída** | ✅ Implementada | CONSTRAINT-001 resolvida definitivamente. |

### 42.2. Decisões de Infraestrutura

| Decisão | Status | Justificativa |
|---------|--------|----------------|
| **Abandono do Hyper-V** | ✅ Implementada | CONSTRAINT-001 (UEFI corrompido) inviabilizou continuidade. |
| **VMware Workstation Pro como hipervisor principal** | ✅ Implementada | Mais resiliente, snapshots funcionais, suporte a VMs GEN2 sem problemas. |
| **600 GB de ativos migrados com sucesso** | ✅ Concluída | 11 VMs, 100% de sucesso. |
| **Backup em HD externo pré-migração** | ✅ Executado | Procedimento obrigatório documentado no POP. |

### 42.3. Decisões de Governança

| Decisão | Status | Justificativa |
|---------|--------|----------------|
| **Repositório GitHub público** | ✅ Publicado (maio/2026) | Transparência, rastreabilidade, compartilhamento de conhecimento. |
| **Documentação como evidência de auditoria** | ✅ Mantida | TAPs, POPs, GMUDs, RELs, TEPs, LICs, ADRs gerados para todos os projetos. |
| **Foco em habilidades executivas** | ✅ Adotado | A capacidade de comunicar decisões estratégicas é prioridade. |

### 42.4. Correções em Relação à Versão 5.0

| Erro na v5.0 | Correção na v5.1 |
|--------------|------------------|
| Odoo classificado como "Source of Truth" | ❌ INCORRETO — Odoo é consumidor de identidade |
| Odoo como substituto do OrangeHRM | ❌ INCORRETO — OrangeHRM mantido como única SoT |
| Odoo como integrador IGA | ❌ INCORRETO — Odoo não tem papel de orquestração |
| PRJ030 como "em planejamento" | ✅ Corrigido — PRJ030 concluído |
| CONSTRAINT-001 como "risco aberto" | ✅ Corrigido — CONSTRAINT-001 resolvida |
| midPoint como "ativo" | ✅ Corrigido — midPoint em descontinuação |

---

## 43. Repositório GitHub Público

### 43.1. Decisão de Abertura (Maio/2026)

O responsável pelo Living Lab decidiu tornar público o repositório GitHub que antes era privado. Esta decisão reflete:

- **Transparência:** Documentar publicamente as decisões estratégicas, sucessos e fracassos
- **Compartilhamento de conhecimento:** Oferecer lições aprendidas para a comunidade de IGA open-source
- **Rastreabilidade:** Garantir que todas as decisões (incluindo as incorretas) sejam auditáveis
- **Foco em habilidades executivas:** A comunicação pública é uma competência essencial para profissionais seniores

### 43.2. Conteúdo do Repositório

| Categoria | Conteúdo |
|-----------|----------|
| **Documentos de contexto** | CONTEXTO_LivingLab_Fiqueok_v5.1.md (este documento) |
| **TAPs** | Planejamento de todos os projetos (PRJ001 a PRJ030) |
| **POPs** | Procedimentos operacionais padronizados |
| **GMUDs / RELs** | Gestão de mudança e relatórios de encerramento |
| **TEPs / LICs** | Encerramento de projetos e lições aprendidas |
| **ADRs** | Architecture Decision Records |
| **Scripts** | Automação, hardening, migração |
| **Configurações** | Docker Compose, Tailscale, Vault, midPoint (histórico) |

### 43.3. Acesso

O repositório está disponível publicamente para consulta. As decisões documentadas (incluindo a descontinuidade do midPoint e a correção do papel do Odoo) estão refletidas na versão mais recente do documento de contexto.

---

**CONTEXTO_LivingLab_Fiqueok_v5.1.md — Documento de Referência para RAG**  
*Baseado exclusivamente em evidência primária dos vaults Obsidian exportados + TEPs PRJ002, PRJ003, PRJ012, PRJ018, PRJ022–PRJ030*  
*Cobrindo PRJ001 a PRJ030 — Dezembro/2025 a Maio/2026*  
*Paulo Feitosa Lima — Living Lab Fiqueok*  
*Gerado com Claude Sonnet como GRC Lead — Maio de 2026*

**Versão 5.1 — Correções arquiteturais:**
- ✅ OrangeHRM reafirmado como única Source of Truth (SoT)
- ✅ Odoo reclassificado como consumidor SaaS (NÃO é SoT)
- ✅ midPoint marcado como descontinuado pós-PRJ030
- ✅ PRJ030 atualizado para "Concluído"
- ✅ CONSTRAINT-001 marcada como "Resolvida"
- ✅ Hierarquia da stack corrigida: OrangeHRM → AD → Entra → SaaS
- ✅ Repositório GitHub público documentado

```