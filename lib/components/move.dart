import 'package:chess_game/Components/piece.dart';

class Moves {
  final String place;
  final ChessPiece piece;
  final bool isWhite;
  Moves(
    this.isWhite, {
    required this.place,
    required this.piece,
  });
  int col(){
    String col=place[0];
     switch (col) {
    case 'a':
      return 0;

    case 'b':
      return 1;
    case 'c':
      return 2;

    case 'd':
      return 3;

    case 'e':
      return 4;

    case 'f':
      return 5;

    case 'g':
      return 6;

    case 'h':
      return 7;

    default:
      return 0;
  }
  }
}

String PieceMoved(int x, int y) {
  switch (y) {
    case 1:
      return "a$x";

    case 2:
      return "b$x";
    case 3:
      return "c$x";

    case 4:
      return "d$x";

    case 5:
      return "e$x";

    case 6:
      return "f$x";

    case 7:
      return "g$x";

    case 8:
      return "h$x";

    default:
      return "";
  }
}
