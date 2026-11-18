SELECT
    l.bairro,
    l.localidade,
    f.ano_origem AS ano,
    COUNT(DISTINCT f.id_atendimento) AS total_atendimentos

FROM elt.fato_atendimento AS f

JOIN elt.dim_localizacao AS l
    ON f.id_localizacao_sk = l.id_localizacao_sk

WHERE (
    l.bairro ILIKE '%%jenipapo%%'
    OR l.localidade ILIKE '%%jenipapo%%'
)
AND f.ano_origem IN ('2022', '2023', '2024')

GROUP BY
    l.bairro,
    l.localidade,
    f.ano_origem

ORDER BY
    l.bairro,
    l.localidade,
    f.ano_origem;