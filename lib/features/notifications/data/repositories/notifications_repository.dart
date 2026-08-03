import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_result.dart';
import '../models/notification_models.dart';

class NotificationsRepository {
  NotificationsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<NotificationListResult>> fetchInbox({int page = 1, int limit = 30}) {
    return _apiClient.get<NotificationListResult>(
      ApiEndpoints.notifications,
      queryParameters: {'page': page, 'limit': limit},
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final data = map['data'];
        return NotificationListResult.fromJson(
          data is Map<String, dynamic> ? data : map,
        );
      },
    );
  }

  Future<ApiResult<int>> fetchUnreadCount() {
    return _apiClient.get<int>(
      ApiEndpoints.notificationsUnreadCount,
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return (data['unreadCount'] as num?)?.toInt() ?? 0;
        }
        return 0;
      },
    );
  }

  Future<ApiResult<AppNotificationModel>> markRead(String id) {
    return _apiClient.post<AppNotificationModel>(
      ApiEndpoints.notificationRead(id),
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final data = map['data'];
        return AppNotificationModel.fromJson(
          data is Map<String, dynamic> ? data : map,
        );
      },
    );
  }

  Future<ApiResult<void>> markAllRead() {
    return _apiClient.post<void>(
      ApiEndpoints.notificationsReadAll,
      parser: (_) {},
    );
  }
}
