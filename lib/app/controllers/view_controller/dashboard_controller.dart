import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/notification_service.dart';
import 'package:language_learning_app/app/controllers/view_controller/languages_controller.dart';
import 'package:language_learning_app/app/models/booking_model.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/auth_service.dart';

class DashboardController
    extends
        GetxController {
  final AuthService _authService = Get.put(
    AuthService(),
  );
  final LanguagesController _languagesController = Get.put(
    LanguagesController(),
  );
  final NotificationService _notificationService =
      Get.put(
        NotificationService(),
        permanent: true
      );
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final RxString userName =
      ''.obs;
  final RxBool isProfileComplete =
      false.obs;
  final RxBool isLoading =
      true.obs;
  final RxList<
    BookingModel
  >
  upcomingBookings =
      <
            BookingModel
          >[]
          .obs;
  final RxMap<
    String,
    String
  >
  userNames =
      <
            String,
            String
          >{}
          .obs;
  final RxMap<
    String,
    String
  >
  languageNames =
      <
            String,
            String
          >{}
          .obs;
  final RxInt unreadNotifications =
      0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    _languagesController.fetchLanguages();
    _notificationService.initNotifications();

    if (_authService.currentUser.value?.role ==
        'teacher') {
      checkProfileCompletion();
      fetchTeacherBookings();
    } else {
      fetchStudentBookings();
    }
    checkNotifications();
  }

  void loadUserData() {
    userName.value =
        _authService.currentUser.value?.name ??
        '';
  }

  Future<
    void
  >
  checkProfileCompletion() async {
    try {
      String userId =
          _authService.currentUser.value!.id;
      DocumentSnapshot
      doc =
          await _firestore
              .collection(
                'teachers',
              )
              .doc(
                userId,
              )
              .get();

      if (doc.exists) {
        Map<
          String,
          dynamic
        >
        data =
            doc.data()
                as Map<
                  String,
                  dynamic
                >;
        List<
          String
        >
        languages = List<
          String
        >.from(
          data['languages'] ??
              [],
        );
        String bio =
            data['bio'] ??
            '';
        double
        hourlyRate =
            (data['hourlyRate'] ??
                    0.0)
                .toDouble();
        List<
          String
        >
        availability = List<
          String
        >.from(
          data['availability'] ??
              [],
        );

        isProfileComplete.value =
            languages.isNotEmpty &&
            bio.isNotEmpty &&
            hourlyRate >
                0 &&
            availability.isNotEmpty;
      }
    } catch (
      e
    ) {
      print(
        'Error checking profile completion: $e',
      );
    }
  }

  Future<
    void
  >
  fetchStudentBookings() async {
    try {
      isLoading.value = true;
      String studentId =
          _authService.currentUser.value!.id;

      QuerySnapshot
      querySnapshot =
          await _firestore
              .collection(
                'bookings',
              )
              .where(
                'studentId',
                isEqualTo:
                    studentId,
              )
              .get();

      _processBookings(
        querySnapshot,
      );

      for (var booking in upcomingBookings) {
        await _fetchTeacherName(
          booking.teacherId,
        );
        await _fetchLanguageName(
          booking.languageId,
        );
      }
    } catch (
      e
    ) {
      print(
        'Error fetching student bookings: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<
    void
  >
  fetchTeacherBookings() async {
    try {
      isLoading.value = true;
      String teacherId =
          _authService.currentUser.value!.id;

      QuerySnapshot
      querySnapshot =
          await _firestore
              .collection(
                'bookings',
              )
              .where(
                'teacherId',
                isEqualTo:
                    teacherId,
              )
              .get();

      _processBookings(
        querySnapshot,
      );

      for (var booking in upcomingBookings) {
        await _fetchStudentName(
          booking.studentId,
        );
        await _fetchLanguageName(
          booking.languageId,
        );
      }
    } catch (
      e
    ) {
      print(
        'Error fetching teacher bookings: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _processBookings(
    QuerySnapshot querySnapshot,
  ) {
    upcomingBookings.clear();

    for (var doc in querySnapshot.docs) {
      try {
        Map<
          String,
          dynamic
        >
        data =
            doc.data()
                as Map<
                  String,
                  dynamic
                >;
        DateTime startTime = DateTime.parse(
          data['startTime'],
        );
        DateTime endTime = DateTime.parse(
          data['endTime'],
        );

        BookingModel booking = BookingModel(
          id:
              doc.id,
          studentId:
              data['studentId'],
          teacherId:
              data['teacherId'],
          languageId:
              data['languageId'],
          startTime:
              startTime,
          endTime:
              endTime,
          amount:
              (data['amount']
                      is int)
                  ? (data['amount']
                          as int)
                      .toDouble()
                  : data['amount'],
          status:
              data['status'],
          paymentId:
              data['paymentId'],
          videoCallChannel:
              data['videoCallChannel'],
          videoCallToken:
              data['videoCallToken'],
          createdAt: DateTime.parse(
            data['createdAt'],
          ),
        );

        // Include bookings that are happening now or in the future
        // Also include recent bookings (within the last hour)
        if (startTime.isAfter(
          DateTime.now().subtract(
            const Duration(
              hours:
                  1,
            ),
          ),
        )) {
          upcomingBookings.add(
            booking,
          );
        }
      } catch (
        parseError
      ) {
        print(
          'Error parsing booking document: $parseError',
        );
      }
    }

    // Sort bookings by start time (earliest first)
    upcomingBookings.sort(
      (
        a,
        b,
      ) => a.startTime.compareTo(
        b.startTime,
      ),
    );
  }

  Future<
    void
  >
  _fetchTeacherName(
    String teacherId,
  ) async {
    if (!userNames.containsKey(
      teacherId,
    )) {
      try {
        DocumentSnapshot
        doc =
            await _firestore
                .collection(
                  'users',
                )
                .doc(
                  teacherId,
                )
                .get();
        if (doc.exists) {
          userNames[teacherId] = doc.get(
            'name',
          );
        }
      } catch (
        e
      ) {
        print(
          'Error fetching teacher name: $e',
        );
      }
    }
  }

  Future<
    void
  >
  _fetchStudentName(
    String studentId,
  ) async {
    if (!userNames.containsKey(
      studentId,
    )) {
      try {
        DocumentSnapshot
        doc =
            await _firestore
                .collection(
                  'users',
                )
                .doc(
                  studentId,
                )
                .get();
        if (doc.exists) {
          userNames[studentId] = doc.get(
            'name',
          );
        }
      } catch (
        e
      ) {
        print(
          'Error fetching student name: $e',
        );
      }
    }
  }

  Future<
    void
  >
  _fetchLanguageName(
    String languageId,
  ) async {
    if (!languageNames.containsKey(
      languageId,
    )) {
      try {
        DocumentSnapshot
        doc =
            await _firestore
                .collection(
                  'languages',
                )
                .doc(
                  languageId,
                )
                .get();
        if (doc.exists) {
          languageNames[languageId] = doc.get(
            'name',
          );
        }
      } catch (
        e
      ) {
        print(
          'Error fetching language name: $e',
        );
      }
    }
  }

  String getTeacherName(
    String teacherId,
  ) {
    return userNames[teacherId] ??
        '';
  }

  String getStudentName(
    String studentId,
  ) {
    return userNames[studentId] ??
        '';
  }

  String getLanguageName(
    String languageId,
  ) {
    return languageNames[languageId] ??
        '';
  }

  Future<
    void
  >
  joinClass(
    String bookingId,
  ) async {
    try {
      BookingModel? booking = upcomingBookings.firstWhereOrNull(
        (
          b,
        ) =>
            b.id ==
            bookingId,
      );

      if (booking !=
          null) {}
    } catch (
      e
    ) {
      print(
        'Error joining class: $e',
      );
      Get.snackbar(
        'Error',
        'Failed to join class: $e',
        snackPosition:
            SnackPosition.BOTTOM,
      );
    }
  }

  Future<
    void
  >
  startClass(
    String bookingId,
  ) async {
    try {
      BookingModel? booking = upcomingBookings.firstWhereOrNull(
        (
          b,
        ) =>
            b.id ==
            bookingId,
      );

      if (booking !=
          null) {
        //         Get.to(() => VideoCallScreen(
        //   appId: agoraAppid,
        //   channelName: booking.videoCallChannel,
        //   token: booking.videoCallToken,
        //   uid: 2, // Different UID for students
        // ));
        // Navigate to chat for now (actual video call implementation would go here)
      }
    } catch (
      e
    ) {
      print(
        'Error starting class: $e',
      );
      Get.snackbar(
        'Error',
        'Failed to start class: $e',
        snackPosition:
            SnackPosition.BOTTOM,
      );
    }
  }

  Future<
    bool
  >
  signOut() {
    return _authService.signOut();
  }

  Future<
    void
  >
  checkNotifications() async {
    if (_authService.currentUser.value ==
        null)
      return;

    String userId =
        _authService.currentUser.value!.id;

    try {
      QuerySnapshot
      querySnapshot =
          await _firestore
              .collection(
                'notifications',
              )
              .where(
                'userId',
                isEqualTo:
                    userId,
              )
              .where(
                'read',
                isEqualTo:
                    false,
              )
              .get();

      unreadNotifications.value = querySnapshot.docs.length;
    } catch (
      e
    ) {
      print(
        'Error checking notifications: $e',
      );
    }
  }

  Future<
    void
  >
  bookingStatusUpdate(
    String bookingId,
    String status,
  ) async {
    try {
      await _firestore
          .collection(
            'bookings',
          )
          .doc(
            bookingId,
          )
          .update(
            {
              'status':
                  status,
            },
          );

      // Refresh bookings list
      if (_authService.currentUser.value?.role ==
          'teacher') {
        fetchTeacherBookings();
      } else {
        fetchStudentBookings();
      }
    } catch (
      e
    ) {
      print(
        'Error updating booking status: $e',
      );
      Get.snackbar(
        'Error',
        'Failed to update booking status: $e',
        snackPosition:
            SnackPosition.BOTTOM,
      );
    }
  }

  Future<
    void
  >
  markNotificationsAsRead() async {
    if (_authService.currentUser.value ==
        null)
      return;

    String userId =
        _authService.currentUser.value!.id;

    try {
      QuerySnapshot
      querySnapshot =
          await _firestore
              .collection(
                'notifications',
              )
              .where(
                'userId',
                isEqualTo:
                    userId,
              )
              .where(
                'read',
                isEqualTo:
                    false,
              )
              .get();

      WriteBatch batch =
          _firestore.batch();

      for (var doc in querySnapshot.docs) {
        batch.update(
          doc.reference,
          {
            'read':
                true,
          },
        );
      }

      await batch.commit();
      unreadNotifications.value = 0;
    } catch (
      e
    ) {
      print(
        'Error marking notifications as read: $e',
      );
    }
  }
}
