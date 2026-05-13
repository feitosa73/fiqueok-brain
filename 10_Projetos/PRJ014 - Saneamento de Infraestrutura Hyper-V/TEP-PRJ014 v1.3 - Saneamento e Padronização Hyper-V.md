# TERMO DE ENCERRAMENTO DO PROJETO

| Campo               | Valor                                                         |
| ------------------- | ------------------------------------------------------------- |
| **Código**          | TEP-PRJ014                                                    |
| **Versão**          | 1.3 — Adendo pós-encerramento (23/04/2026)                    |
| **Versão Anterior** | 1.2 — Adendo pós-encerramento (01/04/2026)                    |
| **Responsável**     | Paulo Feitosa Lima — GRC Lead                                 |
| **Projeto**         | PRJ014 — Saneamento e Padronização Hyper-V                    |
| **Status Final**    | ✅ **CONCLUÍDO — Golden Disk Mestre Substituído e Homologado** |
| **Classificação**   | Confidencial Interno — Lab Fiqueok                            |

---

## 1. CHANGELOG

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 28/03/2026 | Paulo Feitosa Lima | Criação — Encerramento formal do PRJ014 |
| 1.1 | 29/03/2026 | Paulo Feitosa Lima | Adendo: substituição do Golden Disk Windows (reprovação no Pre-Flight), ciclo de purificação, homologação do ativo Win2022-GF-PURE-V3-GREENFIELD.vhdx |
| 1.2 | 01/04/2026 | Paulo Feitosa Lima | Adendo: segunda reprovação do Win2022-GF-GEN2.vhdx — inapto para AD DS por metadados residuais irremovíveis (DCPromo.General.54) |
| **1.3** | **23/04/2026** | **Paulo Feitosa Lima** | **Adendo: perda da VM FOK-SRV-LDAP-01 devido à CONSTRAINT-001 (UEFI corrompido) e falhas no processo de sanitização. Remoção definitiva da VM e liberação de espaço em disco.** |

---

## 2. Contexto do Adendo v1.3

Em 23/04/2026, durante tentativa de recuperação da VM `FOK-SRV-LDAP-01`, foi identificado que a VM não bootava devido a erro de assinatura UEFI/ Secure Boot, impossibilitando sua reativação mesmo após recriação da configuração da VM.

### 2.1. Diagnóstico da Falha

| Sintoma | Causa raiz |
|---------|------------|
| Erro `"The signed image's hash is not allowed (DB)"` | CONSTRAINT-001 (UEFI corrompido) impede que o bootloader assinado pela Microsoft seja validado corretamente |
| VM não inicia mesmo com VHDX íntegro | O problema não está no disco, mas na camada de virtualização (GEN2 + Secure Boot) |
| Falhas de sanitização anteriores contribuíram | O processo de limpeza da VM pode ter corrompido arquivos de estado ou configuração de boot |

### 2.2. Análise da Causa Raiz

| Fator | Contribuição |
|-------|--------------|
| **CONSTRAINT-001 (UEFI corrompido)** | Impede a criação e execução confiável de VMs GEN2. A VM não consegue validar a assinatura do bootloader. |
| **Falhas no processo de sanitização** | Tentativas anteriores de limpeza e recuperação podem ter removido ou corrompido componentes críticos de boot. |
| **Arquivo de estado (.vmgs) perdido** | A configuração original da VM foi perdida; a recriação não foi suficiente para restaurar a funcionalidade. |

---

## 3. Decisão e Ação Tomada

| Decisão | Justificativa |
|---------|---------------|
| ❌ **Não manter a VM** | O esforço de recuperação supera o benefício, dado que a VM não boota mesmo com VHDX íntegro |
| ❌ **Não há necessidade de reconstrução** | A VM `FOK-SRV-LDAP-01` não é crítica para a arquitetura atual do Living Lab |
| ✅ **Remover todos os resquícios da VM** | Liberar espaço em disco e eliminar referências órfãs no Hyper-V |

### 3.1. Comandos de Remoção Executados

```powershell
# 1. Desligar a VM (se estiver em execução)
Stop-VM -Name "FOK-SRV-LDAP-01" -Force -ErrorAction SilentlyContinue

# 2. Remover a VM do Hyper-V
Remove-VM -Name "FOK-SRV-LDAP-01" -Force

# 3. Remover o VHDX (disco virtual)
$vhdPath = "C:\Hyper-V\VMs\FOK-SRV-LDAP-01\FOK-SRV-LDAP-01_RECUPERADA.vhdx"
if (Test-Path $vhdPath) { Remove-Item -Path $vhdPath -Force }

# 4. Remover a pasta da VM
$vmFolder = "C:\Hyper-V\VMs\FOK-SRV-LDAP-01"
if (Test-Path $vmFolder) { Remove-Item -Path $vmFolder -Recurse -Force }

# 5. Limpar referências órfãs no repositório do Hyper-V
vmsvc stop -name "FOK-SRV-LDAP-01" -ErrorAction SilentlyContinue
vmsvc delete -name "FOK-SRV-LDAP-01" -ErrorAction SilentlyContinue
```

### 3.2. Espaço Liberado

| Item | Tamanho |
|------|---------|
| VHDX removido | 7.45 GB |
| Pasta e configurações | ~10 MB |
| **TOTAL** | **~7.45 GB** |

---

## 4. Inventário Final de VMs — Estado Atualizado (23/04/2026)

| VM | Estado | Localização | Observação |
|----|--------|-------------|------------|
| api-gf-01 | Executando | `C:\Hyper-V\VMs\api-gf-01\` | Shadow API operacional |
| ID-P-01 | Salva | `C:\Hyper-V\VMs\ID-P-01\` | AD original preservado |
| IGA-GF-02 | Executando | `C:\Hyper-V\VMs\IGA-GF-02\` | midPoint operacional (substituto da GF-01) |
| Linux Lite | Salva | `C:\Hyper-V\VMs\Linux Lite\` | Gateway VM preservada |
| PRJ015-PROD-BASE | Desligada | `C:\Hyper-V\VMs\PRJ015-BASE-diff.vhdx` | Base para PRJ015 |
| rh-gf-01-local | Executando | `C:\ProgramData\...` | ⚠️ Fora do padrão — pendente migração |
| SYNC-01 | Desligada | `C:\Hyper-V\VMs\SYNC-01\` | VM de sincronização (PRJ014/PRJ015) |
| VAULT-GEN1 | Executando | `C:\Hyper-V\VMs\VAULT-GEN1\` | HashiCorp Vault operacional |
| **FOK-SRV-LDAP-01** | ❌ **REMOVIDA** | — | **Perda devido à CONSTRAINT-001 + falhas de sanitização** |

**Total de VMs ativas atualmente: 8 VMs**

---

## 5. Lições Aprendidas — Atualização (v1.3)

| ID | Lição | Origem | Aplicação Futura |
|----|-------|--------|------------------|
| L12 | Golden Disks GEN2 devem ser criados por clonagem | CONSTRAINT-001 (UEFI corrompido) | Sempre clonar VMs GEN2 existentes |
| L13 | Limpeza pós-clonagem requer ordem específica | Ubuntu clone com dados do OrangeHRM | Remover Tailscale por último, via console |
| L14 | Checkpoints acumulados impactam performance | Diagnóstico inicial | Consolidar checkpoints antes de criar Golden Disk |
| L15 | ISOs duplicadas desperdiçam espaço | Diagnóstico inicial | Manter única pasta de ISOs |
| L16 | Pre-Flight obrigatório antes de homologar Golden Disk | GEN2 reprovado em 29/03 | Executar script de Pre-Flight em todo novo GD |
| L17 | Roles de AD/DNS/DHCP devem ser removidas antes do Sysprep | Sysprep bloqueado em DC | Ordem correta de descomissionamento |
| L18 | Microsoft Edge Stable pode bloquear Sysprep | Erro no Sysprep | Remover Appx problemáticos antes do Sysprep |
| L19 | Convert-VHD é o método correto para purificar discos diferenciais | Merge-VHD falhou | Usar Convert-VHD -VHDType Dynamic |
| L20 | Após renomear o Golden Disk mestre, reparar a cadeia diferencial | PRJ015-BASE-diff perdeu referência | Executar Set-VHD -ParentPath |
| L21 | Golden Disks clonados de servidores que foram DC carregam metadados de AD DS irremovíveis | Win2022-GF-GEN2.vhdx inapto para AD DS | Nunca usar GD clonado de DC. Usar GD de instalação limpa. |
| **L22** | **A CONSTRAINT-001 (UEFI corrompido) não afeta apenas a criação de VMs, mas também a recuperação de VMs existentes. A VM FOK-SRV-LDAP-01 não pôde ser recuperada mesmo com VHDX íntegro.** | **FOK-SRV-LDAP-01 perdida em 23/04/2026** | **Documentar o impacto da CONSTRAINT-001 em todas as VMs GEN2 do laboratório. Considerar migração para GEN1 ou substituição do host.** |

---

## 6. Pendências Identificadas (Atualizado)

| # | Item | Prioridade | Ação Recomendada |
|---|------|------------|------------------|
| P1 | Ubuntu Golden Disk sem validação OOBE/cloud-init | Média | Validar `Ubuntu2404-GF-GEN2-Greenfield.vhdx` |
| P2 | `rh-gf-01-local` fora do padrão de diretório | Baixa | Migrar para `C:\Hyper-V\VMs\rh-gf-01-local\` |
| P3 | `Ubuntu-Clone-Test` sem propósito definido | Baixa | Avaliar remoção |
| P4 | `Win2022-GF-GEN2.vhdx` reprovado em disco | Média | Descartar para liberar 13.82 GB |

---

## 7. Aprovações

| Função | Nome | Data | Status |
|--------|------|------|--------|
| GRC Lead / Responsável | Paulo Feitosa Lima | 23/04/2026 | ✅ APROVADO |
| GRC Advisor | DeepSeek | 23/04/2026 | ✅ REVISADO |

---

**FIM DO TEP-PRJ014 v1.3**
