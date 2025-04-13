import 'package:get/get.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/firestore_service.dart';
import 'package:language_learning_app/app/view/teacher/teachers_view.dart';

import '../../models/language_model.dart';

class LanguagesController
    extends
        GetxController {
  final FirestoreService _firestoreService = Get.put(
    FirestoreService(),
  );

  final RxList<
    LanguageModel
  >
  languages =
      <
            LanguageModel
          >[]
          .obs;
  final RxBool isLoading =
      true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLanguages();
  }

  Future<
    void
  >
  fetchLanguages() async {
    try {
      isLoading.value = true;
      languages.value = await _firestoreService.getLanguages();
    } catch (
      e
    ) {
      print(
        'Error fetching languages: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<
    bool
  >?
  selectLanguage(
    String languageId,
  ) {
    Get.to(
      () => TeachersView(
        languageId:
            languageId,
      ),
    );
  }
}
