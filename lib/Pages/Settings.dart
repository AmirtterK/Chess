import 'package:chess_game/Components/data.dart';
import 'package:chess_game/Components/piece.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(top: 30, right: 30, left: 30, bottom: 40),
        child: Column(
          children: [
            SizedBox(
              height: 80,
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "theme",
                style: TextStyle(
                  fontFamily: "queen",
                  fontSize: 25,
                      color: Color.fromARGB(255, 194, 194, 194),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: SizedBox(
                height: 120,
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                            initialItem: selectedThemeIndex),
                        itemExtent: 50,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            pieceTheme = themes[index];
                            selectedThemeIndex = index;
                          });
                        },
                        children: themes
                            .map((theme) => Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    theme,
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 171, 171, 171),
                                      fontFamily: "queen",
                                      fontSize: 21,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      height: 120,
                      child: Wrap(
                          children: pieces
                              .map((piece) => Container(
                                    width: 40,
                                    height: 40,
                                    color: piece.isWhite
                                        ? Colors.grey.shade600
                                        : Colors.white70,
                                    child: Image.asset(imagePath(piece)),
                                  ))
                              .toList()),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 40,),
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 30, right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Show Hints',
                    style: TextStyle(
                      color: Color.fromARGB(255, 194, 194, 194),
                      fontFamily: "queen",
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  CupertinoSwitch(
                    activeTrackColor:  Color.fromARGB(255, 220, 63, 223).withAlpha(200),
                    value: showHints,
                    onChanged: (value) => setState(() {
                      showHints = !showHints;
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 30, right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Show Move History',
                    style: TextStyle(
                      color: Color.fromARGB(255, 194, 194, 194),
                      fontFamily: "queen",
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  CupertinoSwitch(
                    activeTrackColor:  Color.fromARGB(255, 220, 63, 223).withAlpha(200),
                    value: showMoveHistory,
                    onChanged: (value) => setState(() {
                      showMoveHistory = !showMoveHistory;
                    }),
                  ),
                ],
              ),
            ),
            Spacer(),
            Align(
              child: TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Text(
                  "back",
                  style: TextStyle(
                    fontFamily: "queen",
                    fontSize: 25,
                    color: const Color.fromARGB(255, 108, 108, 108),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
