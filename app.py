"""Mini Wuolah: demostración Flask sin conexión a Oracle.

Coloca base.html e inicio.html existentes en templates/.
Coloca tus PDF de prueba en uploads/ con los nombres indicados en APUNTES.
"""

from pathlib import Path
from db import (consultar, ejecutar, llamar_procedimiento, llamar_funcion)
from flask import (
    Flask,
    abort,
    redirect,
    render_template,
    render_template_string,
    request,
    send_from_directory,
    url_for,
)

app = Flask(__name__)
UPLOADS = Path(app.root_path) / "uploads"

def obtener_destacados():
    r = llamar_funcion(
        "OBTENER_DESTACADOS",
        int,
        None
        )
    return r if r else None

def obtener_carreras():
    r = llamar_funcion(
        "OBTENER_CARRERAS",
        int,
        None
        )
    return r if r else None

def obtener_asignaturas_por_carrera():
    r = llamar_funcion(
        "OBTENER_ASIGNATURAS_POR_CARRERA",
        int,
        None
        )
    return r if r else None

def buscar_apuntes():
    r = llamar_funcion(
        "OBTENER_APUNTES",
        int,
        None
        
        )
    return r if r else None

def buscar_apunte_por_id():
    r = llamar_funcion(
        "OBTENER_APUNTES_POR_ID",
        int,
        None
        )
    return r if r else None

@app.route("/")
@app.route("/inicio")
def inicio():
    return render_template("inicio.html", destacados=obtener_destacados())


@app.route("/apuntes")
def apuntes():
    carrera_id = request.args.get("carrera", type=int)
    asignatura_id = request.args.get("asignatura", type=int)
    busqueda = request.args.get("q", "").strip()

    carreras = obtener_carreras()
    if carrera_id not in {c["id_carrera"] for c in carreras}:
        carrera_id = None

    asignaturas = obtener_asignaturas_por_carrera(carrera_id)
    if asignatura_id not in {a["id_asignatura"] for a in asignaturas}:
        asignatura_id = None

    resultados = buscar_apuntes(carrera_id, asignatura_id, busqueda)

    return render_template(
        "apuntes.html",
        carreras=carreras,
        asignaturas=asignaturas,
        apuntes=resultados,
        carrera_seleccionada=carrera_id,
        asignatura_seleccionada=asignatura_id,
        busqueda=busqueda,
    )


@app.route("/apuntes/<int:apunte_id>/pdf")
def ver_pdf(apunte_id):
    apunte = buscar_apunte_por_id(apunte_id)
    if apunte is None or not (UPLOADS / apunte["archivo"]).is_file():
        abort(404)
    return send_from_directory(UPLOADS, apunte["archivo"], mimetype="application/pdf", as_attachment=False)


@app.route("/apuntes/<int:apunte_id>/descargar")
def descargar_pdf(apunte_id):
    apunte = buscar_apunte_por_id(apunte_id)
    if apunte is None or not (UPLOADS / apunte["archivo"]).is_file():
        abort(404)
    return send_from_directory(UPLOADS, apunte["archivo"], mimetype="application/pdf", as_attachment=True)


# Página de perfil provisional. Si ya tienes templates/perfil.html, se utiliza ese archivo.
@app.route("/usuarios/<int:usuario_id>")
def perfil_usuario(usuario_id):
    pass


@app.route("/perfil")
def mi_perfil():
    # SOLO DEMO: más adelante usar session['usuario_id'] después de iniciar sesión.
    return redirect(url_for("perfil_usuario", usuario_id=1))


if __name__ == "__main__":
    app.run(debug=True)  # Solo para desarrollo local.
