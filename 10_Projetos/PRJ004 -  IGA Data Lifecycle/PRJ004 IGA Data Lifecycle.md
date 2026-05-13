---
project: PRJ004
title: IGA Data Lifecycle - Fonte Autoritativa CSV e Integração LDAP
brand: Fiqueok
status: In Progress
priority: High
owner: Paulo
tags: [IAM, midPoint, GRC, ISO27001, Laboratory]
created: 2026-01-27
---

# 🛡️ 

## 1. Visão Geral (Executive Summary)
Este projeto faz parte do **Living Lab Fiqueok** e visa estabelecer a maturidade na gestão do ciclo de vida de identidades (JML - Joiner, Mover, Leaver). A implementação utiliza o **Evolveum midPoint 4.10** como motor de governança, consumindo dados de uma fonte autoritativa CSV e provisionando identidades em um diretório LDAP segmentado.

### Objetivos Estratégicos
- **Automação de Joiner:** Criação de identidades sem intervenção manual.
- **Segregação de Redes:** Implementação de arquitetura multihomed e VLANs no Hyper-V.
- **Conformidade (GRC):** Garantir que a "âncora de ouro" (`personalNumber`) impeça duplicidade de registros.

---

## 2. Arquitetura Técnica (Baseline v1.1)

### 2.1 Topologia de Rede
| Ativo | VM Name | OS | IP Address | VLAN |
| :--- | :--- | :--- | :--- | :--- |
| **IGA Console** | `iga-gf-01` | Ubuntu 24.04 | `xxx.xxx.xxx.xxx` | 10 (App) |
| **IGA Bridge** | `iga-gf-01` | Ubuntu 24.04 | `10.0.20.5` | 20 (Identity) |
| **LDAP Target** | `FOK-SRV-LDAP-01`| Ubuntu 24.04 | `10.0.20.10` | 20 (Identity) |

### 2.2 Stack de Tecnologia
- **Orquestrador:** Docker Engine (Rede: `iga-project_iga-network`).
- **Plataforma IGA:** Evolveum midPoint 4.10.
- **Diretório:** OpenDJ (LDAP) na VLAN 20.

---

## 3. Configuração de Governança (midPoint)

### 3.1 Mapeamento de Atributos (Schema Handling)
Os atributos abaixo são críticos para a integridade do sistema:
- **UID / personalNumber:** Mapeamento **Strong** (Âncora de Correlação).
- **lifecycleState:** Mapeamento **Strong** (Define o estado Ativo/Inativo).

### 3.2 Regras de Sincronização (Reações)
| Situação | Ação | Justificativa |
| :--- | :--- | :--- |
| `Unmatched` | `Add focus` | **Joiner:** Cria a identidade no midPoint se o ID for novo. |
| `Unlinked` | `Link` | **Reconciliation:** Vincula registros existentes. |
| `Linked` | `Synchronize` | **Mover:** Atualiza atributos em caso de mudança no CSV. |

---

## 4. Plano de Testes e Validação

### ✅ Testes Concluídos (Joiner)
- [x] Importação de 10 colaboradores via arquivo `employees_prj004.csv`.
- [x] Validação de transição de estado: `Unmatched` -> `Linked`.
- [x] Verificação de integridade: 11 usuários totais (incluindo Admin).

### 🔄 Próximos Passos (Mover & Leaver)
- [ ] **Configuração da interface VLAN 20** na VM `iga-gf-01`.
- [ ] **Provisionamento do OpenDJ** via script automatizado na VM `FOK-SRV-LDAP-01`.
- [ ] **Teste de Mover:** Alterar cargo no CSV e validar atualização automática no IGA.
- [ ] **Teste de Leaver:** Inativar colaborador e validar bloqueio de conta.

---

## 5. Log de Auditoria e Evidências
- **Evidência 01:** Registro de "10 Success" na Task de Importação.
- **Evidência 02:** Diagrama de Arquitetura `Midpoint41+LDAP.drawio`.
- **Lição Aprendida:** A ausência da reação `Unmatched` impede a criação de novos usuários, mesmo que o sistema reporte "Success" no processamento da linha.

---
**Documento gerado para fins de aprendizado e análise técnica - Marca Fiqueok.**
