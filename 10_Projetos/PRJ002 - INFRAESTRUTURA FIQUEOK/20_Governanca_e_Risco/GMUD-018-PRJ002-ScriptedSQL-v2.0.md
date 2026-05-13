# GMUD-018-PRJ002 – Implementação Connector ScriptedSQL OrangeHRM

**Gestão de Mudanças - Implementação Crítica (Escopo Revisado)**

**Fiqueok Living Lab - GRC/IAM Open-Source Platform**

---

## Informações Básicas da GMUD

| Campo | Valor |
|-------|-------|
| **ID da GMUD** | GMUD-018-PRJ002 |
| **Título** | Implementação Connector ScriptedSQL para Integração OrangeHRM → midPoint |
| **Tipo** | Mudança Normal (Planejada) |
| **Versão Documento** | 2.0 (Escopo Revisado) |
| **Data de Criação** | 03/01/2026 21:00 BRT |
| **Data de Revisão** | 03/01/2026 21:10 BRT |
| **Responsável Execução** | Paulo Feitosa (Owner/CISO) |
| **Responsável Técnico** | ChatGPT (DevSecOps - Groovy/Python) |
| **Responsável GRC** | Perplexity Pro ✅ (Validação artefatos v2.0) |
| **Projeto** | PRJ002 - Fiqueok Living Lab IAM/IGA |
| **Severidade** | ALTA |
| **Prioridade** | CRÍTICA |
| **Status** | 🟡 PLANEJADA - PENDENTE APROVAÇÃO FINAL |
| **Janela Execução** | 90 minutos (Sábado 21h15-22h45 proposto) |
| **Dependências** | ADR-004 ✅, GMUD-017 ❌, GMUD-016 ✅ |

---

## ⚠️ MUDANÇA DE ESCOPO IMPORTANTE

### Escopo Original GMUD-018 (v1.0 - OBSOLETO)

❌ **ESCOPO ABANDONADO:**
- Object Template User (sAMAccountName automático)
- Resource OrangeHRM ScriptedSQL
- Resource AD Outbound (provisionamento automático)
- Pipeline completo: OrangeHRM → midPoint → AD

❌ **MOTIVO:** Risco de falha dupla (Source + Target simultaneamente)

### Escopo Revisado GMUD-018 (v2.0 - ATUAL)

✅ **ESCOPO FOCADO (Source apenas):**
- Scripts Groovy (3 arquivos: Search, Test, Schema)
- Resource OrangeHRM ScriptedSQL (substituir DatabaseTable)
- Object Template User (versão simplificada para testes)
- Validação: OrangeHRM → midPoint (sincronização funcional)

✅ **JUSTIFICATIVA:**
- Fundação sólida antes de Target (abordagem incremental)
- Post-mortem GMUD-017 demonstrou necessidade de base robusta
- Alinhamento Lean/Agile: MVPs iterativos

**Provisionamento AD movido para:** GMUD-019 (após validação GMUD-018)

---

## 1. Contexto e Motivação

### 1.1. Cronologia Completa

```
30/12/2025 - GMUD-016 (✅ SUCESSO)
  • Integração AD via LDAP 389
  • User 0001 linkado manualmente
  • Pipeline: OrangeHRM ↔ midPoint ↔ AD (manual)

03/01/2026 08:00 - GMUD-017 (❌ FALHA)
  • Objetivo: Corrigir integração OrangeHRM → midPoint
  • 5 tentativas de correção (225 minutos)
  • Causa raiz: Connector DatabaseTable incompatível
  • Decisão: Migrar para ScriptedSQL

03/01/2026 20:55 - ADR-004 (✅ APROVADO)
  • Decisão: ScriptedSQL vs DatabaseTable
  • Score: 8.65/10 vs 3.75/10
  • Probabilidade: 85% vs 30%

03/01/2026 20:56 - Artefatos v1.0 GERADOS
  • 3 scripts Groovy + 2 XMLs

03/01/2026 21:00 - REVISÃO TÉCNICA
  • 12 issues identificados
  • 2 críticos, 2 altos, 4 médios, 4 baixos

03/01/2026 21:03 - Artefatos v2.0 CORRIGIDOS
  • 10/12 issues resolvidos
  • 2 débitos técnicos aceitos
  • Status: PRONTOS para GMUD-018
```

### 1.2. Objetivo GMUD-018 (Revisado)

**Meta:** Implementar Connector ScriptedSQL para integração **OrangeHRM → midPoint**

**Pipeline Escopo v2.0:**

```
OrangeHRM (HR Source)
  ↓ [ScriptedSQL Connector]
midPoint (IGA)
  ↓ [Object Template: validação básica]

[PAUSA AQUI - Validação antes de Target]

Active Directory (Target)
  ↓ [GMUD-019: Provisionamento automático]
```

---

## 2. Decisão Arquitetural (ADR-004)

### 2.1. Decisão Aprovada

**✅ OPÇÃO B: Connector ScriptedSQL**

| Métrica | Valor |
|---------|-------|
| Score ponderado | 8.65/10 |
| Probabilidade sucesso | 85% |
| Tempo implementação | 90 min |
| Manutenibilidade | Alta |

**Justificativa:**
- Resolve limitações DatabaseTable (GMUD-017)
- Recomendação oficial Evolveum
- Controle total sobre queries SQL
- Scripts versionáveis (Git)

### 2.2. Opções Rejeitadas

**❌ DatabaseTable:**
- Histórico 100% falha (GMUD-010, 013, 017)
- Schema discovery incompleto
- 225 minutos sem solução

**⚠️ CSV Import:**
- Fallback se ScriptedSQL falhar
- Não-idiomático para IGA

---

## 3. Artefatos v2.0 Corrigidos

### 3.1. Issues Críticos RESOLVIDOS (2/2)

**RESOURCE-001: OID Placeholder**
- Problema: XML com OID genérico
- Correção: Procedimento documentado (Checklist PR-004)

**RESOURCE-002: scriptBaseDir Inexistente**
- Problema: Path não existe
- Correção: `mkdir -p /opt/midpoint/var/scripts/orangehrm/`

### 3.2. Issues Altos RESOLVIDOS (2/2)

**TEMPLATE-001: Extension Schema**
- Problema: userPrincipalName requer schema adicional
- Correção: Removido (simplificado)

**SCHEMA-001: Formato Flags**
- Problema: `flags: [Flags.NOT_UPDATEABLE]`
- Correção: `flags: Flags.NOT_UPDATEABLE`

### 3.3. Issues Médios RESOLVIDOS (4/4)

**SEARCH-003: Encoding UTF-8**
- Correção: `characterEncoding=UTF-8&useUnicode=true`

**RESOURCE-004: Namespace Faltante**
- Correção: `xmlns:cap` adicionado

**SEARCH-001: Performance LIMIT**
- Correção: `LIMIT 100` (modo teste)

**TEMPLATE-003: Edge Cases**
- Correção: Validação NULL antes de processar

### 3.4. Débitos Técnicos ACEITOS (2/2)

**TEMPLATE-002: Colisão Username** → GMUD-019
- Impacto: Ambiente teste sem colisões
- Solução: Verificação + sufixo numérico

**RESOURCE-003: Senha Texto Claro** → GMUD futura
- Impacto: Lab isolado
- Solução: HashiCorp Vault

**Taxa Resolução:** 10/12 (83%)

---

## 4. Plano de Implementação

### 4.1. Fase 0: Pré-Requisitos (15 min)

#### Checklist Obrigatório

- [ ] PR-001: Checkpoint Hyper-V (IGA-P-01)
- [ ] PR-002: Backup PostgreSQL
- [ ] PR-003: Diretório scripts criado
- [ ] PR-004: OID Resource OrangeHRM obtido
- [ ] PR-005: Connector ScriptedSQL validado
- [ ] PR-006: Rede Docker backend-net OK
- [ ] PR-007: MariaDB acessível (teste)
- [ ] PR-008: Artefatos v2.0 salvos

**Comandos:**

```powershell
# PR-001
Get-VM IGA-P-01 | Checkpoint-VM -SnapshotName "PRE-GMUD-018-v2"
```

```bash
# PR-002
docker exec midpoint-db pg_dump -U midpoint midpoint > backup-pre-gmud018.sql

# PR-003
docker exec midpoint-server mkdir -p /opt/midpoint/var/scripts/orangehrm

# PR-004 - Obter OID via GUI ou logs
# GUI: Configuration → Resources → OrangeHRM → OID na URL

# PR-007
docker exec orangehrm-db mysql -u orangehrmro -p*** orangehrm -e "SELECT COUNT(*) FROM hs_hr_employee;"
```

---

### 4.2. Fase 1: Deploy Scripts Groovy (10 min)

**Artefatos v2.0:**

1. **SearchScript.groovy v2.0** (70 linhas)
2. **TestScript.groovy v1.0** (30 linhas)
3. **SchemaScript.groovy v2.0** (40 linhas)

**Comandos:**

```bash
# Copiar scripts
docker cp SearchScript.groovy midpoint-server:/opt/midpoint/var/scripts/orangehrm/
docker cp TestScript.groovy midpoint-server:/opt/midpoint/var/scripts/orangehrm/
docker cp SchemaScript.groovy midpoint-server:/opt/midpoint/var/scripts/orangehrm/

# Permissões
docker exec midpoint-server chmod 644 /opt/midpoint/var/scripts/orangehrm/*.groovy
docker exec midpoint-server chown midpoint:midpoint /opt/midpoint/var/scripts/orangehrm/*.groovy

# Validar
docker exec midpoint-server ls -lh /opt/midpoint/var/scripts/orangehrm/
```

**Critério:** ✅ 3/3 arquivos copiados, permissões 644

---

### 4.3. Fase 2: Object Template (10 min)

**object-template-user.xml v2.0** (Simplificado)

**OID:** `00000000-0000-0000-0000-000000000222`

**Aplicação:**

```bash
curl -k -u administrator:5ecr3t   -H "Content-Type: application/xml"   -X POST   -d @object-template-user.xml   https://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/objectTemplates

# Validar
curl -k -u administrator:5ecr3t   https://xxx.xxx.xxx.xxx:<REDACTED_SECRET>000000-0000-0000-0000-000000000222
```

**Critério:** ✅ HTTP 201 Created

---

### 4.4. Fase 3: Resource OrangeHRM ScriptedSQL (20 min)

**resource-orangehrm-scripted-v3.xml** (220 linhas)

**CRÍTICO:** Substituir `oid="SUBSTITUIR_PELO_OID_REAL"` pelo OID do PR-004

**Configuração:**
- Connector: `com.evolveum.polygon.connector.scripted.sql.ScriptedSQLConnector`
- JDBC URL: `jdbc:mariadb://orangehrm-db:3306/orangehrm?useSSL=false&characterEncoding=UTF-8&useUnicode=true`
- Scripts: `/opt/midpoint/var/scripts/orangehrm/*.groovy`

**Mapeamentos INBOUND (7):**
1. employeeId → employeeNumber (Strong)
2. givenName → givenName (Strong)
3. familyName → familyName (Strong)
4. middleName → additionalName (Weak)
5. emailAddress → emailAddress (Weak)
6. terminationId → activation/administrativeStatus (Strong)

**Aplicação:**

```bash
# PUT (UPDATE resource existente)
curl -k -u administrator:5ecr3t   -H "Content-Type: application/xml"   -X PUT   -d @resource-orangehrm-scripted-v3.xml   https://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/resources/{OID_REAL}
```

**Critério:** ✅ HTTP 200 OK

---

### 4.5. Fase 4: Validação E2E (30 min)

#### Test Connection

```bash
curl -k -u administrator:5ecr3t   -X POST   https://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/resources/{OID_REAL}/test
```

**Esperado:** 5/5 fases OK

#### Import Task

**Via GUI:**
1. Tasks → New Task
2. Type: Import from Resource
3. Resource: OrangeHRM Source ScriptedSQL v3
4. Execute: Run once

**Monitorar:**

```bash
docker exec midpoint-server tail -f /opt/midpoint/var/log/midpoint.log | grep "SearchScript"
```

**Critério:** ✅ Task SUCCESS, ≥ 1 employee

#### Verificar Users

**GUI:** Users → All users → Filtrar "OrangeHRM"

**Validar:**
- name: paulo.lima (sAMAccountName)
- givenName: Paulo
- familyName: Lima
- employeeNumber: 0001
- emailAddress: paulo.lima@orangehrm.local
- activation: ENABLED

**Critério:** ✅ 7/7 atributos corretos

#### Teste Activation

```sql
docker exec orangehrm-db mysql -u orangehrmro -p*** orangehrm   -e "UPDATE hs_hr_employee SET termination_id = 1 WHERE emp_number = '0001';"
```

**Re-executar Import Task**

**Validar:** User paulo.lima → activation: DISABLED ✅

---

## 5. Plano de Rollback

### 5.1. Rollback Completo - Hyper-V (< 5 min)

```powershell
Restore-VMSnapshot -Name "PRE-GMUD-018-v2" -VMName IGA-P-01 -Confirm:$false
Start-VM -Name IGA-P-01
```

**Impacto:** Zero perda de dados

### 5.2. Rollback Parcial - PostgreSQL (< 5 min)

```bash
docker exec -i midpoint-db psql -U midpoint midpoint < backup-pre-gmud018.sql
docker restart midpoint-server
```

### 5.3. Rollback Seletivo - Resource (< 3 min)

```bash
curl -k -u administrator:5ecr3t   -X DELETE   https://xxx.xxx.xxx.xxx:8080/midpoint/ws/rest/resources/{OID_REAL}
```

---

## 6. Critérios de Sucesso

| ID | Critério | Meta | Validação |
|----|----------|------|-----------|
| CS-001 | Scripts Groovy | 3/3 deployados | ls comando |
| CS-002 | Test Connection | 5/5 OK | GUI Test |
| CS-003 | Import Task | ≥ 1 user | Task logs |
| CS-004 | Mapeamentos | 7 atributos | User detail |
| CS-005 | Activation | terminationId funcional | Teste desligamento |
| CS-006 | sAMAccountName | nome.sobrenome | User name |
| CS-007 | Caracteres | Acentos removidos | José → jose |

---

## 7. Riscos e Mitigações

| Risco | Prob | Impacto | Mitigação |
|-------|------|---------|-----------|
| Scripts Groovy bugs | Baixa | Alto | Revisão v2.0 |
| OID incorreto | Média | Crítico | Checklist PR-004 |
| Encoding UTF-8 falha | Baixa | Médio | JDBC URL corrigido |
| PostgreSQL corrupção | Muito Baixa | Crítico | Checkpoint + backup |

---

## 8. Timeline Estimado

| Fase | Duração | Acumulado |
|------|---------|-----------|
| 0. Pré-requisitos | 15 min | 15 min |
| 1. Deploy Groovy | 10 min | 25 min |
| 2. Object Template | 10 min | 35 min |
| 3. Resource OrangeHRM | 20 min | 55 min |
| 4. Validação E2E | 30 min | 85 min |
| Buffer | 5 min | **90 min** |

---

## 9. Checklist Pós-Execução

**Validações Técnicas:**
- [ ] PE-001: Test Connection 5/5
- [ ] PE-002: Import Task SUCCESS
- [ ] PE-003: Mapeamentos 7/7
- [ ] PE-004: Activation funcional
- [ ] PE-005: Logs limpos
- [ ] PE-006: Performance < 30s
- [ ] PE-007: Encoding UTF-8 OK

**Governança:**
- [ ] PE-008: Backup final PostgreSQL
- [ ] PE-009: Snapshot pós-GMUD
- [ ] PE-010: Documentar OID final
- [ ] PE-011: Atualizar REL-GMUD-018
- [ ] PE-012: Notificar Paulo Feitosa
- [ ] PE-013: Arquivar scripts Git
- [ ] PE-014: Planejar GMUD-019

---

## 10. Compliance

### 10.1. ISO 27001:2022

- **A.12.1.2:** Change Management ✅
- **A.14.2.2:** Secure development ✅
- **A.16.1.7:** Collection of evidence ✅

### 10.2. SGSI-NORM-IAM-001

- ✅ Padrão `nome.sobrenome`
- ✅ Normalização acentos
- ✅ Limite 20 caracteres

---

## 11. Documentos Relacionados

**Upstream:**
- ADR-004 (✅ 20h55)
- GMUD-017 (❌ Falha)
- GMUD-016 (✅ Sucesso)
- SGSI-NORM-IAM-001 (v1.0)

**Downstream:**
- GMUD-019: Provisionamento AD
- GMUD-020: LDAPS 636
- GMUD-021: Vault integration

---

## 12. Aprovações

| Papel | Nome | Status |
|-------|------|--------|
| Solicitante | Paulo Feitosa | PENDENTE |
| Executor | Paulo Feitosa + ChatGPT | PENDENTE |
| Validador Artefatos | Perplexity Pro | ✅ APROVADO |
| CISO | Paulo Feitosa | PENDENTE |

---

## 13. Metadados

**Versão:** 2.0 (Escopo Revisado)  
**Data:** 03/01/2026 21:10 BRT  
**Tipo:** GMUD Normal  
**Classificação:** Internal Use  
**Localização:** `<REDACTED_SECRET>D-018-PRJ002-ScriptedSQL-v2.0.md`

**Alinhamento:**
- ISO 27001:2022: A.12.1.2, A.14.2.2, A.16.1.7
- SGSI-NORM-IAM-001
- ITIL v4: Change Management

**Palavras-chave:** ScriptedSQL, Groovy, OrangeHRM, midPoint, ADR-004, Artefatos v2.0

---

**FIM DA GMUD-018 v2.0**

**STATUS:** 🟡 PLANEJADA - Aguardando aprovação final  
**JANELA:** Sábado 21h15-22h45 (90 min)  
**PRÓXIMA AÇÃO:** Aprovação Paulo Feitosa para execução

