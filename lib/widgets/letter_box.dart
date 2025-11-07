import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          color: Colors.grey.shade300,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          letter ?? '',
          style: GoogleFonts.patrickHand(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: _getTextColor(),
          ),
        ),
      ),
    );
  }
}
