# 

Local: 30_Recursos/00_Metodologia_Fiqueok/MET-001.md

Tipo: Metodologia Corporativa

Versão: 1.1 (Revisada)

Status: Definitivo

---

## 1. O Manifesto de Integração

Na Fiqueok Consultoria, rejeitamos a visão tradicional onde "Segurança" (GRC) e "Tecnologia" (Engenharia) operam em silos. Adotamos uma abordagem unificada onde **a Segurança é um atributo de qualidade da Arquitetura**, e não uma camada adicionada posteriormente.

Para garantir decisões consistentes, unificamos os princípios de **SGSI (Sistema de Gestão de Segurança da Informação)** com a **EA (Enterprise Architecture)**.

## 2. A Cadeia de Valor da Decisão (Traceability)

Todas as decisões técnicas tomadas em projetos devem possuir **Rastreabilidade Vertical**. A tabela abaixo define a hierarquia dos artefatos e seu local físico no nosso Sistema de Gestão (Obsidian).

### O Modelo de 4 Camadas (Hibridismo GRC + EA)

|**Nível**|**Artefato**|**Origem**|**Pergunta Respondida**|**Local Padrão no Obsidian**|
|---|---|---|---|---|
|**1. Estratégico**|**Política**|**GRC**|_O que devemos proteger e por quê?_|`20_Areas/01_SGSI_Fiqueok/01_Governanca_e_Estrategia`|
|**2. Tático**|**Diretriz**|**Joint**|_Qual a direção estratégica para resolver isso?_|`30_Recursos/00_Metodologia_Fiqueok` (Referência) ou `20_Areas/01_SGSI.../02_Normas` (Regra)|
|**3. Técnico**|**Padrão**|**EA**|_Qual o modelo reutilizável aprovado?_|`20_Areas/01_SGSI_Fiqueok/02_Normas` (Ex: Hardening, Padrão de Nomenclatura)|
|**4. Execução**|**Decisão (ADR)**|**Eng.**|_Qual a escolha específica para este contexto?_|`10_Projetos/{Projeto}/Docs` (Durante Projeto) ➔ `30_Recursos` (Se virar legado)|

**Exemplo Prático (Identidade):**

1. **Política:** `PSI-001` (Acesso deve ser controlado) ➔ _Está em 20_Areas...01_Governanca_
    
2. **Diretriz:** `PAD-001` (Usaremos IGA Centralizado) ➔ _Está em 30_Recursos..._
    
3. **Padrão:** `STD-LINUX-01` (Ubuntu Server LTS) ➔ _Estará em 20_Areas...02_Normas_
    
4. **Decisão:** `DDR-001` (Deploy MidPoint via Docker) ➔ _Está em 30_Recursos..._
    

## 3. Princípios Orientadores (Design Principles)

Para garantir que as próximas decisões sigam este modelo, estabelecemos os seguintes princípios:

1. **Segurança como Requisito Não-Funcional:** Não existe "Projeto de Segurança" separado do "Projeto de Arquitetura". A segurança está embutida nos requisitos de arquitetura (SABSA Framework).
    
2. **Compliance by Design:** As tecnologias escolhidas (Nível 4) devem facilitar nativamente o cumprimento das Políticas (Nível 1).
    
    - _Exemplo:_ Escolher MidPoint (Tecnologia) porque ele já gera os logs de auditoria exigidos pela Política de Acesso (Política).
        
3. **Evitar Débito de Governança:** Implementar uma tecnologia sem a correspondente Política ou Padrão é proibido. Isso cria "Shadow IT".
    
4. **Reuso antes de Compra/Build:** Antes de decidir por uma nova tecnologia (ADR), deve-se verificar se já existe um Padrão (Nível 3) definido na biblioteca da Fiqueok (`30_Recursos`).
    

## 4. Referências Cruzadas de Frameworks

Esta metodologia se baseia na harmonia entre:

- **ISO/IEC 27001:** Para definir o SGSI e Gestão de Riscos.
    
- **TOGAF (The Open Group Architecture Framework):** Para estruturar os domínios de Negócio, Dados, Aplicação e Tecnologia.
    
- **SABSA (Sherwood Applied Business Security Architecture):** Para mapear os atributos de segurança aos objetivos de negócio.
