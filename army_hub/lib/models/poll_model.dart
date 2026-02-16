class PollOption {
  final String id;
  final String text;
  final int votes;

  PollOption({
    required this.id,
    required this.text,
    this.votes = 0,
  });

  factory PollOption.fromMap(Map<String, dynamic> data) {
    return PollOption(
      id: data['id'] ?? '',
      text: data['text'] ?? '',
      votes: data['votes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'votes': votes,
    };
  }

  double getPercentage(int totalVotes) {
    if (totalVotes == 0) return 0;
    return (votes / totalVotes) * 100;
  }
}

enum PollStatus { active, closed }

class PollModel {
  final String id;
  final String question;
  final List<PollOption> options;
  final DateTime createdAt;
  final DateTime endsAt;
  final int totalVotes;
  final PollStatus status;
  final String createdBy;
  final List<String> votedUsers;
  final String? category;

  PollModel({
    required this.id,
    required this.question,
    required this.options,
    required this.createdAt,
    required this.endsAt,
    this.totalVotes = 0,
    this.status = PollStatus.active,
    required this.createdBy,
    this.votedUsers = const [],
    this.category,
  });

  factory PollModel.fromJson(Map<String, dynamic> data) {
    return PollModel(
      id: data['id'] ?? '',
      question: data['question'] ?? '',
      options: (data['options'] as List<dynamic>?)
              ?.map((e) => PollOption.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      endsAt: data['expires_at'] != null
          ? DateTime.parse(data['expires_at'])
          : DateTime.now(),
      totalVotes: data['total_votes'] ?? 0,
      status:
          data['status'] == 'closed' ? PollStatus.closed : PollStatus.active,
      createdBy: data['created_by'] ?? '',
      votedUsers: List<String>.from(data['voted_users'] ?? []),
      category: data['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options.map((e) => e.toMap()).toList(),
      'created_at': createdAt.toIso8601String(),
      'expires_at': endsAt.toIso8601String(),
      'total_votes': totalVotes,
      'status': status == PollStatus.closed ? 'closed' : 'active',
      'created_by': createdBy,
      'voted_users': votedUsers,
      'category': category,
    };
  }

  bool hasUserVoted(String userId) {
    return votedUsers.contains(userId);
  }

  bool get isExpired => DateTime.now().isAfter(endsAt);

  Duration get timeRemaining => endsAt.difference(DateTime.now());
}
