import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String sender;
  final String receiver;
  final String message;
  final Timestamp timestamp;

  ChatMessage({
    required this.sender,
    required this.receiver,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'receiver': receiver,
      'message': message,
      'timestamp': timestamp,
    };
  }

  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      sender: map['sender'],
      receiver: map['receiver'],
      message: map['message'],
      timestamp: map['timestamp'],
    );
  }
}
