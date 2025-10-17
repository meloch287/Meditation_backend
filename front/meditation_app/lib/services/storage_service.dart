import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/meditation.dart';
import '../models/chat_message.dart';

class StorageService {
  static const String _userKey = 'user';
  static const String _favoritesKey = 'favorites';
  static const String _chatHistoryKey = 'chat_history';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // User management
  static Future<User?> getUser() async {
    final prefs = await _prefs;
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;

    try {
      return User.fromJson(json.decode(userJson));
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveUser(User user) async {
    final prefs = await _prefs;
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  static Future<void> updateUser(User user) async {
    await saveUser(user);
  }

  // Favorites management
  static Future<List<int>> getFavorites() async {
    final prefs = await _prefs;
    final favoritesJson = prefs.getString(_favoritesKey);
    if (favoritesJson == null) return [];

    try {
      final List<dynamic> favoritesList = json.decode(favoritesJson);
      return favoritesList.cast<int>();
    } catch (e) {
      return [];
    }
  }

  static Future<void> addToFavorites(int meditationId) async {
    final favorites = await getFavorites();
    if (!favorites.contains(meditationId)) {
      favorites.add(meditationId);
      await _saveFavorites(favorites);
    }
  }

  static Future<void> removeFromFavorites(int meditationId) async {
    final favorites = await getFavorites();
    favorites.remove(meditationId);
    await _saveFavorites(favorites);
  }

  static Future<bool> isFavorite(int meditationId) async {
    final favorites = await getFavorites();
    return favorites.contains(meditationId);
  }

  static Future<void> _saveFavorites(List<int> favorites) async {
    final prefs = await _prefs;
    await prefs.setString(_favoritesKey, json.encode(favorites));
  }

  // Chat history management
  static Future<List<ChatMessage>> getChatHistory(String userId) async {
    final prefs = await _prefs;
    final historyJson = prefs.getString('$_chatHistoryKey\_$userId');
    if (historyJson == null) return [];

    try {
      final List<dynamic> historyList = json.decode(historyJson);
      return historyList.map((msg) => ChatMessage.fromJson(msg)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveChatMessage(ChatMessage message) async {
    final history = await getChatHistory(message.userId);
    history.add(message);
    final prefs = await _prefs;
    await prefs.setString(
      '$_chatHistoryKey\_${message.userId}',
      json.encode(history.map((msg) => msg.toJson()).toList()),
    );
  }

  static Future<void> clearChatHistory(String userId) async {
    final prefs = await _prefs;
    await prefs.remove('$_chatHistoryKey\_$userId');
  }

  // Clear all data
  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}