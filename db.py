"""Conexion a Oracle.

La aplicacion no escribe SQL: todo se hace llamando procedimientos almacenados
(PL/SQL). Las credenciales vienen de variables de entorno.
"""
import logging
import os
import re

import oracledb

_pool = None

NUMERO = oracledb.DB_TYPE_NUMBER
TEXTO = oracledb.DB_TYPE_VARCHAR
CURSOR = oracledb.DB_TYPE_CURSOR


class ErrorBD(Exception):
    """Error que devuelve un procedimiento (el mensaje ya se puede mostrar)."""

    def __init__(self, mensaje):
        super().__init__(mensaje)
        self.mensaje = mensaje


class Salida:
    """Marca un parametro OUT del procedimiento."""

    def __init__(self, tipo):
        self.tipo = tipo


SAL_NUM = Salida(NUMERO)
SAL_TXT = Salida(TEXTO)
SAL_CUR = Salida(CURSOR)


def _conexiones():
    global _pool
    if _pool is None:
        _pool = oracledb.create_pool(
            user=os.environ["ORACLE_USER"],
            password=os.environ["ORACLE_PASSWORD"],
            dsn=os.environ["ORACLE_DSN"],
            min=1, max=5, increment=1,
            # si no hay conexion libre en 10 s se produce un error en vez de esperar para siempre
            getmode=oracledb.POOL_GETMODE_TIMEDWAIT, wait_timeout=10000,
        )
    return _pool


def _filas(cursor):
    columnas = [c[0].lower() for c in cursor.description]
    return [dict(zip(columnas, fila)) for fila in cursor.fetchall()]


def _mensaje(error):
    # Los errores propios de los procedimientos son ORA-20001 ... ORA-20999
    texto = str(error)
    encontrado = re.search(r"ORA-20\d{3}: (.*)", texto)
    if encontrado:
        return encontrado.group(1).strip()
    logging.getLogger(__name__).error("Error de Oracle: %s", texto)
    return "No se pudo completar la operacion en la base de datos."


def llamar(procedimiento, *parametros):
    """Llama un procedimiento y devuelve la lista de sus parametros OUT.

    Cada Salida se entrega en orden: un numero, un texto o, si es un cursor,
    una lista de diccionarios con las columnas en minuscula.
    """
    with _conexiones().acquire() as conexion:
        with conexion.cursor() as cursor:
            enviados, salidas = [], []
            for parametro in parametros:
                if isinstance(parametro, Salida):
                    if parametro.tipo is CURSOR:
                        # los cursores de salida se pasan como cursores normales: con cursor.var()
                        # la llamada se queda colgada en oracledb 4.x cuando hay parametros de entrada
                        variable = conexion.cursor()
                    else:
                        variable = cursor.var(parametro.tipo)
                    enviados.append(variable)
                    salidas.append(variable)
                else:
                    enviados.append(parametro)
            try:
                cursor.callproc(procedimiento, enviados)
            except oracledb.DatabaseError as error:
                raise ErrorBD(_mensaje(error)) from error

            resultado = []
            for variable in salidas:
                if isinstance(variable, oracledb.Cursor):
                    resultado.append(_filas(variable))
                    variable.close()
                else:
                    resultado.append(variable.getvalue())
            return resultado


def lista(procedimiento, *parametros):
    """Atajo para los procedimientos que entregan un solo cursor."""
    return llamar(procedimiento, *parametros, SAL_CUR)[0]
