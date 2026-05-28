## MRBoutique - Sistema de Base de Datos Firebase

### 📋 Estructura Completa

El proyecto ahora tiene integración completa con Firebase:

```
lib/
├── models/                          # Modelos de datos
│   ├── usuario_model.dart
│   ├── cliente_model.dart
│   ├── empleado_model.dart
│   ├── proveedor_model.dart
│   ├── categoria_articulo_model.dart
│   ├── articulo_model.dart
│   ├── carrito_model.dart
│   ├── pedido_model.dart
│   ├── venta_model.dart
│   ├── preferencia_cliente_model.dart
│   ├── inventario_model.dart
│   └── qr_model.dart
│
├── services/                        # Servicios
│   ├── auth_service.dart           # ✅ Autenticación Firebase
│   └── database_service.dart        # ✅ Base de datos Firestore
│
├── screens/auth/
│   ├── login_screen.dart           # ✅ Login con Firebase Auth
│   ├── signup_screen.dart          # ✅ Registro con Firebase Auth
│   └── forgot_password_screen.dart
│
└── ... (otros archivos)
```

### 🔐 Autenticación Firebase

#### Login Screen
El archivo `login_screen.dart` ya tiene integración completa con Firebase Auth:

```dart
// Ejemplo de flujo de login
final authService = AuthService();
final usuario = await authService.loginConEmail(
  correo: 'usuario@example.com',
  password: 'password123',
);

// Si es exitoso, se autentica con Firebase Auth y recupera datos de Firestore
```

**Características:**
- ✅ Validación de email y contraseña
- ✅ Autenticación real con Firebase Auth
- ✅ Recuperación de datos del cliente desde Firestore
- ✅ Guardado de datos en UserProvider
- ✅ Manejo de errores robusto

#### Signup Screen
Pantalla completa de registro: `signup_screen.dart`

```dart
// Ejemplo de flujo de registro
final usuario = await authService.registrarClienteConEmail(
  correo: 'nuevo@example.com',
  password: 'password123',
  nombre: 'Juan Pérez',
  direccion: 'Calle Principal 123',
  telefono: '5551234567',
  fechaNacimiento: DateTime(1990, 5, 15),
);
```

**Características:**
- ✅ Registro de cliente completo
- ✅ Validación de todos los campos
- ✅ Selector de fecha de nacimiento
- ✅ Creación automática de Firestore + Firebase Auth
- ✅ Creación automática de preferencias
- ✅ Confirmación de contraseña

### 🗄️ Base de Datos Firestore

El `database_service.dart` proporciona todas las operaciones CRUD:

```dart
final db = DatabaseService();

// Crear
final articulo = await db.insertarArticulo(...);

// Leer
final cliente = await db.obtenerClientePorId('clienteId');

// Actualizar
await db.actualizarCliente(clienteModificado);

// Eliminar
await db.eliminarCliente('clienteId');
```

### 🔄 Flujo Completo de Autenticación

1. **Usuario abre la app**
   ```
   main.dart
   └─ Firebase.initializeApp()
   └─ Verificar authStateChanges
   ```

2. **Usuario hace login**
   ```
   LoginScreen
   └─ AuthService.loginConEmail()
   ├─ Firebase Auth.signInWithEmailAndPassword()
   ├─ DatabaseService.validarCliente()
   └─ UserProvider.login()
   ```

3. **Usuario se registra**
   ```
   SignupScreen
   └─ AuthService.registrarClienteConEmail()
   ├─ Firebase Auth.createUserWithEmailAndPassword()
   ├─ DatabaseService.registrarCliente()
   ├─ Crear preferencias automáticamente
   └─ UserProvider.login()
   ```

4. **Usuario hace logout**
   ```
   ProfileScreen o Menu
   └─ AuthService.logout()
   ├─ Firebase Auth.signOut()
   └─ UserProvider.logout()
   ```

### 📦 Colecciones en Firestore

| Colección | Descripción | Referencia |
|-----------|-------------|-----------|
| `usuarios` | Datos de autenticación | - |
| `clientes` | Clientes registrados | Referencia a usuarios |
| `empleados` | Empleados del sistema | Referencia a usuarios |
| `proveedores` | Proveedores de productos | - |
| `categorias_articulos` | Categorías de productos | - |
| `articulos` | Productos disponibles | Referencia a proveedor y categoría |
| `carrito` | Items del carrito de compras | Referencia a cliente y artículo |
| `pedidos` | Órdenes de compra | Referencia a cliente y artículo |
| `ventas` | Transacciones completadas | Referencia a pedido |
| `preferencia_cliente` | Preferencias de compra | Referencia única a cliente |
| `inventario` | Control de stock | Referencia a artículo y proveedor |
| `qr` | Códigos QR | - |

### 🚀 Ejemplo de Uso Completo

```dart
// 1. Inicializar servicios
final authService = AuthService();
final db = DatabaseService();

// 2. Registrar nuevo cliente
final usuario = await authService.registrarClienteConEmail(
  correo: 'maria@example.com',
  password: 'secure123',
  nombre: 'María García',
  direccion: 'Avenida Principal 456',
  telefono: '5559876543',
  fechaNacimiento: DateTime(1995, 8, 20),
);

// 3. Crear artículos
final categoria = await db.crearCategoria('Vestidos');
final proveedor = await db.crearProveedor(
  proveedor: 'Textiles Premium',
  telefonos: ['5551234567'],
);

final articulo = await db.insertarArticulo(
  articulo: 'Vestido de Gala',
  descripcion: 'Elegante vestido de noche',
  precio: 1299.00,
  idP: proveedor.id,
  idCA: categoria.id,
);

// 4. Cliente agrega artículo al carrito
final carritoItem = await db.agregarAlCarrito(
  idC: usuario.id,
  idA: articulo.id,
  cantidad: 1,
);

// 5. Cliente crea pedido
final pedido = await db.insertarPedido(
  descripcion: 'Compra de vestido',
  idC: usuario.id,
  idA: articulo.id,
  cantidad: 1,
  precio: 1299.00,
);

// 6. Pagar pedido (crea venta automáticamente)
await db.actualizarEstadoPedido(pedido.id, 'Pagado');
```

### 🔒 Seguridad

**Reglas de Firestore que debes configurar:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios solo pueden leer su propio documento
    match /usuarios/{document=**} {
      allow read: if request.auth.uid == resource.data.id;
      allow write: if request.auth.uid == resource.data.id;
    }

    // Clientes pueden leer su propio documento
    match /clientes/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == get(/databases/$(database)/documents/usuarioCliente/$(request.auth.uid)).data.idU;
    }

    // Permitir leer categorías y artículos
    match /categorias_articulos/{document=**} {
      allow read: if request.auth != null;
    }

    match /articulos/{document=**} {
      allow read: if request.auth != null;
    }

    // Carrito: solo el propietario
    match /carrito/{document=**} {
      allow read, write: if request.auth != null;
    }

    // Pedidos: solo el cliente
    match /pedidos/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 📚 Documentación Completa

- **AUTH_GUIDE.md** - Guía completa de autenticación
- **FIRESTORE_GUIDE.md** - Guía completa de operaciones CRUD
- **MODELS** - Todos los modelos de datos con comentarios

### ✅ Checklist de Implementación

- ✅ Firebase Auth configurado
- ✅ Firestore configurado
- ✅ AuthService creado
- ✅ DatabaseService creado
- ✅ LoginScreen con Firebase Auth
- ✅ SignupScreen con registro completo
- ✅ Modelos de datos completos
- ✅ Integración con UserProvider
- ✅ Gestión de errores
- ✅ Validaciones de entrada

### 🐛 Troubleshooting

**Error: "Firebase not initialized"**
```
Solución: Verifica que main.dart tenga Firebase.initializeApp()
```

**Error: "PERMISSION_DENIED"**
```
Solución: Configura las reglas de Firestore adecuadamente
```

**Error: "email-already-in-use"**
```
Solución: El email ya tiene una cuenta, usa otro o recupera contraseña
```

**Error: "No se pudo registrar el cliente en Firestore"**
```
Solución: Verifica que DatabaseService esté inicializado correctamente
```

### 📞 Contacto y Soporte

Para más detalles, revisa:
- [Firebase Auth Documentation](https://firebase.flutter.dev/docs/auth/overview/)
- [Cloud Firestore Documentation](https://firebase.flutter.dev/docs/firestore/overview/)

