#

**Data:** 23/12/2025
**Decisor:** Paulo Feitosa (Arquiteto/CISO)
**Status:** Aprovado

## 1. Contexto
A Fiqueok necessita de um mecanismo para gerenciar o Ciclo de Vida de Identidades (JML - Joiner, Mover, Leaver) no Active Directory.

## 2. Opções Avaliadas
* **Opção A (Rejeitada):** Scripts PowerShell customizados lendo CSV.
    * *Prós:* Rápido de implementar, baixo consumo de recursos.
    * *Contras:* Difícil manutenção, sem trilha de auditoria nativa, sem interface de aprovação, cria dependência de conhecimento tácito ("o script do Paulo").
* **Opção B (Selecionada):** Plataforma IGA Open Source (MidPoint).
    * *Prós:* Conformidade nativa com ISO 27001 (A.9.2), Interface Web, Workflows de aprovação, Reconciliação automática (detecta mudanças manuais indevidas).
    * *Contras:* Curva de aprendizado e necessidade de infraestrutura Linux adicional.

## 3. Decisão
Optou-se pela **Opção B (MidPoint)**.

## 4. Justificativa de Negócio (GRC)
A implementação de um IGA centralizado atende ao princípio de **"Segurança desde a Concepção" (Security by Design)**. Garante que o Active Directory seja apenas um repositório de autenticação, removendo a discricionariedade humana na criação de acessos e garantindo que toda identidade tenha uma fonte autoritativa auditável.