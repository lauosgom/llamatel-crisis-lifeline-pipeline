with source as (
    select * from {{ ref('stg_calls') }}
),

parsed as (
    select
        * except(llamante_problema, tercero_problema, codigo_letras, codigo_numero),

        -- llamante_problema: up to 3 pairs
        regexp_replace(
            trim(regexp_extract(llamante_problema, r'([A-Z]\s+\d+)')),
            r'\s+', ''
        ) as llamante_problema_1,

        regexp_replace(
            trim(regexp_extract(llamante_problema, r'[A-Z]\s+\d+\s+([A-Z]\s+\d+)')),
            r'\s+', ''
        ) as llamante_problema_2,

        regexp_replace(
            trim(regexp_extract(llamante_problema, r'[A-Z]\s+\d+\s+[A-Z]\s+\d+\s+([A-Z]\s+\d+)')),
            r'\s+', ''
        ) as llamante_problema_3,

        -- tercero_problema: up to 3 pairs
        regexp_replace(
            trim(regexp_extract(tercero_problema, r'([A-Z]\s+\d+)')),
            r'\s+', ''
        ) as tercero_problema_1,

        regexp_replace(
            trim(regexp_extract(tercero_problema, r'[A-Z]\s+\d+\s+([A-Z]\s+\d+)')),
            r'\s+', ''
        ) as tercero_problema_2,

        regexp_replace(
            trim(regexp_extract(tercero_problema, r'[A-Z]\s+\d+\s+[A-Z]\s+\d+\s+([A-Z]\s+\d+)')),
            r'\s+', ''
        ) as tercero_problema_3,

        -- combined datetime columns
        datetime(llamada_fecha, llamada_hora)       as llamada_datetime,
        datetime(entrevista_fecha, entrevista_hora) as entrevista_datetime

        -- combined codes
        concat(codigo_letras, "-" ,cast(codigo_numero as STRING)) as codigo_id,

    from source
)

select * except(llamada_fecha, llamada_hora, entrevista_fecha, entrevista_hora)
from parsed