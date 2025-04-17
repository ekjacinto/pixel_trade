import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/card.dart';

class CardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get all cards
  Stream<List<Card>> getCards() {
    return _firestore.collection('cards').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Card.fromFirestore(doc)).toList();
    });
  }

  // Get a single card by ID
  Future<Card?> getCard(String cardId) async {
    final doc = await _firestore.collection('cards').doc(cardId).get();
    if (doc.exists) {
      return Card.fromFirestore(doc);
    }
    return null;
  }
} 