import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:messenger/Chat/chatuserscreen.dart';
import 'Bin/initial_binding.dart';
import 'Routes/routes.dart';
import 'View/splash.dart';

void main() async {
  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarIconBrightness:Brightness.light ,statusBarColor: Colors.white));
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
        GetPage(name: Routes.CHATUSER, page: () => ContactScreen()),
      ],
      initialRoute: Routes.splashscreen,
    );
  }
}
