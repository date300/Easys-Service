// ============================================================
//  AppSoundService — Global Sound System (URL Based)
//  Location: lib/core/services/app_sound_service.dart
//
//  pubspec.yaml এ শুধু এটুকু যোগ করো:
//  dependencies:
//    audioplayers: ^6.1.0
// ============================================================

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AppSoundService {
  AppSoundService._();
  static final AppSoundService instance = AppSoundService._();

  bool _enabled = true;
  bool get soundEnabled => _enabled;
  set soundEnabled(bool val) => _enabled = val;

  // ── Reliable CDN Sound URLs ────────────────────────────────
  static const _sounds = {
    'success': 'https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3',
    'error'  : 'https://assets.mixkit.co/active_storage/sfx/2955/2955-preview.mp3',
    'otp'    : 'https://assets.mixkit.co/active_storage/sfx/2866/2866-preview.mp3',
    'login'  : 'https://assets.mixkit.co/active_storage/sfx/1435/1435-preview.mp3',
    'tap'    : 'https://assets.mixkit.co/active_storage/sfx/2568/2568-preview.mp3',
  };

  // ── Volume per sound ───────────────────────────────────────
  static const _volumes = {
    'success': 0.85,
    'error'  : 0.80,
    'otp'    : 0.75,
    'login'  : 0.90,
    'tap'    : 0.45,
  };

  // ── Reusable players ───────────────────────────────────────
  final _players = <String, AudioPlayer>{};

  // ── Core play method ───────────────────────────────────────
  Future<void> _play(String key) async {
    if (!_enabled) return;
    try {
      final player = _players.putIfAbsent(key, () => AudioPlayer());
      await player.stop();
      await player.setVolume(_volumes[key] ?? 0.8);
      await player.play(UrlSource(_sounds[key]!));
    } catch (e) {
      debugPrint('[AppSoundService] Could not play "$key": $e');
    }
  }

  // ── Public API ─────────────────────────────────────────────

  /// ✅ Registration / save / API success
  Future<void> playSuccess() => _play('success');

  /// ❌ API error / validation fail / network error
  Future<void> playError() => _play('error');

  /// 📨 OTP sent to email or phone
  Future<void> playOtp() => _play('otp');

  /// 🔐 Login success / OTP verified / entering app
  Future<void> playLogin() => _play('login');

  /// 👆 Light button tap feedback
  Future<void> playTap() => _play('tap');

  /// 🔁 Condition based — success অথবা error auto select
  Future<void> playResult({required bool success}) =>
      success ? playSuccess() : playError();

  /// 🔕 Toggle sound on/off
  void toggleSound() => _enabled = !_enabled;

  // ── Cleanup ────────────────────────────────────────────────
  Future<void> dispose() async {
    for (final p in _players.values) {
      await p.dispose();
    }
    _players.clear();
  }
}
