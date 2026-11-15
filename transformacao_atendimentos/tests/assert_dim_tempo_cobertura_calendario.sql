-- Verifica se data é coberta pelo calendário; devolve linhas não contempladas
-- Passa caso nenhuma linha seja devolvida

WITH panorama_calendario AS (

    SELECT

        COUNT(*) FILTER (WHERE id_tempo_sk = -1) AS total_nao_informado,
        COUNT(data_calendario) AS total_datas,
        MIN(data_calendario) AS data_inicio,
        MAX(data_calendario) AS data_fim

    FROM {{ ref('dim_tempo') }}
)

SELECT *
FROM panorama_calendario
WHERE total_nao_informado <> 1
    OR total_datas <> (DATE '{{ var("data_final") }}' - DATE '{{ var("data_inicial") }}' + 1)
    OR data_inicio <> DATE '{{ var("data_inicial") }}'
    OR data_fim <> DATE '{{ var("data_final") }}'
    