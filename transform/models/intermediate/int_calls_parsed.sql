with source as (
    select * from {{ ref('stg_calls') }}
),

parsed as (
    select
        *, 

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
        datetime(entrevista_fecha, entrevista_hora) as entrevista_datetime,

        -- combined codes
	    concat(codigo_letras, '-', cast(codigo_numero as STRING)) as codigo_id,

        --combine orientador_clave_letras and orientador_clave_numero into orientador_clave
        concat(orientador_clave_letras, '-', cast(orientador_clave_numero as STRING)) as orientador_clave,

        --split llamante_actitud_problema by space into two separate columns
        split(llamante_actitud_problema, ' ')[safe_offset(0)] as llamante_actitud_problema_1,
        split(llamante_actitud_problema, ' ')[safe_offset(1)] as llamante_actitud_problema_2,

        --split tercero_actitud_problema by space into two separate columns
        split(tercero_actitud_problema, ' ')[safe_offset(0)] as tercero_actitud_problema_1,
        split(tercero_actitud_problema, ' ')[safe_offset(1)] as tercero_actitud_problema_2,

        -- split orientador_nivel_ayuda by space
        split(orientador_nivel_ayuda, ' ')[safe_offset(0)] as orientador_nivel_ayuda_1,
        split(orientador_nivel_ayuda, ' ')[safe_offset(1)] as orientador_nivel_ayuda_2,

        --split orientador_sentimientos by space into two separate columns
        split(orientador_sentimientos, ' ')[safe_offset(0)] as orientador_sentimientos_1,
        split(orientador_sentimientos, ' ')[safe_offset(1)] as orientador_sentimientos_2,

        --split orientador_actitudes_equivocadas by space into two separate columns
        split(orientador_actitudes_equivocadas, ' ')[safe_offset(0)] as orientador_actitudes_equivocadas_1,
        split(orientador_actitudes_equivocadas, ' ')[safe_offset(1)] as orientador_actitudes_equivocadas_2,

        --split orientador_satisfaccion_llamante by space into two separate columns
        split(orientador_satisfaccion_llamante, ' ')[safe_offset(0)] as orientador_satisfaccion_llamante_1,
        split(orientador_satisfaccion_llamante, ' ')[safe_offset(1)] as orientador_satisfaccion_llamante_2

        --

    from source
)

select * except(llamante_problema, tercero_problema, codigo_letras, codigo_numero, llamada_fecha, llamada_hora, entrevista_fecha, entrevista_hora, orientador_clave_letras, orientador_clave_numero, llamante_actitud_problema, tercero_actitud_problema, orientador_nivel_ayuda, orientador_sentimientos, orientador_actitudes_equivocadas, orientador_satisfaccion_llamante),
from parsed
