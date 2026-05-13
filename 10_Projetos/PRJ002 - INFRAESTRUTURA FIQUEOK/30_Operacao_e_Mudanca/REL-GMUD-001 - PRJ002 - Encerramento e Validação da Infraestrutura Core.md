# 

Documento: Relatório de Execução de Mudança

Projeto Vinculado: PRJ002 - Infraestrutura Fiqueok

GMUD de Referência: GMUD-001 - PRJ002 - Implementacao de Infraestrutura Core

Executor: Paulo Feitosa (Arquiteto/SysAdmin)

Data de Fechamento: 22/12/2025

Status Final: ✅ Concluído com Sucesso

---

## 1. Resumo da Execução

A mudança foi realizada para estabelecer a camada de virtualização (Hyper-V) e provisionar o primeiro servidor (Tier 0). O objetivo de substituir o ambiente legado (VirtualBox) por uma arquitetura corporativa segurada (NAT/TPM) foi atingido.

## 2. Checklist de Atividades Realizadas

|**Etapa**|**Ação Técnica**|**Status**|**Observação**|
|---|---|---|---|
|**1. Rede**|Configuração de vSwitch Interno (`vSwitch_Fiqueok_Corp`)|**OK**|Isolamento L2 garantido.|
|**2. Borda**|Configuração de Gateway (`xxx.xxx.xxx.xxx`) e NAT|**OK**|Teste de conectividade (Ping 8.8.8.8) com sucesso.|
|**3. VM**|Provisionamento da VM `ID-P-01` (Geração 2)|**OK**|2 vCPUs configurados.|
|**4. Segurança**|Ativação de TPM 2.0 e Secure Boot|**OK**|Hardening aplicado via Script.|
|**5. OS**|Instalação do Windows Server 2022 (Desktop Exp.)|**OK**|Versão correta instalada (evitado modo Core).|
|**6. Config**|Definição de IP Estático (`.10`) e Hostname|**OK**|VM renomeada e comunicando com Gateway.|

## 3. Gestão de Incidentes e Desvios

Durante a execução, foram registrados e mitigados os seguintes eventos:

1. **Erro de Sintaxe no Script:** O PowerShell apresentou erro ao calcular a unidade "GB" durante a criação do disco.
    
    - _Solução:_ Script corrigido em tempo real (Runtime) ajustando a multiplicação da variável.
        
2. **Configuração de Memória:** O parâmetro de Memória Dinâmica falhou na criação inicial.
    
    - _Solução:_ Executado "Patch" (Bloco 3.1) para forçar a configuração correta antes do Boot.
        
3. **Boot da ISO:** Houve perda de timing no primeiro boot ("Start PXE over IPv4").
    
    - _Solução:_ Realizado Reset da VM e captura manual do boot pelo DVD.
        

_Nenhum destes incidentes impactou o resultado final ou a integridade do servidor._

## 4. Evidências de Validação

As seguintes evidências foram coletadas e validadas pelo Arquiteto:

- [x] **Conectividade:** Resposta de Ping para `8.8.8.8` a partir da VM.
    
- [x] **Identidade:** Hostname alterado de `WIN-ALEATORIO` para `ID-P-01`.
    
- [x] **Integridade:** Login realizado com sucesso com a conta `Administrator`.
    

## 5. Parecer Final

A infraestrutura base (Host + Rede + VM DC) está operacional e em conformidade com a Arquitetura de Referência **ARQ-002**. O ambiente está apto para receber a instalação dos Serviços de Diretório (AD DS).

**Recomendação:** Proceder com o fechamento da GMUD-001 e aprovação da GMUD-002 para promoção do Domínio.

---

Assinatura do Responsável:

Paulo Feitosa - CISO Fiqueok Consultoria
