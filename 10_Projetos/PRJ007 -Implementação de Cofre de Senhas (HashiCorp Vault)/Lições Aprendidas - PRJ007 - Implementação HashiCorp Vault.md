
---

# 

**Projeto:** PRJ007 - Integração OrangeHRM + MidPoint  
**Data:** 04 de Fevereiro de 2026  
**Fase:** Infraestrutura de Segurança - Gestão de Segredos  
**Responsável:** [Seu Nome]

---

## Contexto Executivo

Durante a implementação do PRJ007, inicialmente planejamos criar uma API de integração personalizada para conectar OrangeHRM ao MidPoint. Após análise, identificamos que essa abordagem introduziria mais um hardcode no sistema, aumentando a dívida técnica. A decisão estratégica foi priorizar a instalação do HashiCorp Vault para gestão centralizada de credenciais e segredos.[developer.hashicorp+2](https://developer.hashicorp.com/vault/install)

Para acelerar o aprendizado e aproveitar a automação de infraestrutura, optamos por provisionar o Vault utilizando Terraform. Durante o processo, utilizamos assistência de IA (Gemini) que conduziu a uma implementação insegura e não funcional.[[addwebsolution](https://www.addwebsolution.com/blog/terraform-tips-for-infrastructure-automation)]​

---

## Decisões Arquiteturais

## Decisão 1: Priorização do Vault sobre API Hardcoded

**Contexto:** Necessidade de integrar OrangeHRM com MidPoint  
**Decisão:** Implementar HashiCorp Vault antes de desenvolver APIs de integração  
**Rationale:** Evitar hardcoding de credenciais e estabelecer arquitetura de segredos desde o início[developer.hashicorp+1](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)

## Decisão 2: Automação com Terraform

**Contexto:** Equipe em curva de aprendizado com múltiplas tecnologias  
**Decisão:** Utilizar Infrastructure as Code (IaC) com Terraform para provisionar Vault  
**Rationale:** Documentar a infraestrutura como código, permitir reprodutibilidade e acelerar futuros deployments[atmosly+1](https://atmosly.com/blog/top-10-terraform-best-practices-for-infrastructure-automation)

## Decisão 3: Deployment via Docker Compose

**Contexto:** Ambiente de laboratório com recursos limitados  
**Decisão:** Utilizar container Docker com armazenamento persistente em arquivo  
**Rationale:** Simplicidade operacional e isolamento do serviço[hub.docker+1](https://hub.docker.com/_/vault)

---

## Problemas Identificados

## 1. Orientação Insegura do Assistente IA

**Problema:** O Gemini conduziu a implementação por um "caminho árduo sem segurança"  
**Impacto:** Perda de tempo, exposição potencial de segredos, instalação não funcional

**Falhas Específicas:**

- Sugestões que não seguiram as práticas de production hardening da HashiCorp[[developer.hashicorp](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)]​
    
- Configurações inadequadas para o processo de unseal[developer.hashicorp+1](https://developer.hashicorp.com/vault/docs/commands/operator/init)
    
- Falta de orientação sobre armazenamento seguro das unseal keys[inventivehq+1](https://inventivehq.com/blog/hashicorp-vault-rekey-unseal-complete-security-guide)
    
- Deployment que não inicializou corretamente o Vault
    

## 2. Gestão Inadequada de Unseal Keys

**Problema:** Planejamento de armazenar unseal keys em SECRETS.md (arquivo de texto)  
**Impacto Potencial:** Violação crítica de segurança[developer.hashicorp+1](https://developer.hashicorp.com/vault/docs/concepts/seal)

**Contexto Técnico:**

- Vault utiliza Shamir's Secret Sharing para dividir a root key em múltiplos shards[[developer.hashicorp](https://developer.hashicorp.com/vault/docs/commands/operator/init)]​
    
- As unseal keys são necessárias para reconstruir a root key e descriptografar a encryption key[[developer.hashicorp](https://developer.hashicorp.com/vault/docs/concepts/seal)]​
    
- Armazenar estas chaves em texto plano anula completamente o modelo de segurança do Vault[notes.kodekloud+1](https://notes.kodekloud.com/docs/HashiCorp-Certified-Vault-Associate-Certification/Learning-the-Vault-Architecture/Seal-and-Unseal)
    

## 3. Falta de Validação da Abordagem

**Problema:** Seguir orientações do assistente IA sem validar contra documentação oficial  
**Impacto:** Retrabalho completo e potencial comprometimento de segurança

---

## Lições Aprendidas

## L1: Validação Crítica para Segurança

**Lição:** Assistentes de IA não devem ser fonte única de verdade para implementações de segurança

**Ação Corretiva:**

- Sempre validar configurações de segurança contra documentação oficial da HashiCorp[developer.hashicorp+1](https://developer.hashicorp.com/vault/install)
    
- Consultar múltiplas fontes para decisões críticas de arquitetura
    
- Implementar checklist de security hardening antes do deployment[[developer.hashicorp](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)]​
    

**Aplicação Futura:**

- Estabelecer processo de peer review antes de implementar sugestões de IA
    
- Manter biblioteca de referências oficiais para tecnologias críticas
    

## L2: Gestão Apropriada de Unseal Keys

**Lição:** Unseal keys são equivalentes às chaves do cofre e requerem proteção máxima[gitguardian+1](https://www.gitguardian.com/remediation/hashicorp-vault-unseal-key)

**Práticas Corretas:**

- **Nunca** armazenar unseal keys em arquivos de texto, repositórios Git ou sistemas de notas[[gitguardian](https://www.gitguardian.com/remediation/hashicorp-vault-unseal-key)]​
    
- Utilizar PGP encryption para proteger as keys durante a distribuição[[developer.hashicorp](https://developer.hashicorp.com/vault/docs/commands/operator/init)]​
    
- Distribuir shares entre múltiplos key holders em organizações (princípio de separação de deveres)[[inventivehq](https://inventivehq.com/blog/hashicorp-vault-rekey-unseal-complete-security-guide)]​
    
- Para ambientes de laboratório: considerar Auto Unseal com cloud KMS ou file-based encryption[[developer.hashicorp](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)]​
    
- Implementar processo de key rotation periódico (vault operator rekey)[[inventivehq](https://inventivehq.com/hashicorp-vault-rekey-or-unseal-vault/)]​
    

**Implementação PRJ007:**

- Utilizar Auto Unseal para ambiente de desenvolvimento/lab
    
- Documentar apenas o método de recuperação, não as keys propriamente ditas
    
- Considerar Transit Secrets Engine para operações de criptografia[[developer.hashicorp](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)]​
    

## L3: Terraform como Documentação Viva

**Lição:** IaC não é apenas automação, é documentação executável da infraestrutura[atmosly+1](https://atmosly.com/blog/top-10-terraform-best-practices-for-infrastructure-automation)

**Benefícios Realizados:**

- Configuração versionada e auditável
    
- Capacidade de destruir e recriar ambiente rapidamente
    
- Documentação sempre sincronizada com estado real
    

**Melhorias Necessárias:**

- Modularizar configurações Terraform para reutilização[[atmosly](https://atmosly.com/blog/top-10-terraform-best-practices-for-infrastructure-automation)]​
    
- Implementar Terraform remote state para colaboração[[addwebsolution](https://www.addwebsolution.com/blog/terraform-tips-for-infrastructure-automation)]​
    
- Adicionar testes de validação (terraform validate, tflint) no pipeline[[atmosly](https://atmosly.com/blog/top-10-terraform-best-practices-for-infrastructure-automation)]​
    

## L4: Priorização de Production Hardening

**Lição:** Mesmo em ambiente de lab, seguir production best practices acelera aprendizado correto[[developer.hashicorp](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)]​

**Práticas Essenciais Vault:**

- Habilitar Audit Device desde o início[[inventivehq](https://inventivehq.com/blog/hashicorp-vault-rekey-unseal-complete-security-guide)]​
    
- Configurar TLS mesmo em redes privadas (Tailscale)[[developer.hashicorp](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)]​
    
- Implementar princípio de least privilege nas políticas RBAC[[inventivehq](https://inventivehq.com/blog/hashicorp-vault-rekey-unseal-complete-security-guide)]​
    
- Ativar log rotation e monitoring[[atmosly](https://atmosly.com/blog/top-10-terraform-best-practices-for-infrastructure-automation)]​
    
- Separar root token usage de operational tokens[[developer.hashicorp](https://developer.hashicorp.com/vault/docs/commands/operator/init)]​
    

## L5: Iteração Rápida em Ambientes Controlados

**Lição:** Snapshot de VMs desligadas permite experimentação sem risco permanente

**Estratégia Aplicada:**

- Criar snapshot antes de mudanças significativas
    
- Testar configurações em ambiente isolado (Tailscale mesh)
    
- Documentar cada iteração para evitar repetir erros
    
- Utilizar containers para isolamento adicional[virtualizationhowto+1](https://www.virtualizationhowto.com/2025/01/hashicorp-vault-docker-install-steps-kubernetes-not-required/)
    

## L6: Assistentes IA como Aceleradores, Não Arquitetos

**Lição:** IA é excelente para scaffolding inicial, não para decisões arquiteturais de segurança

**Uso Apropriado:**

- ✅ Gerar boilerplate de código Terraform
    
- ✅ Sugerir estrutura inicial de docker-compose.yml
    
- ✅ Explicar conceitos e comandos
    
- ❌ Definir arquitetura de segurança
    
- ❌ Configurar políticas de acesso sem validação
    
- ❌ Implementar fluxos críticos sem supervisão humana
    

---

## Impacto no Cronograma

|Fase|Tempo Estimado|Tempo Real|Desvio|
|---|---|---|---|
|Pesquisa e Planejamento|2h|1h|-50%|
|Implementação Inicial|4h|8h|+100%|
|Troubleshooting|1h|6h|+500%|
|Reimplementação Correta|-|4h|N/A|
|**Total**|**7h**|**19h**|**+171%**|

**Análise:** O uso inadequado de assistente IA causou 12h de retrabalho. Investimento inicial em validação teria economizado 8-10h do projeto.

---

## Plano de Ação Daily Scrum Revisado

## Fase 1: Provisionamento (30 min)

-  Criar VM `vault-gf-01` no Hyper-V (2 vCPU, 2GB RAM, 20GB disco)
    
-  Instalar Docker e Docker Compose
    
-  Configurar Tailscale e validar conectividade com malha existente
    

## Fase 2: Deployment Seguro (45 min)

-  Criar `docker-compose.yml` baseado em exemplo oficial HashiCorp[hub.docker+1](https://hub.docker.com/_/vault)
    
-  Criar `vault-config.hcl` com TLS e file storage backend[[developer.hashicorp](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)]​
    
-  Iniciar container: `docker-compose up -d`
    
-  Validar logs: `docker logs vault`
    

## Fase 3: Inicialização (30 min)

-  Executar `vault operator init -key-shares=5 -key-threshold=3`[[developer.hashicorp](https://developer.hashicorp.com/vault/docs/commands/operator/init)]​
    
-  **CRÍTICO:** Implementar Auto Unseal ou PGP encryption para keys[developer.hashicorp+1](https://developer.hashicorp.com/vault/docs/commands/operator/init)
    
-  Executar unseal inicial com threshold de keys[[developer.hashicorp](https://developer.hashicorp.com/vault/docs/concepts/seal)]​
    
-  Autenticar com root token temporário
    

## Fase 4: Configuração Base (60 min)

-  Habilitar KV Secrets Engine v2: `vault secrets enable -version=2 kv`
    
-  Criar políticas RBAC: admin, midpoint, api-proxy[[inventivehq](https://inventivehq.com/blog/hashicorp-vault-rekey-unseal-complete-security-guide)]​
    
-  Gerar tokens renováveis para cada política
    
-  Habilitar Audit Device: `vault audit enable file file_path=/vault/logs/audit.log`[[inventivehq](https://inventivehq.com/blog/hashicorp-vault-rekey-unseal-complete-security-guide)]​
    

## Fase 5: Migração de Segredos (45 min)

-  Migrar credenciais OrangeHRM para `kv/orangehrm/*`
    
-  Migrar credenciais MidPoint para `kv/midpoint/*`
    
-  Testar acesso com tokens específicos
    
-  Validar audit logs
    

## Fase 6: Integração (90 min)

-  Desenvolver script Bash para consumo de segredos
    
-  Implementar biblioteca Python com `hvac` e auto-renewal
    
-  Configurar rotação automática de tokens
    
-  Documentar fluxo de recuperação de secrets
    

## Fase 7: Governança (30 min)

-  Configurar log rotation para audit device
    
-  Documentar procedimento de unseal para DR
    
-  Criar runbook para operações comuns
    
-  Realizar snapshot final com VMs desligadas
    

## Fase 8: Post-Mortem (30 min)

-  Consolidar este documento de Lições Aprendidas
    
-  Atualizar documentação do PRJ007
    
-  Compartilhar learnings com equipe
    
-  Arquivar configurações Terraform no repositório
    

**Tempo Total Revisado:** ~6 horas (vs. 19h da tentativa anterior)

---

## Referências Técnicas

## Documentação Oficial

- HashiCorp Vault Installation Guide[[developer.hashicorp](https://developer.hashicorp.com/vault/install)]​
    
- Production Hardening Checklist[[developer.hashicorp](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)]​
    
- Operator Init Command Reference[[developer.hashicorp](https://developer.hashicorp.com/vault/docs/commands/operator/init)]​
    
- Seal/Unseal Architecture[[developer.hashicorp](https://developer.hashicorp.com/vault/docs/concepts/seal)]​
    

## Security Best Practices

- Vault Security Best Practices[[inventivehq](https://inventivehq.com/blog/hashicorp-vault-rekey-unseal-complete-security-guide)]​
    
- Unseal Key Management[inventivehq+1](https://inventivehq.com/hashicorp-vault-rekey-or-unseal-vault/)
    
- RBAC Implementation Guide[[inventivehq](https://inventivehq.com/blog/hashicorp-vault-rekey-unseal-complete-security-guide)]​
    

## Terraform & IaC

- Terraform Best Practices for Infrastructure Automation[addwebsolution+1](https://www.addwebsolution.com/blog/terraform-tips-for-infrastructure-automation)
    
- Deploying Vault with Terraform[digitalocean+1](https://www.digitalocean.com/community/tutorials/how-to-build-a-hashicorp-vault-server-using-packer-and-terraform-on-digitalocean)
    

## Docker Deployment

- Official Vault Docker Image[[hub.docker](https://hub.docker.com/_/vault)]​
    
- Vault Docker Install Steps[[virtualizationhowto](https://www.virtualizationhowto.com/2025/01/hashicorp-vault-docker-install-steps-kubernetes-not-required/)]​
    

---

## Próximos Passos

1. **Implementação Imediata:**
    
    - Seguir Daily Scrum revisado com validação em cada etapa
        
    - Documentar desvios em tempo real
        
    - Realizar snapshot incremental após cada fase
        
2. **Médio Prazo:**
    
    - Migrar para Auto Unseal com AWS KMS ou Azure Key Vault[[developer.hashicorp](https://developer.hashicorp.com/vault/docs/concepts/production-hardening)]​
        
    - Implementar HA (High Availability) com múltiplos nós Vault
        
    - Configurar backup automatizado do storage backend
        
3. **Longo Prazo:**
    
    - Integrar Vault com pipeline CI/CD
        
    - Implementar Dynamic Secrets para database credentials
        
    - Estabelecer processo de key rotation automático
        

---

## Conclusão

A experiência com a implementação inicial do HashiCorp Vault, apesar dos desafios, proporcionou aprendizados valiosos sobre:

- Limitações e riscos de depender exclusivamente de assistentes IA para decisões críticas de segurança
    
- Importância de seguir documentação oficial para tecnologias de segurança
    
- Valor de Infrastructure as Code como documentação viva
    
- Necessidade de processos robustos para gestão de segredos
    

O retrabalho, embora custoso em tempo, resultou em compreensão profunda da arquitetura do Vault e estabeleceu base sólida para as próximas fases do PRJ007.[addwebsolution+2](https://www.addwebsolution.com/blog/terraform-tips-for-infrastructure-automation)

**Retrospectiva:** Falhar rápido em ambiente controlado é preferível a implementar inseguramente em produção. Este documento serve como guia para futuras implementações e demonstra maturidade no processo de aprendizado da equipe.

---

**Aprovação:**  
[ ] Tech Lead  
[ ] Security Officer  
[ ] Project Manager

**Data de Arquivamento:** 04/02/2026  
**Localização:** `/PRJ007/docs/lessons-learned/001-vault-implementation.md`