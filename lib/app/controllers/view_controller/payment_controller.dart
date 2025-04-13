import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/auth_service.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/firestore_service.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/notification_service.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/payment_service.dart';
import 'package:language_learning_app/app/models/booking_model.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

class PaymentController
    extends
        GetxController {
  final PaymentService _paymentService = Get.put(
    PaymentService(),
  );
  final FirestoreService _firestoreService = Get.put(
    FirestoreService(),
  );
  final NotificationService _notificationService = Get.put(
    NotificationService(),
  );
  final AuthService _authService = Get.put(
    AuthService(),
  );

  final RxString teacherId =
      ''.obs;
  final RxString teacherName =
      ''.obs;
  final RxString languageId =
      ''.obs;
  final RxString studentId =
      ''.obs;
  final Rx<
    DateTime
  >
  startTime = Rx<
    DateTime
  >(
    DateTime.now(),
  );
  final Rx<
    DateTime
  >
  endTime = Rx<
    DateTime
  >(
    DateTime.now().add(
      const Duration(
        hours:
            1,
      ),
    ),
  );
  final RxDouble amount =
      0.0.obs;
  Tuple7<
    String,
    String,
    String,
    String,
    double,
    DateTime,
    DateTime
  >?
  paymentData = Tuple7(
    '',
    '',
    '',
    '',
    0.0,
    DateTime.now(),
    DateTime.now(),
  );

  final RxBool isProcessing =
      false.obs;
  final RxString errorMessage =
      ''.obs;
  final RxBool isPaymentComplete =
      false.obs;
  final RxString bookingId =
      ''.obs;

  PaymentController({
    this.paymentData,
  });

  @override
  void onInit() async {
    super.onInit();

    if (paymentData !=
        null) {
      teacherId.value = paymentData!.item1;
      teacherName.value = paymentData!.item2;
      languageId.value = paymentData!.item3;
      studentId.value = paymentData!.item4;

      amount.value = paymentData!.item5;
      startTime.value = paymentData!.item6;
      endTime.value = paymentData!.item7;
    }
  }

  String formatDate(
    DateTime date,
  ) {
    return DateFormat(
      'EEEE, MMMM d, yyyy',
    ).format(
      date,
    );
  }

  String formatTime(
    DateTime date,
  ) {
    return DateFormat(
      'h:mm a',
    ).format(
      date,
    );
  }

  Future<
    bool
  >
  processPayment() async {
    try {
      isProcessing.value = true;
      errorMessage.value = '';
      final String videoCallChannel =
          const Uuid().v4();
      final String videoCallToken =
          const Uuid().v4();
      final String paymentId = await _paymentService.makePayment(
        amount:
            amount.value,
        currency:
            'usd',
      );

      if (paymentId.isNotEmpty) {
        final booking = BookingModel(
          id:
              const Uuid().v4(),
          studentId:
              studentId.value,
          teacherId:
              teacherId.value,
          languageId:
              languageId.value,
          startTime:
              startTime.value,
          endTime:
              endTime.value,
          amount:
              amount.value,
          status:
              BookingStatus.pending.name,
          paymentId:
              paymentId,
          videoCallChannel:
              videoCallChannel,
          videoCallToken:
              videoCallToken,
          createdAt:
              DateTime.now(),
        );

        final bookingDocId = await _firestoreService.createBooking(
          booking,
        );
        bookingId.value = bookingDocId;

        await _notificationService.sendNotificationToUser(
          userId:
              teacherId.value,
          studentId:
              studentId.value,
          title:
              'New Booking',
          body:
              'You have a new lesson booked by ${_authService.currentUser.value?.name ?? "User"} on ${formatDate(startTime.value)} at ${formatTime(startTime.value)}',
          data: {
            'type':
                'booking',
            'bookingId':
                bookingDocId,
          },
        );
        isPaymentComplete.value = true;
        return true;
      } else {
        errorMessage.value = 'Payment processing failed';
        return false;
      }
    } catch (
      e
    ) {
      print(
        'Error processing payment: $e',
      );
      errorMessage.value = 'Payment failed: ${e.toString()}';
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
}
