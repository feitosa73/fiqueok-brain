# TERMO DE ENCERRAMENTO DO PROJETO — PRJ015 (VERSÃO REAL)

| Campo | Valor |
|-------|-------|
| **Código** | TEP-PRJ015 |
| **Versão** | 2.0 (Revisão Final) |
| **Data** | 01/04/2026 |
| **Responsável** | Paulo Feitosa Lima — GRC Lead / Especialista IAM |
| **Projeto** | PRJ015 — IGA Híbrido Local (AD → Entra Cloud Sync) |
| **Status Final** | ⚠️ ENCERRADO COM APRENDIZADO — Sincronização não alcançada por falha arquitetural; decisão de recriar tenant com modelo correto |
| **Classificação** | Confidencial Interno — Lab Fiqueok |

---

## 1. CHANGELOG

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 31/03/2026 | Paulo Feitosa Lima | Criação inicial (otimista — baseada em critérios de sucesso prematuros) |
| 2.0 | 01/04/2026 | Paulo Feitosa Lima | Revisão com realidade, causa raiz, lições aprendidas e decisão de reinício |

---

## 2. EXECUÇÃO DO PROJETO — REALIDADE

### 2.1. Resumo Executivo

O projeto foi executado entre **30/03/2026 e 01/04/2026**, com duração total de **3 dias**.

A execução enfrentou desafios técnicos significativos, mas o principal obstáculo foi de natureza **arquitetural**: a tentativa de sincronizar um AD on-premises com um Entra ID que já continha os mesmos usuários criados previamente (cloud-first) revelou um conflito estrutural que não pôde ser resolvido com ferramentas de sync.

**Decisão final:** Encerrar o projeto com documentação das lições aprendidas e recriar o tenant do zero adotando o modelo **sync-first**, onde o AD é a única fonte de verdade.

> **Nota sobre suporte externo:** As ferramentas de IA utilizadas como suporte técnico ao longo da execução focaram em resolução de sintomas (zombie objects, ImmutableId, proxyAddresses) sem identificar a falha arquitetural subjacente. Essa abordagem de "resolução reativa" contribuiu para o agravamento do estado do tenant, transformando um problema simples de governança em um conjunto de conflitos técnicos de difícil reversão.

### 2.2. Fases Executadas

| Fase | Atividade | Duração Real | Status |
|------|-----------|--------------|--------|
| F0 | Validação do AD | 1h | ✅ |
| F1 | Criação VM SYNC-01 | 1h | ✅ |
| F2 | Instalação Cloud Sync Agent | 2h | ✅ |
| F3 | Configuração sincronização | 3h | ✅ |
| F4 | Tentativas de validação | 8h | ❌ FALHOU |
| F5 | Análise de causa raiz | 2h | ✅ |
| F6 | Documentação de lições | 2h | ✅ |

---

## 3. O QUE DEU ERRADO — CAUSA RAIZ

### 3.1. Cenário Original

| Componente | Estado |
|------------|--------|
| **AD** | 100 usuários com EmployeeID, UPN, mail preenchidos |
| **Entra ID** | 100 usuários com os mesmos UPNs, criados anteriormente (cloud-only) |
| **Objetivo** | Sincronizar AD → Entra mantendo os objetos existentes |

### 3.2. Problemas Enfrentados

| Problema | Impacto |
|----------|---------|
| Conflito de proxyAddresses | Objetos duplicados no Entra impediam o soft-match |
| OnPremisesImmutableId residual | Bloqueava o hard-match |
| Objetos "zumbis" na lixeira | Continuavam indexados, causando conflitos invisíveis |
| Soft-match falhou sistematicamente | O Entra ID não vinculou os objetos do AD aos existentes |

### 3.3. Causa Raiz

**O Entra ID não foi projetado para "começar cloud-only e depois decidir sincronizar".**

O modelo híbrido saudável exige que a **fonte de verdade seja definida antes da criação dos objetos**. Quando os objetos já existem em ambos os lados sem um vínculo claro, a reconciliação via Cloud Sync se torna inviável — especialmente quando há objetos na lixeira ou atributos residuais.

> **Princípio violado:** Single Source of Truth (SSoT). Ao popular o Entra ID diretamente (com urgência, fora de qualquer plano de sincronização), criou-se uma segunda fonte autoritativa paralela ao AD. A partir desse momento, qualquer tentativa de sync resultaria em duplicação ou conflito — não por falha técnica, mas por falha de arquitetura de identidade.

---

## 4. LIÇÕES APRENDIDAS (ATIVO PERMANENTE)

| ID | Lição | Origem | Aplicação Futura |
|----|-------|--------|------------------|
| L27 | Defina a fonte de verdade antes de criar qualquer usuário | Experiência PRJ015 | Em qualquer projeto de IAM híbrido, definir se a fonte será AD (sync-first) ou Entra (cloud-first) antes da primeira criação |
| L28 | Nunca crie usuários no Entra que serão sincronizados depois | PRJ015 | Sync-first: AD cria → Entra espelha. Cloud-first: Entra cria → AD não existe ou é periférico |
| L29 | Objetos deletados (soft-delete) continuam ocupando namespace | PRJ015 | Purgue objetos permanentemente quando houver conflito de proxyAddresses; soft-delete não libera o endereço |
| L30 | O Graph Explorer e o portal Entra enxergam menos que o backend | PRJ015 | Para limpeza profunda, use az rest ou API direta; objetos zumbis podem ser invisíveis para o portal mas ativos para o Cloud Sync |
| L31 | O Provision on Demand é o melhor teste, mas não é suficiente | PRJ015 | Testar com piloto antes da sincronização em massa; falha no piloto indica problema estrutural, não pontual |
| L32 | Deletar e recriar não é falha — é decisão estratégica | PRJ015 | Quando o custo de limpeza supera o benefício, recriar o ambiente limpo é a escolha certa, especialmente em laboratório |
| L33 | Ferramentas de IA resolvem sintomas, não causas | PRJ015 | Antes de seguir qualquer orientação técnica de IA, validar se a causa raiz foi identificada; orientações reativas podem agravar o problema |

---

## 5. DECISÃO DE ENCERRAMENTO

### 5.1. Opções Avaliadas

| Opção | Viabilidade | Risco |
|-------|-------------|-------|
| A — Continuar tentando limpar | Baixa | Alto — objetos zumbis não totalmente visíveis; incerteza permanente |
| B — Purgar todos os cloud-only e tentar sync | Média | Médio — lixeira poderia manter conflitos residuais |
| C — Recriar tenant do zero com sync-first | Alta | Zero — ambiente novo, arquitetura correta, aprendizado consolidado |

### 5.2. Decisão

**Adotar Opção C — Recriar tenant do zero adotando o modelo sync-first.**

**Justificativa:**

- Tenant de laboratório, sem dados reais, sem licenças pagas
- Custo de recriar é zero
- Custo de continuar tentando limpar é tempo perdido sem garantia de sucesso
- O aprendizado obtido vale mais que qualquer "check" falso no projeto

---

## 6. PRÓXIMOS PASSOS — RECOMEÇO COM SYNC-FIRST

| Etapa | Ação | Responsável |
|-------|------|-------------|
| 1 | Criar novo tenant Entra ID (ou deletar e recriar o existente) | Paulo |
| 2 | Garantir AD com 100 usuários, EmployeeID único, atributos corretos | Paulo |
| 3 | Criar VM SYNC-01 (já existe — validar estado) | Paulo |
| 4 | Instalar Cloud Sync Agent | Paulo |
| 5 | Configurar sincronização com EmployeeID como âncora | Paulo |
| 6 | **Ligar sync ANTES de criar qualquer usuário manual no Entra** | Paulo |
| 7 | Validar os 100 usuários sincronizados | Paulo |
| 8 | Documentar POP-IAM-005 com fluxo sync-first | Paulo |

---

## 7. ENTREGÁVEIS REALIZADOS

| ID | Entregável | Status | Observação |
|----|------------|--------|------------|
| E1 | Relatório de validação do AD | ✅ | 100 usuários com EmployeeID único confirmados |
| E2 | VM SYNC-01 criada | ✅ | GEN2, disco diferencial, Cloud Sync Agent instalado |
| E3 | Evidências de instalação do Cloud Sync | ✅ | Screenshots e logs coletados durante execução |
| E4 | Evidências das tentativas de sincronização | ✅ | Incluem erros, conflitos e diagnósticos — valor de auditoria |
| E5 | Diagnóstico de causa raiz | ✅ | Documentado neste TEP, seção 3 |
| E6 | Lições aprendidas documentadas (L27–L33) | ✅ | Documentado neste TEP, seção 4 |
| E7 | Decisão de reinício estratégico | ✅ | Documentado neste TEP, seção 5 |
| E8 | POP-IAM-005 (sync-first) | 📋 Pendente | A ser criado no recomeço com o modelo correto |

---

## 8. APROVAÇÕES

| Função | Nome | Data | Status |
|--------|------|------|:------:|
| GRC Lead / Responsável Técnico | Paulo Feitosa Lima | 01/04/2026 | ✅ APROVADO |
| GRC Advisor | DeepSeek | 01/04/2026 | ✅ REVISADO |
| FinOps / Custo | Paulo Feitosa Lima | 01/04/2026 | ✅ ZERO CUSTO |

---

## 9. DECLARAÇÃO DE ENCERRAMENTO

Declaro que o projeto **PRJ015 — IGA Híbrido Local (AD → Entra Cloud Sync)** não atingiu o objetivo operacional de sincronizar 100 usuários no modelo inicial, mas gerou valor estratégico permanente:

- Identificou os limites do modelo híbrido com criação prévia de objetos no Entra ID
- Validou na prática o princípio de **Single Source of Truth como pré-requisito de qualquer integração de identidade**
- Documentou um conjunto de lições sobre governança de identidade aplicáveis a cenários reais de empresas em migração para Microsoft 365
- Estabeleceu a decisão correta para o recomeço: **sync-first, AD como fonte autoritativa**
- Registrou o risco de uso de ferramentas de IA como suporte técnico sem validação da causa raiz

O projeto é encerrado como **laboratório de aprendizado**, servindo como referência para futuras implementações de IAM híbrido — tanto no Living Lab Fiqueok quanto em engajamentos com clientes.

O ambiente será recriado com a arquitetura correta no contexto do **PRJ016 — midPoint como motor IGA On-Premise**, que sucede este projeto com a identidade já saneada.

---

**FIM DO TEP-PRJ015 v2.0**

---

*Documento mantido por Paulo Feitosa Lima — Living Lab Fiqueok*
*Próxima revisão: Não aplicável (projeto encerrado para recomeço)*
