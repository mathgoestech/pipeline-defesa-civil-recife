{{ config(materialized='table') }}

-- Uma linha por combinação (ocorrencia, solicitacao) observada nos atendimentos.
-- id_solicitacao = 0 é o membro "tudo desconhecido". COLLATE "C" faz a ordenação
-- bater com a do ETL (ordem de código de caractere), então os ids coincidem.

WITH combinacoes AS (
    SELECT DISTINCT
        ocorrencia_padrao AS ocorrencia,
        solicitacao_padrao AS solicitacao,
        grupo_solicitacao
    FROM {{ ref('int_atendimentos_solicitacao') }}
)

SELECT
    CASE
        WHEN ocorrencia = 'Sem ocorrência registrada'
         AND solicitacao = 'Não informada'
            THEN -1

        ELSE ROW_NUMBER() OVER (
            ORDER BY
                (
                    ocorrencia = 'Sem ocorrência registrada'
                    AND solicitacao = 'Não informada'
                ) DESC,
                ocorrencia COLLATE "C",
                solicitacao COLLATE "C"
        )::INTEGER
    END AS id_solicitacao_sk,

    ocorrencia,
    solicitacao,
    grupo_solicitacao

FROM combinacoes