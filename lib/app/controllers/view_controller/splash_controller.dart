import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/auth_service.dart';
import 'package:language_learning_app/app/utils/components.dart';

class SplashController
    extends
        GetxController {
  final AuthService _authService = Get.put(
    AuthService(),
  );
  Rx<
    User?
  >
  firebaseUser = Rx<
    User?
  >(
    null,
  );
  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();

    Future.delayed(
      defaultDuration *
          6,
    ).then(
      (
        value,
      ) {
        firebaseUser.bindStream(
          _auth.authStateChanges(),
        );

        ever(
          firebaseUser,
          _authService.setInitialScreen,
        );
      },
    );
  }
}
