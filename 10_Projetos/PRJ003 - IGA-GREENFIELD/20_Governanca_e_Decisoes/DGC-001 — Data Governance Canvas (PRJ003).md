

**Projeto:** PRJ003 — IGA Greenfield Reference Architecture  
**Tipo:** Data Governance Canvas (Identidade)  
**Status:** Consolidado (v1.0)  
**Data:** 2026-01-14  
**Owner:** Paulo Feitosa  
**Contexto:** Living Lab Fiqueok 2.0  

---

## 1. Objetivo do Canvas

Definir como os **dados de identidade** do PRJ003 são:

- armazenados
- versionados
- auditados
- corrigidos
- descartados

O objetivo é garantir **rastreabilidade, previsibilidade e aprendizado**, sem criar complexidade desnecessária para o Lab.

---

## 2. Escopo de Dados

| Categoria | Descrição |
|---------|-----------|
| Dados Canônicos | Identidade consolidada |
| Dados Organizacionais | Vínculos e atributos de negócio |
| Dados Técnicos | Contas e identificadores |
| Estados | Estados semânticos da identidade |
| Auditoria | Eventos e decisões |

---

## 3. Retenção de Dados

| Categoria | Retenção | Justificativa |
|---------|----------|---------------|
| Identidade Canônica | Permanente | Referência histórica |
| Estados da Identidade | Permanente | Rastreabilidade |
| Dados Técnicos | Enquanto ativo | Recriação possível |
| Eventos de Lifecycle | Permanente | Evidência de decisão |
| Logs Técnicos | Limitada | Apoio operacional |

---

## 4. Histórico e Versionamento

- Identidade e estados mantêm **histórico completo**
- Alterações não sobrescrevem valores sem registro
- Versionamento lógico é obrigatório
- Histórico é somente leitura

---

## 5. Rastreabilidade e Auditoria

Devem ser auditáveis:
- criação de identidade
- mudança de estado
- correção manual
- exceções
- GMUDs executadas

Evidências mínimas:
- data
- autor
- motivo
- artefato relacionado (GMUD / ADR)

---

## 6. Correção e Exceções

- Correções manuais são permitidas **apenas pelo Owner**
- Exceções devem ser:
  - explícitas
  - registradas
  - reversíveis
- Nenhuma correção silenciosa é permitida

---

## 7. Eliminação e Descarte

- Descarte físico **não é aplicado no Lab**
- Desligamento implica:
  - mudança de estado
  - desativação técnica
  - preservação histórica
- Dados são mantidos para aprendizado e auditoria

---

## 8. Papéis Envolvidos

| Papel | Responsabilidade |
|------|------------------|
| Owner do Projeto | Governança final |
| IGA | Registro e execução |
| Governança | Validação de exceções |
| Auditoria | Consulta e evidência |

---

## 9. Relação com Outros Artefatos

- CAN-ID-001 — Identidade Canônica  
- CAN-ID-002 — Autoridade de Dados  
- CAN-ID-003 — Estados da Identidade  
- DEC-ID-001 — Identity Decision Canvas  
- GMUD-003 — Arquitetura Lógica  
- C4 — Contexto  

---

## 10. Limites

Este canvas **não redefine autoridade**, **não cria semântica** e **não altera estados**.  
Ele governa **o tratamento do dado**, não o significado.

---

## 11. Controle de Versão

| Versão | Data | Autor | Mudança |
|------|------|------|--------|
| 1.0 | 2026-01-14 | Paulo Feitosa | Criação do DGC-001 |
