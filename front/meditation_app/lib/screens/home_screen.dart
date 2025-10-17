import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_card.dart';
import 'meditation_player_screen.dart';
import 'main_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Снятие стресса':
        return Colors.red.withOpacity(0.8);
      case 'Фокус':
        return Colors.blue.withOpacity(0.8);
      case 'Сон':
        return Colors.purple.withOpacity(0.8);
      case 'Энергия':
        return Colors.orange.withOpacity(0.8);
      default:
        return Colors.white.withOpacity(0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final user = appState.user;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1a1a2e),
                  Color(0xFF16213e),
                  Color(0xFF0f0f23),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Привет, ${user?.name ?? 'Пользователь'}!',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: appState.isPremium
                                    ? Colors.amber.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: appState.isPremium
                                      ? Colors.amber.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                appState.isPremium ? 'Premium' : 'Free',
                                style: TextStyle(
                                  color: appState.isPremium
                                      ? Colors.amber
                                      : Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Last meditation info
                        if (user?.lastPlayedMeditationId != null)
                          GlassContainer(
                            padding: const EdgeInsets.all(12),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white70,
                                  size: 24,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Продолжить',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Meditation carousel
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Рекомендуемые медитации',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Consumer<AppState>(
                            builder: (context, appState, child) {
                              final meditations = appState.meditations.take(6).toList();

                              if (meditations.isEmpty) {
                                return const Expanded(
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }

                              return SizedBox(
                                height: 180,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  itemCount: meditations.length,
                                  itemBuilder: (context, index) {
                                    final meditation = meditations[index];
                                    final isPremium = meditation.isPremium && !appState.isPremium;
                                    final isFavorite = appState.isFavorite(meditation.id);

                                    return Container(
                                      width: 160,
                                      margin: const EdgeInsets.only(right: 16),
                                      child: GlassCard(
                                        padding: const EdgeInsets.all(16),
                                        onTap: isPremium ? null : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MeditationPlayerScreen(
                                                meditation: meditation,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Category badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getCategoryColor(meditation.category),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                meditation.category,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 8),

                                            // Title
                                            Text(
                                              meditation.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),

                                            const SizedBox(height: 4),

                                            // Duration
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.access_time,
                                                  color: Colors.white70,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  meditation.formattedDuration,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const Spacer(),

                                            // Premium badge or favorite button
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                if (meditation.isPremium)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber.withOpacity(0.2),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Text(
                                                      'Premium',
                                                      style: TextStyle(
                                                        color: Colors.amber,
                                                        fontSize: 8,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  const SizedBox(),
                                                IconButton(
                                                  onPressed: () {
                                                    appState.toggleFavorite(meditation.id);
                                                  },
                                                  icon: Icon(
                                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                                    color: isFavorite ? Colors.red : Colors.white70,
                                                    size: 18,
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Quick actions
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GlassButton(
                                    onPressed: () {
                                      // Switch to meditation tab
                                      final mainNavState = context.findAncestorStateOfType<MainNavigationState>();
                                      mainNavState?.setState(() {
                                        mainNavState._currentIndex = 1;
                                      });
                                    },
                                    child: const Text('Все медитации'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GlassButton(
                                    onPressed: () {
                                      // Switch to psychologist tab
                                      final mainNavState = context.findAncestorStateOfType<MainNavigationState>();
                                      mainNavState?.setState(() {
                                        mainNavState._currentIndex = 2;
                                      });
                                    },
                                    child: const Text('Поговорить'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}