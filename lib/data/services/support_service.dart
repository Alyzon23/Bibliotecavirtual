import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/support_request_model.dart';

class SupportService {
  final SupabaseClient _client = Supabase.instance.client;

  // Crear nueva solicitud
  Future<bool> createRequest({
    required String title,
    required String description,
    required RequestType type,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client.from('support_requests').insert({
        'user_id': user.id,
        'title': title,
        'description': description,
        'type': type.toString().split('.').last,
        'status': 'pendiente',
      });

      return true;
    } catch (e) {
      print('Error creating support request: $e');
      return false;
    }
  }

  // Obtener solicitudes del usuario actual
  Future<List<SupportRequest>> getUserRequests() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final response = await _client
          .from('support_requests')
          .select('*, users(name, email)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response.map<SupportRequest>((json) {
        // Agregar datos del usuario al JSON
        json['user_name'] = json['users']?['name'];
        json['user_email'] = json['users']?['email'];
        return SupportRequest.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error fetching user requests: $e');
      return [];
    }
  }

  // Obtener todas las solicitudes (solo para admins)
  Future<List<SupportRequest>> getAllRequests() async {
    try {
      final response = await _client
          .from('support_requests')
          .select('*, users(name, email)')
          .order('created_at', ascending: false);

      return response.map<SupportRequest>((json) {
        // Agregar datos del usuario al JSON
        json['user_name'] = json['users']?['name'];
        json['user_email'] = json['users']?['email'];
        return SupportRequest.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error fetching all requests: $e');
      return [];
    }
  }

  // Marcar solicitud como resuelta (solo para admins)
  Future<bool> markAsResolved(String requestId) async {
    try {
      await _client.from('support_requests').update({
        'status': 'resuelto',
        'resolved_at': DateTime.now().toIso8601String(),
      }).eq('id', requestId);

      return true;
    } catch (e) {
      print('Error marking request as resolved: $e');
      return false;
    }
  }

  // Eliminar solicitud (solo para admins)
  Future<bool> deleteRequest(String requestId) async {
    try {
      await _client.from('support_requests').delete().eq('id', requestId);
      return true;
    } catch (e) {
      print('Error deleting request: $e');
      return false;
    }
  }
}