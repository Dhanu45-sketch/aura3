import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/models/sound.dart';
import '../../../core/services/audio_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();

  Sound? _currentSound;
  bool _isLoading = false;
  String? _errorMessage;
  double _volume = 1.0;
  bool _isLooping = false;

  // Playlist context
  String? _currentPlaylistId;
  List<Sound> _currentPlaylist = [];
  int _currentIndex = 0;

  // Getters
  Sound? get currentSound => _currentSound;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPlaying => _audioService.isPlaying;
  Duration get position => _audioService.position;
  Duration? get duration => _audioService.duration;
  double get volume => _volume;
  bool get isLooping => _isLooping;

  String? get currentPlaylistId => _currentPlaylistId;
  List<Sound> get currentPlaylist => _currentPlaylist;
  int get currentIndex => _currentIndex;
  bool get hasNext => _currentIndex < _currentPlaylist.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
  Stream<bool> get playingStream => _audioService.playingStream;

  AudioProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _audioService.initialize();
  }

  // Play sound with playlist context
  Future<void> playSound(
      Sound sound, {
        String? playlistId,
        List<Sound>? playlist,
      }) async {
    _setLoading(true);
    _clearError();

    try {
      _currentSound = sound;
      _currentPlaylistId = playlistId;

      // Set playlist context
      if (playlist != null && playlist.isNotEmpty) {
        _currentPlaylist = playlist;
        _currentIndex = playlist.indexWhere((s) => s.id == sound.id);
        if (_currentIndex == -1) _currentIndex = 0;
      } else {
        // Create single-sound playlist
        _currentPlaylist = [sound];
        _currentIndex = 0;
      }

      debugPrint('Playing: ${sound.title} (${_currentIndex + 1}/${_currentPlaylist.length})');
      debugPrint('Playlist ID: $_currentPlaylistId');

      await _audioService.playSound(sound);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to play sound: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Play next sound in playlist
  Future<void> playNext() async {
    if (!hasNext) {
      debugPrint('No next track available');
      return;
    }

    _currentIndex++;
    if (_currentIndex < _currentPlaylist.length) {
      await playSound(
        _currentPlaylist[_currentIndex],
        playlistId: _currentPlaylistId,
        playlist: _currentPlaylist,
      );
    }
  }

  // Play previous sound in playlist
  Future<void> playPrevious() async {
    if (!hasPrevious) {
      debugPrint('No previous track available');
      return;
    }

    _currentIndex--;
    if (_currentIndex >= 0 && _currentIndex < _currentPlaylist.length) {
      await playSound(
        _currentPlaylist[_currentIndex],
        playlistId: _currentPlaylistId,
        playlist: _currentPlaylist,
      );
    }
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    try {
      await _audioService.togglePlayPause();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Pause
  Future<void> pause() async {
    await _audioService.pause();
    notifyListeners();
  }

  // Resume
  Future<void> resume() async {
    await _audioService.resume();
    notifyListeners();
  }

  // Stop
  Future<void> stop() async {
    await _audioService.stop();
    _currentSound = null;
    notifyListeners();
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  // Set volume
  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _audioService.setVolume(volume);
    notifyListeners();
  }

  // Toggle loop
  Future<void> toggleLoop() async {
    _isLooping = !_isLooping;
    await _audioService.setLoopMode(
      _isLooping ? LoopMode.one : LoopMode.off,
    );
    notifyListeners();
  }

  // Skip forward 10 seconds
  Future<void> skipForward() async {
    await _audioService.skipForward(const Duration(seconds: 10));
  }

  // Skip backward 10 seconds
  Future<void> skipBackward() async {
    await _audioService.skipBackward(const Duration(seconds: 10));
  }

  // Get progress percentage (0.0 to 1.0)
  double get progress {
    if (duration == null || duration!.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration!.inMilliseconds;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}