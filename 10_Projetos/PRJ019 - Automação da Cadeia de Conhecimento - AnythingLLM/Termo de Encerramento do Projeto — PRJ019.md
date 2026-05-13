

---

| **Campo**             | **Valor**                                    |
| --------------------- | -------------------------------------------- |
| **Código do Projeto** | PRJ019                                       |
| **Nome do Projeto**   | Watcher e Ingestor Automatizados para Obsidian |
| **Versão**            | 3.0                                          |
| **Data de Encerramento** | 24/04/2026                                |
| **Responsável**       | Paulo Feitosa Lima — GRC Lead                |
| **Patrocinador**      | Living Lab Fiqueok                           |
| **Classificação**     | CONFIDENCIAL — Dados Técnicos e de Auditoria |
| **Status Final**      | ❌ **ENCERRADO SEM SUCESSO (FREEZED)**        |

---

## Histórico de Revisões

| Versão | Data       | Descrição                                                                                   | Responsável        |
|--------|------------|---------------------------------------------------------------------------------------------|--------------------|
| 2.0    | 24/04/2026 | Versão inicial do Termo de Abertura                                                         | Paulo Feitosa Lima |
| 2.1    | 24/04/2026 | Migração da VM dedicada para Docker Desktop (Windows Host)                                  | Paulo Feitosa Lima |
| 2.2    | 24/04/2026 | Eliminação de secrets no `.env` - Implementação do Vault Agent (Sidecar)                    | Paulo Feitosa Lima |
| 3.0    | 24/04/2026 | **ENCERRAMENTO SEM SUCESSO** — Freezing do projeto após impedimento técnico irreconciliável | Paulo Feitosa Lima |

---

## 1. STATUS FINAL DO PROJETO

| Item | Status |
|------|--------|
| **Conclusão dos Objetivos** | ❌ Parcialmente Não Alcançado |
| **Entregáveis Produzidos** | ⚠️ Código fonte desenvolvido, porém não funcional no ambiente alvo |
| **Ambiente Operacional** | ❌ Sistema não entrou em produção |
| **Decisão Final** | 🔒 **FREEZING IMEDIATO** — Projeto arquivado para revisão arquitetural |

---

## 2. RESUMO DA EXECUÇÃO

### 2.1. O Que Foi Realizado

| Atividade | Status | Observação |
|-----------|--------|------------|
| Configuração do Vault (PRJ007) | ✅ Concluído | AppRole, política e RoleID/SecretID configurados |
| Desenvolvimento da API Service (FastAPI) | ✅ Concluído | Código funcional em testes isolados |
| Desenvolvimento do Watcher (Watchdog) | ✅ Concluído | Implementado com Bind Mounts |
| Implementação do Vault Client | ✅ Concluído | Leitura de token via sink file |
| Dockerfile e containerização | ✅ Concluído | Imagem construída com sucesso |
| Integração Vault Agent (Sidecar) | ❌ **FALHA PERSISTENTE** | Impedimento técnico no WSL2 |
| Testes de integração completos | ❌ Não executado | Devido à falha do Agent |

### 2.2. O Que Não Funcionou

**Falha Crítica:** O Vault Agent (hashicorp/vault:1.15) não consegue iniciar no Docker Desktop Windows/WSL2 quando configurado com usuário não-root (UID 1000:1000) e políticas de hardening.

**Erro Observado:**
```
unable to set CAP_SETFCAP effective capability: Operation not permitted
prj019-vault-agent exited with code 1
```

**Impacto:** Sem o Agent funcionando, não há token no sink file (`/app/token/.vault-token`), e a API Ingestor falha na inicialização com erro `No such file or directory`.

---

## 3. ANÁLISE DETALHADA DO IMPEDIMENTO

### 3.1. Diagnóstico Técnico

| Componente | Problema | Causa Raiz |
|------------|----------|-------------|
| **Vault Agent** | Não inicia com `user: "1000:1000"` | O binário do Vault requer `CAP_SETFCAP` que não é suportado no WSL2 backend |
| **mlock** | Falha com `disable_mlock = false` | WSL2 não implementa `mlock()` de forma compatível com o Vault |
| **Volume compartilhado** | Permissão negada para escrita do token | O volume Docker é criado como root; mesmo com `user: 1000`, o Agent não consegue escrever |
| **Dependência de capabilities** | `IPC_LOCK` insuficiente | CAP_SETFCAP é exigida e não pode ser adicionada via `cap_add` no Windows |

### 3.2. Tentativas Realizadas (Sem Sucesso)

| # | Tentativa | Resultado |
|---|-----------|-----------|
| 1 | Rodar Agent como `user: "1000:1000"` sem `cap_add` | Falha com permission denied no sink |
| 2 | Adicionar `cap_add: IPC_LOCK` | Falha com CAP_SETFCAP |
| 3 | Adicionar `cap_drop: ALL` e `cap_add: IPC_LOCK` | Falha com CAP_SETFCAP |
| 4 | Configurar `security_opt: no-new-privileges:true` | Falha com CAP_SETFCAP |
| 5 | Adicionar `disable_mlock = true` no agent.hcl | Ainda falha com CAP_SETFCAP |
| 6 | Rodar Agent como `user: root` (viola PAD-002) | Funcionaria, mas rejeitado pela governança |

### 3.3. Conclusão do Diagnóstico

> **O Vault Agent no modelo Sidecar NÃO É COMPATÍVEL com Docker Desktop Windows/WSL2 quando se exige hardening (usuário não-root e mlock).**  
>  
> A limitação está no kernel WSL2, que não implementa o conjunto completo de Linux Capabilities necessário para o funcionamento seguro do Vault Agent em modo não-privilegiado.

---

## 4. LIÇÕES APRENDIDAS

### 4.1. Conflito de Camadas (Segurança vs. Operabilidade)

| Lição | Descrição |
|-------|-----------|
| **Problema** | A tentativa de hardening (usuário não-root, mlock, capabilities mínimas) em Docker Desktop Windows/WSL2 gerou conflito de privilégios de kernel |
| **Insight GRC** | Controles de segurança rígidos em ambientes não preparados causam **indisponibilidade total do serviço** |
| **Recomendação** | Validar a compatibilidade das ferramentas de segurança com o ambiente alvo **antes** de definir controles no TAP |

### 4.2. Gestão de Variáveis de Sessão (CLI Hygiene)

| Lição | Descrição |
|-------|-----------|
| **Problema** | Comandos Vault falhavam por `VAULT_ADDR` não definido, gerando confusão entre HTTP/HTTPS |
| **Insight** | Em ambientes de laboratório sem TLS, a persistência do `VAULT_ADDR` é ponto crítico |
| **Melhor Prática** | Adicionar `export VAULT_ADDR='http://127.0.0.1:8200'` ao `.bashrc` do servidor Vault |

### 4.3. Rollback de Arquitetura "Zero Secrets"

| Lição | Descrição |
|-------|-----------|
| **Problema** | O rollback do AppRole exige limpeza em múltiplas camadas |
| **Insight** | Uma arquitetura baseada em segredos efêmeros requer procedimento de descomissionamento documentado |
| **Checklist de Rollback** | 1. Revogar SecretID (efêmero) · 2. Remover Role (configuração) · 3. Remover Policy (autorização) |

### 4.4. Sobre a Escolha do Vault Agent Sidecar

| Lição | Descrição |
|-------|-----------|
| **Problema** | Vault Agent é otimizado para Kubernetes/Linux nativo, não para Docker Desktop Windows |
| **Insight** | A complexidade da solução não justificou o benefício de eliminar apenas 2 variáveis de ambiente (RoleID/SecretID) |
| **Alternativa** | Avaliar o uso de **secrets gerenciados pelo Docker Compose** ou **variáveis de ambiente injetadas via Docker Secrets** (modo swarm) |

---

## 5. ENTREGÁVEIS PRODUZIDOS (PARA APROVEITAMENTO FUTURO)

| ID | Entregável | Localização | Aproveitamento |
|----|------------|-------------|----------------|
| E01 | API Service (código) | `C:\Git\prj019-ingestor\src\` | ✅ Reutilizável |
| E02 | Dockerfile + docker-compose.yml | `C:\Git\prj019-ingestor\` | ⚠️ Requer ajustes |
| E03 | Logger estruturado (JSON) | `src/logger.py` | ✅ Reutilizável |
| E04 | Vault Client (leitura de sink) | `src/vault_client.py` | ⚠️ Para referência |
| E05 | Configuração Vault (política + role) | Servidor vault-gf-01 | ✅ Mantida |

---

## 6. RECOMENDAÇÕES PARA VERSÃO FUTURA (PRJ019 ou sucessor)

### 6.1. Arquiteturas Alternativas a Avaliar

| Alternativa | Complexidade | Compatibilidade Windows | Segurança (PAD-002) |
|-------------|--------------|------------------------|---------------------|
| **Docker Compose + .env (vetado pelo GRC)** | Baixa | ✅ Alta | ❌ Falha |
| **Docker Secrets (modo swarm)** | Média | ✅ Alta (Docker Desktop suporta swarm) | ✅ Aceitável |
| **Vault Agent com usuário root + compensações** | Baixa | ✅ Alta | ⚠️ Aceito com risco documentado |
| **Eliminar Vault Agent — API consome diretamente do Vault via AppRole (com variables)** | Média | ✅ Alta | ⚠️ Aceito (variáveis injetadas, não hardcoded) |
| **Migrar para VM Linux dedicada (reverter v2.0)** | Média | ❌ N/A (ambiente separado) | ✅ Ideal |

### 6.2. Próximos Passos em Sessão de Arquitetura

1. **Aceitar o compromisso de rodar Vault Agent com `user: root`** (com documentação de risco aceito)
2. **Substituir Vault Agent por chamada direta ao Vault** via AppRole (RoleID/SecretID injetados via Docker Compose)
3. **Migrar todo o workload para uma VM Linux dedicada** no Hyper-V (elimina problema do WSL2)
4. **Adotar Docker Secrets** (modo swarm) para gerenciar credenciais

---

## 7. APROVAÇÕES DE ENCERRAMENTO

| Função | Nome | Data | Status |
|--------|------|------|--------|
| GRC Lead / Responsável | Paulo Feitosa Lima | 24/04/2026 | ✅ CIÊNCIA DO ENCERRAMENTO |
| Patrocinador | Living Lab Fiqueok | 24/04/2026 | ⏳ AGUARDANDO CIÊNCIA |

---

## 8. ANEXOS

### Anexo A — Evidência da Falha Crítica

```
prj019-vault-agent  | unable to set CAP_SETFCAP effective capability: Operation not permitted
prj019-vault-agent exited with code 1
prj019-ingestor     | CRITICAL: Erro ao ler token do Agent ou segredo do Vault: [Errno 2] No such file or directory: '/app/token/.vault-token'
```

### Anexo B — Configurações Testadas (Última Tentativa)

- **vault-agent.hcl:** `disable_mlock = true`
- **docker-compose.yml:** `user: "1000:1000"`, `cap_add: IPC_LOCK`
- **Dockerfile:** `USER appuser`, `ENV PYTHONPATH=/app`

### Anexo C — Estado Final dos Recursos no Vault

| Recurso | Status |
|---------|--------|
| Role `prj019-ingestor` | ❌ Removida |
| Policy `policy-svc-ingestor` | ❌ Removida |
| Segredo `secret/data/anythingllm` | ✅ Mantido (para uso futuro) |

---

## 9. CONSIDERAÇÕES FINAIS

> *"O PRJ019 não entregou o valor esperado dentro das premissas de segurança definidas no PAD-002. O impedimento técnico no ambiente Windows/WSL2 inviabilizou a arquitetura escolhida. O projeto está FREEZED para revisão arquitetural em nova sessão de planejamento, prevista para a semana de 27/04/2026."*

---

**FIM DO TERMO DE ENCERRAMENTO DO PROJETO — PRJ019 v3.0**

📄 **Documento salvo como:** `TEP-PRJ019-v3.0.md`  
📁 **Localização:** `10_Projetos/PRJ019/00_Gestao_do_Projeto/`  
🔒 **Classificação:** CONFIDENCIAL