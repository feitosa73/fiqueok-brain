# TERMO DE ABERTURA DO PROJETO (TAP) — PROJ020
## Implementação e Operação de OpenVAS + DefectDojo + Akto para Descoberta e Gestão de Vulnerabilidades de API

---

| Campo | Valor |
|:---|:---|
| **Código do Projeto** | PROJ020 |
| **Nome do Projeto** | Implementação e Operação de OpenVAS + DefectDojo + Akto para Descoberta e Gestão de Vulnerabilidades de API |
| **Versão** | 1.3 |
| **Data de Criação** | 24/04/2026 |
| **Data de Atualização** | 26/04/2026 |
| **Responsável** | Paulo Feitosa Lima — GRC Lead |
| **Patrocinador** | Living Lab Fiqueok |
| **Status** | 🟡 EM INÍCIO — Arquitetura aprovada, aguardando provisionamento |
| **Classificação** | CONFIDENCIAL — Dados Técnicos e de Auditoria |

---

## 1. CONTEXTO ESTRATÉGICO E JUSTIFICATIVA

O Living Lab Fiqueok construiu ao longo dos projetos PRJ001–PRJ016 uma stack de Governança de Identidades (IAM/IGA) madura, com Active Directory, midPoint 4.10, OrangeHRM e HashiCorp Vault operacionais e integrados via mesh Tailscale.

O ciclo GRC, no entanto, permanecia incompleto: o laboratório possuía governança de *quem tem acesso*, mas não tinha visibilidade sistemática sobre *o que está exposto*. O PROJ020 endereça essa lacuna ao introduzir a camada de **Gestão de Vulnerabilidades e Segurança de APIs**, fechando o loop entre identidade e superfície de ataque.

O projeto tem dois objetivos complementares:

1. **Testar a segurança da API REST do PRJ008** (`api-gf-01:8000`) — uma API documentada, com autenticação e logging, atualmente operacional e frozen por bloqueio de conector no midPoint. Nunca foi submetida a um scan formal de segurança.
2. **Descobrir serviços não inventariados na mesh Tailscale** — identificar endpoints que operam sem registro formal no inventário do laboratório, aplicando governança retroativa onde necessário.

### 1.1. Alinhamento com Frameworks de Conformidade

| Framework | Controle | Atendimento |
|-----------|----------|-------------|
| **ISO 27001:2022** | A.8.8 — Gestão de Vulnerabilidades Técnicas | Implantação de processo formal de scan e rastreamento |
| **ISO 27001:2022** | A.8.29 — Testes de Segurança em Desenvolvimento | Validação de segurança da API REST (PRJ008) |
| **NIST CSF 2.0** | ID.RA — Avaliação de Risco | Descoberta contínua de superfície de ataque |
| **CIS Controls v8** | 7 — Gestão Contínua de Vulnerabilidades | Scans recorrentes com DefectDojo como repositório central |

---

## 2. OBJETIVOS DO PROJETO

| ID | Objetivo | Critério de Sucesso |
|----|----------|---------------------|
| OBJ-01 | Implantar OpenVAS em VM dedicada para descoberta de vulnerabilidades | Scan executado com sucesso, resultados exportáveis em XML |
| OBJ-02 | Implantar DefectDojo como central de gestão de vulnerabilidades | Importação de resultados funcionando, dashboard populado |
| OBJ-03 | Implantar Akto para descoberta e teste de segurança de APIs | Endpoints da API PRJ008 identificados e testados |
| OBJ-04 | Estabelecer integração entre OpenVAS e DefectDojo | Scan do OpenVAS importado e rastreável no DefectDojo |
| OBJ-05 | Executar primeiro scan focado na API REST do PRJ008 e demais serviços Tailscale | Vulnerabilidades e serviços não inventariados documentados |
| OBJ-06 | Documentar Procedimento Operacional Padrão (POP) para scans recorrentes | POP publicado no repositório do projeto |

---

## 3. ESCOPO

### 3.1. Dentro do Escopo

| Item | Descrição |
|------|-----------|
| **VM Dedicada** | `sec-scanner-gf-01` (8 GB RAM, 4 vCPUs, 100 GB disco, GEN1) |
| **OpenVAS** | Greenbone Community Edition via Docker para scan de vulnerabilidades |
| **DefectDojo** | Community Edition via Docker para gestão centralizada de vulnerabilidades |
| **Akto** | API Security Platform via Docker para descoberta e teste de segurança de APIs |
| **Alvo primário** | API REST PRJ008 (`api-gf-01:8000`) — FastAPI documentada com autenticação `X-API-KEY` |
| **Alvos secundários** | Demais serviços acessíveis via mesh Tailscale do Living Lab |
| **Descoberta** | Identificação de serviços não inventariados na tailnet |
| **Integração** | Exportação manual de XML do OpenVAS → importação no DefectDojo |
| **Documentação** | POP para execução de scans e importação de resultados |

### 3.2. Fora do Escopo

| Item | Justificativa |
|------|---------------|
| Automação completa da integração OpenVAS → DefectDojo | Será tratada em projeto futuro (PROJ021 ou posterior) |
| Integração automática Akto → DefectDojo | Requer parser customizado — será tratada em projeto futuro |
| Scans externos (internet, Cloudflare) | Escopo restrito à mesh Tailscale do laboratório |
| Integração com HashiCorp Vault (PRJ007) | Será tratada em projeto específico posterior |
| Hardening avançado dos containers | Mantida configuração padrão para o ambiente de laboratório |
| **Projeto relacionado: PRJ016 (Sentinel Identity Shield)** | Stack Wazuh, Grafana Loki e n8n serão implantados em VM separada (`sec-sentinel-gf-01`) — fora do escopo deste TAP |

---

## 4. RESTRIÇÃO ARQUITETURAL ATIVA — CONSTRAINT-001

### 4.1. Descrição da Restrição

Desde **09/02/2026**, o Living Lab opera sob a **CONSTRAINT-001**: uma corrupção no subsistema UEFI do Hyper-V no host Windows impede a criação de novas VMs do tipo **Geração 2 (GEN2)**.

> **Importante:** A restrição afeta exclusivamente a *criação e recuperação* de VMs GEN2. As VMs GEN2 já existentes e saudáveis (ex.: `ID-P-01`, `rh-gf-01-local`, `IGA-GF-02`) permanecem operacionais sem impacto.

### 4.2. Evidência Documental

| Documento | Seção | Conteúdo Relevante |
|-----------|-------|--------------------|
| `CONTEXTO_LivingLab_Fiqueok_v1.0.md` | Seção 3 | CONSTRAINT-001 ativa desde 09/02/2026: corrupção UEFI impede criação de novas VMs GEN2 |
| `TEP-PRJ014-v1.3` | Lição L22 | A CONSTRAINT-001 afeta não apenas a criação, mas também a recuperação de VMs GEN2 existentes que falham |

### 4.3. Workaround Oficial e Decisão para o PROJ020

O workaround documentado para novas VMs é o uso de **Geração 1 (GEN1)**, já aplicado com sucesso em produção no laboratório (`api-gf-01`, `VAULT-GEN1`).

| Questão | Resposta |
|---------|----------|
| VMs GEN1 funcionam no ambiente atual? | ✅ Sim — `api-gf-01` e `VAULT-GEN1` estão em produção |
| GEN1 atende às necessidades do PROJ020? | ✅ Sim — cargas Docker (OpenVAS, DefectDojo, Akto) não requerem Secure Boot ou UEFI |
| Há plano de migração para GEN2? | ✅ Sim — prevista após reinstalação do host Windows (Q2/2026) |

**Decisão:** A VM `sec-scanner-gf-01` será criada como **GEN1**. Risco aceito e documentado.

---

## 5. ARQUITETURA APROVADA

### 5.1. Decisão Arquitetural

Após análise de múltiplas opções por equipe técnica multidisciplinar, foi aprovada a arquitetura de **duas VMs especializadas**:

- **VM1 — PROJ020 (este TAP):** `sec-scanner-gf-01` — Scanner de Vulnerabilidades + Segurança de APIs
- **VM2 — PRJ016 (projeto separado):** `sec-sentinel-gf-01` — SIEM + SOAR + Observabilidade

Este TAP trata exclusivamente da VM1.

### 5.2. Especificação da VM `sec-scanner-gf-01`

| Parâmetro | Valor | Justificativa |
|-----------|-------|---------------|
| **Hostname** | `sec-scanner-gf-01` | Padrão `sec-*-gf-01` do laboratório |
| **RAM** | 8 GB | Suficiente para OpenVAS + DefectDojo + Akto simultâneos |
| **vCPU** | 4 | Suporte a scans paralelos e processamento Akto |
| **Disco** | 100 GB | Logs, VTs do OpenVAS, reports e bancos de dados |
| **Geração** | GEN1 | Workaround oficial CONSTRAINT-001 (ver Seção 4) |
| **Sistema Operacional** | Ubuntu 24.04 LTS | Padrão de todas as VMs do laboratório |

### 5.3. Conectividade de Rede

A VM `sec-scanner-gf-01` utilizará o **Default Switch** do Hyper-V, recebendo IP dinâmico da rede do host. A comunicação com os demais ativos do laboratório será exclusivamente via **Tailscale mesh ZTNA**.

> **Nota:** O Default Switch do Hyper-V atribui IPs na faixa `172.x.x.x` via NAT interno. A comunicação entre VMs não depende dessa faixa — toda a conectividade com o laboratório ocorre via Tailscale mesh, garantindo alcance independente da configuração de IP local.

| Componente | Configuração |
|------------|-------------|
| Switch Hyper-V | Default Switch (IP dinâmico, faixa `172.x.x.x`) |
| Conectividade com o Lab | Tailscale mesh — IP atribuído automaticamente no primeiro `tailscale up` |
| Acesso ao alvo primário | `api-gf-01` via Tailscale (`xxx.xxx.xxx.xxx:8000`) |
| Acesso aos demais serviços | Via Tailscale mesh — todos os nós da tailnet |

### 5.4. Workloads da VM

| Ferramenta | Porta Local | Função |
|------------|-------------|--------|
| OpenVAS (Greenbone) | 9392 | Scanner de vulnerabilidades de rede e aplicação |
| DefectDojo | 8080, 8443 | Gestão centralizada de vulnerabilidades e findings |
| Akto | 9090 | Descoberta de APIs e testes de segurança (autenticação, autorização, headers) |

### 5.5. Fluxo de Dados

```
┌──────────────────────────────────────────────────────────────────┐
│                  sec-scanner-gf-01 (PROJ020)                     │
│                                                                  │
│  ┌─────────────┐    XML (manual)   ┌──────────────┐             │
│  │   OpenVAS   │─────────────────→│  DefectDojo  │             │
│  │   (:9392)   │                   │ (:8080/8443) │             │
│  └─────────────┘                   └──────────────┘             │
│                                          ↑                       │
│  ┌─────────────┐  report manual          │                       │
│  │    Akto     │─────────────────────────┘                       │
│  │   (:9090)   │                                                  │
│  └─────────────┘                                                  │
│         │                                                         │
│         │ via Tailscale mesh                                      │
└─────────┼─────────────────────────────────────────────────────────┘
          │
          ▼ Tailscale
┌─────────────────────────────────────────────────────────────────┐
│                    ALVOS DE SCAN                                 │
│                                                                  │
│  api-gf-01 (xxx.xxx.xxx.xxx)                                    │
│  └── :8000  FastAPI REST — PRJ008 [ALVO PRIMÁRIO]               │
│  └── /employees  GET com X-API-KEY                              │
│  └── /docs       Swagger UI                                     │
│                                                                  │
│  Demais nós da tailnet (alvos secundários elegíveis)            │
│  ├── vault-gf-01    (xxx.xxx.xxx.xxx)                              │
│  ├── rh-gf-01-local (xxx.xxx.xxx.xxx)                              │
│  └── iga-gf-02      (xxx.xxx.xxx.xxx)                             │
└─────────────────────────────────────────────────────────────────┘
```

> **Nota:** A integração Akto → DefectDojo é **manual** — exportação do relatório Akto (JSON/CSV) seguida de registro manual dos findings no DefectDojo. A automação desta integração está fora do escopo deste TAP e poderá ser tratada em projeto futuro.

---

## 6. ALVO PRIMÁRIO — API REST PRJ008

### 6.1. Contexto da API

O PRJ008 desenvolveu uma API REST em FastAPI (`api-gf-01:8000`) que expõe dados de funcionários do OrangeHRM. A API está operacional desde abril/2026 e foi congelada (FROZEN) por bloqueio de conector no midPoint 4.10/Java 21 — não por falha da API em si.

> **Nota de Nomenclatura:** O PRJ008 adotou o nome "Shadow API" por razões históricas de projeto. No contexto do PROJ020, essa API é tratada como um **serviço documentado e conhecido** — com Swagger, autenticação e logging formais — que será submetido a um teste de segurança formal pela primeira vez.

| Característica | Detalhe |
|----------------|---------|
| **Tecnologia** | FastAPI + Uvicorn, Python 3.12 |
| **Endpoint principal** | `GET /employees` — retorna array JSON com dados de funcionários |
| **Autenticação** | Header `X-API-KEY: Fiqueok-Security-Token-2026` |
| **Documentação** | Swagger UI em `/docs` |
| **Segredos** | Credenciais via HashiCorp Vault (`secret/orangehrm/db_api`) |
| **Logging** | Middleware ISO 27001 A.8.15 implementado |
| **Status atual** | ✅ Operacional — frozen aguardando retomada do PRJ008 |

### 6.2. Justificativa do Scan

A API nunca foi submetida a um processo formal de teste de segurança. O PROJ020 realizará a primeira avaliação sistemática, cobrindo:

- Exposição indevida de endpoints
- Falhas de autenticação e autorização
- Dados sensíveis (PII) em responses
- Configurações inseguras de headers HTTP
- Vulnerabilidades conhecidas no runtime FastAPI/Uvicorn

---

## 7. CONFIGURAÇÕES INICIAIS

### 7.1. DefectDojo — Estrutura Inicial

**Product:**
```
Nome:        "Living Lab — Segurança"
Descrição:   "Central de vulnerabilidades e gestão de segurança de APIs do Living Lab Fiqueok"
Prod Type:   "Research and Development"
Tags:        "api-security, vulnerability-management, homelab"
```

**Engagement (Primeiro Scan):**
```
Nome:         "API Security Assessment — PRJ008 — Abril 2026"
Product:      "Living Lab — Segurança"
Status:       "In Progress"
Target Start: 26/04/2026
Target End:   30/04/2026
Tags:         "inaugural, api-security, prj008"
```

### 7.2. OpenVAS — Targets e Tasks

**Target 1 — API REST PRJ008:**
```
Nome:       "API REST PRJ008 — api-gf-01"
Hosts:      xxx.xxx.xxx.xxx
Port List:  Custom → T:8000
Alive Test: TCP-ACK Service Detection
```

**Target 2 — Tailscale Mesh (varredura ampla):**
```
Nome:       "Tailscale Mesh — Living Lab"
Hosts:      xxx.xxx.xxx.xxx, xxx.xxx.xxx.xxx, xxx.xxx.xxx.xxx,
            xxx.xxx.xxx.xxx, xxx.xxx.xxx.xxx
Port List:  All IANA assigned TCP
Alive Test: ICMP, TCP-ACK
```

**Task 1 — Scan Focado na API:**
```
Nome:        "Task — API REST PRJ008 (Rápido)"
Target:      "API REST PRJ008 — api-gf-01"
Scan Config: "Full and fast"
Schedule:    "Never" (execução manual)
```

### 7.3. Akto — Configuração Inicial

```
Dashboard:      http://<IP-Tailscale-VM>:9090
Primeiro acesso: Definir usuário admin e senha
```

**Configuração de alvo:**
```
Alvo:            http://xxx.xxx.xxx.xxx:8000
API Key Header:  X-API-KEY: Fiqueok-Security-Token-2026
Endpoints:       /employees, /docs, /openapi.json
```

---

## 8. PROCEDIMENTO OPERACIONAL PADRÃO — POP-PROJ020-001

### 8.1. Pré-requisitos

- [ ] VM `sec-scanner-gf-01` em execução
- [ ] Tailscale ativo e `api-gf-01` acessível (`tailscale ping xxx.xxx.xxx.xxx`)
- [ ] OpenVAS acessível em `https://<IP-Tailscale-VM>:9392`
- [ ] DefectDojo acessível em `http://<IP-Tailscale-VM>:8080`
- [ ] Akto acessível em `http://<IP-Tailscale-VM>:9090`
- [ ] Product e Engagement criados no DefectDojo

### 8.2. Execução de Scan no OpenVAS

1. Acessar OpenVAS: `https://<IP-Tailscale-VM>:9392`
2. Verificar Feed VTs sincronizado (aguardar se necessário)
3. Scans → Tasks → selecionar Task → **Start**
4. Aguardar status `Done`
5. Scans → Reports → selecionar report → **Download → XML**

### 8.3. Importação no DefectDojo

1. Acessar DefectDojo: `http://<IP-Tailscale-VM>:8080`
2. Navegar até: Product → Engagement → **Import Scan Results**
3. Scan Type: `Greenbone / OpenVAS XML`
4. Upload do arquivo XML exportado
5. Verificar findings importados no dashboard

### 8.4. Execução do Scan Akto e Registro de Findings

1. Acessar Akto: `http://<IP-Tailscale-VM>:9090`
2. Configurar alvo: `http://xxx.xxx.xxx.xxx:8000`
3. Executar descoberta de endpoints
4. Executar testes de segurança (autenticação, autorização, headers)
5. Exportar relatório do Akto (formato JSON ou CSV)
6. Analisar manualmente os achados do Akto
7. Registrar findings relevantes manualmente no DefectDojo (Product → Engagement → Add Finding)

> **Nota:** O Akto não exporta em formato nativamente importável pelo DefectDojo. O registro de findings é realizado manualmente. A automação desta etapa está fora do escopo deste TAP.

### 8.5. Critérios de Sucesso por Ciclo

- [ ] Findings do OpenVAS visíveis no dashboard do DefectDojo
- [ ] Severidades classificadas (Critical, High, Medium, Low, Info)
- [ ] Endpoints da API PRJ008 listados e testados no Akto
- [ ] Findings relevantes do Akto registrados manualmente no DefectDojo
- [ ] Nenhum finding Critical sem plano de tratamento documentado

---

## 9. CRITÉRIOS DE CLASSIFICAÇÃO — VULNERABILIDADES E SERVIÇOS ÓRFÃOS

### 9.1. Critérios de Vulnerabilidades de API

| Critério | Classificação | Ação |
|----------|--------------|------|
| Endpoint exposto sem autenticação | 🔴 Critical | Abertura de RNC imediata |
| Falha de autorização — acesso a recursos de outro contexto | 🔴 Critical | Abertura de RNC imediata |
| Dados sensíveis (PII) em response sem criptografia | 🔴 High | RNC em 24h |
| Swagger/OpenAPI exposto sem controle de acesso | 🟠 High | RNC em 24h |
| Headers de segurança ausentes (CORS, CSP, HSTS) | 🟡 Medium | RNC em 7 dias |
| Versão de runtime desatualizada (FastAPI, Uvicorn) | 🟡 Medium | RNC em 7 dias |
| Informações de debug expostas em response | 🟡 Medium | RNC em 7 dias |
| Endpoint legado ou residual detectado | 🔵 Low | Documentar e investigar |

### 9.2. Critérios para Serviços Não Inventariados na Tailnet

O Akto será utilizado para descobrir **serviços de API não previamente inventariados** na mesh Tailscale — ou seja, endpoints que operam sem registro formal no inventário do laboratório.

| Critério | Classificação | Ação |
|----------|--------------|------|
| Serviço detectado pelo Akto não listado no inventário do lab | 🟡 Serviço Órfão | Registrar no inventário; investigar proprietário |
| Serviço sem documentação (sem Swagger/OpenAPI) | 🟠 Prioridade Média | Documentar retrospectivamente |
| Serviço com autenticação fraca ou ausente | 🔴 Prioridade Alta | RNC imediata |
| Serviço em porta não registrada no inventário | 🟡 Serviço Órfão Potencial | Investigar origem e registrar |

> **Nota:** O objetivo desta subseção é **descobrir e inventariar** — não há expectativa de eliminação de serviços, mas sim de registro formal e aplicação de governança onde necessário.

---

## 10. RISCOS E MITIGAÇÕES

| ID | Risco | Probabilidade | Impacto | Mitigação |
|----|-------|--------------|---------|-----------|
| R01 | Feed VTs do OpenVAS não sincronizar | Baixa | Alto | Verificar conectividade externa; reiniciar container `gvmd` |
| R02 | Scan OpenVAS demorar excessivamente | Média | Médio | Usar Target com porta específica (:8000) para o alvo primário |
| R03 | Importação XML falhar no DefectDojo | Baixa | Médio | Verificar formato XML; tentar importação via API REST do DefectDojo |
| R04 | CONSTRAINT-001 — impossibilidade de GEN2 | Alta | Baixo | VM GEN1 definida como workaround oficial (ver Seção 4) |
| R05 | Akto não descobrir endpoints da API | Média | Médio | Alimentar manualmente com `/openapi.json` da API PRJ008 |
| R06 | Pressão de memória durante scan simultâneo | Baixa | Médio | Escalonar execução: OpenVAS e Akto não simultaneamente |
| R07 | API PRJ008 indisponível durante scan | Baixa | Médio | Verificar `tailscale ping xxx.xxx.xxx.xxx` antes de iniciar |

---

## 11. ENTREGÁVEIS PREVISTOS

| ID | Entregável | Formato | Destino |
|----|------------|---------|---------|
| E01 | VM `sec-scanner-gf-01` provisionada e documentada | VM + notas | Hyper-V / Obsidian |
| E02 | Product e Engagement configurados no DefectDojo | Configuração | Living Lab |
| E03 | Targets e Tasks configurados no OpenVAS | Configuração | Living Lab |
| E04 | Akto configurado com alvo PRJ008 | Configuração | Living Lab |
| E05 | Primeiro scan executado e importado no DefectDojo | XML + Findings | DefectDojo |
| E06 | Relatório de vulnerabilidades da API PRJ008 | Markdown | Obsidian / PROJ020 |
| E07 | Inventário de serviços descobertos na tailnet | Markdown | Obsidian / PROJ020 |
| E08 | POP-PROJ020-001 publicado | Markdown | Repositório PROJ020 |
| E09 | TEP-PROJ020 (Termo de Encerramento) | Markdown | Repositório PROJ020 |

---

## 12. RECURSOS NECESSÁRIOS

| Recurso | Especificação | Status |
|---------|---------------|--------|
| Hyper-V | Windows 10 Pro — CONSTRAINT-001 ativa | ✅ Disponível |
| VM `sec-scanner-gf-01` | 8 GB RAM, 4 vCPUs, 100 GB disco, GEN1 | ⬜ A criar |
| Ubuntu 24.04 LTS | ISO | ✅ Disponível |
| Docker + Compose | Versão atual estável | ⬜ A instalar na VM |
| Tailscale | Última versão estável | ⬜ A instalar na VM |
| Espaço em disco do host | 100 GB | ✅ Disponível |
| RAM do host | 8 GB adicionais (45 GB disponíveis no host) | ✅ Disponível |

---

## 13. CRONOGRAMA ESTIMADO

| Fase | Atividade | Duração Estimada |
|------|-----------|-----------------|
| **Fase 1** | Criar VM `sec-scanner-gf-01` no Hyper-V (GEN1, 8 GB, 4 vCPUs, 100 GB) | 30 min |
| **Fase 2** | Instalar Ubuntu 24.04 LTS | 20 min |
| **Fase 3** | Provisionamento base: Docker, Compose, Tailscale, UFW | 20 min |
| **Fase 4** | Instalar e configurar OpenVAS via Docker (aguardar sync do feed VTs) | 30 min + sync |
| **Fase 5** | Instalar e configurar DefectDojo via Docker | 20 min |
| **Fase 6** | Instalar e configurar Akto via Docker | 20 min |
| **Fase 7** | Criar Product/Engagement no DefectDojo; configurar Targets/Tasks no OpenVAS; configurar alvo PRJ008 no Akto | 30 min |
| **Fase 8** | Executar primeiro scan (API PRJ008 + tailnet) | 1–2 horas |
| **Fase 9** | Importar findings OpenVAS no DefectDojo; analisar e registrar findings Akto manualmente | 1–2 horas |
| **Fase 10** | Documentar findings, abrir RNCs conforme POP-GRC-001, publicar inventário de serviços | 1 hora |
| **Fase 11** | Publicar POP-PROJ020-001 | 1 hora |

**Duração total estimada:** 2 dias (incluindo sincronização do feed VTs do OpenVAS)

---

## 14. REFERÊNCIAS

| Documento | Relação com este TAP |
|-----------|----------------------|
| `TEP-PRJ008-v1.0-FREEZING.md` | Define o alvo primário do PROJ020: a API REST `api-gf-01:8000`, operacional e frozen por bloqueio de conector midPoint 4.10/Java 21. Contexto completo da API e do freeze na Seção 3 do TEP |
| `CONTEXTO_LivingLab_Fiqueok_v1.0.md` | Documenta a CONSTRAINT-001 (corrupção UEFI Hyper-V) e o workaround GEN1 — base da decisão arquitetural da Seção 4 deste TAP |
| `TEP-PRJ014-v1.3` (Lição L22) | Confirma que a CONSTRAINT-001 afeta criação e recuperação de VMs GEN2 — fundamenta o uso de GEN1 para novas VMs |
| `PRJ016-Blueprint` | Projeto relacionado (Sentinel Identity Shield): Wazuh, Loki e n8n em VM separada (`sec-sentinel-gf-01`) — fora do escopo deste TAP |
| `POP-GRC-001 — Fluxo de Gestão de Vulnerabilidades` | Processo de triagem, classificação e SLA de vulnerabilidades aplicável aos findings gerados pelo PROJ020 |

---

## 15. PRÓXIMOS PASSOS IMEDIATOS

| Ordem | Ação | Responsável |
|-------|------|-------------|
| 1 | Criar VM `sec-scanner-gf-01` no Hyper-V (GEN1, 8 GB, 4 vCPUs, 100 GB) | Paulo |
| 2 | Instalar Ubuntu 24.04 LTS | Paulo |
| 3 | Provisionar base: Docker, Compose, Tailscale, UFW | Paulo |
| 4 | Instalar OpenVAS via Docker e aguardar sync do feed VTs | Paulo |
| 5 | Instalar DefectDojo via Docker | Paulo |
| 6 | Instalar Akto via Docker | Paulo |
| 7 | Criar Product e Engagement no DefectDojo | Paulo |
| 8 | Configurar Targets e Tasks no OpenVAS | Paulo |
| 9 | Configurar alvo PRJ008 no Akto | Paulo |
| 10 | Executar primeiro scan e importar findings OpenVAS no DefectDojo | Paulo |
| 11 | Analisar findings Akto e registrar manualmente no DefectDojo | Paulo |
| 12 | Abrir RNCs conforme POP-GRC-001 para findings críticos | Paulo |
| 13 | Publicar inventário de serviços descobertos na tailnet | Paulo |
| 14 | Publicar POP-PROJ020-001 | Paulo |

---

## 16. APROVAÇÕES

| Função | Nome | Data | Status |
|--------|------|------|--------|
| GRC Lead / Responsável | Paulo Feitosa Lima | 26/04/2026 | ✅ APROVADO |
| Arquiteto de Soluções | Paulo Feitosa Lima | 26/04/2026 | ✅ APROVADO |

---

**FIM DO TERMO DE ABERTURA DO PROJETO — PROJ020 v1.3**

---

> 📄 **Documento:** `TAP-PROJ020-v1.3.md`
> 🔒 **Classificação:** CONFIDENCIAL
> 📍 **Localização sugerida:** `10_Projetos/PROJ020/00_Gestao_do_Projeto/TAP-PROJ020-v1.3.md`
> ✍️ **Redigido com apoio de Claude (Anthropic) — Living Lab Fiqueok**

