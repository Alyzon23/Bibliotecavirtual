import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseSeeder {
  static Future<void> seedBooks() async {
    try {
      final response = await Supabase.instance.client
          .from('books')
          .select('id')
          .limit(1);
      
      if (response.isEmpty) {
        await Supabase.instance.client.from('books').insert([
          {
            'title': 'El Quijote',
            'author': 'Miguel de Cervantes',
            'format': 'pdf',
            'description': 'La obra maestra de la literatura española',
            'created_at': DateTime.now().toIso8601String(),
          }
        ]);
      }
    } catch (e) {
      print('Error seeding books: $e');
    }
  }

  static Future<void> seedVideos() async {
    // Implementar si necesitas videos
  }
}