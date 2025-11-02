class Activity {
  final String id;
  final String title;
  final String description;
  final DateTimeRange dates;
  final String location;
  final String? groupe;
  final List<String> participants;
  final List<String> animatorIds;
  final ActivityStatus status;
  final String? imageUrl;
  final List<String> requiredMaterials;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.dates,
    required this.location,
    this.groupe,
    this.participants = const [],
    this.animatorIds = const [],
    this.status = ActivityStatus.planned,
    this.imageUrl,
    this.requiredMaterials = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    DateTimeRange dates;

    if (json['dates'] != null) {
      final datesMap = json['dates'] as Map<String, dynamic>;
      dates = DateTimeRange(
        start: DateTime.parse(datesMap['debut']),
        end: DateTime.parse(datesMap['fin']),
      );
    } else if (json['startTime'] != null && json['endTime'] != null) {
      // Format alternatif pour compatibilité
      dates = DateTimeRange(
        start: DateTime.parse(json['startTime']),
        end: DateTime.parse(json['endTime']),
      );
    } else {
      // Valeur par défaut
      final now = DateTime.now();
      dates = DateTimeRange(start: now, end: now.add(const Duration(hours: 2)));
    }

    return Activity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dates: dates,
      location: json['location'] ?? '',
      groupe: json['groupe'],
      participants: json['participants'] != null
          ? List<String>.from(json['participants'])
          : [],
      animatorIds: json['animatorIds'] != null
          ? List<String>.from(json['animatorIds'])
          : [],
      status: ActivityStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
        orElse: () => ActivityStatus.planned,
      ),
      imageUrl: json['imageUrl'],
      requiredMaterials: json['requiredMaterials'] != null
          ? List<String>.from(json['requiredMaterials'])
          : [],
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dates': {
        'debut': dates.start.toIso8601String(),
        'fin': dates.end.toIso8601String(),
      },
      'location': location,
      'groupe': groupe,
      'participants': participants,
      'animatorIds': animatorIds,
      'status': status.toString().split('.').last,
      'imageUrl': imageUrl,
      'requiredMaterials': requiredMaterials,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Activity copyWith({
    String? id,
    String? title,
    String? description,
    DateTimeRange? dates,
    String? location,
    String? groupe,
    List<String>? participants,
    List<String>? animatorIds,
    ActivityStatus? status,
    String? imageUrl,
    List<String>? requiredMaterials,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dates: dates ?? this.dates,
      location: location ?? this.location,
      groupe: groupe ?? this.groupe,
      participants: participants ?? this.participants,
      animatorIds: animatorIds ?? this.animatorIds,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      requiredMaterials: requiredMaterials ?? this.requiredMaterials,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getters pour faciliter l'accès
  DateTime get startTime => dates.start;
  DateTime get endTime => dates.end;
  Duration get duration => dates.duration;
  bool get isToday {
    final now = DateTime.now();
    return now.year == dates.start.year &&
           now.month == dates.start.month &&
           now.day == dates.start.day;
  }

  String get formattedDateRange {
    final startFormat = _formatDate(dates.start);
    final endFormat = _formatDate(dates.end);

    if (startFormat == endFormat) {
      return '$startFormat ${_formatTime(dates.start)} - ${_formatTime(dates.end)}';
    } else {
      return '$startFormat - $endFormat';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

enum ActivityStatus {
  planned,
  inProgress,
  completed,
  cancelled,
}

extension ActivityStatusExtension on ActivityStatus {
  String get displayName {
    switch (this) {
      case ActivityStatus.planned:
        return 'Planifié';
      case ActivityStatus.inProgress:
        return 'En cours';
      case ActivityStatus.completed:
        return 'Terminé';
      case ActivityStatus.cancelled:
        return 'Annulé';
    }
  }

  String get frenchName {
    switch (this) {
      case ActivityStatus.planned:
        return 'Planifié';
      case ActivityStatus.inProgress:
        return 'En cours';
      case ActivityStatus.completed:
        return 'Terminé';
      case ActivityStatus.cancelled:
        return 'Annulé';
    }
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({
    required this.start,
    required this.end,
  });

  Duration get duration => end.difference(start);

  bool contains(DateTime date) {
    return date.isAfter(start.subtract(const Duration(microseconds: 1))) &&
           date.isBefore(end.add(const Duration(microseconds: 1)));
  }
}