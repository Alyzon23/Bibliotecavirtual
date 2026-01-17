import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animate_do/animate_do.dart';
import '../../../data/services/supabase_auth_service.dart';
import '../../../core/services/lazy_loading_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';
import '../../../main.dart';
import 'tabs/home_tab.dart';
import 'tabs/library_tab.dart';
import 'tabs/videos_tab.dart';
import '../admin/add_book_screen.dart';
import '../admin/add_video_screen.dart';
import 'users_management_screen.dart';
import 'book_detail_screen.dart';
import '../../../data/services/cache_service.dart';

class UserHome extends StatefulWidget {
  final SupabaseAuthService authService;
  
  const UserHome({super.key, required this.authService});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> with LazyLoadingMixin {
  int _selectedIndex = 0;
  String _userName = 'Usuario';
  String _userRole = 'usuario';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ValueNotifier<bool> _searchingNotifier = ValueNotifier<bool>(false);
  bool _canEdit = false;

  @override
  void initState() {
    super.initState();
    _loadUserDataAsync();
  }

  void _loadUserDataAsync() {
    Future.microtask(() async {
      await _loadUserData();
    });
  }

  @override
  void dispose() {
    _searchingNotifier.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final userData = await Supabase.instance.client
            .from('users')
            .select('name, role')
            .eq('id', user.id)
            .single();
        
        if (mounted) {
          setState(() {
            _userName = userData['name'] ?? 'Usuario';
            _userRole = userData['role'] ?? 'usuario';
            final role = userData['role']?.toString().toLowerCase() ?? 'lector';
            _canEdit = ['profesor', 'bibliotecario', 'admin', 'administrador'].contains(role);
          });
        }
      } catch (e) {
        print('Error cargando datos del usuario: $e');
      }
    }
  }

  void _logout() {
    widget.authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resultados para "$query"'),
        content: const SizedBox(
          width: 400,
          height: 200,
          child: Center(
            child: Text('Función de búsqueda en desarrollo'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _getSelectedPage() {
    if (_searchQuery.isNotEmpty) {
      return _SearchResultsTab(searchQuery: _searchQuery);
    }
    
    switch (_selectedIndex) {
      case 0:
        return HomeTab(searchQuery: _searchQuery);
      case 1:
        return LibraryTab(canEdit: _canEdit, userRole: _userRole);
      case 2:
        return VideosTab(canEdit: _canEdit, userRole: _userRole);
      case 3:
        return _FavoritesTab(canEdit: _canEdit);
      case 4:
        return _ProfileTab(userRole: _userRole);
      case 5:
        return const _TopBooksTab();
      case 6:
        return _AddContentTab(canEdit: _canEdit);
      case 7:
        return const _UserManagementTab();
      case 8:
        return const _RequestsTab();
      default:
        return HomeTab(searchQuery: _searchQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Para móvil (APK) usar Drawer, para web usar sidebar fijo
    final isMobile = !kIsWeb;
    
    return Scaffold(
      drawer: isMobile ? _buildDrawer() : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Row(
          children: [
            // Sidebar fijo solo para web
            if (!isMobile) _buildSidebar(),
            // Contenido principal
            Expanded(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: _getSelectedPage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: FadeInLeft(
        child: GlassmorphicContainer(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 0,
          blur: 20,
          alignment: Alignment.center,
          border: 0,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.yaviracBlueDark.withOpacity(0.9),
              AppColors.yaviracOrange.withOpacity(0.95),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          child: Column(
            children: [
              _buildUserHeader(),
              _buildMenuItems(),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return FadeInLeft(
      child: GlassmorphicContainer(
        width: 280,
        height: double.infinity,
        borderRadius: 0,
        blur: 20,
        alignment: Alignment.center,
        border: 0,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.yaviracBlueDark.withOpacity(0.9),
            AppColors.yaviracOrange.withOpacity(0.95),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        child: Column(
          children: [
            _buildUserHeader(),
            _buildMenuItems(),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/yavirac.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.avatarGradient,
                    shape: BoxShape.circle,
                    boxShadow: [AppColors.avatarShadow],
                  ),
                  child: Center(
                    child: Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: AppColors.roleGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _userRole.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: AppColors.getRoleTextColor(_userRole),
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildMenuItem(Icons.home, 'Inicio', 0),
          _buildMenuItem(Icons.library_books, 'Libros', 1),
          _buildMenuItem(Icons.video_library, 'Videos', 2),
          _buildMenuItem(Icons.favorite, 'Favoritos', 3),
          _buildMenuItem(Icons.person, 'Perfil', 4),
          const Divider(color: Colors.white24, height: 32),
          _buildMenuItem(Icons.trending_up, 'Top 10 Libros', 5),
          if (_canEdit) _buildMenuItem(Icons.add, 'Agregar Contenido', 6),
          if (_userRole == 'admin' || _userRole == 'administrador') _buildMenuItem(Icons.people, 'Gestión de Usuarios', 7),
          if (_userRole == 'admin' || _userRole == 'administrador') _buildMenuItem(Icons.help_center, 'Solicitudes', 8),
          _buildMenuItem(Icons.settings, 'Configuración', -1, onTap: () => setState(() => _selectedIndex = 4)),
          ListTile(
            leading: const Icon(Icons.dark_mode, color: Colors.white70),
            title: const Text('Modo Oscuro', style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppColors.logoutGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [AppColors.logoutShadow],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _logout,
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Cerrar Sesión',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final isMobile = !kIsWeb;
    return GlassmorphicContainer(
      width: double.infinity,
      height: isMobile ? 60 : 70,
      borderRadius: 0,
      blur: 15,
      alignment: Alignment.center,
      border: 0,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
        child: Row(
          children: [
            // Botón de menú solo para móvil
            if (isMobile)
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            if (isMobile) const SizedBox(width: 16),
            if (!isMobile) const Spacer(),
            Text(
              'Biblioteca Virtual Yavirac',
              style: GoogleFonts.outfit(
                fontSize: isMobile ? 18 : 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            if (!isMobile) _buildSearchField(),
            if (!isMobile) _buildSearchButton(),
            if (!isMobile) const SizedBox(width: 12),
            if (!isMobile) Text(
              _userName,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            if (!isMobile) const SizedBox(width: 12),
            if (!isMobile) Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                onPressed: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return ValueListenableBuilder<bool>(
      valueListenable: _searchingNotifier,
      builder: (context, isSearching, child) {
        return isSearching
            ? Container(
                height: 40,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.yaviracOrange, width: 1),
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.outfit(color: Colors.grey.shade800, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                  onSubmitted: (value) {
                    _searchingNotifier.value = false;
                    setState(() => _searchQuery = '');
                  },
                  autofocus: true,
                ),
              )
            : const SizedBox(width: 250);
      },
    );
  }

  Widget _buildSearchButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: _searchingNotifier,
        builder: (context, isSearching, child) {
          return IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.white70),
            onPressed: () {
              _searchingNotifier.value = !_searchingNotifier.value;
              if (!_searchingNotifier.value) {
                _searchController.clear();
                setState(() => _searchQuery = '');
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index, {VoidCallback? onTap}) {
    final isSelected = _selectedIndex == index;
    return FadeInLeft(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.menuItemGradient : null,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Cerrar drawer en móvil después de seleccionar
              if (!kIsWeb && Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              if (onTap != null) {
                onTap();
              } else if (index >= 0) {
                setState(() => _selectedIndex = index);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  final bool canEdit;
  const _FavoritesTab({required this.canEdit});

  Future<List<Map<String, dynamic>>> _loadFavorites() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await Supabase.instance.client
          .from('favorites')
          .select('book_id, books(*)')
          .eq('user_id', user.id);
      
      return response.map((item) => item['books'] as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis Favoritos',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadFavorites(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite_border, size: 80, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes favoritos aún',
                          style: GoogleFonts.outfit(fontSize: 18, color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                }
                
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final book = snapshot.data![index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailScreen(book: book),
                        ),
                      ),
                      child: GlassmorphicContainer(
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: 8,
                        blur: 8,
                        alignment: Alignment.center,
                        border: 0,
                        linearGradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.08),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Container(
                                margin: const EdgeInsets.all(6),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: book['cover_url'] != null
                                      ? Image.network(
                                          book['cover_url'],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: Colors.red.withOpacity(0.2),
                                            child: const Icon(Icons.favorite, size: 30, color: Colors.red),
                                          ),
                                        )
                                      : Container(
                                          color: Colors.red.withOpacity(0.2),
                                          child: const Icon(Icons.favorite, size: 30, color: Colors.red),
                                        ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                                child: Text(
                                  book['title'] ?? 'Sin título',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatefulWidget {
  final String userRole;
  const _ProfileTab({required this.userRole});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.1),
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, String>>(
            key: ValueKey(DateTime.now().millisecondsSinceEpoch), // Forzar rebuild
            future: _getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(color: Colors.white);
              }
              
              final userData = snapshot.data ?? {'name': 'Usuario', 'email': 'user@biblioteca.com'};
              
              return Column(
                children: [
                  Text(
                    userData['name']!,
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    userData['email']!,
                    style: GoogleFonts.outfit(color: Colors.white70),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          _buildProfileTile(Icons.history, 'Historial de lectura'),
          _buildProfileTile(Icons.settings, 'Configuración', onTap: () => _showConfigDialog(context)),
          _buildProfileTile(Icons.help, 'Ayuda', onTap: () => _showHelpDialog(context)),
        ],
      ),
    );
  }

  Future<Map<String, String>> _getUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final userData = await Supabase.instance.client
            .from('users')
            .select('name, email')
            .eq('id', user.id)
            .single();
        
        return {
          'name': userData['name'] ?? 'Usuario',
          'email': userData['email'] ?? user.email ?? 'user@biblioteca.com',
        };
      } catch (e) {
        return {
          'name': 'Usuario',
          'email': user.email ?? 'user@biblioteca.com',
        };
      }
    }
    return {'name': 'Usuario', 'email': 'user@biblioteca.com'};
  }

  void _showConfigDialog(BuildContext context) {
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Configuración', style: GoogleFonts.outfit(color: Colors.white)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nuevo nombre',
                  labelStyle: GoogleFonts.outfit(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.yaviracOrange),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                style: GoogleFonts.outfit(color: Colors.white),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  labelStyle: GoogleFonts.outfit(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.yaviracOrange),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                style: GoogleFonts.outfit(color: Colors.white),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  labelStyle: GoogleFonts.outfit(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.yaviracOrange),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.outfit(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.yaviracOrange),
            onPressed: () async {
              await _updateUserData(context, nameController.text, passwordController.text, confirmPasswordController.text);
            },
            child: Text('Guardar', style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final requestController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            const Icon(Icons.help, color: Colors.white),
            const SizedBox(width: 8),
            Text('Ayuda y Soporte', style: GoogleFonts.outfit(color: Colors.white)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Escribe tu solicitud:',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: requestController,
                maxLines: 5,
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Describe tu solicitud aquí...',
                  hintStyle: GoogleFonts.outfit(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.outfit(color: Colors.white70)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                if (requestController.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  _sendRequest(requestController.text, context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor escribe tu solicitud'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Enviar', style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _sendRequest(String request, BuildContext context) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('❌ No hay usuario autenticado');
        return;
      }
      
      print('📤 Enviando solicitud: $request');
      print('👤 Usuario ID: ${user.id}');
      
      // Obtener datos del usuario
      final userData = await Supabase.instance.client
          .from('users')
          .select('name, email')
          .eq('id', user.id)
          .single();
      
      final userName = userData['name'] ?? 'Usuario';
      final userEmail = userData['email'] ?? user.email ?? 'usuario@yavirac.edu.ec';
      
      final response = await Supabase.instance.client.from('requests').insert({
        'user_id': user.id,
        'user_name': userName,
        'user_email': userEmail,
        'request_text': request,
        'status': 'pendiente',
      }).select();
      
      print('✅ Respuesta: $response');
      
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Solicitud enviada correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
    } catch (e) {
      print('💥 Error enviando solicitud: $e');
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar solicitud: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateUserData(BuildContext context, String name, String password, String confirmPassword) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Actualizar nombre si se proporcionó
      if (name.isNotEmpty) {
        await Supabase.instance.client
            .from('users')
            .update({'name': name})
            .eq('id', user.id);
      }

      // Actualizar contraseña si se proporcionó
      if (password.isNotEmpty) {
        if (password != confirmPassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Las contraseñas no coinciden')),
          );
          return;
        }
        
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: password),
        );
      }

      Navigator.pop(context);
      setState(() {}); // Actualizar UI
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos actualizados correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildProfileTile(IconData icon, String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 70,
        borderRadius: 12,
        blur: 10,
        alignment: Alignment.center,
        border: 0,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.white70),
          title: Text(title, style: GoogleFonts.outfit(color: Colors.white)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _SearchResultsTab extends StatelessWidget {
  final String searchQuery;
  const _SearchResultsTab({required this.searchQuery});

  Future<List<Map<String, dynamic>>> _searchBooks() async {
    try {
      final response = await Supabase.instance.client
          .from('books')
          .select()
          .ilike('title', '%$searchQuery%');
      
      final response2 = await Supabase.instance.client
          .from('books')
          .select()
          .ilike('author', '%$searchQuery%');
      
      final allResults = [...response, ...response2];
      final uniqueResults = <String, Map<String, dynamic>>{};
      
      for (var book in allResults) {
        uniqueResults[book['id']] = book;
      }
      
      return uniqueResults.values.toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resultados para "$searchQuery"',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _searchBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 80, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron resultados',
                          style: GoogleFonts.outfit(fontSize: 18, color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                }
                
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final book = snapshot.data![index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailScreen(book: book),
                        ),
                      ),
                      child: GlassmorphicContainer(
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: 8,
                        blur: 8,
                        alignment: Alignment.center,
                        border: 0,
                        linearGradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.08),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          colors: [
                            AppColors.yaviracOrange.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Container(
                                margin: const EdgeInsets.all(6),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: book['cover_url'] != null
                                      ? Image.network(
                                          book['cover_url'],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: AppColors.yaviracOrange.withOpacity(0.2),
                                            child: const Icon(Icons.search, size: 30, color: Colors.white),
                                          ),
                                        )
                                      : Container(
                                          color: AppColors.yaviracOrange.withOpacity(0.2),
                                          child: const Icon(Icons.search, size: 30, color: Colors.white),
                                        ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                                child: Column(
                                  children: [
                                    Text(
                                      book['title'] ?? 'Sin título',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      book['author'] ?? 'Autor desconocido',
                                      style: GoogleFonts.outfit(
                                        fontSize: 8,
                                        color: Colors.white70,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class _TopBooksTab extends StatefulWidget {
  const _TopBooksTab({super.key});

  @override
  State<_TopBooksTab> createState() => _TopBooksTabState();
}

class _TopBooksTabState extends State<_TopBooksTab> {
  
  Future<List<Map<String, dynamic>>> _loadTopBooks() async {
    try {
      final response = await Supabase.instance.client
          .from('book_stats')
          .select('*, books(*)')
          .order('open_count', ascending: false)
          .limit(10);
      return response;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top 10 Libros Más Leídos',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadTopBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No hay estadísticas disponibles', style: GoogleFonts.outfit(color: Colors.white70)),
                  );
                }
                
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    final book = item['books'];
                    final openCount = item['open_count'] ?? 0;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassmorphicContainer(
                        width: double.infinity,
                        height: 80,
                        borderRadius: 12,
                        blur: 10,
                        alignment: Alignment.center,
                        border: 0,
                        linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.yaviracOrange,
                            foregroundColor: Colors.white,
                            child: Text('${index + 1}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                          ),
                          title: Text(book['title'] ?? 'Sin título', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
                          subtitle: Text('${book['author'] ?? 'Autor desconocido'} • $openCount lecturas', style: GoogleFonts.outfit(color: Colors.white70)),
                          trailing: const Icon(Icons.trending_up, color: Colors.greenAccent),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class _AddContentTab extends StatelessWidget {
  final bool canEdit;
  const _AddContentTab({required this.canEdit});

  @override
  Widget build(BuildContext context) {
    if (!canEdit) {
      return const Center(
        child: Text('No tienes permisos para agregar contenido', 
                   style: TextStyle(color: Colors.white70)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agregar Contenido',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddBookScreen(),
                    ),
                  ),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.library_books, size: 64, color: Colors.white),
                        const SizedBox(height: 16),
                        Text(
                          'Agregar Libros',
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddVideoScreen(),
                    ),
                  ),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.video_library, size: 64, color: Colors.white),
                        const SizedBox(height: 16),
                        Text(
                          'Agregar Videos',
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserManagementTab extends StatelessWidget {
  const _UserManagementTab();

  @override
  Widget build(BuildContext context) {
    return const UsersManagementScreen();
  }
}

class _RequestsTab extends StatefulWidget {
  const _RequestsTab();

  @override
  State<_RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<_RequestsTab> {
  late Stream<List<Map<String, dynamic>>> _requestsStream;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    _requestsStream = Supabase.instance.client
        .from('requests')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  void _refreshStream() {
    setState(() {
      _initializeStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solicitudes de Soporte',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _requestsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay solicitudes', style: GoogleFonts.outfit(color: Colors.white70)));
                }
                
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final request = snapshot.data![index];
                    final isResolved = request['status'] == 'resuelto';
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassmorphicContainer(
                        width: double.infinity,
                        height: 100,
                        borderRadius: 12,
                        blur: 10,
                        alignment: Alignment.center,
                        border: 0,
                        linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            (isResolved ? Colors.green : Colors.orange).withOpacity(0.1),
                            (isResolved ? Colors.green : Colors.orange).withOpacity(0.05),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isResolved ? Colors.green : Colors.orange,
                            child: Icon(
                              isResolved ? Icons.check : Icons.help_outline,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(request['request_text']?.toString().substring(0, request['request_text'].toString().length > 30 ? 30 : request['request_text'].toString().length) ?? 'Solicitud', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${request['user_name'] ?? 'Usuario'} • ayuda'.toUpperCase(), style: GoogleFonts.outfit(color: Colors.white70)),
                              Text(isResolved ? 'RESUELTO' : 'PENDIENTE', style: GoogleFonts.outfit(color: isResolved ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility, color: Colors.white70),
                                onPressed: () => _showRequestDetails(context, request),
                              ),
                              if (!isResolved)
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: () => _markAsResolved(context, request['id'].toString()),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteRequest(context, request['id'].toString()),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadRequests() async {
    try {
      final response = await Supabase.instance.client
          .from('requests')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  void _showRequestDetails(BuildContext context, Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(request['title'] ?? 'Solicitud', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Usuario: ${request['user_name'] ?? 'Desconocido'}', style: GoogleFonts.outfit(color: Colors.white70)),
              Text('Email: ${request['user_email'] ?? 'No disponible'}', style: GoogleFonts.outfit(color: Colors.white70)),
              const SizedBox(height: 16),
              Text('Descripción:', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(request['request_text'] ?? request['description'] ?? 'Sin descripción', style: GoogleFonts.outfit(color: Colors.white)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: GoogleFonts.outfit(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsResolved(BuildContext context, String requestId) async {
    try {
      await Supabase.instance.client
          .from('requests')
          .update({'status': 'resuelto'})
          .eq('id', requestId);
      
      // StreamBuilder se actualiza automáticamente, no necesita setState
      _refreshStream();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Solicitud marcada como resuelta', style: GoogleFonts.outfit()), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e', style: GoogleFonts.outfit()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteRequest(BuildContext context, String requestId) async {
    try {
      await Supabase.instance.client
          .from('requests')
          .delete()
          .eq('id', requestId);
      
      // StreamBuilder se actualiza automáticamente, no necesita setState
      _refreshStream();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🗑️ Solicitud eliminada', style: GoogleFonts.outfit()), backgroundColor: Colors.orange),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e', style: GoogleFonts.outfit()), backgroundColor: Colors.red),
      );
    }
  }
}

// Widget reutilizable eliminado - ahora está en common_widgets.dart