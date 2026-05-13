# Lições Aprendidas — PRJ007 v2.0
## HashiCorp Vault — Living Lab Fiqueok

---

| Campo | Valor |
|-------|-------|
| **Documento** | Lições Aprendidas PRJ007 |
| **Versão** | 2.0 — Atualização acumulada Fases 1 e 2 |
| **Data** | 18 de Abril de 2026 |
| **Responsável** | Paulo — Arquiteto de Segurança e Redes |
| **Baseado em** | Evidências coletadas em 18/04/2026 + documentação histórica do PRJ007 |

### Histórico de Versões

| Versão | Data | Descrição |
|--------|------|-----------|
| 1.0 | 04/02/2026 | Lições da Fase 1 — problemas com Terraform/IA, gestão de unseal keys |
| 2.0 | 18/04/2026 | Adição de lições da Fase 2: WSL2, GEN2, gap documental, política órfã, root token |

---

## Sumário

1. [Lições da Fase 1 — mantidas da v1.0](#lições-fase-1)
2. [Lições da Fase 2 — novas na v2.0](#lições-fase-2)
3. [Padrões positivos identificados](#padrões-positivos)
4. [Recomendações para projetos futuros](#recomendações)
5. [Métricas do projeto](#métricas)

---

## Lições Fase 1

*(Mantidas da v1.0 — 04/02/2026)*

### L1.1 — Assistentes de IA não substituem validação técnica em segurança

**O que aconteceu:** Durante a Fase 1, orientações do Gemini levaram a uma implementação insegura e não funcional do Vault via Terraform. A IA sugeriu armazenar unseal keys em `SECRETS.md` (arquivo de texto plano), o que anula completamente o modelo de segurança do Vault.

**Impacto:** Retrabalho completo. Potencial exposição de secrets antes da correção.

**Lição:** Assistentes de IA devem ser usados como aceleradores de produtividade, não como fontes únicas de verdade para implementações de segurança. Toda configuração crítica deve ser validada contra a documentação oficial do fabricante (HashiCorp Production Hardening Guide).

**Ação corretiva implementada:** Processo de peer review de configurações de segurança antes de qualquer implementação. Unseal keys armazenadas no KeePass com acesso controlado.

**Aplicação futura:** Sempre que um assistente de IA sugerir algo relacionado a chaves criptográficas, tokens de autenticação ou configurações de segurança, verificar obrigatoriamente contra a fonte primária.

---

### L1.2 — Gestão inadequada de unseal keys é risco crítico irrecuperável

**O que aconteceu:** O planejamento inicial previa armazenar as unseal keys em `SECRETS.md`, arquivo de texto não versionado mas sem proteção criptográfica adequada.

**Impacto potencial:** Sem unseal keys, os dados do Vault são irrecuperáveis. Com unseal keys comprometidas, qualquer pessoa com acesso ao arquivo controla todos os secrets.

**Lição:** Unseal keys devem seguir o princípio de separação de custódia: cada shard armazenado em local físico e/ou lógico separado. Para o Living Lab, KeePass com backup em mídia externa é o mínimo aceitável.

**Estado atual:** 5 shards Shamir com threshold 3. Localização: KeePass + backup. Adequado para o contexto de laboratório.

---

## Lições Fase 2

*(Novas — v2.0 — 18/04/2026)*

### L2.1 — WSL2 não é plataforma adequada para workloads de infraestrutura crítica

**O que aconteceu:** A Fase 1 encerrou com sucesso em 09/02/2026. Em 10/02/2026, apenas 24 horas depois, o ambiente WSL2 apresentou falhas estruturais após o primeiro reboot da estação: daemon Tailscale não persistia, Vault entrava em estado `dead`, Raft RPC fechava inesperadamente.

**Diagnóstico:** WSL2 tem systemd parcialmente funcional, stack de rede híbrida Windows/Linux com conflitos de socket irrecuperáveis, e lifecycle de processos instável ao fechar sessões.

**Impacto:** Necessidade de reabertura do projeto como Fase 2 com migração completa de plataforma. ~3 dias de retrabalho.

**Lição:** WSL2 é adequado para desenvolvimento e testes rápidos. Não é adequado para serviços que requerem: persistência após reboot, daemon lifecycle estável, stack de rede isolada, ou integração com systemd completo. Para esses casos, usar VM dedicada ou container com orquestração.

**Aplicação futura:** Qualquer serviço que precise de `systemd enable` e comportamento estável entre reboots deve rodar em VM ou bare metal, nunca em WSL2.

---

### L2.2 — Verificar infraestrutura existente antes de criar nova

**O que aconteceu:** A VM do Vault foi criada como GEN1 (BIOS legado) por urgência após a falha do WSL2, sem verificar que o laboratório já possuía uma **golden image GEN2** (`LINUX-GOLDEN-IMAGE`) que poderia ter sido clonada. O POP-LAB-002 foi criado posteriormente documentando essa oportunidade perdida.

**Impacto:** VM em GEN1 sem UEFI, Secure Boot, TPM virtual ou suporte a disco >2TB. Migração para GEN2 registrada como pendência futura (PF-001). Débito técnico acumulado.

**Lição:** Antes de provisionar qualquer nova VM, executar o checklist de pré-decisão arquitetural:
1. Verificar golden images disponíveis (`Get-VM` + inventário)
2. Verificar geração das VMs existentes no projeto
3. Verificar templates padronizados do laboratório
4. Apenas se nenhum existir: criar nova VM do zero

**Ação adotada:** POP-LAB-002 criado em 12/02/2026 documenta a estratégia de template GEN2 para evitar recorrência. O checklist de pré-decisão arquitetural é agora pré-requisito para qualquer novo provisionamento.

---

### L2.3 — Gap documental de 64 dias: evoluções sem GMUD geram débito de rastreabilidade

**O que aconteceu:** Entre 12/02/2026 (POP-DR-001 v1.1) e 18/04/2026 (GMUD-PRJ007-003), as seguintes mudanças foram implementadas sem registro formal:

- Cloudflare ZT + OTP para `vault.fiqueok.com.br` (implementado em 18/04/2026)
- Criação de usuários nominais `paulo`, `rose`, `daniel` no método `userpass`
- Criação de políticas `reader-policy`, `admin-policy`, `api-proxy-policy`
- Ativação do Audit Device em modo Fail-Closed
- Implementação do SSH Secrets Engine (`ssh-client-signer/`)
- Criação da `policy-colaborador-prj009` para assinatura de chaves SSH

**Impacto:** Impossibilidade de determinar com precisão quando cada mudança foi feita, por que foi feita, e se foi validada. A GMUD-PRJ007-003 formaliza essas mudanças retroativamente, mas a rastreabilidade perfeita foi perdida.

**Lição:** Em ambientes de laboratório, a tentação de implementar mudanças rapidamente sem documentação é alta. O custo de não documentar parece zero no momento, mas se acumula: cada mudança sem registro é um gap de auditoria, uma dependência oculta, e um potencial ponto de falha durante a análise de incidentes.

**Ação adotada:** Qualquer mudança em componentes de produção do Living Lab (Vault, AD, cloudflared, Tailscale ACLs) requer GMUD — ainda que simplificada. O gatilho mínimo é: "Se essa mudança pode causar indisponibilidade ou alterar o comportamento de segurança, documenta antes de executar."

---

### L2.4 — Políticas criadas sem GMUD geram itens sem rastreabilidade (caso `policy-colaborador-prj009`)

**O que aconteceu:** Durante a coleta de evidências em 18/04/2026, foi encontrada a `policy-colaborador-prj009` na listagem de políticas do Vault. Nenhum documento do PRJ007 (TAP, REL, ADD-FASE2) mencionava essa política. Após investigação do conteúdo:

```
path "ssh-client-signer/sign/role-colaborador-prj009" {
  capabilities = ["create", "update"]
}
path "secret/data/projeto009/*" {
  capabilities = ["read"]
}
```

A política é parte de uma infraestrutura SSH de assinatura de chaves para colaboradores do PRJ009. Ela não é uma política órfã — é funcional e necessária. Mas foi criada sem GMUD.

**Impacto:** Em uma auditoria de segurança, uma política sem rastreabilidade documental levanta flag imediato. A ausência de documentação não significa ausência de impacto — significa ausência de controle.

**Lição:** Toda política criada no Vault deve referenciar o projeto ou GMUD que a originou, seja no `display_name` do token que a usa, seja na documentação do projeto. A convenção adotada daqui em diante: políticas seguem o padrão `policy-<projeto>-<papel>` e são documentadas na GMUD ou TAP do projeto de origem.

**Ação adotada:** A `policy-colaborador-prj009` foi documentada no TAP PRJ007 v3.0 e na GMUD-PRJ007-003 como OBS-02. O TAP do PRJ009 deve referenciar essa política.

---

### L2.5 — Root token em uso operacional contínuo é antipadrão crítico

**O que aconteceu:** O audit log coletado em 18/04/2026 mostra acesso via browser Chrome com `display_name: root` e `token_issue_time: 2026-02-10T18:39:16Z`. O root token gerado na inicialização da Fase 2 está sendo usado para acessar a UI do Vault regularmente.

**Impacto:** O próprio Relatório de Hardening do PRJ007 cita o CIS Benchmark: "O CIS recomenda explicitamente a desativação ou proteção do Root Token." O documento afirma conformidade ao criar o usuário `paulo` com `admin-policy`, mas o root token continua ativo e em uso. Isso é uma contradição entre o estado documentado e o estado real.

**Lição:** Criar um usuário `admin` não elimina o risco do root token se o root token continuar sendo usado. A conformidade real requer: (1) criar o admin user, (2) validar que o admin user tem os acessos necessários, (3) revogar o root token, (4) guardar as unseal keys para uso somente em emergências de recriação de root token.

**Ação requerida:** Registrada como `R2` no TAP PRJ007 v3.0 e como `PF-006` (pendência futura). Requer GMUD dedicada para:
- Confirmar que `admin-policy` cobre todos os casos de uso operacionais
- Revogar o root token: `vault token revoke <root_token>`
- Documentar procedimento de recriação de root token em emergência

---

## Padrões Positivos

### P1 — Uso de ADRs para decisões arquiteturais

A decisão de usar WSL2 (ADR-005) e a decisão de migrar para GEN1 (ADR-006) foram documentadas formalmente. Em análises posteriores, esses documentos foram essenciais para entender o contexto sem depender de memória. O padrão de ADR deve ser mantido em todos os projetos do Living Lab.

### P2 — Validação de backup com SHA256

O processo de backup da Fase 1 incluiu verificação de integridade SHA256. Isso é um padrão de excelência que deve ser replicado em todos os processos de backup do laboratório.

### P3 — Decisão pragmática sob constraint

Quando o UEFI do Hyper-V falhou (CONSTRAINT-001), a decisão de usar WSL2 entregou 90% do valor com 10% do esforço de uma reinstalação do Windows. A documentação transparente desse tradeoff — incluindo as limitações reconhecidas — é mais valiosa para o portfólio do que uma implementação "perfeita" que esconde os desafios reais.

### P4 — Coleta de evidências antes de documentar

A abordagem adotada em 18/04/2026 — coletar evidências reais do terminal antes de criar documentação — evitou que a GMUD-PRJ007-003 fosse baseada em inferências incorretas. O estado documentado reflete o estado real, o que é o fundamento de qualquer processo de governança confiável.

---

## Recomendações para Projetos Futuros

### Para o Living Lab

1. **Qualquer mudança em componentes de produção = GMUD.** Não importa o tamanho da mudança. O custo de criar uma GMUD é menor que o custo de reconstruir rastreabilidade depois.

2. **Checklist de pré-provisionamento.** Antes de criar qualquer VM: verificar golden images, verificar geração (GEN1 vs GEN2), verificar templates. Usar POP-LAB-002 como referência.

3. **Root token é para emergências, não para uso diário.** Criar usuários `admin` com políticas equivalentes e revogar o root token após validação.

4. **Convenção de nomenclatura para políticas:** `policy-<projeto>-<papel>`. Toda política referencia seu projeto de origem.

5. **Baseline de disco documentado.** Todo serviço com log de auditoria (Vault, Wazuh) deve ter baseline de crescimento documentado e logrotate configurado antes de habilitar o modo verbose.

### Para IA como ferramenta de trabalho

6. **IA como par de revisão, não como autoridade.** Use assistentes de IA para acelerar drafts, identificar lacunas e estruturar documentação. Valide toda configuração de segurança contra a documentação oficial do fabricante.

7. **Peça evidências antes de aceitar análises.** Quando um assistente afirmar que "o ambiente está configurado de tal forma", pergunte: "Você tem evidência disso ou está inferindo?". Esta própria lição foi aplicada neste projeto em 18/04/2026.

---

## Métricas do Projeto

| Métrica | Planejado (v1.0) | Real |
|---------|-----------------|------|
| Duração total | 2 dias (7.5-8h) | ~75 dias (Fase 1: 7 dias + Fase 2: 68 dias) |
| Fases executadas | 1 | 2 + evoluções incrementais |
| GMUDs registradas | N/A (não planejado) | 1 formal (GMUD-PRJ007-003) + 0 retroativas identificadas |
| Mudanças sem GMUD | — | ~6 identificadas no gap de 64 dias |
| Políticas criadas | 3 | 4 (+ `policy-colaborador-prj009` não planejada) |
| Usuários criados | — | 3 (paulo, rose, daniel) |
| Engines habilitadas | 1 (KV v2) | 2 (KV v2 + SSH client signer) |
| Plataformas utilizadas | 1 (VM Docker) | 3 (Docker → WSL2 → VM nativa GEN1) |
| Riscos abertos ao final | — | 8 (ver TAP v3.0 seção 8) |

---

*Lições Aprendidas — PRJ007 HashiCorp Vault*
*Living Lab Fiqueok — Versão 2.0 — Abril 2026*
*Baseado em evidências coletadas em 18/04/2026 e documentação histórica do projeto*
