

### Encerramento Sem Sucesso — Integração midPoint 4.10 com Microsoft Entra ID Free

---

| Campo | Valor |
|-------|-------|
| **Código do Projeto** | PRJ027 |
| **Versão do TEP** | 1.0 |
| **Data** | 08/05/2026 |
| **Responsável** | Paulo Feitosa Lima |
| **Status do Projeto** | ❌ **ENCERRADO SEM SUCESSO** |

---

## 1. Resumo Executivo

O PRJ027 teve como objetivo integrar o midPoint 4.10 ao Microsoft Entra ID Free utilizando o conector `connector-msgraph-1.0.2.0`.

**Resultado Final:** ❌ **NÃO IMPLEMENTADO**

- ✅ App Registration criado e preservado
- ✅ Permissões Graph API concedidas
- ✅ Client Secret armazenado no Vault
- ✅ Conector Graph instalado e descoberto
- ⚠️ Test Connection funcionou em algumas tentativas
- ❌ **Resource nunca ficou 100% funcional**
- ❌ **Nenhum usuário foi provisionado no Entra ID**

---

## 2. O que Funcionou (parcialmente)

| Componente | Status | Observação |
|------------|--------|------------|
| App Registration | ✅ | Preservado para reuso |
| Permissões Graph API | ✅ | 5 permissões concedidas |
| Client Secret | ✅ | Válido, armazenado no Vault |
| Conector Graph | ✅ | Instalado e descoberto |
| Test Connection | ⚠️ | Funcionou intermitentemente |
| Usuários FPxxx no midPoint | ✅ | Existem e têm atributos |

---

## 3. O que Não Funcionou

| Componente | Status | Causa |
|------------|--------|-------|
| Resource XML | ❌ | Inconsistências de schema do midPoint 4.10 |
| Correlation | ❌ | Path `attributes/employeeId` não reconhecido |
| Synchronization | ❌ | Tags `<synchronize>` e `<action>` não aceitas |
| Provisionamento | ❌ | Bloqueado pelos erros acima |
| Usuário no Entra ID | ❌ | Nenhum criado |

---

## 4. Lições Aprendidas (Consolidadas)

| ID | Lição |
|----|-------|
| L27 | Resources antigos em maintenance mode antes de testar novos |
| L28 | midPoint provisiona TODOS os Resources de um usuário de uma vez |
| L29 | Scripts Groovy usam `<expression><script><code>`, NUNCA `<path>` |
| L30 | Scripts precisam declarar `<source>` para atributos referenciados |
| L31 | `icfs:name` precisa de source explícito |
| L35 | Schema do midPoint 4.10 para `<synchronization>` é inconsistente com a documentação |
| L36 | `<synchronize>true</synchronize>` NÃO é aceito |
| L37 | `<action>` com `reconcile` NÃO é aceito para `linked` |
| L38 | Para `unlinked`, usar `<link>true</link>` em vez de `<action>` |
| L39 | A maneira mais confiável é exportar um Resource funcional do sistema |

---

## 5. Estado dos Artefatos Pós-Encerramento

| Artefato | Decisão |
|----------|---------|
| App Registration `midpoint-iga-connector` | ✅ **MANTER** (reuso futuro) |
| Client Secret | ✅ **MANTER** (válido) |
| Permissões Graph API | ✅ **MANTER** |
| Vault (`secret/entra-id/auth`) | ✅ **MANTER** |
| Snapshots das VMs | ✅ **MANTER** |
| Arquivos XML de tentativa | 📁 Arquivar |
| Documentação (POP, TAP, LIC) | 📁 Arquivar |

---

## 6. Próximos Passos (Pendente)

| Ação | Status |
|------|--------|
| Definir se haverá PRJ028 (retomada com abordagem diferente) | ⏳ Indefinido |
| Avaliar outro provedor de identidade (Keycloak? Okta? Auth0?) | ⏳ Indefinido |
| Aguardar correção/documentação da Evolveum para midPoint 4.10 | ⏳ Indefinido |

---

## 7. Aprovação

| Função | Nome | Data | Decisão |
|--------|------|------|---------|
| **Responsável Técnico** | Paulo Feitosa Lima | 08/05/2026 | ✅ **ENCERRADO** |

---

**Fim do TEP-PRJ027-v1.0** ❌

---

*PRJ027 — Integração midPoint ↔ Microsoft Entra ID Free*  
*Living Lab Fiqueok — Encerrado sem sucesso*




## 8. Análise de Causa Raiz — Pesquisa Externa (Pós-Encerramento)

*Esta seção documenta achados obtidos APÓS o encerramento do projeto, com base em pesquisa complementar.*

### 8.1. Evidência Externa Encontrada

| Fonte                                     | Data     | Conteúdo                                                                                                                                                                                                                                                         |
| ----------------------------------------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Fórum Evolveum — usuário Markus Calmius   | Jan/2024 | Relato de LiveSync parando após atualização para smart correlation. Relato ID: [[[ponto médio] O LiveSync parou de funcionar após o upgrade para correlacion/sincronização inteligente](https://lists.evolveum.com/pipermail/midpoint/2024-January/008042.html)] |
| Documentação Evolveum — Smart Correlation | v4.8+    | Modelo de correlação inteligente substitui mecanismos legados                                                                                                                                                                                                    |

### 8.2. Inferência Documentada

**Hipótese:** O midPoint 4.10 introduziu breaking changes no schema de synchronization que tornam obsoletas as tags `<synchronize>true</synchronize>` e `<action><type>reconcile</type></action>`.

**Base para esta inferência:**
1. PRJ027 testou empiricamente estas tags → falha
2. Comunidade reporta comportamento similar pós-atualização
3. Documentação oficial indica que smart correlation é o modelo atual

**Status da inferência:** ⚠️ **Hipótese não confirmada oficialmente** — aguarda resposta da Evolveum ou teste em versão controlada.

### 8.3. Ação Pendente

- [ ] Abrir issue no GitHub da Evolveum com o XML que falhou
- [ ] Testar em midPoint 4.11 (quando disponível)