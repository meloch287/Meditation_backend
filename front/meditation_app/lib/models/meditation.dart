class Meditation {
  final int id;
  final String title;
  final String description;
  final int durationSeconds;
  final String audioUrl;
  final bool isPremium;
  final String category;

  Meditation({
    required this.id,
    required this.title,
    required this.description,
    required this.durationSeconds,
    required this.audioUrl,
    required this.isPremium,
    required this.category,
  });

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'durationSeconds': durationSeconds,
      'audioUrl': audioUrl,
      'isPremium': isPremium,
      'category': category,
    };
  }

  factory Meditation.fromJson(Map<String, dynamic> json) {
    return Meditation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      durationSeconds: json['duration_seconds'] ?? json['durationSeconds'],
      audioUrl: json['audio_url'] ?? json['audioUrl'],
      isPremium: json['is_premium'] ?? json['isPremium'],
      category: json['category'],
    );
  }
}