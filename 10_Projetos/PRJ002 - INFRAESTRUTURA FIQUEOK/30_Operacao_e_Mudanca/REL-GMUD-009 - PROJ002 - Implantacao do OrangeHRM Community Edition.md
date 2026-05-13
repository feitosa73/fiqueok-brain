# Relatório de Encerramento de Mudança 

**ID da Mudança:** GMUD-009

**Título:** Implementação OrangeHRM Community Edition (Fonte Autoritativa)

**Data de Conclusão:** 24 de dezembro de 2025

**Responsável:** Paulo (GRC/IAM Lead) 2

**Status Final:** ✅ **SUCESSO** 3

---

## 1. Resumo da Execução

A implementação do **OrangeHRM Community Edition** foi concluída com êxito no ambiente `IGA-P-01`4. A stack está totalmente operacional, servindo como a **Fonte Autoritativa de Identidades** para o ecossistema de Governança da Fiqueok5. A aplicação foi configurada via Docker Compose e o banco de dados MariaDB foi inicializado e validado666.

+2

---

## 2. Evidências de Implementação e Validação

|**Atividade**|**Resultado Obtido**|**Evidência Técnica**|
|---|---|---|
|**Deploy de Containers**|`orangehrm-db` e `orangehrm-app` em estado _Up (healthy)_777.<br><br>+1|`docker compose ps`8.|
|**Acesso à GUI**|Dashboard acessível em `http://xxx.xxx.xxx.xxx:8081`9.|Login do admin "Paulo" concluído com sucesso10.|
|**Integridade do Banco**|MariaDB 11.4 pronto para conexões e tabelas criadas111111.<br><br>+1|Log: `mariadb: ready for connections`12.|
|**Rede e Conectividade**|Porta 3306 exposta na VM para acesso do midPoint13.|Teste `nc -zv xxx.xxx.xxx.xxx 3306` validado14.|

---

## 3. Controles de GRC Aplicados (Auditoria ISO 27001)

- **Segregação de Redes (A.13.1.1)**: A stack opera na rede bridge isolada `orangehrm_lab_net`, garantindo que a comunicação externa seja restrita às portas necessárias151515.
    
    +1
    
- **Gestão de Segredos (A.9.4.3)**: Implementação de arquivo `.env` para proteção de credenciais, com exclusão via `.gitignore` para prevenir vazamento em repositórios Git161616.
    
    +1
    
- **Menor Privilégio (A.9.2.1)**: Criada a conta `orangehrm_ro` com permissão restrita de `SELECT` na base `orangehrm`, preparando a integração segura para a GMUD-01017.
    
- **Persistência de Dados**: Volumes bind mount configurados para `mariadb_data` e `config`, assegurando a resiliência das identidades em caso de reinicialização181818.
    
    +1
    

---

## 4. Incidentes e Resoluções durante o Deploy

- **Ocorrência**: Falha inicial na subida do MariaDB devido a resíduos de volumes corrompidos19.
    
- **Resolução**: Executado saneamento preventivo via `rm -rf mariadb_data` seguido de ajuste de permissões no sistema de arquivos do host Ubuntu, resultando em inicialização limpa20.
    

---

## 5. Próximos Passos e Pendências

1. **GMUD-010 (Alta Prioridade)**: Criação do Resource no midPoint utilizando o conector `DatabaseTable`21.
    
2. **Carga de Dados**: Cadastro de funcionário fictício no OrangeHRM para validação do fluxo de sincronização (_Live Sync_)22.
    
3. **Documentação**: Atualização do artefato `ARQ003` (Arquitetura de Referência) com os IPs internos finais atribuídos pelo Docker23.
    

---

**Assinatura Digital:** **Paulo – GRC/IAM Lead (Fiqueok Consultoria)** 24
