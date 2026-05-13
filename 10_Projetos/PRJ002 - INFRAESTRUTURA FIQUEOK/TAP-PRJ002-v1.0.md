# TAP-PRJ002 — Termo de Abertura de Projeto
## Integração OrangeHRM → midPoint → Active Directory
**Versão:** 1.0  
**Data:** Dezembro/2025  
**Responsável:** Paulo Feitosa — GRC/IAM Lead (Fiqueok Consultoria)  
**Classificação:** Internal Use — Living Lab Fiqueok

---

## 1. Identificação do Projeto

| Campo | Valor |
|-------|-------|
| **Código** | PRJ-002 |
| **Nome** | Integração IGA — OrangeHRM como Fonte Autoritativa |
| **Ambiente** | Living Lab Fiqueok — IGA-P-01 |
| **Início previsto** | Dezembro/2025 |
| **Sponsor** | Paulo Feitosa (Owner/CISO) |

---

## 2. Objetivo

Implementar, em ambiente de laboratório, o fluxo completo de Identity Governance & Administration (IGA) conectando uma fonte autoritativa de RH ao motor de governança e ao diretório corporativo:

```
OrangeHRM (SSoT / HR Source) → midPoint (IGA Engine) → Active Directory (Target)
```

O projeto serve simultaneamente como prova de conceito técnica do Living Lab Fiqueok e como base de portfólio demonstrando arquitetura IGA enterprise em escala SME.

---

## 3. Escopo

### 3.1 Dentro do Escopo

- Instalação e configuração do midPoint 4.x com repositório PostgreSQL
- Instalação e configuração do OrangeHRM Community Edition como fonte autoritativa
- Configuração de conector entre midPoint e OrangeHRM
- Configuração de conector entre midPoint e Active Directory
- Mapeamento de atributos de identidade entre os três sistemas
- Validação do fluxo de importação de identidades (Joiner flow)
- Documentação de todas as mudanças via GMUDs

### 3.2 Fora do Escopo

- Provisionamento automatizado completo de ciclo de vida (Mover/Leaver)
- Sincronização de senhas
- HashiCorp Vault para gestão de credenciais
- Role-Based Provisioning
- Ambiente de produção

---

## 4. Arquitetura de Referência

```
┌─────────────────┐     Conector     ┌──────────────────┐     Conector LDAP    ┌──────────────┐
│   OrangeHRM     │ ───────────────► │    midPoint       │ ──────────────────► │     AD       │
│  (MariaDB 11.4) │                  │  (IGA Engine)     │                     │  (ID-P-01)   │
│  Porta 8081     │                  │  Porta 8080       │                     │  Porta 389   │
│  IP: 172.16.0.x │                  │  IP: xxx.xxx.xxx.xxx │                     │  xxx.xxx.xxx.xxx │
└─────────────────┘                  └──────────────────┘                     └──────────────┘
        SSoT                              IGA Engine                              Target
```

**VM principal:** IGA-P-01 (Ubuntu Server, Hyper-V)  
**Orquestração:** Docker Compose  
**Rede:** Bridge isolada entre containers + VLAN Management

---

## 5. Infraestrutura Planejada

| Componente | Tecnologia | Função |
|------------|------------|--------|
| IGA Engine | midPoint 4.x + PostgreSQL | Motor de governança de identidades |
| HR Source | OrangeHRM Community + MariaDB 11.4 | Fonte autoritativa de identidades |
| Target | Active Directory (ID-P-01) | Diretório corporativo |
| Rede | Docker bridge + Hyper-V vSwitch | Conectividade segura entre componentes |

---

## 6. GMUDs Previstas

| GMUD | Objetivo |
|------|----------|
| GMUD-008 | Implantação da stack midPoint 4.10 |
| GMUD-009 | Implantação do OrangeHRM Community Edition |
| GMUD-010 | Configuração do Resource OrangeHRM no midPoint |
| GMUD-011 | Validação de rede de integração segura |
| GMUD-013 | Configuração do Resource OrangeHRM v2 |
| GMUD-014 | Integração AD via LDAPS |
| GMUD-015 | Preparação de infraestrutura e segregação de rede |
| GMUD-016 | Integração AD via LDAP e linking de usuário |

---

## 7. Critérios de Sucesso

- midPoint operacional com repositório PostgreSQL estável
- OrangeHRM acessível e com dados de identidade carregados
- Conector midPoint → OrangeHRM funcional com schema discovery completo
- Conector midPoint → AD funcional com Test Connection 5/5
- Ao menos um usuário com shadow linked em OrangeHRM e AD
- Fluxo de importação automática de identidades funcionando end-to-end

---

## 8. Riscos Identificados

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| Incompatibilidade de versão midPoint | Média | Alto | Usar versão LTS |
| Falha no conector OrangeHRM | Média | Alto | Avaliar alternativas (ScriptedSQL, CSV) |
| Certificado TLS no AD | Alta | Médio | Iniciar com LDAP 389, migrar para LDAPS |
| Perda de configuração | Baixa | Alto | Checkpoints Hyper-V antes de cada GMUD |

---

## 9. Premissas

- Ambiente completamente isolado (laboratório, sem impacto em produção)
- Paulo Feitosa como único executor técnico
- IAs generativas como suporte de orientação técnica
- Governança via sistema de GMUDs documentadas no Obsidian

---

## 10. Aprovação

| Papel | Nome | Data |
|-------|------|------|
| Owner/CISO | Paulo Feitosa | Dezembro/2025 |

