class TheoryModel {
  final String id;
  final String userId;
  final String userDisplayName;
  final String input;
  final String output;
  final String bias;
  final DateTime createdAt;
  final int likes;
  final int shares;
  final List<String> tags;
  final bool isPublic;

  TheoryModel({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    required this.input,
    required this.output,
    required this.bias,
    required this.createdAt,
    this.likes = 0,
    this.shares = 0,
    this.tags = const [],
    this.isPublic = true,
  });

  factory TheoryModel.fromJson(Map<String, dynamic> data) {
    return TheoryModel(
      id: data['id'] ?? '',
      userId: data['user_id'] ?? '',
      userDisplayName: data['user_display_name'] ?? 'ARMY',
      input: data['input'] ?? '',
      output: data['output'] ?? '',
      bias: data['bias'] ?? 'OT7',
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      likes: data['likes'] ?? 0,
      shares: data['shares'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      isPublic: data['is_public'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_display_name': userDisplayName,
      'input': input,
      'output': output,
      'bias': bias,
      'created_at': createdAt.toIso8601String(),
      'likes': likes,
      'shares': shares,
      'tags': tags,
      'is_public': isPublic,
    };
  }

  TheoryModel copyWith({
    String? id,
    String? userId,
    String? userDisplayName,
    String? input,
    String? output,
    String? bias,
    DateTime? createdAt,
    int? likes,
    int? shares,
    List<String>? tags,
    bool? isPublic,
  }) {
    return TheoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      input: input ?? this.input,
      output: output ?? this.output,
      bias: bias ?? this.bias,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      shares: shares ?? this.shares,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}
