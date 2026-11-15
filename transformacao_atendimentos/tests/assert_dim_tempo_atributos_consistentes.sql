-- Verifica datas com atributos dissonantes; devolve linhas não conformes
-- Passa caso nenhuma linha seja devolvida

SELECT id_tempo_sk, data_calendario
FROM {{ ref('dim_tempo') }}
WHERE id_tempo_sk <> -1 AND (
    ano IS DISTINCT FROM EXTRACT(YEAR FROM data_calendario) OR
    semestre IS DISTINCT FROM (EXTRACT(MONTH FROM data_calendario)::INTEGER  - 1 )/ 6 + 1
    OR trimestre IS DISTINCT FROM (EXTRACT(MONTH FROM data_calendario)::INTEGER - 1 ) / 3 + 1 OR
    bimestre IS DISTINCT FROM (EXTRACT(MONTH FROM data_calendario)::INTEGER - 1 ) / 2 + 1 OR
    mes IS DISTINCT FROM EXTRACT(MONTH FROM data_calendario) OR
    dia IS DISTINCT FROM EXTRACT(DAY FROM data_calendario) OR
    dia_semana IS DISTINCT FROM (ARRAY['segunda-feira', 'terça-feira', 'quarta-feira', 'quinta-feira', 'sexta-feira', 'sábado', 'domingo'])[EXTRACT(ISODOW FROM data_calendario)::INTEGER] OR
    fim_de_semana IS DISTINCT FROM (EXTRACT(ISODOW FROM data_calendario)::INTEGER - 1 IN (5, 6))
)