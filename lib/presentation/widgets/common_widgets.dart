import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../data/services/cache_service.dart';
import '../screens/user/book_detail_screen.dart';

// Widgets const reutilizables
class AppWidgets {
  static const loadingIndicator = Center(
    child: CircularProgressIndicator(color: Colors.white),
  );
  
  static const noDataText = Center(
    child: Text(
      'Cargando contenido...',
      style: TextStyle(color: Colors.white70),
    ),
  );
}

// Widget optimizado para tarjetas de libros
class BookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final double width;
  final double height;
  
  const BookCard({
    super.key,
    required this.book,
    this.width = 140,
    this.height = 200,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookDetailScreen(book: book),
        ),
      ),
      child: GlassmorphicContainer(
        width: width,
        height: height,
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
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: book['cover_url'] != null
                    ? Image.network(
                        book['cover_url'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.book, size: 40, color: Colors.white54),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.book, size: 40, color: Colors.white54),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
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
                    const SizedBox(height: 2),
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
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para listas horizontales de libros
class HorizontalBookList extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> future;
  final String searchQuery;
  
  const HorizontalBookList({
    super.key,
    required this.future,
    this.searchQuery = '',
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AppWidgets.loadingIndicator;
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return AppWidgets.noDataText;
          }
          
          final books = _filterBooks(snapshot.data!);
          
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: BookCard(book: books[index]),
              );
            },
          );
        },
      ),
    );
  }
  
  List<Map<String, dynamic>> _filterBooks(List<Map<String, dynamic>> books) {
    if (searchQuery.isEmpty) return books;
    
    return books.where((book) {
      final title = (book['title'] ?? '').toString().toLowerCase();
      final author = (book['author'] ?? '').toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      return title.contains(query) || author.contains(query);
    }).toList();
  }
}

// Widget para placeholder de carga
class LoadingPlaceholder extends StatelessWidget {
  final String message;
  
  const LoadingPlaceholder({
    super.key,
    this.message = 'Cargando contenido...',
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// Servicio para datos optimizado
class DataService {
  static Future<List<Map<String, dynamic>>> getTopBooks() async {
    try {
      final cached = await CacheService.getTopBooks();
      return cached.map((item) => item['books'] as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }
  
  static Future<List<Map<String, dynamic>>> getRecentBooks() async {
    try {
      return await CacheService.getRecentBooks();
    } catch (e) {
      return [];
    }
  }
  
  static Future<List<Map<String, dynamic>>> getRecentVideos() async {
    try {
      return await CacheService.getRecentVideos();
    } catch (e) {
      return [];
    }
  }
}