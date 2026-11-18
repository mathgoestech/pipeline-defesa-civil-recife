-- Análise 3: consulta complementar 4
-- Contabiliza ações do tipo "Remoção de famílias" por mês em cada ano de 2022 a 2024.
-- Consideram-se apenas datas válidas.
SELECT COALESCE(t.nome_mes, 'total') AS mes,
       COUNT(f.id_atendimento) FILTER (WHERE t.ano = 2022) AS remocoes_2022,
       COUNT(f.id_atendimento) FILTER (WHERE t.ano = 2023) AS remocoes_2023,
       COUNT(f.id_atendimento) FILTER (WHERE t.ano = 2024) AS remocoes_2024,
       COUNT(f.id_atendimento) AS remocoes_trienio
FROM elt.dim_tempo AS t
LEFT JOIN elt.fato_atendimento AS f
       ON f.id_tempo_registro_sk = t.id_tempo_sk
      AND NOT f.flag_data_inconsistente
      AND f.id_tipo_acao_sk IN (SELECT id_tipo_acao_sk FROM elt.dim_tipo_acao
                                WHERE categoria_acao = 'Remoção de famílias')
WHERE t.ano BETWEEN 2022 AND 2024
GROUP BY ROLLUP ((t.mes, t.nome_mes))
ORDER BY t.mes NULLS LAST;
