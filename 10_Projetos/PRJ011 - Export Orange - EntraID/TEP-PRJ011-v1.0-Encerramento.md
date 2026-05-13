# TERMO DE ENCERRAMENTO DO PROJETO
**Codigo:** PRJ011
**Versao:** 1.0
**Data de Encerramento:** 01 de Marco de 2026
**Responsavel:** Paulo Feitosa Lima - GRC Lead
**GRC Lead AI:** Perplexity AI - Threat Intelligence
**Ambiente:** Living Lab Fiqueok - Hybrid Cloud Lab
**Classificacao:** Confidencial Interno

---

## CHANGELOG

| Versao | Data       | Mudancas                                    |
|--------|------------|---------------------------------------------|
| 1.0    | 01/03/2026 | Criacao - Encerramento formal do PRJ011     |

---

## 1. IDENTIFICACAO DO PROJETO

| Campo                    | Valor                                                              |
|--------------------------|-------------------------------------------------------------------|
| **Codigo**               | PRJ011                                                            |
| **Nome**                 | Entra ID Identity JOIN - Fiqueok Tenant Population                |
| **Categoria**            | Cloud IAM / IGA / AZ-305 Lab                                      |
| **Patrocinador**         | Paulo Feitosa Lima                                                |
| **Data de Inicio**       | 01/03/2026                                                        |
| **Data de Encerramento** | 01/03/2026                                                        |
| **Duracao Real**         | ~4 horas (sessao unica - 18h00 as 22h00)                          |
| **POP de Referencia**    | POP-IAM-002 v1.0 - Provisioning OrangeHRM -> Microsoft Entra ID  |
| **Pre-requisito**        | PRJ010 concluido (OrangeHRM 100 users OK)                         |
| **Dominio**              | fiqueok.com.br (Registro.br + Cloudflare DNS)                     |

---

## 2. RESUMO EXECUTIVO

O PRJ011 teve como objetivo provisionar as 100 identidades digitais da Fiqueok, originadas do sistema de RH OrangeHRM (PRJ010), no diretorio de nuvem Microsoft Entra ID (tenant fiqueok.com.br), estabelecendo o plano de identidade corporativo com UPNs profissionais, grupos de seguranca e bases para Governanca de Identidade (IGA).

O projeto foi executado em sessao unica no dia 01/03/2026, utilizando a abordagem de JOIN DIRETO via CSV + PowerShell Microsoft Graph API (Cenario A - Script Manual), conforme documentado no POP-IAM-002. Apos a correcao de um erro de sintaxe no script de provisionamento (parametro booleano via Splatting - Licao L03 do POP), os 100 usuarios foram provisionados com sucesso no tenant, com todos os atributos de governanca preenchidos.

---

## 3. OBJETIVOS - STATUS FINAL

| ID  | Objetivo Especifico                                               | Status       | Evidencia                               |
|-----|-------------------------------------------------------------------|:------------:|-----------------------------------------|
| OS1 | Verificar dominio fiqueok.com.br no Entra ID (TXT Cloudflare)    | OK           | PF2 - TXT MS=ms97322072 confirmado      |
| OS2 | Exportar 100 identidades do OrangeHRM (MariaDB -> CSV)           | OK           | fiqueok_entraid_users.csv (100 linhas)  |
| OS3 | Provisionar 100 usuarios via PowerShell (New-MgUser bulk)        | OK           | Evidencia_Final_Provisionamento.csv     |
| OS4 | Criar grupos de seguranca GRP_* por Department/JobTitle          | PENDENTE     | Previsto para PRJ011-Fase2              |
| OS5 | Aplicar Conditional Access (C-Level: FIDO2 + MFA rigoroso)       | PENDENTE     | Previsto para PRJ011-Fase3              |
| OS6 | Configurar PIM para CSO (Donner Marcos) e CHRO (Laszlo Bock)     | PENDENTE     | Previsto para PRJ011-Fase3              |
| OS7 | Validar audit logs (primeiro login + risk detection David Velez)  | PENDENTE     | Previsto para PRJ011-Fase4              |

> **Nota:** OS4 a OS7 representam a segunda fase do PRJ011, a ser executada em sessao subsequente. O criterio de encerramento desta sprint (OS3 - 100 usuarios provisionados) foi atingido com sucesso.

---

## 4. ENTREGAVEIS - STATUS

| ID | Entregavel                          | Formato | Status   | Local / Observacao                                          |
|----|-------------------------------------|---------|:--------:|-------------------------------------------------------------|
| E1 | fiqueok_entraid_users.csv           | CSV     | ENTREGUE | PRJ011 - Export Orange - EntraID                            |
| E2 | Provisioning_Script.ps1             | PS1     | ENTREGUE | ...PRJ011\Scripts\Provisioning_Script.ps1                   |
| E3 | PRJ011-groups.ps1                   | PS1     | PENDENTE | Previsto - criacao de grupos GRP_*                          |
| E4 | TAP-PRJ011-v1.0.md                  | MD      | ENTREGUE | Obsidian - PRJ011 - Export Orange - EntraID                 |
| E5 | Evidencia_Final_Provisionamento.csv | CSV     | ENTREGUE | 100 usuarios com CreatedDateTime - 01/03/2026 22h           |
| E6 | POP-IAM-002 v1.0                    | DOCX    | ENTREGUE | Procedimento operacional padrao formalizado                 |
| E7 | Termo de Encerramento PRJ011        | MD      | ESTE DOC | Obsidian - PRJ011 / Documentacao                            |

---

## 5. CRITERIOS DE SUCESSO - AVALIACAO FINAL

### 5.1 Gate de Entrada (Planejamento)

| ID  | Criterio                                              | Resultado |
|-----|-------------------------------------------------------|:---------:|
| CP1 | GATE-PRJ011-001 100% OK (16 pre-flights verdes)       | OK        |
| CP2 | CSV exportado com 100 linhas, 0 duplicatas            | OK        |
| CP3 | PowerShell conectado ao tenant fiqueok.com.br         | OK        |

### 5.2 Gate de Saida (Execucao - Sprint 1)

| ID  | Criterio                                                              | Resultado | Observacao                                         |
|-----|-----------------------------------------------------------------------|:---------:|----------------------------------------------------|
| CE1 | 100 usuarios ativos no Entra ID (UPN @fiqueok.com.br)                 | OK        | Evidencia_Final_Provisionamento.csv - 100 registros |
| CE2 | 10 grupos dinamicos GRP_* provisionados e populados                   | PENDENTE  | Proxima sessao                                     |
| CE3 | PIM elegivel para Donner Marcos (CSO) e Laszlo Bock (CHRO)           | PENDENTE  | Requer Entra ID P2                                 |
| CE4 | CA Policy 'CA-CEO-FIDO2' ativa para David Velez                       | PENDENTE  | Proxima sessao                                     |
| CE5 | Audit Logs visiveis no portal (rastreabilidade ISO 27001 A.9.2.2)    | OK        | Logs gerados automaticamente no Entra ID           |
| CE6 | T1-T8 aprovados (zero falhas criticas)                                | PARCIAL   | T1, T2, T8 concluidos. T3-T7 pendentes             |

---

## 6. EXECUCAO - LINHA DO TEMPO REAL

| Horario | Fase                         | Atividade                                                        | Status |
|---------|------------------------------|------------------------------------------------------------------|:------:|
| 17h30   | Fase 0 - Pre-Flight          | Verificacao de dominio, tenant, PowerShell e CSV                 | OK     |
| 18h00   | Fase 1 - Export OrangeHRM    | Query SQL MariaDB -> fiqueok_entraid_users.csv (100 linhas)      | OK     |
| 18h15   | Fase 1 - Correcao Encoding   | Sanitizacao UTF-8 (caracteres especiais -> CSV limpo via SCP)    | OK     |
| 18h30   | Fase 2 - Provisionamento v1  | Script PS1 executado - ERRO: parametro booleano posicional       | ERRO   |
| 19h00   | Fase 2 - Correcao Script     | Aplicada tecnica Splatting (@Params) - L03 do POP-IAM-002        | OK     |
| 19h30   | Fase 2 - Provisionamento v2  | Re-execucao com script corrigido - 100 usuarios criados          | OK     |
| 22h00   | Validacao Final              | Export Evidencia_Final_Provisionamento.csv - 100 registros       | OK     |

---

## 7. INCIDENTES E DESVIOS REGISTRADOS

| ID    | Tipo           | Descricao                                                                                                                   | Impacto | Resolucao                                                              |
|-------|----------------|-----------------------------------------------------------------------------------------------------------------------------|:-------:|------------------------------------------------------------------------|
| INC01 | Erro de Script | New-MgUser com -AccountEnabled $true retornou: 'Nao e possivel localizar parametro posicional que aceite True'              | Medio   | Refatoracao para Splatting (@Params) - 100 usuarios criados com sucesso |
| INC02 | Encoding       | CSV exportado com caracteres corrompidos (UTF-8 - acentos em A(c) e A tilde o)                                              | Baixo   | Re-exportacao do arquivo limpo via SCP (fiqueok_entraid_limpo.csv)      |
| INC03 | Diretorio      | Erro 'No such file or directory' na copia SCP inicial                                                                       | Baixo   | Criacao do diretorio C:\Users\paulo\Documents\PRJ011 via PowerShell     |

---

## 8. LICOES APRENDIDAS

Conforme consolidado no POP-IAM-002 v1.0, Secao 9.2:

| ID  | Licao                                                                                                                                          | Origem    |
|-----|------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| L01 | Usar conta administrativa NATIVA (.onmicrosoft.com) - contas MSA convidadas retornam HTTP 405 em escritas via Graph API                        | PRJ011    |
| L02 | Grupos Dinamicos exigem P1/P2. Erro NoLicenseForOperation (HTTP 400) ocorre em tenant Free ao usar GroupTypes=['DynamicMembership']             | PRJ011    |
| L03 | **Splatting (@Params) e obrigatorio para parametros booleanos no PowerShell** - evita o erro de parametro posicional com $true/$false           | PRJ011    |
| L04 | EmployeeID como ImmutableID e a ancora perfeita entre OrangeHRM e Entra ID. Nunca reutilizar ou alterar esse campo                             | PRJ010/11 |
| L05 | Sanitizacao de dados (remocao de acentos) deve ocorrer ANTES da exportacao para garantir compatibilidade dos UPNs                              | PRJ011    |

---

## 9. DECISOES TECNICAS FORMALIZADAS

| ID  | Decisao                                                               | Justificativa                                                                              | Impacto Futuro                        |
|-----|-----------------------------------------------------------------------|--------------------------------------------------------------------------------------------|---------------------------------------|
| D01 | JOIN DIRETO via CSV + PowerShell (sem midPoint/SCIM)                  | API OrangeHRM 5.x nao expoe endpoints RESTful estaveis para salary + securityGroup         | PRJ012 - Shadow API + midPoint retry  |
| D02 | EmployeeID (FP001-FP100) como ImmutableID/OnPremisesImmutableId       | Anchor Key consistente entre OrangeHRM e Entra ID - base para IGA futura                  | Obrigatorio em todos os projetos IAM  |
| D03 | Senha temporaria 'Fiqueok@2026!' com ForceChangePasswordNextSignIn    | Boa pratica de seguranca - rotacao obrigatoria no primeiro login                           | Politica de senha a ser formalizada   |
| D04 | PRJ009 (midPoint) mantido em FREEZE                                   | Incompatibilidade SQL staging cross-DB - risco de integridade no connector                 | Revisao prevista no PRJ012            |

---

## 10. RISCOS - STATUS FINAL

| ID | Risco                                   | Status Inicial | Status Final | Observacao                                       |
|----|----------------------------------------:|:--------------:|:------------:|--------------------------------------------------|
| R1 | UPN duplicado (email conflict)          | Media / Alto   | MITIGADO     | Validacao PF12 - 0 duplicatas confirmadas        |
| R2 | EmployeeID invalido como ImmutableID    | Alta / Medio   | MITIGADO     | FP001-FP100 como string - aceito pelo Entra ID   |
| R3 | Licenca P2 expirada/insuficiente        | Baixa / Critico| ABERTO       | PIM e CA dependem de P2 - pendente para Fase 2   |
| R4 | Throttling no bulk provisioning          | Media / Medio  | MITIGADO     | 100 usuarios criados sem bloqueio de tenant      |
| R5 | CA bloqueia proprio admin               | Baixa / Critico| ABERTO       | Break-glass a configurar na Fase 3               |
| R6 | midPoint nao integra futuro             | Alta / Baixo   | ACEITO       | Fallback documentado - PRJ012 Shadow API         |
| R7 | Senha temporaria vaza                   | Baixa / Alto   | MITIGADO     | ForceChangePasswordNextSignIn=$true aplicado     |

---

## 11. PROXIMOS PASSOS - PRJ011 FASE 2

Os itens abaixo representam a continuidade natural do PRJ011 e devem ser executados na proxima sessao:

1. **Criacao dos Grupos de Seguranca GRP_*** - 36 grupos mapeados no secgroup_role_map (Cenario A - estaticos, via POP-IAM-002 Secao 5.1 Passo 1)
2. **Associacao Usuario -> Grupo** - via campo SecurityGroup do CSV (Passo 3 do POP-IAM-002)
3. **Configuracao de Conditional Access** - Politicas CA1-CA7 para C-Level (TAP Secao 7.1)
4. **Configuracao de PIM** - Roles elegiveis para Donner Marcos (CSO) e Laszlo Bock (CHRO)
5. **Execucao dos Testes T3-T7** - Validacao de grupos, PIM, CA e Identity Protection
6. **Planejamento PRJ012** - Shadow API + midPoint Custom Connector (retry integracao automatica)

---

## 12. CHECKLIST DE ENCERRAMENTO (POP-IAM-002 Secao 8.3)

| # | Verificacao                                                                         | Status |
|---|------------------------------------------------------------------------------------|:------:|
| 1 | 100% dos usuarios FP* existem e estao ativos no Entra ID                            | OK     |
| 2 | Atributos Department e JobTitle preenchidos corretamente                            | OK     |
| 3 | Cada usuario membro de Security Group correspondente (Sprint 1 - provisionamento)   | PEND.  |
| 4 | Nenhum usuario desligado com AccountEnabled = True                                  | OK     |
| 5 | Relatorio CSV de evidencia exportado e arquivado                                    | OK     |
| 6 | Audit Log revisado para eventos 'Create user'                                      | OK     |
| 7 | Sessao PowerShell encerrada: Disconnect-MgGraph                                     | OK     |

---

## 13. METRICAS DE EXECUCAO

| Metrica                             | Planejado | Realizado |
|-------------------------------------|:---------:|:---------:|
| Usuarios provisionados              | 100       | **100**   |
| Usuarios com erro final             | 0         | **0**     |
| Incidentes registrados              | -         | **3**     |
| Duracao da sessao                   | 1-2 dias  | **~4h**   |
| Scripts entregues                   | 2         | **1**     |
| Documentos gerados                  | 4         | **6**     |

---

## 14. APROVACOES

| Funcao              | Nome               | Status           | Data       |
|---------------------|--------------------|:----------------:|------------|
| GRC Lead            | Paulo Feitosa Lima | Pendente         | 01/03/2026 |
| GRC Lead AI         | Perplexity AI      | Aprovado         | 01/03/2026 |
| Threat Intelligence | Perplexity AI      | Pipeline Ativo   | 01/03/2026 |

---

**FIM DO TERMO DE ENCERRAMENTO - PRJ011 v1.0**
_Documento gerado por Perplexity AI em 01/03/2026_
_Continuidade: PRJ011 Fase 2 (Grupos + CA + PIM) -> PRJ012 (Shadow API + midPoint)_
