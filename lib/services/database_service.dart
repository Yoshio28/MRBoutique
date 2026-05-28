import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart';
import '../models/cliente_model.dart';
import '../models/empleado_model.dart';
import '../models/proveedor_model.dart';
import '../models/categoria_articulo_model.dart';
import '../models/articulo_model.dart';
import '../models/carrito_model.dart';
import '../models/pedido_model.dart';
import '../models/venta_model.dart';
import '../models/preferencia_cliente_model.dart';
import '../models/inventario_model.dart';
import '../models/qr_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late FirebaseFirestore _db;

  static const String usuariosCollection          = 'usuarios';
  static const String clientesCollection          = 'clientes';
  static const String empleadosCollection         = 'empleados';
  static const String proveedoresCollection       = 'proveedores';
  static const String categoriasCollection        = 'categorias_articulos';
  static const String articulosCollection         = 'articulos';
  static const String carritoCollection           = 'carrito';
  static const String pedidosCollection           = 'pedidos';
  static const String ventasCollection            = 'ventas';
  static const String preferenciaClienteCollection = 'preferencia_cliente';
  static const String inventarioCollection        = 'inventario';
  static const String qrCollection               = 'qr';

  factory DatabaseService() => _instance;

  DatabaseService._internal() {
    _db = FirebaseFirestore.instance;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // USUARIO
  // ══════════════════════════════════════════════════════════════════════════

  /// Crea el documento de usuario en Firestore usando el UID de Firebase Auth.
  /// Si ya existe, lo devuelve sin sobreescribir.
  Future<Usuario?> registrarUsuario({
    required String uid,
    required String correo,
  }) async {
    try {
      final doc = await _db.collection(usuariosCollection).doc(uid).get();
      if (doc.exists) return Usuario.fromMap(doc.data()!, uid);

      final usuario = Usuario(
        id:        uid,
        correo:    correo,
        password:  '',          // contraseña manejada por Firebase Auth, nunca en Firestore
        createdAt: DateTime.now(),
      );
      await _db.collection(usuariosCollection).doc(uid).set(usuario.toMap());
      return usuario;
    } catch (e) {
      print('registrarUsuario → $e');
      return null;
    }
  }

  /// Busca un usuario por correo (sin validar contraseña, eso lo hace Firebase Auth).
  Future<Usuario?> obtenerUsuarioPorCorreo(String correo) async {
    try {
      final query = await _db
          .collection(usuariosCollection)
          .where('correo', isEqualTo: correo)
          .get();
      if (query.docs.isEmpty) return null;
      final doc = query.docs.first;
      return Usuario.fromMap(doc.data(), doc.id);
    } catch (e) {
      print('obtenerUsuarioPorCorreo → $e');
      return null;
    }
  }

  /// Obtiene un usuario por su UID (= ID del documento).
  Future<Usuario?> obtenerUsuarioPorId(String uid) async {
    try {
      final doc = await _db.collection(usuariosCollection).doc(uid).get();
      if (!doc.exists) return null;
      return Usuario.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('obtenerUsuarioPorId → $e');
      return null;
    }
  }

  Future<bool> actualizarUsuario(Usuario usuario) async {
    try {
      await _db.collection(usuariosCollection).doc(usuario.id).update(usuario.toMap());
      return true;
    } catch (e) {
      print('actualizarUsuario → $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CLIENTE
  // ══════════════════════════════════════════════════════════════════════════

  /// Registra cliente + documento de usuario en Firestore.
  /// Recibe el UID de Firebase Auth para vincularlos correctamente.
  Future<Cliente?> registrarCliente({
    required String   uid,
    required String   correo,
    required String   nombre,
    required String?  rfc,
    required String   direccion,
    required String   telefono,
    required DateTime fechaNacimiento,
  }) async {
    try {
      final usuario = await registrarUsuario(uid: uid, correo: correo);
      if (usuario == null) throw Exception('No se pudo crear el documento de usuario');

      final docRef = _db.collection(clientesCollection).doc();
      final cliente = Cliente(
        id:              docRef.id,
        idU:             uid,           // apunta al UID de Firebase Auth
        nombre:          nombre,
        rfc:             rfc,
        direccion:       direccion,
        telefono:        telefono,
        fechaNacimiento: fechaNacimiento,
        activo:          true,
        createdAt:       DateTime.now(),
      );
      await docRef.set(cliente.toMap());
      await crearPreferenciaCliente(idC: cliente.id, direccion: direccion);
      return cliente;
    } catch (e) {
      print('registrarCliente → $e');
      return null;
    }
  }

  /// Busca el cliente activo asociado a un UID de Firebase Auth.
  Future<Cliente?> obtenerClientePorUid(String uid) async {
    try {
      final query = await _db
          .collection(clientesCollection)
          .where('idU', isEqualTo: uid)
          .where('activo', isEqualTo: true)
          .get();
      if (query.docs.isEmpty) return null;
      final doc = query.docs.first;
      return Cliente.fromMap(doc.data(), doc.id);
    } catch (e) {
      print('obtenerClientePorUid → $e');
      return null;
    }
  }

  /// Obtiene un cliente por su ID de documento Firestore.
  Future<Cliente?> obtenerClientePorId(String idC) async {
    try {
      final doc = await _db.collection(clientesCollection).doc(idC).get();
      if (!doc.exists) return null;
      return Cliente.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('obtenerClientePorId → $e');
      return null;
    }
  }

  Future<bool> actualizarCliente(Cliente cliente) async {
    try {
      await _db.collection(clientesCollection).doc(cliente.id).update(cliente.toMap());
      await actualizarPreferenciaClienteCliente(cliente);
      return true;
    } catch (e) {
      print('actualizarCliente → $e');
      return false;
    }
  }

  Future<bool> eliminarCliente(String idC) async {
    try {
      await _db.collection(clientesCollection).doc(idC).update({'activo': false});
      return true;
    } catch (e) {
      print('eliminarCliente → $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EMPLEADO
  // ══════════════════════════════════════════════════════════════════════════

  /// Registra empleado + documento de usuario en Firestore.
  /// Recibe el UID de Firebase Auth — NO recibe password.
  Future<Empleado?> registrarEmpleado({
    required String       uid,       // ← UID de Firebase Auth
    required String       correo,
    required String       nombre,
    required String       rfc,
    required DateTime     fechaNacimiento,
    required String       direccion,
    required double       sueldo,
    required String       ocupacion,
    required List<String> telefonos,
  }) async {
    try {
      final usuario = await registrarUsuario(uid: uid, correo: correo);
      if (usuario == null) throw Exception('No se pudo crear el documento de usuario');

      final docRef = _db.collection(empleadosCollection).doc();
      final empleado = Empleado(
        id:              docRef.id,
        idU:             uid,         // apunta al UID de Firebase Auth
        nombre:          nombre,
        rfc:             rfc,
        fechaNacimiento: fechaNacimiento,
        direccion:       direccion,
        sueldo:          sueldo,
        ocupacion:       ocupacion,
        telefonos:       telefonos,
        activo:          true,
        createdAt:       DateTime.now(),
      );
      await docRef.set(empleado.toMap());
      return empleado;
    } catch (e) {
      print('registrarEmpleado → $e');
      return null;
    }
  }

  /// Busca el empleado activo asociado a un UID de Firebase Auth.
  /// Firebase Auth ya validó la contraseña antes de llegar aquí.
  Future<Empleado?> validarEmpleado({
    required String uid,    // ← solo UID, sin password
  }) async {
    try {
      final query = await _db
          .collection(empleadosCollection)
          .where('idU', isEqualTo: uid)
          .where('activo', isEqualTo: true)
          .get();
      if (query.docs.isEmpty) return null;
      final doc = query.docs.first;
      return Empleado.fromMap(doc.data(), doc.id);
    } catch (e) {
      print('validarEmpleado → $e');
      return null;
    }
  }

  Future<Empleado?> obtenerEmpleadoPorId(String idE) async {
    try {
      final doc = await _db.collection(empleadosCollection).doc(idE).get();
      if (!doc.exists) return null;
      return Empleado.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('obtenerEmpleadoPorId → $e');
      return null;
    }
  }

  Future<bool> actualizarEmpleado(Empleado empleado) async {
    try {
      await _db.collection(empleadosCollection).doc(empleado.id).update(empleado.toMap());
      return true;
    } catch (e) {
      print('actualizarEmpleado → $e');
      return false;
    }
  }

  Future<bool> eliminarEmpleado(String idE) async {
    try {
      await _db.collection(empleadosCollection).doc(idE).update({'activo': false});
      return true;
    } catch (e) {
      print('eliminarEmpleado → $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PROVEEDOR
  // ══════════════════════════════════════════════════════════════════════════

  Future<Proveedor?> crearProveedor({
    required String       proveedor,
    required List<String> telefonos,
  }) async {
    try {
      final docRef = _db.collection(proveedoresCollection).doc();
      final nuevo = Proveedor(
        id:        docRef.id,
        proveedor: proveedor,
        telefonos: telefonos,
        activo:    true,
        createdAt: DateTime.now(),
      );
      await docRef.set(nuevo.toMap());
      return nuevo;
    } catch (e) {
      print('crearProveedor → $e');
      return null;
    }
  }

  Future<Proveedor?> obtenerProveedorPorId(String idP) async {
    try {
      final doc = await _db.collection(proveedoresCollection).doc(idP).get();
      if (!doc.exists) return null;
      return Proveedor.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('obtenerProveedorPorId → $e');
      return null;
    }
  }

  Future<List<Proveedor>> obtenerProveedoresActivos() async {
    try {
      final query = await _db
          .collection(proveedoresCollection)
          .where('activo', isEqualTo: true)
          .get();
      return query.docs.map((doc) => Proveedor.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('obtenerProveedoresActivos → $e');
      return [];
    }
  }

  Future<bool> actualizarProveedor(Proveedor proveedor) async {
    try {
      await _db.collection(proveedoresCollection).doc(proveedor.id).update(proveedor.toMap());
      return true;
    } catch (e) {
      print('actualizarProveedor → $e');
      return false;
    }
  }

  Future<bool> eliminarProveedor(String idP) async {
    try {
      await _db.collection(proveedoresCollection).doc(idP).update({'activo': false});
      return true;
    } catch (e) {
      print('eliminarProveedor → $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CATEGORIA ARTICULO
  // ══════════════════════════════════════════════════════════════════════════

  Future<CategoriaArticulo?> crearCategoria(String categoria) async {
    try {
      final docRef = _db.collection(categoriasCollection).doc();
      final nueva = CategoriaArticulo(
        id:        docRef.id,
        categoria: categoria,
        createdAt: DateTime.now(),
      );
      await docRef.set(nueva.toMap());
      return nueva;
    } catch (e) {
      print('crearCategoria → $e');
      return null;
    }
  }

  Future<List<CategoriaArticulo>> obtenerCategorias() async {
    try {
      final query = await _db.collection(categoriasCollection).get();
      return query.docs.map((doc) => CategoriaArticulo.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('obtenerCategorias → $e');
      return [];
    }
  }

  Future<CategoriaArticulo?> obtenerCategoriaPorId(String idCA) async {
    try {
      final doc = await _db.collection(categoriasCollection).doc(idCA).get();
      if (!doc.exists) return null;
      return CategoriaArticulo.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('obtenerCategoriaPorId → $e');
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ARTICULO
  // ══════════════════════════════════════════════════════════════════════════

  Future<Articulo?> insertarArticulo({
    required String  articulo,
    required String? descripcion,
    required String? imagen,
    required double  precio,
    required String  idP,
    required String  idCA,
  }) async {
    try {
      final proveedor = await obtenerProveedorPorId(idP);
      if (proveedor == null) throw Exception('Proveedor $idP no existe');

      final categoria = await obtenerCategoriaPorId(idCA);
      if (categoria == null) throw Exception('Categoría $idCA no existe');

      final docRef = _db.collection(articulosCollection).doc();
      final nuevo = Articulo(
        id:          docRef.id,
        articulo:    articulo,
        descripcion: descripcion,
        imagen:      imagen,
        precio:      precio,
        idP:         idP,
        idCA:        idCA,
        createdAt:   DateTime.now(),
      );
      await docRef.set(nuevo.toMap());
      return nuevo;
    } catch (e) {
      print('insertarArticulo → $e');
      return null;
    }
  }

  Future<Articulo?> obtenerArticuloPorId(String idA) async {
    try {
      final doc = await _db.collection(articulosCollection).doc(idA).get();
      if (!doc.exists) return null;
      return Articulo.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('obtenerArticuloPorId → $e');
      return null;
    }
  }

  Future<List<Articulo>> obtenerArticulos() async {
    try {
      final query = await _db.collection(articulosCollection).get();
      return query.docs.map((doc) => Articulo.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('obtenerArticulos → $e');
      return [];
    }
  }

 Future<List<Articulo>> obtenerArticulosPorCategoria(String idCA) async {
  try {
    print('🔍 Buscando artículos con idCA = "$idCA"'); // ← log temporal
    final query = await _db
        .collection(articulosCollection)
        .where('idCA', isEqualTo: idCA)
        .get();
    print('✅ Encontrados: ${query.docs.length} artículos'); // ← log temporal
    return query.docs
        .map((doc) => Articulo.fromMap(doc.data(), doc.id))
        .toList();
  } catch (e) {
    print('obtenerArticulosPorCategoria → $e');
    return [];
  }
}

  Future<bool> actualizarArticulo(Articulo articulo) async {
    try {
      await _db.collection(articulosCollection).doc(articulo.id).update(articulo.toMap());
      return true;
    } catch (e) {
      print('actualizarArticulo → $e');
      return false;
    }
  }

  Future<bool> eliminarArticulo(String idA) async {
    try {
      await _db.collection(articulosCollection).doc(idA).delete();
      return true;
    } catch (e) {
      print('eliminarArticulo → $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CARRITO
  // ══════════════════════════════════════════════════════════════════════════

  Future<Carrito?> agregarAlCarrito({
    required String idC,
    required String idA,
    required int    cantidad,
  }) async {
    try {
      final cliente = await obtenerClientePorId(idC);
      if (cliente == null) throw Exception('Cliente no encontrado');

      final articulo = await obtenerArticuloPorId(idA);
      if (articulo == null) throw Exception('Artículo no encontrado');

      final existingQuery = await _db
          .collection(carritoCollection)
          .where('idC', isEqualTo: idC)
          .where('idA', isEqualTo: idA)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        final current    = Carrito.fromMap(existingQuery.docs.first.data(), existingQuery.docs.first.id);
        final actualizado = current.copyWith(cantidad: current.cantidad + cantidad);
        await _db.collection(carritoCollection).doc(current.id).update(actualizado.toMap());
        return actualizado;
      }

      final docRef     = _db.collection(carritoCollection).doc();
      final carritoItem = Carrito(
        id:        docRef.id,
        idC:       idC,
        idA:       idA,
        cantidad:  cantidad,
        createdAt: DateTime.now(),
      );
      await docRef.set(carritoItem.toMap());
      return carritoItem;
    } catch (e) {
      print('agregarAlCarrito → $e');
      return null;
    }
  }

  Future<List<Carrito>> obtenerCarritoCliente(String idC) async {
    try {
      final query = await _db.collection(carritoCollection).where('idC', isEqualTo: idC).get();
      return query.docs.map((doc) => Carrito.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('obtenerCarritoCliente → $e');
      return [];
    }
  }

  Future<bool> eliminarDelCarrito(String idCarrito) async {
    try {
      await _db.collection(carritoCollection).doc(idCarrito).delete();
      return true;
    } catch (e) {
      print('eliminarDelCarrito → $e');
      return false;
    }
  }

  Future<bool> actualizarCantidadCarrito(String idCarrito, int nuevaCantidad) async {
    try {
      await _db.collection(carritoCollection).doc(idCarrito).update({'cantidad': nuevaCantidad});
      return true;
    } catch (e) {
      print('actualizarCantidadCarrito → $e');
      return false;
    }
  }

  Future<bool> limpiarCarritoCliente(String idC) async {
    try {
      final query = await _db.collection(carritoCollection).where('idC', isEqualTo: idC).get();
      for (final doc in query.docs) await doc.reference.delete();
      return true;
    } catch (e) {
      print('limpiarCarritoCliente → $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PEDIDO
  // ══════════════════════════════════════════════════════════════════════════

  Future<Pedido?> insertarPedido({
    required String descripcion,
    required String idC,
    required String idA,
    required int    cantidad,
    required double precio,
    String status = 'En Proceso',
  }) async {
    try {
      final cliente = await obtenerClientePorId(idC);
      if (cliente == null) throw Exception('Cliente no encontrado');

      final docRef    = _db.collection(pedidosCollection).doc();
      final nuevoPedido = Pedido(
        id:          docRef.id,
        descripcion: descripcion,
        idC:         idC,
        idA:         idA,
        cantidad:    cantidad,
        precio:      precio,
        status:      status,
        createdAt:   DateTime.now(),
      );
      await docRef.set(nuevoPedido.toMap());

      if (status == 'Pagado') await crearVenta(nuevoPedido.id);
      return nuevoPedido;
    } catch (e) {
      print('insertarPedido → $e');
      return null;
    }
  }

  Future<Pedido?> obtenerPedidoPorId(String idPed) async {
    try {
      final doc = await _db.collection(pedidosCollection).doc(idPed).get();
      if (!doc.exists) return null;
      return Pedido.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('obtenerPedidoPorId → $e');
      return null;
    }
  }

  Future<List<Pedido>> obtenerPedidosCliente(String idC) async {
    try {
      final query = await _db.collection(pedidosCollection).where('idC', isEqualTo: idC).get();
      return query.docs.map((doc) => Pedido.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('obtenerPedidosCliente → $e');
      return [];
    }
  }

  Future<bool> actualizarEstadoPedido(String idPed, String nuevoStatus) async {
    try {
      await _db.collection(pedidosCollection).doc(idPed).update({'status': nuevoStatus});

      if (nuevoStatus == 'Pagado') {
        final ventaExiste = await _db
            .collection(ventasCollection)
            .where('idPed', isEqualTo: idPed)
            .get();
        if (ventaExiste.docs.isEmpty) await crearVenta(idPed);
      }
      return true;
    } catch (e) {
      print('actualizarEstadoPedido → $e');
      return false;
    }
  }

  Future<List<Pedido>> obtenerTodosPedidos() async {
    try {
      final query = await _db.collection(pedidosCollection).get();
      return query.docs.map((doc) => Pedido.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('obtenerTodosPedidos → $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VENTA
  // ══════════════════════════════════════════════════════════════════════════

  Future<Venta?> crearVenta(String idPed) async {
    try {
      final query = await _db.collection(ventasCollection).where('idPed', isEqualTo: idPed).get();
      if (query.docs.isNotEmpty) return Venta.fromMap(query.docs.first.data(), query.docs.first.id);

      final docRef   = _db.collection(ventasCollection).doc();
      final nuevaVenta = Venta(
        id:        docRef.id,
        idPed:     idPed,
        createdAt: DateTime.now(),
      );
      await docRef.set(nuevaVenta.toMap());
      return nuevaVenta;
    } catch (e) {
      print('crearVenta → $e');
      return null;
    }
  }

  Future<Venta?> obtenerVentaPorId(String idV) async {
    try {
      final doc = await _db.collection(ventasCollection).doc(idV).get();
      if (!doc.exists) return null;
      return Venta.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('obtenerVentaPorId → $e');
      return null;
    }
  }

  Future<List<Venta>> obtenerTodasVentas() async {
    try {
      final query = await _db.collection(ventasCollection).get();
      return query.docs.map((doc) => Venta.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('obtenerTodasVentas → $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PREFERENCIA CLIENTE
  // ══════════════════════════════════════════════════════════════════════════

  Future<PreferenciaCliente?> crearPreferenciaCliente({
    required String  idC,
    String?          direccion,
    String?          metodoPago,
  }) async {
    try {
      final docRef    = _db.collection(preferenciaClienteCollection).doc();
      final preferencia = PreferenciaCliente(
        id:             docRef.id,
        idC:            idC,
        direccionPred:  direccion,
        metodoPagoPred: metodoPago,
        createdAt:      DateTime.now(),
      );
      await docRef.set(preferencia.toMap());
      return preferencia;
    } catch (e) {
      print('crearPreferenciaCliente → $e');
      return null;
    }
  }

  Future<PreferenciaCliente?> obtenerPreferenciaCliente(String idC) async {
    try {
      final query = await _db
          .collection(preferenciaClienteCollection)
          .where('idC', isEqualTo: idC)
          .get();
      if (query.docs.isEmpty) return null;
      final doc = query.docs.first;
      return PreferenciaCliente.fromMap(doc.data(), doc.id);
    } catch (e) {
      print('obtenerPreferenciaCliente → $e');
      return null;
    }
  }

  Future<bool> actualizarPreferenciaCliente({
    required String idC,
    String?         direccion,
    String?         metodoPago,
  }) async {
    try {
      final preferencia = await obtenerPreferenciaCliente(idC);
      if (preferencia == null) {
        await crearPreferenciaCliente(idC: idC, direccion: direccion, metodoPago: metodoPago);
      } else {
        final actualizada = preferencia.copyWith(
          direccionPred:  direccion  ?? preferencia.direccionPred,
          metodoPagoPred: metodoPago ?? preferencia.metodoPagoPred,
        );
        await _db
            .collection(preferenciaClienteCollection)
            .doc(preferencia.id)
            .update(actualizada.toMap());
      }
      return true;
    } catch (e) {
      print('actualizarPreferenciaCliente → $e');
      return false;
    }
  }

  Future<bool> actualizarPreferenciaClienteCliente(Cliente cliente) async {
    return actualizarPreferenciaCliente(
      idC:        cliente.id,
      direccion:  cliente.direccion,
      metodoPago: cliente.metodoPago,
    );
  }

  Future<bool> eliminarDireccionPreferenciaCliente(String idC) async {
    try {
      final preferencia = await obtenerPreferenciaCliente(idC);
      if (preferencia == null) return false;
      await _db
          .collection(preferenciaClienteCollection)
          .doc(preferencia.id)
          .update(preferencia.copyWith(direccionPred: null).toMap());
      return true;
    } catch (e) {
      print('eliminarDireccionPreferenciaCliente → $e');
      return false;
    }
  }

  Future<bool> eliminarMetodoPagoPreferenciaCliente(String idC) async {
    try {
      final preferencia = await obtenerPreferenciaCliente(idC);
      if (preferencia == null) return false;
      await _db
          .collection(preferenciaClienteCollection)
          .doc(preferencia.id)
          .update(preferencia.copyWith(metodoPagoPred: null).toMap());
      return true;
    } catch (e) {
      print('eliminarMetodoPagoPreferenciaCliente → $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INVENTARIO
  // ══════════════════════════════════════════════════════════════════════════

  Future<Inventario?> crearInventario({
    required String descripcion,
    required String idA,
    required String idP,
    required int    stock,
  }) async {
    try {
      final articulo = await obtenerArticuloPorId(idA);
      if (articulo == null) throw Exception('Artículo no encontrado');

      final proveedor = await obtenerProveedorPorId(idP);
      if (proveedor == null) throw Exception('Proveedor no encontrado');

      final docRef   = _db.collection(inventarioCollection).doc();
      final inventario = Inventario(
        id:          docRef.id,
        descripcion: descripcion,
        idA:         idA,
        idP:         idP,
        stock:       stock,
        createdAt:   DateTime.now(),
      );
      await docRef.set(inventario.toMap());
      return inventario;
    } catch (e) {
      print('crearInventario → $e');
      return null;
    }
  }

  Future<Inventario?> obtenerInventarioPorArticulo(String idA) async {
    try {
      final query = await _db.collection(inventarioCollection).where('idA', isEqualTo: idA).get();
      if (query.docs.isEmpty) return null;
      final doc = query.docs.first;
      return Inventario.fromMap(doc.data(), doc.id);
    } catch (e) {
      print('obtenerInventarioPorArticulo → $e');
      return null;
    }
  }

  Future<bool> actualizarStock(String idArticulo, int nuevoStock) async {
    try {
      final inventario = await obtenerInventarioPorArticulo(idArticulo);
      if (inventario == null) return false;
      await _db.collection(inventarioCollection).doc(inventario.id).update({'stock': nuevoStock});
      return true;
    } catch (e) {
      print('actualizarStock → $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // QR
  // ══════════════════════════════════════════════════════════════════════════

  Future<QR?> crearQR(String url) async {
    try {
      final docRef = _db.collection(qrCollection).doc();
      final qr = QR(id: docRef.id, url: url, createdAt: DateTime.now());
      await docRef.set(qr.toMap());
      return qr;
    } catch (e) {
      print('crearQR → $e');
      return null;
    }
  }

  Future<QR?> obtenerQRPorId(String idQR) async {
    try {
      final doc = await _db.collection(qrCollection).doc(idQR).get();
      if (!doc.exists) return null;
      return QR.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('obtenerQRPorId → $e');
      return null;
    }
  }

  Future<List<QR>> obtenerTodosQRs() async {
    try {
      final query = await _db.collection(qrCollection).get();
      return query.docs.map((doc) => QR.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('obtenerTodosQRs → $e');
      return [];
    }
  }

  Future<bool> eliminarQR(String idQR) async {
    try {
      await _db.collection(qrCollection).doc(idQR).delete();
      return true;
    } catch (e) {
      print('eliminarQR → $e');
      return false;
    }
  }
}