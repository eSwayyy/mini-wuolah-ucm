"""Definicion de los 10 mantenedores (CRUD) del administrador.

Cada mantenedor usa los procedimientos de 04_mantenedores.sql:
    WU_<NOMBRE>_LISTAR_P(CURSOR_P OUT)
    WU_<NOMBRE>_IUD_P(OPCION_P, <claves>, <campos en el mismo orden que 'campos'>)

claves : columnas que identifican el registro (la clave simple se genera con secuencia)
campos : columnas que se pueden editar, en el orden de los parametros del procedimiento
  tipo  : texto | area | numero | password | select
  de    : para 'select', de donde salen las opciones:
            ("FACULTAD", "id_facultad", "nombre")  -> otro mantenedor
            [("ESTUDIANTE", "Estudiante"), ...]    -> lista fija
"""

SI_NO = [("1", "Si"), ("0", "No")]

MANTENEDORES = {
    "facultades": dict(
        nombre="FACULTAD", titulo="Facultades", icono="fa-building-columns",
        claves=["id_facultad"],
        campos=[("nombre", "Nombre", "texto", None)],
        columnas=[("id_facultad", "ID"), ("nombre", "Nombre")],
    ),
    "carreras": dict(
        nombre="CARRERA", titulo="Carreras", icono="fa-graduation-cap",
        claves=["id_carrera"],
        campos=[("codigo", "Codigo", "texto", None),
                ("nombre", "Nombre", "texto", None),
                ("id_facultad", "Facultad", "select", ("facultades", "id_facultad", "nombre"))],
        columnas=[("id_carrera", "ID"), ("codigo", "Codigo"), ("nombre", "Nombre"), ("facultad", "Facultad")],
    ),
    "profesores": dict(
        nombre="PROFESOR", titulo="Profesores", icono="fa-chalkboard-user",
        claves=["id_profesor"],
        campos=[("nombre", "Nombre", "texto", None),
                ("apellido", "Apellido", "texto", None),
                ("id_facultad", "Facultad", "select", ("facultades", "id_facultad", "nombre"))],
        columnas=[("id_profesor", "ID"), ("nombre", "Nombre"), ("apellido", "Apellido"), ("facultad", "Facultad")],
    ),
    "asignaturas": dict(
        nombre="ASIGNATURA", titulo="Asignaturas", icono="fa-book",
        claves=["id_asignatura"],
        campos=[("codigo", "Codigo", "texto", None), ("nombre", "Nombre", "texto", None)],
        columnas=[("id_asignatura", "ID"), ("codigo", "Codigo"), ("nombre", "Nombre")],
    ),
    "malla": dict(
        nombre="CARRERA_ASIGNATURA", titulo="Malla (carrera - asignatura)", icono="fa-table-list",
        claves=["id_carrera", "id_asignatura"], compuesta=True,
        campos=[("semestre", "Semestre", "numero", None)],
        claves_select=[("id_carrera", "Carrera", ("carreras", "id_carrera", "nombre")),
                       ("id_asignatura", "Asignatura", ("asignaturas", "id_asignatura", "nombre"))],
        columnas=[("carrera", "Carrera"), ("codigo", "Codigo"), ("asignatura", "Asignatura"), ("semestre", "Semestre")],
    ),
    "tipos": dict(
        nombre="TIPO_APUNTE", titulo="Tipos de apunte", icono="fa-tags",
        claves=["id_tipo"],
        campos=[("nombre", "Nombre", "texto", None)],
        columnas=[("id_tipo", "ID"), ("nombre", "Nombre")],
    ),
    "etiquetas": dict(
        nombre="ETIQUETA", titulo="Etiquetas", icono="fa-hashtag",
        claves=["id_etiqueta"],
        campos=[("nombre", "Nombre", "texto", None)],
        columnas=[("id_etiqueta", "ID"), ("nombre", "Nombre")],
    ),
    "usuarios": dict(
        nombre="USUARIO", titulo="Usuarios", icono="fa-users",
        claves=["id_usuario"],
        campos=[("id_carrera", "Carrera", "select", ("carreras", "id_carrera", "nombre")),
                ("nombre", "Nombre", "texto", None),
                ("correo", "Correo", "texto", None),
                ("password_hash", "Contraseña (vacia = no cambia)", "password", None),
                ("rol", "Rol", "select", [("ESTUDIANTE", "Estudiante"), ("ADMIN", "Administrador")]),
                ("estado", "Estado", "select", [("ACTIVO", "Activo"), ("BLOQUEADO", "Bloqueado")])],
        columnas=[("id_usuario", "ID"), ("nombre", "Nombre"), ("correo", "Correo"), ("rol", "Rol"),
                  ("carrera", "Carrera"), ("estado", "Estado")],
    ),
    "apuntes": dict(
        nombre="APUNTE", titulo="Apuntes", icono="fa-file-pdf", listar_args=[None],
        claves=["id_apunte"],
        campos=[("id_usuario", "Autor", "select", ("usuarios", "id_usuario", "nombre")),
                ("id_asignatura", "Asignatura", "select", ("asignaturas", "id_asignatura", "nombre")),
                ("id_tipo", "Tipo", "select", ("tipos", "id_tipo", "nombre")),
                ("id_profesor", "Profesor", "select", ("profesores", "id_profesor", "apellido")),
                ("titulo", "Titulo", "texto", None),
                ("descripcion", "Descripcion", "area", None),
                ("ruta_archivo", "Ruta del archivo", "texto", None),
                ("estado", "Estado", "select", [("PENDIENTE", "Pendiente"), ("ACTIVO", "Activo"),
                                                ("RECHAZADO", "Rechazado"), ("OCULTO", "Oculto")])],
        columnas=[("id_apunte", "ID"), ("titulo", "Titulo"), ("autor", "Autor"), ("asignatura", "Asignatura"),
                  ("estado", "Estado")],
    ),
    "comentarios": dict(
        nombre="COMENTARIO", titulo="Comentarios", icono="fa-comments",
        claves=["id_comentario"],
        campos=[("id_usuario", "Usuario", "select", ("usuarios", "id_usuario", "nombre")),
                ("id_apunte", "Apunte", "select", ("apuntes", "id_apunte", "titulo")),
                ("contenido", "Contenido", "area", None),
                ("visible", "Visible", "select", SI_NO)],
        columnas=[("id_comentario", "ID"), ("apunte", "Apunte"), ("autor", "Autor"), ("contenido", "Contenido"),
                  ("visible", "Visible")],
    ),
}

# Campos que se envian como numero al procedimiento (el resto va como texto)
CAMPOS_NUMERICOS = {"id_facultad", "id_carrera", "id_asignatura", "id_profesor", "id_usuario", "id_tipo",
                    "id_apunte", "semestre", "visible"}

# Largo maximo de cada campo de texto (el mismo de la columna en Oracle), para validar en el formulario
LARGOS = {
    "facultades": {"nombre": 120},
    "carreras": {"codigo": 20, "nombre": 150},
    "profesores": {"nombre": 80, "apellido": 80},
    "asignaturas": {"codigo": 20, "nombre": 150},
    "tipos": {"nombre": 60},
    "etiquetas": {"nombre": 40},
    "usuarios": {"nombre": 100, "correo": 150},
    "apuntes": {"titulo": 200, "descripcion": 1000, "ruta_archivo": 500},
    "comentarios": {"contenido": 1000},
}

# Campos que pueden quedar vacios (el resto es obligatorio)
OPCIONALES = {"apuntes": {"descripcion", "id_profesor"}, "usuarios": {"id_carrera"}}
