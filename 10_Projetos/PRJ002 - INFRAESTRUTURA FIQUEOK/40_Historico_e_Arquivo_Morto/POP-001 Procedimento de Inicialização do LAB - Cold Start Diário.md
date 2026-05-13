# 📋 

**Status:** Ativo  
**Versão:** 1.0  
**Data de criação:** 30/12/2025  
**Tipo:** POP - Procedimento Operacional Padrão  
**Owner:** Paulo Feitosa  
**Frequência:** Diária - antes de qualquer atividade no LAB

---

## 🎯 Objetivo

Garantir que o ambiente de laboratório PRJ001 (midPoint + OrangeHRM + AD DS) esteja íntegro, operacional e no estado de referência esperado antes de iniciar qualquer atividade de configuração, teste, GMUD ou experimento de GRC/IGA.[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

---

## 📋 Pré-requisitos do Técnico

- Acesso físico ou RDP ao PC Host Hyper-V (Windows 11 Pro)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- Conta com permissão de administrador local no host[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- Credenciais de administrador do midPoint (usuário `administrator` ou break-glass)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- Credenciais de administrador do OrangeHRM[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- Acesso ao vault de senhas da Fiqueok (Obsidian ou gerenciador de senhas)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

---

## 🚀 Procedimento de Inicialização

## 1️⃣ Verificações Iniciais no Host Hyper-V

## 1.1. Ligar e acessar o host

-  Ligar o PC Host (Hyper-V)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Fazer login no Windows 11 Pro com conta Fiqueok)
    
-  Registrar horário de início do procedimento[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

## 1.2. Validar data, hora e sincronização

-  Clicar no relógio da barra de tarefas[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Confirmar que data e hora estão corretas[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Verificar se a sincronização está ativa (crítico para logs, tokens e certificados)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

## 1.3. Teste de conectividade básica

Abrir **PowerShell** como administrador e executar:

powershell

`# Teste de conectividade com DNS público ping 8.8.8.8 # Teste de resolução DNS ping www.google.com`

-  Confirmar resposta de ambos os comandos[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Se falhar, registrar no log de operação antes de prosseguir[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

---

## 2️⃣ Verificar Rede do LAB (VLAN 1 - xxx.xxx.xxx.xxx/16)

## 2.1. Validar configuração de IP do host

-  Abrir **Painel de Controle** → **Central de Rede e Compartilhamento** → **Alterar configurações do adaptador**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Localizar interface do **vSwitch FiqueokCorp** (VLAN 1)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Clicar com botão direito → **Propriedades** → **Protocolo IP Versão 4 (TCP/IPv4)**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Confirmar configuração:
    
    - **IP estático:** xxx.xxx.xxx.xxx (ou conforme GMUD-007)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
        
    - **Máscara de rede:** 255.255.0.0 (/16)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
        
    - **Gateway:** (se aplicável ao cenário)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
        

## 2.2. Testar conectividade com Domain Controller

No PowerShell, executar:

powershell

`# Ping para o AD DS (ID-P-01) ping xxx.xxx.xxx.xxx # Verificar porta LDAP Test-NetConnection -ComputerName xxx.xxx.xxx.xxx -Port 389`

-  Confirmar resposta do ping[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Validar conectividade na porta 389 (LDAP)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

> ⚠️ **PONTO DE BLOQUEIO:** Se o AD DS (xxx.xxx.xxx.xxx) não responder, **NÃO prosseguir** com testes de IAM/IGA. Registrar RNC e investigar causa raiz.[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

---

## 3️⃣ Inicializar VM IGA-P-01 (Ubuntu 22.04 - Docker Host)

## 3.1. Subir a VM no Hyper-V

-  Abrir **Hyper-V Manager**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Localizar VM **IGA-P-01** (Ubuntu 22.04)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Se estiver desligada: clicar com botão direito → **Start**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Aguardar inicialização completa (cerca de 1-2 minutos)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

## 3.2. Acessar console da VM

-  Clicar com botão direito em **IGA-P-01** → **Connect…**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Fazer login no Ubuntu com conta administrativa do Docker Host[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

## 3.3. Validar configuração de rede da VM

No terminal do Ubuntu, executar:

bash

`# Verificar IP da interface ip a # Verificar rota padrão ip route # Testar conectividade com AD DS ping -c 4 xxx.xxx.xxx.xxx # Testar conectividade com o próprio IP ping -c 4 xxx.xxx.xxx.xxx`

-  Confirmar IP **xxx.xxx.xxx.xxx/16** na interface principal[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Validar rota padrão configurada[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Confirmar resposta do ping para AD DS (xxx.xxx.xxx.xxx)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Confirmar resposta do ping para IP local (xxx.xxx.xxx.xxx)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

---

## 4️⃣ Inicializar Bancos de Dados

> 📌 **Ordem crítica:** Bancos de dados devem subir **ANTES** das aplicações midPoint e OrangeHRM.[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

## 4.1. Subir PostgreSQL 16 (repositório do midPoint)

No terminal do Ubuntu, executar:

bash

`# Iniciar serviço PostgreSQL sudo systemctl start postgresql # Verificar status sudo systemctl status postgresql # Verificar porta de escuta ss -tulnp | grep 5432`

-  Confirmar status **active (running)**[](https://www.commandprompt.com/education/how-to-start-or-stop-postgresql-server-on-ubuntu/)​
    
-  Confirmar PostgreSQL escutando na porta **5432**[](https://www.postgresql.org/docs/current/server-start.html)​
    

> ⚠️ **PONTO DE BLOQUEIO:** Se PostgreSQL falhar, anotar mensagem de erro completa e **NÃO iniciar midPoint** até resolver.[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

## 4.2. Subir MariaDB 11.4 (banco do OrangeHRM)

No terminal do Ubuntu, executar:

bash

`# Iniciar serviço MariaDB sudo systemctl start mariadb # Verificar status sudo systemctl status mariadb # Verificar porta de escuta ss -tulnp | grep 3306`

-  Confirmar status **active (running)**[](https://mariadb.com/docs/server/server-management/automated-mariadb-deployment-and-administration/docker-and-mariadb/installing-and-using-mariadb-via-docker)​
    
-  Confirmar MariaDB escutando na porta **3306**[](https://hub.docker.com/_/mariadb)​
    

> ⚠️ **PONTO DE BLOQUEIO:** Se MariaDB falhar, anotar mensagem de erro e **NÃO iniciar OrangeHRM** até resolver.[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

---

## 5️⃣ Inicializar Containers Docker (midPoint + OrangeHRM)

## 5.1. Navegar até diretório do stack IGA

bash

`# Acessar diretório do Docker Compose cd /opt/stack-iga # (ajustar caminho conforme padronização definida em GMUD)`

-  Confirmar presença do arquivo `docker-compose.yml`[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

## 5.2. Subir containers em background

bash

`# Iniciar stack completo docker compose up -d # Verificar containers em execução docker ps`

-  Confirmar container **midPoint 4.10** rodando (porta 8080 mapeada)[](https://docs.evolveum.com/midpoint/install/containers/docker/)​
    
-  Confirmar container **OrangeHRM 5.8** rodando (porta 8081 mapeada)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

## 5.3. Verificar logs de inicialização (se necessário)

bash

`# Logs do midPoint docker logs midpoint-container -f # Logs do OrangeHRM docker logs orangehrm-container -f`

-  Observar se há erros críticos nos logs[](https://docs.evolveum.com/midpoint/install/containers/docker/)​
    
-  Aguardar mensagem de inicialização completa[](https://docs.evolveum.com/midpoint/devel/guides/environment/embedded-tomcat/)​
    

> ⏱️ **Tempo de aguardo:** midPoint leva aproximadamente **2-3 minutos** para inicializar completamente o Tomcat embarcado e carregar o console.[](https://docs.evolveum.com/midpoint/reference/support-4.10/deployment/stand-alone-deployment/)​

---

## 6️⃣ Testes de Acesso às Aplicações

## 6.1. Acessar console do midPoint

No navegador (host ou máquina com rota para VLAN 1):

-  Acessar `http://xxx.xxx.xxx.xxx:8080/midpoint`[](https://docs.evolveum.com/midpoint/install/containers/docker/)​
    
-  Fazer login com usuário **administrator**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Confirmar carregamento completo do dashboard[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

## 6.2. Acessar interface do OrangeHRM

No navegador:

-  Acessar `http://xxx.xxx.xxx.xxx:8081`[](https://mariushosting.com/how-to-install-orangehrm-on-your-synology-nas/)​
    
-  Fazer login com conta administrativa de RH[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Confirmar carregamento da interface principal[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

---

## 7️⃣ Pre-Flight Check - Validação de Saúde do Sistema

> 🔍 **Objetivo:** Confirmar que o ambiente está no estado de referência esperado antes de qualquer mudança.[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

## 7.1. Teste de conexão com recurso OrangeHRM (no midPoint)

No console do midPoint:

-  Navegar para **Resources** → **All resources**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Localizar recurso **OrangeHRM-Source-v4.2**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Clicar no recurso para abrir detalhes[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Clicar no botão **Test connection**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Confirmar status **Success** (verde)[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

**Se o teste falhar:**

- Capturar print da mensagem de erro[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- Verificar se OrangeHRM está acessível via browser[](https://mariushosting.com/how-to-install-orangehrm-on-your-synology-nas/)​
    
- Verificar se MariaDB está escutando na porta 3306[](https://hub.docker.com/_/mariadb)​
    
- Validar credenciais armazenadas no recurso[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- Registrar RNC se necessário[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

## 7.2. Verificação de inventário de contas

Ainda no recurso **OrangeHRM-Source-v4.2**:

-  Clicar na aba **Accounts**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Localizar registro **0001**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Confirmar que o registro possui ícone de **interrogação (?)** indicando status **Unmatched**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

> 📌 **Significado:** Conta não correlacionada, indicando estado de referência esperado para exercícios de correlação e reconciliação.[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

## 7.3. Verificação de status de tarefas

No console do midPoint:

-  Navegar para **Server tasks** → **List tasks**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Localizar tarefa **Import OrangeHRM Identities**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Confirmar que o estado está **CLOSED**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

**Se a tarefa estiver RUNNING ou WAITING sem motivo planejado:**

- Registrar no log de operação[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- Pausar/parar a tarefa antes de novas execuções[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- Investigar causa e registrar RNC se necessário[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

---

## 8️⃣ Registro de Conclusão do Procedimento

## 8.1. Criar log diário de operação no Obsidian

Caminho: `10_Projetos/PRJ001- LABORATORIO DE SI/30_Operacao & Mudancas/`

Nome do arquivo: `LOG-COLD-START-YYYY-MM-DD.md`

**Template do log:**

text

`# Log de Cold Start - DD/MM/YYYY **Técnico responsável:** [Nome]   **Horário de início:** HH:MM   **Horário de conclusão:** HH:MM   ## Checklist de Inicialização - [ ] Host Hyper-V inicializado - [ ] Rede VLAN 1 validada (xxx.xxx.xxx.xxx/16) - [ ] AD DS (xxx.xxx.xxx.xxx) respondendo - [ ] VM IGA-P-01 inicializada - [ ] PostgreSQL 16 ativo (porta 5432) - [ ] MariaDB 11.4 ativo (porta 3306) - [ ] Container midPoint rodando (porta 8080) - [ ] Container OrangeHRM rodando (porta 8081) - [ ] Console midPoint acessível - [ ] Interface OrangeHRM acessível ## Pre-Flight Check - [ ] Test connection OrangeHRM-Source-v4.2: **Success** - [ ] Conta 0001 no inventário: **Unmatched** (status OK) - [ ] Tarefa Import OrangeHRM Identities: **CLOSED** ## Observações [Registrar qualquer anomalia, erro ou comportamento inesperado] ## Ações Necessárias - [ ] Nenhuma / Sistema íntegro - [ ] RNC aberta: [número e link] - [ ] GMUD pendente: [número e link] --- **Status final:** ✅ Ambiente operacional / ⚠️ Ambiente com restrições / ❌ Ambiente indisponível`

## 8.2. Registrar RNC se houver falhas críticas

Se algum item crítico falhar:

-  Criar RNC usando `TEMPLATE-001 - RNC`[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Referenciar a RNC no log diário[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
-  Não prosseguir com GMUDs ou alterações até resolução[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

---

## 📊 Critérios de Sucesso

O procedimento de Cold Start está **concluído com sucesso** quando:

1. ✅ Todos os serviços estão com status **active (running)**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
2. ✅ Test connection do recurso OrangeHRM retorna **Success**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
3. ✅ Conta 0001 está visível no inventário com status **Unmatched**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
4. ✅ Tarefa Import OrangeHRM Identities está em estado **CLOSED**[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
5. ✅ Console do midPoint e interface do OrangeHRM estão acessíveis[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

---

## ⚠️ Pontos de Bloqueio Críticos

**NÃO prosseguir com atividades do LAB se:**

- 🚫 AD DS (xxx.xxx.xxx.xxx) não responder[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- 🚫 PostgreSQL 16 não inicializar[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- 🚫 MariaDB 11.4 não inicializar[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- 🚫 Test connection do recurso OrangeHRM falhar[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

**Ação obrigatória:** Registrar RNC e investigar causa raiz antes de qualquer GMUD.[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​

---

## 🔗 Referências

- **GMUD-007:** Alteração de Endereçamento IP Estático[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- **GMUD-008:** Implantação da Stack midPoint 4.10[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- **GMUD-011:** Rede de Integração Segura Backend Bridge[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- **REL-GMUD-014:** Integração AD e IGA - Suspensão Técnica[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    
- **Manifesto Fiqueok v2.0:** Arquitetura e Governança do LAB[](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_c8737c37-d76d-417c-a629-c2b908421b68/cda39a11-0747-4005-a082-f16eebf5336e/Manifesto-de-Estrategia-e-Infraestrutura-Fiqueok-v2.0.pdf)​
    

---

## 📝 Changelog

|Versão|Data|Autor|Mudanças|
|---|---|---|---|
|1.0|30/12/2025|Paulo Feitosa|Criação inicial do procedimento Cold Start|

---

**Documento mantido por:** Paulo Feitosa (Owner/CISO)  
**Última revisão:** 30/12/2025  
**Próxima revisão obrigatória:** 27/01/2026
