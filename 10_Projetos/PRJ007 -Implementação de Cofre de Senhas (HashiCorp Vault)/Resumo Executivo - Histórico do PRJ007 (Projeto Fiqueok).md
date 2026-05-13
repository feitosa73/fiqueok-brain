

## 

## Contexto do Projeto

O PRJ007 (Fiqueok) é um Living Lab de Governança, Risco e Conformidade (GRC) focado em Identity and Access Management (IAM), desenvolvido para demonstrar competências práticas em segurança cibernética, gestão de identidades e arquitetura híbrida.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​

## Objetivos Estratégicos

- **Visão de Negócio**: Simular gestão do ciclo de vida de segurança integrando camadas heterogêneas (nuvem, on-premise, legado) em ecossistema único e auditável[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Diferencial**: Demonstrar segurança de nível enterprise com eficiência de custos (FinOps) e agilidade[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Propósito Profissional**: Transição de carreira para especialização em Auditoria, GRC e IAM, saindo da execução operacional para posições estratégicas[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

## Infraestrutura Implementada

## **Fase 1: Implementação do HashiCorp Vault na OCI**

- **Data**: Início de fevereiro de 2026[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Objetivo**: Centralizar gestão de segredos e eliminar credenciais hardcoded[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Tecnologias**:
    
    - Oracle Cloud Infrastructure (OCI) - Instância Ubuntu[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
        
    - HashiCorp Vault v1.21.2 via Docker[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
        
    - Tailscale Mesh VPN para conectividade Zero Trust[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
        

**Conquistas Técnicas**:

- Configuração de autenticação baseada em usuário (userpass) substituindo root token[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Implementação de políticas de privilégio mínimo (RBAC)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Acesso via IP privado Tailscale (xxx.xxx.xxx.xxx) sem exposição pública[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Configuração de swap de 2GB para otimização de recursos[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

## **Fase 2: Governança Financeira (FinOps)**

- **Implementação**: Budget de R$ 5,00 com alertas na OCI[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Estratégia**: Monitoramento preventivo com threshold de R$ 0,01 em gasto previsto[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Justificativa GRC**: Visibilidade total sobre custos de infraestrutura como parte da governança operacional[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

## **Fase 3: Arquitetura de Rede Zero Trust**

- **Solução**: Tailscale Mesh VPN conectando ambiente híbrido[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Topologia**:
    
    - Servidor OCI (srv-oci-fiqueok-01): xxx.xxx.xxx.xxx[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
        
    - Desktop local (desktop-o87tpqi)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
        
    - OrangeHRM (rh-gf-01): xxx.xxx.xxx.xxx[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
        
    - Outras VMs: iga-gf-01, fok-ldap-01[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
        

**Validação Técnica**:

- Latência OCI via Tailscale: média 78ms[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Latência OrangeHRM via Tailscale: média 8ms[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- SSH funcional entre todos os nós da malha[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

## Stack Tecnológica Planejada

| Ferramenta      | Localização Planejada | Justificativa GRC                                                                                                                                                                                                                       |
| --------------- | --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| HashiCorp Vault | OCI (Brasil)          | Centralização de segredos, mitigação de vazamentos [[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​               |
| GLPI            | OCI                   | Gestão de ativos (ISO 27001 - A.8) [[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​                               |
| IGA midPoint    | On-Premise            | Automação de Joiner/Mover/Leaver, prevenção de usuários fantasma [[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​ |
| OrangeHRM       | On-Premise            | Fonte primária de identidades (RH) [[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​                               |
| OpenLDAP        | GCP/OCI               | Diretório leve para autenticação [[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​                                 |
| Wazuh (SIEM)    | OCI                   | Detecção e resposta, audit logs centralizados [[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​                    |
| DefectDojo      | OCI                   | Gestão de vulnerabilidades (AppSec) [[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​                              |
| OpenVAS         | On-Premise            | Scanner de vulnerabilidades (alta CPU) [[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​                           |
| Zabbix          | AWS                   | Monitoramento de disponibilidade cross-cloud [[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​                     |
| Azure Entra ID  | Azure (SaaS)          | Governança de identidade cloud-native [[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​                            |

## Estratégia Multicloud

**Distribuição por Provedor**:

- **OCI (Oracle)**: Operações pesadas (Wazuh, Vault, GLPI, DefectDojo) - até 24GB RAM gratuitos[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **AWS**: Monitoramento e auditoria (Zabbix, CloudWatch) - t3.micro 12 meses grátis[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Azure**: Governança de identidade (Entra ID) - serviço SaaS gratuito[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **GCP**: Diretório alternativo (OpenLDAP) - e2-micro always free[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **On-Premise**: Fonte de dados e scanners intensivos (OrangeHRM, midPoint, OpenVAS)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

**Justificativa Estratégica**:

- Resiliência: Falha em um provedor não paralisa todo o laboratório[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Mitigação de vendor lock-in[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Conformidade com LGPD: Soberania de dados com storage no Brasil[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

## Desafios Técnicos Enfrentados

1. **Erro de Autenticação SSH**: Resolvido com identificação correta da chave privada (oci_fiqueok_key)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
2. **Conectividade Tailscale**: Solucionado com troubleshooting de DNS e reinicialização do serviço[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
3. **Limitações de RAM na OCI**: Planejamento de distribuição multicloud[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
4. **Limitações do Host PC**: Dificuldades para criar novas VMs no Hyper-V local[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
5. **Mudança de Topologia de Rede**: Migração de 172.16.0.x (Internal) para 10.0.20.x (External) causou desconexão temporária[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

## Fase Atual: Implementação do Vault no WSL2

**Decisão Arquitetural** (Fevereiro 2026):

- Mudança de Hyper-V para WSL2 (Ubuntu 22.04) como Control Plane local[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Usuário criado: paulo[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Próximos passos: Instalação do Docker Engine nativo e deployment do Vault Primary[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

**Justificativas**:

- Maior estabilidade comparado ao Hyper-V[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Isolamento de recursos[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Facilidade de backup via exportação VHDX[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Evitar erros de npipe do Docker Desktop[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

## Documentação de Rede Atual

**ID-P-01 (Servidor LDAP)**:

- IP atual: 10.0.20.10[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Máscara: 255.255.255.0[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Switch: vSwitch_External_PRJ003 (mode External)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Hostname: id-p-01.fiqueok.corp[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Status: Aguardando reconfiguração de gateway para acesso à internet[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

**IGA-P-01 (Docker Host)**:

- IP: xxx.xxx.xxx.xxx[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Redes Docker internas: 172.18.0.0/16, 172.19.0.0/16, 172.20.0.0/16[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

## Proposta de Valor para o Mercado

**Por que contratar este especialista**:

1. **Tradutor Técnico-Executivo**: Converte vulnerabilidades em planos de ação de negócio[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
2. **Security by Design**: Testa arquiteturas na prática antes de recomendar[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
3. **Especialista em Identidade**: Nicho escasso com pós-graduação em IAM e experiência prática[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
4. **FinOps**: Entrega soluções enterprise com otimização extrema de custos[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

## Marcos para LinkedIn

**Posts Publicados/Planejados**:

- Migração do Vault para OCI com Zero Trust[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Implementação de Cloud Governance (FinOps)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Manifesto: "Por que construir um Living Lab em vez de apenas certificações"[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

## Próximas Etapas Documentadas

1. Finalizar instalação do Vault no WSL2[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
2. Implementar GLPI na OCI para inventário de ativos[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
3. Configurar Wazuh para centralização de logs[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
4. Integrar midPoint com Azure Entra ID via OIDC/SAML[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
5. Estabelecer segunda conta OCI em Ashburn (EUA) para resiliência geográfica[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

---

Este resumo consolida todo o histórico técnico, estratégico e de governança do PRJ007, pronto para ser utilizado como base para o documento de atualização do projeto.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
