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
                        _buildMenuItem(Icons.video_library, 'Gestión Videos', 1),
                        _buildMenuItem(Icons.analytics, 'Estadísticas', 2),
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
class _LibrarianBooksTab extends StatelessWidget {
  const _LibrarianBooksTab();

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
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddBookScreen()),
                ),
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