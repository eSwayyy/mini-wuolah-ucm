
from flask import Flask, render_template, jsonify
from db import consultar

app = Flask(__name__)

@app.route("/")
def inicio():
    return render_template("apuntes.html")

@app.route("/test-db")
def test_db():
    try:
        resultado = consultar(
            "SELECT 'Conexion exitosa' AS mensaje FROM dual"
        )
        return jsonify(resultado)
    except Exception:
        app.logger.exception("Error de conexion con Oracle")
        return jsonify({"error": "No se pudo conectar a Oracle"}), 500

if __name__ == "__main__":
    app.run(debug=True)
