import 'package:flutter/material.dart';

import 'package:chess_ritter/components/piece.dart';

class Tile extends StatelessWidget {
  final bool isDark;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final bool isCheck;
  final bool showHints;
  final String pieceTheme;
  final bool rotatePieces;
  final void Function()? onTap;

  const Tile({
    super.key,
    required this.isDark,
    required this.piece,
    required this.isSelected,
    required this.isValidMove,
    required this.isCheck,
    required this.showHints,
    required this.pieceTheme,
    required this.rotatePieces,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = isDark ? const Color(0xFF5D5A60) : const Color(0xFFE9E6EA);
    final selectedColor = isSelected
        ? Color.alphaBlend(const Color(0x80DC3FDF), background)
        : background;
    final checkColor = isCheck
        ? Color.alphaBlend(const Color(0x88E63946), selectedColor)
        : selectedColor;
    Widget? content;
    if (piece != null) {
      content = Center(
        child: Piece(
          piece: piece!,
          theme: pieceTheme,
          rotated: rotatePieces,
        ),
      );
    }
    if (isValidMove && showHints) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          if (piece != null)
            Piece(
              piece: piece!,
              theme: pieceTheme,
              rotated: rotatePieces,
            ),
          if (piece == null)
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xAA4A4A4A),
                shape: BoxShape.circle,
              ),
            )
          else
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xAA4A4A4A),
                  width: 4,
                ),
              ),
            ),
        ],
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: checkColor,
        child: content,
      ),
    );
  }
}
