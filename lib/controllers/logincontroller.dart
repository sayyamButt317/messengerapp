import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messenger/View/user_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Network/appfirebase.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Routes/routes.dart';
import '../View/chatuserscreen.dart';
import '../View/verification.dart';
import '../app/app_permission.dart';
import '../models/user_model.dart';

class LoginController extends GetxController {
  TextEditingController numberController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String code = "+92";
  RxString numberError = RxString("");
  RxString nameError = RxString("");
  RxString pinError = RxString("");
  RxString selectedimage = "".obs;
  FirebaseAuth auth = FirebaseAuth.instance;
  AppFirebase appFirebase = AppFirebase();
  late String number;
  RxBool isLoading = RxBool(false);
  RxString selectedImage = "".obs;
  AppPermission appPermission = AppPermission();
  var isprofileloading = false.obs;
  RxString imageUrl = RxString('');
  var myuser = UserModel(uId: '', name: '').obs;

  void setIsProfileLoading(bool isLoading) {
    isprofileloading.value = isLoading;
  }

  @override
  void onClose() {
    super.onClose();
    numberController.dispose();
    otpController.dispose();
  }

  Future<void> sendVerificationCode(String number) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: ((phoneAuthCredential) =>
            printInfo(info: "user verified")),
        verificationFailed: (FirebaseAuthException e) => Get.snackbar(
              'Error',
              e.message!,
              backgroundColor: Colors.transparent,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
              colorText: Colors.red,
              borderWidth: 1,
              borderColor: Colors.red,
            ),
        codeSent: (String verificationId, int? resendToken) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("code", verificationId);
          Get.to(const Verification());
        },
        timeout: const Duration(seconds: 60),
        codeAutoRetrievalTimeout: ((String verificationId) => {}));
  }

  sendOTP() async {
    if (numberController.text.isEmpty) {
      numberError("Field is required");
    } else if (numberController.text.length < 10) {
      numberError.value = "Invalid Number";
    } else {
      numberError("");
      number = code + numberController.text;
      await sendVerificationCode(number);
    }
  }

  void verifyOTP() async {
    if (otpController.text.isEmpty) {
      pinError.value = "Field is required";
    } else if (otpController.text.length < 6) {
      pinError.value = "Invalid Pin";
    } else {
      isLoading.value = true;
      await appFirebase.verifyOTP(otpController.text);
      isLoading.value = false;
      Get.off(Profile());
    }
  }

  void skipInfo() {
    isLoading.value = true;
    var userModel = UserModel(
      uId: auth.currentUser!.uid,
      name: "",
    );
    appFirebase.createUser(userModel).then((value) => isLoading(false));
    Get.offAllNamed(Routes.CHATUSER);
  }

  storeUserData() async {
    if (nameController.text.isEmpty) {
      Get.snackbar("Error", "Name Field is required",
          snackPosition: SnackPosition.BOTTOM, colorText: Colors.red);
    } else {
      isprofileloading(true);

      var userModel = UserModel(
        uId: auth.currentUser!.uid,
        name: nameController.text,
      );
      await appFirebase.createUser(userModel).then((value) => isLoading(false));
      Get.offAllNamed(Routes.CHATUSER);
    }
  }

  // String getConversationID(String id) =>  userModel.uId.hashCode <= id.hashCode
  //     ? '${user.uid}_$'
  //     : '${id}_${user.uid}';
  //
  // static Stream<Query>

  getImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      selectedImage.value = image.path.toString();
    }
  }

  void showPicker(BuildContext context) {
    Get.bottomSheet(
        SafeArea(
          child: Container(
            color: Theme.of(context).colorScheme.background,
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text("Photo Library"),
                  onTap: () async {
                    Navigator.pop(context);
                    var status = await appPermission.isStoragePermissionOk();
                    switch (status) {
                      case PermissionStatus.denied:
                        var status =
                            await Permission.storage.request().isDenied;
                        if (status) {
                          getImage(ImageSource.gallery);
                        } else {
                          Get.snackbar("Error", "Storage Permission denied",
                              snackPosition: SnackPosition.BOTTOM,
                              colorText: Colors.red);
                        }
                        break;
                      case PermissionStatus.granted:
                        getImage(ImageSource.gallery);
                        break;
                      case PermissionStatus.restricted:
                        Get.snackbar("Error", "Storage Permission denied",
                            snackPosition: SnackPosition.BOTTOM,
                            colorText: Colors.red);
                        break;
                      case PermissionStatus.limited:
                        Get.snackbar("Error", "Storage Permission denied",
                            snackPosition: SnackPosition.BOTTOM,
                            colorText: Colors.red);
                        break;
                      case PermissionStatus.permanentlyDenied:
                        await openAppSettings();
                        break;
                      case PermissionStatus.provisional:
                        Get.snackbar("Error", "Provisional permission",
                            snackPosition: SnackPosition.BOTTOM,
                            colorText: Colors.red);
                        break;
                    }
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_camera,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text("Camera"),
                  onTap: () async {
                    Navigator.pop(context);
                    var status = await appPermission.isCameraPermissionOk();
                    switch (status) {
                      case PermissionStatus.denied:
                        var status = await Permission.camera.request().isDenied;
                        if (status) {
                          getImage(ImageSource.camera);
                        } else {
                          Get.snackbar("Error", "Camera Permission denied",
                              snackPosition: SnackPosition.BOTTOM,
                              colorText: Colors.red);
                        }
                        break;
                      case PermissionStatus.granted:
                        getImage(ImageSource.gallery);
                        break;
                      case PermissionStatus.restricted:
                        Get.snackbar("Error", "Camera Permission denied",
                            snackPosition: SnackPosition.BOTTOM,
                            colorText: Colors.red);
                        break;
                      case PermissionStatus.limited:
                        Get.snackbar("Error", "Camera Permission denied",
                            snackPosition: SnackPosition.BOTTOM,
                            colorText: Colors.red);
                        break;
                      case PermissionStatus.permanentlyDenied:
                        await openAppSettings();
                        break;
                      case PermissionStatus.provisional:
                        Get.snackbar("Error", "Provisional permission",
                            snackPosition: SnackPosition.BOTTOM,
                            colorText: Colors.red);
                        break;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)));
  }
}
