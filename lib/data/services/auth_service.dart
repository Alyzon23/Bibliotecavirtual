import '../models/user_model.dart';

class AuthService {
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<bool> login(String email, String password) async {
    // Simulación de login - reemplazar con API real
    await Future.delayed(const Duration(seconds: 1));
    
    if (email == 'admin@biblioteca.com' && password == 'admin123') {
      _currentUser = User(
        id: '1',
        email: email,
        name: 'Administrador',
        role: UserRole.admin,
        createdAt: DateTime.now(),
      );
      return true;
    } else if (email == 'user@biblioteca.com' && password == 'user123') {
      _currentUser = User(
        id: '2',
        email: email,
        name: 'Usuario',
        role: UserRole.user,
        createdAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
  }
}