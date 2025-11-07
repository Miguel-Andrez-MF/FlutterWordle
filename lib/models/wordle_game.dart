import 'dart:math';
import 'letter_state.dart';

class WordleGame {
  final String targetWord;
  final List<String> attempts;
  String currentAttempt;
  bool gameWon;
  bool gameLost;

  static final List<String> wordList = [
  'CASAS',
  'PERRO',
  'MESAS',
  'PLAYA',
  'TRIGO',
  'DULCE',
  'CAMPO',
  'HIELO',
  'SUENO',
  'LIMON',
  'PAPEL',
  'FUEGO',
];


  WordleGame()
      : targetWord = wordList[Random().nextInt(wordList.length)],
        attempts = [],
        currentAttempt = '',
        gameWon = false,
        gameLost = false;

  WordleGame.fromJson(Map<String, dynamic> json)
      : targetWord = json['targetWord'] as String,
        attempts = List<String>.from(json['attempts'] as List),
        currentAttempt = json['currentAttempt'] as String,
        gameWon = json['gameWon'] as bool,
        gameLost = json['gameLost'] as bool;

  void addLetter(String letter) {
    if (currentAttempt.length < 5 && !gameWon && !gameLost) {
      currentAttempt += letter.toUpperCase();
    }
  }

  void removeLetter() {
    if (currentAttempt.isNotEmpty && !gameWon && !gameLost) {
      currentAttempt = currentAttempt.substring(0, currentAttempt.length - 1);
    }
  }

  bool submitAttempt() {
    if (currentAttempt.length != 5 || gameWon || gameLost) {
      return false;
    }

    attempts.add(currentAttempt);

    if (currentAttempt == targetWord) {
      gameWon = true;
    } else if (attempts.length >= 6) {
      gameLost = true;
    }

    currentAttempt = '';
    return true;
  }

  List<LetterState> getLetterStates(int attemptIndex) {
    if (attemptIndex >= attempts.length) {
      return List.filled(5, LetterState.empty);
    }

    final attempt = attempts[attemptIndex];
    final states = List<LetterState>.filled(5, LetterState.notInWord);
    final targetLetters = targetWord.split('');
    final attemptLetters = attempt.split('');
    final usedTargetIndices = <int>{};
    final usedAttemptIndices = <int>{};

    for (int i = 0; i < 5; i++) {
      if (attemptLetters[i] == targetLetters[i]) {
        states[i] = LetterState.correct;
        usedTargetIndices.add(i);
        usedAttemptIndices.add(i);
      }
    }

    for (int i = 0; i < 5; i++) {
      if (usedAttemptIndices.contains(i)) continue;

      for (int j = 0; j < 5; j++) {
        if (usedTargetIndices.contains(j)) continue;
        if (attemptLetters[i] == targetLetters[j]) {
          states[i] = LetterState.wrongPosition;
          usedTargetIndices.add(j);
          break;
        }
      }
    }

    return states;
  }

  List<LetterState> getCurrentAttemptStates() {
    if (currentAttempt.isEmpty) {
      return List.filled(5, LetterState.empty);
    }

    final states = <LetterState>[];
    for (int i = 0; i < 5; i++) {
      if (i < currentAttempt.length) {
        states.add(LetterState.empty);
      } else {
        states.add(LetterState.empty);
      }
    }
    return states;
  }

  void reset() {
    attempts.clear();
    currentAttempt = '';
    gameWon = false;
    gameLost = false;
  }
}
