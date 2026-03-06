import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KeypadSection extends StatelessWidget {
  final Function(String) onNumberPressed;
  final Function() onBackspacePressed;
  final Function() onClearPressed;

  const KeypadSection({
    super.key,
    required this.onNumberPressed,
    required this.onBackspacePressed,
    required this.onClearPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRow(['7', '8', '9']),
          _buildRow(['4', '5', '6']),
          _buildRow(['1', '2', '3']),
          _buildRow(['backspace', '0', 'C']),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: keys.map((key) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: _buildButton(key),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildButton(String key) {
    switch (key) {
      case "C":
        return _functionButton(
          text: "C",
          color: const Color(0xFFFF7043),
          onTap: onClearPressed,
        );

      case "backspace":
        return _backspaceButton();

      default:
        return _numberButton(key);
    }
  }

  Widget _numberButton(String number) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onNumberPressed(number),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF006064),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _functionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _backspaceButton() {
    return Material(
      color: const Color(0xFFECEFF1),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onBackspacePressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade400, width: 1.2),
          ),
          child: const Center(
            child: Icon(
              Icons.backspace_rounded,
              size: 34,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
