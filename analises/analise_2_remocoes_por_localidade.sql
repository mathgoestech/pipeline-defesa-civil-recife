-- Análise 2 (complemento): onde aconteceram as remoções de famílias em 2022
SELECT 
    l.bairro,
    l.localidade,
    COUNT(*) as remocoes
FROM elt.fato_atendimento as f
JOIN elt.dim_tipo_acao as ta ON f.id_tipo_acao_sk = ta.id_tipo_acao_sk
JOIN elt.dim_localizacao AS l ON f.id_localizacao_sk = l.id_localizacao_sk
JOIN elt.dim_tempo AS t ON f.id_tempo_acao_sk = t.id_tempo_sk
WHERE ta.categoria_acao = 'Remoção de famílias'
    AND t.ano = 2022
GROUP BY l.bairro, l.localidade
ORDER BY remocoes DESC
LIMIT 10;