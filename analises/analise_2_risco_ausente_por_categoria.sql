-- Análise 2 (complemento): percentual de atendimentos sem grau de risco em cada categoria
SELECT
    ta.categoria_acao,
    COUNT(*) AS atendimentos,
    ROUND(100.0 * COUNT(*) FILTER (WHERE f.id_risco_sk = -1) / COUNT(*), 1) AS percentual_sem_risco
FROM elt.fato_atendimento AS f
JOIN elt.dim_tipo_acao AS ta ON f.id_tipo_acao_sk = ta.id_tipo_acao_sk
WHERE f.id_tipo_acao_sk <> -1
GROUP BY ta.categoria_acao
ORDER BY percentual_sem_risco DESC;