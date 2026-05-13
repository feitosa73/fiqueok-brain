# 

**Projeto:** PRJ004 - IGA Data Lifecycle

**Data da Última Verificação:** 27/01/2026

**Status do Ambiente:** Operacional (Healthy)

## 1. Inventário de Infraestrutura (Host Virtual)

|**Atributo**|**Detalhe Técnico**|
|---|---|
|**Nome da VM (Hyper-V)**|`iga-gf-01`|
|**Sistema Operacional**|Ubuntu Server (Linux)|
|**Endereço IP (Host)**|`xxx.xxx.xxx.xxx`|
|**Gateway da Rede Física**|`xxx.xxx.xxx.xxx`|
|**Papel do Servidor**|Console de Gerenciamento IGA e Banco de Dados|

## 2. Stack de Software e Containers (Docker)

|**Componente**|**Imagem/Versão**|**IP Interno (Docker)**|**Porta Exposta**|
|---|---|---|---|
|**midPoint**|`evolveum/midpoint:4.10`|`172.18.0.x`|`8080`|
|**PostgreSQL**|`postgres:16`|`172.18.0.y`|`5432`|

## 3. Topologia de Rede Lógica

- **Rede do Projeto (Docker):** `iga-project_iga-network`
    
- **Sub-rede Identificada:** `172.18.0.0/16`
    
- **Interfaces de Rede Atuais:**
    
    1. `lo`: Loopback.
        
    2. Interface Primária: Conectada à rede `xxx.xxx.xxx.xxx/24`.
        

## 4. Estado da Governança (midPoint)

- **Fonte Autoritativa:** Ativa (`employees_prj004.csv`).
    
- **Última Carga de Sincronização:** 10 Sucessos (Joiner validado).
    
- **Mapeamentos Críticos:** `personalNumber` e `lifecycleState` configurados como **Strong**.
