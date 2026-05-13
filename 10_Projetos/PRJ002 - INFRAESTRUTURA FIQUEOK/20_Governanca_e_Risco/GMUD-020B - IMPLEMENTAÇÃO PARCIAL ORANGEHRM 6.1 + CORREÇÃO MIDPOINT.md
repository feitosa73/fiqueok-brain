================================================================================

================================================================================
Projeto: PRJ-002 Identity Governance & Administration (IGA)
Título: Implementação Parcial OrangeHRM 6.1 + Correção Base midPoint 4.8 LTS
ID da Mudança: GMUD-021B-PRJ002
Tipo: CORRETIVA + EVOLUTIVA
Severidade: MÉDIA (Melhoria de Ambiente + Correção Estrutural)
Responsável: Paulo Feitosa (Owner/CISO)
Orquestrador Técnico: Gemini Deep-Dive (CTO/Arch) + Perplexity AI (Support)
Data de Execução: 05/01/2026
Status: 🟡 PLANEJADA - PRONTA PARA EXECUÇÃO

================================================================================
1. CONTEXTO E JUSTIFICATIVA
================================================================================

Situação Atual:
- midPoint 4.8.8: Ambiente corrompido (72 tabelas Generic vs 130+ Native Sqale)
- OrangeHRM: Versão atual operacional mas desatualizada
- Necessidade: Fundação estável para integração IGA futura

Alinhamento Estratégico:
Esta GMUD combina duas iniciativas independentes que se beneficiam de execução
conjunta devido ao overlap de janela de manutenção e dependências técnicas:

A) Correção estrutural midPoint (continuação GMUD-020)
B) Atualização OrangeHRM para versão 6.1 (nova iniciativa)

Lições Aplicadas da GMUD-020:
✅ L1: Priorizar recursos embarcados (evitar dependências externas)
✅ L2: Confiar em automação nativa de ferramentas enterprise
✅ L3: Validação incremental de estado após cada mudança crítica
✅ L4: Diagnóstico contextual considerando histórico completo
✅ L5: Circuit breaker de 20 minutos por fase sem progresso

================================================================================
2. ESCOPO E OBJETIVOS
================================================================================

## 2.1 Escopo PARTE A: Restauração midPoint 4.8.8 (Clean Slate)

Objetivo Primário:
Atingir estado HEALTHY do servidor midPoint em menos de 15 minutos,
eliminando intervenção manual no banco de dados.

Estratégia:
- Descomissionamento completo do estado inconsistente (72 tabelas)
- Troca de imagem Alpine → Standard (Debian-based) para maior robustez
- Inicialização nativa Sqale (130+ tabelas auto-criadas)

## 2.2 Escopo PARTE B: Atualização OrangeHRM 6.1

Objetivo Primário:
Migrar OrangeHRM para versão 6.1 LTS mantendo dados e configurações.

Estratégia:
- Backup completo do banco de dados atual
- Deploy novo container OrangeHRM 6.1
- Migração de dados via script oficial
- Validação de funcionalidades críticas

Justificativa da Atualização:
- Versão 6.1: Suporte LTS estendido até 2027
- Melhorias de segurança (CVEs corrigidos)
- Compatibilidade futura com conectores midPoint

Interdependência:
❌ NÃO HÁ DEPENDÊNCIA TÉCNICA entre Parte A e Parte B
✅ Execução conjunta justificada por:
  - Janela de manutenção compartilhada
  - Equipe técnica já mobilizada
  - Backups consolidados em única operação

================================================================================
3. PRÉ-REQUISITOS E VALIDAÇÕES INICIAIS
================================================================================

## 3.1 Validações de Ambiente (Obrigatórias)

□ VM IGA-P-01 operacional (Hyper-V)
□ Docker daemon funcional (docker ps responde)
□ Espaço em disco: > 5 GB disponível em /var/lib/docker
□ Espaço em /backup: > 2 GB disponível
□ Conectividade de rede: teste ping 8.8.8.8
□ PostgreSQL 16: container respondendo

## 3.2 Backups Existentes (da GMUD-020)

✅ Checkpoint Hyper-V: IGA-P-01_Checkpoint_GMUD-020 (disponível)
✅ Backup PostgreSQL midPoint: /tmp/midpoint_backup_20260104.sql
✅ Backup midpoint_home: /backup/midpoint_home_backup_20260104.tar.gz

## 3.3 Novos Backups Requeridos (GMUD-021B)

□ Backup PostgreSQL OrangeHRM (pré-atualização)
□ Backup volumes Docker OrangeHRM
□ Novo Checkpoint Hyper-V: IGA-P-01_Checkpoint_GMUD-021B

================================================================================
4. PROCEDIMENTO DE EXECUÇÃO
================================================================================

## FASE 1: PREPARAÇÃO E BACKUP (Tempo Estimado: 10 min)

### Passo 1.1: Criar Checkpoint Hyper-V
Comando PowerShell (no host Hyper-V):
```powershell
Checkpoint-VM -Name "IGA-P-01" -SnapshotName "IGA-P-01_Checkpoint_GMUD-021B"
```

Validação:
```powershell
Get-VMSnapshot -VMName "IGA-P-01" | Where-Object {$_.Name -like "*GMUD-021B*"}
```

### Passo 1.2: Backup Banco OrangeHRM
Comando:
```bash
docker exec orangehrm-db mysqldump -u orangehrm -p'orangehrm_password' orangehrm > /backup/orangehrm_backup_$(date +%Y%m%d).sql
```

Validação:
```bash
ls -lh /backup/orangehrm_backup_*.sql
# Esperado: Arquivo com tamanho > 100 KB
```

### Passo 1.3: Backup Volumes OrangeHRM
Comando:
```bash
docker run --rm -v orangehrm-data:/data -v /backup:/backup alpine tar czf /backup/orangehrm_volumes_$(date +%Y%m%d).tar.gz /data
```

Validação:
```bash
tar -tzf /backup/orangehrm_volumes_$(date +%Y%m%d).tar.gz | head -20
# Esperado: Lista de arquivos do OrangeHRM
```

Critério de Aceite FASE 1:
✅ 3 backups criados e validados
✅ Checkpoint Hyper-V confirmado
✅ Tempo < 12 minutos

---

## FASE 2: RESTAURAÇÃO MIDPOINT 4.8.8 (Tempo Estimado: 12 min)

### Passo 2.1: Descomissionamento do Estado Inconsistente

Comando 1 - Parar containers:
```bash
docker compose down
```

Validação:
```bash
docker ps -a | grep midpoint
# Esperado: Nenhuma saída (containers removidos)
```

Comando 2 - Remover volume corrompido:
```bash
docker volume rm midpoint-db-data
```

Validação GRC:
```bash
docker volume ls | grep midpoint-db-data
# Esperado: Nenhuma saída (volume removido completamente)
```

⚠️ CRÍTICO: Sem este passo, o banco manterá as 72 tabelas incompatíveis

### Passo 2.2: Ajuste de Robustez da Imagem

Comando - Trocar Alpine → Standard:
```bash
sed -i.bak 's/evolveum\/midpoint:4\.8\.8-alpine/evolveum\/midpoint:4.8.8/' docker-compose.yml
```

Validação:
```bash
grep "image: evolveum/midpoint:" docker-compose.yml
# Esperado: evolveum/midpoint:4.8.8 (sem sufixo -alpine)
```

Justificativa Técnica:
- Imagem Alpine: paths de scripts otimizados, menos tolerante a erros
- Imagem Standard (Debian): mais verbosa, robusta para troubleshooting
- Referência: Lição L1 (evitar dependências externas frágeis)

### Passo 2.3: Inicialização Nativa Sqale

Comando:
```bash
docker compose up -d
```

Monitoramento em tempo real:
```bash
docker logs -f midpoint-server
```

Marcos de Progresso Esperados:
```
[00:00-02:00] Downloading layers...
[02:00-04:00] Starting PostgreSQL connection...
[04:00-08:00] Initializing Native Repository Sqale...
[08:00-10:00] Creating tables (m_*, audit.*, quartz.*)...
[10:00-12:00] Loading initial objects (Administrator, Superuser Role)...
[12:00-14:00] Starting web server (Tomcat)...
[14:00-15:00] midPoint started (v4.8.8)
```

Critério de Aceite FASE 2:
✅ Log exibe "midPoint started"
✅ Container status: healthy
✅ Tempo < 15 minutos

---

## FASE 3: VALIDAÇÃO MIDPOINT (Tempo Estimado: 5 min)

### Passo 3.1: Validação de Integridade do Banco

Comando 1 - Contagem de tabelas:
```bash
docker exec midpoint-db psql -U midpoint -d midpoint -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'm_%';"
```

Resultado Esperado: > 100 tabelas

Comando 2 - Versão do schema:
```bash
docker exec midpoint-db psql -U midpoint -d midpoint -c "SELECT databaseschemaversion FROM m_global_metadata;"
```

Resultado Esperado: 4.8

### Passo 3.2: Validação de Disponibilidade Web

Teste 1 - Health check:
```bash
curl -I http://xxx.xxx.xxx.xxx:8080/midpoint/
```

Resultado Esperado: HTTP/1.1 200 OK

Teste 2 - Acesso via browser:
URL: http://xxx.xxx.xxx.xxx:8080/midpoint/
Credenciais: administrator / 5ecr3t

Validação Visual:
□ Página de login carrega sem erros
□ Versão exibida no rodapé: 4.8.8
□ Login bem-sucedido → Dashboard visível

Critério de Aceite FASE 3:
✅ Banco com 100+ tabelas Native Sqale
✅ Versão schema: 4.8
✅ Login web funcional
✅ Tempo < 7 minutos

---

## FASE 4: ATUALIZAÇÃO ORANGEHRM 6.1 (Tempo Estimado: 18 min)

### Passo 4.1: Parar Container Atual

Comando:
```bash
docker stop orangehrm
docker rm orangehrm
```

Validação:
```bash
docker ps -a | grep orangehrm
# Esperado: Apenas orangehrm-db (container de aplicação removido)
```

### Passo 4.2: Atualizar docker-compose.yml

Edição manual (nano/vim):
```yaml
# Seção orangehrm:
  orangehrm:
    image: orangehrm/orangehrm:6.1
    container_name: orangehrm
    ports:
      - "8081:80"
    environment:
      - ORANGEHRM_DATABASE_HOST=orangehrm-db
      - ORANGEHRM_DATABASE_USER=orangehrm
      - ORANGEHRM_DATABASE_PASSWORD=orangehrm_password
      - ORANGEHRM_DATABASE_NAME=orangehrm
    depends_on:
      - orangehrm-db
    volumes:
      - orangehrm-data:/var/www/html/src/cache
    networks:
      - orangehrm-net
    restart: unless-stopped
```

Validação:
```bash
grep "orangehrm/orangehrm:6.1" docker-compose.yml
# Esperado: Linha com nova versão
```

### Passo 4.3: Deploy Nova Versão

Comando:
```bash
docker compose up -d orangehrm
```

Monitoramento:
```bash
docker logs -f orangehrm
```

Marcos de Progresso:
```
[00:00-03:00] Pulling image orangehrm:6.1...
[03:00-06:00] Starting Apache...
[06:00-10:00] Detecting existing database...
[10:00-15:00] Running migration scripts (5.x → 6.1)...
[15:00-18:00] Rebuilding cache...
[18:00] OrangeHRM 6.1 ready
```

### Passo 4.4: Validação Pós-Atualização

Teste 1 - Health check:
```bash
curl -I http://xxx.xxx.xxx.xxx:8081
```

Resultado Esperado: HTTP/1.1 200 OK

Teste 2 - Acesso via browser:
URL: http://xxx.xxx.xxx.xxx:8081
Credenciais: admin / admin (ou credenciais configuradas)

Validações Funcionais:
□ Login bem-sucedido
□ Dashboard carrega sem erros
□ Módulos principais acessíveis:
  - PIM (Employee Management)
  - Leave (Gestão de Férias)
  - Time (Controle de Ponto)
  - Admin (Configurações)

Teste 3 - Verificação de versão:
Caminho: Admin → About
Esperado: OrangeHRM Version 6.1

Critério de Aceite FASE 4:
✅ Container orangehrm status: healthy
✅ Login funcional
✅ Versão 6.1 confirmada
✅ Dados migrados (usuários, funcionários preservados)
✅ Tempo < 20 minutos

---

## FASE 5: VALIDAÇÃO INTEGRADA (Tempo Estimado: 5 min)

### Passo 5.1: Teste de Coexistência

Validar que ambos os sistemas estão operacionais simultaneamente:

```bash
docker ps --format "table {{.Names}}	{{.Status}}	{{.Ports}}"
```

Resultado Esperado:
```
NAMES              STATUS              PORTS
midpoint-server    Up 15 minutes       0.0.0.0:8080->8080/tcp
midpoint-db        Up 15 minutes       5432/tcp
orangehrm          Up 5 minutes        0.0.0.0:8081->80/tcp
orangehrm-db       Up 3 days           3306/tcp
```

### Passo 5.2: Teste de Recursos

Comando:
```bash
docker stats --no-stream --format "table {{.Name}}	{{.CPUPerc}}	{{.MemUsage}}"
```

Limites Aceitáveis:
- midpoint-server: CPU < 50%, RAM < 2 GB
- orangehrm: CPU < 30%, RAM < 512 MB

### Passo 5.3: Teste de Conectividade

Teste 1 - midPoint:
```bash
curl -s http://xxx.xxx.xxx.xxx:8080/midpoint/ | grep "midPoint"
```

Teste 2 - OrangeHRM:
```bash
curl -s http://xxx.xxx.xxx.xxx:8081 | grep "OrangeHRM"
```

Critério de Aceite FASE 5:
✅ Ambos os sistemas respondendo
✅ Recursos dentro dos limites
✅ Nenhum erro em logs recentes
✅ Tempo < 7 minutos

================================================================================
5. MATRIZ DE VALIDAÇÃO CONSOLIDADA
================================================================================

| Teste | Comando de Verificação | Resultado Esperado | Status |
|-------|------------------------|-------------------|--------|
| **midPoint - Boot** | `docker logs midpoint-server \| grep "started"` | "midPoint started" | □ |
| **midPoint - DB Tables** | `docker exec midpoint-db psql -U midpoint -d midpoint -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name LIKE 'm_%';"` | > 100 tabelas | □ |
| **midPoint - Schema Version** | `docker exec midpoint-db psql -U midpoint -d midpoint -c "SELECT databaseschemaversion FROM m_global_metadata;"` | 4.8 | □ |
| **midPoint - Web Access** | Browser: http://xxx.xxx.xxx.xxx:8080/midpoint/ | Tela de Login | □ |
| **midPoint - Login** | Credenciais: administrator/5ecr3t | Dashboard visível | □ |
| **OrangeHRM - Container** | `docker ps \| grep orangehrm` | Status: Up | □ |
| **OrangeHRM - Web Access** | Browser: http://xxx.xxx.xxx.xxx:8081 | Tela de Login | □ |
| **OrangeHRM - Version** | Admin → About | Version 6.1 | □ |
| **OrangeHRM - Data Integrity** | Verificar lista de funcionários | Dados preservados | □ |
| **Coexistência** | `docker ps --format "{{.Names}}"` | midpoint-server + orangehrm | □ |

================================================================================
6. ANÁLISE DE RISCO E MITIGAÇÃO
================================================================================

## 6.1 Riscos Técnicos

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| **R1: midPoint não inicializar Native Sqale** | BAIXA | ALTO | Validação incremental (Passo 3.1). Rollback via Checkpoint. |
| **R2: Migração OrangeHRM corromper dados** | MÉDIA | ALTO | Backup validado (Fase 1). Teste de integridade (Fase 4.4). |
| **R3: Conflito de recursos (RAM/CPU)** | BAIXA | MÉDIO | Monitoramento (Fase 5.2). Limits no docker-compose. |
| **R4: Timeout de download de imagens** | BAIXA | BAIXO | Executar `docker pull` antes da GMUD. |
| **R5: Incompatibilidade versão MySQL** | MUITO BAIXA | MÉDIO | OrangeHRM 6.1 suporta MySQL 5.7-8.0 (atual: 8.0). |

## 6.2 Riscos de Governança (ISO 27001)

| Controle | Requisito | Validação |
|----------|-----------|-----------|
| **A.12.1.2 - Gestão de Mudanças** | GMUD aprovada e documentada | ✅ Este documento |
| **A.12.3.1 - Backup** | Backups validados antes da mudança | ✅ Fase 1 |
| **A.14.2.2 - Procedimentos de Entrega** | Validação de integridade pós-deploy | ✅ Fases 3 e 4 |
| **A.16.1.7 - Lições Aprendidas** | Aplicação de aprendizados anteriores | ✅ Lições L1-L5 (GMUD-020) |

## 6.3 Riscos Operacionais

**Indisponibilidade Planejada:**
- midPoint: 15 minutos (durante Fase 2-3)
- OrangeHRM: 20 minutos (durante Fase 4)

**Impacto:**
- BAIXO: Ambiente de laboratório (não-produção)
- Nenhum usuário final afetado
- Sistemas podem ficar indisponíveis sem impacto em SLA

**Janela de Execução:**
- Início: 21:30 BRT (05/01/2026)
- Término Previsto: 22:30 BRT (60 minutos)
- Buffer: +30 minutos para troubleshooting

================================================================================
7. ROLLBACK PLAN
================================================================================

## 7.1 Estratégia de Rollback Completo (Recomendada)

**Cenário:** Falha crítica em qualquer fase após 20 minutos sem resolução

Comando PowerShell (no host Hyper-V):
```powershell
Restore-VMSnapshot -Name "IGA-P-01_Checkpoint_GMUD-021B" -VMName "IGA-P-01" -Confirm:$false
Start-VM -Name "IGA-P-01"
```

Tempo Estimado: 5-8 minutos

Resultado:
- Retorno ao estado pré-GMUD
- midPoint: Estado corrompido (como antes)
- OrangeHRM: Versão anterior operacional

## 7.2 Rollback Parcial - Apenas midPoint

**Cenário:** Falha apenas na Fase 2-3, OrangeHRM não iniciado

Passo 1 - Restaurar volume:
```bash
docker volume create midpoint-db-data
docker run --rm -v midpoint-db-data:/data -v /tmp:/backup alpine sh -c "cd /data && tar xzf /backup/midpoint_db_backup_20260104.tar.gz"
```

Passo 2 - Voltar para imagem Alpine:
```bash
sed -i 's/evolveum\/midpoint:4.8.8/evolveum\/midpoint:4.8.8-alpine/' docker-compose.yml
```

Passo 3 - Reiniciar:
```bash
docker compose up -d
```

Tempo Estimado: 8 minutos

## 7.3 Rollback Parcial - Apenas OrangeHRM

**Cenário:** Falha apenas na Fase 4, midPoint já validado

Passo 1 - Restaurar container anterior:
```bash
docker stop orangehrm
docker rm orangehrm
```

Passo 2 - Editar docker-compose.yml:
```bash
sed -i 's/orangehrm\/orangehrm:6.1/orangehrm\/orangehrm:5.6/' docker-compose.yml
```

Passo 3 - Restaurar banco:
```bash
docker exec -i orangehrm-db mysql -u orangehrm -p'orangehrm_password' orangehrm < /backup/orangehrm_backup_20260105.sql
```

Passo 4 - Subir container:
```bash
docker compose up -d orangehrm
```

Tempo Estimado: 10 minutos

## 7.4 Critérios de Ativação de Rollback

Ativar rollback SE:
- ❌ Tempo de execução de uma fase > 20 minutos sem progresso
- ❌ Erros críticos em logs (ex: "FATAL", "Segmentation fault")
- ❌ 3 tentativas de correção sem sucesso
- ❌ Container permanece unhealthy por > 10 minutos

NÃO ativar rollback SE:
- ⚠️ Warnings não-críticos em logs
- ⚠️ Lentidão temporária de download de imagens
- ⚠️ Mensagens informativas de migração de dados

================================================================================
8. MÉTRICAS E KPIs
================================================================================

## 8.1 Tempo de Execução (RTO)

| Fase | Tempo Planejado | Tempo Máximo Aceitável | Buffer |
|------|----------------|----------------------|--------|
| Fase 1: Backup | 10 min | 12 min | +2 min |
| Fase 2: midPoint Restore | 12 min | 15 min | +3 min |
| Fase 3: Validação midPoint | 5 min | 7 min | +2 min |
| Fase 4: OrangeHRM Update | 18 min | 20 min | +2 min |
| Fase 5: Validação Final | 5 min | 7 min | +2 min |
| **TOTAL** | **50 min** | **61 min** | **+11 min** |

## 8.2 Objetivos de Recuperação (RPO)

| Sistema | RPO | Backup Disponível |
|---------|-----|------------------|
| midPoint | 0 min | Checkpoint Hyper-V (pré-GMUD) |
| OrangeHRM | 0 min | Dump MySQL (Fase 1) |
| PostgreSQL midPoint | 24h | Dump existente (GMUD-020) |

## 8.3 Indicadores de Sucesso

| KPI | Meta | Medição |
|-----|------|---------|
| **Taxa de Sucesso Geral** | 100% | (Fases concluídas / Total de fases) × 100 |
| **Disponibilidade midPoint** | > 99% | Tempo online / Tempo total pós-GMUD |
| **Disponibilidade OrangeHRM** | > 99% | Tempo online / Tempo total pós-GMUD |
| **Integridade de Dados** | 100% | Registros preservados / Total de registros |
| **Performance midPoint** | < 5s | Tempo de resposta página de login |
| **Performance OrangeHRM** | < 3s | Tempo de resposta dashboard |

## 8.4 Checklist de Conformidade

□ Backups validados antes do início (ISO 27001 A.12.3.1)
□ Mudanças documentadas e rastreáveis (ISO 27001 A.12.1.2)
□ Validação de integridade executada (ISO 27001 A.14.2.2)
□ Lições aprendidas aplicadas (ISO 27001 A.16.1.7)
□ Rollback plan testável disponível (ISO 27001 A.17.1.2)
□ Evidências geradas e arquivadas (ISO 27001 A.18.1.3)

================================================================================
9. COMUNICAÇÃO E STAKEHOLDERS
================================================================================

## 9.1 Notificação Pré-GMUD (T-24h)

**Destinatários:** Equipe técnica + Usuários de laboratório (se aplicável)

**Mensagem:**
```
Assunto: GMUD-021B - Manutenção Ambiente IGA (05/01/2026)

Prezados,

Será realizada manutenção no ambiente IGA (lab) conforme detalhes:

Data/Hora: 05/01/2026 às 21:30 BRT
Duração Estimada: 60 minutos
Impacto: Indisponibilidade temporária de midPoint e OrangeHRM

Sistemas Afetados:
- midPoint 4.8.8 (http://xxx.xxx.xxx.xxx:8080) - 15 min indisponível
- OrangeHRM (http://xxx.xxx.xxx.xxx:8081) - 20 min indisponível

Ações:
✅ Backups validados
✅ Rollback plan disponível
✅ Comunicação de conclusão será enviada ao término

Dúvidas: contato@fiqueok.com.br
```

## 9.2 Notificação Pós-GMUD (T+0)

**Mensagem de Sucesso:**
```
Assunto: ✅ GMUD-021B CONCLUÍDA - Ambiente IGA Restaurado

GMUD-021B executada com sucesso em XX minutos.

Sistemas Disponíveis:
✅ midPoint 4.8.8: http://xxx.xxx.xxx.xxx:8080/midpoint/
✅ OrangeHRM 6.1: http://xxx.xxx.xxx.xxx:8081

Melhorias Implementadas:
- midPoint: Base de dados corrigida (130+ tabelas Native Sqale)
- OrangeHRM: Atualizado para versão 6.1 LTS

Próximos Passos:
- Monitoramento 24h
- Relatório detalhado disponível em: REL-GMUD-021B.md
```

**Mensagem de Rollback (se necessário):**
```
Assunto: ⚠️ GMUD-021B SUSPENSA - Rollback Executado

GMUD-021B foi suspensa devido a [razão].

Ação Tomada:
✅ Rollback completo executado
✅ Ambiente restaurado ao estado pré-GMUD
✅ Nenhuma perda de dados

Status Atual:
- midPoint: [estado atual]
- OrangeHRM: Operacional (versão anterior)

Próxima Ação:
- Análise de root cause
- Reprogramação da GMUD-021B
```

================================================================================
10. LIÇÕES APRENDIDAS ESPERADAS
================================================================================

## 10.1 Aplicação de Lições Anteriores (GMUD-020)

| Lição | Como foi Aplicada na GMUD-021B |
|-------|-------------------------------|
| **L1: Recursos Embarcados** | Troca Alpine→Standard elimina dependência de caminhos externos |
| **L2: Automação Nativa** | Volume rm + auto-init garante Native Sqale sem intervenção manual |
| **L3: Validação Incremental** | Checkpoints de validação após cada fase crítica (3.1, 4.4, 5.3) |
| **L4: Diagnóstico Contextual** | Histórico GMUD-020 considerado no design da Clean Slate |
| **L5: Circuit Breaker** | Limite de 20 min por fase definido no Rollback Plan |

## 10.2 Novas Lições Esperadas (Pós-GMUD-021B)

**L6: Atualização de Aplicações Containerizadas**
- Contexto: Migração OrangeHRM 5.x → 6.1
- Aprendizado esperado: Validação de compatibilidade de banco (MySQL versioning)
- Aplicação futura: Template de atualização para outros serviços (PKI, AD)

**L7: GMUDs Compostas (Multi-Sistema)**
- Contexto: Mudança afeta 2 sistemas independentes na mesma janela
- Aprendizado esperado: Estratégia de priorização (crítico vs evolutivo)
- Aplicação futura: Definir critérios de "é melhor separar em 2 GMUDs?"

**L8: Validação de Coexistência**
- Contexto: Fase 5 valida que midPoint e OrangeHRM não competem por recursos
- Aprendizado esperado: Thresholds de CPU/RAM para ambiente multi-container
- Aplicação futura: Sizing de VM IGA-P-01 para escalar serviços

================================================================================
11. DOCUMENTAÇÃO E EVIDÊNCIAS
================================================================================

## 11.1 Artefatos Gerados Durante a GMUD

Durante a execução, os seguintes arquivos serão criados:

```
/backup/
├── GMUD-021B/
│   ├── orangehrm_backup_20260105.sql         # Dump MySQL (Fase 1.2)
│   ├── orangehrm_volumes_20260105.tar.gz     # Backup volumes (Fase 1.3)
│   ├── docker-compose.yml.bak                # Backup config (Fase 2.2)
│   ├── execution_log_20260105.txt            # Log completo da execução
│   └── screenshots/
│       ├── midpoint_login_success.png        # Evidência Fase 3.2
│       └── orangehrm_dashboard_v6.1.png      # Evidência Fase 4.4
```

## 11.2 Checkpoint Hyper-V

Nome: `IGA-P-01_Checkpoint_GMUD-021B`
Localização: Hyper-V Manager → IGA-P-01 → Snapshots
Retenção: 7 dias (excluir após 12/01/2026)

## 11.3 Relatório Pós-GMUD

Documento a ser criado: `REL-GMUD-021B.md`

Estrutura esperada:
1. Sumário Executivo
2. Tempo de Execução vs Planejado
3. Desvios e Incidentes
4. Validações Executadas (tabela preenchida)
5. Lições Aprendidas Consolidadas
6. Recomendações para GMUDs Futuras
7. Assinaturas e Aprovações

================================================================================
12. CRITÉRIOS DE SUCESSO E ACEITE
================================================================================

## 12.1 Critérios Obrigatórios (PASS/FAIL)

A GMUD-021B será considerada **BEM-SUCEDIDA** SE E SOMENTE SE:

✅ **midPoint:**
  □ Container status: healthy por > 5 minutos
  □ Banco com > 100 tabelas (Native Sqale)
  □ Login web funcional (administrator/5ecr3t)
  □ Versão exibida: 4.8.8

✅ **OrangeHRM:**
  □ Container status: healthy por > 5 minutos
  □ Login web funcional
  □ Versão exibida: 6.1
  □ Dados preservados (lista de funcionários validada)

✅ **Coexistência:**
  □ Ambos os sistemas acessíveis simultaneamente
  □ CPU total < 70%
  □ RAM total < 4 GB

✅ **Governança:**
  □ Backups validados (Fase 1)
  □ Evidências capturadas (screenshots)
  □ Tempo total < 70 minutos

## 12.2 Critérios Desejáveis (Bônus)

Além dos critérios obrigatórios, são considerados **DESEJÁVEIS**:

⭐ Performance midPoint: Tempo de resposta login < 3s
⭐ Performance OrangeHRM: Tempo de resposta dashboard < 2s
⭐ Zero erros em logs recentes (últimos 100 linhas)
⭐ Tempo de execução < 50 minutos (dentro do planejado)

## 12.3 Critérios de Rejeição (GMUD Falhada)

A GMUD-021B será considerada **FALHADA** SE:

❌ Container permanece unhealthy após 3 tentativas de correção
❌ Perda de dados detectada (OrangeHRM)
❌ Corrupção de banco de dados não-recuperável
❌ Tempo de execução > 90 minutos
❌ Rollback falha (necessidade de escalar para Checkpoint Hyper-V)

================================================================================
13. PRÓXIMOS PASSOS (PÓS-GMUD-021B)
================================================================================

## 13.1 Imediato (Próximas 24h)

□ Monitoramento contínuo de logs (midPoint + OrangeHRM)
□ Validação de estabilidade (containers não reiniciam)
□ Elaboração do REL-GMUD-021B.md
□ Comunicação aos stakeholders

## 13.2 Curto Prazo (1 semana)

□ Atualizar documentação de ambiente (topologia, versões)
□ Arquivar backups em storage secundário
□ Testar conectividade midPoint ↔ OrangeHRM (preparação para integração)
□ Excluir checkpoint Hyper-V antigo (GMUD-020)

## 13.3 Médio Prazo (1 mês)

□ GMUD-022: Configuração de conector OrangeHRM no midPoint
□ Implementação de monitoramento (Prometheus/Grafana)
□ Testes de carga (quantos usuários simultâneos suportam?)
□ Documentação de runbooks operacionais

## 13.4 Longo Prazo (Roadmap IGA)

□ Integração midPoint ↔ Active Directory
□ Implementação de workflows de provisioning automático
□ Políticas de acesso baseadas em papel (RBAC)
□ Auditoria de acessos (compliance ISO 27001)

================================================================================
14. APROVAÇÕES E ASSINATURAS
================================================================================

## 14.1 Elaboração e Revisão

**Elaborado por:**
Nome: Gemini Deep-Dive (CTO/Arch) + Perplexity AI (Support)
Data: 04/01/2026 21:30 BRT
Versão: 1.0

**Revisado por:**
Nome: Paulo Feitosa (Owner/CISO)
Data: ___/___/______
Assinatura: _________________________________

## 14.2 Aprovação de Mudança

**Change Manager (Ambiente Lab):**
Nome: Paulo Feitosa
Data de Aprovação: ___/___/______
Assinatura: _________________________________

Decisão: □ APROVADA   □ REJEITADA   □ ADIADA

Comentários:
_________________________________________________________________
_________________________________________________________________

## 14.3 Responsável pela Execução

**Executor Técnico:**
Nome: Paulo Feitosa (IGA-P-01)
Data de Execução: 05/01/2026
Confirmação de Início: ___:___ BRT
Confirmação de Término: ___:___ BRT

Resultado: □ SUCESSO   □ SUCESSO PARCIAL   □ ROLLBACK

Observações:
_________________________________________________________________
_________________________________________________________________

================================================================================
15. HISTÓRICO DE REVISÕES
================================================================================

| Versão | Data       | Autor                  | Descrição                          |
|--------|------------|------------------------|-----------------------------------|
| 1.0    | 04/01/2026 | Gemini + Perplexity    | Versão inicial para aprovação     |
|        |            |                        |                                   |
|        |            |                        |                                   |

================================================================================
16. REFERÊNCIAS E ANEXOS
================================================================================

## 16.1 Documentos Relacionados

- REL-GMUD-020.md - Relatório de Implementação Parcial
- GMUD-020B.md - Plano de Restauração midPoint (contexto original)
- Manifesto Fiqueok v2.0.pdf - Estratégia GRC e Arquitetura

## 16.2 Referências Técnicas

- Evolveum midPoint 4.8 Documentation: https://docs.evolveum.com/midpoint/4.8/
- OrangeHRM 6.1 Release Notes: https://github.com/orangehrm/orangehrm/releases/6.1
- Docker Compose Best Practices: https://docs.docker.com/compose/production/
- ISO/IEC 27001:2013 - Controles A.12 (Segurança nas Operações)

## 16.3 Contatos de Emergência

**Responsável Técnico:**
Nome: Paulo Feitosa
Telefone: [REDACTED]
Email: paulo@fiqueok.com.br

**Suporte Hyper-V (Host):**
Acesso: RDP xxx.xxx.xxx.xxx (host físico)
Credenciais: [Armazenadas em Bitwarden]

**Escalação (se necessário):**
- Evolveum Community: https://evolveum.com/services/professional-support/
- OrangeHRM Community: https://forum.orangehrm.com/

================================================================================
FIM DA GMUD-021B
================================================================================

Status: 🟡 AGUARDANDO APROVAÇÃO
Próxima Ação: Revisão e assinatura por Paulo Feitosa
Data Prevista de Execução: 05/01/2026 21:30 BRT

================================================================================

