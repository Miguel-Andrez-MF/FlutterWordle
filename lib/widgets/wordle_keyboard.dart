import 'package:flutter/material.dart';
import '../models/letter_state.dart';

class WordleKeyboard extends StatelessWidget {
  final Function(String) onLetterPressed;
  final Function() onBackspacePressed;
  final Function() onSubmitPressed;
  final bool isEnabled;
  final Map<String, LetterState> letterStates;

  const WordleKeyboard({
    super.key,
    required this.onLetterPressed,
    required this.onBackspacePressed,
    required this.onSubmitPressed,
    this.isEnabled = true,
    this.letterStates = const {},
  });

  Color _getKeyColor(String letter) {
    final state = letterStates[letter.toUpperCase()];
    if (state == null) {
      return Colors.grey.shade300;
    }
    switch (state) {
      case LetterState.correct:
        return Colors.green;
      case LetterState.wrongPosition:
        return Colors.amber;
      case LetterState.notInWord:
        return Colors.grey.shade600;
      case LetterState.empty:
        return Colors.grey.shade300;
    }
  }

  Color _getKeyTextColor(String letter) {
    final state = letterStates[letter.toUpperCase()];
    if (state == null || state == LetterState.empty) {
      return Colors.black;
    }
    return Colors.white;
  }

  Widget _buildKey(String letter) {
    final isLetter = letter.length == 1;
    final keyColor = isLetter ? _getKeyColor(letter) : Colors.grey.shade400;
    final textColor = isLetter ? _getKeyTextColor(letter) : Colors.black;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: ElevatedButton(
          onPressed: isEnabled
              ? () {
                  if (isLetter) {
                    onLetterPressed(letter);
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: keyColor,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...rows.map((row) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((letter) => _buildKey(letter)).toList(),
            )),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: ElevatedButton(
                  onPressed: isEnabled ? onBackspacePressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Icon(Icons.backspace),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: ElevatedButton(
                  onPressed: isEnabled ? onSubmitPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'ENVIAR',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
