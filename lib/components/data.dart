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
final Map<int, Widget> startingColorsOptions = const <int, Widget>{
  0: Text( 
    "white",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
  1: Text(
    "black",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
  2: Text(
    "random",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
};
final Map<int, Widget> timeLimitOptions = const <int, Widget>{
  0: Text(
    "none",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
  1: Text(
    "10m",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
  2: Text(
    "15m",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
  3: Text(
    "30m",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
};
final List<Widget> themesList = [
  Text(
    "alpha",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
  Text(
    "clasic",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
  Text(
    "dash",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
  Text(
    "game_room",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
  Text(
    "glass",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
  Text(
    "light",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
  Text(
    "marble",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
  Text(
    "metal",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
  Text(
    "neon",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
  Text(
    "newspaper",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
  Text(
    "tournament",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
    ),
  ),
  Text(
    "wood",
    style: TextStyle(
      color: Color.fromARGB(255, 171, 171, 171),
      fontFamily: "queen",
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