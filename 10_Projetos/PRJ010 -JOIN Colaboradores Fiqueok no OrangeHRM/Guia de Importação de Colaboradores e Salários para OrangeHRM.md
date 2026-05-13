# Guia de Importação de Colaboradores e Salários para OrangeHRM

Como o seu OrangeHRM está em estado **Greenfield** (limpo), você precisará seguir alguns passos específicos para que a importação funcione corretamente, especialmente para campos como **Departamento**, **Cargo (Job Title)** e **Salário (Pay Grades)**, que são vinculados a tabelas mestre.

## 1. Preparação das Configurações (Essencial)

Antes de importar os arquivos CSV, você **deve** cadastrar manualmente (ou via importação de configuração) os seguintes itens no sistema, pois o OrangeHRM não os cria automaticamente durante a importação de funcionários.

### Departamentos (Subunits)
Vá em: **Admin > Organization > Structure**
Cadastre os seguintes departamentos encontrados na sua lista:
- Executive
- Technology - Dev
- Technology - DevOps
- Technology - Security
- Technology - Data
- Operations
- Fraud & Compliance
- Commercial & CS
- HR & Finance

### Cargos (Job Titles)
Vá em: **Admin > Job > Job Titles**
Cadastre os cargos principais (ex: CEO, Senior Software Engineer, Data Scientist, etc.).

### Pay Grades (Faixas Salariais)

Para importar os salários, o OrangeHRM utiliza o conceito de **Pay Grades**. Eu gerei um arquivo `orangehrm_paygrades.csv` com sugestões de faixas salariais baseadas nos dados que você forneceu. Você precisará importá-los primeiro.

**Passos para importar Pay Grades:**
1.  Faça login no seu OrangeHRM como **Admin**.
2.  No menu lateral, vá para **Admin > Job > Pay Grades**.
3.  Procure por uma opção de **Importar** ou **Adicionar** e siga as instruções para carregar o arquivo `orangehrm_paygrades.csv`.
    *   **Importante:** Certifique-se de que a moeda esteja configurada corretamente (no arquivo, usei BRL como padrão).

**Pay Grades Sugeridos:**

| PayGrade             | Min Salário | Max Salário |
| :------------------- | :---------- | :---------- |
| Executive            | 11000       | 48000       |
| Junior/Entry         | 7500        | 9500        |
| Professional/Analyst | 8500        | 20000       |
| Senior/Specialist    | 8500        | 22000       |

## 2. Como Importar o Arquivo CSV de Colaboradores

Anexei a este guia o arquivo `orangehrm_import.csv` formatado corretamente com os dados básicos dos colaboradores.

1. Faça login no seu OrangeHRM como **Admin**.
2. No menu lateral, vá para **PIM** (Personal Information Management).
3. Clique em **Configuration** e selecione **Data Import**.
4. Clique no botão **Upload** (ou selecione o arquivo).
5. Escolha o arquivo `orangehrm_import.csv` que eu gerei para você.
6. Clique em **Import**.

## 3. Atribuição de Salários aos Colaboradores

Após a importação dos colaboradores e dos Pay Grades, você precisará atribuir o Pay Grade correto a cada funcionário.

1.  Vá para **PIM > Employee List**.
2.  Selecione um funcionário.
3.  Vá para a seção **Job** (ou similar, dependendo da versão do OrangeHRM).
4.  Edite as informações do cargo e atribua o **Pay Grade** correspondente ao salário do funcionário.
    *   **Nota:** O OrangeHRM geralmente não permite a importação direta do valor do salário junto com os dados básicos do funcionário. A atribuição é feita através do Pay Grade, que define a faixa salarial.

## 4. Observações Importantes

-   **Formato de Data:** Se houver campos de data no futuro, o padrão do OrangeHRM costuma ser `YYYY-MM-DD`.
-   **Employee ID:** O arquivo já contém os IDs (FP001, FP002, etc.). Certifique-se de que a configuração de "ID Automático" no OrangeHRM não conflite com esses IDs manuais.
-   **Segurança:** Os grupos de segurança (`SecurityGroup`) no seu arquivo original geralmente são configurados na aba **Admin > User Management** após a criação dos funcionários.

## 5. Próximos Passos

Se você precisar de importações mais complexas (como histórico de salários, informações bancárias detalhadas, etc.), pode ser necessário explorar as funcionalidades de API do OrangeHRM ou módulos específicos de folha de pagamento, que geralmente oferecem opções de importação mais robustas.

---
*Gerado automaticamente para ajudar na sua configuração Greenfield.*
