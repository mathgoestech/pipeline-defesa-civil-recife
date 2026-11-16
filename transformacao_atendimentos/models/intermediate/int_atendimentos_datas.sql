{{ config(materialized='view') }}

WITH datas_convertidas AS (

    SELECT
        id_atendimento,
        regional,
        ocorrencia,
        solicitacao,
        endereco,
        bairro,
        localidade,
        grau_risco,
        tipo_acao,
        quantidade,
        altura,
        largura,
        area_m,
        ano_origem,
        flag_area_divergente,

        -- Formatação de datas
        NULLIF(BTRIM(data_registro), '')::DATE AS data_registro,
        NULLIF(BTRIM(data_acao), '')::DATE AS data_acao,
        NULLIF(BTRIM(ano), '')::INTEGER AS ano_cad,

        -- Formatação de nomes de mês
        CASE TRANSLATE(LOWER(BTRIM(mes)), 'çÇ', 'cc')

            WHEN 'janeiro' THEN 1
            WHEN 'fevereiro' THEN 2
            WHEN 'marco' THEN 3
            WHEN 'maro' THEN 3 -- Caso particular de erro em 2022
            WHEN 'abril' THEN 4
            WHEN 'maio' THEN 5
            WHEN 'junho' THEN 6
            WHEN 'julho' THEN 7
            WHEN 'agosto' THEN 8
            WHEN 'setembro' THEN 9
            WHEN 'outubro' THEN 10
            WHEN 'novembro' THEN 11
            WHEN 'dezembro' THEN 12

        END AS mes_cad
    
    FROM {{ ref('int_atendimentos_deduplicados') }}
)

SELECT
    id_atendimento,
    regional,
    ocorrencia,
    solicitacao,
    endereco,
    bairro,
    localidade,
    grau_risco,
    tipo_acao,
    quantidade,
    altura,
    largura,
    area_m,
    ano_origem,
    flag_area_divergente,
    data_registro,
    data_acao,
    data_acao - data_registro AS dias_ate_acao,

    -- Tradução de inconsistências de datas
    CASE
        WHEN data_registro IS NULL OR data_acao IS NULL THEN TRUE -- Datas nulas
        WHEN data_registro NOT BETWEEN '{{ var("data_inicial") }}' AND '{{ var("data_final") }}'
            OR data_acao NOT BETWEEN '{{ var("data_inicial") }}' AND '{{ var("data_final") }}' THEN TRUE -- Datas fora do intervalo
        WHEN data_acao < data_registro OR (data_acao - data_registro) > 365 THEN TRUE -- Datas não cronológicas
        WHEN ano_cad <> EXTRACT(YEAR FROM data_registro) OR mes_cad <> EXTRACT(MONTH FROM data_registro) THEN TRUE -- Ano ou mês divergente
        ELSE FALSE -- Datas consistentes

    END AS flag_data_inconsistente

FROM datas_convertidas
