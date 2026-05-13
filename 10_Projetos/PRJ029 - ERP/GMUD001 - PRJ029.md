

---

# 

**ID da Mudança:** GMUD-001  
**Projeto Relacionado:** PRJ029 - Odoo ERP (Source of Truth)  
**Solicitante:** Paulo Feitosa (Líder Técnico)  
**Data de Abertura:** 11 de Maio de 2026  
**Prioridade:** Alta  

---

## 1. Descrição da Mudança

**Título:** Implantação inicial do Odoo 17.0 em contêiner Docker na VM `erp-odoo-mac`

**Objetivo:**  
Disponibilizar um sistema de origem (HR/RH) funcional para integrar com o ecossistema de IGA (midPoint), permitindo o gerenciamento do ciclo de vida de colaboradores (joiner/mover/leaver).

**Escopo:**
- Subida dos containers `postgres:15` e `odoo:17.0` via Docker Compose
- Configuração de volumes persistentes (`./postgresql`, `./odoo-data`)
- Exposição da porta `8069` na rede local (Tailscale IP `xxx.xxx.xxx.xxx`)
- Criação da base de dados master do Odoo
- Ativação inicial do módulo `Employee`

**Fora de Escopo (GMUD futuras):**
- Configuração de backup automatizado
- Integração com midPoint (será GMUD-002)
- Ajustes de permissão `chown 101:101` (será GMUD-003)

---

## 2. Justificativa e Benefícios

| Critério | Detalhe |
|----------|---------|
| **Motivação** | Necessidade de um sistema de origem confiável para testes de governança de identidade |
| **Riscos mitigados** | Inconsistência de dados cadastrais; ausência de rastreabilidade; acesso residual |
| **Benefícios** | Fonte única de verdade (HR); automação de onboarding/offboarding; conformidade ISO 27001 |

---

## 3. Análise de Impacto e Riscos

### Impacto nos serviços:
- **Serviços afetados:** Nenhum (ambiente novo, sem dependências em produção)
- **Janela de impacto prevista:** N/A

### Riscos identificados:
| Risco | Probabilidade | Severidade | Plano de Contingência |
|-------|---------------|------------|----------------------|
| Porta 8069 já em uso na rede | Baixa | Média | Alterar para 8070 no docker-compose |
| Container Odoo falhar por falta de memória (3.3GB) | Média | Alta | Expandir RAM da VM no VMware |
| Dados persistentes corrompidos | Baixa | Alta | Recriar volumes a partir de backup (ainda não existe - item para GMUD futura) |

---

## 4. Plano de Implementação

### 4.1 Atividades e Sequência

| Passo | Ação | Responsável | Tempo estimado |
|-------|------|-------------|----------------|
| 1 | Acessar VM `erp-odoo-mac` via SSH | Paulo | 1 min |
| 2 | Navegar para `~/odoo-lab` | Paulo | 0.5 min |
| 3 | Validar docker-compose.yml | Paulo | 1 min |
| 4 | Executar `docker compose up -d` | Paulo | 2 min |
| 5 | Verificar logs (`docker compose logs -f --tail 50`) | Paulo | 2 min |
| 6 | Testar acesso HTTP via Tailscale e IP local | Paulo | 2 min |
| 7 | Criar banco de dados mestre via navegador | Paulo | 3 min |
| 8 | Ativar módulo `Employee` | Paulo | 2 min |

**Tempo total estimado:** ~15 minutos

### 4.2 Comandos críticos (já preparados)
```bash
cd ~/odoo-lab
sudo docker compose up -d
sudo docker compose ps
sudo docker compose logs web
```

### 4.3 Rollback (em caso de falha catastrófica)
```bash
cd ~/odoo-lab
sudo docker compose down -v   # remove containers E volumes
# Recriar diretórios vazios
rm -rf ./postgresql ./odoo-data
mkdir ./postgresql ./odoo-data
```

---

## 5. Critérios de Aceite (Pós-Implementação)

- [ ] Container `db` e `web` status `Up` (via `docker ps`)
- [ ] Porta `8069` acessível via `curl -I http://xxx.xxx.xxx.xxx:8069`
- [ ] Página de criação de banco de dados do Odoo acessível no navegador
- [ ] É possível criar um banco de dados master (ex: `erp_livinglab`)
- [ ] Módulo `Employee` ativado sem erros

---

## 6. Aprovações

| Função | Nome | Assinatura | Data |
|--------|------|------------|------|
| **Solicitante / Líder Técnico** | Paulo Feitosa | (eletrônico - via rastreabilidade) | 11/05/2026 |
| **Revisor de Segurança (ISO 27001)** | *a designar* | Pendente | - |
| **Aprovador do CAB** | *a designar* | Pendente | - |

*Nota: Por se tratar de ambiente de laboratório (Living Lab) e mudança de baixo impacto, a aprovação do CAB não é mandatória nesta fase, conforme política interna.*

---

## 7. Histórico de Execução

| Data | Atividade | Responsável | Status |
|------|-----------|-------------|--------|
| 11/05/2026 17:40 | GMUD criada | Paulo Feitosa | ✏️ Aberta |
| Pendente | Execução da implementação | Paulo Feitosa | ⏳ Aguardando |
| Pendente | Validação pós-mudança | Paulo Feitosa | ⏳ Pendente |
| Pendente | Fechamento da GMUD | Paulo Feitosa | ⏳ Pendente |

---

**Aguardando seu "go ahead" para executar a GMUD-001 e iniciar os containers.**  

Deseja que eu já simule os comandos ou prefere executar manualmente e depois reportar?
