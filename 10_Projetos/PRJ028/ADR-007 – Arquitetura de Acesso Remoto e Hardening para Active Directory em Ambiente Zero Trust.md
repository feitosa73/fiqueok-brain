# 
**Architecture Decision Record**
**Living Lab Fiqueok - GRC/IAM Open-Source Platform**
---
## Metadados
| Campo | Valor |
|-------|-------|
| **ID** | ADR-007 |
| **Título** | Arquitetura de Acesso Remoto e Hardening para Active Directory em Ambiente Zero Trust |
| **Status** | ✅ **APROVADO** |
| **Data** | 10/05/2026 |
| **Autor** | Paulo Feitosa Lima |
| **Decisor** | Paulo Feitosa Lima (Owner/CISO) |
| **Contexto** | PRJ028 - Segurança e Acesso Remoto ao Active Directory |
| **Projeto Relacionado** | PRJ026 (Integração midPoint ↔ AD), PRJ017 (Cloudflare Zero Trust) |
| **Decisões Substituídas** | N/A (Primeira decisão formal sobre acesso remoto ao AD) |
| **Versão** | 1.0 |
---
## 1. Contexto e Problema
### 1.1. Situação Anterior
Até a execução do PRJ028, o Active Directory (ID-P-01) apresentava as seguintes características:
| Aspecto | Configuração Anterior | Problema |
|---------|----------------------|----------|
| **Rede** | IP `172.24.192.10`, gateway `172.24.192.1` (inexistente) | Isolado, sem comunicação com outras VMs |
| **Acesso remoto** | WinRM e RDP não funcionavam | Impossibilidade de administração remota |
| **Firewall** | Configuração padrão do Windows | Superfície de ataque ampla |
| **Segurança** | Sem hardening específico | Serviços desnecessários ativos (SMB, NetBIOS) |
### 1.2. Problema a Ser Resolvido
Estabelecer uma **arquitetura de acesso remoto seguro e auditável** para o Active Directory, que permita:
1. **Comunicação segura** entre midPoint e AD (LDAP)
2. **Administração remota** pelo responsável técnico
3. **Isolamento da internet** (entrada bloqueada, saída permitida)
4. **Conformidade com frameworks de segurança** (Zero Trust, CIS, ISO 27001)
### 1.3. Restrições e Premissas
| Restrição | Descrição |
|-----------|-----------|
| **Ambiente** | Laboratório doméstico (Living Lab), não produção |
| **Orçamento** | Zero custo adicional (soluções open-source ou free tier) |
| **Conectividade** | AD deve ter saída para internet (NTP, atualizações) |
| **Acesso externo** | Responsável precisa acessar de qualquer local |
| **Segurança** | Nenhuma porta do AD pode estar exposta diretamente na internet |
---
## 2. Decisão
### 2.1. Arquitetura Escolhida
Adotar uma arquitetura **Zero Trust** baseada em:
| Componente | Tecnologia | Função |
|------------|------------|--------|
| **Overlay Network** | Tailscale (WireGuard) | Rede mesh criptografada entre dispositivos |
| **Firewall** | Windows Defender (netsh advfirewall) | `BlockInbound, AllowOutbound` |
| **Acesso administrativo** | SSH (OpenSSH Server) | Substitui WinRM, mais seguro e auditável |
| **Autenticação** | Chave SSH + MFA | Elimina senhas, adiciona dupla verificação |
| **Controle de acesso** | Tailscale ACLs | Microssegmentação por tag |
| **MFA** | Cloudflare Zero Trust | OTP por e-mail |
### 2.2. Diagrama de Arquitetura

┌─────────────────────────────────────────────────────────────────────────────────────┐  
│ ARQUITETURA DE ACESSO REMOTO AO AD (ZERO TRUST) │  
├─────────────────────────────────────────────────────────────────────────────────────┤  
│ │  
│ ┌─────────────────────────────────────────────────────────────────────────────┐ │  
│ │ LIVING LAB (ON-PREMISE) │ │  
│ │ │ │  
│ │ ┌─────────────────┐ ┌─────────────────┐ │ │  
│ │ │ ID-P-01 │ │ iga-gf-02 │ │ │  
│ │ │ (AD) │◀───── Tailscale ─────▶│ (midPoint) │ │ │  
│ │ │ IP físico: │ (WireGuard) │ IP Tailscale: │ │ │  
│ │ │ 172.23.195.2 │ │ xxx.xxx.xxx.xxx │ │ │  
│ │ │ IP Tailscale: │ │ │ │ │  
│ │ │ xxx.xxx.xxx.xxx│ │ │ │ │  
│ │ │ │ │ │ │ │  
│ │ │ 🔒 Hardening: │ │ │ │ │  
│ │ │ • Firewall: │ │ │ │ │  
│ │ │ BlockInbound│ │ │ │ │  
│ │ │ • SSH ativo │ │ │ │ │  
│ │ │ • SMB off │ │ │ │ │  
│ │ │ • WinRM off │ │ │ │ │  
│ │ └─────────────────┘ └─────────────────┘ │ │  
│ │ ▲ │ │  
│ │ │ Tailscale + MFA + ACLs │ │  
│ │ │ │ │  
│ └───────────┼───────────────────────────────────────────────────────────────────┘ │  
│ │ │  
│ │ Apenas tráfego Tailscale (WireGuard) │  
│ ▼ │  
│ ┌─────────────────────────────────────────────────────────────────────────────┐ │  
│ │ TAILSCALE MESH + CLOUDFLARE ZT │ │  
│ │ │ │  
│ │ ┌──────────────────────────────────────────────────────────────────────┐ │ │  
│ │ │ Tailscale ACLs (Microssegmentação): │ │ │  
│ │ │ • tag:midpoint → tag:ad:389 (LDAP) │ │ │  
│ │ │ • tag:admin → tag:ad:22 (SSH) │ │ │  
│ │ │ • tag:admin → tag:ad:3389 (RDP) │ │ │  
│ │ └──────────────────────────────────────────────────────────────────────┘ │ │  
│ │ │ │  
│ │ ┌──────────────────────────────────────────────────────────────────────┐ │ │  
│ │ │ Cloudflare Zero Trust (MFA): │ │ │  
│ │ │ • Aplicação: [ad-tailscale.fiqueok.com.br](https://ad-tailscale.fiqueok.com.br/) │ │ │  
│ │ │ • Regra: email + MFA (OTP) │ │ │  
│ │ │ • Logs de todas as tentativas │ │ │  
│ │ └──────────────────────────────────────────────────────────────────────┘ │ │  
│ └─────────────────────────────────────────────────────────────────────────────┘ │  
│ │  
│ ✅ AD sem portas expostas na internet │  
│ ✅ Acesso via Tailscale com criptografia WireGuard │  
│ ✅ MFA obrigatória via Cloudflare OTP │  
│ ✅ Microssegmentação via ACLs │  
│ ✅ Logs de auditoria de todas as tentativas │  
└─────────────────────────────────────────────────────────────────────────────────────┘

text

### 2.3. Componentes da Arquitetura
| Componente | Tecnologia | Versão | Justificativa |
|------------|------------|--------|---------------|
| **Overlay Network** | Tailscale | 1.96.3+ | WireGuard nativo, zero configuração de firewall, ACLs integradas |
| **Firewall** | Windows Defender | Windows Server 2022 | Nativo, sem custo adicional |
| **Acesso administrativo** | OpenSSH Server | Windows Server 2022 | Nativo, mais seguro que WinRM, padrão da indústria |
| **Autenticação** | Chave SSH (ed25519) | - | Mais segura que senha, resistente a brute force |
| **MFA** | Cloudflare Zero Trust | Free Tier | Integração nativa com Tailscale, OTP por e-mail |
| **Hardening** | CIS Benchmarks v3.0 | - | Referência global de segurança para Windows Server |
---
## 3. Alternativas Consideradas
### 3.1. Alternativa A: VPN Tradicional (OpenVPN/WireGuard)
| Critério | Avaliação |
|----------|-----------|
| **Segurança** | Média (acesso à rede inteira, não apenas serviços) |
| **Complexidade** | Alta (configuração de certificados, rotas, firewall) |
| **Manutenção** | Alta (gestão de certificados, atualizações) |
| **MFA** | Possível, mas requer configuração adicional |
| **Custo** | Zero (open-source) |
**Motivo da rejeição:** Acesso à rede inteira viola princípio de privilégio mínimo. Tailscale oferece microssegmentação nativa.
### 3.2. Alternativa B: Apenas RDP com Gateway
| Critério | Avaliação |
|----------|-----------|
| **Segurança** | Baixa (RDP tem histórico de vulnerabilidades) |
| **Complexidade** | Média (RD Gateway requer certificados e configuração) |
| **Manutenção** | Média |
| **MFA** | Possível com RD Gateway + NPS + MFA |
| **Custo** | Zero |
**Motivo da rejeição:** RDP é menos seguro que SSH, tem maior superfície de ataque, e não oferece microssegmentação.
### 3.3. Alternativa C: Apenas WinRM com PowerShell Remoto
| Critério | Avaliação |
|----------|-----------|
| **Segurança** | Média (depende de Kerberos/HTTPS) |
| **Complexidade** | Baixa (nativo do Windows) |
| **Manutenção** | Baixa |
| **MFA** | Complexo (requer CredSSP ou soluções adicionais) |
| **Custo** | Zero |
**Motivo da rejeição:** WinRM foi desabilitado no hardening (por escolha). SSH é mais seguro, multiplataforma, e não sofre do problema de Double Hop.
### 3.4. Alternativa D: Tailscale + RDP (sem SSH)
| Critério | Avaliação |
|----------|-----------|
| **Segurança** | Média (RDP ainda é RDP) |
| **Complexidade** | Baixa |
| **Manutenção** | Baixa |
| **MFA** | Sim (via Cloudflare) |
| **Custo** | Zero |
**Motivo da rejeição:** RDP é suficiente para administração eventual, mas SSH permite automação, scripts, e transferência de arquivos (`scp`). SSH é padrão da indústria para administração remota.
---
## 4. Justificativa Técnica
### 4.1. Por que Tailscale?
| Benefício | Descrição |
|-----------|-----------|
| **WireGuard nativo** | Criptografia moderna, performance superior a OpenVPN |
| **Zero configuração de firewall** | Tailscale atravessa NATs e firewalls automaticamente |
| **ACLs integradas** | Microssegmentação por tag, não por IP |
| **Mesh VPN** | Comunicação direta entre nós, sem servidor central |
| **Free tier** | Suficiente para laboratório (até 3 usuários, 100 dispositivos) |
### 4.2. Por que `BlockInbound, AllowOutbound`?
| Princípio | Aplicação |
|-----------|-----------|
| **Privilégio mínimo** | AD não deve receber conexões não solicitadas |
| **Zero Trust** | Nenhuma confiança implícita na rede |
| **CIS Benchmark** | Recomendação explícita para Domain Controllers |
### 4.3. Por que SSH em vez de WinRM?
| Critério | SSH | WinRM |
|----------|-----|-------|
| **Padrão da indústria** | ✅ Sim (Linux, Windows, macOS) | ⚠️ Apenas Windows |
| **Autenticação por chave** | ✅ Nativo | ⚠️ Complexo |
| **Double Hop** | ✅ Resolvido nativamente | ❌ Problema conhecido |
| **Transferência de arquivos** | ✅ `scp`, `sftp` | ❌ Requer scripts adicionais |
| **Superfície de ataque** | 🟢 Menor | 🟡 Maior |
| **MFA integrada** | ✅ Sim (via PAM ou soluções externas) | ⚠️ Complexo |
### 4.4. Por que Chave SSH (ed25519)?
| Critério | Chave SSH | Senha |
|----------|-----------|-------|
| **Resistência a brute force** | ✅ Alta (2^256 combinações) | ❌ Baixa |
| **Gestão** | ✅ Pode ser revogada individualmente | ⚠️ Difícil |
| **Phishing** | ✅ Resistente | ❌ Vulnerável |
| **Conveniência** | ✅ Uma vez configurada | ⚠️ Digitada a cada acesso |
---
## 5. Alinhamento com Frameworks
### 5.1. NIST SP 800-207 (Zero Trust Architecture)
| Princípio | Implementação |
|-----------|---------------|
| **Toda comunicação é segura** | Tailscale com WireGuard (criptografia ponta a ponta) |
| **Acesso por sessão** | ACLs do Tailscale avaliam cada conexão |
| **Privilégio mínimo** | Acesso restrito a portas específicas (389, 22, 3389) |
| **Monitoramento contínuo** | Logs do Tailscale e Cloudflare |
### 5.2. CIS Benchmarks v3.0 (Windows Server 2022)
| Recomendação | Implementação |
|--------------|---------------|
| **Bloquear inbound** | `netsh advfirewall set allprofiles blockinbound` |
| **Desabilitar SMBv1** | `Set-SmbServerConfiguration -EnableSMB1Protocol $false` |
| **Desabilitar NetBIOS** | `Disable-NetAdapterBinding -ComponentID "ms_server"` |
| **Restringir acesso anônimo LDAP** | `dsHeuristics='0000002'` |
| **Usar SSH para administração** | OpenSSH Server instalado e configurado |
### 5.3. ISO 27001:2022
| Controle | Implementação |
|----------|---------------|
| **A.5.15 - Controle de acesso** | Tailscale ACLs + MFA |
| **A.5.16 - Gestão de identidades** | Chave SSH + Cloudflare |
| **A.8.3 - Privilégio mínimo** | Acesso apenas às portas necessárias |
| **A.8.15 - Logging** | Logs do Tailscale e Cloudflare |
| **A.13.1.1 - Segregação de redes** | Tailscale como overlay network |
| **A.13.1.3 - Segurança de rede** | Firewall `BlockInbound` |
---
## 6. Consequências
### 6.1. Positivas
| Consequência | Benefício |
|--------------|-----------|
| **Isolamento completo** | AD sem portas expostas na internet |
| **Acesso seguro** | Tailscale + MFA + chave SSH |
| **Auditabilidade** | Logs de todas as tentativas de acesso |
| **Manutenção simplificada** | Acesso remoto via SSH para scripts e automação |
| **Baixo custo** | Soluções free tier ou nativas do Windows |
### 6.2. Negativas (Aceitas)
| Consequência | Impacto | Mitigação |
|--------------|---------|-----------|
| **Dependência de Tailscale** | Se Tailscale falhar, acesso remoto é perdido | Tailscale tem alta disponibilidade; console Hyper-V como fallback |
| **SSH não é nativo no Windows** | Requer instalação e configuração | OpenSSH é suportado oficialmente pela Microsoft |
| **Curva de aprendizado** | SSH pode ser menos familiar para administradores Windows | Documentação e POP serão criados |
### 6.3. Riscos Residuais
| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| Chave SSH comprometida | Baixa | Alto | Revogar chave, gerar nova; MFA como segunda camada |
| Tailscale comprometido | Muito Baixa | Alto | Tailscale não armazena chaves privadas; MFA adicional |
| Cloudflare indisponível | Baixa | Médio | Acesso via Tailscale ainda funciona (MFA é adicional) |
---
## 7. Referências
### 7.1. Documentos Relacionados
| Documento | Localização | Relevância |
|-----------|-------------|------------|
| TAP-PRJ028 | `10_Projetos/PRJ028/00_Gestao_do_Projeto/` | Planejamento do projeto |
| GMUD-001-PRJ028 | `10_Projetos/PRJ028/20_Governanca_e_Decisoes/` | Execução do hardening |
| GMUD-002-PRJ028 | `10_Projetos/PRJ028/20_Governanca_e_Decisoes/` | Configuração de ACLs e MFA |
| PRJ017 | `10_Projetos/PRJ017/` | Cloudflare Zero Trust |
### 7.2. Frameworks e Normas
| Framework | Referência |
|-----------|------------|
| NIST SP 800-207 | Zero Trust Architecture |
| CIS Benchmarks v3.0 | Windows Server 2022 |
| ISO 27001:2022 | A.5.15, A.5.16, A.8.3, A.8.15, A.13.1.1, A.13.1.3 |
### 7.3. Documentação Técnica
| Tecnologia | Documentação |
|------------|--------------|
| Tailscale ACLs | https://tailscale.com/kb/1018/acls/ |
| OpenSSH no Windows | https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_overview |
| Cloudflare Zero Trust | https://developers.cloudflare.com/cloudflare-one/ |
---
## 8. Aprovações
| Função | Nome | Data | Status |
|--------|------|------|:------:|
| Autor | Paulo Feitosa Lima | 10/05/2026 | ✅ |
| Decisor (Owner/CISO) | Paulo Feitosa Lima | 10/05/2026 | ✅ |
| GRC Lead | Paulo Feitosa Lima | 10/05/2026 | ✅ |
---
## 9. Histórico de Versões
| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 10/05/2026 | Paulo Feitosa Lima | Criação do ADR-007 - Arquitetura Zero Trust para AD |
---
**FIM DO ADR-007 v1.0**
---
*Documento mantido por Paulo Feitosa Lima — Living Lab Fiqueok*  
*PRJ028 - Segurança e Acesso Remoto ao Active Directory*  
*Data: 10/05/2026*
