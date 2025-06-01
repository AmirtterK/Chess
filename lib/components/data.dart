import 'package:chess_game/Components/piece.dart';
import 'package:flutter/material.dart';

String pieceTheme = "neon";
int selectedThemeIndex =5;
int whitefrontLine = 6;
int whitebackLine = 7;
int blackfrontLine = 1;
int blackbackLine = 0;
int whiteDirection = -1;
int blackDirection = 1;
int startingColor = 0;
int timeLimit = 0;
List<int> times = [0,10,15,30];
List<int> blackKingPosition = [0, 4];
List<int> whiteKingPosition = [7, 4];
bool showHints=true;
bool showMoveHistory=true;
final Map<int, Widget> startingColorsOptions = const <int, Widget>{
  0: Text( 
    "white",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
  1: Text(
    "black",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
  2: Text(
    "random",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
};
final Map<int, Widget> timeLimitOptions = const <int, Widget>{
  0: Text(
    "none",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
  1: Text(
    "10m",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
  2: Text(
    "15m",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
  3: Text(
    "30m",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
};
final List<Widget> themesList = [
  Text(
    "alpha",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
  Text(
    "clasic",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
  Text(
    "dash",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
  Text(
    "game_room",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
  Text(
    "glass",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
  Text(
    "light",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
  Text(
    "marble",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
  Text(
    "metal",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
  Text(
    "neon",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
  Text(
    "newspaper",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
  Text(
    "tournament",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
  Text(
    "wood",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
      fontSize: 17
    ),
  ),
];
final List<String> themes = [
  "alpha",
  "classic",
  "dash",
  "game_room",
  "glass",
  "light",
  "marble",
  "metal",
  "neon",
  "newspaper",
  "tournament",
  "wood",
];

void startWhite() {
  whitefrontLine = 6;
  whitebackLine = 7;
  blackfrontLine = 1;
  blackbackLine = 0;
  whiteDirection = -1;
  blackDirection = 1;
  blackKingPosition = [0, 4];
  whiteKingPosition = [7, 4];
}

void startBlack() {
  whitefrontLine = 1;
  whitebackLine = 0;
  blackfrontLine = 6;
  blackbackLine = 7;
  whiteDirection = 1;
  blackDirection = -1;
  blackKingPosition = [7, 4];
  whiteKingPosition = [0, 4];
}


List<ChessPiece> pieces =[
  ChessPiece(type: ChessPieceType.king, isWhite: false),
  ChessPiece(type: ChessPieceType.queen, isWhite:true),
  ChessPiece(type: ChessPieceType.bishop, isWhite: true),
  ChessPiece(type: ChessPieceType.knight, isWhite: false),
  ChessPiece(type: ChessPieceType.pawn, isWhite: false),
  ChessPiece(type: ChessPieceType.rook, isWhite: true),
];