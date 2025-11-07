import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wordle_game.dart';
import '../models/letter_state.dart';
import '../services/storage_service.dart';
import 'wordle_grid.dart';
import 'wordle_keyboard.dart';

class WordleScreen extends StatefulWidget {
  const WordleScreen({super.key});

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen> {
  late WordleGame game;
  final Map<String, LetterState> letterStates = {};
  bool _isLoading = true;
  Map<String, int> _stats = {
    'totalGames': 0,
    'gamesWon': 0,
    'gamesLost': 0,
    'currentStreak': 0,
    'bestStreak': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  Future<void> _loadGame() async {
    final savedGame = await StorageService.loadSession();
    final stats = await StorageService.loadStats();
    
    setState(() {
      game = savedGame ?? WordleGame();
      _stats = stats;
      _isLoading = false;
    });

    if (savedGame != null) {
      _updateLetterStates();
    }
  }

  Future<void> _saveGame() async {
    await StorageService.saveSession(game);
  }

  void _updateLetterStates() {
    letterStates.clear();
    for (int i = 0; i < game.attempts.length; i++) {
      final attempt = game.attempts[i];
      final states = game.getLetterStates(i);
      for (int j = 0; j < attempt.length; j++) {
        final letter = attempt[j];
        final currentState = letterStates[letter];
        final newState = states[j];

        if (currentState == null || newState == LetterState.correct) {
          letterStates[letter] = newState;
        } else if (currentState != LetterState.correct &&
            newState == LetterState.wrongPosition) {
          letterStates[letter] = newState;
        }
      }
    }
  }

  void _onLetterPressed(String letter) {
    setState(() {
      game.addLetter(letter);
      _saveGame();
    });
  }

  void _onBackspacePressed() {
    setState(() {
      game.removeLetter();
      _saveGame();
    });
  }

  Future<void> _onSubmitPressed() async {
    setState(() {
      if (game.submitAttempt()) {
        _updateLetterStates();
        _saveGame();
      }
    });

    if (game.gameWon || game.gameLost) {
      await _updateStats();
      await StorageService.clearSession();
      _showGameOverDialog(context);
    }
  }

  Future<void> _updateStats() async {
    final newTotalGames = _stats['totalGames']! + 1;
    final newGamesWon = game.gameWon ? _stats['gamesWon']! + 1 : _stats['gamesWon']!;
    final newGamesLost = game.gameLost ? _stats['gamesLost']! + 1 : _stats['gamesLost']!;
    
    int newCurrentStreak;
    int newBestStreak = _stats['bestStreak']!;
    
    if (game.gameWon) {
      newCurrentStreak = _stats['currentStreak']! + 1;
      if (newCurrentStreak > newBestStreak) {
        newBestStreak = newCurrentStreak;
      }
    } else {
      newCurrentStreak = 0;
    }

    setState(() {
      _stats = {
        'totalGames': newTotalGames,
        'gamesWon': newGamesWon,
        'gamesLost': newGamesLost,
        'currentStreak': newCurrentStreak,
        'bestStreak': newBestStreak,
      };
    });

    await StorageService.saveStats(
      totalGames: newTotalGames,
      gamesWon: newGamesWon,
      gamesLost: newGamesLost,
      currentStreak: newCurrentStreak,
      bestStreak: newBestStreak,
    );
  }

  void _resetGame() {
    setState(() {
      game = WordleGame();
      letterStates.clear();
    });
    StorageService.clearSession();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isGameOver = game.gameWon || game.gameLost;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 28),
                        onPressed: _resetGame,
                        color: Colors.grey.shade700,
                      ),
                      Text(
                        'WORDLE',
                        style: GoogleFonts.patrickHand(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.bar_chart, size: 28),
                        onPressed: () => _showStats(context),
                        color: Colors.grey.shade700,
                      ),
                    ],
                  ),
                ),
                WordleGrid(game: game),
                const SizedBox(height: 20),
                WordleKeyboard(
                  onLetterPressed: _onLetterPressed,
                  onBackspacePressed: _onBackspacePressed,
                  onSubmitPressed: _onSubmitPressed,
                  isEnabled: !isGameOver,
                  letterStates: letterStates,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          game.gameWon ? '¡Ganaste!' : '¡Perdiste!',
          style: GoogleFonts.patrickHand(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: game.gameWon ? Colors.green.shade700 : Colors.red.shade700,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'La palabra era:',
              style: GoogleFonts.patrickHand(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              game.targetWord,
              style: GoogleFonts.patrickHand(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                'Nuevo Juego',
                style: GoogleFonts.patrickHand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStats(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Estadísticas',
          style: GoogleFonts.patrickHand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Partidas jugadas', '${_stats['totalGames']}'),
            _buildStatRow('Partidas ganadas', '${_stats['gamesWon']}'),
            _buildStatRow('Partidas perdidas', '${_stats['gamesLost']}'),
            const Divider(),
            _buildStatRow('Racha actual', '${_stats['currentStreak']}'),
            _buildStatRow('Mejor racha', '${_stats['bestStreak']}'),
            if (_stats['totalGames']! > 0)
              _buildStatRow(
                'Porcentaje de victorias',
                '${((_stats['gamesWon']! / _stats['totalGames']!) * 100).toStringAsFixed(1)}%',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cerrar',
              style: GoogleFonts.patrickHand(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.patrickHand(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.patrickHand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
