import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chess_game/Components/Tile.dart';
import 'package:chess_game/Components/data.dart';
import 'package:chess_game/Components/piece.dart';
import 'package:chess_game/Components/move.dart';
import 'package:chess_game/Components/progress.dart';
import 'package:chess_game/Logic/Directions.dart';

import 'package:chess_game/Logic/methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with WidgetsBindingObserver {
  List<List<ChessPiece?>>? Board;
  ChessPiece? selectedPiece;
  int x_selected = -1;
  int y_selected = -1;
  List<List<int>> validMoves = [];
  List<ChessPiece> whitePiecestaken = [];
  List<ChessPiece> blackPiecestaken = [];
  int whiteScore = 0;
  int blackScore = 0;
  bool isWhiteTurn = true;
  bool isCheck = false;
  bool WhiteKingChecked = false;
  List<Moves> moves = [];
  Duration _p1Time = Duration(minutes: times[timeLimit]);
  Duration _p2Time = Duration(minutes: times[timeLimit]);
  final ScrollController _scrollController = ScrollController();
  late Timer _timer;
  bool EnPassent = false;
  bool Casteling = false;
  @override
  void initState() {
    super.initState();
    _initializeBoard();
    if (timeLimit != 0) {
      clock();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (timeLimit != 0) {
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => exitGame(),
      child: SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              children: [
                if (showMoveHistory) ...{
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                    child: SizedBox(
                      height: 30,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController,
                        itemCount: moves.length,
                        itemBuilder: (context, index) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Piece(piece: moves[index].piece),
                            Text(moves[index].place),
                            SizedBox(
                              width: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                },
                Progress(
                    isWhite: whiteDirection == -1 ? false : true,
                    whiteScore: whiteScore,
                    blackScore: blackScore,
                    pTime: whiteDirection == -1 ? _p2Time : _p1Time,
                    piecestaken: whiteDirection == -1
                        ? whitePiecestaken
                        : blackPiecestaken),
                ConstrainedBox(
                  constraints:
                      (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                          ? BoxConstraints()
                          : BoxConstraints(
                              minWidth: 0.0,
                              maxWidth: 500.0,
                              minHeight: 0.0,
                              maxHeight: 737.6,
                            ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: 8 * 8,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8),
                    itemBuilder: (context, index) {
                      int x = index ~/ 8;
                      int y = index % 8;
                      bool isWhite = (x + y) % 2 == 0;
                      bool isSelected = (x == x_selected && y == y_selected);
                      bool isValidMove = false;
                      isValidMove = validMoves
                          .any((move) => move[0] == x && move[1] == y);

                      return Tile(
                        isCheck: (isCheck &&
                            Board![x][y] != null &&
                            Board![x][y]!.type == ChessPieceType.king),
                        whiteKingChecked: WhiteKingChecked,
                        isSelected: isSelected && !isCheck,
                        isWhite: isWhite,
                        isvalidMove: isValidMove,
                        piece: Board![x][y],
                        onTap: () async => await pieceSelected(x, y),
                      );
                    },
                  ),
                ),
                Progress(
                    isWhite: whiteDirection == -1 ? true : false,
                    whiteScore: whiteScore,
                    blackScore: blackScore,
                    pTime: whiteDirection == -1 ? _p1Time : _p2Time,
                    piecestaken: whiteDirection == -1
                        ? blackPiecestaken
                        : whitePiecestaken),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> clock() async {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(
        () {
          if (_p1Time.inSeconds == 0 || _p2Time.inSeconds == 0) {
            _timer.cancel();
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: Text(
                  "Match Over ",
                  style: TextStyle(
                    fontSize: 20,
                    color: const Color.fromARGB(151, 255, 255, 255),
                  ),
                ),
                actions: [
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text(
                      "exit",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 171, 171, 171),
                      ),
                    ),
                    onPressed: () async => {
                      context.pop(),
                      context.replaceNamed("Start"),
                    },
                  ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () async => await Reset(),
                    child: Text(
                      "restart",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 171, 171, 171),
                      ),
                    ),
                  ),
                ],
              ),
            );
            return;
          }

          if (isWhiteTurn) {
            _p1Time -= Duration(seconds: 1);
          } else {
            _p2Time -= Duration(seconds: 1);
          }
        },
      );
    });
  }

  Future<void> pieceSelected(int x, int y) async {
    setState(() {
      if (selectedPiece == null && Board![x][y] != null) {
        if (Board![x][y]!.isWhite == isWhiteTurn) {
          selectedPiece = Board![x][y];
          x_selected = x;
          y_selected = y;
        }
      } else if (Board![x][y] != null &&
          Board![x][y]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = Board![x][y];
        x_selected = x;
        y_selected = y;
      } else if (selectedPiece != null &&
          validMoves.any((move) => move[0] == x && move[1] == y)) {
        MovePiece(x, y);
      } else {
        selectedPiece = null;
        x_selected = -1;
        y_selected = -1;
      }
      validMoves = calculateValidMoves(x, y, selectedPiece, true);
    });
  }

  List<List<int>> calculatePrimaryMoves(
      int x, int y, ChessPiece? selectedPiece) {
    List<List<int>> candidateMoves = [];
    if (selectedPiece == null) {
      return [];
    }

    int direction = selectedPiece.isWhite ? whiteDirection : blackDirection;
    switch (selectedPiece.type) {
      case ChessPieceType.king:
        List<List<int>> directions = kingDirections;
        for (var direction in directions) {
          var row = x + direction[0];
          var col = y + direction[1];
          if (!isOnBoard(row, col)) {
            continue;
          }
          if (Board![row][col] != null) {
            if (Board![row][col]!.isWhite != selectedPiece.isWhite) {
              candidateMoves.add([row, col]);
            }
            continue;
          }
          candidateMoves.add([row, col]);
        }
        if (selectedPiece.type == ChessPieceType.king &&
            selectedPiece.movesNum == 0 &&
            Board![x][y + 1] == null &&
            Board![x][y + 2] == null &&
            Board![x][y + 3]!.type == ChessPieceType.rook &&
            Board![x][y + 3]!.movesNum == 0) {
          candidateMoves.add([x, y + 2]);
        }
        if (selectedPiece.type == ChessPieceType.king &&
            selectedPiece.movesNum == 0 &&
            Board![x][y - 1] == null &&
            Board![x][y - 2] == null &&
            Board![x][y - 3] == null &&
            Board![x][y - 4]!.type == ChessPieceType.rook &&
            Board![x][y - 4]!.movesNum == 0) {
          candidateMoves.add([x, y - 2]);
        }
        break;

      case ChessPieceType.queen:
        List<List<int>> directions = queenDirections;
        for (var direction in directions) {
          int i = 1;
          while (true) {
            var row = x + i * direction[0];
            var col = y + i * direction[1];
            if (!isOnBoard(row, col)) {
              break;
            }
            if (Board![row][col] != null) {
              if (Board![row][col]!.isWhite != selectedPiece.isWhite) {
                candidateMoves.add([row, col]);
              }
              break;
            }
            candidateMoves.add([row, col]);
            i++;
          }
        }
        break;
      case ChessPieceType.rook:
        List<List<int>> directions = rookDirections;
        for (var direction in directions) {
          int i = 1;
          while (true) {
            var row = x + i * direction[0];
            var col = y + i * direction[1];
            if (!isOnBoard(row, col)) {
              break;
            }
            if (Board![row][col] != null) {
              if (Board![row][col]!.isWhite != selectedPiece.isWhite) {
                candidateMoves.add([row, col]);
              }
              break;
            }
            candidateMoves.add([row, col]);
            i++;
          }
        }

        break;
      case ChessPieceType.bishop:
        List<List<int>> directions = bishopDirections;
        for (var direction in directions) {
          int i = 1;
          while (true) {
            var row = x + i * direction[0];
            var col = y + i * direction[1];
            if (!isOnBoard(row, col)) {
              break;
            }
            if (Board![row][col] != null) {
              if (Board![row][col]!.isWhite != selectedPiece.isWhite) {
                candidateMoves.add([row, col]);
              }
              break;
            }
            candidateMoves.add([row, col]);
            i++;
          }
        }
        break;

      case ChessPieceType.knight:
        List<List<int>> directions = knightDirections;
        for (var move in directions) {
          var row = x + move[0];
          var col = y + move[1];
          if (!isOnBoard(row, col)) {
            continue;
          }
          if (Board![row][col] != null) {
            if (Board![row][col]!.isWhite != selectedPiece.isWhite) {
              candidateMoves.add([row, col]);
            }
            continue;
          }
          candidateMoves.add([row, col]);
        }
        break;
      case ChessPieceType.pawn:
        if (isOnBoard(x + direction, y) && Board![x + direction][y] == null) {
          candidateMoves.add([x + direction, y]);
        }
        if ((selectedPiece.isWhite && x == whitefrontLine) ||
            (!selectedPiece.isWhite && x == blackfrontLine)) {
          if (isOnBoard(x + direction * 2, y) &&
              Board![x + direction][y] == null &&
              Board![x + direction * 2][y] == null) {
            candidateMoves.add([x + direction * 2, y]);
          }
        }
        if (isOnBoard(x + direction, y - 1) &&
            Board![x + direction][y - 1] != null &&
            (Board![x + direction][y - 1]!.isWhite != selectedPiece.isWhite)) {
          candidateMoves.add([x + direction, y - 1]);
        }
        if (isOnBoard(x + direction, y + 1) &&
            Board![x + direction][y + 1] != null &&
            (Board![x + direction][y + 1]!.isWhite != selectedPiece.isWhite)) {
          candidateMoves.add([x + direction, y + 1]);
        }
        if (isOnBoard(x + direction, y + 1) &&
            selectedPiece.type == ChessPieceType.pawn &&
            Board![x][y + 1]?.type == ChessPieceType.pawn &&
            selectedPiece.isWhite != Board![x][y + 1]?.isWhite &&
            moves.lastOrNull?.piece.type == ChessPieceType.pawn &&
            moves.last.col() == (y + 1) &&
            Board![x][y + 1]!.movesNum == 1 &&
            (x == 3 || x == 4)) {
          candidateMoves.add([x + direction, y + 1]);
        }
        if (isOnBoard(x + direction, y - 1) &&
            selectedPiece.type == ChessPieceType.pawn &&
            Board![x][y - 1]?.type == ChessPieceType.pawn &&
            selectedPiece.isWhite != Board![x][y - 1]?.isWhite &&
            moves.lastOrNull?.piece.type == ChessPieceType.pawn &&
            moves.last.col() == (y - 1) &&
            Board![x][y - 1]!.movesNum == 1 &&
            (x == 3 || x == 4)) {
          candidateMoves.add([x + direction, y - 1]);
        }
        break;
    }
    return candidateMoves;
  }

  List<List<int>> calculateValidMoves(
      int x, int y, ChessPiece? piece, bool checkHappen) {
    List<List<int>> validMoves = [];
    List<List<int>> primaryMoves = calculatePrimaryMoves(x, y, piece);
    if (checkHappen) {
      for (var move in primaryMoves) {
        int new_x = move[0];
        int new_y = move[1];
        if (selectedPiece!.type == ChessPieceType.pawn &&
            Board![new_x][new_y] == null &&
            (x != new_x && y != new_y)) {
          EnPassent = true;
        }
        if (piece!.type == ChessPieceType.king &&
            (new_y == y + 2 || new_y == y - 2)) {
          Casteling = true;
        }
        if (isMoveSafe(x, y, new_x, new_y, piece, validMoves)) {
          validMoves.add(move);
        }
        Casteling = false;
        EnPassent = false;
      }
    } else {
      return primaryMoves;
    }
    return validMoves;
  }

  bool isMoveSafe(int x, int y, int new_x, int new_y, ChessPiece? piece,
      List<List<int>> onProcessMoves) {
    ChessPiece? originaldestinationPiece = Board![new_x][new_y];
    ChessPiece? SpecialMovePiece;
    List<int>? originalKingPosition;
    if (piece!.type == ChessPieceType.king) {
      if (Casteling) {
        if (new_y == y + 2 && onProcessMoves.any((move) => move[1] == y + 1)) {
          SpecialMovePiece = Board![x][y + 3];
          Board![x][y + 3] = null;
          Board![x][y + 1] = SpecialMovePiece;
        } else if (new_y == y - 2 &&
            onProcessMoves.any((move) => move[1] == y - 1)) {
          SpecialMovePiece = Board![x][y - 4];
          Board![x][y - 4] = null;
          Board![x][y - 1] = SpecialMovePiece;
        } else {
          return false;
        }
      }
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;
      if (piece.isWhite) {
        whiteKingPosition = [new_x, new_y];
      } else {
        blackKingPosition = [new_x, new_y];
      }
    }
    if (EnPassent) {
      int direction = selectedPiece!.isWhite ? whiteDirection : blackDirection;
      SpecialMovePiece = Board![new_x - direction][new_y];
      Board![new_x - direction][new_y] = null;
    }

    Board![new_x][new_y] = piece;
    Board![x][y] = null;
    bool isCheck = isKingCheck(piece.isWhite);
    Board![x][y] = piece;
    Board![new_x][new_y] = originaldestinationPiece;
    if (EnPassent) {
      int direction = selectedPiece!.isWhite ? whiteDirection : blackDirection;
      Board![new_x - direction][new_y] = SpecialMovePiece;
    }
    if (Casteling) {
      if (new_y == y + 2) {
        Board![x][y + 3] = SpecialMovePiece;
        Board![x][y + 1] = null;
        SpecialMovePiece = null;
      } else if (new_y == y - 2) {
        Board![x][y - 4] = SpecialMovePiece;
        Board![x][y - 1] = null;
        SpecialMovePiece = null;
      }
    }
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }
    return !isCheck;
  }

  Future<void> _initializeBoard() async {
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));
    for (var i = 0; i < 8; i++) {
      newBoard[whitefrontLine][i] =
          ChessPiece(type: ChessPieceType.pawn, isWhite: true);
      newBoard[blackfrontLine][i] =
          ChessPiece(type: ChessPieceType.pawn, isWhite: false);
    }
    newBoard[whitebackLine][0] =
        ChessPiece(type: ChessPieceType.rook, isWhite: true);
    newBoard[whitebackLine][7] =
        ChessPiece(type: ChessPieceType.rook, isWhite: true);
    newBoard[whitebackLine][1] =
        ChessPiece(type: ChessPieceType.knight, isWhite: true);
    newBoard[whitebackLine][6] =
        ChessPiece(type: ChessPieceType.knight, isWhite: true);
    newBoard[whitebackLine][2] =
        ChessPiece(type: ChessPieceType.bishop, isWhite: true);
    newBoard[whitebackLine][5] =
        ChessPiece(type: ChessPieceType.bishop, isWhite: true);
    newBoard[whitebackLine][4] =
        ChessPiece(type: ChessPieceType.king, isWhite: true);
    newBoard[whitebackLine][3] =
        ChessPiece(type: ChessPieceType.queen, isWhite: true);
    newBoard[blackbackLine][0] =
        ChessPiece(type: ChessPieceType.rook, isWhite: false);
    newBoard[blackbackLine][7] =
        ChessPiece(type: ChessPieceType.rook, isWhite: false);
    newBoard[blackbackLine][1] =
        ChessPiece(type: ChessPieceType.knight, isWhite: false);
    newBoard[blackbackLine][6] =
        ChessPiece(type: ChessPieceType.knight, isWhite: false);
    newBoard[blackbackLine][2] =
        ChessPiece(type: ChessPieceType.bishop, isWhite: false);
    newBoard[blackbackLine][5] =
        ChessPiece(type: ChessPieceType.bishop, isWhite: false);
    newBoard[blackbackLine][4] =
        ChessPiece(type: ChessPieceType.king, isWhite: false);
    newBoard[blackbackLine][3] =
        ChessPiece(type: ChessPieceType.queen, isWhite: false);

    Board = newBoard;
  }

  Future<void> MovePiece(int x, int y) async {
    bool kill = false;
    if (Board![x][y] != null) {
      if (Board![x][y]!.isWhite) {
        whitePiecestaken.add(Board![x][y]!);
        blackScore += piecePoint(Board![x][y]!);
      } else {
        blackPiecestaken.add(Board![x][y]!);
        whiteScore += piecePoint(Board![x][y]!);
      }

      kill = true;
      AudioPlayer().play(AssetSource('sounds/capture.mp3')).then((_) {
        AudioPlayer().release();
      });
    } else if (selectedPiece?.type == ChessPieceType.pawn && y_selected != y) {
      int direction = selectedPiece!.isWhite ? whiteDirection : blackDirection;
      if (Board![x - direction][y]!.isWhite) {
        whitePiecestaken.add(Board![x - direction][y]!);
        blackScore += piecePoint(Board![x - direction][y]!);
      } else {
        blackPiecestaken.add(Board![x - direction][y]!);
        whiteScore += piecePoint(Board![x - direction][y]!);
      }
      Board![x - direction][y] = null;
      kill = true;
      AudioPlayer().play(AssetSource('sounds/capture.mp3')).then((_) {
        AudioPlayer().release();
      });
    }
    Board![x][y] = selectedPiece;
    moves.add(Moves(selectedPiece!.isWhite,
        place: PieceMoved(7 - x + 1, y + 1), piece: selectedPiece!));
    selectedPiece!.movesNum++;
    Board![x_selected][y_selected] = null;
    if (selectedPiece!.type == ChessPieceType.pawn && (x == 0 || x == 7)) {
      promotePawn(x, y, selectedPiece!.isWhite);
    }
    if (selectedPiece!.type == ChessPieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [x, y];
      } else {
        blackKingPosition = [x, y];
      }
    }
    if (isKingCheck(!isWhiteTurn)) {
      isCheck = true;

      AudioPlayer().play(AssetSource('sounds/move-check.mp3')).then((_) {
        AudioPlayer().release();
      });
    } else {
      isCheck = false;
      if (!(selectedPiece!.type == ChessPieceType.pawn && (x == 0 || x == 7))) {
        if (!kill) {
          AudioPlayer().play(AssetSource('sounds/move-self.mp3')).then((_) {
            AudioPlayer().release();
          });
        }
      }
    }

    setState(() {
      selectedPiece = null;
      x_selected = -1;
      y_selected = -1;
      validMoves = [];
    });
    if (isCheckMate(!isWhiteTurn)) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(
            "checkmate",
            style: TextStyle(
              fontSize: 20,
              color: const Color.fromARGB(151, 255, 255, 255),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(
                "exit",
                style: TextStyle(
                  color: const Color.fromARGB(255, 171, 171, 171),
                ),
              ),
              onPressed: () async => {
                context.pop(),
                context.replaceNamed("Start"),
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async => await Reset(),
              child: Text(
                "restart",
                style: TextStyle(
                  color: const Color.fromARGB(255, 171, 171, 171),
                ),
              ),
            ),
          ],
        ),
      );
    }
    isWhiteTurn = !isWhiteTurn;
    if (isCheck) {
      isWhiteKingChecked(isWhiteTurn);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> promotePawn(int x, int y, bool isWhite) async {
    ChessPiece queen = ChessPiece(type: ChessPieceType.queen, isWhite: isWhite);
    ChessPiece bishop =
        ChessPiece(type: ChessPieceType.bishop, isWhite: isWhite);
    ChessPiece rook = ChessPiece(type: ChessPieceType.rook, isWhite: isWhite);
    ChessPiece knight =
        ChessPiece(type: ChessPieceType.knight, isWhite: isWhite);

    AudioPlayer().play(AssetSource('sounds/promote.mp3')).then((_) {
      AudioPlayer().release();
    });
    await showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Center(
          child: CupertinoActionSheet(
            title: Text(
              "Promote",
              style: TextStyle(
                fontSize: 20,
                color: const Color.fromARGB(255, 171, 171, 171),
              ),
            ),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () => {
                  setState(() {
                    Board![x][y] = queen;
                  }),
                  context.pop(),
                },
                child: Row(
                  children: [
                    Text(
                      "Queen",
                      style: TextStyle(
                          color: const Color.fromARGB(215, 255, 255, 255)),
                    ),
                    Spacer(),
                    Image.asset(
                      imagePath(queen),
                      width: 30,
                      height: 30,
                    )
                  ],
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () => {
                  setState(() {
                    Board![x][y] = bishop;
                  }),
                  context.pop(),
                },
                child: Row(
                  children: [
                    Text(
                      "Bishop",
                      style: TextStyle(
                          color: const Color.fromARGB(215, 255, 255, 255)),
                    ),
                    Spacer(),
                    Image.asset(
                      imagePath(bishop),
                      width: 30,
                      height: 30,
                    )
                  ],
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () => {
                  setState(() {
                    Board![x][y] = rook;
                  }),
                  context.pop(),
                },
                child: Row(
                  children: [
                    Text(
                      "Rook",
                      style: TextStyle(
                          color: const Color.fromARGB(215, 255, 255, 255)),
                    ),
                    Spacer(),
                    Image.asset(
                      imagePath(rook),
                      width: 30,
                      height: 30,
                    )
                  ],
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () => {
                  setState(() {
                    Board![x][y] = knight;
                  }),
                  context.pop(),
                },
                child: Row(
                  children: [
                    Text(
                      "Knight",
                      style: TextStyle(
                          color: const Color.fromARGB(215, 255, 255, 255)),
                    ),
                    Spacer(),
                    Image.asset(
                      imagePath(knight),
                      width: 30,
                      height: 30,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isKingCheck(bool isWhiteKing) {
    List<int> KingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;
    for (var i = 0; i < 8; i++) {
      for (var j = 0; j < 8; j++) {
        if (Board![i][j] == null || Board![i][j]!.isWhite == isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateValidMoves(i, j, Board![i][j], false);
        if (pieceValidMoves.any((move) =>
            KingPosition[0] == move[0] && KingPosition[1] == move[1])) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> isWhiteKingChecked(bool isWhiteturn) async {
    setState(() {
      if (isWhiteturn) {
        WhiteKingChecked = true;
      } else {
        WhiteKingChecked = false;
      }
    });
  }

  bool isCheckMate(bool isWhiteKing) {
    if (!isKingCheck(isWhiteKing)) return false;
    for (var i = 0; i < 8; i++) {
      for (var j = 0; j < 8; j++) {
        if (Board![i][j] == null || Board![i][j]!.isWhite != isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateValidMoves(i, j, Board![i][j], true);
        if (pieceValidMoves.isNotEmpty) return false;
      }
    }
    return true;
  }

  Future<void> Reset() async {
    Navigator.pop(context);
    _initializeBoard();
    selectedPiece = null;
    x_selected = -1;
    y_selected = -1;
    validMoves.clear();
    whitePiecestaken.clear();
    blackPiecestaken.clear();
    whiteScore = 0;
    blackScore = 0;
    isWhiteTurn = true;
    if (whiteDirection == -1) {
      blackKingPosition = [0, 4];
      whiteKingPosition = [7, 4];
    } else {
      blackKingPosition = [7, 4];
      whiteKingPosition = [0, 4];
    }
    isCheck = false;
    WhiteKingChecked = false;
    moves.clear();
    _p1Time = Duration(minutes: times[timeLimit]);
    _p2Time = Duration(minutes: times[timeLimit]);
    if (timeLimit != 0) {
      _timer.cancel();

      clock();
    }
    setState(() {});
  }

  Future<void> exitGame() async {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          "exit match",
          style: TextStyle(
            fontSize: 20,
            color: const Color.fromARGB(151, 255, 255, 255),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(
              "exit",
              style: TextStyle(
                color: const Color.fromARGB(255, 171, 171, 171),
              ),
            ),
            onPressed: () async => {
              context.pop(),
              context.replaceNamed("Start"),
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async => context.pop(),
            child: Text(
              "Continue",
              style: TextStyle(
                color: const Color.fromARGB(255, 171, 171, 171),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
