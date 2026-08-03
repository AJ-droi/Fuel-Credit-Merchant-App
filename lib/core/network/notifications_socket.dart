import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'api_config.dart';
import '../storage/token_storage.dart';

typedef NotificationEventHandler = void Function(Map<String, dynamic> payload);

class NotificationsSocket {
  NotificationsSocket({
    TokenStorage? tokenStorage,
    this.onNotification,
    this.onConnectionChanged,
  }) : _tokenStorage = tokenStorage ?? TokenStorage.instance;

  final TokenStorage _tokenStorage;
  final NotificationEventHandler? onNotification;
  final ValueChanged<bool>? onConnectionChanged;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  bool _disposed = false;
  bool _connecting = false;
  int _attempt = 0;

  static String wsUrlForToken(String token) {
    final httpBase = AppConfig.apiBaseUrl;
    final uri = Uri.parse(httpBase);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return Uri(
      scheme: scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: '/api/v1/ws/notifications',
      queryParameters: {'token': token},
    ).toString();
  }

  Future<void> connect() async {
    if (_connecting) return;
    _disposed = false;
    _connecting = true;
    _reconnectTimer?.cancel();

    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        _connecting = false;
        return;
      }

      await disconnect(reconnect: false);

      final channel = WebSocketChannel.connect(Uri.parse(wsUrlForToken(token)));
      _channel = channel;
      _attempt = 0;
      onConnectionChanged?.call(true);

      _subscription = channel.stream.listen(
        _onMessage,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );

      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
        _send({'action': 'ping'});
      });
    } catch (_) {
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  Future<void> disconnect({bool reconnect = false}) async {
    _pingTimer?.cancel();
    _pingTimer = null;
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    onConnectionChanged?.call(false);
    if (reconnect && !_disposed) {
      _scheduleReconnect();
    }
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    unawaited(disconnect(reconnect: false));
  }

  void _send(Map<String, dynamic> payload) {
    final channel = _channel;
    if (channel == null) return;
    try {
      channel.sink.add(jsonEncode(payload));
    } catch (_) {}
  }

  void _onMessage(dynamic raw) {
    try {
      final decoded = raw is String ? jsonDecode(raw) : raw;
      if (decoded is! Map) return;
      final map = Map<String, dynamic>.from(decoded);
      if (map['type']?.toString() == 'notification:new') {
        final data = map['data'];
        if (data is Map) {
          onNotification?.call(Map<String, dynamic>.from(data));
        }
      }
    } catch (_) {}
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    onConnectionChanged?.call(false);
    _channel = null;
    _reconnectTimer?.cancel();
    final delay = Duration(seconds: (2 + _attempt).clamp(2, 30));
    _attempt += 1;
    _reconnectTimer = Timer(delay, () {
      if (!_disposed) unawaited(connect());
    });
  }
}
