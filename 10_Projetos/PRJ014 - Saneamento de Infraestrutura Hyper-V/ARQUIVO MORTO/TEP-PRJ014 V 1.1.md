# TERMO DE ENCERRAMENTO DO PROJETO

| Campo               | Valor                                                         |
| ------------------- | ------------------------------------------------------------- |
| **Código**          | TEP-PRJ014                                                    |
| **Versão**          | 1.1 — Adendo pós-encerramento (29/03/2026)                    |
| **Versão Anterior** | 1.0 — Encerramento original (28/03/2026)                      |
| **Responsável**     | Paulo Feitosa Lima — GRC Lead                                 |
| **Projeto**         | PRJ014 — Saneamento e Padronização Hyper-V                    |
| **Status Final**    | ✅ **CONCLUÍDO — Golden Disk Mestre Substituído e Homologado** |
| **Classificação**   | Confidencial Interno — Lab Fiqueok                            |

---

## 1. CHANGELOG

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 28/03/2026 | Paulo Feitosa Lima | Criação — Encerramento formal do PRJ014 |
| **1.1** | **29/03/2026** | **Paulo Feitosa Lima** | **Adendo: substituição do Golden Disk Windows (reprovação no Pre-Flight), ciclo de purificação, homologação do ativo Win2022-GF-PURE-V3-GREENFIELD.vhdx, higienização de entropia, criação da VM PRJ015-PROD-BASE** |

---

## 2. Contexto do Adendo v1.1

Após o encerramento formal do PRJ014 (v1.0, 28/03/2026), a execução de um Pre-Flight técnico no Golden Disk Windows GEN2 identificou duas não-conformidades críticas que tornaram o ativo impróprio para uso como template mestre:

| Não-Conformidade | Impacto | Decisão |
|------------------|---------|---------|
| ParentPath não nulo — Golden Disk não era standalone; clonagem propagaria a dependência | Substituição obrigatória do ativo | ✅ |
| IsReadOnly = False — sem proteção de imutabilidade | Risco de alteração acidental do template mestre | ✅ |

---

## 3. Ciclo de Purificação — Intervenção de 29/03/2026

### 3.1. Etapas Executadas

| # | Etapa | Ação | Resultado |
|---|-------|------|-----------|
| 1 | Pre-Flight Audit | Execução de script de validação no Win2022-GF-GEN2.vhdx | 2 reprovações identificadas |
| 2 | Tentativa Merge-VHD | Merge-VHD falhou (destino inexistente) | Abortada |
| 3 | Convert-VHD → GEN2-FINAL | Conversão para disco independente sem ParentPath | Intermediário criado |
| 4 | VM POC-PROJ015-TEST | Validação de estrutura diferencial e auditoria GRC (4 controles) | 3/4 controles OK (VM desligada) |
| 5 | Ciclo de Purificação do SO | Descomissionamento de AD DS, DNS e DHCP; remoção do Microsoft Edge Stable (bloqueava Sysprep); execução do Sysprep /generalize /oobe /shutdown | Sysprep executado com sucesso |
| 6 | VM VAL-PURE-GREENFIELD | Boot a partir do disco purificado; validação da tela OOBE 'Hi there' | Estado Pure confirmado ✅ |
| 7 | Extração via Convert-VHD | Conversão do diff da VAL-PURE-GREENFIELD para disco independente (13.04 GB) | Win2022-GF-PURE-OFFICIAL.vhdx |
| 8 | Renomeação Formal | Renome para Win2022-GF-PURE-V3-GREENFIELD.vhdx + Set-VHD para reparar cadeia do diff PRJ015 | Golden Disk Oficial ✅ |
| 9 | Higienização de Entropia | Deleção de GEN2-FINAL, GEN2-PURE, PURE-V3 (intermediários); proteção ReadOnly em todos os VHDXs de GoldenDisks | ~41 GB recuperados ✅ |
| 10 | PRJ015-PROD-BASE | Criação da primeira VM de produção do PRJ015 via disco diferencial apontando para o GD oficial | PRJ015 iniciado ✅ |

---

## 4. Inventário Final de Golden Disks — Estado Verificado

### 4.1. Windows Server 2022

| Arquivo | Tamanho | ReadOnly | Status | Observação |
|---------|--------|----------|--------|------------|
| Win2022-GF-GEN1.vhdx | 10.29 GB | ✅ True | Legado / Ativo | GEN1; base para DCs sem Secure Boot |
| Win2022-GF-GEN2.vhdx | 13.82 GB | ✅ True | Reprovado / Arquivado | ParentPath detectado; não usar para novos provisionamentos |
| **Win2022-GF-PURE-V3-GREENFIELD.vhdx** | **13.04 GB** | ✅ True | **OFICIAL ✅** | **Standalone, OOBE validado, Novo SID. Template padrão para PRJ015+** |

### 4.2. Ubuntu 24.04 LTS

| Arquivo | Tamanho | ReadOnly | Status | Observação |
|---------|--------|----------|--------|------------|
| Ubuntu2404-GF-GEN2.vhdx | 13.19 GB | ✅ True | Arquivo base | Origem da clonagem |
| Ubuntu2404-GF-GEN2-Clone.vhdx | 6.94 GB | ✅ True | Pendente validação | Homologação OOBE pendente |
| Ubuntu2404-GF-GEN2-Greenfield.vhdx | 7.13 GB | ✅ True | Candidato oficial | Validação cloud-init pendente |

---

## 5. Inventário de VMs — Estado Final

| VM | Estado | Caminho do Disco | Observação |
|----|--------|------------------|------------|
| api-gf-01 | Off | C:\Hyper-V\VMs\api-gf-01\api-gf-01.vhdx | |
| FOK-SRV-LDAP-01 | Off | C:\Hyper-V\VMs\FOK-SRV-LDAP-01\FOK-SRV-LDAP-01_RECUPERADA.vhdx | Disco com sufixo _RECUPERADA |
| ID-P-01 | Off | C:\Hyper-V\VMs\ID-P-01\ID-P-01.vhdx | |
| IGA-GF-01 | Off | C:\Hyper-V\VMs\IGA-GF-01\IGA-GF-01_67D99B74(...).avhdx | Disco diferencial ativo |
| IGA-P-01 | Off | C:\Hyper-V\VMs\IGA-P-01\IGA-P-01_8F467337(...).avhdx | Disco diferencial ativo |
| rh-gf-01-local | Off | C:\ProgramData\Microsoft\Windows\Virtual Hard Disks\rh-gf-01-local.vhdx | ⚠️ Fora do padrão C:\Hyper-V\ |
| Ubuntu-Clone-Test | Off | C:\Hyper-V\VMs\Ubuntu-Clone-Test\Ubuntu-Clone-Test.vhdx | VM de teste; avaliar remoção |
| VAULT-GEN1 | Off | C:\Hyper-V\VMs\VAULT-GEN1\VAULT-GEN1_03D812D9(...).avhdx | Disco diferencial ativo |
| **PRJ015-PROD-BASE** | Off | C:\Hyper-V\VMs\PRJ015-BASE-diff.vhdx | **Primeira VM do PRJ015 ✅** |

---

## 6. Lições Aprendidas — Atualização (v1.1)

| ID | Lição | Origem | Aplicação Futura |
|----|-------|--------|------------------|
| L12 | Golden Disks GEN2 devem ser criados por clonagem | CONSTRAINT-001 (UEFI corrompido) | Sempre clonar VMs GEN2 existentes |
| L13 | Limpeza pós-clonagem requer ordem específica | Ubuntu clone com dados do OrangeHRM | Remover Tailscale por último, via console |
| L14 | Checkpoints acumulados impactam performance | Diagnóstico inicial | Consolidar checkpoints antes de criar Golden Disk |
| L15 | ISOs duplicadas desperdiçam espaço | Diagnóstico inicial | Manter única pasta de ISOs |
| **L16** | **Pre-Flight obrigatório antes de homologar Golden Disk** | **GEN2 reprovado em 29/03 por ParentPath e falta de ReadOnly** | **Executar script de Pre-Flight (ParentPath, IsReadOnly, VhdType) em todo novo GD antes de classificar como oficial** |
| **L17** | **Roles de AD/DNS/DHCP devem ser removidas antes do Sysprep** | **Sysprep bloqueado em VM promovida a DC** | **Ordem de descomissionamento: DHCP → DNS → AD DS → reboot → remoção de pacotes bloqueadores (ex: Edge Stable) → Sysprep** |
| **L18** | **Microsoft Edge Stable pode bloquear Sysprep** | **Erro no Sysprep após descomissionamento do AD** | **Remover pacotes Appx problemáticos antes do Sysprep. Validar via SetupAct.log** |
| **L19** | **Convert-VHD é o método correto para purificar discos diferenciais** | **Merge-VHD falhou por exigir destino existente** | **Usar Convert-VHD -VHDType Dynamic para extrair estado puro de um disco diferencial** |
| **L20** | **Após renomear o Golden Disk mestre, reparar a cadeia diferencial** | **PRJ015-BASE-diff perdeu referência após rename do OFFICIAL** | **Executar: Set-VHD -Path \<diff\> -ParentPath \<novo_caminho_mestre\>** |

---

## 7. Pendências Identificadas (Não Bloqueantes)

| # | Item | Prioridade | Ação Recomendada |
|---|------|------------|------------------|
| P1 | Ubuntu Golden Disk sem validação OOBE/cloud-init | Média | Validar Ubuntu2404-GF-GEN2-Greenfield.vhdx com boot e checagem de machine-id |
| P2 | rh-gf-01-local fora do padrão de diretório | Baixa | Migrar para C:\Hyper-V\VMs\rh-gf-01-local\ em janela de manutenção |
| P3 | Ubuntu-Clone-Test sem propósito definido | Baixa | Avaliar remoção ou reclassificação |
| P4 | Win2022-GF-GEN2.vhdx (reprovado) ainda em disco | Baixa | Manter como arquivo histórico ou deletar para liberar 13.82 GB |

---

## 8. Aprovações

| Função | Nome | Data | Status |
|--------|------|------|--------|
| GRC Lead / Responsável | Paulo Feitosa Lima | 29/03/2026 | ✅ APROVADO |
| GRC Advisor | Claude (Anthropic) | 29/03/2026 | ✅ REVISADO |

---

**FIM DO TEP-PRJ014 v1.1**
