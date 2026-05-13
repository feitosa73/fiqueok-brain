

### O que foi executado corretamente ✅

**Instalação do conector.** O JAR foi corretamente depositado em `/icf-connectors/` — o único diretório que o midPoint 4.10 varre para conectores ICF/ConnId nativos. Colocar em `connid-connectors/` seria um erro silencioso, e vocês acertaram isso.

**Resolução do trustAnchors.** A abordagem de forçar o caminho do cacerts via `JAVA_OPTS` com `-Djavax.net.ssl.trustStore` é a correção canônica documentada pela própria AWS para SDKs Java em containers Docker. Correta.

**Secret Key criptografada no repositório.** A evidência do XML do Resource mostra que o `awsSecretAccessKey` foi armazenado com `<t:encryptedData>` usando AES-256-CBC — o midPoint aplicou automaticamente a criptografia via keystore JCEKS. Isso está em conformidade com ISO 27001 A.8.12 e com as boas práticas da Evolveum.

**Schema Handling com `intent: aws-iam-user`.** Usar um intent nomeado em vez de `default` é a abordagem recomendada quando um resource tem múltiplos tipos de objeto ou quando se quer segregação futura. Tecnicamente correto.

**Correlation configurada.** A correlação por `icfs:name` está correta para o conector Atricore, já que o `__UID__` é o próprio username.

---

### O que precisa de correção técnica ⚠️

**Correlation incompleta.** A correlation rule no XML exportado (`Correlação por UserName`) está estruturalmente vazia — a evidência mostra o bloco `<correlators><items>` sem o `<item>` definindo qual atributo do midPoint se correlaciona com qual atributo do resource. Isso significa que em uma reconciliação, o midPoint pode criar usuários duplicados em vez de vincular os existentes. O correto seria:

```xml
<items>
  <item>
    <path>name</path>
    <search>
      <path>attributes/icfs:name</path>
    </search>
  </item>
</items>
```

**Synchronization ausente.** O Resource XML não tem bloco `<synchronization>`. Isso significa que mesmo com reconciliação rodando, o midPoint não sabe o que fazer com objetos não correlacionados (Unmatched → addFocus) ou com objetos deletados na AWS. A tentativa de adicionar via PUT retornou o erro `objectSynchronization has no definition` exatamente por isso — o XML tentou usar a sintaxe antiga (`objectSynchronization`) que foi substituída por `<synchronization>` no midPoint 4.8+.

**Outbound mapping ausente.** O schema handling atual só tem inbound (`icfs:name → name`). Para provisionamento real (criar usuário na AWS a partir do midPoint), precisa de outbound. A criação do FP004 funcionou porque foi feita via assignment manual na GUI, que usa o `icfs:name` como identificador padrão — mas sem outbound explícito, atributos como `path` e `givenName` não serão enviados.

**PATCH via REST API com XML incorreto.** As tentativas de modificar usuários via `curl -X POST` com body `<modifyUser>` e `<modifications>` falharam com `ClassCastException: RawType`. No midPoint 4.10, a API REST de modificação usa `PATCH` (não `POST`) e o body correto é `<objectModification>` com o namespace `api_types_3`. Isso é um desvio de boas práticas — operações de modificação em produção devem ser feitas via GUI ou via `PATCH /ws/rest/users/{oid}` com o XML correto.

---

### O desafio dos grupos — diagnóstico preciso

O atributo `awsGroups` aparece no schema do conector como multivalor sem `<a:access>read</a:access>` — ou seja, o schema o declara como leitura/escrita. Porém, a análise do código-fonte do Atricore AWSConnector v1.1.2 revela que o método `create()` do conector não itera sobre o atributo `groups` para chamar `AddUserToGroup` após criar o usuário. O atributo é populado apenas no `read()` via `ListGroupsForUser`.

Isso não é uma limitação arquitetural do midPoint — é um bug/feature incompleta do conector da Atricore. A solução correta existe dentro do próprio ecossistema midPoint e será documentada quando Paulo solicitar o PRJ024.

---

### Veredicto geral

O PRJ023 está **75% correto** em relação às boas práticas da Evolveum. O provisionamento de usuários funciona. Os três gaps críticos para o próximo projeto são: correlation completa, bloco de synchronization, e outbound mappings. A questão dos grupos tem solução nativa no midPoint — não requer script externo nem AWS CLI.
