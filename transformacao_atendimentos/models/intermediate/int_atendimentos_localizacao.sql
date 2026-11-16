{{ config(materialized='view') }}

WITH textos_padronizados AS (

    SELECT
        id_atendimento,
        regional,
        ano,
        mes,
        data_registro,
        ocorrencia,
        solicitacao,
        endereco,
        bairro,
        localidade,
        grau_risco,
        data_acao,
        tipo_acao,
        quantidade,
        altura,
        largura,
        area_m,
        ano_origem,
        flag_area_divergente,

        INITCAP(REGEXP_REPLACE(BTRIM(regional), '\s+', ' ', 'g'))
            AS regional_tratada,

        INITCAP(REGEXP_REPLACE(BTRIM(bairro), '\s+', ' ', 'g'))
            AS bairro_tratado,

        INITCAP(REGEXP_REPLACE(BTRIM(localidade), '\s+', ' ', 'g'))
            AS localidade_tratada

    FROM {{ ref('int_atendimentos_deduplicados') }}
),

valores_invalidos AS (

    SELECT
        *,

        CASE
            WHEN regional_tratada IS NULL
                 OR UPPER(regional_tratada) IN ('', 'NA', 'NÃO INFORMADO', 'NAO INFORMADO')
                THEN NULL
            ELSE regional_tratada
        END AS regional_limpa,

        CASE
            WHEN bairro_tratado IS NULL
                 OR UPPER(bairro_tratado) IN (
                     '', 'NA', 'NAO INFORMADO',
                     'SEM BAIRRO', 'BAIRRO NAO CADASTRADO'
                 )
                THEN NULL
            ELSE bairro_tratado
        END AS bairro_limpo,

        CASE
            WHEN localidade_tratada IS NULL
                 OR UPPER(localidade_tratada) IN (
                     '', 'NA', 'T', 'SEM LOCALIDADE',
                     'NAO CADASTRADA', 'NAO INFORMADA',
                     'LOCALIDADE NAO CADASTRADA'
                 )
                THEN NULL
            ELSE localidade_tratada
        END AS localidade_limpa

    FROM textos_padronizados
),

localidades_corrigidas AS (

    SELECT
        *,

        CASE
            WHEN localidade_limpa = 'Altoda Bela Vista'
                THEN 'Alto Da Bela Vista'
            WHEN localidade_limpa = 'Alto Bela Vista'
                THEN 'Alto Da Bela Vista'
            WHEN localidade_limpa = 'Alto Do Cruzero'
                THEN 'Alto Do Cruzeiro'
            WHEN localidade_limpa = 'Alto Resplendor'
                THEN 'Alto Do Resplendor'
            WHEN localidade_limpa = 'Alto Dr. Caete'
                THEN 'Alto Dr. Caetes'
            WHEN localidade_limpa = 'Vila Do Milagres'
                THEN 'Vila Dos Milagres'
            ELSE REGEXP_REPLACE(
                REGEXP_REPLACE(
                    localidade_limpa,
                    '^Cgo\.\s*', 'Corrego ', 'i'
                ),
                '^Jd\.\s*', 'Jardim ', 'i'
            )
        END AS localidade_corrigida

    FROM valores_invalidos
),

chaves_localizacao AS (

    SELECT
        a.*,

        UPPER(public.unaccent(a.bairro_limpo)) AS chave_bairro,

        UPPER(public.unaccent(a.localidade_corrigida))
            AS chave_localidade

    FROM localidades_corrigidas AS a
),

bairros_corrigidos AS (

    SELECT
        a.*,

        COALESCE(
            dp.bairro_padronizado,
            REGEXP_REPLACE(
                a.bairro_limpo,
                '^Jd\.\s*', 'Jardim ', 'i'
            )
        ) AS bairro_corrigido

    FROM chaves_localizacao AS a

    LEFT JOIN {{ ref('de_para_bairro') }} AS dp
        ON a.chave_bairro =
           UPPER(public.unaccent(BTRIM(dp.bairro_original)))
),

contagem_regionais AS (

    SELECT
        bairro_corrigido,
        localidade_corrigida,
        regional_limpa,
        COUNT(*) AS quantidade

    FROM bairros_corrigidos

    WHERE regional_limpa IS NOT NULL
      AND bairro_corrigido IS NOT NULL
      AND localidade_corrigida IS NOT NULL

    GROUP BY
        bairro_corrigido,
        localidade_corrigida,
        regional_limpa
),

regionais_mais_frequentes AS (

    SELECT
        bairro_corrigido,
        localidade_corrigida,
        regional_limpa,

        ROW_NUMBER() OVER (
            PARTITION BY
                bairro_corrigido,
                localidade_corrigida
            ORDER BY quantidade DESC, regional_limpa
        ) AS posicao

    FROM contagem_regionais
)

SELECT
    a.id_atendimento,
    COALESCE(a.regional_limpa, r.regional_limpa) AS regional,
    a.ano,
    a.mes,
    a.data_registro,
    a.ocorrencia,
    a.solicitacao,
    a.endereco,
    a.bairro_corrigido AS bairro,
    a.localidade_corrigida AS localidade,
    a.grau_risco,
    a.data_acao,
    a.tipo_acao,
    a.quantidade,
    a.altura,
    a.largura,
    a.area_m,
    a.ano_origem,
    a.flag_area_divergente

FROM bairros_corrigidos AS a

LEFT JOIN regionais_mais_frequentes AS r
    ON a.bairro_corrigido = r.bairro_corrigido
   AND a.localidade_corrigida = r.localidade_corrigida
   AND r.posicao = 1