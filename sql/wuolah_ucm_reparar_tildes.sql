-- =====================================================================
-- WUOLAH UCM - REPARACION DE TILDES Y ENES EN DATOS DE PRUEBA
-- Compatible con SQL*Plus y Oracle 21c XE.
-- EJECUTAR SOLO CONECTADO AL ESQUEMA QUE CONTIENE LAS TABLAS WU_*.
-- No contiene DROP, CREATE ni DELETE: no elimina tablas ni registros.
-- Solo corrige valores que coinciden con errores de codificacion conocidos
-- en los textos originales de la semilla; conserva textos personalizados.
-- Si el origen del problema es la visualizacion del terminal, usar
-- ASCIISTR en las consultas finales para comprobar los datos reales.
-- =====================================================================
SET DEFINE OFF
SET FEEDBACK ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

-- WU_FACULTAD.NOMBRE
UPDATE WU_FACULTAD
   SET NOMBRE = UNISTR('Facultad de Ciencias de la Ingenier\00EDa')
 WHERE ID_FACULTAD = 1
   AND NOMBRE IN (
        UNISTR('Facultad de Ciencias de la Ingenier\00C3\00ADa'),
        UNISTR('Facultad de Ciencias de la Ingenier\251C\00A1a'),
        UNISTR('Facultad de Ciencias de la Ingenier?a'),
        UNISTR('Facultad de Ciencias de la Ingenier\FFFDa')
   );

-- WU_FACULTAD.NOMBRE
UPDATE WU_FACULTAD
   SET NOMBRE = UNISTR('Facultad de Ciencias Sociales y Econ\00F3micas')
 WHERE ID_FACULTAD = 2
   AND NOMBRE IN (
        UNISTR('Facultad de Ciencias Sociales y Econ\00C3\00B3micas'),
        UNISTR('Facultad de Ciencias Sociales y Econ\251C\2502micas'),
        UNISTR('Facultad de Ciencias Sociales y Econ?micas'),
        UNISTR('Facultad de Ciencias Sociales y Econ\FFFDmicas')
   );

-- WU_CARRERA.NOMBRE
UPDATE WU_CARRERA
   SET NOMBRE = UNISTR('Ingenier\00EDa Civil Inform\00E1tica')
 WHERE CODIGO = 'ICI'
   AND NOMBRE IN (
        UNISTR('Ingenier\00C3\00ADa Civil Inform\00C3\00A1tica'),
        UNISTR('Ingenier\251C\00A1a Civil Inform\251C\00EDtica'),
        UNISTR('Ingenier?a Civil Inform?tica'),
        UNISTR('Ingenier\FFFDa Civil Inform\FFFDtica')
   );

-- WU_CARRERA.NOMBRE
UPDATE WU_CARRERA
   SET NOMBRE = UNISTR('Ingenier\00EDa Comercial')
 WHERE CODIGO = 'ICO'
   AND NOMBRE IN (
        UNISTR('Ingenier\00C3\00ADa Comercial'),
        UNISTR('Ingenier\251C\00A1a Comercial'),
        UNISTR('Ingenier?a Comercial'),
        UNISTR('Ingenier\FFFDa Comercial')
   );

-- WU_CARRERA.NOMBRE
UPDATE WU_CARRERA
   SET NOMBRE = UNISTR('Enfermer\00EDa')
 WHERE CODIGO = 'ENF'
   AND NOMBRE IN (
        UNISTR('Enfermer\00C3\00ADa'),
        UNISTR('Enfermer\251C\00A1a'),
        UNISTR('Enfermer?a'),
        UNISTR('Enfermer\FFFDa')
   );

-- WU_PROFESOR.APELLIDO
UPDATE WU_PROFESOR
   SET APELLIDO = UNISTR('Mora N\00FA\00F1ez')
 WHERE NOMBRE = 'Claudia' AND ID_FACULTAD = 2
   AND APELLIDO IN (
        UNISTR('Mora N\00C3\00BA\00C3\00B1ez'),
        UNISTR('Mora N\251C\2551\251C\2592ez'),
        UNISTR('Mora N??ez'),
        UNISTR('Mora N\FFFD\FFFDez')
   );

-- WU_TIPO_APUNTE.NOMBRE
UPDATE WU_TIPO_APUNTE
   SET NOMBRE = UNISTR('Gu\00EDas de ejercicios')
 WHERE ID_TIPO = 2
   AND NOMBRE IN (
        UNISTR('Gu\00C3\00ADas de ejercicios'),
        UNISTR('Gu\251C\00A1as de ejercicios'),
        UNISTR('Gu?as de ejercicios'),
        UNISTR('Gu\FFFDas de ejercicios')
   );

-- WU_TIPO_APUNTE.NOMBRE
UPDATE WU_TIPO_APUNTE
   SET NOMBRE = UNISTR('Res\00FAmenes')
 WHERE ID_TIPO = 4
   AND NOMBRE IN (
        UNISTR('Res\00C3\00BAmenes'),
        UNISTR('Res\251C\2551menes'),
        UNISTR('Res?menes'),
        UNISTR('Res\FFFDmenes')
   );

-- WU_ASIGNATURA.NOMBRE
UPDATE WU_ASIGNATURA
   SET NOMBRE = UNISTR('Introducci\00F3n a la Programaci\00F3n')
 WHERE CODIGO = 'INF113'
   AND NOMBRE IN (
        UNISTR('Introducci\00C3\00B3n a la Programaci\00C3\00B3n'),
        UNISTR('Introducci\251C\2502n a la Programaci\251C\2502n'),
        UNISTR('Introducci?n a la Programaci?n'),
        UNISTR('Introducci\FFFDn a la Programaci\FFFDn')
   );

-- WU_ASIGNATURA.NOMBRE
UPDATE WU_ASIGNATURA
   SET NOMBRE = UNISTR('C\00E1lculo I')
 WHERE CODIGO = 'MAT101'
   AND NOMBRE IN (
        UNISTR('C\00C3\00A1lculo I'),
        UNISTR('C\251C\00EDlculo I'),
        UNISTR('C?lculo I'),
        UNISTR('C\FFFDlculo I')
   );

-- WU_ASIGNATURA.NOMBRE
UPDATE WU_ASIGNATURA
   SET NOMBRE = UNISTR('Microeconom\00EDa')
 WHERE CODIGO = 'ADM101'
   AND NOMBRE IN (
        UNISTR('Microeconom\00C3\00ADa'),
        UNISTR('Microeconom\251C\00A1a'),
        UNISTR('Microeconom?a'),
        UNISTR('Microeconom\FFFDa')
   );

-- WU_ASIGNATURA.NOMBRE
UPDATE WU_ASIGNATURA
   SET NOMBRE = UNISTR('Fundamentos de Enfermer\00EDa')
 WHERE CODIGO = 'ENF101'
   AND NOMBRE IN (
        UNISTR('Fundamentos de Enfermer\00C3\00ADa'),
        UNISTR('Fundamentos de Enfermer\251C\00A1a'),
        UNISTR('Fundamentos de Enfermer?a'),
        UNISTR('Fundamentos de Enfermer\FFFDa')
   );

-- WU_USUARIO.NOMBRE
UPDATE WU_USUARIO
   SET NOMBRE = UNISTR('Mat\00EDas Soto')
 WHERE CORREO = 'matias.soto@alu.ucm.cl'
   AND NOMBRE IN (
        UNISTR('Mat\00C3\00ADas Soto'),
        UNISTR('Mat\251C\00A1as Soto'),
        UNISTR('Mat?as Soto'),
        UNISTR('Mat\FFFDas Soto')
   );

-- WU_USUARIO.NOMBRE
UPDATE WU_USUARIO
   SET NOMBRE = UNISTR('Valentina P\00E9rez')
 WHERE CORREO = 'valentina.perez@alu.ucm.cl'
   AND NOMBRE IN (
        UNISTR('Valentina P\00C3\00A9rez'),
        UNISTR('Valentina P\251C\00AErez'),
        UNISTR('Valentina P\251C\2310rez'),
        UNISTR('Valentina P?rez'),
        UNISTR('Valentina P\FFFDrez')
   );

-- WU_USUARIO.NOMBRE
UPDATE WU_USUARIO
   SET NOMBRE = UNISTR('Pablo N\00FA\00F1ez')
 WHERE CORREO = 'pablo.nunez@alu.ucm.cl'
   AND NOMBRE IN (
        UNISTR('Pablo N\00C3\00BA\00C3\00B1ez'),
        UNISTR('Pablo N\251C\2551\251C\2592ez'),
        UNISTR('Pablo N??ez'),
        UNISTR('Pablo N\FFFD\FFFDez')
   );

-- WU_APUNTE.TITULO
UPDATE WU_APUNTE
   SET TITULO = UNISTR('Apuntes: Modelo Entidad-Relaci\00F3n y Normalizaci\00F3n')
 WHERE RUTA_ARCHIVO = 'uploads/seed/mer_normalizacion.pdf'
   AND TITULO IN (
        UNISTR('Apuntes: Modelo Entidad-Relaci\00C3\00B3n y Normalizaci\00C3\00B3n'),
        UNISTR('Apuntes: Modelo Entidad-Relaci\251C\2502n y Normalizaci\251C\2502n'),
        UNISTR('Apuntes: Modelo Entidad-Relaci?n y Normalizaci?n'),
        UNISTR('Apuntes: Modelo Entidad-Relaci\FFFDn y Normalizaci\FFFDn')
   );

-- WU_APUNTE.TITULO
UPDATE WU_APUNTE
   SET TITULO = UNISTR('Gu\00EDa de ejercicios PL/SQL')
 WHERE RUTA_ARCHIVO = 'uploads/seed/guia_plsql.pdf'
   AND TITULO IN (
        UNISTR('Gu\00C3\00ADa de ejercicios PL/SQL'),
        UNISTR('Gu\251C\00A1a de ejercicios PL/SQL'),
        UNISTR('Gu?a de ejercicios PL/SQL'),
        UNISTR('Gu\FFFDa de ejercicios PL/SQL')
   );

-- WU_APUNTE.DESCRIPCION
UPDATE WU_APUNTE
   SET DESCRIPCION = UNISTR('Certamen resuelto con consultas SQL y dise\00F1o de modelo.')
 WHERE RUTA_ARCHIVO = 'uploads/seed/certamen1_bd.pdf'
   AND DESCRIPCION IN (
        UNISTR('Certamen resuelto con consultas SQL y dise\00C3\00B1o de modelo.'),
        UNISTR('Certamen resuelto con consultas SQL y dise\251C\2592o de modelo.'),
        UNISTR('Certamen resuelto con consultas SQL y dise?o de modelo.'),
        UNISTR('Certamen resuelto con consultas SQL y dise\FFFDo de modelo.')
   );

-- WU_APUNTE.TITULO
UPDATE WU_APUNTE
   SET TITULO = UNISTR('Apuntes de Introducci\00F3n a la Programaci\00F3n')
 WHERE RUTA_ARCHIVO = 'uploads/seed/intro_programacion.pdf'
   AND TITULO IN (
        UNISTR('Apuntes de Introducci\00C3\00B3n a la Programaci\00C3\00B3n'),
        UNISTR('Apuntes de Introducci\251C\2502n a la Programaci\251C\2502n'),
        UNISTR('Apuntes de Introducci?n a la Programaci?n'),
        UNISTR('Apuntes de Introducci\FFFDn a la Programaci\FFFDn')
   );

-- WU_APUNTE.DESCRIPCION
UPDATE WU_APUNTE
   SET DESCRIPCION = UNISTR('Problemas con soluci\00F3n comentada.')
 WHERE RUTA_ARCHIVO = 'uploads/seed/ciclos.pdf'
   AND DESCRIPCION IN (
        UNISTR('Problemas con soluci\00C3\00B3n comentada.'),
        UNISTR('Problemas con soluci\251C\2502n comentada.'),
        UNISTR('Problemas con soluci?n comentada.'),
        UNISTR('Problemas con soluci\FFFDn comentada.')
   );

-- WU_APUNTE.TITULO
UPDATE WU_APUNTE
   SET TITULO = UNISTR('Apuntes de C\00E1lculo I: l\00EDmites y derivadas')
 WHERE RUTA_ARCHIVO = 'uploads/seed/calculo1.pdf'
   AND TITULO IN (
        UNISTR('Apuntes de C\00C3\00A1lculo I: l\00C3\00ADmites y derivadas'),
        UNISTR('Apuntes de C\251C\00EDlculo I: l\251C\00A1mites y derivadas'),
        UNISTR('Apuntes de C?lculo I: l?mites y derivadas'),
        UNISTR('Apuntes de C\FFFDlculo I: l\FFFDmites y derivadas')
   );

-- WU_APUNTE.DESCRIPCION
UPDATE WU_APUNTE
   SET DESCRIPCION = UNISTR('L\00EDmites, continuidad y reglas de derivaci\00F3n.')
 WHERE RUTA_ARCHIVO = 'uploads/seed/calculo1.pdf'
   AND DESCRIPCION IN (
        UNISTR('L\00C3\00ADmites, continuidad y reglas de derivaci\00C3\00B3n.'),
        UNISTR('L\251C\00A1mites, continuidad y reglas de derivaci\251C\2502n.'),
        UNISTR('L?mites, continuidad y reglas de derivaci?n.'),
        UNISTR('L\FFFDmites, continuidad y reglas de derivaci\FFFDn.')
   );

-- WU_APUNTE.TITULO
UPDATE WU_APUNTE
   SET TITULO = UNISTR('Gu\00EDa de derivadas e integrales')
 WHERE RUTA_ARCHIVO = 'uploads/seed/guia_derivadas.pdf'
   AND TITULO IN (
        UNISTR('Gu\00C3\00ADa de derivadas e integrales'),
        UNISTR('Gu\251C\00A1a de derivadas e integrales'),
        UNISTR('Gu?a de derivadas e integrales'),
        UNISTR('Gu\FFFDa de derivadas e integrales')
   );

-- WU_APUNTE.TITULO
UPDATE WU_APUNTE
   SET TITULO = UNISTR('Resumen de Microeconom\00EDa')
 WHERE RUTA_ARCHIVO = 'uploads/seed/microeconomia.pdf'
   AND TITULO IN (
        UNISTR('Resumen de Microeconom\00C3\00ADa'),
        UNISTR('Resumen de Microeconom\251C\00A1a'),
        UNISTR('Resumen de Microeconom?a'),
        UNISTR('Resumen de Microeconom\FFFDa')
   );

-- WU_APUNTE.TITULO
UPDATE WU_APUNTE
   SET TITULO = UNISTR('Prueba de BD sin autorizaci\00F3n')
 WHERE RUTA_ARCHIVO = 'uploads/seed/prueba_no_autorizada.pdf'
   AND TITULO IN (
        UNISTR('Prueba de BD sin autorizaci\00C3\00B3n'),
        UNISTR('Prueba de BD sin autorizaci\251C\2502n'),
        UNISTR('Prueba de BD sin autorizaci?n'),
        UNISTR('Prueba de BD sin autorizaci\FFFDn')
   );

-- WU_APUNTE.DESCRIPCION
UPDATE WU_APUNTE
   SET DESCRIPCION = UNISTR('Material que no deb\00EDa circular.')
 WHERE RUTA_ARCHIVO = 'uploads/seed/prueba_no_autorizada.pdf'
   AND DESCRIPCION IN (
        UNISTR('Material que no deb\00C3\00ADa circular.'),
        UNISTR('Material que no deb\251C\00A1a circular.'),
        UNISTR('Material que no deb?a circular.'),
        UNISTR('Material que no deb\FFFDa circular.')
   );

-- WU_COMENTARIO.CONTENIDO
UPDATE WU_COMENTARIO
   SET CONTENIDO = UNISTR('Muy clara la parte de normalizaci\00F3n, gracias por compartir.')
 WHERE ID_USUARIO = 3 AND ID_APUNTE = 1 AND FECHA_COMENTARIO = DATE '2026-09-02'
   AND CONTENIDO IN (
        UNISTR('Muy clara la parte de normalizaci\00C3\00B3n, gracias por compartir.'),
        UNISTR('Muy clara la parte de normalizaci\251C\2502n, gracias por compartir.'),
        UNISTR('Muy clara la parte de normalizaci?n, gracias por compartir.'),
        UNISTR('Muy clara la parte de normalizaci\FFFDn, gracias por compartir.')
   );

-- WU_COMENTARIO.CONTENIDO
UPDATE WU_COMENTARIO
   SET CONTENIDO = UNISTR('Muy ordenado, los ejemplos de l\00EDmites est\00E1n excelentes.')
 WHERE ID_USUARIO = 2 AND ID_APUNTE = 6 AND FECHA_COMENTARIO = DATE '2026-09-01'
   AND CONTENIDO IN (
        UNISTR('Muy ordenado, los ejemplos de l\00C3\00ADmites est\00C3\00A1n excelentes.'),
        UNISTR('Muy ordenado, los ejemplos de l\251C\00A1mites est\251C\00EDn excelentes.'),
        UNISTR('Muy ordenado, los ejemplos de l?mites est?n excelentes.'),
        UNISTR('Muy ordenado, los ejemplos de l\FFFDmites est\FFFDn excelentes.')
   );

-- WU_COMENTARIO.CONTENIDO
UPDATE WU_COMENTARIO
   SET CONTENIDO = UNISTR('Comentario ocultado por la moderaci\00F3n.')
 WHERE ID_USUARIO = 4 AND ID_APUNTE = 3 AND FECHA_COMENTARIO = DATE '2026-09-18'
   AND CONTENIDO IN (
        UNISTR('Comentario ocultado por la moderaci\00C3\00B3n.'),
        UNISTR('Comentario ocultado por la moderaci\251C\2502n.'),
        UNISTR('Comentario ocultado por la moderaci?n.'),
        UNISTR('Comentario ocultado por la moderaci\FFFDn.')
   );

COMMIT;

PROMPT ==========================================================
PROMPT Comprobacion de caracteres en la base de datos:
PROMPT Microeconomia debe mostrarse como Microeconom\00EDa.
PROMPT ==========================================================
SELECT CODIGO, ASCIISTR(NOMBRE) AS NOMBRE_UNICODE
  FROM WU_ASIGNATURA
 WHERE CODIGO IN ('ADM101', 'INF113', 'MAT101');

SELECT CODIGO, ASCIISTR(NOMBRE) AS NOMBRE_UNICODE
  FROM WU_CARRERA
 WHERE CODIGO IN ('ICI', 'ICO', 'ENF');

PROMPT Reparacion finalizada. Si las consultas siguen mostrando secuencias
PROMPT como \00C3\00AD, revisar el dato concreto o la configuracion NLS.
