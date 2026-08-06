import 'package:flutter/material.dart';

import 'package:chess_ritter/components/piece.dart';

class Progress extends StatelessWidget {
  final bool whiteOnBottom;
  final int whiteScore;
  final int blackScore;
  final Duration whiteTime;
  final Duration blackTime;
  final List<ChessPiece> capturedWhite;
  final List<ChessPiece> capturedBlack;
  final String pieceTheme;
  final String topLabel;
  final String bottomLabel;

  const Progress({
    super.key,
    required this.whiteOnBottom,
    required this.whiteScore,
    required this.blackScore,
    required this.whiteTime,
    required this.blackTime,
    required this.capturedWhite,
    required this.capturedBlack,
    required this.pieceTheme,
    required this.topLabel,
    required this.bottomLabel,
  });

  @override
  Widget build(BuildContext context) {
    final topCaptured = whiteOnBottom ? capturedWhite : capturedBlack;
    final bottomCaptured = whiteOnBottom ? capturedBlack : capturedWhite;
    final topTime = whiteOnBottom ? blackTime : whiteTime;
    final bottomTime = whiteOnBottom ? whiteTime : blackTime;
    final topScore = whiteOnBottom ? blackScore : whiteScore;
    final bottomScore = whiteOnBottom ? whiteScore : blackScore;

    return Column(
      children: [
        _RowStrip(
          label: topLabel,
          score: topScore,
          time: topTime,
          captured: topCaptured,
          pieceTheme: pieceTheme,
        ),
        const SizedBox(height: 10),
        _RowStrip(
          label: bottomLabel,
          score: bottomScore,
          time: bottomTime,
          captured: bottomCaptured,
          pieceTheme: pieceTheme,
        ),
      ],
    );
  }
}

class _RowStrip extends StatefulWidget {
  final String label;
  final int score;
  final Duration time;
  final List<ChessPiece> captured;
  final String pieceTheme;

  const _RowStrip({
    required this.label,
    required this.score,
    required this.time,
    required this.captured,
    required this.pieceTheme,
  });

  @override
  State<_RowStrip> createState() => _RowStripState();
}

class _RowStripState extends State<_RowStrip> {
  final ScrollController _capturedController = ScrollController();

  @override
  void didUpdateWidget(covariant _RowStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.captured.length != widget.captured.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _capturedController.hasClients) {
          _capturedController.animateTo(
            _capturedController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _capturedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                controller: _capturedController,
                itemCount: widget.captured.length,
                separatorBuilder: (_, __) => const SizedBox(width: 2),
                itemBuilder: (context, index) => Piece(
                  piece: widget.captured[index],
                  theme: widget.pieceTheme,
                  size: 32,
                ),
              ),
            ),
          ),
          Text(
            widget.score > 0 ? '+${widget.score}' : '0',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 10),
          Text(
            '${widget.time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${widget.time.inSeconds.remainder(60).toString().padLeft(2, '0')}',
            style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }
}
