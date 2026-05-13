# 

> [!IMPORTANT]
> **Documentação Formal:** O Termo de Abertura de Projeto (TAP) e o Procedimento Operacional Padrão (POP) detalhados estão armazenados no arquivo oficial em formato Word (.docx).

## 📂 Localização do Artefato

- **Caminho:** `C:\Projetos\Obsidian\Fiqueok_Brain\10_Projetos\PRJ017 - Secure Edge Gateway (Zero Trust Implementation)\PRJ017_TAP_POP.docx`
    
- **Acesso:** Deve ser realizado diretamente pelo Computador Local.
    

---

## 🎯 Resumo Executivo

Este projeto implementa o conceito de **Zero Attack Surface** para o laboratório, eliminando a exposição direta de portas na internet. A identidade do usuário passa a ser o novo perímetro de segurança.

### 🏗️ Arquitetura de Borda (Edge)

A solução utiliza **Cloudflare Zero Trust** para criar uma camada de autenticação antes que qualquer tráfego atinja a rede interna.

- **Camada de Identidade:** Cloudflare Access com One-Time PIN (OTP).
    
- **Camada de Transporte:** Cloudflare Tunnel (Managed) eliminando regras de firewall de entrada.
    
- **Camada de Origem:** Aplicação rodando em localhost (Porta 8000 para API, 8085 para OrangeHRM).
    

### ✅ Controles ISO/IEC 27001:2022 Endereçados

- **A.5.15:** Controle de Acesso (Zero Trust Policy).
    
- **A.8.3:** Restrição de Acesso (Identidade verificada).
    
- **A.8.20:** Segurança de Redes (Eliminação de portas expostas).
    
- **A.8.26:** Segurança de Aplicações (HTTPS obrigatório na borda).
    

---

## 📋 Próximas Ações (Roadmap de Replicação)

Conforme definido no **POP-PRJ017-001**:

- [ ] Publicação do **OrangeHRM** via `rh.fiqueok.com.br` (Porta 8085).
    
- [ ] Publicação do **Midpoint IGA** via `iga.fiqueok.com.br` (Porta 8443).
    

---

_Última atualização: 18 de Abril de 2026 por Paulo._
