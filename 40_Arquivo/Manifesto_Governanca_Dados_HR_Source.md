---
status: Ativo
versão: 1
data: 2026-01-04
tipo: Manifesto
área: Governança de Dados
sistema: OrangeHRM PIM
owner: Paulo Feitosa
tags:
  - governança
  - hr-source
  - iam
  - data-quality
  - orangehrm
  - midpoint
relacionado:
  - "[[GMUD-008 - Deploy Automatizado IaC do Ambiente IGA]]"
  - "[[GMUD-011]]"
  - "[[GMUD-016]]"
  - "[[SGSI-NORM-IAM-001]]"
  - "[[KB-001 - midPoint 4.10 Sqale]]"
---

# Manifesto: Diretrizes de Governança de Dados (HR Source)

## 📋 Metadados

| Atributo | Valor |
|----------|-------|
| **Propósito** | Definir o padrão de excelência para identidades no OrangeHRM PIM |
| **Objetivo** | Garantir que o barramento de serviços (midPoint) consuma dados determinísticos |
| **Sistema-Fonte** | OrangeHRM 5.8 (IGA-P-01:8081) |
| **Sistema-Destino** | midPoint 4.10 (IGA-P-01:8080) |
| **Target System** | Active Directory (ID-P-01) |
| **Framework** | SGSI-NORM-IAM-001 |

---

## 🎯 Visão Geral

Este manifesto estabelece os **princípios de qualidade de dados** que governam a fonte autoritativa de identidades no Lab Fiqueok. Dados limpos no HR Source eliminam transformações complexas no midPoint e garantem provisionamento determinístico no Active Directory.

### Princípio Fundamental

> **"Garbage In, Garbage Out"**  
> A qualidade do dado na origem determina a qualidade do usuário no AD. O midPoint não é ferramenta de sanitização — é ferramenta de governança.

---

## 1️⃣ Identificadores Únicos (Imutabilidade)

### Regra de Ouro
Todo colaborador **DEVE** possuir um **Employee ID único e sequencial**.

### Especificação Técnica

| Atributo | Regra | Exemplo | Tipo |
|----------|-------|---------|------|
| **Employee ID** | Sequencial numérico com zero-padding (3 dígitos mínimo) | `001`, `002`, `099`, `100` | String |
| **Formato** | `^[0-9]{3,}$` (regex) | ✅ `001` ❌ `1` ❌ `EMP-001` | Imutável |
| **Geração** | Manual ou auto-increment (conforme volume) | Próximo disponível | — |

### Função no Ecossistema IGA

```
OrangeHRM               midPoint                Active Directory
Employee ID: 001  -->  UID: 001 (ICF Name) -->  employeeID: 001
```

**ICF Name (Identity Connector Framework):** Âncora para correlação e reconciliação de identidades entre sistemas. Sem Employee ID único, o midPoint não consegue rastrear mudanças de forma determinística.

### Casos de Uso

- **Onboarding:** Employee ID define o shadow account no midPoint antes mesmo da sincronização com AD
- **Rehire:** Mesmo Employee ID permite reativar identidade histórica sem duplicação
- **Auditoria:** Rastreamento de mudanças por timeline do Employee ID

---

## 2️⃣ Soberania do Nome (Sanitização)

### Regra de Ouro
Os campos **First Name** e **Last Name** são **mandatórios** e devem estar livres de abreviações indevidas.

### Especificação Técnica

| Campo | Obrigatoriedade | Regras | Exemplos Válidos | Exemplos Inválidos |
|-------|----------------|--------|------------------|-------------------|
| **First Name** | ✅ Obrigatório | - Apenas letras e acentos<br/>- Sem números ou caracteres especiais<br/>- Sem abreviações | `Ana`, `João`, `Maria Luísa` | ❌ `A.`, `Ana123`, `Ana (RH)` |
| **Last Name** | ✅ Obrigatório | - Mesmo padrão do First Name | `Silva`, `Santos Costa` | ❌ `Silva Jr.`, `S.` |
| **Middle Name** | ⚪ Opcional | - Usar apenas se nome composto oficial | `Cristina`, `dos Santos` | ❌ `C.` |

### Padrão SGSI-NORM-IAM-001

O username (AD `sAMAccountName`) segue o padrão:

```
primeironome.sobrenome
```

**Implementação no midPoint (basic.norm()):**

```groovy
// Script de normalização
firstName = basic.norm(input.getPropertyRealValue('http://midpoint.evolveum.com/xml/ns/public/resource/instance-3', 'firstname'))
lastName = basic.norm(input.getPropertyRealValue('http://midpoint.evolveum.com/xml/ns/public/resource/instance-3', 'lastname'))

username = firstName.toLowerCase() + '.' + lastName.toLowerCase()
```

### Responsabilidade da Fonte

O **OrangeHRM (HR Source)** deve fornecer nomes completos e normalizados para evitar que o midPoint precise implementar lógica de sanitização complexa:

| Dado no HR | Username Gerado | Observação |
|------------|-----------------|------------|
| `Carlos Mendes` | ✅ `carlos.mendes` | Perfeito |
| `Pedro Luiz Alves` | ✅ `pedro.alves` | Primeiro nome composto tratado |
| `Julia M Silva` | ❌ `julia.m` | **Abreviação indevida — corrigir no HR** |
| `Roberto Jr Dias` | ❌ `roberto.jr` | **Sufixo inválido — corrigir no HR** |

---

## 3️⃣ Contexto Organizacional (Segregação)

### Regra de Ouro
O campo **Department** é **obrigatório** para permitir alocação automática em Organizational Units (OUs) do Active Directory.

### Especificação Técnica

| Campo | Obrigatoriedade | Função no IGA | Destino no AD |
|-------|----------------|---------------|---------------|
| **Department** | ✅ Obrigatório | Mapping para OU | `OU=<Department>,OU=Users,DC=corp,DC=fiqueok,DC=com,DC=br` |
| **Job Title** | ✅ Obrigatório | Base para RBAC futuro | Atributo `title` no AD |
| **Sub Unit** | ⚪ Opcional | Refinamento de OU (futuro) | Nested OU (roadmap) |

### Mapeamento de Departamentos

| Departamento no HR | OU no Active Directory | Exemplo de DN |
|-------------------|------------------------|---------------|
| `IT` | `OU=IT` | `CN=tecnologia.silva,OU=IT,OU=Users,DC=corp,DC=fiqueok,DC=com,DC=br` |
| `Marketing` | `OU=Marketing` | `CN=comunicacao.santos,OU=Marketing,OU=Users,DC=corp,DC=fiqueok,DC=com,DC=br` |
| `Finance` | `OU=Finance` | `CN=contabilidade.costa,OU=Finance,OU=Users,DC=corp,DC=fiqueok,DC=com,DC=br` |

### Implicações de Conformidade

O preenchimento correto do Department permite auditoria por controles de acesso baseados em segregação de funções (SoD):

- **ISO 27001 A.9.2.3:** Controle de acesso por papel organizacional
- **NIST CSF PR.AC-4:** Princípio do privilégio mínimo por departamento

---

## 4️⃣ Job Title (Fundação para RBAC)

### Regra de Ouro
O campo **Job Title** é **essencial** para a futura implementação de **Role-Based Access Control (RBAC)**.

### Especificação Técnica

| Campo | Obrigatoriedade | Formato | Exemplos |
|-------|----------------|---------|----------|
| **Job Title** | ✅ Obrigatório | String descritiva | `System Administrator`, `Security Analyst`, `HR Manager` |
| **Padronização** | ⚠️ Recomendada | Evitar variações do mesmo cargo | ✅ `Developer` ❌ `Dev`, `Programmer`, `Software Eng` |

### Roadmap de RBAC (Fase 3.0)

```
Job Title no HR  →  midPoint Role Catalog  →  Análise de Permissões
                                              ↓
                    System Admin     →  Grupo AD: IT-Admins
                    Developer        →  Grupo AD: Developers
                    Analyst          →  Grupo AD: Business-Users
```

**Benefício:** Provisionamento automático de grupos AD baseado em cargo, reduzindo intervenção manual e risco de erro.

---

## 5️⃣ Extensões de Negócio (Enriquecimento GRC)

### Visão Estratégica
Para simular um ambiente corporativo realista, o Lab Fiqueok incluirá **campos de enriquecimento** que permitem cenários avançados de **GRC (Governance, Risk & Compliance)**.

### Campos Adicionais

| Campo | Tipo | Propósito GRC | Exemplo de Cenário |
|-------|------|---------------|-------------------|
| **Salary** | Decimal | Análise de risco por valor financeiro de cargo | Auditoria: "Usuários com salário > R$ 20k têm acesso privilegiado?" |
| **13º Salário** | Decimal | Cálculo de custo total de identidade | Relatório: "Custo anual de acessos por departamento" |
| **Admission Date** | Date | Controle de lifecycle (onboarding/offboarding) | Trigger: "Desativar acessos após 90 dias de inatividade" |
| **Employment Status** | Enum | Estado de vínculo (Ativo, Suspenso, Desligado) | Automação: Disable AD account quando status = "Desligado" |

### Exemplo de Cenário GRC Avançado

**Caso de Uso: Risco por Valor Financeiro de Cargo**

```yaml
Regra de Compliance:
  - Cargos com Salary > R$ 15.000
  - DEVEM ter MFA habilitado
  - DEVEM ser revisados semestralmente
  - DEVEM ter aprovação dupla para acessos críticos
```

**Implementação no midPoint (futuro):**

```groovy
condition:
  script:
    code: |
      salary = midpoint.getExtensionPropertyRealValue(focus, 'salary')
      return salary != null && salary > 15000
```

---

## 📊 Matriz de Conformidade

### Validação de Dados no OrangeHRM

| Controle | Campo | Status | Validação | Ferramenta |
|----------|-------|--------|-----------|------------|
| **CTL-HR-001** | Employee ID | ✅ Implementado | Único, numérico, 3+ dígitos | OrangeHRM + midPoint correlation |
| **CTL-HR-002** | First Name | ✅ Implementado | Sem abreviações, apenas letras | Validação manual (futuro: script) |
| **CTL-HR-003** | Last Name | ✅ Implementado | Sem abreviações, apenas letras | Validação manual (futuro: script) |
| **CTL-HR-004** | Department | ✅ Implementado | Lista pré-definida de OUs válidas | Dropdown no OrangeHRM |
| **CTL-HR-005** | Job Title | ⚠️ Parcial | Sem padronização formal | Manual (roadmap: taxonomia) |
| **CTL-HR-006** | Salary | 🔄 Em planejamento | Numérico positivo | Futuro custom field |
| **CTL-HR-007** | Admission Date | 🔄 Em planejamento | Data no passado | Futuro custom field |

---

## 🔄 Fluxo de Dados End-to-End

### Jornada da Identidade

```
1. OrangeHRM (HR Source)
   ↓ REST API
   Employee ID=001, Name: Exemplo Usuario, Dept: IT

2. midPoint (IGA Engine)
   ↓ Normalização: basic.norm()
   Username: exemplo.usuario

3. Active Directory (Target System)
   ↓ LDAP Create User
   sAMAccountName: exemplo.usuario, OU: IT

4. Success + objectGUID
   ↓
5. Sync Status: Provisioned
```

### Pontos de Controle

1. **OrangeHRM:** Validação de preenchimento obrigatório
2. **midPoint:** Script de normalização e mapeamento de atributos
3. **Active Directory:** Schema validation e unicidade de `sAMAccountName`

---

## 🚨 Tratamento de Não-Conformidades

### Cenários de Erro

| Erro | Causa Raiz | Remediação | Responsável |
|------|-----------|------------|-------------|
| **Username duplicado no AD** | Employee ID duplicado ou nome idêntico | Investigar no OrangeHRM, corrigir unicidade | HR Admin + IAM Team |
| **Usuário em OU incorreta** | Department mal preenchido | Atualizar Department no HR, forçar resync | HR Admin |
| **Username com caracteres inválidos** | First/Last Name com abreviações ou símbolos | Corrigir nome no HR, republicar no midPoint | HR Admin |
| **Provisionamento falhou** | Campo obrigatório vazio (ex: Department) | Preencher campo obrigatório, reprocessar | HR Admin |

### Processo de RNC (Relatório de Não-Conformidade)

Quando detectada violação deste manifesto:

1. Criar **RNC** usando `[[TEMPLATE-001 - RNC]]`
2. Classificar severidade: **Crítica** (bloqueia provisionamento) ou **Moderada** (degrada qualidade)
3. Atribuir ação corretiva ao **HR Admin**
4. Validar correção via **resync manual no midPoint**
5. Documentar lição aprendida em `[[Lessons Learned - HR Data Quality]]`

---

## 📚 Referências

### Documentos Relacionados

- `[[GMUD-008]]` — Implantação da Stack midPoint 4.10
- `[[GMUD-011]]` — Rede de Integração Segura (Backend Bridge)
- `[[GMUD-016]]` — Integração midPoint-AD via LDAP (389) e Correlação Usuário 0001 (executada em 30/12/2025)
- `[[REL-GMUD-016]]` — Relatório de Encerramento GMUD-016 (documentação retroativa)
- `[[KB-001 - midPoint 4.10 Sqale]]` — Arquitetura do IGA Engine
- `[[Manifesto v2.0]]` — Manifesto de Estratégia e Infraestrutura Fiqueok

### Normas e Padrões

- **SGSI-NORM-IAM-001:** Padrão de nomenclatura de usuários
- **ISO 27001:2022 A.9.2.1:** User registration and de-registration
- **NIST CSF 2.0 PR.AC-1:** Identities and credentials are issued, managed, verified, revoked

### Scripts Técnicos

- `basic.norm()` — Função de normalização do midPoint
- `generateUsername.groovy` — Script customizado para geração de username

---

## ✅ Checklist de Implementação

Ao cadastrar um novo colaborador no OrangeHRM:

- [ ] **Employee ID** preenchido (formato: `001`, `002`, etc.)
- [ ] **First Name** completo, sem abreviações
- [ ] **Last Name** completo, sem abreviações
- [ ] **Department** selecionado da lista pré-definida
- [ ] **Job Title** preenchido com cargo oficial
- [ ] *(Futuro)* **Salary** preenchido
- [ ] *(Futuro)* **Admission Date** preenchida
- [ ] Salvar e aguardar sincronização automática com midPoint (intervalo: 5 min)
- [ ] Validar criação do usuário no AD via `Get-ADUser -Identity "exemplo.usuario"`

---

## 🔐 Controle de Versão

| Versão | Data | Autor | Mudanças Principais |
|--------|------|-------|---------------------|
| **1.0** | 2026-01-04 | Paulo Feitosa | Criação do manifesto com base nas diretrizes fornecidas |

---

## 📝 Notas de Rodapé

> **Nota sobre Nomes:**  
> Todos os nomes de colaboradores citados neste documento são **fictícios e utilizados apenas para fins de exemplo**. Não há correlação com pessoas reais.

> **Nota sobre GMUD-016:**  
> A **GMUD-016** foi executada com sucesso em **30/12/2025**, estabelecendo a integração midPoint-AD via LDAP porta 389 e realizando o linking do usuário 0001. A implementação ocorreu sem GMUD prévia devido à urgência de negócio, mas foi devidamente documentada de forma retroativa conforme `[[REL-GMUD-016]]`.

> **Alinhamento Estratégico:**  
> Este documento é parte da **Fase 2.0 - Segmentação e PKI** do Roadmap do Lab Fiqueok, priorizando qualidade de dados como fundação para automação avançada e provisionamento determinístico.

---

**Aprovação Pendente:** Paulo Feitosa (Owner)  
**Próxima Revisão:** 2026-02-04  
**Localização:** `FiqueokBrain/10-Projetos/PRJ-001-LABORATORIO/20-Governanca/Manifestos/`
