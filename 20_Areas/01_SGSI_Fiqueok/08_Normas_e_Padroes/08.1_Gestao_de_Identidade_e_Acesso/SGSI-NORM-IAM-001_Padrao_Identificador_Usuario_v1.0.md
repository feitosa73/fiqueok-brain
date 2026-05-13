# Norma de Padrão de Identificador de Usuário (Login Corporativo)

**Código:** SGSI-NORM-IAM-001  
**Versão:** 1.0  
**Data de publicação:** 03/01/2026  
**Aprovação:** [Pendente]  
**Classificação:** Uso Interno  
**Status:** Vigente  

---

## 📋 Controle de Versões

| Versão | Data       | Autor         | Descrição                                    |
|--------|------------|---------------|----------------------------------------------|
| 1.0    | 03/01/2026 | Paulo Feitosa | Versão inicial - Criação da norma de padrão |

---

## 1. Finalidade

Esta norma estabelece o padrão corporativo para definição, geração e gestão de identificadores de usuário (usernames ou logins) utilizados em todos os sistemas, aplicações e plataformas tecnológicas da organização.

O objetivo é garantir **unicidade**, **previsibilidade**, **auditabilidade** e **conformidade regulatória** na criação de identidades digitais, alinhando-se aos requisitos de controles de acesso da ISO/IEC 27001:2022 e ISO/IEC 27002.

---

## 2. Escopo

### 2.1. Aplicabilidade

Esta norma aplica-se a:

- Todos os colaboradores, incluindo efetivos, temporários, estagiários e terceiros com vínculo formal
- Contas de serviço que representem identidades corporativas
- Sistemas corporativos que requeiram autenticação individual
- Serviços de diretório (Active Directory, LDAP, cloud identity providers)
- Plataformas de Identity & Access Management (IAM) e Identity Governance & Administration (IGA)

### 2.2. Exclusões

Ficam fora do escopo desta norma:

- Contas compartilhadas (reguladas por norma específica)
- Contas de aplicação/sistema sem vínculo a pessoa física
- Identificadores de sistemas externos não integrados ao diretório corporativo

---

## 3. Definições e Termos

| Termo | Definição |
|-------|-----------|
| **Identificador de Usuário** | String única e imutável que representa a identidade digital de um colaborador em sistemas corporativos (também denominado *username* ou *login*). |
| **Fonte Autoritativa** | Sistema ou base de dados designado como referência primária para atributos de identidade (ex: sistema de RH). |
| **Colisão de Identificador** | Situação em que a aplicação do algoritmo de geração resulta em identificador já existente, exigindo aplicação de regra de fallback. |
| **Determinismo** | Propriedade que garante que, dadas as mesmas entradas (nome, sobrenome, etc.), o algoritmo sempre produzirá o mesmo identificador. |
| **Imutabilidade** | Característica que impede alteração do identificador após sua criação, exceto em casos excepcionais documentados. |

---

## 4. Princípios de Identidade Digital

### 4.1. Identidade Única

Cada colaborador deve possuir **um único identificador de usuário** que o represente em todos os sistemas corporativos integrados ao diretório central.

**Vedações:**
- Criação de múltiplos identificadores para a mesma pessoa física
- Reutilização de identificadores de colaboradores desligados

### 4.2. Determinismo e Previsibilidade

O identificador deve ser gerado através de **algoritmo determinístico** baseado em atributos do colaborador, garantindo:

- Reprodutibilidade: mesmo conjunto de atributos sempre gera o mesmo identificador
- Ausência de componentes aleatórios ou sequenciais arbitrários
- Rastreabilidade da lógica de formação

### 4.3. Fonte Autoritativa

O sistema de **Gestão de Recursos Humanos (RH)** é designado como **fonte autoritativa** para os atributos utilizados na geração do identificador.

**Implicações:**
- Atributos de identidade devem ser cadastrados e mantidos no sistema de RH
- Alterações de atributos devem seguir processo formal de RH
- Sistemas de IAM/IGA devem sincronizar-se com a fonte autoritativa

### 4.4. Imutabilidade

O identificador de usuário, uma vez criado, é **imutável** durante todo o ciclo de vida do colaborador na organização.

**Exceções (sujeitas a aprovação formal):**
- Mudança de nome civil por ordem judicial
- Erro crítico de cadastro comprovado
- Requisito legal ou regulatório específico

---

## 5. Campos Obrigatórios de Entrada

### 5.1. Atributos Mínimos Requeridos

Os seguintes atributos devem estar disponíveis na fonte autoritativa (RH) para geração do identificador:

| Atributo | Obrigatoriedade | Formato Esperado | Exemplo |
|----------|-----------------|------------------|---------|
| **Nome (givenName)** | Obrigatório | String alfabética, sem caracteres especiais | Paulo |
| **Sobrenome (surname)** | Obrigatório | String alfabética, sem caracteres especiais | Lima |
| **Nome do Meio (middleName)** | Opcional | String alfabética, pode ser vazio | Fernando |
| **Identificador Corporativo (employeeNumber)** | Obrigatório | Código numérico ou alfanumérico único | 00123 |

### 5.2. Tratamento de Atributos

#### 5.2.1. Normalização

Todos os atributos devem ser normalizados antes da aplicação do algoritmo:

- Conversão para minúsculas (lowercase)
- Remoção de acentuação (transliteração para ASCII)
- Remoção de caracteres especiais (pontuação, símbolos)
- Remoção de espaços em branco extras

**Exemplos de normalização:**

| Original | Normalizado |
|----------|-------------|
| José | jose |
| María | maria |
| O'Connor | oconnor |
| Da Silva | dasilva |

#### 5.2.2. Validação de Integridade

O sistema de IAM/IGA deve validar:

- Presença de atributos obrigatórios
- Conformidade de formato
- Ausência de valores nulos ou vazios em campos obrigatórios

---

## 6. Padrão de Formação do Identificador

### 6.1. Formato Primário

**Padrão:** `primeironome.sobrenome`

**Algoritmo:**
1. Extrair primeiro nome (givenName)
2. Extrair sobrenome (surname)
3. Normalizar ambos conforme seção 5.2.1
4. Concatenar com ponto (`.`) como separador
5. Validar unicidade no diretório corporativo

**Exemplos:**

| Nome Completo | Identificador Gerado |
|---------------|----------------------|
| Paulo Lima | paulo.lima |
| Maria Silva | maria.silva |
| José Santos | jose.santos |

### 6.2. Formato Alternativo (Fallback para Colisão)

Caso o formato primário resulte em colisão (identificador já existe), aplicar **formato alternativo** em sequência:

#### 6.2.1. Fallback Nível 1: Inclusão do Nome do Meio

**Padrão:** `primeironome.nomedomeio.sobrenome`

**Condição:** Atributo `middleName` disponível e não vazio

**Exemplos:**

| Nome Completo | Identificador Gerado |
|---------------|----------------------|
| Paulo Fernando Lima | paulo.fernando.lima |
| Maria Cristina Silva | maria.cristina.silva |

#### 6.2.2. Fallback Nível 2: Abreviação do Nome do Meio

**Padrão:** `primeironome.inicialmeio.sobrenome`

**Condição:** Fallback Nível 1 resultou em colisão

**Algoritmo:**
1. Extrair primeira letra do nome do meio
2. Concatenar: `primeironome.inicial.sobrenome`

**Exemplos:**

| Nome Completo | Identificador Gerado |
|---------------|----------------------|
| Paulo Fernando Lima | paulo.f.lima |
| Maria Cristina Silva | maria.c.silva |

#### 6.2.3. Fallback Nível 3: Sufixação Numérica

**Padrão:** `primeironome.sobrenome.N`

**Condição:** Todos os fallbacks anteriores resultaram em colisão

**Algoritmo:**
1. Aplicar formato primário
2. Adicionar sufixo numérico sequencial (`.2`, `.3`, etc.)
3. Iniciar em `.2` (não `.1`, pois o identificador sem sufixo é implicitamente "1")

**Exemplos:**

| Nome Completo | Identificador Gerado | Observação |
|---------------|----------------------|------------|
| Paulo Lima | paulo.lima.2 | Segundo colaborador com mesmo nome |
| Paulo Lima | paulo.lima.3 | Terceiro colaborador com mesmo nome |

### 6.3. Limites e Restrições Técnicas

| Restrição | Especificação | Justificativa |
|-----------|---------------|---------------|
| Comprimento máximo | 64 caracteres | Compatibilidade com AD (sAMAccountName: 20 chars) e LDAP (uid: 255 chars) - adota-se limite conservador |
| Caracteres permitidos | a-z, 0-9, ponto (`.`) | Compatibilidade com sistemas legados e protocolos LDAP/Kerberos |
| Início | Deve iniciar com letra minúscula | Padrão técnico de nomenclatura |
| Fim | Deve terminar com letra ou número | Evita terminações com caracteres especiais |

---

## 7. Tratamento de Colisões

### 7.1. Definição de Colisão

Colisão ocorre quando o identificador gerado pelo algoritmo **já está em uso** no diretório corporativo.

### 7.2. Procedimento de Resolução

O sistema de IAM/IGA deve implementar a seguinte lógica:

```
INÍCIO
  identificador ← AplicarFormatoPrimário(nome, sobrenome)

  SE identificador NÃO existe no diretório ENTÃO
    RETORNAR identificador
  FIM SE

  SE middleName existe E NÃO está vazio ENTÃO
    identificador ← AplicarFallbackNível1(nome, middleName, sobrenome)
    SE identificador NÃO existe no diretório ENTÃO
      RETORNAR identificador
    FIM SE

    identificador ← AplicarFallbackNível2(nome, middleName, sobrenome)
    SE identificador NÃO existe no diretório ENTÃO
      RETORNAR identificador
    FIM SE
  FIM SE

  identificador ← AplicarFallbackNível3(nome, sobrenome)
  RETORNAR identificador
FIM
```

### 7.3. Casos Especiais

#### 7.3.1. Nomes Muito Curtos

Para nomes ou sobrenomes com menos de 3 caracteres, o formato primário deve ser mantido, priorizando fallbacks de nível superior.

**Exemplo:**
- Nome: `Li Zhang`
- Formato primário: `li.zhang`
- Se colidir, aplicar sufixação: `li.zhang.2`

#### 7.3.2. Nomes Compostos

Sobrenomes compostos (ex: "Dos Santos", "Da Silva") devem ser tratados como uma única unidade após normalização.

**Exemplo:**
- Nome completo: `João Dos Santos`
- Normalizado: `joão` + `dossantos`
- Identificador: `joao.dossantos`

---

## 8. Exemplos Práticos

### 8.1. Cenário 1: Caso Simples

**Dados de entrada:**
- Nome: Paulo
- Sobrenome: Lima
- Nome do meio: (vazio)

**Processamento:**
1. Formato primário: `paulo.lima`
2. Validação: identificador não existe
3. **Resultado:** `paulo.lima`

### 8.2. Cenário 2: Nome do Meio Presente

**Dados de entrada:**
- Nome: Paulo
- Sobrenome: Lima
- Nome do meio: Fernando

**Processamento:**
1. Formato primário: `paulo.lima`
2. Validação: **identificador já existe** (colisão detectada)
3. Fallback Nível 1: `paulo.fernando.lima`
4. Validação: identificador não existe
5. **Resultado:** `paulo.fernando.lima`

### 8.3. Cenário 3: Múltiplas Colisões

**Dados de entrada:**
- Nome: Paulo
- Sobrenome: Lima
- Nome do meio: Fernando

**Processamento:**
1. Formato primário: `paulo.lima` → **já existe**
2. Fallback Nível 1: `paulo.fernando.lima` → **já existe**
3. Fallback Nível 2: `paulo.f.lima` → **já existe**
4. Fallback Nível 3: `paulo.lima.2`
5. Validação: identificador não existe
6. **Resultado:** `paulo.lima.2`

### 8.4. Cenário 4: Acentuação e Caracteres Especiais

**Dados de entrada:**
- Nome: José
- Sobrenome: D'Ávila

**Processamento:**
1. Normalização: `jose` + `davila`
2. Formato primário: `jose.davila`
3. Validação: identificador não existe
4. **Resultado:** `jose.davila`

---

## 9. Responsabilidades

### 9.1. Área de Recursos Humanos (RH)

| Responsabilidade | Descrição |
|------------------|-----------|
| **Cadastro de Atributos** | Garantir cadastro completo e preciso dos atributos obrigatórios (nome, sobrenome, nome do meio, employeeNumber) no sistema de RH. |
| **Manutenção de Dados** | Manter atualização contínua dos dados cadastrais conforme processos de admissão, alteração e desligamento. |
| **Validação de Integridade** | Validar conformidade dos dados antes de disponibilizá-los para sincronização com sistemas de IAM. |
| **Tratamento de Exceções** | Aprovar formalmente exceções à norma (ex: alteração de identificador por mudança de nome civil). |

### 9.2. Área de Identity & Access Management (IAM)

| Responsabilidade | Descrição |
|------------------|-----------|
| **Implementação do Algoritmo** | Implementar e manter algoritmo de geração de identificadores conforme padrão definido nesta norma. |
| **Sincronização com Fonte Autoritativa** | Garantir sincronização automatizada e periódica com o sistema de RH. |
| **Gestão de Colisões** | Implementar lógica de detecção e resolução de colisões conforme seção 7. |
| **Auditoria de Geração** | Registrar em log toda geração de identificador, incluindo algoritmo aplicado e resultado. |
| **Gestão de Exceções** | Processar exceções aprovadas por RH, mantendo rastreabilidade completa. |

### 9.3. Área de Tecnologia da Informação (TI)

| Responsabilidade | Descrição |
|------------------|-----------|
| **Provisionamento Técnico** | Criar contas de usuário em sistemas corporativos utilizando identificadores gerados pela plataforma de IAM. |
| **Validação de Unicidade** | Garantir que sistemas de diretório (AD, LDAP) validem unicidade de identificadores. |
| **Conformidade de Integração** | Assegurar que integrações entre sistemas respeitem o padrão de identificador definido. |
| **Disponibilidade de Plataforma** | Manter disponibilidade e desempenho dos serviços de diretório e autenticação. |

### 9.4. Área de Segurança da Informação

| Responsabilidade | Descrição |
|------------------|-----------|
| **Revisão Periódica da Norma** | Revisar anualmente a norma, propondo ajustes conforme evolução tecnológica e regulatória. |
| **Auditoria de Conformidade** | Auditar aderência das áreas aos controles estabelecidos nesta norma. |
| **Gestão de Incidentes** | Tratar incidentes de segurança relacionados a identificadores (ex: duplicidade, uso indevido). |
| **Conformidade Regulatória** | Garantir alinhamento da norma aos requisitos da ISO 27001, ISO 27002 e legislações aplicáveis. |

---

## 10. Relacionamento com Ferramentas e Sistemas

### 10.1. Sistemas de Identity & Access Management (IAM/IGA)

As plataformas de IAM/IGA (ex: midPoint, Okta, SailPoint) são responsáveis por:

- **Implementação do algoritmo** de geração de identificadores
- **Integração com fonte autoritativa** (sistema de RH)
- **Orquestração de provisionamento** de contas em sistemas-alvo
- **Aplicação de políticas** de nomenclatura e detecção de colisões
- **Registro de auditoria** de todas as operações de geração e alteração de identificadores

**Requisitos técnicos:**
- Capacidade de executar lógica de transformação de atributos
- Suporte a múltiplos formatos de fallback
- Validação de unicidade em tempo real
- Logs imutáveis e rastreáveis

### 10.2. Serviços de Diretório (Active Directory, LDAP)

Os serviços de diretório corporativo devem:

- **Receber identificadores** já gerados pela plataforma de IAM
- **Validar unicidade** como controle adicional
- **Rejeitar criações manuais** de contas que não sigam o padrão
- **Prover APIs** para consulta de existência de identificadores

**Atributos LDAP relevantes:**
- `uid` (User ID): identificador de usuário LDAP
- `sAMAccountName` (Active Directory): nome de logon pré-Windows 2000
- `userPrincipalName` (UPN): identificador no formato email (ex: `paulo.lima@fiqueok.com.br`)

### 10.3. Sistema de Recursos Humanos (HR)

O sistema de RH deve:

- **Armazenar atributos obrigatórios** conforme seção 5.1
- **Expor APIs ou interfaces** para sincronização com IAM
- **Notificar alterações** de atributos de identidade
- **Validar qualidade de dados** antes da exportação

---

## 11. Rastreabilidade e Auditoria

### 11.1. Logs Obrigatórios

Toda geração ou alteração de identificador deve gerar registro de auditoria contendo, no mínimo:

| Campo | Descrição | Exemplo |
|-------|-----------|---------|
| **Timestamp** | Data e hora da operação (UTC) | 2026-01-03T17:48:00Z |
| **Colaborador** | Nome completo | Paulo Fernando Lima |
| **employeeNumber** | Identificador corporativo do RH | 00123 |
| **Identificador Gerado** | Username resultante | paulo.fernando.lima |
| **Algoritmo Aplicado** | Formato utilizado | Fallback Nível 1 |
| **Colisões Detectadas** | Número de colisões durante o processo | 1 |
| **Sistema de Origem** | Sistema que iniciou a operação | midPoint IGA |
| **Usuário Responsável** | Conta que executou a operação | svc_iam_automation |

### 11.2. Retenção de Logs

Os logs de auditoria devem ser:

- **Armazenados de forma imutável** (append-only logs)
- **Retidos por no mínimo 7 anos** (conformidade regulatória)
- **Disponíveis para análise forense** e auditorias internas/externas
- **Protegidos contra acesso não autorizado** (criptografia em repouso)

### 11.3. Indicadores de Conformidade

Os seguintes indicadores devem ser monitorados mensalmente:

| Indicador | Meta | Ação em Caso de Desvio |
|-----------|------|-------------------------|
| Identificadores gerados automaticamente | ≥ 99% | Investigar criações manuais |
| Colisões resolvidas com sucesso | 100% | Revisar algoritmo de fallback |
| Identificadores fora do padrão | 0 | Corrigir manualmente e auditar causa |
| Tempo médio de geração | ≤ 5 segundos | Otimizar performance do IAM |

---

## 12. Vinculação aos Controles ISO

### 12.1. ISO/IEC 27001:2022

Esta norma contribui para o atendimento dos seguintes controles do Anexo A:

| Controle | Título | Relação com a Norma |
|----------|--------|---------------------|
| **A.5.15** | Controle de acesso | Define padrão único de identificação para controle de acesso a sistemas corporativos. |
| **A.5.16** | Gestão de identidade | Estabelece processo determinístico e auditável de criação de identidades digitais. |
| **A.5.17** | Informações de autenticação | Garante unicidade de identificadores, base para autenticação segura. |
| **A.5.18** | Direitos de acesso | Identificador único permite rastreamento preciso de direitos e permissões. |
| **A.8.2** | Gestão de acesso privilegiado | Padrão de nomenclatura facilita identificação de contas administrativas (ex: sufixo `-admin`). |

### 12.2. ISO/IEC 27002:2022

Os seguintes controles e diretrizes são observados:

| Seção | Diretriz | Aplicação |
|-------|----------|-----------|
| **5.15** | Controle de acesso | Identificador único como base para políticas de controle de acesso baseado em identidade. |
| **5.16** | Gestão de identidade | Processo automatizado de geração reduz erro humano e garante consistência. |
| **5.17** | Informações de autenticação | Identificador imutável reduz vetores de ataque relacionados a mudanças de identidade. |
| **8.5** | Autenticação segura | Padrão previsível facilita implementação de políticas de senha e MFA. |

### 12.3. Princípios de Privacy by Design

Embora identificadores corporativos não sejam dados sensíveis, esta norma observa:

- **Minimização de dados:** Utiliza apenas atributos necessários (nome, sobrenome)
- **Propósito específico:** Identificador destinado exclusivamente a acesso corporativo
- **Transparência:** Algoritmo documentado e auditável
- **Segurança desde a concepção:** Unicidade e imutabilidade como controles de segurança nativos

---

## 13. Exceções e Casos Não Conformes

### 13.1. Solicitação de Exceção

Exceções a esta norma devem ser:

- **Justificadas formalmente** por escrito
- **Aprovadas pelo Comitê de Segurança da Informação**
- **Documentadas em registro de exceções**
- **Revisadas periodicamente** (máximo 12 meses de validade)

### 13.2. Exemplos de Exceções Aceitáveis

- Colaboradores com nome único (monônimo) culturalmente justificado
- Requisitos legais específicos de jurisdições internacionais
- Limitações técnicas de sistemas legados críticos (com plano de correção)

### 13.3. Tratamento de Contas Pré-Existentes

Contas criadas antes da vigência desta norma que **não estejam em conformidade** devem:

- **Ser catalogadas e documentadas**
- **Ter plano de adequação definido** (prazo máximo: 24 meses)
- **Ser migradas** preferencialmente durante eventos de ciclo de vida (mudança de cargo, transferência)
- **Manter rastreabilidade** entre identificador antigo e novo

---

## 14. Revisão e Atualização

### 14.1. Periodicidade

Esta norma deve ser revisada:

- **Anualmente** em revisão programada
- **Ad-hoc** em caso de:
  - Mudanças regulatórias relevantes
  - Incidentes de segurança relacionados
  - Evolução significativa de tecnologias de IAM
  - Auditoria externa com recomendações

### 14.2. Processo de Revisão

1. **Coleta de evidências:** Análise de logs, incidentes, feedbacks de áreas
2. **Avaliação de conformidade:** Verificação de aderência aos controles ISO
3. **Proposta de alterações:** Elaboração de versão revisada
4. **Consulta às partes interessadas:** RH, IAM, TI, Segurança da Informação
5. **Aprovação:** Comitê de Segurança da Informação
6. **Publicação e comunicação:** Divulgação da nova versão

---

## 15. Referências Normativas

- **ISO/IEC 27001:2022** - Information security, cybersecurity and privacy protection — Information security management systems — Requirements
- **ISO/IEC 27002:2022** - Information security, cybersecurity and privacy protection — Information security controls
- **NIST SP 800-63B** - Digital Identity Guidelines: Authentication and Lifecycle Management
- **RFC 4519** - Lightweight Directory Access Protocol (LDAP): Schema for User Applications
- **RFC 2307** - An Approach for Using LDAP as a Network Information Service

---

## 16. Glossário

| Termo | Definição |
|-------|-----------|
| **Active Directory (AD)** | Serviço de diretório da Microsoft para gerenciamento de identidades em ambientes Windows. |
| **Fallback** | Algoritmo alternativo aplicado quando o algoritmo primário resulta em colisão. |
| **Fonte Autoritativa** | Sistema de referência primária para atributos de identidade (ex: HR). |
| **IAM (Identity & Access Management)** | Gestão de identidades e controle de acesso a recursos corporativos. |
| **IGA (Identity Governance & Administration)** | Governança de identidades com foco em conformidade, auditoria e ciclo de vida. |
| **LDAP (Lightweight Directory Access Protocol)** | Protocolo padrão para acesso a serviços de diretório. |
| **sAMAccountName** | Atributo do Active Directory que representa o nome de logon pré-Windows 2000 (limite: 20 caracteres). |
| **Unicidade** | Propriedade que garante que cada identificador seja exclusivo no escopo do diretório corporativo. |

---

## 17. Aprovação e Vigência

### 17.1. Aprovadores

| Função | Nome | Assinatura | Data |
|--------|------|------------|------|
| **CISO / Gestor de Segurança da Informação** | [Nome] | [Assinatura] | [Data] |
| **Gestor de IAM** | [Nome] | [Assinatura] | [Data] |
| **Gestor de RH** | [Nome] | [Assinatura] | [Data] |
| **Gestor de TI** | [Nome] | [Assinatura] | [Data] |

### 17.2. Vigência

Esta norma entra em vigor na data de sua publicação e permanece vigente até ser substituída por nova versão ou revogada formalmente.

**Data de vigência:** [Data de publicação]  
**Próxima revisão programada:** [Data + 12 meses]

---

## 18. Anexos

### Anexo A - Algoritmo de Geração (Pseudocódigo)

```
FUNÇÃO GerarIdentificador(givenName, surname, middleName, employeeNumber):

    // Normalização de atributos
    nome ← Normalizar(givenName)           // minúsculas, sem acentos
    sobrenome ← Normalizar(surname)
    meio ← Normalizar(middleName)

    // Formato primário
    identificador ← nome + "." + sobrenome

    SE IdentificadorExiste(identificador) = FALSO ENTÃO
        RETORNAR identificador
    FIM SE

    // Fallback Nível 1: Nome do meio completo
    SE meio NÃO está vazio ENTÃO
        identificador ← nome + "." + meio + "." + sobrenome

        SE IdentificadorExiste(identificador) = FALSO ENTÃO
            RETORNAR identificador
        FIM SE

        // Fallback Nível 2: Inicial do meio
        inicial ← PrimeiraLetra(meio)
        identificador ← nome + "." + inicial + "." + sobrenome

        SE IdentificadorExiste(identificador) = FALSO ENTÃO
            RETORNAR identificador
        FIM SE
    FIM SE

    // Fallback Nível 3: Sufixação numérica
    contador ← 2
    ENQUANTO VERDADEIRO FAÇA
        identificador ← nome + "." + sobrenome + "." + contador

        SE IdentificadorExiste(identificador) = FALSO ENTÃO
            RETORNAR identificador
        FIM SE

        contador ← contador + 1
    FIM ENQUANTO

FIM FUNÇÃO

FUNÇÃO Normalizar(texto):
    texto ← ConverterParaMinúsculas(texto)
    texto ← RemoverAcentuação(texto)
    texto ← RemoverCaracteresEspeciais(texto)
    texto ← RemoverEspaçosExtras(texto)
    RETORNAR texto
FIM FUNÇÃO
```

### Anexo B - Matriz de Mapeamento ISO 27001:2022

| Controle ISO | Requisito | Como Esta Norma Atende |
|--------------|-----------|------------------------|
| A.5.15 | Estabelecer controles de acesso | Define identificador único como base para políticas de acesso |
| A.5.16 | Gerenciar identidades de usuários | Estabelece processo de criação de identidades digitais |
| A.5.17 | Proteger informações de autenticação | Garante unicidade e imutabilidade de identificadores |
| A.5.18 | Gerenciar direitos de acesso | Identificador único permite rastreamento de permissões |
| A.8.2 | Acesso privilegiado | Padrão facilita identificação de contas administrativas |

---

## 📍 Localização no SGSI

### Classificação do Documento

**Camada:** **Norma / Padrão**

Este documento é classificado como **Norma** (ou **Padrão Corporativo**) dentro da estrutura do SGSI, situando-se na camada intermediária entre **Políticas** (diretrizes estratégicas de alto nível) e **Procedimentos Operacionais Padrão** (instruções técnicas passo a passo).

### Localização na Estrutura de Diretórios

**Caminho recomendado:**

```
01_SGSI_Fiqueok/
└── 08_Normas_e_Padroes/
    └── 08.1_Gestao_de_Identidade_e_Acesso/
        └── SGSI-NORM-IAM-001_Padrao_Identificador_Usuario_v1.0.md
```

**Estrutura hierárquica do SGSI:**

```
01_SGSI_Fiqueok/
├── 01_Governanca_e_Estrategia/
│   └── (Políticas de alto nível, comitês, estratégia)
├── 02_Gestao_de_Riscos/
│   └── (Metodologia de análise de riscos, planos de tratamento)
├── 03_Compliance_e_SoA/
│   └── (Statement of Applicability, evidências de controles)
|── 04_Pessoas_e_Competencias/
└── 05_Operacao_e_Procedimentos/
|   └── (POPs, runbooks, scripts)
|
| ...
|
├── 08_Normas_e_Padroes/          ◄── LOCALIZAÇÃO DESTE DOCUMENTO
│   ├── 08.1_Gestao_de_Identidade_e_Acesso/
│   │   ├── SGSI-NORM-IAM-001_Padrao_Identificador_Usuario_v1.0.md
│   │   ├── SGSI-NORM-IAM-002_Padrao_Senhas.md (futuro)
│   │   └── SGSI-NORM-IAM-003_Padrao_MFA.md (futuro)
│ ...  
└── 99)Templatens_e_Recursos


### Justificativa da Classificação

| Critério | Justificativa |
|----------|---------------|
| **Natureza do conteúdo** | Define **padrão técnico obrigatório** (formato de identificadores), não apenas diretrizes gerais (política) nem passos de execução (POP). |
| **Nível de abstração** | Intermediário: mais específico que políticas, mais genérico que procedimentos. |
| **Público-alvo** | Múltiplas áreas (RH, IAM, TI, Segurança) que precisam conhecer o padrão, não apenas operadores. |
| **Frequência de mudança** | Relativamente estável (revisão anual), diferente de POPs que podem mudar conforme ferramentas. |
| **Auditabilidade** | Normas são referências diretas em auditorias ISO 27001 (SoA - Anexo A). |
| **Independência de ferramenta** | Não especifica midPoint, Active Directory, etc. - define **o quê**, não **como**. |

### Relacionamento com Outros Documentos

```
POLÍTICA (01_Governanca_e_Estrategia)
    ↓ deriva
NORMA (04_Normas_e_Padroes) ◄── ESTE DOCUMENTO
    ↓ orienta
PROCEDIMENTO (05_Operacao_e_Procedimentos)
    ↓ implementa
AUTOMAÇÃO (Scripts, configurações de IAM)
```

**Exemplo de cascata:**

1. **Política de Controle de Acesso** (estratégica)  
   → Define que "todo usuário deve ter identificador único"

2. **Norma de Padrão de Identificador** (tática) ◄── **ESTE DOCUMENTO**  
   → Define **como** o identificador deve ser formado (`nome.sobrenome`)

3. **POP de Provisionamento de Usuários** (operacional)  
   → Descreve **passo a passo** como criar conta no midPoint usando a norma

4. **Script de Automação**  
   → Implementa o algoritmo definido na norma

---

**FIM DO DOCUMENTO**

---

**Controle de Distribuição:**
- Versão publicada no repositório do SGSI
- Acesso: Colaboradores, Auditores Internos, Auditores Externos (sob NDA)
- Classificação: Uso Interno
