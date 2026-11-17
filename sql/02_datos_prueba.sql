-- Datos ficticios. Ejecutar despues de 01_tablas.sql.
-- Usuarios de demostracion: hashes ficticios, NO sirven para iniciar sesion.
INSERT INTO carrera (codigo,nombre) VALUES ('ICI','Ingenieria Civil Informatica');
INSERT INTO carrera (codigo,nombre) VALUES ('ICO','Ingenieria Comercial');
INSERT INTO carrera (codigo,nombre) VALUES ('ENF','Enfermeria');

INSERT INTO asignatura (codigo,nombre) VALUES ('INF101','Programacion I');
INSERT INTO asignatura (codigo,nombre) VALUES ('INF202','Bases de Datos');
INSERT INTO asignatura (codigo,nombre) VALUES ('MAT101','Calculo I');
INSERT INTO asignatura (codigo,nombre) VALUES ('ADM101','Administracion');

INSERT INTO carrera_asignatura (id_carrera,id_asignatura,semestre)
SELECT c.id_carrera,a.id_asignatura,3 FROM carrera c CROSS JOIN asignatura a WHERE c.codigo='ICI' AND a.codigo='INF202';
INSERT INTO carrera_asignatura (id_carrera,id_asignatura,semestre)
SELECT c.id_carrera,a.id_asignatura,1 FROM carrera c CROSS JOIN asignatura a WHERE c.codigo='ICI' AND a.codigo='INF101';
INSERT INTO carrera_asignatura (id_carrera,id_asignatura,semestre)
SELECT c.id_carrera,a.id_asignatura,1 FROM carrera c CROSS JOIN asignatura a WHERE c.codigo='ICI' AND a.codigo='MAT101';
INSERT INTO carrera_asignatura (id_carrera,id_asignatura,semestre)
SELECT c.id_carrera,a.id_asignatura,1 FROM carrera c CROSS JOIN asignatura a WHERE c.codigo='ICO' AND a.codigo='MAT101';
INSERT INTO carrera_asignatura (id_carrera,id_asignatura,semestre)
SELECT c.id_carrera,a.id_asignatura,2 FROM carrera c CROSS JOIN asignatura a WHERE c.codigo='ICO' AND a.codigo='ADM101';

INSERT INTO usuario (id_carrera,nombre,correo,password_hash,rol)
SELECT id_carrera,'Estudiante Demo','estudiante.demo@ejemplo.invalid','HASH_DEMO_NO_VALIDO','ESTUDIANTE' FROM carrera WHERE codigo='ICI';
INSERT INTO usuario (id_carrera,nombre,correo,password_hash,rol)
SELECT id_carrera,'Admin Demo','admin.demo@ejemplo.invalid','HASH_DEMO_NO_VALIDO','ADMIN' FROM carrera WHERE codigo='ICI';

-- Rutas ilustrativas: los archivos NO se crean mediante SQL.
INSERT INTO apunte (id_usuario,id_asignatura,titulo,descripcion,ruta_archivo)
SELECT u.id_usuario,a.id_asignatura,'Resumen de normalizacion','Ejemplo ficticio para pruebas','demo/normalizacion.pdf'
FROM usuario u CROSS JOIN asignatura a WHERE u.correo='estudiante.demo@ejemplo.invalid' AND a.codigo='INF202';
INSERT INTO apunte (id_usuario,id_asignatura,titulo,descripcion,ruta_archivo)
SELECT u.id_usuario,a.id_asignatura,'Guia de Python','Ejemplo ficticio para pruebas','demo/python.pdf'
FROM usuario u CROSS JOIN asignatura a WHERE u.correo='estudiante.demo@ejemplo.invalid' AND a.codigo='INF101';
COMMIT;
