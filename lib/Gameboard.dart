import 'package:audioplayers/audioplayers.dart';
import 'package:chess_game/components/DeadPiece.dart';
import 'package:chess_game/components/Tile.dart';
import 'package:chess_game/components/move.dart';
import 'package:chess_game/components/piece.dart';
import 'package:chess_game/methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chess_game/components/data.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      DeadPiece(
                          isWhite: moves[index].isWhite,
                          piece: moves[index].piece),
                      Text(moves[index].place),
                      SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10),
              child: SizedBox(
                height: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.start,
                      children: whitePiecestaken
                          .map(
                              (piece) => DeadPiece(isWhite: true, piece: piece))
                          .toList(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (blackScore > whiteScore)
                      Text("+${blackScore - whiteScore}"),
                  ],
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) {
                int x = index ~/ 8;
                int y = index % 8;
                bool isWhite = (x + y) % 2 == 0;
                bool isSelected = (x == x_selected && y == y_selected);
                bool isValidMove = false;
                for (var move in validMoves) {
                  if (move[0] == x && move[1] == y) isValidMove = true;
                }
                return Center(
                  child: Tile(
                    isCheck: (isCheck &&
                        Board![x][y] != null &&
                        Board![x][y]!.type == ChessPieceType.king),
                    whiteKingChecked: WhiteKingChecked,
                    isSelected: isSelected && !isCheck,
                    isWhite: isWhite,
                    isvalidMove: isValidMove,
                    piece: Board![x][y],
                    onTap: () async => await pieceSelected(x, y),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10),
              child: SizedBox(
                height: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.start,
                      children: blackPiecestaken
                          .map((piece) =>
                              DeadPiece(isWhite: false, piece: piece))
                          .toList(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (whiteScore > blackScore)
                      Text("+${whiteScore - blackScore}"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [1, 1],
          [1, -1],
          [-1, 1],
        ];
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
        break;

      case ChessPieceType.queen:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [1, 1],
          [1, -1],
          [-1, 1],
        ];
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
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
        ];
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
        var directions = [
          [-1, -1],
          [1, 1],
          [1, -1],
          [-1, 1],
        ];
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
        var directions = [
          [-2, -1],
          [2, 1],
          [-2, 1],
          [2, -1],
          [-1, -2],
          [1, 2],
          [-1, 2],
          [1, -2],
        ];
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
        if (isMoveSafe(x, y, new_x, new_y, piece)) {
          validMoves.add(move);
        }
      }
    } else {
      return primaryMoves;
    }
    return validMoves;
  }

  bool isMoveSafe(int x, int y, int new_x, int new_y, ChessPiece? piece) {
    ChessPiece? originaldestinationPiece = Board![new_x][new_y];
    List<int>? originalKingPosition;
    if (piece!.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;
      if (piece.isWhite) {
        whiteKingPosition = [new_x, new_y];
      } else {
        blackKingPosition = [new_x, new_y];
      }
    }
    Board![new_x][new_y] = piece;
    Board![x][y] = null;
    bool isCheck = isKingCheck(piece.isWhite);
    Board![x][y] = piece;
    Board![new_x][new_y] = originaldestinationPiece;
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
    }
    Board![x][y] = selectedPiece;
    moves.add(Moves(selectedPiece!.isWhite,
        place: PieceMoved(7 - x + 1, y + 1), piece: selectedPiece!));
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
              child: Text(
                "exit",
                style: TextStyle(
                  color: Color.fromARGB(255, 171, 171, 171),
                ),
              ),
              onPressed: () async => {
                context.pop(),
                context.replaceNamed("Start"),
              },
            ),
            CupertinoDialogAction(
              onPressed: () async => await Reset(),
              child: Text(
                "restart",
                style: TextStyle(
                  color: Color.fromARGB(255, 171, 171, 171),
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
                color: Color.fromARGB(255, 171, 171, 171),
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
    setState(() {});
  }
}
