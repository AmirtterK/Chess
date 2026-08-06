import 'package:chess_ritter/components/piece.dart';

class MoveRecord {
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
  final ChessPieceType type;
  final bool isWhite;
  final bool took;
  final bool isCheck;
  final bool isCheckmate;
  final bool isStalemate;
  final bool kingCastle;
  final bool queenCastle;
  final ChessPieceType promotionType;

  MoveRecord({
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
    required this.type,
    required this.isWhite,
    this.took = false,
    this.isCheck = false,
    this.isCheckmate = false,
    this.isStalemate = false,
    this.kingCastle = false,
    this.queenCastle = false,
    this.promotionType = ChessPieceType.pawn,
  });

  String get notation {
    if (kingCastle) return 'O-O';
    if (queenCastle) return 'O-O-O';
    final pieceLetter = _pieceToChar(type);
    final capture = took ? 'x' : '';
    final promo = promotionType != ChessPieceType.pawn
        ? '=${_pieceToChar(promotionType)}'
        : '';
    final check = isCheckmate ? '#' : (isCheck ? '+' : '');
    return '$pieceLetter${_colToChar(fromCol)}${8 - fromRow}$capture${_colToChar(toCol)}${8 - toRow}$promo$check';
  }

  String _pieceToChar(ChessPieceType type) {
    switch (type) {
      case ChessPieceType.king:
        return 'K';
      case ChessPieceType.queen:
        return 'Q';
      case ChessPieceType.rook:
        return 'R';
      case ChessPieceType.bishop:
        return 'B';
      case ChessPieceType.knight:
        return 'N';
      case ChessPieceType.pawn:
        return '';
    }
  }

  String _colToChar(int col) => String.fromCharCode(97 + col);
}
