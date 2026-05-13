PS C:\WINDOWS\system32> scp paulo@xxx.xxx.xxx.xxx:~/fiqueok_entraid_users.csv C:\Users\paulo\Documents\PRJ011\
paulo@xxx.xxx.xxx.xxx's password:
C:\WINDOWS\System32\OpenSSH\scp.exe: open local "C:/Users/paulo/Documents/PRJ011/": No such file or directory
PS C:\WINDOWS\system32> New-Item -ItemType Directory -Force -Path "C:\Users\paulo\Documents\PRJ011\"^C
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> # 1. Criar o diretório do projeto no seu Vault do Obsidian
PS C:\WINDOWS\system32> $ProjetoPath = "C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID"
PS C:\WINDOWS\system32> New-Item -ItemType Directory -Force -Path "$ProjetoPath\Evidencias"


    Diretório: C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----          3/1/2026   6:02 PM                Evidencias


PS C:\WINDOWS\system32> New-Item -ItemType Directory -Force -Path "$ProjetoPath\Scripts"


    Diretório: C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----          3/1/2026   6:02 PM                Scripts


PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> # 2. Mover o arquivo CSV para a pasta de dados do projeto
PS C:\WINDOWS\system32> Move-Item -Path "C:\Users\paulo\Documents\PRJ011\fiqueok_entraid_users.csv" -Destination "$ProjetoPath\fiqueok_entraid_users.csv" -Force
Move-Item : Não é possível localizar o caminho 'C:\Users\paulo\Documents\PRJ011\fiqueok_entraid_users.csv' porque ele
não existe.
No linha:1 caractere:1
+ Move-Item -Path "C:\Users\paulo\Documents\PRJ011\fiqueok_entraid_user ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (C:\Users\paulo\...traid_users.csv:String) [Move-Item], ItemNotFoundExce
   ption
    + FullyQualifiedErrorId : PathNotFound,Microsoft.PowerShell.Commands.MoveItemCommand

PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> # 3. Criar os arquivos de notas vazios para você preencher durante a execução
PS C:\WINDOWS\system32> New-Item -ItemType File -Path "$ProjetoPath\Logs_Execucao.md"


    Diretório: C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----          3/1/2026   6:02 PM              0 Logs_Execucao.md


PS C:\WINDOWS\system32> New-Item -ItemType File -Path "$ProjetoPath\Scripts\Provisioning_Script.ps1"


    Diretório: C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----          3/1/2026   6:02 PM              0 Provisioning_Script.ps1


PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> $ProjetoPath = "C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID"
PS C:\WINDOWS\system32> scp paulo@xxx.xxx.xxx.xxx:~/fiqueok_entraid_users.csv "$ProjetoPath\fiqueok_entraid_users.csv"
paulo@xxx.xxx.xxx.xxx's password:
fiqueok_entraid_users.csv                                                             100%   12KB   1.7MB/s   00:00
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> $Path = "$ProjetoPath\fiqueok_entraid_users.csv"
PS C:\WINDOWS\system32> $Header = "EmployeeID,FirstName,LastName,DisplayName,UserPrincipalName,JobTitle,Department,Salary"
PS C:\WINDOWS\system32> $Content = Get-Content $Path
PS C:\WINDOWS\system32> $Header, $Content | Set-Content $Path -Encoding UTF8
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> # Validar se os dados estão legíveis
PS C:\WINDOWS\system32> Import-Csv $Path | Select-Object -First 5 | Format-Table

EmployeeID FirstName LastName DisplayName     UserPrincipalName              JobTitle Department Salary
---------- --------- -------- -----------     -----------------              -------- ---------- ------
FP001      David     VÃ©lez   David VÃ©lez    david.velez@fiqueok.com.br     CEO      Executive  48000.00
FP002      AndrÃ©    Chaves   AndrÃ© Chaves   andre.chaves@fiqueok.com.br    Chairman Executive  42000.00
FP003      Luisa     Sotero   Luisa Sotero    luisa.sotero@fiqueok.com.br    COO      Executive  39000.00
FP004      Daniela   Binatti  Daniela Binatti daniela.binatti@fiqueok.com.br CTO      Executive  44000.00
FP005      Ricardo   Guerra   Ricardo Guerra  ricardo.guerra@fiqueok.com.br  CIO      Executive  41000.00


PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> $ProjetoPath = "C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID"
PS C:\WINDOWS\system32> $Path = "$ProjetoPath\fiqueok_entraid_users.csv"
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> # Re-salvando com encoding explícito para corrigir acentuação
PS C:\WINDOWS\system32> $Utf8Content = Get-Content $Path
PS C:\WINDOWS\system32> $Utf8Content | Set-Content $Path -Encoding utf8BOM
Set-Content : Não é possível associar o parâmetro 'Encoding'. Não é possível converter o valor "utf8BOM" para o tipo
"Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding". Erro: "Não é possível corresponder o nome do
identificador utf8BOM a um nome de enumerador válido. Especifique um dos seguintes nomes de enumerador e tente
novamente:
Unknown, String, Unicode, Byte, BigEndianUnicode, UTF8, UTF7, UTF32, Ascii, Default, Oem, BigEndianUTF32"
No linha:1 caractere:44
+ $Utf8Content | Set-Content $Path -Encoding utf8BOM
+                                            ~~~~~~~
    + CategoryInfo          : InvalidArgument: (:) [Set-Content], ParameterBindingException
    + FullyQualifiedErrorId : CannotConvertArgumentNoMessage,Microsoft.PowerShell.Commands.SetContentCommand

PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> # Valide se o David Vélez agora aparece com acento correto
PS C:\WINDOWS\system32> Import-Csv $Path | Select-Object -First 2 | Format-Table

EmployeeID FirstName LastName DisplayName   UserPrincipalName           JobTitle Department Salary
---------- --------- -------- -----------   -----------------           -------- ---------- ------
FP001      David     VÃ©lez   David VÃ©lez  david.velez@fiqueok.com.br  CEO      Executive  48000.00
FP002      AndrÃ©    Chaves   AndrÃ© Chaves andre.chaves@fiqueok.com.br Chairman Executive  42000.00


PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> $ProjetoPath = "C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID"
PS C:\WINDOWS\system32> $Path = "$ProjetoPath\fiqueok_entraid_users.csv"
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> # 1. Baixar o arquivo limpo sobrescrevendo o antigo
PS C:\WINDOWS\system32> scp paulo@xxx.xxx.xxx.xxx:~/fiqueok_entraid_limpo.csv $Path
paulo@xxx.xxx.xxx.xxx's password:
Permission denied, please try again.
paulo@xxx.xxx.xxx.xxx's password:
fiqueok_entraid_limpo.csv                                                             100%   12KB   1.5MB/s   00:00
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> # 2. Injetar o cabeçalho novamente (já que o OUTFILE não gera)
PS C:\WINDOWS\system32> $Header = "EmployeeID,FirstName,LastName,DisplayName,UserPrincipalName,JobTitle,Department,Salary"
PS C:\WINDOWS\system32> $Content = Get-Content $Path
PS C:\WINDOWS\system32> $Header, $Content | Set-Content $Path -Encoding UTF8
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> # 3. Validação Final
PS C:\WINDOWS\system32> Import-Csv $Path | Select-Object EmployeeID, DisplayName -First 5 | Format-Table

EmployeeID DisplayName
---------- -----------
FP001      David Velez
FP002      Andre Chaves
FP003      Luisa Sotero
FP004      Daniela Binatti
FP005      Ricardo Guerra


PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> cd 'C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\'
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID> ls


    Diretório: C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----          3/1/2026   6:02 PM                Evidencias
d-----          3/1/2026   6:02 PM                Scripts
-a----          3/1/2026   6:10 PM          12721 fiqueok_entraid_users.csv
-a----          3/1/2026   6:02 PM              0 Logs_Execucao.md
-a----          3/1/2026   5:49 PM          16668 TAP-PRJ011-v1.0 - Entra ID Identity JOIN.md


PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID> cd Scripts
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts> ls


    Diretório: C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----          3/1/2026   6:02 PM              0 Provisioning_Script.ps1


PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts> ls


    Diretório: C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----          3/1/2026   6:15 PM           1516 Provisioning_Script.ps1


PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts> cat .\Provisioning_Script.ps1
# PRJ011 - Provisionamento Massivo de Identidades (Fiqueok Living Lab)
# Fonte: OrangeHRM (CSV Sanitizado) | Destino: Microsoft Entra ID

$ProjetoPath = "C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID"
$CSVPath = "$ProjetoPath\fiqueok_entraid_users.csv"
$Users = Import-Csv $CSVPath

# Verificar conexÃ£o com o Graph
if (!(Get-MgContext)) {
    Write-Host "NÃ£o conectado. Iniciando Connect-MgGraph..." -ForegroundColor Yellow
    Connect-MgGraph -Scopes "User.ReadWrite.All"
}

foreach ($User in $Users) {
    $PasswordProfile = @{
        Password = "Fiqueok@2026!"
        ForceChangePasswordNextSignIn = $true
    }

    # Gera o apelido de e-mail a partir do UPN (ex: david.velez)
    $MailNick = $User.UserPrincipalName.Split('@')[0]

    try {
        New-MgUser `
            -DisplayName $User.DisplayName `
            -UserPrincipalName $User.UserPrincipalName `
            -MailNickname $MailNick `
            -AccountEnabled $true `
            -PasswordProfile $PasswordProfile `
            -JobTitle $User.JobTitle `
            -Department $User.Department `
            -EmployeeId $User.EmployeeID `
            -OnPremisesImmutableId $User.EmployeeID # Chave Ã‚ncora para IGA

        Write-Host "[SUCCESS] $($User.EmployeeID): $($User.UserPrincipalName) provisionado." -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] $($User.UserPrincipalName): $($_.Exception.Message)" -ForegroundColor Red
    }
}
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts> & "C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1"
NÃ£o conectado. Iniciando Connect-MgGraph...
Welcome to Microsoft Graph!

Connected via delegated access using 14d82eec-204b-4c2f-b7e8-296a70dab67e
Readme: https://aka.ms/graph/sdk/powershell
SDK Docs: https://aka.ms/graph/sdk/powershell/docs
API Docs: https://aka.ms/graph/docs

NOTE: You can use the -NoWelcome parameter to suppress this message.

[ERROR] david.velez@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] andre.chaves@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] luisa.sotero@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] daniela.binatti@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] ricardo.guerra@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] laszlo.bock@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] donner.marcos@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] lucas.carvalho@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] juliana.lima@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] gabriel.martins@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] patricia.silva@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] felipe.barbosa@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] renata.azevedo@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] andre.costa@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] tatiane.nunes@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] eduardo.ribeiro@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] leonardo.moreira@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] aline.teixeira@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] diego.pinto@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] marcos.goncalves@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] beatriz.ramos@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] jonathan.lopes@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] viviane.machado@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] gustavo.castro@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] larissa.campos@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] ricardo.moraes@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] jessica.cardoso@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] carlos.rezende@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] amanda.freitas@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] thiago.pereira@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] marcelo.tavares@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] daniela.rocha@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] rogerio.neves@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] vanessa.dias@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] murilo.barros@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] daniel.coelho@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] helena.ferreira@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] carla.araujo@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] rodrigo.monteiro@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] priscila.duarte@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] sergio.amaral@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] leticia.marques@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] joao.meireles@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] livia.sales@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] henrique.falcao@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] debora.menezes@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] rafaela.viana@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] pedro.queiroz@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] ana.paula@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] carlos.eduardo@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] gabriela.cruz@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] luciana.ferraz@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] renato.silveira@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] paulo.henrique@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] michele.carneiro@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] tatiana.castilho@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] vinicius.fonseca@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] sabrina.mota@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] natalia.lacerda@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] anderson.peixoto@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] caroline.mendes@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] joana.batista@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] samuel.rocha@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] roberta.vidal@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] igor.americo@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] danilo.assis@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] fabio.correia@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] karla.vasconcelos@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] eduarda.brandao@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] cassio.borges@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] patricia.macedo@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] felipe.lourenco@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] amanda.prado@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] gustavo.franco@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] carla.ribeiro@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] leandro.rezende@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] sofia.bueno@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] arthur.henrique@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] beatriz.moreira@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] lucas.toscano@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] emanuel.nogueira@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] cristina.alvarenga@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] raul.andrade@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] mariana.quevedo@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] thiago.pazinato@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] andreia.abreu@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] murilo.vasques@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] helena.santiago@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] julio.oliveira@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] tatiana.pozzebon@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] rodrigo.mendes@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] camila.freire@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] paula.bernardes@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] marcos.teixeira@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] rawfaela.costa@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] guilherme.lira@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] elaine.cardin@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] ricardo.ferraz@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] taina.lopes@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
[ERROR] fernanda.rossetti@fiqueok.com.br: Não é possível localizar um parâmetro posicional que aceite o argumento 'True'.
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts> $ScriptPath = "C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1"
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts> $NewContent = Get-Clipboard # Se você copiou o código acima, ou use o Set-Content anterior com este novo bloco
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts> # Ou simplesmente abra o arquivo no VS Code / Notepad e cole o novo código.
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts> & "C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1"
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:51
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 884976fd-6930-471a-9b76-e81f2ae91399
client-request-id             : a37a7054-d8d3-4f99-adee-8aef06dc40fe
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:51 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP001: david.velez@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:52
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 2a1f5785-64d8-456a-907d-1c93dfa82548
client-request-id             : 05478f88-3d2b-41df-b8ba-ad8d8be04d58
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:51 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP002: andre.chaves@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:52
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 75cc9aef-852f-4425-9af0-cf6ee76d4cbe
client-request-id             : 8830bd0e-1471-4c67-a53f-5376406bb94e
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:51 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP003: luisa.sotero@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:52
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 18365e90-370c-4ed8-85c3-6a27765e5b4f
client-request-id             : 83a2560b-3b29-4296-832e-c0d761d3f473
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:52 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP004: daniela.binatti@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:53
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 59391518-6c72-457b-a4ae-187d0ae8015a
client-request-id             : 592283dd-9e38-42c0-ad3f-c7336296f8d1
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:52 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP005: ricardo.guerra@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:53
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : b18020d3-044f-4f3b-a8cd-c780943f3048
client-request-id             : 4508beb7-42a9-4094-8831-eae2a62da8e7
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:53 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP006: laszlo.bock@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:54
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : c1458e4d-e2d4-4863-9688-62febce72eb2
client-request-id             : fe3d751f-7459-403d-ac93-dadda0da1be2
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:53 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP007: donner.marcos@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:54
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 38aa56ef-339c-4d3b-b592-fcc31da73a36
client-request-id             : 9a075f63-fc5f-4e02-adbd-114d20f2a535
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:54 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP008: lucas.carvalho@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:54
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : aa11cdec-ea81-40e7-91b7-607ec22541e5
client-request-id             : 2e495595-e404-4c9d-8d6a-18d53cb60bec
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:54 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP009: juliana.lima@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:55
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : af9bc346-76f3-4045-bd35-551dc6f7fcc3
client-request-id             : 5bfa4eaf-df7d-488c-aae5-bf26d4117463
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:54 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP010: gabriel.martins@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:55
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : dab79d31-ecad-48f1-9c54-f212d603f3ce
client-request-id             : 37da4ab7-b723-4f5c-ab7e-1baf21466d0d
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:55 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP011: patricia.silva@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:56
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 7c7b5c76-9bd6-4621-802a-ba0578491528
client-request-id             : 5a058b6e-d82f-4f11-9063-7119dfef66e8
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:55 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP012: felipe.barbosa@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:56
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : fdf7be95-f3c1-43f1-b4be-51f0a52e7d2a
client-request-id             : 7188513a-f135-40dd-a2dc-6a61d2c374c4
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:56 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP013: renata.azevedo@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:57
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : e9ce54ec-dfe1-4ef9-a93a-10e16efabe88
client-request-id             : 1fc0b600-d5ea-4119-b59e-d815523f7cb7
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:56 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP014: andre.costa@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:57
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : a696a3c8-f50a-47ed-808d-b320e9c7f654
client-request-id             : ddb8aa18-ca24-43ee-b815-17731ffae252
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:56 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP015: tatiane.nunes@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:57
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 32d6b5c7-4297-4e57-9ea5-f7813c17dafc
client-request-id             : b71783b8-aceb-4ce2-bbed-0683fbc20b13
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:57 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP016: eduardo.ribeiro@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:58
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : a6600449-2646-463a-a234-e7788e4aef95
client-request-id             : 0306e5a2-ac3b-41b7-b2b9-9a3cdcbec662
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:57 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP017: leonardo.moreira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:58
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : e52e79f6-d663-475a-9f3d-62e963b50b60
client-request-id             : 824d8157-450e-4e43-b786-b8583a272dbb
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:58 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP018: aline.teixeira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:19:59
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : f0b8da48-2978-4a5c-9699-cd5882eb7379
client-request-id             : 644bfe2e-324d-4609-9f81-0a516a5cfdfb
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:58 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP019: diego.pinto@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:00
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 8c3a333e-cfcb-4f2a-bd6c-d3e4c3654b34
client-request-id             : 17b147b5-f631-4ec3-aa12-cad1872997ae
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:59 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP020: marcos.goncalves@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:00
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 3dc7c523-4545-45b4-9fc2-500b27f7019d
client-request-id             : a7014e91-ed44-4808-9484-c613b453e82f
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:19:59 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP021: beatriz.ramos@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:00
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 30b55f99-7488-4117-8db6-eed508b6dc8e
client-request-id             : c6e22910-9774-4c63-9bb6-259e404518df
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:00 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP022: jonathan.lopes@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:01
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 3481f832-d14c-4512-8ccc-d8207d706a29
client-request-id             : aa19ebe0-3870-4b90-81e8-e7dcde48230c
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:00 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP023: viviane.machado@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:01
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 5d76dc07-0510-4f75-a2c9-3dcc94e7db98
client-request-id             : 024d9f1d-859e-4313-894e-202c301e9ffd
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:00 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP024: gustavo.castro@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:01
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : b073fb36-61a2-42b7-b25a-a175d863ec50
client-request-id             : c70a1984-1380-4ec1-8820-e688282606bd
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:01 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP025: larissa.campos@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:01
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 63b02651-e051-472e-8876-28e04f1b98e8
client-request-id             : fa6e9d9f-2cd1-4852-a2d5-174bb0a1fe5b
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:01 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP026: ricardo.moraes@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:02
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 6e6a74a7-ac10-445c-87aa-ed5bfef898b1
client-request-id             : 8cf407b5-bf58-4b8c-a817-3522b1b23859
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:01 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP027: jessica.cardoso@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:02
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 17d111a4-b0a0-49a0-bb3d-ee1e5294a5e2
client-request-id             : 5a4d6d40-1d8e-415c-bcea-79f157ca1275
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:02 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP028: carlos.rezende@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:02
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 34e081c4-c5d1-41c6-94dc-2d8551e824fe
client-request-id             : eda60bdd-6755-4872-86db-81f9e37d0722
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:02 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP029: amanda.freitas@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:03
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 20452e34-9571-4035-bf74-617d0a84d5a2
client-request-id             : 2f7550c8-575d-4f81-9b70-7ab98f28d75b
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:02 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP030: thiago.pereira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:03
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : c4519ab4-eea0-48a8-a395-172bb9dd0822
client-request-id             : 5ba0b576-73ba-45e8-9257-9920b42a9418
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:03 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP031: marcelo.tavares@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:04
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 46b1e772-548c-4533-904e-29a6b72c3d47
client-request-id             : b271ec8a-3205-4464-9888-03a7755d43f7
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:03 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP032: daniela.rocha@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:04
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : e33926a9-e582-4e33-aaf6-49d2cb72ca92
client-request-id             : eef28e44-da9e-41b8-a603-2539435b7e74
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:03 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP033: rogerio.neves@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:04
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 2560b3b8-529b-4f7c-8c33-34b4270bf34f
client-request-id             : 92d781d8-871c-47ae-96b6-e8eacaed7eb4
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:04 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP034: vanessa.dias@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:05
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 9f6b8810-8d07-45fb-a4d3-542aa1c409f7
client-request-id             : 92a89c1d-2195-4070-8cad-f0414ae466b2
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:04 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP035: murilo.barros@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:05
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 1d63b189-861f-49bf-bd40-b79939a1c411
client-request-id             : 1b03ffa6-83dd-4efd-bec9-f00d7d56f598
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:04 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP036: daniel.coelho@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:06
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 9d75fb8c-3e4d-41ee-810a-3fa6e3eb335a
client-request-id             : d26c4576-138d-4bb3-91bc-79871a8bd2b9
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:05 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP037: helena.ferreira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:06
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 334b0e62-adbb-4517-852a-6f92ac853ec9
client-request-id             : b92fa777-8b73-48fb-826f-055d3f268db3
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:05 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP038: carla.araujo@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:06
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 6280b7e1-cebd-44a0-85e8-8fab06338e01
client-request-id             : 57ce4eb3-3fa6-4eb6-8575-1e099de2970d
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:06 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP039: rodrigo.monteiro@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:07
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : dff72113-d389-4da7-aa45-4f718b88c7e2
client-request-id             : e8b2184b-d1bd-4a7a-8465-06275c017ae0
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:06 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP040: priscila.duarte@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:07
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 8705b2e5-f7f1-4117-9ae3-9ff0a82684c6
client-request-id             : 7681f855-5712-4d63-aa98-d267812aafeb
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:06 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP041: sergio.amaral@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:07
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : b28c2818-84e4-4a1e-b0b5-3cb345b13971
client-request-id             : fecf2bd5-5f1c-41c8-acce-1871c2630356
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:07 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP042: leticia.marques@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:08
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 1ccfbcc1-fda6-46dc-be4c-7972b5715a73
client-request-id             : 5ffe0b77-a374-4ade-8177-d09feee7d16c
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:07 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP043: joao.meireles@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:08
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : f1ef80a6-f9af-4cb9-8521-071e25522e3b
client-request-id             : ab9e2b25-e5b9-4c79-b53e-f0e5ce6d0c16
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:08 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP044: livia.sales@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:09
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 3640e585-6f8a-44d4-918e-ae790ad58f6f
client-request-id             : 2a93a57f-521c-440a-92e9-48230554aeb1
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:08 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP045: henrique.falcao@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:09
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : d339c347-1684-4f23-aa4f-1b691f90d538
client-request-id             : 4e26586d-57fa-495a-ba5f-f419c4d6a84c
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:08 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP046: debora.menezes@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:09
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : c020b161-02bf-40a4-8bcf-9196ea107f4e
client-request-id             : ec386283-3d6a-4e03-b84f-510ebd8df48a
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:09 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP047: rafaela.viana@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:10
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 2d762d0c-a7a7-435b-ba2d-5fcb1d48893a
client-request-id             : 4c4c8a49-0f72-4a69-aa10-999f0d13a3fc
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:09 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP048: pedro.queiroz@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:10
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 2c0697b4-33e4-4248-87eb-200e677e9453
client-request-id             : 456431f5-ff6b-4340-b533-1926a6d9693b
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:10 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP049: ana.paula@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:11
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 3ca41533-ae2f-4a68-bfd3-42b28775af94
client-request-id             : 3c21f731-ebd1-4c5c-9537-6098f67734b2
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:10 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP050: carlos.eduardo@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:11
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 28fd4a50-88b4-4d2e-a209-921708344433
client-request-id             : f4914fb4-5b7b-4e0f-85e4-94f63734611e
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:10 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP051: gabriela.cruz@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:11
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 76133e14-7307-4930-a325-7bb4dab14b33
client-request-id             : 732d065e-c54d-44d3-8580-0fdc056bd142
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:11 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP052: luciana.ferraz@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:12
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : c3a410ed-4509-458d-a570-ef1472afa6e6
client-request-id             : 4fa322cf-f891-415c-9ade-9117c8b9853c
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:11 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP053: renato.silveira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:12
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 79219adc-450a-4686-99a0-4837e6188926
client-request-id             : aa95413f-be98-4083-beb0-0522c5a45481
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:11 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP054: paulo.henrique@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:12
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 0a67d1d2-6208-49a8-b1e6-1d52236f1ed5
client-request-id             : 3b024caf-1006-4b6a-bfcf-8485b357cf2e
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:12 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP055: michele.carneiro@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:13
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : f66e9caf-feee-4cba-9c38-a7cc4e852ade
client-request-id             : 31161017-1230-4ac0-87e7-d0ff3b36fee7
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:12 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP056: tatiana.castilho@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:13
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : e3ccef71-e034-431a-bb1a-902fcf5f996d
client-request-id             : fb577315-9b99-4214-bdf9-e21d632200e2
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:12 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP057: vinicius.fonseca@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:13
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 3f6689c8-0427-432a-a16c-0de2d11ef93f
client-request-id             : d2b4caca-9fd9-444e-804d-e182b4f0da02
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:13 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP058: sabrina.mota@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:14
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 75f4b939-2858-49c6-8698-af39d47f8aa4
client-request-id             : 9cb6b6df-678a-49e7-8494-91a5332bfa04
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:13 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP059: natalia.lacerda@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:14
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : b74ec5a6-f2ea-4187-a9e1-b26de9561089
client-request-id             : b3119f77-909f-44a1-a93a-244b8f9bdb64
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:14 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP060: anderson.peixoto@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:15
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : bcce2dcd-f79a-459c-b6a6-ce8018734877
client-request-id             : dfc6d877-b9f6-4d25-aa91-8180e1566c4c
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:14 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP061: caroline.mendes@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:15
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 4f7100a0-7644-4912-88a2-1cb99e4f4f52
client-request-id             : 37d7817e-4b75-4a56-83b5-79048eace828
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:14 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP062: joana.batista@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:16
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : e169325d-7c9e-4cc4-aa7a-86a62e8487f0
client-request-id             : 2db50ab9-35e1-4af9-b380-8249c0c3083e
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:15 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP063: samuel.rocha@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:16
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 68f53b36-2044-49a5-9574-9cbc501ce2a1
client-request-id             : 9ff86335-3962-43e6-8a7c-e698887cf483
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:16 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP064: roberta.vidal@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:17
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 2c986599-4bea-49da-8b24-83c609e5b596
client-request-id             : f32a8a81-b527-40a2-a118-c31c40b559cd
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:16 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP065: igor.americo@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:17
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 47e43ccf-3882-45aa-8597-c1d8781d52ee
client-request-id             : 8da4a265-0d32-4cbe-aa3e-1b0b72d1b083
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:16 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP066: danilo.assis@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:17
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : dd19063d-e3fa-430d-bf13-a632f38dddfc
client-request-id             : 92d2f0cc-7b85-46ee-819e-5be489545646
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:17 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP067: fabio.correia@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:18
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 6a13884c-c9db-4524-8b56-77c2161a54b8
client-request-id             : fb769d60-13eb-4db6-831f-6c590b4a5bf4
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:17 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP068: karla.vasconcelos@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:18
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : f013e80e-df55-46c1-8594-231d37e30902
client-request-id             : 9e3277c6-cc9a-4d56-9e44-741d9b20888e
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:18 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP069: eduarda.brandao@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:19
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : aab05647-874e-470b-ad22-790f21b4beff
client-request-id             : 7b473410-0129-4b12-9679-ef1e2127f04c
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:18 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP070: cassio.borges@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:19
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 81780e97-1bdb-459e-925b-98d4ebde1f7a
client-request-id             : 9b5370e7-0464-4658-8ec7-9dba7831b596
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:19 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP071: patricia.macedo@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:20
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : b97996e3-08e2-438c-acd8-20e13a2296df
client-request-id             : e93b02d0-aa40-4bce-abc7-1ca1f0ddc1e1
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:19 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP072: felipe.lourenco@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:20
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : f9f88dd8-99b7-46d5-ba6d-75f9d7c9e3b0
client-request-id             : 48b0349f-a768-41cd-803d-91a2aebd9f2d
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:19 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP073: amanda.prado@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:20
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : ac553e7c-6feb-4d84-83c9-27f7623fa288
client-request-id             : 00396c2b-6c49-4b22-a406-cd500b4986f5
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:20 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP074: gustavo.franco@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:21
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : a137b8d7-d095-459d-8c59-cab775e414c7
client-request-id             : 76577dfd-1f12-4de2-aab3-87c0cee99c10
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:20 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP075: carla.ribeiro@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:21
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 5d51b055-c0d5-4b16-bba4-4b03e997c496
client-request-id             : ccd7f6c4-781a-44be-9bf1-758e86dfc4da
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:21 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP076: leandro.rezende@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:22
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 9f365169-3bb9-480f-b373-9a3acc4f33c9
client-request-id             : 4e55225d-ae33-4de9-84d9-b32d21290ae5
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:21 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP077: sofia.bueno@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:22
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 1e63f3d6-4508-4f39-9bb2-743bc4f21bc5
client-request-id             : 687f911e-9f04-4470-ad2d-f8213143cbcd
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:21 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP078: arthur.henrique@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:22
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 98b3d4a4-ff29-432c-b3c2-46b3e919718e
client-request-id             : af89b50d-0730-4600-b5af-28d70ec378d8
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:22 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP079: beatriz.moreira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:23
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : cf8804c1-669a-4daf-9174-81b34ded473d
client-request-id             : 8c1fb081-942f-4d86-bae4-fe96d81402c3
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:22 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP080: lucas.toscano@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:23
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : bbd361de-2f50-4b34-8bed-0277d45e980e
client-request-id             : 333f1e0c-84f1-4762-9082-3e0deda48b30
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:22 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP081: emanuel.nogueira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:23
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 776aa1fe-f06c-465a-864d-a4cab8a71936
client-request-id             : 72fa57a9-fcd6-49ca-8c73-d5b9b7ae871f
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:23 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP082: cristina.alvarenga@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:24
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 59870219-ccae-420c-90f3-751774f61fab
client-request-id             : 9cdfdfd3-cf99-4981-952c-1f085debcd3c
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:23 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP083: raul.andrade@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:24
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 67377dad-48b3-43c0-be8c-208465165173
client-request-id             : 20fa50fb-02c7-42ed-b49b-8eed11ea78a5
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:24 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP084: mariana.quevedo@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:25
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 6daada55-11e1-4919-bc7b-ca81a62fb18d
client-request-id             : c19a2089-41e7-4467-9271-f3ff1468a883
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:24 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP085: thiago.pazinato@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:25
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : e57efdf8-d4cc-4fbe-8ef1-baa89eb2c528
client-request-id             : 7f2f58c4-b12f-434e-8feb-26805e0cb098
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:24 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP086: andreia.abreu@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:25
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 0f8e3a5e-584f-4369-8788-342d5c8ff110
client-request-id             : 532236a2-fd17-442e-9d65-3f0550a36b2b
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:25 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP087: murilo.vasques@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:26
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : e776c001-a945-4021-a35e-061b096a4bab
client-request-id             : 992b36ea-332d-4eed-a897-69d123750884
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:25 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP088: helena.santiago@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:26
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : d1afcbbb-717a-4eb4-8d56-6f65127b05c3
client-request-id             : e88f424f-8308-4a26-8634-7fe33c3a037c
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:25 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP089: julio.oliveira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:27
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 29feac7b-2434-47fe-83a9-d5c588762547
client-request-id             : b02094ae-658d-4006-b780-7fe76c8112c0
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:26 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP090: tatiana.pozzebon@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:27
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 88624ed0-df9b-4e00-91fd-ef8dd22b93a9
client-request-id             : 54af68a3-cfe3-4b3f-9b84-f25bdd6a53e9
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:26 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP091: rodrigo.mendes@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:27
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 65e80696-12ef-4eb5-b094-895f4f611b73
client-request-id             : 30f253a5-a06e-4b8a-9369-c291a51d91b5
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:27 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP092: camila.freire@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:28
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 9a72c986-1d3c-430e-8253-9411041565b1
client-request-id             : 5e4f6426-7384-4ac5-8e70-cad74a3c9838
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:27 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP093: paula.bernardes@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:28
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : a81055e6-c431-4619-a9a9-2b1195ef8756
client-request-id             : c23509fe-ccf8-4229-a7e9-28bf95a4ab18
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:27 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP094: marcos.teixeira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:29
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : ecd9c6dc-16fc-42f9-9247-d237ac91a59d
client-request-id             : f85820e9-0cac-4413-8433-20c711ea80fa
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:28 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP095: rawfaela.costa@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:29
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 1549cebc-4012-4115-b284-f54e031a2676
client-request-id             : f45cec32-2d3d-48ad-b9ac-5a9aeab14c86
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:28 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP096: guilherme.lira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:30
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : cac0b274-8b28-42c1-815e-1d1c5937ea3d
client-request-id             : 33bbcbca-ba25-4cda-b2c7-b5072e5c0e02
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:29 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP097: elaine.cardin@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:30
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 748d8a0a-f953-4e0a-bd1a-e93136cc29aa
client-request-id             : 9f0f7ca7-d589-4146-8935-66d5b173f7b3
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:29 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP098: ricardo.ferraz@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:30
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 9e73b416-3e4d-40f1-a4e5-1f456fa95784
client-request-id             : 35344fe4-d5c8-4017-92e5-863bb351d2e5
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:29 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP099: taina.lopes@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:20:30
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 2b781906-0b2b-43b5-af12-2ce195dbfd38
client-request-id             : 6f2945f7-62cd-4ad5-8a78-47bdfabc353b
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078DA"}}
Date                          : Sun, 01 Mar 2026 21:20:30 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:30 caractere:9
+         New-MgUser @UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_CreateExpanded], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_CreateExpanded
[SUCCESS] FP100: fernanda.rossetti@fiqueok.com.br
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts> (Get-MgUser -All | Where-Object { $_.EmployeeId -like "FP*" }).Count
Get-MgUser : Expected comma, literal, or object. Was Eof: .
No linha:1 caractere:1
+ (Get-MgUser -All | Where-Object { $_.EmployeeId -like "FP*" }).Count
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Get-MgUser_List], ParserException
    + FullyQualifiedErrorId : Microsoft.Graph.PowerShell.Cmdlets.GetMgUser_List

0
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts> Get-MgUser -Filter "DisplayName eq 'David Velez'" -Property "Id,DisplayName,EmployeeId,Department" | Select-Object DisplayName, EmployeeId, Department
Get-MgUser : The query specified in the URI is not valid. The requested resource is not a collection. Query options $filter, $orderby, $count, $skip, and $top can be
applied only on collections.
Status: 400 (BadRequest)
ErrorCode:
Date: 2026-03-01T21:23:00
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : b45ee2fc-1b15-468c-885e-3e9930b6f748
client-request-id             : 20a86b11-f10f-43ee-be9d-15a531ffb96e
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"001","RoleInstance":"CP1PEPF000078D1"}}
Date                          : Sun, 01 Mar 2026 21:22:59 GMT
No linha:1 caractere:1
+ Get-MgUser -Filter "DisplayName eq 'David Velez'" -Property "Id,Displ ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ ConsistencyLe... , Headers =  }:<>f__AnonymousType48`9) [Get-MgUser_List], Exception
    + FullyQualifiedErrorId : Microsoft.Graph.PowerShell.Cmdlets.GetMgUser_List
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts> Get-MgUser -UserId "david.velez@fiqueok.com.br" -Property "DisplayName,EmployeeId,Department,JobTitle" | Select-Object DisplayName, EmployeeId, Department, JobTitle

DisplayName EmployeeId Department JobTitle
----------- ---------- ---------- --------
Paulo Lima


PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts> cd "C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts"
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts> powershell.exe -ExecutionPolicy Bypass -File ".\Provisioning_Script.ps1"
Welcome to Microsoft Graph!

Connected via delegated access using 14d82eec-204b-4c2f-b7e8-296a70dab67e
Readme: https://aka.ms/graph/sdk/powershell
SDK Docs: https://aka.ms/graph/sdk/powershell/docs
API Docs: https://aka.ms/graph/docs

NOTE: You can use the -NoWelcome parameter to suppress this message.

New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:36
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 87c86e3b-0ba7-4b40-b990-8765e607a4f9
client-request-id             : 7b113560-90c6-479b-aa24-e1aba27662f9
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:36 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP001: david.velez@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:37
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 14711ef2-fba4-4e33-9cd5-1ebc4d1b819b
client-request-id             : 0ef618bc-16a7-47f6-8e3b-69df76c86ad5
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:36 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP002: andre.chaves@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:37
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : b90c825e-c0a0-41f8-b56a-7d8c05126876
client-request-id             : 530549db-4ac1-4dee-bb1a-efd8c5aad4a7
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:36 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP003: luisa.sotero@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:37
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 5f47cd3b-88a4-4836-97c8-b75e920dae40
client-request-id             : 26e00e5a-e462-4afd-8867-d6717fed5968
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:37 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP004: daniela.binatti@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:37
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 49e5f6cd-3bab-44e1-8031-05f612f4eaf5
client-request-id             : 47b77641-7ed1-4341-8f89-fac8862b716e
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:37 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP005: ricardo.guerra@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:38
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : b07fbd1b-22d8-4232-9e5f-7b57ed0c2f06
client-request-id             : 7b984deb-e700-47da-8586-a70ebcb6e2cf
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:37 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP006: laszlo.bock@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:38
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : e6130ca0-89d2-451f-95dd-761b2b619197
client-request-id             : e4e0c859-27dd-431d-863c-eae5f6e302a0
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:37 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP007: donner.marcos@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:38
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 845a5183-5496-450c-8641-d68559255142
client-request-id             : 2a0fd59e-919f-40c3-9948-109af446081a
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:38 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP008: lucas.carvalho@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:38
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : d02491c5-947b-429c-babb-885da9db8563
client-request-id             : 629d7e18-104c-4074-b434-953875fdee4f
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:38 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP009: juliana.lima@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:39
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : bb47de81-93d4-4c33-a4b2-5e5f6ee0f155
client-request-id             : 1e9552bb-4e02-41f2-a243-2ab3c2b375b8
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:38 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP010: gabriel.martins@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:39
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 93f93278-8948-4044-b2df-c9954d93f150
client-request-id             : 2221e1bf-7ae1-4e74-bc3e-643be784bbcc
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:38 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP011: patricia.silva@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:39
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : cd350fca-1828-4102-bbb9-1fa8d7a84c11
client-request-id             : 837da107-c37a-4859-8157-2f43b15b8677
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:39 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP012: felipe.barbosa@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:39
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 18554b31-fce2-4ca1-b89b-7862dfc86f2b
client-request-id             : 412ebc45-fe78-48c3-8cd6-2e1c7ba8befd
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:39 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP013: renata.azevedo@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:41
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 40eebc8f-a673-4338-9794-6826b16281fe
client-request-id             : 1d090b8a-fef1-48a3-a767-ed88f73fbbeb
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:40 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP014: andre.costa@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:41
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 1a2c0858-fa6f-4561-abb7-51c0e4da74d8
client-request-id             : e89d3306-d6c4-45a4-b0ad-b452828e2de8
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:41 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP015: tatiane.nunes@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:42
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 64dc2125-1aae-4478-9b95-a04171874721
client-request-id             : 6cd264e0-a679-416f-9e8e-db82792e746a
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:41 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP016: eduardo.ribeiro@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:42
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : b750fe44-1e0b-40aa-b8b1-213eea2eca77
client-request-id             : 1c350f69-961c-499b-9d77-2f4382637033
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:41 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP017: leonardo.moreira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:42
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : cf02060b-9cd4-4345-8221-cfa22b77d2ca
client-request-id             : 4f7b263e-ed7b-40cd-a6a2-75b70b9be841
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:41 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP018: aline.teixeira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:43
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 6d4c09b4-56ad-4251-8f02-05119fa09814
client-request-id             : d5079304-0397-4896-a1a7-f413ab026e99
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:42 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP019: diego.pinto@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:43
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : cb8c775d-19b1-4106-b800-1657320226a0
client-request-id             : da5f2108-3132-4777-b470-7de18c0f581a
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:42 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP020: marcos.goncalves@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:43
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : d198f3d1-9e85-44a8-94b0-dd22f1380936
client-request-id             : bebb69c5-23e5-419d-bca0-31dbc2891545
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:43 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP021: beatriz.ramos@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:44
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 092f22e9-0dbb-4f0f-8f6b-f9dc097fc063
client-request-id             : 59198069-7f02-4165-9caf-e1fb99d94cf6
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:43 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP022: jonathan.lopes@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:44
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 1583ea4f-bb63-4b54-8b5d-e67aeeb42c53
client-request-id             : 21cc3f51-52ca-4788-a7dd-7ae76dbff162
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:43 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP023: viviane.machado@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:44
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : ea2eee44-d2c0-47ca-ab67-bbb328de165b
client-request-id             : c6322fd5-1982-4c7e-a86d-fbe5670bb146
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:44 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP024: gustavo.castro@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:44
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : bae4073b-94b6-4359-a1b0-a258851bb2da
client-request-id             : b59d23c7-a190-4b11-8804-53374137e196
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:44 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP025: larissa.campos@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:45
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 55095941-d415-439b-a101-2498dc2eae7b
client-request-id             : d1b929a6-ec5f-469d-9568-209029213214
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:44 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP026: ricardo.moraes@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:45
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 13f386dd-9179-48b9-899f-a48dc74b3bf3
client-request-id             : cb5f1182-490d-400b-b5ad-ac7d1bb23f9e
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:44 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP027: jessica.cardoso@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:45
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 446a463b-f2db-44c0-8339-1d29fda76ffb
client-request-id             : 214ba30a-71b6-4097-8614-35d58ecd1568
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:44 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP028: carlos.rezende@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:45
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 01334c1e-5d54-4ce7-b032-697815d390c8
client-request-id             : 6e9dd337-da02-441d-926e-3047cff5e62a
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:45 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP029: amanda.freitas@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:46
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 7c671045-526c-4599-b3af-4b419aa9bc24
client-request-id             : 96170779-00be-44f9-a34b-21e280e1dab7
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:45 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP030: thiago.pereira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:46
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 9fa11f9e-c979-4515-8390-635803759530
client-request-id             : a2d0f7f7-d29d-4455-abc1-dc8ab527112c
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:45 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP031: marcelo.tavares@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:46
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 731687cd-3528-4de8-9510-e596d1b3e95a
client-request-id             : e35e0696-a85c-4cd2-9fc8-7eee6548a733
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:45 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP032: daniela.rocha@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:46
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 99d5522a-f32c-413e-bf2e-43ae5cf11f37
client-request-id             : 1e8139d3-8e8d-4a7b-8e9d-e5405492a91e
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:46 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP033: rogerio.neves@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:47
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 8dac93ca-2415-44a2-a058-5c2572b52f51
client-request-id             : c507c6b8-130b-4778-88c6-bad86e1e9b8a
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:46 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP034: vanessa.dias@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:47
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 7990aa46-0924-4d39-94e8-3dcaa3572a67
client-request-id             : 7cdca897-6c8c-4488-b0b8-60d983c17148
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:46 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP035: murilo.barros@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:47
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 37cb3039-2c81-4155-a100-2b1d7cad23e2
client-request-id             : 87714a7d-e12a-4255-bdf7-23ee0cc06e10
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:46 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP036: daniel.coelho@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:47
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : a699cb3c-6b26-4519-8866-941de7100a77
client-request-id             : a0b87e9e-8dd1-4197-8671-743b238f76db
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:47 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP037: helena.ferreira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:48
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : fb87829e-a33c-4be2-acf9-a1709ae84a24
client-request-id             : 64404787-554d-49a2-9f57-10911f031b71
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:47 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP038: carla.araujo@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:48
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : f5557348-ece2-46e0-b8bb-b4f2a07ee2d7
client-request-id             : 963829b3-a88f-4059-98eb-3532fa81f3bc
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:47 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP039: rodrigo.monteiro@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:48
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : c0e3eca6-0829-4dbd-8422-edaf9fccec7d
client-request-id             : cc0bdc4f-47df-4121-bc55-34d110e6d338
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:47 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP040: priscila.duarte@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:48
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 304c13b1-38ca-4409-869d-e1757fb20362
client-request-id             : 40048138-b69d-43d4-a7d5-b1201517f918
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:48 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP041: sergio.amaral@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:49
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 8b0413b5-58ae-4ee3-9154-99ddbb812b91
client-request-id             : 791e5c89-f318-4888-8f9f-52cd38a4e649
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:48 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP042: leticia.marques@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:49
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : e67f2e94-15f8-40cd-9d51-4cc399dc168d
client-request-id             : d59e426e-cb1e-48ea-99d1-b3201212b2e9
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:48 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP043: joao.meireles@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:49
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : c9a1901b-dc6e-4ea8-8fbf-5ada35a8c6ba
client-request-id             : 8bb8016f-4949-49b6-b3be-75b0f6e4adc0
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:49 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP044: livia.sales@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:49
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : d636feab-2d65-41b8-9834-e95edb230e09
client-request-id             : 011c59e9-cc66-49ec-8319-87da6fad3b6d
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:49 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP045: henrique.falcao@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:50
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 1e2d5e26-d261-44a7-8c66-a40b3d7908ec
client-request-id             : 831a4a21-ee03-4493-83fb-94a39f26ad8e
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:49 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP046: debora.menezes@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:50
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : c9c82311-25a2-4706-a644-c666113f029f
client-request-id             : adc23a9a-4e4e-4457-9746-00b00dbb81c0
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:49 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP047: rafaela.viana@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:50
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : b71a3105-18ec-499f-ac48-bd945213920f
client-request-id             : e9d352bf-4ce1-48d5-b656-80ef102ef0ee
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:50 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP048: pedro.queiroz@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:50
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 2b914189-499a-4f81-932a-aa70536cb433
client-request-id             : f039bf50-2ea6-4e01-9f48-bdafc57f1d0a
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:50 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP049: ana.paula@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:51
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : fb05e201-0228-4a78-acc7-cb3b26815b7d
client-request-id             : b5fb96a6-9fc1-48a5-ac74-7ddbb57bda1b
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:50 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP050: carlos.eduardo@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:51
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 6458fae8-dad4-4c09-8a47-b0677e3b1d99
client-request-id             : 74c11885-03c4-40f6-86a4-f56da092a54d
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:50 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP051: gabriela.cruz@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:51
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : ac2a7be3-1401-478f-8c69-11b84814e332
client-request-id             : 2d1aef11-2c7a-48a2-a7af-da1020b7a651
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:51 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP052: luciana.ferraz@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:51
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 821f66ff-5c9a-47ab-808c-8e525a7d6a0b
client-request-id             : 2684c9a5-fccc-47c1-aecd-bcd385f15e8d
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:51 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP053: renato.silveira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:52
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : efdff508-9e4b-431f-b38e-34a7f4123a30
client-request-id             : 83dbabeb-ad83-4488-88cd-008e451508ea
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:51 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP054: paulo.henrique@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:52
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : fef080d7-3cc5-422c-9833-708a98d88c0a
client-request-id             : c8ca6695-ca13-4170-a9ff-2d484b715c94
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:51 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP055: michele.carneiro@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:52
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 8c44f973-46a4-4985-ba17-4b7d18f542f1
client-request-id             : 9941f529-d68b-4b71-a39d-3e80bfc337f8
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:52 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP056: tatiana.castilho@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:52
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 48adde52-e390-4af4-857a-f8978bd3b94c
client-request-id             : 3d994689-24f6-4060-a48a-50c0d435e546
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:52 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP057: vinicius.fonseca@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:53
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : bd4ee0f8-4408-43c2-bd50-0ec9080085d2
client-request-id             : d2b367c9-6c50-43d4-b2af-1ac4eb0b21e8
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:52 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP058: sabrina.mota@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:53
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 17e12e09-11b1-4efe-b33a-d47ee1aa74a3
client-request-id             : 31961e91-c072-4a91-b589-035485dabca9
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:52 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP059: natalia.lacerda@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:53
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 7a92fcc1-b2b6-41b7-b413-9a3d40fcdf19
client-request-id             : e2ef9eb0-6180-47f3-97a4-6cb3bf3b3827
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:52 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP060: anderson.peixoto@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:53
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : a0240eb5-0cae-4373-8ebb-843e8454715f
client-request-id             : 35d14eb2-481b-40de-81b9-0ab8db1beaf2
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:53 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP061: caroline.mendes@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:54
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : c5f7d079-3964-46aa-a399-82adee9df7ac
client-request-id             : a16b9b2a-3091-4cfd-ba2f-1027c4a018ea
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:53 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP062: joana.batista@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:54
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 9edd09dc-a25d-4f94-bb26-18d2ff863b95
client-request-id             : ba4ea33c-71b0-461d-8359-71aa804f93fe
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:53 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP063: samuel.rocha@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:54
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 36cceb57-b71e-4ef1-83c1-86e0629ee663
client-request-id             : ddc049a4-355c-45c1-b2ed-9733bafef100
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:53 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP064: roberta.vidal@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:54
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 81770750-7b05-4cc0-a6ba-c33cdd30fbb1
client-request-id             : 464e9c15-1351-4266-b378-e01b4304a69c
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:54 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP065: igor.americo@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:55
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : d548f429-cbdf-46fb-b55c-74ddd01583b2
client-request-id             : c59214e7-e881-4a99-9cd6-da3817f20be2
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:54 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP066: danilo.assis@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:55
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 2342fa6f-5794-4b5a-a38f-ea190f5ad8f8
client-request-id             : 86968f53-e645-4166-a294-94eedf4ed323
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:54 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP067: fabio.correia@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:55
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 99faa884-a0c8-47a0-9dc2-1e116465970b
client-request-id             : b974743b-3703-4d15-9fb9-710e463fdd99
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:54 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP068: karla.vasconcelos@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:55
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 1f491445-df84-4881-96d4-03f9839d9f04
client-request-id             : da7211a4-4310-4a87-89f8-0fee80a94185
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:55 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP069: eduarda.brandao@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:56
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 3a49dfe9-0f14-4f3a-88ce-ecef5d317af7
client-request-id             : c1a0c2d9-76f6-43d4-8f08-30cf6ce1752d
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:55 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP070: cassio.borges@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:56
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : fc0d7613-dcd1-4a0f-a05d-db700d3804ce
client-request-id             : 70c1a28f-5be9-47e1-8337-a27cd806bba3
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:55 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP071: patricia.macedo@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:56
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : b4a779dd-2dfb-4a02-9dd2-01960ecadc82
client-request-id             : 47fcdec3-1e76-43cf-9cc8-b0bcb8f4ba73
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:56 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP072: felipe.lourenco@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:57
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : d6e95b0a-d39e-45d5-b719-f4a5558ec154
client-request-id             : 05c00f98-5407-47c2-8996-6ec6e477ee3c
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:56 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP073: amanda.prado@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:57
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : f7349ca4-7f4c-4862-bd45-f3fc933e5520
client-request-id             : f38bb579-4780-4d37-b2af-b943e2688d99
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:56 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP074: gustavo.franco@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:57
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 78970ea1-93fb-4f53-83bd-971f78e59e5b
client-request-id             : 0c7f33be-0721-43d2-bda4-becc6732572d
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:56 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP075: carla.ribeiro@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:57
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : f02a4a1c-70ac-4ec1-a76d-4c5852890a48
client-request-id             : 3bbbefa9-6f41-4a44-be2d-e3928e4011d2
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:57 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP076: leandro.rezende@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:58
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 46d48695-8d24-4d90-a0b3-3cc4212b3116
client-request-id             : 8fc56614-f765-42a1-a620-8f87e6447049
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:57 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP077: sofia.bueno@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:58
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 1f98595f-1a2a-4242-a405-f2e2f4de79a9
client-request-id             : 3fcdca84-59ac-4d7e-8e19-4594a1341918
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:57 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP078: arthur.henrique@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:58
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : a73a1fb1-e970-4c51-afd2-ac53a1a4fdc4
client-request-id             : c523002a-e683-4996-84a4-c26fc4e78b14
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:57 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP079: beatriz.moreira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:58
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : d7fb6a21-8054-4ea9-8072-25fdf4b8b3be
client-request-id             : f4e44dcb-f44a-4a24-b1d1-eb463e1e287a
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:58 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP080: lucas.toscano@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:59
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : b3e41559-8d36-43f1-87c8-8cf4af2e32c9
client-request-id             : 043b39eb-02e4-411d-932f-e7408e1b9924
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:58 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP081: emanuel.nogueira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:59
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : c37be9b8-d028-49c5-aa94-673d91b17fd5
client-request-id             : addf27c2-5e2a-4e90-9ab5-fa7f2e4364ba
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:58 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP082: cristina.alvarenga@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:59
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 5669f730-a21d-4282-9717-ae1dd4afa685
client-request-id             : 7e8c62cc-787a-4135-ba9c-acae48775989
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:58 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP083: raul.andrade@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:26:59
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 63aba61b-d180-468c-8b1c-dc97d615b0ea
client-request-id             : 6a2003a4-9a7b-4c96-a6e5-1a2ca08cbbf9
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:59 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP084: mariana.quevedo@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:27:00
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : d53af94d-3358-4da0-bc72-bc9d22e3f107
client-request-id             : 02e306d7-f000-4f83-a419-21010b315c45
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:59 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP085: thiago.pazinato@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:27:00
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 7d0445b3-578f-44e3-a1e5-81279264a7ca
client-request-id             : 7c383974-dd94-4c24-b5b5-f58d29a4a292
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:59 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP086: andreia.abreu@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:27:00
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 0f9da5a1-b789-4bef-88c3-0e506604c4d9
client-request-id             : b8ea9541-a5c2-4296-99e9-80e2c85fec25
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:26:59 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP087: murilo.vasques@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:27:00
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : a142fa96-bc12-4a38-9b39-4432ea1236eb
client-request-id             : 79e5ab9a-eb99-4435-ac27-f4ff4cdffef9
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:27:00 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP088: helena.santiago@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:27:01
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 58f4207a-cf76-438b-a119-7cc066c94c64
client-request-id             : 7ba26147-0254-41eb-8baf-6d21cdea9620
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:27:00 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP089: julio.oliveira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:27:01
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 9f960cc5-87c5-483c-aea5-39d19f018c44
client-request-id             : 0f548c2f-0f0b-4060-9a5e-d16787b4543e
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:27:00 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP090: tatiana.pozzebon@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:27:01
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 23ad3829-6fed-491b-a838-5343c3901293
client-request-id             : 9987a85d-4111-400e-9e70-a6d449c89c7b
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:27:00 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP091: rodrigo.mendes@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:27:01
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : a4d403f7-a658-4295-93af-36054fb4af40
client-request-id             : 3a19549b-0bac-4820-a4c1-50b0b1bc0faf
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:27:01 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP092: camila.freire@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:27:01
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 79b1b96c-d796-49a4-bd1f-406e54597754
client-request-id             : 202408a0-18f2-49f1-af41-51876a2a0a70
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:27:01 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP093: paula.bernardes@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:27:02
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 89e37801-b8ae-4896-a9c0-f9bc0758eac9
client-request-id             : 7aae2dfc-c9e3-4279-bace-204376939875
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:27:01 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP094: marcos.teixeira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:27:02
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 0c24f470-bf14-44b4-a4a5-c5cd5041be38
client-request-id             : e82e60de-1811-47f6-abac-e306c8fc4a86
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:27:01 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP095: rawfaela.costa@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:27:02
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : fe5cf729-3cb0-4972-b11a-4d1e3131282b
client-request-id             : 483777c9-4606-41ec-8849-f5ccdd71e4f8
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:27:02 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP096: guilherme.lira@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:27:02
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 32ac869e-2b5e-4ad0-a26e-2a2eef48a7de
client-request-id             : 43a3d3a7-26e3-49a8-9606-591ea53c9d75
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:27:02 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP097: elaine.cardin@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:27:03
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : aa3b91b0-2796-4349-a2ca-6494a78622a4
client-request-id             : bbcc4b1d-166e-4fdf-ba64-2da69693807c
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:27:02 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP098: ricardo.ferraz@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:27:03
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : 21f37765-5d0f-469e-af22-6f26f327c37c
client-request-id             : f2626efd-e7a7-4ecb-9c38-3347473da90e
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:27:02 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP099: taina.lopes@fiqueok.com.br
New-MgUser :
Status: 405 (MethodNotAllowed)
ErrorCode: UnknownError
Date: 2026-03-01T21:27:03
Headers:
Transfer-Encoding             : chunked
Vary                          : Accept-Encoding
Strict-Transport-Security     : max-age=31536000
request-id                    : bc5540c2-8460-40e7-b6f4-5aca3e9394b9
client-request-id             : 01199c08-84bd-4ef3-9ede-b6f2a99557f7
x-ms-ags-diagnostic           : {"ServerInfo":{"DataCenter":"Brazil South","Slice":"E","Ring":"3","ScaleUnit":"000","RoleInstance":"CP1PEPF000078CD"}}
Date                          : Sun, 01 Mar 2026 21:27:03 GMT
No C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts\Provisioning_Script.ps1:24 caractere:9
+         New-MgUser -BodyParameter $UserParams
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Headers = , b...softGraphUser }:<>f__AnonymousType53`2) [New-MgUser_Create], Exception
    + FullyQualifiedErrorId : UnknownError,Microsoft.Graph.PowerShell.Cmdlets.NewMgUser_Create
[SUCCESS] FP100: fernanda.rossetti@fiqueok.com.br
PS C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ011 - Export Orange - EntraID\Scripts>
