# 

---

# TERMO DE ENCERRAMENTO DO PROJETO

|Campo|Valor|
|---|---|
|**Código**|TEP-PRJ009|
|**Versão**|1.0|
|**Data**|26/03/2026|
|**Responsável**|Paulo Feitosa Lima — GRC Lead|
|**Projeto**|PRJ009 — Hybrid Identity Bridge|
|**Status Final**|⚠️ **ENCERRADO / ESTRATÉGIA DESCONTINUADA**|
|**Classificação**|Confidencial Interno — Lab Fiqueok|

---

## 1. CHANGELOG

|Versão|Data|Autor|Mudanças|
|---|---|---|---|
|1.0|26/03/2026|Paulo Feitosa Lima|Criação — Encerramento formal do PRJ009|

---

## 2. IDENTIFICAÇÃO DO PROJETO

|Campo|Valor|
|---|---|
|**Código**|PRJ009|
|**Nome**|Hybrid Identity Bridge — OrangeHRM Azure PaaS → midPoint Local|
|**Categoria**|Cloud Hybrid IGA / AZ-305 Lab|
|**Patrocinador**|Paulo Feitosa Lima|
|**Data de Início**|26/02/2026|
|**Data de Encerramento**|26/03/2026|
|**Duração Planejada**|7 dias (experimento)|
|**Duração Real**|~30 dias (com interrupções)|
|**Referência TAP**|TAP-PRJ009-v1.0|
|**Referência ADR**|ADR-PRJ009-001 (início)|
|**Sucessor**|PRJ014 — IGA Híbrido Local|

---

## 3. RESUMO EXECUTIVO

O PRJ009 foi iniciado como um **experimento de arquitetura híbrida** com o objetivo de validar a conectividade entre o OrangeHRM em PaaS (Azure) e o midPoint local, utilizando uma VM Gateway como ponte de identidade.

Durante sua execução, o projeto atingiu marcos importantes:

- ✅ SSH Certificate Authority com HashiCorp Vault implementada e documentada (POP-SSH-CA-PRJ009-v3.0)
    
- ✅ Validação do conceito de identidade rastreável com personas (laszlo.bock)
    
- ✅ Tailscale mesh consolidado como backbone de conectividade
    

No entanto, devido à **expiração dos créditos da subscrição Azure** e ao surgimento de uma **demanda externa real (DPSP)** que justificava o aprendizado de Microsoft Entra Cloud Sync, a decisão estratégica foi de **encerrar o PRJ009** e desprovisionar a infraestrutura de nuvem (VM fiqueok-prj009-gtw-canada), transferindo a inteligência de sincronização para a borda (on-premise).

A decisão foi documentada formalmente no **ADR-PRJ009-002**.

O projeto é encerrado com **status de sucesso conceitual**, mas **não entregou a integração híbrida end-to-end originalmente planejada**. Os ativos gerados (documentação, scripts, lições aprendidas) são preservados e serão reutilizados no PRJ014.

---

## 4. OBJETIVOS — STATUS FINAL

|ID|Objetivo|Status|Observação|
|---|---|---|---|
|OS1|Provisionar infra Azure Zero Custo (VM B1s Gateway + App Service F1)|✅ CONCLUÍDO|VM criada e operacional|
|OS2|Migrar OrangeHRM → Azure PaaS com conectividade híbrida|⚠️ PARCIAL|Migração não concluída — foco redirecionado|
|OS3|Evoluir Shadow API (Local → Azure Managed Identity + Key Vault)|⚠️ PARCIAL|Conceito validado, mas não implementado em produção|
|OS4|Validar ciclo JML end-to-end via tailscale0|❌ NÃO CONCLUÍDO|Pendente da integração híbrida completa|

---

## 5. ENTREGÁVEIS REALIZADOS

|ID|Entregável|Localização|Status|
|---|---|---|---|
|E1|TAP-PRJ009-v1.0|Obsidian / PRJ009|✅ ENTREGUE|
|E2|ADR-PRJ009-001|Obsidian / PRJ009|✅ ENTREGUE|
|E3|POP-SSH-CA-PRJ009-v3.0|Obsidian / PRJ009|✅ ENTREGUE|
|E4|VM Azure fiqueok-prj009-gtw-canada|Azure Portal|⚠️ DESPROVISIONADA|
|E5|Relatório de evidências (auth.log, Vault audit)|Obsidian / Evidências|✅ ENTREGUE|
|E6|ADR-PRJ009-002 (este ciclo)|Obsidian / PRJ009|✅ ENTREGUE|

---

## 6. DECISÃO DE ENCERRAMENTO

### 6.1. Contexto da Decisão

|Fator|Descrição|
|---|---|
|**Créditos Azure**|Subscrição de avaliação expirando — risco de custo residual|
|**Demanda Externa**|Surgimento de projeto DPSP com necessidade de aprendizado em Cloud Sync|
|**Arquitetura**|Decisão de mover inteligência para borda (on-premise) em vez de manter gateway na nuvem|
|**Custo de Oportunidade**|Manter a VM ativa consumiria tempo e recursos sem alinhamento com os objetivos atuais do Living Lab|

### 6.2. Decisão Formalizada

**Data da Decisão:** 26/03/2026  
**Responsável:** Paulo Feitosa Lima — GRC Lead  
**Decisão:** Desprovisionar a VM Azure e encerrar formalmente o PRJ009

**Alternativas Consideradas:**

1. **Migrar a VM para o Home Lab** — Descartada porque perderia Managed Identity e integração nativa com Azure
    
2. **Manter a VM com recursos próprios** — Descartada por custo financeiro desnecessário
    
3. **Encerrar e documentar** — **ESCOLHIDA**
    

---

## 7. ATIVOS PRESERVADOS

Os seguintes ativos do PRJ009 permanecem disponíveis e serão reutilizados:

|Ativo|Reutilização no PRJ014|
|---|---|
|POP-SSH-CA-PRJ009-v3.0|Conceito de certificados SSH mantido|
|Documentação Tailscale|Topologia de rede mantida|
|Lições aprendidas (L01–L08)|Incorporadas ao POP-IAM-002|
|Personas de identidade|Mantidas para cenários de teste|

---

## 8. LIÇÕES APRENDIDAS

|ID|Lição|Origem|
|---|---|---|
|L09|Projetos híbridos com componentes pagos devem ter plano de continuidade financeira claro|PRJ009|
|L10|O custo de oportunidade de manter infraestrutura não utilizada supera o valor do aprendizado marginal|PRJ009|
|L11|Documentar a decisão de abortar é tão importante quanto documentar sucessos|PRJ009|

---

## 9. CRONOGRAMA REAL

|Fase|Período|Duração|Status|
|---|---|---|---|
|Fase 0 — Pre-Flight|26-27/02/2026|2 dias|✅ CONCLUÍDA|
|Fase 1 — Design e Governança|28-30/02/2026|3 dias|✅ CONCLUÍDA|
|Fase 2 — Desenvolvimento|01-03/03/2026|3 dias|⚠️ PARCIAL|
|Fase 3 — Integração e Testes|04-06/03/2026|3 dias|❌ NÃO CONCLUÍDA|
|**Encerramento**|26/03/2026|1 dia|✅ CONCLUÍDO|

---

## 10. CHECKLIST DE ENCERRAMENTO

|#|Verificação|Status|
|---|---|---|
|1|Todos os artefatos documentados no Obsidian|✅ OK|
|2|VM Azure desprovisionada|✅ OK|
|3|Snapshots preservados (se aplicável)|✅ N/A|
|4|Lições aprendidas registradas|✅ OK|
|5|Sucessor formal identificado (PRJ014)|✅ OK|
|6|Documento de encerramento aprovado|✅ OK|

---

## 11. APROVAÇÕES

|Função|Nome|Data|Status|
|---|---|---|---|
|GRC Lead / Responsável|Paulo Feitosa Lima|26/03/2026|✅ APROVADO|
|GRC Advisor|Perplexity AI|26/03/2026|✅ REVISADO|

---

**FIM DO TEP-PRJ009 v1.0**
