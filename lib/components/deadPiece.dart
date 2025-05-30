
import 'package:chess_game/Components/piece.dart';
import 'package:flutter/material.dart';

class DeadPiece extends StatelessWidget {
  final bool isWhite;
  final ChessPiece piece;
  const DeadPiece({super.key, required this.isWhite, required this.piece});

  

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      width: 20,
      height: 20,
      child: Image.asset(imagePath(piece)),
    );
  }
}
