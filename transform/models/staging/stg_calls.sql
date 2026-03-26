select
 --identifiers
 codigo_numero,
 codigo_letras,

 --general call info
 medio_contacto, 
 llamante_llamada_derivada, 
 llamada_hora, 
 llamada_fecha, 
 llamada_resultado, 
 llamada_duracion, 
 sintesis, 

 --caller info
 llamante_sexo, 
 llamante_edad, 
 llamante_estado_civil, 
 llamante_convive, 
 llamante_asiduidad, 
 llamante_procedencia, 
 
--caller problem
 llamante_problema, 
 llamante_naturaleza, 
 llamante_inicio, 
 llamante_peticion, 

 --caller language and attitude
 llamante_actitud_orientador, 
 llamante_presentacion, 
 llamante_paralenguaje, 
 llamante_actitud_problema, 
 
--third party info
 tercero_sexo,
 tercero_edad,
 tercero_estado_civil,
 tercero_convive,
 tercero_relacion,

--third party problem 
 tercero_problema,
 tercero_actitud_problema,

 --interview info
 entrevista_clave, -- ask how this should work
 entrevista_referencia,
 entrevista_hora,
 entrevista_fecha,
 
 --orientator info
 orientador_clave_letras, --ask how this should work
 orientador_clave_numero,

--orientator perception of call
 orientador_nivel_ayuda,
 orientador_sentimientos,
 orientador_autoevaluacion,
 orientador_actitudes_equivocadas,
 orientador_satisfaccion_llamante

from {{ source('raw_data', 'llamatel-llamadas') }}

