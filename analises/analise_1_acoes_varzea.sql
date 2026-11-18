-- Análise complementar: categorias de ação na Várzea

SELECT
    ta.categoria_acao,
    f.ano_origem AS ano,
    COUNT(DISTINCT f.id_atendimento) AS total_atendimentos

FROM elt.fato_atendimento AS f

JOIN elt.dim_localizacao AS l
    ON f.id_localizacao_sk = l.id_localizacao_sk

JOIN elt.dim_tipo_acao AS ta
    ON f.id_tipo_acao_sk = ta.id_tipo_acao_sk

WHERE l.bairro IN ('Várzea', 'Varzea') -- por segurança
  AND f.ano_origem IN ('2022', '2023', '2024')

GROUP BY
    ta.categoria_acao,
    f.ano_origem

ORDER BY
    ta.categoria_acao,
    f.ano_origem;