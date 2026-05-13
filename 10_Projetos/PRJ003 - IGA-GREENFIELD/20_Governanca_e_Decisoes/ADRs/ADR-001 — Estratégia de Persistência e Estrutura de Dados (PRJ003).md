

**Status:** Consolidado

**Data:** 14/01/2026

**Autor:** Paulo Feitosa

**Projeto:** PRJ003 — IGA Greenfield Reference Architecture

---

## 1. Contexto e Problema

O Living Lab Fiqueok 2.0 exige que o ambiente IGA seja capaz de realizar um _cold start_ (recriação do zero) sem perda de coerência semântica e histórica. No PRJ002, a persistência era gerida de forma implícita ou via volumes anónimos do Docker, o que dificultava a auditoria direta no sistema de arquivos e a portabilidade das configurações do midPoint.

Para o **PRJ003**, é necessário definir uma estrutura de diretórios no _host_ que:

- Garanta a sobrevivência dos dados após comandos `docker compose down`.
    
- Permita a rastreabilidade e auditoria exigidas pelo **DGC-001**.
    
- Facilite a gestão de backups e a reconstrução do ambiente em caso de falha catastrófica.
    

## 2. Decisão

Adotaremos uma estratégia de persistência baseada em **Bind Mounts** centralizados no diretório `/srv/prj003` da VM `IGA-GF-01`.

A estrutura de dados será organizada da seguinte forma:

- **/srv/prj003/data/postgres**: Armazenamento exclusivo dos arquivos binários do banco de dados PostgreSQL.
    
- **/srv/prj003/data/midpoint/var**: Armazenamento das configurações de estado, repositório de esquemas e identidades do midPoint.
    
- **/srv/prj003/logs/midpoint**: Centralização de logs aplicacionais para análise fora do ciclo de vida dos containers.
    

### Justificação Técnica:

1. **Transparência e Auditoria:** O uso de _bind mounts_ permite que o Owner do projeto aceda diretamente aos logs e configurações no sistema de ficheiros do Ubuntu, cumprindo o requisito de "Rastreabilidade e Auditoria" do **DGC-001**.
    
2. **Independência do Container:** Os dados residem no _host_, garantindo que a remoção das imagens ou containers não resulte em perda de dados semânticos.
    
3. **Consistência com a GMUD-004:** Utiliza a infraestrutura de Ubuntu Server 24.04 LTS já validada e provisionada.
    

## 3. Consequências

- **Positivas:** - Facilidade na execução de backups a nível de ficheiro no _host_.
    
    - Garantia de que o estado "Ativo" ou "Suspenso" da identidade (definido no **CAN-ID-003**) será preservado entre reinícios da plataforma.
        
    - Conformidade total com a matriz de responsabilidades do **DEC-ID-001**.
        
- **Negativas/Riscos:** - Necessidade de gestão manual de permissões de ficheiros no _host_ para garantir que o utilizador do Docker possa ler/escrever em `/srv/prj003`.
    

## 4. Relação com outros Artefatos

- **DGC-001 (Data Governance Canvas):** Este ADR materializa as cláusulas de armazenamento e retenção.
    
- **GMUD-005 (Execução Funcional):** A GMUD-005 deve referenciar este ADR para configurar os volumes no `docker-compose.yml`.
    
- **DEC-ID-001 (Identity Decision Canvas):** Este ADR cumpre a regra de formalizar decisões arquiteturais antes da implementação técnica.
    

---

### Notas de Aprovação

|**Papel**|**Nome**|**Status**|
|---|---|---|
|Owner do Projeto|Paulo Feitosa|✅ Aprovado|
|Arquiteto IAM|Paulo Feitosa|✅ Aprovado|

---

