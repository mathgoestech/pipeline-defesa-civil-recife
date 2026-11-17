-- Análise 2 (complemento): atendimentos em áreas R4 por mês em 2022
SELECT
    t.mes,
    t.nome_mes,
    COUNT(*) FILTER (WHERE r.codigo_risco = 'R4') AS atendimentos_r4
FROM elt.fato_atendimento AS f
JOIN elt.dim_risco AS r ON f.id_risco_sk = r.id_risco_sk
JOIN elt.dim_tempo AS t ON f.id_tempo_acao_sk = t.id_tempo_sk
WHERE t.ano = 2022
GROUP BY t.mes, t.nome_mes
ORDER BY t.mes;