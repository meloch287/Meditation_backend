import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/meditation.dart';
import '../models/chat_message.dart';

// Replace with your backend URL
const String baseUrl = 'http://localhost:8000/api';

class ApiService {
  // User endpoints
  static Future<User?> getUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<User?> createUser(String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<User?> updateUser(String userId, String name) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateLastPlayed(String userId, int meditationId) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/$userId/last_played/$meditationId'),
      );
    } catch (e) {
      // Ignore errors for offline functionality
    }
  }

  // Meditation endpoints
  static Future<List<Meditation>> getMeditations({
    String? category,
    String? userId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (userId != null) queryParams['user_id'] = userId;

      final uri = Uri.parse('$baseUrl/api/meditations/').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Meditation.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Meditation?> getMeditation(int id, {String? userId}) async {
    try {
      final queryParams = userId != null ? {'user_id': userId} : null;
      final uri = Uri.parse('$baseUrl/api/meditations/$id').replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Meditation.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Subscription endpoints
  static Future<Map<String, dynamic>?> checkActivationCode(String code) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscription/check?code=$code'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> activateSubscription(String code, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/subscription/activate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'code': code, 'user_id': userId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Chat endpoints
  static Future<String?> sendChatMessage(String userId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId, 'message': message}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response'];
      }
      return null;
    } catch (e) {
      return 'Извините, сейчас нет подключения к психологу. Попробуйте позже.';
    }
  }

  static Future<List<ChatMessage>> getChatHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/history?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}