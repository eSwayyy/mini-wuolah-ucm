/*
    MANTENEDORES (10): UN PROCEDIMIENTO INTEGRAL IUD POR TABLA
    OPCION_P: 'I' = INSERT, 'U' = UPDATE, 'D' = DELETE
*/

-- ==================================================================
-- MANTENEDOR: FACULTAD
-- ==================================================================

CREATE OR REPLACE PROCEDURE WU_FACULTAD_IUD_P(
    OPCION_P VARCHAR2,
    ID_FACULTAD_P NUMBER,
    NOMBRE_P VARCHAR2
)
IS
    CODIGO_V NUMBER;
BEGIN
    LOCK TABLE WU_FACULTAD IN ROW EXCLUSIVE MODE;

    IF OPCION_P = 'I' THEN
        INSERT INTO WU_FACULTAD(
            ID_FACULTAD,
            NOMBRE
        )
        VALUES(
            WU_SIGUIENTE_ID_FACULTAD_F(),
            NOMBRE_P
        );
    ELSIF OPCION_P = 'U' THEN
        UPDATE WU_FACULTAD
            SET NOMBRE = NOMBRE_P
            WHERE ID_FACULTAD = ID_FACULTAD_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSIF OPCION_P = 'D' THEN
        DELETE FROM WU_FACULTAD
            WHERE ID_FACULTAD = ID_FACULTAD_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20007, 'Opcion no valida, use I, U o D.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN PROGRAM_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20901, 'Error interno de programa PL/SQL.');
    WHEN STORAGE_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20902, 'Memoria agotada o corrupta en BD.');
    WHEN ROWTYPE_MISMATCH THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20903, 'Incompatibilidad de tipos de datos.');
    WHEN OTHERS THEN
        CODIGO_V := SQLCODE;
        ROLLBACK;
        IF CODIGO_V BETWEEN -20999 AND -20000 THEN
            RAISE;
        ELSIF CODIGO_V = -1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El registro ya existe.');
        ELSIF CODIGO_V = -1400 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Falta un dato obligatorio.');
        ELSIF CODIGO_V = -2290 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Un dato no cumple las reglas permitidas.');
        ELSIF CODIGO_V = -2291 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Un dato relacionado no existe.');
        ELSIF CODIGO_V = -2292 THEN
            RAISE_APPLICATION_ERROR(-20002, 'El registro tiene datos asociados.');
        ELSE
            RAISE_APPLICATION_ERROR(-20010, 'Error inesperado en WU_FACULTAD_IUD_P.');
        END IF;
END WU_FACULTAD_IUD_P;
/

CREATE OR REPLACE PROCEDURE WU_FACULTAD_LISTAR_P(
    CURSOR_P OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN CURSOR_P FOR
        SELECT F.ID_FACULTAD, F.NOMBRE
        FROM WU_FACULTAD F
        ORDER BY F.NOMBRE;
END WU_FACULTAD_LISTAR_P;
/

-- ==================================================================
-- MANTENEDOR: CARRERA
-- ==================================================================

CREATE OR REPLACE PROCEDURE WU_CARRERA_IUD_P(
    OPCION_P VARCHAR2,
    ID_CARRERA_P NUMBER,
    CODIGO_P VARCHAR2,
    NOMBRE_P VARCHAR2,
    ID_FACULTAD_P NUMBER
)
IS
    CODIGO_V NUMBER;
BEGIN
    LOCK TABLE WU_CARRERA IN ROW EXCLUSIVE MODE;

    IF OPCION_P = 'I' THEN
        INSERT INTO WU_CARRERA(
            ID_CARRERA,
            CODIGO,
            NOMBRE,
            ID_FACULTAD
        )
        VALUES(
            WU_SIGUIENTE_ID_CARRERA_F(),
            CODIGO_P,
            NOMBRE_P,
            ID_FACULTAD_P
        );
    ELSIF OPCION_P = 'U' THEN
        UPDATE WU_CARRERA
            SET CODIGO = CODIGO_P,
                NOMBRE = NOMBRE_P,
                ID_FACULTAD = ID_FACULTAD_P
            WHERE ID_CARRERA = ID_CARRERA_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSIF OPCION_P = 'D' THEN
        DELETE FROM WU_CARRERA
            WHERE ID_CARRERA = ID_CARRERA_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20007, 'Opcion no valida, use I, U o D.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN PROGRAM_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20901, 'Error interno de programa PL/SQL.');
    WHEN STORAGE_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20902, 'Memoria agotada o corrupta en BD.');
    WHEN ROWTYPE_MISMATCH THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20903, 'Incompatibilidad de tipos de datos.');
    WHEN OTHERS THEN
        CODIGO_V := SQLCODE;
        ROLLBACK;
        IF CODIGO_V BETWEEN -20999 AND -20000 THEN
            RAISE;
        ELSIF CODIGO_V = -1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El registro ya existe.');
        ELSIF CODIGO_V = -1400 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Falta un dato obligatorio.');
        ELSIF CODIGO_V = -2290 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Un dato no cumple las reglas permitidas.');
        ELSIF CODIGO_V = -2291 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Un dato relacionado no existe.');
        ELSIF CODIGO_V = -2292 THEN
            RAISE_APPLICATION_ERROR(-20002, 'El registro tiene datos asociados.');
        ELSE
            RAISE_APPLICATION_ERROR(-20010, 'Error inesperado en WU_CARRERA_IUD_P.');
        END IF;
END WU_CARRERA_IUD_P;
/

CREATE OR REPLACE PROCEDURE WU_CARRERA_LISTAR_P(
    CURSOR_P OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN CURSOR_P FOR
        SELECT C.ID_CARRERA, C.CODIGO, C.NOMBRE, C.ID_FACULTAD, F.NOMBRE AS FACULTAD
        FROM WU_CARRERA C JOIN WU_FACULTAD F ON(C.ID_FACULTAD = F.ID_FACULTAD)
        ORDER BY C.NOMBRE;
END WU_CARRERA_LISTAR_P;
/

-- ==================================================================
-- MANTENEDOR: PROFESOR
-- ==================================================================

CREATE OR REPLACE PROCEDURE WU_PROFESOR_IUD_P(
    OPCION_P VARCHAR2,
    ID_PROFESOR_P NUMBER,
    NOMBRE_P VARCHAR2,
    APELLIDO_P VARCHAR2,
    ID_FACULTAD_P NUMBER
)
IS
    CODIGO_V NUMBER;
BEGIN
    LOCK TABLE WU_PROFESOR IN ROW EXCLUSIVE MODE;

    IF OPCION_P = 'I' THEN
        INSERT INTO WU_PROFESOR(
            ID_PROFESOR,
            NOMBRE,
            APELLIDO,
            ID_FACULTAD
        )
        VALUES(
            WU_SIGUIENTE_ID_PROFESOR_F(),
            NOMBRE_P,
            APELLIDO_P,
            ID_FACULTAD_P
        );
    ELSIF OPCION_P = 'U' THEN
        UPDATE WU_PROFESOR
            SET NOMBRE = NOMBRE_P,
                APELLIDO = APELLIDO_P,
                ID_FACULTAD = ID_FACULTAD_P
            WHERE ID_PROFESOR = ID_PROFESOR_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSIF OPCION_P = 'D' THEN
        DELETE FROM WU_PROFESOR
            WHERE ID_PROFESOR = ID_PROFESOR_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20007, 'Opcion no valida, use I, U o D.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN PROGRAM_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20901, 'Error interno de programa PL/SQL.');
    WHEN STORAGE_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20902, 'Memoria agotada o corrupta en BD.');
    WHEN ROWTYPE_MISMATCH THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20903, 'Incompatibilidad de tipos de datos.');
    WHEN OTHERS THEN
        CODIGO_V := SQLCODE;
        ROLLBACK;
        IF CODIGO_V BETWEEN -20999 AND -20000 THEN
            RAISE;
        ELSIF CODIGO_V = -1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El registro ya existe.');
        ELSIF CODIGO_V = -1400 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Falta un dato obligatorio.');
        ELSIF CODIGO_V = -2290 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Un dato no cumple las reglas permitidas.');
        ELSIF CODIGO_V = -2291 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Un dato relacionado no existe.');
        ELSIF CODIGO_V = -2292 THEN
            RAISE_APPLICATION_ERROR(-20002, 'El registro tiene datos asociados.');
        ELSE
            RAISE_APPLICATION_ERROR(-20010, 'Error inesperado en WU_PROFESOR_IUD_P.');
        END IF;
END WU_PROFESOR_IUD_P;
/

CREATE OR REPLACE PROCEDURE WU_PROFESOR_LISTAR_P(
    CURSOR_P OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN CURSOR_P FOR
        SELECT P.ID_PROFESOR, P.NOMBRE, P.APELLIDO, P.ID_FACULTAD, F.NOMBRE AS FACULTAD
        FROM WU_PROFESOR P JOIN WU_FACULTAD F ON(P.ID_FACULTAD = F.ID_FACULTAD)
        ORDER BY P.APELLIDO, P.NOMBRE;
END WU_PROFESOR_LISTAR_P;
/

-- ==================================================================
-- MANTENEDOR: ASIGNATURA
-- ==================================================================

CREATE OR REPLACE PROCEDURE WU_ASIGNATURA_IUD_P(
    OPCION_P VARCHAR2,
    ID_ASIGNATURA_P NUMBER,
    CODIGO_P VARCHAR2,
    NOMBRE_P VARCHAR2
)
IS
    CODIGO_V NUMBER;
BEGIN
    LOCK TABLE WU_ASIGNATURA IN ROW EXCLUSIVE MODE;

    IF OPCION_P = 'I' THEN
        INSERT INTO WU_ASIGNATURA(
            ID_ASIGNATURA,
            CODIGO,
            NOMBRE
        )
        VALUES(
            WU_SIGUIENTE_ID_ASIGNATURA_F(),
            CODIGO_P,
            NOMBRE_P
        );
    ELSIF OPCION_P = 'U' THEN
        UPDATE WU_ASIGNATURA
            SET CODIGO = CODIGO_P,
                NOMBRE = NOMBRE_P
            WHERE ID_ASIGNATURA = ID_ASIGNATURA_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSIF OPCION_P = 'D' THEN
        DELETE FROM WU_ASIGNATURA
            WHERE ID_ASIGNATURA = ID_ASIGNATURA_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20007, 'Opcion no valida, use I, U o D.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN PROGRAM_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20901, 'Error interno de programa PL/SQL.');
    WHEN STORAGE_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20902, 'Memoria agotada o corrupta en BD.');
    WHEN ROWTYPE_MISMATCH THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20903, 'Incompatibilidad de tipos de datos.');
    WHEN OTHERS THEN
        CODIGO_V := SQLCODE;
        ROLLBACK;
        IF CODIGO_V BETWEEN -20999 AND -20000 THEN
            RAISE;
        ELSIF CODIGO_V = -1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El registro ya existe.');
        ELSIF CODIGO_V = -1400 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Falta un dato obligatorio.');
        ELSIF CODIGO_V = -2290 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Un dato no cumple las reglas permitidas.');
        ELSIF CODIGO_V = -2291 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Un dato relacionado no existe.');
        ELSIF CODIGO_V = -2292 THEN
            RAISE_APPLICATION_ERROR(-20002, 'El registro tiene datos asociados.');
        ELSE
            RAISE_APPLICATION_ERROR(-20010, 'Error inesperado en WU_ASIGNATURA_IUD_P.');
        END IF;
END WU_ASIGNATURA_IUD_P;
/

CREATE OR REPLACE PROCEDURE WU_ASIGNATURA_LISTAR_P(
    CURSOR_P OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN CURSOR_P FOR
        SELECT S.ID_ASIGNATURA, S.CODIGO, S.NOMBRE
        FROM WU_ASIGNATURA S
        ORDER BY S.NOMBRE;
END WU_ASIGNATURA_LISTAR_P;
/

-- ==================================================================
-- MANTENEDOR: CARRERA_ASIGNATURA
-- ==================================================================

CREATE OR REPLACE PROCEDURE WU_CARRERA_ASIGNATURA_IUD_P(
    OPCION_P VARCHAR2,
    ID_CARRERA_P NUMBER,
    ID_ASIGNATURA_P NUMBER,
    SEMESTRE_P NUMBER
)
IS
    CODIGO_V NUMBER;
BEGIN
    LOCK TABLE WU_CARRERA_ASIGNATURA IN ROW EXCLUSIVE MODE;

    IF OPCION_P = 'I' THEN
        INSERT INTO WU_CARRERA_ASIGNATURA(
            ID_CARRERA,
            ID_ASIGNATURA,
            SEMESTRE
        )
        VALUES(
            ID_CARRERA_P,
            ID_ASIGNATURA_P,
            SEMESTRE_P
        );
    ELSIF OPCION_P = 'U' THEN
        UPDATE WU_CARRERA_ASIGNATURA
            SET SEMESTRE = SEMESTRE_P
            WHERE ID_CARRERA = ID_CARRERA_P AND ID_ASIGNATURA = ID_ASIGNATURA_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSIF OPCION_P = 'D' THEN
        DELETE FROM WU_CARRERA_ASIGNATURA
            WHERE ID_CARRERA = ID_CARRERA_P AND ID_ASIGNATURA = ID_ASIGNATURA_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20007, 'Opcion no valida, use I, U o D.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN PROGRAM_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20901, 'Error interno de programa PL/SQL.');
    WHEN STORAGE_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20902, 'Memoria agotada o corrupta en BD.');
    WHEN ROWTYPE_MISMATCH THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20903, 'Incompatibilidad de tipos de datos.');
    WHEN OTHERS THEN
        CODIGO_V := SQLCODE;
        ROLLBACK;
        IF CODIGO_V BETWEEN -20999 AND -20000 THEN
            RAISE;
        ELSIF CODIGO_V = -1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El registro ya existe.');
        ELSIF CODIGO_V = -1400 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Falta un dato obligatorio.');
        ELSIF CODIGO_V = -2290 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Un dato no cumple las reglas permitidas.');
        ELSIF CODIGO_V = -2291 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Un dato relacionado no existe.');
        ELSIF CODIGO_V = -2292 THEN
            RAISE_APPLICATION_ERROR(-20002, 'El registro tiene datos asociados.');
        ELSE
            RAISE_APPLICATION_ERROR(-20010, 'Error inesperado en WU_CARRERA_ASIGNATURA_IUD_P.');
        END IF;
END WU_CARRERA_ASIGNATURA_IUD_P;
/

CREATE OR REPLACE PROCEDURE WU_CARRERA_ASIGNATURA_LISTAR_P(
    CURSOR_P OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN CURSOR_P FOR
        SELECT CA.ID_CARRERA, C.NOMBRE AS CARRERA, CA.ID_ASIGNATURA, S.CODIGO, S.NOMBRE AS ASIGNATURA, CA.SEMESTRE
        FROM WU_CARRERA_ASIGNATURA CA JOIN WU_CARRERA C ON(CA.ID_CARRERA = C.ID_CARRERA)
             JOIN WU_ASIGNATURA S ON(CA.ID_ASIGNATURA = S.ID_ASIGNATURA)
        ORDER BY C.NOMBRE, CA.SEMESTRE, S.NOMBRE;
END WU_CARRERA_ASIGNATURA_LISTAR_P;
/

-- ==================================================================
-- MANTENEDOR: TIPO_APUNTE
-- ==================================================================

CREATE OR REPLACE PROCEDURE WU_TIPO_APUNTE_IUD_P(
    OPCION_P VARCHAR2,
    ID_TIPO_P NUMBER,
    NOMBRE_P VARCHAR2
)
IS
    CODIGO_V NUMBER;
BEGIN
    LOCK TABLE WU_TIPO_APUNTE IN ROW EXCLUSIVE MODE;

    IF OPCION_P = 'I' THEN
        INSERT INTO WU_TIPO_APUNTE(
            ID_TIPO,
            NOMBRE
        )
        VALUES(
            WU_SIGUIENTE_ID_TIPO_F(),
            NOMBRE_P
        );
    ELSIF OPCION_P = 'U' THEN
        UPDATE WU_TIPO_APUNTE
            SET NOMBRE = NOMBRE_P
            WHERE ID_TIPO = ID_TIPO_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSIF OPCION_P = 'D' THEN
        DELETE FROM WU_TIPO_APUNTE
            WHERE ID_TIPO = ID_TIPO_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20007, 'Opcion no valida, use I, U o D.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN PROGRAM_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20901, 'Error interno de programa PL/SQL.');
    WHEN STORAGE_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20902, 'Memoria agotada o corrupta en BD.');
    WHEN ROWTYPE_MISMATCH THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20903, 'Incompatibilidad de tipos de datos.');
    WHEN OTHERS THEN
        CODIGO_V := SQLCODE;
        ROLLBACK;
        IF CODIGO_V BETWEEN -20999 AND -20000 THEN
            RAISE;
        ELSIF CODIGO_V = -1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El registro ya existe.');
        ELSIF CODIGO_V = -1400 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Falta un dato obligatorio.');
        ELSIF CODIGO_V = -2290 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Un dato no cumple las reglas permitidas.');
        ELSIF CODIGO_V = -2291 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Un dato relacionado no existe.');
        ELSIF CODIGO_V = -2292 THEN
            RAISE_APPLICATION_ERROR(-20002, 'El registro tiene datos asociados.');
        ELSE
            RAISE_APPLICATION_ERROR(-20010, 'Error inesperado en WU_TIPO_APUNTE_IUD_P.');
        END IF;
END WU_TIPO_APUNTE_IUD_P;
/

CREATE OR REPLACE PROCEDURE WU_TIPO_APUNTE_LISTAR_P(
    CURSOR_P OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN CURSOR_P FOR
        SELECT T.ID_TIPO, T.NOMBRE
        FROM WU_TIPO_APUNTE T
        ORDER BY T.NOMBRE;
END WU_TIPO_APUNTE_LISTAR_P;
/

-- ==================================================================
-- MANTENEDOR: ETIQUETA
-- ==================================================================

CREATE OR REPLACE PROCEDURE WU_ETIQUETA_IUD_P(
    OPCION_P VARCHAR2,
    ID_ETIQUETA_P NUMBER,
    NOMBRE_P VARCHAR2
)
IS
    CODIGO_V NUMBER;
BEGIN
    LOCK TABLE WU_ETIQUETA IN ROW EXCLUSIVE MODE;

    IF OPCION_P = 'I' THEN
        INSERT INTO WU_ETIQUETA(
            ID_ETIQUETA,
            NOMBRE
        )
        VALUES(
            WU_SIGUIENTE_ID_ETIQUETA_F(),
            NOMBRE_P
        );
    ELSIF OPCION_P = 'U' THEN
        UPDATE WU_ETIQUETA
            SET NOMBRE = NOMBRE_P
            WHERE ID_ETIQUETA = ID_ETIQUETA_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSIF OPCION_P = 'D' THEN
        DELETE FROM WU_ETIQUETA
            WHERE ID_ETIQUETA = ID_ETIQUETA_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20007, 'Opcion no valida, use I, U o D.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN PROGRAM_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20901, 'Error interno de programa PL/SQL.');
    WHEN STORAGE_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20902, 'Memoria agotada o corrupta en BD.');
    WHEN ROWTYPE_MISMATCH THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20903, 'Incompatibilidad de tipos de datos.');
    WHEN OTHERS THEN
        CODIGO_V := SQLCODE;
        ROLLBACK;
        IF CODIGO_V BETWEEN -20999 AND -20000 THEN
            RAISE;
        ELSIF CODIGO_V = -1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El registro ya existe.');
        ELSIF CODIGO_V = -1400 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Falta un dato obligatorio.');
        ELSIF CODIGO_V = -2290 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Un dato no cumple las reglas permitidas.');
        ELSIF CODIGO_V = -2291 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Un dato relacionado no existe.');
        ELSIF CODIGO_V = -2292 THEN
            RAISE_APPLICATION_ERROR(-20002, 'El registro tiene datos asociados.');
        ELSE
            RAISE_APPLICATION_ERROR(-20010, 'Error inesperado en WU_ETIQUETA_IUD_P.');
        END IF;
END WU_ETIQUETA_IUD_P;
/

CREATE OR REPLACE PROCEDURE WU_ETIQUETA_LISTAR_P(
    CURSOR_P OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN CURSOR_P FOR
        SELECT E.ID_ETIQUETA, E.NOMBRE
        FROM WU_ETIQUETA E
        ORDER BY E.NOMBRE;
END WU_ETIQUETA_LISTAR_P;
/

-- ==================================================================
-- MANTENEDOR: USUARIO
-- ==================================================================

CREATE OR REPLACE PROCEDURE WU_USUARIO_IUD_P(
    OPCION_P VARCHAR2,
    ID_USUARIO_P NUMBER,
    ID_CARRERA_P NUMBER,
    NOMBRE_P VARCHAR2,
    CORREO_P VARCHAR2,
    PASSWORD_HASH_P VARCHAR2,
    ROL_P VARCHAR2,
    ESTADO_P VARCHAR2
)
IS
    CODIGO_V NUMBER;
BEGIN
    LOCK TABLE WU_USUARIO IN ROW EXCLUSIVE MODE;

    IF OPCION_P = 'I' THEN
        INSERT INTO WU_USUARIO(
            ID_USUARIO,
            ID_CARRERA,
            NOMBRE,
            CORREO,
            PASSWORD_HASH,
            ROL,
            ESTADO,
            FECHA_REGISTRO
        )
        VALUES(
            WU_SIGUIENTE_ID_USUARIO_F(),
            ID_CARRERA_P,
            NOMBRE_P,
            LOWER(CORREO_P),
            PASSWORD_HASH_P,
            NVL(ROL_P, 'ESTUDIANTE'),
            NVL(ESTADO_P, 'ACTIVO'),
            SYSDATE
        );
    ELSIF OPCION_P = 'U' THEN
        UPDATE WU_USUARIO
            SET ID_CARRERA = ID_CARRERA_P,
                NOMBRE = NOMBRE_P,
                CORREO = LOWER(CORREO_P),
                PASSWORD_HASH = NVL(PASSWORD_HASH_P, PASSWORD_HASH),
                ROL = NVL(ROL_P, ROL),
                ESTADO = NVL(ESTADO_P, ESTADO)
            WHERE ID_USUARIO = ID_USUARIO_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSIF OPCION_P = 'D' THEN
        DELETE FROM WU_USUARIO
            WHERE ID_USUARIO = ID_USUARIO_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20007, 'Opcion no valida, use I, U o D.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN PROGRAM_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20901, 'Error interno de programa PL/SQL.');
    WHEN STORAGE_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20902, 'Memoria agotada o corrupta en BD.');
    WHEN ROWTYPE_MISMATCH THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20903, 'Incompatibilidad de tipos de datos.');
    WHEN OTHERS THEN
        CODIGO_V := SQLCODE;
        ROLLBACK;
        IF CODIGO_V BETWEEN -20999 AND -20000 THEN
            RAISE;
        ELSIF CODIGO_V = -1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El registro ya existe.');
        ELSIF CODIGO_V = -1400 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Falta un dato obligatorio.');
        ELSIF CODIGO_V = -2290 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Un dato no cumple las reglas permitidas.');
        ELSIF CODIGO_V = -2291 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Un dato relacionado no existe.');
        ELSIF CODIGO_V = -2292 THEN
            RAISE_APPLICATION_ERROR(-20002, 'El registro tiene datos asociados.');
        ELSE
            RAISE_APPLICATION_ERROR(-20010, 'Error inesperado en WU_USUARIO_IUD_P.');
        END IF;
END WU_USUARIO_IUD_P;
/

CREATE OR REPLACE PROCEDURE WU_USUARIO_LISTAR_P(
    CURSOR_P OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN CURSOR_P FOR
        SELECT U.ID_USUARIO, U.NOMBRE, U.CORREO, U.ROL, U.ID_CARRERA,
               WU_NOMBRE_CARRERA_F(U.ID_CARRERA) AS CARRERA, U.ESTADO, U.FECHA_REGISTRO
        FROM WU_USUARIO U
        ORDER BY U.NOMBRE;
END WU_USUARIO_LISTAR_P;
/

-- ==================================================================
-- MANTENEDOR: APUNTE
-- ==================================================================

CREATE OR REPLACE PROCEDURE WU_APUNTE_IUD_P(
    OPCION_P VARCHAR2,
    ID_APUNTE_P NUMBER,
    ID_USUARIO_P NUMBER,
    ID_ASIGNATURA_P NUMBER,
    ID_TIPO_P NUMBER,
    ID_PROFESOR_P NUMBER,
    TITULO_P VARCHAR2,
    DESCRIPCION_P VARCHAR2,
    RUTA_ARCHIVO_P VARCHAR2,
    ESTADO_P VARCHAR2
)
IS
    CODIGO_V NUMBER;
BEGIN
    LOCK TABLE WU_APUNTE IN ROW EXCLUSIVE MODE;

    IF OPCION_P = 'I' THEN
        INSERT INTO WU_APUNTE(
            ID_APUNTE,
            ID_USUARIO,
            ID_ASIGNATURA,
            ID_TIPO,
            ID_PROFESOR,
            TITULO,
            DESCRIPCION,
            RUTA_ARCHIVO,
            ESTADO,
            FECHA_SUBIDA
        )
        VALUES(
            WU_SIGUIENTE_ID_APUNTE_F(),
            ID_USUARIO_P,
            ID_ASIGNATURA_P,
            ID_TIPO_P,
            ID_PROFESOR_P,
            TITULO_P,
            DESCRIPCION_P,
            RUTA_ARCHIVO_P,
            NVL(ESTADO_P, 'PENDIENTE'),
            SYSDATE
        );
    ELSIF OPCION_P = 'U' THEN
        UPDATE WU_APUNTE
            SET ID_USUARIO = ID_USUARIO_P,
                ID_ASIGNATURA = ID_ASIGNATURA_P,
                ID_TIPO = ID_TIPO_P,
                ID_PROFESOR = ID_PROFESOR_P,
                TITULO = TITULO_P,
                DESCRIPCION = DESCRIPCION_P,
                RUTA_ARCHIVO = RUTA_ARCHIVO_P,
                ESTADO = NVL(ESTADO_P, ESTADO)
            WHERE ID_APUNTE = ID_APUNTE_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSIF OPCION_P = 'D' THEN
        DELETE FROM WU_APUNTE_ETIQUETA WHERE ID_APUNTE = ID_APUNTE_P;
        DELETE FROM WU_DESCARGA WHERE ID_APUNTE = ID_APUNTE_P;
        DELETE FROM WU_VALORACION WHERE ID_APUNTE = ID_APUNTE_P;
        DELETE FROM WU_FAVORITO WHERE ID_APUNTE = ID_APUNTE_P;
        DELETE FROM WU_COMENTARIO WHERE ID_APUNTE = ID_APUNTE_P;
        DELETE FROM WU_MODERACION WHERE ID_APUNTE = ID_APUNTE_P;
        DELETE FROM WU_APUNTE
            WHERE ID_APUNTE = ID_APUNTE_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20007, 'Opcion no valida, use I, U o D.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN PROGRAM_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20901, 'Error interno de programa PL/SQL.');
    WHEN STORAGE_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20902, 'Memoria agotada o corrupta en BD.');
    WHEN ROWTYPE_MISMATCH THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20903, 'Incompatibilidad de tipos de datos.');
    WHEN OTHERS THEN
        CODIGO_V := SQLCODE;
        ROLLBACK;
        IF CODIGO_V BETWEEN -20999 AND -20000 THEN
            RAISE;
        ELSIF CODIGO_V = -1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El registro ya existe.');
        ELSIF CODIGO_V = -1400 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Falta un dato obligatorio.');
        ELSIF CODIGO_V = -2290 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Un dato no cumple las reglas permitidas.');
        ELSIF CODIGO_V = -2291 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Un dato relacionado no existe.');
        ELSIF CODIGO_V = -2292 THEN
            RAISE_APPLICATION_ERROR(-20002, 'El registro tiene datos asociados.');
        ELSE
            RAISE_APPLICATION_ERROR(-20010, 'Error inesperado en WU_APUNTE_IUD_P.');
        END IF;
END WU_APUNTE_IUD_P;
/

-- ==================================================================
-- MANTENEDOR: COMENTARIO
-- ==================================================================

CREATE OR REPLACE PROCEDURE WU_COMENTARIO_IUD_P(
    OPCION_P VARCHAR2,
    ID_COMENTARIO_P NUMBER,
    ID_USUARIO_P NUMBER,
    ID_APUNTE_P NUMBER,
    CONTENIDO_P VARCHAR2,
    VISIBLE_P NUMBER
)
IS
    CODIGO_V NUMBER;
BEGIN
    LOCK TABLE WU_COMENTARIO IN ROW EXCLUSIVE MODE;

    IF OPCION_P = 'I' THEN
        INSERT INTO WU_COMENTARIO(
            ID_COMENTARIO,
            ID_USUARIO,
            ID_APUNTE,
            CONTENIDO,
            VISIBLE,
            FECHA_COMENTARIO
        )
        VALUES(
            WU_SIGUIENTE_ID_COMENTARIO_F(),
            ID_USUARIO_P,
            ID_APUNTE_P,
            CONTENIDO_P,
            NVL(VISIBLE_P, 1),
            SYSDATE
        );
    ELSIF OPCION_P = 'U' THEN
        UPDATE WU_COMENTARIO
            SET ID_USUARIO = ID_USUARIO_P,
                ID_APUNTE = ID_APUNTE_P,
                CONTENIDO = CONTENIDO_P,
                VISIBLE = NVL(VISIBLE_P, VISIBLE)
            WHERE ID_COMENTARIO = ID_COMENTARIO_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSIF OPCION_P = 'D' THEN
        DELETE FROM WU_COMENTARIO
            WHERE ID_COMENTARIO = ID_COMENTARIO_P;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'No existe el registro indicado.');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20007, 'Opcion no valida, use I, U o D.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN PROGRAM_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20901, 'Error interno de programa PL/SQL.');
    WHEN STORAGE_ERROR THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20902, 'Memoria agotada o corrupta en BD.');
    WHEN ROWTYPE_MISMATCH THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20903, 'Incompatibilidad de tipos de datos.');
    WHEN OTHERS THEN
        CODIGO_V := SQLCODE;
        ROLLBACK;
        IF CODIGO_V BETWEEN -20999 AND -20000 THEN
            RAISE;
        ELSIF CODIGO_V = -1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El registro ya existe.');
        ELSIF CODIGO_V = -1400 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Falta un dato obligatorio.');
        ELSIF CODIGO_V = -2290 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Un dato no cumple las reglas permitidas.');
        ELSIF CODIGO_V = -2291 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Un dato relacionado no existe.');
        ELSIF CODIGO_V = -2292 THEN
            RAISE_APPLICATION_ERROR(-20002, 'El registro tiene datos asociados.');
        ELSE
            RAISE_APPLICATION_ERROR(-20010, 'Error inesperado en WU_COMENTARIO_IUD_P.');
        END IF;
END WU_COMENTARIO_IUD_P;
/

CREATE OR REPLACE PROCEDURE WU_COMENTARIO_LISTAR_P(
    CURSOR_P OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN CURSOR_P FOR
        SELECT C.ID_COMENTARIO, C.ID_APUNTE, A.TITULO AS APUNTE, C.ID_USUARIO, U.NOMBRE AS AUTOR,
               C.CONTENIDO, C.FECHA_COMENTARIO, C.VISIBLE
        FROM WU_COMENTARIO C JOIN WU_APUNTE A ON(C.ID_APUNTE = A.ID_APUNTE)
             JOIN WU_USUARIO U ON(C.ID_USUARIO = U.ID_USUARIO)
        ORDER BY C.FECHA_COMENTARIO DESC, C.ID_COMENTARIO DESC;
END WU_COMENTARIO_LISTAR_P;
/
