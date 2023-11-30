import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import '../View/verification.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

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
}
