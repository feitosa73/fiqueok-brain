# 

### 1. AS IS (Cenário Atual / Default)

_O estado "Nativo" de uma implementação sem governança._

> A "Foto" do Problema:
> 
> Atualmente, o diretório opera em uma estrutura plana (Flat Hierarchy). Todos os objetos residem nos containers padrão do Windows (CN=Users, CN=Computers).

**Características Técnicas:**

- ❌ **Mistura de Privilégios:** Contas de Serviço, Administradores de Domínio e Estagiários residem no mesmo container.
    
- ❌ **Impossibilidade de GPO Granular:** Não é possível aplicar políticas de segurança (ex: Bloqueio de USB) apenas para o "Financeiro", pois não há separação lógica.
    
- ❌ **Provisionamento Artesanal:** Criação manual (clique-a-clique), sujeita a erro humano e desvios de padrão (ex: `paulo.silva` vs `psilva`).
    
- ❌ **Risco de Auditoria:** Não há rastro claro de quem aprovou o acesso.
    

**Representação Visual (Árvore Lógica):**

Plaintext

```
DC=fiqueok,DC=local
├── CN=Builtin
├── CN=Computers (Workstations misturadas com Servers)
├── CN=Users (Admins, Serviços e Usuários misturados)
└── CN=Infrastructure (Vazio/Default)
```

---

### 2. SHOULD BE (Cenário Projetado / Fiqueok Standard)

_O estado "Governado" após execução da GMUD-004 e GMUD-005._

> A Visão de Futuro:
> 
> Implementação de uma arquitetura hierárquica orientada a riscos e funções (RBAC), com segregação clara de ativos (Tier Model) e automação baseada na fonte da verdade (RH).

**Ganhos de Negócio:**

- ✅ **Segregação de Funções (SoD):** Admins isolados em OUs protegidas (Tier 0).
    
- ✅ **Aplicação de Controles (ISO 27001):** GPOs específicas por departamento ou criticidade.
    
- ✅ **Automação (IGA Nível 1):** O AD reflete exatamente o sistema de RH.
    
- ✅ **Padronização:** Nomenclatura previsível (`nome.sobrenome`) facilitando buscas e scripts.
    

**Representação Visual (Árvore Lógica):**

Plaintext

```
DC=fiqueok,DC=local
├── 📂 Fiqueok_Corp (Raiz Protegida)
│   ├── 📂 Admins (Tier 0/1 - MFA Obrigatório)
│   ├── 📂 Service_Acc (Senhas Longas/Não expiram)
│   ├── 📂 Sec_Groups (RBAC Roles)
│   ├── 📂 Corp_Servers
│   ├── 📂 Corp_Devices
│   └── 📂 Corp_Users
│       ├── 📂 RH
│       ├── 📂 Financeiro
│       └── 📂 TI_Sec
└── CN=Users (Legado/Vazio - Apenas Guest)
```

---

### 3. A Ponte: O Plano de Transição

Para sair do **AS IS** e chegar no **SHOULD BE**, este é o racional que colocaremos na GMUD:

|**Pilar**|**Ação de Mudança**|**GMUD Responsável**|
|---|---|---|
|**Estrutura**|Criar a "Estante" (OUs) antes de comprar os "Livros" (Usuários).|**GMUD-004**|
|**Limpeza**|Mover contas `Administrator` e `Guest` para locais seguros e auditados.|**GMUD-004**|
|**Identidade**|Popular a estrutura nova usando o RH como fonte.|**GMUD-005**|
|**Legado**|Bloquear criação de novos objetos na raiz padrão (`CN=Users`).|**GMUD-006 (Futura)**|