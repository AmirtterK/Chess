import 'dart:math';

import 'package:chess_game/Components/data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 70,bottom: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: Image.asset("assets/themes/tournament/bn.png"),
                  ),
                  Text(
                    "chess",
                    style: TextStyle(
                        fontSize: 50,
                        color: const Color.fromARGB(255, 108, 108, 108),
                        fontFamily: "queen"),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "side",
              style: TextStyle(
                fontFamily: "queen",
                fontSize: 25,
                color: const Color.fromARGB(255, 108, 108, 108),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            CupertinoSlidingSegmentedControl(
              groupValue: startingColor,
              children: startingColorsOptions,
              onValueChanged: (i) => setState(
                () {
                  startingColor = i!;
                },
              ),
            ),
           
          
            
            Spacer(),
            Align(
              child: TextButton(
                onPressed: () {
                  if (startingColor == 0) {
                    startWhite();
                  } else if (startingColor == 1) {
                    startBlack();
                  } else {
                    Random random = Random();
                    random.nextBool() ? startWhite() : startBlack();
                  }
                  context.pushNamed("Gameboard");
                },
                child: Text(
                  "start",
                  style: TextStyle(
                    fontFamily: "queen",
                    fontSize: 25,
                    color: const Color.fromARGB(255, 108, 108, 108),
                  ),
                ),
              ),
            ),
            Align(
              child: TextButton(
                onPressed: () {
                 
                  context.pushNamed("Settings");
                },
                child: Text(
                  "settings",
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
