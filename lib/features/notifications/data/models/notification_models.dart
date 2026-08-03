class NotificationMediaModel {
  const NotificationMediaModel({
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.mimeType,
  });

  final String type;
  final String url;
  final String? thumbnailUrl;
  final String? mimeType;

  factory NotificationMediaModel.fromJson(Map<String, dynamic> json) {
    return NotificationMediaModel(
      type: json['type']?.toString() ?? 'image',
      url: json['url']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      mimeType: json['mimeType']?.toString(),
    );
  }
}

class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.category,
    required this.categoryLabel,
    required this.contentType,
    required this.title,
    required this.body,
    required this.media,
    required this.data,
    required this.publishedAt,
    required this.read,
    this.expiresAt,
  });

  final String id;
  final String category;
  final String categoryLabel;
  final String contentType;
  final String title;
  final String body;
  final List<NotificationMediaModel> media;
  final Map<String, dynamic> data;
  final DateTime publishedAt;
  final DateTime? expiresAt;
  final bool read;

  AppNotificationModel copyWith({bool? read}) {
    return AppNotificationModel(
      id: id,
      category: category,
      categoryLabel: categoryLabel,
      contentType: contentType,
      title: title,
      body: body,
      media: media,
      data: data,
      publishedAt: publishedAt,
      expiresAt: expiresAt,
      read: read ?? this.read,
    );
  }

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final mediaRaw = json['media'];
    final media = mediaRaw is List
        ? mediaRaw
            .whereType<Map>()
            .map((m) => NotificationMediaModel.fromJson(Map<String, dynamic>.from(m)))
            .toList()
        : <NotificationMediaModel>[];
    final dataRaw = json['data'];
    return AppNotificationModel(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? 'system',
      categoryLabel: json['categoryLabel']?.toString() ?? 'Notification',
      contentType: json['contentType']?.toString() ?? 'text',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      media: media,
      data: dataRaw is Map ? Map<String, dynamic>.from(dataRaw) : <String, dynamic>{},
      publishedAt: DateTime.tryParse(json['publishedAt']?.toString() ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
      read: json['read'] == true,
    );
  }
}

class NotificationListResult {
  const NotificationListResult({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  final List<AppNotificationModel> items;
  final int page;
  final int totalPages;
  final int total;

  factory NotificationListResult.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final pagination = json['pagination'];
    final pageMeta = pagination is Map ? Map<String, dynamic>.from(pagination) : <String, dynamic>{};
    return NotificationListResult(
      items: itemsRaw is List
          ? itemsRaw
              .whereType<Map>()
              .map((e) => AppNotificationModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      page: (pageMeta['page'] as num?)?.toInt() ?? 1,
      totalPages: (pageMeta['totalPages'] as num?)?.toInt() ?? 1,
      total: (pageMeta['total'] as num?)?.toInt() ?? 0,
    );
  }
}
