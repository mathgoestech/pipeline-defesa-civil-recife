{{ config(materialized='table') }}

WITH calendario AS (
    SELECT
        dia::DATE AS data_calendario
    FROM GENERATE_SERIES('{{ var("data_inicial") }}'::DATE, '{{ var("data_final") }}'::DATE, '1 day') AS serie(dia)
),

atributos AS (

    SELECT

        -- Chave sequencial ordenada começando em 1, conforme ETL
        ROW_NUMBER() OVER (ORDER BY data_calendario)::INTEGER AS id_tempo_sk,
        data_calendario,

        -- Ano e derivados semestre, trimestre, bimestre
        EXTRACT(YEAR FROM data_calendario)::INTEGER AS ano,
        (EXTRACT(MONTH FROM data_calendario)::INTEGER - 1) / 6 + 1 AS semestre,
        EXTRACT(QUARTER FROM data_calendario)::INTEGER AS trimestre,
        (EXTRACT(MONTH FROM data_calendario)::INTEGER - 1) / 2 + 1 AS bimestre,
        
        -- Mês com listagem de nomes padronizada
        EXTRACT(MONTH FROM data_calendario)::INTEGER AS mes,
        (ARRAY['janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', 'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'])[EXTRACT(MONTH FROM data_calendario)::INTEGER] AS nome_mes,
        
        -- Dia do mês e dia da semana com listagem de nomes padronizada
        EXTRACT(DAY FROM data_calendario)::INTEGER AS dia,
        (ARRAY['segunda-feira', 'terça-feira', 'quarta-feira', 'quinta-feira', 'sexta-feira', 'sábado', 'domingo'])[EXTRACT(ISODOW FROM data_calendario)::INTEGER] AS dia_semana,

        EXTRACT(ISODOW FROM data_calendario) IN (6, 7) AS fim_de_semana

    FROM calendario
),

nao_informado AS (
    SELECT
        -1 AS id_tempo_sk,
        NULL::DATE AS data_calendario,
        NULL::INTEGER AS ano,
        NULL::INTEGER AS semestre,
        NULL::INTEGER AS trimestre,
        NULL::INTEGER AS bimestre,
        NULL::INTEGER AS mes,
        'não informado' AS nome_mes,
        NULL::INTEGER AS dia,
        'não informado' AS dia_semana,
        NULL::BOOLEAN AS fim_de_semana
)

SELECT * FROM nao_informado
UNION ALL
SELECT * FROM atributos