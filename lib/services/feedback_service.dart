import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Centralizes the short-lived sound and haptic effects used by the game.
class FeedbackService {
  FeedbackService._();

  static final FeedbackService instance = FeedbackService._();

  AudioContext get _audioContext => AudioContext(
        android: const AudioContextAndroid(
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
      );

  Future<void> initialize() => AudioPlayer.global.setAudioContext(_audioContext);

  Future<void> playSound(String sound) async {
    final player = AudioPlayer();
    try {
      await player.setAudioContext(
        _audioContext,
      );
      await player.play(AssetSource('sounds/$sound.mp3'));
      final completed = Future.any<void>([
        player.onPlayerComplete.first,
        Future<void>.delayed(const Duration(seconds: 2)),
      ]);
      await completed;
    } catch (_) {
      // A missing or unsupported sound must never interrupt a chess move.
    } finally {
      await player.dispose();
    }
  }

  Future<void> selectionClick() => HapticFeedback.selectionClick();

  Future<void> lightImpact() => HapticFeedback.lightImpact();

  Future<void> mediumImpact() => HapticFeedback.mediumImpact();

  Future<void> heavyImpact() => HapticFeedback.heavyImpact();
}
