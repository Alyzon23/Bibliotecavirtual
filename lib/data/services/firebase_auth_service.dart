import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart' as app_user;

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  app_user.User? _currentUser;
  
  app_user.User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<bool> register(String email, String password, String name, {bool isAdmin = false}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        try {
          await _firestore.collection('users').doc(credential.user!.uid).set({
            'email': email,
            'name': name,
            'role': isAdmin ? 'admin' : 'user',
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (firestoreError) {
          print('Error Firestore: $firestoreError');
        }

        _currentUser = app_user.User(
          id: credential.user!.uid,
          email: email,
          name: name,
          role: isAdmin ? app_user.UserRole.admin : app_user.UserRole.user,
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
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Temporal: admin hardcoded
        final isAdmin = email == 'admin@biblioteca.com';
        
        _currentUser = app_user.User(
          id: credential.user!.uid,
          email: email,
          name: credential.user!.displayName ?? 'Usuario',
          role: isAdmin ? app_user.UserRole.admin : app_user.UserRole.user,
          createdAt: DateTime.now(),
        );
        return true;
      }
    } catch (e) {
      print('Error en login: $e');
    }
    return false;
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
  }
}