{{ config(materialized='view') }}

-- padroniza tipo_acao e grau_risco, as colunas usadas pela dim_tipo_acao e pela dim_risco

WITH chaves AS (
    SELECT
        *,

        -- chave de comparação do tipo de ação: minúsculas, sem espaços sobrando,
        -- com espaço antes de "(" e sem ":" no final
        RTRIM(
            REGEXP_REPLACE(
                REGEXP_REPLACE(LOWER(BTRIM(tipo_acao)), '\s+', ' ', 'g'),
                '\s*\(', ' (', 'g'
            ),
            ':'
        ) AS chave_tipo_acao,

        -- chave de comparação do grau de risco: maiúsculas e sem nenhum espaço
        REGEXP_REPLACE(UPPER(grau_risco), '\s', '', 'g') AS chave_grau_risco

    FROM {{ ref('int_atendimentos_medidas') }}
)

SELECT
    c.regional,
    c.ano,
    c.mes,
    c.data_registro,
    c.ocorrencia,
    c.solicitacao,
    c.endereco,
    c.bairro,
    c.localidade,

    -- grau de risco padronizado no código R1 a R4 ou S/R; o que não é um código válido vira nulo
    CASE
        WHEN c.chave_grau_risco IN ('R1', 'R2', 'R3', 'R4', 'S/R') THEN c.chave_grau_risco
        WHEN c.chave_grau_risco = 'R3RCC' THEN 'R3' -- 44 linhas de 2022 com "R3 RCC"
        ELSE NULL -- vazios e códigos inválidos: RCC, R, R$
    END AS grau_risco,

    c.data_acao,

    -- nome padronizado do tipo de ação, vindo da tabela de-para (seed)
    dp.tipo_acao,
    dp.categoria_acao,

    c.quantidade,
    c.altura,
    c.largura,
    c.area_m,
    c.ano_origem,
    c.flag_area_divergente

FROM chaves AS c
LEFT JOIN {{ ref('de_para_tipo_acao') }} AS dp
    ON c.chave_tipo_acao = dp.chave
