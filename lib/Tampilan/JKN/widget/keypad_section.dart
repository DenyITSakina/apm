import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../responsive/responsive.dart';

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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = ResponsiveUtils.isMobile(context);
          final bool isTablet = ResponsiveUtils.isTablet(context);
          
          return _buildKeypadContent(context, constraints, isMobile, isTablet);
        },
      ),
    );
  }

  Widget _buildKeypadContent(
    BuildContext context, 
    BoxConstraints constraints, 
    bool isMobile, 
    bool isTablet
  ) {
    final double availableHeight = constraints.maxHeight;
    final double buttonHeight = _calculateButtonHeight(availableHeight, isMobile, isTablet);
    final double fontSize = _calculateFontSize(buttonHeight, isMobile, isTablet);
    final double iconSize = _calculateIconSize(buttonHeight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildKeypadRow(['7', '8', '9'], buttonHeight, fontSize),
        _buildKeypadRow(['4', '5', '6'], buttonHeight, fontSize),
        _buildKeypadRow(['1', '2', '3'], buttonHeight, fontSize),
        _buildKeypadRow(['backspace', '0', 'C'], buttonHeight, fontSize, iconSize),
      ],
    );
  }

  double _calculateButtonHeight(double availableHeight, bool isMobile, bool isTablet) {
    final double usableHeight = availableHeight - 36; // Account for padding and spacing
    final double calculatedHeight = usableHeight / 4;
    
    if (isMobile) {
      return calculatedHeight.clamp(60, 85);
    } else if (isTablet) {
      return calculatedHeight.clamp(80, 110);
    } else {
      return calculatedHeight.clamp(90, 140);
    }
  }

  double _calculateFontSize(double buttonHeight, bool isMobile, bool isTablet) {
    final double calculatedSize = buttonHeight * 0.35;
    
    if (isMobile) {
      return calculatedSize.clamp(22, 32);
    } else if (isTablet) {
      return calculatedSize.clamp(28, 42);
    } else {
      return calculatedSize.clamp(32, 50);
    }
  }

  double _calculateIconSize(double buttonHeight) {
    return buttonHeight * 0.35;
  }

  Widget _buildKeypadRow(
    List<String> keys, 
    double buttonHeight, 
    double fontSize, [
    double? iconSize
  ]) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: keys.map((key) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: _buildKeypadButton(key, buttonHeight, fontSize, iconSize),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(
    String key, 
    double buttonHeight, 
    double fontSize, [
    double? iconSize
  ]) {
    switch (key) {
      case 'C':
        return _buildFunctionButton(
          'C', 
          Colors.orange.shade600, 
          onClearPressed, 
          buttonHeight, 
          fontSize
        );
      case 'backspace':
        return _buildBackspaceButton(buttonHeight, iconSize ?? fontSize);
      default:
        return _buildNumberButton(key, buttonHeight, fontSize);
    }
  }

  Widget _buildNumberButton(String number, double buttonHeight, double fontSize) {
    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () => onNumberPressed(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade400, width: 1.5),
          ),
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.2),
        ),
        child: Text(
          number,
          style: GoogleFonts.montserrat(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildFunctionButton(
    String text,
    Color color,
    VoidCallback onPressed,
    double buttonHeight,
    double fontSize,
  ) {
    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: fontSize * 0.85,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(double buttonHeight, double iconSize) {
    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onBackspacePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          foregroundColor: Colors.grey.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade400, width: 1.5),
          ),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        child: Icon(
          Icons.backspace_outlined, 
          size: iconSize,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}