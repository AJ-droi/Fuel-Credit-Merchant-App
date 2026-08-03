class SupportTopicModel {
  const SupportTopicModel({required this.value, required this.label});

  final String value;
  final String label;

  factory SupportTopicModel.fromJson(Map<String, dynamic> json) {
    return SupportTopicModel(
      value: json['value'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

class SupportContactInfoModel {
  const SupportContactInfoModel({
    required this.email,
    required this.phone,
    required this.businessHours,
  });

  final String email;
  final String phone;
  final String businessHours;

  factory SupportContactInfoModel.fromJson(Map<String, dynamic> json) {
    return SupportContactInfoModel(
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      businessHours: json['businessHours'] as String? ?? '',
    );
  }
}

class SupportMessageModel {
  const SupportMessageModel({
    required this.id,
    required this.senderRole,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String senderRole;
  final String message;
  final DateTime createdAt;

  bool get isFromAdmin => senderRole == 'admin';

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      id: json['id'] as String? ?? '',
      senderRole: json['senderRole'] as String? ?? 'customer',
      message: json['message'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class SupportTicketModel {
  const SupportTicketModel({
    required this.id,
    required this.topic,
    required this.topicLabel,
    required this.subject,
    required this.status,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
    required this.hasAdminReply,
    this.messages = const [],
  });

  final String id;
  final String topic;
  final String topicLabel;
  final String subject;
  final String status;
  final String lastMessage;
  final DateTime lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
  final bool hasAdminReply;
  final List<SupportMessageModel> messages;

  bool get isOpen => status == 'open' || status == 'in_progress';
  bool get isResolved => status == 'resolved' || status == 'closed';

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List? ?? [];
    return SupportTicketModel(
      id: json['id'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      topicLabel: json['topicLabel'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageAt: DateTime.tryParse(json['lastMessageAt'] as String? ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      messageCount: json['messageCount'] as int? ?? 0,
      hasAdminReply: json['hasAdminReply'] as bool? ?? false,
      messages: rawMessages
          .whereType<Map<String, dynamic>>()
          .map(SupportMessageModel.fromJson)
          .toList(),
    );
  }
}

class SupportTicketListResult {
  const SupportTicketListResult({required this.tickets, required this.total});

  final List<SupportTicketModel> tickets;
  final int total;

  factory SupportTicketListResult.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List? ?? [];
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    return SupportTicketListResult(
      tickets: items.whereType<Map<String, dynamic>>().map(SupportTicketModel.fromJson).toList(),
      total: pagination['total'] as int? ?? items.length,
    );
  }
}
