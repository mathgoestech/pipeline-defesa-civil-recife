-- Análise 3: consulta complementar 3
-- Retorna, para cada categoria de ação e mês no período entre 2022 e 2024:
-- 1. o total de atendimentos;
-- 2. a mediana do índice mensal.
-- Consideram-se apenas datas válidas, e categorias de ação informadas e não tipificadas como "Remoção de famílias".

-- Constrói grade categorias de ação, anos e meses, considerando-se apenas atendimentos com categoria informada.
-- Foram removidas ações de remoção de famílias em face da grande concentração de atendimentos em 2022.
-- A inclusão destas comprometeria a análise dos dados, vide análise 2 e tabela no notebook da análise 3.
WITH quadro_geral AS (
    SELECT ca.categoria_acao, m.ano, m.mes
    FROM (SELECT DISTINCT categoria_acao FROM elt.dim_tipo_acao
          WHERE categoria_acao NOT IN ('não informado', 'Remoção de famílias')) AS ca
    CROSS JOIN (SELECT DISTINCT ano, mes FROM elt.dim_tempo WHERE ano BETWEEN 2022 AND 2024) AS m
),

-- Contabiliza os atendimentos de cada categoria de ação por ano e mês.
contagem AS (
    SELECT ta.categoria_acao, t.ano, t.mes, COUNT(*) AS total_atendimentos
    FROM elt.fato_atendimento AS f
    INNER JOIN elt.dim_tempo AS t ON f.id_tempo_registro_sk = t.id_tempo_sk
    INNER JOIN elt.dim_tipo_acao AS ta ON f.id_tipo_acao_sk = ta.id_tipo_acao_sk
    WHERE NOT f.flag_data_inconsistente AND t.ano BETWEEN 2022 AND 2024
    GROUP BY ta.categoria_acao, t.ano, t.mes
),

-- Calcula o índice mensal dividindo o total de atendimentos do mês pela média mensal da categoria no respectivo ano.
indice_mensal AS (
    SELECT q.categoria_acao, q.ano, q.mes,
           COALESCE(c.total_atendimentos, 0) AS total_atendimentos,
           COALESCE(c.total_atendimentos, 0) / NULLIF(AVG(COALESCE(c.total_atendimentos, 0))
                OVER (PARTITION BY q.categoria_acao, q.ano), 0) AS indice
    FROM quadro_geral AS q
    LEFT JOIN contagem AS c USING (categoria_acao, ano, mes)
)

-- Obtém a mediana do índice mensal entre os anos de 2022 a 2024 e o total mensal de atendimentos no triênio.
SELECT categoria_acao,
       mes,
       SUM(total_atendimentos) AS atendimentos_trienio,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY indice)::NUMERIC, 2) AS mediana_indice_mensal
FROM indice_mensal
GROUP BY categoria_acao, mes
ORDER BY categoria_acao, mes;
