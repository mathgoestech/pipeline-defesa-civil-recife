-- Análise 3: evolução dos atendimentos por bairro (2022–2024)
-- Conta os atendimentos registrados em cada bairro por ano.

SELECT
    l.bairro,
    f.ano_origem AS ano,
    COUNT(DISTINCT f.id_atendimento) AS total_atendimentos

FROM elt.fato_atendimento AS f

JOIN elt.dim_localizacao AS l
    ON f.id_localizacao_sk = l.id_localizacao_sk

WHERE f.ano_origem IN ('2022', '2023', '2024')
  AND l.bairro IS NOT NULL
  AND l.bairro <> 'não informado'

GROUP BY
    l.bairro,
    f.ano_origem

ORDER BY
    l.bairro,
    f.ano_origem;