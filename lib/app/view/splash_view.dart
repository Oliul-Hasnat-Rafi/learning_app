import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:language_learning_app/app/controllers/view_controller/splash_controller.dart';
import 'package:language_learning_app/app/view/widget/custom_image.dart';
import 'package:language_learning_app/app/view/widget/svg.dart';
import 'package:language_learning_app/app/view/widget/title_text.dart.dart' show TitleText;
import 'package:language_learning_app/app/utils/components.dart';

class SplashView
    extends
        StatelessWidget {
   SplashView({
    super.key,
  });
  final SplashController controller = Get.put(SplashController());
  _size(int i){
    return SizedBox(
      height: defaultPadding /
          i,
    );
  }
  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Center(
            child: CustomImage(
              image:
                  'assets/images/Logo.png',
            ),
          ),
         _size(4),
          const CustomImage(
            image:
                'assets/images/lan.png',
          ),
           _size(1),
          const TitleText(
            "Learn a language with us",
          ),
        ],
      ),
    );
  }
}
