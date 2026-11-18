"""Mini Wuolah: demostración Flask sin conexión a Oracle.

Coloca base.html e inicio.html existentes en templates/.
Coloca tus PDF de prueba en uploads/ con los nombres indicados en APUNTES.
"""

from pathlib import Path

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

# DATOS DE PRUEBA: más adelante se sustituirán por consultas a Oracle/PLSQL.
CARRERAS = [
    {"id_carrera": 1, "nombre": "Ingeniería Civil Informática"},
    {"id_carrera": 2, "nombre": "Ingeniería Comercial"},
    {"id_carrera": 3, "nombre": "Ingeniería Civil Industrial"},
]

ASIGNATURAS = [
    {"id_asignatura": 1, "nombre": "Base de Datos"},
    {"id_asignatura": 2, "nombre": "Programación"},
    {"id_asignatura": 3, "nombre": "Redes de Computadores"},
    {"id_asignatura": 4, "nombre": "Microeconomía"},
    {"id_asignatura": 5, "nombre": "Cálculo"},
]

# Una asignatura puede pertenecer a varias carreras.
CARRERA_ASIGNATURA = [
    (1, 1), (1, 2), (1, 3), (1, 5),
    (2, 4), (2, 5),
    (3, 2), (3, 5),
]

USUARIOS = [
    {"id_usuario": 1, "nombre": "Alonso", "usuario": "alonso", "carrera": "Ingeniería Civil Informática"},
    {"id_usuario": 2, "nombre": "María", "usuario": "maria", "carrera": "Ingeniería Comercial"},
    {"id_usuario": 3, "nombre": "Pedro", "usuario": "pedro", "carrera": "Ingeniería Civil Industrial"},
]

# Los archivos NO se generan automáticamente: agrega tus propios PDF en uploads/.
APUNTES = [
    {"id_apunte": 1, "titulo": "Resumen de SQL", "descripcion": "Consultas, JOIN y funciones SQL.",
     "id_usuario": 1, "id_carrera": 1, "id_asignatura": 1, "tipo": "Resumen",
     "fecha_subida": "12/11/2026", "archivo": "resumen_sql.pdf", "likes": 24, "comentarios": 5, "descargas": 245},
    {"id_apunte": 2, "titulo": "Ejercicios de Python", "descripcion": "Ejercicios resueltos de programación.",
     "id_usuario": 1, "id_carrera": 1, "id_asignatura": 2, "tipo": "Ejercicios",
     "fecha_subida": "10/11/2026", "archivo": "ejercicios_python.pdf", "likes": 18, "comentarios": 3, "descargas": 180},
    {"id_apunte": 3, "titulo": "Modelo OSI y TCP/IP", "descripcion": "Capas y protocolos de red.",
     "id_usuario": 3, "id_carrera": 1, "id_asignatura": 3, "tipo": "Apuntes",
     "fecha_subida": "05/11/2026", "archivo": "modelo_osi.pdf", "likes": 15, "comentarios": 2, "descargas": 120},
    {"id_apunte": 4, "titulo": "Introducción a la Microeconomía", "descripcion": "Oferta, demanda y elasticidad.",
     "id_usuario": 2, "id_carrera": 2, "id_asignatura": 4, "tipo": "Resumen",
     "fecha_subida": "02/11/2026", "archivo": "microeconomia.pdf", "likes": 11, "comentarios": 1, "descargas": 95},
    {"id_apunte": 5, "titulo": "Guía de Derivadas", "descripcion": "Ejercicios de cálculo diferencial.",
     "id_usuario": 2, "id_carrera": 2, "id_asignatura": 5, "tipo": "Guía",
     "fecha_subida": "14/11/2026", "archivo": "guia_derivadas.pdf", "likes": 21, "comentarios": 4, "descargas": 210},
]


def obtener_carreras():
    return CARRERAS


def obtener_asignaturas_por_carrera(carrera_id):
    if carrera_id is None:
        return []
    ids = {id_asignatura for id_carrera, id_asignatura in CARRERA_ASIGNATURA
           if id_carrera == carrera_id}
    return [a for a in ASIGNATURAS if a["id_asignatura"] in ids]


def enriquecer_apunte(apunte):
    """Añade metadatos de presentación sin modificar el dato original."""
    resultado = apunte.copy()
    usuario = next((u for u in USUARIOS if u["id_usuario"] == apunte["id_usuario"]), None)
    carrera = next((c for c in CARRERAS if c["id_carrera"] == apunte["id_carrera"]), None)
    asignatura = next((a for a in ASIGNATURAS if a["id_asignatura"] == apunte["id_asignatura"]), None)
    resultado["autor"] = usuario["usuario"] if usuario else "desconocido"
    resultado["carrera"] = carrera["nombre"] if carrera else "Carrera desconocida"
    resultado["asignatura"] = asignatura["nombre"] if asignatura else "Asignatura desconocida"
    resultado["archivo_disponible"] = (UPLOADS / apunte["archivo"]).is_file()
    return resultado


def obtener_destacados():
    mas_descargados = sorted(APUNTES, key=lambda a: a["descargas"], reverse=True)[:3]
    return [enriquecer_apunte(a) for a in mas_descargados]


def buscar_apuntes(carrera_id=None, asignatura_id=None, busqueda=""):
    resultados = APUNTES

    if carrera_id is not None:
        ids = {a["id_asignatura"] for a in obtener_asignaturas_por_carrera(carrera_id)}
        resultados = [a for a in resultados if a["id_asignatura"] in ids]

    if asignatura_id is not None:
        resultados = [a for a in resultados if a["id_asignatura"] == asignatura_id]

    if busqueda:
        texto = busqueda.casefold()
        resultados = [a for a in resultados
                      if texto in a["titulo"].casefold()
                      or texto in a["descripcion"].casefold()]

    return [enriquecer_apunte(a) for a in resultados]


def buscar_apunte_por_id(apunte_id):
    return next((a for a in APUNTES if a["id_apunte"] == apunte_id), None)


@app.route("/")
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
    usuario = next((u for u in USUARIOS if u["id_usuario"] == usuario_id), None)
    if usuario is None:
        abort(404)
    mis_apuntes = [enriquecer_apunte(a) for a in APUNTES if a["id_usuario"] == usuario_id]
    if (Path(app.root_path) / "templates" / "perfil.html").is_file():
        return render_template("perfil.html", usuario=usuario, apuntes=mis_apuntes)
    return render_template_string("""
        {% extends 'base.html' %}
        {% block titulo %}Perfil de {{ usuario.nombre }}{% endblock %}
        {% block contenido %}
          <div class="container py-4">
            <h1><i class="far fa-user mr-2"></i>{{ usuario.nombre }}</h1>
            <p class="text-muted">@{{ usuario.usuario }} · {{ usuario.carrera }}</p>
            <h4 class="mt-4">Apuntes publicados</h4>
            {% for apunte in apuntes %}
              <p><a href="{{ url_for('apuntes', q=apunte.titulo) }}">{{ apunte.titulo }}</a></p>
            {% else %}<p>Este usuario todavía no ha publicado apuntes.</p>{% endfor %}
          </div>
        {% endblock %}
    """, usuario=usuario, apuntes=mis_apuntes)


@app.route("/perfil")
def mi_perfil():
    # SOLO DEMO: más adelante usar session['usuario_id'] después de iniciar sesión.
    return redirect(url_for("perfil_usuario", usuario_id=1))


if __name__ == "__main__":
    app.run(debug=True)  # Solo para desarrollo local.
