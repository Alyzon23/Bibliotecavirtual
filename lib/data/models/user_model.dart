enum UserRole { admin, bibliotecario, profesor, lector }

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isBibliotecario => role == UserRole.bibliotecario;
  bool get isProfesor => role == UserRole.profesor;
  bool get isLector => role == UserRole.lector;
  
  // Permisos específicos
  bool get canUploadContent => isAdmin || isBibliotecario || isProfesor;
  bool get canDeleteContent => isAdmin || isBibliotecario;
  bool get canEditContent => isAdmin || isBibliotecario;
  bool get canManageUsers => isAdmin;
  bool get canViewStats => isAdmin || isBibliotecario;
}