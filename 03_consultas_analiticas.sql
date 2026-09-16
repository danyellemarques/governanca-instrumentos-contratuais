-- ==============================================================================
-- SISTEMA DE GOVERNANÇA E CONTROLE DE INSTRUMENTOS CONTRATUAIS
-- Script 03: Consultas Analíticas e Regras de Negócio
-- Autora: Danyelle Marques
-- ==============================================================================

SET search_path TO governanca;

-- ------------------------------------------------------------------------------
-- 1. Identificação de gargalos operacionais no fluxo de tramitação
-- Objetivo: Identificar etapas com tempo médio de permanência superior a 3 dias.
-- ------------------------------------------------------------------------------
SELECT
    etapa_origem,
    etapa_destino,
    ROUND(AVG(dias_na_etapa), 1) AS media_dias,
    COUNT(*) AS total_tramitacoes
FROM tramitacao
WHERE dias_na_etapa IS NOT NULL
GROUP BY etapa_origem, etapa_destino
HAVING AVG(dias_na_etapa) > 3
ORDER BY media_dias DESC;


-- ------------------------------------------------------------------------------
-- 2. Classificação da carteira por faixa de valor financeiro
-- Objetivo: Categorizar os instrumentos em faixas de porte financeiro.
-- ------------------------------------------------------------------------------
SELECT
    numero,
    valor_total,
    CASE
        WHEN valor_total < 100000 THEN 'Pequeno Porte'
        WHEN valor_total BETWEEN 100000 AND 500000 THEN 'Medio Porte'
        WHEN valor_total BETWEEN 500001 AND 1000000 THEN 'Grande Porte'
        ELSE 'Mega Porte'
    END AS faixa_valor
FROM instrumento
ORDER BY valor_total DESC;


-- ------------------------------------------------------------------------------
-- 3. Detecção de instrumentos sem auditoria registrada
-- Objetivo: Mapear instrumentos celebrados que nunca passaram por auditoria de controle.
-- ------------------------------------------------------------------------------
SELECT
    numero,
    objeto,
    status
FROM instrumento
WHERE id NOT IN (
    SELECT instrumento_id
    FROM auditoria
);


-- ------------------------------------------------------------------------------
-- 4. Índice de conformidade da última auditoria para instrumentos ativos
-- Objetivo: Resgatar o percentual de conformidade da auditoria mais recente.
-- ------------------------------------------------------------------------------
SELECT
    i.numero,
    a.data_auditoria,
    a.resultado,
    a.checklist_score,
    a.checklist_total,
    ROUND(a.checklist_score * 100.0 / NULLIF(a.checklist_total, 0), 1) AS pct_conformidade
FROM instrumento i
JOIN auditoria a ON i.id = a.instrumento_id
WHERE i.status = 'Ativo'
  AND a.data_auditoria = (
      SELECT MAX(a2.data_auditoria)
      FROM auditoria a2
      WHERE a2.instrumento_id = i.id
  )
ORDER BY pct_conformidade;


-- ------------------------------------------------------------------------------
-- 5. Concentração de recursos e quantidade de instrumentos por organização
-- Objetivo: Consolidar volume financeiro gerido por ente parceiro/fornecedor.
-- ------------------------------------------------------------------------------
SELECT
    o.nome AS organizacao,
    COUNT(i.id) AS qtd_instrumentos,
    SUM(i.valor_total) AS valor_total
FROM organizacao o
JOIN instrumento i ON o.id = i.organizacao_id
GROUP BY o.nome
ORDER BY valor_total DESC;


-- ------------------------------------------------------------------------------
-- 6. Monitoramento de marcos contratuais com atraso de execução
-- Objetivo: Rastrear entregas e etapas físicas com prazo expirado.
-- ------------------------------------------------------------------------------
SELECT
    m.descricao AS marco,
    m.data_prevista,
    i.numero AS instrumento,
    o.nome AS organizacao
FROM marco m
JOIN instrumento i ON m.instrumento_id = i.id
JOIN organizacao o ON i.organizacao_id = o.id
WHERE m.status = 'Atrasado'
ORDER BY m.data_prevista;
