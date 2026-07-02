select
  -- identifiers
  L_Orientador                  as orientador,
  OrientadorUid                 as orientador_uid,
  L_ID_Llamada                  as llamada_id,
  L_Codigo_Orientador           as orientador_codigo,
  CreatedAt                     as created_at,
  document_id,
  last_updated,

  -- general call info
  L_Medio_Contacto              as medio_contacto,
  L_Como_Conoce                 as como_conocio,
  L_Llamada_Derivada            as llamante_llamada_derivada,
  L_Hora                        as llamada_hora,
  L_Fecha                       as llamada_fecha,
  L_Resultado                   as llamada_resultado,
  L_Duracion                    as llamada_duracion,
  L_Sintesis                    as sintesis,

  -- caller info
  U_Sexo                        as llamante_sexo,
  U_Edad                        as llamante_edad,
  U_Estado_Civil                as llamante_estado_civil,
  U_Convive                     as llamante_convive,
  U_Asiduidad                   as llamante_asiduidad,
  U_Procedencia                 as llamante_procedencia,
  U_Cond_Socioeconomica         as llamante_condicion,

  -- caller problem
  U_Problematica_1              as llamante_problematica_1,
  U_Problema_1                  as llamante_problema_1,
  U_Problematica_2              as llamante_problematica_2,
  U_Problema_2                  as llamante_problema_2,
  U_Problematica_3              as llamante_problematica_3,
  U_Problema_3                  as llamante_problema_3,
  U_Naturaleza                  as llamante_naturaleza,
  U_Inicio                      as llamante_inicio,
  U_Peticion                    as llamante_peticion,

  -- caller language and attitude
  U_Actitud_Orientador          as llamante_actitud_orientador,
  U_Presentacion                as llamante_presentacion,
  U_Paralenguaje                as llamante_paralenguaje,
  U_Actitud_Problema_1          as llamante_actitud_problema_1,
  U_Actitud_Problema_2          as llamante_actitud_problema_2,

  -- third party info
  T_Sexo_Tercero                as tercero_sexo,
  T_Edad_Tercero                as tercero_edad,
  T_Estado_Civil_Tercero        as tercero_estado_civil,
  T_Convive                     as tercero_convive,
  T_Relacion                    as tercero_relacion,

  -- third party problem
  T_Problematica_1              as tercero_problematica_1,
  T_Problema_1                  as tercero_problema_1,
  T_Problematica_2              as tercero_problematica_2,
  T_Problema_2                  as tercero_problema_2,
  T_Problematica_3              as tercero_problematica_3,
  T_Problema_3                  as tercero_problema_3,
  T_Actitud_Problema_1          as tercero_actitud_problema_1,
  T_Actitud_Problema_2          as tercero_actitud_problema_2,

  -- orientador info
  O_Clave                       as orientador_clave,

  -- orientador perception of call
  O_Nivel_Ayuda_1               as orientador_nivel_ayuda_1,
  O_Nivel_Ayuda_2               as orientador_nivel_ayuda_2,
  O_Sentimientos_1              as orientador_sentimientos_1,
  O_Sentimientos_2              as orientador_sentimientos_2,
  O_Sentimientos_3              as orientador_sentimientos_3,
  O_Autoevaluacion              as orientador_autoevaluacion,
  O_Actitud_Equivocada_1        as orientador_actitudes_equivocadas_1,
  O_Actitud_Equivocada_2        as orientador_actitudes_equivocadas_2,
  O_Satisfaccion_1              as orientador_satisfaccion_llamante_1,
  O_Satisfaccion_2              as orientador_satisfaccion_llamante_2,
  O_Volvera_Llamar              as orientador_volvera_llamar

from {{ source('raw_data', 'llamatel_llamadas_firebase') }}