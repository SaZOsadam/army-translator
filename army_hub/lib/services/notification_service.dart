import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String _topicsKey = 'subscribed_topics';

  final Set<String> _subscribedTopics = {};

  Future<void> initialize() async {
    // Load previously subscribed topics
    final prefs = await SharedPreferences.getInstance();
    final topics = prefs.getStringList(_topicsKey) ?? [];
    _subscribedTopics.addAll(topics);

    debugPrint('Notification service initialized');
    debugPrint('Subscribed topics: $_subscribedTopics');
  }

  void handleNotification(Map<String, dynamic> data) {
    final type = data['type'];
    final id = data['id'];

    switch (type) {
      case 'theory':
        debugPrint('Navigate to theory: $id');
        break;
      case 'poll':
        debugPrint('Navigate to poll: $id');
        break;
      case 'countdown':
        debugPrint('Navigate to countdown');
        break;
      default:
        debugPrint('Navigate to home');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    _subscribedTopics.add(topic);
    await _saveTopics();
    debugPrint('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    _subscribedTopics.remove(topic);
    await _saveTopics();
    debugPrint('Unsubscribed from topic: $topic');
  }

  Future<void> _saveTopics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_topicsKey, _subscribedTopics.toList());
  }

  Future<String?> getToken() async {
    // In production, integrate with a push notification service
    return null;
  }

  Future<void> subscribeToDefaultTopics() async {
    await subscribeToTopic('arirang_updates');
    await subscribeToTopic('daily_messages');
    await subscribeToTopic('new_teasers');
    await subscribeToTopic('poll_results');
  }

  Future<void> subscribeToBiasTopic(String bias) async {
    final allBiases = [
      'rm',
      'jin',
      'suga',
      'jhope',
      'jimin',
      'v',
      'jungkook',
      'ot7'
    ];
    for (final b in allBiases) {
      await unsubscribeFromTopic('bias_$b');
    }

    final topic = 'bias_${bias.toLowerCase().replaceAll('-', '')}';
    await subscribeToTopic(topic);
  }

  bool isSubscribedTo(String topic) {
    return _subscribedTopics.contains(topic);
  }
}
