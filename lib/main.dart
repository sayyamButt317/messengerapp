import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/View/user_data.dart';
import 'Bin/initial_binding.dart';
import 'Routes/routes.dart';
import 'View/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      /* darktheme: darkThemeData(context),
      theme: lightThemeData(context), */
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      getPages: [
        GetPage(name: Routes.splashscreen, page: () => const SplashScreen()),
        GetPage(name: Routes.DATA, page: () => const UserData()),
      ],
      initialRoute: Routes.splashscreen,
    );
  }
}
