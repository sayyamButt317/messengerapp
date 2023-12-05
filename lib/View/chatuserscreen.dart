import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chat.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('User');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FirebaseAnimatedList(
        query: ref,
        itemBuilder: (context, snapshot, animation, index) {
          return Card(
            child: ListTile(
              onTap: () {
                // Navigate to ChatScreen with the selected user's data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                        // Pass necessary data to ChatScreen
                        // userId: snapshot.key.toString(),
                        // userName: snapshot.child('Name').value.toString(),
                        // Add other necessary data
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
                child: snapshot.child('profile').value.toString() == ""
                    ? const Icon(Icons.person_outlined)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image(
                          fit: BoxFit.fill,
                          image: NetworkImage(
                            snapshot.child('profile').value.toString(),
                          ),
                        ),
                      ),
              ),
              title: Text(snapshot.child('Name').value.toString()),
              subtitle: Text(snapshot.child('message').value.toString()),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add logic for FAB onPressed event (e.g., navigate to a new screen)
          // Example:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
