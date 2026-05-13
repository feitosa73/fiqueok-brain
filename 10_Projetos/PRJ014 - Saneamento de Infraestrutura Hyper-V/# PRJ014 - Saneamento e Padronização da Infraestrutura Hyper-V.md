> [!success] PROJETO CONCLUÍDO **Status:** ✅ CONCLUÍDO — Encerramento formal em 28/03/2026, adendo em 29/03/2026 **Documento de encerramento:** `TEP-PRJ014 V 1.1` **Procedimento operacional derivado:** `POP-GOLDEN-DISK-001` **Próximo projeto:** `TAP-PRJ015` — IGA Híbrido Local (AD → Entra Cloud Sync)

---



---

## 1. IDENTIFICAÇÃO DO PROJETO

|Campo|Valor|
|---|---|
|**Código**|PRJ014|
|**Nome**|Saneamento e Padronização da Infraestrutura Hyper-V|
|**Categoria**|Infraestrutura / Governança de Laboratório|
|**Responsável**|Paulo Feitosa Lima|
|**Data Início**|27/03/2026|
|**Data Conclusão**|28/03/2026 (adendo: 29/03/2026)|
|**Duração Real**|3 dias|
|**Predecessores**|PRJ010, PRJ011, PRJ012, PRJ009|
|**Sucessor**|PRJ015 — IGA Híbrido Local|

---

## 2. HISTÓRICO DO PROJETO

> [!note] Por que este documento existe da forma que está O PRJ014 nasceu com um escopo diferente do que foi executado. Esta seção registra essa evolução para que o histórico de decisões seja rastreável.

### 2.1. Escopo Original (26/03/2026)

O TAP original (`TAP-PRJ014-IGA-Hibrido.md` — movido para `_ARQUIVO-MORTO`) previa o PRJ014 como um projeto de **IGA Híbrido completo**, cobrindo:

- Criação do AD local (Greenfield)
- Script de ingestão OrangeHRM → AD
- Instalação do Entra Cloud Sync Agent **no próprio DC**
- Sincronização AD → Entra ID com 100 usuários

**Por que não foi executado assim:**

|Fator|Consequência|
|---|---|
|A infraestrutura Hyper-V estava desorganizada (VMs em 3 locais, ISOs duplicadas, checkpoints acumulados)|Era impossível criar novas VMs ou templates sem saneamento prévio|
|CONSTRAINT-001 descoberta durante o diagnóstico: subsistema UEFI do Hyper-V corrompido|Impossível criar VMs GEN2 a partir de ISO — bloqueava toda a estratégia de Golden Disks|
|Decisão arquitetural: separar o Cloud Sync Agent do DC em VM dedicada (SYNC-01)|Mudança de escopo — o Cloud Sync virou responsabilidade do PRJ015|

**Resultado:** o PRJ014 foi redefinido exclusivamente como projeto de saneamento de infraestrutura, e o IGA Híbrido passou para o PRJ015.

### 2.2. Renumeração dos Projetos

|Projeto|Nome|Status|
|---|---|---|
|**PRJ014**|Saneamento e Padronização Hyper-V|✅ Concluído|
|**PRJ015**|IGA Híbrido Local (AD → Cloud Sync)|📋 Planejado|
|**PRJ016**|midPoint como Motor IGA (pós-Trial)|📋 Futuro|

---

## 3. JUSTIFICATIVA

Diagnóstico da infraestrutura Hyper-V identificou:

|Problema|Impacto|
|---|---|
|VMs espalhadas em 3 locais diferentes|Dificuldade de gestão e backup|
|ISOs duplicadas em 3 pastas|6.3 GB de espaço desperdiçado|
|VM `LINUX-GOLDEN-IMAGE` com disco inexistente|VM inoperante|
|Múltiplos checkpoints acumulados|Risco de corrupção e degradação de performance|
|Ausência de template padronizado para Windows Server|Dificuldade para criar novas VMs|
|**CONSTRAINT-001: UEFI corrompido**|**Impossível criar VMs GEN2 a partir de ISO**|

---

## 4. ESCOPO EXECUTADO

### 4.1. Incluído

|Item|Status|
|---|---|
|Consolidação de ISOs em `C:\Hyper-V\ISOs\`|✅ Concluído|
|Migração de todas as VMs para `C:\Hyper-V\VMs\[VMName]\`|✅ Concluído|
|Consolidação de checkpoints antigos|✅ Concluído|
|Remoção da VM `LINUX-GOLDEN-IMAGE` (disco inexistente)|✅ Concluído|
|Criação do Golden Disk Windows Server 2022|✅ Concluído (com ciclo de purificação — ver Seção 6)|
|Criação do Golden Disk Ubuntu 24.04 LTS|✅ Concluído (homologação pendente — ver Seção 6)|
|Documentação: TEP-PRJ014 v1.1 e POP-GOLDEN-DISK-001|✅ Concluído|

### 4.2. Excluído

|Item|Motivo|Destino|
|---|---|---|
|Migração de dados do OrangeHRM ou midPoint|Fora do escopo|—|
|Configuração de Entra Cloud Sync|Escopo redefinido|PRJ015|
|Script de ingestão OrangeHRM → AD|Escopo redefinido|PRJ016|
|Criação de novas VMs de produção|Apenas templates neste projeto|PRJ015+|

---

## 5. CHECKPOINTS — DECISÕES TOMADAS

|VM|Ação|Justificativa|
|---|---|---|
|ID-P-01, rh-gf-01-local, VAULT-GEN1|**Mantidos**|Checkpoints ativos representam pontos de recuperação|
|FOK-SRV-LDAP-01, IGA-P-01|**Consolidados (mesclados)**|Checkpoints antigos — mesclagem sem perda de dados|
|LINUX-GOLDEN-IMAGE|**Removida**|Disco inexistente; nada a preservar|

---

## 6. GOLDEN DISKS — HISTÓRICO E ESTADO FINAL

> [!warning] Leia antes de usar qualquer Golden Disk O processo de criação foi significativamente mais complexo do que o previsto. O Golden Disk Windows original foi **reprovado no Pre-Flight** e substituído após ciclo de purificação de 4 iterações. Consulte o `POP-GOLDEN-DISK-001` antes de provisionar qualquer VM a partir destes templates.

### 6.1. Windows Server 2022 — Linha do Tempo

O processo de criação do Golden Disk Windows passou por dois momentos distintos:

**Fase 1 — Criação inicial (27-28/03/2026):**

- CONSTRAINT-001 impediu instalação via ISO para GEN2
- Workaround: clonagem da VM `ID-P-01` (GEN2 existente)
- Resultado entregue no TEP v1.0: `Win2022-GF-GEN2.vhdx` (13.82 GB)

**Fase 2 — Ciclo de purificação (29/03/2026):** Pre-Flight identificou duas não-conformidades no ativo entregue na Fase 1:

|Não-Conformidade|Impacto|
|---|---|
|`ParentPath` não nulo — disco com dependência de pai|Não era standalone; clonagem propagaria a dependência|
|`IsReadOnly = False` — sem proteção de imutabilidade|Risco de alteração acidental do template|

Ciclo de purificação executado em 10 etapas:

|#|Etapa|Resultado|
|---|---|---|
|1|Pre-Flight Audit no GEN2 original|2 reprovações|
|2|Tentativa Merge-VHD|Falhou — cmdlet exige destino existente|
|3|Convert-VHD → GEN2-FINAL|Disco intermediário standalone criado|
|4|VM POC-PROJ015-TEST|Validação estrutural — 3/4 controles OK|
|5|Descomissionamento de AD DS, DNS, DHCP + remoção do Edge Stable|Sysprep desbloqueado|
|6|Sysprep /generalize /oobe /shutdown|Executado com sucesso|
|7|VM VAL-PURE-GREENFIELD — validação OOBE|Tela "Hi there" confirmada ✅|
|8|Convert-VHD → PURE-OFFICIAL|Disco puro extraído (13.04 GB)|
|9|Rename para PURE-V3-GREENFIELD + reparo de cadeia via Set-VHD|Golden Disk oficial nomeado|
|10|Higienização — deleção de intermediários + ReadOnly em todos os GDs|~41 GB recuperados|

**Estado final dos ativos Windows:**

|Arquivo|Tamanho|ReadOnly|Status|Uso|
|---|---|---|---|---|
|`Win2022-GF-GEN1.vhdx`|10.29 GB|✅ True|Ativo / Legado|DCs sem Secure Boot|
|`Win2022-GF-GEN2.vhdx`|13.82 GB|✅ True|⚠️ Reprovado|Não usar — ParentPath detectado|
|**`Win2022-GF-PURE-V3-GREENFIELD.vhdx`**|**13.04 GB**|**✅ True**|**✅ OFICIAL**|**Template padrão para PRJ015+**|

### 6.2. Ubuntu 24.04 LTS

- CONSTRAINT-001 impediu instalação via ISO para GEN2
- Workaround: clonagem de VM existente + sanitização (remoção de Tailscale, machine-id, chaves SSH)
- Validação de estado Greenfield (cloud-init) **pendente**

**Estado final dos ativos Ubuntu:**

|Arquivo|Tamanho|ReadOnly|Status|
|---|---|---|---|
|`Ubuntu2404-GF-GEN2.vhdx`|13.19 GB|✅ True|Base de origem — não usar diretamente|
|`Ubuntu2404-GF-GEN2-Clone.vhdx`|6.94 GB|✅ True|⚠️ Pendente homologação|
|`Ubuntu2404-GF-GEN2-Greenfield.vhdx`|7.13 GB|✅ True|⚠️ Candidato oficial — validação cloud-init pendente|

---

## 7. ESTRUTURA FINAL DO HYPER-V

```
C:\Hyper-V\
│
├── ISOs\
│   ├── WindowsServer2022.iso                        (4.7 GB)
│   └── ubuntu-24.04.3-live-server-amd64.iso         (3.08 GB)
│
├── VMs\
│   ├── api-gf-01\
│   │   └── api-gf-01.vhdx
│   ├── FOK-SRV-LDAP-01\
│   │   └── FOK-SRV-LDAP-01_RECUPERADA.vhdx
│   ├── ID-P-01\
│   │   └── ID-P-01.vhdx
│   ├── IGA-GF-01\
│   │   └── IGA-GF-01_67D99B74(...).avhdx            ← diferencial ativo
│   ├── IGA-P-01\
│   │   └── IGA-P-01_8F467337(...).avhdx             ← diferencial ativo
│   ├── rh-gf-01-local\
│   │   └── rh-gf-01-local.vhdx                     ⚠️ ainda em C:\ProgramData\ — migração pendente
│   ├── Ubuntu-Clone-Test\
│   │   └── Ubuntu-Clone-Test.vhdx                  ← avaliar remoção
│   ├── VAULT-GEN1\
│   │   └── VAULT-GEN1_03D812D9(...).avhdx           ← diferencial ativo
│   └── PRJ015-PROD-BASE\                            ← primeira VM do PRJ015
│       └── PRJ015-BASE-diff.vhdx                   ← diferencial sobre GD oficial
│
├── GoldenDisks\
│   ├── Win2022-GF\
│   │   ├── Win2022-GF-GEN1.vhdx                    (10.29 GB) ✅ ReadOnly — Legado
│   │   ├── Win2022-GF-GEN2.vhdx                    (13.82 GB) ✅ ReadOnly — ⚠️ Reprovado
│   │   └── Win2022-GF-PURE-V3-GREENFIELD.vhdx      (13.04 GB) ✅ ReadOnly — ✅ OFICIAL
│   └── Ubuntu2404-GF\
│       ├── Ubuntu2404-GF-GEN2.vhdx                 (13.19 GB) ✅ ReadOnly — base
│       ├── Ubuntu2404-GF-GEN2-Clone.vhdx           (6.94 GB)  ✅ ReadOnly — pendente
│       └── Ubuntu2404-GF-GEN2-Greenfield.vhdx      (7.13 GB)  ✅ ReadOnly — candidato
│
└── Scripts\
    └── (procedimentos documentados no POP-GOLDEN-DISK-001)
```

---

## 8. LIÇÕES APRENDIDAS

|ID|Lição|Origem|
|---|---|---|
|L12|Golden Disks GEN2 devem ser criados por clonagem, não instalação via ISO|CONSTRAINT-001|
|L13|Limpeza pós-clonagem requer ordem específica (Tailscale por último, via console)|Ubuntu clone|
|L14|Checkpoints acumulados impactam performance — consolidar antes de clonar|Diagnóstico|
|L15|Manter única pasta de ISOs evita duplicatas e desperdício|Diagnóstico|
|L16|Pre-Flight obrigatório antes de homologar qualquer Golden Disk|GEN2 reprovado em 29/03|
|L17|Remover DHCP → DNS → AD DS antes do Sysprep (nesta ordem)|Sysprep bloqueado no DC|
|L18|Microsoft Edge Stable pode bloquear Sysprep — remover via Appx antes|Erro pós-descomissionamento|
|L19|Usar Convert-VHD (não Merge-VHD) para purificar discos diferenciais|Merge-VHD falhou|
|L20|Após renomear GD mestre, reparar cadeia com Set-VHD -ParentPath|PRJ015-BASE-diff perdeu referência|

---

## 9. PENDÊNCIAS (Não Bloqueantes para o PRJ015)

|#|Item|Prioridade|Ação|
|---|---|---|---|
|P1|Ubuntu GD sem validação cloud-init|Média|Validar `Ubuntu2404-GF-GEN2-Greenfield.vhdx` antes de usar|
|P2|`rh-gf-01-local` fora do padrão de diretório|Baixa|Migrar para `C:\Hyper-V\VMs\rh-gf-01-local\`|
|P3|`Ubuntu-Clone-Test` sem propósito definido|Baixa|Avaliar remoção|
|P4|`Win2022-GF-GEN2.vhdx` reprovado ainda em disco|Baixa|Deletar para liberar 13.82 GB ou manter como histórico|

---

## 10. DOCUMENTOS RELACIONADOS

|Documento|Localização|Descrição|
|---|---|---|
|`TEP-PRJ014 V 1.1`|`_ATIVOS\`|Encerramento formal — versão definitiva|
|`POP-GOLDEN-DISK-001`|`05_BASE-LAB\`|Procedimento operacional de Golden Disks|
|`TAP-PRJ015`|`PRJ015\`|Próximo projeto — IGA Híbrido Local|
|`TAP-PRJ014-IGA-Hibrido`|`_ARQUIVO-MORTO\`|Escopo original supersedido|
|`TAP-PRJ014 - IGA Híbrido - Fase 1`|`_ARQUIVO-MORTO\`|Expansão do TAP original supersedida|
|`TEP-PRJ014 v1.0`|`_ARQUIVO-MORTO\`|Encerramento supersedido pela v1.1|
