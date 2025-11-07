import 'package:flutter/material.dart';
import '../models/letter_state.dart';

class LetterBox extends StatelessWidget {
  final String? letter;
  final LetterState state;

  const LetterBox({
    super.key,
    this.letter,
    required this.state,
  });

  Color _getBackgroundColor() {
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

  Color _getTextColor() {
    if (state == LetterState.empty) {
      return Colors.black;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          letter ?? '',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _getTextColor(),
          ),
        ),
      ),
    );
  }
}
