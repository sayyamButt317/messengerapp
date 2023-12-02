import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Network/appfirebase.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Routes/routes.dart';
import '../View/user_data.dart';
import '../app/app_permission.dart';
import '../app/imagepicker.dart';
import '../models/user_model.dart';

class LoginController extends GetxController {
  TextEditingController numberController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  String code = "+92";
  RxString numberError = RxString("");
  RxString nameError = RxString("");
  RxString pinError = RxString("");
  FirebaseAuth auth = FirebaseAuth.instance;
  AppFirebase appFirebase = AppFirebase();
  late String number;
  RxBool isLoading = RxBool(false);
  var selectedImage = "".obs;
  AppPermission appPermission = AppPermission();
  @override
  void onClose() {
    super.onClose();
    numberController.dispose();
    otpController.dispose();
  }

  void sendOTP() async {
    if (numberController.text.isEmpty) {
      numberError("Field is required");
    } else if (numberController.text.length < 10) {
      numberError.value = "Invalid Number";
    } else {
      numberError("");
      number = code + numberController.text;
      await appFirebase.sendVerificationCode(number);
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
      Get.off(const UserData());
    }
  }

  void getImage(ImageSource source) async {
    switch (source) {
      case ImageSource.camera:
        File file = await imageFromCamera(true);
        selectedImage.value = file.path;
        break;
      case ImageSource.gallery:
        File file = await imageFromGallery(true);
        selectedImage.value = file.path;
        break;
    }
  }

  void skipInfo() {
    isLoading.value = true;
    var userModel = UserModel(
        uId: auth.currentUser!.uid,
        name: "",
        image: "",
        number: number,
        status: "Hey i'm using this app",
        typing: "false",
        online: DateTime.now().toString());
    appFirebase.createUser(userModel).then((value) => isLoading(false));
    Get.offAllNamed(Routes.DASHBOARD);
  }

  void uploadUserData() async {
    if (nameController.text.isEmpty) {
      nameError("Field is required");
    } else if (selectedImage.value == "") {
      printError(info: "Image is required");
    } else {
      nameError.value = "";
      isLoading.value = true;
      String link = await appFirebase.uploadUserImage(
          "profile/image", auth.currentUser!.uid, File(selectedImage.value));

      var userModel = UserModel(
          uId: auth.currentUser!.uid,
          name: nameController.text,
          image: link,
          number: number,
          status: "Hey I'm using this app",
          typing: "false",
          online: DateTime.now().toString());
      await appFirebase.createUser(userModel).then((value) => isLoading(false));
      Get.offAllNamed(Routes.DASHBOARD);
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
                          printError(info: "Storage Permission denied");
                        }
                        break;
                      case PermissionStatus.granted:
                        getImage(ImageSource.gallery);
                        break;
                      case PermissionStatus.restricted:
                        printError(info: "Storage Permission denied");
                        break;
                      case PermissionStatus.limited:
                        printError(info: "Storage Permission denied");
                        break;
                      case PermissionStatus.permanentlyDenied:
                        await openAppSettings();
                        break;
                      case PermissionStatus.provisional:
                      // TODO: Handle this case.
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
                          printError(info: "Camera Permission denied");
                        }
                        break;
                      case PermissionStatus.granted:
                        getImage(ImageSource.gallery);
                        break;
                      case PermissionStatus.restricted:
                        printError(info: "Camera Permission denied");
                        break;
                      case PermissionStatus.limited:
                        printError(info: "Camera Permission denied");
                        break;
                      case PermissionStatus.permanentlyDenied:
                        await openAppSettings();
                        break;
                      case PermissionStatus.provisional:
                      // TODO: Handle this case.
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
