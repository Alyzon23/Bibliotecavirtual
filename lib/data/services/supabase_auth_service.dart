import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart' as app_user;

class SupabaseAuthService {
  final _supabase = Supabase.instance.client;
  
  app_user.User? _currentUser;
  
  app_user.User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<bool> register(String email, String password, String name) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        try {
          await _supabase.from('users').insert({
            'id': response.user!.id,
            'email': email,
            'name': name,
            'role': 'user',
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          print('Error insertando usuario: $e');
        }

        _currentUser = app_user.User(
          id: response.user!.id,
          email: email,
          name: name,
          role: app_user.UserRole.user,
          createdAt: DateTime.now(),
        );
        return true;
      }
    } catch (e) {
      print('Error en registro: $e');
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        try {
          final userData = await _supabase
              .from('users')
              .select()
              .eq('id', response.user!.id)
              .single();

          _currentUser = app_user.User(
            id: response.user!.id,
            email: userData['email'],
            name: userData['name'],
            role: userData['role'] == 'admin' ? app_user.UserRole.admin : app_user.UserRole.user,
            createdAt: DateTime.parse(userData['created_at']),
          );
        } catch (e) {
          // Si no existe en users, crear usuario básico
          _currentUser = app_user.User(
            id: response.user!.id,
            email: email,
            name: 'Usuario',
            role: app_user.UserRole.user,
            createdAt: DateTime.now(),
          );
        }
        return true;
      }
    } catch (e) {
      print('Error en login: $e');
    }
    return false;
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
  }
}