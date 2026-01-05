enum RequestStatus { pendiente, resuelto }
enum RequestType { ayuda, configuracion, reporte, otro }

class SupportRequest {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String title;
  final String description;
  final RequestType type;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  SupportRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
  });

  factory SupportRequest.fromJson(Map<String, dynamic> json) {
    return SupportRequest(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? 'Usuario',
      userEmail: json['user_email'] ?? '',
      title: json['title'],
      description: json['description'],
      type: RequestType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => RequestType.otro,
      ),
      status: RequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => RequestStatus.pendiente,
      ),
      createdAt: DateTime.parse(json['created_at']),
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }
}