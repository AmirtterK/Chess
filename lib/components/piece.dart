
import 'package:flutter/material.dart';

enum ChessPieceType { king, queen, bishop, rook, knight, pawn }

class ChessPiece {
  final ChessPieceType type;
  final bool isWhite;
  int movesNum = 0;

  ChessPiece({required this.type, required this.isWhite});

  ChessPiece copy() {
    return ChessPiece(type: type, isWhite: isWhite)..movesNum = movesNum;
  }

  String get code {
    final color = isWhite ? 'w' : 'b';
    switch (type) {
      case ChessPieceType.king:
        return '${color}k';
      case ChessPieceType.queen:
        return '${color}q';
      case ChessPieceType.bishop:
        return '${color}b';
      case ChessPieceType.rook:
        return '${color}r';
      case ChessPieceType.knight:
        return '${color}n';
      case ChessPieceType.pawn:
        return '${color}p';
    }
  }

  static ChessPiece? fromCode(String? code) {
    if (code == null) return null;
    if (code.length != 2) return null;
    final isWhite = code.startsWith('w');
    switch (code[1]) {
      case 'k':
        return ChessPiece(type: ChessPieceType.king, isWhite: isWhite);
      case 'q':
        return ChessPiece(type: ChessPieceType.queen, isWhite: isWhite);
      case 'b':
        return ChessPiece(type: ChessPieceType.bishop, isWhite: isWhite);
      case 'r':
        return ChessPiece(type: ChessPieceType.rook, isWhite: isWhite);
      case 'n':
        return ChessPiece(type: ChessPieceType.knight, isWhite: isWhite);
      case 'p':
        return ChessPiece(type: ChessPieceType.pawn, isWhite: isWhite);
      default:
        return null;
    }
  }
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

String imagePath(ChessPiece piece, {required String theme}) {
    switch (piece.type) {
      case ChessPieceType.bishop:
        return piece.isWhite ? "assets/themes/$theme/wb.png" : "assets/themes/$theme/bb.png";

      case ChessPieceType.king:
        return piece.isWhite ? "assets/themes/$theme/wk.png" : "assets/themes/$theme/bk.png";

      case ChessPieceType.queen:
        return piece.isWhite ? "assets/themes/$theme/wq.png" : "assets/themes/$theme/bq.png";

      case ChessPieceType.pawn:
        return piece.isWhite ? "assets/themes/$theme/wp.png" : "assets/themes/$theme/bp.png";

      case ChessPieceType.rook:
        return piece.isWhite ? "assets/themes/$theme/wr.png" : "assets/themes/$theme/br.png";

      case ChessPieceType.knight:
        return piece.isWhite ? "assets/themes/$theme/wn.png" : "assets/themes/$theme/bn.png";
    }
  }

class Piece extends StatelessWidget {
  final ChessPiece piece;
  final String theme;
  final bool rotated;
  final double size;
  const Piece({
    super.key,
    required this.piece,
    required this.theme,
    this.rotated = false,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Transform.rotate(
        angle: rotated ? 3.1415926535897932 : 0,
        child: Image.asset(imagePath(piece, theme: theme)),
      ),
    );
  }
}
