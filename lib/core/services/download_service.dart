import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/sound.dart';

class DownloadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get the app's documents directory for storing downloaded files
  Future<String> _getDownloadPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${directory.path}/sounds');

    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    return downloadDir.path;
  }

  // Check if sound is already downloaded
  Future<bool> isDownloaded(Sound sound) async {
    try {
      final downloadPath = await _getDownloadPath();
      final fileName = _getFileName(sound);
      final file = File('$downloadPath/$fileName');
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking if downloaded: $e');
      return false;
    }
  }

  // Get local file path if downloaded
  Future<String?> getLocalFilePath(Sound sound) async {
    try {
      final downloadPath = await _getDownloadPath();
      final fileName = _getFileName(sound);
      final file = File('$downloadPath/$fileName');

      if (await file.exists()) {
        return file.path;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting local file path: $e');
      return null;
    }
  }

  // Download sound file from Firebase Storage
  Future<String> downloadSound(
      Sound sound, {
        Function(double)? onProgress,
      }) async {
    try {
      final downloadPath = await _getDownloadPath();
      final fileName = _getFileName(sound);
      final filePath = '$downloadPath/$fileName';
      final file = File(filePath);

      // Check if already exists
      if (await file.exists()) {
        debugPrint('File already downloaded: $fileName');
        return filePath;
      }

      // Get download URL from Firebase Storage
      final ref = _storage.ref(sound.firebaseStoragePath);
      final downloadUrl = await ref.getDownloadURL();

      debugPrint('Downloading: $fileName from $downloadUrl');

      // Download file with progress tracking
      final request = await http.Client().send(http.Request('GET', Uri.parse(downloadUrl)));
      final contentLength = request.contentLength ?? 0;
      var downloadedBytes = 0;

      final bytes = <int>[];

      await for (final chunk in request.stream) {
        bytes.addAll(chunk);
        downloadedBytes += chunk.length;

        if (contentLength > 0 && onProgress != null) {
          final progress = downloadedBytes / contentLength;
          onProgress(progress);
        }
      }

      // Write to file
      await file.writeAsBytes(bytes);
      debugPrint('Download complete: $fileName (${bytes.length} bytes)');

      return filePath;
    } catch (e) {
      debugPrint('Error downloading sound: $e');
      throw Exception('Failed to download sound: ${e.toString()}');
    }
  }

  // Delete downloaded sound
  Future<bool> deleteDownload(Sound sound) async {
    try {
      final downloadPath = await _getDownloadPath();
      final fileName = _getFileName(sound);
      final file = File('$downloadPath/$fileName');

      if (await file.exists()) {
        await file.delete();
        debugPrint('Deleted: $fileName');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting download: $e');
      return false;
    }
  }

  // Get all downloaded sound IDs
  Future<List<String>> getDownloadedSoundIds() async {
    try {
      final downloadPath = await _getDownloadPath();
      final directory = Directory(downloadPath);

      if (!await directory.exists()) {
        return [];
      }

      final files = await directory.list().toList();
      return files
          .whereType<File>()
          .map((file) => _extractSoundIdFromFileName(file.path))
          .where((id) => id != null)
          .cast<String>()
          .toList();
    } catch (e) {
      debugPrint('Error getting downloaded sound IDs: $e');
      return [];
    }
  }

  // Get total size of downloaded files
  Future<int> getTotalDownloadSize() async {
    try {
      final downloadPath = await _getDownloadPath();
      final directory = Directory(downloadPath);

      if (!await directory.exists()) {
        return 0;
      }

      var totalSize = 0;
      final files = await directory.list().toList();

      for (final file in files.whereType<File>()) {
        totalSize += await file.length();
      }

      return totalSize;
    } catch (e) {
      debugPrint('Error calculating download size: $e');
      return 0;
    }
  }

  // Clear all downloads
  Future<bool> clearAllDownloads() async {
    try {
      final downloadPath = await _getDownloadPath();
      final directory = Directory(downloadPath);

      if (await directory.exists()) {
        await directory.delete(recursive: true);
        debugPrint('Cleared all downloads');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error clearing downloads: $e');
      return false;
    }
  }

  // Helper: Generate filename from sound
  String _getFileName(Sound sound) {
    final extension = sound.firebaseStoragePath?.split('.').last ?? 'mp3';
    return '${sound.id}.$extension';
  }

  // Helper: Extract sound ID from filename
  String? _extractSoundIdFromFileName(String path) {
    try {
      final fileName = path.split('/').last;
      return fileName.split('.').first;
    } catch (e) {
      return null;
    }
  }

  // Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// Global singleton
final downloadService = DownloadService();