# CONTEXTO — Living Lab Fiqueok: Saga IAM/IGA
## Documento de Referência para RAG — v1.0
**Gerado em:** Abril de 2026  
**Responsável:** Paulo Feitosa (IAM Specialist / Auditor / GRC Lead)  
**Fonte:** Evidência primária — vaults Obsidian exportados (PRJ001 a PRJ007)  
**Uso:** Contexto para AnythingLLM + Ollama / DeepSeek-R1

---

## ÍNDICE

1. [Sobre o Living Lab Fiqueok](#1-sobre-o-living-lab-fiqueok)
2. [Identidade do Responsável](#2-identidade-do-responsável)
3. [Infraestrutura Base do Laboratório](#3-infraestrutura-base-do-laboratório)
4. [Princípios Arquiteturais Consolidados](#4-princípios-arquiteturais-consolidados)
5. [Linha do Tempo da Saga (PRJ001–PRJ007)](#5-linha-do-tempo-da-saga-prj001prj007)
6. [PRJ001 — Laboratório de SI](#6-prj001--laboratório-de-si)
7. [PRJ002 — Infraestrutura Fiqueok](#7-prj002--infraestrutura-fiqueok)
8. [PRJ003 — IGA Greenfield (Fundamentos Arquiteturais)](#8-prj003--iga-greenfield-fundamentos-arquiteturais)
9. [PRJ004 — IGA Data Lifecycle (CSV)](#9-prj004--iga-data-lifecycle-csv)
10. [PRJ005 — Integração de Fonte Autoritativa (OrangeHRM)](#10-prj005--integração-de-fonte-autoritativa-orangehrm)
11. [PRJ006 — Integração Dinâmica via JDBC (Abortado)](#11-prj006--integração-dinâmica-via-jdbc-abortado)
12. [PRJ007 — HashiCorp Vault (PAM)](#12-prj007--hashicorp-vault-pam)
13. [Lições Aprendidas Transversais](#13-lições-aprendidas-transversais)
14. [Frameworks de Conformidade Adotados](#14-frameworks-de-conformidade-adotados)
15. [Inventário de Ativos e Topologia de Rede](#15-inventário-de-ativos-e-topologia-de-rede)
16. [Governança e Gestão de Decisões](#16-governança-e-gestão-de-decisões)
17. [Papel das IAs no Laboratório](#17-papel-das-ias-no-laboratório)
18. [Riscos Abertos e Pendências Futuras](#18-riscos-abertos-e-pendências-futuras)
19. [Glossário Técnico do Laboratório](#19-glossário-técnico-do-laboratório)

---

## 1. Sobre o Living Lab Fiqueok

O Living Lab Fiqueok é um laboratório de experimentação técnica pessoal, operado por Paulo Feitosa em ambiente doméstico (HomeLab) com Hyper-V sobre Windows 11 Pro. Seu propósito é simular ambientes corporativos reais de IAM (Identity and Access Management) e IGA (Identity Governance and Administration), documentando a jornada com rigor de governança equivalente ao de uma organização Fintech.

O laboratório serve três objetivos simultâneos:

- **Aprendizado aplicado** — implementação real de tecnologias IAM/IGA com falhas, pivôs e soluções documentadas honesamente
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
- **Cloudflare Zero Trust** — exposição segura de serviços com OTP via e-mail (implementado no PRJ017, a partir de abr/2026)
- Virtual Switches Hyper-V para redes internas

### Plataforma de documentação
- **Obsidian** (vault `FiqueokBrain`) — fonte única de verdade para toda documentação do laboratório
- Organização por projeto com pastas padronizadas: `00_Gestao_do_Projeto`, `10_Arquitetura_Tecnica`, `20_Governanca_e_Decisoes`, `30_Operacao_e_Mudanca`, `50_Evidencias`

### CONSTRAINT-001 (ativa desde 09/02/2026)
Corrupção do subsistema UEFI do Hyper-V impede criação de novas VMs do tipo GEN2. VMs existentes não são afetadas. Sintomas: novas VMs não inicializam com erro "The boot loader did not load"; desligamento via GUI retorna erro `0x800710DF`. `SFC /scannow` e `DISM /RestoreHealth` não corrigem. Workaround ativo: uso de GEN1 ou WSL2. Resolução definitiva planejada para Q2/2026 (reinstalação do Windows).

---

## 4. Princípios Arquiteturais Consolidados

Estes princípios foram destilados a partir das evidências de PRJ001 a PRJ007. Cada um foi validado empiricamente — a maioria por uma falha que o tornou necessário.

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

---

## 5. Linha do Tempo da Saga (PRJ001–PRJ007)

| Período | Projeto | Status | Resultado Principal |
|---------|---------|--------|---------------------|
| Dez/2025 | PRJ001 | ✅ Concluído | Baseline de SI; migração VirtualBox → Hyper-V; scans OpenVAS; hardening inicial |
| Jan/2026 | PRJ002 | ✅ Concluído | Infra core (AD, midPoint, OrangeHRM); 25+ GMUDs; incidente de rede; domínio `corp.fiqueok.com.br` |
| Jan/2026 | PRJ003 | ✅ Concluído | Fundamentos arquiteturais IGA Greenfield; Canvases de Identidade; midPoint 4.10 funcional |
| Jan/2026 | PRJ004 | ✅ Concluído | CSV como fonte autoritativa; primeiro ciclo JML completo validado |
| Fev/2026 | PRJ005 | ✅ Concluído | OrangeHRM como fonte autoritativa; conectividade JDBC segura estabelecida em 2 dias |
| Fev/2026 | PRJ006 | ⚠️ Abortado | Anti-padrão JDBC identificado; decisão API-first; higiene de infraestrutura executada |
| Fev–Abr/2026 | PRJ007 | 🟡 Ativo | HashiCorp Vault operacional em GEN1; 3 plataformas tentadas; GMUD-003 executada abr/2026 |

---

## 6. PRJ001 — Laboratório de SI

**Período:** Dezembro/2025  
**Status:** ✅ Concluído  
**Objetivo:** Estabelecer baseline de segurança do laboratório e migrar a plataforma de VirtualBox para Hyper-V.

### Contexto
O PRJ001 foi o projeto inaugural do Living Lab, nascendo de uma necessidade de criar um ambiente estruturado para aprendizado de Segurança da Informação. O ponto de partida foi um laboratório informal em VirtualBox que precisava de maior estabilidade, governança e documentação. Este projeto estabeleceu o modelo formal de GMUDs que seria usado em todos os projetos subsequentes.

### GMUDs Executadas

- **GMUD-001:** Configuração de rede OOB (Host-Only 192.168.56.x) — ✅ Sucesso
- **GMUD-002:** Hardening TLS — desabilitação de TLS 1.0/1.1 no Apache — ✅ Sucesso
- **GMUD-003:** Bloqueio de enumeração anônima RPC via `RestrictAnonymous=1` — ✅ Sucesso (falso positivo identificado e tratado na validação)
- **GMUD-004:** Estruturação de OUs no Active Directory — planejada
- **GMUD-006:** Migração de VirtualBox para Hyper-V — ✅ Executada

### Vulnerabilidades Identificadas (OpenVAS)
O scan inicial identificou 2 vulnerabilidades médias (TLS obsoleto, enumeração RPC anônima) e 3 baixas. As duas médias foram tratadas via GMUD-002 e GMUD-003.

### Domínio
Iniciou com `lab.local`, migrado posteriormente para `corp.fiqueok.com.br`.

### Resultado
Ambiente de laboratório migrado para Hyper-V com baseline de segurança estabelecido, hardening inicial aplicado e primeiras GMUDs formalizadas. Base para todos os projetos subsequentes.

---

## 7. PRJ002 — Infraestrutura Fiqueok

**Período:** Janeiro/2026  
**Status:** ✅ Concluído  
**Objetivo:** Construir a infraestrutura completa do laboratório Greenfield com Hyper-V, Active Directory, midPoint e OrangeHRM.

### Contexto
O PRJ002 foi o projeto mais extenso da fase inicial, com mais de 25 GMUDs executadas ao longo de um mês. Estabeleceu o domínio `corp.fiqueok.com.br`, implantou as principais VMs e realizou as primeiras tentativas de integração IGA — todas documentando tanto sucessos quanto falhas com a mesma fidelidade.

### Topologia de Rede
- **VM ID-P-01** (xxx.xxx.xxx.xxx) — Active Directory Domain Services
- **VM IGA-P-01** (xxx.xxx.xxx.xxx) — midPoint 4.10 + OrangeHRM 5.x (Docker)
- **Segmento:** xxx.xxx.xxx.xxx/16 (conflito /16 vs /24 causou incidente crítico)

### GMUDs por Categoria

**Infra Core (sucesso):**
- GMUD-001 a 005: vSwitch, NAT, AD DS, estrutura de OUs, DHCP — todos concluídos com sucesso
- GMUD-008: Deploy midPoint 4.10 + PostgreSQL 16 via Docker — ✅ Sucesso
- GMUD-009: OrangeHRM 5.x + MariaDB — ✅ Sucesso
- GMUD-011: Rede de integração segura (fiqueok-backend-net) — ✅ Sucesso
- GMUD-016: Integração AD via LDAP 389 + linking user 0001 — ✅ Sucesso (realizado retroativamente sem GMUD prévia)

**GMUDs com falha ou problemas:**
- GMUD-007: IP estático em IGA-P-01 — problema com cloud-init (rede /16 conflitando com /24)
- GMUD-010: Resource OrangeHRM via conector DatabaseTable — ❌ Falhou (driver JDBC ausente, schema mismatch)
- GMUD-013: Resource OrangeHRM v2 via GUI Discovery — ⚠️ Parcial
- GMUD-015/FIX-NET: Conflito /16 vs /24 deixou o laboratório offline por 19 horas — ✅ Resolvido
- GMUD-015A: VLAN20 + svc_ansible (sudoers whitelist) — Parcial
- GMUD-017: Correção OrangeHRM-midPoint — ❌ Sem sucesso após 5 tentativas; causa raiz não identificada
- GMUD-018 v2.0: ScriptedSQL Groovy (substituindo DatabaseTable) — planejada, não executada neste projeto
- GMUD-020: Downgrade midPoint 4.10 → 4.8.8 LTS — planejada (Early Adopter Risk confirmado)

**ADRs relevantes:**
- ADR-004: DatabaseTable vs ScriptedSQL — ScriptedSQL venceu (score 8.65 vs 3.75 na matriz de decisão)
- ADR-005: Rebuild IGA-P-01 para IGA-P-02
- ADR-006: Estratégia de ingestão de dados OrangeHRM-midPoint

### Incidente Crítico
**INC-FQK-2025-015B:** Laboratório ficou offline após conflito de subnets. midPoint inacessível. Tempo de resolução: ~19 horas. Causa raiz: configuração de rede /16 conflitando com rota local /24. Resolução via GMUD corretiva com restauração de conectividade.

### Sequência de Encerramento (GMUDs 021A–025)
As GMUDs finais realizaram sanitização, rollback histórico e validação do CSV canônico como fonte autoritativa temporária. A GMUD-025 declarou formalmente o início do PRJ003 IGA Greenfield — ponto de inflexão arquitetural do laboratório.

### Resultado
Infraestrutura completa estabelecida. midPoint 4.10 e OrangeHRM operacionais. Múltiplas falhas de integração JDBC documentadas. Decisão de reiniciar o IGA em modo Greenfield com canvases de decisão precedendo qualquer automação.

---

## 8. PRJ003 — IGA Greenfield (Fundamentos Arquiteturais)

**Período:** Janeiro/2026  
**Status:** ✅ Concluído  
**Objetivo:** Estruturar os fundamentos arquiteturais e operacionais do Living Lab Fiqueok 2.0 antes de qualquer implementação técnica. Projeto estruturante — não uma GMUD, mas o alicerce que orienta todas as GMUDs subsequentes.

### Contexto e Propósito
O PRJ003 nasceu do reconhecimento de que as falhas do PRJ002 não eram técnicas — eram semânticas. Identificadores implícitos, autoridade de dados não definida, estados de identidade ambíguos. O PRJ003 existe para eliminar esses riscos na raiz, estabelecendo contratos de identidade antes de qualquer configuração técnica.

**Problema central identificado (DOC-ARC-001):** Falhas em automações IGA surgem de lacunas semânticas, não técnicas. Três problemas recorrentes: identificador canônico indefinido, autoridade de dados implícita, estados da identidade ambíguos.

### Canvases de Decisão de Identidade (gates obrigatórios)

**CAN-ID-001 — Identidade Canônica:**
- A entidade canônica representa uma Pessoa no contexto organizacional
- Existe independentemente de vínculos técnicos, contas, permissões ou estados de provisionamento
- Identidade canônica não é uma conta, não é um usuário técnico, não é um registro de sistema
- Identificador canônico: único, criado e mantido no domínio IGA, imutável ao longo do ciclo de vida
- Identificadores técnicos externos (AD, LDAP) não são âncoras de identidade
- Status: Consolidado (gate obrigatório para qualquer GMUD técnica)

**CAN-ID-002 — Autoridade de Dados de Identidade:**
- Não existe fonte soberana única para todos os atributos
- Autoridade é definida por atributo, não por sistema
- Fontes técnicas (AD, LDAP) nunca sobrescrevem dados de negócio (HR)
- Conflitos não são resolvidos implicitamente — exigem regra explícita
- midPoint atua como orquestrador semântico, não como "dono absoluto" dos dados
- Precedência é decisão arquitetural — precede integração técnica

**CAN-ID-003 — Estados da Identidade:**
- Estados canônicos: Pré-criada, Ativa, Suspensa, Desligada, Órfã (sem vínculo válido com fonte de negócio)
- Estados existem mesmo sem contas técnicas provisionadas
- "Habilitado/Desabilitado de conta AD" é estado técnico — não redefine estado de identidade
- Transições de estado são decisões explícitas, não inferências de sistemas
- "Órfã" é estado canônico válido que exige tratamento explícito

**DEC-ID-001 v1.1 — Identity Decision Canvas:**
- Tipos de decisão: Arquitetural, Governança, Técnica, Operacional, Experimental
- Decisões semânticas precedem automação — GMUD técnica não cria semântica
- Configuração não substitui decisão — workaround sem governança é proibido
- Mudanças estruturais em canvases exigem ADR formal
- Decisões proibidas "em voo" durante GMUD: redefinir identidade canônica, alterar autoridade de dados por configuração, criar estados implícitos via sistema técnico

**DGC-001 — Data Governance Canvas:**
- Retenção de identidade canônica e eventos de lifecycle: permanente
- Correções manuais permitidas apenas pelo Owner, com registro explícito
- Sem correções silenciosas
- Dados preservados para aprendizado e auditoria mesmo após desligamento

### ADRs do PRJ003

**ADR-001 — Persistência com Bind Mounts:**
Dados persistidos em `/srv/prj003/` no host (não volumes anônimos Docker). Garante sobrevivência após `docker compose down` e auditabilidade direta no filesystem do Ubuntu. Alinhado com DGC-001 (rastreabilidade e auditoria).

**ADR-002 v1.1 — Reversibilidade e IaC:**
- Production Checkpoints Hyper-V obrigatórios antes de qualquer GMUD técnica (nomenclatura `PRE-GMUD-XXX`)
- Scripts IaC (PowerShell/Bash/Docker Compose) são obrigatórios — comandos CLI avulsos proibidos como procedimento de GMUD
- Credenciais hardcoded estritamente proibidas — gestão via .env protegido
- Análise de causa raiz obrigatória (ISO 27001 A.8.32) antes de nova tentativa após falha
- Captura de logs pré-rollback obrigatória para preservar evidências

**ADR-003 v1.1 — Cross-Mapping de Frameworks:**
Adoção simultânea de ISO/IEC 27001:2022, CIS Controls v8, NIST CSF 2.0, NIST RMF e SOC 2. Um controle técnico gera evidências para múltiplos frameworks simultaneamente — máxima eficiência de conformidade.

### GMUDs Técnicas do PRJ003

- **GMUD-001:** Estruturação do projeto no Obsidian
- **GMUD-002:** Consolidação dos Canvases CAN-ID (gate obrigatório)
- **GMUD-004 v1.1:** Cold Start da infraestrutura IAM (VM Ubuntu 24.04, Docker) — ✅ Sucesso
- **GMUD-005 v1.3:** Deploy midPoint — ❌ Race Condition (PostgreSQL não inicializou antes do midPoint; usuário `administrator` criado de forma inconsistente)
- **GMUD-006 v1.4:** Deploy com orquestração em duas fases (Fase 1: PostgreSQL → aguardar "ready to accept connections" → Fase 2: midPoint) — ✅ Resolveu a race condition
- **GMUD-007:** Deploy manual passo-a-passo exploratório — histórico de falhas documentado para orientar automação futura
- **GMUD-008 v1.2:** Deploy automatizado IaC (PowerShell) — correção de escaping em heredoc, timeout 180s, gate anti-H2 (verifica se midPoint ativou fallback para banco embutido H2)
- **GMUD-009:** Deploy manual da infraestrutura IGA — ✅ Sucesso
- **GMUD-012:** Deploy midPoint 4.10 — ✅ SUCESSO (REL-GMUD-012 com status SUCESSO confirmado)

### Lição crítica documentada
A sequência GMUD-005 → GMUD-006 demonstrou que nenhuma IA (Claude, ChatGPT, Perplexity) previu a race condition entre PostgreSQL e midPoint. A solução foi encontrada empiricamente. IAs sugeriram WSL2 para o PRJ007 sem prever limitações estruturais.

### Resultado
midPoint 4.10 operacional com PostgreSQL 16, Raft storage, bind mounts em `/srv/prj003/`. Canvases CAN-ID consolidados como gates arquiteturais. Fundação sólida para PRJ004 e PRJ005.

---

## 9. PRJ004 — IGA Data Lifecycle (CSV)

**Período:** Janeiro/2026 (paralelo ao PRJ003)  
**Status:** ✅ Concluído  
**Objetivo:** Validar o ciclo JML (Joiner-Mover-Leaver) usando CSV como fonte autoritativa, antes de integrar com sistemas dinâmicos.

### Contexto
Antes de integrar com OrangeHRM (PRJ005), o PRJ004 validou o modelo conceitual de IGA usando um arquivo CSV simples como fonte de identidades. Esse approach permitiu testar os mecanismos de correlação, mapeamento de atributos e reações de sincronização do midPoint sem a complexidade de um sistema HR externo. Funcionou como "prova de conceito controlada" do ciclo JML.

### Entregas
- Configuração do resource CSV no midPoint 4.10 com correlação por `personalNumber`
- POP-IGA-001: Implementação Completa de Ambiente IGA (evoluiu até v4.1)
- Validação empírica do ciclo JML com identidades de teste
- Baseline CSV com dados canonicamente validados como referência para PRJ005

### Resultado
Primeiro ciclo JML completo validado empiricamente. CSV confirmado como baseline de governança para validações de integridade de dados. Mecanismo de correlação do midPoint entendido antes de escalar para integração HR real.

---

## 10. PRJ005 — Integração de Fonte Autoritativa (OrangeHRM)

**Período:** 02–03 de Fevereiro/2026  
**Duração:** 2 dias  
**Status:** ✅ Concluído com Sucesso Operacional

### Objetivo
Estabelecer o OrangeHRM como fonte autoritativa de identidades, substituindo o modelo manual baseado em CSV. Integração via conector JDBC (MariaDB) com controles de segurança formais.

### Arquitetura da Solução

- **VM IGA:** `iga-gf-01` — IP xxx.xxx.xxx.xxx — midPoint 4.10 (Docker, Ubuntu 24.04)
- **VM RH:** `rh-gf-01` / `orangehrm-gf-01` — IP xxx.xxx.xxx.xxx — OrangeHRM 5.x + MariaDB (Docker, Ubuntu 24.04)
- **Protocolo:** JDBC na porta 3306, usuário de serviço com SELECT apenas

### Atividades Executadas

**Fase 1 — Infraestrutura e Conectividade (concluída em 1 dia):**

Handshake TCP validado na porta 3306 via `nc -zv xxx.xxx.xxx.xxx 3306`. UFW configurado no servidor RH com regra restrita: `ufw allow from xxx.xxx.xxx.xxx to any port 3306`. Erro de sintaxe YAML no docker-compose.yml (indentação linha 14) causou downtime de 45 min — corrigido com linter YAML. Usuário de serviço `midpoint_user` criado no MariaDB com `SELECT` apenas no database `greenfield_hr`, conexão restrita por origem (apenas de xxx.xxx.xxx.xxx).

**Query de Ouro (baseline de governança):**
```sql
SELECT 
    e.emp_number,
    e.employee_id,
    e.emp_firstname,
    e.emp_lastname,
    e.emp_work_email,
    jt.job_title_name,
    su.name as subunit_name
FROM hs_hr_employee e
LEFT JOIN ohrm_job_title jt ON e.job_title_code = jt.id
LEFT JOIN ohrm_subunit su ON e.work_station = su.id
```

`LEFT JOIN` usado intencionalmente — colaboradores sem cargo ou departamento não devem ser excluídos da extração.

**Checkpoints Hyper-V criados:**
- `PRJ005_Infra_Ready_Check` — pós-validação de rede e firewall
- `PRJ005_Pre_Logic_Config` — pré-configuração lógica no IGA
- `PRJ005_DB_Config_Complete` — pós-configuração do banco

### Lições Aprendidas

- **L01 (Inventário de Ativos):** Inconsistência entre hostname do OS e nome da VM no Hyper-V causou atraso de 30 min. Padronização de nomenclatura entre camadas é fundamental. Scripts de validação devem verificar naming conventions antes de qualquer deployment.
- **L02 (PAM/Credenciais):** Dificuldade na recuperação de credenciais administrativas customizadas (`M1dP0!ntAdm!n#2026`) por ausência de cofre de senhas. Motivou criação do PRJ007 (HashiCorp Vault).
- **L03 (IaC Linting):** Erro de indentação YAML causou downtime completo do MariaDB. Validação automática com yamllint antes de aplicar mudanças é obrigatória. Pre-commit hooks recomendados.
- **L04 (Validação de IA):** IA sugeriu credenciais padrão incorretas durante troubleshooting. Verificação sempre contra documentação e registros próprios — nunca aceitar sugestão de IA para credenciais sem confirmação.
- **L05 (Query Design):** LEFT JOIN vs INNER JOIN — inclusividade de dados é padrão para atributos opcionais. INNER JOIN criaria exclusão silenciosa de identidades sem cargo ou departamento.

### KPIs Alcançados
- Conectividade JDBC: 100% de disponibilidade durante testes
- Segurança de perímetro: zero exposições não autorizadas
- Rollback: < 3 minutos (média, via checkpoints)
- Integridade de dados: 100% dos atributos mapeados corretamente

### Conformidade ISO 27001
- A.13.1.1 (Segregação de Redes): UFW com regra restritiva entre VMs
- A.9.4.4 (Privilégios Mínimos): usuário `midpoint_user` com SELECT apenas
- A.12.3.1 (Backup de Informações): 3 checkpoints Hyper-V criados

### Resultado
"Duto de dados" funcional e seguro entre midPoint e OrangeHRM. Conectividade JDBC validada, segurança de perímetro estabelecida, usuário de serviço com privilégios mínimos. Fundação entregue ao PRJ006.

---

## 11. PRJ006 — Integração Dinâmica via JDBC (Abortado)

**Período:** Janeiro–02 de Fevereiro/2026  
**Duração:** ~30 dias (com interrupções de dias entre sessões)  
**Status:** ⚠️ Abortado — Estratégia Descontinuada

### Objetivo Original
Integrar midPoint ao OrangeHRM via conector DatabaseTable (JDBC direto ao PostgreSQL/MariaDB), permitindo sincronização automatizada de dados de colaboradores e provisionamento baseado em eventos de RH para OpenLDAP.

### Causa Raiz do Aborto: Anti-Padrão Arquitetural

O schema do OrangeHRM é altamente normalizado — dados de um único colaborador estão distribuídos em múltiplas tabelas com relacionamentos intrincados (`ohrm_user`, `hs_hr_employee`, `ohrm_job_title`, `ohrm_subunit`, `ohrm_employment_status`, dezenas de outras). Para extrair um "perfil único de usuário" via SQL direto, a query evoluiu para 8+ JOINs com soft-delete e lógica de negócio reimplementada em SQL.

**Violações arquiteturais identificadas:**
- Violação de encapsulamento — bypassa validações e regras de negócio da aplicação
- Acoplamento de baixo nível — qualquer mudança de schema do OrangeHRM quebra a integração silenciosamente
- Duplicação de lógica de negócio — regras de soft-delete, status de emprego reimplementadas em SQL
- Fragilidade — atualizações de versão (OrangeHRM 5.8 → 6.0) podem quebrar integração completamente

**Resultado técnico:** Correlação JDBC nunca funcionou. Usuários persistiam em estado `UNMATCHED`. Reações de sincronização configuradas mas nunca disparadas. 5+ variações de XML testadas. Logs insuficientes para diagnóstico científico.

### 10 Desafios Documentados (D01–D10)

- **D01:** Schema normalizado exige 8+ JOINs — cada novo atributo adiciona novo JOIN, criando fragilidade crescente
- **D02:** Falha de correlação JDBC persistente — estado UNMATCHED mesmo com configuração XML sintaticamente correta
- **D03:** Reações de sincronização não disparavam mesmo após correlação aparentemente configurada
- **D04:** Conflitos de IP entre VMs e host Windows (DHCP 192.168.68.x) — SSH instável, impossível distinguir problema de rede de problema de configuração
- **D05:** Interface web do midPoint não permite configuração avançada de correlação — edição direta de XML via "Edit Raw" necessária
- **D06:** Documentação oficial do midPoint 4.8 inconsistente com ambiente 4.10; driver MariaDB vs MySQL com diferenças
- **D07:** Workflow fragmentado em sessões de 2-3 horas com intervalos de 3-7 dias — perda massiva de contexto
- **D08:** Configurações via interface GUI geravam XML incompleto vs XML configurado manualmente
- **D09:** Logs do midPoint insuficientes para troubleshooting científico mesmo em modo DEBUG
- **D10:** 30 dias de calendário para trabalho efetivo estimado em 3-4 dias contínuos

### Ações de Encerramento Executadas

**Higiene de infraestrutura (última ação do PRJ006):**
- Migração para subnet isolada: 192.168.70.0/24 com IPs fixos (rh-gf-01 → .11, iga-gf-01 → .10)
- Remoção da VLAN20 (overhead sem benefício para lab de tamanho pequeno)
- Tailscale consolidado como backbone permanente com MagicDNS
- OAuth 2.0 Confidential Client configurado no OrangeHRM (Client ID + Client Secret documentados)

**Snapshots "Marco Zero PRJ007":**
- `PRJ007-IGA-RedeSaneada-OK` — midPoint operacional, rede .70 + Tailscale, pronto para configuração REST
- `PRJ007-RH-RedeSaneada-OAuth-OK` — OrangeHRM operacional, OAuth configurado e testado, API acessível

### Decisão Estratégica Final
**JDBC → API REST.** Princípio consolidado: API-first, respeitar a camada de aplicação. A API do OrangeHRM entrega dados já processados, validados e normalizados pela lógica de negócio. OAuth 2.0 oferece segurança moderna vs. credenciais de banco expostas em configuração.

### Lições Aprendidas (L01–L07)

- **L01 (Arquitetura):** Respeite a camada de aplicação. JDBC em sistemas modernos é anti-padrão que viola encapsulamento e cria acoplamento insustentável
- **L02 (Planejamento):** Complexidade oculta de schemas de terceiros é subestimada em 10x. 80% do tempo foi gasto entendendo schema, não configurando midPoint
- **L03 (Infraestrutura):** Não se constrói IGA sobre rede instável. Higiene de infraestrutura é Fase 0, não melhoria futura
- **L04 (Governança):** Abortar projeto por razões certas é decisão de governança correta. "Fail fast" é sucesso quando a arquitetura está fundamentalmente errada
- **L05 (Conhecimento):** Documentação em tempo real é obrigatória. Template de sessão: estado inicial → objetivo → ações → resultado → próximos passos
- **L06 (Metodologia):** Teste incremental é não-negociável. Nunca configurar correlação + mapeamentos + reações simultaneamente
- **L07 (IA):** IA é ferramenta, não substituto de expertise. XMLs sintaticamente corretos mas semanticamente errados consumiram sessões inteiras de troubleshooting

### KPIs de Conhecimento (todos superaram expectativas)
- 10 desafios documentados com causa raiz e hipótese de resolução
- 7 lições aprendidas catalogadas com aplicabilidade futura
- Post-mortem exaustivo publicado
- Infraestrutura completamente saneada e entregue ao PRJ007

---

## 12. PRJ007 — HashiCorp Vault (PAM)

**Período:** Fevereiro–Abril/2026 (em curso)  
**Status:** 🟡 Ativo — Operação contínua com melhorias incrementais via GMUD

### Contexto e Justificativa
O PRJ007 nasceu de um gatilho identificado durante o PRJ006 e confirmado no PRJ005: a ausência de um cofre de senhas centralizado causava dependência de memória humana, credenciais hardcoded e risco operacional. O PRJ007 estabelece a **fundação de segurança PAM** para todos os projetos do Living Lab que requerem gestão de secrets.

### Cronologia Completa (3 plataformas, múltiplas fases)

**Fase 0-a — OCI ARM (Fevereiro/2026, anterior à numeração oficial):**
Vault 1.21.2 implantado em instância ARM OCI (Ampere, Vinhedo/Brasil, 24 GB RAM, Ubuntu + Docker). Funcional com Tailscale (IP xxx.xxx.xxx.xxx). Autenticação userpass configurada. Destruído acidentalmente por clique em "Terminate" ao invés de acessar o terminal. Instâncias ARM gratuitas esgotadas na região — impossível recriar.

**Fase 0-b — Tentativa WSL2 + Docker com Gemini (08/02/2026):**
Gemini sugeriu `chmod 777` em diretórios sensíveis do Vault (`~/vault/data`, `~/vault/logs`) — violação crítica de segurança. Stop Work Authority aplicado por Paulo. Gemini rejeitado. Problema adicional: incompatibilidade de file locking entre Docker bind mounts e WSL2 causava container em loop `Restarting (1)`. Rollback para Greenfield. Relatório de incidente documentado.

**Fase 1 — WSL2 + Instalação Nativa (07–09/02/2026):**
- Vault 1.21.2 instalado via apt (repositório HashiCorp oficial) no Ubuntu 22.04 WSL2 — sem Docker
- Raft Storage Backend configurado em `/opt/vault/data`
- Tailscale em modo `userspace-networking` (IP xxx.xxx.xxx.xxx) para contornar conflito com cliente Windows
- Backup da instância WSL2 exportado (3.2 GB, SHA256 validado: `<REDACTED_SECRET>3B7B42350C5C376F25169279`)
- Encerrado com sucesso em 09/02/2026 (REL-PRJ007 v1.0, status SUCESSO)

**Evento Crítico (10/02/2026 — 24 horas após encerramento da Fase 1):**
Após primeiro reboot da estação de trabalho, falhas estruturais do WSL2 se manifestaram:
- Daemon Tailscale não persiste: `safesocket.Listen: /var/run/tailscale/tailscaled.sock: address already in use`
- Vault entra em estado `dead` após reinicialização: `Active: inactive (dead)`
- Raft RPC layer fecha inesperadamente: `"error":"Raft RPC layer closed"`
- Unseal manual obrigatório a cada boot

**ADR-006 — Revogação do WSL2:**
WSL2 declarado tecnicamente inadequado para workloads de infraestrutura crítica. Causa raiz: systemd parcialmente funcional, stack de rede híbrida Windows/Linux com conflitos irrecuperáveis, daemon lifecycle instável. Nenhuma IA previu essas limitações.

**Dano Colateral — Rede:**
Durante troubleshooting do WSL2, o Hyper-V Manager removeu acidentalmente o Virtual Switch `VswitchPRJ003` (limpeza automática de switches órfãos). VMs `ldap-gf-01`, `rh-gf-01`, `iga-gf-01` e `fok-ldap-01` perderam conectividade de rede. Tratado como débito técnico (DT-001 a DT-005). Documentado no ADR-006 e POP-DR-001.

**POP-LAB-002 (12/02/2026):**
Golden image `LINUX-GOLDEN-IMAGE` (GEN2) existia no laboratório mas não foi verificada antes de criar a VM do Vault em GEN1. Gap de comunicação de todas as IAs. POP-LAB-002 criado: checklist de pré-decisão arquitetural obrigatório antes de qualquer novo provisionamento de VM.

**Fase 2 — Hyper-V GEN1 (10/02/2026 — em curso):**
ADD-PRJ007-FASE2 formaliza a reabertura do projeto como nova fase. VM `VAULT-GEN1` provisionada em GEN1 por causa da CONSTRAINT-001 (UEFI corrompido impede GEN2). Vault reinstalado nativamente.

### Estado Atual do Vault (evidência coletada em 18/04/2026)

| Item | Valor |
|------|-------|
| VM | `VAULT-GEN1` (Hyper-V GEN1) |
| Hostname | `vault-gf-01` |
| OS | Ubuntu 24.04.3 LTS, kernel `6.8.0-107-generic` |
| Vault versão | 1.21.3 |
| Storage | Raft Integrated, `node_id: fiqueok-gen1-node`, path `/opt/vault/data` |
| Listener | `0.0.0.0:8200`, `tls_disable=true` |
| api_addr | `http://xxx.xxx.xxx.xxx:8200` |
| IP Tailscale | `xxx.xxx.xxx.xxx` |
| Disco | 9.8 GB total, 5.7 GB usado (61%), 3.7 GB livre |
| Cloudflare ZT | `vault.fiqueok.com.br` com OTP por e-mail (implementado 18/04/2026) |
| Audit Device | File Fail-Closed, `/opt/vault/logs/vault_audit.log` (1.8 MB em abr/2026) |
| cloudflared | `active (running)` via systemd |
| Tailscale | `active (running)` via systemd |

### Autenticação e RBAC

**Métodos de autenticação ativos:** `token/` e `userpass/`

**Usuários nominais:**
- `paulo` — política `admin-policy` (administrador)
- `rose` — política `reader-policy` (operacional)
- `daniel` — política `reader-policy` (operacional)

**Políticas RBAC ativas:**

| Política | Escopo | Uso |
|----------|--------|-----|
| `admin-policy` | `path "*" { all capabilities }` | Usuário paulo |
| `reader-policy` | Leitura de `secret/data/*` e metadata | Usuários rose e daniel |
| `api-proxy-policy` | Leitura de `secret/data/orangehrm/*` e `api-proxy/*` + renovação de token | Token svc-shadow-api (PRJ008) |
| `policy-colaborador-prj009` | Assinatura SSH + leitura `secret/data/projeto009/*` | Colaboradores PRJ009 |
| `policy-metrics` | Leitura de `/sys/metrics` | Token prometheus-scraper-prj016 (PRJ016) |

**Engines montadas:**
- `secret/` — KV v2 (secrets de aplicações: OrangeHRM, midPoint, api-proxy)
- `ssh-client-signer/` — SSH Secrets Engine com role `role-colaborador-prj009` (assinatura de chaves SSH — PRJ009)
- `auth/token/` — Token auth
- `auth/userpass/` — Userpass auth

**Tokens de serviço ativos:**

| Display name | Política | TTL | Expiração | Uso |
|-------------|----------|-----|-----------|-----|
| `token-svc-shadow-api` | `api-proxy-policy` | 720h | 2026-05-17 | PRJ008 Shadow API |
| `prometheus-scraper-prj016` | `policy-metrics` | 8760h | 2027-04 | PRJ016 Prometheus |

### GMUD-PRJ007-003 (18/04/2026) — Hardening e Governança

GMUD executada com sucesso. Snap Hyper-V criado como pré-requisito (`PRE-GMUD-PRJ007-003-20260418-1908`). Ações prospectivas executadas:

- **PRO-01:** logrotate configurado para `vault_audit.log` — mitiga risco Fail-Closed por disco cheio (DEP-001 PRJ016)
- **PRO-02:** Bloco `x_forwarded_for_*` adicionado ao `vault.hcl` — captura IP real do cliente via túnel Cloudflare nos logs de auditoria (DEP-002 PRJ016)
- **PRO-03:** Bloco `telemetry` adicionado ao `vault.hcl` — habilita endpoint `/v1/sys/metrics` para Prometheus (DEP-003 PRJ016)
- **PRO-04:** Política `policy-metrics` + token `prometheus-scraper-prj016` (TTL 8760h, chmod 600)

Vault reiniciado e unsealed após modificação do `vault.hcl`. Todos os critérios de validação V1–V7 aprovados. Nenhum rollback necessário.

### Vault.hcl atual (pós-GMUD-003)
```hcl
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "fiqueok-gen1-node"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
  x_forwarded_for_authorized_addrs     = "127.0.0.1/8"
  x_forwarded_for_hop_skips            = 0
  x_forwarded_for_reject_not_authorized = false
}

api_addr     = "http://xxx.xxx.xxx.xxx:8200"
cluster_addr = "https://127.0.0.1:8201"

ui           = true
disable_mlock = true
log_level    = "info"
log_format   = "json"

telemetry {
  prometheus_retention_time = "30s"
  disable_hostname          = true
}
```

### Riscos Abertos (TAP PRJ007 v3.0)

| ID | Risco | Status |
|----|-------|--------|
| R1 | Disco cheio → Fail-Closed → Vault para | ✅ Mitigado (GMUD-003 PRO-01 — logrotate) |
| R2 | Root token em uso ativo para acesso à UI (antipadrão crítico) | 🔴 Aberto — requer GMUD futura (PF-006) |
| R3 | Unseal manual obrigatório após cada restart | 🟡 Aceito — PF-003 backlog |
| R4 | VM em GEN1 (sem UEFI, TPM, Secure Boot) | 🟡 Aceito — PF-001 pós-CONSTRAINT |
| R5 | TLS desabilitado no listener (HTTP em vez de HTTPS) | 🟡 Aceito — mitigado por Cloudflare ZT + Tailscale E2EE |
| R6 | Warning Raft TLS `keys are pending` nos logs | 🟡 Monitorado — não afeta operação single-node |
| R8 | Token `svc-shadow-api` expira 2026-05-17 | 🔴 Urgente — verificar renovação automática em `api-gf-01` |

### Pendências Futuras (PF)

| ID | Pendência | Prioridade |
|----|-----------|-----------|
| PF-001 | Migração `VAULT-GEN1` de GEN1 para GEN2 | Média |
| PF-002 | TLS no listener do Vault | Média |
| PF-003 | Auto-unseal via Transit ou Cloud KMS | Alta |
| PF-004 | Investigação e resolução do warning Raft TLS | Média |
| PF-005 | Backup automatizado (cron Raft snapshot diário) | Alta |
| PF-006 | Revogar root token e migrar para admin user com TTL | Alta — urgente |
| PF-007 | Atualização do kernel (6.8.0-107 → 6.8.0-110) + reboot | Baixa |
| PF-008 | Confirmar renovação automática do token `svc-shadow-api` | Alta |

### Gap Documental Identificado (64 dias)
Entre 12/02/2026 (POP-DR-001 v1.1) e 18/04/2026 (GMUD-PRJ007-003), as seguintes mudanças foram implementadas sem GMUD registrada: Cloudflare ZT + OTP, criação de usuários nominais, criação de políticas RBAC, ativação do Audit Device Fail-Closed, SSH Secrets Engine, `policy-colaborador-prj009`. Formalizadas retroativamente na GMUD-003 e Lições Aprendidas v2.0.

---

## 13. Lições Aprendidas Transversais

Estas são as lições que aparecem em múltiplos projetos e têm valor universal para o laboratório e para projetos profissionais futuros.

### Sobre Plataformas e Infraestrutura

**WSL2 não é plataforma para workloads críticos** (PRJ007, validado empiricamente): systemd parcialmente funcional, stack de rede híbrida Windows/Linux com conflitos irrecuperáveis, daemon lifecycle instável ao fechar sessões. Toda IA consultada não previu essa limitação antes do evento. Regra: qualquer serviço que precise de `systemd enable` e comportamento estável entre reboots deve rodar em VM ou bare metal.

**Infraestrutura deve preceder integração** (PRJ006): IPs estáticos são pré-requisito. Subnet dedicada para laboratório evita conflitos com DHCP do host. Virtual Switches compartilhados são risco de dano colateral. SSH instável multiplica vetores de troubleshooting tornando diagnóstico científico impossível.

### Sobre Integração de Sistemas

**API-first é princípio, não sugestão** (PRJ006): JDBC direto em sistemas com camada de aplicação robusta viola encapsulamento. A API normaliza dados, aplica regras de negócio e oferece versioning. Schema de banco de terceiros tem complexidade subestimada em 10x. Correlação em midPoint requer dados normalizados.

**Race conditions em bootstrap de containers** (PRJ003): PostgreSQL precisa estar completamente inicializado antes de midPoint tentar conectar. Health check `pg_isready` com threshold obrigatório antes de subir a aplicação dependente.

### Sobre IAs como Ferramentas

IAs são catalisadores, não arquitetos de segurança. Sugestões críticas devem ser validadas contra documentação oficial do fabricante antes de implementação. Incidentes documentados: Gemini sugeriu `chmod 777` (PRJ007) e implementação insegura via Terraform/Docker; nenhuma IA previu race condition PostgreSQL/midPoint (PRJ003) nem limitações WSL2 (PRJ007); IAs produziram XMLs sintaticamente corretos mas semanticamente errados para correlação no midPoint (PRJ006).

### Sobre Documentação e Rastreabilidade

Gap de 64 dias sem GMUD no PRJ007 gerou 6 mudanças sem rastreabilidade — políticas criadas sem saber quando ou por quê. Regra: qualquer mudança em componente de produção do Living Lab (Vault, AD, cloudflared, Tailscale ACLs) requer GMUD, mesmo que simplificada.

Template de sessão obrigatório para continuidade entre sessões fragmentadas: estado inicial → objetivo da sessão → ações executadas → resultado → próximos passos. Screenshots antes/depois de cada mudança significativa.

### Sobre Decisões de Governança

Abortar projeto por razões certas é decisão de governança mais valiosa que entregar solução frágil. O PRJ006 falhou funcionalmente mas entregou conhecimento, infraestrutura saneada e decisão arquitetural estratégica documentada. "Fail fast" documenting everything é maturidade de processo.

---

## 14. Frameworks de Conformidade Adotados

O Living Lab adota cross-mapping simultâneo de cinco frameworks conforme ADR-003 do PRJ003. Um controle técnico gera evidências para múltiplos frameworks simultaneamente.

### ISO/IEC 27001:2022
Framework normativo base. Controles mais citados nos projetos:

| Controle | Implementação no Lab |
|----------|---------------------|
| A.5.1 — Políticas | DEC-ID-001 (governança de decisões) |
| A.8.3 — Privilégio Mínimo | `reader-policy` Vault, `midpoint_user` MariaDB (SELECT apenas) |
| A.8.9 — Gestão de Configuração | Scripts IaC versionados, vault.hcl documentado |
| A.8.13 — Backup | Production Checkpoints Hyper-V, Raft Snapshots |
| A.8.15 — Logging | Vault Audit Device Fail-Closed, logs estruturados JSON |
| A.8.29 — Segurança em Desenvolvimento | gestão de segredos via .env, .gitignore obrigatório |
| A.8.32 — Gestão de Mudanças | GMUDs formais com ADR, análise de causa raiz pós-falha |
| A.13.1.1 — Segregação de Redes | UFW entre VMs, Tailscale como backbone Zero Trust |

### CIS Controls v8
Foco em ações técnicas de higiene:
- Control 3 (Data Protection) — gestão de segredos, `.env` protegido, `.gitignore`
- Control 4 (Secure Configuration) — scripts IaC, hardening sudoers (whitelist de binários)
- Control 8 (Audit Log Management) — Vault audit device, logrotate com retenção 7 dias
- Control 11 (Data Recovery) — checkpoints validados, rollback < 3 minutos

### NIST CSF 2.0 (publicado fevereiro/2024)
- **GOVERN:** DEC-ID-001 — política de decisões de identidade
- **IDENTIFY:** CAN-ID-001 — inventário e definição de identidades canônicas
- **PROTECT:** gestão de segredos via Vault, baseline de configuração via IaC
- **DETECT:** logs de auditoria Vault, análise de anomalias, logrotate para continuidade
- **RESPOND:** análise de causa raiz obrigatória pós-falha, captura de logs pré-rollback
- **RECOVER:** Production Checkpoints, plano de rollback documentado em GMUDs

### NIST RMF (SP 800-37 Rev. 2)
Processo de gestão de risco em 6 etapas. Aplicado via ADRs formais antes de GMUDs técnicas. Cada ADR documenta contexto, alternativas avaliadas, decisão e consequências.

### SOC 2 (Trust Services Criteria)
Evidências de eficácia operacional via REL-GMUDs:
- CC6.1 — Confidencialidade: secrets no Vault, permissões 640/750
- CC7.3 — Monitoramento: Vault audit device, logs JSON
- CC8.1 — Gestão de Mudanças: GMUDs com aprovação e rollback documentados
- A1.2 — Disponibilidade e Backup: checkpoints Hyper-V testados com RTO < 3 min

---

## 15. Inventário de Ativos e Topologia de Rede

### VMs Ativas (estado em abr/2026)

| VM (Hyper-V) | Hostname | Função | IP Local | IP Tailscale | Status |
|-------------|----------|--------|----------|-------------|--------|
| VAULT-GEN1 | vault-gf-01 | HashiCorp Vault 1.21.3 | 172.25.25.41 | xxx.xxx.xxx.xxx | ✅ Ativo |
| rh-gf-01-local | rh-gf-01 | OrangeHRM 5.x + MariaDB | 192.168.70.11 | Ativo via mesh | ✅ Ativo |
| iga-gf-01 | iga-gf-01 | midPoint 4.10 + PostgreSQL | 192.168.70.10 | Ativo via mesh | ✅ Ativo |
| ID-P-01 | id-p-01 | AD DS (corp.fiqueok.com.br) | xxx.xxx.xxx.xxx | — | ✅ Ativo |
| ldap-gf-01 | ldap-gf-01 | OpenLDAP | — | — | ⚠️ Dependente de VSwitch |

### Serviços por VM

**vault-gf-01:**
- HashiCorp Vault 1.21.3 via systemd nativo (porta 8200)
- cloudflared via systemd (túnel para vault.fiqueok.com.br)
- Tailscale via systemd (IP fixo xxx.xxx.xxx.xxx)

**rh-gf-01:**
- OrangeHRM 5.x via Docker (porta 8085)
- MariaDB 10.x via Docker (porta 3306)
- OAuth 2.0 Confidential Client configurado

**iga-gf-01:**
- midPoint 4.10 via Docker (porta 8080)
- PostgreSQL 16 via Docker
- Bind mounts em `/srv/prj003/`

**id-p-01 (Windows Server 2022):**
- Active Directory Domain Services — domínio `corp.fiqueok.com.br`
- DNS server
- DHCP server

### Segmentos de Rede

| Segmento | Uso | Status |
|----------|-----|--------|
| 192.168.70.0/24 | VMs de laboratório IGA/RH com IPs fixos via Netplan | ✅ Ativo desde PRJ006 |
| xxx.xxx.xxx.xxx/16 | VMs legadas (AD DS) | ✅ Ativo |
| 172.25.x.x | Default Switch Hyper-V (VMs em Default Switch) | ✅ Ativo |
| Tailscale mesh | Backbone Zero Trust entre todos os nós | ✅ Ativo |
| Cloudflare ZT | Acesso externo seguro com OTP | ✅ Ativo desde abr/2026 |

### Domínio Active Directory
- **Domínio FQDN:** `corp.fiqueok.com.br`
- **DC:** ID-P-01 (xxx.xxx.xxx.xxx)
- **OUs:** estruturadas conforme GMUD-004 do PRJ002

### Golden Images / Templates
- `Win2022-GF-GEN1` — Windows Server 2022 Greenfield (GEN1) — restrita: não usar para AD DS sem cuidado especial com DCPromo
- `Win2022-GF-GEN2` — Windows Server 2022 Greenfield (GEN2) — padrão para novos servidores Windows
- `PURE-V3-GREENFIELD` — Golden Disk oficial do laboratório
- `LINUX-GOLDEN-IMAGE` — Ubuntu GEN2 com Tailscale + Docker pré-instalados (não verificada antes de criar VAULT-GEN1 — lição POP-LAB-002)
- `Ubuntu2404-GF` — Ubuntu 24.04 base

---

## 16. Governança e Gestão de Decisões

### Modelo de Artefatos

| Artefato | Propósito | Quando criar |
|----------|-----------|--------------|
| TAP | Termo de Abertura do Projeto — objetivos, escopo, riscos | Início de qualquer projeto |
| TEP/ADD | Termo de Encerramento / Adendo de Reabertura | Encerramento ou expansão de escopo |
| GMUD | Gestão de Mudança — plano de execução técnica | Antes de qualquer mudança em componente de produção |
| REL-GMUD | Relatório de execução da GMUD — evidências, resultado, rollback | Após execução, bem-sucedida ou não |
| ADR | Architecture Decision Record — contexto, alternativas, decisão, consequências | Decisão técnica ou arquitetural significativa |
| Canvas (CAN-ID, DGC) | Contratos semânticos de identidade | Antes de qualquer automação IGA |
| POP | Procedimento Operacional Padrão — operações recorrentes | Para operações repetíveis como cold start, clone de VM |
| SOP | Standard Operating Procedure — emergências | Para incidentes e resposta a falhas críticas |

### Estrutura de Pastas Obsidian (padrão por projeto)
```
PRJxxx — Nome do Projeto/
├── 00_Gestao_do_Projeto/       ← TAP, TEP, ADD
├── 10_Arquitetura_Tecnica/     ← Diagramas, C4, ARQ
├── 20_Governanca_e_Decisoes/   ← GMUDs (planejamento), ADRs, Canvases, POPs
│   └── ADRs/
├── 30_Operacao_e_Mudanca/      ← REL-GMUDs, SOP, evidências de execução
├── 40_Arquivos_Diversos/       ← Arquivo morto, versões obsoletas
│   └── 01_ARQUIVOS_MORTOS/
└── 50_Evidencias/              ← Screenshots, logs exportados, exports
```

### Regras de Decisão (DEC-ID-001)

- Decisões arquiteturais e de governança não ocorrem durante GMUDs técnicas — GMUD é executor, não decisor
- Qualquer alteração em Canvas CAN-ID ou ADR exige novo ADR formal
- Nenhuma GMUD técnica sem Production Checkpoint Hyper-V pré-criado (nomenclatura `PRE-GMUD-XXX`)
- Análise de causa raiz obrigatória após qualquer falha — documentada no REL-GMUD antes de nova tentativa
- Decisões proibidas "em voo": redefinir identificador canônico, alterar autoridade de dados por configuração, criar estados de identidade implícitos

---

## 17. Papel das IAs no Laboratório

Paulo opera com múltiplas IAs com papéis especializados e definidos desde o início do laboratório.

| IA | Papel Primário | Casos de Uso |
|----|---------------|--------------|
| **Claude** | GRC Lead / Documentador / Auditor | Documentação técnica, análise de conformidade ISO 27001, POPs, TAPs, RELs, ADRs, análise de risco |
| **ChatGPT** | Arquiteto / Executor | Scripts PowerShell/Bash, implementação técnica, troubleshooting, docker-compose, IaC |
| **Perplexity** | Inteligência / Pesquisa | Validação de versões de software, CVEs, documentação oficial de terceiros |
| **Gemini** | Análise (com ressalvas severas) | Análise de dados — excluído de decisões de segurança após incidente PRJ007 |

**Incidente de referência (PRJ007):** Gemini sugeriu `chmod 777` em diretórios críticos do Vault. Stop Work Authority aplicado imediatamente por Paulo. Gemini excluído de decisões de segurança a partir de então. Episódio documentado em relatório formal de incidente.

**Princípio consolidado:** IAs são catalisadores de produtividade, não substitutos de expertise ou fontes de autoridade em segurança. Toda configuração de segurança deve ser validada contra documentação oficial do fabricante. IA como "segunda opinião" — nunca primeira e única fonte para decisões críticas.

---

## 18. Riscos Abertos e Pendências Futuras

### Riscos de Alto Impacto (estado em abr/2026)

| Risco | Projeto | Urgência | Ação Necessária |
|-------|---------|---------|-----------------|
| Root token Vault em uso ativo (antipadrão) | PRJ007 | Alta | GMUD dedicada para revogar (PF-006) |
| Token `svc-shadow-api` expira 2026-05-17 | PRJ007/PRJ008 | Urgente | Verificar renovação automática em `api-gf-01` |
| Backup automático Vault não configurado | PRJ007 | Alta | Implementar cron Raft snapshot (PF-005) |
| Auto-unseal não implementado | PRJ007 | Alta | PF-003 — backlog PRJ008 |
| CONSTRAINT-001 (novas VMs GEN2 impossíveis) | Lab | Média | Reinstalação Windows planejada Q2/2026 |
| Vault em GEN1 (sem TPM, Secure Boot) | PRJ007 | Média | PF-001 — migração GEN2 pós-CONSTRAINT |
| TLS desabilitado no listener Vault | PRJ007 | Média | Mitigado por Cloudflare ZT + Tailscale; PF-002 |

### Projetos em Fila (baseado em referências nos documentos)

| Projeto | Descrição | Dependência |
|---------|-----------|-------------|
| PRJ008 | Shadow API REST / FastAPI — proxy de autenticação Vault | Vault estável (atendido) |
| PRJ009 | SSH Secrets Engine — assinatura de chaves para colaboradores | SSH engine já configurado no Vault |
| PRJ016 | Sentinel Identity Shield — blueprint de monitoramento com Prometheus | DEP-001/002/003 atendidas na GMUD-003 |
| PRJ017 | Cloudflare Zero Trust | ✅ Concluído (18/04/2026) |
| PRJ018 | Migração Perplexity → RAG local (222 conversas) | — |

---

## 19. Glossário Técnico do Laboratório

| Termo                     | Definição no Contexto Fiqueok                                                                                                                                                   |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **GMUD**                  | Gestão de Mudança — documento formal de planejamento e execução de mudanças técnicas; inclui escopo, rollback, critérios de sucesso                                             |
| **ADR**                   | Architecture Decision Record — registro de decisão arquitetural com contexto, alternativas avaliadas, decisão final e consequências                                             |
| **Canvas (CAN-ID)**       | Artefato de contrato semântico de identidade — gate obrigatório antes de GMUDs técnicas de IGA                                                                                  |
| **DEC-ID**                | Identity Decision Canvas — define tipos de decisão e regras de governança para mudanças de identidade                                                                           |
| **DGC**                   | Data Governance Canvas — define retenção, auditabilidade e tratamento dos dados de identidade                                                                                   |
| **Production Checkpoint** | Checkpoint Hyper-V do tipo Production (usa VSS + PostgreSQL Writer) — garante consistência de dados durante rollback                                                            |
| **Identidade Canônica**   | Representação única e imutável de uma pessoa no domínio IGA, independente de sistemas técnicos                                                                                  |
| **Fail-Closed**           | Comportamento de segurança do Vault: se o log de auditoria não puder ser gravado (disco cheio, permissão negada), o serviço para completamente para evitar operações sem rastro |
| **Stop Work Authority**   | Autoridade exercida para interromper imediatamente atividade que viola princípio de segurança, independentemente de quem a propôs                                               |
| **Marco Zero**            | Snapshot de VMs em estado saneado antes do início de novo projeto — ponto de rollback garantido                                                                                 |
| **Golden Image**          | VM template padronizado para clonagem (LINUX-GOLDEN-IMAGE, Win2022-GF)                                                                                                          |
| **Unseal**                | Processo de desbloqueio do Vault após restart, fornecendo 3 das 5 chaves Shamir para reconstruir a root key                                                                     |
| **Raft Storage**          | Backend de armazenamento integrado do Vault — sem dependência de Consul ou etcd externo, suporta HA futura                                                                      |
| **JML**                   | Joiner-Mover-Leaver — ciclo de vida de identidades (admissão, movimentação, desligamento)                                                                                       |
| **svc-shadow-api**        | Token de serviço do Vault para a Shadow API do PRJ008, política `api-proxy-policy`, TTL 720h                                                                                    |
| **corp.fiqueok.com.br**   | Domínio Active Directory do laboratório, gerenciado por ID-P-01 (xxx.xxx.xxx.xxx)                                                                                                   |
| **Tailscale MagicDNS**    | Resolução de nomes automática entre nós Tailscale (ex: `ssh paulo@vault-gf-01`)                                                                                                 |
| **CONSTRAINT-001**        | Limitação ativa desde 09/02/2026: corrupção UEFI Hyper-V impede criação de novas VMs GEN2                                                                                       |
| **Early Adopter Risk**    | Risco de usar versão nova de software (midPoint 4.10) sem suporte maduro de documentação e conectores                                                                           |
| **Cross-mapping**         | Mapeamento cruzado de um controle técnico para múltiplos frameworks (ISO 27001, CIS, NIST CSF, NIST RMF, SOC 2) simultaneamente                                                 |

---

*CONTEXTO_LivingLab_Fiqueok_v1.0.md — Documento de Referência para RAG*  
*Baseado exclusivamente em evidência primária dos vaults Obsidian exportados*  
*Cobrindo PRJ001 a PRJ007 — Dezembro/2025 a Abril/2026*  
*Paulo Feitosa — Living Lab Fiqueok*  
*Gerado com Claude Sonnet como GRC Lead*

