import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

class Chat {
  final String id;
  final List<String> participants;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String lastMessage;

  Chat({
    required this.id,
    required this.participants,
    required this.createdAt,
    required this.lastMessageAt,
    required this.lastMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'lastMessage': lastMessage,
    };
  }

  factory Chat.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Chat(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastMessageAt: (data['lastMessageAt'] as Timestamp).toDate(),
      lastMessage: data['lastMessage'] ?? '',
    );
  }
} 