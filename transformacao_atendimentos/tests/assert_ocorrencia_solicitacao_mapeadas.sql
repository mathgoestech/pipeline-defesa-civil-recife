-- falha se algum valor original preenchido não achou entrada no mapa
-- (valor novo no CSV que ninguém cadastrou em seeds/mapa_solicitacao.csv)
SELECT ocorrencia, solicitacao
FROM {{ ref('int_atendimentos_solicitacao') }}
WHERE (NULLIF(BTRIM(ocorrencia), '') IS NOT NULL AND ocorrencia_padrao = 'Sem ocorrência registrada')
   OR (NULLIF(BTRIM(solicitacao), '') IS NOT NULL AND solicitacao_padrao = 'Não informada')