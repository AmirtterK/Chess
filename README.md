# Chess Ritter

A Flutter chess app with local 2-player play, a fast built-in AI, saved game resume, board rotation, move history, undo/redo, themes, sound, and haptic feedback.

## Features

- Local 2-player mode
- Optional AI opponent
- Save and resume the current game
- Undo and redo
- Board rotation and piece rotation options
- Move history with clickable review
- Promotion dialog
- Sound and haptic toggles
- App theme picker
- Piece theme picker
- Show hints and notation toggles
- Time control presets

## How To Play

1. Open the app.
2. Choose `2 Player` or `vs AI`.
3. Pick the side or orientation.
4. Choose a time control if you want one.
5. Tap `New Game`.
6. Move pieces by tapping a piece and then a legal destination square.

If you leave a match, the current game is saved automatically and can be resumed from the start screen.

## Settings

The settings page lets you configure:

- App theme
- Piece theme
- Auto-rotate board
- Auto-rotate pieces
- Move hints
- Move history
- Notation
- Undo/redo
- Sound
- Haptics
- Default game mode
- AI difficulty

## How The AI Works

The AI in this project is a built-in Dart engine. It does not rely on Stockfish or any external chess engine, and it is tuned to stay fast.

### AI Code Path

The core AI flow lives in [`lib/state/chess_app_state.dart`](C:/Users/LENOVO/Documents/Coding/Flutter/Chess/lib/state/chess_app_state.dart):

- `_scheduleAiMove()` waits 350 ms after the position changes, then starts the AI turn.
- `_pickAiMove()` gathers legal moves, checks for immediate checkmate, consults the opening book when enabled, and then searches/evaluates candidates.
- `legalMovesForColor()` and `legalMovesForPiece()` enforce king safety, check responses, castling, en passant, and promotion moves.
- `_minimax()` performs a bounded alpha-beta search for the stronger difficulty levels.
- `completePromotion()` finalizes pawn promotion after the player or AI reaches the last rank.
- `_aiRequestId` cancels stale delayed AI requests after undo, redo, restart, or history changes.

The AI only runs when:

- `gameMode == vsAi`
- the current turn belongs to the AI side
- the game is not over
- no promotion dialog is pending
- the player is not reviewing move history

### Move Selection Flow

1. The app builds a list of all legal moves for the AI side.
2. The AI immediately prefers a move that checkmates the opponent.
3. Difficulties III–V can follow a small opening book during the early game.
4. The remaining candidates are ordered and evaluated with a shallow minimax search.
5. Difficulty I chooses randomly from up to four of the best-scored candidates; difficulty II chooses from up to two; difficulties III–V choose the highest-scoring result.

### Evaluation Heuristic

The AI uses a simple board evaluation:

- Pawn = 1 point
- Knight = 3 points
- Bishop = 3 points
- Rook = 5 points
- Queen = 9 points
- King = 0 points

It prefers moves that:

- Win material
- Give check or checkmate
- Promote a pawn
- Improve piece position and mobility
- Avoid leaving its own king in check

### Search Depth

The current AI is intentionally lightweight and bounded for mobile devices:

- Difficulty I searches one ply.
- Difficulty II searches two ply.
- Difficulties III–V search up to three ply.
- Every search is capped at 12,000 search nodes or 300 ms, whichever comes first.
- The AI runs inside the app and does not spawn a separate engine process.

### Strengths And Limits

This AI is fast and self-contained, but it is not a grandmaster engine.

It understands:

- Legal move generation
- Check and checkmate safety
- Castling, en passant, and promotion
- Basic material, mobility, positional, and king-safety evaluation
- Undo/redo and history cancellation while an AI request is pending

It does not provide:

- A large or comprehensive opening book
- Endgame tablebases
- Stockfish-level evaluation

## Project Structure

- `lib/main.dart` - app bootstrap and routing
- `lib/state/chess_app_state.dart` - shared state, game logic, persistence, and AI
- `lib/Pages/Start.dart` - start screen and game setup
- `lib/Pages/Gameboard.dart` - board screen and controls
- `lib/Pages/Settings.dart` - settings screen
- `lib/components/piece.dart` - piece model and rendering helper
- `lib/components/Tile.dart` - board tile widget
- `lib/components/progress.dart` - score and timer strip
- `lib/components/move.dart` - move record and notation helpers

## Running The App

```bash
flutter pub get
flutter run
```

## Testing

```bash
flutter test
```

## Notes

- The app stores preferences with `shared_preferences`.
- Saved games are restored from the last saved position.
- The AI is designed to be easy to understand and extend.
