

| Campo             | Valor                                           |
| ----------------- | ----------------------------------------------- |
| **Código**        | PAD-002                                         |
| **Versão**        | 1.0                                             |
| **Data**          | 24/04/2026                                      |
| **Responsável**   | Paulo Feitosa Lima — GRC Lead                   |
| **Aprovador**     | Living Lab Fiqueok                              |
| **Classificação** | CONFIDENCIAL — Diretriz Técnica e de Governança |

---

## 1. OBJETIVO

Estabeecer padrões obrigatórios para **criação, evolução e operação de APIs** no Living Lab Fiqueok, garantindo:

- **Rastreabilidade** (ISO 27001 A.12.4)
- **Segurança por design** (sem credenciais hardcoded)
- **Resiliência** (retry + dead letter)
- **Auditoria contínua** (logs JSON estruturados)
- **Portabilidade** (Docker + usuário não root)

---

## 2. PRINCÍPIOS FUNDAMENTAIS

| Princípio | Descrição |
|-----------|-----------|
| **API como contrato primeiro** | Swagger/OpenAPI é a *Single Source of Truth* |
| **Nenhum segredo no código** | Nem `.env`, nem variável de ambiente direta → sempre Vault AppRole |
| **Falha visível e rastreável** | Toda falha gera log crítico + (opcional) notificação |
| **Imutabilidade operacional** | API roda dentro de container; mudança exige rebuild + GMUD |
| **Auditoria obrigatória** | Se não está no log, não aconteceu |

---

## 3. PADRÃO TECNOLÓGICO OBRIGATÓRIO

| Componente | Tecnologia | Justificativa |
|------------|------------|----------------|
| **Linguagem** | Python 3.11+ | Suporte longo, maduro, compatível com stack atual |
| **Framework** | FastAPI | Assíncrono nativo, documentação automática, validação Pydantic |
| **Servidor ASGI** | Uvicorn | Performance e padrão da indústria |
| **Validação de dados** | Pydantic v2 | Type safety nativo e integração com FastAPI |
| **Container** | Docker (GEN1) | Portabilidade, isolamento, respeita CONSTRAINT-001 |
| **Usuário no container** | `appuser` (não root) | Mitigação de escalação de privilégio |
| **IP fixo (quando necessário)** | `192.168.70.x/24` | Subnet isolada, evita conflito dinâmico |

---

## 4. SEGURANÇA E GESTÃO DE SEGREDOS

### 4.1. Autenticação e Autorização

| Camada | Padrão | Exemplo |
|--------|--------|---------|
| **Segredo de backend** | HashiCorp Vault AppRole (RoleID + SecretID) | `secret/data/anythingllm` |
| **Token de fachada (frontend)** | API Key estática com rotação anual | `FQK-SVC-<hash>` |
| **Autenticação entre APIs** | mTLS (futuro) ou Vault JWT | — |

✅ Proibido:
- `API_KEY=abc123` no código
- `.env` versionado
- credencial comentada

### 4.2. Criptografia em Trânsito

| Ambiente | Exigência |
|----------|-----------|
| Local (VM Hyper-V) | Tailscale obrigatório para acesso externo |
| Entre containers na mesma VM | `localhost` ou `127.0.0.1` (sem criptografia adicional) |
| Produção futura | TLS + Tailscale ou HTTPS com certificado interno |

---

## 5. ARQUITETURA E RESILIÊNCIA

### 5.1. Padrão de chamada externa

Qualquer API que chama **outro serviço externo** deve implementar:

```
Tentativa 1 → Aguarda 60s
Tentativa 2 → Aguarda 120s
Tentativa 3 → Aguarda 240s
Falha persistente → DEAD_LETTER + log crítico
```

### 5.2. Dead Letter Queue (DLQ) mínimo

| Campo | Obrigatório |
|-------|-------------|
| Arquivo original | ✅ |
| Timestamp da falha | ✅ |
| Motivo (HTTP status / exception) | ✅ |
| Número de tentativas | ✅ |
| Hash SHA256 do payload | ✅ |

> Pode ser implementado como diretório `dead_letter/` + arquivo `.json` ou `.md`

---

## 6. LOG E AUDITORIA (ISO 27001)

### 6.1. Formato obrigatório

**Logs estruturados em JSON** — nunca texto livre.

Exemplo mínimo por operação:

```json
{
  "timestamp": "2026-04-24T14:32:11.123Z",
  "event": "document_ingested",
  "file_path": "10_Projetos/PRJ020/nota.md",
  "file_hash_sha256": "a1b2c3...",
  "target_workspace": "camada-6-seguranca",
  "http_status": 201,
  "source_ip": "127.0.0.1",
  "retry_count": 0
}
```

### 6.2. Proibido em logs

- `Authorization:` header
- `X-Vault-Token:`
- `SecretID`
- Qualquer chave de API

> Filtro automático obrigatório antes da escrita.

### 6.3. Rotação e retenção

- Ferramenta: `logrotate`
- Retenção mínima: 90 dias
- Local padrão: `/var/log/<projeto>/audit.log`

---

## 7. PROCESSO E GOVERNANÇA (PRÉ-DEPLOY)

### 7.1. Antes de escrever código

| Etapa | Obrigatório |
|-------|--------------|
| IP fixo definido (se aplicável) | ✅ |
| Workspace criado no AnythingLLM | ✅ |
| Política Vault criada (`policy-svc-<projeto>`) | ✅ |
| Production Checkpoint Hyper-V | ✅ (nome: `PRE-GMUD-<projeto>`) |

### 7.2. Critérios de merge (sem pipeline CI/CD ainda)

- [ ] `pip-audit` sem vulnerabilidades **críticas ou altas**
- [ ] Revisão manual de código (Paulo)
- [ ] Container roda como `appuser`
- [ ] Logs são JSON + filtro de segredos

---

## 8. DOCUMENTAÇÃO OBRIGATÓRIA

| Documento | Localização | Formato |
|-----------|-------------|---------|
| **Swagger/OpenAPI** | `/docs` da API | automático (FastAPI) |
| **POP (Procedimento Operacional)** | `10_Projetos/<projeto>/` | Markdown |
| **GMUD** | `20_Governanca_e_Decisoes/GMUDs/` | Markdown |
| **TEP (Término)** | `00_Gestao_do_Projeto/` | Markdown |

> A documentação sem Swagger é considerada **incompleta**.

---

## 9. EXEMPLO DE ESTRUTURA DE PROJETO (MÍNIMO)

```
prjXXX-ingestor/
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── .dockerignore
├── src/
│   ├── main.py              # FastAPI app
│   ├── vault_client.py      # AppRole auth
│   ├── classifier.py        # regras YAML/regex
│   ├── anythingllm_client.py
│   └── logger.py            # JSON + sanitize
├── tests/                   # mínimo (futuro PRJ021)
└── dead_letter/             # DLQ
```

---

## 10. APROVAÇÃO

| Função | Nome | Data | Status |
|--------|------|------|--------|
| GRC Lead / Responsável | Paulo Feitosa Lima | 24/04/2026 | ✅ APROVADO |
| Arquiteto de Soluções | Paulo Feitosa Lima | 24/04/2026 | ✅ APROVADO |

---

**FIM DA DIRETRIZ**  
📁 `10_Projetos/PRJ019/00_Gestao_do_Projeto/DIR-API-001.md`  
🔒 CONFIDENCIAL

---

Agora podemos começar a implementar **PRJ019** *dentro* dessa diretriz.  
Se quiser, já posso gerar o esqueleto do projeto (Dockerfile, docker-compose, `main.py`, `vault_client.py` e logger) **100% alinhado** com esse framework.
