

Documento: Relatório de Encerramento de Mudança

Referência: GMUD-005 - PRJ002

Executor: Paulo Feitosa (Arquiteto/SysAdmin)

Data: 22/12/2025

Status: ✅ Concluído com Sucesso

---

## 1. Resumo Executivo

Foi ativado o serviço de endereçamento dinâmico (DHCP) no servidor `ID-P-01`. A implementação visa automatizar a configuração de rede de novos ativos, garantindo que todas as estações recebam as configurações de DNS e Gateway alinhadas às políticas de segurança da organização.

## 2. Checklist de Validação Técnica

|**Item**|**Critério de Sucesso**|**Status**|**Evidência**|
|---|---|---|---|
|**Instalação**|Role DHCP instalada sem erros|**OK**|PowerShell `Success`|
|**Segurança**|Autorização no AD (Anti-Rogue)|**OK**|Servidor listado como autorizado|
|**Escopo**|Range `xxx.xxx.xxx.xxx-200` Ativo|**OK**|`Get-DhcpServerv4Scope` status Active|
|**Opções**|Entrega de DNS (`.10`) e Gateway (`.1`)|**OK**|Validado nas Options 003 e 006|

## 3. Gestão de Riscos e Segurança

- **Mitigação A.13.1:** O servidor DHCP é agora a única fonte de verdade para endereçamento IP.
    
- **Isolamento:** O serviço está restrito à interface de rede interna (Private vSwitch), sem exposição direta à internet (conforme validado na análise de arquitetura).
    

## 4. Próximos Passos (Dependências)

Com o DHCP ativo, o ambiente está pronto para receber a primeira estação de trabalho (Workstation) para testes de ingresso no domínio (Join Domain) e aplicação de GPOs.

---

Assinatura:

Paulo Feitosa - CISO Fiqueok Consultoria
