# 

> Status: Em Construção
> 
> Visão: Arquitetura de Segurança, GRC & CISO Enablement
> 
> Owner: Paulo (Fiqueok Consultoria)

## 1. O Conceito (Visão Estratégica)

Este ambiente é um **Ecossistema Integrado de Experimentação e Governança**, projetado para transpor a teoria dos frameworks de segurança para a prática tecnológica.

Não se trata apenas de configurar ferramentas, mas de simular a convergência entre:

1. **Infraestrutura de Base:** Redes e Diretórios (AD).
    
2. **Operação de Cibersegurança:** Tecnologias de defesa e controle (IAM, PAM, IGA, SIEM, DLP, AppSec).
    
3. **Gestão de Risco e Conformidade (GRC):** Aplicação prática de normas (ISO 27001, CIS Controls, NIST) orquestrada por plataformas de gestão como o DefectDojo.
    

**Objetivo Final:** Habilitar a atuação de alto nível como **Arquiteto de Soluções**, **Gestor de Cibersegurança (CISO)** e **Líder de GRC**, desenvolvendo competências para desenhar, implementar e auditar ambientes corporativos complexos.

---

## 2. Preparação do Host (Pre-Lab / Hardening)

_Ações realizadas na estação de trabalho física para garantir recursos e foco para o laboratório._

### A. Segregação de Perfis (Context Isolation)

Separação lógica de usuários no Windows 11 para garantir integridade e performance:

- **Perfil Gamer:** Focado em lazer.
    
- **Perfil GRC (Fiqueok):** Ambiente de trabalho "limpo" e otimizado para Docker e VMs.
    
    - _Ação:_ Remoção de bloatware e otimização de memória via PowerShell.
        

### B. Gestão do Conhecimento (Second Brain)

- **Ferramenta:** Obsidian (Metodologia PARA).
    
- **Função:** Documentar a evolução técnica e transformá-la em ativo intelectual da consultoria.
    

### C. Camada de Gestão (AppSec & GRC Management)

- **Ferramentas:** Docker Desktop (WSL2) + DefectDojo + OpenVAS.
    
- **Função:** Atuar como o "Painel de Controle Executivo" que centraliza os riscos identificados no ambiente simulado.
    

---

## 3. Arquitetura do Laboratório Virtual (O Cenário Simulado)

_Ambiente isolado (VirtualBox) onde as tecnologias são testadas e os frameworks aplicados._

### A. Infraestrutura e Perímetro

- **Ativos:** Linux Lite (Proxy/Gateway) + Windows Server (AD).
    
- **Escopo:** Redes, Firewalls (FW) e segmentação.
    

### B. Identidade e Acesso (Identity Fabric)

- **Escopo:** IAM, PAM e IGA.
    
- **Cenário:** Simulação de ciclo de vida de identidade, privilégio mínimo e federação usando o Active Directory como core.
    

### C. Segurança Ofensiva e Defensiva (SecOps)

- **Escopo:** SIEM, DLP, SASE e scans de vulnerabilidade (SAST/DAST).
    
- **Cenário:** Detecção de ameaças e resposta a incidentes nos endpoints clientes (Win11/Linux).
    

---

## 4. Log de Decisões e Referências (Audit Trail)

_Rastreabilidade das definições estratégicas e técnicas tomadas durante a construção._

|**Fase**|**Tópico**|**Link de Referência (Evidência)**|
|---|---|---|
|**Planejamento**|Definição da Topologia (Lab + Linux Proxy)|[🔗 Ver Chat: Planejamento](https://gemini.google.com/share/c46517c4bc72)|
|**Conhecimento**|Estruturação do Segundo Cérebro (Obsidian)|[🔗 Ver Chat: Configuração Obsidian](https://gemini.google.com/share/e165147211c4)|
|**AppSec/GRC**|Implementação DefectDojo e OpenVAS|[🔗 Ver Chat: Docker e Ferramentas](https://gemini.google.com/share/0f4467b9dd2a)|
