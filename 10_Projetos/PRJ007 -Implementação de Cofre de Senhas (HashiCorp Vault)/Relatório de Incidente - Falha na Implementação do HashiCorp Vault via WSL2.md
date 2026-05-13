
## Resumo Executivo

A tentativa de implementação do HashiCorp Vault em ambiente WSL2 (Ubuntu 22.04) via Docker foi **abortada** após múltiplas falhas técnicas e violações de princípios de segurança. O projeto retornará ao estado Greenfield (backup de 2.2GB) conforme protocolo de Disaster Recovery Plan (ISO 27001 A.12.3.1).[github+1](https://github.com/docker/for-win/issues/4646)

---

## 🔍 Análise Técnica dos Problemas Identificados

## 1. Violações Críticas de Segurança

A assistente Gemini sugeriu aplicar permissões **chmod 777** em diretórios sensíveis (`~/vault/data` e `~/vault/logs`), o que representa:

- **Quebra do princípio de Least Privilege**: Permissões globais (rwxrwxrwx) expõem dados criptográficos a todos os usuários do sistema
    
- **Não conformidade com ISO 27001**: Controles A.9.4.1 (Restrição de Acesso à Informação) e A.10.1.2 (Gerenciamento de Chaves) comprometidos
    
- **Risco de exposição de segredos**: Chaves mestras e tokens de unseal acessíveis por processos não autorizados
    

Essa recomendação foi corretamente rejeitada pelo auditor responsável, aplicando o **Stop Work Authority** conforme práticas de GRC (Governance, Risk and Compliance).

## 2. Problema Técnico de Compatibilidade WSL2

O container apresentou status **"Restarting (1)"** persistente, indicando falha crítica na inicialização. A causa raiz identificada:

- **File Locking no Raft Storage**: O backend Raft do Vault requer operações de bloqueio de arquivo (file locking) para garantir integridade transacional do banco de dados[github+1](https://github.com/hashicorp/vault/issues/21096)
    
- **Limitação do WSL2**: O kernel WSL2 com volumes Docker mapeados via paths relativos (`./data`) ou montagens Windows (`/mnt/c/...`) falha em processar chamadas de sistema de baixo nível necessárias para file locking[docker+1](https://forums.docker.com/t/permissions-issue-writing-to-docker-volume-inside-wsl2-filesystem/129510)
    
- **Incompatibilidade conhecida**: Problemas documentados na comunidade HashiCorp sobre permissões e inicialização do Raft em ambientes WSL2[forums.docker+1](https://forums.docker.com/t/wsl2-host-folder-mount-permissions-spontaneously-change-during-session/144057)
    

## 3. Análise de Vulnerabilidades Incompleta

Embora a Gemini tenha mencionado a **CVE-2025-12044** no relatório de Threat Intelligence, a implementação não incluiu:

- **Validação proativa da versão**: A CVE-2025-12044 afeta Vault 1.20.3-1.20.4 (Community) e versões Enterprise específicas, com correção disponível em **Vault 1.21.0**[radar.offseq+1](https://radar.offseq.com/threat/cve-2025-12044-cwe-770-allocation-of-resources-wit-3b1e9a44)
    
- **DoS não autenticado**: Vulnerabilidade crítica de negação de serviço via payloads JSON maliciosos que consomem CPU/memória antes da aplicação de rate limiting[[radar.offseq](https://radar.offseq.com/threat/cve-2025-12044-cwe-770-allocation-of-resources-wit-3b1e9a44)]​
    
- **Cadeia de Zero-Days**: Seis CVEs descobertas em agosto de 2025, incluindo RCE crítico (CVE-2025-6000, CVSS 9.1) não foram adequadamente contextualizadas para o ambiente de produção
    

A recomendação da versão 1.21.0 foi correta, mas a implementação falhou na execução.

---

## 📊 Evidências do Rollback

## Backup Validado

- **Arquivo**: `Ubuntu-22.04-Docker-Greenfield-2026-02-08_17-31.tar`
    
- **Tamanho**: 2.2 GB
    
- **Integridade**: Confirmada via comando `wsl --import` executado com sucesso
    
- **Estado**: Ubuntu 22.04 LTS + Docker Engine 29.2.1 (limpo, sem Vault)
    

## Comandos Executados

bash

`# Desregistro da instância comprometida wsl --unregister Ubuntu-22.04 # Restauração do Checkpoint Zero wsl --import Ubuntu-22.04 C:\Projetos\Fiqueok\Instancia_Restaurada C:\Projetos\Fiqueok\Ubuntu-22.04-Docker-Greenfield-2026-02-08_17-31.tar # Validação de acesso wsl -d Ubuntu-22.04 -u paulo`

Status: ✅ **Rollback concluído com sucesso**

---

## 🛡️ Recomendações para Próximas Iterações

## Alternativas Técnicas

1. **Instalação nativa no Ubuntu WSL2**: Em vez de Docker, instalar Vault diretamente no sistema operacional Linux com systemd (se disponível)[robearlam+1](https://robearlam.com/blog/running-hashicorp-vault-on-wsl2-secured-with-letsencrypt)
    
2. **Uso de volumes nomeados Docker**: Evitar bind mounts (`./data`) e utilizar volumes gerenciados pelo Docker Engine[hub.docker+1](https://hub.docker.com/r/hashicorp/vault)
    
3. **Migração para ambiente Linux nativo**: Considerar VM dedicada ou servidor bare-metal para produção, eliminando limitações do WSL2[[github](https://github.com/hashicorp/vault/issues/21096)]​
    

## Processo de Auditoria

- **Validação de vulnerabilidades**: Antes de qualquer deploy, verificar bulletins de segurança (HCSEC) da HashiCorp
    
- **Teste de permissões**: Implementar checklist de hardening baseado em NIST 800-123 e CIS Benchmarks
    
- **Documentação de incidentes**: Este caso serve como evidência para análise de riscos (ISO 27001 A.16.1.4)
    

---

## 📄 Decisão Final

O projeto **aborta** a implementação do HashiCorp Vault sob orientação da Gemini devido a:

1. Negligência em práticas de segurança (sugestão de chmod 777)
    
2. Incompatibilidade técnica não resolvida (WSL2 + Raft Storage)
    
3. Falha em análise prévia de CVEs críticas
    

A instância foi restaurada para o estado Greenfield e o projeto buscará suporte de outra assistente de IA para reavaliar a arquitetura de secrets management do Living Lab Fiqueok 2.0.

---

**Responsável pelo Rollback**: Paulo (Lead Auditor GRC/ISO 27001)  
**Data**: 08 de fevereiro de 2026, 19:23 (UTC-3)  
**Status do Projeto**: Greenfield restaurado, aguardando nova abordagem técnica
