import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../game/models/case.dart';
import '../../game/blocs/case_management/case_management_bloc.dart';
import 'case_game_screen.dart';

class CaseSelectionScreen extends StatelessWidget {
  const CaseSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Case Difficulty'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: BlocListener<CaseManagementBloc, CaseManagementState>(
        listener: (context, state) {
          if (state.status == CaseManagementStatus.active && state.currentCase != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const CaseGameScreen(),
              ),
            );
          } else if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<CaseManagementBloc, CaseManagementState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating case...'),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose Your Challenge',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select a difficulty level to begin your detective mission:',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildDifficultyCard(
                          context,
                          CaseDifficulty.rookie,
                          'Rookie Detective',
                          'Perfect for beginners. Simple clues and familiar locations.',
                          Icons.star_border,
                          Colors.green,
                          '60 minutes • 3-4 locations • Basic clues',
                        ),
                        const SizedBox(height: 16),
                        _buildDifficultyCard(
                          context,
                          CaseDifficulty.detective,
                          'Detective',
                          'Moderate challenge with cultural and historical clues.',
                          Icons.star_half,
                          Colors.blue,
                          '90 minutes • 4-5 locations • Mixed clues',
                        ),
                        const SizedBox(height: 16),
                        _buildDifficultyCard(
                          context,
                          CaseDifficulty.inspector,
                          'Inspector',
                          'Advanced cases requiring deep knowledge and deduction.',
                          Icons.star,
                          Colors.orange,
                          '120 minutes • 5-6 locations • Complex clues',
                        ),
                        const SizedBox(height: 16),
                        _buildDifficultyCard(
                          context,
                          CaseDifficulty.master,
                          'Master Detective',
                          'Expert level with the most challenging mysteries.',
                          Icons.military_tech,
                          Colors.red,
                          '180 minutes • 6+ locations • Expert clues',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(
    BuildContext context,
    CaseDifficulty difficulty,
    String title,
    String description,
    IconData icon,
    Color color,
    String details,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          context.read<CaseManagementBloc>().add(CaseStarted(difficulty));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        details,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}