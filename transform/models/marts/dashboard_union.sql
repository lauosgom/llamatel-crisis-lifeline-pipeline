with orientador_data as (
    select
        co.codigo_orientador,
        co.nombre_orientador as name_orientador
    from {{ ref('codigo_orientador') }} co
),

llamatel as (
    select
        -- identifiers
        codigo_id,
        CAST(null AS STRING) as document_id,
        CAST(null AS STRING) as orientador_uid,

        -- timestamps
        CAST(null AS TIMESTAMP) as created_at,
        CAST(null AS TIMESTAMP) as last_updated,
        imported_at,
        gcs_path,

        -- general call info
        medio_contacto,
        CAST(null AS STRING) as como_conocio,
        llamante_llamada_derivada,
        llamada_datetime,
        llamada_resultado,
        CAST({{ categorize_duracion('llamada_duracion') }} AS STRING) as llamada_duracion,
        sintesis,

        -- caller info
        llamante_sexo,
        llamante_edad,
        llamante_estado_civil,
        llamante_convive,
        llamante_asiduidad,
        llamante_procedencia,
        CAST(null AS STRING) as llamante_condicion,

        -- caller problem
        llamante_problematica_1,
        llamante_problema_1,
        llamante_problematica_2,
        llamante_problema_2,
        llamante_problematica_3,
        llamante_problema_3,
        llamante_naturaleza,
        llamante_inicio,
        llamante_peticion,

        -- caller language and attitude
        llamante_actitud_orientador,
        llamante_presentacion,
        llamante_paralenguaje,
        llamante_actitud_problema_1,
        llamante_actitud_problema_2,

        -- third party info
        tercero_sexo,
        tercero_edad,
        tercero_estado_civil,
        tercero_convive,
        tercero_relacion,

        -- third party problem
        tercero_problematica_1,
        tercero_problema_1,
        tercero_problematica_2,
        tercero_problema_2,
        tercero_problematica_3,
        tercero_problema_3,
        tercero_actitud_problema_1,
        tercero_actitud_problema_2,

        -- interview info
        entrevista_clave,
        entrevista_referencia,
        entrevista_datetime,

        -- orientador info
        orientador_clave,
        ori.name_orientador as orientador,
        

        -- orientador perception
        orientador_nivel_ayuda_1,
        orientador_nivel_ayuda_2,
        orientador_sentimientos_1,
        orientador_sentimientos_2,
        orientador_sentimientos_3,
        orientador_autoevaluacion,
        orientador_actitudes_equivocadas_1,
        orientador_actitudes_equivocadas_2,
        orientador_satisfaccion_llamante_1,
        orientador_satisfaccion_llamante_2,
        CAST(null AS STRING) as orientador_volvera_llamar,

        source

    from {{ ref('dashboard_calls') }} calls
    
    left join orientador_data ori
    on ori.codigo_orientador = calls.orientador_clave

),

firebase as (
    select
        -- identifiers
        CAST(null AS STRING) as codigo_id,
        document_id,
        orientador_uid,

        -- timestamps
        created_at,
        last_updated,
        CAST(null AS TIMESTAMP) as imported_at,
        CAST(null AS STRING) as gcs_path,

        -- general call info
        medio_contacto,
        como_conocio,
        llamante_llamada_derivada,
        llamada_datetime,
        llamada_resultado,
        llamada_duracion,
        sintesis,

        -- caller info
        llamante_sexo,
        llamante_edad,
        llamante_estado_civil,
        llamante_convive,
        llamante_asiduidad,
        llamante_procedencia,
        llamante_condicion,

        -- caller problem
        llamante_problematica_1,
        llamante_problema_1,
        llamante_problematica_2,
        llamante_problema_2,
        llamante_problematica_3,
        llamante_problema_3,
        llamante_naturaleza,
        llamante_inicio,
        llamante_peticion,

        -- caller language and attitude
        llamante_actitud_orientador,
        llamante_presentacion,
        llamante_paralenguaje,
        llamante_actitud_problema_1,
        llamante_actitud_problema_2,

        -- third party info
        tercero_sexo,
        tercero_edad,
        tercero_estado_civil,
        tercero_convive,
        tercero_relacion,

        -- third party problem
        tercero_problematica_1,
        tercero_problema_1,
        tercero_problematica_2,
        tercero_problema_2,
        tercero_problematica_3,
        tercero_problema_3,
        tercero_actitud_problema_1,
        tercero_actitud_problema_2,

        -- interview info (not in firebase)
        CAST(null AS STRING) as entrevista_clave,
        CAST(null AS STRING) as entrevista_referencia,
        CAST(null AS DATETIME) as entrevista_datetime,

        -- orientador info
        src.orientador,
        src.orientador_clave,

        -- orientador perception
        orientador_nivel_ayuda_1,
        orientador_nivel_ayuda_2,
        orientador_sentimientos_1,
        orientador_sentimientos_2,
        orientador_sentimientos_3,
        orientador_autoevaluacion,
        orientador_actitudes_equivocadas_1,
        orientador_actitudes_equivocadas_2,
        orientador_satisfaccion_llamante_1,
        orientador_satisfaccion_llamante_2,
        orientador_volvera_llamar,

        source

    from {{ ref('int_calls_firebase_codes') }} src
)

select * from llamatel
union all
select * from firebase