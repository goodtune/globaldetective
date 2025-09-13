import 'package:flutter/material.dart';

import '../../game/models/case.dart';

class CaseHeader extends StatelessWidget {
  final DetectiveCase currentCase;
  final CaseProgress progress;
  final int elapsedTime;

  const CaseHeader({
    super.key,
    required this.currentCase,
    required this.progress,
    required this.elapsedTime,
  });

  @override
  Widget build(BuildContext context) {
    final remainingTime = currentCase.timeLimit - elapsedTime;
    final progressPercentage = currentCase.totalClues > 0 
        ? (progress.solvedClues.length / currentCase.totalClues) * 100 
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Case title and villain
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentCase.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Villain: ${currentCase.villain.name}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(currentCase.difficulty).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getDifficultyName(currentCase.difficulty),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getDifficultyColor(currentCase.difficulty),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress and stats
          Row(
            children: [
              // Progress indicator
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${progress.solvedClues.length}/${currentCase.totalClues} clues',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progressPercentage / 100,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Time remaining
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: remainingTime <= 30 
                      ? Colors.red.shade100 
                      : remainingTime <= 60 
                          ? Colors.orange.shade100 
                          : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: remainingTime <= 30 
                        ? Colors.red.shade300 
                        : remainingTime <= 60 
                            ? Colors.orange.shade300 
                            : Colors.green.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: remainingTime <= 30 
                          ? Colors.red.shade700 
                          : remainingTime <= 60 
                              ? Colors.orange.shade700 
                              : Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(remainingTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: remainingTime <= 30 
                            ? Colors.red.shade700 
                            : remainingTime <= 60 
                                ? Colors.orange.shade700 
                                : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Score and accuracy
          Row(
            children: [
              _buildStatChip(
                'Score',
                '${progress.totalScore}',
                Icons.stars,
                Colors.amber,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                'Accuracy',
                '${progress.accuracyPercentage.toStringAsFixed(0)}%',
                Icons.track_changes,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                'Locations',
                '${progress.visitedLocations.length}',
                Icons.location_on,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }

  Color _getDifficultyColor(CaseDifficulty difficulty) {
    switch (difficulty) {
      case CaseDifficulty.rookie:
        return Colors.green;
      case CaseDifficulty.detective:
        return Colors.blue;
      case CaseDifficulty.inspector:
        return Colors.orange;
      case CaseDifficulty.master:
        return Colors.red;
    }
  }

  String _getDifficultyName(CaseDifficulty difficulty) {
    switch (difficulty) {
      case CaseDifficulty.rookie:
        return 'ROOKIE';
      case CaseDifficulty.detective:
        return 'DETECTIVE';
      case CaseDifficulty.inspector:
        return 'INSPECTOR';
      case CaseDifficulty.master:
        return 'MASTER';
    }
  }
}