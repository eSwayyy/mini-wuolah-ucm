# Wuolah UCM

Wuolah UCM es un proyecto que busca implementar la famosa idea de un *repositorio de apuntes*.

Creada por: Matías Meza Villagra
            Y otros.

    

## Cómo ejecutar (backend Flask + Oracle)

1. Oracle 21c XE con el esquema `WUOLAH_UCM` (ver `sql/`). Ejecutar `sql/wuolah_ucm_completo.sql` conectado como `WUOLAH_UCM`.
2. Crear el entorno e instalar dependencias:
   ```
   python3 -m venv venv
   source venv/bin/activate        # en Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```
3. Copiar `.env.example` como `.env` y completar las credenciales (`.env` no se sube a Git).
4. Iniciar: `flask --app app run --port 5001` y abrir http://127.0.0.1:5001
   (en macOS el puerto 5000 lo usa AirPlay y responde 403, por eso se usa el 5001)

Usuarios de prueba (datos de `sql/09_datos_prueba.sql`):

| Rol | Correo | Contraseña |
|---|---|---|
| Administrador | admin@ucm.cl | Admin2026! |
| Estudiante | camila.rojas@alu.ucm.cl | Estudiante2026! |

La aplicación no contiene SQL: toda operación llama a un procedimiento almacenado
(`db.llamar`). Las contraseñas se guardan con hash (Werkzeug) y las credenciales de Oracle
se leen de variables de entorno.
