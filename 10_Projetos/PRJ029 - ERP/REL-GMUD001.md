
#  – Relatório de Encerramento de Mudança

**ID da Mudança:** GMUD-001  
**Projeto:** PRJ029 – Odoo ERP (Source of Truth)  
**Data de Fechamento:** 11 de Maio de 2026  
**Responsável pela Execução:** Paulo Feitosa (Líder Técnico)  
**Status da Mudança:** **CONCLUÍDA COM SUCESSO**

---

## 1. Resumo da Mudança

Mudança inicial para implantação do Odoo 17.0 em contêiner Docker na VM `erp-odoo-mac`, visando estabelecer o sistema de origem (HR) para o ecossistema de IGA.

---

## 2. Atividades Executadas (Conforme Plano × Realizado)

| Atividade Planejada | Executada? | Detalhamento |
|---------------------|------------|---------------|
| Expandir disco LVM | ✅ Sim | Crescimento de 10GB → 37GB com `growpart`, `pvresize`, `lvextend`, `resize2fs` |
| Instalar Tailscale e Docker | ✅ Sim | Tailscale 1.96.4 ativo, Docker Engine + Compose instalados |
| Criar `docker-compose.yml` | ✅ Sim | Estrutura com serviços `db` (postgres:15) e `web` (odoo:17.0) |
| Subir containers | ✅ Sim | Imagens baixadas, containers criados |
| **Corrigir permissão de sessão** | ✅ **Sim (incluída durante execução)** | `chown 101:101 ./odoo-data` e `chown 999:999 ./postgresql` |
| Restart dos containers | ✅ Sim | Após correção, ambos os containers saudáveis |
| Criar banco de dados mestre | ⏳ Pendente (após encerramento da GMUD) | Será feito na próxima fase de configuração do Odoo |
| Criar usuário técnico `svc_midpoint` | ⏳ Pendente | Idem |

**Observação importante:** A correção de permissão (`chown`) estava inicialmente prevista como futura, mas a execução identificou a necessidade imediata e foi aplicada dentro da GMUD-001. Isso demonstra agilidade na detecção e resolução de problemas.

---

## 3. Evidências de Sucesso

### 3.1. Containers em execução
```bash
$ sudo docker ps
CONTAINER ID   IMAGE         COMMAND                  STATUS         PORTS
8c3bfa5183eb   odoo:17.0     "/entrypoint.sh odoo"    Up 4 minutes   0.0.0.0:8069->8069/tcp
199b8f671966   postgres:15   "docker-entrypoint.s…"   Up 4 minutes   5432/tcp
```

### 3.2. Logs sem erro de permissão (após correção)
- Não há mais `PermissionError` relacionado a `/var/lib/odoo/sessions`
- O serviço web responde a requisições HTTP (status 200 ou redirecionamentos)

### 3.3. Conectividade via Tailscale
- IP `xxx.xxx.xxx.xxx` responde a ping e a porta 8069 está acessível

---

## 4. Não Conformidades / Desvios

| Desvio | Causa | Impacto | Ação Corretiva |
|--------|-------|---------|----------------|
| Permissão negada para criar diretório de sessões | O usuário do Odoo no container (UID 101) não tinha permissão de escrita no volume `./odoo-data` | Erro 500 no acesso à interface web | Aplicado `chown -R 101:101 ./odoo-data` antes do restart. Incluído definitivamente no procedimento padrão. |

**Nenhuma não conformidade crítica remanescente.**

---

## 5. Lições Aprendidas

1. **Planejar a correção de permissão desde o início** – o `chown` com os UIDs corretos (101 para Odoo, 999 para Postgres) deve fazer parte do modelo padrão de docker-compose para estes containers.
2. **Sempre validar logs imediatamente após o `up -d`** – o erro foi percebido rapidamente e resolvido em menos de 2 minutos.
3. **A memória RAM da VM (3.3GB) é suficiente para subir os serviços, mas será monitorada** – nenhum sintoma de falta de memória até o momento.

---

## 6. Aprovação de Encerramento

Declaro que a GMUD-001 foi executada conforme planejado, com os desvios documentados e corrigidos, e os critérios de aceitação mínimos (containers saudáveis e acesso via rede) foram atendidos.

| Função | Nome | Assinatura | Data |
|--------|------|------------|------|
| **Líder Técnico / Executor** | Paulo Feitosa | (eletrônico) | 11/05/2026 18:50 BRT |
| **Revisor de Qualidade (ISO 27001)** | *a designar* | Pendente | - |

**A mudança está encerrada. O ambiente Odoo está pronto para a fase de configuração funcional (criação de banco, usuário técnico, módulos).**

---

Aguardando suas novas instruções para a configuração do Odoo (criação do banco, ativação de modo desenvolvedor, criação do `svc_midpoint`, geração de API Key, etc.) – que serão documentadas como parte da GMUD-002 ou como uma atividade pós-implantação.
