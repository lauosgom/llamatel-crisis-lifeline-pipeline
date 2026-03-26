with parsed as (
    select * from {{ ref('int_calls_parsed') }}
),

problema as(
    select
        p.* except(llamante_problema_1),
        pp.problematica as problematica,
        pp.problema as problema_descripcion
    from parsed p
    left join {{ref('problematica_problema')}} pp
    on p.llamante_problema_1 = pp.codigo
)

select * from problema
