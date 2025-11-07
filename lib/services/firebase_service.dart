import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wordle_game.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static String? _userId;
  static const String _userIdKey = 'firebase_user_id';

  // Obtener un ID único del dispositivo
  static Future<String> _getUserId() async {
    if (_userId != null) return _userId!;
    
    try {
      // Intentar obtener ID guardado localmente
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString(_userIdKey);
      
      if (_userId == null) {
        // Generar nuevo ID basado en el dispositivo
        final deviceInfo = DeviceInfoPlugin();
        try {
          final androidInfo = await deviceInfo.androidInfo;
          _userId = androidInfo.id;
        } catch (e) {
          // Si no es Android, generar ID único
          _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        }
        
        // Guardar el ID para uso futuro
        await prefs.setString(_userIdKey, _userId!);
      }
    } catch (e) {
      // Si todo falla, usar un ID generado
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    return _userId!;
  }

  // Session Storage - Guarda el estado actual del juego en Firestore
  static Future<void> saveSession(WordleGame game) async {
    try {
      final userId = await _getUserId();
      await _firestore.collection('sessions').doc(userId).set({
        'targetWord': game.targetWord,
        'attempts': game.attempts,
        'currentAttempt': game.currentAttempt,
        'gameWon': game.gameWon,
        'gameLost': game.gameLost,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Si falla Firebase, no hacer nada (el StorageService local lo manejará)
    }
  }

  static Future<WordleGame?> loadSession() async {
    try {
      final userId = await _getUserId();
      final doc = await _firestore.collection('sessions').doc(userId).get();
      
      if (!doc.exists) return null;

      final data = doc.data()!;
      return WordleGame.fromJson({
        'targetWord': data['targetWord'] as String,
        'attempts': List<String>.from(data['attempts'] as List),
        'currentAttempt': data['currentAttempt'] as String? ?? '',
        'gameWon': data['gameWon'] as bool? ?? false,
        'gameLost': data['gameLost'] as bool? ?? false,
      });
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearSession() async {
    try {
      final userId = await _getUserId();
      await _firestore.collection('sessions').doc(userId).delete();
    } catch (e) {
      // Si falla, no hacer nada
    }
  }

  // Local Storage - Estadísticas persistentes en Firestore
  static Future<void> saveStats({
    required int totalGames,
    required int gamesWon,
    required int gamesLost,
    required int currentStreak,
    required int bestStreak,
  }) async {
    try {
      final userId = await _getUserId();
      await _firestore.collection('stats').doc(userId).set({
        'totalGames': totalGames,
        'gamesWon': gamesWon,
        'gamesLost': gamesLost,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Si falla Firebase, no hacer nada
    }
  }

  static Future<Map<String, int>> loadStats() async {
    try {
      final userId = await _getUserId();
      final doc = await _firestore.collection('stats').doc(userId).get();
      
      if (!doc.exists) {
        return {
          'totalGames': 0,
          'gamesWon': 0,
          'gamesLost': 0,
          'currentStreak': 0,
          'bestStreak': 0,
        };
      }

      final data = doc.data()!;
      return {
        'totalGames': data['totalGames'] as int? ?? 0,
        'gamesWon': data['gamesWon'] as int? ?? 0,
        'gamesLost': data['gamesLost'] as int? ?? 0,
        'currentStreak': data['currentStreak'] as int? ?? 0,
        'bestStreak': data['bestStreak'] as int? ?? 0,
      };
    } catch (e) {
      return {
        'totalGames': 0,
        'gamesWon': 0,
        'gamesLost': 0,
        'currentStreak': 0,
        'bestStreak': 0,
      };
    }
  }
}
