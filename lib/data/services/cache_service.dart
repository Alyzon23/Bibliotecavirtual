import 'package:supabase_flutter/supabase_flutter.dart';

class CacheService {
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  static Future<List<Map<String, dynamic>>> getTopBooks() async {
    const key = 'top_books';
    if (_isValidCache(key)) {
      return List<Map<String, dynamic>>.from(_cache[key]);
    }

    try {
      final response = await Supabase.instance.client
          .from('book_stats')
          .select('book_id, open_count, books(*)')
          .order('open_count', ascending: false)
          .limit(10);
      
      _cache[key] = response;
      _cacheTimestamps[key] = DateTime.now();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getRecentBooks() async {
    const key = 'recent_books';
    if (_isValidCache(key)) {
      return List<Map<String, dynamic>>.from(_cache[key]);
    }

    try {
      final response = await Supabase.instance.client
          .from('books')
          .select()
          .order('created_at', ascending: false)
          .limit(5); // Reducido de 10 a 5
      
      _cache[key] = response;
      _cacheTimestamps[key] = DateTime.now();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getRecentVideos() async {
    const key = 'recent_videos';
    if (_isValidCache(key)) {
      return List<Map<String, dynamic>>.from(_cache[key]);
    }

    try {
      final response = await Supabase.instance.client
          .from('videos')
          .select()
          .order('created_at', ascending: false)
          .limit(5); // Reducido de 10 a 5
      
      _cache[key] = response;
      _cacheTimestamps[key] = DateTime.now();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  static bool _isValidCache(String key) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }
    
    final timestamp = _cacheTimestamps[key]!;
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}