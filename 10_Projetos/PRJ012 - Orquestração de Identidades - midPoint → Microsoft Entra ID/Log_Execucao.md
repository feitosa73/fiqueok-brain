

**Data/Hora da Execução:** `2026-03-06 17:15`  
**Responsável:** `Paulo Lima`  
**Projeto:** `PRJ012 — Orquestração de Identidades`  
**Fase:** ATO 1 — Fundação de Conectividade Azure

---

#### 🔐 Identificadores Coletados

- **Name**: midpoint-iga-connector
- **Application (Client) ID:**  6df1b421-cf53-41c4-b4aa-9a5d50f65148
- **Directory (Tenant) ID:** `503bbd0e-f33f-4ebe-b12e-f24a506978c9`
- **Client Secret Value:** `Armazenado no Vault (Path: `secret/prj012/entra-connector)`
- **App Object ID:** 7e08c730-f713-45cd-b90e-d3d23742be50



#### 📜 Permissões Aplicadas

- `User.ReadWrite.All`
- `Group.ReadWrite.All`
- `Directory.Read.All`
- **Consentimento Administrativo:** ✅ Aplicado

---

#### 🧪 Sanity Check — Resultados

- **Token OAuth2:** ✅ Gerado com sucesso (Length: `3456`)
- **Usuários retornados via Graph API:** `100`
- **Grupos retornados via Graph API:** `5`
- **Status HTTP:** `200 OK`

---

#### 📂 Evidência

- Arquivo JSON salvo em: `C:\Logs\PRJ012_ATO1_Validation.json`
- Screenshot do Portal Azure (App Registration + Permissões) anexado em: `Obsidian/PRJ012/Evidencias/ATO1_AppRegistration.png`

---

#### ✅ Conclusão

Ato 1 concluído com sucesso.  
Fundação de conectividade validada → pronto para avançar para **ATO 2 (midPoint → Entra ID)**.

---

👉 Esse modelo pode ser replicado para cada ato, mudando apenas os campos de evidência e validação. Assim, você mantém consistência e rastreabilidade em todo o ciclo.

Quer que eu já prepare também o **template para o ATO 2 (Reconciliação Dry Run)**, para você ter pronto antes de executar os scripts do midPoint?