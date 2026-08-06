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

- `_scheduleAiMove()` waits briefly after the human move and then triggers the AI turn.
- `_pickAiMove()` gathers legal moves and chooses one based on difficulty.
- `legalMovesForColor()` and `legalMovesForPiece()` generate only legal chess moves.
- `_scoreCandidate()` applies a cheap heuristic for higher difficulties.
- `completePromotion()` finalizes pawn promotion after the AI or player reaches the last rank.

The AI only runs when:

- `gameMode == vsAi`
- the current turn belongs to the AI side
- the game is not over
- no promotion dialog is pending
- the player is not reviewing move history

### Move Selection Flow

1. The app builds a list of all legal moves for the AI side.
2. Very easy difficulty picks a random legal move.
3. Higher difficulties score each move with a cheap heuristic and choose the best one.

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
- Give check
- Promote a pawn
- Avoid leaving its own king in check

### Search Depth

The current AI is intentionally lightweight and fast:

- Lower difficulty levels lean on randomness
- Higher difficulty levels use a shallow move score
- The app keeps the logic fast enough for mobile and desktop without spawning a heavy engine process

### Strengths And Limits

This AI is fast and self-contained, but it is not a grandmaster engine.

It understands:

- Legal move generation
- Check and checkmate safety
- Basic positional/material value

It does not yet do:

- Deep multi-ply search
- Opening books
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
