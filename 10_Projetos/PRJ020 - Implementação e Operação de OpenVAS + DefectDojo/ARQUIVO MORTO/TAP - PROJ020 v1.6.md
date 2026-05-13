# TERMO DE ABERTURA DO PROJETO (TAP) — PROJ020 v1.6
## Implementação de DefectDojo + OpenVAS (Kali) para Descoberta e Gestão de Vulnerabilidades de API
### **Documento Único — Contém Toda a História do Projeto**

---

| Campo | Valor |
|:---|:---|
| **Código do Projeto** | PROJ020 |
| **Nome do Projeto** | Implementação de DefectDojo + OpenVAS (Kali) para Descoberta e Gestão de Vulnerabilidades de API |
| **Versão** | **1.6 (DOCUMENTO ÚNICO)** |
| **Data de Criação** | 24/04/2026 |
| **Data de Atualização** | 27/04/2026 |
| **Responsável** | Paulo Feitosa Lima — GRC Lead |
| **Patrocinador** | Living Lab Fiqueok |
| **Status** | 🟢 **FASE B CONCLUÍDA** — GVM operacional, aguardando primeiro scan |
| **Classificação** | CONFIDENCIAL — Dados Técnicos e de Auditoria |

---

## 📌 SUMÁRIO EXECUTIVO PARA O LEITOR

> *Este documento é a versão final e consolidada do PROJ020. Ele contém toda a jornada do projeto, desde a arquitetura inicial até o pivotamento para Kali Linux e o estado atual operacional. Não é necessário ler versões anteriores.*

| O que você precisa saber | Resumo |
|--------------------------|--------|
| **O que é este projeto?** | Implantar um scanner de vulnerabilidades (OpenVAS/GVM) e um sistema de gestão (DefectDojo) para testar a segurança da API do PRJ008 e descobrir serviços não inventariados |
| **Qual a arquitetura final?** | Duas VMs especializadas: `defectdojo-gf-01` (Ubuntu 24.04 + Docker) e `sec-openvas-kali` (Kali Linux + GVM nativo) |
| **O que já foi feito?** | ✅ DefectDojo operacional; ✅ VM Kali criada; ✅ GVM instalado e configurado; ✅ Acesso web funcionando; ✅ Usuários criados |
| **O que falta?** | ⬜ Aguardar fim do sync de feeds; ⬜ Configurar Target para API PRJ008; ⬜ Executar primeiro scan; ⬜ Importar XML no DefectDojo |
| **Lições aprendidas?** | Ubuntu 24.04 é muito recente para GVM; Kali nativo é mais estável; Docker não resolve tudo |

---

## 1. HISTÓRICO COMPLETO DO PROJETO

### 1.1. Versões Anteriores (Arquivadas)

| Versão | Data | Mudança | Justificativa |
|--------|------|---------|----------------|
| v1.0 | 24/04/2026 | Criação inicial | Arquitetura de três ferramentas em uma VM (OpenVAS + DefectDojo + Akto) |
| v1.1 | 25/04/2026 | Ajustes de configuração | Correções no docker-compose do Akto |
| v1.2 | 26/04/2026 | Identificação de falhas | Akto em loop com erro `-Xmx0m` e `free: command not found` |
| v1.3 | 26/04/2026 | Tentativa de correção com Kafka+ZK | Imagem `:0.5.5` não encontrada; stack não sobe |
| v1.4 | 27/04/2026 | Revisão arquitetural | **FROZEN do Akto + decisão de separar VMs** |
| v1.5 | 27/04/2026 | Pivotamento para Kali | Ubuntu 24.04 inviável para GVM |
| **v1.6** | **27/04/2026** | **Documento único consolidado** | **Unificar toda a história do projeto** |

---

## 2. CONTEXTO ESTRATÉGICO E JUSTIFICATIVA

### 2.1. Por que este projeto existe?

O Living Lab Fiqueok construiu uma stack madura de Governança de Identidades (PRJ001–PRJ016), mas o ciclo GRC permanecia incompleto: o laboratório sabia *quem tinha acesso*, mas não tinha visibilidade sistemática sobre **o que está exposto**.

O PROJ020 introduz a camada de **Gestão de Vulnerabilidades e Segurança de APIs**, fechando o loop entre identidade e superfície de ataque.

### 2.2. Alvo primário — API REST PRJ008

O PRJ008 desenvolveu uma API REST em FastAPI (`api-gf-01:8000`) que expõe dados de funcionários do OrangeHRM. A API está operacional desde abril/2026 e foi congelada (FROZEN) por bloqueio de conector no midPoint 4.10/Java 21 — **nunca foi submetida a um scan formal de vulnerabilidades**.

| Característica | Detalhe |
|----------------|---------|
| Tecnologia | FastAPI + Uvicorn, Python 3.12 |
| Endpoint principal | `GET /employees` |
| Autenticação | Header `X-API-KEY: Fiqueok-Security-Token-2026` |
| Documentação | Swagger UI em `/docs` |
| Status atual | ✅ Operacional — aguardando retomada do PRJ008 |

### 2.3. Alinhamento com Frameworks

| Framework | Controle | Atendimento |
|-----------|----------|-------------|
| ISO 27001:2022 | A.8.8 — Gestão de Vulnerabilidades | Processo formal de scan |
| ISO 27001:2022 | A.8.29 — Testes de Segurança | Validação da API PRJ008 |
| NIST CSF 2.0 | ID.RA — Avaliação de Risco | Descoberta de superfície de ataque |
| CIS Controls v8 | 7 — Gestão de Vulnerabilidades | Scans recorrentes com DefectDojo |

---

## 3. A JORNADA COMPLETA — O QUE FOI TENTADO E O QUE FUNCIONOU

### 3.1. Primeira Tentativa: Ubuntu 24.04 Docker (Akto + OpenVAS + DefectDojo)

**Premissa original:** Uma única VM com 8 GB RAM rodando as três ferramentas via Docker.

#### Falhas do Akto (documentadas no `Evidencias PRJ020 b.txt`)

| Tentativa | Problema | Status |
|-----------|----------|--------|
| 1 | `Calculated -Xmx value: 0 MB` + `free: command not found` | Container em loop |
| 2 | `JAVA_OPTS=-Xmx512m` definido | Sobe mas `curl: Connection reset by peer` |
| 3 | Inclusão de Kafka + Zookeeper | Container reinicia; curl falha |
| 4 | Stack com `confluentinc/cp-kafka` | Imagem `:0.5.5` não encontrada |
| 5 | Limpeza total | Akto sequer sobe |

**Decisão:** Akto removido do escopo (poderá ser reavaliado em projeto futuro).

#### Falhas do OpenVAS no Ubuntu 24.04

| Tentativa | Problema |
|-----------|----------|
| Repositório oficial Greenbone | `Connection timed out` — resolvendo para IP de teste `203.0.113.1` |
| PPA mrazavi/gvm | `404 Not Found` — PPA não suporta Ubuntu 24.04 (Noble) |
| Script `gvm-setup.sh` | `404 Not Found` — URL do script mudou |
| Docker (após instalar) | `pull access denied` — imagens migraram para registro privado |

### 3.2. Decisão de Pivotamento (v1.5)

| Premissa Original | Realidade Encontrada |
|-------------------|----------------------|
| Ubuntu LTS → estável e suportado | Bibliotecas muito novas → PPAs quebrados (404) |
| Docker → isolamento fácil | Greenbone migrou imagens (`pull access denied`) |
| Scripts oficiais → funcionam | `gvm-setup.sh` removido (404) |
| Container tem permissões totais | AppArmor/Kernel bloqueia `CAP_NET_RAW` |

**Decisão Final:** Migrar para **Kali Linux com GVM nativo**.

### 3.3. Implementação no Kali Linux (Bem-sucedida)

#### Infraestrutura da VM

| Parâmetro | Valor | Justificativa |
|-----------|-------|---------------|
| Nome | `sec-openvas-kali` | Padrão `sec-*-kali` do laboratório |
| Geração | **GEN2** (Secure Boot desligado) | CONSTRAINT-001 contornada com ajuste |
| RAM | 4-8 GB (dinâmica) | Suficiente para GVM + feeds |
| vCPU | 2 | Scans não exigem mais |
| Disco | 80 GB (VHDX dinâmico) | Feeds NVTs (vários GB) + logs |
| SO | Kali Linux Rolling (2026.1) | Suporte nativo ao GVM |

#### Comandos executados (evidência)

```bash
# Acesso à VM
ssh kali@xxx.xxx.xxx.xxx

# Instalação do GVM (sucesso!)
sudo apt install -y gvm
# Saída: Installing: gvm, greenbone-security-assistant, gsad, gvm-tools

# Setup automático
sudo gvm-setup
# Senha admin gerada: 69637965-4ae0-4dea-84f7-21134fd45a7b

# Verificação
sudo gvm-check-setup
# Resultado: "It seems like your GVM-25.04.0 installation is OK."

# NVTs carregados: 95.086 NVTs
# Feeds sincronizando via rsync
```

#### Correção do acesso remoto (gsad)

Problema: `gsad` escutando apenas em `127.0.0.1` e erro `GLib-CRITICAL: g_file_get_contents: assertion 'filename != NULL' failed`

Solução aplicada:
```bash
# Configurar arquivo de serviço
sudo systemctl edit gsad.service
# Adicionar override com environment

# Verificar resultado
sudo ss -tunlp | grep 9392
# Saída: tcp LISTEN 0 4096 0.0.0.0:9392 0.0.0.0:* users:(("gsad",pid=46685,fd=4))
```

#### Usuários e segurança

```bash
# Alterar senha do admin
sudo gvmd --user=admin --new-password='**********'

# Criar usuário paulo com sudo
sudo adduser paulo
sudo usermod -aG sudo paulo

# Bloquear usuário kali padrão (segurança)
sudo usermod -L kali
```

#### Otimização para servidor (modo appliance)

```bash
# Desabilitar interface gráfica
sudo systemctl set-default multi-user.target
sudo systemctl stop lightdm

# Desabilitar atualizações automáticas
sudo systemctl disable --now apt-daily.timer
sudo systemctl disable --now apt-daily-upgrade.timer

# Verificar economia de memória
free -h
# Saída: Mem: 3.8Gi total, 464Mi usado, 3.4Gi livre (ótimo!)
```

---

## 4. ARQUITETURA FINAL APROVADA (v1.6)

### 4.1. Estratégia de Duas VMs Especializadas

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LIVING LAB — PROJ020 v1.6                           │
│                                                                             │
│  ┌─────────────────────────────┐    ┌─────────────────────────────────────┐│
│  │  FASE A (CONCLUÍDA)          │    │  FASE B (CONCLUÍDA)                 ││
│  │  ┌─────────────────────────┐ │    │  ┌───────────────────────────────┐ ││
│  │  │ defectdojo-gf-01        │ │    │  │ sec-openvas-kali              │ ││
│  │  │ Ubuntu 24.04            │ │    │  │ Kali Linux Rolling            │ ││
│  │  │ DefectDojo (Docker)     │ │    │  │ GVM (Nativo)                  │ ││
│  │  │ Porta: 8080             │ │    │  │ Porta: 9392                   │ ││
│  │  │ Tailscale: xxx.xxx.xxx.xxx │ │    │  │ Tailscale: xxx.xxx.xxx.xxx      │ ││
│  │  │ ✅ Funcional            │ │    │  │ ✅ Funcional                  │ ││
│  │  └─────────────────────────┘ │    │  └───────────────────────────────┘ ││
│  └─────────────────────────────┘    └─────────────────────────────────────┘│
│                                                                             │
│                         COMUNICAÇÃO VIA TAILSCALE MESH                      │
│                                       │                                     │
│                                       ▼                                     │
│                       ┌───────────────────────────────┐                     │
│                       │  api-gf-01 (xxx.xxx.xxx.xxx)  │                     │
│                       │  Porta: 8000                   │                     │
│                       │  API REST PRJ008               │                     │
│                       └───────────────────────────────┘                     │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2. Configuração Final dos Componentes

| Componente | Sistema | Método | Porta | IP Tailscale | Status |
|------------|---------|--------|-------|--------------|--------|
| DefectDojo | Ubuntu 24.04 | Docker | 8080 | xxx.xxx.xxx.xxx | ✅ |
| OpenVAS/GVM | Kali Rolling | Nativo (`apt`) | 9392 | xxx.xxx.xxx.xxx | ✅ |

### 4.3. Credenciais e Acesso

| Serviço | URL | Usuário | Senha |
|---------|-----|---------|-------|
| DefectDojo | `http://xxx.xxx.xxx.xxx:8080` | `admin` | `K6hiVpTKlkn8Jox705unHP` |
| GSA (OpenVAS) | `http://xxx.xxx.xxx.xxx:9392` | `admin` | `**********` |
| SSH VM Kali | `ssh paulo@xxx.xxx.xxx.xxx` | `paulo` | (definida na criação) |

---

## 5. LIÇÕES APRENDIDAS (BASE DE CONHECIMENTO DO LIVING LAB)

### L01: Distros "bleeding edge" não são para ferramentas complexas

| Lição | Impacto |
|-------|---------|
| Ubuntu 24.04 lançado com bibliotecas muito recentes | PPAs comunitários não tiveram tempo de homologar |
| OpenVAS depende de ~30 bibliotecas específicas | Conflito de versões é inevitável no primeiro ano de uma LTS |
| **Recomendação para projetos futuros:** | Para ferramentas complexas, utilizar distros com 6-12 meses de mercado ou distribuições especializadas (Kali, Parrot) |

### L02: Scripts de terceiros são pontos de falha

| Falha | Causa | Mitigação |
|-------|-------|-----------|
| `gvm-setup.sh` → 404 | Greenbone reorganizou repositórios | Preferir pacotes empacotados (`apt`) ou containers oficiais |
| PPAs → 404 | Mantenedores não atualizaram para Noble | Verificar suporte antes de adotar distro nova |

### L03: Docker não é solução universal para permissões de rede

| Tentativa | Resultado |
|-----------|-----------|
| `docker run --privileged` | ❌ Ainda bloqueado pelo AppArmor do host |
| `cap_add: - NET_RAW - NET_ADMIN` | ⚠️ Funciona apenas se host permite |

**Conclusão:** O scanner precisa de permissões de rede que containers modernos podem não ter. **Nativo ainda ganha em casos de ferramentas de baixo nível.**

### L04: Kali Linux como appliance funciona

| Característica | Resultado no PROJ020 |
|----------------|----------------------|
| Rolling release | Risco controlado com atualizações manuais e seletivas |
| Pacote `gvm` nativo | ✅ Vantagem — mantido pela Offensive Security |
| Scripts `gvm-*` | `gvm-setup`, `gvm-check-setup`, `gvm-start/stop` funcionam perfeitamente |
| Memória RAM | **464 MB** após remoção da GUI → excelente para VM dedicada |

---

## 6. STATUS ATUAL DA IMPLEMENTAÇÃO

### 6.1. O que já foi CONCLUÍDO ✅

| Etapa | Detalhe | Data |
|-------|---------|------|
| VM DefectDojo | Criada, configurada e funcional | 26-27/04 |
| DefectDojo Product/Engagement | "Living Lab — Segurança" criado | 27/04 |
| VM Kali `sec-openvas-kali` | Criada (GEN2, 4-8 GB RAM) | 27/04 |
| Kali instalado | ISO 2026.1 | 27/04 |
| Tailscale configurado | IP `xxx.xxx.xxx.xxx` | 27/04 |
| GVM instalado | `sudo apt install -y gvm` | 27/04 |
| `gvm-setup` executado | Senha admin `69637965...` | 27/04 |
| `gvm-check-setup` | OK — 95.086 NVTs carregados | 27/04 |
| Senha admin alterada | `**********` | 27/04 |
| Usuário `paulo` criado | Com sudo | 27/04 |
| Usuário `kali` bloqueado | Segurança | 27/04 |
| gsad configurado | Escutando em `0.0.0.0:9392` | 27/04 |
| Interface gráfica desligada | Modo texto (appliance) | 27/04 |
| Atualizações automáticas | Desabilitadas | 27/04 |

### 6.2. O que está EM ANDAMENTO 🔄

| Etapa | Detalhe | Progresso |
|-------|---------|-----------|
| **Sincronização dos feeds** | SCAP, CERT, GVMD_DATA via rsync | Logs mostrando downloads ativos (CVE 2000-2026) |

**Verificação em tempo real:**
```bash
sudo tail -f /var/log/gvm/gvmd.log
# md manage: Updating /var/lib/gvm/scap-data/nvdcve-2.0-YYYY.json.gz
```

### 6.3. O que está PENDENTE ⬜

| Ordem | Etapa | Responsável |
|-------|-------|-------------|
| 1 | Aguardar fim do sync de feeds (1-3 horas) | Automático |
| 2 | Acessar GSA: `http://xxx.xxx.xxx.xxx:9392` (admin/`**********`) | Paulo |
| 3 | Configurar Target: `API REST PRJ008 — api-gf-01` (host `xxx.xxx.xxx.xxx`, porta `8000`) | Paulo |
| 4 | Configurar Task: `Scan Inaugural — API PRJ008` (Scan Config: Full and fast) | Paulo |
| 5 | Executar Task | Paulo |
| 6 | Exportar XML do report | Paulo |
| 7 | Transferir XML para DefectDojo (via scp ou Tailscale) | Paulo |
| 8 | Importar no DefectDojo (Scan Type: `Greenbone / OpenVAS XML`) | Paulo |
| 9 | Analisar findings e documentar | Paulo |
| 10 | Publicar POP-PROJ020-001 e TEP | Paulo |

---

## 7. CRONOGRAMA REMANESCENTE

| Fase | Atividade | Duração Estimada |
|------|-----------|------------------|
| **1** | Aguardar sync de feeds | 1-3 horas (em progresso) |
| **2** | Configurar Target e Task | 15 min |
| **3** | Executar primeiro scan (porta 8000) | 30-60 min |
| **4** | Exportar e importar XML | 10 min |
| **5** | Analisar resultados | 30-60 min |
| **6** | Publicar POP e TEP | 1 hora |

**Total remanescente:** ~3-5 horas

---

## 8. PROCEDIMENTO OPERACIONAL PADRÃO (POP) — PROJ020-001

### 8.1. Pré-requisitos

- [ ] Kali VM ligada: `ssh paulo@xxx.xxx.xxx.xxx`
- [ ] Tailscale ativo: `tailscale status`
- [ ] API PRJ008 acessível: `tailscale ping xxx.xxx.xxx.xxx`
- [ ] GSA acessível: `http://xxx.xxx.xxx.xxx:9392`

### 8.2. Executar scan

1. Acessar GSA: `http://xxx.xxx.xxx.xxx:9392` (admin/`**********`)
2. Verificar feeds: Administration → Feed Status (aguardar sync)
3. Scans → Targets → New Target:
   - Nome: `API REST PRJ008 — api-gf-01`
   - Hosts: `xxx.xxx.xxx.xxx`
   - Port List: `Custom` → `T:8000`
4. Scans → Tasks → New Task:
   - Nome: `Scan Inaugural — API PRJ008`
   - Target: (selecionar o criado)
   - Scan Config: `Full and fast`
5. Start task (ícone ▶️)
6. Aguardar status `Done`

### 8.3. Importar no DefectDojo

1. Reports → Download → Formato **XML**
2. Transferir XML: `scp arquivo.xml paulo@xxx.xxx.xxx.xxx:~/scans/`
3. Acessar DefectDojo: `http://xxx.xxx.xxx.xxx:8080`
4. Navegar: Product → Engagement → Import Scan Results
5. Scan Type: `Greenbone / OpenVAS XML`
6. Upload arquivo → Import

---

## 9. RISCOS E MITIGAÇÕES

| ID | Risco | Probabilidade | Impacto | Mitigação |
|----|-------|--------------|---------|-----------|
| R-K01 | `apt full-upgrade` quebrar GVM | Média | Alto | **Manutenção controlada:** apenas `apt upgrade --no-upgrade gvm*` |
| R-K02 | GVM não iniciar após reboot | Baixa | Médio | Script `@reboot` no crontab: `@reboot sleep 30 && sudo gvm-start` |
| R-K03 | Feed sync falhar por rede | Baixa | Médio | Proxy Mirror local (projeto futuro) |
| R-K04 | API PRJ008 offline | Baixa | Médio | Verificar `tailscale ping xxx.xxx.xxx.xxx` antes do scan |

---

## 10. ENTREGÁVEIS PREVISTOS

| ID | Entregável | Status |
|----|------------|--------|
| E01 | VM defectdojo-gf-01 (DefectDojo) | ✅ CONCLUÍDO |
| E02 | VM sec-openvas-kali (Kali + GVM) | ✅ CONCLUÍDO |
| E03 | Product/Engagement no DefectDojo | ✅ CONCLUÍDO |
| E04 | GVM configurado e acessível | ✅ CONCLUÍDO |
| E05 | Lições documentadas (L01-L04) | ✅ CONCLUÍDO |
| E06 | Primeiro scan executado | ⬜ PENDENTE |
| E07 | XML importado no DefectDojo | ⬜ PENDENTE |
| E08 | Relatório de vulnerabilidades | ⬜ PENDENTE |
| E09 | POP-PROJ020-001 publicado | ⬜ PENDENTE |
| E10 | TEP-PROJ020-v1.6 (este doc) | ⬜ PENDENTE (após scan) |

---

## 11. REFERÊNCIAS

| Documento | Relação |
|-----------|---------|
| `TEP-PRJ008-v1.0-FREEZING.md` | Alvo primário — API REST PRJ008 |
| `CONTEXTO_LivingLab_Fiqueok_v1.0.md` | CONSTRAINT-001 e workaround GEN1/GEN2 |
| `Evidencias PRJ020 b.txt` | Logs completos das tentativas |
| `POP-GRC-001` | Processo de gestão de vulnerabilidades |

---

## 12. PRÓXIMOS PASSOS IMEDIATOS

| Ordem | Ação | Responsável |
|-------|------|-------------|
| 1 | Aguardar fim do sync de feeds (verificar via `sudo tail -f /var/log/gvm/gvmd.log`) | Automático |
| 2 | Acessar GSA e confirmar feed status verde | Paulo |
| 3 | Configurar Target para `api-gf-01:8000` | Paulo |
| 4 | Executar Task de scan | Paulo |
| 5 | Exportar XML e importar no DefectDojo | Paulo |
| 6 | Documentar findings e gerar TEP | Paulo |

---

## 13. APROVAÇÕES

| Função | Nome | Data | Status |
|--------|------|------|--------|
| GRC Lead / Responsável | Paulo Feitosa Lima | 27/04/2026 | ✅ APROVADO |
| Arquiteto de Soluções | Paulo Feitosa Lima | 27/04/2026 | ✅ APROVADO |

---

**FIM DO TERMO DE ABERTURA DO PROJETO — PROJ020 v1.6 (DOCUMENTO ÚNICO)**

---

> 📄 **Documento:** `TAP-PROJ020-v1.6.md`
> 🔒 **Classificação:** CONFIDENCIAL
> 📍 **Localização:** `10_Projetos/PROJ020/00_Gestao_do_Projeto/TAP-PROJ020-v1.6.md`
> 🗄️ **Versões anteriores (v1.0 a v1.5):** `10_Projetos/PROJ020/Arquivo_Morto/`
> ✍️ **Redigido com apoio de Claude (Anthropic) — Living Lab Fiqueok**

---

## 📁 INSTRUÇÕES PARA ARQUIVAMENTO

As versões anteriores (`TAP-PROJ020-v1.0.md` a `TAP-PROJ020-v1.5.md`) devem ser movidas para:

```
10_Projetos/PROJ020/Arquivo_Morto/
```

**Este documento (v1.6) é o único que precisa ser mantido como referência ativa do projeto.**
