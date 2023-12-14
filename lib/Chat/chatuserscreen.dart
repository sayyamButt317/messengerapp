
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:messenger/Chat/chat.dart';
import 'package:messenger/controllers/logincontroller.dart';

class ContactScreen extends GetView<LoginController> {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Contacts',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: controller.firestore.collection('Users').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                var users = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    String? userName = user['name'] as String?;
                    userName ??= 'Unknown User';

                    return ListTile(
                      leading: const SizedBox(
                        width: 50,
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage('images/avatar.jpg'),
                            ),
                          ],
                        ),
                      ),
                      title: Text(userName),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatScreen(
                              userId: "",
                              userName: "",
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              // Show the dialog to get the group chat name
              _showGroupChatNameDialog(context);
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  _showGroupChatNameDialog(BuildContext context) {
    TextEditingController groupNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Group Chat Name'),
          content: TextField(
            controller: groupNameController,
            decoration: const InputDecoration(hintText: 'Group Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Save the group chat name to Firestore
                String groupName = groupNameController.text.trim();
                if (groupName.isNotEmpty) {
                  try {
                    // Add a document to the "Users" collection with the group name
                    await controller.firestore.collection('Users').add({
                      'name': groupName,
                      // Add other group-related data if needed
                    });

                    // Close the dialog
                    Navigator.of(context).pop();
                  } catch (e) {

                    Get.snackbar("Error",'Error saving group name: $e',
                        snackPosition: SnackPosition.BOTTOM, colorText: Colors.red);
                    // Handle the error as needed
                  }
                } else {
                  Get.snackbar("Error", "Group Name is required",
                      snackPosition: SnackPosition.BOTTOM, colorText: Colors.red);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
