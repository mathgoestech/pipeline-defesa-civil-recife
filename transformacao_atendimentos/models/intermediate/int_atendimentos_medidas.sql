{{ config(materialized='view') }}

WITH medidas_convertidas AS (
    SELECT
        regional,
        ano,
        mes,
        data_registro,
        ocorrencia,
        solicitacao,
        endereco,
        bairro,
        localidade,
        grau_risco,
        data_acao,
        tipo_acao,

        NULLIF(BTRIM(quantidade), '')::NUMERIC AS quantidade,
        NULLIF(BTRIM(altura), '')::NUMERIC AS altura,
        NULLIF(BTRIM(largura), '')::NUMERIC AS largura,

        NULLIF(
            NULLIF(BTRIM(area_m), '')::NUMERIC,
            0
        ) AS area_m,

        ano_origem

    FROM {{ ref('stg_atendimentos') }}
),

medidas_calculadas AS (
    SELECT
        *,
        altura * largura * quantidade AS area_calculada
    FROM medidas_convertidas
)

SELECT
    regional,
    ano,
    mes,
    data_registro,
    ocorrencia,
    solicitacao,
    endereco,
    bairro,
    localidade,
    grau_risco,
    data_acao,
    tipo_acao,
    quantidade,
    altura,
    largura,
    area_m,
    ano_origem,

    CASE
        WHEN area_calculada IS NOT NULL
             AND (
                 area_m IS NULL
                 OR ABS(area_m - area_calculada) > 0.01
             )
            THEN TRUE

        WHEN area_m IS NOT NULL
             AND area_calculada IS NULL
            THEN TRUE

        ELSE FALSE
    END AS flag_area_divergente

FROM medidas_calculadas