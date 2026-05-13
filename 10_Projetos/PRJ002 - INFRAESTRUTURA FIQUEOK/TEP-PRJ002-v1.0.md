# TEP-PRJ002 — Termo de Encerramento de Projeto
## Integração OrangeHRM → midPoint → Active Directory
**Versão:** 1.0  
**Data de Encerramento:** Janeiro/2026  
**Responsável:** Paulo Feitosa — GRC/IAM Lead (Fiqueok Consultoria)  
**Classificação:** Internal Use — Living Lab Fiqueok

---

## 1. Identificação do Projeto

| Campo | Valor |
|-------|-------|
| **Código** | PRJ-002 |
| **Nome** | Integração IGA — OrangeHRM como Fonte Autoritativa |
| **Período** | Dezembro/2025 — Janeiro/2026 |
| **Status Final** | Encerrado — POC parcialmente atingida |
| **GMUDs executadas** | GMUD-008 a GMUD-024 |

---

## 2. Resumo Executivo

O PRJ-002 foi iniciado com o objetivo de implementar o fluxo completo OrangeHRM → midPoint → AD no Living Lab Fiqueok. Ao longo de 17 GMUDs, o projeto percorreu um ciclo completo de tentativas, bloqueadores, rollbacks e aprendizados. O fluxo completo automatizado não foi atingido, mas a prova de conceito foi parcialmente validada — com linking manual funcionando e infraestrutura base consolidada.

O encerramento formal reconhece o valor pedagógico do percurso e documenta os bloqueadores técnicos e arquiteturais que impedirão reincidência nos próximos projetos.

---

## 3. O Que Foi Construído — Linha do Tempo

### GMUD-008 — midPoint 4.10 instalado
Stack Docker Compose com midPoint 4.10-alpine + PostgreSQL 16 (Sqale Repository). Resolvidos: conflito H2 vs PostgreSQL, prefixo `MP_SET_`, schema `m_global_metadata` via init container. **Resultado: stack estável, REST API e GUI validados.**

### GMUD-009 — OrangeHRM Community Edition instalado
OrangeHRM + MariaDB 11.4 em Docker Compose na mesma VM (IGA-P-01), porta 8081. Conta `orangehrm_ro` criada com permissão `SELECT only`. **Resultado: fonte autoritativa operacional.**

### GMUD-010 — Primeira tentativa de Resource OrangeHRM
Tentativa de importar Resource via XML. Falha por Schema Violation — motor Prism/Sqale sensível à ordem de namespaces no XML. **Resultado: encerrada sem sucesso. Lição: usar GUI Wizard.**

### GMUD-011 — Rede bridge persistente
Conectividade IGA-P-01 ↔ OrangeHRM/MariaDB via rede Docker bridge persistente (IaC). Validada com ping e nc de dentro do container midPoint. Isolamento externo confirmado. **Resultado: rede estável e determinística.**

### GMUD-013 — Resource OrangeHRM v2 via GUI
Driver JDBC `mariadb-java-client-3.1.2.jar` injetado. Test Connection via GUI: sucesso. Schema discovery da tabela `hs_hr_employee` funcionou. Atributos `employee_id`, `givenName`, `familyName` mapeados. Importação suspensa — AD ainda instável. **Resultado: conector configurado, importação pendente.**

### GMUD-014 — Tentativa LDAPS (porta 636) para AD
Certificado injetado no Keystore Java. Conectividade L4 (porta 636) confirmada. Falha em L7: handshake TLS — AD não apresentou certificado válido no binding NTDS. **Resultado: encerrada sem sucesso. Causa: AD sem certificado com EKU Server Authentication.**

### GMUD-015 — Segregação de rede VLAN 20
Interface VLAN 20 configurada via Netplan (eth0.20, 192.168.20.10/24). Aplicada com `netplan try --timeout 30` para fallback seguro. **Resultado: segmentação L2 operacional.**

### GMUD-016 — Integração AD via LDAP 389 + Linking manual
Resource AD configurado via LDAP 389 (não encriptado), aceito por decisão explícita de velocidade vs segurança. Test Connection 5/5. 78 atributos descobertos. Usuário 0001 (Paulo Lima) vinculado manualmente a OrangeHRM e AD. **Resultado: fluxo OrangeHRM → midPoint → AD funcional via linking manual.**

### GMUD-017 — Tentativa de correção do Resource OrangeHRM
5 iterações de correção do conector DatabaseTable. Test Connection sempre sucesso, mas Import Task retornava 0 objetos. Schema discovery incompleto (~60%). **Resultado: encerrada sem sucesso. Causa provável: limitação do conector DatabaseTable para schema não-padrão do OrangeHRM.**

### GMUD-018 — Tentativa ScriptedSQL Connector
Scripts Groovy deployados com sucesso. Bloqueador crítico: ScriptedSQL JAR não estava na imagem Docker oficial — é componente opcional que requer instalação manual. Download do Nexus e GitHub falharam (404 e timeout). Rollback via checkpoint Hyper-V em 3 minutos. **Resultado: encerrada sem sucesso. Lição crítica: imagem Docker oficial é lean — connectors opcionais requerem instalação manual.**

### GMUD-019 — Tentativa de Object Template
Import Task retornava SUCCESS mas nenhum User era criado no midPoint. Causa identificada: `<addFocus>` não executava em midPoint 4.10 — breaking change não documentado no Smart Correlation. **Decisão: downgrade para midPoint 4.8 LTS.**

### GMUD-020 a 021 — Downgrade midPoint 4.8 e instabilidades
Série de tentativas de downgrade para 4.8.8. Bloqueadores encontrados: PostgreSQL 9.5 incompatível (requisito 12+), problemas com imagem Alpine vs Debian, erros de Keystore, schema SQL não encontrado. Sanitização agressiva afetou volumes do OrangeHRM. Rollback via snapshot restaurou ambiente. **Resultado: sequência encerrada sem sucesso após múltiplas tentativas.**

### GMUD-022 — Rollback histórico
Retorno ao snapshot `PRE-GMUD-019v2-ObjectTemplate-FUNCIONAL` — ponto anterior ao downgrade, com midPoint 4.10 + PostgreSQL + OrangeHRM estáveis. **Resultado: ambiente estabilizado.**

### GMUD-023 — Validação via CSV como fonte alternativa
Recurso CSV configurado como Golden Source para testar materialização de identidades. Descoberta crítica: midPoint exige atributo `User.name` obrigatório — ausência causava falhas silenciosas. Com mapeamento `employeeId → User.name` adicionado, shadows criados corretamente. **Resultado: sucesso parcial — mecanismo de sincronização validado com CSV.**

### GMUD-024 — Procedimento canônico CSV
Tentativa de estabelecer procedimento reprodutível de Resource CSV. Interrompida por lacuna de validação pré-execução, não por erro de design. **Resultado: encerramento controlado.**

---

## 4. Estado Final do Ambiente

```
OrangeHRM ──JDBC──► midPoint         ⚠️ conector configurado, sincronização automática não funcional
midPoint   ──LDAP──► AD              ✅ LDAP 389 funcional, linking manual validado
Importação automática de identidades  ❌ não atingida via OrangeHRM
Importação via CSV                    ✅ mecanismo validado (GMUD-023)
Fluxo Joiner end-to-end              ❌ não automatizado
```

---

## 5. Critérios de Sucesso — Avaliação Final

| Critério | Meta | Resultado |
|----------|------|-----------|
| midPoint operacional com PostgreSQL | ✅ | ✅ Atingido |
| OrangeHRM com dados de identidade | ✅ | ✅ Atingido |
| Conector midPoint → OrangeHRM funcional | ✅ | ⚠️ Parcial (Test Connection OK, sync não) |
| Conector midPoint → AD funcional | ✅ | ✅ Atingido (LDAP 389) |
| Usuário com shadow linked em ambos | ✅ | ✅ Atingido (manual) |
| Importação automática end-to-end | ✅ | ❌ Não atingido |

---

## 6. Lições Aprendidas Registradas

| ID | Lição | Origem |
|----|-------|--------|
| L01 | Test Connection 5/5 não garante sincronização funcional | GMUD-017/019 |
| L02 | Import Task SUCCESS não garante criação de User (shadow ≠ focus) | GMUD-019/023 |
| L03 | midPoint exige `User.name` obrigatório — ausência causa falha silenciosa | GMUD-023 |
| L04 | Imagem Docker oficial do midPoint é lean — connectors opcionais requerem JAR manual | GMUD-018 |
| L05 | midPoint 4.10 tem breaking changes em Smart Correlation não documentados | GMUD-019 |
| L06 | Configurações manuais de rede Docker são efêmeras — devem ser codificadas em IaC | GMUD-011 |
| L07 | Checkpoint Hyper-V imediatamente antes da GMUD é obrigatório — não 1h antes | GMUD-018/021 |
| L08 | Sanitização agressiva deve ter escopo explícito — risco de afetar volumes fora do escopo | GMUD-021 |
| L09 | Versões non-LTS têm Early Adopter Risk mensurável em ambiente lab | GMUD-019 |
| L10 | Linking manual ≠ provisionamento automático — são capacidades distintas | GMUD-016 |
| L11 | Schema discovery parcial é red flag — validar atributos manualmente antes de avançar | GMUD-017 |
| L12 | Documentação retroativa é válida mas subótima — priorizar GMUD prévia | GMUD-016 |

---

## 7. Débitos Técnicos Identificados

- Sincronização automática OrangeHRM → midPoint não resolvida
- LDAP 389 sem migração para LDAPS 636
- Credenciais em texto claro no Docker Compose (HashiCorp Vault pendente)
- ScriptedSQL JAR não instalado na imagem Docker

---

## 8. Aprovação de Encerramento

| Papel | Nome | Data |
|-------|------|------|
| Owner/CISO | Paulo Feitosa | Janeiro/2026 |

---

---

# ADENDO — Retrospectiva Arquitetural
## Onde Erramos: A Falta de Decisão Arquitetural Prévia

**Versão:** 1.0  
**Tipo:** Retrospective Review — Post-Mortem Arquitetural  
**Data:** Janeiro/2026

---

### 1. O Padrão que se Repetiu

Ao longo de 17 GMUDs, um padrão se repetiu consistentemente:

> Chegamos ao passo técnico, executamos, encontramos o bloqueador, documentamos, tentamos corrigir, falhamos, rollback, próxima GMUD.

Isso não é falha de execução. É falha de arquitetura pré-projeto.

---

### 2. A Decisão Arquitetural que Nunca Foi Feita

**O conector escolhido para integrar OrangeHRM ao midPoint foi o DatabaseTable — por conveniência, não por decisão.**

Nenhuma pergunta arquitetural foi feita antes de executar a GMUD-010:

- Qual conector é o mais adequado para uma fonte autoritativa de RH?
- O DatabaseTable suporta o schema não-padrão do OrangeHRM Community?
- O ScriptedSQL está disponível na imagem Docker padrão?
- A API REST do OrangeHRM está habilitada e documentada?
- Quais são os endpoints disponíveis e o método de autenticação?

A resposta a essas perguntas teria evitado GMUD-010, 013, 017 e 018 — quatro GMUDs e aproximadamente 12 horas de trabalho.

---

### 3. Por Que o Conector Correto Era REST API

O DatabaseTable acopla o midPoint ao **schema interno do banco de dados** do OrangeHRM. Isso cria dois problemas estruturais:

**Primeiro:** qualquer atualização de versão do OrangeHRM pode alterar o schema da tabela `hs_hr_employee`, quebrando silenciosamente o conector.

**Segundo:** o OrangeHRM Community Edition expõe uma API REST oficial com endpoints estáveis e autenticação OAuth2. Essa API é o contrato público do sistema — ela é versionada, documentada e não quebra com atualizações internas de schema.

O conector correto para uma fonte autoritativa de RH é sempre **a interface pública do sistema**, não seu banco de dados interno.

---

### 4. O Que Seria Necessário Para Fazer Correto Desde o Início

Uma decisão arquitetural pré-projeto teria exigido:

**Informações a coletar antes da primeira GMUD:**
- Versão do OrangeHRM e se a API REST estava habilitada
- Endpoints disponíveis (GET /api/v1/employees, autenticação OAuth2 client credentials)
- Estrutura do JSON retornado — campos que representam identidade
- Qual conector midPoint suporta REST autenticado e está disponível na imagem Docker

**Artefatos a produzir antes de executar:**
- Mapa de atributos: campo OrangeHRM → atributo midPoint → atributo AD
- Diagrama de fluxo com protocolos explícitos em cada seta
- Decisão de conector documentada com justificativa arquitetural (ADR)
- Checklist de pré-requisitos validado antes de qualquer GMUD

**Conhecimento necessário que faltou:**
- Entender OAuth2 client credentials flow para consumir API REST
- Saber interpretar JSON de resposta da API antes de configurar o conector
- Conhecer quais connectors midPoint estão incluídos na imagem Docker padrão vs opcionais
- Entender o modelo interno do midPoint: shadow object, focus object, `addFocus`, `User.name` obrigatório

---

### 5. Onde as IAs Falharam

As IAs que orientaram o projeto — incluindo as utilizadas nas GMUDs e nas sessões de suporte técnico — operaram consistentemente no nível de execução:

> "Use o conector DatabaseTable. Aqui está o XML de configuração."

Nenhuma IA fez a pergunta arquitetural prévia:

> "Antes de configurar qualquer conector, precisamos decidir qual é o correto. Qual interface o OrangeHRM expõe? O banco direto é o caminho certo?"

Isso é a diferença entre orientação N2 (como configurar) e orientação N4 (o que configurar e por quê). A ausência de uma decisão arquitetural de nível N4 no início do projeto foi a causa raiz de todas as falhas subsequentes.

---

### 6. O Que Levar Para os Próximos Projetos

Qualquer integração de fonte autoritativa deve responder estas perguntas **antes** da primeira GMUD:

1. Qual é a interface pública do sistema-fonte? (API REST, SCIM, CSV, banco direto?)
2. Essa interface está documentada e estável?
3. O conector necessário está disponível no ambiente de execução?
4. O mapa de atributos foi validado contra dados reais antes de configurar?
5. O fluxo completo foi desenhado com protocolos explícitos em cada seta?

Se qualquer uma dessas respostas for "não sei" — a GMUD não começa.

---

*Adendo aprovado por: Paulo Feitosa — Janeiro/2026*
