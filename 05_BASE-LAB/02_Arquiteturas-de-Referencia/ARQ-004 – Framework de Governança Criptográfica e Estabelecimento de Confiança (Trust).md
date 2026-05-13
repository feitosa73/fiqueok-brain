# 

## 1. Propósito e Aplicabilidade

Esta arquitetura define o padrão para o estabelecimento de comunicações seguras entre entidades computacionais (Sistemas, Usuários, Dispositivos). O foco é garantir a tríade **Confidencialidade, Integridade e Autenticidade** em qualquer fluxo de dados que transite por redes internas ou externas, atendendo aos requisitos de conformidade da **ISO 27001 (A.10.1)**.

## 2. Princípios Fundamentais (Agnósticos)

Para que qualquer integração seja considerada segura na Fiqueok, ela deve seguir estes quatro pilares:

1. **Identidade Verificável (Authentication):** Toda entidade provedora de serviço deve provar sua identidade através de uma credencial digital (Certificado) emitida por uma autoridade reconhecida.
    
2. **Criptografia em Trânsito (Encryption):** Dados sensíveis (senhas, PII, chaves) jamais devem trafegar em texto claro (Cleartext). O uso de protocolos de túnel seguro (TLS/SSL) é mandatório.
    
3. **Cadeia de Confiança Explícita (Trust Store):** O sistema consumidor não deve "aceitar qualquer conexão". Ele deve possuir um inventário controlado de chaves públicas das entidades nas quais confia.
    
4. **Não-Repúdio e Integridade:** A comunicação deve garantir que o dado enviado não foi alterado no percurso e que a origem é legítima.
    

## 3. Modelo Lógico de Interoperação

|**Papel**|**Descrição Abstrata**|**Exemplo de Aplicação**|
|---|---|---|
|**Provedor (Source/Target)**|Entidade que expõe o serviço e apresenta sua identidade digital.|Domain Controller, Database, Web Server.|
|**Consumidor (Client/Integrator)**|Entidade que solicita o serviço e valida a identidade do Provedor.|Motor de IGA, Aplicação, Proxy.|
|**Ativo Criptográfico**|Certificado Público (X.509) que contém a chave pública do Provedor.|Arquivo `.cer`, `.crt` ou `.pem`.|
|**Cofre de Confiança**|Repositório seguro no Consumidor onde os certificados confiáveis são armazenados.|Java Keystore, Windows Root Store, Linux `/etc/ssl/certs`.|

## 4. Governança e Ciclo de Vida (ISO 27001)

Como Auditor, você deve validar:

- **Gestão de Validade:** Certificados devem ter data de expiração monitorada para evitar indisponibilidade de negócio.
    
- **Revogação:** Processo para invalidar chaves comprometidas (CRL/OCSP).
    
- **Segregação:** Chaves privadas devem ser inacessíveis ao sistema consumidor, permanecendo apenas no Provedor.
    

---

### 📊 Visão de Negócio e Impacto (Executive View)

- **Proteção do Ativo Intelectual:** Ao padronizar a ARQ-000, a Fiqueok reduz a superfície de ataque para movimentação lateral e interceptação de dados, protegendo o valor de mercado da empresa.
    
- **ROI de Governança:** A adoção de padrões agnósticos reduz o custo de integração de novas tecnologias, pois o modelo de segurança já está pré-aprovado pela auditoria.