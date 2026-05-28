## Guía Rápida - Servicio de Base de Datos Firestore

### Estructura del Proyecto

```
lib/
├── models/
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
├── services/
│   └── database_service.dart
└── ...
```

### Inicialización

El servicio se inicializa como singleton:

```dart
final DatabaseService db = DatabaseService();
```

### Operaciones Principales

#### USUARIOS
```dart
// Registrar usuario
final usuario = await db.registrarUsuario(
  correo: 'usuario@example.com',
  password: 'password123',
);

// Validar usuario
final usuarioValidado = await db.validarUsuario(
  correo: 'usuario@example.com',
  password: 'password123',
);

// Obtener usuario
final usuario = await db.obtenerUsuarioPorId('userId');
```

#### CLIENTES
```dart
// Registrar cliente (crea usuario + cliente + preferencia)
final cliente = await db.registrarCliente(
  correo: 'cliente@example.com',
  password: 'password123',
  nombre: 'Juan Pérez',
  rfc: 'JPZ000000XXX',
  direccion: 'Calle Principal 123',
  telefono: '5551234567',
  fechaNacimiento: DateTime(1990, 5, 15),
);

// Validar cliente
final cliente = await db.validarCliente(
  correo: 'cliente@example.com',
  password: 'password123',
);

// Obtener cliente
final cliente = await db.obtenerClientePorId('clienteId');

// Actualizar cliente
final actualizado = cliente.copyWith(telefono: '5559876543');
await db.actualizarCliente(actualizado);

// Eliminar cliente (soft delete)
await db.eliminarCliente('clienteId');
```

#### EMPLEADOS
```dart
// Registrar empleado
final empleado = await db.registrarEmpleado(
  correo: 'empleado@example.com',
  password: 'password123',
  nombre: 'Luis Fernando Torres',
  rfc: 'LFT000000XXX',
  fechaNacimiento: DateTime(1992, 3, 3),
  direccion: 'Av. Tecnológico 101',
  sueldo: 9500.00,
  ocupacion: 'Cajero',
  telefonos: ['5551234567', '5559876543'],
);

// Validar empleado
final empleado = await db.validarEmpleado(
  correo: 'empleado@example.com',
  password: 'password123',
);
```

#### PROVEEDORES
```dart
// Crear proveedor
final proveedor = await db.crearProveedor(
  proveedor: 'Distribuidores de Moda París',
  telefonos: ['5544332211', '5544332212'],
);

// Obtener proveedor
final proveedor = await db.obtenerProveedorPorId('proveedorId');

// Obtener todos los proveedores
final proveedores = await db.obtenerProveedoresActivos();
```

#### CATEGORÍAS
```dart
// Crear categoría
final categoria = await db.crearCategoria('Vestidos de Noche');

// Obtener categorías
final categorias = await db.obtenerCategorias();

// Obtener categoría específica
final categoria = await db.obtenerCategoriaPorId('categoriaId');
```

#### ARTÍCULOS
```dart
// Insertar artículo
final articulo = await db.insertarArticulo(
  articulo: 'Vestido Midi Satín Rojo - M',
  descripcion: 'Vestido de fiesta midi, tela satín color rojo vibrante',
  imagen: 'vestido_rojo_m.jpg',
  precio: 1299.00,
  idP: 'proveedorId',
  idCA: 'categoriaId',
);

// Obtener artículo
final articulo = await db.obtenerArticuloPorId('articuloId');

// Obtener todos los artículos
final articulos = await db.obtenerArticulos();

// Obtener artículos por categoría
final articulosCat = await db.obtenerArticulosPorCategoria('categoriaId');

// Actualizar artículo
await db.actualizarArticulo(articulo.copyWith(precio: 1500.00));

// Eliminar artículo
await db.eliminarArticulo('articuloId');
```

#### CARRITO
```dart
// Agregar artículo al carrito
final carritoItem = await db.agregarAlCarrito(
  idC: 'clienteId',
  idA: 'articuloId',
  cantidad: 2,
);

// Obtener carrito del cliente
final carrito = await db.obtenerCarritoCliente('clienteId');

// Actualizar cantidad en carrito
await db.actualizarCantidadCarrito('carritoItemId', 3);

// Eliminar del carrito
await db.eliminarDelCarrito('carritoItemId');

// Limpiar carrito
await db.limpiarCarritoCliente('clienteId');
```

#### PEDIDOS
```dart
// Insertar pedido
final pedido = await db.insertarPedido(
  descripcion: 'Compra Vestido Graduación',
  idC: 'clienteId',
  idA: 'articuloId',
  cantidad: 1,
  precio: 1299.00,
  status: 'En Proceso', // O 'Pagado', 'Pendiente', 'Cancelado'
);

// Obtener pedido
final pedido = await db.obtenerPedidoPorId('pedidoId');

// Obtener pedidos del cliente
final pedidosCliente = await db.obtenerPedidosCliente('clienteId');

// Obtener todos los pedidos
final todosPedidos = await db.obtenerTodosPedidos();

// Actualizar estado del pedido
await db.actualizarEstadoPedido('pedidoId', 'Pagado');
```

#### VENTAS
```dart
// Obtener venta por ID
final venta = await db.obtenerVentaPorId('ventaId');

// Obtener todas las ventas
final ventas = await db.obtenerTodasVentas();

// Las ventas se crean automáticamente cuando un pedido es marcado como 'Pagado'
```

#### PREFERENCIAS DE CLIENTE
```dart
// Obtener preferencia de cliente
final preferencia = await db.obtenerPreferenciaCliente('clienteId');

// Actualizar preferencia de cliente
await db.actualizarPreferenciaCliente(
  idC: 'clienteId',
  direccion: 'Nueva dirección',
  metodoPago: 'Tarjeta de Crédito',
);

// Eliminar dirección preferida
await db.eliminarDireccionPreferenciaCliente('clienteId');

// Eliminar método de pago preferido
await db.eliminarMetodoPagoPreferenciaCliente('clienteId');
```

#### INVENTARIO
```dart
// Crear inventario
final inventario = await db.crearInventario(
  descripcion: 'Stock Vestido Rojo',
  idA: 'articuloId',
  idP: 'proveedorId',
  stock: 50,
);

// Obtener inventario de artículo
final inv = await db.obtenerInventarioPorArticulo('articuloId');

// Actualizar stock
await db.actualizarStock('articuloId', 45);
```

#### QR
```dart
// Crear QR
final qr = await db.crearQR('https://example.com/qr/123');

// Obtener QR
final qr = await db.obtenerQRPorId('qrId');

// Obtener todos los QRs
final qrs = await db.obtenerTodosQRs();

// Eliminar QR
await db.eliminarQR('qrId');
```

### Manejo de Errores

Todos los métodos retornan `null` si hay error y imprimen el error en consola. Es recomendable verificar si el resultado es `null`:

```dart
final cliente = await db.registrarCliente(...);
if (cliente == null) {
  print('Fallo al registrar cliente');
} else {
  print('Cliente registrado: ${cliente.nombre}');
}
```

### Integración con Providers

Para usar el servicio con los providers actuales, puedes hacerlo así en `user_provider.dart`:

```dart
import 'services/database_service.dart';

class UserProvider extends ChangeNotifier {
  final db = DatabaseService();
  
  Future<bool> loginFromFirestore(String email, String password) async {
    final cliente = await db.validarCliente(
      correo: email,
      password: password,
    );
    
    if (cliente != null) {
      // Guardar datos de cliente
      await login(
        name: cliente.nombre,
        email: cliente.idU,
      );
      return true;
    }
    return false;
  }
}
```

### Notas Importantes

1. **Singleton**: El `DatabaseService` es un singleton, puedes acceder a él desde cualquier lugar.
2. **Async**: Todos los métodos son asincronos, usa `await`.
3. **Soft Deletes**: Clientes y empleados usan soft delete (marca como inactivo).
4. **Cascadas Automáticas**: Las ventas se crean automáticamente cuando un pedido es pagado.
5. **Preferencias Automáticas**: Las preferencias de cliente se crean automáticamente al registrar un cliente.

