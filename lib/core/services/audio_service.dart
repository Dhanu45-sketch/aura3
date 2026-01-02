import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import '../models/sound.dart';
import '../services/download_service.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  final DownloadService _downloadService = downloadService;

  Sound? _currentSound;
  bool _isInitialized = false;

  // Getters
  AudioPlayer get player => _player;
  Sound? get currentSound => _currentSound;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;

  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;

  // Initialize audio session (mobile only)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.music());
      }
      _isInitialized = true;
      debugPrint('Audio service initialized');
    } catch (e) {
      _isInitialized = true;
      debugPrint('Audio session initialization skipped: $e');
    }
  }

  // Load and play sound - CHECK LOCAL FIRST
  Future<void> playSound(Sound sound) async {
    try {
      await initialize();
      _currentSound = sound;

      // PRIORITY 1: Check if downloaded locally
      final localPath = await _downloadService.getLocalFilePath(sound);

      if (localPath != null) {
        debugPrint('🎵 Playing from LOCAL storage: $localPath');
        await _player.setFilePath(localPath);
        await _player.play();
        return;
      }

      debugPrint('🌐 Playing from FIREBASE storage (not downloaded)');

      // PRIORITY 2: Play from local asset
      if (sound.localAssetPath != null) {
        await _player.setAsset(sound.localAssetPath!);
      }
      // PRIORITY 3: Stream from Firebase Storage
      else if (sound.firebaseStoragePath != null) {
        if (sound.firebaseStoragePath!.startsWith('http')) {
          await _player.setUrl(sound.firebaseStoragePath!);
        } else {
          final url = await _getFirebaseStorageUrl(sound.firebaseStoragePath!);
          await _player.setUrl(url);
        }
      } else {
        throw Exception('No audio source available for this sound');
      }

      await _player.play();
    } catch (e) {
      debugPrint('ERROR playing sound: $e');
      throw Exception('Failed to play sound: $e');
    }
  }

  // Get download URL from Firebase Storage
  Future<String> _getFirebaseStorageUrl(String path) async {
    try {
      final ref = FirebaseStorage.instance.ref(path);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Firebase Storage error: $e');
      throw Exception('Failed to get audio URL from Firebase Storage. Make sure the file exists at path: $path. Error: $e');
    }
  }

  // Play/Pause toggle
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  // Pause
  Future<void> pause() async {
    await _player.pause();
  }

  // Resume
  Future<void> resume() async {
    await _player.play();
  }

  // Stop
  Future<void> stop() async {
    await _player.stop();
    _currentSound = null;
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  // Set loop mode
  Future<void> setLoopMode(LoopMode loopMode) async {
    await _player.setLoopMode(loopMode);
  }

  // Skip forward
  Future<void> skipForward(Duration duration) async {
    final newPosition = _player.position + duration;
    if (_player.duration != null && newPosition < _player.duration!) {
      await _player.seek(newPosition);
    }
  }

  // Skip backward
  Future<void> skipBackward(Duration duration) async {
    final newPosition = _player.position - duration;
    await _player.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  // Dispose
  void dispose() {
    _player.dispose();
  }
}