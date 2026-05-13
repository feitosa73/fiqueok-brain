# -v1.0.md

## Termo de Abertura do Projeto — PRJ021

---

| **Campo**             | **Valor**                                               |
| --------------------- | ------------------------------------------------------- |
| **Código do Projeto** | PRJ021                                                  |
| **Nome do Projeto**   | DevSecOps Pipeline — GitLab Self-Managed para SAST/DAST |
| **Versão**            | 1.0                                                     |
| **Data de Abertura**  | 24/04/2026                                              |
| **Responsável**       | Paulo Feitosa Lima — GRC Lead                           |
| **Patrocinador**      | Living Lab Fiqueok                                      |
| **Classificação**     | CONFIDENCIAL — Dados Técnicos e de Auditoria            |

---

## 1. OBJETIVOS DO PROJETO

|ID|Objetivo|Critério de Sucesso|
|---|---|---|
|OBJ-01|Implementar GitLab Self-Managed em VM dedicada|Acesso via `https://gitlab.fiqueok.com.br` (Tailscale)|
|OBJ-02|Estabelecer pipeline CI/CD para projetos de automação|Build automático ao fazer push no repositório|
|OBJ-03|Habilitar SAST nos pipelines de PRJ019, PRJ008, PRJ016|Detecção automática de vulnerabilidades no código|
|OBJ-04|Habilitar DAST nos pipelines (APIs expostas)|Scan automático de endpoints em ambiente de teste|
|OBJ-05|Integrar GitLab com HashiCorp Vault para gestão de segredos|Variáveis de ambiente buscadas do Vault, não hardcoded|
|OBJ-06|Substituir auditorias manuais de segurança|Pipeline falha se SAST encontrar critical/high issues|

---

## 2. ESCOPO

### 2.1. Dentro do Escopo

|Item|Descrição|
|---|---|
|**GitLab Self-Managed**|VM Ubuntu 24.04 GEN1, Omnibus package, porta 443 (Tailscale)|
|**Projetos alvo**|PRJ019 (API ingestor), PRJ008 (Shadow API), PRJ016 (scripts automação)|
|**SAST**|Análise estática (Python, JavaScript, Go — conforme linguagem)|
|**DAST**|OWASP ZAP integrado via GitLab DAST template|
|**SCA**|Dependency Scanning (pip, npm)|
|**Container Scanning**|Trivy para imagens Docker construídas no pipeline|
|**Vault Integration**|CI_JOB_JWT_V2 para autenticação sem tokens estáticos|
|**Pipeline as Code**|`.gitlab-ci.yml` em cada repositório|

### 2.2. Fora do Escopo

|Item|Justificativa|
|---|---|
|**Migração de repositórios existentes**|Apenas novos projetos começam no GitLab|
|**Substituição do Obsidian**|Documentação permanece no Obsidian|
|**Gerenciamento de VMs existentes**|GitLab gerencia apenas seus pipelines, não as VMs alvo|
|**Hardening avançado do GitLab**|Configuração padrão, hardening futuro em PRJ incremental|

---

## 3. ARQUITETURA DECIDIDA

### 3.1. Justificativa da Escolha: GitLab Self-Managed

|Critério|Decisão|Justificativa|
|---|---|---|
|**Plataforma**|GitLab Self-Managed|Sem lock-in, SAST/DAST nativos, comunidade ativa|
|**Forma**|VM GEN1 (Ubuntu 24.04)|Respeita CONSTRAINT-001, overhead controlado|
|**Acesso**|Tailscale + certificado auto-assinado|Zero trust, sem exposição à internet|
|**Backup**|Script manual via `gitlab-backup`|PRJ futuro pode automatizar|

### 3.2. Topologia

text

Host Físico (Hyper-V)
│
├── VM: GITLAB-GF-01 (NOVA)
│   ├── Ubuntu 24.04 LTS (GEN1)
│   ├── CPU: 2 vCPU
│   ├── RAM: 6 GB
│   ├── Disco: 40 GB (raiz) + 20 GB (dados Git)
│   ├── Tailscale IP: 100.64.0.x
│   └── URL: https://gitlab.fiqueok.com.br
│
├── Repositórios
│   ├── prj019-ingestor (Python/FastAPI)
│   ├── prj008-shadow-api (Python/FastAPI)
│   └── prj016-scripts (Bash/Python)
│
└── Integração
    ├── Vault (PRJ007) → CI_JOB_JWT_V2
    └── Runner → Docker executor (local)

### 3.3. Pipeline Template Base

yaml

# .gitlab-ci.yml (template para projetos PRJ019/008)
stages:
  - test
  - sast
  - dast
  - container-scan
  - deploy
variables:
  DOCKER_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
# SAST (GitLab nativo)
include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Dependency-Scanning.gitlab-ci.yml
  - template: Security/Container-Scanning.gitlab-ci.yml
# DAST (APIs)
dast:
  stage: dast
  image: registry.gitlab.com/gitlab-org/security-products/dast:latest
  script:
    - /analyze -t http://$CI_ENVIRONMENT_URL
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
# Vault integration
before_script:
  - export VAULT_TOKEN=$(vault write -field=token auth/jwt/login role=gitlab jwt=$CI_JOB_JWT_V2)

---

## 4. REQUISITOS TÉCNICOS

### 4.1. Infraestrutura (Nova VM)

|Recurso|Especificação|Status|Justificativa|
|---|---|---|---|
|**VM**|Ubuntu 24.04 LTS, GEN1|✅ Disponível|Respeita CONSTRAINT-001|
|**vCPU**|2|✅ Disponível|Mínimo recomendado GitLab|
|**RAM**|6 GB|✅ Dentro da margem|4 GB mínimo, 6 GB para conforto|
|**Disco**|60 GB (40+20)|✅ Disponível|40 GB OS, 20 GB dados Git|
|**Tailscale**|IP fixo|✅ Configurável|Acesso seguro|

**Impacto na margem de RAM:** 18 GB → 12 GB restantes (após PRJ021)

### 4.2. Dependências de Projetos Existentes

|Dependência|Projeto|Status|Ação|
|---|---|---|---|
|**Vault JWT Auth**|PRJ007|🔴 Pendente|Configurar `auth/jwt` no Vault|
|**CI_JOB_JWT_V2**|GitLab|✅ Nativo|Disponível em GitLab 15.0+|
|**Docker Registry**|GitLab|✅ Nativo|Container registry incluso|
|**Tailscale DNS**|Lab|✅ Ativo|`gitlab.fiqueok.com.br` a criar|

### 4.3. Configuração Vault para GitLab

hcl

# vault policy: gitlab-ci
path "secret/data/gitlab/*" {
  capabilities = ["read"]
}
# JWT auth configuration
vault write auth/jwt/config \
    bound_issuer="https://gitlab.fiqueok.com.br" \
    oidc_discovery_url="https://gitlab.fiqueok.com.br" \
    default_role="gitlab"
vault write auth/jwt/role/gitlab \
    bound_audiences="https://gitlab.fiqueok.com.br" \
    user_claim="sub" \
    policies="gitlab-ci" \
    ttl=15m

---

## 5. CRONOGRAMA ESTIMADO

|Fase|Atividade|Período|Dependência|
|---|---|---|---|
|**Fase 1**|Provisionar VM (Hyper-V) + Ubuntu 24.04|0.5 dia|CONSTRAINT-001 respeitada|
|**Fase 2**|Instalar GitLab Omnibus + configuração inicial|1 dia|Fase 1|
|**Fase 3**|Configurar Tailscale + certificado + domínio|0.5 dia|Fase 2|
|**Fase 4**|Configurar Vault JWT auth + integração|0.5 dia|PRJ007|
|**Fase 5**|Criar pipelines de exemplo (PRJ019, PRJ008)|1 dia|Fase 4|
|**Fase 6**|Testar SAST/DAST com vulnerabilidades controladas|1 dia|Fase 5|
|**Fase 7**|Documentar POP (criação de novos projetos)|0.5 dia|Fase 6|
|**Duração total**|**5 dias**|—|—|

**Observação:** PRJ021 pode rodar em paralelo com PRJ019. Não há dependência bloqueante.

---

## 6. RISCOS E MITIGAÇÕES

|ID|Risco|Prob.|Impacto|Mitigação|
|---|---|---|---|---|
|R01|CONSTR AINT-001 impede VM GEN2|Alta|Médio|PROJ021 usa GEN1 (testado no PRJ007)|
|R02|RAM insuficiente (6 GB para GitLab)|Baixa|Alto|Monitoramento; ajuste de `gitald` concurrency|
|R03|SSL/TLS com certificado auto-assinado|Médio|Baixo|Uso exclusivo via Tailscale (rede confiável)|
|R04|Vault JWT configurado incorretamente|Média|Médio|Teste com `vault write` antes do pipeline|
|R05|DAST danificar ambiente de produção|Baixa|Alto|DAST executa apenas em ambiente de teste (staging)|
|R06|Pipeline vazar segredos|Baixa|Alto|Variáveis protegidas + linting do `.gitlab-ci.yml`|

---

## 7. ENTREGÁVEIS PREVISTOS

|ID|Entregável|Formato|Localização|
|---|---|---|---|
|E01|VM `GITLAB-GF-01` provisionada|Hyper-V|Host físico|
|E02|GitLab acessível em `https://gitlab.fiqueok.com.br`|URL|Tailscale|
|E03|Repositório `prj019-ingestor` com pipeline SAST|`.gitlab-ci.yml`|GitLab|
|E04|Integração Vault validada|Documentação|`PRJ021/integration/`|
|E05|Relatório de scan SAST em PRJ019 (baseline)|JSON|`PRJ021/reports/`|
|E06|POP-PRJ021-001 (criação de novos projetos no GitLab)|Markdown|`10_Projetos/PRJ021/`|
|E07|TEP-PRJ021|Markdown|`00_Gestao_do_Projeto/`|

---

## 8. CRITÉRIOS DE ACEITE (DEFINIÇÃO DE PRONTO)

- Acesso via `https://gitlab.fiqueok.com.br` funcionando (Tailscale)
    
- CI/CD pipeline executa SAST em PRJ019 e reporta resultados
    
- Pipeline falha se SAST encontrar vulnerabilidade CRITICAL ou HIGH
    
- DAST executa contra API de teste e gera relatório
    
- Vault injeta variáveis no pipeline sem tokens hardcoded
    
- Container Scanning detecta CVEs em imagens Docker
    
- Backup manual (`gitlab-backup`) documentado
    
- POP de onboarding de novos projetos publicado
    

---

## 9. SUCESSORES IDENTIFICADOS

|Projeto|Descrição|Dependência|
|---|---|---|
|PRJ022|Automação de backup do GitLab (cron + offsite)|PRJ021|
|PRJ023|Hardening do GitLab (TLS, Security Headers, MFA)|PRJ021|
|PRJ024|Integração com DefectDojo (PRJ020) para tracking de findings|PRJ020, PRJ021|
|PRJ025|Runner Kubernetes (k3s) para escalabilidade|Opcional|

---

## 10. RELAÇÃO COM PRJ019

|Relação|Descrição|Bloqueante?|
|---|---|---|
|PRJ019 → PRJ021|PRJ019 pode iniciar sem SAST (controles manuais)|❌ Não|
|PRJ021 → PRJ019|PRJ021 adicionará pipeline de segurança ao PRJ019 após conclusão|❌ Não|
|**Modelo de execução**|Paralelo — PRJ019 entrega valor imediato; PRJ021 adiciona segurança|—|

---

## 11. APROVAÇÕES

|Função|Nome|Data|Status|
|---|---|---|---|
|GRC Lead / Responsável|Paulo Feitosa Lima|24/04/2026|✅ APROVADO|
|Arquiteto de Soluções|Paulo Feitosa Lima|24/04/2026|✅ APROVADO|

---

**FIM DO TERMO DE ABERTURA DO PROJETO — PRJ021 v1.0**

📄 **Documento salvo como:** `TAP-PRJ021-v1.0.md`  
📁 **Localização:** `10_Projetos/PRJ021/00_Gestao_do_Projeto/`  
🔒 **Classificação:** CONFIDENCIAL

---

## 📋 RESUMO DOS DOIS TAPS

|Projeto|Objetivo|Prioridade|Dependência|Pipeline de segurança|
|---|---|---|---|---|
|**PRJ019**|Automação Obsidian → AnythingLLM|Alta (entrega valor imediato)|PRJ007 (Vault)|Manual (controles manuais)|
|**PRJ021**|DevSecOps Pipeline (GitLab)|Média (adiciona segurança)|PRJ007 (Vault)|Automático (SAST/DAST/SCA)|
