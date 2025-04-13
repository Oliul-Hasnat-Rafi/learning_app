import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/firebase_service/auth_service.dart';

class AuthController
    extends
        GetxController {
  final AuthService _authService = Get.put(
    AuthService(),
  );

  final Rx<
    bool
  >
  isLoading =
      false.obs;
  final Rx<
    String
  >
  errorMessage =
      ''.obs;

  final RxBool isLogin =
      true.obs;
  final RxString selectedRole =
      'student'.obs;

  final RxBool isSelected =
      true.obs;

  void toggleLoginSignup() {
    isLogin.value = !isLogin.value;
    errorMessage.value = '';
  }

  void setRole(
    String role,
  ) {
    selectedRole.value = role;

    if (role ==
        'student') {
      isSelected.value = true;
    } else {
      isSelected.value = false;
    }

    errorMessage.value = '';
  }

  Future<
    bool
  >
  handleSubmit(
    String email,
    String password, {
    String? name,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      bool success;

      if (isLogin.value) {
        success = await _authService.signIn(
          email,
          password,
        );
      } else {
        if (name ==
                null ||
            name.isEmpty) {
          errorMessage.value = 'Name is required';
          isLoading.value = false;
          return false;
        }
        success = await _authService.signUp(
          email,
          password,
          name,
          selectedRole.value,
        );
      }

      if (!success) {
        errorMessage.value = 'Authentication failed. Please try again.';
        return false;
      }
      return true;
    } catch (
      e
    ) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
