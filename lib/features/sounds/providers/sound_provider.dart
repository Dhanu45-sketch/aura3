import 'package:flutter/foundation.dart';
import '../../../core/models/sound.dart';
import '../../../core/services/sound_service.dart';

class SoundProvider extends ChangeNotifier {
  final SoundService _soundService = SoundService();

  List<Sound> _sounds = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Sound> get sounds => _sounds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SoundProvider() {
    fetchSounds();
  }

  Future<void> fetchSounds() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sounds = await _soundService.getSounds();
    } catch (e) {
      _errorMessage = 'Failed to load sounds: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Helper to get sounds by element
  List<Sound> getSoundsByElement(String element) {
    return _sounds.where((sound) => sound.element == element).toList();
  }

  // Helper to get a single sound by ID
  Sound? getSoundById(String id) {
    try {
      return _sounds.firstWhere((sound) => sound.id == id);
    } catch (e) {
      return null; // Not found
    }
  }
}
