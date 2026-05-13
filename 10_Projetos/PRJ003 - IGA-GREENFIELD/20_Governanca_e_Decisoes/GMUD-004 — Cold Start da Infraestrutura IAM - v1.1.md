#

**Versão:** v1.1  
**Projeto:** PRJ003 — IGA Greenfield  
**Tipo:** GMUD — Mudança Planejada  
**Status:** Aprovada / Executada  
**Responsável:** Paulo Feitosa  
**Apoio Técnico:** ChatGPT  
**Data:** 14/01/2026

---

## 1. Objetivo da GMUD

Estabelecer o **cold start da infraestrutura IAM** do PRJ003, criando um ambiente **virgem, isolado e estável**, preparado para receber, em mudanças posteriores, os componentes da arquitetura de identidade (midPoint, persistência e integrações), **sem antecipar decisões funcionais ou semânticas**.

Esta GMUD trata **exclusivamente da fundação de infraestrutura e runtime**, preservando a separação entre:

- base técnica (infraestrutura)
    
- arquitetura de identidade (governança e semântica)
    

---

## 2. Escopo da Mudança

### 2.1 Incluído no Escopo

- Provisionamento de ambiente IAM em estado virgem
    
- Criação de VM dedicada ao PRJ003, sem conflito com ambientes existentes
    
- Instalação e validação do sistema operacional (Ubuntu Server LTS)
    
- Configuração de conectividade de rede e acesso remoto (SSH)
    
- Instalação e validação do runtime de containers:
    
    - Docker Engine
        
    - Docker Compose Plugin
        
- Validação de inicialização e estabilidade da infraestrutura
    
- Preparação do ambiente para futura execução do midPoint
    
- Registro técnico e rastreável da infraestrutura base
    

---

### 2.2 Explicitamente Fora do Escopo

- Execução funcional do midPoint
    
- Configuração de banco de dados (PostgreSQL)
    
- Criação de volumes Docker de persistência
    
- Qualquer integração funcional (AD, OrangeHRM ou outros sistemas)
    
- Ingestão ou provisionamento de identidades
    
- Automação de lifecycle (JML)
    
- Decisões semânticas de identidade em tempo de execução
    

---

## 3. Justificativa da Versão v1.1

Durante a execução desta mudança, foi consolidado o entendimento de que a **execução do midPoint e sua persistência** representam um **marco arquitetural de identidade**, mesmo quando realizadas em estado inicial.

Para preservar:

- clareza arquitetural,
    
- rastreabilidade das decisões,
    
- e coerência didática do Living Lab,
    

o escopo desta GMUD foi **refinado documentalmente**, mantendo o foco exclusivo na **infraestrutura base**, sem alterar a execução já realizada.

Este ajuste representa **alinhamento de governança**, não mudança de objetivo.

---

## 4. Premissas e Restrições

- O ambiente não deve conflitar com o PRJ002
    
- Nenhuma integração funcional será testada ou configurada
    
- Nenhum valor de negócio ou identidade será buscado nesta GMUD
    
- O ambiente deve permanecer reutilizável para GMUDs futuras
    

---

## 5. Critérios de Sucesso

A GMUD-004 é considerada bem-sucedida quando:

- A VM inicializa corretamente
    
- O sistema operacional está funcional e acessível remotamente
    
- O runtime de containers está instalado e operacional
    
- O ambiente permanece estável após reinício
    
- Não há carga funcional de identidade
    
- Não há integrações ou automações ativas
    

---

## 6. Dependências

- Disponibilidade de host de virtualização
    
- Imagem ISO do Ubuntu Server
    
- Conectividade básica de rede
    

---

## 7. Observações de Governança

A comprovação da execução desta GMUD, bem como as evidências técnicas e validações realizadas, serão registradas **exclusivamente** no documento **REL-GMUD-004**, mantendo a separação formal entre decisão e execução.

---

### ✅ GMUD-004 — v1.1

**Documento de decisão e planejamento — conforme modelo definido no Living Lab**