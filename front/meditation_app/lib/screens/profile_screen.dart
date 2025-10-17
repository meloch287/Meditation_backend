import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _activationCodeController = TextEditingController();
  bool _isEditingName = false;
  bool _isActivating = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppState>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _activationCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    final appState = Provider.of<AppState>(context, listen: false);
    await appState.updateUserName(newName);

    setState(() {
      _isEditingName = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Имя обновлено'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _activateSubscription() async {
    final code = _activationCodeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _isActivating = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    final success = await appState.activateSubscription(code);

    setState(() {
      _isActivating = false;
    });

    if (success) {
      _activationCodeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Подписка активирована!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Неверный код активации'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final user = appState.user;
        if (user == null) return const SizedBox.shrink();

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (only show back button if not in main navigation)
                    Row(
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
                        const Text(
                          'Профиль',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // User info card
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Name editing
                          if (_isEditingName)
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _nameController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: 'Введите имя',
                                      hintStyle: TextStyle(color: Colors.white70),
                                    ),
                                    autofocus: true,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _saveName,
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditingName = false;
                                    });
                                    _nameController.text = user.name;
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditingName = true;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 16),

                          // Premium status
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
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
                              appState.isPremium ? 'Premium активна' : 'Free версия',
                              style: TextStyle(
                                color: appState.isPremium
                                    ? Colors.amber
                                    : Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          if (appState.isPremium && user.premiumExpiresAt != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Истекает: ${user.premiumExpiresAt!.day}.${user.premiumExpiresAt!.month}.${user.premiumExpiresAt!.year}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Activation code section
                    const Text(
                      'Активация подписки',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _activationCodeController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Введите код активации',
                              hintStyle: TextStyle(color: Colors.white70),
                            ),
                            textCapitalization: TextCapitalization.characters,
                          ),
                          const SizedBox(height: 16),
                          GlassButton(
                            onPressed: _isActivating ? null : _activateSubscription,
                            child: _isActivating
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Активировать'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Subscription history placeholder
                    const Text(
                      'История активаций',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        'История активаций будет отображаться здесь',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
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