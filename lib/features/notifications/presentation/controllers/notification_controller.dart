import 'package:flutter/foundation.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/network/notifications_socket.dart';
import '../../data/models/notification_models.dart';

class NotificationController extends ChangeNotifier {
  NotificationController() {
    _socket = NotificationsSocket(onNotification: _onRealtime);
  }

  late final NotificationsSocket _socket;

  List<AppNotificationModel> items = [];
  int unreadCount = 0;
  bool loading = false;
  bool loadingMore = false;
  String? error;
  int _page = 1;
  int _totalPages = 1;

  Future<void> bootstrap() async {
    await Future.wait([refreshUnreadCount(), ensureSocket()]);
  }

  Future<void> ensureSocket() => _socket.connect();

  Future<void> refreshUnreadCount() async {
    final result = await AppServices.instance.notificationsRepository.fetchUnreadCount();
    if (result is ApiSuccess<int>) {
      unreadCount = result.data;
      notifyListeners();
    }
  }

  Future<void> loadInbox({bool refresh = true}) async {
    if (refresh) {
      loading = true;
      error = null;
      _page = 1;
      notifyListeners();
    } else {
      if (loadingMore || _page >= _totalPages) return;
      loadingMore = true;
      notifyListeners();
    }

    final result = await AppServices.instance.notificationsRepository.fetchInbox(
      page: refresh ? 1 : _page + 1,
    );

    if (result is ApiSuccess<NotificationListResult>) {
      final data = result.data;
      items = refresh ? data.items : [...items, ...data.items];
      _page = data.page;
      _totalPages = data.totalPages;
      error = null;
      await refreshUnreadCount();
    } else if (result is ApiFailure<NotificationListResult>) {
      error = result.error.message;
    }

    loading = false;
    loadingMore = false;
    notifyListeners();
  }

  Future<void> openNotification(AppNotificationModel item) async {
    if (item.read) return;
    final result = await AppServices.instance.notificationsRepository.markRead(item.id);
    if (result is ApiSuccess<AppNotificationModel>) {
      final idx = items.indexWhere((n) => n.id == item.id);
      if (idx >= 0) items[idx] = result.data;
      if (unreadCount > 0) unreadCount -= 1;
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    final result = await AppServices.instance.notificationsRepository.markAllRead();
    if (result is ApiSuccess<void>) {
      items = items.map((n) => n.copyWith(read: true)).toList();
      unreadCount = 0;
      notifyListeners();
    }
  }

  void _onRealtime(Map<String, dynamic> payload) {
    final incoming = AppNotificationModel.fromJson({...payload, 'read': false});
    final existed = items.any((n) => n.id == incoming.id);
    items = [incoming, ...items.where((n) => n.id != incoming.id)];
    if (!existed) unreadCount += 1;
    notifyListeners();
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }
}
