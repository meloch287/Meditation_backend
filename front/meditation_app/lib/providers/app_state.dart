import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/meditation.dart';
import '../models/chat_message.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  User? _user;
  List<Meditation> _meditations = [];
  List<int> _favorites = [];
  List<ChatMessage> _chatHistory = [];
  bool _isLoading = false;

  User? get user => _user;
  List<Meditation> get meditations => _meditations;
  List<int> get favorites => _favorites;
  List<ChatMessage> get chatHistory => _chatHistory;
  bool get isLoading => _isLoading;
  bool get isPremium => _user?.hasActivePremium ?? false;

  // Initialize app state
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load user from storage
      _user = await StorageService.getUser();

      // Create user if doesn't exist
      if (_user == null) {
        final userId = const Uuid().v4();
        final newUser = User(id: userId, name: 'Пользователь');
        await StorageService.saveUser(newUser);
        _user = newUser;
      }

      // Load favorites
      _favorites = await StorageService.getFavorites();

      // Load chat history
      _chatHistory = await StorageService.getChatHistory(_user!.id);

      // Load meditations from API
      await loadMeditations();

    } catch (e) {
      // Handle initialization errors gracefully
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // User management
  Future<void> updateUserName(String name) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(name: name);
    await StorageService.updateUser(updatedUser);

    // Try to sync with backend
    final backendUser = await ApiService.updateUser(_user!.id, name);
    if (backendUser != null) {
      _user = backendUser;
      await StorageService.saveUser(_user!);
    } else {
      _user = updatedUser;
    }

    notifyListeners();
  }

  Future<void> updateLastPlayed(int meditationId) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(lastPlayedMeditationId: meditationId);
    _user = updatedUser;
    await StorageService.saveUser(_user!);

    // Sync with backend
    await ApiService.updateLastPlayed(_user!.id, meditationId);

    notifyListeners();
  }

  // Meditations
  Future<void> loadMeditations({String? category}) async {
    _meditations = await ApiService.getMeditations(
      category: category,
      userId: _user?.id,
    );
    notifyListeners();
  }

  // Favorites
  Future<void> toggleFavorite(int meditationId) async {
    if (_favorites.contains(meditationId)) {
      _favorites.remove(meditationId);
      await StorageService.removeFromFavorites(meditationId);
    } else {
      _favorites.add(meditationId);
      await StorageService.addToFavorites(meditationId);
    }
    notifyListeners();
  }

  bool isFavorite(int meditationId) {
    return _favorites.contains(meditationId);
  }

  List<Meditation> get favoriteMeditations {
    return _meditations.where((med) => _favorites.contains(med.id)).toList();
  }

  // Subscriptions
  Future<bool> activateSubscription(String code) async {
    if (_user == null) return false;

    final result = await ApiService.activateSubscription(code, _user!.id);
    if (result != null && result['status'] == 'activated') {
      final expiresAt = DateTime.parse(result['until']);
      final updatedUser = _user!.copyWith(
        isPremium: true,
        premiumExpiresAt: expiresAt,
      );

      _user = updatedUser;
      await StorageService.saveUser(_user!);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Chat
  Future<String?> sendChatMessage(String message) async {
    if (_user == null) return null;

    final response = await ApiService.sendChatMessage(_user!.id, message);
    if (response != null) {
      final userMessage = ChatMessage(
        id: const Uuid().v4(),
        userId: _user!.id,
        content: message,
        isUser: true,
        createdAt: DateTime.now(),
      );

      final aiMessage = ChatMessage(
        id: const Uuid().v4(),
        userId: _user!.id,
        content: response,
        isUser: false,
        createdAt: DateTime.now(),
      );

      await StorageService.saveChatMessage(userMessage);
      await StorageService.saveChatMessage(aiMessage);

      _chatHistory.add(userMessage);
      _chatHistory.add(aiMessage);

      notifyListeners();
    }
    return response;
  }

  Future<void> loadChatHistory() async {
    if (_user == null) return;

    _chatHistory = await ApiService.getChatHistory(_user!.id);
    // Also save to local storage
    for (final message in _chatHistory) {
      await StorageService.saveChatMessage(message);
    }
    notifyListeners();
  }

  Future<void> clearChatHistory() async {
    if (_user == null) return;

    await StorageService.clearChatHistory(_user!.id);
    _chatHistory.clear();
    notifyListeners();
  }
}