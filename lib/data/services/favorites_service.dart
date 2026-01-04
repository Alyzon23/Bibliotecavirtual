import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesService {
  final _supabase = Supabase.instance.client;

  Future<void> addToFavorites(String bookId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    await _supabase.from('favorites').insert({
      'user_id': userId,
      'book_id': bookId,
    });
  }

  Future<void> removeFromFavorites(String bookId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    await _supabase
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('book_id', bookId);
  }

  Future<List<String>> getUserFavorites() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('favorites')
        .select('book_id')
        .eq('user_id', userId);

    return List<String>.from(response.map((item) => item['book_id']));
  }

  Future<bool> isFavorite(String bookId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _supabase
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('book_id', bookId)
        .limit(1);

    return response.isNotEmpty;
  }
}