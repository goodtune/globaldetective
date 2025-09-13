import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../game/models/case.dart';
import '../../game/blocs/case_management/case_management_bloc.dart';
import 'case_selection_screen.dart';

class CaseCompletionScreen extends StatelessWidget {
  const CaseCompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CaseManagementBloc, CaseManagementState>(
        builder: (context, state) {
          if (!state.isCompleted || state.progress == null || state.currentCase == null) {
            return const Center(child: Text('No completed case found'));
          }

          final progress = state.progress!;
          final currentCase = state.currentCase!;
          final isSuccessful = progress.isSuccessful;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isSuccessful
                    ? [Colors.green.shade400, Colors.green.shade700]
                    : [Colors.orange.shade400, Colors.orange.shade700],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Spacer(),
                    
                    // Success/Completion Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSuccessful ? Icons.check_circle : Icons.access_time,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Title
                    Text(
                      isSuccessful ? 'Case Solved!' : 'Case Complete',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      isSuccessful 
                          ? 'Excellent detective work!' 
                          : 'Good effort, Detective!',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Stats Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            currentCase.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Statistics
                          _buildStatRow('Score', '${progress.totalScore} points'),
                          _buildStatRow('Accuracy', '${progress.accuracyPercentage.toStringAsFixed(1)}%'),
                          _buildStatRow('Time', '${progress.timeElapsedMinutes} minutes'),
                          _buildStatRow('Locations Visited', '${progress.visitedLocations.length}'),
                          _buildStatRow('Clues Solved', '${progress.solvedClues.length}'),
                          
                          const SizedBox(height: 16),
                          
                          // Difficulty indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(currentCase.difficulty).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getDifficultyColor(currentCase.difficulty),
                              ),
                            ),
                            child: Text(
                              _getDifficultyName(currentCase.difficulty),
                              style: TextStyle(
                                color: _getDifficultyColor(currentCase.difficulty),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Action Buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const CaseSelectionScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: isSuccessful ? Colors.green.shade700 : Colors.orange.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Take Another Case',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Return to Main Menu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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
        return 'Rookie Detective';
      case CaseDifficulty.detective:
        return 'Detective';
      case CaseDifficulty.inspector:
        return 'Inspector';
      case CaseDifficulty.master:
        return 'Master Detective';
    }
  }
}