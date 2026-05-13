**Categoria:** AppSec / Vulnerability Management / GRC **Site Oficial:** [defectdojo.org](https://www.defectdojo.org/) **Documentação:** [documentation.defectdojo.com](https://documentation.defectdojo.com/) **Repositório:** [GitHub](https://github.com/DefectDojo/django-DefectDojo)

---

## 1. O que é? (Conceito)

É uma plataforma **Open Source** de gerenciamento de vulnerabilidades e orquestração de segurança de aplicações (AppSec). Ele atua como uma "fonte única da verdade" para todos os achados de segurança, independentemente da origem (scanners automatizados, pentests manuais ou auditorias de conformidade).

## 2. Para que serve? (Função no GRC)

- **Centralização:** Importa relatórios de +150 ferramentas de segurança (SAST, DAST, Infra).
    
- **Normalização:** Padroniza a severidade e a nomenclatura dos riscos.
    
- **Deduplicação:** Identifica se o Scanner A e o Scanner B acharam o mesmo bug, evitando ruído.
    
- **Métricas:** Gera dashboards de SLA (tempo de correção), densidade de defeitos e postura de segurança.
    
- **Governança:** Força fluxos de aceitação de risco e falsos positivos.
    

## 3. Aplicação no Lab Fiqueok

No nosso laboratório, o DefectDojo é o **Dashboard Executivo**.

- Ele recebe os dados brutos do [[OpenVAS (Greenbone)]] (Infraestrutura) e de eventuais scans de código.
    
- Ele é onde simulamos o papel do **Gestor de Vulnerabilidades**, decidindo o que deve ser corrigido e o que é risco aceito.
    

## 4. Diferencial de Mercado (Visão Consultor)

Ferramentas pagas equivalentes custam milhares de dólares (ex: Denim Group ThreadFix, ServiceNow VR). Dominar o DefectDojo permite oferecer uma solução de gestão de nível Enterprise com custo de licenciamento zero para clientes que buscam maturidade em AppSec.
