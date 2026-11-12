import os
import oracledb
from dotenv import load_dotenv

load_dotenv()

USUARIO = os.environ["DB_USER"]
CLAVE = os.environ["DB_PASS"]
DSN = os.environ["DB_DSN"]


def get_conexion():
    return oracledb.connect(user=USUARIO, password=CLAVE, dsn=DSN)


def consultar(sql, params=None):
    """SELECT: devuelve una lista de diccionarios."""
    with get_conexion() as con:
        with con.cursor() as cur:
            cur.execute(sql, params or {})
            columnas = [c[0].lower() for c in cur.description]
            return [dict(zip(columnas, fila)) for fila in cur.fetchall()]


def ejecutar(sql, params=None):
    """INSERT / UPDATE / DELETE."""
    with get_conexion() as con:
        with con.cursor() as cur:
            cur.execute(sql, params or {})
        con.commit()


def llamar_procedimiento(nombre, args=None):
    """Llama a un procedimiento PL/SQL."""
    with get_conexion() as con:
        with con.cursor() as cur:
            cur.callproc(nombre, args or [])
        con.commit()


def llamar_funcion(nombre, tipo_retorno, args=None):
    """Llama a una función PL/SQL y devuelve su resultado."""
    with get_conexion() as con:
        with con.cursor() as cur:
            return cur.callfunc(nombre, tipo_retorno, args or [])