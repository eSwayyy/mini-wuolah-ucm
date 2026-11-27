"""Wuolah UCM: aplicacion web (Flask + Jinja) sobre Oracle.

Capa de presentacion: esta aplicacion.
Capa de datos: Oracle (PL/SQL). La aplicacion NO contiene SQL: solo llama
procedimientos almacenados mediante db.llamar() / db.lista().
"""
import os
import uuid
from datetime import datetime
from functools import wraps
from pathlib import Path

from dotenv import load_dotenv
from flask import (Flask, abort, flash, redirect, render_template, request,
                   send_file, session, url_for)
from werkzeug.security import check_password_hash, generate_password_hash

load_dotenv()

from db import ErrorBD, SAL_NUM, SAL_TXT, SAL_CUR, llamar, lista  # noqa: E402
from mantenedores import CAMPOS_NUMERICOS, LARGOS, MANTENEDORES, OPCIONALES  # noqa: E402

app = Flask(__name__)
app.secret_key = os.environ["SECRET_KEY"]
# Nombre propio: otros proyectos Flask en 127.0.0.1 comparten cookies llamados "session".
app.config["SESSION_COOKIE_NAME"] = "wuolah_sesion"
app.config["MAX_CONTENT_LENGTH"] = 20 * 1024 * 1024  # PDF de hasta 20 MB
UPLOADS = Path(app.root_path) / "uploads"


# ---------------------------------------------------------------------
# Utilidades
# ---------------------------------------------------------------------
def entero(valor):
    try:
        return int(valor)
    except (TypeError, ValueError):
        return None


def ruta_absoluta(ruta):
    """Ruta guardada en Oracle -> archivo dentro de uploads/ (o None si no existe)."""
    if not ruta:
        return None
    archivo = (Path(app.root_path) / ruta).resolve()
    if UPLOADS.resolve() not in archivo.parents:
        return None
    return archivo if archivo.is_file() else None


def tarjeta(a, id_carrera=None):
    """Fila de un procedimiento de apuntes -> nombres que usan las plantillas."""
    return {
        "id_apunte": a["id_apunte"], "titulo": a["titulo"], "descripcion": a["descripcion"] or "",
        "tipo": a["tipo"], "estado": a["estado"], "fecha_subida": a["fecha_subida"].strftime("%d/%m/%Y"),
        "id_usuario": a["id_usuario"], "autor": a["autor"],
        "carrera": a["carrera_autor"], "id_carrera": id_carrera,
        "id_asignatura": a["id_asignatura"], "asignatura": a["asignatura"],
        "archivo": Path(a["ruta_archivo"]).name,
        "archivo_disponible": ruta_absoluta(a["ruta_archivo"]) is not None,
        "likes": a["favoritos"], "comentarios": a["comentarios"], "descargas": a["descargas"],
        "promedio": a["promedio"], "total_valoraciones": a["total_valoraciones"],
    }


def apunte_visible(apunte_id):
    """Apunte activo, o cualquiera si lo pide su autor o un administrador."""
    filas = lista("WU_APUNTE_OBTENER_P", apunte_id)
    if not filas:
        abort(404)
    apunte = filas[0]
    usuario = session.get("usuario")
    if apunte["estado"] != "ACTIVO":
        if not usuario or (usuario["rol"] != "ADMIN" and usuario["id"] != apunte["id_usuario"]):
            abort(404)
    return apunte


def destino_seguro(ruta):
    """Solo se redirige a rutas internas (evita redirecciones a otros sitios)."""
    if ruta and ruta.startswith("/") and not ruta.startswith("//"):
        return ruta
    return url_for("inicio")


def login_requerido(f):
    @wraps(f)
    def interna(*args, **kwargs):
        if "usuario" not in session:
            flash("Inicia sesión para continuar.", "warning")
            return redirect(url_for("login", siguiente=request.full_path.rstrip("?")))
        return f(*args, **kwargs)
    return interna


def admin_requerido(f):
    @wraps(f)
    @login_requerido
    def interna(*args, **kwargs):
        if session["usuario"]["rol"] != "ADMIN":
            abort(403)
        return f(*args, **kwargs)
    return interna


@app.errorhandler(ErrorBD)
def error_procedimiento(error):
    flash(error.mensaje, "danger")
    if request.method == "POST" or request.endpoint != "inicio":
        return redirect(request.referrer or url_for("inicio"))
    return error.mensaje, 500


# ---------------------------------------------------------------------
# Sesion
# ---------------------------------------------------------------------
@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        correo = request.form.get("correo", "").strip().lower()
        clave = request.form.get("clave", "")
        id_usuario, nombre, hash_clave, rol, estado = llamar(
            "WU_OBTENER_CREDENCIALES_P", correo, SAL_NUM, SAL_TXT, SAL_TXT, SAL_TXT, SAL_TXT)
        if int(id_usuario) == -1 or not check_password_hash(hash_clave, clave):
            flash("Correo o contraseña incorrectos.", "danger")
            return redirect(url_for("login"))
        if estado != "ACTIVO":
            flash("Tu cuenta está bloqueada. Contacta a un administrador.", "danger")
            return redirect(url_for("login"))
        session.clear()
        session["usuario"] = {"id": int(id_usuario), "nombre": nombre, "rol": rol}
        return redirect(destino_seguro(request.args.get("siguiente")))
    return render_template("login.html")


@app.route("/registro", methods=["GET", "POST"])
def registro():
    carreras = lista("WU_CARRERA_LISTAR_P")
    if request.method == "POST":
        clave = request.form.get("clave", "")
        if len(clave) < 8:
            flash("La contraseña debe tener al menos 8 caracteres.", "danger")
            return redirect(url_for("registro"))
        id_usuario = llamar(
            "WU_REGISTRAR_ESTUDIANTE_P",
            request.form.get("nombre", "").strip(),
            request.form.get("correo", "").strip().lower(),
            generate_password_hash(clave, method="pbkdf2:sha256"),
            entero(request.form.get("carrera")),
            SAL_NUM)[0]
        session.clear()
        session["usuario"] = {"id": int(id_usuario), "nombre": request.form.get("nombre", "").strip(),
                              "rol": "ESTUDIANTE"}
        flash("Cuenta creada. ¡Bienvenido a Wuolah UCM!", "success")
        return redirect(url_for("inicio"))
    return render_template("registro.html", carreras=carreras)


@app.route("/logout", methods=["POST"])
def logout():
    session.clear()
    return redirect(url_for("inicio"))


# ---------------------------------------------------------------------
# Paginas publicas
# ---------------------------------------------------------------------
@app.route("/")
@app.route("/inicio")
def inicio():
    populares = lista("WU_APUNTES_POPULARES_P")
    return render_template("inicio.html", destacados=[tarjeta(a) for a in populares[:3]])


@app.route("/apuntes")
def apuntes():
    carrera = request.args.get("carrera", type=int)
    asignatura = request.args.get("asignatura", type=int)
    busqueda = request.args.get("q", "").strip()

    carreras = lista("WU_CARRERA_LISTAR_P")
    if carrera not in {c["id_carrera"] for c in carreras}:
        carrera = None
    asignaturas = lista("WU_ASIGNATURAS_CARRERA_P", carrera)
    if asignatura not in {a["id_asignatura"] for a in asignaturas}:
        asignatura = None

    filas = lista("WU_BUSCAR_APUNTES_P", busqueda or None, carrera, asignatura, None, None, None)
    return render_template(
        "apuntes.html", carreras=carreras, asignaturas=asignaturas,
        apuntes=[tarjeta(a, carrera) for a in filas],
        carrera_seleccionada=carrera, asignatura_seleccionada=asignatura, busqueda=busqueda)


@app.route("/apuntes/<int:apunte_id>")
def detalle_apunte(apunte_id):
    apunte = apunte_visible(apunte_id)
    usuario = session.get("usuario")
    es_favorito = False
    if usuario:
        es_favorito = apunte_id in {f["id_apunte"] for f in lista("WU_MIS_FAVORITOS_P", usuario["id"])}
    return render_template(
        "detalle.html", apunte=tarjeta(apunte), profesor=apunte["profesor"], codigo=apunte["codigo_asignatura"],
        etiquetas=lista("WU_APUNTE_ETIQUETAS_P", apunte_id),
        comentarios=lista("WU_COMENTARIOS_APUNTE_P", apunte_id), es_favorito=es_favorito)


@app.route("/apuntes/<int:apunte_id>/pdf")
def ver_pdf(apunte_id):
    apunte = apunte_visible(apunte_id)
    archivo = ruta_absoluta(apunte["ruta_archivo"])
    if archivo is None:
        abort(404)
    return send_file(archivo, mimetype="application/pdf")


@app.route("/usuarios/<int:usuario_id>")
def perfil_usuario(usuario_id):
    filas = lista("WU_USUARIO_OBTENER_P", usuario_id)
    if not filas:
        abort(404)
    sesion = session.get("usuario")
    es_propio = bool(sesion) and sesion["id"] == usuario_id
    publicados = lista("WU_MIS_APUNTES_P", usuario_id)
    if not es_propio and not (sesion and sesion["rol"] == "ADMIN"):
        publicados = [a for a in publicados if a["estado"] == "ACTIVO"]
    favoritos = lista("WU_MIS_FAVORITOS_P", usuario_id) if es_propio else []
    return render_template(
        "perfil.html", usuario=filas[0], es_propio=es_propio,
        apuntes=[tarjeta(a) for a in publicados], favoritos=[tarjeta(a) for a in favoritos])


@app.route("/mi-cuenta")
@login_requerido
def mi_perfil():
    return redirect(url_for("perfil_usuario", usuario_id=session["usuario"]["id"]))


# ---------------------------------------------------------------------
# Gestores del estudiante
# ---------------------------------------------------------------------
@app.route("/subir", methods=["GET", "POST"])  # GESTOR 1: publicar apunte
@login_requerido
def subir():
    if request.method == "POST":
        archivo = request.files.get("archivo")
        if not archivo or not archivo.filename.lower().endswith(".pdf") or archivo.stream.read(4) != b"%PDF":
            flash("Debes adjuntar un archivo PDF válido.", "danger")
            return redirect(url_for("subir"))
        archivo.stream.seek(0)
        nombre = uuid.uuid4().hex + ".pdf"
        destino = UPLOADS / nombre
        archivo.save(destino)
        etiquetas = [entero(request.form.get(f"etiqueta{i}")) for i in (1, 2, 3)]
        try:
            llamar("WU_PUBLICAR_APUNTE_P",
                   request.form.get("titulo", "").strip(), request.form.get("descripcion", "").strip(),
                   f"uploads/{nombre}", session["usuario"]["id"],
                   entero(request.form.get("asignatura")), entero(request.form.get("tipo")),
                   entero(request.form.get("profesor")), *etiquetas, SAL_NUM)
        except ErrorBD:
            destino.unlink(missing_ok=True)
            raise
        flash("Apunte enviado. Se publicará cuando un administrador lo apruebe.", "success")
        return redirect(url_for("mi_perfil"))
    return render_template(
        "subir.html", asignaturas=lista("WU_ASIGNATURAS_CARRERA_P", None),
        tipos=lista("WU_TIPO_APUNTE_LISTAR_P"), profesores=lista("WU_PROFESOR_LISTAR_P"),
        etiquetas=lista("WU_ETIQUETA_LISTAR_P"))


@app.route("/apuntes/<int:apunte_id>/descargar")  # GESTOR 3: registrar descarga
@login_requerido
def descargar_pdf(apunte_id):
    apunte = apunte_visible(apunte_id)
    if ruta_absoluta(apunte["ruta_archivo"]) is None:
        abort(404)
    _, ruta = llamar("WU_REGISTRAR_DESCARGA_P", apunte_id, session["usuario"]["id"], SAL_NUM, SAL_TXT)
    return send_file(ruta_absoluta(ruta), as_attachment=True, download_name=apunte["titulo"] + ".pdf",
                     mimetype="application/pdf")


@app.post("/apuntes/<int:apunte_id>/valorar")  # GESTOR 4: valorar apunte
@login_requerido
def valorar(apunte_id):
    promedio, total = llamar("WU_VALORAR_APUNTE_P", apunte_id, session["usuario"]["id"],
                             request.form.get("puntuacion", type=int), SAL_NUM, SAL_NUM)
    flash(f"Valoración guardada. Promedio actual: {promedio} ({int(total)} valoraciones).", "success")
    return redirect(url_for("detalle_apunte", apunte_id=apunte_id))


@app.post("/apuntes/<int:apunte_id>/favorito")  # GESTOR 5: favorito
@login_requerido
def favorito(apunte_id):
    es_favorito = llamar("WU_ALTERNAR_FAVORITO_P", apunte_id, session["usuario"]["id"], SAL_NUM)[0]
    flash("Agregado a tus favoritos." if int(es_favorito) == 1 else "Quitado de tus favoritos.", "success")
    return redirect(url_for("detalle_apunte", apunte_id=apunte_id))


@app.post("/apuntes/<int:apunte_id>/comentar")
@login_requerido
def comentar(apunte_id):
    llamar("WU_COMENTARIO_IUD_P", "I", None, session["usuario"]["id"], apunte_id,
           request.form.get("contenido", "").strip() or None, 1)
    flash("Comentario publicado.", "success")
    return redirect(url_for("detalle_apunte", apunte_id=apunte_id))


# ---------------------------------------------------------------------
# Administrador
# ---------------------------------------------------------------------
@app.route("/admin")
@admin_requerido
def admin():
    return render_template("admin/inicio.html", mantenedores=MANTENEDORES)


def convertir(nombre, valor):
    valor = (valor or "").strip()
    if valor == "":
        return None
    if nombre in CAMPOS_NUMERICOS:
        try:
            return int(valor)
        except ValueError:
            raise ErrorBD(f"El campo {nombre} debe ser numérico.")
    return valor


def opciones(origen):
    """Opciones de un campo select: lista fija u otro mantenedor."""
    if isinstance(origen, list):
        return origen
    clave, valor, texto = origen
    m = MANTENEDORES[clave]
    filas = lista(f"WU_{m['nombre']}_LISTAR_P", *m.get("listar_args", []))
    return [("", "(ninguno)")] + [(str(f[valor]), str(f[texto])) for f in filas]


@app.route("/admin/m/<clave>", methods=["GET", "POST"])  # los 10 mantenedores
@admin_requerido
def mantenedor(clave):
    m = MANTENEDORES.get(clave)
    if m is None:
        abort(404)
    procedimiento = f"WU_{m['nombre']}_IUD_P"

    if request.method == "POST":
        opcion = request.form.get("opcion")
        if opcion not in ("I", "U", "D"):
            abort(400)
        parametros = [opcion] + [convertir(c, request.form.get(c)) for c in m["claves"]]
        for nombre, _, tipo, _ in m["campos"]:
            valor = request.form.get(nombre, "").strip()
            if opcion == "D":
                parametros.append(None)
            elif tipo == "password":
                parametros.append(generate_password_hash(valor, method="pbkdf2:sha256") if valor else None)
            else:
                parametros.append(convertir(nombre, valor))
        llamar(procedimiento, *parametros)
        flash({"I": "Registro creado.", "U": "Registro actualizado.", "D": "Registro eliminado."}[opcion],
              "success")
        return redirect(url_for("mantenedor", clave=clave))

    filas = lista(f"WU_{m['nombre']}_LISTAR_P", *m.get("listar_args", []))
    campos_edicion = m["claves"] + [c[0] for c in m["campos"] if c[2] != "password"]
    for fila in filas:
        fila["_edicion"] = {c: "" if fila.get(c) is None else str(fila[c]) for c in campos_edicion}
    selects = {c[0]: opciones(c[3]) for c in m["campos"] if c[2] == "select"}
    selects.update({c[0]: opciones(c[2]) for c in m.get("claves_select", [])})
    return render_template("admin/mantenedor.html", clave=clave, m=m, filas=filas, selects=selects,
                           largos=LARGOS.get(clave, {}), opcionales=OPCIONALES.get(clave, set()))


@app.route("/admin/moderacion")  # GESTOR 2: moderar apuntes
@admin_requerido
def moderacion():
    return render_template("admin/moderacion.html", apuntes=lista("WU_APUNTE_LISTAR_P", "PENDIENTE"))


@app.post("/admin/moderacion/<int:apunte_id>")
@admin_requerido
def moderar(apunte_id):
    llamar("WU_MODERAR_APUNTE_P", apunte_id, session["usuario"]["id"],
           request.form.get("decision"), request.form.get("motivo", "").strip() or None)
    flash("Decisión registrada.", "success")
    return redirect(url_for("moderacion"))


@app.route("/admin/informes")  # los 3 reportes (dashboards)
@admin_requerido
def reportes():
    anio = request.args.get("anio", type=int) or datetime.now().year
    asignatura = request.args.get("asignatura", type=int)
    carrera = request.args.get("carrera", type=int)

    top, por_carrera = llamar("WU_REP_TOP_DESCARGAS_P", asignatura, anio, SAL_CUR, SAL_CUR)
    descargas_mes, apuntes_mes = llamar("WU_REP_ACTIVIDAD_MENSUAL_P", anio, SAL_CUR, SAL_CUR)
    con_material, sin_material = llamar("WU_REP_COBERTURA_P", carrera, SAL_CUR, SAL_CUR)

    meses = [f"{anio}-{n:02d}" for n in range(1, 13)]
    por_mes = {f["mes"]: f["total"] for f in descargas_mes}
    subidos = {f["mes"]: f["total"] for f in apuntes_mes}
    return render_template(
        "admin/reportes.html", anio=anio, asignatura=asignatura, carrera=carrera,
        asignaturas=lista("WU_ASIGNATURA_LISTAR_P"), carreras=lista("WU_CARRERA_LISTAR_P"),
        top=top[:10], por_carrera=por_carrera, meses=meses,
        serie_descargas=[por_mes.get(m, 0) for m in meses], serie_apuntes=[subidos.get(m, 0) for m in meses],
        con_material=con_material, sin_material=sin_material)


if __name__ == "__main__":
    app.run(debug=os.environ.get("FLASK_DEBUG") == "1")
