import os
import oracledb
from dotenv import load_dotenv

load_dotenv()

def get_conexion():
    """Abre una conexión con Oracle."""
    usuario = os.getenv("DB_USER")
    clave = os.getenv("DB_PASS")
    dsn = os.getenv("DB_DSN", "localhost:1521/XEPDB1")

    if not usuario or not clave:
        raise RuntimeError(
            "Configura ORACLE_USER y ORACLE_PASSWORD."
        )

    return oracledb.connect(
        user=usuario,
        password=clave,
        dsn=dsn
    )


def consultar(sql, parametros=None):
    """Ejecuta un SELECT y devuelve una lista de diccionarios."""
    with get_conexion() as conexion:
        with conexion.cursor() as cursor:
            cursor.execute(sql, parametros or {})

            if cursor.description is None:
                raise ValueError("La consulta no devuelve filas.")

            columnas = [
                col[0].lower()
                for col in cursor.description
            ]

            return [
                dict(zip(columnas, fila))
                for fila in cursor.fetchall()
            ]


def ejecutar(sql, parametros=None):
    """Ejecuta INSERT, UPDATE o DELETE."""
    with get_conexion() as conexion:
        try:
            with conexion.cursor() as cursor:
                cursor.execute(sql, parametros or {})
                filas = cursor.rowcount

            conexion.commit()
            return filas

        except Exception:
            conexion.rollback()
            raise


def llamar_procedimiento(nombre, parametros=None):
    """Ejecuta un procedimiento PL/SQL."""
    with get_conexion() as conexion:
        try:
            with conexion.cursor() as cursor:
                resultado = cursor.callproc(
                    nombre, parametros or []
                )

            conexion.commit()
            return resultado

        except Exception:
            conexion.rollback()
            raise


def llamar_funcion(nombre, tipo_retorno, parametros=None):
    """Ejecuta una función PL/SQL."""
    with get_conexion() as conexion:
        with conexion.cursor() as cursor:
            return cursor.callfunc(
                nombre, tipo_retorno, parametros or []
            )


if __name__ == "__main__":
    try:
        print(consultar("SELECT 1 AS ok FROM dual"))
    except (oracledb.Error, RuntimeError) as error:
        print("Error de conexión:", error)
