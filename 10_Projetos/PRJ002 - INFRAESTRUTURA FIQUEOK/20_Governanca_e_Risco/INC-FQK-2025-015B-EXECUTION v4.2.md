# 

**Plano de Recuperação FINAL SISTÊMICO - Restauração IGA Completa**

**Fiqueok Living Lab - GRC/IAM Open-Source Platform**

**FONTE ÚNICA DA VERDADE v4.2** - ChatGPT Senior Architect EXECUTAR

---

## 0. CONTEXTO GERAL **(Governança Completa)**

## 0.1. **Timeline Histórica**

text

`V1.0 → GMUD-001-014 (Core IGA)   ↓ GMUD-009 ✅ OrangeHRM (hs_hr_employee)[file:9][file:8]  ↓ GMUD-010 ❌ OrangeHRM Resource (Schema fail)[file:10][file:11]  ↓ GMUD-013 ⏸️ OrangeHRM v2 (AD pendente)[file:13][file:12] V2.0 → GMUD-015A → Falha Rede /16 vs /24   ↓ GMUD-015B → Full Schema AD → INC-FQK-2025-015B[file:7]  ↓ GMUD-015-FIX-NET ✅ Rede /16  ↓ v4.1 → **Expurgo Lógico Detectado** (Resources VAZIOS) v4.2 → **RESTAURAÇÃO FONTE (OrangeHRM) + TARGET (AD)**`

**Downtime**: **~25 horas** (28/12 → 29/12 20:59 BRT)

---

## Informações Básicas **(Escopo Sistêmico)**

|Campo|Valor|
|---|---|
|**ID**|INC-FQK-2025-015B|
|**Versão**|**v4.2** (OrangeHRM + AD OSA)|
|**Rede**|✅ VLAN 1 /16 (GMUD-015-FIX-NET)|
|**IGA**|**xxx.xxx.xxx.xxx/16**|
|**Escopo**|**FONTE OrangeHRM + TARGET AD**|
|**Responsável**|**ChatGPT Senior Architect**|

---

## Histórico Revisão

|Versão|Data|Alterações|Responsável|
|---|---|---|---|
|v4.0|18:52|Hyper-V + docker ps|Perplexity|
|v4.1|19:31|Schema `midpoint.m_*`|ChatGPT|
|**v4.2**|**20:59**|**SISTÊMICO**: OrangeHRM (GMUD-010/013)[ppl-ai-file-upload.s3.amazonaws+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/ad250f0f-d8cf-47c4-be6c-f6bd99b936b8/GMUD-010-PRJ002-Configuracao-do-Resource-OrangeHRM-no-midPoint.md)​  <br>**ADENDO**: JDBC params + exceção Vault|**GRC Completo**|

---

## 1. **ADENDO TÉCNICO - Parâmetros OrangeHRM** **(OBRIGATÓRIO)**

## 1.1. **Conectividade Resource OrangeHRM**

text

`TIPO CONECTOR: JDBC / DatabaseTable (ICF) DRIVER: MariaDB Java Client 3.1.2 JDBC URL: jdbc:mariadb://orangehrm-db:3306/orangehrm HOSTNAME: orangehrm-db (fiqueok-backend-net interna) USUÁRIO: orangehrmro CREDENCIAL: FiqueokOrangeHRMRO2025StrongPass (Local Management) BANCO: orangehrm TABELA: hs_hr_employee (Fonte Única Verdade)`

## 1.2. **Escopo Ação**

text

`AÇÃO: Recriação lógica Resource Sqale midPoint PRESERVAÇÃO: ReadOnly - ZERO impacto MariaDB histórico FOCO: Mapeamento employeeid, empfirstname, emplastname`

## 1.3. **Risco Controlado**

text

`IMPACTO: Zero dados persistidos MITIGAÇÃO: Proibição Full Schema Discovery + OSA manual`

## 1.4. **Exceção Técnica AUTORIZADA**

text

`EXCEÇÃO: Credencial texto claro (sem Vault) JUSTIFICATIVA: Downtime >25h prioriza recuperação VAULT: GMUD-015C (pós-INC)`

---

## 2. Plano Execução **(Fase I/II - RÍGIDO)**

## **PASSO 0 - SAFETY FIRST**

powershell

`Checkpoint-VM -Name "IGA-P-01" -CheckpointName "INC-015B-SISTEMICO-v4.2" Get-VMCheckpoint -VMName "IGA-P-01" | ? {$_.CheckpointName -eq "INC-015B-SISTEMICO-v4.2"}`

## **PASSO 0.1 - INVENTÁRIO**

bash

`sudo docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}" | grep -E "postgres|midpoint|orangehrm" sudo docker network ls | grep -E "fiqueok-backend-net|orangehrmlabnet"`

**REGISTRAR**: `<POSTGRES_ID>`, `<MIDPOINT_ID>`, `<ORANGEHRM_DB_ID>`

## **FASE I - FONTE ORANGEHRM** **(GMUD-010/013)**[ppl-ai-file-upload.s3.amazonaws+1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/ad250f0f-d8cf-47c4-be6c-f6bd99b936b8/GMUD-010-PRJ002-Configuracao-do-Resource-OrangeHRM-no-midPoint.md)​

**Passo 1 - Sanity MariaDB**

bash

`sudo docker exec <ORANGEHRM_DB_ID> mariadb -u orangehrmro -pFiqueokOrangeHRMRO2025StrongPass orangehrm \ -e "SELECT COUNT(*), employeeid, empfirstname, emplastname FROM hs_hr_employee LIMIT 3;"`

**ESPERADO**: `hs_hr_employee` + dados Rose Araújo

**Passo 2 - Resource OrangeHRM** **(GUI + ADENDO)**

text

`https://xxx.xxx.xxx.xxx:8080/midpoint → New Resource → DatabaseTable OrangeHRM-Source-v4.2: ├── Connector: DatabaseTable ├── JDBC Driver: org.mariadb.jdbc.Driver ├── JDBC URL: jdbc:mariadb://orangehrm-db:3306/orangehrm?useSSL=false&allowPublicKeyRetrieval=true ├── User: orangehrmro ├── Password: FiqueokOrangeHRMRO2025StrongPass ├── Table: hs_hr_employee ├── Key Column: employeeid └── Test Connection → Schema Auto → SAVE`

**Mapeamentos Obrigatórios**:

text

`employeeid → personalNumber (Strong) empfirstname → givenName (Strong) emplastname → familyName (Strong) jobtitle → extension/jobTitle`

## **FASE II - TARGET AD OSA**

**Passo 3 - Resource AD**

text

`New Resource → LDAP AD-Target-OSA-v4.2: ├── Host: xxx.xxx.xxx.xxx:389 ├── Bind DN: CN=svc-midpoint,CN=Users,DC=corp,DC=fiqueok,DC=com,DC=br ├── Password: LabPassword123! └── ATTRS OSA (5 EXATOS):     ✅ sAMAccountName    ✅ mail    ✅ memberOf    ✅ givenName    ✅ sn`

**Test Connection → SAVE**

## **PASSO 4 - E2E Rose Araújo**

text

`1. OrangeHRM → Rose Araújo (employeeid) 2. midPoint → Tasks → Import OrangeHRM-Source-v4.2 → RUN 3. Users → Rose Araújo ✅ (personalNumber, givenName=empfirstname) 4. Reconciliação → AD-Target-OSA-v4.2 → Sync 5. AD → Get-ADUser rose.araújo ✅`

---

## 3. Rollback **(2 MIN)**

powershell

`Restore-VMSnapshot -VMName "IGA-P-01" -VMCheckpointName "INC-015B-SISTEMICO-v4.2"`

---

## 4. Critérios Aceite **(Sistêmico)**

|Fase|Critério|Evidência|
|---|---|---|
|**0**|Checkpoint v4.2|`Get-VMCheckpoint`|
|**I.1**|hs_hr_employee|`COUNT(*) > 0`|
|**I.2**|OrangeHRM Resource|GUI Test Connection + mapeamentos|
|**II.3**|AD OSA 5 attrs|GUI screenshot|
|**4**|Rose Araújo E2E|`Get-ADUser rose.araújo`|

---

## 5. **EXECUÇÃO ChatGPT** **(25h+ DOWNTIME)**

text

``🚨 v4.2 SISTÊMICA + ADENDO ORANGEHRM 🚨 1. PASSO 0 → Checkpoint "INC-015B-SISTEMICO-v4.2" 2. PASSO 0.1 → docker ps + networks REPORTAR 3. **FASE I** OrangeHRM (JDBC orangehrm-db:3306) 4. **FASE II** AD OSA (5 attrs) 5. **E2E** Rose Araújo fonte→target 📊 REPORTAR OBRIGATÓRIO: ✅ docker ps IDs + networks ✅ MariaDB `hs_hr_employee Rose Araújo` ✅ OrangeHRM Test Connection + JDBC screenshot ✅ AD 5 attrs screenshot ✅ Get-ADUser rose.araújo ⏰ ETA: 75min ✅ Perplexity FASE II 👑 Paulo FINAL``

**Lição Obsidian**: **Visão sistêmica GRC salvou IGA funcionalmente morto** - ChatGPT foco técnico isolado vs Paulo/Gemini visão completa.[ppl-ai-file-upload.s3.amazonaws+3](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7936776c-8d58-4aa7-ab09-af98f352e657/INC-FQK-2025-015B-Report.docx)​

1. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/ad250f0f-d8cf-47c4-be6c-f6bd99b936b8/GMUD-010-PRJ002-Configuracao-do-Resource-OrangeHRM-no-midPoint.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/ad250f0f-d8cf-47c4-be6c-f6bd99b936b8/GMUD-010-PRJ002-Configuracao-do-Resource-OrangeHRM-no-midPoint.md)
2. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/dc7a8920-ca68-46f4-b2b6-14b946785962/GMUD-013-PRJ002-Configuracao-do-Resource-OrangeHRM-no-midPoint-V2.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/dc7a8920-ca68-46f4-b2b6-14b946785962/GMUD-013-PRJ002-Configuracao-do-Resource-OrangeHRM-no-midPoint-V2.md)
3. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7936776c-8d58-4aa7-ab09-af98f352e657/INC-FQK-2025-015B-Report.docx](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7936776c-8d58-4aa7-ab09-af98f352e657/INC-FQK-2025-015B-Report.docx)
4. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/23c67a2e-451a-49cb-9c22-9526d78f2f8a/GMUD-009-PRJ002-Implementacao-OrangeHRM-Community-Edition.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/23c67a2e-451a-49cb-9c22-9526d78f2f8a/GMUD-009-PRJ002-Implementacao-OrangeHRM-Community-Edition.md)
5. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)
6. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-<REDACTED_SECRET>95-bea6-4afc-9f66-47865821338b/image.jpg](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-<REDACTED_SECRET>95-bea6-4afc-9f66-47865821338b/image.jpg)
7. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/f7f143fa-1114-485f-b573-f26c5c253213/INC-FQK-2025-015B-Report.docx](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/f7f143fa-1114-485f-b573-f26c5c253213/INC-FQK-2025-015B-Report.docx)
8. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/1c29766f-2123-4381-891f-9f843cdddd0b/ADR-001-Redistribuicao-de-Papeis-e-Responsabilidades-das-IAs.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/1c29766f-2123-4381-891f-9f843cdddd0b/ADR-001-Redistribuicao-de-Papeis-e-Responsabilidades-das-IAs.md)
9. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-<REDACTED_SECRET>a6-2775-40f2-901f-150bc8d62ad3/image.jpg](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-<REDACTED_SECRET>a6-2775-40f2-901f-150bc8d62ad3/image.jpg)
10. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/54b7d088-1d13-4f88-832d-1af5e5fe417a/REL-GMUD-009-PROJ002-Implantacao-do-OrangeHRM-Community-Edition.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/54b7d088-1d13-4f88-832d-1af5e5fe417a/REL-GMUD-009-PROJ002-Implantacao-do-OrangeHRM-Community-Edition.md)
11. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/83c9be28-b3ca-4be9-b717-a2956499c40e/REL-GMUD-010-PROJ002-Configuracao-do-Resource-OrangeHRM-no-MIdpoint-ENCERRADA-SEM-SUCESSO.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/83c9be28-b3ca-4be9-b717-a2956499c40e/REL-GMUD-010-PROJ002-Configuracao-do-Resource-OrangeHRM-no-MIdpoint-ENCERRADA-SEM-SUCESSO.md)
12. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/3dc09a96-d63f-4610-aa9e-b1b0c4f7bf26/REL-GMUD-013-PRJ002-Configuracao-do-Resourse-OrangeHRM-no-MidPoint-V2.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/3dc09a96-d63f-4610-aa9e-b1b0c4f7bf26/REL-GMUD-013-PRJ002-Configuracao-do-Resourse-OrangeHRM-no-MidPoint-V2.md)
