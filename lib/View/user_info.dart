import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/controllers/logincontroller.dart';


class Profile extends GetView<LoginController>{
  Profile({Key? key}) : super(key: key);


  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.5,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
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

                  GestureDetector(
                    onTap: () {
                      controller.showPicker(context);
                    },
                    child: const CircleAvatar(
                      radius: 60,
                      child:Image(image: AssetImage("images/avatar.jpg",),fit: BoxFit.fill,),
                    ),
                  ),

                  Container(
                    height: Get.height * 0.1,
                  ),
                  TextFormField(
                    controller: controller.nameController,
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
                              await controller.storeUserData();


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
                            return controller.isprofileloading.value
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
