import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cowboycavead/core/audio/audio_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone 9: Audio System & Controller Tests', () {
    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('xyz.luan/audioplayers.global'),
        (MethodCall methodCall) async => 1,
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('xyz.luan/audioplayers'),
        (MethodCall methodCall) async => 1,
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async => '.',
      );
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'audio_bgm_muted': false,
        'audio_sfx_muted': false,
      });
    });

    test('AudioController singleton returns same instance', () {
      final a1 = AudioController();
      final a2 = AudioController.instance;
      expect(identical(a1, a2), isTrue);
    });

    test('AudioController initializes defaults and preferences properly', () async {
      final audio = AudioController.instance;
      await audio.init();

      expect(audio.isBgmMuted, isFalse);
      expect(audio.isSfxMuted, isFalse);
      expect(audio.bgmVolume, equals(0.6));
      expect(audio.sfxVolume, equals(1.0));
    });

    test('AudioController toggleBgm updates state and ValueNotifier', () async {
      final audio = AudioController.instance;
      audio.bgmMutedNotifier.value = false;

      bool notifierFired = false;
      void listener() {
        notifierFired = true;
      }

      audio.bgmMutedNotifier.addListener(listener);

      await audio.toggleBgm();
      expect(audio.isBgmMuted, isTrue);
      expect(notifierFired, isTrue);

      await audio.toggleBgm();
      expect(audio.isBgmMuted, isFalse);

      audio.bgmMutedNotifier.removeListener(listener);
    });

    test('AudioController toggleSfx updates state and ValueNotifier', () async {
      final audio = AudioController.instance;
      audio.sfxMutedNotifier.value = false;

      bool notifierFired = false;
      void listener() {
        notifierFired = true;
      }

      audio.sfxMutedNotifier.addListener(listener);

      await audio.toggleSfx();
      expect(audio.isSfxMuted, isTrue);
      expect(notifierFired, isTrue);

      await audio.toggleSfx();
      expect(audio.isSfxMuted, isFalse);

      audio.sfxMutedNotifier.removeListener(listener);
    });

    test('AudioController safe SFX & BGM helper methods execute without throwing uncaught errors', () async {
      final audio = AudioController.instance;

      // Ensure that calling sound effect and BGM triggers in test runner without audio device doesn't crash
      expect(() => audio.playJump(), returnsNormally);
      expect(() => audio.playCoin(), returnsNormally);
      expect(() => audio.playShoot(), returnsNormally);
      expect(() => audio.playHit(), returnsNormally);
      expect(() => audio.playGameOver(), returnsNormally);
      expect(() => audio.pauseBgm(), returnsNormally);
      expect(() => audio.resumeBgm(), returnsNormally);
      expect(() => audio.stopBgm(), returnsNormally);
    });
  });
}
