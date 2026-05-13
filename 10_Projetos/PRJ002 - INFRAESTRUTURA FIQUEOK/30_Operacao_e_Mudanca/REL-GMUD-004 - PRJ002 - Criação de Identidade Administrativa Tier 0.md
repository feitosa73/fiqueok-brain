# 

Documento: Relatório de Execução de Mudança

Projeto Vinculado: PRJ002 - Infraestrutura Fiqueok

GMUD de Referência: GMUD-004 - PRJ002 - Criacao de Identidade Administrativa

Executor: Paulo Feitosa (Arquiteto/SysAdmin)

Data de Fechamento: 22/12/2025

Status Final: ✅ Concluído com Sucesso

---

## 1. Resumo da Execução

Foi criada a identidade nominal `paulo.feitosa` na Unidade Organizacional `00_Admins`. Esta conta foi elevada aos grupos de administração máxima da floresta para permitir a continuidade da fase de construção (Build) do ambiente, substituindo a necessidade de uso da conta genérica `Administrator` para operações diárias.

## 2. Checklist de Atividades Realizadas

|**Etapa**|**Ação Técnica**|**Status**|**Observação**|
|---|---|---|---|
|**1. Identidade**|Criação do objeto User `paulo.feitosa`|**OK**|Local: `OU=00_Admins,OU=Fiqueok_Corp`.|
|**2. Segurança**|Definição de Senha Forte|**OK**|Flag `PasswordNeverExpires` ativada (Padrão Lab).|
|**3. Acesso**|Adição ao grupo `Domain Admins`|**OK**|Permissão de gestão de diretório.|
|**4. Acesso**|Adição ao grupo `Enterprise Admins`|**OK**|Permissão de gestão de floresta.|
|**5. Acesso**|Adição ao grupo `Schema Admins`|**OK**|Permissão de extensão de schema (necessário para ferramentas futuras).|

## 3. Gestão de Incidentes e Desvios

- **Nenhum incidente registrado.** A criação ocorreu via automação PowerShell sem erros.
    
- **Nota de Design:** Optou-se pela concentração de privilégios nesta conta única durante a fase de Build para agilidade operacional. Recomenda-se a revisão destes acessos (Princípio do Menor Privilégio) na virada para a fase de Operação (Run).
    

## 4. Evidências de Validação

- [x] Login realizado com sucesso via console Hyper-V utilizando a credencial `paulo.feitosa`.
    
- [x] Comando `whoami /groups` confirma associação aos SIDs administrativos (Terminação `-512`, `-519`, `-518`).
    
- [x] Acesso de escrita validado ao criar uma pasta de teste no Desktop.
    

## 5. Parecer Final

O ambiente possui agora um administrador nominal. O uso da conta `Administrator` (Built-in) deve ser descontinuado para tarefas de rotina.

**Recomendação:** Logar sempre com `paulo.feitosa` a partir de agora. A conta `Administrator` deve ter sua senha rotacionada e armazenada em cofre físico ou digital (Break-glass scenario).

---

Assinatura do Responsável:

Paulo Feitosa - CISO Fiqueok Consultoria