import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class NotificationService
    extends
        GetxService {
  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  final AuthService _authService =
      Get.find<
        AuthService
      >();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final RxBool isInitialized =
      false.obs;

  static const String _fcmApiUrl =
      "https://fcm.googleapis.com/v1/projects/learning-app-rafi/messages:send";
  static const String _androidChannelId =
      'language_learning_channel';
  static const String _androidChannelName =
      'Language Learning Notifications';
  static const String _androidDirectChannelId =
      'language_learning_direct_channel';
  static const String _androidDirectChannelName =
      'Direct Notifications';

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
  }

  Future<
    void
  >
  _initNotifications() async {
    print(
      'Initializing notifications service...',
    );

    try {
      await _initLocalNotifications();

      NotificationSettings settings = await _messaging.requestPermission(
        alert:
            true,
        badge:
            true,
        sound:
            true,
        provisional:
            false,
      );

      print(
        'User granted permission: ${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          settings.authorizationStatus ==
              AuthorizationStatus.provisional) {
        String? token =
            await _messaging.getToken();
        if (token !=
            null) {
          await _saveTokenToDatabase(
            token,
          );
        }

        _messaging.onTokenRefresh.listen(
          _saveTokenToDatabase,
        );

        FirebaseMessaging.onMessage.listen(
          _handleForegroundMessage,
        );
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );

        if (Platform.isIOS) {
          await _messaging.setForegroundNotificationPresentationOptions(
            alert:
                true,
            badge:
                true,
            sound:
                true,
          );
        }

        isInitialized.value = true;
        print(
          'Notification service initialized successfully',
        );
      } else {
        print(
          'User declined or has not accepted permission',
        );
      }
    } catch (
      e
    ) {
      print(
        'Error initializing notification service: $e',
      );
    }
  }

  Future<
    void
  >
  _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission:
          true,
      requestBadgePermission:
          true,
      requestSoundPermission:
          true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android:
          initializationSettingsAndroid,
      iOS:
          initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          _onDidReceiveNotificationResponse,
    );
  }

  static Future<
    void
  >
  _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    print(
      'Handling a background message: ${message.messageId}',
    );
  }

  Future<
    void
  >
  _saveTokenToDatabase(
    String token,
  ) async {
    try {
      String? userId =
          _authService.firebaseUser.value?.uid;

      if (userId !=
          null) {
        print(
          'Saving FCM token to database for user: $userId',
        );

        await _firestore
            .collection(
              'users',
            )
            .doc(
              userId,
            )
            .update(
              {
                'fcmTokens': FieldValue.arrayUnion(
                  [
                    token,
                  ],
                ),
                'updatedAt':
                    FieldValue.serverTimestamp(),
              },
            );

        print(
          'FCM token saved successfully',
        );
      } else {
        print(
          'Cannot save FCM token: User ID is null',
        );
      }
    } catch (
      e
    ) {
      print(
        'Error saving FCM token to database: $e',
      );
    }
  }

  void _handleForegroundMessage(
    RemoteMessage message,
  ) {
    print(
      'Got a message whilst in the foreground!',
    );
    print(
      'Message data: ${message.data}',
    );

    if (message.notification !=
        null) {
      print(
        'Message also contained a notification: ${message.notification}',
      );
      _showLocalNotification(
        message,
      );
    }
  }

  Future<
    void
  >
  _showLocalNotification(
    RemoteMessage message,
  ) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription:
          'Notifications for the Language Learning App',
      importance:
          Importance.max,
      priority:
          Priority.high,
      showWhen:
          true,
    );

    const iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const platformChannelSpecifics = NotificationDetails(
      android:
          androidPlatformChannelSpecifics,
      iOS:
          iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload:
          message.data.toString(),
    );
  }

  void _onDidReceiveNotificationResponse(
    NotificationResponse response,
  ) {
    print(
      'Local notification tapped: ${response.payload}',
    );
  }

  static Future<
    String
  >
  getAccessToken() async {
    final serviceAccountJson = {
      "type":
          "service_account",
      "project_id":
          "learning-app-rafi",
      "private_key_id":
          "7b9c9b7a934dd9a6455ab50a45a72bc0cbbb3526",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDjXOQlWRBBgZgs\nUTcOEhY5a7YFSvLQWOygQLAGgycEjUS+zZA+HaNbwASPC9MDQKLBMWgnJj5Okc57\nGeh1k0e0p0VKMfY8FD7wYmp/l/peo7z6jFmAd53KL+q8OF7A9zaKtT1zusoLK/bX\niChFa33UY84TkZXbDKi6SQ0Gs2LLbOdhKJpYJJUM5uEgBNJG7v0LwykmQPCbkXRz\nnDW58pX7usnbDUCIiFOASYVu2YRKbJcOzLb1JlMG4IQupMKzHCBb7F6F7iMdS59U\n1jzqU48AydS5rSk8Edy1UzbcAaglqTBUQAi75QSCS5C4Ltw+8WnNTklsL5XS4Zl4\n9ZyLiOEVAgMBAAECggEAGiccvSkOBCL2kJ508ULmWIuJv/kbjhi0e0iFlvIuIkln\nr3Tw0xxQpqSjQZsQFi8wqX1X6CzvfNUrxaA4y5F57Y9SGpM9qjJ//OGtM2kVbR5z\nhfRv9SWNOm0hmK35REQLe5AWdgH17KwNdEResYGIU055rWmRLcW6gNcXTv6Cbjis\nnd3s/UnBkbsWfvJtE6wtK5pZ1PG3//WUK/PZcbPBLR/rTt9A93IMklGhRgyNCU7j\nEHm6Ad1/5IbQXsCl8CNovWV2boZOJ2q70YmN0a4PvEJr+yXTDZY5CP/rUYWF3BeF\nRhLiSAhUpBSGVc+rLxmWwslQUFmBv0Hbgg8VAqMAgQKBgQD+e5gy0259W41dBVEw\nBSDKpjiR3es16m4TGE3FZyCpgwTJWPUzE6V28Se0KAxXl1DOiQ1KiOrGRar7f4eI\nss+9yhVaFBTHzOaxwntPN/8iyvajah4p9hQ2oYcnan1bArz4qkVHwTYiEFw6W1sn\nn2gfqPi0eHMdcrt71ykD00lN1QKBgQDkt+edsVeSjpH/yCZlwXc7sSIm+Fe8GF70\n+bUeCgFRUSDj56EZgVk9+ZqOPENdtRBTkoGnFXeUod/6SqmssCBYJp/bVnhUaa44\ndYc/+Km2sD3q6VCKKzRrpK9Nn9efr9b2snsbWNSodow2wJkxwMXcOImR1twzndlO\n9dg9/aSmQQKBgFdfTekdaJEHruhiG/bVu+V33nJOdCRFwdcyf/knqDIq9qi+rykD\nNMs6jvwux9YG8MqIiZSun5TFdKf2qC0J34N075HG1T+oHQipEjcnraRfdQC0PXkA\nsP30xXeF+1YVAZaKt1CkiJZ3cYLjvM9EzrYYCJPFyxgwPSiOvdk/YKqlAoGBAIdR\nXxFnOP6Wpz6DtmQBoH+Kf0A7Mf0xFg0uJ8AL/1eS/jiYdDHY22nVYWHBucGZPH2V\ncmveQY+IbjFxNw3abmh5AZ8Ne8fFdrQkpM5uWkqh3yA6xdHZWfxNxQHSDgqGSFJQ\nqpE1byv0Z2SFcp2DBg0SziGg00semtEilrumc2GBAoGAKt9xoJh4+RjZzx2e+72S\nx2najpAfGyt+O35oNb6KuZO1j0+Ap+je0OkP5p28c05/9BxuigwOgZt0W4fi1jYx\nYFyHHV+kU+RYAzypKG4a1RlHVAqJIFuKPZ4dbnvLEBz4bjoQ7GVOvE8jpiRDyPWM\n22B1xzLHew6f4mrMIo3iR2E=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-fbsvc@learning-app-rafi.iam.gserviceaccount.com",
      "client_id":
          "109424720921758434662",
      "auth_uri":
          "https://accounts.google.com/o/oauth2/auth",
      "token_uri":
          "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40learning-app-rafi.iam.gserviceaccount.com",
      "universe_domain":
          "googleapis.com",
    };

    List<
      String
    >
    scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    final auth.ServiceAccountCredentials credentials = auth.ServiceAccountCredentials.fromJson(
      serviceAccountJson,
    );
    final auth.AccessCredentials accessCredentials = await auth.obtainAccessCredentialsViaServiceAccount(
      credentials,
      scopes,
      http.Client(),
    );

    return accessCredentials.accessToken.data;
  }

  Future<
    void
  >
  sendNotificationToUser(
   {
    required String userId,
    required String title,
    required String body,
    String? studentId,
    Map<
      String,
      dynamic
    >
    data = const {},
   }
  ) async {
    try {
      if (!isInitialized.value) {
        await _initNotifications();
      }

      List<
        String
      >
      tokens = await _getUserTokens(
        userId,
      );

      await _firestore
          .collection(
            'notifications',
          )
          .add(
            {
              'userId':
                  userId,
              'title':
                  title,
              'body':
                  body,
              'data':
                  data ??
                  {},
              'tokens':
                  tokens,
              'read':
                  false,
              'sent':
                  true,
              'createdAt':
                  FieldValue.serverTimestamp(),
            },
          );

      await _sendFcmNotifications(
        tokens,
        title,
        body,
        userId,
      );

      if (_authService.firebaseUser.value?.uid ==
          studentId) {
        await _showDirectLocalNotification(
          "New Booking",
          "Your lesson has been booked waiting for teacher to accept",
        );
      }

      print(
        'Notification processed for user: $userId',
      );
    } catch (
      e
    ) {
      print(
        'Error sending notification: $e',
      );
    }
  }

  Future<
    List<
      String
    >
  >
  _getUserTokens(
    String userId,
  ) async {
    DocumentSnapshot
    userDoc =
        await _firestore
            .collection(
              'users',
            )
            .doc(
              userId,
            )
            .get();

    if (userDoc.exists) {
      Map<
        String,
        dynamic
      >
      userData =
          userDoc.data()
              as Map<
                String,
                dynamic
              >;
      if (userData.containsKey(
            'fcmTokens',
          ) &&
          userData['fcmTokens']
              is List) {
        return List<
          String
        >.from(
          userData['fcmTokens'],
        );
      }
    }

    return [];
  }

  Future<
    void
  >
  _sendFcmNotifications(
    List<
      String
    >
    tokens,
    String title,
    String body,
    String userId,
  ) async {
    if (tokens.isEmpty) return;

    final String serverAccessToken =
        await getAccessToken();

    for (String token in tokens) {
      final Map<
        String,
        dynamic
      >
      message = {
        'message': {
          'token':
              token,
          'notification': {
            'title':
                title,
            'body':
                body,
          },
          'data': {
            'id':
                userId.toString(),
          },
        },
      };

      final http.Response response = await http.post(
        Uri.parse(
          _fcmApiUrl,
        ),
        headers: <
          String,
          String
        >{
          'Content-Type':
              'application/json',
          'Authorization':
              'Bearer $serverAccessToken',
        },
        body: jsonEncode(
          message,
        ),
      );

      if (response.statusCode ==
          200) {
        print(
          "Notification sent successfully to token: $token",
        );
      } else {
        print(
          "Failed to send FCM message to token $token: ${response.statusCode} ${response.body}",
        );
      }
    }
  }

  Future<
    void
  >
  _showDirectLocalNotification(
    String title,
    String body,
  ) async {
    try {
      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        _androidDirectChannelId,
        _androidDirectChannelName,
        channelDescription:
            'Direct notifications for testing',
        importance:
            Importance.max,
        priority:
            Priority.high,
        showWhen:
            true,
      );

      const iOSPlatformChannelSpecifics =
          DarwinNotificationDetails();

      const platformChannelSpecifics = NotificationDetails(
        android:
            androidPlatformChannelSpecifics,
        iOS:
            iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(
          100000,
        ),
        title,
        body,
        platformChannelSpecifics,
      );

      print(
        'Local notification shown successfully',
      );
    } catch (
      e
    ) {
      print(
        'Error showing local notification: $e',
      );
    }
  }

  Future<
    void
  >
  testNotification() async {
    try {
      if (!isInitialized.value) {
        await _initNotifications();
      }

      String? userId =
          _authService.firebaseUser.value?.uid;
      if (userId ==
          null) {
        print(
          'Cannot test notification: User is not logged in',
        );
        return;
      }

      await _showDirectLocalNotification(
        'Test Notification',
        'This is a test notification to verify the system is working.',
      );

      print(
        'Test notification sent successfully',
      );
    } catch (
      e
    ) {
      print(
        'Error testing notification: $e',
      );
    }
  }

  Future<
    void
  >
  verifyFcmTokens() async {
    try {
      String? userId =
          _authService.firebaseUser.value?.uid;
      if (userId ==
          null) {
        ('No logged in user to verify tokens');
        return;
      }

      List<
        String
      >
      tokens = await _getUserTokens(
        userId,
      );
      print(
        'User $userId has ${tokens.length} FCM tokens registered',
      );

      if (tokens.isEmpty) {
        String? newToken =
            await _messaging.getToken();
        if (newToken !=
            null) {
          await _saveTokenToDatabase(
            newToken,
          );
          print(
            'Generated and saved new FCM token',
          );
        }
      }
    } catch (
      e
    ) {
      print(
        'Error verifying FCM tokens: $e',
      );
    }
  }

  @override
  void onClose() {
    super.onClose();
    _flutterLocalNotificationsPlugin.cancelAll();
  }
}
