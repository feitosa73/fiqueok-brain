
## **Fase 1: Implementação Bem-Sucedida na OCI (Fevereiro 2026)**

- **Status**: Implementado e funcional[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Localização**: Oracle Cloud Infrastructure - Instância ARM (Ampere) em Vinhedo/Brasil[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Configuração**: 24GB RAM, Ubuntu + Docker + Vault v1.21.2[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Conectividade**: Tailscale Mesh VPN (IP xxx.xxx.xxx.xxx)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Evidências**: Acesso SSH validado, autenticação userpass configurada, prints documentados para LinkedIn[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

## **Incidente Crítico: Perda da Instância OCI**

- **Data**: 08 de fevereiro de 2026[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Causa Raiz**: Erro operacional - clique acidental em "Terminate" ao invés de acessar o terminal[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Impacto**: Perda total da instância (não é possível recuperar instâncias terminadas na OCI)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Tentativa de Recuperação**: Falhou - Oracle não disponibilizou mais instâncias ARM com 24GB RAM gratuitas na região de Vinhedo[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Lição Aprendida**: Necessidade de implementar snapshots/backups automáticos e proteção contra exclusão acidental[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

## **Decisão Arquitetural: Repatriação para Home Lab**

Após a perda da instância na OCI e impossibilidade de recriar com as mesmas especificações gratuitas, a estratégia foi revisada:

**Opções Avaliadas**:

1. ❌ **Recriar no Hyper-V**: Descartado devido a desafios recorrentes de estabilidade e limitações do host PC[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
2. ✅ **WSL2 + Docker**: Escolhida como solução mais estável e gerenciável[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

**Nova Arquitetura (Atual)**:

- **Plataforma**: Windows Subsystem for Linux 2 (WSL2)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Distribuição**: Ubuntu 22.04 LTS[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Runtime**: Docker Engine nativo (não Docker Desktop para evitar erros de npipe)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Usuário**: paulo[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- **Vantagens**:
    
    - Maior estabilidade comparado ao Hyper-V[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
        
    - Facilidade de backup via exportação de VHDX[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
        
    - Isolamento de recursos sem overhead do hypervisor[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
        
    - Acesso direto ao sistema de arquivos do Windows[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
        

## **Impacto no Planejamento Multicloud**

|Componente|Localização Original|Localização Atual|Status|
|---|---|---|---|
|HashiCorp Vault|OCI (Vinhedo)|WSL2 Home Lab|✅ Em implementação|
|GLPI|OCI|**Pendente reavaliação**|⏳ Planejado|
|Wazuh|OCI|**Pendente reavaliação**|⏳ Planejado|
|DefectDojo|OCI|**Pendente reavaliação**|⏳ Planejado|

**Revisão Estratégica Necessária**:

- Avaliar utilização de instâncias AMD (micro) na OCI para serviços menos exigentes[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Considerar distribuição maior de workloads entre AWS e GCP[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
- Implementar política de backup automático antes de novos deployments em cloud[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

## **Lições de Governança (GRC)**

Este incidente gerou aprendizados valiosos para documentação e processos:

1. **Change Management**: Necessidade de procedimento formal para operações destrutivas[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
2. **Backup & Recovery**: Implementar snapshots diários antes de operar instâncias críticas[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
3. **Resource Protection**: Configurar tags de proteção contra exclusão acidental na OCI[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
4. **Documentation**: Este evento reforça a importância de documentar todas as configurações (Infrastructure as Code)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

## **Próximos Passos Ajustados**

**Curto Prazo**:

1. ✅ Finalizar instalação do Docker Engine no WSL2[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
2. ⏳ Deploy do HashiCorp Vault em container no WSL2[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
3. ⏳ Recriar autenticação userpass e políticas RBAC[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    
4. ⏳ Reconectar à malha Tailscale[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​
    

**Médio Prazo**:  
5. Avaliar retorno à OCI com instâncias AMD menores (1GB RAM) para serviços específicos[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​  
6. Implementar GitOps para versionamento de configurações do Vault[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​  
7. Criar runbook de disaster recovery para o laboratório[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​

---

**Resumo Executivo da Mudança**: O Vault foi implementado com sucesso na OCI, mas por erro operacional a instância foi terminada. Devido à indisponibilidade de novas instâncias ARM gratuitas na região, o projeto foi repatriado para o Home Lab utilizando WSL2 como plataforma, priorizando estabilidade e facilidade de gestão. Esta mudança demonstra capacidade de adaptação arquitetural e reforça a importância de práticas de backup e proteção de recursos em ambientes cloud.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/59a69613-3986-4e84-8895-0ed97e755c46/paste.txt)]​


