
# Wuolah UCM

Wuolah UCM es un proyecto que busca implementar la idea de un
**repositorio de apuntes universitarios**, donde los estudiantes
puedan compartir, consultar y descargar material de estudio.

**Creado por:** Alonso Vergara, Cristian Monsalve, Matías Meza y Francisco Uribe.

## Tecnologías utilizadas

- Frontend: HTML, CSS, JavaScript y AdminLTE 3.2.
- Backend: Python y Flask.
- Base de datos: Oracle Database 21c XE.
- Lógica de base de datos: PL/SQL.

## Cómo ejecutar el proyecto


### 1. Configurar Oracle

Tener instalado Oracle Database 21c XE y asegurarse de que
los servicios de Oracle estén iniciados.

#### 1.1. Crear el usuario de la base de datos

Abrir una terminal y conectarse como administrador:

```bash
sqlplus / as sysdba
```

Cambiar al contenedor XEPDB1:

```sql
ALTER SESSION SET CONTAINER = XEPDB1;
```

Crear el usuario:

```sql
CREATE USER wuolah_ucm IDENTIFIED BY Wuolah2026;
```

Otorgar los permisos necesarios:

```sql
GRANT CREATE SESSION TO wuolah_ucm;
GRANT CREATE TABLE TO wuolah_ucm;
GRANT CREATE VIEW TO wuolah_ucm;
GRANT CREATE SEQUENCE TO wuolah_ucm;
GRANT CREATE PROCEDURE TO wuolah_ucm;
GRANT CREATE TRIGGER TO wuolah_ucm;

ALTER USER wuolah_ucm QUOTA UNLIMITED ON USERS;
```

Salir de SQL*Plus:

```sql
EXIT;
```

Si el usuario ya existe, omitir este apartado.

#### 1.2. Conectarse como WUOLAH_UCM

Desde una terminal ubicada en la raíz del proyecto:

```bash
sqlplus wuolah_ucm@//localhost:1521/XEPDB1
```

Introducir la contraseña configurada anteriormente:

```text
Wuolah2026
```

#### 1.3. Crear la base de datos

Una vez conectado como WUOLAH_UCM, ejecutar:

```sql
@sql/wuolah_ucm_completo.sql
```

Este script crea las tablas, relaciones, procedimientos,
funciones, triggers e inserta los datos de prueba.

El script utiliza UNISTR() para evitar problemas de
codificación con tildes y caracteres especiales.

**Advertencia:** ejecutar nuevamente el script completo
elimina las tablas existentes y sus datos.

Finalmente, salir de SQL*Plus:

```sql
EXIT;
```

Continuar con la configuración del entorno virtual de Python.

### 2. Crear el entorno virtual

En Windows:

```powershell
python -m venv venv
venv\Scripts\activate
```

En Linux o macOS:

```bash
python3 -m venv venv
source venv/bin/activate
```

### 3. Instalar las dependencias

```bash
pip install -r requirements.txt
```

### 4. Configurar las variables de entorno

Copiar el archivo `.env.example` como `.env`.

En Windows:

```powershell
Copy-Item .env.example .env
```

En Linux o macOS:

```bash
cp .env.example .env
```

Completar las credenciales de Oracle dentro del archivo `.env`.

El archivo `.env` no debe subirse a GitHub.

### 5. Iniciar la aplicación

```bash
python -m flask --app app run --debug --port 5001
```

Abrir en el navegador:

http://127.0.0.1:5001

Se utiliza el puerto 5001 porque, en macOS, el puerto 5000
puede estar ocupado por AirPlay.

El modo `--debug` permite reflejar los cambios realizados
en el código y las plantillas durante el desarrollo.

## Usuarios de prueba

| Rol | Correo | Contraseña |
|---|---|---|
| Administrador | admin@ucm.cl | Admin2026! |
| Estudiante | camila.rojas@alu.ucm.cl | Estudiante2026! |

## Problemas frecuentes

### Problemas con tildes y caracteres especiales

Al ejecutar scripts SQL desde SQL*Plus, pueden producirse
problemas de codificación con caracteres como las tildes
y la letra ñ.

Por ejemplo:

- Incorrecto: MicroeconomÃ­a
- Correcto: Microeconomía

Para evitar este problema, los textos afectados del script
SQL completo utilizan la función `UNISTR()` de Oracle.

Si la base de datos fue creada utilizando una versión anterior
del script y contiene caracteres incorrectos, conectarse
mediante SQL*Plus:

```bash
sqlplus wuolah_ucm@//localhost:1521/XEPDB1
```

Y ejecutar:

```sql
@sql/wuolah_ucm_reparar_tildes.sql
```

Este script corrige los datos de prueba afectados sin eliminar
las tablas ni los registros existentes.

### Los cambios del frontend no se reflejan

Asegurarse de guardar los archivos modificados y ejecutar
Flask en modo debug:

```bash
python -m flask --app app run --debug --port 5001
```

Si el problema persiste, recargar el navegador utilizando
`Ctrl + Shift + R`.

### Error de conexión con Oracle

Comprobar que:

- Los servicios de Oracle estén iniciados.
- El listener esté funcionando en el puerto 1521.
- Las credenciales del archivo `.env` sean correctas.
- La conexión utilice el servicio `XEPDB1`.

## Arquitectura

La aplicación no contiene consultas SQL directas.
Las operaciones de base de datos se realizan mediante
procedimientos almacenados, utilizando `db.llamar`.

Las contraseñas se almacenan mediante hash utilizando Werkzeug,
y las credenciales de Oracle se leen desde variables de entorno.
