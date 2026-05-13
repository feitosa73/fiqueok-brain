## 📋 **TERMO DE ABERTURA DO PROJETO (TAP) - PROJ020**

---

| **Campo**             | **Valor**                                                                                |
| :-------------------- | :--------------------------------------------------------------------------------------- |
| **Código do Projeto** | PROJ020                                                                                  |
| **Nome do Projeto**   | Implementação e Operação de OpenVAS + DefectDojo para Shadow API Discovery no Living Lab |
| **Versão**            | 1.0                                                                                      |
| **Data de Criação**   | 24/04/2026                                                                               |
| **Responsável**       | Paulo Feitosa Lima — GRC Lead                                                            |
| **Patrocinador**      | Living Lab Fiqueok                                                                       |
| **Status**            | 🟡 EM INÍCIO — Ambiente Greenfield validado                                              |
| **Classificação**     | CONFIDENCIAL — Dados Técnicos e de Auditoria                                             |

---

## 1. OBJETIVOS DO PROJETO

| ID | Objetivo | Critério de Sucesso |
|----|----------|---------------------|
| OBJ-01 | Operacionalizar o OpenVAS para descoberta de Shadow APIs | Scan executado com sucesso, resultados exportáveis em XML |
| OBJ-02 | Operacionalizar o DefectDojo como central de gestão de vulnerabilidades | Importação de resultados funcionando, dashboard populado |
| OBJ-03 | Estabelecer integração entre OpenVAS e DefectDojo | Scan do OpenVAS importado e rastreável no DefectDojo |
| OBJ-04 | Executar primeiro scan focado em Shadow APIs na rede local | Shadow APIs candidatas identificadas e documentadas |
| OBJ-05 | Documentar procedimento operacional padrão para scans recorrentes | POP publicado no repositório do projeto |

---

## 2. ESCOPO

### 2.1. Dentro do Escopo

| Item | Descrição |
|------|-----------|
| OpenVAS | Utilização da instalação existente via Docker (Greenbone Community Edition) |
| DefectDojo | Utilização da instalação existente via Docker |
| Integração | Exportação manual de XML do OpenVAS → importação no DefectDojo |
| Shadow APIs | Descoberta de portas comuns de API (3000, 5000, 8000, 8080, 8443, 9000) |
| Container "vane" | Alvo de teste inicial (Node.js na porta 3000) |
| Documentação | Criação de POP para execução de scans e importação |

### 2.2. Fora do Escopo

| Item | Justificativa |
|------|---------------|
| Automação completa da integração | Será tratada em PROJ021 ou PROJ022 |
| API do DefectDojo | Poderá ser utilizada em projeto futuro |
| Scans externos (Cloudflare, Tailscale) | Escopo restrito à rede local do laboratório |
| Integração com Vault (PRJ007) | Será tratada em projeto específico posterior |
| Hardening avançado do OpenVAS | Mantida configuração padrão do container |

---

## 3. ESTADO ATUAL DO AMBIENTE (GREENFIELD VALIDADO)

### 3.1. DefectDojo

| Parâmetro | Valor | Status |
|-----------|-------|--------|
| URL | `http://localhost:8080` | ✅ Acessível |
| Credencial | admin (senha definida pelo usuário) | ✅ Conhecida |
| Version | 2.53.3 (production mode) | ✅ Ativo |
| Products | 0 | ✅ Greenfield |
| Engagements | 0 | ✅ Greenfield |
| Tests | 0 | ✅ Greenfield |
| Findings | 0 | ✅ Greenfield |
| API | Disponível (requer token gerado pelo usuário) | 🔒 Pendente geração |

**Evidência:** Dashboard com "0 findings" e limpeza confirmada no PROJ018.

### 3.2. OpenVAS (Greenbone Community Edition)

| Parâmetro | Valor | Status |
|-----------|-------|--------|
| URL | `https://localhost:9392` | ✅ Acessível |
| Credencial | admin / admin | ✅ Conhecida |
| Tasks | 0 | ✅ Greenfield |
| Targets | 0 (padrões do sistema mantidos) | ✅ Limpo |
| Reports | 0 | ✅ Limpo |
| Feed VTs | Sincronizando (170k+ VTs) | ✅ Em progresso |
| Containers | Todos Up (gsa, gvmd, ospd-openvas, redis, pg-gvm) | ✅ Operacional |

**Containers em execução:**
```
greenbone-community-edition-gsa-1        (127.0.0.1:9392->80/tcp)      ✅ Up 3 days
greenbone-community-edition-gvmd-1                                        ✅ Up 3 days
greenbone-community-edition-ospd-openvas-1                                ✅ Up 3 days
greenbone-community-edition-openvas-1                                     ✅ Up 3 days
greenbone-community-edition-openvasd-1                                    ✅ Up 3 days
greenbone-community-edition-redis-server-1                                ✅ Up 3 days
greenbone-community-edition-pg-gvm-1                                      ✅ Up 3 days
```

**Container gvm-tools:** Parado (iniciado sob demanda quando necessário)

### 3.3. Infraestrutura de Suporte

| Componente | Status |
|------------|--------|
| Hyper-V | Operacional (com CONSTRAINT-001 ativa) |
| Docker Desktop | Operacional |
| Container "vane" | Rodando em `http://localhost:3000` (potencial Shadow API) |

---

## 4. ARQUITETURA DA SOLUÇÃO

### 4.1. Fluxo de Dados (AS-IS após PROJ020)

```
┌─────────────────────────────────────────────────────────────────┐
│                         OPENVAS                                  │
│  https://localhost:9392                                          │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐          │
│  │   Target    │───→│    Task     │───→│   Report    │          │
│  │ (Shadow API)│    │ (Scan Exec) │    │   (XML)     │          │
│  └─────────────┘    └─────────────┘    └─────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Download XML
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        DEFECTDOJO                                │
│  http://localhost:8080                                           │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐          │
│  │   Product   │───→│ Engagement  │───→│    Test     │          │
│  │ (HomeLAB)   │    │ (Scan Mensal)│    │ (Import XML)│          │
│  └─────────────┘    └─────────────┘    └─────────────┘          │
│                                              │                   │
│                                              ▼                   │
│                                    ┌─────────────────┐          │
│                                    │    Findings     │          │
│                                    │ (Vulnerabilidades│          │
│                                    │  + Shadow APIs)  │          │
│                                    └─────────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2. Estrutura de Dados no DefectDojo

```
Product: "Living Lab - Segurança"
    │
    ├── Engagement: "Shadow API Discovery - Mês Ano"
    │       │
    │       ├── Test: "OpenVAS Full Scan - Rede Local"
    │       │       └── Findings: (vulnerabilidades descobertas)
    │       │
    │       └── Test: "OpenVAS API Ports - Shadow API Hunt"
    │               └── Findings: (endpoints Shadow API)
    │
    └── Engagement: "Scans Recorrentes - Mensal"
            │
            └── Test: "Scan Mês/Ano"
                    └── Findings: (evolução temporal)
```

---

## 5. CRONOGRAMA PROPOSTO

| Fase | Atividade | Período Estimado | Dependência |
|------|-----------|------------------|-------------|
| **Fase 1** | Aguardar feed sync do OpenVAS completar | 0-2 dias | Nenhuma |
| **Fase 2** | Criar estrutura no DefectDojo (Product, Engagement) | 15 min | Fase 1 |
| **Fase 3** | Configurar Target e Task no OpenVAS | 30 min | Fase 1 |
| **Fase 4** | Executar primeiro scan (rápido - apenas portas API) | 30-60 min | Fase 3 |
| **Fase 5** | Exportar XML e importar no DefectDojo | 10 min | Fase 4 |
| **Fase 6** | Analisar resultados e identificar Shadow APIs | 30-60 min | Fase 5 |
| **Fase 7** | Executar scan completo (rede local) | 2-24 horas | Fase 6 |
| **Fase 8** | Documentar POP e lições aprendidas | 2 horas | Fase 7 |

**Duração total estimada:** 2-5 dias (considerando tempos de scan e análise)

---

## 6. CONFIGURAÇÕES INICIAIS

### 6.1. DefectDojo — Configuração da Estrutura

**Product:**
```
Nome: "Living Lab - Segurança"
Descrição: "Central de vulnerabilidades e descoberta de Shadow APIs"
Prod Type: "Research and Development"
Tags: "shadow-api,vulnerability-management,homelab"
```

**Engagement (Primeiro Scan):**
```
Nome: "Shadow API Discovery - Abril 2026"
Product: "Living Lab - Segurança"
Status: "In Progress"
Target Start: 24/04/2026
Target End: 30/04/2026
Tags: "inaugural,api-discovery"
```

### 6.2. OpenVAS — Configuração dos Targets

**Target 1 — Shadow API Discovery (rápido):**
```
Nome: "Shadow API Discovery - Portas API"
Hosts: "localhost" (para teste inicial) ou "192.168.1.0/24" (rede local)
Port List: "Custom" → "T:3000,3001,5000,5001,8000,8001,8080,8081,8443,9000,30000"
Alive Test: "ICMP, TCP-ACK"
```

**Target 2 — Full Scan (completo):**
```
Nome: "Full Scan - Rede Local"
Hosts: "192.168.1.0/24" (ajustar conforme rede do usuário)
Port List: "All IANA assigned TCP"
Alive Test: "ICMP, TCP-ACK"
```

### 6.3. OpenVAS — Configuração das Tasks

**Task 1 — Scan Rápido (Shadow API):**
```
Nome: "Task - Shadow API Discovery (Rápido)"
Target: "Shadow API Discovery - Portas API"
Scan Config: "Full and fast" (ou "Discovery" para mais rápido)
Schedule: "Never"
```

**Task 2 — Scan Completo:**
```
Nome: "Task - Full Scan Rede Local"
Target: "Full Scan - Rede Local"
Scan Config: "Full and fast"
Schedule: "Never"
```

---

## 7. PROCEDIMENTO OPERACIONAL PADRÃO (POP) — PROJ020

### POP-PROJ020-001: Execução de Scan e Importação

#### 7.1. Pré-requisitos
- [ ] OpenVAS acessível em `https://localhost:9392`
- [ ] DefectDojo acessível em `http://localhost:8080`
- [ ] Credenciais conhecidas para ambos

#### 7.2. Passos para Execução de Scan no OpenVAS

1. **Acessar OpenVAS:** `https://localhost:9392` (aceitar risco do certificado SSL)
2. **Verificar Feed:** Aguardar mensagem "Feed is currently syncing" desaparecer
3. **Criar Target:** Scans → Targets → New Target
4. **Criar Task:** Scans → Tasks → New Task
5. **Executar Task:** Clique no ícone ▶️ ao lado da task
6. **Acompanhar progresso:** Scans → Tasks → Status
7. **Aguardar conclusão:** Status muda para "Done"

#### 7.3. Passos para Exportar e Importar

1. **Exportar:** Scans → Reports → Download → Formato **XML**
2. **Salvar arquivo:** `C:\scans\openvas_scan_YYYYMMDD_HHMMSS.xml`
3. **Acessar DefectDojo:** `http://localhost:8080`
4. **Navegar:** Product → Engagement → Tests → Import Scan Result
5. **Configurar importação:**
   - Scan Type: `Greenbone / OpenVAS`
   - File: Selecionar arquivo XML
   - Close Old Findings: (opcional)
6. **Importar:** Clicar em Upload

#### 7.4. Verificação de Sucesso
- [ ] Findings aparecem no dashboard do DefectDojo
- [ ] Severidades estão classificadas corretamente
- [ ] Endpoints estão listados

---

## 8. CRITÉRIOS DE CLASSIFICAÇÃO DE SHADOW APIS

| Critério | Classificação | Ação |
|----------|--------------|------|
| Porta 3000-3001 | 🟡 Potencial Shadow API (Node.js/Express) | Investigar |
| Porta 5000-5001 | 🟡 Potencial Shadow API (Python/Flask) | Investigar |
| Porta 8000-8001 | 🟡 Potencial Shadow API (Django/FastAPI) | Investigar |
| Porta 8080-8081 | 🟡 Potencial Shadow API (Java/Spring) | Investigar |
| Porta 8443 | 🟡 Potencial Shadow API (HTTPS alternativo) | Investigar |
| Container `vane` (porta 3000) | ✅ Shadow API confirmada (não documentada) | Documentar no DefectDojo |
| Endpoint com `/api`, `/v1`, `/swagger` | ✅ Shadow API confirmada | Classificar prioridade alta |
| Endpoint com documentação exposta | 🔴 Shadow API crítica + Risco alto | Prioridade máxima |

---

## 9. RISCOS E MITIGAÇÕES

| ID | Risco | Probabilidade | Impacto | Mitigação |
|----|-------|--------------|---------|-----------|
| R01 | Feed do OpenVAS não sincronizar | Baixa | Alto | Verificar conectividade; reiniciar container |
| R02 | Scan demasiadamente lento | Média | Médio | Usar Target com portas específicas; evitar Full and fast |
| R03 | Importação XML falhar no DefectDojo | Baixa | Médio | Verificar formato XML; tentar CSV como fallback |
| R04 | Certificado SSL bloquear acesso ao OpenVAS | Baixa | Baixo | Aceitar risco no navegador; usar HTTP se disponível |
| R05 | Container "vane" não estar rodando | Baixa | Baixo | Verificar com `docker ps` |
| R06 | Falta de memória durante scan | Baixa | Médio | Monitorar recursos do Docker Desktop |

---

## 10. ENTREGÁVEIS PREVISTOS

| ID | Entregável | Formato | Destino |
|----|------------|---------|---------|
| E01 | Product configurado no DefectDojo | Configuração | Living Lab |
| E02 | Engagement configurado no DefectDojo | Configuração | Living Lab |
| E03 | Targets e Tasks configurados no OpenVAS | Configuração | Living Lab |
| E04 | Primeiro scan executado e importado | XML + Findings | DefectDojo |
| E05 | Shadow APIs identificadas e documentadas | Relatório | DefectDojo |
| E06 | POP-PROJ020-001 publicado | Markdown | Repositório PROJ020 |
| E07 | TEP-PROJ020 (Termo de Encerramento) | Markdown | Repositório PROJ020 |

---

## 11. RECURSOS NECESSÁRIOS

| Recurso | Especificação | Status |
|---------|---------------|--------|
| DefectDojo | Docker, porta 8080 | ✅ Já instalado |
| OpenVAS | Docker, porta 9392 | ✅ Já instalado |
| Container "vane" | Node.js, porta 3000 | ✅ Já instalado |
| Docker Desktop | Windows | ✅ Instalado |
| Espaço em disco | ~20 GB livre | ✅ Disponível |
| Memória RAM | 8 GB alocados para Docker | ✅ Disponível |

---

## 12. REFERÊNCIAS

| Documento | Localização | Relação |
|-----------|-------------|---------|
| TEP-PRJ018-v2.0.md | `10_Projetos/PROJ018/` | Contexto de Greenfield e Camada 6 |
| CONTEXTO_LivingLab_Fiqueok_v1.0.md | Raiz do vault | Infraestrutura e projetos anteriores |
| CONSTRAINT-001 | CONTEXTO v1.0 | Limitação de VMs GEN2 |
| PRJ007 | `10_Projetos/PRJ007/` | Vault para futura integração |

---

## 13. APROVAÇÕES

| Função | Nome | Data | Status |
|--------|------|------|--------|
| GRC Lead / Responsável | Paulo Feitosa Lima | 24/04/2026 | ✅ APROVADO |
| Arquiteto de Soluções | Paulo Feitosa Lima | 24/04/2026 | ✅ APROVADO |

---

## 14. PRÓXIMOS PASSOS IMEDIATOS

| Ordem | Ação | Responsável |
|-------|------|-------------|
| 1 | Aguardar feed sync do OpenVAS completar | Paulo |
| 2 | Criar Product "Living Lab - Segurança" no DefectDojo | Paulo |
| 3 | Criar Engagement "Shadow API Discovery - Abril 2026" | Paulo |
| 4 | Configurar Target "Shadow API Discovery - Portas API" no OpenVAS | Paulo |
| 5 | Executar primeiro scan rápido no container "vane" | Paulo |
| 6 | Importar resultados no DefectDojo | Paulo |
| 7 | Documentar Shadow APIs encontradas | Paulo |

---

**FIM DO TERMO DE ABERTURA DO PROJETO — PROJ020 v1.0**

---

📄 **Documento salvo como:** `TAP-PROJ020-v1.0.md`
🔒 **Classificação:** CONFIDENCIAL
📍 **Localização:** `10_Projetos/PROJ020/00_Gestao_do_Projeto/TAP-PROJ020-v1.0.md`