import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/platform_service.dart';
import '../../../core/constants/app_constants.dart';
import '../layouts/responsive_layout.dart';
import '../widgets/platform_info_card.dart';
import '../../networking/blocs/network_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final platformInfo = PlatformService.instance.platformInfo;
    
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context, platformInfo),
      tablet: _buildTabletLayout(context, platformInfo),
      desktop: _buildDesktopLayout(context, platformInfo),
    );
  }

  Widget _buildMobileLayout(BuildContext context, platformInfo) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlatformInfoCard(platformInfo: platformInfo),
            const SizedBox(height: 24),
            _buildMainMenu(context, true),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, platformInfo) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: PlatformInfoCard(platformInfo: platformInfo),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: _buildMainMenu(context, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, platformInfo) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        centerTitle: true,
        toolbarHeight: 70,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  PlatformInfoCard(platformInfo: platformInfo),
                  const SizedBox(height: 24),
                  _buildQuickStats(context),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              flex: 3,
              child: _buildMainMenu(context, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenu(BuildContext context, bool isMobile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome, Detective!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your adventure mode',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            BlocBuilder<NetworkBloc, NetworkState>(
              builder: (context, networkState) {
                return _buildMenuButton(
                  context,
                  icon: Icons.wifi_outlined,
                  title: 'Host Game',
                  subtitle: networkState.isServerRunning 
                      ? 'Server running (${networkState.connectedPlayers} players)'
                      : 'Start a new multiplayer session',
                  onTap: () => _handleHostGame(context, networkState),
                  isMobile: isMobile,
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            BlocBuilder<NetworkBloc, NetworkState>(
              builder: (context, networkState) {
                return _buildMenuButton(
                  context,
                  icon: Icons.group_add_outlined,
                  title: 'Join Game',
                  subtitle: networkState.hasAvailableSessions
                      ? '${networkState.availableSessions.length} sessions found'
                      : 'Connect to an existing session',
                  onTap: () => _handleJoinGame(context, networkState),
                  isMobile: isMobile,
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildMenuButton(
              context,
              icon: Icons.person_outline,
              title: 'Solo Practice',
              subtitle: 'Explore the world on your own',
              onTap: () => _handleSoloPractice(context),
              isMobile: isMobile,
            ),
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleSettings(context),
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Settings'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleAbout(context),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('About'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: isMobile ? 24 : 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow(context, 'Detective Rank', 'Rookie'),
            const SizedBox(height: 8),
            _buildStatRow(context, 'Cases Solved', '0'),
            const SizedBox(height: 8),
            _buildStatRow(context, 'Countries Visited', '0'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  void _handleHostGame(BuildContext context, NetworkState networkState) {
    if (networkState.isServerRunning) {
      // Show server management dialog
      _showServerManagementDialog(context, networkState);
    } else {
      // Show host game dialog
      _showHostGameDialog(context);
    }
  }

  void _handleJoinGame(BuildContext context, NetworkState networkState) {
    if (!networkState.isNetworkReady) {
      _showDialog(context, 'Network Error', 'Network not ready. Please check your connection.');
      return;
    }

    // Start discovery if not already discovering
    if (!networkState.isDiscovering) {
      context.read<NetworkBloc>().add(const DiscoveryStarted());
    }

    _showJoinGameDialog(context, networkState);
  }

  void _handleSoloPractice(BuildContext context) {
    _showDialog(context, 'Solo Practice', 'Solo practice mode coming soon!\n\nPractice your detective skills without multiplayer.');
  }

  void _handleSettings(BuildContext context) {
    _showDialog(context, 'Settings', 'Settings menu coming soon!\n\nConfigure audio, graphics, and gameplay options.');
  }

  void _handleAbout(BuildContext context) {
    _showDialog(context, 'About Global Detective', 
        '🕵️‍♀️ Global Detective v${AppConstants.appVersion}\n\n'
        'A collaborative geography mystery game inspired by Carmen Sandiego.\n\n'
        'Built with Flutter for multi-platform gaming.\n\n'
        'Platform: ${PlatformService.instance.platformInfo.deviceType.name}');
  }

  void _showHostGameDialog(BuildContext context) {
    final sessionNameController = TextEditingController();
    final playerNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Host New Game'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sessionNameController,
              decoration: const InputDecoration(
                labelText: 'Session Name',
                hintText: 'My Detective Session',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: playerNameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                hintText: 'Detective Name',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final sessionName = sessionNameController.text.trim();
              final playerName = playerNameController.text.trim();
              
              if (sessionName.isNotEmpty && playerName.isNotEmpty) {
                context.read<NetworkBloc>().add(ServerStarted(
                  sessionName: sessionName,
                  hostPlayerName: playerName,
                ));
                Navigator.of(context).pop();
              }
            },
            child: const Text('Start Server'),
          ),
        ],
      ),
    );
  }

  void _showServerManagementDialog(BuildContext context, NetworkState networkState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Server'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session: ${networkState.sessionName}'),
            Text('Host: ${networkState.hostPlayerName}'),
            Text('Port: ${networkState.serverPort}'),
            Text('Connected Players: ${networkState.connectedPlayers}'),
            const SizedBox(height: 16),
            const Text('Server is running and accepting connections.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NetworkBloc>().add(const ServerStopped());
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Stop Server'),
          ),
        ],
      ),
    );
  }

  void _showJoinGameDialog(BuildContext context, NetworkState networkState) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<NetworkBloc, NetworkState>(
        builder: (context, state) => AlertDialog(
          title: const Text('Join Game'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available Sessions (${state.availableSessions.length}):'),
                const SizedBox(height: 16),
                if (state.isDiscovering)
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Searching for sessions...'),
                      ],
                    ),
                  )
                else if (state.availableSessions.isEmpty)
                  const Center(
                    child: Text('No sessions found.\nMake sure you\'re on the same network.'),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.availableSessions.length,
                      itemBuilder: (context, index) {
                        final session = state.availableSessions[index];
                        return Card(
                          child: ListTile(
                            title: Text(session.sessionName),
                            subtitle: Text('Host: ${session.hostName}\n'
                                '${session.currentPlayers}/${session.maxPlayers} players'),
                            trailing: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement join session
                                Navigator.of(context).pop();
                                _showDialog(context, 'Join Session', 
                                    'Joining "${session.sessionName}" coming soon!');
                              },
                              child: const Text('Join'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<NetworkBloc>().add(const DiscoveryStopped());
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            if (!state.isDiscovering)
              ElevatedButton(
                onPressed: () {
                  context.read<NetworkBloc>().add(const DiscoveryStarted());
                },
                child: const Text('Refresh'),
              ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}