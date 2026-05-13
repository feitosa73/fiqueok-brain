# Inventário de Golden Disks — Living Lab Fiqueok

| Campo             | Valor                        |
| ----------------- | ---------------------------- |
| **Versão**        | 1.1                          |
| **Data**          | 01/04/2026                   |
| **Responsável**   | Paulo Feitosa Lima — GRC Lead |
| **Classificação** | Confidencial Interno         |

---

## Golden Disks Disponíveis

| Golden Disk | Arquivo | Tamanho | Geração | Data de Criação | Origem | Status |
|-------------|---------|---------|---------|-----------------|--------|--------|
| **Windows Server 2022 GEN1** | `Win2022-GF-GEN1.vhdx` | 10.29 GB | 1 | 27/03/2026 | Instalação limpa + Sysprep | ✅ Pronto |
| **Windows Server 2022 GEN2** | `Win2022-GF-GEN2.vhdx` | 13.82 GB | 2 | 27/03/2026 | Clonado de `ID-P-01` | ⚠️ **Uso restrito — ver nota** |
| **Windows Server 2022 PURE V3** | `Win2022-GF-PURE-V3-GREENFIELD.vhdx` | 13.04 GB | 2 | 29/03/2026 | Ciclo de purificação + Sysprep | ✅ **OFICIAL** |
| **Ubuntu 24.04 LTS GEN2** | `Ubuntu2404-GF-GEN2-Greenfield.vhdx` | 7.13 GB | 2 | 28/03/2026 | Clonado de `FOK-SRV-LDAP-01` + limpeza | ✅ Pronto |

---

## ⚠️ Restrições de Uso

### Win2022-GF-GEN2.vhdx — NÃO USAR PARA AD DS

**Descoberta em:** 01/04/2026  
**Contexto:** Tentativa de promover servidor clonado deste GD a Controlador de Domínio (`acesstage.local`) resultou em falha persistente `DCPromo.General.54 - The parameter is incorrect`.

**Causa raiz identificada:**  
O GD foi clonado de `ID-P-01`, servidor que exerceu função de Controlador de Domínio (`corp.fiqueok.com.br`). Apesar das tentativas de limpeza manual (registro, SYSVOL, NTDS, sufixo DNS, WinRM), os metadados de AD DS persistiram no VHDX e impedem qualquer promoção a DC, inclusive para domínios completamente novos.

**Regra:** Não utilizar `Win2022-GF-GEN2.vhdx` em qualquer cenário que envolva promoção a Controlador de Domínio (AD DS).

**Alternativa obrigatória para DCs:**
- `Win2022-GF-GEN1.vhdx` — GEN1, instalação limpa, sem histórico de AD DS
- `Win2022-GF-PURE-V3-GREENFIELD.vhdx` — GEN2 oficial, Sysprep validado, estado Pure confirmado

---

## Localização

```
C:\Hyper-V\GoldenDisks
├── Win2022-GF
│   ├── Win2022-GF-GEN1.vhdx
│   ├── Win2022-GF-GEN2.vhdx          ← uso restrito
│   └── Win2022-GF-PURE-V3-GREENFIELD.vhdx   ← OFICIAL
└── Ubuntu2404-GF
    └── Ubuntu2404-GF-GEN2-Greenfield.vhdx
```

---

## Como Usar

Consulte o [POP-GOLDEN-DISK-001](../03_Metodologia-e-Frameworks/POP-GOLDEN-DISK-001.md) para o procedimento de clonagem e provisionamento via disco diferencial.

---

## Histórico de Versões

| Versão | Data | Alterações |
|--------|------|------------|
| 1.0 | 28/03/2026 | Criação do inventário |
| **1.1** | **01/04/2026** | **Adicionado Win2022-GF-PURE-V3-GREENFIELD.vhdx (OFICIAL). Adicionada restrição de uso no GEN2: inapto para AD DS (DCPromo.General.54). Referência ao troubleshooting de 01/04/2026.** |

---
