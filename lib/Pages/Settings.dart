import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:chess_ritter/components/piece.dart';
import 'package:chess_ritter/state/app_theme.dart';
import 'package:chess_ritter/state/chess_app_state.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late FixedExtentScrollController _themeController;
  late FixedExtentScrollController _pieceController;

  @override
  void initState() {
    super.initState();
    _themeController = FixedExtentScrollController(initialItem: appState.themeIndex);
    _pieceController = FixedExtentScrollController(initialItem: appState.pieceThemeIndex);
  }

  @override
  void dispose() {
    _themeController.dispose();
    _pieceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final theme = appState.theme;
        if (_themeController.hasClients && _themeController.selectedItem != appState.themeIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_themeController.hasClients) {
              _themeController.jumpToItem(appState.themeIndex);
            }
          });
        }
        if (_pieceController.hasClients && _pieceController.selectedItem != appState.pieceThemeIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pieceController.hasClients) {
              _pieceController.jumpToItem(appState.pieceThemeIndex);
            }
          });
        }
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(gradient: theme.background),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _Header(),
                  const SizedBox(height: 20),
                  _ThemePicker(
                    title: 'theme',
                    controller: _themeController,
                    names: appThemes.map((entry) => entry.name).toList(),
                    onSelectedItemChanged: appState.setThemeIndex,
                    preview: _ThemePreview(
                      colors: [appState.theme.lightTile, appState.theme.darkTile],
                      pieceTheme: appState.pieceTheme,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ThemePicker(
                    title: 'piece theme',
                    controller: _pieceController,
                    names: appState.pieceThemes,
                    onSelectedItemChanged: appState.setPieceThemeIndex,
                    preview: _ThemePreview(
                      colors: [appState.theme.lightTile, appState.theme.darkTile],
                      pieceTheme: appState.pieceTheme,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ToggleCard(
                    title: 'Gameplay',
                    accent: theme.accent,
                    children: [
                      _ToggleRow(
                        label: 'Auto-Rotate Board (2P)',
                        value: appState.enableRotation,
                        onChanged: appState.setEnableRotation,
                        enabled: appState.gameMode == GameMode.localTwoPlayer,
                        accent: theme.accent,
                      ),
                      _ToggleRow(
                        label: 'Auto-Rotate Pieces (2P)',
                        value: appState.enablePieceRotation,
                        onChanged: appState.setEnablePieceRotation,
                        enabled: appState.gameMode == GameMode.localTwoPlayer &&
                            !appState.enableRotation,
                        accent: theme.accent,
                      ),
                      _ToggleRow(
                        label: 'Move Hints',
                        value: appState.showHints,
                        onChanged: appState.setShowHints,
                        accent: theme.accent,
                      ),
                      _ToggleRow(
                        label: 'Move History',
                        value: appState.showMoveHistory,
                        onChanged: appState.setShowMoveHistory,
                        accent: theme.accent,
                      ),
                      _ToggleRow(
                        label: 'Notation',
                        value: appState.showNotation,
                        onChanged: appState.setShowNotation,
                        accent: theme.accent,
                      ),
                      _ToggleRow(
                        label: 'Undo / Redo',
                        value: appState.allowUndoRedo,
                        onChanged: appState.setAllowUndoRedo,
                        accent: theme.accent,
                      ),
                      _ToggleRow(
                        label: 'Sound',
                        value: appState.soundEnabled,
                        onChanged: appState.setSoundEnabled,
                        accent: theme.accent,
                      ),
                      _ToggleRow(
                        label: 'Haptics',
                        value: appState.hapticEnabled,
                        onChanged: appState.setHapticEnabled,
                        accent: theme.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ToggleCard(
                    title: 'Game Mode',
                    accent: theme.accent,
                    children: [
                      _SegmentRow(
                        label: 'Default Mode',
                        value: appState.gameMode.index,
                        segments: const {0: '2 Player', 1: 'vs AI'},
                        onChanged: (value) {
                          if (value != null) {
                            appState.setGameMode(GameMode.values[value]);
                          }
                        },
                      ),
                      _SegmentRow(
                        label: 'AI Difficulty (${appState.aiDifficultyLabel})',
                        value: appState.aiDifficulty,
                        segments: const {
                          1: 'I',
                          2: 'II',
                          3: 'III',
                          4: 'IV',
                          5: 'V',
                        },
                        onChanged: (value) {
                          if (value != null) appState.setAiDifficulty(value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ActionCard(
                    title: 'Reset Settings',
                    subtitle: 'Restore the original values for all preferences.',
                    label: 'Reset',
                    accent: theme.accent,
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (dialogContext) => CupertinoAlertDialog(
                          title: const Text(
                            'Reset settings?',
                            style: TextStyle(fontFamily: 'queen'),
                          ),
                          content: const Text(
                            'This will restore theme, gameplay, and audio preferences to defaults.',
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
                                appState.resetSettingsToDefaults();
                              },
                              child: const Text('Reset', style: TextStyle(fontFamily: 'queen')),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        'back',
                        style: TextStyle(
                          fontFamily: 'queen',
                          fontSize: 25,
                          color: Color(0xFF6C6C6C),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFFC2C2C2),
              size: 32,
            ),
            tooltip: 'Back',
          ),
        const Text(
          'settings',
          style: TextStyle(fontFamily: 'queen', fontSize: 25, color: Color(0xFFC2C2C2)),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _ThemePicker extends StatelessWidget {
  final String title;
  final FixedExtentScrollController controller;
  final List<String> names;
  final ValueChanged<int> onSelectedItemChanged;
  final Widget preview;

  const _ThemePicker({
    required this.title,
    required this.controller,
    required this.names,
    required this.onSelectedItemChanged,
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'queen',
              fontSize: 25,
              color: Color(0xFFC2C2C2),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          child: SizedBox(
            height: 120,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    scrollController: controller,
                    itemExtent: 50,
                    onSelectedItemChanged: onSelectedItemChanged,
                    children: names
                        .map(
                          (name) => Container(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: Color(0xFFABABAB),
                                fontFamily: 'queen',
                                fontSize: 21,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                preview,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemePreview extends StatelessWidget {
  final List<Color> colors;
  final String pieceTheme;

  const _ThemePreview({required this.colors, required this.pieceTheme});

  @override
  Widget build(BuildContext context) {
    final pieces = [
      ChessPiece(type: ChessPieceType.king, isWhite: false),
      ChessPiece(type: ChessPieceType.queen, isWhite: true),
      ChessPiece(type: ChessPieceType.rook, isWhite: true),
      ChessPiece(type: ChessPieceType.bishop, isWhite: false),
      ChessPiece(type: ChessPieceType.knight, isWhite: false),
      ChessPiece(type: ChessPieceType.pawn, isWhite: true),
    ];
    return SizedBox(
      width: 80,
      height: 120,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: pieces.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final piece = pieces[index];
          final flipRow = (index ~/ 2).isEven;
          final isLightTile = flipRow ? index.isEven : index.isOdd;
          return Container(
            color: isLightTile ? colors[0] : colors[1],
            child: Piece(
              piece: piece,
              theme: pieceTheme,
              size: 40,
            ),
          );
        },
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final String title;
  final Color accent;
  final List<Widget> children;
  const _ToggleCard({required this.title, required this.accent, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: accent.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toLowerCase(),
            style: const TextStyle(
              fontFamily: 'queen',
              color: Color(0xFFC2C2C2),
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final Color accent;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.accent,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: enabled ? onChanged : null,
      title: Text(label),
      activeThumbColor: accent,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _SegmentRow extends StatelessWidget {
  final String label;
  final int value;
  final Map<int, String> segments;
  final ValueChanged<int?> onChanged;

  const _SegmentRow({
    required this.label,
    required this.value,
    required this.segments,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'queen')),
          const SizedBox(height: 8),
          CupertinoSlidingSegmentedControl<int>(
            groupValue: value,
            children: {
              for (final entry in segments.entries)
                entry.key: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(entry.value),
                ),
            },
            onValueChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String label;
  final VoidCallback onPressed;
  final Color accent;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.label,
    required this.onPressed,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: accent.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toLowerCase(),
            style: const TextStyle(
              fontFamily: 'queen',
              color: Color(0xFFC2C2C2),
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(subtitle),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              onPressed: onPressed,
              child: Text(
                label,
                style: const TextStyle(fontFamily: 'queen'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
