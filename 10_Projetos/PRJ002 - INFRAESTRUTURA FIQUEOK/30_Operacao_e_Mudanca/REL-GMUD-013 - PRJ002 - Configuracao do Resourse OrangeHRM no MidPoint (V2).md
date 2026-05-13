# Relatório de Encerramento de Mudança (REL-GMUD-013)

## 1. Identificação e Metadados

- **ID da Mudança:** GMUD-013
    
- **Título:** Integração de Fonte Autoritativa (HR) - OrangeHRM
    
- **Data de Encerramento:** 26/12/2025
    
- **Responsável:** Paulo (Consultor Sênior IAM/IGA & Auditor ISO 27001)
    
- **Status Final:** 🟡 **PARCIALMENTE EXECUTADA / SUSPENSA**
    

---

## 2. Resumo da Execução

A mudança foi executada para sanar as falhas críticas da GMUD-010, estabelecendo a conectividade entre o midPoint 4.10 e o banco de dados MariaDB do OrangeHRM. O ambiente foi sanitizado e o driver JDBC foi injetado com sucesso. Contudo, a execução da Fase III (Importação) foi suspensa por decisão estratégica para evitar a criação de identidades sem o respectivo provisionamento no Active Directory (dependente da GMUD-014/015).

### ✅ Etapas Concluídas (Sucesso Técnico)

- **Sanitização (Fase I):** Injeção do `mariadb-java-client-3.1.2.jar` em `/opt/midpoint/var/lib/` e reinicialização da stack concluídas.
    
- **Configuração e Discovery (Fase II):** O **Test Connection** via interface gráfica (GUI) retornou status positivo, validando o mapeamento automático da tabela `hs_hr_employee`.
    
- **Mapeamento de Atributos:** Schema Handling configurado para `employee_id` (ICF Name), `givenName`, `familyName` e extensão de cargo.
    

### ⚠️ Etapas Pendentes (Suspensão Técnica)

- **Importação Inicial (Fase III):** Os usuários **Rose Araujo** e **Daniel Ribeiro** ainda não foram criados no repositório do midPoint.
    
- **Motivo da Suspensão:** A integridade do fluxo de provisionamento outbound para o AD (GMUD-014) apresentou falhas de TLS, tornando prudente o adiamento da importação da fonte autoritativa para manter a consistência entre os sistemas.
    

---

## 3. Validação dos Critérios de Aceite

|**Teste**|**Resultado**|**Evidência**|
|---|---|---|
|**Conectividade**|✅ Sucesso|Log: "Connection to resource successful"|
|**Integridade (Rose)**|❌ Pendente|Aguardando estabilização do Target AD|
|**Integridade (Daniel)**|❌ Pendente|Aguardando estabilização do Target AD|
|**Atributos**|🟡 Validado em Schema|Mapeamento confirmado via Discovery|

---

## 4. Análise de Riscos e Auditoria (ISO 27001)

- **Gestão de Dependências:** Como Auditor, a decisão de suspender a importação demonstra controle sobre o ciclo de vida da identidade. Importar identidades sem um destino configurado (Target) poderia gerar inconsistências de reconciliação futura.
    
- **Continuidade:** A configuração do Resource OrangeHRM permanece persistida e validada, reduzindo o esforço técnico para a retomada das atividades na **GMUD-015**.