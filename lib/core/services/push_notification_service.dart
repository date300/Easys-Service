import 'dart:async';

class NotificationEvent {
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final bool isBackground;
  NotificationEvent({this.title, this.body, this.data = const {}, this.isBackground = false});
}

class PushNotificationService {
  static final PushNotificationService instance = PushNotificationService._internal();
  factory PushNotificationService() => instance;
  PushNotificationService._internal();

  final StreamController<<NotificationEvent> _onTapController = StreamController<<NotificationEvent>.broadcast();
  Stream<<NotificationEvent> get onTap => _onTapController.stream;

  Future<void> initialize() async {
    // TODO: Complete implementation
  }
}
