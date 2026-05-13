# 🏁 Relatório de Encerramento: GMUD-003 - Hardening RPC

## 1. Dados da Execução
* **ID:** GMUD-003
* **Título:** Hardening de RPC e Tratamento de Falso Positivo
* **Data/Hora:** 19/12/2025 - 17:15
* **Executor:** Paulo (SysAdmin/Auditor)
* **Ativo Afetado:** DC01 (192.168.56.10)
* **Status:** ✅ Concluída com Sucesso

## 2. Racional Estratégico (Motivação da Mudança)
Durante a análise da vulnerabilidade de *Null Session Enumeration* (Porta 135/RPC), foi executado um procedimento de validação prévia (Pre-Change Testing).

1.  **Diagnóstico Pré-Mudança:**
    * O registro `RestrictAnonymous` estava configurado como `0` (Vulnerável segundo CIS Benchmarks).
    * **Teste de Exploração (PoC):** Foi realizada tentativa de extração de usuários via `rpcclient` (LinuxLite). O servidor retornou `NT_STATUS_ACCESS_DENIED`.
    * **Conclusão:** O ambiente já possuía mitigação nativa via ACLs do Windows Server 2019, tornando o risco imediato inexistente.

2.  **Tratamento no DefectDojo:**
    * Com base na PoC, o alerta foi classificado como **Falso Positivo/Mitigado** na plataforma de gestão.

3.  **Justificativa para Execução (Por que aplicar mesmo assim?):**
    * Optou-se por aplicar a correção de registro (`RestrictAnonymous = 1`) para **eliminar a detecção na origem (Scanner)**.
    * **Objetivo de Governança:** Evitar que a supressão administrativa do alerta no DefectDojo mascare uma eventual regressão de configuração futura. Se a mitigação via ACL falhar no futuro, o registro garantirá a segurança. Além disso, garante que o scanner pare de reportar o item, mantendo o Dashboard limpo por correção técnica e não apenas burocrática.

## 3. Ações Executadas
* Alteração da chave de registro: `Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Lsa -Name RestrictAnonymous -Value 1`.
* Reinicialização do Servidor (Reboot) para efetivação do LSA.

## 4. Validação Pós-Mudança (Evidências)
Foram realizados os testes de aceitação com os seguintes resultados:

* **[Passou] Teste 1 - Conformidade:** Comando `Get-ItemProperty` confirmou o valor `1` no registro.
* **[Passou] Teste 2 - Saúde (Regressão):** Login via RDP funcional e serviços de diretório (AD) operantes sem erros críticos no `dcdiag`.
* **[Passou] Teste 3 - Eficácia:** Nova tentativa de ataque via `rpcclient` retornou erro de acesso, confirmando que a porta permanece fechada, agora suportada por configuração explícita de Hardening.

---
**Parecer do Auditor:** A mudança elevou o nível de maturidade do ambiente, alinhando a configuração técnica (Registry) com a prática de segurança (ACLs), eliminando ruídos no processo de Gestão de Vulnerabilidades.
