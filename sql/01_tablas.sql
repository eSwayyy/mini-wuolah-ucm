-- Mini Wuolah UCM - Esquema inicial Oracle XE (12c+)
-- Ejecutar conectado al usuario/esquema de la aplicación.
-- Orden de creación respeta las dependencias entre claves foráneas.

CREATE TABLE carrera (
    id_carrera NUMBER,
    codigo VARCHAR2(20),
    nombre VARCHAR2(150),
    CONSTRAINT pk_carrera PRIMARY KEY (id_carrera),
    CONSTRAINT uq_carrera_codigo (codigo)
);

CREATE TABLE usuario (
    id_usuario NUMBER,
    id_carrera NUMBER,
    nombre VARCHAR2(100),
    correo VARCHAR2(150),
    password_hash VARCHAR2(255),
    rol VARCHAR2(20) DEFAULT 'ESTUDIANTE',
    fecha_registro TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_correo UNIQUE (correo),
    CONSTRAINT ck_usuario_rol CHECK (rol IN ('ESTUDIANTE', 'ADMIN')),
    CONSTRAINT fk_usuario_carrera FOREIGN KEY (id_carrera)
        REFERENCES carrera (id_carrera)
);

CREATE TABLE asignatura (
    id_asignatura NUMBER,
    codigo VARCHAR2(20),
    nombre VARCHAR2(150),
    CONSTRAINT pk_asignatura PRIMARY KEY (id_asignatura),
    CONSTRAINT uq_asignatura_codigo (codigo)
);

CREATE TABLE carrera_asignatura (
    id_carrera NUMBER,
    id_asignatura NUMBER,
    semestre NUMBER(2),
    CONSTRAINT pk_carrera_asignatura PRIMARY KEY (id_carrera, id_asignatura),
    CONSTRAINT ck_ca_semestre CHECK (semestre BETWEEN 1 AND 12),
    CONSTRAINT fk_ca_carrera FOREIGN KEY (id_carrera)
        REFERENCES carrera (id_carrera),
    CONSTRAINT fk_ca_asignatura FOREIGN KEY (id_asignatura)
        REFERENCES asignatura (id_asignatura)
);

CREATE TABLE apunte (
    id_apunte NUMBER,
    id_usuario NUMBER,
    id_asignatura NUMBER,
    titulo VARCHAR2(200),
    descripcion VARCHAR2(1000),
    ruta_archivo VARCHAR2(500),
    fecha_subida TIMESTAMP DEFAULT SYSTIMESTAMP,
    estado VARCHAR2(20) DEFAULT 'ACTIVO',
    CONSTRAINT pk_apunte PRIMARY KEY (id_apunte),
    CONSTRAINT ck_apunte_estado CHECK (estado IN ('ACTIVO', 'OCULTO', 'ELIMINADO')),
    CONSTRAINT fk_apunte_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario),
    CONSTRAINT fk_apunte_asignatura FOREIGN KEY (id_asignatura)
        REFERENCES asignatura (id_asignatura)
);

CREATE TABLE descarga (
    id_descarga NUMBER,
    id_usuario NUMBER,
    id_apunte NUMBER,
    fecha_descarga TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_descarga PRIMARY KEY (id_descarga),
    CONSTRAINT fk_descarga_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario),
    CONSTRAINT fk_descarga_apunte FOREIGN KEY (id_apunte)
        REFERENCES apunte (id_apunte)
);

CREATE TABLE valoracion (
    id_valoracion NUMBER,
    id_usuario NUMBER,
    id_apunte NUMBER,
    puntuacion NUMBER(1),
    fecha_valoracion TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_valoracion PRIMARY KEY (id_valoracion),
    CONSTRAINT uq_valoracion_usuario_apunte UNIQUE (id_usuario, id_apunte),
    CONSTRAINT ck_valoracion_puntuacion CHECK (puntuacion BETWEEN 1 AND 5),
    CONSTRAINT fk_valoracion_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario),
    CONSTRAINT fk_valoracion_apunte FOREIGN KEY (id_apunte)
        REFERENCES apunte (id_apunte)
);

CREATE TABLE comentario (
    id_comentario NUMBER,
    id_usuario NUMBER,
    id_apunte NUMBER,
    contenido VARCHAR2(1000),
    fecha_comentario TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_comentario PRIMARY KEY (id_comentario),
    CONSTRAINT fk_comentario_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario),
    CONSTRAINT fk_comentario_apunte FOREIGN KEY (id_apunte)
        REFERENCES apunte (id_apunte)
);

-- Indices para consultas frecuentes por claves foraneas.
-- Oracle crea indices automaticamente para PK y UNIQUE, pero no para todas las FK.
CREATE INDEX ix_usuario_carrera ON usuario (id_carrera);
CREATE INDEX ix_ca_asignatura ON carrera_asignatura (id_asignatura);
CREATE INDEX ix_apunte_usuario ON apunte (id_usuario);
CREATE INDEX ix_apunte_asignatura ON apunte (id_asignatura);
CREATE INDEX ix_descarga_usuario ON descarga (id_usuario);
CREATE INDEX ix_descarga_apunte ON descarga (id_apunte);
CREATE INDEX ix_valoracion_apunte ON valoracion (id_apunte);
CREATE INDEX ix_comentario_usuario ON comentario (id_usuario);
CREATE INDEX ix_comentario_apunte ON comentario (id_apunte);
