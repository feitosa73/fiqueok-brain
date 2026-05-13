# 

## Nota de Alteração de Infraestrutura (NAI) — Gestão de Identidade de Rede

|**Campo**|**Valor**|
|---|---|
|**Documento Referência**|ARQ-PRJ008-Shadow-API-v2.1-FINAL|
|**Data da Alteração**|29/04/2026|
|**Status da Alteração**|🟢 **EXECUTADO**|
|**Responsável**|Paulo Feitosa Lima|
|**Motivo Principal**|Saneamento de conectividade e fim de colaboração externa|

---

## 1. RESUMO DA ALTERAÇÃO

Este adendo formaliza a remoção da **`tag:consultor`** das interfaces de rede das máquinas virtuais vinculadas ao **PRJ008** (especificamente a `api-gf-01`), restaurando o fluxo de comunicação via Tailscale entre a Shadow API e o **Sentinel-Core**.

## 2. JUSTIFICATIVA TÉCNICA E DE GRC

Originalmente, a `tag:consultor` foi implementada no documento **ARQ-PRJ008 v2.1** para prover acesso restrito ao colaborador externo Daniel, aplicando o princípio do menor privilégio (RBAC).

A manutenção atual fundamenta-se em:

- **Status do Projeto**: O PRJ008 encontra-se em estado **FROZEN** desde 14/04/2026.
    
- **Inatividade de Terceiros**: O compartilhamento de recursos com colaboradores externos não se realizou, tornando o controle de segregação por tag desnecessário para o contexto atual.
    
- **Correção de Assimetria de Rede**: A atribuição da tag gerou um "vácuo de permissões" (Default Deny), onde a VM `api-gf-01` perdia sua identidade de proprietário e era bloqueada de enviar telemetria (Egress) para o Sentinel-Core.
    

## 3. IMPACTO NO MODELO ZERO TRUST

Ao remover a tag, o dispositivo deixa de ser um "recurso isolado" e volta a ser identificado sob a identidade do proprietário (`feitosa.lima@gmail.com`), herdando as permissões globais de administração da Tailnet.

> **Nota de Auditoria**: O controle de microsegmentação documentado na V2.1 do projeto permanece válido como "prova de conceito" (PoC) de controles de IAM, mas foi desativado na produção para garantir a disponibilidade do monitoramento eBPF/Tetragon.

## 4. EVIDÊNCIAS DE EXECUÇÃO

Após a remoção da tag na console administrativa da Tailscale, os seguintes testes de conformidade foram validados:

1. **Conectividade ICMP**: `api-gf-01` → `sentinel-core` (xxx.xxx.xxx.xxx) — **0% packet loss**.
    
2. **Fluxo Promtail**: Envio de lotes de logs para o Loki via IP 100.x — **Sucesso (HTTP 200)**.
    
3. **Integridade de MTU**: Manutenção do padrão **1280 bytes** em todas as interfaces virtuais (Docker e Tailscale).
    

## 5. APROVAÇÃO E RASTREABILIDADE

Esta alteração foi registrada na memória de longo prazo do projeto para garantir que o histórico de "hardening" da Shadow API seja preservado para fins de portfólio e autoridade profissional.

---

**Documento vinculado ao Living Lab Fiqueok — 2026**

**Referência técnica: TEP-PRJ008-v1.0-FREEZING**
