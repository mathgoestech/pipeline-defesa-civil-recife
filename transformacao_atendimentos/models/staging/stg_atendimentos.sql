-- correção da base de 2022, que chega com colunas desalinhadas e sem a "Regional"
WITH base_corrigida_2022 AS (
    SELECT
        -- cria a coluna "Regional" com valor nulo, e as demais recebem o valor da anterior
        CAST(NULL AS TEXT) AS "Regional",
        "Regional" AS "Ano",
        "Ano" AS "Mês",
        "Mês" AS "Data",
        "Data" AS "Ocorrencia",
        "Ocorrencia" AS "Solicitacao",
        -- concatena a rua e o número com uma vírgula entre eles, e também remove as aspas
        CONCAT(
            LTRIM("Solicitacao", '"'),
            ',',
            RTRIM("Endereco", '"')
        ) AS "Endereco",
        -- a partir daqui, as colunas já estão alinhadas com as outras bases
        "Bairro",
        "Localidade",
        "Grau_de_Risco",
        "Data_da_Acao",
        "Tipo_da_Acao",
        "Quantidade",
        "Altura",
        "Largura",
        "Area_m"
    FROM {{ source('raw', 'raw_atendimentos_2022') }}
),

-- consolidação das 3 bases, identificando a origem de cada linha
bases_consolidadas AS (
    SELECT 
        *,
        '2022' AS ano_origem
    FROM base_corrigida_2022
    
    UNION ALL
    
    SELECT 
        *,
        '2023' AS ano_origem
    FROM {{ source('raw', 'raw_atendimentos_2023') }}
    
    UNION ALL
    
    SELECT
        *,
        '2024' AS ano_origem
    FROM {{ source('raw', 'raw_atendimentos_2024') }}
)

-- renomeação das colunas para o padrão do projeto
SELECT
    "Regional" AS regional,
    "Ano" AS ano,
    "Mês" AS mes,
    "Data" AS data_registro,
    "Ocorrencia" AS ocorrencia,
    "Solicitacao" AS solicitacao,
    "Endereco" AS endereco,
    "Bairro" AS bairro,
    "Localidade" AS localidade,
    "Grau_de_Risco" AS grau_risco,
    "Data_da_Acao" AS data_acao,
    "Tipo_da_Acao" AS tipo_acao,
    "Quantidade" AS quantidade,
    "Altura" AS altura,
    "Largura" AS largura,
    "Area_m" AS area_m,
    ano_origem
FROM bases_consolidadas
