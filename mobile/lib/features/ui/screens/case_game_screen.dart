import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../game/blocs/case_management/case_management_bloc.dart';
import '../widgets/clue_card.dart';
import '../widgets/location_selector.dart';
import '../widgets/case_header.dart';
import 'case_completion_screen.dart';

class CaseGameScreen extends StatelessWidget {
  const CaseGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Detective'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          BlocBuilder<CaseManagementBloc, CaseManagementState>(
            builder: (context, state) {
              if (state.isActive) {
                return IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () => _showAbandonDialog(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocListener<CaseManagementBloc, CaseManagementState>(
        listener: (context, state) {
          if (state.isCompleted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const CaseCompletionScreen(),
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
            if (!state.isActive || state.currentCase == null) {
              return const Center(
                child: Text('No active case'),
              );
            }

            return Column(
              children: [
                // Game header with case info and timer
                CaseHeader(
                  currentCase: state.currentCase!,
                  progress: state.progress!,
                  elapsedTime: state.elapsedTimeMinutes,
                ),
                
                // Current location and navigation
                LocationSelector(
                  currentLocation: state.currentLocation!,
                  availableLocations: state.currentCase!.possibleLocations,
                  onLocationChanged: (locationId) {
                    context.read<CaseManagementBloc>().add(
                      LocationChanged(locationId),
                    );
                  },
                ),
                
                // Available clues
                Expanded(
                  child: state.availableClues.isEmpty
                      ? _buildNoCluesMessage(context, state)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.availableClues.length,
                          itemBuilder: (context, index) {
                            final clue = state.availableClues[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ClueCard(
                                clue: clue,
                                onAnswerSelected: (selectedIndex) {
                                  context.read<CaseManagementBloc>().add(
                                    ClueAttempted(
                                      clue: clue,
                                      selectedAnswerIndex: selectedIndex,
                                    ),
                                  );
                                },
                                lastAttemptCorrect: state.lastAttemptedClue?.id == clue.id 
                                    ? state.lastAttemptCorrect 
                                    : null,
                                usedHints: state.usedHints[clue.id] ?? [],
                                onHintRequested: () {
                                  context.read<CaseManagementBloc>().add(
                                    HintRequested(clue),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoCluesMessage(BuildContext context, CaseManagementState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          const Text(
            'All clues solved in this location!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Travel to another location to continue your investigation.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (state.currentCase!.possibleLocations.length > 1)
            ElevatedButton.icon(
              onPressed: () {
                // Show location selector dialog
                _showLocationDialog(context, state);
              },
              icon: const Icon(Icons.travel_explore),
              label: const Text('Travel to Another Location'),
            ),
        ],
      ),
    );
  }

  void _showLocationDialog(BuildContext context, CaseManagementState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Your Next Destination'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: state.currentCase!.possibleLocations
              .where((id) => id != state.currentLocation!.id)
              .map((locationId) {
            return ListTile(
              title: Text(locationId), // TODO: Get actual location name
              onTap: () {
                Navigator.of(context).pop();
                context.read<CaseManagementBloc>().add(
                  LocationChanged(locationId),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAbandonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandon Case?'),
        content: const Text(
          'Are you sure you want to abandon this case? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Playing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CaseManagementBloc>().add(const CaseAbandoned());
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('Abandon Case'),
          ),
        ],
      ),
    );
  }
}