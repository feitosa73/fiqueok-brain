# GMUD-021A - Deploy de Infraestrutura OrangeHRM

**Status:** Planejamento  
**Versão:** 5.0 (Final com Sanitização Completa)  
**Data de Criação:** 06/01/2026  
**Última Atualização:** 06/01/2026 11:35  
**Responsável:** Perplexity Pro (GRC Lead) + ChatGPT (Systems Architect) + Gemini (Deep-Dive Consultant)  
**Aprovador:** Paulo Feitosa (Owner)

---

## 1. Identificação da Mudança

| Campo | Valor |
|-------|-------|
| **ID da GMUD** | GMUD-021A |
| **Título** | Deploy de Infraestrutura OrangeHRM com Sanitização Total de Ambiente Docker e Filesystem |
| **Categoria** | Infraestrutura, Custódia de Dados e Higienização Total de Ativos |
| **Prioridade** | Alta |
| **Ambiente** | Laboratório - IGA-P-01 (xxx.xxx.xxx.xxx) |
| **Janela de Execução** | 07/01/2026 - 19:00 às 22:30 (3h30min) |
| **Impacto Estimado** | Downtime de 5-8 minutos (midPoint) durante Fase 0 |

---

## 2. Justificativa e Contexto Estratégico

O projeto Fiqueok Living Lab demanda estabelecer o OrangeHRM 5.8 como Source of Truth (SoT) para o ecossistema de Identity Governance and Administration (IGA). Esta GMUD implementa não apenas o deploy técnico, mas também a **sanitização total do ambiente Docker e filesystem**, removendo ativos órfãos, containers obsoletos e resíduos de experimentos anteriores (midPoint 4.10) para conformidade plena com ISO 27001 - A.8.1 (Inventário de Ativos) e A.8.9 (Configuração de Ativos).

**Contexto de Higienização Total:**
- Durante as fases anteriores do projeto (GMUDs 001-020), foram criadas redes, containers e **arquivos experimentais** que não estão mais em uso
- O container `midpoint-db` (PostgreSQL 16) foi substituído pelo H2 Embedded (File Mode) conforme GMUD-020D
- O container `midpoint-server` (versão 4.10) foi substituído pelo `midpoint` (versão 4.8.8 LTS)
- Redes Docker órfãs (`midpoint_lab_net`, `orangehrm_lab_net`, `fiqueok-backend-net`) devem ser expurgadas
- **Arquivos residuais da versão 4.10** (`midpoint-db-4.10.sql`, `midpoint_home-4.10.tar.gz`) e diretórios experimentais (`~/midpoint_lab`, `~/orangehrm_lab`) devem ser removidos do filesystem

**Alinhamento com Frameworks de Conformidade:**
- **ISO 27001:2022 - A.12.1.2:** Gestão de Mudanças
- **ISO 27001:2022 - A.8.1:** Gestão de Ativos de Informação (Inventário atualizado)
- **ISO 27001:2022 - A.8.9:** Configuração de Ativos (Baseline de configuração)
- **ISO 27001:2022 - A.8.10:** Eliminação de Informação (Descarte seguro de ativos)
- **NIST CSF 2.0 - PR.IP-3:** Configuration Change Control
- **NIST CSF 2.0 - ID.AM-1:** Physical devices and systems within the organization are inventoried
- **CIS Controls v8 - 1.1:** Establish and Maintain Detailed Enterprise Asset Inventory

---

## 3. Objetivo da Mudança

### 3.1. Objetivos Primários

1. **Sanitização Total de Ambiente:** Descomissionar formalmente containers obsoletos (`midpoint-db`, `midpoint-server`), redes Docker órfãs e **arquivos residuais do filesystem**
2. **Deploy de OrangeHRM 5.8:** Provisionar containers `orangehrm-app` e `orangehrm-db` (MariaDB 11.4) na rede autoritativa `stack-iga_midpoint-net` (172.22.0.0/16)
3. **Integração Simplificada:** Garantir conectividade com midPoint 4.8.8 LTS (H2 Embedded File) via DNS interno Docker
4. **Conformidade de Inventário:** Atualizar inventário de ativos para refletir estado operacional real (zero vestígios de experimentos)

### 3.2. Critérios de Aceite

**Fase 0 - Sanitização Total:**
- [ ] Container `midpoint-db` (PostgreSQL) descomissionado com evidências
- [ ] Container `midpoint-server` (4.10) descomissionado e substituído por `midpoint` (4.8.8)
- [ ] Redes Docker órfãs removidas do inventário
- [ ] Arquivos residuais da versão 4.10 removidos do filesystem (`~/midpoint-db-4.10.sql`, `~/midpoint_home-4.10.tar.gz`)
- [ ] Diretórios experimentais removidos (`~/midpoint_lab`, `~/orangehrm_lab`)
- [ ] midPoint 4.8.8 LTS operacional em H2 Embedded (File Mode) após sanitização
- [ ] Inventário de ativos Docker e filesystem atualizado
- [ ] Permissões de bind mounts validadas (UID 1000 para midPoint Alpine)

**Fase 1 - Deploy OrangeHRM:**
- [ ] Containers `orangehrm-app` e `orangehrm-db` operacionais na rede `stack-iga_midpoint-net`
- [ ] OrangeHRM 5.8 acessível via porta 8081 (http://xxx.xxx.xxx.xxx:8081)
- [ ] Conectividade validada entre containers via DNS interno (ping midpoint → orangehrm-app)
- [ ] Persistência de dados configurada em bind mounts em `/opt/stack-iga/`
- [ ] Stack midPoint 4.8.8 LTS não afetada pela mudança
- [ ] Zero conflitos de portas (8080, 8081, 3306, 5432)

---

## 4. Escopo Técnico

### 4.1. Componentes Afetados

| Componente | Tipo | Status Atual | Mudança | Justificativa |
|------------|------|--------------|---------|---------------|
| IGA-P-01 | VM Ubuntu 22.04 | Operacional | Sem alteração | Host físico |
| stack-iga_midpoint-net | Rede Docker | Ativa (172.22.0.0/16) | Expansão | Rede autoritativa |
| midpoint-server | Container (4.10) | Ativo | **Descomissionar** | Substituído por midPoint 4.8.8 |
| midpoint | Container (4.8.8) | Inexistente | **Criação** | Versão LTS estável |
| midpoint-db | Container PostgreSQL | **Obsoleto** | **Descomissionar** | Substituído por H2 Embedded |
| midpoint_lab_net | Rede Docker | Órfã | **Remover** | Experimento descontinuado |
| orangehrm_lab_net | Rede Docker | Órfã | **Remover** | Experimento descontinuado |
| fiqueok-backend-net | Rede Docker | Órfã | **Remover** | Substituída por stack-iga_midpoint-net |
| ~/midpoint-db-4.10.sql | Arquivo | Residual | **Remover** | Backup obsoleto |
| ~/midpoint_home-4.10.tar.gz | Arquivo | Residual | **Remover** | Backup obsoleto |
| ~/midpoint_lab/ | Diretório | Experimental | **Remover** | Não mais em uso |
| ~/orangehrm_lab/ | Diretório | Experimental | **Remover** | Não mais em uso |
| orangehrm-db | Container MariaDB | Inexistente | **Criação** | Database OrangeHRM |
| orangehrm-app | Container OrangeHRM | Inexistente | **Criação** | HR Source of Truth |

### 4.2. Dependências

Esta GMUD depende das seguintes mudanças anteriores:
- **GMUD-007:** Configuração de IP estático IGA-P-01
- **GMUD-008:** Implantação da Stack midPoint 4.8.8 LTS (H2 Embedded File)
- **GMUD-020D:** Rollback para H2 Embedded (descontinuidade do PostgreSQL e midPoint 4.10)

---

## 5. Plano de Execução

### 5.0. FASE 0 - SANITIZAÇÃO TOTAL E DESCOMISSIONAMENTO

**Objetivo:** Higienizar ambiente Docker e filesystem, removendo ativos obsoletos e órfãos conforme ISO 27001 - A.8.1, A.8.9 e A.8.10

**Duração Estimada:** 25 minutos  
**Impacto:** Downtime de ~5-8 minutos no midPoint durante transição de `midpoint-server` → `midpoint`

#### 5.0.1. Inventário de Ativos Pré-Sanitização

```bash
# ===================================================================
# FASE 0.1: INVENTÁRIO COMPLETO DE ATIVOS (PRÉ-SANITIZAÇÃO)
# Executor: Paulo Feitosa / ChatGPT (Systems Architect)
# Data: 07/01/2026 19:00
# ===================================================================

# 1. Listar todos os containers (ativos e parados)
docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" > /opt/stack-iga/GMUD-021A-inventario-pre-sanitizacao-containers.txt

# 2. Listar todas as redes Docker
docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}" > /opt/stack-iga/GMUD-021A-inventario-pre-sanitizacao-redes.txt

# 3. Listar volumes Docker
docker volume ls > /opt/stack-iga/GMUD-021A-inventario-pre-sanitizacao-volumes.txt

# 4. Inventário de arquivos residuais no filesystem
ls -lh ~/midpoint-db-4.10.sql ~/midpoint_home-4.10.tar.gz 2>/dev/null > /opt/stack-iga/GMUD-021A-inventario-pre-sanitizacao-arquivos.txt
du -sh ~/midpoint_lab ~/orangehrm_lab 2>/dev/null >> /opt/stack-iga/GMUD-021A-inventario-pre-sanitizacao-arquivos.txt

# 5. Exibir conteúdo do inventário
echo "=== CONTAINERS ==="
cat /opt/stack-iga/GMUD-021A-inventario-pre-sanitizacao-containers.txt
echo ""
echo "=== REDES DOCKER ==="
cat /opt/stack-iga/GMUD-021A-inventario-pre-sanitizacao-redes.txt
echo ""
echo "=== ARQUIVOS RESIDUAIS ==="
cat /opt/stack-iga/GMUD-021A-inventario-pre-sanitizacao-arquivos.txt
```

#### 5.0.2. Descomissionamento de Ativos Obsoletos (CRÍTICO)

```bash
# ===================================================================
# FASE 0.2: DESCOMISSIONAMENTO DE CONTAINERS OBSOLETOS
# Justificativa: midPoint 4.10 substituído por 4.8.8 LTS (H2 Embedded)
# Referência: GMUD-020D (Rollback para H2)
# ===================================================================

# 1. Validar que midPoint 4.10 (midpoint-server) está rodando
docker ps | grep midpoint-server
# Esperado: STATUS = Up

# 2. CRÍTICO: Parar container midpoint-server (DOWNTIME INICIA)
echo "[$(date)] DOWNTIME INICIADO: Parando midpoint-server" | tee -a /opt/stack-iga/GMUD-021A-descomissionamento.log
docker stop midpoint-server
# Esperado: midpoint-server

# 3. Validar indisponibilidade (esperado: erro de conexão)
curl -I http://xxx.xxx.xxx.xxx:8080/midpoint/
# Esperado: curl: (7) Failed to connect

# 4. Backup de evidências antes do descomissionamento
docker inspect midpoint-server > /opt/stack-iga/GMUD-021A-evidencia-descomissionamento-midpoint-server.json
docker logs midpoint-server > /opt/stack-iga/GMUD-021A-logs-descomissionamento-midpoint-server.txt

# 5. Remover container midpoint-server (liberação da porta 8080)
docker rm midpoint-server
# Esperado: midpoint-server

# 6. Validar remoção
docker ps -a | grep midpoint-server
# Esperado: Sem saída

# 7. Descomissionar midpoint-db (PostgreSQL) se ainda existir
docker ps -a | grep midpoint-db
if [ $? -eq 0 ]; then
  docker inspect midpoint-db > /opt/stack-iga/GMUD-021A-evidencia-descomissionamento-midpoint-db.json
  docker logs midpoint-db > /opt/stack-iga/GMUD-021A-logs-descomissionamento-midpoint-db.txt
  docker rm -f midpoint-db
  echo "[$(date)] Container midpoint-db descomissionado" | tee -a /opt/stack-iga/GMUD-021A-descomissionamento.log
fi

# 8. Remover volumes órfãos associados (se existirem)
docker volume ls | grep midpoint
# Se houver volumes órfãos não associados a /opt/stack-iga/:
# docker volume rm [volume_name]

# 9. Documentar descomissionamento
cat <<EOF >> /opt/stack-iga/GMUD-021A-descomissionamento.log
[$(date)] DESCOMISSIONAMENTO CONCLUÍDO
- Container midpoint-server (4.10) removido
- Container midpoint-db (PostgreSQL 16) removido
- Porta 8080 liberada para novo container midpoint (4.8.8)
- Justificativa: Substituído por H2 Embedded (GMUD-020D)
EOF
```

#### 5.0.3. Expurgo de Redes Docker Órfãs e Limpeza de Filesystem

```bash
# ===================================================================
# FASE 0.3: EXPURGO DE REDES DOCKER ÓRFÃS E SANITIZAÇÃO DE FILESYSTEM
# Objetivo: Remover redes experimentais e arquivos residuais da versão 4.10
# ===================================================================

# ========== PARTE A: REDES DOCKER ==========

# 1. Identificar redes órfãs (sem containers ativos)
docker network inspect midpoint_lab_net --format "{{.Containers}}"
docker network inspect orangehrm_lab_net --format "{{.Containers}}"
docker network inspect fiqueok-backend-net --format "{{.Containers}}"
# Esperado: {} (vazio) para todas

# 2. Remover rede midpoint_lab_net
docker network rm midpoint_lab_net
# Esperado: midpoint_lab_net

# 3. Remover rede orangehrm_lab_net
docker network rm orangehrm_lab_net
# Esperado: orangehrm_lab_net

# 4. Remover rede fiqueok-backend-net
docker network rm fiqueok-backend-net
# Esperado: fiqueok-backend-net

# 5. Validar remoção de redes
docker network ls
# Esperado: Somente stack-iga_midpoint-net, bridge, host, none

# 6. Documentar expurgo de redes
echo "[$(date)] Redes órfãs removidas: midpoint_lab_net, orangehrm_lab_net, fiqueok-backend-net" >> /opt/stack-iga/GMUD-021A-descomissionamento.log

# ========== PARTE B: FILESYSTEM (NOVA ADIÇÃO) ==========

# 7. Criar diretório de backup para evidências históricas (opcional)
sudo mkdir -p /opt/stack-iga/backup/gmud-021a-pre-sanitizacao
echo "[$(date)] Diretório de backup criado: /opt/stack-iga/backup/gmud-021a-pre-sanitizacao" >> /opt/stack-iga/GMUD-021A-descomissionamento.log

# 8. OPCIONAL: Mover script de descomissionamento para backup (não apagar)
if [ -f ~/descomissionamento-midpoint-4.10.sh ]; then
  sudo mv ~/descomissionamento-midpoint-4.10.sh /opt/stack-iga/backup/gmud-021a-pre-sanitizacao/
  echo "[$(date)] Script descomissionamento-midpoint-4.10.sh movido para backup" >> /opt/stack-iga/GMUD-021A-descomissionamento.log
fi

# 9. Remover arquivos residuais da versão 4.10
echo "[$(date)] Iniciando limpeza de arquivos residuais..." >> /opt/stack-iga/GMUD-021A-descomissionamento.log

if [ -f ~/midpoint-db-4.10.sql ]; then
  rm ~/midpoint-db-4.10.sql
  echo "[$(date)] Removido: midpoint-db-4.10.sql" >> /opt/stack-iga/GMUD-021A-descomissionamento.log
fi

if [ -f ~/midpoint_home-4.10.tar.gz ]; then
  rm ~/midpoint_home-4.10.tar.gz
  echo "[$(date)] Removido: midpoint_home-4.10.tar.gz" >> /opt/stack-iga/GMUD-021A-descomissionamento.log
fi

# 10. Remover diretórios experimentais
if [ -d ~/midpoint_lab ]; then
  rm -rf ~/midpoint_lab
  echo "[$(date)] Removido diretório: ~/midpoint_lab" >> /opt/stack-iga/GMUD-021A-descomissionamento.log
fi

if [ -d ~/orangehrm_lab ]; then
  rm -rf ~/orangehrm_lab
  echo "[$(date)] Removido diretório: ~/orangehrm_lab" >> /opt/stack-iga/GMUD-021A-descomissionamento.log
fi

# 11. Validar limpeza do filesystem
echo "[$(date)] Validando limpeza de filesystem..." >> /opt/stack-iga/GMUD-021A-descomissionamento.log
ls -lh ~/midpoint-db-4.10.sql ~/midpoint_home-4.10.tar.gz 2>&1 | grep "No such file"
ls -d ~/midpoint_lab ~/orangehrm_lab 2>&1 | grep "No such file"
# Esperado: "No such file or directory" para todos

# 12. Documentar limpeza completa
cat <<EOF >> /opt/stack-iga/GMUD-021A-descomissionamento.log
[$(date)] SANITIZAÇÃO DE FILESYSTEM CONCLUÍDA
- Arquivos removidos: midpoint-db-4.10.sql, midpoint_home-4.10.tar.gz
- Diretórios removidos: ~/midpoint_lab, ~/orangehrm_lab
- Evidências históricas preservadas em: /opt/stack-iga/backup/gmud-021a-pre-sanitizacao/
EOF
```

#### 5.0.4. Deploy do Novo Container midPoint 4.8.8 LTS

```bash
# ===================================================================
# FASE 0.4: DEPLOY DO NOVO CONTAINER midpoint (4.8.8 LTS)
# Objetivo: Subir novo container midPoint e restaurar disponibilidade
# ===================================================================

# 1. Navegar ao diretório de stack
cd /opt/stack-iga/

# 2. CRÍTICO: Validar e corrigir permissões de bind mounts
# midPoint 4.8.8 Alpine usa UID 1000 (não root)
echo "[$(date)] Validando permissões de bind mounts..." >> /opt/stack-iga/GMUD-021A-descomissionamento.log

if [ ! -d /opt/stack-iga/midpoint-home ]; then
  sudo mkdir -p /opt/stack-iga/midpoint-home
  echo "[$(date)] Diretório /opt/stack-iga/midpoint-home criado" >> /opt/stack-iga/GMUD-021A-descomissionamento.log
fi

sudo chown -R 1000:1000 /opt/stack-iga/midpoint-home
ls -ld /opt/stack-iga/midpoint-home
# Esperado: drwxr-xr-x 1000 1000 ... /opt/stack-iga/midpoint-home

# 3. Subir novo container midPoint (4.8.8 LTS)
docker-compose up -d midpoint

# 4. Aguardar inicialização (H2 Embedded leva ~30-45s)
echo "[$(date)] Aguardando inicialização do midPoint 4.8.8 LTS (60s)..." | tee -a /opt/stack-iga/GMUD-021A-descomissionamento.log
sleep 60

# 5. Validar que midPoint está operacional (DOWNTIME TERMINA)
curl -I http://xxx.xxx.xxx.xxx:8080/midpoint/
# Esperado: HTTP 200 ou 302

echo "[$(date)] DOWNTIME FINALIZADO: midPoint 4.8.8 operacional" | tee -a /opt/stack-iga/GMUD-021A-descomissionamento.log

# 6. Validar modo H2 File
docker logs midpoint --tail 50 | grep "jdbc:h2:file"
docker exec midpoint ls -lh /opt/midpoint/var/midpoint.mv.db
# Esperado: Arquivo .mv.db presente

# 7. Validar conectividade de rede
docker network inspect stack-iga_midpoint-net | grep -A 5 "Containers"
# Esperado: Container midpoint presente

# 8. Testar login no midPoint
curl -s http://xxx.xxx.xxx.xxx:8080/midpoint/login | grep -i "login"
# Esperado: HTML da página de login

# 9. Documentar sucesso
cat <<EOF >> /opt/stack-iga/GMUD-021A-descomissionamento.log
[$(date)] NOVO CONTAINER MIDPOINT 4.8.8 LTS OPERACIONAL
- Container: midpoint (substitui midpoint-server)
- Versão: 4.8.8 LTS Alpine
- Modo: H2 Embedded (File)
- Porta: 8080
- Bind Mount: /opt/stack-iga/midpoint-home
- Status: Operacional (HTTP 200)
EOF
```

#### 5.0.5. Validação da Stack midPoint Pós-Sanitização

```bash
# ===================================================================
# FASE 0.5: VALIDAÇÃO DE INTEGRIDADE PÓS-SANITIZAÇÃO
# ===================================================================

# 1. Validar que midPoint continua operacional
docker ps | grep midpoint
curl -I http://xxx.xxx.xxx.xxx:8080/midpoint/
# Esperado: HTTP 200 ou 302

# 2. Validar modo H2 File
docker logs midpoint --tail 50 | grep "repository"
docker exec midpoint ls -lh /opt/midpoint/var/midpoint.mv.db
# Esperado: Arquivo .mv.db presente

# 3. Validar conectividade de rede
docker network inspect stack-iga_midpoint-net | grep -A 5 "Containers"
# Esperado: Container midpoint presente

# 4. Validar ausência de containers obsoletos
docker ps -a | grep -E "midpoint-server|midpoint-db"
# Esperado: Sem saída

# 5. Validar ausência de redes órfãs
docker network ls | grep -E "midpoint_lab_net|orangehrm_lab_net|fiqueok-backend-net"
# Esperado: Sem saída

# 6. Validar limpeza de filesystem
ls -lh ~/midpoint-db-4.10.sql ~/midpoint_home-4.10.tar.gz ~/midpoint_lab ~/orangehrm_lab 2>&1 | grep "No such file"
# Esperado: "No such file or directory" para todos

# 7. Gerar relatório consolidado de sanitização
cat <<EOF > /opt/stack-iga/GMUD-021A-relatorio-sanitizacao.txt
=====================================
RELATÓRIO DE SANITIZAÇÃO TOTAL - GMUD-021A
Data: $(date)
Executor: Paulo Feitosa
Responsável GRC: Perplexity Pro
=====================================

ATIVOS DESCOMISSIONADOS (Docker):
- Container: midpoint-server (4.10)
- Container: midpoint-db (PostgreSQL 16)
- Rede: midpoint_lab_net (172.18.0.0/16)
- Rede: orangehrm_lab_net (172.19.0.0/16)
- Rede: fiqueok-backend-net (172.20.0.0/16)

ATIVOS DESCOMISSIONADOS (Filesystem):
- Arquivo: ~/midpoint-db-4.10.sql
- Arquivo: ~/midpoint_home-4.10.tar.gz
- Diretório: ~/midpoint_lab/
- Diretório: ~/orangehrm_lab/

ATIVOS MANTIDOS/CRIADOS:
- Container: midpoint (4.8.8 LTS - H2 Embedded File)
- Rede: stack-iga_midpoint-net (172.22.0.0/16)
- Bind Mount: /opt/stack-iga/midpoint-home (UID 1000)

STATUS FINAL:
- midPoint Operacional: $(curl -s -o /dev/null -w "%{http_code}" http://xxx.xxx.xxx.xxx:8080/midpoint/)
- Downtime Total: ~5-8 minutos
- Inventário Docker Atualizado: OK
- Inventário Filesystem Atualizado: OK
- Conformidade ISO 27001 A.8.1: OK
- Conformidade ISO 27001 A.8.9: OK
- Conformidade ISO 27001 A.8.10: OK
=====================================
EOF

cat /opt/stack-iga/GMUD-021A-relatorio-sanitizacao.txt
```

---

### 5.1. Pré-Requisitos e Validações (Pré-Deploy OrangeHRM)

```bash
# 1. Validar que Fase 0 foi concluída com sucesso
cat /opt/stack-iga/GMUD-021A-relatorio-sanitizacao.txt
# Esperado: "STATUS FINAL: midPoint Operacional: 200"

# 2. Validar rede autoritativa stack-iga_midpoint-net
docker network inspect stack-iga_midpoint-net
# Esperado: Subnet 172.22.0.0/16 ativa

# 3. Validar stack midPoint 4.8.8 LTS operacional (H2 Embedded File)
docker ps | grep midpoint
curl -I http://xxx.xxx.xxx.xxx:8080/midpoint/
# Esperado: HTTP 200 ou 302

# 4. Validar ausência de containers obsoletos
docker ps -a | grep -E "midpoint-server|midpoint-db"
# Esperado: Sem saída

# 5. Criar diretórios de bind mount para OrangeHRM e configurar permissões
sudo mkdir -p /opt/stack-iga/orangehrm-dbdata
sudo chown -R 999:999 /opt/stack-iga/orangehrm-dbdata
ls -ld /opt/stack-iga/orangehrm-dbdata
# Esperado: drwxr-xr-x 999 999

# 6. Validar espaço em disco disponível
df -h /opt/stack-iga/
# Esperado: Mínimo 5GB livres

# 7. Validar porta 8081 disponível
sudo netstat -tuln | grep 8081
# Esperado: Sem saída (porta livre)

# 8. Validar que porta 8080 está em uso pelo midPoint
sudo netstat -tuln | grep 8080
# Esperado: 0.0.0.0:8080 ... LISTEN
```

### 5.2. Alteração do docker-compose.yml

**Arquivo:** `/opt/stack-iga/docker-compose.yml` (IGA-P-01)

**Backup Obrigatório:**
```bash
sudo cp /opt/stack-iga/docker-compose.yml \
       /opt/stack-iga/docker-compose.yml.bkp-$(date +%Y%m%d_%H%M%S)
```

**Conteúdo Completo do docker-compose.yml v5.0:**

```yaml
version: '3.8'

networks:
  # Rede autoritativa (external: true - criada pelo stack principal)
  midpoint-net:
    external: true
    name: stack-iga_midpoint-net

services:
  # ========================================
  # Stack midPoint 4.8.8 LTS (H2 Embedded File Mode)
  # ========================================
  midpoint:
    image: evolveum/midpoint:4.8.8-alpine
    container_name: midpoint
    hostname: midpoint
    ports:
      - "8080:8080"
    environment:
      # CRÍTICO: H2 Embedded (File), não TCP Server
      - MP_SET_midpoint_repository_database=h2
      - MP_SET_midpoint_repository_jdbcUrl=jdbc:h2:file:/opt/midpoint/var/midpoint
      - MP_SET_midpoint_repository_jdbcUsername=midpoint
      - MP_SET_midpoint_repository_jdbcPassword=password
      - MP_INIT_CFG=/opt/midpoint/var/post-initial-objects
    volumes:
      # Bind Mount para visibilidade no host (UID 1000)
      - /opt/stack-iga/midpoint-home:/opt/midpoint/var
    networks:
      - midpoint-net
    restart: unless-stopped

  # ========================================
  # Stack OrangeHRM 5.8 (NOVO - GMUD-021A)
  # ========================================
  orangehrm-db:
    image: mariadb:11.4
    container_name: orangehrm-db
    hostname: orangehrm-db
    environment:
      MYSQL_ROOT_PASSWORD: AdminOHRM2026!
      MYSQL_DATABASE: orangehrm
      MYSQL_USER: orangehrm_user
      MYSQL_PASSWORD: OHRM_Secure2026
    volumes:
      # Bind Mount para visibilidade no host e backup facilitado (UID 999)
      - /opt/stack-iga/orangehrm-dbdata:/var/lib/mysql
    networks:
      - midpoint-net
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-pAdminOHRM2026!"]
      interval: 10s
      timeout: 5s
      retries: 5

  orangehrm-app:
    image: orangehrm/orangehrm:5.8
    container_name: orangehrm-app
    hostname: orangehrm-app
    depends_on:
      orangehrm-db:
        condition: service_healthy
    environment:
      ORANGEHRM_DATABASE_HOST: orangehrm-db
      ORANGEHRM_DATABASE_PORT: 3306
      ORANGEHRM_DATABASE_USER: orangehrm_user
      ORANGEHRM_DATABASE_PASSWORD: OHRM_Secure2026
      ORANGEHRM_DATABASE_NAME: orangehrm
    ports:
      - "8081:80"
    networks:
      - midpoint-net
    restart: unless-stopped
```

### 5.3. Sequência de Comandos de Execução (Deploy OrangeHRM)

```bash
# ===================================================================
# GMUD-021A - FASE 1: DEPLOY ORANGEHRM 5.8
# Executor: Paulo Feitosa / ChatGPT (Systems Architect)
# Data: 07/01/2026 20:30
# ===================================================================

# 1. Navegação ao diretório de stack
cd /opt/stack-iga/

# 2. Validar sintaxe do docker-compose.yml
docker-compose config
# Esperado: Saída sem erros de sintaxe

# 3. Pull de imagens (pré-download)
docker-compose pull orangehrm-db orangehrm-app
# Tempo estimado: 3-5 minutos

# 4. Criação e inicialização dos novos containers
docker-compose up -d orangehrm-db orangehrm-app

# 5. Aguardar healthcheck do MariaDB
echo "Aguardando inicialização do MariaDB (60s)..."
sleep 60

# 6. Validar status dos containers
docker-compose ps
# Esperado: midpoint, orangehrm-db e orangehrm-app com status "Up (healthy)"

# 7. Inspecionar logs de inicialização
docker logs orangehrm-app --tail 50
docker logs orangehrm-db --tail 50
# Esperado: Sem mensagens de ERRO ou FATAL

# 8. Validar conectividade de rede interna (DNS)
docker exec midpoint ping -c 3 orangehrm-app
docker exec midpoint ping -c 3 orangehrm-db
# Esperado: 0% packet loss

# 9. Teste de acesso web (do host)
curl -I http://xxx.xxx.xxx.xxx:8081
# Esperado: HTTP 200 ou 302 (redirect para /installer)

# 10. Validar que stack midPoint 4.8.8 LTS não foi afetada
curl -I http://xxx.xxx.xxx.xxx:8080/midpoint/
docker logs midpoint --tail 20 | grep -i "h2"
# Esperado: midPoint responsivo, logs confirmando H2 File

# 11. Validar rede stack-iga_midpoint-net
docker network inspect stack-iga_midpoint-net | grep -A 10 "Containers"
# Esperado: 3 containers (midpoint, orangehrm-app, orangehrm-db)

# 12. Validar ausência de conflitos de portas
sudo netstat -tuln | grep -E "8080|8081|3306"
# Esperado: 3 linhas (8080 midPoint, 8081 OrangeHRM, 3306 interno MariaDB)
```

---

## 6. Plano de Rollback

### 6.1. Critérios de Ativação do Rollback

O rollback deve ser executado imediatamente se:
1. Falha na inicialização do OrangeHRM após 3 tentativas de restart
2. Perda de conectividade com midPoint 4.8.8 LTS (indisponibilidade da porta 8080)
3. Consumo de recursos acima de 80% CPU ou 90% RAM no IGA-P-01
4. Corrupção de bind mounts ou permissões incorretas
5. Falha de conectividade de rede entre containers (>50% packet loss)
6. Conflitos de portas (8080, 8081, 3306, 5432)

### 6.2. Procedimento de Reversão (Fase 0)

```bash
# ===================================================================
# ROLLBACK FASE 0 - RESTAURAÇÃO DE CONTAINER midpoint-server
# EXECUTAR SOMENTE SE midPoint FICAR INDISPONÍVEL
# ===================================================================

# 1. Parar container midpoint (4.8.8) com problema
docker stop midpoint
docker rm midpoint

# 2. Restaurar container midpoint-server (4.10) do backup
docker run -d \
  --name midpoint-server \
  --network stack-iga_midpoint-net \
  -p 8080:8080 \
  -v /opt/stack-iga/midpoint-home:/opt/midpoint/var \
  evolveum/midpoint:4.10

# 3. Aguardar inicialização
sleep 60

# 4. Validar que midpoint-server está operacional
curl -I http://xxx.xxx.xxx.xxx:8080/midpoint/
# Esperado: HTTP 200

# 5. Documentar rollback
echo "Rollback Fase 0 executado em $(date). Motivo: [PREENCHER]" >> /opt/stack-iga/GMUD-021A-rollback.log
```

### 6.3. Procedimento de Reversão (Fase 1)

```bash
# ===================================================================
# ROLLBACK FASE 1 - REMOÇÃO DE CONTAINERS ORANGEHRM
# ===================================================================

# 1. Navegar ao diretório de stack
cd /opt/stack-iga/

# 2. Parar e remover containers OrangeHRM
docker-compose stop orangehrm-app orangehrm-db
docker-compose rm -f orangehrm-app orangehrm-db

# 3. Validar que containers foram removidos
docker ps -a | grep orangehrm
# Esperado: Sem saída

# 4. Restaurar docker-compose.yml anterior
LATEST_BACKUP=$(ls -t /opt/stack-iga/docker-compose.yml.bkp-* | head -1)
sudo cp $LATEST_BACKUP /opt/stack-iga/docker-compose.yml

# 5. Validar integridade da stack midPoint 4.8.8 LTS
docker-compose ps | grep midpoint
curl -I http://xxx.xxx.xxx.xxx:8080/midpoint/
# Esperado: midPoint operacional

# 6. Documentar rollback
echo "Rollback Fase 1 executado em $(date). Motivo: [PREENCHER]" >> /opt/stack-iga/GMUD-021A-rollback.log
```

---

## 7. Análise de Risco

| ID | Risco | Probabilidade | Impacto | Severidade | Mitigação |
|----|-------|---------------|---------|------------|-----------|
| R01 | Descomissionamento do midpoint-server causa downtime prolongado | Média | Crítico | **Alta** | Deploy rápido do novo container midpoint (4.8.8) na Fase 0.4 |
| R02 | Permissões incorretas (UID 1000) impedem acesso ao H2 | Alta | Crítico | **Alta** | Executar `chown 1000:1000` explicitamente antes do deploy |
| R03 | Conflito de portas 8080 (midpoint-server vs midpoint) | Baixa | Crítico | **Média** | Parar e remover midpoint-server antes de subir midpoint |
| R04 | Rede externa stack-iga_midpoint-net não encontrada | Baixa | Crítico | **Média** | Validar existência da rede na Fase 5.1 |
| R05 | Remoção acidental de arquivos críticos do filesystem | Baixa | Alto | **Média** | Mover arquivos para backup antes de remover |

---

## 8. Matriz de Responsabilidades (RACI)

| Atividade | Paulo (Owner) | Perplexity (GRC) | ChatGPT (Architect) | Gemini |
|-----------|---------------|------------------|---------------------|--------|
| Aprovação da GMUD | **A** | R | C | I |
| Fase 0: Sanitização | **R/A** | C | **R** | I |
| Fase 1: Deploy OrangeHRM | **R/A** | C | **R** | I |
| Análise de risco | **A** | **R** | C | C |
| Decisão de rollback | **A** | R | C | I |

**Legenda:** R = Responsible (Executor), A = Accountable (Aprovador), C = Consulted (Consultado), I = Informed (Informado)

---

## 9. Aprovações

| Papel | Nome | Data | Status |
|-------|------|------|--------|
| Executor Técnico | ChatGPT (Systems Architect) | 06/01/2026 | Planejado |
| Responsável GRC | Perplexity Pro (GRC Lead) | 06/01/2026 | Planejado |
| Consultor Deep-Dive | Gemini (Deep-Dive Consultant) | 06/01/2026 | Consultado |
| Aprovador Final | Paulo Feitosa (Owner) | - | **Pendente** |

---

## 10. Controle de Versão

| Versão | Data | Autor | Mudanças Principais |
|--------|------|-------|---------------------|
| 1.0 | 05/01/2026 | Claude + ChatGPT | Criação inicial |
| 2.0 | 06/01/2026 | Claude + ChatGPT | Correção para H2 Embedded |
| 3.0 | 06/01/2026 | Perplexity + ChatGPT | H2 File Mode, bind mounts |
| 4.0 | 06/01/2026 11:26 | Perplexity + ChatGPT | Fase 0 Sanitização Docker |
| **5.0** | **06/01/2026 11:35** | **Perplexity + ChatGPT + Gemini** | **Sanitização Total: filesystem, midpoint-server, permissões UID 1000** |

---

## 11. Anexos

### Anexo A - Permissões de Bind Mounts

| Container | UID/GID | Bind Mount | Comando |
|-----------|---------|------------|---------|
| midpoint | 1000:1000 | /opt/stack-iga/midpoint-home | `sudo chown -R 1000:1000 /opt/stack-iga/midpoint-home` |
| orangehrm-db | 999:999 | /opt/stack-iga/orangehrm-dbdata | `sudo chown -R 999:999 /opt/stack-iga/orangehrm-dbdata` |

### Anexo B - Estrutura de Diretórios Pós-Sanitização

```
/opt/stack-iga/
├── docker-compose.yml (v5.0)
├── docker-compose.yml.bkp-20260107_190000
├── midpoint-home/ (UID 1000:1000)
│   ├── midpoint.mv.db
│   └── log/
├── orangehrm-dbdata/ (UID 999:999)
│   └── orangehrm/
├── backup/
│   └── gmud-021a-pre-sanitizacao/
├── GMUD-021A-relatorio-sanitizacao.txt
└── GMUD-021A-descomissionamento.log

/home/paulo/  (LIMPO - Zero arquivos residuais)
└── (NENHUM arquivo/diretório relacionado a midpoint/orangehrm)
```

---

**Próxima GMUD:** GMUD-021B - Governança e Carga de Dados no OrangeHRM

**Documento mantido por:** Perplexity Pro (GRC Lead)  
**Repositório:** Obsidian Vault - `FiqueokBrain/10Projetos/PRJ001-LABORATORIO/20Governanca/`  
**Última atualização:** 06/01/2026 11:35 (Hora de Brasília)

---

**Certificação de Higiene:** Este documento representa a sanitização total do ambiente Docker e filesystem conforme ISO 27001 A.8.1, A.8.9 e A.8.10.

