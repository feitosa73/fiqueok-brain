# TAP-PRJ003 — Termo de Abertura de Projeto
## IGA Greenfield Reference Architecture

---

| Campo | Valor |
|---|---|
| **Código do Projeto** | PRJ003 |
| **Nome** | IGA Greenfield Reference Architecture |
| **Contexto** | Living Lab Fiqueok 2.0 |
| **Tipo** | Projeto Estruturante + Implantação Técnica |
| **Owner** | Paulo Feitosa |
| **Data de Abertura** | 2026-01-14 |
| **Data Prevista de Encerramento** | 2026-01-25 |
| **Status** | Aprovado para Execução |

---

## 1. Objetivo do Projeto

O PRJ003 tem como objetivo **estruturar, consolidar e implantar o ambiente IGA (Identity Governance and Administration) do Living Lab Fiqueok 2.0**, garantindo que:

- As decisões de identidade sejam **conscientes, rastreáveis e reproduzíveis**
- O ambiente possa ser **reconstruído do zero (cold start)** sem perda de coerência
- A plataforma IGA (midPoint) opere de forma estável sobre repositório nativo PostgreSQL
- Toda decisão arquitetural seja formalizada antes da execução técnica

Este projeto é composto por duas camadas complementares:
1. **Camada de Governança**: estabelecimento de princípios, canvases de identidade e ADRs
2. **Camada Técnica**: implantação do midPoint + PostgreSQL em ambiente Docker containerizado

---

## 2. Escopo

### 2.1 Dentro do Escopo

- Definição de princípios arquiteturais de identidade (identidade canônica, autoridade de dados, estados)
- Criação de artefatos de decisão: CAN-ID-001, CAN-ID-002, CAN-ID-003, DEC-ID-001, DGC-001
- Arquitetura lógica e diagrama C4 — Contexto
- ADRs de persistência, reversibilidade e estratégia de configuração
- Provisionamento de VM dedicada (IGA-GF-01) com Ubuntu Server 24.04 LTS
- Instalação e configuração de Docker Engine e Docker Compose Plugin
- Deploy de midPoint + PostgreSQL via Docker Compose com volumes persistentes
- Script de automação (IaC) em PowerShell para deploy idempotente host → VM
- Validação de acesso ao midPoint via interface web com usuário `administrator`
- POPs operacionais: Cold Start, reset de volumes, rollback via checkpoint Hyper-V

### 2.2 Fora do Escopo

- Configuração de conectores de recursos externos (LDAP, AD, REST)
- Importação de populações de identidade (usuários reais)
- Automação avançada de ciclo de vida (JML)
- Performance tuning para escala
- Integração com fontes autorizativas de negócio

---

## 3. Arquitetura de Referência

```
┌─────────────────────────────────────────────────────────────────┐
│                  HOST WINDOWS (Orquestrador)                    │
│  PowerShell 7   ──SSH──►   VM: IGA-GF-01                        │
│  xxx.xxx.xxx.xxx              xxx.xxx.xxx.xxx                        │
└─────────────────────────────────────────────────────────────────┘
                                 │
                    Ubuntu Server 24.04 LTS
                    Docker Engine 29.x
                    Docker Compose Plugin
                                 │
                ┌────────────────┴────────────────┐
                │         iga-network (bridge)    │
                │                                 │
        ┌───────┴──────┐               ┌──────────┴──────┐
        │  PostgreSQL  │               │    midPoint     │
        │  16-alpine   │◄─────JDBC─────│   (evolveum)    │
        │  port: 5432  │               │   port: 8080    │
        │  volume:     │               │   volume:       │
        │  /srv/prj003 │               │  /opt/midpoint  │
        │  /data/pg    │               │   /var          │
        └──────────────┘               └─────────────────┘
                │                              │
         Persistência                   Acesso Web
         SCRAM-SHA-256              http://xxx.xxx.xxx.xxx:8080
```

**Componentes:**

| Componente | Versão | Papel |
|---|---|---|
| Ubuntu Server | 24.04 LTS | Sistema operacional da VM |
| Docker Engine | 29.x | Runtime de containers |
| PostgreSQL | 16-alpine | Repositório de dados do midPoint |
| midPoint | 4.8 → 4.10 | Plataforma IGA |
| PowerShell | 7.x | Orquestração de deploy via SSH |

---

## 4. Infraestrutura Planejada

| Recurso | Especificação |
|---|---|
| **VM** | IGA-GF-01 (Hyper-V, GEN2) |
| **IP** | xxx.xxx.xxx.xxx (estático) |
| **OS** | Ubuntu Server 24.04 LTS |
| **RAM** | 2 GB |
| **Storage** | 40 GB |
| **Rede** | Switch virtual externo (Hyper-V) |
| **Acesso remoto** | SSH (chave pública) |
| **Volumes** | `/srv/prj003/data/postgres`, `/srv/prj003/data/midpoint/var` |
| **Checkpoint** | PRE-GMUD-005 (pós Cold Start) |

---

## 5. GMUDs Previstas

| GMUD | Título | Tipo | Dependência |
|---|---|---|---|
| GMUD-001 | Estruturação Inicial do Projeto PRJ003 | Governança | — |
| GMUD-002 | Consolidação dos Canvases de Decisão de Identidade | Governança | GMUD-001 |
| GMUD-003 | Consolidação da Arquitetura Lógica de Identidade | Governança | GMUD-002 |
| GMUD-004 | Cold Start da Infraestrutura IAM | Infraestrutura | GMUD-003 |
| GMUD-005 | Deploy Inicial midPoint + PostgreSQL | Infraestrutura | GMUD-004 |
| GMUD-006 | Deploy com Orquestração de Bootstrap | Infraestrutura | GMUD-005 |
| GMUD-007 | Deploy Manual Passo-a-Passo | Infraestrutura | GMUD-006 |
| GMUD-008 | Deploy Automatizado via IaC (PowerShell) | IaC | GMUD-007 |
| GMUD-009 | Deploy Técnico com Análise de Causa Raiz | Infraestrutura | GMUD-008 |
| GMUD-010 | Orquestração e Deploy Automatizado (Ciclo Final 4.8) | IaC | GMUD-009 |
| GMUD-011 | Deploy midPoint 4.9 — Avaliação de Versão | Infraestrutura | GMUD-010 |
| GMUD-012 | Deploy midPoint 4.10 com Soberania de Dados | Infraestrutura | GMUD-011 |

---

## 6. Critérios de Sucesso

| # | Critério | Verificação |
|---|---|---|
| CS-01 | Artefatos de decisão de identidade formalizados (CAN-ID, DEC-ID, DGC) | Presença e consistência dos documentos |
| CS-02 | VM IGA-GF-01 provisionada com Docker operacional | `docker ps` sem erros |
| CS-03 | midPoint acessível em `http://xxx.xxx.xxx.xxx:8080` | HTTP 200 na interface web |
| CS-04 | Login com usuário `administrator` funcional | Autenticação bem-sucedida |
| CS-05 | PostgreSQL operando como repositório nativo (sem fallback H2) | Log confirma `database: postgresql` |
| CS-06 | Ambiente reconstruível do zero via documentação | Execução bem-sucedida de cold start |
| CS-07 | Script de deploy idempotente (mesmo resultado em execuções repetidas) | Duas rodadas consecutivas com sucesso |

---

## 7. Riscos Identificados

| # | Risco | Probabilidade | Impacto | Mitigação |
|---|---|---|---|---|
| R-01 | Incompatibilidade entre versão de midPoint e PostgreSQL 16 SCRAM-SHA-256 | Média | Alto | Validar documentação oficial antes de cada deploy |
| R-02 | Fallback silencioso do midPoint para banco H2 | Média | Alto | Verificar logs de inicialização antes de validar acesso web |
| R-03 | Volumes Docker com estado residual corrompido (envenenamento) | Alta | Médio | Limpeza nuclear (`rm -rf data/*`) antes de cada tentativa |
| R-04 | Race condition no bootstrap (midPoint sobe antes do PostgreSQL estar saudável) | Alta | Alto | Healthcheck explícito no PostgreSQL com `depends_on: condition: service_healthy` |
| R-05 | Perda de conectividade de rede da VM após rollback via checkpoint Hyper-V | Média | Alto | Validar rede como primeiro passo pós-restauração |
| R-06 | Credenciais com caracteres especiais quebrando injeção via `sed` no entrypoint | Média | Alto | Usar senhas alfanuméricas ou injeção via URL JDBC |
| R-07 | Conflito entre variáveis legadas (`REPO_*`) e modernas (`MP_SET_*`) da imagem Docker | Baixa | Alto | Escolher e documentar um único padrão de configuração |

---

## 8. Premissas

1. O ambiente Hyper-V no host Windows está funcional e com switch virtual externo configurado
2. A VM IGA-GF-01 tem acesso à internet para baixar imagens Docker do hub.docker.com
3. O usuário `paulo` na VM tem configuração `NOPASSWD` no sudoers para execução via SSH automatizado
4. As credenciais de acesso à VM são gerenciadas via arquivo `.env` local (nunca commitadas)
5. O midPoint utilizado é a versão disponível publicamente em `evolveum/midpoint:<tag>` no Docker Hub
6. Checkpoints Hyper-V são criados antes de cada GMUD técnica relevante
7. A documentação do projeto é mantida no Obsidian com versionamento por pasta (`_ATIVOS` / `_ARQUIVO-MORTO`)

---

## 9. Princípios Arquiteturais

1. **Decisão antes da automação** — nenhuma GMUD técnica começa sem artefatos de governança validados
2. **Identidade canônica explícita** — a definição de identidade é formalizada em CAN-ID-001 antes de qualquer integração
3. **Idempotência como regra** — scripts devem produzir o mesmo resultado independentemente do número de execuções
4. **Blast radius controlado** — rollbacks são previstos e testados antes de GMUDs críticas
5. **Documentação como parte do sistema** — REL-GMUDs e lições aprendidas são obrigatórios

---

## 10. Aprovação de Abertura

| Papel | Nome | Data | Status |
|---|---|---|---|
| Owner do Projeto | Paulo Feitosa | 2026-01-14 | ✅ Aprovado |
| GRC Lead | Paulo Feitosa | 2026-01-14 | ✅ Aprovado |

---

*TAP-PRJ003 v1.0 — Living Lab Fiqueok 2.0*

