# 

Documento: Relatório de Execução de Mudança

Projeto Vinculado: PRJ002 - Infraestrutura Fiqueok

GMUD de Referência: GMUD-003 - Estruturacao de Unidades Organizacionais

Executor: Paulo Feitosa (Arquiteto/SysAdmin)

Data de Fechamento: 22/12/2025

Status Final: ✅ Concluído com Sucesso (Com Ressalva Mitigada)

---

## 1. Resumo da Execução

Foi implementada a taxonomia de Unidades Organizacionais (OUs) no Active Directory para suportar o modelo de administração em camadas (Tier Model) e segregação departamental. A estrutura padrão do Windows (`Users`, `Computers`) foi abandonada em favor de uma raiz gerenciada (`Fiqueok_Corp`).

## 2. Checklist de Atividades Realizadas

|**Etapa**|**Ação Técnica**|**Status**|**Observação**|
|---|---|---|---|
|**1. Raiz**|Criação da OU `Fiqueok_Corp`|**OK**|Proteção contra exclusão acidental ativada.|
|**2. Camadas**|Criação das OUs de Topo (`Admins`, `Service_Accounts`, etc.)|**OK**|Estrutura baseada na ARQ-002.|
|**3. Recursos**|Subdivisão de `Resources` em `Servers` e `Workstations`|**OK**|Preparado para GPOs de Servidor vs Desktop.|
|**4. Pessoas**|Criação das OUs Departamentais (`Security`, `Cloud`, etc.)|**OK**|Estrutura pronta para Onboarding.|
|**5. Isolamento**|Bloqueio de Herança de GPO na Raiz|**Corrigido**|Falha inicial mitigada via hotfix.|

## 3. Gestão de Incidentes e Desvios

**Incidente 01:** Falha na aplicação do Bloqueio de Herança (GPO).

- **Descrição:** O comando `Set-GPInheritance` falhou ao receber o parâmetro booleano `$true`.
    
- **Solução:** Aplicado comando corretivo manual utilizando o parâmetro `-IsBlocked Yes`.
    
- **Impacto:** Nulo. A estrutura de pastas foi criada intacta, e o bloqueio foi aplicado segundos depois.
    

## 4. Evidências de Validação

- [x] Abertura do console _Active Directory Users and Computers_ demonstra a existência da árvore `Fiqueok_Corp`.
    
- [x] As subpastas (ex: `04_People > Security`) estão presentes.
    
- [x] A aba "Group Policy Inheritance" da OU Raiz mostra o status "Blocked".
    

## 5. Parecer Final

O Active Directory possui agora uma "arquitetura limpa". Não existem mais impedimentos técnicos para a criação de usuários e grupos.

**Recomendação:** Iniciar imediatamente a criação do primeiro usuário administrativo (Tier 0) na OU `00_Admins`, abandonando o uso da conta `Administrator` padrão (que deve ser desativada ou reservada para Break-glass futuramente).

---

Assinatura do Responsável:

Paulo Feitosa - CISO Fiqueok Consultoria
