class User {
  final String id;
  final String name;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final int? lastPlayedMeditationId;

  User({
    required this.id,
    required this.name,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.lastPlayedMeditationId,
  });

  bool get hasActivePremium {
    return isPremium &&
           premiumExpiresAt != null &&
           premiumExpiresAt!.isAfter(DateTime.now());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isPremium': isPremium,
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
      'lastPlayedMeditationId': lastPlayedMeditationId,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      isPremium: json['isPremium'] ?? false,
      premiumExpiresAt: json['premiumExpiresAt'] != null
          ? DateTime.parse(json['premiumExpiresAt'])
          : null,
      lastPlayedMeditationId: json['lastPlayedMeditationId'],
    );
  }

  User copyWith({
    String? id,
    String? name,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    int? lastPlayedMeditationId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      lastPlayedMeditationId: lastPlayedMeditationId ?? this.lastPlayedMeditationId,
    );
  }
}