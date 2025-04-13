import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:language_learning_app/app/controllers/services/functions/date_time_conversion.dart';
import 'package:language_learning_app/app/view/payment/payment_view.dart';
import 'package:tuple/tuple.dart';
import '../../models/teacher_model.dart';
import '../services/firebase_service/firestore_service.dart';
import '../services/firebase_service/auth_service.dart';

class SchedulingController
    extends
        GetxController {
  final AuthService _authService = Get.put(
    AuthService(),
  );
  final FirestoreService _firestoreService = Get.put(
    FirestoreService(),
  );

  final RxString teacherId =
      ''.obs;
  final RxString languageId =
      ''.obs;
  final RxString teacherName =
      ''.obs;
  final RxString studentName =
      ''.obs;
  final RxDouble hourlyRate =
      0.0.obs;

  final Rx<
    TeacherModel?
  >
  teacher = Rx<
    TeacherModel?
  >(
    null,
  );
  final RxBool isLoading =
      true.obs;

  final RxList<
    DateTime
  >
  availableSlots =
      <
            DateTime
          >[]
          .obs;
  final Rx<
    DateTime?
  >
  selectedSlot = Rx<
    DateTime?
  >(
    null,
  );
  final Rx<
    DateTime?
  >
  selectedDate = Rx<
    DateTime?
  >(
    null,
  );

  Tuple4<
    String,
    String,
    double,
    String
  >?
  teacherData = const Tuple4(
    '',
    '',
    0.0,
    '',
  );

  SchedulingController({
    this.teacherData,
  });

  @override
  void onInit() {
    super.onInit();

    if (teacherData !=
        null) {
      teacherId.value = teacherData!.item1;
      languageId.value = teacherData!.item2;
      teacherName.value = teacherData!.item4;
      hourlyRate.value = teacherData!.item3;

      fetchTeacherDetails();
    }
  }

  Future<
    void
  >
  fetchTeacherDetails() async {
    try {
      isLoading.value = true;

      teacher.value = await _firestoreService.getTeacherById(
        teacherId.value,
      );

      if (teacher.value !=
          null) {
        availableSlots.value =
            teacher.value!.availability
                .map(
                  (
                    slot,
                  ) => DateTime.parse(
                    slot,
                  ),
                )
                .where(
                  (
                    date,
                  ) => date.isAfter(
                    DateTime.now(),
                  ),
                )
                .toList();

        availableSlots.sort();
      }
    } catch (
      e
    ) {
      print(
        'Error fetching teacher details: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectTimeSlot(
    DateTime? slot,
  ) {
    selectedSlot.value = slot;
    selectedDate.value = DateTime(
      slot!.year,
      slot.month,
      slot.day,
    );
  }

  void selectDate(
    DateTime date,
  ) {
    selectedDate.value = date;

    if (selectedSlot.value !=
        null) {
      final slot =
          selectedSlot.value!;
      if (slot.year !=
              date.year ||
          slot.month !=
              date.month ||
          slot.day !=
              date.day) {
        selectedSlot.value = null;
      }
    }
    update();
  }

  String formatDate(
    DateTime date,
  ) {
    return date.custom_EEEE_MMM_d_yyyy;
  }

  String formatTime(
    DateTime date,
  ) {
    return date.custom_hh_mm_a;
  }

  bool isSlotOnSameDay(
    DateTime a,
    DateTime b,
  ) {
    return a.customIsSameDay(
      otherDate:
          b,
    );
  }

  List<
    DateTime
  >
  getSlotsForDay(
    DateTime day,
  ) {
    return availableSlots
        .where(
          (
            slot,
          ) => isSlotOnSameDay(
            slot,
            day,
          ),
        )
        .toList();
  }

  List<
    DateTime
  >
  getUniqueDays() {
    final Map<
      String,
      DateTime
    >
    uniqueDays =
        {};

    for (final slot in availableSlots) {
      final dayKey = DateFormat(
        'yyyy-MM-dd',
      ).format(
        slot,
      );
      if (!uniqueDays.containsKey(
        dayKey,
      )) {
        uniqueDays[dayKey] =
            slot.customConvertToDateTimeDate;
      }
    }

    final result =
        uniqueDays.values.toList();
    result.sort();
    return result;
  }

  void proceedToPayment() {
    if (selectedSlot.value !=
        null) {
      final endTime = selectedSlot.value!.add(
        const Duration(
          hours:
              1,
        ),
      );

      Get.to(
        PaymentView(
          paymentData: Tuple7(
            teacherId.value,
            teacherName.value,
            languageId.value,
            _authService.currentUser.value!.id,
            hourlyRate.value,
            selectedSlot.value!,
            endTime,
          ),
        ),
      );
    }
  }
}
