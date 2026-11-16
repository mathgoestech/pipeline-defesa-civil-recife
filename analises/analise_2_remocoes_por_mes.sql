-- Análise 2 (complemento): quando aconteceram as remoções de famílias
SELECT
    t.ano,
    t.mes,
    t.nome_mes,
    COUNT(*) AS remocoes
FROM elt.fato_atendimento AS f
JOIN elt.dim_tipo_acao AS ta ON f.id_tipo_acao_sk = ta.id_tipo_acao_sk
JOIN elt.dim_tempo AS t ON f.id_tempo_acao_sk = t.id_tempo_sk
WHERE ta.categoria_acao = 'Remoção de famílias'
GROUP BY t.ano, t.mes, t.nome_mes
ORDER BY t.ano, t.mes;
