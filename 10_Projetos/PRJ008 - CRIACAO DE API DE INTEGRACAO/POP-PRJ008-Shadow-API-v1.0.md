# POP — Procedimento Operacional Padrão
## PRJ008 · Shadow API REST · OrangeHRM × midPoint IGA
### Living Lab Fiqueok — Programa Greenfield

---

| Campo | Valor |
|---|---|
| **Documento** | POP-PRJ008-v1.0 |
| **Versão** | 1.0 |
| **Data** | 14/04/2026 |
| **Autor** | Paulo Feitosa Lima |
| **Escopo** | Sprints 1 a 5 — Shadow API completa e funcional |
| **Objetivo** | Replicação completa do ambiente em nova infraestrutura (Cloud ou Home Lab) |
| **Tempo estimado total** | 4–6 horas (ambiente novo) |

---

## VISÃO GERAL DA ARQUITETURA

```
TAILSCALE MESH VPN
├── vault-gf-01     (HashiCorp Vault — segredos)
├── rh-gf-01        (OrangeHRM + MariaDB — fonte de dados)
└── api-gf-01       (Shadow API FastAPI — este POP)
```

**Fluxo de dados:**
```
midPoint IGA → GET /employees (X-API-KEY) → api-gf-01:8000
                                               ↓
                                    Vault (secret/orangehrm/db_api)
                                               ↓
                                    MariaDB rh-gf-01:3306
                                    (svc_shadow_api SELECT-only)
```

---

## PRÉ-REQUISITOS

### Infraestrutura existente (já deve estar operacional)

| Serviço | VM/Host | Porta | Observação |
|---------|---------|-------|------------|
| HashiCorp Vault | `vault-gf-01` | 8200 | Unsealed e autenticado |
| OrangeHRM + MariaDB | `rh-gf-01` | 8085 / 3306 | Docker Compose em `~/prj005-orange-greenfield` |
| Tailscale | Todos os nós | — | Mesh VPN ativa |

### Softwares necessários na máquina de trabalho
- SSH client
- PowerShell 7+ (Windows) ou terminal (Linux/Mac)
- Tailscale instalado e autenticado
- Acesso root/sudo à VM `vault-gf-01`

---

## FASE 0 — PROVISIONAMENTO DA VM api-gf-01

### 0.1 Criação da VM (Hyper-V)

```powershell
# PowerShell — Host Windows (Administrador)

# 1. Criar a VM via disco diferencial do Golden Disk
New-Item -Path "C:\Hyper-V\VMs\api-gf-01" -ItemType Directory -Force

New-VHD -ParentPath "C:\Hyper-V\GoldenDisks\Ubuntu2404-GF\Ubuntu2404-GF-GEN2-Greenfield.vhdx" `
        -Path "C:\Hyper-V\VMs\api-gf-01\api-gf-01.vhdx" `
        -Differencing

New-VM -Name "api-gf-01" `
       -Generation 2 `
       -MemoryStartupBytes 2GB `
       -VHDPath "C:\Hyper-V\VMs\api-gf-01\api-gf-01.vhdx" `
       -SwitchName "vSwitch_External_PRJ003"

Set-VMProcessor -VMName "api-gf-01" -Count 2

# 2. Iniciar VM
Start-VM -Name "api-gf-01"
```

> **Nota Cloud:** Em Cloud (Azure, AWS, OCI), provisionar uma VM Ubuntu 24.04 LTS com mínimo 2 vCPU / 2GB RAM / 20GB SSD. Habilitar porta 8000 no Security Group **apenas para o IP do midPoint** (princípio de menor privilégio).

### 0.2 Snapshot pré-configuração

```powershell
# SEMPRE criar snapshot antes de iniciar configurações
Stop-VM -Name "api-gf-01" -Force
Checkpoint-VM -Name "api-gf-01" -SnapshotName "PRJ008-PreConfig-$(Get-Date -Format 'yyyyMMdd-HHmm')"
Start-VM -Name "api-gf-01"
```

### 0.3 Verificação inicial da VM

```bash
# SSH para a VM
ssh paulo@<IP_DA_VM>

# Verificar sistema
hostnamectl
# Esperado: Ubuntu 24.04 LTS

# Verificar conectividade de rede
ping -c 3 8.8.8.8
```

---

## FASE 1 — CONFIGURAÇÃO DE REDE E TAILSCALE (Sprint 1)

### 1.1 Instalar Tailscale

```bash
# Instalar Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Autenticar com chave efêmera (gerar no painel Tailscale antes)
# https://login.tailscale.com/admin/settings/keys
# Configuração: Ephemeral=Yes, Reusable=No, Expiry=90days
sudo tailscale up --authkey=tskey-auth-XXXXX --hostname=api-gf-01

# Verificar IP atribuído
tailscale ip -4
# ANOTAR o IP: 100.x.x.x (será usado em todo o POP)

# Verificar conectividade com outros nós
tailscale status
ping -c 3 <IP_VAULT_GF_01>     # ex: xxx.xxx.xxx.xxx
ping -c 3 <IP_RH_GF_01>        # ex: xxx.xxx.xxx.xxx
```

**Critério de aceite:** `tailscale status` mostra `api-gf-01` como `active`.

### 1.2 Testar conectividade com MariaDB

```bash
# Testar porta 3306 (MariaDB no rh-gf-01)
nc -zv <IP_RH_GF_01> 3306
# Esperado: Connection to <IP> 3306 port [tcp/mysql] succeeded!
```

---

## FASE 2 — CONFIGURAÇÃO DO VAULT (Sprint 1)

### 2.1 Unseal do Vault (se necessário)

```bash
# SSH para vault-gf-01
ssh paulo@<IP_VAULT_GF_01>

export VAULT_ADDR='http://127.0.0.1:8200'

# Verificar status
vault status

# Se Sealed: true — executar 3x com chaves diferentes
vault operator unseal   # Chave 1/3
vault operator unseal   # Chave 2/3
vault operator unseal   # Chave 3/3

# Verificar: Sealed: false, HA Mode: active
vault status
```

### 2.2 Criar Política de Acesso da API

```bash
# Na vault-gf-01, criar arquivo de política
cat <<EOF > api-proxy-policy.hcl
path "secret/data/orangehrm/*" { capabilities = ["read"] }
path "secret/data/api-proxy/*" { capabilities = ["read"] }
EOF

# Autenticar com root token
vault login

# Aplicar política
vault policy write api-proxy-policy api-proxy-policy.hcl

# Verificar
vault policy read api-proxy-policy
```

### 2.3 Criar Token de Serviço (VLT-04)

```bash
# Gerar token de serviço com TTL 24h
vault token create \
  -policy=api-proxy-policy \
  -period=24h \
  -format=json | jq -r .auth.client_token

# ANOTAR O TOKEN GERADO: hvs.XXXXXXXXXXXX
# Este token será injetado na api-gf-01
```

### 2.4 Provisionar Segredos do Banco

```bash
# Provisionar credenciais do banco de dados
vault kv put secret/orangehrm/db_api \
    username="svc_shadow_api" \
    password="<SENHA_DO_SVC>" \
    db_name="orangehrm" \
    db_host="<IP_RH_GF_01>"

# Verificar
vault kv get secret/orangehrm/db_api
# Deve mostrar os campos: username, password, db_name, db_host

# Provisionar credenciais admin do OrangeHRM (referência)
vault kv put secret/orangehrm/admin \
    password="<SENHA_ADMIN>" \
    username="paulo" \
    url="http://<IP_RH_GF_01>:8085"
```

### 2.5 Injetar Token na api-gf-01

```bash
# SSH para api-gf-01
ssh paulo@<IP_API_GF_01>

# Criar diretório seguro
sudo mkdir -p /var/lib/shadow-api

# Injetar token
echo "<TOKEN_GERADO_NO_2.3>" | sudo tee /var/lib/shadow-api/vault_token > /dev/null

# Aplicar permissões corretas
sudo chmod 600 /var/lib/shadow-api/vault_token
sudo chown paulo:paulo /var/lib/shadow-api/vault_token

# Verificar
sudo cat /var/lib/shadow-api/vault_token
# Deve mostrar o token hvs.XXXX

ls -la /var/lib/shadow-api/vault_token
# Deve mostrar: -rw------- 1 paulo paulo
```

**⚠️ ALERTA DE SEGURANÇA:** Nunca usar o token root da VM vault-gf-01 na api-gf-01. O token de serviço tem permissão mínima (read em `secret/orangehrm/*` apenas).

---

## FASE 3 — BANCO DE DADOS (Sprint 1)

### 3.1 Criar Usuário de Serviço no MariaDB

```bash
# SSH para rh-gf-01
ssh paulo@<IP_RH_GF_01>

# Conectar ao MariaDB via Docker
sudo docker exec -it orange-db mariadb -u root -p
# Senha: conforme ambiente

# No prompt MariaDB:
CREATE USER 'svc_shadow_api'@'%' IDENTIFIED BY '<SENHA_FORTE>';

GRANT SELECT ON orangehrm.ohrm_user TO 'svc_shadow_api'@'%';
GRANT SELECT ON orangehrm.hs_hr_employee TO 'svc_shadow_api'@'%';

FLUSH PRIVILEGES;

# Verificar
SHOW GRANTS FOR 'svc_shadow_api'@'%';

EXIT;
```

### 3.2 Validar Conectividade do Usuário de Serviço

```bash
# Da api-gf-01, testar conexão com o usuário de serviço
mysql -h <IP_RH_GF_01> -u svc_shadow_api -p orangehrm
# Senha: <SENHA_FORTE>

# No prompt MySQL:
SELECT COUNT(*) FROM hs_hr_employee;
# Deve retornar número > 0

EXIT;
```

---

## FASE 4 — AMBIENTE PYTHON (Sprint 1)

### 4.1 Instalar Dependências do Sistema

```bash
# Na api-gf-01
sudo apt update && sudo apt upgrade -y

# Instalar Python venv
sudo apt install -y python3-venv python3-pip

# Verificar versão Python
python3 --version
# Esperado: Python 3.12.x
```

### 4.2 Criar Estrutura do Projeto

```bash
# Criar diretório do projeto
mkdir -p ~/prj008-shadow-api/{app,tests,config,scripts}
cd ~/prj008-shadow-api

# Criar arquivos iniciais
touch app/__init__.py app/main.py app/database.py app/vault.py app/schemas.py

# Criar .gitignore
cat > .gitignore << 'EOF'
.env
*.key
vault_token
__pycache__/
*.pyc
venv/
.pytest_cache/
EOF
```

### 4.3 Criar e Ativar Ambiente Virtual

```bash
cd ~/prj008-shadow-api

# Criar venv
python3 -m venv venv

# Ativar
source venv/bin/activate

# Verificar
which python
# Deve mostrar: ~/prj008-shadow-api/venv/bin/python
```

### 4.4 Instalar Dependências Python

```bash
# Criar requirements.txt
cat > requirements.txt << 'EOF'
fastapi==0.115.0
uvicorn==0.30.6
hvac==2.3.0
python-dotenv==1.0.1
sqlalchemy==2.0.35
pymysql==1.1.1
EOF

# Instalar
pip install --upgrade pip
pip install -r requirements.txt

# Verificar instalação
pip list | grep -E "fastapi|uvicorn|hvac|sqlalchemy|pymysql"
```

---

## FASE 5 — DESENVOLVIMENTO DA SHADOW API (Sprints 2–5)

### 5.1 Módulo Vault (app/vault.py)

```python
# app/vault.py
import hvac
import logging

VAULT_URL = "http://<IP_VAULT_GF_01>:8200"
TOKEN_PATH = "/var/lib/shadow-api/vault_token"

logger = logging.getLogger("shadow-api-auditoria")

def get_db_credentials():
    """Recupera credenciais do MariaDB via Vault (VLT-04)."""
    try:
        with open(TOKEN_PATH, 'r') as f:
            token = f.read().strip()

        client = hvac.Client(url=VAULT_URL, token=token)

        if not client.is_authenticated():
            raise Exception("GRC: Token do Vault inválido ou expirado.")

        response = client.secrets.kv.v2.read_secret_version(
            path='orangehrm/db_api',
            mount_point='secret'
        )

        logger.info("Credenciais do DB recuperadas com sucesso do Vault.")
        return response['data']['data']

    except Exception as e:
        logger.error(f"Falha crítica ao acessar o cofre de senhas: {e}")
        raise e
```

> **Substituir** `<IP_VAULT_GF_01>` pelo IP Tailscale real do vault-gf-01.

### 5.2 Módulo Database (app/database.py)

```python
# app/database.py
import urllib.parse
import logging
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from app.vault import get_db_credentials

logger = logging.getLogger("shadow-api-auditoria")

# Inicialização lazy — evita crash se Vault estiver sealed no startup
_engine = None
_SessionLocal = None
Base = declarative_base()

def get_engine():
    global _engine
    if _engine is None:
        creds = get_db_credentials()

        # urllib.parse.quote_plus trata caracteres especiais na senha
        encoded_pass = urllib.parse.quote_plus(creds['password'])

        # charset=utf8mb4 garante suporte a acentuação (NN-02)
        url = (
            f"mysql+pymysql://{creds['username']}:{encoded_pass}@"
            f"{creds['db_host']}:3306/{creds['db_name']}?charset=utf8mb4"
        )

        _engine = create_engine(
            url,
            pool_pre_ping=True,
            connect_args={"charset": "utf8mb4"}
        )
        logger.info("Engine SQLAlchemy criado com sucesso.")
    return _engine

def get_session():
    global _SessionLocal
    if _SessionLocal is None:
        _SessionLocal = sessionmaker(
            autocommit=False,
            autoflush=False,
            bind=get_engine()
        )
    return _SessionLocal

def get_db():
    db = get_session()()
    try:
        yield db
    finally:
        db.close()
```

### 5.3 Schemas Pydantic (app/schemas.py)

```python
# app/schemas.py
import unicodedata
from typing import Optional
from pydantic import BaseModel, field_validator


def normalize_nfc(value: Optional[str]) -> Optional[str]:
    """Normalização UTF-8 NFC — evita corrupção de nomes acentuados (NN-02)."""
    if value is None or value == "":
        return None  # Empty string → None (NN-03)
    return unicodedata.normalize('NFC', value)


class EmployeeOut(BaseModel):
    emp_number: int
    employee_id: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    middle_name: Optional[str] = None
    employment_status: Optional[str] = None
    department: Optional[str] = None
    job_title: Optional[str] = None
    work_email: Optional[str] = None

    model_config = {"from_attributes": True}

    @field_validator('first_name', 'last_name', 'middle_name',
                     'employee_id', 'department', 'job_title',
                     'work_email', mode='before')
    @classmethod
    def normalize_strings(cls, v):
        return normalize_nfc(v)
```

### 5.4 Aplicação Principal (app/main.py)

```python
# app/main.py
import logging
import time
from fastapi import FastAPI, Security, HTTPException, Request
from fastapi.security.api_key import APIKeyHeader
from fastapi.responses import JSONResponse
from typing import List
from sqlalchemy import text
from app.database import get_db
from app.schemas import EmployeeOut
from app.vault import get_db_credentials

# ── Logging ISO 27001 A.8.15 ──────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s'
)
logger = logging.getLogger("shadow-api-auditoria")

# ── Aplicação ──────────────────────────────────────────────────────────────
app = FastAPI(
    title="Fiqueok Shadow API",
    description="Shadow API REST — OrangeHRM × midPoint IGA",
    version="1.0.0"
)

# ── Autenticação X-API-KEY ─────────────────────────────────────────────────
API_KEY_NAME = "X-API-KEY"
API_KEY_VALUE = "Fiqueok-Security-Token-2026"   # Em produção: ler do Vault
api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=False)

async def verify_api_key(api_key: str = Security(api_key_header)):
    if api_key != API_KEY_VALUE:
        raise HTTPException(status_code=403, detail="API Key inválida.")
    return api_key

# ── Middleware de Auditoria ────────────────────────────────────────────────
@app.middleware("http")
async def audit_middleware(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = round((time.time() - start) * 1000, 2)
    logger.info(
        f"[AUDIT] {request.method} {request.url.path} "
        f"IP={request.client.host} "
        f"STATUS={response.status_code} "
        f"DURATION={duration}ms"
    )
    return response

# ── Endpoints ──────────────────────────────────────────────────────────────
@app.get("/", tags=["Health"])
def read_root():
    return {"status": "Shadow API is operational", "target": "OrangeHRM"}


@app.get(
    "/employees",
    response_model=List[EmployeeOut],
    response_model_exclude_none=True,   # NN-03: campos nulos omitidos
    tags=["Identities"]
)
def list_employees(api_key: str = Security(verify_api_key)):
    """
    Retorna lista de colaboradores do OrangeHRM.
    Requer header: X-API-KEY
    """
    db_gen = get_db()
    db = next(db_gen)
    try:
        sql = text("""
            SELECT
                e.emp_number,
                e.employee_id,
                e.emp_firstname  AS first_name,
                e.emp_lastname   AS last_name,
                e.emp_middle_name AS middle_name,
                e.emp_work_email AS work_email
            FROM hs_hr_employee e
            ORDER BY e.emp_number
        """)
        rows = db.execute(sql).fetchall()
        logger.info(f"[AUDIT] /employees retornou {len(rows)} registros.")
        return [dict(row._mapping) for row in rows]
    except Exception as e:
        logger.error(f"[AUDIT] Erro em /employees: {e}")
        raise HTTPException(status_code=500, detail="Erro interno.")
    finally:
        db.close()
```

### 5.5 Validação do Vault (smoke test)

```bash
# Na api-gf-01, com venv ativo
cd ~/prj008-shadow-api
source venv/bin/activate

# Criar smoke test temporário
cat > smoke_test_vault.py << 'EOF'
from app.vault import get_db_credentials
creds = get_db_credentials()
print(f"✅ Vault OK — usuário: {creds['username']}")
EOF

python smoke_test_vault.py
# Esperado: ✅ Vault OK — usuário: svc_shadow_api

# Remover após validação
rm smoke_test_vault.py
```

### 5.6 Iniciar a API

```bash
cd ~/prj008-shadow-api
source venv/bin/activate

# Iniciar Uvicorn
uvicorn app.main:app --host 0.0.0.0 --port 8000 --log-level info

# Esperado nos logs:
# INFO: Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

---

## FASE 6 — VALIDAÇÃO COMPLETA (Sprint 4)

### 6.1 Testes via curl (da máquina local)

```bash
# Teste 1: Endpoint raiz (sem autenticação)
curl -s http://<IP_API_GF_01>:8000/
# Esperado: {"status":"Shadow API is operational","target":"OrangeHRM"}

# Teste 2: /employees sem API Key (deve retornar 403)
curl -s http://<IP_API_GF_01>:8000/employees
# Esperado: {"detail":"Not authenticated"}

# Teste 3: /employees com API Key (deve retornar 200 com dados)
curl -s \
  -H "X-API-KEY: Fiqueok-Security-Token-2026" \
  http://<IP_API_GF_01>:8000/employees | python3 -m json.tool | head -30
# Esperado: Array JSON com emp_number, employee_id, first_name, last_name

# Teste 4: Verificar encoding UTF-8 (acentuação)
curl -s \
  -H "X-API-KEY: Fiqueok-Security-Token-2026" \
  http://<IP_API_GF_01>:8000/employees | \
  python3 -c "import sys,json; data=json.load(sys.stdin); \
  [print(e['first_name']) for e in data if 'é' in e.get('first_name','') or 'ã' in e.get('first_name','')]"
# Esperado: nomes com acentos corretos (André, João, etc.)
```

### 6.2 Verificar Swagger UI

Abrir no browser: `http://<IP_API_GF_01>:8000/docs`

- Clicar em **Authorize** (cadeado)
- Inserir: `Fiqueok-Security-Token-2026`
- Executar `GET /employees` → deve retornar HTTP 200

### 6.3 Verificar Logs de Auditoria

```bash
# Os logs devem aparecer no terminal do Uvicorn:
# [AUDIT] GET /employees IP=<IP> STATUS=200 DURATION=XXms
```

---

## FASE 7 — HARDENING (Sprint 5)

### 7.1 Verificar Campos Nulos Omitidos (NN-03)

```bash
# Verificar que campos nulos não aparecem no JSON
curl -s \
  -H "X-API-KEY: Fiqueok-Security-Token-2026" \
  http://<IP_API_GF_01>:8000/employees | \
  python3 -c "
import sys, json
data = json.load(sys.stdin)
# Verificar: não deve haver 'null' nem string vazia
has_null = any(
    v is None or v == ''
    for emp in data
    for v in emp.values()
)
print('❌ FALHA: campos nulos encontrados' if has_null else '✅ OK: nenhum campo nulo')
"
```

### 7.2 Verificar UTF-8 NFC (NN-02)

```bash
# Verificar normalização NFC
curl -s \
  -H "X-API-KEY: Fiqueok-Security-Token-2026" \
  http://<IP_API_GF_01>:8000/employees | \
  python3 -c "
import sys, json, unicodedata
data = json.load(sys.stdin)
for emp in data[:5]:
    fn = emp.get('first_name', '')
    nfc = unicodedata.normalize('NFC', fn)
    status = '✅' if fn == nfc else '❌ NFC MISMATCH'
    print(f'{status} {fn}')
"
```

### 7.3 Remover Scripts de Teste

```bash
# IMPORTANTE: remover scripts de debug antes de considerar produção
cd ~/prj008-shadow-api
rm -f smoke_test_vault.py test_db_real.py test_*.py

# Verificar que não há secrets em texto plano
grep -r "password\|secret\|token" app/ --include="*.py" | \
  grep -v "vault_token\|get_db_credentials\|TOKEN_PATH\|X-API-KEY"
# Esperado: sem resultados com credenciais hardcoded
```

---

## FASE 8 — SERVIÇO SYSTEMD (Opcional — Recomendado para Cloud)

Para que a API suba automaticamente após reboot da VM:

### 8.1 Criar Serviço

```bash
# Na api-gf-01
sudo tee /etc/systemd/system/shadow-api.service > /dev/null << 'EOF'
[Unit]
Description=PRJ008 Shadow API REST
After=network.target tailscaled.service
Requires=network.target

[Service]
Type=simple
User=paulo
WorkingDirectory=/home/paulo/prj008-shadow-api
Environment="PATH=/home/paulo/prj008-shadow-api/venv/bin"
ExecStart=/home/paulo/prj008-shadow-api/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000 --log-level info
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Habilitar e iniciar
sudo systemctl daemon-reload
sudo systemctl enable shadow-api
sudo systemctl start shadow-api

# Verificar
sudo systemctl status shadow-api
```

### 8.2 Verificar após reboot

```bash
sudo reboot
# Aguardar ~30s
# Após reconectar:
curl -s http://localhost:8000/
# Esperado: {"status":"Shadow API is operational",...}
```

---

## FASE 9 — RENOVAÇÃO DO TOKEN VAULT (Manutenção)

O token de serviço tem TTL de 24h. Para renovar:

```bash
# Na vault-gf-01
export VAULT_ADDR='http://127.0.0.1:8200'
vault login

# Gerar novo token
NEW_TOKEN=$(vault token create \
  -policy=api-proxy-policy \
  -period=24h \
  -format=json | jq -r .auth.client_token)

# Na api-gf-01 — substituir token
echo "$NEW_TOKEN" | sudo tee /var/lib/shadow-api/vault_token > /dev/null
sudo chmod 600 /var/lib/shadow-api/vault_token
sudo chown paulo:paulo /var/lib/shadow-api/vault_token

# Reiniciar serviço para ler o novo token
sudo systemctl restart shadow-api
```

**Para automação (cron):**

```bash
# Na vault-gf-01 — cron às 03:00 diariamente
crontab -e
# Adicionar:
# 0 3 * * * export VAULT_ADDR='http://127.0.0.1:8200' && vault token renew -format=json > /dev/null 2>&1
```

---

## CHECKLIST DE VERIFICAÇÃO FINAL

Execute este checklist após completar todas as fases:

```bash
echo "=== PRJ008 — CHECKLIST FINAL ==="

# 1. Vault acessível
echo -n "1. Vault acessível: "
curl -s http://<IP_VAULT>:8200/v1/sys/health | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print('✅' if not d.get('sealed') else '❌ SEALED')"

# 2. Token de serviço válido
echo -n "2. Token de serviço: "
VAULT_ADDR="http://<IP_VAULT>:8200"
VAULT_TOKEN=$(cat /var/lib/shadow-api/vault_token)
curl -s -H "X-Vault-Token: $VAULT_TOKEN" \
  "$VAULT_ADDR/v1/auth/token/lookup-self" | \
  python3 -c "import sys,json; d=json.load(sys.stdin); \
  print('✅' if d.get('data') else '❌ INVÁLIDO')"

# 3. MariaDB acessível
echo -n "3. MariaDB (porta 3306): "
nc -zv <IP_RH> 3306 2>&1 | grep -q "succeeded" && echo "✅" || echo "❌"

# 4. API raiz
echo -n "4. GET /: "
curl -s http://localhost:8000/ | python3 -c \
  "import sys,json; d=json.load(sys.stdin); \
  print('✅' if d.get('status') == 'Shadow API is operational' else '❌')"

# 5. GET /employees sem auth → 403
echo -n "5. Auth (sem key → 403): "
CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/employees)
[[ "$CODE" == "403" ]] && echo "✅" || echo "❌ (HTTP $CODE)"

# 6. GET /employees com auth → 200
echo -n "6. GET /employees com key → 200: "
CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "X-API-KEY: Fiqueok-Security-Token-2026" http://localhost:8000/employees)
[[ "$CODE" == "200" ]] && echo "✅" || echo "❌ (HTTP $CODE)"

# 7. Dados retornados
echo -n "7. Dados: "
COUNT=$(curl -s -H "X-API-KEY: Fiqueok-Security-Token-2026" \
  http://localhost:8000/employees | python3 -c \
  "import sys,json; print(len(json.load(sys.stdin)))")
[[ "$COUNT" -gt "0" ]] && echo "✅ $COUNT registros" || echo "❌ Sem dados"

echo "=== FIM DO CHECKLIST ==="
```

---

## VARIÁVEIS DE AMBIENTE — REFERÊNCIA RÁPIDA

| Variável | Valor | Onde usar |
|----------|-------|-----------|
| `IP_VAULT_GF_01` | IP Tailscale do vault-gf-01 | app/vault.py, testes |
| `IP_RH_GF_01` | IP Tailscale do rh-gf-01 | Vault secret + testes |
| `IP_API_GF_01` | IP Tailscale do api-gf-01 | midPoint Resource XML |
| `API_KEY_VALUE` | `Fiqueok-Security-Token-2026` | Header X-API-KEY |
| `VAULT_SECRET_PATH` | `secret/orangehrm/db_api` | app/vault.py |
| `TOKEN_PATH` | `/var/lib/shadow-api/vault_token` | app/vault.py |

---

## ADAPTAÇÃO PARA CLOUD

### Diferenças no provisionamento Cloud vs Hyper-V

| Aspecto | Hyper-V (Home Lab) | Cloud (Azure/AWS/OCI) |
|---------|-------------------|----------------------|
| Criação de VM | `New-VM` PowerShell | Portal/CLI do provedor |
| Rede | Tailscale Mesh | VPC + Security Groups |
| Persistência | VHDX local | Volume gerenciado |
| Custo | Energia elétrica | ~R$ 60–140/mês |
| Cold Start | Unseal manual Vault | Auto-unseal via Cloud KMS |

### Recomendação para Cloud

Para substituir o Vault local pelo auto-unseal em Cloud:

```hcl
# vault-config.hcl (Azure Key Vault)
seal "azurekeyvault" {
  tenant_id     = "xxxx"
  client_id     = "xxxx"
  client_secret = "xxxx"
  vault_name    = "fiqueok-vault"
  key_name      = "vault-unseal-key"
}
```

Para OCI Always Free (recomendado para laboratório sem custo):
- 2 instâncias ARM Ampere A1: 4 vCPU / 24GB RAM total
- 1 instância para `api-gf-01` + Vault combinados
- 1 instância para `iga-gf-02` (midPoint)
- Storage: 200GB incluído

---

## TROUBLESHOOTING

### Problema: GPathResult ao usar ScriptedREST no midPoint 4.10

**Causa:** ScriptedREST 1.1.1.e2 (ForgeRock) é incompatível com Java 21.
**Status:** Bloqueio documentado em TEP-PRJ008-v1.0-FREEZING.md
**Resolução pendente:** Aguardar connector-rest Polygon com suporte Java 21 ou build Maven customizado.

### Problema: Token Vault expirado (API retorna 403 inesperado)

```bash
# Verificar validade do token
export VAULT_ADDR='http://<IP_VAULT>:8200'
export VAULT_TOKEN=$(cat /var/lib/shadow-api/vault_token)
vault token lookup
# Se expirado: executar FASE 9
```

### Problema: MariaDB connection refused

```bash
# Verificar se Tailscale está ativo
tailscale status
# Verificar se MariaDB está rodando em rh-gf-01
ssh paulo@<IP_RH> "cd ~/prj005-orange-greenfield && docker ps"
# Se parado: docker compose up -d
```

### Problema: API não sobe (erro de módulo)

```bash
cd ~/prj008-shadow-api
source venv/bin/activate
python -c "from app.main import app; print('OK')"
# Se erro: verificar imports e requirements.txt
pip install -r requirements.txt --force-reinstall
```

### Problema: Caracteres corrompidos nos nomes

```bash
# Verificar charset da conexão MariaDB
python3 -c "
from app.database import get_engine
with get_engine().connect() as conn:
    result = conn.execute(__import__('sqlalchemy').text('SHOW VARIABLES LIKE \"character_set%\"'))
    for r in result: print(r)
"
# Deve mostrar utf8mb4 em todos os campos
```

---

## REFERÊNCIAS E EVIDÊNCIAS

| Documento | Localização | Descrição |
|-----------|-------------|-----------|
| TAP-PRJ008-v3.0 | Obsidian/PRJ008 | Termo de Abertura |
| TEP-PRJ008-v1.0-FREEZING | Obsidian/PRJ008 | Encerramento/Freezing |
| ARQ-PRJ003-ADR-PRJ008-v2.0 | Obsidian/PRJ003 | Arquitetura e ADRs |
| GATE-PRJ008-001-v2.0 | Obsidian/PRJ008 | Matriz de Readiness |
| Evidencias_Prompt_Orange.md | Evidências Sprint 1 | Criação svc_shadow_api |
| Evidencias_Prompt_Vault.txt | Evidências Sprint 1 | Provisionamento secrets |
| Evidencia_Terminal_-_Vault.md | Evidências Sprint 1 | Política + token |

---

## CONTROLE DE VERSÃO

| Versão | Data | Autor | Mudança |
|--------|------|-------|---------|
| 1.0 | 14/04/2026 | Paulo Feitosa Lima | Versão inicial — Sprints 1–5 documentadas |

---

*POP gerado com apoio de Claude (Anthropic)*
*Living Lab Fiqueok — PRJ008*
*Para retomada da Sprint 6, consultar TEP-PRJ008-v1.0-FREEZING.md*

