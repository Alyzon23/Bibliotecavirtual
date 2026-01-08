import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:file_picker/file_picker.dart';
import '../../../data/services/supabase_auth_service.dart';
import '../../../data/services/cache_service.dart';
import '../../../core/services/lazy_loading_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../theme/glass_theme.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';
import '../../../main.dart';
import 'video_player_screen.dart';
import 'book_detail_screen.dart';
import 'youtube_video_player.dart';
import 'add_book_dialog.dart';
import 'add_video_dialog.dart';
import '../admin/add_book_screen.dart';
import '../admin/add_video_screen.dart';
import 'category_books_view.dart';
import 'category_videos_view.dart';
import 'users_management_screen.dart';

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
    final tabs = {
      0: () => _HomeTab(searchQuery: _searchQuery),
      1: () => _LibraryTab(canEdit: _canEdit, userRole: _userRole),
      2: () => _VideosTab(canEdit: _canEdit, userRole: _userRole),
      3: () => _FavoritesTab(canEdit: _canEdit),
      4: () => _ProfileTab(userRole: _userRole),
      5: () => const _TopBooksTab(),
      6: () => _AddContentTab(canEdit: _canEdit),
      7: () => const _UserManagementTab(),
      8: () => const _RequestsTab(),
    };
    
    if (_searchQuery.isNotEmpty) {
      return _SearchResultsTab(searchQuery: _searchQuery);
    }
    
    final tabBuilder = tabs[_selectedIndex] ?? tabs[0]!;
    return LazyLoadingService.lazyWidget(
      'tab_$_selectedIndex',
      () async => tabBuilder(),
      placeholder: LoadingPlaceholder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Row(
          children: [
            // Sidebar fijo
            FadeInLeft(
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
                    // Header del usuario
                    FadeInDown(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Logo del instituto
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
                            // Info del usuario
                            Row(
                              children: [
                                // Avatar con inicial
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.avatarGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      AppColors.avatarShadow,
                                    ],
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
                                // Nombre y rol
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
                    ),
                    // Menú principal
                    Expanded(
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
                          _buildMenuItem(Icons.settings, 'Configuración', -1, onTap: () {
                            // Cambiar a pestaña de perfil
                            setState(() => _selectedIndex = 4);
                          }),
                          ListTile(
                            leading: ValueListenableBuilder<bool>(
                              valueListenable: ThemeManager.isDarkMode,
                              builder: (context, isDark, child) {
                                return Icon(
                                  isDark ? Icons.light_mode : Icons.dark_mode,
                                  color: Colors.white70,
                                );
                              },
                            ),
                            title: ValueListenableBuilder<bool>(
                              valueListenable: ThemeManager.isDarkMode,
                              builder: (context, isDark, child) {
                                return Text(
                                  isDark ? 'Modo Claro' : 'Modo Oscuro',
                                  style: const TextStyle(color: Colors.white),
                                );
                              },
                            ),
                            onTap: () {
                              ThemeManager.toggleTheme();
                            },
                          ),
                        ],
                      ),
                    ),
                    // Cerrar sesión
                    FadeInUp(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: AppColors.logoutGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              AppColors.logoutShadow,
                            ],
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
                    ),
                  ],
                ),
              ),
            ),
                // Contenido principal
                Expanded(
                  child: Column(
                    children: [
                      // AppBar
                      GlassmorphicContainer(
                        width: double.infinity,
                        height: 70,
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
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              const Spacer(),
                              Text(
                                'Biblioteca Virtual Yavirac',
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const Spacer(),
                              ValueListenableBuilder<bool>(
                                valueListenable: _searchingNotifier,
                                builder: (context, isSearching, child) {
                                  return isSearching
                                      ? Container(
                                          height: 40,
                                          width: 250,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: GlassTheme.primaryColor, width: 1),
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
                                            onChanged: (value) {
                                              setState(() {
                                                _searchQuery = value;
                                              });
                                            },
                                            onSubmitted: (value) {
                                              _searchingNotifier.value = false;
                                              setState(() {
                                                _searchQuery = '';
                                              });
                                            },
                                            autofocus: true,
                                          ),
                                        )
                                      : const SizedBox(width: 250);
                                },
                              ),
                              Container(
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
                                          setState(() {
                                            _searchQuery = '';
                                          });
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _userName,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
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
                      ),
                      // Contenido
                      Expanded(
                        child: Container(
                          // Remove color to show validation background
                          child: _getSelectedPage(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          border: isSelected ? null : Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ?? (index >= 0 ? () {
              setState(() => _selectedIndex = index);
            } : null),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
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

class _HomeTab extends StatelessWidget {
  final String searchQuery;
  const _HomeTab({this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 32),
          _buildTopBooksSection(),
          const SizedBox(height: 32),
          _buildSection('Libros Recientes', DataService.getRecentBooks()),
          const SizedBox(height: 24),
          _buildSection('Videos Recientes', DataService.getRecentVideos()),
        ],
      ),
    );
  }
  
  Widget _buildWelcomeHeader() {
    return FadeInDown(
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            AppColors.primaryShadow,
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¡Bienvenido!',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Descubre miles de libros y videos educativos',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTopBooksSection() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 300,
      borderRadius: 20,
      blur: 15,
      alignment: Alignment.center,
      border: 0,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.05),
          Colors.white.withOpacity(0.02),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: GlassTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Top 10 Más Leídos',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: HorizontalBookList(
                future: DataService.getTopBooks(),
                searchQuery: searchQuery,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, Future<List<Map<String, dynamic>>> future) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        const SizedBox(height: 8),
        HorizontalBookList(
          future: future,
          searchQuery: searchQuery,
        ),
      ],
    );
  }
}

class _LibraryTab extends StatefulWidget {
  final String searchQuery;
  final bool canEdit;
  final String userRole;
  const _LibraryTab({this.searchQuery = '', required this.canEdit, required this.userRole});

  @override
  State<_LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<_LibraryTab> {
  String? selectedCategory;
  bool showCategoryAccordion = false;
  
  final categories = {
    'Desarrollo de Software': ['Frontend', 'Backend', 'Móvil', 'Base de Datos'],
    'Marketing': ['Digital', 'Tradicional', 'Redes Sociales', 'SEO'],
    'Guía Nacional de Turismo': ['Costas', 'Sierra', 'Oriente', 'Galápagos'],
    'Arte Culinaria': ['Cocina Nacional', 'Cocina Internacional', 'Repostería', 'Bebidas'],
    'Idiomas': ['Inglés', 'Francés', 'Alemán', 'Italiano']
  };
  
  Future<List<Map<String, dynamic>>> _loadTopBooks() async {
    final topBooks = await CacheService.getTopBooks();
    return topBooks.map((item) => item['books'] as Map<String, dynamic>).toList();
  }
  
  Future<List<Map<String, dynamic>>> _loadRecentBooks() async {
    return await CacheService.getRecentBooks();
  }
  
  Future<List<Map<String, dynamic>>> _loadSuggestions() async {
    // Usar datos en caché para sugerencias
    final recent = await CacheService.getRecentBooks();
    return recent.take(5).toList();
  }

  Widget _buildBookList(List<Map<String, dynamic>> books, BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailScreen(book: book),
                          ),
                        ),
                        child: GlassmorphicContainer(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: 12,
                          blur: 10,
                          alignment: Alignment.center,
                          border: 0,
                          linearGradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderGradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                Container(
                                  height: 120,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: book['cover_url'] != null
                                        ? Image.network(
                                            book['cover_url'],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.book, size: 40, color: Colors.white54)),
                                          )
                                        : const Center(child: Icon(Icons.book, size: 40, color: Colors.white54)),
                                  ),
                                ),
                                Container(
                                  height: 60,
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          book['title'] ?? 'Sin título',
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          book['author'] ?? 'Autor desconocido',
                                          style: GoogleFonts.outfit(
                                            fontSize: 8,
                                            color: Colors.white70,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (widget.canEdit && (widget.userRole == 'bibliotecario' || widget.userRole == 'admin'))
                        Positioned(
                          top: 4,
                          right: 4,
                          child: PopupMenuButton<String>(
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.more_vert, color: Colors.white, size: 16),
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editBook(context, book);
                              } else if (value == 'delete' && widget.userRole == 'admin') {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF1E293B),
                                    title: Text('Eliminar libro', style: GoogleFonts.outfit(color: Colors.white)),
                                    content: Text('¿Seguro que quieres eliminar este libro?', style: GoogleFonts.outfit(color: Colors.white70)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancelar', style: GoogleFonts.outfit(color: Colors.white70)),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          try {
                                            await Supabase.instance.client.from('books').delete().eq('id', book['id']);
                                            // Limpiar caché de libros
                                            CacheService.clearBooksCache();
                                            setState(() {});
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Libro eliminado correctamente', style: GoogleFonts.outfit()), backgroundColor: Colors.green),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error al eliminar: $e', style: GoogleFonts.outfit()), backgroundColor: Colors.red),
                                            );
                                          }
                                        },
                                        child: Text('Eliminar', style: GoogleFonts.outfit(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 16),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              if (widget.userRole == 'admin')
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 16, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (selectedCategory != null) {
      return CategoryBooksView(
        category: selectedCategory!,
        onBack: () => setState(() => selectedCategory = null),
        canEdit: widget.canEdit,
        userRole: widget.userRole,
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                showCategoryAccordion = !showCategoryAccordion;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.yaviracOrange.withOpacity(0.2),
                    AppColors.yaviracBlueDark.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.yaviracOrange.withOpacity(0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.yaviracOrange.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.avatarGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.category, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Explorar Categorías',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      showCategoryAccordion ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.yaviracOrange,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showCategoryAccordion)
            Container(
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.yaviracOrange.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: categories.keys.map((category) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                            showCategoryAccordion = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.yaviracOrange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.folder, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  category,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.yaviracOrange,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          
          const SizedBox(height: 32),
          
          // Top 10 Libros
          Text(
            'Top 10 Libros',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadTopBooks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.white)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox(height: 200, child: Center(child: Text('No hay libros populares', style: GoogleFonts.outfit(color: Colors.white70))));
              }
              return _buildBookList(snapshot.data!, context);
            },
          ),
          
          const SizedBox(height: 32),
          
          // Libros Recientes
          Text(
            'Libros Recientes',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadRecentBooks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.white)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox(height: 200, child: Center(child: Text('No hay libros recientes', style: GoogleFonts.outfit(color: Colors.white70))));
              }
              return _buildBookList(snapshot.data!, context);
            },
          ),
          
          const SizedBox(height: 32),
          
          // Libros Sugeridos
          Text(
            'Libros Sugeridos',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadSuggestions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.white)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox(height: 200, child: Center(child: Text('No hay libros sugeridos', style: GoogleFonts.outfit(color: Colors.white70))));
              }
              return _buildBookList(snapshot.data!, context);
            },
          ),
        ],
      ),
    );
  }

  void _editBook(BuildContext context, Map<String, dynamic> book) {
    final titleController = TextEditingController(text: book['title']);
    final authorController = TextEditingController(text: book['author']);
    final coverUrlController = TextEditingController(text: book['cover_url']);
    final isbnController = TextEditingController(text: book['isbn']);
    final yearController = TextEditingController(text: book['year']?.toString());
    final descriptionController = TextEditingController(text: book['description']);
    
    String selectedCategory = book['category'] ?? 'Desarrollo de Software';
    String selectedSubcategory = book['subcategory'] ?? '';
    
    final categories = {
      'Desarrollo de Software': ['Frontend', 'Backend', 'Móvil', 'Base de Datos'],
      'Marketing': ['Digital', 'Tradicional', 'Redes Sociales', 'SEO'],
      'Guía Nacional de Turismo': ['Costas', 'Sierra', 'Oriente', 'Galápagos'],
      'Arte Culinaria': ['Cocina Nacional', 'Cocina Internacional', 'Repostería', 'Bebidas'],
      'Idiomas': ['Inglés', 'Francés', 'Alemán', 'Italiano']
    };
    
    if (selectedSubcategory.isEmpty || !categories[selectedCategory]!.contains(selectedSubcategory)) {
      selectedSubcategory = categories[selectedCategory]!.first;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Editar: ${book['title']}'),
          content: SizedBox(
            width: 400,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: authorController,
                    decoration: const InputDecoration(labelText: 'Autor'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: categories.keys.map((category) {
                      return DropdownMenuItem(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                        selectedSubcategory = categories[value]!.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey(selectedCategory),
                    value: selectedSubcategory,
                    decoration: const InputDecoration(labelText: 'Subcategoría'),
                    items: categories[selectedCategory]!.map((subcategory) {
                      return DropdownMenuItem(value: subcategory, child: Text(subcategory));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSubcategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: coverUrlController,
                    decoration: const InputDecoration(labelText: 'URL de portada'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: isbnController,
                    decoration: const InputDecoration(labelText: 'ISBN'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: yearController,
                    decoration: const InputDecoration(labelText: 'Año de publicación'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await Supabase.instance.client
                      .from('books')
                      .update({
                        'title': titleController.text,
                        'author': authorController.text,
                        'category': selectedCategory,
                        'subcategory': selectedSubcategory,
                        'cover_url': coverUrlController.text,
                        'isbn': isbnController.text,
                        'year': int.tryParse(yearController.text),
                        'description': descriptionController.text,
                      })
                      .eq('id', book['id']);
                  
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Libro actualizado correctamente')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

}

class _VideosTab extends StatefulWidget {
  final String searchQuery;
  final bool canEdit;
  final String userRole;
  const _VideosTab({this.searchQuery = '', required this.canEdit, required this.userRole});

  @override
  State<_VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<_VideosTab> {
  String? selectedCategory;
  bool showCategoryAccordion = false;
  
  final categories = {
    'Desarrollo de Software': ['Frontend', 'Backend', 'Móvil', 'Base de Datos'],
    'Marketing': ['Digital', 'Tradicional', 'Redes Sociales', 'SEO'],
    'Guía Nacional de Turismo': ['Costas', 'Sierra', 'Oriente', 'Galápagos'],
    'Arte Culinaria': ['Cocina Nacional', 'Cocina Internacional', 'Repostería', 'Bebidas'],
    'Idiomas': ['Inglés', 'Francés', 'Alemán', 'Italiano']
  };

  Future<List<Map<String, dynamic>>> _loadTopVideos() async {
    return await CacheService.getRecentVideos(); // Usar caché de videos recientes
  }
  
  Future<List<Map<String, dynamic>>> _loadRecentVideos() async {
    return await CacheService.getRecentVideos();
  }
  
  Future<List<Map<String, dynamic>>> _loadRecommendedVideos() async {
    // Usar datos en caché para recomendaciones
    final recent = await CacheService.getRecentVideos();
    return recent.take(3).toList();
  }

  Widget _buildVideoList(List<Map<String, dynamic>> videos, BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => YouTubeVideoPlayer(video: video),
                          ),
                        ),
                        child: GlassmorphicContainer(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: 12,
                          blur: 10,
                          alignment: Alignment.center,
                          border: 0,
                          linearGradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderGradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 2,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: video['thumbnail_url'] != null
                                      ? Image.network(
                                          video['thumbnail_url'],
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: Colors.grey.shade800,
                                            child: const Icon(Icons.video_library, size: 40, color: Colors.white54),
                                          ),
                                        )
                                      : Container(
                                          color: Colors.grey.shade800,
                                          child: const Icon(Icons.video_library, size: 40, color: Colors.white54),
                                        ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          video['title'] ?? 'Sin título',
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          video['category'] ?? 'Sin categoría',
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            color: Colors.white70,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (video['views'] != null)
                                        Flexible(
                                          child: Text(
                                            '${video['views']} vistas',
                                            style: GoogleFonts.outfit(
                                              fontSize: 9,
                                              color: Colors.white54,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (widget.canEdit && (widget.userRole == 'bibliotecario' || widget.userRole == 'admin'))
                        Positioned(
                          top: 4,
                          right: 4,
                          child: PopupMenuButton<String>(
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.more_vert, color: Colors.white, size: 16),
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editVideo(context, video);
                              } else if (value == 'delete' && widget.userRole == 'admin') {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF1E293B),
                                    title: Text('Eliminar video', style: GoogleFonts.outfit(color: Colors.white)),
                                    content: Text('¿Seguro que quieres eliminar este video?', style: GoogleFonts.outfit(color: Colors.white70)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancelar', style: GoogleFonts.outfit(color: Colors.white70)),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          try {
                                            await Supabase.instance.client.from('videos').delete().eq('id', video['id']);
                                            // Limpiar caché de videos
                                            CacheService.clearVideosCache();
                                            if (mounted) {
                                              setState(() {});
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Video eliminado correctamente', style: GoogleFonts.outfit()), backgroundColor: Colors.green),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Error al eliminar: $e', style: GoogleFonts.outfit()), backgroundColor: Colors.red),
                                              );
                                            }
                                          }
                                        },
                                        child: Text('Eliminar', style: GoogleFonts.outfit(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 16),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              if (widget.userRole == 'admin')
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 16, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  void _editVideo(BuildContext context, Map<String, dynamic> video) {
    final titleController = TextEditingController(text: video['title'] ?? '');
    final thumbnailController = TextEditingController(text: video['thumbnail_url'] ?? '');
    final descriptionController = TextEditingController(text: video['description'] ?? '');
    
    String selectedCategory = video['category'] ?? 'Desarrollo de Software';
    String selectedSubcategory = video['subcategory'] ?? 'Frontend';
    
    final categories = {
      'Desarrollo de Software': ['Frontend', 'Backend', 'Móvil', 'Base de Datos'],
      'Marketing': ['Digital', 'Tradicional', 'Redes Sociales', 'SEO'],
      'Guía Nacional de Turismo': ['Costas', 'Sierra', 'Oriente', 'Galápagos'],
      'Arte Culinaria': ['Cocina Nacional', 'Cocina Internacional', 'Repostería', 'Bebidas'],
      'Idiomas': ['Inglés', 'Francés', 'Alemán', 'Italiano']
    };
    
    if (!categories.containsKey(selectedCategory)) {
      selectedCategory = 'Desarrollo de Software';
    }
    if (!categories[selectedCategory]!.contains(selectedSubcategory)) {
      selectedSubcategory = categories[selectedCategory]!.first;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Editar: ${video['title']}'),
          content: SizedBox(
            width: 500,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Título'),
                    controller: titleController,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(labelText: 'URL de miniatura'),
                    controller: thumbnailController,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: categories.keys.map((category) {
                      return DropdownMenuItem(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                        selectedSubcategory = categories[value]!.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey(selectedCategory),
                    value: selectedSubcategory,
                    decoration: const InputDecoration(labelText: 'Subcategoría'),
                    items: categories[selectedCategory]!.map((subcategory) {
                      return DropdownMenuItem(value: subcategory, child: Text(subcategory));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSubcategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    controller: descriptionController,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await Supabase.instance.client
                      .from('videos')
                      .update({
                        'title': titleController.text,
                        'thumbnail_url': thumbnailController.text,
                        'category': selectedCategory,
                        'subcategory': selectedSubcategory,
                        'description': descriptionController.text,
                      })
                      .eq('id', video['id']);
                  
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video actualizado correctamente')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (selectedCategory != null) {
      return CategoryVideosView(
        category: selectedCategory!,
        onBack: () => setState(() => selectedCategory = null),
        canEdit: widget.canEdit,
        userRole: widget.userRole,
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                showCategoryAccordion = !showCategoryAccordion;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.yaviracOrange.withOpacity(0.2),
                    AppColors.yaviracBlueDark.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.yaviracOrange.withOpacity(0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.yaviracOrange.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.avatarGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.category, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Explorar Categorías',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      showCategoryAccordion ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.yaviracOrange,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showCategoryAccordion)
            Container(
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.yaviracOrange.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: categories.keys.map((category) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                            showCategoryAccordion = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.yaviracOrange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.folder, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  category,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.yaviracOrange,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          
          const SizedBox(height: 32),
          
          // Top 10 Videos
          Text(
            'Top 10 Videos',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadTopVideos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.white)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox(height: 200, child: Center(child: Text('No hay videos populares', style: GoogleFonts.outfit(color: Colors.white70))));
              }
              return _buildVideoList(snapshot.data!, context);
            },
          ),
          
          const SizedBox(height: 32),
          
          // Videos Recientes
          Text(
            'Videos Recientes',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadRecentVideos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.white)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox(height: 200, child: Center(child: Text('No hay videos recientes', style: GoogleFonts.outfit(color: Colors.white70))));
              }
              return _buildVideoList(snapshot.data!, context);
            },
          ),
          
          const SizedBox(height: 32),
          
          // Videos Recomendados
          Text(
            'Videos Recomendados',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadRecommendedVideos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.white)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox(height: 200, child: Center(child: Text('No hay videos recomendados', style: GoogleFonts.outfit(color: Colors.white70))));
              }
              return _buildVideoList(snapshot.data!, context);
            },
          ),
        ],
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
                    borderSide: BorderSide(color: GlassTheme.primaryColor),
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
                    borderSide: BorderSide(color: GlassTheme.primaryColor),
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
                    borderSide: BorderSide(color: GlassTheme.primaryColor),
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
            style: ElevatedButton.styleFrom(backgroundColor: GlassTheme.primaryColor),
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
                            GlassTheme.primaryColor.withOpacity(0.3),
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
                                            color: GlassTheme.primaryColor.withOpacity(0.2),
                                            child: const Icon(Icons.search, size: 30, color: Colors.white),
                                          ),
                                        )
                                      : Container(
                                          color: GlassTheme.primaryColor.withOpacity(0.2),
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
    return await CacheService.getTopBooks();
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
                            backgroundColor: GlassTheme.primaryColor,
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