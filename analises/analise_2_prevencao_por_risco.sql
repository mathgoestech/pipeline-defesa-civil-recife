-- Análise 2 (complemento): composição das ações dentro de cada grau de risco
SELECT
    r.codigo_risco,
    ta.categoria_acao,
    COUNT(*) AS atendimentos,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY r.codigo_risco), 1) AS percentual_no_risco
FROM elt.fato_atendimento AS f
JOIN elt.dim_tipo_acao AS ta ON f.id_tipo_acao_sk = ta.id_tipo_acao_sk
JOIN elt.dim_risco AS r ON f.id_risco_sk = r.id_risco_sk
WHERE f.id_tipo_acao_sk <> -1
  AND r.nivel_risco BETWEEN 1 AND 4
GROUP BY r.codigo_risco, r.nivel_risco, ta.categoria_acao
ORDER BY r.nivel_risco, atendimentos DESC;