import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:language_learning_app/app/view/widget/custom_animated_size_widget.dart';
import 'package:language_learning_app/app/view/widget/custom_image.dart';
import 'package:language_learning_app/app/view/widget/custom_text_field1.dart';
import 'package:language_learning_app/app/view/widget/svg.dart';
import 'package:language_learning_app/app/view/widget/title_text.dart.dart';
import 'package:language_learning_app/app/utils/components.dart';
import 'package:on_process_button_widget/on_process_button_widget.dart';
import '../../controllers/view_controller/auth_controller.dart';

class AuthView
    extends
        StatelessWidget {
  AuthView({
    super.key,
  });
  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();
  final TextEditingController _nameController =
      TextEditingController();
  final AuthController controller = Get.put(
    AuthController(),
  );

  _size(
    int i,
  ) {
    return SizedBox(
      height:
          defaultPadding /
          i,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(
          defaultPadding,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                CustomImage(
                  image:
                      'assets/images/Logo_title.png',
                  height:
                      defaultPadding *
                      2,
                ),
                _size(
                  2,
                ),
                const TitleText(
                  "Sign up and start learning any language",
                ),
                Obx(
                  () => Text(
                    controller.isLogin.value
                        ? 'Sign In'
                        : 'Create Account',
                    textAlign:
                        TextAlign.center,
                    style: const TextStyle(
                      fontSize:
                          20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                _size(
                  1,
                ),
                Obx(
                  () => CustomAnimatedSize(
                    child:
                        controller.isLogin.value
                            ? const SizedBox.shrink()
                            : CustomTextField1(
                              textEditingController:
                                  _nameController,
                              hintText:
                                  'Name',
                              prefixChild: const Icon(
                                Icons.person,
                              ),
                            ),
                  ),
                ),
                Obx(
                  () =>
                      controller.isLogin.value
                          ? const SizedBox.shrink()
                          : const SizedBox(
                            height:
                                15,
                          ),
                ),
                CustomTextField1(
                  textEditingController:
                      _emailController,
                  hintText:
                      'Email',
                  prefixChild: const Icon(
                    Icons.email,
                  ),
                ),
                _size(
                  2,
                ),
                CustomTextField1(
                  textEditingController:
                      _passwordController,
                  hintText:
                      'Password',
                  prefixChild: const CustomSVG(
                    "assets/icons/lock_icon.svg",
                  ),
                  obscureText:
                      true,
                ),
                _size(
                  2,
                ),
                Obx(
                  () =>
                      controller.isLogin.value
                          ? const SizedBox.shrink()
                          : Row(
                            children: [
                              const SubtitleText(
                                string:
                                    'I want to:',
                              ),
                              SizedBox(
                                width:
                                    defaultPadding /
                                    2,
                              ),
                              CustomAnimatedSize(
                                alignment:
                                    Alignment.topCenter,
                                child: Obx(
                                  () => _BackContainer(
                                    children: [
                                      _Button(
                                        text:
                                            "Learn",
                                        isSelected:
                                            controller.isSelected.value,
                                        onTap:
                                            () => controller.setRole(
                                              'student',
                                            ),
                                        isLearnSection:
                                            false,
                                      ),
                                      _Button(
                                        text:
                                            "Teach",
                                        isSelected:
                                            !controller.isSelected.value,
                                        onTap:
                                            () => controller.setRole(
                                              'teacher',
                                            ),
                                        isLearnSection:
                                            false,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                ),
                _size(
                  2,
                ),
                // Error message
                Obx(
                  () =>
                      controller.errorMessage.value.isNotEmpty
                          ? Text(
                            controller.errorMessage.value,
                            style: const TextStyle(
                              color:
                                  Colors.red,
                            ),
                            textAlign:
                                TextAlign.center,
                          )
                          : const SizedBox.shrink(),
                ),
                _size(
                  2,
                ),
                Obx(
                  () => OnProcessButtonWidget(
                    onTap:
                        controller.isLoading.value
                            ? null
                            : () => controller.handleSubmit(
                              _emailController.text,
                              _passwordController.text,
                              name:
                                  _nameController.text,
                            ),
                    onDone:
                        (
                          isSuccess,
                        ) {},
                    child: Text(
                      controller.isLogin.value
                          ? 'Login'
                          : 'Sign Up',
                      style: const TextStyle(
                        fontSize:
                            16,
                      ),
                    ),
                  ),
                ),
                _size(
                  2,
                ),
                Center(
                  child: Obx(
                    () => RichText(
                      text: TextSpan(
                        text:
                            controller.isLogin.value
                                ? 'Create a new account '
                                : 'Already have an account? ',
                        style: const TextStyle(
                          color:
                              Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text:
                                controller.isLogin.value
                                    ? 'Sign Up'
                                    : 'Login',
                            style: const TextStyle(
                              color:
                                  Colors.blue,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () =>
                                          controller.toggleLoginSignup(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackContainer
    extends
        StatelessWidget {
  const _BackContainer({
    required this.children,
  });
  final List<
    Widget
  >
  children;

  @override
  Widget build(
    BuildContext context,
  ) {
    return AnimatedContainer(
      duration:
          defaultDuration,
      clipBehavior:
          Clip.hardEdge,
      padding: EdgeInsets.symmetric(
        vertical:
            defaultPadding /
            4,
        horizontal:
            defaultPadding /
            2,
      ),
      margin: EdgeInsets.all(
        defaultPadding /
            8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          Theme.of(
            context,
          ).buttonTheme.height,
        ),
        color: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withOpacity(
          0.1,
        ),
      ),
      child: Wrap(
        spacing:
            defaultPadding /
            4,
        runSpacing:
            defaultPadding /
            4,
        alignment:
            WrapAlignment.center,
        children:
            children,
      ),
    );
  }
}

class _Button
    extends
        StatelessWidget {
  const _Button({
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.isLearnSection =
        true,
  });
  final String text;
  final bool isSelected;
  final bool isLearnSection;
  final Function() onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return OnProcessButtonWidget(
      expanded:
          false,
      contentPadding: EdgeInsets.symmetric(
        horizontal:
            12,
        vertical:
            defaultPadding /
            3,
      ),
      constraints:
          isLearnSection
              ? null
              : const BoxConstraints(),
      boxShadow:
          isSelected
              ? [
                BoxShadow(
                  color: blendColors(
                    baseColor:
                        Theme.of(
                          context,
                        ).colorScheme.surface,
                    blendColor:
                        Theme.of(
                          context,
                        ).colorScheme.onSurface,
                    blendMode:
                        BlendModeType.multiply,
                  ).withOpacity(
                    0.1,
                  ),
                  blurRadius:
                      defaultPadding,
                  offset: Offset(
                    defaultPadding /
                        2,
                    defaultPadding /
                        2,
                  ),
                ),
              ]
              : null,
      fontColor:
          Theme.of(
            context,
          ).colorScheme.onSurface,
      backgroundColor:
          Colors.transparent,
      borderRadius: BorderRadius.circular(
        Theme.of(
          context,
        ).buttonTheme.height,
      ),
      onDone:
          (
            _,
          ) =>
              onTap(),
      child: AnimatedContainer(
        duration:
            defaultDuration,
        curve:
            Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal:
              8,
          vertical:
              4,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(
                    context,
                  ).colorScheme.surface
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(
            Theme.of(
              context,
            ).buttonTheme.height,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight:
                isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  //! ------------------------------------------------------------------------------------------------ Colors
  Color blendColors({
    required Color baseColor,
    required Color blendColor,
    required BlendModeType blendMode,
  }) {
    double normalize(
      int value,
    ) =>
        value /
        255.0;

    int
    clamp(
      double value,
    ) =>
        value
            .clamp(
              0,
              255,
            )
            .toInt();

    switch (blendMode) {
      case BlendModeType.normal:
        return baseColor;

      case BlendModeType.multiply:
        return Color.fromARGB(
          baseColor.alpha,
          clamp(
            normalize(
                  baseColor.red,
                ) *
                normalize(
                  blendColor.red,
                ) *
                255,
          ),
          clamp(
            normalize(
                  baseColor.green,
                ) *
                normalize(
                  blendColor.green,
                ) *
                255,
          ),
          clamp(
            normalize(
                  baseColor.blue,
                ) *
                normalize(
                  blendColor.blue,
                ) *
                255,
          ),
        );

      case BlendModeType.screen:
        return Color.fromARGB(
          baseColor.alpha,
          clamp(
            (1 -
                    (1 -
                            normalize(
                              baseColor.red,
                            )) *
                        (1 -
                            normalize(
                              blendColor.red,
                            ))) *
                255,
          ),
          clamp(
            (1 -
                    (1 -
                            normalize(
                              baseColor.green,
                            )) *
                        (1 -
                            normalize(
                              blendColor.green,
                            ))) *
                255,
          ),
          clamp(
            (1 -
                    (1 -
                            normalize(
                              baseColor.blue,
                            )) *
                        (1 -
                            normalize(
                              blendColor.blue,
                            ))) *
                255,
          ),
        );

      default:
        return baseColor;
    }
  }
}

enum BlendModeType {
  normal,
  multiply,
  screen,
}
