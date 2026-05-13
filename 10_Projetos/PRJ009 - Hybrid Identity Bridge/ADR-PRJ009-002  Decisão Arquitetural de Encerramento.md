# 

|Campo|Valor|
|---|---|
|**Documento**|ADR-PRJ009-002|
|**Versão**|1.0|
|**Data**|26/03/2026|
|**Autor**|Paulo Feitosa Lima — GRC Lead|
|**Status**|APROVADO|
|**Contexto**|Encerramento do PRJ009 e pivotagem para PRJ014|
|**Decisão**|Desprovisionar VM Azure e mover inteligência para borda|
|**Supercede**|ADR-PRJ009-001 (início do projeto)|

---

## 1. CONTEXTO

O **ADR-PRJ009-001** (26/02/2026) documentou a decisão de iniciar o PRJ009 como um experimento de 7 dias para validar a conectividade híbrida entre OrangeHRM em PaaS (Azure) e midPoint local, utilizando uma VM Gateway como ponte.

Durante a execução, o projeto alcançou:

- SSH Certificate Authority com Vault funcional
    
- Tailscale mesh consolidado
    
- Validação do conceito de identidade rastreável
    

No entanto, dois fatores externos impactaram a continuidade:

1. **Expiração dos créditos da subscrição Azure** — risco de custo residual
    
2. **Surgimento de demanda externa (DPSP)** — que justificava aprendizado em Microsoft Entra Cloud Sync
    

---

## 2. DECISÃO ESTRATÉGICA

**Decisão:** Desprovisionar a VM `fiqueok-prj009-gtw-canada` e encerrar formalmente o PRJ009, transferindo a inteligência de sincronização para a borda (on-premise) no novo projeto PRJ014.

**Justificativa:**

- **Custo:** Manter a VM ativa com recursos próprios geraria custo desnecessário
    
- **Alinhamento:** O aprendizado em Cloud Sync atende à demanda externa (DPSP) de forma mais direta
    
- **Arquitetura:** A estratégia de "identidade híbrida com gateway na nuvem" é substituída por "identidade híbrida com sincronização na borda"
    
- **Preservação:** Os ativos conceituais do PRJ009 (SSH CA, Vault, Tailscale) são preservados e reutilizáveis
    

---

## 3. ALTERNATIVAS CONSIDERADAS

|Alternativa|Vantagens|Desvantagens|Decisão|
|---|---|---|---|
|Migrar VM para Home Lab|Preserva o ativo físico|Perde Managed Identity, integração nativa com Azure|❌ REJEITADA|
|Manter VM com recursos próprios|Continua o experimento|Custo financeiro, sem alinhamento com demanda atual|❌ REJEITADA|
|Encerrar e documentar|Zero custo, aprendizado preservado|Perda da infraestrutura em nuvem|✅ ESCOLHIDA|

---

## 4. IMPACTO NOS ARTEFATOS EXISTENTES

|Artefato|Impacto|Ação|
|---|---|---|
|POP-SSH-CA-PRJ009-v3.0|Nenhum|Preservado como referência|
|Tailscale mesh|Nenhum|Mantido como backbone de conectividade local|
|Logs e evidências|Nenhum|Preservados no Obsidian|
|VM Azure|Destruída|Desprovisionada|

---

## 5. DECISÃO FORMAL

**STATUS:** APROVADA  
**DATA:** 26/03/2026  
**PRÓXIMA AÇÃO:** Início do PRJ014 — IGA Híbrido Local

---

**FIM DO ADR-PRJ009-002 v1.0**
