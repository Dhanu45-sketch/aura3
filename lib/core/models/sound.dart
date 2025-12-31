class Sound {
  final String id;
  final String title;
  final String element; // earth, fire, water, wind
  final String description;
  final int durationSeconds;
  final String? firebaseStoragePath; // Path in Firebase Storage
  final String? localAssetPath; // For bundled sounds
  final String thumbnailUrl;
  final bool isPremium;

  Sound({
    required this.id,
    required this.title,
    required this.element,
    required this.description,
    required this.durationSeconds,
    this.firebaseStoragePath,
    this.localAssetPath,
    required this.thumbnailUrl,
    this.isPremium = false,
  });

  factory Sound.fromJson(Map<String, dynamic> json) {
    return Sound(
      id: json['id'] as String,
      title: json['title'] as String,
      element: json['element'] as String,
      description: json['description'] as String,
      durationSeconds: json['durationSeconds'] as int,
      firebaseStoragePath: json['firebaseStoragePath'] as String?,
      localAssetPath: json['localAssetPath'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'element': element,
      'description': description,
      'durationSeconds': durationSeconds,
      'firebaseStoragePath': firebaseStoragePath,
      'localAssetPath': localAssetPath,
      'thumbnailUrl': thumbnailUrl,
      'isPremium': isPremium,
    };
  }

  // Check if sound is available locally
  bool get isLocal => localAssetPath != null;

  // Get formatted duration
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Copy with method
  Sound copyWith({
    String? id,
    String? title,
    String? element,
    String? description,
    int? durationSeconds,
    String? firebaseStoragePath,
    String? localAssetPath,
    String? thumbnailUrl,
    bool? isPremium,
  }) {
    return Sound(
      id: id ?? this.id,
      title: title ?? this.title,
      element: element ?? this.element,
      description: description ?? this.description,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      firebaseStoragePath: firebaseStoragePath ?? this.firebaseStoragePath,
      localAssetPath: localAssetPath ?? this.localAssetPath,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
