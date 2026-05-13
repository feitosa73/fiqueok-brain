
# TERMO DE ABERTURA DO PROJETO (TAP) — PROJ020 v1.4
## Implementação de DefectDojo + OpenVAS para Descoberta e Gestão de Vulnerabilidades de API (Arquitetura Revisada)

---

| Campo | Valor |
|:---|:---|
| **Código do Projeto** | PROJ020 |
| **Nome do Projeto** | Implementação de DefectDojo + OpenVAS para Descoberta e Gestão de Vulnerabilidades de API |
| **Versão** | 1.4 |
| **Data de Criação** | 24/04/2026 |
| **Data de Atualização** | 27/04/2026 |
| **Responsável** | Paulo Feitosa Lima — GRC Lead |
| **Patrocinador** | Living Lab Fiqueok |
| **Status** | 🟢 EM EXECUÇÃO — Fase A concluída, aguardando Fase B |
| **Classificação** | CONFIDENCIAL — Dados Técnicos e de Auditoria |

---

## 1. HISTÓRICO DE VERSÕES E MUDANÇA DE ESTRATÉGIA

| Versão | Data | Mudança | Justificativa |
|--------|------|---------|----------------|
| v1.0 | 24/04/2026 | Criação inicial | Arquitetura de três ferramentas em uma VM (OpenVAS + DefectDojo + Akto) |
| v1.1 | 25/04/2026 | Ajustes de configuração | Correções no docker-compose do Akto |
| v1.2 | 26/04/2026 | Identificação de falhas | Akto em loop com erro `-Xmx0m` e `free: command not found` |
| v1.3 | 26/04/2026 | Tentativa de correção com Kafka+ZK | Imagem `:0.5.5` não encontrada; stack não sobe |
| v1.4 | 27/04/2026 | **Revisão arquitetural completa** | **Motivo: FROZEN do Akto + decisão de separar VMs** |

### 1.1. Motivação Detalhada da Mudança para v1.4

#### 🔴 Evidências de Falha do Akto (extraídas do `Evidencias PRJ020 b.txt`)

| Tentativa | Problema | Status |
|-----------|----------|--------|
| 1 | `Calculated -Xmx value: 0 MB` + `Invalid maximum heap size: -Xmx0m` + `free: command not found` | Container em loop reiniciando |
| 2 | `JAVA_OPTS=-Xmx512m -Xms256m` definido manualmente | Sobe, mas `curl: (56) Recv failure: Connection reset by peer` |
| 3 | Inclusão de Kafka + Zookeeper com `JAVA_OPTS=-Xmx1024m -Xms512m` | Container reinicia; porta 9090 escutando mas `curl` falha |
| 4 | Stack completa com `confluentinc/cp-kafka` | Imagem `aktosecurity/akto-api-security-dashboard:0.5.5` não encontrada |
| 5 | Limpeza total e reinstalação | Akto sequer sobe |

#### 🟡 Limitação de Recursos Identificada

```
free -h (após limpeza)
Mem:  3.8Gi   1.3Gi   1.7Gi   57Mi   1.2Gi   2.5Gi
Swap: 4.0Gi    19Mi   4.0Gi
```

- A VM com 4 GB RAM (após redução) não comportaria simultaneamente:
  - DefectDojo (Docker) — ~2 GB
  - OpenVAS (Docker) — ~2 GB
  - Akto (Docker com Kafka+ZK) — ~2 GB
- **Decisão estratégica:** especializar VMs por função em vez de sobrecarregar uma única.

#### ✅ Decisão Final (documentada ao final do `Contexto Desafio Akto.txt`)

> *"Vamos fazer duas coisas importantes. Primeiro deixar a VM sec-scanner-gf-01 limpa, apenas com o que precisa para o DefectDojo funcionar. Avaliar se é preciso realmente rodar ela em cima de Docker já que estamos falando que essa maquina sera exclusiva para o DefectDojo (talvez avaliar necessidade de alterar a nomenclatura). Reduzir a memoria dessa maquina que esta em 8GB para o minimo suficiente para que ela funcione. Depois partimos para a Openvas."*

**Tradução operacional:**
- ✅ **Fase A (concluída):** VM exclusiva para DefectDojo (`defectdojo-gf-01`)
- ✅ **Fase B (pendente):** Nova VM dedicada para OpenVAS (`sec-openvas-gf-01`)
- ❌ **Akto removido do escopo** (poderá ser reavaliado em projeto futuro)

---

## 2. ARQUITETURA FINAL APROVADA (v1.4)

### 2.1. Estratégia de Duas VMs Especializadas

```
┌─────────────────────────────────────────────────────────────────────┐
│                    FASE A (CONCLUÍDA)                                │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  VM: defectdojo-gf-01 (ex-sec-scanner-gf-01)                 │  │
│  │  RAM: 4 GB (reduzido de 8 GB)                                 │  │
│  │  Tailscale IP: xxx.xxx.xxx.xxx                                   │  │
│  │  Função: Gestão centralizada de vulnerabilidades              │  │
│  │  ┌─────────────────────────────────────────────────────────┐  │  │
│  │  │  DefectDojo (Docker)                                     │  │  │
│  │  │  Portas: 8080 (HTTP), 8443 (HTTPS)                       │  │  │
│  │  │  Admin password: K6hiVpTKlkn8Jox705unHP                  │  │  │
│  │  └─────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    FASE B (PENDENTE)                                 │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  VM: sec-openvas-gf-01 (a criar)                              │  │
│  │  RAM: 4-6 GB                                                   │  │
│  │  Função: Scanner de vulnerabilidades                           │  │
│  │  ┌─────────────────────────────────────────────────────────┐  │  │
│  │  │  OpenVAS (Greenbone Community Edition)                   │  │  │
│  │  │  Porta: 9392                                              │  │  │
│  │  └─────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘

                    COMUNICAÇÃO VIA TAILSCALE
                              │
                              ▼
              ┌───────────────────────────────┐
              │  api-gf-01 (xxx.xxx.xxx.xxx)  │
              │  Porta: 8000                   │
              │  API REST PRJ008               │
              └───────────────────────────────┘
```

### 2.2. Justificativa da Arquitetura de Duas VMs

| Critério | Abordagem Anterior (v1.3) | Abordagem Atual (v1.4) | Vantagem |
|----------|---------------------------|------------------------|----------|
| Isolamento | Todas ferramentas na mesma VM | DefectDojo isolado do scanner | Falha no OpenVAS não afeta DefectDojo |
| Recursos | 8 GB para 3 ferramentas | 4 GB + 4 GB distribuídos | Melhor aproveitamento |
| Falha do Akto | Bloqueava todo o projeto | Akto removido, projeto prossegue | Resiliência |
| Manutenção | Backup único | Backups separados | Recuperação granular |
| Escalabilidade | Difícil adicionar ferramentas | Fácil criar VM para nova ferramenta | Extensível |

---

## 3. FASE A — DEFECTDOJO (CONCLUÍDA)

### 3.1. Evidências de Conclusão (do `Evidencias PRJ020 b.txt`)

#### Renomeação da VM
```powershell
Stop-VM -Name "sec-scanner-gf-01" -Force
Rename-VM -Name "sec-scanner-gf-01" -NewName "defectdojo-gf-01"
Start-VM -Name "defectdojo-gf-01"
```

#### Configuração do hostname
```bash
sudo hostnamectl set-hostname defectdojo-gf-01
sudo tailscale set --hostname defectdojo-gf-01
```

#### Redução de RAM
```powershell
Set-VMMemory -VMName "sec-scanner-gf-01" -StartupBytes 4GB -DynamicMemoryEnabled $true -MinimumBytes 2GB -MaximumBytes 6GB
```

#### Limpeza do ambiente (remoção de containers órfãos)
```bash
sudo docker stop $(sudo docker ps -aq) 2>/dev/null
sudo docker rm $(sudo docker ps -aq) 2>/dev/null
sudo docker system prune -a -f --volumes 2>/dev/null
```

#### DefectDojo em funcionamento
```bash
curl -I http://localhost:8080
HTTP/1.1 302 Found
Location: /login?next=/
```

#### Acesso ao dashboard (log do navegador)
```
"GET /dashboard HTTP/1.1" 200 9309
"POST /login?next=/" HTTP/1.1" 302 0
```

### 3.2. Configuração Final do DefectDojo

| Parâmetro | Valor |
|-----------|-------|
| URL de acesso | `http://xxx.xxx.xxx.xxx:8080` |
| Usuário admin | `admin` |
| Senha admin | `K6hiVpTKlkn8Jox705unHP` |
| Product criado | "Living Lab — Segurança" |
| Engagement criado | "API Security Assessment — PRJ008 — Abril 2026" |

---

## 4. FASE B — OPENVAS (PENDENTE)

### 4.1. Especificação da VM `sec-openvas-gf-01`

| Parâmetro | Valor | Justificativa |
|-----------|-------|---------------|
| **Hostname** | `sec-openvas-gf-01` | Padrão `sec-*-gf-01` do laboratório |
| **RAM** | 4 GB (mínimo) ou 6 GB (recomendado) | OpenVAS nativo consome menos que Docker |
| **vCPU** | 2 | Scans básicos não exigem mais |
| **Disco** | 80 GB | Feeds VTs (vários GB) + logs |
| **Geração** | GEN1 | CONSTRAINT-001 ativa (ver TAP v1.3 Seção 4) |
| **Sistema Operacional** | Ubuntu 24.04 LTS | Padrão do laboratório |

### 4.2. Instalação do OpenVAS (Nativo)

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependências
sudo apt install -y software-properties-common curl wget gnupg2

# Adicionar repositório do Greenbone
curl -fsSL https://www.greenbone.net/GBCommunitySigningKey.asc | sudo gpg --dearmor -o /etc/apt/keyrings/greenbone.gpg
echo "deb [signed-by=/etc/apt/keyrings/greenbone.gpg] https://deb.greenbone.net/ stable main" | sudo tee /etc/apt/sources.list.d/greenbone.list

# Instalar Greenbone Community Edition
sudo apt update
sudo apt install -f -y greenbone-community-edition

# Configurar Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up

# Acessar OpenVAS
# URL: https://<IP-Tailscale-VM>:9392
```

### 4.3. Target e Task no OpenVAS

**Target — API REST PRJ008:**
```
Nome:       "API REST PRJ008 — api-gf-01"
Hosts:      xxx.xxx.xxx.xxx
Port List:  Custom → T:8000
Alive Test: TCP-ACK Service Detection
```

**Task — Scan Focado:**
```
Nome:        "Task — API REST PRJ008"
Target:      "API REST PRJ008 — api-gf-01"
Scan Config: "Full and fast"
```

---

## 5. INTEGRAÇÃO OPENVAS → DEFECTDOJO

### 5.1. Fluxo de Dados

```
┌─────────────────┐    XML Export     ┌─────────────────┐
│    OpenVAS      │ ────────────────→ │   DefectDojo    │
│  (sec-openvas)  │                   │ (defectdojo-gf) │
└─────────────────┘                   └─────────────────┘
        │                                      │
        │                                      │
        ▼                                      ▼
   Scan da API                           Findings
   api-gf-01:8000                        gerenciados
```

### 5.2. Procedimento de Importação

1. Acessar OpenVAS: `https://<IP-sec-openvas>:9392`
2. Executar Task → Aguardar conclusão
3. Reports → Download → Formato XML
4. Transferir XML para `defectdojo-gf-01` (via scp ou Tailscale)
5. Acessar DefectDojo: `http://xxx.xxx.xxx.xxx:8080`
6. Product → Engagement → Import Scan Results
7. Scan Type: `Greenbone / OpenVAS XML`
8. Upload do arquivo

---

## 6. CRONOGRAMA ATUALIZADO (v1.4)

| Fase | Atividade | Status | Data |
|------|-----------|--------|------|
| **Fase A** | Criar VM sec-scanner-gf-01 | ✅ Concluído | 26/04 |
| **Fase A** | Instalar Ubuntu 24.04 | ✅ Concluído | 26/04 |
| **Fase A** | Instalar DefectDojo via Docker | ✅ Concluído | 26/04 |
| **Fase A** | Testar DefectDojo | ✅ Concluído | 26/04 |
| **Fase A** | Remover Akto e containers órfãos | ✅ Concluído | 27/04 |
| **Fase A** | Renomear VM para defectdojo-gf-01 | ✅ Concluído | 27/04 |
| **Fase A** | Reduzir RAM para 4 GB | ✅ Concluído | 27/04 |
| **Fase B** | Criar VM sec-openvas-gf-01 | ⬜ Pendente | 27/04 |
| **Fase B** | Instalar Ubuntu 24.04 | ⬜ Pendente | 27/04 |
| **Fase B** | Instalar Tailscale | ⬜ Pendente | 27/04 |
| **Fase B** | Instalar OpenVAS nativo | ⬜ Pendente | 27/04 |
| **Fase B** | Configurar Target/Task | ⬜ Pendente | 27/04 |
| **Fase B** | Executar primeiro scan | ⬜ Pendente | 27-28/04 |
| **Fase B** | Importar XML no DefectDojo | ⬜ Pendente | 28/04 |
| **Fase B** | Documentar resultados | ⬜ Pendente | 28/04 |

---

## 7. ENTREGÁVEIS ATUALIZADOS (v1.4)

| ID | Entregável | Formato | Status |
|----|------------|---------|--------|
| E01 | VM defectdojo-gf-01 provisionada | VM + notas | ✅ CONCLUÍDO |
| E02 | DefectDojo funcional | URL + credenciais | ✅ CONCLUÍDO |
| E03 | Product/Engagement criados | Configuração | ✅ CONCLUÍDO |
| E04 | VM sec-openvas-gf-01 criada | VM | ⬜ PENDENTE |
| E05 | OpenVAS instalado e configurado | Configuração | ⬜ PENDENTE |
| E06 | Primeiro scan executado | XML | ⬜ PENDENTE |
| E07 | Importação no DefectDojo | Findings | ⬜ PENDENTE |
| E08 | Relatório de vulnerabilidades da API PRJ008 | Markdown | ⬜ PENDENTE |
| E09 | POP-PROJ020-001 publicado | Markdown | ⬜ PENDENTE |
| E10 | TEP-PROJ020-v1.4 | Markdown | ⬜ PENDENTE |

---

## 8. PRÓXIMOS PASSOS IMEDIATOS

| Ordem | Ação | Responsável | Prazo |
|-------|------|-------------|-------|
| 1 | Criar VM `sec-openvas-gf-01` no Hyper-V (GEN1, 4-6 GB RAM) | Paulo | 27/04 |
| 2 | Instalar Ubuntu 24.04 LTS | Paulo | 27/04 |
| 3 | Instalar Tailscale | Paulo | 27/04 |
| 4 | Instalar OpenVAS nativo (Greenbone) | Paulo | 27/04 |
| 5 | Aguardar sync do feed VTs (~1-2 horas) | Paulo | 27/04 |
| 6 | Configurar Target (api-gf-01:8000) | Paulo | 27/04 |
| 7 | Executar Task de scan | Paulo | 27-28/04 |
| 8 | Exportar XML e importar no DefectDojo | Paulo | 28/04 |
| 9 | Documentar findings e gerar relatório | Paulo | 28/04 |

---

## 9. APROVAÇÕES

| Função | Nome | Data | Status |
|--------|------|------|--------|
| GRC Lead / Responsável | Paulo Feitosa Lima | 27/04/2026 | ✅ APROVADO |
| Arquiteto de Soluções | Paulo Feitosa Lima | 27/04/2026 | ✅ APROVADO |

---

**FIM DO TERMO DE ABERTURA DO PROJETO — PROJ020 v1.4**

---

> 📄 **Documento:** `TAP-PROJ020-v1.4.md`
> 🔒 **Classificação:** CONFIDENCIAL
> 📍 **Localização sugerida:** `10_Projetos/PROJ020/00_Gestao_do_Projeto/TAP-PROJ020-v1.4.md`
> ✍️ **Redigido com apoio de Claude (Anthropic) — Living Lab Fiqueok**
