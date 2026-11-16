-- Análise 2: grau de risco x tipo de ação
-- distribuição dos atendimentos de cada categoria de ação entre os graus de risco R1 a R4
-- (ficam de fora as linhas sem risco ou sem ação informados, e as 6 linhas S/R)

SELECT
    ta.categoria_acao,
    r.codigo_risco,
    r.descricao_risco,
    COUNT(*) AS atendimentos,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY ta.categoria_acao),
        1
    ) AS percentual_na_categoria
FROM elt.fato_atendimento AS f
JOIN elt.dim_tipo_acao AS ta ON f.id_tipo_acao_sk = ta.id_tipo_acao_sk
JOIN elt.dim_risco AS r ON f.id_risco_sk = r.id_risco_sk
WHERE f.id_tipo_acao_sk <> -1
  AND r.nivel_risco BETWEEN 1 AND 4
GROUP BY ta.categoria_acao, r.codigo_risco, r.descricao_risco, r.nivel_risco
ORDER BY ta.categoria_acao, r.nivel_risco;
