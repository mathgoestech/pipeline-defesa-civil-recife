{{ config(materialized='table') }}

WITH localizacoes_distintas AS (

    SELECT DISTINCT
        regional,
        bairro,
        localidade

    FROM {{ ref('int_atendimentos_localizacao') }}

    WHERE regional IS NOT NULL
       OR bairro IS NOT NULL
       OR localidade IS NOT NULL
),

localizacoes_com_chave AS (

    SELECT
        ROW_NUMBER() OVER (
            ORDER BY
                regional COLLATE "C" NULLS LAST,
                bairro COLLATE "C" NULLS LAST,
                localidade COLLATE "C" NULLS LAST
        ) AS id_localizacao_sk,

        regional,
        bairro,
        localidade

    FROM localizacoes_distintas
)

SELECT
    id_localizacao_sk,
    regional,
    bairro,
    localidade

FROM localizacoes_com_chave

UNION ALL

SELECT
    -1 AS id_localizacao_sk,
    'não informado' AS regional,
    'não informado' AS bairro,
    'não informado' AS localidade