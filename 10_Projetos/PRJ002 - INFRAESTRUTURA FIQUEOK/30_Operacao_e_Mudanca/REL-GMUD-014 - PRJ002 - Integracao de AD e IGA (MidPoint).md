# Relatório de Encerramento de Mudança (REL-GMUD-014)

## 1. Identificação e Metadados

- **ID da Mudança:** GMUD-014
    
- **Título:** Integração de Provisionamento Outbound AD via LDAPS
    
- **Data de Encerramento:** 26/12/2025
    
- **Responsável:** Paulo (IAM/IGA Lead)
    
- **Status Final:** 🔴 **ENCERRADA SEM SUCESSO (Suspensão Técnica)**
    

---

## 2. Resumo da Execução

A mudança visava estabelecer a comunicação segura entre o midPoint (IGA) e o Active Directory (Target) utilizando o protocolo **LDAPS (Porta 636)**. Foram concluídas com sucesso as fases de infraestrutura do lado do cliente (midPoint), incluindo a injeção da cadeia de confiança na JVM. No entanto, a conexão final falhou durante a negociação de criptografia (Handshake TLS).

### ✅ Etapas Concluídas (Sucesso Parcial de Infraestrutura)

- **Certificação do Consumidor:** Exportação e injeção do `ad_ca.cer` no Keystore Java (`/etc/ssl/certs/java/cacerts`).
    
- **Conectividade de Rede (Layer 4):** Validação de abertura de porta via `nc -zv` e `ping` (Porta 636 respondendo como **OPEN**).
    

### ❌ Fator Impeditivo (Causa da Falha)

- **Falha de Camada 7 (Sessão):** O servidor de destino (`id-p-01`) encerrou a conexão abruptamente (`Connection reset by peer / errno=104`) ao iniciar o handshake TLS.
    
- **Diagnóstico Técnico:** A ausência de apresentação do certificado pelo servidor (identificada via `keytool -printcert` e `openssl s_client`) indica que o serviço LDAPS no AD DS não está devidamente vinculado a um certificado válido ou funcional no repositório **Personal/Computer** do Windows.
    

---

## 3. Análise de Lições Aprendidas (Post-Mortem)

### Por que esta falha não foi prevista no planejamento original?

1. **Presunção de L4 vs. L7:** O plano original baseou-se na premissa de que a porta 636 aberta seria um indicativo de serviço LDAPS pronto para consumo. Em ambientes complexos, a porta pode estar "ouvindo" (Listen), mas sem o _binding_ correto do certificado na camada de aplicação.
    
2. **Ambiente de Lab vs. Prod:** Em laboratórios, a falta de uma Autoridade Certificadora (CA) estruturada ou o uso de certificados sem a finalidade **Server Authentication (EKU)** costuma ser uma falha silenciosa que só se manifesta no ato do handshake.
    

---

## 4. Plano de Recuperação e Próximos Passos

A GMUD-014 será substituída pela **GMUD-015**, que terá como objetivo a remediação do lado do Servidor de Diretório.

- **Ação Corretiva:** Reconfiguração do repositório de certificados do Domain Controller e validação da chave privada vinculada ao serviço NTDS.
    
- **Justificativa:** Sem a estabilização do LDAPS, o provisionamento de senhas da Rose e do Daniel é tecnicamente impossível, violando a diretriz de segurança **ARQ-004**.
    

---

### 📊 Visão Executiva e de Risco (Executive View)

- **Impacto no Cronograma:** Atraso estimado de 24 horas para estabilização do túnel seguro.
    
- **Risco de Segurança:** A suspensão da GMUD-014 evita a exposição de credenciais em texto claro (Porta 389), mantendo o padrão de conformidade exigido pela **ISO 27001**.
    
- **Benefício Estratégico:** A descoberta antecipada desta falha de handshake previne erros intermitentes de produção que seriam muito mais custosos para a **Fiqueok**.