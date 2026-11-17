-- Análise 2 (complemento): tipo de remoção (destino das famílias) e remoções no período das chuvas de 2022
SELECT
    ta.tipo_acao,
    COUNT(*) AS remocoes,
    COUNT(*) FILTER (WHERE t.data_calendario BETWEEN '2022-05-25' AND '2022-08-31') AS remocoes_chuvas_2022
FROM elt.fato_atendimento AS f
JOIN elt.dim_tipo_acao AS ta ON f.id_tipo_acao_sk = ta.id_tipo_acao_sk
JOIN elt.dim_tempo AS t ON f.id_tempo_acao_sk = t.id_tempo_sk
WHERE ta.categoria_acao = 'Remoção de famílias'
GROUP BY ta.tipo_acao
ORDER BY remocoes DESC;