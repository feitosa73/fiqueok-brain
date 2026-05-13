#  Retrospectiva

**Projeto**: JOIN Colaboradores Fiqueok no OrangeHRM  
**Período**: 01/03/2026 (Greenfield → 100 colaboradores populados)  
**Status**: **Sucesso Operacional** (100% integridade dados, 102 usuários criados)

## O Que Funcionou Bem

- **Automação SQL Staging**: Carga cross-database (greenfield_hr → orangehrm) evitou UI manual, preservando Salary/JobTitle em 100% casos.
    
- **Higienização Dados**: TRIM() e INSERT IGNORE resolveram 96 JobTitles/Subunits divergentes.
    
- **RBAC Mapeamento**: secgroup_role_map traduziu GRP_* → user_role_id (Admin/ESS), criando acessos dia-zero.
    
- **Resiliência Infra**: Reset root MariaDB (Rosa2025!) + checkpoints Hyper-V garantiram RTO <5min.
    
- **Validação Final**: Query "Query OK, 100 rows" + SELECT LIMIT 5 confirmou David Vélez CEO/Salary 48k.​
    

## O Que Poderia Melhorar

- **Senha Root Inicial**: Access Denied x2 → Break-glass procedure desnecessária (docker --skip-grant-tables).
    
- **Schema Divergências**: job_title vs job_title_name; payperiod_code ausente → 3 warnings/0 rows iniciais.
    
- **Mapeamento Grupos**: 22→31→47→100 usuários (iterativo) → Tabela secgroup_role_map incompleta no v1.
    
- **Banco Staging**: greenfield_hr isolado OK, mas staging sem índices → Performance em escala >1k.
    
- **Documentação Inline**: "cite 2" colados em SQL → Erros sintaxe 1064 (higienizar prompts).
    

## Ações de Melhoria

|Ação|Responsável|Prazo|Impacto|
|---|---|---|---|
|Vault Credenciais (Rosa2025!) no 1Password|Paulo|03/03|Alto (ISO A.9.2.3)|
|Script Python API v2 (pandas+mysql-connector)|Paulo|05/03|Médio (Escala 10k+)|
|secgroup_role_map Completa (todos GRP_*)|Paulo|Hoje|Alto (RBAC full)|
|Índices staging (EmployeeID)|Paulo|03/03|Baixo (Perf)|
|Checklist Pre-SQL (SHOW TABLES/DESC)|Template Obsidian|Hoje|Alto (Zero erros)|

## Lições Aprendidas (L0*)

- **L01**: Sempre DESC/DISTINCT antes INSERT → Detecta 96% schema gaps.
    
- **L02**: Docker vars (MYSQL_ROOT_PASSWORD) em docker-compose.yml → Evita lockouts.
    
- **L03**: Staging DB isolado + Cross-JOIN → Zero contaminação produção.
    
- **L04**: EmployeeID como ImmutableID → Ponte perfeita OrangeHRM → Entra ID (PRJ011).
    
- **L05**: Warnings=0 é meta; IGNORE salva, mas logue!​
    

## Estado Evolução Lab

text

`Estado Inicial (Ruim): UI manual, erros manuais Salary Automação Sem Governança: SQL direto, mas sem Vault/Checks Processo Corrigido: Staging + Mapeamento RBAC IGA Aplicado: Pronto para midPoint/Entra ID sync`

**Próximo**: PRJ011 - Export OrangeHRM → Entra ID (EmployeeID anchor). Lab pronto para demo executiva