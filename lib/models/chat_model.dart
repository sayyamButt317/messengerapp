class ChatMessage {
  final String sender;
  final String receiver;
  final String message;

  ChatMessage({
    required this.sender,
    required this.receiver,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'receiver': receiver,
      'message': message,
    };
  }

  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      sender: map['sender'],
      receiver: map['receiver'],
      message: map['message'],
    );
  }
}
