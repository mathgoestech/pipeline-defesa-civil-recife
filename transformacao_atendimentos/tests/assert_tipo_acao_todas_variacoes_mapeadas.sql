-- garante que toda variação de tipo_acao da base existe na tabela de-para;
-- se aparecer uma escrita nova (por exemplo, numa base de outro ano), o teste falha
-- e lista as variações que precisam ser incluídas no seed

SELECT DISTINCT
    m.tipo_acao AS tipo_acao_original
FROM {{ ref('int_atendimentos_medidas') }} AS m
LEFT JOIN {{ ref('de_para_tipo_acao') }} AS dp
    ON RTRIM(
           REGEXP_REPLACE(
               REGEXP_REPLACE(LOWER(BTRIM(m.tipo_acao)), '\s+', ' ', 'g'),
               '\s*\(', ' (', 'g'
           ),
           ':'
       ) = dp.chave
WHERE m.tipo_acao IS NOT NULL
  AND dp.chave IS NULL
