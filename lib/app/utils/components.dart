import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

//! ------------------------------------------------------------------------------------------------ Sizes
get baseScreenSize => const Size(
  360,
  690,
);
get defaultPadding =>
    24.sp;
get defaultBoxHeight =>
    defaultPadding *
    2;
get defaultBorderRadius =>
    8.0;
const paginationPageSize =
    50;
const maxBoxWidth =
    400.0;

//* Border
get borderWidth1 =>
    2.sp;
get borderWidth2 =>
    1.sp;

//! ------------------------------------------------------------------------------------------------ Time
const defaultSplashScreenShow = Duration(
  seconds:
      3,
);
const defaultDuration = Duration(
  milliseconds:
      500,
);
const apiCallTimeOut = Duration(
  seconds:
      60,
);
const otpWaiting = Duration(
  seconds:
      10,
);

//! ------------------------------------------------------------------------------------------------ Color
const _primaryLight = Color(
  0xff007AFF,
);
const _secondaryColor = Color(
  0xff3395FF,
);
const _secondaryColor1 = Color(
  0xff767C80,
);
const _secondaryColor2 = Color(
  0xff66AFFF,
);
const cBackgroundColor = Color(
  0xff99CAFF,
);
const cBlack = Color.fromARGB(
  255,
  0,
  0,
  0,
);
const cAlert = Color(
  0xffF7CB44,
);
//! ------------------------------------------------------------------------------------------------ Text
get textTheme => GoogleFonts.montserratTextTheme(
  Typography.englishLike2018.apply(
    fontSizeFactor:
        1.sp,
  ),
);

get buttonTheme => ButtonThemeData(
  height:
      defaultBoxHeight,
);
get appBarTheme => AppBarTheme(
  toolbarHeight:
      defaultBoxHeight,
  surfaceTintColor:
      Colors.transparent,
  centerTitle:
      false,
);

//! ------------------------------------------------------------------------------------------------ Theme
ThemeData
getTheme({
  bool isDark =
      false,
}) {
  final colorS = ColorScheme.fromSeed(
    seedColor:
        _primaryLight,
    secondary:
        _secondaryColor,
    onSecondary:
        _secondaryColor1,
    secondaryContainer:
        _secondaryColor2,
    shadow:
        cBlack,
    brightness:
        isDark
            ? Brightness.dark
            : Brightness.light,
  );
  return ThemeData(
    useMaterial3:
        true,
    // textTheme: textTheme,
    buttonTheme:
        buttonTheme,
    appBarTheme:
        appBarTheme,
    colorScheme:
        colorS,
    // dialogTheme: DialogTheme(backgroundColor: colorS.primary),
  );
}
