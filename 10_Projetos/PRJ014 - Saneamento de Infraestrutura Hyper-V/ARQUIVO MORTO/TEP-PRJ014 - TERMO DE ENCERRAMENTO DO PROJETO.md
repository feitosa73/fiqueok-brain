## 

---

# TERMO DE ENCERRAMENTO DO PROJETO

|Campo|Valor|
|---|---|
|**Código**|TEP-PRJ014|
|**Versão**|1.0|
|**Data**|28/03/2026|
|**Responsável**|Paulo Feitosa Lima — GRC Lead|
|**Projeto**|PRJ014 — Saneamento e Padronização Hyper-V|
|**Status Final**|✅ **CONCLUÍDO COM SUCESSO**|
|**Classificação**|Confidencial Interno — Lab Fiqueok|

---

## 1. CHANGELOG

|Versão|Data|Autor|Mudanças|
|---|---|---|---|
|1.0|28/03/2026|Paulo Feitosa Lima|Criação — Encerramento formal do PRJ014|

---

## 2. IDENTIFICAÇÃO DO PROJETO

|Campo|Valor|
|---|---|
|**Código**|PRJ014|
|**Nome**|Saneamento e Padronização da Infraestrutura Hyper-V|
|**Categoria**|Infraestrutura / Governança de Laboratório|
|**Patrocinador**|Paulo Feitosa Lima|
|**Data de Início**|27/03/2026|
|**Data de Encerramento**|28/03/2026|
|**Duração Real**|2 dias|
|**Referência TAP**|TAP-PRJ014 v1.2|
|**Sucessor**|PRJ015 — IGA Híbrido Local|

---

## 3. RESUMO EXECUTIVO

O PRJ014 teve como objetivo principal **sanear e padronizar a infraestrutura Hyper-V** do Living Lab Fiqueok, consolidando VMs, ISOs e criando Golden Disks (templates) para Windows Server 2022 e Ubuntu 24.04 LTS.

O projeto foi executado em resposta à **CONSTRAINT-001** (corrupção do subsistema UEFI do Hyper-V), que impedia a criação de novas VMs Generation 2. A solução adotada foi:

1. **Consolidar ISOs** em pasta única (`C:\Hyper-V\ISOs\`)
    
2. **Migrar VMs** para estrutura padronizada (`C:\Hyper-V\VMs\`)
    
3. **Criar Golden Disks** via instalação limpa (GEN1) e clonagem de VMs existentes (GEN2)
    
4. **Limpar e generalizar** o clone do Ubuntu para torná-lo um template Greenfield
    

**Principais entregas:**

- ✅ 3 Golden Disks prontos para uso
    
- ✅ Estrutura padronizada do Hyper-V
    
- ✅ Documentação do procedimento de clonagem
    
- ✅ 100% das VMs migradas e funcionando
    

---

## 4. OBJETIVOS — STATUS FINAL

|ID|Objetivo|Status|Evidência|
|---|---|---|---|
|OBJ-01|Consolidar ISOs em única pasta|✅ CONCLUÍDO|`C:\Hyper-V\ISOs\` com 2 ISOs|
|OBJ-02|Migrar VMs para `C:\Hyper-V\VMs\`|✅ CONCLUÍDO|7 VMs migradas|
|OBJ-03|Consolidar checkpoints antigos|✅ CONCLUÍDO|Checkpoints removidos|
|OBJ-04|Criar Golden Disk Windows GEN1|✅ CONCLUÍDO|10.29 GB|
|OBJ-05|Criar Golden Disk Windows GEN2|✅ CONCLUÍDO|13.82 GB (clonado de ID-P-01)|
|OBJ-06|Criar Golden Disk Ubuntu GEN2|✅ CONCLUÍDO|7.13 GB (clonado e limpo)|
|OBJ-07|Documentar procedimentos|✅ CONCLUÍDO|POP-GOLDEN-DISK-001|

---

## 5. ENTREGÁVEIS REALIZADOS

|ID|Entregável|Localização|Status|
|---|---|---|---|
|E1|ISOs consolidadas|`C:\Hyper-V\ISOs\`|✅|
|E2|VMs migradas|`C:\Hyper-V\VMs\`|✅|
|E3|Golden Disk Windows GEN1|`C:\Hyper-V\GoldenDisks\Win2022-GF\Win2022-GF-GEN1.vhdx`|✅|
|E4|Golden Disk Windows GEN2|`C:\Hyper-V\GoldenDisks\Win2022-GF\Win2022-GF-GEN2.vhdx`|✅|
|E5|Golden Disk Ubuntu GEN2|`C:\Hyper-V\GoldenDisks\Ubuntu2404-GF\Ubuntu2404-GF-GEN2-Greenfield.vhdx`|✅|
|E6|POP-GOLDEN-DISK-001|Procedimento de clonagem|✅|
|E7|TEP-PRJ014|Este documento|✅|

---

## 6. DESAFIOS ENFRENTADOS E SOLUÇÕES

|Desafio|Solução|Lição Aprendida|
|---|---|---|
|CONSTRAINT-001 (UEFI corrompido)|Uso de GEN1 para criação, clonagem de VMs GEN2 existentes|VMs GEN2 podem ser clonadas, não criadas do zero|
|ISOs duplicadas em 3 pastas|Consolidação em `C:\Hyper-V\ISOs\`|Padronização evita desperdício|
|VMs espalhadas em 3 locais|Migração para `C:\Hyper-V\VMs\`|Estrutura única facilita gestão|
|Clone do Ubuntu com dados do OrangeHRM|Limpeza manual (Tailscale, chaves SSH, machine-id)|Golden Disk deve ser generalizado|
|Checkpoints acumulados|Consolidação via PowerShell|Manter no máximo 2-3 checkpoints|

---

## 7. LIÇÕES APRENDIDAS

|ID|Lição|Origem|Aplicação Futura|
|---|---|---|---|
|L12|Golden Disks GEN2 devem ser criados por clonagem, não instalação|CONSTRAINT-001|Sempre clonar VMs GEN2 existentes|
|L13|Limpeza pós-clonagem requer ordem específica|Ubuntu clone|Remover Tailscale por último, via console|
|L14|Checkpoints acumulados impactam performance|Diagnóstico|Consolidar checkpoints antes de criar Golden Disk|
|L15|ISOs duplicadas desperdiçam espaço|Diagnóstico|Manter única pasta de ISOs|

---

## 8. ESTRUTURA FINAL DO HYPER-V

text

C:\Hyper-V\
├── ISOs\
│   ├── WindowsServer2022.iso (4.7 GB)
│   └── ubuntu-24.04.3-live-server-amd64.iso (3.08 GB)
├── VMs\
│   ├── api-gf-01\
│   ├── FOK-SRV-LDAP-01\
│   ├── ID-P-01\
│   ├── IGA-GF-01\
│   ├── IGA-P-01\
│   ├── rh-gf-01-local\
│   └── VAULT-GEN1\
├── GoldenDisks\
│   ├── Win2022-GF\
│   │   ├── Win2022-GF-GEN1.vhdx (10.29 GB)
│   │   └── Win2022-GF-GEN2.vhdx (13.82 GB)
│   └── Ubuntu2404-GF\
│       └── Ubuntu2404-GF-GEN2-Greenfield.vhdx (7.13 GB)
└── Scripts\
    └── (scripts de clonagem)

---

## 9. APROVAÇÕES

|Função|Nome|Data|Status|
|---|---|---|---|
|GRC Lead / Responsável|Paulo Feitosa Lima|28/03/2026|✅ APROVADO|
|GRC Advisor|DeepSeek|28/03/2026|✅ REVISADO|