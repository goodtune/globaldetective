import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/game_bloc.dart';
import '../../../../shared/widgets/animated_logo.dart';
import '../../../../core/theme/app_theme.dart';

class GameHomePage extends StatelessWidget {
  const GameHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              Color(0xFF2C3E50),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                
                // Logo and Title
                const AnimatedLogo(),
                const SizedBox(height: 24),
                
                Text(
                  'GLOBAL DETECTIVE',
                  style: GoogleFonts.orbitron(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Where in the World is the Criminal?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // Game Mode Buttons
                _GameModeCard(
                  icon: Icons.person,
                  title: 'Single Player',
                  description: 'Start your solo detective career',
                  onTap: () => _startSinglePlayer(context),
                ),
                
                const SizedBox(height: 16),
                
                _GameModeCard(
                  icon: Icons.group,
                  title: 'Multiplayer',
                  description: 'Join forces with other detectives',
                  onTap: () => _startMultiplayer(context),
                  isEnabled: false, // TODO: Implement multiplayer
                ),
                
                const SizedBox(height: 32),
                
                // Secondary Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/profile'),
                        icon: const Icon(Icons.badge, color: Colors.white),
                        label: Text(
                          'Profile',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/globe'),
                        icon: const Icon(Icons.public, color: Colors.white),
                        label: Text(
                          'Explore',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // How to Play
                TextButton(
                  onPressed: () => _showHowToPlay(context),
                  child: Text(
                    'How to Play',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _startSinglePlayer(BuildContext context) {
    context.read<GameBloc>().add(StartSinglePlayerGame());
    context.go('/cases');
  }
  
  void _startMultiplayer(BuildContext context) {
    // TODO: Implement multiplayer lobby
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Multiplayer mode coming soon!'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }
  
  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'How to Play',
          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _HowToPlayStep(
                step: '1',
                title: 'Choose a Case',
                description: 'Select from available mystery cases based on your detective rank.',
              ),
              _HowToPlayStep(
                step: '2',
                title: 'Read the Briefing',
                description: 'Study the suspect profile and mission objectives carefully.',
              ),
              _HowToPlayStep(
                step: '3',
                title: 'Investigate the World',
                description: 'Travel to countries and landmarks to find clues about the criminal.',
              ),
              _HowToPlayStep(
                step: '4',
                title: 'Analyze Clues',
                description: 'Separate real evidence from red herrings to track the suspect.',
              ),
              _HowToPlayStep(
                step: '5',
                title: 'Make the Arrest',
                description: 'Use your deduction skills to identify and capture the criminal.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

class _GameModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool isEnabled;
  
  const _GameModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.isEnabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isEnabled ? AppTheme.primaryColor : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isEnabled ? AppTheme.textColor : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isEnabled ? AppTheme.subtitleColor : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isEnabled ? AppTheme.primaryColor : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HowToPlayStep extends StatelessWidget {
  final String step;
  final String title;
  final String description;
  
  const _HowToPlayStep({
    required this.step,
    required this.title,
    required this.description,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}