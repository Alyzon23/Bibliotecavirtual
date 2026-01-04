import 'package:supabase_flutter/supabase_flutter.dart';

class StatsService {
  final _supabase = Supabase.instance.client;

  Future<void> recordBookOpen(String bookId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Registrar en historial
    await _supabase.from('book_opens_history').insert({
      'book_id': bookId,
      'user_id': userId,
    });

    // Actualizar contador
    await _supabase.rpc('increment_book_opens', params: {'book_id': bookId});
  }

  Future<void> updateReadingProgress(String bookId, int progress) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('reading_history').upsert({
      'user_id': userId,
      'book_id': bookId,
      'progress': progress,
      'last_read': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getRecentBooks() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('reading_history')
        .select('book_id, books(*)')
        .eq('user_id', userId)
        .order('last_read', ascending: false)
        .limit(10);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getTopBooks() async {
    final response = await _supabase
        .from('book_stats')
        .select('book_id, open_count, books(*)')
        .order('open_count', ascending: false)
        .limit(10);

    return List<Map<String, dynamic>>.from(response);
  }
}