import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../View/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  final String userId;
  final String userName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late ScrollController _scrollController;
  FlutterTts flutterTts = FlutterTts();
  SpeechToText speechToText = SpeechToText();
  bool isListening = false;
  String recognizedText = "";

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var messages = snapshot.data!.docs;
                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  var messageText = message['text'];
                  var messageSender = message['sender'];

                  var messageWidget = MessageWidget(
                    sender: messageSender,
                    text: messageText,
                    onDelete: () {
                      _deleteMessage(message.id);
                    },

                  );
                  messageWidgets.add(messageWidget);
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messageWidgets.length,
                  itemBuilder: (context, index) {
                    return messageWidgets[index];
                  },
                );
              },
            ),
          ),
          buildMessageComposer(),
        ],
      ),
    );
  }

  Widget buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.black12),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              _sendMessage(recognizedText);
            },
          ),
          IconButton(
            onPressed: () async {
              var available = await speechToText.initialize();
              if (!isListening) {
                if (available) {
                  setState(() {
                    isListening = true;
                  });
                  await speechToText.listen(
                    onResult: (result) {
                      setState(() {
                        _messageController.text = result.recognizedWords;
                      });
                    },
                  );
                }
              } else {
                await speechToText.stop();
                setState(() {
                  isListening = false;
                });
                Get.snackbar(
                  'Error',
                  "Speech recognition not available",
                  backgroundColor: Colors.transparent,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                  colorText: Colors.red,
                  borderWidth: 1,
                  borderColor: Colors.red,
                );
              }
            },
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 20,
              child: Icon(
                isListening ? Icons.mic : Icons.mic_none,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _sendMessage(recognizedText) {
    String message = _messageController.text;
    if (message.isNotEmpty) {
      _firestore.collection('messages').add({
        'text': message,
        'sender': widget.userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> speakMessage() async {
    if (_messageController.text.isNotEmpty) {
      await flutterTts.speak(_messageController.text);
    }
  }

  void _deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }
}
