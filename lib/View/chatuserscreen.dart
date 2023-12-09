import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chat.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Contacts',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('User').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          final List<DocumentSnapshot> contacts = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index].data() as Map<String, dynamic>;
              final String name = contact['name'] ?? '';
              final String image = contact['image'] ?? '';

              return ListTile(
                onTap: () {
                  Get.to(ChatScreen(
                    userId: contacts[index].id,
                    userName: name,
                    userImage: image,
                  ));
                },
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(image),
                ),
                title: Text(name),
                subtitle:
                    const Text('Last message'), // Add last message logic here
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const ChatScreen(userId: "", userName: "", userImage: ""));
        },
        child: const Icon(Icons.messenger_rounded),
      ),
    );
  }
}
