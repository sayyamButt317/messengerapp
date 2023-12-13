import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MessageWidget extends StatelessWidget {
  final String sender;
  final String text;
  final FlutterTts flutterTts = FlutterTts();
  final Function onDelete;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  MessageWidget({
    required this.sender,
    required this.text,
    required this.onDelete,

    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                sender,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8.0),
            ],
          ),
          const SizedBox(height: 4.0),
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: sender == sender ? Colors.indigo[300] : Colors.grey[700],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.volume_up,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _speakText();
                  },
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
  void _deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }
  Future<void> _speakText() async {
    await flutterTts.speak(text);
  }
}
