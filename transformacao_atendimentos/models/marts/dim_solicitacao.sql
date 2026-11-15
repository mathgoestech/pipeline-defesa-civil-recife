{{ config(materialized='table') }}

-- Uma linha por combinação (ocorrencia, solicitacao) observada nos atendimentos.
-- id_solicitacao = 0 é o membro "tudo desconhecido". COLLATE "C" faz a ordenação
-- bater com a do ETL (ordem de código de caractere), então os ids coincidem.
WITH combinacoes AS (
    SELECT DISTINCT
        ocorrencia_padrao  AS ocorrencia,
        solicitacao_padrao AS solicitacao,
        grupo_solicitacao
    FROM {{ ref('int_atendimentos_solicitacao') }}
)

SELECT
    (ROW_NUMBER() OVER (
        ORDER BY
            (ocorrencia <> 'Sem ocorrência registrada' OR solicitacao <> 'Não informada'),
            ocorrencia COLLATE "C",
            solicitacao COLLATE "C"
    ) - 1)::INTEGER AS id_solicitacao,
    ocorrencia,
    solicitacao,
    grupo_solicitacao
FROM combinacoes