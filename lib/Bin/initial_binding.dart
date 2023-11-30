import "package:get/get.dart";

import "../controllers/logincontroller.dart";

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}
