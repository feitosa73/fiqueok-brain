

---
type: Inference Document
project: PRJ027
date: 2026-05-10
status: hypothesis
confidence: medium
---
# INF-PRJ027-001 — Breaking Changes no midPoint 4.10 para Synchronization
## Declaração de Transparência
**Este documento não contém evidência direta nos arquivos do Living Lab.**
O conteúdo abaixo é uma **inferência** baseada em:
1. Comportamento observado no PRJ027 (evidência empírica)
2. Relatos da comunidade Evolveum (fontes externas)
3. Correlação temporal com versões do midPoint
## Evidência Empírica (Living Lab)
| Teste | Resultado |
|-------|-----------|
| `<synchronize>true</synchronize>` no Resource XML | ❌ Falha silenciosa |
| `<action><type>reconcile</type></action>` | ❌ Não aceito |
| `<link>true</link>` para `unlinked` | ✅ Funciona |
## Evidência Externa
| Fonte | Link | Data | Relevância |
|-------|------|------|------------|
| Fórum Evolveum — Markus | [URL] | Jan/2024 | Relato de LiveSync quebrado pós-atualização |
| Documentação Smart Correlation | [URL] | v4.8+ | Modelo substituto documentado |
## Inferência
**Hipótese:** midPoint 4.10 não suporta mais o modelo legado de synchronization tags. Recursos configurados no padrão pré-4.8 precisam ser migrados para smart correlation.
**Nível de confiança:** Médio (confirmado empiricamente no lab, mas sem confirmação oficial da Evolveum)
## Pendência para Fechamento desta Inferência
- [ ] Obter resposta oficial da Evolveum via ticket/slack
- [ ] Testar migração do XML para smart correlation
- [ ] Documentar se funcionou ou não