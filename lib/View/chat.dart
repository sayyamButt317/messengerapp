import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
    required this.userId,
    required this.userName,
    required this.userImage,
  }) : super(key: key);

  final String userId;
  final String userName;
  final userImage;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late ScrollController _scrollController;
  FlutterTts flutterTts = FlutterTts();
  late AudioPlayer audioPlayer;
  Record? audioRecord;
  bool isRecording = false;
  String audioPath = "";
  SpeechToText speechToText = SpeechToText();

  bool isListening = false;
  String recognizedText = "";

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    super.initState();
    _scrollController = ScrollController();
    checkMicrophoneAvailability();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
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
                  reverse: true, // Set reverse to true
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
                hintStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.send,
              color: Colors.white,
            ),
            onPressed: () {
              _sendMessage(recognizedText);
            },
          ),
          IconButton(
            icon: isListening
                ? const Icon(
              Icons.stop,
              color: Colors.red,
            )
                : const Icon(
              Icons.mic,
              color: Colors.white,
            ),
            onPressed: () {
              isListening ? stopListening() : startListening();
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String recognizedText) {
    String message = _messageController.text;
    if (message.isNotEmpty) {
      _firestore.collection('messages').add({
        'text': message,
        'sender': 'User',
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

  void checkMicrophoneAvailability() async {
    SpeechToText speechToText = SpeechToText();
    bool available = await speechToText.initialize(
      onStatus: (status) {
        if (status == speechToText.isNotListening) {
          setState(() {
            isListening = false;
          });
        }
      },
      onError: (errorNotification) {
        print("Error: $errorNotification");
      },
    );

    if (available) {
      setState(() {
        print('Microphone available: $available');
      });
    } else {
      print("The user has denied the use of speech recognition.");
      // You might want to show a message or ask for permission again.
    }
  }

  Future<void> startListening() async {
    try {
      bool available = await speechToText.initialize();
      if (available) {
        await speechToText.listen(
          onResult: (result) {
            setState(() {
              recognizedText = result.recognizedWords;
            });
          },
        );
        setState(() {
          isListening = true;
        });
      } else {
        print("The user has denied the use of speech recognition.");
      }
    } catch (e) {
      print('Error starting speech recognition: $e');
    }
  }



  void stopListening() async {
    try {
      await speechToText.stop();
      setState(() {
        isListening = false;
        _sendMessage(recognizedText);
        recognizedText =
        "";
      });
    } catch (e) {
      print('Error stopping speech recognition: $e');
    }
  }

  void _deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }
}

