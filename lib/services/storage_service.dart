import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wordle_game.dart';
import 'firebase_service.dart';

class StorageService {
  static const String _sessionKey = 'wordle_session';
  static const String _statsKey = 'wordle_stats';

  // Session Storage - Guarda en Firebase (principal) y SharedPreferences (backup)
  static Future<void> saveSession(WordleGame game) async {
    // Guardar en Firebase (principal)
    await FirebaseService.saveSession(game);
    
    // También guardar localmente como backup
    final prefs = await SharedPreferences.getInstance();
    final sessionData = {
      'targetWord': game.targetWord,
      'attempts': game.attempts,
      'currentAttempt': game.currentAttempt,
      'gameWon': game.gameWon,
      'gameLost': game.gameLost,
    };
    await prefs.setString(_sessionKey, jsonEncode(sessionData));
  }

  static Future<WordleGame?> loadSession() async {
    // Intentar cargar desde Firebase primero
    final firebaseGame = await FirebaseService.loadSession();
    if (firebaseGame != null) {
      // Si hay datos en Firebase, también actualizar local
      final prefs = await SharedPreferences.getInstance();
      final sessionData = {
        'targetWord': firebaseGame.targetWord,
        'attempts': firebaseGame.attempts,
        'currentAttempt': firebaseGame.currentAttempt,
        'gameWon': firebaseGame.gameWon,
        'gameLost': firebaseGame.gameLost,
      };
      await prefs.setString(_sessionKey, jsonEncode(sessionData));
      return firebaseGame;
    }
    
    // Si no hay en Firebase, intentar cargar local
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString(_sessionKey);
    
    if (sessionData == null) return null;

    try {
      final data = jsonDecode(sessionData) as Map<String, dynamic>;
      final game = WordleGame.fromJson(data);
      // Sincronizar con Firebase
      await FirebaseService.saveSession(game);
      return game;
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearSession() async {
    // Limpiar en ambos lugares
    await FirebaseService.clearSession();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  // Local Storage - Estadísticas persistentes
  // Guarda en Firebase (principal) y SharedPreferences (backup)
  static Future<void> saveStats({
    required int totalGames,
    required int gamesWon,
    required int gamesLost,
    required int currentStreak,
    required int bestStreak,
  }) async {
    // Guardar en Firebase (principal)
    await FirebaseService.saveStats(
      totalGames: totalGames,
      gamesWon: gamesWon,
      gamesLost: gamesLost,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
    );
    
    // También guardar localmente como backup
    final prefs = await SharedPreferences.getInstance();
    final statsData = {
      'totalGames': totalGames,
      'gamesWon': gamesWon,
      'gamesLost': gamesLost,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
    };
    await prefs.setString(_statsKey, jsonEncode(statsData));
  }

  static Future<Map<String, int>> loadStats() async {
    // Intentar cargar desde Firebase primero
    final firebaseStats = await FirebaseService.loadStats();
    if (firebaseStats['totalGames']! > 0) {
      // Si hay datos en Firebase, también actualizar local
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_statsKey, jsonEncode(firebaseStats));
      return firebaseStats;
    }
    
    // Si no hay en Firebase, intentar cargar local
    final prefs = await SharedPreferences.getInstance();
    final statsData = prefs.getString(_statsKey);
    
    if (statsData == null) {
      return {
        'totalGames': 0,
        'gamesWon': 0,
        'gamesLost': 0,
        'currentStreak': 0,
        'bestStreak': 0,
      };
    }

    try {
      final data = jsonDecode(statsData) as Map<String, dynamic>;
      final stats = {
        'totalGames': data['totalGames'] as int? ?? 0,
        'gamesWon': data['gamesWon'] as int? ?? 0,
        'gamesLost': data['gamesLost'] as int? ?? 0,
        'currentStreak': data['currentStreak'] as int? ?? 0,
        'bestStreak': data['bestStreak'] as int? ?? 0,
      };
      // Sincronizar con Firebase
      await FirebaseService.saveStats(
        totalGames: stats['totalGames']!,
        gamesWon: stats['gamesWon']!,
        gamesLost: stats['gamesLost']!,
        currentStreak: stats['currentStreak']!,
        bestStreak: stats['bestStreak']!,
      );
      return stats;
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
