## TAP-PROJ020-v1.5 — TERMO DE ABERTURA DO PROJETO

### **Versão:** 1.5

### **Data:** 27/04/2026

### **Status:** 🟡 PIVOTAMENTO EM EXECUÇÃO — Fase B-v2 iniciada

---

## 1. JUSTIFICATIVA ESTRATÉGICA DO PIVOTAMENTO

### 1.1. Falha da Hipótese Inicial (Ubuntu 24.04 LTS)

|Premissa Original|Realidade Encontrada|
|---|---|
|Ubuntu LTS → estável e suportado|Biblioteca libical + Python muito novas → PPAs quebrados (404)|
|Docker → isolamento fácil|Greenbone migrou imagens para registro privado (`pull access denied`)|
|Scripts oficiais → funcionam|`gvm-setup.sh` removido/substituído (404)|
|Container tem permissões totais|AppArmor/Kernel bloqueia `CAP_NET_RAW` mesmo em modo privilegiado|

### 1.2. Decisão de Pivotamento

**Arquitetura Aprovada a partir de v1.5:**

|Componente|v1.4 (Falho)|v1.5 (Corrigido)|
|---|---|---|
|**Sistema Operacional VM**|Ubuntu Server 24.04 LTS|**Kali Linux Rolling**|
|**Método de Deploy**|Docker Compose|**Nativo via `apt`**|
|**OpenVAS/GVM**|Container (`greenbone/ospd-openvas`)|Pacote (`gvm`)|
|**Scripts de Gestão**|Manuais|`gvm-setup`, `gvm-start/stop`|
|**Manutenção de Feeds**|Via container|`greenbone-feed-sync` nativo|

---

## 2. ARQUITETURA FINAL APROVADA (v1.5)

text

┌─────────────────────────────────────────────────────────────────────────┐
│                     LIVING LAB — PROJ020 v1.5                           │
│                                                                         │
│  ┌─────────────────────────┐    ┌─────────────────────────────────────┐ │
│  │  FASE A (CONCLUÍDA)      │    │  FASE B-v2 (EM EXECUÇÃO)            │ │
│  │  ┌─────────────────────┐ │    │  ┌───────────────────────────────┐ │ │
│  │  │ defectdojo-gf-01    │ │    │  │ sec-openvas-kali              │ │ │
│  │  │ Ubuntu 24.04        │ │    │  │ Kali Linux Rolling            │ │ │
│  │  │ DefectDojo (Docker) │ │    │  │ GVM (Nativo)                  │ │ │
│  │  │ Porta: 8080         │ │    │  │ Porta: 9392                   │ │ │
│  │  │ ✅ Funcional        │ │    │  │ 🔄 Em provisionamento         │ │ │
│  │  └─────────────────────┘ │    │  └───────────────────────────────┘ │ │
│  └─────────────────────────┘    └─────────────────────────────────────┘ │
│                                                                         │
│                    COMUNICAÇÃO VIA TAILSCALE MESH                       │
│                                    │                                    │
│                                    ▼                                    │
│                    ┌───────────────────────────────┐                    │
│                    │  api-gf-01 (xxx.xxx.xxx.xxx)  │                    │
│                    │  Porta: 8000                   │                    │
│                    │  API REST PRJ008               │                    │
│                    └───────────────────────────────┘                    │
└─────────────────────────────────────────────────────────────────────────┘

---

## 3. LIÇÕES APRENDIDAS (BASE DE CONHECIMENTO)

### L01: Distros "bleeding edge" vs. Ferramentas Maduras

|Lição|Impacto|
|---|---|
|Ubuntu 24.04 lançado com bibliotecas muito recentes|PPAs comunitários não tiveram tempo de homologar|
|OpenVAS depende de ~30 bibliotecas específicas|Conflito de versões é inevitável no primeiro ano de uma LTS|
|**Recomendação:** Para ferramentas complexas, utilizar distros com 6-12 meses de mercado|`apt` funciona, PPAs estão testados|

### L02: Dependência de Scripts de Terceiros

|Falha|Causa|Mitigação Futura|
|---|---|---|
|`gvm-setup.sh` → 404|Greenbone reorganizou repositórios|Preferir pacotes empacotados (`apt`) ou containers oficiais|
|PPAs → 404|Mantenedores não atualizaram para Noble|Verificar suporte antes de adotar distro nova|

### L03: Docker Não é "Curinga" para Permissões de Rede

|Comando|Resultado|
|---|---|
|`docker run --privileged`|❌ Ainda bloqueado pelo AppArmor do host|
|`cap_add: - NET_RAW - NET_ADMIN`|⚠️ Funciona apenas se host permite|

**Conclusão:** O scanner precisa de permissões de rede que containers modernos (mesmo privilegiados) podem não ter dependendo da configuração do kernel do host.

### L04: Kali Linux — Caso de Uso Correto

|Característica|Para PROJ020|Justificativa|
|---|---|---|
|Rolling release|⚠️ Risco controlado|Usaremos como **appliance** (atualizações controladas)|
|Pacote `gvm` nativo|✅ Vantagem|Mantido pela Offensive Security|
|Scripts `gvm-*`|✅ Vantagem|`gvm-setup`, `gvm-check-setup`, `gvm-start/stop`|

---

## 4. IMPACTOS E RISCOS REVISADOS

### 4.1. Impacto no Cronograma

|Atividade|Estimativa Original (v1.4)|Real (v1.5)|Diferença|
|---|---|---|---|
|Instalação do OpenVAS|2 horas|30 minutos (Kali)|**-1.5h**|
|Configuração e ajustes|2 horas|1 hora|**-1h**|
|Sincronização de feeds|1-2 horas|1-2 horas|Neutro|
|**TOTAL FASE B**|**5-6 horas**|**4-5 horas**|**-1 hora**|

✅ O pivotamento **reduziu** o tempo de implementação, não aumentou.

### 4.2. Novos Riscos e Mitigações

|ID|Risco|Probabilidade|Impacto|Mitigação|
|---|---|---|---|---|
|R-K01|`apt full-upgrade` quebrar GVM|Média|Alto|**Congelar atualizações** (modo appliance)|
|R-K02|GVM não iniciar após reboot|Baixa|Médio|Script `@reboot` no crontab|
|R-K03|Feed sync falhar por rede|Baixa|Médio|Proxy Mirror local em projeto futuro|

### 4.3. Procedimento de Manutenção do Kali (Modo Appliance)

bash

# Em vez de `apt full-upgrade`, atualizações controladas:
sudo apt update
sudo apt upgrade --no-upgrade gvm python3* postgresql* redis*  # isola GVM
# Ou realizar upgrade completo apenas em janela de manutenção agendada

---

## 5. STATUS ATUAL DA IMPLEMENTAÇÃO

### Fase B-v2: Kali Linux + GVM Nativo

|Etapa|Comando/Status|Concluído|
|---|---|---|
|Criar VM `sec-openvas-kali`|✅ VM criada (GEN1, 4-6 GB RAM)|(aguardando confirmação)|
|Instalar Kali Linux|⬜ Pendente|—|
|Instalar Tailscale|⬜ Pendente|—|
|Instalar GVM|`sudo apt install -y gvm`|⬜ Pendente|
|Executar `gvm-setup`|Anotar senha admin|⬜ Pendente|
|Verificar com `gvm-check-setup`|⬜ Pendente|—|
|Configurar acesso remoto|`gsad --listen=0.0.0.0`|⬜ Pendente|
|Executar scan na API PRJ008|⬜ Pendente|—|
|Exportar XML para DefectDojo|⬜ Pendente|—|

---

## 6. ENTREGÁVEIS ATUALIZADOS (v1.5)

|ID|Entregável|Status|
|---|---|---|
|E01|VM defectdojo-gf-01 (DefectDojo)|✅ CONCLUÍDO|
|E02|VM sec-openvas-kali criada|🔄 EM PROVISIONAMENTO|
|E03|GVM instalado e configurado|⬜ PENDENTE|
|E04|Primeiro scan da API PRJ008|⬜ PENDENTE|
|E05|XML importado no DefectDojo|⬜ PENDENTE|
|E06|Relatório de vulnerabilidades|⬜ PENDENTE|
|E07|Lições documentadas (este TAP)|✅ CONCLUÍDO|

---

## 7. APROVAÇÕES

|Função|Nome|Data|Status|
|---|---|---|---|
|GRC Lead / Responsável|Paulo Feitosa Lima|27/04/2026|✅ APROVADO|
|Arquiteto de Soluções|Paulo Feitosa Lima|27/04/2026|✅ APROVADO|

---

**FIM DO TERMO DE ABERTURA DO PROJETO — PROJ020 v1.5**

---

> 📄 **Documento:** `TAP-PROJ020-v1.5.md`  
> 🔒 **Classificação:** CONFIDENCIAL  
> 📍 **Localização sugerida:** `10_Projetos/PROJ020/00_Gestao_do_Projeto/TAP-PROJ020-v1.5.md`  
> ✍️ **Redigido com apoio de Claude (Anthropic) — Living Lab Fiqueok**
