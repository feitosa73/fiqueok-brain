
# GMUD-001-PRJ026 – Integração midPoint 4.10 com Active Directory (Via Tailscale)

**Gestão de Mudanças - Projeto PRJ026 (Integração midPoint ↔ Active Directory)**

**Living Lab Fiqueok - GRC/IAM Open-Source Platform**

---

## Informações Básicas da GMUD

| Campo | Valor |
|-------|-------|
| **ID da GMUD** | GMUD-001-PRJ026 |
| **Título** | Integração midPoint 4.10 com Active Directory via Tailscale |
| **Tipo** | Mudança Configuracional / IGA |
| **Versão Documento** | 2.0 (Atualizada pós-PRJ028) |
| **Data de Criação** | 10/05/2026 |
| **Data de Atualização** | 10/05/2026 |
| **Responsável Execução** | Paulo Feitosa Lima |
| **Projeto** | PRJ026 - Integração midPoint 4.10 com Active Directory |
| **Severidade** | MÉDIA |
| **Prioridade** | ALTA |
| **Status** | 📝 PLANEJADA - PRONTA PARA EXECUÇÃO |
| **Pré-requisito** | ✅ PRJ028 CONCLUÍDO (Tailscale no AD, firewall configurado) |
| **Referências** | ADR-007, GMUD-001/002-PRJ028, TAP-PRJ028 |

---

## 1. Contexto e Problema

### 1.1. Objetivo Original do PRJ026

O PRJ026 foi planejado para estabelecer integração bidirecional entre o **midPoint 4.10** e o **Active Directory**, permitindo provisionamento automático de usuários (Joiner/Mover/Leaver) e governança centralizada de identidades.

### 1.2. Bloqueador Identificado e Resolvido

Durante a fase de validação pré-execução do PRJ026, identificou-se que **o midPoint não conseguia se comunicar com o Active Directory**.

**Causa raiz:** O AD estava em sub-rede diferente do host (`172.24.192.10` vs `172.23.192.1`), com gateway incorreto, isolado da rede.

**Solução implementada (PRJ028):**

| Ação | Resultado |
|------|-----------|
| Correção de rede | AD com IP `172.23.195.2` (mesma sub-rede do host) |
| Instalação do Tailscale | AD com IP Tailscale `xxx.xxx.xxx.xxx` |
| Firewall configurado | `BlockInbound, AllowOutbound` |
| ACLs Tailscale | Apenas `tag:midpoint` acessa porta 389 |
| Hardening aplicado | SMB, NetBIOS, WinRM desabilitados |

### 1.3. Estado Atual da Infraestrutura (Pré-GMUD)

| Componente | IP | Status |
|------------|-----|--------|
| **AD (ID-P-01)** | `xxx.xxx.xxx.xxx` (Tailscale) | ✅ Operacional, seguro |
| **midPoint (iga-gf-02)** | `xxx.xxx.xxx.xxx` (Tailscale) | ✅ Operacional |
| **Rede de comunicação** | Tailscale overlay | ✅ Criptografada (WireGuard) |
| **Firewall AD** | `BlockInbound, AllowOutbound` | ✅ Configurado |
| **ACLs Tailscale** | `tag:midpoint → tag:ad:389` | ✅ Configurado |

---

## 2. Objetivo da GMUD

Estabelecer integração segura entre o **midPoint 4.10** e o **Active Directory** via Tailscale, permitindo:

1. Provisionamento automático de usuários no AD (Joiner)
2. Atualização de atributos (Mover)
3. Desativação/remoção de usuários (Leaver)
4. Gerenciamento de grupos e associações
5. Reconciliação contínua entre midPoint e AD
6. Auditoria centralizada de identidades

---

## 3. Escopo da Mudança

### 3.1. Incluído na GMUD

| Item | Descrição |
|------|-----------|
| **Fase 1** | Verificar conectividade midPoint ↔ AD via Tailscale |
| **Fase 2** | Configurar Resource AD no midPoint (via IP Tailscale) |
| **Fase 3** | Configurar mapeamentos de atributos (inbound/outbound) |
| **Fase 4** | Configurar Correlation Rule (employeeID como âncora) |
| **Fase 5** | Configurar Synchronization Reactions (Joiner/Mover/Leaver) |
| **Fase 6** | Validar integração com usuário de teste |
| **Fase 7** | Documentação |

### 3.2. Excluído da GMUD

| Item | Justificativa |
|------|---------------|
| ❌ Instalação/configuração do Tailscale | Já realizado no PRJ028 |
| ❌ Hardening do AD | Já realizado no PRJ028 |
| ❌ Configuração de LDAPS (636) | Será GMUD futura (PKI/Vault) |
| ❌ Configuração de MFA para acesso | Já realizado no PRJ028 |

### 3.3. Dependências

| Dependência | Projeto | Status |
|-------------|---------|--------|
| Tailscale instalado no AD | PRJ028 | ✅ Concluído |
| Firewall AD configurado (`BlockInbound`) | PRJ028 | ✅ Concluído |
| ACLs Tailscale (porta 389 liberada) | PRJ028 | ✅ Concluído |
| midPoint operacional | PRJ003 | ✅ Concluído |

---

## 4. Plano de Execução

### 4.1. Fase 0 - Preparação (5 min)

```powershell
# No Hyper-V host (PowerShell como Administrador)

# Criar checkpoint de segurança
Checkpoint-VM -VMName "ida-gf-02" -SnapshotName "PRE-GMUD-001-PRJ026-$(Get-Date -Format 'yyyyMMdd-HHmm')"
Checkpoint-VM -VMName "ID-P-01" -SnapshotName "PRE-GMUD-001-PRJ026-$(Get-Date -Format 'yyyyMMdd-HHmm')"
```

**Critério de saída:** ✅ Snapshots criados.

---

### 4.2. Fase 1 - Verificar Conectividade (5 min)

#### 1.1. Testar conectividade via Tailscale

```bash
# No iga-gf-02 (via SSH)
ping xxx.xxx.xxx.xxx
nc -zv xxx.xxx.xxx.xxx 389
```

**Resultado esperado:**
```
PING xxx.xxx.xxx.xxx: 56 data bytes
64 bytes from xxx.xxx.xxx.xxx: icmp_seq=0 ttl=128 time=2.5ms

Connection to xxx.xxx.xxx.xxx 389 port [tcp/ldap] succeeded!
```

**Critério de saída:** ✅ Ping OK, porta 389 acessível.

---

### 4.3. Fase 2 - Configurar Resource AD no midPoint (15 min)

#### 2.1. Verificar conectores disponíveis

```bash
# No iga-gf-02
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://172.23.201.182:8080/midpoint/ws/rest/connectors" \
  | jq '.[] | {name: .name, oid: .oid}' | grep -i -A1 "adldap"
```

#### 2.2. Criar/Atualizar Resource via XML

```xml
<?xml version="1.0" encoding="UTF-8"?>
<resource xmlns="http://midpoint.evolveum.com/xml/ns/public/common/common-3"
          xmlns:c="http://midpoint.evolveum.com/xml/ns/public/connector/icf-1/connector-schema-3"
          xmlns:ri="http://midpoint.evolveum.com/xml/ns/public/resource/instance-3">

    <name>Active Directory (Tailscale)</name>
    <description>Integração com Active Directory via Tailscale (overlay segura)</description>
    <lifecycleState>active</lifecycleState>

    <connectorRef oid="20f08b13-5ba3-414b-bfb9-0842e290c7e1"/>

    <connectorConfiguration>
        <configuration>
            <c:host>xxx.xxx.xxx.xxx</c:host> <!-- IP Tailscale do AD -->
            <c:port>389</c:port>
            <c:connectionSecurity>none</c:connectionSecurity> <!-- Tailscale já criptografa -->
            <c:authenticationType>simple</c:authenticationType>
            <c:principal>CN=paulo.feitosa,OU=00_Admins,OU=Fiqueok_Corp,DC=corp,DC=fiqueok,DC=com,DC=br</c:principal>
            <c:credentials>
                <c:password>[SENHA_DO_PAULO]</c:password>
            </c:credentials>
            <c:baseContexts>
                <c:baseContext>DC=corp,DC=fiqueok,DC=com,DC=br</c:baseContext>
            </c:baseContexts>
            <c:accountBaseContext>OU=04_People,OU=Fiqueok_Corp,DC=corp,DC=fiqueok,DC=com,DC=br</c:accountBaseContext>
            <c:groupBaseContext>OU=02_Security_Groups,OU=Fiqueok_Corp,DC=corp,DC=fiqueok,DC=com,DC=br</c:groupBaseContext>
            <c:accountSynchronization>
                <c:enabled>true</c:enabled>
            </c:accountSynchronization>
        </configuration>
    </connectorConfiguration>

    <schemaHandling>
        <objectType>
            <kind>account</kind>
            <intent>user</intent>
            <displayName>AD User</displayName>

            <!-- Mapeamento sAMAccountName -->
            <attribute>
                <ref>ri:name</ref>
                <displayName>sAMAccountName</displayName>
                <inbound>
                    <strength>strong</strength>
                    <target>
                        <path>name</path>
                    </target>
                </inbound>
                <outbound>
                    <strength>strong</strength>
                    <source>
                        <path>name</path>
                    </source>
                </outbound>
            </attribute>

            <!-- Mapeamento employeeID (âncora de correlação) -->
            <attribute>
                <ref>ri:employeeID</ref>
                <inbound>
                    <strength>strong</strength>
                    <target>
                        <path>personalNumber</path>
                    </target>
                </inbound>
                <outbound>
                    <strength>strong</strength>
                    <source>
                        <path>personalNumber</path>
                    </source>
                </outbound>
            </attribute>

            <!-- Mapeamento givenName -->
            <attribute>
                <ref>ri:givenName</ref>
                <inbound>
                    <target>
                        <path>givenName</path>
                    </target>
                </inbound>
                <outbound>
                    <source>
                        <path>givenName</path>
                    </source>
                </outbound>
            </attribute>

            <!-- Mapeamento sn (sobrenome) -->
            <attribute>
                <ref>ri:sn</ref>
                <inbound>
                    <target>
                        <path>familyName</path>
                    </target>
                </inbound>
                <outbound>
                    <source>
                        <path>familyName</path>
                    </source>
                </outbound>
            </attribute>

            <!-- Mapeamento mail -->
            <attribute>
                <ref>ri:mail</ref>
                <inbound>
                    <target>
                        <path>emailAddress</path>
                    </target>
                </inbound>
                <outbound>
                    <source>
                        <path>emailAddress</path>
                    </source>
                </outbound>
            </attribute>

            <!-- Mapeamento department -->
            <attribute>
                <ref>ri:department</ref>
                <outbound>
                    <source>
                        <path>costCenter</path>
                    </source>
                </outbound>
            </attribute>

            <!-- Mapeamento title -->
            <attribute>
                <ref>ri:title</ref>
                <outbound>
                    <source>
                        <path>title</path>
                    </source>
                </outbound>
            </attribute>

            <!-- Correlação baseada em employeeID -->
            <correlation>
                <correlationRule>
                    <name>Correlacao_EmployeeID</name>
                    <item>
                        <source>
                            <path>employeeID</path>
                        </source>
                        <target>
                            <path>personalNumber</path>
                        </target>
                    </item>
                </correlationRule>
            </correlation>

            <!-- Reações de sincronização -->
            <synchronization>
                <reaction>
                    <name>Joiner - Criar Usuario</name>
                    <situation>unmatched</situation>
                    <action>
                        <type>addFocus</type>
                    </action>
                </reaction>
                <reaction>
                    <name>Mover - Atualizar Usuario</name>
                    <situation>linked</situation>
                    <action>
                        <type>synchronize</type>
                    </action>
                </reaction>
                <reaction>
                    <name>Leaver - Desabilitar Usuario</name>
                    <situation>deleted</situation>
                    <action>
                        <type>disable</type>
                    </action>
                </reaction>
            </synchronization>
        </objectType>
    </schemaHandling>
</resource>
```

#### 2.3. Aplicar configuração via GUI (alternativa)

```
1. Configuration → Resources → New Resource
2. Selecionar AdLdapConnector
3. Preencher:
   - Host: xxx.xxx.xxx.xxx
   - Port: 389
   - Principal: CN=paulo.feitosa,OU=00_Admins,OU=Fiqueok_Corp,DC=corp,DC=fiqueok,DC=com,DC=br
   - Password: [senha do paulo.feitosa]
4. Test Connection → Deve retornar 5/5 Success
5. Save
```

**Critério de saída:** ✅ Test Connection OK (5/5 SUCCESS).

---

### 4.4. Fase 3 - Configurar Mapeamentos de Atributos (10 min)

| Atributo AD | Atributo midPoint | Direção | Regra |
|-------------|-------------------|---------|-------|
| `sAMAccountName` | `name` | inbound/outbound | Direto |
| `employeeID` | `personalNumber` | inbound/outbound | **Âncora de correlação** |
| `givenName` | `givenName` | inbound/outbound | Direto |
| `sn` | `familyName` | inbound/outbound | Direto |
| `mail` | `emailAddress` | inbound/outbound | Direto |
| `department` | `costCenter` | outbound | Mapeamento |
| `title` | `title` | outbound | Direto |

**Critério de saída:** ✅ Mapeamentos configurados no Resource.

---

### 4.5. Fase 4 - Validar Integração (15 min)

#### 4.5.1. Executar Import Task

```
1. Tasks → New Task
2. Type: Import from Resource
3. Resource: Active Directory (Tailscale)
4. Object Type: account
5. Execute: Run now
```

#### 4.5.2. Verificar Shadows criados

```bash
# No iga-gf-02
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://172.23.201.182:8080/midpoint/ws/rest/shadows" \
  | jq '.shadows[] | {name: .name, resourceRef: .resourceRef.oid}'
```

#### 4.5.3. Verificar usuários no midPoint

```
Users → All Users
Procurar por: paulo.feitosa (deve existir)
```

**Critério de saída:** ✅ Shadows e usuários criados.

---

### 4.6. Fase 5 - Teste de Ciclo JML (15 min)

#### 5.1. Joiner (Criar usuário)

```powershell
# No AD, criar usuário de teste
New-ADUser -Name "Teste Joiner" `
    -SamAccountName "teste.joiner" `
    -UserPrincipalName "teste.joiner@corp.fiqueok.com.br" `
    -GivenName "Teste" `
    -Surname "Joiner" `
    -EmployeeID "TEST001" `
    -Enabled $true `
    -AccountPassword (ConvertTo-SecureString "Teste@123" -AsPlainText -Force)
```

**Esperado:** Usuário aparece no midPoint via reconciliação.

#### 5.2. Mover (Atualizar atributo)

```powershell
# No AD, atualizar atributo
Set-ADUser -Identity "teste.joiner" -Title "Analista Senior" -Department "TI"
```

**Esperado:** midPoint detecta e sincroniza a mudança.

#### 5.3. Leaver (Desabilitar usuário)

```powershell
# No AD, desabilitar usuário
Disable-ADAccount -Identity "teste.joiner"
```

**Esperado:** midPoint desabilita/remove o usuário.

**Critério de saída:** ✅ Ciclo JML funcionando.

---

### 4.7. Fase 6 - Documentação (10 min)

| # | Entregável | Formato | Localização |
|---|------------|--------|-------------|
| 1 | REL-GMUD-001-PRJ026 (v2.0) | MD | `10_Projetos/PRJ026/30_Operacao_e_Mudanca/` |
| 2 | Resource AD XML final | XML | `10_Projetos/PRJ026/10_Arquitetura_Tecnica/` |
| 3 | POP-PRJ026 (Integração midPoint-AD) | MD | `05_BASE-LAB/03_Metodologia-e-Frameworks/` |

---

## 5. Cronograma Estimado

| Fase | Atividade | Duração | Tempo Acumulado |
|------|-----------|---------|-----------------|
| 0 | Preparação (checkpoints) | 5 min | 5 min |
| 1 | Verificar conectividade | 5 min | 10 min |
| 2 | Configurar Resource AD | 15 min | 25 min |
| 3 | Configurar mapeamentos | 10 min | 35 min |
| 4 | Validar integração | 15 min | 50 min |
| 5 | Teste de ciclo JML | 15 min | 65 min |
| 6 | Documentação | 10 min | 75 min |
| **TOTAL** | | **~1h15min** | |

---

## 6. Matriz de Validação

| # | Teste | Comando | Resultado Esperado | Status |
|---|-------|---------|-------------------|--------|
| 1 | Conectividade Tailscale | `ping xxx.xxx.xxx.xxx` | 0% loss | □ |
| 2 | Porta LDAP | `nc -zv xxx.xxx.xxx.xxx 389` | Connection succeeded | □ |
| 3 | Test Connection | GUI midPoint | 5/5 Success | □ |
| 4 | Resource criado | `curl /resources` | OID presente | □ |
| 5 | Import Task | Executar task | SUCCESS | □ |
| 6 | Shadows criados | `curl /shadows` | Shadows listados | □ |
| 7 | Usuário criado | GUI Users | User visível | □ |
| 8 | Joiner funcionando | Criar usuário no AD | Sincronizado | □ |
| 9 | Mover funcionando | Atualizar atributo | Sincronizado | □ |
| 10 | Leaver funcionando | Desabilitar conta | Sincronizado | □ |

---

## 7. Plano de Rollback

### 7.1. Critério de Ativação

Ativar rollback se qualquer um dos cenários ocorrer:
- ❌ Test Connection falha após 3 tentativas
- ❌ Import Task retorna erro
- ❌ midPoint não cria shadows
- ❌ Tempo de execução > 2 horas sem progresso

### 7.2. Procedimento de Rollback

```powershell
# Opção A - Restaurar snapshot do midPoint
Stop-VM -Name "iga-gf-02" -Force
Restore-VMSnapshot -Name "PRE-GMUD-001-PRJ026-*" -VMName "iga-gf-02" -Confirm:$false
Start-VM -Name "iga-gf-02"

# Opção B - Remover Resource AD no midPoint
# GUI: Configuration → Resources → Active Directory (Tailscale) → Delete
```

**Tempo estimado de rollback:** < 5 minutos

---

## 8. Riscos e Mitigações

| ID | Risco | Probabilidade | Impacto | Mitigação |
|----|-------|--------------|---------|-----------|
| R01 | IP Tailscale do AD mudar | Baixa | Médio | Tailscale oferece IP fixo por dispositivo |
| R02 | Tailscale indisponível | Muito Baixa | Alto | Console Hyper-V como fallback |
| R03 | ACL bloqueia acesso do midPoint | Baixa | Alto | Verificar ACLs antes da GMUD (já configurado) |
| R04 | Mapeamento de atributos incorreto | Média | Médio | Testar com usuário único antes da carga |
| R05 | Correlation Rule falha | Média | Médio | Validar employeeID único no AD |

---

## 9. Lições Aprendidas

| ID | Lição | Origem | Aplicação |
|----|-------|--------|-----------|
| L01 | Tailscale oferece overlay network segura sem expor portas | PRJ028 | Padrão para acesso a serviços críticos |
| L02 | Firewall `BlockInbound, AllowOutbound` é suficiente para laboratório | PRJ028 | Adotado como padrão |
| L03 | Comunicação via Tailscale elimina necessidade de VPN complexa | PRJ028 | Simplifica arquitetura de rede |
| L04 | ACLs com tags são mais fáceis de manter que IPs fixos | PRJ028 | Usar tags em vez de IPs |

---

## 10. Documentos Relacionados

| Documento | Localização | Relevância |
|-----------|-------------|------------|
| TAP-PRJ026 | `10_Projetos/PRJ026/00_Gestao_do_Projeto/` | Planejamento original |
| ADR-007 | `10_Projetos/PRJ028/20_Governanca_e_Decisoes/ADRs/` | Arquitetura Zero Trust |
| GMUD-001-PRJ028 | `10_Projetos/PRJ028/20_Governanca_e_Decisoes/` | Hardening e Tailscale |
| GMUD-002-PRJ028 | `10_Projetos/PRJ028/20_Governanca_e_Decisoes/` | SSH, ACLs e MFA |
| REL-GMUD-001-PRJ028 | `10_Projetos/PRJ028/30_Operacao_e_Mudanca/` | Encerramento PRJ028 |

---

## 11. Aprovações

| Função | Nome | Data | Status |
|--------|------|------|:------:|
| Responsável Técnico | Paulo Feitosa Lima | 10/05/2026 | 🟡 Pendente |
| GRC Lead | Paulo Feitosa Lima | 10/05/2026 | 🟡 Pendente |
| Aprovador Final | Paulo Feitosa Lima | 10/05/2026 | 🟡 Pendente |

---

## 12. Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 10/05/2026 | Paulo Feitosa Lima | Criação da GMUD (planejamento original) |
| **2.0** | **10/05/2026** | **Paulo Feitosa Lima** | **Atualização para usar Tailscale (IP `xxx.xxx.xxx.xxx`). Adicionados pré-requisitos do PRJ028. Simplificada configuração de rede.** |

---

**FIM DA GMUD-001-PRJ026 v2.0**

---

*Documento mantido por Paulo Feitosa Lima — Living Lab Fiqueok*  
*PRJ026 - Integração midPoint 4.10 com Active Directory*  
*Pré-requisito: PRJ028 concluído (Tailscale no AD)*  
*Data: 10/05/2026*
```
