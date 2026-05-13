

**Plano de Recuperação FINAL - midPoint Corrupção Lógica**

**Fiqueok Living Lab - GRC/IAM Open-Source Platform**

**FONTE ÚNICA DA VERDADE** - ChatGPT Senior Architect EXECUTAR

---

## Informações Básicas **(Status Pós-GMUD-015-FIX-NET)**

|Campo|Valor|
|---|---|
|**ID do Incidente**|INC-FQK-2025-015B|
|**Status Rede**|✅ **VLAN 1 /16 UNIFICADA** (GMUD-015-FIX-NET ✅)|
|**IGA-P-01 IP**|✅ **xxx.xxx.xxx.xxx/16 ESTÁTICO**|
|**Conectividade AD**|✅ **xxx.xxx.xxx.xxx/16 OK**|
|**Impedimento**|❌ **midPoint GUI Fatal Error** (Resource 20MB)|
|**Responsável Execução**|**ChatGPT (Senior Systems Architect)**|
|**GRC Lead**|Perplexity Pro (Validação/Relatório)|
|**Data Execução**|**29/12/2025 18:52 BRT**|
|**Downtime Acumulado**|**~22 horas**|

---

## 1. Status Atual **(VALIDADO GMUD-015-FIX-NET)**

text

`✅ VLAN 1 Management: xxx.xxx.xxx.xxx/16 UNIFICADA ✅ IGA-P-01: xxx.xxx.xxx.xxx/16 ESTÁTICO (netplan) ✅ AD ID-P-01: xxx.xxx.xxx.xxx/16 OK ✅ VLAN 20: 192.168.20.10/24 ISOLADA ✅ Rotas limpas, DNS corp.fiqueok.com.br funcional ❌ midPoint: Resource AD-Fiqueok 20MB → HTTP 500`

**Conectividade Confirmada**:

bash

`ping -c 4 xxx.xxx.xxx.xxx          # AD <10ms ✅ nslookup corp.fiqueok.com.br   # DNS OK ✅ nc -zv xxx.xxx.xxx.xxx 5432       # PostgreSQL OK ✅ curl -k https://xxx.xxx.xxx.xxx:8080/midpoint  # HTTP 500 ❌`

---

## 2. Causa Raiz **(Gemini Deep-Dive + ChatGPT Feedback)**

text

`Full Schema Discovery AD → 10.000 atributos →  Resource XML 20MB → GUI Parser Fail → Fatal Error 500 PostgreSQL intacto → midPoint OFFLINE`

**Guardrails ADR-002 v4.0**:

text

`❌ PROIBIDO: RAW XML editing ✅ OBRIGATÓRIO: OSA Pattern (5 atributos) ✅ Perplexity Threat validação prévia ✅ Checkpoint-VM Hyper-V pré-execução ✅ docker ps INVENTÁRIO containers`

---

## 3. Plano Execução **(DEFINITIVO v4.0 - ChatGPT SEGUIR EXATAMENTE)**

## **PASSO 0 - SAFETY FIRST** **(Checkpoint Hyper-V OFICIAL)**

powershell

`# Hyper-V Host (Administrator PowerShell) Checkpoint-VM -Name "IGA-P-01" -CheckpointName "INC-015B-RECOVERY-START-v4" Get-VMCheckpoint -VMName "IGA-P-01" | Where-Object {$_.CheckpointName -eq "INC-015B-RECOVERY-START-v4"}`

**CONFIRMAR**: Checkpoint criado **ANTES QUALQUER** ação

## **PASSO 0.1 - INVENTÁRIO Containers** **(NOVO - CRÍTICO)**

bash

`# IGA-P-01 sudo docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}"`

**REGISTRAR IDs reais**:

text

`EXEMPLO ESPERADO: abc123def456    postgres-16     postgres:16    Up 2 hours ghi789jkl012    midpoint-4.10   midpoint:4.10  Up 2 hours`

**SUBSTITUIR** `postgres-16` e `midpoint-4.10` pelos **IDs reais** nos próximos passos.

## **PASSO 1 - Remoção SQL Cirúrgica** **(Container IDs Reais)**

bash

`# IGA-P-01 → PostgreSQL REAL (substituir <POSTGRES_ID>) sudo docker exec -it <POSTGRES_ID> psql -U usermidpoint -d midpoint # 1.1 IDENTIFICAR Resource corrupto SELECT oid, name, fullObjectSize FROM mgenericobject  WHERE oclass='Resource' AND name LIKE '%AD%'; # 1.2 BACKUP AUDITORIA (CRÍTICO) COPY (SELECT * FROM mgenericobject WHERE name='AD-Fiqueok')  TO '/tmp/AD-Fiqueok-corrupted-backup.sql'; # 1.3 REMOÇÃO CIRÚRGICA DELETE FROM mgenericobject WHERE name='AD-Fiqueok' AND oclass='Resource'; VACUUM FULL ANALYZE mgenericobject; # 1.4 VERIFICAR LIMPEZA SELECT COUNT(*) FROM mgenericobject WHERE oclass='Resource'; \q`

**SAÍDA ESPERADA**: `Resource count -1`, sem erros

## **PASSO 2 - Restabelecimento midPoint** **(Container ID Real)**

bash

`# Substituir <MIDPOINT_ID> sudo docker restart <MIDPOINT_ID> sudo docker logs <MIDPOINT_ID> --tail 30 | grep -E "started|fatal|error|repository" # Validação GUI CRÍTICA curl -k -w "HTTP %{http_code}\n" https://xxx.xxx.xxx.xxx:8080/midpoint -o /dev/null`

**CRITÉRIO ACEITE**: `HTTP 200` **(sem Fatal Error)**

## **PASSO 3 - Recriação Resource OSA Minimalista** **(GUI STRICT 5 ATRIBUTOS)**

text

`Browser → https://xxx.xxx.xxx.xxx:8080/midpoint Administration → Resources → New Resource → LDAP CONFIGURAÇÃO OBRIGATÓRIA: ├── Name: AD-Fiqueok-OSA-v4 ├── Server Host: xxx.xxx.xxx.xxx ├── Port: 389 ├── Bind DN: CN=svc-midpoint,CN=Users,DC=corp,DC=fiqueok,DC=com,DC=br ├── Bind Password: LabPassword123! └── ATTRIBUTOS OSA (EXATAMENTE 5):     ✅ sAMAccountName    ✅ mail    ✅ memberOf    ✅ givenName    ✅ sn    ❌ SEM outros atributos    ❌ SEM Schema Discovery    ❌ SEM RAW XML editing`

**Test Connection → SAVE → CONFIRMAR GUI**

## **PASSO 4 - Validação End-to-End** **(Produção)**

bash

`# 4.1 LDAP conectividade pura ldapsearch -x -H ldap://xxx.xxx.xxx.xxx:389 \   -D "CN=svc-midpoint,CN=Users,DC=corp,DC=fiqueok,DC=com,DC=br" \  -w LabPassword123! -b "DC=corp,DC=fiqueok,DC=com,DC=br" \  "(sAMAccountName=jdoe)" sAMAccountName mail memberOf givenName sn # 4.2 midPoint Resource sync (GUI) Administration → AD-Fiqueok-OSA-v4 → Test Connection ✅ # 4.3 Provisioning E2E (OrangeHRM → AD) OrangeHRM → User teste → Sync midPoint → Verificar AD: Get-ADUser -Filter "sAMAccountName -eq 'test-user-osa'"`

**CRITÉRIO FINAL**: `1 usuário provisionado AD via midPoint`

---

## 4. Rollback **(IMEDIATO - 2 MIN)**

text

`ERRO QUALQUER PASSO → EXECUTAR: powershell Restore-VMSnapshot -VMName "IGA-P-01" -VMCheckpointName "INC-015B-RECOVERY-START-v4" -Confirm:$false`

**NOTIFICAR**: Perplexity Pro + Paulo Feitosa **IMEDIATAMENTE**

---

## 5. Critérios de Aceite **(ChatGPT ASSINAR)**

|#|Critério|Comando/Evidência|Status|
|---|---|---|---|
|**0**|Checkpoint Hyper-V|`Get-VMCheckpoint "INC-015B-RECOVERY-START-v4"`|⏳|
|**0.1**|Inventário containers|`docker ps` IDs reais|⏳|
|**1**|Resource removido|`SELECT COUNT(*) Resource` (-1)|⏳|
|**2**|midPoint HTTP 200|`curl ... HTTP 200`|⏳|
|**3**|Resource OSA 5 attrs|GUI screenshot|⏳|
|**4**|1 User provisionado|`Get-ADUser test-user-osa`|⏳|

---

## 6. **EXECUÇÃO OBRIGATÓRIA ChatGPT** **(22h+ DOWNTIME)**

text

`🚨 PRIORIDADE ABSOLUTA - v4.0 DEFINITIVA 🚨 🔢 SEQUÊNCIA RÍGIDA (NÃO PULAR): 1. PASSO 0 → Checkpoint-VM "INC-015B-RECOVERY-START-v4" 2. PASSO 0.1 → docker ps → REGISTRAR IDs reais 3. PASSO 1 → docker exec <POSTGRES_ID> SQL DELETE 4. PASSO 2 → docker restart <MIDPOINT_ID> → HTTP 200 5. PASSO 3 → GUI OSA EXATOS 5 atributos 6. PASSO 4 → ldapsearch + 1 user AD 📊 REPORTAR CADA PASSO: - Saída comando - Screenshot GUI (Passo 3) - Logs docker (Passo 2) ⏰ ETA: 45-60 minutos ✅ NOTIFICAR Perplexity PASSO 4 👑 APROVAÇÃO Paulo PASSO 4`

---

## 7. Pós-Success **(Perplexity GRC Automático)**

text

`✅ INC-FQK-2025-015B → RESOLVED v4.0 📄 REL-INC-FQK-2025-015B-FINAL ✅ GMUD-015B v2 → Schema OSA produção 🚀 Sprint 2 → Vault PKI VLAN 20`

---

## 8. Métricas **(Rastreabilidade Auditoria)**

|Métrica|Meta v4.0|Status|
|---|---|---|
|**MTTR Total**|<24h|22h+ ⏳|
|**Checkpoint**|Criado v4|⏳|
|**Container IDs**|Reais docker ps|⏳|
|**HTTP Recovery**|200|⏳|
|**OSA Strict**|5 attrs|⏳|
|**E2E Provisioning**|1 user|⏳|

**Documento EXECUTION v4.0 - ChatGPT Senior Architect**

**Riscos Eliminados**: Comandos Hyper-V corretos, inventário containers, OSA 5 attrs rigoroso[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7936776c-8d58-4aa7-ab09-af98f352e657/INC-FQK-2025-015B-Report.docx)​

1. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7936776c-8d58-4aa7-ab09-af98f352e657/INC-FQK-2025-015B-Report.docx](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7936776c-8d58-4aa7-ab09-af98f352e657/INC-FQK-2025-015B-Report.docx)
2. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)
3. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/69453806/8b752095-bea6-4afc-9f66-47865821338b/image.jpg](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/69453806/8b752095-bea6-4afc-9f66-47865821338b/image.jpg)
4. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/f7f143fa-1114-485f-b573-f26c5c253213/INC-FQK-2025-015B-Report.docx](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/f7f143fa-1114-485f-b573-f26c5c253213/INC-FQK-2025-015B-Report.docx)
5. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/1c29766f-2123-4381-891f-9f843cdddd0b/ADR-001-Redistribuicao-de-Papeis-e-Responsabilidades-das-IAs.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/1c29766f-2123-4381-891f-9f843cdddd0b/ADR-001-Redistribuicao-de-Papeis-e-Responsabilidades-das-IAs.md)
6. [https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/69453806/e06ca9a6-2775-40f2-901f-150bc8d62ad3/image.jpg](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/69453806/e06ca9a6-2775-40f2-901f-150bc8d62ad3/image.jpg)
