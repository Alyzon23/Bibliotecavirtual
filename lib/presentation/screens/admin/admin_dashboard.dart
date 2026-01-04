import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/services/supabase_auth_service.dart';
import '../../theme/glass_theme.dart';
import '../auth/login_screen.dart';
import 'add_book_screen.dart';

class AdminDashboard extends StatefulWidget {
  final SupabaseAuthService authService;
  
  const AdminDashboard({super.key, required this.authService});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Panel de Administración', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: GlassTheme.glassDecoration.gradient,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: GlassTheme.decorationBackground,
        child: IndexedStack(
          index: _selectedIndex,
          children: const [
            _DashboardTab(),
            _BooksTab(),
            _VideosTab(),
            _UsersTab(),
          ],
        ),
      ),
      bottomNavigationBar: GlassmorphicContainer(
        width: double.infinity,
        height: 70,
        borderRadius: 0,
        blur: 20,
        alignment: Alignment.center,
        border: 0,
        linearGradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.3),
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
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: GlassTheme.primaryColor,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books),
              label: 'Libros',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library),
              label: 'Videos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Usuarios',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estadísticas', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: _StatCard(title: 'Total Libros', value: '1,234', icon: Icons.book)),
              SizedBox(width: 16),
              Expanded(child: _StatCard(title: 'Usuarios Activos', value: '567', icon: Icons.people)),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: _StatCard(title: 'Lecturas Hoy', value: '89', icon: Icons.visibility)),
              SizedBox(width: 16),
              Expanded(child: _StatCard(title: 'Nuevos Registros', value: '12', icon: Icons.person_add)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 120,
      borderRadius: 16,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: GlassTheme.secondaryColor),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(title, style: GoogleFonts.outfit(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _BooksTab extends StatefulWidget {
  const _BooksTab();

  @override
  State<_BooksTab> createState() => _BooksTabState();
}

class _BooksTabState extends State<_BooksTab> {
  
  Future<List<Map<String, dynamic>>> _loadBooks() async {
    try {
      final response = await Supabase.instance.client
          .from('books')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
  
  Future<void> _deleteBook(String bookId) async {
    try {
      await Supabase.instance.client
          .from('books')
          .delete()
          .eq('id', bookId);
      setState(() {}); // Refresh
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Libro eliminado', style: GoogleFonts.outfit())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e', style: GoogleFonts.outfit())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gestión de Libros', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlassTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
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
                label: Text('Agregar Libro', style: GoogleFonts.outfit()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay libros agregados', style: GoogleFonts.outfit(color: Colors.white70)));
                }
                
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final book = snapshot.data![index];
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
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: book['cover_url'] != null
                                ? Image.network(
                                    book['cover_url'],
                                    width: 40,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.book, color: Colors.white54),
                                  )
                                : const Icon(Icons.book, color: Colors.white54),
                          ),
                          title: Text(book['title'], style: GoogleFonts.outfit(color: Colors.white)),
                          subtitle: Text('${book['author']} • ${book['format'].toUpperCase()}', style: GoogleFonts.outfit(color: Colors.white70)),
                          trailing: PopupMenuButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white70),
                            color: const Color(0xFF1E293B),
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'edit', child: Text('Editar', style: GoogleFonts.outfit(color: Colors.white))),
                              PopupMenuItem(value: 'delete', child: Text('Eliminar', style: GoogleFonts.outfit(color: Colors.white))),
                            ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deleteBook(book['id']);
                              }
                            },
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
}

class _VideosTab extends StatefulWidget {
  const _VideosTab();

  @override
  State<_VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<_VideosTab> {
  
  Future<List<Map<String, dynamic>>> _loadVideos() async {
    try {
      final response = await Supabase.instance.client
          .from('videos')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
  
  Future<void> _deleteVideo(String videoId) async {
    try {
      await Supabase.instance.client
          .from('videos')
          .delete()
          .eq('id', videoId);
      setState(() {}); // Refresh
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video eliminado', style: GoogleFonts.outfit())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e', style: GoogleFonts.outfit())),
        );
      }
    }
  }

  void _showAddVideoDialog() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    final categoryController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Agregar Video', style: GoogleFonts.outfit(color: Colors.white)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Título del video',
                  labelStyle: GoogleFonts.outfit(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E3A8A)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'URL del video (YouTube)',
                  labelStyle: GoogleFonts.outfit(color: Colors.white70),
                  hintText: 'https://www.youtube.com/watch?v=...',
                  hintStyle: GoogleFonts.outfit(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E3A8A)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  labelStyle: GoogleFonts.outfit(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E3A8A)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: GoogleFonts.outfit(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E3A8A)),
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
              onPressed: () => _addVideo(
                titleController.text,
                urlController.text,
                categoryController.text,
                descriptionController.text,
              ),
              child: Text('Agregar', style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addVideo(String title, String url, String category, String description) async {
    if (title.isEmpty || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Título y URL son obligatorios')),
      );
      return;
    }

    try {
      // Extraer video ID de YouTube
      String? videoId = _extractYouTubeId(url);
      if (videoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL de YouTube inválida')),
        );
        return;
      }

      await Supabase.instance.client.from('videos').insert({
        'title': title,
        'video_url': url,
        'video_id': videoId,
        'category': category.isEmpty ? 'General' : category,
        'description': description,
        'thumbnail_url': 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
        'views': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      Navigator.pop(context);
      setState(() {}); // Refresh
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Video agregado correctamente'),
          backgroundColor: Color(0xFF1E3A8A),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String? _extractYouTubeId(String url) {
    RegExp regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );
    Match? match = regExp.firstMatch(url);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gestión de Videos', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _showAddVideoDialog,
                icon: const Icon(Icons.add),
                label: Text('Agregar Video', style: GoogleFonts.outfit()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadVideos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay videos agregados', style: GoogleFonts.outfit(color: Colors.white70)));
                }
                
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final video = snapshot.data![index];
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
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: video['thumbnail_url'] != null
                                ? Image.network(
                                    video['thumbnail_url'],
                                    width: 60,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.video_library, color: Colors.white54),
                                  )
                                : const Icon(Icons.video_library, color: Colors.white54),
                          ),
                          title: Text(video['title'], style: GoogleFonts.outfit(color: Colors.white)),
                          subtitle: Text('${video['category']} • ${video['views']} vistas', style: GoogleFonts.outfit(color: Colors.white70)),
                          trailing: PopupMenuButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white70),
                            color: const Color(0xFF1E293B),
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'edit', child: Text('Editar', style: GoogleFonts.outfit(color: Colors.white))),
                              PopupMenuItem(value: 'delete', child: Text('Eliminar', style: GoogleFonts.outfit(color: Colors.white))),
                            ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deleteVideo(video['id']);
                              }
                            },
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
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gestión de Usuarios', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 15,
              itemBuilder: (context, index) => Padding(
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
                      backgroundColor: GlassTheme.secondaryColor,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text('Usuario ${index + 1}', style: GoogleFonts.outfit(color: Colors.white)),
                    subtitle: Text('usuario${index + 1}@email.com', style: GoogleFonts.outfit(color: Colors.white70)),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white70),
                      color: const Color(0xFF1E293B),
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'view', child: Text('Ver Perfil', style: GoogleFonts.outfit(color: Colors.white))),
                        PopupMenuItem(value: 'suspend', child: Text('Suspender', style: GoogleFonts.outfit(color: Colors.white))),
                        PopupMenuItem(value: 'delete', child: Text('Eliminar', style: GoogleFonts.outfit(color: Colors.white))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}