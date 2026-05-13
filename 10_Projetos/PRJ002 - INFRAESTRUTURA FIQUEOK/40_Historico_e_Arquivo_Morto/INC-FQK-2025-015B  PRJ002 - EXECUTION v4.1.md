# 

**Plano de Recuperação FINAL CORRIGIDO - midPoint Corrupção Lógica**

**Fiqueok Living Lab - GRC/IAM Open-Source Platform**

**FONTE ÚNICA DA VERDADE v4.1** - ChatGPT Senior Architect EXECUTAR

---

## 0. CONTEXTO GERAL **(Jornada Completa Fiqueok Lab)**

## 0.1. **Evolução Infraestrutura**

text

`V1.0 → Rede Plana (xxx.xxx.xxx.xxx/16)   ↓ GMUD-001 a 014 V2.0 → Segmentação VLANs (GMUD-015A)   ↓ Falha Silenciosa VLAN 1 (/16 vs /24) Sprint 2 → GMUD-015B (LDAP midPoint-AD)   ↓ Full Schema Discovery → INC-FQK-2025-015B GMUD-015-FIX-NET → Rede normalizada   ↓ v4.1 → RECUPERAÇÃO FINAL`

## 0.2. **Causa Raiz Completa INC-FQK-2025-015B**

text

`GMUD-015B → Integração LDAP insegura (porta 389) 1. Schema Discovery COMPLETO AD (10.000 attrs) 2. Resource AD-Fiqueok → XML 20MB (midpoint.m_generic_object) 3. GUI Parser Fail → Fatal Error 500 4. Rede instável (/16 vs /24) → Recuperação BLOQUEADA 5. GMUD-015-FIX-NET → Rede OK → v4.1 EXECUTAR`

**Downtime Acumulado**: **~23 horas** (28/12 19:30 → 29/12 19:32)

---

## Informações Básicas **(Status Pós-GMUD-015-FIX-NET + Schema Refinado)**

|Campo|Valor|
|---|---|
|**ID do Incidente**|INC-FQK-2025-015B|
|**Versão Documento**|**v4.1** (Schema PostgreSQL real corrigido)|
|**Status Rede**|✅ **VLAN 1 /16 UNIFICADA** (GMUD-015-FIX-NET ✅)|
|**IGA-P-01**|Ubuntu 24.04 → **xxx.xxx.xxx.xxx/16 ESTÁTICO**|
|**AD ID-P-01**|Windows Server 2022 → **xxx.xxx.xxx.xxx/16**|
|**Impedimento**|❌ **midPoint GUI Fatal Error** (Generic Object 20MB)|
|**Schema Real**|**midpoint.m_generic_object + midpoint.m_resource**|
|**Responsável**|**ChatGPT (Senior Systems Architect)**|
|**GRC Lead**|Perplexity Pro|
|**Data**|**29/12/2025 19:32 BRT**|

---

## Histórico de Revisão **(Completo)**

|Versão|Data|Alterações Críticas|Responsável|
|---|---|---|---|
|**v4.0**|18:52|Hyper-V Checkpoint + docker ps|Perplexity|
|**v4.1**|**19:32**|**Schema REAL**: `midpoint.m_generic_object`  <br>**Sanity**: `octet_length(full_object)`  <br>**DELETE qualificado**|Perplexity + ChatGPT|

**Discrepância**: `mgenericobject` (teórico) ≠ `midpoint.m_generic_object` (real midPoint 4.10 Docker)

---

## 1. Status Atual **(VALIDADO Completo)**

text

`🏗️ INFRAESTRUTURA ATUAL (Pós-GMUD-015-FIX-NET): ├── VLAN 1 Mgmt: xxx.xxx.xxx.xxx/16 ✅ UNIFICADA │   ├── IGA-P-01: xxx.xxx.xxx.xxx/16 (netplan estático) │   └── AD ID-P-01: xxx.xxx.xxx.xxx/16 ✅ ├── VLAN 20 PKI: 192.168.20.10/24 ✅ ISOLADA ├── Docker Stack IGA: │   ├── postgres-16: porta 5432 ✅ │   └── midpoint-4.10: porta 8080 HTTP 500 ❌ └── DNS: corp.fiqueok.com.br → xxx.xxx.xxx.xxx ✅`

**Testes Pré-Execução**:

bash

`ping -c 4 xxx.xxx.xxx.xxx          # AD <10ms ✅ nslookup corp.fiqueok.com.br   # DNS OK ✅ nc -zv xxx.xxx.xxx.xxx 5432       # PostgreSQL OK ✅ curl -k https://xxx.xxx.xxx.xxx:8080/midpoint  # HTTP 500 ❌ (esperado)`

---

## 2. Causa Raiz **(Refinada Completa)**

text

`1. GMUD-015B → LDAP midPoint-AD (porta 389) 2. Full Schema Discovery → 10.000 attrs AD 3. Generic Object: midpoint.m_generic_object → XML ~20MB 4. GUI Parser Fail → Fatal Error 500 5. Rede instável (/16 vs /24) → GMUD-015-FIX-NET 6. Schema discrepância → v4.1 CORRIGIDA`

**Localização Física**:

text

`DATABASE: midpoint (postgres-16) ├── m_resource: metadados Resource └── m_generic_object: full_object ~20MB (AD-Fiqueok)`

---

## 3. Plano Execução **(DEFINITIVO v4.1 - Schema REAL)**

## **PASSO 0 - SAFETY FIRST** **(Hyper-V Checkpoint OFICIAL)**

powershell

`# Hyper-V Host (Administrator) Checkpoint-VM -Name "IGA-P-01" -CheckpointName "INC-015B-RECOVERY-v4.1" Get-VMCheckpoint -VMName "IGA-P-01" | Where-Object {$_.CheckpointName -eq "INC-015B-RECOVERY-v4.1"}`

**OUTPUT**: Checkpoint criado ✅ **REPORTAR**

## **PASSO 0.1 - INVENTÁRIO Docker** **(IDs REAIS)**

bash

`# IGA-P-01 sudo docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" | grep -E "postgres|midpoint"`

**REGISTRAR**:

text

`<POSTGRES_ID>    postgres-16    postgres:16    Up X hours <MIDPOINT_ID>    midpoint-4.10  midpoint:4.10  Up X hours`

**SUBSTITUIR** nos próximos passos **EXATAMENTE**

## **PASSO 1 - Sanity Check + Cirurgia SQL** **(Schema REAL)**

bash

`sudo docker exec -it <POSTGRES_ID> psql -U usermidpoint -d midpoint`

sql

`-- 1.1 RESOURCES (metadados) SELECT id, name FROM midpoint.m_resource WHERE name LIKE '%AD%'; -- 1.2 SANITY CHECK VILÃO 20MB SELECT oid, name, octet_length(full_object) as size_bytes FROM midpoint.m_generic_object WHERE name = 'AD-Fiqueok'; -- ESPERADO: ~20971520 bytes (20MB) ← CONFIRMAR -- 1.3 BACKUP AUDITÓRIO COPY (SELECT * FROM midpoint.m_generic_object WHERE name='AD-Fiqueok')  TO '/tmp/AD-Fiqueok-v4.1-backup.sql'; -- 1.4 DELETE CIRÚRGICO DELETE FROM midpoint.m_generic_object WHERE name = 'AD-Fiqueok'; VACUUM FULL ANALYZE midpoint.m_generic_object; -- 1.5 VERIFICAÇÃO SELECT COUNT(*) FROM midpoint.m_generic_object WHERE name = 'AD-Fiqueok'; \q`

**CRITÉRIO**: `size_bytes ~20MB` → `COUNT = 0` ✅ **REPORTAR**

## **PASSO 2 - Restart midPoint**

bash

`sudo docker restart <MIDPOINT_ID> sudo docker logs <MIDPOINT_ID> --tail 50 | grep -E "started|fatal|error|generic|repository" curl -k -w "HTTP %{http_code}\n" https://xxx.xxx.xxx.xxx:8080/midpoint -o /dev/null`

**CRITÉRIO**: `HTTP 200` ✅ **REPORTAR**

## **PASSO 3 - Resource OSA Minimalista** **(GUI 5 ATRIBUTOS)**

text

`https://xxx.xxx.xxx.xxx:8080/midpoint → Administration → Resources → New → LDAP AD-Fiqueok-OSA-v4.1: ├── Host: xxx.xxx.xxx.xxx:389 ├── Bind: CN=svc-midpoint,CN=Users,DC=corp,DC=fiqueok,DC=com,DC=br ├── Password: LabPassword123! └── ATTRS OSA (5 EXATOS):     ✅ sAMAccountName    ✅ mail    ✅ memberOf    ✅ givenName    ✅ sn`

**Test Connection → SAVE → Screenshot** ✅ **REPORTAR**

## **PASSO 4 - E2E Provisioning**

bash

`# LDAP ldapsearch -x -H ldap://xxx.xxx.xxx.xxx:389 -D "CN=svc-midpoint..." -w LabPassword123! \ -b "DC=corp,DC=fiqueok,DC=com,DC=br" "(sAMAccountName=jdoe)" sAMAccountName mail # OrangeHRM → midPoint → AD Get-ADUser -Filter "sAMAccountName -eq 'test-osa-v4.1'"`

**CRITÉRIO FINAL**: 1 user AD ✅ **REPORTAR**

---

## 4. Rollback **(2 MIN)**

powershell

`Restore-VMSnapshot -VMName "IGA-P-01" -VMCheckpointName "INC-015B-RECOVERY-v4.1" -Confirm:$false`

---

## 5. Critérios Aceite **(Checklist ChatGPT)**

|#|Critério|Evidência|Status|
|---|---|---|---|
|0|Checkpoint v4.1|`Get-VMCheckpoint`|⏳|
|0.1|Docker IDs|`docker ps` reais|⏳|
|1|Sanity 20MB|`octet_length ~20MB`|⏳|
|1|DELETE|`COUNT=0`|⏳|
|2|HTTP 200|`curl 200`|⏳|
|3|OSA 5 attrs|GUI screenshot|⏳|
|4|1 User AD|`Get-ADUser`|⏳|

---

## 6. EXECUÇÃO **ChatGPT** **(23h+ DOWNTIME)**

text

`🚨 v4.1 DEFINITIVA - CONTEXTO COMPLETO 🚨 1. PASSO 0 → Checkpoint 2. PASSO 0.1 → docker ps → REPORTAR IDs 3. PASSO 1 → Sanity 20MB → DELETE → REPORTAR 4. PASSO 2 → Restart → HTTP 200 → REPORTAR 5. PASSO 3 → GUI 5 attrs → Screenshot 6. PASSO 4 → E2E user AD → REPORTAR ⏰ ETA: 45min ✅ Perplexity PASSO 4 👑 Paulo APROVAÇÃO FINAL`

**SIM**: Contexto geral **COMPLETO** - Jornada V1→V2, causa raiz detalhada, histórico revisão, status infra atualizado.[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7936776c-8d58-4aa7-ab09-af98f352e657/INC-FQK-2025-015B-Report.docx)​

1. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7936776c-8d58-4aa7-ab09-af98f352e657/INC-FQK-2025-015B-Report.docx](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7936776c-8d58-4aa7-ab09-af98f352e657/INC-FQK-2025-015B-Report.docx)
2. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)
3. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/69453806/8b752095-bea6-4afc-9f66-47865821338b/image.jpg](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/69453806/8b752095-bea6-4afc-9f66-47865821338b/image.jpg)
4. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/f7f143fa-1114-485f-b573-f26c5c253213/INC-FQK-2025-015B-Report.docx](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/f7f143fa-1114-485f-b573-f26c5c253213/INC-FQK-2025-015B-Report.docx)
5. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/1c29766f-2123-4381-891f-9f843cdddd0b/ADR-001-Redistribuicao-de-Papeis-e-Responsabilidades-das-IAs.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/1c29766f-2123-4381-891f-9f843cdddd0b/ADR-001-Redistribuicao-de-Papeis-e-Responsabilidades-das-IAs.md)
6. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/69453806/e06ca9a6-2775-40f2-901f-150bc8d62ad3/image.jpg](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/69453806/e06ca9a6-2775-40f2-901f-150bc8d62ad3/image.jpg)
