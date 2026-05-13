**Nome Atual:** Greenbone Vulnerability Management (GVM) **Categoria:** Vulnerability Scanner / Infrastructure Security / DAST **Site Oficial:** [greenbone.net](https://www.greenbone.net/) **Repositório:** [GitHub Greenbone](https://github.com/greenbone)

---

## 1. O que é? (Conceito)

É um framework **Open Source** para varredura e gerenciamento de vulnerabilidades. Diferente de ferramentas que analisam código (SAST), o OpenVAS olha para a **infraestrutura ativa**: ele testa portas abertas, serviços rodando, configurações de SSL/TLS e versões de softwares em servidores e endpoints, comparando o que encontra com uma base de dados de ameaças conhecidas (NVTs - Network Vulnerability Tests).

## 2. Para que serve? (Função no GRC)

- **Descoberta de Ativos:** Mapeia o que está vivo na rede (quem não é visto, não é auditado).
    
- **Identificação Técnica de Riscos:** Traduz "falta de patch" em "CVE crítica com exploit disponível".
    
- **Validação de Compliance:** Verifica se as configurações técnicas (Hardening) estão aderentes a políticas como CIS Benchmarks.
    
- **Auditoria Contínua:** Permite agendar scans periódicos para garantir que novas vulnerabilidades não surgiram no ambiente.
    

## 3. Aplicação no Lab Fiqueok

No nosso laboratório, o OpenVAS é o **Motor de Detecção**.

- Ele será instalado via Docker no host.
    
- Ele varrerá os alvos do laboratório (como a VM do Windows 11 Enterprise e o Windows Server AD).
    
- **A Conexão:** Os relatórios gerados por ele (XML) não ficam isolados; eles são exportados e ingeridos pelo **[[DefectDojo]]**, centralizando a gestão do risco.
    

## 4. Diferencial de Mercado (Visão Consultor)

O OpenVAS é a principal alternativa gratuita aos gigantes de mercado como **Tenable Nessus** e **Qualys**.

- **Pró:** Custo zero de licenciamento, permitindo varrer redes inteiras sem pagar por "IP".
    
- **Contra:** Interface menos amigável e requer maior expertise técnica para configuração e tuning.
    
- **Posicionamento:** Ideal para empresas que estão iniciando programas de GRC ou consultorias que precisam realizar diagnósticos técnicos de baixo custo inicial.
