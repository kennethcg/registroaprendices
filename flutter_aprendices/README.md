# Aprendices CRUD - Flutter + Supabase

## 1. Crear/abrir el proyecto

Si este ZIP se abre en una carpeta vacía, instala Flutter y ejecuta:

    flutter create .
    flutter pub get
    flutter run

Si ya tienes un proyecto Flutter, reemplaza su `pubspec.yaml` y la carpeta `lib/` por los de este ZIP.

## 2. Supabase

1. Abre el SQL Editor de tu proyecto Supabase.
2. Ejecuta `supabase.sql`.
3. En Authentication > Users crea un usuario o usa el botón "Crear cuenta" de la aplicación.
4. Si tienes activada la confirmación por correo, confirma el correo antes de iniciar sesión.

## 3. Funciones incluidas

- Formulario de autenticación.
- Mostrar/ocultar contraseña.
- Registro de usuario.
- HomePage después del login.
- SELECT de aprendices.
- INSERT de aprendices.
- UPDATE de aprendices.
- DELETE de aprendices.
- Búsqueda por ID, nombre, celular o correo.
- Selector de fecha de nacimiento.
- Cerrar sesión.

## 4. Dependencia

`supabase_flutter: ^2.0.0`

La aplicación usa `Supabase.initialize()` con la URL y publishable key suministradas en la actividad.
