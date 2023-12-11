import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final List<PhoneContact> _selectedContacts = [];

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
          if (_selectedContacts.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _selectedContacts.length,
                itemBuilder: (context, index) {
                  final contact = _selectedContacts[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage('images/avatar.jpg'),
                    ),
                    title: Text(contact.fullName ?? ''),
                    // subtitle: Text(contact.phoneNumber ?? ''),
                  );
                },
              ),
            )
          else
            const Expanded(
              child: Center(child: Text('No contacts selected')),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool permission = await FlutterContactPicker.requestPermission();
          if (permission) {
            if (await FlutterContactPicker.hasPermission()) {
              PhoneContact? selectedContact =
                  await FlutterContactPicker.pickPhoneContact();
              if (selectedContact.fullName!.isNotEmpty) {
                setState(() {
                  _selectedContacts.add(selectedContact);
                });
              }
            }
          }
        },
        child: const Icon(Icons.contacts),
      ),
    );
  }
}
