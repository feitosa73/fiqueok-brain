## 📝 

---

| Campo | Valor |
|-------|-------|
| **Código do Relatório** | REL-PRJ012-v2.0 |
| **Projeto** | PRJ012 — Orquestração de Identidades (midPoint → Microsoft Entra ID) |
| **Data de Execução Original** | 06/03/2026 a 10/03/2026 |
| **Data de Reavaliação** | 08/05/2026 |
| **Responsável Técnico** | Paulo Feitosa Lima — GRC Lead / Especialista IAM |
| **Ambiente** | Living Lab Fiqueok — Tenant `fiqueok.com.br` (Tier Free) |
| **Status do Projeto** | **✅ ENCERRADO COM SUCESSO PARCIAL** |
| **Referência TAP** | TAP-PRJ012 v1.1 |
| **Projeto Sucessor** | PRJ027 (Retomada da Conexão e Expansão de Governança) |

---

## 1. Resumo Executivo

O **PRJ012** foi executado originalmente em março de 2026 com o objetivo de estabelecer a fundação de conectividade entre o midPoint e o Microsoft Entra ID, incluindo a criação do App Registration, configuração do conector Graph API, importação de 100 usuários como shadows e validação do fluxo de reconciliação.

Durante a execução do **PRJ027** (Integração midPoint → Entra ID com Governança), foi realizada uma **forense completa do ambiente** em 08/05/2026, que identificou o estado real dos artefatos deixados pelo PRJ012.

---

## 2. Estado dos Artefatos — Forense Realizada em 08/05/2026

### 2.1. Componentes no Microsoft Entra ID (Cloud)

| Artefato | Status | Evidência |
|----------|--------|-----------|
| **App Registration `midpoint-iga-connector`** | ✅ **PRESERVADO** | Portal Azure — Client ID `6df1b421-cf53-41c4-b4aa-9a5d50f65148` |
| **Tenant ID** | ✅ **PRESERVADO** | `503bbd0e-f33f-4ebe-b12e-f24a506978c9` |
| **Client Secret** | ❌ **INVÁLIDO** | Teste de token retornou HTTP 401 — Não Autorizado |
| **Permissões Graph** | ⚠️ **PARCIALMENTE PRESERVADAS** | `Directory.Read.All`, `Group.ReadWrite.All`, `User.ReadWrite.All` |

### 2.2. Componentes no midPoint (IGA-GF-02)

| Artefato | Status Original (PRJ012 ATO 2) | Status Atual (Forense 08/05/2026) |
|----------|-------------------------------|-----------------------------------|
| **Conector Graph API** | ✅ Instalado | ❌ **AUSENTE** — não listado no diretório `icf-connectors/` |
| **Resource Entra ID** | ✅ Criado | ❌ **AUSENTE** — não encontrado na API de resources |
| **Shadows dos usuários** | ✅ 100 shadows importados | ❌ **0 shadows** — API retornou vazio |
| **Usuários FP001-FP012** | ✅ Existentes | ❌ **AUSENTES** — API retornou erro |

### 2.3. Componentes no HashiCorp Vault (vault-gf-01)

| Artefato | Status |
|----------|--------|
| **Path `secret/prj012/entra-connector`** | ✅ **PRESERVADO** |
| **Client ID armazenado** | ✅ `6df1b421-cf53-41c4-b4aa-9a5d50f65148` |
| **Client Secret armazenado** | ⚠️ **PRESERVADO MAS INVÁLIDO** (mesmo valor que falhou no teste) |

---

## 3. Análise de Discrepâncias

### 3.1. O que foi PRESERVADO (Consistente com o TAP)

| Item | Alinhamento com TAP |
|------|---------------------|
| App Registration no Entra ID | ✅ Totalmente alinhado |
| Client ID e Tenant ID | ✅ Corretos e utilizáveis |
| Permissões base (`User.ReadWrite.All`) | ✅ Presente |
| Vault path com credenciais | ✅ Estrutura preservada |

### 3.2. O que foi PERDIDO (Inconsistente com o TAP)

| Item | Causa Provável | Impacto |
|------|----------------|---------|
| Conector Graph no midPoint | Rollback de snapshot do container midPoint (pós-PRJ012) | ❌ Impede conexão imediata |
| Resource Entra ID | Deletado durante limpeza ou restore | ❌ Impede reconciliação |
| Shadows (100 usuários) | Perdidos no mesmo rollback | ❌ Perda do baseline |
| Usuários FP001-FP012 | Não foram recriados após restore | ❌ Sem identidades para teste |
| Client Secret | Revogado ou regenerado sem atualizar Vault | ❌ Autenticação falha |

### 3.3. Diagnóstico da Causa Raiz

A análise forense indica que **o container do midPoint (`IGA-GF-02`) foi restaurado a partir de um snapshot anterior à conclusão do PRJ012** em algum momento entre março e maio de 2026.

**Evidências que sustentam esta conclusão:**

1. O App Registration no Entra ID permanece intacto (está na nuvem, fora do escopo do snapshot)
2. O Vault manteve o secret (também independente do snapshot)
3. Todos os artefatos **dentro do midPoint** (conector, resource, shadows, usuários) foram perdidos

---

## 4. Avaliação de Sucesso vs. TAP-PRJ012

### 4.1. Critérios de Sucesso do TAP-PRJ012

| ID | Critério | Status | Justificativa |
|----|----------|--------|----------------|
| OBJ-01 | App Registration com permissões corretas | ✅ **ATINGIDO** | App existe, permissões base presentes |
| OBJ-02 | Conector midPoint → Entra ID via Graph API | ❌ **NÃO ATINGIDO** | Conector não está mais instalado |
| OBJ-03 | Reconciliação de leitura (Dry Run) | ❌ **NÃO ATINGIDO** | Resource não existe mais |
| OBJ-04 | Mapeamento `EmployeeID` como âncora | ❌ **NÃO ATINGIDO** | Correlation rule perdida |
| OBJ-05 | Conector OrangeHRM → midPoint | ⚠️ **FORA DO ESCOPO** | ATO 3 não foi executado |
| OBJ-06 | RBAC por Department | ⚠️ **FORA DO ESCOPO** | ATO 3 não foi executado |
| OBJ-07 | Ciclo JML básico | ⚠️ **FORA DO ESCOPO** | ATO 3 não foi executado |

### 4.2. Status Final

| Aspecto | Avaliação |
|---------|-----------|
| **Entregáveis na nuvem (Entra ID)** | ✅ **100% PRESERVADOS** |
| **Entregáveis no midPoint** | ❌ **0% PRESERVADOS** |
| **Entregáveis no Vault** | ✅ **100% PRESERVADOS** (secret inválido, mas estrutura OK) |

---

## 5. Decisão de Encerramento

### ✅ **PRJ012 ENCERRADO COM SUCESSO PARCIAL**

**Justificativa:**

1. **A FASE 1 (ATO 1)** — Fundação de Conectividade Azure — foi **100% bem-sucedida e permanece válida**:
   - App Registration criado e preservado
   - Permissões base concedidas
   - Estrutura de armazenamento de secrets no Vault estabelecida

2. **A FASE 2 (ATO 2)** — midPoint → Entra ID — foi **executada com sucesso na época, mas não persistiu** devido a operações de manutenção do ambiente (snapshots/rollbacks) em projetos posteriores.

3. **A FASE 3 (ATO 3)** — OrangeHRM → JML/RBAC — **nunca foi executada**, permanecendo como pendência fora do escopo do PRJ012.

---

## 6. Lições Aprendidas

| ID | Lição | Aplicação Futura |
|----|-------|------------------|
| L12 | Configurações dentro do midPoint (conectores, resources, shadows) são voláteis se o container for restaurado de snapshot | Documentar snapshots e seus conteúdos; validar persistência pós-restore |
| L13 | O Client Secret do Entra ID, mesmo armazenado no Vault, pode ser revogado externamente sem atualização do Vault | Implementar health check periódico do secret via script |
| L14 | App Registrations no Entra ID sobrevivem a qualquer restore de VM/container local | Priorizar a criação de recursos na nuvem para persistência |
| L15 | A forense prévia à implementação é essencial para identificar degradação de configurações | Incluir seção de "validação de artefatos existentes" em todo TAP |

---

## 7. Relação com o PRJ027 (Projeto Sucessor)

O **PRJ027** (Integração midPoint ↔ Microsoft Entra ID com Governança) foi iniciado em 08/05/2026 com base na forense realizada sobre o PRJ012.

### 7.1. O que o PRJ027 REAPROVEITOU do PRJ012

| Item | Utilização no PRJ027 |
|------|----------------------|
| App Registration `midpoint-iga-connector` | ✅ Reutilizado (Client ID e Tenant ID) |
| Permissões base | ✅ Mantidas, com adição de 4 novas permissões |
| Vault path `secret/entra-id/auth` | ✅ Criado baseado na estrutura do PRJ012 |

### 7.2. O que o PRJ027 RECONSTRUIU

| Item | Ação no PRJ027 |
|------|----------------|
| Conector Graph API | Reinstalado (`connector-msgraph-1.0.2.0.jar`) |
| Resource Entra ID | Recriado do zero |
| Shadows (usuários) | Reimportados via reconciliação |
| Usuários FP001-FP012 | Recriados a partir do CSV |
| Client Secret | Novo secret gerado e armazenado no Vault |
| Permissões faltantes | `Directory.ReadWrite.All`, `GroupMember.ReadWrite.All`, `RoleManagement.ReadWrite.Directory`, `Organization.Read.All` |

---

## 8. Aprovações

| Função | Nome | Data | Decisão |
|--------|------|------|----------|
| **Responsável Técnico** | Paulo Feitosa Lima | 08/05/2026 | ✅ **APROVADO** — Encerramento com Sucesso Parcial |
| **GRC Advisor** | Perplexity AI | 08/05/2026 | ✅ **REVISADO** — Documentação forense consistente |
| **Auditoria** | Claude (Anthropic) | 08/05/2026 | ✅ **CONSOLIDADO** — Lições aprendidas registradas |

---

## 9. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 06/03/2026 | Paulo Feitosa Lima | Relatório original do ATO 1 |
| **2.0** | **08/05/2026** | **Paulo Feitosa Lima** | **Reavaliação retroativa baseada em forense do PRJ027. Status alterado para "Sucesso Parcial". Documentada perda de artefatos no midPoint e transição para PRJ027.** |

---

**Fim do REL-PRJ012-v2.0** ✅

---

*PRJ012 — Orquestração de Identidades (midPoint → Microsoft Entra ID)*  
*Living Lab Fiqueok*  
*Projeto Sucessor: PRJ027 — Integração com Governança*  
*Arquivado em: `FiqueokBrain/PRJ012/90 Encerramento/REL-PRJ012-v2.0.md`*
