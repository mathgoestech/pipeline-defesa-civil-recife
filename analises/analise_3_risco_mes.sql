-- Análise 3: consulta complementar 2
-- Obtém, para cada mês, por ano e em todo o triênio:
-- 1. o percentual de atendimentos classificados como sem risco ou cujo risco não foi informado;
-- 2. o percentual dos atendimentos com gravidade R3 e R4;
-- 3. o número de atendimentos de grau R4.
-- Consideram-se apenas datas válidas e, para as porcentagens de risco R3 e R4, apenas os atendimentos com grau de risco informado.
-- Em face da ausência do grau de risco na base de dados em novembro e dezembro de 2024, foi-lhes atribuído valor NULL nas porcentagens e nos valores.
SELECT t.mes,
       t.nome_mes,
       COUNT(*) AS total_atendimentos,

       ROUND(100.0 * COUNT(*) FILTER (WHERE r.nivel_risco IS NULL OR r.nivel_risco NOT BETWEEN 1 AND 4)
             / COUNT(*), 1) AS pct_risco_nao_informado,
       ROUND(100.0 * COUNT(*) FILTER (WHERE (r.nivel_risco IS NULL OR r.nivel_risco NOT BETWEEN 1 AND 4) AND t.ano = 2022)
             / NULLIF(COUNT(*) FILTER (WHERE t.ano = 2022), 0), 1) AS pct_risco_nao_informado_2022,
       ROUND(100.0 * COUNT(*) FILTER (WHERE (r.nivel_risco IS NULL OR r.nivel_risco NOT BETWEEN 1 AND 4) AND t.ano = 2023)
             / NULLIF(COUNT(*) FILTER (WHERE t.ano = 2023), 0), 1) AS pct_risco_nao_informado_2023,
       ROUND(100.0 * COUNT(*) FILTER (WHERE (r.nivel_risco IS NULL OR r.nivel_risco NOT BETWEEN 1 AND 4) AND t.ano = 2024)
             / NULLIF(COUNT(*) FILTER (WHERE t.ano = 2024), 0), 1) AS pct_risco_nao_informado_2024,

       ROUND(100.0 * COUNT(*) FILTER (WHERE r.nivel_risco >= 3)
             / NULLIF(COUNT(*) FILTER (WHERE r.nivel_risco BETWEEN 1 AND 4), 0), 1) AS pct_risco_r3_r4,
       ROUND(100.0 * COUNT(*) FILTER (WHERE r.nivel_risco >= 3 AND t.ano = 2022)
             / NULLIF(COUNT(*) FILTER (WHERE r.nivel_risco BETWEEN 1 AND 4 AND t.ano = 2022), 0), 1) AS pct_risco_r3_r4_2022,
       ROUND(100.0 * COUNT(*) FILTER (WHERE r.nivel_risco >= 3 AND t.ano = 2023)
             / NULLIF(COUNT(*) FILTER (WHERE r.nivel_risco BETWEEN 1 AND 4 AND t.ano = 2023), 0), 1) AS pct_risco_r3_r4_2023,
       ROUND(100.0 * COUNT(*) FILTER (WHERE r.nivel_risco >= 3 AND t.ano = 2024)
             / NULLIF(COUNT(*) FILTER (WHERE r.nivel_risco BETWEEN 1 AND 4 AND t.ano = 2024), 0), 1) AS pct_risco_r3_r4_2024,

       CASE WHEN COUNT(*) FILTER (WHERE r.nivel_risco BETWEEN 1 AND 4) > 0
            THEN COUNT(*) FILTER (WHERE r.nivel_risco = 4) END AS atendimentos_r4,
       CASE WHEN COUNT(*) FILTER (WHERE r.nivel_risco BETWEEN 1 AND 4 AND t.ano = 2022) > 0
            THEN COUNT(*) FILTER (WHERE r.nivel_risco = 4 AND t.ano = 2022) END AS atendimentos_r4_2022,
       CASE WHEN COUNT(*) FILTER (WHERE r.nivel_risco BETWEEN 1 AND 4 AND t.ano = 2023) > 0
            THEN COUNT(*) FILTER (WHERE r.nivel_risco = 4 AND t.ano = 2023) END AS atendimentos_r4_2023,
       CASE WHEN COUNT(*) FILTER (WHERE r.nivel_risco BETWEEN 1 AND 4 AND t.ano = 2024) > 0
            THEN COUNT(*) FILTER (WHERE r.nivel_risco = 4 AND t.ano = 2024) END AS atendimentos_r4_2024

FROM elt.fato_atendimento AS f
INNER JOIN elt.dim_tempo AS t ON f.id_tempo_registro_sk = t.id_tempo_sk
LEFT JOIN elt.dim_risco AS r ON f.id_risco_sk = r.id_risco_sk
WHERE NOT f.flag_data_inconsistente AND t.ano BETWEEN 2022 AND 2024
GROUP BY t.mes, t.nome_mes
ORDER BY t.mes;
