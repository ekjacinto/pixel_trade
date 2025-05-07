import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser?.uid ?? '';

  // Get or create a chat between two users
  Future<String> getOrCreateChat(String otherUserId) async {
    if (userId.isEmpty) throw Exception('Not authenticated');

    // Sort user IDs to ensure consistent chat ID
    final List<String> participants = [userId, otherUserId]..sort();
    
    // Check if chat already exists
    final querySnapshot = await _firestore
        .collection('chats')
        .where('participants', isEqualTo: participants)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    }

    // Create new chat
    final chatDoc = await _firestore.collection('chats').add({
      'participants': participants,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
    });

    return chatDoc.id;
  }

  // Send a message
  Future<void> sendMessage(String chatId, String message) async {
    if (userId.isEmpty) throw Exception('Not authenticated');

    // Update chat's last message
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessage': message,
    });
  }

  // Get messages stream for a chat
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
    });
  }

  // Get user's chats
  Stream<List<Chat>> getUserChats() {
    if (userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Chat.fromFirestore(doc))
          .toList();
    });
  }
} 