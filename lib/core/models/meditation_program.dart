class MeditationSession {
  final int day;
  final String title;
  final String instruction;
  final String? recommendedSoundId;
  final int durationSeconds;

  MeditationSession({
    required this.day,
    required this.title,
    required this.instruction,
    this.recommendedSoundId,
    required this.durationSeconds,
  });

  factory MeditationSession.fromJson(Map<String, dynamic> json) {
    return MeditationSession(
      day: json['day'] as int,
      title: json['title'] as String,
      instruction: json['instruction'] as String,
      recommendedSoundId: json['recommendedSoundId'] as String?,
      durationSeconds: json['durationSeconds'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'title': title,
      'instruction': instruction,
      'recommendedSoundId': recommendedSoundId,
      'durationSeconds': durationSeconds,
    };
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    return '$minutes min';
  }
}

class MeditationProgram {
  final String id;
  final String title;
  final String description;
  final String level; // beginner, intermediate, advanced
  final int totalDays;
  final List<MeditationSession> sessions;
  final String? imageUrl;

  MeditationProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.totalDays,
    required this.sessions,
    this.imageUrl,
  });

  factory MeditationProgram.fromJson(Map<String, dynamic> json) {
    return MeditationProgram(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      level: json['level'] as String,
      totalDays: json['totalDays'] as int,
      sessions: (json['sessions'] as List<dynamic>)
          .map((session) => MeditationSession.fromJson(session))
          .toList(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'totalDays': totalDays,
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'imageUrl': imageUrl,
    };
  }

  // Get level color
  String get levelColor {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 'green';
      case 'intermediate':
        return 'blue';
      case 'advanced':
        return 'purple';
      default:
        return 'gray';
    }
  }
}