Welcome to the Google Cloud CLI! Run "gcloud -h" to get the list of available commands.
---
Welcome! This command will take you through the configuration of gcloud.

Your current configuration has been set to: [default]

You can skip diagnostics next time by using the following flag:
  gcloud init --skip-diagnostics

Network diagnostic detects and fixes local network connection issues.
Checking network connection...done.
Reachability Check passed.
Network diagnostic passed (1/1 checks passed).

You must sign in to continue. Would you like to sign in (selecting "Y" will open your browser to the sign-in page where
you complete authentication) (Y/n)?  Y

Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=32555940559.apps.googleusercontent.com&redirect_uri=http%3A%2F%2Flocalhost%3A8085%2F&scope=openid+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fappengine.admin+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fsqlservice.login+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcompute+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Faccounts.reauth&state=l6pAaKyK3qNOXyk1iC16X5PWTjtgMt&access_type=offline&code_challenge=sLmcAf3sdy7JuF-wmfcxxY4bjAv0_tUyP1fzZceBEvQ&code_challenge_method=S256

You are signed in as: [feitosa.lima@gmail.com].

Pick cloud project to use:
 [1] gen-lang-client-0874790435
 [2] labs-385023
 [3] silver-archery-385123
 [4] sistema-inventario-iam
 [5] Enter a project ID
 [6] Create a new project
Please enter numeric choice or text value (must exactly match list item):  6

Enter a Project ID. Note that a Project ID CANNOT be changed later.
Project IDs must be 6-30 characters (lowercase ASCII, digits, or
hyphens) in length and start with a lowercase letter. Midpoint_IGA
WARNING: Project creation failed: HttpError accessing <https://cloudresourcemanager.googleapis.com/v1/projects?alt=json>: response: <{'vary': 'Origin, X-Origin, Referer', 'content-type': 'application/json; charset=UTF-8', 'content-encoding': 'gzip', 'date': 'Mon, 04 May 2026 19:37:49 GMT', 'server': 'ESF', 'x-xss-protection': '0', 'x-frame-options': 'SAMEORIGIN', 'x-content-type-options': 'nosniff', 'server-timing': 'gfet4t7; dur=796', 'alt-svc': 'h3=":443"; ma=2592000,h3-29=":443"; ma=2592000', 'transfer-encoding': 'chunked', 'status': 400}>, content <{
  "error": {
    "code": 400,
    "message": "Request contains an invalid argument.",
    "status": "INVALID_ARGUMENT",
    "details": [
      {
        "@type": "type.googleapis.com/google.rpc.BadRequest",
        "fieldViolations": [
          {
            "field": "project_id",
            "description": "project_id contains invalid characters"
          },
          {
            "field": "display_name",
            "description": "project display name contains invalid characters"
          }
        ]
      },
      {
        "@type": "type.googleapis.com/google.rpc.Help",
        "links": [
          {
            "url": "https://cloud.google.com/resource-manager/reference/rest/v1/projects"
          }
        ]
      }
    ]
  }
}
>
Please make sure to create the project [Midpoint_IGA] using
    $ gcloud projects create Midpoint_IGA
or change to another project using
    $ gcloud config set project <PROJECT ID>
The Google Cloud CLI is configured and ready to use!

* Commands that require authentication will use feitosa.lima@gmail.com by default
Run `gcloud help config` to learn how to change individual settings

This gcloud configuration is called [default]. You can create additional configurations if you work with multiple accounts and/or projects.
Run `gcloud topic configurations` to learn more.

Some things to try next:

* Run `gcloud --help` to see the Cloud Platform services you can interact with. And run `gcloud help COMMAND` to get help on any gcloud command.
* Run `gcloud topic --help` to learn about advanced features of the CLI like arg files and output formatting
* Run `gcloud cheat-sheet` to see a roster of go-to `gcloud` commands.

C:\Program Files (x86)\Google\Cloud SDK>gcloud projects create midpoint-iga --name="MidPoint IGA Lab"
Create in progress for [https://cloudresourcemanager.googleapis.com/v1/projects/midpoint-iga].
Waiting for [operations/create_project.global.8053157137990589492] to finish...done.
Enabling service [cloudapis.googleapis.com] on project [midpoint-iga]...
Operation "operations/acat.p2-94652337432-5e0777f3-295c-4166-8194-eeffca0f39ad" finished successfully.

C:\Program Files (x86)\Google\Cloud SDK>
C:\Program Files (x86)\Google\Cloud SDK>gcloud projects list | findstr midpoint-iga

C:\Program Files (x86)\Google\Cloud SDK>
C:\Program Files (x86)\Google\Cloud SDK># Aguardar propagação (10-15 segundos)
'#' não é reconhecido como um comando interno
ou externo, um programa operável ou um arquivo em lotes.

C:\Program Files (x86)\Google\Cloud SDK>timeout /t 15

Aguardando  0 segundos, pressione uma tecla para continuar ...

C:\Program Files (x86)\Google\Cloud SDK>
C:\Program Files (x86)\Google\Cloud SDK>gcloud projects list | findstr midpoint-iga
midpoint-iga                MidPoint IGA Lab        94652337432

C:\Program Files (x86)\Google\Cloud SDK>
C:\Program Files (x86)\Google\Cloud SDK>
C:\Program Files (x86)\Google\Cloud SDK>gcloud iam service-accounts create midpoint-connector \
ERROR: (gcloud.iam.service-accounts.create) unrecognized arguments: \

To search the help text of gcloud commands, run:
  gcloud help -- SEARCH_TERMS

C:\Program Files (x86)\Google\Cloud SDK>  --display-name="midPoint Connector GCP" \
'--display-name' não é reconhecido como um comando interno
ou externo, um programa operável ou um arquivo em lotes.

C:\Program Files (x86)\Google\Cloud SDK>  --description="Conta de serviço para integração midPoint com GCP IAM" \
'--description' não é reconhecido como um comando interno
ou externo, um programa operável ou um arquivo em lotes.

C:\Program Files (x86)\Google\Cloud SDK>  --project=midpoint-iga
'--project' não é reconhecido como um comando interno
ou externo, um programa operável ou um arquivo em lotes.

C:\Program Files (x86)\Google\Cloud SDK>gcloud iam service-accounts create midpoint-connector --display-name="midPoint Connector GCP" --description="Conta de servico para integracao midPoint com GCP IAM" --project=midpoint-iga
Created service account [midpoint-connector].

C:\Program Files (x86)\Google\Cloud SDK>
C:\Program Files (x86)\Google\Cloud SDK>gcloud projects add-iam-policy-binding midpoint-iga --member="serviceAccount:midpoint-connector@midpoint-iga.iam.gserviceaccount.com" --role="roles/iam.securityAdmin"
Updated IAM policy for project [midpoint-iga].
bindings:
- members:
  - serviceAccount:midpoint-connector@midpoint-iga.iam.gserviceaccount.com
  role: roles/iam.securityAdmin
- members:
  - user:feitosa.lima@gmail.com
  role: roles/owner
etag: BwZRAx6p_fQ=
version: 1

C:\Program Files (x86)\Google\Cloud SDK>
C:\Program Files (x86)\Google\Cloud SDK>
C:\Program Files (x86)\Google\Cloud SDK>gcloud iam service-accounts keys create %USERPROFILE%\midpoint-gcp-key.json --iam-account=midpoint-connector@midpoint-iga.iam.gserviceaccount.com --project=midpoint-iga
created key [<REDACTED_SECRET>] of type [json] as [C:\Users\win\midpoint-gcp-key.json] for [midpoint-connector@midpoint-iga.iam.gserviceaccount.com]

C:\Program Files (x86)\Google\Cloud SDK>
C:\Program Files (x86)\Google\Cloud SDK># Verificar se o arquivo foi criado
'#' não é reconhecido como um comando interno
ou externo, um programa operável ou um arquivo em lotes.

C:\Program Files (x86)\Google\Cloud SDK>dir %USERPROFILE%\midpoint-gcp-key.json
 O volume na unidade C não tem nome.
 O Número de Série do Volume é 2472-5849

 Pasta de C:\Users\win

05/04/2026  04:43 PM             2,366 midpoint-gcp-key.json
               1 arquivo(s)          2,366 bytes
               0 pasta(s)   875,775,709,184 bytes disponíveis

C:\Program Files (x86)\Google\Cloud SDK>
C:\Program Files (x86)\Google\Cloud SDK># Exibir o conteúdo (para copiar/compartilhar com o midPoint)
'#' não é reconhecido como um comando interno
ou externo, um programa operável ou um arquivo em lotes.

C:\Program Files (x86)\Google\Cloud SDK>type %USERPROFILE%\midpoint-gcp-key.json
{
  "type": "service_account",
  "project_id": "midpoint-iga",
  "private_key_id": "<REDACTED_SECRET>",
  "private_key": "-----BEGIN PRIVATE KEY-----\<REDACTED_SECRET>jAgEAAoIBAQC4FiLF8Cs3C1zo\<REDACTED_SECRET>DGpxFyDpLItUN3RllNFAdY47G\<REDACTED_SECRET>I7yBOK9olaSGpuetCM8BgAlP4\<REDACTED_SECRET>Mklm91GKoHiGqwPvZVuZvpy7O\<REDACTED_SECRET>4PMEfQIxrtD0iligxuwXRV+/P\<REDACTED_SECRET>FdBkgJ0K+Ji4ArjSKZfCvWQc/\<REDACTED_SECRET>EG0Mha7WaY5fCMk7jJjJN8w89\<REDACTED_SECRET>2JPbdzyBQ8zMj92OCyF8SVpb2\<REDACTED_SECRET>x880CCK8hcoj/wyhoFRWm1Exy\<REDACTED_SECRET>slwPUTjgT+wxS79DKDLaxS0mR\<REDACTED_SECRET>eSxtjt3mJqKc9YDlwk43iuADg\<REDACTED_SECRET>4TwKBgQDeihekAFkvEUr1JAkS\<REDACTED_SECRET>3nXyK1xXjJIMdWIgjfSAN3Qq3\<REDACTED_SECRET>0m0S48O1qsEcGVuNArOZJU/gz\<REDACTED_SECRET>MnBTV4EKHM7RvZ2RfZLeJBHUE\<REDACTED_SECRET>i589Do7Wap3JHdRfeC3NKqA2Z\<REDACTED_SECRET>pBok45FK2h+Xfmd+XFyN6oBW/\<REDACTED_SECRET>GbuV8CQHxYiY9YSiTNZAtfBat\<REDACTED_SECRET>3pEu8qTMWI2gTSOA/0n+FTSE8\<REDACTED_SECRET>Rtmttnoqmpg66PzXzAoGBAIt5\<REDACTED_SECRET>GJwwtHtN7TkJEl+5OdJEkGUjf\<REDACTED_SECRET>WuKdVjeVf+qbQx55/f2dxUk1F\<REDACTED_SECRET>fAoGAIWWOsZCNj+XFxA1oeE7e\<REDACTED_SECRET>ae3+3idmJQT9lKcfO6RaHYvtT\<REDACTED_SECRET>uI3E5zsUrMnKkjK+S9m3GjEa+\nJadNH6JZRunO5ibFKb2xf2M=\n-----END PRIVATE KEY-----\n",
  "client_email": "midpoint-connector@midpoint-iga.iam.gserviceaccount.com",
  "client_id": "106389980620576348642",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/midpoint-connector%40midpoint-iga.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}

C:\Program Files (x86)\Google\Cloud SDK>gcloud iam service-accounts keys create %USERPROFILE%\midpoint-gcp-key.json --iam-account=midpoint-connector@midpoint-iga.iam.gserviceaccount.com --project=midpoint-iga
created key [<REDACTED_SECRET>] of type [json] as [C:\Users\win\midpoint-gcp-key.json] for [midpoint-connector@midpoint-iga.iam.gserviceaccount.com]

C:\Program Files (x86)\Google\Cloud SDK>
C:\Program Files (x86)\Google\Cloud SDK>
C:\Program Files (x86)\Google\Cloud SDK>
C:\Program Files (x86)\Google\Cloud SDK>dir %USERPROFILE%\midpoint-gcp-key.json
 O volume na unidade C não tem nome.
 O Número de Série do Volume é 2472-5849

 Pasta de C:\Users\win

05/04/2026  04:45 PM             2,366 midpoint-gcp-key.json
               1 arquivo(s)          2,366 bytes
               0 pasta(s)   875,633,164,288 bytes disponíveis

C:\Program Files (x86)\Google\Cloud SDK>
C:\Program Files (x86)\Google\Cloud SDK>gcloud services enable iam.googleapis.com --project=midpoint-iga
Operation "operations/acat.p2-94652337432-7a476241-f321-46a1-8776-403168554761" finished successfully.

C:\Program Files (x86)\Google\Cloud SDK>gcloud services enable cloudresourcemanager.googleapis.com --project=midpoint-iga
Operation "operations/acat.p2-94652337432-38ce9265-2141-4e5c-bccd-e1d09ca39aca" finished successfully.

C:\Program Files (x86)\Google\Cloud SDK>gcloud services enable admin.googleapis.com --project=midpoint-iga
Operation "operations/acat.p2-94652337432-cc0a1092-f3cb-4e2f-b8f4-6edc0decd3b5" finished successfully.

C:\Program Files (x86)\Google\Cloud SDK>
