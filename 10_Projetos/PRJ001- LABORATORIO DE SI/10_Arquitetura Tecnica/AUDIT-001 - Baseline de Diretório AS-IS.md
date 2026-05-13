# 

> [!fail] Diagnóstico Inicial
> O ambiente encontra-se em estado **Não Conforme**.
> - **0 Unidades Organizacionais** criadas.
> - **100% dos usuários** residem no container default `CN=Users`.
> - Impossibilidade técnica de aplicar GPOs granulares.

### Evidência Técnica (Log)
```text
**********************
Windows PowerShell transcript start
Start time: 20251219132105
Username: LAB\Administrator
RunAs User: LAB\Administrator
Configuration Name: 
Machine: DC01 (Microsoft Windows NT 10.0.20348.0)
Host Application: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -noExit -Command Invoke-SConfigLogon
Process ID: 3528
PSVersion: 5.1.20348.558
PSEdition: Desktop
PSCompatibleVersions: 1.0, 2.0, 3.0, 4.0, 5.0, 5.1.20348.558
BuildVersion: 10.0.20348.558
CLRVersion: 4.0.30319.42000
WSManStackVersion: 3.0
PSRemotingProtocolVersion: 2.3
SerializationVersion: 1.1.0.1
**********************
Transcript started, output file is C:\Temp\Auditoria_AS_IS_20251219_1321.txt
>>> RELATÓRIO DE ESTRUTURA (AS-IS) <<<
Domínio Alvo: DC=lab,DC=local
---------------------------------------------------
1. ANÁLISE DO CONTAINER PADRÃO (CN=Users,DC=lab,DC=local)
   Total de Usuários fora de padrão: 4

---------------------------------------------------
2. MAPA DE OUS ATUAL

Name               DistinguishedName
----               -----------------
Domain Controllers OU=Domain Controllers,DC=lab,DC=local
FIQUEOK_CORP       OU=FIQUEOK_CORP,DC=lab,DC=local
Groups             OU=Groups,OU=FIQUEOK_CORP,DC=lab,DC=local
Identity_Tier0     OU=Identity_Tier0,OU=FIQUEOK_CORP,DC=lab,DC=local
Identity_Tier1     OU=Identity_Tier1,OU=FIQUEOK_CORP,DC=lab,DC=local
Identity_Tier2     OU=Identity_Tier2,OU=FIQUEOK_CORP,DC=lab,DC=local
LAB-Usuarios       OU=LAB-Usuarios,DC=lab,DC=local
Servers            OU=Servers,OU=FIQUEOK_CORP,DC=lab,DC=local
Service_Accounts   OU=Service_Accounts,OU=FIQUEOK_CORP,DC=lab,DC=local
Users              OU=Users,OU=FIQUEOK_CORP,DC=lab,DC=local
Workstations       OU=Workstations,OU=FIQUEOK_CORP,DC=lab,DC=local


**********************
Windows PowerShell transcript end
End time: 20251219132105
**********************