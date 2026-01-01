import 'package:flutter/foundation.dart';
import '../../../core/models/meditation_program.dart';
import '../../../core/services/meditation_service.dart';
import '../../../core/services/storage_service.dart';

class MeditationProvider extends ChangeNotifier {
  final MeditationService _meditationService = meditationService;
  final StorageService _storage = storageService;

  List<MeditationProgram> _programs = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Track user's progress for each program
  Map<String, int> _programProgress = {}; // programId -> completed day

  List<MeditationProgram> get programs => _programs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, int> get programProgress => _programProgress;

  MeditationProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadPrograms();
    await _loadProgress();
  }

  // Load meditation programs
  Future<void> loadPrograms() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _programs = await _meditationService.getPrograms();
    } catch (e) {
      _errorMessage = 'Failed to load meditation programs: ${e.toString()}';
      debugPrint(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load user's progress from storage
  Future<void> _loadProgress() async {
    try {
      _programProgress = await _storage.getMeditationProgress();
      debugPrint('Loaded progress for ${_programProgress.length} programs');
    } catch (e) {
      debugPrint('Error loading meditation progress: $e');
    }
  }

  // Get completed day for a program (0 if not started)
  int getCompletedDay(String programId) {
    return _programProgress[programId] ?? 0;
  }

  // Check if program is completed
  bool isProgramCompleted(String programId) {
    final program = _meditationService.getProgramById(programId);
    if (program == null) return false;

    final completedDay = getCompletedDay(programId);
    return completedDay >= program.totalDays;
  }

  // Get completion percentage
  double getCompletionPercentage(String programId) {
    final program = _meditationService.getProgramById(programId);
    if (program == null) return 0.0;

    final completedDay = getCompletedDay(programId);
    return (completedDay / program.totalDays).clamp(0.0, 1.0);
  }

  // Mark session as completed
  Future<void> completeSession(String programId, int day) async {
    try {
      final currentProgress = _programProgress[programId] ?? 0;

      // Only update if this is the next day in sequence
      if (day == currentProgress + 1) {
        _programProgress[programId] = day;
        await _storage.setMeditationProgress(_programProgress);
        notifyListeners();
        debugPrint('Completed day $day of program $programId');
      }
    } catch (e) {
      debugPrint('Error completing session: $e');
    }
  }

  // Reset program progress
  Future<void> resetProgram(String programId) async {
    try {
      _programProgress[programId] = 0;
      await _storage.setMeditationProgress(_programProgress);
      notifyListeners();
      debugPrint('Reset progress for program $programId');
    } catch (e) {
      debugPrint('Error resetting program: $e');
    }
  }

  // Get next session for a program
  MeditationSession? getNextSession(String programId) {
    final completedDay = getCompletedDay(programId);
    final nextDay = completedDay + 1;
    return _meditationService.getSession(programId, nextDay);
  }

  // Get current or next available session
  MeditationSession? getCurrentSession(String programId) {
    final completedDay = getCompletedDay(programId);

    if (completedDay == 0) {
      // Not started, return first session
      return _meditationService.getSession(programId, 1);
    } else {
      final program = _meditationService.getProgramById(programId);
      if (program != null && completedDay >= program.totalDays) {
        // Completed, return last session
        return _meditationService.getSession(programId, program.totalDays);
      } else {
        // In progress, return next session
        return _meditationService.getSession(programId, completedDay + 1);
      }
    }
  }
}