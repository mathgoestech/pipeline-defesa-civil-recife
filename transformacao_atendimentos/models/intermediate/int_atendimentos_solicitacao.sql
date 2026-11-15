{{ config(materialized='view') }}

-- Padroniza ocorrencia e solicitacao.
-- A base de 2022 perdeu os caracteres acentuados na origem ("Imóveis" virou "Imveis"),
-- então não dá para "consertar" a codificação. A chave de comparação descarta tudo que
-- não é ASCII e ignora caixa/espaços; o nome correto vem do seed mapa_solicitacao.
WITH com_chave AS (
    SELECT
        *,
        NULLIF(BTRIM(REGEXP_REPLACE(REGEXP_REPLACE(LOWER(ocorrencia), '[^ -~]', '', 'g'), '\s+', ' ', 'g')), '') AS chave_ocorrencia,
        NULLIF(BTRIM(REGEXP_REPLACE(REGEXP_REPLACE(LOWER(solicitacao), '[^ -~]', '', 'g'), '\s+', ' ', 'g')), '') AS chave_solicitacao
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
    c.grau_risco,
    c.data_acao,
    c.tipo_acao,
    c.quantidade,
    c.altura,
    c.largura,
    c.area_m,
    c.ano_origem,
    c.flag_area_divergente,

    COALESCE(mo.valor_padrao, 'Sem ocorrência registrada') AS ocorrencia_padrao,
    COALESCE(ms.valor_padrao, 'Não informada')              AS solicitacao_padrao,
    COALESCE(NULLIF(ms.grupo, ''), 'Não informada')         AS grupo_solicitacao

FROM com_chave AS c
LEFT JOIN {{ ref('mapa_solicitacao') }} AS mo
    ON mo.tipo = 'ocorrencia'  AND mo.chave = c.chave_ocorrencia
LEFT JOIN {{ ref('mapa_solicitacao') }} AS ms
    ON ms.tipo = 'solicitacao' AND ms.chave = c.chave_solicitacao