# 

Documento: Relatório de Execução de Mudança

Projeto Vinculado: PRJ002 - Infraestrutura Fiqueok

GMUD de Referência: GMUD-002 - PRJ002 - Implementacao do Servico de Diretorio

Executor: Paulo Feitosa (Arquiteto/SysAdmin)

Data de Fechamento: 22/12/2025

Status Final: ✅ Concluído com Sucesso

---

## 1. Resumo da Execução

A mudança teve como objetivo promover o servidor `ID-P-01` à função de Controlador de Domínio (Domain Controller), estabelecendo a raiz de confiança (Root Trust) da organização. A operação transformou o servidor standalone na base da infraestrutura de Identidade da _Fiqueok Consultoria_.

## 2. Checklist de Atividades Realizadas

|**Etapa**|**Ação Técnica**|**Status**|**Observação**|
|---|---|---|---|
|**1. Instalação**|Deploy das Roles `AD-Domain-Services` e `DNS`|**OK**|Binários instalados via PowerShell.|
|**2. Promoção**|Execução do `Install-ADDSForest`|**OK**|Floresta `corp.fiqueok.com.br` criada.|
|**3. Configuração**|Definição de Nível Funcional (WinThreshold)|**OK**|Compatibilidade garantida com Windows Server 2016+.|
|**4. Recuperação**|Definição de senha DSRM|**OK**|Senha armazenada em cofre seguro.|
|**5. Estrutura**|Criação automática das partições de diretório|**OK**|Schema, Configuration e Domain partitions criadas.|

## 3. Gestão de Incidentes e Desvios

- **Nenhum incidente registrado.** A execução ocorreu conforme o planejado no script de automação, sem erros de pré-requisitos ou falhas de reinicialização.
    

## 4. Evidências de Validação

O _Health Check_ pós-promoção validou os seguintes indicadores críticos:

- [x] **Serviços Críticos:** `ADWS` (Web Services), `DNS`, `KDC` (Kerberos) e `Netlogon` em status _Running_.
    
- [x] **Resolução de Nomes:** O comando `Resolve-DnsName` confirmou que o domínio aponta para o IP `xxx.xxx.xxx.xxx`.
    
- [x] **Integridade do SYSVOL:** Pasta de replicação de políticas (`C:\Windows\SYSVOL\...`) presente e acessível.
    
- [x] **Identidade:** Servidor reconhecido como `RIDMaster` e `PDCEmulator` da floresta.
    

## 5. Parecer Final

A Identidade Centralizada está estabelecida. O ambiente agora possui um **Single Sign-On (SSO)** básico pronto para ser povoado. O servidor `ID-P-01` é oficialmente o "Tier 0" (Ativo mais crítico) da organização.

**Recomendação:** Proceder com a criação da estrutura lógica (Unidades Organizacionais) antes de criar usuários, para garantir a aplicação correta de GPOs desde o início.

---

Assinatura do Responsável:

Paulo Feitosa - CISO Fiqueok Consultoria
