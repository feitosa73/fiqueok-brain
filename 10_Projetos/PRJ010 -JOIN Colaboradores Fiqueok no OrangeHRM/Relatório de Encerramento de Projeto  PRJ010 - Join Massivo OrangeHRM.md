# 

## 1. Sumário Executivo

O projeto **PRJ010** consistiu na carga massiva e automação do processo de **Joiner** para 100 colaboradores da FinPay no sistema OrangeHRM 5.x. O objetivo foi estabelecer o RH como **Fonte Autoritativa** única, garantindo a integridade de dados biográficos, financeiros e de acesso.

## 2. Objetivos Alcançados ✅

- **Carga de Identidades**: 100% dos colaboradores da `Lista De Funcionarios.txt` foram provisionados.
    
- **Integridade Financeira**: Sucesso na transposição de salários após saneamento de metadados.
    
- **Governança RBAC**: Implementação de matriz de acesso vinculando `SecurityGroups` a `User Roles`.
    
- **Padronização**: Homologação do **POP-IAM-001** para futuras replicações.
    

## 3. Gestão de Incidentes e Resiliência (Show-off Técnico)

Durante a execução, o projeto enfrentou desafios reais que foram mitigados seguindo as melhores práticas de GRC:

|**Incidente**|**Categoria**|**Impacto**|**Mitigação Aplicada**|
|---|---|---|---|
|**Divergência de Metadados**|Integridade|Falha no JOIN de Cargos/Departamentos.|Execução de injeção massiva de _Job Titles_ via script antes da carga de funcionários.|
|**Violação de FK (Pay Period)**|Compliance|Erro 1452 na inserção de salários.|Saneamento da tabela de referência `hs_hr_payperiod` garantindo conformidade com o Schema.|
|**Inconsistência de String**|Qualidade|Zero registros afetados inicialmente.|Aplicação da função `TRIM()` para higienização de espaços em branco na Fonte Autoritativa.|

## 4. Conformidade e Governança (Visão Auditor)

- **ISO 27001 (A.9.2.2)**: O processo de concessão de acesso foi 100% automatizado, eliminando o risco de privilégios excessivos por erro manual.
    
- **ISO 27001 (A.12.1.2)**: Uso de **Staging Table** isolada no banco `greenfield_hr` para proteger o ambiente de produção durante a carga.
    
- **Rastreabilidade**: O uso de `EmployeeID` como âncora garante a auditabilidade do ciclo de vida da identidade do RH ao Entra ID.
