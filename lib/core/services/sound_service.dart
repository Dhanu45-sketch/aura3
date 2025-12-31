import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/sound.dart';

class SoundService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // CORRECTED: Fetches sounds by listing files directly from Firebase Storage.
  Future<List<Sound>> getSounds() async {
    try {
      final List<Sound> sounds = [];
      final List<String> elements = ['earth', 'fire', 'water', 'wind'];

      for (final element in elements) {
        final listResult = await _storage.ref('sounds/$element').listAll();

        for (final item in listResult.items) {
          sounds.add(Sound(
            id: item.fullPath, // Use the full path as a unique ID
            title: _formatTitle(item.name), // Generate a title from the filename
            element: element,
            description: 'Audio from Firebase Storage',
            durationSeconds: 0, // Duration is unknown from storage listing
            firebaseStoragePath: item.fullPath, // The full path to the file
            thumbnailUrl: '', // No thumbnail available
            isPremium: false,
          ));
        }
      }

      if (sounds.isEmpty) {
        debugPrint("No sounds found in Firebase Storage under the 'sounds/' directory.");
      }

      return sounds;
    } catch (e) {
      debugPrint('Error listing files from Firebase Storage: $e');
      throw Exception('Failed to load sounds from storage. Error: ${e.toString()}');
    }
  }

  // Helper to make filenames more readable.
  String _formatTitle(String fileName) {
    return fileName
        .replaceAll('.wav', '')
        .replaceAll('.mp3', '')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((s) => s.isNotEmpty && double.tryParse(s) == null)
        .join(' ');
  }
}
