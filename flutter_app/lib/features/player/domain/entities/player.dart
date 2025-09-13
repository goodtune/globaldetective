class Player {
  final String id;
  final String name;
  final String rank;
  final int totalScore;
  final int casesSolved;
  final int currentBudget;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Player({
    required this.id,
    required this.name,
    required this.rank,
    required this.totalScore,
    required this.casesSolved,
    required this.currentBudget,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      name: map['name'] as String,
      rank: map['rank'] as String,
      totalScore: map['total_score'] as int,
      casesSolved: map['cases_solved'] as int,
      currentBudget: map['current_budget'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rank': rank,
      'total_score': totalScore,
      'cases_solved': casesSolved,
      'current_budget': currentBudget,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Player copyWith({
    String? id,
    String? name,
    String? rank,
    int? totalScore,
    int? casesSolved,
    int? currentBudget,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      rank: rank ?? this.rank,
      totalScore: totalScore ?? this.totalScore,
      casesSolved: casesSolved ?? this.casesSolved,
      currentBudget: currentBudget ?? this.currentBudget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get rankEmoji {
    switch (rank.toLowerCase()) {
      case 'rookie':
        return '🟢';
      case 'detective':
        return '🔵';
      case 'inspector':
        return '🟣';
      case 'chief':
        return '🟡';
      default:
        return '⚪';
    }
  }

  String get nextRank {
    switch (rank.toLowerCase()) {
      case 'rookie':
        return 'Detective';
      case 'detective':
        return 'Inspector';
      case 'inspector':
        return 'Chief Inspector';
      default:
        return rank;
    }
  }

  int get casesNeededForPromotion {
    switch (rank.toLowerCase()) {
      case 'rookie':
        return 3 - casesSolved;
      case 'detective':
        return 10 - casesSolved;
      case 'inspector':
        return 25 - casesSolved;
      default:
        return 0;
    }
  }

  bool get canBePromoted {
    return casesNeededForPromotion <= 0 && rank.toLowerCase() != 'chief';
  }

  @override
  String toString() {
    return 'Player(id: $id, name: $name, rank: $rank, score: $totalScore)';
  }
}