-- Teste para verificar se a chave é gerada conforme a data no calendário; devolve linhas não conformes
-- Passa caso nenhuma linha seja devolvida
SELECT id_tempo_sk, data_calendario
FROM {{ ref('dim_tempo') }}
WHERE id_tempo_sk IS DISTINCT FROM data_calendario - DATE '{{ var("data_inicial") }}' + 1 AND id_tempo_sk <> -1