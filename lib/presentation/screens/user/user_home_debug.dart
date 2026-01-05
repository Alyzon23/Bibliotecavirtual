// Archivo temporal para debug - agregar estas líneas al _loadUserData()

setState(() {
  _userName = userData['name'] ?? 'Usuario';
  _userEmail = userData['email'] ?? user.email ?? 'user@biblioteca.com';
  _userRole = userData['role'] ?? 'usuario';
  final role = userData['role']?.toString().toLowerCase() ?? 'lector';
  _canEdit = role == 'profesor' || role == 'bibliotecario' || role == 'admin' || role == 'administrador';
  
  // DEBUG: Agregar estas líneas
  print('🔍 Debug UserHome - Rol original: ${userData['role']}');
  print('🔍 Debug UserHome - Rol procesado: $role');
  print('🔍 Debug UserHome - CanEdit: $_canEdit');
  print('🔍 Debug UserHome - Comparaciones:');
  print('   - profesor: ${role == 'profesor'}');
  print('   - bibliotecario: ${role == 'bibliotecario'}');
  print('   - admin: ${role == 'admin'}');
  print('   - administrador: ${role == 'administrador'}');
});