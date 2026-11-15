{{ config(materialized='table') }}

-- classificação de risco usada pela Defesa Civil (Ministério das Cidades / IPT):
-- R1 baixo, R2 médio, R3 alto e R4 muito alto, além de S/R para sem risco

SELECT
    id_risco_sk,
    codigo_risco,
    descricao_risco,
    nivel_risco
FROM (
    VALUES
        (-1, 'não informado', 'não informado', NULL::INTEGER),
        (1, 'S/R', 'sem risco', 0),
        (2, 'R1', 'baixo', 1),
        (3, 'R2', 'médio', 2),
        (4, 'R3', 'alto', 3),
        (5, 'R4', 'muito alto', 4)
) AS classificacao (id_risco_sk, codigo_risco, descricao_risco, nivel_risco)
