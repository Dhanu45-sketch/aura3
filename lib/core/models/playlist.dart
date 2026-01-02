enum PlaylistType {
  custom,
  element,
  favorites,
  downloads,
  recentlyPlayed,
}

class Playlist {
  final String id;
  final String name;
  final String description;
  final PlaylistType type;
  final List<String> soundIds; // List of sound IDs
  final String? element; // For element playlists
  final DateTime createdAt;
  final DateTime updatedAt;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.soundIds,
    this.element,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: PlaylistType.values.firstWhere(
            (e) => e.toString() == 'PlaylistType.${json['type']}',
        orElse: () => PlaylistType.custom,
      ),
      soundIds: List<String>.from(json['soundIds'] as List),
      element: json['element'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'soundIds': soundIds,
      'element': element,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    PlaylistType? type,
    List<String>? soundIds,
    String? element,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      soundIds: soundIds ?? this.soundIds,
      element: element ?? this.element,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if playlist contains a sound
  bool contains(String soundId) {
    return soundIds.contains(soundId);
  }

  // Get playlist icon based on type
  String get icon {
    switch (type) {
      case PlaylistType.element:
        return _getElementIcon(element ?? '');
      case PlaylistType.favorites:
        return '❤️';
      case PlaylistType.downloads:
        return '📥';
      case PlaylistType.recentlyPlayed:
        return '🕐';
      case PlaylistType.custom:
      default:
        return '🎵';
    }
  }

  String _getElementIcon(String element) {
    switch (element.toLowerCase()) {
      case 'earth':
        return '🌍';
      case 'fire':
        return '🔥';
      case 'water':
        return '💧';
      case 'wind':
        return '💨';
      default:
        return '🎵';
    }
  }
}