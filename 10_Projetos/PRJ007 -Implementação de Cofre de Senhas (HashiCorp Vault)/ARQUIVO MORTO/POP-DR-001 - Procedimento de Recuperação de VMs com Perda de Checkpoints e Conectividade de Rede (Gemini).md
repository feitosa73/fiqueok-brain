

**Status:** Ativo

**Versão:** 1.1 (Revisada pós-incidente IGA-GF-01)

**Data:** 10/02/2026

**Tipo:** POP - Disaster Recovery

**Owner:** Paulo Feitosa (Fiqueok)

**Classificação:** Crítico

---

## **1. Objetivo**

Recuperar máquinas virtuais (OrangeHRM, LDAP, AD) no Hyper-V que sofreram perda de catálogo de pontos de verificação (checkpoints) e corrupção de roteamento de rede, consolidando a cadeia de discos diferenciais (.avhdx) em discos únicos (.vhdx).

## **2. Escopo**

Aplica-se às VMs do Living Lab Fiqueok:

- **IGA-GF-01** (midPoint / OrangeHRM)
    
- **FOK-SRV-LDAP-01** (OpenLDAP)
    
- **VAULT-GEN1** (HashiCorp Vault)
    

## **3. Gatilhos de Acionamento (Triggers)**

1. Erro Hyper-V `0x800705AA` (Recursos insuficientes).
    
2. VM bootando em estado "zerado" (ignorando checkpoints existentes).
    
3. Erro de rede `Host de destino inacessível` ou `Connection timed out`.
    

---

## **4. Fase 1: Preservação e Inventário (Segurança de GRC)**

### **4.1. Backup de Frio (Cold Backup)**

Antes de qualquer manobra, os arquivos brutos devem ser isolados em unidade externa (Drive D:).

1. Desligue a VM no Gerenciador do Hyper-V.
    
2. No PowerShell (Admin), execute a cópia de segurança:
    
    PowerShell
    
    ```
    Copy-Item -Path "C:\ProgramData\Microsoft\Windows\Virtual Hard Disks\NOME_DA_VM*" -Destination "D:\BkpVM\" -Verbose
    ```
    

### **4.2. Identificação da Ponta da Cadeia**

Identifique o arquivo `.avhdx` mais recente através da data de modificação:

PowerShell

```
Get-ChildItem "D:\BkpVM\*.avhdx" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
```

---

## **5. Fase 2: Consolidação Forense (O Resgate)**

### **5.1. Conversão do Disco (Achatamento)**

Utilize o comando `Convert-VHD` para criar um novo disco consolidado a partir da cadeia de checkpoints. **Não utilize Merge-VHD se desejar manter os originais intactos.**

PowerShell

```
Convert-VHD -Path "D:\BkpVM\ARQUIVO_MAIS_RECENTE.avhdx" -DestinationPath "D:\BkpVM\VM_FINAL_RECUPERADA.vhdx" -VHDType Dynamic
```

### **5.2. Tratamento de Erro: Handle Lock (Arquivo em Uso)**

Se o Hyper-V ou o PowerShell negarem acesso ao arquivo (Erro `0x80070020`):

1. **Desanexar VHD**: Vá em `Gerenciamento de Disco`, localize qualquer disco VHD montado (cor azul) e selecione `Desanexar VHD`.
    
2. **Restart do Serviço**: No PowerShell: `Restart-Service vmms`.
    
3. **Reset de Permissões**:
    
    PowerShell
    
    ```
    takeown /f "D:\BkpVM\VM_FINAL_RECUPERADA.vhdx"
    icacls "D:\BkpVM\VM_FINAL_RECUPERADA.vhdx" /grant Todos:F
    ```
    

---

## **6. Fase 3: Reconfiguração de Infraestrutura**

### **6.1. Vinculação do Novo Disco**

1. Nas **Configurações da VM**, vá em **Controladora SCSI** > **Disco Rígido**.
    
2. Altere o caminho para o novo arquivo: `D:\BkpVM\VM_FINAL_RECUPERADA.vhdx`.
    

### **6.2. Correção de Rede (Netplan)**

Caso o IP antigo (`192.168.70.x`) cause conflito com o novo Switch Virtual:

1. Acesse o console da VM.
    
2. Edite o Netplan para modo DHCP temporário:
    
    Bash
    
    ```
    sudo nano /etc/netplan/50-cloud-init.yaml
    ```
    
    _Configuração sugerida:_
    
    YAML
    
    ```
    network:
      version: 2
      ethernets:
        eth0:
          dhcp4: true
    ```
    
3. Aplique: `sudo netplan apply`.
    

---

## **7. Fase 4: Validação de Serviços (IGA/IAM)**

### **7.1. Docker e Conectividade**

1. Verifique o novo IP: `ip a`.
    
2. Valide o status dos containers: `docker ps -a`.
    
3. Reinicie os serviços: `cd /srv/iga-project && sudo docker compose up -d`.
    
4. Teste o acesso via Tailscale: `http://100.x.x.x:8080/midpoint`.
    

---

## **8. Checklist de Encerramento (Selo de Auditoria)**

- [ ] VM inicia sem erros de checkpoint?
    
- [ ] Disco consolidado está em unidade segura (D:)?
    
- [ ] Conectividade externa e Tailscale operacionais?
    
- [ ] Senhas administrativas validadas ou prontas para reset?
    

## **9. Referências**

- Incidente de Recuperação IGA-GF-01 (Fev/2026)
    
- Guia de Administração de Discos Virtuais Microsoft Hyper-V