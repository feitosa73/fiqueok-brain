
> [!ABSTRACT] Resumo Executivo
> 
> Este documento define a infraestrutura de Governança de Identidades da Fiqueok. Integra o midPoint 4.10 com o OrangeHRM, implementando Security by Design, segregação de redes Docker e conformidade com ISO 27001:2022.

---

## 1. Princípios de Arquitetura (GRC & Tech)

|**Princípio**|**Descrição**|**Justificativa**|
|---|---|---|
|**Fonte Autoritativa**|OrangeHRM é a única "origem da verdade".|Alinhamento NIST/ISO.|
|**Segregação de Redes**|Stacks isoladas via Docker Bridge.|ISO 27001 A.13.1.1.|
|**Zero Trust**|Menor privilégio no acesso ao banco (Read-Only).|Redução de superfície de ataque.|
|**Infra as Code**|Docker Compose + Documentação versionada.|Rastreabilidade total.|

---

## 2. Desenho de Rede e Conectividade

### 2.1 Topologia Docker

A infraestrutura é segmentada para evitar movimentação lateral:

- **Rede `midpoint_lab_net`**: midPoint-Server (8080) + Postgres (5432).
    
- **Rede `orangehrm_lab_net`**: OrangeHRM-App (8081) + MariaDB (3306).
    

> [!IMPORTANT] Hardening de Rede
> 
> Os bancos de dados (Portas 5432 e 3306) não estão expostos para o host. A comunicação é estritamente interna entre os containers, atendendo ao controle CIS Control 1.1.

---

## 3. Fluxos de Identidade (Ciclo de Vida JML)

### 3.1 Mapeamento HR-Feed (OrangeHRM ➔ midPoint)

|**Campo HR**|**Atributo midPoint**|**Função Estratégica**|
|---|---|---|
|`employee_id`|`personalNumber`|**Correlação**: Unicidade da conta.|
|`job_title`|`jobTitle`|**RBAC**: Gatilho para atribuição de acessos.|
|`department`|`organizationalUnit`|**Estrutura**: Alocação na árvore organizacional.|
|`termination_date`|`administrativeStatus`|**Leaver**: Desativação automática de contas.|

### 3.2 Processos Automatizados

1. **Joiner (Novo):** Detecta novo registro no MariaDB ➔ Cria User no midPoint ➔ Atribui Roles por Cargo.
    
2. **Mover (Mudança):** Altera `job_title` ➔ midPoint recalcula permissões ➔ Remove acessos antigos.
    
3. **Leaver (Saída):** `termination_date` atingida ➔ Suspensão imediata no IGA e (futuro) no AD.
    

---

## 4. Segurança e Gestão de Segredos

- **Cofre de Senhas:** Todas as credenciais de admin (`administrator`, `orangehrm_admin`) e de DB são geridas no **KeePass**.
    
- **Variaveis de Ambiente:** Uso de arquivos `.env` para evitar exposição de senhas no `docker-compose.yml`.
    
- **Princípio do Menor Privilégio:** O conector do midPoint utiliza um usuário no MariaDB com permissão apenas de `SELECT` na tabela de funcionários.
    

---

## 5. Roadmap de Evolução

- [x] **Fase 1:** midPoint 4.10 + OrangeHRM operacionais em Docker.
    
- [ ] **Fase 2:** Integração com **Active Directory** (Provisionamento Real).
    
- [ ] **Fase 3:** Implementação de **Campanhas de Certificação de Acesso** (Revisão Periódica).
    
- [ ] **Fase 4:** Dashboards de conformidade para auditoria ISO 27001.
    

---

## 6. Referências de Conformidade

- **ISO 27001:2022**: Controles A.5, A.6, A.7 e A.9.
    
- **NIST CSF 2.0**: Categorias Identify (ID) e Protect (PR).
    
- **CIS Controls v8**: Controles 1, 2 e 8.