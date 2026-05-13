# GMUD-016-PRJ002 – Integração midPoint-AD via LDAP e Linking de Usuário

**Gestão de Mudanças - Retrospectiva**

**Fiqueok Living Lab - GRC/IAM Open-Source Platform**

---

## Informações Básicas da GMUD

| Campo | Valor |
|-------|-------|
| **ID da GMUD** | GMUD-016-PRJ002 |
| **Título** | Integração midPoint-AD via LDAP (389) e Correlação Usuário 0001 |
| **Tipo** | Retrospectiva (Documentação de Mudanças Executadas) |
| **Data de Execução Real** | 30/12/2025 |
| **Data de Documentação** | 03/01/2026 |
| **Responsável Execução** | Paulo Feitosa (Owner/CISO) |
| **Responsável Documentação** | Perplexity Pro (GRC Lead) |
| **Projeto** | PRJ002 - Fiqueok Living Lab IAM/IGA |
| **Severidade** | MÉDIA |
| **Status** | ✅ EXECUTADA COM SUCESSO (Retrospectiva) |
| **Dependências** | GMUD-015-FIX-NET, REL-GMUD-015-FIX-NET |

---

## 1. Contexto e Motivação

### 1.1. Situação Pré-Mudança

Após sucesso da **GMUD-015-FIX-NET** (29/12/2025), ambiente IGA apresentava:

```
✅ Rede estável: IGA-P-01 (xxx.xxx.xxx.xxx/16) ↔ ID-P-01 (xxx.xxx.xxx.xxx/16)
✅ midPoint operacional (GUI acessível)
✅ OrangeHRM Source funcional (Resource validado)
⏸️ Active Directory Target: NÃO CONFIGURADO
⏸️ Provisionamento outbound: PENDENTE
```

### 1.2. Motivação da Mudança

**Objetivo Estratégico:** Viabilizar publicação de conteúdo técnico no LinkedIn demonstrando capacidade de **Identity Governance & Administration (IGA)** end-to-end:

```
OrangeHRM (HR Source) → midPoint (IGA) → Active Directory (Target)
```

**Decisão Tática:** Priorizar **velocidade de implementação** para criar evidência tangível, postergando integração via **LDAPS (636)** para fase posterior (GMUD-017 planejada).

### 1.3. Contexto de Execução

**Exceção Autorizada:** Mudança executada **sem GMUD prévia** devido a:
- Urgência de publicação (timeline marketing)
- Ambiente de laboratório (non-production)
- Owner/CISO como executor (aprovação implícita)

**Governança Corretiva:** Esta GMUD retrospectiva garante:
- ✅ Rastreabilidade completa de configurações
- ✅ Documentação auditável
- ✅ Base para rollback futuro
- ✅ Alinhamento ISO 27001 (A.12.1.2 - Change Management)

---

## 2. Escopo Técnico Executado

### 2.1. Fase I - Configuração Resource Active Directory

#### 2.1.1. Parâmetros de Conexão LDAP

**Tipo Connector:** LDAP Connector (ICF - Identity Connector Framework)

**Configuração Implementada:**

| Parâmetro | Valor Configurado | Justificativa |
|-----------|-------------------|---------------|
| **Host** | `xxx.xxx.xxx.xxx` | IP fixo Domain Controller (ID-P-01) |
| **Porta** | `389` | LDAP não-seguro (aceito em lab) |
| **Bind DN** | `CN=svc-midpoint,CN=Users,DC=corp,DC=fiqueok,DC=com,DC=br` | Service Account pré-criado |
| **Bind Password** | `LabPassword123!` | Credencial texto claro (Local Management) |
| **Base Context** | `DC=corp,DC=fiqueok,DC=com,DC=br` | Raiz domínio corp.fiqueok.com.br |
| **Object Class** | `user` | Escopo: usuários AD |
| **Use SSL** | `false` | Porta 389 (não-encriptado) |

#### 2.1.2. Schema e Mapeamentos

**Atributos AD Configurados:**

```
INBOUND (AD → midPoint):
✅ sAMAccountName → name (Strong)
✅ givenName → givenName (Weak)
✅ sn → familyName (Weak)
✅ mail → emailAddress (Weak)
✅ memberOf → groups (Association)

OUTBOUND (midPoint → AD):
✅ name → sAMAccountName (Strong)
✅ givenName → givenName (Strong)
✅ familyName → sn (Strong)
✅ emailAddress → mail (Weak)
```

**Decisão Técnica:** Mapeamento **bidirecional** para suportar:
- Importação (Reconciliation) de usuários AD existentes
- Provisionamento (Provisioning) de novos usuários via midPoint

#### 2.1.3. Validação Conexão

**Teste Executado:**

```
midPoint → Configuration → Resources → AD-Target-LDAP-389
→ Test Connection
```

**Resultado:**

```
✅ Connector instantiation: Success
✅ Connector initialization: Success
✅ Connector connection: Success
✅ Connector capabilities: Success
✅ Resource schema: Success (78 attributes detected)
```

**Evidência:** Connection test **100% sucesso** (5/5 fases)

---

### 2.2. Fase II - Linking Usuário 0001 (Paulo Lima)

#### 2.2.1. Estado Inicial

**midPoint User 0001:**

```
Usuário: 0001 (Break-Glass Administrator)
givenName: Paulo
familyName: Lima
personalNumber: (empty)
Status: LINKED ao OrangeHRM? NÃO
```

**OrangeHRM Employee:**

```
employeeId: 0001
empFirstName: Paulo
empLastName: Lima
```

**Active Directory:**

```
Usuário: Paulo.Lima
DN: CN=Paulo Lima,CN=Users,DC=corp,DC=fiqueok,DC=com,DC=br
sAMAccountName: paulo.lima
Estado: Conta desabilitada (nova)
```

#### 2.2.2. Operação de Linking

**Ação Executada:** Vinculação manual usuário midPoint 0001 → conta AD `Paulo.Lima`

**Procedimento:**

```
1. midPoint → Users → 0001 (Paulo Lima)
2. Accounts → Add Account
3. Resource: AD-Target-LDAP-389
4. Tipo: Link to existing account
5. Distinguished Name: CN=Paulo Lima,CN=Users,DC=corp,DC=fiqueok,DC=com,DC=br
6. Save
```

**Resultado Esperado:**

```
✅ Shadow criado (midPoint metadata)
✅ Projection estabelecida (user 0001 ↔ Paulo.Lima)
✅ Sincronização bidirecional habilitada
```

#### 2.2.3. Configuração OrangeHRM Linking

**Ação Executada:** Vinculação adicional usuário midPoint 0001 → employee OrangeHRM 0001

**Procedimento:**

```
1. midPoint → Users → 0001 (Paulo Lima)
2. Accounts → Add Account
3. Resource: OrangeHRM-Source-JDBC
4. Tipo: Link to existing account
5. Key: employeeId = 0001
6. Save
```

**Resultado:**

```
✅ User 0001 agora possui 2 projections:
   ├── OrangeHRM (Source) → employeeId 0001
   └── AD (Target) → CN=Paulo Lima
```

---

### 2.3. Fase III - Tentativa de Provisionamento AD

#### 2.3.1. Objetivo

Testar ciclo completo de provisionamento:

```
OrangeHRM (empFirstName, empLastName) 
  → midPoint (givenName, familyName)
    → Active Directory (givenName, sn, sAMAccountName)
```

#### 2.3.2. Ações Executadas

**Teste 1: Reconciliation AD**

```
Configuration → Resources → AD-Target-LDAP-389
→ Tasks → Import Accounts from Resource
→ Run Now
```

**Resultado:**
```
⚠️ Task executada
⚠️ Contas AD importadas como shadows
❌ Provisionamento outbound: NÃO TESTADO (escopo futuro)
```

**Teste 2: Synchronization Task**

```
Tasks → Reconciliation → AD Target
→ Run Reconciliation
```

**Resultado:**
```
✅ Shadows sincronizados
✅ User 0001 status: LINKED
⏸️ Provisionamento automático: PENDENTE configuração mappings outbound
```

---

## 3. Resultados e Validações

### 3.1. Critérios de Sucesso Atingidos

| Critério | Meta | Resultado | Status |
|----------|------|-----------|--------|
| **Conexão AD 389** | Test Connection Success | ✅ 5/5 fases OK | **OK** |
| **Schema Discovery** | ≥ 50 atributos | ✅ 78 atributos | **OK** |
| **User 0001 Linking OrangeHRM** | Shadow criado | ✅ employeeId 0001 | **OK** |
| **User 0001 Linking AD** | Projection ativa | ✅ CN=Paulo Lima | **OK** |
| **Importação AD** | ≥ 1 shadow | ✅ paulo.lima shadow | **OK** |

### 3.2. Validações Técnicas

**Conectividade LDAP (Camada 4/7):**

```bash
# IGA-P-01 → ID-P-01
nc -zv xxx.xxx.xxx.xxx 389
# Resultado: Connection to xxx.xxx.xxx.xxx 389 port [tcp/ldap] succeeded!
```

**Query LDAP Manual:**

```bash
ldapsearch -x -H ldap://xxx.xxx.xxx.xxx:389   -D "CN=svc-midpoint,CN=Users,DC=corp,DC=fiqueok,DC=com,DC=br"   -w "LabPassword123!"   -b "DC=corp,DC=fiqueok,DC=com,DC=br"   "(sAMAccountName=paulo.lima)"
```

**Resultado:**
```
# Paulo Lima, Users, corp.fiqueok.com.br
dn: CN=Paulo Lima,CN=Users,DC=corp,DC=fiqueok,DC=com,DC=br
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: Paulo Lima
sAMAccountName: paulo.lima
givenName: Paulo
sn: Lima
```

✅ **Validação:** Conta AD acessível via LDAP

---

## 4. Exceções e Limitações Conhecidas

### 4.1. Exceções Técnicas

| Exceção | Justificativa | Risco | Mitigação Planejada |
|---------|---------------|-------|---------------------|
| **LDAP porta 389** | Velocidade implementação | **ALTO** (tráfego texto claro) | GMUD-017: Migração LDAPS 636 |
| **Credencial texto claro** | Ausência Vault configurado | **MÉDIO** | GMUD-018: HashiCorp Vault |
| **Provisionamento parcial** | Foco em linking, não sync completo | **BAIXO** | GMUD-019: Outbound mappings |

### 4.2. Limitações de Escopo

**NÃO IMPLEMENTADO nesta GMUD:**

❌ Provisionamento automático de novos usuários AD  
❌ Gestão de senhas via midPoint  
❌ Sincronização de grupos AD (memberOf)  
❌ Password policies  
❌ Account lifecycle (enable/disable)

**Justificativa:** Escopo reduzido para viabilizar **publicação LinkedIn** com evidência mínima viável de IGA funcional.

---

## 5. Riscos e Impactos

### 5.1. Análise de Riscos

| Risco | Probabilidade | Impacto | Mitigação Aplicada |
|-------|---------------|---------|-------------------|
| **Exposição credenciais LDAP** | Média | Alto | Ambiente isolado (lab) |
| **Tráfego não-encriptado** | Alta | Alto | VLAN isolada Management Zone |
| **Inconsistência dados** | Baixa | Médio | Linking manual (não automático) |
| **Perda rastreabilidade** | Alta | Médio | ✅ GMUD retrospectiva (este doc) |

### 5.2. Impacto de Negócio

**Positivo:**
- ✅ Viabilizou publicação LinkedIn
- ✅ Demonstração capacidade técnica IGA
- ✅ Integração Source (HR) → Target (AD)

**Negativo:**
- ⚠️ Débito técnico: LDAPS pendente
- ⚠️ Débito documental: GMUD retroativa (não prévia)

---

## 6. Lições Aprendidas

### 6.1. Governança e Processos

| # | Lição | Impacto | Ação Preventiva |
|---|-------|---------|-----------------|
| **L1** | **GMUDs urgentes devem ter template express** | ALTO | Criar POP-GRC-004 (GMUD Express) |
| **L2** | **Documentação retroativa é válida, mas subótima** | MÉDIO | Priorizar GMUD prévia mesmo em labs |
| **L3** | **Linking manual é técnica válida para POC** | BAIXO | OK para labs, vedar em produção |

### 6.2. Técnicas

| # | Lição | Impacto | Aplicação Futura |
|---|-------|---------|------------------|
| **T1** | **LDAP 389 funcional para fase inicial** | MÉDIO | Aceito em labs, transição LDAPS obrigatória |
| **T2** | **Test Connection 5/5 é insuficiente** | ALTO | Incluir testes E2E (query real, write test) |
| **T3** | **Linking ≠ Provisioning** | CRÍTICO | Documentar diferença em ADR futuro |

---

## 7. Próximos Passos e Dependências

### 7.1. GMUDs Sequenciais Planejadas

```
✅ GMUD-016 (esta) → Conexão AD 389 + Linking 0001
   ↓
🟡 GMUD-017 → Migração LDAPS 636 (segurança)
   ↓
🟡 GMUD-018 → HashiCorp Vault (credential management)
   ↓
🟡 GMUD-019 → Outbound Provisioning Automático
   ↓
🟡 GMUD-020 → Password Synchronization
```

### 7.2. Artefatos Pendentes

- [ ] ADR-003: Decisão LDAP vs LDAPS em ambientes lab
- [ ] POP-GRC-004: Procedimento GMUD Express
- [ ] DOC-IAM-002: Diferença Linking vs Provisioning
- [ ] GMUD-017: Implementação LDAPS 636

---

## 8. Plano de Rollback (Retroativo)

### 8.1. Rollback Conexão AD

**Cenário:** Necessidade de desfazer configuração Resource AD

**Procedimento:**

```
1. midPoint → Configuration → Resources
2. AD-Target-LDAP-389 → Delete
3. Confirmar exclusão
4. Validar: Shadows orphaned (sem impacto AD real)
```

**Impacto:** ✅ Zero impacto em AD (read-only nesta fase)

### 8.2. Rollback Linking User 0001

**Cenário:** Desvincular user 0001 das accounts

**Procedimento:**

```
1. midPoint → Users → 0001
2. Accounts → OrangeHRM Shadow → Unlink
3. Accounts → AD Shadow → Unlink
4. Save
```

**Impacto:** ✅ User 0001 volta ao estado inicial (standalone)

---

## 9. Evidências e Rastreabilidade

### 9.1. Localização de Artefatos

| Artefato | Localização | Status |
|----------|-------------|--------|
| **Histórico Gemini** | `https://gemini.google.com/share/fa2a8e01e435` | ✅ Disponível |
| **Screenshots midPoint** | (Não preservados) | ⚠️ Ausente |
| **Logs midPoint** | `IGA-P-01:/var/log/midpoint/midpoint.log` | ✅ Disponível |
| **Esta GMUD** | `Obsidian: 10Projetos/PRJ002/20Governanca/GMUDs/` | ✅ Criado |

### 9.2. Cross-References

**Documentos Relacionados:**

```
UPSTREAM:
├── GMUD-015-FIX-NET (pré-requisito rede)
└── REL-GMUD-015-FIX-NET (baseline estabilidade)

DOWNSTREAM:
├── GMUD-017 (LDAPS 636 - planejada)
├── GMUD-018 (Vault - planejada)
└── REL-GMUD-016 (este relatório - a criar)
```

---

## 10. Aprovações

| Papel | Nome | Assinatura Digital | Data |
|-------|------|-------------------|------|
| **Executor** | Paulo Feitosa | paulo-fiqueok-ciso | 30/12/2025 |
| **Documentador GRC** | Perplexity Pro | perplexity-grc-fiqueok | 03/01/2026 |
| **Aprovador Retroativo** | Paulo Feitosa (Owner/CISO) | **PENDENTE** | - |

---

## 11. Metadados do Documento

**Versão:** 1.0  
**Data Criação:** 03/01/2026  
**Tipo:** GMUD Retrospectiva  
**Classificação:** Internal Use - Lab Operations  
**Localização Obsidian:** `10Projetos/PRJ002/20Governanca/GMUDs/GMUD-016-PRJ002-Integracao-AD-Linking-User-0001.md`

---

**FIM DA GMUD-016**

