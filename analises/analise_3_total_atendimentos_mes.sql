-- Análise 3: consulta complementar 1
-- Retorna o número total de atendimentos realizados por mês, considerando-se apenas datas válidas:
-- 1. em cada ano entre 2022 e 2024;
-- 2. ao todo, somando-se os três anos.
SELECT t.mes,
       t.nome_mes,
       COUNT(*) FILTER (WHERE t.ano = 2022) AS atendimentos_2022,
       COUNT(*) FILTER (WHERE t.ano = 2023) AS atendimentos_2023,
       COUNT(*) FILTER (WHERE t.ano = 2024) AS atendimentos_2024,
       COUNT(*) AS atendimentos_trienio
FROM elt.fato_atendimento AS f
INNER JOIN elt.dim_tempo AS t ON f.id_tempo_registro_sk = t.id_tempo_sk
WHERE NOT f.flag_data_inconsistente AND t.ano BETWEEN 2022 AND 2024
GROUP BY t.mes, t.nome_mes
ORDER BY t.mes;
