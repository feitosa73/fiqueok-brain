# 

**Plano de Recuperação Final - midPoint Corrupção Lógica**

**Fiqueok Living Lab - GRC/IAM Open-Source Platform**

**FONTE ÚNICA DA VERDADE** - ChatGPT Senior Architect EXECUTAR

---

## Informações Básicas **(Status Atual)**

|Campo|Valor|
|---|---|
|**ID do Incidente**|INC-FQK-2025-015B|
|**Status Rede**|✅ **NORMALIZADA** (GMUD-015-FIX-NET executada)|
|**Ambiente**|IGA-P-01 Ubuntu 24.04 → midPoint 4.10 Docker|
|**Conectividade**|✅ IGA xxx.xxx.xxx.xxx/16 ↔ AD xxx.xxx.xxx.xxx/16|
|**Impedimento**|❌ **midPoint GUI Fatal Error** (Resource 20MB)|
|**Responsável Execução**|**ChatGPT (Senior Systems Architect)**|
|**GRC Lead**|Perplexity Pro (Validação/Relatório)|
|**Data Execução**|**29/12/2025 18:43 BRT**|
|**Downtime Acumulado**|**~21 horas**|

---

## 1. Status Atual **(Pós-GMUD-015-FIX-NET)**

text

`✅ VLAN 1 unificada /16 (xxx.xxx.xxx.xxx/16) ✅ IGA-P-01: xxx.xxx.xxx.xxx/16 ESTÁTICO ✅ AD ID-P-01: xxx.xxx.xxx.xxx/16 OK ✅ VLAN 20 isolada: 192.168.20.10/24 ✅ Rotas limpas, DNS funcional ❌ midPoint: Resource AD-Fiqueok 20MB → GUI OFFLINE`

**Conectividade Validada**:

bash

`ping xxx.xxx.xxx.xxx # AD <10ms ✅ nslookup corp.fiqueok.com.br # DNS OK ✅ curl -k https://xxx.xxx.xxx.xxx:8080/midpoint # HTTP 500 ❌`

---

## 2. Causa Raiz **(Consolidada Gemini Deep-Dive)**

text

`Full Schema Discovery AD → 10.000 atributos →  Resource XML 20MB → Parser Fail → GUI Fatal Error 500 → PostgreSQL intacto, midPoint OFFLINE`

**Guardrails ADR-002**:

text

`❌ Proibido: RAW XML editing ✅ Obrigatório: OSA Pattern (5 atributos) ✅ Perplexity Threat validação prévia ✅ Snapshot VM pré-execução`

---

## 3. Plano Execução **(RIGOROSO - ChatGPT SEGUIR EXATAMENTE)**

## **PASSO 0 - SAFETY FIRST** **(OBRIGATÓRIO)**

powershell

`# Hyper-V Host (Administrator) New-VMSnapshot -VMName "IGA-P-01" -Name "INC-015B-RECOVERY-START" Get-VMSnapshot -VMName "IGA-P-01" | Where-Object {$_.Name -eq "INC-015B-RECOVERY-START"}`

**CONFIRMAR**: Snapshot criado antes QUALQUER ação

## **PASSO 1 - Remoção SQL Cirúrgica**

bash

`# IGA-P-01 → PostgreSQL (usermidpoint/midpoint) sudo docker exec -it postgres-16 psql -U usermidpoint -d midpoint # 1.1 Identificar Resource corrupto SELECT oid, name, fullObjectSize FROM mgenericobject  WHERE oclass='Resource' AND name LIKE '%AD%'; # 1.2 BACKUP AUDITORIA (CRÍTICO) COPY (SELECT * FROM mgenericobject WHERE name='AD-Fiqueok')  TO '/tmp/AD-Fiqueok-corrupted-backup.sql'; # 1.3 REMOÇÃO DELETE FROM mgenericobject WHERE name='AD-Fiqueok' AND oclass='Resource'; VACUUM ANALYZE mgenericobject; # 1.4 VERIFICAR SELECT COUNT(*) FROM mgenericobject WHERE oclass='Resource'; \q`

**SAÍDA ESPERADA**: Resource removido, contagem Resources -1

## **PASSO 2 - Restabelecimento midPoint**

bash

`# IGA-P-01 sudo docker restart midpoint-4.10 sudo docker logs midpoint-4.10 --tail 50 | grep -E "started|fatal|error" # Validação GUI curl -k -w "HTTP %{http_code}\n" https://xxx.xxx.xxx.xxx:8080/midpoint -o /dev/null`

**CRITÉRIO ACEITE**: `HTTP 200` (sem Fatal Error)

## **PASSO 3 - Recriação Resource OSA Minimalista** **(GUI ONLY)**

text

`Browser → https://xxx.xxx.xxx.xxx:8080/midpoint Administration → Resources → New Resource → LDAP Resource Name: AD-Fiqueok-OSA Server Host: xxx.xxx.xxx.xxx Port: 389 Bind DN: CN=svc-midpoint,CN=Users,DC=corp,DC=fiqueok,DC=com,DC=br Bind Password: LabPassword123! ATTRIBUTOS OSA (APENAS 5): ✅ sAMAccountName ✅ mail ✅ memberOf ✅ givenName ✅ sn ❌ SEM Schema Discovery ❌ SEM RAW XML`

**Test Connection → SAVE**

## **PASSO 4 - Validação End-to-End**

bash

`# 4.1 LDAP conectividade ldapsearch -x -H ldap://xxx.xxx.xxx.xxx:389 \   -D "CN=svc-midpoint,CN=Users,DC=corp,DC=fiqueok,DC=com,DC=br" \  -w LabPassword123! -b "DC=corp,DC=fiqueok,DC=com,DC=br" \  "(sAMAccountName=jdoe)" sAMAccountName mail memberOf # 4.2 midPoint Resource sync (GUI) Administration → Resources → AD-Fiqueok-OSA → Test Connection ✅ # 4.3 Provisioning teste (OrangeHRM → AD) Criar user teste OrangeHRM → Sync midPoint → Verificar AD`

**CRITÉRIO FINAL**: 1 usuário provisionado AD via midPoint

---

## 4. Rollback **(IMEDIATO)**

text

`ERRO QUALQUER PASSO → EXECUTAR: 1. Restaurar Snapshot "INC-015B-RECOVERY-START" 2. NOTIFICAR Perplexity Pro + Paulo Feitosa 3. Manter INC OPEN (rede OK, midPoint OFF)`

---

## 5. Critérios de Aceite **(ChatGPT CONFIRMAR)**

|Critério|Comando/Evidência|Status|
|---|---|---|
|**Snapshot Pré**|`Get-VMSnapshot "INC-015B-RECOVERY-START"`|⏳|
|**Resource Removido**|`SELECT COUNT(*) mgenericobject Resource`|⏳|
|**midPoint HTTP 200**|`curl ... HTTP 200`|⏳|
|**Resource OSA Criado**|GUI 5 atributos|⏳|
|**LDAP Teste OK**|`ldapsearch jdoe`|⏳|
|**1 User Provisionado**|AD user criado via midPoint|⏳|

---

## 6. **HANDOFF EXECUÇÃO ChatGPT** **(IMEDIATO)**

text

`🚨 PRIORIDADE ABSOLUTA - 21h+ DOWNTIME 🚨 SEQUÊNCIA OBRIGATÓRIA: 1. PASSO 0 → Snapshot "INC-015B-RECOVERY-START" 2. PASSO 1 → SQL DELETE + VACUUM 3. PASSO 2 → Docker restart + HTTP 200 4. PASSO 3 → GUI OSA 5 atributos 5. PASSO 4 → ldapsearch + 1 user provisionado 6. REPORTAR CADA PASSO neste thread ⏰ ETA TOTAL: 45-60 minutos 📄 NOTIFICAR Perplexity ao final PASSO 4 👑 APROVAÇÃO Paulo Feitosa PASSO 4`

---

## 7. Pós-Recuperação **(Perplexity GRC)**

text

`✅ INC-FQK-2025-015B → RESOLVED ↓ 📄 REL-INC-FQK-2025-015B-FINAL ↓ ✅ GMUD-015B v2 → Schema OSA produção ↓ 🚀 Sprint 2 → Vault PKI VLAN 20`

---

## 8. Métricas Alvo

|Métrica|Meta|Atual|
|---|---|---|
|**MTTR Total**|<24h|21h+ ⏳|
|**Recuperação**|60 min|⏳|
|**Provisioning E2E**|1 user|⏳|
|**RPO**|Zero perda|✅|

**Documento classificado EXECUTION - ChatGPT Senior Architect**

1. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)
2. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-<REDACTED_SECRET>95-bea6-4afc-9f66-47865821338b/image.jpg](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-<REDACTED_SECRET>95-bea6-4afc-9f66-47865821338b/image.jpg)
3. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/f7f143fa-1114-485f-b573-f26c5c253213/INC-FQK-2025-015B-Report.docx](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/f7f143fa-1114-485f-b573-f26c5c253213/INC-FQK-2025-015B-Report.docx)
4. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/1c29766f-2123-4381-891f-9f843cdddd0b/ADR-001-Redistribuicao-de-Papeis-e-Responsabilidades-das-IAs.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/1c29766f-2123-4381-891f-9f843cdddd0b/ADR-001-Redistribuicao-de-Papeis-e-Responsabilidades-das-IAs.md)
5. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-<REDACTED_SECRET>a6-2775-40f2-901f-150bc8d62ad3/image.jpg](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-<REDACTED_SECRET>a6-2775-40f2-901f-150bc8d62ad3/image.jpg)
6. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7936776c-8d58-4aa7-ab09-af98f352e657/INC-FQK-2025-015B-Report.docx](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7936776c-8d58-4aa7-ab09-af98f352e657/INC-FQK-2025-015B-Report.docx)
