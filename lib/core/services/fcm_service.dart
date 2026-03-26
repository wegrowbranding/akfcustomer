// Dart imports:
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Project imports:
import '/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
}

Future<String> getToken() async => Platform.isAndroid
    ? await FirebaseMessaging.instance.getToken() ?? ''
    : await FirebaseMessaging.instance.getAPNSToken() ?? '';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

  Future<void> initalize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _requestPermission();
    await setupFlutterNotifications();
    await _setupMessageHandlers();
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission();
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }

    // android setup
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // ios setup
    const initializationSettingsDarwin = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        if (details.actionId == 'REPLY_ACTION_KEY') {
        } else {
          _handleBackgroundMessage(convertPayload(details.payload!));
        }
      },
    );

    _isFlutterLocalNotificationsInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final AndroidNotification? android = message.notification?.android;

    // if (message.data["isLocationRequest"] != null &&
    //     message.data["isLocationRequest"] == "true") {
    //   groupViewRequest(id: message.data["locationRequestId"]);
    // }

    if (notification != null && android != null) {
      await _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            // actions: message.data['isChat'] == 'true'
            //     ? <AndroidNotificationAction>[
            //         const AndroidNotificationAction(
            //           'REPLY_ACTION_KEY',
            //           'Reply',
            //           showsUserInterface: true,
            //           inputs: [
            //             AndroidNotificationActionInput(
            //               label: 'Type your reply here...',
            //             ),
            //           ],
            //         ),
            //       ]
            //     : [],
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _setupMessageHandlers() async {
    // foreground
    FirebaseMessaging.onMessage.listen(showNotification);

    // background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleBackgroundMessage(message.data);
    });

    // opened app
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage.data);
    }
  }

  void _handleBackgroundMessage(Map<String, dynamic> message) {}

  Map<String, dynamic> convertPayload(String payload) {
    final String validJson = payload.replaceAllMapped(
      RegExp(r'(\w+):\s*([a-zA-Z0-9_-]+|\[.*\])'),
      (match) {
        final key = match.group(1);
        var value = match.group(2);

        if (value!.startsWith('[')) {
          value = value.replaceAllMapped(
            RegExp(r'(\w+)'),
            (listMatch) => '"${listMatch.group(1)}"',
          );
          return '"$key": $value';
        } else {
          return '"$key": "$value"';
        }
      },
    );

    final Map<String, dynamic> map = jsonDecode(validJson);
    return map;
  }
}
