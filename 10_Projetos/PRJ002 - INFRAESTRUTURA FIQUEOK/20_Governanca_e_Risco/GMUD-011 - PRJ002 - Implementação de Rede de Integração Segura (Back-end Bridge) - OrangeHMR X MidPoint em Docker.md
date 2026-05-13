## 📊 Informações da Mudança

| **Campo**            | **Valor**                                                    |
| -------------------- | ------------------------------------------------------------ |
| **ID da GMUD**       | GMUD-011                                                     |
| **Título**           | Implementação de Rede de Integração Segura (Back-end Bridge) |
| **Solicitante**      | Paulo - Fiqueok Consultoria                                  |
| **Executor**         | Paulo - Fiqueok Consultoria                                  |
| **Data de Criação**  | 26/12/2025                                                   |
| **Data de Execução** | 26/12/2025                                                   |
| **Prioridade**       | Alta (Bloqueio de evolução do projeto IGA)                   |
| **Categoria**        | Infraestrutura / Docker Networking                           |
| **Impacto**          | Médio (Reinicialização de containers de IGA e RH)            |
| **Risco**            | Baixo (Alteração de configuração lógica de rede)             |
| **Status**           | Executada                                                    |

---

## 🎯 Objetivo

Implementar uma rede de integração persistente entre as stacks de IGA e RH para garantir:

1. **Resolução de Nomes (DNS):** Permitir que o midPoint localize o banco de dados via `orangehrm-db`.
    
2. **Persistência (IaC):** Garantir que a conectividade sobreviva a reinícios do host ou comandos `down/up`.
    
3. **Micro-segmentação (ISO 27001):** Isolar o tráfego de integração, expondo apenas o banco de dados ao motor de IGA.
    

---

## 📝 Descrição Técnica

### Estado Atual (Incidente)

As stacks midpoint_lab e orangehrm_lab operam em redes isoladas. Após o reinício do host, a conectividade efêmera foi perdida, resultando no erro:

nc: bad address 'orangehrm-db'.

### Estado Desejado (Pós-Mudança)

Criação de uma rede bridge externa (`fiqueok-backend-net`) que atua como um "corredor seguro" entre o container de banco de dados do RH e o servidor de IGA.

---

## 🔧 Mudanças a Serem Realizadas

#### 1️⃣ Ubuntu Server (IGA-P-01) - Host

**Ação:** Criação da rede lógica de integração no Docker Engine.

Bash

```
docker network create fiqueok-backend-net
```

#### 2️⃣ Configuração do OrangeHRM (Fonte Autoritativa)

**Arquivo:** `~/orangehrm_lab/docker-compose.yml` **Ação:** Injeção da rede de integração no serviço de banco de dados (**MariaDB**).

YAML

```
services:
  orangehrm-db:
    networks:
      - orangehrm_lab_net
      - fiqueok-backend-net  # Interface de comunicação IGA

networks:
  orangehrm_lab_net:
  fiqueok-backend-net:
    external: true
```

#### 3️⃣ Configuração do midPoint (Motor de IGA)

**Arquivo:** `~/midpoint_lab/docker-compose.yml` **Ação:** Injeção da rede no servidor e segregação do tráfego do repositório (**PostgreSQL**).

YAML

```
services:
  midpoint_server:
    networks:
      - midpoint_internal_net  # Tráfego interno (Banco Postgres)
      - fiqueok-backend-net    # Tráfego externo (Integração RH)

networks:
  midpoint_internal_net:
  fiqueok-backend-net:
    external: true
```

---

### 🛡️ Fundamentação Técnica (NIST CSF 2.0 / ISO 27001:2022)

Esta estrutura atende aos seguintes requisitos:

- **ISO/IEC 27001:2022 (A.13.1.1):** Segregação de Redes. O midPoint agora possui caminhos distintos para sua persistência (Postgres) e para sua coleta de dados (MariaDB).
    
- **NIST CSF 2.0 (PR.NW-01):** As comunicações de rede são protegidas. A micro-segmentação garante que o banco de dados do RH não esteja exposto a toda a sub-rede do midPoint, apenas ao container específico do servidor.
- 
```

---

## ⏱️ Janela de Manutenção

|**Item**|**Descrição**|
|---|---|
|**Duração Estimada**|15 minutos|
|**Downtime Esperado**|~2 minutos (Restart dos containers)|
|**Sistemas Afetados**|midPoint UI e OrangeHRM UI|

---

## ✅ Critérios de Sucesso

### Testes de Validação

Bash

# 1. Validar criação da rede
docker network ls | grep fiqueok-backend-net

# 2. Testar resolução de DNS de dentro do midPoint
docker exec -it midpoint_lab-midpoint_server-1 ping -c 2 orangehrm-db

# 3. Testar conectividade na porta do MariaDB
docker exec -it midpoint_lab-midpoint_server-1 nc -zv orangehrm-db 3306
# Esperado: Connection to 
```
orangehrm-db 3306 port [tcp/mysql] succeeded!
```

---

## 🔄 Plano de Rollback

1. Remover as referências à rede `fiqueok-backend-net` dos arquivos `.yml`.
    
2. Executar `docker compose up -d` em ambas as pastas para retornar ao estado isolado original.
    
3. Remover a rede: `docker network rm fiqueok-backend-net`.
    

---

## 📊 Impacto nos Sistemas

|**Sistema**|**Impacto**|**Mitigação**|
|---|---|---|
|midPoint|Indisponibilidade breve|Execução fora de horário de pico|
|OrangeHRM|Indisponibilidade breve|Reinício simultâneo das stacks|
|Segurança|Positivo (Segregação)|Aplicação de micro-segmentação de rede|

---

## 🔐 Requisitos de Segurança

- ✅ Acesso sudo no Host Ubuntu.
    
- ✅ Princípio do Menor Privilégio: Somente o DB e o IGA participam da nova rede.
    
- ✅ Conformidade ISO 27001 (A.13.1.1 - Segregação de Redes).
    

---

## 📋 Checklist de Execução

### Pré-Execução

- [ ] Backup dos arquivos `docker-compose.yml` atuais.
    
- [ ] Validar que os containers estão `Up` antes de iniciar.
    

### Execução

- [ ] Criar rede `fiqueok-backend-net`.
    
- [ ] Editar YAML do OrangeHRM.
    
- [ ] Editar YAML do midPoint.
    
- [ ] Aplicar mudanças (`docker compose up -d`).
    

### Pós-Execução

- [ ] Executar os 3 testes de validação.
    
- [ ] Capturar logs de sucesso para o Obsidian.
    
- [ ] Atualizar status da GMUD para "Executada".
    

---

## ✍️ Aprovações e Assinaturas

|**Papel**|**Nome**|**Data**|**Assinatura**|
|---|---|---|---|
|Solicitante|Paulo|26/12/2025|________|
|Executor|Paulo|26/12/2025|________|
|Aprovador|Paulo|26/12/2025|________|

---

### 📖 Aplicação Prática (NVI - Provérbios 21:5)

_"Os planos bem elaborados levam à fartura; mas o apressado sempre acaba na miséria."_
