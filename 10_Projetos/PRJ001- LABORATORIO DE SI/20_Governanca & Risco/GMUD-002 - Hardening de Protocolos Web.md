---
id_mudanca: GMUD-002
titulo: Hardening de Criptografia - Desativação de TLS 1.0/1.1
solicitante: GRC (Via RNC001)
responsavel_execucao: Operação (Paulo)
data_planejada: 2025-12-19
status: 🔵 Planejada
tipo: Normal
risco: Baixo
tags: #GMUD #Hardening #InfraCore
---

# 🛠️ GMUD-002: Hardening de Protocolos Web

## 1. Contexto e Justificativa
**Origem da Demanda:**
* Esta mudança visa atender ao **[[RNC001 - TLS Obsoleto na Infra Core]]**.
* Ação corretiva necessária para adequação à **ISO 27001 (A.8.24)** e mitigação de riscos de interceptação de dados (Man-in-the-Middle).

**Justificativa Técnica:**
O scan de vulnerabilidade (Ato 1) identificou que o servidor web central (`192.168.56.101`) aceita conexões via TLS 1.0 e 1.1. Estes protocolos são considerados inseguros pela indústria e devem ser desabilitados em favor do TLS 1.2 e 1.3.

## 2. Escopo da Mudança
* **Ativo Alvo:** Metasploitable (Servidor Web) / IP: `192.168.56.101`.
* **Serviço Afetado:** Apache Web Server (`apache2`).
* **Impacto Operacional:** Indisponibilidade momentânea do serviço web (segundos) durante o reinício do serviço.

## 3. Plano de Execução (Script Técnico)
1.  **Acesso:** Conectar via SSH ou Console na VM Metasploitable.
2.  **Backup:**
    `cp /etc/apache2/mods-available/ssl.conf /etc/apache2/mods-available/ssl.conf.bkp_gmud002`
3.  **Configuração:**
    * Editar arquivo: `nano /etc/apache2/mods-available/ssl.conf`
    * Localizar diretiva: `SSLProtocol`
    * Alterar para: `SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1`
4.  **Validação:** Executar `apache2ctl configtest` para verificar sintaxe.
5.  **Aplicação:** Reiniciar serviço: `/etc/init.d/apache2 restart`

## 4. Plano de Rollback
Caso o serviço web falhe em iniciar:
1.  Restaurar backup: `cp /etc/apache2/mods-available/ssl.conf.bkp_gmud002 /etc/apache2/mods-available/ssl.conf`
2.  Reiniciar serviço: `/etc/init.d/apache2 restart`

## 5. Aprovação
* **Aprovador:** GRC & Security Architecture
* **Parecer:** Aprovado. A mudança reduz significativamente a superfície de ataque sem impacto funcional previsto para o laboratório.