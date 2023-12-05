import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/View/chatuserscreen.dart';
import 'Bin/initial_binding.dart';
import 'Routes/routes.dart';
import 'View/chat.dart';
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
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      getPages: [
        GetPage(name: Routes.splashscreen, page: () => const SplashScreen()),
        GetPage(name: Routes.CHATUSER, page: () => const ContactScreen()),
      ],
      initialRoute: Routes.splashscreen,
    );
  }
}
