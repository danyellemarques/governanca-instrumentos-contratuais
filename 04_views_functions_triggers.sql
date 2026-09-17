-- ==============================================================================
-- SISTEMA DE GOVERNANÇA E CONTROLE DE INSTRUMENTOS CONTRATUAIS
-- Script 04: Estruturas Avançadas (VIEWs, Functions, Triggers e Window Functions)
-- Autora: Danyelle Marques
-- ==============================================================================

SET search_path TO governanca;

-- ------------------------------------------------------------------------------
-- 1. VIEW: painel_carteira
-- Consolida as informações essenciais para a visão executiva e conexão com Power BI
-- ------------------------------------------------------------------------------
CREATE OR REPLACE VIEW painel_carteira AS
SELECT
    i.numero,
    i.tipo,
    LEFT(i.objeto, 60) AS objeto_resumido,
    o.nome AS organizacao,
    r.nome AS responsavel,
    i.valor_total,
    i.status,
    i.data_vigencia_fim,
    (i.data_vigencia_fim - CURRENT_DATE) AS dias_restantes,
    COALESCE(
      (SELECT a.resultado
       FROM auditoria a
       WHERE a.instrumento_id = i.id
       ORDER BY a.data_auditoria DESC
       LIMIT 1),
      'Sem auditoria'
    ) AS ultima_auditoria
FROM instrumento i
JOIN organizacao o ON i.organizacao_id = o.id
JOIN responsavel r ON i.responsavel_id = r.id;


-- ------------------------------------------------------------------------------
-- 2. FUNCTION: dias_restantes_vigencia
-- Calcula prazo restante e classifica nível de criticidade do instrumento
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dias_restantes_vigencia(p_instrumento_id INT)
RETURNS TABLE(
    numero VARCHAR,
    dias_restantes INT,
    situacao VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        i.numero,
        (i.data_vigencia_fim - CURRENT_DATE)::INT,
        CASE
            WHEN i.data_vigencia_fim < CURRENT_DATE THEN 'VENCIDO'
            WHEN (i.data_vigencia_fim - CURRENT_DATE) <= 30 THEN 'CRITICO'
            WHEN (i.data_vigencia_fim - CURRENT_DATE) <= 90 THEN 'ATENCAO'
            ELSE 'OK'
        END::VARCHAR
    FROM instrumento i
    WHERE i.id = p_instrumento_id;
END;
$$ LANGUAGE plpgsql;


-- ------------------------------------------------------------------------------
-- 3. TRIGGER & FUNCTION: Automação de Tempo de Tramitação
-- Calcula automaticamente os dias na etapa sempre que data_saida for registrada
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION calcular_dias_na_etapa()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.data_saida IS NOT NULL AND OLD.data_saida IS NULL THEN
        NEW.dias_na_etapa := EXTRACT(DAY FROM (NEW.data_saida - NEW.data_entrada));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_dias_etapa ON tramitacao;

CREATE TRIGGER trg_dias_etapa
    BEFORE UPDATE ON tramitacao
    FOR EACH ROW
    EXECUTE FUNCTION calcular_dias_na_etapa();


-- ------------------------------------------------------------------------------
-- 4. WINDOW FUNCTIONS (Consultas Analíticas Avançadas)
-- ------------------------------------------------------------------------------

-- A) Ranking de Organizações por Valor Global Contratado (RANK)
SELECT
    o.nome,
    SUM(i.valor_total) AS valor_total,
    RANK() OVER (ORDER BY SUM(i.valor_total) DESC) AS ranking
FROM organizacao o
JOIN instrumento i ON o.id = i.organizacao_id
GROUP BY o.nome;

-- B) Histórico e Variação de Score das Auditorias (LAG)
SELECT
    i.numero,
    a.data_auditoria,
    a.resultado,
    a.checklist_score,
    LAG(a.checklist_score) OVER (
      PARTITION BY a.instrumento_id
      ORDER BY a.data_auditoria
    ) AS score_anterior,
    a.checklist_score - COALESCE(
      LAG(a.checklist_score) OVER (
        PARTITION BY a.instrumento_id
        ORDER BY a.data_auditoria
      ), a.checklist_score
    ) AS variacao
FROM auditoria a
JOIN instrumento i ON a.instrumento_id = i.id
ORDER BY i.numero, a.data_auditoria;
