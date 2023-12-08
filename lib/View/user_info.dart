import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:messenger/View/chatuserscreen.dart';
import 'package:messenger/controllers/logincontroller.dart';
import 'package:path/path.dart' as Path;

import '../models/user_model.dart';

class Profile extends StatefulWidget {
  const Profile({
    Key? key,
  }) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  final LoginController getxcontroller =
      Get.put<LoginController>(LoginController());

  var myuser = UserModel(uId: '', image: '', name: '').obs;
  RxString imageUrl = RxString('');
  File? selectedImage;
  Future<void> getImage(ImageSource camera) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      maxWidth: 150,
      maxHeight: 200,
      source: camera,
    );
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<String> uploadImage(File? image) async {
    if (image == null) {
      return '';
    }

    String imageUrl = '';
    try {
      String fileName = Path.basename(image.path);
      var reference = FirebaseStorage.instance.ref().child('Users/$fileName');
      TaskSnapshot taskSnapshot = await reference.putFile(image);
      imageUrl = await taskSnapshot.ref.getDownloadURL();
      debugPrint("Download URL: $imageUrl");
    } catch (error) {
      debugPrint("Image Upload Error: $error");
    }
    return imageUrl;
  }

  Future<void> storeUserInfo() async {
    try {
      String imageurl = '';

      if (selectedImage != null) {
        imageurl = await uploadImage(selectedImage!);
      }

      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Update user data with image URL if it's not empty
      if (imageurl.isNotEmpty) {
        await FirebaseFirestore.instance.collection('User').doc(uid).set({
          'image': imageurl,
        }, SetOptions(merge: true));
      }

      // Update user data with name and phone
      await FirebaseFirestore.instance.collection('User').doc(uid).set({
        'name': nameController.text,
      }, SetOptions(merge: true));

      getxcontroller.isprofileloading(true);
      Get.offAll(() => const ContactScreen());
    } catch (error) {
      Get.snackbar(
        'Error',
        "There was an error updating your profile.",
        backgroundColor: Colors.transparent,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        colorText: Colors.red,
        borderWidth: 1,
        borderColor: Colors.red,
      );
    }
  }

  Future<void> getuserinfo() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .snapshots()
        .listen((event) {
      myuser.value = UserModel.fromJson(event.data() ?? {});
      imageUrl.value = myuser.value.image ?? '';
      nameController.text = myuser.value.name ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.5,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Profile',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(),
                  SizedBox(
                    height: Get.height * 0.2,
                    child: Obx(() {
                      return Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: GestureDetector(
                              onTap: () {
                                getImage(ImageSource.camera);
                              },
                              child: selectedImage == null
                                  ? (myuser.value.image != null &&
                                          myuser.value.image!.isNotEmpty)
                                      ? Container(
                                          width: 120,
                                          height: 120,
                                          margin:
                                              const EdgeInsets.only(bottom: 20),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 5,
                                            ),
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: NetworkImage(
                                                  myuser.value.image!),
                                            ),
                                            shape: BoxShape.circle,
                                            color: Colors.grey,
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.camera_alt_outlined,
                                              size: 40,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 120,
                                          height: 120,
                                          margin:
                                              const EdgeInsets.only(bottom: 20),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey,
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.camera_alt_outlined,
                                              size: 40,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                  : Container(
                                      width: 120,
                                      height: 120,
                                      margin: const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: FileImage(selectedImage!),
                                          fit: BoxFit.fill,
                                        ),
                                        shape: BoxShape.circle,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                          )
                        ],
                      );
                    }),
                  ),
                  Container(
                    height: Get.height * 0.1,
                  ),
                  TextFormField(
                    controller: nameController,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Name",
                      hintText: "Name",
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.black,
                        size: 18,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Container(
                    height: Get.height * 0.2,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MaterialButton(
                          onPressed: () async {
                            if (nameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please fill all required fields',
                                  ),
                                ),
                              );
                            } else {
                              getxcontroller.isprofileloading(true);
                              await storeUserInfo();
                              getxcontroller.isprofileloading(false);
                            }
                          },
                          height: 50,
                          minWidth: 300,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Theme.of(context).primaryColor,
                          child: Obx(() {
                            return getxcontroller.isprofileloading.value
                                ? const CircularProgressIndicator(
                                    strokeWidth: 3, color: Colors.white)
                                : const Text(
                                    "Save",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
