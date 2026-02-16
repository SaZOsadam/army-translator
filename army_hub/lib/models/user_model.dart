class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String bias;
  final String language;
  final bool isPremium;
  final DateTime createdAt;
  final List<String> predictions;
  final List<String> badges;
  final int theoriesGenerated;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.bias,
    required this.language,
    this.isPremium = false,
    required this.createdAt,
    this.predictions = const [],
    this.badges = const [],
    this.theoriesGenerated = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      uid: data['id'] ?? '',
      email: data['email'] ?? '',
      displayName: data['username'] ?? '',
      photoUrl: data['avatar_url'],
      bias: data['bias'] ?? 'OT7',
      language: data['language'] ?? 'en',
      isPremium: data['is_premium'] ?? false,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      predictions: List<String>.from(data['predictions'] ?? []),
      badges: List<String>.from(data['badges'] ?? []),
      theoriesGenerated: data['theories_generated'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': displayName,
      'avatar_url': photoUrl,
      'bias': bias,
      'language': language,
      'is_premium': isPremium,
      'created_at': createdAt.toIso8601String(),
      'predictions': predictions,
      'badges': badges,
      'theories_generated': theoriesGenerated,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? bias,
    String? language,
    bool? isPremium,
    DateTime? createdAt,
    List<String>? predictions,
    List<String>? badges,
    int? theoriesGenerated,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bias: bias ?? this.bias,
      language: language ?? this.language,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      predictions: predictions ?? this.predictions,
      badges: badges ?? this.badges,
      theoriesGenerated: theoriesGenerated ?? this.theoriesGenerated,
    );
  }
}
