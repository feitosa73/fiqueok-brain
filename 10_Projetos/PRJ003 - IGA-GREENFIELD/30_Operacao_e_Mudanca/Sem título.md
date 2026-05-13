## 

A GMUD-011 foi executada em 21 de janeiro de 2026 às 17:57 UTC e **falhou** devido à mesma causa raiz das tentativas anteriores, mas com diagnóstico definitivo.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7c79cf35-634b-4ec6-82e5-07a9c240cee5/paste.txt)]​

## Causa Raiz Confirmada

O script `entrypoint.sh` da imagem `evolveum/midpoint:4.9` possui lógica interna que **ignora completamente** as variáveis `REPO_DATABASE_TYPE` e `REPO_JDBC_URL`. O log mostra que, apesar de ter sido configurado `REPO_DATABASE_TYPE: postgresql`, o midPoint processou `midpoint.repository.database .:. h2`, forçando o banco H2 incompatível com o repositório Native.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7c79cf35-634b-4ec6-82e5-07a9c240cee5/paste.txt)]​

## Evidências Técnicas

O PostgreSQL 16 iniciou corretamente e o schema foi provisionado com sucesso (164 objetos de banco criados via injeção manual dos arquivos `postgres.sql`, `postgres-audit.sql` e `postgres-quartz.sql`). Entretanto, quando o container `iga-midpoint` iniciou, o log registrou:[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7c79cf35-634b-4ec6-82e5-07a9c240cee5/paste.txt)]​

text

`Processing variable (MAP) ... midpoint.repository.database .:. h2 Unsupported database type: h2`

Isso comprova que a camada de entrypoint da imagem sobrescreveu as variáveis de ambiente antes de passar os parâmetros para a JVM.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7c79cf35-634b-4ec6-82e5-07a9c240cee5/paste.txt)]​

## Lições Aprendidas

- A imagem Docker oficial do midPoint 4.9 tem automação de detecção de banco que pode entrar em conflito com configurações explícitas
    
- As variáveis `REPO_*` são processadas pelo `entrypoint.sh`, não diretamente pelo motor Java
    
- O midPoint 4.9 rejeita H2 quando o repositório Native está configurado, gerando falha imediata na inicialização
    
- Scripts SQL de validação precisam de aspas corretas (`'public'` ao invés de `public`)[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7c79cf35-634b-4ec6-82e5-07a9c240cee5/paste.txt)]​
    

## Próximos Passos

Para a **GMUD-012**, será implementada a técnica de **Soberania Total de Variáveis** usando o prefixo `MP_SET_` para injetar propriedades Java diretamente, contornando a lógica do `entrypoint.sh`. Esta abordagem injeta as propriedades `midpoint.repository.database=postgresql` e `midpoint.repository.type=native` diretamente no motor Java, impedindo que a imagem "adivinhe" o banco de dados.[[ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/69453806/7c79cf35-634b-4ec6-82e5-07a9c240cee5/paste.txt)]​
