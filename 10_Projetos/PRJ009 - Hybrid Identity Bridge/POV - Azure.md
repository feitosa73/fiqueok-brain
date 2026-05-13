O Windows PowerShell
Copyright (C) Microsoft Corporation. Todos os direitos reservados.

Instale o PowerShell mais recente para obter novos recursos e aprimoramentos! https://aka.ms/PSWindows

PS C:\WINDOWS\system32> az login
Select the account you want to log in with. For more information on login with Azure CLI, see https://go.microsoft.com/fwlink/?linkid=2271136
User canceled the flow. Status: Response_Status.Status_UserCanceled, Error code: 0, Tag: 593773845
Run the command below to authenticate interactively; additional arguments may be added as needed:
az logout
az login
PS C:\WINDOWS\system32> az login
Select the account you want to log in with. For more information on login with Azure CLI, see https://go.microsoft.com/fwlink/?linkid=2271136
User cancelled the Accounts Control Operation.. Status: Response_Status.Status_UserCanceled, Error code: 0, Tag: 528315210
Run the command below to authenticate interactively; additional arguments may be added as needed:
az logout
az login
PS C:\WINDOWS\system32> az login --use-device-code
To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code BRWAC28K3 to authenticate.

Retrieving tenants and subscriptions for the selection...

[Tenant and subscription selection]

No     Subscription name     Subscription ID                       Tenant
-----  --------------------  ------------------------------------  -----------------
[1] *  Azure subscription 1  8c8a1deb-2cbc-4c51-a177-87b874d44923  Default Directory

The default is marked with an *; the default tenant is 'Default Directory' and subscription is 'Azure subscription 1' (8c8a1deb-2cbc-4c51-a177-87b874d44923).

Select a subscription and tenant (Type a number or Enter for no changes): https://microsoft.com/devicelogin
Invalid selection.
Select a subscription and tenant (Type a number or Enter for no changes):

Tenant: Default Directory
Subscription: Azure subscription 1 (8c8a1deb-2cbc-4c51-a177-87b874d44923)

[Announcements]
With the new Azure CLI login experience, you can select the subscription you want to use more easily. Learn more about it and its configuration at https://go.microsoft.com/fwlink/?linkid=2271236

If you encounter any problem, please open an issue at https://aka.ms/azclibug

[Warning] The login output has been updated. Please be aware that it no longer displays the full list of available subscriptions by default.

PS C:\WINDOWS\system32> az account show --output json
{
  "environmentName": "AzureCloud",
  "homeTenantId": "503bbd0e-f33f-4ebe-b12e-f24a506978c9",
  "id": "8c8a1deb-2cbc-4c51-a177-87b874d44923",
  "isDefault": true,
  "managedByTenants": [],
  "name": "Azure subscription 1",
  "state": "Enabled",
  "tenantDefaultDomain": "paulofiqueokcom.onmicrosoft.com",
  "tenantDisplayName": "Default Directory",
  "tenantId": "503bbd0e-f33f-4ebe-b12e-f24a506978c9",
  "user": {
    "name": "paulo@fiqueok.com.br",
    "type": "user"
  }
}
PS C:\WINDOWS\system32> az group create --name "fiqueok-prj009-poc-rg" --location "brazilsouth" --tags "Projeto=PRJ009" "Ambiente=POC" "Responsavel=Paulo" "Empresa=Fiqueok"
{
  "id": "/subscriptions/8c8a1deb-2cbc-4c51-a177-87b874d44923/resourceGroups/fiqueok-prj009-poc-rg",
  "location": "brazilsouth",
  "managedBy": null,
  "name": "fiqueok-prj009-poc-rg",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": {
    "Ambiente": "POC",
    "Empresa": "Fiqueok",
    "Projeto": "PRJ009",
    "Responsavel": "Paulo"
  },
  "type": "Microsoft.Resources/resourceGroups"
}
PS C:\WINDOWS\system32> az group list --output table
Name                   Location     Status
---------------------  -----------  ---------
fiqueok-prj009-poc-rg  brazilsouth  Succeeded
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> # Definindo o nome do Vault (deve ter entre 3-24 caracteres, apenas letras e números)
PS C:\WINDOWS\system32> $VAULT_NAME="fiqueok-prj009-poc-kv"
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> az keyvault create `
>>   --name $VAULT_NAME `
>>   --resource-group "fiqueok-prj009-poc-rg" `
>>   --location "brazilsouth" `
>>   --enable-rbac-authorization true `
>>   --tags "Projeto=PRJ009" "Ambiente=POC"
(MissingSubscriptionRegistration) The subscription is not registered to use namespace 'Microsoft.KeyVault'. See https://aka.ms/rps-not-found for how to register subscriptions.
Code: MissingSubscriptionRegistration
Message: The subscription is not registered to use namespace 'Microsoft.KeyVault'. See https://aka.ms/rps-not-found for how to register subscriptions.
Exception Details:      (MissingSubscriptionRegistration) The subscription is not registered to use namespace 'Microsoft.KeyVault'. See https://aka.ms/rps-not-found for how to register subscriptions.
        Code: MissingSubscriptionRegistration
        Message: The subscription is not registered to use namespace 'Microsoft.KeyVault'. See https://aka.ms/rps-not-found for how to register subscriptions.
        Target: Microsoft.KeyVault
PS C:\WINDOWS\system32> az provider register --namespace 'Microsoft.KeyVault'
Registering is still on-going. You can monitor using 'az provider show -n Microsoft.KeyVault'
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> az provider show -n
argument --namespace/-n: expected one argument

Examples from AI knowledge base:
az provider show --namespace Microsoft.Storage
Gets the specified resource provider. (autogenerated)

az provider show --expand {expand} --namespace Microsoft.Storage
Gets the specified resource provider. (autogenerated)

https://docs.microsoft.com/en-US/cli/azure/provider#az_provider_show
Read more about the command in reference docs
PS C:\WINDOWS\system32> az provider show -n Microsoft.KeyVault --query "registrationState"
"Registered"
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> $VAULT_NAME="fiqueok-prj009-poc-kv"
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> az keyvault create `
>>   --name $VAULT_NAME `
>>   --resource-group "fiqueok-prj009-poc-rg" `
>>   --location "brazilsouth" `
>>   --enable-rbac-authorization true `
>>   --tags "Projeto=PRJ009" "Ambiente=POC"
{
  "id": "/subscriptions/8c8a1deb-2cbc-4c51-a177-87b874d44923/resourceGroups/fiqueok-prj009-poc-rg/providers/Microsoft.KeyVault/vaults/fiqueok-prj009-poc-kv",
  "location": "brazilsouth",
  "name": "fiqueok-prj009-poc-kv",
  "properties": {
    "accessPolicies": [],
    "createMode": null,
    "enablePurgeProtection": null,
    "enableRbacAuthorization": true,
    "enableSoftDelete": true,
    "enabledForDeployment": false,
    "enabledForDiskEncryption": false,
    "enabledForTemplateDeployment": false,
    "hsmPoolResourceId": null,
    "networkAcls": null,
    "privateEndpointConnections": null,
    "provisioningState": "Succeeded",
    "publicNetworkAccess": "Enabled",
    "sku": {
      "family": "A",
      "name": "standard"
    },
    "softDeleteRetentionInDays": 90,
    "tenantId": "503bbd0e-f33f-4ebe-b12e-f24a506978c9",
    "vaultUri": "https://fiqueok-prj009-poc-kv.vault.azure.net/"
  },
  "resourceGroup": "fiqueok-prj009-poc-rg",
  "systemData": {
    "createdAt": "2026-02-26T17:31:36.684000+00:00",
    "createdBy": "paulo@fiqueok.com.br",
    "createdByType": "User",
    "lastModifiedAt": "2026-02-26T17:31:36.684000+00:00",
    "lastModifiedBy": "paulo@fiqueok.com.br",
    "lastModifiedByType": "User"
  },
  "tags": {
    "Ambiente": "POC",
    "Projeto": "PRJ009"
  },
  "type": "Microsoft.KeyVault/vaults"
}
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> $MSI_NAME="fiqueok-prj009-api-identity"
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> az identity create `
>>   --name $MSI_NAME `
>>   --resource-group "fiqueok-prj009-poc-rg" `
>>   --location "brazilsouth" `
>>   --tags "Projeto=PRJ009" "Ambiente=POC"
Resource provider 'Microsoft.ManagedIdentity' used by this operation is not registered. We are registering for you.
Registration succeeded.
{
  "clientId": "05195e48-c70c-413f-af09-47f2f7e58b9d",
  "id": "/subscriptions/8c8a1deb-2cbc-4c51-a177-87b874d44923/resourcegroups/fiqueok-prj009-poc-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/fiqueok-prj009-api-identity",
  "isolationScope": "None",
  "location": "brazilsouth",
  "name": "fiqueok-prj009-api-identity",
  "principalId": "f2ff052f-0930-4d26-963d-f1edd4a1950c",
  "resourceGroup": "fiqueok-prj009-poc-rg",
  "systemData": null,
  "tags": {
    "Ambiente": "POC",
    "Projeto": "PRJ009"
  },
  "tenantId": "503bbd0e-f33f-4ebe-b12e-f24a506978c9",
  "type": "Microsoft.ManagedIdentity/userAssignedIdentities"
}
PS C:\WINDOWS\system32> az identity show --name "fiqueok-prj009-api-identity" --resource-group "fiqueok-prj009-poc-rg"
{
  "clientId": "05195e48-c70c-413f-af09-47f2f7e58b9d",
  "id": "/subscriptions/8c8a1deb-2cbc-4c51-a177-87b874d44923/resourcegroups/fiqueok-prj009-poc-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/fiqueok-prj009-api-identity",
  "isolationScope": "None",
  "location": "brazilsouth",
  "name": "fiqueok-prj009-api-identity",
  "principalId": "f2ff052f-0930-4d26-963d-f1edd4a1950c",
  "resourceGroup": "fiqueok-prj009-poc-rg",
  "systemData": null,
  "tags": {
    "Ambiente": "POC",
    "Projeto": "PRJ009"
  },
  "tenantId": "503bbd0e-f33f-4ebe-b12e-f24a506978c9",
  "type": "Microsoft.ManagedIdentity/userAssignedIdentities"
}
PS C:\WINDOWS\system32>