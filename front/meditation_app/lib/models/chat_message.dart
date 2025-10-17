class ChatMessage {
  final String id;
  final String userId;
  final String content;
  final bool isUser;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.content,
    required this.isUser,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'isUser': isUser,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      userId: json['user_id'] ?? json['userId'],
      content: json['content'],
      isUser: json['is_user'] ?? json['isUser'],
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
    );
  }

  ChatMessage copyWith({
    String? id,
    String? userId,
    String? content,
    bool? isUser,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}