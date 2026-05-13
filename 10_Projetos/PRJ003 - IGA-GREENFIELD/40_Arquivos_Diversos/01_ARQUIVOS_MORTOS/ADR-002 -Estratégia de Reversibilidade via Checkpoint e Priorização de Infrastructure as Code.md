---
**ADR:** ADR-002  
**Projeto:** PRJ003 — IGA Greenfield Reference Architecture  
**Título:** Estratégia de Reversibilidade via Checkpoint e Priorização de Infrastructure as Code  
**Status:** Aceito  
**Data:** 2026-01-17  
**Autor:** Paulo Feitosa  
**Contexto:** Living Lab Fiqueok 2.0  
**Dependências:** GMUD-004, GMUD-005  
---

## Sumário Executivo

Este ADR estabelece duas decisões arquiteturais fundamentais para o PRJ003:

1. **Reversibilidade obrigatória via Checkpoint Hyper-V**: Toda GMUD técnica deve criar um Ponto de Verificação antes da execução, sendo este o mecanismo oficial de rollback em caso de falha.
2. **Priorização de Infrastructure as Code (IaC)**: Toda implementação deve priorizar a criação e execução de scripts automatizados em detrimento de comandos manuais, garantindo documentação, reuso e reprodutibilidade.

---

## Contexto

### Problema Observado

Durante ciclos anteriores do Living Lab (PRJ002), foram identificados os seguintes problemas recorrentes:

- **Rollbacks manuais complexos**: Procedimentos de reversão dependiam de sequências de comandos CLI sujeitas a erro humano e inconsistências de estado.
- **Falta de rastreabilidade**: Mudanças executadas via comandos avulsos não geravam documentação técnica reutilizável.
- **Tempo de implementação elevado**: Configurações manuais consumiam tempo significativo sem gerar artefatos de valor.
- **Impossibilidade de replicação**: Ambientes não podiam ser recriados com confiança devido à ausência de scripts versionados.
- **Risco de contaminação de estado**: Estados intermediários corrompidos dificultavam diagnóstico e correção.

### Oportunidade de Melhoria

O PRJ003, como ambiente greenfield em Hyper-V, possui duas capacidades inexploradas:

1. **Pontos de Verificação Hyper-V**: Permitem rollback instantâneo para estado anterior validado.
2. **Scripts PowerShell/Bash**: Permitem automação completa de configurações com rastreabilidade Git.

---

## Decisão

### Decisão 1: Reversibilidade Obrigatória via Checkpoint Hyper-V

**Princípio:**  
Toda GMUD técnica executada no PRJ003 deve criar um **Ponto de Verificação (Checkpoint)** no Hyper-V antes de iniciar a execução. Este checkpoint torna-se o **Gate de Reversibilidade Oficial**.

**Regras de Aplicação:**

1. **Criação obrigatória**: Antes de qualquer execução técnica, um checkpoint deve ser criado manualmente no Gerenciador Hyper-V.
2. **Nomenclatura padronizada**: `PRE-GMUD-XXX` (onde XXX é o número da GMUD).
3. **Validação explícita**: Scripts de execução devem incluir pausa manual para confirmação de criação do checkpoint.
4. **Critério de rollback**: Qualquer falha técnica, validação negativa ou não conclusão de critério de sucesso aciona aplicação do checkpoint.
5. **Documentação**: Plano de rollback em GMUDs deve referenciar o checkpoint como procedimento oficial.

**Exemplo de Validação em Script:**

```powershell
Write-Host "ATENÇÃO: Garanta que o Checkpoint 'PRE-GMUD-XXX' foi criado no Hyper-V!" -ForegroundColor Red -BackgroundColor White
Read-Host "Pressione ENTER para continuar se o Checkpoint estiver pronto..."
```

**Justificativa:**

- Elimina procedimentos manuais de limpeza sujeitos a erro
- Garante estado idempotente e limpo para novas tentativas
- Reduz tempo de rollback de minutos para segundos
- Permite múltiplas execuções sem contaminação residual
- Facilita diagnóstico preservando logs do estado falho

---

### Decisão 2: Priorização de Infrastructure as Code (IaC)

**Princípio:**  
Toda implementação técnica no PRJ003 deve priorizar a criação e execução de **scripts automatizados** (PowerShell, Bash, Docker Compose, Ansible) em detrimento de comandos CLI avulsos ou configurações manuais via interface gráfica.

**Regras de Aplicação:**

1. **Scripts como artefato primário**: Comandos executados devem estar consolidados em arquivos `.ps1`, `.sh`, `.yml` versionados.
2. **Execução via script**: GMUDs técnicas devem executar scripts, não listas de comandos ad-hoc.
3. **Documentação inline**: Scripts devem conter comentários suficientes para compreensão sem documentação externa.
4. **Versionamento obrigatório**: Scripts devem ser armazenados em repositório Git ou Obsidian com controle de versão.
5. **Reutilização como critério**: Scripts devem ser projetados para execução em contextos diferentes (outras VMs, ambientes).
6. **Evidências automáticas**: Scripts devem gerar logs e evidências técnicas sem intervenção manual.

**Hierarquia de Preferência:**

| Prioridade | Método | Uso Recomendado |
|-----------|--------|-----------------|
| 1ª | Docker Compose / Kubernetes YAML | Deploy de aplicações e serviços |
| 2ª | Scripts PowerShell / Bash | Automação de configuração de sistema |
| 3ª | Ansible / Terraform | Provisionamento de infraestrutura complexa |
| 4ª | Comandos CLI documentados | Apenas para diagnóstico ou investigação |
| 5ª | Interfaces gráficas | Não recomendado (exceto para operações únicas de administração) |

**Justificativa:**

- **Redução de tempo**: Execução automatizada é mais rápida que configuração manual.
- **Documentação automática**: Script é documentação executável e versionável.
- **Reprodutibilidade garantida**: Ambientes podem ser recriados com fidelidade.
- **Redução de erros**: Eliminação de variação humana na execução.
- **Reuso entre GMUDs**: Scripts podem ser adaptados para mudanças futuras.
- **Facilita testes**: Scripts podem ser executados em ambientes de teste antes de produção.

---

## Consequências

### Impactos Positivos

| Área | Benefício |
|------|-----------|
| **Governança** | Rollbacks auditáveis e previsíveis |
| **Operação** | Redução drástica de tempo de rollback |
| **Documentação** | Scripts servem como documentação técnica viva |
| **Aprendizado** | Scripts reutilizáveis em projetos futuros |
| **Qualidade** | Redução de erros de execução manual |
| **Velocidade** | Implementações mais rápidas e confiáveis |
| **Replicação** | Capacidade de recriar ambientes em outros contextos |

### Impactos Negativos e Mitigações

| Impacto Negativo | Mitigação |
|------------------|-----------|
| Tempo inicial maior para criar scripts | Investimento se paga em reuso e confiabilidade |
| Checkpoints consomem espaço em disco | Gerenciar apenas 1-2 checkpoints ativos por vez |
| Necessidade de conhecimento em scripting | Templates de scripts disponíveis para GMUDs futuras |
| Rollback via checkpoint perde logs pós-falha | Coleta de evidências antes do rollback (via script) |

---

## Aplicação em GMUDs

### Checklist de Aderência ao ADR-001

Toda GMUD técnica deve validar:

- [ ] Checkpoint criado antes da execução?
- [ ] Checkpoint nomeado conforme padrão `PRE-GMUD-XXX`?
- [ ] Script de execução criado (não apenas lista de comandos)?
- [ ] Script gera evidências técnicas automaticamente?
- [ ] Plano de rollback referencia o checkpoint?
- [ ] Script é reutilizável em outros contextos?
- [ ] Script está versionado e armazenado no projeto?

---

## Exemplos de Aplicação

### Exemplo 1: GMUD-005 (Deploy midPoint)

**Checkpoint:**  
- Nome: `PRE-GMUD-005`
- Criado antes do deploy do Docker Compose

**Script:**  
- Arquivo: `deploy-gmud-005.ps1`
- Funcionalidades:
  - Validação de checkpoint
  - Criação de estrutura de diretórios
  - Deploy do `docker-compose.yml`
  - Validação HTTP automática
  - Coleta de evidências técnicas

**Rollback:**  
- Aplicar checkpoint `PRE-GMUD-005` no Hyper-V
- VM retorna ao estado pós-GMUD-004 (Docker instalado, sem containers)

---

### Exemplo 2: GMUD Futura (Integração com AD)

**Checkpoint:**  
- Nome: `PRE-GMUD-XXX`
- Criado antes da configuração do conector AD

**Script esperado:**  
- Arquivo: `deploy-ad-connector.sh`
- Funcionalidades:
  - Upload de configuração XML para midPoint
  - Teste de conectividade LDAP
  - Validação de sincronização inicial
  - Geração de relatório de correlação

**Rollback:**  
- Aplicar checkpoint `PRE-GMUD-XXX`
- Configuração de conector é revertida automaticamente

---

## Relação com Outros Artefatos

Este ADR fundamenta e é referenciado por:

- **GMUD-004**: Estabeleceu infraestrutura base para aplicação do ADR
- **GMUD-005**: Primeira aplicação prática das decisões deste ADR
- **DGC-001**: Coleta automática de evidências via scripts
- **Todas as GMUDs futuras**: Devem aderir às regras deste ADR

---

## Critérios de Revisão

Este ADR poderá ser revisado caso:

1. Tecnologia de virtualização mude (ex.: migração para KVM, AWS)
2. Checkpoints se mostrem inviáveis por limitações de espaço
3. Scripts provarem ser contraproducentes em casos específicos
4. Ferramentas de IaC mais adequadas sejam identificadas

Qualquer revisão exige novo ADR formal.

---

## Decisões Formais Congeladas

Este ADR congela as seguintes decisões arquiteturais:

1. **Checkpoint Hyper-V é o mecanismo oficial de rollback** para GMUDs técnicas no PRJ003.
2. **Scripts IaC são obrigatórios** para qualquer mudança técnica que envolva configuração de sistema.
3. **Comandos CLI avulsos não são aceitos** como procedimento de execução de GMUD.
4. **GMUDs sem checkpoint pré-criado não devem ser executadas**.
5. **GMUDs sem script de automação não serão aprovadas**.

---

## Aprovação

| Papel | Nome | Status |
|-------|------|--------|
| Autor | Paulo Feitosa | Aprovado |
| Owner Técnico | Paulo Feitosa | Aprovado |
| Owner de Governança | Paulo Feitosa | Aprovado |

---

## Controle de Versão

| Versão | Data | Autor | Mudança |
|--------|------|-------|---------|
| 1.0 | 2026-01-17 | Paulo Feitosa | Criação do ADR-001 |

---

**Repositório Obsidian (Vault FiqueokBrain):**  
`10/Projetos/PRJ003 - IGA-GREENFIELD/20/Governanca e Decisoes/ADRs/ADR-001.md`
