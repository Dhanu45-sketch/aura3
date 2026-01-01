import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/meditation_program.dart';

class MeditationService {
  static const String localJsonPath = 'assets/data/meditation_programs.json';

  List<MeditationProgram> _cachedPrograms = [];
  bool _isLoaded = false;

  // Load meditation programs from local JSON
  Future<List<MeditationProgram>> getPrograms() async {
    if (_isLoaded && _cachedPrograms.isNotEmpty) {
      debugPrint('Using cached meditation programs');
      return _cachedPrograms;
    }

    try {
      debugPrint('Loading meditation programs from JSON...');
      final jsonString = await rootBundle.loadString(localJsonPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      final programsList = jsonData['programs'] as List<dynamic>;
      _cachedPrograms = programsList
          .map((programJson) => MeditationProgram.fromJson(programJson))
          .toList();

      _isLoaded = true;
      debugPrint('Loaded ${_cachedPrograms.length} meditation programs');
      return _cachedPrograms;
    } catch (e) {
      debugPrint('Error loading meditation programs: $e');
      throw Exception('Failed to load meditation programs: ${e.toString()}');
    }
  }

  // Get program by ID
  MeditationProgram? getProgramById(String id) {
    try {
      return _cachedPrograms.firstWhere((program) => program.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get programs by level
  List<MeditationProgram> getProgramsByLevel(String level) {
    return _cachedPrograms
        .where((program) => program.level.toLowerCase() == level.toLowerCase())
        .toList();
  }

  // Get session from a program
  MeditationSession? getSession(String programId, int day) {
    try {
      final program = getProgramById(programId);
      return program?.sessions.firstWhere((session) => session.day == day);
    } catch (e) {
      return null;
    }
  }
}

// Global singleton
final meditationService = MeditationService();