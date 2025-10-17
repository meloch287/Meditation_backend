import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/meditation.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_container.dart';
import 'meditation_player_screen.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategory;

  final List<String> categories = [
    'Все',
    'Снятие стресса',
    'Фокус',
    'Сон',
    'Энергия',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {
      if (_tabController.index == 0) {
        _selectedCategory = null;
      } else {
        _selectedCategory = categories[_tabController.index];
      }
    });

    // Reload meditations with new category filter
    final appState = Provider.of<AppState>(context, listen: false);
    appState.loadMeditations(category: _selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
            // Header (only show back button if not in main navigation)
            Consumer<AppState>(
              builder: (context, appState, child) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      if (Navigator.of(context).canPop())
                        GlassButton(
                          onPressed: () => Navigator.pop(context),
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      if (Navigator.of(context).canPop())
                        const SizedBox(width: 16),
                      Text(
                        'Медитации',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                );
              },
            ),

              // Category tabs
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicator: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: categories.map((category) {
                    return Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          category,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Meditations list
              Expanded(
                child: Consumer<AppState>(
                  builder: (context, appState, child) {
                    final meditations = _selectedCategory == null
                        ? appState.meditations
                        : appState.meditations.where(
                            (med) => med.category == _selectedCategory,
                          ).toList();

                    if (meditations.isEmpty) {
                      return const Center(
                        child: Text(
                          'Нет доступных медитаций',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: meditations.length,
                      itemBuilder: (context, index) {
                        final meditation = meditations[index];
                        final isFavorite = appState.isFavorite(meditation.id);
                        final isLocked = meditation.isPremium && !appState.isPremium;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GlassCard(
                            onTap: isLocked ? null : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MeditationPlayerScreen(
                                    meditation: meditation,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Play button / Lock icon
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: isLocked
                                          ? Colors.grey.withOpacity(0.3)
                                          : Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isLocked ? Icons.lock : Icons.play_arrow,
                                      color: isLocked ? Colors.grey : Colors.white,
                                      size: 30,
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Meditation info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          meditation.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          meditation.description,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              color: Colors.white.withOpacity(0.6),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              meditation.formattedDuration,
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.6),
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            if (meditation.isPremium)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: const Text(
                                                  'Premium',
                                                  style: TextStyle(
                                                    color: Colors.amber,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Favorite button
                                  IconButton(
                                    onPressed: () {
                                      appState.toggleFavorite(meditation.id);
                                    },
                                    icon: Icon(
                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: isFavorite ? Colors.red : Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}