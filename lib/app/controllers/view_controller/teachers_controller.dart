import 'package:get/get.dart';
import 'package:language_learning_app/app/controllers/view_controller/chat_controller.dart';
import 'package:language_learning_app/app/models/teacher_model.dart';
import 'package:language_learning_app/app/models/user_model.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/firestore_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:language_learning_app/app/view/scheduling/scheduling_view.dart';
import 'package:tuple/tuple.dart';

import '../../view/chat/chat_detail_view.dart';

class TeachersController
    extends
        GetxController {
  final FirestoreService _firestoreService = Get.put(
    FirestoreService(),
  );
  final ChatController chatController = Get.put(
    ChatController(),
  );
  final RxList<
    TeacherWithUserData
  >
  teachers =
      <
            TeacherWithUserData
          >[]
          .obs;
  final RxBool isLoading =
      true.obs;
  final RxString languageId =
      ''.obs;
  final RxString languageName =
      ''.obs;

  TeachersController({
    String? languageId,
  }) {
    if (languageId !=
        null) {
      this.languageId.value = languageId;
    }
  }
  @override
  void onInit() {
    super.onInit();

    if (languageId.value.isNotEmpty) {
      fetchTeachersByLanguage();
      fetchLanguageName();
    }
  }

  Future<
    void
  >
  fetchTeachersByLanguage() async {
    try {
      isLoading.value = true;

      List<
        TeacherModel
      >
      teacherModels = await _firestoreService.getTeachersByLanguage(
        languageId.value,
      );

      List<
        TeacherWithUserData
      >
      teachersWithData =
          [];

      for (var teacher in teacherModels) {
        DocumentSnapshot
        userDoc =
            await FirebaseFirestore.instance
                .collection(
                  'users',
                )
                .doc(
                  teacher.userId,
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
          UserModel user = UserModel.fromJson(
            {
              'id':
                  userDoc.id,
              ...userData,
            },
          );

          teachersWithData.add(
            TeacherWithUserData(
              teacher:
                  teacher,
              user:
                  user,
            ),
          );
        }
      }

      teachers.value = teachersWithData;
    } catch (
      e
    ) {
      print(
        'Error fetching teachers: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<
    void
  >
  fetchLanguageName() async {
    try {
      DocumentSnapshot
      doc =
          await FirebaseFirestore.instance
              .collection(
                'languages',
              )
              .doc(
                languageId.value,
              )
              .get();

      if (doc.exists) {
        languageName.value = doc.get(
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

  Future<
    bool
  >
  selectTeacher(
    TeacherWithUserData teacher,
  ) async {
    Get.to(
      SchedulingView(
        teacherData: Tuple4(
          teacher.teacher.id,
          languageId.value,
          teacher.teacher.hourlyRate,
          teacher.user.name,
        ),
      ),
    );
    return true;
  }

  void startChatWithTeacher(
    dynamic teacherData,
  ) async {
    try {
      final teacherId =
          teacherData.user.id;
      final teacherName =
          teacherData.user.name;
      final teacherPhoto =
          teacherData.user.photoUrl;

      final success = await chatController.createConversationWithTeacher(
        teacherId,
        teacherName,
        teacherPhoto,
      );

      if (success &&
          chatController.currentConversationId.value.isNotEmpty) {
        Get.to(
          () => ChatDetailView(
            conversationId:
                chatController.currentConversationId.value,
          ),
        );
      } else {
        Get.snackbar(
          'Error',
          'Unable to start chat at this time',
          snackPosition:
              SnackPosition.BOTTOM,
        );
      }
    } catch (
      e
    ) {
      print(
        'Error starting chat with teacher: $e',
      );
      Get.snackbar(
        'Error',
        'Failed to connect with teacher',
        snackPosition:
            SnackPosition.BOTTOM,
      );
    }
  }
}

class TeacherWithUserData {
  final TeacherModel teacher;
  final UserModel user;

  TeacherWithUserData({
    required this.teacher,
    required this.user,
  });
}
