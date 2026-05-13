
# 

**Architecture Decision Record**

**Living Lab Fiqueok - GRC/IAM Open-Source Platform**

---

## Metadados

| Campo | Valor |
|-------|-------|
| **ID** | ADR-008 |
| **Título** | Modelo de Identidade e Autoridade de Atributos para IGA Híbrido |
| **Status** | ✅ **APROVADO** |
| **Data** | 10/05/2026 |
| **Autor** | Paulo Feitosa Lima |
| **Decisor** | Paulo Feitosa Lima (Owner/CISO) |
| **Validação Externa** | Gemini (Análise de práticas de mercado) |
| **Contexto** | PRJ026 (Integração midPoint ↔ AD), PRJ028 (Segurança AD), PRJ003 (Canvases) |
| **Decisões Relacionadas** | ADR-007 (Arquitetura Zero Trust para AD), PRJ003 Canvases |
| **Versão** | 1.0 |

---

## 1. Contexto e Problema

### 1.1. Situação Atual

O Living Lab Fiqueok possui os seguintes sistemas de identidade:

| Sistema | Função | Estado |
|---------|--------|--------|
| **OrangeHRM** | Fonte autoritativa de RH (dados de pessoas) | ✅ Operacional |
| **midPoint 4.10** | Motor IGA (orquestrador de identidades) | ✅ Operacional |
| **Active Directory** | Sistema alvo (Target) para provisionamento | ✅ Operacional (após PRJ028) |
| **Microsoft Entra ID** | Sistema alvo futuro (Target) | ⚠️ Desconectado |

**Problema identificado:** Não há um modelo formal definido para:

- Hierarquia de autoridade entre os sistemas
- Formato dos identificadores de identidade (UPN, sAMAccountName)
- Política de resolução de conflitos (colisão de nomes)
- Tratamento de mudanças de nome (Mover)

### 1.2. Perguntas que este ADR responde

| Pergunta | Resposta |
|----------|----------|
| Qual sistema é a fonte de verdade para dados de identidade? | OrangeHRM (RH) |
| Qual atributo será usado como âncora de correlação (immutableId)? | `employeeID` |
| Qual será o formato do UPN (UserPrincipalName) no AD? | `nome.sobrenome@fiqueok.com.br` |
| Como o IGA deve tratar colisões de nomes? | Resolução automática (N+1) com fallback seguro |
| Como tratar mudança de nome civil? | Renomear UPN e preservar e-mail antigo como alias |

---

## 2. Hierarquia de Autoridade (Single Source of Truth)

### 2.1. Níveis de Autoridade

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                    HIERARQUIA DA FONTE DE VERDADE (CONFORME ADR-008)                 │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    NÍVEL 1 - FONTE AUTORITATIVA (SSoT)                       │   │
│  │                                                                              │   │
│  │  ┌──────────────────────────────────────────────────────────────────────┐ │   │
│  │  │                        ORANGEHRM (RH)                                 │ │   │
│  │  │                                                                      │ │   │
│  │  │  Atributos de autoridade exclusiva:                                  │ │   │
│  │  │  • employeeID (identificador único e imutável)                       │ │   │
│  │  │  • givenName (primeiro nome)                                         │ │   │
│  │  │  • familyName (sobrenome)                                            │ │   │
│  │  │  • department (departamento)                                         │ │   │
│  │  │  • title (cargo)                                                     │ │   │
│  │  │  • employmentStatus (status de emprego)                              │ │   │
│  │  │                                                                      │ │   │
│  │  │  ⚠️ NOTA: O RH NÃO define o formato do UPN ou e-mail.                │ │   │
│  │  │     Ele fornece os dados brutos; o IGA deriva os identificadores.    │ │   │
│  │  └──────────────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                       │                                             │
│                                       ▼                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    NÍVEL 2 - ORQUESTRADOR IGA (MIDPOINT)                     │   │
│  │                                                                              │   │
│  │  Responsabilidades:                                                          │   │
│  │  • Consumir dados do RH (via Shadow API ou CSV)                             │   │
│  │  • Validar unicidade de e-mail/UPN                                          │   │
│  │  • Resolver colisões automaticamente (lógica N+1)                          │   │
│  │  • Derivar atributos técnicos:                                              │   │
│  │    - userPrincipalName (UPN) = e-mail                                       │   │
│  │    - sAMAccountName = parte antes do @                                      │   │
│  │    - displayName = givenName + " " + familyName                             │   │
│  │  • Provisionar para sistemas alvo (AD, Entra ID)                            │   │
│  │  • Gerenciar ciclo de vida JML (Joiner, Mover, Leaver)                      │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                       │                                             │
│                                       ▼                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                    NÍVEL 3 - SISTEMAS ALVO (TARGET SYSTEMS)                 │   │
│  │                                                                              │   │
│  │  ┌─────────────────────────────────────────────────────────────────────┐   │   │
│  │  │  Active Directory (ID-P-01)                                         │   │   │
│  │  │  • Recebe provisionamento do midPoint                               │   │   │
│  │  │  • NUNCA é fonte de verdade para atributos de identidade            │   │   │
│  │  │  • Dados existentes são resíduos de projetos anteriores             │   │   │
│  │  └─────────────────────────────────────────────────────────────────────┘   │   │
│  │                                                                              │   │
│  │  ┌─────────────────────────────────────────────────────────────────────┐   │   │
│  │  │  Microsoft Entra ID (Futuro)                                        │   │   │
│  │  │  • Receberá provisionamento via midPoint ou Entra Connect           │   │   │
│  │  │  • Refletirá as decisões do IGA                                      │   │   │
│  │  └─────────────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### 2.2. Matriz de Autoridade por Atributo

| Atributo | Fonte de Verdade | Derivado por | Provisionado para | Mutabilidade |
|----------|------------------|--------------|-------------------|--------------|
| `employeeID` | OrangeHRM | - | AD, Entra ID | ❌ Imutável |
| `givenName` | OrangeHRM | - | AD, Entra ID | ⚠️ Mutável (raro) |
| `familyName` | OrangeHRM | - | AD, Entra ID | ⚠️ Mutável (raro) |
| `department` | OrangeHRM | - | AD, Entra ID | ✅ Mutável |
| `title` | OrangeHRM | - | AD, Entra ID | ✅ Mutável |
| `employmentStatus` | OrangeHRM | - | AD, Entra ID | ✅ Mutável |
| **`userPrincipalName` (UPN)** | **midPoint** | `emailAddress` | AD, Entra ID | ✅ Mutável (com alias) |
| **`sAMAccountName`** | **midPoint** | Parte antes do `@` do UPN | AD | ✅ Mutável (raro) |
| **`emailAddress`** | **midPoint** | Regra de derivação | AD, Entra ID | ✅ Mutável (com alias) |
| **`displayName`** | **midPoint** | `givenName + " " + familyName` | AD, Entra ID | ✅ Mutável |

---

## 3. Decisões Específicas

### 3.1. Âncora de Correlação (ImmutableId / SourceAnchor)

| Decisão | Valor |
|---------|-------|
| **Atributo** | `employeeID` |
| **Justificativa** | Imutável, único, não muda com eventos de vida (casamento, rebranding) |
| **Implementação** | Mapeado para `ms-DS-ConsistencyGuid` no AD (não `objectGUID`) |
| **Alinhamento** | Microsoft Best Practice, NIST SP 800-207 |

### 3.2. Formato do UPN (UserPrincipalName)

| Decisão | Valor |
|---------|-------|
| **Formato** | `nome.sobrenome@fiqueok.com.br` (derivado do e-mail) |
| **Justificativa** | Experiência do usuário (memorável, intuitivo), alinhado com Mail-as-UPN |
| **Implementação** | O IGA deriva o UPN a partir do e-mail gerado |
| **Alinhamento** | Microsoft Best Practice (Mail-as-UPN) |

### 3.3. Origem do E-mail

| Decisão | Valor |
|---------|-------|
| **Origem** | O IGA gera o e-mail com base nos dados do RH |
| **Justificativa** | RH fornece dados brutos (nome, sobrenome); IGA aplica regras de negócio e resolve colisões |
| **Implementação** | RH não define o e-mail; apenas informa nome e sobrenome |
| **Motivo** | Evita erro humano (digitação incorreta) e garante consistência das regras |

### 3.4. Política de Resolução de Colisões (Homônimos)

| Decisão | Valor |
|---------|-------|
| **Política** | Resolução automática pelo IGA (lógica "N+1") |
| **Justificativa** | Evita atrito operacional; RH não precisa se preocupar com unicidade |
| **Implementação** | Conforme seção 4.2 |
| **Fallback** | Se exaurir tentativas (ex: 99 colisões), usar `employeeID@dominio.com.br` |

### 3.5. Tratamento de Mudança de Nome (Mover)

| Decisão | Valor |
|---------|-------|
| **Política** | IGA renomeia UPN e preserva e-mail antigo como alias |
| **Justificativa** | Evita perda de e-mails e quebra de autenticação |
| **Implementação** | Adicionar e-mail antigo como `smtp:` (alias) no AD |
| **Alinhamento** | Microsoft Best Practice (proxyAddresses) |

---

## 4. Regras de Derivação (Implementação no midPoint)

### 4.1. Geração de E-mail e UPN

```groovy
// <REDACTED_SECRET>====================
// REGRA DE DERIVAÇÃO DE E-MAIL E UPN
// <REDACTED_SECRET>====================
// Input: givenName, familyName (do RH)
// Output: emailAddress, userPrincipalName

def given = basic.norm(givenName)      // "João" → "joao"
def family = basic.norm(familyName)    // "Silva" → "silva"
def domain = "fiqueok.com.br"

// Geração do base email
def baseEmail = given + '.' + family + '@' + domain
def emailAddress = baseEmail
def counter = 1

// Resolução automática de colisões (lógica N+1)
while (emailExists(emailAddress)) {
    counter++
    emailAddress = given + '.' + family + counter + '@' + domain
    
    // Fallback seguro: se atingir limite, usa employeeID
    if (counter > 99) {
        emailAddress = "user." + employeeID + '@' + domain
        log.warn("Colisão excessiva para ${given}.${family}. Usando fallback: ${emailAddress}")
        break
    }
}

// UPN = emailAddress (Mail-as-UPN)
def userPrincipalName = emailAddress

// sAMAccountName = parte antes do @ (limitado a 20 caracteres)
def samAccountName = emailAddress.split('@')[0]
if (samAccountName.length() > 20) {
    samAccountName = samAccountName.substring(0, 20)
}

// Retornar valores
return [
    emailAddress: emailAddress,
    userPrincipalName: userPrincipalName,
    samAccountName: samAccountName
]
```

### 4.2. Tratamento de Mudança de Nome (Mover)

```groovy
// <REDACTED_SECRET>====================
// REGRA PARA MUDANÇA DE NOME (MOVER)
// <REDACTED_SECRET>====================
// Quando givenName ou familyName mudam, preservar e-mail antigo como alias

def oldEmail = focusOld.getEmailAddress()
def newEmail = emailAddress

if (oldEmail != null && oldEmail != newEmail) {
    // Adicionar e-mail antigo como alias (proxyAddress)
    def oldProxy = 'smtp:' + oldEmail
    addToProxyAddresses(oldProxy)
    
    log.info("Nome alterado: ${oldEmail} → ${newEmail}. Alias preservado: ${oldProxy}")
}
```

### 4.3. Mapeamento para o AD

| Atributo no AD | Origem no midPoint | Direção |
|----------------|-------------------|---------|
| `employeeID` | `employeeID` (do RH) | IGA → AD |
| `givenName` | `givenName` (do RH) | IGA → AD |
| `sn` | `familyName` (do RH) | IGA → AD |
| `userPrincipalName` | `emailAddress` (derivado) | IGA → AD |
| `sAMAccountName` | `emailAddress.split('@')[0]` | IGA → AD |
| `mail` | `emailAddress` (derivado) | IGA → AD |
| `displayName` | `givenName + " " + familyName` | IGA → AD |
| `proxyAddresses` | `smtp:{email}` + aliases históricos | IGA → AD |
| `department` | `department` (do RH) | IGA → AD |
| `title` | `title` (do RH) | IGA → AD |

---

## 5. Alinhamento com Frameworks

### 5.1. NIST SP 800-207 (Zero Trust Architecture)

| Princípio | Implementação |
|-----------|---------------|
| Identidade como perímetro | UPN amigável para usuários, employeeID para correlação técnica |
| Privilégio mínimo | IGA provisiona apenas atributos necessários |
| Verificação contínua | Validação de unicidade antes de provisionar |

### 5.2. CIS Benchmarks v3.0 (Windows Server 2022)

| Recomendação | Implementação |
|--------------|---------------|
| UPN deve ser igual ao e-mail principal | ✅ Mail-as-UPN |
| sAMAccountName limitado a 20 caracteres | ✅ Implementado |
| Preservar e-mails antigos como alias | ✅ proxyAddresses |

### 5.3. ISO 27001:2022

| Controle | Implementação |
|----------|---------------|
| A.5.15 - Controle de acesso | UPN amigável para usuários |
| A.5.16 - Gestão de identidades | employeeID como âncora imutável |
| A.8.3 - Privilégio mínimo | IGA orquestra, sistemas alvo apenas refletem |
| A.8.15 - Logging | Logs de todas as derivações e colisões |

### 5.4. Microsoft Best Practices

| Recomendação | Implementação |
|--------------|---------------|
| SourceAnchor = ms-DS-ConsistencyGuid | ✅ employeeID mapeado |
| Mail-as-UPN | ✅ UPN = e-mail |
| ProxyAddresses para aliases | ✅ Preservado em mudanças de nome |
| Não usar objectGUID como âncora | ✅ Evitado |

---

## 6. Consequências

### 6.1. Positivas

| Consequência | Benefício |
|--------------|-----------|
| **Autonomia do IGA** | IGA resolve colisões sem depender do RH |
| **Experiência do usuário** | UPN amigável e memorável |
| **Correlação robusta** | employeeID imutável garante integridade |
| **Rastreabilidade** | Logs completos de derivações e resoluções |
| **Conformidade** | Alinhado com Microsoft, CIS, NIST, ISO 27001 |

### 6.2. Negativas (Aceitas)

| Consequência | Impacto | Mitigação |
|--------------|---------|-----------|
| **Complexidade no IGA** | Maior esforço de configuração | Documentação detalhada (POP) |
| **Fallback user.employeeID** | UPN não amigável em casos extremos | Ocorre apenas após 99 colisões (improvável) |
| **Dependência do midPoint** | Se IGA falhar, provisionamento para | Tailscale + MFA + snapshots |

### 6.3. Riscos Residuais

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| Duas pessoas com mesmo nome e employeeID | Muito Baixa | Alto | Validação no RH antes da criação |
| Mudança de nome em lote (ex: 1000 usuários) | Baixa | Médio | Script de migração planejado |
| Colisão com alias existente | Baixa | Baixo | Verificação antes de adicionar proxyAddress |

---

## 7. Decisões Rejeitadas

| Alternativa | Motivo da Rejeição |
|-------------|---------------------|
| **employeeID como UPN** | UX ruim (usuário não memoriza FP001@dominio) |
| **RH como gerador de e-mail** | Risco de erro humano e inconsistência |
| **Bloqueio puro em caso de colisão** | Gera atrito operacional e tickets de suporte |
| **objectGUID como âncora** | Microsoft não recomenda; não é consistente entre florestas |

---

## 8. Referências

### 8.1. Documentos Internos

| Documento | Relevância |
|-----------|------------|
| ADR-007 | Arquitetura Zero Trust para AD |
| PRJ003 Canvases | Fundamentos de identidade canônica |
| TAP-PRJ026 | Planejamento da integração |
| GMUD-001-PRJ026 | Execução da integração |

### 8.2. Referências Externas

| Fonte | Link |
|-------|------|
| Microsoft - Source Anchor | https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/plan-connect-design-concepts |
| Microsoft - Mail-as-UPN | https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/plan-connect-userprincipalname |
| Microsoft - ProxyAddresses | https://learn.microsoft.com/en-us/exchange/recipients/email-addresses |
| CIS Benchmarks v3.0 | https://www.cisecurity.org/benchmark/microsoft_windows_server |
| NIST SP 800-207 | Zero Trust Architecture |

---

## 9. Aprovações

| Função | Nome | Data | Status |
|--------|------|------|:------:|
| Autor | Paulo Feitosa Lima | 10/05/2026 | ✅ |
| Validação Externa | Gemini | 10/05/2026 | ✅ |
| Decisor (Owner/CISO) | Paulo Feitosa Lima | 10/05/2026 | ✅ |
| GRC Lead | Paulo Feitosa Lima | 10/05/2026 | ✅ |

---

## 10. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 10/05/2026 | Paulo Feitosa Lima | Criação do ADR-008 - Modelo de Identidade e Autoridade de Atributos |

---

**FIM DO ADR-008 v1.0**

---

*Documento mantido por Paulo Feitosa Lima — Living Lab Fiqueok*  
*PRJ026 - Integração midPoint 4.10 com Active Directory*  
*Referência: ADR-007, PRJ003 Canvases*  
*Data: 10/05/2026*
```
