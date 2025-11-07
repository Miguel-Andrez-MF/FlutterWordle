import 'package:flutter/material.dart';
import '../models/wordle_game.dart';
import '../models/letter_state.dart';
import 'letter_box.dart';

class WordleGrid extends StatelessWidget {
  final WordleGame game;

  const WordleGrid({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(6, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (colIndex) {
              String? letter;
              LetterState state;

              if (rowIndex < game.attempts.length) {
                final attempt = game.attempts[rowIndex];
                final states = game.getLetterStates(rowIndex);
                letter = colIndex < attempt.length ? attempt[colIndex] : null;
                state = states[colIndex];
              } else if (rowIndex == game.attempts.length) {
                letter = colIndex < game.currentAttempt.length
                    ? game.currentAttempt[colIndex]
                    : null;
                state = LetterState.empty;
              } else {
                letter = null;
                state = LetterState.empty;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: LetterBox(
                  letter: letter,
                  state: state,
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
