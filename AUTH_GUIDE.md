## Guía Firebase Authentication - MRBoutique

### Inicialización

El `AuthService` se inicializa como singleton y maneja toda la autenticación con Firebase:

```dart
final authService = AuthService();
```

### Operaciones de Autenticación

#### 1. Registrar Cliente (Sign Up)

```dart
final usuario = await authService.registrarClienteConEmail(
  correo: 'cliente@example.com',
  password: 'password123',
  nombre: 'Juan Pérez',
  rfc: null, // opcional
  direccion: 'Calle Principal 123',
  telefono: '5551234567',
  fechaNacimiento: DateTime(1990, 5, 15),
);

if (usuario != null) {
  print('Cliente registrado exitosamente');
} else {
  print('Error al registrar cliente');
}
```

#### 2. Iniciar Sesión Cliente (Login)

```dart
final usuario = await authService.loginConEmail(
  correo: 'cliente@example.com',
  password: 'password123',
);

if (usuario != null) {
  print('Inicio de sesión exitoso: ${usuario.correo}');
} else {
  print('Credenciales incorrectas');
}
```

#### 3. Registrar Empleado

```dart
final usuario = await authService.registrarEmpleadoConEmail(
  correo: 'empleado@example.com',
  password: 'password123',
  nombre: 'Luis Fernando Torres',
  rfc: 'LFT000000XXX',
  fechaNacimiento: DateTime(1992, 3, 3),
  direccion: 'Av. Tecnológico 101',
  sueldo: 9500.00,
  ocupacion: 'Cajero',
  telefonos: ['5551234567'],
);
```

#### 4. Iniciar Sesión Empleado

```dart
final usuario = await authService.loginEmpleadoConEmail(
  correo: 'empleado@example.com',
  password: 'password123',
);
```

#### 5. Cerrar Sesión (Logout)

```dart
await authService.logout();
```

#### 6. Cambiar Contraseña

```dart
final exito = await authService.cambiarContrasena(
  passwordActual: 'passwordActual123',
  nuevaPassword: 'passwordNuevo456',
);

if (exito) {
  print('Contraseña actualizada');
} else {
  print('Error al cambiar contraseña');
}
```

#### 7. Recuperación de Contraseña

```dart
final exito = await authService.enviarEmailRecuperacion('usuario@example.com');

if (exito) {
  print('Email de recuperación enviado');
} else {
  print('Error al enviar email');
}
```

#### 8. Verificación de Email

```dart
final exito = await authService.enviarEmailVerificacion();

if (exito) {
  print('Email de verificación enviado');
} else {
  print('Error al enviar email de verificación');
}
```

#### 9. Eliminar Cuenta

```dart
final exito = await authService.eliminarCuenta();

if (exito) {
  print('Cuenta eliminada');
} else {
  print('Error al eliminar cuenta');
}
```

### Propiedades del AuthService

```dart
// Verificar si está autenticado
if (authService.isAuthenticated) {
  print('Usuario autenticado');
}

// Obtener usuario actual
final firebaseUser = authService.currentUser;
print('UID: ${firebaseUser?.uid}');
print('Email: ${firebaseUser?.email}');

// Stream de cambios de autenticación (para listeners en tiempo real)
authService.authStateChanges.listen((user) {
  if (user == null) {
    print('Usuario no autenticado');
  } else {
    print('Usuario autenticado: ${user.email}');
  }
});
```

### Obtener Usuario Actual desde Firestore

```dart
final usuario = await authService.obtenerUsuarioActual();

if (usuario != null) {
  print('Usuario: ${usuario.correo}');
}
```

### Integración con Pantalla de Login

El `login_screen.dart` ya está integrado con Firebase Auth:

```dart
// En el método _submit del login_screen.dart
final authService = AuthService();
final usuario = await authService.loginConEmail(
  correo: email,
  password: password,
);

if (usuario != null) {
  // Obtener datos del cliente desde Firestore
  final db = DatabaseService();
  final cliente = await db.validarCliente(
    correo: email,
    password: password,
  );

  // Guardar datos en UserProvider
  await context.read<UserProvider>().login(
    name: cliente.nombre,
    email: email,
    phone: cliente.telefono,
  );
}
```

### Pantalla de Registro (Sign Up)

Existe una pantalla completa `signup_screen.dart` que:
- ✅ Registra nuevo cliente con todos los datos
- ✅ Valida email y contraseña
- ✅ Selecciona fecha de nacimiento
- ✅ Integra Firebase Auth automáticamente
- ✅ Crea perfil en Firestore
- ✅ Crea preferencias de cliente automáticamente

Para usarla:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const SignupScreen()),
);
```

### Manejo de Errores

El `AuthService` maneja automáticamente los siguientes errores de Firebase Auth:

- `user-not-found` → "El usuario no existe"
- `wrong-password` → "Contraseña incorrecta"
- `email-already-in-use` → "El email ya está registrado"
- `invalid-email` → "Email inválido"
- `weak-password` → "La contraseña es muy débil"
- `too-many-requests` → "Demasiados intentos, intenta más tarde"
- `requires-recent-login` → "Debes iniciar sesión nuevamente"

### Flujo Seguro de Autenticación

1. **Sign Up**:
   - Valida datos del cliente
   - Crea usuario en Firebase Auth
   - Registra cliente en Firestore
   - Crea preferencias automáticamente
   - Guarda en UserProvider

2. **Login**:
   - Valida credenciales en Firestore
   - Autentica con Firebase Auth
   - Obtiene datos del cliente
   - Guarda en UserProvider
   - Redirige a app principal

3. **Logout**:
   - Cierra sesión en Firebase Auth
   - Limpia datos en UserProvider
   - Redirige a pantalla de login

### Estado de Autenticación (Listening)

Para estar pendiente de cambios de autenticación:

```dart
StreamBuilder<User?>(
  stream: authService.authStateChanges,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (snapshot.hasData) {
      // Usuario autenticado
      return const MainShell();
    }

    // Usuario no autenticado
    return const LoginScreen();
  },
)
```

### Errores Comunes y Soluciones

**Error: "Credenciales incorrectas"**
- Verifica que el email y contraseña sean correctos
- Asegúrate de que la cuenta esté activa en Firestore

**Error: "El email ya está registrado"**
- El email ya tiene una cuenta
- Usa otro email o recupera la contraseña

**Error: "Demasiados intentos"**
- Firebase bloqueó la cuenta por seguridad
- Espera unos minutos o recupera la contraseña

**Error: "Usuario no encontrado en Firestore"**
- La cuenta se creó en Firebase pero falló en Firestore
- Intenta registrarse nuevamente

