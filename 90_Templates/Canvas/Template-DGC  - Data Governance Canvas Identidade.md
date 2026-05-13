

**Tipo:** Canvas de Governança de Dados  
**Domínio:** Identidade e Acesso (IAM / IGA)  
**Aplicação:** Projetos de Identidade  
**Versão do Template:** 1.0  

---

## 1. Objetivo do Canvas

Este canvas define **como dados de identidade são governados ao longo do tempo**, abordando:

- retenção
- histórico
- rastreabilidade
- auditoria
- exceções
- descarte

Ele **não define semântica nem autoridade primária** (isso pertence ao CAN-ID).  
Ele governa **o ciclo de vida do dado**, não da identidade.

---

## 2. Escopo de Dados

Descrever quais categorias de dados este canvas governa.

Exemplos:
- dados cadastrais
- dados organizacionais
- dados técnicos
- dados de auditoria
- metadados de identidade

---

## 3. Retenção de Dados

Definir políticas de retenção por categoria.

| Categoria de Dado | Retenção | Justificativa |
|------------------|----------|---------------|

---

## 4. Histórico e Versionamento

Definir:
- quais dados mantêm histórico
- por quanto tempo
- se o histórico é imutável
- se versões podem ser sobrescritas

---

## 5. Rastreabilidade e Auditoria

Definir:
- quais eventos devem ser auditáveis
- nível de detalhe
- relação com GMUD / ADR
- evidências mínimas exigidas

---

## 6. Correção e Exceções

Definir:
- como correções são feitas
- quem pode corrigir
- quando exceção é permitida
- como exceções são registradas

---

## 7. Eliminação e Descarte de Dados

Definir:
- critérios de descarte
- descarte lógico vs físico
- impacto regulatório (ex: LGPD)
- relação com desligamento

---

## 8. Papéis Envolvidos

| Papel | Responsabilidade |
|------|------------------|
| Owner de Dados | |
| Governança | |
| Operação | |
| Auditoria | |

---

## 9. Relação com Outros Artefatos

- CAN-ID-001 / 002 / 003
- DEC-ID
- ADRs
- GMUDs
- C4

---

## 10. Limites do Canvas

Este canvas **não define**:
- estrutura de identidade
- estados semânticos
- workflows técnicos
- autoridade de dado por sistema

---

## 11. Controle de Versão

| Versão | Data | Autor | Mudança |
|------|------|------|--------|
