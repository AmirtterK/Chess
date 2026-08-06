import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:chess_ritter/state/chess_app_state.dart';

ButtonStyle _compactButtonStyle(Color accent) => TextButton.styleFrom(
      minimumSize: const Size(180, 52),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      foregroundColor: accent,
      textStyle: const TextStyle(
        fontFamily: 'queen',
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );

class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final theme = appState.theme;
        final sideLabel = appState.humanPlaysWhite ? 'white' : 'black';
        final buttonStyle = _compactButtonStyle(theme.accent);
        const pagePadding = EdgeInsets.fromLTRB(20, 48, 20, 8);

        return Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(gradient: theme.background),
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: pagePadding,
                    sliver: SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 620),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Image.asset('assets/themes/tournament/bn.png', width: 80, height: 80),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 18),
                                      child: Text(
                                        'Chess Ritter',
                                        style: TextStyle(
                                          fontFamily: 'queen',
                                          fontSize: 50,
                                          color: Color(0xFF6C6C6C),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              _MenuCard(
                                title: 'side',
                                titleColor: theme.accent,
                                child: CupertinoSlidingSegmentedControl<int>(
                                  groupValue: appState.humanPlaysWhite ? 0 : 1,
                                  children: const {
                                    0: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('White')),
                                    1: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('Black')),
                                  },
                                  onValueChanged: (value) {
                                    if (value != null) appState.setHumanPlaysWhite(value == 0);
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              _MenuCard(
                                title: 'time',
                                titleColor: theme.accent,
                                child: CupertinoSlidingSegmentedControl<int>(
                                  groupValue: appState.timeLimitIndex,
                                  children: const {
                                    0: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('None')),
                                    1: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('10m')),
                                    2: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('15m')),
                                    3: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('30m')),
                                  },
                                  onValueChanged: (value) {
                                    if (value != null) appState.setTimeLimitIndex(value);
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              _MenuCard(
                                title: 'game mode',
                                titleColor: theme.accent,
                                child: CupertinoSlidingSegmentedControl<int>(
                                  groupValue: appState.gameMode.index,
                                  children: const {
                                    0: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('2 Player')),
                                    1: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('vs AI')),
                                  },
                                  onValueChanged: (value) {
                                    if (value != null) appState.setGameMode(GameMode.values[value]);
                                  },
                                ),
                              ),
                              if (appState.gameMode == GameMode.vsAi)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 18),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'AI ${appState.aiName} · ${appState.aiDifficultyLabel}',
                                            style: TextStyle(color: theme.accent, fontSize: 18, fontWeight: FontWeight.w700),
                                          ),
                                          Text(
                                            ' · ${appState.aiElo} Elo',
                                            style: TextStyle(color: theme.accent, fontSize: 18, fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      CupertinoSlidingSegmentedControl<int>(
                                          groupValue: appState.aiDifficulty,
                                          children: const {
                                            1: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('I')),
                                            2: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('II')),
                                            3: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('III')),
                                            4: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('IV')),
                                            5: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('V')),
                                          },
                                          onValueChanged: (value) {
                                            if (value != null) appState.setAiDifficulty(value);
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              const Spacer(),
                              TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  appState.newGame();
                                  context.pushNamed('Gameboard');
                                },
                                child: const Text('New Game'),
                              ),
                              TextButton(
                                style: buttonStyle,
                                onPressed: () => context.pushNamed('Settings'),
                                child: const Text('Settings'),
                              ),
                              if (appState.canResumeSavedGame)
                                TextButton(
                                  style: buttonStyle,
                                  onPressed: () => context.pushNamed('Gameboard'),
                                  child: const Text('resume'),
                                ),
                              // const SizedBox(height: 8),
                              // Text(
                              //   'Mode: ${appState.gameMode == GameMode.vsAi ? 'AI' : 'Local'} | Side: $sideLabel',
                              //   textAlign: TextAlign.center,
                              //   style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                              // ),
                            ],
                          ),
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

class _MenuCard extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Widget child;

  const _MenuCard({required this.title, required this.titleColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontFamily: 'queen', fontSize: 25, color: titleColor)),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}
