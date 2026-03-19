import 'package:flutter/material.dart';
import 'package:innolab/utils/theme/custom_themes/text_theme.dart';
import 'package:innolab/utils/theme/custom_themes/chip_theme.dart';
import 'package:innolab/utils/theme/custom_themes/appbar_theme.dart';
import 'package:innolab/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:innolab/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:innolab/utils/theme/custom_themes/outline_theme.dart';
import 'package:innolab/utils/theme/custom_themes/textfield_theme.dart';


class ATheme {
  ATheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    textTheme:  ATextTheme.LightTxtTheme,
    chipTheme: AChipTheme.lightChipTheme,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AAppbarTheme.lightAppbarTheme,
    bottomSheetTheme:  ABottomSheetTheme.lightBottomSheetTheme,
    elevatedButtonTheme: AElevatedButtonThemeData.lightElavationButtonTheme,
    outlinedButtonTheme: AOutlineTheme.lightOutlineTheme,
    inputDecorationTheme: ATextFormFieldTheme.darkTextFormFieldTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    textTheme:  ATextTheme.DarkTxtTheme,
    chipTheme: AChipTheme.lightChipTheme,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AAppbarTheme.darkAppbarTheme,
    bottomSheetTheme:  ABottomSheetTheme.darkBottomSheetTheme,
    elevatedButtonTheme: AElevatedButtonThemeData.darkElavationButtonTheme,
    outlinedButtonTheme: AOutlineTheme.darkOutlineTheme,
    inputDecorationTheme: ATextFormFieldTheme.darkTextFormFieldTheme,
  );
}
