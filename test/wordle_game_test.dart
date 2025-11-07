import 'package:flutter_test/flutter_test.dart';
import 'package:parcial_flutter/models/wordle_game.dart';
import 'package:parcial_flutter/models/letter_state.dart';

void main() {
  group('WordleGame - Pruebas Unitarias', () {
    
    test('getLetterStates debe marcar correctamente las letras', () {
     
      final game = WordleGame.fromJson({
        'targetWord': 'HELLO',
        'attempts': ['APPLE', 'HELLO'],
        'currentAttempt': '',
        'gameWon': false,
        'gameLost': false,
      });

      // Verificar el primer intento: "APPLE" vs "HELLO"
      final states1 = game.getLetterStates(0);
      expect(states1.length, 5, reason: 'Debe tener 5 estados');
      
      // A no está en HELLO
      expect(states1[0], LetterState.notInWord);
      // P no está en HELLO 
      expect(states1[1], LetterState.notInWord);
      // P no está en HELLO 
      expect(states1[2], LetterState.notInWord);
      // L está en HELLO en posición 3 
      expect(states1[3], LetterState.correct);
      // E está en HELLO pero posición incorrecta 
      expect(states1[4], LetterState.wrongPosition);

      
      final states2 = game.getLetterStates(1);
      expect(states2.length, 5, reason: 'Debe tener 5 estados');
      
      // Todas las letras deben estar correctas
      expect(states2[0], LetterState.correct); // H
      expect(states2[1], LetterState.correct); // E
      expect(states2[2], LetterState.correct); // L
      expect(states2[3], LetterState.correct); // L
      expect(states2[4], LetterState.correct); // O
    });

    // Prueba 2: Verificar el flujo completo del juego
    test('El juego debe funcionar correctamente: agregar letras, enviar intentos, ganar', () {
      
      final game = WordleGame.fromJson({
        'targetWord': 'HELLO',
        'attempts': [],
        'currentAttempt': '',
        'gameWon': false,
        'gameLost': false,
      });

      // Verificar estado inicial
      expect(game.attempts.length, 0);
      expect(game.currentAttempt, '');
      expect(game.gameWon, false);
      expect(game.gameLost, false);

      
      game.addLetter('H');
      expect(game.currentAttempt, 'H');
      
      game.addLetter('E');
      expect(game.currentAttempt, 'HE');
      
      game.addLetter('L');
      expect(game.currentAttempt, 'HEL');
      
      game.addLetter('L');
      expect(game.currentAttempt, 'HELL');
      
      game.addLetter('O');
      expect(game.currentAttempt, 'HELLO');
      expect(game.currentAttempt.length, 5);

      // Intentar agregar una letra más (no debe funcionar)
      game.addLetter('X');
      expect(game.currentAttempt, 'HELLO', reason: 'No debe agregar más de 5 letras');

      // Enviar el intento
      final result = game.submitAttempt();
      expect(result, true, reason: 'Debe permitir enviar un intento válido');
      expect(game.attempts.length, 1);
      expect(game.attempts[0], 'HELLO');
      expect(game.currentAttempt, '', reason: 'Debe limpiar el intento actual');

      // Verificar que ganó el juego
      expect(game.gameWon, true);
      expect(game.gameLost, false);

      
      game.addLetter('A');
      expect(game.currentAttempt, '', reason: 'No debe permitir agregar letras después de ganar');
    });
  });
}
