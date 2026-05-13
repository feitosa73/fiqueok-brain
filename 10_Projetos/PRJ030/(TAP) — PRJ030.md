# TERMO DE ABERTURA DO PROJETO (TAP) — PRJ030

## Migração da Infraestrutura Hyper-V para VMware Workstation

---

| Campo | Valor |
|-------|-------|
| **Código** | PRJ030 |
| **Nome** | Migração da Infraestrutura Hyper-V para VMware Workstation |
| **Versão** | 1.0 |
| **Data** | 12/05/2026 |
| **Responsável** | Paulo Feitosa Lima — GRC Lead |
| **Patrocinador** | Living Lab Fiqueok |
| **Status** | 📝 EM PLANEJAMENTO — Aguardando GMUD-001 |
| **Predecessores** | PRJ014 (Saneamento Hyper-V), PRJ016, PRJ020 |
| **Sucessor** | N/A (projeto de infraestrutura) |

---

## 1. JUSTIFICATIVA ESTRATÉGICA

### 1.1. Por que migrar do Hyper-V para o VMware?

| Problema | Impacto | Solução VMware |
|----------|---------|----------------|
| **CONSTRAINT-001** — UEFI corrompido no Hyper-V | Impossível criar/carregar VMs GEN2 novas ou recuperar existentes (FOK-SRV-LDAP-01 já perdida) | VMware Workstation não sofre do mesmo problema |
| **Checkpoints acumulados** | Risco de corrupção e degradação de performance | Estrutura de snapshots do VMware é mais robusta |
| **ISOs duplicadas e desorganização** | 6.3 GB desperdiçados, gestão difícil | Padronização durante a migração |
| **Golden Disks GEN2 reprovados** | Win2022-GF-GEN2.vhdx inapto para uso como template | Recriar templates limpos no VMware |

### 1.2. Alinhamento com Projetos Anteriores

| Projeto | Relação com PRJ030 |
|---------|---------------------|
| PRJ014 | Forneceu a base saneada do Hyper-V (Golden Disks, estrutura de pastas) |
| PRJ016 (Sentinel Shield) | **Crítico** — SENTINEL-CORE é o cérebro do ITDR; migração não pode quebrá-lo |
| PRJ020 (Vulnerabilidades) | DefectDojo (100 GB) e Kali GVM (80 GB) são ativos do PROJ020 |

---

## 2. ESCOPO

### 2.1. Incluído

| Item | Detalhe |
|------|---------|
| **Planejamento e Governança** | TAP, POP, GMUD-001 |
| **Pre-Flight** | ✅ Já executado (11 VMs, 600 GB) |
| **Backup completo** | Para HD externo (via `Export-VM`) |
| **Conversão VHDX → VMDK** | Via StarWind V2V Converter ou qemu-img |
| **Reconstrução da VM AD** | `ID-P-01` será recriada (não migrada) |
| **Validação pós-migração** | Testes de conectividade Tailscale, serviços críticos |
| **Documentação** | TEP-PRJ030, Lições aprendidas, "Caminho Feliz" |

### 2.2. Excluído

| Item | Motivo |
|------|--------|
| Migração do `FOK-SRV-LDAP-01` | Já removida (TEP-PRJ014 v1.3) |
| Migração do `Win2022-GF-GEN2.vhdx` | Reprovado no Pre-Flight (ParentPath detectado) |
| Reinstalação do Windows Host | Fora do escopo (CONSTRAINT-001 será tratada separadamente) |
| Provisionamento de novas VMs | Escopo apenas de migração |

---

## 3. INVENTÁRIO DE ATIVOS (BASEADO NO PRE-FLIGHT)

| VM | Projeto | Tamanho | Gen | Trilha |
|----|---------|---------|-----|--------|
| SENTINEL-CORE | PRJ016 | 80 GB | 1 | 🟢 Verde |
| VAULT-GEN1 | PRJ007 | 20 GB | 1 | 🟢 Verde |
| defectdojo-gf-01 | PROJ020 | 100 GB | 1 | 🟢 Verde |
| api-gf-01 | PRJ008 | 40 GB | 1 | 🟢 Verde |
| Linux Lite | PRJ017 | 40 GB | 1 | 🟢 Verde |
| SYNC-01 | PRJ015 | 60 GB | 2 | 🟡 Amarela |
| sec-openvas-kali | PROJ020 | 80 GB | 2 | 🟡 Amarela |
| rh-gf-01-local | PRJ005 | 40 GB | 2 | 🟡 Amarela |
| IGA-GF-02 | PRJ022-024 | 20 GB | 2 | 🟡 Amarela |
| PRJ015-PROD-BASE | PRJ015 | 60 GB | 2 | 🟡 Amarela |
| ID-P-01 | PRJ002/012 | 60 GB | 2 | 🔴 Vermelha |

**Total: 600 GB**

---

## 4. TRILHAS DE MIGRAÇÃO

| Trilha | Método | Aplicável | Risco |
|--------|--------|-----------|-------|
| 🟢 **Verde** | Export-VM + conversão direta VHDX → VMDK | VMs GEN1 (6 VMs, 340 GB) | Baixo |
| 🟡 **Amarela** | Conversão assistida por agente (StarWind V2V Agent) | VMs GEN2 funcionais (5 VMs, 260 GB) | Médio |
| 🔴 **Vermelha** | Rebuild limpo + restore de dados | `ID-P-01` (AD DS) | Alto (planejado) |

---

## 5. CRONOGRAMA ESTIMADO

| Fase | Atividade | Duração | Responsável |
|------|-----------|---------|-------------|
| **Governança** | TAP, POP, GMUD-001 | 1 dia | Paulo |
| **Preparação** | Backup para HD externo | 2-3 horas | Paulo |
| **Validação** | Conversão SENTINEL-CORE (POC) | 2 horas | Paulo |
| **Execução F1** | VMs Verdes (6 VMs) | 4 horas | Paulo |
| **Execução F2** | VMs Amarelas (5 VMs) | 4 horas | Paulo |
| **Execução F3** | Rebuild do AD | 2 horas | Paulo |
| **Encerramento** | TEP, lições, POP final | 1 dia | Paulo |

**Total estimado: 3-4 dias**

---

## 6. RISCOS E MITIGAÇÕES

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| **SENTINEL-CORE não boota no VMware** | Média | 🔴 Crítico | Converter primeiro como POC; manter backup |
| **Perda de dados durante conversão** | Baixa | 🔴 Crítico | Backup completo antes + snapshots Hyper-V |
| **VM GEN2 com UEFI corrompido falha** | Alta | 🟡 Médio | Rebuild documentado para AD; outras tentam agente |
| **Tailscale quebra pós-migração** | Média | 🟡 Médio | Testar conectividade imediatamente após cada VM |
| **Espaço em disco insuficiente no destino** | Baixa | 🟡 Médio | VMware em HD diferente (verificar antes) |

---

## 7. CRITÉRIOS DE ACEITE

| # | Critério | Métrica |
|---|----------|---------|
| CA-01 | Todas as VMs Verdes (GEN1) migradas com sucesso | 6/6 VMs bootam no VMware |
| CA-02 | SENTINEL-CORE mantém funcionalidade | Wazuh, Loki, Grafana respondem |
| CA-03 | Vault mantém selo e segredos | `vault status` mostra selado (aguardando unseal) |
| CA-04 | Conectividade Tailscale preservada | `tailscale status` mostra todos os nós |
| CA-05 | AD recriado e funcional | Usuários autenticam, GPOs aplicadas |
| CA-06 | Documentação concluída | TEP + POP final + "Caminho Feliz" |

---

## 8. APROVAÇÕES

| Função | Nome | Data | Status |
|--------|------|------|--------|
| GRC Lead | Paulo Feitosa Lima | 12/05/2026 | ✅ APROVADO |
| Patrocinador | Paulo Feitosa Lima | 12/05/2026 | ✅ APROVADO |

---

**Próximo passo:** GMUD-001/PRJ030 para autorizar a execução do backup e da conversão POC.

---
