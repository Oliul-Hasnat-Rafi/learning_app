import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:language_learning_app/app/models/language_model.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/auth_service.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/firestore_service.dart';

class TeacherProfileController
    extends
        GetxController {
  final AuthService _authService = Get.put(
    AuthService(),
  );
  final FirestoreService _firestoreService = Get.put(
    FirestoreService(),
  );

  final RxBool isLoading =
      false.obs;
  final RxString bio =
      ''.obs;
  final RxDouble hourlyRate =
      0.0.obs;
  final RxList<
    String
  >
  selectedLanguageIds =
      <
            String
          >[]
          .obs;
  final RxList<
    LanguageModel
  >
  availableLanguages =
      <
            LanguageModel
          >[]
          .obs;
  final RxList<
    LanguageModel
  >
  availableLanguagesV1 =
      <
            LanguageModel
          >[]
          .obs;
  final RxList<
    String
  >
  availability =
      <
            String
          >[]
          .obs;

  @override
  void onInit() {
    super.onInit();
    loadTeacherProfile();
    loadAvailableLanguages();
  }

  Future<
    void
  >
  loadTeacherProfile() async {
    try {
      isLoading.value = true;

      String teacherId =
          _authService.currentUser.value!.id;
      DocumentSnapshot
      doc =
          await FirebaseFirestore.instance
              .collection(
                'teachers',
              )
              .doc(
                teacherId,
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

        bio.value =
            data['bio'] ??
            '';
        hourlyRate.value =
            (data['hourlyRate'] ??
                    0.0)
                .toDouble();
        selectedLanguageIds.value = List<
          String
        >.from(
          data['languages'] ??
              [],
        );
        availability.value = List<
          String
        >.from(
          data['availability'] ??
              [],
        );
      }
    } catch (
      e
    ) {
      print(
        'Error loading teacher profile: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }



  Future<
    void
  >
  loadAvailableLanguages() async {
    try {
      availableLanguages.value = await _firestoreService.getLanguages();
    } catch (
      e
    ) {
      print(
        'Error loading languages: $e',
      );
    }
  }

  void toggleLanguage(
    String languageId,
  ) {
    if (selectedLanguageIds.contains(
      languageId,
    )) {
      selectedLanguageIds.remove(
        languageId,
      );
    } else {
      selectedLanguageIds.add(
        languageId,
      );
    }
  }

  void addAvailabilitySlot(
    DateTime dateTime,
  ) {
    String dateTimeString =
        dateTime.toIso8601String();
    if (!availability.contains(
      dateTimeString,
    )) {
      availability.add(
        dateTimeString,
      );
      availability.sort(
        (
          a,
          b,
        ) => DateTime.parse(
          a,
        ).compareTo(
          DateTime.parse(
            b,
          ),
        ),
      );
    }
  }

  void removeAvailabilitySlot(
    String dateTimeString,
  ) {
    availability.remove(
      dateTimeString,
    );
  }

  Future<
    bool
  >
  saveTeacherProfile() async {
    try {
      isLoading.value = true;

      String teacherId =
          _authService.currentUser.value!.id;

      return await _firestoreService.updateTeacherProfile(
        teacherId:
            teacherId,
        languages:
            selectedLanguageIds,
        bio:
            bio.value,
        hourlyRate:
            hourlyRate.value,
        availability:
            availability,
      );
    } catch (
      e
    ) {
      print(
        'Error saving teacher profile: $e',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
