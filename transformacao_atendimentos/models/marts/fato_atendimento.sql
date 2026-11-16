{{ config(materialized='table') }}

WITH atendimentos AS (
    SELECT
        id_atendimento,
        ano_origem,
        quantidade,
        altura,
        largura,
        area_m
    FROM {{ ref('int_atendimentos_deduplicados') }}
),

localizacao AS (
    SELECT
        id_atendimento,
        regional,
        bairro,
        localidade
    FROM {{ ref('int_atendimentos_localizacao') }}
),

solicitacao AS (
    SELECT
        id_atendimento,
        ocorrencia_padrao,
        solicitacao_padrao,
        grupo_solicitacao
    FROM {{ ref('int_atendimentos_solicitacao') }}
),

acao_risco AS (
    SELECT
        id_atendimento,
        tipo_acao,
        categoria_acao,
        grau_risco
    FROM {{ ref('int_atendimentos_acao_risco') }}
),

datas AS (
    SELECT
        id_atendimento,
        data_registro,
        data_acao,
        dias_ate_acao,
        flag_data_inconsistente
    FROM {{ ref('int_atendimentos_datas') }}
)

SELECT
    a.id_atendimento,

    COALESCE(dl.id_localizacao_sk, -1)
        AS id_localizacao_sk,

    COALESCE(ds.id_solicitacao_sk, -1)
        AS id_solicitacao_sk,

    COALESCE(dta.id_tipo_acao_sk, -1)
        AS id_tipo_acao_sk,

    COALESCE(dr.id_risco_sk, -1)
        AS id_risco_sk,

    COALESCE(dtr.id_tempo_sk, -1)
        AS id_tempo_registro_sk,

    COALESCE(dta_tempo.id_tempo_sk, -1)
        AS id_tempo_acao_sk,

    a.ano_origem,
    a.quantidade,
    a.altura,
    a.largura,
    a.area_m,

    dt.dias_ate_acao,
    dt.flag_data_inconsistente

FROM atendimentos AS a

LEFT JOIN localizacao AS l
    ON a.id_atendimento = l.id_atendimento

LEFT JOIN {{ ref('dim_localizacao') }} AS dl
    ON l.regional IS NOT DISTINCT FROM dl.regional
   AND l.bairro IS NOT DISTINCT FROM dl.bairro
   AND l.localidade IS NOT DISTINCT FROM dl.localidade

LEFT JOIN solicitacao AS s
    ON a.id_atendimento = s.id_atendimento

LEFT JOIN {{ ref('dim_solicitacao') }} AS ds
    ON s.ocorrencia_padrao = ds.ocorrencia
   AND s.solicitacao_padrao = ds.solicitacao
   AND s.grupo_solicitacao = ds.grupo_solicitacao

LEFT JOIN acao_risco AS ar
    ON a.id_atendimento = ar.id_atendimento

LEFT JOIN {{ ref('dim_tipo_acao') }} AS dta
    ON COALESCE(ar.tipo_acao, 'não informado') = dta.tipo_acao
   AND COALESCE(ar.categoria_acao, 'não informado') = dta.categoria_acao

LEFT JOIN {{ ref('dim_risco') }} AS dr
    ON COALESCE(ar.grau_risco, 'não informado') = dr.codigo_risco

LEFT JOIN datas AS dt
    ON a.id_atendimento = dt.id_atendimento

LEFT JOIN {{ ref('dim_tempo') }} AS dtr
    ON dt.data_registro IS NOT DISTINCT FROM dtr.data_calendario

LEFT JOIN {{ ref('dim_tempo') }} AS dta_tempo
    ON dt.data_acao IS NOT DISTINCT FROM dta_tempo.data_calendario  