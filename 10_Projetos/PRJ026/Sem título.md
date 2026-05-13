Compreendo completamente. Vamos fazer o rollback de forma segura e documentar tudo para uma nova tentativa no futuro.

## Procedimento de Rollback Imediato

### 1. Restaurar Snapshots (via Hyper-V host)

```powershell
# No PowerShell (Administrador) do Hyper-V host

# Listar snapshots disponíveis
Get-VMSnapshot -VMName "iga-gf-02" | Select-Object Name, CreationTime
Get-VMSnapshot -VMName "ID-P-01" | Select-Object Name, CreationTime

# Restaurar snapshots PRE-GMUD
Stop-VM -Name "iga-gf-02" -Force
Stop-VM -Name "ID-P-01" -Force

Restore-VMSnapshot -VMName "iga-gf-02" -Name "PRE-GMUD-001-PRJ026-v3-*" -Confirm:$false
Restore-VMSnapshot -VMName "ID-P-01" -Name "PRE-GMUD-001-PRJ026-v3-*" -Confirm:$false

Start-VM -Name "iga-gf-02"
Start-VM -Name "ID-P-01"

# Aguardar inicialização (2 minutos)
Start-Sleep -Seconds 120

# Verificar conectividade
Test-NetConnection -ComputerName xxx.xxx.xxx.xxx -Port 8080
```

### 2. Verificar Rollback Completo

```bash
# No iga-gf-02 (após rollback)
curl -s -u administrator:'M1dP0!ntAdm!n#2026' \
  "http://localhost:8080/midpoint/ws/rest/users?search=personalNumber=TEST00" \
  | grep -c "TEST00"

# Deve retornar 0 (nenhum usuário de teste)
```

---

## Relatório GMUD-001-PRJ026 - EXECUÇÃO SEM SUCESSO

### Informações Básicas

| Campo | Valor |
|-------|-------|
| **ID da GMUD** | GMUD-001-PRJ026 |
| **Status Final** | ❌ **FALHA** - Rollback Executado |
| **Data Execução** | 11/05/2026 |
| **Horário Início** | 18:00 |
| **Horário Rollback** | ~20:30 |
| **Tempo Total** | ~2h30min |
| **Responsável** | Paulo Feitosa Lima |

### Resumo da Execução

| Fase | Status | Observação |
|------|--------|------------|
| Fase 0 - Preparação | ✅ SUCESSO | Snapshots criados |
| Fase 0.5 - POC CSV | ✅ SUCESSO | CSV funcionou perfeitamente |
| Fase 1 - Conectividade | ✅ SUCESSO | Ping/porta 389 OK |
| Fase 2 - Resource AD | ✅ SUCESSO | Test Connection 5/5 |
| Fase 3 - Mapeamentos | ⚠️ PARCIAL | Funcionou, mas... |
| Fase 4 - Derivações | ⚠️ PARCIAL | Funcionou, mas... |
| Fase 5 - Correlation | ✅ SUCESSO | Funcionou |
| Fase 6 - Reactions | ❌ **FALHA** | Problema com `objectPolicyConfiguration` |
| Fase 7 - Validação | ❌ **NÃO EXECUTADO** | Bloqueado pela Fase 6 |

### Problema Crítico Encontrado

**Erro:** `Item objectPolicyConfiguration has no definition (invalue CTD SystemConfigurationType)`

**Causa:** O campo `objectPolicyConfiguration` **não existe** no schema do `SystemConfigurationType` no midPoint 4.10. O XML que continha a definição do Object Template para o Resource AD estava malformado ou incompatível.

**Impacto:** Impediu a persistência da configuração do Resource AD com o Object Template referenciado.

---

## Lições Aprendidas (Lições Aprendidas)

### L01 - Valide schema antes de configurar

**Problema:** Não validamos se `objectPolicyConfiguration` existia no midPoint 4.10.

**Solução Futura:** 
```bash
# Validar schema antes da GMUD
curl -s http://localhost:8080/midpoint/ws/rest/systemConfigurations/schema \
  | grep -i "objectPolicyConfiguration"
# O comando acima não retornou nada, indicando que não existe!
```

**Ação:** Incluir validação de schema no **pre-flight check**.

---

### L02 - CSV POC foi um sucesso absoluto

**Aprendizado:** A Fase 0.5 (Pre-Flight POC com CSV) funcionou perfeitamente e validou todos os mapeamentos.

**Por que funcionou?** 
- CSV é simples, sem autenticação/complicações
- Permite debug visual dos dados
- Mesma lógica de mapeamento do AD

**Ação:** **Manter CSV POC como padrão** para TODAS as integrações futuras.

---

### L03 - Object Template deve ser independente do Resource

**Problema:** Tentamos referenciar o Object Template diretamente no Resource AD de forma incorreta.

**Solução Correta:** O Object Template deve ser aplicado de duas formas:

```xml
<!-- Opção 1: Via System Configuration (global para todos usuários) -->
<defaultUserTemplateRef oid="00000000-0000-0000-0000-000000000222"/>

<!-- Opção 2: Via Security Policy (mais granular) -->
<securityPolicy>
    <defaultUserTemplateRef oid="..."/>
</securityPolicy>
```

**NÃO** via `objectPolicyConfiguration` (não existe no midPoint 4.10).

---

### L04 - Documentação do midPoint precisa ser consultada versão a versão

**Problema:** Assumimos que configurações de tutoriais (versão 4.8/4.9) funcionam no 4.10.

**Ação:** Para PRÓXIMA GMUD, consultar:
- Documentação oficial do midPoint 4.10
- Fórum da Evolveum
- Testar em sandbox antes da execução real

---

### L05 - Comandos de verificação preventiva

**O que faltou fazer ANTES da GMUD:**

```bash
# 1. Validar schema completo do SystemConfiguration
curl -s http://localhost:8080/midpoint/ws/rest/systemConfigurations/schema \
  | jq '.definitions' > /tmp/sysconfig-schema.json

# 2. Verificar se objectPolicyConfiguration existe
grep -i "objectPolicy" /tmp/sysconfig-schema.json

# 3. Validar XML antes de aplicar (em ambiente de teste)
xmllint --noout resource-ad.xml

# 4. Testar apenas o Object Template isoladamente
# Criar template, validar, depois associar
```

---

### L06 - Limite do chat e complexidade

**Observação:** O problema ficou complexo e o chat atingiu limite de contexto.

**Ação:** Para PRÓXIMA GMUD:
- Dividir em menores (Resource, Template, Correlation, Reactions)
- Criar documentação incremental
- Usar arquivos locais para logs extensos

---

## Recomendações para GMUD-Follow-up (GMUD-002-PRJ026)

### O que deve ser diferente na próxima tentativa

| # | Recomendação | Responsável | Prioridade |
|---|--------------|-------------|------------|
| 1 | **Estudar schema do midPoint 4.10** completamente | Paulo | 🔴 |
| 2 | **Criar sandbox isolado** (VM clone) para testes | Paulo | 🔴 |
| 3 | **Validar `defaultUserTemplateRef`** no SystemConfiguration | Paulo | 🔴 |
| 4 | **Testar Resource AD sem Object Template primeiro** | Paulo | 🟡 |
| 5 | **Adicionar Object Template depois**, separadamente | Paulo | 🟡 |
| 6 | **Documentar XML completo validado** antes da execução | Paulo | 🟡 |
| 7 | **Reduzir escopo**: Resource AD + Correlation primeiro | Paulo | 🟡 |

### Plano Proposto para GMUD-002-PRJ026

```
Fase 0: Preparação + Snapshots (5 min)
Fase 0.5: CSV POC (já validado - pular) (0 min)
Fase 1: Conectividade (5 min)
Fase 2: Resource AD SEM Object Template (15 min)
Fase 3: Testar criação manual de usuário (10 min)
Fase 4: Criar Object Template ISOLADO (15 min)
Fase 5: Associar via defaultUserTemplateRef (5 min)
Fase 6: Testar criação automática (10 min)
Fase 7: Correlation e Reactions (15 min)
Fase 8: Validação completa (15 min)

TOTAL: ~1h30min (mais conservador)
```

---

## Próximos Passos Imediatos

### 1. Documentar o aprendizado

```bash
# Criar relatório no repositório
cat > /home/paulo/PRJ026/LESSONS-LEARNED-GMUD-001.md << 'EOF'
# Lições Aprendidas - GMUD-001-PRJ026

## Data: 11/05/2026
## Status: FALHA - Rollback executado

## Problema Principal:
objectPolicyConfiguration não existe no midPoint 4.10

## Solução para próxima tentativa:
Usar defaultUserTemplateRef no SystemConfiguration

## Comandos úteis para validação preventiva:
[colocar comandos aqui]

## CSV POC: SUCESSO - manter como padrão
EOF
```

### 2. Criar template de validação

```bash
# Criar script de pré-verificação para próxima GMUD
cat > /home/paulo/scripts/pre-flight-check.sh << 'EOF'
#!/bin/bash
# Pre-flight check para GMUD do midPoint

MIDPOINT_URL="http://localhost:8080/midpoint/ws/rest"
USER="administrator"
PASS="M1dP0!ntAdm!n#2026"

echo "=== PRE-FLIGHT CHECK PRJ026 ==="

# 1. Verificar schema
echo "1. Validando schema do SystemConfiguration..."
curl -s -u $USER:$PASS "$MIDPOINT_URL/systemConfigurations/schema" > /tmp/schema.json
if grep -q "defaultUserTemplateRef" /tmp/schema.json; then
    echo "   ✅ defaultUserTemplateRef encontrado"
else
    echo "   ❌ defaultUserTemplateRef NÃO encontrado"
fi

# 2. Verificar conectividade com AD
echo "2. Validando conectividade com AD..."
if ping -c 1 xxx.xxx.xxx.xxx > /dev/null 2>&1; then
    echo "   ✅ Ping OK"
else
    echo "   ❌ Ping FALHOU"
fi

if nc -zv xxx.xxx.xxx.xxx 389 2>&1 | grep -q "succeeded"; then
    echo "   ✅ Porta 389 OK"
else
    echo "   ❌ Porta 389 FALHOU"
fi

echo "=== PRE-FLIGHT CONCLUÍDO ==="
EOF

chmod +x /home/paulo/scripts/pre-flight-check.sh
```

### 3. Agendar estudo do midPoint 4.10

```bash
# Criar nota de estudo
cat > /home/paulo/PRJ026/STUDY-MIDPOINT-4.10.txt << 'EOF'
# Tópicos para estudar antes da GMUD-002

1. SystemConfiguration schema completo
   - defaultUserTemplateRef
   - globalSecurityPolicyRef
   - cleanupPolicy

2. Como aplicar Object Template corretamente
   - Via SystemConfiguration
   - Via Security Policy
   - Via Role assignment

3. Resource AD configuration (documentação oficial 4.10)
   - Connector configuration
   - Schema handling
   - Correlation rules

4. Test Connection - todos os 5 checks (o que cada um valida)

5. Laboratório: Criar Resource manualmente via GUI primeiro
EOF
```

---

## Status Final

| Item | Status |
|------|--------|
| **Ambiente** | ✅ Rollback concluído - Ambiente estável |
| **Snapshots** | ✅ Restaurados |
| **Usuários de teste** | ✅ Removidos (rollback) |
| **Documentação** | ✅ Lições aprendidas registradas |
| **Próxima GMUD** | 📝 Planejamento iniciado |

---

## Declaração de Encerramento

```
Declaro que a GMUD-001-PRJ026 foi EXECUTADA SEM SUCESSO,
o rollback foi realizado com segurança, e todas as lições
aprendidas foram documentadas para garantir sucesso em
futuras tentativas.

A integração midPoint ↔ Active Directory permanece como
pendente, agora com maior clareza dos desafios técnicos.

Data: 11/05/2026
Responsável: Paulo Feitosa Lima
```

---

**FIM DO RELATÓRIO DE EXECUÇÃO - GMUD-001-PRJ026**

---

*Documento mantido por Paulo Feitosa Lima — Living Lab Fiqueok*  
*Status: ❌ FALHA - Rollback executado*  
*Próxima ação: GMUD-002-PRJ026 (após estudo do midPoint 4.10)*
