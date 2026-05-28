import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario_model.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  late FirebaseAuth _auth;
  late DatabaseService _db;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User?         get currentUser      => _auth.currentUser;
  bool          get isAuthenticated  => _auth.currentUser != null;

  factory AuthService() => _instance;

  AuthService._internal() {
    _auth = FirebaseAuth.instance;
    _db   = DatabaseService();
  }

  Future<Usuario?> registrarClienteConEmail({
    required String   correo,
    required String   password,
    required String   nombre,
    required String?  rfc,
    required String   direccion,
    required String   telefono,
    required DateTime fechaNacimiento,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email:    correo,
        password: password,
      );
      final firebaseUser = cred.user;
      if (firebaseUser == null) throw Exception('Firebase Auth no devolvió usuario');

      final cliente = await _db.registrarCliente(
        uid:             firebaseUser.uid,
        correo:          correo,
        nombre:          nombre,
        rfc:             rfc,
        direccion:       direccion,
        telefono:        telefono,
        fechaNacimiento: fechaNacimiento,
      );

   
      if (cliente == null) {
        await firebaseUser.delete();
        throw Exception('No se pudo guardar el cliente en Firestore');
      }

      await firebaseUser.updateDisplayName(nombre);

      return Usuario(
        id:        firebaseUser.uid,
        correo:    correo,
        password:  '',          
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      print('registrarClienteConEmail → $e');
      return null;
    }
  }


  Future<Usuario?> loginConEmail({
    required String correo,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email:    correo,
        password: password,
      );
      final firebaseUser = cred.user;
      if (firebaseUser == null) throw Exception('Firebase Auth no devolvió usuario');

      final cliente = await _db.obtenerClientePorUid(firebaseUser.uid);
      if (cliente == null) {
        await _auth.signOut();
        throw Exception('No se encontró un cliente activo para este usuario');
      }

      return Usuario(
        id:        firebaseUser.uid,
        correo:    correo,
        password:  '',
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      print('loginConEmail → $e');
      return null;
    }
  }

  Future<Usuario?> registrarEmpleadoConEmail({
    required String       correo,
    required String       password,
    required String       nombre,
    required String       rfc,
    required DateTime     fechaNacimiento,
    required String       direccion,
    required double       sueldo,
    required String       ocupacion,
    required List<String> telefonos,
  }) async {
    try {
      // 1. Crear en Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email:    correo,
        password: password,
      );
      final firebaseUser = cred.user;
      if (firebaseUser == null) throw Exception('Firebase Auth no devolvió usuario');

      final empleado = await _db.registrarEmpleado(
        uid:             firebaseUser.uid,  
        correo:          correo,
        nombre:          nombre,
        rfc:             rfc,
        fechaNacimiento: fechaNacimiento,
        direccion:       direccion,
        sueldo:          sueldo,
        ocupacion:       ocupacion,
        telefonos:       telefonos,
      );

      if (empleado == null) {
        await firebaseUser.delete();
        throw Exception('No se pudo guardar el empleado en Firestore');
      }

      await firebaseUser.updateDisplayName(nombre);

      return Usuario(
        id:        firebaseUser.uid,
        correo:    correo,
        password:  '',
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      print('registrarEmpleadoConEmail → $e');
      return null;
    }
  }

  Future<Usuario?> loginEmpleadoConEmail({
    required String correo,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email:    correo,
        password: password,
      );
      final firebaseUser = cred.user;
      if (firebaseUser == null) throw Exception('Firebase Auth no devolvió usuario');

      final empleado = await _db.validarEmpleado(uid: firebaseUser.uid);
      if (empleado == null) {
        await _auth.signOut();
        throw Exception('No se encontró un empleado activo para este usuario');
      }

      return Usuario(
        id:        firebaseUser.uid,
        correo:    correo,
        password:  '',
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      print('loginEmpleadoConEmail → $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('logout → $e');
    }
  }

  Future<bool> cambiarContrasena({
    required String passwordActual,
    required String nuevaPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) throw Exception('No hay usuario autenticado');

      final credential = EmailAuthProvider.credential(
        email:    user.email!,
        password: passwordActual,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(nuevaPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      print('cambiarContrasena → $e');
      return false;
    }
  }

  Future<bool> enviarEmailRecuperacion(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      print('enviarEmailRecuperacion → $e');
      return false;
    }
  }

  Future<bool> enviarEmailVerificacion() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');
      await user.sendEmailVerification();
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      print('enviarEmailVerificacion → $e');
      return false;
    }
  }

  Future<bool> eliminarCuenta() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');
      await user.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      print('eliminarCuenta → $e');
      return false;
    }
  }

  Future<Usuario?> obtenerUsuarioActual() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;
      return await _db.obtenerUsuarioPorId(firebaseUser.uid);
    } catch (e) {
      print('obtenerUsuarioActual → $e');
      return null;
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    final mensajes = {
      'user-not-found':        'El usuario no existe',
      'wrong-password':        'Contraseña incorrecta',
      'invalid-credential':    'Credenciales inválidas',   // nuevo código de Firebase
      'email-already-in-use':  'El email ya está registrado',
      'invalid-email':         'Email inválido',
      'weak-password':         'La contraseña es muy débil (mínimo 6 caracteres)',
      'operation-not-allowed': 'Operación no permitida',
      'too-many-requests':     'Demasiados intentos, espera un momento',
      'requires-recent-login': 'Debes iniciar sesión nuevamente para esta acción',
      'network-request-failed':'Sin conexión a internet',
    };

    final msg = mensajes[e.code] ?? e.message ?? 'Error desconocido';
    print('FirebaseAuthError [${e.code}]: $msg');
    // El mensaje ya está logueado; el caller muestra su propio error al usuario.
  }
}