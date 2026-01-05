import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/services/supabase_auth_service.dart';
import '../../theme/glass_theme.dart';
import '../auth/login_screen.dart';
import 'add_book_screen.dart';

class LibrarianDashboard extends StatefulWidget {
  final SupabaseAuthService authService;
  
  const LibrarianDashboard({super.key, required this.authService});

  @override
  State<LibrarianDashboard> createState() => _LibrarianDashboardState();
}

class _LibrarianDashboardState extends State<LibrarianDashboard> {
  int _selectedIndex = 0;

  void _logout() {
    widget.authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
            ],
          ),
        ),
        child: Row(
          children: [
            // Sidebar
            Container(
              width: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E3A8A).withOpacity(0.9),
                    const Color(0xFF1D4ED8).withOpacity(0.95),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.library_books, size: 60, color: Colors.white),
                        const SizedBox(height: 16),
                        Text(
                          'Panel Bibliotecario',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildMenuItem(Icons.library_books, 'Gestión Libros', 0),
                        _buildMenuItem(Icons.add_box, 'Agregar Contenido', 1),
                        _buildMenuItem(Icons.video_library, 'Gestión Videos', 2),
                        _buildMenuItem(Icons.analytics, 'Estadísticas', 3),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar Sesión'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Contenido
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: const [
                  _LibrarianBooksTab(),
                  _LibrarianAddContentTab(),
                  _LibrarianVideosTab(),
                  _LibrarianStatsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: isSelected ? const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
        ) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: GoogleFonts.poppins(color: Colors.white)),
        onTap: () => setState(() => _selectedIndex = index),
      ),
    );
  }
}

// Tabs específicas para bibliotecario
class _LibrarianBooksTab extends StatefulWidget {
  const _LibrarianBooksTab();

  @override
  State<_LibrarianBooksTab> createState() => _LibrarianBooksTabState();
}

class _LibrarianBooksTabState extends State<_LibrarianBooksTab> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gestión de Libros', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddBookScreen()),
                  );
                  if (result == true) {
                    // Refresh books list
                    if (mounted) setState(() {});
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar Libro'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Expanded(
            child: Center(
              child: Text('Funcionalidad de gestión de libros', style: TextStyle(color: Colors.white70)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibrarianVideosTab extends StatelessWidget {
  const _LibrarianVideosTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gestión de Videos', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ElevatedButton.icon(
                onPressed: () {}, // Implementar agregar video
                icon: const Icon(Icons.add),
                label: const Text('Agregar Video'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Expanded(
            child: Center(
              child: Text('Funcionalidad de gestión de videos', style: TextStyle(color: Colors.white70)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibrarianAddContentTab extends StatelessWidget {
  const _LibrarianAddContentTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Agregar Contenido', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 40),
          Expanded(
            child: Row(
              children: [
                // Card Agregar Libros
                Expanded(
                  child: Container(
                    height: 300,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddBookScreen()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.library_books, size: 60, color: Colors.white),
                              const SizedBox(height: 20),
                              Text(
                                'Agregar Libros',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Sube archivos PDF o EPUB\ny agrega información\ndel libro',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Card Agregar Videos
                Expanded(
                  child: Container(
                    height: 300,
                    margin: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Función en desarrollo')),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.video_library, size: 60, color: Colors.white),
                              const SizedBox(height: 20),
                              Text(
                                'Agregar Videos',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Agrega videos educativos\ny contenido multimedia\na la biblioteca',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white70,
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
        ],
      ),
    );
  }
}

class _LibrarianStatsTab extends StatelessWidget {
  const _LibrarianStatsTab();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Text('Estadísticas de biblioteca', style: TextStyle(color: Colors.white70, fontSize: 18)),
      ),
    );
  }
}