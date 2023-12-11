import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  PhoneContact? _phoneContact;

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
      body: Center(
        child: _phoneContact != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Selected Contact: ${_phoneContact!.fullName}'),
                  Text('Phone Number: ${_phoneContact!.phoneNumber}'),
                ],
              )
            : const Text('No contact selected'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool permission = await FlutterContactPicker.requestPermission();
          if (permission) {
            if (await FlutterContactPicker.hasPermission()) {
              _phoneContact = await FlutterContactPicker.pickPhoneContact();
              if (_phoneContact != null &&
                  _phoneContact!.fullName!.isNotEmpty) {
                // Handle the selected contact, you can add it to a list or perform other actions
                print('Selected contact: ${_phoneContact!.fullName}');
              } else {
                // Handle the case where the user did not pick a contact
              }
              setState(() {});
            }
          }
        },
        child: const Icon(Icons.contacts),
      ),
    );
  }
}
