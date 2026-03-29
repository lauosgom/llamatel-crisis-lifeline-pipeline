with lookup_table as (
    select
        campo,
        cast(codigo as STRING) as codigo,
        valor
    from {{ ref('lookup_table') }}
)

deduped as (
    select
        *,
        row_number() over (
            partition by codigo_id
            order by llamada_datetime desc
        ) as rn
    from {{ ref('int_calls_parsed') }}
),

select
    --identifiers
    codigo_numero,
    codigo_letras,
    imported_at,
    gcs_path,

    --general call info
    contacto.valor as medio_contacto,
    llamadaDerivada.valor as llamante_llamada_derivada,
    llamada_datetime,
    llamadaResultado.valor as llamada_resultado,
    llamada_duracion,
    COALESCE(llamanteProcedencia.valor, 'No lo sé') as llamante_procedencia,
    sintesis,

    --caller info
    COALESCE(llamanteSexo.valor, 'No lo sé') as llamante_sexo,
    COALESCE(llamanteEdad.valor, 'No lo sé') as llamante_edad,
    COALESCE(llamanteEstadoCivil.valor, 'No lo sé') as llamante_estado_civil,
    COALESCE(llamanteConvive.valor, 'No lo sé') as llamante_convive,
    COALESCE(llamanteAsiduidad.valor, 'No lo sé') as llamante_asiduidad,

    --caller problem
    problematicas1.problematica as llamante_problematica_1,
    problematicas1.problema as llamante_problema_1,

    problematicas2.problematica as llamante_problematica_2,
    problematicas2.problema as llamante_problema_2,

    problematicas3.problematica as llamante_problematica_3,
    problematicas3.problema as llamante_problema_3,

    naturaleza.valor as llamante_naturaleza,
    inicio.valor as llamante_inicio,
    COALESCE(peticion.valor, 'No lo sé') as llamante_peticion,

    --caller language and attitude
    actitudOrientador.valor as llamante_actitud_orientador,
    COALESCE(presentacion.valor, 'No lo sé') as llamante_presentacion,
    COALESCE(paralenguaje.valor, 'No lo sé') as llamante_paralenguaje,
    COALESCE(actitudProblema.valor, 'No lo sé') as llamante_actitud_problema,

    --third party
    terceroSexo.valor as tercero_sexo,
    terceroEdad.valor as tercero_edad,    
    terceroEstadoCivil.valor as tercero_estado_civil,
    terceroConvive.valor as tercero_convive,
    terceroRelacion.valor as tercero_relacion,

    --third party problem
    tp1.problematica as tercero_problematica_1,
    tp1.problema     as tercero_problema_1,

    tp2.problematica as tercero_problematica_2,
    tp2.problema     as tercero_problema_2,

    tp3.problematica as tercero_problematica_3,
    tp3.problema     as tercero_problema_3,

    actitudProblemaTercero.valor as tercero_actitud_problema,

    --interview info
    entrevista_clave,
    entrevista_referencia,
    entrevista_datetime,

    --orientador info
    orientador_nivel_ayuda,
    orientadorSentimientos.valor as orientador_sentimientos,
    orientadorAutoevaluacion.valor as orientador_autoevaluacion,
    orientadorActitudesEquivocadas.valor as orientador_actitudes_equivocadas,
    orientadorSatisfaccionLlamante.valor as orientador_satisfaccion_llamante


from deduped parsed
where rn = 1

--medio_contacto
left join lookup_table contacto
    on contacto.campo = 'medio_contacto'
    and contacto.codigo = parsed.medio_contacto

--llamada_derivada
left join lookup_table llamadaDerivada
    on llamadaDerivada.campo = 'llamante_llamada_derivada'
    and llamadaDerivada.codigo = parsed.llamante_llamada_derivada

--llamante_sexo
left join lookup_table llamanteSexo
    on llamanteSexo.campo = 'llamante_sexo'
    and llamanteSexo.codigo = parsed.llamante_sexo

--llamante_edad
left join lookup_table llamanteEdad
    on llamanteEdad.campo = 'llamante_edad'
    and llamanteEdad.codigo = parsed.llamante_edad

--llamante_estado_civil
left join lookup_table llamanteEstadoCivil
    on llamanteEstadoCivil.campo = 'llamante_estado_civil'
    and llamanteEstadoCivil.codigo = parsed.llamante_estado_civil

--llamante convive
left join lookup_table llamanteConvive
    on llamanteConvive.campo = 'llamante_convive'
    and llamanteConvive.codigo = parsed.llamante_convive

--llamante asiduidad
left join lookup_table llamanteAsiduidad
    on llamanteAsiduidad.campo = 'llamante_asiduidad'
    and llamanteAsiduidad.codigo = parsed.llamante_asiduidad

--llamante procedencia
left join lookup_table llamanteProcedencia
    on llamanteProcedencia.campo = 'llamante_procedencia'
    and llamanteProcedencia.codigo = parsed.llamante_procedencia

--llamada_resultado
left join lookup_table llamadaResultado
    on llamadaResultado.campo = 'llamada_resultado'
    and llamadaResultado.codigo = parsed.llamada_resultado

--problem
left join {{ref('problematica_problema')}} problematicas1
    on parsed.llamante_problema_1 = problematicas1.codigo

left join {{ref('problematica_problema')}} problematicas2
    on parsed.llamante_problema_2 = problematicas2.codigo

left join {{ref('problematica_problema')}} problematicas3
    on parsed.llamante_problema_3 = problematicas3.codigo

--naturaleza
left join lookup_table naturaleza
    on naturaleza.campo = 'llamante_naturaleza'
    and naturaleza.codigo = parsed.llamante_naturaleza

--inicio
left join lookup_table inicio
    on inicio.campo = 'llamante_inicio'
    and inicio.codigo = parsed.llamante_inicio

--peticion
left join lookup_table peticion
    on peticion.campo = 'llamante_peticion'
    and peticion.codigo = parsed.llamante_peticion

--actitud_orientador
left join lookup_table actitudOrientador
    on actitudOrientador.campo = 'llamante_actitud_orientador'
    and actitudOrientador.codigo = parsed.llamante_actitud_orientador

--presentacion
left join lookup_table presentacion
    on presentacion.campo = 'llamante_presentacion'
    and presentacion.codigo = parsed.llamante_presentacion

--llamante_paralenguaje
left join lookup_table paralenguaje
    on paralenguaje.campo = 'llamante_paralenguaje'
    and paralenguaje.codigo = parsed.llamante_paralenguaje

--llamante_actitud_problema
left join lookup_table actitudProblema
    on actitudProblema.campo = 'llamante_actitud_problema'
    and actitudProblema.codigo = parsed.llamante_actitud_problema

--tercero_sexo
left join lookup_table terceroSexo
    on terceroSexo.campo = 'llamante_sexo'
    and terceroSexo.codigo = parsed.tercero_sexo

--tercero edad
left join lookup_table terceroEdad
    on terceroEdad.campo = 'llamante_edad'
    and terceroEdad.codigo = parsed.tercero_edad

--tercero_estado_civil
left join lookup_table terceroEstadoCivil
    on terceroEstadoCivil.campo = 'llamante_estado_civil'
    and terceroEstadoCivil.codigo = parsed.tercero_estado_civil

--tercero convive
left join lookup_table terceroConvive
    on terceroConvive.campo = 'llamante_convive'
    and terceroConvive.codigo = parsed.tercero_convive

--tercero relacion
left join lookup_table terceroRelacion
    on terceroRelacion.campo = 'tercero_relacion'
    and terceroRelacion.codigo = parsed.tercero_relacion

--tercero problema
left join {{ref('problematica_problema')}} tp1
    on parsed.tercero_problema_1 = tp1.codigo

left join {{ref('problematica_problema')}} tp2
    on parsed.tercero_problema_2 = tp2.codigo

left join {{ref('problematica_problema')}} tp3
    on parsed.tercero_problema_3 = tp3.codigo

--tercero actitud problema
left join lookup_table actitudProblemaTercero
    on actitudProblemaTercero.campo = 'tercero_actitud_problema'
    and actitudProblemaTercero.codigo = parsed.tercero_actitud_problema

--interview info

--orientador sentimientos
left join lookup_table orientadorSentimientos
    on orientadorSentimientos.campo = 'orientador_sentimientos'
    and orientadorSentimientos.codigo = parsed.orientador_sentimientos

--orientador autoevaluacion
left join lookup_table orientadorAutoevaluacion
    on orientadorAutoevaluacion.campo = 'orientador_autoevaluacion'
    and orientadorAutoevaluacion.codigo = parsed.orientador_autoevaluacion

--orientador actitudes equivocadas
left join lookup_table orientadorActitudesEquivocadas
    on orientadorActitudesEquivocadas.campo = 'orientador_actitudes_equivocadas'
    and orientadorActitudesEquivocadas.codigo = parsed.orientador_actitudes_equivocadas

--orientador satisfaccion llamante
left join lookup_table orientadorSatisfaccionLlamante
    on orientadorSatisfaccionLlamante.campo = 'orientador_satisfaccion_llamante'
    and orientadorSatisfaccionLlamante.codigo = parsed.orientador_satisfaccion_llamante