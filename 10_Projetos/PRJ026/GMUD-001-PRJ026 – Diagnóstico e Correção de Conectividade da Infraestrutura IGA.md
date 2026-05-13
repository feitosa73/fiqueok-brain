# 
**Gestão de Mudanças - Projeto PRJ026 (Integração midPoint ↔ Active Directory)**
**Living Lab Fiqueok - GRC/IAM Open-Source Platform**
---
## Informações Básicas da GMUD
| Campo | Valor |
|-------|-------|
| **ID da GMUD** | GMUD-001-PRJ026 |
| **Título** | Diagnóstico e Correção de Conectividade da Infraestrutura IGA (midPoint ↔ AD) |
| **Tipo** | Mudança Corretiva / Diagnóstica |
| **Versão Documento** | 1.0 |
| **Data de Criação** | 10/05/2026 |
| **Responsável Execução** | Paulo Feitosa Lima |
| **Projeto** | PRJ026 - Integração midPoint 4.10 com Active Directory |
| **Severidade** | ALTA (bloqueia integração IGA) |
| **Prioridade** | URGENTE |
| **Status** | 📝 PLANEJADA - AGUARDANDO EXECUÇÃO |
---
## 1. Contexto e Problema Identificado
### 1.1. Objetivo Original do PRJ026
O PRJ026 foi planejado para estabelecer integração bidirecional entre o **midPoint 4.10** e o **Active Directory**, permitindo provisionamento automático de usuários (Joiner/Mover/Leaver) e governança centralizada de identidades.
### 1.2. Bloqueador Identificado
Durante a fase de validação pré-execução do PRJ026, identificou-se que **o midPoint não consegue se comunicar com o Active Directory**, inviabilizando qualquer tentativa de integração.
**Evidência do bloqueio:**
| Teste | Origem | Destino | Resultado |
|-------|--------|---------|-----------|
| Ping | midPoint (iga-gf-02) | AD (172.24.192.10) | ❌ 100% packet loss |
| LDAP (389) | midPoint (iga-gf-02) | AD (172.24.192.10) | ❌ Conexão falhou |
| Ping | AD | Gateway (172.24.192.1) | ❌ Destination host unreachable |
### 1.3. Causa Raiz - Análise Documental
Após análise aprofundada dos documentos históricos do Living Lab (PRJ001 a PRJ027), identificou-se:
| Descoberta | Evidência |
|------------|-----------|
| **IP original do AD** | `xxx.xxx.xxx.xxx` (documentado em REL-GMUD-002, REL-GMUD-007, REL-GMUD-015, REL-GMUD-016, CONF-TEC-001) |
| **IP atual do AD** | `172.24.192.10` (constatado em diagnóstico de 10/05/2026) |
| **Mudança não documentada** | O AD foi movido para o Default Switch do Hyper-V em algum momento entre 06/01/2026 e 10/05/2026 |
| **Gateway configurado** | `172.24.192.1` (IP que não responde e não é o gateway do Default Switch) |
| **Gateway correto do Default Switch** | `172.23.192.1` (conforme ipconfig do host) |
| **midPoint** | Continua tentando alcançar o AD em `xxx.xxx.xxx.xxx` (configuração anterior) |
### 1.4. Diagnóstico da Rede
| Componente | IP | Gateway | Status |
|------------|-----|---------|--------|
| **Host (Default Switch)** | `172.23.192.1/20` | N/A | ✅ Operacional |
| **AD (ID-P-01)** | `172.24.192.10/20` | `172.24.192.1` (incorreto) | ⚠️ Isolado |
| **midPoint (iga-gf-02)** | `172.23.201.182/20` | DHCP (correto) | ✅ Operacional |
| **Tailscale** | `xxx.xxx.xxx.xxx` (host), `xxx.xxx.xxx.xxx` (midPoint) | ✅ | ✅ Operacional |
**Conclusão:** O AD está em uma sub-rede diferente do host e do midPoint (`172.24.x.x` vs `172.23.x.x`), com um gateway que não existe. A comunicação entre midPoint e AD é impossível nas condições atuais.
---
## 2. Decisões de Arquitetura e Segurança
### 2.1. Princípios Aplicados
| Princípio | Aplicação |
|-----------|-----------|
| **Blast radius controlado** | Rollback via checkpoint Hyper-V antes de qualquer alteração |
| **Infraestrutura como alicerce** | Resolver conectividade antes de qualquer integração IGA |
| **Segurança por camadas** | Não expor o AD à internet sem hardening |
| **Documentação como parte do sistema** | Todas as alterações documentadas nesta GMUD |
### 2.2. Decisão de Segurança: Não Expor o AD à Internet
**Risco identificado:** Conceder gateway e DNS ao AD sem hardening exporia um Domain Controller à internet, com portas críticas abertas (389, 445, 88, 135-139).
**Decisão:** ❌ **Não será concedido acesso direto à internet ao AD.**
**Caminho escolhido:** ✅ **Corrigir a configuração do midPoint para alcançar o AD no IP atual (`172.24.192.10`) e/ou ajustar a rede do AD para a mesma sub-rede do midPoint.**
---
## 3. Escopo da Mudança
### 3.1. Incluído na GMUD
| Item | Descrição | Justificativa |
|------|-----------|---------------|
| **Fase 1 - Diagnóstico Final** | Validar se o AD consegue receber tráfego na porta 389 via Tailscale | Testar alternativa de acesso seguro |
| **Fase 2 - Correção de Rota** | Ajustar gateway do AD para `172.23.192.1` (caso necessário) | Permitir comunicação com host e outras VMs |
| **Fase 3 - Atualização do midPoint** | Configurar Resource do AD no midPoint para apontar para `172.24.192.10` | Restaurar visibilidade do midPoint sobre o AD |
| **Fase 4 - Validação** | Testes de conectividade LDAP e integração básica | Confirmar resolução do bloqueio |
### 3.2. Excluído da GMUD
| Item | Justificativa |
|------|---------------|
| ❌ Instalação de Tailscale no AD | Avaliado e postergado para GMUD futura se necessário |
| ❌ Hardening completo do AD para acesso à internet | Fora do escopo - AD permanecerá isolado |
| ❌ Provisionamento automático de usuários (JML) | Escopo do PRJ026 original, será retomado após esta GMUD |
| ❌ Configuração de LDAPS (636) | Será tratado em GMUD específica após conectividade básica |
### 3.3. Abordagem Preferencial vs. Alternativa
| Abordagem | Descrição | Risco | Preferência |
|-----------|-----------|-------|-------------|
| **A (Preferencial)** | Ajustar midPoint para enxergar AD no IP atual (`172.24.192.10`) | Baixo | ✅ **Primeira tentativa** |
| **B (Alternativa)** | Ajustar gateway do AD para `172.23.192.1` e colocar na mesma sub-rede do midPoint | Médio | ⚠️ Segunda opção |
| **C (Contingência)** | Instalar Tailscale no AD e usar IP Tailscale para comunicação | Baixo | 🔄 Último recurso |
---
## 4. Plano de Execução
### 4.1. Pré-requisitos (Checkpoint Obrigatório)
```powershell
# No Hyper-V host (PowerShell como Administrador)
# Criar checkpoint de segurança antes de qualquer alteração
Checkpoint-VM -VMName "ID-P-01" -SnapshotName "PRE-GMUD-001-PRJ026-$(Get-Date -Format 'yyyyMMdd-HHmm')"
Checkpoint-VM -VMName "iga-gf-02" -SnapshotName "PRE-GMUD-001-PRJ026-$(Get-Date -Format 'yyyyMMdd-HHmm')"

**Critério:** ✅ Snapshots criados com sucesso antes de prosseguir.

---

### 4.2. Fase 1 - Abordagem Preferencial (Ajustar midPoint)

**Objetivo:** Configurar o midPoint para enxergar o AD no IP atual (`172.24.192.10`).

#### Passo 1.1: Verificar configuração atual do Resource AD no midPoint

bash

# No iga-gf-02 (via SSH)
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://172.23.201.182:8080/midpoint/ws/rest/resources" \
  | jq '.[] | select(.name | contains("Active Directory")) | {name: .name, oid: .oid}'

**Resultado esperado:** Identificar o OID do Resource AD para atualização.

#### Passo 1.2: Atualizar o Resource AD para o IP correto

bash

# Exportar configuração atual do Resource
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://172.23.201.182:8080/midpoint/ws/rest/resources/{OID}" \
  > /tmp/ad_resource_backup.xml
# Editar o arquivo XML para alterar o host de xxx.xxx.xxx.xxx para 172.24.192.10
sed -i 's/xxx.xxx.xxx.xxx/172.24.192.10/g' /tmp/ad_resource_backup.xml
# Aplicar a atualização
curl -X PUT -u administrator:'M1dP0!ntAdm!n#2026' \
  -H "Content-Type: application/xml" \
  -d @/tmp/ad_resource_backup.xml \
  "http://172.23.201.182:8080/midpoint/ws/rest/resources/{OID}"

#### Passo 1.3: Validar conectividade LDAP

bash

# Testar conexão LDAP do midPoint para o AD
docker exec iga-midpoint nc -zv 172.24.192.10 389

**Critério de sucesso:** ✅ `Connection to 172.24.192.10 389 port [tcp/ldap] succeeded!`

#### Passo 1.4: Testar Resource no midPoint

1. Acessar GUI do midPoint: `http://172.23.201.182:8080/midpoint`
    
2. Navegar: **Configuration → Resources → Active Directory**
    
3. Clicar em **Test Connection**
    
4. Validar: **5/5 fases com status SUCCESS**
    

---

### 4.3. Fase 2 - Abordagem Alternativa (Ajustar Rede do AD)

**Executar APENAS se a Fase 1 falhar (midPoint não alcançar `172.24.192.10`).**

#### Passo 2.1: Verificar gateway correto do Default Switch

powershell

# No console do AD
ipconfig | findstr "Gateway"

Gateway atual: `172.24.192.1` (incorreto)

Gateway correto da rede do host: `172.23.192.1`

#### Passo 2.2: Alterar gateway do AD

powershell

# No console do AD (PowerShell como Administrador)
# Remover rota padrão incorreta
Remove-NetRoute -DestinationPrefix "0.0.0.0/0" -InterfaceIndex 6 -Confirm:$false
# Adicionar rota padrão correta
New-NetRoute -DestinationPrefix "0.0.0.0/0" -NextHop "172.23.192.1" -InterfaceIndex 6
# Verificar a nova rota
Get-NetRoute -DestinationPrefix "0.0.0.0/0"

#### Passo 2.3: Configurar DNS (temporário para testes)

powershell

# No console do AD
Set-DnsClientServerAddress -InterfaceIndex 6 -ServerAddresses ("8.8.8.8", "1.1.1.1")

#### Passo 2.4: Testar conectividade

powershell

# Testes no console do AD
ping 172.23.192.1
ping 8.8.8.8
nslookup google.com

**Critério de sucesso:** ✅ Ping para `172.23.192.1` responde.

#### Passo 2.5: Liberar porta LDAP no firewall do AD (se necessário)

powershell

# No console do AD (verificar se já está liberada)
Get-NetFirewallRule -DisplayName "*LDAP*" | Select-Object DisplayName, Enabled
# Se necessário, criar regra
New-NetFirewallRule -DisplayName "LDAP para midPoint" -Direction Inbound -Protocol TCP -LocalPort 389 -Action Allow

---

### 4.4. Fase 3 - Validação Final

|#|Teste|Comando/Ação|Critério de Sucesso|
|---|---|---|---|
|1|Ping do midPoint para AD|`ping 172.24.192.10` (ou novo IP)|0% packet loss|
|2|Porta LDAP|`nc -zv 172.24.192.10 389`|Connection succeeded|
|3|Test Connection (midPoint GUI)|Resource AD → Test Connection|5/5 Success|
|4|Listar usuários AD via midPoint|Executar reconciliation task|Shadows criados|
|5|Rollback testado|Restaurar snapshot|< 5 minutos|

---

## 5. Matriz de Validação

|#|Teste|Resultado Esperado|Status|
|---|---|---|---|
|1|Checkpoint criado|✅ Snapshot OK|□|
|2|Conexão LDAP do midPoint|✅ Connection succeeded|□|
|3|Test Connection no Resource AD|✅ 5/5 SUCCESS|□|
|4|Importação de shadows AD|✅ Usuários visíveis|□|
|5|Documentação atualizada|✅ GMUD registrada|□|

---

## 6. Plano de Rollback

### 6.1. Critério de Ativação

Ativar rollback se qualquer um dos cenários ocorrer:

- ❌ Test Connection falha após 3 tentativas
    
- ❌ Ping para gateway não responde após correção
    
- ❌ AD fica inacessível após alterações
    
- ❌ Tempo de execução > 2 horas sem progresso
    

### 6.2. Procedimento de Rollback

powershell

# No Hyper-V host (PowerShell como Administrador)
Stop-VM -Name "ID-P-01" -Force
Stop-VM -Name "iga-gf-02" -Force
Start-Sleep -Seconds 5
# Restaurar snapshots
Restore-VMSnapshot -Name "PRE-GMUD-001-PRJ026-*" -VMName "ID-P-01" -Confirm:$false
Restore-VMSnapshot -Name "PRE-GMUD-001-PRJ026-*" -VMName "iga-gf-02" -Confirm:$false
# Iniciar VMs
Start-VM -Name "ID-P-01"
Start-VM -Name "iga-gf-02"
# Validar
Get-VM ID-P-01, iga-gf-02 | Select-Object Name, State

**Tempo estimado de rollback:** < 5 minutos

---

## 7. Riscos e Mitigações

|ID|Risco|Probabilidade|Impacto|Mitigação|
|---|---|---|---|---|
|R01|midPoint não alcança `172.24.192.10`|Média|Alto|Acionar Abordagem Alternativa (Fase 2)|
|R02|Gateway `172.23.192.1` não responde|Baixa|Alto|Verificar switch Hyper-V antes da mudança|
|R03|AD perde conectividade com outras VMs|Baixa|Médio|Rollback imediato via snapshot|
|R04|Firewall do AD bloqueia LDAP|Baixa|Médio|Regra explícita criada na Fase 2|
|R05|Mudança não documentada no futuro|Média|Médio|Esta GMUD serve como registro oficial|

---

## 8. Lições Aprendidas (Incorporadas)

|ID|Lição|Origem|Aplicação|
|---|---|---|---|
|L01|Mudanças de rede em VMs DEVEM ser documentadas|Gap documental 06/01-10/05/2026|Toda mudança de IP/switch requer GMUD|
|L02|midPoint mantém configuração Resource mesmo com VM inacessível|Diagnóstico PRJ026|Verificar Resource antes de assumir falha|
|L03|Tailscale é alternativa segura para acesso sem exposição de rede|Análise de segurança|Considerar Tailscale no AD como contingência|
|L04|Checkpoint Hyper-V pré-GMUD é obrigatório|PRJ003 ADR-002|Aplicado nesta GMUD|
|L05|Hardening deve preceder acesso à internet|Análise de risco|AD não será exposto sem guardrails|

---

## 9. Documentos Relacionados

|Documento|Localização|Relevância|
|---|---|---|
|TAP-PRJ026|`10_Projetos/PRJ026/00_Gestao_do_Projeto/TAP-PRJ026.md`|Planejamento original|
|REL-GMUD-002|`10_Projetos/PRJ002/20_Governanca/REL-GMUD-002.md`|IP original do AD|
|REL-GMUD-007|`10_Projetos/PRJ002/20_Governanca/REL-GMUD-007.md`|Configuração de rede IGA-P-01|
|REL-GMUD-015|`10_Projetos/PRJ002/20_Governanca/REL-GMUD-015.md`|Correção de rede VLAN 1/16|
|TEP-PRJ015|`10_Projetos/PRJ015/TEP-PRJ015-v3.0.md`|Histórico de comunicação AD-Entra|
|ADR-002|`05_BASE-LAB/ADR-002-Reversibilidade-e-IaC.md`|Checkpoints obrigatórios|

---

## 10. Cronograma Estimado

|Fase|Atividade|Duração|Tempo Acumulado|
|---|---|---|---|
|Pré|Criar checkpoints|5 min|5 min|
|Fase 1|Abordagem Preferencial (ajustar midPoint)|15 min|20 min|
|Fase 1.3|Validação|10 min|30 min|
|Fase 2|Abordagem Alternativa (se necessário)|20 min|50 min|
|Fase 3|Validação final|15 min|65 min|
|Pós|Documentação|15 min|80 min|
|**TOTAL**||**~1h20min**||

---

## 11. Critérios de Sucesso

|#|Critério|Métrica|
|---|---|---|
|1|Conectividade midPoint ↔ AD restaurada|Ping OK + porta 389 aberta|
|2|Test Connection no Resource AD|5/5 Success|
|3|AD continua sem acesso direto à internet|Gateway não configurado ou firewall bloqueia|
|4|Documentação atualizada|GMUD-001-PRJ026 registrada|
|5|Rollback testado|Restauração de snapshot < 5 min|

---

## 12. Aprovações

|Função|Nome|Data|Status|
|---|---|---|---|
|Responsável Técnico|Paulo Feitosa Lima|10/05/2026|🟡 Pendente|
|GRC Lead|Paulo Feitosa Lima|10/05/2026|🟡 Pendente|
|Aprovador Final|Paulo Feitosa Lima|10/05/2026|🟡 Pendente|

---

## 13. Histórico de Versões

|Versão|Data|Autor|Mudanças|
|---|---|---|---|
|1.0|10/05/2026|Paulo Feitosa Lima|Criação da GMUD com base em diagnóstico completo de conectividade|

---

## 14. Próximos Passos Pós-GMUD

|Ordem|Ação|Projeto|
|---|---|---|
|1|Validar conectividade midPoint ↔ AD|GMUD-001-PRJ026|
|2|Retomar execução do PRJ026 (Resource AD)|PRJ026|
|3|Testar Joiner/Mover/Leaver com AD|PRJ026|
|4|Documentar POP de integração midPoint-AD|PRJ026|
|5|(Opcional) Instalar Tailscale no AD para acesso seguro|GMUD futura|

---

**FIM DA GMUD-001-PRJ026 v1.0**

---

_Documento mantido por Paulo Feitosa Lima — Living Lab Fiqueok_  
*PRJ026 - Integração midPoint 4.10 com Active Directory*  
*Data: 10/05/2026*
