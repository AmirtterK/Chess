import 'package:chess_game/Components/piece.dart';
import 'package:flutter/material.dart';

class Tile extends StatelessWidget {
  final bool isCheck;
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isvalidMove;
  final void Function()? onTap;
  final bool whiteKingChecked;
  const Tile({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
    this.onTap,
    required this.isvalidMove,
    required this.isCheck,
    required this.whiteKingChecked,
  });

  @override
  Widget build(BuildContext context) {
    
    Widget? content = piece != null ? Image.asset(imagePath(piece!)) : null;
    Color tileColor;
    if (isCheck) {
      tileColor = isWhite ? Colors.white70 : Colors.grey.shade600;
      if(whiteKingChecked == piece!.isWhite){

      tileColor = Color.alphaBlend(
          const Color.fromARGB(255, 220, 63, 223).withAlpha(200), tileColor);
      }
    } else if (isSelected) {
      tileColor = isWhite ? Colors.white30 : Colors.grey.shade600;
    } else if (isvalidMove) {
      content = Stack(
        children: [
          if (piece != null) Image.asset(imagePath(piece!)),
          if (piece != null)
            Transform.scale(
                scale: 0.95,
                child: Image.asset(
                  "assets/icons/capture_circle.png",
                  color: const Color.fromARGB(200, 94, 94, 94),
                )),
          if (piece == null)
            Transform.scale(
                scale: 0.4,
                child: ClipOval(
                    child: Container(
                  color: Color.fromARGB(206, 94, 94, 94),
                ))),
        ],
      );
      tileColor = isWhite ? Colors.white70 : Colors.grey.shade600;
    } else {
      tileColor = isWhite ? Colors.white70 : Colors.grey.shade600;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: tileColor,
        child: content,
      ),
    );
  }
}
