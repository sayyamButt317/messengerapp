import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chat.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('User');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: users.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (context, index) {
              var user = snapshot.data?.docs[index];
              if (user != null) {
                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            userId: user.id,
                            userName: user['name'],
                            userImage: user['image'],
                          ),
                        ),
                      );
                    },
                    leading: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      child: user['image'].toString().isEmpty
                          ? const Icon(Icons.person_outlined)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image(
                                fit: BoxFit.fill,
                                image: NetworkImage(user['image']),
                              ),
                            ),
                    ),
                    title: Text(user['name'].toString()),
                    subtitle: Text(user['message'].toString()),
                  ),
                );
              } else {
                return Container();
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatScreen(
                userId: '',
                userName: '',
                userImage: "",
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
