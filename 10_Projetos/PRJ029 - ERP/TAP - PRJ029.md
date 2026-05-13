Perfeito, Paulo. Recebi todas as informações do terminal e confirmei o ambiente.

Com base nos dados coletados, segue o **TAP PRJ029** formalizado e corrigido:

---

# Technical Assessment Plan (TAP) - PRJ029

**ID:** PRJ029

**Projeto:** Implementação de ERP Odoo 17.0 (Source of Truth) para Ecossistema de IGA

**Data:** 11 de Maio de 2026

**Status:** Em Execução (Fase de Provisionamento e Configuração)

---

## 1. Visão Geral e Objetivos Estratégicos

Implementação de uma instância Dockerizada do **Odoo 17.0** para atuar como o **Sistema de Origem (HR/RH)** no ecossistema de gestão de identidades do *Living Lab*.

- **Visão de Negócio:** Centralizar o ciclo de vida do colaborador (Joiner, Mover, Leaver)
- **Riscos Mitigados:** Inconsistência de dados cadastrais, acesso residual de ex-funcionários e falta de padronização em cargos/departamentos

---

## 2. Stack Tecnológica & Arquitetura (Validada)

| Componente | Especificação |
|------------|----------------|
| **Host VM** | Ubuntu 26.04 LTS (GNU/Linux 7.0.0-15-generic) |
| **Hypervisor** | VMware (open-vm-tools instalado) |
| **vCPU** | 2 x Intel Core i5-1038NG7 @ 2.00GHz |
| **RAM** | 3.3 GiB (expansível via host) |
| **Storage** | 40GB (expansão LVM concluída: 37GB disponíveis) |
| **Runtime** | Docker Engine + Docker Compose Plugin |
| **Network** | Tailscale Mesh (IP: xxx.xxx.xxx.xxx) + eth0 (192.168.61.129) |

### Containers a serem implantados:

| Container | Imagem | Porta | Persistência |
|-----------|--------|-------|--------------|
| PostgreSQL 15 | `postgres:15` | - | `./postgresql` |
| Odoo 17.0 | `odoo:17.0` | 8069 | `./odoo-data` |

---

## 3. Inventário de Recursos (Após Provisionamento)

### Hardware/VM validado:
```bash
✓ 2 vCPUs alocadas
✓ 3.3 GiB RAM (uso atual: 12%)
✓ 37GB de storage LVM (/dev/mapper/ubuntu--vg-ubuntu--lv)
✓ Interface ens33: 192.168.61.129
✓ Tailscale ativo: xxx.xxx.xxx.xxx
```

### Software instalado:
```bash
✓ Docker CE 29.4.3
✓ Docker Compose Plugin 5.1.3
✓ containerd.io 2.2.3
✓ Tailscale 1.96.4
```

### Estrutura de diretórios criada:
```bash
/home/paulo/odoo-lab/
├── docker-compose.yml
├── postgresql/          # Dados do banco
└── odoo-data/           # Dados da aplicação
```

---

## 4. Checklist de Segurança e Governança (ISO 27001)

| Item | Status | Observação |
|------|--------|------------|
| Segregação de dados | ✅ OK | Volumes Docker separados |
| Least Privilege (Host) | ⚠️ Pendente | Ajustar `chown 101:101` para diretórios Odoo |
| Master Password Management | ⚠️ Pendente | Armazenar chave mestre em cofre (Ex: Vault GF-01) |
| API Security | ⚠️ Pendente | Configurar usuário técnico para midPoint |
| Data Integrity | 📋 Em progresso | Avaliar uso de Demo Data vs dados sintéticos |
| Backup Strategy | ⚠️ Pendente | Definir política de dump do PostgreSQL |
| Network Segmentation | ✅ OK | Tailscale + VLAN isolada |

---

## 5. Plano de Implementação Técnica

| Fase | Atividade | Status |
|------|-----------|--------|
| **Fase 1** | Provisionamento da VM Ubuntu 26.04 | ✅ Concluído |
| **Fase 2** | Expansão de disco LVM (40GB) | ✅ Concluído |
| **Fase 3** | Instalação Docker + Tailscale | ✅ Concluído |
| **Fase 4** | Criação do docker-compose.yml | ✅ Concluído |
| **Fase 5** | Subir containers (odoov17 + pg15) | 🔄 **Em execução** |
| **Fase 6** | Configurar Master Admin e banco de dados | ⏳ Pendente |
| **Fase 7** | Ativar módulo `employee` | ⏳ Pendente |
| **Fase 8** | Configurar XML-RPC/JSON-RPC para midPoint | ⏳ Pendente |
| **Fase 9** | Validação de integração com IGA | ⏳ Pendente |

---

## 6. Ações Imediatas (Próximos Passos)

### 6.1 Subir os containers:
```bash
cd ~/odoo-lab
sudo docker compose up -d
```

### 6.2 Verificar logs e saúde:
```bash
sudo docker compose logs -f
sudo docker ps
sudo docker compose ps
```

### 6.3 Ajustar permissões (Least Privilege):
```bash
sudo chown -R 101:101 ~/odoo-lab/odoo-data
```

### 6.4 Testar acesso:
```
http://xxx.xxx.xxx.xxx:8069
http://192.168.61.129:8069
```

---

## 7. Indicadores de Sucesso (KPIs)

| KPI | Métrica | Alvo |
|-----|---------|------|
| **Uptime** | Disponibilidade do ERP | ≥ 99.5% |
| **Integração** | Reconciliation midPoint → Odoo | 100% dos campos mapeados |
| **Segurança** | Acesso restrito à Tailscale | Sem exposição na internet |
| **Desempenho** | Tempo de resposta da API | ≤ 200ms |
| **Disponibilidade** | Container health check | Status "healthy" |

---

## 8. Observações e Riscos

| Risco | Probabilidade | Mitigação |
|-------|---------------|-----------|
| VM com apenas 3.3GB RAM (subdimensionada para Odoo + PG) | Média | Monitorar uso e expandir recursos via host |
| Docker com permissões root em volumes | Baixa | Aplicar `chown 101:101` |
| Falta de backup | Alta | Implementar dump automático do PG |

---

**Documento assinado eletronicamente via rastreabilidade ISO 27001**

*Paulo Feitosa* – Líder Técnico  
*Data: 11/05/2026 17:32 BRT*

---

**Pronto para executar a Fase 5? Posso te ajudar a subir os containers e validar os logs.**
