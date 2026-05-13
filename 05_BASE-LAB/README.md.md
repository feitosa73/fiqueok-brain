# 📦 BASE-LAB — Fundação Estrutural do Fiqueok Living Lab

## 1. Propósito

A **BASE-LAB** concentra todos os **artefatos estruturais, metodológicos e arquiteturais** que **não pertencem a um projeto específico**, mas que **servem como fundação reutilizável** para múltiplos projetos do Fiqueok Living Lab.

Ela existe para evitar:

- Redefinição recorrente de conceitos
    
- Cópias inconsistentes de documentos críticos
    
- Acoplamento indevido entre projetos
    
- Perda de rastreabilidade arquitetural e metodológica
    

> **Princípio-chave:**  
> Projetos consomem a BASE.  
> A BASE **não depende** de projetos.

---

## 2. O que é BASE-LAB (e o que não é)

### ✅ É:

- Repositório de **decisões fundacionais**
    
- Biblioteca de **arquiteturas de referência**
    
- Fonte única de **processos e metodologias**
    
- Base de **padrões reutilizáveis**
    
- Núcleo de **governança do laboratório**
    

### ❌ Não é:

- Um projeto
    
- Um backlog
    
- Um dump de arquivos antigos
    
- Um local para documentação operacional de execução
    
- Um histórico de mudanças (isso é GMUD)
    

---

## 3. Estrutura da BASE-LAB

`05_BASE-LAB/ │ ├── 01_Documentos-Fundacionais/ │   └── (DOC-ARC, manifestos, decisões estruturais) │ ├── 02_Arquiteturas-de-Referencia/ │   └── (ARQ-001+, arquiteturas lógicas, técnicas e conceituais) │ ├── 03_Metodologia-e-Frameworks/ │   └── (POP, fluxos, modelos de governança, frameworks) │ ├── 04_POCs-e-PADROES/ │   └── (padrões técnicos, provas de conceito reutilizáveis) │ ├── 99_Governanca-do-Lab/ │   └── (regras, políticas internas, decisões do laboratório) │ └── README.md`

---

## 4. Critérios de Inclusão de Conteúdo

Um artefato **DEVE** estar na BASE-LAB se:

- Pode ser reutilizado por **mais de um projeto**
    
- Define **como pensar**, não apenas **como executar**
    
- Estabelece **regras, padrões ou referências**
    
- Representa uma **decisão estrutural ou metodológica**
    
- Deve sobreviver ao encerramento de um projeto
    

Um artefato **NÃO DEVE** estar na BASE-LAB se:

- Refere-se a uma execução específica
    
- Tem dependência direta de escopo, prazo ou ambiente
    
- Existe apenas para justificar uma mudança (GMUD)
    
- É temporário ou exploratório sem maturidade
    

---

## 5. Relação com Projetos (PRJ)

- Projetos **não copiam** arquivos da BASE
    
- Projetos **referenciam** a BASE via links ou citações
    
- Atualizações na BASE:
    
    - Devem ser **raras**
        
    - Devem ser **deliberadas**
        
    - Preferencialmente formalizadas via GMUD
        

> Se um projeto precisa “alterar” a BASE, isso é um **sinal arquitetural**, não um detalhe operacional.

---

## 6. Evolução e Governança

A BASE-LAB é um **ativo vivo**, porém **controlado**.

Mudanças típicas aceitáveis:

- Consolidação de arquiteturas
    
- Generalização de padrões
    
- Extração de aprendizados recorrentes
    
- Formalização de metodologias maduras
    

Mudanças não aceitáveis:

- Ajustes táticos para destravar execução
    
- Customizações para um único projeto
    
- Decisões apressadas sem impacto transversal
    

---

## 7. Regra de Ouro

> **Se este arquivo fosse deletado amanhã,  
> todos os projetos deveriam continuar existindo,  
> mas com perda significativa de qualidade arquitetural.**

Se isso não for verdade, o arquivo **não pertence à BASE-LAB**.

---

## 8. Status

- **Estado:** Ativo
    
- **Responsável:** Owner do Living Lab
    
- **Escopo:** Transversal a todos os projetos Fiqueok