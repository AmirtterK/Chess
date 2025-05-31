import 'package:chess_game/Components/data.dart';
import 'package:chess_game/Components/deadPiece.dart';
import 'package:chess_game/Components/piece.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Progress extends StatefulWidget {
  final bool isWhite;
  final int whiteScore;
  final int blackScore;
  final Duration pTime;
  final List<ChessPiece> piecestaken;
  const Progress({
    super.key,
    required this.isWhite,
    required this.whiteScore,
    required this.blackScore,
    required this.pTime,
    required this.piecestaken,
  });

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20, left: 10),
        child: SizedBox(
          height: 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                alignment: WrapAlignment.start,
                children: widget.piecestaken
                    .map((piece) =>
                        DeadPiece(isWhite: widget.isWhite, piece: piece))
                    .toList(),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  if (widget.isWhite)
                    SizedBox(
                        height: 20,
                        child: widget.whiteScore > widget.blackScore
                            ? Text("+${widget.whiteScore - widget.blackScore}")
                            : null)
                  else
                    SizedBox(
                        height: 20,
                        child: widget.blackScore > widget.whiteScore
                            ? Text("+${widget.blackScore - widget.whiteScore}")
                            : null),
                  if (timeLimit != 0) ...{
                    Spacer(),
                    Text("${widget.pTime.inMinutes.remainder(60).toString().padLeft(2, "0")}:${(widget.pTime.inSeconds.remainder(60)).toString().padLeft(2, "0")}"),
                    SizedBox(
                      width: 20,
                    ),
                  }
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
