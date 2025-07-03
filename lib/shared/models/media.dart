enum MediaType { image, video, audio, document, youtube }

class MediaItem {
  final String id;
  final MediaType type;
  final String url;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final int sizeBytes;
  final int order;
  final DateTime createdAt;

  MediaItem({
    required this.id,
    required this.type,
    required this.url,
    this.title,
    this.description,
    this.thumbnailUrl,
    required this.sizeBytes,
    required this.order,
    required this.createdAt,
  });

  MediaItem copyWith({
    String? id,
    MediaType? type,
    String? url,
    String? title,
    String? description,
    String? thumbnailUrl,
    int? sizeBytes,
    int? order,
    DateTime? createdAt,
  }) {
    return MediaItem(
      id: id ?? this.id,
      type: type ?? this.type,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 