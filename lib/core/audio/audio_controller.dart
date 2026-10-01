import 'dart:async';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized Audio Controller managing Background Music (BGM),
/// Sound Effects (SFX), and user mute preferences with persistence.
class AudioController {
  AudioController._internal();

  static final AudioController instance = AudioController._internal();
  factory AudioController() => instance;

  static const String _prefBgmMuted = 'audio_bgm_muted';
  static const String _prefSfxMuted = 'audio_sfx_muted';

  final ValueNotifier<bool> bgmMutedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> sfxMutedNotifier = ValueNotifier<bool>(false);

  bool get isBgmMuted => bgmMutedNotifier.value;
  bool get isSfxMuted => sfxMutedNotifier.value;

  double bgmVolume = 0.6;
  double sfxVolume = 1.0;

  bool _isInitialized = false;
  bool _isBgmPlaying = false;

  /// Initializes SharedPreferences, audio cache, and preloads assets.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      bgmMutedNotifier.value = prefs.getBool(_prefBgmMuted) ?? false;
      sfxMutedNotifier.value = prefs.getBool(_prefSfxMuted) ?? false;
    } catch (e) {
      debugPrint('AudioController: SharedPreferences init error: $e');
    }

    try {
      FlameAudio.audioCache.prefix = 'assets/audio/';
      FlameAudio.bgm.initialize();
      // Preload sound effects
      await FlameAudio.audioCache.loadAll([
        'jump.wav',
        'coin.wav',
        'shoot.wav',
        'hit.wav',
        'game_over.wav',
      ]);
    } catch (e) {
      debugPrint('AudioController: Audio preload error: $e');
    }

    _isInitialized = true;
  }

  /// Plays background music in a loop if not muted.
  Future<void> playBgm({String track = 'bgm.mp3'}) async {
    if (isBgmMuted) {
      _isBgmPlaying = false;
      return;
    }

    try {
      FlameAudio.audioCache.prefix = 'assets/audio/';
      await FlameAudio.bgm.play(track, volume: bgmVolume);
      _isBgmPlaying = true;
    } catch (e) {
      debugPrint('AudioController: playBgm error: $e');
    }
  }

  /// Pauses background music.
  void pauseBgm() {
    try {
      if (FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.pause();
      }
    } catch (e) {
      debugPrint('AudioController: pauseBgm error: $e');
    }
  }

  /// Resumes background music if not muted.
  void resumeBgm() {
    if (isBgmMuted) return;

    try {
      if (_isBgmPlaying) {
        FlameAudio.bgm.resume();
      } else {
        playBgm();
      }
    } catch (e) {
      debugPrint('AudioController: resumeBgm error: $e');
    }
  }

  /// Stops background music.
  void stopBgm() {
    _isBgmPlaying = false;
    try {
      FlameAudio.bgm.stop();
    } catch (e) {
      debugPrint('AudioController: stopBgm error: $e');
    }
  }

  /// Plays a short sound effect if SFX is not muted.
  Future<void> playSfx(String fileName, {double? volume}) async {
    if (isSfxMuted) return;

    try {
      FlameAudio.audioCache.prefix = 'assets/audio/';
      await FlameAudio.play(fileName, volume: volume ?? sfxVolume);
    } catch (e) {
      debugPrint('AudioController: playSfx($fileName) error: $e');
    }
  }

  /// Sound effect helpers
  void playJump() => playSfx('jump.wav');
  void playCoin() => playSfx('coin.wav');
  void playShoot() => playSfx('shoot.wav');
  void playHit() => playSfx('hit.wav');
  void playGameOver() => playSfx('game_over.wav');

  /// Toggles BGM mute state and persists preference.
  Future<void> toggleBgm() async {
    final newValue = !bgmMutedNotifier.value;
    bgmMutedNotifier.value = newValue;

    if (newValue) {
      pauseBgm();
    } else {
      resumeBgm();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefBgmMuted, newValue);
    } catch (e) {
      debugPrint('AudioController: Save BGM pref error: $e');
    }
  }

  /// Toggles SFX mute state and persists preference.
  Future<void> toggleSfx() async {
    final newValue = !sfxMutedNotifier.value;
    sfxMutedNotifier.value = newValue;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefSfxMuted, newValue);
    } catch (e) {
      debugPrint('AudioController: Save SFX pref error: $e');
    }
  }
}
