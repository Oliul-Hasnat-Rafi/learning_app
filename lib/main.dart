import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/auth_service.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/chat_service.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/firestore_service.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/notification_service.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/payment_service.dart';
import 'package:language_learning_app/app/view/splash_view.dart';
import 'package:language_learning_app/app/utils/components.dart';
import 'package:language_learning_app/firebase_options.dart';
import 'package:language_learning_app/app/utils/firebase_setup_util.dart';
import 'package:language_learning_app/app/utils/secret.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseSetupUtil.uploadLanguages();
  
  await dotenv.load(fileName: "assets/.env");
  
  Stripe.publishableKey = Secret.stripePublishableKey;
  await Stripe.instance.applySettings();
  
    runApp(DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      fontSizeResolver: (fontSize, instance) => fontSize.toDouble(),
      ensureScreenSize: true,
      designSize: baseScreenSize,
      minTextAdapt: true,
      useInheritedMediaQuery: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Language Learning App',
          theme: getTheme(),
          debugShowCheckedModeBanner: false,
          initialBinding: AppBindings(),
          home:  SplashView(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          ),
        );
      },
    );
  }
}

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.putAsync<ChatService>(
      () async {
        final service = ChatService();
        return await service.init();
      },
      permanent: true,
    ); 
    Get.put(AuthService(), permanent: true);
    Get.put(FirestoreService(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    Get.put(PaymentService(), permanent: true);
  }
}