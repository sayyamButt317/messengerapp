import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late ScrollController _scrollController;
  FlutterTts flutterTts = FlutterTts();
  AudioPlayer _audioPlayer = AudioPlayer();


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
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

                var messages = snapshot.data!.docs.reversed;
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

                return ListView(
                  controller: _scrollController,
                  reverse: true,
                  children: messageWidgets,
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
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
              _sendMessage();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.mic,
              color: Colors.white,
            ),
            onPressed: () {
              _speakMessage();
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _firestore.collection('messages').add({
        'text': _messageController.text,
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

  Future<void> _speakMessage() async {
    if (_messageController.text.isNotEmpty) {
      await flutterTts.speak(_messageController.text);
    }
  }

  void _deleteMessage(String messageId) {
    _firestore.collection('messages').doc(messageId).delete();
  }
}

class MessageWidget extends StatelessWidget {
  final String sender;
  final String text;
  final FlutterTts flutterTts = FlutterTts();
  final Function onDelete;

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
              color: sender == 'User' ? Colors.blue : Colors.grey[700],
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
                IconButton(
                  icon: const Icon(
                    Icons.textsms_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Add logic for handling text message button tap
                  },
                ),
                GestureDetector(
                  onTap: () {
                    onDelete();
                  },
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      // Add logic for handling delete button tap
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _speakText() async {
    await flutterTts.speak(text);
  }
}
