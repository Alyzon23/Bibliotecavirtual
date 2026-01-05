import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/glass_theme.dart';
import '../../../data/services/debug_service.dart';
import 'simple_book_reader.dart';
import 'flipbook_reader.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _isFavorite = false;
  bool _isLoading = false;
  String _createdByInfo = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _incrementViewCount();
    _loadCreatedByInfo();
  }

  Future<void> _loadCreatedByInfo() async {
    if (widget.book['created_by'] != null) {
      try {
        final userData = await Supabase.instance.client
            .from('users')
            .select('name, role')
            .eq('id', widget.book['created_by'])
            .single();
        
        setState(() {
          final name = userData['name'] ?? 'Usuario';
          final role = userData['role'] ?? 'usuario';
          _createdByInfo = '$name ($role)';
        });
      } catch (e) {
        setState(() {
          _createdByInfo = 'Sistema';
        });
      }
    } else {
      setState(() {
        _createdByInfo = 'Sistema';
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('favorites')
            .select()
            .eq('user_id', user.id)
            .eq('book_id', widget.book['id'])
            .maybeSingle();
        
        setState(() {
          _isFavorite = response != null;
        });
      } catch (e) {
        print('Error checking favorite: $e');
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('❌ Usuario no autenticado');
      return;
    }

    // Debug info antes de cambiar favorito
    print('🔄 === ANTES DE CAMBIAR FAVORITO ===');
    await DebugService.debugUserInfo();
    print('🔄 Toggling favorite for book: ${widget.book['id']}, user: ${user.id}');
    setState(() => _isLoading = true);

    try {
      if (_isFavorite) {
        print('🗑️ Eliminando de favoritos...');
        await Supabase.instance.client
            .from('favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('book_id', widget.book['id']);
        print('✅ Eliminado de favoritos');
      } else {
        print('❤️ Agregando a favoritos...');
        final result = await Supabase.instance.client
            .from('favorites')
            .insert({
          'user_id': user.id,
          'book_id': widget.book['id'],
        });
        print('✅ Agregado a favoritos: $result');
      }
      
      setState(() {
        _isFavorite = !_isFavorite;
      });
      
      // Debug info después de cambiar favorito
      print('🔄 === DESPUÉS DE CAMBIAR FAVORITO ===');
      await DebugService.debugUserInfo();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Agregado a favoritos' : 'Eliminado de favoritos'),
          backgroundColor: _isFavorite ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      print('❌ Error en favoritos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _incrementViewCount() async {
    try {
      // Primero verificar si existe el registro
      final existing = await Supabase.instance.client
          .from('book_stats')
          .select('open_count')
          .eq('book_id', widget.book['id'])
          .maybeSingle();
      
      if (existing != null) {
        // Si existe, incrementar
        await Supabase.instance.client
            .from('book_stats')
            .update({
          'open_count': existing['open_count'] + 1,
          'updated_at': DateTime.now().toIso8601String(),
        })
            .eq('book_id', widget.book['id']);
      } else {
        // Si no existe, crear nuevo
        await Supabase.instance.client
            .from('book_stats')
            .insert({
          'book_id': widget.book['id'],
          'open_count': 1,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  Future<void> _readBook() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlipBookReader(book: widget.book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: GlassTheme.decorationBackground,
        child: SafeArea(
          child: Column(
            children: [
              // Header con botón de regreso
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GlassmorphicContainer(
                      width: 50,
                      height: 50,
                      borderRadius: 25,
                      blur: 15,
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
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Detalles del Libro',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    GlassmorphicContainer(
                      width: 50,
                      height: 50,
                      borderRadius: 25,
                      blur: 15,
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
                      child: IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: _isLoading ? null : _toggleFavorite,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Contenido principal
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Portada y información principal
                      GlassmorphicContainer(
                        width: double.infinity,
                        height: 400,
                        borderRadius: 20,
                        blur: 20,
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
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              // Portada del libro
                              Container(
                                width: 180,
                                height: 280,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: widget.book['cover_url'] != null
                                      ? Image.network(
                                          widget.book['cover_url'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: GlassTheme.primaryColor.withOpacity(0.3),
                                            child: const Icon(Icons.book, size: 80, color: Colors.white54),
                                          ),
                                        )
                                      : Container(
                                          color: GlassTheme.primaryColor.withOpacity(0.3),
                                          child: const Icon(Icons.book, size: 80, color: Colors.white54),
                                        ),
                                ),
                              ),
                              
                              const SizedBox(width: 24),
                              
                              // Información del libro
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.book['title'] ?? 'Sin título',
                                      style: GoogleFonts.outfit(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    Text(
                                      'por ${widget.book['author'] ?? 'Autor desconocido'}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: GlassTheme.primaryColor,
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // Información adicional
                                    _buildInfoRow(Icons.calendar_today, 'Año', widget.book['year']?.toString() ?? 'N/A'),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(Icons.qr_code, 'ISBN', widget.book['isbn'] ?? 'N/A'),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(Icons.person, 'Subido por', _createdByInfo),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(Icons.category, 'Categoría', widget.book['category'] ?? 'General'),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(Icons.description, 'Formato', widget.book['format']?.toUpperCase() ?? 'PDF'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Descripción
                      if (widget.book['description'] != null && widget.book['description'].toString().isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.05),
                                Colors.white.withOpacity(0.02),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.description, color: GlassTheme.primaryColor, size: 24),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Descripción',
                                      style: GoogleFonts.outfit(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  widget.book['description'],
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    color: Colors.white70,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      
                      const SizedBox(height: 32),
                      
                      // Botón de leer libro
                      GlassmorphicContainer(
                        width: double.infinity,
                        height: 70,
                        borderRadius: 20,
                        blur: 15,
                        alignment: Alignment.center,
                        border: 0,
                        linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            GlassTheme.primaryColor.withOpacity(0.8),
                            GlassTheme.secondaryColor.withOpacity(0.6),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _readBook,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.menu_book, color: Colors.white, size: 28),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Leer Libro',
                                    style: GoogleFonts.outfit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}