import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/player_bloc.dart';
import '../../../../core/theme/app_theme.dart';

class PlayerProfilePage extends StatefulWidget {
  const PlayerProfilePage({super.key});

  @override
  State<PlayerProfilePage> createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load default player
    context.read<PlayerBloc>().add(const LoadPlayer('default'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detective Profile'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          if (state is PlayerLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is PlayerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<PlayerBloc>().add(const LoadPlayer('default')),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is! PlayerLoaded) {
            return const Center(child: Text('No player data available'));
          }
          
          final player = state.player;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.getRankColor(player.rank),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Name
                        Text(
                          player.name,
                          style: GoogleFonts.orbitron(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Rank Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.getRankColor(player.rank),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(player.rankEmoji),
                              const SizedBox(width: 8),
                              Text(
                                player.rank,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.emoji_events,
                        title: 'Total Score',
                        value: player.totalScore.toString(),
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.assignment_turned_in,
                        title: 'Cases Solved',
                        value: player.casesSolved.toString(),
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.account_balance_wallet,
                        title: 'Current Budget',
                        value: '\$${player.currentBudget}',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.trending_up,
                        title: 'Next Rank',
                        value: player.nextRank,
                        color: AppTheme.getRankColor(player.nextRank),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Promotion Progress
                if (!player.canBePromoted && player.rank.toLowerCase() != 'chief') ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Promotion Progress',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Cases needed for ${player.nextRank}: ${player.casesNeededForPromotion}',
                            style: GoogleFonts.poppins(
                              color: AppTheme.subtitleColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: player.casesSolved / (player.casesSolved + player.casesNeededForPromotion),
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.getRankColor(player.nextRank),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Promotion Available
                if (player.canBePromoted) ...[
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.celebration,
                            size: 48,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Promotion Available!',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You can now be promoted to ${player.nextRank}',
                            style: GoogleFonts.poppins(
                              color: Colors.green.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.read<PlayerBloc>().add(PromotePlayer()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                            ),
                            child: const Text('Accept Promotion'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/cases'),
                        icon: const Icon(Icons.search),
                        label: const Text('New Case'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/globe'),
                        icon: const Icon(Icons.public),
                        label: const Text('Explore World'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.orbitron(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}