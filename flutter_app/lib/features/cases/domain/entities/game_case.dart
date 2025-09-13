class GameCase {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String suspectName;
  final String? suspectDescription;
  final String artifactName;
  final String? artifactDescription;
  final int timeLimit; // in minutes
  final int budgetRequired;
  final int rewardAmount;
  final DateTime createdAt;

  const GameCase({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.suspectName,
    this.suspectDescription,
    required this.artifactName,
    this.artifactDescription,
    required this.timeLimit,
    required this.budgetRequired,
    required this.rewardAmount,
    required this.createdAt,
  });

  factory GameCase.fromMap(Map<String, dynamic> map) {
    return GameCase(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      difficulty: map['difficulty'] as String,
      suspectName: map['suspect_name'] as String,
      suspectDescription: map['suspect_description'] as String?,
      artifactName: map['artifact_name'] as String,
      artifactDescription: map['artifact_description'] as String?,
      timeLimit: map['time_limit'] as int,
      budgetRequired: map['budget_required'] as int,
      rewardAmount: map['reward_amount'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'suspect_name': suspectName,
      'suspect_description': suspectDescription,
      'artifact_name': artifactName,
      'artifact_description': artifactDescription,
      'time_limit': timeLimit,
      'budget_required': budgetRequired,
      'reward_amount': rewardAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get difficultyEmoji {
    switch (difficulty.toLowerCase()) {
      case 'rookie':
        return '🟢';
      case 'detective':
        return '🟡';
      case 'inspector':
        return '🔴';
      default:
        return '⚪';
    }
  }

  @override
  String toString() {
    return 'GameCase(id: $id, title: $title, difficulty: $difficulty)';
  }
}