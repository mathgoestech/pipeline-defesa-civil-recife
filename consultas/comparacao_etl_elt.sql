-- ============================================================
--                    VALIDACAO ETL x ELT
-- ============================================================

-- 1. Comparacao da quantidade de registros nas tabelas
SELECT
    'fato_atendimento' AS tabela,
    (SELECT COUNT(*) FROM etl.fato_atendimento) AS total_etl,
    (SELECT COUNT(*) FROM elt.fato_atendimento) AS total_elt

UNION ALL

SELECT
    'dim_localizacao',
    (SELECT COUNT(*) FROM etl.dim_localizacao),
    (SELECT COUNT(*) FROM elt.dim_localizacao)

UNION ALL

SELECT
    'dim_solicitacao',
    (SELECT COUNT(*) FROM etl.dim_solicitacao),
    (SELECT COUNT(*) FROM elt.dim_solicitacao)

UNION ALL

SELECT
    'dim_tipo_acao',
    (SELECT COUNT(*) FROM etl.dim_tipo_acao),
    (SELECT COUNT(*) FROM elt.dim_tipo_acao)

UNION ALL

SELECT
    'dim_risco',
    (SELECT COUNT(*) FROM etl.dim_risco),
    (SELECT COUNT(*) FROM elt.dim_risco)

UNION ALL

SELECT
    'dim_tempo',
    (SELECT COUNT(*) FROM etl.dim_tempo),
    (SELECT COUNT(*) FROM elt.dim_tempo);


-- 2. Comparacao do conteudo da fato
-- Ignora id_atendimento e as chaves substitutas (SKs), comparando
-- atributos descritivos, datas, medidas e multiplicidade dos registros.
WITH etl_dados AS (
    SELECT
        l.regional,
        l.bairro,
        l.localidade,
        s.ocorrencia,
        s.solicitacao,
        s.grupo_solicitacao,
        a.tipo_acao,
        a.categoria_acao,
        r.codigo_risco,
        r.descricao_risco,
        r.nivel_risco,
        tr.data_calendario AS data_registro,
        ta.data_calendario AS data_acao,
        f.ano_origem,
        f.quantidade,
        f.altura,
        f.largura,
        f.area_m,
        f.dias_ate_acao,
        f.flag_data_inconsistente
    FROM etl.fato_atendimento AS f
    LEFT JOIN etl.dim_localizacao AS l
        ON f.id_localizacao_sk = l.id_localizacao_sk
    LEFT JOIN etl.dim_solicitacao AS s
        ON f.id_solicitacao_sk = s.id_solicitacao_sk
    LEFT JOIN etl.dim_tipo_acao AS a
        ON f.id_tipo_acao_sk = a.id_tipo_acao_sk
    LEFT JOIN etl.dim_risco AS r
        ON f.id_risco_sk = r.id_risco_sk
    LEFT JOIN etl.dim_tempo AS tr
        ON f.id_tempo_registro_sk = tr.id_tempo_sk
    LEFT JOIN etl.dim_tempo AS ta
        ON f.id_tempo_acao_sk = ta.id_tempo_sk
),

elt_dados AS (
    SELECT
        l.regional,
        l.bairro,
        l.localidade,
        s.ocorrencia,
        s.solicitacao,
        s.grupo_solicitacao,
        a.tipo_acao,
        a.categoria_acao,
        r.codigo_risco,
        r.descricao_risco,
        r.nivel_risco,
        tr.data_calendario AS data_registro,
        ta.data_calendario AS data_acao,
        f.ano_origem,
        f.quantidade,
        f.altura,
        f.largura,
        f.area_m,
        f.dias_ate_acao,
        f.flag_data_inconsistente
    FROM elt.fato_atendimento AS f
    LEFT JOIN elt.dim_localizacao AS l
        ON f.id_localizacao_sk = l.id_localizacao_sk
    LEFT JOIN elt.dim_solicitacao AS s
        ON f.id_solicitacao_sk = s.id_solicitacao_sk
    LEFT JOIN elt.dim_tipo_acao AS a
        ON f.id_tipo_acao_sk = a.id_tipo_acao_sk
    LEFT JOIN elt.dim_risco AS r
        ON f.id_risco_sk = r.id_risco_sk
    LEFT JOIN elt.dim_tempo AS tr
        ON f.id_tempo_registro_sk = tr.id_tempo_sk
    LEFT JOIN elt.dim_tempo AS ta
        ON f.id_tempo_acao_sk = ta.id_tempo_sk
),

diferencas AS (
    SELECT
        'ETL_ONLY' AS lado,
        d.*
    FROM (
        SELECT * FROM etl_dados
        EXCEPT ALL
        SELECT * FROM elt_dados
    ) AS d

    UNION ALL

    SELECT
        'ELT_ONLY' AS lado,
        d.*
    FROM (
        SELECT * FROM elt_dados
        EXCEPT ALL
        SELECT * FROM etl_dados
    ) AS d
)

SELECT
    lado,
    COUNT(*) AS quantidade_diferencas
FROM diferencas
GROUP BY lado
ORDER BY lado;