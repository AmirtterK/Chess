
import 'package:chess_game/Components/data.dart';
import 'package:flutter/material.dart';

class Piece extends StatelessWidget {
  final ChessPiece piece;
  const Piece({super.key, required this.piece});

  

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

enum ChessPieceType { king, queen, bishop, rook, knight, pawn }

class ChessPiece {
  final ChessPieceType type;
  final bool isWhite;
  int movesNum=0;
  ChessPiece({required this.type, required this.isWhite});
}

int piecePoint(ChessPiece piece) {
  switch (piece.type) {
    case ChessPieceType.pawn:
      return 1;
    case ChessPieceType.knight:
    case ChessPieceType.bishop:
      return 3;

    case ChessPieceType.queen:
      return 9;

    case ChessPieceType.rook:
      return 5;

    case ChessPieceType.king:
      return 0;
  }
}
String imagePath(ChessPiece piece) {
    switch (piece.type) {
      case ChessPieceType.bishop:
        return piece.isWhite ? "assets/themes/$pieceTheme/wb.png" : "assets/themes/$pieceTheme/bb.png";

      case ChessPieceType.king:
        return piece.isWhite ? "assets/themes/$pieceTheme/wk.png" : "assets/themes/$pieceTheme/bk.png";

      case ChessPieceType.queen:
        return piece.isWhite ? "assets/themes/$pieceTheme/wq.png" : "assets/themes/$pieceTheme/bq.png";

      case ChessPieceType.pawn:
        return piece.isWhite ? "assets/themes/$pieceTheme/wp.png" : "assets/themes/$pieceTheme/bp.png";

      case ChessPieceType.rook:
        return piece.isWhite ? "assets/themes/$pieceTheme/wr.png" : "assets/themes/$pieceTheme/br.png";

      case ChessPieceType.knight:
        return piece.isWhite ? "assets/themes/$pieceTheme/wn.png" : "assets/themes/$pieceTheme/bn.png";
    }
  }

  
