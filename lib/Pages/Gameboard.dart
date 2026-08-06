import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:chess_ritter/components/Tile.dart';
import 'package:chess_ritter/components/piece.dart';
import 'package:chess_ritter/components/progress.dart';
import 'package:chess_ritter/state/chess_app_state.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  bool _promotionDialogShown = false;
  bool _gameOverDialogShown = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final theme = appState.theme;
        final isTwoPlayer = appState.gameMode == GameMode.localTwoPlayer;
        final boardRotated = isTwoPlayer && appState.enableRotation && !appState.whiteTurn;
        final pieceRotated = isTwoPlayer && !appState.enableRotation &&
            appState.enablePieceRotation &&
            !appState.whiteTurn;

        if (appState.promotionPending && !_promotionDialogShown) {
          _promotionDialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => _showPromotionDialog(context));
        }
        if (appState.gameOver && !_gameOverDialogShown) {
          _gameOverDialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => _showGameOverDialog(context));
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) => _confirmExit(context),
          child: Scaffold(
            extendBody: true,
            resizeToAvoidBottomInset: false,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(gradient: theme.background),
              child: SafeArea(
                child: Column(
                  children: [
                    if (appState.showMoveHistory) _MoveStrip(onResume: _resumeLiveGame),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Progress(
                        whiteOnBottom: appState.humanPlaysWhite,
                        topLabel: _playerLabel(
                          isWhite: !appState.humanPlaysWhite,
                        ),
                        bottomLabel: _playerLabel(
                          isWhite: appState.humanPlaysWhite,
                        ),
                        whiteScore: appState.whiteScore,
                        blackScore: appState.blackScore,
                        whiteTime: appState.whiteTime,
                        blackTime: appState.blackTime,
                        capturedWhite: appState.whiteCaptured,
                        capturedBlack: appState.blackCaptured,
                        pieceTheme: appState.pieceTheme,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GridView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: 64,
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 8,
                                            ),
                                            itemBuilder: (context, index) {
                                              final displayRow = index ~/ 8;
                                              final displayCol = index % 8;
                                              final boardRow = boardRotated ? 7 - displayRow : displayRow;
                                              final boardCol = boardRotated ? 7 - displayCol : displayCol;
                                              final piece = appState.board[boardRow][boardCol];
                                              final isDark = (boardRow + boardCol).isOdd;
                                              final isSelected = appState.selectedRow == boardRow &&
                                                  appState.selectedCol == boardCol;
                                              final isValidMove = appState.validMoves.any(
                                                (move) => move[0] == boardRow && move[1] == boardCol,
                                              );
                                              final isCheck = appState.whiteKingChecked &&
                                                  piece != null &&
                                                  piece.type == ChessPieceType.king &&
                                                  piece.isWhite == appState.whiteTurn;

                                              return Tile(
                                                isDark: isDark,
                                                piece: piece,
                                                isSelected: isSelected,
                                                isValidMove: isValidMove,
                                                isCheck: isCheck,
                                                showHints: appState.showHints,
                                                pieceTheme: appState.pieceTheme,
                                                rotatePieces: pieceRotated,
                                                onTap: () => appState.selectSquare(boardRow, boardCol),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                      child: Column(
                        children: [
                          _ControlBar(
                            onUndo: appState.allowUndoRedo ? appState.undoMove : null,
                            onRedo: appState.allowUndoRedo ? appState.redoMove : null,
                            onRestart: _restartGame,
                            onExit: () => _confirmExit(context),
                            onResume: appState.usingHistory ? _resumeLiveGame : null,
                            undoEnabled: appState.allowUndoRedo && appState.moves.isNotEmpty && !appState.usingHistory,
                            redoEnabled: appState.allowUndoRedo && !appState.usingHistory,
                            showResume: appState.usingHistory,
                            status: appState.gameOver
                                ? (appState.stalemate ? 'Stalemate' : 'Game over')
                                : appState.promotionPending
                                    ? 'Choose promotion piece'
                                    : appState.usingHistory
                                        ? 'History review mode'
                                        : appState.aiThinking
                                            ? '${appState.aiName} is thinking...'
                                            : (appState.whiteTurn ? 'White to move' : 'Black to move'),
                            accent: theme.accent,
                          ),
                        ],
                      ),
                    ),
                    ],
                  ),
                ),
            ),
          ),
        );
      },
    );
  }

  String _playerLabel({required bool isWhite}) {
    if (appState.gameMode == GameMode.localTwoPlayer) {
      return isWhite ? 'White' : 'Black';
    }
    final isHuman = isWhite == appState.humanPlaysWhite;
    return isHuman ? 'Player' : appState.aiName;
  }

  void _resumeLiveGame() {
    appState.returnToLiveGame();
    setState(() {
      _gameOverDialogShown = false;
      _promotionDialogShown = false;
    });
  }

  void _restartGame() {
    appState.newGame();
    setState(() {
      _gameOverDialogShown = false;
      _promotionDialogShown = false;
    });
  }

  Future<void> _confirmExit(BuildContext context) async {
    if (appState.usingHistory) {
      _resumeLiveGame();
      return;
    }
    await showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Exit game?', style: TextStyle(fontFamily: 'queen')),
        content: const Text(
          'Your current position will be saved for later resume.',
          style: TextStyle(fontFamily: 'queen'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'queen')),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(dialogContext);
              appState.saveGame();
              context.goNamed('Start');
            },
            child: const Text('Exit', style: TextStyle(fontFamily: 'queen')),
          ),
        ],
      ),
    );
  }

  Future<void> _showPromotionDialog(BuildContext context) async {
    await showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final options = [
          (ChessPieceType.queen, 'Queen'),
          (ChessPieceType.rook, 'Rook'),
          (ChessPieceType.bishop, 'Bishop'),
          (ChessPieceType.knight, 'Knight'),
        ];
        return CupertinoAlertDialog(
          title: const Text('Promote pawn', style: TextStyle(fontFamily: 'queen')),
          content: const Text(
            'Choose the piece you want.',
            style: TextStyle(fontFamily: 'queen'),
          ),
          actions: [
            for (final option in options)
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  appState.completePromotion(option.$1);
                  setState(() => _promotionDialogShown = false);
                },
                child: Text(option.$2, style: const TextStyle(fontFamily: 'queen')),
              ),
          ],
        );
      },
    );
    if (mounted) {
      setState(() => _promotionDialogShown = false);
    }
  }

  Future<void> _showGameOverDialog(BuildContext context) async {
    await showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(
          appState.stalemate ? 'Stalemate' : 'Game over',
          style: const TextStyle(fontFamily: 'queen'),
        ),
        content: Text(
          appState.stalemate
              ? 'The game ended in a draw.'
              : (appState.whiteTurn ? 'Black wins.' : 'White wins.'),
          style: const TextStyle(fontFamily: 'queen'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(dialogContext);
              appState.newGame();
              setState(() {
                _gameOverDialogShown = false;
                _promotionDialogShown = false;
              });
            },
            child: const Text('Restart', style: TextStyle(fontFamily: 'queen')),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(dialogContext);
              appState.saveGame();
              context.goNamed('Start');
            },
            child: const Text('Exit', style: TextStyle(fontFamily: 'queen')),
          ),
        ],
      ),
    );
    if (mounted) {
      setState(() => _gameOverDialogShown = false);
    }
  }
}

class _MoveStrip extends StatefulWidget {
  final VoidCallback onResume;
  const _MoveStrip({required this.onResume});

  @override
  State<_MoveStrip> createState() => _MoveStripState();
}

class _MoveStripState extends State<_MoveStrip> {
  final ScrollController _moveController = ScrollController();

  void _showLatestMove() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _moveController.hasClients) {
        _moveController.animateTo(
          _moveController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant _MoveStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _showLatestMove();
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _showLatestMove();
    return Container(
      height: 48,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        controller: _moveController,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        itemBuilder: (context, index) {
          final move = appState.moves[index];
          final selected = appState.historyViewIndex == index + 1;
          return GestureDetector(
            onTap: () => appState.selectHistoryIndex(index + 1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                move.notation,
                style: const TextStyle(fontSize: 13, fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: appState.moves.length,
      ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback onRestart;
  final VoidCallback onExit;
  final VoidCallback? onResume;
  final bool undoEnabled;
  final bool redoEnabled;
  final bool showResume;
  final String status;
  final Color accent;

  const _ControlBar({
    required this.onUndo,
    required this.onRedo,
    required this.onRestart,
    required this.onExit,
    required this.onResume,
    required this.undoEnabled,
    required this.redoEnabled,
    required this.showResume,
    required this.status,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _PanelButton(
                label: showResume ? 'Resume' : status,
                enabled: showResume,
                onPressed: onResume,
                accent: accent,
              ),
            ),
            const SizedBox(width: 10),
            _IconPanelButton(
              icon: CupertinoIcons.arrow_uturn_left,
              enabled: undoEnabled,
              onPressed: onUndo,
              accent: accent,
            ),
            const SizedBox(width: 10),
            _IconPanelButton(
              icon: CupertinoIcons.arrow_uturn_right,
              enabled: redoEnabled,
              onPressed: onRedo,
              accent: accent,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _PanelButton(
                label: 'Restart',
                icon: CupertinoIcons.restart,
                enabled: true,
                onPressed: onRestart,
                accent: accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PanelButton(
                label: 'Exit',
                icon: CupertinoIcons.square_arrow_right,
                enabled: true,
                onPressed: onExit,
                accent: const Color(0xFFFC5C5C),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PanelButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool enabled;
  final VoidCallback? onPressed;
  final Color accent;

  const _PanelButton({
    required this.label,
    this.icon,
    required this.enabled,
    required this.onPressed,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: enabled ? onPressed : null,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: enabled ? Colors.white.withValues(alpha: 0.10) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: enabled ? accent : Colors.white38),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'queen',
                color: enabled ? accent : Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconPanelButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onPressed;
  final Color accent;

  const _IconPanelButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: enabled ? onPressed : null,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: enabled ? Colors.white.withValues(alpha: 0.10) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, size: 18, color: enabled ? accent : Colors.white38),
      ),
    );
  }
}
