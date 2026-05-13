


**Projeto:** PRJ007 - Integração OrangeHRM + MidPoint  
**Data:** 04 de Fevereiro de 2026  
**Fase:** Infraestrutura de Segurança - Gestão de Segredos  
**Responsável:** [Seu Nome]  
**Versão:** 2.0 (Revisada com feedback Gemini + DeepSeek)

---

## Contexto Executivo

Durante a implementação do PRJ007, inicialmente planejamos criar uma API de integração personalizada para conectar OrangeHRM ao MidPoint. Após análise, identificamos que essa abordagem introduziria mais um hardcode no sistema, aumentando a dívida técnica. A decisão estratégica foi priorizar a instalação do HashiCorp Vault para gestão centralizada de credenciais e segredos.[](https://developer.hashicorp.com/vault/install)

Para acelerar o aprendizado e aproveitar a automação de infraestrutura, optamos por provisionar o Vault utilizando Terraform. Durante o processo, utilizamos assistência de IA (Gemini) que conduziu a uma implementação insegura e não funcional, resultando em retrabalho significativo e exposição de vulnerabilidades críticas.[](https://www.addwebsolution.com/blog/terraform-tips-for-infrastructure-automation)​

---

## Decisões Arquiteturais

## Decisão 1: Priorização do Vault sobre API Hardcoded

**Contexto:** Necessidade de integrar OrangeHRM com MidPoint  
**Decisão:** Implementar HashiCorp Vault antes de desenvolver APIs de integração  
**Rationale:** Evitar hardcoding de credenciais e estabelecer arquitetura de segredos desde o início[](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)

## Decisão 2: Automação com Terraform

**Contexto:** Equipe em curva de aprendizado com múltiplas tecnologias  
**Decisão:** Utilizar Infrastructure as Code (IaC) com Terraform para provisionar Vault  
**Rationale:** Documentar a infraestrutura como código, permitir reprodutibilidade e acelerar futuros deployments[](https://atmosly.com/blog/top-10-terraform-best-practices-for-infrastructure-automation)

**Aprimoramento Identificado:** O uso do provedor `taliesins/hyperv` revelou a importância de:

- **Due Diligence de Provedores:** Verificar se é provedor oficial HashiCorp ou partner certified
    
- **Análise de Maturidade:** Última atualização, atividade no GitHub, issues abertas e vulnerabilidades conhecidas
    
- **Fallback Strategy:** Ter plano B (PowerShell nativo) para provedores não oficiais
    
- **Isolamento de Experimentação:** Branch dedicada e snapshot prévio à execução de `terraform apply`
    

## Decisão 3: Deployment via Docker Compose

**Contexto:** Ambiente de laboratório com recursos limitados  
**Decisão:** Utilizar container Docker com armazenamento persistente em arquivo  
**Rationale:** Simplicidade operacional e isolamento do serviço[](https://hub.docker.com/_/vault)

---

## Nota Técnica: Decisão Arquitetural de Storage Backend

## File Storage vs Integrated Storage (Raft)

|Critério|File Storage (Lab)|Integrated Storage (Produção)|
|---|---|---|
|**Alta Disponibilidade (HA)**|❌ Não suporta|✅ Suporta nativamente via Raft consensus [](https://developer.hashicorp.com/vault/docs/configuration/storage/raft)|
|**Performance**|⚠️ Limitada por I/O de arquivo|✅ Otimizado para operações concorrentes|
|**Backup**|⚠️ Complexo (lock files) [](https://stackoverflow.com/questions/71742759/hashicrop-vault-backup-with-file-backend)​|✅ Suporta snapshots nativos (`vault operator raft snapshot`) [](https://stackoverflow.com/questions/71742759/hashicrop-vault-backup-with-file-backend)​|
|**Uso em Docker**|⚠️ Requer volume dedicado com permissões corretas|✅ Recomendado pela HashiCorp como padrão [](https://developer.hashicorp.com/vault/docs/configuration/storage/raft)​|
|**Replicação Enterprise**|❌ Não suporta|✅ Compatível com DR e Performance Replication [](https://developer.hashicorp.com/vault/docs/internals/integrated-storage)​|
|**Complexidade Operacional**|✅ Simples (single file)|⚠️ Requer gestão de cluster Raft|

**Decisão PRJ007:** Utilizar File Storage APENAS para:

- Isolamento completo do ambiente de laboratório
    
- Demonstração conceitual de persistência
    
- Validação da documentação oficial HashiCorp sem dependências externas
    

**⚠️ Nota de Transição:** Este backend NÃO deve ser replicado em produção sem reavaliação arquitetural completa. Para produção, Integrated Storage (Raft) é o padrão atual da HashiCorp desde 2019.[](https://developer.hashicorp.com/vault/docs/configuration/storage/raft)

---

## Problemas Identificados

## 1. Orientação Insegura do Assistente IA

**Problema:** O Gemini conduziu a implementação por um "caminho árduo sem segurança"  
**Impacto:** Perda de tempo, exposição potencial de segredos, instalação não funcional

**Falhas Específicas:**

- Sugestões que não seguiram as práticas de production hardening da HashiCorp[](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)​
    
- Configurações inadequadas para o processo de unseal[](https://developer.hashicorp.com/vault/docs/commands/operator/init)
    
- Falta de orientação sobre armazenamento seguro das unseal keys[](https://inventivehq.com/blog/hashicorp-vault-rekey-unseal-complete-security-guide)
    
- Deployment que não inicializou corretamente o Vault
    

## 2. Gestão Inadequada de Unseal Keys

**Problema:** Planejamento de armazenar unseal keys em SECRETS.md (arquivo de texto)  
**Impacto Potencial:** Violação crítica de segurança[](https://developer.hashicorp.com/vault/docs/concepts/seal)

**Contexto Técnico:**

- Vault utiliza Shamir's Secret Sharing para dividir a root key em múltiplos shards[](https://notes.kodekloud.com/docs/HashiCorp-Certified-Vault-Associate-Certification/Learning-the-Vault-Architecture/Unsealing-with-Key-Shards)
    
- As unseal keys são necessárias para reconstruir a root key e descriptografar a encryption key[](https://developer.hashicorp.com/vault/docs/concepts/seal)​
    
- Armazenar estas chaves em texto plano anula completamente o modelo de segurança do Vault[](https://notes.kodekloud.com/docs/HashiCorp-Certified-Vault-Associate-Certification/Learning-the-Vault-Architecture/Seal-and-Unseal)
    
- Violação direta de **ISO 27001: A.10.1.2** (gestão de chaves criptográficas)[](https://hightable.io/iso27001-annex-a-8-24-use-of-cryptography/)
    

## 3. Falta de Validação da Abordagem

**Problema:** Seguir orientações do assistente IA sem validar contra documentação oficial  
**Impacto:** Retrabalho completo e potencial comprometimento de segurança

## 4. Vulnerabilidade de Hardcoded Credentials

**Problema:** O assistente IA conduziu à exposição da senha `**********` em múltiplos locais:

- Variáveis de ambiente no histórico do PowerShell
    
- Prompt interativo do Terraform sem mascaramento
    
- Possivelmente em logs do sistema operacional e Docker
    

**Impacto:** Violação de princípios básicos de segurança:

- **ISO 27001: A.9.4.1** - Restrição de acesso à informação[](https://info-savvy.com/iso-27001-annex-a-10-cryptography/)​
    
- **ISO 27001: A.10.1.1** - Política de uso de controles criptográficos[](https://hightable.io/iso27001-annex-a-8-24-use-of-cryptography/)
    
- Comprometimento da conta administrativa do Hyper-V
    

**Controle Corretivo Implementado:**

- Limpeza completa do histórico do PowerShell (`Clear-History`)
    
- Revogação/rotação de credenciais expostas
    
- Implementação de variáveis de ambiente via `.env` com `.gitignore` obrigatório
    
- Uso de `Get-Credential` para input seguro em scripts futuros
    

---

## Lições Aprendidas

## L1: Validação Crítica para Segurança

**Lição:** Assistentes de IA não devem ser fonte única de verdade para implementações de segurança

**Ação Corretiva:**

- Sempre validar configurações de segurança contra documentação oficial da HashiCorp[](https://developer.hashicorp.com/vault/install)
    
- Consultar múltiplas fontes para decisões críticas de arquitetura
    
- Implementar checklist de security hardening antes do deployment[](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)​
    

**Aplicação Futura:**

- Estabelecer processo de peer review antes de implementar sugestões de IA
    
- Manter biblioteca de referências oficiais para tecnologias críticas
    

## L2: Gestão Apropriada de Unseal Keys

**Lição:** Unseal keys são equivalentes às chaves do cofre e requerem proteção máxima[](https://www.gitguardian.com/remediation/hashicorp-vault-unseal-key)

**Práticas Corretas:**

- **Nunca** armazenar unseal keys em arquivos de texto, repositórios Git ou sistemas de notas[](https://www.gitguardian.com/remediation/hashicorp-vault-unseal-key)​
    
- Utilizar PGP encryption para proteger as keys durante a distribuição[](https://developer.hashicorp.com/vault/docs/commands/operator/init)​
    
- Distribuir shares entre múltiplos key holders em organizações (princípio de separação de deveres)[](https://inventivehq.com/blog/hashicorp-vault-rekey-unseal-complete-security-guide)​
    
- Para ambientes de laboratório: considerar Auto Unseal com cloud KMS ou file-based encryption[](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)​
    
- Implementar processo de key rotation periódico (`vault operator rekey`)[](https://inventivehq.com/hashicorp-vault-rekey-or-unseal-vault/)​
    

## L2 (Ampliação): Valor Pedagógico do Unseal Manual para Laboratórios GRC

**Contexto Adicional:** Para laboratórios de GRC/SGSI, o processo manual de Unseal oferece:[](https://docs.devnetexperttraining.com/static-docs/HashiCorp-Vault/docs/concepts/seal/)

1. **Experiência Tátil** com Shamir's Secret Sharing[](https://notes.kodekloud.com/docs/HashiCorp-Certified-Vault-Associate-Certification/Learning-the-Vault-Architecture/Unsealing-with-Key-Shards)
    
    - Compreensão prática do threshold cryptography (k-of-n scheme)
        
    - Vivência do processo de custódia distribuída de chaves
        
2. **Alinhamento com ISO 27001: A.10.1.2**[](https://info-savvy.com/iso-27001-annex-a-10-cryptography/)
    
    - Gestão de chaves criptográficas ao longo de todo o ciclo de vida
        
    - Separação de deveres (key custodians vs operators)
        
    - Processo documentável para auditoria e conformidade
        
3. **Conscientização de Segurança**
    
    - Entendimento visceral da criticidade da gestão de chaves
        
    - Base para procedimentos operacionais em produção
        
    - Referência para implementações futuras com Auto Unseal
        

**Decisão para PRJ007:** Implementar **Unseal Manual com 5 chaves e threshold 3** como:

- Exercício de conscientização em segurança da informação
    
- Base para documentação de procedimentos operacionais padrão (POP)
    
- Referência para futuras implantações em produção com HSM/KMS
    
- Demonstração de controles ISO 27001 Annex A.10[](https://hightable.io/iso27001-annex-a-8-24-use-of-cryptography/)
    

**Transição para Produção:** Após domínio do processo manual, migrar para Auto Unseal com:

- AWS KMS, Azure Key Vault, ou Google Cloud KMS
    
- HSM (Hardware Security Module) para ambientes altamente regulados
    
- Transit Auto Unseal para clusters multi-datacenter
    

## L3: Terraform como Documentação Viva

**Lição:** IaC não é apenas automação, é documentação executável da infraestrutura[](https://atmosly.com/blog/top-10-terraform-best-practices-for-infrastructure-automation)

**Benefícios Realizados:**

- Configuração versionada e auditável
    
- Capacidade de destruir e recriar ambiente rapidamente
    
- Documentação sempre sincronizada com estado real
    

**Melhorias Necessárias:**

- Modularizar configurações Terraform para reutilização[](https://atmosly.com/blog/top-10-terraform-best-practices-for-infrastructure-automation)​
    
- Implementar Terraform remote state para colaboração[](https://www.addwebsolution.com/blog/terraform-tips-for-infrastructure-automation)​
    
- Adicionar testes de validação (`terraform validate`, `tflint`) no pipeline[](https://atmosly.com/blog/top-10-terraform-best-practices-for-infrastructure-automation)​
    

## L4: Priorização de Production Hardening

**Lição:** Mesmo em ambiente de lab, seguir production best practices acelera aprendizado correto[](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)​

**Práticas Essenciais Vault:**

- Habilitar Audit Device desde o início[](https://inventivehq.com/blog/hashicorp-vault-rekey-unseal-complete-security-guide)​
    
- Configurar TLS mesmo em redes privadas (Tailscale)[](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)​
    
- Implementar princípio de least privilege nas políticas RBAC[](https://inventivehq.com/blog/hashicorp-vault-rekey-unseal-complete-security-guide)​
    
- Ativar log rotation e monitoring[](https://atmosly.com/blog/top-10-terraform-best-practices-for-infrastructure-automation)​
    
- Separar root token usage de operational tokens[](https://developer.hashicorp.com/vault/docs/commands/operator/init)​
    

## L5: Iteração Rápida em Ambientes Controlados

**Lição:** Snapshot de VMs desligadas permite experimentação sem risco permanente

**Estratégia Aplicada:**

- Criar snapshot antes de mudanças significativas
    
- Testar configurações em ambiente isolado (Tailscale mesh)
    
- Documentar cada iteração para evitar repetir erros
    
- Utilizar containers para isolamento adicional[](https://www.virtualizationhowto.com/2025/01/hashicorp-vault-docker-install-steps-kubernetes-not-required/)
    

## L6: Assistentes IA como Aceleradores, Não Arquitetos

**Lição:** IA é excelente para scaffolding inicial, não para decisões arquiteturais de segurança

**Uso Apropriado:**

- ✅ Gerar boilerplate de código Terraform
    
- ✅ Sugerir estrutura inicial de docker-compose.yml
    
- ✅ Explicar conceitos e comandos
    
- ❌ Definir arquitetura de segurança
    
- ❌ Configurar políticas de acesso sem validação
    
- ❌ Implementar fluxos críticos sem supervisão humana
    

## L7: Controles Compensatórios para IA-Assisted Development

## Contexto

A falha na implementação inicial expôs a necessidade de controles formais quando utilizando assistentes de IA para decisões de segurança.[](https://info-savvy.com/iso-27001-annex-a-10-cryptography/)

## Controle Implementado: Human-in-the-loop Validation

**Regra de Ouro:** `[IA Output] → [Manual Validation] → [Documented Exception] → [Execution]`

**Processo Concreto:**

1. **Captura do Comando IA:** Documentar exatamente o que o assistente sugeriu
    
2. **Validação Cruzada:**
    
    bash
    
    `# Exemplo: Para qualquer comando Vault sugerido vault [command] --help grep -rn "[concept]" /usr/share/doc/vault/`
    
3. **Documentação da Exceção:** Se divergir da documentação oficial, requer:
    
    - Justificativa técnica registrada no ADR (Architecture Decision Record)
        
    - Avaliação de risco assinada (baixo/médio/alto/crítico)
        
    - Plano de reversão documentado
        
    - Aprovação formal do Security Officer
        
4. **Execução Controlada:** Sempre em ambiente isolado primeiro (snapshot + rollback ready)
    

## Template de Validação (ADR Simplificado)

text

`## Validação de Sugestão IA - [YYYY-MM-DD] **IA Suggestion:** [comando/configuração sugerida] **Official Docs:** [link para seção relevante em docs.hashicorp.com] **Divergence?:** [Sim/Não] **If Yes:** - **Justification:** [explicação técnica detalhada] - **Risk Assessment:** [baixo/médio/alto/crítico] - **Mitigation:** [controles compensatórios implementados] - **Rollback Plan:** [procedimento de reversão] **Approver:** [nome/role] **Date:** [data] **Status:** [Approved/Rejected/Pending]`

## Benefícios do Controle

- Transforma o "risco IA" em processo auditável[](https://info-savvy.com/iso-27001-annex-a-10-cryptography/)​
    
- Cria barreira contra implementação acidental de anti-patterns
    
- Serve como evidência objetiva para auditorias ISO 27001[](https://hightable.io/iso27001-annex-a-8-24-use-of-cryptography/)​
    
- Estabelece trilha de auditoria para decisões técnicas
    

---

## Impacto no Cronograma

|Fase|Tempo Estimado|Tempo Real|Desvio|
|---|---|---|---|
|Pesquisa e Planejamento|2h|1h|-50%|
|Implementação Inicial|4h|8h|+100%|
|Troubleshooting|1h|6h|+500%|
|Reimplementação Correta|-|4h|N/A|
|**Total**|**7h**|**19h**|**+171%**|

**Análise:** O uso inadequado de assistente IA causou **12h de retrabalho**. Investimento inicial em validação (processo L7) teria economizado 8-10h do projeto e evitado exposição de credenciais.

**Custo do Retrabalho:** Quantificar este desvio de +171% demonstra maturidade em gestão de projetos e consciência sobre o custo real de decisões arquiteturais inadequadas.

---

## Plano de Ação Daily Scrum Revisado

## Fase 1: Provisionamento e Validação de Conectividade (30 min)

**Provisionamento:**

-  Criar VM `vault-gf-01` no Hyper-V (2 vCPU, 2GB RAM, 20GB disco)
    
-  Instalar Docker e Docker Compose via script automatizado
    
-  Configurar Tailscale e validar conectividade com malha existente
    

**✅ NOVO: Validação de Conectividade DNS/Rede (Crítico)**

bash

`# Na VM vault-gf-01 após Tailscale tailscale status tailscale ping rh-gf-01 tailscale ping iga-gf-01 # Testar resolução DNS via MagicDNS nslookup rh-gf-01 nslookup iga-gf-01 # Testar conectividade básica ping -c 3 rh-gf-01 ping -c 3 iga-gf-01`

**Critério de Saída:** Todas as VMs na malha Tailscale devem ser alcançáveis por nome e IP antes de iniciar o deployment do Vault.

---

## Fase 2: Deployment Seguro (45 min)

-  Criar `docker-compose.yml` baseado em exemplo oficial HashiCorp[](https://hub.docker.com/_/vault)
    
-  Criar `vault-config.hcl` com configurações:
    
    text
    
    `storage "file" {   path = "/vault/data" } listener "tcp" {   address     = "0.0.0.0:8200"  tls_disable = 0  # TLS habilitado mesmo em lab  tls_cert_file = "/vault/config/vault-cert.pem"  tls_key_file  = "/vault/config/vault-key.pem" } api_addr = "https://vault-gf-01:8200" ui = true`
    
-  Gerar certificados TLS autoassinados para o lab
    
-  Iniciar container: `docker-compose up -d`
    
-  Validar logs: `docker logs -f vault`
    

---

## Fase 3: Inicialização com Shamir's Secret Sharing (45 min)

-  Executar inicialização com parâmetros pedagógicos:[](https://docs.devnetexperttraining.com/static-docs/HashiCorp-Vault/docs/concepts/seal/)
    
    bash
    
    `vault operator init \   -key-shares=5 \  -key-threshold=3 \  -format=json > init-keys.json`
    
-  **🔐 CRÍTICO: Proteção das Unseal Keys**
    
    - **NUNCA** comitar `init-keys.json` no Git
        
    - Opção 1 (Lab): Criptografar com GPG e distribuir para key custodians simulados
        
    - Opção 2 (Lab): Armazenar em KeePass/1Password com MFA
        
    - Opção 3 (Produção): Implementar Auto Unseal[](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)​
        
-  Executar unseal manual com 3 das 5 keys:[](https://developer.hashicorp.com/vault/docs/concepts/seal)
    
    bash
    
    `vault operator unseal <key1> vault operator unseal <key2> vault operator unseal <key3>`
    
-  Verificar status: `vault status` (deve mostrar `Sealed: false`)
    
-  Autenticar com root token (uso temporário apenas para setup inicial):
    
    bash
    
    `vault login <root_token>`
    
-  **Documentar processo** de unseal para DR/runbook (sem as keys propriamente ditas)
    

---

## Fase 4: Configuração Base e Governança (60 min)

**Secrets Engine:**

-  Habilitar KV v2: `vault secrets enable -version=2 -path=kv kv`
    
-  Criar estrutura de paths:
    
    bash
    
    `vault kv put kv/orangehrm/db username=orangehrm_admin vault kv put kv/midpoint/admin username=administrator`
    

**Políticas RBAC:**

-  Criar política `admin-policy.hcl` (full access, restrito ao Security Officer)
    
-  Criar política `midpoint-policy.hcl` (read-only em `kv/midpoint/*` e `kv/orangehrm/*`)
    
-  Criar política `api-proxy-policy.hcl` (read-only em `kv/orangehrm/api`)
    

**Tokens Operacionais:**

-  Gerar tokens renováveis com TTL adequado:
    
    bash
    
    `vault token create -policy=midpoint-policy -renewable -ttl=24h vault token create -policy=api-proxy-policy -renewable -ttl=12h`
    

**Audit Device (ISO 27001: A.12.4.1):**

-  Habilitar audit logging:[](https://inventivehq.com/blog/hashicorp-vault-rekey-unseal-complete-security-guide)​
    
    bash
    
    `vault audit enable file file_path=/vault/logs/audit.log`
    
-  Configurar rotação de logs (logrotate) para rastreabilidade completa
    

---

## Fase 5: Migração de Segredos (45 min)

-  Migrar **100%** das credenciais OrangeHRM para `kv/orangehrm/*`
    
-  Migrar **100%** das credenciais MidPoint para `kv/midpoint/*`
    
-  Testar acesso com tokens específicos:
    
    bash
    
    `VAULT_TOKEN=<midpoint_token> vault kv get kv/midpoint/admin`
    
-  Validar audit logs: `cat /vault/logs/audit.log | jq .`
    

---

## Fase 6: Integração e Automação (90 min)

**Script Bash para Consumo de Segredos:**

bash

`#!/bin/bash # fetch-secrets.sh VAULT_ADDR="https://vault-gf-01:8200" VAULT_TOKEN=$(cat /etc/vault/token) secret=$(vault kv get -format=json kv/orangehrm/db) db_user=$(echo $secret | jq -r .data.data.username) db_pass=$(echo $secret | jq -r .data.data.password) export DB_USER=$db_user export DB_PASS=$db_pass`

**Biblioteca Python com hvac e Auto-Renewal:**

python

`import hvac import os from datetime import datetime class VaultClient:     def __init__(self):        self.client = hvac.Client(            url='https://vault-gf-01:8200',            token=os.getenv('VAULT_TOKEN')        )             def renew_token(self):        """Auto-renewal de token antes de expirar"""        if self.client.is_authenticated():            self.client.auth.token.renew_self()                 def get_secret(self, path):        """Recupera segredo com tratamento de erro"""        try:            return self.client.secrets.kv.v2.read_secret_version(path=path)        except hvac.exceptions.InvalidPath:            print(f"Segredo {path} não encontrado")            return None`

-  Configurar rotação automática de tokens via cron
    
-  Documentar fluxo de recuperação de secrets para desenvolvedores
    

---

## Fase 7: Observabilidade e Documentação (30 min)

-  Configurar log rotation para audit device:
    
    bash
    
    `# /etc/logrotate.d/vault-audit /vault/logs/audit.log {     daily    rotate 30    compress    delaycompress    notifempty    create 0640 vault vault }`
    
-  Criar runbook de operações comuns:
    
    - Procedimento de unseal manual (sem as keys)
        
    - Rotação de tokens
        
    - Backup do storage backend
        
    - Recuperação de disaster
        
-  Realizar snapshot final com VMs desligadas (backup completo)
    

---

## Fase 8: Post-Mortem e Arquivamento (30 min)

-  Consolidar este documento de Lições Aprendidas (versão 2.0)
    
-  Atualizar documentação técnica do PRJ007 com arquitetura final
    
-  Compartilhar learnings com equipe em sessão de knowledge transfer
    
-  Arquivar configurações Terraform no repositório (sem credenciais)
    
-  Criar ADR (Architecture Decision Record) para decisões críticas
    
-  Submeter para revisão do Security Officer
    

---

**Tempo Total Revisado:** ~6 horas (vs. 19h da tentativa anterior)  
**Eficiência Ganho:** 68% de redução no tempo de execução com processo validado

---

## Referências Técnicas

## Documentação Oficial HashiCorp

- HashiCorp Vault Installation Guide[](https://developer.hashicorp.com/vault/install)​
    
- Production Hardening Checklist[](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)​
    
- Operator Init Command Reference[](https://developer.hashicorp.com/vault/docs/commands/operator/init)​
    
- Seal/Unseal Architecture[](https://developer.hashicorp.com/vault/docs/concepts/seal)​
    
- Integrated Storage (Raft) Backend[](https://developer.hashicorp.com/vault/docs/configuration/storage/raft)​
    
- Raft Storage Internals[](https://developer.hashicorp.com/vault/docs/internals/integrated-storage)​
    

## Security Best Practices

- Vault Security Best Practices[](https://inventivehq.com/blog/hashicorp-vault-rekey-unseal-complete-security-guide)​
    
- Unseal Key Management[](https://inventivehq.com/hashicorp-vault-rekey-or-unseal-vault/)
    
- RBAC Implementation Guide[](https://inventivehq.com/blog/hashicorp-vault-rekey-unseal-complete-security-guide)​
    
- Shamir's Secret Sharing in Vault[](https://notes.kodekloud.com/docs/HashiCorp-Certified-Vault-Associate-Certification/Learning-the-Vault-Architecture/Unsealing-with-Key-Shards)
    

## Compliance e Governança

- ISO 27001 Annex A.10: Cryptography[](https://info-savvy.com/iso-27001-annex-a-10-cryptography/)​
    
- ISO 27001 A.10.1.2: Key Management[](https://hightable.io/iso27001-annex-a-8-24-use-of-cryptography/)​
    
- ISO 27001 A.9.4.1: Information Access Restriction[](https://info-savvy.com/iso-27001-annex-a-10-cryptography/)​
    
- ISO 27001 A.12.4.1: Event Logging[](https://info-savvy.com/iso-27001-annex-a-10-cryptography/)​
    

## Terraform & IaC

- Terraform Best Practices for Infrastructure Automation[](https://www.addwebsolution.com/blog/terraform-tips-for-infrastructure-automation)
    
- Deploying Vault with Terraform[](https://www.digitalocean.com/community/tutorials/how-to-build-a-hashicorp-vault-server-using-packer-and-terraform-on-digitalocean)
    

## Docker Deployment

- Official Vault Docker Image[](https://hub.docker.com/_/vault)​
    
- Vault Docker Install Steps[](https://www.virtualizationhowto.com/2025/01/hashicorp-vault-docker-install-steps-kubernetes-not-required/)​
    

---

## Próximos Passos

## 1. Implementação Imediata

- Seguir Daily Scrum revisado com validação em cada etapa
    
- Aplicar processo L7 (Human-in-the-loop) para todas as decisões críticas
    
- Documentar desvios em tempo real no ADR
    
- Realizar snapshot incremental após cada fase
    

## 2. Médio Prazo (30-60 dias)

- Migrar para **Integrated Storage (Raft)** para experiência com HA[](https://developer.hashicorp.com/vault/docs/internals/integrated-storage)
    
- Implementar Auto Unseal com AWS KMS ou Azure Key Vault[](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)​
    
- Configurar backup automatizado do storage backend[](https://stackoverflow.com/questions/71742759/hashicrop-vault-backup-with-file-backend)​
    
- Estabelecer processo de key rotation (`vault operator rekey`)[](https://inventivehq.com/hashicorp-vault-rekey-or-unseal-vault/)​
    

## 3. Longo Prazo (90+ dias)

- Integrar Vault com pipeline CI/CD para secrets injection
    
- Implementar Dynamic Secrets para database credentials
    
- Configurar replicação Enterprise (DR + Performance Replication)[](https://developer.hashicorp.com/vault/docs/internals/integrated-storage)​
    
- Estabelecer programa de auditoria contínua com base nos logs[](https://info-savvy.com/iso-27001-annex-a-10-cryptography/)​
    

---

## Conclusão

A experiência com a implementação inicial do HashiCorp Vault, apesar dos **desafios significativos** (desvio de +171% no cronograma), proporcionou aprendizados valiosos sobre:

1. **Limitações Críticas de IA:** Dependência exclusiva de assistentes IA para decisões de segurança resulta em vulnerabilidades sistêmicas[](https://inventivehq.com/blog/hashicorp-vault-rekey-unseal-complete-security-guide)
    
2. **Importância de Documentação Oficial:** Validação cruzada com fontes oficiais é controle obrigatório para tecnologias de segurança[](https://developer.hashicorp.com/vault/docs/configuration/storage/raft)
    
3. **Valor de IaC:** Infrastructure as Code como documentação viva e auditável[](https://www.addwebsolution.com/blog/terraform-tips-for-infrastructure-automation)
    
4. **Gestão de Chaves Criptográficas:** Compreensão profunda de Shamir's Secret Sharing e controles ISO 27001 A.10[](https://docs.devnetexperttraining.com/static-docs/HashiCorp-Vault/docs/concepts/seal/)
    
5. **Controles Compensatórios:** Processo Human-in-the-loop transforma riscos em oportunidades de aprendizado estruturado
    

**Retrospectiva:** Falhar rápido em ambiente controlado é **preferível** a implementar inseguramente em produção. O retrabalho, embora custoso (12h), resultou em:

- Compreensão profunda da arquitetura de segurança do Vault[](https://developer.hashicorp.com/vault/docs/configuration/storage/raft)
    
- Base sólida para próximas fases do PRJ007
    
- Processos auditáveis alinhados com ISO 27001[](https://hightable.io/iso27001-annex-a-8-24-use-of-cryptography/)
    
- Maturidade no uso de assistentes IA para infraestrutura crítica
    

Este documento serve como:

- **Caso de estudo** para entrevistas técnicas em posições de segurança
    
- **Evidência objetiva** de capacidade de aprendizagem estruturada
    
- **Referência técnica** para futuras implementações do Vault
    
- **Artefato de conformidade** para auditorias ISO 27001
    

---

## Aprovações

|Role|Nome|Assinatura|Data|
|---|---|---|---|
|**Tech Lead**||||
|**Security Officer**||||
|**Project Manager**||||

---

**Versão:** 2.0 (Revisada)  
**Data de Arquivamento:** 04/02/2026  
**Localização:** `/PRJ007/docs/lessons-learned/001-vault-implementation-v2.md`  
**Classificação:** Interno - Lições Aprendidas  
**Próxima Revisão:** 04/05/2026 (após implementação completa)

---

**Changelog:**

- **v1.0 (04/02/2026 14:25):** Versão inicial com análise básica
    
- **v2.0 (04/02/2026 14:49):** Incorporação de feedback Gemini + DeepSeek:
    
    - Adição de L7 (Human-in-the-loop validation)
        
    - Comparação técnica File vs Raft Storage[](https://developer.hashicorp.com/vault/docs/internals/integrated-storage)
        
    - Valor pedagógico do Unseal Manual[](https://notes.kodekloud.com/docs/HashiCorp-Certified-Vault-Associate-Certification/Learning-the-Vault-Architecture/Unsealing-with-Key-Shards)
        
    - Validação de conectividade DNS na Fase 1
        
    - Problema #4: Exposição de credenciais hardcoded
        
    - Alinhamento com ISO 27001 Annex A.10[](https://hightable.io/iso27001-annex-a-8-24-use-of-cryptography/)
        
    - Template ADR para validação de sugestões IA