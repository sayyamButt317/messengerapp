import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messenger/View/chat.dart';


class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;



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
              future: firestore.collection('Users').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ));
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
                        height:80,

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
                      }
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
