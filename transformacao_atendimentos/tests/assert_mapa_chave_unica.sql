-- falha se o mapa tiver a mesma (tipo, chave) duas vezes
SELECT tipo, chave, COUNT(*) AS n
FROM {{ ref('mapa_solicitacao') }}
GROUP BY tipo, chave
HAVING COUNT(*) > 1