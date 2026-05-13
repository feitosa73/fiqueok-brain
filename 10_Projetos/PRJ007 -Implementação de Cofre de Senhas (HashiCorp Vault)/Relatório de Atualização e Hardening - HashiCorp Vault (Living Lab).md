#

**Data:** 18 de Abril de 2026

**Responsável:** Paulo

**Contexto:** Transição de ambiente técnico para arquitetura de governança e confiança zero.

## 1. Histórico de Alterações Recentes

O ambiente evoluiu de uma instalação base com acesso via Root Token para uma estrutura multiusuário com perímetros de rede e identidade.

### 1.1 Camada de Rede e Identidade (Perímetro)

- **Publicação Segura (PRJ017):** Implementação de Túnel Cloudflare (`cloudflared`) eliminando a exposição de IPs diretos e habilitando HTTPS/TLS 1.3.
    
- **Zero Trust (Cloudflare Access):** Adição de camada de autenticação externa via **OTP (One-Time PIN)** vinculada a e-mails específicos antes de permitir o acesso à interface do Vault.
    

### 1.2 Gestão de Identidade Interna (IAM)

- **Ativação de Método Userpass:** Habilitação do método de autenticação por usuário e senha para eliminar a dependência do Root Token.
    
- **Criação de Usuários Nominais:**
    
    - `paulo`: Perfil Administrador (`admin-policy`).
        
    - `rose` & `daniel`: Perfil Operacional (`reader-policy`).
        
- **Implementação de RBAC (Role-Based Access Control):** Criação de políticas ACL para garantir o **Princípio do Privilégio Mínimo**.
    

## 2. Implementação da Auditoria (Estado Atual)

- **Audit Device:** Ativado o dispositivo de log em arquivo no caminho `/opt/vault/logs/vault_audit.log`.
    
- **Integridade:** O Vault está configurado para o modo "Fail-Closed" (se o log falhar, o serviço trava para impedir ações sem rastro).
    
- **Análise de Dados:** Logs gerados em formato JSON, com mascaramento de dados sensíveis via HMAC-SHA256.
    

---

## 3. Análise de Risco e Tomada de Decisão (Trade-offs)

Atualmente, enfrentamos um dilema técnico-operacional que requer decisão:

|**Desafio**|**Descrição do Risco**|**Decisão Racional Proposta**|
|---|---|---|
|**Esgotamento de Disco**|O log de auditoria é verboso. O disco atual (10GB) está com 61% de uso.|Implementar **Logrotate** (retenção de 7 dias) e compressão para garantir a disponibilidade do serviço.|
|**Fricção de MFA**|Usuários passam pelo OTP da Cloudflare e depois pela senha do Vault.|Manter o MFA na borda (Cloudflare) para conveniência, mas avaliar TOTP interno apenas para contas `admin` (sudo).|
|**Visibilidade de Log**|Logs internos mostram IP `127.0.0.1` devido ao túnel.|Configurar o Vault para aceitar o cabeçalho `X-Forwarded-For`, permitindo auditoria do IP real do usuário.|

---

## 4. Alinhamento com Frameworks de Mercado

### ISO/IEC 27001

- **Controle A.8.15 (Logging):** Atendido com a ativação do Audit Device.
    
- **Controle A.8.3 (Privilégio Mínimo):** Atendido com a criação da `reader-policy`.
    
- **Controle A.5.18 (Gestão de Identidades):** Atendido pela migração do Root Token para contas nominais.
    

### NIST Cybersecurity Framework (PR.AC-1)

- Recomenda que identidades sejam verificadas e vinculadas a ativos. A integração Cloudflare + Vault Userpass endereça a **Identidade Federada** e o **Controle de Acesso**.
    

### CIS Benchmarks (HashiCorp Vault)

- O CIS recomenda explicitamente a **desativação ou proteção do Root Token**. Ao criar o usuário `paulo` com `admin-policy`, o ambiente cumpre um dos requisitos de hardening mais críticos do benchmark.
    

### Regulamentação PCI-DSS v4.0 (Cenário Hipotético)

Se este ambiente processasse dados de cartões de crédito, as seguintes exigências seriam obrigatórias:

- **Requisito 7:** Restringir o acesso aos dados pelo princípio da "necessidade de saber". (Implementado via ACLs).
    
- **Requisito 10:** Implementar trilhas de auditoria para todos os acessos a recursos do sistema. (Implementado via File Audit).
    
- **Requisito 10.4.1:** Logs de auditoria devem ser protegidos contra alterações não autorizadas. (O uso de `copytruncate` e permissões `root:vault` no Linux auxiliam aqui).
    

---

## 5. Próximos Passos Sugeridos

1. **Hardening de SO:** Configurar o `logrotate` para mitigar o risco de _Denial of Service_ por disco cheio.
    
2. **Monitoramento:** Integrar os logs do Vault com um centralizador (ex: Syslog ou SIEM) para retirar o log da máquina local.
    
3. **Segregação:** Testar a tentativa de acesso negado (403) para validar que a auditoria registra eventos negativos.