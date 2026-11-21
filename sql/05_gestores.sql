/*
    AUTENTICACION Y GESTORES (PROCESOS DE NEGOCIO)
    GESTOR 1: PUBLICAR APUNTE
    GESTOR 2: MODERAR APUNTE
    GESTOR 3: REGISTRAR DESCARGA
    GESTOR 4: VALORAR APUNTE
    GESTOR 5: ALTERNAR FAVORITO
*/

-- ======================================================================
-- AUTENTICACION
-- LA CLAVE LLEGA YA CIFRADA DESDE LA APLICACION, LA BD SOLO GUARDA EL HASH
-- ======================================================================

CREATE OR REPLACE PROCEDURE WU_REGISTRAR_ESTUDIANTE_P(
    NOMBRE_P VARCHAR2,
    CORREO_P VARCHAR2,
    PASSWORD_HASH_P VARCHAR2,
    ID_CARRERA_P NUMBER,
    ID_USUARIO_P OUT NUMBER
)
IS
    CONTADOR_V NUMBER;
    CODIGO_V NUMBER;
BEGIN
    LOCK TABLE WU_USUARIO IN ROW EXCLUSIVE MODE;

    IF WU_CORREO_EXISTE_F(CORREO_P) = 1 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Ya existe una cuenta con ese correo.');
    END IF;

    IF ID_CARRERA_P IS NOT NULL THEN
        SELECT COUNT(*)
            INTO CONTADOR_V
            FROM WU_CARRERA
            WHERE ID_CARRERA = ID_CARRERA_P;
        IF CONTADOR_V = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Referencia invalida: la carrera no existe.');
        END IF;
    END IF;

    ID_USUARIO_P := WU_SIGUIENTE_ID_USUARIO_F();

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
        ID_USUARIO_P,
        ID_CARRERA_P,
        NOMBRE_P,
        LOWER(CORREO_P),
        PASSWORD_HASH_P,
        'ESTUDIANTE',
        'ACTIVO',
        SYSDATE
    );

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
            RAISE_APPLICATION_ERROR(-20010, 'Error inesperado en WU_REGISTRAR_ESTUDIANTE_P.');
        END IF;
END WU_REGISTRAR_ESTUDIANTE_P;
/

-- SI EL CORREO NO EXISTE RETORNA ID_USUARIO_P = -1 (MISMO CRITERIO DE LAS FUNCIONES)
CREATE OR REPLACE PROCEDURE WU_OBTENER_CREDENCIALES_P(
    CORREO_P VARCHAR2,
    ID_USUARIO_P OUT NUMBER,
    NOMBRE_P OUT VARCHAR2,
    PASSWORD_HASH_P OUT VARCHAR2,
    ROL_P OUT VARCHAR2,
    ESTADO_P OUT VARCHAR2
)
IS
BEGIN
    SELECT ID_USUARIO, NOMBRE, PASSWORD_HASH, ROL, ESTADO
        INTO ID_USUARIO_P, NOMBRE_P, PASSWORD_HASH_P, ROL_P, ESTADO_P
        FROM WU_USUARIO
        WHERE LOWER(CORREO) = LOWER(CORREO_P);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ID_USUARIO_P := -1;
        NOMBRE_P := NULL;
        PASSWORD_HASH_P := NULL;
        ROL_P := NULL;
        ESTADO_P := NULL;
    WHEN OTHERS THEN
        ID_USUARIO_P := -99;
END WU_OBTENER_CREDENCIALES_P;
/

-- ======================================================================
-- GESTOR 1: PUBLICAR APUNTE
-- CREA EL APUNTE EN ESTADO PENDIENTE Y LE ASOCIA HASTA 3 ETIQUETAS
-- ======================================================================

CREATE OR REPLACE PROCEDURE WU_PUBLICAR_APUNTE_P(
    TITULO_P VARCHAR2,
    DESCRIPCION_P VARCHAR2,
    RUTA_ARCHIVO_P VARCHAR2,
    ID_USUARIO_P NUMBER,
    ID_ASIGNATURA_P NUMBER,
    ID_TIPO_P NUMBER,
    ID_PROFESOR_P NUMBER,
    ID_ETIQUETA1_P NUMBER,
    ID_ETIQUETA2_P NUMBER,
    ID_ETIQUETA3_P NUMBER,
    ID_APUNTE_P OUT NUMBER
)
IS
    CONTADOR_V NUMBER;
    ETIQUETA_V NUMBER;
    CODIGO_V NUMBER;
BEGIN
    LOCK TABLE WU_APUNTE IN ROW EXCLUSIVE MODE;
    LOCK TABLE WU_APUNTE_ETIQUETA IN ROW EXCLUSIVE MODE;

    IF WU_USUARIO_ACTIVO_F(ID_USUARIO_P) <> 1 THEN
        RAISE_APPLICATION_ERROR(-20030, 'El usuario no existe o esta bloqueado.');
    END IF;

    ID_APUNTE_P := WU_SIGUIENTE_ID_APUNTE_F();

    INSERT INTO WU_APUNTE(
        ID_APUNTE,
        ID_USUARIO,
        ID_ASIGNATURA,
        ID_TIPO,
        ID_PROFESOR,
        TITULO,
        DESCRIPCION,
        RUTA_ARCHIVO,
        FECHA_SUBIDA,
        ESTADO
    )
    VALUES(
        ID_APUNTE_P,
        ID_USUARIO_P,
        ID_ASIGNATURA_P,
        ID_TIPO_P,
        ID_PROFESOR_P,
        TITULO_P,
        DESCRIPCION_P,
        RUTA_ARCHIVO_P,
        SYSDATE,
        'PENDIENTE'
    );

    -- ETIQUETAS: SE IGNORAN LAS NULAS Y LAS REPETIDAS
    FOR I IN 1..3 LOOP
        IF I = 1 THEN
            ETIQUETA_V := ID_ETIQUETA1_P;
        ELSIF I = 2 THEN
            ETIQUETA_V := ID_ETIQUETA2_P;
        ELSE
            ETIQUETA_V := ID_ETIQUETA3_P;
        END IF;

        IF ETIQUETA_V IS NOT NULL THEN
            SELECT COUNT(*)
                INTO CONTADOR_V
                FROM WU_APUNTE_ETIQUETA
                WHERE ID_APUNTE = ID_APUNTE_P AND ID_ETIQUETA = ETIQUETA_V;

            IF CONTADOR_V = 0 THEN
                INSERT INTO WU_APUNTE_ETIQUETA(ID_APUNTE, ID_ETIQUETA)
                VALUES(ID_APUNTE_P, ETIQUETA_V);
            END IF;
        END IF;
    END LOOP;

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
            RAISE_APPLICATION_ERROR(-20010, 'Error inesperado en WU_PUBLICAR_APUNTE_P.');
        END IF;
END WU_PUBLICAR_APUNTE_P;
/

-- ======================================================================
-- GESTOR 2: MODERAR APUNTE
-- SOLO UN ADMINISTRADOR APRUEBA O RECHAZA. QUEDA REGISTRO EN WU_MODERACION
-- ======================================================================

CREATE OR REPLACE PROCEDURE WU_MODERAR_APUNTE_P(
    ID_APUNTE_P NUMBER,
    ID_ADMIN_P NUMBER,
    DECISION_P VARCHAR2,
    MOTIVO_P VARCHAR2
)
IS
    ESTADO_V WU_APUNTE.ESTADO%TYPE;
    CODIGO_V NUMBER;
BEGIN
    LOCK TABLE WU_APUNTE IN ROW EXCLUSIVE MODE;
    LOCK TABLE WU_MODERACION IN ROW EXCLUSIVE MODE;

    IF WU_ES_ADMIN_F(ID_ADMIN_P) <> 1 THEN
        RAISE_APPLICATION_ERROR(-20031, 'Solo un administrador puede moderar apuntes.');
    END IF;

    IF DECISION_P NOT IN ('ACTIVO', 'RECHAZADO') THEN
        RAISE_APPLICATION_ERROR(-20033, 'La decision debe ser ACTIVO o RECHAZADO.');
    END IF;

    IF DECISION_P = 'RECHAZADO' AND MOTIVO_P IS NULL THEN
        RAISE_APPLICATION_ERROR(-20035, 'Debe indicar el motivo del rechazo.');
    END IF;

    IF WU_ESTADO_APUNTE_F(ID_APUNTE_P) = 'NO_EXISTE' THEN
        RAISE_APPLICATION_ERROR(-20032, 'El apunte no existe.');
    END IF;

    SELECT ESTADO
        INTO ESTADO_V
        FROM WU_APUNTE
        WHERE ID_APUNTE = ID_APUNTE_P
        FOR UPDATE;

    INSERT INTO WU_MODERACION(
        ID_MODERACION,
        ID_APUNTE,
        ID_ADMIN,
        DECISION,
        MOTIVO,
        FECHA_MODERACION
    )
    VALUES(
        WU_SIGUIENTE_ID_MODERACION_F(),
        ID_APUNTE_P,
        ID_ADMIN_P,
        DECISION_P,
        MOTIVO_P,
        SYSDATE
    );

    UPDATE WU_APUNTE
        SET ESTADO = DECISION_P
        WHERE ID_APUNTE = ID_APUNTE_P;

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
            RAISE_APPLICATION_ERROR(-20010, 'Error inesperado en WU_MODERAR_APUNTE_P.');
        END IF;
END WU_MODERAR_APUNTE_P;
/

-- ======================================================================
-- GESTOR 3: REGISTRAR DESCARGA
-- DEVUELVE LA RUTA DEL ARCHIVO PARA QUE LA APLICACION LO ENTREGUE
-- ======================================================================

CREATE OR REPLACE PROCEDURE WU_REGISTRAR_DESCARGA_P(
    ID_APUNTE_P NUMBER,
    ID_USUARIO_P NUMBER,
    TOTAL_DESCARGAS_P OUT NUMBER,
    RUTA_ARCHIVO_P OUT VARCHAR2
)
IS
    CODIGO_V NUMBER;
BEGIN
    LOCK TABLE WU_DESCARGA IN ROW EXCLUSIVE MODE;

    IF WU_USUARIO_ACTIVO_F(ID_USUARIO_P) <> 1 THEN
        RAISE_APPLICATION_ERROR(-20030, 'El usuario no existe o esta bloqueado.');
    END IF;

    IF WU_ESTADO_APUNTE_F(ID_APUNTE_P) <> 'ACTIVO' THEN
        RAISE_APPLICATION_ERROR(-20034, 'Solo se pueden descargar apuntes activos.');
    END IF;

    SELECT RUTA_ARCHIVO
        INTO RUTA_ARCHIVO_P
        FROM WU_APUNTE
        WHERE ID_APUNTE = ID_APUNTE_P;

    INSERT INTO WU_DESCARGA(
        ID_DESCARGA,
        ID_USUARIO,
        ID_APUNTE,
        FECHA_DESCARGA
    )
    VALUES(
        WU_SIGUIENTE_ID_DESCARGA_F(),
        ID_USUARIO_P,
        ID_APUNTE_P,
        SYSDATE
    );

    TOTAL_DESCARGAS_P := WU_TOTAL_DESCARGAS_F(ID_APUNTE_P);

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
            RAISE_APPLICATION_ERROR(-20010, 'Error inesperado en WU_REGISTRAR_DESCARGA_P.');
        END IF;
END WU_REGISTRAR_DESCARGA_P;
/

-- ======================================================================
-- GESTOR 4: VALORAR APUNTE
-- UNA VALORACION POR USUARIO Y APUNTE: SI YA EXISTE SE ACTUALIZA
-- ======================================================================

CREATE OR REPLACE PROCEDURE WU_VALORAR_APUNTE_P(
    ID_APUNTE_P NUMBER,
    ID_USUARIO_P NUMBER,
    PUNTUACION_P NUMBER,
    PROMEDIO_P OUT NUMBER,
    TOTAL_VALORACIONES_P OUT NUMBER
)
IS
    CONTADOR_V NUMBER;
    AUTOR_V WU_APUNTE.ID_USUARIO%TYPE;
    CODIGO_V NUMBER;
BEGIN
    LOCK TABLE WU_VALORACION IN ROW EXCLUSIVE MODE;

    IF WU_USUARIO_ACTIVO_F(ID_USUARIO_P) <> 1 THEN
        RAISE_APPLICATION_ERROR(-20030, 'El usuario no existe o esta bloqueado.');
    END IF;

    IF PUNTUACION_P IS NULL OR PUNTUACION_P < 1 OR PUNTUACION_P > 5 OR PUNTUACION_P <> TRUNC(PUNTUACION_P) THEN
        RAISE_APPLICATION_ERROR(-20023, 'El puntuacion debe ser un entero entre 1 y 5.');
    END IF;

    IF WU_ESTADO_APUNTE_F(ID_APUNTE_P) <> 'ACTIVO' THEN
        RAISE_APPLICATION_ERROR(-20034, 'Solo se pueden valorar apuntes activos.');
    END IF;

    SELECT ID_USUARIO
        INTO AUTOR_V
        FROM WU_APUNTE
        WHERE ID_APUNTE = ID_APUNTE_P;
    IF AUTOR_V = ID_USUARIO_P THEN
        RAISE_APPLICATION_ERROR(-20021, 'No puede valorar su propio apunte.');
    END IF;

    SELECT COUNT(*)
        INTO CONTADOR_V
        FROM WU_VALORACION
        WHERE ID_APUNTE = ID_APUNTE_P AND ID_USUARIO = ID_USUARIO_P;

    IF CONTADOR_V > 0 THEN
        UPDATE WU_VALORACION
            SET PUNTUACION = PUNTUACION_P,
                FECHA_VALORACION = SYSDATE
            WHERE ID_APUNTE = ID_APUNTE_P AND ID_USUARIO = ID_USUARIO_P;
    ELSE
        INSERT INTO WU_VALORACION(
            ID_VALORACION,
            ID_USUARIO,
            ID_APUNTE,
            PUNTUACION,
            FECHA_VALORACION
        )
        VALUES(
            WU_SIGUIENTE_ID_VALORACION_F(),
            ID_USUARIO_P,
            ID_APUNTE_P,
            PUNTUACION_P,
            SYSDATE
        );
    END IF;

    PROMEDIO_P := WU_PROMEDIO_VALORACION_F(ID_APUNTE_P);
    TOTAL_VALORACIONES_P := WU_TOTAL_VALORACIONES_F(ID_APUNTE_P);

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
            RAISE_APPLICATION_ERROR(-20010, 'Error inesperado en WU_VALORAR_APUNTE_P.');
        END IF;
END WU_VALORAR_APUNTE_P;
/

-- ======================================================================
-- GESTOR 5: ALTERNAR FAVORITO
-- SI EL APUNTE YA ES FAVORITO LO QUITA, SI NO LO AGREGA
-- ES_FAVORITO_P RETORNA 1 (QUEDO COMO FAVORITO) O 0 (SE QUITO)
-- ======================================================================

CREATE OR REPLACE PROCEDURE WU_ALTERNAR_FAVORITO_P(
    ID_APUNTE_P NUMBER,
    ID_USUARIO_P NUMBER,
    ES_FAVORITO_P OUT NUMBER
)
IS
    CONTADOR_V NUMBER;
    CODIGO_V NUMBER;
BEGIN
    LOCK TABLE WU_FAVORITO IN ROW EXCLUSIVE MODE;

    IF WU_USUARIO_ACTIVO_F(ID_USUARIO_P) <> 1 THEN
        RAISE_APPLICATION_ERROR(-20030, 'El usuario no existe o esta bloqueado.');
    END IF;

    IF WU_ESTADO_APUNTE_F(ID_APUNTE_P) = 'NO_EXISTE' THEN
        RAISE_APPLICATION_ERROR(-20032, 'El apunte no existe.');
    END IF;

    SELECT COUNT(*)
        INTO CONTADOR_V
        FROM WU_FAVORITO
        WHERE ID_APUNTE = ID_APUNTE_P AND ID_USUARIO = ID_USUARIO_P;

    IF CONTADOR_V > 0 THEN
        DELETE FROM WU_FAVORITO
            WHERE ID_APUNTE = ID_APUNTE_P AND ID_USUARIO = ID_USUARIO_P;
        ES_FAVORITO_P := 0;
    ELSE
        IF WU_ESTADO_APUNTE_F(ID_APUNTE_P) <> 'ACTIVO' THEN
            RAISE_APPLICATION_ERROR(-20034, 'Solo se pueden guardar apuntes activos.');
        END IF;
        INSERT INTO WU_FAVORITO(ID_USUARIO, ID_APUNTE, FECHA_FAVORITO)
        VALUES(ID_USUARIO_P, ID_APUNTE_P, SYSDATE);
        ES_FAVORITO_P := 1;
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
            RAISE_APPLICATION_ERROR(-20010, 'Error inesperado en WU_ALTERNAR_FAVORITO_P.');
        END IF;
END WU_ALTERNAR_FAVORITO_P;
/
