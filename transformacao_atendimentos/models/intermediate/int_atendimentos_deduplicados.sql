{{ config(materialized='view') }}

-- Remove registros duplicados seguindo o mesmo critério utilizado no ETL.

WITH registros_unicos AS (

    SELECT DISTINCT ON (
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
        ano_origem
    )

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
        flag_area_divergente

    FROM {{ ref('int_atendimentos_medidas') }}

    ORDER BY
        regional NULLS FIRST,
        ano NULLS FIRST,
        mes NULLS FIRST,
        data_registro NULLS FIRST,
        ocorrencia NULLS FIRST,
        solicitacao NULLS FIRST,
        endereco NULLS FIRST,
        bairro NULLS FIRST,
        localidade NULLS FIRST,
        grau_risco NULLS FIRST,
        data_acao NULLS FIRST,
        tipo_acao NULLS FIRST,
        quantidade NULLS FIRST,
        altura NULLS FIRST,
        largura NULLS FIRST,
        area_m NULLS FIRST,
        ano_origem NULLS FIRST,
        flag_area_divergente
)

SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            regional NULLS FIRST,
            ano NULLS FIRST,
            mes NULLS FIRST,
            data_registro NULLS FIRST,
            ocorrencia NULLS FIRST,
            solicitacao NULLS FIRST,
            endereco NULLS FIRST,
            bairro NULLS FIRST,
            localidade NULLS FIRST,
            grau_risco NULLS FIRST,
            data_acao NULLS FIRST,
            tipo_acao NULLS FIRST,
            quantidade NULLS FIRST,
            altura NULLS FIRST,
            largura NULLS FIRST,
            area_m NULLS FIRST,
            ano_origem NULLS FIRST
    )::INTEGER AS id_atendimento,

    *

FROM registros_unicos