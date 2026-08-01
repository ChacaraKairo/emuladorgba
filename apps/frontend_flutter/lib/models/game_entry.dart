class GameEntry {
  const GameEntry({
    required this.id,
    required this.title,
    required this.romPath,
    required this.addedAt,
    this.lastPlayedAt,
  });

  final String id;
  final String title;
  final String romPath;
  final DateTime addedAt;
  final DateTime? lastPlayedAt;

  GameEntry copyWith({DateTime? lastPlayedAt}) {
    return GameEntry(
      id: id,
      title: title,
      romPath: romPath,
      addedAt: addedAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'title': title,
        'romPath': romPath,
        'addedAt': addedAt.toIso8601String(),
        'lastPlayedAt': lastPlayedAt?.toIso8601String(),
      };

  factory GameEntry.fromJson(Map<String, Object?> json) {
    final lastPlayedValue = json['lastPlayedAt'] as String?;
    return GameEntry(
      id: json['id']! as String,
      title: json['title']! as String,
      romPath: json['romPath']! as String,
      addedAt: DateTime.parse(json['addedAt']! as String),
      lastPlayedAt:
          lastPlayedValue == null ? null : DateTime.parse(lastPlayedValue),
    );
  }
}
