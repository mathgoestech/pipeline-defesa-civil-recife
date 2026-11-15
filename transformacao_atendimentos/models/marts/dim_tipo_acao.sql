{{ config(materialized='table') }}

-- um registro por tipo de ação padronizado que aparece na base

WITH tipos AS (
    SELECT DISTINCT
        tipo_acao,
        categoria_acao
    FROM {{ ref('int_atendimentos_acao_risco') }}
    WHERE tipo_acao IS NOT NULL
),

com_chave AS (
    SELECT
        -- chave sequencial em ordem alfabética, começando em 1, igual ao ETL
        -- (COLLATE "C" ordena pelos códigos dos caracteres, como o sorted() do Python)
        ROW_NUMBER() OVER (ORDER BY tipo_acao COLLATE "C")::INTEGER AS id_tipo_acao_sk,
        tipo_acao,
        categoria_acao
    FROM tipos
),

nao_informado AS (
    SELECT
        -1 AS id_tipo_acao_sk,
        'não informado' AS tipo_acao,
        'não informado' AS categoria_acao
)

SELECT * FROM nao_informado
UNION ALL
SELECT * FROM com_chave
