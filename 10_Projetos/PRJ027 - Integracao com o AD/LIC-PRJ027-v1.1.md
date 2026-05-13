## ✅ Adendo incorporado — Documento de Lições Aprendidas (Versão Atualizada)


---

# DOCUMENTO DE LIÇÕES APRENDIDAS — PRJ027 (Até 08/05/2026)

## Integração midPoint 4.10 com Microsoft Entra ID Free

---

| Campo           | Valor                                             |
| --------------- | ------------------------------------------------- |
| **Documento**   |                                                   |
| **Versão**      | 1.1                                               |
| **Data**        | 08/05/2026                                        |
| **Responsável** | Paulo Feitosa Lima                                |
| **Projeto**     | PRJ027 — Integração midPoint ↔ Microsoft Entra ID |
| **Status**      | 🔴 **BLOQUEADO** — Rollback em andamento          |

---

## 1. Resumo Executivo

O PRJ027 teve como objetivo integrar o midPoint 4.10 ao Microsoft Entra ID Free utilizando o conector oficial `connector-msgraph-1.0.2.0`. Apesar de todas as configurações aparentemente corretas (App Registration, permissões, Vault, Resource, mappings, role), o provisionamento do usuário FP001 **não ocorreu**.

A análise aprofundada dos logs e da execução revelou **múltiplas causas raiz** interligadas:

1. **Conflito com projetos anteriores** (AWS IAM, GCP IAM) — afetando FP001
2. **Erros de sintaxe nos mappings do XML** — afetando TODOS os usuários
3. **Falta de declaração explícita de dependências (source)** — afetando TODOS os usuários
4. **Problemas de ordem de execução** (recompute tenta provisionar tudo de uma vez)

> **🔍 Evidência Final — Caso Gabriel Martins (FP010):**
>
> Para confirmar que o problema não era exclusivo do FP001 (que tinha shadows corrompidas da AWS/GCP), tentou-se o provisionamento do usuário **FP010 (Gabriel Martins)** — um usuário **limpo**, sem vínculos com projetos anteriores.
>
> **O resultado:** O mesmo erro ocorreu. O midPoint não conseguiu gerar o UPN `gabriel.martins@fiqueok.com.br` devido à falha de sintaxe no script de mapeamento (tag `<path>` usada incorretamente para executar código Groovy).
>
> **Conclusão:** A falha era **sistêmica** — o Resource `Microsoft Entra ID` estava mal configurado na base, independentemente do estado das shadows dos usuários.

---

## 2. Linha do Tempo dos Eventos

| Data | Evento | Status |
|------|--------|--------|
| 04-06/05 | Configuração inicial: App Registration, permissões, Vault | ✅ Sucesso |
| 06/05 | Instalação do conector `connector-msgraph-1.0.2.0.jar` | ✅ Sucesso |
| 08/05 | Criação do Resource `Microsoft Entra ID` | ✅ Sucesso |
| 08/05 | Test Connection | ✅ Sucesso |
| 08/05 | Criação da Role `Entra ID Basic User` | ✅ Sucesso |
| 08/05 | Atribuição da role ao usuário FP001 | ✅ Sucesso |
| 08/05 | Recompute do FP001 | ❌ **FALHA** — sem shadow do Entra ID |
| 08/05 | Identificação do erro `Cannot convert OID 'FP001' to UUID` | 🔍 Descoberta |
| 08/05 | Identificação do conflito com shadow da AWS IAM | 🔍 Descoberta |
| 08/05 | **Tentativa com FP010 (Gabriel Martins) — usuário limpo** | ❌ **FALHA** — mesmo erro |
| 08/05 | **Confirmação: erro é SISTÊMICO (configuração do Resource)** | 🔍 **Conclusão** |

---

## 3. Causas Raiz Identificadas

### 3.1. Conflito Interferente das Shadows de Projetos Anteriores

**Problema:** O usuário FP001 possuía shadows vinculadas aos projetos AWS IAM (PRJ023) e GCP IAM (PRJ024). Essas shadows estavam em estado inconsistente (existiam no midPoint mas a conta real na AWS/GCP já não existia ou estava em conflito).

**Evidência no log:**
```
Found conflicting existing object with attribute name = [ FP001 ]: shadow:91a484a5-f021-4f01-91e9-5d58e48d63ea(FP001)
Object already exists on the resource (AWS IAM: IAM User ... EntityAlreadyExistsException)
```

**Impacto:** O midPoint, ao executar o recompute, tenta **provisionar todos os recursos de uma vez** (AWS, GCP, Entra ID). Como o provisionamento para AWS já falhava (conta já existia ou shadow corrompida), todo o processo era abortado antes de chegar no Entra ID. O erro na AWS **bloqueou o Entra ID** para FP001.

**✅ ISOLADO:** Este problema afetava APENAS usuários com shadows antigas (ex: FP001).

### 3.2. Erro de Sintaxe no Mapeamento `userPrincipalName` (SISTÊMICO)

**Problema:** O mapeamento do UPN foi configurado com uma tag `<path>` contendo um script Groovy. A tag `<path>` NÃO suporta expressões lógicas ou concatenações — apenas caminhos de atributos.

**Incorreto:**
```xml
<source>
    <path>givenName.toLowerCase() + '.' + familyName.toLowerCase() + '@fiqueok.com.br'</path>
</source>
```

**Correto:**
```xml
<expression>
    <script>
        <code>givenName.toLowerCase() + '.' + familyName.toLowerCase() + '@fiqueok.com.br'</code>
    </script>
</expression>
```

**🔍 Evidência:** O erro persistiu com FP010 (usuário limpo), confirmando que o problema era na configuração do Resource, não nos dados do usuário.

### 3.3. Falta de Declaração de Dependência (Groovy Script) — SISTÊMICO

**Problema:** Quando se utiliza um script Groovy que referencia `givenName` e `familyName`, o midPoint precisa saber que esses atributos são **fontes** do mapeamento. Sem a tag `<source>` adequada, o script pode ser executado sem ter os dados carregados.

**Solução padrão para scripts no midPoint:**
```xml
<attribute>
    <ref>userPrincipalName</ref>
    <outbound>
        <strength>strong</strength>
        <expression>
            <script>
                <code>givenName.toLowerCase() + '.' + familyName.toLowerCase() + '@fiqueok.com.br'</code>
            </script>
        </expression>
        <source>
            <path>givenName</path>
        </source>
        <source>
            <path>familyName</path>
        </source>
    </outbound>
</attribute>
```

### 3.4. Atributo `icfs:name` sem Source Declarado

**Problema:** O mapeamento `icfs:name` existia no `schemaHandling` mas sem `<source>` definido.

```xml
<attribute id="20">
    <ref>icfs:name</ref>
    <outbound>
        <name>Name</name>
        <strength>strong</strength>
        <!-- FALTA <source> -->
    </outbound>
</attribute>
```

O Entra ID exige `displayName`, mas o conector pode precisar de `icfs:name` como identificador interno. Sem source, o valor ficava vazio.

### 3.5. API REST do midPoint não aceita `name` como OID

**Problema:** A API REST `GET /users/FP001` tenta interpretar `FP001` como um OID (UUID), causando erro. Isso não afeta o provisionamento via GUI, mas atrapalhou o diagnóstico.

**Correção:** Usar `POST /users/search` com filtro por `name`, ou usar o OID real do usuário (`436d61c3-c4c3-4e5c-9501-17fd554ac46a`).

---

## 4. Lições Aprendidas

| ID | Lição | Aplicação Futura |
|----|-------|------------------|
| **L27** | Antes de iniciar um novo projeto de provisionamento, **desabilitar (maintenance mode)** os Resources antigos que não são mais ativos, para evitar conflitos durante o recompute. | Verificar todos os Resources vinculados a usuários de teste antes de novas configurações. |
| **L28** | O midPoint, ao executar recompute em um usuário, **provisiona TODOS os Resources** vinculados ao usuário ao mesmo tempo. Uma falha em um Resource bloqueia os demais. | Isolar testes: criar usuários de teste DEDICADOS para cada novo Resource, sem roles antigas. |
| **L29** | Scripts Groovy em mappings DEVEM ser colocados dentro de `<expression><script><code>` e NUNCA dentro de `<path>`. | Seguir o padrão correto de XML para expressões. |
| **L30** | Todo script que referencia atributos do usuário DEVE declarar esses atributos como `<source>` no mapping. | Declarar explicitamente as dependências. |
| **L31** | O atributo `icfs:name` no conector MsGraphConnector pode ser requisitado implicitamente. Para garantir, declarar `<source><path>name</path></source>`. | Validar todos os mappings antes de testar. |
| **L32** | A API REST do midPoint NÃO aceita busca por `name` diretamente. Usar `POST /users/search` com filtro ou o OID real. | Documentar nos POPs os comandos corretos de diagnóstico. |
| **L33** | Testes de provisionamento devem ser feitos com **usuários de teste ISOLADOS** (ex: `TST001`), sem roles ou shadows de projetos anteriores. | Criar um "ambiente de prova" antes de usar dados reais. |
| **L34** | **A falha no FP010 (usuário limpo) provou que o erro era sistêmico.** Nunca assumir que o problema é apenas de um usuário "sujo" — testar com um usuário novo isola a causa raiz. | Ao diagnosticar falhas, criar um usuário de teste novo para validar se o erro persiste. |

---

## 5. Estado Atual dos Artefatos (Forense)

| Artefato | Estado | Ação Necessária |
|----------|--------|-----------------|
| Resource `Microsoft Entra ID` | ✅ Criado, porém com mappings incorretos | Corrigir XML |
| Role `Entra ID Basic User` | ✅ Criada, correta | Manter |
| Usuário FP001 | ✅ Existe no midPoint | Desvincular shadows da AWS/GCP |
| Usuário FP010 | ✅ Existe no midPoint | Usuário limpo — será usado para teste após correção |
| Shadow AWS IAM (FP001) | ❌ Corrompida/inconsistente | Desvincular ou deletar |
| Shadow GCP IAM (FP001) | ❌ Inconsistente | Desvincular ou deletar |
| Resource AWS IAM | ⚠️ Ativo, causando conflito | Colocar em maintenance mode |
| Resource GCP IAM | ⚠️ Ativo, causando conflito | Colocar em maintenance mode |

---

## 6. Plano de Rollback (Hyper-V Checkpoint)

### 6.1. Procedimento de Rollback por Snapshot

Conforme procedimento padrão do Living Lab, o rollback será realizado via **restauração do snapshot Hyper-V** (`PRJ027-Antes-Implementacao-20260508`), levando o ambiente ao estado anterior ao início das configurações problemáticas.

```powershell
# [PowerShell como Administrador]
# Listar snapshots disponíveis
Get-VMSnapshot -VMName "IGA-GF-02" | Select-Object Name, CreationTime

# Restaurar snapshot
Restore-VMSnapshot -VMName "IGA-GF-02" -Name "PRJ027-Antes-Implementacao-20260508" -Confirm:$false

# Iniciar a VM
Start-VM -Name "IGA-GF-02"
```

### 6.2. O que o Rollback por Snapshot NÃO apaga

O rollback via snapshot do Hyper-V restaura **apenas o estado da VM IG A-GF-02** (midPoint). Os seguintes artefatos permanecem intactos e **devem ser limpos manualmente**:

| Artefato | Local | Ação Pós-Rollback |
|----------|-------|-------------------|
| App Registration `midpoint-iga-connector` | Entra ID (nuvem) | Reaproveitar (já existe) |
| Client Secret | Entra ID + Vault | Manter (já foi criado) |
| Permissões Graph API | Entra ID | Já estão concedidas |
| Snapshots antigos | Hyper-V | Manter (inclusive o restaurado) |

### 6.3. Pós-Rollback — Validação Obrigatória

Após restaurar o snapshot, validar:

```bash
# [iga-gf-02]
sudo docker ps | grep midpoint
# Deve mostrar: iga-midpoint   Up (healthy)

curl -s -o /dev/null -w "HTTP: %{http_code}\n" http://localhost:8080/midpoint
# Deve retornar: HTTP: 200
```

---

## 7. Checklist para o Novo POP (v5.0)

| # | Item | Descrição |
|---|------|------------|
| 1 | **Pre-Flight obrigatório** | Verificar shadows existentes do usuário de teste antes de começar |
| 2 | **Isolamento de Resources** | Colocar Resources antigos em maintenance mode |
| 3 | **Usuário de teste dedicado** | Criar `TST001` sem roles/shadow antigas |
| 4 | **Mappings corretos** | Usar `<expression><script>` para lógica, `<source>` para dependências |
| 5 | **Validação XML** | Verificar sintaxe antes de salvar |
| 6 | **Teste incremental** | Primeiro testar apenas `icfs:name`, depois adicionar outros atributos |
| 7 | **Teste com usuário limpo** | Após corrigir XML, testar primeiro com `TST001` ou `FP010` |
| 8 | **Logs de provisionamento** | Monitorar logs específicos: `sudo docker logs iga-midpoint --tail 100 \| grep -E "provision|create|Entra"` |

---

## 8. Aprovações

| Função | Nome | Data | Decisão |
|--------|------|------|---------|
| **Responsável Técnico** | Paulo Feitosa Lima | 08/05/2026 | ✅ Rollback aprovado (via snapshot) |
| **GRC Advisor** | Perplexity AI | 08/05/2026 | ✅ Lições registradas |

---

**Fim do LIC-PRJ027-v1.1** ✅

---

*PRJ027 — Lições Aprendidas e Plano de Correção*  
*Living Lab Fiqueok*  
*Arquivado em: `FiqueokBrain/PRJ027/99 Memória/LIC-PRJ027-v1.1.md`*
