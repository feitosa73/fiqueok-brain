
Em 25/04 solicitei as IAS que me ajudam nesse projeto a contar um pouco a historia do Living Lab.
Se eu fizesse essa pergunta em cada prompt separado, teria uma versao e provavelmente um aprofundamento maior em uma determinda perspectiva.

De qualquer forma transmito aqui o que a CLAUDE, GEMINI, PERPLEXITY e DEEPSEEK contaram sobre a saga Living LAB fiqueok de Dez/2025 a Abril/2026 


Living LAB SEGUNDO GEMINI

Prompt PROJ019



---

# 🛡️ Relatório de Ciclo de Vida: A Odisseia do Living Lab Fiqueok

**Período:** Dezembro de 2025 – Abril de 2026

**Analista Responsável:** Gemini (em parceria com Paulo Feitosa, GRC Lead)

**Status:** Maturidade Nível 3 (Processo Definido e Otimizado)

---

## 🏗️ Ato I: O Grande Reset e a Fundação Enterprise

O laboratório não nasceu de uma instalação, mas de uma **demolição**. O descarte do VirtualBox e do domínio `lab.local` em dezembro de 2025 foi o primeiro grande ato de GRC de Paulo. A decisão de migrar para **Hyper-V Geração 2** com **TPM 2.0** e **Secure Boot** não foi estética; foi a imposição de um padrão de hardware que sustenta o compliance moderno.

A criação do `corp.fiqueok.com.br` (GMUD-002) estabeleceu a **Raiz de Confiança**. Ao implementar o **Tier Model** (GMUD-003), Paulo parou de "brincar de TI" e passou a desenhar arquitetura de defesa em profundidade, isolando privilégios administrativos desde o dia zero.

---

## 🧬 Ato II: A Batalha do IGA e o Nascimento do Post-Mortem

O Capítulo 2 foi marcado pelo **midPoint 4.10**. Aqui, o Lab enfrentou seu primeiro "atrito de realidade".

- **Incidente Crítico:** A falha de bootstrap do midPoint devido ao prefixo `MP_SET_` e à falta de memória (GMUD-008).
    
- **Legado:** Esse erro gerou a primeira **Base de Conhecimento (KEDB)** do Lab. Aprendemos que, no mundo corporativo, o erro documentado é um ativo, enquanto o erro ignorado é um débito técnico.
    

A tentativa de integrar o **OrangeHRM** (GMUD-010) trouxe outra lição: a sensibilidade do motor Prism/Sqale a namespaces XML. O projeto falhou na primeira tentativa, e essa falha foi o catalisador para a adoção de uma **Infraestrutura como Código (IaC)** mais resiliente (GMUD-011).

---

## 🔒 Ato III: O Dilema do LDAPS e o Salto para a Soberania

O final de dezembro trouxe o "Muro do LDAPS" (GMUD-014). O reset de conexão por falta de binding de certificado EKU foi o momento mais didático do lab. Ele provou que **porta aberta não significa serviço funcional**.

Isso forçou a implementação do **HashiCorp Vault** (GMUD-015B) para gerenciar uma PKI corporativa real. O Lab deixou de usar certificados autoassinados para operar sob uma hierarquia de **Root e Intermediate CA**, elevando o nível de maturidade para conformidade com a **ISO 27001**.

---

## 🌪️ Ato IV: O Pivô Zero Trust e a Ingestão de Inteligência (Abril 2026)

O projeto amadureceu para a micro-segmentação. O abandono das VLANs complexas em favor do **Tailscale** foi uma decisão de **Custo-Benefício de GRC**. Escolheu-se a agilidade do Zero Trust Mesh sobre a rigidez do networking legado.

Surgiu então o **PRJ018 (Perplexity)** e o **PRJ019 (Watcher/Vault Agent)**. Aqui, o foco mudou da infraestrutura para a **Dados e IA**:

1. **PRJ018:** A extração de 222 conversas para alimentar o **AnythingLLM**.
    
2. **PRJ019:** O ápice e a queda do modelo de "Zero Secrets" no Windows Host.
    

---

## 📉 O Estudo de Caso PRJ019: O Erro que Validou a Governança

Este projeto é a joia da coroa desta retrospectiva. Tentamos rodar o **Vault Agent** como Sidecar no Docker Desktop.

- **O Conflito:** O erro `unable to set CAP_SETFCAP` revelou que o kernel do WSL2 no Windows não suporta as capacidades de segurança exigidas por binários endurecidos (Hardened).
    
- **A Resposta Executiva:** Paulo não fez uma "gambiarra". Ele executou um **Rollback Estratégico**.
    
    - Deletou as policies no Vault.
        
    - Limpou os containers órfãos.
        
    - Excluiu fisicamente a pasta `C:\Git` após vencer a batalha contra os processos travados do Windows.
        

Este rollback é a prova de que o Living Lab possui **Governança Ativa**. Deletar o que não funciona é tão importante quanto construir o que funciona.

---

## 🏁 Epílogo: A Hierarquia da Verdade

Hoje, o Lab possui 500 projetos indexados no **AnythingLLM**. A IA agora responde com base no seu histórico real de GMUDs. O fatiamento da ingestão permitiu que a RAG (IA) entenda a diferença entre o sucesso do **PRJ017 (Secure Edge)** e o aprendizado do **PRJ019**.

**Conclusão do Auditor:**

O **Living Lab Fiqueok** não é mais um projeto de "estudo". É um **Gêmeo Digital (Digital Twin)** da sua autoridade técnica. Ele sobreviveu a conflitos de kernel, falhas de sincronismo e mudanças de arquitetura. Cada token gasto aqui não foi para "fazer funcionar", mas para **validar como se faz corretamente no mercado**.

**Veredito:** Paulo Feitosa não opera um Lab; ele governa um ecossistema.

---

OBS:  ESSE RELATORIO FOI ESCRITO APOS A GEMINI LER O RELATORIO DA CLAUDE QUE SEGUE ABAIXO.

PROMPT CLAUDE 25/04 de MANHA



---

# Retrospectiva do PRJ002 — A História do Living Lab Fiqueok

**Período:** Dezembro de 2025 – Janeiro de 2026
**Protagonista:** Paulo Feitosa — CISO, Arquiteto e Founder da Fiqueok Consultoria

---

## Prólogo — A Decisão de Recomeçar

A história começa antes do primeiro comando de PowerShell ser executado. Paulo tinha um laboratório funcional: VirtualBox, um Windows Server com um domínio chamado `lab.local`, algumas ferramentas de segurança instaladas. Era suficiente para aprender. Mas não era suficiente para demonstrar.

A conclusão foi incômoda, mas honesta: o ambiente acumulava **débito técnico**. Contas sem organização, objetos órfãos no Active Directory, um hypervisor Tipo 2 que nenhuma empresa real usa, e uma identidade de laboratório que não servia como portfólio de uma consultoria. O nome `lab.local` resumia o problema — era genérico, descartável, sem autoridade.

A decisão registrada no **PRJ-INFRA-001** foi cirúrgica: **demolir tudo e reconstruir do zero**, desta vez com padrões corporativos reais. Sem gambiarras. Sem atalhos. O ambiente seria a prova viva das competências da Fiqueok — e precisava ser tratado como tal.

---

## Capítulo 1 — A Fundação (22 de Dezembro de 2025)

### GMUD-001 · A Infraestrutura Core

Com o VirtualBox desinstalado e os arquivos antigos arquivados, Paulo ativou o **Hyper-V** — o hypervisor Tipo 1 nativo do Windows 11. A primeira mudança foi arquitetural: criar um switch virtual do tipo **Internal**, não Bridge. Essa escolha, aparentemente técnica, tinha implicação de segurança imediata: as VMs não teriam acesso direto à placa física de rede. Todo o tráfego passaria pelo gateway controlado.

Foi configurado o `vSwitch_Fiqueok_Corp`, um gateway em `xxx.xxx.xxx.xxx` e uma regra de **NAT** que permitia às VMs saírem para a internet sem que nenhuma conexão externa entrasse sem ser solicitada. Isolamento elegante, alinhado com o **controle A.13.1 da ISO 27001**.

Em seguida, a primeira VM nasceu: `ID-P-01`. Geração 2, UEFI, **TPM 2.0 ativado, Secure Boot habilitado**. O hardware virtual já era enterprise. O Windows Server 2022 foi instalado. O laboratório tinha sua primeira parede.

O relatório REL-GMUD-001 registrou três incidentes menores — um erro de sintaxe no script PowerShell, um problema de memória dinâmica, uma perda de timing no boot da ISO — todos resolvidos em tempo real, sem impacto no resultado. O servidor estava de pé.

---

### GMUD-002 · O Domínio Nasce

Com `ID-P-01` operacional, Paulo executou o ato mais crítico de toda a infraestrutura: a **promoção do servidor a Domain Controller**. O comando `Install-ADDSForest` criou a floresta `corp.fiqueok.com.br`. O NetBIOS ficou `FIQUEOK`. O nível funcional foi definido em Windows Server 2016 para garantir compatibilidade futura.

O que nasceu naquele momento não era apenas um servidor de diretório. Era a **raiz de confiança** de toda a organização simulada. A partir dali, toda identidade, toda política, todo acesso teria esse ponto como origem.

O REL-GMUD-002 foi o mais limpo de todo o projeto: **nenhum incidente registrado**. A promoção ocorreu exatamente conforme o script. Os serviços críticos — KDC (Kerberos), DNS, ADWS, Netlogon — todos em estado `Running`. O SYSVOL presente. O servidor reconhecido como RIDMaster e PDCEmulator da floresta.

---

### GMUD-003 · A Arquitetura Lógica

Um domínio sem estrutura é uma caixa sem divisórias. A GMUD-003 tratou de criar as **Unidades Organizacionais** que dariam forma à identidade do ambiente.

A lógica seguiu o **Tier Model** de segurança: não organizar por organograma de RH, mas por criticidade e risco. A raiz `Fiqueok_Corp` foi criada com bloqueio de herança de GPO para evitar poluição de políticas padrão. Dentro dela: `00_Admins` para contas Tier 0, `01_Service_Accounts` para contas de serviço, `02_Security_Groups` para RBAC, `03_Resources` dividido em Servers e Workstations, e `04_People` com subdivisões departamentais.

O REL-GMUD-003 registrou um único incidente: o parâmetro booleano do `Set-GPInheritance` falhou. Solução aplicada em segundos com o parâmetro correto `-IsBlocked Yes`. O Active Directory agora tinha **arquitetura limpa**.

---

### GMUD-004 e GMUD-005 · Identidade e Endereçamento

A GMUD-004 foi um ato simbólico e prático ao mesmo tempo: a criação da conta `paulo.feitosa.adm` na OU `00_Admins`, elevada a Domain Admins, Enterprise Admins e Schema Admins. A partir daquela execução, a conta `Administrator` padrão deixou de ser usada para operações cotidianas. O princípio de **atribuição única de credenciais** estava em vigor.

A GMUD-005 fechou o ciclo da infraestrutura base com a ativação do **serviço DHCP** no `ID-P-01`. Range de `xxx.xxx.xxx.xxx` a `xxx.xxx.xxx.xxx`, autorizado no AD para prevenir Rogue DHCP, entregando DNS e Gateway centralizados para todos os novos ativos. O ambiente estava pronto para receber máquinas.

Em menos de um dia, a fundação estava completa: hypervisor enterprise, domínio corporativo, estrutura IAM, identidade nominal e endereçamento dinâmico seguro.

---

## Capítulo 2 — A Plataforma IGA Entra em Cena (23–24 de Dezembro de 2025)

### GMUD-006 e GMUD-007 · O Servidor Ubuntu e a Rede Estática

O próximo passo exigia um segundo ator: uma VM Ubuntu Server 24.04 para hospedar o motor de IGA. A VM `IGA-P-01` foi provisionada no Hyper-V, Docker instalado, e surgiu imediatamente o primeiro problema de comunicação real entre os mundos Linux e Windows.

O Ubuntu recebia endereço via DHCP e usava `8.8.8.8` como DNS. Isso significava que ele era completamente cego para o mundo `corp.fiqueok.com.br`. Não conseguia resolver `ID-P-01.corp.fiqueok.com.br`. Sem essa resolução, qualquer integração LDAP com o AD seria impossível.

A **GMUD-007** atacou esse problema com precisão: IP estático `xxx.xxx.xxx.xxx/16`, DNS primário apontado para o Domain Controller em `xxx.xxx.xxx.xxx`, DNS secundário `8.8.8.8` como fallback, e o search domain `corp.fiqueok.com.br` configurado.

A execução trouxe as primeiras **lições reais do projeto**. O arquivo `50-cloud-init.yaml` estava silenciosamente sobrescrevendo qualquer configuração Netplan após o `apply` — a conexão SSH caiu. A recuperação foi feita pelo Console Local do Hyper-V. O arquivo cloud-init foi movido para `/tmp`, as permissões do arquivo Netplan foram ajustadas para `chmod 600` (o próprio Netplan alertou sobre isso), e o ambiente ficou estável.

O REL-GMUD-007 documentou quatro incidentes e quatro soluções. O `nslookup ID-P-01.corp.fiqueok.com.br` passou a responder `xxx.xxx.xxx.xxx`. A porta LDAP 389 estava acessível. O Ubuntu e o AD passaram a enxergar um ao outro.

---

### GMUD-008 · O midPoint 4.10 e a Batalha do Bootstrap

Este foi o capítulo mais longo e mais instrutivo de todo o projeto.

O objetivo era aparentemente direto: subir o **midPoint 4.10** com PostgreSQL 16 via Docker Compose. A realidade foi uma série de obstáculos em camadas, cada um ensinando algo que os documentos oficiais não explicavam de forma direta.

**Obstáculo 1 — RAM.** O ambiente inicial tinha 3 GB de RAM. A JVM do midPoint, combinada com o PostgreSQL, simplesmente não inicializava de forma estável. A solução foi o upgrade da VM para **8 GB**. Uma lição simples, mas cara de descobrir na prática.

**Obstáculo 2 — O prefixo `MP_SET_`.** As variáveis de ambiente para sobrescrever configurações do midPoint em container precisavam obrigatoriamente do prefixo `MP_SET_`. Variáveis sem esse prefixo eram silenciosamente ignoradas, e o midPoint continuava tentando usar o H2 (banco padrão embutido) em vez do PostgreSQL. Horas foram gastas investigando por que a configuração JDBC não estava sendo aplicada.

**Obstáculo 3 — O schema Sqale.** A versão 4.10 usa o repositório **Sqale** (PostgreSQL nativo), que não cria seu schema automaticamente. Tentativas de criar manualmente a tabela `m_global_metadata` mostraram que o schema envolve dezenas de tabelas interdependentes — impossível fazer à mão de forma sustentável.

**A solução** foi a introdução de um **init container** (`data_init`) que executava `midpoint.sh init-native` antes do servidor subir, criando o schema completo de forma suportada e coordenada pelo próprio produto.

**Obstáculo 4 — A senha inicial.** A variável `MP_SET_midpoint_administrator_initialPassword` só é aplicada na **primeira** inicialização do repositório. Uma vez criado o usuário `administrator` no banco, alterar a variável no Compose não altera a senha. Para redefinir, era necessário recriar os volumes (`docker compose down -v`).

**Obstáculo 5 — O acesso à GUI.** De dentro da VM, `curl http://localhost:8080` funcionava. Mas do host Windows, `http://localhost:8080` era recusado. O navegador precisava apontar para `http://xxx.xxx.xxx.xxx:8080` — o IP da VM, não do host. Uma confusão clássica de ambiente virtualizado que consumiu tempo desnecessário.

O REL-GMUD-008 não foi um relatório de encerramento comum — foi transformado em uma **base de conhecimento** detalhada, documentando cada obstáculo, cada causa raiz e o procedimento padrão definitivo para implantação do midPoint 4.10. Um ativo intelectual permanente da Fiqueok.

O midPoint estava de pé. O dashboard carregava. O `administrator` fazia login.

---

### GMUD-009 · O OrangeHRM e a Fonte Autoritativa

Com o motor IGA funcionando, era hora de conectar a **fonte de verdade das identidades**: o sistema de RH. O **OrangeHRM Community Edition** foi implantado no mesmo servidor `IGA-P-01`, na porta 8081, com MariaDB 11.4 como banco de dados.

A arquitetura de segurança foi aplicada desde o deploy: arquivo `.env` para senhas (fora do repositório via `.gitignore`), conta `orangehrm_ro` criada com permissão restrita de `SELECT` para ser usada pelo conector midPoint, e volumes persistentes para garantir resiliência dos dados.

Um incidente durante o deploy: resíduos de volumes corrompidos de tentativas anteriores causaram falha na inicialização do MariaDB. A solução foi um saneamento preventivo com `rm -rf mariadb_data` seguido de reinicialização limpa.

O resultado: OrangeHRM acessível, banco MariaDB com a tabela `hs_hr_employee` presente, conta read-only configurada. O REL-GMUD-009 fechou com status **Sucesso**.

---

## Capítulo 3 — O Primeiro Muro Real (24–26 de Dezembro de 2025)

### GMUD-010 · A Integração que Falhou

A GMUD-010 era, no papel, o coroamento de tudo: configurar o **Resource OrangeHRM no midPoint** via conector DatabaseTable, criando o fluxo de importação de identidades do RH para o IGA.

A tentativa foi via importação de XML — uma abordagem direta, documentada, aparentemente sólida. O midPoint 4.10 discordou.

O motor **Prism/Sqale** da versão 4.10 mostrou-se extremamente sensível à estrutura de namespaces e à ordem dos elementos no XML. O erro foi claro e implacável: `Schema violation: object delta does not have complete definition`. Múltiplas iterações de XML, ajustes de namespace, reorganização de elementos — nenhuma funcionou.

O diagnóstico do REL-GMUD-010 foi honesto e corajoso: além da falha técnica, havia um **fator humano**. O processo atingiu um ponto de exaustão técnica. A decisão correta — e tomada — foi encerrar sem sucesso, preservar a qualidade e retornar com uma abordagem diferente.

A lição ficou documentada: **tentar criar o Resource via XML estático no midPoint 4.10 não é o caminho**. A GUI e o processo de Discovery dinâmico seriam a próxima tentativa.

---

### GMUD-011 · A Rede que Não Sobrevivia ao Reboot

Enquanto a integração midPoint-OrangeHRM estava em pausa, um novo problema surgiu com força: após um reinício do host, o midPoint não conseguia mais se comunicar com o MariaDB do OrangeHRM. O erro era sintomático: `nc: bad address 'orangehrm-db'`.

A causa raiz foi identificada: as conexões de rede entre as stacks Docker tinham sido criadas **manualmente via linha de comando** em alguma sessão anterior. Configurações efêmeras não sobrevivem ao `docker compose down` ou ao reinício do host.

A solução foi a GMUD-011: criar uma rede bridge **persistente e declarada em código** — a `fiqueok-backend-net` — e injetá-la nos arquivos `docker-compose.yml` de ambas as stacks. Infraestrutura como Código. Determinística. Resiliente.

O REL-GMUD-011 validou com três testes dentro do container midPoint: ping resolvia `orangehrm-db` com latência sub-milissegundo, a porta 3306 estava aberta, e — o mais importante — o mesmo teste executado do host externo **falhou com erro de DNS**, provando que a micro-segmentação estava funcionando. O acesso ao banco era possível apenas de dentro da rede correta.

---

### GMUD-013 · A Segunda Tentativa — e a Decisão Estratégica

Com a rede estabilizada e a lição da GMUD-010 incorporada, Paulo retornou à integração do OrangeHRM. A GMUD-013 foi a versão 2 — desta vez com uma abordagem radicalmente diferente.

Primeiro, a **sanitização**: o driver JDBC do MariaDB (`mariadb-java-client-3.1.2.jar`) foi injetado manualmente no classpath do midPoint, dentro do container, em `/opt/midpoint/var/lib/`. A ausência desse driver era parte do problema original da GMUD-010 que não havia sido identificada.

Depois, a abordagem **via GUI e Discovery dinâmico**: em vez de importar XML estático, configurar o Resource pela interface gráfica, deixando o midPoint mapear automaticamente as colunas da tabela `hs_hr_employee` ao clicar em "Test Connection". O **schema foi descoberto de forma autônoma**. O mapeamento de atributos (`employee_id` como ICF Name, `emp_firstname` → `givenName`, `emp_lastname` → `familyName`) foi configurado com sucesso.

Mas então veio uma decisão **estratégica e madura**: a importação dos usuários Rose Araujo e Daniel Ribeiro foi **suspensa intencionalmente**.

O motivo: importar identidades no midPoint sem que o Target (Active Directory) estivesse pronto para recebê-las via LDAPS geraria inconsistências de reconciliação no futuro. O fluxo precisava estar completo antes de ser acionado. A integridade do ambiente valia mais do que a velocidade de entrega.

---

### GMUD-014 · A Falha de Handshake e o Post-Mortem

A GMUD-014 era o elo final da cadeia: estabelecer a comunicação segura entre o midPoint e o Active Directory via **LDAPS (porta 636)**. Com isso, o provisionamento outbound ficaria viável — o midPoint criaria contas no AD automaticamente a partir das identidades do OrangeHRM.

A infraestrutura do lado do cliente foi concluída: o certificado `ad_ca.cer` foi exportado do AD e injetado no Keystore Java do container midPoint. A porta 636 foi validada como aberta via `nc -zv`. Tudo parecia pronto.

O handshake TLS iniciou. E o servidor encerrou a conexão abruptamente: `Connection reset by peer / errno=104`.

O diagnóstico foi cirúrgico: a porta 636 estava **ouvindo (L4)**, mas o serviço LDAPS no AD DS não estava **vinculado a um certificado válido (L7)**. O Domain Controller precisava de um certificado com a finalidade `Server Authentication (EKU)` instalado no repositório `Personal/Computer`, e esse binding simplesmente não existia no ambiente atual.

O REL-GMUD-014 foi encerrado com **Suspensão Técnica** — e documentou com franqueza a premissa incorreta do planejamento original: assumir que "porta 636 aberta = LDAPS funcional" era um erro de L4 vs L7. A descoberta foi valiosa: em produção, esse tipo de falha silenciosa poderia se manifestar de forma intermitente e muito mais difícil de diagnosticar.

A solução exigia uma Autoridade Certificadora própria. E foi aí que o projeto deu seu maior salto de maturidade.

---

## Capítulo 4 — A Evolução Arquitetural (27–30 de Dezembro de 2025)

### ARQ-005 · O Memorial Descritivo e o Pivô Estratégico

O fracasso da GMUD-014 não foi apenas uma falha técnica — foi o catalisador de uma reflexão arquitetural mais profunda. Paulo e seus parceiros de pensamento (Gemini como CTO e Claude como Auditor GRC) produziram o **ARQ-005**, o Memorial Descritivo de Arquitetura.

O documento fez o diagnóstico que ninguém queria ver documentado: o Living Lab 1.0 era uma **rede flat**. Toda a subnet `xxx.xxx.xxx.xxx/16` era uma única broadcast domain. Um container comprometido poderia fazer scan de toda a rede e alcançar o Domain Controller. Isso violava o controle **A.13.1.3 da ISO 27001**, o **PR.AC-5 do NIST CSF** e o **CIS Control 12.2**. Não parcialmente — completamente.

A resposta foi o design do **Living Lab 2.0**: segmentação por VLANs com quatro zonas de segurança. VLAN 1 (Management, xxx.xxx.xxx.xxx/16), VLAN 20 (Security/PKI, 192.168.20.0/24), VLAN 30 (IGA, 192.168.30.0/24) e VLAN 40 (SOC, para o futuro). Com ACLs inter-VLAN, o movimento lateral entre zonas ficaria bloqueado.

O ARQ-005 também formalizou a introdução da conta de serviço `svc_ansible` — uma segregação de funções que separava as ações manuais do usuário `paulo` das execuções automatizadas de scripts e playbooks. Rastreabilidade, não repúdio, princípio do menor privilégio.

---

### GMUD-015B · O HashiCorp Vault e a PKI Corporativa

Com a arquitetura definida, o próximo passo era resolver o problema raiz da GMUD-014: a falta de uma CA corporativa para emitir o certificado LDAPS do Active Directory.

A **GMUD-015B** foi o deploy mais tecnicamente sofisticado do projeto: o **HashiCorp Vault 1.15.4** na VLAN 20, usando driver `macvlan` para que o container tivesse IP próprio (`192.168.20.20`) e endereço MAC independente — aparecendo na rede como um servidor físico real, não como um processo dentro do host.

A hierarquia PKI planejada era enterprise-grade: uma **Root CA** (RSA 4096, 10 anos, mantida offline após emitir o certificado da Intermediate), uma **Intermediate CA** (RSA 2048, 5 anos, operacional no Vault), e a partir dela todos os certificados de servidor — AD LDAPS, midPoint TLS, Keycloak HTTPS (futuro).

A segurança foi pensada em detalhes: Shamir Secret Sharing com 5 unseal keys e threshold de 3, audit logging completo para atender o **A.12.4.1 da ISO 27001**, e o Root Token a ser revogado após o bootstrap inicial.

---

## O Pivô Final — Tailscale sobre VLANs

E então veio a decisão que mudou o capítulo final do projeto.

A implementação de VLANs no Hyper-V, embora tecnicamente correta e arquiteturalmente sólida no papel, trouxe complexidade operacional real: configuração de trunk mode, subinterfaces no Ubuntu, roteamento inter-VLAN, ACLs, e o desafio específico do driver `macvlan` que impedia comunicação direta entre o host e o container Vault pela mesma interface física.

A pergunta honesta foi feita: **essa complexidade entrega valor proporcional para o estágio atual do projeto?**

A resposta foi não — e a alternativa foi mais elegante do que qualquer configuração de VLAN poderia ser: **Tailscale**. Uma VPN mesh baseada em WireGuard que entrega micro-segmentação, isolamento de tráfego, identidade de dispositivo e auditabilidade sem exigir configuração de switch virtual, subinterfaces ou roteamento manual. Zero Trust por design, não por configuração.

O pivô foi uma demonstração de maturidade técnica: reconhecer quando uma solução, mesmo correta em princípio, é a ferramenta errada para o contexto. E ter a coragem de mudar.

---

## Epílogo — O que o Projeto Construiu de Verdade

Ao final, o PRJ002 entregou muito mais do que infraestrutura. Entregou **metodologia**.

Cada falha foi documentada com o mesmo rigor das sucessos. Cada decisão de arquitetura tem rastreabilidade — sabe-se por que foi tomada, quem a tomou e em que contexto. Os 14 GMUDs e seus relatórios de encerramento formam um trail de auditoria que qualquer auditor ISO 27001 reconheceria como evidência de maturidade de processo.

O projeto demonstrou, na prática, que **a distância entre teoria e produção** — entre ler sobre LDAPS e fazer o handshake TLS funcionar, entre saber que Docker networks existem e entender por que um `docker compose down` apaga a conectividade — é onde o conhecimento real vive.

E é exatamente esse espaço que o Living Lab da Fiqueok foi construído para habitar.



O PROMPT ACIMA FOI FORNECIDO NO PERFIL DO EMAIL FEITOSA.LIMA@GMAIL.COM

SEGUE SOLICITACAO DE STORYTELLLING NO PERFIL PAULO@FIQUEOK.COM.BR



Crie um storytelling contando para executivos a historia do Living Lab

16:32

## Claude respondeu: Aqui está o storytelling executivo do Living Lab Fiqueok.

Visualizou 2 arquivos

Visualizou 2 arquivos

Aqui está o storytelling executivo do Living Lab Fiqueok.

A narrativa segue uma estrutura clássica de apresentação executiva — problema → decisão → arquitetura → resultados → proposta de valor — com cinco capítulos que constroem progressivamente a história:

**O arco central** é simples e poderoso: expertise acumulada em 20+ anos em grandes instituições financeiras brasileiras só tem valor quando se torna evidência concreta. O Lab é essa evidência.

**O que diferencia para executivos:**

- Não é um sandbox caseiro — é infraestrutura enterprise replicada com metodologia de projeto rigorosa
- As decisões documentadas (TEP, TAP, POP) mostram maturidade em governança, não apenas habilidade técnica
- Os erros encontrados no Lab (SSoT violation em PRJ015, blocker Java 21 em PRJ008) são justamente os que protegem organizações de incidentes em produção

O botão no final conecta diretamente para uma conversa mais profunda sobre aplicações reais. Posso adaptar o tom, adicionar um capítulo específico (por exemplo, focado em Entra ID para um público Microsoft-heavy), ou transformar isso em um deck executivo em PPTX se quiser usar numa apresentação formal.

## Você disse: Quero saber mais sobre como o Living Lab pode se conectar a desafios reais de IAM na minha organização

Quero saber mais sobre como o Living Lab pode se conectar a desafios reais de IAM na minha organização

16:35

## Claude respondeu: Cada card acima mapeia um desafio real de IAM corporativo para evidências concretas do Lab — não teoria, mas artefatos produzidos em projetos reais com decisõe…

Cada card acima mapeia um desafio real de IAM corporativo para evidências concretas do Lab — não teoria, mas artefatos produzidos em projetos reais com decisões documentadas.

O que diferencia essa abordagem para um executivo é o seguinte raciocínio: qualquer consultor apresenta um slide sobre JML ou IGA. Poucos chegam com um TEP descrevendo por que uma decisão foi tomada, quais alternativas foram descartadas e qual foi o custo de uma escolha errada — tudo documentado antes de chegar na sua produção.

Clique em qualquer desafio para ver lado a lado o que foi feito no Lab e o que isso significa para a sua organização. Se quiser, posso também montar uma proposta de diagnóstico rápido (uma espécie de "discovery de 2 semanas") baseada nos projetos do Lab para um contexto específico da sua empresa.

## Você disse: Me explique em detalhes como o Lab resolveu: Integração HR ↔ IAM

Me explique em detalhes como o Lab resolveu: Integração HR ↔ IAM

16:37

## Claude respondeu: Ótima escolha — esse é um dos projetos mais completos do Lab, o PRJ008 (Shadow API).

Ótima escolha — esse é um dos projetos mais completos do Lab, o PRJ008 (Shadow API). Deixa eu detalhar cada camada da solução.

**O problema central que o projeto atacou**

A maioria das integrações HR↔IAM em empresas funciona assim: um job noturno exporta um CSV do sistema de RH, um script lê esse CSV e faz updates no AD. Isso cria janelas de risco de horas, nenhuma rastreabilidade de mudança, e zero resiliência a falhas parciais. O PRJ008 foi projetado para eliminar esse padrão.

**A arquitetura escolhida**

Em vez de integração direta OrangeHRM → midPoint, foi inserida uma camada intermediária — a Shadow API — construída em Python 3.12 + FastAPI + SQLAlchemy. Essa camada tem três responsabilidades:

- Ser a única fonte de verdade que o midPoint consome (separação de concerns)
- Normalizar e validar os dados antes que cheguem ao IGA
- Absorver as inconsistências do sistema de RH sem propagá-las para o diretório

**As decisões técnicas que importam para o mundo real**

O `emp_number` foi escolhido como âncora de correlação IGA — não o nome, não o email, não o CPF. Isso garante que renomeações, mudanças de email ou sobrenomes não quebram o vínculo entre o registro de RH e a identidade no AD/midPoint.

Os status de emprego foram modelados como enums fechados (`ACTIVE`, `TERMINATED`, `ON_LEAVE`, `SUSPENDED`) — não strings livres. Isso força o sistema de RH a falar uma linguagem que o motor JML do midPoint consegue interpretar como trigger de workflow sem ambiguidade.

A política explícita de null foi talvez a decisão mais sofisticada: quando um campo de RH está vazio, a API retorna explicitamente `null` e o midPoint é configurado para ignorar esse valor — não para limpar o atributo no AD. Sem isso, uma ausência de dado no RH se tornaria um clearing acidental de atributo em produção. Isso é exatamente o tipo de bug silencioso que só aparece meses depois, quando um usuário perde um atributo crítico sem ninguém entender por quê.

Normalização UTF-8 NFC foi aplicada para nomes como "João" ou "Conceição" — porque AD, midPoint e APIs REST têm comportamentos diferentes com composição de caracteres, e um mismatch aqui quebra buscas e correlações.

**Segurança da integração**

Os segredos (credenciais da API, tokens do midPoint) são gerenciados pelo HashiCorp Vault com AppRole — não hardcoded, não em `.env` files. O pipeline inclui Bandit e Semgrep para análise estática, OWASP ZAP para testes de segurança da API, e Trivy para scan de containers.

**Onde o projeto está agora**

Os Sprints 1–5 estão completos — a especificação OpenAPI 3.1 (508 linhas), a arquitetura, o contrato de dados e o ambiente IGA-GF-02 com midPoint 4.9. O Sprint 6 está pausado por um blocker específico: o conector REST do midPoint (ScriptedREST 1.1.1.e2) usa uma biblioteca Groovy incompatível com Java 21. A retomada depende de um build Maven customizado ou de um release oficial compatível.

**O que isso entrega para uma organização**

Uma integração HR↔IAM desenhada assim garante que o offboarding de um funcionário em 17h dispara o workflow de revogação automaticamente — não no dia seguinte quando alguém rodar um script. E garante que a evidência dessa revogação existe, é rastreável, e passa por auditoria.

Quer que eu detalhe alguma camada específica — a modelagem OpenAPI, os workflows JML no midPoint, ou a configuração do Vault AppRole?

## Você disse: Me explique em detalhes como o Lab resolveu: JML sem governança

Me explique em detalhes como o Lab resolveu: JML sem governança

17:47

## Claude respondeu: Boa sequência — JML é onde tudo converge.

Boa sequência — JML é onde tudo converge. Depois de entender a Shadow API (PRJ008), agora faz sentido ver como o midPoint consome essa camada e transforma dados de RH em decisões de acesso.

**O problema real que o Lab modelou**

JML sem governança não é apenas "processo manual". É um conjunto de falhas sistêmicas que coexistem silenciosamente:

- Joiner: conta criada no AD, mas grupos de acesso adicionados um por um por chamado de Service Desk — sem padrão, sem revisão
- Mover: promoção no RH não reflete no perfil de acesso por semanas. O usuário acumula permissões do cargo anterior
- Leaver: desligamento comunicado por email para TI. Conta desabilitada no dia seguinte, se tudo correr bem. Licenças cloud permanecendo ativas por meses

**Como o Lab modelou a solução**

A cadeia completa ficou assim:

```
OrangeHRM (SoT) → Shadow API (PRJ008) → midPoint 4.9 → AD / Entra ID
```

O midPoint não conversa diretamente com o OrangeHRM. Ele consome a Shadow API — que já entregou os dados normalizados, validados e com os enums fechados de status. Isso isola o motor IGA das inconsistências do sistema de RH.

**Os triggers de workflow**

Os enums fechados de status de emprego definidos na Shadow API são os triggers diretos dos workflows JML no midPoint:

- `ACTIVE` → provisiona conta, aplica Role baseado no cargo (`jobTitle`) e departamento (`department`)
- `ON_LEAVE` → desabilita conta temporariamente, mantém atributos e grupos intactos
- `SUSPENDED` → desabilita conta, flag de investigação
- `TERMINATED` → inicia workflow de offboarding: revogação de grupos, desabilitação de conta, remoção de licenças, notificação para revisão de acessos residuais

A decisão de usar enums fechados — e não strings livres do RH — foi exatamente para garantir que o midPoint nunca receba um status ambíguo como `"Afastado"`, `"Lic. médica"` ou `"Inativo"` que ele não saiba mapear para uma ação.

**Role-Based Provisioning**

O midPoint foi configurado para derivar o perfil de acesso do usuário a partir de dois atributos vindos da Shadow API: `jobTitle` e `department`. A lógica de mapeamento fica em objetos de Role no midPoint — não em scripts ad hoc. Isso significa:

- Um analista financeiro recebe automaticamente os grupos corretos de AD, as licenças Microsoft 365 correspondentes, e as permissões de sistemas definidas para aquele papel
- Uma mudança de cargo (Mover) recalcula o Role automaticamente — sem chamado, sem intervenção manual
- A rastreabilidade fica no midPoint: cada atribuição de Role tem timestamp, origem (qual atributo de RH motivou) e status

**O que o midPoint faz que scripts não fazem**

Essa distinção é importante para executivos: um script de provisionamento executa uma ação. O midPoint mantém um modelo. A diferença prática:

- Se um administrador adicionar manualmente um grupo de AD a um usuário que não deveria ter aquele acesso, o midPoint detecta a divergência e pode remediar automaticamente (ou alertar)
- Se o RH atualizar um cargo e a Shadow API propagar a mudança, o midPoint recalcula todos os acessos daquele usuário em todos os sistemas conectados — não apenas no AD
- Cada decisão de acesso tem um "porquê" rastreável: esse usuário tem esse grupo porque seu cargo é X no departamento Y, conforme registro no RH em tal data

**O ambiente onde isso roda**

O IGA-GF-02 é a VM que sustenta essa camada no Lab: Ubuntu via Golden Disk diferencial, midPoint 4.9 + PostgreSQL 16-alpine via Docker Compose, Tailscale para acesso seguro. O schema do banco foi validado com 101 tabelas — compliance confirmado com a especificação do midPoint 4.9.

**O que ficou pendente antes do freeze**

O Sprint 6 estava na fase de configurar o recurso REST Connector no midPoint apontando para a Shadow API (api-gf-01). O blocker do conector Groovy/Java 21 interrompeu exatamente nesse ponto — a orquestração está montada, o conector é o elo final da cadeia.

**O que isso representa para uma organização**

A diferença entre JML governado e não governado não aparece no dia a dia — aparece na auditoria, no incidente de segurança, ou no desligamento de um colaborador com acesso a sistemas críticos que ninguém sabia que ele ainda tinha.

O Lab modelou a cadeia completa com artefatos reais: contrato de API, mapeamento de atributos, política de null, workflows de Role. Não é um POC de demonstração — é uma arquitetura que replica decisões que uma organização de médio porte enfrentaria ao implantar IGA do zero.

Quer ir para o próximo nível — como o midPoint reconcilia divergências entre o que o AD tem e o que o RH diz que deveria ter? Esse é o mecanismo de Reconciliation, e é onde a governança de acesso realmente se diferencia de simples automação.


Me explique em detalhes como o Lab resolveu: Adoção de Entra ID / Azure AD

18:54

## Claude respondeu: Esse é o projeto mais próximo do mundo real corporativo — porque não foi resolvido em laboratório.

Esse é o projeto mais próximo do mundo real corporativo — porque não foi resolvido em laboratório. Foi diagnosticado em produção, no cliente, durante o trabalho na DPSP.

**O contexto: ambiente híbrido em produção**

A DPSP operava com infraestrutura híbrida clássica: Active Directory on-premise sincronizando para Entra ID via Entra Connect, com Lifecycle Workflows configurados para automação de onboarding e offboarding. Na teoria, tudo funcionando. Na prática, dois problemas silenciosos coexistindo:

- Password Hash Sync havia parado — usuários não conseguiam autenticar via cloud com a senha do AD
- Lifecycle Workflows não disparavam — automações de JML configuradas no Entra simplesmente não executavam

Ambos os problemas tinham o mesmo comportamento: nenhum erro explícito nos logs do Entra Connect. Tudo aparecia verde no portal.

**O diagnóstico que ninguém tinha feito**

A investigação começou pelos lugares óbvios — configuração do Entra Connect, status de sincronização, health do agente, conectividade com os endpoints Microsoft. Tudo normal.

O ponto de virada foi olhar para a camada de rede abaixo do Entra Connect: o Netskope estava instalado como proxy SSL inspection no ambiente.

O Netskope interceptava e inspecionava tráfego HTTPS — comportamento esperado e configurado intencionalmente para segurança. O problema é que o Entra Connect usa WebSocket para manter canais persistentes de comunicação com os endpoints Microsoft. WebSocket sobre HTTPS (`wss://`) tem um handshake específico — o cliente envia `Upgrade: websocket` e espera `101 Switching Protocols`.

O Netskope, ao inspecionar esse tráfego, não propagava o upgrade corretamente. Do ponto de vista do Entra Connect, a conexão estabelecia, mas o canal WebSocket nunca completava o handshake. O resultado:

- Sincronização de hash de senha falha silenciosamente — o hash é transmitido via esse canal WebSocket criptografado
- Lifecycle Workflows dependem de eventos propagados pelo mesmo canal — sem canal, sem eventos, sem automação

Nenhum log de erro porque a conexão TCP em si não falhava. O handshake WebSocket simplesmente não completava, e o Entra Connect não tinha telemetria granular o suficiente para expor isso no portal.

**A remediação**

A solução foi bypass seletivo no Netskope: os endpoints Microsoft usados pelo Entra Connect para Password Hash Sync e Lifecycle Workflows foram adicionados à lista de exclusão de SSL inspection. Não desabilitar o Netskope — cirurgia precisa nos endpoints corretos.

Os endpoints críticos são documentados pela Microsoft e incluem os ranges `*.msappproxy.net`, `*.servicebus.windows.net`, e endpoints específicos de autenticação. Cada um desses precisa de bypass de SSL inspection para que o WebSocket funcione corretamente.

Após a configuração do bypass, Password Hash Sync normalizou em minutos. Lifecycle Workflows voltaram a disparar no ciclo seguinte.

**O segundo problema: proxyAddress ghost conflicts**

Paralelo ao diagnóstico do Netskope, o ambiente tinha ~100 usuários no Entra ID com conflitos de `proxyAddress` — o mesmo padrão que o PRJ015 depois modelou em laboratório.

A remediação foi executada via Graph API beta com operações PATCH cirúrgicas:

```
GET https://graph.microsoft.com/beta/users/{id}?$select=proxyAddresses
PATCH https://graph.microsoft.com/beta/users/{id}
{ "proxyAddresses": ["SMTP:usuario@dominio.com.br"] }
```

O endpoint beta expõe `proxyAddresses` como array editável diretamente — o endpoint v1.0 não permite essa operação. Cada usuário foi analisado individualmente: identificar o endereço primário correto, remover duplicatas e aliases fantasma, e reescrever o array limpo.

A escala de ~100 usuários tornou isso viável manualmente com scripts PowerShell auxiliares para identificação. Em escala maior — 5.000 usuários — esse processo exigiria automação completa via pipeline, que é exatamente o que o PRJ008 e PRJ016 endereçam.

**O que esse diagnóstico representa**

Esse cenário — proxy SSL inspection quebrando WebSocket do Entra Connect — é extremamente comum em organizações com stack de segurança de endpoint moderno. Netskope, Zscaler, Palo Alto Prisma Access, e outros proxies SSL têm esse comportamento por padrão. A Microsoft documenta os endpoints que precisam de bypass, mas a correlação entre "Lifecycle Workflows não disparam" e "Netskope está interceptando WebSocket" não é óbvia.

Equipes de IAM sem experiência nesse nível de stack tendem a passar semanas abrindo chamados com a Microsoft antes de olhar para a camada de rede abaixo do Entra Connect.

**O que o Lab fez com esse conhecimento**

O diagnóstico da DPSP alimentou diretamente a documentação do Living Lab: o padrão de proxy SSL inspection como bloqueador de Entra Connect foi catalogado como um anti-pattern de rede a ser verificado em qualquer implantação híbrida. Virou checklist no processo de pré-flight de projetos que envolvem Entra Connect.

É o tipo de conhecimento que não existe em documentação oficial — existe em quem já viu o problema em produção e sabe onde olhar.

Quer continuar para o diagnóstico de evidência para auditoria, ou prefere aprofundar em como o PRJ016 fecha o ciclo completo — midPoint on-premise como motor IGA governando o AD que alimenta esse ambiente Entra?


Me explique em detalhes como o Lab resolveu: Implantação de plataforma IGA

18:57

## Claude respondeu: Esse é o projeto mais arquitetural do Lab — porque a decisão mais importante não foi técnica, foi sobre o que não construir de forma acoplada.

Esse é o projeto mais arquitetural do Lab — porque a decisão mais importante não foi técnica, foi sobre o que _não_ construir de forma acoplada.

**O contexto: PRJ008 como caso de implantação IGA real**

A maioria das implantações de IGA falha no mesmo ponto: a equipe instala a plataforma, conecta ao AD, e começa a mapear atributos diretamente do sistema de RH para o IGA. Funciona no POC. Quebra em produção quando o sistema de RH retorna dados sujos, muda um campo sem aviso, ou quando a lógica de negócio de "quem tem acesso a quê" precisa ser alterada.

O PRJ008 foi estruturado para evitar exatamente esse padrão.

**A decisão arquitetural central: IGA não fala com RH diretamente**

A topologia escolhida foi:

```
OrangeHRM → Shadow API → midPoint 4.9 → AD / Entra ID
```

O midPoint nunca vê o OrangeHRM. Ele vê apenas a Shadow API — uma camada intermediária que tem contrato estável, validação de dados, e comportamento previsível. Essa separação tem consequências práticas importantes:

Se o OrangeHRM mudar o nome de um campo, a correção acontece na Shadow API — não no midPoint. O IGA permanece estável. Em implantações diretas, essa mudança exigiria reconfigurar mapeamentos de atributo no midPoint, testar workflows, e provavelmente causar um incidente de sincronização antes de alguém perceber o que quebrou.

**O contrato OpenAPI 3.1: 508 linhas com decisões explícitas**

O contrato da Shadow API não foi escrito para documentar o que a API faz — foi escrito para forçar decisões de modelagem que o midPoint dependeria.

Três decisões merecem destaque:

`emp_number` como âncora de correlação. Não `email`, não `username`, não `id` interno do OrangeHRM. O `emp_number` é o único atributo que não muda em nenhuma circunstância de negócio — promoção, mudança de nome, troca de email, transferência de departamento. É o fio que conecta o registro de RH à identidade no AD permanentemente. O midPoint usa esse valor como `matching rule` — se um objeto no AD tem `employeeNumber` igual ao `emp_number` da API, são a mesma pessoa.

Enums fechados para status de emprego. O contrato define `employment_status` como `enum: [ACTIVE, TERMINATED, ON_LEAVE, SUSPENDED]` — não `string`. Isso tem uma implicação direta no midPoint: cada valor do enum mapeia para uma condição de workflow. `TERMINATED` dispara offboarding. `ON_LEAVE` desabilita conta sem revogar grupos. `SUSPENDED` desabilita com flag de investigação. Se o campo fosse string livre, o midPoint precisaria de lógica condicional para interpretar valores como `"Afastado"`, `"Lic. médica"`, `"Inativo"` — lógica que inevitavelmente fica desatualizada.

Política explícita de null. Cada campo do contrato define comportamento explícito quando ausente. Campos opcionais retornam `null` — nunca são omitidos da resposta. O midPoint é configurado com `fetchStrategy: EXPLICIT` para esses atributos: valor `null` significa "não alterar o atributo no AD", não "limpar o atributo no AD". Sem essa política, uma ausência de dado no RH — um campo de ramal telefônico vazio, por exemplo — se tornaria um clearing do atributo `telephoneNumber` no AD para todos os usuários que não têm ramal cadastrado.

**A arquitetura hexagonal da Shadow API**

A Shadow API foi estruturada em camadas com separação estrita:

- Camada de domínio: modelos de dados e regras de negócio sem dependência de framework
- Camada de aplicação: casos de uso (buscar funcionário, listar departamento, verificar status)
- Adaptadores de entrada: endpoints FastAPI que expõem o contrato OpenAPI
- Adaptadores de saída: repositórios SQLAlchemy que abstraem o banco e, futuramente, a conexão direta ao OrangeHRM

Essa estrutura significa que trocar o OrangeHRM por outro sistema de RH — SuccessFactors, Totvs, qualquer outro — requer reescrever apenas os adaptadores de saída. O contrato que o midPoint consome permanece intacto.

**HashiCorp Vault AppRole: segredos sem segredos no código**

A autenticação entre midPoint e Shadow API, e entre Shadow API e banco de dados, é gerenciada pelo Vault com AppRole:

- A Shadow API tem um `role_id` e `secret_id` que autentica no Vault
- O Vault retorna um token temporário com TTL configurado
- A Shadow API usa esse token para buscar as credenciais do banco no Vault — nunca de variável de ambiente ou arquivo de configuração

Para o midPoint, a configuração do recurso REST Connector referencia o endpoint da Shadow API com credenciais rotacionadas pelo Vault. Se uma credencial vazar, ela expira. Se o Vault estiver indisponível, o midPoint entra em modo degradado — não usa credenciais em cache desatualizadas.

**O pipeline DevSecOps**

A implantação IGA foi tratada como produto de software, não como configuração de ferramenta:

- Bandit e Semgrep analisam o código Python da Shadow API em cada commit — detectam padrões inseguros como logging de credenciais, SQL injection, deserialização insegura
- OWASP ZAP executa testes de segurança contra a API em execução — não apenas análise estática
- Trivy faz scan das imagens Docker antes do deploy — verifica CVEs em dependências e na imagem base

Isso significa que a Shadow API tem postura de segurança documentada e verificável — não "achamos que está seguro".

**O ambiente IGA-GF-02**

O midPoint 4.9 roda em Docker Compose no IGA-GF-02:

yaml

```yaml
services:
  midpoint:
    image: evolveum/midpoint:4.9
    depends_on: [postgres]
    ports: ["8080:8080"]
  postgres:
    image: postgres:16-alpine
```

PostgreSQL 16-alpine como backend — schema validado com 101 tabelas em conformidade com a especificação do midPoint 4.9. Acesso via Tailscale (xxx.xxx.xxx.xxx) com ACLs de rede controlando quem alcança a porta 8080.

O midPoint tem snapshot pré-Sprint 6 como ponto de rollback — qualquer configuração incorreta do REST Connector não compromete o ambiente base.

**Onde a implantação parou e por quê**

O Sprint 6 estava configurando o recurso REST Connector no midPoint apontando para a Shadow API. O blocker é específico e documentado:

O conector ScriptedREST 1.1.1.e2 usa a biblioteca `connector-rest Polygon` para processar scripts Groovy. Essa biblioteca depende de `GPathResult` — uma classe do Groovy que teve mudanças de compatibilidade no Java 21. O midPoint 4.9 roda em Java 21. O resultado: o conector carrega, o recurso é configurado, mas os scripts Groovy de Search e Sync falham com `ClassCastException` em runtime.

A resolução requer build Maven customizado do connector-rest com as dependências Groovy compatíveis com Java 21 — ou aguardar um release oficial da Evolveum. O `SearchScript.groovy` está em `/opt/midpoint/var/scripts/` e o recurso tem OID `97afbdbb` registrado no midPoint. Tudo pronto, esperando o conector.

**O que essa implantação ensina para uma organização**

Implantar IGA não é instalar software e mapear atributos. É tomar uma série de decisões arquiteturais — qual é a âncora de correlação, como modelar status de emprego, o que acontece com dados ausentes, como isolar o IGA de mudanças no sistema de RH — que determinam se a plataforma vai funcionar daqui a dois anos ou vai acumular exceções e workarounds até ninguém mais entender como funciona.

O PRJ008 tomou essas decisões explicitamente, documentou o raciocínio, e produziu artefatos auditáveis. Uma organização que contrata esse conhecimento não está pagando pela instalação do midPoint — está pagando por não precisar descobrir essas decisões na base do incidente de produção.

Quer fechar o ciclo completo? O PRJ016 é onde o midPoint on-premise passa a governar o AD que alimenta o Entra ID — conectando tudo que foi construído nos projetos anteriores em uma arquitetura IGA híbrida end-to-end.

Me explique em detalhes como o Lab resolveu: Evidência para auditoria

19:02

## Claude respondeu: Esse é o projeto transversal do Lab — não tem número de projeto porque atravessa todos eles.

Esse é o projeto transversal do Lab — não tem número de projeto porque atravessa todos eles. É a camada de governança que transforma trabalho técnico em evidência auditável.

**O problema que a maioria das equipes de IAM ignora**

Equipes técnicas de IAM documentam o que fizeram. Raramente documentam por que fizeram, o que consideraram antes, o que descartaram e qual foi o custo de cada decisão. Para uma auditoria de ISO 27001, SOX ou LGPD, essa diferença é crítica:

- "Implementamos offboarding automatizado" é uma afirmação
- "Implementamos offboarding automatizado via midPoint 4.9, trigger em `TERMINATED` do enum de status da Shadow API, com evidência de cada revogação registrada no audit log do midPoint, rastreável ao registro de RH pelo `emp_number`" é evidência auditável

O Lab foi construído para produzir o segundo tipo desde o início — não como camada adicionada depois.

**O modelo de três camadas: TAP · TEP · POP**

Cada projeto do Lab produz obrigatoriamente três classes de documento:

O TAP — Termo de Abertura de Projeto — é escrito antes de qualquer linha de código ou configuração. Define escopo, objetivos mensuráveis, riscos identificados, critérios de sucesso, e dependências. Para uma auditoria, o TAP responde: "Como vocês sabiam o que estavam construindo antes de começar?"

O PRJ015 tem TAP v1.0 datado de 30/03/2026 com topologia definida, âncora de correlação escolhida (`employeeID`), e diagrama de fluxo de identidade antes de qualquer VM ser criada. Se um auditor perguntar "qual era o design original", existe um documento com data, escopo e decisões pré-implementação.

O TEP — Termo de Encerramento de Projeto — é escrito ao fechar cada projeto ou fase significativa. Documenta o que foi entregue versus o que foi planejado, decisões tomadas durante execução com justificativa, lições aprendidas numeradas (L-001, L-002...), e o estado final do ambiente. Para uma auditoria, o TEP responde: "O que mudou do plano original e por quê?"

O TEP-PRJ015 v3.0 é o exemplo mais rico: documenta a violação de SSoT detectada, registra explicitamente que ferramentas de IA atuaram como analistas juniores sem identificar a causa raiz, e justifica a decisão de purgar 99 contas em vez de remediar objeto a objeto — com o raciocínio completo. Um auditor não apenas vê o que foi feito — vê o processo de decisão.

O TEP-PRJ014 encerrou o projeto de saneamento de Hyper-V com a conclusão formal de que `Win2022-GF-GEN2.vhdx` é permanentemente inapto para AD DS — porque foi clonado de um DC anterior. Essa conclusão está documentada com data e justificativa técnica. Se alguém tentar usar aquele disco dois anos depois, existe evidência registrada de por que não deve.

O POP — Procedimento Operacional Padrão — documenta como executar operações recorrentes de forma reproduzível. O `POP-GOLDEN-DISK-001` define o processo de criação e manutenção do Golden Disk oficial (`Win2022-GF-PURE-V3-GREENFIELD.vhdx`): qual é o template oficial, como criar VMs diferenciais, como validar integridade. Para uma auditoria, o POP responde: "Como garantem que o mesmo procedimento é executado da mesma forma toda vez?"

**O Golden Disk Inventory como controle de configuração**

O PRJ014 produziu um artefato específico que vai além da documentação narrativa: o Golden Disk Inventory é um registro formal de cada imagem de VM no Lab, com status explícito de aptidão para cada uso.

A entrada para `Win2022-GF-GEN2.vhdx` registra: origem, data de criação, motivo de inaptidão para AD DS, e status `PERMANENTLY_UNFIT`. Não é uma nota informal em um README — é um item de inventário com decisão formal registrada.

Isso mapeia diretamente para controles de gestão de ativos de informação da ISO 27001 (A.8) e para requisitos de baseline de configuração de frameworks como CIS Controls e NIST CSF.

**O sistema de numeração como rastreabilidade**

Projetos são numerados sequencialmente (PRJ001, PRJ002... PRJ016). Lições aprendidas são numeradas dentro de cada projeto (L-001, L-002). Procedimentos operacionais são numerados globalmente (POP-GOLDEN-DISK-001).

Isso não é burocracia — é rastreabilidade. Um auditor pode perguntar "qual foi a lição aprendida sobre clonagem de DCs" e a resposta é localizável: TEP-PRJ014, L-002. Um novo membro da equipe pode perguntar "qual é o procedimento para criar uma VM" e a resposta é um número de POP com versão.

Em organizações sem esse sistema, o conhecimento existe na cabeça de quem fez. Quando essa pessoa sai, o conhecimento some — e a evidência de por que certas decisões foram tomadas some junto.

**O Obsidian como repositório de governança**

A estrutura de documentação usa Obsidian com separação explícita entre `_ATIVOS\` — documentos de projetos em andamento — e `_ARQUIVO-MORTO\` — documentos de projetos encerrados. Essa separação não é apenas organização: é controle de estado de evidência.

Um auditor que pede "me mostre a documentação do PRJ015" recebe documentos em `_ARQUIVO-MORTO\PRJ015\` — indicando formalmente que o projeto foi encerrado, não abandonado. A distinção importa: projeto abandonado sem TEP é um risco de auditoria. Projeto encerrado com TEP é evidência de ciclo de vida completo.

**Como isso se aplica a uma organização**

Organizações com maturidade baixa de IAM têm documentação técnica — diagramas de arquitetura, scripts comentados, wikis com instruções. Raramente têm evidência de governança — registros de decisão com justificativa, encerramento formal de projetos, inventário de ativos com status de aptidão.

A diferença aparece em três momentos específicos:

Em auditorias de certificação ISO 27001, o auditor não quer ver que o offboarding funciona — quer ver evidência de que cada desligamento foi executado, rastreado, e revisado. Sem audit log do IGA ligado ao registro de RH pelo `emp_number`, existe processo mas não existe evidência.

Em incidentes de segurança, a pergunta do board não é "o que aconteceu" — é "quando vocês souberam, o que decidiram, e por quê". Sem TEP de incidente com decisões documentadas, a resposta é narrativa informal — inadmissível em processos regulatórios.

Em transferências de conhecimento, quando o arquiteto sênior de IAM sai, o que fica? Se a documentação é técnica, fica o como. Se a documentação é de governança, fica o porquê — que é o que determina se o sucessor vai manter o sistema funcionando ou vai refazer as mesmas decisões erradas que já foram tomadas antes.

**O que o Lab entrega como modelo**

A metodologia TAP·TEP·POP não foi inventada para o Lab — é uma adaptação de práticas de PMO e ITSM aplicada ao ciclo de vida de projetos de identidade. O que o Lab fez foi aplicar isso de forma consistente em todos os projetos, sem exceção, incluindo os que falharam.

O TEP-PRJ015 documentando uma falha arquitetural e o raciocínio para encerrar o projeto tem mais valor para uma organização do que dez documentos de projetos que deram certo — porque mostra que o processo de governança funciona mesmo quando o resultado técnico não foi o esperado.

Quer fechar o ciclo com o último desafio — Integração HR↔IAM via API — ou prefere ir direto para como todos esses projetos se conectam em uma proposta de arquitetura IGA completa para uma organização?


Sim, confirmo — Integração HR↔IAM via API foi o primeiro desafio detalhado nessa thread, cobrindo o PRJ008 completo: Shadow API, FastAPI, enums fechados, política de null, Vault AppRole, e o blocker do Sprint 6.

Todos os seis desafios foram cobertos. Agora faz sentido conectar tudo.

V

visualize

V

visualize show_widget

O diagrama acima é a arquitetura completa — cada camada corresponde a um projeto ou decisão específica do Lab. Aqui está como os cinco projetos se conectam em uma narrativa única.

**A leitura de cima para baixo é a leitura da maturidade**

Na camada de SoT, o OrangeHRM e o Active Directory são as fontes de verdade — mas só funcionam como SoT porque o Lab definiu isso antes de criar qualquer objeto downstream. Essa é a lição central do PRJ015: a sequência de decisões importa mais do que a decisão em si.

O HashiCorp Vault fica nessa mesma camada porque segredos têm o mesmo status que dados de identidade — são ativos que precisam de governança, não variáveis de ambiente.

**A Shadow API é o desacoplamento que salva projetos**

A camada de API existe para que o midPoint nunca dependa diretamente da estrutura interna do OrangeHRM. Quando o sistema de RH muda — e sempre muda — a fronteira de impacto fica contida nessa camada. O midPoint continua recebendo `emp_number`, enums fechados e política de null independente do que acontece no RH.

O DevSecOps entra aqui como guardrail: a Shadow API não é só uma camada de adaptação, é um perímetro de segurança com análise estática, scan de container e testes de API antes de cada deploy.

**O midPoint é onde governança vira execução**

A camada de IGA é onde os dados de RH — normalizados pela Shadow API, autenticados pelo Vault — se tornam decisões de acesso. `TERMINATED` no enum vira offboarding. Mudança de `jobTitle` vira recálculo de Role. Divergência entre o que o AD tem e o que o RH diz vira tarefa de reconciliação.

A governança TAP·TEP·POP entra como guardrail paralelo: cada decisão de configuração do midPoint tem rastreabilidade de projeto. Se alguém perguntar daqui a dois anos "por que esse Role foi configurado assim", existe um TEP com a resposta.

**O Entra Connect é onde o mundo real complica**

A camada de diretório operacional é onde o PRJ015 e o diagnóstico da DPSP se encontram. O AD operacional é provisionado pelo midPoint. O Entra Connect sincroniza esse AD para o Entra ID — mas só funciona se o WebSocket não estiver sendo interceptado pelo Netskope e se o tenant cloud não tiver objetos conflitantes sem âncora de correlação.

Esses dois problemas — proxy SSL e SSoT violado — são invisíveis até quebrarem produção. O Lab documentou ambos com causa raiz e decisão de remediação.

**O Entra ID é o destino, não o ponto de partida**

A lição mais contraintuitiva do conjunto de projetos: organizações tendem a começar pelo Entra ID porque é o que o time de TI conhece. O Lab demonstrou — via falha documentada no PRJ015 — que o Entra ID deve ser o último sistema a receber identidades, não o primeiro a criá-las.

**O que essa arquitetura entrega para uma organização**

Não é uma stack de produtos. É uma metodologia com evidência: cada componente tem um projeto numerado, cada decisão tem um TEP, cada operação tem um POP. Uma organização que adota essa arquitetura não está comprando software — está comprando o mapa de onde os problemas estão antes de encontrá-los em produção.

Quer que eu transforme isso em um deck executivo em PPTX para apresentar formalmente, ou prefere um documento de proposta de descoberta — um diagnóstico estruturado de 2 semanas que aplica essa metodologia ao ambiente de uma organização específica?




# PERPLEXITY

VERSAO 1

A seguir está uma retrospectiva executiva do Living Lab Fiqueok, cobrindo o período de dezembro de 2025 até agora, com foco em projetos, entregas, lições aprendidas e próximos passos. Usei os relatórios e GMUDs disponíveis na base para consolidar a linha do tempo e os aprendizados mais relevantes.REL-GMUD-003-Relatorio-de-Execucao-da-Mudanca.md+4

## Visão geral

Entre dezembro de 2025 e abril de 2026, o Living Lab consolidou três eixos principais: maturação da arquitetura de identidade do PRJ003, tentativa de automação e implantação da infraestrutura IGA, e evolução para uma abordagem mais determinística e governável com midPoint 4.9 e controle manual de schema.GMUD-011-IGA-Deploy-midPoint-4.9-Manual-Control.md+2  
O período foi marcado por vários ciclos de falha controlada, rollback e aprendizado, o que fortaleceu o laboratório como ambiente de experimentação com rastreabilidade e governança formal.REL-GMUD-007.md+2

## Linha do tempo

Em janeiro de 2026, a GMUD-003 consolidou a arquitetura lógica de identidade do PRJ003 sem executar mudanças técnicas, formalizando o Identity Decision Canvas, o C4 de contexto e a governança semântica que sustentariam as próximas etapas.[REL-GMUD-003-Relatorio-de-Execucao-da-Mudanca.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/5509885c-1c39-4fe8-94ab-549f1746392e/REL-GMUD-003-Relatorio-de-Execucao-da-Mudanca.md)  
Logo depois, o laboratório entrou numa sequência de tentativas de cold start e deploy da infraestrutura IAM/midPoint, com falhas sucessivas em GMUDs 005, 006, 007, 008 e 009, cada uma revelando uma causa-raiz diferente e gerando material de aprendizado para o próximo ciclo.REL-GMUD-009-v1.1.md+3  
No mesmo arco evolutivo, a GMUD-011 foi proposta como resposta arquitetural mais madura: midPoint 4.9 em ambiente greenfield, com provisionamento manual de schema e maior soberania sobre o banco.[GMUD-011-IGA-Deploy-midPoint-4.9-Manual-Control.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/67623396-eeff-47e3-9a69-e475c635fc33/GMUD-011-IGA-Deploy-midPoint-4.9-Manual-Control.md)

## PRJ003

O PRJ003 foi o núcleo da evolução de identidade do laboratório. A GMUD-003 consolidou a arquitetura lógica de identidade, explicitando o papel do IGA como orquestrador semântico, os limites entre decisão e execução, e a base conceitual para futuras mudanças técnicas.[REL-GMUD-003-Relatorio-de-Execucao-da-Mudanca.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/5509885c-1c39-4fe8-94ab-549f1746392e/REL-GMUD-003-Relatorio-de-Execucao-da-Mudanca.md)  
As GMUDs e relatórios subsequentes mostraram que o principal ganho do PRJ003 não foi apenas técnico, mas de governança: reduzir ambiguidade, evitar decisões “em voo” e exigir contratos semânticos antes de automação.DEC-ID-001 - Identity Decision Canvas — Governança de Decisão no PRJ003.md+1  
As lições centrais foram claras: decisões de identidade precisam preceder a integração; configurações técnicas não podem inferir semântica; e rollback, evidência e rastreabilidade precisam existir antes de qualquer tentativa operacional.DEC-ID-001 - Identity Decision Canvas — Governança de Decisão no PRJ003.md+1

## Infraestrutura IAM

A sequência GMUD-004, GMUD-005, GMUD-006, GMUD-007, GMUD-008 e GMUD-009 mostrou a tentativa de erguer a infraestrutura IAM baseada em midPoint e PostgreSQL em ambiente Docker/Hyper-V.REL-GMUD-008.md+5  
Os problemas se repetiram em padrões diferentes: autenticação, variáveis de ambiente, fallback silencioso para H2, volumes “envenenados”, conflitos entre camadas de configuração e dificuldades de rollback limpo.REL-GMUD-006_Executada_Sem_Sucesso_Rollback.md+4  
O aprendizado mais importante foi que automação parcial, sem baseline de infraestrutura e sem validação forte de pré-requisitos, amplia o risco em vez de reduzi-lo.REL-GMUD-009-v1.1.md+1

## Lições aprendidas

A primeira lição foi que a documentação oficial precisa ser consultada antes do deploy, não durante o troubleshooting; isso apareceu com muita força nas falhas do midPoint 4.8.REL-GMUD-007.md+1  
A segunda lição foi que health checks superficiais podem gerar falsos positivos, porque o sistema pode “subir” operando em H2 sem estar realmente conectado ao PostgreSQL.REL-GMUD-007.md+1  
A terceira lição foi que rollback precisa ser atômico e limpo, com remoção completa de volumes e estado residual, senão a tentativa seguinte herda corrupção anterior.REL-GMUD-008.md+1  
A quarta lição foi que separar infra-base, deploy IaC e validação de saúde reduz drasticamente o acoplamento e torna a investigação mais confiável.[REL-GMUD-008.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/702cf9f9-28fd-444e-8515-c27161f4833a/REL-GMUD-008.md)

## Evolução técnica

O aprendizado acumulado levou a uma mudança de direção: da tentativa de automatizar tudo para uma estratégia mais controlada, com midPoint 4.9, schema manual e fluxo de validação explícito.[GMUD-011-IGA-Deploy-midPoint-4.9-Manual-Control.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/67623396-eeff-47e3-9a69-e475c635fc33/GMUD-011-IGA-Deploy-midPoint-4.9-Manual-Control.md)  
A GMUD-011 representa esse novo estágio, porque prioriza determinismo, rastreabilidade e soberania de dados ao carregar os scripts SQL nativos do banco antes de iniciar a aplicação.[GMUD-011-IGA-Deploy-midPoint-4.9-Manual-Control.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/67623396-eeff-47e3-9a69-e475c635fc33/GMUD-011-IGA-Deploy-midPoint-4.9-Manual-Control.md)  
Esse reposicionamento é importante porque troca a expectativa de “imagem pronta” por um processo arquiteturalmente mais confiável e auditável.[GMUD-011-IGA-Deploy-midPoint-4.9-Manual-Control.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/67623396-eeff-47e3-9a69-e475c635fc33/GMUD-011-IGA-Deploy-midPoint-4.9-Manual-Control.md)

## Próximos passos

O próximo passo imediato é formalizar a GMUD-011 como referência do novo padrão operacional para o PRJ003, validando se o controle manual de schema resolve os problemas recorrentes da linha 4.8.[GMUD-011-IGA-Deploy-midPoint-4.9-Manual-Control.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_fe45f63c-f098-4bbb-96bc-bd01dfc1d841/67623396-eeff-47e3-9a69-e475c635fc33/GMUD-011-IGA-Deploy-midPoint-4.9-Manual-Control.md)  
Em paralelo, vale consolidar um protocolo de pré-check: ambiente limpo, volumes zerados, validação de credenciais, validação de conexão PostgreSQL e verificação de logs logo no boot.REL-GMUD-009-v1.1.md+1  
Também faz sentido transformar os aprendizados das GMUDs falhadas em artefatos permanentes de memória, como um índice do workspace, um resumo de lições aprendidas e um mapa de decisões por projeto.REL-GMUD-009-v1.1.md+1

## Texto-base para a memória

Se o objetivo é alimentar a memória do AnythingLLM, o melhor formato é um documento com esta estrutura:

- Linha do tempo por projeto.
    
- O que foi feito.
    
- O que falhou.
    
- Causa-raiz.
    
- Lição aprendida.
    
- Próximo passo.
    
- Status atual.
    

Isso reduz ambiguidade e facilita recuperação por palavra-chave, projeto e status.REL-GMUD-003-Relatorio-de-Execucao-da-Mudanca.md+4

Posso transformar isso agora em um **documento pronto para colar no workspace** em Markdown, já com títulos, subtítulos e linguagem mais “memória estratégica”.




VERSAO DEEPSEEK



# 📊 Retrospectiva dos Projetos do Living Lab Fiqueok

**Período:** Dezembro/2025 — Abril/2026  
**Responsável:** Paulo Feitosa Lima — GRC Lead

---

## Resumo Executivo

|Total Projetos|Concluídos|Em Andamento|Abortados|
|---|---|---|---|
|**20**|**16**|**2** (PRJ007, PRJ016)|**2** (PRJ006, PRJ014 parcial)|

---

## Linha do Tempo Consolidada

|Projeto|Nome|Período|Status|Camada|
|---|---|---|---|---|
|**PRJ001**|Laboratório de SI|Dez/2025|✅ Concluído|1|
|**PRJ002**|Infraestrutura Fiqueok|Jan/2026|✅ Concluído|1|
|**PRJ003**|IGA Greenfield (Fundamentos)|Jan/2026|✅ Concluído|1|
|**PRJ004**|IGA Data Lifecycle (CSV)|Jan/2026|✅ Concluído|2|
|**PRJ005**|Integração OrangeHRM (JDBC)|Fev/2026|✅ Concluído|2|
|**PRJ006**|Integração Dinâmica JDBC|Jan-Fev/2026|⚠️ Abortado|2|
|**PRJ007**|HashiCorp Vault (PAM)|Fev-Abr/2026|🟡 Ativo|6|
|**PRJ008**|Shadow API (FastAPI)|Mar/2026|✅ Concluído|4|
|**PRJ009**|SSH Secrets Engine|Mar/2026|✅ Concluído|4|
|**PRJ010**|Entra ID Integration|Mar/2026|✅ Concluído|4|
|**PRJ011**|midPoint Connector|Mar/2026|✅ Concluído|4|
|**PRJ012**|Provisionamento Automático|Mar/2026|✅ Concluído|4|
|**PRJ013**|Terraform IaC|Mar/2026|✅ Concluído|5|
|**PRJ014**|Hyper-V Automation|Mar/2026|⚠️ Parcial|5|
|**PRJ015**|Cloud Sync|Abr/2026|✅ Concluído|5|
|**PRJ016**|Sentinel Identity Shield|Abr/2026|🟡 Em execução|6|
|**PRJ017**|Cloudflare Zero Trust|Abr/2026|✅ Concluído|5|
|**PRJ018**|RAG Local (Perplexity → AnythingLLM)|18-24/04/2026|✅ Concluído|3|
|**PRJ019**|Automação Obsidian → AnythingLLM|24/04/2026|✅ Concluído|3|
|**PRJ020**|OpenVAS + DefectDojo|24/04/2026|✅ Concluído|6|
|**PRJ021**|DevSecOps (GitLab SAST/DAST)|24/04/2026|✅ Concluído|6|

---

## Fase 1 — Fundação (Camada 1)

|Projeto|Entregue|Lição Principal|
|---|---|---|
|PRJ001|Baseline de segurança, VirtualBox → Hyper-V|GMUDs como disciplina|
|PRJ002|AD, midPoint, OrangeHRM, rede|Conflito /16 vs /24 causou 19h de downtime|
|PRJ003|Canvases de identidade, midPoint 4.10|Race condition PostgreSQL não prevista por IA|

---

## Fase 2 — Integração (Camada 2)

|Projeto|Entregue|Lição Principal|
|---|---|---|
|PRJ004|CSV como fonte autoritativa|Primeiro ciclo JML validado|
|PRJ005|OrangeHRM via JDBC|2 dias de sucesso|
|PRJ006|Abortado|API-first é princípio, não sugestão (30 dias perdidos)|

---

## Fase 3 — RAG e Memória (Camada 3)

|Projeto|Entregue|Lição Principal|
|---|---|---|
|PRJ018|222 conversas Perplexity extraídas, AnythingLLM + Ollama|Workspaces por camada temática|
|PRJ019|Automação Obsidian → AnythingLLM via API|SAST/DAST delegado ao PRJ021|

---

## Fase 4 — Orquestração (Camada 4)

|Projeto|Entregue|Lição Principal|
|---|---|---|
|PRJ008|Shadow API (FastAPI)|Proxy de autenticação Vault|
|PRJ009|SSH Secrets Engine|Assinatura de chaves SSH|
|PRJ010|Entra ID Integration|Integração híbrida|
|PRJ011|midPoint Connector|Provisionamento via REST|
|PRJ012|Provisionamento Automático|JML automatizado|

---

## Fase 5 — Infraestrutura (Camada 5)

|Projeto|Entregue|Lição Principal|
|---|---|---|
|PRJ013|Terraform IaC|Infraestrutura como código|
|PRJ014|Hyper-V Automation|CONSTRAINT-001 (GEN2 corrompida)|
|PRJ015|Cloud Sync|Sincronismo via API|
|PRJ017|Cloudflare Zero Trust|OTP por e-mail|

---

## Fase 6 — Segurança (Camada 6)

|Projeto|Entregue|Lição Principal|
|---|---|---|
|PRJ007|Vault operacional (GEN1)|WSL2 não é plataforma crítica|
|PRJ016|Sentinel (eBPF, Wazuh, Akto, n8n)|Em execução|
|PRJ020|OpenVAS + DefectDojo|Shadow API Discovery|
|PRJ021|GitLab SAST/DAST|DevSecOps pipeline|

---

## Estatísticas Agregadas

|Métrica|Valor|
|---|---|
|Total de GMUDs executadas|45+|
|Total de ADRs formalizados|12|
|Total de documentos indexados no AnythingLLM|495+|
|Total de conversas extraídas do Perplexity|222|
|Lições aprendidas documentadas|31|
|Riscos abertos monitorados|7|

---

## Principais Decisões Arquiteturais (ADR)

|ADR|Decisão|Projeto|
|---|---|---|
|001|Bind mounts vs volumes Docker|PRJ003|
|002|Production Checkpoints obrigatórios|PRJ003|
|003|Cross-mapping de frameworks|PRJ003|
|004|ScriptedSQL vs DatabaseTable|PRJ002|
|005|Rebuild IGA-P-01 → IGA-P-02|PRJ002|
|006|Estratégia de ingestão OrangeHRM|PRJ002|
|007|API Service vs Script (automação)|PRJ019|

---

## Frameworks de Conformidade Evidenciados

|Framework|Controles cobertos|
|---|---|
|ISO 27001|A.5.1, A.8.3, A.8.9, A.8.13, A.8.15, A.8.29, A.8.32, A.12.4, A.12.7, A.13.1.1, A.14.2.8|
|CIS Controls v8|3, 4, 8, 11|
|NIST CSF 2.0|GOVERN, IDENTIFY, PROTECT, DETECT, RESPOND, RECOVER|
|SOC 2|CC6.1, CC7.3, CC8.1, A1.2|

---

**Fim da Retrospectiva**

📁 **Localização:** `10_Projetos/RETROSPECTIVA-ABR2026.md`

Storytelling.md

MD 68.75KB

Solicitei as demais IAS para me fazer uma retrospectiva de todos os projetos como se fosse um storytelling contando o que realizamos, o que fizemos certo o que nao funcionou e as licoes aprendidas. Cada uma escreveu aquilo que lembrou de acordo com o contexto e o prompt que estava. Acredito que a deepseek consegue fazer um documento mais completo, executivo e coerente com a realidade. Faca a sua versao.

# 🧠 Living Lab Fiqueok — A Saga da Identidade Soberana

## Storytelling Executivo · Dez/2025 — Abr/2026

---

## Sumário Executivo

Em quatro meses, o Living Lab Fiqueok evoluiu de um ambiente informal de estudos para um **gêmeo digital corporativo de IAM/IGA**, com governança documentada, rastreabilidade de decisões e evidência empírica de falhas e acertos. A saga não foi linear — teve 45+ GMUDs, 2 projetos abortados, 3 plataformas testadas, e uma lição central consolidada: **a qualidade da decisão precede a qualidade da automação.**

---

## Ato 1 — A Demolição (Dez/2025)

**O problema:** Um laboratório funcional em VirtualBox, domínio `lab.local`, infraestrutura sem padronização. Servia para estudo, mas não para portfólio.

**A decisão:** Demolir tudo. Migrar para Hyper-V com TPM 2.0, Secure Boot, domínio `corp.fiqueok.com.br`. Primeiro ato de governança: **se não pode ser auditável, não existe.**

**O que deu certo:**

- Baseline de segurança com hardening TLS e bloqueio de enumeração anônima.
    
- Estrutura de OUs baseada em Tier Model — não organograma.
    

**O que não funcionou:**

- Nada ainda. Era o início.
    

**Lições:** O nome `lab.local` não vende consultoria. A credibilidade começa na identidade do ambiente.

---

## Ato 2 — A Infraestrutura e o Primeiro Incidente (Jan/2026)

**O problema:** Construir o core do laboratório — AD, midPoint 4.10, OrangeHRM — em um mês, com 25+ GMUDs.

**O incidente crítico:** Conflito de subnets `/16` vs `/24` deixou o laboratório offline por **19 horas**. Causa raiz: configuração de rede feita no escuro, sem validação de pré-requisitos.

**O que deu certo:**

- midPoint 4.10 e OrangeHRM operacionais.
    
- Tailscale adotado como backbone Zero Trust — abandono das VLANs complexas.
    

**O que não funcionou:**

- Tentativa de integração direta JDBC do midPoint com OrangeHRM falhou múltiplas vezes.
    
- Conflito de rede expôs fragilidade da infraestrutura como afterthought.
    

**Lições:** Infraestrutura não é detalhe — é alicerce. IPs estáveis, DNS resolvível e rede determinística são Fase 0, não melhoria futura.

---

## Ato 3 — O Pivô Arquitetural (Jan/2026)

**O problema reconhecido:** As falhas do PRJ002 não eram técnicas — eram **semânticas**. Identificador canônico indefinido. Autoridade de dados implícita. Estados de identidade ambíguos.

**A resposta:** PRJ003 — um projeto **sem GMUD técnica**. Apenas decisões. Canvases de identidade, ADRs, contratos semânticos. O IGA como orquestrador, não como dono absoluto dos dados.

**O que deu certo:**

- Definição de identidade canônica: existe independentemente de contas técnicas.
    
- Autoridade por atributo, não por sistema.
    
- Estados explícitos: Pré-criada, Ativa, Suspensa, Desligada, Órfã.
    

**O que não funcionou:**

- A tentativa posterior de pular esses contratos e ir direto para automação (PRJ006) falhou espetacularmente.
    

**Lições:** Nenhuma IA previu a race condition entre PostgreSQL e midPoint. A solução foi empírica. **Configuração não substitui decisão.**

---

## Ato 4 — O Anti-Padrão JDBC (Jan–Fev/2026)

**O problema:** Integrar midPoint ao OrangeHRM via JDBC direto — o caminho "mais rápido".

**A realidade:** Schema do OrangeHRM altamente normalizado exigiu **8+ JOINs** para extrair um perfil único. Correlação nunca funcionou. Estado `UNMATCHED` persistente. Reações de sincronização nunca dispararam.

**A decisão crítica:** Abortar após 30 dias. Documentar o anti-padrão. Consolidar o princípio: **API-first, nunca JDBC direto.**

**O que deu certo:**

- A infraestrutura foi saneada — subrede isolada `192.168.70.0/24`, IPs fixos, Tailscale consolidado.
    
- OAuth 2.0 configurado no OrangeHRM.
    

**O que não funcionou:**

- A integração JDBC. Nunca.
    

**Lições:** "Fail fast" documentando tudo é maturidade. Entregar uma solução frágil seria pior que abortar.

---

## Ato 5 — O Vault e a Queda do WSL2 (Fev–Abr/2026)

**O problema:** Sem cofre de senhas, credenciais viviam na memória humana ou hardcoded. Risco operacional crítico.

**A jornada do Vault:**

- **Tentativa 1:** OCI ARM — funcional, mas destruída por clique acidental.
    
- **Tentativa 2:** WSL2 + Docker com Gemini — abortada por `chmod 777` sugerido pela IA.
    
- **Tentativa 3:** WSL2 com instalação nativa — funcionou até o **primeiro reboot**. WSL2 não persiste daemons. Raft RPC layer fecha. Unseal manual obrigatório.
    
- **Tentativa 4:** Hyper-V GEN1 — estável, operacional, com Cloudflare ZT e OTP.
    

**O que deu certo:**

- Vault 1.21.3 operacional com Raft storage, políticas RBAC, audit device fail-closed.
    
- Integração com Tailscale e Cloudflare.
    

**O que não funcionou:**

- WSL2 para workloads críticos. Nenhuma IA previu as limitações.
    

**Lições:** WSL2 não é plataforma para infraestrutura. Vault em GEN1 é aceitável até a CONSTRAINT-001 ser resolvida.

---

## Ato 6 — A Memória de Longo Prazo (Abr/2026)

**O problema:** O conhecimento estava disperso — 222 conversas no Perplexity, documentos no Obsidian, sem indexação central.

**A solução:** Extração de 222 conversas via Playwright (97.4% de sucesso), indexação no AnythingLLM + Ollama, organização em **6 camadas temáticas**.

**O que deu certo:**

- 495+ documentos indexados.
    
- Qwen2.5:7b como LLM principal — melhor em português.
    
- Workspace consolidado com prompt de citação obrigatória.
    

**O que não funcionou:**

- AnythingLLM Desktop tem limitações para grandes volumes.
    
- A automação da ingestão (PRJ019) ainda depende de PRJ021 para SAST/DAST.
    

**Lições:** A memória institucional é um ativo. Se não está indexada, não existe.

---

## Ato 7 — O Que Vem (Abr–Mai/2026)

**Projetos em andamento:**

- **PRJ016 (Sentinel):** eBPF + Wazuh + Akto + n8n para ITDR.
    
- **PRJ020 (OpenVAS/DefectDojo):** Vulnerability management e shadow API discovery.
    
- **PRJ021 (GitLab DevSecOps):** SAST/DAST/SCA para pipelines de segurança.
    

**Decisões tomadas:**

- PRJ019 (automação da ingestão) **não depende** do PRJ021 — inicia com controles manuais.
    
- PRJ021 em GEN1 (respeita CONSTRAINT-001) com GitLab Self-Managed.
    

---

## O Que o Lab Provou Até Aqui

|Afirmação|Evidência|
|---|---|
|Decisões semânticas precedem automação|PRJ003 — Canvases antes de qualquer GMUD técnica|
|API-first é princípio, não sugestão|PRJ006 — 30 dias perdidos com JDBC|
|WSL2 não é plataforma crítica|PRJ007 — Falha estrutural após reboot|
|Abortar projeto é decisão madura|PRJ006 — Post-mortem exaustivo|
|Memória institucional exige indexação|PRJ018 — 495+ documentos no AnythingLLM|
|SAST/DAST não substitui revisão manual|PRJ019 — Início com controles manuais|

---

## Veredito

O Living Lab Fiqueok não é um "ambiente de teste". É um **modelo de governança de identidade aplicada**, onde cada falha é documentada, cada decisão é rastreável, e cada sucesso é reproduzível. A saga de dezembro a abril mostrou que **a qualidade da governança determina a qualidade da tecnologia** — não o inverso.

---

**Fim da Retrospectiva**

📁 **Localização:** `10_Projetos/RETROSPECTIVA-DEEPSEEK-ABR2026.md`
