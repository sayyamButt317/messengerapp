import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import '../View/verification.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AppFirebase {
  Future<void> sendVerificationCode(String number) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: ((phoneAuthCredential) =>
            printInfo(info: "user verified")),
        verificationFailed: (FirebaseAuthException e) =>
            printError(info: e.message!),
        codeSent: (String verificationId, int? resendToken) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("code", verificationId);
          Get.to(() => const Verification());
        },
        timeout: const Duration(seconds: 60),
        codeAutoRetrievalTimeout: ((String verificationId) => {}));
  }

  Future<void> verifyOTP(String otp) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? verificationId = pref.getString("code");
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!, smsCode: otp);
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> createUser(UserModel userModel) async {
    CollectionReference ref = FirebaseFirestore.instance.collection("User");
    await FirebaseAuth.instance.currentUser?.updateDisplayName(userModel.name);
    await FirebaseAuth.instance.currentUser?.updatePhotoURL(userModel.image);
    SharedPreferences.getInstance().then((value) {
      value.setString("number", userModel.number);
    });

    return await ref.doc(userModel.uId).set(userModel.toJson());
  }

  Future<String> uploadUserImage(String path, String uId, File file) async {
    Reference storage = FirebaseStorage.instance.ref(uId).child(path);
    UploadTask task = storage.putFile(file);
    TaskSnapshot snapshot = await task;
    String link = await snapshot.ref.getDownloadURL();
    return link;
  }
}
