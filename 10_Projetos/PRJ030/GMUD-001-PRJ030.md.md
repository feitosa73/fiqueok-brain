
---

## 

# GESTÃO DE MUDANÇA (GMUD) — PRJ030

## Título: Autorização para Backup e Migração POC da Infraestrutura Hyper-V para VMware

---

| Campo | Valor |
|-------|-------|
| **GMUD ID** | GMUD-001/PRJ030 |
| **Projeto** | PRJ030 — Migração Hyper-V → VMware |
| **Data da Solicitação** | 12/05/2026 |
| **Solicitante** | Paulo Feitosa Lima — GRC Lead |
| **Tipo de Mudança** | 🟡 Normal (planejada, com janela de rollback) |
| **Prioridade** | Alta |
| **Janela de Execução** | 12/05/2026 a 16/05/2026 |

---

## 1. DESCRIÇÃO DA MUDANÇA

Executar o **backup completo** das 11 VMs do Hyper-V para HD externo e a **Prova de Conceito (POC) de migração** da VM `SENTINEL-CORE` (PRJ016) para VMware Workstation, validando o procedimento antes da migração em escala.

### 1.1. Atividades Autorizadas

| # | Atividade | Duração | Critério de Sucesso |
|---|-----------|---------|---------------------|
| 1 | Backup de todas as VMs via `Export-VM` | 2-3 horas | Todos os arquivos `.vhdx` copiados |
| 2 | Backup de configurações específicas (Wazuh, Vault) | 30 min | Arquivos `.tar.gz` gerados |
| 3 | Conversão `SENTINEL-CORE` VHDX → VMDK | 30 min | Arquivo `.vmdk` gerado |
| 4 | Importação no VMware Workstation | 15 min | VM boota |
| 5 | Validação dos serviços (Wazuh, Loki, Grafana) | 15 min | 3/3 serviços respondem |

### 1.2. Escopo Excluído (NÃO AUTORIZADO NESTA GMUD)

- Migração de qualquer outra VM além da `SENTINEL-CORE`
- Descomissionamento da VM original no Hyper-V
- Rebuild do AD (`ID-P-01`)

---

## 2. JUSTIFICATIVA

| Fator | Detalhe |
|-------|---------|
| **CONSTRAINT-001** | UEFI corrompido no Hyper-V impede criação/recuperação de VMs GEN2 |
| **FOK-SRV-LDAP-01** | Já perdida em 23/04/2026 (TEP-PRJ014 v1.3) |
| **PRJ016 em execução** | SENTINEL-CORE é crítico para o ITDR do laboratório |
| **Risco de novas perdas** | Qualquer VM GEN2 pode falhar a qualquer momento |

---

## 3. ANÁLISE DE IMPACTO

### 3.1. Impacto em Caso de Sucesso

| Área | Impacto |
|------|---------|
| Disponibilidade | Laboratório operacional durante backup (Export-VM não trava VMs) |
| Segurança | Backup em HD externo (criptografia não aplicada — risco baixo) |
| PRJ016 | POC valida que o SENTINEL-CORE migra com sucesso |

### 3.2. Impacto em Caso de Falha (e Rollback)

| Cenário | Probabilidade | Ação de Rollback |
|---------|--------------|------------------|
| Backup corrompido | Baixa | Refazer Export-VM |
| SENTINEL-CORE não boota no VMware | Média | Restaurar snapshot Hyper-V original |
| Tailscale quebra | Baixa | `tailscale up` com parâmetros originais |

---

## 4. PLANO DE ROLLBACK

### 4.1. Rollback do Backup

powershell
# Nenhuma ação necessária — backup é cópia, não move


#4.2. Rollback da POC (SENTINEL-CORE)

powershell

# 1. Desligar VM no VMware
# 2. Remover do inventário
# 3. Descartar arquivos .vmdk
# 4. Manter VM original no Hyper-V

---

## 5. APROVAÇÕES

|Função|Nome|Data|Voto|Assinatura|
|---|---|---|---|---|
|Solicitante|Paulo Feitosa Lima|12/05/2026|✅ Aprova|—|
|GRC Lead|Paulo Feitosa Lima|12/05/2026|✅ Aprova|—|
|Patrocinador|Paulo Feitosa Lima|12/05/2026|✅ Aprova|—|

---

## 6. REGISTRO DE EXECUÇÃO (A SER PREENCHIDO APÓS A GMUD)

|Campo|Valor|
|---|---|
|Data de execução|_____________|
|Backup concluído (S/N)|_____________|
|Backup size (GB)|_____________|
|POC SENTINEL-CORE (S/N)|_____________|
|Serviços validados (3/3)|_____________|
|Rollback necessário (S/N)|_____________|
|Responsável|_____________|

---

**FIM DA GMUD-001/PRJ030**ginal permanece no Hyper-V
