import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/support_models.dart';

class SupportRepository {
  SupportRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<List<SupportTopicModel>>> fetchTopics() {
    return _apiClient.get<List<SupportTopicModel>>(
      ApiEndpoints.supportTopics,
      parser: (json) {
        final data = _unwrap(json);
        final topics = data is Map<String, dynamic> ? data['topics'] as List? ?? [] : [];
        return topics
            .whereType<Map<String, dynamic>>()
            .map(SupportTopicModel.fromJson)
            .where((t) => t.value != 'loan_issue')
            .toList();
      },
    );
  }

  Future<ApiResult<SupportContactInfoModel>> fetchContactInfo() {
    return _apiClient.get<SupportContactInfoModel>(
      ApiEndpoints.supportContact,
      parser: (json) {
        final data = _unwrap(json);
        return SupportContactInfoModel.fromJson(
          data is Map<String, dynamic> ? data : <String, dynamic>{},
        );
      },
    );
  }

  Future<ApiResult<SupportTicketListResult>> fetchTickets({int page = 1, int limit = 20}) {
    return _apiClient.get<SupportTicketListResult>(
      ApiEndpoints.supportTickets,
      queryParameters: {'page': page, 'limit': limit},
      parser: (json) {
        final data = _unwrap(json);
        return SupportTicketListResult.fromJson(
          data is Map<String, dynamic> ? data : <String, dynamic>{},
        );
      },
    );
  }

  Future<ApiResult<SupportTicketModel>> fetchTicket(String ticketId) {
    return _apiClient.get<SupportTicketModel>(
      ApiEndpoints.supportTicket(ticketId),
      parser: (json) {
        final data = _unwrap(json);
        return SupportTicketModel.fromJson(
          data is Map<String, dynamic> ? data : <String, dynamic>{},
        );
      },
    );
  }

  Future<ApiResult<SupportTicketModel>> createTicket({
    required String topic,
    required String message,
  }) {
    return _apiClient.post<SupportTicketModel>(
      ApiEndpoints.supportTickets,
      data: {'topic': topic, 'message': message},
      parser: (json) {
        final data = _unwrap(json);
        return SupportTicketModel.fromJson(
          data is Map<String, dynamic> ? data : <String, dynamic>{},
        );
      },
    );
  }

  Future<ApiResult<SupportTicketModel>> sendMessage({
    required String ticketId,
    required String message,
  }) {
    return _apiClient.post<SupportTicketModel>(
      ApiEndpoints.supportTicketMessages(ticketId),
      data: {'message': message},
      parser: (json) {
        final data = _unwrap(json);
        return SupportTicketModel.fromJson(
          data is Map<String, dynamic> ? data : <String, dynamic>{},
        );
      },
    );
  }

  static dynamic _unwrap(dynamic body) {
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }
}
