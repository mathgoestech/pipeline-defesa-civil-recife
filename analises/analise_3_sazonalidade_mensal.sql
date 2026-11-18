-- Análise 3: consulta geral
-- Analisa o padrão de sazonalidade de atendimentos da defesa civil entre os anos de 2022 a 2024, considerando apenas dados consistentes.
-- Extraem-se:
-- 1. o índice mensal de atendimentos;
-- 2. a média e a mediana do índice mensal entre os três anos;
-- 3. o coeficiente de variação, a posição pela média e pela mediana, e a classificação pela mediana em demanda e estabilidade de cada mês entre os três anos.

-- Obtém o total de atendimentos a partir da junção da tabela fato com a dimensão de tempo e agrupa-os por mês e por ano.
WITH atendimentos_mensais AS (
    SELECT t.ano, t.mes, t.nome_mes, COUNT(*) AS total_atendimentos
    FROM elt.fato_atendimento AS f
    INNER JOIN elt.dim_tempo AS t ON f.id_tempo_registro_sk = t.id_tempo_sk
    WHERE NOT f.flag_data_inconsistente AND t.ano BETWEEN 2022 AND 2024
    GROUP BY t.ano, t.mes, t.nome_mes
),

-- Calcula o índice mensal pela divisão do total de atendimentos do mês pela média mensal do respectivo ano.
indice_mensal AS (
    SELECT *, total_atendimentos / AVG(total_atendimentos) OVER (PARTITION BY ano) AS indice
    FROM atendimentos_mensais
),

-- (1) Seleciona mês e respectivo nome;
-- (2) Calcula o índice do mês para cada ano;
-- (3) Calcula a média do índice do mês computando-se os três anos;
-- (4) Calcula a mediana do índice do mês entre os três anos;
-- (5) Calcula o coeficiente de variação do índice do mês entre os três anos.
dados_mensais AS (
    SELECT
       mes,
       nome_mes,
       MAX(CASE WHEN ano = 2022 THEN indice END) AS indice_2022,
       MAX(CASE WHEN ano = 2023 THEN indice END) AS indice_2023,
       MAX(CASE WHEN ano = 2024 THEN indice END) AS indice_2024,
       AVG(indice) AS indice_medio_mensal,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY indice)::NUMERIC AS mediana_indice_mensal,
       STDDEV_SAMP(indice) / AVG(indice) AS cv_mensal
    FROM indice_mensal
    GROUP BY mes, nome_mes
)

-- (1) Arredonda dados mensais calculados;
-- (2) Calcula a posição do mês em relação aos demais, considerando o índice médio mensal;
-- (3) Calcula a posição do mês em relação aos demais, considerando a mediana do índice mensal;
-- (4) Classifica o mês em relação à demanda (mediana do índice mensal) e à estabilidade (coeficiente de variação).
SELECT mes,
       nome_mes,
       ROUND(indice_2022, 2) AS indice_2022,
       ROUND(indice_2023, 2) AS indice_2023,
       ROUND(indice_2024, 2) AS indice_2024,
       ROUND(indice_medio_mensal, 2) AS indice_medio_mensal,
       ROUND(mediana_indice_mensal, 2) AS mediana_indice_mensal,
       ROUND(cv_mensal, 2) AS cv_mensal,
       RANK() OVER (ORDER BY indice_medio_mensal DESC) AS posicao_media,
       RANK() OVER (ORDER BY mediana_indice_mensal DESC) AS posicao_mediana,
       CASE
            WHEN mediana_indice_mensal >= 1.2 THEN 'alta'
            WHEN mediana_indice_mensal <= 0.8 THEN 'baixa'
            ELSE 'média'
        END || ' demanda, ' ||
        CASE WHEN cv_mensal > 0.15 THEN 'instável' ELSE 'estável' END AS classificacao_mediana
FROM dados_mensais
ORDER BY mes;
