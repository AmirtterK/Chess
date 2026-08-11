import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chess_ritter/Logic/Directions.dart';
import 'package:chess_ritter/components/move.dart';
import 'package:chess_ritter/components/piece.dart';
import 'package:chess_ritter/services/feedback_service.dart';

import 'app_theme.dart';

enum GameMode { localTwoPlayer, vsAi }

class MoveCandidate {
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
  final ChessPiece piece;

  const MoveCandidate({
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
    required this.piece,
  });
}

class GameSnapshot {
  final List<List<ChessPiece?>> board;
  final List<MoveRecord> moves;
  final List<ChessPiece> whiteCaptured;
  final List<ChessPiece> blackCaptured;
  final bool whiteTurn;
  final bool gameOver;
  final bool stalemate;
  final int whiteScore;
  final int blackScore;
  final Duration whiteTime;
  final Duration blackTime;
  final List<int> whiteKingPosition;
  final List<int> blackKingPosition;
  final int whiteFrontLine;
  final int whiteBackLine;
  final int blackFrontLine;
  final int blackBackLine;
  final int whiteDirection;
  final int blackDirection;
  final GameMode gameMode;
  final bool humanPlaysWhite;
  final int aiDifficulty;
  final int availableUndos;

  const GameSnapshot({
    required this.board,
    required this.moves,
    required this.whiteCaptured,
    required this.blackCaptured,
    required this.whiteTurn,
    required this.gameOver,
    required this.stalemate,
    required this.whiteScore,
    required this.blackScore,
    required this.whiteTime,
    required this.blackTime,
    required this.whiteKingPosition,
    required this.blackKingPosition,
    required this.whiteFrontLine,
    required this.whiteBackLine,
    required this.blackFrontLine,
    required this.blackBackLine,
    required this.whiteDirection,
    required this.blackDirection,
    required this.gameMode,
    required this.humanPlaysWhite,
    required this.aiDifficulty,
    required this.availableUndos,
  });

  Map<String, dynamic> toJson() {
    return {
      'board': board
          .map((row) => row.map((piece) => piece?.code).toList())
          .toList(),
      'moves': moves
          .map(
            (m) => {
              'fromRow': m.fromRow,
              'fromCol': m.fromCol,
              'toRow': m.toRow,
              'toCol': m.toCol,
              'type': m.type.index,
              'isWhite': m.isWhite,
              'took': m.took,
              'isCheck': m.isCheck,
              'isCheckmate': m.isCheckmate,
              'isStalemate': m.isStalemate,
              'kingCastle': m.kingCastle,
              'queenCastle': m.queenCastle,
              'promotionType': m.promotionType.index,
            },
          )
          .toList(),
      'whiteCaptured': whiteCaptured.map((piece) => piece.code).toList(),
      'blackCaptured': blackCaptured.map((piece) => piece.code).toList(),
      'whiteTurn': whiteTurn,
      'gameOver': gameOver,
      'stalemate': stalemate,
      'whiteScore': whiteScore,
      'blackScore': blackScore,
      'whiteTime': whiteTime.inSeconds,
      'blackTime': blackTime.inSeconds,
      'whiteKingPosition': whiteKingPosition,
      'blackKingPosition': blackKingPosition,
      'whiteFrontLine': whiteFrontLine,
      'whiteBackLine': whiteBackLine,
      'blackFrontLine': blackFrontLine,
      'blackBackLine': blackBackLine,
      'whiteDirection': whiteDirection,
      'blackDirection': blackDirection,
      'gameMode': gameMode.index,
      'humanPlaysWhite': humanPlaysWhite,
      'aiDifficulty': aiDifficulty,
      'availableUndos': availableUndos,
    };
  }

  static GameSnapshot fromJson(Map<String, dynamic> json) {
    final board = (json['board'] as List<dynamic>)
        .map<List<ChessPiece?>>(
          (row) => (row as List<dynamic>)
              .map<ChessPiece?>(
                (code) => ChessPiece.fromCode(code as String?),
              )
              .toList(),
        )
        .toList();
    final moves = (json['moves'] as List<dynamic>)
        .map<MoveRecord>(
          (item) => MoveRecord(
            fromRow: item['fromRow'] as int,
            fromCol: item['fromCol'] as int,
            toRow: item['toRow'] as int,
            toCol: item['toCol'] as int,
            type: ChessPieceType.values[item['type'] as int],
            isWhite: item['isWhite'] as bool,
            took: item['took'] as bool,
            isCheck: item['isCheck'] as bool,
            isCheckmate: item['isCheckmate'] as bool,
            isStalemate: item['isStalemate'] as bool,
            kingCastle: item['kingCastle'] as bool,
            queenCastle: item['queenCastle'] as bool,
            promotionType:
                ChessPieceType.values[item['promotionType'] as int],
          ),
        )
        .toList();
    final whiteCaptured = (json['whiteCaptured'] as List<dynamic>)
        .map<ChessPiece?>((code) => ChessPiece.fromCode(code as String?))
        .whereType<ChessPiece>()
        .toList();
    final blackCaptured = (json['blackCaptured'] as List<dynamic>)
        .map<ChessPiece?>((code) => ChessPiece.fromCode(code as String?))
        .whereType<ChessPiece>()
        .toList();
    return GameSnapshot(
      board: board,
      moves: moves,
      whiteCaptured: whiteCaptured,
      blackCaptured: blackCaptured,
      whiteTurn: json['whiteTurn'] as bool,
      gameOver: json['gameOver'] as bool,
      stalemate: json['stalemate'] as bool,
      whiteScore: json['whiteScore'] as int,
      blackScore: json['blackScore'] as int,
      whiteTime: Duration(seconds: json['whiteTime'] as int),
      blackTime: Duration(seconds: json['blackTime'] as int),
      whiteKingPosition:
          (json['whiteKingPosition'] as List<dynamic>).cast<int>(),
      blackKingPosition:
          (json['blackKingPosition'] as List<dynamic>).cast<int>(),
      whiteFrontLine: json['whiteFrontLine'] as int,
      whiteBackLine: json['whiteBackLine'] as int,
      blackFrontLine: json['blackFrontLine'] as int,
      blackBackLine: json['blackBackLine'] as int,
      whiteDirection: json['whiteDirection'] as int,
      blackDirection: json['blackDirection'] as int,
      gameMode: GameMode.values[json['gameMode'] as int],
      humanPlaysWhite: json['humanPlaysWhite'] as bool,
      aiDifficulty: json['aiDifficulty'] as int,
      availableUndos: json['availableUndos'] as int,
    );
  }
}

class ChessAppState extends ChangeNotifier {
  ChessAppState._();
  static final ChessAppState instance = ChessAppState._();
  static final math.Random _random = math.Random();

  SharedPreferences? _prefs;
  bool _loading = true;
  bool _aiBusy = false;
  int _aiRequestId = 0;
  final Stopwatch _aiSearchClock = Stopwatch();
  int _aiSearchNodes = 0;
  bool _aiSearchAborted = false;
  static const int _maxAiSearchNodes = 12000;
  static const Duration _maxAiSearchTime = Duration(milliseconds: 300);
  bool _hasValidSavedGame = false;
  Timer? _timer;

  static const String _savedGameKey = 'saved_game';
  static const String _themeKey = 'theme_index';
  static const String _pieceThemeKey = 'piece_theme_index';
  static const String _showHintsKey = 'show_hints';
  static const String _showMoveHistoryKey = 'show_move_history';
  static const String _showNotationKey = 'show_notation';
  static const String _allowUndoRedoKey = 'allow_undo_redo';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _hapticEnabledKey = 'haptic_enabled';
  static const String _rotateBoardKey = 'rotate_board';
  static const String _rotatePiecesKey = 'rotate_pieces';
  static const String _gameModeKey = 'game_mode';
  static const String _aiDifficultyKey = 'ai_difficulty';
  static const String _humanSideKey = 'human_side_white';
  static const String _timeLimitKey = 'time_limit_index';

  final List<String> pieceThemes = const [
    'alpha',
    'classic',
    'dash',
    'game_room',
    'glass',
    'light',
    'marble',
    'metal',
    'neon',
    'newspaper',
    'tournament',
    'wood',
  ];

  int themeIndex = 5;
  int pieceThemeIndex = 1;
  bool showHints = true;
  bool showMoveHistory = true;
  bool showNotation = true;
  bool allowUndoRedo = true;
  bool soundEnabled = true;
  bool hapticEnabled = true;
  bool enableRotation = true;
  bool enablePieceRotation = false;
  GameMode gameMode = GameMode.localTwoPlayer;
  int aiDifficulty = 2;
  bool humanPlaysWhite = true;
  int timeLimitIndex = 0;
  final List<int> timeLimits = const [0, 10, 15, 30];

  static const List<int> aiElos = [700, 1000, 1400, 1800, 2200];
  static const List<String> aiNames = [
    'Omen',
    'Kimi',
    'Kolobanov',
    'Jäger',
    'Ritter',
  ];

  int get aiElo => aiElos[aiDifficulty.clamp(1, 5) - 1];
  String get aiName => aiNames[aiDifficulty.clamp(1, 5) - 1];
  String get aiDifficultyLabel => const ['Beginner', 'Casual', 'Club', 'Expert', 'Master'][aiDifficulty.clamp(1, 5) - 1];

  List<List<ChessPiece?>> board = [];
  List<MoveRecord> moves = [];
  List<ChessPiece> whiteCaptured = [];
  List<ChessPiece> blackCaptured = [];
  bool whiteTurn = true;
  bool gameOver = false;
  bool stalemate = false;
  bool whiteKingChecked = false;
  int whiteScore = 0;
  int blackScore = 0;
  Duration whiteTime = Duration.zero;
  Duration blackTime = Duration.zero;
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  int whiteFrontLine = 6;
  int whiteBackLine = 7;
  int blackFrontLine = 1;
  int blackBackLine = 0;
  int whiteDirection = -1;
  int blackDirection = 1;
  int? selectedRow;
  int? selectedCol;
  List<List<int>> validMoves = [];
  int? historyViewIndex;
  int availableUndos = 1;
  bool promotionPending = false;
  int? promotionRow;
  int? promotionCol;
  ChessPiece? promotionPiece;
  final List<GameSnapshot> _history = [];
  int _historyIndex = 0;

  bool get loading => _loading;
  bool get aiThinking => _aiBusy;
  AppThemePreset get theme => appThemes[themeIndex.clamp(0, appThemes.length - 1)];
  String get pieceTheme => pieceThemes[pieceThemeIndex.clamp(0, pieceThemes.length - 1)];
  bool get aiTurn => gameMode == GameMode.vsAi && whiteTurn != humanPlaysWhite;
  bool get usingHistory => historyViewIndex != null;
  bool get canResumeSavedGame {
    return _hasValidSavedGame;
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    themeIndex = (_prefs!.getInt(_themeKey) ?? 5).clamp(0, appThemes.length - 1);
    pieceThemeIndex = (_prefs!.getInt(_pieceThemeKey) ?? 1).clamp(0, pieceThemes.length - 1);
    showHints = _prefs!.getBool(_showHintsKey) ?? true;
    showMoveHistory = _prefs!.getBool(_showMoveHistoryKey) ?? true;
    showNotation = _prefs!.getBool(_showNotationKey) ?? true;
    allowUndoRedo = _prefs!.getBool(_allowUndoRedoKey) ?? true;
    soundEnabled = _prefs!.getBool(_soundEnabledKey) ?? true;
    hapticEnabled = _prefs!.getBool(_hapticEnabledKey) ?? true;
    enableRotation = _prefs!.getBool(_rotateBoardKey) ?? true;
    enablePieceRotation = _prefs!.getBool(_rotatePiecesKey) ?? false;
    gameMode = GameMode.values[_prefs!.getInt(_gameModeKey) ?? 0];
    aiDifficulty = _prefs!.getInt(_aiDifficultyKey) ?? 2;
    humanPlaysWhite = _prefs!.getBool(_humanSideKey) ?? true;
    timeLimitIndex = _prefs!.getInt(_timeLimitKey) ?? 0;
    _loading = false;
    notifyListeners();
    if (await loadSavedGame()) {
      return;
    }
    newGame(saveImmediately: false);
  }

  Future<bool> loadSavedGame() async {
    final raw = _prefs?.getString(_savedGameKey);
    if (raw == null || raw.isEmpty) {
      _hasValidSavedGame = false;
      return false;
    }
    try {
      final saved = GameSnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      _applySnapshot(saved);
      _history
        ..clear()
        ..add(saved);
      _historyIndex = 0;
      _hasValidSavedGame = true;
      notifyListeners();
      _restartTimer();
      _scheduleAiMove();
      return true;
    } catch (_) {
      _hasValidSavedGame = false;
      return false;
    }
  }

  Future<void> saveGame() async {
    final prefs = _prefs;
    if (prefs == null) return;
    final snapshot = _currentSnapshot();
    await prefs.setString(_savedGameKey, jsonEncode(snapshot.toJson()));
    _hasValidSavedGame = true;
    notifyListeners();
  }

  Future<void> clearSavedGame() async {
    await _prefs?.remove(_savedGameKey);
    _hasValidSavedGame = false;
  }

  Future<void> savePreferenceChanges() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setInt(_themeKey, themeIndex);
    await prefs.setInt(_pieceThemeKey, pieceThemeIndex);
    await prefs.setBool(_showHintsKey, showHints);
    await prefs.setBool(_showMoveHistoryKey, showMoveHistory);
    await prefs.setBool(_showNotationKey, showNotation);
    await prefs.setBool(_allowUndoRedoKey, allowUndoRedo);
    await prefs.setBool(_soundEnabledKey, soundEnabled);
    await prefs.setBool(_hapticEnabledKey, hapticEnabled);
    await prefs.setBool(_rotateBoardKey, enableRotation);
    await prefs.setBool(_rotatePiecesKey, enablePieceRotation);
    await prefs.setInt(_gameModeKey, gameMode.index);
    await prefs.setInt(_aiDifficultyKey, aiDifficulty);
    await prefs.setBool(_humanSideKey, humanPlaysWhite);
    await prefs.setInt(_timeLimitKey, timeLimitIndex);
  }

  void setThemeIndex(int value) {
    themeIndex = value.clamp(0, appThemes.length - 1);
    savePreferenceChanges();
    notifyListeners();
  }

  void setPieceThemeIndex(int value) {
    pieceThemeIndex = value.clamp(0, pieceThemes.length - 1);
    savePreferenceChanges();
    notifyListeners();
  }

  void setShowHints(bool value) {
    showHints = value;
    savePreferenceChanges();
    notifyListeners();
  }

  void setShowMoveHistory(bool value) {
    showMoveHistory = value;
    savePreferenceChanges();
    notifyListeners();
  }

  void setShowNotation(bool value) {
    showNotation = value;
    savePreferenceChanges();
    notifyListeners();
  }

  void setAllowUndoRedo(bool value) {
    allowUndoRedo = value;
    savePreferenceChanges();
    notifyListeners();
  }

  void setSoundEnabled(bool value) {
    soundEnabled = value;
    if (value) {
      unawaited(FeedbackService.instance.initialize());
    }
    savePreferenceChanges();
    notifyListeners();
  }

  void setHapticEnabled(bool value) {
    hapticEnabled = value;
    savePreferenceChanges();
    notifyListeners();
  }

  void setEnableRotation(bool value) {
    if (gameMode != GameMode.localTwoPlayer) return;
    enableRotation = value;
    if (enableRotation) {
      enablePieceRotation = false;
    }
    savePreferenceChanges();
    notifyListeners();
  }

  void setEnablePieceRotation(bool value) {
    if (gameMode != GameMode.localTwoPlayer || enableRotation) return;
    enablePieceRotation = value;
    savePreferenceChanges();
    notifyListeners();
  }

  void setGameMode(GameMode mode) {
    gameMode = mode;
    savePreferenceChanges();
    notifyListeners();
  }

  void setAiDifficulty(int value) {
    aiDifficulty = value.clamp(1, 5);
    savePreferenceChanges();
    notifyListeners();
  }

  void setHumanPlaysWhite(bool value) {
    humanPlaysWhite = value;
    savePreferenceChanges();
    notifyListeners();
  }

  void setTimeLimitIndex(int value) {
    timeLimitIndex = value.clamp(0, timeLimits.length - 1);
    savePreferenceChanges();
    notifyListeners();
  }

  void resetSettingsToDefaults() {
    themeIndex = 5;
    pieceThemeIndex = 1;
    showHints = true;
    showMoveHistory = true;
    showNotation = true;
    allowUndoRedo = true;
    soundEnabled = true;
    hapticEnabled = true;
    enableRotation = true;
    enablePieceRotation = false;
    gameMode = GameMode.localTwoPlayer;
    aiDifficulty = 2;
    humanPlaysWhite = true;
    timeLimitIndex = 0;
    savePreferenceChanges();
    notifyListeners();
  }

  void newGame({bool saveImmediately = true}) {
    _aiRequestId++;
    _aiBusy = false;
    configureOrientation(humanPlaysWhite);
    board = _createInitialBoard();
    whiteTurn = true;
    gameOver = false;
    stalemate = false;
    whiteKingChecked = false;
    whiteScore = 0;
    blackScore = 0;
    selectedRow = null;
    selectedCol = null;
    validMoves = [];
    whiteCaptured = [];
    blackCaptured = [];
    moves = [];
    historyViewIndex = null;
    availableUndos = 1;
    promotionPending = false;
    promotionRow = null;
    promotionCol = null;
    promotionPiece = null;
    whiteTime = Duration(minutes: timeLimits[timeLimitIndex]);
    blackTime = Duration(minutes: timeLimits[timeLimitIndex]);
    _history
      ..clear()
      ..add(_currentSnapshot());
    _historyIndex = 0;
    _restartTimer();
    notifyListeners();
    if (saveImmediately) {
      saveGame();
    }
    _scheduleAiMove();
  }

  void configureOrientation(bool whiteAtBottom) {
    if (whiteAtBottom) {
      whiteFrontLine = 6;
      whiteBackLine = 7;
      blackFrontLine = 1;
      blackBackLine = 0;
      whiteDirection = -1;
      blackDirection = 1;
      whiteKingPosition = [7, 4];
      blackKingPosition = [0, 4];
    } else {
      whiteFrontLine = 1;
      whiteBackLine = 0;
      blackFrontLine = 6;
      blackBackLine = 7;
      whiteDirection = 1;
      blackDirection = -1;
      whiteKingPosition = [0, 4];
      blackKingPosition = [7, 4];
    }
  }

  List<List<ChessPiece?>> _createInitialBoard() {
    final newBoard = List.generate(8, (_) => List<ChessPiece?>.filled(8, null));
    for (var i = 0; i < 8; i++) {
      newBoard[whiteFrontLine][i] = ChessPiece(type: ChessPieceType.pawn, isWhite: true);
      newBoard[blackFrontLine][i] = ChessPiece(type: ChessPieceType.pawn, isWhite: false);
    }
    newBoard[whiteBackLine][0] = ChessPiece(type: ChessPieceType.rook, isWhite: true);
    newBoard[whiteBackLine][7] = ChessPiece(type: ChessPieceType.rook, isWhite: true);
    newBoard[whiteBackLine][1] = ChessPiece(type: ChessPieceType.knight, isWhite: true);
    newBoard[whiteBackLine][6] = ChessPiece(type: ChessPieceType.knight, isWhite: true);
    newBoard[whiteBackLine][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: true);
    newBoard[whiteBackLine][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: true);
    newBoard[whiteBackLine][4] = ChessPiece(type: ChessPieceType.king, isWhite: true);
    newBoard[whiteBackLine][3] = ChessPiece(type: ChessPieceType.queen, isWhite: true);

    newBoard[blackBackLine][0] = ChessPiece(type: ChessPieceType.rook, isWhite: false);
    newBoard[blackBackLine][7] = ChessPiece(type: ChessPieceType.rook, isWhite: false);
    newBoard[blackBackLine][1] = ChessPiece(type: ChessPieceType.knight, isWhite: false);
    newBoard[blackBackLine][6] = ChessPiece(type: ChessPieceType.knight, isWhite: false);
    newBoard[blackBackLine][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: false);
    newBoard[blackBackLine][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: false);
    newBoard[blackBackLine][4] = ChessPiece(type: ChessPieceType.king, isWhite: false);
    newBoard[blackBackLine][3] = ChessPiece(type: ChessPieceType.queen, isWhite: false);
    return newBoard;
  }

  void selectSquare(int row, int col) {
    if (gameOver || promotionPending) return;
    if (historyViewIndex != null) {
      historyViewIndex = null;
      _restoreLivePosition();
    }
    final piece = board[row][col];
    if (selectedRow == null || selectedCol == null) {
      if (piece != null && piece.isWhite == whiteTurn) {
        selectedRow = row;
        selectedCol = col;
        validMoves = legalMovesForPiece(row, col);
        _hapticSelection();
        notifyListeners();
      }
      return;
    }
    final selectedPiece = board[selectedRow!][selectedCol!];
    if (piece != null && piece.isWhite == whiteTurn) {
      selectedRow = row;
      selectedCol = col;
      validMoves = legalMovesForPiece(row, col);
      _hapticSelection();
      notifyListeners();
      return;
    }
    if (validMoves.any((move) => move[0] == row && move[1] == col) && selectedPiece != null) {
      _executeMove(selectedRow!, selectedCol!, row, col, selectedPiece);
      return;
    }
    selectedRow = null;
    selectedCol = null;
    validMoves = [];
    _hapticLight();
    notifyListeners();
  }

  void completePromotion(ChessPieceType type) {
    if (!promotionPending || promotionRow == null || promotionCol == null || promotionPiece == null) {
      return;
    }
    final row = promotionRow!;
    final col = promotionCol!;
    board[row][col] = ChessPiece(type: type, isWhite: promotionPiece!.isWhite)..movesNum = promotionPiece!.movesNum;
    final last = moves.removeLast();
    moves.add(
      MoveRecord(
        fromRow: last.fromRow,
        fromCol: last.fromCol,
        toRow: last.toRow,
        toCol: last.toCol,
        type: last.type,
        isWhite: last.isWhite,
        took: last.took,
        isCheck: last.isCheck,
        isCheckmate: last.isCheckmate,
        isStalemate: last.isStalemate,
        kingCastle: last.kingCastle,
        queenCastle: last.queenCastle,
        promotionType: type,
      ),
    );
    promotionPending = false;
    promotionPiece = null;
    promotionRow = null;
    promotionCol = null;
    _finishMove(last, promotionType: type);
    if (soundEnabled) {
      unawaited(FeedbackService.instance.playSound('promote'));
    }
    _hapticMedium();
  }

  void undoMove() {
    if (!allowUndoRedo || _historyIndex <= 0 || usingHistory) return;
    _aiRequestId++;
    _aiBusy = false;
    final rewindBy = gameMode == GameMode.vsAi ? math.min(2, _historyIndex) : 1;
    _historyIndex -= rewindBy;
    _applySnapshot(_history[_historyIndex]);
    _restartTimer();
    _hapticLight();
    notifyListeners();
    saveGame();
    _scheduleAiMove();
  }

  void redoMove() {
    if (!allowUndoRedo || _historyIndex >= _history.length - 1 || usingHistory) return;
    _aiRequestId++;
    _aiBusy = false;
    final available = _history.length - 1 - _historyIndex;
    final advanceBy = gameMode == GameMode.vsAi ? math.min(2, available) : 1;
    _historyIndex += advanceBy;
    _applySnapshot(_history[_historyIndex]);
    _restartTimer();
    _hapticLight();
    notifyListeners();
    saveGame();
    _scheduleAiMove();
  }

  void selectHistoryIndex(int index) {
    if (index < 0 || index >= _history.length) return;
    historyViewIndex = index;
    _applySnapshot(_history[index]);
    notifyListeners();
  }

  void returnToLiveGame() {
    historyViewIndex = null;
    _restoreLivePosition();
    notifyListeners();
    _scheduleAiMove();
  }

  void _restoreLivePosition() {
    if (_history.isEmpty) return;
    _applySnapshot(_history[_historyIndex]);
  }

  void _executeMove(int fromRow, int fromCol, int toRow, int toCol, ChessPiece piece) {
    final before = _currentSnapshot();
    final move = _movePieceOnBoard(fromRow, fromCol, toRow, toCol, piece);
    if (move == null) {
      _applySnapshot(before);
      return;
    }
    moves.add(move);
    if (promotionPending) {
      notifyListeners();
      // Do not persist a half-finished promotion. The last completed position
      // remains the recoverable save until the player chooses a piece.
      return;
    }
    _finishMove(move);
  }

  MoveRecord? _movePieceOnBoard(int fromRow, int fromCol, int toRow, int toCol, ChessPiece piece) {
    var took = false;
    var kingCastle = false;
    var queenCastle = false;
    ChessPieceType promotionType = ChessPieceType.pawn;

    final destinationPiece = board[toRow][toCol];
    if (destinationPiece != null) {
      took = true;
      if (destinationPiece.isWhite) {
        whiteCaptured.add(destinationPiece);
        blackScore += piecePoint(destinationPiece);
      } else {
        blackCaptured.add(destinationPiece);
        whiteScore += piecePoint(destinationPiece);
      }
    } else if (piece.type == ChessPieceType.pawn && fromCol != toCol) {
      final captureRow = toRow - (piece.isWhite ? whiteDirection : blackDirection);
      final captured = board[captureRow][toCol];
      if (captured != null) {
        took = true;
        board[captureRow][toCol] = null;
        if (captured.isWhite) {
          whiteCaptured.add(captured);
          blackScore += piecePoint(captured);
        } else {
          blackCaptured.add(captured);
          whiteScore += piecePoint(captured);
        }
      }
    }

    board[toRow][toCol] = piece;
    board[fromRow][fromCol] = null;
    piece.movesNum++;

    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = [toRow, toCol];
      } else {
        blackKingPosition = [toRow, toCol];
      }
      if (toCol == fromCol + 2) {
        kingCastle = true;
        board[toRow][toCol - 1] = board[toRow][toCol + 1];
        board[toRow][toCol + 1] = null;
        board[toRow][toCol - 1]?.movesNum++;
      } else if (toCol == fromCol - 2) {
        queenCastle = true;
        board[toRow][toCol + 1] = board[toRow][toCol - 2];
        board[toRow][toCol - 2] = null;
        board[toRow][toCol + 1]?.movesNum++;
      }
    }

    if (piece.type == ChessPieceType.pawn && (toRow == 0 || toRow == 7)) {
      promotionPending = true;
      promotionRow = toRow;
      promotionCol = toCol;
      promotionPiece = piece;
    }

    final move = MoveRecord(
      fromRow: fromRow,
      fromCol: fromCol,
      toRow: toRow,
      toCol: toCol,
      type: piece.type,
      isWhite: piece.isWhite,
      took: took,
      kingCastle: kingCastle,
      queenCastle: queenCastle,
      promotionType: promotionType,
    );
    return move;
  }

  void _pushHistory() {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(_currentSnapshot());
    _historyIndex = _history.length - 1;
  }

  GameSnapshot _currentSnapshot() {
    return GameSnapshot(
      board: _cloneBoard(board),
      moves: List<MoveRecord>.from(moves),
      whiteCaptured: List<ChessPiece>.from(whiteCaptured.map((piece) => piece.copy())),
      blackCaptured: List<ChessPiece>.from(blackCaptured.map((piece) => piece.copy())),
      whiteTurn: whiteTurn,
      gameOver: gameOver,
      stalemate: stalemate,
      whiteScore: whiteScore,
      blackScore: blackScore,
      whiteTime: whiteTime,
      blackTime: blackTime,
      whiteKingPosition: List<int>.from(whiteKingPosition),
      blackKingPosition: List<int>.from(blackKingPosition),
      whiteFrontLine: whiteFrontLine,
      whiteBackLine: whiteBackLine,
      blackFrontLine: blackFrontLine,
      blackBackLine: blackBackLine,
      whiteDirection: whiteDirection,
      blackDirection: blackDirection,
      gameMode: gameMode,
      humanPlaysWhite: humanPlaysWhite,
      aiDifficulty: aiDifficulty,
      availableUndos: availableUndos,
    );
  }

  void _applySnapshot(GameSnapshot snapshot) {
    board = _cloneBoard(snapshot.board);
    moves = List<MoveRecord>.from(snapshot.moves);
    whiteCaptured = List<ChessPiece>.from(snapshot.whiteCaptured.map((piece) => piece.copy()));
    blackCaptured = List<ChessPiece>.from(snapshot.blackCaptured.map((piece) => piece.copy()));
    whiteTurn = snapshot.whiteTurn;
    gameOver = snapshot.gameOver;
    stalemate = snapshot.stalemate;
    whiteScore = snapshot.whiteScore;
    blackScore = snapshot.blackScore;
    whiteTime = snapshot.whiteTime;
    blackTime = snapshot.blackTime;
    whiteKingPosition = List<int>.from(snapshot.whiteKingPosition);
    blackKingPosition = List<int>.from(snapshot.blackKingPosition);
    whiteFrontLine = snapshot.whiteFrontLine;
    whiteBackLine = snapshot.whiteBackLine;
    blackFrontLine = snapshot.blackFrontLine;
    blackBackLine = snapshot.blackBackLine;
    whiteDirection = snapshot.whiteDirection;
    blackDirection = snapshot.blackDirection;
    gameMode = snapshot.gameMode;
    humanPlaysWhite = snapshot.humanPlaysWhite;
    aiDifficulty = snapshot.aiDifficulty;
    availableUndos = snapshot.availableUndos;
    selectedRow = null;
    selectedCol = null;
    validMoves = [];
    promotionPending = false;
    promotionRow = null;
    promotionCol = null;
    promotionPiece = null;
    whiteKingChecked = isKingInCheck(whiteTurn);
  }

  List<List<ChessPiece?>> _cloneBoard(List<List<ChessPiece?>> source) {
    return source
        .map(
          (row) => row.map((piece) => piece?.copy()).toList(),
        )
        .toList();
  }

  bool isKingInCheck(bool whiteKing) {
    final kingPosition = whiteKing ? whiteKingPosition : blackKingPosition;
    return isSquareAttacked(kingPosition[0], kingPosition[1], !whiteKing);
  }

  bool isSquareAttacked(int row, int col, bool byWhite) {
    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece == null || piece.isWhite != byWhite) continue;
        if (_pieceAttacksSquare(r, c, piece, row, col)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _pieceAttacksSquare(int row, int col, ChessPiece piece, int targetRow, int targetCol) {
    final dRow = targetRow - row;
    final dCol = targetCol - col;
    switch (piece.type) {
      case ChessPieceType.pawn:
        final direction = piece.isWhite ? whiteDirection : blackDirection;
        return dRow == direction && dCol.abs() == 1;
      case ChessPieceType.knight:
        return (dRow.abs() == 2 && dCol.abs() == 1) || (dRow.abs() == 1 && dCol.abs() == 2);
      case ChessPieceType.king:
        return dRow.abs() <= 1 && dCol.abs() <= 1;
      case ChessPieceType.bishop:
        if (dRow.abs() != dCol.abs()) return false;
        return _pathClear(row, col, targetRow, targetCol);
      case ChessPieceType.rook:
        if (dRow != 0 && dCol != 0) return false;
        return _pathClear(row, col, targetRow, targetCol);
      case ChessPieceType.queen:
        if (dRow == 0 || dCol == 0 || dRow.abs() == dCol.abs()) {
          return _pathClear(row, col, targetRow, targetCol);
        }
        return false;
    }
  }

  bool _pathClear(int row, int col, int targetRow, int targetCol) {
    final stepRow = (targetRow - row).sign;
    final stepCol = (targetCol - col).sign;
    var r = row + stepRow;
    var c = col + stepCol;
    while (r != targetRow || c != targetCol) {
      if (board[r][c] != null) return false;
      r += stepRow;
      c += stepCol;
    }
    return true;
  }

  List<MoveCandidate> legalMovesForColor(bool white) {
    final candidates = <MoveCandidate>[];
    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece == null || piece.isWhite != white) continue;
        for (final move in legalMovesForPiece(r, c)) {
          candidates.add(
            MoveCandidate(
              fromRow: r,
              fromCol: c,
              toRow: move[0],
              toCol: move[1],
              piece: piece,
            ),
          );
        }
      }
    }
    return candidates;
  }

  List<List<int>> legalMovesForPiece(int row, int col) {
    final piece = board[row][col];
    if (piece == null) return [];
    final moves = <List<int>>[];
    for (final candidate in primaryMovesForPiece(row, col, piece)) {
      // Kings are never captured in chess; checkmate ends the game before a
      // move could reach the opposing king's square.
      final target = board[candidate[0]][candidate[1]];
      if (target?.type == ChessPieceType.king) continue;
      if (_isMoveSafe(row, col, candidate[0], candidate[1], piece)) {
        moves.add(candidate);
      }
    }
    return moves;
  }

  List<List<int>> primaryMovesForPiece(int row, int col, ChessPiece piece) {
    final moves = <List<int>>[];
    final direction = piece.isWhite ? whiteDirection : blackDirection;
    switch (piece.type) {
      case ChessPieceType.king:
        for (final delta in kingDirections) {
          final r = row + delta[0];
          final c = col + delta[1];
          if (_isOnBoard(r, c) && (board[r][c] == null || board[r][c]!.isWhite != piece.isWhite)) {
            moves.add([r, c]);
          }
        }
        if (piece.movesNum == 0 &&
            !isSquareAttacked(row, col, !piece.isWhite) &&
            !_isSquareOccupied(row, col + 1) &&
            !_isSquareOccupied(row, col + 2)) {
          final rook = _pieceAt(row, col + 3);
          if (rook != null &&
              rook.isWhite == piece.isWhite &&
              rook.type == ChessPieceType.rook &&
              rook.movesNum == 0 &&
              !_isSquareAttackedForCastling(row, col, col + 1, piece.isWhite) &&
              !_isSquareAttackedForCastling(row, col, col + 2, piece.isWhite)) {
            moves.add([row, col + 2]);
          }
        }
        if (piece.movesNum == 0 &&
            !isSquareAttacked(row, col, !piece.isWhite) &&
            !_isSquareOccupied(row, col - 1) &&
            !_isSquareOccupied(row, col - 2) &&
            !_isSquareOccupied(row, col - 3)) {
          final rook = _pieceAt(row, col - 4);
          if (rook != null &&
              rook.isWhite == piece.isWhite &&
              rook.type == ChessPieceType.rook &&
              rook.movesNum == 0 &&
              !_isSquareAttackedForCastling(row, col, col - 1, piece.isWhite) &&
              !_isSquareAttackedForCastling(row, col, col - 2, piece.isWhite)) {
            moves.add([row, col - 2]);
          }
        }
        break;
      case ChessPieceType.queen:
        _addSlidingMoves(moves, row, col, piece, queenDirections);
        break;
      case ChessPieceType.rook:
        _addSlidingMoves(moves, row, col, piece, rookDirections);
        break;
      case ChessPieceType.bishop:
        _addSlidingMoves(moves, row, col, piece, bishopDirections);
        break;
      case ChessPieceType.knight:
        for (final delta in knightDirections) {
          final r = row + delta[0];
          final c = col + delta[1];
          if (_isOnBoard(r, c) && (board[r][c] == null || board[r][c]!.isWhite != piece.isWhite)) {
            moves.add([r, c]);
          }
        }
        break;
      case ChessPieceType.pawn:
        final oneRow = row + direction;
        if (_isOnBoard(oneRow, col) && board[oneRow][col] == null) {
          moves.add([oneRow, col]);
        }
        final startRow = piece.isWhite ? whiteFrontLine : blackFrontLine;
        final twoRow = row + direction * 2;
        if (row == startRow && _isOnBoard(twoRow, col) && board[oneRow][col] == null && board[twoRow][col] == null) {
          moves.add([twoRow, col]);
        }
        for (final deltaCol in [-1, 1]) {
          final r = row + direction;
          final c = col + deltaCol;
          if (_isOnBoard(r, c) && board[r][c] != null && board[r][c]!.isWhite != piece.isWhite) {
            moves.add([r, c]);
          }
        }
        final lastMove = movesHistoryLast;
        if (lastMove != null &&
            lastMove.type == ChessPieceType.pawn &&
            lastMove.isWhite != piece.isWhite &&
            (lastMove.fromRow - lastMove.toRow).abs() == 2) {
          final targetRow = row + direction;
          final adjacentPawn = _pieceAt(lastMove.toRow, lastMove.toCol);
          if (targetRow == lastMove.toRow &&
              (lastMove.toCol == col - 1 || lastMove.toCol == col + 1) &&
              adjacentPawn?.type == ChessPieceType.pawn &&
              adjacentPawn?.isWhite != piece.isWhite &&
              board[targetRow][lastMove.toCol] == null) {
            moves.add([targetRow, lastMove.toCol]);
          }
        }
        break;
    }
    return moves;
  }

  void _addSlidingMoves(List<List<int>> moves, int row, int col, ChessPiece piece, List<List<int>> directions) {
    for (final delta in directions) {
      var r = row + delta[0];
      var c = col + delta[1];
      while (_isOnBoard(r, c)) {
        if (board[r][c] != null) {
          if (board[r][c]!.isWhite != piece.isWhite) {
            moves.add([r, c]);
          }
          break;
        }
        moves.add([r, c]);
        r += delta[0];
        c += delta[1];
      }
    }
  }

  bool _isMoveSafe(int fromRow, int fromCol, int toRow, int toCol, ChessPiece piece) {
    final cloneBoard = _cloneBoard(board);
    final cloneWhiteKing = List<int>.from(whiteKingPosition);
    final cloneBlackKing = List<int>.from(blackKingPosition);

    final movingPiece = cloneBoard[fromRow][fromCol];
    cloneBoard[fromRow][fromCol] = null;

    if (movingPiece == null) return false;
    if (movingPiece.type == ChessPieceType.pawn && fromCol != toCol && cloneBoard[toRow][toCol] == null) {
      final captureRow = toRow - (movingPiece.isWhite ? whiteDirection : blackDirection);
      cloneBoard[captureRow][toCol] = null;
    }
    cloneBoard[toRow][toCol] = movingPiece;
    if (movingPiece.type == ChessPieceType.king) {
      if (movingPiece.isWhite) {
        cloneWhiteKing[0] = toRow;
        cloneWhiteKing[1] = toCol;
      } else {
        cloneBlackKing[0] = toRow;
        cloneBlackKing[1] = toCol;
      }
      if (toCol == fromCol + 2) {
        cloneBoard[toRow][toCol - 1] = cloneBoard[toRow][toCol + 1];
        cloneBoard[toRow][toCol + 1] = null;
      } else if (toCol == fromCol - 2) {
        cloneBoard[toRow][toCol + 1] = cloneBoard[toRow][toCol - 2];
        cloneBoard[toRow][toCol - 2] = null;
      }
    }

    final kingSquare = movingPiece.isWhite ? cloneWhiteKing : cloneBlackKing;
    return !_isSquareAttackedOnBoard(cloneBoard, kingSquare[0], kingSquare[1], !movingPiece.isWhite, cloneWhiteKing, cloneBlackKing);
  }

  bool _isSquareAttackedOnBoard(List<List<ChessPiece?>> testBoard, int row, int col, bool byWhite, List<int> whiteKing, List<int> blackKing) {
    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 8; c++) {
        final piece = testBoard[r][c];
        if (piece == null || piece.isWhite != byWhite) continue;
        if (_pieceAttacksSquareOnBoard(testBoard, r, c, piece, row, col)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _pieceAttacksSquareOnBoard(List<List<ChessPiece?>> testBoard, int row, int col, ChessPiece piece, int targetRow, int targetCol) {
    final dRow = targetRow - row;
    final dCol = targetCol - col;
    switch (piece.type) {
      case ChessPieceType.pawn:
        final direction = piece.isWhite ? whiteDirection : blackDirection;
        return dRow == direction && dCol.abs() == 1;
      case ChessPieceType.knight:
        return (dRow.abs() == 2 && dCol.abs() == 1) || (dRow.abs() == 1 && dCol.abs() == 2);
      case ChessPieceType.king:
        return dRow.abs() <= 1 && dCol.abs() <= 1;
      case ChessPieceType.bishop:
        if (dRow.abs() != dCol.abs()) return false;
        return _pathClearOnBoard(testBoard, row, col, targetRow, targetCol);
      case ChessPieceType.rook:
        if (dRow != 0 && dCol != 0) return false;
        return _pathClearOnBoard(testBoard, row, col, targetRow, targetCol);
      case ChessPieceType.queen:
        if (dRow == 0 || dCol == 0 || dRow.abs() == dCol.abs()) {
          return _pathClearOnBoard(testBoard, row, col, targetRow, targetCol);
        }
        return false;
    }
  }

  bool _pathClearOnBoard(List<List<ChessPiece?>> testBoard, int row, int col, int targetRow, int targetCol) {
    final stepRow = (targetRow - row).sign;
    final stepCol = (targetCol - col).sign;
    var r = row + stepRow;
    var c = col + stepCol;
    while (r != targetRow || c != targetCol) {
      if (testBoard[r][c] != null) return false;
      r += stepRow;
      c += stepCol;
    }
    return true;
  }

  bool _isSquareAttackedForCastling(int row, int fromCol, int targetCol, bool whiteKing) {
    return isSquareAttacked(row, targetCol, !whiteKing);
  }

  bool _isOnBoard(int row, int col) => row >= 0 && row < 8 && col >= 0 && col < 8;
  bool _isSquareOccupied(int row, int col) => _isOnBoard(row, col) && board[row][col] != null;
  ChessPiece? _pieceAt(int row, int col) => _isOnBoard(row, col) ? board[row][col] : null;
  MoveRecord? get movesHistoryLast => moves.isEmpty ? null : moves.last;

  bool hasAnyLegalMove(bool white) => legalMovesForColor(white).isNotEmpty;

  bool isCheckMate(bool white) => isKingInCheck(white) && !hasAnyLegalMove(white);

  void _restartTimer() {
    _timer?.cancel();
    if (timeLimitIndex == 0) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (gameOver || promotionPending || usingHistory) return;
      if (whiteTurn) {
        if (whiteTime.inSeconds <= 0) {
          _endGame(stalemate: false);
          return;
        }
        whiteTime = whiteTime - const Duration(seconds: 1);
      } else {
        if (blackTime.inSeconds <= 0) {
          _endGame(stalemate: false);
          return;
        }
        blackTime = blackTime - const Duration(seconds: 1);
      }
      notifyListeners();
      saveGame();
    });
  }

  void _endGame({required bool stalemate}) {
    gameOver = true;
    this.stalemate = stalemate;
    notifyListeners();
    saveGame();
  }

  void _scheduleAiMove() {
    if (!aiTurn || gameOver || promotionPending || usingHistory) return;
    if (_aiBusy) return;
    _aiBusy = true;
    notifyListeners();
    final requestId = ++_aiRequestId;
    Future.delayed(const Duration(milliseconds: 350), () async {
      if (requestId != _aiRequestId) return;
      try {
        await Future<void>.delayed(Duration.zero);
        if (!aiTurn || gameOver || promotionPending || usingHistory) return;
        final move = _pickAiMove();
        if (requestId != _aiRequestId) return;
        if (move == null) {
          final inCheck = isKingInCheck(whiteTurn);
          if (!hasAnyLegalMove(whiteTurn)) {
            _endGame(stalemate: !inCheck);
          }
          return;
        }
        final piece = board[move.fromRow][move.fromCol];
        if (piece != null) {
          _executeMove(move.fromRow, move.fromCol, move.toRow, move.toCol, piece);
          if (promotionPending && promotionPiece != null) {
            completePromotion(ChessPieceType.queen);
          }
        }
      } finally {
        if (requestId == _aiRequestId) {
          _aiBusy = false;
          notifyListeners();
        }
      }
    });
  }

  MoveCandidate? _pickAiMove() {
    final legal = legalMovesForColor(whiteTurn);
    if (legal.isEmpty) return null;
    _aiSearchClock
      ..reset()
      ..start();
    _aiSearchNodes = 0;
    _aiSearchAborted = false;
    // A forced mate always outranks the opening book, material, and position.
    final checkmate = _immediateCheckmateMove(legal);
    if (checkmate != null) return checkmate;
    // Only the stronger personalities know the opening book. Lower levels
    // deliberately make less precise opening choices.
    final bookMove = aiDifficulty >= 3 ? _openingBookMove(legal) : null;
    if (bookMove != null) return bookMove;

    // This search runs on Flutter's UI isolate, so it must have a hard budget.
    final depth = const [1, 2, 3, 3, 3][aiDifficulty.clamp(1, 5) - 1];
    final aiWhite = !humanPlaysWhite;
    final ordered = [...legal]..sort((a, b) => _moveOrderingScore(b).compareTo(_moveOrderingScore(a)));
    final scored = <MapEntry<MoveCandidate, double>>[];
    var alpha = -double.infinity;
    for (final candidate in ordered) {
      if (_shouldAbortAiSearch()) break;
      final before = _currentSnapshot();
      final promotionBefore = promotionPending;
      final promotionRowBefore = promotionRow;
      final promotionColBefore = promotionCol;
      final promotionPieceBefore = promotionPiece;
      _applySearchMove(candidate);
      final value = _minimax(depth - 1, alpha, double.infinity, aiWhite);
      _applySnapshot(before);
      promotionPending = promotionBefore;
      promotionRow = promotionRowBefore;
      promotionCol = promotionColBefore;
      promotionPiece = promotionPieceBefore;
      scored.add(MapEntry(candidate, value));
      alpha = math.max(alpha, value).toDouble();
    }
    _aiSearchClock.stop();
    if (scored.isEmpty) return legal.first;
    scored.sort((a, b) => b.value.compareTo(a.value));
    final topCount = aiDifficulty == 1
        ? math.min(4, scored.length).toInt()
        : aiDifficulty == 2
            ? math.min(2, scored.length).toInt()
            : 1;
    return scored[_random.nextInt(topCount)].key;
  }

  MoveCandidate? _immediateCheckmateMove(List<MoveCandidate> legal) {
    for (final candidate in legal) {
      if (_shouldAbortAiSearch()) break;
      final before = _currentSnapshot();
      final promotionBefore = promotionPending;
      final promotionRowBefore = promotionRow;
      final promotionColBefore = promotionCol;
      final promotionPieceBefore = promotionPiece;
      _applySearchMove(candidate);
      final isMate = isKingInCheck(whiteTurn) && legalMovesForColor(whiteTurn).isEmpty;
      _applySnapshot(before);
      promotionPending = promotionBefore;
      promotionRow = promotionRowBefore;
      promotionCol = promotionColBefore;
      promotionPiece = promotionPieceBefore;
      if (isMate) return candidate;
    }
    return null;
  }

  double _moveOrderingScore(MoveCandidate candidate) {
    final piece = board[candidate.fromRow][candidate.fromCol];
    if (piece == null) return -9999;
    final target = board[candidate.toRow][candidate.toCol];
    double score = 0;

    if (target != null) {
      score += _pieceValue(target) * 10;
    }

    if (piece.type == ChessPieceType.pawn && candidate.fromCol != candidate.toCol && target == null) {
      final captureRow = candidate.toRow - (piece.isWhite ? whiteDirection : blackDirection);
      final captured = _isOnBoard(captureRow, candidate.toCol) ? board[captureRow][candidate.toCol] : null;
      if (captured != null) {
        score += _pieceValue(captured) * 10;
      }
    }

    if (piece.type == ChessPieceType.pawn && (candidate.toRow == 0 || candidate.toRow == 7)) {
      score += 80;
    }

    if (piece.type == ChessPieceType.king && (candidate.toCol == candidate.fromCol + 2 || candidate.toCol == candidate.fromCol - 2)) {
      score += 15;
    }

    final centerDistance = (candidate.toRow - 3.5).abs() + (candidate.toCol - 3.5).abs();
    score += (7 - centerDistance) * 0.5;

    final advanceBonus = piece.isWhite ? (7 - candidate.toRow) : candidate.toRow;
    score += piece.type == ChessPieceType.pawn ? advanceBonus * 0.7 : 0;

    return score + _pieceSquareValue(piece, candidate.toRow, candidate.toCol);
  }

  double _minimax(int depth, double alpha, double beta, bool aiWhite) {
    if (_shouldAbortAiSearch()) return 0;
    final legal = legalMovesForColor(whiteTurn);
    if (legal.isEmpty) {
      if (isKingInCheck(whiteTurn)) {
        return whiteTurn == aiWhite ? -100000.0 - depth : 100000.0 + depth;
      }
      return 0;
    }
    if (depth <= 0) return _evaluateBoard(aiWhite);

    final ordered = [...legal]..sort((a, b) => _moveOrderingScore(b).compareTo(_moveOrderingScore(a)));
    final maximizing = whiteTurn == aiWhite;
    var best = maximizing ? -double.infinity : double.infinity;
    for (final candidate in ordered) {
      if (_shouldAbortAiSearch()) break;
      final before = _currentSnapshot();
      final promotionBefore = promotionPending;
      final promotionRowBefore = promotionRow;
      final promotionColBefore = promotionCol;
      final promotionPieceBefore = promotionPiece;
      _applySearchMove(candidate);
      final value = _minimax(depth - 1, alpha, beta, aiWhite);
      _applySnapshot(before);
      promotionPending = promotionBefore;
      promotionRow = promotionRowBefore;
      promotionCol = promotionColBefore;
      promotionPiece = promotionPieceBefore;
      if (maximizing) {
        best = math.max(best, value).toDouble();
        alpha = math.max(alpha, best).toDouble();
      } else {
        best = math.min(best, value).toDouble();
        beta = math.min(beta, best).toDouble();
      }
      if (beta <= alpha) break;
    }
    return best;
  }

  bool _shouldAbortAiSearch() {
    _aiSearchNodes++;
    if (_aiSearchNodes > _maxAiSearchNodes || _aiSearchClock.elapsed > _maxAiSearchTime) {
      _aiSearchAborted = true;
    }
    return _aiSearchAborted;
  }

  void _applySearchMove(MoveCandidate candidate) {
    final piece = board[candidate.fromRow][candidate.fromCol];
    if (piece == null) return;
    final move = _movePieceOnBoard(candidate.fromRow, candidate.fromCol, candidate.toRow, candidate.toCol, piece);
    if (move == null) return;
    moves.add(move);
    if (promotionPending && promotionPiece != null) {
      board[candidate.toRow][candidate.toCol] = ChessPiece(type: ChessPieceType.queen, isWhite: piece.isWhite)
        ..movesNum = piece.movesNum;
      promotionPending = false;
      promotionRow = null;
      promotionCol = null;
      promotionPiece = null;
    }
    whiteTurn = !whiteTurn;
  }

  double _evaluateBoard(bool aiWhite) {
    var score = 0.0;
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece == null) continue;
        final value = _pieceValue(piece) * 100 + _pieceSquareValue(piece, row, col);
        score += piece.isWhite == aiWhite ? value : -value;
      }
    }
    final ownMobility = legalMovesForColor(aiWhite).length;
    final enemyMobility = legalMovesForColor(!aiWhite).length;
    score += (ownMobility - enemyMobility) * 2.5;
    if (isKingInCheck(!aiWhite)) score += 35;
    if (isKingInCheck(aiWhite)) score -= 35;
    return score;
  }

  double _pieceSquareValue(ChessPiece piece, int row, int col) {
    final tableRow = piece.isWhite ? row : 7 - row;
    final center = 3.5 - (tableRow - 3.5).abs();
    return switch (piece.type) {
      ChessPieceType.pawn => tableRow * 1.5 + center * 2,
      ChessPieceType.knight => center * 7,
      ChessPieceType.bishop => center * 4,
      ChessPieceType.rook => (tableRow == 1 || tableRow == 6) ? 3 : 0,
      ChessPieceType.queen => center * 1.5,
      ChessPieceType.king => tableRow < 2 ? 8 : -center * 2,
    };
  }

  MoveCandidate? _openingBookMove(List<MoveCandidate> legal) {
    if (moves.length > 9) return null;
    const lines = [
      // Italian Game: 1.e4 e5 2.Nf3 Nc6 3.Bc4 Bc5 4.c3 Nf6 5.d3
      [[6, 4, 4, 4], [1, 4, 3, 4], [7, 6, 5, 5], [0, 1, 2, 2], [7, 5, 4, 2], [0, 5, 3, 2], [6, 2, 5, 2], [0, 6, 2, 5], [6, 3, 5, 3]],
      // Ruy Lopez: 1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7
      [[6, 4, 4, 4], [1, 4, 3, 4], [7, 6, 5, 5], [0, 1, 2, 2], [7, 1, 3, 5], [1, 0, 2, 0], [3, 5, 4, 4], [0, 6, 2, 5], [7, 4, 7, 6], [0, 5, 1, 4]],
      // Sicilian Defence: 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6
      [[6, 4, 4, 4], [1, 2, 3, 2], [7, 6, 5, 5], [1, 3, 2, 3], [6, 3, 4, 3], [3, 2, 4, 3], [7, 5, 5, 3], [0, 6, 2, 5]],
      // French Defence: 1.e4 e6 2.d4 d5 3.Nc3 Nf6 4.e5
      [[6, 4, 4, 4], [1, 4, 2, 4], [6, 3, 4, 3], [1, 3, 3, 3], [7, 1, 5, 2], [0, 6, 2, 5], [4, 4, 3, 4]],
      // Caro-Kann: 1.e4 c6 2.d4 d5 3.exd5 cxd5 4.Bd3
      [[6, 4, 4, 4], [1, 2, 2, 2], [6, 3, 4, 3], [1, 3, 3, 3], [4, 4, 3, 3], [2, 2, 3, 3], [7, 5, 5, 3]],
      // Queen's Gambit Declined: 1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Bg5
      [[6, 3, 4, 3], [1, 3, 3, 3], [6, 2, 4, 2], [1, 4, 2, 4], [7, 1, 5, 2], [0, 6, 2, 5], [7, 2, 4, 5]],
      // King's Indian: 1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6
      [[6, 3, 4, 3], [0, 6, 2, 5], [6, 2, 4, 2], [1, 6, 2, 6], [7, 1, 5, 2], [0, 5, 1, 6], [6, 4, 4, 4], [1, 3, 2, 3]],
      // English Opening: 1.c4 e5 2.Nc3 Nf6 3.g3 Bb4
      [[6, 2, 4, 2], [1, 4, 3, 4], [7, 1, 5, 2], [0, 6, 2, 5], [6, 6, 5, 6], [0, 5, 3, 1]],
      // Scandinavian Defence: 1.e4 d5 2.exd5 Qxd5 3.Nc3 Qd8
      [[6, 4, 4, 4], [1, 3, 3, 3], [4, 4, 3, 3], [0, 3, 3, 3], [7, 1, 5, 2], [3, 3, 0, 3]],
      // London System: 1.d4 d5 2.Nf3 Nf6 3.Bf4 e6 4.e3
      [[6, 3, 4, 3], [1, 3, 3, 3], [7, 6, 5, 5], [0, 6, 2, 5], [7, 2, 4, 5], [1, 4, 2, 4], [6, 4, 5, 4]],
    ];
    final matching = <MoveCandidate>[];
    for (final line in lines) {
      if (moves.length >= line.length) continue;
      var matches = true;
      for (var i = 0; i < moves.length; i++) {
        final move = moves[i];
        final expected = line[i];
        if (move.fromRow != expected[0] || move.fromCol != expected[1] || move.toRow != expected[2] || move.toCol != expected[3]) {
          matches = false;
          break;
        }
      }
      if (!matches) continue;
      final expected = line[moves.length];
      matching.addAll(legal.where((candidate) => candidate.fromRow == expected[0] && candidate.fromCol == expected[1] && candidate.toRow == expected[2] && candidate.toCol == expected[3]));
    }
    return matching.isEmpty ? null : matching[_random.nextInt(matching.length)];
  }

  double _pieceValue(ChessPiece piece) {
    return switch (piece.type) {
      ChessPieceType.pawn => 1,
      ChessPieceType.knight => 3,
      ChessPieceType.bishop => 3,
      ChessPieceType.rook => 5,
      ChessPieceType.queen => 9,
      ChessPieceType.king => 0,
    };
  }

  void _finishMove(MoveRecord move, {ChessPieceType promotionType = ChessPieceType.pawn}) {
    final currentIndex = moves.length - 1;
    if (currentIndex >= 0) {
      final updated = MoveRecord(
        fromRow: move.fromRow,
        fromCol: move.fromCol,
        toRow: move.toRow,
        toCol: move.toCol,
        type: move.type,
        isWhite: move.isWhite,
        took: move.took,
        isCheck: isKingInCheck(!whiteTurn),
        isCheckmate: isCheckMate(!whiteTurn),
        isStalemate: !isCheckMate(!whiteTurn) && !isKingInCheck(!whiteTurn) && !hasAnyLegalMove(!whiteTurn),
        kingCastle: move.kingCastle,
        queenCastle: move.queenCastle,
        promotionType: promotionType == ChessPieceType.pawn ? move.promotionType : promotionType,
      );
      moves[currentIndex] = updated;
      if (soundEnabled) {
        final sound = promotionType != ChessPieceType.pawn
            ? 'promote'
            : move.took
            ? 'capture'
            : move.kingCastle || move.queenCastle
                ? 'castle'
                : updated.isCheck
                    ? 'move-check'
                    : move.isWhite == humanPlaysWhite
                        ? 'move-self'
                        : 'move-opponent';
        unawaited(FeedbackService.instance.playSound(sound));
      }
      _hapticMedium();
    }
    whiteTurn = !whiteTurn;
    selectedRow = null;
    selectedCol = null;
    validMoves = [];
    final enemyWhite = whiteTurn;
    final enemyHasMoves = hasAnyLegalMove(enemyWhite);
    final enemyInCheck = isKingInCheck(enemyWhite);
    // The checked side is the side whose turn starts after this move.
    whiteKingChecked = enemyInCheck;
    gameOver = enemyInCheck && !enemyHasMoves;
    stalemate = !gameOver && !enemyInCheck && !enemyHasMoves;
    if (gameOver || stalemate) {
      _endGame(stalemate: stalemate);
      _hapticHeavy();
    }
    _pushHistory();
    notifyListeners();
    saveGame();
    _restartTimer();
    _scheduleAiMove();
  }

  void _hapticSelection() {
    if (hapticEnabled) {
      unawaited(FeedbackService.instance.selectionClick());
    }
  }

  void _hapticLight() {
    if (hapticEnabled) {
      unawaited(FeedbackService.instance.lightImpact());
    }
  }

  void _hapticMedium() {
    if (hapticEnabled) {
      unawaited(FeedbackService.instance.mediumImpact());
    }
  }

  void _hapticHeavy() {
    if (hapticEnabled) {
      unawaited(FeedbackService.instance.heavyImpact());
    }
  }
}

final ChessAppState appState = ChessAppState.instance;
