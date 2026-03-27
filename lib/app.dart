import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:innolab/src/features/auth/marcelo_login/screens/user_login_web.dart';
import 'package:innolab/src/features/core/admin/home/screens/admin_home_web.dart';
import 'package:innolab/src/features/home/screens/user_home_screen.dart';
import 'package:innolab/src/features/routing/authWrapper.dart';
import 'package:innolab/utils/theme/theme.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  
      themeMode: ThemeMode.system,
      theme: ATheme.lightTheme,
      darkTheme: ATheme.darkTheme,
      navigatorKey: Get.key,

      home: Authwrapper(),
      // home: AInventoryPage(),
      // home: UserLoginWeb(),
    );
  }
}